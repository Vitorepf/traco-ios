import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-06d — a linha do tempo dos widgets da casa.
///
/// O defeito que abriu a volta F4 não estava em nenhuma suíte: `policy:
/// .never` nas duas linhas do tempo. Sem o app abrir, o WidgetKit nunca mais
/// pedia nada e o widget congelava — nove horas parados no iPhone do dono
/// (06/09, 13:04, "atualizado às 04:14"). Aqui a lei fica escrita: a política
/// SEMPRE devolve uma volta, dentro de um teto e acima de um piso, e as
/// entradas desenham o dia sem acordar o app.
@Suite("Linha do tempo do widget (F4)")
struct LinhaDoTempoWidgetTests {
    private let agora = Date(timeIntervalSince1970: 1_788_700_000)  // 06/09/2026, meio do dia

    private func proximo(_ titulo: String, daqui minutos: Double, dura: Double = 60,
                         lembrar: Date? = nil) -> Superficie.Proximo {
        let i = agora.addingTimeInterval(minutos * 60)
        return .init(titulo: titulo, inicio: i, fim: i.addingTimeInterval(dura * 60),
                     diaInteiro: false, aviso: nil, lembrarEm: lembrar)
    }

    private func superficie(_ proximos: [Superficie.Proximo],
                            validoAte: Date? = nil) -> SuperficieDisco.Leitura {
        .disponivel(Superficie(geradoEm: agora,
                               validoAte: validoAte ?? agora.addingTimeInterval(14 * 86400),
                               destaque: nil, proximos: proximos))
    }

    /// O que os dois provedores montam: as transições que a superfície conhece
    /// mais os começos que ainda não passaram.
    private func datas(_ leitura: SuperficieDisco.Leitura, cal: Calendar = .current) -> [Date] {
        guard case .disponivel(let s) = leitura else {
            return Relogio.datas(base: Superficie.transicoes(leitura, agora: agora),
                                 inicios: [], agora: agora, cal: cal)
        }
        return Relogio.datas(base: Superficie.transicoes(leitura, agora: agora),
                             inicios: s.proximos.filter { $0.fim > agora }.map(\.inicio),
                             agora: agora, cal: cal)
    }

    // MARK: - A política: nunca `.never`

    @Test("a volta existe sempre, mesmo sem nenhuma transição")
    func voltaSempre() {
        let semNada = Relogio.voltar(agora: agora, ultima: nil)
        #expect(semNada > agora)
        #expect(semNada <= agora.addingTimeInterval(Relogio.releitura))
    }

    @Test("a volta nunca passa do teto de releitura, por longe que seja a última entrada")
    func voltaTemTeto() {
        let daquiADuasSemanas = agora.addingTimeInterval(14 * 86400)
        #expect(Relogio.voltar(agora: agora, ultima: daquiADuasSemanas)
                == agora.addingTimeInterval(Relogio.releitura))
    }

    @Test("a volta nunca cai abaixo do piso: transição colada não vira rajada")
    func voltaTemPiso() {
        let jaJa = agora.addingTimeInterval(30)
        #expect(Relogio.voltar(agora: agora, ultima: jaJa) == agora.addingTimeInterval(Relogio.minimo))
        #expect(Relogio.voltar(agora: agora, ultima: agora.addingTimeInterval(-3600))
                == agora.addingTimeInterval(Relogio.minimo))
    }

    @Test("entre o piso e o teto, a volta é a última entrada — releitura na hora em que muda")
    func voltaSegueAUltimaEntrada() {
        let daquiAUmaHora = agora.addingTimeInterval(3600)
        #expect(Relogio.voltar(agora: agora, ultima: daquiAUmaHora) == daquiAUmaHora)
    }

    @Test("o orçamento: no máximo umas poucas releituras por dia")
    func orcamentoRespeitado() {
        #expect(86400 / Relogio.releitura <= 12)
        #expect(Relogio.minimo >= 600)
    }

    // MARK: - As entradas: o dia desenhado de uma vez

    @Test("a véspera, o início e o fim de cada compromisso entram na linha")
    func vesperaInicioEFim() {
        let p = proximo("Dentista", daqui: 180)
        let datas = datas(superficie([p]))
        #expect(datas.contains(p.inicio.addingTimeInterval(-Relogio.vespera)))
        #expect(datas.contains(p.inicio))
        #expect(datas.contains(p.fim))
    }

    @Test("a meia-noite entra sempre: o Destaque de hoje deixa de ser o de hoje")
    func meiaNoiteEntra() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        let meiaNoite = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: agora)!)
        #expect(datas(superficie([]), cal: cal).contains(meiaNoite))
        // e também quando não há nada que ler: a linha nunca fica vazia
        #expect(datas(.indisponivel, cal: cal).contains(meiaNoite))
    }

    @Test("nenhuma entrada no passado, nenhuma repetida, tudo em ordem")
    func ordenadasESemPassado() {
        let datas = datas(superficie([proximo("Já passou", daqui: -120), proximo("Dentista", daqui: 45),
                                      proximo("Jantar", daqui: 45)]))  // mesma hora: uma data só
        #expect(datas == datas.sorted())
        #expect(Set(datas).count == datas.count)
        #expect(datas.allSatisfy { $0 >= agora })
    }

    @Test("a véspera que já passou não vira entrada")
    func vesperaPassadaNaoEntra() {
        // começa em 20 min: a véspera (uma hora antes) já ficou para trás
        let p = proximo("Daqui a pouco", daqui: 20)
        let datas = datas(superficie([p]))
        #expect(!datas.contains(p.inicio.addingTimeInterval(-Relogio.vespera)))
        #expect(datas.contains(p.inicio))
    }

    @Test("a linha é curta: um dia cheio cabe em poucas entradas")
    func linhaCurta() {
        let datas = datas(superficie([proximo("Dentista", daqui: 45), proximo("Revisão", daqui: 180),
                                      proximo("Jantar", daqui: 420)]))
        // agora + (véspera, início, fim) × 3 + meia-noite + horizonte
        #expect(datas.count <= 12)
        #expect(datas.first == agora)
    }

    @Test("a soneca da tela bloqueada continua sendo uma transição")
    func sonecaEntra() {
        let soneca = agora.addingTimeInterval(600)
        let p = proximo("Dentista", daqui: 45, lembrar: soneca)
        #expect(datas(superficie([p])).contains(soneca))
    }
}

/// ADR 2026-09-06d, revisão G3 — A2: o sino é uma promessa, não um enfeite.
///
/// O revisor negou os avisos às 15:20 e às 15:21 os quatro widgets da casa
/// mostravam `🔔 16:00` e `🔔 17:15`. Nenhum ponto do caminho de publicação
/// perguntava pela autorização: `mudo:` silenciava UM evento (o que acabara de
/// ser gravado) e a revogação global não silenciava nada. Aqui a lei fica
/// escrita: sem permissão no último olhar, a superfície sai sem sino nenhum.
@Suite("O sino só sai quando há alarme (F4-B)")
struct SinoHonestoTests {
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!) }

    private func comEspelho(_ permitido: Bool, _ corpo: () -> Void) {
        let antes = SuperficieDisco.defaults.bool(forKey: Avisos.chaveEspelho)
        SuperficieDisco.defaults.set(permitido, forKey: Avisos.chaveEspelho)
        corpo()
        SuperficieDisco.defaults.set(antes, forKey: Avisos.chaveEspelho)
    }

    @Test("avisos negados no iPhone: nenhum sino na superfície")
    func negadoNaoPromete() {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 6, hour: 15, minute: 21))!
        let dentista = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(2340),
                                        fim: agora.addingTimeInterval(5940))
        let revisao = EventoCalendario(titulo: "Revisão com o time", inicio: agora.addingTimeInterval(6540),
                                       fim: agora.addingTimeInterval(10140))

        comEspelho(false) {
            let fatias = ProximoCompromisso.proximasFatias([dentista, revisao], cal: cal, manha: 8, agora: agora)
            #expect(fatias.count == 2)
            #expect(fatias.allSatisfy { $0.aviso == nil })
        }

        // e com permissão o sino volta — a correção não apagou a promessa,
        // só passou a exigir que ela seja verdade
        comEspelho(true) {
            let fatias = ProximoCompromisso.proximasFatias([dentista, revisao], cal: cal, manha: 8, agora: agora)
            #expect(fatias.allSatisfy { $0.aviso != nil })
        }
    }

    @Test("permissão negada vence o caminho de publicação inteiro")
    func negadoAtravessaAPublicacao() {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 6, hour: 15, minute: 21))!
        let e = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(2340),
                                 fim: agora.addingTimeInterval(5940))
        comEspelho(false) {
            ProximoCompromisso.publicar([e], cal: cal, manha: 8, agora: agora)
            #expect(ProximoCompromisso.lido(agora: agora)?.aviso == nil)
        }
        comEspelho(true) {
            ProximoCompromisso.publicar([e], cal: cal, manha: 8, agora: agora)
            #expect(ProximoCompromisso.lido(agora: agora)?.aviso != nil)
        }
        ProximoCompromisso.gravar(nil)
    }
}
