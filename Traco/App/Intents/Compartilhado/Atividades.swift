import ActivityKit
import Foundation

/// As duas Live Activities do Traço. Só atributos e estado: quem pede,
/// atualiza e encerra é o app (`DestaqueDoDia`, `ProximoCompromisso`).

/// O Destaque vivo (COLHEITA: Forest, Wallet, Clear, Taio, Stoic): a única
/// coisa de hoje, na tela bloqueada e na Ilha, enquanto o dia dura.
/// Uma linha do autor; nunca expressiva, nunca trancada.
nonisolated struct DestaqueAtividade: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var linha: String
        /// ADR 08h: o MESMO contrato do widget — a linha aqui é a mesma
        /// projeção, cortada pelo mesmo teto, e a Ilha diz se é trecho.
        var inteira: Bool? = nil
    }

    /// ADR 05u: a atividade sabe DE QUEM é. O botão devolve `id` e `dia` ao

    /// app, que revalida antes de marcar — "o próximo atual" não existe mais.
    var dia: String
    var id: UUID
}

/// O compromisso vivo: título e a conta que corre até a hora.
/// O sistema desenha o tempo (`Text(style:)`), então ela anda sozinha sem o
/// app acordar — que é o único jeito honesto de uma contagem na Ilha.
nonisolated struct CompromissoAtividade: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var titulo: String
        var inicio: Date
        var fim: Date
        var diaInteiro: Bool
        /// ADR 04f: a soneca pedida na tela bloqueada. `nil` = ninguém pediu.
        var lembrarEm: Date?
        /// O que impediu o toque de virar alarme. Botão que não faz nada e não
        /// diz nada é o defeito da ADR 04a de novo, agora do tamanho de um dedo.
        var recado: String?
    }

    /// A ocorrência a que esta atividade pertence (`Superficie.ocorrencia`:
    /// id + início). Trocar de compromisso encerra a anterior: uma por vez.
    var chave: String
}
