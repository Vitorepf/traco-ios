import Foundation
import SwiftUI

/// Os feriados do autor (Goiânia, GO): nacionais mais os municipais da cidade.
/// Algoritmo puro, offline, sem EventKit e sem calendário assinado — o §19.2
/// não deixa isto depender de rede, e não depende.
///
/// O que a tela faz com isto é UM risco no número do dia: o dia que não é útil
/// aparece cortado. Nada de cor, nada de ícone, nada de aviso.
nonisolated enum Feriados: Sendable {
    nonisolated struct Feriado: Sendable, Equatable {
        var nome: String
        /// Ponto facultativo na lei federal (Carnaval, Cinzas, Corpus Christi).
        /// O risco é o mesmo — o país para de qualquer jeito —, mas o nome diz.
        var facultativo: Bool = false
    }

    // MARK: tabela

    /// Data fixa, chaveada por `mes * 100 + dia`.
    ///
    /// Nacionais: Leis 662/1949, 6.802/1980, 10.607/2002 e 14.759/2023 (esta
    /// última tornou o 20 de novembro feriado NACIONAL — antes era estadual
    /// ou municipal em parte do país).
    ///
    /// Estadual de Goiás: 26/7, Fundação da Cidade de Goiás — a Data Magna do
    /// estado (Lei estadual 10.460/1988; Bartolomeu Bueno funda o Arraial de
    /// Sant'Anna em 1727, e a data também é da padroeira da capital velha).
    ///
    /// Municipais de Goiânia: 24/5, Nossa Senhora Auxiliadora, padroeira da
    /// cidade; e 24/10, o lançamento da pedra fundamental, em 1933.
    nonisolated static let fixos: [Int: Feriado] = [
        101: Feriado(nome: "Confraternização Universal"),
        421: Feriado(nome: "Tiradentes"),
        501: Feriado(nome: "Dia do Trabalho"),
        524: Feriado(nome: "Nossa Senhora Auxiliadora, padroeira de Goiânia"),
        726: Feriado(nome: "Fundação da Cidade de Goiás"),
        907: Feriado(nome: "Independência"),
        1012: Feriado(nome: "Nossa Senhora Aparecida"),
        1024: Feriado(nome: "Aniversário de Goiânia"),
        1102: Feriado(nome: "Finados"),
        1115: Feriado(nome: "Proclamação da República"),
        1120: Feriado(nome: "Consciência Negra"),
        1225: Feriado(nome: "Natal"),
    ]

    /// Deslocamento em dias a partir do Domingo de Páscoa.
    ///
    /// Corpus Christi é ponto facultativo na lei FEDERAL, mas feriado
    /// MUNICIPAL em Goiânia — e é onde o autor está. Carnaval e Cinzas
    /// continuam facultativos: o país para, a lei não manda.
    nonisolated static let moveis: [Int: Feriado] = [
        -48: Feriado(nome: "Segunda de Carnaval", facultativo: true),
        -47: Feriado(nome: "Carnaval", facultativo: true),
        -46: Feriado(nome: "Quarta-feira de Cinzas", facultativo: true),
        -2: Feriado(nome: "Sexta-feira da Paixão"),
        60: Feriado(nome: "Corpus Christi"),
    ]

    // MARK: consulta

    nonisolated static func de(_ data: Date, _ cal: Calendar = Calendario.gregoriano()) -> Feriado? {
        let c = cal.dateComponents([.year, .month, .day], from: data)
        guard let ano = c.year, let mes = c.month, let dia = c.day else { return nil }
        if let fixo = fixos[mes * 100 + dia] { return fixo }
        guard let pascoa = pascoa(ano, cal) else { return nil }
        let dias = cal.dateComponents([.day], from: pascoa, to: Calendario.inicioDoDia(data, cal)).day
        return dias.flatMap { moveis[$0] }
    }

    nonisolated static func eFeriado(_ data: Date, _ cal: Calendar = Calendario.gregoriano()) -> Bool {
        de(data, cal) != nil
    }

    // MARK: Páscoa

    /// Domingo de Páscoa pelo algoritmo gregoriano anônimo (Meeus/Jones/Butcher).
    /// Aritmética inteira, sem tabela e sem teto de ano.
    nonisolated static func pascoa(_ ano: Int, _ cal: Calendar = Calendario.gregoriano()) -> Date? {
        let a = ano % 19
        let b = ano / 100
        let c = ano % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let soma = h + l - 7 * m + 114
        return cal.date(from: DateComponents(year: ano, month: soma / 31, day: soma % 31 + 1))
            .map { Calendario.inicioDoDia($0, cal) }
    }
}
