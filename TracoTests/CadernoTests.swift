import Foundation
import Testing
@testable import Traco

struct CadernoTests {
    @Test func codigoViraPortalENaoEntraNaVoz() {
        let md = """
        quero um parser
        ```swift
        func senti() { return }
        ```
        """
        let f = Caderno.fatias(md)
        #expect(f.contains { if case .codigo(let l, let s) = $0.bloco { return l == "swift" && s.contains("func") } else { return false } })
        #expect(Caderno.prosa(de: md) == "quero um parser")
    }

    @Test func editarCodigoMantemLetrasSemCerca() {
        let md = "quero um parser\n```swift\n\n```"
        let f = Caderno.fatias(md)
        let codigo = f.first { if case .codigo = $0.bloco { true } else { false } }
        #expect(codigo != nil)
        let saida = Caderno.aplicar(
            f,
            id: codigo!.id,
            bloco: Caderno.comTexto(codigo!.bloco, "func senti")
        )
        #expect({
            if case .codigo("swift", let s) = Caderno.fatias(saida).first(where: {
                if case .codigo = $0.bloco { true } else { false }
            })?.bloco {
                s == "func senti"
            } else { false }
        }())
        #expect(!Caderno.visivel(saida).contains("```"))
        #expect(Caderno.visivel(saida).contains("func senti"))
    }

    @Test func terminalVisivelNaoTemCerca() {
        let bloco = BlocoCaderno.codigo(lingua: "bash", fonte: "echo ola")
        #expect(Caderno.textoVisivel(bloco) == "echo ola")
        #expect(!Caderno.textoVisivel(bloco).contains("```"))
        #expect(Caderno.serializar(bloco) == "```bash\necho ola\n```")
        #expect(!Caderno.visivel("```bash\necho ola\n```").contains("```"))
        #expect(Caderno.visivel("```bash\necho ola\n```").contains("echo ola"))
        #expect(Caderno.prosa(de: "```bash\necho ola\n```").isEmpty)
    }

    @Test func epigrafeVisivelNaoTemCerca() {
        let bloco = BlocoCaderno.recipiente(slug: "epigrafe", linhas: ["a noite fecha"])
        #expect(PapelForma.cromo(de: "epigrafe") == .epigrafe)
        #expect(Caderno.textoVisivel(bloco) == "a noite fecha")
        #expect(!Caderno.textoVisivel(bloco).contains(":::"))
        #expect(Caderno.serializar(bloco) == ":::epigrafe\na noite fecha\n:::")
        #expect(!Caderno.visivel(":::epigrafe\na noite fecha\n:::").contains(":::"))
        #expect(Caderno.visivel(":::epigrafe\na noite fecha\n:::").contains("a noite fecha"))
        #expect(Caderno.prosa(de: ":::epigrafe\na noite fecha\n:::") == "a noite fecha")
        let f = Caderno.fatias(":::epigrafe\na noite fecha\n:::")
        #expect(f.contains { if case .paragrafo(let t) = $0.bloco { t.isEmpty && $0.aberto } else { false } })
        #expect(Caderno.paginaUna(":::epigrafe\na noite fecha\n:::") == nil)
    }

    @Test func cenaVisivelNaoTemCerca() {
        let bloco = BlocoCaderno.recipiente(slug: "cena", linhas: ["a porta abre"])
        #expect(PapelForma.cromo(de: "cena") == .cena)
        #expect(Caderno.textoVisivel(bloco) == "a porta abre")
        #expect(!Caderno.textoVisivel(bloco).contains(":::"))
        #expect(Caderno.serializar(bloco) == ":::cena\na porta abre\n:::")
        #expect(!Caderno.visivel(":::cena\na porta abre\n:::").contains(":::"))
        #expect(Caderno.visivel(":::cena\na porta abre\n:::").contains("a porta abre"))
        #expect(PapelForma.catalogo.contains { $0.slug == "cena" }) // fora da régua, vivo no arquivo
    }

    @Test func formulaVisivelNaoTemCerca() {
        let bloco = BlocoCaderno.codigo(lingua: "tex", fonte: "a + b")
        #expect(Caderno.textoVisivel(bloco) == "a + b")
        #expect(!Caderno.textoVisivel(bloco).contains("```"))
        #expect(!Caderno.textoVisivel(bloco).contains("$"))
        #expect(Caderno.serializar(bloco) == "```tex\na + b\n```")
        #expect(!Caderno.visivel("```tex\na + b\n```").contains("```"))
    }

    @Test func imagemAudioVideoSaoPortais() {
        let md = """
        ![](traco://img/AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE)
        [audio:voz.m4a](traco://audio/AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE)
        [video:cena.mov](traco://video/AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE)
        """
        let tipos = Caderno.fatias(md).map(\.bloco)
        #expect(tipos.contains { if case .imagem = $0 { true } else { false } })
        #expect(tipos.contains { if case .audio = $0 { true } else { false } })
        #expect(tipos.contains { if case .video = $0 { true } else { false } })
        #expect(Caderno.prosa(de: md).isEmpty)
    }

    @Test func tituloListaCitacao() {
        let md = """
        # capa
        - um
        - dois
        > dito
        """
        let blocos = Caderno.fatias(md).map(\.bloco)
        #expect(blocos.contains { if case .titulo(1, "capa") = $0 { true } else { false } })
        #expect(blocos.contains { if case .itens(let xs, false) = $0 { xs == ["um", "dois"] } else { false } })
        #expect(blocos.contains { if case .citacao(let xs) = $0 { xs == ["dito"] } else { false } })
    }

    @Test func citacaoVisivelNaoTemMaior() {
        #expect({
            if case .citacao(let xs) = Caderno.paginaUna("> a noite")?.bloco { xs == ["a noite"] } else { false }
        }())
        #expect(Caderno.visivel("> a noite").trimmingCharacters(in: .whitespacesAndNewlines) == "a noite")
        #expect(!Caderno.visivel("> a noite").contains(">"))
        #expect(Caderno.textoVisivel(.citacao(["a noite"])) == "a noite")
        #expect(Caderno.serializar(.citacao(["a noite"])) == "> a noite")
        #expect(Caderno.textoVisivel(Caderno.forma(.citacao, texto: "a noite")) == "a noite")
        #expect(!Caderno.textoVisivel(Caderno.forma(.citacao, texto: "a noite")).contains(">"))
        #expect(Caderno.fatiaQueNasceu(de: "", para: "> a noite") == "citacao:0")
        let volta = Caderno.fatias(Caderno.serializar(.citacao(["a noite"])))
        #expect(volta.contains { Caderno.textoVisivel($0.bloco) == "a noite" })
        #expect(volta.allSatisfy { !Caderno.textoVisivel($0.bloco).contains(">") })
    }

    @Test func tabelaETarefaFicamVisuaisENaVoz() {
        let md = """
        | a | b |
        | --- | --- |
        | 1 | 2 |
        - [ ] abrir
        - [x] fechar
        """
        let blocos = Caderno.fatias(md).map(\.bloco)
        #expect(blocos.contains { if case .tabela(let c, let corpo) = $0 { c == ["a", "b"] && corpo == [["1", "2"]] } else { false } })
        #expect(blocos.contains { if case .tarefas(let xs) = $0 { xs == [TarefaCaderno(feito: false, texto: "abrir"), TarefaCaderno(feito: true, texto: "fechar")] } else { false } })
        let prosa = Caderno.prosa(de: md)
        #expect(prosa.contains("abrir"))
        #expect(prosa.contains("fechar"))
        #expect(prosa.contains("a"))
    }

    @Test func serializarNaoMostraMarcacaoNoTextoVisivel() {
        let titulo = Caderno.forma(.titulo, texto: "capa")
        #expect(Caderno.textoVisivel(titulo) == "capa")
        #expect(Caderno.serializar(titulo) == "# capa")
        let codigo = Caderno.forma(.codigo("swift"), texto: "")
        #expect(Caderno.textoVisivel(codigo) == "")
        #expect(Caderno.serializar(codigo) == "```swift\n\n```")
        let (antes, ultimo) = Caderno.partirUltimo("quero um parser")
        #expect(antes.isEmpty)
        #expect(ultimo == "quero um parser")
        let nota = Caderno.juntar("quero um parser", .codigo(lingua: "swift", fonte: "let n = 2"))
        #expect(Caderno.prosa(de: nota) == "quero um parser")
        #expect(Caderno.fatias(nota).contains { if case .codigo = $0.bloco { true } else { false } })
    }

    @Test func recipienteNaoVazaMarcacao() {
        let md = """
        :::verso
        a noite
        :::
        """
        let f = Caderno.fatias(md)
        #expect(f.contains { if case .recipiente(let slug, let xs) = $0.bloco { slug == "verso" && xs == ["a noite"] } else { false } })
        let bloco = BlocoCaderno.recipiente(slug: "verso", linhas: ["a noite"])
        #expect(Caderno.textoVisivel(bloco) == "a noite")
        #expect(Caderno.serializar(bloco) == ":::verso\na noite\n:::")
        #expect(Caderno.prosa(de: md) == "a noite")
    }

    @Test func recipienteAbertoNaoVazaMarcacao() {
        let md = """
        rascunho
        :::ideia
        ainda
        """
        let f = Caderno.fatias(md)
        #expect(f.contains { if case .recipiente(let slug, let xs) = $0.bloco { slug == "ideia" && xs == ["ainda"] } else { false } })
        #expect(f.allSatisfy { !$0.fonte.contains(":::") || Caderno.textoVisivel($0.bloco).contains("ainda") || $0.bloco == .paragrafo("rascunho") })
        #expect(!Caderno.textoVisivel(.recipiente(slug: "ideia", linhas: ["ainda"])).contains(":::"))
        #expect(Caderno.prosa(de: md).contains("ainda"))
        #expect(Caderno.prosa(de: md).contains("rascunho"))
    }

    @Test func editarRecipienteMantemFormaEEscondeFonte() {
        let md = """
        :::chamada
        isto importa agora
        :::
        :::traducao
        Dwdwdwd
        vergonha
        :::
        """
        let f = Caderno.fatias(md)
        let chamada = f.first { if case .recipiente("chamada", _) = $0.bloco { true } else { false } }
        #expect(chamada != nil)
        let novo = Caderno.comTexto(chamada!.bloco, "isto importa agora")
        let saida = Caderno.aplicar(f, id: chamada!.id, bloco: novo)
        let depois = Caderno.fatias(saida)
        #expect(depois.contains { if case .recipiente("chamada", let xs) = $0.bloco { xs == ["isto importa agora"] } else { false } })
        #expect(depois.contains { if case .recipiente("traducao", _) = $0.bloco { true } else { false } })
        #expect(depois.allSatisfy { !Caderno.textoVisivel($0.bloco).contains(":::") })
    }

    @Test func paginaUnaETituloOuProsa() {
        #expect({
            if case .titulo(1, "capa") = Caderno.paginaUna("#capa")?.bloco { true } else { false }
        }())
        #expect(Caderno.textoVisivel(Caderno.paginaUna("#capa")!.bloco) == "capa")
        #expect(!Caderno.textoVisivel(Caderno.paginaUna("#")!.bloco).contains("#"))
        #expect({
            if case .paragrafo = Caderno.paginaUna("leite")?.bloco { true } else { false }
        }())
        #expect(Caderno.paginaUna("#capa\n\ncorpo") == nil)
        #expect(Caderno.paginaUna("| a | b |") == nil)
        #expect({
            if case .itens(let xs, false) = Caderno.paginaUna("- leite")?.bloco { xs == ["leite"] } else { false }
        }())
        #expect({
            if case .tarefas(let xs) = Caderno.paginaUna("- [ ] abrir")?.bloco { xs.first?.texto == "abrir" } else { false }
        }())
        #expect({
            if case .tabela = Caderno.paginaUna("|")?.bloco { true } else { false }
        }())
        // lista de qualquer tamanho continua una: a digitação nunca troca de campo
        #expect({
            if case .itens(let xs, false) = Caderno.paginaUna("- um\n- dois")?.bloco { xs == ["um", "dois"] } else { false }
        }())
        // a edição crua só vive em prosa+lista: mobiliário NUNCA aparece cru
        #expect(Caderno.soProsaELista("oi\n\n1. um\n2. dois"))
        #expect(!Caderno.soProsaELista("```rust\nfe\n```"))
        #expect(!Caderno.soProsaELista("> citação"))
        #expect(!Caderno.soProsaELista("[arquivo:guia.pdf](traco://file/00000000-0000-4000-8000-000000000001)"))
        #expect(!Caderno.soProsaELista("| a | b |"))
        #expect(!Caderno.soProsaELista("- [ ] tarefa"))
        #expect(!Caderno.temMarca(Caderno.visivel("- [ ] abrir")))
        #expect(!Caderno.visivel("- leite").contains("- "))
    }

    @Test func caixaNascenteViraTarefaSemMarca() {
        #expect({
            if case .tarefas(let xs) = Caderno.paginaUna("- [")?.bloco {
                xs.first?.texto == ""
            } else { false }
        }())
        #expect({
            if case .tarefas(let xs) = Caderno.paginaUna("- []abrir")?.bloco {
                xs.first?.texto == "abrir"
            } else { false }
        }())
        #expect(Caderno.textoVisivel(Caderno.paginaUna("- []abrir")!.bloco) == "abrir")
        #expect(!Caderno.visivel("- []abrir").contains("["))
        #expect(!Caderno.visivel("- [").contains("["))
        #expect({
            if case .tarefas(let xs) = Caderno.comTexto(.itens([""], ordenada: false), "[") {
                xs.first?.texto == ""
            } else { false }
        }())
        #expect({
            if case .tarefas(let xs) = Caderno.comTexto(
                .tarefas([TarefaCaderno(feito: false, texto: "")]),
                "]abrir"
            ) {
                xs.first?.texto == "abrir"
            } else { false }
        }())
        #expect({
            if case .itens(let xs, false) = Caderno.paginaUna("- [sic]")?.bloco {
                xs == ["[sic]"]
            } else { false }
        }())
    }

    @Test func saiDaProsaEditaAFiguraNova() {
        #expect(Caderno.fatiaQueNasceu(de: "", para: "#capa") == "titulo-1:0")
        #expect(Caderno.fatiaQueNasceu(de: "", para: "#") == "titulo-1:0")
        #expect(Caderno.fatiaQueNasceu(de: "leite", para: "leite") == nil)
        #expect(Caderno.fatiaQueNasceu(de: "", para: "- um") == "lista:0")
        #expect(Caderno.fatiaQueNasceu(de: "", para: "| a | b |") == "tabela:0")
    }

    @Test func hashSemEspacoViraTituloSemMarca() {
        let f = Caderno.fatias("#capa")
        #expect(f.contains { if case .titulo(1, "capa") = $0.bloco { true } else { false } })
        #expect(Caderno.textoVisivel(.titulo(1, "capa")) == "capa")
        #expect(!Caderno.textoVisivel(.titulo(1, "capa")).contains("#"))
        #expect(!Caderno.fatias("#!/bin/sh").contains { if case .titulo = $0.bloco { true } else { false } })
    }

    @Test func tabelaVisivelNaoTemPipe() {
        let bloco = Caderno.forma(.tabela, texto: "")
        #expect(!Caderno.textoVisivel(bloco).contains("|"))
        #expect(!Caderno.textoVisivel(bloco).contains("---"))
    }

    @Test func tituloVazioNaoVazaMarcacao() {
        let f = Caderno.fatias("##")
        #expect(f.contains { if case .titulo(2, "") = $0.bloco { true } else { false } })
        #expect(Caderno.textoVisivel(.titulo(2, "")) == "")
        #expect(!Caderno.textoVisivel(.titulo(2, "")).contains("#"))
    }

    @Test func seccaoVisivelNaoTemHash() {
        #expect({
            if case .titulo(2, "capa") = Caderno.paginaUna("## capa")?.bloco { true } else { false }
        }())
        #expect(Caderno.textoVisivel(.titulo(2, "capa")) == "capa")
        #expect(!Caderno.visivel("## capa").contains("#"))
        #expect(Caderno.serializar(.titulo(2, "capa")) == "## capa")
    }

    @Test func reguaEnxutaCatalogoVasto() {
        // SPEC §12: a RÉGUA é enxuta (≤12 — menu grande é template em menu).
        #expect(PapelForma.regua.count == 12)
        #expect(PapelForma.regua.prefix(6).map(\.nome) == ["Título", "Seção", "Lista", "Numerada", "Tarefa", "Citação"])
        // O CATÁLOGO segue vasto e único: todo `:::slug` já gravado continua lendo.
        #expect(PapelForma.catalogo.count >= 120)
        #expect(Set(PapelForma.catalogo.map(\.slug)).count == PapelForma.catalogo.count)
        #expect(PapelForma.regua.allSatisfy { r in PapelForma.catalogo.contains { $0.slug == r.slug } })
    }

    @Test func idDaFatiaNaoReshuffleAoEditar() {
        let md = """
        :::chamada
        um
        :::
        :::traducao
        a
        b
        :::
        """
        let f = Caderno.fatias(md)
        let chamada = f.first { $0.id == "papel-chamada:0" }
        #expect(chamada != nil)
        #expect(f.contains { $0.id == "papel-traducao:0" })
        let saida = Caderno.aplicar(f, id: "papel-chamada:0", bloco: Caderno.comTexto(chamada!.bloco, "um e mais"))
        let depois = Caderno.fatias(saida)
        #expect(depois.contains { $0.id == "papel-chamada:0" && Caderno.textoVisivel($0.bloco) == "um e mais" })
        #expect(depois.contains { $0.id == "papel-traducao:0" })
    }

    @Test func pipeSozinhoNaoFicaNaPagina() {
        let f = Caderno.fatias("|")
        #expect(f.contains { if case .tabela = $0.bloco { true } else { false } })
        #expect(!Caderno.visivel("|").contains("|"))
        #expect(Caderno.fatiaQueNasceu(de: "", para: "|") == "tabela:0")
    }

    @Test func pipeSemSeparadorViraTabelaSemMarca() {
        let f = Caderno.fatias("| a | b |")
        #expect(f.contains { if case .tabela(let c, _) = $0.bloco { c == ["a", "b"] } else { false } })
        #expect(!Caderno.visivel("| a | b |").contains("|"))
        #expect(!Caderno.temMarca(Caderno.visivel("| a | b |")))
    }

    @Test func separadorPipeNaoFicaNaPagina() {
        let f = Caderno.fatias("|---|")
        #expect(f.contains { if case .tabela = $0.bloco { true } else { false } })
        #expect(!Caderno.visivel("|---|").contains("|"))
        #expect(!Caderno.visivel("|---|").contains("---"))
        #expect(!Caderno.temMarca(Caderno.visivel("|---|")))
    }

    @Test func cercaVaziaNaoFicaNaPagina() {
        let f = Caderno.fatias("ainda\n:::")
        #expect(f.contains { if case .paragrafo(let t) = $0.bloco { t.contains("ainda") } else { false } })
        #expect(f.allSatisfy { !Caderno.textoVisivel($0.bloco).contains(":::") })
        #expect(!Caderno.visivel("ainda\n:::").contains(":::"))
    }

    @Test func pdfViraArquivoSemMarca() {
        let id = UUID()
        let marca = AnexoDisco.marcaMarkdown(id: id, nome: "guia.pdf", tipo: .pdf)
        let f = Caderno.fatias(marca)
        #expect(f.contains { if case .arquivo(_, let n) = $0.bloco { n == "guia.pdf" } else { false } })
        #expect(Caderno.prosa(de: marca).isEmpty)
        #expect(!Caderno.visivel(marca).contains("traco://"))
        #expect(Caderno.visivel(marca).contains("guia.pdf"))
    }

    @Test func divisoriaVisivelNaoTemTraco() {
        #expect(Caderno.fatias("---").contains { if case .divisoria = $0.bloco { true } else { false } })
        #expect(Caderno.textoVisivel(.divisoria) == "")
        #expect(Caderno.serializar(.divisoria) == "---")
        #expect(!Caderno.visivel("---").contains("---"))
        #expect(!Caderno.visivel("***").contains("***"))
        #expect(Caderno.fatias("***").contains { if case .divisoria = $0.bloco { true } else { false } })
    }

    @Test func superficieEscondeMarcas() {
        let uuid = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
        let amostras = [
            "#capa",
            "##",
            "```swift\nlet x",
            ":::ideia\nainda",
            "| a | b |\n| --- | --- |",
            "| x | y |",
            "- [ ] abrir",
            "---",
            "![](traco://img/\(uuid))",
            "[arquivo:guia.pdf](traco://file/\(uuid))",
        ]
        for md in amostras {
            #expect(!Caderno.temMarca(Caderno.visivel(md)), "vazou em \(md)")
        }
        #expect(!Caderno.visivel("#capa").contains("#"))
    }

    @Test func cercaAbertaViraPortalSemMarca() {
        let md = """
        rascunho
        ```swift
        let x
        """
        let f = Caderno.fatias(md)
        #expect(f.contains { if case .paragrafo(let t) = $0.bloco { t.contains("rascunho") } else { false } })
        #expect(f.contains { if case .codigo("swift", let s) = $0.bloco { s.contains("let x") } else { false } })
        #expect(f.allSatisfy { !Caderno.textoVisivel($0.bloco).contains("```") })
        #expect(Caderno.prosa(de: md) == "rascunho")
    }
}

struct SintaxeTests {
    @Test func jsonPintaChaveEValor() {
        let p = SintaxeLocal.pintar("{\"a\": \"b\"}", lingua: "json")
        #expect(p.contains { $0.0.contains("a") && $0.1 == .chave })
        #expect(p.contains { $0.0.contains("b") && $0.1 == .valor })
    }

    @Test func swiftPintaKeywordTipoEFuncao() {
        let p = SintaxeLocal.pintar("func abrir() -> String { return 2 }", lingua: "swift")
        #expect(p.contains { $0.0 == "func" && $0.1 == .chave })
        #expect(p.contains { $0.0 == "abrir" && $0.1 == .funcao })
        #expect(p.contains { $0.0 == "String" && $0.1 == .tipo })
        #expect(p.contains { $0.0 == "2" && $0.1 == .numero })
    }

    @Test func comentarioNaoEKeyword() {
        let p = SintaxeLocal.pintar("// func senti", lingua: "swift")
        #expect(p.allSatisfy { $0.1 == .comentario || $0.0 == "\n" })
    }

    @Test func pythonHashEComentario() {
        let p = SintaxeLocal.pintar("# def foo", lingua: "python")
        #expect(p.contains { $0.1 == .comentario })
    }
    @Test func memoDevolveOMesmoResultadoDoParser() {
        let md = "# capa\n- um\n- dois\n> dito"
        let a = Caderno.fatias(md)
        let b = Caderno.fatias(md) // segunda chamada: memo
        #expect(a == b)
        #expect(a.map(\.id) == Caderno.fatiasSemMemo(md).map(\.id))
        let outro = Caderno.fatias(md + "\nmais")
        #expect(outro.count >= a.count) // mudança real invalida o memo
    }
}

struct DesempenhoParserTests {
    /// META: "nota de 10k palavras fluida". Este teste roda em DEBUG (sem -O);
    /// o teto de 30ms aqui equivale a poucos ms em Release — e barra qualquer
    /// regressão quadrática (a versão O(n²) media 254ms neste mesmo harness).
    @Test func dezMilPalavrasCabemNumFrame() {
        var linhas: [String] = []
        for i in 0..<500 {
            linhas.append("# seção \(i)")
            linhas.append(String(repeating: "palavra ", count: 18))
            linhas.append("- item um da lista \(i)")
            linhas.append("- item dois da lista \(i)")
            linhas.append("> uma citação com algum corpo \(i)")
        }
        let doc = linhas.joined(separator: "\n") // ~10k palavras, blocos variados
        _ = Caderno.fatiasSemMemo(doc) // aquecimento
        let inicio = ContinuousClock.now
        let n = 20
        for _ in 0..<n { _ = Caderno.fatiasSemMemo(doc) }
        let total = ContinuousClock.now - inicio
        let mediaMs = Double(total.components.attoseconds) / 1e15 / Double(n)
            + Double(total.components.seconds) * 1000 / Double(n)
        #expect(mediaMs < 30, "parse médio de 10k palavras: \(mediaMs)ms — acima do teto (debug)")
    }
}

/// A bateria do screenshot do dono: todos os casos de digitação de lista.
struct DigitacaoDeListaTests {
    @Test func enterContinuaListaNumerada() {
        let velho = "1. comprar leite"
        let novo = velho + "\n"
        #expect(Caderno.continuar(velho: velho, novo: novo) == "1. comprar leite\n2. ")
    }

    @Test func enterContinuaListaSimplesETarefa() {
        #expect(Caderno.continuar(velho: "- pão", novo: "- pão\n") == "- pão\n- ")
        #expect(Caderno.continuar(velho: "- [ ] ligar", novo: "- [ ] ligar\n") == "- [ ] ligar\n- [ ] ")
    }

    @Test func enterEmItemVazioSaiDaLista() {
        // "1. a\n2. " + Enter → o "2. " morre e a linha fica livre
        let velho = "1. a\n2. "
        let novo = velho + "\n"
        #expect(Caderno.continuar(velho: velho, novo: novo) == "1. a\n\n")
        #expect(Caderno.continuar(velho: "- ", novo: "- \n") == "\n")
        #expect(Caderno.continuar(velho: "3.", novo: "3.\n") == "\n")
    }

    @Test func mudancaQueNaoEEnterNaoMexe() {
        #expect(Caderno.continuar(velho: "1. a", novo: "1. ab") == "1. ab")
        #expect(Caderno.continuar(velho: "1. a", novo: "1. a\nx e mais") == "1. a\nx e mais")
        #expect(Caderno.continuar(velho: "abc", novo: "abc\n") == "abc\n") // linha comum: nada a herdar
    }

    @Test func enterNoMeioDoTextoTambemContinua() {
        // Enter com texto depois (quebrar um item em dois)
        let velho = "1. um dois"
        // \n inserido depois de "um " → "1. um \ndois"… continuação insere "2. " antes de "dois"
        let novo = "1. um \ndois"
        #expect(Caderno.continuar(velho: velho, novo: novo) == "1. um \n2. dois")
    }

    @Test func numeroSoltoJaEItem() {
        // o caso do screenshot: "3." em linhas soltas não vira parágrafos órfãos
        let f = Caderno.fatias("3.\n3.\n3.")
        // uma lista só (+ o parágrafo vazio aberto que o parser anexa para seguir digitando)
        #expect({ if case .itens(let xs, true) = f[0].bloco { xs == ["", "", ""] } else { false } }())
        #expect(!f.dropFirst().contains { if case .itens = $0.bloco { true } else { false } })
        let f2 = Caderno.fatias("-")
        #expect({ if case .itens(let xs, false) = f2[0].bloco { xs == [""] } else { false } }())
    }

    @Test func serializacaoRenumeraLimpo() {
        // itens com marcador digitado à mão nunca duplicam: o conteúdo é só conteúdo
        let md = Caderno.serializar(.itens(["a", "b"], ordenada: true))
        #expect(md == "1. a\n2. b")
    }
}
