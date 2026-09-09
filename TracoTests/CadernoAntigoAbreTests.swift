import Foundation
import SwiftData
import Testing
@testable import Traco

/// O PORTÃO da migração (ADR 2026-09-09f). Cada arquivo em `TracoTests/Fixtures`
/// é um caderno REAL, gravado por um build daquela versão e nunca mais tocado.
/// O teste abre cada um com o container do app de hoje e conta as notas.
///
/// É o único teste que prova o que a suíte inteira não provava: os testes de
/// `DiscoTraco` injetam closures e nunca abriram um store antigo de verdade —
/// por isso a 08u passou verde e derrubou o arranque no aparelho do autor.
///
/// Quem mudar a classe viva sem abrir uma versão nova no plano vê VERMELHO
/// aqui: o checksum do schema corrente muda, o caderno gravado pelo build
/// anterior deixa de ser encontrado no plano e o container recusa abrir.
@MainActor
struct CadernoAntigoAbreTests {
    /// Cadernos congelados e quantas notas cada um tem.
    nonisolated static let cadernos: [CadernoCongelado] = [
        CadernoCongelado(arquivo: "caderno-v4-pre08u", notas: 7),
        CadernoCongelado(arquivo: "caderno-v5-origem", notas: 7),
    ]

    /// O store vem do bundle somente-leitura; a migração precisa escrever.
    private func copiar(_ nome: String) throws -> URL {
        let bundle = Bundle(for: MarcaDoBundleDeTestes.self)
        let origem = try #require(bundle.url(forResource: nome, withExtension: "store"),
                                  "fixture \(nome).store não está no bundle de testes")
        let destino = URL.temporaryDirectory
            .appendingPathComponent("caderno-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: destino, withIntermediateDirectories: true)
        let url = destino.appendingPathComponent("default.store")
        try FileManager.default.copyItem(at: origem, to: url)
        return url
    }

    @Test(arguments: cadernos)
    func cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno: CadernoCongelado) throws {
        let url = try copiar(caderno.arquivo)
        let container = try ModelContainer.traco(url: url)
        let notas = try container.mainContext.fetch(FetchDescriptor<Nota>())
        #expect(notas.count == caderno.notas,
                "\(caderno.arquivo): esperava \(caderno.notas) notas, achei \(notas.count)")
        #expect(notas.allSatisfy { !$0.texto.isEmpty }, "\(caderno.arquivo): nota sem texto")
    }

    /// O texto do autor atravessa a migração inteiro, não só a contagem.
    @Test func oTextoDoAutorAtravessa() throws {
        let url = try copiar("caderno-v4-pre08u")
        let container = try ModelContainer.traco(url: url)
        let notas = try container.mainContext.fetch(FetchDescriptor<Nota>())
        let textos = Set(notas.map(\.texto))
        for i in 1...7 { #expect(textos.contains("caderno antigo \(i)")) }
        #expect(notas.contains { $0.trancada }, "a nota selada continua selada")
        #expect(notas.contains { $0.queimada }, "a nota queimada continua queimada")
        // ADR 08u: nota gravada antes da origem é do autor.
        #expect(notas.allSatisfy { $0.origem == .autor })
        #expect(notas.contains { $0.sentido == "linha 3" })
    }
}

/// A RECEITA de um caderno congelado novo — e ela roda ANTES da mudança que
/// abre a versão seguinte, porque depois o build que grava aquela versão não
/// existe mais. Quem for abrir a V6 roda esta suíte no build da V5 ainda
/// intacto, pega o `.store` em `Documents/caderno-congelado/` do app-host
/// (`xcrun simctl get_app_container <UDID> app.traco data`) e o comita em
/// `TracoTests/Fixtures/caderno-v5-<nome>.store`, somando-o à lista acima.
///
/// Como teste, prova o outro lado da mesma moeda: o build de hoje grava um
/// caderno no disco e o relê inteiro.
@MainActor
struct GerarCadernoCongelado {
    @Test func gravaEReleOCadernoDaVersaoCorrente() throws {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pasta = docs.appendingPathComponent("caderno-congelado", isDirectory: true)
        try? FileManager.default.removeItem(at: pasta)
        try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        let url = pasta.appendingPathComponent("default.store")

        // O MESMO conteúdo do `caderno-v4-pre08u`: o portão compara maçã com maçã.
        let container = try ModelContainer.traco(url: url)
        let ctx = container.mainContext
        for i in 1...7 {
            let n = Nota(texto: "caderno antigo \(i)", sentido: "linha \(i)")
            n.minutosEscritos = i
            if i == 3 { n.trancada = true }
            if i == 5 { n.queimada = true; n.queimadaEm = .now }
            ctx.insert(n)
        }
        ctx.insert(ReciboEntrada(chave: "pre-08u"))
        try ctx.save()
        #expect(try ctx.fetch(FetchDescriptor<Nota>()).count == 7)
        print("CADERNO-CONGELADO em \(url.path)")
    }
}

/// Só para achar o bundle de testes em tempo de execução.
private final class MarcaDoBundleDeTestes {}

nonisolated struct CadernoCongelado: Sendable, CustomStringConvertible {
    let arquivo: String
    let notas: Int
    var description: String { arquivo }
}
