import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct RevisaoRetryAjusteTests {
    @Test func retryDaOficinaPreservaCausaSemCriarOutraVersao() throws {
        enum Falha: Error { case disco }
        let c = try ModelContainer.traco(emMemoria: true)
        var d = DocumentoTrabalho(intencao: "Oferta com preço")
        try d.guardarVersaoHumana("Oferta inicial")
        try d.prepararAcao("Mostrar a Ana")
        let e = try d.registrarRelato("Pediu o preço", acaoID: d.acoes[0].id, resultado: .parcial)
        let t = try Trabalho(documento: d)
        c.mainContext.insert(t)
        try c.mainContext.save()
        let o = try OficinaTrabalho(trabalho: t, context: c.mainContext)
        o.persistir = { _ in throw Falha.disco }
        let causa = DocumentoTrabalho.Ajuste(gatilho: .resultadoInformado, motivo: e.texto, evidenciaID: e.id)
        #expect(!o.alterar { try $0.guardarVersaoHumana("Oferta: 180", base: d.versaoAtual?.id, ajuste: causa) })
        #expect(!o.salvo)
        #expect(try t.ler() == d, "a escrita recusada não substitui o documento persistido")
        let pendente = try #require(o.documento.versaoAtual)
        #expect(o.documento.ajuste(de: pendente)?.evidenciaID == e.id)
        o.persistir = { try $0.save() }
        #expect(o.guardar(), "mesmo método do botão Tentar guardar novamente")
        let volta = try t.ler()
        #expect(volta.artefatos.count == 2)
        #expect(volta.versaoAtual?.id == pendente.id)
        #expect(volta.ajuste(de: pendente)?.evidenciaID == e.id)
        #expect(volta.versaoAtual?.conteudo == "Oferta: 180")
        try volta.validar()
    }
}
