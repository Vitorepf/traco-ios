import Foundation
import SwiftData
import Testing
@testable import Traco

/// O PORTÃO DO `try!` — item 8 da fila do dono ("falhas previsíveis permitem
/// recuperação e preservam o conteúdo") e a dívida que a limpeza de 07/09
/// registrou no RUMO: `TracoApp.swift:13` fazia `try! DiscoTraco.abrir(…)`, e
/// um banco que não abrisse matava o app no arranque — sem tela, sem
/// explicação, sem recuperação (ADR 2026-09-08s).
///
/// `try!` num caminho de produção é uma decisão de matar o processo tomada no
/// ponto de uso, longe de quem vai ver a tela morrer. O portão não proíbe:
/// congela. O que existe hoje está na lista abaixo com o julgamento caso a
/// caso; o que aparecer novo fica vermelho.
///
/// Irmão do `PortaoDoMovimentoTests`, e reusa a varredura dele (`codigoVisivel`)
/// para não contar `try!` escrito dentro de comentário ou de string — este
/// próprio arquivo de doc estaria vermelho sem isso.
struct PortaoDoTryBangTests {
    /// A DÍVIDA CONGELADA em 08/09/2026, **medida** — e a medida se refaz. O
    /// `grep` cru NÃO serve de prova: hoje ele conta 10, porque esta volta
    /// escreveu duas linhas de comentário que dizem `try!`. A conta que vale é
    /// a de `try!` em CÓDIGO, e este comando a reproduz, aqui e em `main`:
    ///
    /// ```
    /// grep -rn 'try!' Traco/ TracoWidget/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//'
    /// ```
    ///
    /// **8 em 08/09; 6 depois da volta B1** (ADR 2026-09-09o). O portão não usa
    /// esse filtro de uma linha: usa `codigoVisivel`, que apaga comentário E
    /// string antes de contar — o filtro acima é a versão que qualquer um roda
    /// sem compilar nada.
    ///
    /// A volta B1 foi ATRÁS das quatro "dívidas reais" com o dado que as faz
    /// explodir, como manda a §8, e o que achou virou medida em vez de opinião:
    /// **nenhuma das quatro pode explodir**, e duas delas nem sequer estavam
    /// guardadas pelo `try`. A prova roda em `AProvaDosQuatro`, abaixo.
    ///
    /// | arquivo | n | julgamento |
    /// |---|---|---|
    /// | `Traco/Caderno/AnexoDisco.swift` | 1 | **infalível por construção** — `NSRegularExpression` de padrão literal |
    /// | `Traco/Trabalho/ConferenciaTrabalho.swift` | 1 | **infalível por construção** — `Regex` de padrão literal, mas o padrão chega por argumento: infalível só enquanto todos os chamadores forem literais, e é isso que `aConferenciaSoAceitaPadraoLiteralDoProprioArquivo` guarda |
    /// | `Traco/Notas/Corpus.swift` | 2 | **as duas infalíveis por construção** — a do corpo é `JSONEncoder().encode` de um `String` (`campos` é `[String: String]`) com o `!` do dicionário coberto pelo filtro `f.campos[$0] != nil` três linhas acima; a outra é regex literal |
    /// | `Traco/Notas/Indice.swift` | 1 | **infalível por construção** — `NSRegularExpression` de padrão literal |
    /// | `Traco/App/Sessao.swift` | 1 | **infalível por construção** — `JSONEncoder().encode([String])`: `[String]` é sempre JSON válido e `String` do Swift é sempre UTF-8 válido, então não há texto do autor que derrube a assinatura |
    ///
    /// SAÍRAM (`FonteNotas` e `PraticaTrabalho`, o mesmo `json(_ objeto: Any)`
    /// nos dois): não saíram por serem infalíveis — saíram porque o `try!` ali
    /// era o guarda ERRADO. `JSONSerialization.data(withJSONObject:)` com objeto
    /// inválido **não lança**: levanta `NSInvalidArgumentException`, que mata o
    /// processo por baixo de `try!`, de `try?` e de `do/catch` igualmente. O
    /// guarda que funciona é `isValidJSONObject`, e é o que está lá agora.
    static let faltosos: [String: Int] = [
        "Traco/App/Sessao.swift": 1,
        "Traco/Caderno/AnexoDisco.swift": 1,
        "Traco/Notas/Corpus.swift": 2,
        "Traco/Notas/Indice.swift": 1,
        "Traco/Trabalho/ConferenciaTrabalho.swift": 1,
    ]

    /// `try!` como token: `try` seguido de `!` e depois espaço ou não-`=`
    /// (para não confundir com nada). `try?` e `try` não contam.
    static let tryBang = #"\btry!"#

    static func porLinha(_ texto: String, _ padrao: Regex<AnyRegexOutput>) -> [(Int, String, Int)] {
        let visivel = PortaoDoMovimentoTests.codigoVisivel(texto, apagandoTema: false)
            .split(separator: "\n", omittingEmptySubsequences: false)
        var achados: [(Int, String, Int)] = []
        for n in visivel.indices {
            let quantos = visivel[n].matches(of: padrao).count
            guard quantos > 0 else { continue }
            achados.append((n + 1, visivel[n].trimmingCharacters(in: .whitespaces), quantos))
        }
        return achados
    }

    /// Sonda: o contra-veneno da lei de 08/09 ("verde que não visitou o lugar
    /// do defeito"). Duas que TÊM de acusar, duas que NÃO podem.
    @MainActor @Test func aVarreduraAindaEnxerga() throws {
        let padrao = try Regex(Self.tryBang)
        func conta(_ s: String) -> Int { Self.porLinha(s, padrao).reduce(0) { $0 + $1.2 } }
        #expect(conta("container = try! DiscoTraco.abrir(emTeste: emTeste)") > 0,
                "`try!` deixou de ser visto")
        #expect(conta("let rx = try! NSRegularExpression(pattern: p)") > 0,
                "`try!` numa linha de regex deixou de ser visto")
        #expect(conta("let c = try? ModelContainer.traco()\nlet d = try ModelContainer.traco()") == 0,
                "`try?` ou `try` viraram vermelhos")
        #expect(conta("// nunca escreva try! aqui\nlet s = \"try!\"") == 0,
                "comentário ou string virou vermelho")
    }

    @MainActor @Test func nenhumTryBangNovoNaProducao() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let fontes = PortaoDoMovimentoTests.fontes(raiz)
        // sem esta linha, um caminho errado deixaria a varredura vazia e VERDE
        #expect(fontes.count > 100, "a varredura não achou os fontes: \(fontes.count) arquivos")

        let padrao = try Regex(Self.tryBang)
        var contagem: [String: Int] = [:]
        var vistas: [String] = []
        for caminho in fontes {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            for (linha, codigo, quantos) in Self.porLinha(texto, padrao) {
                contagem[caminho, default: 0] += quantos
                vistas.append("\(caminho):\(linha): \(codigo)")
            }
        }
        // a lista congelada NÃO nasce vazia (8 casos medidos em 08/09), então
        // uma varredura que não vê nada é varredura cega, não repositório limpo.
        // Esta linha sai junto com o último item da lista.
        #expect(!vistas.isEmpty, "a varredura ficou cega: \(Self.faltosos.values.reduce(0,+)) `try!` estão congelados")

        // descer NUNCA é vermelho: quem conserta uma dívida não edita este teste
        var divergencias: [String] = []
        for caminho in Set(contagem.keys).union(Self.faltosos.keys).sorted() {
            let hoje = contagem[caminho] ?? 0
            let congelado = Self.faltosos[caminho] ?? 0
            guard hoje > congelado else { continue }
            divergencias.append("\(caminho): \(hoje) hoje, \(congelado) congelado  ← SUBIU")
        }
        #expect(divergencias.isEmpty, Comment(rawValue: """
            `try!` novo em produção:
            \(divergencias.joined(separator: "\n"))

            `try!` mata o processo no ponto de uso, longe de quem vê a tela
            morrer — foi assim que o arranque do Traço morria com o banco
            fechado (ADR 2026-09-08s). Escreva `try?` com estado tratado, ou
            `do/catch` com uma tela que diga o que houve, onde o conteúdo está
            e o próximo ato. Se for mesmo infalível por construção (regex
            literal), acrescente a linha na tabela de `faltosos` com o
            julgamento, e não sem ele.

            o que a varredura viu:
            \(vistas.joined(separator: "\n"))
            """))
    }
}

/// A PROVA DOS QUATRO — volta B1, ADR 2026-09-09o.
///
/// A §8 manda "cada uma com teste que reproduz **antes**". Fui atrás do dado
/// que faz cada uma das quatro "dívidas reais" explodir na mão do autor. Ele
/// não existe, e é isto que está medido aqui — o vermelho que faltou é achado,
/// não desculpa. O que a caça achou de verdade foi outra coisa, e pior: nos
/// dois `json(_ objeto: Any)` o `try!` guardava a porta errada.
///
/// O VERMELHO, medido fora da suíte porque não cabe dentro dela: uma exceção
/// do Objective-C não é capturável em Swift e mata o runner inteiro, então a
/// sonda foi um binário à parte (`swift sonda.swift`):
///
/// ```
/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException',
///     reason: 'Invalid number value (NaN) in JSON write'
/// *** Terminating app due to uncaught exception 'NSInvalidArgumentException',
///     reason: 'Invalid type in JSON write (__NSTaggedDate)'
/// ```
///
/// Isto acontece **por baixo** de `try!`, de `try?` e de `do/catch` igualmente:
/// `JSONSerialization.data(withJSONObject:)` não LANÇA com objeto inválido, ela
/// LEVANTA. Trocar `try!` por `try?` ali teria sido um verde que nunca visitou
/// o lugar do defeito. O guarda que funciona é `isValidJSONObject`.
@MainActor
struct AProvaDosQuatro {
    /// O pior que um autor consegue digitar e colar: NUL, controle, o não-caractere
    /// U+FFFF, emoji fora do plano básico, espaço de largura zero, os separadores
    /// de linha e parágrafo do Unicode, barra, aspas, a pontuação toda do JSON e
    /// um acento combinante solto no fim.
    static let feio = "\u{0}\u{1F}\u{FFFF}\u{1F600}\u{200B}\u{2028}\u{2029}\\\"{}[]:,\n\t— c\u{301}"

    /// `Traco/Analise/FonteNotas.swift` — o objeto é montado em runtime, mas só
    /// com `String`, `Int`, array e dicionário. Não há título nem linha de nota
    /// que o derrube: o texto mais feio entra inteiro e o esquema sai válido.
    @Test func oPromptDasNotasSobreviveAoTextoMaisFeioDoAutor() throws {
        let f = FonteNotas(id: UUID(), titulo: Self.feio, texto: "\(Self.feio)\nsegunda linha",
                           editadaEm: Date(timeIntervalSince1970: 0))
        let p = try #require(RespostaNotas.montar(
            pergunta: Self.feio, fontes: [f],
            conversa: [.init(pergunta: Self.feio, resposta: Self.feio)],
            catalogo: Self.feio, retrato: Self.feio, teto: 40_000))
        #expect(p.fontes.count == 1)
        #expect(p.omitidas == 0)
        let esquema = try #require(try JSONSerialization.jsonObject(
            with: Data(RespostaNotas.esquemaRemoto(p).utf8)) as? [String: Any])
        // se o guarda tivesse caído no `"{}"`, esta chave não existiria
        #expect(esquema["additionalProperties"] as? Bool == false)
    }

    /// `Traco/Trabalho/PraticaTrabalho.swift` — mesmo helper, mesma prova: a
    /// tentativa da pessoa vira `[String]` e nenhum caractere dela é inválido.
    @Test func aTentativaMaisFeiaSerializaSemPerderLinha() throws {
        let linhas = PraticaTrabalho.segmentos("\(Self.feio)\n\(Self.feio)").map(\.texto)
        let saida = PraticaTrabalho.json(linhas)
        let volta = try #require(try JSONSerialization.jsonObject(with: Data(saida.utf8)) as? [String])
        #expect(volta == linhas)
    }

    /// `Traco/Notas/Corpus.swift` — o `encode` é de um `String` (`campos` é
    /// `[String: String]`) e o `!` do dicionário está coberto pelo filtro
    /// `f.campos[$0] != nil` três linhas acima. A prova é a ida e a volta: o
    /// campo mais feio, com chave conhecida e chave que o catálogo não conhece,
    /// volta idêntico.
    @Test func oCampoMaisFeioVoltaIdenticoDoBackup() throws {
        let campos = ["obstaculo": Self.feio, "chave-que-o-catalogo-nao-conhece": Self.feio]
        let md = Corpus.arquivoMd(texto: Self.feio, gesto: .woop, campos: campos,
                                  criadaEm: Date(timeIntervalSince1970: 0))
        let item = try #require(Corpus.importar(md).first)
        #expect(Corpus.separarCampos(texto: item.texto, gesto: .woop).campos == campos)
    }

    /// `Traco/App/Sessao.swift` — `JSONEncoder().encode([String])`. `[String]`
    /// é sempre um JSON válido e `String` do Swift é sempre UTF-8 válido: não
    /// existe nota que derrube a assinatura, e ela continua distinguindo edição.
    @Test func aAssinaturaDaNotaAceitaOTextoMaisFeio() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let n = Nota(texto: Self.feio)
        n.sentido = Self.feio
        c.mainContext.insert(n)
        try c.mainContext.save()
        let antes = try #require(Sessao.fonteParaPergunta(n))
        #expect(antes.assinatura?.count == 64)
        n.texto = Self.feio + "!"
        let depois = try #require(Sessao.fonteParaPergunta(n))
        #expect(antes.assinatura != depois.assinatura)
    }

    /// O ACHADO DA CAÇA, e o verde do vermelho colado no cabeçalho: com objeto
    /// inválido o `JSONSerialization` não devolve erro — `isValidJSONObject` é
    /// o único jeito de saber antes, e agora os dois helpers perguntam. O que
    /// era morte do processo virou esquema vazio, e esquema vazio derruba a
    /// leitura da resposta, que é a recusa que o Traço já sabe dizer.
    @Test func oGuardaDoJsonEOIsValidJSONObjectENaoOTry() {
        #expect(!JSONSerialization.isValidJSONObject(["a": Double.nan]))
        #expect(!JSONSerialization.isValidJSONObject(["a": Date()]))
        #expect(!JSONSerialization.isValidJSONObject("texto solto no topo"))
        #expect(RespostaNotas.json(["a": Double.nan]) == "{}")
        #expect(PraticaTrabalho.json(["a": Date()]) == "{}")
        // e o caminho bom continua bom, com as chaves ordenadas
        #expect(RespostaNotas.json(["b": "x", "a": 1] as [String: Any]) == #"{"a":1,"b":"x"}"#)
        #expect(PraticaTrabalho.json([Self.feio]) != "{}")
    }

    /// A QUINTA, que a A1 nomeou e ninguém guardava.
    ///
    /// `ConferenciaTrabalho.regex(_:)` faz `try! Regex("(?i)" + padrao)`. É
    /// infalível **só enquanto todo chamador passar um literal do próprio
    /// arquivo** — no dia em que alguém passar um padrão vindo do documento, do
    /// pedido ou da IA, um `[` sem par mata o app dentro da conferência. É a
    /// dívida que ainda não é dívida, e é barata de guardar agora: este teste
    /// fica vermelho no commit que a criar, não no relatório de crash.
    @Test func aConferenciaSoAceitaPadraoLiteralDoProprioArquivo() throws {
        let caminho = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Traco/Trabalho/ConferenciaTrabalho.swift")
        let texto = PortaoDoMovimentoTests.codigoVisivel(
            try String(contentsOf: caminho, encoding: .utf8), apagandoTema: false)

        // os literais que o próprio arquivo declara. `codigoVisivel` apaga o
        // conteúdo da string crua mas conserva o `#` que a abre, e é por ele
        // que se reconhece a declaração depois da varredura.
        let literais = Set(texto.matches(of: try Regex(#"private static let (\w+) = #"#))
            .map { String($0.output[1].substring ?? "") })
        #expect(literais.contains("marcaDeTempo"), "os literais de padrão sumiram: \(literais)")

        // todo argumento que chega a `regex(...)`; a linha da declaração traz
        // `_ padrao: String` e é a única com `:`, então sai por aí
        let usados = texto.matches(of: try Regex(#"\bregex\(([^()]*)\)"#))
            .map { String($0.output[1].substring ?? "") }
            .filter { !$0.contains(":") }
        #expect(usados.count >= 4, "a varredura ficou cega: \(usados.count) chamadas de regex(")

        let deFora = usados.filter { !literais.contains($0) }.sorted()
        #expect(deFora.isEmpty, Comment(rawValue: """
            padrão que NÃO é literal deste arquivo chegando a `regex(_:)`:
            \(deFora.joined(separator: "\n"))

            `regex(_:)` é `try! Regex(...)`: com padrão vindo do documento, do
            pedido ou da resposta da IA, um `[` sem par mata o app no meio da
            conferência. Se o padrão passou a vir de fora, o `try!` tem de sair
            junto — `try?` e o critério que não se lê, em vez do processo morto.
            """))
    }
}
