import Testing
@testable import Traco

/// ADR 2026-09-08l: a terceira linha do Perfil — o que a IA ainda não faz.
/// ADR 2026-09-09z: e em que LÍNGUA ela o diz.
struct PerfilQualidadeTests {
    private func r(_ op: Politica.Operacao, conserto: String? = nil) -> PerfilView.Reprovada {
        .init(op: op, motivo: "motivo", conserto: conserto)
    }

    @Test("a terceira lista é exatamente o que a tabela diz estar indisponível por qualidade")
    func listaVemDaTabela() {
        #expect(PerfilView.reprovadas.map(\.op) == Politica.indisponiveis)
        for x in PerfilView.reprovadas { #expect(!x.motivo.isEmpty, "\(x.op) sem motivo") }
    }

    @Test("o conserto entra na linha dizendo o que falta; sem ele, nada promete")
    func consertoNaLinha() {
        #expect(PerfilView.restoDa(r(.responder, conserto: "falta ela citar a fonte"))
                == " — motivo · falta ela citar a fonte")
        #expect(PerfilView.restoDa(r(.ecos)) == " — motivo")
    }

    /// Q-E: a linha deixou de ser `Text + Text` (obsoleto no iOS 26). O que não
    /// pode mudar: só o NOME leva a tinta suave, o resto vai sem cor própria, e
    /// o texto é o mesmo de antes — verbatim, sem passar por Markdown.
    @Test("a linha compõe nome tingido mais resto sem cor, e o texto não muda")
    func linhaTingeSoONome() {
        let caso = r(.responder, conserto: "falta ela citar a fonte")
        let linha = PerfilView.linhaDa(caso)
        #expect(String(linha.characters)
                == Politica.nome(.responder) + PerfilView.restoDa(caso))
        let tingidos = linha.runs.filter { $0.foregroundColor == Tema.tintaSuave }
        #expect(tingidos.count == 1)
        #expect(tingidos.first.map { String(linha[$0.range].characters) } == Politica.nome(.responder))
    }

    /// ADR 2026-09-09z, ordem do dono (DIRETRIZ §13): o cartão CONTA fala a
    /// LÍNGUA DO AUTOR. Ele mandou a captura das 10h46 — "Indisponível mesmo
    /// com a conta Grok — a medida de 08/09 reprovou", "devolveu o vocabulário
    /// interno do app", "fato inventado" — e disse que aquilo é o nosso jargão
    /// na tela dele.
    ///
    /// O portão lê o TEXTO INTEIRO do cartão pelo caminho da tela, não a
    /// contagem de linhas: com as frases velhas, a data e "medida" derrubam
    /// este teste na primeira asserção. Contar grupos passava idêntico.
    @Test("o cartão CONTA não leva data, nem 'medida', nem o nosso plano de obra")
    func oCartaoFalaALinguaDoAutor() {
        let cartao = [PerfilView.oQueAIAFaz, PerfilView.oQueAContaAcrescenta,
                      PerfilView.aberturaSemConserto, PerfilView.aberturaEmCorrecao,
                      PerfilView.nadaCortado]
            + PerfilView.reprovadas.map { String(PerfilView.linhaDa($0).characters) }
        for frase in cartao {
            #expect(frase.range(of: #"\d\d/\d\d"#, options: .regularExpression) == nil,
                    "data na tela do autor: \(frase)")
            let baixo = frase.lowercased()
            for jargao in ["medida", "medido", "medimos", "reprov", "prompt", "esquema",
                           "fixture", "jsonl", "grok-4", "vocabulário interno", "fato inventado",
                           "contexto não sustent"] {
                #expect(!baixo.contains(jargao), "jargão nosso na tela do autor: '\(jargao)' em \(frase)")
            }
        }
    }

    /// O outro lado da mesma ordem: o cartão diz o que a IA FAZ por ele hoje —
    /// e hoje ela responde sobre as notas dele (ADR 09v). Se `responderNasNotas`
    /// voltar para a lista de cortadas sem medida nova, isto fica vermelho.
    @Test("a primeira linha do cartão é o que a IA faz, e responder nas Notas está lá")
    func oCartaoAbreComOQueElaFaz() {
        #expect(PerfilView.oQueAIAFaz.hasPrefix("A IA faz por você"))
        #expect(PerfilView.oQueAContaAcrescenta.contains(Politica.nome(.responderNasNotas)))
        #expect(!PerfilView.reprovadas.contains { $0.op == .responderNasNotas })
    }

    /// Cada uma das seis cortadas fala do EFEITO para o autor, no presente.
    /// Guardado pela frase, uma a uma: um portão que só conta as seis passaria
    /// igual com o texto de diagnóstico que o dono fotografou.
    @Test("as seis linhas cortadas dizem o que acontece com ele, não o nosso diagnóstico")
    func cadaLinhaCortadaFalaDoAutor() throws {
        let esperado: [Politica.Operacao: String] = [
            .ecos: "deixa de fora justamente as notas que mais tinham a ver",
            .calibragem: "não diz nada quando você não errou",
            .recordar: "entrega a resposta junto com a pergunta",
            .responder: "inventa uma situação que você não escreveu",
            .instigar: "quando você diz que não sabe quando foi, ela pergunta assim mesmo",
            .contrapor: "inventa uma renda que você não escreveu",
        ]
        #expect(Set(esperado.keys) == Set(Politica.indisponiveis))
        for (op, frase) in esperado {
            let r = try #require(PerfilView.reprovadas.first { $0.op == op })
            #expect(String(PerfilView.linhaDa(r).characters).contains(frase), "\(op): \(r.motivo)")
        }
        // As três em correção dizem o que FALTA, começando pela palavra que o
        // autor entende — nunca "o prompt", "o modelo" ou "falta medir".
        for op in [Politica.Operacao.responder, .instigar, .contrapor] {
            let c = try #require(Politica.linha(op).conserto)
            #expect(c.hasPrefix("falta ela "), "\(op): o conserto não fala com ele — \(c)")
            #expect(!c.contains("falta medir"), "\(op): agenda nossa na tela — \(c)")
        }
    }
}
