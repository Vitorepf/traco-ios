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
            TituloTela("Todas")
            campoBusca
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(familias) { familia in
                        SinalTipo(nome: familia.nome)
                            .padding(.horizontal, Tema.margem)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        ForEach(familia.formas) { papel in
                            Button(papel.nome) {
                                Toque.selecao()
                                aoEscolher(papel)
                                dismiss()
                            }
                            .buttonStyle(PressaoDiscreta())
                            .font(Tema.chrome)
                            .foregroundStyle(Tema.tinta)
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                            .contentShape(Rectangle())
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
