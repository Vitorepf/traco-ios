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
                #expect(leitura.contemProtegida)
                #expect(leitura.itens.count == 1)
                #expect(try #require(leitura.itens.first).texto == "nota aberta")
            }
        }
        #expect(!Corpus.importarComEstado(aberta).contemProtegida)
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
}
