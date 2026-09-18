import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-04l: o catálogo é dado. Se o JSON do bundle quebrar, TODA nota
/// perde os campos — este é o teste que grita antes do autor.
@Suite(.serialized) struct CatalogoTests {
    @Test func oBundleTemOsQuarentaEUmMetodos() {
        let ids = Catalogo.doApp.map(\.id)
        #expect(ids.count == 41)
        for esperado in ["woop", "seEntao", "spec", "notaPermanente", "destaque", "expressiva", "destilar",
                         "palavra", "decisao", "premortem", "argumento", "leitura", "feynman", "dia",
                         "analogia", "steelman", "divergencia", "primeirosPrincipios",
                         "praticaDeliberada", "atualizacao"] {
            #expect(ids.contains(esperado), "falta \(esperado)")
        }
        // A Inversão saiu na colagem da leva 3: mesmo movimento do Pré-mortem,
        // que faz mais, e a regex dela foi HERDADA por ele — a deleção sem a
        // herança deixaria cinco frases de gatilho sem dono.
        #expect(!ids.contains("inversao"))
        // ADR 2026-09-06e: os métodos da trilha entram no FIM, e a POSIÇÃO é
        // comportamento — o roteador para no primeiro que casa. Os sete da leva 1
        // continuam antes dos catorze da leva 3.
        #expect(Array(ids.suffix(21).prefix(7)) == ["subtracao", "colunaEsquerda", "classeDeReferencia",
                                                   "cincoPorques", "perguntaHamming", "vistoNaoVisto",
                                                   "exameDaNoite"])
        #expect(Array(ids.suffix(14)) == ["fatoContrario", "ordemDeGrandeza", "comecariaHoje", "combinado",
                                          "pontoQueDecide", "oQueSeRepetiu", "regraQueEuFaco", "reparacao",
                                          "verAntesDeNomear", "oQueNaoEsta", "estaBom", "porta",
                                          "transferencia", "sobrevivente"])
    }

    @Test func osDezDeOrigemMantemOsCampos() {
        #expect(Gesto.woop.campos.map(\.id) == ["resultado", "obstaculo", "plano"])
        #expect(Gesto.decisao.campos.map(\.id) == ["escolha", "opcoes", "criterio", "decidido", "espero", "aconteceu", "saldo"])
        #expect(Gesto.decisao.campos.last?.soDepois == true)
        #expect(Gesto.destilar.campos.first?.teto == 200)
        #expect(Gesto.spec.nome == "Especificação")
        #expect(Gesto.expressiva.campos.isEmpty)
        #expect(Gesto.expressiva.metodo.isEmpty) // selo: a sábia não entra
    }

    @Test func todoMetodoNovoTemMovimentoEPergunta() {
        for m in Catalogo.doApp where m.id != "expressiva" {
            #expect(!m.movimento.isEmpty, Comment(rawValue: m.id))
            #expect(!m.pergunta.isEmpty, Comment(rawValue: m.id))
            #expect(!m.reconhecimento.isEmpty, Comment(rawValue: m.id))
            #expect(!m.campos.isEmpty, Comment(rawValue: m.id))
        }
    }

    @Test func idDesconhecidoNaoPerdeOGesto() {
        let g = Gesto(rawValue: "metodoQueSumiu")
        #expect(g != nil)
        #expect(g?.conhecido == false)
        #expect(g?.nome == "metodoQueSumiu")
        #expect(g?.campos.isEmpty == true)
        #expect(Gesto(rawValue: "  ") == nil)
    }

    /// ADR 05o: o método do autor sai da pasta e a nota não vira prosa — o
    /// corpus volta com o mesmo gesto e com os campos que ele respondeu.
    @MainActor @Test func oCorpusVoltaComOMetodoQueSumiuDaPasta() throws {
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent("metodos-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: pasta)
            Catalogo.pastaDoAutor = pasta.deletingLastPathComponent().appendingPathComponent("nada")
            Catalogo.recarregar()
        }
        let arquivo = pasta.appendingPathComponent("cornell.json")
        try #"{"id":"cornell","nome":"Cornell","campos":[{"id":"pistas","rotulo":"Pistas"},{"id":"resumo","rotulo":"Resumo"}]}"#
            .write(to: arquivo, atomically: true, encoding: .utf8)
        Catalogo.pastaDoAutor = pasta
        Catalogo.recarregar()
        let gesto = try #require(Gesto(rawValue: "cornell"))
        #expect(gesto.nome == "Cornell")
        let campos = ["pistas": "a atenção é finita", "resumo": "o que fica da aula"]
        let md = Corpus.arquivoMd(texto: "a aula de hoje", gesto: gesto, campos: campos,
                                  criadaEm: Date(timeIntervalSince1970: 0))

        try FileManager.default.removeItem(at: arquivo)
        Catalogo.recarregar()
        #expect(Catalogo.metodo("cornell") == nil)

        let item = try #require(Corpus.importar(md).first)
        let devolvido = try #require(item.gestoNome.flatMap(Gesto.doNome))
        #expect(devolvido == gesto)
        #expect(devolvido.conhecido == false)
        let restaurada = Corpus.separarCampos(texto: item.texto, gesto: devolvido)
        #expect(restaurada.texto == "a aula de hoje")
        #expect(restaurada.campos == campos)
    }

    /// ADR 05o: a fronteira do import. Um .md alheio com `gesto:` em prosa não
    /// planta um id — a nota entra sem gesto, como antes do catálogo.
    @Test func textoLivreNoGestoNaoViraId() throws {
        let frase = String(repeating: "uma frase inteira ", count: 25)
        let md = """
            ---
            criada: 1970-01-01T00:00:00Z
            gesto: \(frase)
            ---

            a nota de fora
            """
        let item = try #require(Corpus.importar(md).first)
        #expect(item.gestoNome == nil)
        #expect(Gesto.doNome(frase) == nil)
        #expect(Gesto.doNome("metodoQueSumiu")?.conhecido == false) // id curto ainda entra
    }

    /// ADR 05o: quando os dois vêm, o id manda — o nome é exibição e pode ter
    /// sido reaproveitado por outro método.
    @Test func oMetodoPrevaleceSobreONome() throws {
        let md = """
            ---
            criada: 1970-01-01T00:00:00Z
            gesto: WOOP
            metodo: cornellDoAutor
            ---

            a aula de hoje
            """
        let item = try #require(Corpus.importar(md).first)
        #expect(item.gestoNome == "cornellDoAutor")
        #expect(item.gestoNome.flatMap(Gesto.doNome)?.rawValue == "cornellDoAutor")
    }

    @Test func oCatalogoRoteiaOsMetodosNovos() {
        func v(_ t: String) -> AnaliseLocal.Veredito { AnaliseLocal.classificar(texto: t, gestoAtual: nil, campos: [:]) }
        #expect(v("defendo que a tese central está errada") == .gesto(Gesto(rawValue: "argumento")!, pergunta: Catalogo.metodo("argumento")!.pergunta))
        #expect(v("terminei de ler o livro sobre atenção") == .gesto(Gesto(rawValue: "leitura")!, pergunta: Catalogo.metodo("leitura")!.pergunta))
        #expect(v("preciso planejar o dia com calma") == .gesto(.dia, pergunta: Catalogo.metodo("dia")!.pergunta))
        #expect(v("quero começar a correr") == .gesto(.woop, pergunta: AnaliseLocal.perguntaWOOP)) // a ordem de origem fica
    }

    @Test func pdfAnexadoComProsaViraLeitura() {
        let texto = "as ideias do capítulo dois sobre atenção\n\n[arquivo:guia.pdf](traco://file/00000000-0000-4000-8000-000000000001)\n"
        let v = AnaliseLocal.classificar(texto: texto, gestoAtual: nil, campos: [:])
        #expect(v == .gesto(Gesto(rawValue: "leitura")!, pergunta: Catalogo.metodo("leitura")!.pergunta))
        // só o arquivo, sem uma palavra do autor, não é nota (a prosa é vazia): silêncio
        #expect(AnaliseLocal.classificar(texto: "[arquivo:guia.pdf](traco://file/00000000-0000-4000-8000-000000000001)", gestoAtual: nil, campos: [:]) == .silencio)
    }

    @Test func oEncadeamentoEDado() {
        let e = Gesto.woop.encadeamentos
        #expect(e.count == 1)
        #expect(e.first?.para == "seEntao")
        #expect(e.first?.mapa == ["se": "obstaculo", "entao": "plano"])
        #expect(Gesto.premortem.encadeamentos.contains { $0.compromisso?.dias == 14 })
    }

    /// ADR 04z: nenhum método é ilha, e todo encadeamento aponta para forma
    /// e campos que existem — dos dois lados.
    @Test func nenhumMetodoEIlhaEOMapaFecha() {
        let ilhas: Set<String> = ["notaPermanente", "destaque", "expressiva", "destilar", "palavra", "seEntao", "dia"]
        for m in Catalogo.doApp {
            if !ilhas.contains(m.id) {
                #expect(!m.encadeamentos.isEmpty, "\(m.id) é ilha")
            }
            let origem = Set(m.campos.map(\.id))
            for e in m.encadeamentos {
                #expect(Set(e.exige).isSubset(of: origem), "\(m.id): exige campo que não tem")
                if let para = e.para {
                    let destino = Catalogo.metodo(para)
                    #expect(destino != nil, "\(m.id) → \(para) não existe")
                    let campos = Set(destino?.campos.map(\.id) ?? [])
                    #expect(Set(e.mapa.keys).isSubset(of: campos), "\(m.id) → \(para): campo de destino inexistente")
                    #expect(Set(e.mapa.values).isSubset(of: origem), "\(m.id) → \(para): campo de origem inexistente")
                }
                if let c = e.compromisso {
                    #expect(origem.contains(c.campo) && c.dias > 0, "\(m.id): compromisso sem campo")
                }
            }
        }
        #expect(Catalogo.metodo("porta")?.encadeamentos.first?.para == "decisao")
    }

    /// ADR 05x: todo método do app diz de onde vem, com função válida (prática, lente
    /// ou evidência) e sem campo vazio — "sem evidência específica conhecida"
    /// é resposta; silêncio não é.
    @Test func todoMetodoDoAppTemProveniencia() throws {
        for m in Catalogo.doApp {
            let p = try #require(m.proveniencia, Comment(rawValue: m.id))
            #expect(p.funcao != nil, Comment(rawValue: m.id))
            #expect(!p.fonte.isEmpty && !p.adaptacao.isEmpty && !p.evidencia.isEmpty && !p.aplicabilidade.isEmpty, Comment(rawValue: m.id))
            #expect(p.linhas.count == 5, Comment(rawValue: m.id))
        }
        #expect(Set(Catalogo.doApp.compactMap { $0.proveniencia?.funcao }).count == 3)
    }

    /// ADR 05x: a proveniência é aditiva — JSON antigo decodifica sem ela,
    /// função desconhecida vira "não informada" sem derrubar o método, e o
    /// que entra volta igual.
    @Test func aProvenienciaEOpcionalNoArquivo() throws {
        let sem = try JSONDecoder().decode(Metodo.self, from: Data(#"{"id":"x","nome":"X","campos":[]}"#.utf8))
        #expect(sem.proveniencia == nil)
        let com = try JSONDecoder().decode(Metodo.self, from: Data(#"""
            {"id":"x","nome":"X","campos":[],"proveniencia":{"fonte":"Alguém, 2001","funcao":"lente","evidencia":"sem evidência específica conhecida"}}
            """#.utf8))
        let p = try #require(com.proveniencia)
        #expect(p.funcao == .lente)
        #expect(p.funcaoEmPalavras == "lente")
        #expect(p.linhas.map(\.rotulo) == ["FONTE", "FUNÇÃO", "EVIDÊNCIA"])
        let invalida = try JSONDecoder().decode(Metodo.self, from: Data(#"""
            {"id":"x","nome":"X","campos":[],"proveniencia":{"fonte":"Alguém","funcao":"milagre"}}
            """#.utf8))
        #expect(invalida.proveniencia?.funcao == nil)
        #expect(invalida.proveniencia?.funcaoEmPalavras == "não informada")
        #expect(invalida.proveniencia?.linhas.map(\.rotulo) == ["FONTE"])
        let volta = try JSONDecoder().decode(Metodo.self, from: JSONEncoder().encode(com))
        #expect(volta.proveniencia == p)
    }

    /// ADR 05x: método do autor sem o campo entra e a tela diz "não
    /// informada"; com o campo, é a dele.
    @Test func oMetodoDoAutorEntraComOuSemProveniencia() throws {
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent("metodos-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: pasta); Catalogo.pastaDoAutor = pasta.deletingLastPathComponent().appendingPathComponent("nada"); Catalogo.recarregar() }
        try #"{"id":"cornell","nome":"Cornell","campos":[{"id":"pistas","rotulo":"Pistas"}]}"#
            .write(to: pasta.appendingPathComponent("cornell.json"), atomically: true, encoding: .utf8)
        try #"{"id":"pomodoro","nome":"Pomodoro","campos":[{"id":"tarefa","rotulo":"Tarefa"}],"proveniencia":{"fonte":"Francesco Cirillo, anos 1980","funcao":"pratica"}}"#
            .write(to: pasta.appendingPathComponent("pomodoro.json"), atomically: true, encoding: .utf8)
        Catalogo.pastaDoAutor = pasta
        Catalogo.recarregar()
        #expect(Catalogo.doAutor.map(\.id) == ["cornell", "pomodoro"])
        #expect(Catalogo.metodo("cornell")?.proveniencia == nil)
        #expect(Catalogo.metodo("pomodoro")?.proveniencia?.fonte == "Francesco Cirillo, anos 1980")
        #expect(Catalogo.metodo("pomodoro")?.doAutor == true)
    }

    /// ADR 05x: o método que saiu da pasta é DITO, não escondido — e o do
    /// catálogo não diz nada.
    @Test func oMetodoAusenteTemEstadoParaATela() throws {
        let sumiu = try #require(Gesto(rawValue: "metodoQueSumiu"))
        #expect(sumiu.estadoDoMetodo == "o método “metodoQueSumiu” não está mais no catálogo; os campos continuam na nota.")
        #expect(sumiu.campos.isEmpty)
        #expect(Gesto.woop.estadoDoMetodo == nil)
        #expect(Gesto.woop.metodoDef.proveniencia?.funcao == .evidencia)
    }

    /// ADR 2026-09-06e: "sempre que" sem `\b` casava DENTRO de "sempre quebra",
    /// "sempre queria", "sempre quero" — e o Se–então roubava a frase de quem
    /// ela era. Estas três casavam errado antes do `\b`; agora não casam.
    @Test func oSeEntaoNaoCasaDentroDeOutraPalavra() {
        func id(_ t: String) -> String? {
            if case let .gesto(g, _) = AnaliseLocal.classificar(texto: t, gestoAtual: nil, campos: [:]) { return g.rawValue }
            return nil
        }
        #expect(id("sempre quebra no mesmo ponto, qual é a causa") == "cincoPorques")
        #expect(id("sempre queria ter dito o que pensei") == "colunaEsquerda")
        // e o Se–então continua pegando o que sempre foi dele
        #expect(id("sempre que abro o telefone na cama eu perco uma hora") == "seEntao")
        #expect(id("toda vez que sento para escrever eu abro o navegador") == "seEntao")
        #expect(id("não consigo parar de conferir o e-mail no meio da escrita") == "seEntao")
    }

    /// ADR 2026-09-06e: os sete novos roteiam para si mesmos com a frase do autor.
    ///
    /// As duas frases do Exame da noite desta volta eram "perdi a paciência na
    /// reunião e me arrependi" e "fui injusto com o time hoje de manhã", e as
    /// duas MORRERAM na colagem com main: a guarda da ADR 2026-09-06h as lê
    /// como escrita pessoal e as cala, que é o que ela existe para fazer — as
    /// duas são confissão de conduta, indistinguíveis das 22 do revisor. O
    /// teste estava errado, não a guarda: pedia que uma confissão virasse
    /// exercício. As três frases abaixo convocam o método sem confessar nada.
    @Test func osSeteNovosRoteiamParaSiMesmos() {
        func id(_ t: String) -> String? {
            if case let .gesto(g, _) = AnaliseLocal.classificar(texto: t, gestoAtual: nil, campos: [:]) { return g.rawValue }
            return nil
        }
        let casos: [(String, String)] = [
            ("subtracao", "preciso simplificar o fecho da volta, virou um monstro"),
            ("subtracao", "o roteiro está complicado demais, o que eu tiro dele"),
            ("colunaEsquerda", "fiquei calado e devia ter falado sobre o prazo"),
            ("colunaEsquerda", "não disse o que pensei na conversa de ontem"),
            ("classeDeReferencia", "quanto tempo vai levar para eu terminar isso"),
            ("classeDeReferencia", "acho que termino em três dias, mas nunca acerto"),
            ("cincoPorques", "por que isso aconteceu, quero a causa raiz"),
            ("cincoPorques", "o build quebrou de novo, qual foi a causa"),
            ("perguntaHamming", "quais são os problemas importantes do meu campo"),
            ("perguntaHamming", "no que eu deveria estar trabalhando este ano"),
            ("vistoNaoVisto", "qual é o custo de oportunidade de tocar esta frente agora"),
            ("vistoNaoVisto", "em troca de quê eu estou fazendo isso"),
            ("exameDaNoite", "exame da noite: o que eu não quero repetir amanhã"),
            ("exameDaNoite", "passei o dia em revista antes de deitar"),
            ("exameDaNoite", "passei o dia em revista e anotei o que muda amanhã"),
        ]
        for (esperado, frase) in casos {
            #expect(id(frase) == esperado, Comment(rawValue: "«\(frase)» foi para \(id(frase) ?? "nada")"))
        }
        // e nenhum deles rouba os 20 antigos
        #expect(id("vou construir uma função para simplificar o cadastro") == "spec")
        #expect(id("hoje eu preciso fechar a volta e responder o dono") == "dia")
        #expect(id("preciso decidir entre ficar no emprego e abrir a empresa") == "decisao")
        // a regex herdada da Inversão agora mora no Pré-mortem
        #expect(id("como garantir que falhe: eu deixaria o método sem origem") == "premortem")
        #expect(id("quais são as suposições que eu herdei sobre notas") == "primeirosPrincipios")
    }

    /// O CASO FÁCIL da proteção, e só ele: desabafo LONGO e carregado de
    /// vocabulário da Expressiva (`senti`, `raiva`, `doeu`, `chorei`). Aqui a
    /// ordem do arquivo basta — a Coluna da esquerda casa por `fiquei calad[oa]`
    /// e `na reunião com`, o Exame da noite por `me arrependi`, e os dois
    /// perdem porque a Expressiva vem antes. Se alguém mover um dos sete para
    /// cima dela, este teste cai.
    ///
    /// A proteção NÃO é só a ordem: é a ordem MAIS o teto de 120 caracteres em
    /// `AnaliseLocal.detectarGesto`, que pula a Expressiva em texto curto. O
    /// caso difícil — linha curta e desabafo factual — está em
    /// `aEscritaPessoalNaoChegaVestidaDeMetodo`, que FALHAVA de propósito
    /// nesta volta e passou a VERDE na colagem com main, quando a guarda das
    /// voltas A1–A5 (ADRs 2026-09-06h e 06i) entrou.
    @Test func oDesabafoLongoContinuaExpressivo() {
        let desabafo = """
            na reunião com o chefe eu senti uma raiva enorme, doeu ficar ali, fiquei calado o tempo todo \
            e chorei depois no corredor, foi pesado demais para mim
            """
        #expect(desabafo.count > 120)
        #expect(AnaliseLocal.classificar(texto: desabafo, gestoAtual: nil, campos: [:]) == .expressiva)

        let arrependido = """
            perdi a paciência com o time hoje e me arrependi na hora, senti uma raiva que não passou o dia \
            inteiro, doeu ver a cara deles e chorei sozinho depois
            """
        #expect(AnaliseLocal.classificar(texto: arrependido, gestoAtual: nil, campos: [:]) == .expressiva)

        // a posição no arquivo é o que segura: os sete estão DEPOIS da Expressiva
        let ids = Catalogo.doApp.map(\.id)
        let expressiva = ids.firstIndex(of: "expressiva") ?? .max
        for novo in ["subtracao", "colunaEsquerda", "classeDeReferencia", "cincoPorques",
                     "perguntaHamming", "vistoNaoVisto", "exameDaNoite"] {
            #expect((ids.firstIndex(of: novo) ?? -1) > expressiva, Comment(rawValue: "\(novo) subiu acima da Expressiva"))
        }
    }

    /// O CASO DIFÍCIL da proteção da escrita pessoal. Escrito VERMELHO nesta
    /// volta, ele passou a VERDE na colagem com main: as 22 do revisor são
    /// caladas pela guarda das voltas A1–A5 (ADRs 2026-09-06h e 06i), sem uma
    /// linha de `Traco/Analise` tocada aqui. Nenhuma das 22 sobrou.
    ///
    /// As 22 frases são do revisor do G3 (`ferramentas/orca/m3-rev-provas/`),
    /// não do autor desta volta: 14 linhas curtas com palavra de sentimento e
    /// 8 desabafos longos e factuais, sem nenhuma das dez palavras da
    /// Expressiva. Nenhuma delas é material de exercício. Quando uma chega
    /// como `.gesto`, `Sessao` veste a nota sozinha (`usarForma(g,
    /// explicita: false)`, `cartao = .vestida`) e carimba 4–5 campos de método
    /// sobre o texto de quem acabou de escrever que chorou — reproduzido na
    /// tela em `m3-rev-02` e `m3-rev-03`. A Expressiva, quando ganha, só
    /// SUGERE. Os dois caminhos não são simétricos, e o que rouba é o que veste.
    ///
    /// Por que falhava, e o que cada metade cobrava — a medição do G3, mantida
    /// porque é ela que explica de onde a guarda veio:
    /// - as 14 curtas caem no teto de 120 de `AnaliseLocal.detectarGesto`, que
    ///   pula a Expressiva e promove `colunaEsquerda` e `exameDaNoite` a
    ///   primeiro-a-casar. É conserto de `Traco/Analise`, fora desta volta.
    /// - os 8 longos passam do teto e mesmo assim são roubados: o léxico de dez
    ///   palavras da Expressiva não cobre o desabafo factual, e as palavras que
    ///   o cobririam (`engoli`, `fiquei calado`, `me arrependi`, `perdi a
    ///   paciência`) são as regex dos dois métodos novos. Alargar a Expressiva
    ///   por dado deixaria os dois inalcançáveis — medido, não suposto.
    ///   Esta metade cobrava guarda em código, não regex — e foi guarda em
    ///   código que chegou.
    @Test func aEscritaPessoalNaoChegaVestidaDeMetodo() {
        let curtas = [
            "Senti raiva e me arrependi na hora.",
            "Chorei e me arrependi de ter dito aquilo.",
            "Doeu. Perdi a paciência com ela.",
            "Fiquei calado e senti medo de falar.",
            "Triste. Engoli tudo de novo.",
            "Me arrependi.",
            "Fui grosso com ele e sinto vergonha.",
            "Hoje eu reagi mal, tive raiva, e pronto.",
            "Não devia ter feito isso, senti muito.",
            "Estou triste porque não consegui dizer nada.",
            "Perdi a cabeça. Sinto muito.",
            "Deixei passar e doeu.",
            "Foi pesado e eu fiquei calada.",
            "Me arrependi e chorei.",
        ]
        let longas = [
            "Foi um dia longo e eu fiquei calado a reunião inteira enquanto ele levava o crédito pelo que eu fiz. Saí de lá com um nó na garganta e não falei com ninguém.",
            "Engoli o que eu queria dizer. De novo. É sempre assim, eu penso a resposta perfeita três horas depois quando já não serve pra nada e só sobra o gosto ruim.",
            "Me arrependi. Deitei e fiquei olhando o teto pensando em tudo que eu não devia ter feito hoje, e quanto mais eu penso pior fica, não consigo desligar isso.",
            "Perdi a paciência de novo com a minha mãe no telefone. Ela não fez nada demais, eu que já estava no limite desde de manhã e joguei tudo em cima dela.",
            "Não devia ter reagido assim na frente do meu filho. Ele só perguntou uma coisa boba e eu explodi. Fico revendo a cara dele e me odiando um pouco por isso.",
            "Deixei passar mais uma vez. Ele falou aquilo na frente de todo mundo e eu ri junto como um idiota. Depois passei o resto do dia remoendo o que eu devia ter dito.",
            "Hoje eu tratei mal quem não merecia e agora estou aqui às onze da noite escrevendo isso pra não ligar pra ela e piorar tudo com uma desculpa mal feita.",
            "Fui injusto com o time inteiro na retrospectiva. Falei que o problema era falta de cuidado quando o problema era o prazo que eu mesmo aceitei sem discutir.",
        ]
        for frase in curtas + longas {
            let v = AnaliseLocal.classificar(texto: frase, gestoAtual: nil, campos: [:])
            if case let .gesto(g, _) = v {
                Issue.record(Comment(rawValue: "escrita pessoal vestida de \(g.nome) [\(frase.count)]: «\(frase)»"))
            }
        }
        // as 8 longas passam do teto de 120: se uma delas encolher, o teste
        // deixa de medir o que diz medir
        for frase in longas { #expect(frase.count > 120, Comment(rawValue: frase)) }
    }

    /// ALCANCE: nenhum ramo de regex nasce inalcançável sem alguém saber.
    ///
    /// Gera uma frase por ramo de cada regex de `Catalogo.todos` (alternância
    /// vira ramo, classe vira a primeira letra, opcional some, `\w+` e `\d`
    /// viram palavra e dígito) e cobra que ela chegue no método que a declara.
    /// Cada sonda leva um rabo de pontos: passa o teto de 120 sem casar regex
    /// nenhuma, então o resultado não depende de qual lado do teto está o
    /// conserto da Expressiva.
    ///
    /// DEZESSETE desvios conhecidos e aceitos, de DUAS naturezas — o número foi
    /// remedido na colagem com main, não herdado da ADR 2026-09-06h, e a volta
    /// P1 tirou o décimo oitavo apagando o ramo morto que o causava.
    ///
    /// Os TRÊS primeiros são regex larga e cedo comendo regex específica e
    /// tarde, e tocam DOIS métodos (`steelman` e `divergencia`) — nenhum dos
    /// dois fica sem porta: os dois têm ramos vivos.
    ///
    /// Os QUATORZE seguintes são a GUARDA da escrita pessoal (ADR 2026-09-06h,
    /// estreitada pela 06i e pelas 06i-B/C/D) chegando antes do roteamento e
    /// calando a sonda: 3 ramos da Coluna da esquerda e 11 do Exame da noite.
    /// Não é regex morta — é regex que o app se recusa a usar, de propósito,
    /// porque a frase é confissão de conduta e a nota fica do autor. Medido
    /// com `conhecidos` vazio depois da colagem, ANTES da volta P1: eram 18
    /// desvios — 4 antigos ainda vivos (nenhuma entrada morta) e 14 novos, o
    /// mesmo número que a 06h previu; o estreitamento da A5 e das A-5-B/C/D não
    /// mudou a conta. A P1 apagou o ramo morto e um dos 4 antigos saiu com ele.
    ///
    /// O que a conta COBRA, e está aqui para ninguém descobrir sozinho: o
    /// SEGUNDO ramo do Exame da noite (`não devia ter …`, `me arrependi`,
    /// `fui injusto|grosso|duro demais|ríspido`) está INTEIRO fechado — 9 de 9
    /// sondas caladas. Dos 16 ramos do método (eram 17 até a volta P1), 11 estão
    /// calados pela guarda e 5 chegam: `exame da noite`, `passei o dia em
    /// revista` e `hoje eu (fiz|reagi|tratei)`. É a proteção funcionando, e é o
    /// preço dela.
    ///
    /// Desvio NOVO, fora destes 17, derruba o teste.
    @Test func todoRamoDeRegexAlcancaOSeuMetodo() {
        let conhecidos: Set<String> = [
            // regex larga comendo regex específica (pré-existentes)
            "steelman|melhor argumento contra|argumento",
            "divergencia|dez ideias|notaPermanente",
            "divergencia|todas as ideias|notaPermanente",
            // `exameDaNoite|olhando o dia de hoje|dia` saiu na volta P1: o ramo
            // era morto por sombreamento (`Meu dia` tem `\bo dia de hoje\b` e
            // vem antes no catálogo), e foi apagado do `Metodos.json`.
            // a guarda da escrita pessoal cala a sonda — Coluna da esquerda (3)
            "colunaEsquerda|engoli|silencio",          // ADR 2026-09-06h
            "colunaEsquerda|fiquei calado|silencio",   // ADR 2026-09-06h
            "colunaEsquerda|deixei passar|silencio",   // ADR 2026-09-06h
            // a guarda da escrita pessoal cala a sonda — Exame da noite (11)
            "exameDaNoite|não devia ter feito|silencio",    // ADR 2026-09-06h
            "exameDaNoite|não devia ter reagido|silencio",  // ADR 2026-09-06h
            "exameDaNoite|não devia ter agido|silencio",    // ADR 2026-09-06h
            "exameDaNoite|não devia ter tratado|silencio",  // ADR 2026-09-06h
            "exameDaNoite|me arrependi|silencio",           // ADR 2026-09-06h
            "exameDaNoite|fui injusto|silencio",            // ADR 2026-09-06h
            "exameDaNoite|fui grosso|silencio",             // ADR 2026-09-06h
            "exameDaNoite|fui duro demais|silencio",        // ADR 2026-09-06h
            "exameDaNoite|fui ríspido|silencio",            // ADR 2026-09-06h
            "exameDaNoite|perdi a paciência|silencio",      // ADR 2026-09-06h
            "exameDaNoite|perdi a cabeça|silencio",         // ADR 2026-09-06h
            // A leva 3, e os quatro são custo DECLARADO, não descuido.
            // "ideia" da Nota permanente comendo regex específica é o desvio
            // herdado II.1, medido antes desta colagem e com volta própria:
            "fatoContrario|derruba a minha ideia|notaPermanente",
            "fatoContrario|derruba minha ideia|notaPermanente",
            // a guarda da escrita pessoal cala a sonda — os dois únicos gatilhos
            // dos catorze que caem nela (`mago[aeiou]` e `arrepend`, os dois em
            // `lexicoDoSentimento`). Os outros dez da Reparação e os outros oito
            // da Porta chegam, e é por isso que os dois métodos ficam:
            "reparacao|magoei|silencio",                    // ADR 2026-09-06h
            "porta|se eu me arrepender|silencio",           // ADR 2026-09-06h
        ]
        let rabo = " " + String(repeating: ".", count: 140)
        var total = 0
        for m in Catalogo.todos {
            for regex in m.roteamento {
                for sonda in Sondas.deRegex(regex) {
                    total += 1
                    var chegou = "silencio"
                    switch AnaliseLocal.classificar(texto: sonda + rabo, gestoAtual: nil, campos: [:]) {
                    case let .gesto(g, _): chegou = g.rawValue
                    case .expressiva: chegou = "expressiva"
                    default: break
                    }
                    guard chegou != m.id else { continue }
                    let chave = "\(m.id)|\(sonda)|\(chegou)"
                    #expect(conhecidos.contains(chave),
                            Comment(rawValue: "ramo inalcançável: \(m.id) «\(sonda)» chega em \(chegou)"))
                }
            }
        }
        #expect(total > 250, Comment(rawValue: "só \(total) sondas — o expansor parou de expandir"))
    }

    /// `Sessao.encadear` sai em silêncio quando o destino não está no catálogo,
    /// mas a view desenha o botão do mesmo jeito: destino inexistente = botão
    /// que acende e não faz nada. Guarda de dado — a correção da view é outra
    /// volta.
    @Test func nenhumEncadeamentoApontaParaMetodoInexistente() {
        for m in Catalogo.todos {
            for e in m.encadeamentos {
                guard let para = e.para else { continue }
                #expect(Catalogo.metodo(para) != nil, Comment(rawValue: "\(m.id) → \(para): botão morto"))
            }
        }
    }

    @Test func aPastaDoAutorEntraEOInvalidoEDito() throws {
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent("metodos-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: pasta); Catalogo.pastaDoAutor = pasta.deletingLastPathComponent().appendingPathComponent("nada"); Catalogo.recarregar() }
        try #"{"id":"cornell","nome":"Cornell","campos":[{"id":"pistas","rotulo":"Pistas"},{"id":"resumo","rotulo":"Resumo, nas minhas palavras"}],"roteamento":["\\bcornell\\b"]}"#
            .write(to: pasta.appendingPathComponent("cornell.json"), atomically: true, encoding: .utf8)
        try #"{"id":"woop","nome":"Roubo"}"#.write(to: pasta.appendingPathComponent("roubo.json"), atomically: true, encoding: .utf8)
        try "isto não é json".write(to: pasta.appendingPathComponent("quebrado.json"), atomically: true, encoding: .utf8)
        Catalogo.pastaDoAutor = pasta
        Catalogo.recarregar()
        #expect(Catalogo.doAutor.map(\.id) == ["cornell"])
        #expect(Gesto(rawValue: "cornell")?.campos.count == 2)
        #expect(Gesto.woop.nome == "WOOP") // o do app não é sobrescrito
        #expect(Catalogo.problemas.count == 2)
        let v = AnaliseLocal.classificar(texto: "anotar em cornell a aula de hoje", gestoAtual: nil, campos: [:])
        #expect(v == .gesto(Gesto(rawValue: "cornell")!, pergunta: ""))
    }
}

/// Expansor de ramos de regex: a máquina do teste de alcance. Cobre só o que o
/// `roteamento` do catálogo usa — alternância, grupo, classe, opcional, `\w`,
/// `\d`, `.*`, `\b` e `^`. Não é um motor de regex; é o inverso barato dele.
enum Sondas {
    /// Uma frase por ramo do padrão inteiro.
    static func deRegex(_ padrao: String) -> [String] {
        fatiar(Array(padrao)).flatMap { frases($0) }
    }

    /// Corta no `|` de nível zero — fora de grupo e fora de classe.
    private static func fatiar(_ s: [Character]) -> [[Character]] {
        var partes: [[Character]] = [[]], nivel = 0, classe = false
        for c in s {
            if classe {
                partes[partes.count - 1].append(c)
                if c == "]" { classe = false }
                continue
            }
            switch c {
            case "[": classe = true; partes[partes.count - 1].append(c)
            case "(": nivel += 1; partes[partes.count - 1].append(c)
            case ")": nivel -= 1; partes[partes.count - 1].append(c)
            case "|" where nivel == 0: partes.append([])
            default: partes[partes.count - 1].append(c)
            }
        }
        return partes
    }

    private static func frases(_ ramo: [Character]) -> [String] {
        var saidas = [""]
        func juntar(_ pedacos: [String]) { saidas = saidas.flatMap { a in pedacos.map { a + $0 } } }
        var i = 0
        while i < ramo.count {
            let c = ramo[i]
            if c == "\\", i + 1 < ramo.count {
                let n = ramo[i + 1]
                i += 2
                switch n {
                case "b": continue
                case "d":
                    if i < ramo.count, ramo[i] == "{" { while i < ramo.count, ramo[i] != "}" { i += 1 }; i += 1 }
                    juntar(["7"])
                case "w":
                    if i < ramo.count, ramo[i] == "+" || ramo[i] == "*" { i += 1 }
                    juntar(["coisa"])
                case "s": juntar([" "])
                default: juntar([String(n)])
                }
                continue
            }
            switch c {
            case "^", "$":
                i += 1
            case ".":
                i += 1
                if i < ramo.count, ramo[i] == "*" || ramo[i] == "+" { i += 1 }
                juntar([" isso "])
            case "(":
                var nivel = 1, j = i + 1, dentro: [Character] = []
                while j < ramo.count, nivel > 0 {
                    if ramo[j] == "(" { nivel += 1 }
                    if ramo[j] == ")" { nivel -= 1 }
                    if nivel > 0 { dentro.append(ramo[j]) }
                    j += 1
                }
                i = j
                let opcional = i < ramo.count && (ramo[i] == "?" || ramo[i] == "*")
                if opcional { i += 1 }
                if dentro.first == "?" { continue } // (?m), (?i): não é grupo
                if opcional { continue }            // ramo sem o opcional
                juntar(fatiar(dentro).flatMap { frases($0) })
            case "[":
                var j = i + 1, dentro: [Character] = []
                while j < ramo.count, ramo[j] != "]" { dentro.append(ramo[j]); j += 1 }
                i = j + 1
                if i < ramo.count, ramo[i] == "?" || ramo[i] == "*" { i += 1; continue }
                juntar([String(dentro.first ?? "a")])
            default:
                i += 1
                if i < ramo.count, ramo[i] == "?" || ramo[i] == "*" { i += 1; continue }
                if i < ramo.count, ramo[i] == "+" { i += 1 }
                juntar([String(c)])
            }
        }
        return saidas.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
