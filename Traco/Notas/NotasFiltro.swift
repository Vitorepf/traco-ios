import Foundation

enum NotasFiltro {
    static func visiveis(_ notas: [Nota], busca: String, filtro: FiltroNotas?,
                         dominio: Dominio? = nil) -> [Nota] {
        notas.filter { nota in
            if filtro == .trancadas { return nota.trancada }
            if nota.trancada { return busca.isEmpty && filtro == nil && dominio == nil }
            if let filtro, let g = filtro.gesto, nota.gesto != g { return false }
            if let dominio, nota.dominio != dominio { return false }
            if !busca.isEmpty {
                // "analise" acha "análise": busca sem acento e sem caixa
                return nota.vozDoAutor.range(
                    of: busca,
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                ) != nil
            }
            return true
        }
    }
}
