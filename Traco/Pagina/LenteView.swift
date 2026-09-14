import SwiftUI

/// A lente sobre a página: o que se repete, o que enfraquece, o que é de
/// outro. Só aponta; a página continua do autor (regra de ferro 1).
/// Apontar (ADR k): o autor marca um trecho seu com um rótulo fechado.
struct LenteView: View {
    let texto: String
    /// Sem nota no disco (ou expressiva) não se aponta: só se lê.
    var notaUUID: UUID?
    var gesto: Gesto? = nil
    @Environment(\.dismiss) private var dismiss
    /// ADR 04i: o retrato viaja com a instigação e o contrapor.
    var retrato: String = ""
    @State private var perguntasDaSabia: [String] = []
    /// Desde quando a sábia instiga; nil = não está. A hora é o que a
    /// `Espera` mostra andando (DIRETRIZ §13 item 3), e a tarefa é o que
    /// "Parar de esperar" cancela.
    @State private var instigandoDesde: Date?
    @State private var tarefaInstigar: Task<Void, Never>?
    /// ADR 04m: o que o autor não considerou. Nil = nada pedido ou nada honesto.
    /// ADR 2026-09-09s: a `Contraparte` VAZIA nunca chega aqui — ela é aviso,
    /// não conteúdo, e mostrá-la seria uma seção com três rótulos e nada.
    @State private var contraparte: Sabia.Contraparte?
    @State private var contrapondoDesde: Date?
    @State private var tarefaContrapor: Task<Void, Never>?
    @State private var avaliouContraparte = false
    /// O que a rota da sábia tem a DIZER: a frase da tabela quando ninguém
    /// responde, ou a falha quando quem responde não respondeu. Era um `Bool`
    /// que só sabia falar de conta — e com a conta ligada a rota calava
    /// (ADR 2026-09-09q).
    @State private var aviso: (op: Politica.Operacao, texto: String, estado: LinhaDeEstado.Estado)?
    @State private var apontados: [Apontamento] = []
    @State private var trechoNovo = ""
    @State private var recusado = false
    /// ADR 05x: a proveniência da forma, recolhida por padrão.
    @State private var deOndeVem = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Hermes §5: a densidade se controla no cabeçalho — e a seção recolhida
    /// fica recolhida na próxima nota também.
    var recolhidas = Recolhidas("lente")

    private var prosa: String { Caderno.prosa(de: texto) }
    /// O `NLTagger` e cinco regex sobre a nota inteira: pesado demais para o
    /// `body`, que é justamente o instante em que a folha sobe.
    @State private var lente = Lente.vazio

    var body: some View {
        let l = lente
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // o cabeçalho da casa: título nos tokens, Pronto como texto — a
                // cápsula cinza pesava mais que o título (von-restorff invertido)
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lente")
                            .font(Tema.tituloTela)
                            .tracking(Tema.trackingTitulo)
                            .foregroundStyle(Tema.tinta)
                            .accessibilityAddTraits(.isHeader)
                        // "nada a apontar" vive aqui, na linha de metadados: um
                        // parágrafo solto para dizer pouco era ruído
                        Text(resumo(l) + (l.vazia ? " · nada a apontar" : ""))
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .monospacedDigit()
                            .accessibilityIdentifier(l.vazia ? "lente-vazia" : "lente-resumo")
                    }
                    Spacer(minLength: 8)
                    Button("Pronto") { dismiss() }
                        .font(Tema.barra)
                        .foregroundStyle(Tema.tinta)
                        .alvo()
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityIdentifier("lente-pronto")
                }

                // ADR 05x: a forma desta nota e de onde ela vem. Informação,
                // nunca selo: fonte, função, o que o Traço adaptou, evidência.
                // ADR 10k: o cabeçalho era o NOME da forma em caixa alta —
                // caixa alta nomeando conteúdo. Agora a seção agrupa, e o
                // nome da forma é o título da linha.
                if let gesto {
                    secao("A forma desta nota", id: "forma") {
                        if let estado = gesto.estadoDoMetodo {
                            LinhaDeLista("exclamationmark.triangle", gesto.nome, estado, fio: false)
                                .accessibilityIdentifier("metodo-ausente")
                        } else {
                            Button {
                                withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                                    deOndeVem.toggle()
                                }
                            } label: {
                                LinhaDeLista(
                                    titulo: gesto.nome,
                                    subtitulo: "de onde vem: fonte, função, o que o Traço adaptou",
                                    fio: !deOndeVem,
                                    glifo: { Image(systemName: "book.closed") },
                                    acessorio: {
                                        Image(systemName: "chevron.down")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Tema.tintaFraca)
                                            .rotationEffect(.degrees(deOndeVem ? 180 : 0))
                                    })
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityIdentifier("de-onde-vem")
                            .accessibilityHint(deOndeVem ? "Recolhe" : "Fonte, função, o que o Traço adaptou e a evidência")
                            .accessibilityValue(deOndeVem ? "aberto" : "recolhido")
                            if deOndeVem {
                                LinhasDeProveniencia(gesto.metodoDef)
                                    .padding(.vertical, 10)
                                    .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
                            }
                        }
                    }
                }

                if !apontados.isEmpty {
                    secao("Apontados por você", id: "apontados", contagem: apontados.count,
                          nota: "um toque tira a marca") {
                        ForEach(apontados) { a in
                            Button {
                                if let notaUUID, Apontar.desmarcar(notaUUID, id: a.id) {
                                    apontados = Apontar.listar(notaUUID)
                                    Toque.leve()
                                }
                            } label: {
                                // o rótulo era cápsula em caixa alta; agora é o
                                // subtítulo, e o glifo diz o tipo pela forma
                                linha(a.trecho, nil, tipo: a.rotulo, rotulo: a.rotulo.nome)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityHint("Tira a marca")
                        }
                    }
                }

                if !l.vazia {
                    if !l.muletas.isEmpty {
                        // ADR 06h: "acho que", "um pouco" e "na verdade" são os
                        // hedges que o próprio catálogo ensina (a Inversão diz
                        // "costuma ser"). A contagem é verdade; a função, não.
                        secao("Palavras de apoio", id: "muletas", contagem: l.muletas.count,
                              nota: "contadas por palavra inteira") {
                            ForEach(l.muletas) { achado($0.termo, $0.vezes, sugerido: .muleta) }
                        }
                    }
                    if !l.frasesFeitas.isEmpty {
                        secao("Frases de outro", id: "frases", contagem: l.frasesFeitas.count,
                              nota: "quando aparecem, o pensamento parou um instante") {
                            ForEach(l.frasesFeitas, id: \.self) { achado($0, nil, sugerido: .fraseFeita) }
                        }
                    }
                    if !l.passivas.isEmpty {
                        secao("Passivas", id: "passivas", contagem: l.passivas.count,
                              nota: "quem faz ficou escondido") {
                            ForEach(l.passivas, id: \.self) { achado($0, nil, sugerido: .passiva) }
                        }
                    }
                    if !l.adverbios.isEmpty {
                        secao("Advérbios", id: "adverbios", contagem: l.adverbios.count,
                              nota: "o verbo devia bastar") {
                            ForEach(l.adverbios) { achado($0.termo, $0.vezes, sugerido: .vago) }
                        }
                    }
                    if !l.adjetivos.isEmpty {
                        secao("Adjetivos repetidos", id: "adjetivos", contagem: l.adjetivos.count,
                              nota: "um é escolha; três é hábito") {
                            ForEach(l.adjetivos) { achado($0.termo, $0.vezes, sugerido: .vago) }
                        }
                    }
                }

                // ADR o: instigar — a sábia devolve perguntas, nunca respostas
                if notaUUID != nil, gesto != .expressiva {
                    secao("Instigar", id: "instigar", contagem: perguntasDaSabia.isEmpty ? nil : perguntasDaSabia.count,
                          nota: "perguntas sobre o que falta — nunca respostas") {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(perguntasDaSabia, id: \.self) { q in
                                // a pergunta é o conteúdo: quebra, não corta
                                LinhaDeLista("questionmark.bubble", q, nil, linhasDoTitulo: nil)
                            }
                            if let aviso, aviso.op == .instigar {
                                LinhaDeEstado(aviso.texto, aviso.estado)
                                    .padding(.vertical, 10)
                                    .accessibilityIdentifier("lente-aviso-instigar")
                            }
                            // §13 item 3: era um `ProgressView` mudo — um laço
                            // igual no 1º e no 241º segundo. A espera diz o tempo
                            // e tem saída, como nas Notas e na Página.
                            if let desde = instigandoDesde {
                                Espera(frase: Espera.aSabiaPensa, desde: desde,
                                       identificador: "lente-instigar-pensando") {
                                    tarefaInstigar?.cancel()
                                    instigandoDesde = nil
                                }
                                .padding(.vertical, 6)
                            }
                            // ADR 10k: a ação se reconhece pelo chevron, e o
                            // título é tinta — o âmbar era a cor do cursor
                            Button {
                                instigar()
                            } label: {
                                LinhaDeLista(tocavel: "plus.bubble", perguntasDaSabia.isEmpty ? "Instigar" : "Mais perguntas",
                                             "vai à sábia; as perguntas ficam aqui", fio: false)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .disabled(instigandoDesde != nil)
                            .accessibilityIdentifier("instigar")
                        }
                    }
                }

                // ADR 04m: contrapor — a posição contrária, a opção fora da
                // lista, o exemplo de outro campo. Informação, nunca instrução.
                if notaUUID != nil, gesto != .expressiva {
                    secao("Contrapor", id: "contrapor",
                          nota: "o outro lado, a opção que faltou, o exemplo de outro campo") {
                        VStack(alignment: .leading, spacing: 0) {
                            if let c = contraparte {
                                // ADR 10k: "O OUTRO LADO" em caixa alta nomeava
                                // o parágrafo; é nome de conteúdo — frase normal
                                if !c.contra.isEmpty { paragrafo("O outro lado", c.contra) }
                                if !c.foraDaLista.isEmpty { paragrafo("Fora da lista", c.foraDaLista) }
                                if !c.outroCampo.isEmpty { paragrafo("Em outro campo", c.outroCampo) }
                                HStack(spacing: 14) {
                                    Button("Copiar") {
                                        UIPasteboard.general.string = [c.contra, c.foraDaLista, c.outroCampo].filter { !$0.isEmpty }.joined(separator: "\n\n")
                                        Toque.leve()
                                    }
                                    .font(Tema.barra)
                                    .foregroundStyle(Tema.tinta)
                                    .buttonStyle(PressaoDiscreta())
                                    .alvo()
                                    // §14: o retorno é um CONTROLE, o mesmo das
                                    // Notas e da Página, não dois links soltos
                                    if !avaliouContraparte {
                                        ControleDeRetorno { serviu in
                                            Sinais.resposta(c.contra, forma: gesto, serviu: serviu)
                                            avaliouContraparte = true
                                            Toque.leve()
                                        }
                                    }
                                }
                            }
                            if let aviso, aviso.op == .contrapor {
                                LinhaDeEstado(aviso.texto, aviso.estado)
                                    .padding(.vertical, 10)
                                    .accessibilityIdentifier("lente-aviso-contrapor")
                            }
                            if let desde = contrapondoDesde {
                                Espera(frase: Espera.aSabiaPensa, desde: desde,
                                       identificador: "lente-contrapor-pensando") {
                                    tarefaContrapor?.cancel()
                                    contrapondoDesde = nil
                                }
                                .padding(.vertical, 6)
                            }
                            Button {
                                contrapor()
                            } label: {
                                LinhaDeLista(tocavel: "arrow.left.arrow.right", contraparte == nil ? "Contrapor" : "Outro ângulo",
                                             "vai à sábia; a resposta fica aqui, nunca na nota", fio: false)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .disabled(contrapondoDesde != nil)
                            .accessibilityIdentifier("contrapor")
                            .accessibilityHint("Vai à sábia; a resposta fica aqui, nunca na nota")
                        }
                    }
                }

                if notaUUID != nil {
                    secao("Apontar um trecho", id: "apontar",
                          nota: "cole ou escreva um pedaço do seu texto e diga o que ele é") {
                        VStack(alignment: .leading, spacing: 0) {
                            // o campo é a única caixa da Lente: é onde se escreve,
                            // e o tipo sozinho não diz "escreva aqui"
                            TextField("um trecho do texto", text: $trechoNovo, axis: .vertical)
                                .font(.callout)
                                .lineLimit(1...3)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
                                .padding(.top, 4)
                                .accessibilityIdentifier("apontar-trecho")
                            HStack(spacing: 8) {
                                ForEach(RotuloApontar.allCases, id: \.self) { r in
                                    Button(r.nome) { marcar(trechoNovo, r) }
                                        .font(Tema.meta.weight(.medium))
                                        .foregroundStyle(trechoNovo.isEmpty ? Tema.tintaMorta : Tema.tintaSuave)
                                        .padding(.horizontal, 10)
                                        .frame(height: 30)
                                        .background(Tema.chip, in: Capsule())
                                        .disabled(trechoNovo.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                            }
                            .padding(.vertical, 10)
                            if recusado {
                                Text("esse trecho não está no seu texto.")
                                    .font(Tema.meta)
                                    .foregroundStyle(Tema.aviso)
                                    .padding(.bottom, 10)
                            }
                        }
                    }
                }
            }
            .padding(Tema.margem)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Tema.fundo.ignoresSafeArea())
        .foregroundStyle(Tema.tinta)
        // ADR 04a, de novo: `[.medium, .large]` nascia no médio com as
        // perguntas cortadas pela borda (report do dono, 04/set). A Lente é
        // leitura; abre inteira.
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
        .onAppear { if let notaUUID { apontados = Apontar.listar(notaUUID) } }
        .task { lente = Lente.ler(prosa) }
    }

    private func instigar() {
        if let frase = Politica.aviso(.instigar) { aviso = (.instigar, frase, .semConta); return }
        aviso = nil
        instigandoDesde = .now
        let t = prosa
        let g = gesto
        let r0 = retrato
        // ADR 04j: o degrau da instigação sobe com a prática nesta forma
        let degrau = g.map { Degraus.instigar($0, sinais: Sinais.todos()) } ?? 0
        tarefaInstigar?.cancel()
        tarefaInstigar = Task {
            let r = await Sabia.instigar(texto: t, gesto: g, degrau: degrau, retrato: r0)
            // quem parou de esperar não recebe o que chegar depois
            guard !Task.isCancelled else { return }
            instigandoDesde = nil
            // as TRÊS saídas ficam: a espera com tempo não pode engolir a
            // distinção entre "o modelo calou" e "nada passou na nossa guarda"
            switch r {
            case .some(let q) where !q.isEmpty: perguntasDaSabia = q; Toque.suave()
            case .some: aviso = (.instigar, Sabia.nadaPassouNaGuarda, .falhou); Toque.aviso()
            case .none: aviso = (.instigar, Grok.avisoDaFalha(), .falhou); Toque.aviso()
            }
        }
    }

    private func contrapor() {
        if let frase = Politica.aviso(.contrapor) { aviso = (.contrapor, frase, .semConta); return }
        aviso = nil
        contrapondoDesde = .now
        avaliouContraparte = false
        let t = prosa
        let g = gesto
        let r0 = retrato
        tarefaContrapor?.cancel()
        tarefaContrapor = Task {
            let r = await Sabia.contrapor(texto: t, gesto: g, retrato: r0)
            guard !Task.isCancelled else { return }
            contrapondoDesde = nil
            switch r {
            case .some(let c) where !c.vazia: contraparte = c; Toque.suave()
            case .some: aviso = (.contrapor, Sabia.nadaPassouNaGuarda, .falhou); Toque.aviso()
            case .none: aviso = (.contrapor, Grok.avisoDaFalha(), .falhou); Toque.aviso()
            }
        }
    }

    /// Um ângulo da contraparte: o nome do ângulo numa linha de peso, o
    /// texto inteiro embaixo, e o fio entre um e outro (Hermes §6: texto puro
    /// em largura inteira, sem balão, sem caixa alta no nome).
    private func paragrafo(_ nome: String, _ texto: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nome)
                .font(Tema.meta.weight(.semibold))
                .foregroundStyle(Tema.tintaSuave)
            Text(texto)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(Tema.linha).frame(height: 0.5) }
        .accessibilityIdentifier("contraparte")
    }

    private func marcar(_ trecho: String, _ rotulo: RotuloApontar) {
        guard let notaUUID else { return }
        if Apontar.marcar(notaUUID, trecho: trecho, rotulo: rotulo, noTexto: prosa) {
            apontados = Apontar.listar(notaUUID)
            trechoNovo = ""
            recusado = false
            Toque.suave()
        } else {
            recusado = true
            Toque.aviso()
        }
    }

    private func resumo(_ l: Lente) -> String {
        let p = l.palavras == 1 ? "1 palavra" : "\(l.palavras) palavras"
        let f = l.frases == 1 ? "1 frase" : "\(l.frases) frases"
        return "\(p) · \(f)"
    }

    /// Hermes §5: cabeçalho sussurrado com a contagem e o recolher; a nota
    /// de uma linha desce para baixo dele, e o conteúdo pousa no papel — a
    /// caixa cinza em volta de cada seção saiu (ADR 10k).
    private func secao<C: View>(_ titulo: String, id: String, contagem: Int? = nil, nota: String? = nil,
                                @ViewBuilder _ conteudo: () -> C) -> some View {
        // Laço de simplicidade (14/09): a nota de rodapé sob cada cabeçalho
        // era uma frase de explicação por seção — quatro na folha. O cabeçalho
        // nomeia e a linha diz o que faz; a explicação fica no código.
        recolhidas.secao(titulo, id: id, contagem: contagem) {
            conteudo()
        }
    }

    /// Um achado da lente. Com nota no disco, o toque abre os rótulos para
    /// apontar: é o autor quem decide o que aquilo é.
    @ViewBuilder
    private func achado(_ termo: String, _ vezes: Int?, sugerido: RotuloApontar) -> some View {
        if notaUUID != nil {
            Menu {
                ForEach(RotuloApontar.allCases, id: \.self) { r in
                    Button(r.nome) { marcar(termo, r) }
                }
            } label: {
                linha(termo, vezes, tipo: sugerido, rotulo: nil)
            }
            .accessibilityHint("Apontar este trecho com um rótulo")
        } else {
            linha(termo, vezes, tipo: sugerido, rotulo: nil)
        }
    }

    /// A linha da Lente é a linha do app (Hermes §4): o glifo diz o TIPO do
    /// achado pela forma — o mesmo glifo no achado e no apontado —, o termo é
    /// o título, o rótulo apontado é o subtítulo, e a contagem é o acessório.
    private func linha(_ termo: String, _ vezes: Int?, tipo: RotuloApontar, rotulo: String?) -> some View {
        LinhaDeLista(
            titulo: termo,
            subtitulo: rotulo,
            linhasDoTitulo: 2,
            glifo: { Image(systemName: Self.glifo(tipo)) },
            acessorio: {
                if let vezes {
                    Text("×\(vezes)")
                        .font(Tema.meta.monospacedDigit())
                        .foregroundStyle(Tema.tintaSuave)
                }
            })
    }

    static func glifo(_ tipo: RotuloApontar) -> String {
        switch tipo {
        case .fraseFeita: "text.quote"
        case .vago: "cloud"
        case .passiva: "eye.slash"
        case .muleta: "ellipsis.bubble"
        }
    }
}
