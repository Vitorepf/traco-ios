import SwiftData
import UIKit
import SwiftUI

struct NotasView: View {
    @Bindable var sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var faseDaCena
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var tamanhoTexto
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]
    @Query private var trabalhos: [Trabalho]
    /// ADR 09c: a conversa vive na `Sessao` — em `@State` ela morria toda vez
    /// que a `RaizView` recriava esta view ao trocar de aba.
    private var conversaNotas: ConversaNotas { sessao.conversaNotas }
    /// O que FILTRA a lista. É outro texto que o da pergunta (§14: duas
    /// intenções, dois lugares): a busca é uma linha da lista; a pergunta é a
    /// linha "?" da folha.
    private var busca: String {
        get { conversaNotas.busca }
        nonmutating set { conversaNotas.busca = newValue }
    }
    /// ADR 04n: as notas próximas da busca que a busca por letras não achou.
    @State private var peloSentido: [Nota] = []
    @State private var tarefaSentido: Task<Void, Never>?
    @State private var filtro: FiltroNotas?
    @State private var filtroDominio: Dominio?
    @State private var versoesDe: Nota?
    @State private var redeDe: Nota?
    @State private var serieDe: UUID?
    @State private var contextoURL: URL?
    @State private var ordem: OrdemNotas = .criadaEm
    @State private var ditado = Ditado()
    /// Q4: seleção múltipla. Vazio = modo normal; não-vazio = modo lote.
    @State private var escolhidas: Set<UUID> = []
    @State private var confirmarLote = false
    @State private var mostrarTrabalhos = false
    @FocusState private var perguntaFocada: Bool

    var body: some View {
        telaNotas
            // ADR 04n: a busca por letras é a primeira; o índice de sentido
            // responde logo atrás, com o que ela não achou
            .onChange(of: busca) { _, nova in
                // ADR 10i: a segunda porta do mesmo gesto — quem escreve "?"
                // na busca está a perguntar, como na página. A linha da busca
                // devolve o que já tinha e a folha abre com a pergunta começada.
                if nova.hasPrefix("?") {
                    busca = ""
                    conversaNotas.entrada = String(nova.dropFirst()).trimmingCharacters(in: .whitespaces)
                    abrirPergunta()
                    return
                }
                procurarPeloSentido(nova, entre: filtradas)
            }
            .onChange(of: fontesVigentesDaConversa) { _, _ in revalidarConversa() }
            .onChange(of: faseDaCena) { _, fase in
                if fase == .active { revalidarConversa() }
            }
            .onAppear { revalidarConversa() }
            .onChange(of: sessao.aba) { _, aba in
                if aba != .notas { conversaNotas.interromper() }
            }
            .onDisappear {
                conversaNotas.interromper()
                tarefaSentido?.cancel()
            }
    }

    private var telaNotas: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                topbar
                // §14 (complemento): a resposta é uma FOLHA do Traço na área
                // da lista, não um cartão flutuando por cima do que a pessoa
                // escreveu. Com conversa, a lista e a sua regência cedem o
                // lugar; Fechar (um só, na topbar) devolve a lista.
                // ADR 10i: a folha também abre VAZIA, só com a linha "?" — é
                // a entrada. O pé da tela fica livre: nada permanente ali.
                if conversaNotas.modoPergunta {
                    conversaDaSabia
                } else {
                    regencia
                    // Dono, 14/09: buscar e perguntar moram em cima da pílula,
                    // num campo flutuante como o do calendário — digitar filtra,
                    // enviar pergunta, o microfone dita. O "buscar" do topo e a
                    // marca "?" saíram: é um gesto só, no lugar do polegar.
                    // Como no calendário, o campo FLUTUA sobre a lista (a última
                    // linha passa por baixo), em vez de cortá-la em cheio.
                    // ZStack de propósito: `lista` é um Group com dois ramos
                    // (vazio / cheio) e um overlay no Group nasce em CADA ramo —
                    // quando a busca chegava a zero, o campo era recriado no
                    // meio da palavra e perdia o foco e as teclas seguintes.
                    ZStack { lista }.overlay(alignment: .bottom) { campoDeBuscaEPergunta }
                }
            }
            .animation(Tema.corte(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: conversaNotas.modoPergunta)
            .animation(Tema.corte(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: conversaNotas.estado)
            .animation(Tema.corte(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: conversaNotas.semModelo)
            .transaction { if reduceMotion { $0.disablesAnimations = true } }
            .onChange(of: conversaNotas.trocas.count) { antes, depois in
                if depois > antes {
                    Toque.suave()
                    AccessibilityNotification.Announcement("A sábia respondeu.").post()
                }
            }
            // VoiceOver: o cartão sobe sozinho no pé da tela — quem não vê precisa ouvir
            .onChange(of: conversaNotas.estado) { _, estado in
                switch estado {
                case .pensando: AccessibilityNotification.Announcement("A sábia está pensando.").post()
                case .falhou: AccessibilityNotification.Announcement("A sábia não respondeu. Perguntar de novo está ao lado da pergunta.").post()
                case .recolhida: AccessibilityNotification.Announcement("A resposta foi recolhida porque uma fonte mudou ou deixou de estar acessível. Você pode perguntar de novo.").post()
                default: break
                }
            }
            .onChange(of: conversaNotas.semModelo) { _, sem in
                if sem { AccessibilityNotification.Announcement("A sábia " + Sabia.porOndeEmPalavras + ". A busca continua.").post() }
            }
        }
        .sheet(isPresented: $mostrarTrabalhos) { TrabalhosView() }
    }

    /// ADR 10i: o gesto de perguntar. A folha abre com a linha "?" em branco
    /// e o teclado de pé; a busca que estava a ser escrita fica onde estava.
    private func abrirPergunta() {
        conversaNotas.perguntando = true
        Toque.selecao()
    }

    // MARK: ADR 05e — perguntar pela barra


    private var conversa: [Sessao.TrocaNasNotas] { conversaNotas.trocas }
    private var pensando: Bool { conversaNotas.pensando }

    /// Lê os campos observáveis das dependências, não só a identidade da
    /// lista: selar/editar a mesma Nota também precisa disparar revalidação.
    private var fontesVigentesDaConversa: [FonteNotas] {
        let ids = Set(conversa.flatMap(\.dependencias).map(\.id))
        return notas.filter { ids.contains($0.uuid) }.compactMap(Sessao.fonteParaPergunta)
    }

    private func revalidarConversa() {
        conversaNotas.revalidarFontes { Sessao.dependenciasValidas($0, no: context) }
    }

    private func plantarObraDaGuarda() {
        guard let nome = conversaNotas.obraParaPlantar else { return }
        if sessao.plantarObra(nome, no: context) != nil {
            conversaNotas.obraParaPlantar = nil
        }
    }

    private func perguntar() {
        guard conversaNotas.modoPergunta else { return }
        conversaNotas.perguntar(disponivel: Sabia.disponivel) { pergunta, anteriores in
            await sessao.responderNasNotas(pergunta, conversa: anteriores, no: context)
        }
    }

    private func repetirPergunta() {
        conversaNotas.repetir(disponivel: Sabia.disponivel) { pergunta, anteriores in
            await sessao.responderNasNotas(pergunta, conversa: anteriores, no: context)
        }
    }

    private func fecharConversa() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { conversaNotas.fechar() }
    }

    /// A nota que foi junto abre como da lista: queimada e trancada com as
    /// mesmas guardas. A conversa fica na sessão (ADR 09c) e está aqui na volta.
    private func abrirFonte(_ id: UUID) {
        guard let nota = notas.first(where: { $0.uuid == id }) else { return }
        abrirDaLista(nota)
    }

    /// A CONVERSA sem balão e sem caixa (REFERENCIA-HERMES §6): cada mensagem
    /// é uma linha de autor — VOCÊ em âmbar, SÁBIA no verde dela — e, embaixo,
    /// o texto puro em largura inteira; entre uma e outra, um fio recuado,
    /// alinhado com o texto. A resposta vem inteira, sem teto e sem dobra; as
    /// trocas anteriores ficam acima, na ordem — perguntar de novo continua,
    /// não recomeça. Só a última leva as fontes e o retorno. Enquanto a sábia
    /// pensa, a pergunta já está na folha e a espera é a CÁPSULA colada acima
    /// do campo (§8); se não respondeu, a falha é a mensagem da SÁBIA, com
    /// "Perguntar de novo" ao lado. O que a sábia diz passa pela mesma
    /// `CartaoDeResposta` da Página e da Lente — nenhuma tela desenha a IA por
    /// conta própria (§15).
    private var conversaDaSabia: some View {
        let emEspera: String? = if case .pensando(let p, _) = conversaNotas.estado { p } else { nil }
        let aRepetir = conversaNotas.perguntaParaRepetir
        return VStack(spacing: 0) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(conversa.enumerated()), id: \.offset) { i, troca in
                    let ultima = i == conversa.count - 1 && aRepetir == nil
                    let retorno: ((Bool) -> Void)? = ultima && !conversaNotas.avaliadas.contains(troca.resposta) ? { serviu in
                        Sinais.resposta(troca.resposta, forma: nil, serviu: serviu)
                        conversaNotas.avaliadas.insert(troca.resposta)
                        Toque.leve()
                    } : nil
                    mensagemDaPessoa(troca.pergunta, fio: i > 0)
                    mensagem(.sabia, fio: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            CartaoDeResposta(
                                titulo: nil,
                                fontes: ultima ? conversaNotas.fontes.map { .init(id: $0.id, titulo: $0.titulo) } : [],
                                abrirFonte: abrirFonte,
                                retorno: retorno,
                                avaliada: ultima && conversaNotas.avaliadas.contains(troca.resposta),
                                rota: "sabia-notas"
                            ) {
                                // ADR 02o: a resposta chega ao lado, nunca na nota. Levar
                                // um trecho para a nota é ato do autor — selecionar e
                                // copiar —, com as palavras dele.
                                Text(troca.resposta).textSelection(.enabled)
                            }
                            if ultima, conversaNotas.obraParaPlantar != nil {
                                Button("Plantar esta obra", action: plantarObraDaGuarda)
                                    .font(Tema.meta)
                                    .foregroundStyle(Tema.ambarTinta)
                                    .alvo()
                                    .buttonStyle(.discreto)
                                    .accessibilityIdentifier("plantar-sabia-notas")
                            }
                        }
                    }
                }
                if let pergunta = emEspera ?? aRepetir {
                    mensagemDaPessoa(pergunta, fio: !conversa.isEmpty)
                }
                if let pergunta = aRepetir {
                    mensagem(.sabia, fio: true) {
                        CartaoDeResposta(
                            titulo: nil,
                            // a rota das Notas é só Grok (Politica, ADR 09v): sem
                            // a conta, a frase é a da Politica e a saída é o Perfil —
                            // "Falta a conta" com "Perguntar de novo" enganava, e o
                            // Perfil dizia "modelo do aparelho pronto" (vídeo 14/09)
                            falhou: conversaNotas.estado == .recolhida(pergunta)
                                ? "A resposta foi recolhida porque uma fonte mudou ou deixou de estar acessível."
                                : conversaNotas.estado == .interrompida(pergunta)
                                    ? "você parou de esperar."
                                    : !ContaGrok.ligada ? Politica.semProvedor(.responderNasNotas)
                                    : Grok.avisoDaFalha(),
                            repetir: ContaGrok.ligada ? repetirPergunta : { sessao.irPara(.perfil, no: context) },
                            rotuloDoRepetir: ContaGrok.ligada ? "Perguntar de novo" : "Entrar com a conta Grok",
                            rota: "sabia-notas"
                        ) { EmptyView() }
                    }
                }
                if conversaNotas.semModelo {
                    LinhaDeEstado("a sábia " + Sabia.porOndeEmPalavras + ". Sem ela, a busca continua.", .semConta)
                        .padding(.vertical, 16)
                        .accessibilityIdentifier("sem-conta-notas")
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, Tema.margem)
            // uma folha, lida inteira na ordem: cada pergunta, cada resposta,
            // quem foi junto, o retorno. O contêiner é a pilha, não a rolagem:
            // à árvore de AX a rolagem é `scrollView`, e a suíte procura a
            // conversa como `otherElement` — foi assim que o ensaio "não pegou".
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Conversa com a sábia")
            .accessibilityIdentifier("cartao-sabia-notas")
        }
        // a conversa curta pousa junto do campo, como no Hermes; a longa
        // continua a abrir pelo começo, que é por onde se lê
        .defaultScrollAnchor(.bottom, for: .alignment)
        .scrollBounceBehavior(.always)
        .scrollDismissesKeyboard(.interactively)
        // §8 e §9: o campo fica no pé da conversa, e a cápsula colada acima
        // dele enquanto a sábia pensa. Rolar a resposta não os leva. Pilha, e
        // não `safeAreaInset`: como inset o pé virava barra SOBRE a rolagem, e
        // o iOS 26 pintava a sombra da borda nele — o pé flutuava por cima da
        // conversa, o que o Hermes não faz.
        VStack(spacing: 8) {
            if let desde = conversaNotas.esperandoDesde {
                CapsulaDeEspera(frase: Espera.aSabiaPensa, desde: desde,
                                identificador: "sabia-notas-pensando")
                    .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
            }
            linhaDaPergunta
        }
        .padding(.horizontal, Tema.margem)
        .padding(.top, 8)
        }
        .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
    }

    /// Uma mensagem: a linha de autor e, embaixo, o que foi dito. O fio vai
    /// no topo, na largura do texto — recuado, nunca de ponta a ponta.
    private func mensagem<C: View>(_ autor: Autor, fio: Bool, @ViewBuilder _ texto: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LinhaDeAutor(autor)
            texto()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            if fio { Rectangle().fill(Tema.linha).frame(height: 0.5) }
        }
    }

    /// A pergunta da pessoa, na mesma letra e tinta da resposta: no Hermes o
    /// que o USER diz e o que o bot diz pesam igual — quem distingue é a
    /// linha de autor, não o cinza.
    private func mensagemDaPessoa(_ pergunta: String, fio: Bool) -> some View {
        mensagem(.voce, fio: fio) {
            Text(pergunta)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .accessibilityIdentifier("pergunta-sabia-notas")
        }
    }

    /// SPEC §20: navegar é da barra inferior. Aqui o título e o export do
    /// conjunto visível — a casa de escrever não carrega este chrome.
    private var topbar: some View {
        TituloTela(texto: escolhidas.isEmpty ? "Notas" : "\(escolhidas.count) escolhida\(escolhidas.count == 1 ? "" : "s")") {
            if !escolhidas.isEmpty {
                loteAcoes
            } else if conversaNotas.modoPergunta {
                // o ÚNICO fechar da conversa (§14: eram dois), fora do caminho
                // da leitura; a folha some e a lista volta
                Button("Fechar", action: fecharConversa)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .alvo(folgaH: 8)
                    .buttonStyle(.discreto)
                    .accessibilityHint("A conversa some; as suas notas voltam")
                    .accessibilityIdentifier("fechar-resposta")
            } else {
                HStack(spacing: 4) {
                    if !filtradas.isEmpty {
                        // o gesto de compartilhar que todo iPhone conhece (jakobs-law);
                        // D1: só o glifo, sem o círculo de chip — a folha não tem botões redondos
                        Button {
                            contextoURL = Corpus.urlComoContexto(
                                filtradas.map(FatiaCorpus.de), nome: "traco-contexto.md")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.medium))
                                .foregroundStyle(Tema.tintaSuave)
                        }
                        .frame(width: Tema.alvo, height: Tema.alvo)
                        .contentShape(Rectangle())
                        .buttonStyle(.discreto)
                        .accessibilityLabel("Como contexto")
                        .accessibilityHint("Entrega estas notas à sua IA, sem servidor")
                        // ao lado do título: em AX5 crescia até partir "Notas" em duas linhas
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                }
            }
        }
    }

    /// D1 (DIRETRIZ §9): a régua de 29 cápsulas e a cápsula da ordem viram
    /// duas PALAVRAS em tinta suave sob o título — "Todas ⌄ · Mais recentes ⌄" —,
    /// cada uma abrindo o seu menu. Hierarquia por tipografia, não por selo.
    /// A seta da régua (V13) deixa de ser necessária: o menu mostra os 29 de
    /// uma vez, nenhum fica escondido à direita.
    private var regencia: some View {
        // Laço de simplicidade (goal de 14/09): filtrar por 29 formas e
        // domínios e escolher a ordem eram decisões de taxonomia — a IA
        // classifica em silêncio e a busca acha. As duas palavras saem do
        // cabeçalho; os menus ficam no código até a próxima volta julgar o
        // que sobra deles (o filtro de trancadas, por exemplo).
        Color.clear.frame(height: 0)
        .sheet(isPresented: Binding(get: { contextoURL != nil },
                                    set: { if !$0 { contextoURL = nil } })) {
            if let contextoURL { CompartilharArquivo(url: contextoURL) }
        }
        .sheet(item: $versoesDe) { nota in
            VersoesView(nota: nota, sessao: sessao)
        }
        .sheet(item: $redeDe) { nota in
            RedeView(nota: nota, todas: notas, sessao: sessao)
        }
        .sheet(item: Binding(get: { serieDe.map(IdDaSerie.init) },
                             set: { serieDe = $0?.id })) { alvo in
            SerieView(serie: alvo.id, todas: notas)
        }
        .confirmationDialog(
            "Apagar \(escolhidas.count) nota\(escolhidas.count == 1 ? "" : "s")?",
            isPresented: $confirmarLote, titleVisibility: .visible
        ) {
            Button("Apagar", role: .destructive) {
                for uuid in escolhidas { sessao.apagar(uuid: uuid, no: context) }
                escolhidas = []
            }
            Button("Manter", role: .cancel) {}
        } message: {
            Text("O traço some do aparelho, e a revisão marcada some com ele.")
        }
    }

    /// Uma palavra que abre um menu: o rótulo em `meta` tinta suave e a seta
    /// pequena. É o mesmo desenho do domínio na linha da nota (`ChipDominio`).
    private func palavraDeMenu(_ texto: String) -> some View {
        HStack(spacing: 3) {
            Text(texto)
            SetaDeMenu()
        }
        .font(Tema.meta)
        .foregroundStyle(Tema.tintaSuave)
    }

    private var nomeDoFiltro: String {
        filtro?.rawValue ?? filtroDominio?.nome ?? "Todas"
    }

    private var menuFiltro: some View {
        Menu {
            Button {
                Toque.selecao()
                filtro = nil
                filtroDominio = nil
            } label: {
                Label("Todas", systemImage: filtro == nil && filtroDominio == nil ? "checkmark" : "")
            }
            .accessibilityIdentifier("filtro-todas")
            // Domínio primeiro: são sete e é o eixo de "marcar"; os métodos são
            // onze e crescem com a pasta do autor — os dois primeiros grupos
            // cabem sem rolar o menu (hicks-law: uma lista, dois grupos).
            Section("Domínio") {
                ForEach(Dominio.allCases) { item in
                    Button {
                        Toque.selecao()
                        filtroDominio = filtroDominio == item ? nil : item
                        filtro = nil
                    } label: {
                        Label(item.nome, systemImage: filtroDominio == item ? "checkmark" : "")
                    }
                    .accessibilityIdentifier("filtro-dominio-\(item.rawValue)")
                }
            }
            Section("Método") {
                ForEach(FiltroNotas.allCases.filter { $0 != .trancadas }) { item in
                    Button {
                        Toque.selecao()
                        filtro = filtro == item ? nil : item
                        filtroDominio = nil
                    } label: {
                        Label(item.rawValue, systemImage: filtro == item ? "checkmark" : "")
                    }
                    .accessibilityIdentifier("filtro-\(item.slug)")
                }
            }
            Button {
                Toque.selecao()
                filtro = filtro == .trancadas ? nil : .trancadas
                filtroDominio = nil
            } label: {
                Label(FiltroNotas.trancadas.rawValue, systemImage: filtro == .trancadas ? "checkmark" : "")
            }
            .accessibilityIdentifier("filtro-trancadas")
        } label: {
            palavraDeMenu(nomeDoFiltro)
        }
        .menuStyle(.button)
        .buttonStyle(.discreto)
        // a palavra mede 20; o alvo de 44 cresce para o vão, sem ocupar layout
        .alvo(folgaV: 12)
        .accessibilityLabel("Mostrar \(nomeDoFiltro)")
        .accessibilityHint("Um filtro por vez: método, domínio ou trancadas")
        .accessibilityIdentifier("filtro-notas")
    }

    /// Q3: a lista só sabia ordenar por data de criação — e o "recordada 3×"
    /// já estava no subtítulo, o dado existia e não dava para ordenar por ele.
    private var menuOrdem: some View {
        Menu {
            ForEach(OrdemNotas.allCases) { o in
                Button {
                    Toque.selecao()
                    ordem = o
                } label: {
                    Label(o.nome, systemImage: ordem == o ? "checkmark" : "")
                }
            }
        } label: {
            palavraDeMenu(ordem.nome)
        }
        .menuStyle(.button)
        .buttonStyle(.discreto)
        .alvo(folgaV: 12)
        .accessibilityLabel("Ordenar por \(ordem.nome)")
        .accessibilityIdentifier("ordem-notas")
    }

    /// Q4: apagar dez notas eram dez confirmações; exportar um punhado
    /// escolhido a dedo não existia.
    private var loteAcoes: some View {
        HStack(spacing: 14) {
            Button("Como contexto") {
                let fatias = filtradas.filter { escolhidas.contains($0.uuid) }
                    .map(FatiaCorpus.de).filter { !$0.nuncaSai }
                contextoURL = Corpus.urlComoContexto(fatias, nome: "traco-contexto.md")
            }
            .font(Tema.meta)
            .foregroundStyle(Tema.tintaSuave)
            Button("Apagar") { confirmarLote = true }
                .font(Tema.meta.weight(.semibold))
                .foregroundStyle(Tema.aviso)
                .accessibilityIdentifier("lote-apagar")
            Button("Pronto") { escolhidas = [] }
                .font(Tema.meta)
                .foregroundStyle(Tema.tinta)
                .accessibilityIdentifier("lote-pronto")
        }
        .alvo()
        .buttonStyle(.discreto)
    }

    /// D1: a busca é uma LINHA no pé da folha, não uma barra de sistema —
    /// sem cartão branco nem lupa; a hairline acima e o caret âmbar dizem
    /// "escreva aqui", como na página.
    ///
    /// §14 (complemento): buscar e perguntar são DUAS intenções e cada uma
    /// tem o seu gesto. A linha nasce como busca ("buscar"); a palavra
    /// D1 (ADR 09k) + ADR 10i: a busca é uma LINHA da lista, no lugar de
    /// busca — sob o título, antes das notas —, sem cartão branco nem lupa:
    /// hairline abaixo e o caret âmbar dizem "escreva aqui". Só filtra.
    /// Escrever "?" nela é a segunda porta do gesto de perguntar (ver `body`).
    private var linhaDeBusca: some View {
        HStack(spacing: 8) {
            TextField(
                "",
                text: Bindable(conversaNotas).busca,
                prompt: Text("buscar").foregroundStyle(Tema.tintaFraca)
            )
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .font(Tema.corpo)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .alvo()
                .accessibilityIdentifier("busca-notas")
                .accessibilityLabel("Buscar")
                .accessibilityValue(busca.isEmpty ? "vazio" : busca)
                .accessibilityHint(filtro == .trancadas ? "Indisponível no filtro de trancadas" : "Escrever filtra a lista; \"?\" no início pergunta")
            if !busca.isEmpty {
                Button {
                    busca = ""
                    filtro = nil
                    filtroDominio = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Tema.tintaFraca)
                        .frame(width: Tema.alvo, height: Tema.alvo)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.discreto)
                .transition(Tema.transicao(.opacity.combined(with: .scale(scale: 0.8)), reduzido: reduceMotion))
                .accessibilityIdentifier("limpar-busca")
                .accessibilityLabel("Limpar")
            }
        }
        .alvo()
        .padding(.horizontal, Tema.margem)
        .overlay(alignment: .bottom) { Rectangle().fill(Tema.linha).frame(height: 0.5).padding(.horizontal, Tema.margem) }
        .padding(.bottom, 8)
        .opacity(filtro == .trancadas ? 0.4 : 1)
        .disabled(filtro == .trancadas)
    }

    /// A entrada da conversa é o MESMO campo do pé das Notas (dono, 14/09:
    /// "tamanho, experiência, empacotamento"): a linha "?" com fio era um
    /// terceiro desenho de campo, sem microfone. O botão vira parar enquanto
    /// a sábia pensa; a próxima pergunta pode ser escrita, mas só segue depois.
    private var linhaDaPergunta: some View {
        let primeira = conversa.isEmpty
        return CampoFlutuante(texto: Bindable(conversaNotas).entrada,
                              dica: pensando ? "escreva a próxima" : primeira ? "diga qualquer coisa" : "diga mais",
                              ditado: ditado, identificador: "pergunta-notas",
                              identificadorDoBotao: pensando ? "parar-de-esperar" : "perguntar-notas",
                              rotuloEnviar: "Perguntar à sábia", rotuloDitar: "Ditar a pergunta",
                              aoEnviar: perguntar, foco: $perguntaFocada,
                              aoParar: pensando ? { conversaNotas.interromper() } : nil)
            .onAppear {
                ditado.aoTexto = { [conversaNotas] falado in conversaNotas.entrada = falado }
                // a folha vazia nasce pronta para escrever; com conversa, o
                // teclado não sobe por cima da resposta — quem quer, toca
                if primeira { Task { @MainActor in perguntaFocada = true } }
            }
            .onDisappear { ditado.parar() }
    }

    /// O campo do pé (dono, 14/09): a mesma cápsula do calendário. Digitar
    /// filtra a lista ao vivo; enviar leva a frase à sábia como pergunta; o
    /// microfone dita para o mesmo campo. Um lugar, três atos, sem menu.
    private var campoDeBuscaEPergunta: some View {
        CampoFlutuante(texto: Bindable(conversaNotas).busca, dica: "diga qualquer coisa", ditado: ditado,
                       identificador: "busca-notas", identificadorDoBotao: busca.isEmpty ? "ditar-notas" : "perguntar-notas",
                       rotuloEnviar: "Perguntar à sábia", rotuloDitar: "Ditar", aoEnviar: perguntarDaBusca)
            .padding(.horizontal, Tema.margem)
            // cola na pílula: o pé é UM bloco (campo sobre a pílula), não dois
            // vidros com um vão maior do que a margem da tela entre eles
            .padding(.bottom, -6)
            .onAppear { ditado.aoTexto = { [conversaNotas] falado in conversaNotas.busca = falado } }
            .onDisappear { ditado.parar() }
    }

    /// Enviar do campo do pé: a busca vira a pergunta e a folha da conversa abre.
    private func perguntarDaBusca() {
        let texto = busca.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return }
        // pedido com dia e hora é do calendário, não da sábia
        if sessao.marcarCompromissos(em: texto) > 0 {
            conversaNotas.busca = ""
            return
        }
        conversaNotas.entrada = texto
        conversaNotas.busca = ""
        conversaNotas.perguntando = true
        Toque.selecao()
        perguntar()
    }

    /// D1: o rótulo de seção da folha é uma palavra em tinta fraca — "hoje",
    /// "setembro", "pelo sentido" —, não um selo em caixa alta com tracking.
    private func secao(_ titulo: String) -> some View {
        Text(titulo)
            .font(Tema.meta)
            .foregroundStyle(Tema.tintaFraca)
            .padding(.top, 24)
            .padding(.bottom, 2)
            .accessibilityAddTraits(.isHeader)
    }

    /// ADR 04n: pergunta ao índice de sentido, fora da main thread, e só
    /// mostra o que a busca por letras não achou. O selo já cortou no índice.
    private func procurarPeloSentido(_ termo: String, entre visiveis: [Nota]) {
        tarefaSentido?.cancel()
        let limpo = termo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard limpo.count >= 3, Indice.disponivel else { peloSentido = []; return }
        let jaVistas = Set(visiveis.map(\.uuid))
        let todas = notas
        tarefaSentido = Task {
            let vizinhas = await Task.detached(priority: .userInitiated) {
                Indice.vizinhas(de: limpo, teto: 5, minimo: 0.3, exceto: jaVistas)
            }.value
            guard !Task.isCancelled else { return }
            let porId = Dictionary(uniqueKeysWithValues: todas.map { ($0.uuid, $0) })
            peloSentido = vizinhas.compactMap { porId[$0.uuid] }
                .filter { !$0.fechada && $0.gesto != .expressiva && $0.temVoz }
        }
    }

    @ViewBuilder private var secaoPeloSentido: some View {
        if !busca.isEmpty, !peloSentido.isEmpty {
            secao("pelo sentido")
            Text("falam disto sem usar a palavra")
                .font(.footnote)
                .foregroundStyle(Tema.tintaFraca)
                .padding(.bottom, 6)
            ForEach(Array(peloSentido.enumerated()), id: \.element.uuid) { i, nota in
                botaoNota(nota)
                if i < peloSentido.count - 1 {
                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                }
            }
        }
    }

    /// ADR 04v: o que o autor escreveu e a hora de conferir chegou. Só
    /// existe quando há campo devido e vazio; some ao responder.
    private var voltas: [(nota: Nota, campo: CampoForma)] {
        guard busca.isEmpty, filtro == nil, filtroDominio == nil else { return [] }
        return notas.compactMap { n in
            Volta.campoDevido(gesto: n.gesto, campos: n.campos, criadaEm: n.criadaEm, fechado: n.fechada)
                .map { (n, $0) }
        }
    }

    @ViewBuilder private var secaoDaVolta: some View {
        let devidas = voltas
        if !devidas.isEmpty {
            // D1: sem o rótulo "A VOLTA". A pergunta em tinta ÂMBAR é o único
            // texto âmbar da folha — é a folha cobrando, como "1 volta a
            // conferir" na página em branco (ADR 05b): mesmo idioma, mesma tinta.
            // a mesma nota volta a aparecer no mês: o id tem de ser outro, ou o
            // LazyVStack descarta uma das duas linhas (visto na captura 31)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(devidas.enumerated()), id: \.offset) { i, par in
                    Button {
                        sessao.abrir(par.nota)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Volta.cobranca(par.campo))
                                .font(Tema.corpo)
                                .foregroundStyle(Tema.ambarTinta)
                                .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 2)
                            Text(titulo(par.nota))
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaFraca)
                                .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .padding(.vertical, 12)
                        .alvo()
                    }
                    .buttonStyle(.discreto)
                    .accessibilityLabel("A volta: \(Volta.cobranca(par.campo)) \(titulo(par.nota))")
                    .accessibilityHint("Abre a nota com o campo da volta")
                    .accessibilityIdentifier("volta-notas")
                    if i < devidas.count - 1 {
                        Rectangle().fill(Tema.linha).frame(height: 0.5)
                    }
                }
            }
            .padding(.top, 4)
            .accessibilityIdentifier("secao-volta")
        }
    }

    /// ADR 08p: Trabalhos é destino, não ação — nem link âmbar no chrome (§20,
    /// 05f) nem, desde a D1, linha de menu com ícone e seta na borda. É uma
    /// FRASE em tinta suave que diz o que há — "3 trabalhos ›" — no idioma que a
    /// página em branco já usa ("1 volta a conferir"): a folha afirma um fato e
    /// o fato é a porta. O "›" fica no texto, tipográfico, para continuar a
    /// ler-se como "abre" (jakobs-law). Rola com o arquivo e some na busca.
    @ViewBuilder private var linhaTrabalhos: some View {
        if NotasFiltro.mostraTrabalhos(busca: busca, filtro: filtro, dominio: filtroDominio) {
            Button { mostrarTrabalhos = true } label: {
                Text(trabalhos.isEmpty ? "trabalhos ›"
                     : "\(trabalhos.count) trabalho\(trabalhos.count == 1 ? "" : "s") ›")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .padding(.vertical, 6)
                    .alvo(folgaV: 8)
            }
            .buttonStyle(.discreto)
            .accessibilityLabel(trabalhos.isEmpty ? "Trabalhos" : "Trabalhos, \(trabalhos.count)")
            .accessibilityHint("Retoma intenções, versões e próximos atos")
            .accessibilityIdentifier("abrir-trabalhos")
        }
    }

    private var lista: some View {
        let visiveis = filtradas
        return Group {
            if visiveis.isEmpty, peloSentido.isEmpty || busca.isEmpty {
                // No eixo do app, onde os resultados nasceriam — não um placar
                // centralizado contra a tela toda (law-of-continuity; mesmo
                // conserto do Recordar em 9eb6124). O glifo decorativo saiu:
                // era o elemento mais chamativo do ecrã carregando zero
                // conteúdo (critique-visual-hierarchy).
                // a saída tem que ser do BURACO em que o autor caiu: quando
                // o vazio é da busca, "escrever na página" joga fora o que
                // ele estava procurando em vez de devolver o arquivo
                // ADR 09d: o vazio também rola. Filtrar até zero com o teclado
                // em pé deixava a pessoa PRESA: sem lista não havia gesto que
                // dispensasse o teclado, e a tab bar ficava atrás dele — sair
                // custava jogar fora o que se estava procurando.
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // a porta dos Trabalhos existe mesmo com o arquivo vazio
                        linhaTrabalhos.padding(.horizontal, Tema.margem)
                        Vazio(frase: vazioTitulo, acao: busca.isEmpty && filtro == nil && filtroDominio == nil
                              ? .init("escrever na página") {
                                  sessao.novaPagina()
                                  sessao.mostrarNotas = false
                              }
                              : .init("ver todas as notas", id: "limpar-busca") {
                                  busca = ""
                                  filtro = nil
                                  filtroDominio = nil
                              })
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                // conteúdo curto não rola sozinho: sem isto não há gesto para
                // o teclado seguir
                .scrollBounceBehavior(.always)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // com zero pelas letras o vazio já diz tudo: contar "0" em cima é eco
                        if !busca.isEmpty || filtro != nil || filtroDominio != nil, !visiveis.isEmpty {
                            Text(contagem(visiveis.count))
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaFraca)
                                .padding(.top, 12)
                                .accessibilityIdentifier("contagem-busca")
                        }
                        // O arquivo tem tempo: seções por mês, não um pergaminho cego.
                        if visiveis.isEmpty, !busca.isEmpty {
                            Text(vazioTitulo)
                                .font(Tema.corpo)
                                .foregroundStyle(Tema.tintaSuave)
                                .padding(.top, 12)
                        }
                        linhaTrabalhos
                        secaoDaVolta
                        ForEach(meses(visiveis), id: \.titulo) { mes in
                            secao(mes.titulo)
                            ForEach(Array(mes.notas.enumerated()), id: \.element.uuid) { i, nota in
                                botaoNota(nota)
                                // sem separador depois do último: a lista fecha
                                if i < mes.notas.count - 1 {
                                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                                }
                            }
                        }
                        secaoPeloSentido

                    }
                    .padding(.horizontal, Tema.margem)
                }
            }
        }
        // o mesmo gesto do caderno (CadernoView:68): arrastar a lista devolve
        // a tela — sem isto o teclado da busca prende a tab bar atrás de si e
        // a única saída é o "x" (jakobs-law: no Notes, arrastar a lista
        // dispensa o teclado). Vale nos DOIS ramos: era só do cheio, e o vazio
        // ficou para trás.
        .scrollDismissesKeyboard(.interactively)
        // a última linha rola para cima do campo flutuante, nunca fica sob ele
        .contentMargins(.bottom, Tema.alvo + 28, for: .scrollContent)
        .desvanece(topo: 24, pe: 48, reservaPe: Tema.alvo + 16)
    }

    private struct SecaoMes {
        let titulo: String
        let notas: [Nota]
    }

    private func meses(_ notas: [Nota]) -> [SecaoMes] {
        let cal = Calendar.current
        let anoAtual = cal.component(.year, from: .now)
        var ordem: [String] = []
        var grupos: [String: [Nota]] = [:]
        let f = DateFormatter()
        f.locale = .current
        for nota in notas {
            let ano = cal.component(.year, from: nota.criadaEm)
            f.dateFormat = ano == anoAtual ? "LLLL" : "LLLL yyyy"
            // a seção de hoje se chama "hoje": repetir "agosto" no cabeçalho e
            // "hoje" em cada linha gasta a única informação temporal útil.
            // D1: minúsculas — é uma palavra na margem da folha, não um selo.
            let titulo = cal.isDateInToday(nota.criadaEm)
                ? "hoje"
                : f.string(from: nota.criadaEm).lowercased()
            if grupos[titulo] == nil { ordem.append(titulo) }
            grupos[titulo, default: []].append(nota)
        }
        return ordem.map { SecaoMes(titulo: $0, notas: grupos[$0] ?? []) }
    }

    private var vazioTitulo: String {
        if filtro == .trancadas { return "nenhuma trancada." }
        if !busca.isEmpty { return "nenhuma nota com “\(busca)”." }
        return "nada aqui ainda."
    }

    /// A busca não dizia quantas achou: o autor não sabia se tinha terminado
    /// (zeigarnik-effect).
    private func contagem(_ n: Int) -> String {
        let notas = n == 1 ? "1 nota" : "\(n) notas"
        if !busca.isEmpty { return "\(notas) com “\(busca)”" }
        // o chip aceso pode ter rolado para fora da régua: a contagem diz por quê
        if let filtro { return "\(notas) · \(filtro.rawValue)" }
        if let filtroDominio { return "\(notas) · \(filtroDominio.nome)" }
        return notas
    }

    private func abrirDaLista(_ nota: Nota) {
        if nota.queimada {
            sessao.abrir(nota) // diz honestamente que não há o que abrir
        } else if nota.trancada {
            sessao.confirmacao = .naoSeRele(nota.uuid)
        } else {
            sessao.abrir(nota)
        }
    }

    private func botaoNota(_ nota: Nota) -> some View {
        // Dois botões irmãos — nunca um Button dentro do outro. O domínio
        // promete um toque; aninhado, o toque abria a nota. D1: alinhados
        // pela última linha de base, a palavra do domínio fecha a última
        // linha da nota, na margem — tipografia, não caixa.
        HStack(alignment: .lastTextBaseline, spacing: 8) {
            Button {
                if escolhidas.isEmpty {
                    abrirDaLista(nota)
                } else if escolhidas.contains(nota.uuid) {
                    escolhidas.remove(nota.uuid)
                } else {
                    escolhidas.insert(nota.uuid)
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    if nota.queimada {
                        // §8: a queimada não finge existir. Mostra o que sobrou —
                        // e o que sobrou é justamente o que se multiplica.
                        Text("Expressiva — queimada")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                        if !nota.sentido.isEmpty {
                            DestaqueBusca.texto(nota.sentido, termo: busca, base: Tema.tinta)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        Text(nota.minutosEscritos >= 1
                             ? "\(nota.minutosEscritos) min · \(VozDoAutor.relativo(nota.criadaEm))"
                             : VozDoAutor.relativo(nota.criadaEm))
                            .font(.subheadline)
                            .foregroundStyle(Tema.tintaFraca)
                    } else if nota.trancada {
                        Text("Expressiva — trancada")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                        Text("não se relê · \(VozDoAutor.relativo(nota.criadaEm))")
                            .font(.subheadline)
                            .foregroundStyle(Tema.tintaFraca)
                    } else {
                        // D1: o título é a primeira linha do autor, na letra da
                        // página (`corpo`, regular) — a lista é o sumário da folha
                        DestaqueBusca.texto(titulo(nota), termo: busca, base: Tema.tinta)
                            .font(Tema.corpo)
                            // em AX o teto de duas linhas cortava "Quero dormir mais cedo est…"
                            .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 2)
                        // D1: método e quem escreveu (ADR 08u) ditos com uma
                        // palavra em tinta suave, o trecho em tinta fraca; nada
                        // em selo. O domínio é a palavra com seta, na margem
                        // direita da mesma linha — irmão do botão (abaixo).
                        let sub = subtitulo(nota)
                        let comSub = !(sub == "hoje" && busca.isEmpty)
                        let palavras = [nota.gesto?.nome, nota.origem.etiqueta].compactMap { $0 }
                        if comSub || !palavras.isEmpty {
                            // interpolação de Text em Text: o `+` foi descontinuado no iOS 26 (único warning do build)
                            Text("\(Text(palavras.joined(separator: " · ") + (comSub && !palavras.isEmpty ? " · " : "")).foregroundStyle(Tema.tintaSuave))\(comSub ? DestaqueBusca.texto(sub, termo: busca, base: Tema.tintaFraca) : Text(""))")
                                .font(Tema.meta)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                // a linha de um título só mede 25; o alvo pega 10 do vão de cada lado
                .alvo(folgaV: 10)
            }
            .buttonStyle(.linha)
            .tint(Tema.tinta)
            .accessibilityLabel(nota.trancada ? "Expressiva trancada" : titulo(nota))
            .accessibilityHint(nota.trancada ? "Reabrir pede confirmação dupla" : "Segure para recordar a memória")
            .accessibilityIdentifier("nota-notas")

            if !nota.fechada, nota.gesto != .expressiva, nota.dominio != nil || nota.dominioTravado {
                // Laço de simplicidade (14/09): o domínio é identidade, não
                // decisão — a palavra só diz. Corrigir mora no toque longo da
                // linha ("Escolher", "Sem domínio", "Devolver ao app"), com o
                // mesmo poder e nenhum chevron a pedir escolha em cada linha.
                ChipDominio(atual: nota.dominio, travado: nota.dominioTravado)
                    .accessibilityIdentifier("chip-dominio")
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, escolhidas.contains(nota.uuid) ? 10 : 0)
        .alvo()
        .background(
            escolhidas.contains(nota.uuid) ? Tema.chip : .clear,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .animation(Tema.animacao(.easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: escolhidas.contains(nota.uuid))
        .contextMenu {
            if !nota.trancada {
                Button("Recordar") { sessao.recordarDaNotas(nota) }
            }
            let fatia = FatiaCorpus.de(nota)
            if !fatia.nuncaSai {
                Button("Como contexto") {
                    contextoURL = Corpus.urlComoContexto([fatia], nome: "traco-contexto.md")
                }
            }
            if !nota.fechada, nota.gesto != .expressiva {
                Button("Versões") { versoesDe = nota }
                Button("Ligações") { redeDe = nota }
            }
            // ADR 05d: o domínio também se escolhe daqui, sem depender do chip
            if !nota.fechada, nota.gesto != .expressiva {
                Menu("Domínio") {
                    ForEach(Dominio.allCases) { d in
                        Button(d.nome) { sessao.escolherDominio(d, na: nota, no: context) }
                    }
                    Button("Sem domínio") { sessao.escolherDominio(nil, na: nota, no: context) }
                    if nota.dominioTravado {
                        Button("Devolver ao app") { sessao.devolverDominio(nota, no: context) }
                    }
                }
            }
            // R3: as quatro linhas juntas, depois do quarto fecho
            if nota.gesto == .expressiva, nota.serieUUID != nil {
                Button("Ver a série") { serieDe = nota.serieUUID }
            }
            Button("Escolher") {
                Toque.selecao()
                escolhidas.insert(nota.uuid)
            }
            // ADR 2026-08-31f: apagar existe, com atrito — trancada exige dupla.
            Button("Apagar", role: .destructive) {
                sessao.confirmacao = nota.trancada ? .apagarTrancada(nota.uuid) : .apagar(nota.uuid)
            }
        }
    }

    private var filtradas: [Nota] {
        OrdemNotas.ordenar(
            NotasFiltro.visiveis(notas, busca: busca, filtro: filtro, dominio: filtroDominio),
            por: ordem)
    }

    private func titulo(_ nota: Nota) -> String {
        nota.tituloNaLista
    }

    private func subtitulo(_ nota: Nota) -> String {
        if !busca.isEmpty {
            let trecho = VozDoAutor.trecho(em: nota.textoDeQualquerOrigem, termo: busca)
            // trecho que repete o título gasta uma linha e não informa nada
            let t = titulo(nota)
            if trecho == t || t.hasPrefix(trecho) || trecho.hasPrefix(t) {
                return VozDoAutor.relativo(nota.criadaEm)
            }
            return trecho
        }
        // arquivo do esforço, não streak: quantas vezes esta nota foi recordada
        let recordadas = Revisoes.contagem(nota.uuid)
        let sufixo = recordadas > 0 ? " · recordada \(recordadas)×" : ""
        // na ordem dos campos do método, não na do dicionário: a linha da
        // nota mudava de texto a cada abertura (auditoria 13/09, defeito 14)
        let ordem = nota.gesto?.metodoDef.campos.map(\.id) ?? []
        let respostas = nota.campos
            .sorted { (ordem.firstIndex(of: $0.key) ?? ordem.count, $0.key) < (ordem.firstIndex(of: $1.key) ?? ordem.count, $1.key) }
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if respostas.isEmpty {
            return VozDoAutor.relativo(nota.criadaEm) + sufixo
        }
        return VozDoAutor.truncar(respostas.joined(separator: " · "), 56) + sufixo
    }
}


/// Folha de compartilhamento do sistema (o export gera no toque, não no body).
struct CompartilharArquivo: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

/// `sheet(item:)` pede Identifiable; um UUID solto não serve.
private struct IdDaSerie: Identifiable {
    let id: UUID
}
