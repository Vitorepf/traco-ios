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

struct PilhaFiltroTests {
    @Test func buscaAchaObstaculoEIgnoraLabel() {
        let woop = Nota(
            texto: "quero correr de manhã",
            gesto: .woop,
            campos: ["obstaculo": "o celular na cama", "resultado": ""]
        )
        let achados = PilhaFiltro.visiveis([woop], busca: "celular", filtro: nil)
        #expect(achados.count == 1)
        let falso = PilhaFiltro.visiveis([woop], busca: "Resultado", filtro: nil)
        #expect(falso.isEmpty)
    }

    @Test func trancadaNaoEntraNaBusca() {
        let secreta = Nota(texto: "o celular na cama", gesto: .expressiva, trancada: true)
        let aberta = Nota(texto: "quero o celular na cozinha", gesto: .woop)
        #expect(PilhaFiltro.visiveis([secreta, aberta], busca: "celular", filtro: nil).map(\.texto) == [aberta.texto])
        let soTrancadas = PilhaFiltro.visiveis([secreta, aberta], busca: "", filtro: .trancadas)
        #expect(soTrancadas.count == 1)
        #expect(soTrancadas.first?.trancada == true)
    }

    @Test func filtroWOOPSoWOOP() {
        let woop = Nota(texto: "quero", gesto: .woop)
        let spec = Nota(texto: "construir o app", gesto: .spec)
        let v = PilhaFiltro.visiveis([woop, spec], busca: "", filtro: .woop)
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
        #expect(PilhaFiltro.visiveis(notas, busca: "celular", filtro: nil).map(\.gesto) == [.woop])
        #expect(PilhaFiltro.visiveis(notas, busca: "", filtro: .woop).map(\.gesto) == [.woop])
        #expect(PilhaFiltro.visiveis(notas, busca: "", filtro: nil).count == 2)
    }
}

@MainActor
struct SessaoTests {
    @Test func expressivaTrancaEPorteiroNaoEscreve() throws {
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
        #expect(s.perguntaCodice == nil)
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
        guard case .naoSeRele = s.veu else {
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

    @Test func codiceNaoEntraNaNota() {
        let s = Sessao()
        s.texto = "rascunho"
        s.perguntaCodice = "Você escreveu “x”. O que fez diferente?"
        s.novaPagina()
        s.perguntaCodice = "Você escreveu “x”. O que fez diferente?"
        #expect(s.texto.isEmpty)
        #expect(s.perguntaCodice?.contains("escreveu") == true)
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

    @Test func vencidaNaPilhaTrancaSemAbrir() throws {
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
}
