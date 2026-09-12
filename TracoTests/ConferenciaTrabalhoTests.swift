import Foundation
import NaturalLanguage
import SwiftData
import Testing
@testable import Traco

/// ADR 05p: a conferência local do artefato contra o pedido que o produziu.
/// Nenhum teste aqui prova qualidade semântica; provam o que a checagem diz
/// ter examinado e, principalmente, o que ela declara NÃO ter examinado.
@MainActor
struct ConferenciaTrabalhoTests {
    enum Falha: Error { case disco }

    /// Um pedido já pronto, com o artefato recebido: o par que a conferência lê.
    private func recebido(intencao: String, resultado: String = "", pedido instrucao: String,
                          artefato: String) throws -> (DocumentoTrabalho, DocumentoTrabalho.Pedido) {
        var d = DocumentoTrabalho(intencao: intencao, resultado: resultado)
        let p = try d.iniciarPedido(instrucao)
        try d.receber(artefato, produtor: "Fake controlado, só para teste", pedidoID: p.id)
        return (d, p)
    }

    private func conferir(_ d: DocumentoTrabalho, _ p: DocumentoTrabalho.Pedido) -> DocumentoTrabalho.Conferencia {
        ConferenciaTrabalho.conferir(pedido: p, intencao: d.intencaoAtual, artefato: d.versaoAtual?.conteudo ?? "")
    }

    private func criterio(_ c: DocumentoTrabalho.Conferencia, contendo pedaco: String) throws -> DocumentoTrabalho.Resultado {
        try #require(c.resultados.first { $0.criterio.contains(pedaco) })
    }

    // MARK: - Disco

    @Test func jsonV4AntigoDecodificaSemConferencia() throws {
        var antigo = DocumentoTrabalho(intencao: "Preparar a conversa")
        try antigo.guardarVersaoHumana("Versão escrita à mão antes desta ADR")
        // Grava sem a chave, como o disco de antes: `nil` é "sem conferência".
        var json = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(antigo)) as? [String: Any])
        var artefatos = try #require(json["artefatos"] as? [[String: Any]])
        artefatos[0].removeValue(forKey: "conferencias")
        json["artefatos"] = artefatos
        let dados = try JSONSerialization.data(withJSONObject: json)

        let lido = try JSONDecoder().decode(DocumentoTrabalho.self, from: dados)
        try lido.validar()
        #expect(lido.versaoAtual?.conferencias == nil)
        #expect(lido.versaoAtual?.conteudo == "Versão escrita à mão antes desta ADR")
    }

    @Test func conferenciaSobreviveAoDiscoComPedidoEResultados() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro em espanhol, 3 blocos de 5 minutos.",
                                  artefato: bilingue)
        var documento = d
        try documento.registrarConferencia(conferir(d, p), em: try #require(d.versaoAtual).id)
        let trabalho = try Trabalho(documento: documento)

        let lido = try trabalho.ler()
        let c = try #require(lido.versaoAtual?.conferencias?.last)
        #expect(c.pedidoID == p.id)
        #expect(c.executor == "aparelho · regras v3")
        #expect(c.versaoDoMetodo == 3)
        #expect(c.estado == .concluida)
        #expect(c.resultados.count == lido.versaoAtual?.conferencias?.last?.resultados.count)
    }

    @Test func conferenciaComPedidoInexistenteNaoPassaNaValidacao() throws {
        var (d, _) = try recebido(intencao: "Praticar", pedido: "Em português.", artefato: "Texto qualquer para conferir.")
        let solta = DocumentoTrabalho.Conferencia(pedidoID: UUID(), executor: "x", versaoDoMetodo: 1, estado: .concluida)
        d.artefatos[0].conferencias = [solta]
        #expect(throws: DocumentoTrabalho.Erro.self) { try d.validar() }
    }

    // MARK: - Extração dos critérios

    @Test func criterioTrazTrechoLiteralEInstrucaoPrevaleceSobreAIntencao() throws {
        var d = DocumentoTrabalho(intencao: "Quero um roteiro em inglês para viajar",
                                  resultado: "Um roteiro em francês serviria")
        let p = try d.iniciarPedido("Prepare o roteiro em português. O público é iniciante.")

        let criterios = ConferenciaTrabalho.criterios(pedido: p, intencao: d.intencaoAtual)
        let idioma = try #require(criterios.first { $0.rotulo.contains("Idioma") })
        #expect(idioma.fonte == .instrucao)
        #expect(idioma.rotulo == "Idioma pedido: português")
        #expect(idioma.trecho == "Prepare o roteiro em português")
        #expect(p.instrucao.contains(idioma.trecho))
    }

    @Test func semInstrucaoReconhecidaOCriterioCaiParaOResultadoDesejado() throws {
        var d = DocumentoTrabalho(intencao: "Praticar conversação", resultado: "Frases em espanhol que eu use no balcão")
        let p = try d.iniciarPedido("Prepare um material curto para começar hoje.")

        let criterios = ConferenciaTrabalho.criterios(pedido: p, intencao: d.intencaoAtual)
        let idioma = try #require(criterios.first { $0.rotulo.contains("Idioma") })
        #expect(idioma.fonte == .resultado)
        #expect(idioma.trecho == "Frases em espanhol que eu use no balcão")
    }

    // MARK: - Idioma

    private let ingles = """
    # Solo speaking routine

    Start with a warm-up: read the following sentences out loud, slowly, paying attention to the vowels.
    Then record yourself and listen back, marking every word that felt uncomfortable to pronounce.
    """

    private let bilingue = """
    # Roteiro solo de espanhol

    Leia cada frase em voz alta e confira a tradução logo em seguida, sem pressa.

    - Buenos días, ¿cómo estás? Me llamo Vitor y estoy aprendiendo español. — Bom dia, como vai? Meu nome é Vitor e estou aprendendo espanhol.
    - ¿Puedes repetir eso más despacio, por favor? No entendí muy bien. — Você pode repetir isso mais devagar, por favor? Não entendi muito bem.
    """

    @Test func artefatoEmInglesComPedidoEmPortuguesDivergeECitaOTrecho() throws {
        let (d, p) = try recebido(intencao: "Preparar meu roteiro",
                                  pedido: "Escreva o roteiro em português, para iniciante.",
                                  artefato: ingles)
        let r = try criterio(conferir(d, p), contendo: "Idioma")
        #expect(r.situacao == .divergencia)
        #expect(r.fonte == .instrucao)
        #expect(!r.trechosDoArtefato.isEmpty)
        #expect(r.trechosDoArtefato.allSatisfy { ingles.contains($0.prefix(40)) })
        #expect(r.justificativa.contains("inglês"))
    }

    @Test func bilinguismoLegitimoNaoViraDivergenciaEDeclaraOQueNaoConferiu() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol sozinho",
                                  pedido: "Frases em espanhol com tradução em português, para iniciante.",
                                  artefato: bilingue)
        let r = try criterio(conferir(d, p), contendo: "Idioma")
        #expect(r.criterio == "Idiomas pedidos: português e espanhol")
        #expect(r.situacao == .atendidoNoEscopo)
        #expect(r.trechosDoArtefato.isEmpty)
        #expect(r.justificativa.contains("Não conferi qual frase é original e qual é tradução"))
    }

    @Test func textoCurtoDemaisFicaInconclusivoENaoAtendido() throws {
        let (d, p) = try recebido(intencao: "Praticar", pedido: "Responda em português.", artefato: "Hola. Sí.")
        let r = try criterio(conferir(d, p), contendo: "Idioma")
        #expect(r.situacao == .inconclusivo)
        #expect(r.justificativa.contains("40 caracteres"))
        #expect(r.justificativa.contains("Não é o mesmo que dizer que o idioma está certo"))
        // V5, P2-a: nada divergente não é nada confirmado.
        #expect(ConferenciaTrabalho.linha(conferir(d, p))
                == "Conferência: nada confirmado · 1 inconclusivo · 1 critério não avaliado")
    }

    @Test func cabecalhoTabelaECodigoNaoEntramNaLeituraDeIdioma() {
        let markdown = """
        # Um título razoavelmente comprido que passaria dos quarenta caracteres
        | coluna | outra coluna com bastante texto para passar do limite |
        ```
        let frase = "uma linha de código bem comprida que passaria do limite"
        ```
        Esta é a única linha de prosa de verdade neste artefato de exemplo.
        """
        #expect(ConferenciaTrabalho.prosa(markdown) == ["Esta é a única linha de prosa de verdade neste artefato de exemplo."])
    }

    // MARK: - Tempo

    @Test func ajusteHerdaRestricoesSemSobreporPedidoNovo() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Adapte aos relatos.", artefato: "Bloco 1: 5 minutos. Bloco 2: 5 minutos. Bloco 3: 5 minutos.")
        let anteriores = ["Prepare três blocos de cinco minutos, com espanhol e tradução em português."]
        let herdados = ConferenciaTrabalho.criterios(pedido: p, intencao: d.intencaoAtual, instrucoesAnteriores: anteriores)
        #expect(herdados.contains { $0.alvo == .idioma([.portuguese, .spanish]) })
        #expect(herdados.contains { $0.alvo == .tempo(blocos: 3, cada: 5, total: 15) })
        var novo = p
        novo.instrucao = "Agora em inglês, dois blocos de quatro minutos."
        let atuais = ConferenciaTrabalho.criterios(pedido: novo, intencao: d.intencaoAtual, instrucoesAnteriores: anteriores)
        #expect(atuais.contains { $0.alvo == .idioma([.english]) })
        #expect(atuais.contains { $0.alvo == .tempo(blocos: 2, cada: 4, total: 8) })
        let resposta = #"{"criterios":[{"criterio":"Tempo","trechoFonte":"três blocos de cinco minutos","fonte":"instrucao","situacao":"inconclusivo","trechosDoArtefato":[],"justificativa":"Não medi a prática."}]}"#
        let revisao = try #require(RevisaoTrabalho.parse(resposta, pedido: p, intencao: d.intencaoAtual, artefato: "", instrucoesAnteriores: anteriores))
        #expect(revisao[0].trechoFonte == "três blocos de cinco minutos")
    }

    @Test func tresBlocosDeCincoComArtefatoSomandoQuinzeEAtendido() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo em espanhol, 3 blocos de 5 minutos.",
                                  artefato: """
                                  ## Bloco 1 — 5 minutos
                                  Leia as frases em voz alta, devagar, prestando atenção nas vogais abertas.
                                  ## Bloco 2 — 5 minutos
                                  Grave a si mesmo dizendo as mesmas frases e ouça a gravação inteira depois.
                                  ## Bloco 3 — 5 minutos
                                  Responda em voz alta às perguntas abaixo, sem consultar as traduções.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.criterio == "Tempo pedido: 3 blocos de 5 minutos (15 no total)")
        #expect(r.situacao == .atendidoNoEscopo)
        #expect(r.justificativa.contains("somando 15"))
        #expect(r.justificativa.contains("não prova a duração da prática"))
    }

    @Test func artefatoSemMarcaDeMinutosDizQueNaoEncontrouDistribuicao() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo em espanhol, 3 blocos de 5 minutos.",
                                  artefato: """
                                  ## Primeira parte
                                  Leia as frases em voz alta, devagar, prestando atenção nas vogais abertas.
                                  ## Segunda parte
                                  Grave a si mesmo dizendo as mesmas frases e ouça a gravação inteira depois.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.situacao == .divergencia)
        #expect(r.justificativa.hasPrefix("Não encontrei distribuição"))
        #expect(r.justificativa.contains("não é o mesmo que dizer que os tempos somam errado"))
    }

    @Test func somaDezContraQuinzePedidosDivergeECitaOsNumeros() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo em espanhol, 3 blocos de 5 minutos.",
                                  artefato: """
                                  ## Bloco 1 — 5 minutos
                                  Leia as frases em voz alta, devagar, prestando atenção nas vogais abertas.
                                  ## Bloco 2 — 5 minutos
                                  Grave a si mesmo dizendo as mesmas frases e ouça a gravação inteira depois.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.situacao == .divergencia)
        #expect(r.justificativa == "O pedido pede 3 blocos de 5 minutos (15 no total); encontrei 2 marcas: 5 min, 5 min, somando 10. Cada bloco também precisa ter a duração pedida.")
        #expect(r.trechosDoArtefato == ["5 min, 5 min"])
    }

    @Test(arguments: [5, 6]) func resumoDosBlocosNaoContaComoBlocoExtra(ultimo: Int) throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "3 blocos de 5 minutos.",
                                  artefato: "Realize o exercício em três blocos de cinco minutos, sozinho. Bloco 1 (5 minutos): Leia. Bloco 2 (5 minutos): Escreva. Bloco 3 (\(ultimo) minutos): Pratique.")
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.situacao == (ultimo == 5 ? .atendidoNoEscopo : .divergencia))
        #expect(r.trechosDoArtefato == ["5 min, 5 min, \(ultimo) min"])
    }

    @Test func blocosAdicionaisDepoisDaDistribuicaoNaoSaoResumo() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "3 blocos de 5 minutos.",
                                  artefato: "Bloco 1: 5 minutos. Bloco 2: 5 minutos. Bloco 3: 5 minutos. Depois faça mais três blocos de cinco minutos.")
        #expect(try criterio(conferir(d, p), contendo: "Tempo").situacao == .divergencia)
    }

    @Test func totalAnunciadoNoCabecalhoNaoContaDuasVezes() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo em espanhol, 3 blocos de 5 minutos.",
                                  artefato: """
                                  # Roteiro de 15 minutos
                                  ## Bloco 1 — 5 minutos
                                  Leia as frases em voz alta, devagar, prestando atenção nas vogais abertas.
                                  ## Bloco 2 — 5 minutos
                                  Grave a si mesmo dizendo as mesmas frases e ouça a gravação inteira depois.
                                  ## Bloco 3 — 5 minutos
                                  Responda em voz alta às perguntas abaixo, sem consultar as traduções.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.situacao == .atendidoNoEscopo)
        #expect(r.trechosDoArtefato == ["5 min, 5 min, 5 min"])
    }

    // O defeito da volta 4: o pedido lia números por extenso e o artefato só
    // dígitos, então a tela afirmava "nenhuma marca de minutos" sobre artefato
    // que tinha três. Um léxico só, dos dois lados.

    @Test func artefatoComTempoPorExtensoContaComoMarcaEAtende() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo em espanhol, 3 blocos de 5 minutos.",
                                  artefato: """
                                  ## Bloco 1
                                  Leia as frases em voz alta, devagar, cada um com cinco minutos de prática.
                                  ## Bloco 2
                                  Grave a si mesmo dizendo as mesmas frases, cinco minutos, e ouça depois.
                                  ## Bloco 3
                                  Responda às perguntas em voz alta por cinco minutos, sem consultar nada.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.situacao == .atendidoNoEscopo)
        #expect(r.justificativa.contains("3 marcas"))
        #expect(r.justificativa.contains("somando 15"))
        #expect(r.trechosDoArtefato == ["5 min, 5 min, 5 min"])
    }

    @Test func umaMarcaPorExtensoDivergeEConcordaNoSingular() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo em espanhol, 3 blocos de 5 minutos.",
                                  artefato: """
                                  ## Bloco 1
                                  Leia as frases em voz alta, devagar, com cinco minutos de prática atenta.
                                  ## Bloco 2
                                  Grave a si mesmo dizendo as mesmas frases e ouça a gravação inteira depois.
                                  ## Bloco 3
                                  Responda às perguntas em voz alta, sem consultar as traduções do material.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.situacao == .divergencia)
        #expect(r.justificativa == "O pedido pede 3 blocos de 5 minutos (15 no total); encontrei 1 marca: 5 min, somando 5. Cada bloco também precisa ter a duração pedida.")
        #expect(!r.justificativa.contains("nenhuma marca"))
    }

    @Test func pedidoPorExtensoEArtefatoEmDigitosLeemOMesmoLexico() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Roteiro solo, três blocos de cinco minutos cada.",
                                  artefato: """
                                  ## Bloco 1 — 5 minutos
                                  Leia as frases em voz alta, devagar, prestando atenção nas vogais abertas.
                                  ## Bloco 2 — 5 minutos
                                  Grave a si mesmo dizendo as mesmas frases e ouça a gravação inteira depois.
                                  ## Bloco 3 — 5 minutos
                                  Responda em voz alta às perguntas abaixo, sem consultar as traduções.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.criterio == "Tempo pedido: 3 blocos de 5 minutos (15 no total)")
        #expect(r.situacao == .atendidoNoEscopo)
    }

    @Test func meiaHoraEApostrofoSaoMarcasDeTempo() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Prepare um roteiro de meia hora para praticar sozinho.",
                                  artefato: """
                                  ## Aquecimento
                                  Leia as frases em voz alta, devagar, durante quinze minutos, sem pressa.
                                  ## Prática
                                  Grave a si mesmo repetindo cada frase por 15', ouvindo a gravação depois.
                                  """)
        let r = try criterio(conferir(d, p), contendo: "Tempo")
        #expect(r.criterio == "Tempo pedido: 30 minutos")
        #expect(r.situacao == .atendidoNoEscopo)
        #expect(r.trechosDoArtefato == ["15 min, 15 min"])
    }

    // MARK: - Cobertura declarada

    @Test func pedidoSemRestricaoReconhecidaFicaTodoNaoAvaliadoEALinhaDiz() throws {
        let (d, p) = try recebido(intencao: "Organizar minha semana",
                                  pedido: "Me ajude a organizar o que preciso fazer.",
                                  artefato: "Uma lista de coisas a fazer, escrita com calma e sem pressa nenhuma.")
        let c = conferir(d, p)
        #expect(c.estado == .concluida)
        #expect(c.resultados.allSatisfy { $0.situacao == .naoAvaliado })
        #expect(ConferenciaTrabalho.linha(c) == "Conferência: nenhum critério examinado · 2 critérios não avaliados")
    }

    @Test func aLinhaNuncaAprovaEContaOQueNaoFoiExaminado() throws {
        let (bom, p1) = try recebido(intencao: "Praticar espanhol",
                                     pedido: "Frases em espanhol com tradução em português.",
                                     artefato: bilingue)
        #expect(ConferenciaTrabalho.linha(conferir(bom, p1))
                == "Conferência: nenhuma divergência nos critérios examinados · 1 critério não avaliado")

        let (ruim, p2) = try recebido(intencao: "Preparar meu roteiro",
                                      pedido: "Escreva em português, 3 blocos de 5 minutos.",
                                      artefato: ingles)
        let linha = ConferenciaTrabalho.linha(conferir(ruim, p2))
        #expect(linha == "Conferência: 2 possíveis divergências · 1 critério não avaliado")
        #expect(!linha.contains("verificad"))
        #expect(!linha.contains("aprovad"))
    }

    @Test func artefatoAcimaDoTetoRecusaVeredictoEmVezDeLerUmPedaco() throws {
        let gigante = String(repeating: "Uma frase inteira em português, repetida muitas vezes. ",
                             count: ConferenciaTrabalho.tetoDoArtefato / 30)
        let (d, p) = try recebido(intencao: "Praticar", pedido: "Escreva em português.", artefato: gigante)
        let c = conferir(d, p)
        #expect(c.estado == .indisponivel)
        #expect(c.resultados.isEmpty)
        #expect(ConferenciaTrabalho.linha(c).hasPrefix("Conferência indisponível:"))
    }

    // MARK: - Versão, acesso e intercâmbio

    @Test func conferenciaDeVersaoAntigaNaoSeAplicaAVersaoNova() throws {
        var (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Frases em espanhol com tradução em português.",
                                  artefato: bilingue)
        let antiga = try #require(d.versaoAtual).id
        let atrasada = conferir(d, p)
        try d.guardarVersaoHumana("Reescrevi tudo à mão, em português, do meu jeito.")
        let nova = try #require(d.versaoAtual).id
        #expect(antiga != nova)

        #expect(throws: DocumentoTrabalho.Erro.self) { try d.registrarConferencia(atrasada, em: antiga) }
        #expect(d.artefatos.allSatisfy { $0.conferencias == nil })
    }

    @Test func acessoNegadoNaoLeOArtefatoENaoGravaConferencia() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "Frase privada identificável")
        container.mainContext.insert(nota)
        var (d, p) = try recebido(intencao: nota.texto,
                                  pedido: "Escreva em português, 3 blocos de 5 minutos.",
                                  artefato: ingles)
        d.notaOrigemID = nota.uuid
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        nonisolated(unsafe) var leituras = 0
        oficina.conferencia = { pedido, _, _, _ in
            leituras += 1
            return .init(pedidoID: pedido.id, executor: "x", versaoDoMetodo: 1, estado: .concluida)
        }

        nota.trancada = true
        try container.mainContext.save()
        let artefatoID = try #require(d.versaoAtual).id
        #expect(oficina.conferir(artefatoID, pedidoID: p.id) == false)
        #expect(leituras == 0)
        #expect(try trabalho.ler().artefatos.allSatisfy { $0.conferencias == nil })
    }

    @Test func falhaAoGravarAConferenciaPreservaOArtefatoJaCommitado() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Frases em espanhol com tradução em português.",
                                  artefato: bilingue)
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let commitado = trabalho.conteudoJSON
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        oficina.persistir = { _ in throw Falha.disco }

        #expect(oficina.conferir(try #require(d.versaoAtual).id, pedidoID: p.id) == false)
        #expect(oficina.salvo == false)
        #expect(trabalho.conteudoJSON == commitado)
        #expect(try trabalho.ler().versaoAtual?.conteudo == bilingue)
    }

    @Test func exportarMarkdownNaoLevaConferenciaEImportarNaoCriaUma() throws {
        var (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Frases em espanhol com tradução em português.",
                                  artefato: bilingue)
        try d.registrarConferencia(conferir(d, p), em: try #require(d.versaoAtual).id)

        let arquivo = try IntercambioTrabalho.exportar(d)
        let texto = try #require(String(data: arquivo, encoding: .utf8))
        #expect(!texto.contains("conferencia"))
        #expect(!texto.contains("atendidoNoEscopo"))
        #expect(!texto.contains("aparelho · regras v2"))

        let editado = Data((texto + "\n\nUma linha acrescentada fora do Traço, num editor qualquer.").utf8)
        let previa = try IntercambioTrabalho.preparar(editado, para: d)
        #expect(try d.aplicarVersaoExterna(previa))
        let importada = try #require(d.versaoAtual)
        #expect(importada.origem == .externa)
        #expect(importada.conferencias == nil)
        try d.validar()
    }

    // MARK: - Revisão assistida (ADR 05q)

    /// O par que a revisão lê, com o pedido do caso real de prova/4.md.
    private func paraRevisar() throws -> (DocumentoTrabalho, DocumentoTrabalho.Pedido) {
        try recebido(intencao: "Praticar espanhol sozinho, do zero",
                     resultado: "Conseguir falar as frases em voz alta hoje",
                     pedido: "roteiro solo de espanhol, 3 blocos de 5 minutos, frases em espanhol com tradução em português, para iniciante",
                     artefato: bilingue)
    }

    private func revisar(_ d: DocumentoTrabalho, _ p: DocumentoTrabalho.Pedido,
                         resposta: String, provedor: String = "Grok",
                         janela: Int = 100_000) async -> DocumentoTrabalho.Conferencia {
        await RevisaoTrabalho.revisar(pedido: p, intencao: d.intencaoAtual,
                                      artefato: d.versaoAtual?.conteudo ?? "", criterios: [],
                                      janela: { janela }, chamar: { _, _ in (resposta, provedor) })
    }

    private func criterioJSON(_ pares: String) -> String { #"{"criterios":[{"# + pares + "}]}" }

    @Test func aMensagemLevaPedidoArtefatoECriteriosInteiros() throws {
        let (d, p) = try paraRevisar()
        let locais = conferir(d, p).resultados
        let m = RevisaoTrabalho.montar(pedido: p, intencao: d.intencaoAtual, artefato: bilingue, criterios: locais)
        #expect(m.contains(d.intencaoAtual.texto))
        #expect(m.contains(d.intencaoAtual.resultado))
        #expect(m.contains(p.instrucao))
        #expect(m.contains(bilingue))
        #expect(m.contains("Tempo pedido: 3 blocos de 5 minutos (15 no total)"))
    }

    @Test func parserRecusaChaveAlemDoContrato() throws {
        let (d, p) = try paraRevisar()
        let cru = criterioJSON(#""criterio":"Traduções","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"divergencia","trechosDoArtefato":[],"justificativa":"Faltam.","confianca":0.9"#)
        #expect(RevisaoTrabalho.parse(cru, pedido: p, intencao: d.intencaoAtual, artefato: bilingue) == nil)
        let extraNoTopo = #"{"criterios":[],"resumo":"tudo certo"}"#
        #expect(RevisaoTrabalho.parse(extraNoTopo, pedido: p, intencao: d.intencaoAtual, artefato: bilingue) == nil)
    }

    @Test func parserRecusaSituacaoOuFonteForaDaLista() throws {
        let (d, p) = try paraRevisar()
        let situacao = criterioJSON(#""criterio":"Traduções","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"aprovado","trechosDoArtefato":[],"justificativa":"Faltam.""#)
        #expect(RevisaoTrabalho.parse(situacao, pedido: p, intencao: d.intencaoAtual, artefato: bilingue) == nil)
        let fonte = criterioJSON(#""criterio":"Traduções","trechoFonte":"tradução em português","fonte":"pedido","situacao":"divergencia","trechosDoArtefato":[],"justificativa":"Faltam.""#)
        #expect(RevisaoTrabalho.parse(fonte, pedido: p, intencao: d.intencaoAtual, artefato: bilingue) == nil)
    }

    @Test func citacaoQueNaoEstaNoOriginalViraInconclusivoESomeDaTela() throws {
        let (d, p) = try paraRevisar()
        let inventadaNoPedido = criterioJSON(#""criterio":"Duração","trechoFonte":"quatro blocos de dez minutos","fonte":"instrucao","situacao":"divergencia","trechosDoArtefato":[],"justificativa":"O pedido exigia outra coisa.""#)
        let a = try #require(RevisaoTrabalho.parse(inventadaNoPedido, pedido: p, intencao: d.intencaoAtual, artefato: bilingue))
        #expect(a.count == 1)
        #expect(a[0].situacao == .inconclusivo)
        #expect(a[0].trechoFonte.isEmpty)
        #expect(a[0].justificativa.hasPrefix("Citação não encontrada"))

        let inventadaNoArtefato = criterioJSON(#""criterio":"Traduções","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"atendidoNoEscopo","trechosDoArtefato":["Bom dia, tudo bem com você?"],"justificativa":"Traduziu tudo.""#)
        let b = try #require(RevisaoTrabalho.parse(inventadaNoArtefato, pedido: p, intencao: d.intencaoAtual, artefato: bilingue))
        #expect(b[0].situacao == .inconclusivo)
        #expect(b[0].trechosDoArtefato.isEmpty)
        #expect(b[0].justificativa.contains("no artefato"))
    }

    @Test func citacaoLiteralPassaEPreservaOQueAIADisse() throws {
        let (d, p) = try paraRevisar()
        let cru = criterioJSON(#""criterio":"Traduções para o português","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"atendidoNoEscopo","trechosDoArtefato":["Bom dia, como vai?"],"justificativa":"Cada frase tem a tradução na mesma linha.""#)
        let r = try #require(RevisaoTrabalho.parse(cru, pedido: p, intencao: d.intencaoAtual, artefato: bilingue))
        #expect(r[0].situacao == .atendidoNoEscopo)
        #expect(r[0].trechoFonte == "tradução em português")
        #expect(r[0].trechosDoArtefato == ["Bom dia, como vai?"])
        #expect(r[0].justificativa == "Cada frase tem a tradução na mesma linha.")
    }

    @Test func jsonInvalidoDeixaARevisaoIndisponivelSemInventarAusenciaDeProblema() async throws {
        let (d, p) = try paraRevisar()
        let c = await revisar(d, p, resposta: "Claro! Li o roteiro e ele está ótimo.")
        #expect(c.estado == .indisponivel)
        #expect(c.resultados.isEmpty)
        let linha = RevisaoTrabalho.linha(c)
        #expect(linha.hasPrefix("Revisão da IA indisponível:"))
        #expect(!linha.contains("aprovad"))
    }

    @Test func aProvenienciaGravadaEODoProvedorEfetivoNaoDaConfiguracao() async throws {
        let (d, p) = try paraRevisar()
        let cru = criterioJSON(#""criterio":"Traduções","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"divergencia","trechosDoArtefato":["Buenos días, ¿cómo estás?"],"justificativa":"Sem tradução.""#)
        let noAparelho = await revisar(d, p, resposta: cru, provedor: "Apple Intelligence no aparelho")
        #expect(noAparelho.executor == "Apple Intelligence no aparelho · revisão assistida")
        let noGrok = await revisar(d, p, resposta: cru, provedor: "Grok")
        #expect(noGrok.executor == "Grok · revisão assistida")
        #expect(noGrok.estado == .concluida)
        #expect(noGrok.versaoDoMetodo == 2)
    }

    @Test func aRespostaFavoravelNaoAprovaEDizQuemNaoApontou() async throws {
        let (d, p) = try paraRevisar()
        let cru = criterioJSON(#""criterio":"Traduções para o português","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"atendidoNoEscopo","trechosDoArtefato":["Bom dia, como vai?"],"justificativa":"Cada frase tem tradução.""#)
        let c = await revisar(d, p, resposta: cru)
        #expect(RevisaoTrabalho.linha(c) == "Revisão da IA: a IA não apontou divergências nos critérios examinados")
        #expect(!RevisaoTrabalho.linha(c).contains("aprovad"))
        #expect(!RevisaoTrabalho.linha(c).contains("verificad"))
    }

    @Test func acimaDaJanelaDoProvedorFicaIndisponivelSemCortarNemChamar() async throws {
        let (d, p) = try paraRevisar()
        nonisolated(unsafe) var chamadas = 0
        let c = await RevisaoTrabalho.revisar(
            pedido: p, intencao: d.intencaoAtual, artefato: bilingue, criterios: [],
            janela: { 200 }, chamar: { _, _ in chamadas += 1; return ("{}", "Grok") })
        #expect(chamadas == 0)
        #expect(c.estado == .indisponivel)
        #expect(c.executor == RevisaoTrabalho.naoExecutada)
        #expect(try #require(c.motivo).hasPrefix("Limite do provedor:"))
        #expect(try #require(c.motivo).contains("Não mandei um pedaço"))
        // O artefato continua inteiro no documento: nada foi resumido para caber.
        #expect(d.versaoAtual?.conteudo == bilingue)
    }

    @Test func retornoIncompletoNaoInventaQueOProvedorNaoLeuOArtefato() async throws {
        let (d, p) = try paraRevisar()
        let c = await RevisaoTrabalho.revisar(pedido: p, intencao: d.intencaoAtual,
                                              artefato: bilingue, criterios: [],
                                              janela: { 100_000 }, chamar: { _, _ in nil })
        #expect(c.estado == .indisponivel)
        #expect(c.executor == RevisaoTrabalho.naoExecutada)
        let linha = RevisaoTrabalho.linha(c)
        #expect(linha.contains("Não recebi uma revisão completa"))
        #expect(linha.contains("tente novamente"))
        #expect(!linha.contains("Nada do artefato foi lido"))
        #expect(!linha.contains("Nenhum provedor respondeu"))
    }

    /// Q1: timeout não vira "revisão incompleta". O artefato fica.
    @Test func timeoutDaRevisaoNomeiaAEsperaEPreservaOArtefato() async throws {
        defer { _ = Grok.retirarFalha() }
        let (d, p) = try paraRevisar()
        let c = await RevisaoTrabalho.revisar(pedido: p, intencao: d.intencaoAtual,
                                              artefato: bilingue, criterios: [],
                                              janela: { 100_000 }, chamar: { _, _ in
            Grok.registrarFalha(.timeout)
            return nil
        })
        #expect(c.estado == .indisponivel)
        #expect(c.executor == RevisaoTrabalho.naoExecutada)
        #expect(c.motivo == Grok.frase(.timeout))
        #expect(RevisaoTrabalho.linha(c).contains("estourou"))
        #expect(!RevisaoTrabalho.linha(c).contains("Não recebi uma revisão completa"))
        #expect(d.versaoAtual?.conteudo == bilingue)
    }

    @Test func gerarNaoDisparaRevisaoDaIA() async throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let d = DocumentoTrabalho(intencao: "Praticar espanhol sozinho, do zero",
                                  resultado: "Conseguir falar as frases em voz alta hoje")
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext,
                                          produzir: { _, _ in .init(texto: self.bilingue, produtor: "Fake controlado, só para teste") })
        oficina.estaDisponivel = { true }
        nonisolated(unsafe) var revisoes = 0
        oficina.revisao = { pedido, _, _, _, _ in
            revisoes += 1
            return .init(pedidoID: pedido.id, executor: "x · revisão assistida", versaoDoMetodo: 1, estado: .concluida)
        }

        await oficina.gerar("roteiro solo de espanhol, 3 blocos de 5 minutos, frases em espanhol com tradução em português")?.value
        #expect(revisoes == 0)
        let versao = try #require(oficina.documento.versaoAtual)
        // A conferência local roda; a revisão da IA só a pedido.
        #expect(versao.conferencias?.count == 1)
        #expect(versao.conferencias?.first?.executor == ConferenciaTrabalho.executor)
    }

    @Test func conferirComIAGravaOutraConferenciaSemApagarALocal() async throws {
        let container = try ModelContainer.traco(emMemoria: true)
        var (d, p) = try paraRevisar()
        try d.registrarConferencia(conferir(d, p), em: try #require(d.versaoAtual).id)
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        nonisolated(unsafe) var criteriosVistos: [String] = []
        oficina.revisao = { pedido, _, _, criterios, _ in
            criteriosVistos = criterios.map(\.criterio)
            return .init(pedidoID: pedido.id, executor: "Apple Intelligence no aparelho · revisão assistida",
                         versaoDoMetodo: 1, estado: .concluida,
                         resultados: [.init(criterio: "Traduções", trechoFonte: "tradução em português",
                                            fonte: .instrucao, situacao: .divergencia,
                                            justificativa: "Nenhuma frase tem tradução.")])
        }

        let artefatoID = try #require(d.versaoAtual).id
        await oficina.revisarComIA(artefatoID, pedidoID: p.id)?.value
        let guardadas = try #require(try trabalho.ler().versaoAtual?.conferencias)
        #expect(guardadas.count == 2)
        #expect(guardadas[0].executor == ConferenciaTrabalho.executor)
        #expect(guardadas[1].executor == "Apple Intelligence no aparelho · revisão assistida")
        // A lista de critérios já extraídos viaja com o pedido.
        #expect(criteriosVistos.contains { $0.hasPrefix("Tempo pedido:") })
        #expect(oficina.revisando == false)
    }

    @Test func acessoNegadoNaoChamaAIANemGravaRevisao() async throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "Frase privada identificável")
        container.mainContext.insert(nota)
        var (d, p) = try paraRevisar()
        d.notaOrigemID = nota.uuid
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        nonisolated(unsafe) var chamadas = 0
        oficina.revisao = { pedido, _, _, _, _ in
            chamadas += 1
            return .init(pedidoID: pedido.id, executor: "x · revisão assistida", versaoDoMetodo: 1, estado: .concluida)
        }

        nota.trancada = true
        try container.mainContext.save()
        #expect(oficina.revisarComIA(try #require(d.versaoAtual).id, pedidoID: p.id) == nil)
        #expect(chamadas == 0)
        #expect(try trabalho.ler().artefatos.allSatisfy { $0.conferencias == nil })
    }

    // MARK: - Pedir ajuste e versão sem conferência

    @Test func duasDivergenciasViramOPedidoDeAjusteNasPalavrasDaConferencia() throws {
        let c = DocumentoTrabalho.Conferencia(
            pedidoID: UUID(), executor: ConferenciaTrabalho.executor, versaoDoMetodo: 1, estado: .concluida,
            resultados: [
                .init(criterio: "Tempo pedido: 3 blocos de 5 minutos (15 no total)",
                      trechoFonte: "3 blocos de 5 minutos", fonte: .instrucao, situacao: .divergencia,
                      trechosDoArtefato: ["5 min"],
                      justificativa: "O pedido pede 3 blocos de 5 minutos (15 no total); encontrei 1 marca somando 5."),
                .init(criterio: "Traduções para o português", trechoFonte: "tradução em português",
                      fonte: .instrucao, situacao: .divergencia, trechosDoArtefato: [],
                      justificativa: "Nenhuma frase traz tradução."),
                .init(criterio: "Destinatário, conteúdo e adequação", trechoFonte: "para iniciante",
                      fonte: .instrucao, situacao: .naoAvaliado, justificativa: "Ninguém leu."),
            ])
        let texto = try #require(ConferenciaTrabalho.pedidoDeAjuste(c))
        let marca = "Ajustar a versão anterior (a partir da conferência de \(c.data.formatted(date: .abbreviated, time: .shortened)), por aparelho · regras v3):"
        #expect(texto == """
        \(marca)
        - Tempo pedido: 3 blocos de 5 minutos (15 no total). Na versão anterior: “5 min”. O pedido diz: “3 blocos de 5 minutos”. O pedido pede 3 blocos de 5 minutos (15 no total); encontrei 1 marca somando 5.
        - Traduções para o português. O pedido diz: “tradução em português”. Nenhuma frase traz tradução.
        """)
        #expect(!texto.contains("Destinatário"))
    }

    @Test func semDivergenciaNaoHaPedidoDeAjuste() throws {
        let (d, p) = try recebido(intencao: "Praticar espanhol",
                                  pedido: "Frases em espanhol com tradução em português.",
                                  artefato: bilingue)
        #expect(ConferenciaTrabalho.pedidoDeAjuste(conferir(d, p)) == nil)
    }

    @Test func versaoSemConferenciaTemRotaParaAPrimeiraPeloPedidoQueAProduziu() throws {
        var (d, p) = try paraRevisar()
        let versao = try #require(d.versaoAtual)
        #expect(versao.conferencias == nil)
        #expect(d.pedidoDe(versao)?.id == p.id)
        // Versão escrita à mão não nasceu de pedido: não há contra o que conferir.
        try d.guardarVersaoHumana("Reescrevi tudo à mão, do meu jeito, em português.")
        #expect(d.pedidoDe(try #require(d.versaoAtual)) == nil)
    }

    // MARK: - Correções da volta 5

    /// P2-a: três inconclusivos são ZERO critérios confirmados. Este é o caso
    /// real da revisão pela tela (05/09/2026): o modelo do aparelho devolveu
    /// três critérios com citações não literais e a linha soava favorável.
    @Test func tresInconclusivosNaoViramAusenciaDeDivergencia() async throws {
        let (d, p) = try paraRevisar()
        let tres = #"""
        {"criterios":[
        {"criterio":"Traduções para o português","trechoFonte":"não está no pedido","fonte":"instrucao","situacao":"atendidoNoEscopo","trechosDoArtefato":[],"justificativa":"Traduziu."},
        {"criterio":"Distribuição do tempo","trechoFonte":"também não está","fonte":"instrucao","situacao":"naoAvaliado","trechosDoArtefato":[],"justificativa":"Não li."},
        {"criterio":"Material para iniciante","trechoFonte":"nem isto","fonte":"instrucao","situacao":"divergencia","trechosDoArtefato":[],"justificativa":"Faltou."}
        ]}
        """#
        let c = await revisar(d, p, resposta: tres)
        #expect(c.resultados.count == 3)
        #expect(c.resultados.allSatisfy { $0.situacao == .inconclusivo })
        let linha = RevisaoTrabalho.linha(c)
        #expect(linha == "Revisão da IA: nada confirmado · 3 inconclusivos")
        #expect(!linha.contains("não apontou"))
        #expect(!linha.contains("aprovad"))
    }

    /// P2-b: material importado não nasceu de pedido nenhum. Sem `origem == .ia`
    /// o casamento por `anteriorID` nulo achava o PRIMEIRO pedido do trabalho.
    @Test func versaoImportadaNaoOfereceConferenciaContraPedidoAlheio() throws {
        var (d, p) = try paraRevisar()
        let primeira = try #require(d.versaoAtual)
        #expect(d.pedidoDe(primeira)?.id == p.id)

        let solto = Data("Um texto qualquer, escrito fora do Traço, sem envelope e sem vínculo.".utf8)
        let previa = try IntercambioTrabalho.preparar(solto, para: d)
        #expect(previa.estado == .semVinculo)
        #expect(try d.aplicarVersaoExterna(previa))
        let importada = try #require(d.versaoAtual)
        #expect(importada.origem == .externa)
        #expect(importada.anteriorID == nil)
        #expect(d.pedidoDe(importada) == nil)
    }

    /// Decisão da volta 5: a revisão assistida só é OFERECIDA onde há provedor
    /// que a produza. Sem conta Grok, no lugar do botão fica a linha honesta.
    @Test func semContaGrokNaoHaBotaoDaIAEHaLinhaQueDizPorQue() {
        #expect(RevisaoTrabalho.oferta(contaLigada: true) == nil)
        let aviso = RevisaoTrabalho.oferta(contaLigada: false)
        #expect(aviso == RevisaoTrabalho.semProvedor)
        #expect(aviso?.contains("conta Grok") == true)
        #expect(aviso?.contains("não devolveu revisão válida") == true)
        #expect(aviso?.contains("Criar") == false)
    }

    /// P3-a: nos dois casos reais o modelo pôs o nome do enum como título do
    /// critério. Título não é situação: a resposta não veio no formato exigido.
    @Test func criterioComNomeDeEnumNoTituloDerrubaARevisaoInteira() throws {
        let (d, p) = try paraRevisar()
        for nome in ["atendidoNoEscopo", "divergencia", "naoAvaliado", "instrucao"] {
            let cru = criterioJSON(#""criterio":"\#(nome)","trechoFonte":"tradução em português","fonte":"instrucao","situacao":"inconclusivo","trechosDoArtefato":[],"justificativa":"Alguma coisa.""#)
            #expect(RevisaoTrabalho.parse(cru, pedido: p, intencao: d.intencaoAtual, artefato: bilingue) == nil)
        }
    }
}
