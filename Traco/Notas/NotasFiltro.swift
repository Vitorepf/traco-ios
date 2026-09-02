import Foundation

enum NotasFiltro {
    static func visiveis(_ notas: [Nota], busca: String, filtro: FiltroNotas?) -> [Nota] {
        // "analise" acha "análise": busca sem acento e sem caixa
        func bate(_ texto: String) -> Bool {
            busca.isEmpty || texto.range(of: busca, options: [.caseInsensitive, .diacriticInsensitive], locale: .current) != nil
        }
        return notas.filter { nota in
            if filtro == .trancadas { return nota.trancada }
            // fechada: o texto nunca entra; a linha de sentido é a única coisa
            // que sai do selo (SPEC §8.5) — e por isso a busca a acha
            if nota.fechada { return filtro == nil && bate(nota.sentido) }
            if let filtro, let g = filtro.gesto, nota.gesto != g { return false }
            return bate(nota.vozDoAutor)
        }
    }
}
