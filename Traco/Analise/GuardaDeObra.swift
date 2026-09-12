import Foundation

/// ADR 2026-09-12a — pedido de livro, autor ou tese ausente das Fontes
/// não vira saber-de-mundo. A recusa é LOCAL: o modelo nem é chamado.
/// Plantar é oferta; sem aceite não há cânone.
nonisolated enum GuardaDeObra {
    static let fraseNaoEstaNoCaderno = "não está no caderno"
    static let oferecePlantar = "Quer plantar esta obra? Enquanto não plantar, eu não invento o que ela diz."

    struct Pedido: Equatable, Sendable {
        var nome: String
    }

    /// Só olha as fontes que já passaram pelo selo (`fonteParaPergunta`).
    /// Não busca o disco. Nota selada não planta obra.
    static func recusarSeAusente(pergunta: String, fontes: [FonteNotas]) -> RespostaNotas.Retorno? {
        guard let pedido = obraAusente(pergunta: pergunta, fontes: fontes) else { return nil }
        return recusa(pedido)
    }

    /// O nome que ela pediu, quando a obra não está nas Fontes. Sem tese.
    static func obraAusente(pergunta: String, fontes: [FonteNotas]) -> Pedido? {
        guard let pedido = pedido(pergunta), !estaNasFontes(pedido, fontes: fontes) else { return nil }
        return pedido
    }

    /// O texto da nota plantada: só o nome. Plantar não inventa a tese.
    static func textoPlantado(_ nome: String) -> String? {
        let t = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        return significativo(t) ? t : nil
    }

    static func recusa(_ pedido: Pedido) -> RespostaNotas.Retorno {
        .init(texto: "\(pedido.nome) \(fraseNaoEstaNoCaderno). \(oferecePlantar)",
              enviadas: [], citadas: [], base: "insuficiente",
              obraParaPlantar: pedido.nome)
    }

    static func estaNasFontes(_ pedido: Pedido, fontes: [FonteNotas]) -> Bool {
        let termos = termosDaObra(pedido.nome)
        guard termos.count >= 2 else { return false }
        let corpus = " " + fontes.map { Prova.normal($0.titulo + " " + $0.texto) }.joined(separator: " ") + " "
        let achados = termos.filter { corpus.contains(" \($0) ") }
        return achados.count >= 2 && achados.count * 5 >= termos.count * 3
    }

    static func pedido(_ pergunta: String) -> Pedido? {
        let texto = pergunta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return nil }
        if let entreAspas = tituloEntreAspas(texto), significativo(entreAspas) {
            return Pedido(nome: entreAspas)
        }
        if let depoisDoMarcador = depoisDeMarcador(texto), significativo(depoisDoMarcador) {
            return Pedido(nome: depoisDoMarcador)
        }
        if let autor = autorNomeado(texto), significativo(autor) {
            return Pedido(nome: autor)
        }
        return nil
    }

    private static let marcadores = [
        "tratado", "manifesto", "romance", "manual", "ensaio", "artigo",
        "livro", "tese", "obra",
    ]

    private static let parada: Set<String> = [
        "a", "o", "os", "as", "um", "uma", "uns", "umas",
        "de", "do", "da", "dos", "das", "e", "ou", "que", "com", "por", "para",
        "em", "no", "na", "nos", "nas", "ao", "aos", "se", "sua", "seu",
        "suas", "seus", "nao", "mais", "mas", "como", "sobre", "qual",
        "voce", "ela", "ele", "isto", "isso", "este", "esta",
    ]

    private static func tituloEntreAspas(_ s: String) -> String? {
        for (abre, fecha) in [("\"", "\""), ("“", "”"), ("«", "»")] {
            guard let i = s.range(of: abre) else { continue }
            let depois = s[i.upperBound...]
            guard let f = depois.range(of: fecha) else { continue }
            let nome = String(depois[..<f.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            if significativo(nome) { return nome }
        }
        return nil
    }

    private static func depoisDeMarcador(_ s: String) -> String? {
        for marcador in marcadores {
            guard let r = s.range(of: #"\b\#(marcador)\b"#, options: [.regularExpression, .caseInsensitive])
            else { continue }
            let nome = limparResto(String(s[r.upperBound...]))
            if nome.lowercased().hasPrefix("sobre ") { continue }
            if significativo(nome) { return nome }
        }
        return nil
    }

    private static let verbosDoAutor = [
        "diz", "pensa", "escreveu", "escreve", "afirma", "defende", "ensina",
        "propõe", "propoe", "sustenta", "explica", "argumenta",
    ]

    private static func autorNomeado(_ s: String) -> String? {
        for verbo in verbosDoAutor {
            guard let r = s.range(of: #"\b\#(verbo)\b"#, options: [.regularExpression, .caseInsensitive])
            else { continue }
            let depois = limparResto(String(s[r.upperBound...]))
            if significativo(depois) { return depois }
            let antes = limparCabeca(String(s[..<r.lowerBound]))
            if significativo(antes) { return antes }
        }
        for marca in atribuicoes {
            guard let r = s.range(of: #"\b\#(marca)"#, options: [.regularExpression, .caseInsensitive])
            else { continue }
            var nome = limparResto(String(s[r.upperBound...]))
            if let virgula = nome.firstIndex(of: ",") {
                nome = String(nome[..<virgula])
            }
            if let corte = nome.range(of: " o que ", options: .caseInsensitive) {
                nome = String(nome[..<corte.lowerBound])
            }
            nome = nome.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "?!.,;:—-"))
            if significativo(nome) { return nome }
        }
        return nil
    }

    /// Irmãs de «segundo»: o nome vem depois da marca, não do verbo.
    private static let atribuicoes = [
        "segundo ", "de acordo com ", "na opinião de ", "na opiniao de ",
    ]

    /// «O que o Daniel Kahneman diz» — o nome mora antes do verbo.
    /// Tira artigo e «que» da cabeça; «ela» / «você» caem na parada.
    private static func limparCabeca(_ s: String) -> String {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        t = t.trimmingCharacters(in: CharacterSet(charactersIn: "?!.,;:—-"))
        let prefixos = [
            "o ", "a ", "os ", "as ", "um ", "uma ", "do ", "da ", "de ", "dos ", "das ",
            "que ", "o que ",
        ]
        var mudou = true
        while mudou {
            mudou = false
            let baixo = t.lowercased()
            for p in prefixos where baixo.hasPrefix(p) {
                t = String(t.dropFirst(p.count))
                mudou = true
                break
            }
        }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "?!.,;:—-"))
    }

    private static func limparResto(_ s: String) -> String {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        t = t.trimmingCharacters(in: CharacterSet(charactersIn: "?!.,;:—-"))
        let prefixos = ["o ", "a ", "os ", "as ", "um ", "uma ", "do ", "da ", "de ", "dos ", "das "]
        var mudou = true
        while mudou {
            mudou = false
            let baixo = t.lowercased()
            for p in prefixos where baixo.hasPrefix(p) {
                t = String(t.dropFirst(p.count))
                mudou = true
                break
            }
        }
        if let corte = t.firstIndex(of: "?") { t = String(t[..<corte]) }
        if let corte = t.range(of: " sobre ", options: .caseInsensitive) {
            t = String(t[..<corte.lowerBound])
        }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "?!.,;:—-"))
    }

    private static func significativo(_ nome: String) -> Bool {
        termosDaObra(nome).count >= 2
    }

    private static func termosDaObra(_ nome: String) -> [String] {
        Prova.normal(nome).split(separator: " ").map(String.init)
            .filter { $0.count >= 4 && !parada.contains($0) }
    }
}
