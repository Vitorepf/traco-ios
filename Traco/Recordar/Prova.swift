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
    /// - alvo longo: nenhuma sequência de quatro palavras do alvo pode aparecer
    ///   na pergunta — quatro palavras seguidas já é citação, não é apontar.
    static func vaza(_ pergunta: String, alvo: String) -> Bool {
        let p = " " + normal(pergunta) + " "
        let a = normal(alvo)
        guard !a.isEmpty else { return false }
        let termos = a.split(separator: " ").map(String.init)
        guard termos.count > 3 else { return p.contains(" " + a + " ") }
        for i in 0...(termos.count - 4) {
            let gram = termos[i..<(i + 4)].joined(separator: " ")
            if p.contains(" " + gram + " ") { return true }
        }
        return false
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
