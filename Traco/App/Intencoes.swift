import AppIntents
import SwiftUI

/// O app fora do app (exp 3): Atalhos, Siri e Action Button chegam de graça
/// com App Intents no alvo principal — sem extensão, sem app group.
struct NovaNotaIntent: AppIntent {
    static let title: LocalizedStringResource = "Nova nota"
    static let description = IntentDescription("Abre o Traço numa página em branco, pronta para escrever.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Rota.pendente = .novaPagina
        NotificationCenter.default.post(name: Rota.mudou, object: nil)
        return .result()
    }
}

struct AbrirNotasIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir notas"
    static let description = IntentDescription("Abre a lista de notas do Traço.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Rota.pendente = .notas
        NotificationCenter.default.post(name: Rota.mudou, object: nil)
        return .result()
    }
}

struct TracoAtalhos: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NovaNotaIntent(),
            phrases: ["Nova nota no \(.applicationName)", "Escrever no \(.applicationName)"],
            shortTitle: "Nova nota",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: AbrirNotasIntent(),
            phrases: ["Minhas notas no \(.applicationName)"],
            shortTitle: "Notas",
            systemImageName: "list.bullet"
        )
    }
}

/// Rota de entrada única: intents, traco:// e o Share convergem aqui; a PaginaView consome.
@MainActor
enum Rota {
    enum Destino: Equatable { case novaPagina, notas, recordar, criar(texto: String) }
    static var pendente: Destino?
    static let mudou = Notification.Name("traco.rotaMudou")

    static func daURL(_ url: URL) -> Destino? {
        guard url.scheme == "traco" else { return nil }
        switch url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) {
        case "nova", "": return .novaPagina
        case "notas": return .notas
        case "recordar": return .recordar
        case "criar":
            // U1 Share: o texto compartilhado viaja na query; sem texto, o
            // pouso não cai no vazio — vira página em branco.
            let texto = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "texto" })?.value ?? ""
            return texto.isEmpty ? .novaPagina : .criar(texto: texto)
        default: return nil
        }
    }
}
