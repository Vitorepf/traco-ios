import SwiftUI

/// Leitura de artefatos pelo parser existente. Nenhum portal abre arquivos,
/// executa código ou transforma uma tarefa do documento em ação do aplicativo.
struct ConteudoTrabalhoView: View {
    let fonte: String
    @Environment(\.dynamicTypeSize) private var tamanhoTexto

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Caderno.fatias(fonte)) { fatia in
                bloco(fatia)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .textSelection(.enabled)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private func bloco(_ fatia: FatiaCaderno) -> some View {
        switch fatia.bloco {
        case .paragrafo, .itens, .citacao, .divisoria:
            ProsaView(bloco: fatia.bloco)
        case .titulo:
            ProsaView(bloco: fatia.bloco)
                .accessibilityAddTraits(.isHeader)
        case .tarefas(let itens):
            VStack(alignment: .leading, spacing: 12) {
                // Índices pertencem a esta versão imutável, não a uma lista editável.
                ForEach(Array(itens.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: item.feito ? "checkmark.square" : "square")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .accessibilityHidden(true)
                        Text(ProsaView.textoInline(item.texto))
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(item.feito ? "Marcada no documento" : "Não marcada no documento"): \(item.texto)")
                }
            }
        case .tabela(let cabeca, let corpo):
            if tamanhoTexto.isAccessibilitySize || max(cabeca.count, corpo.map(\.count).max() ?? 0) > 3 {
                tabelaLinear(cabeca, corpo)
            } else {
                ProsaView(bloco: fatia.bloco)
                    // O visual compacto compara colunas; VoiceOver recebe os
                    // pares cabeçalho/valor, sem perder a associação de cada célula.
                    .accessibilityRepresentation { tabelaLinear(cabeca, corpo) }
            }
        case .codigo(let lingua, let codigo):
            VStack(alignment: .leading, spacing: 8) {
                Text(lingua).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                ScrollView(.horizontal) {
                    Text(verbatim: codigo)
                        .font(Tema.mono)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: true, vertical: true)
                        .padding(12)
                }
                .background(Tema.codigoFundo, in: RoundedRectangle(cornerRadius: Tema.raio))
                .accessibilityLabel("Código em \(lingua), somente leitura")
            }
        case .imagem, .audio, .video, .arquivo, .recipiente:
            // Inclusive referências locais: a fonte fica visível, sem resolver
            // caminhos e sem carregar anexos de notas fora deste agregado.
            Text(verbatim: fatia.fonte)
                .font(Tema.mono)
                .foregroundStyle(Tema.tintaSuave)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func tabelaLinear(_ cabeca: [String], _ corpo: [[String]]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tabela").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                .accessibilityAddTraits(.isHeader)
            if corpo.isEmpty {
                ForEach(Array(cabeca.enumerated()), id: \.offset) { _, nome in
                    Text(verbatim: nome).font(Tema.corpo)
                }
            }
            ForEach(Array(corpo.enumerated()), id: \.offset) { indice, linha in
                VStack(alignment: .leading, spacing: 10) {
                    Text("Linha \(indice + 1)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    ForEach(0..<max(cabeca.count, linha.count), id: \.self) { coluna in
                        let nome = coluna < cabeca.count && !cabeca[coluna].isEmpty ? cabeca[coluna] : "Coluna \(coluna + 1)"
                        let valor = coluna < linha.count && !linha[coluna].isEmpty ? linha[coluna] : "Sem valor"
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: nome).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            Text(verbatim: valor).font(Tema.corpo).foregroundStyle(Tema.tinta)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) { Rectangle().fill(Tema.linha).frame(height: 1) }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
