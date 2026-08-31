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

    /// Reconstrói os campos achatados pelo export ("— Nome —\nRótulo: resposta"):
    /// labels são mobiliário — não podem virar voz do autor no import (§15/§16).
    static func separarCampos(texto: String, gesto: Gesto?) -> (texto: String, campos: [String: String]) {
        guard let gesto, let alcance = texto.range(of: "\n\n— \(gesto.nome) —\n") else {
            return (texto, [:])
        }
        let corpo = String(texto[..<alcance.lowerBound])
        let bloco = String(texto[alcance.upperBound...])
        var campos: [String: String] = [:]
        for linha in bloco.split(separator: "\n") {
            for campo in gesto.campos where linha.hasPrefix("\(campo.rotulo): ") {
                campos[campo.id] = String(linha.dropFirst(campo.rotulo.count + 2))
            }
        }
        return campos.isEmpty ? (texto, [:]) : (corpo, campos)
    }

    /// Import (FILA P1.3): lê o formato do próprio export — e qualquer .md solto.
    /// REGRA DO SELO: import JAMAIS cria nota trancada; tudo que entra, entra aberto.
    nonisolated static func importar(_ conteudo: String) -> [(texto: String, gestoNome: String?, criadaEm: Date)] {
        let f = ISO8601DateFormatter()
        // blocos do nosso export: "---\ncriada: ...\n[gesto: ...]\n---\n\ncorpo"
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\ncriada: (\S+)\n(?:gesto: (.+)\n)?---\n"#)
        let ns = conteudo as NSString
        let hits = padrao.matches(in: conteudo, range: NSRange(location: 0, length: ns.length))
        guard !hits.isEmpty else {
            let limpo = conteudo.trimmingCharacters(in: .whitespacesAndNewlines)
            return limpo.isEmpty ? [] : [(limpo, nil, .now)]
        }
        var saida: [(String, String?, Date)] = []
        for (i, hit) in hits.enumerated() {
            let inicioCorpo = hit.range.location + hit.range.length
            let fimCorpo = i + 1 < hits.count ? hits[i + 1].range.location : ns.length
            let corpo = ns.substring(with: NSRange(location: inicioCorpo, length: fimCorpo - inicioCorpo))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !corpo.isEmpty else { continue }
            let data = f.date(from: ns.substring(with: hit.range(at: 1))) ?? .now
            let gestoNome = hit.range(at: 2).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 2))
            saida.append((corpo, gestoNome, data))
        }
        return saida
    }

    /// Backup silencioso no Documents (visível no app Arquivos; entra no backup
    /// do aparelho). Trancadas continuam de fora — o selo vale para o restauro.
    static func backupAutomatico(notas: [Nota]) {
        let corpo = corpoDoCorpus(notas: notas.map { ($0.texto, $0.gesto, $0.campos, $0.trancada, $0.criadaEm) })
        guard !corpo.isEmpty,
              let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        try? corpo.data(using: .utf8)?.write(to: docs.appendingPathComponent("traco-corpus.md"), options: .atomic)
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
