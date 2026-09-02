import SwiftUI

/// Uma superfície elevada de verdade (auditoria 31/ago): preenchimento, fio de
/// luz no topo, hairline em volta e sombra de contato. Sem isso, sobre preto,
/// um retângulo mais claro lê como buraco em vez de objeto (law-of-figure-ground).
struct SuperficieElevada: ViewModifier {
    var raio: CGFloat = Tema.raio
    var fundo: Color = Tema.superficie
    /// Superfície grande é mais "grossa": sombra mais profunda (apple-design §12).
    var grande: Bool = false

    func body(content: Content) -> some View {
        content
            .background(fundo, in: RoundedRectangle(cornerRadius: raio, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: raio, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Tema.luzBorda, Tema.linha.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            }
            // contato é 2pt, não 18: a sombra alcançava o gutter inteiro e
            // deixava o fundo abaixo do próprio token
            .shadow(color: Tema.sombraContato, radius: grande ? 6 : 4, y: 1)
    }
}

/// O aviso da casa: cartão de raio 12 na margem, texto em tintaSuave — e, só
/// quando há volta, UMA ação em âmbar à direita ("Desfazer" do apagar).
/// Vive na página E no arquivo: apagar acontece no arquivo, e o toast tinha
/// que morar onde o gesto acontece.
struct ToastView: View {
    let texto: String
    var acao: (rotulo: String, acao: () -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Text(texto)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tintaSuave)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let acao {
                Button(acao.rotulo, action: acao.acao)
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.ambar)
                    .accessibilityIdentifier("toast-acao")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Tema.superficieAlta, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        .padding(.horizontal, Tema.margem)
        .accessibilityIdentifier("toast-analise")
        .accessibilityAddTraits(.isStaticText)
    }
}

extension View {
    func superficieElevada(raio: CGFloat = Tema.raio,
                           fundo: Color = Tema.superficie,
                           grande: Bool = false) -> some View {
        modifier(SuperficieElevada(raio: raio, fundo: fundo, grande: grande))
    }
}
