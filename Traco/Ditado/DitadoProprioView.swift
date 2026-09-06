import SwiftUI

/// ADR 2026-09-05x — a superfície do ditado próprio.
///
/// Cobre a página porque a gravação é a tarefa inteira: um toque fora do app
/// faz UMA coisa, e essa coisa é falar. O idioma visual é o da confirmação
/// (material, tinta, um título e no máximo duas ações) — nada novo em tokens.
///
/// Os três estados que o autor precisa distinguir têm títulos diferentes:
/// **Gravando** (nada guardado ainda), **Áudio guardado** (no disco, sem
/// letra) e **Guardado nas Notas** (com a letra, ainda por conferir).
struct DitadoProprioView: View {
    @Bindable var ditado: DitadoProprio
    let aoFechar: () -> Void
    let aoEscrever: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var materializado = false
    /// o ponto é o único sinal não textual: cresce com o texto
    @ScaledMetric(relativeTo: .body) private var ladoDoPonto: CGFloat = 12

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Tema.fundo.opacity(0.55).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    conteudo
                }
                .padding(28)
                .frame(maxWidth: 360, alignment: .leading)
            }
            .scaleEffect(materializado || reduceMotion ? 1 : 1.04)
            .blur(radius: materializado || reduceMotion ? 0 : 6)
            .opacity(materializado || reduceMotion ? 1 : 0)
        }
        // A TROCA DE ESTADO É SECA, de propósito. Em fade, "Gravando." e
        // "Áudio guardado." aparecem SOBREPOSTOS por um quarto de segundo e
        // nenhum dos dois se lê (capturado: f3b-02-transcrevendo-sobreposto).
        // É a mesma decisão da troca de aba na raiz: sem direção espacial, a
        // troca seca não tem vão. Quem marca a mudança é o háptico e o anúncio.
        .transaction { t in t.animation = nil }
        .onAppear {
            // a gravação não divide a tela: o teclado que a página tenha
            // deixado de pé sai, senão ele cobre a superfície pelo topo
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
            withAnimation(Tema.movimento(.escala, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                materializado = true
            }
        }
        .onChange(of: ditado.estado) { _, novo in anunciar(novo) }
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { escapar() }
    }

    @ViewBuilder
    private var conteudo: some View {
        switch ditado.estado {
        case .gravando:
            titulo("Gravando.")
            relogio
            texto("Fale. O áudio é guardado primeiro; a letra vem depois.")
            botao("Pronto", id: "ditado-pronto") { Task { await ditado.concluir() } }
            botaoMudo("Descartar", id: "ditado-descartar") {
                ditado.descartar()
                aoFechar()
            }
        case .transcrevendo:
            titulo("Áudio guardado.")
            texto("Transcrevendo no aparelho…")
            meta("A nota já existe, com o áudio dentro. Nada depende do que vem agora.")
            botaoMudo("Fechar", id: "ditado-fechar") { aoFechar() }
        case .transcrito(let letra):
            titulo("Guardado nas Notas.")
            Text(letra)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Tema.entreItens)
                .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
                .accessibilityIdentifier("ditado-transcricao")
            meta("Transcrito no aparelho. Confira quando puder — máquina não é o mesmo que conferido.")
            botao("Pronto", id: "ditado-pronto") { aoFechar() }
        case .semLetra(let motivo):
            titulo("O áudio ficou.")
            texto("Não consegui transcrever: \(motivo)")
            meta("A nota está nas Notas com o áudio dentro; é só tocar para ouvir.")
            botao("Tentar de novo", id: "ditado-tentar") { Task { await ditado.tentarDeNovo() } }
            botaoMudo("Pronto", id: "ditado-pronto") { aoFechar() }
        case .semMicrofone(let motivo):
            titulo("Sem microfone.")
            texto(primeiraMaiuscula(motivo))
            meta("Nada foi gravado — não há áudio guardado desta vez.")
            botao("Abrir os Ajustes", id: "ditado-ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            botaoMudo("Escrever em vez disso", id: "ditado-escrever") { aoEscrever() }
        }
    }

    /// O tempo é a prova de que está gravando; o ponto é a prova de que o
    /// microfone OUVE. Sob movimento reduzido o ponto fica quieto e cheio: o
    /// tempo, que já anda, continua sendo a evidência.
    private var relogio: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Tema.aviso)
                .frame(width: ladoDoPonto, height: ladoDoPonto)
                .opacity(reduceMotion ? 1 : 0.35 + 0.65 * ditado.nivel)
                .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.toque), reduzido: reduceMotion),
                           value: ditado.nivel)
            Text(Self.emMinutos(ditado.segundos))
                .font(Tema.mono)
                .monospacedDigit()
                .foregroundStyle(Tema.tinta)
        }
        .frame(minHeight: Tema.alvo, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Gravando há \(ditado.segundos) segundos")
        .accessibilityIdentifier("ditado-relogio")
    }

    static func emMinutos(_ s: Int) -> String { String(format: "%d:%02d", s / 60, s % 60) }

    private func primeiraMaiuscula(_ t: String) -> String {
        guard let p = t.first else { return t }
        return p.uppercased() + t.dropFirst()
    }

    private func escapar() {
        if case .gravando = ditado.estado { ditado.descartar() }
        aoFechar()
    }

    private func anunciar(_ estado: DitadoProprio.Estado) {
        let frase: String? = switch estado {
        case .gravando: "Gravando."
        case .transcrevendo: "Áudio guardado. Transcrevendo."
        case .transcrito: "Transcrito e guardado nas Notas."
        case .semLetra(let m): "Não consegui transcrever: \(m) O áudio ficou guardado."
        case .semMicrofone(let m): "Sem microfone. \(m)"
        }
        if let frase { AccessibilityNotification.Announcement(frase).post() }
    }

    private func titulo(_ t: String) -> some View {
        Text(t)
            .font(Tema.confirmacaoTitulo)
            .foregroundStyle(Tema.tinta)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("ditado-titulo")
    }

    private func texto(_ t: String) -> some View {
        Text(t).font(Tema.confirmacaoCorpo).foregroundStyle(Tema.tintaSuave)
    }

    private func meta(_ t: String) -> some View {
        Text(t).font(Tema.meta).foregroundStyle(Tema.tintaFraca)
    }

    private func botao(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.barra)
            .foregroundStyle(Tema.ambarTinta)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }

    private func botaoMudo(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.chrome)
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }
}

#Preview("gravando") {
    let d = DitadoProprio()
    return DitadoProprioView(ditado: d, aoFechar: {}, aoEscrever: {})
}
