import SwiftData
import UserNotifications
import SwiftUI

@main
struct TracoApp: App {
    private let container: ModelContainer

    init() {
        // O plano de migração é obrigatório: sem ele, uma mudança de schema
        // apaga as notas do autor em silêncio.
        container = (try? ModelContainer.traco()) ?? (try! ModelContainer.traco(emMemoria: true))
        UNUserNotificationCenter.current().delegate = Revisoes.Delegate.compartilhado
    }

    var body: some Scene {
        WindowGroup {
            RaizView()
        }
        .modelContainer(container)
    }
}