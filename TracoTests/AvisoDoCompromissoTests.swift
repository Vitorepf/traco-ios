import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-04a — o aviso do compromisso, que existia no motor e não na
/// tela. Aqui se prova o que a ficha promete: a antecedência, a hora real, o
/// dia da semana quando o alarme recua para a véspera, e o disco que não perde
/// o "não avisa" do autor.
@Suite("Aviso do compromisso")
struct AvisoDoCompromissoTests {
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!) }

    private func evento(_ h: Int, _ m: Int = 0, dia: Int = 5, diaInteiro: Bool = false,
                        aviso: Int? = 0, repeteEm: [Int] = []) -> EventoCalendario {
        let c = cal
        let inicio = c.date(from: DateComponents(year: 2026, month: 9, day: dia, hour: h, minute: m))!
        return EventoCalendario(titulo: "Dentista", inicio: inicio,
                                fim: inicio.addingTimeInterval(3600),
                                diaInteiro: diaInteiro, repeteEm: repeteEm,
                                avisoMinutos: aviso)
    }

    @Test("a lista é fechada e tem nome em português")
    func nomes() {
        #expect(Aviso.nome(nil) == "Não avisa")
        #expect(Aviso.nome(0) == "Na hora")
        #expect(Aviso.nome(30) == "30 min antes")
        #expect(Aviso.nome(60) == "1 h antes")
        #expect(Aviso.nome(1440) == "1 dia antes")
        #expect(Aviso.nome(0, diaInteiro: true) == "Na manhã do dia")
        #expect(Aviso.nome(1440, diaInteiro: true) == "Um dia antes, de manhã")
        #expect(Aviso.opcoes[0] == Int?.none)       // "não avisa" é escolha, e é a primeira
        #expect(Aviso.opcoesDiaInteiro.count == 3)  // dia inteiro não tem "30 min antes"
    }

    @Test("a antecedência recua a hora real do alarme")
    func instante() {
        let e = evento(14, 30, aviso: 30)
        let quando = Aviso.instante(de: e, cal, manha: 8)
        #expect(quando == e.inicio.addingTimeInterval(-30 * 60))
        #expect(Aviso.instante(de: evento(14, aviso: nil), cal, manha: 8) == nil)
    }

    @Test("dia inteiro cobra na âncora da manhã, nunca à meia-noite")
    func diaInteiro() {
        let e = evento(0, diaInteiro: true, aviso: 0)
        let quando = Aviso.instante(de: e, cal, manha: 8)
        #expect(cal.component(.hour, from: quando!) == 8)
        #expect(cal.isDate(quando!, inSameDayAs: e.inicio))

        let vespera = Aviso.instante(de: evento(0, diaInteiro: true, aviso: 1440), cal, manha: 8)!
        #expect(cal.component(.hour, from: vespera) == 8)
        let ontem = cal.date(byAdding: .day, value: -1, to: e.inicio)!
        #expect(cal.isDate(vespera, inSameDayAs: ontem))
    }

    @Test("aviso que cai na véspera anda com o dia da semana")
    func recuo() {
        // segunda 00h30 com 1 h de antecedência toca no DOMINGO 23h30
        let e = evento(0, 30, dia: 7, aviso: 60) // 7/set/2026 é uma segunda
        let quando = Aviso.instante(de: e, cal, manha: 8)!
        #expect(Aviso.diasDeRecuo(inicio: e.inicio, aviso: quando, cal) == 1)
        #expect(Aviso.diasDeRecuo(inicio: e.inicio, aviso: e.inicio, cal) == 0)
    }

    @Test("a promessa é dita em unidade do mundo do autor")
    func promessa() {
        let e = evento(14, 30, aviso: 30)
        let noDia = cal.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 9))!
        #expect(Aviso.promessa(de: e, cal, manha: 8, agora: noDia) == "hoje às 14:00")
        let vespera = cal.date(from: DateComponents(year: 2026, month: 9, day: 4, hour: 9))!
        #expect(Aviso.promessa(de: e, cal, manha: 8, agora: vespera) == "amanhã às 14:00")
        #expect(Aviso.promessa(de: evento(14, aviso: nil), cal, manha: 8) == nil)
    }

    @Test("série diz os dias em que o alarme realmente toca")
    func promessaDaSerie() {
        // toda segunda (2) às 00h30, avisando 1 h antes → toca todo domingo
        let e = evento(0, 30, dia: 7, aviso: 60, repeteEm: [2])
        let dita = Aviso.promessa(de: e, cal, manha: 8)
        #expect(dita?.contains("23:30") == true)
        #expect(dita?.contains(Calendario.diasEmLetras([1], cal)) == true) // domingo
    }

    @Test("o disco guarda o silêncio que o autor pediu")
    func discoPreservaOSilencio() throws {
        let mudo = evento(14, aviso: nil)
        let volta = try JSONDecoder().decode(EventoCalendario.self, from: JSONEncoder().encode(mudo))
        #expect(volta.avisoMinutos == nil)

        let comAviso = evento(14, aviso: 15)
        let volta2 = try JSONDecoder().decode(EventoCalendario.self, from: JSONEncoder().encode(comAviso))
        #expect(volta2.avisoMinutos == 15)
    }

    @Test("arquivo gravado antes da ADR 04a continua avisando na hora")
    func discoVelho() throws {
        let antigo = """
        {"id":"\(UUID().uuidString)","titulo":"Dentista",
         "inicio":800000000,"fim":800003600,"notas":"","diaInteiro":false}
        """
        let e = try JSONDecoder().decode(EventoCalendario.self, from: Data(antigo.utf8))
        #expect(e.avisoMinutos == 0) // o comportamento da ADR 03d fica de pé
    }
}

/// ADR 2026-09-04a — o próximo compromisso publicado fora do app.
@Suite("Próximo compromisso")
struct ProximoCompromissoTests {
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!) }

    @Test("o que já acabou não é o próximo")
    func expira() {
        let agora = Date()
        ProximoCompromisso.gravar(.init(titulo: "Dentista",
                                        inicio: agora.addingTimeInterval(-7200),
                                        fim: agora.addingTimeInterval(-3600),
                                        diaInteiro: false, aviso: nil))
        #expect(ProximoCompromisso.lido(agora: agora) == nil)
        #expect(ProximoCompromisso.naTelaBloqueada(agora: agora) == "Traço")

        ProximoCompromisso.gravar(.init(titulo: "Dentista",
                                        inicio: agora.addingTimeInterval(3600),
                                        fim: agora.addingTimeInterval(7200),
                                        diaInteiro: false, aviso: agora))
        #expect(ProximoCompromisso.lido(agora: agora)?.titulo == "Dentista")
        ProximoCompromisso.gravar(nil)
        #expect(ProximoCompromisso.lido(agora: agora) == nil)
    }

    @Test("deixa de nota não vai à tela bloqueada; o compromisso vai")
    func selo() {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 9))!
        let daNota = EventoCalendario(titulo: "correr", inicio: agora.addingTimeInterval(1800),
                                      fim: agora.addingTimeInterval(3600), origem: UUID())
        let meu = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(7200),
                                   fim: agora.addingTimeInterval(10800))
        ProximoCompromisso.publicar([daNota, meu], cal: cal, manha: 8, agora: agora)
        let lido = ProximoCompromisso.lido(agora: agora)
        #expect(lido?.titulo == "Dentista") // a deixa é mais cedo e mesmo assim não entra
        ProximoCompromisso.gravar(nil)
    }
}

/// ADR 2026-09-04c — o degrau do aparelho não pode engolir o aviso do §5.
@Suite("A escada não engole o aviso")
struct EscadaDaAnaliseTests {
    @Test("silêncio do modelo devolve a palavra ao algoritmo")
    func silencioNaoEVeredito() {
        let aviso = AnaliseLocal.Veredito.aviso(AnaliseLocal.avisoWood)
        // era isto que quebrava: o modelo do aparelho não tem como emitir
        // aviso, devolvia `.silencio` e a regex nunca rodava
        #expect(Sessao.escolher(remoto: .silencio, local: aviso) == aviso)
        #expect(Sessao.escolher(remoto: nil, local: aviso) == aviso)
    }

    @Test("forma do modelo manda, porque rotear é o papel dele")
    func formaDoModeloManda() {
        let doModelo = AnaliseLocal.Veredito.gesto(.spec, pergunta: AnaliseLocal.pergunta(.spec))
        #expect(Sessao.escolher(remoto: doModelo, local: .silencio) == doModelo)
        #expect(Sessao.escolher(remoto: .expressiva, local: .silencio) == .expressiva)
    }

    @Test("silêncio dos dois continua silêncio")
    func silencioDeVerdade() {
        #expect(Sessao.escolher(remoto: .silencio, local: .silencio) == .silencio)
    }
}

/// Varredura 04/set — o espelho só escreve o que mudou.
@Suite("O espelho não reescreve o igual")
struct EspelhoIncrementalTests {
    @Test("igual não escreve; diferente escreve")
    func soOQueMudou() throws {
        let alvo = FileManager.default.temporaryDirectory
            .appendingPathComponent("espelho-\(UUID().uuidString).md")
        defer { try? FileManager.default.removeItem(at: alvo) }

        #expect(Corpus.escreverSeMudou(Data("um".utf8), em: alvo))   // não existia
        #expect(!Corpus.escreverSeMudou(Data("um".utf8), em: alvo))  // idêntico: não toca
        #expect(Corpus.escreverSeMudou(Data("dois".utf8), em: alvo)) // mudou: grava
        #expect(try String(contentsOf: alvo, encoding: .utf8) == "dois")
        #expect(!Corpus.escreverSeMudou(nil, em: alvo))              // nada a gravar
    }

    @Test("o selo continua reescrevendo, porque o conteúdo muda")
    func oSeloAindaSobrescreve() throws {
        let raiz = FileManager.default.temporaryDirectory
            .appendingPathComponent("corpus-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: raiz) }
        let id = UUID()
        func fatia(trancada: Bool) -> FatiaCorpus {
            FatiaCorpus(id: id, texto: "o desabafo inteiro", gesto: .expressiva, campos: [:],
                        criadaEm: .now, editadaEm: .now, recordada: 0, sentido: "ficou claro",
                        minutos: 15, trancada: trancada, queimada: false,
                        expressivaEmCurso: false, dominio: nil, serie: nil, dia: 0)
        }
        Corpus.escrever(fatias: [fatia(trancada: false)], em: raiz)
        let md = raiz.appendingPathComponent("notas/\(id.uuidString.lowercased()).md")
        #expect(try String(contentsOf: md, encoding: .utf8).contains("o desabafo inteiro"))
        // selou: o corpo tem de SUMIR do disco, mesmo com a gravação incremental
        Corpus.escrever(fatias: [fatia(trancada: true)], em: raiz)
        let depois = try String(contentsOf: md, encoding: .utf8)
        #expect(!depois.contains("o desabafo inteiro"))
        #expect(depois.contains("estado: selada"))
        #expect(depois.contains("sentido: ficou claro"))
    }
}

/// ADR 2026-09-04e — o modo férias. O Traço cala o que ELE inventou de cobrar;
/// o que o autor marcou continua tocando.
@Suite("Modo férias", .serialized)
struct FeriasTests {
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!) }
    private func dia(_ d: Int, _ m: Int = 9, _ a: Int = 2026) -> Date {
        cal.date(from: DateComponents(year: a, month: m, day: d, hour: 9))!
    }
    private func limpar() {
        Ferias.ligado = false
        Ferias.ate = nil
        Ferias.incluiFeriados = false
    }

    @Test("desligado, todo dia cobra")
    func desligado() {
        limpar()
        #expect(!Ferias.vigente(agora: dia(5)))
        #expect(!Ferias.cala(dia(5), cal: cal, agora: dia(5)))
        #expect(Ferias.diasQueCobram(de: dia(5), dias: 7, cal: cal, agora: dia(5)).count == 7)
        #expect(!Ferias.haSilencio(de: dia(5), dias: 7, cal: cal, agora: dia(5)))
    }

    @Test("com data, cala até o último dia — e o dia seguinte cobra")
    func comData() {
        limpar()
        Ferias.ligado = true
        Ferias.ate = dia(8)
        #expect(Ferias.vigente(agora: dia(5)))
        #expect(Ferias.cala(dia(5), cal: cal, agora: dia(5)))
        #expect(Ferias.cala(dia(8), cal: cal, agora: dia(5)))   // o último dia é inclusive
        #expect(!Ferias.cala(dia(9), cal: cal, agora: dia(5)))  // e a volta cobra
        let cobram = Ferias.diasQueCobram(de: dia(5), dias: 7, cal: cal, agora: dia(5))
        #expect(cobram.count == 3)                               // 9, 10 e 11
        #expect(Ferias.haSilencio(de: dia(5), dias: 7, cal: cal, agora: dia(5)))
        limpar()
    }

    @Test("expira sozinho: ninguém precisa lembrar de desligar")
    func expira() {
        limpar()
        Ferias.ligado = true
        Ferias.ate = dia(8)
        #expect(!Ferias.expirarSePassou(agora: dia(8)))   // no último dia ainda vale
        #expect(Ferias.vigente(agora: dia(8)))
        #expect(Ferias.expirarSePassou(agora: dia(9)))    // passou: desliga e avisa quem chamou
        #expect(!Ferias.ligado)
        #expect(!Ferias.expirarSePassou(agora: dia(9)))   // e não desliga duas vezes
        limpar()
    }

    @Test("sem data, cala até o autor desligar")
    func semData() {
        limpar()
        Ferias.ligado = true
        Ferias.ate = nil
        #expect(Ferias.vigente(agora: dia(30, 12, 2027)))
        #expect(Ferias.cala(dia(30, 12, 2027), cal: cal, agora: dia(5)))
        #expect(!Ferias.expirarSePassou(agora: dia(30, 12, 2027)))
        #expect(Ferias.diasQueCobram(de: dia(5), dias: 7, cal: cal, agora: dia(5)).isEmpty)
        limpar()
    }

    @Test("feriado só cala quando o autor liga — e 7 de setembro é feriado")
    func feriado() {
        limpar()
        #expect(Feriados.eFeriado(dia(7), cal))                  // Independência
        #expect(!Ferias.cala(dia(7), cal: cal, agora: dia(5)))    // desligado: cobra
        Ferias.incluiFeriados = true
        #expect(Ferias.cala(dia(7), cal: cal, agora: dia(5)))     // ligado: cala
        #expect(!Ferias.cala(dia(8), cal: cal, agora: dia(5)))    // e só no feriado
        // e as duas razões SOMAM: feriado depois do fim das férias continua calado
        Ferias.ligado = true
        Ferias.ate = dia(5)
        #expect(Ferias.cala(dia(7), cal: cal, agora: dia(5)))
        limpar()
    }

    @Test("a série da expressiva não morre: espera o primeiro dia que cobra")
    func aSerieEspera() {
        limpar()
        Ferias.ligado = true
        Ferias.ate = dia(8)
        let quando = Ferias.primeiroDiaQueCobra(aPartirDe: dia(6), cal: cal, agora: dia(5))
        #expect(cal.isDate(quando, inSameDayAs: dia(9)))
        limpar()
        // sem férias, o dia pedido é o dia
        let normal = Ferias.primeiroDiaQueCobra(aPartirDe: dia(6), cal: cal, agora: dia(5))
        #expect(cal.isDate(normal, inSameDayAs: dia(6)))
    }

    @Test("a frase do Perfil diz a verdade em cada estado")
    func emPalavras() {
        limpar()
        #expect(Ferias.emPalavras(agora: dia(5), cal: cal).contains("desligado"))
        Ferias.ligado = true
        Ferias.ate = nil
        #expect(Ferias.emPalavras(agora: dia(5), cal: cal).contains("sem data"))
        Ferias.ate = dia(8)
        #expect(Ferias.emPalavras(agora: dia(5), cal: cal).contains("8 de setembro"))
        limpar()
    }
}

/// ADR 2026-09-04f — a tela bloqueada deixa de ser cartaz.
@Suite("O botão da tela bloqueada", .serialized)
struct TelaBloqueadaInterativaTests {
    @Test("o lembrete atravessa o App Group")
    func lembreteVaiEVolta() {
        let quando = Date().addingTimeInterval(600)
        ProximoCompromisso.gravar(.init(
            titulo: "Dentista", inicio: Date().addingTimeInterval(3600),
            fim: Date().addingTimeInterval(7200), diaInteiro: false, aviso: nil))
        let com = ProximoCompromisso.lido()!.comLembrete(quando)
        ProximoCompromisso.gravar(com)
        let lido = ProximoCompromisso.lido()
        #expect(lido?.lembrarEm != nil)
        #expect(abs((lido?.lembrarEm ?? .now).timeIntervalSince(quando)) < 1)
        ProximoCompromisso.gravar(nil)
    }

    @Test("lembrete que já passou não fica na tela")
    func lembreteVelhoNaoConta() {
        ProximoCompromisso.gravar(.init(
            titulo: "Dentista", inicio: Date().addingTimeInterval(3600),
            fim: Date().addingTimeInterval(7200), diaInteiro: false, aviso: nil,
            lembrarEm: Date().addingTimeInterval(-600)))
        #expect(ProximoCompromisso.lido()?.lembrarEm == nil)
        ProximoCompromisso.gravar(nil)
    }

    @Test("sem permissão o botão NÃO promete lembrete nenhum")
    func semPermissaoNaoMente() async throws {
        // no processo de teste os avisos são `notDetermined`: o intent tem de
        // recusar e não gravar hora nenhuma. Botão que promete o que não vai
        // acontecer é a ADR 04a do avesso.
        ProximoCompromisso.gravar(.init(
            titulo: "Dentista", inicio: Date().addingTimeInterval(3600),
            fim: Date().addingTimeInterval(7200), diaInteiro: false, aviso: nil))
        _ = try await LembrarDepoisIntent().perform()
        #expect(ProximoCompromisso.lido()?.lembrarEm == nil)
        ProximoCompromisso.gravar(nil)
    }

    @Test("sem compromisso o botão não faz nada, e não quebra")
    func semCompromisso() async throws {
        ProximoCompromisso.gravar(nil)
        _ = try await LembrarDepoisIntent().perform()
        #expect(ProximoCompromisso.lido() == nil)
    }
}
