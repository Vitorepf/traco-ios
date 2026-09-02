import Foundation
import SwiftData

/// Schema versionado desde o dia 1: toda mudança futura em `Nota` entra como
/// V2 + estágio de migração — nunca como perda silenciosa das notas do autor.
enum TracoSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Nota.self] }

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
        var queimada: Bool = false
        var queimadaEm: Date?
        var minutosEscritos: Int = 0
        var sentido: String = ""

        init(
            texto: String = "",
            gestoRaw: String? = nil,
            camposJSON: String = "{}",
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
            self.gestoRaw = gestoRaw
            self.camposJSON = camposJSON
            self.trancada = trancada
            self.criadaEm = criadaEm
            self.editadaEm = editadaEm
            self.expressivaPrazo = expressivaPrazo
            self.queimada = queimada
            self.queimadaEm = queimadaEm
            self.minutosEscritos = minutosEscritos
            self.sentido = sentido
        }
    }
}

enum TracoSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [Nota.self] }
}

enum TracoMigracao: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TracoSchemaV1.self, TracoSchemaV2.self] }
    static var stages: [MigrationStage] {
        [MigrationStage.lightweight(fromVersion: TracoSchemaV1.self, toVersion: TracoSchemaV2.self)]
    }
}

extension ModelContainer {
    /// Container oficial do app — sempre com o plano de migração.
    static func traco(emMemoria: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: TracoSchemaV2.self),
            migrationPlan: TracoMigracao.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: emMemoria)
        )
    }
}
