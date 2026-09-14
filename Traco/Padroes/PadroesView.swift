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
    @State private var trajetoriaLida: Trajetoria?
    /// Hermes §5: a densidade se controla no cabeçalho de cada seção.
    var recolhidas = Recolhidas("padroes")

    private func lerSemana() {
        var eventos: [EventoCalendario] = []
        if case .eventos(let lidos) = CalendarioDisco.carregar() { eventos = lidos }
        semana = RevisaoSemanal.ler(notas: notas.map(\.paraSemana), eventos: eventos)
        trajetoriaLida = Trajetoria.ler(notas: notas.map(\.paraTrajetoria), sinais: Sinais.todos())
    }

    // MARK: - A trajetória (ADR 04q)

    /// Hermes §1 e §5 (ADR 10k): a trajetória pousa no papel, sob um
    /// cabeçalho que recolhe. Os nomes das duas colunas eram caixa alta
    /// dentro de um cartão — nomeavam conteúdo; agora são frase normal.
    @ViewBuilder private var trajetoria: some View {
        if let t = self.trajetoriaLida, !t.vazia {
            recolhidas.secao("Trajetória", id: "trajetoria") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        periodo(t.recente)
                        Rectangle().fill(Tema.linha).frame(width: 0.5)
                        periodo(t.anterior)
                    }
                }
                .padding(.top, 4)
            }
            .accessibilityIdentifier("trajetoria")
        }
    }

    private func periodo(_ p: Trajetoria.Periodo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // o modelo guarda o rótulo em caixa alta para o texto exportado;
            // na tela ele é o NOME de uma coluna, e nome vai em frase normal
            Text(p.rotulo.lowercased().capitalizadoNoInicio)
                .font(Tema.meta.weight(.semibold))
                .foregroundStyle(Tema.tinta)
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
                .buttonStyle(.linha)
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
    /// A porta é a da Sabia (ADR 11a): um par já é matéria. A rota continua
    /// cortada — `provedor` é nil até remedição.
    private var paresDoJuizo: [String] {
        (semana?.calibragem ?? []).map {
            "escolha: \($0.escolha)\nesperava: \($0.esperava)\naconteceu: \($0.aconteceu)"
        }
    }

    private func lerCalibragem() async {
        let pares = paresDoJuizo
        guard Sabia.paresDaCalibragem(pares), Politica.provedor(.calibragem) != nil else { return }
        let r = await Sabia.lerCalibragem(pares: pares)
        withAnimation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { sobreOJuizo = r ?? [] }
    }

    /// Perguntas sobre o próprio juízo — nunca nota, nunca placar (§12). O que
    /// a memória apaga é a expectativa de ANTES; só o papel guarda.
    @ViewBuilder private var juizo: some View {
        if !sobreOJuizo.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sobreOJuizo, id: \.self) { p in
                    LinhaDeLista("person.fill.questionmark", p, "sobre o seu juízo", linhasDoTitulo: nil)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("sobre-o-juizo")
            .transition(Tema.transicao(.opacity.combined(with: .offset(y: 8)), reduzido: reduceMotion))
        } else if Sabia.paresDaCalibragem(paresDoJuizo), Politica.provedor(.calibragem) == nil {
            // ADR 07b: há pares para ler e ninguém que leia — dito, não calado
            LinhaDeEstado(Politica.semProvedor(.calibragem), .semConta)
                .padding(.vertical, 8)
                .accessibilityIdentifier("juizo-sem-provedor")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // §20: voltar é da barra inferior. Aqui fica o nome da tela, e só.
            // ADR 10i: a marca de perguntar, a mesma de toda tela do arquivo;
            // a folha da pergunta mora nas Notas
            // perguntar mora no campo do pé das Notas (ADR 2026-09-14a); a
            // marca "?" aqui era uma segunda porta para o mesmo lugar
            TituloTela("Padrões")

            ScrollView {
                // Hermes §1, §4 e §5 (ADR 10k): três seções no papel, sem
                // cartão; a pergunta é uma linha como outra qualquer
                VStack(alignment: .leading, spacing: Tema.entreSecoes) {
                    revisaoDaSemana
                    trajetoria
                    perguntasDaSemana
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, Tema.margem)
            }
            // a rolagem se dissolve sob o título e sobre a pílula, não corta
            .desvanece(topo: 24, pe: 48)
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

    // MARK: - As perguntas

    /// A contagem mora no cabeçalho (o "45" do Hermes); a espera e o vazio
    /// são LINHAS normais, na posição de qualquer outra (Hermes §11).
    private var perguntasDaSemana: some View {
        recolhidas.secao("Perguntas", id: "perguntas", contagem: carregou && !perguntas.isEmpty ? perguntas.count : nil) {
            if !carregou {
                LinhaDeLista("hourglass", "lendo as suas notas…", fio: false)
            } else if perguntas.isEmpty {
                LinhaDeLista("text.bubble", "ainda não há o que ler", "escreva primeiro — as perguntas nascem das suas notas abertas",
                             fio: false)
            } else {
                ForEach(Array(perguntas.enumerated()), id: \.offset) { indice, pergunta in
                    Button {
                        sessao.novaPagina()
                        sessao.perguntaPadroes = pergunta
                        sessao.mostrarPadroes = false
                        sessao.mostrarNotas = false
                    } label: {
                        // o título É a pergunta: quebra, não corta. O glifo é
                        // o de escrever — responder é abrir uma página
                        LinhaDeLista(tocavel: "square.and.pencil", pergunta, nil,
                                     linhasDoTitulo: nil, fio: indice < perguntas.count - 1)
                    }
                    .buttonStyle(.linha)
                    .opacity(reduceMotion || visiveis > indice ? 1 : 0)
                    .offset(y: reduceMotion || visiveis > indice ? 0 : 8)
                    .accessibilityIdentifier("pergunta-padroes-\(indice)")
                    .accessibilityHint("Abre uma página vazia com esta pergunta no cartão")
                }
                // "Li" dava um EU à IA — e o app não é interlocutor. A contagem
                // de notas e o que acontece ao tocar são METADADO: letra miúda
                Text("Das suas \(abertas.count) \(abertas.count == 1 ? "nota aberta" : "notas abertas"). Toque numa para responder — a resposta vira nota sua.")
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - A semana (ADR q)

    /// Uma lista só, sem subtítulos em negrito: o que era cabeçalho de bloco
    /// ("Planos sem a falha nomeada") desce para o SUBTÍTULO de cada linha, e
    /// o glifo diz o tipo pela forma antes de ler (Hermes §4).
    @ViewBuilder
    private var revisaoDaSemana: some View {
        if let r = semana, !r.vazia {
            let total = r.porForma.reduce(0) { $0 + $1.quantas }
            recolhidas.secao("Esta semana", id: "semana") {
                if !r.porForma.isEmpty {
                    LinhaDeLista("doc.on.doc", "\(total) \(total == 1 ? "nota" : "notas") em sete dias",
                                 r.porForma.map { "\($0.quantas) \($0.forma?.nome.lowercased() ?? "sem forma")" }.joined(separator: " · "))
                }
                bloco("star", "destaque", r.destaques)
                bloco("arrow.triangle.branch", "decisão a conferir", r.decisoesAConferir)
                bloco("scope", "o que está em jogo", r.desejos)
                bloco("exclamationmark.triangle", "o que pode dar errado ainda não tem nome", r.semRisco, premortem: true)
                // a hora já diz quando; "nos próximos sete dias" repetido em
                // cada linha era ruído (auditoria 13/09, defeito 10)
                bloco("calendar", "", r.proximos)
                ForEach(r.calibragem) { c in
                    Button {
                        if let nota = Sessao.buscar(uuid: c.id, no: context) {
                            sessao.abrir(nota)
                            sessao.irPara(.escrever, no: context)
                        }
                    } label: {
                        // o par é o conteúdo: duas linhas, não uma
                        LinhaDeLista(titulo: c.escolha,
                                     subtitulo: "esperava " + c.esperava + "\naconteceu " + c.aconteceu,
                                     linhasDoSubtitulo: 2,
                                     glifo: { Image(systemName: "checkmark.seal") },
                                     acessorio: { Chevron() })
                    }
                    .buttonStyle(.linha)
                    .accessibilityIdentifier("calibragem")
                }
                if !r.calibragem.isEmpty { juizo }
                ForEach(r.sentidos, id: \.self) { linha in
                    LinhaDeLista("lightbulb", linha, "ficou claro", linhasDoTitulo: 2)
                }
            }
            .accessibilityIdentifier("revisao-semana")
        }
    }

    @ViewBuilder
    private func bloco(_ simbolo: String, _ tipo: String, _ linhas: [RevisaoSemanal.Linha],
                       premortem: Bool = false) -> some View {
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
                // o "PRÉ-MORTEM" em caixa alta e âmbar era etiqueta pintada;
                // agora é o fim do subtítulo, em frase normal (ADR 10k)
                LinhaDeLista(tocavel: simbolo, linha.texto,
                             [linha.quando.map(RevisaoSemanalFormato.quando), tipo.isEmpty ? nil : tipo]
                                .compactMap { $0 }.joined(separator: " · "),
                             linhasDoTitulo: 2)
            }
            .buttonStyle(.linha)
        }
    }

}

enum RevisaoSemanalFormato {
    static func quando(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        // meia-noite em ponto é dia inteiro (aniversário, feriado): dizer
        // "00:00" era mentir a hora (auditoria 13/09, defeito 9)
        let c = Calendar.current.dateComponents([.hour, .minute], from: d)
        f.dateFormat = c.hour == 0 && c.minute == 0 ? "EEE d, 'dia inteiro'" : "EEE d, HH:mm"
        return f.string(from: d).replacingOccurrences(of: ".", with: "")
    }
}
