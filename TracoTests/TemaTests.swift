import SwiftUI
import Testing
@testable import Traco

/// ADR 2026-09-05t: com "Reduzir movimento", toda animação custom vira o
/// mesmo fade curto — uma lei, num lugar só. A gaveta do Caderno e o morph
/// do Calendário têm nome próprio, mas devolvem o MESMO fade.
struct TemaTests {
    @Test func movimentoReduzidoViraFadeCurto() {
        let mola = Animation.spring(response: 0.55, dampingFraction: 0.82)
        #expect(Tema.animacao(mola, reduzido: true) == Tema.fadeReduzido)
        #expect(Tema.animacao(mola, reduzido: false) == mola)
    }

    @Test func gavetaECalendarioSeguemAMesmaLei() {
        #expect(Tema.gaveta(reduzido: true) == Tema.fadeReduzido)
        #expect(Tema.gaveta(reduzido: false) != Tema.fadeReduzido)
        #expect(CalendarioTema.morph(true) == Tema.fadeReduzido)
        #expect(CalendarioTema.morph(false) != Tema.fadeReduzido)
    }

    /// G4 da volta 8: o que se arrasta com o dedo corta seco em reduzido —
    /// nil, nenhum fade, nenhum quadro em que o painel some sob o dedo.
    @Test func oQueSeArrastaCortaSecoEmReduzido() {
        let mola = Animation.spring(response: 0.55, dampingFraction: 0.82)
        #expect(Tema.corte(mola, reduzido: true) == nil)
        #expect(Tema.corte(mola, reduzido: false) == mola)
    }
}
