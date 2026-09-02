import Foundation

/// Eixo transversal às formas (COLHEITA · TickTick). Inferido, nunca arquivado
/// à mão. Um toque no chip troca ou tira. Expressiva não é classificada.
enum Dominio: String, CaseIterable, Codable, Identifiable, Sendable {
    case trabalho
    case casa
    case saude
    case dinheiro
    case pessoas
    case estudo
    case ideias

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .trabalho: "Trabalho"
        case .casa: "Casa"
        case .saude: "Saúde"
        case .dinheiro: "Dinheiro"
        case .pessoas: "Pessoas"
        case .estudo: "Estudo"
        case .ideias: "Ideias"
        }
    }

    /// Léxico local primeiro. Sem confiança = silêncio. Rótulo fora da lista = nenhum.
    static func inferir(voz: String) -> Dominio? {
        let lower = voz.lowercased()
        let pontos: [(Dominio, [String])] = [
            (.trabalho, ["reunião", "reuniao", "cliente", "deploy", "prazo", "sprint",
                         "chefe", "colega", "escritório", "escritorio", "standup", "slack"]),
            (.casa, ["casa", "aluguel", "faxina", "geladeira", "cozinha", "quarto",
                     "reforma", "vizinho", "condomínio", "condominio"]),
            (.saude, ["consulta", "dor", "remédio", "remedio", "médico", "medico",
                      "sono", "ansiedade", "terapia", "exame", "hospital"]),
            (.dinheiro, ["dinheiro", "conta", "boleto", "salário", "salario", "imposto",
                         "investimento", "dívida", "divida", "cartão", "cartao", "banco"]),
            (.pessoas, ["mãe", "mae", "pai", "filho", "filha", "amigo", "amiga",
                        "namoro", "casamento", "família", "familia"]),
            (.estudo, ["estudo", "aula", "prova", "curso", "ler", "livro", "aprender",
                       "dissertação", "dissertacao"]),
            (.ideias, ["ideia", "insight", "percebi", "hipótese", "hipotese", "conceito"]),
        ]
        var melhor: (Dominio, Int)?
        for (dom, palavras) in pontos {
            let n = palavras.filter { lower.contains($0) }.count
            if n > 0, n >= (melhor?.1 ?? 0) { melhor = (dom, n) }
        }
        guard let melhor, melhor.1 >= 1 else { return nil }
        return melhor.0
    }

    static func doNome(_ s: String) -> Dominio? {
        let alvo = s.trimmingCharacters(in: .whitespaces)
        return Dominio(rawValue: alvo.lowercased())
            ?? allCases.first { $0.nome.caseInsensitiveCompare(alvo) == .orderedSame }
    }
}

enum Ancora: String, CaseIterable, Codable, Sendable {
    case manha, tarde, noite

    nonisolated var nome: String {
        switch self {
        case .manha: "manhã"
        case .tarde: "tarde"
        case .noite: "noite"
        }
    }

    /// Hora padrão; o autor ajusta uma vez no Perfil.
    nonisolated var horaPadrao: Int {
        switch self {
        case .manha: 8
        case .tarde: 14
        case .noite: 21
        }
    }

    nonisolated static func hora(_ ancora: Ancora) -> Int {
        let chave = "ancora-\(ancora.rawValue)"
        let v = UserDefaults.standard.object(forKey: chave) as? Int
        return v ?? ancora.horaPadrao
    }

    nonisolated static func gravar(_ ancora: Ancora, hora: Int) {
        UserDefaults.standard.set(max(0, min(23, hora)), forKey: "ancora-\(ancora.rawValue)")
    }

    nonisolated static func doPeriodo(_ texto: String) -> Ancora? {
        let lower = texto.lowercased()
        if lower.contains(regex: #"de manh[ãa]|pela manh[ãa]|ao acordar"#) { return .manha }
        if lower.contains(regex: #"\btarde\b|depois do almo"#) { return .tarde }
        if lower.contains(regex: #"\bnoite\b|antes de dormir|ao deitar"#) { return .noite }
        return nil
    }
}

/// Lê hora ou período no campo "Se" / plano. Determinístico (NSDataDetector).
enum Gatilho: Sendable {
    nonisolated static func data(em texto: String, agora: Date = .now) -> Date? {
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty else { return nil }
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let alcance = NSRange(limpo.startIndex..., in: limpo)
        let hit = detector?.firstMatch(in: limpo, options: [], range: alcance)
        if let data = hit?.date, data > agora.addingTimeInterval(-60) { return data }
        if let ancora = Ancora.doPeriodo(limpo) {
            return Self.proxima(ancora, aPartirDe: agora)
        }
        return nil
    }

    nonisolated static func proxima(_ ancora: Ancora, aPartirDe agora: Date) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: agora)
        comps.hour = Ancora.hora(ancora)
        comps.minute = 0
        let hoje = Calendar.current.date(from: comps) ?? agora
        if hoje > agora { return hoje }
        return Calendar.current.date(byAdding: .day, value: 1, to: hoje) ?? hoje.addingTimeInterval(86400)
    }
}
