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

/// O que a face pode dizer sobre o que NÃO está nela (G4 da F4, achado A).
///
/// Num dia de cinco compromissos a superfície carrega três e o pequeno
/// imprimia **"+2 depois"**: uma contagem exata sobre uma lista que ele mesmo
/// sabia cortada. O dono lia "+2" e acreditava que o dia tinha três. Tinha
/// cinco. Número errado é pior que nenhum, porque encerra a dúvida.
///
/// A correção é das duas metades ao mesmo tempo: o instantâneo passou a
/// carregar quantos ficaram de fora (`Superficie.alemDaLista`) e a face só
/// publica número quando ele existe. Instantâneo velho, gravado antes desta
/// conta, não sabe — e aí a face diz "mais depois", que é verdade, em vez de
/// um número que não é.
///
/// Mora aqui, fora do SwiftUI, pela mesma razão de `EstadoNaFace`: um `if` de
/// view não tem suíte, e foi um `if` de view que derrubou esta volta.
nonisolated enum Restantes: Equatable {
    /// A face mostra o dia inteiro.
    case nenhum
    /// Faltam exatamente estes.
    case exato(Int)
    /// Há mais, e a face não sabe quantos: então não inventa número.
    case algunsMais

    /// - Parameters:
    ///   - naFace: quantos dos publicados a face está mostrando.
    ///   - publicados: quantos o instantâneo carrega (já sem os que acabaram).
    ///   - alem: quantos ficaram de fora do instantâneo; `nil` = não sabe.
    static func de(naFace: Int, publicados: Int, alem: Int?) -> Restantes {
        let naLista = max(0, publicados - max(0, naFace))
        guard let alem else { return .algunsMais }
        let total = naLista + max(0, alem)
        return total > 0 ? .exato(total) : .nenhum
    }

    /// A linha da face. `nil` quando não há o que dizer — e a face não gasta
    /// altura dizendo que não há nada.
    var frase: String? {
        switch self {
        case .nenhum: nil
        case .exato(let n): "+\(n) depois"
        case .algunsMais: "mais depois"
        }
    }

    /// A mesma coisa, na ordem em que o autor ouve.
    var emVoz: String? {
        switch self {
        case .nenhum: nil
        case .exato(let n): "mais \(n) depois"
        case .algunsMais: "e mais depois"
        }
    }
}

/// Quanto um RÓTULO pode encolher antes de a face desistir (F5, ADR 08h).
///
/// Só rótulos encolhem: marca, estado, oferta — texto NOSSO, curto e
/// reescrevível. Se não couber a 60%, o conserto é escrever mais curto.
///
/// A frase do autor NÃO passa por aqui. A F4-F lhe deu um piso de 0,35 e o
/// G4 mediu o preço: em AX5 a frase saía no mesmo corpo de ~11 pt de quem não
/// ligou acessibilidade — o encolhimento comia o aumento que a pessoa pediu —
/// e com 247 caracteres desenhava onze linhas a ~7 pt e ainda cortava. A
/// frase mantém o corpo do papel escolhido e reduz a QUANTIDADE de texto; o
/// que não cabe termina em "…" (`Sacrificio`, e a ADR 08h para a regra).
nonisolated enum Encolhe {
    static let rotulo: CGFloat = 0.6
}

/// A ordem de sacrifício do pequeno com Destaque (ADR 08h).
///
/// O que não cede: o rodapé "Desatualizado." e a legibilidade da frase — o
/// corpo de leitura não é a última moeda para pagar a falta de espaço. O que
/// cede, nesta ordem: primeiro o rótulo de caminho "Nova nota" (é redundante
/// — o cartão inteiro já é o toque, e o G4 provou que ele não é alvo
/// independente); só depois a QUANTIDADE de frase, com corte honesto.
///
/// Cada candidato é "n linhas da frase, com ou sem o rótulo"; a face prova os
/// candidatos em ordem (`ViewThatFits`) e fica com o primeiro que cabe. Para
/// cada n, o candidato COM rótulo vem antes do sem — assim o rótulo só entra
/// quando não custa uma linha da frase. Mora aqui, fora do SwiftUI, para que a
/// ordem tenha suíte: foi um `if` de view que decidia isso na F4-F.
nonisolated enum Sacrificio {
    nonisolated struct Candidato: Hashable, Sendable {
        let linhas: Int
        let rotulo: Bool
    }

    /// Quantas linhas, no máximo, a face tenta — o pequeno em tamanho normal
    /// cabe cinco; oito cobre qualquer família que passe por aqui.
    static let maximo = 8

    static func candidatos(maximo: Int = maximo, rotulo: Bool) -> [Candidato] {
        (1...max(1, maximo)).reversed().flatMap { n in
            rotulo ? [Candidato(linhas: n, rotulo: true), Candidato(linhas: n, rotulo: false)]
                   : [Candidato(linhas: n, rotulo: false)]
        }
    }
}


/// Até quantas linhas a frase do autor pode crescer no médio (F5, ADR 08h).
///
/// Com agenda embaixo, duas: a agenda só existe ali e fica com o pé do cartão.
/// Sem agenda, o layout decide (`Sacrificio.maximo`): na F4-H o teto de duas
/// linhas com o rodapé "Desatualizado." deixava três linhas de cartão VAZIAS
/// entre a frase cortada e o rodapé — corte evitável, que é a falha que a
/// regra do corte honesto nomeia. O rodapé não precisa de teto para existir:
/// ele tem prioridade de layout menor e o VStack lhe garante a linha.
///
/// Mora fora do SwiftUI pela razão de sempre: um `if` de view não tem suíte, e
/// foram `if`s de view que derrubaram esta família quatro vezes.
nonisolated enum LinhasDoDestaque {
    static func noMedio(comAgenda: Bool) -> Int {
        comAgenda ? 2 : Sacrificio.maximo
    }
}

