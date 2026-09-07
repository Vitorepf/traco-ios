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

    /// ADR 06i-B — O CRUZAMENTO, o bloco que faltava às duas réguas: desabafo
    /// que TAMBÉM carrega palavra de roteamento. É o caso comum na vida real e
    /// era o ponto cego das duas — as 57 protegidas quase não exercitam a
    /// família 1b (7 de 57) e nenhuma delas tem gancho. Oito destas o revisor
    /// do re-G3 mediu VESTIDAS pela A-5 e caladas em main. Um por gancho:
    /// `^quero`, `sempre que`, `toda vez`, `percebi`, `hoje eu preciso`,
    /// `não entendi`, `^preciso começar`, `^preciso parar`, `meu objetivo`,
    /// `\bapp\b`. Ao lado, a porta que levaria a nota se a guarda não existisse.
    static let comGancho: [(String, String)] = [
        ("Quero sumir uns dias, ando muito cansado ultimamente.", "woop"),
        ("Sempre que meu pai liga eu fico exausto por dois dias.", "seEntao"),
        ("Toda vez que ela não responde eu fico com um medo besta de ter feito algo errado.", "seEntao"),
        ("Percebi que estou sozinha faz meses e ninguém notou.", "notaPermanente"),
        ("Hoje eu preciso aguentar o dia, mas estou cansado demais pra isso.", "dia"),
        ("Não entendi por que ando tão vazio ultimamente.", "feynman"),
        ("Preciso começar a dormir, ando ansioso desde que ela foi embora.", "woop"),
        ("Preciso parar de me cobrar tanto, ando cansado demais pra isso.", "woop"),
        ("Meu objetivo era aguentar até sexta e estou exausto demais pra isso.", "woop"),
        ("Faz três semanas que eu acordo cansado, olho pro app que eu preciso construir e não consigo encostar nele, e isso me deixa pior a cada dia que passa.", "spec"),
        // ADR 06i-C — um por buraco fechado: `dá medo` predicado, `bate um
        // cansaço` e `por dentro pesa`. Os três tinham gancho e escapavam.
        ("Me dá um medo que trava tudo, e sempre que penso nisso eu adio.", "seEntao"),
        ("Toda vez que eu abro o computador bate um cansaço que não é do corpo.", "seEntao"),
        ("Hoje eu preciso fingir que está tudo bem, mas por dentro pesa.", "dia"),
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

    /// ADR 06i — A RÉGUA INVERSA, a que faltava: a nota comum de trabalho
    /// continua achando a sua forma. As 57 acima provam que desabafo não vira
    /// método; NENHUMA provava a outra direção, e foi por isso que a família 1
    /// larga da 06h passou. **Duas frases por PORTA** das 21 formas de main.
    /// As dez marcadas `[R]` são as do revisor do re-G3 — oito delas eram
    /// regressão limpa em `main` no commit `2d33d63`.
    static let trabalho: [(String, String)] = [
        ("Quero correr de manhã, mas o medo de me machucar me trava.", "woop"),  // [R]
        ("Meu objetivo é entregar o módulo até sexta, e o hábito de deixar pro fim atrapalha.", "woop"),
        ("Sempre que fico sozinho em casa eu abro a geladeira e como tudo.", "seEntao"),  // [R]
        ("Toda vez que eu chego cansado do trabalho eu deixo o treino pra amanhã.", "seEntao"),
        ("Preciso construir a tela de estado vazio do app, com mensagem e botão de recomeçar.", "spec"),  // [R]
        ("Estado vazio, carregando e falha: as três telas que faltam no app.", "spec"),  // [R]
        ("A carga pesa demais nesse endpoint e o módulo trava com dez mil linhas.", "spec"),  // [R]
        ("Estou cansado desse módulo cheio de casos especiais e vou reescrever a função.", "spec"),  // [R]
        ("O módulo roda sozinho depois do deploy, sem ninguém apertar nada.", "spec"),  // [R]
        ("Percebi que sistemas ansiosos por resposta imediata acabam derrubando a fila.", "notaPermanente"),  // [R]
        ("Entendi que a ideia central do artigo é separar decisão de execução.", "notaPermanente"),
        ("Comprar café\nRenovar o domínio\nMandar a nota fiscal", "destaque"),
        ("Ligar pro dentista\nPagar o IPTU\nTrocar o pneu do carro", "destaque"),
        ("Hoje foi um daqueles dias em que tudo dói e eu não consigo nomear o motivo, só sei que sentei no chão do banheiro e chorei sem barulho nenhum.", "expressiva"),
        ("Sinto uma tristeza sem endereço desde ontem à noite, e quanto mais eu tento explicar pra mim mesmo, menos sentido faz o que eu escrevo aqui.", "expressiva"),
        ("Numa frase: o produto existe pra devolver ao autor o que ele escreveu.", "destilar"),
        ("Preciso destilar esse relatório de vinte páginas em um parágrafo pro conselho.", "destilar"),
        ("O que significa idempotente no contexto de uma fila de mensagens?", "palavra"),
        ("Não conhecia o termo antifrágil até hoje, e vale fixar o sentido dele.", "palavra"),
        ("Tenho que escolher entre os dois fornecedores, e o medo de errar trava a decisão.", "decisao"),  // [R]
        ("A decisão de mudar de cidade não é reversível e não dá pra adiar mais.", "decisao"),
        ("Pré-mortem: imagino o lançamento no chão e o que me dá medo é ninguém avisar a tempo.", "premortem"),  // [R]
        ("Imagina que deu errado a migração: qual foi a primeira peça a ceder?", "premortem"),
        ("Meu argumento é que a fila deve ser síncrona, e a objeção mais forte é o custo.", "argumento"),
        ("Defendo que a revisão por pares vale o atraso de dois dias na entrega.", "argumento"),
        ("Li um estudo que diz que times cansados erram três vezes mais no fim do dia.", "leitura"),
        ("O livro que terminei ontem defende que o problema importante escolhe o pesquisador.", "leitura"),
        ("Preciso explicar pra minha irmã como funciona o juro composto sem fórmula.", "feynman"),
        ("Não entendi como o compilador resolve genéricos e quero entender de verdade.", "feynman"),
        ("Hoje eu preciso fechar o orçamento, responder o cliente e revisar o contrato.", "dia"),
        ("Vou planejar o dia em três blocos: escrita de manhã, reuniões à tarde, leitura à noite.", "dia"),
        ("Que analogia explica cache pra quem nunca programou? Talvez a despensa de casa.", "analogia"),
        ("Onde isso já foi resolvido em outro campo? Logística deve ter resposta pronta.", "analogia"),
        ("Qual é o pior jeito de conduzir essa reunião? Começo listando o que evitar.", "inversao"),
        ("Inversão: como garantir que o lançamento dê errado de propósito?", "inversao"),
        ("Quem discorda de mim aqui tem um ponto: o plano grátis traz metade dos usuários.", "steelman"),
        ("Steelman da posição contrária: manter o servidor próprio sai mais barato em três anos.", "steelman"),
        ("Dez jeitos de reduzir o tempo de resposta sem trocar o banco.", "divergencia"),
        ("Brainstorm de todas as opções de nome antes de bater o martelo.", "divergencia"),
        ("Do zero: por que essa reunião semanal existe? Quais pressupostos ninguém checou?", "primeirosPrincipios"),
        ("Primeiros princípios do preço: o que é verdade de fato sobre o custo por usuário?", "primeirosPrincipios"),
        ("Preciso treinar escrita técnica: um exercício de trinta minutos por dia.", "praticaDeliberada"),
        ("A habilidade que falta pro time é revisar código em voz alta; dá pra treinar toda semana.", "praticaDeliberada"),
        ("Preciso construir uma busca exaustiva no módulo de relatórios antes de otimizar.", "spec"),
        ("Preciso construir a lista vazia e o estado vazio da tela.", "spec"),  // ADR 06i-B / ALTO-2
        // ADR 06i-C: a cauda da 06i-B tinha calado estas quatro. O intensificador
        // posposto curto-circuitava o teste do objeto, e `ando `/`bate ` sem
        // borda casavam dentro do gerúndio e de "combate".
        ("Estou cansado demais desse módulo cheio de casos especiais e vou reescrever a função.", "spec"),  // [R] ALTO-3
        ("Terminei de escrever o parser trabalhando cansado demais, vou revisar o módulo amanhã.", "spec"),  // [R] ALTO-4
        ("Estou trabalhando com medo de quebrar a produção, então vou construir um teste antes.", "spec"),
        ("O time está descansado e a fila vazia depois do deploy, e o módulo aguenta.", "spec"),
        ("Meu argumento é que o sentimento do cliente não substitui o dado da pesquisa.", "argumento"),
        ("Aposto que o novo fluxo reduz o abandono, mas dou 60% de chance, não mais que isso.", "atualizacao"),
        ("Qual a probabilidade real de entregar em março? Quanto eu acredito nisso hoje?", "atualizacao"),
        // ADR 06i-D: a mesma classe de borda da 06i-C, dois pontos que a
        // varredura não tinha alcançado — `tratei mal` dentro de "contratei" e
        // "retratei", e o `dá|deu` largo comendo a ansiedade do usuário.
        ("Contratei mal o fornecedor e vou construir um processo de seleção com três etapas.", "spec"),
        ("Retratei mal o problema no relatório e preciso destilar tudo em um parágrafo.", "destilar"),
        ("Percebi que contratei mal por pressa: urgência não é critério de escolha.", "notaPermanente"),
        ("A fila dá ansiedade no usuário e vou construir um indicador de progresso na tela.", "spec"),
        ("Esse fluxo dá cansaço em quem usa, e preciso destilar as dez etapas em três.", "destilar"),
        ("Percebi que a espera longa dá ansiedade em quem espera, e isso muda o desenho.", "notaPermanente"),
        // ADR 2026-09-06e: as SETE portas que a volta M3 abre. A régua de
        // `todaPortaDeMainTemPeloMenosDuasFrases` cobra duas frases por porta,
        // e as sete novas são justamente as que roubavam escrita pessoal — não
        // há frase aqui que confesse conduta; toda uma é nota de trabalho.
        ("O cadastro ficou complicado demais e dá para simplificar antes de lançar.", "subtracao"),
        ("O painel está cheio de botões e eu vou cortar pela metade nesta versão.", "subtracao"),
        ("Aquela conversa com o fornecedor foi confusa e preciso reconstruir os dois lados.", "colunaEsquerda"),
        ("Na reunião com o jurídico faltou registrar o que cada lado defendeu.", "colunaEsquerda"),
        ("Quanto tempo vai levar a migração do banco? Já fiz três parecidas.", "classeDeReferencia"),
        ("Minha estimativa é de duas semanas, e vale comparar com as vezes anteriores.", "classeDeReferencia"),
        ("O build quebrou de novo na mesma etapa e eu preciso da causa raiz.", "cincoPorques"),
        ("Por que isso aconteceu no deploy de sexta pela terceira vez seguida?", "cincoPorques"),
        ("Quais são os problemas importantes do meu campo que eu venho adiando?", "perguntaHamming"),
        ("No que eu deveria estar trabalhando neste trimestre para o resultado importar?", "perguntaHamming"),
        ("Qual é o custo de oportunidade de manter o servidor próprio mais um ano?", "vistoNaoVisto"),
        ("O plano anual sai mais barato na fatura, mas em troca de quê?", "vistoNaoVisto"),
        ("Exame da noite: o que do dia de trabalho eu não repito amanhã.", "exameDaNoite"),
        ("Passei o dia em revista e vou fixar uma regra para a semana.", "exameDaNoite"),
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
    /// A régua inversa correndo: cada nota de trabalho chega à SUA porta.
    /// Falha se qualquer uma parar de chegar — é o teste que não existia.
    @MainActor @Test func aNotaComumDeTrabalhoContinuaAchandoAForma() {
        for (frase, esperado) in Self.trabalho {
            #expect(Self.rota(frase) == esperado,
                    Comment(rawValue: "\(Self.rota(frase)) ← «\(frase)» (esperado \(esperado))"))
        }
    }

    /// E o catálogo de main não tem porta sem régua: 21 formas, no mínimo duas
    /// frases cada. Sem isto a régua acima encolhe sem ninguém ver.
    @MainActor @Test func todaPortaDeMainTemPeloMenosDuasFrases() {
        var porPorta: [String: Int] = [:]
        for (_, p) in Self.trabalho { porPorta[p, default: 0] += 1 }
        for m in Catalogo.doApp {
            #expect(porPorta[m.id, default: 0] >= 2,
                    Comment(rawValue: "porta sem régua de alcance: \(m.id)"))
        }
        #expect(porPorta.count == Catalogo.doApp.count)
    }

    /// AS DUAS RÉGUAS JUNTAS, no mesmo catálogo e na mesma corrida — é a
    /// condição que a ADR 06i cobra: a guarda que protege as 57 não pode calar
    /// as 47, e vice-versa. Se um dia as duas não puderem valer ao mesmo tempo,
    /// o caso vai para a ADR com o lado escolhido, não para este teste.
    @MainActor @Test func asDuasReguasValemAoMesmoTempo() {
        Self.comOsNovos {
            for frase in Self.curtas + Self.longas + Self.doRevisorG3
                + Self.minhas.map(\.0) + Self.comGancho.map(\.0) {
                let r = Self.rota(frase)
                #expect(r == "silencio" || r == "expressiva",
                        Comment(rawValue: "escrita pessoal vestida de \(r): «\(frase)»"))
            }
            for (frase, esperado) in Self.legitimas + Self.trabalho {
                #expect(Self.rota(frase) == esperado,
                        Comment(rawValue: "\(Self.rota(frase)) ← «\(frase)» (esperado \(esperado))"))
            }
        }
    }

    /// ADR 06i-B: desabafo COM gancho continua desabafo. Cada uma bate no
    /// roteamento da porta declarada — sem a guarda a nota chega lá vestida,
    /// que é exatamente o que o revisor mediu (18 de 20) na A-5.
    @MainActor @Test func oDesabafoComGanchoDeRoteamentoNaoViraExercicio() {
        Self.comOsNovos {
            for (frase, porta) in Self.comGancho {
                let r = Self.rota(frase)
                #expect(r == "silencio" || r == "expressiva",
                        Comment(rawValue: "desabafo com gancho vestido de \(r): «\(frase)»"))
                let lower = frase.lowercased()
                #expect(AnaliseLocal.eEscritaPessoal(frase, lower),
                        Comment(rawValue: "a guarda não reconhece: «\(frase)»"))
                #expect(Catalogo.metodo(porta)?.roteamento.contains { lower.contains(regex: $0) } == true,
                        Comment(rawValue: "sem gancho de \(porta), a frase não mede nada: «\(frase)»"))
            }
        }
    }

    /// ADR 06i, o critério em si: a palavra de dupla vida sozinha não decide.
    @MainActor @Test func aPalavraDeDuplaVidaSozinhaNaoDecide() {
        func p(_ t: String) -> Bool { AnaliseLocal.eEscritaPessoal(t, t.lowercased()) }
        // o sentimento como ASSUNTO — primeira pessoa, complemento pronome ou nada
        #expect(p("Estou sozinho nisso."))
        #expect(p("Estou cansado de mim."))
        #expect(p("Estou com medo de perder ela."))
        #expect(p("Não conhecia esse vazio de agora."))
        #expect(p("Estou exausto e vazio."))          // duas de dupla vida
        #expect(p("Foi pesado e eu fiquei calada."))  // dupla vida + omissão, 29 caracteres
        // a mesma palavra dita de uma COISA, ou como obstáculo de uma intenção
        #expect(!p("Estou cansado desse módulo cheio de casos especiais."))
        #expect(!p("Sempre que fico sozinho em casa eu abro a geladeira."))
        #expect(!p("O medo de me machucar me trava."))
        #expect(!p("A tela de estado vazio precisa de um botão."))
        #expect(!p("O módulo roda sozinho depois do deploy."))
        // e a borda de palavra do `senti`: "sentido" e "sentimento" não são desabafo
        // ADR 06i-B: a cauda do idioma — intensificador posposto e tempo
        #expect(p("Estou cansado demais pra isso."))
        #expect(p("Ando sozinha faz meses."))
        #expect(p("Fico com um medo besta de ter feito algo errado."))
        #expect(p("Acordo cansado, olho pro dia e não encosto em nada."))
        #expect(p("Estou com uma ansiedade que não passa."))
        #expect(p("Meu cansaço não é de trabalho."))
        // e o mesmo vocabulário dito de uma COISA continua trabalho
        #expect(!p("A ansiedade do usuário na fila é o sintoma, não a causa."))
        #expect(!p("O cansaço do time depois do deploy é real."))
        // ADR 06i-B / ALTO-2: `vazia` e `vazio` são a MESMA palavra na densidade
        #expect(!p("A lista vazia e o estado vazio da tela."))
        #expect(!p("O que me dá medo é ninguém avisar a tempo."))
        #expect(!p("Faz sentido separar o módulo em dois? O sentimento do time é que sim."))
        #expect(!p("Preciso de uma busca exaustiva no índice antes de otimizar."))
        // ADR 06i-C: o intensificador é TRANSPARENTE — o objeto continua sendo
        // testado depois dele, e uma palavra a mais não troca o lado da frase.
        #expect(!p("Estou cansado demais desse módulo cheio de casos especiais."))
        #expect(p("Estou cansado demais pra isso."))
        // e a borda de palavra dos verbos: gerúndio não é primeira pessoa
        #expect(!p("Terminei o parser trabalhando cansado demais, vou revisar o módulo."))
        #expect(!p("Fiquei pensando ansioso demais no resultado do deploy."))
        #expect(!p("Estou trabalhando com medo de quebrar a produção."))
        #expect(!p("O combate um medo de cada vez é a tática do time de suporte."))
        // ...e dos radicais que moram dentro de outra palavra
        #expect(!p("O time está descansado e a fila vazia depois do deploy."))
        #expect(!p("Ele pensou o problema todo e devolveu a spec revisada."))
        #expect(!p("O filme odiado pela crítica virou tema da spec da semana."))
        #expect(!p("Me abriguei da chuva e cheguei atrasado na reunião do módulo."))
        #expect(!p("O erro foi desculpado pelo time e a fila voltou a rodar."))
        // ADR 06i-C: PREDICAR leva artigo, pede infinitivo ou abre a frase;
        // NOMEAR é o obstáculo dentro de uma intenção e continua trabalho
        #expect(p("Me dá um medo que trava tudo."))
        #expect(p("Dá medo de encarar amanhã."))
        #expect(!p("O que dá medo de verdade nesse plano é o custo do banco."))
        // e o mesmo verbo no ramo dos substantivos, que tinha ficado de fora
        #expect(p("Toda vez que eu abro o computador bate um cansaço que não é do corpo."))
        #expect(p("Percebi que bate uma ansiedade toda vez que ele chega em casa."))
        #expect(p("Hoje eu preciso fingir que está tudo bem, mas por dentro pesa."))
    }
}
