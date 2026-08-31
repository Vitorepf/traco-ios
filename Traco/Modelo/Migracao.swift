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

extension ModelContainer {
    /// Container oficial do app — sempre com o plano de migração.
    static func traco(emMemoria: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: TracoSchemaV1.self),
            migrationPlan: TracoMigracao.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: emMemoria)
        )
    }
}
