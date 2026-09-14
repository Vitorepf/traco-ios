import SwiftUI

extension View {
    /// A rolagem entra e sai por baixo do que flutua (título, campo, pílula)
    /// dissolvendo-se no papel, em vez de cortar em cheio. É PINTURA por cima
    /// (gradiente da cor do fundo), não máscara: a máscara fazia da rolagem um
    /// grupo de composição que não era desenhado enquanto a camada do arquivo
    /// deslizava — a lista "aparecia" no lugar final e só a pílula viajava
    /// (rajada de capturas de 14/09, volta 46).
    /// `reservaPe` é a faixa que algo opaco cobre (o campo): ali nada se vê,
    /// e o desvanecimento acontece logo ACIMA dela.
    func desvanece(topo: CGFloat = 0, pe: CGFloat = 0, reservaPe: CGFloat = 0, fundo: Color = Tema.fundo) -> some View {
        overlay(alignment: .top) {
            if topo > 0 {
                LinearGradient(colors: [fundo, fundo.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: topo)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .bottom) {
            if pe > 0 || reservaPe > 0 {
                VStack(spacing: 0) {
                    LinearGradient(colors: [fundo.opacity(0), fundo], startPoint: .top, endPoint: .bottom)
                        .frame(height: pe)
                    if reservaPe > 0 { fundo.frame(height: reservaPe) }
                }
                .allowsHitTesting(false)
            }
        }
    }
}
