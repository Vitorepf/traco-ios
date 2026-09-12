import Foundation
import SwiftData
import Testing
@testable import Traco

/// Q6 — contexto e continuidade. O que a pessoa escreveu, corrigiu e selou
/// sobrevive ao await. Resultado anterior informa o ajuste sem perder origem.
@MainActor
struct Q6ContextoContinuidadeTests {
    private func caderno() throws -> ModelContainer { try ModelContainer.traco(emMemoria: true) }

    private func fonte(_ titulo: String, _ texto: String) -> FonteNotas {
        .init(id: UUID(), titulo: titulo, texto: texto,
              editadaEm: Date(timeIntervalSince1970: 1_783_000_000))
    }

    @Test func correcaoDaPessoaNaoECortadaERespostaDaIACede() throws {
        let pergunta = "Qual é o prazo?\nA correção de hoje deve prevalecer."
        let correcao = Sessao.TrocaNasNotas(
            pergunta: "Corrijo: agora é 12/09, não 10/09.",
            resposta: String(repeating: "Resposta longa da IA. ", count: 80))
        let enorme = fonte("Nota grande", String(repeating: "Material. ", count: 800))
        let p = try #require(RespostaNotas.montar(
            pergunta: pergunta, fontes: [enorme], conversa: [correcao],
            catalogo: "", retrato: "", teto: 1000))
        #expect(p.mensagem.contains(pergunta))
        let linhaJSON = try #require(p.mensagem.components(separatedBy: "\n").first { $0.hasPrefix("[") })
        let historico = try #require(JSONSerialization.jsonObject(with: Data(linhaJSON.utf8)) as? [[String: String]])
        #expect(historico.first?["pergunta"] == correcao.pergunta)
        #expect(historico.first?["resposta"] == nil)
        #expect(p.mensagensDaPessoa == 1)
        #expect(p.respostasOmitidas == 1)
        #expect(!p.mensagem.contains("Resposta longa da IA."))
    }

    @Test func resultadoAnteriorViajaNaProximaPerguntaSemVirasVozDoAutor() async throws {
        let c = try caderno()
        let nota = Nota(texto: "A entrega é 12/09.\nO teto é R$ 800.")
        c.mainContext.insert(nota)
        try c.mainContext.save()
        let s = Sessao()
        var viuAnterior = false
        s.responderContextoNotas = { pergunta, _, conversa, _, _, _ in
            if pergunta.contains("ajusta") {
                viuAnterior = conversa.contains { $0.pergunta.contains("prazo") && $0.resposta.contains("12/09") }
                #expect(conversa.allSatisfy { !$0.resposta.contains("Referência:") || $0.resposta.contains("12/09") })
            }
            return .init(texto: "O prazo informado é 12/09.", enviadas: [], citadas: [])
        }
        let primeira = await s.responderNasNotas("qual o prazo?", conversa: [], no: c.mainContext)
        let resposta = try #require(primeira.resposta)
        #expect(resposta.contains("12/09"))
        let historico = [Sessao.TrocaNasNotas(pergunta: "qual o prazo?", resposta: resposta,
                                             dependencias: primeira.dependencias)]
        _ = await s.responderNasNotas("ajusta: confirma o teto também", conversa: historico, no: c.mainContext)
        #expect(viuAnterior, "o ajuste tem de ver o resultado anterior")
        #expect(Sessao.fonteParaPergunta(nota)?.texto.contains("12/09") == true)
        #expect(nota.origem == .autor)
    }

    @Test func seloNoAwaitDescartaRetornoENaoPerdeAPergunta() async throws {
        let c = try caderno()
        let n = Nota(texto: "Prazo 12/09.")
        c.mainContext.insert(n)
        try c.mainContext.save()
        let f = try #require(Sessao.fonteParaPergunta(n))
        let s = Sessao()
        s.responderContextoNotas = { _, enviadas, _, _, _, validar in
            n.trancada = true
            #expect(!validar(enviadas))
            return .init(texto: "isto não pode aparecer", enviadas: [f], citadas: [f])
        }
        let r = await s.responderNasNotas("qual o prazo?", conversa: [], no: c.mainContext)
        #expect(r.resposta == nil)
        #expect(r.fontesMudaram)
        #expect(Sessao.fonteParaPergunta(n) == nil)
    }

    @Test func conversaDaFolhaGuardaAPerguntaQuandoAFonteSome() async throws {
        let c = try caderno()
        let n = Nota(texto: "Prazo 12/09.")
        c.mainContext.insert(n)
        try c.mainContext.save()
        let f = try #require(Sessao.fonteParaPergunta(n))
        let folha = ConversaNotas()
        folha.entrada = "qual o prazo?"
        let tarefa = try #require(folha.perguntar(disponivel: true) { _, _ in
            n.trancada = true
            return .init(resposta: "isto não pode aparecer", fontes: [f],
                         dependencias: [f], fontesMudaram: true)
        })
        await tarefa.value
        #expect(folha.trocas.isEmpty)
        if case .recolhida(let q) = folha.estado {
            #expect(q == "qual o prazo?")
        } else {
            Issue.record("a pergunta tinha de ficar para repetir, estado=\(folha.estado)")
        }
    }
}
