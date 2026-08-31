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
        // §19.4: a IA devolve RÓTULO; a pergunta e a frase são do app
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"woop","aviso":null}"#)
                == .gesto(.woop, pergunta: AnaliseLocal.pergunta(.woop)))
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":null,"aviso":"doisGestos"}"#)
                == .aviso(AnaliseLocal.avisoDoisGestos))
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"expressiva","aviso":null}"#) == .expressiva)
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":null,"aviso":null}"#) == .silencio)
        #expect(AnaliseRemota.parseVeredito("claro! aqui está: nada de json") == nil) // fora do formato → silêncio/local
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"golpe","aviso":null}"#) == .silencio)
    }

    @Test func contaDesligadaNaoDeixaRastroNoCofre() async {
        ContaGrok.sair()
        #expect(!ContaGrok.ligada)
        #expect(await ContaGrok.token() == nil) // sem sessão: nada a renovar
    }

    @Test func semContaRemotaCalaSemRede() async {
        ContaGrok.sair()
        let v = await AnaliseRemota.classificar(texto: "quero correr", gestoAtual: nil)
        #expect(v == nil) // sem conta: zero rede, cai no local
    }

    /// A lei do dono (ADR 31j/31k): não existe chave de API neste app.
    @Test func loginEPelaAssinaturaNaoPorToken() {
        #expect(ContaGrok.escopos.contains("api:access"))
        #expect(ContaGrok.escopos.contains("offline_access")) // renova sozinho
        let corpo = String(data: ContaGrok.corpo(["a": "x y", "b": "z"]), encoding: .utf8) ?? ""
        #expect(corpo.contains("a=x%20y"))
        #expect(corpo.contains("b=z"))
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

@MainActor
struct CorrecoesVarredura3Tests {
    @Test func gestoVoltaDoNomeEDoRaw() {
        #expect(Gesto.doNome("WOOP") == .woop)
        #expect(Gesto.doNome("woop") == .woop)
        #expect(Gesto.doNome("Nota permanente") == .notaPermanente)
        #expect(Gesto.doNome("Se–então") == .seEntao)
        #expect(Gesto.doNome("inexistente") == nil)
    }

    @Test func roundtripPreservaOGesto() {
        let corpo = Corpus.corpoDoCorpus(notas: [("quero correr", .woop, [:], false, Date(timeIntervalSince1970: 9))])
        let item = Corpus.importar(corpo).first
        #expect(item?.gestoNome.flatMap(Gesto.doNome) == .woop)
    }

    /// A prova da doutrina: NENHUMA palavra do modelo chega à tela.
    @Test func modeloNaoConsegueEscreverNaTela() {
        let gigante = String(repeating: "bla ", count: 200)
        // texto livre no lugar do rótulo = rótulo desconhecido = silêncio
        #expect(AnaliseRemota.parseVeredito("{\"gesto\":null,\"aviso\":\"\(gigante)\"}") == .silencio)
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":null,"aviso":"você é incrível!"}"#) == .silencio)
        // rótulo válido só pode virar UMA das nossas frases
        for (rotulo, frase) in AnaliseLocal.avisos {
            #expect(AnaliseRemota.parseVeredito("{\"gesto\":null,\"aviso\":\"\(rotulo)\"}") == .aviso(frase))
        }
        // pergunta inventada pelo modelo é ignorada: a do template vence
        #expect(AnaliseRemota.parseVeredito(#"{"gesto":"spec","aviso":null,"pergunta":"eu inventei isto"}"#)
                == .gesto(.spec, pergunta: AnaliseLocal.pergunta(.spec)))
    }

    /// Texto livre em Padrões só passa se o algoritmo VERIFICAR a citação.
    @Test func perguntaSoPassaSeCitarOAutorDeVerdade() {
        let vozes = ["quero acordar cedo mas o celular fica na cama"]
        let bom = #"{"perguntas":["O que muda se o “celular fica na cama” sair do quarto?"]}"#
        #expect(PadroesRemoto.parsePerguntas(bom, vozes: vozes)?.count == 1)
        // citação que o autor nunca escreveu → descartada
        let inventado = #"{"perguntas":["E quando você disse “eu sempre desisto”, o que sentiu?"]}"#
        #expect(PadroesRemoto.parsePerguntas(inventado, vozes: vozes)?.isEmpty == true)
        // conclusão disfarçada (sem "?") → descartada
        let conclusao = #"{"perguntas":["Você claramente evita o “celular fica na cama”."]}"#
        #expect(PadroesRemoto.parsePerguntas(conclusao, vozes: vozes)?.isEmpty == true)
        // sem citação nenhuma → descartada
        let solta = #"{"perguntas":["O que você faria diferente amanhã?"]}"#
        #expect(PadroesRemoto.parsePerguntas(solta, vozes: vozes)?.isEmpty == true)
    }

    @Test func textoMudadoEmVooNaoVeste() async throws {
        let s = Sessao()
        s.autoAnalise = true
        s.texto = "quero correr de manhã"
        s.agendarAutoAnalise(depois: 0.05)
        s.texto = "outra coisa completamente banal" // muda antes do veredito
        try await Task.sleep(for: .milliseconds(200))
        #expect(s.gesto == nil) // o veredito velho não vestiu o texto novo
    }
}

@MainActor
struct RoundtripCamposTests {
    @Test func camposVoltamComoCamposNaoComoVoz() {
        let corpo = Corpus.corpoDoCorpus(notas: [
            ("quero correr de manhã", .woop, ["obstaculo": "o celular na cama", "resultado": "energia"], false, Date(timeIntervalSince1970: 5)),
        ])
        let item = Corpus.importar(corpo)[0]
        let gesto = item.gestoNome.flatMap(Gesto.doNome)
        let (texto, campos) = Corpus.separarCampos(texto: item.texto, gesto: gesto)
        #expect(texto == "quero correr de manhã") // sem labels na voz
        #expect(campos["obstaculo"] == "o celular na cama")
        #expect(campos["resultado"] == "energia")
        #expect(!texto.contains("Obstáculo interno")) // mobiliário não indexa
    }

    @Test func semBlocoDeFormaNadaMuda() {
        let (texto, campos) = Corpus.separarCampos(texto: "nota simples", gesto: .woop)
        #expect(texto == "nota simples")
        #expect(campos.isEmpty)
    }
}

@MainActor
struct EscadaTests {
    @Test func escadaSobeETemTeto() {
        let u = UUID()
        UserDefaults.standard.removeObject(forKey: "revisaoNivel")
        #expect(Revisoes.dias(nivel: Revisoes.nivel(u)) == 3)
        Revisoes.registrarCumprida(u)
        #expect(Revisoes.dias(nivel: Revisoes.nivel(u)) == 7)
        Revisoes.registrarCumprida(u)
        #expect(Revisoes.dias(nivel: Revisoes.nivel(u)) == 21)
        Revisoes.registrarCumprida(u) // teto: fica em 21
        #expect(Revisoes.dias(nivel: Revisoes.nivel(u)) == 21)
        UserDefaults.standard.removeObject(forKey: "revisaoNivel")
    }
}

@MainActor
struct ConfiancaDia200Tests {
    @Test func soltarPreservaAsRespostas() {
        let s = Sessao()
        s.texto = "quero correr de manhã"
        s.usarForma(.woop)
        s.campos["obstaculo"] = "o celular na cama"
        s.campos["plano"] = "deixo na cozinha"
        s.soltarForma()
        #expect(s.gesto == nil)
        #expect(s.texto.contains("quero correr de manhã"))
        #expect(s.texto.contains("o celular na cama")) // a voz voltou ao texto
        #expect(s.texto.contains("deixo na cozinha"))
        #expect(!s.texto.contains("Obstáculo interno")) // sem mobiliário
    }

    @Test func soltarSemRespostasNaoSujaOTexto() {
        let s = Sessao()
        s.texto = "quero correr"
        s.usarForma(.woop)
        s.soltarForma()
        #expect(s.texto == "quero correr")
    }

    @Test func apagarTemJanelaDeDesfazer() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let context = ModelContext(container)
        let nota = Nota(texto: "não era para apagar", gesto: .woop, campos: ["obstaculo": "x"])
        context.insert(nota)
        try context.save()
        let s = Sessao()
        s.apagar(uuid: nota.uuid, no: context)
        #expect(try context.fetch(FetchDescriptor<Nota>()).isEmpty)
        #expect(s.apagadaRecuperavel != nil)
        s.desfazerApagar(no: context)
        let voltou = try context.fetch(FetchDescriptor<Nota>())
        #expect(voltou.count == 1)
        #expect(voltou[0].texto == "não era para apagar")
        #expect(voltou[0].campos["obstaculo"] == "x")
        #expect(s.apagadaRecuperavel == nil)
    }
}

@MainActor
struct PadroesRemotoTests {
    @Test func parseEstritoDasPerguntas() {
        let ok = PadroesRemoto.parsePerguntas(#"{"perguntas":["Você escreveu “x” — por quê?","Segunda?"]}"#)
        #expect(ok?.count == 2)
        #expect(PadroesRemoto.parsePerguntas("sem json") == nil)
        #expect(PadroesRemoto.parsePerguntas(#"{"perguntas":[]}"#) == [])
    }

    @Test func nuncaRepeteDuasVisitasSeguidas() {
        UserDefaults.standard.removeObject(forKey: "padroesVistas")
        let p1 = ["Você escreveu “adiar” de novo — o que mudou?", "E a promessa sem data?"]
        #expect(PadroesRemoto.ineditas(p1) == p1)
        PadroesRemoto.registrarVistas(p1)
        let p2 = ["Você escreveu “adiar” de novo — o que mudou?", "Uma pergunta nova?"]
        #expect(PadroesRemoto.ineditas(p2) == ["Uma pergunta nova?"])
        // tudo visto → repete em vez de calar para sempre
        #expect(PadroesRemoto.ineditas(p1) == p1)
        UserDefaults.standard.removeObject(forKey: "padroesVistas")
    }
}

/// SPEC §8: os DOIS fechos da expressiva são métodos distintos, com garantias
/// distintas. Se a promessa "queimou" não for verdade em TODAS as rotas, é mentira.
@MainActor
struct FechoExpressivaTests {
    private func container() throws -> ModelContainer {
        try ModelContainer.traco(emMemoria: true)
    }

    @Test func queimarDestroiOTextoEGuardaOSentido() throws {
        let c = try container()
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "a coisa que eu não queria ter escrito"
        s.salvar(no: c.mainContext)
        s.queimar(no: c.mainContext, sentido: "o medo era de decepcionar, não de falhar")

        let notas = try c.mainContext.fetch(FetchDescriptor<Nota>())
        #expect(notas.count == 1)
        let nota = try #require(notas.first)
        #expect(nota.queimada)
        #expect(nota.texto.isEmpty)                    // o texto foi destruído
        #expect(nota.campos.isEmpty)
        #expect(nota.sentido == "o medo era de decepcionar, não de falhar")
        #expect(nota.queimadaEm != nil)
        #expect(nota.fechada)                          // vale como fechada em toda rota
        #expect(!nota.trancada)                        // queimar ≠ selar
    }

    @Test func queimadaNuncaSaiNoExportNemNoBackup() throws {
        let c = try container()
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "isto não pode sair daqui"
        s.salvar(no: c.mainContext)
        s.queimar(no: c.mainContext, sentido: "aprendi X")

        let notas = try c.mainContext.fetch(FetchDescriptor<Nota>())
        let corpo = Corpus.corpoDoCorpus(
            notas: notas.map { ($0.texto, $0.gesto, $0.campos, $0.fechada, $0.criadaEm) }
        )
        #expect(!corpo.contains("isto não pode sair daqui"))
    }

    @Test func queimarNaoDeixaJanelaDeDesfazer() throws {
        let c = try container()
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "sem volta"
        s.salvar(no: c.mainContext)
        s.queimar(no: c.mainContext, sentido: "")
        // desfazer traria o texto de volta — queimar não tem volta, é o método
        #expect(s.apagadaRecuperavel == nil)
    }

    @Test func queimadaNaoAbre() throws {
        let c = try container()
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "conteúdo"
        s.salvar(no: c.mainContext)
        s.queimar(no: c.mainContext, sentido: "")
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        s.abrir(nota)
        #expect(s.texto.isEmpty)     // nada foi carregado para a página
        #expect(s.toast != nil)      // e o app diz por quê, em vez de calar
    }

    @Test func selarGuardaOTextoEOSentido() throws {
        let c = try container()
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "o que eu escrevi fica comigo"
        s.sentidoPendente = "o que ficou claro"
        s.trancarESair(no: c.mainContext, destino: .pagina)

        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.trancada)
        #expect(!nota.queimada)
        #expect(nota.texto == "o que eu escrevi fica comigo") // selar preserva
        #expect(nota.sentido == "o que ficou claro")
        #expect(nota.fechada)
    }

    @Test func oFechoEEscolhaDoAutorNaoDoRelogio() {
        let s = Sessao()
        s.gesto = .expressiva
        s.texto = "escrevi"
        s.timerLigado = true
        s.timerEsgotou = true
        s.segundosRestantes = 0
        let c = try? ModelContainer.traco(emMemoria: true)
        s.esgotarTimer(no: c!.mainContext)
        #expect(s.fechoExpressiva != nil) // o tempo abre a ESCOLHA, não tranca
    }
}
