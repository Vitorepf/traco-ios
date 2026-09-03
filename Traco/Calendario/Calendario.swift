import Foundation

/// As quatro distâncias: o dia âncora não muda ao zoomar.
nonisolated enum EscalaCalendario: String, CaseIterable, Sendable {
    case dia, semana, mes, ano

    var letra: String {
        switch self {
        case .dia: "D"
        case .semana: "S"
        case .mes: "M"
        case .ano: "A"
        }
    }

    var nome: String {
        switch self {
        case .dia: "Dia"
        case .semana: "Semana"
        case .mes: "Mês"
        case .ano: "Ano"
        }
    }
}

nonisolated enum ModoCalendario: String, Sendable {
    case lista, grelha
}

/// Um compromisso. O domínio é o MESMO das notas (ADR 2026-09-02c): uma
/// taxonomia só. Arquivos antigos traziam `categoria`; a leitura converte.
nonisolated struct EventoCalendario: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var titulo: String
    var inicio: Date
    var fim: Date
    var dominio: Dominio?
    var notas: String
    var diaInteiro: Bool
    /// Deixa de uma nota (o "Se" com hora): a nota é a dona; não vai ao disco
    /// do calendário, e tocar abre a nota. É o calendário das intenções.
    var origem: UUID? = nil

    var eDeixa: Bool { origem != nil }

    init(
        id: UUID = UUID(),
        titulo: String,
        inicio: Date,
        fim: Date,
        dominio: Dominio? = nil,
        notas: String = "",
        diaInteiro: Bool = false,
        origem: UUID? = nil
    ) {
        self.id = id
        self.titulo = titulo
        self.inicio = inicio
        self.fim = fim
        self.dominio = dominio
        self.notas = notas
        self.diaInteiro = diaInteiro
        self.origem = origem
    }

    private enum Chave: String, CodingKey {
        case id, titulo, inicio, fim, dominio, categoria, notas, diaInteiro
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Chave.self)
        id = try c.decode(UUID.self, forKey: .id)
        titulo = try c.decode(String.self, forKey: .titulo)
        inicio = try c.decode(Date.self, forKey: .inicio)
        fim = try c.decode(Date.self, forKey: .fim)
        notas = try c.decodeIfPresent(String.self, forKey: .notas) ?? ""
        diaInteiro = try c.decodeIfPresent(Bool.self, forKey: .diaInteiro) ?? false
        if let d = try c.decodeIfPresent(String.self, forKey: .dominio) {
            dominio = Dominio(rawValue: d)
        } else if let antiga = try c.decodeIfPresent(String.self, forKey: .categoria) {
            // o clone tinha cinco categorias próprias; viram domínio
            dominio = switch antiga {
            case "trabalho": .trabalho
            case "corpo": .saude
            case "social": .pessoas
            case "casa": .casa
            default: nil
            }
        } else {
            dominio = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Chave.self)
        try c.encode(id, forKey: .id)
        try c.encode(titulo, forKey: .titulo)
        try c.encode(inicio, forKey: .inicio)
        try c.encode(fim, forKey: .fim)
        try c.encodeIfPresent(dominio?.rawValue, forKey: .dominio)
        try c.encode(notas, forKey: .notas)
        try c.encode(diaInteiro, forKey: .diaInteiro)
    }

    var duracaoMinutos: Int {
        max(0, Int(fim.timeIntervalSince(inicio) / 60))
    }

    /// Mudar o dia leva o fim junto: a duração é do compromisso, não da data.
    func movido(paraODiaDe novo: Date, _ cal: Calendar) -> EventoCalendario {
        var e = self
        let h = cal.component(.hour, from: inicio)
        let m = cal.component(.minute, from: inicio)
        e.inicio = Calendario.hora(h, m, no: novo, cal)
        e.fim = e.inicio.addingTimeInterval(fim.timeIntervalSince(inicio))
        return e
    }

    /// Começa depois de terminar? O fim segue o início e guarda a duração.
    func comInicio(_ novo: Date) -> EventoCalendario {
        var e = self
        let duracao = max(5 * 60, fim.timeIntervalSince(inicio))
        e.inicio = novo
        e.fim = novo.addingTimeInterval(duracao)
        return e
    }

    /// O fim nunca fica antes do início: o mínimo são cinco minutos.
    func comFim(_ novo: Date) -> EventoCalendario {
        var e = self
        e.fim = max(novo, inicio.addingTimeInterval(5 * 60))
        return e
    }
}

/// Matemática do calendário — `nonisolated` para os testes e para o parse.
nonisolated enum Calendario {
    /// A deixa de uma nota (ADR i): o "Se" com hora, 30 minutos, dona = a nota.
    /// Expressiva e fechada nunca.
    nonisolated static func deixa(uuid: UUID, gesto: Gesto?, fechada: Bool, gatilhoEm: Date?,
                                  se: String, tituloNaLista: String, dominio: Dominio?) -> EventoCalendario? {
        guard let quando = gatilhoEm, !fechada, gesto != .expressiva else { return nil }
        let corte = se.trimmingCharacters(in: .whitespacesAndNewlines)
        let titulo = corte.isEmpty ? tituloNaLista : corte
        guard !titulo.isEmpty else { return nil }
        return EventoCalendario(id: uuid, titulo: titulo, inicio: quando,
                                fim: quando.addingTimeInterval(30 * 60), dominio: dominio, origem: uuid)
    }

    /// Marcas da semana: sete barras, 03 às 21.
    static let horasDaSemana = [3, 6, 9, 12, 15, 18, 21]

    /// pt-BR; domingo primeiro por padrão (o autor troca no ajuste).
    nonisolated static func gregoriano(fuso: TimeZone = .current, segundaPrimeiro: Bool = false) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "pt_BR")
        cal.timeZone = fuso
        cal.firstWeekday = segundaPrimeiro ? 2 : 1
        return cal
    }

    nonisolated static func inicioDoDia(_ data: Date, _ cal: Calendar) -> Date {
        cal.startOfDay(for: data)
    }

    /// Hora do dia SEM somar minutos ao início: no dia da mudança de horário,
    /// somar 16h30 ao começo do dia dava 17h30.
    nonisolated static func hora(_ h: Int, _ m: Int, no dia: Date, _ cal: Calendar) -> Date {
        let base = inicioDoDia(dia, cal)
        if h >= 24 { return cal.date(byAdding: .day, value: 1, to: base) ?? base }
        return cal.date(bySettingHour: h, minute: m, second: 0, of: base) ?? base
    }

    nonisolated static func mesmoDia(_ a: Date, _ b: Date, _ cal: Calendar) -> Bool {
        cal.isDate(a, inSameDayAs: b)
    }

    /// Os sete dias da semana que contém a âncora, do primeiro dia da semana.
    nonisolated static func semana(da ancora: Date, _ cal: Calendar) -> [Date] {
        let dia = inicioDoDia(ancora, cal)
        let weekday = cal.component(.weekday, from: dia)
        let recuo = (weekday - cal.firstWeekday + 7) % 7
        let primeiro = cal.date(byAdding: .day, value: -recuo, to: dia) ?? dia
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: primeiro) }
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
            return formatar(ancora, "d 'de' MMMM", cal)
        case .semana:
            let dias = semana(da: ancora, cal)
            guard let primeiro = dias.first, let ultimo = dias.last else { return "" }
            if cal.component(.month, from: primeiro) == cal.component(.month, from: ultimo) {
                return "\(formatar(primeiro, "d", cal)) – \(formatar(ultimo, "d 'de' MMMM", cal))"
            }
            return "\(formatar(primeiro, "d", cal)) \(mesCurto(primeiro, cal)) – \(formatar(ultimo, "d", cal)) \(mesCurto(ultimo, cal))"
        case .mes:
            return formatar(ancora, "MMMM yyyy", cal).capitalizadoNoInicio
        case .ano:
            return formatar(ancora, "yyyy", cal)
        }
    }

    /// "set", sem o ponto que o pt-BR põe.
    nonisolated static func mesCurto(_ data: Date, _ cal: Calendar) -> String {
        formatar(data, "MMM", cal).replacingOccurrences(of: ".", with: "")
    }

    nonisolated static func letraDoDia(_ data: Date, _ cal: Calendar) -> String {
        formatar(data, "EEEEE", cal).uppercased()
    }

    /// As sete letras na ordem da semana do calendário.
    nonisolated static func letrasDaSemana(_ cal: Calendar) -> [String] {
        semana(da: Date(timeIntervalSince1970: 0), cal).map { letraDoDia($0, cal) }
    }

    nonisolated static func diaPorExtenso(_ data: Date, _ cal: Calendar) -> String {
        formatar(data, "EEEE, d 'de' MMMM", cal).capitalizadoNoInicio
    }

    nonisolated static func horaCurta(_ data: Date, _ cal: Calendar) -> String {
        formatar(data, "HH:mm", cal)
    }

    nonisolated static func intervalo(_ e: EventoCalendario, _ cal: Calendar) -> String {
        if e.diaInteiro { return "Dia inteiro" }
        return "\(horaCurta(e.inicio, cal)) – \(horaCurta(e.fim, cal))"
    }

    // Um DateFormatter por formato: alocar um por chamada custava 84 por
    // render do mês e 504 no ano.
    nonisolated private static let tranca = NSLock()
    nonisolated(unsafe) private static var formatadores: [String: DateFormatter] = [:]

    nonisolated static func formatar(_ data: Date, _ formato: String, _ cal: Calendar) -> String {
        let chave = "\(formato)|\(cal.timeZone.identifier)|\(cal.locale?.identifier ?? "")|\(cal.firstWeekday)"
        tranca.lock()
        defer { tranca.unlock() }
        if let f = formatadores[chave] { return f.string(from: data) }
        let f = DateFormatter()
        f.calendar = cal
        f.locale = cal.locale
        f.timeZone = cal.timeZone
        f.dateFormat = formato
        formatadores[chave] = f
        return f.string(from: data)
    }

    nonisolated static func eventos(
        _ todos: [EventoCalendario],
        noDia dia: Date,
        _ cal: Calendar
    ) -> [EventoCalendario] {
        todos
            .filter { mesmoDia($0.inicio, dia, cal) }
            .sorted { ($0.diaInteiro ? 0 : 1, $0.inicio) < ($1.diaInteiro ? 0 : 1, $1.inicio) }
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
        todos
            .filter { mesmoMes($0.inicio, ancora, cal) }
            .sorted { $0.inicio < $1.inicio }
    }

    /// Eventos por dia, calculado UMA vez por render (o mês perguntava 42
    /// vezes, o ano 504, cada uma filtrando a lista inteira).
    nonisolated static func porDia(_ todos: [EventoCalendario], _ cal: Calendar) -> [Date: [EventoCalendario]] {
        var mapa: [Date: [EventoCalendario]] = [:]
        for e in todos { mapa[inicioDoDia(e.inicio, cal), default: []].append(e) }
        for chave in mapa.keys {
            mapa[chave]?.sort { ($0.diaInteiro ? 0 : 1, $0.inicio) < ($1.diaInteiro ? 0 : 1, $1.inicio) }
        }
        return mapa
    }

    /// Dois compromissos à mesma hora ficam lado a lado, não um sobre o outro.
    /// Cada evento recebe a coluna e o total de colunas do seu grupo.
    nonisolated struct Coluna: Equatable, Sendable {
        var evento: EventoCalendario
        var indice: Int
        var total: Int
    }

    nonisolated static func colunas(_ eventos: [EventoCalendario]) -> [Coluna] {
        let ordenados = eventos.filter { !$0.diaInteiro }.sorted {
            $0.inicio == $1.inicio ? $0.fim > $1.fim : $0.inicio < $1.inicio
        }
        var saida: [Coluna] = []
        var grupo: [(EventoCalendario, Int)] = []
        var fimDoGrupo: Date = .distantPast
        var fimsDasColunas: [Date] = []

        func fecharGrupo() {
            let total = max(1, fimsDasColunas.count)
            saida += grupo.map { Coluna(evento: $0.0, indice: $0.1, total: total) }
            grupo = []
            fimsDasColunas = []
        }

        for e in ordenados {
            if e.inicio >= fimDoGrupo, !grupo.isEmpty { fecharGrupo() }
            var coluna = fimsDasColunas.firstIndex { $0 <= e.inicio }
            if coluna == nil {
                fimsDasColunas.append(e.fim)
                coluna = fimsDasColunas.count - 1
            } else {
                fimsDasColunas[coluna!] = e.fim
            }
            grupo.append((e, coluna!))
            fimDoGrupo = max(fimDoGrupo, e.fim)
        }
        if !grupo.isEmpty { fecharGrupo() }
        return saida
    }

    /// Mudar a escala NUNCA move a âncora — o dia em que estás é o sítio.
    nonisolated static func ir(para escala: EscalaCalendario, ancora: Date) -> (EscalaCalendario, Date) {
        (escala, ancora)
    }

    /// Escolher um mês (ano → mês) guarda o dia: 2 set → 2 jan, não o dia 1.
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

    nonisolated static func minutosDoDia(_ data: Date, _ cal: Calendar) -> Int {
        cal.component(.hour, from: data) * 60 + cal.component(.minute, from: data)
    }
}

nonisolated extension String {
    var capitalizadoNoInicio: String {
        guard let primeira = first else { return self }
        return primeira.uppercased() + dropFirst()
    }
}

/// Cria compromisso a partir de prosa em português — local, sem modelo.
/// "dentista sexta 14:30", "almoço com a Ana amanhã às 12h", "feira sábado de
/// manhã", "viagem dia 15 dia inteiro", "reunião 9h-10h30 por 2h".
nonisolated enum CalendarioFrase {
    /// Consulta, não marcação: "o que tenho sexta?", "semana que vem",
    /// "amanhã?", "este mês". Devolve para onde ir. Nada de chat: o app
    /// responde mostrando o dia. Só é consulta se, tirando as palavras de
    /// pergunta e a data, não sobra nada para virar título.
    nonisolated static func consulta(
        _ prosa: String,
        ancora: Date,
        agora: Date,
        _ cal: Calendar
    ) -> (dia: Date, escala: EscalaCalendario)? {
        var texto = prosa.lowercased()
            .replacingOccurrences(of: "?", with: " ")
        let hoje = Calendario.inicioDoDia(agora, cal)
        var destino: (Date, EscalaCalendario)?
        let periodos: [(String, Int, Calendar.Component, EscalaCalendario)] = [
            (#"\b(semana que vem|pr[óo]xima semana|semana seguinte)\b"#, 7, .day, .semana),
            (#"\b(semana passada|[úu]ltima semana)\b"#, -7, .day, .semana),
            (#"\b(est[ae]|ness?a)\s+semana\b"#, 0, .day, .semana),
            (#"\b(m[êe]s que vem|pr[óo]ximo m[êe]s|m[êe]s seguinte)\b"#, 1, .month, .mes),
            (#"\b(m[êe]s passado|[úu]ltimo m[êe]s)\b"#, -1, .month, .mes),
            (#"\b(est[ae]|ness?e)\s+m[êe]s\b"#, 0, .month, .mes),
            (#"\b(ano que vem|pr[óo]ximo ano)\b"#, 1, .year, .ano),
            (#"\b(est[ae]|ness?e)\s+ano\b"#, 0, .year, .ano),
        ]
        for (padrao, passo, unidade, escala) in periodos {
            if let m = achar(padrao, texto) {
                let dia = cal.date(byAdding: unidade, value: passo, to: hoje) ?? hoje
                destino = (Calendario.inicioDoDia(dia, cal), escala)
                texto = m.resto
                break
            }
        }
        // pergunta é sobre a vida, não sobre onde a tela está: "sexta" é a
        // próxima sexta a partir de HOJE, mesmo olhando outro mês
        if destino == nil, let (d, r) = comerDia(texto, ancora: hoje, agora: agora, cal) {
            destino = (d, .dia)
            texto = r
        }
        guard let destino else { return nil }
        // o que sobra tem de ser só pergunta
        let pergunta = #"\b(o que|que|tenho|tem|h[áa]|eu|marcad[oa]s?|compromissos?|agenda|mostra|mostre|me|ver|vai ter|tem algo|algo|alguma coisa|de|em|na|no|para|pra|a|as|os|e)\b"#
        let resto = texto.replacingOccurrences(of: pergunta, with: " ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: " ,.-–!"))
        guard resto.isEmpty else { return nil }
        return destino
    }

    nonisolated static func ler(
        _ prosa: String,
        ancora: Date,
        agora: Date,
        _ cal: Calendar,
        manha: Int = 8,
        tarde: Int = 14,
        noite: Int = 20
    ) -> EventoCalendario? {
        let limpo = prosa.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty else { return nil }

        var resto = limpo
        var dia = Calendario.inicioDoDia(ancora, cal)
        var inicioMinutos: Int? = nil
        var duracao: Int? = nil
        var diaInteiro = false

        if let (d, r) = comerDia(resto, ancora: ancora, agora: agora, cal) {
            dia = d
            resto = r
        }
        if let r = comerDiaInteiro(resto) {
            diaInteiro = true
            resto = r
        }
        if let (d, r) = comerDuracao(resto) {
            duracao = d
            resto = r
        }
        if !diaInteiro, let (i, d, r) = comerHora(resto, manha: manha, tarde: tarde, noite: noite) {
            inicioMinutos = i
            if let d { duracao = d }
            resto = r
        }

        let titulo = limparTitulo(resto)
        guard !titulo.isEmpty else { return nil }

        let inicio: Date
        let fim: Date
        if diaInteiro {
            inicio = Calendario.inicioDoDia(dia, cal)
            fim = Calendario.hora(24, 0, no: dia, cal)
        } else {
            let m = inicioMinutos ?? 9 * 60
            inicio = Calendario.hora(m / 60, m % 60, no: dia, cal)
            fim = inicio.addingTimeInterval(TimeInterval((duracao ?? 60) * 60))
        }
        return EventoCalendario(
            titulo: titulo,
            inicio: inicio,
            fim: fim,
            dominio: Dominio.inferir(voz: titulo),
            diaInteiro: diaInteiro
        )
    }

    // MARK: dia

    nonisolated private static func comerDia(
        _ texto: String,
        ancora: Date,
        agora: Date,
        _ cal: Calendar
    ) -> (Date, String)? {
        let hoje = Calendario.inicioDoDia(agora, cal)
        func mais(_ n: Int) -> Date { cal.date(byAdding: .day, value: n, to: hoje) ?? hoje }

        // "15/09" ou "15/9"
        if let m = achar(#"\b(\d{1,2})/(\d{1,2})(?:/(\d{2,4}))?\b"#, texto) {
            let d = Int(m.grupos[1]) ?? 1
            let mes = Int(m.grupos[2]) ?? 1
            var ano = cal.component(.year, from: hoje)
            if let a = Int(m.grupos[3]) { ano = a < 100 ? 2000 + a : a }
            // "31/02" não vira 3 de março em silêncio
            if let data = cal.date(from: DateComponents(year: ano, month: mes, day: d)),
               cal.component(.day, from: data) == d, cal.component(.month, from: data) == mes {
                return (Calendario.inicioDoDia(data, cal), m.resto)
            }
        }
        // "dia 15": este mês se ainda não passou, senão o próximo
        if let m = achar(#"\bdia\s+(\d{1,2})\b"#, texto), let d = Int(m.grupos[1]), (1...31).contains(d) {
            var comps = cal.dateComponents([.year, .month], from: hoje)
            comps.day = d
            if let neste = cal.date(from: comps), neste >= hoje {
                return (Calendario.inicioDoDia(neste, cal), m.resto)
            }
            if let proximoMes = cal.date(byAdding: .month, value: 1, to: hoje) {
                var c2 = cal.dateComponents([.year, .month], from: proximoMes)
                c2.day = d
                if let data = cal.date(from: c2) { return (Calendario.inicioDoDia(data, cal), m.resto) }
            }
        }

        let fixos: [(String, Date)] = [
            (#"\bdepois de amanh[ãa]\b"#, mais(2)),
            (#"\bamanh[ãa]\b"#, mais(1)),
            (#"\bhoje\b"#, hoje),
        ]
        for (padrao, data) in fixos {
            if let m = achar(padrao, texto) { return (data, m.resto) }
        }

        let semana: [(String, Int)] = [
            (#"\b(domingo|dom)\b"#, 1),
            (#"\b(segunda(?:-feira)?|seg)\b"#, 2),
            (#"\b(ter[çc]a(?:-feira)?|ter)\b"#, 3),
            (#"\b(quarta(?:-feira)?|qua)\b"#, 4),
            (#"\b(quinta(?:-feira)?|qui)\b"#, 5),
            (#"\b(sexta(?:-feira)?|sex)\b"#, 6),
            (#"\b(s[áa]bado|sab)\b"#, 7),
        ]
        for (padrao, weekday) in semana {
            if let m = achar(padrao, texto) {
                return (proximo(weekday, aPartir: ancora, cal), m.resto)
            }
        }
        return nil
    }

    /// O próximo weekday a partir da âncora, contando o próprio dia.
    nonisolated private static func proximo(_ weekday: Int, aPartir de: Date, _ cal: Calendar) -> Date {
        let dia = Calendario.inicioDoDia(de, cal)
        let actual = cal.component(.weekday, from: dia)
        var delta = weekday - actual
        if delta < 0 { delta += 7 }
        return cal.date(byAdding: .day, value: delta, to: dia) ?? dia
    }

    nonisolated private static func comerDiaInteiro(_ texto: String) -> String? {
        achar(#"\b(o\s+)?dia\s+(inteiro|todo)\b"#, texto)?.resto
    }

    // MARK: duração

    nonisolated private static func comerDuracao(_ texto: String) -> (Int, String)? {
        // "por 2h", "por 1h30", "por 45 min", "durante 2 horas"
        if let m = achar(#"\b(?:por|durante)\s+(\d{1,2})(?:\s*h(?:oras?)?\s*(\d{2})?|\s*(min(?:utos?)?))\b"#, texto) {
            let n = Int(m.grupos[1]) ?? 0
            if !m.grupos[3].isEmpty { return (max(5, n), m.resto) }
            let extra = Int(m.grupos[2]) ?? 0
            return (max(5, n * 60 + extra), m.resto)
        }
        return nil
    }

    // MARK: hora

    /// Devolve (início em minutos, duração se houver intervalo, resto).
    /// Um número solto NUNCA é hora: "reunião com 3 pessoas" não é às 03:00.
    nonisolated private static func comerHora(
        _ texto: String,
        manha: Int,
        tarde: Int,
        noite: Int
    ) -> (Int, Int?, String)? {
        let hora = #"(\d{1,2})(?:[:h](\d{2})?)?"#
        // intervalo: "14:30-16:00", "das 9h às 10h30", "9 às 11h", "14h até 15h"
        if let m = achar(#"(?:\bdas?\s+)?\b"# + hora + #"\s*(?:[–\-]|às|as|até|ate|a)\s*"# + hora + #"(?:\s*h)?\b"#, texto),
           temMarcador(m.texto) {
            let a = minutos(m.grupos[1], m.grupos[2])
            let b = minutos(m.grupos[3], m.grupos[4])
            return (a, b > a ? b - a : nil, m.resto)
        }
        // "às 14:30", "as 14h", "14h30", "14:30", "à 1h"
        if let m = achar(#"(?:\b[àa]s?\s+)?\b(\d{1,2})(?:[:h](\d{2})?|\s*h(?:oras)?\b)"#, texto) {
            return (minutos(m.grupos[1], m.grupos[2]), nil, m.resto)
        }
        if let m = achar(#"\b[àa]s\s+(\d{1,2})\b"#, texto) {
            return (minutos(m.grupos[1], ""), nil, m.resto)
        }
        if let m = achar(#"\bmeio[-\s]dia\b"#, texto) { return (12 * 60, nil, m.resto) }
        if let m = achar(#"\bmeia[-\s]noite\b"#, texto) { return (0, nil, m.resto) }
        if let m = achar(#"\b(de|pela|na)\s+manh[ãa]\b"#, texto) { return (manha * 60, nil, m.resto) }
        if let m = achar(#"\b([àa]|de|pela|na)\s+tarde\b"#, texto) { return (tarde * 60, nil, m.resto) }
        if let m = achar(#"\b([àa]|de|pela|na)\s+noite\b"#, texto) { return (noite * 60, nil, m.resto) }
        return nil
    }

    /// Intervalo só vale com um marcador de hora em algum lado: "9 às 11h",
    /// "14:30-16:00". "2 a 3 pessoas" não tem.
    nonisolated private static func temMarcador(_ trecho: String) -> Bool {
        trecho.contains(":") || trecho.lowercased().contains("h")
            || trecho.lowercased().contains("às") || trecho.lowercased().contains("das")
    }

    nonisolated private static func minutos(_ hora: String, _ minuto: String) -> Int {
        let h = max(0, min(23, Int(hora) ?? 0))
        let m = max(0, min(59, Int(minuto) ?? 0))
        return h * 60 + m
    }

    // MARK: título

    nonisolated private static let conectores: Set<String> = [
        "às", "as", "à", "a", "o", "de", "do", "da", "dos", "das", "no", "na", "nos", "nas",
        "em", "e", "ao", "aos", "com", "para", "pra", "por",
    ]

    nonisolated private static func limparTitulo(_ texto: String) -> String {
        var palavras = texto
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: " ,.-–"))
            .split(separator: " ")
            .map(String.init)
        while let ultima = palavras.last, conectores.contains(ultima.lowercased()) { palavras.removeLast() }
        while let primeira = palavras.first, conectores.contains(primeira.lowercased()) { palavras.removeFirst() }
        return palavras.joined(separator: " ")
            .trimmingCharacters(in: CharacterSet(charactersIn: " ,.-–"))
            .capitalizadoNoInicio
    }

    // MARK: regex

    nonisolated private struct Achado {
        var texto: String
        var grupos: [String]
        var resto: String
    }

    nonisolated private static func achar(_ padrao: String, _ texto: String) -> Achado? {
        guard let regex = try? NSRegularExpression(pattern: padrao, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(texto.startIndex..., in: texto)
        guard let m = regex.firstMatch(in: texto, range: range),
              let todo = Range(m.range, in: texto) else { return nil }
        var grupos: [String] = []
        for i in 0..<m.numberOfRanges {
            if let r = Range(m.range(at: i), in: texto) { grupos.append(String(texto[r])) } else { grupos.append("") }
        }
        let resto = texto.replacingCharacters(in: todo, with: " ")
        return Achado(texto: String(texto[todo]), grupos: grupos, resto: resto)
    }
}

/// Compromissos no aparelho — arquivo próprio, fora do schema das notas.
/// O arquivo é do autor (aparece em Arquivos): vazio é vazio, e corrompido
/// nunca vira semente.
nonisolated enum CalendarioDisco {
    nonisolated enum Leitura: Sendable {
        case semArquivo
        case eventos([EventoCalendario])
        case corrompido
    }

    static func urlPadrao() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("Traço/calendario.json")
    }

    static func carregar(de url: URL = urlPadrao()) -> Leitura {
        guard FileManager.default.fileExists(atPath: url.path) else { return .semArquivo }
        do {
            let data = try Data(contentsOf: url)
            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601
            return .eventos(try dec.decode([EventoCalendario].self, from: data))
        } catch {
            // arquivos gravados antes de 02/set usavam o formato numérico
            if let data = try? Data(contentsOf: url),
               let antigos = try? JSONDecoder().decode([EventoCalendario].self, from: data) {
                return .eventos(antigos)
            }
            return .corrompido
        }
    }

    /// Guarda o arquivo ilegível ao lado, com a hora, e nunca por cima.
    @discardableResult
    static func porDeLado(_ url: URL = urlPadrao()) -> URL? {
        let carimbo = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
        let destino = url.deletingPathExtension().appendingPathExtension("ilegivel-\(carimbo).json")
        do {
            try FileManager.default.moveItem(at: url, to: destino)
            return destino
        } catch {
            return nil
        }
    }

    static func gravar(_ eventos: [EventoCalendario], em url: URL = urlPadrao()) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.sortedKeys]
        let data = try enc.encode(eventos)
        try data.write(to: url, options: .atomic)
    }
}
