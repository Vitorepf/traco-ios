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

    nonisolated static let avisoFrasePronta = "A frase aqui é sua. O Traço não escreve."
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

        if lower.contains(regex: #"escrev[ae] (por|pra|para) mim|melhore|reescreva|resuma"#) {
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
    /// 1. o estado, por RADICAL — qualquer flexão da mesma palavra.
    static let lexicoDoSentimento = #"senti|sinto|dói|doeu|chor(ei|ar|ando|o)|trist|raiva|medo|\bpesa|desmoron|arrepend|vergonh|mago[aeiou]|remoend|\btravei\b|\beu travo\b|angusti|ansios|exaust|vazi[oa]|sozinh|cansad|desanimad|humilhad|culpad|nó na garganta"#

    /// 2. o juízo sobre si — o autor dizendo o que ELE é, ou o que ELE
    /// estragou. Vale em qualquer tamanho: "eu sou o problema" não fica menos
    /// pessoal em oitenta caracteres.
    static let lexicoDoJuizoSobreSi = #"me (odi|culp|detest|despre)|n[ãa]o (sirvo|presto|valho)|sou (o|um|uma) (problema|lixo|fracasso|idiota|péssim|merda)|a culpa (é|foi) minha|estraguei|me sentindo (um|uma)"#

    /// 3. o funcionamento básico negado — dormir, comer, rir, aguentar. É o
    /// desabafo que não usa nenhuma palavra de sentimento e mesmo assim só
    /// fala de si.
    static let lexicoDoNaoAguento = #"n[ãa]o (durmo|consigo dormir|como mais|rio|aguento|tenho vontade|saio da cama|consigo mais)"#

    /// 4. o que eu fiz A ALGUÉM, em QUALQUER tamanho. O teto de 120 era a
    /// régua errada aqui: contar que se foi grosso com o irmão é desabafo com
    /// noventa caracteres tanto quanto com quatrocentos.
    static let lexicoDoAtoContraAlguem = #"fui (injust|gross|duro demais|ríspid)|perdi a (paciência|cabeça)|tratei mal|briguei|discuti com|gritei com|xinguei|explodi com|descontei (com|n[oa])"#

    /// 5. o que eu DEIXEI de fazer — e este sim só ACIMA do teto: curta,
    /// "fiquei calada quando perguntaram" é a nota que nomeia uma conversa, e o
    /// método que pergunta serve; longa, é o dia sendo despejado.
    static let lexicoDaOmissao = #"engoli|fiquei calad|deixei passar|não devia ter"#

    /// ADR 06h — a fronteira do produto, em código e não no `Metodos.json`: a
    /// pasta do autor reescreve o catálogo, e uma guarda que protege a escrita
    /// pessoal não pode morar num arquivo editável.
    static func eEscritaPessoal(_ x: String, _ lower: String) -> Bool {
        if lower.contains(regex: lexicoDoSentimento) { return true }
        if lower.contains(regex: lexicoDoJuizoSobreSi) { return true }
        if lower.contains(regex: lexicoDoNaoAguento) { return true }
        if lower.contains(regex: lexicoDoAtoContraAlguem) { return true }
        return x.count > tetoDoDesabafo && lower.contains(regex: lexicoDaOmissao)
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
        let linhas = x.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if linhas.count >= 3 && linhas.allSatisfy({ $0.count < 60 }) {
            return .destaque
        }
        return nil
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
