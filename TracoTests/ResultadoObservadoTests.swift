import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 08m: o resultado da ação volta ao trabalho — agendado, feito e
/// funcionou são coisas diferentes.
///
/// Nenhum teste aqui prova que a pessoa realizou nada, nem que a revisão
/// seguinte é boa. Provam o contrato: que o resultado observado é um eixo
/// separado do ato, que fracasso e parcial existem com o mesmo peso do
/// sucesso, que `cancelada` tem gesto, que registro antigo continua NÃO
/// OBSERVADO, e que a orientação seguinte muda pelo resultado com a causa
/// guardada como dado.
@MainActor
struct ResultadoObservadoTests {

    // MARK: - Armação

    private func comAcao(_ texto: String = "Apresentar a proposta ao cliente")
        throws -> (DocumentoTrabalho, UUID) {
        var d = DocumentoTrabalho(intencao: "Fechar o contrato", resultado: "Proposta aceita")
        try d.prepararAcao(texto)
        return (d, try #require(d.acoes.first).id)
    }

    // MARK: - 1. Os três eixos não se resumem um no outro

    /// Executar é ato; observar é resultado. Um existe sem o outro: ação
    /// marcada como realizada sem resultado informado, e resultado informado
    /// de ação que ninguém marcou como feita.
    @Test func atoEResultadoSaoEixosIndependentes() throws {
        var (d, acao) = try comAcao()

        // Feito, e nada observado.
        try d.marcarExecutada(acao)
        #expect(d.acoes[0].estado == .executada)
        #expect(d.observacao(de: acao) == nil, "marcar realizada não informa resultado")
        try d.validar()

        // Observado, numa ação que continua pendente.
        var (outro, pendente) = try comAcao("Ligar para o fornecedor")
        try outro.registrarRelato("Liguei e não atenderam", acaoID: pendente, resultado: .naoFuncionou)
        #expect(outro.acoes[0].estado == .pendente, "informar resultado não marca execução")
        #expect(outro.acoes[0].executadaEm == nil)
        #expect(outro.observacao(de: pendente)?.resultado == .naoFuncionou)
        try outro.validar()
    }

    /// Fracasso e parcial são de primeira classe: as três formas entram, e a
    /// última informada é a que orienta. Relato sem classificação continua
    /// possível — e fica NÃO OBSERVADO, nunca sucesso por omissão.
    @Test func asTresFormasEntramERelatoSemClassificacaoFicaNaoObservado() throws {
        var (d, acao) = try comAcao()
        for r in DocumentoTrabalho.ResultadoObservado.allCases {
            try d.registrarRelato("Relato de \(r.rawValue)", acaoID: acao, resultado: r)
        }
        #expect(d.evidencias.map(\.resultado) == [.funcionou, .parcial, .naoFuncionou])
        #expect(d.observacao(de: acao)?.resultado == .naoFuncionou, "a última informada orienta")
        try d.validar()

        var (sem, acaoSem) = try comAcao()
        let e = try sem.registrarRelato("Aconteceu, mas ainda não sei dizer se serviu", acaoID: acaoSem)
        #expect(e.resultado == nil)
        #expect(sem.observacao(de: acaoSem) == nil)
        #expect(sem.ultimaObservacao == nil)
        try sem.validar()
    }

    /// Migração (ADR 05r, mesma regra): documento gravado antes deste contrato
    /// não tem a chave, e nenhum estado velho vira resultado por releitura —
    /// nem mesmo o relato de uma ação marcada como EXECUTADA.
    @Test func registroAntigoSemAChaveContinuaNaoObservado() throws {
        var (d, acao) = try comAcao()
        try d.marcarExecutada(acao)
        try d.registrarRelato("Apresentei a proposta", acaoID: acao, resultado: .funcionou)

        var json = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(d)) as? [String: Any])
        var evidencias = try #require(json["evidencias"] as? [[String: Any]])
        evidencias[0].removeValue(forKey: "resultado")
        json["evidencias"] = evidencias
        let lido = try JSONDecoder().decode(DocumentoTrabalho.self,
                                            from: JSONSerialization.data(withJSONObject: json))
        try lido.validar()
        #expect(lido.evidencias[0].resultado == nil)
        #expect(lido.observacao(de: acao) == nil, "executada não vira \"deu certo\" por releitura")
        #expect(lido.acoes[0].estado == .executada, "e o ato continua registrado como foi")
        #expect(lido.evidencias[0].texto == d.evidencias[0].texto)
    }

    /// Resultado observado é do RELATO de um ato no mundo. Numa tentativa,
    /// "funcionou" seria a resposta de um exercício se declarando certa.
    @Test func tentativaNaoCarregaResultadoObservado() throws {
        var d = DocumentoTrabalho(intencao: "Falar espanhol")
        d.apoio = .praticar
        // Prática por conta própria: sem exercício preparado, que é o caminho
        // mais curto até uma tentativa guardada.
        try d.guardarTentativa("Hola, me llamo Vitor.", apoioUtilizado: "nenhum", artefatoID: nil)
        try d.validar()

        var forjado = d
        forjado.evidencias[0].resultado = .funcionou
        #expect(throws: DocumentoTrabalho.Erro.self) { try forjado.validar() }
    }

    // MARK: - 2. `cancelada` deixa de ser inalcançável

    /// O estado existia no contrato e só os testes o alcançavam. Agora há
    /// gesto — e ele só cancela o que está pendente: o que a pessoa marcou
    /// como realizado aconteceu, e desfazer isso apagaria um ato.
    @Test func cancelarAcaoTemGestoESoAlcancaOPendente() throws {
        var (d, acao) = try comAcao()
        try d.agendar(acao, para: Date(timeIntervalSince1970: 1_800_000_000), aviso: 30)
        try d.cancelarAcao(acao)
        #expect(d.acoes[0].estado == .cancelada)
        try d.validar()

        // Cancelada não reagenda (a agenda e o aviso só leem `pendente`).
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.agendar(acao, para: Date(timeIntervalSince1970: 1_800_003_600))
        }
        // Cancelar de novo não é operação: o estado já é esse.
        #expect(throws: DocumentoTrabalho.Erro.self) { try d.cancelarAcao(acao) }

        var (feita, outra) = try comAcao()
        try feita.marcarExecutada(outra)
        #expect(throws: DocumentoTrabalho.Erro.self) { try feita.cancelarAcao(outra) }
        #expect(feita.acoes[0].estado == .executada)
    }

    /// ADR 08n: a regra que olhava um eixo só deixava cancelar o que a pessoa
    /// JÁ disse que aconteceu. Primeira ordem: o relato com resultado chega e
    /// depois vem a tentativa de cancelar.
    @Test func observadoAntes_naoSeCancelaDepois() throws {
        var (d, acao) = try comAcao()
        #expect(d.podeCancelar(acao), "pendente e não observada: o gesto cabe")
        try d.registrarRelato("Apresentei e o cliente fechou", acaoID: acao, resultado: .funcionou)

        #expect(!d.podeCancelar(acao), "a tela não oferece mais o gesto")
        #expect(throws: DocumentoTrabalho.Erro.self) { try d.cancelarAcao(acao) }
        #expect(d.acoes[0].estado == .pendente, "e nada mudou por tentar")
        #expect(d.observacao(de: acao)?.resultado == .funcionou, "o que ela observou continua lá")
        try d.validar()

        // Relato SEM resultado não tranca a saída: contar não é observar.
        var (aberta, outra) = try comAcao("Ligar para o fornecedor")
        try aberta.registrarRelato("Liguei, ainda sem retorno", acaoID: outra)
        #expect(aberta.podeCancelar(outra))
        try aberta.cancelarAcao(outra)
        #expect(aberta.acoes[0].estado == .cancelada)
        try aberta.validar()
    }

    /// Segunda ordem, o mesmo lugar honesto: cancelou primeiro e o resultado
    /// chega no meio. Classificar o resultado de uma ação cancelada seria
    /// observar o que se desistiu de fazer — e nenhuma rota grava o par.
    @Test func canceladaAntes_naoRecebeResultadoDepois() throws {
        var (d, acao) = try comAcao()
        try d.cancelarAcao(acao)

        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.registrarRelato("Mas no fim deu certo", acaoID: acao, resultado: .funcionou)
        }
        #expect(d.observacao(de: acao) == nil)
        #expect(d.acoes[0].estado == .cancelada)

        // Contar o que houve continua valendo — só a classificação não entra.
        try d.registrarRelato("Desisti porque o cliente sumiu", acaoID: acao)
        #expect(d.evidencias.count == 1 && d.evidencias[0].resultado == nil)
        try d.validar()

        // E a rota de fora (importação, migração, chamador novo) também não
        // grava o par: a guarda é do documento, não do gesto.
        var forjado = d
        forjado.evidencias[0].resultado = .funcionou
        #expect(throws: DocumentoTrabalho.Erro.self) { try forjado.validar() }
    }

    // MARK: - 3. A orientação seguinte muda pelo resultado informado

    /// Três resultados, três pedidos diferentes — e o quarto caso, sem
    /// resultado, continua sendo o pedido genérico de antes.
    @Test func aOrientacaoSeguinteMudaPeloResultado() {
        let bom = TrabalhoView.orientacaoDoRelato(.funcionou)
        let parcial = TrabalhoView.orientacaoDoRelato(.parcial)
        let ruim = TrabalhoView.orientacaoDoRelato(.naoFuncionou)
        let sem = TrabalhoView.orientacaoDoRelato(nil)
        #expect(Set([bom, parcial, ruim, sem]).count == 4, "cada resultado pede outra coisa")
        #expect(bom.contains("FUNCIONOU") && !bom.contains("NÃO FUNCIONOU"))
        #expect(parcial.contains("EM PARTE"))
        #expect(ruim.contains("NÃO FUNCIONOU") && ruim.contains("caminho diferente"))
        #expect(!ruim.contains("erro dela") || ruim.contains("Não trate"))
    }

    /// ADR 08o: a orientação diz de QUAL ação o resultado veio. Com três
    /// ações e três resultados, sem o nome ela mandava "propor caminho
    /// diferente" num Trabalho cuja ação principal a pessoa disse que
    /// funcionou — a promessa da volta só se sustenta se dá para saber qual.
    @Test func aOrientacaoNomeiaAAcaoDoUltimoResultado() throws {
        var (d, proposta) = try comAcao()
        try d.prepararAcao("Ensaiar a abertura")
        let ensaio = try #require(d.acoes.last).id
        try d.registrarRelato("O cliente aceitou", acaoID: proposta, resultado: .funcionou)
        try d.registrarRelato("Travei na abertura", acaoID: ensaio, resultado: .naoFuncionou)

        let alvo = try #require(TrabalhoView.acaoObservada(d))
        #expect(alvo == "Ensaiar a abertura", "o último resultado é o do ensaio, não o da proposta")

        let orientacao = TrabalhoView.orientacaoDoRelato(d.ultimaObservacao?.resultado, acao: alvo)
        #expect(orientacao.contains("Ensaiar a abertura"))
        #expect(!orientacao.contains("Apresentar a proposta ao cliente"),
                "a ação que funcionou não é a que motiva o caminho diferente")
        #expect(orientacao.contains("NÃO FUNCIONOU"))

        // Sem nada observado não há ação a nomear, e o pedido segue genérico.
        let (limpo, _) = try comAcao()
        #expect(TrabalhoView.acaoObservada(limpo) == nil)
    }

    /// A causa é dado vinculante, não inferência: aponta a evidência em que a
    /// pessoa informou o resultado, e o vínculo sobrevive à versão recebida.
    @Test func aCausaDoRelatoFicaGuardadaNaVersaoQueNasceuDela() throws {
        var (d, acao) = try comAcao()
        let e = try d.registrarRelato("O cliente travou no preço", acaoID: acao, resultado: .naoFuncionou)
        let causa = try #require(TrabalhoView.causaDoRelato(d))
        #expect(causa.gatilho == .resultadoInformado)
        #expect(causa.evidenciaID == e.id)
        #expect(causa.conferenciaID == nil && causa.criterioIDs.isEmpty)
        #expect(causa.motivo.contains("Não funcionou") && causa.motivo.contains("travou no preço"))

        let p = try d.iniciarPedido(TrabalhoView.orientacaoDoRelato(.naoFuncionou), ajuste: causa)
        try d.receber("Outra abordagem: começar pelo custo evitado.", produtor: "Fake", pedidoID: p.id)
        let versao = try #require(d.versaoAtual)
        #expect(d.ajuste(de: versao)?.gatilho == .resultadoInformado)
        #expect(d.ajuste(de: versao)?.evidenciaID == e.id)
        try d.validar()

        // E sobrevive ao disco.
        let volta = try JSONDecoder().decode(DocumentoTrabalho.self, from: JSONEncoder().encode(d))
        #expect(volta.ajuste(de: try #require(volta.versaoAtual))?.evidenciaID == e.id)
        #expect(volta == d)
    }

    /// Sem resultado informado não há causa a registrar — deduzir uma seria
    /// inventar causalidade, que é o que a 08j proibiu.
    @Test func semResultadoInformadoNaoHaCausa() throws {
        var (d, acao) = try comAcao()
        #expect(TrabalhoView.causaDoRelato(d) == nil)
        try d.registrarRelato("Aconteceu alguma coisa", acaoID: acao)
        #expect(TrabalhoView.causaDoRelato(d) == nil)
    }

    /// "Você informou" tem de apontar o relato em que ela informou. O
    /// documento recusa a causa que não fecha: sem evidência, com evidência
    /// sem resultado, ou com a bagagem da leitura de tentativa que aqui não
    /// existe.
    @Test func oDocumentoRecusaACausaQueNaoFecha() throws {
        var (d, acao) = try comAcao()
        let semResultado = try d.registrarRelato("Só contei o que houve", acaoID: acao)
        let comResultado = try d.registrarRelato("E não funcionou", acaoID: acao, resultado: .naoFuncionou)

        func recusa(_ aj: DocumentoTrabalho.Ajuste, _ comentario: Comment) {
            var copia = d
            #expect(throws: DocumentoTrabalho.Erro.self, comentario) {
                try copia.iniciarPedido("revise", ajuste: aj)
            }
        }
        recusa(.init(gatilho: .resultadoInformado, motivo: "sem apontar nada"),
               "sem evidência não há onde ler o que ela informou")
        recusa(.init(gatilho: .resultadoInformado, motivo: "aponta relato sem resultado",
                     evidenciaID: semResultado.id),
               "o relato apontado tem de trazer um resultado")
        recusa(.init(gatilho: .resultadoInformado, motivo: "aponta evidência que não existe",
                     evidenciaID: UUID()),
               "ponteiro que não fecha explicaria a mudança errada")
        recusa(.init(gatilho: .resultadoInformado, motivo: "   ", evidenciaID: comResultado.id),
               "motivo vazio não é motivo")
        recusa(.init(gatilho: .resultadoInformado, motivo: "com leitura de tentativa",
                     evidenciaID: comResultado.id, conferenciaID: UUID()),
               "não há leitura de tentativa nesta causa")
        recusa(.init(gatilho: .resultadoInformado, motivo: "com critérios",
                     evidenciaID: comResultado.id, criterioIDs: [UUID()]),
               "não há critério de exercício nesta causa")

        // E a que fecha, entra.
        #expect(throws: Never.self) {
            try d.iniciarPedido("revise", ajuste: .init(gatilho: .resultadoInformado,
                                                        motivo: "você informou: Não funcionou",
                                                        evidenciaID: comResultado.id))
        }
    }

    // MARK: - 4. O que a IA recebe distingue os três

    @Test func oContextoDizOsTresEixosSeparados() throws {
        var (d, acao) = try comAcao()
        try d.marcarExecutada(acao)
        try d.registrarRelato("Apresentei e o cliente adiou", acaoID: acao, resultado: .parcial)
        let contexto = d.contextoDeRetorno
        #expect(contexto.contains("estado registrado: executada"))
        #expect(contexto.contains("resultado informado pela pessoa: Funcionou em parte"))

        var (sem, outra) = try comAcao()
        try sem.registrarRelato("Não sei ainda", acaoID: outra)
        #expect(sem.contextoDeRetorno.contains("resultado informado pela pessoa: não observado"))

        // A seção de ações do pedido delegado diz o mesmo, ação por ação.
        let p = try d.iniciarPedido("revise")
        let pedido = MotorTrabalho.pedido(d, p, teto: 100_000)
        #expect(pedido.contains("resultado informado pela pessoa: Funcionou em parte"))
        #expect(pedido.contains("resultado é observação da pessoa, não medição"))
        #expect(MotorTrabalho.pedido(sem, try sem.iniciarPedido("revise"), teto: 100_000)
            .contains("resultado informado pela pessoa: não observado"))
    }

    /// O núcleo da causa fala do RELATO, não de uma tentativa que não houve.
    @Test func oNucleoDaCausaNaoChamaRelatoDeTentativa() throws {
        var (d, acao) = try comAcao()
        let e = try d.registrarRelato("O cliente travou no preço", acaoID: acao, resultado: .naoFuncionou)
        let causa = try #require(TrabalhoView.causaDoRelato(d))
        let nucleo = PraticaTrabalho.nucleoDoAjuste(d, causa)
        #expect(nucleo.contains("RELATO QUE SUSTENTA O AJUSTE"))
        #expect(!nucleo.contains("TENTATIVA QUE SUSTENTA"))
        #expect(nucleo.contains("RESULTADO QUE ELA INFORMOU: Não funcionou"))
        #expect(nucleo.contains("o resultado que ela informou"))
        #expect(nucleo.contains(e.texto))
        #expect(PraticaTrabalho.origemDoAjuste(causa, tentativaEm: e.data)
            .hasPrefix("A partir do resultado que você informou"))
    }
}
