import Foundation

/// ADR 2026-09-12a — pedido de livro, autor ou tese ausente das Fontes
/// não vira saber-de-mundo. A recusa é LOCAL: o modelo nem é chamado.
/// Plantar é oferta; sem aceite não há cânone.
///
/// Identidade é por fonte, como frase contígua — nunca saco de palavras
/// somado entre notas. Nome plantado marca presença. Conteúdo extra na
/// fonte NÃO foi qualificado como tese desta obra.
nonisolated enum GuardaDeObra {
    static let fraseNaoEstaNoCaderno = "não está no caderno"
    static let oferecePlantar = "Quer plantar esta obra? Enquanto não plantar, eu não invento o que ela diz."
    static let fraseNomePuro = "nesta consulta chegou só o nome. Não invento o que ela diz."
    static let fraseForaDestaConsulta = "não coube nesta consulta. Não invento o que ela diz."

    struct Pedido: Equatable, Sendable {
        var nome: String
    }

    /// Só olha as fontes que já passaram pelo selo (`fonteParaPergunta`).
    /// Não busca o disco. Nota selada não planta obra.
    static func recusarSeAusente(pergunta: String, fontes: [FonteNotas]) -> RespostaNotas.Retorno? {
        guard let pedido = obraAusente(pergunta: pergunta, fontes: fontes) else { return nil }
        return recusa(pedido)
    }

    /// Nome puro nesta consulta. Não diz que falta no caderno. Não afirma tese.
    /// Seleção que não casa o pedido NÃO recusa: a rota das Notas não extrapola
    /// o recorte ao caderno; geração e conferência leem o material enviado.
    static func recusarSeConsultaInsuficiente(pergunta: String, fontes: [FonteNotas]) -> RespostaNotas.Retorno? {
        guard let pedido = pedido(pergunta), estaNasFontes(pedido, fontes: fontes) else { return nil }
        if fontes.contains(where: { eIdentidade(pedido.nome, na: $0) && !soONome($0, pedido: pedido) }) {
            return nil
        }
        return recusaNomePuro(pedido)
    }

    /// A obra estava nas fontes da seleção e não coube no pacote efetivo.
    /// Limite desta consulta, não ausência no caderno.
    static func recusarSeOmitidaDoPacote(pergunta: String, originais: [FonteNotas],
                                         efetivas: [FonteNotas]) -> RespostaNotas.Retorno? {
        guard let pedido = pedido(pergunta),
              estaNasFontes(pedido, fontes: originais),
              !estaNasFontes(pedido, fontes: efetivas) else { return nil }
        return recusaForaDestaConsulta(pedido)
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

    static func recusaNomePuro(_ pedido: Pedido) -> RespostaNotas.Retorno {
        .init(texto: "\(pedido.nome) \(fraseNomePuro)",
              enviadas: [], citadas: [], base: "insuficiente")
    }

    static func recusaForaDestaConsulta(_ pedido: Pedido) -> RespostaNotas.Retorno {
        .init(texto: "\(pedido.nome) \(fraseForaDestaConsulta)",
              enviadas: [], citadas: [], base: "insuficiente")
    }

    /// Presença: uma fonte, sozinha, identifica a obra. Palavras de notas
    /// distintas não se somam.
    static func estaNasFontes(_ pedido: Pedido, fontes: [FonteNotas]) -> Bool {
        fontes.contains { eIdentidade(pedido.nome, na: $0) }
    }

    /// Filtro de nome puro: o texto da fonte é só o nome. Não qualifica tese.
    static func semRotulosDeCampo(_ texto: String) -> String {
        let nomes = Set(Catalogo.todos.flatMap { $0.campos.map(\.nome) })
        return texto.split(separator: "\n", omittingEmptySubsequences: false).map { linha in
            guard let dois = linha.range(of: ": "), nomes.contains(String(linha[..<dois.lowerBound])) else { return String(linha) }
            return String(linha[dois.upperBound...])
        }.joined(separator: "\n")
    }

    static func soONome(_ fonte: FonteNotas, pedido: Pedido) -> Bool {
        guard eIdentidade(pedido.nome, na: fonte) else { return false }
        let n = Prova.normal(pedido.nome)
        let titulo = Prova.normal(fonte.titulo)
        // a nota com forma chega rotulada ("Fonte: Antifrágil", 16k): o rótulo não é conteúdo
        let texto = Prova.normal(semRotulosDeCampo(fonte.texto))
        return texto == n || texto == titulo || texto.isEmpty
    }

    static func pedido(_ pergunta: String) -> Pedido? {
        let texto = pergunta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return nil }
        if let depoisDoMarcador = depoisDeMarcador(texto), significativo(depoisDoMarcador) {
            return Pedido(nome: depoisDoMarcador)
        }
        if !citaFrase(texto), let entreAspas = tituloEntreAspas(texto), significativo(entreAspas) {
            return Pedido(nome: entreAspas)
        }
        if let autor = autorNomeado(texto), significativo(autor), nomeProprio(autor, na: texto) {
            return Pedido(nome: autor)
        }
        return nil
    }

    private static let marcadores = [
        "tratado", "manifesto", "romance", "manual", "ensaio", "artigo",
        "livro", "tese", "obra",
    ]

    /// Entram no nome porque costumam ser o começo do título. «livro» só aponta.
    private static let marcadoresNoNome: Set<String> = [
        "tratado", "manifesto", "romance", "manual", "ensaio", "artigo", "tese", "obra",
    ]

    private static let parada: Set<String> = [
        "a", "o", "os", "as", "um", "uma", "uns", "umas",
        "de", "do", "da", "dos", "das", "e", "ou", "que", "com", "por", "para",
        "em", "no", "na", "nos", "nas", "ao", "aos", "se", "sua", "seu",
        "suas", "seus", "nao", "mais", "mas", "como", "sobre", "qual",
        "voce", "ela", "ele", "isto", "isso", "este", "esta",
        "frase", "citada", "cite", "citou", "citei",
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

    /// Aspas citam frase, slogan ou título. «Explique a frase "…"» não é obra.
    private static func citaFrase(_ s: String) -> Bool {
        Prova.normal(s).split(separator: " ").contains("frase")
    }

    private static func depoisDeMarcador(_ s: String) -> String? {
        for marcador in marcadores {
            guard let r = s.range(of: #"\b\#(marcador)\b"#, options: [.regularExpression, .caseInsensitive])
            else { continue }
            let resto = limparResto(String(s[r.upperBound...]))
            if resto.lowercased().hasPrefix("sobre ") { continue }
            if resto.lowercased().hasPrefix("frase ") { continue }
            let cru = marcadoresNoNome.contains(marcador)
                ? limparResto(String(s[r.lowerBound...]))
                : resto
            if significativo(cru) { return cru }
        }
        return nil
    }

    private static let verbosDoAutor = [
        "diz", "pensa", "escreveu", "escreve", "afirma", "defende", "ensina",
        "propõe", "propoe", "sustenta", "explica", "explique", "argumenta", "resuma", "resume",
    ]

    private static func autorNomeado(_ s: String) -> String? {
        for verbo in verbosDoAutor {
            guard let r = s.range(of: #"\b\#(verbo)\b"#, options: [.regularExpression, .caseInsensitive])
            else { continue }
            let depois = limparResto(String(s[r.upperBound...]))
            if utilizavelComoNome(depois, na: s) { return depois }
            let antes = limparCabeca(String(s[..<r.lowerBound]))
            if utilizavelComoNome(antes, na: s) { return antes }
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
            if utilizavelComoNome(nome, na: s) { return nome }
        }
        return nil
    }

    private static func utilizavelComoNome(_ nome: String, na pergunta: String) -> Bool {
        guard significativo(nome), !nome.lowercased().hasPrefix("frase ") else { return false }
        return nomeProprio(nome, na: pergunta)
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

    /// Uma obra pode ser um título curto (Hamlet, Duna). Artigo ou pronome não.
    private static func significativo(_ nome: String) -> Bool {
        let tokens = Prova.normal(nome).split(separator: " ").map(String.init)
        return tokens.contains { $0.count >= 4 && !parada.contains($0) }
            || tokens.filter { $0.count >= 3 && !parada.contains($0) }.count >= 2
    }

    /// Capital no meio da pergunta, não só a letra inicial da frase.
    private static func nomeProprio(_ nome: String, na pergunta: String) -> Bool {
        let tokens = nome.split(whereSeparator: \.isWhitespace).map(String.init)
        return tokens.contains { token in
            guard let inicial = token.first, inicial.isUppercase else { return false }
            guard let r = pergunta.range(of: token, options: .literal)
                    ?? pergunta.range(of: token, options: .caseInsensitive) else { return false }
            return r.lowerBound > pergunta.startIndex
        }
    }

    private static func eIdentidade(_ nome: String, na fonte: FonteNotas) -> Bool {
        let n = Prova.normal(nome)
        guard !n.isEmpty else { return false }
        let titulo = Prova.normal(fonte.titulo)
        let texto = Prova.normal(fonte.texto)
        if igualOuPrefixo(n, em: titulo) || igualOuPrefixo(n, em: texto) { return true }
        // Título da fonte + liga + autor no pedido: o autor tem de estar
        // na mesma fonte. «Tratado» + «das» não identifica o tratado.
        if autorAposTitulo(n, titulo: titulo, na: fonte) { return true }
        return false
    }

    private static func igualOuPrefixo(_ nome: String, em campo: String) -> Bool {
        campo == nome || campo.hasPrefix(nome + " ")
    }

    private static func autorAposTitulo(_ nome: String, titulo: String, na fonte: FonteNotas) -> Bool {
        guard !titulo.isEmpty, nome.hasPrefix(titulo + " ") else { return false }
        let resto = String(nome.dropFirst(titulo.count + 1))
        for liga in ["de ", "da ", "do ", "dos ", "das "] {
            guard resto.hasPrefix(liga) else { continue }
            let autor = String(resto.dropFirst(liga.count))
            guard !autor.isEmpty else { return false }
            let campo = Prova.normal(fonte.titulo) + " " + Prova.normal(fonte.texto)
            return campo.contains(autor)
        }
        return false
    }
}
