import Foundation

enum Gesto: String, CaseIterable, Codable, Identifiable {
    case woop
    case seEntao
    case spec
    case notaPermanente
    case destaque
    case expressiva

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
        case .spec: "Spec"
        case .notaPermanente: "Nota permanente"
        case .destaque: "Destaque"
        case .expressiva: "Expressiva"
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
        }
    }

    var campos: [CampoForma] {
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
        }
    }
}

struct CampoForma: Identifiable, Hashable {
    let id: String
    let rotulo: String
}

enum FiltroNotas: String, CaseIterable, Identifiable {
    case woop = "WOOP"
    case seEntao = "Se–então"
    case spec = "Spec"
    case notaPermanente = "Permanente"
    case destaque = "Destaque"
    case trancadas = "Trancadas"

    var id: String { rawValue }

    var slug: String {
        switch self {
        case .woop: "woop"
        case .seEntao: "se-entao"
        case .spec: "spec"
        case .notaPermanente: "nota-permanente"
        case .destaque: "destaque"
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
        case .trancadas: nil
        }
    }
}