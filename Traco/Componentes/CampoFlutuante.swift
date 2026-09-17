import SwiftUI

/// O campo flutuante do pé — o mesmo nas Notas, na página e no calendário
/// (dono, 14/09): escrever ou falar, num lugar só, no alcance do polegar. À
/// esquerda, o que a tela oferece a mais (um "+", ou nada); à direita, um
/// botão que muda com o estado — enviar quando há texto, microfone quando
/// não há, parar enquanto grava. Uma correção aqui vale nas três telas.
struct CampoFlutuante<Mais: View>: View {
    @Binding var texto: String
    var dica: String
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

    var body: some View {
        let temTexto = !texto.trimmingCharacters(in: .whitespaces).isEmpty
        HStack(spacing: 6) {
            mais()
            HStack(spacing: 4) {
            TextField("", text: $texto, prompt: Text(dica).foregroundStyle(Tema.tintaFraca))
                .font(Tema.meta)
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.send)
                .onSubmit(aoEnviar)
                .frame(minHeight: 32)
                .padding(.leading, Mais.self == EmptyView.self ? 14 : 4)
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
                    .font(aoParar != nil || temTexto || ditado.gravando ? .caption2.weight(.bold) : .footnote.weight(.medium))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(aoParar != nil || temTexto || ditado.gravando ? Tema.sobreAtivo : Tema.tintaSuave)
                    .frame(width: 26, height: 26)
                    .background {
                        // o disco se LEVANTA do poço, como a escala escolhida
                        if aoParar != nil || temTexto || ditado.gravando {
                            Circle()
                                .fill(aoParar != nil || (ditado.gravando && !temTexto) ? Tema.aviso : Tema.chipAtivo)
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
            .padding(.trailing, 2)
        }
        // dono, 15/09: o poço cinza com borda branca "está amador". O material
        // é o VIDRO do sistema (iOS 26+): reflexo, profundidade e sombra da
        // própria Apple, o mesmo da pílula e do botão âmbar — um material só no
        // pé, sem sombra desenhada à mão somando cinza no papel.
        .padding(4)
        .glassEffect(.regular.interactive(), in: .capsule)
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
