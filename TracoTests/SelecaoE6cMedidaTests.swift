import Foundation
import SwiftData
import Testing
@testable import Traco

/// E6c, a medida SEM IA da seleção de candidatas (registrada em prova/e6/LEIA.md antes de rodar).
/// É instrumento, não portão: só roda com `TRACO_MEDIR_E6C` e grava `prova/e6c/selecao-sem-ia.json`.
@MainActor @Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["TRACO_MEDIR_E6C"] != nil))
struct SelecaoE6cMedidaTests {
    static let pasta = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("prova/e6c")

    struct CadernoE6c: Decodable {
        struct N: Decodable { var id: String; var texto: String; var editadaEm: String }
        struct E: Decodable { var id: String; var nota: String; var esperadas: [String]; var tipo: String }
        struct P: Decodable { var id: String; var pergunta: String; var esperadas: [String]; var controle: Bool }
        var notas: [N]; var ecos: [E]; var perguntas: [P]
    }

    /// O braço B, só aqui: 20 recentes + 20 pelas palavras raras da nota.
    static func bracoB(texto: String, todas: [Nota], excetoId: UUID) -> [Nota] {
        let podem = todas.filter { $0.uuid != excetoId }.sorted { $0.editadaEm > $1.editadaEm }
        let recentes = Array(podem.prefix(20))
        let opcoes: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        let corpos = podem.map { String($0.texto.prefix(3000)) }
        let consulta = Array(NotasFiltro.palavras(String(texto.prefix(3000))).sorted { $0.count > $1.count }.prefix(40))
        let raras = consulta.filter { p in corpos.filter { $0.range(of: p, options: opcoes) != nil }.count * 5 <= max(podem.count, 5) }
        let ja = Set(recentes.map(\.uuid))
        var pontuadas: [(nota: Nota, pontos: Int)] = []
        for (nota, corpo) in zip(podem, corpos) where !ja.contains(nota.uuid) {
            let pontos = NotasFiltro.pontuacao(corpo, palavras: raras)
            if pontos > 0 { pontuadas.append((nota, pontos)) }
        }
        pontuadas.sort { a, b in a.pontos == b.pontos ? a.nota.editadaEm > b.nota.editadaEm : a.pontos > b.pontos }
        return recentes + pontuadas.prefix(20).map { $0.nota }
    }

    @Test func medirASelecaoSemIA() throws {
        let caderno = try JSONDecoder().decode(CadernoE6c.self, from: Data(contentsOf: Self.pasta.appendingPathComponent("caderno.json")))
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let iso = ISO8601DateFormatter()
        var porId: [String: Nota] = [:]
        for n in caderno.notas {
            let nota = Nota(texto: n.texto, editadaEm: try #require(iso.date(from: n.editadaEm)))
            ctx.insert(nota); porId[n.id] = nota
        }
        try ctx.save()
        let todas = Array(porId.values)
        var ecos: [[String: Any]] = []
        for e in caderno.ecos {
            let nota = try #require(porId[e.nota])
            let a = Set(Sessao.candidatasDeEcos(de: nota.uuid, todas: todas, jaLigadas: []).map(\.uuid))
            let b = Set(Self.bracoB(texto: Caderno.prosa(de: nota.texto), todas: todas, excetoId: nota.uuid).map(\.uuid))
            ecos.append(["id": e.id, "tipo": e.tipo,
                         "esperadas": e.esperadas,
                         "emA_40recentes": e.esperadas.filter { a.contains(porId[$0]!.uuid) },
                         "emB_20recentes20palavras": e.esperadas.filter { b.contains(porId[$0]!.uuid) }])
        }
        var perguntas: [[String: Any]] = []
        for p in caderno.perguntas {
            let ids = Set(Sessao.candidatasDoAutor(pergunta: p.pergunta, no: ctx).map(\.id))
            perguntas.append(["id": p.id, "controle": p.controle, "esperadas": p.esperadas,
                              "emCandidatasDoAutor30": p.esperadas.filter { ids.contains(porId[$0]!.uuid) }])
        }
        // tempo com 400 notas: o caderno e mais 164 cópias com outra data
        for (i, n) in caderno.notas.prefix(164).enumerated() {
            ctx.insert(Nota(texto: n.texto, editadaEm: Date(timeIntervalSince1970: 1_700_000_000 + Double(i))))
        }
        try ctx.save()
        let quatrocentas = try ctx.fetch(FetchDescriptor<Nota>())
        let longa = try #require(caderno.notas.max { $0.texto.count < $1.texto.count }).texto
        func ms(_ bloco: () -> Void) -> Double {
            let t0 = Date(); for _ in 0..<5 { bloco() }; return Date().timeIntervalSince(t0) / 5 * 1000
        }
        let tempos: [String: Any] = [
            "notas": quatrocentas.count,
            "A_ms": ms { _ = Sessao.candidatasDeEcos(de: nil, todas: quatrocentas, jaLigadas: []) },
            "B_ms_notaLonga": ms { _ = Self.bracoB(texto: longa, todas: quatrocentas, excetoId: UUID()) },
            "candidatasDoAutor_ms": ms { _ = Sessao.candidatasDoAutor(pergunta: caderno.perguntas[0].pergunta, no: ctx) },
        ]
        let soma: ([[String: Any]], String) -> Int = { lista, chave in lista.reduce(0) { $0 + (($1[chave] as? [String])?.count ?? 0) } }
        let saida: [String: Any] = [
            "caderno": "prova/e6c/caderno.json", "ecos": ecos, "perguntas": perguntas, "tempos400": tempos,
            "resumo": ["esperadasEcos": soma(ecos, "esperadas"), "emA": soma(ecos, "emA_40recentes"),
                       "emB": soma(ecos, "emB_20recentes20palavras"),
                       "perguntasSemPalavra": perguntas.filter { !($0["controle"] as! Bool) }.count,
                       "perguntasSemPalavraAchadas": perguntas.filter { !($0["controle"] as! Bool) && !(($0["emCandidatasDoAutor30"] as? [String]) ?? []).isEmpty }.count,
                       "controlesAchados": perguntas.filter { ($0["controle"] as! Bool) && !(($0["emCandidatasDoAutor30"] as? [String]) ?? []).isEmpty }.count],
        ]
        let dados = try JSONSerialization.data(withJSONObject: saida, options: [.prettyPrinted, .sortedKeys])
        try dados.write(to: Self.pasta.appendingPathComponent("selecao-sem-ia.json"))
        #expect(!dados.isEmpty)
    }
}
