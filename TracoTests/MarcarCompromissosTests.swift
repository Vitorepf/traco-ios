import Foundation
import Testing
@testable import Traco

/// O campo das Notas recebe qualquer coisa: só o que tem dia E hora vira
/// compromisso; pergunta sem marca devolve zero e segue à sábia (volta 48).
@MainActor struct MarcarCompromissosTests {
    @Test func perguntaSemMarcaNaoMarca() {
        let s = Sessao()
        #expect(s.marcarCompromissos(em: "o que me trava para dormir cedo") == 0)
        #expect(s.marcarCompromissos(em: "sexta") == 0)
    }

    @Test func fraseComVariosDatadosLeTodos() {
        let agora = Date.now
        let cal = Calendario.gregoriano()
        let lidos = "dentista amanhã 14h e correr terça 6h"
            .replacingOccurrences(of: "\\s+e\\s+", with: "\n", options: .regularExpression)
            .split(separator: "\n")
            .compactMap { CalendarioFrase.lerDatado(String($0), agora: agora, cal) }
        #expect(lidos.count == 2)
    }
}
