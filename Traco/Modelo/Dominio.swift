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

    nonisolated var nome: String {
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
    nonisolated static func inferir(voz: String) -> Dominio? {
        let lower = voz.lowercased()
        let pontos: [(Dominio, [String])] = [
            (.trabalho, ["reunião", "reuniao", "cliente", "deploy", "prazo", "sprint",
                         "chefe", "colega", "escritório", "escritorio", "standup", "slack",
                         "entrevista", "apresentação", "apresentacao", "call"]),
            (.casa, ["casa", "aluguel", "faxina", "geladeira", "cozinha", "quarto",
                     "reforma", "vizinho", "condomínio", "condominio", "mercado", "feira",
                     "mudança", "mudanca", "encanador", "eletricista"]),
            (.saude, ["consulta", "dor", "remédio", "remedio", "médico", "medico",
                      "sono", "ansiedade", "terapia", "exame", "hospital", "dentista",
                      "academia", "treino", "corrida", "yoga", "nutricionista", "fisioterapia"]),
            (.dinheiro, ["dinheiro", "conta", "boleto", "salário", "salario", "imposto",
                         "investimento", "dívida", "divida", "cartão", "cartao", "banco"]),
            (.pessoas, ["mãe", "mae", "pai", "filho", "filha", "amigo", "amiga",
                        "namoro", "casamento", "família", "familia", "almoço", "almoco", "jantar",
                        "aniversário", "aniversario", "visita", "encontro"]),
            (.estudo, ["estudo", "aula", "prova", "curso", "ler", "livro", "aprender",
                       "dissertação", "dissertacao", "faculdade", "palestra", "workshop"]),
            (.ideias, ["ideia", "insight", "percebi", "hipótese", "hipotese", "conceito"]),
        ]
        var melhor: (Dominio, Int)?
        var empatou = false
        for (dom, palavras) in pontos {
            // palavra inteira: "casamento" não é Casa, "encontrar" não é Dinheiro
            let n = palavras.filter { p in
                lower.range(of: "\\b\(NSRegularExpression.escapedPattern(for: p))\\b",
                            options: .regularExpression) != nil
            }.count
            guard n > 0 else { continue }
            if n > (melhor?.1 ?? 0) { melhor = (dom, n); empatou = false }
            else if n == melhor?.1 { empatou = true }
        }
        // ADR 05d: empate é silêncio — "chegar em casa … vou ler" não é Casa
        // por vir antes de Estudo na lista. Sem confiança, sem chip.
        guard let melhor, !empatou else { return nil }
        return melhor.0
    }

    /// ADR 05d: o rótulo que o modelo de bordo devolveu. "nenhum" = sem
    /// domínio; qualquer outra coisa fora da lista = nil (falha, fica o léxico).
    nonisolated static func doModelo(_ rotulo: String) -> Dominio?? {
        let limpo = rotulo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if limpo == "nenhum" { return .some(nil) }
        guard let d = Dominio(rawValue: limpo) else { return nil }
        return .some(d)
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

/// Lê hora ou período no campo "Se" / plano. Determinístico.
enum Gatilho: Sendable {
    nonisolated static func data(em texto: String, agora: Date = .now) -> Date? {
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty else { return nil }
        // Hora em português primeiro: o detector, em locale inglês, lê "8h" como 20h.
        if let hm = horaEscrita(limpo) {
            return proximaHora(hm, aPartirDe: agora)
        }
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let alcance = NSRange(limpo.startIndex..., in: limpo)
        let hit = detector?.firstMatch(in: limpo, options: [], range: alcance)
        if let data = hit?.date {
            if data > agora.addingTimeInterval(-60) { return data }
            // Hora de hoje já passou: a intenção é a próxima vez, não o silêncio.
            if Calendar.current.isDate(data, inSameDayAs: agora) {
                return Calendar.current.date(byAdding: .day, value: 1, to: data)
            }
        }
        if let ancora = Ancora.doPeriodo(limpo) {
            return Self.proxima(ancora, aPartirDe: agora)
        }
        return nil
    }

    /// "às 8", "as 8h", "14h30" — o detector falha em locale inglês.
    nonisolated static func horaEscrita(_ texto: String) -> DateComponents? {
        let lower = texto.lowercased()
        let padroes = [
            #"(?:às?|as)\s*(\d{1,2})h(\d{2})?"#,
            #"(?:às?|as)\s*(\d{1,2}):(\d{2})"#,
            #"às\s*(\d{1,2})\b"#,
            #"(\d{1,2})h(\d{2})?"#,
        ]
        for p in padroes {
            guard let re = try? NSRegularExpression(pattern: p),
                  let m = re.firstMatch(in: lower, range: NSRange(lower.startIndex..., in: lower)),
                  let r1 = Range(m.range(at: 1), in: lower),
                  let h = Int(lower[r1]), (0...23).contains(h)
            else { continue }
            var minuto = 0
            if m.numberOfRanges > 2, m.range(at: 2).location != NSNotFound,
               let r2 = Range(m.range(at: 2), in: lower) {
                guard let mm = Int(lower[r2]), (0...59).contains(mm) else { continue }
                minuto = mm
            }
            var c = DateComponents()
            c.hour = h
            c.minute = minuto
            return c
        }
        return nil
    }

    nonisolated static func proximaHora(_ hm: DateComponents, aPartirDe agora: Date) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: agora)
        comps.hour = hm.hour
        comps.minute = hm.minute ?? 0
        comps.second = 0
        let hoje = Calendar.current.date(from: comps) ?? agora
        if hoje > agora.addingTimeInterval(-60) { return hoje }
        return Calendar.current.date(byAdding: .day, value: 1, to: hoje) ?? hoje.addingTimeInterval(86400)
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
