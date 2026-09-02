import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct CorpusSeloTests {
    @Test func contratoEIndiceVaoNoCorpus() {
        let corpo = Corpus.corpoDoCorpus(fatias: [
            FatiaCorpus(
                id: UUID(), texto: "quero correr de manhã", gesto: .woop,
                campos: ["obstaculo": "celular"], criadaEm: Date(timeIntervalSince1970: 2),
                editadaEm: Date(timeIntervalSince1970: 3), recordada: 2, sentido: "",
                minutos: 0, trancada: false, queimada: false, expressivaEmCurso: false,
                dominio: .saude, serie: nil, dia: 0)
        ])
        #expect(corpo.hasPrefix("# Traço — corpus"))
        #expect(corpo.contains("Nenhuma\npalavra aqui veio de um modelo") || corpo.contains("Nenhuma palavra aqui veio de um modelo"))
        #expect(corpo.contains("recordada: 2"))
        #expect(corpo.contains("dominio: Saúde"))
        #expect(corpo.contains("id: "))
        #expect(!corpo.contains("traco://"))
    }

    @Test func seloNasQuatroRotas() {
        let aberta = FatiaCorpus(
            id: UUID(), texto: "quero o WOOP aberto", gesto: .woop,
            campos: ["resultado": "energia"], criadaEm: Date(timeIntervalSince1970: 1),
            editadaEm: Date(timeIntervalSince1970: 1), recordada: 0, sentido: "",
            minutos: 0, trancada: false, queimada: false, expressivaEmCurso: false,
            dominio: nil, serie: nil, dia: 0)
        let selada = FatiaCorpus(
            id: UUID(), texto: "dor selada nunca viaja", gesto: .expressiva,
            campos: [:], criadaEm: Date(timeIntervalSince1970: 2),
            editadaEm: Date(timeIntervalSince1970: 2), recordada: 0, sentido: "vi o medo",
            minutos: 12, trancada: true, queimada: false, expressivaEmCurso: false,
            dominio: nil, serie: nil, dia: 0)
        let curso = FatiaCorpus(
            id: UUID(), texto: "ainda escrevendo a dor", gesto: .expressiva,
            campos: [:], criadaEm: Date(timeIntervalSince1970: 3),
            editadaEm: Date(timeIntervalSince1970: 3), recordada: 0, sentido: "",
            minutos: 4, trancada: false, queimada: false, expressivaEmCurso: true,
            dominio: nil, serie: nil, dia: 0)
        let queimada = FatiaCorpus(
            id: UUID(), texto: "dor queimada nunca viaja", gesto: .expressiva,
            campos: [:], criadaEm: Date(timeIntervalSince1970: 4),
            editadaEm: Date(timeIntervalSince1970: 4), recordada: 0, sentido: "o que ficou",
            minutos: 15, trancada: false, queimada: true, expressivaEmCurso: false,
            dominio: nil, serie: nil, dia: 0)
        let corpo = Corpus.corpoDoCorpus(fatias: [aberta, selada, curso, queimada])
        #expect(corpo.contains("quero o WOOP aberto"))
        #expect(corpo.contains("energia"))
        #expect(!corpo.contains("dor selada nunca viaja"))
        #expect(corpo.contains("vi o medo"))
        #expect(corpo.contains("estado: selada"))
        #expect(!corpo.contains("ainda escrevendo a dor"))
        #expect(!corpo.contains("dor queimada nunca viaja"))
        #expect(corpo.contains("o que ficou"))
        #expect(corpo.contains("estado: queimada"))
        let itens = Corpus.importar(corpo)
        #expect(itens.count == 1)
        #expect(itens[0].texto.contains("quero o WOOP aberto"))
    }

    @Test func umMdPorNotaNoArquivos() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("traco-espelho-\(UUID().uuidString)", isDirectory: true)
        let antes = Corpus.diretorio
        Corpus.diretorio = tmp
        defer {
            Corpus.diretorio = antes
            try? FileManager.default.removeItem(at: tmp)
        }
        let id = UUID()
        let fatia = FatiaCorpus(
            id: id, texto: "uma ideia permanente", gesto: .notaPermanente,
            campos: ["ideia": "corta"], criadaEm: Date(timeIntervalSince1970: 9),
            editadaEm: Date(timeIntervalSince1970: 9), recordada: 1, sentido: "",
            minutos: 0, trancada: false, queimada: false, expressivaEmCurso: false,
            dominio: .ideias, serie: nil, dia: 0)
        Corpus.escreverEspelho(fatias: [fatia])
        let leia = try String(contentsOf: tmp.appendingPathComponent("LEIA-ME.md"), encoding: .utf8)
        #expect(leia.contains("segundo cérebro"))
        let nota = try String(
            contentsOf: tmp.appendingPathComponent("notas/\(id.uuidString.lowercased()).md"),
            encoding: .utf8)
        #expect(nota.contains("uma ideia permanente"))
        #expect(nota.contains("id: \(id.uuidString)"))
        #expect(FileManager.default.fileExists(
            atPath: tmp.appendingPathComponent("traco-corpus.md").path))
    }

    @Test func importIgnoraId() {
        let id = UUID()
        let md = """
        ---\n\
        id: \(id.uuidString)\n\
        criada: 1970-01-01T00:00:00Z\n\
        gesto: WOOP\n\
        ---\n\n\
        quero correr\n
        """
        let itens = Corpus.importar(md)
        #expect(itens.count == 1)
        #expect(itens[0].texto.contains("quero correr"))
        #expect(!itens[0].texto.contains(id.uuidString))
    }
}

struct LinguagemTests {
    @Test func destilarPelaEssencia() {
        let v = AnaliseLocal.classificar(
            texto: "preciso destilar isto numa frase", gestoAtual: nil, campos: [:])
        guard case .gesto(.destilar, let p) = v else {
            Issue.record("Destilar deveria vestir")
            return
        }
        #expect(p == AnaliseLocal.pergunta(.destilar))
    }

    @Test func palavraPeloSignificado() {
        let v = AnaliseLocal.classificar(
            texto: "epifania significa o que eu não conhecia", gestoAtual: nil, campos: [:])
        guard case .gesto(.palavra, _) = v else {
            Issue.record("Palavra deveria vestir")
            return
        }
    }

    @Test func destilarNoRemoto() {
        let v = AnaliseRemota.parseVeredito(#"{"gesto":"destilar","aviso":null}"#)
        #expect(v == .gesto(.destilar, pergunta: AnaliseLocal.pergunta(.destilar)))
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"palavra","aviso":null}"#)
                == .gesto(.palavra, pergunta: AnaliseLocal.pergunta(.palavra)))
    }

    @Test func tituloPrefereAFrase() {
        #expect(VozDoAutor.titulo("texto longo", gesto: .destilar, campos: ["frase": "a frase"])
                == "a frase")
        #expect(VozDoAutor.titulo("epifania", gesto: .palavra, campos: ["minhas": "um estalo"])
                == "um estalo")
    }
}

struct DominioTests {
    @Test func inferirPeloLexico() {
        #expect(Dominio.inferir(voz: "reunião com o cliente no slack") == .trabalho)
        #expect(Dominio.inferir(voz: "o boleto do banco venceu") == .dinheiro)
        #expect(Dominio.inferir(voz: "leite") == nil)
    }

    @Test func doNomeFechaALista() {
        #expect(Dominio.doNome("Saúde") == .saude)
        #expect(Dominio.doNome("golpe") == nil)
    }
}

struct GatilhoTests {
    @Test func periodoViraAncora() throws {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 9
        comps.day = 2
        comps.hour = 10
        comps.minute = 0
        let agora = Calendar.current.date(from: comps)!
        let d = Gatilho.data(em: "de manhã, quando acordo", agora: agora)
        let quando = try #require(d)
        #expect(Calendar.current.component(.hour, from: quando) == Ancora.hora(.manha))
        #expect(Calendar.current.component(.day, from: quando) == 3)
    }
}

struct DestaqueDoDiaTests {
    @Test func soValeNoMesmoDia() {
        let suite = UserDefaults(suiteName: DestaqueDoDia.suite) ?? .standard
        suite.removeObject(forKey: DestaqueDoDia.chaveLinha)
        suite.removeObject(forKey: DestaqueDoDia.chaveDia)
        DestaqueDoDia.gravar("a única de hoje")
        #expect(DestaqueDoDia.linhaDeHoje() == "a única de hoje")
        suite.set("1999-01-01", forKey: DestaqueDoDia.chaveDia)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
        suite.removeObject(forKey: DestaqueDoDia.chaveLinha)
        suite.removeObject(forKey: DestaqueDoDia.chaveDia)
    }
}

@MainActor
struct SerieExpressivaTests {
    @Test func primeiroFechoAbreASerie() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "hoje senti o peito pesado e chorei sem saber dizer o nome"
        s.sentidoPendente = "o medo tinha nome"
        s.trancarESair(no: c.mainContext, destino: .pagina)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        s.fechoUUID = nota.uuid
        s.guardarSentidoDoFecho("o medo tinha nome", no: c.mainContext)
        let gravada = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(gravada.serieUUID != nil)
        #expect(gravada.diaDaSerie == 1)
        #expect(gravada.sentido == "o medo tinha nome")
    }
}

@MainActor
struct FilaDoDiaTests {
    @Test func vencidaEntraNaFila() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let u = UUID()
        let nota = Nota(texto: "quero recordar isto", gesto: .woop)
        nota.uuid = u
        nota.criadaEm = Date().addingTimeInterval(-4 * 86400)
        c.mainContext.insert(nota)
        try c.mainContext.save()
        UserDefaults.standard.removeObject(forKey: "revisaoProxima")
        var p: [String: TimeInterval] = [:]
        p[u.uuidString] = Date().addingTimeInterval(-3600).timeIntervalSince1970
        UserDefaults.standard.set(p, forKey: "revisaoProxima")
        let fila = Revisoes.filaDoDia(notas: [nota])
        #expect(fila.map(\.uuid) == [u])
        UserDefaults.standard.removeObject(forKey: "revisaoProxima")
    }
}

@MainActor
struct DominioNaNotaTests {
    @Test func salvarInfereEUmToqueTrava() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "reunião com o cliente no slack"
        s.salvar(no: c.mainContext)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.dominio == .trabalho)
        #expect(!nota.dominioTravado)
        s.desfazerDominio()
        s.salvar(no: c.mainContext)
        #expect(nota.dominio == nil)
        #expect(nota.dominioTravado)
    }
}

@MainActor
struct QuartoFechoTests {
    @Test func sentidosAnterioresFicamLadoALado() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let serie = UUID()
        for dia in 1...3 {
            let n = Nota(texto: "", gesto: .expressiva, trancada: true, sentido: "linha \(dia)")
            n.serieUUID = serie
            n.diaDaSerie = dia
            c.mainContext.insert(n)
        }
        let atual = Nota(texto: "quarto dia", gesto: .expressiva, trancada: true)
        atual.serieUUID = serie
        atual.diaDaSerie = 4
        c.mainContext.insert(atual)
        try c.mainContext.save()
        #expect(Sessao.sentidosAnteriores(atual, no: c.mainContext) == ["linha 1", "linha 2", "linha 3"])
    }
}

struct GestoNovosNomesTests {
    @Test func destilarEPalavraRoundtrip() {
        #expect(Gesto.doNome("Destilar") == .destilar)
        #expect(Gesto.doNome("Palavra") == .palavra)
        #expect(Gesto.doNome("destilar") == .destilar)
    }
}
