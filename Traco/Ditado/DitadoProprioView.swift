import SwiftUI

/// ADR 2026-09-06c — a superfície do ditado próprio.
///
/// Cobre a página porque a gravação é a tarefa inteira: um toque fora do app
/// faz UMA coisa, e essa coisa é falar. O idioma visual é o da confirmação —
/// e agora é literalmente o MESMO: `FolhaDeConfirmacao` (G3, M6).
///
/// Os quatro estados que o autor precisa distinguir têm títulos diferentes, e
/// cada um diz a verdade sobre onde o áudio está: **Gravando.** (nada
/// guardado), **Áudio guardado.** (no disco, sem letra), **Guardado nas
/// Notas.** (com a letra) e **O áudio ficou no aparelho.** (gravado, mas a
/// nota não entrou).
struct DitadoProprioView: View {
    @Bindable var ditado: DitadoProprio
    let aoFechar: () -> Void
    let aoEscrever: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// o ponto é o único sinal não textual: cresce com o texto
    @ScaledMetric(relativeTo: .body) private var ladoDoPonto: CGFloat = 12

    var body: some View {
        FolhaDeConfirmacao(aoEscapar: escapar) { conteudo }
            // A TROCA DE ESTADO É SECA, de propósito. Em fade, "Gravando." e
            // "Áudio guardado." aparecem SOBREPOSTOS por um quarto de segundo
            // e nenhum dos dois se lê (capturado: f3b-02-transcrevendo-sobreposto).
            // É a mesma decisão da troca de aba na raiz: sem direção espacial,
            // a troca seca não tem vão. Quem marca a mudança é o háptico
            // (`Toque` em cada troca de resultado) e o anúncio.
            .transaction { t in t.animation = nil }
            .onChange(of: ditado.estado) { _, novo in anunciar(novo) }
    }

    @ViewBuilder
    private var conteudo: some View {
        switch ditado.estado {
        case .gravando:
            Folha.titulo("Gravando.", id: "ditado-titulo")
            relogio
            Folha.texto("Fale. O áudio é guardado primeiro; a letra vem depois.")
            Folha.botao("Pronto", id: "ditado-pronto") { Task { await ditado.concluir() } }
            Folha.botaoMudo("Descartar", id: "ditado-descartar") {
                ditado.descartar()
                aoFechar()
            }
        case .transcrevendo:
            Folha.titulo("Áudio guardado.", id: "ditado-titulo")
            Folha.texto("Transcrevendo no aparelho…")
            Folha.meta("A nota já existe, com o áudio dentro. Nada depende do que vem agora.")
            Folha.botaoMudo("Fechar", id: "ditado-fechar") { aoFechar() }
        case .transcrito(let letra):
            Folha.titulo("Guardado nas Notas.", id: "ditado-titulo")
            Text(letra)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Tema.entreItens)
                .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
                .accessibilityIdentifier("ditado-transcricao")
            Folha.meta("Transcrito no aparelho. Confira quando puder — máquina não é o mesmo que conferido.")
            Folha.botao("Pronto", id: "ditado-pronto") { aoFechar() }
            // M3 do G3: pedir a conferência sem dar o caminho era mandar o
            // autor caçar a nota na lista. A conferência começa aqui.
            if ditado.abrirANota != nil {
                Folha.botaoMudo("Abrir a nota", id: "ditado-abrir-nota") {
                    ditado.abrirANota?()
                    aoFechar()
                }
            }
        case .semLetra(let motivo):
            Folha.titulo("O áudio ficou.", id: "ditado-titulo")
            Folha.texto("Não consegui transcrever: \(motivo)")
            Folha.meta("A nota está nas Notas com o áudio dentro; é só tocar para ouvir.")
            Folha.botao("Tentar de novo", id: "ditado-tentar") { Task { await ditado.tentarDeNovo() } }
            Folha.botaoMudo("Pronto", id: "ditado-pronto") { aoFechar() }
        case .semDeposito(let motivo):
            // A1 do G3: aqui a tela dizia "Sem microfone." e "Nada foi gravado"
            // com o microfone funcionando e o m4a no disco. Agora diz os três
            // fatos: o que existe, o que falhou, e o que o autor pode fazer.
            Folha.titulo("O áudio ficou no aparelho.", id: "ditado-titulo")
            Folha.texto("Gravei, mas a nota não entrou: \(motivo)")
            Folha.meta("Sem uma nota que o cite, o áudio é apagado em um dia.")
            Folha.botao("Tentar de novo", id: "ditado-tentar") { Task { await ditado.depositarDeNovo() } }
            Folha.botaoMudo("Descartar a gravação", id: "ditado-descartar") {
                ditado.descartar()
                aoFechar()
            }
        case .semMicrofone(let motivo):
            Folha.titulo("Sem microfone.", id: "ditado-titulo")
            Folha.texto(primeiraMaiuscula(motivo))
            Folha.meta("Nada foi gravado — não há áudio guardado desta vez.")
            Folha.botao("Abrir os Ajustes", id: "ditado-ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            Folha.botaoMudo("Escrever em vez disso", id: "ditado-escrever") { aoEscrever() }
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
        let frase = switch estado {
        case .gravando: "Gravando."
        case .transcrevendo: "Áudio guardado. Transcrevendo."
        case .transcrito: "Transcrito e guardado nas Notas."
        case .semLetra(let m): "Não consegui transcrever: \(m) O áudio ficou guardado."
        case .semDeposito(let m): "O áudio ficou no aparelho. A nota não entrou: \(m)"
        case .semMicrofone(let m): "Sem microfone. \(m)"
        }
        AccessibilityNotification.Announcement(frase).post()
    }
}

#Preview("gravando") {
    DitadoProprioView(ditado: DitadoProprio(), aoFechar: {}, aoEscrever: {})
}
