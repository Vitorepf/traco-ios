import Foundation
import SwiftData

/// Schema versionado desde o dia 1: toda mudança futura em `Nota` entra como
/// V2 + estágio de migração — nunca como perda silenciosa das notas do autor.
enum TracoSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Nota.self] }
}

enum TracoMigracao: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TracoSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

/// Verdade sobre o arranque. Se o banco de disco não abriu, o app está em
/// memória: NADA do que se escreve fica, e o backup no Arquivos não pode ser
/// tocado — senão o único backup do corpus morreria reescrito com uma nota.
/// Nunca em silêncio: a página avisa (radiografia 02/set, P0).
enum Arranque {
    static var bancoEmMemoria = false
}

extension ModelContainer {
    /// Container oficial do app — sempre com o plano de migração.
    static func traco(emMemoria: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let config = url.map { ModelConfiguration(url: $0) } ?? ModelConfiguration(isStoredInMemoryOnly: emMemoria)
        return try ModelContainer(
            for: Schema(versionedSchema: TracoSchemaV1.self),
            migrationPlan: TracoMigracao.self,
            configurations: config
        )
    }

    /// O arranque do app. Se o banco de disco não abre (schema, disco cheio,
    /// arquivo corrompido), abre em memória e LEVANTA A BANDEIRA: a página
    /// avisa, e nada destrutivo (backup, índice, varredura de anexos) roda.
    /// O arquivo em disco não é tocado.
    static func tracoOuEmergencia(url: URL? = nil) -> ModelContainer {
        do {
            let c = try traco(url: url)
            Arranque.bancoEmMemoria = false
            return c
        } catch {
            Arranque.bancoEmMemoria = true
            return try! traco(emMemoria: true)
        }
    }
}
