import SwiftData
import UserNotifications
import SwiftUI

@main
struct TracoApp: App {
    // ADR 2026-09-08n: o arranque deixou de ser `try!`. A recusa do disco é
    // estado, e o estado é `@State` porque "tentar de novo" é o único ato
    // honesto que se pode oferecer — um disco cheio ou um arquivo ainda preso
    // pelo iCloud abre na segunda vez.
    @State private var disco: DiscoTraco.Resultado
    private let emTeste = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    init() {
        // O plano de migração é obrigatório: sem ele, uma mudança de schema
        // apaga as notas do autor em silêncio.
        let emTeste = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let disco = DiscoTraco.abrir(emTeste: emTeste)
        _disco = State(initialValue: disco)
        // ADR 05u: a suíte roda dentro deste processo; a superfície do App
        // Group real (widget, orçamento, atividades) não é dela
        if emTeste { SuperficieDisco.isolarParaTestes() }
        UNUserNotificationCenter.current().delegate = Revisoes.Delegate.compartilhado
        if case .aberto = disco { Self.aoAbrir() }
    }

    /// O que o arranque faz DEPOIS de ter um caderno de verdade. Com o disco
    /// recusado nada disto corre: reagendar avisos e reconciliar a Ilha a
    /// partir de um mundo vazio calaria o que está de pé lá fora.
    private static func aoAbrir() {
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
            switch disco {
            case .aberto(let container):
                RaizView()
                    #if DEBUG
                    .task { await AvaliacaoIA.executarSeSolicitado() }
                    #endif
                    .modelContainer(container)
            case .recusou(let erro):
                ArranqueFalhouView(erro: String(describing: erro)) {
                    let outra = DiscoTraco.abrir(emTeste: emTeste)
                    disco = outra
                    if case .aberto = outra { Self.aoAbrir(); return true }
                    return false
                }
            }
        }
    }
}
