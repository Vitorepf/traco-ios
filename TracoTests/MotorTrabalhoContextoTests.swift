import Foundation
import Testing
@testable import Traco

@MainActor
struct MotorTrabalhoContextoTests {
    @Test func pedidoSemHistoricoTerminaNaInstrucaoSemSecoesVazias() throws {
        var documento = DocumentoTrabalho(intencao: "Preparar uma explicação")
        let pedido = try documento.iniciarPedido("Entregue um exemplo concreto e duas perguntas.")
        let texto = MotorTrabalho.pedido(documento, pedido, teto: 3500)
        #expect(texto.hasSuffix(pedido.instrucao))
        #expect(texto.contains(documento.intencaoAtual.texto))
        for ausente in ["RESULTADO DESEJADO:", "CORREÇÕES DA PESSOA", "RETORNO ATRIBUÍDO",
                        "VERSÃO ANTERIOR", "HIPÓTESES NÃO CONFIRMADAS", "<material_de_referencia>"] {
            #expect(!texto.contains(ausente))
        }
        #expect(!texto.contains("CONTEXTO PARCIAL"))
    }

    @Test func instrucaoVigenteFicaDepoisDoMaterialConflitanteEDoFechamento() throws {
        var documento = DocumentoTrabalho(intencao: "Explicar uma proposta")
        let antigo = "Use uma tabela longa e exija recursos adicionais."
        try documento.guardarVersaoHumana(antigo)
        let pedido = try documento.iniciarPedido("Reescreva em um parágrafo, usando apenas os recursos disponíveis.")
        let texto = MotorTrabalho.pedido(documento, pedido, teto: 3500)
        let inicio = try #require(texto.range(of: "<material_de_referencia>"))
        let base = try #require(texto.range(of: antigo))
        let fecho = try #require(texto.range(of: "</material_de_referencia>"))
        let vigente = try #require(texto.range(of: pedido.instrucao))
        #expect(inicio.upperBound <= base.lowerBound && base.upperBound <= fecho.lowerBound)
        #expect(fecho.upperBound < vigente.lowerBound && texto.hasSuffix(pedido.instrucao))
        #expect(texto.contains("suas restrições prevalecem"))
    }

    @Test func contextoCortadoMantemFechamentoCorrecaoEInstrucaoInteiros() throws {
        for teto in [1200, 3500, 18000] {
            var documento = DocumentoTrabalho(intencao: "Comparar opções", resultado: "Uma decisão informada")
            try documento.guardarVersaoHumana(String(repeating: "Material antigo 👩🏽‍💻 com detalhes. ", count: 1500))
            let hipotese = DocumentoTrabalho.Hipotese(texto: "Foi falta de capacidade",
                contexto: "A informação estava indisponível", evidencias: [])
            documento.hipoteses.append(hipotese)
            try documento.avaliarHipotese(hipotese.id, estado: .contestada)
            let pedido = try documento.iniciarPedido("Compare as opções sem atribuir a dificuldade a uma limitação pessoal.")
            let texto = MotorTrabalho.pedido(documento, pedido, teto: teto)
            #expect(texto.count <= teto)
            #expect(texto.contains("CONTEXTO PARCIAL"))
            #expect(texto.contains(hipotese.texto) && texto.contains(hipotese.contexto))
            #expect(texto.contains("contestada") && texto.contains("Você"))
            let fecho = try #require(texto.range(of: "</material_de_referencia>"))
            let vigente = try #require(texto.range(of: pedido.instrucao))
            #expect(fecho.upperBound < vigente.lowerBound && texto.hasSuffix(pedido.instrucao))
        }
    }

    @Test func nucleoQueNaoCabeNaoETruncadoParaSimularPedidoValido() throws {
        var documento = DocumentoTrabalho(intencao: "Finalidade essencial")
        let hipotese = DocumentoTrabalho.Hipotese(texto: "Correção essencial",
            contexto: String(repeating: "contexto obrigatório ", count: 300), evidencias: [])
        documento.hipoteses.append(hipotese)
        try documento.avaliarHipotese(hipotese.id, estado: .contestada)
        let pedido = try documento.iniciarPedido("Produza o material solicitado.")
        let texto = MotorTrabalho.pedido(documento, pedido, teto: 3500)
        #expect(texto.count > 3500)
        #expect(texto.contains(hipotese.contexto) && texto.hasSuffix(pedido.instrucao))
    }

    @Test func reproduzirLiteralmenteContinuaSendoPedidoPossivel() throws {
        var documento = DocumentoTrabalho(intencao: "Preparar uma cópia para leitura")
        let base = "Trecho que deve permanecer exatamente assim."
        try documento.guardarVersaoHumana(base)
        let pedido = try documento.iniciarPedido("Reproduza literalmente a versão anterior, sem alterações.")
        let texto = MotorTrabalho.pedido(documento, pedido, teto: 3500)
        #expect(texto.contains(base) && texto.hasSuffix(pedido.instrucao))
        // O contrato organiza entrada; não impõe ao domínio uma mudança falsa
        // quando a própria pessoa pediu cópia. Qualidade exige execução real.
        try documento.receber(base, produtor: "Fixture", pedidoID: pedido.id)
        #expect(documento.versaoAtual?.conteudo == base)
    }
}
