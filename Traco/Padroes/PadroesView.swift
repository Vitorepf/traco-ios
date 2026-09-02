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
        Array(notas.filter { !$0.fechada && !$0.vozDoAutor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.prefix(12))
    }

    /// Grok quando há chave (perguntas NOVAS a cada visita); local de guarda.
    /// Nunca a mesma pergunta duas visitas seguidas.
    /// SPEC §9.1: as últimas ~12 vozes. De uma fechada só entra a linha de
    /// sentido (§8.5) — nunca o texto; `notas` já vem da mais recente à mais antiga.
    private var vozes: [String] {
        Array(notas.compactMap { nota -> String? in
            let voz = nota.fechada ? nota.sentido : nota.vozDoAutor
            return voz.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : voz
        }.prefix(12))
    }

    private func carregarPerguntas() async {
        let vozes = vozes
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
            TituloTela("Padrões")

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
                        // "Li" dava um EU à IA — e o app não é interlocutor.
                        // Se é preciso avisar que quem conclui é o autor, é
                        // porque a frase anterior sugeriu o contrário.
                        // contagem + instrução são METADADO: no corpo de 20pt
                        // pesavam igual às próprias perguntas, que são o
                        // conteúdo. Mesmo tamanho da contagem em Notas.
                        Text("\(abertas.count) \(abertas.count == 1 ? "nota" : "notas"), \(perguntas.count) \(perguntas.count == 1 ? "pergunta" : "perguntas"). Toque numa para responder — a resposta vira nota sua.")
                            .font(Tema.meta)
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
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Tema.tintaFraca)
                                        .accessibilityHidden(true)
                                }
                                .padding(16)
                                .superficieElevada()
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
