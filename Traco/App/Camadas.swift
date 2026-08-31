import SwiftUI

/// Duas camadas num trilho horizontal (SPEC §20 rev.2):
///
///     [ Notas · Padrões · Perfil ]  ←→  [ ESCREVER ]
///            com barra                    sem nada
///
/// Escrever não é aba: é a casa. Do arquivo, arrastar para a ESQUERDA volta a
/// escrever; da escrita, a borda esquerda traz o arquivo. O arrasto é 1:1 e a
/// soltura herda a velocidade do dedo (apple-design §2, §5, §6).
struct Camadas<Arquivo: View, Escrita: View>: View {
    @Binding var arquivoAberto: Bool
    var gestoAtivo: Bool
    var reduceMotion: Bool
    @ViewBuilder var arquivo: () -> Arquivo
    @ViewBuilder var escrita: () -> Escrita

    @State private var arrasto: CGFloat = 0

    private let borda: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                arquivo()
                    .frame(width: w, height: geo.size.height)
                    .offset(x: posicao(w) - w)
                    .allowsHitTesting(arquivoAberto)
                    .accessibilityHidden(!arquivoAberto)

                escrita()
                    .frame(width: w, height: geo.size.height)
                    .offset(x: posicao(w))
                    .allowsHitTesting(!arquivoAberto)
                    .accessibilityHidden(arquivoAberto)
            }
            .contentShape(Rectangle())
            .gesture(gestoAtivo ? trilho(w) : nil)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : nil, value: arquivoAberto)
        }
    }

    /// 0 = escrevendo · w = arquivo à mostra. O dedo move o trilho inteiro.
    private func posicao(_ w: CGFloat) -> CGFloat {
        let base: CGFloat = arquivoAberto ? w : 0
        return max(0, min(w, base + arrasto))
    }

    private func trilho(_ w: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { v in
                if arquivoAberto {
                    // do arquivo: só o arrasto para a ESQUERDA conta, e só da
                    // borda direita — o scroll dos chips continua sendo dele
                    guard v.startLocation.x > w - borda else { return }
                    arrasto = min(0, v.translation.width)
                } else {
                    // da escrita: borda esquerda, para não roubar a seleção de texto
                    guard v.startLocation.x < borda else { return }
                    arrasto = max(0, v.translation.width)
                }
            }
            .onEnded { v in
                guard arrasto != 0 else { return }
                let indo = v.translation.width
                let projetado = indo + v.predictedEndTranslation.width * 0.35
                let virar = abs(projetado) > w * 0.3
                let alvo = arquivoAberto ? !virar : virar
                if reduceMotion {
                    withAnimation(.easeOut(duration: 0.2)) {
                        arquivoAberto = alvo
                        arrasto = 0
                    }
                } else {
                    // a mola herda a velocidade: sem costura entre dedo e animação
                    let restante = max(abs(w - abs(indo)), 1)
                    let vel = abs(v.velocity.width) / restante
                    withAnimation(.interpolatingSpring(stiffness: 340, damping: 34, initialVelocity: vel)) {
                        arquivoAberto = alvo
                        arrasto = 0
                    }
                }
                if alvo != (arrasto != 0) { Toque.selecao() }
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
