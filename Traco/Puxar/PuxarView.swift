import SwiftUI

struct PuxarView: View {
    let texto: String
    let campos: [String: String]
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
                Button("‹ voltar") { dismiss() }
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityLabel("Voltar")
                Spacer()
                Text("PUXAR")
                    .font(Tema.label)
                    .tracking(1.4)
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
                    Toque.leve()
                    fase = .revelar
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
                            bloco("DE MEMÓRIA", memoria)
                            bloco("A NOTA", notaInteira)
                        }
                        .padding(Tema.margem)
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
            fase = .escrever
            foco = true
        }
    }

    private func bloco(_ titulo: String, _ corpo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(Tema.label)
                .tracking(1.2)
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
            .font(Tema.barra)
            .foregroundStyle(recede ? Tema.tintaFraca : Tema.ambar)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
