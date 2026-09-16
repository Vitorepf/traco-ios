import SwiftUI

/// O campo flutuante do pé — o mesmo nas Notas, na página e no calendário
/// (dono, 14/09): escrever ou falar, num lugar só, no alcance do polegar. À
/// esquerda, o que a tela oferece a mais (um "+", ou nada); à direita, um
/// botão que muda com o estado — enviar quando há texto, microfone quando
/// não há, parar enquanto grava. Uma correção aqui vale nas três telas.
struct CampoFlutuante<Mais: View>: View {
    @Binding var texto: String
    var dica: String
    /// A dica longa ocupa o campo quando cabe; quando o campo aperta (o Hoje à
    /// vista, iPhone estreito), vale a curta — nunca reticências no meio da
    /// palavra (dono, 16/09: "vazio entre Marcar e o microfone").
    var dicaCurta: String? = nil
    var ditado: Ditado
    var identificador: String
    var identificadorDoBotao: String? = nil
    var rotuloEnviar: String
    var rotuloDitar: String
    var aoEnviar: () -> Void
    /// Chamado ANTES de começar a ditar (a página fixa a base do texto).
    var aoComecarDitado: () -> Void = {}
    /// Quem monta o campo pode levar o cursor a ele (a folha do Trabalho).
    var foco: FocusState<Bool>.Binding? = nil
    /// Enquanto a outra ponta trabalha (a sábia pensa), o botão vira parar.
    var aoParar: (() -> Void)? = nil
    @ViewBuilder var mais: () -> Mais
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focoProprio: Bool
    @State private var larguraDoTexto: CGFloat = .infinity

    private var dicaQueCabe: String {
        guard let dicaCurta else { return dica }
        let largura = (dica as NSString).size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .body)]).width
        return largura <= larguraDoTexto ? dica : dicaCurta
    }

    var body: some View {
        let temTexto = !texto.trimmingCharacters(in: .whitespaces).isEmpty
        HStack(spacing: 6) {
            mais()
            HStack(spacing: 4) {
            TextField("", text: $texto, prompt: Text(dicaQueCabe).foregroundStyle(Tema.tintaFraca))
                // dono, 16/09: "tão fino que está feio" — o texto sobe ao corpo
                // (17) na MESMA altura de 40; peso vem do tipo, não do tamanho
                .font(.body)
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.send)
                .onSubmit(aoEnviar)
                .frame(minHeight: 32)
                .padding(.leading, Mais.self == EmptyView.self ? 14 : 4)
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { larguraDoTexto = $0 - (Mais.self == EmptyView.self ? 14 : 4) - 2 }
                .accessibilityIdentifier(identificador)
                .accessibilityLabel(dica)
                .accessibilityValue(texto.isEmpty ? "vazio" : texto)
                .focused(foco ?? $focoProprio)
            Button {
                if let aoParar {
                    aoParar()
                } else if temTexto {
                    ditado.parar()
                    aoEnviar()
                } else if ditado.gravando {
                    ditado.parar()
                } else {
                    aoComecarDitado()
                    ditado.alternar()
                }
            } label: {
                // ocioso, o microfone é só o glifo — a caixa cinza dentro da
                // cápsula branca lia como um botão barato; com texto, o enviar
                // é o círculo carvão com a sombra de controle do calendário
                // ocioso, o microfone é só o glifo, em tinta, sem disco: menos
                // camadas (dono, 14/09: "clean, ultra premium"); com texto, o
                // enviar é o único objeto escuro — um disco carvão pequeno
                Image(systemName: aoParar != nil ? "stop.fill" : temTexto ? "arrow.up" : (ditado.gravando ? "stop.fill" : "mic"))
                    // dono, 16/09: o microfone ocioso "fino" — sobe a 19 semibold, o peso
                    // dos glifos do trilho
                    .font(aoParar != nil || temTexto || ditado.gravando ? .footnote.weight(.bold) : .system(size: 19, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(aoParar != nil || temTexto || ditado.gravando ? .white : Tema.tinta)
                    .frame(width: 30, height: 30)
                    .background {
                        // o disco se LEVANTA do poço, como a escala escolhida
                        if aoParar != nil || temTexto || ditado.gravando {
                            RoundedRectangle(cornerRadius: Tema.raioDeCasa(30), style: .continuous)
                                // parar de esperar a sábia é carvão, como o enviar (dono, 16/09: o quadrado
                                // vermelho parecia erro); vermelho só na gravação do ditado
                                .fill(aoParar == nil && ditado.gravando && !temTexto ? Tema.aviso : Tema.chipAtivo)
                                .shadow(color: CalendarioTema.sombraControle, radius: 3, y: 1.5)
                        }
                    }
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.discreto)
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: temTexto)
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: ditado.gravando)
            .accessibilityLabel(aoParar != nil ? "Parar de esperar" : temTexto ? rotuloEnviar : ditado.gravando ? "Parar de ditar" : rotuloDitar)
            .accessibilityIdentifier(identificadorDoBotao ?? (identificador + (temTexto ? "-enviar" : "-ditar")))
            }
            .padding(.trailing, 1)
        }
        // dono, 15/09: o poço cinza com borda branca "está amador". O material
        // é o VIDRO do sistema (iOS 26+): reflexo, profundidade e sombra da
        // própria Apple, o mesmo da pílula e do botão âmbar — um material só no
        // pé, sem sombra desenhada à mão somando cinza no papel.
        .padding(4)
        // dono, 16/09: sólido sem sair do vidro — um véu de papel dá corpo ao
        // material fino, sem borda nem sombra desenhada
        .glassEffect(.regular.tint(.white.opacity(0.35)).interactive(),
                     in: RoundedRectangle(cornerRadius: Tema.raioDoCampo, style: .continuous))
    }
}

extension CampoFlutuante where Mais == EmptyView {
    init(texto: Binding<String>, dica: String, ditado: Ditado, identificador: String,
         identificadorDoBotao: String? = nil, rotuloEnviar: String, rotuloDitar: String,
         aoEnviar: @escaping () -> Void, aoComecarDitado: @escaping () -> Void = {},
         foco: FocusState<Bool>.Binding? = nil, aoParar: (() -> Void)? = nil) {
        self.init(texto: texto, dica: dica, ditado: ditado, identificador: identificador,
                  identificadorDoBotao: identificadorDoBotao, rotuloEnviar: rotuloEnviar,
                  rotuloDitar: rotuloDitar, aoEnviar: aoEnviar, aoComecarDitado: aoComecarDitado,
                  foco: foco, aoParar: aoParar) { EmptyView() }
    }
}

/// O "+" que abre o que a tela oferece a mais, no lugar de sempre.
struct BotaoMais<Conteudo: View>: View {
    var rotulo: String
    var identificador: String
    @ViewBuilder var conteudo: () -> Conteudo

    var body: some View {
        Menu { conteudo() } label: {
            Image(systemName: "plus")
                .font(.body.weight(.medium))
                .foregroundStyle(Tema.tinta)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.discreto)
        .accessibilityLabel(rotulo)
        .accessibilityIdentifier(identificador)
    }
}

/// A seleção que escorre como gota (dono, 16/09: "uma espécie de slime que vai
/// passando… vem uma partezinha depois, e o resto é puxado"). As duas bordas
/// seguem molas diferentes: a da frente sai primeiro e passa um fio do alvo, a
/// de trás vem puxada e alcança; esticada, a gota afina, como líquido que
/// conserva o volume. Vale para o trilho D S M A e para o Dock.
///
/// A mola é calculada aqui, quadro a quadro: com `withAnimation` o SwiftUI
/// anima a LARGURA e a POSIÇÃO derivadas com uma curva só (a última), e a gota
/// viajava redonda — medido no vídeo de 16/09. Movimento reduzido: salta.
struct Gota: View {
    var indice: Int
    /// distância entre o começo de uma casa e o da seguinte
    var passo: CGFloat
    /// lado da gota em repouso (largura e altura)
    var lado: CGFloat
    /// quantas casas há: a frente passa um fio do alvo, mas nunca da última
    /// casa — além dela a gota saía cortada reta pela borda (vídeo 16/09)
    var casas: Int
    /// nil: cápsula; com raio: o quadrado de cantos contínuos do Dock
    var raio: CGFloat? = nil
    var cor: Color = .black
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// de onde cada borda partiu e quando; nil = em repouso no índice
    @State private var partida: (frente: CGFloat, tras: CGFloat, em: Date)?
    @State private var ate: CGFloat = 0

    private static let frente = (resposta: 0.26, amortecimento: 0.66)
    private static let tras = (resposta: 0.5, amortecimento: 0.84)
    private static let duracao: TimeInterval = 0.9

    var body: some View {
        TimelineView(.animation(paused: partida == nil)) { contexto in
            let (x1, x2) = bordas(em: contexto.date)
            let largura = abs(x1 - x2) + lado
            // afina até 74 % quando estica: a ponte entre as casas lê como líquido
            let altura = max(lado * 0.74, lado - (largura - lado) * 0.16)
            forma
                .frame(width: largura, height: altura)
                .offset(x: min(x1, x2))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                // quem move a gota é a mola daqui: a animação de quem trocou a
                // escala (o morph do calendário) não pode arrastá-la redonda
                .transaction { $0.animation = nil }
        }
        .onChange(of: indice) { antigo, novo in
            let destino = CGFloat(novo) * passo
            guard !reduceMotion else { partida = nil; ate = destino; return }
            // retoma de onde CADA borda está agora, mesmo no meio de outra viagem;
            // em repouso, parte do índice ANTIGO (aqui `indice` já é o novo)
            let (x1, x2) = partida == nil ? (CGFloat(antigo) * passo, CGFloat(antigo) * passo) : bordas(em: .now)
            partida = (x1, x2, .now)
            ate = destino
            let marca = partida?.em
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(Self.duracao))
                if partida?.em == marca { partida = nil }
            }
        }
    }

    private func bordas(em data: Date) -> (CGFloat, CGFloat) {
        // em repouso a gota mora no índice: nasce no lugar, sem voar da borda
        guard let partida else { let x = CGFloat(indice) * passo; return (x, x) }
        let t = data.timeIntervalSince(partida.em)
        let f = Self.mola(t, Self.frente.resposta, Self.frente.amortecimento)
        let r = Self.mola(t, Self.tras.resposta, Self.tras.amortecimento)
        let limite = CGFloat(max(0, casas - 1)) * passo
        func preso(_ x: CGFloat) -> CGFloat { min(max(x, 0), limite) }
        return (preso(partida.frente + (ate - partida.frente) * f), preso(partida.tras + (ate - partida.tras) * r))
    }

    /// Progresso 0 → 1 de uma mola sub-amortecida partindo do repouso.
    static func mola(_ t: TimeInterval, _ resposta: Double, _ amortecimento: Double) -> CGFloat {
        guard t > 0 else { return 0 }
        let w0 = 2 * Double.pi / resposta
        let z = amortecimento
        let wd = w0 * (1 - z * z).squareRoot()
        let e = exp(-z * w0 * t)
        return CGFloat(1 - e * (cos(wd * t) + (z * w0 / wd) * sin(wd * t)))
    }

    @ViewBuilder private var forma: some View {
        if let raio {
            RoundedRectangle(cornerRadius: raio, style: .continuous).fill(cor)
        } else {
            Capsule().fill(cor)
        }
    }
}
