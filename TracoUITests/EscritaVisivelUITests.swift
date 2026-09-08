import XCTest

/// O condutor da prova de tela da V12-E (ADR 08f): toques e teclado REAIS pelo
/// XCTest, no aparelho escolhido, sem o helper compartilhado. Quem fotografa e
/// filma é o shell de fora, por `xcrun simctl io <UDID>`, sincronizado com este
/// teste por arquivos-sinal em `/tmp/v12e/`: o teste escreve `<fase>.pronto`
/// quando a tela está no estado, e espera `<fase>.segue` para continuar.
/// Roteiro: página nova → texto maior que o papel (a forma veste sozinha) →
/// três letras no fim → três letras no MEIO → "Abrir os campos".
///
/// V12-F: cartão e "Abrir os campos" são PRÉ-CONDIÇÕES que falham, nunca
/// estados aceitáveis. O re-G3 da V12-E apanhou este teste a passar verde sem
/// cartão — verde que não visitou o lugar do defeito. Se o cartão não vier, ou
/// o botão não existir, ou a folha não abrir, o teste fica vermelho e avisa o
/// condutor de fora por `falhou.pronto` (com o motivo dentro), para ele não
/// esperar 180 s por um `gravar` que nunca chega.
@MainActor final class EscritaVisivelUITests: XCTestCase {
    private let pasta = "/tmp/v12e"

    private func sinal(_ fase: String) {
        FileManager.default.createFile(atPath: "\(pasta)/\(fase).pronto", contents: nil)
        let prazo = Date().addingTimeInterval(120)
        while !FileManager.default.fileExists(atPath: "\(pasta)/\(fase).segue"), Date() < prazo {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
    }

    /// Pré-condição: ou o elemento está na tela, ou o teste é VERMELHO com o
    /// motivo, e o condutor fica sabendo no mesmo instante.
    private func exigir(_ elemento: XCUIElement, _ porque: String, prazo: TimeInterval = 5) -> Bool {
        if elemento.waitForExistence(timeout: prazo) { return true }
        FileManager.default.createFile(atPath: "\(pasta)/falhou.pronto", contents: Data(porque.utf8))
        XCTFail("PRÉ-CONDIÇÃO: \(porque)")
        return false
    }

    private func rodar(tamanho: String?, texto: String, comCartao: Bool) {
        try? FileManager.default.createDirectory(atPath: pasta, withIntermediateDirectories: true)
        let app = XCUIApplication()
        if let tamanho { app.launchArguments += ["-UIPreferredContentSizeCategoryName", tamanho] }
        // o estado do aparelho não decide a prova: em 08/09 um `autoAnalise =
        // false` esquecido no contêiner deixou duas corridas sem cartão. Tem de
        // ser `<false/>`/`<true/>`: no domínio de argumentos "1" e "YES" são
        // STRING, e o `object(forKey:) as? Bool` da `Sessao` os ignora (provado
        // com `UserDefaults` num binário de linha de comando, V12-F).
        app.launchArguments += ["-autoAnalise", "<true/>"]
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
        let cartao = app.descendants(matching: .any)["cartao-recolhido"].firstMatch
        guard comCartao else {
            // o caso "encaixe vazio" prova o contrário: o texto sem forma NÃO veste
            XCTAssertFalse(cartao.exists, "o texto sem forma vestiu um cartão")
            sinal("sem-cartao")
            return
        }
        guard exigir(cartao, "o cartão da forma não está na tela — o caminho do A1 começa nele") else { return }
        if tamanho != nil {
            // em AX as saídas vivem no menu da própria linha do cartão
            cartao.tap()
            sleep(1)
        }
        let abrir = app.buttons.matching(NSPredicate(format: "identifier == 'abrir-campos' OR label == 'Abrir os campos'")).firstMatch
        guard exigir(abrir, "o botão \"Abrir os campos\" não está na tela — sem o toque não há A1") else { return }
        sinal("gravar")
        abrir.tap()
        sleep(3)
        let folha = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'forma-'")).firstMatch
        guard exigir(folha, "a folha dos campos não abriu depois do toque", prazo: 2) else { return }
        sinal("aberto")
    }

    static let woop = String(repeating: "quero correr de manha mas tenho preguica de levantar. Se de manha eu ficar na cama depois do alarme, entao eu ponho os pes no chao e visto o tenis antes de pensar. ", count: 3)
    static let semForma = String(repeating: "hoje o dia foi longo e a chuva nao parou; fiquei em casa lendo e escrevendo sem pressa nenhuma. ", count: 4)

    func testLargeComCartao() { rodar(tamanho: nil, texto: Self.woop, comCartao: true) }
    func testAX5ComCartao() { rodar(tamanho: "UICTContentSizeCategoryAccessibilityXXXL", texto: Self.woop, comCartao: true) }
    func testLargeEncaixeVazio() { rodar(tamanho: nil, texto: Self.semForma, comCartao: false) }
    func testAX5EncaixeVazio() { rodar(tamanho: "UICTContentSizeCategoryAccessibilityXXXL", texto: Self.semForma, comCartao: false) }
}
