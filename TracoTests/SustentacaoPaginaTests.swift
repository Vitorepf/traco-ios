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

    /// E8: a frase que supõe o documento sai; o resto da resposta fica. Só o que é
    /// todo documento inventado vira recusa. E o "pdf" que o material traz passa.
    @Test func aGuardaTiraAFraseENaoCalaARespostaInteira() {
        let nota = "Relatório de setembro: 1. Contexto; 2. Metodologia; 3. Resultados por praça. Tenho 30 minutos."
        let resposta = "Leia primeiro 3. Resultados por praça, que traz as filas de cada uma.\nAbra o PDF e vá ao sumário.\nDepois anote as três decisões em uma linha cada, dentro dos 30 minutos."
        let r = SustentacaoPagina.filtrar(resposta, pergunta: "como organizo a leitura?", contexto: nota)
        #expect(r == "Leia primeiro 3. Resultados por praça, que traz as filas de cada uma.\nDepois anote as três decisões em uma linha cada, dentro dos 30 minutos.")
        let misturada = "Comece pelas filas da praça Leste. Abra o PDF na página 3. Anote as três decisões antes dos 30 minutos acabarem."
        #expect(SustentacaoPagina.filtrar(misturada, pergunta: "como organizo?", contexto: nota)
                == "Comece pelas filas da praça Leste. Anote as três decisões antes dos 30 minutos acabarem.")
        let comPdf = nota + " Está no PDF que o banco mandou."
        #expect(SustentacaoPagina.filtrar("O PDF que o banco mandou traz a cotação; comece pela seção 3.", pergunta: "e agora?", contexto: comPdf)
                == "O PDF que o banco mandou traz a cotação; comece pela seção 3.", "o PDF que o material cita não é inventado")
    }

    /// E8: o pedido proíbe supor o que quem escreve anota ou usa, manda fechar a conta
    /// de data, dizer tudo o que falta, remeter a profissional em saúde, e não presume gênero.
    @Test func oPedidoDaPaginaNaoSupoeEFechaAConta() {
        let p = Sabia.sistemaResponder
        #expect(p.contains("Não suponha o que ela anota, usa ou tem") && p.contains("\"até 23/09\""))
        #expect(p.contains("inclusive a quantidade") && p.contains("profissional de saúde"))
        #expect(p.contains(Sabia.semGenero))
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
