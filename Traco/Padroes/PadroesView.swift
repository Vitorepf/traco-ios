import SwiftData
import SwiftUI

struct PadroesView: View {
    @Bindable var sessao: Sessao
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]
    @State private var visiveis = 0
    @State private var perguntas: [String] = []
    @State private var carregou = false

    private var abertas: [Nota] {
        Array(notas.filter { !$0.trancada && !$0.vozDoAutor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.prefix(12))
    }

    /// Grok quando há chave (perguntas NOVAS a cada visita); local de guarda.
    /// Nunca a mesma pergunta duas visitas seguidas.
    private func carregarPerguntas() async {
        let vozes = abertas.map(\.vozDoAutor)
        let locais = PadroesLocal.perguntas(
            vozes: vozes,
            obstaculos: abertas.compactMap { $0.campos["obstaculo"] }
        )
        let remotas = await PadroesRemoto.perguntas(vozes: vozes)
        let escolhidas = PadroesRemoto.ineditas(remotas ?? locais)
        PadroesRemoto.registrarVistas(escolhidas)
        perguntas = escolhidas
        carregou = true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // §20: voltar é da barra inferior. Aqui fica o nome da tela, e só.
            Text("Padrões")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, Tema.margem)
                .padding(.top, 4)
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if !carregou {
                        Text("lendo as suas notas…")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaFraca)
                            .padding(.top, 8)
                    } else if perguntas.isEmpty {
                        Text("ainda não há o que ler. escreva primeiro.")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                    } else {
                        Text("Li as últimas \(abertas.count) notas. Perguntas — toque numa para respondê-la. Quem conclui é você.")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .padding(.bottom, 8)

                        ForEach(Array(perguntas.enumerated()), id: \.offset) { indice, pergunta in
                            Button {
                                sessao.novaPagina()
                                sessao.perguntaPadroes = pergunta
                                sessao.mostrarPadroes = false
                                sessao.mostrarNotas = false
                            } label: {
                                HStack(alignment: .center, spacing: 12) {
                                    Text(pergunta)
                                        .font(Tema.corpo)
                                        .foregroundStyle(Tema.tinta)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "arrow.forward")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Tema.ambar)
                                        .accessibilityHidden(true)
                                }
                                .padding(16)
                                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                                        .strokeBorder(Tema.linha, lineWidth: 0.5)
                                )
                                .frame(minHeight: Tema.alvo)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .opacity(reduceMotion || visiveis > indice ? 1 : 0)
                            .offset(y: reduceMotion || visiveis > indice ? 0 : 8)
                            .accessibilityIdentifier("pergunta-padroes-\(indice)")
                            .accessibilityHint("Abre uma página vazia com esta pergunta no cartão")
                        }
                    }
                }
                .padding(Tema.margem)
            }
        }
        .background(Tema.fundo.ignoresSafeArea())
        .task {
            await carregarPerguntas()
            guard !reduceMotion else {
                visiveis = perguntas.count
                return
            }
            for i in perguntas.indices {
                try? await Task.sleep(for: .milliseconds(min(70, 45 + i * 8)))
                visiveis = i + 1
            }
        }
    }
}
