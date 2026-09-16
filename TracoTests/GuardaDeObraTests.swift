import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-12a — a guarda é local. Uma obra fantasma cai mesmo quando
/// o gerador inventa. Saber-de-mundo pela base `geral` não atravessa.
@MainActor
struct GuardaDeObraTests {
    private let fantasma = "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?"

    /// Transporte/guarda: a conferência ecoa a candidata. Não mede sentido.
    private func eco(_ pacote: RespostaNotas.Pacote, _ cru: String) async -> String? { cru }

    /// A rota das Notas não recusa com ausência global. Geração + conferência
    /// leem o material enviado; a conferência aqui é dublê de reparo.
    private func semTeseInventadaNaRotaDasNotas(pergunta: String, inventado: String) async throws -> RespostaNotas.Retorno {
        var gerou = 0, conferiu = 0
        let ajuda = #"{"base":"notas","texto":"Nesta consulta o material é o orçamento da viagem. Não invento tese de obra que o trecho não traz.","trechoIDs":["N1T1"]}"#
        let r = try #require(await Sabia.responderNasNotas(
            pergunta: pergunta, fontes: [fonteViagem()],
            gerarRemoto: { _ in gerou += 1; return inventado },
            conferirRemoto: { _, _ in conferiu += 1; return ajuda }))
        #expect(gerou == 1 && conferiu == 1)
        return r
    }

    private func fonteViagem() -> FonteNotas {
        .init(id: UUID(), titulo: "Orçamento da viagem",
              texto: "Reservei R$ 6.000. Hospedagem 400 euros.",
              editadaEm: Date(timeIntervalSince1970: 1_783_000_000))
    }

    private func fonteDaObra() -> FonteNotas {
        .init(id: UUID(), titulo: "Tratado das Nuvens Invertidas",
              texto: "Mélanie Voss: a tese é que a nuvem invertida ensina a esperar.",
              editadaEm: Date(timeIntervalSince1970: 1_783_000_000))
    }

    @Test func obraFantasmaEPedidoBibliografico() throws {
        let p = try #require(GuardaDeObra.pedido(fantasma))
        #expect(p.nome.contains("Nuvens"))
        #expect(p.nome.contains("Voss") || p.nome.contains("Mélanie") || p.nome.contains("Melanie"))
        #expect(GuardaDeObra.pedido("Qual é o prazo da entrega?") == nil)
        #expect(GuardaDeObra.pedido("O que é WOOP?") == nil)
        #expect(GuardaDeObra.pedido("estou lendo um livro sobre culinária") == nil)
    }

    /// O português põe o nome ANTES do verbo. Sem isto a guarda só via
    /// «diz Kahneman» e «O que o Daniel Kahneman diz» ia ao modelo inventar.
    @Test func autorAntesDoVerboEPedidoENaoInventa() async throws {
        let pergunta = "O que o Daniel Kahneman diz sobre ruído?"
        let p = try #require(GuardaDeObra.pedido(pergunta))
        #expect(p.nome.contains("Daniel"))
        #expect(p.nome.contains("Kahneman"))
        #expect(GuardaDeObra.pedido("O que ela diz sobre o prazo?") == nil)
        #expect(GuardaDeObra.pedido("O que você afirma no relatório?") == nil)

        let r = try await semTeseInventadaNaRotaDasNotas(
            pergunta: pergunta, inventado: #"{"base":"geral","texto":"Kahneman defende um decreto sobre ruído.","trechoIDs":[]}"#)
        #expect(r.texto.contains("decreto") != true)
        #expect(r.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r.obraParaPlantar == nil)
    }

    /// «pensa» é o mesmo pedido que «diz». Sem isto a guarda só via o
    /// verbo medido e «O que o Kahneman pensa» ia ao modelo inventar.
    @Test func pensaTambemEPedidoENaoInventa() async throws {
        let depois = "O que o Daniel Kahneman pensa sobre ruído?"
        let antes = "O que pensa o Daniel Kahneman sobre ruído?"
        let p1 = try #require(GuardaDeObra.pedido(depois))
        let p2 = try #require(GuardaDeObra.pedido(antes))
        #expect(p1.nome.contains("Daniel") && p1.nome.contains("Kahneman"))
        #expect(p2.nome.contains("Daniel") && p2.nome.contains("Kahneman"))
        #expect(GuardaDeObra.pedido("O que ela pensa sobre o prazo?") == nil)
        #expect(GuardaDeObra.pedido("O que você pensa do relatório?") == nil)

        let r = try await semTeseInventadaNaRotaDasNotas(
            pergunta: depois, inventado: #"{"base":"geral","texto":"Kahneman pensa um decreto sobre ruído.","trechoIDs":[]}"#)
        #expect(r.texto.contains("decreto") != true)
        #expect(r.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r.obraParaPlantar == nil)
    }

    /// Os outros verbos de atribuição. Sem isto «explica» / «argumenta» /
    /// «escreve» iam ao modelo inventar a tese — o mesmo furo do «pensa».
    @Test func verbosDeAtribuicaoCalamOModelo() async throws {
        for verbo in ["explica", "argumenta", "escreve"] {
            let p = try #require(GuardaDeObra.pedido("O que o Daniel Kahneman \(verbo) sobre ruído?"))
            #expect(p.nome.contains("Daniel") && p.nome.contains("Kahneman"), "\(verbo)")
            #expect(GuardaDeObra.pedido("O que ela \(verbo) sobre o prazo?") == nil, "\(verbo)")
        }
        #expect(GuardaDeObra.pedido("Como o Daniel Kahneman explica o ruído?") != nil)

        let r = try await semTeseInventadaNaRotaDasNotas(
            pergunta: "Como o Daniel Kahneman explica o ruído?",
            inventado: #"{"base":"geral","texto":"Kahneman explica um decreto sobre ruído.","trechoIDs":[]}"#)
        #expect(r.texto.contains("decreto") != true)
        #expect(r.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r.obraParaPlantar == nil)
    }

    /// «segundo» já pega. «de acordo com» e «na opinião de» são o mesmo
    /// pedido de autor — sem isto o modelo inventava a tese.
    @Test func deAcordoComENaOpiniaoDeCalamOModelo() async throws {
        let acordo = "De acordo com Daniel Kahneman, o que é ruído?"
        let opiniao = "Na opinião de Daniel Kahneman o que é ruído?"
        let p1 = try #require(GuardaDeObra.pedido(acordo))
        let p2 = try #require(GuardaDeObra.pedido(opiniao))
        #expect(p1.nome.contains("Daniel") && p1.nome.contains("Kahneman"))
        #expect(p2.nome.contains("Daniel") && p2.nome.contains("Kahneman"))
        #expect(!p1.nome.contains("ruído") && !p1.nome.contains("ruido"))
        #expect(!p2.nome.contains("ruído") && !p2.nome.contains("ruido"))
        #expect(GuardaDeObra.pedido("De acordo com ela, o que falta no prazo?") == nil)
        #expect(GuardaDeObra.pedido("Na opinião de você, o que falta?") == nil)
        #expect(GuardaDeObra.pedido("Qual é o prazo da entrega?") == nil)

        let r = try await semTeseInventadaNaRotaDasNotas(
            pergunta: acordo, inventado: #"{"base":"geral","texto":"Kahneman defende um decreto sobre ruído.","trechoIDs":[]}"#)
        #expect(r.texto.contains("decreto") != true)
        #expect(r.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r.obraParaPlantar == nil)
    }

    @Test func obraNasFontesNaoRecusa() throws {
        let p = try #require(GuardaDeObra.pedido(fantasma))
        #expect(GuardaDeObra.estaNasFontes(p, fontes: [fonteDaObra()]))
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: [fonteViagem()]))
        #expect(GuardaDeObra.recusarSeAusente(pergunta: fantasma, fontes: [fonteDaObra()]) == nil)
    }

    @Test func recusaUsaAFraseEOferecePlantar() throws {
        let r = try #require(GuardaDeObra.recusarSeAusente(pergunta: fantasma, fontes: [fonteViagem()]))
        #expect(r.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno))
        #expect(r.texto.contains("plantar"))
        #expect(r.base == "insuficiente")
        #expect(r.enviadas.isEmpty && r.citadas.isEmpty)
        #expect(!r.texto.contains("nuvem invertida ensina"))
        #expect(r.obraParaPlantar?.contains("Nuvens") == true)
        #expect(GuardaDeObra.textoPlantado(r.obraParaPlantar ?? "")?.contains("decreto") != true)
    }

    /// Mutação: o gerador inventa a tese. A rota das Notas não recusa com
    /// ausência global; a conferência (dublê) tira a tese. A guarda
    /// `recusarSeAusente` continua na Página e no próprio tipo.
    @Test func obraFantasmaCaiMesmoQuandoOModeloInventa() async throws {
        let r = try await semTeseInventadaNaRotaDasNotas(
            pergunta: fantasma,
            inventado: #"{"base":"geral","texto":"Voss defende que a nuvem invertida é um decreto.","trechoIDs":[]}"#)
        #expect(!r.texto.contains("decreto"))
        #expect(!r.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno))
        #expect(r.obraParaPlantar == nil)
        #expect(GuardaDeObra.recusarSeAusente(pergunta: fantasma, fontes: [fonteViagem()]) != nil)
    }

    @Test func obraPlantadaDeixaOModeloResponder() async {
        var chamou = false
        let sustentado = #"{"base":"notas","texto":"A tese plantada é esperar.","trechoIDs":["N1T1"]}"#
        let r = await Sabia.responderNasNotas(
            pergunta: fantasma, fontes: [fonteDaObra()],
            gerarRemoto: { _ in
                chamou = true
                return sustentado
            },
            conferirRemoto: eco)
        #expect(chamou)
        #expect(r?.conferida == true)
        #expect(r?.texto.contains("A tese plantada é esperar.") == true)
        #expect(r?.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
    }

    @Test func perguntaComumAindaPodeUsarGeral() async {
        var chamou = false
        let geral = #"{"base":"geral","texto":"WOOP é desejo, resultado, obstáculo e plano.","trechoIDs":[]}"#
        let r = await Sabia.responderNasNotas(
            pergunta: "O que é WOOP?", fontes: [fonteViagem()],
            gerarRemoto: { _ in
                chamou = true
                return geral
            },
            conferirRemoto: eco)
        #expect(chamou)
        #expect(r?.conferida == true)
        #expect(r?.texto.contains("WOOP") == true)
        #expect(r?.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
    }

    @Test func seloNaoPlantaObraAGuardaNaoBuscaODisco() throws {
        let p = try #require(GuardaDeObra.pedido(fantasma))
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: []))
        #expect(GuardaDeObra.recusarSeAusente(pergunta: fantasma, fontes: []) != nil)
    }

    @Test func plantarAObraADeixaNasFontesSemInventarTese() throws {
        try isolado {
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            let recusa = try #require(GuardaDeObra.recusarSeAusente(pergunta: fantasma, fontes: [fonteViagem()]))
            let nome = try #require(recusa.obraParaPlantar)
            #expect(GuardaDeObra.textoPlantado("   ") == nil)
            #expect(s.plantarObra("   ", no: c.mainContext) == nil)

            let nota = try #require(s.plantarObra(nome, no: c.mainContext))
            #expect(nota.origem == .autor)
            #expect(nota.texto == nome)
            #expect(!nota.texto.contains("decreto"))
            #expect(!nota.texto.contains("nuvem invertida ensina"))
            let fonte = try #require(Sessao.fonteParaPergunta(nota))
            #expect(GuardaDeObra.estaNasFontes(.init(nome: nome), fontes: [fonte]))
            #expect(GuardaDeObra.recusarSeAusente(pergunta: fantasma, fontes: [fonte]) == nil)
            #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: fantasma, fontes: [fonte]) != nil)
        }
    }

    @Test func tituloEntreAspasTambemEPedido() throws {
        let p = try #require(GuardaDeObra.pedido("O que diz «O Jogo da Vida e Como Jogá-lo» sobre decreto?"))
        #expect(p.nome.contains("Jogo da Vida"))
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: [fonteViagem()]))
    }

    @Test func aRotaDeProducaoNaoExtrapolASelecaoParaOCaderno() async throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        var gerou = 0, conferiu = 0
        let ajuda = #"{"base":"insuficiente","texto":"Nesta consulta não veio trecho da obra. Não invento a tese.","trechoIDs":[]}"#
        s.responderContextoNotas = { pergunta, fontes, conversa, catalogo, retrato, validar in
            await Sabia.responderNasNotas(
                pergunta: pergunta, fontes: fontes, conversa: conversa,
                catalogo: catalogo, retrato: retrato, validarAcesso: validar,
                gerarRemoto: { _ in
                    gerou += 1
                    return #"{"base":"geral","texto":"Voss defende um decreto.","trechoIDs":[]}"#
                },
                conferirRemoto: { _, _ in
                    conferiu += 1
                    return ajuda
                })
        }
        let r = await s.responderNasNotas(fantasma, conversa: [], no: c.mainContext)
        #expect(gerou == 1 && conferiu == 1)
        #expect(r.resposta?.contains("decreto") != true)
        #expect(r.resposta?.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r.obraParaPlantar == nil)
    }

    @Test func aFolhaOfereceOGestoDePlantar() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let notas = try String(contentsOf: raiz.appendingPathComponent("Traco/Notas/NotasView.swift"), encoding: .utf8)
        #expect(notas.contains("plantar-sabia-notas"))
        #expect(notas.contains("Plantar esta obra"))
        #expect(notas.contains("plantarObraDaGuarda"))
    }

    @Test func titulosCurtosSaoPedidoEFraseComumNaoE() throws {
        #expect(GuardaDeObra.pedido("Resuma o livro Hamlet")?.nome.localizedCaseInsensitiveContains("Hamlet") == true)
        #expect(GuardaDeObra.pedido("Resuma o livro Duna")?.nome.localizedCaseInsensitiveContains("Duna") == true)
        #expect(GuardaDeObra.pedido("Explique Dom Casmurro")?.nome.contains("Casmurro") == true)
        #expect(GuardaDeObra.recusarSeAusente(pergunta: "Resuma o livro Hamlet", fontes: []) != nil)
        #expect(GuardaDeObra.recusarSeAusente(pergunta: "Explique Dom Casmurro", fontes: []) != nil)
        #expect(GuardaDeObra.pedido("Explique a frase \"planejamento semanal\".") == nil)
        #expect(GuardaDeObra.recusarSeAusente(
            pergunta: "Explique a frase \"planejamento semanal\".", fontes: []) == nil)
        #expect(GuardaDeObra.pedido("O que o planejamento semanal diz sobre as metas?") == nil)
    }

    @Test func mencaoNaoIdentificaENomePuroRecusa() throws {
        let p = try #require(GuardaDeObra.pedido("Resuma o livro Hamlet"))
        let mencao = FonteNotas(id: UUID(), titulo: "Reunião",
                                texto: "No planejamento semanal citei Hamlet.", editadaEm: .now)
        let obra = FonteNotas(id: UUID(), titulo: "Hamlet",
                              texto: "Hamlet: a tese é a dúvida que atrasa o ato.", editadaEm: .now)
        let soNome = FonteNotas(id: UUID(), titulo: "Hamlet", texto: "Hamlet", editadaEm: .now)
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: [mencao]))
        #expect(GuardaDeObra.estaNasFontes(p, fontes: [soNome]))
        #expect(GuardaDeObra.soONome(soNome, pedido: p))
        #expect(!GuardaDeObra.soONome(obra, pedido: p))
        #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: "Resuma o livro Hamlet", fontes: [soNome]) != nil)
        #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: "Resuma o livro Hamlet", fontes: [obra]) == nil)
        #expect(GuardaDeObra.recusarSeAusente(pergunta: "Resuma o livro Hamlet", fontes: [soNome]) == nil)
    }

    @Test func prefixoGenericoNaoIdentificaEConteudoExtraNaoETeseQualificada() throws {
        let p = try #require(GuardaDeObra.pedido(fantasma))
        #expect(GuardaDeObra.estaNasFontes(p, fontes: [fonteDaObra()]))
        let generico = FonteNotas(id: UUID(), titulo: "Tratado", texto: "Tratado", editadaEm: .now)
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: [generico]))
        let parcial = FonteNotas(id: UUID(), titulo: "Tratado das Nuvens",
                                 texto: "Tratado das Nuvens", editadaEm: .now)
        #expect(!GuardaDeObra.estaNasFontes(p, fontes: [parcial]))
        let caderno = GuardaDeObra.Pedido(nome: "Caderno de Planos Impossíveis")
        let soCaderno = FonteNotas(id: UUID(), titulo: "Caderno", texto: "Caderno", editadaEm: .now)
        #expect(!GuardaDeObra.estaNasFontes(caderno, fontes: [soCaderno]))
        let duna = try #require(GuardaDeObra.pedido("Resuma o livro Duna"))
        for texto in ["Quero comprar Duna", "Duna é caro", "Duna de Frank Herbert"] {
            let f = FonteNotas(id: UUID(), titulo: "Duna", texto: texto, editadaEm: .now)
            #expect(GuardaDeObra.estaNasFontes(duna, fontes: [f]), Comment(rawValue: texto))
            #expect(!GuardaDeObra.soONome(f, pedido: duna), Comment(rawValue: texto))
        }
        let soDuna = FonteNotas(id: UUID(), titulo: "Duna", texto: "Duna", editadaEm: .now)
        #expect(GuardaDeObra.soONome(soDuna, pedido: duna))
        #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: "Resuma o livro Duna", fontes: [soDuna]) != nil)
    }

    @Test func nomePlantadoNaoSustentaTeseNemChamaOModelo() async throws {
        try await isolado {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        let nome = try #require(GuardaDeObra.pedido(fantasma)?.nome)
        let nota = try #require(s.plantarObra(nome, no: c.mainContext))
        let fonte = try #require(Sessao.fonteParaPergunta(nota))
        #expect(GuardaDeObra.estaNasFontes(.init(nome: nome), fontes: [fonte]))
        #expect(GuardaDeObra.soONome(fonte, pedido: .init(nome: nome)))
        var chamou = false
        let r = await Sabia.responderNasNotas(
            pergunta: fantasma, fontes: [fonte],
            gerarRemoto: { _ in
                chamou = true
                return #"{"base":"geral","texto":"Voss defende um decreto.","trechoIDs":[]}"#
            },
            conferirRemoto: { _, cru in
                chamou = true
                return cru
            })
        #expect(!chamou, "nome plantado não autoriza inventar tese")
        #expect(r?.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r?.obraParaPlantar == nil)
        #expect(r?.base == "insuficiente")
        #expect(r?.texto.contains("decreto") != true)
        }
    }

    private func isolado(_ executar: () async throws -> Void) async throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("guarda-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let indice = Indice.url, corpus = Corpus.diretorio
        let espelho = PastaEspelho.defaults
        let nome = "guarda-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Indice.url = raiz.appendingPathComponent("indice.json")
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Indice.apagarTudo()
        defer {
            Indice.apagarTudo()
            Indice.url = indice
            Corpus.diretorio = corpus
            PastaEspelho.defaults = espelho
            defaults.removePersistentDomain(forName: nome)
        }
        try await executar()
    }

    private func isolado(_ executar: () throws -> Void) throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("guarda-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let indice = Indice.url, corpus = Corpus.diretorio
        let espelho = PastaEspelho.defaults
        let nome = "guarda-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Indice.url = raiz.appendingPathComponent("indice.json")
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Indice.apagarTudo()
        defer {
            Indice.apagarTudo()
            Indice.url = indice
            Corpus.diretorio = corpus
            PastaEspelho.defaults = espelho
            defaults.removePersistentDomain(forName: nome)
        }
        try executar()
    }

    @Test func consultaInsuficienteOlhaAsFontesDoPacote() throws {
        let p = try #require(GuardaDeObra.pedido(fantasma))
        #expect(GuardaDeObra.estaNasFontes(p, fontes: [fonteDaObra()]))
        #expect(!GuardaDeObra.soONome(fonteDaObra(), pedido: p))
        #expect(GuardaDeObra.recusarSeConsultaInsuficiente(pergunta: fantasma, fontes: [fonteViagem()]) == nil)
        let omitida = try #require(GuardaDeObra.recusarSeOmitidaDoPacote(
            pergunta: fantasma, originais: [fonteDaObra()], efetivas: [fonteViagem()]))
        #expect(omitida.obraParaPlantar == nil)
        #expect(!omitida.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno))
        let sabia = try String(contentsOf: URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Traco/Analise/Sabia.swift"), encoding: .utf8)
        #expect(sabia.contains("recusarSeConsultaInsuficiente(pergunta: pergunta, fontes: pacote.fontes)"))
        #expect(!sabia.contains("recusarSeAusente(pergunta: pergunta, fontes: fontes)"))
        // ADR 16c: a guarda da obra omitida tem chamador, e só quando nada coube
        #expect(sabia.contains("if pacote.fontes.isEmpty,\n           let recusa = GuardaDeObra.recusarSeOmitidaDoPacote(pergunta: pergunta"))
    }

    @Test func fonteOmitidaDoPacoteNaoAbreTese() async throws {
        let p = try #require(GuardaDeObra.pedido(fantasma))
        let obra = FonteNotas(
            id: UUID(), titulo: "Tratado das Nuvens Invertidas",
            texto: "Tratado das Nuvens Invertidas. Mélanie Voss: a tese é que a nuvem invertida ensina a esperar. "
                + String(repeating: "a nuvem invertida ensina a esperar. ", count: 800),
            editadaEm: Date(timeIntervalSince1970: 1_783_000_000))
        try #require(GuardaDeObra.estaNasFontes(p, fontes: [obra]))
        let pacote = try #require(RespostaNotas.montar(
            pergunta: fantasma, fontes: [obra], conversa: [],
            catalogo: "", retrato: "", teto: 16_000))
        try #require(!pacote.fontes.contains { $0.id == obra.id })
        try #require(pacote.omitidas >= 1)
        var gerou = 0, conferiu = 0
        let ajuda = #"{"base":"insuficiente","texto":"A obra não coube nesta consulta; não invento a tese.","trechoIDs":[]}"#
        let r = await Sabia.responderNasNotas(
            pergunta: fantasma, fontes: [obra],
            gerarRemoto: { pacote in
                gerou += 1
                #expect(pacote.fontes.isEmpty)
                return #"{"base":"geral","texto":"inventei a tese.","trechoIDs":[]}"#
            },
            conferirRemoto: { pacote, _ in
                conferiu += 1
                #expect(pacote.fontes.isEmpty)
                return ajuda
            })
        // ADR 2026-09-16c: a obra pedida estava na seleção e NADA coube — a
        // recusa é local («fora desta consulta») e o modelo não é chamado; com
        // outra fonte no pacote, a 12b vale e a pergunta segue
        #expect(gerou == 0 && conferiu == 0)
        #expect(r?.texto.contains(GuardaDeObra.fraseForaDestaConsulta) == true)
        #expect(r?.obraParaPlantar == nil)
        #expect(r?.texto.contains(GuardaDeObra.fraseNaoEstaNoCaderno) != true)
        #expect(r?.texto.contains("inventei a tese") != true)
    }

    @Test func persistenciaFalhouNaoProjeta() throws {
        enum Recusa: Error { case disco }
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let indice = Indice.url
        Indice.url = raiz.appendingPathComponent("indice.json")
        Indice.apagarTudo()
        defer {
            Indice.apagarTudo()
            Indice.url = indice
        }
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.persistirNoDisco = { _ in throw Recusa.disco }
        #expect(s.plantarObra("Tratado das Nuvens Invertidas", no: c.mainContext) == nil)
        let notas = (try? c.mainContext.fetch(FetchDescriptor<Nota>())) ?? []
        #expect(notas.isEmpty)
        #expect(Indice.quantas == 0)
    }
}
