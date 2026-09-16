import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-16e — o resultado ajusta as regras; o «serviu», nunca.
@MainActor @Suite(.serialized)
struct ResultadoAjustaRegrasTests {
    static let biblioteca = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "ferramentas/obras/biblioteca")

    static func obras() throws -> [String] {
        try ["hormozi.md", "lenny.md"].map { arquivo in
            let bruto = try String(contentsOf: biblioteca.appending(path: arquivo), encoding: .utf8)
            return try #require(Corpus.importar(bruto).first).texto
        }
    }

    static let consulta = "baixar o preço da mentoria porque os clientes estão cancelando\nbaixar o preço\nmanter e dar mais valor\no que segura o cliente"

    @Test func oSaldoSoValeNasPalavrasDaForma() {
        #expect(Conselho.saldo("Aquém") == .aquem && Conselho.saldo("ficou aquem do que eu esperava") == .aquem)
        #expect(Conselho.saldo("igual") == .igual && Conselho.saldo("Além!") == .alem)
        #expect(Conselho.saldo("não sei, entre igual e além") == nil, "duas respostas não são saldo")
        #expect(Conselho.saldo("foi ótimo") == nil)
        // revisão E4: negação e "nada além" não viram o contrário
        #expect(Conselho.saldo("não ficou aquém") == nil)
        #expect(Conselho.saldo("nada além do que eu esperava") == nil)
        #expect(Conselho.saldo("Além do que eu esperava") == .alem)
    }

    /// A prova do plano: a regra que falhou duas vezes cai no ranking.
    @Test func aRegraQueFalhouDuasVezesCaiNoRanking() throws {
        let obras = try Self.obras()
        let antes = try #require(Conselho.escolher(consulta: Self.consulta, obras: obras, pesos: [:]))
        let chave = antes.regra.secao.chave
        let aquem = Sinal(tipo: .resultado, regra: chave, saldo: Conselho.Saldo.aquem.rawValue)
        let umaVez = Obra.ranquear(pergunta: Self.consulta, textos: obras, pesos: Conselho.pesos([aquem]))
        let duasVezes = Obra.ranquear(pergunta: Self.consulta, textos: obras, pesos: Conselho.pesos([aquem, aquem]))
        let posicao = { (achados: [Obra.Achado]) in achados.firstIndex { $0.secao.chave == chave } ?? .max }
        #expect(posicao(duasVezes) > 0, "a que falhou 2x deixa o primeiro lugar")
        #expect(posicao(duasVezes) >= posicao(umaVez))
        let depois = try #require(Conselho.escolher(consulta: Self.consulta, obras: obras, pesos: Conselho.pesos([aquem, aquem])),
                                  "o peso não pode calar a exposição")
        #expect(depois.regra.secao.chave != chave)
        // além sobe; igual não mexe
        let alem = Sinal(tipo: .resultado, regra: chave, saldo: Conselho.Saldo.alem.rawValue)
        let igual = Sinal(tipo: .resultado, regra: chave, saldo: Conselho.Saldo.igual.rawValue)
        #expect(Conselho.pesos([alem])[chave]! > 1 && Conselho.pesos([igual])[chave] == 1)
        #expect(Conselho.pesos(Array(repeating: alem, count: 20))[chave] == 2, "teto")
        #expect(Conselho.pesos(Array(repeating: aquem, count: 20))[chave] == 0.2, "piso")
    }

    /// Aprender por aprovação é sicofancia: «não serviu» não mexe no peso.
    @Test func oServiuNuncaPesa() throws {
        let obras = try Self.obras()
        let antes = try #require(Conselho.escolher(consulta: Self.consulta, obras: obras, pesos: [:]))
        let chave = antes.regra.secao.chave
        let naoServiu = [Sinal(tipo: .resposta, serviu: false, texto: antes.regra.secao.texto, regra: chave),
                         Sinal(tipo: .pergunta, serviu: false, texto: chave, regra: chave),
                         Sinal(tipo: .exposto, texto: antes.regra.secao.texto, regra: chave)]
        #expect(Conselho.pesos(naoServiu).isEmpty)
    }

    /// Ponta a ponta: a Decisão exposta, reaberta com "aconteceu" e "saldo",
    /// dá o saldo à regra UMA vez; sem saldo legível, nada.
    @Test func aVoltaDaDecisaoDaOSaldoARegraExposta() throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("resultado-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let corpus = Corpus.diretorio, espelho = PastaEspelho.defaults, sinais = Sinais.url
        let nome = "resultado-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Corpus.diretorio = raiz; PastaEspelho.defaults = defaults; Sinais.url = raiz.appendingPathComponent("sinais.json")
        defer {
            Corpus.diretorio = corpus; PastaEspelho.defaults = espelho; Sinais.url = sinais
            defaults.removePersistentDomain(forName: nome); try? FileManager.default.removeItem(at: raiz)
        }
        let c = try ModelContainer.traco(emMemoria: true)
        for texto in try Self.obras() { let n = Nota(texto: texto); n.origem = .obra; c.mainContext.insert(n) }
        try c.mainContext.save()
        let s = Sessao()
        s.texto = "Baixar ou não o preço da mentoria porque os clientes estão cancelando"
        s.gesto = .decisao
        s.campos = ["escolha": s.texto, "opcoes": "baixar o preço\nmanter e dar mais valor",
                    "criterio": "o que segura o cliente sem cortar o faturamento",
                    "decidido": "manter o preço", "espero": "cancelamento cai em 60 dias"]
        s.concluir(no: c.mainContext)
        let exposto = try #require(Sinais.todos().first { $0.tipo == .exposto })
        let nota = try #require(c.mainContext.fetch(FetchDescriptor<Nota>()).first { $0.gesto == .decisao })
        // volta sem saldo legível: nada
        s.abrir(nota)
        s.campos["aconteceu"] = "cancelaram dois"
        s.campos["saldo"] = "não sei"
        s.concluir(no: c.mainContext)
        #expect(Sinais.todos().filter { $0.tipo == .resultado }.isEmpty)
        // com o saldo nas palavras da forma: uma vez
        s.abrir(nota)
        s.campos["saldo"] = "Aquém"
        s.concluir(no: c.mainContext)
        s.abrir(nota)
        s.concluir(no: c.mainContext)
        let resultados = Sinais.todos().filter { $0.tipo == .resultado }
        #expect(resultados.count == 1)
        #expect(resultados.first?.regra == exposto.regra && resultados.first?.saldo == "aquem")
        #expect(Conselho.pesos(Sinais.todos())[exposto.regra ?? ""] == 0.6)
        // o autor corrige o saldo: vale o último
        s.abrir(nota)
        s.campos["saldo"] = "igual"
        s.concluir(no: c.mainContext)
        #expect(Conselho.pesos(Sinais.todos())[exposto.regra ?? ""] == 1)
        // 600 sinais depois, a exposição e o resultado continuam no diário
        for _ in 0..<600 { Sinais.registrar(Sinal(tipo: .ficou, forma: "woop")) }
        let diario = Sinais.todos()
        #expect(diario.count == Sinais.teto)
        #expect(diario.contains { $0.tipo == .exposto && $0.nota == nota.uuid })
        #expect(diario.filter { $0.tipo == .resultado }.count == 2)
    }
}
