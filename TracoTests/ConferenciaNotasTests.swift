import Foundation
import SwiftData
import Testing
@testable import Traco

/// Conferência da rota `responderNasNotas`: encanamento e invariantes.
/// Geradores controlados não contam como inferência de produção.
@MainActor
struct ConferenciaNotasTests {
    private let perguntaTese = "Qual tese Duna defende e como uso isso na minha escolha?"
    private let teseInventada =
        #"{"base":"notas","texto":"Duna defende que devemos confiar sem reservas em líderes carismáticos. Faça isso na sua escolha.","trechoIDs":["N1T1"]}"#

    private func fonte(_ titulo: String, _ texto: String) -> FonteNotas {
        .init(id: UUID(), titulo: titulo, texto: texto,
              editadaEm: Date(timeIntervalSince1970: 1_783_000_000))
    }

    private func json(base: String, texto: String, ids: [String]) throws -> String {
        let dados = try JSONSerialization.data(
            withJSONObject: ["base": base, "texto": texto, "trechoIDs": ids], options: [.sortedKeys])
        return String(decoding: dados, as: UTF8.self)
    }

    private func eco(_ pacote: RespostaNotas.Pacote, _ cru: String) async -> String? { cru }

    private func ajudaDoMaterial(_ corpo: String) throws -> String {
        let texto: String
        switch corpo {
        case "Quero comprar Duna":
            texto = "Você anotou que quer comprar Duna. Nesta consulta não há trecho da obra. Sem a tese no material, não a invento."
        case "Duna é caro":
            texto = "Você anotou que Duna é caro. Preço não é doutrina da obra. Nesta consulta não há trecho da tese; não invento valor nem conteúdo."
        case "Duna de Frank Herbert":
            texto = "A nota identifica Duna de Frank Herbert. Identidade não sustenta a tese. Nesta consulta não há trecho da obra; não invento o que ela defende."
        default:
            texto = "Nesta consulta o material não sustenta a tese da obra. Não invento o que ela diz."
        }
        return try json(base: "notas", texto: texto, ids: ["N1T1"])
    }

    @Test func parserLiteralAindaAceitaTeseInventadaNasTresFontes() throws {
        for corpo in ["Quero comprar Duna", "Duna é caro", "Duna de Frank Herbert"] {
            let p = try #require(RespostaNotas.montar(
                pergunta: perguntaTese, fontes: [fonte("Duna", corpo)],
                conversa: [], catalogo: "", retrato: "", teto: 16_000))
            let r = try #require(RespostaNotas.interpretar(teseInventada, pacote: p))
            #expect(r.texto.contains("líderes carismáticos"), Comment(rawValue: corpo))
            #expect(r.citadas.map(\.titulo) == ["Duna"], Comment(rawValue: corpo))
        }
    }

    @Test func conferenciaReparaTeseInventadaNasTresFontesENaoDizAusenciaGlobal() async throws {
        #expect(perguntaTese == "Qual tese Duna defende e como uso isso na minha escolha?")
        for corpo in ["Quero comprar Duna", "Duna é caro", "Duna de Frank Herbert"] {
            let f = fonte("Duna", corpo)
            #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: perguntaTese, fontes: [f]) == nil,
                    Comment(rawValue: corpo))
            let ajuda = try ajudaDoMaterial(corpo)
            var geracoes = 0, conferencias = 0
            var pacoteVisto: RespostaNotas.Pacote?
            var candidataVista: String?
            let r = await Sabia.responderNasNotas(
                pergunta: perguntaTese, fontes: [f],
                gerarRemoto: { _ in
                    geracoes += 1
                    return teseInventada
                },
                conferirRemoto: { pacote, cru in
                    conferencias += 1
                    pacoteVisto = pacote
                    candidataVista = cru
                    return ajuda
                })
            #expect(geracoes == 1 && conferencias == 1, Comment(rawValue: corpo))
            #expect(candidataVista == teseInventada, Comment(rawValue: corpo))
            #expect(pacoteVisto?.fontes.count == 1, Comment(rawValue: corpo))
            let texto = try #require(r?.texto)
            #expect(r?.conferida == true && r?.reparadaNaConferencia == true, Comment(rawValue: corpo))
            #expect(!texto.contains("líderes carismáticos"), Comment(rawValue: corpo))
            #expect(!texto.contains("confiar sem reservas"), Comment(rawValue: corpo))
            #expect(!texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno), Comment(rawValue: corpo))
            #expect(r?.obraParaPlantar == nil, Comment(rawValue: corpo))
            #expect(r?.citadas.map(\.titulo) == ["Duna"], Comment(rawValue: corpo))
        }
    }

    @Test func anotacaoDeCompraComOrcamentoEAtendivel() async throws {
        let f = fonte("Minha anotação de compra",
                      "Quero comprar Duna. Tenho 80 reais reservados; ainda não anotei o preço.")
        let boa = try json(base: "notas",
                           texto: "Você quer comprar Duna e reservou R$ 80. O preço ainda não está na nota; confirme o valor e compare com os 80 antes de decidir.",
                           ids: ["N1T1"])
        let r = await Sabia.responderNasNotas(
            pergunta: "Explique minha anotação e me ajude a decidir o próximo passo, sem resumir o livro.",
            fontes: [f], gerarRemoto: { _ in boa }, conferirRemoto: eco)
        let texto = try #require(r?.texto)
        #expect(r?.conferida == true && r?.reparadaNaConferencia == false)
        #expect(texto.contains("80"))
        #expect(!texto.contains("líderes"))
        #expect(!texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno))
        #expect(r?.citadas.map(\.id) == [f.id])
    }

    @Test func trechoPertinenteSustentaAplicacaoUtil() async throws {
        let f = fonte("Caderno da Ponte — exercício fictício",
                      "Uma ponte só serve se liga as duas margens. No argumento, a premissa é uma margem e a conclusão é a outra; falta justificar a passagem quando só repetimos a conclusão.")
        let boa = try json(base: "notas",
                           texto: "O trecho diz que repetir a conclusão não justifica a passagem. Em «meu serviço é bom porque é excelente» falta a evidência da passagem. Pergunta concreta: que resultado observável mostra que o serviço melhorou para alguém?",
                           ids: ["N1T1"])
        let r = await Sabia.responderNasNotas(
            pergunta: "Segundo este trecho, o que falta no argumento Meu serviço é bom porque é excelente, e qual pergunta concreta me ajuda a melhorar?",
            fontes: [f], gerarRemoto: { _ in boa }, conferirRemoto: eco)
        let texto = try #require(r?.texto)
        #expect(r?.conferida == true)
        #expect(texto.contains("passagem") || texto.contains("circular"))
        #expect(r?.citadas.map(\.id) == [f.id])
        #expect(!texto.contains("Duna"))
    }

    @Test func conflitoEntreFontesNaoEscolheUmLadoEmSilencio() async throws {
        let a = fonte("Ensaio A", "Decisão boa exige esperar toda dúvida desaparecer.")
        let b = fonte("Ensaio B", "Decisão boa admite dúvida residual e exige experiência pequena reversível.")
        let esconde = try json(base: "notas",
                               texto: "O ensaio recomenda esperar toda dúvida desaparecer antes de agir amanhã.",
                               ids: ["N1T1"])
        let expoe = try json(base: "notas",
                             texto: "Há conflito: uma anotação pede esperar a dúvida sumir; a outra admite dúvida residual e pede uma experiência pequena reversível. Sem correção sua, as duas ficam de pé. Amanhã você escolhe conferindo qual regra ainda vale, ou testa o passo reversível só se aceitar a segunda.",
                             ids: ["N1T1", "N2T1"])
        let r = await Sabia.responderNasNotas(
            pergunta: "Há duas anotações sobre decidir com dúvida. Qual regra fica e como ajo amanhã?",
            fontes: [a, b],
            gerarRemoto: { _ in esconde },
            conferirRemoto: { _, cru in
                #expect(cru == esconde)
                return expoe
            })
        let texto = try #require(r?.texto)
        #expect(r?.reparadaNaConferencia == true)
        #expect(texto.contains("conflito"))
        #expect(Set(r?.citadas.map(\.id) ?? []) == [a.id, b.id])
        #expect(r?.citadas.map(\.id) != [a.id])
    }

    @Test func idValidoDeFonteIrrelevanteNaoPublicaATese() async throws {
        let compra = fonte("Duna", "Quero comprar Duna")
        let recusa = try json(base: "insuficiente",
                              texto: "O trecho citado só registra que você quer comprar Duna. Não sustenta a tese inventada. Sem trecho da obra nesta consulta, não atribuo doutrina; o que está apoiado é a intenção de compra.",
                              ids: [])
        let r = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [compra],
            gerarRemoto: { _ in teseInventada },
            conferirRemoto: { _, cru in
                #expect(cru == teseInventada)
                return recusa
            })
        let texto = try #require(r?.texto)
        #expect(r?.conferida == true)
        #expect(!texto.contains("líderes carismáticos"))
        #expect(r?.citadas.isEmpty == true)
        #expect(r?.obraParaPlantar == nil)
        #expect(!texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno))
    }

    @Test func omissaoNaoInventaAObraEDeixaANotaQueCoube() async throws {
        let lista = fonte("Lista", "leite e pão")
        let enorme = FonteNotas(
            id: UUID(), titulo: "Tratado das Nuvens Invertidas",
            texto: "Tratado das Nuvens Invertidas. Mélanie Voss: a tese é que a nuvem invertida ensina a esperar. "
                + String(repeating: "a nuvem invertida ensina a esperar. ", count: 800),
            // E9: nota do AUTOR enorme entra por partes; o livro colado é obra, e obra que não cabe segue fora
            editadaEm: Date(timeIntervalSince1970: 1_783_000_000), obra: true)
        let pacote = try #require(RespostaNotas.montar(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            fontes: [enorme, lista], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        try #require(!pacote.fontes.contains { $0.id == enorme.id })
        try #require(pacote.omitidas >= 1)
        var gerou = 0, conferiu = 0
        let ajuda = try json(base: "notas",
                             texto: "A obra longa não coube nesta consulta; não invento a tese. Coube a lista: leite e pão.",
                             ids: ["N1T1"])
        let r = await Sabia.responderNasNotas(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            fontes: [enorme, lista],
            gerarRemoto: { visto in
                gerou += 1
                #expect(visto.fontes.map(\.id) == [lista.id])
                return teseInventada
            },
            conferirRemoto: { visto, _ in
                conferiu += 1
                #expect(visto.fontes.map(\.id) == [lista.id])
                return ajuda
            })
        #expect(gerou == 1 && conferiu == 1)
        #expect(r?.obraParaPlantar == nil)
        #expect(r?.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r?.texto.contains("nuvem invertida ensina") != true)
        #expect(r?.citadas.map(\.id) == [lista.id])
    }

    @Test func conferenciaLeAsFontesEfetivasDoPacote() async throws {
        let compra = fonte("Duna", "Quero comprar Duna")
        let lista = fonte("Lista", "leite e pão")
        var visto: [UUID] = []
        let ajuda = try ajudaDoMaterial("Quero comprar Duna")
        let r = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [compra, lista],
            gerarRemoto: { pacote in
                visto = pacote.fontes.map(\.id)
                return teseInventada
            },
            conferirRemoto: { pacote, cru in
                #expect(pacote.fontes.map(\.id) == visto)
                #expect(Set(pacote.fontes.map(\.id)) == [compra.id, lista.id])
                #expect(cru == teseInventada)
                return ajuda
            })
        #expect(r?.conferida == true)
        #expect(r?.texto.contains("líderes carismáticos") != true)
    }

    @Test func falaAntigaDaIANaoEProvaECorrecaoHumanaPermanece() async throws {
        let compra = fonte("Duna", "Quero comprar Duna")
        let historico = [
            Sessao.TrocaNasNotas(pergunta: "Qual era a tese?",
                                 resposta: "Obra X defende obedecer sem questionar."),
            Sessao.TrocaNasNotas(pergunta: "Corrijo: eu só anotei que quero comprar.",
                                 resposta: "Registrei."),
        ]
        let usaIA = try json(base: "conversa",
                             texto: "Como a conversa anterior já disse, a obra defende obedecer sem questionar. Aplique isso na escolha.",
                             ids: [])
        let usaCorrecao = try json(base: "notas",
                                   texto: "Você corrigiu: só anotou que quer comprar. A fala anterior da IA não prova tese. Sem trecho da obra nesta consulta, o próximo passo é o preço, não a doutrina.",
                                   ids: ["N1T1"])
        var pedidoConferencia: String?
        let r = await Sabia.responderNasNotas(
            pergunta: "Como aplico a tese na minha escolha?",
            fontes: [compra], conversa: historico,
            gerarRemoto: { pacote in
                #expect(pacote.mensagem.contains("Corrijo: eu só anotei que quero comprar."))
                #expect(pacote.mensagem.contains("Obra X defende obedecer sem questionar."))
                return usaIA
            },
            conferirRemoto: { pacote, cru in
                pedidoConferencia = RespostaNotas.mensagemDaConferencia(pacote: pacote, candidata: cru)
                #expect(cru == usaIA)
                return usaCorrecao
            })
        let texto = try #require(r?.texto)
        #expect(pedidoConferencia?.contains("fala anterior da IA") == true)
        #expect(texto.contains("só anotou") || texto.contains("quer comprar"))
        #expect(!texto.contains("obedecer sem questionar"))
        #expect(r?.reparadaNaConferencia == true)
    }

    @Test func ausenciaDeCallbackNaoPublicaCandidataCrua() async {
        var gerou = 0
        let r = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [fonte("Duna", "Quero comprar Duna")],
            gerarRemoto: { _ in
                gerou += 1
                return teseInventada
            })
        #expect(gerou == 1)
        #expect(r == nil, "sem conferir injetado o Grok de teste cala; candidata crua não publica")
    }

    @Test func conferenciaNulaOuInvalidaNaoPublica() async throws {
        let f = fonte("Duna", "Quero comprar Duna")
        let nula = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [f],
            gerarRemoto: { _ in teseInventada },
            conferirRemoto: { _, _ in nil })
        #expect(nula == nil)
        let invalida = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [f],
            gerarRemoto: { _ in teseInventada },
            conferirRemoto: { _, _ in "isto não é json" })
        #expect(invalida == nil)
        let idInventado = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [f],
            gerarRemoto: { _ in teseInventada },
            conferirRemoto: { _, _ in
                #"{"base":"notas","texto":"reparo com id inventado.","trechoIDs":["N9T9"]}"#
            })
        #expect(idInventado == nil)
    }

    @Test func boaCandidataEMantidaSemTerceiraChamada() async throws {
        let f = fonte("Duna", "Quero comprar Duna. Tenho 80 reais reservados.")
        let boa = try json(base: "notas",
                           texto: "Você quer comprar Duna e reservou R$ 80. Confirme o preço e compare com os 80.",
                           ids: ["N1T1"])
        var geracoes = 0, conferencias = 0
        let r = await Sabia.responderNasNotas(
            pergunta: "Explique minha anotação de compra.",
            fontes: [f],
            gerarRemoto: { _ in
                geracoes += 1
                return boa
            },
            conferirRemoto: { _, cru in
                conferencias += 1
                return cru
            })
        #expect(geracoes == 1 && conferencias == 1)
        #expect(r?.conferida == true && r?.reparadaNaConferencia == false)
        #expect(r?.texto.contains("80") == true)
        #expect(r?.candidato == boa)
        #expect(r?.conferencia == boa)
    }

    @Test func fonteErradaESubstituidaPelaReferenciaCerta() async throws {
        let certa = fonte("Anotação de compra", "Quero comprar Duna. Reservei 80 reais.")
        let errada = fonte("Lista do mercado", "leite e pão")
        let citaErrada = try json(base: "notas",
                                  texto: "Sua lista do mercado indica a tese de Duna.",
                                  ids: ["N2T1"])
        let citaCerta = try json(base: "notas",
                                 texto: "A lista do mercado não fala de Duna. Você anotou que quer comprar Duna e reservou 80 reais.",
                                 ids: ["N1T1"])
        let r = await Sabia.responderNasNotas(
            pergunta: "O que eu anotei sobre comprar Duna?",
            fontes: [certa, errada],
            gerarRemoto: { _ in citaErrada },
            conferirRemoto: { _, _ in citaCerta })
        #expect(r?.citadas.map(\.id) == [certa.id])
        #expect(r?.texto.contains("80") == true)
        #expect(r?.texto.contains("lista do mercado indica a tese") != true)
    }

    @Test func cancelamentoDuranteCadaAwaitNaoPublica() async {
        let f = fonte("Duna", "Quero comprar Duna")
        var gerou = 0, conferiu = 0
        let noGerar = await Task {
            await Sabia.responderNasNotas(
                pergunta: self.perguntaTese, fontes: [f],
                gerarRemoto: { _ in
                    gerou += 1
                    withUnsafeCurrentTask { $0?.cancel() }
                    return self.teseInventada
                },
                conferirRemoto: { _, cru in
                    conferiu += 1
                    return cru
                })
        }.value
        #expect(gerou == 1 && conferiu == 0)
        #expect(noGerar == nil)

        gerou = 0
        conferiu = 0
        let noConferir = await Task {
            await Sabia.responderNasNotas(
                pergunta: self.perguntaTese, fontes: [f],
                gerarRemoto: { _ in
                    gerou += 1
                    return self.teseInventada
                },
                conferirRemoto: { _, cru in
                    conferiu += 1
                    withUnsafeCurrentTask { $0?.cancel() }
                    return cru
                })
        }.value
        #expect(gerou == 1 && conferiu == 1)
        #expect(noConferir == nil)
    }

    @Test func limiteDoReparoFalivelAindaPodeMencionarTituloSemGestoDePlantar() async throws {
        let f = fonte("Duna", "Quero comprar Duna")
        let reparo = try json(base: "insuficiente",
                              texto: "Quer plantar O Livro Inventado das Areias? Enquanto não plantar, eu invento o que ele diz.",
                              ids: [])
        let r = await Sabia.responderNasNotas(
            pergunta: perguntaTese, fontes: [f],
            gerarRemoto: { _ in teseInventada },
            conferirRemoto: { _, _ in reparo })
        #expect(r?.obraParaPlantar == nil)
        #expect(r?.conferida == true)
        #expect(r?.texto.contains("Livro Inventado") == true)
    }

    @Test func aFixturePreservaAPerguntaOriginalDasContraprovas() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let fixture = try String(contentsOf: raiz.appending(path: "prova/sustentacao-notas-casos.json"),
                                 encoding: .utf8)
        #expect(fixture.contains(perguntaTese))
        #expect(!fixture.contains("Resuma o livro Duna"))
    }

    @Test func oScriptDeAvaliacaoNaoInstalaNemApagaEAbortaSemContaOuCarimbo() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let script = try String(contentsOf: raiz.appending(path: "ferramentas/orca/avaliar-sustentacao-notas.sh"),
                                encoding: .utf8)
        #expect(script.contains("A1DF082C-FC87-4DF9-9F56-F2DA1C084DED"))
        #expect(script.contains("com-trava.sh"))
        #expect(script.contains("pedidoConferenciaNotasSHA256"))
        #expect(script.contains("pedidoResponderNasNotasSHA256"))
        #expect(script.contains("divergência"))
        #expect(script.contains("sistemaConferirNasNotas"))
        #expect(script.contains("matriz incompleta"))
        #expect(script.contains("anterior-"))
        #expect(!script.contains("[:2000]"))
        #expect(script.contains("contaGrokLigada"))
        #expect(script.contains("exit 4"))
        #expect(script.contains("exit 5"))
        #expect(!script.contains("xcodebuild"))
        #expect(!script.contains("simctl install"))
        #expect(!script.contains("simctl erase"))
        #expect(!script.contains(" --remove-existing-content"))
        #expect(!script.contains("clearState"))
        let carimbo = try #require(script.range(of: "pedidoConferenciaNotasSHA256"))
        let conta = try #require(script.range(of: "contaGrokLigada"))
        let casos = try #require(script.range(of: "sustentacao-notas-casos.json"))
        #expect(carimbo.lowerBound < conta.lowerBound)
        #expect(conta.lowerBound < casos.lowerBound)
    }
}
