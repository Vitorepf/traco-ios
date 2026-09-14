import Foundation
import Testing
@testable import Traco

private func utc(segunda: Bool = false) -> Calendar {
    Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!, segundaPrimeiro: segunda)
}

private func urlTemp() -> URL {
    FileManager.default.temporaryDirectory
        .appendingPathComponent("cal-\(UUID().uuidString)")
        .appendingPathComponent("calendario.json")
}

struct CalendarioEscalaTests {
    private let cal = utc()

    /// Segunda, 20 de julho de 2026, 12:00 UTC.
    private var ancora: Date {
        cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
    }

    @Test func abaCalendarioEstaNaBarra() {
        #expect(Aba.naBarra == [.notas, .calendario, .padroes, .perfil])
        #expect(Aba.calendario.titulo == "Calendário")
    }

    @Test func titulosEmPortugues() {
        #expect(Calendario.titulo(escala: .dia, ancora: ancora, cal) == "20 de julho")
        #expect(Calendario.titulo(escala: .semana, ancora: ancora, cal) == "19 – 25 de julho")
        #expect(Calendario.titulo(escala: .mes, ancora: ancora, cal) == "Julho 2026")
        #expect(Calendario.titulo(escala: .ano, ancora: ancora, cal) == "2026")
        let set2 = cal.date(from: DateComponents(year: 2026, month: 9, day: 2, hour: 12))!
        #expect(Calendario.titulo(escala: .semana, ancora: set2, cal) == "30 ago – 5 set")
    }

    @Test func letrasDaSemanaSeguemOPrimeiroDia() {
        #expect(Calendario.letrasDaSemana(cal) == ["D", "S", "T", "Q", "Q", "S", "S"])
        #expect(Calendario.letrasDaSemana(utc(segunda: true)) == ["S", "T", "Q", "Q", "S", "S", "D"])
        #expect(EscalaCalendario.allCases.map(\.letra) == ["D", "S", "M", "A"])
    }

    @Test func semanaContemAAncoraENaoSalta() {
        let dias = Calendario.semana(da: ancora, cal)
        #expect(dias.count == 7)
        #expect(cal.component(.day, from: dias[0]) == 19)
        #expect(cal.component(.day, from: dias[6]) == 25)
        let naSegunda = Calendario.semana(da: ancora, utc(segunda: true))
        #expect(cal.component(.day, from: naSegunda[0]) == 20)
        #expect(cal.component(.day, from: naSegunda[6]) == 26)
        let (escala, dia) = Calendario.ir(para: .mes, ancora: ancora)
        #expect(escala == .mes)
        #expect(Calendario.mesmoDia(dia, ancora, cal))
    }

    @Test func grelhaDoMesTem42CelulasEOdiaVinte() {
        let grelha = Calendario.grelhaDoMes(da: ancora, cal)
        #expect(grelha.count == 42)
        #expect(grelha.contains { Calendario.mesmoDia($0, ancora, cal) })
        #expect(cal.component(.day, from: grelha[0]) == 28)
        #expect(cal.component(.month, from: grelha[0]) == 6)
    }

    @Test func anoTemDozeMeses() {
        let meses = Calendario.mesesDoAno(da: ancora, cal)
        #expect(meses.count == 12)
        #expect(cal.component(.month, from: meses[0]) == 1)
        #expect(cal.component(.year, from: meses[11]) == 2026)
    }

    @Test func escolherOutroMesMantemODia() {
        let set2 = cal.date(from: DateComponents(year: 2026, month: 9, day: 2, hour: 12))!
        let jan = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let novo = Calendario.noMes(jan, preservando: set2, cal)
        #expect(cal.component(.day, from: novo) == 2)
        #expect(cal.component(.month, from: novo) == 1)
        let jan31 = cal.date(from: DateComponents(year: 2026, month: 1, day: 31, hour: 12))!
        let fev = cal.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        let curto = Calendario.noMes(fev, preservando: jan31, cal)
        #expect(cal.component(.day, from: curto) == 28)
    }

    /// No dia da mudança de horário, somar minutos ao início do dia dava 17:30.
    @Test func horaNaoEscorregaNoHorarioDeVerao() {
        let lisboa = Calendario.gregoriano(fuso: TimeZone(identifier: "Europe/Lisbon")!)
        let mudanca = lisboa.date(from: DateComponents(year: 2026, month: 3, day: 29, hour: 12))!
        let d = Calendario.hora(16, 30, no: mudanca, lisboa)
        #expect(lisboa.component(.hour, from: d) == 16)
        #expect(lisboa.component(.minute, from: d) == 30)
        let meiaNoite = Calendario.hora(24, 0, no: mudanca, lisboa)
        #expect(lisboa.component(.day, from: meiaNoite) == 30)
        #expect(lisboa.component(.hour, from: meiaNoite) == 0)
    }

    @Test func doisAoMesmoTempoFicamLadoALado() {
        func e(_ t: String, _ h: Int, _ m: Int, _ dur: Int) -> EventoCalendario {
            let i = Calendario.hora(h, m, no: ancora, cal)
            return EventoCalendario(titulo: t, inicio: i, fim: i.addingTimeInterval(Double(dur) * 60))
        }
        let colunas = Calendario.colunas([e("A", 9, 0, 60), e("B", 9, 30, 60), e("C", 14, 0, 30)])
        let a = colunas.first { $0.evento.titulo == "A" }!
        let b = colunas.first { $0.evento.titulo == "B" }!
        let c = colunas.first { $0.evento.titulo == "C" }!
        #expect(a.total == 2 && b.total == 2)
        #expect(a.indice != b.indice)
        #expect(c.total == 1 && c.indice == 0)
    }

    @Test func moverODiaLevaADuracao() {
        let i = Calendario.hora(14, 0, no: ancora, cal)
        let e = EventoCalendario(titulo: "X", inicio: i, fim: i.addingTimeInterval(5400))
        let outro = cal.date(byAdding: .day, value: 3, to: ancora)!
        let movido = e.movido(paraODiaDe: outro, cal)
        #expect(cal.component(.day, from: movido.inicio) == 23)
        #expect(cal.component(.hour, from: movido.inicio) == 14)
        #expect(movido.duracaoMinutos == 90)
        let fimAntes = e.comFim(i.addingTimeInterval(-3600))
        #expect(fimAntes.duracaoMinutos == 5)
        let comecaDepois = e.comInicio(i.addingTimeInterval(7200))
        #expect(comecaDepois.duracaoMinutos == 90)
    }
}

struct CalendarioFraseTests {
    private let cal = utc()
    private var ancora: Date {
        cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
    }

    private func ler(_ s: String) -> EventoCalendario? {
        CalendarioFrase.ler(s, ancora: ancora, agora: ancora, cal, manha: 8, tarde: 14, noite: 20)
    }

    @Test func dentistaSextaAsDuasEMeia() throws {
        let e = try #require(ler("Dentista sexta 14:30"))
        #expect(e.titulo == "Dentista")
        #expect(cal.component(.weekday, from: e.inicio) == 6)
        #expect(cal.component(.day, from: e.inicio) == 24)
        #expect(cal.component(.hour, from: e.inicio) == 14)
        #expect(cal.component(.minute, from: e.inicio) == 30)
        #expect(e.dominio == .saude)
        #expect(e.duracaoMinutos == 60)
    }

    @Test func numeroSoltoNaoEHora() throws {
        let e = try #require(ler("reunião com 3 pessoas"))
        #expect(e.titulo == "Reunião com 3 pessoas")
        #expect(cal.component(.hour, from: e.inicio) == 9)
        #expect(e.dominio == .trabalho)
    }

    @Test func amanhaAsDozeComConectoresLimpos() throws {
        let e = try #require(ler("almoço com a Ana amanhã às 12h"))
        #expect(e.titulo == "Almoço com a Ana")
        #expect(cal.component(.day, from: e.inicio) == 21)
        #expect(cal.component(.hour, from: e.inicio) == 12)
        #expect(e.dominio == .pessoas)
    }

    @Test func intervaloDefineOFim() throws {
        let e = try #require(ler("das 9h às 10h30 reunião"))
        #expect(e.titulo == "Reunião")
        #expect(cal.component(.hour, from: e.inicio) == 9)
        #expect(e.duracaoMinutos == 90)
        let f = try #require(ler("Treino 14:30-16:00"))
        #expect(f.duracaoMinutos == 90)
    }

    @Test func duracaoPorExtenso() throws {
        let e = try #require(ler("treino por 45 min hoje 7h"))
        #expect(e.titulo == "Treino")
        #expect(cal.component(.day, from: e.inicio) == 20)
        #expect(cal.component(.hour, from: e.inicio) == 7)
        #expect(e.duracaoMinutos == 45)
        let f = try #require(ler("viagem por 2h"))
        #expect(f.duracaoMinutos == 120)
    }

    @Test func diaInteiroEDiaDoMes() throws {
        let e = try #require(ler("viagem dia 25 dia inteiro"))
        #expect(e.titulo == "Viagem")
        #expect(e.diaInteiro)
        #expect(cal.component(.day, from: e.inicio) == 25)
        #expect(cal.component(.month, from: e.inicio) == 7)
        let f = try #require(ler("prova 15/09"))
        #expect(cal.component(.day, from: f.inicio) == 15)
        #expect(cal.component(.month, from: f.inicio) == 9)
        #expect(f.dominio == .estudo)
        // dia 3 já passou em julho: vai para agosto
        let g = try #require(ler("boleto dia 3"))
        #expect(cal.component(.month, from: g.inicio) == 8)
        #expect(g.dominio == .dinheiro)
    }

    @Test func periodosDoDiaUsamAsAncorasDoAutor() throws {
        let e = try #require(ler("feira sábado de manhã"))
        #expect(e.titulo == "Feira")
        #expect(cal.component(.weekday, from: e.inicio) == 7)
        #expect(cal.component(.hour, from: e.inicio) == 8)
        #expect(e.dominio == .casa)
        let f = try #require(ler("cinema à noite"))
        #expect(cal.component(.hour, from: f.inicio) == 20)
    }

    @Test func vazioNaoInventaEvento() {
        #expect(ler("   ") == nil)
        #expect(ler("às 16:30") == nil)
        #expect(ler("amanhã") == nil)
    }
}

struct CalendarioDominioTests {
    @Test func palavraInteiraNaoPedaco() {
        #expect(Dominio.inferir(voz: "casamento da prima") == .pessoas)
        #expect(Dominio.inferir(voz: "preciso encontrar o computador") == nil)
        #expect(Dominio.inferir(voz: "o país inteiro") == nil)
        #expect(Dominio.inferir(voz: "pagar a conta") == .dinheiro)
        // ADR 05d: empate é silêncio, e o modelo devolve pela lista fechada
        #expect(Dominio.inferir(voz: "toda vez que eu chegar em casa deixo o celular na gaveta e vou ler") == nil)
        #expect(Dominio.inferir(voz: "reunião com o cliente sobre o aluguel da casa nova e a reforma") == .casa)
        #expect(Dominio.doModelo("estudo") == .some(.estudo))
        #expect(Dominio.doModelo("nenhum") == .some(nil))
        #expect(Dominio.doModelo("cozinha") == nil)
    }
}

struct CalendarioDiscoTests {
    private let cal = utc()

    @Test func corrompidoVaiParaOLadoENuncaViraSemente() throws {
        let url = urlTemp()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("{isto não é json".utf8).write(to: url)
        if case .corrompido = CalendarioDisco.carregar(de: url) {} else { Issue.record("devia ser corrompido") }
        let agenda = CalendarioAgenda(agora: .now, cal: cal, disco: url)
        #expect(agenda.eventos.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
        let irmaos = try FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
        #expect(irmaos.contains { $0.contains("ilegivel") })
        #expect(agenda.toast != nil)
    }

    @Test func vazioFicaVazio() throws {
        let url = urlTemp()
        try CalendarioDisco.gravar([], em: url)
        let agenda = CalendarioAgenda(agora: .now, cal: cal, disco: url)
        #expect(agenda.eventos.isEmpty)
        #expect(agenda.toast == nil)
    }

    @Test func arquivoAntigoComCategoriaViraDominio() throws {
        let url = urlTemp()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let antigo = """
        [{"id":"7E7B1A6A-2C3B-4E9D-9B1F-1F2A3B4C5D6E","titulo":"Gym","inicio":780000000,"fim":780003600,"categoria":"corpo","notas":"","diaInteiro":false}]
        """
        try Data(antigo.utf8).write(to: url)
        guard case .eventos(let lidos) = CalendarioDisco.carregar(de: url) else {
            Issue.record("devia ler o formato antigo")
            return
        }
        #expect(lidos.count == 1)
        #expect(lidos[0].dominio == .saude)
        // regrava no formato novo e continua legível
        try CalendarioDisco.gravar(lidos, em: url)
        guard case .eventos(let deNovo) = CalendarioDisco.carregar(de: url) else {
            Issue.record("devia reler")
            return
        }
        #expect(deNovo == lidos)
    }
}

struct CalendarioAgendaTests {
    private let cal = utc()
    private var ancora: Date {
        cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
    }

    @Test func mudarEscalaNaoPerdeODia() {
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: urlTemp(), eventos: [])
        agenda.ir(para: .semana)
        #expect(Calendario.mesmoDia(agenda.ancora, ancora, cal))
        #expect(!agenda.aproximando)
        agenda.ir(para: .ano)
        #expect(agenda.titulo == "2026")
        agenda.ir(para: .dia)
        #expect(agenda.aproximando)
        #expect(agenda.titulo == "20 de julho")
    }

    @Test func anoParaOutroMesGuardaODiaDoMes() {
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: urlTemp(), eventos: [])
        agenda.ir(para: .ano)
        agenda.ir(mes: agenda.meses[0])
        agenda.ir(para: .mes)
        #expect(cal.component(.day, from: agenda.ancora) == 20)
        #expect(cal.component(.month, from: agenda.ancora) == 1)
    }

    @Test func prosaViraEventoNoDiscoEAncoraVaiAoDia() throws {
        let url = urlTemp()
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        agenda.prosa = "Reunião de equipe amanhã às 16:30"
        agenda.adicionarDaProsa(agora: ancora)
        #expect(agenda.eventos.contains { $0.titulo == "Reunião de equipe" })
        #expect(agenda.prosa.isEmpty)
        #expect(cal.component(.day, from: agenda.ancora) == 21)
        guard case .eventos(let lidos) = CalendarioDisco.carregar(de: url) else {
            Issue.record("devia gravar")
            return
        }
        #expect(lidos.contains { $0.titulo == "Reunião de equipe" })
    }

    /// O gesto não mente: disco recusado, a prosa fica e nada entra.
    @Test func discoRecusadoNaoLimpaAProsa() {
        let url = URL(fileURLWithPath: "/dev/null/traco-impossivel/calendario.json")
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        agenda.prosa = "Dentista 14:30"
        agenda.adicionarDaProsa(agora: ancora)
        #expect(agenda.prosa == "Dentista 14:30")
        #expect(agenda.eventos.isEmpty)
        #expect(agenda.ficha == nil)
        #expect(agenda.toast != nil)
    }

    @Test func fichaSemTituloNaoEntraEApagarTira() {
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: urlTemp(), eventos: [])
        let i = Calendario.hora(10, 0, no: ancora, cal)
        agenda.guardar(EventoCalendario(titulo: "   ", inicio: i, fim: i.addingTimeInterval(1800)))
        #expect(agenda.eventos.isEmpty)
        let e = EventoCalendario(titulo: "Café", inicio: i, fim: i.addingTimeInterval(1800))
        agenda.guardar(e)
        #expect(agenda.eventos.count == 1)
        agenda.apagar(e.id)
        #expect(agenda.eventos.isEmpty)
    }
}

/// ADR: a série, a âncora e a ordem da frase (achados 01 e 02 da varredura).
@Suite struct RepeticaoEAncoraTests {
    let cal = Calendario.gregoriano()

    private func dia(_ ano: Int, _ mes: Int, _ d: Int, _ h: Int = 10) -> Date {
        cal.date(from: DateComponents(year: ano, month: mes, day: d, hour: h))!
    }

    /// O bug de julho: a tela em 13/jul, o autor em setembro.
    @Test func oDiaDaSemanaSaiDeHojeNaoDaTela() throws {
        let setembro = dia(2026, 9, 3)          // quinta
        let julho = dia(2026, 7, 13)            // segunda — a tela ficou aqui
        let e = try #require(CalendarioFrase.ler("dentista sexta 14h", ancora: julho, agora: setembro, cal))
        #expect(cal.component(.month, from: e.inicio) == 9)
        #expect(cal.component(.day, from: e.inicio) == 4)   // a próxima sexta de VERDADE
    }

    /// Dois dias na frase, sem "toda": manda a ordem da FRASE.
    @Test func aOrdemDaFraseVenceAOrdemDaLista() throws {
        let quinta = dia(2026, 9, 3)
        let e = try #require(CalendarioFrase.ler("treino sexta e segunda", ancora: quinta, agora: quinta, cal))
        #expect(cal.component(.weekday, from: e.inicio) == 6) // sexta, a primeira na frase
        #expect(!e.titulo.lowercased().contains("sexta"))     // e ela SAIU do título
    }

    @Test func todaSextaESegundaViraSerie() throws {
        let quinta = dia(2026, 9, 3)
        let e = try #require(CalendarioFrase.ler("academia toda sexta e segunda às 8:30", ancora: quinta, agora: quinta, cal))
        #expect(e.repeteEm == [2, 6])
        #expect(e.titulo == "Academia")
        #expect(cal.component(.hour, from: e.inicio) == 8)
        #expect(cal.component(.minute, from: e.inicio) == 30)
        // a primeira ocorrência é a próxima sexta (4/9), não hoje
        #expect(cal.component(.day, from: e.inicio) == 4)
    }

    @Test func oPluralTambemConta() throws {
        let quinta = dia(2026, 9, 3)
        let e = try #require(CalendarioFrase.ler("pilates todas as terças", ancora: quinta, agora: quinta, cal))
        #expect(e.repeteEm == [3])
    }

    @Test func semTodaNaoRepete() throws {
        let quinta = dia(2026, 9, 3)
        let e = try #require(CalendarioFrase.ler("dentista sexta 14:30", ancora: quinta, agora: quinta, cal))
        #expect(e.repeteEm.isEmpty)
        #expect(!e.repete)
    }

    /// A série é UMA linha no disco; a tela é que multiplica.
    @Test func aSerieViraUmaOcorrenciaPorDiaQueCasa() {
        let serie = EventoCalendario(
            titulo: "Academia", inicio: dia(2026, 9, 4, 8), fim: dia(2026, 9, 4, 9),
            repeteEm: [2, 6])
        let ocorrencias = Calendario.ocorrencias(
            [serie], de: dia(2026, 9, 1), a: dia(2026, 9, 30), cal)
        // setembro/2026: sextas 4,11,18,25 · segundas 7,14,21,28 — mas só a
        // partir do início da série (4/9), então a segunda 31/8 não entra
        #expect(ocorrencias.count == 8)
        #expect(ocorrencias.allSatisfy { [2, 6].contains(cal.component(.weekday, from: $0.inicio)) })
        // a hora do dia sobrevive a cada cópia
        #expect(ocorrencias.allSatisfy { cal.component(.hour, from: $0.inicio) == 8 })
        // e a cópia carrega o id da SÉRIE: tocar nela abre a série
        #expect(ocorrencias.allSatisfy { $0.id == serie.id })
    }

    /// Antes do início da série não existe ocorrência.
    @Test func aSerieNaoRetroage() {
        let serie = EventoCalendario(
            titulo: "Academia", inicio: dia(2026, 9, 18, 8), fim: dia(2026, 9, 18, 9),
            repeteEm: [6])
        let antes = Calendario.ocorrencias([serie], de: dia(2026, 9, 1), a: dia(2026, 9, 17), cal)
        #expect(antes.isEmpty)
    }

    @Test func eventoSemRepeticaoSaiUmaVez() {
        let uma = EventoCalendario(titulo: "Prova", inicio: dia(2026, 9, 15, 9), fim: dia(2026, 9, 15, 11))
        let xs = Calendario.ocorrencias([uma], de: dia(2026, 9, 1), a: dia(2026, 9, 30), cal)
        #expect(xs.count == 1)
        #expect(xs.first?.inicio == uma.inicio)
    }

    /// O arquivo do autor: a série vai e volta inteira, e o antigo sem a chave
    /// continua abrindo como uma vez só.
    @Test func aSerieSobreviveAoDisco() throws {
        let serie = EventoCalendario(titulo: "Academia", inicio: dia(2026, 9, 4, 8),
                                     fim: dia(2026, 9, 4, 9), repeteEm: [2, 6])
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        let volta = try dec.decode([EventoCalendario].self, from: try enc.encode([serie]))
        #expect(volta.first?.repeteEm == [2, 6])

        let antigo = #"[{"id":"\#(UUID().uuidString)","titulo":"Velho","inicio":"2026-09-04T08:00:00Z","fim":"2026-09-04T09:00:00Z","notas":"","diaInteiro":false}]"#
        let lido = try dec.decode([EventoCalendario].self, from: Data(antigo.utf8))
        #expect(lido.first?.repeteEm.isEmpty == true)
    }

    @Test func osDiasSaemEmLetras() {
        #expect(Calendario.diasEmLetras([2, 6], cal) == "seg · sex")
        #expect(Calendario.diasEmLetras([], cal) == "")
    }

    @Test("vários compromissos numa frase só viram vários; sem marca em todas as partes, é um")
    func variosNumaFrase() throws {
        let cal = Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!)
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 14, hour: 9))!
        let dois = CalendarioFrase.lerVarios("dentista sexta 14h e reunião segunda 10h", ancora: agora, agora: agora, cal)
        #expect(dois.count == 2)
        #expect(dois.map(\.titulo) == ["Dentista", "Reunião"])
        let tres = CalendarioFrase.lerVarios("dentista sexta 14h; correr terça 6h30, almoço quinta 12h", ancora: agora, agora: agora, cal)
        #expect(tres.count == 3)
        let um = CalendarioFrase.lerVarios("jantar com a Ana e o Pedro às 20h", ancora: agora, agora: agora, cal)
        #expect(um.count == 1)
        #expect(um.first?.titulo == "Jantar com a Ana e o Pedro")
        let semMarca = CalendarioFrase.lerVarios("dentista sexta 14h e ligar para a Ana", ancora: agora, agora: agora, cal)
        #expect(semMarca.count == 1)
    }
}
