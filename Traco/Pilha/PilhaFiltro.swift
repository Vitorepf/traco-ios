import Foundation

enum PilhaFiltro {
    static func visiveis(_ notas: [Nota], busca: String, filtro: FiltroPilha?) -> [Nota] {
        notas.filter { nota in
            if filtro == .trancadas { return nota.trancada }
            if nota.trancada { return busca.isEmpty && filtro == nil }
            if let filtro, let g = filtro.gesto, nota.gesto != g { return false }
            if !busca.isEmpty {
                return nota.vozDoAutor.localizedCaseInsensitiveContains(busca)
            }
            return true
        }
    }
}
