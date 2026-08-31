import SwiftData
import SwiftUI
import UIKit

struct PaginaView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var sessao = Sessao()
    @FocusState private var focoPagina: Bool
    @ScaledMetric(relativeTo: .body) private var corpoFolga: CGFloat = 9
    @State private var abrirArquivo = false

    var body: some View {
        Empilha(aberto: $sessao.mostrarNotas, reduceMotion: reduceMotion) {
            pagina
        } frente: {
            NotasView(sessao: sessao)
        }
        .tint(Tema.ambar)
        .sheet(isPresented: $sessao.mostrarRecordar) {
            RecordarView(texto: sessao.recordarTexto, campos: sessao.recordarCampos) {
                sessao.cumprirRevisaoPendente(no: context)
            }
                .presentationBackground(Tema.fundo)
                .presentationDragIndicator(.hidden)
        }
        .overlay {
            if let confirmacao = sessao.confirmacao {
                ConfirmacaoView(estado: confirmacao, sessao: sessao, context: context)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.03)))
            }
        }
        .animation(sessao.confirmacao != nil
            ? .easeOut(duration: Tema.confirmacaoEntra)
            : .easeIn(duration: 0.15),
            value: sessao.confirmacao != nil)
        .onAppear {
            sessao.trancarExpressivasVencidas(no: context)
            sessao.varrerAnexosOrfaos(no: context)
            restaurarFoco()
            #if DEBUG
            print("TRACO_PAGINA_PRONTA")
            #endif
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
                if sessao.timerLigado { sessao.salvar(no: context) }
            default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            sessao.alinharTimerAoRelogio()
            sessao.trancarExpressivasVencidas(no: context)
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
                if let gesto = sessao.gesto, gesto != .expressiva {
                    ScrollView {
                        CamposFormaView(gesto: gesto, campos: $sessao.campos)
                            // com o cartão vivo, a forma respira acima dele —
                            // a assinatura do produto nunca acontece fora de cena
                            .padding(.bottom, sessao.cartao != nil ? 132 : 0)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .frame(maxHeight: 260)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if sessao.cartao == nil && !sessao.paginaVazia {
                    bottomBar
                        .transition(.opacity)
                }
            }

            if let toast = sessao.toast {
                Text(toast)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Tema.superficieAlta, in: Capsule())
                    .overlay(Capsule().strokeBorder(Tema.linha, lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .padding(.bottom, 88)
                    .accessibilityIdentifier("toast-analise")
                    .accessibilityAddTraits(.isStaticText)
                    .transition(.opacity)
            }

            if let cartao = sessao.cartao {
                CartaoAnaliseView(cartao: cartao, sessao: sessao)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                    .transition(reduceMotion
                        ? .opacity
                        : .asymmetric(
                            insertion: .scale(scale: 0.96, anchor: .bottom).combined(with: .opacity).combined(with: .offset(y: 14)),
                            removal: .opacity
                        ))
            }
        }
        .animation(Tema.cartao(reduzido: reduceMotion, aEntrar: sessao.cartao != nil), value: sessao.cartao != nil)
        .animation(.easeOut(duration: 0.2), value: sessao.paginaVazia)
        .animation(.easeOut(duration: 0.2), value: sessao.toast)
    }

    private var topbar: some View {
        HStack {
            Button("Notas") { sessao.irNotas(no: context) }
                .keyboardShortcut("l", modifiers: .command)
                .foregroundStyle(Tema.tintaSuave)
                .frame(minHeight: Tema.alvo)
                .accessibilityIdentifier("abrir-notas")
                .accessibilityLabel("Notas")
                .accessibilityHint("Abre as notas anteriores")

            Spacer()

            Button("Concluída") { sessao.concluir(no: context) }
                .keyboardShortcut(.return, modifiers: .command)
                .foregroundStyle(concluidaEAmbar ? Tema.ambar : Tema.tintaSuave)
                .opacity(sessao.paginaVazia ? 0 : 1)
                .allowsHitTesting(!sessao.paginaVazia)
                .frame(minHeight: Tema.alvo)
                .accessibilityHidden(sessao.paginaVazia)
                .accessibilityIdentifier("concluir")
                .accessibilityLabel("Concluída")
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
            texto: $sessao.texto,
            foco: $focoPagina,
            folga: corpoFolga,
            abrirArquivo: $abrirArquivo
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
        HStack(spacing: 0) {
            Button("Analisar") { sessao.analisar() }
                .foregroundStyle(sessao.paginaVazia || sessao.gesto != nil || sessao.cartao != nil ? Tema.tintaFraca : Tema.ambar)
                .disabled(sessao.paginaVazia)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                    sessao.alternarAutoAnalise() // §17: opt-out sem tela de ajustes
                })
                .accessibilityLabel("Analisar")
                .accessibilityHint("Classifica o que você escreveu. Não escreve na nota. Toque longo liga ou desliga a análise automática.")

            if !sessao.paginaVazia {
                Button("Recordar") { sessao.irRecordar(no: context) }
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityLabel("Recordar")
                    .accessibilityHint("Esconde a nota e cobra a memória")
                Button("Anexar") { abrirArquivo = true }
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityLabel("Anexar")
                    .accessibilityHint("Foto, vídeo, áudio, gravar ou arquivo")
                    .accessibilityIdentifier("abrir-arquivo")
            }
        }
        .font(Tema.barra)
        .buttonStyle(BarraBotaoStyle())
        .background(Tema.fundo)
        .overlay(alignment: .top) {
            Rectangle().fill(Tema.linha).frame(height: 0.5)
        }
    }

    private var timerBar: some View {
        VStack(spacing: 6) {
            // o tempo é o instrumento do método: corpo de verdade, legenda separada
            Text(tempoFormatado)
                .font(.title3.weight(.semibold).monospacedDigit())
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

    /// Página livre: o cursor volta. Notas, padrões ou confirmação cobrem — o teclado some.
    private func restaurarFoco() {
        guard !sessao.mostrarNotas, !sessao.mostrarPadroes, sessao.confirmacao == nil else { return }
        focoPagina = true
    }
}

private struct BarraBotaoStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(configuration.isPressed
                ? .easeOut(duration: 0.08)
                : .spring(response: 0.32, dampingFraction: 0.65),
                value: configuration.isPressed)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
