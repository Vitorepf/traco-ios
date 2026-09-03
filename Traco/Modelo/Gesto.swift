import Foundation

enum Gesto: String, CaseIterable, Codable, Identifiable {
    case woop
    case seEntao
    case spec
    case notaPermanente
    case destaque
    case expressiva
    case destilar
    case palavra
    /// Diário de decisão (Kahneman/Klein): a escolha, as opções, o critério e
    /// o que eu espero — para comparar depois com o que aconteceu.
    case decisao
    /// Pré-mortem (Gary Klein, 2007): imaginar que já falhou e explicar por quê.
    case premortem

    var id: String { rawValue }

    /// Import/export aceitam o nome de exibição ("WOOP") E o rawValue ("woop") —
    /// o roundtrip do corpus nunca perde o gesto por causa da grafia.
    static func doNome(_ s: String) -> Gesto? {
        let alvo = s.trimmingCharacters(in: .whitespaces)
        return Gesto(rawValue: alvo) ?? allCases.first { $0.nome.caseInsensitiveCompare(alvo) == .orderedSame }
    }

    var nome: String {
        switch self {
        case .woop: "WOOP"
        case .seEntao: "Se–então"
        // "Spec" era o único nome em inglês entre cinco em português — jargão
        // de programador num app de escrever (o próprio arquivo manda: rótulos
        // na língua de quem escreve). rawValue segue "Spec": o corpus antigo
        // importa por doNome.
        case .spec: "Especificação"
        case .notaPermanente: "Nota permanente"
        case .destaque: "Destaque"
        case .expressiva: "Expressiva"
        case .destilar: "Destilar"
        case .palavra: "Palavra"
        case .decisao: "Decisão"
        case .premortem: "Pré-mortem"
        }
    }

    /// O que o app RECONHECEU no texto — não um elogio, não uma conclusão:
    /// a razão da classificação, para o autor poder discordar dela.
    var reconhecimento: String {
        switch self {
        case .woop: "isto é um desejo com obstáculo pela frente."
        case .seEntao: "isto é um hábito que trava num gatilho."
        case .spec: "isto tem problema e critério de pronto."
        case .notaPermanente: "isto é uma ideia que vale guardar inteira."
        case .destaque: "isto parece a lista do seu dia."
        case .expressiva: "isto é desabafo — pede tempo e porta fechada."
        case .destilar: "isto pede ser cortado até sobrar uma frase."
        case .palavra: "isto é uma palavra que você quer poder usar."
        case .decisao: "isto é uma escolha entre caminhos."
        case .premortem: "isto é um plano que ainda não imaginou a própria falha."
        }
    }

    nonisolated var campos: [CampoForma] {
        switch self {
        case .woop:
            [
                CampoForma(id: "resultado", rotulo: "Resultado (o melhor desfecho)"),
                CampoForma(id: "obstaculo", rotulo: "Obstáculo interno (o SEU hábito/medo)"),
                CampoForma(id: "plano", rotulo: "Se [obstáculo], então eu"),
            ]
        case .seEntao:
            [
                CampoForma(id: "se", rotulo: "Se (hora / lugar / obstáculo)"),
                CampoForma(id: "entao", rotulo: "Então eu (substituto concreto, não “não faço”)"),
            ]
        case .spec:
            [
                // rótulos na língua de quem escreve, não no jargão do método:
                // "não-objetivos" e "casos-limite" pediam ao autor que soubesse
                // vocabulário de spec antes de conseguir responder. Os ids ficam
                // (estão gravados nas notas) — só a pergunta muda.
                CampoForma(id: "problema", rotulo: "Problema"),
                CampoForma(id: "pronto", rotulo: "Pronto quando"),
                CampoForma(id: "nao", rotulo: "O que eu NÃO vou fazer"),
                CampoForma(id: "restricoes", rotulo: "Restrições (prazo, dinheiro, gente)"),
                CampoForma(id: "limites", rotulo: "O que pode dar errado"),
            ]
        case .notaPermanente:
            [
                CampoForma(id: "ideia", rotulo: "Uma ideia, nas suas palavras"),
                CampoForma(id: "liga", rotulo: "Liga a"),
                CampoForma(id: "fonte", rotulo: "Fonte"),
            ]
        case .destaque:
            [CampoForma(id: "unica", rotulo: "A única coisa de hoje, primeiro, até acabar")]
        case .expressiva:
            []
        case .destilar:
            [
                CampoForma(id: "em200", rotulo: "Em 200", teto: 200),
                CampoForma(id: "em100", rotulo: "Em 100", teto: 100),
                CampoForma(id: "em50", rotulo: "Em 50", teto: 50),
                CampoForma(id: "frase", rotulo: "Numa frase", teto: 140),
            ]
        case .palavra:
            [
                CampoForma(id: "minhas", rotulo: "Nas minhas palavras"),
                CampoForma(id: "frase", rotulo: "Uma frase minha com ela"),
                CampoForma(id: "onde", rotulo: "Onde a encontrei"),
            ]
        case .decisao:
            [
                CampoForma(id: "escolha", rotulo: "O que estou decidindo"),
                CampoForma(id: "opcoes", rotulo: "As opções (uma por linha)"),
                CampoForma(id: "criterio", rotulo: "O que decide entre elas"),
                CampoForma(id: "decidido", rotulo: "Decidi"),
                CampoForma(id: "espero", rotulo: "O que espero que aconteça, e quando eu confiro"),
                CampoForma(id: "aconteceu", rotulo: "O que aconteceu", soDepois: true),
            ]
        case .premortem:
            [
                CampoForma(id: "plano", rotulo: "O plano, em uma frase"),
                CampoForma(id: "falhou", rotulo: "Um ano depois, falhou. O que aconteceu?"),
                CampoForma(id: "sinal", rotulo: "O primeiro sinal de que estava indo por aí"),
                CampoForma(id: "mudo", rotulo: "O que eu mudo no plano agora"),
            ]
        }
    }
}

struct CampoForma: Identifiable, Hashable {
    let id: String
    let rotulo: String
    var teto: Int? = nil
    /// Campo que só faz sentido na VOLTA (a conferência da decisão). Some
    /// enquanto está vazio e a hora não chegou: perguntar o resultado no dia
    /// em que se decide é ruído, e ruído é fricção (§17).
    var soDepois: Bool = false
}

enum FiltroNotas: String, CaseIterable, Identifiable {
    case woop = "WOOP"
    case seEntao = "Se–então"
    case spec = "Especificação"
    case notaPermanente = "Permanente"
    case destaque = "Destaque"
    case destilar = "Destilar"
    case palavra = "Palavras"
    case decisao = "Decisões"
    case premortem = "Pré-mortem"
    case trancadas = "Trancadas"

    var id: String { rawValue }

    var slug: String {
        switch self {
        case .woop: "woop"
        case .seEntao: "se-entao"
        case .spec: "spec"
        case .notaPermanente: "nota-permanente"
        case .destaque: "destaque"
        case .destilar: "destilar"
        case .palavra: "palavra"
        case .decisao: "decisao"
        case .premortem: "premortem"
        case .trancadas: "trancadas"
        }
    }

    var gesto: Gesto? {
        switch self {
        case .woop: .woop
        case .seEntao: .seEntao
        case .spec: .spec
        case .notaPermanente: .notaPermanente
        case .destaque: .destaque
        case .destilar: .destilar
        case .palavra: .palavra
        case .decisao: .decisao
        case .premortem: .premortem
        case .trancadas: nil
        }
    }
}