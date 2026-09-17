import Foundation
import SwiftData
import Testing
@testable import Traco

/// E6 (segundo cérebro): a folha «Notas ligadas» e o contexto da Página escolhem as candidatas
/// a eco num ponto só — as 40 mais recentes do autor, sem a própria, as já ligadas e as versões
/// juntas —, e o pedido nomeia consequência e padrão, que a linha de base perdia.
@MainActor @Suite(.serialized)
struct EcosSegundoCerebroTests {
    @Test func asQuarentaMaisRecentesSemAVersaoJuntaNemAJaLigada() throws {
        let original = Juntas.url
        Juntas.url = FileManager.default.temporaryDirectory.appendingPathComponent("juntas-\(UUID().uuidString).json")
        Juntas.esquecerCache()
        defer { Juntas.url = original; Juntas.esquecerCache() }

        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let hoje = Date(timeIntervalSince1970: 1_790_000_000)
        let nota = Nota(texto: "Compras da semana, versão de hoje.", editadaEm: hoje)
        let versao = Nota(texto: "Compras da semana, versão de ontem.", editadaEm: hoje.addingTimeInterval(-60))
        let jaLigada = Nota(texto: "Lista de espera da oficina.", editadaEm: hoje.addingTimeInterval(-120))
        // 41 notas soltas: a mais recente entra, a mais antiga fica fora
        let soltas = (0..<41).map { i in
            Nota(texto: "Nota solta \(i).", editadaEm: hoje.addingTimeInterval(-Double(i + 3) * 3_600))
        }
        let todas = [nota, versao, jaLigada] + soltas.reversed()
        for n in todas { ctx.insert(n) }
        try ctx.save()
        #expect(Juntas.juntar(nota.uuid, com: versao.uuid))

        let candidatas = Sessao.candidatasDeEcos(de: nota.uuid, todas: todas, jaLigadas: [jaLigada.uuid])
        #expect(candidatas.count == 40)
        #expect(candidatas.first?.uuid == soltas[0].uuid, "a solta mais recente entra, e primeiro")
        #expect(!candidatas.contains { $0.uuid == soltas[40].uuid }, "com 41, a mais antiga fica fora")
        #expect(!candidatas.contains { [nota.uuid, versao.uuid, jaLigada.uuid].contains($0.uuid) },
                "a própria, a versão junta e a já ligada não são sugestão")
    }

    /// Obra, nota do bot, selada e expressiva não são candidatas (a sugestão é entre notas suas).
    @Test func seladaExpressivaObraEBotNaoSaoCandidatas() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let boa = Nota(texto: "A oficina de sábado tem sala para 15.")
        let selada = Nota(texto: "A oficina de sábado foi cancelada uma vez.", trancada: true)
        let expressiva = Nota(texto: "Oficina de sábado, que raiva de tudo.", gesto: .expressiva)
        let obra = Nota(texto: "## Oficina\nRegra de sábado da oficina.")
        obra.origem = .obra
        let bot = Nota(texto: "Pesquisa sobre oficina de sábado e lotação.")
        bot.origem = .grokbot
        for n in [boa, selada, expressiva, obra, bot] { ctx.insert(n) }
        try ctx.save()
        let ids = Set(Sessao.candidatasDeEcos(de: nil, todas: [boa, selada, expressiva, obra, bot], jaLigadas: []).map(\.uuid))
        #expect(ids == [boa.uuid])
    }

    /// A folha e a Página passam pelo mesmo ponto: voltar a `.prefix(40)` num dos dois quebra aqui.
    @Test func aFolhaEAPaginaChamamOMesmoPonto() throws {
        let raiz = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let rede = try String(contentsOf: raiz.appendingPathComponent("Traco/Notas/RedeView.swift"), encoding: .utf8)
        let sessao = try String(contentsOf: raiz.appendingPathComponent("Traco/App/Sessao.swift"), encoding: .utf8)
        #expect(rede.contains("Sessao.candidatasDeEcos(de: nota.uuid") && !rede.contains(".prefix(40)"))
        let pagina = try #require(sessao.range(of: "func contextoDoCaderno"))
        let fim = sessao.range(of: "\n    func ", range: pagina.upperBound..<sessao.endIndex)?.lowerBound ?? sessao.endIndex
        let trecho = sessao[pagina.lowerBound..<fim]
        #expect(trecho.contains("Self.candidatasDeEcos(de: notaUUID") && !trecho.contains("Indice.vizinhas(de: Caderno.prosa(de: texto), teto: 40"))
    }

    @Test func oPedidoNomeiaConsequenciaEPadrao() {
        #expect(Sabia.sistemaEcos.contains("a consequência"))
        #expect(Sabia.sistemaEcos.contains("o mesmo padrão que se repete"))
    }
}
