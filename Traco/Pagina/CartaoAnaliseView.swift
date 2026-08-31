import SwiftUI

struct CartaoAnaliseView: View {
    let cartao: CartaoAnalisar
    let sessao: Sessao
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch cartao {
            case .aviso(let frase):
                chip("Aviso", aviso: true)
                Text(frase)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isStaticText)
            case .forma(let gesto, let pergunta):
                chip(gesto.nome, aviso: false)
                Text(pergunta)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Abrir a forma \(gesto.nome)") {
                    sessao.usarForma(gesto)
                }
                .buttonStyle(CartaoBotaoStyle())
                .accessibilityHint("Campos vazios nascem abaixo do seu texto")
            case .expressiva:
                chip("Escrita expressiva", aviso: false)
                Text("Isto pede 15 minutos — fato E sentimento, sobre o mesmo evento. Ao fim, a nota tranca e não se relê.")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Começar o timer") {
                    sessao.comecarExpressiva(no: context)
                }
                .buttonStyle(CartaoBotaoStyle())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Tema.raioCartao)
                .fill(Tema.superficieAlta)
                .shadow(color: .black.opacity(0.45), radius: 16, y: 8)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raioCartao)
                .stroke(Tema.linha, lineWidth: 0.5)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("cartao-analise")
    }

    private func chip(_ titulo: String, aviso: Bool) -> some View {
        Text(titulo.uppercased())
            .font(Tema.label)
            .tracking(1.1)
            .foregroundStyle(aviso ? Tema.aviso : Tema.tintaSuave)
    }
}

private struct CartaoBotaoStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Tema.barra)
            .foregroundStyle(Tema.ambar)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
