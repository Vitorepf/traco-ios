import XCTest

/// ADR 08y / G3 da R1: a curva-zero medida em **toques e gestos**, e não em
/// telas percorridas. A régua do dono é "quanto a pessoa tem de fazer" — então
/// o condutor é o XCUITest, que executa toque e arrasto de verdade, no aparelho
/// escolhido pelo `-destination`, sem o helper compartilhado do `orca emulator`
/// (que amplifica o arrasto de 6 a 24x e é um só na máquina).
///
/// A tarefa medida é uma só, a mesma nos dois candidatos: **voltar ao trabalho
/// no dia seguinte e saber as sete coisas** que o autor precisa para continuar.
/// O mesmo estado plantado (`ferramentas/orca/semear-retomada.py`), o mesmo
/// gesto (`swipeUp()` do XCUITest) e o mesmo aparelho.
///
/// O teste de medida não julga: ele **conta e registra** em
/// `/tmp/curva-zero/medida.txt`. Quem compara os dois candidatos é o relato.
/// Os outros três fixam os estados do bloco que o G3 apontou sem prova: teto e
/// excedente, primeira visita, reabertura e AX5. Em cada um o teste **para** e
/// espera o condutor de fora fotografar com `xcrun simctl io <UDID> screenshot`
/// — porque ausência na árvore não é prova de ausência na tela, e a captura tem
/// de ser do mesmo instante.
@MainActor final class CurvaZeroRetomadaUITests: XCTestCase {
    private let pasta = "/tmp/curva-zero"

    /// Os sete fatos, cada um com um trecho de rótulo que o encontra **nos dois
    /// candidatos**: no "antes" ele está no bloco original (histórico, cartão do
    /// ato, dificuldade); no "depois" a mesma notícia aparece na retomada. O
    /// predicado é o mesmo, e o teste toma sempre a ocorrência mais alta.
    private static let fatos: [(String, String)] = [
        ("objetivo", "Explicar a proposta em cinco minutos"),
        ("proximo-passo", "Continuar: Ensaiar"),
        ("versao-nova", "Versão 2"),
        ("ato-realizado", "marcou como realizada"),
        ("resultado-informado", "Resultado que você informou"),
        ("quando-foi-o-retorno", "19:30"),
        ("dificuldade", "o problema duas vezes"),
    ]

    /// A faixa legível da folha: dentro da janela e acima da barra de abas, que
    /// cobre os últimos 80 pt. Um rótulo fora dela existe na árvore e não está
    /// na tela de quem lê — e é a tela que conta.
    private func naFaixa(_ y: CGFloat, _ altura: CGFloat, _ janela: CGFloat) -> Bool {
        y >= 0 && y + altura <= janela - 80
    }

    private func despejar(_ app: XCUIApplication, _ nome: String) {
        try? FileManager.default.createDirectory(atPath: pasta, withIntermediateDirectories: true)
        try? app.debugDescription.write(toFile: "\(pasta)/\(nome).txt", atomically: true, encoding: .utf8)
    }

    /// Congela o teste no estado e avisa o condutor de fora, que fotografa com
    /// `simctl` e libera. Sem condutor esperando, segue depois de 20 s: a
    /// medida não pode ficar refém da foto.
    private func pausarParaAFoto(_ fase: String) {
        FileManager.default.createFile(atPath: "\(pasta)/\(fase).pronto", contents: nil)
        let prazo = Date().addingTimeInterval(20)
        while !FileManager.default.fileExists(atPath: "\(pasta)/\(fase).segue"), Date() < prazo {
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
    }

    /// Os três toques da jornada: Notas → Trabalhos → o trabalho. Idênticos nos
    /// dois candidatos; é o que o "antes" e o "depois" têm em comum.
    @discardableResult
    private func abrirAFolha(_ app: XCUIApplication) -> Int {
        XCTAssertTrue(app.textViews["pagina"].firstMatch.waitForExistence(timeout: 20), "a Página não abriu")
        app.buttons["notas-da-pagina"].firstMatch.tap()
        XCTAssertTrue(app.buttons["abrir-trabalhos"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["abrir-trabalhos"].firstMatch.tap()
        let naLista = app.buttons["trabalho-na-lista"].firstMatch
        XCTAssertTrue(naLista.waitForExistence(timeout: 10), "o trabalho semeado não está na lista")
        naLista.tap()
        XCTAssertTrue(app.buttons["trabalho-continuar-ato"].firstMatch.waitForExistence(timeout: 15),
                      "a folha do trabalho não abriu")
        sleep(2)
        return 3
    }

    private func lancar(tamanho: String? = nil) -> XCUIApplication {
        try? FileManager.default.createDirectory(atPath: pasta, withIntermediateDirectories: true)
        let app = XCUIApplication()
        app.launchEnvironment["TRACO_SEM_MODELO"] = "1"
        if let tamanho { app.launchArguments += ["-UIPreferredContentSizeCategoryName", tamanho] }
        app.launch()
        return app
    }

    // MARK: - a medida

    func testCurvaZeroEmToquesEGestos() throws {
        let app = lancar()
        let toques = abrirAFolha(app)

        let janela = app.frame.height
        var linhas = ["janela=\(Int(janela))pt  toques-ate-a-folha=\(toques)",
                      "gesto\t" + Self.fatos.map(\.0).joined(separator: "\t") + "\tvistos"]
        var vistos = Set<String>()
        var anterior: [String] = []
        var gesto = 0
        let tetoDeGestos = 14

        while gesto <= tetoDeGestos {
            var celulas: [String] = []
            for (nome, trecho) in Self.fatos {
                let achados = app.descendants(matching: .any)
                    .matching(NSPredicate(format: "label CONTAINS %@", trecho))
                    .allElementsBoundByIndex
                    .filter { $0.exists && $0.frame.height > 0 }
                guard let alto = achados.min(by: { $0.frame.minY < $1.frame.minY }) else {
                    celulas.append("ausente"); continue
                }
                let f = alto.frame
                let dentro = naFaixa(f.minY, f.height, janela)
                if dentro { vistos.insert(nome) }
                celulas.append(String(format: "%.2f%@", f.minY / janela, dentro ? "*" : ""))
            }
            linhas.append("\(gesto)\t" + celulas.joined(separator: "\t") + "\t\(vistos.count)")
            if vistos.count == Self.fatos.count { break }
            // Chegar ao fim do documento é resultado: o gesto seguinte não move
            // nada, e insistir inventaria gestos que a pessoa não daria.
            if celulas == anterior { linhas.append("fundo do documento — o gesto não move mais"); break }
            anterior = celulas
            gesto += 1
            app.swipeUp()
            sleep(1)
        }

        linhas.append("gestos-ate-os-sete=\(gesto)  toques=\(toques)  vistos=\(vistos.count)/\(Self.fatos.count)")
        try linhas.joined(separator: "\n").write(toFile: "\(pasta)/medida.txt", atomically: true, encoding: .utf8)
        despejar(app, "arvore-final")
        XCTAssertEqual(vistos.count, Self.fatos.count, "algum dos sete fatos não apareceu em \(tetoDeGestos) gestos")
    }

    // MARK: - os estados do bloco

    /// Teto, excedente e o que acontece ao reabrir, na tela viva. Seis mudanças
    /// desde a visita, menos o relato que a folha já mostra inteiro logo abaixo:
    /// cinco na lista, quatro exibidas e "e mais 1 desde então".
    ///
    /// **Fechar a folha e abrir de novo é uma VISITA NOVA** — a janela recomeça
    /// e o bloco cala, porque a notícia já foi entregue. Este teste fixa esse
    /// contrato em vez de descrevê-lo: quem quiser que a retomada sobreviva a
    /// sair-e-voltar terá de mudar a ADR, e o vermelho aqui avisa. O que a
    /// janela preserva é a REABERTURA INTERNA (`preservarEReabrir`, depois de um
    /// erro de escrita), que não passa por aqui e fica declarada como limite.
    func testTetoExcedenteEAVisitaQueRecomecaAoReabrir() {
        let app = lancar()
        abrirAFolha(app)
        let bloco = app.otherElements["trabalho-desde-a-ultima-visita"].firstMatch
        XCTAssertTrue(bloco.waitForExistence(timeout: 10), "o bloco da retomada não está na folha")
        XCTAssertEqual(app.staticTexts.matching(identifier: "trabalho-mudanca").count, 4,
                       "o teto de quatro linhas não está valendo")
        let excedente = app.staticTexts["trabalho-mudancas-restantes"].firstMatch
        XCTAssertTrue(excedente.exists, "o que não coube tem de ser DITO")
        XCTAssertEqual(excedente.label, "e mais 1 desde então")
        despejar(app, "estado-normal")
        pausarParaAFoto("normal")

        // sair e voltar: visita nova, janela zerada, bloco calado
        app.buttons["trabalho-voltar"].firstMatch.tap()
        XCTAssertTrue(app.buttons["trabalho-na-lista"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["trabalho-na-lista"].firstMatch.tap()
        XCTAssertTrue(app.buttons["trabalho-continuar-ato"].firstMatch.waitForExistence(timeout: 15))
        sleep(2)
        XCTAssertFalse(app.otherElements["trabalho-desde-a-ultima-visita"].firstMatch.exists,
                       "a folha reaberta repetiu a notícia que já tinha dado")
        despejar(app, "reaberta")
    }

    /// Sem visita guardada — primeira abertura, reinstalação, dados limpos — a
    /// folha CALA: o app não sabe desde quando contar e chutar seria inventar.
    /// Semeie com `VISITA=0`. A ausência é afirmada com a árvore E com a foto do
    /// mesmo instante, porque ausência na árvore não prova ausência na tela.
    func testSemVisitaGuardadaAFolhaCala() {
        let app = lancar()
        abrirAFolha(app)
        XCTAssertTrue(app.buttons["trabalho-continuar-ato"].firstMatch.exists, "a folha não abriu")
        XCTAssertFalse(app.otherElements["trabalho-desde-a-ultima-visita"].firstMatch.exists,
                       "sem visita guardada não pode haver \"desde\"")
        despejar(app, "sem-visita")
        pausarParaAFoto("sem-visita")
    }

    /// AX5 com o bloco na tela: a captura do G3 mostrava o topo da folha e não
    /// o bloco, então a legibilidade dele em AX5 ficou sem prova. Aqui o teste
    /// leva o bloco para dentro da janela e só então chama a foto.
    func testBlocoDaRetomadaEmAX5() {
        let app = lancar(tamanho: "UICTContentSizeCategoryAccessibilityXXXL")
        abrirAFolha(app)
        let bloco = app.otherElements["trabalho-desde-a-ultima-visita"].firstMatch
        XCTAssertTrue(bloco.waitForExistence(timeout: 10), "o bloco não está na folha em AX5")
        let janela = app.frame
        // Em AX5 o bloco inteiro tem 1289 pt e a janela 874: ele NÃO cabe, e
        // exigir que coubesse rolaria para longe dele. O alvo é a primeira
        // linha — é ela que prova a legibilidade da retomada nesse tamanho.
        let primeira = app.staticTexts.matching(identifier: "trabalho-mudanca").element(boundBy: 0)
        // Quanto da linha está DENTRO da faixa legível. Uma linha de 348 pt não
        // cabe inteira com folga numa janela útil de 794, e o gesto normal anda
        // 664 pt de uma vez: exigir "inteira" faz o laço saltar por cima dela.
        // O gesto lento é o mesmo nos dois lados da medida e não entra na conta
        // da curva-zero — esta prova é de legibilidade, não de esforço.
        func visivel() -> CGFloat {
            let f = primeira.frame
            return min(f.maxY, janela.height - 80) - max(f.minY, 0)
        }
        var gestos = 0
        while visivel() < 120, gestos < 12 {
            app.swipeUp(velocity: .slow); sleep(1); gestos += 1
        }
        XCTAssertGreaterThanOrEqual(visivel(), 120,
                                    "a primeira linha da retomada não entrou na janela em AX5")
        // nada sangra pelos lados: tudo quebra linha
        for linha in app.staticTexts.matching(identifier: "trabalho-mudanca").allElementsBoundByIndex {
            XCTAssertGreaterThanOrEqual(linha.frame.minX, 0, "uma linha da retomada saiu pela esquerda em AX5")
            XCTAssertLessThanOrEqual(linha.frame.maxX, janela.width, "uma linha da retomada saiu pela direita em AX5")
        }
        despejar(app, "ax5")
        try? "gestos-ate-o-bloco-em-ax5=\(gestos)".write(toFile: "\(pasta)/ax5-gestos.txt",
                                                        atomically: true, encoding: .utf8)
        pausarParaAFoto("ax5")
    }
}
