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
    @ViewBuilder var mais: () -> Mais
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let temTexto = !texto.trimmingCharacters(in: .whitespaces).isEmpty
        HStack(spacing: 8) {
            mais()
            TextField("", text: $texto, prompt: Text(dica).foregroundStyle(Tema.tintaFraca))
                .font(.callout)
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.send)
                .onSubmit(aoEnviar)
                .frame(minHeight: Tema.alvo)
                .padding(.leading, Mais.self == EmptyView.self ? 14 : 0)
                .accessibilityIdentifier(identificador)
                .accessibilityLabel(dica)
                .accessibilityValue(texto.isEmpty ? "vazio" : texto)
            Button {
                if temTexto {
                    ditado.parar()
                    aoEnviar()
                } else if ditado.gravando {
                    ditado.parar()
                } else {
                    aoComecarDitado()
                    ditado.alternar()
                }
            } label: {
                Image(systemName: temTexto ? "arrow.up" : (ditado.gravando ? "stop.fill" : "mic"))
                    .font(.subheadline.weight(.bold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(temTexto || ditado.gravando ? .white : Tema.tinta)
                    .frame(width: 36, height: 36)
                    .background(temTexto || ditado.gravando ? Tema.chipAtivo : Tema.chip,
                                in: RoundedRectangle(cornerRadius: Tema.Raio.controle, style: .continuous))
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.discreto)
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: temTexto)
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: ditado.gravando)
            .accessibilityLabel(temTexto ? rotuloEnviar : ditado.gravando ? "Parar de ditar" : rotuloDitar)
            .accessibilityIdentifier(identificadorDoBotao ?? (identificador + (temTexto ? "-enviar" : "-ditar")))
        }
        .padding(.leading, 2)
        .padding(.trailing, 4)
        .padding(.vertical, 2)
        .background(Capsule().fill(Tema.superficie))
        .overlay(Capsule().strokeBorder(Tema.luzBorda, lineWidth: 1))
        .sombra(Tema.Sombra.campo)
    }
}

extension CampoFlutuante where Mais == EmptyView {
    init(texto: Binding<String>, dica: String, ditado: Ditado, identificador: String,
         identificadorDoBotao: String? = nil, rotuloEnviar: String, rotuloDitar: String,
         aoEnviar: @escaping () -> Void, aoComecarDitado: @escaping () -> Void = {}) {
        self.init(texto: texto, dica: dica, ditado: ditado, identificador: identificador,
                  identificadorDoBotao: identificadorDoBotao, rotuloEnviar: rotuloEnviar,
                  rotuloDitar: rotuloDitar, aoEnviar: aoEnviar, aoComecarDitado: aoComecarDitado) { EmptyView() }
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
                .font(.callout.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .frame(width: Tema.alvo, height: Tema.alvo)
                .contentShape(Rectangle())
        }
        .buttonStyle(.discreto)
        .accessibilityLabel(rotulo)
        .accessibilityIdentifier(identificador)
    }
}
