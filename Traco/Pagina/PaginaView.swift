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
    @State private var trabalhoAberto: Trabalho?
    @ScaledMetric(relativeTo: .body) private var corpoFolga: CGFloat = 9
    @State private var abrirArquivo = false
    @State private var lenteAberta = false
    @State private var chegou = false
    @State private var pulso = false

    var body: some View {
        // §20: a navegação é da RAIZ. Este Empilha era resíduo da arquitetura
        // antiga e renderizava a NotasView uma SEGUNDA vez, por baixo da camada
        // de arquivo que a raiz já mostra.
        pagina
            .opacity(chegou || reduceMotion ? 1 : 0)
            .sheet(isPresented: $mostrarCampos) {
                if let gesto = sessao.gesto, gesto != .expressiva {
                    VStack(alignment: .leading, spacing: 0) {
                        Button("Voltar à página") {
                            guard sessao.salvar(no: context) else { return }
                            mostrarCampos = false
                        }
                        .font(Tema.meta)
                        .padding(.horizontal, Tema.margem)
                        .padding(.top, 16)
                        .alvo()
                        .accessibilityIdentifier("voltar-campos")
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
                            .buttonStyle(PressaoDiscreta())
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
            // a chegada assenta em vez de piscar pronta
            withAnimation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { chegou = true }
            sessao.trancarExpressivasVencidas(no: context)
            sessao.varrerAnexosOrfaos(no: context)
            sessao.rearmarSeries(no: context)
            // ADR 04i: o retrato lê o disco quando a sábia precisa dele
            sessao.notasParaRetrato = {
                ((try? context.fetch(FetchDescriptor<Nota>())) ?? []).map {
                    Retrato.NotaLida(gesto: $0.gesto, fechada: $0.fechada, expressiva: $0.gesto == .expressiva,
                                     criadaEm: $0.criadaEm, campos: $0.campos)
                }
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
            if g == nil || g == .expressiva { mostrarCampos = false }
        }
        .onChange(of: mostrarCampos) { _, aberto in
            if !aberto { restaurarFoco() }
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

            if let toast = sessao.toast {
                // O aviso fala a língua das outras superfícies: cartão de raio
                // 12, largura cheia, texto na margem — a cápsula centrada era o
                // único oval do app e quebrava o eixo esquerdo (report do dono,
                // 01/set: "esses elementos estão diferentes do resto";
                // law-of-similarity com o cartão da análise).
                Text(toast)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Tema.superficieAlta, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: Tema.raio, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5))
                    .shadow(color: Tema.sombraContato, radius: 2, y: 1)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 88)
                    .transition(Tema.transicao(.opacity.combined(with: .offset(y: 6)), reduzido: reduceMotion))
                    .accessibilityIdentifier("toast-analise")
                    .accessibilityAddTraits(.isStaticText)
            }

        }
        .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.paginaVazia)
        .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.toast)
    }

    /// Auditoria de movimento: UMA superfície no rodapé.
    ///
    /// Régua, barra de ações e cartão eram três views independentes, cada uma
    /// com sua opacidade e sua lei — e se atravessavam no ar (g111: "SPEC" e
    /// "Analisar" legíveis na MESMA linha de base; g112: a régua legível DENTRO
    /// do cartão). Aqui só existe UM ocupante por vez, e a troca é uma transição
    /// de conteúdo dentro do mesmo container.
    @ViewBuilder
    private var rodapeUnico: some View {
        // sem `.transition(.opacity)`: cross-fade deixava as DUAS barras
        // legíveis nas mesmas linhas por um quadro inteiro. Elementos que
        // ocupam o mesmo espaço não se dissolvem um no outro — um sai, o outro
        // entra, e quem anima é a ALTURA do container.
        if let cartao = sessao.cartao {
            CartaoAnaliseView(cartao: cartao, sessao: sessao, aoAbrirCampos: { mostrarCampos = true })
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 12)
        } else if sessao.analisando, !sessao.paginaVazia {
            // o sinal de que ALGO está acontecendo — sem ele a tela fica muda
            HStack(spacing: 8) {
                Circle()
                    .fill(Tema.ambar)
                    .frame(width: 5, height: 5)
                    .opacity(pulso ? 1 : 0.25)
                    // laço: sob movimento reduzido para — o ponto fica aceso, e o "lendo…" já diz
                    .animation(Tema.movimento(.laco, .easeInOut(duration: Tema.Duracao.pulso).repeatForever(autoreverses: true), reduzido: reduceMotion), value: pulso)
                Text("lendo…")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .onAppear { pulso = true }
            .accessibilityIdentifier("analisando")
        } else if !sessao.paginaVazia || sessao.podeRecordar {
            bottomBar
        }
    }

    private var topbar: some View {
        HStack {
            Button("Notas") { sessao.irNotas(no: context) }
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
        .buttonStyle(PressaoDiscreta())
        .padding(.horizontal, Tema.margem)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.temVoz)
    }

    /// SPEC §4: os campos nascem abaixo do texto. Reabrir a nota não os esconde.
    private var camposAbaixo: AnyView? {
        guard sessao.temCamposDaForma, let gesto = sessao.gesto else { return nil }
        return AnyView(CamposFormaView(
            gesto: gesto,
            campos: $sessao.campos,
            conferenciaDevida: sessao.conferenciaDevida,
            aoEncadear: { sessao.encadear($0, no: context) }
        ))
    }

    private var editor: some View {
        CadernoView(
            rodape: AnyView(rodapeUnico),
            abaixo: camposAbaixo,
            esconderRegua: sessao.cartao != nil,
            texto: $sessao.texto,
            foco: $focoPagina,
            folga: corpoFolga,
            abrirArquivo: $abrirArquivo,
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
            let documento = DocumentoTrabalho(intencao: nota.vozDoAutor, notaOrigemID: id)
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

    private var acoesDaPagina: some View {
        Group {
            // O âmbar marca o que o AUTOR ainda precisa fazer. Com a análise
            // automática ligada — cujo próprio texto promete "você nunca precisa
            // lembrar do botão" — o app já faz isto sozinho: o botão fica de pé
            // como atalho, mas para de gritar (von-restorff).
            Button("Analisar") { sessao.analisar() }
                .foregroundStyle(
                    sessao.paginaVazia || sessao.gesto != nil || sessao.cartao != nil ? Tema.tintaFraca
                        : sessao.autoAnalise ? Tema.tintaSuave
                        : Tema.ambarTinta
                )
                .disabled(sessao.paginaVazia)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                    sessao.alternarAutoAnalise() // §17: opt-out sem tela de ajustes
                })
                .accessibilityLabel("Analisar")
                .accessibilityHint("Classifica o que você escreveu. Não escreve na nota.")
                // o toque longo tem par no rotor: quem usa VoiceOver liga e desliga por ação
                .accessibilityAction(named: Text(sessao.autoAnalise ? "Desligar análise automática" : "Ligar análise automática")) {
                    sessao.alternarAutoAnalise()
                }

            // A barra chega com corpo OU com alvo só nos campos. Recordar
            // não some porque a prosa viveu no Se / na frase, não no corpo.
            Button("Recordar") { sessao.irRecordar(no: context) }
                .foregroundStyle(Tema.tintaSuave)
                .disabled(!sessao.podeRecordar)
                .accessibilityLabel("Recordar")
                .accessibilityHint("Esconde a nota e cobra a memória")
            Button("Anexar") { abrirArquivo = true }
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityLabel("Anexar arquivo")
                .accessibilityHint("Anexar foto, vídeo, áudio, gravação ou arquivo")
                .accessibilityIdentifier("abrir-arquivo")
            // a lente da língua: regra local, aponta e não reescreve
            Button("Lente") {
                guard sessao.salvar(no: context) else { return }
                lenteAberta = true
            }
                .foregroundStyle(Tema.tintaSuave)
                .disabled(sessao.paginaVazia)
                .accessibilityLabel("Lente da língua")
                .accessibilityHint("Muletas, frases feitas, passivas e adjetivos repetidos. Só aponta.")
                .accessibilityIdentifier("abrir-lente")
        }
    }

    private var bottomBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            if sessao.temVoz, sessao.gesto != .expressiva {
                Button("Trabalhar nisto", action: trabalharNisto)
                    .foregroundStyle(Tema.ambarTinta)
                    .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                    .accessibilityHint("Cria um trabalho com esta intenção; sua nota é preservada")
                    .accessibilityIdentifier("trabalhar-nisto")
            }
            if tamanhoTexto.isAccessibilitySize {
                Menu("Mais ações da nota") { acoesDaPagina }
                    .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            } else {
                HStack(spacing: 8) { acoesDaPagina }
            }
        }
        .sheet(isPresented: $lenteAberta) {
            LenteView(texto: sessao.texto, notaUUID: sessao.gesto == .expressiva ? nil : sessao.notaUUID, gesto: sessao.gesto,
                      retrato: sessao.retratoAtual())
        }
        .font(Tema.barra)
        .buttonStyle(BarraBotaoStyle())
        .padding(.horizontal, Tema.margem)
        .padding(.vertical, 8)
        .background(Tema.fundo)
        .overlay(alignment: .top) {
            Rectangle().fill(Tema.linha).frame(height: 0.5)
        }
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
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
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
            .buttonStyle(PressaoDiscreta())
            .accessibilityLabel("Soltar a pergunta")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .accessibilityIdentifier("cartao-padroes")
    }

    private func anuncio(_ cartao: CartaoAnalisar?) -> String? {
        switch cartao {
        case .forma(let g, _): "Forma \(g.nome) sugerida. Abrir a forma disponível."
        case .aviso(let frase): frase
        case .sabiaPensando: "A sábia está pensando."
        case .resposta: "A sábia respondeu. A resposta está no cartão."
        case .vestido: "Vestido. Desfazer disponível."
        case .semConta: "A sábia " + Sabia.porOndeEmPalavras + "."
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
            .buttonStyle(PressaoDiscreta())
            .padding(.horizontal, Tema.margem)
            .padding(.bottom, 2)
            .transition(.opacity)
            .accessibilityHint("Abre as Notas, na seção A VOLTA")
            .accessibilityIdentifier("linha-da-volta")
        }
    }
}
