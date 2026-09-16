import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor @Suite(.serialized)
struct RevisaoTresRupturasTests {
    // o 17e do Xcode 27 não traz o embedding de palavras em português: sem
    // ele o teste não mede a recuperação — pula, dizendo por quê, em vez de
    // falhar a suíte por falta de instrumento
    @Test(.enabled(if: Indice.disponivel, "sem NLEmbedding PT no aparelho: o instrumento não alcança a recuperação"))
    func plantarChegaAConsultaRealSemFonteManual() async throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let indice = Indice.url, corpus = Corpus.diretorio
        let espelho = PastaEspelho.defaults
        let nomeDefaults = "revisao-plantar-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nomeDefaults))
        Indice.url = raiz.appendingPathComponent("indice.json")
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Indice.apagarTudo()
        defer {
            Indice.apagarTudo(); Indice.url = indice
            Corpus.diretorio = corpus; PastaEspelho.defaults = espelho
            defaults.removePersistentDomain(forName: nomeDefaults)
        }
        let c = try ModelContainer.traco(emMemoria: true), s = Sessao()
        let nome = "Tratado do Pensamento e Planejamento"
        let n = try #require(s.plantarObra(nome, no: c.mainContext))
        for _ in 0..<40 where Indice.vetorGuardado(n.uuid) == nil {
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(Indice.vetorGuardado(n.uuid) != nil, "plantar deve projetar no índice")
        #expect(s.contextoDasNotas(pergunta: nome, no: c.mainContext).contains { $0.id == n.uuid })
        var recebeu = false
        s.responderContextoNotas = { _, fontes, _, _, _, _ in
            recebeu = fontes.contains { $0.id == n.uuid }
            return nil
        }
        _ = await s.responderNasNotas(nome, conversa: [], no: c.mainContext)
        #expect(recebeu, "a consulta pública deve entregar a nota ao executor")
    }

    @Test func preparandoEEdicaoAlheiaNaoFecham() throws {
        var d = DocumentoTrabalho(intencao: "Oferta para cliente")
        try d.guardarVersaoHumana("Oferta inicial")
        try d.prepararAcao("Apresentar")
        let e = try d.registrarRelato("Pediu preço", acaoID: d.acoes[0].id, resultado: .parcial)
        _ = try d.iniciarPedido("Ajustar preço", ajuste: .init(gatilho: .resultadoInformado, motivo: e.texto, evidenciaID: e.id))
        #expect(!d.jornada.ajuste)
        #expect(d.proximaEstacao == .ajuste)
        d.cancelarPedido()
        try d.guardarVersaoHumana("Corrigi pontuação somente", base: d.versaoAtual?.id)
        #expect(!d.jornada.ajuste, "edição comum não registra causa")
    }

    @Test func identidadeNaoSeMontaPorPalavrasDispersas() throws {
        let p = GuardaDeObra.Pedido(nome: "Tratado das Nuvens Invertidas")
        func f(_ texto: String) -> FonteNotas { .init(id: UUID(), titulo: texto, texto: texto, editadaEm: .now) }
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: [f("As nuvens chegaram"), f("Fotografias invertidas")]))
        #expect(GuardaDeObra.recusarSeAusente(pergunta: "Resuma o livro Duna", fontes: []) != nil)
        #expect(GuardaDeObra.recusarSeAusente(pergunta: "Explique a frase \"planejamento semanal\".", fontes: []) == nil)
    }
}
