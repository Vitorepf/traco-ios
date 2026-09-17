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
        HStack(spacing: Tema.doca) {
            HStack(spacing: Tema.folgaDasAbas) {
                ForEach(Aba.naBarra) { item in
                    let aceso = aba == item
                    Button {
                        // a aba acesa também avisa: quem cuida dela decide o que é
                        // «voltar ao começo» (a busca das Notas limpa, auditoria 17/09)
                        if !aceso { Toque.selecao() }
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
                HStack(spacing: Tema.folgaDasAbas) {
                    ForEach(Aba.naBarra) { glifo($0).symbolVariant(.fill) }
                }
                .foregroundStyle(.white)
                .background(Tema.chipAtivo)
                .mask {
                    // dono, 15/09: a seleção na forma de ícone, um quadrado
                    // centrado no glifo — a mesma forma do botão de escrever. O
                    // losango foi provado e preterido: apertava o glifo e era uma
                    // terceira forma. Lado e passo são fixos: não há o que medir.
                    // dono, 16/09: a seleção escorre como gota — a frente sai,
                    // o resto é puxado, e o quadrado afina na ponte
                    Gota(indice: Aba.naBarra.firstIndex(of: aba) ?? 0,
                         passo: Tema.ladoDaAba + Tema.folgaDasAbas,
                         lado: Tema.ladoDaAba, casas: Aba.naBarra.count, raio: Tema.raioDaAba)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            // a folga da borda até a primeira aba é a folga entre as abas;
            // em cima e embaixo, 8 pt até a seleção
            .padding(.horizontal, Tema.folgaDasAbas)
            .padding(.vertical, Tema.doca)
            // o vidro do sistema, cantos contínuos concêntricos com a seleção
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Tema.raioDoca, style: .continuous))

            // ação, não destino: círculo âmbar, uma vez na tela, glifo escuro
            // por cima (7,6:1). `law-of-similarity` — o que FAZ não pode
            // parecer o que LEVA.
            Button {
                Toque.leve()
                aoNovaNota()
            } label: {
                // dono, 15/09: "em vez de amarelo, no estilo de vidro, igual
                // esses" — o mesmo vidro da pílula e das ações do título, na
                // forma dos ícones do iPhone. A identidade fica no TRAÇO: o
                // glifo em âmbar-tinta (5,8:1), o âmbar onde o autor escreve.
                Image(systemName: Aba.escrever.icone)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Tema.ambarTinta)
                    .frame(width: Tema.barraNav, height: Tema.barraNav)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: Tema.raioDoca, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: Tema.raioDoca, style: .continuous))
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

    private func glifo(_ item: Aba) -> some View {
        Image(systemName: item.icone)
            // o glifo ocupa ~46 % do quadrado, como o desenho de um ícone no
            // Dock (dono, 15/09: "os ícones talvez muito pequenos")
            .font(.system(size: 24))
            .frame(width: Tema.ladoDaAba, height: Tema.ladoDaAba)
            .contentShape(Capsule())
    }
}
