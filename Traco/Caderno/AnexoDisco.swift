import Foundation
import UniformTypeIdentifiers

enum AnexoDisco {
    static func pasta() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Traco/Anexos", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    static func url(_ id: String, nome: String? = nil) -> URL {
        if let nome, !nome.isEmpty {
            let ext = (nome as NSString).pathExtension
            if !ext.isEmpty {
                return pasta().appendingPathComponent("\(id).\(ext)")
            }
        }
        let candidatos = (try? FileManager.default.contentsOfDirectory(at: pasta(), includingPropertiesForKeys: nil)) ?? []
        if let hit = candidatos.first(where: { $0.deletingPathExtension().lastPathComponent == id }) {
            return hit
        }
        return pasta().appendingPathComponent(id)
    }

    static func gravar(id: UUID, dados: Data, nome: String) throws -> URL {
        let destino = url(id.uuidString, nome: nome)
        try dados.write(to: destino, options: .atomic)
        return destino
    }

    static func dados(_ id: String, nome: String? = nil) -> Data? {
        try? Data(contentsOf: url(id, nome: nome))
    }

    static func tamanho(_ id: String, nome: String? = nil) -> String {
        guard let v = try? url(id, nome: nome).resourceValues(forKeys: [.fileSizeKey]),
              let n = v.fileSize
        else { return "" }
        if n < 1024 { return "\(n) B" }
        if n < 1024 * 1024 { return String(format: "%.0f KB", Double(n) / 1024) }
        return String(format: "%.1f MB", Double(n) / (1024 * 1024))
    }

    static func marcaMarkdown(id: UUID, nome: String, tipo: UTType) -> String {
        if tipo.conforms(to: .image) {
            return "\n\n![\(nome)](traco://img/\(id.uuidString))\n"
        }
        if tipo.conforms(to: .movie) {
            return "\n\n[video:\(nome)](traco://video/\(id.uuidString))\n"
        }
        if tipo.conforms(to: .audio) {
            return "\n\n[audio:\(nome)](traco://audio/\(id.uuidString))\n"
        }
        return "\n\n[arquivo:\(nome)](traco://file/\(id.uuidString))\n"
    }
}
