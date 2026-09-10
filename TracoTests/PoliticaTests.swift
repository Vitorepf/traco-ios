import Testing
@testable import Traco

/// ADR 07b — a tabela de quem responde. O teste trava o que a medição de
/// 07/09 decidiu: onde o aparelho reprovou, a falta de conta é silêncio DITO,
/// nunca uma descida calada ao modelo pior.
@Suite struct PoliticaTests {
    @Test func todaOperacaoTemRegraEProva() {
        for op in Politica.Operacao.allCases {
            let l = Politica.linha(op)
            #expect(!l.porque.isEmpty, "\(op) sem evidência")
            #expect(!Politica.semProvedor(op).isEmpty, "\(op) sem frase para a tela")
            #expect(!Politica.nome(op).isEmpty)
        }
    }

    @Test func ondeOAparelhoReprovouSemContaNinguemResponde() {
        let medidas: [Politica.Operacao] = [.produzir, .prepararPratica, .conferirTentativa, .revisar,
                                            .conferir, .padroes]
        for op in medidas {
            #expect(Politica.linha(op).regra == .soGrok, "\(op)")
            #expect(Politica.provedor(op, contaLigada: false, bordo: true) == nil, "\(op) desceu ao aparelho")
            #expect(Politica.provedor(op, contaLigada: true, bordo: true) == .grok)
            #expect(!Politica.desceAoAparelho(op))
        }
    }

    @Test func aEscadaDesceAoAparelhoSoOndeATabelaDeixa() {
        #expect(Politica.provedor(.classificar, contaLigada: false, bordo: true) == .bordo)
        #expect(Politica.provedor(.classificar, contaLigada: true, bordo: true) == .grok)
        #expect(Politica.provedor(.classificar, contaLigada: false, bordo: false) == nil)
        #expect(Politica.desceAoAparelho(.classificar))
        // o domínio nunca vai à rede, com ou sem conta
        #expect(Politica.provedor(.dominio, contaLigada: true, bordo: false) == nil)
        #expect(Politica.provedor(.dominio, contaLigada: true, bordo: true) == .bordo)
    }

    @Test func oPerfilListaAsDezesseisSemRepetir() {
        let todas = Politica.pelaConta + Politica.peloAparelho + Politica.indisponiveis
        #expect(Set(todas).count == Politica.Operacao.allCases.count)
        #expect(todas.count == Politica.Operacao.allCases.count)
    }

    /// ADR 08q: com a conta LIGADA, as cortadas continuam sem executor — e a
    /// frase da tela não pode mandar conectar a conta que já existe.
    /// ADR 09n: `responder` saiu desta lista às 14h01 de 09/09 e VOLTOU às 15h,
    /// quando o G3 reprovou a escolha do modelo — a comparação mudou duas
    /// alavancas e não decidia o padrão global. São sete de novo. Quem tirar
    /// uma sem medida nova, PAREADA, quebra aqui — e a Q2-F (09q) FEZ a medida
    /// pareada: nenhum dos três modelos que a conta serve passou os 18 casos.
    @Test func indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho() {
        let cortadas: [Politica.Operacao] = [.ecos, .calibragem, .recordar, .responderNasNotas,
                                            .instigar, .contrapor, .responder]
        #expect(Set(Politica.indisponiveis) == Set(cortadas))
        // ADR 08z: a chave da sonda só existe em DEBUG e só abre o que ela
        // nomeia. Aqui ela tem de estar VAZIA — uma suíte que rodasse com a
        // variável ligada mediria outra tabela e não a do autor.
        #expect(Politica.liberadasParaAvaliacao.isEmpty, "a suíte correu com operações liberadas para avaliação")
        for op in cortadas {
            #expect(Politica.linha(op).regra == .indisponivelPorQualidade, "\(op)")
            #expect(Politica.provedor(op, contaLigada: true, bordo: true) == nil, "\(op) ainda tem executor")
            #expect(!Politica.desceAoAparelho(op), "\(op) desceu ao aparelho")
            let frase = Politica.semProvedor(op)
            #expect(frase.contains("indisponível"), "\(op): a frase não diz que está indisponível")
            #expect(!frase.contains("conta Grok"), "\(op): a frase manda conectar conta que já existe")
            #expect(!Politica.pelaConta.contains(op) && !Politica.peloAparelho.contains(op), "\(op) promete ajuda no Perfil")
            #expect(Politica.linha(op).medidaEm != nil, "\(op) sem data da medida")
        }
        // O `motivo` é o que a TELA mostra, e a tela não cabe evidência: uma
        // oração curta, sem data e sem caminho de prova. Quem carrega isso é
        // o `porque`, que vai para a ADR.
        for op in cortadas {
            let m = Politica.linha(op).motivo
            #expect(!m.isEmpty, "\(op) sem motivo para a tela")
            #expect(m.count <= 80, "\(op): motivo longo demais para a linha (\(m.count))")
            #expect(!m.contains("prova/"), "\(op): caminho de prova na frase da tela")
            #expect(!m.contains("08/09"), "\(op): data na frase da tela")
            #expect(!m.contains("de 6"), "\(op): contagem da medida na frase da tela")
        }
        // O corte tem dois grupos, e o Perfil precisa distingui-los: sem
        // substituto medido, e com conserto já nomeado.
        #expect(Politica.indisponiveis.filter { Politica.linha($0).conserto == nil }.count == 3)
        #expect(Set(Politica.indisponiveis.filter { Politica.linha($0).conserto != nil })
                == Set([.responderNasNotas, .responder, .instigar, .contrapor]))
        // ADR 09i: `instigar` e `contrapor` entram no grupo "em correção" —
        // o conserto está escrito, a MEDIDA é que falta. O texto vai inteiro
        // para a tela (PerfilView `restoDa`), então fala do que o autor vê.
    }

    /// ADR 09n, REVERTIDA em 09/09 pelo G3 (`revisao-q2-responder.md`). A
    /// medida do conserto ficou; a ESCOLHA DO MODELO caiu, por dois P1: a
    /// comparação mudou duas alavancas (modelo e `reasoning_effort`), logo não
    /// decide o padrão global, e a triagem dos doze candidatos excluiu por nome
    /// e posição, não por fato observado.
    ///
    /// Este teste guarda o estado revertido — e guarda o MOTIVO, para a volta
    /// não voltar por descuido: `responder` só sai da lista de novo quando uma
    /// comparação de UMA alavanca escolher o modelo.
    ///
    /// A Q2-F (ADR 09q) FEZ essa comparação e **não achou substituto**. Os doze
    /// modelos foram triados pela frase que a API respondeu — cinco `imagine`
    /// dão `Model not found`, e `grok-build-0.1` e as três `grok-4.20` recusam
    /// `reasoningEffort`, que o Traço manda em toda chamada. Sobraram TRÊS
    /// candidatos, e os três correram os 12 casos da 08z mais os 6 cegos do
    /// revisor, 3 vezes, com `medium` fixo nos três: `4.3` 15 de 18, `4.5`
    /// **17** de 18, `4.6` 16 de 18 (`prova/q2f-modelo-4*.jsonl`). Nenhum chega
    /// a 18, as duas leituras do placar discordam do vencedor por UM
    /// descumprimento em 54, e o `4.6` custa 4,2× a espera. Quem for tirar
    /// `responder` da lista precisa bater um placar que três modelos não
    /// bateram — e o `grok-4.3` daqui reprova um caso cego em 3 de 3.
    @Test func responderEsperaAComparacaoPareadaAntesDeVoltar() throws {
        #expect(Grok.modelo == "grok-4.3", "a Q2-F comparou os três candidatos com UMA alavanca e nenhum passou (ADR 09q)")
        #expect(Politica.linha(.responder).regra == .indisponivelPorQualidade)
        #expect(Politica.provedor(.responder, contaLigada: true, bordo: true) == nil)
        #expect(!Politica.desceAoAparelho(.responder))
        #expect(!Politica.pelaConta.contains(.responder))
        #expect(Politica.indisponiveis.contains(.responder))
        #expect(Politica.linha(.responder).medidaEm == "09/09/2026")
        // O conserto do prompt FICA e está nomeado. A Q2-F mudou QUAL é o
        // conserto que falta: não é mais "escolher o modelo" — três foram
        // medidos e nenhum passou —, é o prompt impedir a invenção da estrutura
        // de um documento, que derruba `4.3` e `4.5` no caso do relatório.
        let conserto = try #require(Politica.linha(.responder).conserto)
        #expect(conserto.contains("ESTRUTURA"))
        #expect(!conserto.contains("comparação pareada"))
        // A LINHA QUE O AUTOR LÊ no Perfil, montada pelo mesmo caminho da tela
        // — `reprovadas` lê a tabela, `dataDe` decide se a data desce à linha,
        // `linhaDa` escreve. Sem isto o conserto seria dado sem superfície.
        let emCorrecao = PerfilView.reprovadas.filter { $0.conserto != nil }
        let r = try #require(emCorrecao.first { $0.op == .responder })
        let linha = String(PerfilView.linhaDa(r, dataNaLinha: PerfilView.dataDe(emCorrecao).isEmpty)
            .characters)
        #expect(linha.hasPrefix("responder à sua pergunta — inventou cenário que o contexto não sustentava · 09/09 · conserto: "))
        #expect(linha.contains("três medidos, nenhum passou"))
        // O piso de esforço nasceu de uma falha CALADA e sobrevive à reversão:
        // `"none"` é recusado por modelo que raciocina, e a rota calaria.
        #expect(Grok.esforcoMinimo == "low")
        #expect(Grok.corpo(sistema: "", usuario: "", temperatura: 0.3, esquema: nil,
                           esforco: "medium") != nil)
    }

    /// Sem conta e sem aparelho (a suíte), produzir é indisponibilidade dita —
    /// não resposta vazia nem versão do aparelho.
    @Test func produzirSemProvedorEIndisponivel() async {
        #expect(!MotorTrabalho.disponivel)
        let doc = DocumentoTrabalho(intencao: "Falar de mim em espanhol", resultado: "um roteiro")
        let pedido = DocumentoTrabalho.Pedido(instrucao: "quinze minutos", intencaoID: doc.intencaoAtual.id)
        await #expect(throws: MotorTrabalho.Erro.self) {
            try await MotorTrabalho.produzir(doc, pedido, contaLigada: false)
        }
    }
}
