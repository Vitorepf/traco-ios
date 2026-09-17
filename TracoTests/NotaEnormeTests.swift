import Foundation
import SwiftData
import Testing
@testable import Traco

nonisolated private final class Contador: @unchecked Sendable { nonisolated(unsafe) var n = 0 }
nonisolated private final class Caixa: @unchecked Sendable {
    nonisolated(unsafe) let nota: Nota
    init(_ nota: Nota) { self.nota = nota }
}

/// E9 (PRINCÍPIO DA SÁBIA): a nota enorme nunca fica fora por tamanho — vai por
/// partes que a pergunta pede e leva a leitura guardada da Sábia; a resposta é
/// fiel, não literal.
@MainActor @Suite(.serialized)
struct NotaEnormeTests {
    static func diario() -> String {
        var linhas = ["# Diário de trabalho 2026"]
        for dia in 1...400 {
            linhas.append("## Dia \(dia)")
            linhas.append("Reunião de rotina com a equipe, conferência das planilhas e pedidos da semana, sem novidade no dia \(dia).")
            if dia == 120 { linhas.append("A Gráfica Pontal subiu o milheiro de panfletos de R$ 380 para R$ 440.") }
            if dia == 300 { linhas.append("Correção: o milheiro de panfletos da Gráfica Pontal fica em R$ 410 a partir de agosto.") }
        }
        return linhas.joined(separator: "\n")
    }

    @Test func asPartesSaoPedacosLiteraisEComecamNoTitulo() {
        let paragrafo = (1...400).map { "Frase número \($0) de um parágrafo sem quebra nenhuma." }.joined(separator: " ")
        let texto = "# Estudo\n\n## Primeira\nLinha curta.\n\n" + paragrafo + "\n## Segunda\nOutra linha."
        let partes = RespostaNotas.partes(texto)
        #expect(partes.allSatisfy { $0.count <= RespostaNotas.tamanhoDaParte + RespostaNotas.cabecaCurta })
        for linha in partes.flatMap({ $0.components(separatedBy: "\n") }) {
            #expect(texto.contains(linha), "linha que não foi escrita assim: \(linha.prefix(60))")
        }
        #expect(partes.contains { $0.contains("## Segunda\nOutra linha.") }, "o título fica com o que vem embaixo dele")
        let dias = RespostaNotas.partes((1...60).map { "## Dia \($0)\nNada de novo no dia \($0)." }.joined(separator: "\n"))
        #expect(dias.count < 10 && dias.allSatisfy { $0.hasPrefix("## Dia") }, "dias curtos vão juntos, e cada parte começa num título")
        #expect(partes.count > 10, "o parágrafo de \(paragrafo.count) caracteres quebra nas frases")
        #expect(RespostaNotas.partes(String(repeating: "palavra ", count: 500)).allSatisfy { $0.count <= RespostaNotas.tamanhoDaParte + RespostaNotas.cabecaCurta })
    }

    @Test func aNotaEnormeEntraPelasPartesQueAPerguntaPede() throws {
        let diario = FonteNotas(id: UUID(), titulo: "Diário de trabalho 2026", texto: Self.diario(), editadaEm: .now)
        #expect(diario.texto.count > 30_000)
        let p = try #require(RespostaNotas.montar(pergunta: "quanto custa o milheiro de panfletos da Gráfica Pontal?",
                                                  fontes: [diario], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        let enviada = try #require(p.fontes.first { $0.id == diario.id }, "a nota enorme não fica fora")
        #expect(enviada.texto.contains("R$ 440") && enviada.texto.contains("R$ 410"), "as partes com o fato e a correção")
        #expect(enviada.texto.count <= RespostaNotas.partesPorNota * (RespostaNotas.tamanhoDaParte + RespostaNotas.cabecaCurta + 2))
        #expect(p.fora.contains { $0.hasPrefix("nota «Diário de trabalho 2026»: por partes") })
        #expect(p.notasDoAutorForaInteiras.isEmpty && p.mensagem.contains("\"partes\"") && p.mensagem.contains("CONTEXTO PARCIAL"))
        var comLeitura = diario
        comLeitura.sintese = "Quem escreve registra a rotina; o milheiro da Pontal foi corrigido para R$ 410."
        let q = try #require(RespostaNotas.montar(pergunta: "o que tem nesse diário?", fontes: [comLeitura], conversa: [],
                                                  catalogo: "", retrato: "", teto: 16_000))
        #expect(q.mensagem.contains("\"leituraDaSabia\"") && q.mensagem.contains(SinteseDeNota.rotuloNoPedido.prefix(30)))
        #expect(!q.fontes[0].texto.contains("corrigido para R$ 410"), "a leitura não vira linha citável")
    }

    @Test func aLeituraGuardadaValeSoParaANotaComoEstavaEOSeloTira() async throws {
        let antes = SinteseDeNota.url
        SinteseDeNota.url = FileManager.default.temporaryDirectory.appendingPathComponent("sinteses-\(UUID()).json")
        defer { SinteseDeNota.url = antes }
        let id = UUID()
        SinteseDeNota.gravar(id, assinatura: "a1", texto: "leitura")
        #expect(SinteseDeNota.ler(id, assinatura: "a1") == "leitura" && SinteseDeNota.ler(id, assinatura: "a2") == nil)
        // leitura guardada por pedido antigo (sem a versão na chave) não é reusada
        let antiga = UUID()
        let velho = ["\(antiga.uuidString)": SinteseDeNota.Guardada(assinatura: "a1", texto: "abre pela rotina", geradaEm: .now),
                     "\(id.uuidString)": SinteseDeNota.Guardada(assinatura: "v\(SinteseDeNota.versaoDoPedido)|a1", texto: "leitura", geradaEm: .now)]
        try JSONEncoder().encode(velho).write(to: SinteseDeNota.url)
        #expect(SinteseDeNota.ler(antiga, assinatura: "a1") == nil && SinteseDeNota.ler(id, assinatura: "a1") == "leitura")
        #expect(SinteseDeNota.parse(#"{"leitura":"  "}"#) == nil)
        let longa = String(repeating: "Quem escreve decidiu algo. ", count: 80)
        let cortada = try #require(SinteseDeNota.parse("{\"leitura\":\"\(longa)\"}"), "leitura longa se corta, não some")
        #expect(cortada.count <= SinteseDeNota.teto && cortada.hasSuffix("algo."))

        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let nota = Nota(texto: Self.diario())
        ctx.insert(nota)
        try ctx.save()
        let fonte = try #require(Sessao.fonteParaPergunta(nota))
        let assinatura = try #require(fonte.assinatura)

        // a guardada vai junto, sem chamar ninguém
        SinteseDeNota.gravar(nota.uuid, assinatura: assinatura, texto: "guardada")
        #expect(Sessao.comLeiturasGuardadas([fonte])[0].sintese == "guardada")

        // sem leitura: depois da pergunta, em segundo plano, uma vez por assinatura
        SinteseDeNota.remover(nota.uuid)
        let chamadas = Contador()
        Sessao.lerEmSegundoPlano([nota.uuid], no: ctx, perguntar: { @Sendable _, u, _ in
            chamadas.n += 1
            #expect(u.hasPrefix("NOTA (JSON):"), "a nota vai como dado")
            return #"{"leitura":"lida depois"}"#
        })
        for _ in 0..<50 where SinteseDeNota.ler(nota.uuid, assinatura: assinatura) == nil { try await Task.sleep(for: .milliseconds(20)) }
        #expect(SinteseDeNota.ler(nota.uuid, assinatura: assinatura) == "lida depois")
        SinteseDeNota.remover(nota.uuid)
        Sessao.lerEmSegundoPlano([nota.uuid], no: ctx, perguntar: { @Sendable _, _, _ in chamadas.n += 1; return nil })
        try await Task.sleep(for: .milliseconds(100))
        #expect(chamadas.n == 1, "a mesma assinatura não vai de novo nesta execução")

        // selada enquanto a Sábia lia: nada fica no disco
        let outra = Nota(texto: Self.diario() + "\nfim")
        ctx.insert(outra)
        try ctx.save()
        let assinaturaOutra = try #require(Sessao.fonteParaPergunta(outra)?.assinatura)
        let caixa = Caixa(outra)
        Sessao.lerEmSegundoPlano([outra.uuid], no: ctx, perguntar: { @Sendable _, _, _ in
            await MainActor.run { caixa.nota.trancada = true }
            return #"{"leitura":"de nota selada"}"#
        })
        try await Task.sleep(for: .milliseconds(200))
        #expect(SinteseDeNota.ler(outra.uuid, assinatura: assinaturaOutra) == nil)

        // o selo tira do disco
        SinteseDeNota.gravar(nota.uuid, assinatura: assinatura, texto: "guardada")
        let s = Sessao()
        s.abrir(nota)
        #expect(s.salvar(no: ctx, trancar: true))
        #expect(SinteseDeNota.ler(nota.uuid, assinatura: assinatura) == nil)
    }

    /// Revisão da E9: "Duna" seguido de um parágrafo enorme virava a parte "Duna" sozinha,
    /// e a guarda recusava «chegou só o nome». A cabeça curta vai com o que vem embaixo.
    @Test func aCabecaCurtaNaoFicaSozinhaNemViraSoONome() throws {
        let corpo = String(repeating: "O deserto ensina paciência e a água decide quem manda. ", count: 600)
        let partes = RespostaNotas.partes("Duna\n" + corpo)
        #expect(partes[0].hasPrefix("Duna\nO deserto"))
        #expect(RespostaNotas.partes("# Viagem a Lisboa\n" + corpo)[0].hasPrefix("# Viagem a Lisboa\nO deserto"))
        let duplo = "Primeira frase.  Segunda frase com dois espaços antes. " + String(repeating: "Mais uma frase comprida. ", count: 100)
        for linha in RespostaNotas.partes(duplo).flatMap({ $0.components(separatedBy: "\n") }) {
            #expect(duplo.contains(linha), "espaço duplo preservado")
        }
        let duna = FonteNotas(id: UUID(), titulo: "Duna", texto: "Duna\n" + corpo, editadaEm: .now)
        let p = try #require(RespostaNotas.montar(pergunta: "Resuma o livro Duna", fontes: [duna], conversa: [],
                                                  catalogo: "", retrato: "", teto: 16_000))
        #expect(p.idsPorPartes == [duna.id] && p.fontes[0].texto.contains("deserto"))
        #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: "Resuma o livro Duna", fontes: p.fontes) == nil)
    }

    /// A nota que cabe vai inteira, como antes da E9 — por partes só a que não cabe.
    @Test func aNotaMediaQueCabeVaiInteira() throws {
        let media = FonteNotas(id: UUID(), titulo: "Plano", texto: String(repeating: "linha do plano de vendas\n", count: 400), editadaEm: .now)
        #expect(media.texto.count > RespostaNotas.tetoInteira)
        let p = try #require(RespostaNotas.montar(pergunta: "qual o plano?", fontes: [media], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        #expect(p.fontes[0].texto == media.texto && p.idsPorPartes.isEmpty && !p.mensagem.contains("CONTEXTO PARCIAL"))
    }

    @Test func oPedidoPedeSinteseFielECurta() {
        #expect(Sabia.sistemaResponderNasNotas.contains("Fiel, não literal"))
        #expect(Sabia.sistemaResponderNasNotas.contains("é a decisão X, tomada em 29/08"))
        #expect(Sabia.sistemaConferirNasNotas.contains("síntese fiel e curta não se tira por não ser cópia"))
        #expect(Sabia.sistemaResponderNasNotas.contains("ausência nas partes não é ausência na nota")
                && Sabia.sistemaResponderNasNotas.contains("Nunca fale à pessoa da mecânica do pedido"))
        #expect(SinteseDeNota.sistema.contains("Comece pelo que MUDOU") && Sabia.semGenero.contains("«vale mais firmeza»"))
    }
}

/// E9: partes são da nota do AUTOR. Obra e nota do bot enormes seguem as regras delas.
struct PartesSoDoAutorTests {
    @Test func obraENotaDoBotNaoVaoPorPartes() throws {
        let texto = (1...2_000).map { "linha \($0) sobre a nuvem invertida" }.joined(separator: "\n")
        var doBot = FonteNotas(id: UUID(), titulo: "Pesquisa · pesquisa do bot", texto: texto, editadaEm: .now)
        doBot.doAutor = false
        let obra = FonteNotas(id: UUID(), titulo: "Tratado", texto: texto, editadaEm: .now, obra: true)
        let p = try #require(RespostaNotas.montar(pergunta: "o que diz a nuvem invertida?", fontes: [doBot, obra],
                                                  conversa: [], catalogo: "", retrato: "", teto: 16_000))
        #expect(p.fontes.isEmpty && p.porPartes == 0)
        #expect(p.fora.contains("nota «Pesquisa · pesquisa do bot»: não coube"))
    }
}

/// Revisão da E9: a pergunta que nomeia a nota pelo título a leva, sem o Grok (e1-a-ampla
/// caiu 2 de 3 porque a escolha devolveu []); título curto e genérico não puxa nada.
@MainActor struct TituloNomeadoTests {
    @Test func aPerguntaQueNomeiaANotaALevaEONomeGenericoNao() async {
        #expect(Sessao.tituloNomeado("Diário de trabalho 2026", na: "Quais mudanças importantes eu registrei no diário de trabalho este ano?"))
        #expect(!Sessao.tituloNomeado("Notas", na: "o que eu anotei nas notas?"), "uma palavra só precisa de 6+ letras")
        #expect(!Sessao.tituloNomeado("Diário de trabalho 2026", na: "o que eu decidi no trabalho?"), "todas as palavras do título")
        #expect(Sessao.tituloNomeado("Orçamento", na: "quanto ficou o orcamento?"), "sem acento e sem caixa")
        let diario = FonteNotas(id: UUID(), titulo: "Diário de trabalho 2026", texto: "rotina", editadaEm: .now)
        let outra = FonteNotas(id: UUID(), titulo: "Compras", texto: "café", editadaEm: .now)
        let semGrok = await Sessao.comNotasPeloSentido(pergunta: "o que registrei no diário de trabalho?", fontes: [outra],
                                                       candidatas: [outra, diario], perguntar: { _, _, _ in #"{"notas":[]}"# })
        #expect(semGrok.map(\.id) == [diario.id, outra.id])
    }
}

/// Revisão da E9: na escolha das notas do autor, o número inválido sai e o resto fica.
@MainActor struct EscolhaDasNotasTolerante {
    @Test func numeroInvalidoSaiERestoFica() async {
        #expect(Sessao.numerosDaEscolha(#"{"notas":[1, 99, 2, 2, 1.5]}"#, total: 3, maximo: 5) == [1, 2])
        #expect(Sessao.numerosDaEscolha(#"{"notas":"1"}"#, total: 3, maximo: 5) == nil)
        #expect(Sessao.numerosDaEscolha(#"{"notas":[3,2,1]}"#, total: 3, maximo: 2) == [3, 2])
        let a = FonteNotas(id: UUID(), titulo: "Proposta", texto: "a", editadaEm: .now)
        let b = FonteNotas(id: UUID(), titulo: "Preço", texto: "b", editadaEm: .now)
        let r = await Sessao.comNotasPeloSentido(pergunta: "o que decidi?", fontes: [], candidatas: [a, b],
                                                 perguntar: { _, _, _ in #"{"notas":[2, 7]}"# })
        #expect(r.map(\.id) == [b.id], "o 7 inválido não derruba a escolha do 2")
        // a escolha da regra continua rígida
        #expect(Conselho.ler(#"{"regra":7}"#, chave: "regra", total: 3) == nil)
    }
}
