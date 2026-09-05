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
        let porId = Dictionary(uniqueKeysWithValues: notas.map { ($0.uuid, $0) })
        return achadas.compactMap { porId[$0.uuid] }
            .filter { !$0.fechada && $0.gesto != .expressiva && $0.temVoz }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DO CADERNO")
                .font(.caption2.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(CalendarioTema.tintaSuave)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("ficha-do-caderno")
            VStack(spacing: 0) {
                ForEach(Array(vizinhas.enumerated()), id: \.element.uuid) { i, nota in
                    Button {
                        aoAbrir(nota.uuid)
                    } label: {
                        HStack(spacing: 8) {
                            Text(nota.tituloNaLista)
                                .font(.callout)
                                .foregroundStyle(CalendarioTema.tinta)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let g = nota.gesto {
                                Text(g.nome.uppercased())
                                    .font(CalendarioTema.letra)
                                    .tracking(0.8)
                                    .foregroundStyle(CalendarioTema.tintaSuave)
                            }
                        }
                        .padding(.vertical, 10)
                        .frame(minHeight: Tema.alvo)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressaoClara())
                    .accessibilityHint("Abre a nota")
                    .accessibilityIdentifier("do-caderno-nota")
                    if i < vizinhas.count - 1 {
                        Rectangle().fill(CalendarioTema.linha).frame(height: 0.5)
                    }
                }
            }
            .padding(.horizontal, 14)
            .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: CalendarioTema.raioCampo, style: .continuous))
        }
    }
}
