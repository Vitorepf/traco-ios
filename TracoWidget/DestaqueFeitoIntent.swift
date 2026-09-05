import AppIntents
import WidgetKit

/// F2: o widget deixa de ser cartaz e vira botão.
///
/// A única coisa de hoje é a única coisa que cabe num widget: marcá-la como
/// feita, sem abrir o app. `openAppWhenRun = false` é o ponto — o gesto
/// acontece na tela inicial e pronto.
///
/// Não vira streak, não conta, não compara com ontem (§12). A marca vale só
/// para o dia de hoje e some com ele.
/// ADR 04f: passou a `LiveActivityIntent` para valer também DENTRO da Live
/// Activity — o botão da tela bloqueada precisa rodar no processo do app.
/// No widget da casa nada muda: `LiveActivityIntent` é um `AppIntent`.
struct DestaqueFeitoIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Feito"
    static let description = IntentDescription("Marca a única coisa de hoje como feita.")
    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        if DestaqueDoDia.feitoHoje() {
            DestaqueDoDia.desmarcarFeito()
        } else {
            DestaqueDoDia.marcarFeito()
        }
        return .result()
    }
}
