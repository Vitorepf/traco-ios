import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-16c — consultar a obra por seção.
@MainActor @Suite(.serialized)
struct ConsultarObrasTests {
    static let raiz = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    static let biblioteca = raiz.appending(path: "ferramentas/obras/biblioteca")

    struct Pergunta: Decodable { var pergunta: String; var arquivo: String; var secao: Int; var video: String }

    static func obra(_ arquivo: String) throws -> String {
        let bruto = try String(contentsOf: biblioteca.appending(path: arquivo), encoding: .utf8)
        return try #require(Corpus.importar(bruto).first).texto
    }

    /// A prova do plano, com as 20 perguntas escritas ANTES do BM25 existir
    /// (`ferramentas/obras/perguntas.json`, commit da E1) por quem não viu o
    /// código: a seção certa está entre as três que viajam, em pelo menos 16.
    @Test func vintePerguntasAchamASecaoCertaEntreAsTres() throws {
        let perguntas = try JSONDecoder().decode([Pergunta].self,
            from: Data(contentsOf: Self.raiz.appending(path: "ferramentas/obras/perguntas.json")))
        #expect(perguntas.count == 20)
        var acertos = 0
        var falhas: [String] = []
        var admitidas = 0
        for p in perguntas {
            let achados = Obra.ranquear(pergunta: p.pergunta, texto: try Self.obra(p.arquivo))
            let tres = achados.prefix(3).map(\.secao)
            // o que o pacote leva: a obra admitida E a certa entre as três
            if achados.contains(where: Obra.admite),
               achados.prefix(3).contains(where: { $0.secao.chave.hasPrefix(p.video + "&") }) { admitidas += 1 }
            // a identidade é o vídeo, não o número: regenerar a biblioteca renumera
            if tres.contains(where: { $0.chave.hasPrefix(p.video + "&") }) { acertos += 1 }
            else { falhas.append("\(p.arquivo) §\(p.secao): \(p.pergunta.prefix(50)) → \(tres.map { $0.titulo.prefix(14) })") }
        }
        print("E2 · \(acertos)/20 no top 3 · \(admitidas)/20 admitidas no pacote\n" + falhas.joined(separator: "\n"))
        #expect(acertos >= 16, "\(acertos)/20 — \(falhas)")
    }

    /// A ponte de sinônimos da volta 3 foi escrita DEPOIS de ver as falhas da
    /// volta 1. A reserva (`perguntas-reserva.json`) foi escrita com o motor
    /// congelado, por outro agente, longe das 20 seções da prova: é a medida
    /// de generalização. Registra o número; não é portão (ADR 16c).
    @Test func reservaMedeAGeneralizacao() throws {
        let perguntas = try JSONDecoder().decode([Pergunta].self,
            from: Data(contentsOf: Self.raiz.appending(path: "ferramentas/obras/perguntas-reserva.json")))
        var acertos = 0
        var falhas: [String] = []
        for p in perguntas {
            let tres = Obra.ranquear(pergunta: p.pergunta, secoes: Obra.secoes(try Self.obra(p.arquivo))).prefix(3).map(\.secao)
            if tres.contains(where: { $0.chave.hasPrefix(p.video + "&") }) { acertos += 1 }
            else { falhas.append("\(p.arquivo) §\(p.secao): \(p.pergunta.prefix(50)) → \(tres.map { $0.titulo.prefix(14) })") }
        }
        print("E2 reserva · \(acertos)/\(perguntas.count) no top 3\n" + falhas.joined(separator: "\n"))
        #expect(perguntas.count == 10)
    }

    // MARK: o pacote das Notas

    static func fonteDaObra(_ arquivo: String = "hormozi.md") throws -> FonteNotas {
        FonteNotas(id: UUID(), titulo: "Alex Hormozi — regras conferidas · obra", texto: try obra(arquivo),
                   editadaEm: Date(timeIntervalSince1970: 1_790_000_000), obraConferida: true)
    }

    /// Antes: a biblioteca (21 KB) e o dossiê (1,5 MB) passavam de 16.000 e
    /// eram pulados INTEIROS (`FonteNotas.swift:124`); nenhum caractere chegava.
    @Test func aObraViajaNasTresSecoesQueAPerguntaPede() throws {
        let pergunta = "estou pensando em baixar o preço porque os clientes estão cancelando"
        let obra = try Self.fonteDaObra()
        #expect(obra.texto.count > 16_000)
        let pacote = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [obra], conversa: [],
                                                       catalogo: "", retrato: "", teto: 16_000))
        #expect(pacote.omitidas == 0)
        let enviada = try #require(pacote.fontes.first)
        #expect(enviada.id == obra.id && enviada.assinatura == obra.assinatura)
        #expect(Obra.secoes(enviada.texto).count == 3)
        #expect(enviada.texto.contains("Quase nunca baixar preço"))
        #expect(pacote.mensagem.contains(Obra.origemNoPedido), "o modelo lê que é obra, não fato dela")
        // o que é dela vem antes da obra (revisão: a obra empurrava o retrato para fora)
        let comRetrato = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [obra], conversa: [],
                                                           catalogo: "", retrato: "Formas nos últimos 30 dias: 3 Decisão.", teto: 16_000))
        let retrato = try #require(comRetrato.mensagem.range(of: "SOBRE QUEM ESCREVE"))
        let daObra = try #require(comRetrato.mensagem.range(of: Obra.origemNoPedido))
        #expect(retrato.lowerBound < daObra.lowerBound)
        // obra sem nenhuma seção que case não é assunto: não entra nem conta como omitida
        let fora = try #require(RespostaNotas.montar(pergunta: "qual a cor do céu azulado?", fontes: [obra], conversa: [],
                                                     catalogo: "", retrato: "", teto: 16_000))
        #expect(fora.fontes.isEmpty && fora.omitidas == 0)
    }

    @Test(.enabled(if: FileManager.default.isReadableFile(atPath: ObraNaoEVozTests.caminhoDoDossieReal),
                   "sem ~/Desktop/negocios-dossies/hormozi-videos.md nesta máquina"))
    func oDossieRealViajaPorSecaoESoQuandoAPerguntaOToca() throws {
        let texto = try String(contentsOfFile: ObraNaoEVozTests.caminhoDoDossieReal, encoding: .utf8)
        let fonte = FonteNotas(id: UUID(), titulo: "hormozi-videos · parece obra", texto: texto, editadaEm: .now, obra: true)
        func montar(_ pergunta: String, teto: Int = 16_000) throws -> RespostaNotas.Pacote {
            try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [fonte], conversa: [], catalogo: "", retrato: "", teto: teto))
        }
        let caixa = try montar("como melhorar o fluxo de caixa cobrando o cliente antes de entregar")
        #expect(caixa.fontes.count == 1 && caixa.mensagem.count <= 16_000 && caixa.omitidas == 0)
        // revisão: um radical comum ou a ponte sozinha punham o dossiê em toda pergunta
        for alheia in ["quando a mãe chega?", "minha conta do banco", "quero aprender violão", "qual a cor do céu azulado?"] {
            let p = try montar(alheia)
            #expect(p.fontes.isEmpty && p.omitidas == 0, "\(alheia)")
        }
        // o recorte que não cabe inteiro leva as seções que cabem, não some
        let apertado = try montar("como melhorar o fluxo de caixa cobrando o cliente antes de entregar", teto: 6_000)
        let enviada = try #require(apertado.fontes.first)
        #expect((1...3).contains(Obra.secoes(enviada.texto).count))
    }

    /// Na obra suposta, "Mestre:" e "Vídeo:" são texto de quem escreveu o
    /// arquivo: a citação não os repete como autoria do app.
    @Test func aObraSupostaNaoForjaMestreNemLink() throws {
        let texto = "## 1. Cobre antes\r\nMestre: Alex Hormozi\r\nVídeo: Aula oficial — https://evil.example/login\r\nMinuto: 1:00\r\ncobre o cliente antes de entregar o serviço\r\n\r\n## 2. Outra\r\ntexto"
        #expect(Obra.secoes(texto).count == 2, "CRLF parte as seções")
        let fonte = FonteNotas(id: UUID(), titulo: "arquivo · parece obra", texto: texto, editadaEm: .now, obra: true)
        let pacote = try #require(RespostaNotas.montar(pergunta: "cobro o cliente antes de entregar?", fontes: [fonte],
                                                       conversa: [], catalogo: "", retrato: "", teto: 16_000))
        let trecho = try #require(pacote.trechos.first { $0.texto.hasPrefix("cobre o cliente") })
        let r = try #require(RespostaNotas.interpretar(#"{"base":"notas","texto":"Cobrar antes.","trechoIDs":[""# + trecho.id + #""]}"#, pacote: pacote))
        #expect(r.texto.contains("Referência: “1. Cobre antes” · arquivo · parece obra"), "\(r.texto)")
        #expect(!r.texto.contains("evil") && !r.texto.contains("Alex Hormozi"))
        #expect(RespostaNotas.resumoDasFontes([fonte]) == "leu 1 obra")
        let minha = FonteNotas(id: UUID(), titulo: "minha", texto: "x", editadaEm: .now)
        #expect(RespostaNotas.resumoDasFontes([minha, fonte]) == "leu 1 nota sua e 1 obra")
    }

    @Test func aCitacaoDaObraNomeiaMestreVideoEMinuto() throws {
        let pergunta = "estou pensando em baixar o preço porque os clientes estão cancelando"
        let pacote = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [try Self.fonteDaObra()], conversa: [],
                                                       catalogo: "", retrato: "", teto: 16_000))
        let trecho = try #require(pacote.trechos.first { $0.texto.hasPrefix("Regra: Quase nunca baixar preço") })
        let cru = #"{"base":"notas","texto":"O Hormozi diz para quase nunca baixar o preço por churn.","trechoIDs":[""# + trecho.id + #""]}"#
        let r = try #require(RespostaNotas.interpretar(cru, pacote: pacote))
        #expect(r.texto.contains("Referência: Alex Hormozi, “NEVER lower your prices...”, minuto 7:20 — https://www.youtube.com/watch?v=BZQtuK-ucDM&t=440s"), "\(r.texto)")
    }

    @MainActor @Test func aObraNaoEntraNoIndiceNemTomaAVagaDaNotaDoAutor() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let bruto = try String(contentsOf: Self.biblioteca.appending(path: "hormozi.md"), encoding: .utf8)
        let item = try #require(Corpus.importar(bruto).first)
        let obra = Nota(texto: item.texto)
        obra.origem = item.origem
        let minha = Nota(texto: "Decidir se baixo o preço da mentoria porque os clientes cancelam")
        c.mainContext.insert(obra); c.mainContext.insert(minha)
        try c.mainContext.save()
        #expect(!Sessao.paraIndice(obra).podeEntrar)
        let fontes = Sessao().contextoDasNotas(pergunta: "baixo o preço porque os clientes cancelam?", no: c.mainContext)
        #expect(fontes.map(\.id) == [minha.uuid, obra.uuid], "a do autor primeiro; a obra depois, marcada")
        #expect(fontes.last?.obra == true && fontes.first?.obra == false)
        #expect(Sessao().contextoDasNotas(pergunta: "qual a cor do céu azulado?", no: c.mainContext).isEmpty)
    }

    // MARK: ADR 2026-09-16i — as seções das Notas pelo sentido

    @Test func aListaDoModeloSoValeComInteirosDistintosAteTres() {
        #expect(Conselho.numerosEscolhidos(#"{"regras":[3,1]}"#, total: 30) == [3, 1])
        #expect(Conselho.numerosEscolhidos(#"{"regras":[]}"#, total: 30) == [])
        for cru in [#"{"regras":[0]}"#, #"{"regras":[31]}"#, #"{"regras":[2,2]}"#, #"{"regras":[1,2,3,4]}"#,
                    #"{"regras":[true]}"#, #"{"regras":[1.5]}"#, #"{"regras":"1"}"#, #"{"regras":[1],"texto":"use"}"#, "1"] {
            #expect(Conselho.numerosEscolhidos(cru, total: 30) == nil, "\(cru)")
        }
    }

    /// O modelo escolhe entre as 30 melhores das palavras e só devolve números:
    /// o que viaja é a seção literal da posição, na ordem que ele deu.
    @Test func asSecoesEscolhidasPeloSentidoSaoAsLiteraisDaLista() async throws {
        let obras = [try Self.obra("hormozi.md"), try Self.obra("lenny.md")]
        let pergunta = "os clientes estão indo embora depois de dois meses; o que faço?"
        let lista = Array(Obra.ranquear(pergunta: pergunta, textos: obras).prefix(Conselho.candidatas))
        try #require(lista.count >= 5)
        var visto = ""
        let secoes = try #require(await Conselho.escolherSecoesPeloSentido(pergunta: pergunta, obras: obras, pesos: [:]) { s, u, e in
            visto = u
            #expect(s == Conselho.sistemaEscolherSecoes && e == Conselho.esquemaEscolherSecoes)
            return #"{"regras":[5,2]}"#
        })
        #expect(secoes == [lista[4].secao, lista[1].secao])
        #expect(!visto.contains("youtube.com"), "vídeo e minuto não ajudam a julgar o sentido")
        // nenhuma serve: vazio; ilegível ou sem resposta: nil, e a rota cai nas palavras
        #expect(await Conselho.escolherSecoesPeloSentido(pergunta: pergunta, obras: obras, pesos: [:]) { _, _, _ in #"{"regras":[]}"# } == [])
        #expect(await Conselho.escolherSecoesPeloSentido(pergunta: pergunta, obras: obras, pesos: [:]) { _, _, _ in nil } == nil)
        // o modelo não vê peso: a regra que o mundo rebaixou duas vezes sai; só ela, volta às palavras
        let rebaixada = lista[1].secao
        let pesos = [rebaixada.chave: 0.36]
        let n = try #require(Obra.ranquear(pergunta: pergunta, textos: obras, pesos: pesos).prefix(Conselho.candidatas)
            .firstIndex { $0.secao == rebaixada }) + 1
        #expect(await Conselho.escolherSecoesPeloSentido(pergunta: pergunta, obras: obras, pesos: pesos) { _, _, _ in #"{"regras":[\#(n)]}"# } == nil)
    }

    @Test func oPacoteLevaAsSecoesEscolhidasEAObraSemEscolhaNaoEntra() throws {
        let obra = try Self.fonteDaObra()
        let secoes = Obra.secoes(obra.texto)
        let escolhidas = [secoes[20].texto, secoes[0].texto]
        let pergunta = "os clientes estão indo embora depois de dois meses; o que faço?"
        let pacote = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [obra], conversa: [], catalogo: "",
                                                       retrato: "", teto: 16_000, escolhidas: [obra.id: escolhidas]))
        #expect(pacote.fontes.first?.texto == escolhidas.joined(separator: "\n\n"))
        let nenhuma = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [obra], conversa: [], catalogo: "",
                                                        retrato: "", teto: 16_000, escolhidas: [obra.id: []]))
        #expect(nenhuma.fontes.isEmpty && nenhuma.omitidas == 0)
        // sem escolha do modelo, a de antes: as palavras
        let palavras = try #require(RespostaNotas.montar(pergunta: "estou pensando em baixar o preço porque os clientes estão cancelando",
                                                         fontes: [obra], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        #expect(palavras.fontes.first?.texto.contains("Quase nunca baixar preço") == true)
    }

    /// O diário do app (pesos por resultado) fica fora destes testes: a rota lê `Sinais.todos()`.
    private func semDiario<T>(_ executar: () async throws -> T) async rethrows -> T {
        let antes = Sinais.url
        Sinais.url = FileManager.default.temporaryDirectory.appendingPathComponent("sinais-\(UUID()).json")
        defer { Sinais.url = antes }
        return try await executar()
    }

    /// A ligação: a rota das Notas pede a escolha ANTES de montar, e o que o
    /// modelo escolheu — não as três das palavras — é o que vai à geração.
    @Test func aRotaDasNotasMandaAEscolhaDoModeloAGeracao() async throws {
        try await semDiario {
            let obra = try Self.fonteDaObra()
            let pergunta = "estou pensando em baixar o preço porque os clientes estão cancelando"
            let lista = Array(Obra.ranquear(pergunta: pergunta, texto: obra.texto).prefix(Conselho.candidatas))
            let alvo = try #require(lista.dropFirst(min(9, lista.count - 1)).first).secao
            let n = try #require(lista.firstIndex { $0.secao == alvo }) + 1
            var enviado: RespostaNotas.Pacote?
            _ = await Sabia.responderNasNotas(pergunta: pergunta, fontes: [obra],
                                              escolherObra: { _, _, _ in #"{"regras":[\#(n)]}"# },
                                              gerarRemoto: { p in enviado = p; return nil })
            #expect(enviado?.fontes.first?.texto == alvo.texto)
            // sem conta (escolherObra nil) as palavras decidem: as três do ranking
            var semConta: RespostaNotas.Pacote?
            _ = await Sabia.responderNasNotas(pergunta: pergunta, fontes: [obra], escolherObra: nil,
                                              gerarRemoto: { p in semConta = p; return nil })
            #expect(semConta?.fontes.first?.texto == lista.prefix(3).map(\.secao.texto).joined(separator: "\n\n"))
        }
    }

    /// Revisão da E2: a obra que o modelo julgou fora do assunto não "deixou de
    /// caber" — "o que o Alex Hormozi diz sobre casamento?" recebia a recusa
    /// «Alex Hormozi não coube nesta consulta» e ficava sem resposta.
    @Test func obraForaDoAssuntoNaoViraRecusaDeQueNaoCoube() async throws {
        try await semDiario {
            let obra = try Self.fonteDaObra()
            let pergunta = "o que o Alex Hormozi diz sobre casamento?"
            for escolher in [{ (_: String, _: String, _: String) async -> String? in #"{"regras":[]}"# }, nil] {
                var gerou = false
                let r = await Sabia.responderNasNotas(pergunta: pergunta, fontes: [obra], escolherObra: escolher,
                                                      gerarRemoto: { _ in gerou = true; return nil })
                #expect(r?.texto.contains(GuardaDeObra.fraseForaDestaConsulta) != true)
                #expect(gerou, "a pergunta segue à geração, como antes da E2")
            }
        }
    }

    /// Revisão da E2: a biblioteca regenerada ao lado da velha repete seções
    /// iguais; a escolhida viaja uma vez, não uma por obra.
    @Test func aSecaoEscolhidaViajaUmaVezMesmoRepetidaEmDuasObras() async throws {
        try await semDiario {
            let velha = try Self.fonteDaObra()
            let nova = FonteNotas(id: UUID(), titulo: "Alex Hormozi — regras conferidas · obra",
                                  texto: velha.texto + "\n\n## 99. Regra nova\nRegra: uma regra que só a nova tem",
                                  editadaEm: .now, obraConferida: true)
            let pergunta = "estou pensando em baixar o preço porque os clientes estão cancelando"
            let alvo = try #require(Obra.ranquear(pergunta: pergunta, textos: [velha.texto, nova.texto]).first).secao
            var enviado: RespostaNotas.Pacote?
            _ = await Sabia.responderNasNotas(pergunta: pergunta, fontes: [velha, nova],
                                              escolherObra: { _, _, _ in #"{"regras":[1,2]}"# },
                                              gerarRemoto: { p in enviado = p; return nil })
            let textos = (enviado?.fontes ?? []).map(\.texto).joined(separator: "\n\n")
            #expect(textos.components(separatedBy: alvo.titulo).count - 1 == 1, "\(textos.prefix(200))")
        }
    }

    /// A escolha tem queda própria: a falha dela não troca o aviso que a tela
    /// mostra (nem apaga o de outra rota).
    @Test func aFalhaDaEscolhaNaoViraOAvisoDaResposta() async throws {
        try await semDiario {
            let obra = try Self.fonteDaObra()
            Grok.limparFalha()
            defer { Grok.limparFalha() }
            _ = await Sabia.responderNasNotas(pergunta: "baixo o preço porque os clientes cancelam?", fontes: [obra],
                                              escolherObra: { _, _, _ in Grok.registrarFalha(.timeout); return nil },
                                              gerarRemoto: { _ in nil })
            #expect(Grok.falhaPendente() == nil)
            Grok.registrarFalha(.recusa)
            await Grok.$semAviso.withValue(true) { Grok.limparFalha() }
            #expect(Grok.falhaPendente() == .recusa, "o aviso de outra rota fica")
        }
    }

    /// Com a escolha pelo sentido, a obra conferida chega à rota se a pergunta
    /// toca QUALQUER seção dela; quem corta é o modelo, ou a admissão das
    /// palavras no pacote quando não há conta. A suposta segue pela admissão.
    @Test func aObraConferidaEntraNaRotaSeAPerguntaTocaAlgumaSecao() throws {
        // uma seção toca a pergunta por UM radical: as palavras não a admitem (16c)
        let texto = (1...8).map { "## \($0). Regra \($0)\nRegra: " + ($0 == 3 ? "suba o preço antes de cortar" : "assunto número \($0) sem relação") }
            .joined(separator: "\n\n")
        let pergunta = "e o preço?"
        let ranking = Obra.ranquear(pergunta: pergunta, texto: texto)
        try #require(!ranking.isEmpty && !ranking.contains(where: Obra.admite))
        let conferida = FonteNotas(id: UUID(), titulo: "mestre · obra", texto: texto, editadaEm: .now, obraConferida: true)
        let suposta = FonteNotas(id: UUID(), titulo: "arquivo · parece obra", texto: texto, editadaEm: .now, obra: true)
        #expect(Sessao.obraCandidata(conferida, pergunta: pergunta), "o modelo decide se serve")
        #expect(!Sessao.obraCandidata(suposta, pergunta: pergunta), "a suposta segue pela admissão")
        #expect(!Sessao.obraCandidata(conferida, pergunta: "qual a cor do céu azulado?"))
        // sem conta, o pacote ainda corta pelas palavras: a obra não entra
        let pacote = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [conferida], conversa: [],
                                                       catalogo: "", retrato: "", teto: 16_000))
        #expect(pacote.fontes.isEmpty && pacote.omitidas == 0)
    }

    /// ADR 2026-09-16k: a geração e a conferência das Notas dizem que obra não
    /// é nota da pessoa. O efeito se mede no Air (prova/16k); aqui fica o texto.
    @Test func osPedidosDasNotasDizemDeQuemEAObra() {
        #expect(Sabia.sistemaResponderNasNotas.contains(Sabia.vozDaObra))
        #expect(Sabia.sistemaConferirNasNotas.contains(Sabia.vozDaObra))
        #expect(Sabia.vozDaObra.contains("suas notas"))
        #expect(Sabia.sistemaResponderNasNotas.contains(Sabia.semGenero) && Sabia.sistemaConferirNasNotas.contains(Sabia.semGenero))
    }

    // MARK: ADR 2026-09-16k — as notas do autor pelo sentido (V2)

    /// Decisão do dono: trancada, queimada, selada e expressiva NUNCA são
    /// candidatas — nem o título delas vai à rede. Nem obra, nem nota do bot.
    @Test func nenhumaNotaFechadaViraCandidata() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let aberta = Nota(texto: "Decidi trocar de contador em outubro")
        let trancada = Nota(texto: "Decidi sobre o contador, trancada"); trancada.trancada = true
        let queimada = Nota(texto: "Decidi sobre o contador, queimada"); queimada.queimada = true
        let expressiva = Nota(texto: "Escrevi sobre o contador", gesto: .expressiva)
        let selada = Nota(texto: "Selei o que senti sobre o contador", gesto: .expressiva); selada.trancada = true
        let obra = Nota(texto: "## 1. Regra\nRegra: contador"); obra.origem = .obra
        let bot = Nota(texto: "Resumo do bot sobre o contador"); bot.origem = .grokbot
        for n in [aberta, trancada, queimada, expressiva, selada, obra, bot] { ctx.insert(n) }
        try ctx.save()
        let candidatas = Sessao.candidatasDoAutor(pergunta: "o que eu decidi sobre o contador?", no: ctx)
        #expect(candidatas.map(\.id) == [aberta.uuid])
    }

    /// Só título e começo vão na escolha; a escolhida entra inteira e primeiro.
    @Test func aNotaEscolhidaPeloSentidoEntraInteiraEAntes() async throws {
        let longa = FonteNotas(id: UUID(), titulo: "Contabilidade da PJ",
                               texto: "Contabilidade da PJ\n" + String(repeating: "detalhe ", count: 60) + "FIM-SECRETO-DA-NOTA",
                               editadaEm: .now)
        let outra = FonteNotas(id: UUID(), titulo: "Lista de compras", texto: "Lista de compras: pão", editadaEm: .now)
        let obra = try Self.fonteDaObra()
        var pedido = ""
        let fontes = await Sessao.comNotasPeloSentido(pergunta: "quem cuida da papelada dos meus impostos?",
                                                      fontes: [outra, obra], candidatas: [outra, longa]) { s, u, e in
            pedido = u
            #expect(s == Sessao.sistemaEscolherNotas && e == Sessao.esquemaEscolherNotas)
            return #"{"notas":[2]}"#
        }
        #expect(fontes.map(\.id) == [longa.id, outra.id, obra.id])
        #expect(fontes.first?.texto.contains("FIM-SECRETO-DA-NOTA") == true, "a escolhida vai inteira")
        #expect(!pedido.contains("FIM-SECRETO-DA-NOTA"), "na escolha só o começo viaja")
        // sem conta ou ilegível: a seleção de antes
        for cru in [nil, "não sei"] as [String?] {
            let igual = await Sessao.comNotasPeloSentido(pergunta: "x", fontes: [outra], candidatas: [outra, longa]) { _, _, _ in cru }
            #expect(igual.map(\.id) == [outra.id])
        }
        // varredura das guardas que calam (E9, líder 17/09): o número repetido conta uma vez, o resto fica
        let repetida = await Sessao.comNotasPeloSentido(pergunta: "x", fontes: [outra], candidatas: [outra, longa]) { _, _, _ in #"{"notas":[1,2,1]}"# }
        #expect(repetida.map(\.id) == [outra.id, longa.id])
        // até 5 valem; o sexto sai e os cinco ficam (antes a escolha inteira virava ilegível)
        let sete = (1...7).map { FonteNotas(id: UUID(), titulo: "nota \($0)", texto: "texto \($0)", editadaEm: .now) }
        let cinco = await Sessao.comNotasPeloSentido(pergunta: "x", fontes: [], candidatas: sete) { _, _, _ in #"{"notas":[1,2,3,4,5]}"# }
        #expect(cinco.map(\.id) == Array(sete.prefix(5)).map(\.id))
        let seis = await Sessao.comNotasPeloSentido(pergunta: "x", fontes: [], candidatas: sete) { _, _, _ in #"{"notas":[1,2,3,4,5,6]}"# }
        #expect(seis.map(\.id) == Array(sete.prefix(5)).map(\.id))
        #expect(await Sessao.comNotasPeloSentido(pergunta: "x", fontes: [outra], candidatas: [longa], perguntar: nil).map(\.id) == [outra.id])
    }

    /// A ligação: a pergunta nas Notas passa pela escolha antes da rota.
    @Test func aPerguntaNasNotasLevaANotaEscolhida() async throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let decisao = Nota(texto: "# Contabilidade", gesto: .decisao,
                           campos: ["escolha": "Trocar de escritório de contabilidade", "decidido": "Trocar em outubro"])
        let distratora = Nota(texto: "Comprar pão e café")
        c.mainContext.insert(decisao); c.mainContext.insert(distratora)
        try c.mainContext.save()
        let s = Sessao()
        var enviadas: [FonteNotas] = []
        s.escolherNotas = { _, u, _ in
            let lista = (try? JSONSerialization.jsonObject(with: Data(u.utf8)) as? [String: Any])?["notas"] as? [[String: Any]] ?? []
            let n = lista.firstIndex { ($0["titulo"] as? String)?.contains("Contabilidade") == true }.map { $0 + 1 } ?? 0
            return #"{"notas":[\#(n)]}"#
        }
        s.responderContextoNotas = { _, fontes, _, _, _, _ in enviadas = fontes; return nil }
        _ = await s.responderNasNotas("quem cuida da papelada dos meus impostos?", conversa: [], no: c.mainContext)
        #expect(enviadas.first?.id == decisao.uuid)
    }

    /// V3: o campo vai com o rótulo do método — o modelo sabe o que foi decidido
    /// e o que estava em jogo (real-01: sem rótulo, "linhas em conflito" 3 de 3).
    @Test func aDecisaoVaiAoPedidoComOsCamposRotulados() throws {
        // revisão da V: com o rótulo, a Leitura só com a fonte continua sendo "só o nome"
        let leitura = Nota(texto: "", gesto: Gesto(rawValue: "leitura"), campos: ["fonte": "Antifrágil"])
        try #require(leitura.gesto != nil, "a forma Leitura existe no catálogo")
        let daLeitura = try #require(Sessao.fonteParaPergunta(leitura))
        #expect(daLeitura.texto.contains(": Antifrágil"))
        #expect(GuardaDeObra.soONome(daLeitura, pedido: .init(nome: "Antifrágil")))
        // a obra suposta não é dita "de um mestre" no pedido
        let suposta = FonteNotas(id: UUID(), titulo: "arquivo · parece obra", texto: "## 1. Cobre antes\ncobre o cliente antes de entregar", editadaEm: .now, obra: true)
        let pacoteSuposta = try #require(RespostaNotas.montar(pergunta: "cobro o cliente antes de entregar?", fontes: [suposta], conversa: [], catalogo: "", retrato: "", teto: 16_000))
        #expect(pacoteSuposta.mensagem.contains(Obra.origemSupostaNoPedido) && !pacoteSuposta.mensagem.contains(Obra.origemNoPedido))
        let nota = Nota(texto: "# Dar desconto para fechar a proposta", gesto: .decisao,
                        campos: ["escolha": "Dar 20% de desconto para o cliente que está enrolando",
                                 "decidido": "Não dar desconto e oferecer um bônus de implantação", "aconteceu": ""])
        let fonte = try #require(Sessao.fonteParaPergunta(nota))
        let decidido = try #require(Gesto.decisao.metodoDef.campos.first { $0.id == "decidido" }).nome
        let escolha = try #require(Gesto.decisao.metodoDef.campos.first { $0.id == "escolha" }).nome
        #expect(fonte.texto.contains("\(decidido): Não dar desconto e oferecer um bônus de implantação"), "\(fonte.texto)")
        #expect(fonte.texto.contains("\(escolha): Dar 20% de desconto"))
        #expect(!fonte.texto.contains(": \n") && !fonte.texto.hasSuffix(":"), "campo vazio não vira rótulo solto")
        // nota sem forma continua como era
        let solta = Nota(texto: "Comprar pão")
        #expect(Sessao.fonteParaPergunta(solta)?.texto == solta.textoDeQualquerOrigem)
    }
}
