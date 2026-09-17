import Foundation
import SwiftData
import Testing
@testable import Traco

/// Achados altos da auditoria de experiência do líder (16/09), um por suíte.

/// A resposta das Notas era recolhida sem ninguém mexer: `salvar` mudava a data
/// de uma nota só aberta, e a conversa depende da data de cada fonte.
@MainActor @Suite(.serialized)
struct GravarSemMudancaTests {
    @Test func abrirESairSemEditarNaoMudaADataNemRecolheAResposta() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let antes = Date(timeIntervalSince1970: 1_780_000_000)
        let nota = Nota(texto: "# Proposta do cliente", gesto: .decisao,
                        campos: ["escolha": "Dar desconto", "opcoes": "Dar desconto\nOferecer bônus", "decidido": "Oferecer bônus"],
                        criadaEm: antes, editadaEm: antes)
        ctx.insert(nota)
        try ctx.save()
        let fontes = [try #require(Sessao.fonteParaPergunta(nota))]

        let s = Sessao()
        s.abrir(nota)
        #expect(s.salvar(no: ctx))
        #expect(nota.editadaEm == antes, "abrir e sair sem editar não é edição")
        #expect(Sessao.dependenciasValidas(fontes, no: ctx), "a resposta que leu a nota continua de pé")

        s.texto = "# Proposta do cliente, revista"
        #expect(s.salvar(no: ctx))
        #expect(nota.editadaEm > antes)
        #expect(!Sessao.dependenciasValidas(fontes, no: ctx), "editar de verdade ainda recolhe")
    }
}
