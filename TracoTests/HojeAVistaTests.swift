import Foundation
import Testing
@testable import Traco

/// O "Hoje" do pé só existe quando hoje NÃO está na tela (volta 40).
@MainActor struct HojeAVistaTests {
    private func agenda() -> CalendarioAgenda { CalendarioAgenda(agora: .now, eventos: []) }

    @Test func naSemanaDeHojeNaoPrecisaDeHoje() {
        let a = agenda()
        let agora = Date.now
        a.escala = .semana
        a.ancora = a.cal.date(byAdding: .day, value: 1, to: agora) ?? agora
        let mesmaSemana = Calendario.semana(da: agora, a.cal).contains { Calendario.mesmoDia($0, a.ancora, a.cal) }
        #expect(a.hojeAVista(agora) == mesmaSemana)
        a.ancora = a.cal.date(byAdding: .day, value: 14, to: agora) ?? agora
        #expect(!a.hojeAVista(agora))
    }

    @Test func noDiaSoAAncora() {
        let a = agenda()
        let agora = Date.now
        a.escala = .dia
        a.ancora = agora
        #expect(a.hojeAVista(agora))
        a.ancora = a.cal.date(byAdding: .day, value: 1, to: agora) ?? agora
        #expect(!a.hojeAVista(agora))
    }
}
