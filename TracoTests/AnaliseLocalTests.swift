import Testing
@testable import Traco

struct AnaliseLocalTests {
    @Test func paginaVaziaESilencio() {
        #expect(AnaliseLocal.classificar(texto: "   ", gestoAtual: nil, campos: [:]) == .silencio)
    }

    @Test func woopPeloDesejo() {
        let v = AnaliseLocal.classificar(texto: "quero correr de manhã", gestoAtual: nil, campos: [:])
        #expect(v == .gesto(.woop, pergunta: AnaliseLocal.perguntaWOOP))
    }

    @Test func woodNaoAbreForma() {
        let v = AnaliseLocal.classificar(texto: "eu sou um vencedor", gestoAtual: nil, campos: [:])
        #expect(v == .aviso(AnaliseLocal.avisoWood))
    }

    @Test func banalESilencio() {
        let v = AnaliseLocal.classificar(texto: "leite", gestoAtual: nil, campos: [:])
        #expect(v == .silencio)
    }

    @Test func oettingenAvisoPlanoSemObstaculo() {
        let v = AnaliseLocal.classificar(texto: "meu plano é acordar e vai dar certo", gestoAtual: nil, campos: [:])
        #expect(v == .aviso(AnaliseLocal.avisoOettingen))
    }

    @Test func oettingenNaoRoubaWOOP() {
        let v = AnaliseLocal.classificar(texto: "quero correr e vai dar certo", gestoAtual: nil, campos: [:])
        guard case .gesto(.woop, _) = v else {
            Issue.record("WOOP deveria vencer o plano")
            return
        }
    }

    @Test func fraseProntaAviso() {
        let v = AnaliseLocal.classificar(texto: "escreve pra mim um parágrafo", gestoAtual: nil, campos: [:])
        #expect(v == .aviso(AnaliseLocal.avisoFrasePronta))
    }

    @Test func ouvinteAviso() {
        let v = AnaliseLocal.classificar(texto: "preciso falar com alguém", gestoAtual: nil, campos: [:])
        #expect(v == .aviso(AnaliseLocal.avisoOuvinte))
    }

    @Test func desabafoLongoEExpressiva() {
        let v = AnaliseLocal.classificar(
            texto: "hoje senti um peso no peito quando acordei e o medo de nao dar conta voltou. chorei no chuveiro. estava pesado o dia inteiro e eu nao disse a ninguem.",
            gestoAtual: nil,
            campos: [:]
        )
        #expect(v == .expressiva)
    }

    @Test func mesmaFormaESilencio() {
        let v = AnaliseLocal.classificar(
            texto: "quero correr",
            gestoAtual: .woop,
            campos: ["obstaculo": "o celular na cama"]
        )
        #expect(v == .silencio)
    }

    @Test func cercaNaoAbreWOOP() {
        let md = """
        leite
        ```swift
        func quero() {}
        ```
        """
        #expect(AnaliseLocal.classificar(texto: md, gestoAtual: nil, campos: [:]) == .silencio)
    }

    @Test func doisGestosAvisom() {
        let v = AnaliseLocal.classificar(
            texto: "quero correr",
            gestoAtual: .woop,
            campos: ["obstaculo": "sempre que pego o telefone"]
        )
        #expect(v == .aviso(AnaliseLocal.avisoDoisGestos))
    }
}

struct PadroesLocalTests {
    @Test func vazioNaoInventa() {
        #expect(PadroesLocal.perguntas(vozes: []).isEmpty)
    }

    @Test func citaFragmentoLiteral() {
        let qs = PadroesLocal.perguntas(
            vozes: ["quero acordar cedo para treinar", "o celular na cama ganhou de novo"],
            obstaculos: ["o celular na cama"]
        )
        #expect(!qs.isEmpty)
        #expect(qs.count <= 3)
        #expect(qs.contains { $0.contains("celular na cama") })
    }

    @Test func nuncaDiagnostica() {
        let qs = PadroesLocal.perguntas(vozes: ["percebi que a pressa come o dia"])
        #expect(qs.allSatisfy { !$0.lowercased().contains("você sempre") })
        #expect(qs.allSatisfy { !$0.lowercased().contains("você falha") })
    }
}

struct VozDoAutorTests {
    @Test func labelsNaoEntramNaVoz() {
        let voz = VozDoAutor.juntar(texto: "quero correr", campos: ["obstaculo": "o celular", "resultado": ""])
        #expect(voz.contains("quero correr"))
        #expect(voz.contains("o celular"))
        #expect(!voz.contains("Resultado"))
    }

    @Test func truncaEmPalavra() {
        let t = VozDoAutor.truncar("o celular na cama ganhou de novo hoje", 18)
        #expect(t.hasSuffix("…"))
        #expect(!t.contains("ganhou"))
    }

    @Test func tituloNaoMostraFonte() {
        #expect(VozDoAutor.titulo("# capa") == "capa")
        #expect(!VozDoAutor.titulo("# capa").contains("#"))
        #expect(VozDoAutor.titulo("> a noite") == "a noite")
        #expect(!VozDoAutor.titulo("> a noite").contains(">"))
        #expect(VozDoAutor.titulo("```swift\nfunc senti\n```") == "func senti")
        #expect(!VozDoAutor.titulo("```swift\nfunc senti\n```").contains("`"))
        #expect(VozDoAutor.titulo(":::ideia\nainda\n:::") == "ainda")
        #expect(!VozDoAutor.titulo(":::ideia\nainda\n:::").contains(":::"))
        let uuid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
        #expect(!VozDoAutor.titulo("![](traco://img/\(uuid))").contains("traco://"))
        #expect(!Caderno.temMarca(VozDoAutor.titulo("```swift\nfunc senti\n```")))
    }
}
