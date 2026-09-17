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

/// Os Padrões mostravam "Na NOTA 3 você escreveu… da NOTA 6?": o endereço do
/// pedido chegava ao autor. O pedido leva o título; a guarda recusa o número.
struct PadroesSemEnderecoTests {
    @Test func oPedidoLevaOTituloEOSistemaPedeCitarPorEle() {
        let pedido = PadroesRemoto.montarPedido(vozes: ["Subir para R$ 90", "Treinar de manhã"],
                                                titulos: ["Subir o preço do plano anual", ""])
        #expect(pedido.contains("NOTA 1 — «Subir o preço do plano anual»:\nSubir para R$ 90"))
        #expect(pedido.contains("NOTA 2:\nTreinar de manhã"), "sem título, só o endereço")
        #expect(PadroesRemoto.sistema.contains("nunca o número"))
        #expect(!PadroesRemoto.sistema.contains("ele mesmo") && !PadroesRemoto.sistema.contains("por ele"))
    }

    @Test func aPerguntaQueTrazONumeroDaNotaCaiEAMesmaSemEleFica() {
        let vozes = ["Subir para R$ 90 no plano anual", "Adiar o aumento para janeiro"]
        let comNumero = #"{"perguntas":["Na NOTA 1 você escreveu “Subir para R$ 90”; o que mudou na NOTA 2?"]}"#
        let comTitulo = #"{"perguntas":["Em «Subir o preço do plano anual» você escreveu “Subir para R$ 90”; o que mudou depois?"]}"#
        #expect(PadroesRemoto.parsePerguntas(comNumero, vozes: vozes) == [])
        #expect(PadroesRemoto.parsePerguntas(comTitulo, vozes: vozes)?.count == 1)
        #expect(PadroesRemoto.citaEndereco("o que diz a nota 12?") && !PadroesRemoto.citaEndereco("o que dizem as notas?"))
    }
}
