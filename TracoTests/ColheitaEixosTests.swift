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
        // Importação/colagem não prova autoria: o cabeçalho não pode certificar
        // uma origem que Nota não registra. A proteção do selo segue abaixo.
        #expect(corpo.contains("não certifica autoria humana"))
        #expect(corpo.contains("não inclui o histórico dos Trabalhos"))
        #expect(!corpo.contains("palavra aqui veio de um modelo"))
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

    @Test func importarNaoMenteSeODiscoRecusa() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.persistirNoDisco = { _ in throw DiscoImportRecusou.gravar }
        let n = s.importarCorpus([
            (texto: "quero correr de manhã", gestoNome: "WOOP", criadaEm: .now)
        ], no: c.mainContext)
        #expect(n == 0)
        #expect(s.toast != nil)
        #expect(try c.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
    }

    @Test func importarGravaQuandoODiscoAceita() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        let n = s.importarCorpus([
            (texto: "quero correr de manhã", gestoNome: "WOOP",
             criadaEm: Date(timeIntervalSince1970: 1))
        ], no: c.mainContext)
        #expect(n == 1)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.texto.contains("quero correr"))
        #expect(nota.gesto == .woop)
        #expect(!nota.trancada)
    }
}

private enum DiscoImportRecusou: Error { case gravar }

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

    @Test func destilarCobraAFraseNuncaORascunho() {
        let rascunho = "um parágrafo longo sobre o medo do peito que não saía"
        let campos = [
            "em200": "o medo do peito que não saía",
            "em50": "o medo do peito",
            "frase": "o medo tinha nome",
        ]
        #expect(RitualRecordar.de(.destilar).alvo(texto: rascunho, campos: campos)
                == "o medo tinha nome")
        #expect(RitualRecordar.de(.destilar).alvo(
            texto: rascunho, campos: ["em200": "o medo do peito que não saía", "em50": "o peito"])
                == "o peito")
        #expect(RitualRecordar.de(.destilar).alvo(texto: rascunho, campos: [:]).isEmpty)
        #expect(RitualRecordar.de(.destilar).alvo(texto: rascunho, campos: ["frase": ""]).isEmpty)
    }

    @MainActor
    @Test func destilarSemCorteNaoAbreRecordar() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "um parágrafo longo sobre o medo do peito"
        s.gesto = .destilar
        s.campos = ["em200": "", "frase": ""]
        s.irRecordar(no: c.mainContext)
        #expect(!s.mostrarRecordar)
        s.campos["frase"] = "o medo tinha nome"
        s.texto = ""
        s.irRecordar(no: c.mainContext)
        #expect(s.mostrarRecordar)
        #expect(s.recordarCampos["frase"] == "o medo tinha nome")
        s.mostrarRecordar = false
        let semCorte = Nota(texto: "rascunho sem corte", gesto: .destilar)
        s.recordarDaNotas(semCorte)
        #expect(!s.mostrarRecordar)
    }

    @Test func palavraRecordaAVozNuncaAMarca() {
        #expect(RitualRecordar.de(.palavra).alvo(texto: "# foco", campos: [:]) == "foco")
        #expect(RitualRecordar.de(.palavra).alvo(texto: "foco", campos: [:]) == "foco")
        #expect(!RitualRecordar.de(.palavra).alvo(texto: "# foco", campos: [:]).contains("#"))
    }

    @Test func destilarEPalavraNaoMostramOAlvoAntes() {
        #expect(!RitualRecordar.de(.destilar).mostraAlvoAntesDeEscrever)
        #expect(!RitualRecordar.de(.palavra).mostraAlvoAntesDeEscrever)
        #expect(RitualRecordar.de(.woop).mostraAlvoAntesDeEscrever)
        #expect(RitualRecordar.de(.seEntao).mostraAlvoAntesDeEscrever)
    }

    @Test func tituloPrefereAFrase() {
        #expect(VozDoAutor.titulo("texto longo", gesto: .destilar, campos: ["frase": "a frase"])
                == "a frase")
        #expect(VozDoAutor.titulo("epifania", gesto: .palavra, campos: ["minhas": "um estalo"])
                == "um estalo")
    }

    /// A lista e a tela bloqueada dizem a mesma linha. Voz só no campo
    /// não deixa o arquivo mudo.
    @Test func tituloDoDestaqueEAunica() {
        #expect(VozDoAutor.titulo("", gesto: .destaque, campos: ["unica": "correr antes do café"])
                == "correr antes do café")
        #expect(VozDoAutor.titulo("rascunho do dia", gesto: .destaque, campos: ["unica": "correr"])
                == "correr")
    }

    @Test func tituloNaoFicaMudoQuandoAVozViveNoCampo() {
        #expect(VozDoAutor.titulo("", gesto: .seEntao, campos: ["se": "quando o telefone vibrar"])
                == "quando o telefone vibrar")
        #expect(VozDoAutor.titulo("", gesto: .woop, campos: ["resultado": "energia de manhã"])
                == "energia de manhã")
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
    private func instante(hora: Int, dia: Int = 2) -> Date {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 9
        comps.day = dia
        comps.hour = hora
        comps.minute = 0
        return Calendar.current.date(from: comps)!
    }

    @Test func periodoViraAncora() throws {
        let agora = instante(hora: 10)
        let d = Gatilho.data(em: "de manhã, quando acordo", agora: agora)
        let quando = try #require(d)
        #expect(Calendar.current.component(.hour, from: quando) == Ancora.hora(.manha))
        #expect(Calendar.current.component(.day, from: quando) == 3)
    }

    @Test func horaPassadaHojeRolaAoAmanha() throws {
        let agora = instante(hora: 15)
        let quando = try #require(Gatilho.data(em: "às 8h", agora: agora))
        #expect(Calendar.current.component(.hour, from: quando) == 8)
        #expect(Calendar.current.component(.day, from: quando) == 3)
    }

    @Test func horaAindaPorVirFicaHoje() throws {
        let agora = instante(hora: 7)
        let quando = try #require(Gatilho.data(em: "às 8h", agora: agora))
        #expect(Calendar.current.component(.hour, from: quando) == 8)
        #expect(Calendar.current.component(.day, from: quando) == 2)
    }

    @Test func artigoNaoEHora() {
        let agora = instante(hora: 15)
        #expect(Gatilho.data(em: "as 3 coisas na mesa", agora: agora) == nil)
        #expect(Gatilho.data(em: "quando o telefone vibrar", agora: agora) == nil)
    }
}

struct DestaqueDoDiaTests {
    private func limpar() {
        let suite = UserDefaults(suiteName: DestaqueDoDia.suite) ?? .standard
        suite.removeObject(forKey: DestaqueDoDia.chaveLinha)
        suite.removeObject(forKey: DestaqueDoDia.chaveDia)
        suite.removeObject(forKey: DestaqueDoDia.chaveId)
    }

    @Test func soValeNoMesmoDia() {
        limpar()
        let id = UUID()
        DestaqueDoDia.gravar("a única de hoje", id: id)
        #expect(DestaqueDoDia.linhaDeHoje() == "a única de hoje")
        let suite = UserDefaults(suiteName: DestaqueDoDia.suite) ?? .standard
        suite.set("1999-01-01", forKey: DestaqueDoDia.chaveDia)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
        limpar()
    }

    @Test func apagarADonaSomeDaTela() {
        limpar()
        let id = UUID()
        DestaqueDoDia.gravar("correr", id: id)
        DestaqueDoDia.apagar(id: UUID())
        #expect(DestaqueDoDia.linhaDeHoje() == "correr")
        DestaqueDoDia.apagar(id: id)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
        limpar()
    }

    @Test func telaBloqueadaNaoFingeUmaLinha() {
        limpar()
        #expect(DestaqueDoDia.naTelaBloqueada() == "Traço")
        #expect(!DestaqueDoDia.naTelaBloqueada().contains("—"))
        let id = UUID()
        DestaqueDoDia.gravar("correr", id: id)
        #expect(DestaqueDoDia.naTelaBloqueada() == "correr")
        limpar()
    }
}

@MainActor
struct DestaqueNaSessaoTests {
    @Test func unicaNaListaNaoFicaMuda() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = ""
        s.gesto = .destaque
        s.campos = ["unica": "correr antes do café"]
        s.salvar(no: c.mainContext)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.tituloNaLista == "correr antes do café")
        #expect(DestaqueDoDia.linhaDeHoje() == "correr antes do café")
    }

    @Test func unicaVaziaSobeAVozDoCorpo() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "correr antes do café"
        s.gesto = .destaque
        s.campos = ["unica": ""]
        s.salvar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == "correr antes do café")
        s.campos["unica"] = "só esta"
        s.salvar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == "só esta")
    }

    @Test func largarOGestoTiraDaTelaBloqueada() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "correr antes do café"
        s.gesto = .destaque
        s.campos = ["unica": "correr antes do café"]
        s.salvar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == "correr antes do café")
        s.gesto = .woop
        s.salvar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
    }

    @Test func esvaziarTiraDaTelaBloqueada() throws {
        let suite = UserDefaults(suiteName: DestaqueDoDia.suite) ?? .standard
        suite.removeObject(forKey: DestaqueDoDia.chaveLinha)
        suite.removeObject(forKey: DestaqueDoDia.chaveDia)
        suite.removeObject(forKey: DestaqueDoDia.chaveId)
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "correr antes do café"
        s.gesto = .destaque
        s.salvar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == "correr antes do café")
        s.texto = ""
        s.campos = ["unica": ""]
        s.salvar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
        #expect(s.temVoz == false)
        let noDisco = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(noDisco.texto == "correr antes do café")
        suite.removeObject(forKey: DestaqueDoDia.chaveLinha)
        suite.removeObject(forKey: DestaqueDoDia.chaveDia)
        suite.removeObject(forKey: DestaqueDoDia.chaveId)
    }

    @Test func apagarANotaTiraDaTelaBloqueada() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "uma coisa só"
        s.gesto = .destaque
        s.salvar(no: c.mainContext)
        let id = try #require(s.notaUUID)
        #expect(DestaqueDoDia.linhaDeHoje() == "uma coisa só")
        s.apagar(uuid: id, no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
        s.desfazerApagar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == "uma coisa só")
        let voltou = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(voltou.uuid == id)
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

    @Test func notificacaoDoDiaDoisGravaASerieVazia() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        let serie = UUID()
        s.abrirDiaDaSerie(serie, dia: 2, no: c.mainContext)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.serieUUID == serie)
        #expect(nota.diaDaSerie == 2)
        #expect(nota.gesto == .expressiva)
        #expect(nota.texto.isEmpty)
        #expect(!nota.fechada)
        #expect(nota.expressivaPrazo != nil)
        s.pararTimer()
    }

    @Test func segundoToqueReabreOMesmoDia() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        let serie = UUID()
        s.abrirDiaDaSerie(serie, dia: 2, no: c.mainContext)
        let id = try #require(s.notaUUID)
        s.pararTimer()
        s.novaPagina()
        s.abrirDiaDaSerie(serie, dia: 2, no: c.mainContext)
        #expect(s.notaUUID == id)
        #expect(try c.mainContext.fetch(FetchDescriptor<Nota>()).count == 1)
        s.pararTimer()
    }

    @Test func diaVazioNaoELinhaMuda() throws {
        let n = Nota(texto: "", gesto: .expressiva)
        n.diaDaSerie = 2
        #expect(n.tituloNaLista == "Expressiva · dia 2")
        n.texto = "hoje senti o peito pesado"
        #expect(n.tituloNaLista.contains("peito"))
    }

    @Test func recordarMaisRecenteSaltaPaginaSemVoz() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let fantasma = Nota(texto: "", gesto: .expressiva)
        fantasma.diaDaSerie = 2
        fantasma.editadaEm = .now
        let escrita = Nota(texto: "quero correr de manhã", gesto: .woop)
        escrita.editadaEm = .now.addingTimeInterval(-60)
        c.mainContext.insert(fantasma)
        c.mainContext.insert(escrita)
        try c.mainContext.save()
        let s = Sessao()
        s.recordarMaisRecente(no: c.mainContext)
        #expect(s.mostrarRecordar)
        #expect(s.recordarTexto == "quero correr de manhã")
        s.mostrarRecordar = false
        s.recordarTexto = ""
        s.recordarDaNotas(fantasma)
        #expect(!s.mostrarRecordar)
        #expect(s.recordarTexto.isEmpty)
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

    @Test func seEntaoSoNosCamposEntraNaFila() throws {
        let u = UUID()
        let nota = Nota(
            texto: "",
            gesto: .seEntao,
            campos: ["se": "o celular na cama", "entao": "ponho-o na cozinha"])
        nota.uuid = u
        nota.criadaEm = Date().addingTimeInterval(-4 * 86400)
        UserDefaults.standard.removeObject(forKey: "revisaoProxima")
        var p: [String: TimeInterval] = [:]
        p[u.uuidString] = Date().addingTimeInterval(-3600).timeIntervalSince1970
        UserDefaults.standard.set(p, forKey: "revisaoProxima")
        let fila = Revisoes.filaDoDia(notas: [nota])
        #expect(nota.texto.isEmpty)
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

    /// ADR 05d: a escolha no menu vale na nota e na página aberta, e trava.
    @Test func escolherNoMenuTravaEValeNaPagina() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "reunião com o cliente", dominio: .trabalho)
        c.mainContext.insert(nota)
        try c.mainContext.save()
        let s = Sessao()
        s.abrir(nota)
        #expect(s.escolherDominio(.estudo, na: nota, no: c.mainContext))
        #expect(nota.dominio == .estudo && nota.dominioTravado)
        #expect(s.dominio == .estudo && s.dominioTravado)
        s.texto = "reunião com o cliente no slack"
        s.salvar(no: c.mainContext)
        #expect(nota.dominio == .estudo) // travada: o léxico não volta
        s.escolherDominioNaPagina(nil)
        s.salvar(no: c.mainContext)
        #expect(nota.dominio == nil && nota.dominioTravado)
    }

    @Test func toqueNoChipSoltaETrava() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "reunião com o cliente", dominio: .trabalho)
        nota.dominioTravado = false
        c.mainContext.insert(nota)
        try c.mainContext.save()
        let s = Sessao()
        #expect(s.soltarDominio(nota, no: c.mainContext))
        #expect(nota.dominio == nil)
        #expect(nota.dominioTravado)
        s.abrir(nota)
        s.texto = "reunião com o cliente no slack"
        s.salvar(no: c.mainContext)
        #expect(nota.dominio == nil)
        #expect(nota.dominioTravado)
    }

    @Test func chipNaoMenteSeODiscoRecusa() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "reunião com o cliente", dominio: .trabalho)
        nota.dominioTravado = false
        c.mainContext.insert(nota)
        try c.mainContext.save()
        let uuid = nota.uuid
        let s = Sessao()
        s.persistirNoDisco = { _ in throw DiscoImportRecusou.gravar }
        #expect(!s.soltarDominio(nota, no: c.mainContext))
        #expect(s.toast != nil)
        let viva = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(viva.uuid == uuid)
        #expect(viva.dominio == .trabalho)
        #expect(!viva.dominioTravado)
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

    @Test func paginaVaziaNaoAbreSerie() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .expressiva
        s.trancarESair(no: c.mainContext, destino: .pagina)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        s.fechoUUID = nota.uuid
        s.guardarSentidoDoFecho("", no: c.mainContext)
        #expect(nota.serieUUID == nil)
        #expect(nota.diaDaSerie == 0)
    }
}

@MainActor
struct PromessaVerdadeTests {
    @Test func contextoUsaADataDoDisco() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "quero correr de manhã"
        s.gesto = .woop
        s.salvar(no: c.mainContext)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        let criada = nota.criadaEm
        let fatia = try #require(s.fatiaComoContexto(no: c.mainContext))
        #expect(fatia.id == nota.uuid)
        #expect(abs(fatia.criadaEm.timeIntervalSince(criada)) < 0.01)
        #expect(fatia.texto.contains("quero correr"))
        #expect(!fatia.nuncaSai)
    }

    @Test func recordarSoltoNaoMostraProxima() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let a = Nota(texto: "primeira", gesto: .woop)
        let b = Nota(texto: "segunda", gesto: .woop)
        c.mainContext.insert(a)
        c.mainContext.insert(b)
        try c.mainContext.save()
        let s = Sessao()
        s.filaUUIDs = [a.uuid, b.uuid]
        s.filaAtiva = false
        s.recordarDaNotas(a)
        #expect(!s.temProximaFila)
        #expect(s.filaUUIDs.isEmpty)
    }

    @Test func seSemHoraCancelaOAviso() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "quando o telefone vibrar"
        s.gesto = .seEntao
        s.campos = ["se": "de manhã", "entao": "deixo na cozinha"]
        s.salvar(no: c.mainContext)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.gatilhoEm != nil)
        s.campos["se"] = "quando o telefone vibrar"
        s.salvar(no: c.mainContext)
        #expect(nota.gatilhoEm == nil)
    }

    @Test func reabrirNotaComFormaTrazOsCampos() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(
            texto: "",
            gesto: .seEntao,
            campos: ["se": "quando o telefone vibrar", "entao": "fecho o app"]
        )
        c.mainContext.insert(nota)
        try c.mainContext.save()
        let s = Sessao()
        #expect(!s.temCamposDaForma)
        s.abrir(nota)
        #expect(s.paginaVazia)
        #expect(s.temCamposDaForma)
        #expect(s.gesto == .seEntao)
        #expect(s.campos["entao"] == "fecho o app")
        s.gesto = .expressiva
        #expect(!s.temCamposDaForma)
    }

    @Test func vozSoNosCamposPodeRecordar() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .seEntao
        s.campos = ["se": "quando o telefone vibrar", "entao": "fecho o app"]
        #expect(s.paginaVazia)
        #expect(s.temVoz)
        #expect(s.podeRecordar)
        s.irRecordar(no: c.mainContext)
        #expect(s.mostrarRecordar)
        #expect(s.recordarCampos["entao"] == "fecho o app")
        s.mostrarRecordar = false
        s.campos["entao"] = ""
        #expect(s.temVoz)
        #expect(!s.podeRecordar)
        s.irRecordar(no: c.mainContext)
        #expect(!s.mostrarRecordar)
        #expect(s.toast?.contains("recordar") == true)
    }

    @Test func paginaVaziaSemAlvoNaoPodeRecordar() {
        let s = Sessao()
        #expect(s.paginaVazia)
        #expect(!s.temVoz)
        #expect(!s.podeRecordar)
    }

    @Test func vozSoNosCamposGravaEConclui() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .seEntao
        s.campos = ["se": "quando o telefone vibrar", "entao": "fecho o app"]
        #expect(s.paginaVazia)
        #expect(s.temVoz)
        s.concluir(no: c.mainContext)
        let notas = try c.mainContext.fetch(FetchDescriptor<Nota>())
        #expect(notas.count == 1)
        #expect(notas[0].campos["se"] == "quando o telefone vibrar")
        #expect(notas[0].campos["entao"] == "fecho o app")
        #expect(notas[0].temVoz)
        #expect(s.paginaVazia)
        #expect(s.toast?.contains("guardada") == true)
    }

    @Test func paginaSemVozNaoGravaNemMente() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .seEntao
        s.campos = ["se": "", "entao": ""]
        #expect(!s.temVoz)
        s.concluir(no: c.mainContext)
        #expect(try c.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
        #expect(s.toast == nil)
    }

    @Test func fechoEDaNotaDestaPagina() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let velha = Nota(
            texto: "dor antiga e o peito pesado o dia inteiro",
            gesto: .expressiva,
            trancada: true
        )
        velha.editadaEm = Date().addingTimeInterval(60)
        c.mainContext.insert(velha)
        try c.mainContext.save()
        let s = Sessao()
        s.texto = "hoje senti o peito pesado e chorei sem saber o nome"
        s.gesto = .expressiva
        s.abrirFecho(no: c.mainContext)
        let nova = try #require(s.fechoUUID)
        #expect(nova != velha.uuid)
        #expect(s.fechoExpressiva != nil)
    }
}

struct GestoNovosNomesTests {
    @Test func destilarEPalavraRoundtrip() {
        #expect(Gesto.doNome("Destilar") == .destilar)
        #expect(Gesto.doNome("Palavra") == .palavra)
        #expect(Gesto.doNome("destilar") == .destilar)
    }

    /// SPEC §20: Palavra é os três campos. Definir / Look Up na casa é chrome.
    @Test func palavraSaoTresCamposSemDefinir() throws {
        #expect(Gesto.palavra.campos.map(\.id) == ["minhas", "frase", "onde"])
        #expect(!Gesto.palavra.campos.contains {
            $0.rotulo.localizedCaseInsensitiveContains("Definir")
        })
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let campos = try String(
            contentsOf: raiz.appending(path: "Traco/Pagina/CamposFormaView.swift"),
            encoding: .utf8)
        #expect(!campos.contains("Definir"))
        #expect(!campos.contains("DicionarioNativo"))
        #expect(!campos.contains("termoDicionario"))
        #expect(!FileManager.default.fileExists(
            atPath: raiz.appending(path: "Traco/Pagina/DicionarioNativo.swift").path))
    }

    /// SPEC §11 + ADR o: a barra da casa é Analisar · Recordar · Anexar · Lente.
    /// "Vestir tudo" existe, mas no menu de formas — nunca como botão da barra.
    @Test func casaNaoTemVestir() throws {
        let pagina = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(path: "Traco/Pagina/PaginaView.swift"),
            encoding: .utf8)
        #expect(!pagina.contains("Button(\"Vestir"))
        #expect(!pagina.contains("vestir-nota"))
        #expect(!pagina.contains("vestirNota"))
        #expect(pagina.contains("Analisar"))
        #expect(pagina.contains("Recordar"))
        #expect(pagina.contains("Anexar"))
    }
}

struct DiscoTracoTests {
    @Test func discoQuebraNaoFingeCadernoVazio() throws {
        DiscoTraco.aviso = nil
        struct Boom: Error {}
        _ = try DiscoTraco.abrir(
            emTeste: false,
            disco: { throw Boom() },
            memoria: { try ModelContainer.traco(emMemoria: true) }
        )
        #expect(DiscoTraco.aviso?.contains("não inventa") == true)
        DiscoTraco.aviso = nil
    }

    @Test func discoSaudavelNaoAvisa() throws {
        DiscoTraco.aviso = "sujo"
        _ = try DiscoTraco.abrir(
            emTeste: false,
            disco: { try ModelContainer.traco(emMemoria: true) },
            memoria: { throw DiscoTesteErro.falhou }
        )
        #expect(DiscoTraco.aviso == nil)
    }
}

private enum DiscoTesteErro: Error { case falhou }

@MainActor
struct MigracaoDiscoTests {
    @Test func v1NoDiscoChegaVivaNaV2() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("traco-mig-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("traco.store")
        let id = UUID()
        let criada = Date(timeIntervalSince1970: 1_700_000_000)

        try autoreleasepool {
            let v1 = try ModelContainer(
                for: Schema(versionedSchema: TracoSchemaV1.self),
                configurations: ModelConfiguration(url: url)
            )
            let n = TracoSchemaV1.Nota(
                texto: "quero correr de manhã",
                gestoRaw: "woop",
                criadaEm: criada,
                editadaEm: criada
            )
            n.uuid = id
            v1.mainContext.insert(n)
            try v1.mainContext.save()
        }

        let v2 = try ModelContainer.traco(url: url)
        let notas = try v2.mainContext.fetch(FetchDescriptor<Nota>())
        #expect(notas.count == 1)
        #expect(notas[0].uuid == id)
        #expect(notas[0].texto == "quero correr de manhã")
        #expect(notas[0].gesto == .woop)
        #expect(notas[0].dominio == nil)
        #expect(notas[0].gatilhoEm == nil)
    }
}
