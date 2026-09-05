import Foundation
import Testing

@testable import Traco

@Suite struct FeriadosTests {
    let cal = Calendario.gregoriano()

    private func dia(_ ano: Int, _ mes: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: ano, month: mes, day: d))!
    }

    @Test func aPascoaBateComOCalendarioDeVerdade() {
        // conferidas contra o calendário litúrgico
        let esperadas = [
            2024: (3, 31), 2025: (4, 20), 2026: (4, 5), 2027: (3, 28), 2030: (4, 21),
        ]
        for (ano, (mes, d) ) in esperadas {
            let p = Feriados.pascoa(ano, cal)
            #expect(p == dia(ano, mes, d), "Páscoa de \(ano)")
        }
    }

    @Test func osMoveisSaemDaPascoa() {
        // 2026: Páscoa 5 de abril
        #expect(Feriados.de(dia(2026, 4, 3), cal)?.nome == "Sexta-feira da Paixão")
        #expect(Feriados.de(dia(2026, 2, 17), cal)?.nome == "Carnaval")
        #expect(Feriados.de(dia(2026, 2, 16), cal)?.nome == "Segunda de Carnaval")
        #expect(Feriados.de(dia(2026, 2, 18), cal)?.nome == "Quarta-feira de Cinzas")
        #expect(Feriados.de(dia(2026, 6, 4), cal)?.nome == "Corpus Christi")
        // o domingo de Páscoa não é feriado civil
        #expect(Feriados.de(dia(2026, 4, 5), cal) == nil)
    }

    @Test func osNacionaisFixos() {
        for (mes, d, nome) in [
            (1, 1, "Confraternização Universal"),
            (4, 21, "Tiradentes"),
            (5, 1, "Dia do Trabalho"),
            (9, 7, "Independência"),
            (10, 12, "Nossa Senhora Aparecida"),
            (11, 2, "Finados"),
            (11, 15, "Proclamação da República"),
            (11, 20, "Consciência Negra"),
            (12, 25, "Natal"),
        ] {
            #expect(Feriados.de(dia(2026, mes, d), cal)?.nome == nome)
        }
    }

    @Test func osDeGoiania() {
        #expect(Feriados.de(dia(2026, 10, 24), cal)?.nome == "Aniversário de Goiânia")
        #expect(Feriados.de(dia(2026, 5, 24), cal)?.nome.contains("Auxiliadora") == true)
    }

    /// A Data Magna do estado (Lei estadual 10.460/1988).
    @Test func oEstadualDeGoias() {
        #expect(Feriados.de(dia(2026, 7, 26), cal)?.nome == "Fundação da Cidade de Goiás")
        #expect(Feriados.de(dia(2026, 7, 26), cal)?.facultativo == false)
    }

    /// Corpus Christi é feriado municipal em Goiânia, não só facultativo.
    @Test func corpusChristiNaoEFacultativoAqui() {
        #expect(Feriados.de(dia(2026, 6, 4), cal)?.facultativo == false)
    }

    @Test func diaComumNaoTemRisco() {
        for (mes, d) in [(9, 3), (3, 10), (7, 15), (8, 1)] {
            #expect(!Feriados.eFeriado(dia(2026, mes, d), cal), "\(d)/\(mes)")
        }
    }

    /// Ponto facultativo é ponto facultativo: o nome diz, o risco é o mesmo.
    @Test func oFacultativoSeIdentifica() {
        #expect(Feriados.de(dia(2026, 2, 17), cal)?.facultativo == true)
        #expect(Feriados.de(dia(2026, 12, 25), cal)?.facultativo == false)
    }

    /// A hora do dia não muda o veredito: o feriado é do DIA.
    @Test func aHoraNaoImporta() {
        let meiaNoite = Calendario.hora(0, 0, no: dia(2026, 4, 3), cal)
        let quaseMeiaNoite = Calendario.hora(23, 59, no: dia(2026, 4, 3), cal)
        #expect(Feriados.eFeriado(meiaNoite, cal))
        #expect(Feriados.eFeriado(quaseMeiaNoite, cal))
    }
}
