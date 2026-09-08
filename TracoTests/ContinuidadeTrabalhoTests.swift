import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct ContinuidadeTrabalhoTests {
    @Test func espanholRetomaTentativaRelatoEFeedbackSemInventarRealizacao() throws {
        var d = DocumentoTrabalho(intencao: "Me apresentar em espanhol", resultado: "Conseguir uma apresentação curta")
        d.apoio = .praticar
        let primeiroPedido = try d.iniciarPedido("Sou iniciante. Três blocos de cinco minutos, sozinho, sem câmera nem instrutor.")
        let pratica = DocumentoTrabalho.Pratica(capacidade: "Apresentação", situacao: "Viagem",
            enunciado: "Escreva uma frase sobre onde você mora.", exemplo: "Para nacionalidade: Soy de Brasil.",
            criterios: [.init(texto: "Conjuga o verbo na primeira pessoa.")])
        try d.receber(PraticaTrabalho.emMarkdown(pratica), produtor: "Fixture explícita",
                      pedidoID: primeiroPedido.id, pratica: pratica)
        let primeiraVersao = try #require(d.versaoAtual)
        let tentativa = try d.guardarTentativa("Yo vive en Brasil.", apoioUtilizado: "Consultei o exemplo",
                                              artefatoID: primeiraVersao.id)
        try d.registrarConferenciaDaTentativa(.init(executor: "Avaliador controlado", versaoDoMetodo: 2,
            estado: .concluida, resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .divergencia,
                trechoDaTentativa: "Yo vive", observacao: "A conjugação não corresponde ao sujeito.")]), em: tentativa.id)
        try d.registrarRelato("Fiz só o primeiro bloco e travei no verbo.", acaoID: tentativa.acaoID)
        let container = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let contextoNovo = ModelContext(container)
        let reaberto = try #require(try contextoNovo.fetch(FetchDescriptor<Trabalho>()).first)
        var lido = try reaberto.ler()
        #expect(lido == d)
        let pedido = try lido.iniciarPedido("Adapte o exercício à dificuldade, mantendo os recursos e o tempo combinados.")
        for texto in [MotorTrabalho.pedido(lido, pedido, teto: 18_000), PraticaTrabalho.montarPreparacao(lido, pedido)] {
            for esperado in [primeiroPedido.instrucao, pratica.enunciado, pratica.criterios[0].texto,
                             tentativa.texto, "Consultei o exemplo", "Avaliador controlado", "divergencia",
                             "Fiz só o primeiro bloco", "pendente", pedido.instrucao] {
                #expect(texto.contains(esperado), "Contexto perdeu: \(esperado)")
            }
            #expect(texto.hasSuffix(pedido.instrucao))
        }
        try lido.receber("Exercício adaptado controlado", produtor: "Fixture explícita", pedidoID: pedido.id, pratica: pratica)
        #expect(lido.artefatos.count == 2)
        #expect(lido.tentativas(doArtefato: primeiraVersao.id).first == d.tentativas(doArtefato: primeiraVersao.id).first)
        #expect(lido.acoes.first?.estado == .pendente)
        #expect(lido.acoes.first?.executadaEm == nil)
        #expect(lido.evidencias.last?.tipo == .relato)
        try lido.validar()
    }

    @Test func historicoLongoPreservaRetornoRecenteENucleoNosDoisMotores() throws {
        var d = DocumentoTrabalho(intencao: "Praticar espanhol", resultado: "Me apresentar")
        try d.prepararAcao("Ensaiar sozinho")
        let acao = try #require(d.acoes.first)
        try d.registrarRelato(String(repeating: "Histórico antigo extenso. ", count: 2000), acaoID: acao.id)
        try d.registrarRelato("Hoje tive dificuldade com o verbo vivir.", acaoID: acao.id)
        let p = try d.iniciarPedido("Use três blocos de cinco minutos, sem câmera.")
        for texto in [MotorTrabalho.pedido(d, p, teto: 3500), PraticaTrabalho.montarPreparacao(d, p, teto: 3500)] {
            #expect(texto.count <= 3500)
            #expect(texto.contains("Hoje tive dificuldade com o verbo vivir."))
            #expect(texto.contains("CONTEXTO PARCIAL"))
            #expect(texto.contains("</material_de_referencia>"))
            #expect(texto.hasSuffix(p.instrucao))
        }
    }
}
