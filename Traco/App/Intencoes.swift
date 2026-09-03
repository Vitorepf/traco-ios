import AppIntents
import SwiftData
import SwiftUI

/// O app fora do app (exp 3): Atalhos, Siri e Action Button chegam de graça
/// com App Intents no alvo principal — sem extensão, sem app group.
struct NovaNotaIntent: AppIntent {
    static let title: LocalizedStringResource = "Nova nota"
    static let description = IntentDescription("Abre o Traço numa página em branco, pronta para escrever.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Rota.pendente = .novaPagina
        NotificationCenter.default.post(name: Rota.mudou, object: nil)
        return .result()
    }
}

struct AbrirNotasIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir notas"
    static let description = IntentDescription("Abre a lista de notas do Traço.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        Rota.pendente = .notas
        NotificationCenter.default.post(name: Rota.mudou, object: nil)
        return .result()
    }
}

struct TracoAtalhos: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NovaNotaIntent(),
            phrases: ["Nova nota no \(.applicationName)", "Escrever no \(.applicationName)"],
            shortTitle: "Nova nota",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: AbrirNotasIntent(),
            phrases: ["Minhas notas no \(.applicationName)"],
            shortTitle: "Notas",
            systemImageName: "list.bullet"
        )
        AppShortcut(
            intent: DestaqueDeHojeIntent(),
            phrases: ["Destaque de hoje no \(.applicationName)", "Qual é o meu destaque no \(.applicationName)"],
            shortTitle: "Destaque de hoje",
            systemImageName: "sparkle"
        )
        AppShortcut(
            intent: CompromissosDeHojeIntent(),
            phrases: ["Meu dia no \(.applicationName)", "O que tenho hoje no \(.applicationName)"],
            shortTitle: "Meu dia",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: LinhasDeSentidoIntent(),
            phrases: ["Linhas de sentido do \(.applicationName)"],
            shortTitle: "Linhas de sentido",
            systemImageName: "text.quote"
        )
        AppShortcut(
            intent: CorpusComoContextoIntent(),
            phrases: ["Contexto do \(.applicationName)", "Minhas notas como contexto no \(.applicationName)"],
            shortTitle: "Como contexto",
            systemImageName: "doc.text"
        )
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
private func notasDoDisco() -> [Nota] {
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
    var forma: GestoEscolha?

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        var fatias = fatiasDoDisco()
        if let forma { fatias = fatias.filter { $0.gesto == forma.gesto } }
        return .result(value: Corpus.corpoDoCorpus(fatias: fatias))
    }
}

/// As formas do §6 como enum de Atalhos.
enum GestoEscolha: String, AppEnum {
    case woop, seEntao, spec, notaPermanente, destaque, destilar, palavra

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Forma")
    static let caseDisplayRepresentations: [GestoEscolha: DisplayRepresentation] = [
        .woop: "WOOP", .seEntao: "Se–então", .spec: "Especificação",
        .notaPermanente: "Nota permanente", .destaque: "Destaque",
        .destilar: "Destilar", .palavra: "Palavra",
    ]

    var gesto: Gesto {
        switch self {
        case .woop: .woop
        case .seEntao: .seEntao
        case .spec: .spec
        case .notaPermanente: .notaPermanente
        case .destaque: .destaque
        case .destilar: .destilar
        case .palavra: .palavra
        }
    }
}

/// Rota de entrada única: intents e traco:// convergem aqui; a PaginaView consome.
@MainActor
enum Rota {
    enum Destino { case novaPagina, notas, calendario, recordar }
    static var pendente: Destino?
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
        default: return nil
        }
    }
}
