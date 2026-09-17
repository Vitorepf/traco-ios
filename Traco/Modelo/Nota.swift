import Foundation
import SwiftData

/// Quem escreveu o texto (ADR 2026-09-08u). O padrão é o autor; qualquer outra
/// origem é o bot falando, e o app diz isso na tela, mantém a nota fora do
/// Retrato e nunca a conta como voz do autor. `obra` (ADR 2026-09-16a) é texto
/// de um mestre — dossiê, livro, transcrição: consulta, nunca voz. `obraSuposta`
/// (16b) é a que o app DEDUZIU (arquivo sem cabeçalho, origem desconhecida):
/// fora da voz igual, mas à vista na lista — pode ser a nota dele.
nonisolated enum OrigemNota: String, Sendable, CaseIterable {
    case autor, grokbot, pesquisa, obra
    case obraSuposta = "obra-suposta"

    /// Texto de mestre, declarado ou deduzido: consulta-se por seção.
    var eObra: Bool { self == .obra || self == .obraSuposta }

    /// A palavra que aparece na etiqueta. Diz o essencial: não é voz do autor.
    var etiqueta: String? {
        switch self {
        case .autor: nil
        case .grokbot: "feito pelo bot"
        case .pesquisa: "pesquisa do bot"
        case .obra: "obra"
        case .obraSuposta: "parece obra"
        }
    }
}

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
    /// ADR 08u: quem escreveu. Vazio = o autor — é o que toda nota anterior a
    /// esta ADR é, e continuar a ser.
    var origemRaw: String = ""

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

    /// Nota que não é do autor: etiqueta na tela, fora do Retrato, fora da voz.
    var origem: OrigemNota {
        // vazio é o autor (toda nota anterior à 08u); um valor que esta versão
        // não conhece NÃO é: cai em obra, fora da voz (ADR 2026-09-16a)
        get { origemRaw.isEmpty ? .autor : OrigemNota(rawValue: origemRaw) ?? .obraSuposta }
        set { origemRaw = newValue == .autor ? "" : newValue.rawValue }
    }

    var gesto: Gesto? {
        get { gestoRaw.flatMap(Gesto.init(rawValue:)) }
        set { gestoRaw = newValue?.rawValue }
    }

    var campos: [String: String] {
        get { Self.decode(camposJSON) }
        set { camposJSON = Self.encode(newValue) }
    }

    /// ADR 09b: o domínio INFERIDO é uma afirmação derivada do texto, e o mapa
    /// de domínios é do autor. Numa nota que não é dele, o rótulo do léxico
    /// cala — inclusive o que ficou gravado antes desta ADR, sem migração. O
    /// que o AUTOR escolheu no menu (`dominioTravado`) continua, porque aí a
    /// afirmação é dele: ele pode dizer que a nota do bot é sobre trabalho.
    var dominio: Dominio? {
        get {
            guard origem == .autor || dominioTravado else { return nil }
            return Dominio(rawValue: dominioRaw)
        }
        set { dominioRaw = newValue?.rawValue ?? "" }
    }

    /// Um toque no chip: tira o rótulo e trava a inferência. Não volta sozinho.
    func soltarDominio() {
        dominio = nil
        dominioTravado = true
    }

    /// E devolve. A ADR c dizia "um toque desfaz e trava" — e não previu que
    /// não havia segundo toque: quem errasse o dedo perdia o domínio daquela
    /// nota para sempre. Destravar faz a inferência voltar no próximo salvar.
    func devolverDominio() {
        dominioTravado = false
    }

    var serieUUID: UUID? {
        get { serieRaw.isEmpty ? nil : UUID(uuidString: serieRaw) }
        set { serieRaw = newValue?.uuidString ?? "" }
    }

    /// Todo o texto da nota, seja de quem for — labels do app continuam fora.
    /// A linha de sentido vive fora do selo e entra aqui (§8.5). A BUSCA lê
    /// daqui: uma nota que o bot deixou na pasta tem de ser encontrável.
    var textoDeQualquerOrigem: String {
        VozDoAutor.juntar(texto: texto, campos: campos, sentido: sentido)
    }

    /// E7: o texto que VAI AO MODELO, com os rótulos do método (`VozDoAutor.rotulada`).
    var paraAIA: String {
        VozDoAutor.rotulada(texto: texto, campos: campos, gesto: gesto, sentido: sentido)
    }

    /// E7: a voz do autor como vai ao modelo — rotulada, sem citação, vazia se não é dele.
    var vozDoAutorParaAIA: String {
        origem == .autor ? VozDoAutor.rotulada(texto: texto, campos: campos, gesto: gesto, sentido: sentido, semCitacao: true) : ""
    }

    /// Só a voz do autor — VAZIO quando a nota não é dele (ADR 2026-09-09b).
    /// Quem declara voz, retrato, trajetória ou mapa do autor lê DAQUI, e por
    /// isso o classificador de domínio e as perguntas dos Padrões não recebem
    /// uma palavra que a pessoa não escreveu. Quem quer o texto seja de quem
    /// for pede `textoDeQualquerOrigem` — e o nome diz o que está pedindo.
    /// A citação `>` é de outro (ADR 2026-09-16a): fica na busca, sai da voz.
    var vozDoAutor: String {
        origem == .autor ? VozDoAutor.juntar(texto: texto, campos: campos, sentido: sentido, semCitacao: true) : ""
    }

    /// Página sem voz não é nota: o arquivo e o Recordar não a tratam como traço.
    var temVoz: Bool {
        !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !textoDeQualquerOrigem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
            gatilhoEm: gatilhoEm, serieUUID: serieUUID, diaDaSerie: diaDaSerie,
            origem: origem
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
        // ADR 09b: a origem acompanha todo consumidor. Sem ela, desfazer o
        // apagar devolvia obra, pesquisa e texto do bot como VOZ DO AUTOR — e a
        // voz dele é o que o Trabalho e o Destaque usam (auditoria 17/09).
        n.origem = r.origem
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
    var origem: OrigemNota = .autor
}
/// ADR 2026-09-09b — a origem acompanha todo consumidor.
///
/// Quatro leitores declaram, na própria documentação, que falam da mente do
/// AUTOR: o Retrato ("só com as suas palavras e contagens"), a Trajetória, a
/// revisão da semana ("o que a mente deixou no papel") e a Rede ("a ligação
/// nasce do que o AUTOR escreveu"). Nenhum deles pode ler texto que não seja
/// dele — nem para inferir domínio, nem para CONTAR.
///
/// A conversão de `Nota` para cada um deles mora aqui, num lugar só. Antes
/// eram seis `map` iguais espalhados por views e intents, e um deles — a rota
/// de produção das Notas — esquecia a origem e mandava a nota do bot para a
/// IA. Um lugar para acertar, e o campo `vozDoAutor` sem padrão em cada
/// `NotaLida`: quem inventar um sétimo chamador não compila sem declarar.
extension Nota {
    var paraRetrato: Retrato.NotaLida {
        .init(gesto: gesto, fechada: fechada, expressiva: gesto == .expressiva,
              criadaEm: criadaEm, campos: campos, vozDoAutor: origem == .autor)
    }

    var paraTrajetoria: Trajetoria.NotaLida {
        .init(uuid: uuid, gesto: gesto, fechada: fechada, criadaEm: criadaEm,
              editadaEm: queimadaEm ?? editadaEm, campos: campos, sentido: sentido,
              vozDoAutor: origem == .autor)
    }

    var paraSemana: RevisaoSemanal.NotaLida {
        .init(uuid: uuid, gesto: gesto, fechada: fechada, criadaEm: criadaEm,
              gatilhoEm: gatilhoEm, titulo: tituloNaLista, campos: campos, sentido: sentido,
              queimadaOuSeladaEm: queimadaEm ?? editadaEm, vozDoAutor: origem == .autor)
    }

    var paraRede: Rede.NotaLida {
        .init(uuid: uuid, titulo: tituloNaLista, texto: texto, campos: campos, gesto: gesto,
              fechada: fechada, expressivaEmCurso: gesto == .expressiva && !fechada,
              vozDoAutor: origem == .autor)
    }
}
