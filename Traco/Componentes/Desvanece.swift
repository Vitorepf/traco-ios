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
                // a rolagem continua por baixo da área segura (pílula, indicador
                // de início): a pintura desce até a borda da tela, como a
                // máscara cortava — a altura da área segura vem da geometria
                GeometryReader { g in
                    let ins = g.safeAreaInsets.bottom
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        LinearGradient(colors: [fundo.opacity(0), fundo], startPoint: .top, endPoint: .bottom)
                            .frame(height: pe)
                        fundo.frame(height: reservaPe + ins)
                    }
                    .frame(width: g.size.width, height: g.size.height + ins, alignment: .bottom)
                }
                .allowsHitTesting(false)
            }
        }
    }
}
