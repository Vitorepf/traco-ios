import Foundation

enum VozDoAutor: Sendable {
    /// Tira os colchetes de ligação (ADR 2026-09-03b): eles são sintaxe, não
    /// voz — não aparecem no título da lista nem no que viaja.
    nonisolated static func semColchetes(_ s: String) -> String {
        guard s.contains("[[") else { return s }
        return s.replacingOccurrences(of: #"\[\[([^\[\]\n]{1,120})\]\]"#, with: "$1",
                                      options: .regularExpression)
    }

    /// Os valores dos campos na ORDEM DO MÉTODO (resultado, obstáculo, plano),
    /// não na do dicionário — que mudava a cada leitura e embaralhava a nota no
    /// Recordar ("plano, obstáculo, resultado"). O método é o que tem esses
    /// campos; sem método, a ordem das chaves.
    nonisolated static func respostasNaOrdemDoMetodo(_ campos: [String: String]) -> [String] {
        let chaves = Set(campos.keys)
        let ordem = Catalogo.todos.first { Set($0.campos.map(\.id)).isSuperset(of: chaves) }?.campos.map(\.id) ?? []
        return campos
            .sorted { (ordem.firstIndex(of: $0.key) ?? ordem.count, $0.key) < (ordem.firstIndex(of: $1.key) ?? ordem.count, $1.key) }
            .map(\.value)
    }

    nonisolated static func juntar(texto: String, campos: [String: String],
                                   sentido: String = "") -> String {
        let respostas = respostasNaOrdemDoMetodo(campos)
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
        let primeira = base.split(separator: "\n", omittingEmptySubsequences: true).first.map(String.init) ?? ""
        let doCorpo = semColchetes(primeira)
        // ADR 04k: uma nota encadeada nasce com só `[[origem]]` no corpo e a
        // voz nos campos — a ligação é sintaxe, não título
        let soLigacao = primeira.trimmingCharacters(in: .whitespaces)
            .range(of: #"^\[\[[^\[\]\n]+\]\]$"#, options: .regularExpression) != nil
        let temCampo = gesto?.campos.contains { !(campos[$0.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? false
        if !doCorpo.isEmpty, !(soLigacao && temCampo) { return doCorpo }
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
        // `whereSeparator` e não `"\n"`: em CRLF o fim de linha é um só `Character`
        // e a voz virava UMA linha — o trecho da busca devolvia o começo da nota
        // cortado, em vez da linha que tem o termo.
        let linhas = voz.split(whereSeparator: \.isNewline).map(String.init)
        // a pergunta inteira não está em linha nenhuma: vale a linha que tem
        // uma das palavras dela (a busca por palavras do NotasFiltro)
        let palavras = termo.split { !$0.isLetter && !$0.isNumber }.map(String.init).filter { $0.count >= 4 }
        let linha = linhas.first { $0.localizedCaseInsensitiveContains(termo) }
            ?? linhas.first { l in palavras.contains { l.localizedCaseInsensitiveContains($0) } }
            ?? VozDoAutor.titulo(voz)
        return truncar(linha, limite)
    }
}

nonisolated extension String {
    /// Uma linha só, com teto: o campo do pré-mortem quer a frase, não a nota.
    func linhaUnica(teto: Int) -> String {
        let plano = split(whereSeparator: \.isNewline).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard plano.count > teto else { return plano }
        return String(plano.prefix(teto)).trimmingCharacters(in: .whitespaces) + "…"
    }
}
