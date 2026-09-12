import Foundation
import NaturalLanguage

/// A metade ALGORÍTMICA da prova do Recordar (ADR 2026-09-03i).
///
/// A sábia toma a prova, mas quem decide o que é cobrado é o algoritmo, e o
/// que é cobrado são as palavras DO AUTOR — a IA nunca escolhe o que importa
/// na nota de outra pessoa. Ela também não passa sem ser conferida: a pergunta
/// que vaza a resposta é recusada aqui, antes de chegar à tela.
///
/// §19.4: só entra o que o app sabe checar.
nonisolated enum Prova {
    /// O que a nota cobra, em pedaços — frases do alvo, na ordem.
    ///
    /// Sai do alvo e só do alvo: a conferência devolve NÚMEROS destes pontos,
    /// nunca texto, então tudo que o autor lê na tela continua sendo dele.
    static func pontos(_ alvo: String, teto: Int = 8) -> [String] {
        let limpo = alvo.replacingOccurrences(of: "\r\n", with: "\n")
        var saida: [String] = []
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.setLanguage(.portuguese)
        for linha in limpo.split(whereSeparator: \.isNewline) {
            let texto = String(linha)
            tokenizer.string = texto
            // Um ponto dentro de 12.50 ou Dra. não termina a evidência.
            for intervalo in tokenizer.tokens(for: texto.startIndex..<texto.endIndex) {
                let t = texto[intervalo].trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "-*>#[] "))
                // pedaço curto demais não é ponto: é migalha, e cobrar migalha
                // transforma a prova em caça-palavra
                guard t.count >= 12 else { continue }
                saida.append(t)
                if saida.count == teto { return saida }
            }
        }
        // alvo de uma linha curta (Palavra, Se–Então): o alvo inteiro é o ponto
        if saida.isEmpty {
            let t = limpo.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { saida.append(t) }
        }
        return saida
    }

    /// A pergunta não pode entregar a resposta. Prova dura, não confiança:
    ///
    /// - alvo curto (a Palavra, o Então de uma linha): a pergunta não pode
    ///   conter o alvo, ponto;
    /// - alvo longo: a régua olha o ALVO da recuperação — o predicado depois
    ///   do copula e os números —, não um 4-grama do enunciado inteiro.
    ///   "Qual é a capital de Portugal?" não revela Lisboa; "…exatamente 15?"
    ///   revela o 15. ADR 2026-09-11a.
    static func vaza(_ pergunta: String, alvo: String) -> Bool { vazamento(pergunta, alvo: alvo) != nil }

    /// Citação do exemplo na prática: 4-grama do texto inteiro. O Recordar
    /// não usa isto — lá o 4-grama do enunciado derrubava a pergunta certa.
    static func vazaCitacao(_ texto: String, alvo: String) -> Bool {
        vazamento(texto, alvo: alvo, modo: .citacao) != nil
    }

    enum ModoVazamento: Sendable { case recuperacao, citacao }

    /// O trecho normalizado que casou e ONDE ele começa no alvo, para quem
    /// precisa AUDITAR a recusa (ADR 08p) e não só sofrê-la. `nil` = não vaza.
    ///
    /// O trecho é conteúdo do alvo: serve para decidir dentro do processo e
    /// morre com ele. Quem REGISTRA a recusa guarda a posição e a origem, não
    /// o texto — ver `PraticaTrabalho.Recusa.criterioVazaOExemplo`.
    static func vazamento(_ pergunta: String, alvo: String,
                          modo: ModoVazamento = .recuperacao) -> (trecho: String, palavra: Int, de: Int)? {
        let p = " " + normal(pergunta) + " "
        let a = normal(alvo)
        guard !a.isEmpty else { return nil }
        let termos = a.split(separator: " ").map(String.init)
        guard termos.count > 3 else {
            return p.contains(" " + a + " ") ? (a, 1, termos.count) : nil
        }
        if modo == .citacao {
            for i in 0...(termos.count - 4) {
                let gram = termos[i..<(i + 4)].joined(separator: " ")
                if p.contains(" " + gram + " ") { return (gram, i + 1, termos.count) }
            }
            return nil
        }
        let daPergunta = numeros(em: pergunta)
        if let n = numeros(em: alvo).first(where: { daPergunta.contains($0) }) {
            return (n, 1, termos.count)
        }
        for predicado in predicados(alvo) {
            let pt = normal(predicado)
            let palavras = pt.split(separator: " ").map(String.init)
            guard !palavras.isEmpty else { continue }
            if palavras.count <= 3 {
                if p.contains(" " + pt + " ") { return (pt, 1, termos.count) }
            } else {
                for i in 0...(palavras.count - 4) {
                    let gram = palavras[i..<(i + 4)].joined(separator: " ")
                    if p.contains(" " + gram + " ") { return (gram, i + 1, palavras.count) }
                }
            }
            let conteudo = palavras.filter { !parada.contains($0) }
            guard conteudo.count <= 4 else { continue }
            if let w = conteudo.first(where: { p.contains(" " + $0 + " ") }) {
                return (w, 1, termos.count)
            }
        }
        return nil
    }

    /// Copulas com acento: " é " não é o " e " da conjunção. Ordem: as
    /// formas longas primeiro, para "estão" não perder para "é".
    private static let copulas = [
        " são ", " foram ", " eram ", " estão ", " estava ", " estavam ",
        " esteve ", " ficam ", " ficou ", " fica ", " está ", " foi ", " era ", " é ",
    ]

    private static let parada: Set<String> = [
        "a", "o", "os", "as", "um", "uma", "uns", "umas",
        "de", "do", "da", "dos", "das", "e", "ou", "que", "com", "por", "para",
        "em", "no", "na", "nos", "nas", "ao", "aos", "se", "sua", "seu",
        "suas", "seus", "nao", "mais", "mas", "como",
    ]

    /// O complemento depois do primeiro copula de cada frase: é o que se
    /// recupera. Sujeito e pista ("a capital de Portugal") não entram.
    static func predicados(_ alvo: String) -> [String] {
        alvo.replacingOccurrences(of: "\r\n", with: "\n")
            .split(whereSeparator: \.isNewline)
            .map { String($0) }
            .compactMap(predicado)
    }

    private static func predicado(_ frase: String) -> String? {
        let padded = " " + frase.trimmingCharacters(in: .whitespacesAndNewlines) + " "
        for copula in copulas {
            if let r = padded.range(of: copula, options: .caseInsensitive) {
                let resto = String(padded[r.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !resto.isEmpty { return resto }
            }
        }
        return nil
    }

    /// Dígitos do alvo da recuperação. "15" vaza; o 4-grama ao redor, não.
    static func numeros(em texto: String) -> [String] {
        texto.split { !$0.isNumber }.map(String.init).filter { !$0.isEmpty }
    }

    /// Minúsculas, sem acento, sem pontuação, espaços colapsados. É o que faz
    /// "Fronteira, entre rota" casar com "fronteira entre rota".
    static func normal(_ s: String) -> String {
        let dobrado = s.folding(options: [.diacriticInsensitive, .caseInsensitive],
                                locale: Locale(identifier: "pt_BR"))
        let letras = dobrado.map { $0.isLetter || $0.isNumber ? $0 : " " }
        return String(letras).split(separator: " ").joined(separator: " ")
    }
}
