import SwiftUI

/// O que cada forma esconde no Recordar. Destilar some tudo; o resto mostra
/// o alvo na leitura — Palavra e Se deixam a pista visível.
enum RitualRecordar: Equatable, Sendable {
    case livre, destilada, palavra, seEntao, decisao
    /// ADR 04l: o ritual declarado no catálogo — o método diz o que some e o
    /// que fica de pista.
    case campos(Metodo.RecordarSpec)

    nonisolated static func de(_ gesto: Gesto?) -> Self {
        switch gesto {
        case .destilar: return .destilada
        case .palavra: return .palavra
        case .seEntao: return .seEntao
        case .decisao: return .decisao
        default:
            if let spec = gesto?.metodoDef.recordar, !spec.alvo.isEmpty { return .campos(spec) }
            return .livre
        }
    }

    nonisolated static func juntar(_ ids: [String], _ campos: [String: String]) -> String {
        ids.compactMap { campos[$0]?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    /// Destilar some tudo. Palavra deixa a definição e some a palavra.
    /// Mostrar o alvo antes é ditado, não memória.
    nonisolated var mostraAlvoAntesDeEscrever: Bool {
        switch self {
        case .destilada, .palavra: false
        case .campos(let spec): spec.mostraAntes
        default: true
        }
    }

    /// O que o autor tenta lembrar. Destilar cobra a frase — ou o corte
    /// mais curto que ele chegou a fazer. O rascunho de origem nunca é o alvo:
    /// era o que se cortava, não o que se lembra.
    nonisolated func alvo(texto: String, campos: [String: String]) -> String {
        switch self {
        case .livre:
            return VozDoAutor.juntar(texto: texto, campos: campos)
        case .destilada:
            for id in ["frase", "em50", "em100", "em200"] {
                let corte = campos[id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !corte.isEmpty { return corte }
            }
            return ""
        case .palavra:
            return Caderno.prosa(de: texto).trimmingCharacters(in: .whitespacesAndNewlines)
        case .seEntao:
            return campos["entao"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case .decisao:
            // o que eu esperava, antes de saber o que aconteceu: é o que a
            // memória reescreve primeiro (hindsight), por isso é o alvo
            return campos["espero"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case .campos(let spec):
            return Self.juntar(spec.alvo, campos)
        }
    }

    nonisolated func temAlvo(texto: String, campos: [String: String]) -> Bool {
        !alvo(texto: texto, campos: campos).isEmpty
    }
}

struct RecordarView: View {
    let texto: String
    let campos: [String: String]
    var gesto: Gesto?
    var aoRevelar: () -> Void = {}
    var aoCobrarAntes: (() -> Void)?
    var aoProxima: (() -> Void)?
    /// R1: "hoje não" — empurra para amanhã sem mexer na escada.
    var aoAdiar: (() -> Void)?
    /// R2: pular a fila sem revelar (revelar sobe o degrau).
    var aoPular: (() -> Void)?
    /// ADR 03i: em que degrau da escada esta nota está AGORA (antes de revelar).
    /// A mesma nota tem de cobrar mais fundo a cada volta — senão a décima
    /// revisão é idêntica à primeira, e recuperação sem dificuldade não fixa.
    var degrau: Int = 0
    /// ADR 04i: o retrato vai junto da pergunta da prova.
    var retrato: String = ""
    @State private var avaliou = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var fase: Fase
    @State private var memoria = ""
    /// ADR 03i: a pergunta que a sábia fez sobre ESTA nota. nil = a fixa.
    @State private var perguntaDaSabia: String?
    /// Quais pontos do alvo voltaram na memória do autor. nil = não conferiu
    /// (sem conta, sem rede, ou resposta recusada) — e aí não se mostra nada.
    @State private var voltaram: Set<Int>?
    @FocusState private var foco: Bool

    private enum Fase {
        case ler, esconder, escrever, revelar
    }

    init(texto: String, campos: [String: String], gesto: Gesto? = nil,
         aoRevelar: @escaping () -> Void = {},
         aoCobrarAntes: (() -> Void)? = nil,
         aoProxima: (() -> Void)? = nil,
         aoAdiar: (() -> Void)? = nil,
         aoPular: (() -> Void)? = nil,
         degrau: Int = 0,
         retrato: String = "") {
        self.texto = texto
        self.campos = campos
        self.gesto = gesto
        self.aoRevelar = aoRevelar
        self.aoCobrarAntes = aoCobrarAntes
        self.aoProxima = aoProxima
        self.aoAdiar = aoAdiar
        self.aoPular = aoPular
        self.degrau = degrau
        self.retrato = retrato
        _fase = State(initialValue: RitualRecordar.de(gesto).mostraAlvoAntesDeEscrever ? .ler : .escrever)
    }

    private var modo: RitualRecordar { RitualRecordar.de(gesto) }

    private var notaInteira: String {
        VozDoAutor.juntar(texto: texto, campos: campos)
    }

    private var pista: String {
        switch modo {
        case .livre: notaInteira
        case .destilada: ""
        case .palavra: campos["minhas"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case .seEntao: campos["se"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case .decisao: [campos["escolha"], campos["decidido"]].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }.joined(separator: "\n")
        case .campos(let spec): RitualRecordar.juntar(spec.pista, campos)
        }
    }

    private var alvo: String {
        modo.alvo(texto: texto, campos: campos)
    }

    private var pergunta: String {
        switch modo {
        case .livre: "O que estava escrito?"
        case .destilada: "A frase?"
        case .palavra: "Qual era a palavra?"
        case .seEntao: "Então você faz o quê?"
        case .decisao: "O que você esperava que acontecesse?"
        case .campos(let spec): spec.pergunta
        }
    }

    private var instrucao: String {
        switch modo {
        case .livre: "Leia uma última vez — a nota vai se esconder."
        case .destilada: "A frase some. Escreva-a de memória."
        case .palavra: "A definição fica. A palavra some."
        case .seEntao: "O Se fica. O Então some."
        case .decisao: "A escolha fica. O que você esperava some."
        case .campos(let spec): spec.instrucao
        }
    }

    private var rotuloAlvo: String {
        switch modo {
        case .livre: "A NOTA"
        case .destilada: "A FRASE"
        case .palavra: "A PALAVRA"
        case .seEntao: "ENTÃO"
        case .decisao: "O QUE EU ESPERAVA"
        case .campos(let spec): spec.rotuloAlvo
        }
    }

    /// O que a memória NÃO trouxe — nas palavras do autor, sempre.
    ///
    /// Sem placar, sem nota, sem porcentagem (§12): recuperação parcial é o
    /// caso NORMAL da prática de recuperação, não um fracasso a medir. Só se
    /// mostra o que faltou, que é a única parte com serventia — reler.
    @ViewBuilder private var naoVoltou: some View {
        if let voltaram {
            let faltando = Prova.pontos(alvo).enumerated()
                .filter { !voltaram.contains($0.offset) }
                .map(\.element)
            if !faltando.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("O QUE NÃO VOLTOU")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(Tema.tintaFraca)
                    ForEach(Array(faltando.enumerated()), id: \.offset) { _, ponto in
                        Text(ponto)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, Tema.margem)
                .accessibilityIdentifier("recordar-nao-voltou")
                // chega alguns segundos depois do lado a lado: aparecer de
                // estalo assusta quem está lendo (§21)
                .transition(.opacity.combined(with: .offset(y: 8)))
            }
        }
    }

    /// A pergunta da prova, uma vez por abertura. Silêncio em qualquer falha.
    private func pedirPergunta() async {
        guard perguntaDaSabia == nil, Sabia.disponivel else { return }
        perguntaDaSabia = await Sabia.perguntaDeRecordar(alvo: alvo, pista: pista,
                                                         gesto: gesto, degrau: degrau, retrato: retrato)
    }

    private func conferir() {
        guard Sabia.disponivel else { return }
        let pontos = Prova.pontos(alvo)
        let escrito = memoria
        let g = gesto
        Task {
            let r = await Sabia.conferir(pontos: pontos, memoria: escrito, gesto: g)
            withAnimation(.easeOut(duration: 0.3)) { voltaram = r }
            // ADR 04h: o que não voltou é sinal — entra no retrato e na trajetória
            if let r { Sinais.naoVoltou(g, faltaram: pontos.count - r.count, de: pontos.count) }
        }
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
                            .font(Tema.chrome)
                    }
                }
                    .foregroundStyle(Tema.tinta)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityLabel("Voltar")
                Spacer()
                Text("RECORDAR")
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaFraca)
                Spacer()
                Color.clear.frame(width: 64, height: Tema.alvo)
            }
            .padding(.horizontal, Tema.margem)

            if fase == .ler || fase == .esconder {
                Text(instrucao)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 16)
            }

            switch fase {
            case .ler:
                ScrollView {
                    if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                        Text(pista)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                            .padding(.bottom, 16)
                    }
                    if modo.mostraAlvoAntesDeEscrever {
                        Text(alvo)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                    }
                }
            case .esconder:
                ScrollView {
                    if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                        Text(pista)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                            .padding(.bottom, 16)
                    }
                    if modo.mostraAlvoAntesDeEscrever {
                        Text(alvo)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                            .blur(radius: reduceMotion ? 0 : 14)
                            .scaleEffect(reduceMotion ? 1 : 0.985)
                            .opacity(0.25)
                            .padding(.horizontal, Tema.margem)
                            .accessibilityHidden(true)
                    }
                }
            case .escrever:
                if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                    Text(pista)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tema.margem)
                        .padding(.bottom, 12)
                }
                // ADR 03i: a pergunta era uma de cinco frases fixas — a mesma
                // para toda nota, para sempre, no ritual mais repetido do app.
                // A da sábia entra quando passa na prova de não vazar; a fixa
                // segura o lugar sempre (sem conta, sem rede, ou recusada).
                Text(perguntaDaSabia ?? pergunta)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 8)
                    .accessibilityIdentifier("recordar-pergunta")
                if let q = perguntaDaSabia, !avaliou {
                    // ADR 04h: a pergunta da prova também recebe o sinal
                    HStack(spacing: 14) {
                        Button("serviu") { Sinais.pergunta(q, forma: gesto, serviu: true); avaliou = true; Toque.leve() }
                            .accessibilityIdentifier("serviu")
                        Button("não serviu") { Sinais.pergunta(q, forma: gesto, serviu: false); avaliou = true; Toque.leve() }
                            .accessibilityIdentifier("nao-serviu")
                    }
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaFraca)
                    .buttonStyle(PressaoDiscreta())
                    .frame(minHeight: 32)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 4)
                }
                TextEditor(text: $memoria)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .scrollContentBackground(.hidden)
                    .focused($foco)
                    .tint(Tema.ambar)
                    .padding(.horizontal, Tema.margem - 5)
                    .accessibilityLabel("Memória")
                Button("Revelar") {
                    Toque.suave()
                    foco = false
                    aoRevelar()
                    conferir()
                    withAnimation(.easeOut(duration: 0.35)) { fase = .revelar }
                }
                .disabled(memoriaVazia)
                .buttonStyle(PrimarioStyle(recede: memoriaVazia))
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
                .accessibilityHint(memoriaVazia ? "Escreva de memória primeiro" : "Mostra memória e nota lado a lado")
                // as duas saídas honestas: adiar não é falhar, e pular não
                // pode custar um degrau da escada
                HStack(spacing: 20) {
                    if let aoAdiar {
                        Button("hoje não") { aoAdiar() }
                            .accessibilityHint("Volta amanhã. A escada não muda.")
                            .accessibilityIdentifier("recordar-adiar")
                    }
                    if let aoPular {
                        Button("pular") { aoPular() }
                            .accessibilityHint("Vai à próxima sem revelar esta")
                            .accessibilityIdentifier("recordar-pular")
                    }
                }
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())
                .padding(.bottom, 8)
            case .revelar:
                GeometryReader { geo in
                    let ladoALado = geo.size.width >= 360
                    let colunas = ladoALado
                        ? [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                        : [GridItem(.flexible())]
                    ScrollView {
                        LazyVGrid(columns: colunas, alignment: .leading, spacing: 22) {
                            bloco("DE MEMÓRIA", memoria)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                            bloco(rotuloAlvo, alvo)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                                .animation(.easeOut(duration: 0.35).delay(0.08), value: fase)
                        }
                        .padding(Tema.margem)
                        .overlay {
                            if ladoALado {
                                Rectangle()
                                    .fill(Tema.linha)
                                    .frame(width: 0.5)
                                    .padding(.vertical, Tema.margem)
                            }
                        }
                        naoVoltou
                    }
                }
                VStack(spacing: 4) {
                    if let aoProxima {
                        Button("próxima") { aoProxima() }
                            .buttonStyle(PrimarioStyle())
                            .accessibilityLabel("Próxima")
                            .accessibilityHint("Abre a seguinte. Sem contagem.")
                    } else {
                        Button("Voltar à página") { dismiss() }
                            .buttonStyle(PrimarioStyle())
                    }
                    if let aoCobrarAntes {
                        Button("cobrar antes") { aoCobrarAntes() }
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityHint("A escada volta a 3 dias")
                    }
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
            }
        }
        .background(Tema.fundo.ignoresSafeArea())
        .task {
            if !modo.mostraAlvoAntesDeEscrever {
                foco = true
                return
            }
            let esperaLeitura: Duration = reduceMotion ? .milliseconds(200) : .milliseconds(1500)
            let esperaBlur: Duration = reduceMotion ? .milliseconds(250) : .milliseconds(900)
            try? await Task.sleep(for: esperaLeitura)
            withAnimation(.easeOut(duration: reduceMotion ? 0.18 : 0.4)) { fase = .esconder }
            try? await Task.sleep(for: esperaBlur)
            withAnimation(.easeOut(duration: 0.3)) { fase = .escrever }
            foco = true
        }
        // task separada: a pergunta vem pela rede e o ritmo do ritual NÃO pode
        // esperar por ela. Chegou a tempo, entra; chegou tarde, o autor já está
        // escrevendo com a frase fixa e nada muda embaixo dele.
        .task { await pedirPergunta() }
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
            .foregroundStyle(recede ? Tema.tintaFraca : Tema.ambarTinta)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
