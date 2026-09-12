import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 08j: o artefato que se reescreve — a observação da tentativa vira a
/// versão seguinte, e o documento diz por quê.
///
/// Nenhum teste aqui prova que a nova versão é um exercício BOM, nem que a
/// pessoa aprendeu alguma coisa. Provam o contrato: que a causa é um dado
/// guardado e verdadeiro no próprio documento, que a leitura contestada para
/// de orientar, que a saída da adaptação não tem por onde escrever a resposta,
/// e que fechar e reabrir conserva tudo isso.
@MainActor
struct AjusteDoExercicioTests {
    enum Falha: Error { case disco }

    // MARK: - Armação

    private func container() throws -> ModelContainer {
        try ModelContainer.traco(emMemoria: true)
    }

    private func preparada(capacidade: String = "Falar frases básicas em espanhol",
                           enunciado: String = "Escreva três frases em espanhol se apresentando a um vizinho novo.",
                           criterios: [String] = ["Escreve três frases completas.", "Usa o verbo no presente."],
                           mudanca: String? = nil) -> PraticaTrabalho.Preparada {
        .init(capacidade: capacidade,
              situacao: "Sozinho em casa, sem instrutor",
              enunciado: enunciado,
              exemplo: "Para pedir informação na rua: “Perdone, ¿dónde está la estación?” (Com licença, onde fica a estação?)",
              criterios: criterios, mudanca: mudanca)
    }

    private func pratica(_ p: PraticaTrabalho.Preparada? = nil) throws -> DocumentoTrabalho.Pratica {
        try #require(PraticaTrabalho.validar(p ?? preparada()))
    }

    private let tentativaEscrita = "Hola, me llamo Vitor.\nSoy de Brasil.\nVivo aquí desde enero."

    /// Um trabalho de espanhol com exercício N, uma tentativa guardada, e um
    /// pedido anterior concluído cuja restrição precisa sobreviver ao ajuste.
    private func comTentativa() throws -> (DocumentoTrabalho, DocumentoTrabalho.Pratica, UUID) {
        var d = DocumentoTrabalho(intencao: "Praticar espanhol sozinho, do zero",
                                  resultado: "Conseguir falar as frases em voz alta hoje")
        d.apoio = .praticar
        let p = try d.iniciarPedido("Quero praticar me apresentar em espanhol, em três blocos de cinco minutos.")
        let pratica = try pratica()
        try d.receber(PraticaTrabalho.emMarkdown(pratica), produtor: "Fake controlado, só para teste",
                      pedidoID: p.id, pratica: pratica)
        let e = try d.guardarTentativa(tentativaEscrita, apoioUtilizado: "olhei o exemplo",
                                       artefatoID: try #require(d.versaoAtual).id)
        return (d, pratica, e.id)
    }

    private func leitura(_ pratica: DocumentoTrabalho.Pratica,
                         situacao: DocumentoTrabalho.SituacaoCriterio = .divergencia,
                         estado: DocumentoTrabalho.EstadoConferencia = .concluida)
        -> DocumentoTrabalho.ConferenciaTentativa {
        .init(executor: "Fake · feedback da tentativa", versaoDoMetodo: 1, estado: estado,
              resultados: estado == .concluida
                ? [.init(criterioID: pratica.criterios[0].id, situacao: situacao,
                         trechoDaTentativa: "Soy de Brasil",
                         observacao: "O trecho não flexiona o verbo pedido."),
                   .init(criterioID: pratica.criterios[1].id, situacao: .atendidoNoEscopo,
                         trechoDaTentativa: "Vivo aquí desde enero",
                         observacao: "O trecho está no presente.")]
                : [])
    }

    /// A oficina com o motor real por dentro: `preparar` e `entregar` são
    /// falsos, mas a composição do anúncio e a guarda do núcleo são as de
    /// produção — é ali que a volta se prova, não num dublê do motor inteiro.
    private func oficina(_ d: DocumentoTrabalho, no container: ModelContainer,
                         mudanca: String = "Troquei o segundo bloco: agora ele pede frases com o verbo conjugado, e mantive os três blocos de cinco minutos.",
                         enunciadoNovo: String = "Em três blocos de cinco minutos, escreva frases conjugando o verbo no presente para cada pessoa.")
        throws -> (OficinaTrabalho, Trabalho) {
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let o = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                    produzir: { d, p in
            try await MotorTrabalho.produzir(d, p, contaLigada: true, preparar: { _, pedido, _ in
                let bruta = self.preparada(capacidade: "Conjugar o presente em espanhol",
                                           enunciado: enunciadoNovo,
                                           criterios: ["Conjuga o verbo para cada pessoa.",
                                                       "Mantém os três blocos de cinco minutos."],
                                           mudanca: pedido.ajuste == nil ? nil : mudanca)
                guard let validada = PraticaTrabalho.validar(bruta) else { return nil }
                return (validada, "Fake · exercício adaptado")
            }, entregar: { _, _, _ in .init(texto: "não usado", produtor: "Fake") })
        })
        return (o, trabalho)
    }

    // MARK: - 1. A causa é dado guardado, não inferência

    /// Contrato 2: `receber` grava o vínculo; `ajuste(de:)` devolve a causa
    /// registrada. Registro antigo, sem `pedidoID`, devolve `nil` — vínculo não
    /// registrado é isso mesmo, não uma causalidade reconstruída.
    @Test func aVersaoGuardaOPedidoQueAProduziuEOAntigoFicaSemVinculo() throws {
        var (d, _, evidenciaID) = try comTentativa()
        let praticaN = try #require(d.versaoAtual?.pratica)
        let n = try #require(d.versaoAtual)
        #expect(n.pedidoID == d.pedidos[0].id)
        #expect(d.ajuste(de: n) == nil) // preparar não é ajustar

        let ajuste = DocumentoTrabalho.Ajuste(gatilho: .necessidadePercebida, motivo: "a leitura apontou o verbo",
                                              evidenciaID: evidenciaID, conferenciaID: nil,
                                              criterioIDs: [praticaN.criterios[0].id])
        var comLeitura = ajuste
        let c = leitura(praticaN)
        try d.registrarConferenciaDaTentativa(c, em: evidenciaID)
        comLeitura.conferenciaID = c.id
        let p2 = try d.iniciarPedido(PraticaTrabalho.instrucaoDoAjuste, ajuste: comLeitura)
        let novaPratica = try pratica(preparada(criterios: ["Conjuga o verbo.", "Mantém os blocos."],
                                                mudanca: "Mudei o segundo bloco."))
        try d.receber(PraticaTrabalho.emMarkdown(novaPratica), produtor: "Fake",
                      pedidoID: p2.id, pratica: novaPratica)
        let n1 = try #require(d.versaoAtual)
        #expect(n1.pedidoID == p2.id)
        #expect(d.ajuste(de: n1)?.gatilho == .necessidadePercebida)
        #expect(d.ajuste(de: n1)?.evidenciaID == evidenciaID)
        #expect(d.ajuste(de: n1)?.criterioIDs == [praticaN.criterios[0].id])
        try d.validar()

        // Registro antigo: sem `pedidoID`, a causa não se inventa.
        var antigo = d
        antigo.artefatos[1].pedidoID = nil
        #expect(antigo.ajuste(de: antigo.artefatos[1]) == nil)
    }

    /// O ponteiro que não fecha explicaria a mudança errada — pior que não
    /// explicar. E "percebi" sem tentativa nem leitura não é percepção.
    @Test func aValidacaoRecusaVinculoQuebradoECausaQueNaoSeSustenta() throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        var quebrado = d
        quebrado.artefatos[0].pedidoID = UUID()
        #expect(throws: DocumentoTrabalho.Erro.self) { try quebrado.validar() }

        var baseErrada = d
        baseErrada.pedidos[0].artefatoID = nil
        baseErrada.artefatos[0].anteriorID = nil
        try baseErrada.validar() // coerente: base nula dos dois lados
        baseErrada.pedidos[0].artefatoID = UUID()
        #expect(throws: DocumentoTrabalho.Erro.self) { try baseErrada.validar() }

        // necessidade percebida exige a tentativa E a leitura que a sustentam
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.iniciarPedido("adapte", ajuste: .init(gatilho: .necessidadePercebida,
                                                        motivo: "porque sim", evidenciaID: nil))
        }
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.iniciarPedido("adapte", ajuste: .init(gatilho: .necessidadePercebida,
                                                        motivo: "porque sim", evidenciaID: evidenciaID,
                                                        conferenciaID: nil))
        }
        // motivo vazio não é motivo
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.iniciarPedido("adapte", ajuste: .init(gatilho: .pedidoDoAutor, motivo: "   "))
        }
        // critério inventado não entra na causa
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.iniciarPedido("adapte", ajuste: .init(gatilho: .pedidoDoAutor, motivo: "quero outro",
                                                        evidenciaID: evidenciaID,
                                                        criterioIDs: [UUID()]))
        }
        // e o pedido do autor pode existir sem leitura nenhuma
        let p = try d.iniciarPedido("quero outro", ajuste: .init(gatilho: .pedidoDoAutor,
                                                                 motivo: "quero outro",
                                                                 evidenciaID: evidenciaID,
                                                                 criterioIDs: [pratica.criterios[0].id]))
        #expect(p.ajuste?.gatilho == .pedidoDoAutor)
        try d.validar()
    }

    // MARK: - 2. A prova do espanhol: a tentativa com erro gera outra atividade

    @Test func umaTentativaComErroGeraExercicioDiferenteComACausaEARespostaEmBranco() async throws {
        let (d, pratica, evidenciaID) = try comTentativa()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        o.feedbackDaTentativa = { _, _, _ in self.leitura(pratica) }
        let n = try #require(o.documento.versaoAtual).id

        let tarefa = try #require(o.conferirEAdaptar(evidenciaID))
        await tarefa.value

        // a leitura foi ao disco ANTES da versão (05s), e ficou lá
        let leituraGuardada = try #require(o.documento.evidencias.first { $0.id == evidenciaID }?
            .tentativa?.conferencias?.last)
        #expect(leituraGuardada.estado == .concluida)

        // e a versão seguinte nasceu, diferente, com a causa presa a ela
        #expect(o.documento.artefatos.count == 2)
        let n1 = try #require(o.documento.versaoAtual)
        #expect(n1.id != n)
        #expect(n1.anteriorID == n)
        #expect(n1.pratica?.enunciado != pratica.enunciado)
        #expect(n1.pratica?.criterios.map(\.texto) == ["Conjuga o verbo para cada pessoa.",
                                                       "Mantém os três blocos de cinco minutos."])
        let ajuste = try #require(o.documento.ajuste(de: n1))
        #expect(ajuste.gatilho == .necessidadePercebida)
        #expect(ajuste.evidenciaID == evidenciaID)
        #expect(ajuste.conferenciaID == leituraGuardada.id)
        #expect(ajuste.criterioIDs == [pratica.criterios[0].id])
        #expect(ajuste.motivo.contains("Escreve três frases completas."))

        // o anúncio: uma seção, escrita pelo app, sem ID e sem "você aprendeu"
        let conteudo = n1.conteudo
        #expect(conteudo.components(separatedBy: "## Nesta versão").count == 2)
        #expect(conteudo.contains("A partir da leitura da sua tentativa"))
        #expect(conteudo.contains("Reescrever o exercício não é dizer que você aprendeu."))
        #expect(!conteudo.contains(evidenciaID.uuidString))
        #expect(!conteudo.contains(n1.id.uuidString))
        #expect(n1.pratica?.mudanca?.isEmpty == false)

        // a próxima resposta nasce EM BRANCO: nenhuma tentativa ligada à N+1
        #expect(o.documento.tentativas(doArtefato: n1.id).isEmpty)
        // e a tentativa da N continua presa à N, com a leitura dela
        #expect(o.documento.tentativas(doArtefato: n).count == 1)
        #expect(o.documento.evidencias.first { $0.id == evidenciaID }?.artefatoID == n)
        #expect(try trabalho.ler().artefatos.count == 2)
    }

    /// Contrato 4 e 6: o núcleo do ajuste carrega a causa inteira e as
    /// restrições vigentes ANTES do bloco que o orçamento pode cortar.
    @Test func oNucleoDoAjusteTrazTentativaLeituraCriteriosERestricoesForaDoTrechoDescartavel() throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        let c = leitura(pratica)
        try d.registrarConferenciaDaTentativa(c, em: evidenciaID)
        let ajuste = DocumentoTrabalho.Ajuste(gatilho: .necessidadePercebida,
                                              motivo: "a leitura apontou o verbo",
                                              evidenciaID: evidenciaID, conferenciaID: c.id,
                                              criterioIDs: [pratica.criterios[0].id])
        let p = try d.iniciarPedido(PraticaTrabalho.instrucaoDoAjuste, ajuste: ajuste)
        let mensagem = PraticaTrabalho.montarPreparacao(d, p)

        let nucleo = PraticaTrabalho.nucleoDoAjuste(d, ajuste)
        #expect(nucleo.contains(tentativaEscrita))
        #expect(nucleo.contains("O trecho não flexiona o verbo pedido."))
        #expect(nucleo.contains("← trabalhe este"))
        #expect(nucleo.contains("Escreve três frases completas."))
        #expect(nucleo.contains(pratica.enunciado))

        // tudo isso está na CABEÇA: antes do bloco de referência truncável
        let corte = try #require(mensagem.range(of: "<material_de_referencia>"))
        let cabeca = String(mensagem[..<corte.lowerBound])
        #expect(cabeca.contains(tentativaEscrita))
        #expect(cabeca.contains("O trecho não flexiona o verbo pedido."))
        #expect(cabeca.contains("RESTRIÇÕES AINDA APLICÁVEIS"))
        #expect(cabeca.contains("três blocos de cinco minutos"))
    }

    /// Contrato 4: se a causa não cabe, o ajuste fica indisponível e diz isso.
    /// Nunca sai um pedaço da evidência que explica a mudança.
    @Test func aCausaQueNaoCabeDeixaOAjusteIndisponivelEPreservaOExercicio() async throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        // uma tentativa longa demais: o núcleo obrigatório estoura a janela
        d.evidencias[0].texto = String(repeating: "Hola, me llamo Vitor. ", count: 1_200)
        let c = leitura(pratica)
        try d.registrarConferenciaDaTentativa(c, em: evidenciaID)
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        let n = try #require(o.documento.versaoAtual).id

        // ADR 08k: a necessidade percebida aponta o critério que divergiu — a
        // causa que não cabe é a mesma que o app monta, não uma mais frouxa.
        let ajuste = DocumentoTrabalho.Ajuste(gatilho: .necessidadePercebida, motivo: "a leitura apontou o verbo",
                                              evidenciaID: evidenciaID, conferenciaID: c.id,
                                              criterioIDs: [pratica.criterios[0].id])
        let tarefa = try #require(o.gerar(PraticaTrabalho.instrucaoDoAjuste, ajuste: ajuste))
        await tarefa.value

        #expect(o.documento.artefatos.count == 1)
        #expect(o.documento.versaoAtual?.id == n)
        #expect(o.documento.pedidos.last?.estado == .ajusteIndisponivel)
        #expect(o.documento.ajusteIndisponivel)
        #expect(!o.documento.praticaIndisponivel) // não é a preparação que falhou
        #expect(o.documento.pedidoAtivo == nil)
        #expect(o.documento.tentativas(doArtefato: n).count == 1)
        #expect(try trabalho.ler().pedidos.last?.estado == .ajusteIndisponivel)
        #expect(!PraticaTrabalho.ajusteIndisponivel.isEmpty)
    }

    // MARK: - 3. Leitura que não sustenta ajuste não reescreve nada

    @Test func leituraSemDivergenciaOuIndisponivelNaoGeraVersaoENemFicaCalada() async throws {
        for (situacao, estado, esperado) in [
            (DocumentoTrabalho.SituacaoCriterio.atendidoNoEscopo, DocumentoTrabalho.EstadoConferencia.concluida, PraticaTrabalho.leituraSemDivergencia),
            (.inconclusivo, .concluida, PraticaTrabalho.leituraSemDivergencia),
            (.divergencia, .indisponivel, PraticaTrabalho.leituraNaoConcluida),
        ] {
            let (d, pratica, evidenciaID) = try comTentativa()
            let container = try container()
            let (o, _) = try oficina(d, no: container)
            o.feedbackDaTentativa = { _, _, _ in self.leitura(pratica, situacao: situacao, estado: estado) }

            let tarefa = try #require(o.conferirEAdaptar(evidenciaID))
            await tarefa.value

            #expect(o.documento.artefatos.count == 1)
            #expect(o.documento.pedidos.count == 1) // nenhum pedido de ajuste nasceu
            #expect(o.leituraSemAjuste == esperado)
            // a leitura, essa, ficou guardada
            #expect(o.documento.evidencias.first { $0.id == evidenciaID }?.tentativa?.conferencias?.count == 1)
        }
    }

    /// A mesma leitura não gera duas versões, e reabrir o documento não
    /// dispara reescrita: só o toque dispara.
    @Test func aMesmaLeituraNaoGeraDuasVersoesEReabrirNaoDispara() async throws {
        let (d, pratica, evidenciaID) = try comTentativa()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        o.feedbackDaTentativa = { _, _, _ in self.leitura(pratica) }
        await (try #require(o.conferirEAdaptar(evidenciaID))).value
        #expect(o.documento.artefatos.count == 2)

        // segundo toque na MESMA tentativa: a base já não é a versão vigente
        #expect(o.conferirEAdaptar(evidenciaID) == nil)
        #expect(o.documento.artefatos.count == 2)

        let reaberta = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                           produzir: { _, _ in .init(texto: "x", produtor: "Fake") })
        #expect(reaberta.documento.artefatos.count == 2)
        #expect(reaberta.documento.pedidos.count == 2)
        #expect(reaberta.leituraSemAjuste == nil)
    }

    /// P1 da revisão G3 desta volta: a unicidade da leitura era guarda de
    /// TELA — `conferirEAdaptar` a impunha e o agregado não. Outra rota, uma
    /// importação ou um chamador novo passavam por cima. Aqui ela é do
    /// documento: a N+2 da mesma leitura é recusada sem tela nenhuma, e uma
    /// leitura que não concluiu, que foi contestada ou que deu o critério por
    /// atendido não sustenta ajuste algum.
    @Test func aMesmaLeituraNaoSustentaUmSegundoAjusteNoProprioDocumento() throws {
        var (d, praticaN, evidenciaID) = try comTentativa()
        let c = leitura(praticaN)
        try d.registrarConferenciaDaTentativa(c, em: evidenciaID)
        let causa = DocumentoTrabalho.Ajuste(gatilho: .necessidadePercebida,
                                             motivo: "a leitura apontou o verbo",
                                             evidenciaID: evidenciaID, conferenciaID: c.id,
                                             criterioIDs: [praticaN.criterios[0].id])
        let p = try d.iniciarPedido(PraticaTrabalho.instrucaoDoAjuste, ajuste: causa)
        let adaptada = try pratica(preparada(criterios: ["Conjuga o verbo.", "Mantém os blocos."],
                                             mudanca: "Mudei o segundo bloco."))
        try d.receber(PraticaTrabalho.emMarkdown(adaptada), produtor: "Fake",
                      pedidoID: p.id, pratica: adaptada)
        #expect(d.artefatos.count == 2)

        // A N+2 da MESMA leitura: recusada pelo agregado, sem passar pela tela.
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try d.iniciarPedido(PraticaTrabalho.instrucaoDoAjuste, ajuste: causa)
        }
        #expect(d.artefatos.count == 2)
        #expect(d.pedidos.count == 2) // e o pedido recusado não ficou para trás
        #expect(d.pedidos.allSatisfy { $0.estado == .pronto })

        // E um documento que trouxesse os dois ajustes da mesma leitura — de
        // uma importação, de uma regressão — não passa na leitura do disco.
        var forjado = d
        forjado.pedidos.append(.init(instrucao: "por fora", intencaoID: d.intencaoAtual.id,
                                     artefatoID: d.versaoAtual?.id, estado: .pronto, ajuste: causa))
        #expect(throws: DocumentoTrabalho.Erro.self) { try forjado.validar() }

        // Leitura que não concluiu não sustenta ajuste.
        var comOutras = d
        let inconclusa = leitura(praticaN, estado: .indisponivel)
        try comOutras.registrarConferenciaDaTentativa(inconclusa, em: evidenciaID)
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try comOutras.iniciarPedido("adapte", ajuste: .init(gatilho: .necessidadePercebida,
                                                                motivo: "a leitura apontou",
                                                                evidenciaID: evidenciaID,
                                                                conferenciaID: inconclusa.id,
                                                                criterioIDs: [praticaN.criterios[0].id]))
        }

        // Critério que a leitura deu por ATENDIDO não é divergência a tratar.
        let outra = leitura(praticaN)
        try comOutras.registrarConferenciaDaTentativa(outra, em: evidenciaID)
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try comOutras.iniciarPedido("adapte", ajuste: .init(gatilho: .necessidadePercebida,
                                                                motivo: "a leitura apontou",
                                                                evidenciaID: evidenciaID,
                                                                conferenciaID: outra.id,
                                                                criterioIDs: [praticaN.criterios[1].id]))
        }
        // E "percebi" sem apontar critério nenhum não é percepção.
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try comOutras.iniciarPedido("adapte", ajuste: .init(gatilho: .necessidadePercebida,
                                                                motivo: "a leitura apontou",
                                                                evidenciaID: evidenciaID,
                                                                conferenciaID: outra.id))
        }

        // Contestada, a mesma leitura para de sustentar ajuste NOVO — e a
        // versão que já nasceu dela continua guardada e explicada.
        try comOutras.contestarLeitura(outra.id, em: evidenciaID, motivo: "não foi isso que eu errei")
        #expect(throws: DocumentoTrabalho.Erro.self) {
            try comOutras.iniciarPedido("adapte", ajuste: .init(gatilho: .necessidadePercebida,
                                                                motivo: "a leitura apontou",
                                                                evidenciaID: evidenciaID,
                                                                conferenciaID: outra.id,
                                                                criterioIDs: [praticaN.criterios[0].id]))
        }
        try comOutras.validar()
        #expect(comOutras.artefatos.count == 2)
        #expect(comOutras.ajuste(de: try #require(comOutras.versaoAtual))?.conferenciaID == c.id)
    }

    /// P1 da revisão G3 desta volta: entre o toque em "Conferir e adaptar" e a
    /// chegada da N+1 a pessoa ainda podia entrar em "Editar esta versão", e o
    /// documento trocava debaixo dela. A tela agora leva ao progresso em vez de
    /// abrir o campo — e a lei mora no documento: guardar sobre uma base que já
    /// não está na tela é recusado, com o texto dela preservado.
    @Test func editarDuranteAAdaptacaoNaoTrocaODocumentoDebaixoDaPessoa() async throws {
        let (d, praticaN, evidenciaID) = try comTentativa()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        let liberar = AsyncStream<Void>.makeStream()
        o.feedbackDaTentativa = { _, _, _ in
            var it = liberar.stream.makeAsyncIterator()
            _ = await it.next()
            return self.leitura(praticaN)
        }
        let n = try #require(o.documento.versaoAtual).id

        // 1. começar a adaptar
        let tarefa = try #require(o.conferirEAdaptar(evidenciaID))
        // 2. editar: é este o estado que a tela lê para fechar a entrada em
        //    edição (`preparacaoEmCurso`), e a base editada é a N.
        #expect(o.adaptando)

        // 3. a resposta chega no meio da edição: a N+1 nasce
        liberar.continuation.yield()
        liberar.continuation.finish()
        await tarefa.value
        let n1 = try #require(o.documento.versaoAtual).id
        #expect(n1 != n)
        #expect(o.documento.artefatos.count == 2)

        // 4. guardar o texto editado sobre a N é recusado: ele responde a um
        //    material que já não está na tela. Nada é sobrescrito.
        #expect(!o.alterar { try $0.guardarVersaoHumana("Minha reescrita da versão anterior", base: n) })
        #expect(o.documento.artefatos.count == 2)
        #expect(o.documento.versaoAtual?.id == n1)
        #expect(try trabalho.ler().artefatos.count == 2)

        // 5. sobre a versão que ESTÁ na tela, guardar continua sendo dela
        #expect(o.alterar { try $0.guardarVersaoHumana("Minha reescrita do que estou lendo agora", base: n1) })
        #expect(o.documento.artefatos.count == 3)
        #expect(try trabalho.ler().artefatos.count == 3)
    }

    /// Simplicidade 7 da revisão: a cápsula enlatada saiu, e a via do pedido
    /// explícito do autor não saiu com ela — o que ele ESCREVE passa a ser a
    /// causa registrada. Sem apontar tentativa nenhuma: ele escreveu um pedido,
    /// não disse a qual tentativa ele responde.
    @Test func oPedidoEscritoPeloAutorRegistraAPropriaCausa() throws {
        var (d, _, _) = try comTentativa()
        let escrito = "Quero um exercício mais curto, com uma frase só, ainda sobre me apresentar."
        let causa = try #require(TrabalhoView.causaDoPedidoEscrito(d, escrito))
        #expect(causa.gatilho == .pedidoDoAutor)
        #expect(causa.motivo == escrito)
        #expect(causa.evidenciaID == nil)
        #expect(causa.conferenciaID == nil)
        #expect(causa.criterioIDs.isEmpty)

        let p = try d.iniciarPedido(escrito, ajuste: causa)
        let nova = try pratica(preparada(enunciado: "Escreva uma frase em espanhol se apresentando.",
                                         mudanca: "Reduzi para uma frase, como você pediu."))
        try d.receber(PraticaTrabalho.emMarkdown(nova), produtor: "Fake", pedidoID: p.id, pratica: nova)
        let vigente = try #require(d.versaoAtual)
        #expect(d.ajuste(de: vigente)?.motivo == escrito)
        #expect(PraticaTrabalho.origemDoAjuste(try #require(d.ajuste(de: vigente)), tentativaEm: nil) == "A pedido seu.")
        try d.validar()

        // Preparar não é ajustar: sem exercício vigente não há causa a inventar.
        var semExercicio = DocumentoTrabalho(intencao: "Praticar espanhol")
        semExercicio.apoio = .praticar
        #expect(TrabalhoView.causaDoPedidoEscrito(semExercicio, escrito) == nil)
        #expect(TrabalhoView.causaDoPedidoEscrito(d, "   ") == nil)
    }

    // MARK: - 4. A correção do dono tira a leitura equivocada do ajuste seguinte

    @Test func aLeituraContestadaSaiDoContextoEDoNucleoMasFicaNoRegistro() async throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        let c = leitura(pratica)
        try d.registrarConferenciaDaTentativa(c, em: evidenciaID)
        #expect(d.contextoDeRetorno.contains("O trecho não flexiona o verbo pedido."))

        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        #expect(o.contestarLeitura(c.id, em: evidenciaID,
                                   motivo: "Eu não errei o verbo; eu não sabia a palavra “vizinho”."))

        let guardada = try #require(o.documento.evidencias.first { $0.id == evidenciaID }?
            .tentativa?.conferencias?.first { $0.id == c.id })
        // a história fica: a leitura, os resultados e a tentativa continuam lá
        #expect(guardada.contestada)
        #expect(guardada.resultados.count == 2)
        #expect(guardada.estado == .concluida)
        #expect(o.documento.evidencias.first { $0.id == evidenciaID }?.texto == tentativaEscrita)
        #expect(guardada.motivoDaContestacao?.contains("vizinho") == true)

        // e deixa de orientar: some do contexto e a linha de contestação entra
        let contexto = o.documento.contextoDeRetorno
        #expect(!contexto.contains("O trecho não flexiona o verbo pedido."))
        #expect(contexto.contains("Leitura contestada pela pessoa"))
        #expect(contexto.contains("vizinho"))

        // não sustenta um ajuste novo
        #expect(OficinaTrabalho.ajuste(de: guardada, evidenciaID: evidenciaID, pratica: pratica) == nil)
        let ajusteAntigo = DocumentoTrabalho.Ajuste(gatilho: .necessidadePercebida, motivo: "a leitura apontou o verbo",
                                                    evidenciaID: evidenciaID, conferenciaID: c.id)
        let nucleo = PraticaTrabalho.nucleoDoAjuste(o.documento, ajusteAntigo)
        #expect(!nucleo.contains("O trecho não flexiona o verbo pedido."))
        #expect(nucleo.contains("CONTESTADA"))
        #expect(o.documento.leituraDoAjuste(ajusteAntigo) == nil)
        #expect(try trabalho.ler().evidencias[0].tentativa?.conferencias?[0].contestada == true)
    }

    /// A correção sobrevive ao ajuste que vem depois dela, pedido pelo autor:
    /// a interpretação contestada não volta ao contexto pela porta dos fundos.
    @Test func oAjusteSeguinteNaoRepeteAInterpretacaoQueODonoCorrigiu() async throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        let c = leitura(pratica)
        try d.registrarConferenciaDaTentativa(c, em: evidenciaID)
        let container = try container()
        let (o, _) = try oficina(d, no: container)
        #expect(o.contestarLeitura(c.id, em: evidenciaID, motivo: "Eu não errei o verbo."))

        var visto: String?
        let capturado = try OficinaTrabalho(trabalho: o.trabalho, context: container.mainContext,
                                            produzir: { d, p in
            visto = PraticaTrabalho.montarPreparacao(d, p)
            throw MotorTrabalho.Erro.praticaIndisponivel
        })
        let tarefa = try #require(capturado.gerar("Quero outro exercício.",
                                                  ajuste: .init(gatilho: .pedidoDoAutor,
                                                                motivo: "Você pediu um exercício adaptado a partir desta tentativa.",
                                                                evidenciaID: evidenciaID)))
        await tarefa.value
        let mensagem = try #require(visto)
        #expect(!mensagem.contains("O trecho não flexiona o verbo pedido."))
        #expect(mensagem.contains("Leitura contestada pela pessoa"))
        #expect(mensagem.contains(tentativaEscrita))
        #expect(pratica.criterios.count == 2)
    }

    // MARK: - 5. Fechar e reabrir conserva N, tentativa, causa e N+1

    @Test func reabrirConservaVersaoTentativaCausaEVersaoSeguinte() async throws {
        let (d, pratica, evidenciaID) = try comTentativa()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        o.feedbackDaTentativa = { _, _, _ in self.leitura(pratica) }
        await (try #require(o.conferirEAdaptar(evidenciaID))).value
        let n1 = try #require(o.documento.versaoAtual).id

        let reaberta = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                           produzir: { _, _ in .init(texto: "x", produtor: "Fake") })
        let doc = reaberta.documento
        #expect(doc.artefatos.count == 2)
        #expect(doc.artefatos[0].pratica?.enunciado == pratica.enunciado)
        #expect(doc.versaoAtual?.id == n1)
        let e = try #require(doc.evidencias.first { $0.id == evidenciaID })
        #expect(e.texto == tentativaEscrita)
        #expect(e.tentativa?.conferencias?.count == 1)
        let vigente = try #require(doc.versaoAtual)
        let ajuste = try #require(doc.ajuste(de: vigente))
        #expect(ajuste.gatilho == .necessidadePercebida)
        #expect(ajuste.conferenciaID == e.tentativa?.conferencias?[0].id)
        #expect(doc.versaoAtual?.pratica?.mudanca?.isEmpty == false)
        #expect(doc.versaoAtual?.conteudo.contains("## Nesta versão") == true)
    }

    /// 05l/06a: falha de gravação, retry da MESMA versão sem gerar outra, e
    /// conflito de base com o conteúdo preservado.
    @Test func falhaDeGravacaoRetryEConflitoNaoPerdemACausaNemDuplicamAVersao() async throws {
        let (d, pratica, evidenciaID) = try comTentativa()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        o.feedbackDaTentativa = { _, _, _ in self.leitura(pratica) }
        var falhar = true
        o.persistir = { ctx in
            if falhar { throw Falha.disco }
            try ctx.save()
        }
        await (try #require(o.conferirEAdaptar(evidenciaID))).value

        // o disco recusou: nada foi guardado, e o candidato continua em memória
        #expect(o.salvo == false)
        #expect(o.recusaDoCommit == .disco)
        #expect(try trabalho.ler().evidencias[0].tentativa?.conferencias == nil)
        let emMemoria = o.documento.artefatos.count

        falhar = false
        #expect(o.guardar())
        let gravado = try trabalho.ler()
        // retry confirma a MESMA versão: não nasceu uma segunda
        #expect(gravado.artefatos.count == emMemoria)
        #expect(gravado.evidencias[0].tentativa?.conferencias?.count == 1)
        #expect(gravado.evidencias[0].texto == tentativaEscrita)

        // conflito: outra abertura mexeu no disco; o conteúdo daqui é preservado
        let outra = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                        produzir: { _, _ in .init(texto: "x", produtor: "Fake") })
        #expect(outra.alterar { try $0.prepararAcao("Ensaiar em voz alta") })
        #expect(o.guardar() == false)
        #expect(o.recusaDoCommit == .baseDivergente)
        #expect(o.documento.evidencias.first { $0.id == evidenciaID }?.texto == tentativaEscrita)
        #expect(try trabalho.ler().evidencias[0].texto == tentativaEscrita)
    }

    /// 05j: o selo da origem cancela o pedido de ajuste em curso e a leitura
    /// atrasada não é aplicada depois da revogação.
    @Test func revogarAOrigemInterrompeOAjusteEmCurso() async throws {
        var (d, pratica, evidenciaID) = try comTentativa()
        let container = try container()
        let nota = Nota(texto: "origem do trabalho")
        container.mainContext.insert(nota)
        d.notaOrigemID = nota.uuid
        let (o, _) = try oficina(d, no: container)

        let liberar = AsyncStream<Void>.makeStream()
        o.feedbackDaTentativa = { _, _, _ in
            var it = liberar.stream.makeAsyncIterator()
            _ = await it.next()
            return self.leitura(pratica)
        }
        let tarefa = try #require(o.conferirEAdaptar(evidenciaID))
        nota.trancada = true
        try container.mainContext.save()
        liberar.continuation.yield()
        liberar.continuation.finish()
        await tarefa.value

        #expect(o.acesso.permitido == false)
        #expect(o.documento.artefatos.count == 1)
        #expect(o.documento.evidencias.first { $0.id == evidenciaID }?.tentativa?.conferencias == nil)
    }

    // MARK: - 6. A fronteira da IA está no tipo

    /// Contrato 5: a saída da adaptação aceita preparação e a descrição da
    /// mudança. Não tem campo de resposta nem comando que toque em `Evidencia`.
    @Test func aSaidaDaAdaptacaoNaoTemPorOndeEscreverATentativa() throws {
        let esquema = try #require(try JSONSerialization.jsonObject(
            with: Data(PraticaTrabalho.esquemaRemotoPreparacao(comMudanca: true).utf8)) as? [String: Any])
        #expect(esquema["additionalProperties"] as? Bool == false)
        let chaves = Set(try #require(esquema["required"] as? [String]))
        #expect(chaves == ["capacidade", "situacao", "enunciado", "exemplo", "criterios", "mudanca"])
        #expect(Set(try #require(esquema["properties"] as? [String: Any]).keys) == chaves)

        // sem ajuste, "mudanca" nem é oferecida
        let semAjuste = try #require(try JSONSerialization.jsonObject(
            with: Data(PraticaTrabalho.esquemaRemotoPreparacao().utf8)) as? [String: Any])
        #expect(!(try #require(semAjuste["required"] as? [String])).contains("mudanca"))

        // e o parser recusa tudo que sai do contrato
        let base = #"{"capacidade":"c","situacao":"s","enunciado":"e","exemplo":"x","criterios":["a","b"]"#
        #expect(PraticaTrabalho.parsePreparacao(base + "}", comMudanca: true) == nil) // falta mudanca
        #expect(PraticaTrabalho.parsePreparacao(base + #","mudanca":"  "}"#, comMudanca: true) == nil)
        #expect(PraticaTrabalho.parsePreparacao(base + #","mudanca":"mudei o bloco","tentativa":"Hola"}"#,
                                                comMudanca: true) == nil)
        #expect(PraticaTrabalho.parsePreparacao(base + #","mudanca":"mudei o bloco"}"#, comMudanca: false) == nil)
        let ok = try #require(PraticaTrabalho.parsePreparacao(base + #","mudanca":"mudei o bloco"}"#,
                                                              comMudanca: true))
        #expect(ok.mudanca == "mudei o bloco")
    }

    /// O anúncio não é rota para dar a resposta: a mesma prova de vazamento
    /// dos critérios vale para ele. Limite honesto, e está na ADR: isto é
    /// estrutura — não prova ausência de solução disfarçada no enunciado.
    @Test func aDescricaoDaMudancaPassaPelaMesmaProvaDeVazamentoEPeloTeto() throws {
        let p = preparada()
        #expect(PraticaTrabalho.validar(preparada(mudanca: "Mudei o segundo bloco.")) != nil)
        #expect(PraticaTrabalho.validar(preparada(mudanca: String(repeating: "a", count: 401))) == nil)
        let vazando = String(p.exemplo.split(separator: " ").prefix(6).joined(separator: " "))
        #expect(Prova.vazaCitacao(vazando, alvo: p.exemplo))
        #expect(PraticaTrabalho.validar(preparada(mudanca: vazando)) == nil)
    }

    /// Contrato 3: nada de estado de exercício persistido. "Reescrito" não é
    /// "aprendido" — e o documento gravado não tem onde escrever que é.
    @Test func nadaNoDocumentoGuardaDesempenhoGlobalOuAprendizagem() async throws {
        let (d, pratica, evidenciaID) = try comTentativa()
        let container = try container()
        let (o, trabalho) = try oficina(d, no: container)
        o.feedbackDaTentativa = { _, _, _ in self.leitura(pratica) }
        await (try #require(o.conferirEAdaptar(evidenciaID))).value

        let cru = try #require(String(data: trabalho.conteudoJSON, encoding: .utf8)).lowercased()
        for palavra in ["aprendido", "aprendeu", "pontuacao", "pontuação", "dominio", "domínio", "nivel", "score"] {
            #expect(!cru.contains("\"\(palavra)\""))
        }
        // e nenhuma hipótese virou confirmada por conta da reescrita
        #expect(o.documento.hipoteses.isEmpty)
        #expect(o.documento.versaoAtual?.pratica?.hipoteseID == nil)
    }
}
