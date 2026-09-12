import Foundation
import Testing
@testable import Traco

/// A Página: documento inventado cai; obra fantasma cai sem chamar o modelo.
@MainActor
struct SustentacaoPaginaTests {
    @Test func pdfInventadoCaiEDocumentoNaNotaPassa() {
        let nota = "Reservei R$ 6.000. O prazo é 12/09."
        #expect(SustentacaoPagina.inventouDocumento(
            "Abra o PDF e vá ao sumário para achar o prazo.", material: nota))
        #expect(SustentacaoPagina.filtrar(
            "Abra o PDF e vá ao sumário.", pergunta: "qual o prazo?", contexto: nota)
            == SustentacaoPagina.recusaDocumento)
        #expect(!SustentacaoPagina.inventouDocumento(
            "O prazo que você anotou é 12/09.", material: nota))
        let comPdf = nota + " O PDF do banco está em Arquivos."
        #expect(!SustentacaoPagina.inventouDocumento(
            "O PDF do banco que você citou tem a cotação.", material: comPdf))
    }

    @Test func obraFantasmaNaPaginaNaoChamaOModelo() async {
        var chamou = false
        let r = await Sabia.responder(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            contexto: "Reservei R$ 6.000 para a viagem.",
            gesto: nil,
            gerar: { _ in
                chamou = true
                return "Abra o PDF. Voss defende um decreto."
            })
        #expect(!chamou, "a guarda da Página tem de calar o modelo")
        #expect(r?.contains(GuardaDeObra.fraseNaoEstaNoCaderno) == true)
        #expect(r?.contains("plantar") == true)
        #expect(r?.contains("decreto") != true)
        #expect(r?.contains("PDF") != true)
    }

    @Test func obraNaPaginaDeixaOModeloResponderEDocumentoInventadoCai() async {
        var chamou = false
        let r = await Sabia.responder(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            contexto: "Tratado das Nuvens Invertidas de Mélanie Voss: a tese é esperar.",
            gesto: nil,
            gerar: { _ in
                chamou = true
                return "Abra o PDF e vá ao sumário."
            })
        #expect(chamou)
        #expect(r == SustentacaoPagina.recusaDocumento)
    }
}
