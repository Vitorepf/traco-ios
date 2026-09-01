import SwiftUI

/// Folha do catálogo (SPEC §12). A régua fica nas 12; aqui nascem as outras.
/// Palavras, nunca slug, cerca, ou prosa da IA.
struct MenuFormasView: View {
    var aoEscolher: (PapelForma) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var busca = ""

    private var familias: [PapelForma.FamiliaMenu] {
        PapelForma.menu(filtrado: busca)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Todas" é o rótulo do BOTÃO que abriu isto, não o nome da tela.
            // A tela mostra formas — é assim que ela se chama.
            TituloTela("Formas")
            campoBusca
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(familias) { familia in
                        // o cabeçalho não repete o que vem logo abaixo dele:
                        // "CHAMADA" seguido de "Chamada" lia como falha de
                        // renderização, não como agrupamento (law-of-similarity)
                        if !(familia.formas.count == 1 && familia.formas[0].nome == familia.nome) {
                            SinalTipo(nome: familia.nome)
                                .padding(.horizontal, Tema.margem)
                                .padding(.top, 20)
                                .padding(.bottom, 6)
                        }
                        ForEach(Array(familia.formas.enumerated()), id: \.element.id) { indice, papel in
                            // a linha INTEIRA é o alvo. Com moldura e
                            // contentShape do lado de FORA do Button, só a
                            // palavra respondia: numa lista de 136 nomes curtos
                            // o dedo cai na faixa vazia à direita e nada
                            // acontece (fitts-law)
                            Button {
                                Toque.selecao()
                                aoEscolher(papel)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    // fio entre irmãos: 136 nomes soltos no
                                    // escuro não tinham espinha para o olho
                                    // descer (law-of-continuity). Recuado até a
                                    // margem do texto, como no arquivo.
                                    if indice > 0 {
                                        Rectangle()
                                            .fill(Tema.linha)
                                            .frame(height: 0.5)
                                            .padding(.leading, Tema.margem)
                                    }
                                    Text(papel.nome)
                                        .font(Tema.chrome)
                                        .foregroundStyle(Tema.tinta)
                                        .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                                        .padding(.horizontal, Tema.margem)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityIdentifier("catalogo-\(papel.slug)")
                        }
                    }
                }
                .padding(.bottom, 28)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Tema.superficie)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.superficie)
        .accessibilityIdentifier("menu-formas")
    }

    private var campoBusca: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Tema.tintaFraca)
                .accessibilityHidden(true)
            TextField(
                "",
                text: $busca,
                prompt: Text("Buscar").foregroundStyle(Tema.tintaFraca)
            )
            .foregroundStyle(Tema.tinta)
            .tint(Tema.ambar)
            .font(Tema.chrome)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            if !busca.isEmpty {
                Button {
                    busca = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Tema.tintaFraca)
                        .frame(width: Tema.alvo, height: Tema.alvo)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("limpar-busca-formas")
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: Tema.alvo)
        .background(Tema.fundo, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 8)
        .accessibilityIdentifier("busca-formas")
    }
}
