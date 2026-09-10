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
    @Test func indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho() throws {
        // ADR 2026-09-09v: a `responderNasNotas` SAIU daqui em 10/09. Ela é a
        // primeira das sete a voltar, e voltou por MEDIDA: 21 de 21 no
        // `grok-4.5` contra 12 de 21 no `grok-4.3`, mesma fixture, mesma
        // janela, mesmo binário. Quem a puser de volta nesta lista sem uma
        // corrida nova quebra aqui — e quem tirar outra sem medida também.
        let cortadas: [Politica.Operacao] = [.ecos, .calibragem, .recordar,
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
            #expect(!m.contains("/"), "\(op): caminho de prova ou data na frase da tela")
            #expect(!m.contains("de 6"), "\(op): contagem da medida na frase da tela")
        }
        // O corte tem dois grupos, e o Perfil precisa distingui-los: sem
        // substituto medido, e com conserto já nomeado.
        // ADR 2026-09-10b: `responder` MUDOU DE GRUPO — do "já sabemos o que
        // falta" para o "sem conserto conhecido". O conserto que estava escrito
        // era o prompt parar de inventar a estrutura do documento; ele foi
        // TENTADO, duas vezes, medido contra a base no mesmo binário, e as duas
        // versões saíram piores (base 14 e 15 de 20; candidatos 12 e 12). Manter a frase na
        // tela seria prometer ao autor um conserto que já falhou.
        #expect(Politica.indisponiveis.filter { Politica.linha($0).conserto == nil }.count == 4)
        #expect(Set(Politica.indisponiveis.filter { Politica.linha($0).conserto != nil })
                == Set([.instigar, .contrapor]))
        #expect(Politica.linha(.responder).conserto == nil, "o conserto do prompt foi medido e não fecha (ADR 10b)")
        // ADR 09i: `instigar` e `contrapor` entram no grupo "em correção" —
        // o conserto está escrito, a MEDIDA é que falta. O texto vai inteiro
        // para a tela (PerfilView `restoDa`), então fala do que o autor vê.
        //
        // ADR 09t: o LOTE-3 derrubou os motivos de 08/09 destas TRÊS e a linha
        // passa a dizer o que ele leu. Guardado pela FRASE e pela data, no
        // caminho real da tela — contar os dois grupos passava igual com o
        // texto velho, e um portão que passa com o defeito de pé não guarda
        // nada. Se um destes trechos sair da tabela sem medida nova, quebra
        // aqui.
        let emCorrecao = PerfilView.reprovadas.filter { $0.conserto != nil }
        for (op, leitura) in [(Politica.Operacao.instigar, "quando você diz que não sabe quando foi"),
                              (.contrapor, "inventa uma renda que você não escreveu")] {
            let r = try #require(emCorrecao.first { $0.op == op })
            let linha = PerfilView.restoDa(r)
            #expect(linha.contains(leitura), "\(op): a tela não diz o que o LOTE-3 leu — \(linha)")
            #expect(!linha.contains("08/09"), "\(op): motivo de 08/09 ainda na tela — \(linha)")
            #expect(Politica.linha(op).medidaEm == "10/09/2026", "\(op): a data não é a do LOTE-3")
        }
        // ADR 09v — O RETORNO tem de chegar à TELA, não só à tabela: a operação
        // que voltou some da lista de reprovadas do Perfil, e a frase que o
        // autor lê no ponto em que toca deixa de dizer "indisponível". Contar a
        // lista sozinha passaria igual com a linha velha (defeito da V12-E).
        #expect(!Politica.indisponiveis.contains(.responderNasNotas))
        #expect(!PerfilView.reprovadas.contains { $0.op == .responderNasNotas })
        #expect(Politica.linha(.responderNasNotas).regra == .soGrok)
        #expect(Politica.provedor(.responderNasNotas, contaLigada: true, bordo: true) == .grok)
        #expect(Politica.provedor(.responderNasNotas, contaLigada: false, bordo: true) == nil)
        let voltou = Politica.semProvedor(.responderNasNotas)
        #expect(!voltou.contains("indisponível"), "a tela ainda diz indisponível — \(voltou)")
        #expect(voltou.contains("conta Grok"), "sem conta, a tela tem de dizer o que falta — \(voltou)")
    }

    /// ADR 2026-09-09z, ordem do dono (DIRETRIZ §13). O Perfil o autor lê
    /// quando vai lá olhar; ESTE aviso ele lê no momento em que toca a
    /// operação e ela não acontece — o pior lugar possível para encontrar
    /// "na medida de 08/09". Uma língua só nas duas telas.
    ///
    /// O portão lê a frase INTEIRA das dezesseis, pelo caminho da tela: com o
    /// texto velho a data derruba `.responder`, `.ecos`, `.calibragem`,
    /// `.recordar`, `.instigar` e `.contrapor` na primeira asserção.
    @Test func oAvisoDaRotaFalaALinguaDoAutor() {
        for op in Politica.Operacao.allCases {
            let f = Politica.semProvedor(op)
            #expect(f.range(of: #"\d\d/\d\d"#, options: .regularExpression) == nil,
                    "\(op): data na tela do autor — \(f)")
            let baixo = f.lowercased()
            for jargao in ["medida", "medido", "medimos", "reprov", "prompt", "esquema",
                           "fixture", "jsonl", "grok-4", "vocabulário interno", "fato inventado",
                           "contexto não sustent"] {
                #expect(!baixo.contains(jargao), "\(op): jargão nosso — '\(jargao)' em \(f)")
            }
        }
        // A que VOLTOU fala no molde do G0: o que ela FAZ por ele, e só o que
        // falta para poder fazer. Sem o diagnóstico de por que o aparelho saiu.
        #expect(Politica.semProvedor(.responderNasNotas)
                == "Responder as perguntas que você deixa nas notas precisa da sua conta Grok (em Perfil).")
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
        #expect(Politica.linha(.responder).medidaEm == "10/09/2026")
        // ADR 2026-09-10b: o conserto do prompt SAIU, porque foi medido. Duas
        // reescritas de `sistemaResponder` correram contra o texto vigente no
        // MESMO binário — 20 casos × 3 cada braço, `TRACO_AVALIAR_PEDIDO` como
        // única variável — e as duas ficaram piores: base 14 e 15 de 20 nas
        // duas janelas, candidatos 12 e 12. O defeito é simétrico e nenhuma das duas o
        // separou: mandar ajudar traz de volta "abra o PDF, vá ao sumário";
        // mandar não inventar faz o modelo parar em "não consta X" sem o
        // próximo ato. Quem escrever um conserto novo aqui precisa de uma
        // corrida que bata os 14 de 20 da base.
        #expect(Politica.linha(.responder).conserto == nil)
        #expect(!PerfilView.reprovadas.filter { $0.conserto != nil }.contains { $0.op == .responder })
        // A LINHA QUE O AUTOR LÊ no Perfil, montada pelo mesmo caminho da tela
        // — `reprovadas` lê a tabela e `linhaDa` escreve. Sem isto a mudança
        // seria dado sem superfície.
        let semConserto = PerfilView.reprovadas.filter { $0.conserto == nil }
        let r = try #require(semConserto.first { $0.op == .responder })
        let linha = String(PerfilView.linhaDa(r).characters)
        // ADR 09z: a língua é a do autor — sem a data e sem o nosso plano de
        // obra. A metade nova ("só diz o que falta") é o que as duas tentativas
        // acharam de pé, e o autor lê as duas metades do defeito.
        #expect(linha == "responder à sua pergunta — inventa uma situação que você não escreveu,"
                + " e às vezes só diz o que falta")
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
