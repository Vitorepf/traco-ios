import Testing
@testable import Traco

/// Propriedades do caderno sob entrada HOSTIL. Os testes de exemplo provam que
/// o caso que eu imaginei funciona; estes provam que a lei vale para entradas
/// que eu não imaginei — que é onde os defeitos moram.
struct CadernoFuzzTests {

    // MARK: - Corpus

    /// Pedaços que um autor de verdade digita, mais tudo que costuma quebrar
    /// parser: mobiliário markdown solto, cercas sem fecho, pipes na prosa,
    /// RTL, emoji com modificador, CRLF, controle, palavra gigante.
    static let pedacos: [String] = [
        "a noite fecha",
        "quero correr de manhã",
        "custo | benefício",
        "1. primeiro",
        "- item",
        "- [ ] tarefa",
        "- [x] feita",
        "# título",
        "## seção",
        "### sub",
        "> citação",
        "---",
        "***",
        "```",
        "```swift",
        "```swift\nlet x = 1",
        "let x = 1\n```",
        ":::",
        ":::verso",
        ":::verso\nlinha\n:::",
        "traco://file/abc",
        "![alt](traco://file/abc)",
        "| a | b |",
        "| --- | --- |",
        "|---|",
        "|",
        "||",
        "  ",
        "\t",
        "",
        "\n",
        "\r\n",
        "\n\n\n",
        "😀",
        "👨‍👩‍👧‍👦 família",
        "🇧🇷 bandeira",
        "e\u{0301} com acento combinante",
        "مرحبا بالعالم",
        "שלום עולם",
        "日本語のテキスト",
        "\u{200B}zero width",
        "\u{FEFF}bom",
        String(repeating: "x", count: 600),
        String(repeating: "palavra ", count: 200),
        "linha1\nlinha2\nlinha3",
        "#semespaco",
        "-semespaco",
        ">semespaco",
        "1.semespaco",
        "  - recuado",
        "\t- tabulado",
        "- ",
        "# ",
        "> ",
    ]

    /// Gerador determinístico: o mesmo fuzz roda igual em toda máquina e toda
    /// vez — um teste que falha só às vezes não é prova de nada.
    struct Semente {
        private var estado: UInt64
        init(_ s: UInt64) { estado = s == 0 ? 0x9E3779B97F4A7C15 : s }
        mutating func proximo() -> UInt64 {
            estado ^= estado << 13
            estado ^= estado >> 7
            estado ^= estado << 17
            return estado
        }
        mutating func indice(_ n: Int) -> Int { n == 0 ? 0 : Int(proximo() % UInt64(n)) }
    }

    static func documentos(quantos: Int, semente: UInt64 = 20260831) -> [String] {
        var r = Semente(semente)
        return (0..<quantos).map { _ in
            let n = 1 + r.indice(7)
            let sep = ["\n", "\n\n", "\n\n\n"]
            return (0..<n)
                .map { _ in pedacos[r.indice(pedacos.count)] }
                .joined(separator: sep[r.indice(sep.count)])
        }
    }

    // MARK: - As leis

    /// A LEI DO DONO: o autor nunca vê mobiliário markdown. As marcas aqui são
    /// as que o APP escreve — cerca de código, cerca de recipiente, URL interna.
    /// "- [ ]" e "|---" ficam de fora de propósito: dentro do corpo de um verso
    /// eles são texto DO AUTOR (um poema pode ter um traço), e mostrá-los é o
    /// certo. A lei é sobre mobiliário nosso, não sobre a voz dele.
    @Test func prosaNuncaCarregaMobiliario() {
        for doc in Self.documentos(quantos: 400) {
            let p = Caderno.prosa(de: doc)
            #expect(!p.contains("```"), "cerca de código vazou: \(p.debugDescription) ← \(doc.debugDescription)")
            #expect(!p.contains(":::"), "cerca de recipiente vazou: \(p.debugDescription) ← \(doc.debugDescription)")
            #expect(!p.contains("traco://"), "URL interna vazou: \(p.debugDescription) ← \(doc.debugDescription)")
        }
    }

    /// O texto VISÍVEL na tela obedece à mesma lei.
    @Test func visivelNuncaCarregaMobiliario() {
        for doc in Self.documentos(quantos: 400, semente: 7717) {
            let v = Caderno.visivel(doc)
            #expect(!v.contains("```"), "cerca vazou em visivel: \(v.debugDescription) ← \(doc.debugDescription)")
            #expect(!v.contains(":::"), "recipiente vazou em visivel: \(v.debugDescription) ← \(doc.debugDescription)")
            #expect(!v.contains("traco://"), "URL interna vazou em visivel: \(v.debugDescription) ← \(doc.debugDescription)")
        }
    }

    /// Fatiar é ESTÁVEL: remontar as fatias e fatiar de novo dá o mesmo
    /// documento. Sem isto, editar um bloco reescreve blocos vizinhos.
    @Test func fatiarEEstavel() {
        for doc in Self.documentos(quantos: 400, semente: 4242) {
            let um = Caderno.fatias(doc)
            let remontado = um.map(\.fonte).joined(separator: "\n\n")
            let dois = Caderno.fatias(remontado)
            #expect(Self.comConteudo(um) == Self.comConteudo(dois),
                    "blocos mudaram no reparse: \(doc.debugDescription)")
        }
    }

    /// Serializar e fatiar de volta devolve o MESMO bloco. É a garantia de que
    /// vestir uma forma não corrompe o que o autor escreveu.
    @Test func serializarERedondo() {
        for doc in Self.documentos(quantos: 300, semente: 999) {
            for fatia in Caderno.fatias(doc) {
                let volta = Caderno.fatias(Caderno.serializar(fatia.bloco))
                #expect(volta.count >= 1)
                #expect(volta.first?.bloco == fatia.bloco,
                        "ida e volta perdeu o bloco \(fatia.bloco) ← \(doc.debugDescription)")
            }
        }
    }

    /// Trocar uma fatia por ELA MESMA não pode mexer no documento. O parágrafo
    /// vazio do fim é a linha onde o cursor mora, não conteúdo: `aplicar` o
    /// descarta de propósito, então a comparação é sobre os blocos com texto.
    static func comConteudo(_ fs: [FatiaCaderno]) -> [BlocoCaderno] {
        fs.map(\.bloco).filter {
            if case .paragrafo(let t) = $0 {
                return !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return true
        }
    }

    @Test func aplicarIdenticoNaoMexe() {
        for doc in Self.documentos(quantos: 300, semente: 31337) {
            let fs = Caderno.fatias(doc)
            guard let alvo = fs.first else { continue }
            let depois = Caderno.aplicar(fs, id: alvo.id, novo: alvo.fonte)
            #expect(Self.comConteudo(Caderno.fatias(depois)) == Self.comConteudo(fs),
                    "aplicar idêntico mexeu no documento: \(doc.debugDescription)")
        }
    }

    /// Aplicar CONVERGE: o espaçamento entre blocos vira "\n\n" na primeira
    /// edição, e a segunda não muda mais um byte. (ponytail: a voz fica; o
    /// número de linhas em branco entre blocos, não — preservá-lo exigiria
    /// faixas no parser. Em modo vestido ele nem se vê.)
    @Test func aplicarConvergeEmUmaEdicao() {
        for doc in Self.documentos(quantos: 300, semente: 77) {
            // a edição REAL: o bloco serializado (um chip, um toggle), nunca a fonte crua
            let fs = Caderno.fatias(doc)
            guard let alvo = fs.first else { continue }
            let a = Caderno.aplicar(fs, id: alvo.id, novo: Caderno.serializar(alvo.bloco))
            let fs2 = Caderno.fatias(a)
            guard let alvo2 = fs2.first else { continue }
            let b = Caderno.aplicar(fs2, id: alvo2.id, novo: Caderno.serializar(alvo2.bloco))
            #expect(a == b, "a segunda edição mudou bytes: \(doc.debugDescription)")
        }
    }

    /// A VOZ do autor não se perde: toda palavra de prosa que entrou continua
    /// legível na saída visível.
    @Test func aVozNaoSePerde() {
        let vozes = ["saudade", "correr", "manhã", "obstáculo", "ninguém"]
        for (i, voz) in vozes.enumerated() {
            for doc in Self.documentos(quantos: 60, semente: UInt64(500 + i)) {
                let comVoz = doc + "\n\n" + voz
                #expect(Caderno.visivel(comVoz).contains(voz),
                        "a voz \(voz) sumiu de \(comVoz.debugDescription)")
            }
        }
    }

    /// `soProsaELista` é o portão da edição crua: se ele disser sim, o texto
    /// não pode ter NENHUMA marca — é literalmente a promessa ao autor.
    @Test func portaoDaEdicaoCruaNuncaDeixaPassarMarca() {
        for doc in Self.documentos(quantos: 500, semente: 8080) {
            if Caderno.soProsaELista(doc) {
                #expect(!Caderno.temMarca(doc),
                        "portão aberto com marca dentro: \(doc.debugDescription)")
            }
        }
    }

    /// Fatiar nunca engole o documento inteiro nem devolve vazio para texto
    /// com conteúdo.
    @Test func fatiarSempreDevolveAlgo() {
        for doc in Self.documentos(quantos: 400, semente: 1234) {
            let fs = Caderno.fatias(doc)
            #expect(!fs.isEmpty, "fatias vazias para \(doc.debugDescription)")
            // só exigimos conteúdo visível quando há LETRA ou DÍGITO FORA das
            // linhas de cerca: um documento que é só mobiliário ("```",
            // ":::verso" — onde "verso" é o nome do papel, não texto do autor)
            // não tem nada a mostrar, e não mostrar nada é o certo
            let semCercas = doc
                .split(separator: "\n", omittingEmptySubsequences: false)
                .filter { l in
                    let t = l.trimmingCharacters(in: .whitespaces)
                    return !t.hasPrefix("```") && !t.hasPrefix(":::")
                }
                .joined(separator: "\n")
            if semCercas.contains(where: { $0.isLetter || $0.isNumber }) {
                let algum = fs.contains { !Caderno.textoVisivel($0.bloco).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    || fs.contains { if case .divisoria = $0.bloco { true } else { false } }
                    || fs.contains { if case .codigo = $0.bloco { true } else { false } }
                    || fs.contains { if case .imagem = $0.bloco { true } else { false } }
                    || fs.contains { if case .audio = $0.bloco { true } else { false } }
                    || fs.contains { if case .video = $0.bloco { true } else { false } }
                    || fs.contains { if case .arquivo = $0.bloco { true } else { false } }
                #expect(algum, "documento com conteúdo virou só vazio: \(doc.debugDescription)")
            }
        }
    }

    /// Vestir QUALQUER forma sobre QUALQUER texto devolve um documento que
    /// ainda fatia — e cujo bloco é o da forma pedida.
    @Test func vestirQualquerFormaSobreQualquerTexto() {
        let formas: [FormaCaderno] = [.titulo, .lista, .tarefa, .citacao, .tabela, .codigo("swift")]
        for doc in Self.documentos(quantos: 120, semente: 606) {
            let (_, ultimo) = Caderno.partirUltimo(doc)
            for forma in formas {
                let bloco = Caderno.forma(forma, texto: ultimo)
                let fonte = Caderno.serializar(bloco)
                let fs = Caderno.fatias(fonte)
                #expect(!fs.isEmpty, "\(forma) sobre \(ultimo.debugDescription) não fatiou")
                #expect(Caderno.chave(fs[0].bloco) == Caderno.chave(bloco),
                        "\(forma) virou \(Caderno.chave(fs[0].bloco)) em \(ultimo.debugDescription)")
            }
        }
    }

    /// CRLF é o que chega de import de .md feito no Windows: não pode virar
    /// caractere visível na nota.
    @Test func crlfNaoViraLixoVisivel() {
        for doc in Self.documentos(quantos: 200, semente: 13) {
            let comCRLF = doc.replacingOccurrences(of: "\n", with: "\r\n")
            #expect(!Caderno.visivel(comCRLF).contains("\r"),
                    "\\r sobrou na tela: \(comCRLF.debugDescription)")
        }
    }

    /// Documento grande não pode explodir nem demorar: o autor de verdade
    /// escreve por anos na mesma nota.
    @Test func documentoGrandeFatiaRapido() {
        let grande = Self.documentos(quantos: 400, semente: 55).joined(separator: "\n\n")
        let inicio = ContinuousClock.now
        let fs = Caderno.fatiasSemMemo(grande)
        let gasto = ContinuousClock.now - inicio
        #expect(!fs.isEmpty)
        #expect(gasto < .milliseconds(400), "fatiar \(grande.count) chars levou \(gasto)")
    }
}
