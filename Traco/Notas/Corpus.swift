import Foundation

/// Export do corpus (FILA P1.4): as notas como UM arquivo .md legível e versionável.
/// ADR 2026-08-31d: trancadas NUNCA saem no export — o selo da expressiva vale
/// também para a rota de backup/restauro (META-FINAL). Elas vivem só no aparelho.
/// ponytail: um arquivo único v1; um-.md-por-nota + import ficam na FILA.
enum Corpus {
    static func arquivoMd(texto: String, gesto: Gesto?, campos: [String: String], criadaEm: Date,
                          extra: String? = nil) -> String {
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
        if let extra { cab += "\n\(extra)" }
        return "---\n\(cab)\n---\n\n\(corpo)\n"
    }

    /// `sentidos`: SPEC §8.5 — a linha de sentido é a ÚNICA coisa que sai do
    /// selo. Vai como bloco próprio, SEM gesto: importar não pode acordar um
    /// timer de expressiva, e a linha volta como nota aberta nas palavras do autor.
    static func corpoDoCorpus(notas: [(texto: String, gesto: Gesto?, campos: [String: String], trancada: Bool, criadaEm: Date)],
                              sentidos: [(sentido: String, criadaEm: Date)] = []) -> String {
        let abertas = notas
            .filter { !$0.trancada && !$0.texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { ($0.criadaEm, arquivoMd(texto: $0.texto, gesto: $0.gesto, campos: $0.campos, criadaEm: $0.criadaEm)) }
        let linhas = sentidos
            .filter { !$0.sentido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { ($0.criadaEm, arquivoMd(texto: $0.sentido, gesto: nil, campos: [:], criadaEm: $0.criadaEm, extra: "expressiva: sentido")) }
        return (abertas + linhas).sorted { $0.0 < $1.0 }.map(\.1).joined(separator: "\n")
    }

    /// O que sai do selo: só a linha de sentido das fechadas (§8.5).
    private static func sentidos(_ notas: [Nota]) -> [(sentido: String, criadaEm: Date)] {
        notas.filter(\.fechada).map { ($0.sentido, $0.criadaEm) }
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
        // blocos do nosso export: "---\ncriada: ...\n[gesto: ...]\n[chave: ...]\n---\n\ncorpo"
        // (linhas extras no cabeçalho são toleradas: um export mais novo importa no app velho)
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\ncriada: (\S+)\n(?:gesto: (.+)\n)?(?:\w+: .*\n)*---\n"#)
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
        // Em emergência o corpus da RAM não é o corpus: reescrever o arquivo
        // mataria o único backup que existe sem nuvem.
        guard !Arranque.bancoEmMemoria else { return }
        let corpo = corpoDoCorpus(notas: notas.map { ($0.texto, $0.gesto, $0.campos, $0.fechada, $0.criadaEm) },
                                  sentidos: sentidos(notas))
        guard !corpo.isEmpty,
              let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        gravar(corpo, em: docs)
    }

    /// Uma geração de volta: o arquivo anterior vira `traco-corpus-anterior.md`
    /// antes de qualquer sobrescrita. Um bug, ou um apagar por engano, nunca
    /// custa o corpus inteiro — o autor tem sempre o de antes, no Arquivos.
    static func gravar(_ corpo: String, em docs: URL) {
        let fm = FileManager.default
        let atual = docs.appendingPathComponent("traco-corpus.md")
        let anterior = docs.appendingPathComponent("traco-corpus-anterior.md")
        if fm.fileExists(atPath: atual.path) {
            try? fm.removeItem(at: anterior)
            try? fm.copyItem(at: atual, to: anterior)
        }
        try? corpo.data(using: .utf8)?.write(to: atual, options: .atomic)
    }

    static func exportar(notas: [Nota]) -> URL? {
        let corpo = corpoDoCorpus(notas: notas.map { ($0.texto, $0.gesto, $0.campos, $0.fechada, $0.criadaEm) },
                                  sentidos: sentidos(notas))
        guard !corpo.isEmpty else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("traco-corpus-\(f.string(from: .now)).md")
        try? corpo.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }
}
