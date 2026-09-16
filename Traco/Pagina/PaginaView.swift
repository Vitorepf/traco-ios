import SwiftData
import SwiftUI
import UIKit

struct PaginaView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var tamanhoTexto
    @Bindable var sessao: Sessao
    /// Q2: os títulos das outras notas alimentam o completar de `[[ligação]]`.
    @Query(sort: \Nota.editadaEm, order: .reverse) private var notas: [Nota]
    @FocusState private var focoPagina: Bool
    @State private var mostrarCampos = false
    @State private var perguntaDaPagina = ""
    @State private var ditado = Ditado()
    @State private var baseDoDitado = ""
    /// A folha dos campos está a subir ou em cena: o encaixe inteiro (cartão e
    /// pé) sai POR CORTE antes de ela subir e volta por corte quando ela desce.
    /// Com o encaixe em cena enquanto o teclado descia, o papel crescia na hora
    /// (o `UIScrollView` recebe o frame final de imediato) e os rótulos dos
    /// campos — conteúdo do próprio papel — ficavam legíveis entre o cartão e o
    /// pé por ~100 ms, sem e com Reduzir Movimento (G4 final da V12, A1; ADR
    /// 08f, V12-E). Sem encaixe, a única superfície naquela faixa é o papel.
    @State private var folhaEmCena = false
    @State private var campoDaFormaEmFoco = false
    @State private var trabalhoAberto: Trabalho?
    @ScaledMetric(relativeTo: .body) private var corpoFolga: CGFloat = 9
    @State private var abrirArquivo = false
    @State private var abrirDesenho = false
    @State private var lenteAberta = false
    @State private var chegou = false
    #if DEBUG
    /// A sessão da Página viva, para o teste hospedado (`EscritaVisivelTests`)
    /// pôr o cartão e o aviso de pé sem simular a análise. Só em DEBUG.
    nonisolated(unsafe) static weak var sessaoViva: Sessao?
    #endif

    var body: some View {
        // §20: a navegação é da RAIZ. Este Empilha era resíduo da arquitetura
        // antiga e renderizava a NotasView uma SEGUNDA vez, por baixo da camada
        // de arquivo que a raiz já mostra.
        pagina
            .opacity(chegou || reduceMotion ? 1 : 0)
            .sheet(isPresented: $mostrarCampos) {
                if let gesto = sessao.gesto, gesto != .expressiva {
                    VStack(alignment: .leading, spacing: 0) {
                        // "voltar" em tinta, não no âmbar do tint (2,0:1 sobre
                        // branco, ADR 02h): o cabeçalho é o de toda folha
                        CabecalhoDeFolha(saida: .voltar, aoSair: {
                            guard sessao.salvar(no: context) else { return }
                            mostrarCampos = false
                        }, prefixo: "campos")
                            .padding(.horizontal, Tema.margem)
                            .padding(.top, 16)
                        // a folha tem cabeçalho de verdade: o nome da forma é
                        // TÍTULO, não um sexto rótulo. E o âmbar sai do botão
                        // que descarta — o olho não entra pela ação destrutiva
                        HStack(alignment: .firstTextBaseline) {
                            Text(gesto.nome)
                                .font(Tema.tituloTela)
                                .tracking(Tema.trackingTitulo)
                                .foregroundStyle(Tema.tinta)
                                .accessibilityAddTraits(.isHeader)
                            Spacer(minLength: 8)
                            Button("Deixar como nota") {
                                sessao.soltarForma()
                                mostrarCampos = false
                            }
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .buttonStyle(.discreto)
                            .accessibilityIdentifier("soltar-na-folha")
                            .accessibilityHint("Desfaz a forma; o seu texto fica intacto")
                        }
                        .padding(.horizontal, Tema.margem)
                        .padding(.top, 20)
                        .padding(.bottom, 12)

                        ScrollView {
                            CamposFormaView(
                                gesto: gesto,
                                campos: $sessao.campos,
                                conferenciaDevida: sessao.conferenciaDevida,
                                campoInicial: sessao.campoPedido,
                                aoEncadear: { e in
                                    mostrarCampos = false
                                    sessao.encadear(e, no: context)
                                }
                            )
                                .padding(.bottom, 24)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .presentationDetents([.large]) // ADR 04u: folha de leitura nasce inteira, nunca cortada no médio
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Tema.superficie)
                }
            }
        .sheet(item: $trabalhoAberto) { trabalho in TrabalhoView(trabalho: trabalho) }
        .tint(Tema.ambar)
        .sheet(isPresented: $sessao.mostrarRecordar) {
            RecordarView(
                texto: sessao.recordarTexto,
                campos: sessao.recordarCampos,
                gesto: sessao.recordarGesto,
                aoRevelar: { sessao.cumprirRevisaoPendente(no: context) },
                aoCobrarAntes: { sessao.cobrarAntesPendente() },
                aoProxima: sessao.temProximaFila ? { sessao.proximaDaFila(no: context) } : nil,
                aoAdiar: { sessao.adiarPendente() },
                aoPular: sessao.temProximaFila ? { sessao.pularDaFila(no: context) } : nil,
                degrau: sessao.recordarUUID.map { Revisoes.nivel($0) } ?? 0,
                retrato: sessao.retratoAtual()
            )
            .id(sessao.recordarUUID)
            .presentationBackground(Tema.superficie)
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            #if DEBUG
            Self.sessaoViva = sessao
            #endif
            // a chegada assenta em vez de piscar pronta
            withAnimation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { chegou = true }
            sessao.trancarExpressivasVencidas(no: context)
            sessao.varrerAnexosOrfaos(no: context)
            sessao.rearmarSeries(no: context)
            // o Trabalho recebe as notas da pessoa que falam da intenção como
            // material (a mesma régua de palavras da busca; até seis, 600 letras)
            MotorTrabalho.materialDoAutor = { intencao in
                let notas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
                let palavras = NotasFiltro.palavras(intencao)
                // uma palavra do assunto já basta ("Traço"); as mais parecidas primeiro
                var pontuadas: [(texto: String, pontos: Int, quando: Date)] = []
                for n in notas where !n.fechada && n.gesto != .expressiva && n.temVoz {
                    let texto = n.textoDeQualquerOrigem
                    let pontos = NotasFiltro.pontuacao(texto, palavras: palavras)
                    if pontos >= 1 { pontuadas.append((texto, pontos, n.editadaEm)) }
                }
                pontuadas.sort { a, b in a.pontos == b.pontos ? a.quando > b.quando : a.pontos > b.pontos }
                return pontuadas.prefix(6).map { String($0.texto.prefix(600)) }
            }
            // ADR 04i: o retrato lê o disco quando a sábia precisa dele
            sessao.notasParaRetrato = {
                ((try? context.fetch(FetchDescriptor<Nota>())) ?? []).map(\.paraRetrato)
            }
            sessao.observadosParaRetrato = {
                AcessoTrabalho.juizosObservados(
                    de: (try? context.fetch(FetchDescriptor<Trabalho>())) ?? [],
                    no: context)
            }
            // ADR 04n / 04p: o índice de sentido e a entrada do Mac, no arranque
            sessao.sincronizarIndice(no: context)
            sessao.recolherEntrada(no: context)
            restaurarFoco()
            #if DEBUG
            print("TRACO_PAGINA_PRONTA")
            #endif
        }
        .onChange(of: sessao.aba) { _, nova in
            if nova != .escrever {
                focoPagina = false
                Teclado.recolher()
            } else {
                restaurarFoco()
            }
        }
        .onChange(of: focoPagina) { _, agora in
            if agora { sessao.acabouDeAbrir = false }
        }
        .onChange(of: sessao.mostrarNotas) { _, aberto in
            if aberto {
                focoPagina = false
                Teclado.recolher()
            } else {
                restaurarFoco()
            }
        }
        .onChange(of: sessao.mostrarPadroes) { _, aberto in
            if aberto {
                focoPagina = false
                Teclado.recolher()
            } else if !sessao.mostrarNotas {
                restaurarFoco()
            }
        }
        .onChange(of: sessao.confirmacao != nil) { _, coberto in
            if !coberto { restaurarFoco() }
        }
        // §3: a página em branco chega com o cursor pronto — também a que
        // nasce depois de Concluir (a barra tinha três "pagina" e o toque do
        // fluxo caía fora do editor; com o foco de volta, nada depende dele)
        // o cartão vestido vive enquanto o autor escreve na PÁGINA (o "um toque
        // desfaz" fica à mão), mas sai assim que ele começa a preencher a FORMA:
        // ali ele cobre os campos de baixo, e cobrir é fricção (§17)
        // ATENÇÃO: vestir a forma cria os campos VAZIOS, o que também muda
        // `campos`. Só o CONTEÚDO conta — senão o cartão morria no instante
        // em que nascia (16 fluxos caíram assim).
        .onChange(of: sessao.camposComResposta) { _, agora in
            if agora, case .vestida? = sessao.cartao {
                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { sessao.cartao = nil }
            }
            // ADR 04r: o primeiro caractere num campo é ATO — a sábia instiga aqui
            if agora { sessao.instigarSePreciso() }
        }
        .onChange(of: sessao.geracaoDaPagina) { _, _ in
            // a página nova troca o editor de identidade no mesmo ciclo: o foco
            // pedido ANTES da troca caía no editor velho e se perdia (1 em 3)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(80))
                if !sessao.mostrarNotas { restaurarFoco() }
            }
        }
        // a forma vestiu sozinha, mas a folha NÃO sobe sozinha: modal no meio da
        // escrita rouba a página. A alça "abrir campos" é a porta, a um toque.
        .onChange(of: sessao.gesto) { _, g in
            // duas comparações numa linha estouravam o type-checker do Xcode 27
            let semForma: Bool = g == nil
            if semForma || g == .expressiva { mostrarCampos = false }
        }
        .onChange(of: mostrarCampos) { _, aberto in
            if !aberto {
                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { folhaEmCena = false }
                restaurarFoco()
            }
        }
        // VoiceOver: o cartão muda sozinho no rodapé — quem não vê precisa ouvir
        // (a forma vestida e a expressiva já são anunciadas pela Sessão)
        .onChange(of: sessao.cartao) { _, novo in
            guard let msg = anuncio(novo) else { return }
            AccessibilityNotification.Announcement(msg).post()
        }
        .onChange(of: sessao.timerEsgotou) { _, esgotou in
            if esgotou { sessao.esgotarTimer(no: context) }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                sessao.alinharTimerAoRelogio()
                sessao.trancarExpressivasVencidas(no: context)
                sessao.recolherEntrada(no: context)
                if !sessao.mostrarNotas { restaurarFoco() }
            case .inactive, .background:
                // TODA página em voo grava ao sair de cena, não só a do timer.
                // Antes disto, escrever e a tela bloquear — ou uma ligação, ou
                // o dedo no botão errado — apagava o que o autor tinha acabado
                // de escrever, porque o texto só existia na memória até
                // "Concluir". `salvar` ignora página vazia e reusa o notaUUID,
                // então isto não cria nota do nada nem duplica.
                sessao.salvar(no: context)
            default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            sessao.alinharTimerAoRelogio()
            sessao.trancarExpressivasVencidas(no: context)
        }
        .onOpenURL { url in
            if let destino = Rota.daURL(url) { seguirRota(destino) }
        }
        .onReceive(NotificationCenter.default.publisher(for: Rota.mudou)) { _ in
            if let destino = Rota.consumir() { seguirRota(destino) }
        }
        // ADR 05u: no arranque frio o intent corre antes de esta view escutar;
        // a rota fica pendente e é consumida quando a cena está pronta
        .onAppear {
            if let destino = Rota.consumir() { seguirRota(destino) }
        }
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirRevisao)) { aviso in
            // §17: um passo — a notificação abre direto o Recordar da nota
            guard let uuid = aviso.object as? UUID,
                  let nota = Sessao.buscar(uuid: uuid, no: context) else { return }
            // o degrau só sobe quando o autor REVELA — abrir e fechar não é revisão
            sessao.revisaoPendente = uuid
            sessao.recordarDaNotas(nota)
        }
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirFila)) { _ in
            sessao.abrirFilaDoDia(no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirSemana)) { _ in
            // ADR q: o aviso de domingo abre os Padrões, onde a semana está
            sessao.irPara(.padroes, no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirSerie)) { aviso in
            guard let serie = aviso.object as? UUID else { return }
            let dia = aviso.userInfo?["dia"] as? Int ?? 2
            sessao.abrirDiaDaSerie(serie, dia: dia, no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirGatilho)) { aviso in
            guard let uuid = aviso.object as? UUID,
                  let nota = Sessao.buscar(uuid: uuid, no: context) else { return }
            sessao.abrir(nota)
        }
        // ADR 04a: o compromisso avisa; tocar no aviso abre o calendário no dia
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirCompromisso)) { _ in
            Rota.escalaCalendario = .dia
            sessao.irPara(.calendario, no: context)
        }
    }

    private var pagina: some View {
        ZStack(alignment: .bottom) {
            Tema.fundo.ignoresSafeArea()

            VStack(spacing: 0) {
                topbar
                // ADR 08u: a etiqueta de origem. Vem ANTES do texto porque é o
                // que muda como se lê o que vem depois — a página é o lugar em
                // que se confunde texto do bot com a própria voz. Mesma cápsula
                // do gesto na lista: nada de cor nova, nada de componente novo.
                if let marca = sessao.origemDaPagina.etiqueta {
                    Pilula(marca, forma: .etiqueta)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tema.margem)
                        .padding(.bottom, 8)
                        .accessibilityIdentifier("origem-nota")
                        .accessibilityLabel("Esta nota não é sua voz: \(marca)")
                }
                if sessao.paginaVazia && sessao.gesto == nil && !sessao.timerLigado {
                    // a única companhia do cursor: o dia (some no primeiro caractere)
                    Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaFraca)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tema.margem)
                        .padding(.bottom, 2)
                        .transition(.opacity)
                        .accessibilityHidden(true)
                    // ADR 05b: a data diz o que o dia espera
                    LinhaDaVolta { sessao.irPara(.notas, no: context) }
                }
                if let pergunta = sessao.perguntaPadroes {
                    cartaoPergunta(pergunta)
                }
                if sessao.timerLigado {
                    timerBar
                }
                editor
            }
        }
        .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.paginaVazia)
        // O toast vive no MESMO encaixe do cartão (`acimaDoPe`) e muda a altura
        // do papel como ele: com o foco na Página ele entra e sai por CORTE
        // (ADR 08x). Animado, ele cortava a linha ativa — 3 quadros com 1 pt
        // fora do papel em `large` no 17 Pro, com o seguidor 8 pt atrás da
        // borda que descia (ADR 09j).
        .animation(focoPagina ? nil : Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.toast)
        // o cartão entra e sai como a gaveta: quem anima é a ALTURA do encaixe.
        // MAS A GAVETA NÃO CORRE SOBRE A LINHA DO AUTOR (ADR 08x): com o foco
        // na Página, a altura do encaixe muda por CORTE.
        .animation(focoPagina ? nil : Tema.gaveta(reduzido: reduceMotion), value: sessao.cartao)
        .animation(focoPagina ? nil : Tema.gaveta(reduzido: reduceMotion), value: sessao.analisando)
    }

    /// O que fica ACIMA do pé — o aviso, o cartão da análise ou "lendo…" —
    /// dentro do mesmo encaixe da régua e das ações, que são desenho do dono
    /// (ADR 05f) e não saem do lugar: o V9 viu o cartão tomar o pé e o toque
    /// mirado em "Todas" cair no texto do cartão (fitts-law). Um sai, o outro
    /// entra — CORTANDO, nunca em fade sobre as mesmas linhas —, e quem anima é
    /// a altura do container (§21).
    /// A identidade do cartão é o CASO, não a carga: ver `acimaDoPe`.
    private func casoDoCartao(_ c: CartaoAnalisar) -> String {
        switch c {
        case .aviso: "aviso"
        case .forma: "forma"
        case .vestida: "vestida"
        case .expressiva: "expressiva"
        case .pergunta: "pergunta"
        case .resposta: "resposta"
        case .sabiaPensando: "sabiaPensando"
        case .vestido: "vestido"
        case .semConta: "semConta"
        case .conselho: "conselho"
        }
    }

    /// O encaixe acima do pé. A pilha é EXPLÍCITA porque quem a recebe é um
    /// `AnyView` (`CadernoView.acima`): apagado o tipo, o `TupleView` deixa de
    /// ser achatado pela pilha de baixo e os ocupantes espalhavam-se pela caixa
    /// do teto — o aviso nascia no meio do texto do autor (ADR 08f).
    private var acimaDoPe: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let toast = sessao.toast {
                // O aviso fala a língua das outras superfícies: cartão de raio 12,
                // largura cheia, texto na margem; vive no fluxo do pé, nunca por
                // cima das ações (a linha de recusa da gravação fica aqui até o
                // disco dizer sim, ADR 05s)
                Text(toast)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .cartao(.papel, recuo: [])
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 8)
                    .transition(Tema.transicao(.opacity.combined(with: .offset(y: 6)), reduzido: reduceMotion))
                    .accessibilityIdentifier("toast-analise")
                    .accessibilityAddTraits(.isStaticText)
            }
            if let cartao = sessao.cartao {
                // enquanto o autor ESCREVE (teclado de pé) o cartão vale uma
                // linha: a página é do texto dele. As saídas ficam à vista; a
                // prosa abre a um toque, no lugar, sem mexer no teclado.
                CartaoAnaliseView(cartao: cartao, sessao: sessao,
                                  aoAbrirCampos: { abrirCampos() },
                                  // com a folha dos campos em cena o cartão fica
                                  // como está: mudar de forma por trás dela é
                                  // desenhar o encaixe em duas geometrias
                                  recolhido: focoPagina || mostrarCampos)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 12)
                    // a troca de CASO do cartão é troca de VIEW, e ela CORTA: sem
                    // isto o SwiftUI dissolvia o texto velho sobre o novo, nas mesmas
                    // linhas — foi o que o G3 da V12 filmou entre `.forma` e
                    // `.vestida` (A1). Dentro do mesmo caso a identidade fica: a
                    // resposta da sábia chega sem reiniciar o "serviu / não serviu".
                    .transition(.identity)
                    .id(casoDoCartao(cartao))
            } else if sessao.analisando, !sessao.paginaVazia {
                // o sinal de que ALGO está acontecendo — sem ele a tela fica muda
                LinhaDeEstado("lendo…", .lendo)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tema.margem)
                    .padding(.vertical, 8)
                    .accessibilityIdentifier("analisando")
                    // "lendo…" e o cartão ocupam a MESMA linha do encaixe: um fade
                    // entre eles é o cross-fade entre irmãos legíveis que a 05y proíbe
                    .transition(.identity)
            }
        }
    }

    private var topbar: some View {
        HStack {
            // "Notas" solto lia como título da página (auditoria 13/09,
            // defeito 5): o chevron diz que é a saída para o arquivo. A
            // tentativa de 13/09 caía só em AX5, que saiu da suíte.
            Button { sessao.irNotas(no: context) } label: {
                Text("‹ Notas").lineLimit(1).fixedSize()
            }
                .keyboardShortcut("l", modifiers: .command)
                .alvo()
                .accessibilityIdentifier("notas-da-pagina")

            Spacer()

            Button("Concluir") { sessao.concluir(no: context) }
                .keyboardShortcut(.return, modifiers: .command)
                .foregroundStyle(sessao.concluirEAmbar ? Tema.ambarTinta : Tema.tintaSuave)
                .opacity(sessao.temVoz ? 1 : 0)
                .allowsHitTesting(sessao.temVoz)
                .alvo()
                .accessibilityHidden(!sessao.temVoz)
                .accessibilityIdentifier("concluir")
                .accessibilityLabel("Concluir")
                .accessibilityHint("Guarda e abre uma página nova")
        }
        .font(Tema.chrome)
        .buttonStyle(.discreto)
        .padding(.horizontal, Tema.margem)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.temVoz)
    }

    /// Custo assumido da 05y: em tamanho AX, com o cartão em cena, uma terceira
    /// barra não cabe — a régua cede. Em `large` ela FICA, cartão ou não; foi
    /// isso que o G3 da V12 pediu para provar (M1).
    static func esconderRegua(cartao: CartaoAnalisar?, tamanho: DynamicTypeSize) -> Bool {
        cartao != nil && tamanho.isAccessibilitySize
    }

    /// SPEC §4: os campos nascem abaixo do texto. Reabrir a nota não os esconde.
    private var camposAbaixo: AnyView? {
        guard sessao.temCamposDaForma, let gesto = sessao.gesto else { return nil }
        return AnyView(CamposFormaView(
            gesto: gesto,
            campos: $sessao.campos,
            conferenciaDevida: sessao.conferenciaDevida,
                                campoInicial: sessao.campoPedido,
            aoEncadear: { sessao.encadear($0, no: context) }
        ))
    }

    /// O encaixe sai por corte (transação sem animação) e SÓ DEPOIS a folha
    /// sobe com a sua própria curva: duas mudanças de estado, duas transações.
    private func abrirCampos() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { folhaEmCena = true }
        mostrarCampos = true
    }

    private var editor: some View {
        CadernoView(
            // o pé é voz + pergunta + "+": a página em branco é a hora de ditar
            // (dono, 14/09: "microfone nas notas, sempre à mão"); só a folha o cobre
            rodape: folhaEmCena || campoDaFormaEmFoco ? nil : AnyView(bottomBar),
            abaixo: camposAbaixo,
            acima: folhaEmCena ? nil : AnyView(acimaDoPe),
            esconderRegua: Self.esconderRegua(cartao: sessao.cartao, tamanho: tamanhoTexto),
            folhaEmCena: folhaEmCena,
            texto: $sessao.texto,
            foco: $focoPagina,
            folga: corpoFolga,
            abrirArquivo: $abrirArquivo,
            abrirDesenho: $abrirDesenho,
            aoTocarRegua: { sessao.tocarRegua($0) },
            aoVestirTudo: { sessao.vestirTudo() },
            titulosParaLigar: titulosParaLigar
        ) {
            var t = Transaction()
            t.disablesAnimations = true
            // a forma vestida sozinha fica com o Soltar à mão enquanto o autor
            // segue escrevendo: uma tecla não pode apagar o "um toque desfaz"
            // (e a análise seguinte, já com a forma, seria silêncio sem cartão)
            if case .vestida? = sessao.cartao {} else {
                withTransaction(t) { sessao.cartao = nil }
            }
            sessao.agendarAutoAnalise() // §17: a pausa chama a análise sozinha
        }
        .frame(maxWidth: 680)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onPreferenceChange(CampoDaFormaEmFoco.self) { emFoco in campoDaFormaEmFoco = emFoco }
    }

    /// Só o que pode ser ligado: o selo vale aqui como vale na rede (ADR 03b),
    /// e a própria nota aberta não se liga a si mesma.
    private var titulosParaLigar: [String] {
        notas
            .filter { !$0.fechada && $0.gesto != .expressiva && $0.uuid != sessao.notaUUID }
            .prefix(200)
            .map(\.tituloNaLista)
            .filter { !$0.isEmpty }
    }

    private func trabalharNisto() {
        guard sessao.gesto != .expressiva, sessao.temVoz,
              sessao.salvar(no: context), let id = sessao.notaUUID,
              let nota = Sessao.buscar(uuid: id, no: context), !nota.fechada else { return }
        do {
            let documento = DocumentoTrabalho(intencao: nota.textoDeQualquerOrigem, notaOrigemID: id)
            let trabalho = try Trabalho(documento: documento)
            context.insert(trabalho)
            try context.save()
            Teclado.recolher()
            trabalhoAberto = trabalho
        } catch {
            context.rollback()
            sessao.mostrarToast("Não consegui criar o trabalho. Sua nota continua guardada.")
        }
    }

    /// O pé da página (dono, 14/09): o mesmo campo flutuante das Notas e do
    /// Calendário. O "+" guarda Trabalhar nisto, Anexar e Lente; o microfone
    /// DITA NA PÁGINA (descarregar o pensamento por voz); escrever no campo e
    /// enviar pergunta à sábia sobre esta nota, e a resposta abre nas Notas.
    private var bottomBar: some View {
        CampoFlutuante(texto: $perguntaDaPagina, dica: "Fale com o Traço", ditado: ditado,
                       identificador: "pergunta-da-pagina", rotuloEnviar: "Perguntar à sábia",
                       rotuloDitar: "Ditar na página", aoEnviar: perguntarDaPagina,
                       aoComecarDitado: { baseDoDitado = sessao.texto }) {
            BotaoMais(rotulo: "Mais", identificador: "mais-acoes-da-nota") {
                if sessao.temVoz, sessao.gesto != .expressiva {
                    Button("Trabalhar nisto", action: trabalharNisto)
                        .accessibilityIdentifier("trabalhar-nisto")
                }
                Button("Desenhar") { abrirDesenho = true }
                    .accessibilityIdentifier("desenhar")
                Button("Anexar") { abrirArquivo = true }
                    .accessibilityIdentifier("abrir-arquivo")
                Button("Lente") {
                    guard sessao.salvar(no: context) else { return }
                    lenteAberta = true
                }
                .disabled(sessao.paginaVazia)
                .accessibilityIdentifier("abrir-lente")
            }
        }
        .padding(.horizontal, Tema.margem)
        .padding(.vertical, 8)
        .background(Tema.fundo)
        // o pé não cede ao cartão: se falta altura, é o texto do cartão que rola
        .fixedSize(horizontal: false, vertical: true)
        .sheet(isPresented: $lenteAberta) {
            LenteView(texto: sessao.texto, notaUUID: sessao.gesto == .expressiva ? nil : sessao.notaUUID, gesto: sessao.gesto,
                      retrato: sessao.retratoAtual())
                // a Lente cabe em meia folha: em folha inteira o conteúdo
                // ocupava 45 % e o resto era papel vazio (auditoria 15/09, 14)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            // o ditado escreve NA PÁGINA, depois do que já estava: a
            // transcrição chega inteira a cada vez, então a base é fixa
            ditado.aoTexto = { [weak sessao] falado in
                guard let sessao else { return }
                let sep = baseDoDitado.isEmpty || baseDoDitado.hasSuffix("\n") ? "" : " "
                sessao.texto = baseDoDitado + sep + falado
            }
        }
        .onDisappear { ditado.parar() }
    }

    /// Enviar do campo: a pergunta vai à sábia com as notas como fonte e a
    /// conversa abre nas Notas — a página é guardada antes.
    private func perguntarDaPagina() {
        let q = perguntaDaPagina.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        perguntaDaPagina = ""
        sessao.conversaNotas.entrada = q
        sessao.conversaNotas.perguntando = true
        let sessao = self.sessao
        sessao.conversaNotas.perguntar(disponivel: Sabia.disponivel) { pergunta, anteriores in
            await sessao.responderNasNotas(pergunta, conversa: anteriores, no: context)
        }
        Toque.selecao()
        sessao.irNotas(no: context)
    }

    private var timerBar: some View {
        VStack(spacing: 6) {
            // o tempo é o instrumento do método: corpo de verdade, legenda separada
            Text(tempoFormatado)
                .font(.system(.title3, design: .rounded).weight(.semibold).monospacedDigit())
                .foregroundStyle(Tema.tinta)
                .contentTransition(.numericText(countsDown: true))
                .animation(Tema.movimento(.deslocamento, .linear(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.segundosRestantes)
                .accessibilityLabel("Tempo da escrita expressiva")
                .accessibilityValue(tempoFormatado)
                .accessibilityIdentifier("timer-expressiva")
            Text("fato e sentimento — ao fim, tranca")
                .font(.caption)
                .foregroundStyle(Tema.tintaSuave)
            GeometryReader { geo in
                Capsule()
                    .fill(Tema.linha)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(sessao.segundosRestantes <= 60 ? Tema.aviso : Tema.ambar)
                            .frame(width: geo.size.width * progresso)
                            // o relógio move a barra: sob reduzido, corta a cada segundo
                            .animation(Tema.corte(.linear(duration: Tema.Duracao.relogio), reduzido: reduceMotion), value: progresso)
                    }
            }
            .frame(height: 3)
            .padding(.horizontal, Tema.margem)
            .padding(.top, 2)
            .accessibilityHidden(true)
        }
        .padding(.bottom, 8)
    }

    private var tempoFormatado: String {
        String(format: "%02d:%02d", sessao.segundosRestantes / 60, sessao.segundosRestantes % 60)
    }

    private var progresso: CGFloat {
        CGFloat(sessao.segundosRestantes) / CGFloat(15 * 60)
    }

    private func cartaoPergunta(_ pergunta: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PERGUNTA DOS PADRÕES")
                .rotulo()
            Text(pergunta)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .fixedSize(horizontal: false, vertical: true)
            Button("soltar a pergunta") {
                sessao.perguntaPadroes = nil
            }
            .font(Tema.corpo)
            .foregroundStyle(Tema.tintaSuave)
            .alvo()
            .buttonStyle(.discreto)
            .accessibilityLabel("Soltar a pergunta")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cartao(.papel, recuo: [])
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .accessibilityIdentifier("cartao-padroes")
    }

    private func anuncio(_ cartao: CartaoAnalisar?) -> String? {
        switch cartao {
        case .forma(let g, _): "Forma \(g.nome) sugerida. Abrir a forma disponível."
        case .aviso(let frase): frase
        case .sabiaPensando: "A sábia está pensando. Parar de esperar disponível."
        case .resposta: "A sábia respondeu. A resposta está no cartão."
        case .vestido: "Vestido. Desfazer disponível."
        case .semConta: "A sábia " + Sabia.porOndeEmPalavras + "."
        case .conselho: "Conselho dos mestres no cartão."
        default: nil
        }
    }

    private func seguirRota(_ destino: Rota.Destino) {
        switch destino {
        case .novaPagina:
            guard sessao.salvar(no: context) else { return }
            sessao.novaPagina()
            sessao.mostrarNotas = false
            sessao.mostrarPadroes = false
        // ADR 05w: um toque fora do app → página em branco com o teclado pronto.
        // O foco só entra com a página livre (`restaurarFoco` guarda cobertura
        // e confirmação); coberta, entra quando a cobertura sai.
        case .captura(let ditado):
            sessao.irPara(.escrever, no: context)
            guard sessao.aba == .escrever, sessao.salvar(no: context) else { return }
            sessao.novaPagina()
            sessao.mostrarNotas = false
            sessao.mostrarPadroes = false
            // o teclado recolhido por arrasto deixa `focoPagina` em true (a
            // régua segue o foco): só a transição false → true o levanta
            focoPagina = false
            DispatchQueue.main.async { restaurarFoco() }
            if ditado { sessao.mostrarToast("Toque no microfone do teclado para ditar.") }
        case .notas:
            // `mostrarNotas = true` só mudava `aba`; a camada do arquivo lê
            // `abaArquivo`, e do calendário o link ficava no calendário
            sessao.irPara(.notas, no: context)
        case .calendario:
            sessao.irPara(.calendario, no: context)
            NotificationCenter.default.post(name: Rota.mudou, object: nil)
        case .recordar:
            sessao.recordarMaisRecente(no: context)
        case .anotar(let texto):
            // ADR 05a: pela rota, a entrada é recolhida na hora
            Entrada.depositar(texto, raiz: Entrada.raizDoApp)
            sessao.recolherEntrada(no: context)
        // ADR 05u: entidade chega por id; o selo e o acesso são revalidados
        // AQUI, não só na consulta — a proteção pode ter vindo depois
        case .nota(let id):
            guard let nota = Sessao.buscar(uuid: id, no: context), !nota.fechada,
                  nota.gesto != .expressiva else {
                sessao.mostrarToast("Essa nota não está disponível.")
                return
            }
            guard sessao.salvar(no: context) else { return }
            sessao.abrir(nota)
            sessao.mostrarNotas = false
            sessao.mostrarPadroes = false
        case .trabalho(let id):
            guard let trabalho = (try? context.fetch(FetchDescriptor<Trabalho>()))?.first(where: { $0.uuid == id }),
                  AcessoTrabalho.permitido(trabalho, no: context) else {
                sessao.mostrarToast("Esse trabalho não está disponível.")
                return
            }
            guard sessao.salvar(no: context) else { return }
            trabalhoAberto = trabalho
        case .compromisso(_, let inicio):
            Rota.escalaCalendario = .dia
            sessao.agenda?.ancora = Calendario.inicioDoDia(inicio, sessao.agenda?.cal ?? Calendario.gregoriano())
            sessao.irPara(.calendario, no: context)
            NotificationCenter.default.post(name: Rota.mudou, object: nil)
        }
    }

    /// Página livre: o cursor volta. Notas, padrões ou confirmação cobrem — o teclado some.
    /// A casa e o arquivo vivem ao MESMO tempo (§20): sem esta guarda a página
    /// continuava com o foco enquanto o autor estava no Perfil, e o teclado
    /// ficava preso numa tela sem campo nenhum.
    private func restaurarFoco() {
        guard sessao.aba == .escrever, sessao.confirmacao == nil,
              sessao.fechoExpressiva == nil, !mostrarCampos
        else { return }
        // nota aberta da lista chega sem teclado: metade da nota ficava
        // escondida atrás dele (auditoria 15/09, 11). A flag NÃO se consome
        // aqui: `mostrarNotas` e `aba` mudam no mesmo abrir e chamam isto
        // duas vezes — consumida na primeira, a segunda levantava o teclado.
        // Quem a apaga é o toque do autor no papel (`focoPagina` fica true).
        if sessao.acabouDeAbrir { return }
        focoPagina = true
    }
}

/// As ações da página eram palavras soltas numa faixa: sem contêiner, sem
/// borda, sem fundo — nada dizia que eram tocáveis (critique-affordance).
private struct BarraBotaoStyle: ButtonStyle {
    @Environment(\.isEnabled) private var ativo
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                Tema.superficieAlta.opacity(configuration.isPressed ? 1 : 0.85),
                in: RoundedRectangle(cornerRadius: Tema.Raio.controle, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Tema.Raio.controle, style: .continuous)
                    .strokeBorder(Tema.luzBorda, lineWidth: 0.5)
            }
            // a pílula mede 38; o alvo mede 44 (3 para cada lado, no vão da barra)
            .alvo(folgaV: 3)
            // desabilitado é OPACIDADE da cor ativa, nunca uma cor diferente
            .opacity(ativo ? 1 : 0.38)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .animation(Tema.pressaoAnim(configuration.isPressed, reduzido: reduceMotion), value: configuration.isPressed)
    }
}

/// ADR 05b — "1 volta a conferir" sob a data, só quando há; um toque abre
/// as Notas, onde A VOLTA (04v) já espera.
private struct LinhaDaVolta: View {
    var aoTocar: () -> Void
    @Query private var notas: [Nota]

    private var quantas: Int {
        notas.filter { Volta.campoDevido(gesto: $0.gesto, campos: $0.campos, criadaEm: $0.criadaEm, fechado: $0.fechada) != nil }.count
    }

    var body: some View {
        let linha = Volta.emPalavras(quantas: quantas)
        if !linha.isEmpty {
            Button(action: aoTocar) {
                Text(linha)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.ambarTinta)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.discreto)
            .padding(.horizontal, Tema.margem)
            .padding(.bottom, 2)
            .transition(.opacity)
            .accessibilityHint("Abre as Notas, na seção A VOLTA")
            .accessibilityIdentifier("linha-da-volta")
        }
    }
}
