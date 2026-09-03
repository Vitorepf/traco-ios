import SwiftData
import SwiftUI

struct PadroesView: View {
    @Bindable var sessao: Sessao
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]
    @State private var visiveis = 0
    @State private var perguntas: [String] = []
    @State private var carregou = false
    @Environment(\.modelContext) private var context

    /// ADR q: a revisão da semana, sem rede. Deixas e compromissos vêm do calendário.
    private var semana: RevisaoSemanal {
        var eventos: [EventoCalendario] = []
        if case .eventos(let lidos) = CalendarioDisco.carregar() { eventos = lidos }
        let lidas = notas.map {
            RevisaoSemanal.NotaLida(uuid: $0.uuid, gesto: $0.gesto, fechada: $0.fechada, criadaEm: $0.criadaEm,
                                    gatilhoEm: $0.gatilhoEm, titulo: $0.tituloNaLista, campos: $0.campos,
                                    sentido: $0.sentido, queimadaOuSeladaEm: $0.queimadaEm ?? $0.editadaEm)
        }
        return RevisaoSemanal.ler(notas: lidas, eventos: eventos)
    }

    private var abertas: [Nota] {
        // §8.8, §19.1: expressiva em curso (app morto no timer, relançado) nunca vai à rede
        Array(notas.filter { !$0.fechada && $0.gesto != .expressiva && !$0.vozDoAutor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.prefix(12))
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
            TituloTela("Padrões")

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    revisaoDaSemana
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

    // MARK: - A semana (ADR q)

    @ViewBuilder
    private var revisaoDaSemana: some View {
        let r = semana
        if !r.vazia {
            VStack(alignment: .leading, spacing: 12) {
                Text("ESTA SEMANA")
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                if !r.porForma.isEmpty {
                    Text(r.porForma.map { "\($0.quantas) \($0.forma?.nome.lowercased() ?? "sem forma")" }.joined(separator: " · "))
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                }
                if !r.destaques.isEmpty {
                    bloco("Os destaques", r.destaques)
                }
                if !r.decisoesAConferir.isEmpty {
                    bloco("Decisões a conferir", r.decisoesAConferir)
                }
                if !r.desejos.isEmpty {
                    bloco("O que está em jogo", r.desejos)
                }
                if !r.semRisco.isEmpty {
                    bloco("Planos sem a falha nomeada", r.semRisco, premortem: true)
                }
                if !r.proximos.isEmpty {
                    bloco("Próximos sete dias", r.proximos)
                }
                if !r.sentidos.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("O que ficou claro")
                            .font(Tema.meta.weight(.semibold))
                            .foregroundStyle(Tema.tinta)
                        ForEach(r.sentidos, id: \.self) { linha in
                            Text("— " + linha)
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaSuave)
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieElevada()
            .padding(.bottom, 8)
            .accessibilityIdentifier("revisao-semana")
        }
    }

    private func bloco(_ titulo: String, _ linhas: [RevisaoSemanal.Linha], premortem: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(Tema.meta.weight(.semibold))
                .foregroundStyle(Tema.tinta)
            ForEach(linhas) { linha in
                Button {
                    guard let nota = Sessao.buscar(uuid: linha.id, no: context) else { return }
                    if premortem {
                        // um toque abre o pré-mortem DESTE plano; o plano fica
                        sessao.abrirPremortem(de: nota, no: context)
                    } else {
                        sessao.abrir(nota)
                        sessao.irPara(.escrever, no: context)
                    }
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        if let q = linha.quando {
                            Text(RevisaoSemanalFormato.quando(q))
                                .font(Tema.meta.monospacedDigit())
                                .foregroundStyle(Tema.tintaFraca)
                        }
                        Text(linha.texto)
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        if premortem {
                            Spacer(minLength: 4)
                            Text("PRÉ-MORTEM")
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(0.8)
                                .foregroundStyle(Tema.ambarTinta)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDiscreta())
            }
        }
    }
}

enum RevisaoSemanalFormato {
    static func quando(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEE d, HH:mm"
        return f.string(from: d).replacingOccurrences(of: ".", with: "")
    }
}
