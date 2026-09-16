import Foundation
import Testing
@testable import Traco

@MainActor
@Suite(.serialized)
struct IntegridadeCorpusTests {
    @Test func notaSoDeCamposRestauraSemInventarTexto() throws {
        let campos = ["se": "quando chegar\n\nem casa", "entao": "  guardo o celular  "]
        let md = Corpus.arquivoMd(texto: "", gesto: .seEntao, campos: campos,
                                  criadaEm: Date(timeIntervalSince1970: 0))
        let item = try #require(Corpus.importar(md).first)
        let restaurada = Corpus.separarCampos(texto: item.texto, gesto: item.gestoNome.flatMap(Gesto.doNome))
        #expect(restaurada.texto.isEmpty)
        #expect(restaurada.campos == campos)
    }

    @Test func notaLegadaSoDeCamposRestauraSemInventarTexto() {
        let legado = "— WOOP —\nresultado: energia\nobstaculo: celular"
        let restaurada = Corpus.separarCampos(texto: legado, gesto: .woop)
        #expect(restaurada.texto.isEmpty)
        #expect(restaurada.campos == ["resultado": "energia", "obstaculo": "celular"])
    }

    @Test func camposRestauramParagrafosEspacosETextoQuePareceEstrutura() throws {
        let campos = [
            "resultado": "  primeiro\n\nsegundo\n  ",
            "obstaculo": "resultado: isto pertence ao obstáculo\n---\ncriada: 1970-01-01T00:00:00Z\n---\nestado: selada",
            "plano": "\taspas: \"sim\" e barra \\ e emoji 🌱\r\nfim",
        ]
        let md = Corpus.arquivoMd(texto: "minha intenção", gesto: .woop,
                                  campos: campos, criadaEm: Date(timeIntervalSince1970: 0))
        let itens = Corpus.importar(md)
        #expect(itens.count == 1)
        let item = try #require(itens.first)
        let restaurada = Corpus.separarCampos(texto: item.texto, gesto: .woop)
        #expect(restaurada.texto == "minha intenção")
        #expect(restaurada.campos == campos)
    }

    @Test func valoresVaziosEChavesDesconhecidasNaoSomemNoBackup() throws {
        let campos = ["resultado": "", "obstaculo": " \n\t", "campo-antigo": "resposta preservada"]
        let md = Corpus.arquivoMd(texto: "intenção", gesto: .woop,
                                  campos: campos, criadaEm: Date(timeIntervalSince1970: 0))
        let item = try #require(Corpus.importar(md).first)
        #expect(Corpus.separarCampos(texto: item.texto, gesto: .woop).campos == campos)
    }

    @Test func importacaoLegadaContinuaAceitandoIdsERotulos() throws {
        let rotulo = try #require(Gesto.woop.campos.first(where: { $0.id == "obstaculo" })?.rotulo)
        for identificador in ["obstaculo", rotulo] {
            let legado = "minha intenção\n\n— WOOP —\n\(identificador): celular na cama"
            let restaurada = Corpus.separarCampos(texto: legado, gesto: .woop)
            #expect(restaurada.texto == "minha intenção")
            #expect(restaurada.campos["obstaculo"] == "celular na cama")
        }
    }

    @Test func discursoSobreEstadoNaoESelo() throws {
        let autoria = "A documentação usa estado: selada como exemplo."
        let md = Corpus.arquivoMd(texto: autoria, gesto: nil, campos: [:],
                                  criadaEm: Date(timeIntervalSince1970: 0))
        #expect(try #require(Corpus.importar(md).first).texto == autoria)
    }

    @Test func campoNovoDanificadoNaoDescartaAsPalavrasOriginais() {
        let autoria = "intenção\n\n— WOOP —\n<!-- traco-campos:json-v1 -->\nresultado: \"válido\"\nobstaculo: \"incompleto"
        let restaurada = Corpus.separarCampos(texto: autoria, gesto: .woop)
        #expect(restaurada.texto == autoria)
        #expect(restaurada.campos.isEmpty)
    }

    @Test func cabecalhoSeladoContinuaRecusadoMesmoComCorpo() {
        let selada = "---\ncriada: 1970-01-01T00:00:00Z\ngesto: WOOP\nestado: selada\n---\n\ncorpo privado"
        #expect(Corpus.importar(selada).isEmpty)
    }

    @Test func arquivoMistoInformaConteudoProtegidoMesmoImportandoAberta() throws {
        let aberta = Corpus.arquivoMd(texto: "nota aberta", gesto: nil, campos: [:],
                                      criadaEm: Date(timeIntervalSince1970: 0))
        for estado in ["selada", "queimada"] {
            let protegida = "---\ncriada: 1970-01-01T00:00:01Z\nestado: \(estado)\n---\n"
            for corpus in [aberta + "\n" + protegida, protegida + "\n" + aberta] {
                let leitura = Corpus.importarComEstado(corpus)
                #expect(!leitura.podeRetirar)
                #expect(leitura.itens.count == 1)
                #expect(try #require(leitura.itens.first).texto == "nota aberta")
            }
        }
        #expect(Corpus.importarComEstado(aberta).podeRetirar)
    }

    // MARK: - ADR 09y: um arquivo só se apaga quando o app leu tudo o que havia nele

    /// A tabela do P0-CRLF, medida antes em harness com as linhas verbatim do
    /// `Corpus`: os quatro casos do revisor (A–D), a prosa antes do primeiro
    /// cabeçalho (E — que não precisa de `\r` nenhum), o arquivo misto (F) e a
    /// nota aberta inteira em CRLF (G). Em `main`, SEIS dos sete apagavam o
    /// arquivo do autor e três importavam o corpo de uma nota selada como voz
    /// dele; o sétimo é o A, que sempre funcionou e aqui é a guarda contra
    /// regressão do caminho que já estava certo.
    @Test func arquivoSoSaiDaEntradaQuandoOAppLeuTudo() {
        let selada = "---\ncriada: 2026-09-09T10:00:00Z\norigem: modelo\nestado: selada\n---\n\na dor que ninguém lê\n"
        let aberta = "---\ncriada: 2026-09-09T10:00:00Z\n---\n\ncorpo aberto\n"
        func crlf(_ s: String) -> String { s.replacingOccurrences(of: "\n", with: "\r\n") }
        let casos: [(String, String)] = [
            ("A) LF puro, selada", selada),
            ("B) tudo CRLF, selada", crlf(selada)),
            ("C) \\r só na linha do estado",
             selada.replacingOccurrences(of: "estado: selada\n", with: "estado: selada\r\n")),
            ("D) \\r só na linha da origem",
             selada.replacingOccurrences(of: "origem: modelo\n", with: "origem: modelo\r\n")),
            ("E) prosa do autor antes do 1º cabeçalho, sem um \\r",
             "# minhas notas de hoje\n\numa linha que só existe aqui\n\n" + aberta),
            ("F) misto: nota sã + \\r antes do ---",
             aberta + "\n---\ncriada: 2026-09-09T11:00:00Z\r\nestado: selada\n---\n\noutra dor\n"),
            ("G) nota aberta inteira em CRLF", crlf(aberta)),
        ]
        for (nome, md) in casos {
            let r = Corpus.importarComEstado(md)
            #expect(!r.podeRetirar, "\(nome): o arquivo do autor seria APAGADO")
            #expect(r.consumido < 1, "\(nome): cobertura \(r.consumido) afirma ter lido tudo")
            #expect(!r.itens.contains { $0.texto.contains("dor") },
                    "\(nome): o corpo de uma nota SELADA entrou como nota")
        }
    }

    /// A irmã que NÃO acusa: o que o parser leu inteiro continua entrando e
    /// continua podendo sair da `entrada/`. Sem ela, `podeRetirar = false` fixo
    /// passaria no teste de cima e ninguém veria a pasta parar de esvaziar.
    @Test func oQueOAppLeuInteiroContinuaPodendoSairDaEntrada() throws {
        let solta = "só uma ideia solta, sem cabeçalho nenhum"
        let r = Corpus.importarComEstado(solta)
        #expect(r.consumido == 1)
        #expect(r.podeRetirar)
        #expect(try #require(r.itens.first).texto == solta)

        let exportada = Corpus.arquivoMd(texto: "três temas voltam", gesto: .woop,
                                         campos: ["resultado": "energia"],
                                         criadaEm: Date(timeIntervalSince1970: 0))
        let volta = Corpus.importarComEstado(exportada)
        #expect(volta.consumido == 1)
        #expect(volta.podeRetirar)
        #expect(volta.itens.count == 1)
    }

    @Test func bookmarkInvalidoLimpaConfiguracaoSemExecutarAcesso() throws {
        let anterior = PastaEspelho.defaults
        let nomeSuite = "integridade-espelho-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: nomeSuite))
        PastaEspelho.defaults = defaults
        defer {
            PastaEspelho.defaults = anterior
            defaults.removePersistentDomain(forName: nomeSuite)
        }
        defaults.set(Data("não é um bookmark".utf8), forKey: PastaEspelho.chave)
        defaults.set("pasta inacessível", forKey: PastaEspelho.chaveNome)
        var acessou = false
        PastaEspelho.comAcesso { _ in acessou = true }
        #expect(!acessou)
        #expect(defaults.data(forKey: PastaEspelho.chave) == nil)
        #expect(PastaEspelho.nome == nil)
        PastaEspelho.limpar()
        #expect(defaults.string(forKey: PastaEspelho.chaveNome) == nil)
    }

    // MARK: - ADR 2026-09-08u: quem escreveu

    @Test func origemDoCabecalhoAtravessaOImport() throws {
        for (linha, esperada) in [("origem: grokbot", OrigemNota.grokbot),
                                  ("origem: pesquisa", .pesquisa),
                                  ("origem: obra", .obra),
                                  ("", .autor),
                                  // ADR 2026-09-16a: quem declarou origem declarou que
                                  // não foi o autor — a que esta versão não conhece é obra
                                  ("origem: assistente", .obraSuposta)] {
            let md = "---\ncriada: 1970-01-01T00:00:00Z\ngesto: WOOP\n"
                + (linha.isEmpty ? "" : linha + "\n") + "---\n\ntrês temas voltam\n"
            let item = try #require(Corpus.importar(md).first)
            #expect(item.origem == esperada, "linha “\(linha)”")
        }
    }

    @Test func origemSobreviveAoRoundtripPelaPasta() throws {
        var f = FatiaCorpus(id: UUID(), texto: "o que se repete", gesto: nil, campos: [:],
                            criadaEm: Date(timeIntervalSince1970: 0), editadaEm: Date(timeIntervalSince1970: 0),
                            recordada: 0, sentido: "", minutos: 0, trancada: false, queimada: false,
                            expressivaEmCurso: false, dominio: nil, serie: nil, dia: 0)
        f.origem = .grokbot
        let md = Corpus.arquivoMd(f)
        #expect(md.contains("origem: grokbot"))
        #expect(try #require(Corpus.importar(md).first).origem == .grokbot)
        // e a nota do autor não ganha uma linha que não existia
        f.origem = .autor
        #expect(!Corpus.arquivoMd(f).contains("origem:"))
    }

    @Test func notaQueNaoEDoAutorFicaForaDoRetrato() {
        let campos = ["obstaculo": "deixo para depois"]
        let doAutor = Retrato.NotaLida(gesto: .woop, fechada: false, expressiva: false,
                                       criadaEm: .now, campos: campos, vozDoAutor: true)
        let doBot = Retrato.NotaLida(gesto: .woop, fechada: false, expressiva: false,
                                     criadaEm: .now, campos: ["obstaculo": "o bot achou isto"],
                                     vozDoAutor: false)
        let texto = Retrato.ler(notas: [doAutor, doBot], sinais: [])
        #expect(texto.contains("deixo para depois"))
        #expect(!texto.contains("o bot achou isto"))
        // nem como CONTAGEM: uma forma só, não duas
        #expect(texto.contains("1 WOOP"))
        #expect(Retrato.ler(notas: [doBot], sinais: []).isEmpty)
    }

    @Test func agendaSaiNaPastaComOQueVenceESemOQueOSeloFecha() throws {
        let raiz = FileManager.default.temporaryDirectory
            .appendingPathComponent("agenda-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: raiz) }

        let agora = Date(timeIntervalSince1970: 1_760_000_000)
        let velha = agora.addingTimeInterval(-40 * 86_400)
        func fatia(_ texto: String, gesto: Gesto?, campos: [String: String] = [:],
                   trancada: Bool = false, emCurso: Bool = false, recordar: Date? = nil) -> FatiaCorpus {
            FatiaCorpus(id: UUID(), texto: texto, gesto: gesto, campos: campos, criadaEm: velha,
                        editadaEm: velha, recordada: 0, sentido: "", minutos: 3, trancada: trancada,
                        queimada: false, expressivaEmCurso: emCurso, dominio: nil, serie: nil, dia: 0,
                        origem: .autor, recordarEm: recordar)
        }
        let devida = fatia("abrir a segunda clínica", gesto: .decisao,
                           campos: ["escolha": "abrir a segunda clínica", "espero": "dois pacientes a mais"])
        let respondida = fatia("trocar o contador", gesto: .decisao,
                               campos: ["escolha": "trocar o contador", "espero": "menos retrabalho",
                                        "aconteceu": "veio igual", "saldo": "igual"])
        let cobrada = fatia("quero correr todo dia", gesto: .woop,
                            campos: ["resultado": "acordar leve", "obstaculo": "durmo tarde", "plano": "deito às 23h"],
                            recordar: agora.addingTimeInterval(-86_400))
        let selada = fatia("a dor", gesto: .expressiva, trancada: true, recordar: agora.addingTimeInterval(-86_400))
        let emCurso = fatia("a dor de agora", gesto: .expressiva, emCurso: true)

        let evento = EventoCalendario(titulo: "reunião com o contador",
                                      inicio: agora.addingTimeInterval(86_400),
                                      fim: agora.addingTimeInterval(90_000))
        let passado = EventoCalendario(titulo: "o que já foi", inicio: velha, fim: velha)
        let texto = Corpus.agenda([devida, respondida, cobrada, selada, emCurso].filter { !$0.nuncaSai },
                                  eventos: [evento, passado], agora: agora)

        #expect(texto.contains("reunião com o contador"))
        #expect(!texto.contains("o que já foi"))
        #expect(texto.contains("abrir a segunda clínica"))
        #expect(!texto.contains("trocar o contador"), "decisão já respondida não é cobrança")
        #expect(texto.contains("quero correr todo dia"))
        // o selo continua valendo na agenda: nem o corpo da selada, nem a em curso
        #expect(!texto.contains("a dor"))

        // e o arquivo aparece de verdade ao lado dos três de hoje
        Corpus.escrever(fatias: [devida, cobrada], em: raiz)
        let noDisco = try String(contentsOf: raiz.appendingPathComponent("agenda.md"), encoding: .utf8)
        #expect(noDisco.hasPrefix("# Agenda do Traço"))
        #expect(FileManager.default.fileExists(atPath: raiz.appendingPathComponent("INDICE.md").path))
    }

    @Test func expressivaESeladaContinuamForaDaPastaDepoisDaOrigem() throws {
        let raiz = FileManager.default.temporaryDirectory
            .appendingPathComponent("selo-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: raiz) }
        let quando = Date(timeIntervalSince1970: 0)
        func f(trancada: Bool, emCurso: Bool) -> FatiaCorpus {
            FatiaCorpus(id: UUID(), texto: "o texto da dor", gesto: .expressiva, campos: [:],
                        criadaEm: quando, editadaEm: quando, recordada: 0, sentido: "o medo era outro",
                        minutos: 15, trancada: trancada, queimada: false, expressivaEmCurso: emCurso,
                        dominio: nil, serie: nil, dia: 0)
        }
        Corpus.escrever(fatias: [f(trancada: true, emCurso: false), f(trancada: false, emCurso: true)], em: raiz)
        for nome in ["traco-corpus.md", "agenda.md", "INDICE.md"] {
            let conteudo = (try? String(contentsOf: raiz.appendingPathComponent(nome), encoding: .utf8)) ?? ""
            #expect(!conteudo.contains("o texto da dor"), "\(nome) deixou o corpo da expressiva sair")
        }
        let notas = (try? FileManager.default.contentsOfDirectory(
            atPath: raiz.appendingPathComponent("notas").path)) ?? []
        #expect(notas.count == 1, "a em curso não vira arquivo")
        let selada = try String(contentsOf: raiz.appendingPathComponent("notas/\(notas[0])"), encoding: .utf8)
        #expect(selada.contains("estado: selada") && !selada.contains("o texto da dor"))
    }
}
