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
    /// Projeção transitória de uma ação; o agregado Trabalho continua dono.
    var origemTrabalho: UUID? = nil
    /// Dias da semana em que repete (1 = domingo … 7 = sábado). Vazio = uma vez
    /// só. O disco guarda a SÉRIE, nunca as ocorrências: "toda sexta" é uma
    /// linha no arquivo, não cinquenta e duas.
    var repeteEm: [Int] = []

    /// ADR 2026-09-04a: minutos ANTES do começo em que o aviso toca.
    /// `nil` = não avisa. Arquivo gravado antes desta ADR não tem a chave e
    /// vale 0 (na hora): o comportamento da ADR 03d fica de pé para tudo que
    /// já estava marcado.
    var avisoMinutos: Int? = 0

    /// A3: veio do calendário do iPhone (Apple, Google…). Não é nosso: não vai
    /// ao disco, não se edita, não se apaga e não sai no export. Só se lê.
    /// Não é codificável de propósito — nada disto atravessa o `calendario.json`.
    var doSistema: Bool = false

    var eDeixa: Bool { origem != nil }
    var repete: Bool { !repeteEm.isEmpty }
    /// O que o Traço pode mexer: o que ele mesmo guardou.
    var editavel: Bool { origem == nil && origemTrabalho == nil && !doSistema }

    init(
        id: UUID = UUID(),
        titulo: String,
        inicio: Date,
        fim: Date,
        dominio: Dominio? = nil,
        notas: String = "",
        diaInteiro: Bool = false,
        origem: UUID? = nil,
        origemTrabalho: UUID? = nil,
        repeteEm: [Int] = [],
        avisoMinutos: Int? = 0
    ) {
        self.id = id
        self.titulo = titulo
        self.inicio = inicio
        self.fim = fim
        self.dominio = dominio
        self.notas = notas
        self.diaInteiro = diaInteiro
        self.origem = origem
        self.origemTrabalho = origemTrabalho
        self.repeteEm = repeteEm
        self.avisoMinutos = avisoMinutos
    }

    private enum Chave: String, CodingKey {
        case id, titulo, inicio, fim, dominio, categoria, notas, diaInteiro, repeteEm, avisoMinutos
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Chave.self)
        id = try c.decode(UUID.self, forKey: .id)
        titulo = try c.decode(String.self, forKey: .titulo)
        inicio = try c.decode(Date.self, forKey: .inicio)
        fim = try c.decode(Date.self, forKey: .fim)
        notas = try c.decodeIfPresent(String.self, forKey: .notas) ?? ""
        diaInteiro = try c.decodeIfPresent(Bool.self, forKey: .diaInteiro) ?? false
        // arquivo gravado antes da repetição não tem a chave: uma vez só
        repeteEm = (try c.decodeIfPresent([Int].self, forKey: .repeteEm) ?? [])
            .filter { (1...7).contains($0) }
            .sorted()
        // chave ausente = arquivo velho = avisa na hora; chave nula = o autor
        // desligou o aviso deste compromisso, e isso tem de sobreviver ao disco
        avisoMinutos = c.contains(.avisoMinutos)
            ? try c.decodeIfPresent(Int.self, forKey: .avisoMinutos)
            : 0
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
        guard origemTrabalho == nil else {
            throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath,
                debugDescription: "A ação pertence ao Trabalho e não pode virar compromisso independente."))
        }
        var c = encoder.container(keyedBy: Chave.self)
        try c.encode(id, forKey: .id)
        try c.encode(titulo, forKey: .titulo)
        try c.encode(inicio, forKey: .inicio)
        try c.encode(fim, forKey: .fim)
        try c.encodeIfPresent(dominio?.rawValue, forKey: .dominio)
        try c.encode(notas, forKey: .notas)
        try c.encode(diaInteiro, forKey: .diaInteiro)
        if repete { try c.encode(repeteEm, forKey: .repeteEm) }
        try c.encode(avisoMinutos, forKey: .avisoMinutos)
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

/// ADR 2026-09-04a — a antecedência do aviso, em lista fechada.
///
/// O rótulo é do app; a ficha mostra a HORA REAL ao lado, porque é ela que o
/// autor confere. "Avisa 30 min antes" é promessa abstrata; "sexta, 13h30" é
/// promessa em unidade do mundo dele.
nonisolated enum Aviso {
    /// Minutos antes do começo. `nil` = não avisa.
    static let opcoes: [Int?] = [nil, 0, 5, 10, 15, 30, 60, 120, 1440]
    /// Dia inteiro não tem "minutos antes" que signifiquem coisa alguma: ou
    /// cobra na âncora da manhã, ou na véspera, ou cala.
    static let opcoesDiaInteiro: [Int?] = [nil, 0, 1440]

    static func nome(_ minutos: Int?, diaInteiro: Bool = false) -> String {
        guard let m = minutos else { return "Não avisa" }
        if diaInteiro { return m >= 1440 ? "Um dia antes, de manhã" : "Na manhã do dia" }
        switch m {
        case 0: return "Na hora"
        case 60: return "1 h antes"
        case 120: return "2 h antes"
        case 1440: return "1 dia antes"
        default: return "\(m) min antes"
        }
    }

    /// O instante em que o aviso toca. Dia inteiro cobra na âncora da manhã do
    /// autor — à meia-noite ninguém lê — e "um dia antes" na manhã da véspera.
    static func instante(de evento: EventoCalendario, _ cal: Calendar, manha: Int) -> Date? {
        guard let m = evento.avisoMinutos else { return nil }
        if evento.diaInteiro {
            let dia = m >= 1440
                ? (cal.date(byAdding: .day, value: -1, to: evento.inicio) ?? evento.inicio)
                : evento.inicio
            return Calendario.hora(manha, 0, no: dia, cal)
        }
        return evento.inicio.addingTimeInterval(-Double(m) * 60)
    }

    /// Quantos dias o aviso recuou em relação ao começo (0, 1 ou mais). Uma
    /// antecedência pode empurrar o alarme para a véspera — e aí o dia da
    /// semana da série anda junto, senão o aviso toca seis dias atrasado.
    static func diasDeRecuo(inicio: Date, aviso: Date, _ cal: Calendar) -> Int {
        let a = cal.startOfDay(for: inicio)
        let b = cal.startOfDay(for: aviso)
        return max(0, cal.dateComponents([.day], from: b, to: a).day ?? 0)
    }

    /// A promessa em uma linha, do jeito que o autor confere. Vazia quando não
    /// há aviso — silêncio pedido não se anuncia.
    static func promessa(de evento: EventoCalendario, _ cal: Calendar,
                         manha: Int, agora: Date = .now) -> String? {
        guard let quando = instante(de: evento, cal, manha: manha) else { return nil }
        let hora = Calendario.horaCurta(quando, cal)
        if evento.repete {
            let recuo = diasDeRecuo(inicio: evento.inicio, aviso: quando, cal)
            let dias = evento.repeteEm.map { ((($0 - 1 - recuo) % 7) + 7) % 7 + 1 }.sorted()
            return "toda \(Calendario.diasEmLetras(dias, cal)) às \(hora)"
        }
        if cal.isDate(quando, inSameDayAs: agora) { return "hoje às \(hora)" }
        if let amanha = cal.date(byAdding: .day, value: 1, to: agora),
           cal.isDate(quando, inSameDayAs: amanha) { return "amanhã às \(hora)" }
        return "\(Calendario.formatar(quando, "EEEE, d 'de' MMM", cal)) às \(hora)"
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
        // o mês é nome próprio no título, em toda escala (dono, 16/09:
        // "o S de setembro maiúsculo, assim como o mensal")
        case .dia:
            return "\(formatar(ancora, "d", cal)) de \(formatar(ancora, "MMMM", cal).capitalizadoNoInicio)"
        case .semana:
            let dias = semana(da: ancora, cal)
            guard let primeiro = dias.first, let ultimo = dias.last else { return "" }
            if cal.component(.month, from: primeiro) == cal.component(.month, from: ultimo) {
                return "\(formatar(primeiro, "d", cal)) – \(formatar(ultimo, "d", cal)) de \(formatar(ultimo, "MMMM", cal).capitalizadoNoInicio)"
            }
            return "\(formatar(primeiro, "d", cal)) \(mesCurto(primeiro, cal).capitalizadoNoInicio) – \(formatar(ultimo, "d", cal)) \(mesCurto(ultimo, cal).capitalizadoNoInicio)"
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

    /// "seg · sex" — os dias da série na língua do autor, na ordem da semana.
    nonisolated static func diasEmLetras(_ dias: [Int], _ cal: Calendar) -> String {
        let semana = Calendario.semana(da: Date(timeIntervalSince1970: 0), cal)
        return semana
            .filter { dias.contains(cal.component(.weekday, from: $0)) }
            .map { formatar($0, "EEE", cal).replacingOccurrences(of: ".", with: "") }
            .joined(separator: " · ")
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
        if e.origemTrabalho != nil, e.duracaoMinutos == 0 { return horaCurta(e.inicio, cal) }
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

    /// As ocorrências concretas no intervalo, inclusive nas duas pontas.
    ///
    /// Evento sem repetição sai como ele mesmo. Com repetição, sai uma cópia
    /// por dia que casa, a partir do início da série — e a cópia guarda o
    /// MESMO `id`, para que tocar nela abra a série, não um fantasma.
    /// É a única porta entre a série guardada e o que a tela desenha.
    nonisolated static func ocorrencias(
        _ eventos: [EventoCalendario],
        de inicio: Date,
        a fim: Date,
        _ cal: Calendar
    ) -> [EventoCalendario] {
        let primeiro = inicioDoDia(inicio, cal)
        let ultimo = inicioDoDia(fim, cal)
        guard primeiro <= ultimo else { return [] }
        var saida: [EventoCalendario] = []
        for e in eventos {
            guard e.repete else {
                saida.append(e)
                continue
            }
            let comeco = max(primeiro, inicioDoDia(e.inicio, cal))
            var dia = comeco
            while dia <= ultimo {
                if e.repeteEm.contains(cal.component(.weekday, from: dia)) {
                    saida.append(e.movido(paraODiaDe: dia, cal))
                }
                guard let proximo = cal.date(byAdding: .day, value: 1, to: dia) else { break }
                dia = proximo
            }
        }
        return saida
    }

    /// A ORDEM DO DIA, declarada: o de dia inteiro vem primeiro e, entre dois
    /// deles, o MAIS LONGO na frente (a viagem de uma semana antes do
    /// aniversário), desempatando pelo título. A semana desenha só a pílula
    /// de cima (`prefix(1)`) e `sorted` não é estável: com «Aniversário da
    /// Ana» e «Viagem a Lisboa» no mesmo dia — os dois começando à
    /// meia-noite — qual das duas aparecia era sorteio, e mudava entre
    /// renders (achado de contrato da ADR 17p; quem esconde já conta no
    /// «+n» de `CalendarioSemanaView.escondidos`).
    nonisolated static func antesNoDia(_ a: EventoCalendario, _ b: EventoCalendario) -> Bool {
        if a.diaInteiro != b.diaInteiro { return a.diaInteiro }
        // a hora de começo de um dia inteiro é sempre meia-noite: não ordena nada
        if !a.diaInteiro, a.inicio != b.inicio { return a.inicio < b.inicio }
        let duracaoA = a.fim.timeIntervalSince(a.inicio)
        let duracaoB = b.fim.timeIntervalSince(b.inicio)
        if duracaoA != duracaoB { return duracaoA > duracaoB }
        return a.titulo.localizedStandardCompare(b.titulo) == .orderedAscending
    }

    nonisolated static func eventos(
        _ todos: [EventoCalendario],
        noDia dia: Date,
        _ cal: Calendar
    ) -> [EventoCalendario] {
        todos
            .filter { mesmoDia($0.inicio, dia, cal) }
            .sorted(by: antesNoDia)
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
            mapa[chave]?.sort(by: antesNoDia)
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
        if destino == nil, let (d, r) = comerDia(texto, agora: agora, cal) {
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
        var repeteEm: [Int] = []

        // "toda sexta e segunda" antes de "sexta": a repetição come os dias,
        // senão `comerDia` levaria um deles e a série viraria uma data só
        if let (dias, r) = comerRepeticao(resto) {
            repeteEm = dias
            dia = primeiraOcorrencia(dias, aPartirDe: agora, cal)
            resto = r
        } else if let (d, r) = comerDia(resto, agora: agora, cal) {
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
            diaInteiro: diaInteiro,
            repeteEm: repeteEm
        )
    }

    /// Vários compromissos numa frase só ("dentista sexta 14h e reunião
    /// segunda 10h; correr terça 6h") — a pessoa fala dez e os dez ficam
    /// marcados (goal de 14/09). A frase parte em " e ", vírgula, ponto e
    /// vírgula, ponto final e quebra de linha.
    ///
    /// Cada parte que carrega dia, hora ou repetição vira um compromisso. A
    /// parte que NÃO carrega marca nenhuma não se perde nem nasce sozinha: vai
    /// junto com a próxima que carregue — e é por isso que "jantar com a Ana e
    /// o Pedro às 20h" continua sendo UM compromisso, e "o Pedro" nunca vira
    /// evento. O que sobra no fim volta ao último compromisso, relido inteiro.
    ///
    /// Antes, bastava UMA parte sem marca para o método desistir de todas e ler
    /// a frase inteira como um compromisso só (relato do dono, 17/09: ditou os
    /// compromissos do dia e nenhum entrou). Vinte itens ditados não têm vinte
    /// marcas perfeitas — e um item mudo não é razão para engolir os outros
    /// dezanove.
    nonisolated static func lerVarios(
        _ prosa: String, ancora: Date, agora: Date, _ cal: Calendar,
        manha: Int = 8, tarde: Int = 14, noite: Int = 20
    ) -> [EventoCalendario] {
        func umDe(_ texto: String) -> EventoCalendario? {
            ler(texto, ancora: ancora, agora: agora, cal, manha: manha, tarde: tarde, noite: noite)
        }
        func aFraseInteira() -> [EventoCalendario] { umDe(prosa).map { [$0] } ?? [] }

        let partes = prosa
            .replacingOccurrences(of: "\\s+e\\s+", with: "\n", options: .regularExpression)
            // o ditado com pontuação separa por ponto final; "14.30" não é ponto
            // final — o ponto só corta quando vem espaço (ou o fim) depois dele
            .replacingOccurrences(of: "\\.(?=\\s|$)", with: "\n", options: .regularExpression)
            .split(whereSeparator: { $0 == "\n" || $0 == ";" || $0 == "," })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard partes.count > 1 else { return aFraseInteira() }

        var lidos: [EventoCalendario] = []
        // o texto que gerou cada compromisso lido — para poder reler o último
        var brutos: [String] = []
        // partes sem marca, à espera da próxima que tenha
        var pendente: [String] = []

        for parte in partes {
            if temMarca(parte, agora: agora, cal, manha: manha, tarde: tarde, noite: noite) {
                // "12 de outubro, às 14h" parte em duas com marca nas duas, e a
                // segunda não tem título: junta-se à primeira em vez de sumir
                let junto = (pendente + [parte]).joined(separator: " e ")
                if let e = umDe(junto) {
                    lidos.append(e)
                    brutos.append(junto)
                    pendente = []
                    continue
                }
            }
            pendente.append(parte)
        }

        guard !pendente.isEmpty else { return lidos.isEmpty ? aFraseInteira() : lidos }
        // a cauda muda ("correr terça 6h e depois alongar") pertence ao último
        guard let ultimo = brutos.last,
              let e = umDe(([ultimo] + pendente).joined(separator: " e ")) else { return aFraseInteira() }
        lidos[lidos.count - 1] = e
        return lidos
    }

    /// Uma linha de NOTA que é compromisso: precisa de dia (ou repetição) E
    /// hora (ou "dia inteiro"). "reunião sexta 14h" entra; "ligar para a Ana"
    /// e "sexta" sozinhos não — a nota não vira agenda por acidente.
    nonisolated static func lerDatado(
        _ linha: String, agora: Date, _ cal: Calendar,
        manha: Int = 8, tarde: Int = 14, noite: Int = 20
    ) -> EventoCalendario? {
        let limpa = linha
            .replacingOccurrences(of: "^\\s*([-*#]+|\\d+\\.|\\[[ x]\\])\\s*", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard limpa.count >= 6 else { return nil }
        let temDia = comerRepeticao(limpa) != nil || comerDia(limpa, agora: agora, cal) != nil
        let temHora = comerHora(limpa, manha: manha, tarde: tarde, noite: noite) != nil || comerDiaInteiro(limpa) != nil
        guard temDia, temHora else { return nil }
        guard let e = ler(limpa, ancora: agora, agora: agora, cal, manha: manha, tarde: tarde, noite: noite),
              e.titulo.count >= 3 else { return nil }
        return e
    }

    /// A parte carrega dia, hora, repetição ou "dia inteiro"?
    nonisolated private static func temMarca(_ texto: String, agora: Date, _ cal: Calendar,
                                             manha: Int, tarde: Int, noite: Int) -> Bool {
        if comerRepeticao(texto) != nil { return true }
        if comerDia(texto, agora: agora, cal) != nil { return true }
        if comerDiaInteiro(texto) != nil { return true }
        if comerHora(texto, manha: manha, tarde: tarde, noite: noite) != nil { return true }
        return false
    }

    // MARK: dia

    /// Os sete dias da semana, com o número do `weekday` do Calendar.
    /// O plural conta: "todas as sextas" é como se diz — sem o `s?` opcional,
    /// `\bsexta\b` não casava em "sextas" e a série virava uma data só.
    nonisolated private static let diasDaSemana: [(String, Int)] = [
        (#"\b(domingos?|dom)\b"#, 1),
        (#"\b(segundas?(?:-feiras?)?|seg)\b"#, 2),
        (#"\b(ter[çc]as?(?:-feiras?)?|ter)\b"#, 3),
        (#"\b(quartas?(?:-feiras?)?|qua)\b"#, 4),
        (#"\b(quintas?(?:-feiras?)?|qui)\b"#, 5),
        (#"\b(sextas?(?:-feiras?)?|sex)\b"#, 6),
        (#"\b(s[áa]bados?|sab)\b"#, 7),
    ]

    /// "toda sexta e segunda", "todas as terças", "todo sábado" → os dias que
    /// repetem, e o texto sem eles. Sem a palavra de repetição, nil: aí é uma
    /// data só, e quem cuida é `comerDia`.
    nonisolated static func comerRepeticao(_ texto: String) -> (dias: [Int], resto: String)? {
        guard let marca = achar(#"\b(todas?\s+(?:as?\s+)?|todos?\s+(?:os?\s+)?)"#, texto) else { return nil }
        var resto = marca.resto
        var dias: Set<Int> = []
        // um dia pode aparecer mais de uma vez; cada passada come o que achou
        for (padrao, weekday) in diasDaSemana {
            while let m = achar(padrao, resto) {
                dias.insert(weekday)
                resto = m.resto
            }
        }
        guard !dias.isEmpty else { return nil }
        return (dias.sorted(), resto)
    }

    /// O primeiro dia, a partir de hoje (inclusive), que casa com a série.
    nonisolated static func primeiraOcorrencia(_ dias: [Int], aPartirDe agora: Date, _ cal: Calendar) -> Date {
        let hoje = Calendario.inicioDoDia(agora, cal)
        for passo in 0..<7 {
            guard let d = cal.date(byAdding: .day, value: passo, to: hoje) else { break }
            if dias.contains(cal.component(.weekday, from: d)) { return d }
        }
        return hoje
    }

    nonisolated private static func comerDia(
        _ texto: String,
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

        // o dia que vem PRIMEIRO NA FRASE, não o primeiro da nossa lista: com
        // "sexta e segunda", `segunda` ganhava por estar antes na lista e o
        // "sexta" sobrava no título
        let achados = diasDaSemana.compactMap { padrao, weekday in
            achar(padrao, texto).map { (m: $0, weekday: weekday) }
        }
        if let primeiro = achados.min(by: { $0.m.posicao < $1.m.posicao }) {
            // a partir de HOJE, nunca da âncora da tela: marcar segue o
            // relógio, como perguntar já seguia. Com a tela em julho, "segunda"
            // caía em julho e o compromisso nascia dois meses atrás.
            return (proximo(primeiro.weekday, aPartir: agora, cal), primeiro.m.resto)
        }
        return nil
    }

    /// O próximo weekday a partir da data dada, contando o próprio dia.
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

    /// O verbo do pedido não é o título: "me lembra de ligar para a Ana amanhã
    /// 15h" marca "Ligar para a Ana" (o campo recebe pedidos — dono, 14/09).
    nonisolated private static let verbosDePedido =
        #"^(?:me\s+)?(?:lembra|lembre|lembrar|marca|marcar|marque|agenda|agendar|agende|coloca|colocar|coloque|anota|anotar|anote|adiciona|adicionar|adicione|bota|botar)(?:\s+me)?(?:\s+(?:de|um|uma|o|a))?\s+"#

    nonisolated private static func limparTitulo(_ texto: String) -> String {
        var palavras = texto
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: " ,.-–"))
            .replacingOccurrences(of: verbosDePedido, with: "", options: [.regularExpression, .caseInsensitive])
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
        /// Onde casou. Com dois dias na frase ("sexta e segunda"), quem manda é
        /// a ordem da FRASE, não a ordem da nossa lista.
        var posicao: Int
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
        return Achado(texto: String(texto[todo]), grupos: grupos, resto: resto, posicao: m.range.location)
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
        let data = try enc.encode(eventos.filter(\.editavel))
        try data.write(to: url, options: .atomic)
    }
}

// MARK: - ADR 2026-09-04a: o próximo compromisso sai do app

extension ProximoCompromisso {
    /// Publica os próximos compromissos das duas semanas seguintes no App
    /// Group, para o widget e para a Ilha.
    ///
    /// Deixa de nota não entra: a nota é a dona dela, já tem o próprio gatilho,
    /// e o selo vale para a tela bloqueada como vale para a rede. O que veio do
    /// iPhone entra (é contexto do dia do autor), mas nunca promete aviso —
    /// quem avisa por ele é o app Calendário, que é o dono.
    /// `mudo` é o compromisso cujo alarme o sistema RECUSOU (sem permissão,
    /// sem espaço, hora passada): ele aparece, mas sem sino — a tela não
    /// promete o que não vai acontecer. E quando os avisos do Traço estão
    /// desligados no iPhone, NENHUM sino sai: `mudo` valia para um evento só,
    /// e a revogação global não silenciava nada (revisão G3, A2).
    static func publicar(_ eventos: [EventoCalendario], cal: Calendar,
                         manha: Int = Ancora.hora(.manha), agora: Date = .now,
                         mudo: UUID? = nil) {
        // Os compromissos do iPhone entram AQUI, de uma fonte só, e não pela
        // lista que o chamador trouxe: das seis rotas de publicação, só a do
        // calendário os juntava, e a do Trabalho — que corre a cada commit da
        // Oficina — reescrevia a Superfície sem eles (auditoria 17/09).
        let fatias = proximasFatias(eventos + CalendarioSistema.naSuperficie,
                                    cal: cal, manha: manha, agora: agora, mudo: mudo)
        publicar(fatias, agora: agora)
        FilaDeAtividade.compartilhada.enfileirar {
            await atualizarAtividade(fatias.first, agora: agora)
        }
    }

    /// Seleção sem efeitos externos, compartilhada pela publicação e seus testes.
    static func proximaFatia(_ eventos: [EventoCalendario], cal: Calendar,
                             manha: Int, agora: Date, mudo: UUID? = nil) -> Fatia? {
        proximasFatias(eventos, cal: cal, manha: manha, agora: agora, mudo: mudo).first
    }

    /// Deixa de nota não entra. Ação de Trabalho elegível entra: o selo já a
    /// tirou em `CalendarioTrabalho.eventos`. Uma tesoura só (ADR 2026-09-11a).
    nonisolated static func candidatosAoProximo(_ eventos: [EventoCalendario]) -> [EventoCalendario] {
        eventos.filter { !$0.eDeixa }
    }

    /// Todas as ocorrências do horizonte, em ordem. Quem corta em `candidatas`
    /// é `publicar` — e corta CONTANDO (ADR 06d, achado A do G4): a face
    /// precisa saber quantos ficaram de fora para não fechar um número falso.
    /// O widget continua virando de uma candidata para a outra sem acordar o
    /// app (ADR 05u); o que mudou foi só onde a tesoura mora.
    static func proximasFatias(_ eventos: [EventoCalendario], cal: Calendar,
                               manha: Int, agora: Date, mudo: UUID? = nil) -> [Fatia] {
        let ate = fimDoHorizonte(agora: agora, cal: cal)
        let vivos = candidatosAoProximo(eventos)
        return Calendario.ocorrencias(vivos, de: agora, a: ate, cal)
            .filter { $0.fim > agora }
            .sorted { $0.inicio < $1.inicio }
            .map { e in
                Fatia(id: e.id, titulo: e.titulo, inicio: e.inicio, fim: e.fim,
                      diaInteiro: e.diaInteiro,
                      aviso: (!e.eDeixa && !e.doSistema && e.avisoMinutos != nil
                              && e.id != mudo && Avisos.permitidosNoUltimoOlhar)
                          ? Aviso.instante(de: e, cal, manha: manha) : nil,
                      lembrarEm: nil, doSistema: e.doSistema)
            }
    }
}
