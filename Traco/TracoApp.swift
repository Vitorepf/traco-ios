import SwiftData
import UserNotifications
import SwiftUI

@main
struct TracoApp: App {
    private let container: ModelContainer

    init() {
        // O plano de migração é obrigatório: sem ele, uma mudança de schema
        // apaga as notas do autor em silêncio.
        let emTeste = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        container = try! DiscoTraco.abrir(emTeste: emTeste)
        DiscoTraco.compartilhado = container
        UNUserNotificationCenter.current().delegate = Revisoes.Delegate.compartilhado
        // ADR 04e: as férias expiram sozinhas — o autor não tem de lembrar de
        // desligar. O arranque é onde a volta acontece, e é por isso que ele
        // vem ANTES de agendar: reagendar com o modo velho seria calar de novo.
        Ferias.expirarSePassou()
        Revisoes.agendarFilaDiaria()
        Revisoes.agendarRevisaoSemanal()
    }

    var body: some Scene {
        WindowGroup {
            RaizView()
        }
        .modelContainer(container)
    }
}