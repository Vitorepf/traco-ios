import Testing
import Foundation
@testable import Traco

/// ADR 2026-09-10h — a prova que não se pode abrir não é prova.
///
/// `Politica.swift` é onde cada operação de IA diz POR QUE tem o executor que
/// tem — e seis delas dizem por que não têm nenhum. O campo `porque` termina
/// sempre no caminho da medida, e é o que alguém segue quando vai conferir se
/// a razão ainda vale. Em 10/09 cinco linhas apontavam para
/// `prova/q-qualidade.md`, um arquivo que nunca existiu (o real é
/// `ferramentas/orca/q-qualidade.md`): a prova de seis indisponibilidades
/// apontava para o vazio, e só se descobriu quando alguém tentou segui-la.
///
/// Este portão anda com a tabela: caminho citado que não abre fica vermelho no
/// mesmo instante em que é escrito, não na volta seguinte.
@Suite struct PortaoDaProvaQueAbreTests {
    /// `prova/…` ou `ferramentas/…`, parando antes da pontuação da frase — o
    /// `porque` é prosa, e `prova/4.md e prova/5.md` são dois caminhos, não um.
    static let caminhoDeProva = #"(?:prova|ferramentas)/[A-Za-z0-9_./-]*[A-Za-z0-9_/]"#

    @Test func todoCaminhoDeProvaCitadoPelaPoliticaAbre() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let tabela = raiz.appending(path: "Traco/Analise/Politica.swift")
        let texto = try String(contentsOf: tabela, encoding: .utf8)

        let citados = texto.matches(of: try Regex(Self.caminhoDeProva))
            .map { String(texto[$0.range]) }
        let unicos = Set(citados).sorted()

        // sem esta linha, uma regex quebrada deixaria a varredura vazia e VERDE
        #expect(unicos.count >= 12,
                "a varredura não achou os caminhos: \(unicos.count) — a regex quebrou?")

        let orfaos = unicos.filter { !FileManager.default.fileExists(atPath: raiz.appending(path: $0).path) }
        #expect(orfaos.isEmpty,
                "a Politica aponta para prova que não abre: \(orfaos.joined(separator: ", "))")
    }

    /// A irmã que NÃO acusa: sem ela, um `fileExists` que dissesse sempre true
    /// passaria neste portão para sempre. O caminho falso tem a mesma forma dos
    /// verdadeiros e mora onde eles moram.
    @Test func oPortaoAcusaUmCaminhoQueNaoExiste() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let inventado = "prova/q-qualidade.md"

        #expect(try inventado.wholeMatch(of: Regex(Self.caminhoDeProva)) != nil,
                "o falso nem seria colhido pela regex — o portão não estaria a medir isto")
        #expect(!FileManager.default.fileExists(atPath: raiz.appending(path: inventado).path),
                "\(inventado) passou a existir: troque o falso deste teste por outro")
    }
}
