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

    /// O que cobrar em cada degrau — vai no pedido, como na prova (ADR 03i).
    nonisolated static func instrucaoDeInstigar(_ degrau: Int) -> String {
        switch max(0, min(4, degrau)) {
        case 0: "DEGRAU 0 — primeira vez nesta forma. Cobre o MOVIMENTO básico do método: o passo que se pula."
        case 1: "DEGRAU 1 — já usou esta forma. Cobre a RELAÇÃO entre dois campos: um contradiz o outro? um depende do outro?"
        case 2: "DEGRAU 2 — usa esta forma com frequência. Cobre a EVIDÊNCIA: como ele sabe o que escreveu? o que provaria o contrário?"
        case 3: "DEGRAU 3 — veterano nesta forma. Cobre o CUSTO de errar: o que perde se estiver enganado, e para que lado costuma errar."
        default: "DEGRAU 4 — domina esta forma. Cobre o LIMITE do próprio método: onde ele deixa de servir a este caso, o que ele esconde."
        }
    }

    /// Quantas notas concluídas de uma forma.
    nonisolated static func concluidas(_ forma: Gesto, sinais: [Sinal]) -> Int {
        sinais.filter { $0.tipo == .ficou && $0.forma == forma.rawValue }.count
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
            return "\(g.nome) no degrau \(instigar(g, sinais: sinais))\(nota)"
        }.joined(separator: " · ") + "."
    }
}
