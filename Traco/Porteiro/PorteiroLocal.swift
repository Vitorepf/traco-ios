import Foundation

/// Porteiro do app. Roda só no aparelho.
/// Nunca chama api.x.ai, nunca gasta crédito Super, nunca paga token.
enum PorteiroLocal: Sendable {
    enum Veredito: Equatable {
        case silencio
        case trava(String)
        case gesto(Gesto, pergunta: String)
        case expressiva
    }

    static let travaFrasePronta = "A frase aqui é sua. O porteiro não escreve."
    static let travaWood = "Afirmação vazia não muda nada — e pesa em quem se estima pouco. Escreva por que um valor seu importa."
    static let travaOuvinte = "Quem é a pessoa de verdade que deveria receber isto? O porteiro não é ouvinte."
    static let travaOettingen = "Sem o obstáculo interno, isso é fantasia — e fantasia reduz o esforço. Qual é o seu?"
    static let travaDoisGestos = "Um gesto por sessão. O segundo método vai para outra página."
    static let perguntaWOOP = "Qual é o hábito ou o medo seu que vai impedir — não o relógio, não os outros?"

    static func classificar(texto: String, gestoAtual: Gesto?, campos: [String: String]) -> Veredito {
        let bruto = Caderno.prosa(de: texto).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bruto.isEmpty else { return .silencio }

        let voz = VozDoAutor.juntar(texto: bruto, campos: campos)
        let lower = voz.lowercased()

        if lower.contains(regex: #"escrev[ae] (por|pra|para) mim|melhore|reescreva|resuma"#) {
            return .trava(travaFrasePronta)
        }
        if lower.contains(regex: #"eu sou (rico|um vencedor|incrível|o melhor|imparável)"#) {
            return .trava(travaWood)
        }
        if lower.contains(regex: #"me escuta|me console|desabafar com você|preciso falar com alguém"#) {
            return .trava(travaOuvinte)
        }

        if let gestoAtual {
            let posForma = campos.values
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
            if let novo = detectarGesto(posForma, posForma.lowercased(), estrito: true),
               novo != .expressiva || gestoAtual != .expressiva,
               novo != gestoAtual {
                return .trava(travaDoisGestos)
            }
            return .silencio
        }

        if let gesto = detectarGesto(voz, lower, estrito: false) {
            if gesto == .expressiva { return .expressiva }
            return .gesto(gesto, pergunta: pergunta(gesto))
        }

        if ePlanoSemObstaculo(lower) {
            return .trava(travaOettingen)
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

    private static func detectarGesto(_ x: String, _ lower: String, estrito: Bool) -> Gesto? {
        if x.count > 120 && lower.contains(regex: #"senti|sinto|dói|doeu|medo|triste|raiva|chorei|pesado|desmoronar"#) {
            return .expressiva
        }
        if lower.contains(regex: #"(?m)^quero|^preciso começar|^preciso parar|meu objetivo|quero parar"#) {
            return .woop
        }
        if lower.contains(regex: #"sempre que|toda vez|não consigo parar"#) {
            return .seEntao
        }
        if lower.contains(regex: #"\b(feature|sistema|api|tela|site|função|app|módulo|construir)\b"#) {
            return .spec
        }
        if lower.contains(regex: #"percebi|entendi que|ideia|insight"#) {
            return .notaPermanente
        }
        if estrito { return nil }
        let linhas = x.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if linhas.count >= 3 && linhas.allSatisfy({ $0.count < 60 }) {
            return .destaque
        }
        return nil
    }

    private static func pergunta(_ gesto: Gesto) -> String {
        switch gesto {
        case .woop: perguntaWOOP
        case .seEntao: "Quando o gatilho vier, você faz o quê — concreto, substituto?"
        case .spec: "O que fica explicitamente de fora desta rodada?"
        case .notaPermanente: "Nas suas palavras: qual é a UMA ideia?"
        case .destaque: "Qual é a única de hoje — primeiro, até acabar?"
        case .expressiva: ""
        }
    }
}

extension String {
    func contains(regex pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
}
