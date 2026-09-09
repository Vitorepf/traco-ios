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
    @Environment(\.dynamicTypeSize) private var tamanho
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

    /// Quando o revelar compara em DUAS colunas.
    ///
    /// Era só `largura >= 360` — uma medida em pontos, cega ao corpo do texto.
    /// Em AX5 as colunas ficavam com ~150 pt cada e o SwiftUI, sem espaço,
    /// prefere hifenizar a encolher: "obstá-culo", "MEMÓ-RIA", "per-gunta", e a
    /// nota ainda cortada no meio de uma letra. Regra, não modificador solto,
    /// para poder ser testada fora da tela (lição da F4, §22).
    nonisolated static func comparaLadoALado(largura: CGFloat, tamanho: DynamicTypeSize) -> Bool {
        largura >= 360 && !tamanho.isAccessibilitySize
    }

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
                        .rotulo()
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
                .transition(Tema.transicao(.opacity.combined(with: .offset(y: 8)), reduzido: reduceMotion))
            }
        } else if fase == .revelar, Politica.provedor(.conferir) == nil {
            // ADR 07b: a seção que não veio diz por quê, em vez de calar
            LinhaDeEstado(Politica.semProvedor(.conferir), .semConta)
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, Tema.margem)
                .accessibilityIdentifier("recordar-sem-provedor")
        }
    }

    /// A pergunta que chega da sábia só entra se ela ainda não veio E se o autor
    /// ainda não escreveu nada.
    ///
    /// O vídeo da volta 19 pegou o enunciado sendo trocado ~4 s depois, com o
    /// autor já escrevendo: trocar a pergunta no meio da prova é mudar a prova.
    /// Regra nomeada e testada fora da tela (lição da F4, §22) — o espaço em
    /// branco não conta como escrita, senão um toque no campo já fecharia a porta.
    nonisolated static func aceitaPergunta(jaTem: Bool, memoria: String) -> Bool {
        !jaTem && memoria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// A pergunta da prova, uma vez por abertura. Silêncio em qualquer falha.
    private func pedirPergunta() async {
        // a mesma regra ANTES de pedir: com a primeira letra a `.task(id:)`
        // cancela esta chamada e reentra aqui — sem a guarda de cima, reentrar
        // pagaria uma segunda pergunta para jogar fora (dinheiro no lixo)
        guard Self.aceitaPergunta(jaTem: perguntaDaSabia != nil, memoria: memoria),
              Politica.provedor(.recordar) != nil else { return }
        let vinda = await Sabia.perguntaDeRecordar(alvo: alvo, pista: pista,
                                                  gesto: gesto, degrau: degrau, retrato: retrato)
        // e DEPOIS de voltar: a resposta pode chegar com o autor já escrevendo.
        // Chegou antes da primeira letra, entra; chegou depois, o autor termina
        // com a pergunta que leu.
        guard Self.aceitaPergunta(jaTem: perguntaDaSabia != nil, memoria: memoria) else { return }
        perguntaDaSabia = vinda
    }

    private func conferir() {
        guard Politica.provedor(.conferir) != nil else { return }
        let pontos = Prova.pontos(alvo)
        let escrito = memoria
        let g = gesto
        Task {
            let r = await Sabia.conferir(pontos: pontos, memoria: escrito, gesto: g)
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { voltaram = r }
            // ADR 04h: o que não voltou é sinal — entra no retrato e na trajetória
            if let r { Sinais.naoVoltou(g, faltaram: pontos.count - r.count, de: pontos.count) }
        }
    }

    private var memoriaVazia: Bool {
        memoria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var escondendo: Bool { fase == .esconder }

    /// A pista (quando o método deixa uma) e a pergunta que o autor responde.
    private var perguntaDaProva: some View {
        VStack(alignment: .leading, spacing: 0) {
            if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                Text(pista)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
            }
            // ADR 03i: a pergunta era uma de cinco frases fixas — a mesma para
            // toda nota, para sempre, no ritual mais repetido do app. A da
            // sábia entra quando passa na prova de não vazar; a fixa segura o
            // lugar sempre (sem conta, sem rede, ou recusada).
            //
            // `tintaSuave` é a voz do app; `tinta` cheia é a voz do autor. A
            // pergunta e o que ele escreve ficam a 20 pt uma do outro, no mesmo
            // corpo e na mesma margem: se a pergunta subisse para `tinta`, os
            // dois parágrafos viravam um só (`law-of-similarity`).
            Text(perguntaDaSabia ?? pergunta)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tintaSuave)
                // AX5: comprimida pelo editor abaixo, a pergunta virava "O que estava…"
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("recordar-pergunta")
        }
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 16)
    }

    /// Uma saída honesta do ritual: rótulo, o que ela faz com a escada, e o ato.
    private struct Saida: Identifiable {
        let id: String
        let rotulo: String
        let dica: String
        let acao: () -> Void
    }

    /// O pé do Recordar, um só para escrever e para revelar.
    ///
    /// A auditoria V9 achou "Revelar" e "hoje não" como dois textos centrados
    /// soltos no papel, sem cara de botão (`critique-affordance`) e sem peso
    /// diferente entre o caminho e a saída (`von-restorff-effect`). O pé
    /// resolve os dois: um fio o separa da superfície de escrita
    /// (`law-of-common-region` — daí em diante é controle, não texto), a ação
    /// principal é a `Pilula(.larga)` cheia — o único objeto escuro da folha —
    /// e as saídas ficam abaixo dela, em meta. Centrar DENTRO do pé é decisão;
    /// centrar no meio do papel era o eixo esquerdo quebrado.
    private func rodape(_ principal: String, ativa: Bool = true,
                        dica: String? = nil, ax: String? = nil,
                        acao: @escaping () -> Void,
                        saidas: [Saida] = []) -> some View {
        VStack(spacing: 4) {
            Button(action: acao) {
                // desabilitada, a `Pilula` guarda a cápsula e a tinta legível
                // por dentro do componente (V12-B): o contorno à mão que vivia
                // aqui virava hairline dobrada e saiu
                Pilula(principal, forma: .larga, selecionada: ativa)
            }
            .buttonStyle(.discreto)
            .disabled(!ativa)
            .accessibilityHint(dica ?? "")
            // o rótulo da cápsula é minúsculo por desenho; o VoiceOver lê o nome
            // da ação, que a volta 19 tinha perdido ao trocar o botão pelo pé
            .accessibilityLabel(ax ?? principal)
            .accessibilityIdentifier("recordar-principal")

            if !saidas.isEmpty {
                HStack(spacing: 20) {
                    ForEach(saidas) { saida in
                        Button(saida.rotulo, action: saida.acao)
                            .alvo()
                            .accessibilityHint(saida.dica)
                            .accessibilityIdentifier("recordar-\(saida.id)")
                    }
                }
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .buttonStyle(.discreto)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Tema.margem)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .overlay(alignment: .top) { Rectangle().fill(Tema.linha).frame(height: 0.5) }
    }

    var body: some View {
        // .leading: tudo nasce na margem esquerda. Em `.center` (o default) a
        // linha "serviu / não serviu" e as ações flutuavam centradas contra um
        // conteúdo todo alinhado à esquerda — três eixos numa tela só
        // (`law-of-continuity`). Quem quer largura inteira ainda pede.
        VStack(alignment: .leading, spacing: 0) {
            CabecalhoDeFolha(saida: .voltar, aoSair: { dismiss() }) {
                Text("RECORDAR").rotulo()
            }
            .padding(.horizontal, Tema.margem)
            // cabeçalho é chrome: como a barra do sistema, não cresce em AX
            // (a AX5 partia "RECORDAR" em duas linhas e cortava "voltar")
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            if fase == .ler || fase == .esconder {
                Text(instrucao)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 16)
                    // §21, um objeto um driver: a frase promete que a nota vai
                    // se esconder — ela sai NO MESMO driver da nota, não 0,9 s
                    // depois. No vídeo da V9 ela ficava sozinha e legível numa
                    // tela já vazia, prometendo o que já tinha acontecido.
                    .opacity(escondendo ? 0 : 1)
                    // sai em corte: em fade ela cruzava com a pergunta na mesma linha
                    .transition(entraFase)
            }

            switch fase {
            case .ler, .esconder:
                // §21: a nota que se esconde é UM objeto — o mesmo texto embaça
                // e apaga; antes eram duas views cruzando em fade
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
                            .blur(radius: escondendo && !reduceMotion ? 14 : 0)
                            .scaleEffect(escondendo && !reduceMotion ? 0.985 : 1)
                            .opacity(escondendo ? 0.25 : 1)
                            .padding(.horizontal, Tema.margem)
                            .accessibilityHidden(escondendo)
                    }
                }
                .transition(entraFase)
            case .escrever:
                Group {
                // A pergunta cede ALTURA, nunca legibilidade. Em AX5 ela ocupava
                // sete linhas e deixava ao autor um campo de linha e meia — a
                // prática não cabia na tela onde ela acontece. `ViewThatFits`
                // resolve sem medir nada: cabe inteira, ela encosta na pergunta
                // e o campo começa logo abaixo; não cabe, a MESMA pergunta rola
                // dentro do que sobra. O `fixedSize` fica nos dois ramos — é o
                // que impede o SwiftUI de hifenizar em vez de encolher (F4).
                GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                // A pergunta nunca passa de metade do vão. `layoutPriority` não
                // servia: com prioridade a `ScrollView` recebe a proposta
                // inteira e fica com ela, e numa pergunta longa da sábia em AX5
                // o cabeçalho, o "serviu" e o rodapé se sobrepuseram na tela.
                //
                // A metade é TETO, não cota. O `.frame(maxHeight:)` do lado de
                // fora do `ViewThatFits` cobrava a metade inteira mesmo quando a
                // pergunta tinha duas linhas: em `large` abriam ~198 pt de papel
                // morto e o autor escrevia no meio da folha. O teto desceu para
                // dentro do ramo que rola — o único que precisa dele.
                ViewThatFits(in: .vertical) {
                    perguntaDaProva
                    ScrollView { perguntaDaProva }
                        .frame(height: geo.size.height / 2)
                }
                TextEditor(text: $memoria)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .scrollContentBackground(.hidden)
                    .focused($foco)
                    .tint(Tema.ambar)
                    // o piso do campo: três alvos. Sem ele o VStack dava tudo à
                    // pergunta em corpos grandes e o autor escrevia numa fresta
                    .frame(minHeight: Tema.alvo * 3)
                    .padding(.horizontal, Tema.margem - 5)
                    .accessibilityLabel("Memória")
                if let q = perguntaDaSabia, !avaliou {
                    // ADR 04h: a pergunta da prova também recebe o sinal.
                    // Fica DEPOIS do campo: julgar a pergunta da sábia é o ato
                    // menos importante da tela e estava no segundo lugar mais
                    // visível dela, entre a pergunta e o lugar de escrever.
                    // Continua em TODO corpo de texto: esconder o julgamento de
                    // quem usa letra grande seria tirar poder de quem já tem menos.
                    HStack(spacing: 14) {
                        Button("serviu") { Sinais.pergunta(q, forma: gesto, serviu: true); avaliou = true; Toque.leve() }
                            .accessibilityIdentifier("serviu")
                        Button("não serviu") { Sinais.pergunta(q, forma: gesto, serviu: false); avaliou = true; Toque.leve() }
                            .accessibilityIdentifier("nao-serviu")
                    }
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaFraca)
                    .buttonStyle(.discreto)
                    .frame(minHeight: 32)
                    .padding(.horizontal, Tema.margem)
                    .accessibilityLabel("A pergunta serviu?")
                }
                }
                }
                // as duas saídas honestas: adiar não é falhar, e pular não
                // pode custar um degrau da escada
                rodape("Revelar", ativa: !memoriaVazia,
                       dica: memoriaVazia ? "Escreva de memória primeiro" : "Mostra memória e nota lado a lado",
                       acao: {
                           Toque.suave()
                           foco = false
                           aoRevelar()
                           conferir()
                           withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { fase = .revelar }
                       },
                       saidas: [
                        aoAdiar.map { Saida(id: "adiar", rotulo: "hoje não", dica: "Volta amanhã. A escada não muda.", acao: $0) },
                        aoPular.map { Saida(id: "pular", rotulo: "pular", dica: "Vai à próxima sem revelar esta", acao: $0) },
                       ].compactMap { $0 })
                }
                // um Group: cada irmão da fase corta ao sair e amanhece ao entrar
                .transition(entraFase)
            case .revelar:
                Group {
                GeometryReader { geo in
                    let ladoALado = Self.comparaLadoALado(largura: geo.size.width, tamanho: tamanho)
                    // `.topLeading`: sem isto a grade centra verticalmente a
                    // célula mais curta, e "DE MEMÓRIA" descia 57 pt abaixo de
                    // "A NOTA" — dois rótulos do mesmo posto em alturas
                    // diferentes (`law-of-continuity`)
                    let colunas = ladoALado
                        ? [GridItem(.flexible(), spacing: 16, alignment: .topLeading),
                           GridItem(.flexible(), spacing: 16, alignment: .topLeading)]
                        : [GridItem(.flexible(), alignment: .topLeading)]
                    ScrollView {
                        LazyVGrid(columns: colunas, alignment: .leading, spacing: 22) {
                            bloco("DE MEMÓRIA", memoria)
                                .transition(Tema.transicao(.opacity.combined(with: .offset(y: 10)), reduzido: reduceMotion))
                            bloco(rotuloAlvo, alvo)
                                .transition(Tema.transicao(.opacity.combined(with: .offset(y: 10)), reduzido: reduceMotion))
                                .animation(Tema.animacao(.easeOut(duration: Tema.Duracao.media).delay(Tema.Duracao.toque), reduzido: reduceMotion), value: fase)
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
                rodape(aoProxima == nil ? "Voltar à página" : "próxima",
                       dica: aoProxima == nil ? "" : "Abre a seguinte. Sem contagem.",
                       ax: aoProxima == nil ? nil : "Próxima",
                       acao: { if let aoProxima { aoProxima() } else { dismiss() } },
                       saidas: [
                        aoCobrarAntes.map { Saida(id: "cobrar", rotulo: "cobrar antes", dica: "A escada volta a 3 dias", acao: $0) },
                       ].compactMap { $0 })
                }
                .transition(entraFase)
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
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.longa), reduzido: reduceMotion)) { fase = .esconder }
            try? await Task.sleep(for: esperaBlur)
            withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { fase = .escrever }
            foco = true
        }
        // task separada: a pergunta vem pela rede e o ritmo do ritual NÃO pode
        // esperar por ela. Chegou a tempo, entra; chegou tarde, o autor já está
        // escrevendo com a frase fixa e nada muda embaixo dele.
        //
        // `id: memoriaVazia`: a primeira letra CANCELA a chamada em voo em vez
        // de só descartar a resposta quando ela chega — com conta da sábia, uma
        // pergunta tardia era paga e jogada fora.
        .task(id: memoriaVazia) { await pedirPergunta() }
    }

    /// §21, "nada de cross-fade entre irmãos": a fase que sai corta seco e a
    /// que entra amanhece — nunca há um quadro com dois textos na mesma linha.
    private var entraFase: AnyTransition {
        .asymmetric(
            insertion: Tema.transicao(.opacity.combined(with: .offset(y: 8)), reduzido: reduceMotion),
            removal: .identity)
    }

    private func bloco(_ titulo: String, _ corpo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .rotulo(Tema.tintaSuave)
            Text(corpo)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}
