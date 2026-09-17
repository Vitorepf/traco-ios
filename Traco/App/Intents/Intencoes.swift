import AppIntents
import SwiftData
import SwiftUI

/// O app fora do app (exp 3): Atalhos, Siri e Action Button chegam de graça
/// com App Intents no alvo principal — sem extensão, sem app group.
///
/// ADR 05u: este é o catálogo do app. O que os widgets e as Live Activities
/// precisam declarar mora em `Compartilhado/` e é compilado nos dois alvos;
/// o resto só aqui. Toda entrada (Siri, Atalhos, URL, widget, Ilha) converge
/// em `Rota` ou numa função concreta do app — nunca em lógica duplicada.
struct NovaNotaIntent: AppIntent {
    static let title: LocalizedStringResource = "Nova nota"
    static let description = IntentDescription("Abre o Traço numa página em branco, pronta para escrever.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Rota.ir(.novaPagina)
        return .result()
    }
}

/// ADR 05a: anotar sem abrir o app — a frase cai na entrada e vira nota
/// quando o Traço volta à cena.
struct AnotarIntent: AppIntent {
    static let title: LocalizedStringResource = "Anotar"
    static let description = IntentDescription("Guarda uma frase no Traço sem abrir o app. Vira nota na próxima vez que ele abrir.")
    static let openAppWhenRun = false

    @Parameter(title: "Texto", requestValueDialog: "O que anotar?")
    var texto: String

    static var parameterSummary: some ParameterSummary { Summary("Anotar \(\.$texto)") }

    /// ADR 05u: vazio e falha de gravação são duas respostas. "anotado"
    /// significa depósito confirmado em `entrada/`, não nota importada.
    enum Resposta: Equatable {
        case vazio, falhou, anotado
        var fala: String {
            switch self {
            case .vazio: "nada a anotar."
            case .falhou: "não consegui guardar. A frase não entrou."
            case .anotado: "anotado."
            }
        }
    }

    @MainActor
    static func anotar(_ texto: String) -> Resposta {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .vazio }
        return Entrada.depositar(texto, raiz: Entrada.raizDoApp) ? .anotado : .falhou
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(stringLiteral: Self.anotar(texto).fala))
    }
}

struct AbrirNotasIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir notas"
    static let description = IntentDescription("Abre a lista de notas do Traço.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Rota.ir(.notas)
        return .result()
    }
}

// MARK: - Intents que DEVOLVEM texto (COLHEITA: 23 blocos pediam isto)
//
// O Traço lido sem ser aberto: Atalhos, Siri e o botão de Ação recebem texto
// e passam adiante, para a IA do autor ou para onde ele quiser. O selo vale
// aqui como vale no export: expressiva em curso nunca sai; selada e queimada
// saem só como metadado e linha de sentido (§8.5, §19.1).

/// Lê o disco por conta própria: o intent pode rodar com o app fechado.
@MainActor
func notasDoDisco() -> [Nota] {
    guard let container = DiscoTraco.compartilhado ?? (try? ModelContainer.traco()) else { return [] }
    let contexto = ModelContext(container)
    return (try? contexto.fetch(FetchDescriptor<Nota>())) ?? []
}

@MainActor
private func fatiasDoDisco() -> [FatiaCorpus] {
    notasDoDisco().filter(\.temVoz).map(FatiaCorpus.de)
}

struct DestaqueDeHojeIntent: AppIntent {
    static let title: LocalizedStringResource = "Destaque de hoje"
    static let description = IntentDescription("A única linha de hoje, escrita por você. Vazio se não houver.")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let linha = DestaqueDoDia.linhaDeHoje() ?? ""
        return .result(value: linha, dialog: IntentDialog(stringLiteral: linha.isEmpty ? "Sem destaque hoje." : linha))
    }
}

struct CompromissosDeHojeIntent: AppIntent {
    static let title: LocalizedStringResource = "Meu dia"
    static let description = IntentDescription("Os compromissos de hoje, um por linha, com a hora.")

    @Parameter(title: "Dia", description: "Vazio = hoje", default: nil)
    var dia: Date?

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let cal = Calendario.gregoriano()
        let alvo = dia ?? .now
        var eventos: [EventoCalendario] = []
        if case .eventos(let lidos) = CalendarioDisco.carregar() { eventos = lidos }
        // as deixas do "Se" (ADR i) entram no dia como no app
        eventos += notasDoDisco().compactMap {
            Calendario.deixa(uuid: $0.uuid, gesto: $0.gesto, fechada: $0.fechada, gatilhoEm: $0.gatilhoEm,
                             se: $0.campos["se"] ?? "", tituloNaLista: $0.tituloNaLista, dominio: $0.dominio)
        }
        let doDia = Calendario.eventos(eventos, noDia: alvo, cal)
        let linhas = doDia.map { e in
            e.diaInteiro ? "Dia inteiro · \(e.titulo)" : "\(Calendario.horaCurta(e.inicio, cal)) · \(e.titulo)"
        }
        let texto = linhas.joined(separator: "\n")
        let fala = linhas.isEmpty ? "Nada marcado em \(Calendario.diaPorExtenso(alvo, cal))." : texto
        return .result(value: texto, dialog: IntentDialog(stringLiteral: fala))
    }
}

struct LinhasDeSentidoIntent: AppIntent {
    static let title: LocalizedStringResource = "Linhas de sentido"
    static let description = IntentDescription("As frases que você escreveu ao fechar cada expressiva, da mais recente para trás.")

    @Parameter(title: "Quantas", default: 10)
    var quantas: Int

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let linhas = fatiasDoDisco()
            .filter { !$0.nuncaSai }
            .filter { !$0.sentido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { $0.criadaEm > $1.criadaEm }
            .prefix(max(1, quantas))
            .map { "— \($0.sentido.trimmingCharacters(in: .whitespacesAndNewlines))" }
        let texto = linhas.joined(separator: "\n")
        return .result(value: texto, dialog: IntentDialog(stringLiteral: texto.isEmpty ? "Nenhuma linha de sentido ainda." : texto))
    }
}

struct CorpusComoContextoIntent: AppIntent {
    static let title: LocalizedStringResource = "Como contexto"
    static let description = IntentDescription("O corpus inteiro em Markdown, com o contrato do app no topo: pronto para a sua IA ler.")

    @Parameter(title: "Só a forma", default: nil)
    var forma: FormaEntity?

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        var fatias = fatiasDoDisco()
        if let g = forma?.gesto { fatias = fatias.filter { $0.gesto == g } }
        return .result(value: Corpus.corpoDoCorpus(fatias: fatias))
    }
}

struct EstaSemanaIntent: AppIntent {
    static let title: LocalizedStringResource = "Esta semana"
    static let description = IntentDescription("A revisão da semana (ADR q): notas por forma, destaques, decisões a conferir, os próximos sete dias e o que ficou claro.")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        var eventos: [EventoCalendario] = []
        if case .eventos(let lidos) = CalendarioDisco.carregar() { eventos = lidos }
        let r = RevisaoSemanal.ler(notas: notasDoDisco().map(\.paraSemana), eventos: eventos)
        let texto = RevisaoSemanal.texto(r)
        return .result(value: texto, dialog: IntentDialog(stringLiteral: texto.isEmpty ? "Nada esta semana ainda." : texto))
    }
}

/// ADR 04q: a trajetória em texto — o mesmo que o cartão dos Padrões diz.
struct TrajetoriaIntent: AppIntent {
    static let title: LocalizedStringResource = "Trajetória"
    static let description = IntentDescription("Dois períodos lado a lado, nas suas palavras: formas, obstáculos, o que não voltou no Recordar, decisões conferidas, palavras, o que ficou claro.")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let t = Trajetoria.ler(notas: notasDoDisco().map(\.paraTrajetoria), sinais: Sinais.todos())
        let texto = t.vazia ? "" : Trajetoria.texto(t)
        return .result(value: texto, dialog: IntentDialog(stringLiteral: texto.isEmpty ? "Ainda não há trajetória: escreva primeiro." : texto))
    }
}

/// F1: o primeiro intent que ESCREVE. Os outros sete só leem — não havia como
/// marcar um compromisso sem abrir o app, e o parser que faz isso já estava
/// pronto e testado. "Ei Siri, marcar dentista sexta às 14h no Traço."
///
/// Continua sendo algoritmo: `CalendarioFrase` é regex e relógio, sem rede e
/// sem modelo. A IA não entra aqui.
struct MarcarCompromissoIntent: AppIntent {
    static let title: LocalizedStringResource = "Marcar compromisso"
    static let description = IntentDescription("Escreva ou fale o compromisso — “dentista sexta às 14:30”. O Traço entende o dia e a hora sozinho, no aparelho.")

    @Parameter(title: "O quê", requestValueDialog: "O que você quer marcar?")
    var frase: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let cal = Calendario.gregoriano()
        let agora = Date()
        guard let evento = CalendarioFrase.ler(
            frase, ancora: agora, agora: agora, cal,
            manha: Ancora.hora(.manha), tarde: Ancora.hora(.tarde), noite: Ancora.hora(.noite)
        ) else {
            return .result(dialog: "Não entendi o quê. Tente “dentista sexta às 14h”.")
        }
        var eventos: [EventoCalendario] = []
        if case .eventos(let lidos) = CalendarioDisco.carregar() { eventos = lidos }
        eventos.append(evento)
        do {
            try CalendarioDisco.gravar(eventos)
        } catch {
            return .result(dialog: "Não consegui gravar. O compromisso não entrou.")
        }
        let aviso = await Revisoes.agendarCompromisso(evento, cal: cal)
        // ADR 06d, item 6 («o sino é promessa, não enfeite»): o RESULTADO do
        // alarme vai junto. Sem `mudo:`, esta rota publicava sino para o
        // alarme que o iOS RECUSOU — com o teto de 64 pendentes cheio, a Siri
        // dizia "ficou sem alarme" e a tela bloqueada desenhava `bell.fill`
        // com a hora (auditoria 17/09). É a mesma linha das duas irmãs:
        // `Sessao.agendarEContar` e `CalendarioAgenda.avisar`.
        ProximoCompromisso.publicar(ProximoCompromisso.comAcoesDoTrabalho(eventos), cal: cal,
                                    mudo: aviso.vaiTocar ? nil : evento.id)
        let quando = evento.diaInteiro
            ? Calendario.diaPorExtenso(evento.inicio, cal)
            : "\(Calendario.diaPorExtenso(evento.inicio, cal)) às \(Calendario.horaCurta(evento.inicio, cal))"
        let repete = evento.repete ? ", toda \(Calendario.diasEmLetras(evento.repeteEm, cal))" : ""
        // ADR 04a: quem marca tem de ouvir a promessa, também por voz
        let promessa = switch aviso {
        case .agendado: " Eu te aviso."
        case .semPermissao: " Os avisos estão desligados no iPhone."
        case .semEspaco: " O iPhone já tem avisos demais; este ficou sem alarme."
        case .passou: " A hora do aviso já passou."
        case .semAviso: ""
        }
        return .result(dialog: "\(evento.titulo), \(quando)\(repete).\(promessa)")
    }
}

/// ADR 06g: as formas dos Atalhos nascem do CATÁLOGO.
///
/// Era um `AppEnum` com nove casos escritos à mão: quem filtrava o corpus pela
/// Siri alcançava 9 das 21 formas de hoje (32% das 28 depois da colagem), e
/// nada falhava para avisar — a mesma doença do enum morto da análise de bordo.
/// `AppEnum` exige `caseDisplayRepresentations` estático e por isso não pode
/// nascer de arquivo; a entidade com consulta pode, e ainda traz o método que
/// o autor escreveu na pasta dele, sem código. O id é o do catálogo, o mesmo
/// que o disco guarda.
struct FormaEntity: AppEntity {
    let id: String
    let nome: String

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Forma")
    static let defaultQuery = FormaQuery()
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(nome)") }

    /// Nil quando o método saiu da pasta entre montar o atalho e rodá-lo.
    var gesto: Gesto? { Catalogo.metodo(id) == nil ? nil : Gesto(rawValue: id) }

    static var todas: [FormaEntity] { Catalogo.todos.map { FormaEntity(id: $0.id, nome: $0.nome) } }
}

struct FormaQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [FormaEntity] {
        FormaEntity.todas.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [FormaEntity] { FormaEntity.todas }
}

/// Rota de entrada única: intents e traco:// convergem aqui; a PaginaView consome.
@MainActor
enum Rota {
    enum Destino: Equatable {
        case novaPagina, notas, calendario, recordar, anotar(String)
        /// ADR 05w: página em branco com o teclado pronto; `ditado` é onde o
        /// ditado próprio (próxima superfície) vai entrar.
        case captura(ditado: Bool)
        /// ADR 05u: entidades chegam por aqui (Atalhos, Spotlight, avisos);
        /// a tela revalida o selo/acesso antes de abrir.
        case nota(UUID), trabalho(UUID), compromisso(id: UUID, inicio: Date)
    }
    /// Anunciada por `mudou` e consumida quando a cena está pronta — também no
    /// arranque frio, em que o intent corre antes de a `PaginaView` escutar.
    static var pendente: Destino?

    static func ir(_ destino: Destino) {
        pendente = destino
        anunciar()
    }
    /// O anúncio à cena. A suíte roda DENTRO do app do simulador, com a
    /// `PaginaView` viva ouvindo; o teste de arranque frio troca isto por
    /// silêncio para provar que a rota espera a cena.
    static var anunciar: () -> Void = { NotificationCenter.default.post(name: mudou, object: nil) }
    /// Devolve a pendente UMA vez. Quem chama é a cena pronta (`PaginaView`).
    static func consumir() -> Destino? {
        defer { pendente = nil }
        return pendente
    }
    /// ADR 06c: o ditado NÃO é um `Destino`. Quem o consome é a raiz, não a
    /// Página — e o teclado da `.captura` não pode subir por trás da gravação.
    /// Fica num canal próprio, anunciado pela mesma notificação e devolvido
    /// UMA vez, como a rota.
    static var ditadoPendente = false

    #if DEBUG
    /// Instrumento de evidência, só em Debug: `traco://ditar?ensaio=transcrito`
    /// troca o RECONHECEDOR por uma letra fixa — o microfone, a gravação e a
    /// nota continuam reais. Existe porque o simulador não tem o modelo de
    /// fala no aparelho: sem isto o estado "transcrito" não se fotografa.
    static var ensaioDoDitado: String?
    #endif

    static func ditar() {
        ditadoPendente = true
        anunciar()
    }

    static func consumirDitado() -> Bool {
        defer { ditadoPendente = false }
        return ditadoPendente
    }

    /// Só o deep link das escalas — a aba sozinha abre no dia.
    static var escalaCalendario: EscalaCalendario?
    static let mudou = Notification.Name("traco.rotaMudou")

    static func daURL(_ url: URL) -> Destino? {
        guard url.scheme == "traco" else { return nil }
        switch url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) {
        case "nova", "": return .novaPagina
        case "notas": return .notas
        case "calendario":
            let resto = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            switch resto {
            case "semana", "week", "w": escalaCalendario = .semana
            case "mes", "month", "m": escalaCalendario = .mes
            case "ano", "year", "y": escalaCalendario = .ano
            case "dia", "day", "d", "": escalaCalendario = .dia
            default: escalaCalendario = .dia
            }
            return .calendario
        case "recordar": return .recordar
        case "nota":
            // ADR 08i: o widget que mostra um trecho promete a continuação —
            // `traco://nota/<uuid>` cai na rota de entidade da 05u, e a tela
            // revalida selo e acesso antes de abrir.
            return UUID(uuidString: url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
                .map(Destino.nota)
        case "ditar":

            // ADR 06c: anuncia o ditado e devolve nil — a Página, que só
            // entende `Destino`, corretamente não faz nada.
            #if DEBUG
            ensaioDoDitado = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first { $0.name == "ensaio" }?.value
            #endif
            ditar()
            return nil
        case "anotar":
            // ADR 05a: traco://anotar?texto=… — a frase cai na entrada
            let texto = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first { $0.name == "texto" }?.value ?? ""
            return texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : .anotar(texto)
        default: return nil
        }
    }
}
