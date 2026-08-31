import SwiftData
import SwiftUI

@main
struct TracoApp: App {
    private let container: ModelContainer

    init() {
        // O plano de migração é obrigatório: sem ele, uma mudança de schema
        // apaga as notas do autor em silêncio.
        container = (try? ModelContainer.traco()) ?? (try! ModelContainer.traco(emMemoria: true))
    }

    var body: some Scene {
        WindowGroup {
            PaginaView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}