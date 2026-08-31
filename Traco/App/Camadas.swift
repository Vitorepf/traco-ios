import SwiftUI

/// Duas camadas (SPEC §20 rev.2):
///
///     [ Notas · Padrões · Perfil ]  desliza por cima de  [ ESCREVER ]
///
/// Escrever não é aba: é a casa, e fica PARADA no fundo. O arquivo entra pela
/// esquerda e sai para a esquerda. Um só elemento se move — layout determinístico:
/// as duas camadas são irmãs de tela cheia num ZStack, então nenhuma pode ser
/// proposta com largura menor que a tela.
///
/// ponytail: já tentei trilho de duas páginas (HStack deslocado) e ZStack com
/// offset nos DOIS filhos. Ambos realimentavam o layout e entregavam o arquivo
/// com ~72% da largura, deixando a escrita aparecer numa faixa à direita. Este é
/// o menor arranjo que não tem esse laço.
struct Camadas<Arquivo: View, Escrita: View>: View {
    @Binding var arquivoAberto: Bool
    var gestoAtivo: Bool
    var reduceMotion: Bool
    @ViewBuilder var arquivo: () -> Arquivo
    @ViewBuilder var escrita: () -> Escrita

    @State private var arrasto: CGFloat = 0
    @State private var largura: CGFloat = 0

    private let borda: CGFloat = 28

    var body: some View {
        ZStack {
            escrita()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(!arquivoAberto)
                .accessibilityHidden(arquivoAberto)

            arquivo()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: deslocamento)
                .allowsHitTesting(arquivoAberto)
                .accessibilityHidden(!arquivoAberto)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            // medir POR FORA: um GeometryReader que também dimensiona os filhos
            // realimenta o layout
            GeometryReader { g in
                Color.clear
                    .onAppear { largura = g.size.width }
                    .onChange(of: g.size.width) { _, nova in largura = nova }
            }
        }
        .contentShape(Rectangle())
        .gesture(gestoAtivo && largura > 0 ? trilho(largura) : nil)
        .animation(reduceMotion ? .easeOut(duration: 0.2) : nil, value: arquivoAberto)
    }

    /// 0 = arquivo à mostra · −largura = arquivo fora, à esquerda.
    private var deslocamento: CGFloat {
        guard largura > 0 else { return -10_000 } // antes de medir, some de vez
        let base: CGFloat = arquivoAberto ? 0 : -largura
        return max(-largura, min(0, base + arrasto))
    }

    private func trilho(_ w: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { v in
                if arquivoAberto {
                    // do arquivo: para a ESQUERDA, a partir da borda direita —
                    // o scroll horizontal dos chips continua sendo deles
                    guard v.startLocation.x > w - borda else { return }
                    arrasto = min(0, v.translation.width)
                } else {
                    // da escrita: borda esquerda, longe da seleção de texto
                    guard v.startLocation.x < borda else { return }
                    arrasto = max(0, v.translation.width)
                }
            }
            .onEnded { v in
                guard arrasto != 0 else { return }
                let projetado = v.translation.width + v.predictedEndTranslation.width * 0.35
                let virar = abs(projetado) > w * 0.3
                let alvo = arquivoAberto ? !virar : virar
                let mudou = alvo != arquivoAberto
                // antes: mola dura demais — o painel acelerava e batia num muro
                // (+76px num quadro, zero no seguinte). `interactiveSpring`
                // herda a velocidade do dedo e ASSENTA (apple-design §5/§6).
                let mola: Animation = reduceMotion
                    ? .easeOut(duration: 0.2)
                    : .interactiveSpring(response: 0.38, dampingFraction: 0.86, blendDuration: 0.1)
                withAnimation(mola) {
                    arquivoAberto = alvo
                    arrasto = 0
                }
                if mudou { Toque.selecao() }
            }
    }
}

/// O puxador: 3×36pt na borda esquerda da escrita. Descobribilidade sem chrome —
/// diz "tem algo aqui" sem ocupar a tela nem pedir leitura.
struct PuxadorBorda: View {
    var body: some View {
        Capsule()
            .fill(Tema.tintaFraca.opacity(0.35))
            .frame(width: 3, height: 36)
            .padding(.leading, 2)
            .frame(maxHeight: .infinity, alignment: .center)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
