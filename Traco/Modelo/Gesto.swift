import Foundation

/// Uma forma do §6 — agora um id sobre o catálogo (ADR 2026-09-04l), não um
/// `case`. Os dez de origem continuam com os mesmos ids (`gestoRaw` no disco
/// e o corpus exportado não mudam); os demais vêm do `Metodos.json` e da
/// pasta do autor. `Gesto.woop` e os outros estáticos existem para o código
/// que precisa falar de uma forma pelo nome — o selo da expressiva, a escada
/// do Recordar, a decisão com data de conferir.
nonisolated struct Gesto: Hashable, Codable, Identifiable, Sendable, CaseIterable {
    let rawValue: String
    var id: String { rawValue }

    /// Todo id conhecido pelo catálogo, e também os que já foram gravados
    /// num `gestoRaw` e cujo método sumiu da pasta: a nota não perde o gesto.
    init?(rawValue: String) {
        let limpo = rawValue.trimmingCharacters(in: .whitespaces)
        guard !limpo.isEmpty else { return nil }
        self.rawValue = limpo
    }

    private init(_ raw: String) { rawValue = raw }

    static let woop = Gesto("woop")
    static let seEntao = Gesto("seEntao")
    static let spec = Gesto("spec")
    static let notaPermanente = Gesto("notaPermanente")
    static let destaque = Gesto("destaque")
    static let expressiva = Gesto("expressiva")
    static let destilar = Gesto("destilar")
    static let palavra = Gesto("palavra")
    static let decisao = Gesto("decisao")
    static let premortem = Gesto("premortem")
    static let dia = Gesto("dia")

    /// Na ordem do catálogo: os do app primeiro, depois os do autor.
    static var allCases: [Gesto] { Catalogo.todos.map { Gesto($0.id) } }

    /// Import/export aceitam o nome de exibição ("WOOP") E o rawValue ("woop") —
    /// o roundtrip do corpus nunca perde o gesto por causa da grafia. O que não
    /// está mais no catálogo também entra (ADR 05o: um método apagado da pasta
    /// não pode transformar a nota em prosa), mas só com cara de id: sem
    /// espaço e até 64 caracteres. Frase inteira de um .md alheio fica de fora.
    static func doNome(_ s: String) -> Gesto? {
        let alvo = s.trimmingCharacters(in: .whitespaces)
        guard !alvo.isEmpty else { return nil }
        if Catalogo.metodo(alvo) != nil { return Gesto(alvo) }
        if let doCatalogo = allCases.first(where: { $0.nome.caseInsensitiveCompare(alvo) == .orderedSame }) {
            return doCatalogo
        }
        guard alvo.count <= 64, alvo.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else { return nil }
        return Gesto(rawValue: alvo)
    }

    // MARK: o método, do catálogo

    var metodoDef: Metodo { Catalogo.metodo(rawValue) ?? .desconhecido(rawValue) }
    var nome: String { metodoDef.nome }
    /// O MOVIMENTO do método (ADR 03n) — o que a sábia cobra.
    var metodo: String { metodoDef.movimento }
    var reconhecimento: String { metodoDef.reconhecimento }
    var campos: [CampoForma] { metodoDef.campos }
    var origem: String { metodoDef.origem }
    var encadeamentos: [Metodo.Encadeamento] { metodoDef.encadeamentos }
    /// O catálogo conhece este id? Falso = método que sumiu da pasta.
    var conhecido: Bool { Catalogo.metodo(rawValue) != nil }
    /// ADR 05x: o que a tela diz quando o método não está mais no catálogo
    /// (05o). Nil = o catálogo conhece. Estado honesto, não bloqueio: os campos
    /// ficam.
    ///
    /// A frase NÃO diz "saiu da sua pasta" (como dizia até a colagem da leva 3):
    /// isso é verdade quando o autor apagou um método da pasta dele, e falso
    /// quando quem tirou foi o app — a fusão da Inversão no Pré-mortem é o
    /// primeiro caso. Depois do fato os dois são indistinguíveis, porque o
    /// método sumiu junto com a informação de onde vinha; a frase de agora é
    /// verdadeira nos dois.
    var estadoDoMetodo: String? {
        conhecido ? nil : "o método “\(rawValue)” não está mais no catálogo; os campos continuam na nota."
    }

    // MARK: Codable como texto (o que o disco e o corpus sempre guardaram)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        rawValue = try c.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

/// Os chips da busca: um por método com `filtro`, mais Trancadas.
nonisolated struct FiltroNotas: Hashable, Identifiable, Sendable {
    let rawValue: String
    let gesto: Gesto?
    var id: String { rawValue }

    static let trancadas = FiltroNotas(rawValue: "Trancadas", gesto: nil)
    static let woop = FiltroNotas(rawValue: "WOOP", gesto: .woop)
    static let seEntao = FiltroNotas(rawValue: "Se–então", gesto: .seEntao)
    static let spec = FiltroNotas(rawValue: "Especificação", gesto: .spec)
    static let notaPermanente = FiltroNotas(rawValue: "Permanente", gesto: .notaPermanente)
    static let destaque = FiltroNotas(rawValue: "Destaque", gesto: .destaque)
    static let destilar = FiltroNotas(rawValue: "Destilar", gesto: .destilar)
    static let palavra = FiltroNotas(rawValue: "Palavras", gesto: .palavra)
    static let decisao = FiltroNotas(rawValue: "Decisões", gesto: .decisao)
    static let premortem = FiltroNotas(rawValue: "Pré-mortem", gesto: .premortem)

    static var allCases: [FiltroNotas] {
        Catalogo.todos.compactMap { m in
            guard let f = m.filtro else { return nil }
            return FiltroNotas(rawValue: f, gesto: Gesto(rawValue: m.id))
        } + [trancadas]
    }

    var slug: String {
        guard let gesto else { return "trancadas" }
        switch gesto {
        case .seEntao: return "se-entao"
        case .notaPermanente: return "nota-permanente"
        default: return gesto.rawValue.lowercased()
        }
    }
}
