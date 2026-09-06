import Foundation

/// ADR 06d (F4) — a linha do tempo que NÃO congela.
///
/// A F2 fechou as duas linhas com `policy: .never` (`.atEnd` só quando havia
/// mais de uma entrada). O efeito no iPhone do dono, 06/09 às 13:04: os dois
/// widgets diziam "atualizado às 04:14" — nove horas parados. `.never` é uma
/// promessa de que o app SEMPRE vai conseguir pedir a recarga; e o app não
/// abre à noite, e o pedido já foi recusado antes (ChronoCore 27, A1 da F2).
///
/// Aqui a regra é: as ENTRADAS desenham o dia (elas não custam orçamento —
/// custa recarregar), e a POLÍTICA garante a releitura do disco. Nunca
/// `.never`, nunca por minuto.
///
/// Só aritmética de datas, de propósito: assim a lei que faltava à F2 cabe
/// numa suíte (`LinhaDoTempoWidgetTests`) sem WidgetKit e sem App Group.
nonisolated enum Relogio {
    /// De quanto em quanto tempo o widget relê o disco por conta própria:
    /// ~8 releituras por dia, muito abaixo do orçamento do WidgetKit, e o
    /// bastante para que "abra o Traço" nunca seja a única saída.
    static let releitura: TimeInterval = 3 * 3600
    /// Piso: nem com transições próximas o widget pede recarga em rajada.
    static let minimo: TimeInterval = 15 * 60
    /// A hora em que o compromisso deixa de ser "mais tarde" e vira "agora".
    static let vespera: TimeInterval = 3600

    /// Depois de quando o sistema deve pedir a próxima linha do tempo.
    static func voltar(agora: Date, ultima: Date?) -> Date {
        let teto = agora.addingTimeInterval(releitura)
        return max(min(ultima ?? teto, teto), agora.addingTimeInterval(minimo))
    }

    /// As datas do dia, ao longo do dia.
    ///
    /// - Parameters:
    ///   - base: o que a superfície já sabe (`Superficie.transicoes`: agora, o
    ///     fim de cada próximo, a soneca e o horizonte).
    ///   - inicios: o começo de cada compromisso que ainda não acabou.
    /// Entram também a VÉSPERA de cada começo (quando a linha passa a chamar
    /// atenção) e a MEIA-NOITE (quando o Destaque de hoje deixa de ser o de
    /// hoje). Entrada não custa orçamento — recarga custa —, então o dia
    /// inteiro é desenhado de uma vez e o widget vira sozinho.
    static func datas(base: [Date], inicios: [Date], agora: Date,
                      cal: Calendar = .current) -> [Date] {
        var datas = Set(base)
        datas.insert(cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: agora) ?? agora))
        for i in inicios {
            datas.insert(i)
            datas.insert(i.addingTimeInterval(-vespera))
        }
        return datas.sorted().filter { $0 >= agora }
    }
}
