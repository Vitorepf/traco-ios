import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-16l (E7) — o contexto da Sábia: a nota vai com os rótulos do
/// método em TODAS as rotas que levam campos ao modelo.
@MainActor @Suite(.serialized)
struct ContextoDaSabiaTests {
    static let campos = ["escolha": "Dar 20% de desconto para o cliente que está enrolando",
                         "opcoes": "Dar o desconto", "criterio": "Fechar este mês",
                         "decidido": "Não dar desconto e oferecer um bônus de implantação", "aconteceu": ""]
    static func nome(_ id: String) -> String { Gesto.decisao.metodoDef.campos.first { $0.id == id }!.nome }

    @Test func oSerializadorRotulaCampoSentidoEForaDoMetodo() {
        let t = VozDoAutor.rotulada(texto: "# Proposta", campos: Self.campos.merging(["extra": "valor solto"]) { a, _ in a },
                                    gesto: .decisao, sentido: "desconto ensina a pedir desconto")
        #expect(t.contains("\(Self.nome("decidido")): Não dar desconto"))
        #expect(t.contains("\(Self.nome("escolha")): Dar 20%"))
        #expect(t.contains("extra: valor solto"))
        #expect(t.contains("\(VozDoAutor.rotuloDoSentido): desconto ensina"))
        #expect(!t.contains(": \n") && !t.hasSuffix(":"), "campo vazio não vira rótulo solto")
        // a busca por palavras continua sem rótulo
        #expect(!VozDoAutor.juntar(texto: "# Proposta", campos: Self.campos).contains(Self.nome("decidido") + ":"))
    }

    /// Conselho: a situação que vai ao modelo é rotulada; o BM25 segue sem rótulo.
    @Test func oConselhoMandaASituacaoRotulada() async throws {
        let campos = Self.campos.merging(["espero": "contrato até sexta"]) { a, _ in a }
        let consulta = try #require(Conselho.consulta(gesto: .decisao, campos: campos))
        let situacao = try #require(Conselho.situacao(gesto: .decisao, campos: campos))
        #expect(!consulta.contains(":") && situacao.contains("\(Self.nome("escolha")): Dar 20%"))
        #expect(!situacao.contains(Self.nome("decidido")), "a situação não leva o decidido: o conselho vem depois do ato")
        let obra = try String(contentsOf: ConselhoSombraTests.obras.appending(path: "biblioteca/hormozi.md"), encoding: .utf8)
        let texto = try #require(Corpus.importar(obra).first).texto
        var pedido = ""
        _ = await Conselho.escolherPeloSentido(consulta: consulta, situacao: situacao, obras: [texto], pesos: [:]) { _, u, _ in
            pedido = u; return #"{"regra":0,"suspeitas":[]}"#
        }
        let json = try #require(JSONSerialization.jsonObject(with: Data(pedido.utf8)) as? [String: Any])
        #expect(json["situacao"] as? String == situacao)
    }

    /// Padrões: a voz que vai ao modelo é rotulada, a obra não é voz, e a citação
    /// se confere na voz crua — pergunta que cita o rótulo não cita o autor.
    @Test func osPadroesMandamAVozRotulada() {
        let decisao = Nota(texto: "# Proposta", gesto: .decisao, campos: Self.campos)
        let obra = Nota(texto: "## 1. Regra\nRegra: x"); obra.origem = .obra
        let vozes = PadroesView.vozesParaAIA([decisao, obra])
        #expect(vozes[0].contains("\(Self.nome("decidido")): Não dar desconto"))
        #expect(vozes[1].isEmpty)
        let cru = [decisao.vozDoAutor]
        let citaRotulo = #"{"perguntas":["Por que “\#(Self.nome("decidido")): Não dar desconto” pesou mais?"]}"#
        let citaValor = #"{"perguntas":["Por que “Não dar desconto” pesou mais?"]}"#
        #expect(PadroesRemoto.parsePerguntas(citaRotulo, vozes: cru) == [])
        #expect(PadroesRemoto.parsePerguntas(citaValor, vozes: cru)?.count == 1)
    }

    /// Recordar: só a nota livre vai rotulada ao modelo; nos modos de campo, nada muda.
    @Test func oRecordarMandaANotaLivreRotulada() {
        let livre = RitualRecordar.livre.rotuladaParaAIA(texto: "# Proposta", campos: Self.campos, gesto: .decisao)
        #expect(livre?.contains("\(Self.nome("decidido")): Não dar desconto") == true)
        #expect(RitualRecordar.destilada.rotuladaParaAIA(texto: "x", campos: ["frase": "f"], gesto: .destilar) == nil)
    }

    /// Página: a nota citada por [[…]] vai à pergunta com os campos rotulados.
    @Test func aPerguntaDaPaginaLevaANotaCitadaRotulada() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let decisao = Nota(texto: "# Dar desconto para fechar a proposta", gesto: .decisao, campos: Self.campos)
        c.mainContext.insert(decisao)
        try c.mainContext.save()
        let s = Sessao()
        s.texto = "Rever o que ficou em [[Dar desconto para fechar a proposta]]"
        let ligadas = s.notasLigadas(no: c.mainContext)
        #expect(ligadas.first?.prosa.contains("\(Self.nome("decidido")): Não dar desconto") == true, "\(ligadas)")
    }

    // MARK: E7 — o Retrato e o pacote

    @Test func oRetratoDizOTipoADataECortaPorBloco() {
        let longo = String(repeating: "cansaço depois do almoço ", count: 6)
        func nota(_ g: Gesto, _ campos: [String: String], _ dias: Double) -> Retrato.NotaLida {
            .init(gesto: g, fechada: false, expressiva: false, criadaEm: Date.now.addingTimeInterval(-dias * 86_400), campos: campos, vozDoAutor: true)
        }
        // obstáculos (~750) cabem; os resultados do Trabalho (5 relatos de ~220, sem teto por
        // citação) estouram com folga; as palavras (~90), depois, ainda cabem
        var notas = (0..<5).map { nota(.woop, ["obstaculo": longo], Double($0)) }
        notas.append(nota(.palavra, ["minhas": "fôlego"], 0))
        let observados = (0..<5).map { _ in Retrato.JuizoObservado(rotulo: "Funcionou em parte", relato: String(repeating: "a reunião atrasou ", count: 12)) }
        let r = Retrato.lerComRecibo(notas: notas, sinais: [], observados: observados)
        #expect(r.texto.contains("(contagem)") && r.texto.contains("(citações"))
        #expect(r.texto.range(of: #"” \(\d{2}/\d{2}\)"#, options: .regularExpression) != nil, "a citação leva a data")
        #expect(!r.texto.contains("dela") && !r.texto.contains("dele") && !r.texto.contains("você informou"))
        #expect(r.texto.count <= Retrato.teto && !r.texto.hasSuffix("…"), "corta por bloco, nunca no meio")
        #expect(r.cortados == ["resultados"] && !r.texto.contains("Resultados informados"), "\(r.cortados)")
        #expect(r.texto.contains("fôlego"), "o bloco seguinte que cabe ainda entra")
        #expect(!Sabia.rotuloRetrato.contains("dela"))
    }

    @Test func oRetratoEOCatalogoSoVaoQuandoAPerguntaPede() {
        let longa = String(repeating: "reunião sem pauta ", count: 25)
        let retrato = "Formas nos últimos 30 dias (contagem): 3 Decisão.\nObstáculos internos já nomeados (citações, com a data da nota): “cansaço depois do almoço” (12/08).\nDecisões conferidas (contagem): 2. O que aconteceu ficou aquém do esperado em 1, igual em 1, além em 0; em 1 o saldo não foi escrito e a conta veio de uma leitura por palavras do que aconteceu.\nJuízos que já cortou numa frase (citações): “\(longa)” (10/08)."
        let doAssunto = Retrato.pertinente(retrato, pergunta: "por que fico cansado depois do almoço?")
        #expect(doAssunto.contains("cansaço") && !doAssunto.contains("Formas") && !doAssunto.contains("reunião"))
        // nenhum bloco divide assunto: vão os blocos que cabem, na ordem, até o teto menor
        let semAssunto = Retrato.pertinente(retrato, pergunta: "quando a mãe chega?")
        #expect(semAssunto.contains("Formas") && semAssunto.contains("cansaço") && semAssunto.contains("conferidas") && !semAssunto.contains("reunião"))
        #expect(semAssunto.count <= Retrato.tetoSemAssunto)
        #expect(Retrato.pertinente(retrato, pergunta: "que juízos cortei?") == semAssunto, "o rótulo do bloco não é assunto")
        #expect(Retrato.pertinente(retrato, pergunta: "o que escrevi sobre a Marina?") == semAssunto, "o molde da contagem não é assunto")
        #expect(Retrato.pertinente(retrato, pergunta: "quantas decisões conferidas?") == semAssunto)
        #expect(Sessao.catalogoParaPergunta("qual forma serve para decidir isto?") == Sessao.catalogoCompleto)
        #expect(Sessao.catalogoParaPergunta("vale um pré-mortem aqui?") == Sessao.catalogoCompleto)
        #expect(Sessao.catalogoParaPergunta("o que eu decidi sobre desconto?").isEmpty)
        #expect(Sessao.catalogoParaPergunta("qual a melhor forma de pedir aumento?").isEmpty, "«forma de» é jeito, não forma")
    }

    /// A frase da tela (texto do líder): uma nota, várias, e silêncio quando o que caiu não é nota do autor.
    @Test func aTelaNomeiaSoANotaDoAutorQueNaoCoube() throws {
        #expect(RespostaNotas.avisoDasNotasFora(["Diário longo"]) == "«Diário longo» não coube inteira nesta resposta.")
        #expect(RespostaNotas.avisoDasNotasFora(["Diário longo", "b", "c"]) == "«Diário longo» e mais 2 notas não couberam inteiras nesta resposta.")
        #expect(RespostaNotas.avisoDasNotasFora([]) == nil)
        #expect(RespostaNotas.avisoDasNotasFora([String(repeating: "palavra ", count: 10)])?.contains("…»") == true)
        // ponta a ponta: o retrato que não coube não aparece; a nota do autor que não coube, sim; a do bot, não
        let curta = FonteNotas(id: UUID(), titulo: "Prazo", texto: "Prazo 12/09.", editadaEm: .now)
        let soRetrato = try #require(RespostaNotas.montar(pergunta: "qual o prazo?", fontes: [curta], conversa: [], catalogo: "",
                                                          retrato: String(repeating: "r", count: 15_900), teto: 16_000))
        #expect(soRetrato.fora.contains("retrato: não coube") && soRetrato.notasDoAutorForaInteiras.isEmpty)
        let cru = #"{"base":"notas","texto":"O prazo é 12/09.","trechoIDs":["N1T1"]}"#
        let r1 = try #require(RespostaNotas.interpretar(cru, pacote: soRetrato))
        #expect(!r1.texto.contains("não coube") && !r1.texto.contains("Contexto parcial"))
        let enorme = String(repeating: "linha do diário\n", count: 1_100)
        let longa = FonteNotas(id: UUID(), titulo: "Diário longo", texto: enorme, editadaEm: .now)
        let comLonga = try #require(RespostaNotas.montar(pergunta: "qual o prazo?", fontes: [curta, longa], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        let r2 = try #require(RespostaNotas.interpretar(cru, pacote: comLonga))
        #expect(r2.texto.hasSuffix("«Diário longo» não coube inteira nesta resposta."))
        var doBot = FonteNotas(id: UUID(), titulo: "Resumo · pesquisa do bot", texto: enorme, editadaEm: .now)
        doBot.doAutor = false
        let comBot = try #require(RespostaNotas.montar(pergunta: "qual o prazo?", fontes: [curta, doBot], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        #expect(comBot.fora == ["nota «Resumo · pesquisa do bot»: não coube"] && comBot.notasDoAutorForaInteiras.isEmpty)
        let bot = Nota(texto: "Resumo da pesquisa"); bot.origem = .pesquisa
        #expect(Sessao.fonteParaPergunta(bot)?.doAutor == false && Sessao.fonteParaPergunta(Nota(texto: "Minha nota"))?.doAutor == true)
    }
}
