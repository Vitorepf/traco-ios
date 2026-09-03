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
    /// Domínio inferido (COLHEITA). Vazio = silêncio. `dominioTravado` = o autor
    /// tocou o chip: a inferência não volta a escrever por cima.
    var dominioRaw: String = ""
    var dominioTravado: Bool = false
    /// Aviso do "Se" com hora — não é calendário.
    var gatilhoEm: Date?
    /// Série da expressiva (1–4). `serieRaw` vazio = sessão única.
    var serieRaw: String = ""
    var diaDaSerie: Int = 0

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
        sentido: String = "",
        dominio: Dominio? = nil
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
        self.dominioRaw = dominio?.rawValue ?? ""
        self.dominioTravado = dominio != nil
        self.gatilhoEm = nil
        self.serieRaw = ""
        self.diaDaSerie = 0
    }

    /// Fechada de qualquer jeito: selada OU queimada. Quem pergunta "pode sair
    /// daqui?" tem de olhar esta, nunca só `trancada`.
    var fechada: Bool { trancada || queimada }

    var gesto: Gesto? {
        get { gestoRaw.flatMap(Gesto.init(rawValue:)) }
        set { gestoRaw = newValue?.rawValue }
    }

    var campos: [String: String] {
        get { Self.decode(camposJSON) }
        set { camposJSON = Self.encode(newValue) }
    }

    var dominio: Dominio? {
        get { Dominio(rawValue: dominioRaw) }
        set { dominioRaw = newValue?.rawValue ?? "" }
    }

    /// Um toque no chip: tira o rótulo e trava a inferência. Não volta sozinho.
    func soltarDominio() {
        dominio = nil
        dominioTravado = true
    }

    var serieUUID: UUID? {
        get { serieRaw.isEmpty ? nil : UUID(uuidString: serieRaw) }
        set { serieRaw = newValue?.uuidString ?? "" }
    }

    /// Só a voz do autor — labels do app não entram na busca nem no classificador.
    /// A linha de sentido vive fora do selo e entra aqui (§8.5).
    var vozDoAutor: String {
        VozDoAutor.juntar(texto: texto, campos: campos, sentido: sentido)
    }

    /// Página sem voz não é nota: o arquivo e o Recordar não a tratam como traço.
    var temVoz: Bool {
        !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !vozDoAutor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// O que a lista mostra. Página vazia do dia N não é uma linha muda.
    var tituloNaLista: String {
        let t = VozDoAutor.titulo(texto, gesto: gesto, campos: campos)
        if !t.isEmpty { return t }
        if gesto == .expressiva, diaDaSerie >= 1 { return "Expressiva · dia \(diaDaSerie)" }
        if gesto == .expressiva { return "Expressiva" }
        return t
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

    /// Cópia fiel para a janela de desfazer — o mesmo id, as mesmas datas.
    func retrato() -> NotaRecuperavel {
        NotaRecuperavel(
            uuid: uuid, texto: texto, gesto: gesto, campos: campos,
            criadaEm: criadaEm, editadaEm: editadaEm,
            trancada: trancada, queimada: queimada, queimadaEm: queimadaEm,
            minutosEscritos: minutosEscritos, sentido: sentido,
            dominio: dominio, dominioTravado: dominioTravado,
            gatilhoEm: gatilhoEm, serieUUID: serieUUID, diaDaSerie: diaDaSerie
        )
    }

    static func de(_ r: NotaRecuperavel) -> Nota {
        let n = Nota(
            texto: r.texto, gesto: r.gesto, campos: r.campos,
            trancada: r.trancada, criadaEm: r.criadaEm, editadaEm: r.editadaEm,
            queimada: r.queimada, queimadaEm: r.queimadaEm,
            minutosEscritos: r.minutosEscritos, sentido: r.sentido,
            dominio: r.dominio
        )
        n.uuid = r.uuid
        n.dominioTravado = r.dominioTravado
        n.gatilhoEm = r.gatilhoEm
        n.serieUUID = r.serieUUID
        n.diaDaSerie = r.diaDaSerie
        return n
    }
}

/// O que o desfazer precisa para não mentir: é a mesma nota, não um primo.
struct NotaRecuperavel: Sendable, Equatable {
    var uuid: UUID
    var texto: String
    var gesto: Gesto?
    var campos: [String: String]
    var criadaEm: Date
    var editadaEm: Date
    var trancada: Bool
    var queimada: Bool
    var queimadaEm: Date?
    var minutosEscritos: Int
    var sentido: String
    var dominio: Dominio?
    var dominioTravado: Bool
    var gatilhoEm: Date?
    var serieUUID: UUID?
    var diaDaSerie: Int
}