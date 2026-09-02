import Foundation

/// As quatro distâncias do clone: o dia âncora não muda ao zoomar.
nonisolated enum EscalaCalendario: String, CaseIterable, Sendable {
    case dia, semana, mes, ano

    var letra: String {
        switch self {
        case .dia: "D"
        case .semana: "W"
        case .mes: "M"
        case .ano: "Y"
        }
    }
}

nonisolated enum ModoCalendario: String, Sendable {
    case lista, grelha
}

nonisolated enum CategoriaEvento: String, Codable, Sendable, CaseIterable {
    case trabalho, corpo, social, casa, outro
}

nonisolated struct EventoCalendario: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var titulo: String
    var inicio: Date
    var fim: Date
    var categoria: CategoriaEvento
    var notas: String
    var diaInteiro: Bool

    init(
        id: UUID = UUID(),
        titulo: String,
        inicio: Date,
        fim: Date,
        categoria: CategoriaEvento = .outro,
        notas: String = "",
        diaInteiro: Bool = false
    ) {
        self.id = id
        self.titulo = titulo
        self.inicio = inicio
        self.fim = fim
        self.categoria = categoria
        self.notas = notas
        self.diaInteiro = diaInteiro
    }

    var duracaoMinutos: Int {
        max(0, Int(fim.timeIntervalSince(inicio) / 60))
    }
}

/// Matemática do calendário — `nonisolated` para os testes e para o parse.
nonisolated enum Calendario {
    /// Marcas da semana do clone: sete barras, 03 às 21.
    static let horasDaSemana = [3, 6, 9, 12, 15, 18, 21]

    /// Domingo primeiro, nomes em inglês: o clone é S M T W T F S / 20 July.
    nonisolated static func gregoriano(fuso: TimeZone = .current) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_GB")
        cal.timeZone = fuso
        // locale en_GB começa na segunda; o clone é S M T W T F S.
        cal.firstWeekday = 1
        return cal
    }

    nonisolated static func inicioDoDia(_ data: Date, _ cal: Calendar) -> Date {
        cal.startOfDay(for: data)
    }

    nonisolated static func mesmoDia(_ a: Date, _ b: Date, _ cal: Calendar) -> Bool {
        cal.isDate(a, inSameDayAs: b)
    }

    /// Os sete dias da semana que contém a âncora, domingo→sábado.
    nonisolated static func semana(da ancora: Date, _ cal: Calendar) -> [Date] {
        let dia = inicioDoDia(ancora, cal)
        let weekday = cal.component(.weekday, from: dia)
        let recuo = weekday - cal.firstWeekday
        let domingo = cal.date(byAdding: .day, value: -recuo, to: dia) ?? dia
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: domingo) }
    }

    /// 42 células (6×7): o mês e as sobras do anterior/seguinte.
    nonisolated static func grelhaDoMes(da ancora: Date, _ cal: Calendar) -> [Date] {
        let dia = inicioDoDia(ancora, cal)
        let comps = cal.dateComponents([.year, .month], from: dia)
        guard let primeiro = cal.date(from: comps) else { return [] }
        return semana(da: primeiro, cal)
            .first
            .map { inicio in (0..<42).compactMap { cal.date(byAdding: .day, value: $0, to: inicio) } }
            ?? []
    }

    /// O primeiro dia de cada mês do ano da âncora.
    nonisolated static func mesesDoAno(da ancora: Date, _ cal: Calendar) -> [Date] {
        let ano = cal.component(.year, from: ancora)
        return (1...12).compactMap { mes in
            cal.date(from: DateComponents(year: ano, month: mes, day: 1))
        }
    }

    nonisolated static func titulo(escala: EscalaCalendario, ancora: Date, _ cal: Calendar) -> String {
        switch escala {
        case .dia:
            return formatar(ancora, "d MMMM", cal)
        case .semana:
            let dias = semana(da: ancora, cal)
            guard let primeiro = dias.first, let ultimo = dias.last else { return "" }
            if cal.component(.month, from: primeiro) == cal.component(.month, from: ultimo) {
                return "\(formatar(primeiro, "d", cal)) – \(formatar(ultimo, "d MMMM", cal))"
            }
            return "\(formatar(primeiro, "d MMM", cal)) – \(formatar(ultimo, "d MMM", cal))"
        case .mes:
            return formatar(ancora, "MMMM yyyy", cal)
        case .ano:
            return formatar(ancora, "yyyy", cal)
        }
    }

    nonisolated static func letraDoDia(_ data: Date, _ cal: Calendar) -> String {
        formatar(data, "EEEEE", cal)
    }

    nonisolated static func formatar(_ data: Date, _ formato: String, _ cal: Calendar) -> String {
        let f = DateFormatter()
        f.calendar = cal
        f.locale = cal.locale
        f.timeZone = cal.timeZone
        f.dateFormat = formato
        return f.string(from: data)
    }

    nonisolated static func eventos(
        _ todos: [EventoCalendario],
        noDia dia: Date,
        _ cal: Calendar
    ) -> [EventoCalendario] {
        todos
            .filter { mesmoDia($0.inicio, dia, cal) }
            .sorted { $0.inicio < $1.inicio }
    }

    nonisolated static func eventos(
        _ todos: [EventoCalendario],
        naSemanaDe ancora: Date,
        _ cal: Calendar
    ) -> [EventoCalendario] {
        let dias = Set(semana(da: ancora, cal).map { inicioDoDia($0, cal) })
        return todos
            .filter { dias.contains(inicioDoDia($0.inicio, cal)) }
            .sorted { $0.inicio < $1.inicio }
    }

    nonisolated static func eventos(
        _ todos: [EventoCalendario],
        noMesDe ancora: Date,
        _ cal: Calendar
    ) -> [EventoCalendario] {
        let mes = cal.component(.month, from: ancora)
        let ano = cal.component(.year, from: ancora)
        return todos
            .filter {
                cal.component(.month, from: $0.inicio) == mes
                    && cal.component(.year, from: $0.inicio) == ano
            }
            .sorted { $0.inicio < $1.inicio }
    }

    /// Mudar a escala NUNCA move a âncora — o dia em que estás é o sítio.
    nonisolated static func ir(para escala: EscalaCalendario, ancora: Date) -> (EscalaCalendario, Date) {
        (escala, ancora)
    }

    /// Escolher um mês (ano → mês) guarda o dia: 2 Set → 2 Jan, não o dia 1.
    /// No próprio mês a âncora não mexe. Fevereiro come o 31.
    nonisolated static func noMes(_ mes: Date, preservando ancora: Date, _ cal: Calendar) -> Date {
        if mesmoMes(mes, ancora, cal) { return inicioDoDia(ancora, cal) }
        let dia = cal.component(.day, from: ancora)
        let teto = cal.range(of: .day, in: .month, for: mes)?.count ?? dia
        var comps = cal.dateComponents([.year, .month], from: mes)
        comps.day = min(dia, teto)
        return inicioDoDia(cal.date(from: comps) ?? mes, cal)
    }

    nonisolated static func irHoje(agora: Date, _ cal: Calendar) -> Date {
        inicioDoDia(agora, cal)
    }

    nonisolated static func eHoje(_ data: Date, agora: Date, _ cal: Calendar) -> Bool {
        mesmoDia(data, agora, cal)
    }

    nonisolated static func mesmoMes(_ a: Date, _ b: Date, _ cal: Calendar) -> Bool {
        cal.component(.month, from: a) == cal.component(.month, from: b)
            && cal.component(.year, from: a) == cal.component(.year, from: b)
    }
}

/// Cria evento a partir de prosa — local, sem modelo. O clone pede inglês.
nonisolated enum CalendarioFrase {
    nonisolated static func ler(
        _ prosa: String,
        ancora: Date,
        agora: Date,
        _ cal: Calendar
    ) -> EventoCalendario? {
        let limpo = prosa.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty else { return nil }

        var resto = limpo
        var dia = Calendario.inicioDoDia(ancora, cal)
        var inicioMinutos = 9 * 60
        var duracao = 30
        var diaInteiro = false

        if let (d, r) = comerDia(resto, ancora: ancora, agora: agora, cal) {
            dia = d
            resto = r
        }
        if let (i, d, r, todo) = comerHora(resto) {
            inicioMinutos = i
            duracao = d
            resto = r
            diaInteiro = todo
        }

        let titulo = resto
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: " ,.-"))
        guard !titulo.isEmpty else { return nil }

        let inicio = cal.date(byAdding: .minute, value: inicioMinutos, to: dia) ?? dia
        let fim = cal.date(byAdding: .minute, value: duracao, to: inicio) ?? inicio
        return EventoCalendario(
            titulo: titulo,
            inicio: inicio,
            fim: fim,
            categoria: categoria(de: titulo),
            diaInteiro: diaInteiro
        )
    }

    nonisolated private static func comerDia(
        _ texto: String,
        ancora: Date,
        agora: Date,
        _ cal: Calendar
    ) -> (Date, String)? {
        let baixo = texto.lowercased()
        let hoje = Calendario.inicioDoDia(agora, cal)
        let pares: [(String, Date)] = [
            ("today", hoje),
            ("tomorrow", cal.date(byAdding: .day, value: 1, to: hoje) ?? hoje),
            ("monday", proximo(.monday, aPartir: ancora, cal)),
            ("tuesday", proximo(.tuesday, aPartir: ancora, cal)),
            ("wednesday", proximo(.wednesday, aPartir: ancora, cal)),
            ("thursday", proximo(.thursday, aPartir: ancora, cal)),
            ("friday", proximo(.friday, aPartir: ancora, cal)),
            ("saturday", proximo(.saturday, aPartir: ancora, cal)),
            ("sunday", proximo(.sunday, aPartir: ancora, cal)),
        ]
        for (palavra, data) in pares {
            if let r = cortar(palavra, de: baixo, original: texto) {
                return (data, r)
            }
        }
        return nil
    }

    nonisolated private static func proximo(
        _ weekday: Weekday,
        aPartir de: Date,
        _ cal: Calendar
    ) -> Date {
        let dia = Calendario.inicioDoDia(de, cal)
        let alvo = weekday.rawValue
        let actual = cal.component(.weekday, from: dia)
        var delta = alvo - actual
        if delta < 0 { delta += 7 }
        return cal.date(byAdding: .day, value: delta, to: dia) ?? dia
    }

    /// Sunday=1 … Saturday=7, igual ao Gregorian.
    private enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }

    nonisolated private static func comerHora(_ texto: String) -> (Int, Int, String, Bool)? {
        let baixo = texto.lowercased()
        if baixo.contains("all day") || baixo.contains("all-day") {
            let r = texto.replacingOccurrences(of: #"(?i)\s*all[-\s]?day\s*"#, with: " ", options: .regularExpression)
            return (0, 24 * 60, r, true)
        }

        let padroes: [(NSRegularExpression, (NSTextCheckingResult, String) -> (Int, Int, String)?)] = [
            // 16:30-17:00 ou 16:30 – 17:00
            (
                try! NSRegularExpression(pattern: #"\b(\d{1,2})[:.](\d{2})\s*[–\-]\s*(\d{1,2})[:.](\d{2})\b"#),
                { m, s in
                    let a = minutos(hora: grupo(m, 1, s), minuto: grupo(m, 2, s), pm: false, meridio: false)
                    let b = minutos(hora: grupo(m, 3, s), minuto: grupo(m, 4, s), pm: false, meridio: false)
                    return (a, max(15, b - a), cortar(m, de: s))
                }
            ),
            // at 4:30pm / 16:30 / 7pm
            (
                try! NSRegularExpression(pattern: #"(?:\bat\s+)?(\d{1,2})(?:[:.](\d{2}))?\s*(am|pm)?"#),
                { m, s in
                    let meridio = !grupo(m, 3, s).isEmpty
                    let pm = grupo(m, 3, s).lowercased() == "pm"
                    let a = minutos(hora: grupo(m, 1, s), minuto: grupo(m, 2, s), pm: pm, meridio: meridio)
                    return (a, 30, cortar(m, de: s))
                }
            ),
        ]

        for (regex, ler) in padroes {
            let range = NSRange(texto.startIndex..., in: texto)
            if let m = regex.firstMatch(in: texto, range: range),
               let valor = ler(m, texto) {
                return (valor.0, valor.1, valor.2, false)
            }
        }
        return nil
    }

    nonisolated private static func minutos(hora: String, minuto: String, pm: Bool, meridio: Bool) -> Int {
        var h = Int(hora) ?? 0
        let m = Int(minuto) ?? 0
        if meridio {
            if pm, h < 12 { h += 12 }
            if !pm, h == 12 { h = 0 }
        }
        return max(0, min(23, h)) * 60 + max(0, min(59, m))
    }

    nonisolated private static func grupo(_ m: NSTextCheckingResult, _ i: Int, _ s: String) -> String {
        guard let r = Range(m.range(at: i), in: s) else { return "" }
        return String(s[r])
    }

    nonisolated private static func cortar(_ m: NSTextCheckingResult, de s: String) -> String {
        guard let r = Range(m.range, in: s) else { return s }
        return s.replacingCharacters(in: r, with: " ")
    }

    nonisolated private static func cortar(_ palavra: String, de baixo: String, original: String) -> String? {
        guard let range = baixo.range(of: palavra) else { return nil }
        let start = original.index(original.startIndex, offsetBy: baixo.distance(from: baixo.startIndex, to: range.lowerBound))
        let end = original.index(start, offsetBy: palavra.count)
        return String(original[..<start] + " " + original[end...])
    }

    nonisolated static func categoria(de titulo: String) -> CategoriaEvento {
        let t = titulo.lowercased()
        if t.contains("sync") || t.contains("standup") || t.contains("design")
            || t.contains("work") || t.contains("review") { return .trabalho }
        if t.contains("run") || t.contains("gym") || t.contains("yoga")
            || t.contains("walk") { return .corpo }
        if t.contains("brunch") || t.contains("museum") || t.contains("movie")
            || t.contains("lunch") || t.contains("dinner") { return .social }
        if t.contains("grocery") || t.contains("meal") || t.contains("farmers")
            || t.contains("shop") { return .casa }
        return .outro
    }
}

/// Eventos no aparelho — ficheiro próprio, fora do schema das notas.
nonisolated enum CalendarioDisco {
    static func urlPadrao() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("Traço/calendario.json")
    }

    static func carregar(de url: URL = urlPadrao()) -> [EventoCalendario] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([EventoCalendario].self, from: data)
        } catch {
            return []
        }
    }

    static func gravar(_ eventos: [EventoCalendario], em url: URL = urlPadrao()) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(eventos)
            try data.write(to: url, options: .atomic)
        } catch {
            return
        }
    }

    /// A semente do clone: a semana da âncora parece o vídeo (Team sync, Lunch, pílulas).
    nonisolated static func semente(ancora: Date, agora: Date, _ cal: Calendar) -> [EventoCalendario] {
        let dias = Calendario.semana(da: ancora, cal)
        func em(_ dia: Date, _ h: Int, _ m: Int, duracao: Int = 30) -> (Date, Date) {
            let inicio = cal.date(byAdding: .minute, value: h * 60 + m, to: Calendario.inicioDoDia(dia, cal)) ?? dia
            let fim = cal.date(byAdding: .minute, value: duracao, to: inicio) ?? inicio
            return (inicio, fim)
        }
        func evento(_ titulo: String, _ dia: Date, _ h: Int, _ m: Int, _ duracao: Int, _ cat: CategoriaEvento) -> EventoCalendario {
            let (a, b) = em(dia, h, m, duracao: duracao)
            return EventoCalendario(titulo: titulo, inicio: a, fim: b, categoria: cat)
        }

        var lista: [EventoCalendario] = []
        if dias.count == 7 {
            lista += [
                evento("Brunch", dias[0], 10, 0, 75, .social),
                evento("Museum visit", dias[0], 14, 0, 90, .social),
                evento("Standup", dias[1], 9, 0, 15, .trabalho),
                evento("Lunch", dias[1], 12, 30, 45, .social),
                evento("Team sync", dias[1], 16, 30, 30, .trabalho),
                evento("Long run", dias[2], 7, 0, 60, .corpo),
                evento("Design review", dias[2], 15, 0, 45, .trabalho),
                evento("Yoga", dias[3], 8, 0, 45, .corpo),
                evento("Grocery shop", dias[3], 18, 0, 40, .casa),
                evento("Standup", dias[4], 9, 0, 15, .trabalho),
                evento("Gym session", dias[4], 17, 30, 60, .corpo),
                evento("Farmers market", dias[5], 9, 30, 60, .casa),
                evento("Movie", dias[5], 20, 0, 120, .social),
                evento("Meal prep", dias[6], 11, 0, 50, .casa),
            ]
        }
        // Se a âncora não é a segunda-feira da semente, o Team sync do vídeo
        // ainda precisa de um bloco no dia em que o autor está.
        let hoje = Calendario.inicioDoDia(agora, cal)
        if !lista.contains(where: { $0.titulo == "Team sync" && Calendario.mesmoDia($0.inicio, hoje, cal) }) {
            let (a, b) = em(hoje, 16, 30, duracao: 30)
            lista.append(EventoCalendario(titulo: "Team sync", inicio: a, fim: b, categoria: .trabalho))
        }
        return lista
    }
}
