import Testing
@testable import Traco

@MainActor
struct ProsaLiteralTests {
    @Test(arguments: ["2 * 3", "~aproximadamente", "[sem fecho", "`código aberto", "[[nota", "fim **", "👩🏽‍💻 [rascunho"])
    func marcadoresIncompletosPermanecemLiterais(_ fonte: String) {
        #expect(String(ProsaView.textoInline(fonte).characters) == fonte)
    }

    @Test func literalNaoImpedeFormatacaoSeguinte() {
        #expect(String(ProsaView.textoInline("[rascunho e **pronto**").characters) == "[rascunho e pronto")
    }
}
