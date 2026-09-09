import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
@Suite(.serialized)
struct IntegridadeEntradaTests {
    enum Recusa: Error { case disco }

    private func isolado(_ executar: (URL) throws -> Void) throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("entrada-integridade-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let corpus = Corpus.diretorio
        let espelho = PastaEspelho.defaults
        let sinais = Sinais.url
        let nome = "entrada-integridade-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Sinais.url = raiz.appendingPathComponent("sinais.json")
        defer {
            Corpus.diretorio = corpus
            PastaEspelho.defaults = espelho
            Sinais.url = sinais
            defaults.removePersistentDomain(forName: nome)
            try? FileManager.default.removeItem(at: raiz)
        }
        try executar(raiz)
    }

    @Test func concluirRecusadoConservaAutoriaSemSinalNemSucesso() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let sessao = Sessao()
            sessao.texto = "Quero estudar espanhol"
            sessao.gesto = .woop
            sessao.campos = ["obstaculo": "Adio a tentativa.\n\nTenho medo de errar."]
            let campos = sessao.campos
            sessao.persistirNoDisco = { _ in throw Recusa.disco }
            sessao.concluir(no: container.mainContext)
            #expect(sessao.texto == "Quero estudar espanhol")
            #expect(sessao.campos == campos)
            #expect(sessao.toast?.contains("guardada") != true)
            #expect(Sinais.todos().filter { $0.tipo == .ficou }.isEmpty)
            #expect(try container.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
            sessao.irPara(.notas, no: container.mainContext)
            #expect(sessao.aba == .escrever)
            sessao.irNotas(no: container.mainContext)
            #expect(!sessao.mostrarNotas)
            // O mesmo rascunho é recuperável, sem reiniciar a sessão.
            sessao.persistirNoDisco = nil
            #expect(sessao.salvar(no: container.mainContext))
            let salva = try #require(container.mainContext.fetch(FetchDescriptor<Nota>()).first)
            #expect(salva.texto == sessao.texto && salva.campos == campos)
        }
    }

    @Test func entradaRecusadaPreservaFonteEReciboNaoAntecedeCommit() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            #expect(Entrada.depositar("Meu único texto", raiz: Entrada.raizDoApp))
            let arquivo = try #require(Entrada.arquivos(raizes: [Entrada.raizDoApp]).first)
            let sessao = Sessao()
            sessao.persistirNoDisco = { _ in throw Recusa.disco }
            sessao.recolherEntrada(no: container.mainContext)
            #expect(FileManager.default.fileExists(atPath: arquivo.url.path))
            #expect(try container.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
            #expect(try container.mainContext.fetch(FetchDescriptor<ReciboEntrada>()).isEmpty)
            sessao.persistirNoDisco = nil
            sessao.recolherEntrada(no: container.mainContext)
            #expect(try container.mainContext.fetch(FetchDescriptor<Nota>()).map(\.texto) == ["Meu único texto"])
            #expect(!FileManager.default.fileExists(atPath: arquivo.url.path))
            #expect(try container.mainContext.fetchCount(FetchDescriptor<ReciboEntrada>()) == 1)
        }
    }

    @Test func replayDepoisDoCommitNaoDuplicaNemRessuscitaNotaApagada() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            #expect(Entrada.depositar("Uma tentativa", raiz: Entrada.raizDoApp))
            let arquivo = try #require(Entrada.arquivos(raizes: [Entrada.raizDoApp]).first)
            let sessao = Sessao()
            sessao.recolherEntrada(no: container.mainContext)
            // Representa queda após commit e antes da retirada da mesma fonte.
            try arquivo.dados.write(to: arquivo.url)
            sessao.recolherEntrada(no: container.mainContext)
            #expect(try container.mainContext.fetchCount(FetchDescriptor<Nota>()) == 1)
            for nota in try container.mainContext.fetch(FetchDescriptor<Nota>()) { container.mainContext.delete(nota) }
            try container.mainContext.save()
            try arquivo.dados.write(to: arquivo.url)
            sessao.recolherEntrada(no: container.mainContext)
            #expect(try container.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
            #expect(!FileManager.default.fileExists(atPath: arquivo.url.path))
        }
    }

    @Test func retiradaNaoApagaUmaEdicaoPosterior() throws {
        try isolado { _ in
            #expect(Entrada.depositar("Primeira versão", raiz: Entrada.raizDoApp))
            let arquivo = try #require(Entrada.arquivos(raizes: [Entrada.raizDoApp]).first)
            try "Outra versão ainda não importada".write(to: arquivo.url, atomically: true, encoding: .utf8)
            #expect(!Entrada.confirmar(arquivo))
            #expect(try String(contentsOf: arquivo.url, encoding: .utf8) == "Outra versão ainda não importada")
        }
    }

    @Test func linkNaEntradaNaoConcedeAutoridadeSobreArquivoExterno() throws {
        try isolado { raiz in
            let alvo = raiz.appendingPathComponent("fora.md")
            try "Não sou entrada".write(to: alvo, atomically: true, encoding: .utf8)
            let pasta = Entrada.raizDoApp.appendingPathComponent("entrada")
            try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
            try FileManager.default.createSymbolicLink(at: pasta.appendingPathComponent("link.md"), withDestinationURL: alvo)
            #expect(Entrada.arquivos(raizes: [Entrada.raizDoApp]).isEmpty)
            #expect(try String(contentsOf: alvo, encoding: .utf8) == "Não sou entrada")
        }
    }

    @Test func entradaMistaPreservaFonteRecusadaSemReimportarParteAberta() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let pasta = Entrada.raizDoApp.appendingPathComponent("entrada")
            try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
            let url = pasta.appendingPathComponent("mista.md")
            let texto = "---\ncriada: 2026-09-05T00:00:00Z\n---\n\naberta\n\n---\ncriada: 2026-09-05T01:00:00Z\nestado: selada\n---\n\nconteúdo protegido\n"
            try texto.write(to: url, atomically: true, encoding: .utf8)
            let sessao = Sessao()
            sessao.recolherEntrada(no: container.mainContext)
            sessao.recolherEntrada(no: container.mainContext)
            #expect(try container.mainContext.fetch(FetchDescriptor<Nota>()).map(\.texto) == ["aberta"])
            #expect(try String(contentsOf: url, encoding: .utf8) == texto)
        }
    }

    @Test func migracaoV2PreservaNotaEReciboSobreviveReabertura() throws {
        try isolado { raiz in
            let url = raiz.appendingPathComponent("migracao.sqlite")
            let uuid = UUID()
            do {
                let antigo = try ModelContainer(for: Schema(versionedSchema: TracoSchemaV2.self),
                    configurations: ModelConfiguration(url: url))
                // ADR 09f: a V2 é uma CÓPIA CONGELADA, não a classe viva — gravar
                // aqui com a `Nota` de hoje não migrava coisa nenhuma (era o mesmo
                // modelo dos dois lados), e foi essa ficção que deixou a 08u passar.
                let nota = TracoSchemaV2.Nota()
                nota.uuid = uuid
                nota.texto = "Autoria anterior"
                nota.gestoRaw = "woop"
                nota.camposJSON = #"{"obstaculo":"Primeiro\n\nSegundo"}"#
                antigo.mainContext.insert(nota)
                try antigo.mainContext.save()
            }
            do {
                let novo = try ModelContainer.traco(url: url)
                let nota = try #require(novo.mainContext.fetch(FetchDescriptor<Nota>()).first)
                #expect(nota.uuid == uuid && nota.texto == "Autoria anterior")
                #expect(nota.campos["obstaculo"] == "Primeiro\n\nSegundo")
                novo.mainContext.insert(ReciboEntrada(chave: "recibo-persistente"))
                try novo.mainContext.save()
            }
            let reaberto = try ModelContainer.traco(url: url)
            #expect(try reaberto.mainContext.fetchCount(FetchDescriptor<Nota>()) == 1)
            #expect(try reaberto.mainContext.fetch(FetchDescriptor<ReciboEntrada>()).map(\.chave) == ["recibo-persistente"])
        }
    }
}
