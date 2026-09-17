import Foundation
import SwiftData
import Testing
@testable import Traco

/// Auditoria de 17/09: o que a varredura, a queima e a janela de desfazer
/// faziam com arquivos que o autor ainda podia querer de volta.
@MainActor
@Suite(.serialized)
struct AuditoriaIntegridadeTests {
    private func isolado(_ executar: (URL) throws -> Void) throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("auditoria-integridade-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let corpus = Corpus.diretorio
        let espelho = PastaEspelho.defaults
        let indice = Indice.url
        let versoes = Versoes.diretorio
        let nome = "auditoria-integridade-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Indice.url = raiz.appendingPathComponent("indice.json")
        Versoes.diretorio = raiz.appendingPathComponent("versoes")
        defer {
            Corpus.diretorio = corpus
            PastaEspelho.defaults = espelho
            Indice.url = indice
            Versoes.diretorio = versoes
            defaults.removePersistentDomain(forName: nome)
            try? FileManager.default.removeItem(at: raiz)
        }
        try executar(raiz)
    }

    /// Um anexo "velho" (fora da carência de 24 h) na pasta real de anexos.
    private func anexoVelho() throws -> (id: String, url: URL) {
        let id = UUID().uuidString.lowercased()
        let url = AnexoDisco.pasta().appendingPathComponent("\(id).png")
        try Data("x".utf8).write(to: url)
        let ontem = Date().addingTimeInterval(-48 * 3600)
        try FileManager.default.setAttributes([.modificationDate: ontem], ofItemAtPath: url.path)
        return (id, url)
    }

    @Test func versaoGuardadaSeguraOAnexo() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let context = ModelContext(container)
            let anexo = try anexoVelho()
            defer { try? FileManager.default.removeItem(at: anexo.url) }
            let nota = Nota(texto: "sem foto agora")
            context.insert(nota)
            try context.save()
            // a foto só existe numa versão anterior da nota
            Versoes.registrar(nota.uuid, texto: "com foto ![f](traco://img/\(anexo.id))",
                              campos: [:], gesto: nil, fechada: false)
            Sessao().varrerAnexosOrfaos(no: context)
            #expect(FileManager.default.fileExists(atPath: anexo.url.path),
                    "restaurar a versão precisa achar o arquivo")
        }
    }

    @Test func desfazerApagarDevolveVersoesEAnexos() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let context = ModelContext(container)
            let anexo = try anexoVelho()
            defer { try? FileManager.default.removeItem(at: anexo.url) }
            let nota = Nota(texto: "ideia ![f](traco://img/\(anexo.id))")
            let id = nota.uuid
            context.insert(nota)
            try context.save()
            Versoes.registrar(id, texto: "rascunho antigo", campos: [:], gesto: nil, fechada: false)

            let s = Sessao()
            s.apagar(uuid: id, no: context)
            s.varrerAnexosOrfaos(no: context) // a Página aparece durante a janela
            #expect(FileManager.default.fileExists(atPath: anexo.url.path))
            #expect(!Versoes.listar(id).isEmpty)
            #expect(s.toast == "nota apagada.")

            s.desfazerApagar(no: context)
            #expect(Sessao.buscar(uuid: id, no: context) != nil)
            #expect(Versoes.listar(id).map(\.texto) == ["rascunho antigo"])
            #expect(FileManager.default.fileExists(atPath: anexo.url.path))
        }
    }

    @Test func fecharAJanelaApagaOQueFicouGuardado() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let context = ModelContext(container)
            let anexo = try anexoVelho()
            defer { try? FileManager.default.removeItem(at: anexo.url) }
            let nota = Nota(texto: "ideia ![f](traco://img/\(anexo.id))")
            let id = nota.uuid
            context.insert(nota)
            try context.save()
            Versoes.registrar(id, texto: "rascunho antigo", campos: [:], gesto: nil, fechada: false)

            let s = Sessao()
            s.apagar(uuid: id, no: context)
            s.consolidarApagada(no: context)
            #expect(s.apagadaRecuperavel == nil)
            #expect(Versoes.listar(id).isEmpty)
            #expect(!FileManager.default.fileExists(atPath: anexo.url.path))
        }
    }

    @Test func apagarEmLoteNaoAbreJanela() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let context = ModelContext(container)
            let nota = Nota(texto: "uma de muitas")
            context.insert(nota)
            try context.save()
            Versoes.registrar(nota.uuid, texto: "antes", campos: [:], gesto: nil, fechada: false)
            let s = Sessao()
            s.apagar(uuid: nota.uuid, no: context, recuperavel: false)
            #expect(s.apagadaRecuperavel == nil)
            #expect(Versoes.listar(nota.uuid).isEmpty)
        }
    }

    @Test func queimarLevaOsAnexosNaHora() throws {
        try isolado { _ in
            let container = try ModelContainer.traco(emMemoria: true)
            let context = ModelContext(container)
            // anexo recém-gravado: a varredura esperaria 24 h, a queima não
            let id = UUID().uuidString.lowercased()
            let url = AnexoDisco.pasta().appendingPathComponent("\(id).m4a")
            try Data("x".utf8).write(to: url)
            defer { try? FileManager.default.removeItem(at: url) }
            let s = Sessao()
            s.gesto = .expressiva
            s.texto = "desabafo [audio:a](traco://audio/\(id))"
            s.salvar(no: context)
            #expect(s.queimar(no: context, sentido: ""))
            #expect(!FileManager.default.fileExists(atPath: url.path))
        }
    }

    @Test func statusHTTPTemNomeProprio() {
        #expect(Grok.falhaDoStatus(401) == .semConta)
        #expect(Grok.falhaDoStatus(403) == .semConta)
        #expect(Grok.falhaDoStatus(429) == .ocupado)
        #expect(Grok.falhaDoStatus(503) == .provedor)
        #expect(Grok.falhaDoStatus(200) == nil)
        #expect(Grok.falhaDoStatus(nil) == nil)
        for f in [Grok.FalhaHonesta.ocupado, .provedor] {
            #expect(Grok.frase(f).contains("continua aqui"))
        }
    }

    @Test func rotaCortadaNaoViraBotao() {
        // instigar e contrapor estão fora por qualidade: a Lente não os oferece
        for op in Politica.indisponiveis {
            #expect(LenteView.cortada(op))
        }
        #expect(!LenteView.cortada(.responderNasNotas))
    }
}

/// A cópia em .md volta ao caderno sem duplicar nem perder a identidade.
@MainActor
struct CopiaVoltaAoCadernoTests {
    @Test func importarACopiaDuasVezesNaoDuplicaEMantemOId() throws {
        let origem = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "decidi subir o preço", gesto: .woop, campos: ["obstaculo": "medo"])
        nota.dominio = .trabalho
        nota.editadaEm = Date(timeIntervalSince1970: 1_000_000)
        origem.mainContext.insert(nota)
        try origem.mainContext.save()
        let md = Corpus.arquivoMd(FatiaCorpus.de(nota))

        let destino = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        #expect(s.importarCorpus(Corpus.importar(md), no: destino.mainContext, anunciar: false) == 1)
        #expect(s.importarCorpus(Corpus.importar(md), no: destino.mainContext, anunciar: false) == 0)
        let voltou = try #require(try destino.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(try destino.mainContext.fetch(FetchDescriptor<Nota>()).count == 1)
        #expect(voltou.uuid == nota.uuid)
        #expect(voltou.editadaEm == nota.editadaEm)
        #expect(voltou.dominio == .trabalho)
        #expect(voltou.campos["obstaculo"] == "medo")
    }
}

/// As candidatas a eco vão inteiras ou não vão (o corte em 9.000 partia a última).
struct EcosCabemInteirosTests {
    @Test func aCandidataQueNaoCabeFicaDeForaInteira() {
        let linha = String(repeating: "a", count: 296) // "[i] " + 296 = 300, mais 2 de separador
        let quarenta = Array(repeating: linha, count: 40)
        let n = Sabia.quantasCabem(quarenta)
        #expect(n == 29) // 300 + 9 × 302 + 19 × 303 = 8.775; a 30ª passaria de 9.000
        let corpo = quarenta.prefix(n).enumerated().map { "[\($0.offset)] \($0.element)" }.joined(separator: "\n\n")
        #expect(corpo.count <= 9000)
        #expect(Sabia.quantasCabem(["curta"]) == 1)
        #expect(Sabia.quantasCabem([]) == 0)
    }
}

/// Aspas nas Notas são palavra literal de quem escreve, ou deixam de ser aspas.
struct AspasHonestasTests {
    private func pacote() -> RespostaNotas.Pacote {
        let fonte = FonteNotas(id: UUID(), titulo: "Proposta atual",
                               texto: "Decidi subir o preço para R$ 8.400 a partir de outubro.",
                               editadaEm: .now)
        return RespostaNotas.Pacote(mensagem: "quanto vou cobrar?", fontes: [fonte], omitidas: 0)
    }

    @Test func citacaoLiteralFicaInventadaPerdeAsAspas() {
        let p = pacote()
        #expect(RespostaNotas.aspasHonestas("Você escreveu «subir o preço para R$ 8.400».", pacote: p)
                == "Você escreveu «subir o preço para R$ 8.400».")
        #expect(RespostaNotas.aspasHonestas("Na “Proposta atual” você fixou o valor.", pacote: p)
                == "Na “Proposta atual” você fixou o valor.")
        #expect(RespostaNotas.aspasHonestas("Você escreveu «dobrar o preço já».", pacote: p)
                == "Você escreveu dobrar o preço já.")
        // caixa, acento e espaço não fazem a citação deixar de ser literal
        #expect(RespostaNotas.aspasHonestas("«DECIDI  SUBIR o preco»", pacote: p) == "«DECIDI  SUBIR o preco»")
    }
}
