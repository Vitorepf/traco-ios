import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif
#if canImport(ActivityKit)
import ActivityKit
#endif

/// A linha do Destaque de hoje — a única coisa que a tela bloqueada mostra.
/// Nunca expressiva, nunca trancada: só a frase que o autor escreveu.
/// Some no mesmo instante em que a nota deixa de ser o Destaque.
enum DestaqueDoDia: Sendable {
    nonisolated static let suite = "group.app.traco"
    nonisolated static let chaveLinha = "destaqueLinha"
    nonisolated static let chaveDia = "destaqueDia"
    nonisolated static let chaveId = "destaqueId"

    nonisolated static func gravar(_ linha: String, id: UUID, em data: Date = .now) {
        let corte = linha.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !corte.isEmpty else {
            apagar(id: id)
            return
        }
        let d = UserDefaults(suiteName: suite) ?? .standard
        d.set(corte, forKey: chaveLinha)
        d.set(diaISO(data), forKey: chaveDia)
        d.set(id.uuidString, forKey: chaveId)
        recarregar()
        Task { await atividade(linha: corte, dia: diaISO(data)) }
    }

    /// Só a dona da linha pode apagá-la. Outra nota não silencia o Destaque alheio.
    nonisolated static func apagar(id: UUID) {
        let d = UserDefaults(suiteName: suite) ?? .standard
        guard d.string(forKey: chaveId) == id.uuidString else { return }
        d.removeObject(forKey: chaveLinha)
        d.removeObject(forKey: chaveDia)
        d.removeObject(forKey: chaveId)
        recarregar()
        Task { await encerrarAtividades() }
    }

    // MARK: Live Activity (a Ilha e a tela bloqueada, enquanto o dia dura)

    /// Uma atividade por dia: atualiza a que existe, senão pede uma nova.
    /// Termina sozinha à meia-noite (`staleDate`) e quando a linha some.
    // nonisolated: Activity não é Sendable; sem fronteira de ator não há envio
    nonisolated static func atividade(linha: String, dia: String) async {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let estado = DestaqueAtividade.ContentState(linha: linha)
        let meiaNoite = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        let conteudo = ActivityContent(state: estado, staleDate: meiaNoite)
        if let existente = Activity<DestaqueAtividade>.activities.first(where: { $0.attributes.dia == dia }) {
            await existente.update(conteudo)
            for outra in Activity<DestaqueAtividade>.activities where outra.id != existente.id {
                await outra.end(nil, dismissalPolicy: .immediate)
            }
            return
        }
        await encerrarAtividades()
        _ = try? Activity.request(attributes: DestaqueAtividade(dia: dia), content: conteudo)
        #endif
    }

    nonisolated static func encerrarAtividades() async {
        #if canImport(ActivityKit)
        for a in Activity<DestaqueAtividade>.activities {
            await a.end(nil, dismissalPolicy: .immediate)
        }
        #endif
    }

    nonisolated static func linhaDeHoje(agora: Date = .now) -> String? {
        let d = UserDefaults(suiteName: suite) ?? .standard
        guard d.string(forKey: chaveDia) == diaISO(agora) else { return nil }
        let linha = d.string(forKey: chaveLinha)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return linha.isEmpty ? nil : linha
    }

    /// Sem Destaque o ecrã diz o nome do app — nunca um travessão a fingir linha.
    nonisolated static func naTelaBloqueada(agora: Date = .now) -> String {
        linhaDeHoje(agora: agora) ?? "Traço"
    }

    nonisolated private static func recarregar() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "TracoWidget")
        #endif
    }

    nonisolated static func diaISO(_ data: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: data)
    }
}
