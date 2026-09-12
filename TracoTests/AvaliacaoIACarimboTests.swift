import CryptoKit
import Foundation
import Testing
@testable import Traco

/// O PORTÃO DOS CARIMBOS DE PEDIDO — e o que o fez nascer foi uma mescla.
///
/// A 10b pôs `pedidoResponderSHA256` no registro do JSONL; a 10c pôs
/// `pedidoInstigarSHA256`. As duas chaves caíram na **mesma cauda** do
/// dicionário, na linha em que `.map { … }.joined()]` fecha o literal — e
/// `origin/main` não mesclou. Resolver de afogadilho ali derruba **uma das
/// duas em silêncio**: o build passa, a suíte passa, a corrida seguinte grava
/// um JSONL sem o carimbo do braço e **parece medida**.
///
/// *Um carimbo que desaparece sem barulho é pior que um carimbo que nunca
/// existiu*, porque o segundo se vê e o primeiro não. Por isso o conserto foi
/// aos dois níveis: os carimbos saíram da cauda para `carimbosDoPedido`, onde
/// cada rota tem a sua linha e um conflito futuro é visível, e este portão
/// fica vermelho se um sumir mesmo assim.
///
/// A régua é calculada AQUI, do texto do pedido, e não pedida a
/// `AvaliacaoIA.sha256` — oráculo que chama o candidato só serve no negativo.
@MainActor
struct AvaliacaoIACarimboTests {
    static func sha(_ t: String) -> String {
        SHA256.hash(data: Data(t.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    @Test("as DUAS rotas medidas carimbam, e o carimbo é o sha do pedido que rodou")
    func osDoisCarimbos() {
        let c = AvaliacaoIA.carimbosDoPedido
        #expect(Set(c.keys) == ["pedidoResponderSHA256", "pedidoInstigarSHA256"],
                "uma rota medida perdeu o carimbo do braço: \(c.keys.sorted())")
        #expect(c["pedidoResponderSHA256"] == Self.sha(Sabia.sistemaResponder))
        #expect(c["pedidoInstigarSHA256"] == Self.sha(Sabia.pedidoDeInstigar))
    }

    /// Carimbo que não distingue os braços não carimba nada. O `instigar` roda
    /// em dois pedidos no MESMO binário (`TRACO_AVALIAR_PEDIDO=base`), e é
    /// disso que a comparação pareada vive.
    @Test("o carimbo separa os dois braços de instigar, e o que roda é um deles")
    func oCarimboSeparaOsBracos() {
        let vigente = Self.sha(Sabia.sistemaInstigar)
        let anterior = Self.sha(Sabia.sistemaInstigarBase)
        #expect(vigente != anterior, "os dois braços têm o mesmo sha: a corrida mediria uma coisa só")
        #expect([vigente, anterior].contains(AvaliacaoIA.carimbosDoPedido["pedidoInstigarSHA256"]))
    }

    /// O teste de valor acima fica VERDE se alguém apagar a linha que junta os
    /// carimbos ao registro — a constante continua certa e o JSONL sai sem ela.
    /// Este lê o fonte. A sonda que acusa vem com a irmã que não acusa: sem a
    /// segunda, uma varredura que parasse de enxergar passaria calada.
    @Test("o registro do JSONL ainda junta os carimbos")
    func oRegistroJuntaOsCarimbos() throws {
        let fonte = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Traco/Analise/AvaliacaoIA.swift")
        let texto = try String(contentsOf: fonte, encoding: .utf8)
        let codigo = PortaoDoMovimentoTests.codigoVisivel(texto, apagandoTema: false)
        #expect(codigo.contains("for (chave, sha) in carimbosDoPedido { linha[chave] = sha }"),
                "os carimbos existem mas não entram no gravar: o JSONL sai sem o braço")
        #expect(codigo.contains("for (chave, v) in carimbosDaRegua { linha[chave] = v }"),
                "a régua e a porta existem mas não entram no gravar: a fumaça não distingue o binário da 11a")
        #expect(!codigo.contains("for (chave, sha) in carimbosQueNinguemEscreveu"),
                "a varredura parou de enxergar o fonte de AvaliacaoIA")
    }

    @Test("a fumaça carimba a porta de um par e a régua Lisboa, do código que rodou")
    func osCarimbosDaRegua() {
        let c = AvaliacaoIA.carimbosDaRegua
        #expect(Set(c.keys) == ["portaCalibragemAceitaUmPar", "reguaLisboaNaoVaza"])
        #expect(c["portaCalibragemAceitaUmPar"] == (Sabia.paresDaCalibragem(["um"]) ? "true" : "false"))
        #expect(c["reguaLisboaNaoVaza"] == (Prova.vaza(
            "Qual é a capital de Portugal?",
            alvo: "A capital de Portugal é Lisboa.") ? "false" : "true"))
        #expect(c["portaCalibragemAceitaUmPar"] == "true",
                "o candidato desta árvore tem de aceitar um par; se isto falhou, a 11a saiu do código")
        #expect(c["reguaLisboaNaoVaza"] == "true",
                "o candidato desta árvore não vaza Lisboa pelo enunciado; se isto falhou, a régua velha voltou")
    }

    @Test("a identidade da 11a copia os dois casos da matriz, sem inventar entrada")
    func aIdentidadeCopiaAMatriz() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        func lote(_ nome: String) throws -> [[String: Any]] {
            let dados = try Data(contentsOf: raiz.appending(path: "prova/\(nome)"))
            let json = try JSONSerialization.jsonObject(with: dados) as? [String: Any]
            return try #require(json?["casos"] as? [[String: Any]])
        }
        let matriz = Dictionary(uniqueKeysWithValues: try lote("12-recordar-calibragem-casos.json").map {
            (try #require($0["id"] as? String), $0)
        })
        let identidade = try lote("12-identidade-regua-porta.json")
        #expect(identidade.map { $0["id"] as? String } == ["qn-calibragem-par-unico", "q5-recordar-capital-lisboa"])
        for caso in identidade {
            let id = try #require(caso["id"] as? String)
            let origem = try #require(matriz[id])
            #expect(caso["operacao"] as? String == origem["operacao"] as? String)
            let a = try JSONSerialization.data(withJSONObject: caso["entrada"] as Any, options: [.sortedKeys])
            let b = try JSONSerialization.data(withJSONObject: origem["entrada"] as Any, options: [.sortedKeys])
            #expect(a == b, "a identidade desviou a entrada de \(id)")
        }
    }

    /// Sem o braço `devicectl` a remedição só alcança o simulador (conta
    /// desligada). Sem os abortos, um `VIA=devicectl` no binário velho gasta
    /// a conta. O script não instala e não apaga o caderno.
    @Test("o script de remediar aborta sem a 11a e alcança o iPhone sem install")
    func oScriptDeRemediarNaoInstalaEAlcancaOIphone() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let script = try String(contentsOf: raiz.appending(path: "ferramentas/orca/remedir-recordar-calibragem.sh"),
                                encoding: .utf8)
        #expect(script.contains("VIA=devicectl"))
        #expect(script.contains("devicectl device copy to"))
        #expect(script.contains("devicectl device process launch"))
        #expect(script.contains("appDataContainer"))
        #expect(script.contains("VIA=devicectl exige D="))
        #expect(script.contains("D:-1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF"))
        #expect(script.contains("exit 5"))
        #expect(script.contains("return 7"))
        #expect(script.contains("enviar_fixture"))
        #expect(script.contains(".vazio-envio"))
        #expect(script.contains("salta arquivo do mesmo tamanho"))
        #expect(script.contains("portaCalibragemAceitaUmPar"))
        #expect(script.contains("reguaLisboaNaoVaza"))
        #expect(script.contains("não instalo"))
        #expect(!script.contains("xcodebuild"))
        #expect(!script.contains("devicectl device install"))
        #expect(!script.contains(" --remove-existing-content"))
        #expect(!script.contains("147D3079-1557-5D87-8784-546121A608DD"),
                "identificador do iPhone no padrão faria a remedição gastar sem pedido")
        let porta = try #require(script.range(of: "if ! carimbos_11a"))
        let conta = try #require(script.range(of: "if ! conta_ligada"))
        #expect(porta.lowerBound < conta.lowerBound,
                "conta desligada não pode esconder que o binário não é o da 11a")
        #expect(script.contains("11a no binário"))
        // SO=1 lê a 11a e a conta e para. Sem isto, o mesmo comando que
        // identifica o binário gasta a matriz inteira quando os dois portões
        // passam — e a identidade no iPhone vira remedição por acidente.
        #expect(script.contains("SO=\"${SO:-}\""))
        let so = try #require(script.range(of: "só fumaça"))
        let r43 = try #require(script.range(of: "recordar-calibragem-grok-4.3"))
        #expect(conta.lowerBound < so.lowerBound,
                "SO=1 tem de falar depois da conta, senão esconde os portões")
        #expect(so.lowerBound < r43.lowerBound,
                "SO=1 tem de sair antes das 36×2, senão a identidade gasta")
    }
}
