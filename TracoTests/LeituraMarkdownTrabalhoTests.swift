import Foundation
import Testing
@testable import Traco

struct LeituraMarkdownTrabalhoTests {
    @Test func arquivoPermaneceIntactoDepoisDaLeitura() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".md")
        let dados = Data("# Conteúdo\r\n\r\n```swift\nlet x = 2 * 3\n```\n".utf8)
        try dados.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(try LeituraMarkdownTrabalho.ler(url, limite: dados.count) == dados)
        #expect(try Data(contentsOf: url) == dados)
    }

    @Test func arquivoGrandeEhRecusadoSemImportarPrefixo() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".md")
        let dados = Data(repeating: 65, count: 4097)
        try dados.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        #expect(throws: (any Error).self) { try LeituraMarkdownTrabalho.ler(url, limite: 4096) }
        #expect(try Data(contentsOf: url) == dados)
    }
}
