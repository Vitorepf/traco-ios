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
        #expect(c.executor == "aparelho · regras v1")
        #expect(c.versaoDoMetodo == 1)
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
        #expect(r.justificativa == "O pedido pede 3 blocos de 5 minutos (15 no total); encontrei 2 marcas somando 10.")
        #expect(r.trechosDoArtefato == ["5 min, 5 min"])
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
        #expect(r.justificativa == "O pedido pede 3 blocos de 5 minutos (15 no total); encontrei 1 marca somando 5.")
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
        oficina.conferencia = { pedido, _, _ in
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
        var (d, p) = try recebido(intencao: "Praticar espanhol",
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
        #expect(!texto.contains("aparelho · regras v1"))

        let editado = Data((texto + "\n\nUma linha acrescentada fora do Traço, num editor qualquer.").utf8)
        let previa = try IntercambioTrabalho.preparar(editado, para: d)
        #expect(try d.aplicarVersaoExterna(previa))
        let importada = try #require(d.versaoAtual)
        #expect(importada.origem == .externa)
        #expect(importada.conferencias == nil)
        try d.validar()
    }
}
