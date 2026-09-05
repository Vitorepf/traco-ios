import SwiftUI

struct CartaoAnaliseView: View {
    let cartao: CartaoAnalisar
    let sessao: Sessao
    var aoAbrirCampos: (() -> Void)?
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var tamanhoTexto
    /// ADR 04h: já disse se serviu — as duas saídas somem depois do toque.
    @State private var avaliou = false
    /// Em tamanhos AX o texto rola e as ações NÃO rolam junto: ficam no pé do
    /// cartão, sempre à vista. A revisão da volta 8 mediu, em AX5, "Deixar
    /// como nota" três páginas abaixo, dentro do teto de 380.
    private var acoesNoPe: Bool { tamanhoTexto.isAccessibilitySize }

    /// As duas saídas discretas de todo texto de modelo: serviu / não serviu.
    /// É a entrada da segunda volta do ciclo (a IA aprendendo esta mente).
    @ViewBuilder private func avaliacao(_ texto: String, resposta: Bool = false) -> some View {
        if !avaliou {
            HStack(spacing: 14) {
                Button("serviu") {
                    if resposta { sessao.avaliarResposta(texto, serviu: true) } else { sessao.avaliarPergunta(texto, serviu: true) }
                    avaliou = true
                }
                .accessibilityIdentifier("serviu")
                Button("não serviu") {
                    if resposta { sessao.avaliarResposta(texto, serviu: false) } else { sessao.avaliarPergunta(texto, serviu: false) }
                    avaliou = true
                }
                .accessibilityIdentifier("nao-serviu")
            }
            .font(Tema.label)
            .foregroundStyle(Tema.tintaFraca)
            .buttonStyle(CompactoStyle())
            .accessibilityHint("Diz ao Traço se esta pergunta valeu — ele aprende com você")
        }
    }

    var body: some View {
        // AX: em Dynamic Type grande o texto cresce — o cartão rola por dentro
        // e nunca cobre a topbar (o resto da UI continua alcançável).
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                conteudo
            }
            if acoesNoPe {
                VStack(alignment: .leading, spacing: 0) { acoes }
                    .padding(.leading, 15) // alinha com o texto: trilho 3 + vão 12
                    // o pé não cede: sem isto o VStack o comprimia e "Abrir os
                    // campos" virava "Abrir os ca…" (visto em AX5, 05/09)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        // em AX o teto sobe: duas ações de duas linhas (≈256 pt) mais três
        // linhas de texto que rolam; em tamanhos normais o cartão é o que era
        .frame(maxHeight: acoesNoPe ? 480 : 380)
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Tema.raioCartao, style: .continuous)
                .fill(Tema.superficieAlta)
                // material de verdade: sombra ambiente + sombra de contato
                .shadow(color: Tema.sombraFlutuante, radius: 16, y: 6)
                .shadow(color: Tema.sombraContato, radius: 2, y: 1)
        }
        .overlay {
            // em OLED escuro quem constrói presença é a luz na aresta superior
            RoundedRectangle(cornerRadius: Tema.raioCartao, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [Tema.luzBorda, .clear],
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

    /// ADR o, e a lei do dono é incondicional: "se eu deixar uma pergunta
    /// clara na nota, ela responde". Mover o "?" para o ramo do silêncio
    /// (03/set) fez a forma tomar o rodapé e a pergunta ficar INALCANÇÁVEL —
    /// a varredura pegou. A precedência absoluta do "?" também era errada
    /// (bloqueava a forma para sempre): as duas coisas cabem no mesmo cartão.
    /// A forma manda no cartão; a pergunta fica aqui embaixo, discreta e
    /// sempre a um toque.
    @ViewBuilder private var botaoPergunta: some View {
        if sessao.perguntaNaNota != nil {
            Button("Perguntar à sábia") { sessao.perguntarASabia(no: context) }
                .buttonStyle(CompactoStyle())
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("perguntar-sabia")
                .accessibilityHint("A resposta vem aqui, nunca na nota")
        }
    }

    private var conteudo: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch cartao {
            case .aviso(let frase):
                corpoCartao(trilho: Tema.aviso) {
                    // o cartão de recusa dizia "Pergunta" no kicker — papel
                    // errado com trilho vermelho (visto no iPhone do dono,
                    // 01/set). Aviso se chama Aviso (reforma da linguagem).
                    chip("Aviso", aviso: true)
                    avisoTexto(frase)
                }
            case .forma(let gesto, let pergunta):
                corpoCartao(trilho: Tema.ambar) {
                    chip(gesto.nome, aviso: false)
                    Text(pergunta)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .vestida(let gesto, let perguntaTemplate):
                corpoCartao(trilho: Tema.ambar) {
                    // Auditoria de UX: o âmbar estava no botão que JOGA FORA a
                    // classificação, e o caminho positivo era um chevron sem rótulo.
                    // O funil principal apontava ao contrário (fitts-law +
                    // von-restorff-effect). E "soltar" é ambíguo em pt-BR entre
                    // largar e aplicar — metade tocaria achando que confirma.
                    chip(gesto.nome, aviso: false)
                    if sessao.dominio != nil || sessao.dominioTravado {
                        // ADR 05d: menu, não apagar
                        ChipDominio(atual: sessao.dominio, travado: sessao.dominioTravado,
                                    aoEscolher: { sessao.escolherDominioNaPagina($0) })
                    }
                    Text(gesto.reconhecimento)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                    // ADR 03h: a pergunta viajava no cartão e era DESCARTADA
                    // aqui — o caminho automático (§17.3) é o comum, e nele o
                    // autor abria a forma sem ouvir pergunta nenhuma. Agora a
                    // da sábia entra quando chega; a do template segura o lugar.
                    Text(sessao.perguntaDaSabia ?? perguntaTemplate)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("pergunta-da-forma")
                    if let q = sessao.perguntaDaSabia { avaliacao(q) }
                }
            case .pergunta(let q):
                corpoCartao(trilho: Tema.ambar) {
                    chip("Sua pergunta", aviso: false)
                    Text(q)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .sabiaPensando:
                corpoCartao(trilho: Tema.ambar) {
                    chip("A sábia", aviso: false)
                    HStack(spacing: 10) {
                        ProgressView().tint(Tema.tintaSuave)
                        Text("pensando…")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                    }
                }
            case .resposta(let q, let texto):
                corpoCartao(trilho: Tema.ambar) {
                    chip("A sábia, sobre: \(q)", aviso: false)
                    Text(texto)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("resposta-sabia")
                    if !sessao.notasNaPergunta.isEmpty || sessao.notasLidasNaPergunta > 0 {
                        // honestidade sobre a rede, como o Perfil faz: o autor
                        // vê QUAIS notas foram junto INTEIRAS — e quantas do
                        // caderno foram lidas para achar os ecos. Dizer só as
                        // três que voltaram, com quarenta viajando, é meia
                        // verdade (varredura 04/set).
                        Text(sessao.divulgacaoDaPergunta)
                            .font(Tema.label)
                            .foregroundStyle(Tema.tintaFraca)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("notas-na-pergunta")
                    }
                    avaliacao(texto, resposta: true)
                }
            case .vestido:
                corpoCartao(trilho: Tema.ambar) {
                    chip("Vestido", aviso: false)
                    Text("As suas palavras, com forma. Nenhuma mudou.")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .semConta:
                corpoCartao(trilho: Tema.aviso) {
                    chip("Sem conta", aviso: true)
                    avisoTexto("a sábia " + Sabia.porOndeEmPalavras + ". Sem ela, tudo o mais continua.")
                }
            case .expressiva:
                corpoCartao(trilho: Tema.ambar) {
                    chip("Escrita expressiva", aviso: false)
                    Text("Isto pede 15 minutos — fato E sentimento, sobre o mesmo evento. Ao fim, a nota tranca e não se relê.")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fechar() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { sessao.cartao = nil }
    }

    /// As saídas de cada cartão, num lugar só: no corpo em tamanhos normais
    /// (dentro do trilho, como sempre), no pé em AX (`acoesNoPe`).
    @ViewBuilder private var acoes: some View {
        switch cartao {
        case .aviso, .sabiaPensando:
            EmptyView()
        case .forma(let gesto, _):
            Button("Abrir a forma \(gesto.nome)") {
                sessao.usarForma(gesto)
            }
            .buttonStyle(CartaoBotaoStyle())
            .accessibilityHint("Campos vazios nascem abaixo do seu texto")
            botaoPergunta
        case .vestida:
            ladoALado {
                // ADR 04r: abrir os campos é ATO — é aqui que a sábia instiga
                Button("Abrir os campos") { sessao.instigarSePreciso(); aoAbrirCampos?() }
                    .buttonStyle(CartaoBotaoStyle())
                    .accessibilityIdentifier("abrir-campos")
                    .accessibilityHint("Os campos da forma abrem numa folha; o seu texto fica intacto")
                Button("Deixar como nota") { sessao.soltarForma() }
                    .buttonStyle(CompactoStyle())
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("soltar-forma")
                    .accessibilityHint("Desfaz a forma; o seu texto fica intacto")
            }
            botaoPergunta
        case .pergunta:
            Button("Perguntar à sábia") { sessao.perguntarASabia(no: context) }
                .buttonStyle(CartaoBotaoStyle())
                .accessibilityIdentifier("perguntar-sabia")
                .accessibilityHint("A resposta vem aqui, nunca na nota")
        case .resposta(_, let texto):
            ladoALado {
                Button("Copiar") {
                    UIPasteboard.general.string = texto
                    Toque.leve()
                }
                .buttonStyle(CartaoBotaoStyle())
                .accessibilityHint("Vai para a área de transferência; colar é gesto seu")
                Button("Fechar", action: fechar)
                    .buttonStyle(CompactoStyle())
                    .foregroundStyle(Tema.tintaSuave)
            }
        case .vestido(let antes):
            ladoALado {
                Button("Desfazer") { sessao.desfazerVestir(antes) }
                    .buttonStyle(CartaoBotaoStyle())
                    .accessibilityIdentifier("desfazer-vestir")
                Button("Ficar assim", action: fechar)
                    .buttonStyle(CompactoStyle())
                    .foregroundStyle(Tema.tintaSuave)
            }
        case .semConta:
            Button("Fechar", action: fechar)
                .buttonStyle(CompactoStyle())
                .foregroundStyle(Tema.tintaSuave)
        case .expressiva:
            Button("Começar o timer") {
                sessao.comecarExpressiva(no: context)
            }
            .buttonStyle(CartaoBotaoStyle())
        }
    }

    /// Duas saídas lado a lado; em AX, uma por linha (não cabem juntas).
    private func ladoALado<Conteudo: View>(@ViewBuilder _ conteudo: () -> Conteudo) -> some View {
        let leiaute = acoesNoPe
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(spacing: 10))
        return leiaute { conteudo() }
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
                if !acoesNoPe { acoes }
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
            .alvo()
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
            .foregroundStyle(Tema.ambarTinta)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
