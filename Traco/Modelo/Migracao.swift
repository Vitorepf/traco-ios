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

/// O disco falhou: a página não finge que o caderno está vazio.
enum DiscoTraco {
    static var aviso: String?
    /// O container do app, para os intents reusarem em vez de abrir outro.
    static var compartilhado: ModelContainer?

    /// Testes: memória. App: disco. Se o disco recusa, o aviso diz a verdade
    /// e o contentor em memória só existe para o SwiftUI não explodir.
    static func abrir(
        emTeste: Bool,
        disco: () throws -> ModelContainer = { try ModelContainer.traco() },
        memoria: () throws -> ModelContainer = { try ModelContainer.traco(emMemoria: true) }
    ) rethrows -> ModelContainer {
        if emTeste { return try memoria() }
        do {
            aviso = nil
            return try disco()
        } catch {
            aviso = "as notas estão no disco e não abri. o app não inventa um caderno vazio."
            return try memoria()
        }
    }
}

extension ModelContainer {
    /// Container oficial do app — sempre com o plano de migração.
    static func traco(emMemoria: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let config: ModelConfiguration
        if let url {
            config = ModelConfiguration(url: url)
        } else {
            config = ModelConfiguration(isStoredInMemoryOnly: emMemoria)
        }
        return try ModelContainer(
            for: Schema(versionedSchema: TracoSchemaV2.self),
            migrationPlan: TracoMigracao.self,
            configurations: config
        )
    }
}
