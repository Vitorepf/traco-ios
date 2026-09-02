import Foundation
import SwiftUI
import UIKit

@Observable
final class CalendarioAgenda {
    var ancora: Date
    var escala: EscalaCalendario = .dia
    var modo: ModoCalendario = .grelha
    var eventos: [EventoCalendario]
    var prosa = ""
    var ficha: EventoCalendario?
    var menuMais = false
    var ajustes = false
    var ouvir = false

    private let disco: URL
    let cal: Calendar

    init(
        agora: Date = .now,
        cal: Calendar = Calendario.gregoriano(),
        disco: URL = CalendarioDisco.urlPadrao(),
        eventos: [EventoCalendario]? = nil
    ) {
        self.cal = cal
        self.disco = disco
        let dia = Calendario.inicioDoDia(agora, cal)
        self.ancora = dia
        if let eventos {
            self.eventos = eventos
        } else {
            let lidos = CalendarioDisco.carregar(de: disco)
            self.eventos = lidos.isEmpty
                ? CalendarioDisco.semente(ancora: dia, agora: agora, cal)
                : lidos
            if lidos.isEmpty { gravar() }
        }
    }

    var titulo: String { Calendario.titulo(escala: escala, ancora: ancora, cal) }
    var semana: [Date] { Calendario.semana(da: ancora, cal) }
    var grelha: [Date] { Calendario.grelhaDoMes(da: ancora, cal) }
    var meses: [Date] { Calendario.mesesDoAno(da: ancora, cal) }
    var ancoraEHoje: Bool { Calendario.eHoje(ancora, agora: .now, cal) }
    var mesEDeHoje: Bool { Calendario.mesmoMes(ancora, .now, cal) }

    func ir(para nova: EscalaCalendario) {
        let (e, a) = Calendario.ir(para: nova, ancora: ancora)
        escala = e
        ancora = a
    }

    func ir(dia: Date) {
        ancora = Calendario.inicioDoDia(dia, cal)
    }

    func ir(mes: Date) {
        ancora = Calendario.noMes(mes, preservando: ancora, cal)
    }

    func irHoje() {
        ancora = Calendario.irHoje(agora: .now, cal)
    }

    func eventos(no dia: Date) -> [EventoCalendario] {
        Calendario.eventos(eventos, noDia: dia, cal)
    }

    func eventosDaEscala() -> [EventoCalendario] {
        switch escala {
        case .dia: Calendario.eventos(eventos, noDia: ancora, cal)
        case .semana: Calendario.eventos(eventos, naSemanaDe: ancora, cal)
        case .mes: Calendario.eventos(eventos, noMesDe: ancora, cal)
        case .ano:
            eventos
                .filter { cal.component(.year, from: $0.inicio) == cal.component(.year, from: ancora) }
                .sorted { $0.inicio < $1.inicio }
        }
    }

    func adicionarDaProsa() {
        let frase = prosa
        guard let evento = CalendarioFrase.ler(frase, ancora: ancora, agora: .now, cal) else { return }
        eventos.append(evento)
        prosa = ""
        Teclado.recolher()
        gravar()
        Toque.suave()
        ficha = evento
    }

    func guardar(_ evento: EventoCalendario) {
        if let i = eventos.firstIndex(where: { $0.id == evento.id }) {
            eventos[i] = evento
        } else {
            eventos.append(evento)
        }
        gravar()
        ancora = Calendario.inicioDoDia(evento.inicio, cal)
    }

    func apagar(_ id: UUID) {
        eventos.removeAll { $0.id == id }
        if ficha?.id == id { ficha = nil }
        gravar()
    }

    func colar() {
        if let texto = UIPasteboard.general.string, !texto.isEmpty {
            prosa = texto
            Toque.leve()
        }
    }

    private func gravar() {
        CalendarioDisco.gravar(eventos, em: disco)
    }
}
