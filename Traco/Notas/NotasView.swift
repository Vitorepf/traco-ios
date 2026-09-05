import SwiftData
import UIKit
import SwiftUI

struct NotasView: View {
    @Bindable var sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var tamanhoTexto
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]
    @State private var conversaNotas = ConversaNotas()
    private var busca: String {
        get { conversaNotas.entrada }
        nonmutating set { conversaNotas.entrada = newValue }
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
    /// Q4: seleção múltipla. Vazio = modo normal; não-vazio = modo lote.
    @State private var escolhidas: Set<UUID> = []
    @State private var confirmarLote = false
    @State private var mostrarTrabalhos = false

    var body: some View {
        telaNotas
            // ADR 04n: a busca por letras é a primeira; o índice de sentido
            // responde logo atrás, com o que ela não achou
            .onChange(of: busca) { _, nova in procurarPeloSentido(nova, entre: filtradas) }
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
                Button { mostrarTrabalhos = true } label: {
                    Label("Trabalhos", systemImage: "doc.text")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.ambarTinta)
                        .frame(minHeight: Tema.alvo)
                }
                .padding(.horizontal, Tema.margem)
                .accessibilityHint("Retoma intenções, versões e próximos atos")
                .accessibilityIdentifier("abrir-trabalhos")
                chips
                lista
            }
        }
        .sheet(isPresented: $mostrarTrabalhos) { TrabalhosView() }
        // ADR 05e: a barra vive no pé, na zona do polegar, acima da navegação
        // e do teclado; o cartão da sábia sobe sobre ela só quando há conversa
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 8) {
                cartaoDaSabia
                campoBusca
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: conversaNotas.estado)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: conversaNotas.semModelo)
            .transaction { if reduceMotion { $0.disablesAnimations = true } }
            .onChange(of: conversaNotas.trocas.count) { antes, depois in
                if depois > antes {
                    Toque.suave()
                    AccessibilityNotification.Announcement("A sábia respondeu. A resposta está no cartão.").post()
                }
            }
            // VoiceOver: o cartão sobe sozinho no pé da tela — quem não vê precisa ouvir
            .onChange(of: conversaNotas.estado) { _, estado in
                switch estado {
                case .pensando: AccessibilityNotification.Announcement("A sábia está pensando.").post()
                case .falhou: AccessibilityNotification.Announcement("A sábia não respondeu. Repetir pergunta disponível.").post()
                default: break
                }
            }
            .onChange(of: conversaNotas.semModelo) { _, sem in
                if sem { AccessibilityNotification.Announcement("A sábia " + Sabia.porOndeEmPalavras + ". A busca continua.").post() }
            }
            .padding(.top, 8)
            .background(Tema.fundo.opacity(0.96))
        }
    }

    // MARK: ADR 05e — perguntar pela barra

    @State private var avaliada: Set<String> = []

    private var conversa: [Sessao.TrocaNasNotas] { conversaNotas.trocas }
    private var pensando: Bool { conversaNotas.pensando }
    private var titulosNaPergunta: [String] { conversaNotas.titulos }

    private func perguntar() {
        conversaNotas.perguntar(disponivel: Sabia.disponivel) { pergunta, anteriores in
            await sessao.responderNasNotas(pergunta, conversa: anteriores, no: context)
        }
    }

    private func repetirPergunta() {
        conversaNotas.repetir(disponivel: Sabia.disponivel) { pergunta, anteriores in
            await sessao.responderNasNotas(pergunta, conversa: anteriores, no: context)
        }
    }

    @ViewBuilder private var cartaoDaSabia: some View {
        if conversaNotas.temCartao {
            VStack(alignment: .leading, spacing: 10) {
                if let ultima = conversa.last, conversaNotas.perguntaParaRepetir == nil {
                    Text("A SÁBIA, SOBRE: \(ultima.pergunta)".uppercased())
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(Tema.tintaFraca)
                        .lineLimit(2)
                    // teto de altura: a resposta tem até 900 caracteres e a
                    // lista tem de continuar visível atrás (critique-information-density)
                    ScrollView {
                        Text(ultima.resposta)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("resposta-sabia-notas")
                    }
                    .frame(maxHeight: 220)
                    if !titulosNaPergunta.isEmpty {
                        Text("Foram junto: " + titulosNaPergunta.prefix(4).joined(separator: " · ")
                             + (titulosNaPergunta.count > 4 ? " · e mais \(titulosNaPergunta.count - 4)" : ""))
                            .font(Tema.label)
                            .foregroundStyle(Tema.tintaFraca)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if !avaliada.contains(ultima.resposta) {
                        HStack(spacing: 14) {
                            Button("serviu") { Sinais.resposta(ultima.resposta, forma: nil, serviu: true); avaliada.insert(ultima.resposta); Toque.leve() }
                            Button("não serviu") { Sinais.resposta(ultima.resposta, forma: nil, serviu: false); avaliada.insert(ultima.resposta); Toque.leve() }
                        }
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .buttonStyle(PressaoDiscreta())
                    }
                }
                if pensando {
                    Text("a sábia pensa…")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaFraca)
                        .accessibilityIdentifier("sabia-pensando-notas")
                }
                if let pergunta = conversaNotas.perguntaParaRepetir {
                    ScrollView {
                        Text(pergunta)
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tinta)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("pergunta-pendente-notas")
                    }
                    .frame(maxHeight: 120)
                    Text(conversaNotas.estado == .interrompida(pergunta)
                         ? "a pergunta foi interrompida."
                         : "a sábia não respondeu.")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("sabia-falhou-notas")
                    Button("Repetir pergunta") { repetirPergunta() }
                        .font(Tema.meta)
                        .foregroundStyle(Tema.ambarTinta)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityIdentifier("repetir-pergunta-notas")
                }
                if conversaNotas.semModelo {
                    Text("a sábia " + Sabia.porOndeEmPalavras + ". Sem ela, a busca continua.")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("sem-conta-notas")
                }
                HStack {
                    if conversa.count > 1 {
                        Text("\(conversa.count) trocas")
                            .font(Tema.label)
                            .foregroundStyle(Tema.tintaFraca)
                    }
                    Spacer()
                    Button("Fechar") {
                        var t = Transaction(); t.disablesAnimations = true
                        withTransaction(t) { conversaNotas.fechar(); avaliada = [] }
                    }
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityIdentifier("fechar-sabia-notas")
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
            .padding(.horizontal, Tema.margem)
            .transition(Tema.transicao(.move(edge: .bottom).combined(with: .opacity), reduzido: reduceMotion))
            // um cartão, lido inteiro na ordem: rótulo, resposta, quem foi junto, avaliação
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Cartão da sábia")
            .accessibilityIdentifier("cartao-sabia-notas")
        }
    }

    /// SPEC §20: navegar é da barra inferior. Aqui o título e o export do
    /// conjunto visível — a casa de escrever não carrega este chrome.
    private var topbar: some View {
        TituloTela(texto: escolhidas.isEmpty ? "Notas" : "\(escolhidas.count) escolhida\(escolhidas.count == 1 ? "" : "s")") {
            if !escolhidas.isEmpty {
                loteAcoes
            } else if !filtradas.isEmpty {
                HStack(spacing: 14) {
                    menuOrdem
                    // texto solto no canto não parecia botão (critique-affordance);
                    // agora é o gesto de compartilhar que todo iPhone conhece (jakobs-law)
                    Button {
                        contextoURL = Corpus.urlComoContexto(
                            filtradas.map(FatiaCorpus.de), nome: "traco-contexto.md")
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(width: 34, height: 34)
                            .background(Tema.chip, in: Circle())
                    }
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityLabel("Como contexto")
                    .accessibilityHint("Entrega estas notas à sua IA, sem servidor")
                }
                // dois controles de chrome ao lado do título: em AX5 cresciam
                // até partir "Notas" em duas linhas; teto igual ao das barras
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
        }
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
            HStack(spacing: 4) {
                if tamanhoTexto.isAccessibilitySize {
                    // AX5: o nome não cabe ao lado do título e virava "…"
                    Image(systemName: "arrow.up.arrow.down")
                        .font(Tema.meta.weight(.medium))
                } else {
                    Text(ordem.nome)
                        .font(Tema.meta.weight(.medium))
                }
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(Tema.tintaSuave)
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(Tema.chip, in: Capsule())
        }
        .menuStyle(.button)
        .buttonStyle(PressaoDiscreta())
        .frame(minHeight: Tema.alvo)
        .contentShape(Rectangle())
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
        .frame(minHeight: Tema.alvo)
        .buttonStyle(PressaoDiscreta())
    }

    private var campoBusca: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Tema.tintaFraca)
                .accessibilityHidden(true)
            TextField(
                "",
                text: $conversaNotas.entrada,
                prompt: Text("Buscar ou perguntar").foregroundStyle(Tema.tintaFraca)
            )
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .font(Tema.corpo)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.send)
                .onSubmit { perguntar() }
                .accessibilityIdentifier("busca-notas")
                .accessibilityLabel("Buscar ou perguntar")
                .accessibilityValue(busca.isEmpty ? "vazio" : busca)
                .accessibilityHint(filtro == .trancadas ? "Indisponível no filtro de trancadas" : "Escrever filtra; enviar pergunta à sábia")
            if !busca.isEmpty {
                // ADR 05e: enviar é perguntar — o mesmo botão do calendário
                Button {
                    perguntar()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Tema.chipAtivo, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .frame(width: Tema.alvo, height: Tema.alvo)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDiscreta())
                .disabled(pensando)
                .accessibilityLabel("Perguntar à sábia")
                .accessibilityIdentifier("perguntar-notas")
            }
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
                .buttonStyle(PressaoDiscreta())
                .transition(Tema.transicao(.opacity.combined(with: .scale(scale: 0.8)), reduzido: reduceMotion))
                .accessibilityIdentifier("limpar-busca")
                .accessibilityLabel("Limpar busca")
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: Tema.alvo)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 8)
        .opacity(filtro == .trancadas ? 0.4 : 1)
        .disabled(filtro == .trancadas)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Todas" é a saída: sem ela, filtrar era um caminho sem volta
                // óbvio (critique-affordance)
                Button {
                    Toque.selecao()
                    withAnimation(.easeOut(duration: 0.25)) {
                        filtro = nil
                        filtroDominio = nil
                    }
                } label: {
                    Text("Todas")
                        .font(Tema.meta.weight(.medium))
                        .foregroundStyle(filtro == nil ? .white : Tema.tintaSuave)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(minHeight: 34)
                        .background(Capsule().fill(filtro == nil ? Tema.chipAtivo : Tema.chip))
                }
                .frame(minHeight: Tema.alvo)
                .contentShape(Rectangle())
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("filtro-todas")
                .accessibilityAddTraits(filtro == nil ? [.isSelected] : [])
                ForEach(FiltroNotas.allCases) { item in
                    chipFiltro(
                        titulo: item.rawValue,
                        ligado: filtro == item,
                        id: "filtro-\(item.slug)"
                    ) {
                        filtro = filtro == item ? nil : item
                    }
                }
                ForEach(Dominio.allCases) { item in
                    chipFiltro(
                        titulo: item.nome,
                        ligado: filtroDominio == item,
                        id: "filtro-dominio-\(item.rawValue)"
                    ) {
                        filtroDominio = filtroDominio == item ? nil : item
                    }
                }
                Color.clear.frame(width: 4)
            }
            .padding(.horizontal, Tema.margem)
        }
        // MESMO defeito da régua do caderno: ScrollView horizontal sem altura
        // engole todo o espaço que o VStack oferece. A fileira de filtros
        // flutuava no meio de um bloco de ~280pt — 110pt de vão até a busca e
        // 128pt até a lista, três ilhas soltas onde devia haver uma coluna
        // (law-of-proximity).
        .frame(height: Tema.alvo)
        .mask(
            HStack(spacing: 0) {
                Rectangle()
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 28)
            }
        )
        .padding(.bottom, 8)
        .accessibilityHint("Um filtro por vez")
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

    private func chipFiltro(titulo: String, ligado: Bool, id: String,
                            acao: @escaping () -> Void) -> some View {
        Button {
            Toque.selecao()
            withAnimation(.easeOut(duration: 0.25)) { acao() }
        } label: {
            Text(titulo)
                .font(Tema.meta.weight(.medium))
                .foregroundStyle(ligado ? .white : Tema.tintaSuave)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 34)
                .background(Capsule().fill(ligado ? Tema.chipAtivo : Tema.chip))
        }
        .frame(minHeight: Tema.alvo)
        .contentShape(Rectangle())
        .buttonStyle(PressaoDiscreta())
        .accessibilityAddTraits(ligado ? [.isSelected] : [])
        .accessibilityIdentifier(id)
        .accessibilityLabel(titulo)
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
            Text("PELO SENTIDO")
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
                .padding(.top, 20)
                .padding(.bottom, 2)
                .accessibilityAddTraits(.isHeader)
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
            Text("A VOLTA")
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
                .padding(.top, 20)
                .padding(.bottom, 6)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("secao-volta")
            // a mesma nota volta a aparecer no mês: o id tem de ser outro, ou o
            // LazyVStack descarta uma das duas linhas (visto na captura 31)
            ForEach(Array(devidas.enumerated()), id: \.offset) { i, par in
                Button {
                    sessao.abrir(par.nota)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Volta.cobranca(par.campo))
                            .font(Tema.chrome.weight(.semibold))
                            .foregroundStyle(Tema.tinta)
                            .lineLimit(2)
                        Text(titulo(par.nota))
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaFraca)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .padding(.vertical, 12)
                    .frame(minHeight: Tema.alvo)
                }
                .buttonStyle(PressaoDiscreta())
                .accessibilityLabel("\(Volta.cobranca(par.campo)) \(titulo(par.nota))")
                .accessibilityHint("Abre a nota com o campo da volta")
                .accessibilityIdentifier("volta-notas")
                if i < devidas.count - 1 {
                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                }
            }
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
                VStack(alignment: .leading, spacing: 12) {
                    Text(vazioTitulo)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                    // a saída tem que ser do BURACO em que o autor caiu: quando
                    // o vazio é da busca, "escrever na página" joga fora o que
                    // ele estava procurando em vez de devolver o arquivo
                    if busca.isEmpty, filtro == nil, filtroDominio == nil {
                        Button("escrever na página") {
                            sessao.novaPagina()
                            sessao.mostrarNotas = false
                        }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                    } else {
                        Button("ver todas as notas") {
                            busca = ""
                            filtro = nil
                            filtroDominio = nil
                        }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityIdentifier("limpar-busca")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Tema.margem)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
                        secaoDaVolta
                        ForEach(meses(visiveis), id: \.titulo) { secao in
                            Text(secao.titulo)
                                .font(Tema.label)
                                .tracking(Tema.trackingLabel)
                                .foregroundStyle(Tema.tintaFraca)
                                .padding(.top, 20)
                                .padding(.bottom, 6)
                                .accessibilityAddTraits(.isHeader)
                            ForEach(Array(secao.notas.enumerated()), id: \.element.uuid) { i, nota in
                                botaoNota(nota)
                                // sem separador depois do último: a lista fecha
                                if i < secao.notas.count - 1 {
                                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                                }
                            }
                        }
                        secaoPeloSentido

                    }
                    .padding(.horizontal, Tema.margem)
                }
                // o mesmo gesto do caderno (CadernoView:68): arrastar a lista
                // devolve a tela — sem isto o teclado da busca prendia a tab
                // bar atrás de si e a única saída era o "x" (jakobs-law: no
                // Notes, arrastar a lista dispensa o teclado)
                .scrollDismissesKeyboard(.interactively)
            }
        }
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
            // a seção de hoje se chama HOJE: repetir "agosto" no cabeçalho e
            // "hoje" em cada linha gasta a única informação temporal útil
            let titulo = cal.isDateInToday(nota.criadaEm)
                ? "HOJE"
                : f.string(from: nota.criadaEm).uppercased()
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
        if !busca.isEmpty {
            return n == 1 ? "1 nota com “\(busca)”" : "\(n) notas com “\(busca)”"
        }
        return n == 1 ? "1 nota" : "\(n) notas"
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
        // Dois botões irmãos — nunca um Button dentro do outro. O chip de
        // domínio promete um toque; aninhado, o toque abria a nota.
        HStack(alignment: .center, spacing: 8) {
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
                            .font(.body.weight(.semibold))
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
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Tema.tintaSuave)
                        Text("não se relê · \(VozDoAutor.relativo(nota.criadaEm))")
                            .font(.subheadline)
                            .foregroundStyle(Tema.tintaFraca)
                    } else {
                        DestaqueBusca.texto(titulo(nota), termo: busca, base: Tema.tinta)
                            .font(Tema.chrome.weight(.semibold))
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            if let g = nota.gesto {
                                Text(g.nome.uppercased())
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(Tema.tintaSuave)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Tema.chip, in: Capsule())
                            }
                            let sub = subtitulo(nota)
                            if !(sub == "hoje" && busca.isEmpty) {
                                DestaqueBusca.texto(sub, termo: busca, base: Tema.tintaFraca)
                                    .font(Tema.meta)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressaoDiscreta())
            .tint(Tema.tinta)
            .accessibilityLabel(nota.trancada ? "Expressiva trancada" : titulo(nota))
            .accessibilityHint(nota.trancada ? "Reabrir pede confirmação dupla" : "Segure para recordar a memória")
            .accessibilityIdentifier("nota-notas")

            if !nota.fechada, nota.gesto != .expressiva, nota.dominio != nil || nota.dominioTravado {
                // ADR 05d: o chip abre o menu; nada apaga num toque
                ChipDominio(atual: nota.dominio, travado: nota.dominioTravado,
                            aoEscolher: { sessao.escolherDominio($0, na: nota, no: context) },
                            aoDevolver: { sessao.devolverDominio(nota, no: context) })
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, escolhidas.contains(nota.uuid) ? 10 : 0)
        .frame(minHeight: Tema.alvo)
        .background(
            escolhidas.contains(nota.uuid) ? Tema.chip : .clear,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .animation(.easeOut(duration: 0.15), value: escolhidas.contains(nota.uuid))
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
            let trecho = VozDoAutor.trecho(em: nota.vozDoAutor, termo: busca)
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
        let respostas = nota.campos.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
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
