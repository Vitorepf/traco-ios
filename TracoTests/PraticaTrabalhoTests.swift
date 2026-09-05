import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 05r: a prática dentro do Trabalho — preparação estruturada, tentativa
/// do autor e feedback por critério.
///
/// Nenhum teste aqui prova que a pessoa aprendeu, nem que o modelo prepara um
/// bom exercício. Provam o contrato: o que o app aceita, o que ele recusa, e o
/// que ele se recusa a chamar de acerto.
@MainActor
struct PraticaTrabalhoTests {
    enum Falha: Error { case disco }

    // MARK: - Armação

    private func preparada(criterios: [String] = ["Escreve três frases completas.",
                                                  "Usa o verbo no presente."]) -> PraticaTrabalho.Preparada {
        .init(capacidade: "Falar frases básicas em espanhol",
              situacao: "Sozinho em casa, sem instrutor",
              enunciado: "Escreva três frases em espanhol se apresentando a um vizinho novo.",
              exemplo: "Para pedir informação na rua: “Perdone, ¿dónde está la estación?” (Com licença, onde fica a estação?)",
              criterios: criterios)
    }

    private func pratica() throws -> DocumentoTrabalho.Pratica {
        try #require(PraticaTrabalho.validar(preparada()))
    }

    /// Um trabalho com apoio de prática e o exercício já recebido.
    private func comExercicio(apoio: DocumentoTrabalho.Apoio = .praticar)
        throws -> (DocumentoTrabalho, DocumentoTrabalho.Pratica) {
        var d = DocumentoTrabalho(intencao: "Praticar espanhol sozinho, do zero",
                                  resultado: "Conseguir falar as frases em voz alta hoje")
        d.apoio = apoio
        let p = try d.iniciarPedido("Quero praticar me apresentar em espanhol.")
        let pratica = try pratica()
        try d.receber(PraticaTrabalho.emMarkdown(pratica), produtor: "Fake controlado, só para teste",
                      pedidoID: p.id, pratica: pratica)
        return (d, pratica)
    }

    private let tentativaEscrita = "Hola, me llamo Vitor. Soy de Brasil. Vivo aquí desde enero."

    private func comTentativa() throws -> (DocumentoTrabalho, DocumentoTrabalho.Pratica, UUID) {
        var (d, pratica) = try comExercicio()
        let e = try d.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo",
                                       artefatoID: try #require(d.versaoAtual).id)
        return (d, pratica, e.id)
    }

    private func json(_ pares: String) -> String { "{\(pares)}" }

    private func avaliacao(_ id: UUID, _ situacao: String, _ trecho: String,
                           _ observacao: String = "O trecho tem sujeito e verbo.") -> String {
        """
        {"criterioID":"\(id.uuidString)","situacao":"\(situacao)",
         "trechoDaTentativa":"\(trecho)","observacao":"\(observacao)"}
        """
    }

    private func container(comOrigem nota: Nota? = nil) throws -> ModelContainer {
        let c = try ModelContainer.traco(emMemoria: true)
        if let nota { c.mainContext.insert(nota) }
        return c
    }

    // MARK: - Disco: o formato antigo continua legível

    @Test func jsonAntigoSemCamposDaPraticaDecodificaEValida() throws {
        var antigo = DocumentoTrabalho(intencao: "Preparar a conversa")
        try antigo.guardarVersaoHumana("Versão escrita à mão antes desta ADR")
        try antigo.prepararAcao("Ensaiar")
        try antigo.registrarRelato("Correu bem", acaoID: try #require(antigo.acoes.first).id)
        antigo.hipoteses.append(.init(texto: "Falta ensaio", contexto: "conversa", evidencias: []))

        var raiz = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(antigo)) as? [String: Any])
        raiz.removeValue(forKey: "trechoExercitado")
        var artefatos = try #require(raiz["artefatos"] as? [[String: Any]])
        artefatos[0].removeValue(forKey: "pratica")
        raiz["artefatos"] = artefatos
        var evidencias = try #require(raiz["evidencias"] as? [[String: Any]])
        evidencias[0].removeValue(forKey: "tentativa")
        raiz["evidencias"] = evidencias
        var hipoteses = try #require(raiz["hipoteses"] as? [[String: Any]])
        for chave in ["propostaPor", "avaliadaEm", "motivoAvaliacao"] { hipoteses[0].removeValue(forKey: chave) }
        raiz["hipoteses"] = hipoteses

        let lido = try JSONDecoder().decode(DocumentoTrabalho.self, from: try JSONSerialization.data(withJSONObject: raiz))
        try lido.validar()
        #expect(lido.formato == 1)
        #expect(lido.versaoAtual?.pratica == nil)
        #expect(lido.trechoExercitado == nil)
        #expect(lido.evidencias.first?.tentativa == nil)
        #expect(lido.evidencias.first?.tipo == .relato)
        // Autoria não se reconstrói por dedução: fica desconhecida.
        #expect(lido.hipoteses.first?.propostaPor == nil)
        #expect(lido.hipoteses.first?.avaliadaEm == nil)
        #expect(lido.praticaPedida == false)
    }

    @Test func tentativaEFeedbackSobrevivemAoDiscoEAoReabrir() throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        let registro = DocumentoTrabalho.ConferenciaTentativa(
            executor: "Fake · feedback da tentativa", versaoDoMetodo: 1, estado: .concluida,
            resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .divergencia,
                               trechoDaTentativa: "Soy de Brasil", observacao: "Só duas frases neste trecho.")])
        try d.registrarConferenciaDaTentativa(registro, em: evidenciaID)
        let trabalho = try Trabalho(documento: d)

        let lido = try trabalho.ler()
        let e = try #require(lido.evidencias.first { $0.id == evidenciaID })
        #expect(e.texto == tentativaEscrita)
        #expect(e.tipo == .tentativa)
        #expect(e.tentativa?.origem == .pessoa)
        #expect(e.tentativa?.apoioUtilizado == "olhei o exemplo")
        #expect(e.tentativa?.conferencias?.count == 1)
        #expect(lido.versaoAtual?.pratica?.criterios.count == 2)
    }

    // MARK: - Referência inválida

    @Test func criterioIDInventadoNoFeedbackNaoPassaNaValidacao() throws {
        var (d, _, evidenciaID) = try comTentativa()
        let inventado = DocumentoTrabalho.ConferenciaTentativa(
            executor: "Fake", versaoDoMetodo: 1, estado: .concluida,
            resultados: [.init(criterioID: UUID(), situacao: .atendidoNoEscopo,
                               trechoDaTentativa: "Hola", observacao: "…")])
        try d.registrarConferenciaDaTentativa(inventado, em: evidenciaID)
        #expect(throws: DocumentoTrabalho.Erro.self) { try d.validar() }
    }

    @Test func tentativaSemAcaoOuSemPraticaNoMaterialERecusada() throws {
        var (d, _, evidenciaID) = try comTentativa()
        // Sem a ação ligada ao material, a tentativa não responde a nada.
        var semAcao = d
        semAcao.acoes = []
        #expect(throws: DocumentoTrabalho.Erro.self) { try semAcao.validar() }

        // Material sem prática não pode carregar resposta de exercício.
        var semPratica = d
        semPratica.artefatos[0].pratica = nil
        #expect(throws: DocumentoTrabalho.Erro.self) { try semPratica.validar() }

        // Tentativa apontando para si mesma como anterior.
        var circular = d
        let i = try #require(circular.evidencias.firstIndex { $0.id == evidenciaID })
        circular.evidencias[i].tentativa?.anteriorID = evidenciaID
        #expect(throws: DocumentoTrabalho.Erro.self) { try circular.validar() }

        // E o documento intacto continua válido.
        try d.validar()
    }

    @Test func guardarTentativaRecusaMaterialSemPraticaApoioVazioEAnteriorInexistente() throws {
        var d = DocumentoTrabalho(intencao: "Praticar espanhol")
        try d.guardarVersaoHumana("Texto qualquer, sem exercício")
        let versaoID = try #require(d.versaoAtual).id
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.guardarTentativa("Hola", apoioUtilizado: "nenhum", artefatoID: versaoID)
        }
        var (comPratica, _) = try comExercicio()
        let praticaID = try #require(comPratica.versaoAtual).id
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try comPratica.guardarTentativa("Hola", apoioUtilizado: "  ", artefatoID: praticaID)
        }
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try comPratica.guardarTentativa("Hola", apoioUtilizado: "olhei", artefatoID: praticaID,
                                            anteriorID: UUID())
        }
        #expect(comPratica.evidencias.isEmpty)
    }

    @Test func hipoteseSoAponteEvidenciasConhecidas() throws {
        var (d, _, evidenciaID) = try comTentativa()
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.proporHipotese("Falta vocabulário", propostaPor: "Você", evidencias: [UUID()])
        }
        let h = try d.proporHipotese("Falta vocabulário", propostaPor: "Você", evidencias: [evidenciaID])
        #expect(h.propostaPor == "Você")
        #expect(h.evidencias == [evidenciaID])
        try d.validar()
    }

    // MARK: - Origem preservada

    @Test func tentativaNaoViraVersaoENaoMudaOrigemDoMaterial() throws {
        var (d, _, _) = try comTentativa()
        #expect(d.artefatos.count == 1)
        #expect(d.versaoAtual?.origem == .ia)
        #expect(d.versaoAtual?.produtor == "Fake controlado, só para teste")
        // A resposta do autor é evidência, com origem dela.
        #expect(d.evidencias.count == 1)
        #expect(d.evidencias[0].tentativa?.origem == .pessoa)
        #expect(d.evidencias[0].atribuidaA == "Você")
        // E `guardarVersaoHumana`, que criaria origem mista, não foi chamada.
        try d.guardarVersaoHumana("Se alguém chamar isto, a origem vira mista")
        #expect(d.versaoAtual?.origem == .mista)
        #expect(d.artefatos.count == 2)
    }

    @Test func origensIAPessoaMistaEExternaSobrevivemAoCicloDaPratica() throws {
        var d = DocumentoTrabalho(intencao: "Praticar espanhol")
        d.apoio = .praticar
        try d.guardarVersaoHumana("Minha versão")                              // pessoa
        let p = try d.iniciarPedido("prepare um exercício")
        let pratica = try pratica()
        try d.receber(PraticaTrabalho.emMarkdown(pratica), produtor: "Fake", pedidoID: p.id, pratica: pratica)
        try d.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo",
                               artefatoID: try #require(d.versaoAtual).id)
        try d.guardarVersaoHumana("Versão a partir da anterior")                // mista
        d.artefatos.append(.init(conteudo: "Arquivo importado", origem: .externa,
                                 produtor: "Arquivo importado · autoria não verificada",
                                 intencaoID: d.intencaoAtual.id, anteriorID: d.artefatos.last?.id))
        try d.validar()
        #expect(d.artefatos.map(\.origem) == [.pessoa, .ia, .mista, .externa])
        #expect(d.evidencias.allSatisfy { $0.tentativa?.origem == .pessoa })
    }

    // MARK: - Preparação: o contrato do exercício

    @Test func preparacaoValidaViraPraticaComCriteriosIdentificados() throws {
        let p = try #require(PraticaTrabalho.validar(preparada()))
        #expect(p.criterios.count == 2)
        #expect(Set(p.criterios.map(\.id)).count == 2)
        #expect(p.enunciado.contains("três frases"))
        let corpo = PraticaTrabalho.emMarkdown(p)
        #expect(corpo.contains("Exemplo resolvido"))
        #expect(corpo.contains(p.enunciado))
    }

    @Test func exemploIgualAoEnunciadoOuDentroDeleERecusado() {
        var igual = preparada()
        igual.exemplo = igual.enunciado
        #expect(PraticaTrabalho.validar(igual) == nil)

        var dentro = preparada()
        dentro.exemplo = "Escreva três frases em espanhol"
        dentro.enunciado = "Escreva três frases em espanhol se apresentando a um vizinho novo."
        #expect(PraticaTrabalho.validar(dentro) == nil)
    }

    @Test func criterioQueRepeteQuatroPalavrasDoExemploERecusado() {
        let vazando = preparada(criterios: ["Escreve três frases completas.",
                                            "Diz ¿dónde está la estación? como no exemplo."])
        #expect(PraticaTrabalho.validar(vazando) == nil)
    }

    @Test func preparacaoForaDoContratoNaoViraPraticaParcial() {
        #expect(PraticaTrabalho.parsePreparacao("não é json") == nil)
        #expect(PraticaTrabalho.parsePreparacao(#"{"capacidade":"a","situacao":"b","enunciado":"c"}"#) == nil)
        #expect(PraticaTrabalho.parsePreparacao(#"{"capacidade":"a","situacao":"b","enunciado":"c","exemplo":"d","criterios":["e","f"],"nota":9}"#) == nil)
        // Lista curta demais, campo vazio e critério repetido não passam.
        #expect(PraticaTrabalho.validar(preparada(criterios: ["Só um critério."])) == nil)
        #expect(PraticaTrabalho.validar(preparada(criterios: ["Igual.", "igual"])) == nil)
        var semCapacidade = preparada()
        semCapacidade.capacidade = ""
        #expect(PraticaTrabalho.validar(semCapacidade) == nil)
    }

    @Test func praticaSoEPedidaEmPraticarOuCombinarDelimitado() throws {
        var d = DocumentoTrabalho(intencao: "Praticar espanhol")
        d.apoio = .delegar
        #expect(d.praticaPedida == false)
        d.apoio = .praticar
        #expect(d.praticaPedida)
        d.apoio = .combinar
        #expect(d.praticaPedida == false)
        d.trechoExercitado = "   "
        #expect(d.praticaPedida == false)
        d.trechoExercitado = "As frases em espanhol"
        #expect(d.praticaPedida)
        #expect(PraticaTrabalho.montarPreparacao(d, try d.iniciarPedido("prepare"))
            .contains("O TRECHO QUE ELA VAI EXERCITAR"))
    }

    @Test func montagemDaPreparacaoNaoLevaATentativaDaPessoa() throws {
        var (d, _, _) = try comTentativa()
        let p = try d.iniciarPedido("prepare outro exercício")
        let mensagem = PraticaTrabalho.montarPreparacao(d, p)
        #expect(!mensagem.contains(tentativaEscrita))
        #expect(mensagem.contains("Praticar espanhol sozinho, do zero"))
    }

    // MARK: - Feedback: o que não produz veredito

    @Test func payloadForaDoContratoNaoProduzVeredito() throws {
        let p = try pratica()
        let id = p.criterios[0].id
        let casos = [
            "isto não é JSON nenhum",
            json(#""avaliacoes":[]"# + #","extra":1"#),                       // chave a mais
            json(#""criterios":[]"#),                                          // chave errada
            json("\"avaliacoes\":[{\"criterioID\":\"\(id.uuidString)\",\"situacao\":\"atendidoNoEscopo\"}]"), // campo faltando
            json("\"avaliacoes\":[\(avaliacao(id, "otimo", "Hola"))]"),        // enum fora da lista
            json("\"avaliacoes\":[\(avaliacao(UUID(), "atendidoNoEscopo", "Hola"))]"), // id inventado
        ]
        for cru in casos {
            #expect(PraticaTrabalho.parseConferencia(cru, pratica: p, tentativa: tentativaEscrita) == nil,
                    "deveria recusar: \(cru.prefix(40))")
        }
    }

    @Test func trechoNaoLiteralCaiParaInconclusivoSemCitacaoInventada() throws {
        let p = try pratica()
        let cru = json("\"avaliacoes\":[\(avaliacao(p.criterios[0].id, "atendidoNoEscopo", "Buenos días, señor"))]")
        let rs = try #require(PraticaTrabalho.parseConferencia(cru, pratica: p, tentativa: tentativaEscrita))
        let alvo = try #require(rs.first { $0.criterioID == p.criterios[0].id })
        #expect(alvo.situacao == .inconclusivo)
        #expect(alvo.trechoDaTentativa.isEmpty)
        #expect(alvo.observacao.contains("não aparece literalmente"))
    }

    @Test func vereditoSemTrechoNenhumNaoConfirmaNada() throws {
        let p = try pratica()
        let cru = json("\"avaliacoes\":[\(avaliacao(p.criterios[0].id, "atendidoNoEscopo", ""))]")
        let rs = try #require(PraticaTrabalho.parseConferencia(cru, pratica: p, tentativa: tentativaEscrita))
        #expect(rs.first { $0.criterioID == p.criterios[0].id }?.situacao == .inconclusivo)
    }

    @Test func observacaoQueTrazSolucaoOuReescritaNaoEMostrada() throws {
        let p = try pratica()
        let solucao = "Perdone, ¿dónde está la estación?"
        let cru = json("\"avaliacoes\":[\(avaliacao(p.criterios[0].id, "divergencia", "Soy de Brasil", "Escreva assim: \(solucao)"))]")
        let rs = try #require(PraticaTrabalho.parseConferencia(cru, pratica: p, tentativa: tentativaEscrita))
        let alvo = try #require(rs.first { $0.criterioID == p.criterios[0].id })
        #expect(alvo.situacao == .inconclusivo)
        #expect(!alvo.observacao.contains(solucao))
        #expect(alvo.observacao.contains("solução"))
    }

    @Test func criterioNaoCobertoVoltaNaoAvaliadoENuncaAcertoImplicito() throws {
        let p = try pratica()
        let cru = json("\"avaliacoes\":[\(avaliacao(p.criterios[0].id, "atendidoNoEscopo", "Hola, me llamo Vitor"))]")
        let rs = try #require(PraticaTrabalho.parseConferencia(cru, pratica: p, tentativa: tentativaEscrita))
        #expect(rs.count == 2)
        let faltante = try #require(rs.first { $0.criterioID == p.criterios[1].id })
        #expect(faltante.situacao == .naoAvaliado)
        #expect(faltante.observacao.contains("Não avaliado não é atendido"))
    }

    @Test func aLinhaDoFeedbackNuncaAprovaEDizNadaConfirmadoSemConfirmacao() throws {
        let p = try pratica()
        let so = DocumentoTrabalho.ConferenciaTentativa(
            executor: "Fake", versaoDoMetodo: 1, estado: .concluida,
            resultados: p.criterios.map { .init(criterioID: $0.id, situacao: .inconclusivo,
                                                trechoDaTentativa: "", observacao: "…") })
        #expect(PraticaTrabalho.linha(so).contains("nada confirmado"))
        #expect(!PraticaTrabalho.linha(so).lowercased().contains("aprovad"))

        let indisponivel = DocumentoTrabalho.ConferenciaTentativa(
            executor: PraticaTrabalho.naoExecutada, versaoDoMetodo: 1, estado: .indisponivel,
            motivo: "Limite do aparelho: …")
        #expect(PraticaTrabalho.linha(indisponivel).hasPrefix("Feedback indisponível:"))
    }

    @Test func tetoDoAparelhoRecusaConferenciaEmVezDeCortar() async throws {
        var p = try pratica()
        p.enunciado = String(repeating: "a", count: 5_000)
        let c = await MotorTrabalho.conferirTentativa(pratica: p, tentativa: tentativaEscrita,
                                                      apoioUtilizado: "olhei o exemplo")
        #expect(c.estado == .indisponivel)
        #expect(c.executor == PraticaTrabalho.naoExecutada)
        #expect(c.resultados.isEmpty)
        #expect(try #require(c.motivo).contains("Não mandei um pedaço deles."))
    }

    @Test func montagemDaConferenciaLevaEnunciadoCriteriosApoioETentativaInteiros() throws {
        let p = try pratica()
        let m = PraticaTrabalho.montarConferencia(p, tentativa: tentativaEscrita, apoioUtilizado: "olhei o exemplo")
        #expect(m.contains(p.enunciado))
        #expect(m.contains(tentativaEscrita))
        #expect(m.contains("olhei o exemplo"))
        for c in p.criterios { #expect(m.contains(c.id.uuidString)) }
    }

    // MARK: - Demonstração honesta

    @Test func reavaliarAMesmaTentativaNaoCriaOutraDemonstracao() throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        func leitura() -> DocumentoTrabalho.ConferenciaTentativa {
            .init(executor: "Fake", versaoDoMetodo: 1, estado: .concluida,
                  resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .divergencia,
                                     trechoDaTentativa: "Soy de Brasil", observacao: "…")])
        }
        try d.registrarConferenciaDaTentativa(leitura(), em: evidenciaID)
        try d.registrarConferenciaDaTentativa(leitura(), em: evidenciaID)
        try d.validar()
        #expect(d.evidencias.count == 1)
        #expect(d.tentativas(doArtefato: try #require(d.versaoAtual).id).count == 1)
        #expect(d.evidencias[0].tentativa?.conferencias?.count == 2)
    }

    @Test func novaTentativaLigaAAnteriorSemApagarAPrimeira() throws {
        var (d, _, primeira) = try comTentativa()
        let versaoID = try #require(d.versaoAtual).id
        let segunda = try d.guardarTentativa("Hola, me llamo Vitor. Vivo en São Paulo. Trabajo con software.",
                                             apoioUtilizado: "reli os critérios", artefatoID: versaoID,
                                             anteriorID: primeira)
        try d.validar()
        #expect(d.tentativas(doArtefato: versaoID).count == 2)
        #expect(d.evidencias.first { $0.id == primeira }?.texto == tentativaEscrita)
        #expect(segunda.tentativa?.anteriorID == primeira)
        #expect(segunda.tentativa?.apoioUtilizado == "reli os critérios")
        // Uma ação só para o material: guardar não multiplica atos.
        #expect(d.acoes.count == 1)
    }

    @Test func guardarTentativaNaoMarcaAcaoExecutadaNemConfirmaHipotese() throws {
        var (d, _, _) = try comTentativa()
        #expect(d.acoes.allSatisfy { $0.estado == .pendente && $0.executadaEm == nil })
        let h = try d.proporHipotese("Falta vocabulário de apresentação", propostaPor: "Você")
        // Marcar a ação como realizada não toca na hipótese.
        try d.marcarExecutada(try #require(d.acoes.first).id)
        try d.guardarTentativa("Otra tentativa distinta aquí.", apoioUtilizado: "sem apoio",
                               artefatoID: try #require(d.versaoAtual).id)
        #expect(d.hipoteses.first { $0.id == h.id }?.estado == .proposta)
        #expect(d.hipoteses.first { $0.id == h.id }?.avaliadaPor == nil)
        #expect(d.hipoteses.first { $0.id == h.id }?.avaliadaEm == nil)
    }

    @Test func confirmarConcordanciaRegistraMotivoENaoDeclaraAprendizagem() throws {
        var (d, _, _) = try comTentativa()
        let h = try d.proporHipotese("O que falta é vocabulário, não gramática",
                                     propostaPor: "Apple Intelligence no aparelho")
        try d.avaliarHipotese(h.id, estado: .confirmada, motivo: "travei nas palavras, não na ordem")
        let confirmada = try #require(d.hipoteses.first { $0.id == h.id })
        #expect(confirmada.estado == .confirmada)
        #expect(confirmada.avaliadaPor == "Você")            // só a pessoa avalia
        #expect(confirmada.propostaPor == "Apple Intelligence no aparelho")
        #expect(confirmada.motivoAvaliacao == "travei nas palavras, não na ordem")
        #expect(confirmada.avaliadaEm != nil)
        // Concordância não vira capacidade adquirida em lugar nenhum.
        #expect(d.evidencias.allSatisfy { $0.tentativa?.conferencias == nil })
        #expect(d.acoes.allSatisfy { $0.estado == .pendente })

        try d.avaliarHipotese(h.id, estado: .contestada, motivo: "  ")
        let contestada = try #require(d.hipoteses.first { $0.id == h.id })
        #expect(contestada.motivoAvaliacao == nil)
        #expect(contestada.estado == .contestada)
        // Contestar não apaga tentativa nem feedback.
        #expect(d.evidencias.count == 1)
        #expect(d.dificuldadeVigente == nil)
    }

    @Test func feedbackNaoSobrescreveARespostaDaPessoa() throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        try d.registrarConferenciaDaTentativa(
            .init(executor: "Fake", versaoDoMetodo: 1, estado: .concluida,
                  resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .divergencia,
                                     trechoDaTentativa: "Soy de Brasil",
                                     observacao: "Este trecho não é uma apresentação.")]),
            em: evidenciaID)
        #expect(d.evidencias.first { $0.id == evidenciaID }?.texto == tentativaEscrita)
        #expect(d.evidencias.first { $0.id == evidenciaID }?.atribuidaA == "Você")
    }

    // MARK: - Oficina: retry, callback atrasado e acesso

    private func oficina(_ d: DocumentoTrabalho, no container: ModelContainer) throws -> (OficinaTrabalho, Trabalho) {
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let o = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                    produzir: { _, _ in .init(texto: "não usado", produtor: "Fake") })
        return (o, trabalho)
    }

    @Test func retryDeSaveNaoDuplicaTentativaENaoApagaOQueEstavaEmEdicao() throws {
        let (d, _) = try comExercicio()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        let versaoID = try #require(o.documento.versaoAtual).id

        var falhar = true
        o.persistir = { ctx in
            if falhar { throw Falha.disco }
            try ctx.save()
        }
        #expect(o.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo", artefatoID: versaoID) == false)
        #expect(o.salvo == false)
        // O candidato continua em memória; o disco não o recebeu.
        #expect(o.documento.tentativas(doArtefato: versaoID).count == 1)
        #expect(try trabalho.ler().evidencias.isEmpty)

        falhar = false
        #expect(o.guardar())
        #expect(o.salvo)
        let gravado = try trabalho.ler()
        #expect(gravado.tentativas(doArtefato: versaoID).count == 1)
        #expect(gravado.evidencias[0].texto == tentativaEscrita)
    }

    @Test func reabrirRecuperaATentativaGuardada() throws {
        let (d, _) = try comExercicio()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        let versaoID = try #require(o.documento.versaoAtual).id
        #expect(o.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo", artefatoID: versaoID))

        let reaberta = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                           produzir: { _, _ in .init(texto: "x", produtor: "Fake") })
        let e = try #require(reaberta.documento.tentativaAtual)
        #expect(e.texto == tentativaEscrita)
        #expect(e.tentativa?.apoioUtilizado == "olhei o exemplo")
        #expect(reaberta.documento.versaoAtual?.pratica?.criterios.count == 2)
    }

    /// Um retorno que chega depois que o contexto mudou não pode ser exibido
    /// como leitura do contexto de agora.
    private func callbackAtrasado(mudanca: @escaping (OficinaTrabalho, UUID) -> Void) async throws -> Bool {
        let (d, pratica) = try comExercicio()
        let container = try container()
        let (o, _) = try oficina(d, no: container)
        let versaoID = try #require(o.documento.versaoAtual).id
        #expect(o.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo", artefatoID: versaoID))
        let evidenciaID = try #require(o.documento.tentativaAtual).id

        let liberar = AsyncStream<Void>.makeStream()
        o.feedbackDaTentativa = { _, _, _ in
            var it = liberar.stream.makeAsyncIterator()
            _ = await it.next()
            return .init(executor: "Fake · feedback da tentativa", versaoDoMetodo: 1, estado: .concluida,
                         resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .divergencia,
                                            trechoDaTentativa: "Soy de Brasil", observacao: "…")])
        }
        let tarefa = try #require(o.conferirTentativa(evidenciaID))
        mudanca(o, versaoID)
        liberar.continuation.yield()
        liberar.continuation.finish()
        await tarefa.value
        return o.documento.evidencias.first { $0.id == evidenciaID }?.tentativa?.conferencias == nil
    }

    @Test func retornoAtrasadoEDescartadoAposNovaTentativa() async throws {
        #expect(try await callbackAtrasado { o, versaoID in
            _ = o.guardarTentativa("Otra frase completamente distinta.", apoioUtilizado: "reli",
                                   artefatoID: versaoID)
        })
    }

    @Test func retornoAtrasadoEDescartadoAposNovoMaterial() async throws {
        #expect(try await callbackAtrasado { o, _ in
            o.alterar { try $0.guardarVersaoHumana("Outro material por cima") }
        })
    }

    @Test func retornoAtrasadoEDescartadoAposMudarOApoio() async throws {
        #expect(try await callbackAtrasado { o, _ in
            o.alterar { $0.apoio = .delegar }
        })
    }

    @Test func retornoAtrasadoEDescartadoAposContestarHipotese() async throws {
        #expect(try await callbackAtrasado { o, _ in
            o.alterar { d in
                let h = try d.proporHipotese("É falta de contexto", propostaPor: "Você")
                try d.avaliarHipotese(h.id, estado: .contestada, motivo: "não é isso")
            }
        })
    }

    @Test func retornoAtrasadoEDescartadoAposRevogarOAcesso() async throws {
        let nota = Nota(texto: "Origem identificável")
        var (d, pratica) = try comExercicio()
        d.notaOrigemID = nota.uuid
        let container = try container(comOrigem: nota)
        let (o, _) = try oficina(d, no: container)
        let versaoID = try #require(o.documento.versaoAtual).id
        #expect(o.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo", artefatoID: versaoID))
        let evidenciaID = try #require(o.documento.tentativaAtual).id

        let liberar = AsyncStream<Void>.makeStream()
        o.feedbackDaTentativa = { _, _, _ in
            var it = liberar.stream.makeAsyncIterator()
            _ = await it.next()
            return .init(executor: "Fake", versaoDoMetodo: 1, estado: .concluida,
                         resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .atendidoNoEscopo,
                                            trechoDaTentativa: "Hola", observacao: "…")])
        }
        let tarefa = try #require(o.conferirTentativa(evidenciaID))
        nota.trancada = true
        try container.mainContext.save()
        liberar.continuation.yield()
        liberar.continuation.finish()
        await tarefa.value
        #expect(o.acesso.permitido == false)
        #expect(o.documento.evidencias.first { $0.id == evidenciaID }?.tentativa?.conferencias == nil)
    }

    @Test func acessoNegadoNaoLeENaoChamaOProvedor() async throws {
        let nota = Nota(texto: "Origem identificável")
        var (d, _) = try comExercicio()
        d.notaOrigemID = nota.uuid
        let container = try container(comOrigem: nota)
        let (o, trabalho) = try oficina(d, no: container)
        let versaoID = try #require(o.documento.versaoAtual).id
        #expect(o.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo", artefatoID: versaoID))
        let evidenciaID = try #require(o.documento.tentativaAtual).id
        let antes = trabalho.conteudoJSON

        var chamadas = 0
        o.feedbackDaTentativa = { _, _, _ in
            chamadas += 1
            return .init(executor: "Fake", versaoDoMetodo: 1, estado: .concluida)
        }
        nota.gesto = .expressiva
        try container.mainContext.save()

        #expect(o.conferirTentativa(evidenciaID) == nil)
        #expect(o.guardarTentativa("outra tentativa", apoioUtilizado: "nenhum", artefatoID: versaoID) == false)
        #expect(chamadas == 0)
        #expect(trabalho.conteudoJSON == antes)   // nada foi lido nem escrito
        #expect(AcessoTrabalho.estado(trabalho, no: container.mainContext) == .restrito(.origemProtegida))
    }

    // MARK: - Intercâmbio

    @Test func exportarMarkdownNaoLevaTentativaNemFeedbackComoVersao() throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        try d.registrarConferenciaDaTentativa(
            .init(executor: "Fake", versaoDoMetodo: 1, estado: .concluida,
                  resultados: [.init(criterioID: pratica.criterios[0].id, situacao: .divergencia,
                                     trechoDaTentativa: "Soy de Brasil", observacao: "Observação do feedback.")]),
            em: evidenciaID)
        let dados = try IntercambioTrabalho.exportar(d)
        let texto = try #require(String(data: dados, encoding: .utf8))
        #expect(texto.contains(pratica.enunciado))
        #expect(!texto.contains(tentativaEscrita))
        #expect(!texto.contains("Observação do feedback."))
    }
}
