import Foundation

/// Export do corpus (FILA P1.4): as notas como UM arquivo .md legível e versionável.
/// ADR 2026-08-31d: trancadas NUNCA saem no export — o selo da expressiva vale
/// também para a rota de backup/restauro (META-FINAL). Elas vivem só no aparelho.
/// ponytail: um arquivo único v1; um-.md-por-nota + import ficam na FILA.
enum Corpus {
    static func arquivoMd(texto: String, gesto: Gesto?, campos: [String: String], criadaEm: Date) -> String {
        var corpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        if let gesto, !campos.isEmpty {
            let respostas = gesto.campos.compactMap { campo -> String? in
                guard let r = campos[campo.id]?.trimmingCharacters(in: .whitespacesAndNewlines), !r.isEmpty else { return nil }
                return "\(campo.rotulo): \(r)"
            }
            if !respostas.isEmpty {
                corpo += "\n\n— \(gesto.nome) —\n" + respostas.joined(separator: "\n")
            }
        }
        let f = ISO8601DateFormatter()
        var cab = "criada: \(f.string(from: criadaEm))"
        if let gesto { cab += "\ngesto: \(gesto.nome)" }
        return "---\n\(cab)\n---\n\n\(corpo)\n"
    }

    static func corpoDoCorpus(notas: [(texto: String, gesto: Gesto?, campos: [String: String], trancada: Bool, criadaEm: Date)]) -> String {
        let abertas = notas.filter { !$0.trancada && !$0.texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let blocos = abertas
            .sorted { $0.criadaEm < $1.criadaEm }
            .map { arquivoMd(texto: $0.texto, gesto: $0.gesto, campos: $0.campos, criadaEm: $0.criadaEm) }
        return blocos.joined(separator: "\n")
    }

    static func exportar(notas: [Nota]) -> URL? {
        let corpo = corpoDoCorpus(notas: notas.map { ($0.texto, $0.gesto, $0.campos, $0.trancada, $0.criadaEm) })
        guard !corpo.isEmpty else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("traco-corpus-\(f.string(from: .now)).md")
        try? corpo.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }
}
