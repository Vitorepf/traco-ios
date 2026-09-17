import SwiftData
import SwiftUI

/// ADR 2026-09-04w — DO CADERNO: as notas cujo sentido é vizinho do
/// compromisso, pelo índice do aparelho. A ficha só a inclui quando há
/// vizinha: seção vazia não existe, nem como espaçamento.
struct DoCadernoView: View {
    let vizinhas: [Nota]
    var aoAbrir: (UUID) -> Void

    /// O que se procura: título e notas do compromisso, juntos.
    nonisolated static func consulta(titulo: String, notas: String) -> String {
        (titulo + " " + notas).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// As vizinhas de um compromisso entre as notas dadas. O selo corta: o
    /// índice já não tem fechada nem expressiva, e aqui corta de novo.
    static func procurar(_ texto: String, entre notas: [Nota]) async -> [Nota] {
        guard texto.count >= 3, Indice.disponivel else { return [] }
        let achadas = await Task.detached(priority: .userInitiated) {
            Indice.vizinhas(de: texto, teto: 3, minimo: 0.3)
        }.value
        guard !Task.isCancelled else { return [] }
        let porId = Dictionary(notas.map { ($0.uuid, $0) }, uniquingKeysWith: { a, _ in a })
        return achadas.compactMap { porId[$0.uuid] }
            .filter { !$0.fechada && $0.gesto != .expressiva && $0.temVoz }
    }

    /// ADR 10k: "DO CADERNO" é cabeçalho de seção — agrupa, e conta. O nome
    /// da forma à direita, em caixa alta, era etiqueta nomeando conteúdo:
    /// desce ao subtítulo, em frase normal, e a caixa cinza em volta sai.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CabecalhoDeSecao("Do caderno", contagem: vizinhas.count)
                .accessibilityIdentifier("ficha-do-caderno")
            ForEach(Array(vizinhas.enumerated()), id: \.element.uuid) { i, nota in
                Button {
                    aoAbrir(nota.uuid)
                } label: {
                    LinhaDeLista(tocavel: "doc.text", nota.tituloNaLista, nota.gesto?.nome,
                                 linhasDoTitulo: 2, fio: i < vizinhas.count - 1)
                }
                .buttonStyle(PressaoClara())
                .accessibilityHint("Abre a nota")
                .accessibilityIdentifier("do-caderno-nota")
            }
        }
    }
}
