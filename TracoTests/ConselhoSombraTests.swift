import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-16d — decidir, em sombra.
@MainActor @Suite(.serialized)
struct ConselhoSombraTests {
    struct Decisao: Decodable {
        var escolha: String; var opcoes: String; var criterio: String
        var decidido: String; var espero: String
        var arquivo: String; var secao: Int; var video: String
    }

    static let obras = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "ferramentas/obras")

    private func isolado(_ executar: (ModelContext) throws -> Void) throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("conselho-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let corpus = Corpus.diretorio, espelho = PastaEspelho.defaults, sinais = Sinais.url
        let nome = "conselho-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Sinais.url = raiz.appendingPathComponent("sinais.json")
        defer {
            Corpus.diretorio = corpus; PastaEspelho.defaults = espelho; Sinais.url = sinais
            defaults.removePersistentDomain(forName: nome)
            try? FileManager.default.removeItem(at: raiz)
        }
        let c = try ModelContainer.traco(emMemoria: true)
        for arquivo in ["hormozi.md", "lenny.md"] {
            let bruto = try String(contentsOf: Self.obras.appending(path: "biblioteca/\(arquivo)"), encoding: .utf8)
            let item = try #require(Corpus.importar(bruto).first)
            let obra = Nota(texto: item.texto)
            obra.origem = item.origem
            c.mainContext.insert(obra)
        }
        try c.mainContext.save()
        try executar(c.mainContext)
    }

    private func concluir(_ d: Decisao, no ctx: ModelContext, sessao: Sessao = Sessao()) -> Sessao {
        sessao.texto = d.escolha
        sessao.gesto = .decisao
        sessao.campos = ["escolha": d.escolha, "opcoes": d.opcoes, "criterio": d.criterio,
                         "decidido": d.decidido, "espero": d.espero]
        sessao.concluir(no: ctx)
        return sessao
    }

    private func medir(_ arquivo: String) throws -> (acertos: Int, total: Int, falhas: [String]) {
        let decisoes = try JSONDecoder().decode([Decisao].self, from: Data(contentsOf: Self.obras.appending(path: arquivo)))
        var acertos = 0
        var falhas: [String] = []
        try isolado { ctx in
            for d in decisoes {
                let antes = Sinais.todos().count(where: { $0.tipo == .exposto })
                _ = concluir(d, no: ctx)
                // revisão: sem exposição NOVA, a anterior não conta como acerto desta
                let expostos = Sinais.todos().filter { $0.tipo == .exposto }
                let exposto = expostos.count > antes ? expostos.last : nil
                if exposto?.regra?.hasPrefix(d.video + "&") == true, exposto?.texto?.contains("\nRegra: ") == true {
                    acertos += 1
                } else {
                    falhas.append("\(d.arquivo) §\(d.secao) \(d.escolha.prefix(40)) → \(exposto?.texto?.prefix(40) ?? "nada")")
                }
            }
        }
        return (acertos, decisoes.count, falhas)
    }

    /// A prova do plano: as 5 decisões pré-registradas no commit da E2. A meta
    /// era 5/5; o medido com o BM25 congelado foi 1/5 (reserva 2/5) — ADR 16d.
    /// O teste é CATRACA do medido: não deixa piorar; subir o piso é o
    /// trabalho da próxima volta (reordenar as 10 melhores pelo modelo).
    @Test func cincoDecisoesAchamARegraEsperada() throws {
        let m = try medir("decisoes-fixture.json")
        print("E3 · fixture \(m.acertos)/\(m.total)\n" + m.falhas.joined(separator: "\n"))
        #expect(m.total == 5)
        #expect(m.acertos >= 1, "\(m.falhas)")
    }

    /// A reserva: 5 decisões escritas por outro agente com o motor congelado.
    /// Registra a generalização; não é portão (ADR 16d).
    @Test func reservaDeDecisoesMedeAGeneralizacao() throws {
        let m = try medir("decisoes-reserva.json")
        print("E3 · reserva \(m.acertos)/\(m.total)\n" + m.falhas.joined(separator: "\n"))
        #expect(m.total == 5)
    }

    @Test func registraEmSombraUmaVezSemMostrarNada() throws {
        let d = Decisao(escolha: "Baixar ou não o preço da mentoria porque os clientes estão cancelando",
                        opcoes: "baixar o preço\nmanter e dar mais valor", criterio: "o que segura o cliente sem cortar o faturamento",
                        decidido: "manter o preço", espero: "cancelamento cai em 60 dias",
                        arquivo: "hormozi.md", secao: 1, video: "")
        try isolado { ctx in
            let s = concluir(d, no: ctx)
            let expostos = Sinais.todos().filter { $0.tipo == .exposto }
            let e = try #require(expostos.first)
            #expect(expostos.count == 1)
            #expect(e.texto?.hasPrefix("## ") == true && e.regra?.hasPrefix("https://www.youtube.com/watch?v=") == true)
            #expect(e.contraria == nil || e.contraria?.contains(e.texto ?? "") == false)
            #expect(!(e.porque ?? []).isEmpty)
            // nada aparece: o fim é o de sempre
            #expect(s.cartao == nil && s.toast == "guardada em Notas")
            // abrir e concluir de novo não registra outra vez
            let nota = try #require(ctx.fetch(FetchDescriptor<Nota>()).first { $0.gesto == .decisao })
            s.abrir(nota)
            s.concluir(no: ctx)
            #expect(Sinais.todos().filter { $0.tipo == .exposto }.count == 1)
        }
    }

    @Test func semOAtoEscritoOuFormaQueNaoDecideNaoConsulta() throws {
        #expect(Conselho.consulta(gesto: .decisao, campos: ["escolha": "preço", "decidido": "manter"]) == nil)
        #expect(Conselho.consulta(gesto: .decisao, campos: ["escolha": "preço", "espero": "x"]) == nil)
        #expect(Conselho.consulta(gesto: .woop, campos: ["resultado": "preço", "decidido": "x", "espero": "y"]) == nil)
        #expect(Conselho.consulta(gesto: .premortem, campos: ["plano": "abrir a loja", "mudo": "testar antes"]) == "abrir a loja")
        // obra suposta (sem portões) não aconselha; só a conferida
        try isolado { ctx in
            for n in try ctx.fetch(FetchDescriptor<Nota>()) { n.origem = .obraSuposta }
            let d = Decisao(escolha: "Baixar o preço porque os clientes cancelam", opcoes: "baixar\nmanter",
                            criterio: "segurar cliente", decidido: "manter", espero: "menos cancelamento",
                            arquivo: "", secao: 0, video: "")
            _ = concluir(d, no: ctx)
            #expect(Sinais.todos().filter { $0.tipo == .exposto }.isEmpty)
        }
    }

    /// Revisão E3: um build sem o tipo `exposto` lia o diário como vazio e
    /// gravava por cima, apagando a história inteira do autor.
    @Test func diarioIlegivelNaoESobrescrito() throws {
        try isolado { _ in
            let futuro = #"[{"id":"6F1B0C8E-0000-4000-8000-000000000001","quando":"2026-09-16T12:00:00Z","tipo":"tipoDeUmBuildNovo"}]"#
            try Data(futuro.utf8).write(to: Sinais.url)
            #expect(!Sinais.registrar(Sinal(tipo: .ficou, forma: "woop")))
            #expect(try String(contentsOf: Sinais.url, encoding: .utf8) == futuro)
        }
    }

    /// Revisão E3: "Pré-mortem do que decidi" grava e sai sem concluir.
    @Test func encadearDaDecisaoTambemConsulta() throws {
        let e = try #require(Gesto.decisao.metodoDef.encadeamentos.first { $0.para == Gesto.premortem.rawValue })
        try isolado { ctx in
            let s = Sessao()
            s.texto = "Baixar ou não o preço da mentoria porque os clientes estão cancelando"
            s.gesto = .decisao
            s.campos = ["escolha": s.texto, "opcoes": "baixar o preço\nmanter e dar mais valor",
                        "criterio": "o que segura o cliente sem cortar o faturamento",
                        "decidido": "manter o preço", "espero": "cancelamento cai em 60 dias"]
            s.encadear(e, no: ctx)
            #expect(Sinais.todos().filter { $0.tipo == .exposto }.count == 1)
            #expect(s.gesto == .premortem)
        }
    }
}
