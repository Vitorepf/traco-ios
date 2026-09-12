import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-12a / Q4 — classificar, vestir e domínio usam a tabela e o
/// classificador já existentes. Sem objeto Território, sem wizard de
/// taxonomia, sem painel novo. Domínio não vai à rede.
@MainActor
struct Q4CadernoUnicoTests {
    private var raiz: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
    }

    @Test func dominioContinuaSoBordoENaoHaOperacaoNova() {
        #expect(Politica.linha(.dominio).regra == .soBordo)
        #expect(Politica.provedor(.dominio, contaLigada: true, bordo: false) == nil)
        #expect(Politica.provedor(.dominio, contaLigada: true, bordo: true) == .bordo)
        #expect(Politica.provedor(.dominio, contaLigada: false, bordo: true) == .bordo)
        #expect(Politica.linha(.classificar).regra == .grokDepoisBordo)
        #expect(Politica.linha(.vestir).regra == .grokDepoisBordo)
        #expect(Politica.Operacao.allCases.count == 16)
    }

    @Test func oMotorDeDominioNaoChamaARede() throws {
        let bordo = try String(contentsOf: raiz.appending(path: "Traco/Analise/AnaliseDeBordo.swift"),
                               encoding: .utf8)
        let trecho = trechoDeFuncao(bordo, apos: "static func dominio(texto:")
        #expect(!trecho.isEmpty)
        #expect(!trecho.contains("Grok."))
        #expect(!trecho.contains("AnaliseRemota"))
        #expect(trecho.contains("LanguageModelSession"))
    }

    @Test func plantarInfereDominioDaNotaNaoDaPagina() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.dominio = .dinheiro
        s.dominioTravado = true
        let nota = try #require(s.plantarObra("Tratado das Nuvens Invertidas", no: c.mainContext))
        #expect(nota.dominio == Dominio.inferir(voz: nota.vozDoAutor))
        #expect(nota.dominio != .dinheiro)
        let sessao = try String(contentsOf: raiz.appending(path: "Traco/App/Sessao.swift"),
                                encoding: .utf8)
        #expect(sessao.contains("func plantarObra"))
        #expect(sessao.contains("Dominio.inferir(voz: nota.vozDoAutor)"))
        #expect(!trechoDePlantar(sessao).contains("aplicarDominio"))
    }

    @Test func oCodigoNaoInventaTerritorioNemWizardDeTaxonomia() throws {
        let fontes = try swiftEm(raiz.appending(path: "Traco"))
        var territorio: [String] = []
        var wizard: [String] = []
        for (nome, texto) in fontes {
            if texto.contains("enum Territorio") || texto.contains("struct Territorio")
                || texto.contains("enum Território") || texto.contains("struct Território")
                || texto.contains("class Territorio") || texto.contains("class Território") {
                territorio.append(nome)
            }
            if texto.contains("wizard-taxonomia") || texto.contains("WizardTaxonomia")
                || texto.contains("painel-taxonomia") || texto.contains("PainelTaxonomia") {
                wizard.append(nome)
            }
        }
        #expect(territorio.isEmpty, "objeto Território em \(territorio)")
        #expect(wizard.isEmpty, "wizard de taxonomia em \(wizard)")
    }

    private func trechoDePlantar(_ sessao: String) -> String {
        trechoDeFuncao(sessao, apos: "func plantarObra")
    }

    private func trechoDeFuncao(_ fonte: String, apos marca: String) -> String {
        guard let inicio = fonte.range(of: marca) else { return "" }
        let depois = fonte[inicio.lowerBound...]
        guard let fim = depois.range(of: "\n    static func ")
                ?? depois.range(of: "\n    func ") else { return String(depois.prefix(1200)) }
        return String(depois[..<fim.lowerBound])
    }

    private func swiftEm(_ pasta: URL) throws -> [(String, String)] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: pasta, includingPropertiesForKeys: nil) else { return [] }
        var saida: [(String, String)] = []
        while let url = enumerator.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            saida.append((url.lastPathComponent, try String(contentsOf: url, encoding: .utf8)))
        }
        return saida
    }
}
