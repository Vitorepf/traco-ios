import XCTest

/// ADR 2026-09-09w: a resposta que transborda o teto do cartão NÃO corta calada.
///
/// Em 10/09 o cartão da sábia terminou a resposta em `"(A nota"` — parêntese
/// aberto, frase pela metade — e nada na tela dizia que havia mais
/// (`ferramentas/orca/q3c-01-cartao-com-a-sobra.png`). O `ScrollView` sempre
/// rolou; o que faltava era o AVISO de que valia a pena rolar.
///
/// A resposta longa não se produz aqui: sob XCTest o portão dos motores fica
/// fechado e o aparelho com conta é o da conta, onde a suíte não corre. Por
/// isso o `-ensaio-resposta-longa-nas-notas` semeia uma resposta MEDIDA de
/// verdade (568 grafemas, `prova/lote09b-q3-grok-4.6.jsonl`) — o mesmo
/// instrumento que a `PraticaTrabalho.ensaioDaOferta` já usa, e pela mesma
/// razão.
///
/// O par de asserções é o que dá valor ao teste: o sinal APARECE quando há
/// sobra e SOME quando a pessoa chega ao fim. Um sinal que nunca some não
/// provou que enxerga — provou que está pintado na tela.
@MainActor final class SinalDeSobraUITests: XCTestCase {
    private func abrirNotasComRespostaLonga(_ tamanho: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        if let tamanho { app.launchArguments += ["-UIPreferredContentSizeCategoryName", tamanho] }
        app.launchArguments += ["-autoAnalise", "<true/>", "-ensaio-resposta-longa-nas-notas"]
        app.launchEnvironment["TRACO_SEM_MODELO"] = "1"
        app.launch()
        // O ensaio abre JÁ nas Notas: a prova é do cartão, e chegar a ele pela
        // Página amarrava o teste a uma tela que não é a dele — em AX5 a topbar
        // da Página fica em y=-371 pt e não volta com rolagem (medido em duas
        // corridas seguidas, 10/09), e o teste ficava vermelho por um defeito
        // de outra área.
        XCTAssertTrue(app.otherElements["cartao-sabia-notas"].firstMatch.waitForExistence(timeout: 15),
                      "PRÉ-CONDIÇÃO: o cartão da sábia não veio semeado — o ensaio não pegou")
        return app
    }

    /// Rola DENTRO do cartão, não na lista atrás dele: o arrasto sai de um
    /// ponto do próprio cartão, na faixa onde vive o texto da resposta.
    private func rolarNoCartao(_ app: XCUIApplication) {
        let cartao = app.otherElements["cartao-sabia-notas"].firstMatch
        cartao.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.30))
            .press(forDuration: 0.05,
                   thenDragTo: cartao.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02)))
    }

    private func exigirSinal(_ app: XCUIApplication, _ porque: String) {
        XCTAssertTrue(app.staticTexts["sobra-resposta-notas"].firstMatch.waitForExistence(timeout: 5), porque)
    }

    /// `medium`: a resposta medida transborda os 220 pt e o sinal está lá.
    func testRespostaLongaAvisaQueContinua() {
        let app = abrirNotasComRespostaLonga()
        XCTAssertTrue(app.staticTexts["resposta-sabia-notas"].firstMatch.exists,
                      "PRÉ-CONDIÇÃO: a resposta não está no cartão")
        exigirSinal(app, "a resposta transborda o teto e NADA diz que continua — é o corte calado de 10/09 de volta")
    }

    /// AX5: o corte que some em `medium` volta em letra grande, e é aí que ele
    /// mais engana. Nenhum teto conserta isto; só o sinal.
    ///
    /// A pré-condição aqui é o CARTÃO, não o `Text` da resposta: em AX5 os 568
    /// grafemas medem **3.120,7 pt** dentro de uma janela de 220 (a árvore de AX
    /// da corrida de 10/09 diz "Barra de rolagem vertical, 15 páginas"), o texto
    /// fica inteiro fora da janela e o XCUITest não o entrega. O que se afirma é
    /// o que importa e o que ele entrega: o sinal existe.
    /// A prova de que isso aparece NA TELA em AX5 é a captura do aparelho da
    /// conta, não este teste — aqui garante-se a invariante, ali o que se vê.
    func testRespostaLongaAvisaQueContinuaEmAX5() {
        let app = abrirNotasComRespostaLonga("UICTContentSizeCategoryAccessibilityXXXL")
        exigirSinal(app, "em AX5 a resposta transborda e NADA diz que continua")
    }

    /// E o sinal é vivo: chegou ao fim, ele sai. Sem esta metade o teste
    /// passaria com um degradê pintado para sempre no pé do cartão.
    func testOSinalSaiQuandoAPessoaChegaAoFim() {
        let app = abrirNotasComRespostaLonga()
        exigirSinal(app, "PRÉ-CONDIÇÃO: o sinal não apareceu, então não há o que ver sair")

        let sinal = app.staticTexts["sobra-resposta-notas"].firstMatch
        for _ in 0..<8 where sinal.exists { rolarNoCartao(app) }

        XCTAssertFalse(sinal.exists,
                       "a resposta chegou ao fim e o sinal continua dizendo que há mais — sinal que mente uma vez não é mais lido")
    }
}
