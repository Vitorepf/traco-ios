import Foundation
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
    /// **9 em `main`, 8 no candidato** (`TracoApp.swift:13` saiu), e as 8 linhas
    /// que ele imprime são exatamente as da tabela abaixo. O portão não usa esse
    /// filtro de uma linha: usa `codigoVisivel`, que apaga comentário E string
    /// antes de contar, e chega ao mesmo 8 — o filtro acima é a versão que
    /// qualquer um roda sem compilar nada.
    /// Duas colunas de julgamento, porque distinguir os dois é metade do valor
    /// da volta: **infalível por construção** (literal que o compilador não
    /// verifica mas o autor sim) versus **dívida real** (pode falhar com dado
    /// de fora e mata o app).
    ///
    /// | arquivo | n | julgamento |
    /// |---|---|---|
    /// | `Traco/Analise/FonteNotas.swift` | 1 | **dívida real** — `JSONSerialization.data` sobre objeto montado em runtime; volta Q, viva |
    /// | `Traco/App/Sessao.swift` | 1 | **dívida real** — `JSONEncoder().encode([String])` do texto do autor; codificar `[String]` não falha na prática, mas o valor vem de fora |
    /// | `Traco/Caderno/AnexoDisco.swift` | 1 | **infalível por construção** — `NSRegularExpression` de padrão literal |
    /// | `Traco/Trabalho/ConferenciaTrabalho.swift` | 1 | **infalível por construção** — `Regex` de padrão literal, mas o padrão chega por argumento: infalível só enquanto todos os chamadores forem literais; volta E1, viva |
    /// | `Traco/Trabalho/PraticaTrabalho.swift` | 1 | **dívida real** — igual ao `FonteNotas`; volta E1, viva |
    /// | `Traco/Notas/Corpus.swift` | 2 | linha 144 **dívida real** (`encode` de campo do autor, com `!` no dicionário logo ao lado); linha 277 **infalível por construção** (regex literal) |
    /// | `Traco/Notas/Indice.swift` | 1 | **infalível por construção** — `NSRegularExpression` de padrão literal |
    ///
    /// As quatro dívidas reais foram ao RUMO. NÃO se conserta nada disto nesta
    /// volta: `Analise` é da volta Q e `Trabalho` é da volta E1, as duas vivas —
    /// e mexer na área de outra volta é falha, não zelo.
    static let faltosos: [String: Int] = [
        "Traco/Analise/FonteNotas.swift": 1,
        "Traco/App/Sessao.swift": 1,
        "Traco/Caderno/AnexoDisco.swift": 1,
        "Traco/Notas/Corpus.swift": 2,
        "Traco/Notas/Indice.swift": 1,
        "Traco/Trabalho/ConferenciaTrabalho.swift": 1,
        "Traco/Trabalho/PraticaTrabalho.swift": 1,
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
        #expect(!vistas.isEmpty, "a varredura ficou cega: 8 `try!` estavam congelados")

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
