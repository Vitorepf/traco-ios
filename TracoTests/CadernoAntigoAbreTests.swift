import Foundation
import SwiftData
import Testing
@testable import Traco

/// O PORTÃO da migração (ADR 2026-09-09f). Cada arquivo em `TracoTests/Fixtures`
/// é um caderno REAL, gravado com a forma VIVA do build daquela versão e nunca
/// mais tocado. O teste abre cada um com o container do app de hoje e conta as
/// notas.
///
/// **Cada versão do plano tem o seu** — e a frase só vale porque a lista abaixo
/// tem uma linha para cada entrada de `TracoMigracao.schemas`; o teste
/// `oPortaoTemUmCadernoPorVersao` recusa a lista se alguém abrir uma versão sem
/// gravar o caderno dela.
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
    /// Cadernos congelados, um por versão do plano, com o que cada um leva.
    /// A contagem é distinta de propósito: se o teste abrisse o arquivo errado,
    /// a conta denunciaria.
    nonisolated static let cadernos: [CadernoCongelado] = [
        // A primeira 1.0.0 (`b7fbc3e`, 31/08 08:27): a `Nota` só tinha texto e
        // selo. Sem `sentido`, sem queima — as colunas não existiam.
        CadernoCongelado(arquivo: "caderno-v0-b7fbc3e", prefixo: "caderno v0",
                         notas: 3, temSentido: false, temQueimada: false),
        // A segunda 1.0.0 (`fea00dd`, 31/08 16:31): entrou o fecho expressivo.
        CadernoCongelado(arquivo: "caderno-v1-fea00dd", prefixo: "caderno v1", notas: 4),
        // 2.0.0 (`bf535c5`, 02/09): entraram domínio, gatilho e série.
        CadernoCongelado(arquivo: "caderno-v2-bf535c5", prefixo: "caderno v2", notas: 5),
        // 3.0.0: degrau do plano. NENHUM build a gravou em campo — ela nasceu e
        // foi superada dentro do mesmo commit (`9ad639e`), que já abria o
        // container pela V4. O caderno aqui usa a `Nota` viva de `bf535c5` e o
        // `ReciboEntrada` vivo de `9ad639e`, que é a forma que a 3.0.0 teria.
        CadernoCongelado(arquivo: "caderno-v3-degrau", prefixo: "caderno v3", notas: 6),
        // 4.0.0 (`9ad639e` até a 08u): a versão do caderno do autor.
        CadernoCongelado(arquivo: "caderno-v4-pre08u", prefixo: "caderno antigo", notas: 7),
        // 5.0.0: a versão corrente, gravada pelo build desta volta.
        CadernoCongelado(arquivo: "caderno-v5-origem", prefixo: "caderno antigo", notas: 7),
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

    /// A frase "cada versão" tem de ter cada versão: uma linha na lista por
    /// entrada do plano. Quem abrir a V6 e esquecer o caderno dela vê vermelho
    /// aqui — e vê ANTES de a mudança chegar ao aparelho do autor.
    @Test func oPortaoTemUmCadernoPorVersao() {
        #expect(Self.cadernos.count == TracoMigracao.schemas.count,
                "o plano tem \(TracoMigracao.schemas.count) versões e o portão \(Self.cadernos.count) cadernos")
    }

    @Test(arguments: cadernos)
    func cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno: CadernoCongelado) throws {
        let url = try copiar(caderno.arquivo)
        let container = try ModelContainer.traco(url: url)
        let notas = try container.mainContext.fetch(FetchDescriptor<Nota>())
        #expect(notas.count == caderno.notas,
                "\(caderno.arquivo): esperava \(caderno.notas) notas, achei \(notas.count)")
        #expect(notas.allSatisfy { !$0.texto.isEmpty }, "\(caderno.arquivo): nota sem texto")

        // O texto do autor atravessa inteiro, não só a contagem.
        let textos = Set(notas.map(\.texto))
        for i in 1...caderno.notas {
            #expect(textos.contains("\(caderno.prefixo) \(i)"),
                    "\(caderno.arquivo): sumiu \(caderno.prefixo) \(i)")
        }
        // O selo é da primeira versão em diante; a queima e o sentido, da
        // segunda 1.0.0 em diante.
        #expect(notas.contains { $0.trancada }, "\(caderno.arquivo): a nota selada continua selada")
        if caderno.temQueimada {
            #expect(notas.contains { $0.queimada }, "\(caderno.arquivo): a nota queimada continua queimada")
        }
        if caderno.temSentido {
            #expect(notas.contains { $0.sentido == "linha 3" }, "\(caderno.arquivo): sumiu o sentido")
        }
        // ADR 08u: nota gravada antes da origem é do autor.
        #expect(notas.allSatisfy { $0.origem == .autor }, "\(caderno.arquivo): origem que não é do autor")
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
    let prefixo: String
    let notas: Int
    var temSentido: Bool = true
    var temQueimada: Bool = true
    var description: String { arquivo }
}
