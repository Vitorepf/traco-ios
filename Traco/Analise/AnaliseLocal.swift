import Foundation

/// Analisar do app. Roda só no aparelho.
/// Nunca chama api.x.ai, nunca gasta crédito Super, nunca paga token.
enum AnaliseLocal: Sendable {
    enum Veredito: Equatable {
        case silencio
        case aviso(String)
        case gesto(Gesto, pergunta: String)
        case expressiva
    }

    nonisolated static let avisoFrasePronta = "Nesta página, a escrita é sua. Para delegar um texto à IA, use um Trabalho."
    /// ADR 06f: o app não diz o que a fonte não mediu. Wood 2009 mediu HUMOR
    /// logo depois de repetir uma frase dada, não fixação — a informação e a
    /// pergunta ficam; a sentença sobre o mundo, não.
    nonisolated static let avisoWood = "Um estudo de 2009 mediu isto: repetir uma frase dessas fez quem estava com a autoestima baixa se sentir pior, e quem estava com ela alta, um pouco melhor. O que aconteceu que fez você escrever isso?"
    nonisolated static let avisoOuvinte = "Quem é a pessoa de verdade que deveria ouvir isto?"
    nonisolated static let avisoOettingen = "Falta o obstáculo. O que, em você, pode atrapalhar isto?"
    nonisolated static let avisoDoisGestos = "Um gesto por sessão. O segundo método vai para outra página."

    /// A ÚNICA porta entre um rótulo da IA e uma frase na tela (§19.4).
    /// Rótulo fora deste dicionário = silêncio.
    nonisolated static let avisos: [String: String] = [
        "afirmacaoVazia": avisoWood,
        "textoPronto": avisoFrasePronta,
        "ouvinte": avisoOuvinte,
        "semObstaculo": avisoOettingen,
        "doisGestos": avisoDoisGestos,
    ]
    /// ADR 06f: de onde vem o aviso, no formato da ADR 05x. Aviso fora deste
    /// dicionário não tem fonte a mostrar, e a tela não inventa uma.
    nonisolated static let provenienciaDosAvisos: [String: Metodo.Proveniencia] = [
        avisoWood: .init(
            fonte: "Joanne V. Wood, W. Q. Elaine Perunovic e John W. Lee, \"Positive self-statements: power for some, peril for others\", Psychological Science 20(7), 2009",
            funcao: .evidencia,
            evidencia: "Dois experimentos com estudantes, medindo humor logo depois de repetir uma frase dada. Quem tinha autoestima baixa se sentiu pior; quem tinha alta, um pouco melhor. Não mede escrever a própria frase, não mede efeito duradouro, e não diz nada sobre você."),
    ]

    /// O aviso do plano sem obstáculo é o mesmo estudo do WOOP: a proveniência
    /// é a do catálogo, não uma segunda cópia que possa divergir dela.
    nonisolated static func proveniencia(doAviso aviso: String) -> Metodo.Proveniencia? {
        if aviso == avisoOettingen { return Catalogo.metodo("woop")?.proveniencia }
        return provenienciaDosAvisos[aviso]
    }

    nonisolated static let perguntaWOOP = "Qual é o hábito ou o medo seu que vai impedir — não o relógio, não os outros?"

    static func classificar(texto: String, gestoAtual: Gesto?, campos: [String: String]) -> Veredito {
        // §8.5 no motor, não só na UI: a análise NUNCA comenta uma expressiva —
        // nem reaberta por dupla confirmação, nem com o timer parado.
        if gestoAtual == .expressiva { return .silencio }
        let bruto = Caderno.prosa(de: texto).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bruto.isEmpty else { return .silencio }

        let voz = VozDoAutor.juntar(texto: bruto, campos: campos)
        let lower = voz.lowercased()

        if pedeTextoPronto(texto) {
            return .aviso(avisoFrasePronta)
        }
        if lower.contains(regex: #"eu sou (rico|um vencedor|incrível|o melhor|imparável)"#) {
            return .aviso(avisoWood)
        }
        if lower.contains(regex: #"me escuta|me console|desabafar com você|preciso falar com alguém"#) {
            return .aviso(avisoOuvinte)
        }

        if let gestoAtual {
            let posForma = campos.values
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
            if let novo = detectarGesto(posForma, posForma.lowercased(), estrito: true),
               novo != gestoAtual {
                return .aviso(avisoDoisGestos)
            }
            return .silencio
        }

        // ADR 04l: um arquivo de leitura anexado (pdf, epub) com prosa ao lado é
        // material de fora entrando — a forma é a Leitura (antes das
        // regex de prosa: o arquivo pesa mais que uma palavra solta como "ideia"), com a sua prova no
        // Recordar. O arquivo continua arquivo; o conhecimento é o que o autor
        // escreve nas próprias palavras.
        if texto.contains(regex: #"\]\(traco://file/[0-9A-Fa-f-]{36}\)"#),
           texto.lowercased().contains(regex: #"\[arquivo:[^\]]*\.(pdf|epub)\]"#),
           let leitura = Gesto(rawValue: "leitura"), leitura.conhecido {
            return .gesto(leitura, pergunta: pergunta(leitura))
        }
        if let gesto = detectarGesto(voz, lower, estrito: false) {
            if gesto == .expressiva { return .expressiva }
            return .gesto(gesto, pergunta: pergunta(gesto))
        }

        if ePlanoSemObstaculo(lower) {
            return .aviso(avisoOettingen)
        }
        return .silencio
    }

    /// O aviso local tem prioridade até sobre o modelo: uma menção não pode
    /// interromper o autor como se fosse um pedido. Preservar a estrutura aqui
    /// impede que `prosa` transforme citação, título ou tarefa em comando.
    /// Campos são respostas do método, não instruções ao aplicativo.
    static func pedeTextoPronto(_ markdown: String) -> Bool {
        guard case .paragrafo(let abertura) = Caderno.fatias(markdown).first?.bloco else { return false }
        // ponytail: reconhece somente comandos diretos na abertura. Pedidos
        // indiretos exigem intenção explícita na superfície, não mais palavras
        // soltas classificadas como ordem dentro do material do autor.
        return abertura.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().contains(regex:
            #"^(?:por favor[,\s]+)?(?:escrev[ae]\s+(?:por|pra|para)\s+mim\b|(?:resuma|reescreva)\b|melhore\s+(?:(?:o|a|os|as|este|esta|esse|essa|meu|minha)\s+)?(?:texto|frase|par[aá]grafo|rascunho|reda[çc][ãa]o)\b)"#)
    }

    /// Plano/fantasia sem obstáculo interno — e sem o gancho WOOP ("quero"),
    /// que já abre a forma que cobra o obstáculo.
    static func ePlanoSemObstaculo(_ lower: String) -> Bool {
        let temPlano = lower.contains(regex: #"meu plano|vou (conseguir|ser|ficar|ter sucesso)|amanhã (eu )?vou|já me vejo|só (pensar|vibrar) positivo|vai dar certo"#)
        let temObstaculo = lower.contains(regex: #"obstáculo|medo|preguiça|hábito|sempre que|mas eu|quando eu|adiar|procrastin|ansiedade|cansaço"#)
        let temWOOP = lower.contains(regex: #"(?m)^quero|^preciso começar|^preciso parar|meu objetivo"#)
        return temPlano && !temObstaculo && !temWOOP
    }

    /// O teto que separa a nota curta do desabafo: abaixo dele um "senti"
    /// solto não abre a Expressiva, e o Destaque continua Destaque.
    static let tetoDoDesabafo = 120

    /// ADR 06h (volta A-B): CINCO FAMÍLIAS, não uma lista de frases. O revisor
    /// mostrou o defeito de lista: `me odiando` pegava e `me odiei` não.
    ///
    /// 1a. o estado, por RADICAL — qualquer flexão da mesma palavra, e só o
    /// sentimento que NÃO tem segunda vida no trabalho. `senti` ganhou borda de
    /// palavra na volta A-5: sem ela "o sentido dele" e "o sentimento do
    /// cliente" calavam a nota inteira.
    static let lexicoDoSentimento = #"\bsenti\b|\bsinto\b|\bsentia\b|\bme sentindo\b|dói|doeu|chor(ei|ar|ando|o)|trist|raiva|desmoron|arrepend|vergonh|mago[aeiou]|remoend|\btravei\b|\beu travo\b|angusti|desanimad|humilhad|\bculpad|nó na garganta"#

    /// 1b (ADR 06i). A PALAVRA DE DUPLA VIDA: `medo`, `pesa`, `ansioso`,
    /// `exausto`, `vazio`, `sozinho` e `cansado` são vocabulário de trabalho
    /// tanto quanto de desabafo — "o medo de me machucar me trava" é o
    /// OBSTÁCULO de um WOOP, "estado vazio, carregando e falha" é uma tela.
    /// Sozinha ela não decide nada; precisa do autor no meio (`lexicoDoSentimentoNoAutor`),
    /// de uma segunda palavra da mesma família, ou da omissão ao lado.
    /// ADR 06i-B: `vazi`, não `vazi[oa]` — era o único radical desta lista que
    /// capturava a própria flexão, e por isso "a lista vazia e o estado vazio"
    /// contava como DUAS palavras na densidade. Os substantivos `ansiedade` e
    /// `cansaço` entram porque `ansios`/`cansad` não os alcançam.
    /// ADR 06i-C: `\b` em `medo` e `cansad` — sem ela "o time está descansado e
    /// a fila vazia" contava duas palavras e calava uma nota de sistema.
    static let lexicoDeDuplaVida = #"\bmedo|\bpesa|ansios|ansiedade|exaust|vazi|sozinh|\bcansad|\bcansaço"#

    /// ADR 06i-B — A CAUDA DO IDIOMA. O revisor mediu 18 de 20 desabafos novos
    /// vestidos pela A-5: a causa não era o radical, era esta lista curta. O que
    /// vem depois do adjetivo num desabafo real não é só pronome e pontuação —
    /// é intensificador posposto ("cansado demais") e advérbio de tempo
    /// ("sozinha faz meses", "vazio ultimamente", "exausto por dois dias").
    /// ADR 06i-C: o intensificador saiu daqui e virou TRANSPARENTE
    /// (`intensificadorPosposto`). Como terminador ele curto-circuitava o teste
    /// do objeto: "estou cansado demais desse módulo" — o exemplo canônico do
    /// lado trabalho — casava na palavra `demais` e nunca chegava a olhar o
    /// objeto. `pra isso` entra porque é complemento pronominal, não objeto.
    static let caudaDoSentimento = #"([.,;!?]|$|e |nisso|disso|pra isso|de mim|comigo|por dentro|aqui|hoje|ainda|de novo|de tudo|desde |faz (tempo|dias|semanas|meses|anos)|o (dia|tempo) (todo|inteiro)|há (dias|semanas|meses)|por (\w+ )?(dias?|semanas?|horas?|m[êe]s|meses))"#

    /// O intensificador vem ENTRE o adjetivo e a cauda, e não no lugar dela: com
    /// ele "cansado demais pra isso" é desabafo e "cansado demais desse módulo"
    /// continua trabalho, porque o objeto ainda é testado.
    static let intensificadorPosposto = #"(demais|pra caramba|ultimamente)?\s*"#

    /// ADR 06i — o critério: o SENTIMENTO COMO ASSUNTO, não a palavra solta.
    /// Primeira pessoa + verbo de estado, e o complemento é pronome, nada, ou
    /// uma cauda do idioma ("estou sozinho nisso", "cansado demais") — não um
    /// objeto de trabalho ("estou cansado desse módulo", "fico sozinho em
    /// casa"). Para `medo` a linha é entre PREDICAR ("estou com medo", "fico
    /// com um medo") e NOMEAR ("o medo de errar"), que é o obstáculo dentro de
    /// uma intenção; `vazio` conta como SUBSTANTIVO ("esse vazio"), não como
    /// adjetivo de tela; e `pesa` conta quando o que pesa não tem nome ("isso
    /// pesa", "cada dia pesa"), porque a nota de trabalho nomeia a carga.
    /// O RADICAL não foi tocado na 06i-B: alargá-lo é o que causou a regressão
    /// da 06h. Só a cauda, os verbos de estado e os dois substantivos.
    /// ADR 06i-C: `\b` na frente de TODA lista de verbos. Sem ela `ando ` casava
    /// dentro do gerúndio ("trabalhando cansado demais"), `bate ` dentro de
    /// "combate um medo", e uma nota de trabalho perdia a porta. É o mesmo
    /// defeito de borda que a 06i consertou no `senti`.
    static let lexicoDoSentimentoNoAutor =
        #"\b(estou|tô|estava|ando|fiquei|fico|vivo|acordei|acordo|me sinto|me sentia|sinto-me) (muito |tão |meio |um pouco |completamente |bem |só )?(sozinh[oa]|cansad[oa]|vazi[oa]|exaust[oa]|ansios[oa])\b\s*"#
        + intensificadorPosposto
        + caudaDoSentimento
        + #"|\b(estou|tô|estava|fiquei|fico|tenho|tinha|senti|sinto|ando|bate|bateu) (com |muito |tanto |um pouco de )*(um |uma )?medo"#
        + #"|morrendo de medo"#
        // ADR 06i-C — PREDICAR vs NOMEAR, a linha que a 06i-B nomeou e não
        // escreveu. PREDICAR leva artigo ("me dá um medo"), pede infinitivo
        // ("dá medo de encarar") ou abre a frase ("Dá medo."). NOMEAR — "o que
        // me dá medo é ninguém avisar" — não faz nenhum dos três, e continua
        // sendo obstáculo dentro de uma intenção.
        + #"|\bd[áa] (um |uma )medo|\bd[áa] medo de \w+r\b|(^|[.!?]\s*)d[áa] medo"#
        // ADR 06i-D — `me dá|me deu`, não `dá|deu`: o largo comia "a fila dá
        // ansiedade no usuário" e "esse fluxo dá cansaço", onde a ansiedade é
        // do usuário e não do autor.
        + #"|\b(estou|tô|ando|vivo|fiquei|fico|bate|bateu|me d[áa]|me deu) (com |numa |num |de )?(muita |tanta |uma |um )?(ansiedade|cansaço)\b"#
        + #"|\b(minha|meu) (ansiedade|cansaço)\b"#
        + #"|\b(o|um|esse|aquele|num|no|meu) vazio\b"#
        + #"|\b(isso|isto|tudo|a vida|o dia|cada dia|essa semana|por dentro) pesa\b"#

    /// 2. o juízo sobre si — o autor dizendo o que ELE é, ou o que ELE
    /// estragou. Vale em qualquer tamanho: "eu sou o problema" não fica menos
    /// pessoal em oitenta caracteres.
    /// ADR 06i-C: `\b` em `me ` e `sou ` — "ele pensou o problema todo" carrega
    /// `sou o problema` no meio de "pensou".
    static let lexicoDoJuizoSobreSi = #"\bme (odi|culp|detest|despre)|n[ãa]o (sirvo|presto|valho)|\bsou (o|um|uma) (problema|lixo|fracasso|idiota|péssim|merda)|a culpa (é|foi) minha|estraguei|\bme sentindo (um|uma)"#

    /// 3. o funcionamento básico negado — dormir, comer, rir, aguentar. É o
    /// desabafo que não usa nenhuma palavra de sentimento e mesmo assim só
    /// fala de si.
    static let lexicoDoNaoAguento = #"n[ãa]o (durmo|consigo dormir|como mais|rio|aguento|tenho vontade|saio da cama|consigo mais)"#

    /// 4. a CONFISSÃO DE CONDUTA — o que eu fiz a alguém, ou o que eu não devia
    /// ter feito — em QUALQUER tamanho. O teto de 120 era a régua errada aqui:
    /// contar que se foi grosso com o irmão é desabafo com noventa caracteres
    /// tanto quanto com quatrocentos.
    /// ADR 06i-D: `\b` em `tratei mal` — sem ela "contratei mal" e "retratei
    /// mal" calavam uma nota de trabalho. Mesma classe de borda da 06i-C.
    /// ADR 06i-E: `não devia ter` veio da família 5, e a assimetria era
    /// arbitrária — "fui grosso com ele hoje" era calada e "não devia ter
    /// reagido assim com ele" chegava VESTIDA de Exame da noite no mesmo
    /// tamanho, sendo o mesmo ato de fala.
    static let lexicoDoAtoContraAlguem = #"fui (injust|gross|duro demais|ríspid)|perdi a (paciência|cabeça)|\btratei mal|\bbriguei|discuti com|gritei com|xinguei|explodi com|descontei (com|n[oa]|nel[ae]|em)|não devia ter"#

    /// 5. o que eu DEIXEI de fazer — e este sim só ACIMA do teto: curta,
    /// "fiquei calada quando perguntaram" é a nota que nomeia uma conversa, e o
    /// método que pergunta serve; longa, é o dia sendo despejado. Só o que é
    /// omissão de verdade mora aqui (ADR 06i-E).
    static let lexicoDaOmissao = #"engoli|fiquei calad|deixei passar"#

    /// ADR 06h — a fronteira do produto, em código e não no `Metodos.json`: a
    /// pasta do autor reescreve o catálogo, e uma guarda que protege a escrita
    /// pessoal não pode morar num arquivo editável.
    static func eEscritaPessoal(_ x: String, _ lower: String) -> Bool {
        if lower.contains(regex: lexicoDoSentimento) { return true }
        if lower.contains(regex: lexicoDoJuizoSobreSi) { return true }
        if lower.contains(regex: lexicoDoNaoAguento) { return true }
        if lower.contains(regex: lexicoDoAtoContraAlguem) { return true }
        if x.count > tetoDoDesabafo, lower.contains(regex: lexicoDaOmissao) { return true }
        // ADR 06i: a família 1b só decide com companhia. A omissão vale aqui em
        // QUALQUER tamanho ("Foi pesado e eu fiquei calada." tem 29 caracteres),
        // porque as duas marcas juntas já são o autor falando de si.
        guard lower.contains(regex: lexicoDeDuplaVida) else { return false }
        if lower.contains(regex: lexicoDaOmissao) { return true }
        if lower.contains(regex: lexicoDoSentimentoNoAutor) { return true }
        return duasDeDuplaVida(lower)
    }

    /// Densidade: duas palavras DIFERENTES de dupla vida na mesma nota
    /// ("estou exausto e vazio") são o assunto; uma só é vocabulário.
    private static func duasDeDuplaVida(_ lower: String) -> Bool {
        var vistas: Set<Substring> = []
        var resto = lower[...]
        while let r = resto.range(of: lexicoDeDuplaVida, options: .regularExpression) {
            vistas.insert(resto[r])
            if vistas.count >= 2 { return true }
            resto = resto[r.upperBound...]
        }
        return false
    }

    /// ADR 06h (volta A-B): a mesma guarda vista de FORA do laço. `Sessao`
    /// precisa dela para calar o modelo — a proteção não pode valer só no
    /// caminho puramente regex.
    static func escritaPessoal(texto: String, campos: [String: String]) -> Bool {
        let bruto = Caderno.prosa(de: texto).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bruto.isEmpty else { return false }
        let voz = VozDoAutor.juntar(texto: bruto, campos: campos)
        return eEscritaPessoal(voz, voz.lowercased())
    }

    /// Roteia pela regex do CATÁLOGO (ADR 04l), na ordem do catálogo. Três
    /// regras continuam em código porque não são regex: a expressiva pede
    /// texto longo além das palavras de sentimento, o Destaque é uma lista de
    /// linhas curtas sem palavra nenhuma, e a escrita pessoal não é matéria de
    /// exercício (ADR 06h) — nenhum método leva um texto em que o autor está
    /// falando do que sentiu, do que ele é, ou do que fez e lamenta.
    private static func detectarGesto(_ x: String, _ lower: String, estrito: Bool) -> Gesto? {
        let pessoal = eEscritaPessoal(x, lower)
        for m in Catalogo.todos where !m.roteamento.isEmpty {
            guard let g = Gesto(rawValue: m.id) else { continue }
            if g == .expressiva, x.count <= tetoDoDesabafo { continue }
            // A guarda não depende mais da POSIÇÃO no catálogo: o revisor
            // mediu 15 de 20 desabafos vestidos pelos cinco métodos que vinham
            // ANTES da Expressiva. Escrita pessoal só tem uma porta.
            if pessoal, g != .expressiva { continue }
            if m.roteamento.contains(where: { lower.contains(regex: $0) }) { return g }
        }
        if estrito { return nil }
        // o rodapé do Destaque fecha a mesma função e obedece o mesmo cálculo:
        // três linhas curtas de desabafo não são uma lista para destacar.
        guard !pessoal else { return nil }
        // `whereSeparator`: em CRLF isto contava UMA linha e o `>= 3` nunca era
        // verdade, então o Destaque não pegava nota vinda de fora.
        let linhas = x.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if linhas.count >= 3 && linhas.allSatisfy({ $0.count < 60 }) && !listaSemDia(x) {
            return .destaque
        }
        return nil
    }

    /// Dono, 17/09: «Comprar / Leite , farinha , ovo» abriu o campo «A única
    /// coisa de hoje». Uma lista de compras ou de itens — cabeça «Comprar»,
    /// «Compras do mês», «Mercado», «Lista de…», ou uma linha de itens
    /// separados por vírgula — sem sinal de dia não é o Destaque, nem pelas
    /// linhas curtas nem pelo modelo (`Sessao.escolher`). O plano do dia
    /// («hoje», «amanhã», «dia», «única», «primeiro») continua sendo.
    /// ponytail: palavras fixas; «arroz / feijão / café» sem cabeça ainda veste
    /// Destaque — separar substantivo de afazer pede o modelo, não mais regex.
    nonisolated static func listaSemDia(_ voz: String) -> Bool {
        let dobrada = voz.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
        if dobrada.contains(regex: #"\b(hoje|amanha|dia|unica|primeir[oa])\b"#) { return false }
        let linhas = dobrada.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard let cabeca = linhas.first else { return false }
        return cabeca.contains(regex: #"^(comprar|compras|mercado|supermercado|feira|lista)(\s+(de|do|da|dos|das|pra|para)\b.*)?$"#)
            || linhas.contains { Caderno.itensDaEnumeracao($0) != nil }
    }

    /// A pergunta é sempre do template — nunca do modelo (§19.4).
    nonisolated static func pergunta(_ gesto: Gesto) -> String {
        gesto.metodoDef.pergunta
    }
}

extension String {
    nonisolated func contains(regex pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
}
