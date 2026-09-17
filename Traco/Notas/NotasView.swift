import SwiftData
import UIKit
import SwiftUI

struct NotasView: View {
    @Bindable var sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var faseDaCena
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.tecladoAberto) private var tecladoAberto
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
    /// Nota viva: a folha «Juntar com», o recomeço da lista depois de juntar
    /// ou separar, e o «Desfazer» da última junção.
    @State private var juntarDe: Nota?
    @State private var juntas = Juntas.mapa()
    @State private var contagensJuntas: [UUID: Int] = [:]
    @State private var desfazerJuntar: DesfazerJuntar?
    @State private var tarefaDesfazer: Task<Void, Never>?
    @State private var serieDe: UUID?
    @State private var contextoURL: URL?
    @State private var ordem: OrdemNotas = .criadaEm
    @State private var ditado = Ditado()
    /// Q4: seleção múltipla. Vazio = modo normal; não-vazio = modo lote.
    @State private var escolhidas: Set<UUID> = []
    @State private var confirmarLote = false
    @State private var mostrarTrabalhos = false
    /// A altura visível da conversa: o último bloco ocupa ao menos isso, para
    /// a pergunta enviada poder subir ao topo mesmo com resposta curta.
    @State private var alturaDaConversa: CGFloat = 0
    @State private var obraEmLeitura: ObraEmLeitura?
    @State private var voltasAbertas = false

    struct ObraEmLeitura: Identifiable {
        let id = UUID()
        let titulo: String
        let texto: String
        let citadas: [String]
    }
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
                    AccessibilityNotification.Announcement("A Sábia respondeu.").post()
                }
            }
            // VoiceOver: o cartão sobe sozinho no pé da tela — quem não vê precisa ouvir
            .onChange(of: conversaNotas.estado) { _, estado in
                switch estado {
                case .pensando: AccessibilityNotification.Announcement("A Sábia está pensando.").post()
                case .falhou: AccessibilityNotification.Announcement("A Sábia não respondeu. Perguntar de novo está ao lado da pergunta.").post()
                case .recolhida: AccessibilityNotification.Announcement("A resposta foi recolhida porque uma fonte mudou ou deixou de estar acessível. Você pode perguntar de novo.").post()
                default: break
                }
            }
            .onChange(of: conversaNotas.semModelo) { _, sem in
                if sem { AccessibilityNotification.Announcement("A Sábia " + Sabia.porOndeEmPalavras + ". A busca continua.").post() }
            }
        }
        .sheet(isPresented: $mostrarTrabalhos) { TrabalhosView() }
        .sheet(item: $juntarDe) { nota in
            JuntarView(nota: nota, todas: notas) { outra in juntar(nota, com: outra) }
        }
        .overlay(alignment: .bottom) { barraDesfazerJuntar }
        .task(id: chaveJuntas) { contagensJuntas = Juntas.contagens(juntas, notas.map(ficha)) }
    }

    // MARK: - Nota viva

    private struct DesfazerJuntar: Equatable {
        let antes: [UUID: UUID]
        let frase: String
    }

    private func juntar(_ nota: Nota, com outra: Nota) {
        let antes = Juntas.mapa()
        guard Juntas.juntar(nota.uuid, com: outra.uuid) else {
            sessao.mostrarToast("não consegui juntar — as duas notas continuam como estavam.")
            return
        }
        Toque.leve()
        withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
            juntas = Juntas.mapa()
        }
        oferecerDesfazer(antes, "Juntada a «\(nota.tituloNaLista.prefix(40))»")
    }

    private func separar(_ nota: Nota) {
        let antes = Juntas.mapa()
        guard Juntas.separar(nota.uuid) else { return }
        Toque.leve()
        withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
            juntas = Juntas.mapa()
        }
        oferecerDesfazer(antes, "Separada das versões")
    }

    private func oferecerDesfazer(_ antes: [UUID: UUID], _ frase: String) {
        withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
            desfazerJuntar = DesfazerJuntar(antes: antes, frase: frase)
        }
        AccessibilityNotification.Announcement(frase + ". Desfazer está no pé da tela.").post()
        tarefaDesfazer?.cancel()
        // com VoiceOver a barra fica até a próxima ação: 6 s não bastam para chegar nela
        guard !UIAccessibility.isVoiceOverRunning else { return }
        tarefaDesfazer = Task { @MainActor in
            try? await Task.sleep(for: .seconds(8))
            guard !Task.isCancelled else { return }
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                desfazerJuntar = nil
            }
        }
    }

    @ViewBuilder private var barraDesfazerJuntar: some View {
        if let d = desfazerJuntar {
            HStack(spacing: 12) {
                Text(d.frase)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Button("Desfazer") {
                    tarefaDesfazer?.cancel()
                    guard Juntas.restaurar(d.antes) else {
                        sessao.mostrarToast("não consegui desfazer — as notas continuam inteiras.")
                        return
                    }
                    Toque.leve()
                    withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                        juntas = Juntas.mapa()
                        desfazerJuntar = nil
                    }
                }
                .font(Tema.corpo.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .buttonStyle(.discreto)
                .alvo()
                .accessibilityIdentifier("desfazer-juntar")
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
            // flutua: sombra própria, para não ler como parte da lista (auditoria 17/09)
            .shadow(color: Tema.sombraFlutuante, radius: 12, y: 4)
            .padding(.horizontal, Tema.margem)
            .padding(.bottom, 64)
            .transition(Tema.transicao(.opacity.combined(with: .offset(y: 6)), reduzido: reduceMotion))
        }
    }

    /// Cada grupo aparece uma vez, pela versão mais nova que está à vista.
    /// A regra mora em `Juntas.recolher` (com teste); aqui só a tradução.
    private func recolherJuntas(_ lista: [Nota]) -> [Nota] {
        guard !contagensJuntas.isEmpty else { return lista }
        let porId = Dictionary(lista.map { ($0.uuid, $0) }, uniquingKeysWith: { a, _ in a })
        return Juntas.recolher(lista.map(ficha), mapa: juntas, contagens: contagensJuntas).compactMap { porId[$0] }
    }

    /// Quantas versões a nota viva tem. 1 = sozinha (ou selada: nunca conta).
    private func versoes(_ nota: Nota) -> Int { contagensJuntas[nota.uuid] ?? 1 }

    private func ficha(_ n: Nota) -> Juntas.Ficha {
        .init(uuid: n.uuid, criadaEm: n.criadaEm,
              podeJuntar: Juntas.podeJuntar(fechada: n.fechada, gesto: n.gesto, obra: n.origem.eObra))
    }

    /// Recalcula as contagens quando o mapa muda ou quando alguma nota é
    /// criada, apagada, selada ou muda de forma — não a cada quadro.
    private var chaveJuntas: Int {
        var h = Hasher()
        h.combine(juntas)
        for n in notas { h.combine(n.uuid); h.combine(n.fechada); h.combine(n.gestoRaw); h.combine(n.origemRaw) }
        return h.finalize()
    }

    /// ADR 10i: o gesto de perguntar. A folha abre com a linha "?" em branco
    /// e o teclado de pé; a busca que estava a ser escrita fica onde estava.
    private func abrirPergunta() {
        conversaNotas.recolhida = false
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
        withTransaction(t) { conversaNotas.recolher() }
    }

    /// A conversa recolhida mora no topo da lista, a um toque (auditoria 16/09
    /// noite). Encerrar de vez é o ✕ — ou "Nova conversa" lá dentro.
    @ViewBuilder private var continuarConversa: some View {
        if conversaNotas.recolhida, conversaNotas.temCartao {
            HStack(spacing: 12) {
                Button {
                    Toque.selecao()
                    withAnimation(Tema.corte(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                        conversaNotas.recolhida = false
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Tema.tinta)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pensando ? "A Sábia está pensando…" : "Continuar a conversa")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Tema.tinta)
                            if let ultima = conversa.last?.pergunta ?? conversaNotas.perguntaParaRepetir {
                                Text(ultima)
                                    .font(.subheadline)
                                    .foregroundStyle(Tema.tintaSuave)
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDeCartao())
                .accessibilityIdentifier("continuar-conversa")
                Button {
                    Toque.selecao()
                    conversaNotas.fechar()
                } label: {
                    Image(systemName: "xmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Tema.tintaFraca)
                        .frame(width: 30, height: 30)
                        .background(Tema.superficieBaixa, in: Circle())
                        .alvo()
                }
                .buttonStyle(.discreto)
                .accessibilityLabel("Encerrar a conversa")
                .accessibilityIdentifier("encerrar-conversa")
            }
            .cartao()
            .padding(.top, 14)
            .padding(.bottom, 4)
        }
    }

    /// A nota que foi junto abre como da lista: queimada e trancada com as
    /// mesmas guardas. A conversa fica na sessão (ADR 09c) e está aqui na volta.
    private func abrirFonte(_ id: UUID) {
        guard let nota = notas.first(where: { $0.uuid == id }) else { return }
        // a obra se LÊ numa folha (as regras citadas em capas), não se abre no
        // editor: abrir no editor a salvava e recolhia a resposta (auditoria 16/09)
        if nota.origem.eObra {
            let referencia = conversa.last.map { RespostaDaSabia.separar($0.resposta).referencia ?? "" } ?? ""
            obraEmLeitura = .init(titulo: nota.tituloNaLista, texto: nota.texto,
                                  citadas: ReferenciasDaResposta.itens(referencia).compactMap { $0.link?.absoluteString })
            return
        }
        abrirDaLista(nota)
    }

    /// A CONVERSA (dono, 16/09: "horrível… design totalmente quebrado"). Quem
    /// pergunta fala num balão à direita; a sábia responde sem balão e sem
    /// rótulo, em parágrafos; a espera é uma linha logo abaixo da pergunta, que
    /// sobe ao topo quando é enviada; as fontes e as ações moram colados à
    /// resposta. A regra de conteúdo continua a mesma: a resposta chega ao
    /// lado, nunca na nota (ADR 02o), e só a última leva fontes e retorno.
    private var conversaDaSabia: some View {
        let emEspera = conversaNotas.esperandoDesde
        let pergunta: String? = if case .pensando(let p, _) = conversaNotas.estado { p } else { nil }
        let aRepetir = conversaNotas.perguntaParaRepetir
        let vazia = conversa.isEmpty && pergunta == nil && aRepetir == nil && !conversaNotas.semModelo
        return VStack(spacing: 0) {
        ScrollViewReader { rolagem in
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if vazia {
                    AberturaDaConversa().padding(.top, 8)
                }
                ForEach(Array(conversa.enumerated()), id: \.offset) { i, troca in
                    let ultima = i == conversa.count - 1 && aRepetir == nil && pergunta == nil
                    VStack(alignment: .leading, spacing: 16) {
                        BalaoDaPergunta(texto: troca.pergunta)
                        VStack(alignment: .leading, spacing: 14) {
                            // o rodapé "De …" só quando diz algo que a ficha não diz: a obra, com minuto
                            RespostaDaSabia(texto: troca.resposta,
                                            mostrarReferencia: !ultima || conversaNotas.fontes.isEmpty
                                                || conversaNotas.fontes.contains(where: \.obra))
                            if ultima, !conversaNotas.fontes.isEmpty {
                                FontesDaResposta(
                                    resumo: RespostaNotas.resumoDasFontes(conversaNotas.fontes),
                                    fontes: conversaNotas.fontes.map { .init(id: $0.id, titulo: $0.titulo, obra: $0.obra) },
                                    abrir: abrirFonte,
                                    aoAbrir: {
                                        // depois que a lista cresce: no mesmo quadro o fim ainda é o velho
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Tema.Duracao.curta) {
                                            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                                                rolagem.scrollTo("acoes-da-ultima", anchor: .bottom)
                                            }
                                        }
                                    })
                            }
                            if ultima, conversaNotas.obraParaPlantar != nil {
                                Button("Plantar esta obra", action: plantarObraDaGuarda)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Tema.tinta)
                                    .padding(.horizontal, 16)
                                    .frame(height: 38)
                                    .glassEffect(.regular.interactive(), in: .capsule)
                                    .alvo()
                                    .buttonStyle(.discreto)
                                    .accessibilityIdentifier("plantar-sabia-notas")
                            }
                            AcoesDaResposta(
                                texto: troca.resposta,
                                retorno: ultima && !conversaNotas.avaliadas.contains(troca.resposta) ? { serviu in
                                    Sinais.resposta(troca.resposta, forma: nil, serviu: serviu)
                                    conversaNotas.avaliadas.insert(troca.resposta)
                                    Toque.leve()
                                } : nil,
                                avaliada: conversaNotas.avaliadas.contains(troca.resposta))
                                .id(ultima ? "acoes-da-ultima" : "acoes-\(i)")
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("autor-sabia")
                    }
                    .frame(minHeight: i == conversa.count - 1 && pergunta == nil && aRepetir == nil
                           ? max(0, alturaDaConversa - 32) : nil, alignment: .top)
                    .id("troca-\(i)")
                }
                if let p = pergunta ?? aRepetir {
                    VStack(alignment: .leading, spacing: 16) {
                        BalaoDaPergunta(texto: p)
                        if let emEspera {
                            PensandoDaSabia(desde: emEspera)
                                .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
                        } else if let aRepetir {
                            FalhaDaSabia(
                                // a rota das Notas é só Grok (Politica, ADR 09v): sem
                                // a conta, a frase é a da Politica e a saída é o Perfil
                                frase: conversaNotas.estado == .recolhida(aRepetir)
                                    ? "A resposta foi recolhida porque uma fonte mudou ou deixou de estar acessível."
                                    : conversaNotas.estado == .interrompida(aRepetir)
                                        ? "Você parou de esperar."
                                        : !ContaGrok.ligada ? Politica.semProvedor(.responderNasNotas)
                                        : Grok.avisoDaFalha(),
                                rotulo: ContaGrok.ligada ? "Perguntar de novo" : "Entrar com a conta Grok",
                                acao: ContaGrok.ligada ? repetirPergunta : { sessao.irPara(.perfil, no: context) })
                        }
                    }
                    .frame(minHeight: max(0, alturaDaConversa - 32), alignment: .top)
                    .id("pendente")
                }
                if conversaNotas.semModelo {
                    LinhaDeEstado("a Sábia " + Sabia.porOndeEmPalavras + ". Sem ela, a busca continua.", .semConta)
                        .accessibilityIdentifier("sem-conta-notas")
                        .id("sem-modelo")
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, Tema.margem)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Conversa com a Sábia")
            .accessibilityIdentifier("cartao-sabia-notas")
        }
        .scrollBounceBehavior(.always)
        .scrollDismissesKeyboard(.interactively)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { alturaDaConversa = $0 }
        // a pergunta enviada sobe ao topo, com a espera logo abaixo; a resposta
        // que chega começa no topo, que é por onde se lê
        .onChange(of: conversaNotas.esperandoDesde) { _, desde in
            guard desde != nil else { return }
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                rolagem.scrollTo("pendente", anchor: .top)
            }
        }
        .onChange(of: conversa.count) { antes, depois in
            guard depois > antes else { return }
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                rolagem.scrollTo("troca-\(depois - 1)", anchor: .top)
            }
        }
        // sem modelo, o aviso nasce abaixo do último bloco (que ocupa a tela): rola até ele
        .onChange(of: conversaNotas.semModelo) { _, sem in
            guard sem else { return }
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                rolagem.scrollTo("sem-modelo", anchor: .top)
            }
        }
        .onAppear { if !conversa.isEmpty { rolagem.scrollTo("troca-\(conversa.count - 1)", anchor: .top) } }
        }
        linhaDaPergunta
            .padding(.horizontal, Tema.margem)
            .padding(.top, 8)
            .padding(.bottom, tecladoAberto ? 8 : 0)
        }
        .sheet(item: $obraEmLeitura) { obra in
            LeituraDaObra(titulo: obra.titulo, texto: obra.texto, citadas: obra.citadas)
        }
        .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
    }

    /// SPEC §20: navegar é da barra inferior. Aqui o título e o export do
    /// conjunto visível — a casa de escrever não carrega este chrome.
    @ViewBuilder private var topbar: some View {
        if conversaNotas.modoPergunta, escolhidas.isEmpty {
            topoDaConversa
        } else {
        TituloTela(texto: escolhidas.isEmpty ? "Notas" : "\(escolhidas.count) escolhida\(escolhidas.count == 1 ? "" : "s")") {
            if !escolhidas.isEmpty {
                loteAcoes
            } else {
                // dono, 15/09: "abaixo de Notas está extremamente zoado" — a
                // frase cinza "6 trabalhos ›" solta sob o título. Os Trabalhos
                // são DESTINO e moram na linha do título, num botão de vidro
                // com a contagem, ao lado do compartilhar (o mesmo material).
                HStack(spacing: 0) {
                    Button { mostrarTrabalhos = true } label: {
                        HStack(spacing: 6) {
                            // a pasta diz "trabalho"; o martelo não dizia o que era (auditoria 16/09 noite)
                            Image(systemName: "briefcase")
                            if !trabalhos.isEmpty {
                                Text("\(trabalhos.count)").monospacedDigit()
                            }
                        }
                        .font(.body.weight(.medium))
                        .foregroundStyle(Tema.tinta)
                        .padding(.leading, 14)
                        .padding(.trailing, 10)
                        .frame(height: 40)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.discreto)
                    .accessibilityLabel(trabalhos.isEmpty ? "Trabalhos" : "Trabalhos, \(trabalhos.count)")
                    .accessibilityHint("Retoma intenções, versões e próximos atos")
                    .accessibilityIdentifier("abrir-trabalhos")
                    // sempre à vista (auditoria 17/09: sumia com a busca vazia e a
                    // cápsula do topo pulava de dois para um ícone); vazio, apagado
                    do {
                        // o gesto de compartilhar que todo iPhone conhece (jakobs-law)
                        Button {
                            contextoURL = Corpus.urlComoContexto(
                                filtradas.map(FatiaCorpus.de), nome: Self.nomeDoArquivo())
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.medium))
                                .foregroundStyle(Tema.tinta)
                                .padding(.leading, 10)
                                .padding(.trailing, 14)
                                .frame(height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.discreto)
                        .disabled(filtradas.isEmpty)
                        .opacity(filtradas.isEmpty ? 0.35 : 1)
                        .accessibilityLabel("Exportar as notas visíveis")
                        .accessibilityHint("Gera um arquivo com estas notas para outra IA, sem servidor")
                        // ao lado do título: em AX5 crescia até partir "Notas" em duas linhas
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                }
                // dono, 15/09: as ações do título numa cápsula de vidro só, como
                // os apps da Apple no iOS 26/27 — dois vidros de tamanhos e pesos
                // diferentes liam como peças soltas
                .glassEffect(.regular.interactive(), in: .capsule)
            }
        }
        }
    }

    /// O topo da conversa: não é a lista, então não se chama "Notas" nem tem
    /// "Fechar". Voltar às notas à esquerda, o escopo no meio, e uma conversa
    /// nova à direita — botões de vidro, como o Journal e o Granola.
    private var topoDaConversa: some View {
        HStack(spacing: 12) {
            Button(action: fecharConversa) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.discreto)
            .glassEffect(.regular.interactive(), in: .circle)
            .accessibilityLabel("Voltar às notas")
            .accessibilityHint("A conversa some; as suas notas voltam")
            .accessibilityIdentifier("fechar-resposta")
            Spacer(minLength: 0)
            Text("Sábia")
                .font(.body.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            Button {
                Toque.selecao()
                conversaNotas.fechar()
                conversaNotas.recolhida = false
        conversaNotas.perguntando = true
                perguntaFocada = true
            } label: {
                // não o lápis: ele é "nova nota" no Dock, na mesma tela
                Image(systemName: "plus.bubble")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Tema.tinta)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.discreto)
            .glassEffect(.regular.interactive(), in: .circle)
            .opacity(conversa.isEmpty && !pensando && conversaNotas.perguntaParaRepetir == nil ? 0 : 1)
            .disabled(conversa.isEmpty && !pensando && conversaNotas.perguntaParaRepetir == nil)
            .accessibilityLabel("Nova conversa")
            .accessibilityIdentifier("nova-conversa")
        }
        .padding(.horizontal, Tema.margem)
        .padding(.top, 4)
        .padding(.bottom, 8)
        // a resposta rola por baixo: sem fundo, o texto aparecia sob o título
        .background(Tema.fundo)
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
                              dica: primeira && !pensando ? "Pergunte à Sábia" : "Continue a conversa",
                              ditado: ditado, identificador: "pergunta-notas",
                              identificadorDoBotao: pensando ? "parar-de-esperar" : "perguntar-notas",
                              rotuloEnviar: "Perguntar à Sábia", rotuloDitar: "Ditar a pergunta",
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
        CampoFlutuante(texto: Bindable(conversaNotas).busca, dica: "Fale com o Traço", ditado: ditado,
                       identificador: "busca-notas", identificadorDoBotao: busca.isEmpty ? "ditar-notas" : "perguntar-notas",
                       rotuloEnviar: "Perguntar à Sábia", rotuloDitar: "Ditar", aoEnviar: perguntarDaBusca,
                       aoLimpar: { conversaNotas.busca = "" })
            // a largura exata do pé (abas + botão de escrever), centrado: as
            // pontas do campo alinham com as pontas da fileira de baixo
            .frame(width: Tema.larguraDoPe)
            .frame(maxWidth: .infinity)
            .padding(.bottom, tecladoAberto ? 8 : Tema.doca - 14)   // 1u até o Dock; com teclado, 8 acima dele (dono, 16/09: o campo entrava no teclado)
            .onAppear { ditado.aoTexto = { [conversaNotas] falado in conversaNotas.busca = falado } }
            .onDisappear { ditado.parar() }
    }

    /// Enviar do campo do pé: a busca vira a pergunta e a folha da conversa abre.
    /// «Traço — notas 17-09-2026.md» (auditoria 17/09: «traco-contexto» era jargão).
    static func nomeDoArquivo(_ titulo: String? = nil) -> String {
        let data = Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))
            .split(separator: "-").reversed().joined(separator: "-")
        let limpo = titulo.map { String($0.prefix(40)).replacingOccurrences(of: "/", with: "-") }
        return (limpo.map { "Traço — \($0)" } ?? "Traço — notas \(data)") + ".md"
    }

    /// Termina em «?» ou tem quatro palavras ou mais: é pergunta, não busca.
    private var pareceUmaPergunta: Bool {
        guard filtro == nil, filtroDominio == nil, Politica.provedor(.responderNasNotas) != nil else { return false }
        let t = busca.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.hasSuffix("?") || t.split(whereSeparator: \.isWhitespace).count >= 4
    }

    private var linhaPerguntarASabia: some View {
        Button { perguntarDaBusca() } label: {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "text.bubble")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Perguntar à Sábia")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Tema.tinta)
                    Text(busca.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaSuave)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.up")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Tema.chipAtivo, in: Circle())
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cartao()
        }
        .buttonStyle(PressaoDeCartao())
        .padding(.top, 12)
        .padding(.bottom, 4)
        .accessibilityIdentifier("perguntar-da-busca")
    }

    private func perguntarDaBusca() {
        let texto = busca.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return }
        // pedido com dia e hora é do calendário, não da sábia
        if sessao.marcarCompromissos(em: texto) > 0 {
            conversaNotas.busca = ""
            return
        }
        // sem quem responda, a pergunta fica como busca: a lista (por palavra
        // e pelo sentido) já mostra o que as notas dizem sobre isso; abrir uma
        // folha vazia só para dizer "precisa da conta" apagava a resposta que
        // estava à vista (auditoria 15/09, alto 2). Nenhum aviso: a lista É a
        // resposta, e o Perfil já diz quem responde.
        guard Politica.provedor(.responderNasNotas) != nil else { return }
        conversaNotas.entrada = texto
        conversaNotas.busca = ""
        conversaNotas.recolhida = false
        conversaNotas.perguntando = true
        Toque.selecao()
        perguntar()
    }

    /// D1: o rótulo de seção da folha é uma palavra em tinta fraca — "hoje",
    /// "setembro", "pelo sentido" —, não um selo em caixa alta com tracking.
    private func secao(_ titulo: String) -> some View {
        // dono, 16/09 (cartões): o rótulo mora no eixo do TEXTO dos cartões,
        // não na borda deles, e respira mais acima do que abaixo — pertence
        // ao grupo que abre. Mês com maiúscula, como no calendário.
        // Atlas das Notas (Journal, Apple Notes): o mês é TÍTULO do grupo, em
        // tinta, não rótulo cinza — é ele que organiza a folha
        Text(titulo.capitalizadoNoInicio)
            .font(.title3.weight(.semibold))
            .foregroundStyle(Tema.tinta)
            // na borda dos cartões, como o Journal (auditoria: 4 pt para dentro)
            .padding(.leading, 0)
            .padding(.top, 26)
            .padding(.bottom, 10)
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
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaFraca)
                .padding(.bottom, 6)
            ForEach(recolherJuntas(peloSentido), id: \.uuid) { nota in
                botaoNota(nota)
                    .padding(.bottom, Tema.entreCartoes)
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
            // duas à vista; o resto numa linha que abre (auditoria 16/09 noite:
            // quatro cartões tomavam a tela e repetiam as notas de Hoje)
            let mostradas = voltasAbertas ? devidas : Array(devidas.prefix(2))
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(mostradas.enumerated()), id: \.offset) { _, par in
                    Button {
                        sessao.abrir(par.nota, campo: par.campo.id)
                    } label: {
                        // o mesmo cartão das notas (dono, 16/09): o aviso âmbar diz
                        // que chegou a hora, o título diz de qual decisão, e a
                        // pergunta da forma diz o que falta escrever
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Hora de conferir", systemImage: "clock.arrow.circlepath")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Tema.ambarTinta)
                            Text(partesDoCartao(par.nota).titulo)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Tema.tinta)
                                .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 2)
                            Text(Volta.cobranca(par.campo))
                                .font(.subheadline)
                                .foregroundStyle(Tema.tintaSuave)
                                .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .padding(.vertical, 8)
                        .alvo()
                        .cartao()
                    }
                    .buttonStyle(PressaoDeCartao())
                    .contextMenu { menuDaNota(par.nota) }
                    .accessibilityLabel("A volta: \(Volta.cobranca(par.campo)) \(titulo(par.nota))")
                    .accessibilityHint("Abre a nota com o campo da volta")
                    .accessibilityIdentifier("volta-notas")
                    .padding(.bottom, Tema.entreCartoes)
                }
                if devidas.count > 2 {
                    Button {
                        Toque.selecao()
                        withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                            voltasAbertas.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(voltasAbertas ? "Mostrar menos" : "Mais \(devidas.count - 2) para conferir")
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.bold))
                                .rotationEffect(.degrees(voltasAbertas ? 180 : 0))
                                .accessibilityHidden(true)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .padding(.leading, 4)
                        .alvo()
                    }
                    .buttonStyle(.discreto)
                    .accessibilityIdentifier("mais-voltas")
                }
            }
            // o primeiro cartão nasce abaixo do esmaecimento do topo (24)
            .padding(.top, 14)
            .accessibilityIdentifier("secao-volta")
        }
    }

    private var lista: some View {
        let visiveis = filtradas
        return Group {
            if visiveis.isEmpty, peloSentido.isEmpty || busca.isEmpty, !pareceUmaPergunta {
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
                        Vazio(frase: vazioTitulo, acao: busca.isEmpty && filtro == nil && filtroDominio == nil
                              ? .init("Escrever na página") {
                                  sessao.novaPagina()
                                  sessao.mostrarNotas = false
                              }
                              // uma pergunta digitada que não casa com nota nenhuma
                              // é pergunta, não busca vazia (auditoria 16/09)
                              : !busca.isEmpty && filtro == nil && filtroDominio == nil
                                && Politica.provedor(.responderNasNotas) != nil
                              ? .init("Perguntar à Sábia", id: "perguntar-da-busca") { perguntarDaBusca() }
                              : .init("Ver todas as notas", id: "limpar-busca") {
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
                        // auditoria 17/09: pergunta digitada não é busca vazia — a
                        // primeira linha é perguntar; o que casa fica embaixo
                        if pareceUmaPergunta { linhaPerguntarASabia }
                        // com zero pelas letras o vazio já diz tudo: contar "0" em cima é eco
                        if !busca.isEmpty || filtro != nil || filtroDominio != nil, !visiveis.isEmpty {
                            Text(contagem(recolherJuntas(visiveis).count))
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaFraca)
                                .padding(.top, 12)
                                .accessibilityIdentifier("contagem-busca")
                        }
                        // O arquivo tem tempo: seções por mês, não um pergaminho cego.
                        // com achados pelo sentido logo abaixo, "nenhuma nota com…"
                        // é nota de rodapé, não manchete
                        if visiveis.isEmpty, !busca.isEmpty, !pareceUmaPergunta {
                            Text(vazioTitulo)
                                .font(peloSentido.isEmpty ? Tema.corpo : Tema.meta)
                                .foregroundStyle(peloSentido.isEmpty ? Tema.tintaSuave : Tema.tintaFraca)
                                .padding(.top, 12)
                        }
                        // a porta dos Trabalhos não entra no resultado de uma busca
                        continuarConversa
                        secaoDaVolta
                        // quem está à vista em «Hora de conferir» não se repete logo
                        // abaixo (auditoria 17/09: os cartões apareciam duas vezes)
                        let noTopo = Set((voltasAbertas ? voltas : Array(voltas.prefix(2))).map(\.nota.uuid))
                        ForEach(meses(recolherJuntas(visiveis).filter { !noTopo.contains($0.uuid) }), id: \.titulo) { mes in
                            secao(mes.titulo)
                            ForEach(mes.notas, id: \.uuid) { nota in
                                botaoNota(nota)
                                    .padding(.bottom, Tema.entreCartoes)
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
        if filtro == .trancadas { return "Nenhuma trancada" }
        if !busca.isEmpty { return "Nenhuma nota com “\(busca)”" }
        return "Nada aqui ainda"
    }

    /// A busca não dizia quantas achou: o autor não sabia se tinha terminado
    /// (zeigarnik-effect).
    private func contagem(_ n: Int) -> String {
        let notas = n == 1 ? "1 nota" : "\(n) notas"
        // «para», não «com»: a busca também acha pela palavra parecida
        // (auditoria 17/09: «1 nota com "pilates"» sem «pilates» nela)
        if !busca.isEmpty { return "\(notas) para “\(busca)”" }
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
        // promete um toque; aninhado, o toque abria a nota. Dono, 16/09 (Atlas
        // das Notas — Journal, Apple Notes, Wispr): o cartão lê em três andares
        // — título em peso, a prévia do texto e um rodapé com fio que assina a
        // nota (quando, e de qual domínio).
        ZStack(alignment: .bottomTrailing) {
            Button {
                if escolhidas.isEmpty {
                    abrirDaLista(nota)
                } else if escolhidas.contains(nota.uuid) {
                    escolhidas.remove(nota.uuid)
                } else {
                    escolhidas.insert(nota.uuid)
                }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        if nota.queimada {
                            // §8: a queimada não finge existir. Mostra o que sobrou —
                            // e o que sobrou é justamente o que se multiplica.
                            Text("Expressiva — queimada")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Tema.tintaSuave)
                            if !nota.sentido.isEmpty {
                                DestaqueBusca.texto(nota.sentido, termo: busca, base: Tema.tintaSuave)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        } else if nota.trancada {
                            Text("Expressiva — trancada")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Tema.tintaSuave)
                            Text("não se relê")
                                .font(.subheadline)
                                .foregroundStyle(Tema.tintaFraca)
                        } else {
                            let partes = partesDoCartao(nota)
                            DestaqueBusca.texto(partes.titulo, termo: busca, base: Tema.tinta)
                                .font(.body.weight(.semibold))
                                .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 2)
                            if let previa = partes.previa.map({ $0.prefix(1).uppercased() + $0.dropFirst() }) {
                                DestaqueBusca.texto(previa, termo: busca, base: Tema.tintaSuave)
                                    .font(.subheadline)
                                    .lineSpacing(1)
                                    .lineLimit(tamanhoTexto.isAccessibilitySize ? nil : 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                    Text(rodape(nota))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Tema.tintaFraca)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                        // o domínio mora à direita do rodapé, por cima (irmão)
                        .padding(.trailing, temDominio(nota) ? 96 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressaoDeCartao())
            .tint(Tema.tinta)
            .accessibilityLabel(nota.trancada ? "Expressiva trancada" : titulo(nota))
            .accessibilityValue(versoes(nota) > 1 ? "\(versoes(nota)) versões" : "")
            .accessibilityHint(nota.trancada ? "Reabrir pede confirmação dupla" : "Segure para recordar a memória")
            .accessibilityIdentifier("nota-notas")

            if temDominio(nota) {
                // Laço de simplicidade (14/09): o domínio é identidade, não
                // decisão — a palavra só diz. Corrigir mora no toque longo.
                ChipDominio(atual: nota.dominio, travado: nota.dominioTravado)
                    .font(.footnote.weight(.medium))
                    .frame(minHeight: 36)
                    .accessibilityIdentifier("chip-dominio")
            }
        }
        .padding(.top, 8)
        // dono, 16/09: cada nota é um objeto sobre o papel — a separação é o
        // vão entre cartões, não um fio entre linhas
        .cartao(selecionado: escolhidas.contains(nota.uuid))
        // nota viva: as versões de trás aparecem como folhas sob o cartão
        .background(alignment: .bottom) {
            if versoes(nota) > 1 {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous)
                        .fill(Tema.superficie)
                        .overlay { RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5) }
                        .padding(.horizontal, 24)
                        .offset(y: 12)
                        .opacity(versoes(nota) > 2 ? 0.6 : 0)
                    RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous)
                        .fill(Tema.superficie)
                        .overlay { RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5) }
                        .padding(.horizontal, 12)
                        .offset(y: 6)
                }
                .shadow(color: Tema.sombraFlutuante.opacity(0.5), radius: 4, y: 2)
                .accessibilityHidden(true)
            }
        }
        .padding(.bottom, versoes(nota) > 1 ? (versoes(nota) > 2 ? 12 : 6) : 0)
        .animation(Tema.animacao(.easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: escolhidas.contains(nota.uuid))
        .contextMenu { menuDaNota(nota) }
    }

    /// O mesmo menu no cartão da nota e no de «Hora de conferir», que é a mesma nota
    /// (auditoria 16/09 noite: o toque longo ali abria em vez de mostrar o menu).
    @ViewBuilder private func menuDaNota(_ nota: Nota) -> some View {
        // auditoria 17/09: nove itens numa pilha só; agora em quatro grupos —
        // levar a nota · as notas em volta · organizar · apagar
        let aberta = !nota.fechada && nota.gesto != .expressiva
        let fatia = FatiaCorpus.de(nota)
        Section {
            if !nota.trancada {
                Button("Recordar", systemImage: "brain.head.profile") { sessao.recordarDaNotas(nota) }
            }
            if !fatia.nuncaSai {
                Button("Enviar para outra IA", systemImage: "square.and.arrow.up") {
                    contextoURL = Corpus.urlComoContexto([fatia], nome: Self.nomeDoArquivo(nota.tituloNaLista))
                }
            }
        }
        Section {
            if aberta {
                Button("Notas ligadas", systemImage: "link") { redeDe = nota }
            }
            if Juntas.podeJuntar(fechada: nota.fechada, gesto: nota.gesto, obra: nota.origem.eObra) {
                Button("Juntar com…", systemImage: "square.on.square") { juntarDe = nota }
            }
            if versoes(nota) > 1 {
                Button("Separar das versões", systemImage: "square.split.2x1") { separar(nota) }
            }
            if aberta {
                // «Versões» são as datas da nota viva; o histórico de edição é «Alterações»
                Button("Alterações", systemImage: "clock.arrow.circlepath") { versoesDe = nota }
            }
            // R3: as quatro linhas juntas, depois do quarto fecho
            if nota.gesto == .expressiva, nota.serieUUID != nil {
                Button("Ver a série", systemImage: "square.stack") { serieDe = nota.serieUUID }
            }
        }
        Section {
            // ADR 05d: o domínio também se escolhe daqui, sem depender do chip
            if aberta {
                Menu("Domínio", systemImage: "tag") {
                    ForEach(Dominio.allCases) { d in
                        // o atual leva ✓ (auditoria 17/09: não se via qual estava)
                        if nota.dominio == d {
                            Button(d.nome, systemImage: "checkmark") { sessao.escolherDominio(d, na: nota, no: context) }
                        } else {
                            Button(d.nome) { sessao.escolherDominio(d, na: nota, no: context) }
                        }
                    }
                    Button("Sem domínio") { sessao.escolherDominio(nil, na: nota, no: context) }
                    if nota.dominioTravado {
                        Button("Devolver ao app") { sessao.devolverDominio(nota, no: context) }
                    }
                }
            }
            Button("Selecionar", systemImage: "checkmark.circle") {
                Toque.selecao()
                escolhidas.insert(nota.uuid)
            }
        }
        Section {
            // ADR 2026-08-31f: apagar existe, com atrito — trancada exige dupla.
            Button("Apagar", systemImage: "trash", role: .destructive) {
                sessao.confirmacao = nota.trancada ? .apagarTrancada(nota.uuid) : .apagar(nota.uuid)
            }
        }
    }

    private var filtradas: [Nota] {
        OrdemNotas.ordenar(
            NotasFiltro.visiveis(notas, busca: busca, filtro: filtro, dominio: filtroDominio),
            por: ordem)
    }

    private func temDominio(_ nota: Nota) -> Bool {
        !nota.fechada && nota.gesto != .expressiva && (nota.dominio != nil || nota.dominioTravado)
    }

    /// Título e prévia do cartão. O título é a primeira FRASE quando a primeira
    /// linha é um parágrafo inteiro (quase toda nota escrita de uma vez); a
    /// prévia é o que vem depois — nunca a repetição do título.
    private func partesDoCartao(_ nota: Nota) -> (titulo: String, previa: String?) {
        let base = titulo(nota)
        var t = base
        if base.count > 70, let r = base.range(of: #"[.!?:](\s|$)"#, options: .regularExpression),
           base.distance(from: base.startIndex, to: r.lowerBound) >= 12 {
            // "Celular na cama: se eu pegar…" — os dois-pontos nomeiam a nota e saem do título
            t = String(base[..<(base[r.lowerBound] == ":" ? r.lowerBound : r.upperBound)]).trimmingCharacters(in: .whitespaces)
        }
        // título não termina em ponto (auditoria 16/09 noite); reticências e "?" ficam
        if t.hasSuffix("."), !t.hasSuffix("..") { t.removeLast() }
        if !busca.isEmpty {
            let sub = subtitulo(nota)
            if sub == VozDoAutor.relativo(nota.criadaEm) || base.hasPrefix(sub) {
                // forma: as respostas separadas, não emendadas numa frase só
                // («Manter em 90 Margem sem perder vendas», visto na busca)
                return (t, previaDaForma(nota, titulo: t) ?? restoDaNota(nota, depoisDe: t))
            }
            // o trecho que começa pelo título repetia o título (auditoria 16/09 noite)
            let dobrar = { (x: String) in x.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) }
            if dobrar(sub).hasPrefix(dobrar(t)) {
                let resto = sub.dropFirst(t.count).trimmingCharacters(in: CharacterSet(charactersIn: ".:…").union(.whitespaces))
                return (t, resto.isEmpty ? nil : resto)
            }
            return (t, sub)
        }
        return (t, previaDaForma(nota, titulo: t) ?? restoDaNota(nota, depoisDe: t))
    }

    /// Forma com campos: a prévia são as respostas, na ordem do método, sem a
    /// que só repete o título ("Baixar o preço…" · "Baixar o preço porque…").
    private func previaDaForma(_ nota: Nota, titulo t: String) -> String? {
        let ordem = nota.gesto?.metodoDef.campos.map(\.id) ?? []
        let dobrar = { (x: String) in x.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) }
        let respostas = nota.campos
            .sorted { (ordem.firstIndex(of: $0.key) ?? ordem.count, $0.key) < (ordem.firstIndex(of: $1.key) ?? ordem.count, $1.key) }
            // as opções vêm uma por linha: na prévia, uma vírgula entre elas
            .map { $0.value.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.joined(separator: ", ") }
            .filter { !$0.isEmpty && !dobrar($0).hasPrefix(dobrar(t)) && !dobrar(t).hasPrefix(dobrar($0)) }
        // a decisão tomada diz mais que as opções emendadas
        if let decidido = nota.campos["decidido"]?.trimmingCharacters(in: .whitespacesAndNewlines), !decidido.isEmpty {
            return "Decidi: " + decidido
        }
        if !respostas.isEmpty { return respostas.joined(separator: " · ") }
        return nil
    }

    private func restoDaNota(_ nota: Nota, depoisDe titulo: String) -> String? {
        // linha que termina sem pontuação é item de lista: vírgula entre elas
        // («Arroz, café, detergente»), não uma frase emendada
        let linhas = Caderno.prosa(de: nota.textoDeQualquerOrigem)
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let prosa = linhas.enumerated().reduce(into: "") { acc, par in
            guard par.offset > 0 else { acc = par.element; return }
            let anterior = linhas[par.offset - 1]
            acc += (".:;,!?…".contains(anterior.last ?? ".") || par.offset == 1 ? " " : ", ") + par.element
        }
        guard let r = prosa.range(of: titulo) else { return nil }
        // o título perde o ponto final: a prévia não pode começar por ele
        let resto = prosa[r.upperBound...].drop { ".:;,".contains($0) || $0.isWhitespace }.trimmingCharacters(in: .whitespacesAndNewlines)
        return resto.isEmpty ? nil : resto
    }

    /// O rodapé que assina a nota: quando, e as marcas que valem (origem,
    /// recordada). O domínio fica à direita, no chip.
    private func rodape(_ nota: Nota) -> String {
        // hoje o grupo já diz "Hoje": o rodapé diz a hora. Nos outros dias, a
        // data — "Há 15 dias" obrigava a contar (dono, 16/09: "faz mais sentido
        // colocar a data"); o ano só quando não é este
        let quando = nota.criadaEm
        let cal = Calendar.current
        var partes = [cal.isDateInToday(quando)
                      ? quando.formatted(date: .omitted, time: .shortened)
                      : cal.isDate(quando, equalTo: .now, toGranularity: .year)
                        ? quando.formatted(.dateTime.day().month(.wide))
                        : quando.formatted(.dateTime.day().month(.wide).year())]
        // nota viva: «3 versões · 20 de setembro»
        if versoes(nota) > 1 { partes.insert("\(versoes(nota)) versões", at: 0) }
        if let origem = nota.origem.etiqueta { partes.append(origem) }
        if nota.queimada, nota.minutosEscritos >= 1 { partes.append("\(nota.minutosEscritos) min") }
        let recordadas = Revisoes.contagem(nota.uuid)
        if recordadas > 0 { partes.append("recordada \(recordadas)×") }
        return partes.joined(separator: " · ")
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
            // uma lista mostra os itens ("passagens · hotel · seguro"), não o
            // nome da forma nem só a data
            if nota.gesto == .destaque {
                let itens = Caderno.prosa(de: nota.textoDeQualquerOrigem)
                    .split(whereSeparator: \.isNewline).dropFirst()
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                if !itens.isEmpty { return VozDoAutor.truncar(itens.joined(separator: " · "), 56) + sufixo }
            }
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
