import Foundation

/// ADR 2026-09-16d/e — o conselho em SOMBRA.
///
/// Uma Decisão (ou um Pré-mortem) concluída com o ato do autor já escrito
/// procura nas obras CONFERIDAS a regra que mais conversa com o que ele pesou.
/// Nada aparece: o app registra a regra literal, a outra voz e as palavras que
/// as ligaram (`Sinal.exposto`). Quando ele volta e escreve o que aconteceu e o
/// saldo, a regra exposta ganha esse saldo (`Sinal.resultado`) e isso pesa na
/// busca seguinte. O «serviu» nunca pesa: aprender por aprovação é sicofancia.
nonisolated enum Conselho {
    enum Saldo: String, Codable, Sendable { case aquem, igual, alem }

    /// O que a busca lê — e só quando o ATO já está escrito: decidir antes de
    /// consultar é a ordem (ADR 02o, VISAO 05/09).
    static func consulta(gesto: Gesto?, campos: [String: String]) -> String? {
        func tem(_ id: String) -> Bool { !(campos[id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let ids: [String]
        switch gesto {
        case .decisao?:
            guard tem("decidido"), tem("espero") else { return nil }
            ids = ["escolha", "opcoes", "criterio"]
        case .premortem?:
            // o Pré-mortem não tem "decidido": o ato é o plano e o que muda nele
            guard tem("plano"), tem("mudo") else { return nil }
            ids = ["plano", "falhou", "sinal"]
        default:
            return nil
        }
        let texto = ids.compactMap { campos[$0] }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        return texto.isEmpty ? nil : texto
    }

    /// A regra e a outra voz: a melhor seção de OUTRO mestre, quando há. Só
    /// registra quando a pergunta toca a regra de fato (`Obra.admite`) — um
    /// radical comum não vira conselho nem ganha peso depois.
    /// ponytail: «contrária» é outra voz sobre o mesmo assunto, não contradição
    /// provada — o app não lê sentido; nomear a oposição pede etiqueta de tese.
    static func escolher(consulta: String, obras: [String], pesos: [String: Double]) -> (regra: Obra.Achado, outra: Obra.Achado?)? {
        let achados = Obra.ranquear(pergunta: consulta, textos: obras, pesos: pesos)
        // a melhor ADMITIDA: um peso não pode pôr na frente uma seção que a
        // decisão mal toca e, com isso, calar a exposição (revisão E4)
        guard let primeira = achados.first(where: Obra.admite) else { return nil }
        let outra = achados.first { Obra.admite($0) && $0.secao.mestre != nil && $0.secao.mestre != primeira.secao.mestre }
        return (primeira, outra)
    }

    /// O saldo nas palavras do autor, estrito: a resposta COMEÇA por aquém,
    /// igual ou além, com ou sem "ficou" ("Aquém.", "ficou além do esperado"). "Não ficou aquém",
    /// "nada além do esperado" ou duas respostas não são saldo — melhor não
    /// aprender do que aprender ao contrário. (O Retrato conta por palavras de
    /// sinal, de propósito grosseiro; aqui o saldo mexe no peso de uma regra.)
    static func saldo(_ texto: String) -> Saldo? {
        let t = texto.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
            .trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        let achados = [("aquem", Saldo.aquem), ("igual", .igual), ("alem", .alem)]
            .filter { t.range(of: #"\b"# + $0.0 + #"\b"#, options: .regularExpression) != nil }.map(\.1)
        guard achados.count == 1, let saldo = achados.first else { return nil }
        // a pergunta da forma é "Ficou aquém, igual ou além…?": "ficou aquém" responde
        let palavra = switch saldo { case .aquem: "aquem"; case .igual: "igual"; case .alem: "alem" }
        return t.range(of: #"^((ficou|foi|saiu)\s+)?"# + palavra + #"\b"#, options: .regularExpression) != nil ? saldo : nil
    }

    /// O peso de cada regra pelo que aconteceu no mundo: aquém rebaixa, além
    /// eleva, igual não mexe — entre 0,2 e 2, para uma regra não calar nem
    /// dominar o resto. Lê SÓ `resultado`, e só o último de cada nota (o autor
    /// pode corrigir o saldo) — nunca `serviu`.
    static func pesos(_ sinais: [Sinal]) -> [String: Double] {
        var ultimo: [UUID: Sinal] = [:]
        var semNota: [Sinal] = []
        for s in sinais where s.tipo == .resultado {
            if let nota = s.nota { ultimo[nota] = s } else { semNota.append(s) }
        }
        var pesos: [String: Double] = [:]
        for s in semNota + ultimo.values.sorted(by: { $0.quando < $1.quando }) {
            guard let chave = s.regra, let saldo = s.saldo.flatMap(Saldo.init(rawValue:)) else { continue }
            let fator = switch saldo { case .aquem: 0.6; case .igual: 1.0; case .alem: 1.25 }
            pesos[chave] = min(2, max(0.2, pesos[chave, default: 1] * fator))
        }
        return pesos
    }
}
