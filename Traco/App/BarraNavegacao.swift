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

/// Barra inferior das telas de ARQUIVO (REFERENCIA-HERMES §2): os destinos numa
/// pílula que flutua acima da borda, só ícone; a ação de escrever num círculo
/// FORA dela. Criar não disputa espaço com navegar — é fisicamente outra coisa.
/// Na escrita ela não existe — lá o foco é total (§3).
struct BarraNavegacao: View {
    @Binding var aba: Aba
    var escondida: Bool
    /// Começar uma nota é AÇÃO, não destino — por isso tem forma própria.
    var aoNovaNota: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: Tema.entreItens) {
            HStack(spacing: 0) {
                ForEach(Aba.naBarra) { item in
                    let aceso = aba == item
                    Button {
                        guard !aceso else { return }
                        Toque.selecao()
                        aba = item
                    } label: {
                        Image(systemName: item.icone)
                            .font(.system(size: 21, weight: aceso ? .semibold : .regular))
                            .symbolVariant(aceso ? .fill : .none)
                            .foregroundStyle(aceso ? Tema.tinta : Tema.tintaFraca)
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                            // onde você está: cápsula cheia atrás do glifo
                            .background { if aceso { Capsule().fill(Tema.chip) } }
                            // o aceso é ESTADO, não transição: acendia em fade meio
                            // segundo depois do conteúdo, deixando quadros sem aba
                            // selecionada nenhuma
                            .animation(nil, value: aba)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityIdentifier("aba-\(item.rawValue)")
                    .accessibilityLabel(item.titulo)
                    .accessibilityHint(item.dica)
                    .accessibilityAddTraits(aceso ? [.isButton, .isSelected] : .isButton)
                    // sem rótulo na tela: o toque longo mostra o nome grande,
                    // como a barra do sistema
                    .accessibilityShowsLargeContentViewer {
                        Label(item.titulo, systemImage: item.icone)
                    }
                }
            }
            .padding((Tema.barraNav - Tema.alvo) / 2)
            .background {
                // o fundo sustenta a cor, o vidro deixa o conteúdo passar por
                // baixo sem sumir (apple-design §12)
                Capsule()
                    .fill(Tema.superficieAlta.opacity(0.85))
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(Tema.linha, lineWidth: 0.5))
                    .sombra(Tema.Sombra.flutuante)
            }

            // ação, não destino: círculo âmbar, uma vez na tela, glifo escuro
            // por cima (7,6:1). `law-of-similarity` — o que FAZ não pode
            // parecer o que LEVA.
            Button {
                Toque.leve()
                aoNovaNota()
            } label: {
                Image(systemName: Aba.escrever.icone)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Tema.tinta)
                    .frame(width: Tema.barraNav, height: Tema.barraNav)
                    .background(Tema.ambar, in: Circle())
                    .sombra(Tema.Sombra.flutuante)
                    .contentShape(Circle())
            }
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier("nova-nota")
            .accessibilityLabel("Escrever uma nota nova")
            .accessibilityHint("Guarda esta e abre uma página em branco")
            .accessibilityShowsLargeContentViewer {
                Label(Aba.escrever.titulo, systemImage: Aba.escrever.icone)
            }
        }
        .padding(.horizontal, Tema.margem)
        // movimento reduzido: a barra não desce — só apaga
        .offset(y: escondida && !reduceMotion ? 130 : 0)
        .opacity(escondida ? 0 : 1)
        .animation(Tema.movimento(.deslocamento, Tema.Mola.teclado, reduzido: reduceMotion), value: escondida)
        .accessibilityHidden(escondida)
    }
}
