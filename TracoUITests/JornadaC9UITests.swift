import XCTest

/// C9: oferta e jornada Markdown ponta a ponta, tocadas de verdade.
/// Sem Grok: a pessoa escreve a versão e o ajuste. Não é Q8 no aparelho
/// do dono — é o protótipo da jornada no simulador coordenado.
@MainActor final class JornadaC9UITests: XCTestCase {
    private func abrirTrabalhos(_ app: XCUIApplication) {
        app.launchEnvironment["TRACO_SEM_MODELO"] = "1"
        app.launchArguments += ["-autoAnalise", "<true/>"]
        app.launch()
        let pagina = app.textViews["pagina"].firstMatch
        XCTAssertTrue(pagina.waitForExistence(timeout: 20), "a Página não abriu")
        app.buttons["notas-da-pagina"].firstMatch.tap()
        XCTAssertTrue(app.buttons["abrir-trabalhos"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["abrir-trabalhos"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["trabalho-nova-intencao"].firstMatch.waitForExistence(timeout: 10),
                      "a folha dos Trabalhos não abriu")
    }

    private func soltarTeclado(_ app: XCUIApplication) {
        for _ in 0..<4 where app.keyboards.firstMatch.exists {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.22))
                .press(forDuration: 0.05,
                       thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.70)))
        }
    }

    private func elemento(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        let porId = app.descendants(matching: .any)[id].firstMatch
        if porId.exists { return porId }
        let campo = app.textFields[id].firstMatch
        if campo.exists { return campo }
        return app.textViews[id].firstMatch
    }

    private func irAte(_ app: XCUIApplication, _ id: String, prazo: TimeInterval = 16) -> XCUIElement {
        let limite = Date().addingTimeInterval(prazo)
        while Date() < limite {
            let el = elemento(app, id)
            if el.exists && el.isHittable { return el }
            if !el.exists {
                RunLoop.current.run(until: Date().addingTimeInterval(0.25))
                continue
            }
            // y grande = abaixo da dobra: sobe o documento. Alternar
            // cima/baixo nunca chegava no campo da dificuldade (~2600 pt).
            if el.frame.minY > 620 { app.swipeUp() }
            else if el.frame.minY < 120 { app.swipeDown() }
            else { app.swipeUp() }
        }
        let el = elemento(app, id)
        XCTAssertTrue(el.waitForExistence(timeout: 2), "não achei \(id)")
        XCTAssertTrue(el.isHittable, "\(id) existe mas não chegou à tela (y=\(el.frame.minY))")
        return el
    }

    private func irAoTopo(_ app: XCUIApplication) {
        for _ in 0..<6 { app.swipeDown() }
    }

    private func campoDentro(_ caixa: XCUIElement) -> XCUIElement {
        if caixa.elementType == .textField || caixa.elementType == .textView { return caixa }
        if caixa.textViews.firstMatch.exists { return caixa.textViews.firstMatch }
        if caixa.textFields.firstMatch.exists { return caixa.textFields.firstMatch }
        return caixa
    }

    private func escrever(_ app: XCUIApplication, em id: String, _ texto: String) {
        let direto = elemento(app, id)
        let imediato = campoDentro(direto)
        if direto.exists && (imediato.isHittable || direto.isHittable) {
            if imediato.isHittable { imediato.tap() } else { direto.tap() }
            imediato.typeText(texto)
            return
        }
        let caixa = irAte(app, id)
        let campo = campoDentro(caixa)
        if campo.isHittable { campo.tap() }
        XCTAssertTrue(campo.waitForExistence(timeout: 3), "o campo \(id) não está na árvore")
        campo.typeText(texto)
    }

    /// A primeira versão já está na estação; a de edição abre na gaveta.
    /// Devolve o identificador em que dá para escrever.
    @discardableResult
    private func esperarCampoDaVersao(_ app: XCUIApplication) -> String {
        let candidatos = ["versao", "trabalho-campo-versao", "trabalho-editar-versao"]
        let limite = Date().addingTimeInterval(6)
        while Date() < limite {
            for id in candidatos where elemento(app, id).exists { return id }
            if app.textFields["Sua versão"].firstMatch.exists { return "Sua versão" }
            if app.textViews["Sua versão"].firstMatch.exists { return "Sua versão" }
            if app.textFields["Editar a versão"].firstMatch.exists { return "Editar a versão" }
            if app.textViews["Editar a versão"].firstMatch.exists { return "Editar a versão" }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        XCTAssertTrue(candidatos.contains(where: { elemento(app, $0).exists })
                        || app.textFields["Sua versão"].firstMatch.exists
                        || app.textViews["Sua versão"].firstMatch.exists
                        || app.textFields["Editar a versão"].firstMatch.exists
                        || app.textViews["Editar a versão"].firstMatch.exists,
                      "o campo da versão não está na estação")
        return "versao"
    }

    private func tocar(_ app: XCUIApplication, _ id: String) {
        irAte(app, id).tap()
    }

    func testAJornadaMarkdownFechaSemIANemWizard() {
        let app = XCUIApplication()
        abrirTrabalhos(app)

        escrever(app, em: "trabalho-nova-intencao", "Uma pagina de oferta para a clinica")
        tocar(app, "trabalho-criar")
        XCTAssertTrue(app.descendants(matching: .any)["trabalho-oferta-texto"].firstMatch.waitForExistence(timeout: 10)
                        || app.descendants(matching: .any)["trabalho-ir-ao-proximo-passo"].firstMatch.waitForExistence(timeout: 10),
                      "a oferta da jornada não veio ao abrir o trabalho")

        soltarTeclado(app)
        irAoTopo(app)
        let oferta = app.descendants(matching: .any)["trabalho-oferta-texto"].firstMatch
        XCTAssertTrue(oferta.waitForExistence(timeout: 5), "a oferta não está na retomada")
        XCTAssertTrue(oferta.label.contains("artefato"), "estação inicial não é o artefato: \(oferta.label)")
        XCTAssertFalse(oferta.label.contains("inteligência"))

        tocar(app, "trabalho-ir-ao-proximo-passo")
        escrever(app, em: esperarCampoDaVersao(app), "Consulta de 50 minutos.")
        soltarTeclado(app)
        tocar(app, "trabalho-guardar-versao")

        irAoTopo(app)
        XCTAssertTrue(oferta.waitForExistence(timeout: 5))
        XCTAssertTrue(oferta.label.contains("ação"),
                      "depois da versão a oferta não pede o ato: \(oferta.label)")
        tocar(app, "trabalho-ir-ao-proximo-passo")

        escrever(app, em: "acao", "Mostrar a pagina a Ana")
        soltarTeclado(app)
        tocar(app, "trabalho-preparar-acao")

        irAoTopo(app)
        XCTAssertTrue(oferta.label.contains("registrar"),
                      "depois do ato a oferta não pede o relato")
        tocar(app, "trabalho-ir-ao-proximo-passo")

        escrever(app, em: "trabalho-relato", "ela pediu o preco por escrito")
        soltarTeclado(app)
        tocar(app, "trabalho-resultado-parcial")
        tocar(app, "trabalho-registrar-relato")

        irAoTopo(app)
        XCTAssertTrue(app.descendants(matching: .any)["trabalho-colheita-juizos"].firstMatch.waitForExistence(timeout: 5),
                      "C5: a colheita não apareceu na retomada")
        XCTAssertTrue(oferta.label.contains("ajustar"),
                      "depois do relato a oferta não pede o ajuste")

        tocar(app, "trabalho-ir-ao-proximo-passo")
        escrever(app, em: esperarCampoDaVersao(app), " Preco 180.")
        soltarTeclado(app)
        tocar(app, "trabalho-guardar-nova-versao")

        irAoTopo(app)
        XCTAssertTrue(oferta.waitForExistence(timeout: 5))
        XCTAssertTrue(oferta.label.contains("não invento um gargalo"),
                      "jornada fechada sem o aviso honesto: \(oferta.label)")
        XCTAssertFalse(app.descendants(matching: .any)["trabalho-ir-ao-proximo-passo"].firstMatch.exists,
                       "jornada fechada ainda oferece ir ao próximo passo")

        escrever(app, em: "dificuldade", "ela trava no preco")
        soltarTeclado(app)
        tocar(app, "pratica-guardar-dificuldade")

        irAoTopo(app)
        let no = app.descendants(matching: .any)["trabalho-dificuldade-texto"].firstMatch
        XCTAssertTrue(no.waitForExistence(timeout: 5), "o nó plantado não subiu à retomada")
        XCTAssertTrue(no.label.contains("trava no preco"))
        XCTAssertFalse(oferta.exists, "nó plantado e oferta da jornada não podem aparecer juntos")
    }
}
