import XCTest

/// **DIRETRIZ §13 item 3 — *"espera calada é defeito de IA, não de design"*;
/// §14 viu nas Notas um "a sábia pensa…" parado com um "Fechar" e mais nada.**
///
/// Este teste toca a tela de verdade e exige as três coisas: **pensando**,
/// **tempo** que ANDA e **parar de esperar** — e que parar devolva a
/// pergunta em vez de a perder. Tamanho `large`, o do dono (DIRETRIZ §12).
///
/// A espera vem semeada (`-ensaio-espera-nas-notas`), não de chamada real:
/// sob XCTest o portão dos motores fica fechado e o aparelho com conta é o
/// da conta, onde a suíte não corre.
@MainActor final class EsperaComEstadoUITests: XCTestCase {
    func testAEsperaNasNotasMostraPensandoTempoEParar() {
        let app = XCUIApplication()
        app.launchArguments += ["-autoAnalise", "<true/>", "-ensaio-espera-nas-notas"]
        app.launchEnvironment["TRACO_SEM_MODELO"] = "1"
        app.launch()

        XCTAssertTrue(app.otherElements["cartao-sabia-notas"].firstMatch.waitForExistence(timeout: 15),
                      "PRÉ-CONDIÇÃO: o cartão não veio semeado — o ensaio não pegou")

        // o título é a PERGUNTA da pessoa, em letra de gente
        let titulo = app.staticTexts["pergunta-sabia-notas"].firstMatch
        XCTAssertTrue(titulo.exists, "a pergunta não é o título do cartão")
        XCTAssertEqual(titulo.label, "Quanto ainda me falta no pretérito?")

        // 1. PENSANDO
        let espera = app.staticTexts["sabia-notas-pensando"].firstMatch
        XCTAssertTrue(espera.waitForExistence(timeout: 5),
                      "a espera não apareceu — o autor ficaria sem saber que algo começou")

        // 2. TEMPO: do quarto segundo em diante o número aparece E ANDA
        let comRelogio = NSPredicate(format: "label CONTAINS 'há'")
        XCTAssertEqual(XCTWaiter().wait(for: [expectation(for: comRelogio, evaluatedWith: espera)], timeout: 15),
                       .completed, "a espera não ganhou relógio: '\(espera.label)'")
        let primeiro = espera.label
        let andou = NSPredicate(format: "label != %@", primeiro)
        XCTAssertEqual(XCTWaiter().wait(for: [expectation(for: andou, evaluatedWith: espera)], timeout: 10),
                       .completed, "o relógio parou em '\(primeiro)' — laço mudo com outra roupa")

        // 3. PARAR: existe, é alcançável e tem alvo de 44 pt; e há UM fechar
        let parar = app.buttons["parar-de-esperar"].firstMatch
        XCTAssertTrue(parar.exists, "esperar 241 s sem saída é a pessoa presa ao cartão")
        XCTAssertTrue(parar.isHittable, "a saída existe na árvore mas não é alcançável")
        XCTAssertGreaterThanOrEqual(parar.frame.height, 44, "alvo abaixo de 44 pt (\(parar.frame.height))")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label == 'Fechar'")).count, 1,
                       "mais de um Fechar na tela")

        // e parar NÃO PERDE a pergunta
        parar.tap()
        XCTAssertTrue(app.staticTexts["pergunta-pendente-notas"].firstMatch.waitForExistence(timeout: 5),
                      "parar de esperar perdeu a pergunta do autor")
        XCTAssertTrue(app.buttons["repetir-pergunta-notas"].firstMatch.exists,
                      "perguntar de novo tem de ser um toque")
        XCTAssertFalse(app.staticTexts["sabia-notas-pensando"].firstMatch.exists,
                       "parou de esperar e a espera continuou na tela")
    }

    /// A resposta semeada: título = pergunta, fontes fechadas numa linha que
    /// abre em títulos tocáveis, retorno como controle, um só fechar.
    func testARespostaTemPerguntaFontesRetornoEUmFechar() {
        let app = XCUIApplication()
        app.launchArguments += ["-autoAnalise", "<true/>", "-ensaio-resposta-longa-nas-notas"]
        app.launchEnvironment["TRACO_SEM_MODELO"] = "1"
        app.launch()
        XCTAssertTrue(app.otherElements["cartao-sabia-notas"].firstMatch.waitForExistence(timeout: 15),
                      "PRÉ-CONDIÇÃO: o cartão não veio semeado")
        XCTAssertEqual(app.staticTexts["pergunta-sabia-notas"].firstMatch.label,
                       "Quanto vou gastar em reais com hospedagem e transporte na viagem?")
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'A SÁBIA'")).firstMatch.exists)

        let fontes = app.buttons["fontes-sabia-notas"].firstMatch
        XCTAssertTrue(fontes.exists, "a linha das fontes não existe")
        XCTAssertEqual(fontes.label, "leu 4 notas suas")
        XCTAssertFalse(app.buttons["fonte-sabia-notas"].firstMatch.exists, "as fontes abriram sem a pessoa pedir")
        fontes.tap()
        XCTAssertTrue(app.buttons["fonte-sabia-notas"].firstMatch.waitForExistence(timeout: 3), "as fontes não abriram")
        XCTAssertEqual(app.buttons.matching(identifier: "fonte-sabia-notas").count, 4, "uma fonte por nota, uma vez cada")

        XCTAssertTrue(app.buttons["serviu"].firstMatch.exists && app.buttons["nao-serviu"].firstMatch.exists)
        app.buttons["serviu"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["retorno-anotado"].firstMatch.waitForExistence(timeout: 3), "o retorno não confirmou")
        XCTAssertFalse(app.buttons["serviu"].firstMatch.exists, "o controle ficou depois de avaliado")

        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label == 'Fechar'")).count, 1, "mais de um Fechar")
        app.buttons["fechar-resposta"].firstMatch.tap()
        XCTAssertFalse(app.otherElements["cartao-sabia-notas"].firstMatch.waitForExistence(timeout: 2), "fechar não fechou")
    }
}
