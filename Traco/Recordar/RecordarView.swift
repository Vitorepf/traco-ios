import SwiftUI

struct RecordarView: View {
    let texto: String
    let campos: [String: String]
    var aoRevelar: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var fase: Fase = .ler
    @State private var memoria = ""
    @FocusState private var foco: Bool

    private enum Fase {
        case ler, esconder, escrever, revelar
    }

    private var notaInteira: String {
        VozDoAutor.juntar(texto: texto, campos: campos)
    }

    private var memoriaVazia: Bool {
        memoria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.backward")
                            .font(.subheadline.weight(.semibold))
                        Text("voltar")
                    }
                }
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityLabel("Voltar")
                Spacer()
                Text("RECORDAR")
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                Spacer()
                Color.clear.frame(width: 64, height: Tema.alvo)
            }
            .padding(.horizontal, Tema.margem)

            switch fase {
            case .ler:
                Text("Leia uma última vez — a nota vai se esconder.")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 12)
                ScrollView {
                    Text(notaInteira)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tema.margem)
                }
            case .esconder:
                ScrollView {
                    Text(notaInteira)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .blur(radius: reduceMotion ? 0 : 14)
                        .scaleEffect(reduceMotion ? 1 : 0.985)
                        .opacity(0.25)
                        .padding(.horizontal, Tema.margem)
                        .accessibilityHidden(true)
                }
            case .escrever:
                Text("O que estava escrito?")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 8)
                TextEditor(text: $memoria)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .scrollContentBackground(.hidden)
                    .focused($foco)
                    .tint(Tema.ambar)
                    .padding(.horizontal, 14)
                    .accessibilityLabel("Memória")
                Button("Revelar") {
                    Toque.suave()
                    foco = false // o teclado desce COM a virada — a recompensa em tela cheia
                    aoRevelar() // a revisão cumpre-se aqui, não no toque da notificação
                    withAnimation(.easeOut(duration: 0.35)) { fase = .revelar }
                }
                .disabled(memoriaVazia)
                .buttonStyle(PrimarioStyle(recede: memoriaVazia))
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
                .accessibilityHint(memoriaVazia ? "Escreva de memória primeiro" : "Mostra memória e nota lado a lado")
            case .revelar:
                GeometryReader { geo in
                    let ladoALado = geo.size.width >= 360
                    let colunas = ladoALado
                        ? [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                        : [GridItem(.flexible())]
                    ScrollView {
                        LazyVGrid(columns: colunas, alignment: .leading, spacing: 22) {
                            // a folha vira: memória primeiro, a nota chega um respiro depois
                            bloco("DE MEMÓRIA", memoria)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                            bloco("A NOTA", notaInteira)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                                .animation(.easeOut(duration: 0.35).delay(0.08), value: fase)
                        }
                        .padding(Tema.margem)
                        .overlay {
                            if ladoALado {
                                // documento comparado: uma régua entre memória e nota
                                Rectangle()
                                    .fill(Tema.linha)
                                    .frame(width: 0.5)
                                    .padding(.vertical, Tema.margem)
                            }
                        }
                    }
                }
                Button("Voltar à página") { dismiss() }
                    .buttonStyle(PrimarioStyle())
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 24)
            }
        }
        .background(Tema.fundo.ignoresSafeArea())
        .task {
            let esperaLeitura: Duration = reduceMotion ? .milliseconds(200) : .milliseconds(1500)
            let esperaBlur: Duration = reduceMotion ? .milliseconds(250) : .milliseconds(900)
            try? await Task.sleep(for: esperaLeitura)
            withAnimation(.easeOut(duration: reduceMotion ? 0.18 : 0.4)) { fase = .esconder }
            try? await Task.sleep(for: esperaBlur)
            withAnimation(.easeOut(duration: 0.3)) { fase = .escrever }
            foco = true
        }
    }

    private func bloco(_ titulo: String, _ corpo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaSuave)
            Text(corpo)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PrimarioStyle: ButtonStyle {
    var recede: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
            .font(Tema.barra)
            .foregroundStyle(recede ? Tema.tintaFraca : Tema.ambar)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
