import Foundation

enum Gesto: String, CaseIterable, Codable, Identifiable {
    case woop
    case seEntao
    case spec
    case notaPermanente
    case destaque
    case expressiva

    var id: String { rawValue }

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
                CampoForma(id: "problema", rotulo: "Problema"),
                CampoForma(id: "pronto", rotulo: "Pronto quando"),
                CampoForma(id: "nao", rotulo: "Não-objetivos"),
                CampoForma(id: "restricoes", rotulo: "Restrições"),
                CampoForma(id: "limites", rotulo: "Casos-limite"),
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
    case notaPermanente = "Nota permanente"
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