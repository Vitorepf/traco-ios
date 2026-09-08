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
        // ADR 05u: a suíte roda dentro deste processo; a superfície do App
        // Group real (widget, orçamento, atividades) não é dela
        if emTeste { SuperficieDisco.isolarParaTestes() }
        UNUserNotificationCenter.current().delegate = Revisoes.Delegate.compartilhado
        // ADR 04e: as férias expiram sozinhas — o autor não tem de lembrar de
        // desligar. O arranque é onde a volta acontece, e é por isso que ele
        // vem ANTES de agendar: reagendar com o modo velho seria calar de novo.
        Ferias.expirarSePassou()
        Revisoes.agendarFilaDiaria()
        Revisoes.agendarRevisaoSemanal()
        // ADR 05u: atividade órfã (o app morreu entre o commit e o ActivityKit,
        // ou o dia virou) é reconciliada com o estado guardado no arranque
        FilaDeAtividade.compartilhada.enfileirar {
            await DestaqueDoDia.reconciliar()
            await ProximoCompromisso.reconciliar()
        }
    }

    var body: some Scene {
        WindowGroup {
            RaizView()
                #if DEBUG
                .task { await AvaliacaoIA.executarSeSolicitado() }
                #endif
        }
        .modelContainer(container)
    }
}
