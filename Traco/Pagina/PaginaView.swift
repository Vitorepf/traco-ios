import SwiftData
import SwiftUI
import UIKit

struct PaginaView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var sessao: Sessao
    @FocusState private var focoPagina: Bool
    @State private var mostrarCampos = false
    @ScaledMetric(relativeTo: .body) private var corpoFolga: CGFloat = 9
    @State private var abrirArquivo = false
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
                            CamposFormaView(gesto: gesto, campos: $sessao.campos)
                                .padding(.bottom, 24)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Tema.superficie)
                }
            }
        .tint(Tema.ambar)
        .sheet(isPresented: $sessao.mostrarRecordar) {
            RecordarView(texto: sessao.recordarTexto, campos: sessao.recordarCampos) {
                sessao.cumprirRevisaoPendente(no: context)
            }
                .presentationBackground(Tema.superficie)
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            // a chegada assenta em vez de piscar pronta
            withAnimation(.easeOut(duration: 0.25)) { chegou = true }
            sessao.trancarExpressivasVencidas(no: context)
            sessao.varrerAnexosOrfaos(no: context)
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
        // a forma vestiu sozinha, mas a folha NÃO sobe sozinha: modal no meio da
        // escrita rouba a página. A alça "abrir campos" é a porta, a um toque.
        .onChange(of: sessao.gesto) { _, g in
            if g == nil || g == .expressiva { mostrarCampos = false }
        }
        .onChange(of: mostrarCampos) { _, aberto in
            if !aberto { restaurarFoco() }
        }
        .onChange(of: sessao.timerEsgotou) { _, esgotou in
            if esgotou { sessao.esgotarTimer(no: context) }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                sessao.alinharTimerAoRelogio()
                sessao.trancarExpressivasVencidas(no: context)
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
            if let destino = Rota.pendente { Rota.pendente = nil; seguirRota(destino) }
        }
        .onReceive(NotificationCenter.default.publisher(for: Revisoes.abrirRevisao)) { aviso in
            // §17: um passo — a notificação abre direto o Recordar da nota
            guard let uuid = aviso.object as? UUID,
                  let nota = Sessao.buscar(uuid: uuid, no: context) else { return }
            // o degrau só sobe quando o autor REVELA — abrir e fechar não é revisão
            sessao.revisaoPendente = uuid
            sessao.recordarDaNotas(nota)
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
                    .background(Tema.superficieAlta, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 88)
                    .transition(.opacity.combined(with: .offset(y: 6)))
                    .accessibilityIdentifier("toast-analise")
                    .accessibilityAddTraits(.isStaticText)
                    .transition(.opacity)
            }

        }
        .animation(.easeOut(duration: 0.2), value: sessao.paginaVazia)
        .animation(.easeOut(duration: 0.2), value: sessao.toast)
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
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulso)
                Text("lendo…")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .onAppear { pulso = true }
            .accessibilityIdentifier("analisando")
        } else if !sessao.paginaVazia {
            bottomBar
        }
    }

    private var topbar: some View {
        HStack {
            // §20: o destino "Notas" mora na barra inferior; o atalho ⌘L continua
            Button("") { sessao.irNotas(no: context) }
                .keyboardShortcut("l", modifiers: .command)
                .frame(width: 0, height: 0)
                .opacity(0)
                .accessibilityHidden(true)

            Spacer()

            Button("Concluir") { sessao.concluir(no: context) }
                .keyboardShortcut(.return, modifiers: .command)
                .foregroundStyle(concluidaEAmbar ? Tema.ambar : Tema.tintaSuave)
                .opacity(sessao.paginaVazia ? 0 : 1)
                .allowsHitTesting(!sessao.paginaVazia)
                .frame(minHeight: Tema.alvo)
                .accessibilityHidden(sessao.paginaVazia)
                .accessibilityIdentifier("concluir")
                .accessibilityLabel("Concluir")
                .accessibilityHint("Guarda e abre uma página nova")
        }
        .font(Tema.chrome)
        .buttonStyle(PressaoDiscreta())
        .padding(.horizontal, Tema.margem)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .animation(.easeOut(duration: 0.2), value: sessao.paginaVazia)
    }

    private var editor: some View {
        CadernoView(
            rodape: AnyView(rodapeUnico),
            esconderRegua: sessao.cartao != nil,
            texto: $sessao.texto,
            foco: $focoPagina,
            folga: corpoFolga,
            abrirArquivo: $abrirArquivo,
            aoTocarRegua: { sessao.tocarRegua($0) }
        ) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { sessao.cartao = nil }
            sessao.agendarAutoAnalise() // §17: a pausa chama a análise sozinha
        }
        .frame(maxWidth: 680)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            // O âmbar marca o que o AUTOR ainda precisa fazer. Com a análise
            // automática ligada — cujo próprio texto promete "você nunca precisa
            // lembrar do botão" — o app já faz isto sozinho: o botão fica de pé
            // como atalho, mas para de gritar (von-restorff).
            Button("Analisar") { sessao.analisar() }
                .foregroundStyle(
                    sessao.paginaVazia || sessao.gesto != nil || sessao.cartao != nil ? Tema.tintaFraca
                        : sessao.autoAnalise ? Tema.tintaSuave
                        : Tema.ambar
                )
                .disabled(sessao.paginaVazia)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                    sessao.alternarAutoAnalise() // §17: opt-out sem tela de ajustes
                })
                .accessibilityLabel("Analisar")
                .accessibilityHint("Classifica o que você escreveu. Não escreve na nota. Toque longo liga ou desliga a análise automática.")

            // "Vestir" é irmão de "Analisar": age sobre o MESMO texto, mas veste
            // a forma em vez de classificar. A IA não escreve — só estrutura.
            Button("Vestir") { sessao.vestirNota() }
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityLabel("Vestir a nota")
                .accessibilityHint("Estrutura o que você escreveu em título, listas e destaques. Não escreve na nota.")
                .accessibilityIdentifier("vestir-nota")

            // sem `if !paginaVazia` aqui: o rodapeUnico só chega nesta barra com
            // a página cheia. A condição repetida era morta e fazia parecer que
            // existe um estado em que "Analisar" aparece sozinho — não existe.
            Button("Recordar") { sessao.irRecordar(no: context) }
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityLabel("Recordar")
                .accessibilityHint("Esconde a nota e cobra a memória")
            Button("Anexar") { abrirArquivo = true }
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityLabel("Anexar arquivo")
                .accessibilityHint("Anexar foto, vídeo, áudio, gravação ou arquivo")
                .accessibilityIdentifier("abrir-arquivo")
        }
        .font(Tema.barra)
        .buttonStyle(BarraBotaoStyle())
        .padding(.horizontal, Tema.margem)
        .padding(.vertical, 8)
        .background(Tema.fundo)
        .overlay(alignment: .top) {
            Rectangle().fill(Tema.luzBorda).frame(height: 0.5)
        }
    }

    private var timerBar: some View {
        VStack(spacing: 6) {
            // o tempo é o instrumento do método: corpo de verdade, legenda separada
            Text(tempoFormatado)
                .font(.system(.title3, design: .rounded).weight(.semibold).monospacedDigit())
                .foregroundStyle(Tema.tinta)
                .contentTransition(.numericText(countsDown: true))
                .animation(.linear(duration: 0.3), value: sessao.segundosRestantes)
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
                            .animation(.linear(duration: 1), value: progresso)
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

    /// Um âmbar por vista: com forma aberta, Concluída; senão o analise/cartão leva o acento.
    private var concluidaEAmbar: Bool {
        sessao.gesto != nil && sessao.gesto != .expressiva && sessao.cartao == nil
    }

    private var timerTexto: String {
        let m = sessao.segundosRestantes / 60
        let s = sessao.segundosRestantes % 60
        return String(format: "%02d:%02d · fato e sentimento — ao fim, tranca", m, s)
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
            .frame(minHeight: Tema.alvo)
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

    private func seguirRota(_ destino: Rota.Destino) {
        switch destino {
        case .novaPagina:
            sessao.novaNota(no: context)
        case .notas:
            sessao.irNotas(no: context)
        case .recordar:
            sessao.recordarMaisRecente(no: context)
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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                Tema.superficieAlta.opacity(configuration.isPressed ? 1 : 0.85),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Tema.luzBorda, lineWidth: 0.5)
            }
            // desabilitado é OPACIDADE da cor ativa, nunca uma cor diferente
            .opacity(ativo ? 1 : 0.38)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
    }
}
