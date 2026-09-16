import Foundation

/// A latência da descoberta (ADR 2026-09-06j): quanto tempo entre AFIRMAR uma
/// coisa e SABER que estava certo ou errado. Nada aqui é campo novo — tudo já
/// estava gravado e ninguém lia: a hipótese tem `data` e `avaliadaEm` (ADR 05r),
/// a decisão tem "o que espero, e quando eu confiro" e "o que aconteceu"
/// (ADR 03a/04t), e o histórico de versões (`Versoes`) datou cada gravação.
///
/// Não é placar. Não conta sequência, não pontua, não compara com meta e não
/// tem cor de bom ou ruim. Quatro estados distintos e nenhum deles é falha:
/// AFIRMADO (dito, ainda não é hora), DEVIDO (a hora chegou e continua sem
/// resposta), DESCOBERTO (soube — com ou sem a data de quando) e ABANDONADO
/// (fechou sem conferir, que é resultado legítimo).
///
/// O que interessa é a SÉRIE: uma latência sozinha não diz nada. E a série só é
/// honesta com os abertos ao lado dos fechados — medir só o que fechou é
/// exatamente o viés de sobrevivência que a ideia desta volta veio combater.
nonisolated enum Latencia {
    enum Estado: String, Sendable, CaseIterable {
        case afirmado, devido, descoberto, abandonado
    }
    enum Fonte: String, Sendable { case hipotese, decisao }

    /// Uma afirmação com data. `descobertoEm == nil` em estado `.descoberto`
    /// é o registro antigo: descobriu, e QUANDO não está gravado. A tela diz
    /// "tempo desconhecido"; ninguém reconstrói a data por dedução (ADR 05r).
    struct Registro: Sendable, Equatable, Identifiable {
        var id: UUID
        var fonte: Fonte
        var texto: String
        var afirmadoEm: Date
        var devidoEm: Date?
        var descobertoEm: Date?
        var estado: Estado
        /// ADR 05r: quem PROPÔS a hipótese. Só a hipótese tem proponente — a
        /// decisão é escrita do autor —, e `nil` na hipótese é o registro
        /// anterior à 05r, que a tela diz não saber em vez de deduzir.
        var propostaPor: String?

        /// A marca de autoria, ou `nil` quando é o próprio autor. A latência de
        /// uma hipótese que a IA propôs não é a latência do autor, então ela vem
        /// escrita — no molde de `TrabalhoView`, que já imprime essa linha.
        var autoria: String? {
            guard fonte == .hipotese else { return nil }
            guard let quem = propostaPor?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !quem.isEmpty else { return "autoria desconhecida" }
            return quem.caseInsensitiveCompare("Você") == .orderedSame ? nil : "proposta por " + quem
        }

        /// Dias entre afirmar e descobrir. `nil` quando não descobriu ainda ou
        /// quando a data da descoberta não foi gravada.
        var dias: Int? {
            guard estado == .descoberto, let descobertoEm else { return nil }
            return Self.dias(de: afirmadoEm, a: descobertoEm)
        }
        /// Há quantos dias está em aberto. `nil` para quem já fechou.
        func diasEmAberto(agora: Date = .now) -> Int? {
            guard estado == .afirmado || estado == .devido else { return nil }
            return Self.dias(de: afirmadoEm, a: agora)
        }
        /// Tempo decorrido, não diferença de calendário: 23h→01h é meio dia, e
        /// arredondar para 1 inflaria a série inteira.
        static func dias(de: Date, a: Date) -> Int {
            max(0, Int(a.timeIntervalSince(de) / 86_400))
        }
    }

    // MARK: - Ler o que já está gravado

    /// As hipóteses de um trabalho. Sem data de conferir, elas nunca ficam
    /// `.devido`: cobrar prazo que o autor não marcou seria inventar.
    static func registros(hipoteses: [DocumentoTrabalho.Hipotese], encerrado: Bool) -> [Registro] {
        hipoteses.map { h in
            let avaliada = h.estado != .proposta || h.avaliadaEm != nil
            return Registro(
                id: h.id, fonte: .hipotese,
                texto: h.texto.trimmingCharacters(in: .whitespacesAndNewlines),
                afirmadoEm: h.data, devidoEm: nil,
                descobertoEm: avaliada ? h.avaliadaEm : nil,
                estado: avaliada ? .descoberto : (encerrado ? .abandonado : .afirmado),
                propostaPor: h.propostaPor)
        }
    }

    /// Uma nota de Decisão. A data da descoberta NÃO é `editadaEm` — essa é a
    /// última edição de qualquer coisa e mentiria a cada retoque. Vem do
    /// histórico: `Versoes` guarda o estado ANTERIOR carimbado com a hora da
    /// gravação, então a versão mais recente que ainda tinha "o que aconteceu"
    /// vazio é a hora em que ele deixou de estar vazio. Sem histórico (nota
    /// importada, ou 30 versões passaram por cima), fica `nil`: tempo
    /// desconhecido, sem inventar.
    static func registro(decisao uuid: UUID, campos: [String: String], criadaEm: Date,
                         fechada: Bool, agora: Date = .now,
                         versoes: (UUID) -> [VersaoNota] = Versoes.listar) -> Registro? {
        // O selo, na regra do vizinho de cima na mesma tela (o retrato): nota
        // trancada ou queimada não entra na latência, NEM COMO CONTAGEM. Uma
        // duração medida a partir do que o selo fechou é mais do que contar, e
        // a guarda fica aqui — no funil por onde toda leitura de decisão passa.
        guard !fechada else { return nil }
        let texto = primeiroPreenchido(campos, ["escolha", "decidido", "espero"])
        let devidoEm = Gatilho.data(em: campos["espero"] ?? "", agora: criadaEm)
        let respondeu = !vazio(campos["aconteceu"])
        var estado: Estado = .afirmado
        if respondeu {
            estado = .descoberto
        } else if (devidoEm ?? criadaEm) <= agora {
            estado = .devido
        }
        return Registro(
            id: uuid, fonte: .decisao, texto: texto, afirmadoEm: criadaEm, devidoEm: devidoEm,
            descobertoEm: respondeu ? quandoRespondeu(uuid, versoes: versoes) : nil,
            estado: estado)
    }

    /// A gravação em que "o que aconteceu" deixou de estar vazio.
    private static func quandoRespondeu(_ uuid: UUID, versoes: (UUID) -> [VersaoNota]) -> Date? {
        versoes(uuid).sorted { $0.data > $1.data }.first { vazio($0.campos["aconteceu"]) }?.data
    }

    private static func vazio(_ s: String?) -> Bool {
        (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private static func primeiroPreenchido(_ campos: [String: String], _ ids: [String]) -> String {
        for id in ids {
            let v = (campos[id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !v.isEmpty { return String(v.prefix(120)) }
        }
        return ""
    }

    // MARK: - A série

    /// Um mês de descobertas. `mediana` em dias — mediana, não média: uma
    /// hipótese esquecida por um ano não desloca o mês inteiro.
    struct Mes: Sendable, Equatable, Identifiable {
        var inicio: Date
        var quantas: Int
        var mediana: Int
        var id: Date { inicio }
    }

    /// A leitura inteira. Os abertos viajam junto dos fechados de propósito.
    struct Serie: Sendable, Equatable {
        var meses: [Mes] = []
        var descobertos: [Registro] = []
        var abertos: [Registro] = []
        var abandonados: [Registro] = []
        /// Descobriu, mas a data não está gravada. Não entra em nenhum mês.
        var semData: [Registro] = []
        var vazia: Bool {
            descobertos.isEmpty && abertos.isEmpty && abandonados.isEmpty && semData.isEmpty
        }
        /// A mediana de tudo que tem os dois carimbos.
        var medianaGeral: Int? { Latencia.mediana(descobertos.compactMap(\.dias)) }
    }

    static func serie(_ registros: [Registro], agora: Date = .now,
                      cal: Calendar = .current) -> Serie {
        var s = Serie()
        for r in registros {
            switch r.estado {
            case .descoberto: r.dias == nil ? s.semData.append(r) : s.descobertos.append(r)
            case .afirmado, .devido: s.abertos.append(r)
            case .abandonado: s.abandonados.append(r)
            }
        }
        s.descobertos.sort { ($0.descobertoEm ?? .distantPast) < ($1.descobertoEm ?? .distantPast) }
        // o mais velho em aberto primeiro: é o que o autor quer reconhecer
        s.abertos.sort { $0.afirmadoEm < $1.afirmadoEm }
        s.abandonados.sort { $0.afirmadoEm < $1.afirmadoEm }
        s.semData.sort { $0.afirmadoEm < $1.afirmadoEm }

        var porMes: [Date: [Int]] = [:]
        for r in s.descobertos {
            guard let dias = r.dias, let quando = r.descobertoEm,
                  let inicio = cal.date(from: cal.dateComponents([.year, .month], from: quando))
            else { continue }
            porMes[inicio, default: []].append(dias)
        }
        s.meses = porMes.keys.sorted().map {
            Mes(inicio: $0, quantas: porMes[$0]?.count ?? 0, mediana: mediana(porMes[$0] ?? []) ?? 0)
        }
        return s
    }

    /// O que cabe na tela, com cota POR ESTADO. Cortar no total apaga os
    /// fechados assim que os abertos passam de doze — a tela viraria doze
    /// contadores de dívida, que é o contrário do que a série promete. A cota
    /// garante que cada estado sobrevive ao corte quando existe: 2 devidos e o
    /// resto de 4 em afirmados (os mais velhos, na ordem do tempo), 2 sem data,
    /// 4 descobertos (os mais recentes) e 2 abandonados. Teto de doze linhas.
    static func paraTela(_ s: Serie) -> [Registro] {
        let devidos = s.abertos.filter { $0.estado == .devido }.prefix(2)
        let afirmados = s.abertos.filter { $0.estado == .afirmado }.prefix(4 - devidos.count)
        let abertos = (devidos + afirmados).sorted { $0.afirmadoEm < $1.afirmadoEm }
        return abertos + s.semData.prefix(2)
            + s.descobertos.reversed().prefix(4) + s.abandonados.prefix(2)
    }

    static func mediana(_ v: [Int]) -> Int? {
        guard !v.isEmpty else { return nil }
        let o = v.sorted()
        let m = o.count / 2
        return o.count.isMultiple(of: 2) ? (o[m - 1] + o[m] + 1) / 2 : o[m]
    }

    // MARK: - Em palavras

    /// "menos de um dia", "1 dia", "23 dias".
    static func emDias(_ dias: Int) -> String {
        switch dias {
        case ..<1: "menos de um dia"
        case 1: "1 dia"
        default: "\(dias) dias"
        }
    }

    /// A linha da série. Descreve, não julga: nem "melhorou" nem "piorou".
    static func emPalavras(_ s: Serie, agora: Date = .now) -> String {
        guard !s.vazia else { return "" }
        var partes: [String] = []
        // "mediana" fica no código; na tela é "a do meio", que se lê sem glossário
        if let m = s.medianaGeral {
            partes.append("\(s.descobertos.count) descoberta\(s.descobertos.count == 1 ? "" : "s") com as duas datas · a do meio levou \(emDias(m))")
        }
        if !s.semData.isEmpty { partes.append("\(s.semData.count) sem a data da descoberta") }
        if !s.abertos.isEmpty { partes.append("\(s.abertos.count) em aberto") }
        if !s.abandonados.isEmpty { partes.append("\(s.abandonados.count) abandonada\(s.abandonados.count == 1 ? "" : "s")") }
        return partes.joined(separator: " · ")
    }

    static func rotulo(_ estado: Estado) -> String {
        switch estado {
        // as palavras das Notas, não as do modelo (auditoria 16/09 noite: "devido")
        case .afirmado: "esperando"
        case .devido: "hora de conferir"
        case .descoberto: "conferida"
        case .abandonado: "fechada"
        }
    }
}
