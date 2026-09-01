import SwiftUI

struct CartaoAnaliseView: View {
    let cartao: CartaoAnalisar
    let sessao: Sessao
    var aoAbrirCampos: (() -> Void)?
    @Environment(\.modelContext) private var context

    var body: some View {
        // AX: em Dynamic Type grande o texto cresce — o cartão rola por dentro
        // e nunca cobre a topbar (o resto da UI continua alcançável).
        ScrollView {
            conteudo
        }
        .frame(maxHeight: 380)
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Tema.raioCartao, style: .continuous)
                .fill(Tema.superficieAlta)
                // material de verdade: sombra ambiente + sombra de contato
                .shadow(color: .black.opacity(0.45), radius: 16, y: 8)
                .shadow(color: .black.opacity(0.30), radius: 2, y: 1)
        }
        .overlay {
            // em OLED escuro quem constrói presença é a luz na aresta superior
            RoundedRectangle(cornerRadius: Tema.raioCartao, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.07), .clear],
                                   startPoint: .top, endPoint: .bottom),
                    lineWidth: 1
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raioCartao, style: .continuous)
                .stroke(Tema.linha, lineWidth: 0.5)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("cartao-analise")
    }

    private var conteudo: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch cartao {
            case .aviso(let frase):
                corpoCartao(trilho: Tema.aviso) {
                    chip("Pergunta", aviso: false)
                    avisoTexto(frase)
                }
            case .forma(let gesto, let pergunta):
                corpoCartao(trilho: Tema.ambar) {
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
                }
            case .vestida(let gesto, _):
                corpoCartao(trilho: Tema.ambar) {
                    // Auditoria de UX: o âmbar estava no botão que JOGA FORA a
                    // classificação, e o caminho positivo era um chevron sem rótulo.
                    // O funil principal apontava ao contrário (fitts-law +
                    // von-restorff-effect). E "soltar" é ambíguo em pt-BR entre
                    // largar e aplicar — metade tocaria achando que confirma.
                    chip(gesto.nome, aviso: false)
                    Text(gesto.reconhecimento)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 10) {
                        Button("Abrir os campos") { aoAbrirCampos?() }
                            .buttonStyle(CartaoBotaoStyle())
                            .accessibilityIdentifier("abrir-campos")
                            .accessibilityHint("Os campos da forma abrem numa folha; o seu texto fica intacto")
                        Button("Deixar como nota") { sessao.soltarForma() }
                            .buttonStyle(CompactoStyle())
                            .foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("soltar-forma")
                            .accessibilityHint("Desfaz a forma; o seu texto fica intacto")
                    }
                }
            case .expressiva:
                corpoCartao(trilho: Tema.ambar) {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func avisoTexto(_ frase: String) -> some View {
        Text(frase)
            .font(Tema.corpo)
            .foregroundStyle(Tema.tinta)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isStaticText)
    }

    /// UMA anatomia para todos os cartões: trilho na cor do papel, rótulo
    /// fraco, corpo em tinta cheia. Antes, dois cartões irmãos no mesmo slot
    /// tinham gramáticas opostas (law-of-similarity).
    @ViewBuilder
    private func corpoCartao<Conteudo: View>(trilho: Color,
                                             @ViewBuilder _ conteudo: () -> Conteudo) -> some View {
        HStack(alignment: .top, spacing: 12) {
            UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 2)
                .fill(trilho)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 10) {
                conteudo()
            }
        }
    }

    private func chip(_ titulo: String, aviso: Bool) -> some View {
        Text(titulo.uppercased())
            .font(Tema.label)
            .tracking(Tema.trackingLabel)
            .foregroundStyle(aviso ? Tema.aviso : Tema.tintaFraca)
    }
}

/// A secundária NÃO é âmbar: duas saídas em âmbar empatam em peso e o olho não
/// sabe qual é o caminho (von-restorff-effect).
private struct CompactoStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Tema.barra)
            .frame(minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
    }
}

private struct CartaoBotaoStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
            .font(Tema.barra)
            .foregroundStyle(Tema.ambar)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
