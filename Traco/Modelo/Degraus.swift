import Foundation

/// Degraus para tudo (ADR 2026-09-04j). Só a escada do Recordar era
/// adaptativa; o resto do app dava o mesmo estímulo à mente que melhora.
/// Aqui o algoritmo decide o degrau — nunca o modelo (ADR 03i).
nonisolated enum Degraus {
    /// O degrau da instigação para uma forma: quantas notas dela o autor já
    /// concluiu. 0 · 1–2 · 3–5 · 6–10 · 11+ → 0..4.
    nonisolated static func instigar(concluidas: Int) -> Int {
        switch concluidas {
        case ..<1: 0
        case 1...2: 1
        case 3...5: 2
        case 6...10: 3
        default: 4
        }
    }

    /// ADR 04x: a prática mais o que o autor disse das duas últimas perguntas
    /// desta forma — dois "não serviu" descem um degrau, dois "serviu" sobem.
    nonisolated static func instigar(_ forma: Gesto, sinais: [Sinal]) -> Int {
        let base = instigar(concluidas: concluidas(forma, sinais: sinais))
        return max(0, min(4, base + ajuste(forma, sinais: sinais)))
    }

    nonisolated static func ajuste(_ forma: Gesto, sinais: [Sinal]) -> Int {
        let ultimos = sinais.filter { $0.tipo == .pergunta && $0.forma == forma.rawValue }
            .suffix(2).compactMap(\.serviu)
        guard ultimos.count == 2 else { return 0 }
        if ultimos.allSatisfy({ !$0 }) { return -1 }
        if ultimos.allSatisfy({ $0 }) { return 1 }
        return 0
    }

    /// O que cobrar em cada degrau — vai nas INSTRUÇÕES da instigação (ADR
    /// 2026-09-09i), nunca ao lado do rascunho. E vai escrito no mundo de quem
    /// escreve. A medida de 09/09 mostrou o outro lado: a instrução CHEGA
    /// (a sonda passa o degrau, e ele entra na mensagem de sistema), mas as
    /// respostas do 4 repetiam as do 0 — porque cada nível dizia só o que
    /// cobrar, e a cobrança fácil servia para todos. Agora cada nível também
    /// diz o que NÃO conta como cumprido, que é a diferença que se vê na tela.
    /// A redação anterior nomeava a nossa máquina ("DEGRAU 0", "nesta
    /// forma", "o MOVIMENTO básico do método", "o passo que se pula") e a
    /// medida de 08/09 viu essas palavras voltarem como ASSUNTO da pergunta —
    /// "Qual é o movimento básico que se pula?" para um autor que escreveu
    /// sobre praticar espanhol. O degrau muda o que se cobra; ele não é o
    /// assunto, e por isso não tem mais nome citável aqui.
    nonisolated static func instrucaoDeInstigar(_ degrau: Int) -> String {
        switch max(0, min(4, degrau)) {
        case 0: "Pergunte sobre o que o texto trata como resolvido sem ter resolvido."
        case 1: "Pergunte se duas coisas escritas no texto se contradizem ou dependem uma da outra. Perguntar o que cada uma significa, isolada, NÃO cumpre isto."
        case 2: "Pergunte de onde vem o que o texto afirma e o que mostraria o contrário. Perguntar o que quis dizer ou o que vai fazer NÃO cumpre isto."
        case 3: "Pergunte o que se perde se o que o texto afirma não se confirmar, e para que lado essa avaliação costuma errar. Perguntar se vai dar certo NÃO cumpre isto."
        default: "Pergunte em que caso aquilo de que tudo ali depende deixa de valer, e o que se veria acontecer se não valesse. Perguntar o que quis dizer, o que vai fazer com o que tem, ou o que pode dar errado, NÃO cumpre isto."
        }
    }

    /// Quantas notas concluídas de uma forma.
    nonisolated static func concluidas(_ forma: Gesto, sinais: [Sinal]) -> Int {
        sinais.filter { $0.tipo == .ficou && $0.forma == forma.rawValue }.count
    }

    /// O degrau na língua de quem escreve (auditoria 17/09: «degrau 2» era
    /// termo interno): o que a pergunta cobra naquele nível.
    nonisolated static func emPalavras(degrau: Int) -> String {
        switch max(0, min(4, degrau)) {
        case 0: "pergunta pelo básico"
        case 1: "pergunta como as ideias se ligam"
        case 2: "pergunta pela evidência"
        case 3: "pergunta pelo custo de errar"
        default: "pergunta onde deixa de valer"
        }
    }

    /// Para o Perfil: o degrau de cada forma em que há sinal, em uma linha.
    /// Vazio sem sinal nenhum.
    nonisolated static func emPalavras(sinais: [Sinal]) -> String {
        let formas = Gesto.allCases.filter { g in
            g != .expressiva && sinais.contains { $0.forma == g.rawValue && ($0.tipo == .ficou || $0.tipo == .pergunta) }
        }
        guard !formas.isEmpty else { return "" }
        return formas.map { g in
            let a = ajuste(g, sinais: sinais)
            let nota = a < 0 ? " (desceu: duas perguntas não serviram)" : a > 0 ? " (subiu: duas perguntas serviram)" : ""
            return "\(g.nome): \(emPalavras(degrau: instigar(g, sinais: sinais)))\(nota)"
        }.joined(separator: " · ") + "."
    }
}
