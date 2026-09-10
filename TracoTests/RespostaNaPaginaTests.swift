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
        #expect(r.contexto.contains("--- outra nota sua: Cabe ---"))
        #expect(!r.contexto.contains("Não cabe"))
        #expect(r.contexto.count <= Sabia.tetoDoContextoDaNota)
    }

    /// A ordem É a prioridade (ADR 05o): a ligada explícita do autor vem antes
    /// da vizinha do índice, e quem não couber fica de fora INTEIRA, com o
    /// rótulo — nunca meia nota sem cabeçalho.
    @Test func vizinhaQueNaoCabeFicaDeForaInteiraComORotulo() {
        let pagina = String(repeating: "a", count: Sabia.tetoDoContextoDaNota - 10)
        let r = Sabia.contextoDaPergunta(pagina: pagina, vizinhas: [(titulo: "Alguma", prosa: "texto")])
        #expect(r.viajaram.isEmpty)
        #expect(r.contexto == pagina)
        #expect(!r.contexto.contains("outra nota sua"))
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
