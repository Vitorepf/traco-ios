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
            RecordarView(texto: sessao.recordarTexto, campos: sessao.recordarCampos)
                .presentationBackground(Tema.fundo)
                .presentationDragIndicator(.hidden)
        }
        .overlay {
            if let confirmacao = sessao.confirmacao {
                ConfirmacaoView(estado: confirmacao, sessao: sessao, context: context)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.03)))
            }
        }
        .animation(Tema.gaveta(reduzido: reduceMotion), value: sessao.confirmacao != nil)
        .onAppear {
            sessao.trancarExpressivasVencidas(no: context)
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
    }

    private var pagina: some View {
        ZStack(alignment: .bottom) {
            Tema.fundo.ignoresSafeArea()

            VStack(spacing: 0) {
                topbar
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
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .frame(maxHeight: 260)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if sessao.cartao == nil {
                    bottomBar
                }
            }

            if let toast = sessao.toast {
                Text(toast)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.bottom, 88)
                    .accessibilityIdentifier("toast-analise")
                    .accessibilityAddTraits(.isStaticText)
                    .transition(.opacity)
            }

            if let cartao = sessao.cartao {
                CartaoAnaliseView(cartao: cartao, sessao: sessao)
                    .padding(.horizontal, 10)
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
        .animation(.easeOut(duration: 0.2), value: sessao.toast)
    }

    private var topbar: some View {
        HStack {
            Button("Notas") { sessao.irNotas(no: context) }
                .foregroundStyle(Tema.tintaSuave)
                .frame(minHeight: Tema.alvo)
                .accessibilityIdentifier("abrir-notas")
                .accessibilityLabel("Notas")
                .accessibilityHint("Abre as notas anteriores")

            Spacer()

            Button("Concluída") { sessao.concluir(no: context) }
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            Button("Analisar") { sessao.analisar() }
                .foregroundStyle(sessao.paginaVazia || sessao.gesto != nil || sessao.cartao != nil ? Tema.tintaFraca : Tema.ambar)
                .disabled(sessao.paginaVazia)
                .accessibilityLabel("Analisar")
                .accessibilityHint("Classifica o que você escreveu. Não escreve na nota.")

            if !sessao.paginaVazia {
                Button("Recordar") { sessao.irRecordar(no: context) }
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityLabel("Recordar")
                    .accessibilityHint("Esconde a nota e cobra a memória")
                Button("Arquivo") { abrirArquivo = true }
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityLabel("Arquivo")
                    .accessibilityHint("Foto, vídeo, áudio, gravar ou ficheiro")
                    .accessibilityIdentifier("abrir-arquivo")
            }
        }
        .font(Tema.barra)
        .buttonStyle(BarraBotaoStyle())
        .background(Tema.fundo.opacity(0.72))
        .overlay(alignment: .top) {
            Rectangle().fill(Tema.linha).frame(height: 0.5)
        }
    }

    private var timerBar: some View {
        VStack(spacing: 8) {
            Text(timerTexto)
                .font(Tema.label.monospacedDigit())
                .foregroundStyle(Tema.tintaSuave)
                .frame(minHeight: 28)
                .accessibilityLabel("Tempo da escrita expressiva")
                .accessibilityValue(timerTexto)
                .accessibilityIdentifier("timer-expressiva")
            GeometryReader { geo in
                Capsule()
                    .fill(Tema.linha)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Tema.ambarSuave)
                            .frame(width: geo.size.width * progresso)
                    }
            }
            .frame(height: 2)
            .padding(.horizontal, Tema.margem)
            .accessibilityHidden(true)
        }
        .padding(.bottom, 8)
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
            Text("PERGUNTA DO CÓDICE")
                .font(Tema.label)
                .tracking(1.2)
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
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
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
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
