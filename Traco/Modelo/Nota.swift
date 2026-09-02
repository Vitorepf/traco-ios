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
    /// SPEC §8: a expressiva fecha por um de DOIS métodos.
    /// `trancada` = SELADA (Pennebaker: o texto fica, mas não se relê à toa).
    /// `queimada` = o texto foi DESTRUÍDO (Briñol 2013: descartar o pensamento
    /// como objeto material reduz o poder dele). Só sobram data, duração e a
    /// linha de sentido que o autor escreveu.
    var queimada: Bool = false
    var queimadaEm: Date?
    var minutosEscritos: Int = 0
    /// A frase que o AUTOR escreveu no fim ("o que ficou claro?"). Nunca é da IA.
    /// Vive fora do selo: entra na busca, nos Padrões e no Recordar.
    var sentido: String = ""

    init(
        texto: String = "",
        gesto: Gesto? = nil,
        campos: [String: String] = [:],
        trancada: Bool = false,
        criadaEm: Date = .now,
        editadaEm: Date = .now,
        expressivaPrazo: Date? = nil,
        queimada: Bool = false,
        queimadaEm: Date? = nil,
        minutosEscritos: Int = 0,
        sentido: String = ""
    ) {
        self.uuid = UUID()
        self.texto = texto
        self.gestoRaw = gesto?.rawValue
        self.camposJSON = Self.encode(campos)
        self.trancada = trancada
        self.criadaEm = criadaEm
        self.editadaEm = editadaEm
        self.expressivaPrazo = expressivaPrazo
        self.queimada = queimada
        self.queimadaEm = queimadaEm
        self.minutosEscritos = minutosEscritos
        self.sentido = sentido
    }

    /// Fechada de qualquer jeito: selada, queimada OU expressiva ainda em curso.
    /// Quem pergunta "pode sair daqui?" tem de olhar esta, nunca só `trancada`.
    /// A expressiva entra no banco destrancada no instante em que o timer
    /// começa; morte do processo ou uma rota externa a deixam assim por até
    /// 15 min. O selo vale desde o primeiro caractere: rede, backup, índice,
    /// busca e Padrões não a leem nunca. Só `abrir` (retomar o timer) olha
    /// `trancada`.
    var fechada: Bool { trancada || queimada || gesto == .expressiva }

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