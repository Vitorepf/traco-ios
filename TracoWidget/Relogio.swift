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

/// Onde o estado honesto aparece na face (R1 da revisão Re-G3).
///
/// A F4-B tirou o estado do cabeçalho, onde ele saía truncado, e o desceu para
/// a linha do conteúdo. Só que na view ele virou o ÚLTIMO ramo de um `if/else`
/// — e bastava haver Destaque posto para ele nunca ser alcançado: passado o
/// horizonte, o widget do Traço largava a agenda inteira e ficava CALADO.
/// Verdade truncada trocada por silêncio, no defeito que abriu a volta.
///
/// A lei é uma só e não é da view: **passada a validade, toda face diz**. O
/// que muda é o LUGAR — havendo conteúdo em cima, o estado desce ao rodapé;
/// não havendo, ele é o próprio miolo e carrega a ação. Mora aqui, fora do
/// SwiftUI, para caber numa suíte: um `if/else` de view não tem teste, e foi
/// exatamente um `if/else` de view que regrediu.
nonisolated enum EstadoNaFace: Equatable {
    /// Instantâneo fresco: não há estado a dizer.
    case nenhum
    /// Não há conteúdo: o estado É o miolo, com a ação de recuperação.
    case miolo
    /// Há conteúdo velho em cima: o estado desce ao rodapé, sem sumir.
    case rodape

    static func de(velha: Bool, temConteudo: Bool) -> EstadoNaFace {
        guard velha else { return .nenhum }
        return temConteudo ? .rodape : .miolo
    }

    var diz: Bool { self != .nenhum }
}

/// Quantas linhas a frase de estado pode ocupar antes de o SwiftUI partir a
/// palavra ao meio (re-G3 N2).
///
/// Com teto maior que 1 o SwiftUI prefere HIFENIZAR a encolher, e
/// "Desatualizado." saía `Desatualiza-/do.` no pequeno em AX5 — a mesma
/// família do `PRÓXI-/MO` que derrubou a F4, agora na própria palavra que diz
/// a verdade. Numa palavra só não há quebra honesta: uma linha, e o
/// `minimumScaleFactor` encolhe a palavra inteira, como em `Velho()`. Havendo
/// espaço, quebrar linha é melhor que encolher — a frase sai no corpo cheio.
///
/// Está aqui, e não na view, pela mesma razão de `EstadoNaFace`: um `if` de
/// view não tem suíte, e foi um corte de view que derrubou esta volta.
nonisolated enum LinhasDoEstado {
    static func de(_ frase: String, teto: Int = 3) -> Int {
        frase.contains(" ") ? teto : 1
    }
}
