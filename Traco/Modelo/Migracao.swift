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

enum TracoSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(3, 0, 0) }
    static var models: [any PersistentModel.Type] { [Nota.self, ReciboEntrada.self] }
}

enum TracoSchemaV4: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(4, 0, 0) }
    static var models: [any PersistentModel.Type] { [Nota.self, ReciboEntrada.self, Trabalho.self] }
}

enum TracoMigracao: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TracoSchemaV1.self, TracoSchemaV2.self, TracoSchemaV3.self, TracoSchemaV4.self] }
    static var stages: [MigrationStage] {
        [MigrationStage.lightweight(fromVersion: TracoSchemaV1.self, toVersion: TracoSchemaV2.self),
         MigrationStage.lightweight(fromVersion: TracoSchemaV2.self, toVersion: TracoSchemaV3.self),
         MigrationStage.lightweight(fromVersion: TracoSchemaV3.self, toVersion: TracoSchemaV4.self)]
    }
}

/// O arranque do disco. Se o banco não abre, NADA se abre no lugar dele: a
/// versão anterior caía num contentor em memória e deixava o app inteiro de pé
/// sobre um caderno vazio — e as rotas do selo (`Corpus.escrever`) apagam do
/// espelho em Arquivos todo `.md` que não estiver na lista que recebem. Um
/// caderno vazio na RAM sobrevoando o espelho é o estrago que o defeito ainda
/// não tinha feito (ADR 2026-09-08n). Preservar vem antes de voltar a funcionar.
enum DiscoTraco {
    /// O container do app, para os intents reusarem em vez de abrir outro.
    static var compartilhado: ModelContainer?

    enum Resultado {
        case aberto(ModelContainer)
        case recusou(Error)
    }

    /// Testes: memória. App: disco. A recusa é estado tratado, nunca `try!` —
    /// e nunca um contentor de emergência que finge ser o caderno.
    static func abrir(
        emTeste: Bool,
        disco: () throws -> ModelContainer = { try ModelContainer.traco() },
        memoria: () throws -> ModelContainer = { try ModelContainer.traco(emMemoria: true) }
    ) -> Resultado {
        do {
            let container = try emTeste ? memoria() : disco()
            compartilhado = container
            return .aberto(container)
        } catch {
            compartilhado = nil
            return .recusou(error)
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
            for: Schema(versionedSchema: TracoSchemaV4.self),
            migrationPlan: TracoMigracao.self,
            configurations: config
        )
    }
}
