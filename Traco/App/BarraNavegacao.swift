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
                        glifo(item).foregroundStyle(Tema.tintaFraca)
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
            .overlay {
                // onde você está: a cápsula carvão da `Pilula` selecionada, com o
                // glifo cheio em branco. É uma camada inteira recortada pela
                // cápsula que anda — o glifo nunca fica branco sobre branco
                // enquanto ela chega, e nenhum quadro fica sem aba acesa.
                HStack(spacing: 0) {
                    ForEach(Aba.naBarra) { glifo($0).symbolVariant(.fill) }
                }
                .foregroundStyle(.white)
                .background(Tema.chipAtivo)
                .mask {
                    GeometryReader { g in
                        let largura = g.size.width / CGFloat(Aba.naBarra.count)
                        // concêntrica com a pílula: 18 − 4 de respiro = 14
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .frame(width: largura)
                            .offset(x: largura * CGFloat(Aba.naBarra.firstIndex(of: aba) ?? 0))
                            // `escala`, não `toque`: a de 0,65 passava da borda da
                            // pílula e saía cortada reta na viagem de três casas
                            .animation(Tema.movimento(.deslocamento, Tema.Mola.escala, reduzido: reduceMotion), value: aba)
                    }
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .padding((Tema.barraNav - Tema.alvo) / 2)
            // o vidro do sistema (iOS 26+): o mesmo material do campo acima —
            // a sombra desenhada à mão deixava uma faixa cinza sob o pé
            // dono, 15/09: "tudo mais quadrado, como os apps e widgets" — a
            // pílula é o Dock do Traço: cantos contínuos, raio 18 em 52 pt —
            // a proporção do Dock do iPhone (medida na captura do dono)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            // ação, não destino: círculo âmbar, uma vez na tela, glifo escuro
            // por cima (7,6:1). `law-of-similarity` — o que FAZ não pode
            // parecer o que LEVA.
            Button {
                Toque.leve()
                aoNovaNota()
            } label: {
                // dono, 15/09: "consegue deixar ele ultra premium e elegante".
                // O vidro tingido turvava o âmbar e deixava um aro marrom; o
                // botão é uma peça de âmbar polido: luz de cima (degradê curto),
                // fio de luz na metade de cima, contorno quase invisível embaixo,
                // um brilho âmbar curto por baixo e o glifo mais fino.
                Image(systemName: Aba.escrever.icone)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Tema.tinta)
                    .frame(width: Tema.barraNav, height: Tema.barraNav)
                    .background { pecaDeAmbar }
                    .contentShape(Superelipse())
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
        // folga embaixo igual à dos lados: a pílula desce para dentro da área
        // do indicador de início, como a do Hermes (~17 pt da borda).
        // ponytail: num iPhone de botão (área segura 0) a pílula sobe 20 pt
        // acima da reserva de `Tema.barraNav` da RaizView; somar a diferença
        // à reserva se esse aparelho entrar na conta.
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, Tema.margem)
        .ignoresSafeArea(.container, edges: .bottom)
        // movimento reduzido: a barra não desce — só apaga
        .offset(y: escondida && !reduceMotion ? 130 : 0)
        .opacity(escondida ? 0 : 1)
        .animation(Tema.movimento(.deslocamento, Tema.Mola.teclado, reduzido: reduceMotion), value: escondida)
        .accessibilityHidden(escondida)
    }

    /// O botão âmbar como peça polida, na forma dos ícones do iPhone: luz de
    /// cima em degradê curto, fio de luz na metade de cima, contorno quase
    /// invisível e um brilho âmbar curto por baixo.
    private var pecaDeAmbar: some View {
        let forma = Superelipse()
        let luz = LinearGradient(colors: [Color(hex: 0xE9BC62), Tema.ambar, Color(hex: 0xCF9B3A)],
                                 startPoint: .top, endPoint: .bottom)
        let fio = LinearGradient(colors: [.white.opacity(0.7), .white.opacity(0)],
                                 startPoint: .top, endPoint: .center)
        return forma.fill(luz)
            .overlay { forma.stroke(fio, lineWidth: 1).clipShape(forma) }
            .overlay { forma.stroke(Tema.ambarTinta.opacity(0.18), lineWidth: 0.5) }
            .shadow(color: Tema.ambar.opacity(0.32), radius: 8, y: 4)
            .shadow(color: Tema.sombraContato, radius: 1, y: 0.5)
    }

    private func glifo(_ item: Aba) -> some View {
        Image(systemName: item.icone)
            .font(.system(size: 21))
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .contentShape(Capsule())
    }
}
