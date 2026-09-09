import XCTest

/// ADR 2026-09-09c: a pergunta é da SESSÃO, não da view.
///
/// `RaizView` recria a `NotasView` ao trocar de aba (o `switch` de
/// `sessao.abaArquivo`), e com o `@State` morria a conversa inteira: a pergunta
/// que a pessoa estava esperando sumia sem que nada dissesse. Este teste toca
/// a tela de verdade e exige o contrário — o que a pessoa deixou nas Notas
/// continua lá quando ela volta.
///
/// Sob XCTest o portão dos motores fica fechado (`Motores.desligados`), então a
/// sábia responde pelo cartão "sem conta". Isso não enfraquece a prova: o
/// cartão é o MESMO estado da `ConversaNotas` que a recriação apagava.
@MainActor final class PerguntaSobreviveUITests: XCTestCase {
    private func abrirNotas(_ app: XCUIApplication) {
        app.launchArguments += ["-autoAnalise", "<true/>"]
        app.launch()
        let paraNotas = app.buttons["notas-da-pagina"].firstMatch
        XCTAssertTrue(paraNotas.waitForExistence(timeout: 30), "a Página não apareceu")
        paraNotas.tap()
        XCTAssertTrue(app.textFields["busca-notas"].firstMatch.waitForExistence(timeout: 10),
                      "as Notas não abriram")
    }

    /// Ida e volta pela barra: Notas → Calendário → Notas é o caminho que
    /// recria a view. O teclado sobe sobre a barra: sem fechá-lo, o toque cai
    /// numa TECLA e a aba nunca troca — foi assim que a primeira corrida deste
    /// teste passou verde sem visitar o lugar do defeito.
    private func trocarDeAbaEVoltar(_ app: XCUIApplication) {
        // a lista fecha o teclado por arrasto (`.scrollDismissesKeyboard(.interactively)`).
        // Sem isso o toque na barra cai numa TECLA e a aba nunca troca — foi
        // assim que a primeira corrida deste teste passou verde sem visitar o
        // lugar do defeito.
        for _ in 0..<3 where !app.staticTexts["calendario-titulo"].firstMatch.exists {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.30))
                .press(forDuration: 0.1,
                       thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62)))
            app.buttons["aba-calendario"].firstMatch.tap()
        }
        XCTAssertTrue(app.staticTexts["calendario-titulo"].firstMatch.waitForExistence(timeout: 5),
                      "PRÉ-CONDIÇÃO: o Calendário não abriu — a aba não trocou")
        app.buttons["aba-notas"].firstMatch.tap()
        XCTAssertTrue(app.textFields["busca-notas"].firstMatch.waitForExistence(timeout: 5),
                      "as Notas não voltaram")
    }

    func testBuscaEmEdicaoSobreviveATrocaDeAba() {
        let app = XCUIApplication()
        abrirNotas(app)

        let busca = app.textFields["busca-notas"].firstMatch
        busca.tap()
        busca.typeText("o que eu aprendi ontem")
        XCTAssertEqual(busca.value as? String, "o que eu aprendi ontem", "a busca não recebeu o texto")

        trocarDeAbaEVoltar(app)

        XCTAssertEqual(app.textFields["busca-notas"].firstMatch.value as? String,
                       "o que eu aprendi ontem",
                       "o que a pessoa estava escrevendo sumiu ao trocar de aba")
    }

    func testCartaoDaPerguntaSobreviveATrocaDeAba() {
        let app = XCUIApplication()
        abrirNotas(app)

        let busca = app.textFields["busca-notas"].firstMatch
        busca.tap()
        busca.typeText("o que eu aprendi ontem")
        app.buttons["perguntar-notas"].firstMatch.tap()

        let cartao = app.otherElements["cartao-sabia-notas"].firstMatch
        XCTAssertTrue(cartao.waitForExistence(timeout: 10),
                      "PRÉ-CONDIÇÃO: o cartão da sábia não apareceu depois de perguntar")

        trocarDeAbaEVoltar(app)

        XCTAssertTrue(app.otherElements["cartao-sabia-notas"].firstMatch.waitForExistence(timeout: 5),
                      "o cartão da sábia sumiu ao trocar de aba — a pessoa perdeu o que esperava sem que nada dissesse")
    }
}
