import Foundation
import UniformTypeIdentifiers

enum AnexoDisco {
    static func pasta() -> URL {
        // sob teste, uma pasta temporária: a suíte roda dentro do app e nunca
        // pode varrer os anexos reais de quem a roda
        let raiz = Arranque.sobTeste
            ? FileManager.default.temporaryDirectory
            : FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let base = raiz.appendingPathComponent("Traco/Anexos", isDirectory: true)
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

    // MARK: - Ciclo de vida (P0 6): anexo sem marcador em nota nenhuma é órfão

    static func idsReferenciados(em textos: [String]) -> Set<String> {
        let rx = try! NSRegularExpression(pattern: #"traco://[a-z]+/([0-9A-Fa-f-]{36})"#)
        var ids = Set<String>()
        for t in textos {
            rx.enumerateMatches(in: t, range: NSRange(t.startIndex..., in: t)) { m, _, _ in
                if let m, let r = Range(m.range(at: 1), in: t) { ids.insert(String(t[r]).lowercased()) }
            }
        }
        return ids
    }

    static func orfaos(referenciados: Set<String>, arquivos: [URL], agora: Date = .now) -> [URL] {
        arquivos.filter { url in
            let id = url.deletingPathExtension().lastPathComponent.lowercased()
            guard !referenciados.contains(id) else { return false }
            // ponytail: 24h de carência protege anexo recém-gravado de nota ainda não salva
            let mod = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            return agora.timeIntervalSince(mod) > 24 * 3600
        }
    }

    static func varrerOrfaos(textos: [String]) {
        // Em emergência o banco está vazio: nenhum anexo é referenciado e a
        // varredura apagaria TODOS com mais de 24h. Nada destrutivo sem banco.
        guard !Arranque.bancoEmMemoria else { return }
        let arquivos = (try? FileManager.default.contentsOfDirectory(
            at: pasta(), includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        for url in orfaos(referenciados: idsReferenciados(em: textos), arquivos: arquivos) {
            try? FileManager.default.removeItem(at: url)
        }
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
