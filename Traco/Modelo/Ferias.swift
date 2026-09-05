import Foundation

/// ADR 2026-09-04e — o modo férias.
///
/// O Traço é um app que COBRA: a fila do Recordar toca todo dia na hora do
/// autor, a revisão da semana toca domingo à noite, e a série da expressiva
/// cobra quatro dias seguidos. Isso é o método, e é por isso que ele funciona.
///
/// Mas não havia como dizer "estou fora". Quem viaja levava o ritual junto —
/// e um ritual que não se pode pausar não é ritual, é sino. Pior: o autor
/// aprende a ignorar a notificação, e aí ela morreu para sempre (o custo real
/// não é o incômodo de uma semana, é a cobrança que deixa de funcionar quando
/// ele voltar).
///
/// **A linha que separa o que cala do que continua:** o Traço cala o que ELE
/// inventou de cobrar — memória, revisão, série. O que o AUTOR marcou continua
/// tocando: compromisso e aviso do "Se". Férias não desmarca dentista.
///
/// Feriado é uma escolha à parte, e desligada por padrão: um feriado é dia em
/// casa, e dia em casa é bom dia para recordar. Quem discordar liga.
nonisolated enum Ferias {
    private static let chaveLigado = "feriasLigado"
    private static let chaveAte = "feriasAte"
    private static let chaveFeriados = "feriasIncluiFeriados"

    private static var d: UserDefaults { .standard }

    /// Está de férias AGORA. Expira sozinho: o autor não tem de lembrar de
    /// desligar (§17 — lembrar de um recurso é fricção, e fricção é bug).
    nonisolated static func vigente(agora: Date = .now) -> Bool {
        guard d.bool(forKey: chaveLigado) else { return false }
        guard let ate = ate else { return true }
        return agora < fimDoDia(ate)
    }

    nonisolated static var ligado: Bool {
        get { d.bool(forKey: chaveLigado) }
        set {
            d.set(newValue, forKey: chaveLigado)
            if !newValue { d.removeObject(forKey: chaveAte) }
        }
    }

    /// Último dia das férias (inclusive). `nil` = até o autor desligar.
    nonisolated static var ate: Date? {
        get {
            let t = d.double(forKey: chaveAte)
            return t > 0 ? Date(timeIntervalSince1970: t) : nil
        }
        set { d.set(newValue?.timeIntervalSince1970 ?? 0, forKey: chaveAte) }
    }

    /// Calar também nos feriados. Desligado por padrão, de propósito.
    nonisolated static var incluiFeriados: Bool {
        get { d.bool(forKey: chaveFeriados) }
        set { d.set(newValue, forKey: chaveFeriados) }
    }

    /// Passou da data: desliga e devolve `true` se mudou alguma coisa — quem
    /// chama reagenda o que estava calado.
    @discardableResult
    nonisolated static func expirarSePassou(agora: Date = .now) -> Bool {
        guard d.bool(forKey: chaveLigado), let ate = ate, agora >= fimDoDia(ate) else { return false }
        ligado = false
        return true
    }

    /// Este dia cobra ou cala?
    /// As duas razões somam: um feriado DEPOIS do fim das férias continua
    /// calado se o autor ligou os feriados. A versão que testava as férias
    /// primeiro engolia essa combinação.
    nonisolated static func cala(_ dia: Date, cal: Calendar = Calendario.gregoriano(),
                                 agora: Date = .now) -> Bool {
        if incluiFeriados, Feriados.eFeriado(dia, cal) { return true }
        guard vigente(agora: agora) else { return false }
        guard let ate = ate else { return true }
        return Calendario.inicioDoDia(dia, cal) <= Calendario.inicioDoDia(ate, cal)
    }

    /// Os dias que COBRAM na janela — a fila diária é montada a partir disto.
    /// Vazio = ninguém cobra nesta janela, e aí não se agenda nada.
    nonisolated static func diasQueCobram(de inicio: Date, dias: Int,
                                          cal: Calendar = Calendario.gregoriano(),
                                          agora: Date = .now) -> [Date] {
        (0..<max(0, dias)).compactMap { n -> Date? in
            guard let dia = cal.date(byAdding: .day, value: n, to: Calendario.inicioDoDia(inicio, cal))
            else { return nil }
            return cala(dia, cal: cal, agora: agora) ? nil : dia
        }
    }

    /// Há algum dia calado na janela? Se não há, a fila pode ser UMA
    /// notificação repetente (um slot do orçamento em vez de catorze).
    nonisolated static func haSilencio(de inicio: Date, dias: Int,
                                       cal: Calendar = Calendario.gregoriano(),
                                       agora: Date = .now) -> Bool {
        diasQueCobram(de: inicio, dias: dias, cal: cal, agora: agora).count < dias
    }

    /// O primeiro dia em que se pode cobrar, a partir de um dia dado. Serve à
    /// série da expressiva: ela não morre nas férias, ela espera.
    nonisolated static func primeiroDiaQueCobra(aPartirDe dia: Date,
                                                cal: Calendar = Calendario.gregoriano(),
                                                agora: Date = .now) -> Date {
        var alvo = dia
        for _ in 0..<60 {
            guard cala(alvo, cal: cal, agora: agora) else { return alvo }
            alvo = cal.date(byAdding: .day, value: 1, to: alvo) ?? alvo
        }
        return alvo
    }

    /// A linha honesta do Perfil: o que está calado, e até quando.
    nonisolated static func emPalavras(agora: Date = .now,
                                       cal: Calendar = Calendario.gregoriano()) -> String {
        guard vigente(agora: agora) else {
            return incluiFeriados
                ? "desligado. Nos feriados o Traço também cala."
                : "desligado. O Traço cobra todo dia, como sempre."
        }
        guard let ate = ate else {
            return "ligado, sem data. Nada te cobra memória até você desligar — os seus compromissos continuam avisando."
        }
        return "ligado até \(Calendario.formatar(ate, "d 'de' MMMM", cal)). Os seus compromissos continuam avisando."
    }

    nonisolated private static func fimDoDia(_ dia: Date,
                                             cal: Calendar = Calendario.gregoriano()) -> Date {
        cal.date(byAdding: .day, value: 1, to: Calendario.inicioDoDia(dia, cal))
            ?? dia.addingTimeInterval(86400)
    }
}
