import Foundation
import Testing
@testable import Traco

private func utc() -> Calendar {
    Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
}

/// Segunda, 20 de julho de 2026, 12:00 UTC.
private var ancora: Date {
    utc().date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
}

struct ConsultaEmProsaTests {
    private let cal = utc()

    private func consulta(_ s: String) -> (Date, EscalaCalendario)? {
        CalendarioFrase.consulta(s, ancora: ancora, agora: ancora, cal).map { ($0.dia, $0.escala) }
    }

    @Test func perguntaVaiAoDia() throws {
        let (dia, escala) = try #require(consulta("o que tenho sexta?"))
        #expect(cal.component(.day, from: dia) == 24)
        #expect(escala == .dia)
        let (amanha, _) = try #require(consulta("amanhã?"))
        #expect(cal.component(.day, from: amanha) == 21)
        let (so, _) = try #require(consulta("sexta"))
        #expect(cal.component(.day, from: so) == 24)
    }

    @Test func periodosMudamAEscala() throws {
        let (d, e) = try #require(consulta("semana que vem"))
        #expect(cal.component(.day, from: d) == 27)
        #expect(e == .semana)
        let (m, em) = try #require(consulta("o que tem no mês que vem"))
        #expect(cal.component(.month, from: m) == 8)
        #expect(em == .mes)
        let (_, ea) = try #require(consulta("este ano"))
        #expect(ea == .ano)
    }

    @Test func compromissoNaoEConsulta() {
        #expect(consulta("dentista sexta 14:30") == nil)
        #expect(consulta("almoço com a Ana amanhã") == nil)
        #expect(consulta("reunião") == nil)
    }

    @Test func aAgendaRespondeIndoAoDia() {
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: FileManager.default.temporaryDirectory
            .appendingPathComponent("cal-\(UUID().uuidString).json"), eventos: [])
        agenda.prosa = "o que tenho na semana que vem?"
        agenda.adicionarDaProsa(agora: ancora)
        #expect(agenda.eventos.isEmpty)
        #expect(agenda.prosa.isEmpty)
        #expect(agenda.escala == .semana)
        #expect(cal.component(.day, from: agenda.ancora) == 27)
        #expect(agenda.toast == nil)
    }
}

struct DeixaNoCalendarioTests {
    private let cal = utc()

    @Test func deixaEntraNasEscalasMasNaoNoDisco() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cal-\(UUID().uuidString).json")
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        let nota = UUID()
        let quando = Calendario.hora(18, 0, no: ancora, cal)
        agenda.deixas = [EventoCalendario(id: nota, titulo: "Se chegar em casa", inicio: quando,
                                          fim: quando.addingTimeInterval(1800), origem: nota)]
        #expect(agenda.eventos(no: ancora).count == 1)
        #expect(agenda.eventos(no: ancora)[0].eDeixa)
        #expect(agenda.eventosDaEscala().count == 1)
        // guardar uma deixa não grava nada: a nota é a dona
        agenda.guardar(agenda.deixas[0])
        #expect(agenda.eventos.isEmpty)
        if case .eventos(let lidos) = CalendarioDisco.carregar(de: url) { #expect(lidos.isEmpty) }
        // abrir chama a nota, não a ficha
        var aberta: UUID?
        agenda.aoAbrirNota = { aberta = $0 }
        agenda.abrir(agenda.deixas[0])
        #expect(aberta == nota)
        #expect(agenda.ficha == nil)
    }

    @Test func origemNuncaVaiAoJSON() throws {
        let e = EventoCalendario(titulo: "x", inicio: ancora, fim: ancora, origem: UUID())
        let enc = JSONEncoder()
        let data = try enc.encode([e])
        let s = String(decoding: data, as: UTF8.self)
        #expect(!s.contains("origem"))
        let lidos = try JSONDecoder().decode([EventoCalendario].self, from: data)
        #expect(lidos[0].origem == nil)
    }
}

struct LenteTests {
    @Test func achaMuletasFrasesFeitasEPassivas() {
        let l = Lente.ler("Tipo, eu acho que no final do dia o projeto foi entregue. Tipo assim, basicamente deu certo.")
        // "tipo assim" come o seu "tipo"; "acho que" come o "eu acho"
        #expect(l.muletas.contains { $0.termo == "tipo" && $0.vezes == 1 })
        #expect(l.muletas.contains { $0.termo == "tipo assim" && $0.vezes == 1 })
        #expect(!l.muletas.contains { $0.termo == "eu acho" })
        #expect(l.muletas.contains { $0.termo == "basicamente" })
        #expect(l.frasesFeitas.contains("no final do dia"))
        #expect(l.passivas.contains { $0.lowercased().contains("foi entregue") })
        #expect(l.palavras > 10)
        #expect(l.frases == 2)
    }

    @Test func adverbioEmMenteEAdjetivoRepetido() {
        let l = Lente.ler("Ele falou rapidamente. O dia foi bonito, a casa é bonita, o carro bonito.")
        #expect(l.adverbios.contains { $0.termo == "rapidamente" })
        // adjetivo só vira achado quando repete
        #expect(l.adjetivos.allSatisfy { $0.vezes >= 2 })
    }

    @Test func textoLimpoNaoTemNadaAApontar() {
        let l = Lente.ler("Fui ao mercado e comprei pão.")
        #expect(l.muletas.isEmpty)
        #expect(l.frasesFeitas.isEmpty)
        #expect(l.passivas.isEmpty)
        #expect(l.adjetivos.isEmpty)
    }
}

struct VersoesEApontarTests {
    private func pastaTemp() -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("v-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }

    @Test func versaoGuardaAAnteriorENuncaAExpressiva() {
        Versoes.diretorio = pastaTemp()
        let id = UUID()
        #expect(Versoes.registrar(id, texto: "primeira", campos: [:], gesto: nil, fechada: false))
        // igual à última: não duplica
        #expect(!Versoes.registrar(id, texto: "primeira", campos: [:], gesto: nil, fechada: false))
        #expect(Versoes.registrar(id, texto: "segunda", campos: ["se": "x"], gesto: .seEntao, fechada: false))
        let lista = Versoes.listar(id)
        #expect(lista.count == 2)
        #expect(lista[0].texto == "segunda")
        // expressiva e fechada nunca entram
        #expect(!Versoes.registrar(UUID(), texto: "desabafo", campos: [:], gesto: .expressiva, fechada: false))
        #expect(!Versoes.registrar(UUID(), texto: "selada", campos: [:], gesto: nil, fechada: true))
        Versoes.apagar(id)
        #expect(Versoes.listar(id).isEmpty)
    }

    @Test func versoesTemTeto() {
        Versoes.diretorio = pastaTemp()
        let id = UUID()
        for i in 0..<40 { Versoes.registrar(id, texto: "v\(i)", campos: [:], gesto: nil, fechada: false) }
        #expect(Versoes.listar(id).count == Versoes.teto)
        #expect(Versoes.listar(id)[0].texto == "v39")
    }

    @Test func apontarSoTrechoDoProprioTexto() {
        Apontar.diretorio = pastaTemp()
        let id = UUID()
        let texto = "no final do dia o projeto foi entregue"
        #expect(Apontar.marcar(id, trecho: "no final do dia", rotulo: .fraseFeita, noTexto: texto))
        #expect(!Apontar.marcar(id, trecho: "frase que não existe", rotulo: .vago, noTexto: texto))
        #expect(Apontar.marcar(id, trecho: "foi entregue", rotulo: .passiva, noTexto: texto))
        let lista = Apontar.listar(id)
        #expect(lista.count == 2)
        #expect(lista[0].rotulo == .passiva)
        #expect(Apontar.desmarcar(id, id: lista[0].id))
        #expect(Apontar.listar(id).count == 1)
        Apontar.apagar(id)
        #expect(Apontar.listar(id).isEmpty)
    }
}

struct PastaEspelhoTests {
    @Test func espelhoEscreveNaPastaDoAutorESoOQuePodeSair() throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("esp-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        PastaEspelho.defaults = UserDefaults(suiteName: "teste-espelho-\(UUID().uuidString)")!
        #expect(PastaEspelho.nome == nil)
        #expect(PastaEspelho.guardar(raiz))
        #expect(PastaEspelho.nome == raiz.lastPathComponent)

        let aberta = FatiaCorpus(id: UUID(), texto: "quero correr", gesto: .woop, campos: [:],
                                 criadaEm: .now, editadaEm: .now, recordada: 0, sentido: "", minutos: 0,
                                 trancada: false, queimada: false, expressivaEmCurso: false,
                                 dominio: nil, serie: nil, dia: 0)
        let emCurso = FatiaCorpus(id: UUID(), texto: "desabafo", gesto: .expressiva, campos: [:],
                                  criadaEm: .now, editadaEm: .now, recordada: 0, sentido: "", minutos: 3,
                                  trancada: false, queimada: false, expressivaEmCurso: true,
                                  dominio: nil, serie: nil, dia: 0)
        var escrita: URL?
        PastaEspelho.comAcesso { pasta in
            Corpus.escrever(fatias: [aberta, emCurso], em: pasta)
            escrita = pasta
        }
        let pasta = try #require(escrita)
        #expect(pasta.lastPathComponent == "Traço")
        let notas = try FileManager.default.contentsOfDirectory(atPath: pasta.appendingPathComponent("notas").path)
        #expect(notas == [aberta.id.uuidString.lowercased() + ".md"])
        #expect(FileManager.default.fileExists(atPath: pasta.appendingPathComponent("LEIA-ME.md").path))
        #expect(FileManager.default.fileExists(atPath: pasta.appendingPathComponent("traco-corpus.md").path))
        let corpus = try String(contentsOf: pasta.appendingPathComponent("traco-corpus.md"), encoding: .utf8)
        #expect(!corpus.contains("desabafo"))

        PastaEspelho.limpar()
        #expect(PastaEspelho.nome == nil)
        var chamou = false
        PastaEspelho.comAcesso { _ in chamou = true }
        #expect(!chamou)
    }
}
