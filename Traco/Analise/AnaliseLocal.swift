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
    nonisolated static let avisoWood = "Afirmação sem prova não gruda. O que aconteceu que fez você escrever isso?"
    nonisolated static let avisoOuvinte = "Quem é a pessoa de verdade que deveria ouvir isto?"
    nonisolated static let avisoOettingen = "Falta o obstáculo. O que, em você, costuma atrapalhar isto?"
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

    /// Roteia pela regex do CATÁLOGO (ADR 04l), na ordem do catálogo. Duas
    /// regras continuam em código porque não são regex: a expressiva pede
    /// texto longo além das palavras de sentimento, e o Destaque é uma lista
    /// de linhas curtas sem palavra nenhuma.
    private static func detectarGesto(_ x: String, _ lower: String, estrito: Bool) -> Gesto? {
        for m in Catalogo.todos where !m.roteamento.isEmpty {
            guard let g = Gesto(rawValue: m.id) else { continue }
            if g == .expressiva, x.count <= 120 { continue }
            if m.roteamento.contains(where: { lower.contains(regex: $0) }) { return g }
        }
        if estrito { return nil }
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
