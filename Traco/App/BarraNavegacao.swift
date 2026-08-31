import SwiftUI

/// Os quatro destinos do app (SPEC §20). Destino ≠ ação: o que se FAZ mora na
/// tela; o para onde se VAI mora aqui.
enum Aba: String, CaseIterable, Identifiable, Sendable {
    case escrever, notas, padroes, perfil

    var id: String { rawValue }

    /// A barra só lista o ARQUIVO. Escrever é a casa — chega-se por gesto,
    /// não por aba (`hicks-law`: três escolhas, não quatro).
    static let naBarra: [Aba] = [.notas, .padroes, .perfil]

    var titulo: String {
        switch self {
        case .escrever: "Escrever"
        case .notas: "Notas"
        case .padroes: "Padrões"
        case .perfil: "Perfil"
        }
    }

    var icone: String {
        switch self {
        case .escrever: "square.and.pencil"
        case .notas: "rectangle.stack"
        case .padroes: "circle.hexagongrid"
        case .perfil: "person.crop.circle"
        }
    }

    var dica: String {
        switch self {
        case .escrever: "A página em branco"
        case .notas: "Suas notas, busca e filtros"
        case .padroes: "Perguntas sobre o que se repete nas suas notas"
        case .perfil: "Conta e ajustes"
        }
    }
}

/// Barra inferior das telas de ARQUIVO: destino no polegar (`fitts-law`), padrão
/// que o iOS já ensinou (`jakobs-law`), âmbar marcando onde você está.
/// Na escrita ela não existe — lá o foco é total (§3).
struct BarraNavegacao: View {
    @Binding var aba: Aba
    var escondida: Bool
    /// Começar uma nota é AÇÃO, não destino — por isso tem forma própria.
    var aoNovaNota: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            // ação, não destino: pílula âmbar cheia, sem estado de seleção.
            // `law-of-similarity` — o que FAZ não pode parecer o que LEVA.
            Button {
                Toque.leve()
                aoNovaNota()
            } label: {
                VStack(spacing: 3) {
                    // Dois âmbares fixos no rodapé (esta pílula + a aba
                    // selecionada) faziam o acento não significar nada, e o olho
                    // entrava pela navegação em vez de pelo conteúdo
                    // (von-restorff-effect). A ação se distingue por FORMA e
                    // PESO — o âmbar fica só para dizer onde você está.
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Tema.tinta)
                        .frame(width: 38, height: 26)
                        .background(Tema.superficieAlta, in: Capsule())
                        .overlay(Capsule().strokeBorder(Tema.luzBorda, lineWidth: 0.5))
                    Text("Nova")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.4)
                        .foregroundStyle(Tema.tintaSuave)
                }
                .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier("nova-nota")
            .accessibilityLabel("Nova nota")
            .accessibilityHint("Guarda esta e abre uma página em branco")

            ForEach(Aba.naBarra) { item in
                Button {
                    guard aba != item else { return }
                    Toque.selecao()
                    aba = item
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: item.icone)
                            .font(.system(size: 21, weight: aba == item ? .semibold : .regular))
                            .symbolVariant(aba == item ? .fill : .none)
                            .frame(height: 24)
                        Text(item.titulo)
                            .font(.caption2.weight(aba == item ? .semibold : .regular))
                            .tracking(0.4)
                    }
                    .foregroundStyle(aba == item ? Tema.ambar : Tema.tintaSuave)
                    // o aceso é ESTADO, não transição: acendia em fade meio
                    // segundo depois do conteúdo, deixando quadros sem aba
                    // selecionada nenhuma
                    .animation(nil, value: aba)
                    .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("aba-\(item.rawValue)")
                .accessibilityLabel(item.titulo)
                .accessibilityHint(item.dica)
                .accessibilityAddTraits(aba == item ? [.isButton, .isSelected] : .isButton)
            }

        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .background {
            // material de verdade: o conteúdo passa por baixo, não some atrás de
            // uma faixa opaca (apple-design §12)
            // o material lavava o âmbar: o fundo sustenta a cor, o vidro só
            // deixa o conteúdo passar por baixo sem sumir (apple-design §12)
            Rectangle()
                .fill(Tema.fundo.opacity(0.82))
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle().fill(Tema.luzBorda).frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        }
        .offset(y: escondida ? 130 : 0)
        .opacity(escondida ? 0 : 1)
        .animation(reduceMotion ? .easeOut(duration: 0.15)
                                : .interpolatingSpring(stiffness: 420, damping: 34),
                   value: escondida)
        .accessibilityHidden(escondida)
    }
}
