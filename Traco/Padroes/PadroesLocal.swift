import Foundation

/// Lê a voz do autor e devolve perguntas que citam fragmentos literais.
/// Nunca conclui, nunca diagnostica, nunca elogia.
enum PadroesLocal: Sendable {
    private static let paragens: Set<String> = [
        "de", "da", "do", "das", "dos", "que", "e", "o", "a", "os", "as",
        "um", "uma", "para", "pra", "com", "não", "nao", "na", "no", "em",
        "é", "eu", "meu", "minha", "meus", "minhas", "isso", "isto", "este",
        "esta", "ser", "ter", "mais", "como", "mas", "por", "se", "ou", "ao",
        "à", "the", "and", "of", "to", "quero", "preciso", "hoje",
    ]

    static func perguntas(vozes: [String], obstaculos: [String] = []) -> [String] {
        let limpas = vozes
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !limpas.isEmpty else { return [] }

        var saida: [String] = []
        var usados: Set<String> = []

        if let obstaculo = obstaculos
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .first(where: { $0.count >= 4 }) {
            let frag = VozDoAutor.truncar(obstaculo, 42)
            saida.append("O obstáculo “\(frag)” — em que outra nota ele volta disfarçado?")
            usados.insert(frag.lowercased())
        }

        if let repetido = fragmentoRepetido(em: limpas), !usados.contains(repetido.lowercased()) {
            saida.append("Você escreveu “\(repetido)” em mais de uma nota — o que fez diferente na vez que andou?")
            usados.insert(repetido.lowercased())
        }

        for voz in limpas {
            let titulo = VozDoAutor.truncar(VozDoAutor.titulo(voz), 42)
            guard titulo.count >= 8, !usados.contains(titulo.lowercased()) else { continue }
            if saida.count == 0 {
                saida.append("Sua nota diz: “\(titulo)”. Se isso é verdade, o que deveria estar escrito hoje — e não está?")
            } else if saida.count == 1,
                      let outra = limpas
                          .map({ VozDoAutor.truncar(VozDoAutor.titulo($0), 36) })
                          .first(where: { $0.count >= 8 && $0.lowercased() != titulo.lowercased() && !usados.contains($0.lowercased()) }) {
                saida.append("“\(titulo)” e “\(outra)” — o que liga as duas, nas suas palavras?")
                usados.insert(outra.lowercased())
            }
            // Auditoria de UX: havia aqui um template de HÁBITO ("na vez em que
            // o pé andou") colado em qualquer nota — inclusive numa de
            // arquitetura de software. Uma pergunta genérica é a prova visível
            // de que o app não reconheceu nada, e contamina a aba inteira.
            // Sem pergunta específica, silêncio (§19.4).
            usados.insert(titulo.lowercased())
            if saida.count >= 3 { break }
        }

        return Array(saida.prefix(3))
    }

    private static func fragmentoRepetido(em vozes: [String]) -> String? {
        var conta: [String: Int] = [:]
        var original: [String: String] = [:]
        for voz in vozes {
            var vistos = Set<String>()
            for palavra in voz.split(whereSeparator: { !$0.isLetter }) {
                let crua = String(palavra)
                let chave = crua.lowercased()
                guard chave.count >= 5, !paragens.contains(chave), vistos.insert(chave).inserted else { continue }
                conta[chave, default: 0] += 1
                original[chave] = crua
            }
        }
        return conta
            .filter { $0.value >= 2 }
            .max { $0.value < $1.value }
            .flatMap { original[$0.key] }
    }
}
