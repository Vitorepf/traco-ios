import AppIntents
import UserNotifications
#if canImport(ActivityKit)
import ActivityKit
#endif

/// ADR 2026-09-04f — a tela bloqueada deixa de ser cartaz.
///
/// O compromisso já aparece lá (ADR 04a). Mas ver não é agir: quando o aviso
/// toca e o autor não pode atender AGORA, a única saída era abrir o app — e
/// abrir o app é justamente o que ninguém faz na fila do banco.
///
/// Um botão, um significado: **cobra de novo daqui a dez minutos.** Vale antes
/// do compromisso ("me lembra de sair") e depois do aviso ("agora não dá") —
/// é a mesma frase do "hoje não" do Recordar (ADR 03e): adiar não é falhar
/// nem acertar, é a hora errada.
///
/// Namespace próprio (`soneca-<id>`): a soneca nunca alcança o aviso do
/// compromisso, e cancelar um não mata o outro.
struct LembrarDepoisIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Lembrar em 10 min"
    static let description = IntentDescription("Cobra este compromisso de novo daqui a dez minutos.")
    static let openAppWhenRun = false

    nonisolated static let minutos = 10

    func perform() async throws -> some IntentResult {
        guard let f = ProximoCompromisso.lido() else { return .result() }
        let quando = Date().addingTimeInterval(TimeInterval(Self.minutos * 60))

        let centro = UNUserNotificationCenter.current()
        let permissao = await centro.notificationSettings().authorizationStatus
        guard permissao == .authorized || permissao == .provisional else {
            // sem permissão o toque não vira alarme — e tem de DIZER isso.
            // Botão mudo é a ADR 04a repetida do tamanho de um dedo.
            await contar("avisos desligados no iPhone", de: f)
            return .result()
        }

        let conteudo = UNMutableNotificationContent()
        conteudo.title = f.titulo
        conteudo.body = ""
        conteudo.sound = .default
        conteudo.interruptionLevel = .timeSensitive
        conteudo.userInfo = ["compromisso": f.id.uuidString]
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: quando)
        let id = "soneca-\(f.id.uuidString)"
        centro.removePendingNotificationRequests(withIdentifiers: [id])
        try? await centro.add(UNNotificationRequest(
            identifier: id, content: conteudo,
            trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)))

        // o toque tem de VIRAR alguma coisa na tela: sem isto o botão seria
        // mudo, que é o defeito que a ADR 04a existe para não repetir
        ProximoCompromisso.gravar(f.comLembrete(quando))
        await contar(nil, de: f, lembrarEm: quando)
        return .result()
    }

    /// O retorno na tela: ou a hora em que vai cobrar, ou a razão de não ir.
    private func contar(_ recado: String?, de f: ProximoCompromisso.Fatia,
                        lembrarEm: Date? = nil) async {
        #if canImport(ActivityKit)
        for a in Activity<CompromissoAtividade>.activities {
            var estado = a.content.state
            estado.lembrarEm = lembrarEm
            estado.recado = recado
            await a.update(ActivityContent(state: estado, staleDate: f.fim))
        }
        #endif
    }
}
