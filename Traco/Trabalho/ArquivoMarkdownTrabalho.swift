import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ArquivoMarkdownTrabalho: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    var dados: Data

    init(dados: Data) { self.dados = dados }
    init(configuration: ReadConfiguration) throws {
        guard let dados = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        self.dados = dados
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: dados)
    }
}

nonisolated enum LeituraMarkdownTrabalho {
    static func ler(_ url: URL, limite: Int) throws -> Data {
        let acesso = url.startAccessingSecurityScopedResource()
        defer { if acesso { url.stopAccessingSecurityScopedResource() } }
        var falha: NSError?
        var resultado: Result<Data, Error>?
        NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &falha) { coordenada in
            resultado = Result {
                let arquivo = try FileHandle(forReadingFrom: coordenada)
                defer { try? arquivo.close() }
                // Lê no máximo limite+1 mesmo se o arquivo mudar de tamanho.
                let dados = try arquivo.read(upToCount: limite + 1) ?? Data()
                guard dados.count <= limite else { throw CocoaError(.fileReadTooLarge) }
                return dados
            }
        }
        if let falha { throw falha }
        guard let resultado else { throw CocoaError(.fileReadUnknown) }
        return try resultado.get()
    }
}
