import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-04l: o catálogo é dado. Se o JSON do bundle quebrar, TODA nota
/// perde os campos — este é o teste que grita antes do autor.
@Suite(.serialized) struct CatalogoTests {
    @Test func oBundleTemOsVinteEUmMetodos() {
        let ids = Catalogo.doApp.map(\.id)
        #expect(ids.count == 21)
        for esperado in ["woop", "seEntao", "spec", "notaPermanente", "destaque", "expressiva", "destilar",
                         "palavra", "decisao", "premortem", "argumento", "leitura", "feynman", "dia",
                         "analogia", "inversao", "steelman", "divergencia", "primeirosPrincipios",
                         "praticaDeliberada", "atualizacao"] {
            #expect(ids.contains(esperado), "falta \(esperado)")
        }
    }

    @Test func osDezDeOrigemMantemOsCampos() {
        #expect(Gesto.woop.campos.map(\.id) == ["resultado", "obstaculo", "plano"])
        #expect(Gesto.decisao.campos.map(\.id) == ["escolha", "opcoes", "criterio", "decidido", "espero", "aconteceu", "saldo"])
        #expect(Gesto.decisao.campos.last?.soDepois == true)
        #expect(Gesto.destilar.campos.first?.teto == 200)
        #expect(Gesto.spec.nome == "Especificação")
        #expect(Gesto.expressiva.campos.isEmpty)
        #expect(Gesto.expressiva.metodo.isEmpty) // selo: a sábia não entra
    }

    @Test func todoMetodoNovoTemMovimentoEPergunta() {
        for m in Catalogo.doApp where m.id != "expressiva" {
            #expect(!m.movimento.isEmpty, Comment(rawValue: m.id))
            #expect(!m.pergunta.isEmpty, Comment(rawValue: m.id))
            #expect(!m.reconhecimento.isEmpty, Comment(rawValue: m.id))
            #expect(!m.campos.isEmpty, Comment(rawValue: m.id))
        }
    }

    @Test func idDesconhecidoNaoPerdeOGesto() {
        let g = Gesto(rawValue: "metodoQueSumiu")
        #expect(g != nil)
        #expect(g?.conhecido == false)
        #expect(g?.nome == "metodoQueSumiu")
        #expect(g?.campos.isEmpty == true)
        #expect(Gesto(rawValue: "  ") == nil)
    }

    /// ADR 05o: o método do autor sai da pasta e a nota não vira prosa — o
    /// corpus volta com o mesmo gesto e com os campos que ele respondeu.
    @MainActor @Test func oCorpusVoltaComOMetodoQueSumiuDaPasta() throws {
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent("metodos-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: pasta)
            Catalogo.pastaDoAutor = pasta.deletingLastPathComponent().appendingPathComponent("nada")
            Catalogo.recarregar()
        }
        let arquivo = pasta.appendingPathComponent("cornell.json")
        try #"{"id":"cornell","nome":"Cornell","campos":[{"id":"pistas","rotulo":"Pistas"},{"id":"resumo","rotulo":"Resumo"}]}"#
            .write(to: arquivo, atomically: true, encoding: .utf8)
        Catalogo.pastaDoAutor = pasta
        Catalogo.recarregar()
        let gesto = try #require(Gesto(rawValue: "cornell"))
        #expect(gesto.nome == "Cornell")
        let campos = ["pistas": "a atenção é finita", "resumo": "o que fica da aula"]
        let md = Corpus.arquivoMd(texto: "a aula de hoje", gesto: gesto, campos: campos,
                                  criadaEm: Date(timeIntervalSince1970: 0))

        try FileManager.default.removeItem(at: arquivo)
        Catalogo.recarregar()
        #expect(Catalogo.metodo("cornell") == nil)

        let item = try #require(Corpus.importar(md).first)
        let devolvido = try #require(item.gestoNome.flatMap(Gesto.doNome))
        #expect(devolvido == gesto)
        #expect(devolvido.conhecido == false)
        let restaurada = Corpus.separarCampos(texto: item.texto, gesto: devolvido)
        #expect(restaurada.texto == "a aula de hoje")
        #expect(restaurada.campos == campos)
    }

    /// ADR 05o: a fronteira do import. Um .md alheio com `gesto:` em prosa não
    /// planta um id — a nota entra sem gesto, como antes do catálogo.
    @Test func textoLivreNoGestoNaoViraId() throws {
        let frase = String(repeating: "uma frase inteira ", count: 25)
        let md = """
            ---
            criada: 1970-01-01T00:00:00Z
            gesto: \(frase)
            ---

            a nota de fora
            """
        let item = try #require(Corpus.importar(md).first)
        #expect(item.gestoNome == nil)
        #expect(Gesto.doNome(frase) == nil)
        #expect(Gesto.doNome("metodoQueSumiu")?.conhecido == false) // id curto ainda entra
    }

    /// ADR 05o: quando os dois vêm, o id manda — o nome é exibição e pode ter
    /// sido reaproveitado por outro método.
    @Test func oMetodoPrevaleceSobreONome() throws {
        let md = """
            ---
            criada: 1970-01-01T00:00:00Z
            gesto: WOOP
            metodo: cornellDoAutor
            ---

            a aula de hoje
            """
        let item = try #require(Corpus.importar(md).first)
        #expect(item.gestoNome == "cornellDoAutor")
        #expect(item.gestoNome.flatMap(Gesto.doNome)?.rawValue == "cornellDoAutor")
    }

    @Test func oCatalogoRoteiaOsMetodosNovos() {
        func v(_ t: String) -> AnaliseLocal.Veredito { AnaliseLocal.classificar(texto: t, gestoAtual: nil, campos: [:]) }
        #expect(v("defendo que a tese central está errada") == .gesto(Gesto(rawValue: "argumento")!, pergunta: Catalogo.metodo("argumento")!.pergunta))
        #expect(v("terminei de ler o livro sobre atenção") == .gesto(Gesto(rawValue: "leitura")!, pergunta: Catalogo.metodo("leitura")!.pergunta))
        #expect(v("preciso planejar o dia com calma") == .gesto(.dia, pergunta: Catalogo.metodo("dia")!.pergunta))
        #expect(v("quero começar a correr") == .gesto(.woop, pergunta: AnaliseLocal.perguntaWOOP)) // a ordem de origem fica
    }

    @Test func pdfAnexadoComProsaViraLeitura() {
        let texto = "as ideias do capítulo dois sobre atenção\n\n[arquivo:guia.pdf](traco://file/00000000-0000-4000-8000-000000000001)\n"
        let v = AnaliseLocal.classificar(texto: texto, gestoAtual: nil, campos: [:])
        #expect(v == .gesto(Gesto(rawValue: "leitura")!, pergunta: Catalogo.metodo("leitura")!.pergunta))
        // só o arquivo, sem uma palavra do autor, não é nota (a prosa é vazia): silêncio
        #expect(AnaliseLocal.classificar(texto: "[arquivo:guia.pdf](traco://file/00000000-0000-4000-8000-000000000001)", gestoAtual: nil, campos: [:]) == .silencio)
    }

    @Test func oEncadeamentoEDado() {
        let e = Gesto.woop.encadeamentos
        #expect(e.count == 1)
        #expect(e.first?.para == "seEntao")
        #expect(e.first?.mapa == ["se": "obstaculo", "entao": "plano"])
        #expect(Gesto.premortem.encadeamentos.contains { $0.compromisso?.dias == 14 })
    }

    /// ADR 04z: nenhum método é ilha, e todo encadeamento aponta para forma
    /// e campos que existem — dos dois lados.
    @Test func nenhumMetodoEIlhaEOMapaFecha() {
        let ilhas: Set<String> = ["notaPermanente", "destaque", "expressiva", "destilar", "palavra", "seEntao", "dia"]
        for m in Catalogo.doApp {
            if !ilhas.contains(m.id) {
                #expect(!m.encadeamentos.isEmpty, "\(m.id) é ilha")
            }
            let origem = Set(m.campos.map(\.id))
            for e in m.encadeamentos {
                #expect(Set(e.exige).isSubset(of: origem), "\(m.id): exige campo que não tem")
                if let para = e.para {
                    let destino = Catalogo.metodo(para)
                    #expect(destino != nil, "\(m.id) → \(para) não existe")
                    let campos = Set(destino?.campos.map(\.id) ?? [])
                    #expect(Set(e.mapa.keys).isSubset(of: campos), "\(m.id) → \(para): campo de destino inexistente")
                    #expect(Set(e.mapa.values).isSubset(of: origem), "\(m.id) → \(para): campo de origem inexistente")
                }
                if let c = e.compromisso {
                    #expect(origem.contains(c.campo) && c.dias > 0, "\(m.id): compromisso sem campo")
                }
            }
        }
        #expect(Catalogo.metodo("inversao")?.encadeamentos.first?.para == "premortem")
    }

    @Test func aPastaDoAutorEntraEOInvalidoEDito() throws {
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent("metodos-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: pasta); Catalogo.pastaDoAutor = pasta.deletingLastPathComponent().appendingPathComponent("nada"); Catalogo.recarregar() }
        try #"{"id":"cornell","nome":"Cornell","campos":[{"id":"pistas","rotulo":"Pistas"},{"id":"resumo","rotulo":"Resumo, nas minhas palavras"}],"roteamento":["\\bcornell\\b"]}"#
            .write(to: pasta.appendingPathComponent("cornell.json"), atomically: true, encoding: .utf8)
        try #"{"id":"woop","nome":"Roubo"}"#.write(to: pasta.appendingPathComponent("roubo.json"), atomically: true, encoding: .utf8)
        try "isto não é json".write(to: pasta.appendingPathComponent("quebrado.json"), atomically: true, encoding: .utf8)
        Catalogo.pastaDoAutor = pasta
        Catalogo.recarregar()
        #expect(Catalogo.doAutor.map(\.id) == ["cornell"])
        #expect(Gesto(rawValue: "cornell")?.campos.count == 2)
        #expect(Gesto.woop.nome == "WOOP") // o do app não é sobrescrito
        #expect(Catalogo.problemas.count == 2)
        let v = AnaliseLocal.classificar(texto: "anotar em cornell a aula de hoje", gestoAtual: nil, campos: [:])
        #expect(v == .gesto(Gesto(rawValue: "cornell")!, pergunta: ""))
    }
}
