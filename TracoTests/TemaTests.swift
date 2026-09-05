import SwiftUI
import Testing
@testable import Traco

/// ADR 2026-09-05t: com "Reduzir movimento", toda animação custom vira o
/// mesmo fade curto — uma lei, num lugar só.
struct TemaTests {
    @Test func movimentoReduzidoViraFadeCurto() {
        let mola = Animation.spring(response: 0.55, dampingFraction: 0.82)
        #expect(Tema.animacao(mola, reduzido: true) == Tema.fadeReduzido)
        #expect(Tema.animacao(mola, reduzido: false) == mola)
        #expect(Tema.gaveta(reduzido: true) != Tema.gaveta(reduzido: false))
        #expect(Tema.cartao(reduzido: true, aEntrar: true) == Tema.cartao(reduzido: true, aEntrar: false))
    }
}
