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
        guard let primeira = achados.first, Obra.admite(primeira) else { return nil }
        let outra = achados.dropFirst().first { $0.secao.mestre != nil && $0.secao.mestre != primeira.secao.mestre }
        return (primeira, outra)
    }
}
