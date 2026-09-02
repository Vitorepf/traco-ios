import Foundation
import NaturalLanguage

/// A lente da língua (iA Writer, Edda, Vocabulary): o autor visto por dentro,
/// por regra local, sem modelo. Conta o que se repete, o que enfraquece e o
/// que é frase de outro. Nunca reescreve: aponta.
nonisolated struct Lente: Sendable, Equatable {
    struct Achado: Sendable, Equatable, Identifiable {
        var termo: String
        var vezes: Int
        var id: String { termo }
    }

    var palavras: Int
    var frases: Int
    var muletas: [Achado]
    var adverbios: [Achado]
    var adjetivos: [Achado]
    var passivas: [String]
    var frasesFeitas: [String]

    var vazia: Bool {
        muletas.isEmpty && adverbios.isEmpty && adjetivos.isEmpty && passivas.isEmpty && frasesFeitas.isEmpty
    }

    // MARK: léxicos (pt-BR)

    /// O que se diz para ganhar tempo. Contadas por palavra inteira.
    static let muletas: [String] = [
        "tipo", "tipo assim", "né", "basicamente", "na verdade", "meio que", "acho que",
        "eu acho", "simplesmente", "realmente", "literalmente", "enfim", "sabe", "entende",
        "coisa", "coisas", "super", "mega", "de certa forma", "com certeza", "obviamente",
        "claramente", "exatamente", "então assim", "digamos", "um pouco", "bastante",
    ]

    /// Frase de outro: quando aparece, o autor parou de pensar por um instante.
    static let frasesFeitas: [String] = [
        "no final do dia", "no fim do dia", "fora da caixa", "a nível de", "em nível de",
        "via de regra", "sem sombra de dúvida", "nem tudo são flores", "o céu é o limite",
        "pisar em ovos", "de vento em popa", "à flor da pele", "custe o que custar",
        "ponta do iceberg", "mãos à obra", "pé no chão", "zona de conforto",
        "fazer a diferença", "agregar valor", "em suma", "com o passar do tempo",
        "dar o melhor de si", "cada vez mais", "por outro lado", "em última análise",
        "vale a pena", "sem dúvida", "de uma vez por todas", "hoje em dia",
    ]

    /// ser/estar + particípio: a passiva esconde quem faz.
    static let passiva = #"\b(é|são|foi|foram|era|eram|será|serão|seja|sejam|fosse|fossem|sendo|sido|está|estão|estava|estavam|ser|estar)\s+([\p{L}]+(?:ado|ada|ados|adas|ido|ida|idos|idas)|(?:entregue|feit[oa]|dit[oa]|vist[oa]|post[oa]|abert[oa]|escrit[oa]|cobert[oa]|mort[oa]|pag[oa]|ganh[oa]|gast[oa]|aceit[oa]|impress[oa]|expuls[oa]|extint[oa]|inclus[oa]|solt[oa]|salv[oa]|pres[oa]|suspens[oa]|eleit[oa]|frit[oa]|limp[oa]|peg[oa]|resolvid[oa]|descobert[oa])s?)\b"#

    // MARK: análise

    nonisolated static func ler(_ texto: String) -> Lente {
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        let baixo = limpo.lowercased()

        let tokens = palavrasDe(baixo)
        let frases = max(0, limpo.split(whereSeparator: { ".!?\n".contains($0) })
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)

        // a mais longa primeiro, e o que ela pegou sai do texto: "tipo assim"
        // não conta de novo em "tipo", "eu acho que" não conta duas vezes
        var restante = baixo
        var feitas: [String] = []
        for f in Self.frasesFeitas.sorted(by: { $0.count > $1.count }) {
            let (n, r) = comer(f, de: restante)
            if n > 0 { feitas.append(f); restante = r }
        }
        var muletas: [String: Int] = [:]
        for m in Self.muletas.sorted(by: { $0.count > $1.count }) {
            let (n, r) = comer(m, de: restante)
            if n > 0 { muletas[m] = n; restante = r }
        }

        var passivas: [String] = []
        if let re = try? NSRegularExpression(pattern: passiva, options: [.caseInsensitive]) {
            let range = NSRange(limpo.startIndex..., in: limpo)
            for m in re.matches(in: limpo, range: range) {
                if let r = Range(m.range, in: limpo) { passivas.append(String(limpo[r])) }
            }
        }

        // classes gramaticais: o etiquetador do sistema, offline; o "-mente"
        // por regra, porque o etiquetador falha nos advérbios longos
        var adverbios: [String: Int] = [:]
        var adjetivos: [String: Int] = [:]
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = limpo
        let opcoes: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
        tagger.enumerateTags(in: limpo.startIndex..<limpo.endIndex, unit: .word, scheme: .lexicalClass, options: opcoes) { tag, faixa in
            let palavra = limpo[faixa].lowercased()
            guard palavra.count > 2 else { return true }
            if tag == .adverb || palavra.hasSuffix("mente") {
                adverbios[palavra, default: 0] += 1
            } else if tag == .adjective {
                adjetivos[palavra, default: 0] += 1
            }
            return true
        }
        // "-mente" como advérbio só quando NÃO for muleta já contada
        for m in muletas.keys where adverbios[m] != nil { adverbios[m] = nil }

        func ordenar(_ d: [String: Int]) -> [Achado] {
            d.map { Achado(termo: $0.key, vezes: $0.value) }
                .sorted { $0.vezes == $1.vezes ? $0.termo < $1.termo : $0.vezes > $1.vezes }
        }

        return Lente(
            palavras: tokens.count,
            frases: frases,
            muletas: ordenar(muletas),
            adverbios: ordenar(adverbios).filter { $0.vezes >= 1 },
            // adjetivo só vira achado quando repete: um adjetivo é escolha, três é hábito
            adjetivos: ordenar(adjetivos).filter { $0.vezes >= 2 },
            passivas: passivas,
            frasesFeitas: feitas
        )
    }

    nonisolated private static func palavrasDe(_ s: String) -> [String] {
        s.split { !$0.isLetter && $0 != "-" && $0 != "'" }.map(String.init)
    }

    /// Conta e apaga do texto o que contou, para a próxima não recontar.
    nonisolated private static func comer(_ termo: String, de texto: String) -> (Int, String) {
        guard let re = try? NSRegularExpression(
            pattern: "\\b" + NSRegularExpression.escapedPattern(for: termo) + "\\b",
            options: [.caseInsensitive]) else { return (0, texto) }
        let ns = NSMutableString(string: texto)
        let n = re.replaceMatches(in: ns, range: NSRange(location: 0, length: ns.length), withTemplate: " ")
        return (n, String(ns))
    }

    nonisolated private static func contar(_ termo: String, em texto: String) -> Int {
        guard let re = try? NSRegularExpression(
            pattern: "\\b" + NSRegularExpression.escapedPattern(for: termo) + "\\b",
            options: [.caseInsensitive]) else { return 0 }
        return re.numberOfMatches(in: texto, range: NSRange(texto.startIndex..., in: texto))
    }
}
