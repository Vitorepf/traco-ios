import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct IntercambioTrabalhoTests {
    private func exemplo(_ texto: String = "Versão original") throws -> DocumentoTrabalho {
        var documento = DocumentoTrabalho(intencao: "Preparar uma conversa")
        try documento.guardarVersaoHumana(texto)
        try documento.prepararAcao("Experimentar a abertura")
        try documento.registrarRelato("Ainda não comecei", acaoID: documento.acoes[0].id)
        return documento
    }

    /// Simula a edição externa do corpo, mantendo o envelope entregue.
    private func editar(_ arquivo: Data, corpo: String) throws -> Data {
        let quebra = try #require(arquivo.firstIndex(of: 0x0A))
        return Data(arquivo[...quebra]) + Data(corpo.utf8)
    }

    @Test func corpoEditadoExternamenteVoltaIntegralComAutoriaEVinculosHonestos() throws {
        var documento = try exemplo()
        let antes = documento
        let corpo = "\n  # Plano 👩🏽‍💻\r\n\r\n```html\r\n<script>não executar()</script>\r\n```\n<!-- comentário comum -->\n\t"
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: corpo)
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAtual && preview.texto == corpo)
        #expect(try documento.aplicarVersaoExterna(preview))
        let nova = try #require(documento.versaoAtual)
        #expect(nova.conteudo == corpo && nova.formato == .markdown)
        #expect(nova.conteudo.utf8.elementsEqual(corpo.utf8))
        #expect(nova.origem == .externa && nova.produtor == "Arquivo importado · autoria não verificada")
        #expect(nova.anteriorID == antes.versaoAtual?.id && nova.intencaoID == antes.intencaoAtual.id)
        #expect(documento.artefatos.dropLast() == antes.artefatos[...])
        #expect(documento.acoes == antes.acoes && documento.evidencias == antes.evidencias)
        let reexportada = try IntercambioTrabalho.preparar(IntercambioTrabalho.exportar(documento), para: documento)
        #expect(reexportada.baseID == nova.id && reexportada.estado == .baseAtual)
    }

    @Test func retornoDaBaseAntigaFormaRamoSemSubstituirVersaoIntermediaria() throws {
        var documento = try exemplo()
        let a = try #require(documento.versaoAtual)
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: "Retorno externo de A")
        try documento.guardarVersaoHumana("Versão B local")
        let antes = documento
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAntiga)
        #expect(throws: IntercambioTrabalho.Erro.self) { try documento.aplicarVersaoExterna(preview) }
        #expect(documento == antes)
        #expect(try documento.aplicarVersaoExterna(preview, confirmarBaseAntiga: true))
        #expect(documento.versaoAtual?.anteriorID == a.id)
        #expect(documento.artefatos.dropLast() == antes.artefatos[...])
        #expect(documento.acoes == antes.acoes)
    }

    @Test func intencaoRevistaExigeConfirmacaoEPreservaIntencaoDaBase() throws {
        var documento = try exemplo()
        let original = documento.intencaoAtual.id
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: "Preparado para intenção antiga")
        try documento.reverIntencao("Agora quero outra conversa", resultado: "Outro resultado")
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAntiga && preview.intencaoDaBaseID == original)
        #expect(try documento.aplicarVersaoExterna(preview, confirmarBaseAntiga: true))
        #expect(documento.versaoAtual?.intencaoID == original)
        #expect(documento.intencaoAtual.id != original)
    }

    @Test func mudancaDepoisDaPreviaExigeNovaConfirmacaoMasRelatoPodeSerConservado() throws {
        for mudarIntencao in [true, false] {
            var documento = try exemplo()
            let preview = try IntercambioTrabalho.preparar(Data("Texto externo".utf8), para: documento)
            if mudarIntencao { try documento.reverIntencao("Outra intenção", resultado: "") }
            else { try documento.guardarVersaoHumana("Outra versão") }
            let antes = documento
            #expect(throws: IntercambioTrabalho.Erro.self) { try documento.aplicarVersaoExterna(preview) }
            #expect(documento == antes)
        }
        var documento = try exemplo()
        let preview = try IntercambioTrabalho.preparar(Data("Texto externo".utf8), para: documento)
        try documento.registrarRelato("Chegou enquanto eu conferia", acaoID: documento.acoes[0].id)
        let evidencias = documento.evidencias
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.evidencias == evidencias)
    }

    @Test func semEnvelopeNaoInventaAncestralNemRemoveBOMOuComentario() throws {
        var documento = try exemplo()
        let texto = "\u{FEFF}<!-- comentário comum -->\r\n\n  material externo  \n"
        let preview = try IntercambioTrabalho.preparar(Data(texto.utf8), para: documento)
        #expect(preview.estado == .semVinculo && preview.texto == texto)
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.versaoAtual?.anteriorID == nil)
        #expect(documento.versaoAtual?.intencaoID == documento.intencaoAtual.id)
        try documento.guardarVersaoHumana("Minha edição posterior")
        #expect(documento.versaoAtual?.origem == .mista)
        #expect(documento.versaoAtual?.produtor == "Você, a partir de versão anterior")
        #expect(documento.artefatos[documento.artefatos.count - 2].origem == .externa)
    }

    @Test func BOMAntesDoEnvelopeECRLFPreservamCorpoExato() throws {
        let documento = try exemplo()
        let exportado = try IntercambioTrabalho.exportar(documento)
        let quebra = try #require(exportado.firstIndex(of: 0x0A))
        let corpo = "\r\ntexto editado\r\n\n"
        let arquivo = Data([0xEF, 0xBB, 0xBF]) + Data(exportado[..<quebra]) + Data("\r\n".utf8) + Data(corpo.utf8)
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAtual && preview.texto == corpo)
    }

    @Test func envelopeAdulteradoNuncaCaiEmSemVinculo() throws {
        let documento = try exemplo()
        let exportado = try IntercambioTrabalho.exportar(documento)
        let quebra = try #require(exportado.firstIndex(of: 0x0A))
        let linha = String(decoding: exportado[..<quebra], as: UTF8.self)
        let payload = String(linha.dropFirst("<!-- traco-trabalho:v1 ".count).dropLast(" -->".count))
        let json = try #require(Data(base64Encoded: payload))
        let original = try #require(JSONSerialization.jsonObject(with: json) as? [String: Any])
        for chave in ["trabalhoID", "artefatoID", "intencaoID", "hashBase", "protocolo"] {
            var valores = original
            if chave == "protocolo" { valores[chave] = 99 }
            else if chave == "hashBase" { valores[chave] = "hash adulterado" }
            else { valores[chave] = UUID().uuidString }
            let adulterado = try JSONSerialization.data(withJSONObject: valores).base64EncodedString()
            let arquivo = Data("<!-- traco-trabalho:v1 \(adulterado) -->\ncorpo".utf8)
            var destino = documento
            let preview = try IntercambioTrabalho.preparar(arquivo, para: destino)
            #expect(preview.estado == .incompativel)
            #expect(throws: IntercambioTrabalho.Erro.self) { try destino.aplicarVersaoExterna(preview) }
            #expect(destino == documento)
        }
        for texto in ["<!-- traco-trabalho:v9 e30= -->\ncorpo", "<!-- traco-trabalho:v1 @@@ -->\ncorpo", "<!-- traco-trabalho:v1 sem fecho"] {
            #expect(try IntercambioTrabalho.preparar(Data(texto.utf8), para: documento).estado == .incompativel)
        }
    }

    @Test func repeticaoNaoFabricaHistoricoENaoCancelaPedidoQuandoNadaMudou() throws {
        var documento = try exemplo()
        let semEdicao = try IntercambioTrabalho.preparar(IntercambioTrabalho.exportar(documento), para: documento)
        _ = try documento.iniciarPedido("Preparação em curso")
        let antes = documento
        #expect(try !documento.aplicarVersaoExterna(semEdicao))
        #expect(documento == antes)
        let dados = Data("Versão externa nova".utf8)
        let preview = try IntercambioTrabalho.preparar(dados, para: documento)
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.pedidoAtivo == nil)
        let depois = documento
        #expect(throws: IntercambioTrabalho.Erro.self) { try documento.aplicarVersaoExterna(preview) }
        let repetida = try IntercambioTrabalho.preparar(dados, para: documento)
        #expect(try !documento.aplicarVersaoExterna(repetida))
        #expect(documento == depois)
    }

    @Test func encodingInvalidoETamanhoExcessivoSaoRecusadosSemTruncamento() throws {
        let documento = try exemplo()
        #expect(throws: IntercambioTrabalho.Erro.self) {
            try IntercambioTrabalho.preparar(Data([0xC3, 0x28]), para: documento)
        }
        let noLimite = Data(repeating: 0x61, count: IntercambioTrabalho.limiteBytes)
        #expect(try IntercambioTrabalho.preparar(noLimite, para: documento).texto.utf8.count == noLimite.count)
        #expect(throws: IntercambioTrabalho.Erro.self) {
            try IntercambioTrabalho.preparar(noLimite + Data([0x61]), para: documento)
        }
        var enorme = documento
        try enorme.guardarVersaoHumana(String(decoding: noLimite, as: UTF8.self))
        #expect(throws: IntercambioTrabalho.Erro.self) { try IntercambioTrabalho.exportar(enorme) }
    }

    @Test func fidelidadeDeBytesNaoConfundeUnicodeEquivalenteComReplay() throws {
        var documento = try exemplo("caf\u{E9}")
        let decomposto = "cafe\u{301}"
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: decomposto)
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.versaoAtual?.conteudo.utf8.elementsEqual(decomposto.utf8) == true)
    }

    @Test func commitRecusadoPreservaCandidatoERetryNaoAdicionaOutraVersao() throws {
        enum Falha: Error { case disco }
        let container = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: exemplo())
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let antes = trabalho.conteudoJSON
        let preview = try IntercambioTrabalho.preparar(Data("Nova versão importada".utf8), para: oficina.documento)
        oficina.persistir = { _ in throw Falha.disco }
        #expect(!oficina.alterar { try $0.aplicarVersaoExterna(preview) })
        let idCandidato = oficina.documento.versaoAtual?.id
        #expect(trabalho.conteudoJSON == antes && oficina.documento.artefatos.count == 2)
        oficina.persistir = { try $0.save() }
        #expect(oficina.guardar())
        let volta = try trabalho.ler()
        #expect(volta.artefatos.count == 2 && volta.versaoAtual?.id == idCandidato)
        #expect(volta.versaoAtual?.origem == .externa)
    }
}
