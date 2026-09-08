import Testing

// ADR 04r: o aviso é do algoritmo, sempre. O contrato remoto só roteia; um
// `aviso` que ainda chegue de um modelo velho é ignorado — e no `escolher`
// da sessão, o aviso local vence qualquer gesto remoto.
@Suite struct AvisoEDoAlgoritmoTests {
    @Test func avisoRemotoEIgnorado() {
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":null,"aviso":"textoPronto"}"#) == .silencio)
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"woop","aviso":"textoPronto"}"#)
                == .gesto(.woop, pergunta: AnaliseLocal.pergunta(.woop)))
    }

    @Test func avisoLocalVenceGestoRemoto() {
        let aviso = AnaliseLocal.Veredito.aviso(AnaliseLocal.avisoWood)
        #expect(Sessao.escolher(remoto: .gesto(.woop, pergunta: "p"), local: aviso) == aviso)
        #expect(Sessao.escolher(remoto: .gesto(.woop, pergunta: "p"), local: .silencio) == .gesto(.woop, pergunta: "p"))
    }
}
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

    @Test func pedidoDiretoDeTextoContinuaAvisandoNestaSuperficie() {
        for texto in ["escreve pra mim um parágrafo", "Escreva para mim uma frase.",
                      "Resuma este texto.", "reescreva minha frase", "Por favor, resuma o texto.",
                      "Melhore meu rascunho.", "melhore a redação"] {
            #expect(AnaliseLocal.classificar(texto: texto, gestoAtual: nil, campos: [:])
                    == .aviso(AnaliseLocal.avisoFrasePronta), "\(texto)")
        }
        #expect(AnaliseLocal.avisoFrasePronta.contains("Nesta página"))
        #expect(AnaliseLocal.avisoFrasePronta.contains("Trabalho"))
    }

    @Test func relatoCitacaoObjetivoENegacaoNaoSaoPedidosDeTextoAIA() {
        let casos = [
            "Quero que João resuma a reunião amanhã.",
            "Minha professora pediu que eu reescreva a conclusão.",
            "Melhorei minha rotina de revisão.",
            "Quero que o serviço melhore sem aumentar o preço.",
            "Não resuma minhas anotações.",
            "Não reescreva esta frase.",
            "Ela disse: escreva para mim uma carta.",
            "A mensagem foi:\n\nResuma o projeto para mim.",
            "“Resuma o artigo” foi o exercício de ontem.",
            "> Resuma este texto.",
            "# Reescreva o futuro",
            "- Resuma a reunião para João.",
            "```txt\nresuma o artigo\n```\nMaterial da aula.",
            "Melhore sua alimentação.",
        ]
        for texto in casos {
            #expect(AnaliseLocal.classificar(texto: texto, gestoAtual: nil, campos: [:])
                    != .aviso(AnaliseLocal.avisoFrasePronta), "\(texto)")
        }
        let v = AnaliseLocal.classificar(texto: "quero estudar", gestoAtual: .woop,
                                         campos: ["plano": "Resuma o capítulo antes da aula."])
        #expect(v != .aviso(AnaliseLocal.avisoFrasePronta))
    }

    @Test func corrigirFalsoAvisoNaoLiberaReescritaDeExpressivaNemFormaSobreDesabafo() {
        #expect(AnaliseLocal.classificar(texto: "reescreva minha frase", gestoAtual: .expressiva, campos: [:]) == .silencio)
        let pessoal = "Chorei quando ela pediu que eu reescreva a carta. Estou triste e me culpo pelo que aconteceu."
        let local = AnaliseLocal.classificar(texto: pessoal, gestoAtual: nil, campos: [:])
        #expect(local != .aviso(AnaliseLocal.avisoFrasePronta))
        #expect(AnaliseLocal.escritaPessoal(texto: pessoal, campos: [:]))
        #expect(Sessao.escolher(remoto: .gesto(.woop, pergunta: "p"), local: local, pessoal: true) == local)
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

/// ADR 06f: o aviso interrompe o autor com forma, informação e pergunta —
/// nunca com uma sentença sobre o mundo que a fonte não sustenta.
@Suite("O aviso não alega eficácia")
struct AvisoSemAlegacaoTests {
    /// A frase de 2009 ("Afirmação sem prova NÃO GRUDA") é o caso que motivou a
    /// regra: o estudo mede humor, não fixação.
    static let proibidas = [
        "não gruda", "nao gruda", "gruda", "comprovad", "cientificamente",
        "estudos mostram", "está provado", "esta provado", "prova que",
        "funciona", "não funciona", "garante", "eficaz", "eficácia",
        "está errado", "esta errado", "não adianta", "nao adianta",
    ]

    @Test func nenhumAvisoAlegaEficacia() {
        for frase in Set(AnaliseLocal.avisos.values).union([AnaliseLocal.perguntaWOOP]) {
            let lower = frase.lowercased()
            for palavra in Self.proibidas {
                #expect(!lower.contains(palavra), "\(frase) — contém \"\(palavra)\"")
            }
        }
    }

    @Test func oAvisoDaAfirmacaoDizOQueOEstudoMediu() {
        let a = AnaliseLocal.avisoWood
        #expect(a.contains("2009"))
        #expect(a.contains("autoestima"))
        // a pergunta é a melhor parte do aviso, e ela fica
        #expect(a.hasSuffix("O que aconteceu que fez você escrever isso?"))
    }

    @Test func oAvisoTemProveniencia() throws {
        let p = try #require(AnaliseLocal.proveniencia(doAviso: AnaliseLocal.avisoWood))
        #expect(p.fonte.contains("Wood") && p.fonte.contains("2009"))
        #expect(p.funcao == .evidencia)
        #expect(p.evidencia.contains("humor"))
        // o limite do estudo é dito junto com o achado
        #expect(p.evidencia.contains("não diz nada sobre você"))
        #expect(p.linhas.map(\.rotulo) == ["FONTE", "FUNÇÃO", "EVIDÊNCIA"])
    }

    @Test func oAvisoDoPlanoUsaAProvenienciaDoCatalogo() {
        #expect(AnaliseLocal.proveniencia(doAviso: AnaliseLocal.avisoOettingen)
                == Catalogo.metodo("woop")?.proveniencia)
    }

    @Test func avisoSemFonteNaoInventaUma() {
        #expect(AnaliseLocal.proveniencia(doAviso: AnaliseLocal.avisoFrasePronta) == nil)
        #expect(AnaliseLocal.proveniencia(doAviso: AnaliseLocal.avisoDoisGestos) == nil)
        #expect(AnaliseLocal.proveniencia(doAviso: AnaliseLocal.avisoOuvinte) == nil)
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
