import AppIntents
import SwiftData
import SwiftUI

/// ADR 05u — as entidades mínimas do Traço para Atalhos e Siri.
///
/// Só id e um título público. O selo entra ANTES de qualquer representação:
/// expressiva (em curso ou fechada), selada e queimada não viram entidade;
/// Trabalho só depois de `AcessoTrabalho`; compromisso só o que o autor
/// marcou (deixa de nota e projeção do Trabalho ficam com os donos, ADR 05k).
/// O `perform()` de quem recebe a entidade revalida de novo: o sistema pode
/// devolver uma entidade antiga, e proteção acontece depois da consulta.

// MARK: - Nota

struct NotaEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Nota")
    static let defaultQuery = NotaQuery()

    var id: UUID
    var titulo: String

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(titulo)") }

    /// A única porta: nota pública, com voz, um título.
    @MainActor
    static func publica(_ nota: Nota) -> NotaEntity? {
        guard !nota.fechada, nota.gesto != .expressiva, nota.temVoz else { return nil }
        let t = nota.tituloNaLista.trimmingCharacters(in: .whitespacesAndNewlines)
        return NotaEntity(id: nota.uuid, titulo: t.isEmpty ? "Nota" : t)
    }

    @MainActor
    static func publicas(agora: Date = .now) -> [NotaEntity] {
        notasDoDisco().sorted { $0.editadaEm > $1.editadaEm }.compactMap(publica)
    }
}

struct NotaQuery: EntityQuery, EntityStringQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [NotaEntity] {
        NotaEntity.publicas().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [NotaEntity] {
        Array(NotaEntity.publicas().prefix(10))
    }

    @MainActor
    func entities(matching string: String) async throws -> [NotaEntity] {
        let termo = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termo.isEmpty else { return [] }
        return NotaEntity.publicas().filter { $0.titulo.localizedCaseInsensitiveContains(termo) }
    }
}

struct AbrirNotaIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir nota"
    static let description = IntentDescription("Abre uma nota do Traço na página.")
    static let openAppWhenRun = true

    @Parameter(title: "Nota")
    var nota: NotaEntity

    static var parameterSummary: some ParameterSummary { Summary("Abrir \(\.$nota)") }

    /// Revalida: o sistema pode entregar uma entidade de antes do selo.
    @MainActor
    static func destino(_ nota: NotaEntity) -> Rota.Destino? {
        NotaEntity.publicas().contains(where: { $0.id == nota.id }) ? .nota(nota.id) : nil
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let destino = Self.destino(nota) else {
            return .result(dialog: "Essa nota não está disponível.")
        }
        Rota.ir(destino)
        return .result(dialog: "")
    }
}

// MARK: - Trabalho

struct TrabalhoEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Trabalho")
    static let defaultQuery = TrabalhoQuery()

    var id: UUID
    var titulo: String

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(titulo)") }

    /// Só com `AcessoTrabalho.permitido`: origem ausente ou protegida não
    /// entrega nem o título.
    @MainActor
    static func permitidos() -> [TrabalhoEntity] {
        guard let container = DiscoTraco.compartilhado ?? (try? ModelContainer.traco()) else { return [] }
        let contexto = ModelContext(container)
        let todos = (try? contexto.fetch(FetchDescriptor<Trabalho>(sortBy: [SortDescriptor(\.atualizadoEm, order: .reverse)]))) ?? []
        return todos.filter { AcessoTrabalho.permitido($0, no: contexto) }.map {
            let t = $0.titulo.trimmingCharacters(in: .whitespacesAndNewlines)
            return TrabalhoEntity(id: $0.uuid, titulo: t.isEmpty ? "Trabalho" : t)
        }
    }
}

struct TrabalhoQuery: EntityQuery, EntityStringQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [TrabalhoEntity] {
        TrabalhoEntity.permitidos().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [TrabalhoEntity] {
        Array(TrabalhoEntity.permitidos().prefix(10))
    }

    @MainActor
    func entities(matching string: String) async throws -> [TrabalhoEntity] {
        let termo = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termo.isEmpty else { return [] }
        return TrabalhoEntity.permitidos().filter { $0.titulo.localizedCaseInsensitiveContains(termo) }
    }
}

struct AbrirTrabalhoIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir trabalho"
    static let description = IntentDescription("Abre um trabalho do Traço.")
    static let openAppWhenRun = true

    @Parameter(title: "Trabalho")
    var trabalho: TrabalhoEntity

    static var parameterSummary: some ParameterSummary { Summary("Abrir \(\.$trabalho)") }

    @MainActor
    static func destino(_ trabalho: TrabalhoEntity) -> Rota.Destino? {
        TrabalhoEntity.permitidos().contains(where: { $0.id == trabalho.id }) ? .trabalho(trabalho.id) : nil
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let destino = Self.destino(trabalho) else {
            return .result(dialog: "Esse trabalho não está disponível.")
        }
        Rota.ir(destino)
        return .result(dialog: "")
    }
}

// MARK: - Compromisso

struct CompromissoEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Compromisso")
    static let defaultQuery = CompromissoQuery()

    /// `Superficie.ocorrencia`: série repetida tem o mesmo UUID em cada dia.
    var id: String
    var compromisso: UUID
    var titulo: String
    var inicio: Date
    var diaInteiro: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(titulo)", subtitle: "\(Superficie.quando(inicio, diaInteiro: diaInteiro))")
    }

    /// Só o que o autor marcou, nas duas semanas seguintes. Deixa de nota e
    /// projeção do Trabalho não são compromissos (ADR 05k).
    @MainActor
    static func proximos(agora: Date = .now) -> [CompromissoEntity] {
        guard case .eventos(let eventos) = CalendarioDisco.carregar() else { return [] }
        let cal = Calendario.gregoriano()
        let ate = cal.date(byAdding: .day, value: 14, to: agora) ?? agora
        return Calendario.ocorrencias(eventos.filter { $0.editavel && !$0.eDeixa && $0.origemTrabalho == nil },
                                      de: agora, a: ate, cal)
            .filter { $0.fim > agora }
            .sorted { $0.inicio < $1.inicio }
            .map { CompromissoEntity(id: Superficie.ocorrencia($0.id, $0.inicio), compromisso: $0.id,
                                     titulo: $0.titulo, inicio: $0.inicio, diaInteiro: $0.diaInteiro) }
    }
}

struct CompromissoQuery: EntityQuery, EntityStringQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [CompromissoEntity] {
        CompromissoEntity.proximos().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [CompromissoEntity] {
        Array(CompromissoEntity.proximos().prefix(10))
    }

    @MainActor
    func entities(matching string: String) async throws -> [CompromissoEntity] {
        let termo = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termo.isEmpty else { return [] }
        return CompromissoEntity.proximos().filter { $0.titulo.localizedCaseInsensitiveContains(termo) }
    }
}

struct AbrirCompromissoIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir compromisso"
    static let description = IntentDescription("Abre o calendário do Traço no dia do compromisso.")
    static let openAppWhenRun = true

    @Parameter(title: "Compromisso")
    var compromisso: CompromissoEntity

    static var parameterSummary: some ParameterSummary { Summary("Abrir \(\.$compromisso)") }

    @MainActor
    static func destino(_ compromisso: CompromissoEntity) -> Rota.Destino? {
        guard let c = CompromissoEntity.proximos().first(where: { $0.id == compromisso.id }) else { return nil }
        return .compromisso(id: c.compromisso, inicio: c.inicio)
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let destino = Self.destino(compromisso) else {
            return .result(dialog: "Esse compromisso não está mais marcado.")
        }
        Rota.ir(destino)
        return .result(dialog: "")
    }
}
