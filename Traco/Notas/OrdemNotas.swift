import Foundation

/// Como a lista se ordena (Q3). Era fixa em `criadaEm` desc — e o dado de
/// "recordada 3×" já estava na tela sem ter como ordenar por ele.
enum OrdemNotas: String, CaseIterable, Identifiable, Sendable {
    case criadaEm, editadaEm, recordada

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .criadaEm: "Mais recentes"
        case .editadaEm: "Editadas por último"
        case .recordada: "Mais recordadas"
        }
    }

    /// A ordenação acontece DEPOIS do filtro, sobre o array — o `@Query` fica
    /// com a ordem estável de criação e a tela decide o resto.
    static func ordenar(_ notas: [Nota], por ordem: OrdemNotas) -> [Nota] {
        switch ordem {
        case .criadaEm:
            return notas.sorted { $0.criadaEm > $1.criadaEm }
        case .editadaEm:
            return notas.sorted { $0.editadaEm > $1.editadaEm }
        case .recordada:
            // empate volta para a data: duas notas nunca recordadas mantêm a
            // ordem que o autor reconhece
            return notas.sorted {
                let a = Revisoes.contagem($0.uuid), b = Revisoes.contagem($1.uuid)
                return a == b ? $0.criadaEm > $1.criadaEm : a > b
            }
        }
    }
}
