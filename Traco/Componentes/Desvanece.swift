import SwiftUI

extension View {
    /// A rolagem entra e sai por baixo do que flutua (título, campo, pílula)
    /// dissolvendo-se no papel, em vez de cortar em cheio. Máscara, não
    /// gradiente por cima: o que flutua continua nítido.
    /// `reservaPe` é a faixa que algo opaco cobre (o campo): ali nada se vê,
    /// e o desvanecimento acontece logo ACIMA dela.
    func desvanece(topo: CGFloat = 0, pe: CGFloat = 0, reservaPe: CGFloat = 0) -> some View {
        mask {
            VStack(spacing: 0) {
                if topo > 0 {
                    LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                        .frame(height: topo)
                }
                Color.black
                if pe > 0 {
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: pe)
                }
                if reservaPe > 0 { Color.clear.frame(height: reservaPe) }
            }
        }
    }
}
