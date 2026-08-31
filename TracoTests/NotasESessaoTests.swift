import SwiftData
import SwiftUI
import Testing
@testable import Traco

struct DestaqueBuscaTests {
    @Test func marcaOTermoSemComerOResto() {
        let t = DestaqueBusca.texto("o celular na cama", termo: "celular", base: .white)
        #expect(String(describing: t).contains("celular"))
    }
}

struct NotasFiltroTests {
    @Test func buscaAchaObstaculoEIgnoraLabel() {
        let woop = Nota(
            texto: "quero correr de manhã",
            gesto: .woop,
            campos: ["obstaculo": "o celular na cama", "resultado": ""]
        )
        let achados = NotasFiltro.visiveis([woop], busca: "celular", filtro: nil)
        #expect(achados.count == 1)
        let falso = NotasFiltro.visiveis([woop], busca: "Resultado", filtro: nil)
        #expect(falso.isEmpty)
    }

    @Test func trancadaNaoEntraNaBusca() {
        let secreta = Nota(texto: "o celular na cama", gesto: .expressiva, trancada: true)
        let aberta = Nota(texto: "quero o celular na cozinha", gesto: .woop)
        #expect(NotasFiltro.visiveis([secreta, aberta], busca: "celular", filtro: nil).map(\.texto) == [aberta.texto])
        let soTrancadas = NotasFiltro.visiveis([secreta, aberta], busca: "", filtro: .trancadas)
        #expect(soTrancadas.count == 1)
        #expect(soTrancadas.first?.trancada == true)
    }

    @Test func filtroWOOPSoWOOP() {
        let woop = Nota(texto: "quero", gesto: .woop)
        let spec = Nota(texto: "construir o app", gesto: .spec)
        let v = NotasFiltro.visiveis([woop, spec], busca: "", filtro: .woop)
        #expect(v.map(\.gesto) == [.woop])
    }

    @Test func limparBuscaRestauraTudo() {
        let woop = Nota(
            texto: "quero correr de manhã",
            gesto: .woop,
            campos: ["obstaculo": "o celular na cama"]
        )
        let spec = Nota(texto: "construir o app", gesto: .spec)
        let notas = [woop, spec]
        #expect(NotasFiltro.visiveis(notas, busca: "celular", filtro: nil).map(\.gesto) == [.woop])
        #expect(NotasFiltro.visiveis(notas, busca: "", filtro: .woop).map(\.gesto) == [.woop])
        #expect(NotasFiltro.visiveis(notas, busca: "", filtro: nil).count == 2)
    }
}

@MainActor
struct SessaoTests {
    @Test func expressivaTrancaEAnalisarNaoEscreve() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let s = Sessao()
        s.texto = "hoje senti medo e chorei. o peito pesado não saiu o dia inteiro."
        s.gesto = .expressiva
        s.trancarESair(no: context, destino: .pagina)
        let notas = try context.fetch(FetchDescriptor<Nota>())
        #expect(notas.count == 1)
        #expect(notas[0].trancada)
        #expect(notas[0].texto.contains("senti medo"))
        #expect(s.texto.isEmpty)
        #expect(s.perguntaPadroes == nil)
    }

    @Test func abrirTrancadaNaoMostraTexto() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let nota = Nota(texto: "segredo do desabafo", gesto: .expressiva, trancada: true)
        context.insert(nota)
        let s = Sessao()
        s.abrir(nota)
        #expect(s.texto.isEmpty)
        guard case .naoSeRele = s.confirmacao else {
            Issue.record("tinha de pedir a dupla confirmação")
            return
        }
        s.abrir(nota, mesmoTrancada: true)
        #expect(s.texto == "segredo do desabafo")
    }

    @Test func relogioDoTimerNaoDependeDeTicks() {
        let s = Sessao()
        let t0 = Date()
        s.iniciarTimer(agora: t0)
        s.alinharTimerAoRelogio(agora: t0.addingTimeInterval(60))
        #expect(s.segundosRestantes == 14 * 60)
        #expect(s.timerEsgotou == false)
        s.alinharTimerAoRelogio(agora: t0.addingTimeInterval(15 * 60 + 1))
        #expect(s.segundosRestantes == 0)
        #expect(s.timerEsgotou)
        s.pararTimer()
    }

    @Test func fimDoTimerTrancaComoSaida() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let s = Sessao()
        s.texto = "hoje senti medo e o peito ficou pesado o dia inteiro, chorei."
        s.gesto = .expressiva
        s.timerLigado = true
        s.segundosRestantes = 0
        s.timerEsgotou = true
        s.esgotarTimer(no: context)
        let notas = try context.fetch(FetchDescriptor<Nota>())
        #expect(notas.first?.trancada == true)
        #expect(s.timerLigado == false)
        #expect(s.texto.isEmpty)
    }

    @Test func padroesNaoEntraNaNota() {
        let s = Sessao()
        s.texto = "rascunho"
        s.perguntaPadroes = "Você escreveu “x”. O que fez diferente?"
        s.novaPagina()
        s.perguntaPadroes = "Você escreveu “x”. O que fez diferente?"
        #expect(s.texto.isEmpty)
        #expect(s.perguntaPadroes?.contains("escreveu") == true)
    }

    @Test func timerNasceComQuinzeMinutos() {
        let s = Sessao()
        s.iniciarTimer()
        #expect(s.segundosRestantes == 15 * 60)
        #expect(s.timerLigado)
        s.pararTimer()
    }

    @Test func quinzeMinutosDeRelogioTranca() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let s = Sessao()
        s.texto = "hoje senti medo e o peito ficou pesado o dia inteiro, chorei."
        s.gesto = .expressiva
        let inicio = Date(timeIntervalSince1970: 1_000_000)
        s.iniciarTimer(agora: inicio, duracao: 15 * 60)
        s.alinharTimerAoRelogio(agora: inicio.addingTimeInterval(14 * 60 + 59))
        #expect(s.timerEsgotou == false)
        #expect(s.segundosRestantes == 1)
        s.alinharTimerAoRelogio(agora: inicio.addingTimeInterval(15 * 60))
        #expect(s.timerEsgotou)
        s.esgotarTimer(no: context)
        let notas = try context.fetch(FetchDescriptor<Nota>())
        #expect(notas.first?.trancada == true)
        s.pararTimer()
    }

    @Test func prazoVencidoTrancaAoReabrir() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let nota = Nota(
            texto: "hoje senti medo e o peito ficou pesado o dia inteiro, chorei.",
            gesto: .expressiva,
            expressivaPrazo: Date().addingTimeInterval(-30)
        )
        context.insert(nota)
        let s = Sessao()
        s.abrir(nota)
        #expect(s.timerEsgotou)
        #expect(s.segundosRestantes == 0)
        s.esgotarTimer(no: context)
        #expect(nota.trancada)
    }

    @Test func vencidaNaNotasTrancaSemAbrir() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let nota = Nota(
            texto: "hoje senti medo e o peito ficou pesado o dia inteiro, chorei.",
            gesto: .expressiva,
            expressivaPrazo: Date().addingTimeInterval(-30)
        )
        context.insert(nota)
        let s = Sessao()
        s.trancarExpressivasVencidas(no: context)
        #expect(nota.trancada)
        #expect(nota.expressivaPrazo == nil)
    }

    @Test func prazoAbertoRetomaOResto() throws {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let nota = Nota(
            texto: "hoje senti medo e o peito ficou pesado o dia inteiro, chorei.",
            gesto: .expressiva,
            expressivaPrazo: Date().addingTimeInterval(180)
        )
        context.insert(nota)
        let s = Sessao()
        s.abrir(nota)
        #expect(s.timerLigado)
        #expect(s.segundosRestantes >= 179 && s.segundosRestantes <= 180)
        s.pararTimer()
    }

    // MARK: - Fecho da expressiva (P0: onde uma regressão apaga ou expõe a escrita)

    private func sessaoExpressiva(minutosEscritos: Int) throws -> (Sessao, ModelContext) {
        let container = try ModelContainer(
            for: Nota.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let s = Sessao()
        s.texto = "hoje senti medo e chorei, o peito pesado não saiu o dia inteiro."
        s.gesto = .expressiva
        let t0 = Date()
        s.iniciarTimer(agora: t0)
        s.alinharTimerAoRelogio(agora: t0.addingTimeInterval(TimeInterval(minutosEscritos * 60)))
        return (s, context)
    }

    @Test func concluirComDezMinutosTrancaDireto() throws {
        let (s, context) = try sessaoExpressiva(minutosEscritos: 11)
        s.concluir(no: context)
        let notas = try context.fetch(FetchDescriptor<Nota>())
        #expect(notas.first?.trancada == true)
        #expect(s.texto.isEmpty)
        #expect(s.timerLigado == false)
    }

    @Test func concluirAntesDosDezPassaPelaConfirmacao() throws {
        let (s, context) = try sessaoExpressiva(minutosEscritos: 5)
        s.concluir(no: context)
        #expect(s.confirmacao == .sairTranca(destino: .pagina))
        let notas = try context.fetch(FetchDescriptor<Nota>())
        #expect(notas.allSatisfy { !$0.trancada })
        #expect(!s.texto.isEmpty) // a escrita não foi apagada nem salva destrancada
        s.pararTimer()
    }

    @Test func sairPelasNotasDuranteTimerAbreConfirmacao() throws {
        let (s, context) = try sessaoExpressiva(minutosEscritos: 3)
        s.irNotas(no: context)
        #expect(s.confirmacao == .sairTranca(destino: .notas))
        #expect(s.mostrarNotas == false)
        let notas = try context.fetch(FetchDescriptor<Nota>())
        #expect(notas.allSatisfy { !$0.trancada && $0.expressivaPrazo != nil } || notas.isEmpty)
        s.pararTimer()
    }

    @Test func recordarDuranteTimerNaoCapturaTexto() throws {
        let (s, context) = try sessaoExpressiva(minutosEscritos: 3)
        s.irRecordar(no: context)
        #expect(s.confirmacao == .sairTranca(destino: .recordar))
        #expect(s.recordarTexto.isEmpty) // a expressiva não vaza pela rota do Recordar
        #expect(s.mostrarRecordar == false)
        s.trancarESair(no: context, destino: .recordar)
        #expect(s.recordarTexto.isEmpty)
        #expect(s.confirmacao == .trancada(destino: .pagina)) // trancada não se recorda
    }

    @Test func analiseCalaEmExpressivaNoMotor() {
        // §8.5 no motor, não só na UI: mesmo conteúdo que dispararia aviso, cala.
        let v = AnaliseLocal.classificar(
            texto: "eu sou um vencedor e preciso falar com alguém",
            gestoAtual: .expressiva,
            campos: [:]
        )
        #expect(v == .silencio)
    }

    @Test func padroesSemObstaculoNaoRepeteFragmento() {
        let perguntas = PadroesLocal.perguntas(vozes: [
            "quero parar de adiar o projeto do app",
            "percebi que executo bem o que escrevi ontem",
            "quero acordar cedo para treinar",
        ])
        for p in perguntas {
            let frags = p.split(separator: "“").dropFirst().map { $0.prefix(while: { $0 != "”" }) }
            #expect(Set(frags).count == frags.count, "pergunta repete fragmento: \(p)")
        }
    }
}

@MainActor
struct CicloDeVidaTests {
    @Test func migracaoVersionadaInicializa() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let context = ModelContext(container)
        context.insert(Nota(texto: "nota sob schema V1"))
        try context.save()
        #expect(try context.fetch(FetchDescriptor<Nota>()).count == 1)
    }

    @Test func anexoOrfaoEDetectadoComCarencia() {
        let id = UUID().uuidString.lowercased()
        let refs = AnexoDisco.idsReferenciados(em: ["texto com ![f](traco://img/\(id)) no meio"])
        #expect(refs == [id])

        let dir = FileManager.default.temporaryDirectory
        let referenciado = dir.appendingPathComponent("\(id).png")
        let orfaoVelho = dir.appendingPathComponent("\(UUID().uuidString.lowercased()).png")
        let orfaoNovo = dir.appendingPathComponent("\(UUID().uuidString.lowercased()).png")
        for u in [referenciado, orfaoVelho, orfaoNovo] {
            try? Data("x".utf8).write(to: u)
        }
        // orfaoVelho "envelhece" simulando o relógio: agora = amanhã
        let amanha = Date().addingTimeInterval(25 * 3600)
        let mortos = AnexoDisco.orfaos(referenciados: refs, arquivos: [referenciado, orfaoVelho, orfaoNovo], agora: amanha)
        #expect(mortos.map(\.lastPathComponent).contains(orfaoVelho.lastPathComponent))
        #expect(!mortos.map(\.lastPathComponent).contains(referenciado.lastPathComponent))
        // com o relógio de agora, o órfão recém-criado tem carência de 24h
        let vivos = AnexoDisco.orfaos(referenciados: refs, arquivos: [orfaoNovo], agora: .now)
        #expect(vivos.isEmpty)
        for u in [referenciado, orfaoVelho, orfaoNovo] { try? FileManager.default.removeItem(at: u) }
    }

    @Test func trancadaSeguraSeusAnexos() {
        // O texto da trancada continua referenciando: o anexo dela NÃO é órfão.
        let id = UUID().uuidString.lowercased()
        let refs = AnexoDisco.idsReferenciados(em: ["desabafo com [audio:a](traco://audio/\(id))"])
        #expect(refs.contains(id))
    }
}

@MainActor
struct AutoAnaliseTests {
    @Test func pausaVesteWOOPSemBotao() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "quero correr de manhã"
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(80))
        // §17.3 superou a fatia 1: no automático a forma já vem vestida
        #expect(s.cartao == .vestida(.woop, pergunta: AnaliseLocal.perguntaWOOP))
        #expect(s.gesto == .woop)
    }

    @Test func silencioAutomaticoEInvisivel() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "leite"
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(80))
        #expect(s.cartao == nil)
        #expect(s.toast == nil) // §17: no automático, silêncio não faz barulho
    }

    @Test func digitarCancelaOAgendamento() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "quero correr de manhã"
        s.agendarAutoAnalise(depois: 10)
        s.texto = "quero correr de manhã cedo"
        s.agendarAutoAnalise(depois: 10) // reagenda: o antigo cancela
        try await Task.sleep(for: .milliseconds(50))
        #expect(s.cartao == nil) // nada dispara antes da pausa real
    }

    @Test func naoRodaDuranteTimerNemComFormaOuOptOut() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "quero correr de manhã"
        s.gesto = .expressiva
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(60))
        #expect(s.cartao == nil)
        s.gesto = nil
        s.autoAnalise = false
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(60))
        #expect(s.cartao == nil)
        s.autoAnalise = true // restaura o default global (UserDefaults é real nos testes)
    }
}

@MainActor
struct RevisoesTests {
    @Test func trancadaEExpressivaNuncaAgendam() {
        #expect(!Revisoes.podeAgendar(gesto: .expressiva, trancada: false, texto: "desabafo"))
        #expect(!Revisoes.podeAgendar(gesto: .woop, trancada: true, texto: "segredo"))
        #expect(!Revisoes.podeAgendar(gesto: nil, trancada: false, texto: "   "))
        #expect(Revisoes.podeAgendar(gesto: .woop, trancada: false, texto: "quero correr"))
        #expect(Revisoes.podeAgendar(gesto: nil, trancada: false, texto: "nota nua"))
    }

    @Test func revisaoCaiTresDiasDepois() {
        let criada = Date(timeIntervalSince1970: 1_700_000_000)
        let quando = Revisoes.proximaRevisao(aPartirDe: criada)
        let dias = Calendar.current.dateComponents([.day], from: criada, to: quando).day
        #expect(dias == 3)
    }
}

@MainActor
struct CorpusTests {
    @Test func trancadaNuncaSaiNoExport() {
        let corpo = Corpus.corpoDoCorpus(notas: [
            ("segredo do desabafo", .expressiva, [:], true, Date(timeIntervalSince1970: 1)),
            ("quero correr de manhã", .woop, ["obstaculo": "celular na cama"], false, Date(timeIntervalSince1970: 2)),
        ])
        #expect(!corpo.contains("segredo"))
        #expect(corpo.contains("quero correr de manhã"))
        #expect(corpo.contains("celular na cama")) // respostas dos campos entram
        #expect(corpo.contains("---")) // frontmatter legível
    }

    @Test func arquivoMdEhLegivelEVersionavel() {
        let md = Corpus.arquivoMd(texto: "uma ideia", gesto: nil, campos: [:], criadaEm: Date(timeIntervalSince1970: 0))
        #expect(md.hasPrefix("---\ncriada: 1970"))
        #expect(md.contains("uma ideia"))
    }
}

@MainActor
struct ApagarTests {
    @Test func apagarRemoveNotaELimpaSessao() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let context = ModelContext(container)
        let nota = Nota(texto: "para apagar")
        context.insert(nota)
        try context.save()
        let s = Sessao()
        s.abrir(nota)
        s.apagar(uuid: nota.uuid, no: context)
        #expect(try context.fetch(FetchDescriptor<Nota>()).isEmpty)
        #expect(s.texto.isEmpty) // a página não segura fantasma
        #expect(s.confirmacao == nil)
    }

    @Test func apagarOutraNotaNaoMexeNaPagina() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let context = ModelContext(container)
        let alvo = Nota(texto: "para apagar")
        context.insert(alvo)
        try context.save()
        let s = Sessao()
        s.texto = "escrita viva na página"
        s.apagar(uuid: alvo.uuid, no: context)
        #expect(s.texto == "escrita viva na página")
        #expect(try context.fetch(FetchDescriptor<Nota>()).isEmpty)
    }
}

@MainActor
struct AnaliseRemotaTests {
    @Test func parseVereditoEstrito() {
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"woop","aviso":null,"pergunta":"Qual o obstáculo?"}"#)
                == .gesto(.woop, pergunta: "Qual o obstáculo?"))
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":null,"aviso":"Um gesto por sessão. O segundo método vai para outra página.","pergunta":null}"#)
                == .aviso("Um gesto por sessão. O segundo método vai para outra página."))
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"expressiva","aviso":null,"pergunta":null}"#) == .expressiva)
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":null,"aviso":null,"pergunta":null}"#) == .silencio)
        #expect(AnaliseRemota.parseVeredito("claro! aqui está: nada de json") == nil) // fora do formato → silêncio/local
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"golpe","aviso":null,"pergunta":null}"#) == .silencio)
    }

    @Test func chaveVaiEVoltaDoKeychain() {
        Chave.apagar()
        #expect(!Chave.existe)
        Chave.salvar("xai-teste-123")
        #expect(Chave.ler() == "xai-teste-123")
        Chave.apagar()
        #expect(Chave.ler() == nil)
    }

    @Test func semChaveRemotaCalaSemRede() async {
        Chave.apagar()
        let v = await AnaliseRemota.classificar(texto: "quero correr", gestoAtual: nil)
        #expect(v == nil) // sem chave: zero rede, cai no local
    }
}

@MainActor
struct AutoVestirTests {
    @Test func pausaVesteDireto() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "quero correr de manhã"
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(120))
        #expect(s.gesto == .woop) // vestida sozinha (§17.3)
        #expect(s.campos.keys.sorted() == ["obstaculo", "plano", "resultado"])
        #expect(s.texto == "quero correr de manhã") // as palavras do autor intactas
        if case .vestida(.woop, _) = s.cartao {} else { Issue.record("cartão devia ser .vestida") }
    }

    @Test func soltarDesfazESuprimeNaNota() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "quero correr de manhã"
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(120))
        s.soltarForma()
        #expect(s.gesto == nil)
        #expect(s.campos.isEmpty)
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(120))
        #expect(s.gesto == nil) // §17.2: opt-out por nota — não re-veste
        s.novaPagina()
        #expect(s.autoSuprimidaNaNota == false) // página nova zera a supressão
    }

    @Test func expressivaNuncaComecaSozinha() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "hoje foi pesado, briguei com meu sócio e senti que tudo pode desmoronar, dói pensar nisso e o medo não sai da cabeça de jeito nenhum"
        s.agendarAutoAnalise(depois: 0)
        try await Task.sleep(for: .milliseconds(120))
        #expect(s.timerLigado == false) // timer é compromisso: só com toque
        #expect(s.cartao == .expressiva) // a oferta aparece; a decisão é do autor
    }
}

@MainActor
struct ImportarTests {
    @Test func importaOProprioExport() {
        let corpo = Corpus.corpoDoCorpus(notas: [
            ("quero correr de manhã", .woop, ["obstaculo": "celular"], false, Date(timeIntervalSince1970: 1000)),
            ("percebi que executo o que escrevi", nil, [:], false, Date(timeIntervalSince1970: 2000)),
        ])
        let itens = Corpus.importar(corpo)
        #expect(itens.count == 2)
        #expect(itens[0].texto.contains("quero correr"))
        #expect(itens[0].gestoNome == "WOOP")
        #expect(abs(itens[0].criadaEm.timeIntervalSince1970 - 1000) < 1)
        #expect(itens[1].gestoNome == nil)
    }

    @Test func mdSoltoViraUmaNota() {
        let itens = Corpus.importar("# uma ideia\nsem frontmatter nenhum")
        #expect(itens.count == 1)
        #expect(itens[0].texto.contains("uma ideia"))
    }

    @Test func vazioNaoImportaNada() {
        #expect(Corpus.importar("   \n  ").isEmpty)
    }
}

struct RevisaoRotaTests {
    @Test func uuidSaiDoUserInfo() {
        let u = UUID()
        #expect(Revisoes.uuidDaResposta(["uuid": u.uuidString]) == u)
        #expect(Revisoes.uuidDaResposta(["uuid": "lixo"]) == nil)
        #expect(Revisoes.uuidDaResposta([:]) == nil)
    }
}
