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
        #expect(codigo.contains("for (chave, sha) in carimbosDoPedido { registro[chave] = sha }"),
                "os carimbos existem mas não entram no registro: o JSONL sai sem o braço")
        #expect(!codigo.contains("for (chave, sha) in carimbosQueNinguemEscreveu"),
                "a varredura parou de enxergar o fonte de AvaliacaoIA")
    }
}
