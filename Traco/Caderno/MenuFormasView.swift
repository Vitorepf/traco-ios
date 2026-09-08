import SwiftUI

/// Folha do catálogo (SPEC §12). A régua fica nas 12; aqui nascem as outras.
/// Palavras, nunca slug, cerca, ou prosa da IA.
struct MenuFormasView: View {
    var aoEscolher: (PapelForma) -> Void
    /// ADR o: dar forma ao texto inteiro sem tocar numa palavra.
    var aoVestirTudo: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var busca = ""

    private var familias: [PapelForma.FamiliaMenu] {
        PapelForma.menu(filtrado: busca)
    }

    private var contagem: String {
        let n = familias.reduce(0) { $0 + $1.formas.count }
        let formas = n == 1 ? "forma" : "formas"
        return busca.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "\(n) \(formas)"
            : "\(n) \(formas) com “\(busca)”"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Todas" é o rótulo do BOTÃO que abriu isto, não o nome da tela.
            // A tela mostra formas — é assim que ela se chama.
            TituloTela("Formas")
            campoBusca
            ScrollView {
                // cabeçalho GRUDADO: com 124 formas em 13 famílias, rolar
                // apagava o rótulo e o autor perdia onde estava. É o que toda
                // lista longa do iOS faz (jakobs-law).
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    // a contagem no TOPO, como no arquivo: sem ela o autor abria
                    // uma lista sem fim e não sabia se a busca tinha terminado
                    // (zeigarnik). Mesma tinta e mesmo corpo dos "3 notas com X".
                    Text(contagem)
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaFraca)
                        .padding(.horizontal, Tema.margem)
                        .padding(.top, 4)
                        .accessibilityIdentifier("contagem-formas")

                    if let aoVestirTudo, busca.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button {
                            Toque.selecao()
                            aoVestirTudo()
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Vestir tudo")
                                    .font(Tema.chrome.weight(.semibold))
                                    .foregroundStyle(Tema.tinta)
                                Text("dá forma ao texto inteiro — título, seções, listas, tabelas — sem mudar uma palavra")
                                    .font(.footnote)
                                    .foregroundStyle(Tema.tintaSuave)
                            }
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.discreto)
                        .accessibilityIdentifier("vestir-tudo")
                    }

                    if familias.isEmpty {
                        // vazio que ENSINA e devolve a saída, NO EIXO da folha
                        // (law-of-continuity; mesmo conserto da busca de notas)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("nenhuma forma com “\(busca)”.")
                                .font(Tema.corpo)
                                .foregroundStyle(Tema.tintaSuave)
                            Button("ver todas as formas") { busca = "" }
                                .font(Tema.chrome.weight(.semibold))
                                .foregroundStyle(Tema.ambarTinta)
                                .alvo()
                                .buttonStyle(.discreto)
                                .accessibilityIdentifier("limpar-filtro-formas")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tema.margem)
                        .padding(.top, 12)
                    }

                    ForEach(familias) { familia in
                      Section {
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
                            .buttonStyle(.discreto)
                            .accessibilityIdentifier("catalogo-\(papel.slug)")
                        }
                      } header: {
                        // fundo opaco: grudado, sem ele as linhas passariam por
                        // baixo do rótulo e as duas leituras se somariam
                        SinalTipo(nome: familia.nome)
                            .padding(.horizontal, Tema.margem)
                            .padding(.top, 20)
                            .padding(.bottom, 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Tema.superficie)
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
                // "Buscar" sozinho não diz onde: no arquivo é "Buscar nas notas"
                prompt: Text("Buscar forma").foregroundStyle(Tema.tintaFraca)
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
                .buttonStyle(.discreto)
                .accessibilityIdentifier("limpar-busca-formas")
            }
        }
        .padding(.horizontal, 12)
        .alvo()
        .background(Tema.fundo, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 8)
        .accessibilityIdentifier("busca-formas")
    }
}
