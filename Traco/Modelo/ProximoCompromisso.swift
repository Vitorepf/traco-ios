import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif
#if canImport(WidgetKit)
import WidgetKit
#endif

/// ADR 2026-09-04a — o próximo compromisso, FORA do app.
///
/// A palavra do dono: *"está marcado não adianta nada se eu não sei"*. Um
/// compromisso que só existe dentro do Traço é um compromisso que o autor
/// descobre tarde — porque a tela que ele mais olha não é a do Traço, é a
/// bloqueada. Então o próximo mora no App Group e aparece em três lugares:
/// widget da casa, widget da tela bloqueada e Live Activity na Ilha.
///
/// Só o que ele MESMO marcou e o que o iPhone dele já mostra. Nota, expressiva
/// e trancada não passam por aqui: o selo vale para a tela bloqueada como vale
/// para a rede.
nonisolated enum ProximoCompromisso: Sendable {
    nonisolated static let suite = "group.app.traco"
    private static let chaveTitulo = "proximoTitulo"
    private static let chaveInicio = "proximoInicio"
    private static let chaveFim = "proximoFim"
    private static let chaveDiaInteiro = "proximoDiaInteiro"
    private static let chaveAviso = "proximoAviso"
    private static let chaveId = "proximoId"
    private static let chaveLembrete = "proximoLembrete"

    /// O que a tela mostra. `aviso` é o instante em que vai tocar — nil quando
    /// o autor desligou; a superfície diz as duas coisas, nunca finge.
    nonisolated struct Fatia: Equatable, Sendable {
        /// O id do compromisso: a tela bloqueada precisa dele para AGIR
        /// (ADR 04f), não só para mostrar.
        var id: UUID = UUID()
        var titulo: String
        var inicio: Date
        var fim: Date
        var diaInteiro: Bool
        var aviso: Date?
        /// A soneca que o autor pediu da própria tela bloqueada.
        var lembrarEm: Date?

        func comLembrete(_ quando: Date) -> Fatia {
            var f = self
            f.lembrarEm = quando
            return f
        }
    }

    private static var defaults: UserDefaults { UserDefaults(suiteName: suite) ?? .standard }

    nonisolated static func gravar(_ f: Fatia?) {
        let d = defaults
        guard let f else {
            for c in [chaveTitulo, chaveInicio, chaveFim, chaveDiaInteiro, chaveAviso,
                      chaveId, chaveLembrete] {
                d.removeObject(forKey: c)
            }
            recarregar()
            return
        }
        d.set(f.id.uuidString, forKey: chaveId)
        d.set(f.lembrarEm?.timeIntervalSince1970 ?? 0, forKey: chaveLembrete)
        d.set(f.titulo, forKey: chaveTitulo)
        d.set(f.inicio.timeIntervalSince1970, forKey: chaveInicio)
        d.set(f.fim.timeIntervalSince1970, forKey: chaveFim)
        d.set(f.diaInteiro, forKey: chaveDiaInteiro)
        d.set(f.aviso?.timeIntervalSince1970 ?? 0, forKey: chaveAviso)
        recarregar()
    }

    /// O que está guardado, se ainda não acabou. Compromisso que terminou não
    /// é "o próximo" — deixar o de ontem na tela bloqueada é mentira barata.
    nonisolated static func lido(agora: Date = .now) -> Fatia? {
        let d = defaults
        let titulo = d.string(forKey: chaveTitulo)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let inicio = d.double(forKey: chaveInicio)
        guard !titulo.isEmpty, inicio > 0 else { return nil }
        let fimBruto = d.double(forKey: chaveFim)
        let comeco = Date(timeIntervalSince1970: inicio)
        let fim = fimBruto > 0 ? Date(timeIntervalSince1970: fimBruto) : comeco.addingTimeInterval(3600)
        guard fim > agora else { return nil }
        let aviso = d.double(forKey: chaveAviso)
        let lembrete = d.double(forKey: chaveLembrete)
        return Fatia(
            id: (d.string(forKey: chaveId)).flatMap(UUID.init(uuidString:)) ?? UUID(),
            titulo: titulo, inicio: comeco, fim: fim,
            diaInteiro: d.bool(forKey: chaveDiaInteiro),
            aviso: aviso > 0 ? Date(timeIntervalSince1970: aviso) : nil,
            lembrarEm: lembrete > agora.timeIntervalSince1970
                ? Date(timeIntervalSince1970: lembrete) : nil)
    }

    /// A linha de uma face só (`accessoryInline`): hora e título, nada mais.
    nonisolated static func naTelaBloqueada(agora: Date = .now) -> String {
        guard let f = lido(agora: agora) else { return "Traço" }
        return f.diaInteiro ? f.titulo : "\(horaCurta(f.inicio)) · \(f.titulo)"
    }

    nonisolated static func horaCurta(_ data: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "HH:mm"
        return f.string(from: data)
    }

    /// "hoje", "amanhã" ou o dia da semana — o autor pensa assim, não em datas.
    nonisolated static func diaEmPalavras(_ data: Date, agora: Date = .now) -> String {
        let cal = Calendar(identifier: .gregorian)
        if cal.isDate(data, inSameDayAs: agora) { return "hoje" }
        let amanha = cal.date(byAdding: .day, value: 1, to: agora) ?? agora
        if cal.isDate(data, inSameDayAs: amanha) { return "amanhã" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE, d 'de' MMM"
        return f.string(from: data)
    }

    nonisolated private static func recarregar() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "TracoProximo")
        #endif
    }

    // MARK: - A Ilha (só quando é hoje e está perto)

    /// Longe demais na Ilha vira ruído permanente; perto é justamente quando
    /// olhar o relógio resolve. Seis horas é a janela de "o resto do meu dia".
    nonisolated static let janelaViva: TimeInterval = 6 * 3600

    nonisolated static func atualizarAtividade(_ f: Fatia?, agora: Date = .now) async {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard let f, f.inicio.timeIntervalSince(agora) <= janelaViva, f.fim > agora else {
            await encerrarAtividades()
            return
        }
        let estado = CompromissoAtividade.ContentState(
            titulo: f.titulo, inicio: f.inicio, fim: f.fim, diaInteiro: f.diaInteiro,
            lembrarEm: f.lembrarEm, recado: nil)
        let conteudo = ActivityContent(state: estado, staleDate: f.fim)
        let chave = String(Int(f.inicio.timeIntervalSince1970))
        if let viva = Activity<CompromissoAtividade>.activities.first(where: { $0.attributes.chave == chave }) {
            await viva.update(conteudo)
            for outra in Activity<CompromissoAtividade>.activities where outra.id != viva.id {
                await outra.end(nil, dismissalPolicy: .immediate)
            }
            return
        }
        await encerrarAtividades()
        _ = try? Activity.request(attributes: CompromissoAtividade(chave: chave), content: conteudo)
        #endif
    }

    nonisolated static func encerrarAtividades() async {
        #if canImport(ActivityKit)
        for a in Activity<CompromissoAtividade>.activities {
            await a.end(nil, dismissalPolicy: .immediate)
        }
        #endif
    }
}

/// A Live Activity do compromisso: título e a conta que corre até a hora.
/// O sistema desenha o tempo (`Text(style:)`), então ela anda sozinha sem o
/// app acordar — que é o único jeito honesto de uma contagem na Ilha.
nonisolated struct CompromissoAtividade: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var titulo: String
        var inicio: Date
        var fim: Date
        var diaInteiro: Bool
        /// ADR 04f: a soneca pedida na tela bloqueada. `nil` = ninguém pediu.
        var lembrarEm: Date?
        /// O que impediu o toque de virar alarme. Botão que não faz nada e não
        /// diz nada é o defeito da ADR 04a de novo, agora do tamanho de um dedo.
        var recado: String?
    }

    /// O compromisso a que esta atividade pertence. Trocar de compromisso
    /// encerra a anterior: uma por vez, como a do Destaque.
    var chave: String
}
