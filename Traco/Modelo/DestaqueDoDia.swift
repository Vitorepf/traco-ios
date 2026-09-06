import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

/// A linha do Destaque de hoje — a única coisa que a tela bloqueada mostra.
/// Nunca expressiva, nunca trancada: só a frase que o autor escreveu.
/// Some no mesmo instante em que a nota deixa de ser o Destaque.
///
/// ADR 05u: este é o ESTADO (linha, dona, dia, feito), guardado pelo app; a
/// tela bloqueada e o widget leem a projeção em `Superficie`, publicada
/// depois de cada mudança. Feito guarda a dona e o dia: amanhã o Destaque é
/// outro, e marcar um cartão velho não altera o novo.
enum DestaqueDoDia: Sendable {
    nonisolated static let chaveLinha = "destaqueLinha"
    nonisolated static let chaveDia = "destaqueDia"
    nonisolated static let chaveId = "destaqueId"
    nonisolated static let chaveFeito = "destaqueFeitoEm"
    nonisolated static let chaveFeitoId = "destaqueFeitoId"

    nonisolated private static var defaults: UserDefaults { SuperficieDisco.defaults }

    nonisolated static func gravar(_ linha: String, id: UUID, em data: Date = .now) {
        let corte = linha.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !corte.isEmpty else {
            apagar(id: id)
            return
        }
        let d = defaults
        let dia = Superficie.diaISO(data)
        d.set(corte, forKey: chaveLinha)
        d.set(dia, forKey: chaveDia)
        d.set(id.uuidString, forKey: chaveId)
        publicar(agora: data)
        FilaDeAtividade.compartilhada.enfileirar { await reconciliar(agora: data) }
    }

    /// Só a dona da linha pode apagá-la. Outra nota não silencia o Destaque alheio.
    nonisolated static func apagar(id: UUID) {
        let d = defaults
        guard d.string(forKey: chaveId) == id.uuidString else { return }
        for c in [chaveLinha, chaveDia, chaveId, chaveFeito, chaveFeitoId] { d.removeObject(forKey: c) }
        publicar()
        FilaDeAtividade.compartilhada.enfileirar { await encerrarAtividades() }
    }

    // MARK: - Feito (com identidade; nunca alterna)

    /// Marca feito SE o Destaque de hoje ainda é este. Devolve `false` quando
    /// não é (cartão velho) ou quando a superfície recusou a gravação — e aí
    /// nada é confirmado: o estado volta ao que era.
    @discardableResult
    nonisolated static func marcarFeito(id: UUID, dia: String, agora: Date = .now) -> Bool {
        guard eDeHoje(id: id, dia: dia, agora: agora) else { return false }
        let d = defaults
        let feitoAntes = (d.string(forKey: chaveFeito), d.string(forKey: chaveFeitoId))
        d.set(dia, forKey: chaveFeito)
        d.set(id.uuidString, forKey: chaveFeitoId)
        guard publicar(agora: agora) else {
            d.set(feitoAntes.0, forKey: chaveFeito)
            d.set(feitoAntes.1, forKey: chaveFeitoId)
            return false
        }
        return true
    }

    @discardableResult
    nonisolated static func desfazerFeito(id: UUID, dia: String, agora: Date = .now) -> Bool {
        guard eDeHoje(id: id, dia: dia, agora: agora), feitoHoje(agora: agora) else { return false }
        let d = defaults
        d.removeObject(forKey: chaveFeito)
        d.removeObject(forKey: chaveFeitoId)
        guard publicar(agora: agora) else {
            d.set(dia, forKey: chaveFeito)
            d.set(id.uuidString, forKey: chaveFeitoId)
            return false
        }
        return true
    }

    nonisolated private static func eDeHoje(id: UUID, dia: String, agora: Date) -> Bool {
        let d = defaults
        return dia == Superficie.diaISO(agora)
            && d.string(forKey: chaveDia) == dia
            && d.string(forKey: chaveId) == id.uuidString
            && linhaDeHoje(agora: agora) != nil
    }

    nonisolated static func feitoHoje(agora: Date = .now) -> Bool {
        let d = defaults
        return d.string(forKey: chaveFeito) == Superficie.diaISO(agora)
            && d.string(forKey: chaveFeitoId) == d.string(forKey: chaveId)
    }

    nonisolated static func linhaDeHoje(agora: Date = .now) -> String? {
        let d = defaults
        guard d.string(forKey: chaveDia) == Superficie.diaISO(agora) else { return nil }
        let linha = d.string(forKey: chaveLinha)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return linha.isEmpty ? nil : linha
    }

    nonisolated static func idDeHoje(agora: Date = .now) -> UUID? {
        guard linhaDeHoje(agora: agora) != nil else { return nil }
        return defaults.string(forKey: chaveId).flatMap(UUID.init(uuidString:))
    }

    /// Sem Destaque o ecrã diz o nome do app — nunca um travessão a fingir linha.
    nonisolated static func naTelaBloqueada(agora: Date = .now) -> String {
        linhaDeHoje(agora: agora) ?? "Traço"
    }

    // MARK: - Projeção

    nonisolated static func projecao(agora: Date = .now) -> Superficie.Destaque? {
        guard let linha = linhaDeHoje(agora: agora), let id = idDeHoje(agora: agora) else { return nil }
        return .init(id: id, dia: Superficie.diaISO(agora), linha: linha, feito: feitoHoje(agora: agora))
    }

    @discardableResult
    nonisolated static func publicar(agora: Date = .now) -> Bool {
        SuperficieDisco.publicar(agora: agora) { $0.destaque = projecao(agora: agora) }
    }

    // MARK: - Live Activity (a Ilha e a tela bloqueada, enquanto o dia dura)

    /// Reconcilia o que está vivo com o estado guardado: uma atividade só,
    /// da dona de hoje, e nenhuma quando não há Destaque ou ele já foi feito.
    /// Chamada no arranque, no retorno à cena e depois de cada comando.
    // nonisolated: Activity não é Sendable; sem fronteira de ator não há envio
    nonisolated static func reconciliar(agora: Date = .now) async {
        #if canImport(ActivityKit)
        guard let p = projecao(agora: agora), !p.feito else {
            await encerrarAtividades()
            return
        }
        guard SuperficieDisco.atividades() else { return }
        let estado = DestaqueAtividade.ContentState(linha: p.linha)
        let meiaNoite = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: agora) ?? agora)
        let conteudo = ActivityContent(state: estado, staleDate: meiaNoite)
        var viva: Activity<DestaqueAtividade>?
        for a in Activity<DestaqueAtividade>.activities {
            if viva == nil, a.attributes.dia == p.dia, a.attributes.id == p.id, a.activityState == .active {
                viva = a
            } else {
                await a.end(nil, dismissalPolicy: .immediate)
            }
        }
        if let viva {
            if viva.content.state != estado { await viva.update(conteudo) }
            return
        }
        _ = try? Activity.request(attributes: DestaqueAtividade(dia: p.dia, id: p.id), content: conteudo)
        #endif
    }

    nonisolated static func encerrarAtividades() async {
        #if canImport(ActivityKit)
        for a in Activity<DestaqueAtividade>.activities {
            await a.end(nil, dismissalPolicy: .immediate)
        }
        #endif
    }
}

/// Uma fila para a Live Activity: gravar e apagar em sequência, nunca em
/// corrida (dois autosaves seguidos criavam dois cartões).
nonisolated final class FilaDeAtividade: @unchecked Sendable {
    nonisolated static let compartilhada = FilaDeAtividade()
    private let tranca = NSLock()
    private var ultima: Task<Void, Never>?

    nonisolated func enfileirar(_ op: @escaping @Sendable () async -> Void) {
        tranca.lock()
        let anterior = ultima
        ultima = Task {
            await anterior?.value
            await op()
        }
        tranca.unlock()
    }
}
