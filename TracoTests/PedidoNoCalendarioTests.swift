import Foundation
import Testing
@testable import Traco

/// O verbo do pedido não vira título (volta 66).
struct PedidoNoCalendarioTests {
    private let cal = Calendario.gregoriano()

    @Test func meLembraDeSaiDoTitulo() throws {
        let e = try #require(CalendarioFrase.ler("me lembra de ligar para a Ana amanhã 15h", ancora: .now, agora: .now, cal))
        #expect(e.titulo == "Ligar para a Ana")
    }

    @Test func marcaSaiDoTitulo() throws {
        let e = try #require(CalendarioFrase.ler("marca dentista sexta 14h", ancora: .now, agora: .now, cal))
        #expect(e.titulo == "Dentista")
    }

    @Test func tituloSemVerboFicaIgual() throws {
        let e = try #require(CalendarioFrase.ler("dentista sexta 14h", ancora: .now, agora: .now, cal))
        #expect(e.titulo == "Dentista")
    }
}
