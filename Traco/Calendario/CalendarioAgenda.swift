import Foundation
import SwiftUI
import UIKit

@Observable
final class CalendarioAgenda {
    var ancora: Date
    var escala: EscalaCalendario = .dia
    var modo: ModoCalendario = .grelha
    var eventos: [EventoCalendario]
    /// As deixas das notas ("Se" com hora), lidas do modelo pela view. Não
    /// vão ao disco do calendário: a nota é a dona.
    var deixas: [EventoCalendario] = []
    /// Ações confirmadas no Trabalho, somente para leitura nesta agenda.
    var acoesDosTrabalhos: [EventoCalendario] = []
    var aoAbrirTrabalho: ((UUID, UUID) -> Void)? { didSet { abrirAcaoDaNotificacao() } }
    /// Tocar numa deixa abre a nota; a raiz liga isto à Sessao.
    var aoAbrirNota: ((UUID) -> Void)?
    /// A3: os compromissos do iPhone, só leitura. A view os alimenta.
    var doSistema: [EventoCalendario] = []
    /// O que se abre quando se toca num compromisso que não é nosso.
    var fichaDoSistema: EventoCalendario?
    var prosa = ""
    var ficha: EventoCalendario?
    var menuMais = false
    /// O que o disco recusou ou o arquivo que não abriu. Some sozinho.
    var toast: String?
    /// ADR 04a: o estado dos avisos do iPhone, lido quando a ficha abre. A
    /// tela não promete o que o sistema não vai cumprir.
    var estadoDosAvisos: Avisos.Estado = .concedido
    /// O que aconteceu no último agendamento — a ficha conta, não engole.
    var ultimoAviso: ResultadoDoAviso?
    /// O toast em cena tem volta pelos Ajustes (permissão negada).
    var toastComAjustes = false
    /// A escala anterior decide a direção do desdobramento.
    private(set) var escalaAnterior: EscalaCalendario = .dia

    private let disco: URL
    private(set) var cal: Calendar
    private var toastTask: Task<Void, Never>?
    /// ADR 05n: o toque na notificação da ação chega pela rota do compromisso
    /// (abrir o calendário); se o calendário já está na frente, é aqui que se ouve.
    private var ouvinteDaAcao: (any NSObjectProtocol)?

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
        } else {
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
        ouvinteDaAcao = NotificationCenter.default.addObserver(
            forName: Revisoes.abrirCompromisso, object: nil, queue: .main
        ) { [weak self] _ in MainActor.assumeIsolated { self?.abrirAcaoDaNotificacao() } }
    }

    var titulo: String { Calendario.titulo(escala: escala, ancora: ancora, cal) }
    var semana: [Date] { Calendario.semana(da: ancora, cal) }
    var grelha: [Date] { Calendario.grelhaDoMes(da: ancora, cal) }
    var meses: [Date] { Calendario.mesesDoAno(da: ancora, cal) }
    /// As SÉRIES e as deixas, como estão guardadas. Quem desenha usa `porDia`
    /// ou `eventos(no:)`, que expandem as repetições.
    var todos: [EventoCalendario] { eventos + deixas + doSistema + acoesDosTrabalhos }

    /// O intervalo que a escala atual mostra — é dentro dele que as séries
    /// viram ocorrências. O mês usa a grelha de 42 células (as sobras contam).
    private var faixaVisivel: (Date, Date) {
        switch escala {
        case .dia:
            let d = Calendario.inicioDoDia(ancora, cal)
            return (d, d)
        case .semana:
            let dias = semana
            return (dias.first ?? ancora, dias.last ?? ancora)
        case .mes:
            let g = grelha
            return (g.first ?? ancora, g.last ?? ancora)
        case .ano:
            let ano = cal.component(.year, from: ancora)
            let jan = cal.date(from: DateComponents(year: ano, month: 1, day: 1)) ?? ancora
            let dez = cal.date(from: DateComponents(year: ano, month: 12, day: 31)) ?? ancora
            return (jan, dez)
        }
    }

    /// A faixa que o leitor do sistema deve carregar. É a visível — com um dia
    /// de folga em cada ponta, porque a grade do mês mostra sobras.
    var faixaParaOSistema: (Date, Date) {
        let (de, a) = faixaVisivel
        return (cal.date(byAdding: .day, value: -1, to: de) ?? de,
                cal.date(byAdding: .day, value: 1, to: a) ?? a)
    }

    var porDia: [Date: [EventoCalendario]] {
        let (de, a) = faixaVisivel
        return Calendario.porDia(Calendario.ocorrencias(todos, de: de, a: a, cal), cal)
    }

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
        Calendario.eventos(Calendario.ocorrencias(todos, de: dia, a: dia, cal), noDia: dia, cal)
    }

    func eventosDaEscala() -> [EventoCalendario] {
        let (de, a) = faixaVisivel
        let vivos = Calendario.ocorrencias(todos, de: de, a: a, cal)
        switch escala {
        case .dia: return Calendario.eventos(vivos, noDia: ancora, cal)
        case .semana: return Calendario.eventos(vivos, naSemanaDe: ancora, cal)
        case .mes: return Calendario.eventos(vivos, noMesDe: ancora, cal)
        case .ano:
            return vivos
                .filter { cal.component(.year, from: $0.inicio) == cal.component(.year, from: ancora) }
                .sorted { $0.inicio < $1.inicio }
        }
    }

    isolated deinit {
        if let ouvinteDaAcao { NotificationCenter.default.removeObserver(ouvinteDaAcao) }
    }

    /// A mesma rota do toque na projeção: quem abre Trabalhos revalida a origem.
    func abrirAcaoDaNotificacao() {
        guard let (trabalho, acao) = Revisoes.acaoDaNotificacao, let aoAbrirTrabalho else { return }
        Revisoes.acaoDaNotificacao = nil
        aoAbrirTrabalho(trabalho, acao)
    }

    /// Compromisso abre a ficha; deixa abre a nota que a criou; o que veio do
    /// iPhone abre uma ficha só de leitura — não é nosso para editar.
    func abrir(_ evento: EventoCalendario) {
        if let trabalhoID = evento.origemTrabalho {
            aoAbrirTrabalho?(trabalhoID, evento.id)
            return
        }
        if let origem = evento.origem {
            aoAbrirNota?(origem)
            return
        }
        if evento.doSistema {
            fichaDoSistema = evento
            return
        }
        // ocorrência de uma série: a ficha edita a SÉRIE, não a cópia do dia —
        // guardar a cópia moveria o início da série para o dia em que se tocou
        ficha = eventos.first { $0.id == evento.id } ?? evento
    }

    // MARK: escrever — o gesto não mente se o disco recusa

    /// Da prosa ao disco. Se o disco recusa, a prosa fica onde estava.
    func adicionarDaProsa(agora: Date = .now) {
        let frase = prosa
        // pergunta, não marcação: o app responde indo até o dia
        if let (dia, nova) = CalendarioFrase.consulta(frase, ancora: ancora, agora: agora, cal) {
            prosa = ""
            Teclado.recolher()
            Toque.selecao()
            ancora = dia
            ir(para: nova)
            return
        }
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
        avisar(evento, anunciar: false) // a ficha abre em seguida e diz melhor
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
        guard evento.editavel else { return }
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
        avisar(e)
        ancora = Calendario.inicioDoDia(e.inicio, cal)
    }

    func apagar(_ id: UUID) {
        let antes = eventos
        eventos.removeAll { $0.id == id }
        guard gravar() else {
            eventos = antes
            return
        }
        // o aviso morre com o compromisso: alarme de coisa apagada é o pior
        // tipo de mentira que um calendário pode contar
        Revisoes.cancelarCompromisso(id: id)
        publicarProximo()
        if ficha?.id == id { ficha = nil }
    }

    func apagarTudo() {
        let antes = eventos
        eventos = []
        guard gravar() else {
            eventos = antes
            return
        }
        for e in antes { Revisoes.cancelarCompromisso(id: e.id) }
        publicarProximo()
        ficha = nil
    }

    func colar() {
        if let texto = UIPasteboard.general.string, !texto.isEmpty {
            prosa = texto
            Toque.leve()
        }
    }

    /// ADR 2026-09-03d: o que se marca, avisa. Deixa de nota não passa por
    /// aqui — a nota é a dona dela e já tem o seu próprio gatilho.
    ///
    /// ADR 04a: o resultado VOLTA. Agendar e não contar foi o defeito.
    private func avisar(_ e: EventoCalendario, anunciar: Bool = true) {
        // O widget e a Ilha vêm PRIMEIRO, e síncronos. Publicar depois do
        // `await` do agendamento deixava a tela bloqueada refém do diálogo de
        // permissão: se ninguém responde ao prompt do iOS, a continuação não
        // volta e o "próximo" nunca era escrito (visto no simulador, 04/set —
        // o App Group tinha só o Destaque). Superfície não espera diálogo.
        publicarProximo()
        guard e.editavel else { return }
        Task {
            let r = await Revisoes.agendarCompromisso(e, cal: cal)
            ultimoAviso = r
            estadoDosAvisos = await Avisos.estado()
            switch r {
            case .semPermissao:
                mostrar("marquei — mas os avisos do Traço estão desligados no iPhone.",
                        comAjustes: true)
            case .semEspaco:
                mostrar("o iPhone guarda \(Avisos.teto) avisos e já estão todos. este ficou sem alarme.")
            case .passou:
                mostrar("marquei. a hora do aviso já passou, então não vai tocar.")
            case .agendado:
                // peak-end: o fim do percurso devolve a promessa, não silêncio.
                // Só quando não há ficha em cena para dizê-la melhor.
                if anunciar, let promessa = Aviso.promessa(de: e, cal, manha: Ancora.hora(.manha)) {
                    mostrar("marcado · o aviso toca \(promessa)")
                }
            case .semAviso:
                if anunciar { mostrar("marcado · sem aviso, como você pediu") }
            }
            // e a superfície conta a verdade: alarme recusado não vira sino
            publicarProximo(mudo: r.vaiTocar ? nil : e.id)
        }
    }

    /// ADR 04a: o compromisso existe FORA do app — widget, tela bloqueada e
    /// Ilha. Toda escrita no calendário republica o próximo.
    func publicarProximo(agora: Date = .now, mudo: UUID? = nil) {
        ProximoCompromisso.publicar(eventos + doSistema, cal: cal, agora: agora, mudo: mudo)
    }

    /// Lido quando a ficha abre: o estado do sistema muda fora do app.
    func lerEstadoDosAvisos() {
        Task { estadoDosAvisos = await Avisos.estado() }
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

    func mostrar(_ msg: String, comAjustes: Bool = false) {
        toast = msg
        toastComAjustes = comAjustes
        AccessibilityNotification.Announcement(msg).post()
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                self?.toast = nil
                self?.toastComAjustes = false
            }
        }
    }
}
