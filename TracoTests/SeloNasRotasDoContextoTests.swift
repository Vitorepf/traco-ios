import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-12a — o selo é invariante das rotas que a Fase 1–2 toca.
/// Sem esta auditoria, pesquisa não abre.
@MainActor
struct SeloNasRotasDoContextoTests {
    private let segredo = "SEGREDO-SELO-12A-MELANIE-VOSS"

    private func caderno() throws -> ModelContainer { try ModelContainer.traco(emMemoria: true) }

    @Test func pesquisaDelegadaNaoAbreAntesDaAuditoria() {
        #expect(!PesquisaDelegada.aberta)
        #expect(PesquisaDelegada.aceitar("achado da rede") == nil)
        #expect(PesquisaDelegada.aceitar("achado da rede", aberta: false) == nil)
    }

    @Test func aceiteDaPesquisaForaDoRetratoNaoAbreARota() {
        #expect(!PesquisaDelegada.aberta)
        #expect(PesquisaDelegada.aceitar("", aberta: true) == nil)
        #expect(PesquisaDelegada.aceitar("   ", aberta: true) == nil)

        let nota = PesquisaDelegada.aceitar("achado da rede", aberta: true)
        #expect(nota?.origem == .pesquisa)
        #expect(nota?.texto == "achado da rede")
        #expect(nota?.vozDoAutor.isEmpty == true)
        #expect(nota?.paraRetrato.vozDoAutor == false)
        #expect(Retrato.ler(notas: [nota!.paraRetrato], sinais: []).isEmpty)
        #expect(!PesquisaDelegada.aberta)
    }

    @Test func buscaNaoMostraOSegredoSelado() {
        let secreta = Nota(texto: segredo, trancada: true)
        let aberta = Nota(texto: "Prazo 12/09.")
        #expect(NotasFiltro.visiveis([secreta, aberta], busca: "SEGREDO", filtro: nil).isEmpty)
        #expect(NotasFiltro.visiveis([secreta, aberta], busca: "MELANIE", filtro: nil).isEmpty)
        #expect(NotasFiltro.visiveis([secreta, aberta], busca: "Prazo", filtro: nil).map(\.texto)
            == [aberta.texto])
    }

    @Test func fonteParaPerguntaRecusaSeladaExpressivaESemVoz() throws {
        let c = try caderno()
        let selada = Nota(texto: segredo, trancada: true)
        let expressiva = Nota(texto: segredo, gesto: .expressiva)
        let vazia = Nota(texto: "   ")
        let aberta = Nota(texto: "Prazo 12/09.")
        for n in [selada, expressiva, vazia, aberta] { c.mainContext.insert(n) }
        try c.mainContext.save()
        #expect(Sessao.fonteParaPergunta(selada) == nil)
        #expect(Sessao.fonteParaPergunta(expressiva) == nil)
        #expect(Sessao.fonteParaPergunta(vazia) == nil)
        #expect(Sessao.fonteParaPergunta(aberta) != nil)
    }

    @Test func retratoNaoLeCampoDeNotaSelada() {
        let selada = Retrato.NotaLida(gesto: .woop, fechada: true, expressiva: false,
                                      criadaEm: .now, campos: ["obstaculo": segredo],
                                      vozDoAutor: true)
        let aberta = Retrato.NotaLida(gesto: .woop, fechada: false, expressiva: false,
                                      criadaEm: .now, campos: ["obstaculo": "o celular na cama"],
                                      vozDoAutor: true)
        let r = Retrato.ler(notas: [selada, aberta], sinais: [])
        #expect(!r.contains(segredo))
        #expect(r.contains("o celular na cama"))
    }

    @Test func guardaDeObraNaoUsaFonteQueOSeloJaCortou() async throws {
        let c = try caderno()
        let selada = Nota(texto: "Tratado das Nuvens Invertidas de Mélanie Voss: a tese secreta.",
                          trancada: true)
        c.mainContext.insert(selada)
        try c.mainContext.save()

        let anterior = Indice.url
        Indice.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("indice-selo-guarda-\(UUID().uuidString).json")
        Indice.apagarTudo()
        defer {
            Indice.apagarTudo()
            Indice.url = anterior
        }
        // índice velho ainda aponta a nota: o selo corta na fonte, não no disco
        Indice.atualizar(.init(uuid: selada.uuid, editadaEm: selada.editadaEm,
                               voz: selada.texto, podeEntrar: true))

        #expect(Sessao.fonteParaPergunta(selada) == nil)
        #expect(Sessao().contextoDasNotas(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            no: c.mainContext).isEmpty)

        let s = Sessao()
        var chamou = false
        let inventado = #"{"base":"geral","texto":"Voss defende um decreto e a tese secreta.","trechoIDs":[]}"#
        s.responderContextoNotas = { pergunta, fontes, conversa, catalogo, retrato, validar in
            await Sabia.responderNasNotas(
                pergunta: pergunta, fontes: fontes, conversa: conversa,
                catalogo: catalogo, retrato: retrato, validarAcesso: validar,
                gerarRemoto: { _ in
                    chamou = true
                    return inventado
                },
                gerarLocal: { _ in
                    chamou = true
                    return inventado
                })
        }
        let r = await s.responderNasNotas(
            "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            conversa: [], no: c.mainContext)
        #expect(!chamou, "nota selada no índice velho não autoriza chamar o modelo")
        #expect(r.resposta?.contains(GuardaDeObra.fraseNaoEstaNoCaderno) == true)
        #expect(r.resposta?.contains("tese secreta") != true)
        #expect(r.resposta?.contains("decreto") != true)
        #expect(r.obraParaPlantar != nil)
    }

    @Test func indiceNaoGuardaNotaQueNaoPodeEntrar() {
        let anterior = Indice.url
        Indice.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("indice-selo-12a-\(UUID().uuidString).json")
        Indice.apagarTudo()
        defer {
            Indice.apagarTudo()
            Indice.url = anterior
        }
        let id = UUID()
        Indice.atualizar(.init(uuid: id, editadaEm: .now, voz: segredo, podeEntrar: true))
        Indice.atualizar(.init(uuid: id, editadaEm: .now, voz: segredo, podeEntrar: false))
        #expect(Indice.vetorGuardado(id) == nil)
    }

    @Test func juizoDeTrabalhoComOrigemSeladaNaoEntraNoRetrato() throws {
        let c = try caderno()
        let nota = Nota(texto: "Frase privada identificável")
        c.mainContext.insert(nota)
        var d = DocumentoTrabalho(intencao: nota.texto, notaOrigemID: nota.uuid)
        try d.prepararAcao("Conversar com a Ana")
        try d.registrarRelato(segredo, acaoID: d.acoes[0].id, resultado: .parcial)
        let trabalho = try Trabalho(documento: d)
        c.mainContext.insert(trabalho)
        nota.trancada = true
        try c.mainContext.save()

        let observados = AcessoTrabalho.juizosObservados(de: [trabalho], no: c.mainContext)
        #expect(observados.isEmpty)
        #expect(!Retrato.ler(notas: [], sinais: [], observados: observados).contains(segredo))
    }

    @Test func juizoAutorizadoViajaNoRetratoDaRotaDeProducao() async throws {
        let c = try caderno()
        let nota = Nota(texto: "Conversar com a Ana sobre outubro")
        c.mainContext.insert(nota)
        var d = DocumentoTrabalho(intencao: nota.texto, notaOrigemID: nota.uuid)
        try d.prepararAcao("Falar com a Ana")
        try d.registrarRelato("a conversa com a Ana adiou", acaoID: d.acoes[0].id,
                              resultado: .parcial)
        c.mainContext.insert(try Trabalho(documento: d))
        try c.mainContext.save()

        let ligadoAntes = Retrato.ligado
        Retrato.ligado = true
        defer { Retrato.ligado = ligadoAntes }

        let s = Sessao()
        var retratoEnviado: String?
        s.responderContextoNotas = { _, _, _, _, retrato, _ in
            retratoEnviado = retrato
            return .init(texto: "não sei.", enviadas: [], citadas: [])
        }
        _ = await s.responderNasNotas("o que aconteceu?", conversa: [], no: c.mainContext)
        let retrato = try #require(retratoEnviado)
        #expect(retrato.contains("a conversa com a Ana adiou"))
        #expect(retrato.contains("Funcionou em parte"))
    }
}
