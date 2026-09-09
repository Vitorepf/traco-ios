import Foundation
import Testing
@testable import Traco

/// O PORTÃO DA ROTA QUE CALA — volta B2, ADR 2026-09-09q.
///
/// `Politica.semProvedor` tem uma frase para CADA uma das dezesseis operações,
/// e `PoliticaTests` já guardava que nenhuma está vazia. O que ninguém guardava
/// é se alguma TELA a mostra. A auditoria desta volta contou: dezesseis frases
/// escritas, seis mostradas. As outras dez eram motor sem superfície — e três
/// delas estavam justamente nas rotas em que o autor toca um botão:
///
/// - **Lente · Instigar e Contrapor.** As duas são `indisponivelPorQualidade`
///   desde a 08q, mas a Lente perguntava a `Sabia.disponivel` — que responde
///   "sim" com a conta ligada. O laço girava, `Sabia.chamar` batia em `nil` na
///   primeira linha, e o autor recebia uma VIBRAÇÃO. Nada na tela.
/// - **Caderno · Perguntar à sábia.** `responder` também não tem executor, e o
///   toast dizia "a sábia não respondeu. tente de novo." — convite a repetir o
///   que nunca vai dar certo.
///
/// O portão tem duas metades. A primeira prende o contrato de `Politica.aviso`
/// (uma linha: quem não tem provedor tem frase). A segunda é a **tabela
/// congelada** de quem MOSTRA a frase, no espírito do `PortaoDoTryBangTests`:
/// tirar uma superfície fica vermelho, e operação nova sem superfície nasce
/// vermelha, com o julgamento escrito ao lado.
struct PortaoDaRotaQueCalaTests {

    // MARK: o contrato de uma linha

    /// `aviso` é `semProvedor` exatamente quando ninguém responde. Se um dia
    /// devolver `nil` com a tabela dizendo que não há executor, toda rota
    /// consertada nesta volta volta a calar de uma vez só.
    @Test func avisoEhAFraseExatamenteQuandoNinguemResponde() {
        for op in Politica.Operacao.allCases {
            for conta in [true, false] {
                for bordo in [true, false] {
                    let quem = Politica.provedor(op, contaLigada: conta, bordo: bordo)
                    let frase = Politica.aviso(op, contaLigada: conta, bordo: bordo)
                    if quem == nil {
                        #expect(frase == Politica.semProvedor(op),
                                "\(op) sem provedor (conta \(conta), bordo \(bordo)) e sem frase")
                        #expect(frase?.isEmpty == false)
                    } else {
                        #expect(frase == nil,
                                "\(op) tem \(quem!) e mesmo assim mandou a tela avisar")
                    }
                }
            }
        }
    }

    /// A conta ligada NÃO desfaz o corte por qualidade. É o caso exato do
    /// defeito: a Lente perguntava a `Sabia.disponivel` (que é `true` aqui) e
    /// concluía que podia chamar.
    @Test func contaLigadaNaoRessuscitaOperacaoCortadaPorQualidade() {
        for op in Politica.indisponiveis {
            #expect(Politica.provedor(op, contaLigada: true, bordo: true) == nil,
                    "\(op) voltou a ter executor sem passar pela medida")
            #expect(Politica.aviso(op, contaLigada: true, bordo: true) != nil,
                    "\(op) está indisponível e a tela não tem o que dizer")
        }
        #expect(Politica.aviso(.instigar, contaLigada: true, bordo: true) != nil)
        #expect(Politica.aviso(.contrapor, contaLigada: true, bordo: true) != nil)
        #expect(Politica.aviso(.responder, contaLigada: true, bordo: true) != nil)
    }

    // MARK: a tabela congelada de quem MOSTRA

    /// Onde cada operação diz ao autor, no ponto em que ele tocou, que ninguém
    /// vai responder. O valor é o trecho de código que a varredura procura.
    ///
    /// | operação | superfície |
    /// |---|---|
    /// | `produzir` | `OficinaTrabalho` põe a frase em `erro`, com o pedido guardado |
    /// | `prepararPratica`, `conferirTentativa` | `PraticaTrabalho.semProvedor`, a mesma frase por constante |
    /// | `revisar` | `TrabalhoView` pela `RevisaoTrabalho.oferta()`, que devolve a frase no lugar do botão |
    /// | `conferir` | `RecordarView`, `LinhaDeEstado` na fase de revelar |
    /// | `ecos` | `RedeView` |
    /// | `calibragem` | `PadroesView` |
    /// | `responder` | `Sessao.perguntarASabia` — **entrou na B2** |
    /// | `instigar`, `contrapor` | `LenteView` — **entraram na B2** |
    static let mostram: [Politica.Operacao: String] = [
        .produzir: "Politica.semProvedor(.produzir)",
        .prepararPratica: "PraticaTrabalho.semProvedor",
        .conferirTentativa: "PraticaTrabalho.semProvedor",
        .revisar: "RevisaoTrabalho.oferta(",
        .conferir: "Politica.semProvedor(.conferir)",
        .ecos: "Politica.semProvedor(.ecos)",
        .calibragem: "Politica.semProvedor(.calibragem)",
        .responder: "Politica.aviso(.responder)",
        .instigar: "Politica.aviso(.instigar)",
        .contrapor: "Politica.aviso(.contrapor)",
    ]

    /// As SEIS que continuam sem frase no ponto de uso, com o julgamento —
    /// como o `PortaoDoTryBang` faz com os `try!` que ficaram. Cinco não
    /// causam dano; UMA é dívida nomeada.
    ///
    /// | operação | julgamento |
    /// |---|---|
    /// | `responderNasNotas` | **DÍVIDA REAL** (RUMO, frente das Notas): `NotasView` diz "a sábia não respondeu.", com "Repetir" ao lado, para uma operação que a 08q cortou. Mesmo defeito que a `responder` tinha; fica de fora da B2 porque a tela das Notas é da frente de design D1, que a está reescrevendo. |
    /// | `recordar` | sem dano: o ritual segue com a pergunta fixa e nada foi prometido (`pedirPergunta`: "Silêncio em qualquer falha"). |
    /// | `padroes` | sem dano: `PadroesView` faz `remotas ?? locais` — o autor vê perguntas de qualquer jeito. |
    /// | `vestir` | a rota diz por frase própria: "nada a vestir aqui." e "a sábia não respondeu. o texto ficou como estava." (B2). |
    /// | `classificar`, `dominio` | rotas AUTOMÁTICAS, sem gesto do autor. §17: no modo automático o silêncio é invisível, e um toast a cada pausa seria ruído. |
    static let calam: Set<Politica.Operacao> =
        [.responderNasNotas, .recordar, .padroes, .vestir, .classificar, .dominio]

    private static func fontesVisiveis() throws -> [String: String] {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        var saida: [String: String] = [:]
        for caminho in PortaoDoMovimentoTests.fontes(raiz) where caminho != "Traco/Analise/Politica.swift" {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            saida[caminho] = PortaoDoMovimentoTests.codigoVisivel(texto, apagandoTema: false)
        }
        return saida
    }

    /// A lista congelada nasce de uma varredura; se a varredura parar de
    /// enxergar, tudo fica "sem superfície" e o teste acusaria o mundo inteiro
    /// — mas se ela passasse a ver de mais, ficaria verde à toa. Estas duas
    /// sondas medem os dois sentidos pelo mesmo caminho dos fontes.
    @Test func aVarreduraAindaEnxerga() throws {
        let fontes = try Self.fontesVisiveis()
        #expect(fontes.count > 100, "a varredura não achou os fontes: \(fontes.count) arquivos")
        #expect(fontes["Traco/Analise/Politica.swift"] == nil, "a declaração entrou na varredura")
        let visivel = PortaoDoMovimentoTests.codigoVisivel(
            "// Politica.aviso(.recordar)\nlet s = \"Politica.aviso(.padroes)\"\nPolitica.aviso(.ecos)",
            apagandoTema: false)
        #expect(!visivel.contains("Politica.aviso(.recordar)"), "comentário virou superfície")
        #expect(!visivel.contains("Politica.aviso(.padroes)"), "string virou superfície")
        #expect(visivel.contains("Politica.aviso(.ecos)"), "código deixou de ser visto")
    }

    @Test func nenhumaOperacaoPerdeuASuaSuperficie() throws {
        let fontes = try Self.fontesVisiveis()
        var semSuperficie: [String] = []
        for (op, trecho) in Self.mostram {
            let onde = fontes.filter { $0.value.contains(trecho) }.keys.sorted()
            if onde.isEmpty { semSuperficie.append("\(op) — nenhuma tela mostra `\(trecho)`") }
        }
        let lista = semSuperficie.joined(separator: "\n")
        #expect(semSuperficie.isEmpty, "rota que voltou a calar:\n\(lista)")
    }

    /// Operação nova sem superfície nasce VERMELHA, e ganhar uma superfície
    /// também acusa — para que a tabela de julgamentos acima acompanhe.
    @Test func aTabelaDeSuperficiesCobreAsDezesseis() {
        let cobertas = Set(Self.mostram.keys).union(Self.calam)
        #expect(cobertas == Set(Politica.Operacao.allCases),
                "operação fora da tabela: \(Set(Politica.Operacao.allCases).subtracting(cobertas))")
        #expect(Set(Self.mostram.keys).isDisjoint(with: Self.calam))
        #expect(Self.mostram.count == 10 && Self.calam.count == 6,
                "a conta da B2 era 10 com superfície e 6 sem; mudou sem passar pelo julgamento")
    }
}
