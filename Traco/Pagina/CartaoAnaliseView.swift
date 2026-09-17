import SwiftUI

struct CartaoAnaliseView: View {
    let cartao: CartaoAnalisar
    let sessao: Sessao
    var aoAbrirCampos: (() -> Void)?
    /// O autor está a ESCREVER (teclado de pé). Aí a página é dele: o cartão
    /// vale uma linha, e a prosa abre a um toque (ADR 05y, correção do G4).
    var recolhido = false
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var tamanhoTexto
    /// O que sobra da tela para o encaixe, medido pelo Caderno (ADR 05y).
    @Environment(\.tetoDoEncaixe) private var tetoDoEncaixe
    /// ADR 04h: já disse se serviu — as duas saídas somem depois do toque.
    @State private var avaliou = false
    /// O autor pediu a prosa com o teclado de pé. Nasce falso a cada CASO novo
    /// de cartão, porque a identidade do cartão é o caso (`casoDoCartao`).
    @State private var abertoNoTeclado = false
    /// O texto do cartão ainda tem linhas abaixo da dobra (o degradê do pé).
    @State private var textoRola = false
    /// Em tamanhos AX as duas saídas ficam uma por linha e o teto sobe. As
    /// ações vivem no pé do cartão em TODO tamanho (a V8 fazia só em AX; em
    /// `large` uma resposta longa da sábia escondia Copiar e Fechar).
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
            .buttonStyle(.compacto)
            // A frase antiga ("ele aprende com você") era alegação de eficácia sem
            // dono na tela. `Degraus.ajuste` é um contador com memória de DOIS: as
            // duas últimas respostas DESTA forma, e só se concordarem, movem o
            // degrau ±1 (preso a 0–4). Dizer o mecanismo dá ao autor a razão de
            // apertar o botão, que a promessa vaga não dava (auditoria da voz do
            // app, trilha Métodos, 06/09).
            .accessibilityHint("Diz ao Traço se esta pergunta valeu — duas respostas iguais seguidas mudam o que ele cobra nesta forma")
        }
    }

    /// O cartão que traz PROSA recolhe-se enquanto o autor escreve. Quatro não:
    /// o AVISO e o "sem conta" (esconder falha para limpar a tela é o que o
    /// contrato proíbe), o "pensando…" (esconder a espera é a mesma coisa, e já
    /// é uma linha) e a RESPOSTA DA SÁBIA — essa o autor PEDIU, e entregá-la
    /// recolhida seria esconder o resultado de quem o mandou vir (curva-zero
    /// §2). O teto do encaixe é que a segura: o texto dela rola lá dentro.
    /// Fora do `body` para ter teste.
    static func podeRecolher(_ cartao: CartaoAnalisar) -> Bool {
        switch cartao {
        // o CONSELHO (ADR 16h) chega na página em branco, com o cursor
        // posto e ninguém escrevendo: recolhido, escondia mestre, vídeo e
        // minuto (visto no Air); a primeira tecla da nota seguinte já o fecha
        case .aviso, .semConta, .sabiaPensando, .resposta, .conselho: false
        default: true
        }
    }

    private var podeRecolher: Bool { Self.podeRecolher(cartao) }

    /// A frase da espera. Fora do `body` para ter teste, como `podeRecolher`.
    /// Os primeiros segundos não levam número: até aí a espera é a de sempre e
    /// um contador só apressaria quem não estava com pressa. Do quarto segundo
    /// em diante o número aparece e anda — é o que separa "está pensando" de
    /// "travou", e a medida diz que ele vai passar dos trinta (ADR 09n).
    static func fraseDaEspera(desde: Date, agora: Date) -> String {
        Espera.linha(Espera.aSabiaPensa, desde: desde, agora: agora)
    }

    /// A linha: o mesmo trilho âmbar do cartão inteiro e a frase que importa,
    /// cortada numa linha. Sem rótulo em cima — a frase já diz qual é a forma,
    /// e cada linha a mais aqui é uma linha a menos de papel.
    private func linhaRecolhida<Rotulo: View>(@ViewBuilder _ envolve: (AnyView) -> Rotulo) -> some View {
        envolve(AnyView(
            // só o âmbar chega aqui: aviso e "sem conta" não recolhem
            corpoCartao(trilho: Tema.ambar) {
                HStack(spacing: 8) {
                    Text(resumo)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer(minLength: 8)
                    Image(systemName: acoesNoPe ? "ellipsis" : "chevron.up")
                        .font(Tema.label)
                        .foregroundStyle(Tema.tintaFraca)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        ))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(kicker). \(resumo)")
        .accessibilityIdentifier("cartao-recolhido")
    }

    /// Fora de AX, a linha ABRE A PROSA no lugar: o teclado não se mexe e o pé
    /// não sai do sítio — o encaixe só cresce até o teto que o papel lhe deixa,
    /// e o texto do cartão rola lá dentro, como já rolava. Derrubar o teclado
    /// aqui foi tentado e filmado: a barra do pé viaja 334 pt enquanto o cartão
    /// cresce, e os dois ficam legíveis na mesma faixa por ~165 ms — a classe A1
    /// outra vez. Não se mexe no teclado.
    @ViewBuilder private var portaDaProsa: some View {
        if acoesNoPe {
            // em AX as duas saídas não cabem ao lado da linha e a prosa não cabe
            // no que sobra: a linha vira MENU, o mesmo desenho que o pé da
            // página já usa em AX ("Mais ações da nota"). A prosa inteira fica
            // para quando o teclado descer — arrastar o papel já o desce.
            Menu {
                acoes
            } label: {
                linhaRecolhida { $0 }
            }
            .accessibilityHint("Abre as saídas desta forma")
        } else {
            Button { abertoNoTeclado = true } label: {
                linhaRecolhida { $0 }
            }
            .buttonStyle(.discreto)
            .accessibilityHint("Mostra o texto inteiro do cartão; o seu texto fica intacto")
        }
    }

    var body: some View {
        // recolher e abrir é troca de VIEW no mesmo encaixe: CORTA. Sem isto o
        // SwiftUI dissolvia a linha sobre o corpo do cartão nas mesmas linhas —
        // a classe A1 outra vez, agora no gatilho novo (05y).
        if case .conselho(let c) = cartao {
            // dono, 16/09: o conselho é uma CAPA própria (CartaoDoConselhoView),
            // sem trilho, sem rolagem de cartão e sem «Fechar» no pé
            CartaoDoConselhoView(voz: c.regra, fechar: fechar, teto: tetoDoEncaixe ?? .infinity,
                                 sobre: Sessao.buscar(uuid: c.nota, no: context)?.tituloNaLista)
                // visto é o que foi desenhado, não o que foi oferecido
                .onAppear { sessao.conselhoApareceu(c) }
                .accessibilityIdentifier("cartao-analise")
                .transition(.identity)
        } else if recolhido, podeRecolher, !abertoNoTeclado {
            cartaoRecolhido.transition(.identity)
        } else {
            cartaoInteiro.transition(.identity)
        }
    }

    /// Recolhido: a linha, e as saídas logo abaixo dela. Em tamanho AX as
    /// saídas ficam uma por linha e não cabem com o teclado de pé — ali elas
    /// vivem no menu da própria linha (custo declarado na 05y, o mesmo desenho
    /// do pé da página em AX). Fora de AX nada se esconde: só a PROSA é que
    /// fica atrás do toque.
    private var cartaoRecolhido: some View {
        VStack(alignment: .leading, spacing: 10) {
            portaDaProsa
            if temAcoes, !acoesNoPe {
                VStack(alignment: .leading, spacing: 0) { acoes }
                    .padding(.leading, 15) // alinha com o texto: trilho 3 + vão 12
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        // recolhido o cartão vale a sua altura ideal e nada mais: sem isto o
        // trilho (uma Shape, que aceita toda a altura oferecida) esticava a
        // linha e abria um vão de ~58 pt entre ela e as saídas
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cartao(.flutuante, recuo: [])
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("cartao-analise")
    }

    /// O teto do ambiente menos o que o próprio cartão gasta em volta do
    /// texto: 16+16 de recheio mais os 12 que a Página põe embaixo dele. Nunca
    /// abaixo de 96 — um cartão de 40 pt não é um cartão, é um risco.
    private var tetoParaOTexto: CGFloat {
        guard let teto = tetoDoEncaixe else { return .infinity }
        return max(96, teto - 44)
    }

    private var cartaoInteiro: some View {
        // o TEXTO rola quando cresce (Dynamic Type, resposta longa) e nunca
        // cobre a topbar; as ações não rolam: ficam no pé, sempre à vista
        VStack(alignment: .leading, spacing: 10) {
            ScrollView { conteudo }
                .onScrollGeometryChange(for: Bool.self) { g in
                    g.contentOffset.y + g.containerSize.height < g.contentSize.height - 1
                } action: { _, rola in textoRola = rola }
                // o sinal de que há mais texto: um degradê no pé, só enquanto há
                // (G4 da V8: o corte seco a meio glifo não dizia nada)
                .overlay(alignment: .bottom) {
                    if textoRola {
                        LinearGradient(colors: [.clear, Tema.superficie], startPoint: .top, endPoint: .bottom)
                            .frame(height: 24)
                            .allowsHitTesting(false)
                    }
                }
            if temAcoes {
                VStack(alignment: .leading, spacing: 0) { acoes }
                    .padding(.leading, 15) // alinha com o texto: trilho 3 + vão 12
                    // o pé não cede: sem isto o VStack o comprimia e "Abrir os
                    // campos" virava "Abrir os ca…" (visto em AX5, 05/09)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        // em AX o teto sobe: duas ações de duas linhas (≈232 pt) mais três
        // linhas de texto que rolam — e para aí, porque o pé da página (um
        // menu em AX) fica embaixo do cartão, não no lugar dele. E acima de
        // tudo manda o que SOBRA da tela (05y): sem isto o teto era absoluto e
        // quem pagava era o papel; com ele, é o texto do cartão que rola.
        .frame(maxHeight: min(acoesNoPe ? 440 : 380, tetoParaOTexto))
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cartao(.flutuante, recuo: [])
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
            Button("Perguntar à Sábia") { sessao.perguntarASabia(no: context) }
                .buttonStyle(.compacto)
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("perguntar-sabia")
                .accessibilityHint("A resposta vem aqui, nunca na nota")
        }
    }

    /// O rótulo do cartão, num lugar só: a linha recolhida e o cartão inteiro
    /// dizem a MESMA coisa (law-of-similarity — e uma fonte, não duas).
    private var kicker: String {
        switch cartao {
        case .aviso: "Aviso"
        case .forma(let gesto, _): gesto.nome
        case .vestida(let gesto, _): gesto.nome
        case .pergunta: "Sua pergunta"
        // §14: a pessoa não pergunta a uma "sábia" — o título é a pergunta
        // dela, e quem o desenha é o `CartaoDeResposta`. Este só serve à
        // linha recolhida, que estes dois cartões nunca são (`podeRecolher`).
        case .sabiaPensando: "Sua pergunta"
        case .resposta: "Sua pergunta"
        case .vestido: "Vestido"
        case .semConta: "Sem conta"
        case .expressiva: "Escrita expressiva"
        case .conselho: "Conselho"
        }
    }

    /// O que a linha recolhida mostra do corpo: a frase que importa em cada
    /// caso, cortada numa linha. Nada de resumo inventado — é o texto do
    /// cartão, o mesmo que abre embaixo.
    private var resumo: String {
        switch cartao {
        case .aviso(let frase): frase
        case .forma(_, let pergunta): pergunta
        case .vestida(let gesto, _): gesto.reconhecimento
        case .pergunta(let q): q
        case .sabiaPensando(_, let desde): Self.fraseDaEspera(desde: desde, agora: .now)
        case .resposta(_, let texto): texto
        case .vestido: "As suas palavras, com forma. Nenhuma mudou."
        case .semConta: "a Sábia " + Sabia.porOndeEmPalavras + "."
        case .expressiva: "Isto pede 15 minutos — fato E sentimento, sobre o mesmo evento."
        case .conselho(let c): c.regra.regra
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
                    chip(kicker, aviso: true)
                    avisoTexto(frase)
                }
            case .forma(_, let pergunta):
                corpoCartao(trilho: Tema.ambar) {
                    chip(kicker, aviso: false)
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
                    chip(kicker, aviso: false)
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
                    chip(kicker, aviso: false)
                    Text(q)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .sabiaPensando(let q, let desde):
                // ADR 09n desenhou aqui o relógio da espera; a DIRETRIZ §14
                // levou-o para a superfície ÚNICA da resposta, com a pergunta
                // da pessoa como título e a saída ao lado do tempo. A saída
                // que estava no pé (`acoes`) mudou-se para cá com ele.
                corpoCartao(trilho: Tema.ambar) {
                    CartaoDeResposta(titulo: q, pensandoDesde: desde,
                                     cancelar: { sessao.pararDeEsperarASabia() },
                                     rota: "sabia") { EmptyView() }
                }
            case .resposta(let q, let texto):
                corpoCartao(trilho: Tema.ambar) {
                    // honestidade sobre a rede, como o Perfil faz: o autor vê
                    // QUAIS notas foram junto INTEIRAS — e quantas do caderno
                    // foram lidas para achar os ecos (varredura 04/set). A
                    // linha fechada é a divulgação inteira; aberta, os títulos.
                    CartaoDeResposta(
                        titulo: q,
                        fontes: sessao.notasNaPergunta.map { .init(id: nil, titulo: $0) },
                        resumoDasFontes: sessao.divulgacaoDaPergunta,
                        retorno: avaliou ? nil : { serviu in
                            sessao.avaliarResposta(texto, serviu: serviu)
                            avaliou = true
                        },
                        avaliada: avaliou,
                        rota: "sabia"
                    ) {
                        Text(texto).textSelection(.enabled)
                    }
                }
            case .vestido:
                corpoCartao(trilho: Tema.ambar) {
                    chip(kicker, aviso: false)
                    Text("As suas palavras, com forma. Nenhuma mudou.")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .semConta:
                corpoCartao(trilho: Tema.aviso) {
                    chip(kicker, aviso: true)
                    avisoTexto("a Sábia " + Sabia.porOndeEmPalavras + ". Sem ela, tudo o mais continua.")
                }
            case .expressiva:
                corpoCartao(trilho: Tema.ambar) {
                    chip(kicker, aviso: false)
                    Text("Isto pede 15 minutos — fato E sentimento, sobre o mesmo evento. Ao fim, a nota tranca e não se relê.")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .conselho:
                // ADR 2026-09-16h: a capa do conselho não passa por aqui (`body`)
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fechar() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { sessao.cartao = nil }
    }

    private var temAcoes: Bool {
        switch cartao {
        case .aviso, .sabiaPensando: false
        default: true
        }
    }

    /// As saídas de cada cartão, num lugar só: o pé.
    @ViewBuilder private var acoes: some View {
        switch cartao {
        case .aviso:
            EmptyView()
        case .sabiaPensando:
            // ADR 09n: a saída existe e não perde nada — a pergunta volta ao
            // cartão com "Perguntar à sábia" a um toque. Desde a §14 ela mora
            // na `Espera`, ao lado do tempo, e não no pé.
            EmptyView()
        case .forma(let gesto, _):
            Button("Abrir a forma \(gesto.nome)") {
                sessao.usarForma(gesto)
            }
            .buttonStyle(.primario(alinhamento: .leading))
            .accessibilityHint("Campos vazios nascem abaixo do seu texto")
            botaoPergunta
        case .vestida:
            // Laço de 14/09: a forma já vestiu e os campos já estão na folha.
            // "Preencher os campos" pedia um toque para chegar onde o dedo já
            // chega; a única decisão que sobra é desfazer, e ela pesa pouco.
            Button("Desfazer") { sessao.soltarForma() }
                .buttonStyle(.compacto)
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("soltar-forma")
                .accessibilityHint("Desfaz a forma; o seu texto fica intacto")
            botaoPergunta
        case .pergunta:
            Button("Perguntar à Sábia") { sessao.perguntarASabia(no: context) }
                .buttonStyle(.primario(alinhamento: .leading))
                .accessibilityIdentifier("perguntar-sabia")
                .accessibilityHint("A resposta vem aqui, nunca na nota")
        case .resposta(_, let texto):
            ladoALado {
                Button("Copiar") {
                    UIPasteboard.general.string = texto
                    Toque.leve()
                }
                .buttonStyle(.primario(alinhamento: .leading))
                .accessibilityHint("Vai para a área de transferência; colar é gesto seu")
                Button("Fechar", action: fechar)
                    .buttonStyle(.compacto)
                    .foregroundStyle(Tema.tintaSuave)
            }
        case .vestido(let antes):
            ladoALado {
                Button("Desfazer") { sessao.desfazerVestir(antes) }
                    .buttonStyle(.primario(alinhamento: .leading))
                    .accessibilityIdentifier("desfazer-vestir")
                Button("Ficar assim", action: fechar)
                    .buttonStyle(.compacto)
                    .foregroundStyle(Tema.tintaSuave)
            }
        case .semConta:
            Button("Fechar", action: fechar)
                .buttonStyle(.compacto)
                .foregroundStyle(Tema.tintaSuave)
        case .expressiva:
            Button("Começar o timer") {
                sessao.comecarExpressiva(no: context)
            }
            .buttonStyle(.primario(alinhamento: .leading))
        case .conselho:
            // a saída mora na capa (✕), sem escolha nem «serviu» (ADR 14a e 16e)
            EmptyView()
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
            VStack(alignment: .leading, spacing: 10) { conteudo() }
        }
    }

    private func chip(_ titulo: String, aviso: Bool) -> some View {
        Text(titulo).rotulo(aviso ? Tema.aviso : Tema.tintaFraca)
    }
}
