import SwiftUI

/// Push/pop do espelho: a frente entra da direita, o fundo recua −28%.
/// Reduced motion = só opacity. Swipe-back a partir da borda.
struct Empilha<Fundo: View, Frente: View>: View {
    @Binding var aberto: Bool
    var reduceMotion: Bool
    @ViewBuilder var fundo: () -> Fundo
    @ViewBuilder var frente: () -> Frente

    @State private var arrasto: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let largura = geo.size.width
            ZStack {
                fundo()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: deslocamentoFundo(largura))
                    .opacity(aberto && !reduceMotion ? 0.85 : 1)
                    .allowsHitTesting(!aberto)
                    .accessibilityHidden(aberto)

                if aberto {
                    frente()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .offset(x: arrasto)
                        .zIndex(1)
                        .transition(reduceMotion ? .opacity : .move(edge: .trailing))
                        .gesture(swipe(largura))
                }
            }
            .animation(Tema.gaveta(reduzido: reduceMotion), value: aberto)
        }
    }

    private func deslocamentoFundo(_ largura: CGFloat) -> CGFloat {
        guard aberto, !reduceMotion else { return 0 }
        return -largura * 0.28 + arrasto * 0.28
    }

    private func swipe(_ largura: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { valor in
                guard valor.startLocation.x < 24 else { return }
                arrasto = max(0, valor.translation.width)
            }
            .onEnded { valor in
                let deveFechar = valor.translation.width > largura * 0.28
                    || valor.predictedEndTranslation.width > largura * 0.45
                withAnimation(Tema.gaveta(reduzido: reduceMotion)) {
                    if deveFechar { aberto = false }
                    arrasto = 0
                }
            }
    }
}
