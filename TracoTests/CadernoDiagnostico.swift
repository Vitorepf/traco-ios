import Testing
@testable import Traco

/// Diagnóstico com REDUÇÃO: pega cada documento que quebra uma lei e vai
/// cortando pedaços enquanto continuar quebrando, até sobrar o caso mínimo.
/// Um contraexemplo de uma linha se conserta; um de sete linhas se discute.
struct CadernoDiagnostico {

    /// As leis, como predicados que devolvem o nome da quebra (ou nil).
    static let leis: [(nome: String, quebra: (String) -> Bool)] = [
        ("reparse-muda", { d in
            let um = Caderno.fatias(d)
            let dois = Caderno.fatias(um.map(\.fonte).joined(separator: "\n\n"))
            return CadernoFuzzTests.comConteudo(um) != CadernoFuzzTests.comConteudo(dois)
        }),
        ("aplicar-identico-muda", { d in
            let fs = Caderno.fatias(d)
            guard let alvo = fs.first else { return false }
            let depois = Caderno.aplicar(fs, id: alvo.id, novo: alvo.fonte)
            return CadernoFuzzTests.comConteudo(Caderno.fatias(depois)) != CadernoFuzzTests.comConteudo(fs)
        }),
        ("conteudo-vira-vazio", { d in
            guard !d.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            let fs = Caderno.fatias(d)
            if fs.isEmpty { return true }
            let algum = fs.contains { !Caderno.textoVisivel($0.bloco).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                || fs.contains { if case .paragrafo = $0.bloco { false } else { true } }
            return !algum
        }),
    ]

    /// Corta linhas enquanto a quebra sobreviver.
    static func reduzir(_ doc: String, _ quebra: (String) -> Bool) -> String {
        var atual = doc
        var mudou = true
        while mudou {
            mudou = false
            let linhas = atual.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            guard linhas.count > 1 else { break }
            for i in linhas.indices {
                var menor = linhas
                menor.remove(at: i)
                let cand = menor.joined(separator: "\n")
                if quebra(cand) {
                    atual = cand
                    mudou = true
                    break
                }
            }
        }
        return atual
    }

    @Test func casosMinimos() {
        let docs = CadernoFuzzTests.documentos(quantos: 500, semente: 20260831)
            + CadernoFuzzTests.documentos(quantos: 500, semente: 7717)
            + CadernoFuzzTests.documentos(quantos: 500, semente: 31337)
            + CadernoFuzzTests.documentos(quantos: 500, semente: 1234)
        for (nome, quebra) in Self.leis {
            var minimos = Set<String>()
            for d in docs where quebra(d) {
                minimos.insert(Self.reduzir(d, quebra))
            }
            print("=== \(nome): \(minimos.count) casos mínimos ===")
            for m in minimos.sorted().prefix(12) {
                print("   \(m.debugDescription)")
                print("     prosa   → \(Caderno.prosa(de: m).debugDescription)")
                print("     visivel → \(Caderno.visivel(m).debugDescription)")
                print("     blocos  → \(Caderno.fatias(m).map { Caderno.chave($0.bloco) })")
            }
        }
        print("=== FIM MINIMOS ===")
    }
}
