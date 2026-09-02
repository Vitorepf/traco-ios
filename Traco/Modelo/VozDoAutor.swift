import Foundation

enum VozDoAutor: Sendable {
    nonisolated static func juntar(texto: String, campos: [String: String],
                                   sentido: String = "") -> String {
        let respostas = campos.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let prosa = Caderno.prosa(de: texto)
        let linha = sentido.trimmingCharacters(in: .whitespacesAndNewlines)
        return ([prosa] + respostas + (linha.isEmpty ? [] : [linha]))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    /// Destilada mostra a frase; Palavra, a definição; Destaque, a única
    /// (a mesma linha da tela bloqueada). Sem isso, a lista fica muda.
    nonisolated static func titulo(_ texto: String, gesto: Gesto? = nil,
                                   campos: [String: String] = [:]) -> String {
        if gesto == .destilar {
            let frase = campos["frase"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !frase.isEmpty { return frase }
        }
        if gesto == .palavra {
            let minhas = campos["minhas"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !minhas.isEmpty { return minhas }
        }
        if gesto == .destaque {
            let unica = campos["unica"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !unica.isEmpty { return unica }
        }
        let prosa = Caderno.prosa(de: texto)
        let base = prosa.isEmpty ? Caderno.visivel(texto) : prosa
        let doCorpo = base.split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? ""
        if !doCorpo.isEmpty { return doCorpo }
        // voz só nos campos: o arquivo não finge que a nota não tem nome
        if let gesto {
            for campo in gesto.campos {
                let v = campos[campo.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !v.isEmpty { return v }
            }
        }
        return ""
    }

    nonisolated static func truncar(_ texto: String, _ n: Int) -> String {
        guard texto.count > n else { return texto }
        let corte = texto.prefix(n)
        if let lastSpace = corte.lastIndex(of: " ") {
            return String(corte[..<lastSpace]) + "…"
        }
        return String(corte) + "…"
    }

    nonisolated static func relativo(_ data: Date, agora: Date = .now) -> String {
        let dias = Calendar.current.dateComponents([.day], from: data, to: agora).day ?? 0
        if dias <= 0 { return "hoje" }
        if dias == 1 { return "ontem" }
        return "há \(dias) dias"
    }

    nonisolated static func trecho(em voz: String, termo: String, limite: Int = 56) -> String {
        let linhas = voz.split(separator: "\n").map(String.init)
        let linha = linhas.first { $0.localizedCaseInsensitiveContains(termo) } ?? VozDoAutor.titulo(voz)
        return truncar(linha, limite)
    }
}