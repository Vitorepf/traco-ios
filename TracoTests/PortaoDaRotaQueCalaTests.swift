import Foundation
import SwiftData
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
    /// | `responderNasNotas` | sem dano agora: a rota VOLTOU em 10/09 (`soGrok`). Sem conta a folha diz `Sabia.porOndeEmPalavras`; falha usa `Grok.avisoDaFalha` (timeout, cancelar, limite, recusa). O "Repetir" é da rota viva, não de uma operação cortada. |
    /// | `recordar` | sem dano: o ritual segue com a pergunta fixa e nada foi prometido (`pedirPergunta`: "Silêncio em qualquer falha"). |
    /// | `padroes` | sem dano: `PadroesView` faz `remotas ?? locais` — o autor vê perguntas de qualquer jeito. |
    /// | `vestir` | a rota diz por frase própria: "nada a vestir aqui." e "a sábia não respondeu. o texto ficou como estava." (B2). |
    /// | `classificar`, `dominio` | rotas AUTOMÁTICAS, sem gesto do autor. §17: no modo automático o silêncio é invisível, e um toast a cada pausa seria ruído. |
    static let calam: Set<Politica.Operacao> =
        [.responderNasNotas, .recordar, .padroes, .vestir, .classificar, .dominio,
         // ADR 2026-09-16g: roda sozinha ao concluir e registra em sombra — não há tela a avisar
         .escolherRegra]

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
        #expect(Self.mostram.count == 10 && Self.calam.count == 7,
                "a conta da B2 era 10 com superfície e 6 sem; mudou sem passar pelo julgamento")
    }

    /// Superfície (Lente, Rede) não cobre o disparo automático. Abrir a forma
    /// e montar o contexto da Página tinham o mesmo defeito da B2: olhavam
    /// `Sabia.disponivel` / seguiam em frente e `chamar` calava sem rede.
    @Test func aFormaAbertaNaoDisparaInstigarCortado() throws {
        let trecho = try Self.trechoEmSessao(apos: "func instigarSobreAForma")
        #expect(trecho.contains("guard Politica.aviso(.instigar) == nil else { return }"),
                "a forma aberta não consulta a Politica")
        let aviso = try #require(trecho.range(of: "Politica.aviso(.instigar)"))
        let chamada = try #require(trecho.range(of: "Sabia.instigar("),
                                   "o trecho não achou a chamada — a varredura parou de enxergar")
        #expect(aviso.lowerBound < chamada.lowerBound,
                "a forma aberta chama instigar sem olhar a Politica")
        #expect(!trecho.contains("Politica.aviso(.recordar)"),
                "a varredura passou a ver comentário como portão")
    }

    @Test func oContextoDoCadernoNaoDisparaEcosCortado() throws {
        let trecho = try Self.trechoEmSessao(apos: "func contextoDoCaderno")
        #expect(trecho.contains("guard Politica.provedor(.ecos) != nil else {"),
                "o contexto da Página não consulta a Politica")
        let porta = try #require(trecho.range(of: "Politica.provedor(.ecos)"))
        let chamada = try #require(trecho.range(of: "Sabia.ecos("),
                                   "o trecho não achou a chamada — a varredura parou de enxergar")
        #expect(porta.lowerBound < chamada.lowerBound,
                "o contexto da Página chama ecos sem olhar a Politica")
        #expect(trecho.contains("notasLidasNaPergunta = 0"),
                "sem ecos a divulgação ainda conta candidatas que ninguém leu")
        #expect(!trecho.contains("Politica.provedor(.recordar)"),
                "a varredura passou a ver um portão que não está neste trecho")
    }

    /// Sem índice, as outras notas do caderno ainda seriam candidatas a eco
    /// (`ordem.isEmpty`). O código velho gravava essa conta e chamava a rota
    /// cortada; o novo zera a divulgação e devolve só ligações e vizinhas.
    @Test func semEcosADivulgacaoNaoContaCandidatasNaoLidas() async throws {
        #expect(Politica.provedor(.ecos) == nil, "ecos voltou sem remedição")
        let c = try ModelContainer.traco(emMemoria: true)
        c.mainContext.insert(Nota(texto: "Vizinha um\n\nprosa longa o bastante para o caderno"))
        c.mainContext.insert(Nota(texto: "Vizinha dois\n\noutra prosa que o eco local enxergaria"))
        let s = Sessao()
        s.texto = "minha página atual com prosa suficiente"
        s.notasLidasNaPergunta = 99
        let saida = await s.contextoDoCaderno(no: c.mainContext, pergunta: "qual o prazo?")
        #expect(s.notasLidasNaPergunta == 0,
                "sem ecos ainda conta \(s.notasLidasNaPergunta) candidatas")
        #expect(saida.allSatisfy { !$0.titulo.hasPrefix("Vizinha") },
                "eco cortado ainda embutiu nota que ninguém escolheu")
    }

    private static func trechoEmSessao(apos marca: String) throws -> String {
        let fonte = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Traco/App/Sessao.swift")
        let texto = try String(contentsOf: fonte, encoding: .utf8)
        let visivel = PortaoDoMovimentoTests.codigoVisivel(texto, apagandoTema: false)
        guard let inicio = visivel.range(of: marca) else { return "" }
        let depois = visivel[inicio.lowerBound...]
        guard let fim = depois.range(of: "\n    func ") else { return String(depois.prefix(2400)) }
        return String(depois[..<fim.lowerBound])
    }
}
