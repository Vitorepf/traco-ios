import Foundation
import Testing
@testable import Traco

struct CalendarioEscalaTests {
    private let cal = {
        var c = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
        return c
    }()

    /// Segunda 20 Jul 2026 12:00 UTC — o dia do vídeo.
    private var ancora: Date {
        cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
    }

    @Test func abaCalendarioEstaNaBarra() {
        #expect(Aba.naBarra == [.notas, .calendario, .padroes, .perfil])
        #expect(Aba.calendario.titulo == "Calendário")
        #expect(Aba.calendario.icone == "calendar")
        #expect(!Aba.naBarra.contains(.escrever))
    }

    @Test func titulosDasQuatroEscalas() {
        #expect(Calendario.titulo(escala: .dia, ancora: ancora, cal) == "20 July")
        #expect(Calendario.titulo(escala: .semana, ancora: ancora, cal) == "19 – 25 July")
        #expect(Calendario.titulo(escala: .mes, ancora: ancora, cal) == "July 2026")
        #expect(Calendario.titulo(escala: .ano, ancora: ancora, cal) == "2026")
    }

    @Test func semanaContemAAncoraENaoSalta() {
        let dias = Calendario.semana(da: ancora, cal)
        #expect(dias.count == 7)
        #expect(cal.component(.day, from: dias[0]) == 19)
        #expect(cal.component(.day, from: dias[1]) == 20)
        #expect(cal.component(.day, from: dias[6]) == 25)
        #expect(dias.contains { Calendario.mesmoDia($0, ancora, cal) })
        let (escala, dia) = Calendario.ir(para: .mes, ancora: ancora)
        #expect(escala == .mes)
        #expect(Calendario.mesmoDia(dia, ancora, cal))
        let (ano, ainda) = Calendario.ir(para: .ano, ancora: ancora)
        #expect(ano == .ano)
        #expect(Calendario.mesmoDia(ainda, ancora, cal))
    }

    @Test func grelhaDoMesTem42CelulasEOdiaVinte() {
        let grelha = Calendario.grelhaDoMes(da: ancora, cal)
        #expect(grelha.count == 42)
        #expect(grelha.contains { Calendario.mesmoDia($0, ancora, cal) })
        #expect(cal.component(.day, from: grelha[0]) == 28)
        #expect(cal.component(.month, from: grelha[0]) == 6)
    }

    @Test func semanaMarcaDasTresAsNoveDaNoite() {
        #expect(Calendario.horasDaSemana == [3, 6, 9, 12, 15, 18, 21])
    }

    @Test func anoTemDozeMeses() {
        let meses = Calendario.mesesDoAno(da: ancora, cal)
        #expect(meses.count == 12)
        #expect(cal.component(.month, from: meses[0]) == 1)
        #expect(cal.component(.month, from: meses[6]) == 7)
        #expect(cal.component(.year, from: meses[11]) == 2026)
    }

    @Test func miniMesDoAnoTemOsNumerosDoMes() {
        let grelha = Calendario.grelhaDoMes(da: ancora, cal)
        let doMes = grelha.filter { Calendario.mesmoMes($0, ancora, cal) }
            .map { cal.component(.day, from: $0) }
        #expect(doMes == Array(1...31))
        #expect(grelha.contains { Calendario.mesmoDia($0, ancora, cal) })
    }

    @Test func escolherOutroMesMantemODia() {
        let set2 = cal.date(from: DateComponents(year: 2026, month: 9, day: 2, hour: 12))!
        let jan = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let novo = Calendario.noMes(jan, preservando: set2, cal)
        #expect(cal.component(.day, from: novo) == 2)
        #expect(cal.component(.month, from: novo) == 1)
        #expect(Calendario.mesmoDia(Calendario.noMes(set2, preservando: set2, cal), set2, cal))
        let jan31 = cal.date(from: DateComponents(year: 2026, month: 1, day: 31, hour: 12))!
        let fev = cal.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        let curto = Calendario.noMes(fev, preservando: jan31, cal)
        #expect(cal.component(.month, from: curto) == 2)
        #expect(cal.component(.day, from: curto) == 28)
    }

    @Test func hojeVoltaAAncoraDeAgora() {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 2, hour: 10))!
        let hoje = Calendario.irHoje(agora: agora, cal)
        #expect(Calendario.eHoje(hoje, agora: agora, cal))
        #expect(!Calendario.eHoje(ancora, agora: agora, cal))
    }
}

struct CalendarioFraseTests {
    private let cal = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
    private var ancora: Date {
        cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
    }

    @Test func teamSyncAsQuatroEMeia() throws {
        let e = try #require(CalendarioFrase.ler(
            "Team sync at 16:30", ancora: ancora, agora: ancora, cal))
        #expect(e.titulo == "Team sync")
        #expect(cal.component(.hour, from: e.inicio) == 16)
        #expect(cal.component(.minute, from: e.inicio) == 30)
        #expect(e.duracaoMinutos == 30)
        #expect(e.categoria == .trabalho)
        #expect(Calendario.mesmoDia(e.inicio, ancora, cal))
    }

    @Test func intervaloDefineOFim() throws {
        let e = try #require(CalendarioFrase.ler(
            "Team sync 16:30-17:00", ancora: ancora, agora: ancora, cal))
        #expect(cal.component(.hour, from: e.fim) == 17)
        #expect(cal.component(.minute, from: e.fim) == 0)
        #expect(e.duracaoMinutos == 30)
    }

    @Test func tomorrowNaoMoveAAncoraSoOEvento() throws {
        let e = try #require(CalendarioFrase.ler(
            "Lunch tomorrow 12:30", ancora: ancora, agora: ancora, cal))
        #expect(e.titulo == "Lunch")
        #expect(cal.component(.day, from: e.inicio) == 21)
        #expect(cal.component(.hour, from: e.inicio) == 12)
        #expect(e.categoria == .social)
    }

    @Test func sextaASeteDaNoite() throws {
        let e = try #require(CalendarioFrase.ler(
            "Gym Friday 7pm", ancora: ancora, agora: ancora, cal))
        #expect(e.titulo == "Gym")
        #expect(cal.component(.weekday, from: e.inicio) == 6)
        #expect(cal.component(.hour, from: e.inicio) == 19)
        #expect(e.categoria == .corpo)
    }

    @Test func vazioNaoInventaEvento() {
        #expect(CalendarioFrase.ler("   ", ancora: ancora, agora: ancora, cal) == nil)
        #expect(CalendarioFrase.ler("at 16:30", ancora: ancora, agora: ancora, cal) == nil)
    }
}

struct CalendarioAgendaTests {
    @Test func mudarEscalaNaoPerdeODia() {
        let cal = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
        let ancora = cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("cal-\(UUID().uuidString).json")
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        agenda.ir(para: .semana)
        #expect(Calendario.mesmoDia(agenda.ancora, ancora, cal))
        agenda.ir(para: .mes)
        #expect(Calendario.mesmoDia(agenda.ancora, ancora, cal))
        agenda.ir(para: .ano)
        #expect(Calendario.mesmoDia(agenda.ancora, ancora, cal))
        #expect(agenda.titulo == "2026")
        agenda.ir(para: .dia)
        #expect(agenda.titulo == "20 July")
    }

    @Test func anoParaOutroMesGuardaODiaDoMes() {
        let cal = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
        let ancora = cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("cal-\(UUID().uuidString).json")
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        agenda.ir(para: .ano)
        agenda.ir(mes: agenda.meses[0])
        agenda.ir(para: .mes)
        #expect(cal.component(.day, from: agenda.ancora) == 20)
        #expect(cal.component(.month, from: agenda.ancora) == 1)
        agenda.ir(mes: agenda.meses[6])
        #expect(Calendario.mesmoDia(agenda.ancora, ancora, cal))
    }

    @Test func prosaViraEventoNoDisco() throws {
        let cal = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
        let ancora = cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("cal-\(UUID().uuidString).json")
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        agenda.prosa = "Team sync at 16:30"
        agenda.adicionarDaProsa()
        #expect(agenda.eventos.contains { $0.titulo == "Team sync" })
        #expect(agenda.prosa.isEmpty)
        let lidos = CalendarioDisco.carregar(de: url)
        #expect(lidos.contains { $0.titulo == "Team sync" })
    }

    @Test func sementeTemOTeamSyncDaSegunda() {
        let cal = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
        let ancora = cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
        let semente = CalendarioDisco.semente(ancora: ancora, agora: ancora, cal)
        let noDia = Calendario.eventos(semente, noDia: ancora, cal)
        #expect(noDia.contains { $0.titulo == "Team sync" })
        #expect(noDia.contains { $0.titulo == "Lunch" })
        #expect(Calendario.eventos(semente, naSemanaDe: ancora, cal).count >= 8)
    }

    /// Photos/Camera plantavam "Photo" no campo — o gesto mentia.
    @Test func maisNaoPlantaPhoto() throws {
        let fonte = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(path: "Traco/Calendario/CalendarioView.swift"),
            encoding: .utf8)
        #expect(!fonte.contains("prosa = \"Photo\""))
        #expect(!fonte.contains("Button(\"Photos\")"))
        #expect(!fonte.contains("Button(\"Camera\")"))
        #expect(fonte.contains("Button(\"Paste\")"))
    }
}
