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

    /// PRÉ-CONDIÇÃO de toda troca de aba: o teclado fora.
    ///
    /// O teclado da busca sobe SOBRE a barra de abas — no AX do G3 as abas
    /// aparecem em `y: 1.0572`, fora da tela. Tocar ali cai numa TECLA: a
    /// corrida do revisor terminou com "o que eu aprendi ontem**gggd**" na
    /// busca, quatro toques que viraram quatro letras. Por isso este helper
    /// AFIRMA que o teclado saiu em vez de seguir tocando às cegas.
    ///
    /// O gesto é o do próprio app (`.scrollDismissesKeyboard(.interactively)`).
    /// Ele dependia de haver lista para arrastar, e nestes dois testes a busca
    /// filtra até zero — era essa a dependência de estado que fazia o teste
    /// passar para quem tinha notas semeadas e falhar para quem não tinha. A
    /// ADR 09d pôs o vazio a rolar também, então o gesto vale nos dois estados.
    private func soltarOTeclado(_ app: XCUIApplication) {
        for _ in 0..<4 where app.keyboards.firstMatch.exists {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.30))
                .press(forDuration: 0.1,
                       thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62)))
        }
        XCTAssertFalse(app.keyboards.firstMatch.exists,
                       "PRÉ-CONDIÇÃO: o teclado não saiu no arrasto da lista — a barra de abas segue atrás dele e todo toque na barra vira letra")
    }

    /// Ida e volta pela barra: Notas → Calendário → Notas é o caminho que
    /// recria a view.
    private func trocarDeAbaEVoltar(_ app: XCUIApplication) {
        soltarOTeclado(app)
        let calendario = app.buttons["aba-calendario"].firstMatch
        XCTAssertTrue(calendario.waitForExistence(timeout: 5),
                      "PRÉ-CONDIÇÃO: a aba do Calendário não existe na árvore")
        XCTAssertTrue(calendario.isHittable,
                      "PRÉ-CONDIÇÃO: a aba do Calendário existe mas não é alcançável — algo está por cima dela")
        calendario.tap()
        XCTAssertTrue(app.staticTexts["calendario-titulo"].firstMatch.waitForExistence(timeout: 5),
                      "PRÉ-CONDIÇÃO: o Calendário não abriu — a aba não trocou")
        app.buttons["aba-notas"].firstMatch.tap()
        // ADR 10i: com conversa aberta as Notas voltam como FOLHA (sem a linha
        // da busca); sem conversa, como lista (com ela)
        let voltou = NSPredicate { _, _ in
            app.textFields["busca-notas"].firstMatch.exists || app.otherElements["cartao-sabia-notas"].firstMatch.exists
        }
        XCTAssertEqual(XCTWaiter().wait(for: [XCTNSPredicateExpectation(predicate: voltou, object: nil)], timeout: 5), .completed,
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

        // ADR 10i: perguntar é a marca "?" no título; a folha abre com a
        // linha "?" em branco e o teclado de pé
        app.buttons["perguntar-modo"].firstMatch.tap()
        let pergunta = app.textFields["pergunta-notas"].firstMatch
        XCTAssertTrue(pergunta.waitForExistence(timeout: 5), "a linha \"?\" não apareceu")
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5), "a folha abriu sem o teclado de pé")
        pergunta.typeText("o que eu aprendi ontem")
        app.buttons["perguntar-notas"].firstMatch.tap()

        let cartao = app.otherElements["cartao-sabia-notas"].firstMatch
        XCTAssertTrue(cartao.waitForExistence(timeout: 10),
                      "PRÉ-CONDIÇÃO: o cartão da sábia não apareceu depois de perguntar")

        trocarDeAbaEVoltar(app)

        XCTAssertTrue(app.otherElements["cartao-sabia-notas"].firstMatch.waitForExistence(timeout: 5),
                      "o cartão da sábia sumiu ao trocar de aba — a pessoa perdeu o que esperava sem que nada dissesse")
    }
}
