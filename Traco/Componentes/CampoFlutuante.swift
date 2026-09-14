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
    @ViewBuilder var mais: () -> Mais
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focoProprio: Bool

    var body: some View {
        let temTexto = !texto.trimmingCharacters(in: .whitespaces).isEmpty
        HStack(spacing: 8) {
            mais()
            TextField("", text: $texto, prompt: Text(dica).foregroundStyle(Tema.tintaSuave))
                .font(Tema.chrome)
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.send)
                .onSubmit(aoEnviar)
                .frame(minHeight: Tema.alvo)
                .padding(.leading, Mais.self == EmptyView.self ? 16 : 0)
                .accessibilityIdentifier(identificador)
                .accessibilityLabel(dica)
                .accessibilityValue(texto.isEmpty ? "vazio" : texto)
                .focused(foco ?? $focoProprio)
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
                // ocioso, o microfone é só o glifo — a caixa cinza dentro da
                // cápsula branca lia como um botão barato; com texto, o enviar
                // é o círculo carvão com a sombra de controle do calendário
                Image(systemName: temTexto ? "arrow.up" : (ditado.gravando ? "stop.fill" : "mic"))
                    .font(.subheadline.weight(.bold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(temTexto || ditado.gravando ? .white : Tema.tinta)
                    .frame(width: 34, height: 34)
                    .background {
                        if temTexto || ditado.gravando {
                            Circle()
                                .fill(ditado.gravando && !temTexto ? Tema.aviso : Tema.chipAtivo)
                                .shadow(color: CalendarioTema.sombraControle, radius: 4, y: 2)
                        } else {
                            // ocioso, um disco quase invisível: o microfone tem
                            // corpo, como o "+" e o enviar, sem virar botão cinza
                            Circle().fill(Tema.linha)
                        }
                    }
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.discreto)
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: temTexto)
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: ditado.gravando)
            .accessibilityLabel(temTexto ? rotuloEnviar : ditado.gravando ? "Parar de ditar" : rotuloDitar)
            .accessibilityIdentifier(identificadorDoBotao ?? (identificador + (temTexto ? "-enviar" : "-ditar")))
        }
        .padding((Tema.barraNav - Tema.alvo) / 2)
        // a MESMA cápsula da pílula de navegação (BarraNavegacao): material,
        // fio, sombra e altura iguais — os dois objetos do pé são da mesma
        // família, não dois vidros diferentes empilhados (dono, 14/09: "olha o
        // tamanho, experiência, empacotamento")
        .background {
            Capsule()
                .fill(Tema.superficieAlta.opacity(0.85))
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Tema.linha, lineWidth: 0.5))
                .sombra(Tema.Sombra.flutuante)
        }
    }
}

extension CampoFlutuante where Mais == EmptyView {
    init(texto: Binding<String>, dica: String, ditado: Ditado, identificador: String,
         identificadorDoBotao: String? = nil, rotuloEnviar: String, rotuloDitar: String,
         aoEnviar: @escaping () -> Void, aoComecarDitado: @escaping () -> Void = {},
         foco: FocusState<Bool>.Binding? = nil) {
        self.init(texto: texto, dica: dica, ditado: ditado, identificador: identificador,
                  identificadorDoBotao: identificadorDoBotao, rotuloEnviar: rotuloEnviar,
                  rotuloDitar: rotuloDitar, aoEnviar: aoEnviar, aoComecarDitado: aoComecarDitado,
                  foco: foco) { EmptyView() }
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
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Tema.tinta)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Tema.linha))
                .frame(width: Tema.alvo, height: Tema.alvo)
                .contentShape(Rectangle())
        }
        .buttonStyle(.discreto)
        .accessibilityLabel(rotulo)
        .accessibilityIdentifier(identificador)
    }
}
