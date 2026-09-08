import Testing
@testable import Traco

/// ADR 2026-09-08l: a terceira linha do Perfil — o que a medida reprovou.
struct PerfilQualidadeTests {
    private func r(_ op: Politica.Operacao, _ data: String?, conserto: String? = nil) -> PerfilView.Reprovada {
        .init(op: op, motivo: "motivo", medidaEm: data, conserto: conserto)
    }

    @Test("a terceira lista é exatamente o que a tabela diz estar indisponível por qualidade")
    func listaVemDaTabela() {
        #expect(PerfilView.reprovadas.map(\.op) == Politica.indisponiveis)
        for x in PerfilView.reprovadas { #expect(!x.motivo.isEmpty, "\(x.op) sem motivo") }
    }

    @Test("data compartilhada sobe para a abertura; datas diferentes descem à linha")
    func dataNoLugarCerto() {
        let mesma = [r(.ecos, "08/09/2026"), r(.calibragem, "08/09/2026")]
        #expect(PerfilView.dataDe(mesma) == " de 08/09")
        #expect(PerfilView.restoDa(mesma[0], dataNaLinha: PerfilView.dataDe(mesma).isEmpty) == " — motivo")
        let mista = [r(.ecos, "08/09/2026"), r(.calibragem, "09/09/2026")]
        #expect(PerfilView.dataDe(mista) == "")
        #expect(PerfilView.restoDa(mista[1], dataNaLinha: true) == " — motivo · 09/09")
        #expect(PerfilView.dataDe([r(.ecos, nil)]) == "")
    }

    @Test("conserto nomeado aparece na linha; sem conserto, nada promete")
    func consertoNaLinha() {
        #expect(PerfilView.restoDa(r(.responder, "08/09/2026", conserto: "exigir fonte"), dataNaLinha: false)
                == " — motivo · conserto: exigir fonte")
        #expect(!PerfilView.restoDa(r(.ecos, "08/09/2026"), dataNaLinha: false).contains("conserto"))
    }

    /// Q-E: a linha deixou de ser `Text + Text` (obsoleto no iOS 26). O que não
    /// pode mudar: só o NOME leva a tinta suave, o resto vai sem cor própria, e
    /// o texto é o mesmo de antes — verbatim, sem passar por Markdown.
    @Test("a linha compõe nome tingido mais resto sem cor, e o texto não muda")
    func linhaTingeSoONome() {
        let caso = r(.responder, "08/09/2026", conserto: "exigir fonte")
        let linha = PerfilView.linhaDa(caso, dataNaLinha: false)
        #expect(String(linha.characters)
                == Politica.nome(.responder) + PerfilView.restoDa(caso, dataNaLinha: false))
        let tingidos = linha.runs.filter { $0.foregroundColor == Tema.tintaSuave }
        #expect(tingidos.count == 1)
        #expect(tingidos.first.map { String(linha[$0.range].characters) } == Politica.nome(.responder))
    }
}
