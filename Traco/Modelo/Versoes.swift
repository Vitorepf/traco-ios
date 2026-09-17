import Foundation

/// Histórico de versões (Drafts, Obsidian): cada gravação que muda o texto
/// guarda a anterior, num arquivo por nota em Documents/Traço/versoes.
/// O autor vê e restaura; o app nunca escreve por ele. A expressiva nunca
/// entra: o que se destrói na queima não pode sobreviver aqui (§8).
nonisolated struct VersaoNota: Codable, Equatable, Sendable, Identifiable {
    var data: Date
    var texto: String
    var campos: [String: String]
    var id: Date { data }
}

nonisolated enum Versoes {
    static let teto = 30

    nonisolated(unsafe) static var diretorio: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Traço/versoes", isDirectory: true)

    nonisolated static func url(_ uuid: UUID) -> URL {
        diretorio.appendingPathComponent(uuid.uuidString.lowercased() + ".json")
    }

    nonisolated static func listar(_ uuid: UUID) -> [VersaoNota] {
        guard let data = try? Data(contentsOf: url(uuid)) else { return [] }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return ((try? dec.decode([VersaoNota].self, from: data)) ?? []).sorted { $0.data > $1.data }
    }

    /// A regra, num lugar só: versão é de TODA nota — de compra, de decisão,
    /// de método ou de prosa solta —, menos a expressiva, aberta, selada ou
    /// queimada (§8). Quem MOSTRA o campo pergunta aqui, como quem GRAVA:
    /// eram duas cópias da mesma condição, e uma podia mudar sem a outra.
    nonisolated static func valemPara(gesto: Gesto?, fechada: Bool) -> Bool {
        gesto != .expressiva && !fechada
    }

    /// Guarda `texto`/`campos` como uma versão, se diferem da última guardada.
    /// Quem chama passa o que ESTAVA gravado antes de sobrescrever.
    @discardableResult
    nonisolated static func registrar(_ uuid: UUID, texto: String, campos: [String: String],
                                      gesto: Gesto?, fechada: Bool, agora: Date = .now) -> Bool {
        guard valemPara(gesto: gesto, fechada: fechada) else { return false }
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty || !campos.values.allSatisfy({ $0.trimmingCharacters(in: .whitespaces).isEmpty }) else { return false }
        var lista = listar(uuid)
        if let ultima = lista.first, ultima.texto == texto, ultima.campos == campos { return false }
        lista.insert(VersaoNota(data: agora, texto: texto, campos: campos), at: 0)
        if lista.count > teto { lista = Array(lista.prefix(teto)) }
        return gravar(uuid, lista)
    }

    nonisolated static func apagar(_ uuid: UUID) {
        try? FileManager.default.removeItem(at: url(uuid))
    }

    nonisolated private static func gravar(_ uuid: UUID, _ lista: [VersaoNota]) -> Bool {
        do {
            try FileManager.default.createDirectory(at: diretorio, withIntermediateDirectories: true)
            let enc = JSONEncoder()
            enc.dateEncodingStrategy = .iso8601
            try enc.encode(lista).write(to: url(uuid), options: .atomic)
            return true
        } catch {
            return false
        }
    }
}

/// Apontar (Edda; ADR 2026-09-02k): o autor marca um trecho SEU com um rótulo
/// fechado. Sem substituto, sem sugestão. Um arquivo por nota, ao lado das
/// versões; a expressiva nunca.
nonisolated enum RotuloApontar: String, CaseIterable, Codable, Sendable {
    case fraseFeita, vago, passiva, muleta

    var nome: String {
        switch self {
        case .fraseFeita: "Frase feita"
        case .vago: "Vago"
        case .passiva: "Passiva"
        case .muleta: "Palavra de apoio" // ADR 06h, o mesmo rótulo da Lente
        }
    }
}

nonisolated struct Apontamento: Codable, Equatable, Sendable, Identifiable {
    var trecho: String
    var rotulo: RotuloApontar
    var data: Date
    var id: String { trecho.lowercased() + "|" + rotulo.rawValue }
}

nonisolated enum Apontar {
    nonisolated(unsafe) static var diretorio: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Traço/apontamentos", isDirectory: true)

    nonisolated static func url(_ uuid: UUID) -> URL {
        diretorio.appendingPathComponent(uuid.uuidString.lowercased() + ".json")
    }

    nonisolated static func listar(_ uuid: UUID) -> [Apontamento] {
        guard let data = try? Data(contentsOf: url(uuid)) else { return [] }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return (try? dec.decode([Apontamento].self, from: data)) ?? []
    }

    /// O trecho tem de estar no texto do autor: apontar é sobre o que ELE escreveu.
    @discardableResult
    nonisolated static func marcar(_ uuid: UUID, trecho: String, rotulo: RotuloApontar,
                                   noTexto texto: String, agora: Date = .now) -> Bool {
        let limpo = trecho.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty, texto.lowercased().contains(limpo.lowercased()) else { return false }
        var lista = listar(uuid)
        let novo = Apontamento(trecho: limpo, rotulo: rotulo, data: agora)
        lista.removeAll { $0.id == novo.id }
        lista.insert(novo, at: 0)
        return gravar(uuid, lista)
    }

    @discardableResult
    nonisolated static func desmarcar(_ uuid: UUID, id: String) -> Bool {
        var lista = listar(uuid)
        lista.removeAll { $0.id == id }
        return gravar(uuid, lista)
    }

    nonisolated static func apagar(_ uuid: UUID) {
        try? FileManager.default.removeItem(at: url(uuid))
    }

    nonisolated private static func gravar(_ uuid: UUID, _ lista: [Apontamento]) -> Bool {
        do {
            try FileManager.default.createDirectory(at: diretorio, withIntermediateDirectories: true)
            let enc = JSONEncoder()
            enc.dateEncodingStrategy = .iso8601
            try enc.encode(lista).write(to: url(uuid), options: .atomic)
            return true
        } catch {
            return false
        }
    }
}
