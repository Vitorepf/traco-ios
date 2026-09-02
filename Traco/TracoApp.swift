import SwiftData
import UserNotifications
import SwiftUI

@main
struct TracoApp: App {
    private let container: ModelContainer

    init() {
        // O plano de migração é obrigatório: sem ele, uma mudança de schema
        // apaga as notas do autor em silêncio.
        do {
            container = try ModelContainer.traco()
        } catch {
            // O banco de disco não abriu (schema, disco cheio, arquivo
            // corrompido). Abrir em memória mantém o app de pé para o autor
            // VER o aviso — o arquivo em disco fica intacto, e o backup não
            // é reescrito (Corpus olha esta bandeira).
            Arranque.bancoEmMemoria = true
            container = try! ModelContainer.traco(emMemoria: true)
        }
        UNUserNotificationCenter.current().delegate = Revisoes.Delegate.compartilhado
    }

    var body: some Scene {
        WindowGroup {
            RaizView()
        }
        .modelContainer(container)
    }
}