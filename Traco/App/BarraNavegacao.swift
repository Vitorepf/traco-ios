import SwiftUI

/// Os quatro destinos do app (SPEC §20). Destino ≠ ação: o que se FAZ mora na
/// tela; o para onde se VAI mora aqui.
enum Aba: String, CaseIterable, Identifiable, Sendable {
    case escrever, notas, calendario, padroes, perfil

    var id: String { rawValue }

    /// A barra lista o ARQUIVO. Escrever é a casa — chega-se por gesto,
    /// não por aba. Calendário é o quarto destino (ADR 2026-09-02g).
    static let naBarra: [Aba] = [.notas, .calendario, .padroes, .perfil]

    var titulo: String {
        switch self {
        case .escrever: "Escrever"
        case .notas: "Notas"
        case .calendario: "Calendário"
        case .padroes: "Padrões"
        case .perfil: "Perfil"
        }
    }

    var icone: String {
        switch self {
        case .escrever: "square.and.pencil"
        case .notas: "rectangle.stack"
        case .calendario: "calendar"
        case .padroes: "circle.hexagongrid"
        case .perfil: "person.crop.circle"
        }
    }

    var dica: String {
        switch self {
        case .escrever: "A página em branco"
        case .notas: "Suas notas, busca e filtros"
        case .calendario: "Dia, semana, mês e ano — o dia em que estás"
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
                    // No mundo claro o preto diz onde você está e o âmbar volta
                    // a ser a assinatura da AÇÃO: uma pílula, uma vez na tela,
                    // com o glifo escuro por cima (7,6:1). Forma e cor a
                    // separam dos destinos (law-of-similarity).
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Tema.tinta)
                        .frame(width: 44, height: 24)
                        .background(Tema.ambar, in: Capsule())
                    Text("Escrever")
                        .font(.caption2)
                        .tracking(0.4)
                        .foregroundStyle(Tema.tintaSuave)
                }
                .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier("nova-nota")
            .accessibilityLabel("Escrever uma nota nova")
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
                    .foregroundStyle(aba == item ? Tema.tinta : Tema.tintaFraca)
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
        // barra de abas: o sistema também não escala o rótulo no lugar
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .background {
            // material de verdade: o conteúdo passa por baixo, não some atrás de
            // uma faixa opaca (apple-design §12)
            // o material lavava o âmbar: o fundo sustenta a cor, o vidro só
            // deixa o conteúdo passar por baixo sem sumir (apple-design §12)
            Rectangle()
                .fill(Tema.superficie.opacity(0.85))
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        }
        // movimento reduzido: a barra não desce — só apaga
        .offset(y: escondida && !reduceMotion ? 130 : 0)
        .opacity(escondida ? 0 : 1)
        .animation(Tema.animacao(.interpolatingSpring(stiffness: 420, damping: 34), reduzido: reduceMotion),
                   value: escondida)
        .accessibilityHidden(escondida)
    }
}
