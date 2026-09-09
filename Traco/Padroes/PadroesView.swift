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
    ///
    /// Lida UMA vez, no `.task` — era propriedade computada lida do `body`, e
    /// abria e decodificava `calendario.json` do disco em toda invalidação da
    /// árvore, mais um `tituloNaLista` por nota.
    @State private var semana: RevisaoSemanal?
    /// ADR 03o: a leitura da calibragem — o padrão ENTRE os pares que o autor
    /// não vê olhando um de cada vez. Vazio = nada verificado, e nada se mostra.
    @State private var sobreOJuizo: [String] = []
    /// ADR 04q: dois períodos lado a lado, sem seta e sem placar.
    @State private var trajetoria: Trajetoria?

    private func lerSemana() {
        var eventos: [EventoCalendario] = []
        if case .eventos(let lidos) = CalendarioDisco.carregar() { eventos = lidos }
        let lidas = notas.map {
            RevisaoSemanal.NotaLida(uuid: $0.uuid, gesto: $0.gesto, fechada: $0.fechada, criadaEm: $0.criadaEm,
                                    gatilhoEm: $0.gatilhoEm, titulo: $0.tituloNaLista, campos: $0.campos,
                                    sentido: $0.sentido, queimadaOuSeladaEm: $0.queimadaEm ?? $0.editadaEm)
        }
        semana = RevisaoSemanal.ler(notas: lidas, eventos: eventos)
        trajetoria = Trajetoria.ler(notas: notas.map {
            Trajetoria.NotaLida(uuid: $0.uuid, gesto: $0.gesto, fechada: $0.fechada, criadaEm: $0.criadaEm,
                                editadaEm: $0.queimadaEm ?? $0.editadaEm, campos: $0.campos, sentido: $0.sentido,
                                doAutor: $0.origem == .autor)
        }, sinais: Sinais.todos())
    }

    // MARK: - A trajetória (ADR 04q)

    @ViewBuilder private var cartaoTrajetoria: some View {
        if let t = trajetoria, !t.vazia {
            VStack(alignment: .leading, spacing: 12) {
                Text("TRAJETÓRIA")
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                Text("Dois períodos, lado a lado. Sem nota, sem seta: quem lê é você.")
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
                HStack(alignment: .top, spacing: 12) {
                    periodo(t.recente)
                    Rectangle().fill(Tema.linha).frame(width: 0.5)
                    periodo(t.anterior)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieElevada()
            .padding(.bottom, 8)
            .accessibilityIdentifier("trajetoria")
        }
    }

    private func periodo(_ p: Trajetoria.Periodo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(p.rotulo)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
            Text("\(p.notas) \(p.notas == 1 ? "nota" : "notas")")
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
            if !p.porForma.isEmpty {
                Text(p.porForma.joined(separator: " · "))
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !p.obstaculos.isEmpty { linhas("Obstáculos", p.obstaculos) }
            if !p.recordar.isEmpty { miuda("Recordar", p.recordar) }
            if !p.calibragem.isEmpty { miuda("Decisões", p.calibragem) }
            if !p.palavras.isEmpty { linhas("Palavras", p.palavras) }
            if !p.sentidos.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("O que ficou claro").font(Tema.meta.weight(.semibold)).foregroundStyle(Tema.tinta)
                    ForEach(p.sentidos, id: \.self) { Text("— " + $0).font(Tema.meta).foregroundStyle(Tema.tintaSuave).fixedSize(horizontal: false, vertical: true) }
                }
            }
            if p.vazio {
                Text("nada neste período.")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaFraca)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func miuda(_ titulo: String, _ texto: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo).font(Tema.meta.weight(.semibold)).foregroundStyle(Tema.tinta)
            Text(texto).font(Tema.meta).foregroundStyle(Tema.tintaSuave).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func linhas(_ titulo: String, _ xs: [Trajetoria.Linha]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo).font(Tema.meta.weight(.semibold)).foregroundStyle(Tema.tinta)
            ForEach(xs) { l in
                Button {
                    guard let nota = Sessao.buscar(uuid: l.id, no: context) else { return }
                    sessao.abrir(nota)
                    sessao.irPara(.escrever, no: context)
                } label: {
                    Text("“" + l.texto + "”")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDiscreta())
            }
        }
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

    /// A única leitura do app que olha para o AUTOR e não para um texto.
    /// Só entra com dois pares ou mais: um caso não é padrão.
    private func lerCalibragem() async {
        guard let c = semana?.calibragem, c.count >= 2, Politica.provedor(.calibragem) != nil else { return }
        let pares = c.map { "escolha: \($0.escolha)\nesperava: \($0.esperava)\naconteceu: \($0.aconteceu)" }
        let r = await Sabia.lerCalibragem(pares: pares)
        withAnimation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { sobreOJuizo = r ?? [] }
    }

    /// Perguntas sobre o próprio juízo — nunca nota, nunca placar (§12). O que
    /// a memória apaga é a expectativa de ANTES; só o papel guarda.
    @ViewBuilder private var juizo: some View {
        if !sobreOJuizo.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Sobre o seu juízo")
                    .font(Tema.meta.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                ForEach(sobreOJuizo, id: \.self) { p in
                    Text("— " + p)
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("sobre-o-juizo")
            .transition(Tema.transicao(.opacity.combined(with: .offset(y: 8)), reduzido: reduceMotion))
        } else if let c = semana?.calibragem, c.count >= 2, Politica.provedor(.calibragem) == nil {
            // ADR 07b: há pares para ler e ninguém que leia — dito, não calado
            LinhaDeEstado(Politica.semProvedor(.calibragem), .semConta)
                .accessibilityIdentifier("juizo-sem-provedor")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // §20: voltar é da barra inferior. Aqui fica o nome da tela, e só.
            TituloTela("Padrões")

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    revisaoDaSemana
                    cartaoTrajetoria
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
            lerSemana()
            await carregarPerguntas()
            await lerCalibragem()
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
        if let r = semana, !r.vazia {
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
                if !r.calibragem.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Decisões conferidas")
                            .font(Tema.meta.weight(.semibold))
                            .foregroundStyle(Tema.tinta)
                        ForEach(r.calibragem) { c in
                            Button {
                                if let nota = Sessao.buscar(uuid: c.id, no: context) {
                                    sessao.abrir(nota)
                                    sessao.irPara(.escrever, no: context)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(c.escolha)
                                        .font(Tema.meta)
                                        .foregroundStyle(Tema.tinta)
                                        .lineLimit(1)
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("esperava")
                                            .font(Tema.label)
                                            .tracking(Tema.trackingLabel)
                                            .foregroundStyle(Tema.tintaFraca)
                                            .frame(width: 74, alignment: .leading)
                                        Text(c.esperava)
                                            .font(Tema.meta)
                                            .foregroundStyle(Tema.tintaSuave)
                                            .lineLimit(2)
                                    }
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("aconteceu")
                                            .font(Tema.label)
                                            .tracking(Tema.trackingLabel)
                                            .foregroundStyle(Tema.tintaFraca)
                                            .frame(width: 74, alignment: .leading)
                                        Text(c.aconteceu)
                                            .font(Tema.meta)
                                            .foregroundStyle(Tema.tinta)
                                            .lineLimit(2)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityIdentifier("calibragem")
                        }
                        juizo
                    }
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
