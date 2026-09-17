import Foundation

/// ADR 2026-09-12a — instigar não pergunta o que a nota já fechou.
/// A tesoura é LOCAL, depois do parse: o pedido vigente fica (a 2ª
/// redação que ensinou a não perguntar o fechado calou a nota magra).
/// A rota permanece cortada na Politica até remedição pareada.
nonisolated enum GuardaDeInstigar {
    enum Perna: String, CaseIterable, Sendable {
        case que, quando, darCerto, causa, criterio
    }

    /// Palpite de domínio que a nota não deu. A palavra DELA volta.
    static let dominioSuposto = [
        "projeto", "emprego", "curso", "namoro", "chefe", "socio",
        "contrato", "prejuizo", "margem", "tentativa anterior",
        "episodio de antes", "sua relacao",
    ]

    static func fechadas(_ texto: String) -> Set<Perna> {
        let t = Sabia.dobrada(texto)
        var s = Set<Perna>()
        if quandoFechado(t) { s.insert(.quando) }
        if darCertoFechado(t) { s.insert(.darCerto) }
        if causaFechada(t) { s.insert(.causa) }
        if queFechado(t) { s.insert(.que) }
        if criterioFechado(t) { s.insert(.criterio) }
        return s
    }

    static func cobra(_ pergunta: String, _ perna: Perna) -> Bool {
        let p = Sabia.dobrada(pergunta)
        switch perna {
        case .quando:
            return p.contains(regex: #"quando (comecou|aconteceu|foi|deu|ocorreu)"#)
                || p.contains(regex: #"que (dia|semana|momento|hora|data)\b"#)
                || p.contains(regex: #"em que (dia|semana|momento|hora)"#)
        case .darCerto:
            return p.contains(regex: #"que (seria|era|e) dar certo"#)
                || p.contains(regex: #"como (seria|era) dar certo"#)
        case .causa:
            return p.contains(regex: #"(qual|que) (foi |e )?a causa"#)
                || p.contains(regex: #"o que causou"#)
                || p.contains(regex: #"por que (comecou|aconteceu|foi)"#)
                || p.contains(regex: #"por causa de (que|quem)"#)
                || p.contains(regex: #"qual foi o motivo"#)
        case .criterio:
            return p.contains("criterio")
        case .que:
            return p.contains(regex: #"o que aconteceu"#)
                || p.contains(regex: #"o que foi que aconteceu"#)
                || p.contains(regex: #"do que .{0,24}desist"#)
                || p.contains(regex: #"de que .{0,24}desist"#)
                || p.contains(regex: #"o que deu (errado|certo)"#)
        }
    }

    static func filtrar(_ perguntas: [String], texto: String) -> [String] {
        let fechou = fechadas(texto)
        return perguntas.filter { p in
            if fechou.contains(where: { cobra(p, $0) }) { return false }
            if Sabia.vazaAlheio(p, termos: dominioSuposto, texto: texto) { return false }
            return true
        }
    }

    private static func quandoFechado(_ t: String) -> Bool {
        t.contains(regex: #"nao (consigo|sei)( dizer)? quando"#)
            || t.contains(regex: #"\b(ontem|anteontem)\b"#)
    }

    private static func darCertoFechado(_ t: String) -> Bool {
        t.contains(regex: #"(nem|nao) sei o que (seria|era|e) dar certo"#)
            || t.contains(regex: #"dar certo.{0,48}seria"#)
    }

    /// E8 volta 4: a nota que dá a razão já deu o critério — perguntar «que critério separa…»
    /// é pergunta respondida. Medido no bruto v2+v3: tira 6, 5 reprovadas por isso e 1 aprovada;
    /// sem a razão na nota (sala × casa), o critério é a pergunta certa e fica.
    private static func criterioFechado(_ t: String) -> Bool {
        t.contains(regex: #"\b(porque|pois|ja que|criterio)\b"#) || t.contains("por causa d")
    }

    private static func causaFechada(_ t: String) -> Bool {
        t.contains(regex: #"nao foi por causa"#)
            || t.contains(regex: #"nao foi por nada"#)
            || t.contains(regex: #"sem causa"#)
    }

    /// O quê só fecha quando ela nomeou o ato com objeto. «Desisti.» e
    /// «Não deu certo de novo.» deixam a perna aberta — calá-los é o
    /// defeito da 2ª redação.
    private static func queFechado(_ t: String) -> Bool {
        t.contains(regex: #"\b(mandei|enviei|liguei|escrevi|publiquei|aceitei|pedi|marquei|entreguei)\s+\w{3,}"#)
    }
}
