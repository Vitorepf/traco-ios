import Foundation
import SwiftData

@Model
final class Nota {
    var uuid: UUID
    var texto: String
    var gestoRaw: String?
    var camposJSON: String
    var trancada: Bool
    var criadaEm: Date
    var editadaEm: Date
    var expressivaPrazo: Date?

    init(
        texto: String = "",
        gesto: Gesto? = nil,
        campos: [String: String] = [:],
        trancada: Bool = false,
        criadaEm: Date = .now,
        editadaEm: Date = .now,
        expressivaPrazo: Date? = nil
    ) {
        self.uuid = UUID()
        self.texto = texto
        self.gestoRaw = gesto?.rawValue
        self.camposJSON = Self.encode(campos)
        self.trancada = trancada
        self.criadaEm = criadaEm
        self.editadaEm = editadaEm
        self.expressivaPrazo = expressivaPrazo
    }

    var gesto: Gesto? {
        get { gestoRaw.flatMap(Gesto.init(rawValue:)) }
        set { gestoRaw = newValue?.rawValue }
    }

    var campos: [String: String] {
        get { Self.decode(camposJSON) }
        set { camposJSON = Self.encode(newValue) }
    }

    /// Só a voz do autor — labels do app não entram na busca nem no classificador.
    var vozDoAutor: String {
        VozDoAutor.juntar(texto: texto, campos: campos)
    }

    private static func encode(_ campos: [String: String]) -> String {
        (try? String(data: JSONEncoder().encode(campos), encoding: .utf8)) ?? "{}"
    }

    private static func decode(_ json: String) -> [String: String] {
        guard let data = json.data(using: .utf8),
              let map = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return map
    }
}