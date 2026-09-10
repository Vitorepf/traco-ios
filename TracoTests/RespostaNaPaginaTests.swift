import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-10b — a linha "?" da nota: o que viaja, o que volta, e a quem.
///
/// O corpo de `Sessao.perguntarASabia` nunca tinha sido exercitado pela suíte
/// (sem conta e com `Motores.desligados`, toda chamada parava na primeira
/// linha), e é exatamente ali que estavam os três defeitos que esta volta
/// fecha: a resposta que publica na pergunta errada, a divulgação que nomeia
/// notas que não viajaram, e a falha que some com a pergunta junto.
@MainActor
struct RespostaNaPaginaTests {
    private func caderno() throws -> ModelContainer { try ModelContainer.traco(emMemoria: true) }

    private func sessaoComPergunta(_ q: String = "? Qual é o prazo?") -> Sessao {
        let s = Sessao()
        s.texto = "Rascunho da proposta.\n\(q)"
        return s
    }

    // MARK: o contexto que viaja, e a divulgação que corresponde

    /// A divulgação era montada da lista INTEIRA de vizinhas, antes do corte —
    /// e o corte é o `prefix` de `Sabia.responder`. Com o caderno cheio, o
    /// cartão nomeava ao autor uma nota que nunca saiu do aparelho.
    @Test func aDivulgacaoNomeiaSoAsVizinhasQueCouberam() {
        let pagina = String(repeating: "a", count: 4_000)
        let cabe = (titulo: "Cabe", prosa: String(repeating: "b", count: 500))
        let naoCabe = (titulo: "Não cabe", prosa: String(repeating: "c", count: 900))
        let r = Sabia.contextoDaPergunta(pagina: pagina, vizinhas: [cabe, naoCabe])
        #expect(r.viajaram == ["Cabe"])
        #expect(r.contexto.contains("outra nota sua, escrita em outro dia"))
        #expect(r.contexto.contains("Cabe ---"))
        // ADR 10g: a PROSA da que não coube continua em casa — o que muda é
        // que o nome dela agora é dito, no bloco do que não se leu.
        #expect(!r.contexto.contains(String(repeating: "c", count: 20)))
        #expect(r.contexto.count <= Sabia.tetoDoContextoDaNota)
    }

    // MARK: ADR 10g — o que não coube se DIZ, e o que coube não se nega

    /// A metade que fecha a simetria (ordem do dono, 10/09 13h55): *"li as duas
    /// primeiras páginas e não o resto" é resposta; "vá ao sumário" é invenção*.
    /// Antes, a nota que não cabia sumia em silêncio e o modelo completava o
    /// resto de cabeça — não porque mente, mas porque nada dizia que faltava.
    @Test func aNotaQueNaoCoubeEDITAPELONOME() {
        let pagina = String(repeating: "a", count: 4_000)
        let r = Sabia.contextoDaPergunta(pagina: pagina,
                                         vizinhas: [(titulo: "Relatório de setembro",
                                                     prosa: String(repeating: "c", count: 4_000))])
        #expect(r.contexto.contains("O QUE NÃO COUBE"))
        #expect(r.contexto.contains("Relatório de setembro"))
        #expect(r.contexto.count <= Sabia.tetoDoContextoDaNota)
    }

    /// O RISCO que a alavanca cria, e a irmã que não acusa: quando tudo cabe,
    /// não há uma palavra sobre não ter lido. Uma guarda que só sabe acusar
    /// não está provada — esta é a que tem de ficar calada.
    @Test func quandoTudoCabeNadaSeDizSobreNaoTerLido() {
        let r = Sabia.contextoDaPergunta(pagina: "a minha página",
                                         vizinhas: [(titulo: "A", prosa: "um"),
                                                    (titulo: "B", prosa: "dois")])
        #expect(r.viajaram == ["A", "B"])
        #expect(!r.contexto.contains("NÃO COUBE"))
        #expect(!r.contexto.lowercased().contains("não leu"))
    }

    /// Meia nota entra — mas dizendo quanto entrou. Abaixo do mínimo ela fica
    /// de fora inteira, porque três linhas soltas de um documento é o convite
    /// exato para o modelo completar o resto.
    @Test func aNotaGrandeEntraPELAMETADEEDIZQUANTO() {
        let r = Sabia.contextoDaPergunta(pagina: "curta",
                                         vizinhas: [(titulo: "Doc", prosa: String(repeating: "d", count: 9_000))])
        #expect(r.viajaram == ["Doc"])
        #expect(r.contexto.contains("você leu os primeiros"))
        #expect(r.contexto.contains("de 9000 caracteres"))
        #expect(r.contexto.count <= Sabia.tetoDoContextoDaNota)
    }

    /// A invariante do orçamento sobrevive ao pior caso: o aviso tem de CABER,
    /// senão o `prefix(teto)` de `Sabia.responder` o corta justamente na
    /// corrida em que ele é a resposta.
    @Test func oAvisoCabeNoOrcamentoNoPiorCaso() {
        let vizinhas = (1...40).map { (titulo: "Nota \($0) " + String(repeating: "t", count: 80),
                                       prosa: String(repeating: "x", count: 3_000)) }
        let r = Sabia.contextoDaPergunta(pagina: String(repeating: "a", count: 4_900), vizinhas: vizinhas)
        #expect(r.contexto.count <= Sabia.tetoDoContextoDaNota)
        #expect(r.contexto.contains("O QUE NÃO COUBE"))
        #expect(r.contexto.hasSuffix("."))
    }

    /// A página também é texto do autor: quando ela sozinha estoura, o corte
    /// dela se declara em vez de acontecer em silêncio dentro de `responder`.
    @Test func aPaginaCortadaSeDECLARA() {
        let r = Sabia.contextoDaPergunta(pagina: String(repeating: "a", count: 12_000),
                                         vizinhas: [(titulo: "A", prosa: "um")])
        #expect(r.contexto.contains("A sua própria página"))
        #expect(r.contexto.count <= Sabia.tetoDoContextoDaNota)
    }

    /// O INSTRUMENTO tambem se mede. O braço `antigo` da medida da 10g existe
    /// para reproduzir o caminho INTEIRO de antes, e o corte aos 1.200 morava
    /// em `Sessao.notasLigadas` — fora desta função. Sem esta guarda o braço
    /// velho jogava a nota fora por não caber e media uma TERCEIRA montagem,
    /// que nunca rodou para autor nenhum. Custou uma janela de aparelho de
    /// conta em 10/09 para eu descobrir isso lendo o JSONL.
    @Test func oBracoAntigoReproduzOCorteAos1200() {
        let doc = String(repeating: "z", count: 9_000)
        let velho = Sabia.contextoDaPerguntaComoEraNa10b(pagina: "curta",
                                                         vizinhas: [(titulo: "Doc", prosa: doc)])
        #expect(velho.viajaram == ["Doc"])
        #expect(velho.contexto.count < 1_400)
        #expect(!velho.contexto.contains("O QUE NÃO COUBE"))
        // e a irmã: o braço NOVO manda muito mais do mesmo documento
        let novo = Sabia.contextoDaPergunta(pagina: "curta", vizinhas: [(titulo: "Doc", prosa: doc)])
        #expect(novo.contexto.count > 4_000)
    }

    @Test func todasCabemQuandoOCadernoEPequeno() {
        let r = Sabia.contextoDaPergunta(pagina: "página", vizinhas: [(titulo: "A", prosa: "um"),
                                                                     (titulo: "B", prosa: "dois")])
        #expect(r.viajaram == ["A", "B"])
    }

    // MARK: a resposta chega inteira

    /// A ADR 04r cortava aos 900 com "…", e a parte que morria era a última —
    /// que é onde mora a ressalva. Quatro das 54 execuções do `grok-4.5` na
    /// Q2-F passaram dos 900 (`prova/q2f-modelo-45.jsonl`).
    @Test func aRespostaLongaChegaInteiraComARessalvaDoFim() throws {
        let ressalva = "Confirme a cotação no banco antes de pagar."
        let longa = String(repeating: "detalhe da conta. ", count: 60) + ressalva
        #expect(longa.count > Sabia.tetoResposta)
        let limpa = try #require(Sabia.limparResposta("**" + longa))
        #expect(limpa.hasSuffix(ressalva))
        #expect(!limpa.hasSuffix("…"))
        #expect(limpa.count == longa.count)
    }

    @Test func aLimpezaDeMarkdownEODescarteDoVazioFicam() {
        #expect(Sabia.limparResposta("## Título\n**forte**") == "Título\nforte")
        #expect(Sabia.limparResposta("   \n  ") == nil)
    }

    // MARK: a resposta pertence à pergunta que a pediu

    /// Iniciar A, cancelar, iniciar B, e A voltar atrasada. O guarda antigo
    /// exigia só ALGUM `.sabiaPensando` — e "algum" inclui a pergunta seguinte.
    @Test func retornoAtrasadoDeAnaoPublicaNaPerguntaDeB() async throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Pergunta A")
        let liberarA = Sinalizador(), liberarB = Sinalizador()
        s.responderNaPagina = { pergunta, _, _, _ in
            if pergunta == "Pergunta A" { await liberarA.esperar(); return "resposta de A" }
            await liberarB.esperar()
            return "resposta de B"
        }
        let tarefaA = s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)
        s.pararDeEsperarASabia()
        s.texto = "Rascunho da proposta.\n? Pergunta B"
        let tarefaB = s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)
        // A volta ENQUANTO B ainda pensa: é aqui que o guarda antigo cedia —
        // "algum `.sabiaPensando`" era o de B, e a resposta de A publicava nele.
        await liberarA.liberar()
        await tarefaA?.value
        #expect(s.cartao == .sabiaPensando(pergunta: "Pergunta B", desde: inicioDeB(s)))
        await liberarB.liberar()
        await tarefaB?.value
        #expect(s.cartao == .resposta(pergunta: "Pergunta B", texto: "resposta de B"))
    }

    /// A hora do cartão em voo, para comparar o caso inteiro sem depender do relógio.
    private func inicioDeB(_ s: Sessao) -> Date {
        if case .sabiaPensando(_, let desde)? = s.cartao { return desde }
        return .distantPast
    }

    /// A página se lê JUNTO da pergunta, não depois do await: com o teto do
    /// modelo em minutos, abrir outra nota durante a espera deixou de ser
    /// hipótese. O contexto enviado é o da nota que fez a pergunta.
    @Test func oContextoEODaNotaQuePerguntou() async throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Qual é o prazo?")
        s.texto = "A proposta vence dia 12.\n? Qual é o prazo?"
        let visto = Caixa()
        s.responderNaPagina = { _, contexto, _, _ in
            await visto.guardar(contexto)
            return "12 de setembro."
        }
        let tarefa = s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)
        s.texto = "Outra nota, outro assunto inteiramente."
        await tarefa?.value
        let contexto = await visto.valor
        #expect(contexto?.contains("A proposta vence dia 12.") == true)
        #expect(contexto?.contains("outro assunto inteiramente") == false)
    }

    // MARK: a falha fica junto da pergunta

    /// Era `cartao = nil` mais um toast que passa: depois de minutos de espera
    /// o autor voltava à página sem cartão e sem caminho de volta.
    @Test func aFalhaDeixaAPerguntaNoCartaoComRecuperacao() async throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Qual é o prazo?")
        s.responderNaPagina = { _, _, _, _ in nil }
        await s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)?.value
        #expect(s.cartao == .pergunta("Qual é o prazo?"))
        #expect(s.notasNaPergunta.isEmpty)
        // o cartão da pergunta é o que traz "Perguntar à sábia" de volta
        #expect(!CartaoAnaliseView.podeRecolher(.sabiaPensando(pergunta: "q", desde: .now)))
    }

    /// Selar uma fonte durante o `await` revoga o que ela emprestou: a resposta
    /// derivada dela não chega à tela. Mesma guarda do `responderNasNotas`.
    @Test func fonteSeladaDuranteAEsperaNaoPublicaAResposta() async throws {
        let c = try caderno()
        let vizinha = Nota(texto: "O prazo combinado é 12/09.")
        c.mainContext.insert(vizinha)
        try c.mainContext.save()
        let s = Sessao()
        s.texto = "Rascunho ligado a [[\(vizinha.tituloNaLista)]].\n? Qual é o prazo?"
        s.responderNaPagina = { _, _, _, _ in
            vizinha.trancada = true
            return "O prazo é 12/09."
        }
        await s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)?.value
        #expect(s.cartao == .pergunta("Qual é o prazo?"))
        #expect(s.notasNaPergunta.isEmpty)
    }

    /// A vizinha que sustentou o contexto é uma FONTE com assinatura — sem
    /// isto a revalidação não teria o que comparar e passaria sempre.
    @Test func aVizinhaLigadaViraFonteComAssinatura() throws {
        let c = try caderno()
        let vizinha = Nota(texto: "O prazo combinado é 12/09.")
        c.mainContext.insert(vizinha)
        try c.mainContext.save()
        let s = Sessao()
        s.texto = "Rascunho ligado a [[\(vizinha.tituloNaLista)]]."
        let ligadas = s.notasLigadas(no: c.mainContext)
        #expect(ligadas.map(\.uuid) == [vizinha.uuid])
        let fontes = s.fontesDoContexto(ligadas, no: c.mainContext)
        #expect(fontes.map(\.id) == [vizinha.uuid])
        #expect(Sessao.dependenciasValidas(fontes, no: c.mainContext))
        vizinha.texto = "O prazo mudou para 15/09."
        #expect(!Sessao.dependenciasValidas(fontes, no: c.mainContext))
    }

    // MARK: autoria

    /// A resposta vai para o CARTÃO, nunca para a nota (ADR 02o). Nem a
    /// pergunta, nem a resposta, nem a falha tocam no texto do autor.
    @Test func aNotaNaoMudaAntesNemDepoisDaResposta() async throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Qual é o prazo?")
        let antes = s.texto
        s.responderNaPagina = { _, _, _, _ in "O prazo é 12/09." }
        let tarefa = s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)
        #expect(s.texto == antes)
        await tarefa?.value
        #expect(s.texto == antes)
        #expect(s.cartao == .resposta(pergunta: "Qual é o prazo?", texto: "O prazo é 12/09."))
    }

    /// Escrita expressiva não chega à sábia por caminho nenhum — nem pela
    /// linha "?", nem pelo motor.
    @Test func expressivaNaoPerguntaEOMotorRecusa() async throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Qual é o prazo?")
        s.gesto = .expressiva
        s.responderNaPagina = { _, _, _, _ in Issue.record("a expressiva alcançou o modelo"); return "x" }
        s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: nil)
        #expect(s.cartao == nil)
        #expect(await Sabia.responder(pergunta: "q", contexto: "c", gesto: .expressiva) == nil)
    }

    /// Sem executor, a rota DIZ — e a pergunta do autor fica no cartão. É o
    /// estado de hoje (`responder` cortada); quando ela voltar, `aviso` é nil
    /// e o caminho de cima é o que corre.
    @Test func semExecutorOCartaoGuardaAPergunta() throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Qual é o prazo?")
        s.responderNaPagina = { _, _, _, _ in Issue.record("chamou o modelo sem executor"); return "x" }
        s.perguntarASabia(no: c.mainContext, disponivel: true, aviso: Politica.semProvedor(.responder))
        #expect(s.cartao == .pergunta("Qual é o prazo?"))
    }

    /// **O ramo que faltava.** Medido no fecho da 10b com `xccov`, o corpo desta
    /// função saiu de 0 para 47 das 49 linhas — e as duas que sobravam eram
    /// `cartao = .semConta` e o `return nil` dela. O G3 viu a ironia: é o único
    /// ramo que um autor SEM conta Grok alcança hoje, ou seja, o caminho mais
    /// percorrido pelo público era o que a suíte não pisava.
    ///
    /// A ordem também é o contrato: sem conta o autor lê "sem conta", não o
    /// aviso de qualidade — por isso o `aviso` aqui é o da PRODUÇÃO, e mesmo
    /// assim o cartão é `.semConta`. Nenhuma tarefa abre, e o modelo não é
    /// chamado por caminho nenhum.
    @Test func semContaOCartaoDizSemConta() throws {
        let c = try caderno()
        let s = sessaoComPergunta("? Qual é o prazo?")
        s.responderNaPagina = { _, _, _, _ in Issue.record("chamou o modelo sem conta"); return "x" }
        let tarefa = s.perguntarASabia(no: c.mainContext, disponivel: false,
                                       aviso: Politica.aviso(.responder))
        #expect(tarefa == nil)
        #expect(s.cartao == .semConta)
        #expect(s.notasNaPergunta.isEmpty)
    }
}

/// Duas peças mínimas para a prova de retorno atrasado: um sinal que só abre
/// quando o teste manda, e uma caixa para o que o motor recebeu.
private actor Sinalizador {
    private var continuacoes: [CheckedContinuation<Void, Never>] = []
    private var aberto = false
    func esperar() async {
        if aberto { return }
        await withCheckedContinuation { continuacoes.append($0) }
    }
    func liberar() {
        aberto = true
        for c in continuacoes { c.resume() }
        continuacoes.removeAll()
    }
}

private actor Caixa {
    private(set) var valor: String?
    func guardar(_ v: String) { valor = v }
}
