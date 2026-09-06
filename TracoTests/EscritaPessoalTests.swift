import Foundation
import Testing

@testable import Traco

/// ADR 2026-09-06h — a escrita pessoal é da Expressiva, e de mais ninguém.
///
/// As 58 frases são do REVISOR da volta M3 (`ferramentas/orca/m3-rev-provas/`),
/// não minhas: 22 delas eram roubadas por dois métodos que fazem pergunta sobre
/// a conduta do autor. Os dois entram aqui pela pasta do autor — o
/// `Metodos.json` é da volta M3 e não se toca — com o roteamento literal dela.
@Suite(.serialized) struct EscritaPessoalTests {
    /// Os SETE da volta M3, com o roteamento literal do `Metodos.json` dela.
    static let novos = [
        "subtracao": #"{"id":"subtracao","nome":"Subtração","campos":[{"id":"melhorar","rotulo":"O que eu quero melhorar (já existe)"},{"id":"ia","rotulo":"O que eu ia acrescentar"}],"roteamento":["\\bsimplificar\\b|\\benxugar\\b|\\bcortar pela metade\\b|\\bmenos (é|e) mais\\b","\\bo que (eu )?(tiro|corto|removo)\\b|\\bo que (tirar|remover|cortar)\\b|\\btirar (uma|umas|algumas|as) (coisa|coisas|peças?|partes?|etapas?)\\b","\\b(cheio|cheia|lotad[oa]) de (passos|etapas|op[çc][õo]es|regras|coisas|bot[õo]es)\\b|\\bcomplicad[oa] demais\\b|\\bvirou um monstro\\b"]}"#,
        "colunaEsquerda": #"{"id":"colunaEsquerda","nome":"Coluna da esquerda","campos":[{"id":"comQuem","rotulo":"A conversa (com quem, sobre o quê)"},{"id":"disse","rotulo":"O que foi dito, dos dois lados"}],"roteamento":["\\bn[ãa]o (disse|falei|consegui dizer)\\b|\\bengoli\\b|\\bfiquei calad[oa]\\b|\\bdeixei passar\\b","\\bdevia ter (dito|falado|respondido)\\b|\\bqueria ter dito\\b|\\bo que eu queria ter falado\\b","\\b(essa|aquela) conversa (com|foi)\\b|\\ba conversa com (o|a|ele|ela)\\b|\\bna reuni[ãa]o com\\b"]}"#,
        "classeDeReferencia": #"{"id":"classeDeReferencia","nome":"Classe de referência","campos":[{"id":"estimo","rotulo":"O que estou estimando, e o palpite de agora"},{"id":"parecidos","rotulo":"As vezes em que fiz parecido, e como cada uma terminou"}],"roteamento":["\\bquanto tempo (isso |isto |ele |ela )?(vai levar|leva|vai demorar|demora)\\b|\\bem quanto tempo\\b","\\bestimativa\\b|\\bestimo\\b|\\bchute de (prazo|tempo)\\b|\\bd[áa] para (fazer|terminar|entregar) (isso|isto) em\\b","\\bacho que (levo|leva|demora|dá para fazer em|termino em)\\b|\\bfica pronto em\\b|\\bentrego (em|at[ée])\\b"]}"#,
        "cincoPorques": #"{"id":"cincoPorques","nome":"Cinco porquês","campos":[{"id":"aconteceu","rotulo":"O que aconteceu (o fato, sem explicação)"},{"id":"porque1","rotulo":"Por quê? (1)"}],"roteamento":["\\bdeu errado de novo\\b|\\baconteceu de novo\\b|\\bde novo o mesmo\\b|\\bsempre (quebra|estoura|d[áa] errado)\\b","\\bpor que isso (aconteceu|deu errado|quebrou)\\b|\\bcausa raiz\\b|\\bcinco porqu[êe]s\\b|\\b5 porqu[êe]s\\b","\\bqual (foi|é) a causa\\b|\\bfalhou de novo\\b"]}"#,
        "perguntaHamming": #"{"id":"perguntaHamming","nome":"A pergunta de Hamming","campos":[{"id":"campo","rotulo":"O meu campo — onde eu quero contar"},{"id":"importantes","rotulo":"Os problemas importantes dele (um por linha)"}],"roteamento":["\\bproblemas? importantes?\\b|\\bo que (é|e) importante no meu campo\\b|\\bgrandes problemas\\b","\\bno que eu (deveria|devia) estar trabalhando\\b|\\bestou trabalhando (n[oa] )?(coisa )?errad[oa]\\b|\\btrabalhando em coisa pequena\\b","\\bvale a pena trabalhar nisso\\b|\\bisso me leva a algum lugar\\b|\\bpara onde isso me leva\\b"]}"#,
        "vistoNaoVisto": #"{"id":"vistoNaoVisto","nome":"O que se vê e o que não se vê","campos":[{"id":"ato","rotulo":"O ato, o hábito ou o gasto"},{"id":"vejo","rotulo":"O que se vê (o efeito imediato)"}],"roteamento":["\\bcusto de oportunidade\\b|\\bo que eu deixo de (fazer|ganhar|ter)\\b|\\bdeixo de fazer\\b","\\bcompensa mesmo\\b|\\bsai mais barato\\b|\\bt[áa] de gra[çc]a\\b|\\bnão custa nada\\b","\\bem troca de quê\\b|\\bo que isso me custa\\b|\\bo pre[çc]o disso\\b"]}"#,
        "exameDaNoite": #"{"id":"exameDaNoite","nome":"Exame da noite","campos":[{"id":"revi","rotulo":"O dia em revista, sem esconder nada"},{"id":"naoRepito","rotulo":"O que EU fiz e não quero repetir"}],"roteamento":["\\bexame da noite\\b|\\bpassei o dia em revista\\b|\\bolhando o dia de hoje\\b","\\bn[ãa]o devia ter (feito|reagido|agido|tratado)\\b|\\bme arrependi\\b|\\bfui (injust[oa]|gross[oa]|duro demais|ríspid[oa])\\b","\\bperdi a (paci[êe]ncia|cabe[çc]a)\\b|\\bhoje eu (fiz|reagi|tratei)\\b"]}"#,
    ]

    /// As 14 linhas curtas do revisor (`frases2.txt`), todas com o dia em
    /// primeira pessoa. Nenhuma pode virar exercício.
    static let curtas = [
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

    /// Os 8 desabafos longos e FACTUAIS do revisor (`frases.txt`): passam dos
    /// 120 caracteres e não usam nenhuma das dez palavras da Expressiva.
    static let longas = [
        "Foi um dia longo e eu fiquei calado a reunião inteira enquanto ele levava o crédito pelo que eu fiz. Saí de lá com um nó na garganta e não falei com ninguém.",
        "Engoli o que eu queria dizer. De novo. É sempre assim, eu penso a resposta perfeita três horas depois quando já não serve pra nada e só sobra o gosto ruim.",
        "Me arrependi. Deitei e fiquei olhando o teto pensando em tudo que eu não devia ter feito hoje, e quanto mais eu penso pior fica, não consigo desligar isso.",
        "Perdi a paciência de novo com a minha mãe no telefone. Ela não fez nada demais, eu que já estava no limite desde de manhã e joguei tudo em cima dela.",
        "Não devia ter reagido assim na frente do meu filho. Ele só perguntou uma coisa boba e eu explodi. Fico revendo a cara dele e me odiando um pouco por isso.",
        "Deixei passar mais uma vez. Ele falou aquilo na frente de todo mundo e eu ri junto como um idiota. Depois passei o resto do dia remoendo o que eu devia ter dito.",
        "Hoje eu tratei mal quem não merecia e agora estou aqui às onze da noite escrevendo isso pra não ligar pra ela e piorar tudo com uma desculpa mal feita.",
        "Fui injusto com o time inteiro na retrospectiva. Falei que o problema era falta de cuidado quando o problema era o prazo que eu mesmo aceitei sem discutir.",
    ]

    /// Volta A-B: os 15 desabafos que o REVISOR G3 inventou e mediu chegando
    /// VESTIDOS (de 20 que ele escreveu) — cinco pelos métodos que vêm
    /// ANTES da Expressiva no catálogo (`woop`, `seEntao`, `spec`,
    /// `notaPermanente`) e dois pelo rodapé do Destaque, que calculava
    /// `pessoal` e nunca usava o cálculo.
    static let doRevisorG3 = [
        "Chorei muito hoje. Sempre que ele fala assim eu me calo e depois passo a noite inteira remoendo.",
        "Não consigo parar de pensar no que eu disse pra ela. Doeu ver a cara dela quando eu falei aquilo.",
        "Percebi hoje que eu magoei a minha filha e estou me odiando por isso desde a hora do almoço.",
        "Toda vez que a minha mãe liga eu fico com raiva e depois com culpa, e hoje não foi diferente.",
        "Quero parar de ser assim. Hoje eu perdi a paciência de novo e senti vergonha na frente de todo mundo.",
        "Meu objetivo era não chorar hoje e eu chorei antes das dez da manhã, sozinho no carro.",
        "Chorei.\nFui grosso com ela.\nEstou pesado.",
        "Doeu muito.\nNao falei nada.\nHoje foi horrivel.",
        "Hoje eu não sirvo pra nada. Passei o dia olhando a TELA sem conseguir fazer nada, e à noite a conversa com o meu pai só piorou tudo.",
        "Estou exausto e vazio. Não durmo há três dias e hoje na reunião com o time eu simplesmente desliguei.",
        "A IDEIA de que eu estraguei aquela amizade não sai da minha cabeça, chorei no banho de novo.",
        "Entendi que eu sou o problema. Fui grosso com ela sem motivo nenhum e agora ela nem responde.",
        "Sempre que eu penso naquela conversa eu travo. Engoli tudo de novo.",
        "Preciso parar de fazer isso comigo. Hoje eu me odiei o dia inteiro.",
        "Estou sozinho nisso. Sempre que eu preciso de alguém não tem ninguém.",
    ]

    /// Volta A-B: os meus 20, escritos DEPOIS do conserto e contra a régua do
    /// dono — "se a sua guarda só passa nas frases que alguém já escreveu, ela
    /// não é guarda, é lista". Cada um bate numa porta DIFERENTE do catálogo
    /// (o `esperadoSemGuarda` é o método que levaria a nota se a guarda não
    /// existisse), varrendo os 21 métodos antes e depois da Expressiva.
    static let minhas: [(String, String)] = [
        ("Quero parar de me anular perto dele. Hoje foi de novo e eu voltei pra casa me sentindo um lixo.", "woop"),
        ("Toda vez que a gente discute eu acabo pedindo desculpa por algo que eu nem fiz. Estou cansado de mim.", "seEntao"),
        ("Passei o dia inteiro na frente da tela e não produzi nada. Me sinto um fracasso e não sei mais o que fazer.", "spec"),
        ("Percebi que faz meses que eu não rio de verdade. Fui ver as fotos de janeiro e nem reconheci aquela pessoa.", "notaPermanente"),
        ("Briguei com ela.\nNão pedi desculpa.\nDormi no sofá.", "destaque"),
        ("Hoje eu preciso fingir que está tudo bem outra vez, e cada dia isso pesa um pouco mais.", "dia"),
        ("Preciso decidir se eu conto pra ela o que aconteceu. Estou com medo das duas saídas.", "decisao"),
        ("Não entendi o que eu fiz de errado. Ela só parou de falar comigo e eu fiquei três dias remoendo.", "feynman"),
        ("Queria melhorar em ser gente. Fui grosso com o meu irmão hoje sem nenhum motivo e ele nem revidou.", "praticaDeliberada"),
        ("Estou lendo umas coisas sobre luto e chorei na terceira página. Acho que não é sobre o livro.", "leitura"),
        ("Não conhecia esse vazio de agora. É como se eu tivesse desligado por dentro e ninguém notasse.", "palavra"),
        ("O pior jeito de criar um filho é o que eu fiz hoje, e eu gritei com ele por causa de um copo derrubado.", "inversao"),
        ("O outro lado é que ela tem razão. Eu sumi, eu não liguei, e agora quero que ela entenda a minha tristeza.", "steelman"),
        ("Pensei em dez jeitos de sair dessa e todos terminam comigo sozinho num apartamento vazio.", "divergencia"),
        ("É como quando eu tinha doze anos e ninguém veio na minha festa. A mesma vergonha, trinta anos depois.", "analogia"),
        ("Do zero: eu não presto pra relacionamento nenhum. Hoje ficou claro na cara dela quando eu falei aquilo.", "primeirosPrincipios"),
        ("Aposto que ela nem vai responder. E eu não devia ter mandado aquela mensagem às duas da manhã, sabendo que ela ia ler de manhã cedo antes do trabalho.", "atualizacao"),
        ("Meu argumento hoje foi que eu estava cansado. É mentira, eu só descontei nela porque dava.", "argumento"),
        ("Imagina que deu errado: a gente se separa e eu fico com dois dias por semana com a minha filha. Não durmo pensando nisso.", "premortem"),
        ("Numa frase: eu estraguei o que era bom. Levei anos pra construir e uma noite pra pôr abaixo.", "destilar"),
    ]

    /// O outro lado: as frases do revisor que os dois métodos levam com razão.
    /// Se a guarda comer estas, ela é larga demais.
    static let legitimas: [(String, String)] = [
        ("Passei o dia em revista e não gostei do que vi.", "exameDaNoite"),
        ("Exame da noite: o que eu fiz hoje que eu faria de novo?", "exameDaNoite"),
        ("A conversa com ela ontem ficou entalada e eu não sei se falo ou se deixo morrer.", "colunaEsquerda"),
        ("Na reunião com o cliente eu deixei passar um erro grave só pra não criar atrito.", "colunaEsquerda"),
        ("Fiquei calada quando perguntaram quem tinha feito. Era eu. Não levantei a mão.", "colunaEsquerda"),
        ("Não consegui dizer que aquilo me machucou, e agora parece tarde demais pra dizer.", "colunaEsquerda"),
    ]

    static func comOsNovos<T>(_ corpo: () throws -> T) rethrows -> T {
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent("metodos-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: pasta)
            Catalogo.pastaDoAutor = pasta.deletingLastPathComponent().appendingPathComponent("nada")
            Catalogo.recarregar()
        }
        for (id, json) in novos {
            try? json.write(to: pasta.appendingPathComponent("\(id).json"), atomically: true, encoding: .utf8)
        }
        Catalogo.pastaDoAutor = pasta
        Catalogo.recarregar()
        return try corpo()
    }

    static func rota(_ texto: String) -> String {
        switch AnaliseLocal.classificar(texto: texto, gestoAtual: nil, campos: [:]) {
        case .silencio: "silencio"
        case .expressiva: "expressiva"
        case .aviso: "aviso"
        case .gesto(let g, _): g.rawValue
        }
    }

    @MainActor @Test func osDoisMetodosEntramMesmoPelaPastaDoAutor() throws {
        try Self.comOsNovos {
            #expect(Catalogo.metodo("colunaEsquerda") != nil)
            #expect(Catalogo.metodo("exameDaNoite") != nil)
            // e a ordem é a mesma da volta M3: os dois DEPOIS da Expressiva
            let ids = Catalogo.todos.map(\.id)
            let iE = try #require(ids.firstIndex(of: "expressiva"))
            #expect(try #require(ids.firstIndex(of: "colunaEsquerda")) > iE)
            #expect(try #require(ids.firstIndex(of: "exameDaNoite")) > iE)
        }
    }

    @MainActor @Test func nenhumaDas22ViraExercicio() {
        Self.comOsNovos {
            // a régua do revisor da M3: escrita pessoal não vira `.gesto`
            // NENHUM — não é só não virar os dois métodos novos.
            for frase in Self.curtas + Self.longas {
                let r = Self.rota(frase)
                #expect(r == "silencio" || r == "expressiva",
                        Comment(rawValue: "escrita pessoal vestida de \(r) [\(frase.count)]: «\(frase)»"))
            }
            // as 8 longas passam do teto: se uma encolher, o teste deixa de
            // medir a metade difícil
            for frase in Self.longas { #expect(frase.count > AnaliseLocal.tetoDoDesabafo, Comment(rawValue: frase)) }
        }
    }

    @MainActor @Test func oQueOsDoisMetodosLevamComRazaoContinuaDeles() {
        Self.comOsNovos {
            for (frase, esperado) in Self.legitimas {
                #expect(Self.rota(frase) == esperado, Comment(rawValue: "\(Self.rota(frase)) ← \(frase.prefix(60))"))
            }
        }
    }

    /// Volta A-B / achado A-1 do G3: a guarda deixou de depender da POSIÇÃO no
    /// catálogo. Os cinco métodos antes da Expressiva e o rodapé do Destaque
    /// estão cobertos pelo mesmo cálculo.
    @MainActor @Test func osVinteDoRevisorG3NaoViramExercicio() {
        Self.comOsNovos {
            for frase in Self.doRevisorG3 {
                let r = Self.rota(frase)
                #expect(r == "silencio" || r == "expressiva",
                        Comment(rawValue: "escrita pessoal vestida de \(r): «\(frase)»"))
            }
        }
    }

    /// A régua do dono: frases que NINGUÉM tinha escrito quando a guarda foi
    /// feita, uma por porta do catálogo. Sem a guarda cada uma vira o método
    /// declarado ao lado — é o que faz delas régua e não enfeite.
    @MainActor @Test func osMeusVinteNaoViramExercicio() {
        Self.comOsNovos {
            for (frase, _) in Self.minhas {
                let r = Self.rota(frase)
                #expect(r == "silencio" || r == "expressiva",
                        Comment(rawValue: "escrita pessoal vestida de \(r): «\(frase)»"))
            }
        }
    }

    /// E cada uma delas bate mesmo na porta que diz bater: sem `eEscritaPessoal`
    /// a nota chegaria ao método do lado. Se este teste ficar verde com a
    /// guarda desligada, a régua acima não mede nada.
    @MainActor @Test func cadaUmaDasMinhasBateNumaPortaDiferente() {
        let portas = Set(Self.minhas.map(\.1))
        #expect(portas.count == Self.minhas.count)
        for (frase, esperado) in Self.minhas {
            let voz = frase
            let lower = voz.lowercased()
            #expect(AnaliseLocal.eEscritaPessoal(voz, lower),
                    Comment(rawValue: "a guarda não reconhece: «\(frase)»"))
            guard esperado != "destaque" else {
                let linhas = voz.split(separator: "\n")
                #expect(linhas.count >= 3 && linhas.allSatisfy { $0.count < 60 })
                continue
            }
            let m = Catalogo.metodo(esperado)
            #expect(m?.roteamento.contains { lower.contains(regex: $0) } == true,
                    Comment(rawValue: "não bate em \(esperado): «\(frase)»"))
        }
    }

    /// Volta A-B / achado A-2 do G3: `.silencio` tem precedência ZERO em
    /// `Sessao.escolher`, então a guarda era NULA com Grok ou Apple
    /// Intelligence ligados. A quarta linha da regra: escrita pessoal
    /// reconhecida pelo algoritmo cala o modelo.
    @MainActor @Test func aEscritaPessoalCalaOModelo() {
        let doModelo = AnaliseLocal.Veredito.gesto(.expressiva, pergunta: "p")
        let exame = AnaliseLocal.Veredito.gesto(.destaque, pergunta: "p")
        // sem a guarda, a forma do modelo continua mandando (ADR 04c)
        #expect(Sessao.escolher(remoto: exame, local: .silencio) == exame)
        // com a guarda, o veredito local vence qualquer forma do modelo
        #expect(Sessao.escolher(remoto: exame, local: .silencio, pessoal: true) == .silencio)
        #expect(Sessao.escolher(remoto: doModelo, local: .expressiva, pessoal: true) == .expressiva)
        // e o aviso local continua acima de tudo
        let aviso = AnaliseLocal.Veredito.aviso(AnaliseLocal.avisoWood)
        #expect(Sessao.escolher(remoto: exame, local: aviso, pessoal: true) == aviso)
    }

    /// E o caminho de verdade: `Sessao` calcula `pessoal` do texto cru, com o
    /// mobiliário fora, como `classificar` faz.
    @MainActor @Test func aSessaoReconheceAEscritaPessoalDoTextoCru() {
        #expect(AnaliseLocal.escritaPessoal(texto: "Me arrependi e chorei.", campos: [:]))
        #expect(!AnaliseLocal.escritaPessoal(texto: "", campos: [:]))
        #expect(!AnaliseLocal.escritaPessoal(texto: "Preciso construir um app de notas.", campos: [:]))
    }

    /// A guarda é do texto, não da lista de métodos: vale para qualquer método
    /// que venha depois da Expressiva, inclusive um que o autor escreva.
    @MainActor @Test func aGuardaOlhaOTextoENaoOMetodo() {
        #expect(AnaliseLocal.eEscritaPessoal("Me arrependi.", "me arrependi."))
        #expect(!AnaliseLocal.eEscritaPessoal("Preciso construir um app de notas.",
                                              "preciso construir um app de notas."))
        // o ato contado é desabafo no texto longo e nota curta no texto curto
        let curto = "Fiquei calada quando perguntaram quem tinha feito. Era eu."
        #expect(!AnaliseLocal.eEscritaPessoal(curto, curto.lowercased()))
        let longo = String(repeating: "a conversa seguiu e eu fiquei calada. ", count: 5)
        #expect(AnaliseLocal.eEscritaPessoal(longo, longo))
    }
}
