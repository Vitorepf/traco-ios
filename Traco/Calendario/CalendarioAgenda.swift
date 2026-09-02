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
    /// O que o disco recusou ou o arquivo que não abriu. Some sozinho.
    var toast: String?
    /// A escala anterior decide a direção do desdobramento.
    private(set) var escalaAnterior: EscalaCalendario = .dia

    private let disco: URL
    private(set) var cal: Calendar
    private var toastTask: Task<Void, Never>?

    static let chaveSegunda = "calendario-segunda-primeiro"

    init(
        agora: Date = .now,
        cal: Calendar? = nil,
        disco: URL = CalendarioDisco.urlPadrao(),
        eventos: [EventoCalendario]? = nil
    ) {
        let segunda = UserDefaults.standard.bool(forKey: Self.chaveSegunda)
        let c = cal ?? Calendario.gregoriano(segundaPrimeiro: segunda)
        self.cal = c
        self.disco = disco
        self.ancora = Calendario.inicioDoDia(agora, c)
        if let eventos {
            self.eventos = eventos
            return
        }
        switch CalendarioDisco.carregar(de: disco) {
        case .semArquivo:
            self.eventos = []
        case .eventos(let lidos):
            self.eventos = lidos
        case .corrompido:
            // nunca por cima: o arquivo é do autor
            self.eventos = []
            CalendarioDisco.porDeLado(disco)
            mostrar("o arquivo do calendário não abriu. guardei uma cópia ao lado e comecei vazio.")
        }
    }

    var titulo: String { Calendario.titulo(escala: escala, ancora: ancora, cal) }
    var semana: [Date] { Calendario.semana(da: ancora, cal) }
    var grelha: [Date] { Calendario.grelhaDoMes(da: ancora, cal) }
    var meses: [Date] { Calendario.mesesDoAno(da: ancora, cal) }
    var porDia: [Date: [EventoCalendario]] { Calendario.porDia(eventos, cal) }

    func ancoraEHoje(_ agora: Date) -> Bool { Calendario.eHoje(ancora, agora: agora, cal) }

    var segundaPrimeiro: Bool {
        get { cal.firstWeekday == 2 }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.chaveSegunda)
            cal = Calendario.gregoriano(fuso: cal.timeZone, segundaPrimeiro: newValue)
        }
    }

    func ir(para nova: EscalaCalendario) {
        guard nova != escala else { return }
        escalaAnterior = escala
        let (e, a) = Calendario.ir(para: nova, ancora: ancora)
        escala = e
        ancora = a
    }

    /// Aproximar é ir do ano para o dia: a escala nova cresce; afastar recua.
    var aproximando: Bool {
        indice(escala) < indice(escalaAnterior)
    }

    private func indice(_ e: EscalaCalendario) -> Int {
        EscalaCalendario.allCases.firstIndex(of: e) ?? 0
    }

    func ir(dia: Date) {
        ancora = Calendario.inicioDoDia(dia, cal)
    }

    func ir(mes: Date) {
        ancora = Calendario.noMes(mes, preservando: ancora, cal)
    }

    func irHoje(agora: Date = .now) {
        ancora = Calendario.irHoje(agora: agora, cal)
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

    // MARK: escrever — o gesto não mente se o disco recusa

    /// Da prosa ao disco. Se o disco recusa, a prosa fica onde estava.
    func adicionarDaProsa(agora: Date = .now) {
        let frase = prosa
        guard let evento = CalendarioFrase.ler(
            frase, ancora: ancora, agora: agora, cal,
            manha: Ancora.hora(.manha), tarde: Ancora.hora(.tarde), noite: Ancora.hora(.noite)
        ) else {
            if !frase.trimmingCharacters(in: .whitespaces).isEmpty {
                mostrar("faltou o quê: escreva o compromisso, com dia e hora se quiser.")
            }
            return
        }
        eventos.append(evento)
        guard gravar() else {
            eventos.removeAll { $0.id == evento.id }
            return
        }
        prosa = ""
        Teclado.recolher()
        Toque.suave()
        ancora = Calendario.inicioDoDia(evento.inicio, cal)
        ficha = evento
    }

    /// Um compromisso em branco no dia âncora, para quem prefere a ficha.
    func novoEmBranco(agora: Date = .now) {
        let h = Calendario.eHoje(ancora, agora: agora, cal)
            ? min(22, cal.component(.hour, from: agora) + 1)
            : 9
        let inicio = Calendario.hora(h, 0, no: ancora, cal)
        ficha = EventoCalendario(titulo: "", inicio: inicio, fim: inicio.addingTimeInterval(3600))
    }

    /// Guarda a ficha. Título vazio não entra: um compromisso sem nome não é nada.
    func guardar(_ evento: EventoCalendario) {
        var e = evento
        e.titulo = e.titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.titulo.isEmpty else {
            if eventos.contains(where: { $0.id == e.id }) { apagar(e.id) }
            return
        }
        let antes = eventos
        if let i = eventos.firstIndex(where: { $0.id == e.id }) {
            eventos[i] = e
        } else {
            eventos.append(e)
        }
        guard gravar() else {
            eventos = antes
            return
        }
        ancora = Calendario.inicioDoDia(e.inicio, cal)
    }

    func apagar(_ id: UUID) {
        let antes = eventos
        eventos.removeAll { $0.id == id }
        guard gravar() else {
            eventos = antes
            return
        }
        if ficha?.id == id { ficha = nil }
    }

    func apagarTudo() {
        let antes = eventos
        eventos = []
        guard gravar() else {
            eventos = antes
            return
        }
        ficha = nil
    }

    func colar() {
        if let texto = UIPasteboard.general.string, !texto.isEmpty {
            prosa = texto
            Toque.leve()
        }
    }

    @discardableResult
    private func gravar() -> Bool {
        do {
            try CalendarioDisco.gravar(eventos, em: disco)
            return true
        } catch {
            mostrar("o disco recusou. o calendário ficou como estava.")
            Toque.aviso()
            return false
        }
    }

    func mostrar(_ msg: String) {
        toast = msg
        AccessibilityNotification.Announcement(msg).post()
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled { self?.toast = nil }
        }
    }
}
