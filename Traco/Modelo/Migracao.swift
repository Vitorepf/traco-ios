import Foundation
import SwiftData

/// A PRIMEIRA forma da 1.0.0 — a `Nota` de `b7fbc3e` (31/08 08:27), o commit em
/// que o schema versionado nasceu. Naquela tarde, `fea00dd` (31/08 16:31) pôs
/// `queimada`, `queimadaEm`, `minutosEscritos` e `sentido` na `Nota` **sem abrir
/// versão** — o mesmo pecado da 08u, cometido antes dela. O rótulo continuou
/// `1.0.0`; o checksum, não: `ZaCSxtyZ+GhOyX+/HrdB0vDyHUU4iGbD8pyC5WHEAI8=`
/// virou `c2qnFksOJhh+/ANo29UNO8QkIxGdsSf0P+COGywTg4E=`. Um caderno gravado
/// naquelas oito horas não casava com nenhuma versão do plano e **não abria**
/// (medido, ADR 2026-09-09f). Existem portanto DUAS 1.0.0 no mundo, e o
/// CoreData casa o store pelo CHECKSUM, não pelo rótulo: por isso a primeira
/// entra aqui com um rótulo próprio (`0.9.0`) — que serve só para nós lermos.
enum TracoSchemaV0: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(0, 9, 0) }
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

        init() {
            self.uuid = UUID()
            self.texto = ""
            self.camposJSON = "{}"
            self.trancada = false
            self.criadaEm = .now
            self.editadaEm = .now
        }
    }
}

/// A SEGUNDA forma da 1.0.0 — a `Nota` de `fea00dd` até `bf535c5^`, com o fecho
/// expressivo (queima, minutos, sentido). Schema versionado desde o dia 1: toda
/// mudança futura em `Nota` entra como versão nova + estágio de migração —
/// nunca como perda silenciosa das notas do autor.
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

/// V2 (02/09 a 05/09): a `Nota` ganhou domínio, gatilho e série. Daqui em
/// diante a cópia é CONGELADA — declarada aqui, nunca mais tocada. Um
/// `VersionedSchema` que aponta para a classe VIVA não congela coisa nenhuma:
/// o checksum dele anda junto com o código, e o caderno gravado ontem deixa de
/// ser reconhecido hoje ("Cannot use staged migration with an unknown model
/// version", NSCocoaErrorDomain 134504 — ADR 2026-09-09f). A cópia congelada é
/// o preço de poder abrir o que o autor já escreveu.
enum TracoSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
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
        var dominioRaw: String = ""
        var dominioTravado: Bool = false
        var gatilhoEm: Date?
        var serieRaw: String = ""
        var diaDaSerie: Int = 0

        init() {
            self.uuid = UUID()
            self.texto = ""
            self.camposJSON = "{}"
            self.trancada = false
            self.criadaEm = .now
            self.editadaEm = .now
        }
    }
}

/// V3 (05/09): entrou o recibo de importação. A `Nota` não mudou de V2 para
/// V4 — o que distingue os três checksums é a LISTA de classes, e por isso as
/// três versões reusam a mesma cópia congelada.
enum TracoSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(3, 0, 0) }
    static var models: [any PersistentModel.Type] { [TracoSchemaV2.Nota.self, ReciboEntrada.self] }

    @Model
    final class ReciboEntrada {
        @Attribute(.unique) var chave: String
        var recebidaEm: Date

        init() {
            self.chave = ""
            self.recebidaEm = .now
        }
    }
}

/// V4 (05/09 até a 08u): entrou o `Trabalho`. É a versão em que está o caderno
/// do autor gravado antes da 08u — o store que a R1-C mediu.
enum TracoSchemaV4: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(4, 0, 0) }
    static var models: [any PersistentModel.Type] {
        [TracoSchemaV2.Nota.self, TracoSchemaV3.ReciboEntrada.self, Trabalho.self]
    }

    @Model
    final class Trabalho {
        var uuid: UUID
        var titulo: String
        var atualizadoEm: Date
        var conteudoJSON: Data

        init() {
            self.uuid = UUID()
            self.titulo = ""
            self.atualizadoEm = .now
            self.conteudoJSON = Data()
        }
    }
}

/// V5 (08u/09b): `Nota.origemRaw`. Esta é a versão CORRENTE e a única que
/// aponta para as classes vivas — é o que "corrente" quer dizer. A próxima
/// mudança em `Nota`, `ReciboEntrada` ou `Trabalho` congela uma cópia aqui e
/// abre a V6; o portão `CadernoAntigoAbreTests` fica vermelho se não abrir.
enum TracoSchemaV5: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(5, 0, 0) }
    static var models: [any PersistentModel.Type] { [Nota.self, ReciboEntrada.self, Trabalho.self] }
}

/// O plano. Todo estágio é leve: até aqui só entraram atributo com padrão e
/// modelo novo. O que a 08u errou não foi acrescentar `origemRaw` com padrão —
/// foi acrescentá-lo SEM abrir versão, deixando o checksum da V4 andar com a
/// classe viva. O caderno na mão do autor guarda o checksum do dia em que foi
/// gravado; se nenhuma versão do plano casa com ele, o arranque recusa abrir
/// (`loadIssueModelContainer`) e o autor fica sem o caderno.
enum TracoMigracao: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [/*SONDA TracoSchemaV0.self,*/ TracoSchemaV1.self, TracoSchemaV2.self,
         TracoSchemaV3.self, TracoSchemaV4.self, TracoSchemaV5.self]
    }
    static var stages: [MigrationStage] {
        [/*SONDA*/ MigrationStage.lightweight(fromVersion: TracoSchemaV1.self, toVersion: TracoSchemaV2.self),
         MigrationStage.lightweight(fromVersion: TracoSchemaV2.self, toVersion: TracoSchemaV3.self),
         MigrationStage.lightweight(fromVersion: TracoSchemaV3.self, toVersion: TracoSchemaV4.self),
         MigrationStage.lightweight(fromVersion: TracoSchemaV4.self, toVersion: TracoSchemaV5.self)]
    }
}

/// O arranque do disco. Se o banco não abre, NADA se abre no lugar dele: a
/// versão anterior caía num contentor em memória e deixava o app inteiro de pé
/// sobre um caderno vazio — e as rotas do selo (`Corpus.escrever`) apagam do
/// espelho em Arquivos todo `.md` que não estiver na lista que recebem. Um
/// caderno vazio na RAM sobrevoando o espelho é o estrago que o defeito ainda
/// não tinha feito (ADR 2026-09-08s). Preservar vem antes de voltar a funcionar.
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
            for: Schema(versionedSchema: TracoSchemaV5.self),
            migrationPlan: TracoMigracao.self,
            configurations: config
        )
    }
}
