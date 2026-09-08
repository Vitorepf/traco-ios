import XCTest

/// O condutor da prova de tela da V12-E (ADR 08f): toques e teclado REAIS pelo
/// XCTest, no aparelho escolhido, sem o helper compartilhado. Quem fotografa e
/// filma é o shell de fora, por `xcrun simctl io <UDID>`, sincronizado com este
/// teste por arquivos-sinal em `/tmp/v12e/`: o teste escreve `<fase>.pronto`
/// quando a tela está no estado, e espera `<fase>.segue` para continuar.
/// Roteiro: página nova → texto maior que o papel (a forma veste sozinha) →
/// três letras no fim → três letras no MEIO → "Abrir os campos".
final class EscritaVisivelUITests: XCTestCase {
    private let pasta = "/tmp/v12e"

    private func sinal(_ fase: String) {
        FileManager.default.createFile(atPath: "\(pasta)/\(fase).pronto", contents: nil)
        let prazo = Date().addingTimeInterval(120)
        while !FileManager.default.fileExists(atPath: "\(pasta)/\(fase).segue"), Date() < prazo {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
    }

    private func rodar(tamanho: String?, texto: String) {
        try? FileManager.default.createDirectory(atPath: pasta, withIntermediateDirectories: true)
        let app = XCUIApplication()
        if let tamanho { app.launchArguments += ["-UIPreferredContentSizeCategoryName", tamanho] }
        app.launchEnvironment["TRACO_SEM_MODELO"] = "1"
        app.launch()
        let pagina = app.textViews["pagina"].firstMatch
        XCTAssertTrue(pagina.waitForExistence(timeout: 15), "a Página não apareceu")
        pagina.tap()
        sleep(1)
        pagina.typeText(texto)
        sleep(4) // a pausa chama a análise; a forma veste sozinha (ou não, se o texto não tem forma)
        sinal("digitado")
        pagina.typeText("abc")
        sleep(1)
        sinal("fim")
        // no MEIO: um toque no alto do papel e três letras
        pagina.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12)).tap()
        sleep(1)
        pagina.typeText("xyz")
        sleep(1)
        sinal("meio")
        let abrir = app.buttons["abrir-campos"].firstMatch
        if abrir.waitForExistence(timeout: 3) {
            sinal("gravar")
            abrir.tap()
            sleep(3)
            sinal("aberto")
        } else {
            sinal("sem-cartao")
        }
    }

    static let woop = String(repeating: "quero correr de manha mas tenho preguica de levantar. Se de manha eu ficar na cama depois do alarme, entao eu ponho os pes no chao e visto o tenis antes de pensar. ", count: 3)
    static let semForma = String(repeating: "hoje o dia foi longo e a chuva nao parou; fiquei em casa lendo e escrevendo sem pressa nenhuma. ", count: 4)

    func testLargeComCartao() { rodar(tamanho: nil, texto: Self.woop) }
    func testAX5ComCartao() { rodar(tamanho: "UICTContentSizeCategoryAccessibilityXXXL", texto: Self.woop) }
    func testLargeEncaixeVazio() { rodar(tamanho: nil, texto: Self.semForma) }
    func testAX5EncaixeVazio() { rodar(tamanho: "UICTContentSizeCategoryAccessibilityXXXL", texto: Self.semForma) }
}
