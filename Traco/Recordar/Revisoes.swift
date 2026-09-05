import Foundation
import UserNotifications

/// Recordar como ritual (COLHEITA): uma fila por dia, uma notificação na hora
/// que o autor escolhe, uma nota por tela, sem contagem. A escada responde —
/// silêncio avança; um toque em "cobrar antes" volta ao primeiro degrau.
enum Revisoes {
    nonisolated static let escada = [3, 7, 21, 60, 180, 365]
    nonisolated static let intervaloDias = 3

    nonisolated static func dias(nivel: Int) -> Int {
        escada[max(0, min(nivel, escada.count - 1))]
    }

    static var hora: Int {
        get { (UserDefaults.standard.object(forKey: "horaRecordar") as? Int) ?? 8 }
        set {
            UserDefaults.standard.set(max(0, min(23, newValue)), forKey: "horaRecordar")
            agendarFilaDiaria()
        }
    }

    static func nivel(_ uuid: UUID) -> Int {
        niveis()[uuid.uuidString] ?? 0
    }

    /// Tocar Revelar = revisão cumprida: o silêncio sobe o degrau.
    static func registrarCumprida(_ uuid: UUID, agora: Date = .now) {
        var d = niveis()
        d[uuid.uuidString] = min((d[uuid.uuidString] ?? 0) + 1, escada.count - 1)
        gravarNiveis(d)
        var c = contas()
        c[uuid.uuidString] = (c[uuid.uuidString] ?? 0) + 1
        UserDefaults.standard.set(c, forKey: "revisaoConta")
        marcarProxima(uuid, daquiA: dias(nivel: d[uuid.uuidString] ?? 0), agora: agora)
    }

    /// Um toque cobra antes: a escada volta ao 3.
    static func cobrarAntes(_ uuid: UUID, agora: Date = .now) {
        var d = niveis()
        d[uuid.uuidString] = 0
        gravarNiveis(d)
        marcarProxima(uuid, daquiA: dias(nivel: 0), agora: agora)
    }

    /// "Hoje não." Empurra para amanhã e NÃO mexe na escada: adiar não é
    /// falhar nem acertar — é a hora errada. Sem isto, quem abria a
    /// notificação num momento ruim só tinha duas saídas: fazer agora, ou
    /// sair — e sair não reagendava nada, então a nota sumia da fila.
    static func adiar(_ uuid: UUID, agora: Date = .now) {
        marcarProxima(uuid, daquiA: 1, agora: agora)
    }

    static func contagem(_ uuid: UUID) -> Int {
        contas()[uuid.uuidString] ?? 0
    }

    /// Há o que lembrar: o alvo do rito, não a voz solta. Destilar sem corte
    /// e Se sem Então não entram na fila — Recordar vazio é mentira.
    nonisolated static func podeAgendar(gesto: Gesto?, trancada: Bool,
                                        texto: String, campos: [String: String] = [:]) -> Bool {
        guard !trancada, gesto != .expressiva else { return false }
        return RitualRecordar.de(gesto).temAlvo(texto: texto, campos: campos)
    }

    nonisolated static func proximaRevisao(aPartirDe data: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: intervaloDias, to: data)
            ?? data.addingTimeInterval(TimeInterval(intervaloDias) * 86400)
    }

    static func proximaData(_ uuid: UUID) -> Date? {
        guard let t = proximas()[uuid.uuidString] else { return nil }
        return Date(timeIntervalSince1970: t)
    }

    /// Grava o vencimento. A notificação é UMA, diária — nunca por nota.
    static func agendar(uuid: UUID, criadaEm: Date, gesto: Gesto?, trancada: Bool,
                        texto: String, campos: [String: String] = [:],
                        aoNegar: @escaping @Sendable () -> Void = {}) {
        guard podeAgendar(gesto: gesto, trancada: trancada, texto: texto, campos: campos) else { return }
        if proximaData(uuid) == nil {
            marcarProxima(uuid, daquiA: dias(nivel: nivel(uuid)), agora: max(criadaEm, .now))
        }
        pedirPermissao(aoNegar: aoNegar)
        agendarFilaDiaria()
    }

    static func filaDoDia(notas: [Nota], agora: Date = .now) -> [Nota] {
        let hoje = Calendar.current.startOfDay(for: agora)
        return notas
            .filter { nota in
                guard podeAgendar(gesto: nota.gesto, trancada: nota.fechada,
                                  texto: nota.texto, campos: nota.campos) else {
                    return false
                }
                let vencimento = proximaData(nota.uuid)
                    ?? Calendar.current.date(byAdding: .day, value: dias(nivel: nivel(nota.uuid)),
                                             to: nota.criadaEm)
                    ?? nota.criadaEm
                return Calendar.current.startOfDay(for: vencimento) <= hoje
            }
            .sorted { $0.criadaEm < $1.criadaEm }
    }

    /// `async/await` em vez de closure: a versão com `getNotificationSettings`
    /// lia `hora` (isolada no MainActor) e capturava o `centro` (não-Sendable)
    /// dentro de uma closure `@Sendable` — corrida de dados de verdade, não
    /// ruído de migração.
    /// Quantos dias à frente a fila é enumerada quando há silêncio no caminho.
    /// Catorze: cobre a viagem típica e cabe no orçamento (ADR 04b).
    nonisolated static let janelaDaFila = 14

    nonisolated static func idsDaFila() -> [String] {
        ["fila-do-dia"] + (0..<janelaDaFila).map { "fila-dia-\($0)" }
    }

    /// ADR 04e — a fila do dia respeita as férias.
    ///
    /// Sem silêncio no caminho, UMA notificação repetente basta e custa um slot
    /// do orçamento. Com férias (ou feriado, se o autor ligou), o iOS não sabe
    /// pular dia nenhum num gatilho repetente — então a fila é enumerada dia a
    /// dia na janela, e o arranque do app a re-arma.
    static func agendarFilaDiaria() {
        let h = hora // lido AQUI, no MainActor, antes de qualquer salto
        let repetente = !Ferias.haSilencio(de: .now, dias: janelaDaFila)
        let dias = repetente ? [] : Ferias.diasQueCobram(de: .now, dias: janelaDaFila)
        let ids = idsDaFila()
        Task {
            let centro = UNUserNotificationCenter.current()
            centro.removePendingNotificationRequests(withIdentifiers: ids)
            guard await autorizada() else { return }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Recordar"
            conteudo.body = ""
            conteudo.userInfo = ["fila": true]
            guard repetente else {
                // tudo calado na janela: silêncio de verdade, sem nenhum aviso
                guard !dias.isEmpty else { return }
                // ADR 04b: a fila enumerada também respeita o teto de 64. Sem
                // isto, ligar as férias com a agenda cheia faria o iOS descartar
                // os dias que não coubessem — em silêncio, que é o defeito que
                // a 04a existe para não repetir.
                let cabem = await Avisos.livres(reusando: Set(ids))
                let cal = Calendario.gregoriano()
                for (i, dia) in dias.prefix(cabem).enumerated() {
                    var c = cal.dateComponents([.year, .month, .day], from: dia)
                    c.hour = h
                    c.minute = 0
                    guard let quando = cal.date(from: c), quando > .now else { continue }
                    try? await centro.add(UNNotificationRequest(
                        identifier: "fila-dia-\(i)", content: conteudo,
                        trigger: UNCalendarNotificationTrigger(dateMatching: c, repeats: false)))
                }
                return
            }
            var comps = DateComponents()
            comps.hour = h
            comps.minute = 0
            try? await centro.add(UNNotificationRequest(
                identifier: "fila-do-dia", content: conteudo,
                trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)))
        }
    }

    /// Para o Perfil dizer a verdade sobre os avisos, sem pedir nada.
    static func autorizadaParaAvisar() async -> Bool { await autorizada() }

    /// Já autorizada a avisar? Nunca PEDE — quem pede é `pedirPermissao`.
    private static func autorizada() async -> Bool {
        let estado = await UNUserNotificationCenter.current().notificationSettings()
        return estado.authorizationStatus == .authorized
            || estado.authorizationStatus == .provisional
    }

    // MARK: - A revisão da semana (ADR q): domingo, na hora da noite do autor

    static let chaveRevisaoSemanal = "revisao-semanal-ligada"

    static var revisaoSemanalLigada: Bool {
        UserDefaults.standard.object(forKey: chaveRevisaoSemanal) as? Bool ?? true
    }

    static func agendarRevisaoSemanal() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["revisao-semanal"])
        // ADR 04e: domingo à noite, de férias, é domingo à noite de férias
        guard revisaoSemanalLigada, !Ferias.vigente() else { return }
        let noite = Ancora.hora(.noite)
        Task {
            guard await autorizada() else { return }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Esta semana"
            conteudo.body = ""
            conteudo.userInfo = ["semana": true]
            var comps = DateComponents()
            comps.weekday = 1 // domingo
            comps.hour = noite
            comps.minute = 0
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            try? await UNUserNotificationCenter.current().add(
                UNNotificationRequest(identifier: "revisao-semanal", content: conteudo, trigger: gatilho))
        }
    }

    // MARK: - Aviso do Se (título da nota, sem corpo)

    static func agendarGatilho(uuid: UUID, titulo: String, em data: Date) {
        guard data > .now else { return }
        Task {
            // uma porta só para a permissão (ADR 04a/04b): pedir em três
            // lugares diferentes, com opções diferentes, fazia o primeiro que
            // rodasse decidir o que o app pode fazer para sempre
            guard await Avisos.pedirSePreciso() == .concedido else { return }
            let centro = UNUserNotificationCenter.current()
            let conteudo = UNMutableNotificationContent()
            conteudo.title = titulo
            conteudo.body = ""
            conteudo.interruptionLevel = .timeSensitive // o "Se" é do autor
            conteudo.userInfo = ["uuid": uuid.uuidString, "gatilho": true]
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: data)
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await centro.add(UNNotificationRequest(
                identifier: "gatilho-\(uuid.uuidString)", content: conteudo, trigger: gatilho))
        }
    }

    static func cancelarGatilho(uuid: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["gatilho-\(uuid.uuidString)"])
    }

    // MARK: - Aviso do compromisso (ADR 2026-09-03d · superfície na 04a)

    /// Namespace próprio: o id de um evento e o uuid de uma nota são os dois
    /// UUID, e um cancelar não pode alcançar o aviso do outro.
    nonisolated static func idDoCompromisso(_ id: UUID, weekday: Int? = nil) -> String {
        weekday.map { "compromisso-\(id.uuidString)-\($0)" } ?? "compromisso-\(id.uuidString)"
    }

    /// O compromisso avisa na hora que o AUTOR escolheu, e o resultado volta
    /// para a tela dizer a verdade (ADR 04a: função que ele não vê não existe).
    ///
    /// Série vira UMA notificação semanal por dia da semana, repetindo: o
    /// sistema cobra sozinho, sem o app reagendar toda semana. Dia inteiro
    /// avisa na âncora da manhã do autor, não à meia-noite.
    @discardableResult
    static func agendarCompromisso(_ e: EventoCalendario,
                                   cal: Calendar = Calendario.gregoriano(),
                                   manha: Int = Ancora.hora(.manha),
                                   agora: Date = .now) async -> ResultadoDoAviso {
        guard e.editavel else { return .semAviso }
        cancelarCompromisso(id: e.id)
        let corte = e.titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !corte.isEmpty else { return .semAviso }
        guard let quando = Aviso.instante(de: e, cal, manha: manha) else { return .semAviso }
        let estado = await Avisos.pedirSePreciso()
        guard estado == .concedido else { return .semPermissao }

        let ids = e.repete ? e.repeteEm.map { idDoCompromisso(e.id, weekday: $0) } : [idDoCompromisso(e.id)]
        guard await Avisos.cabem(ids.count, reusando: Set(ids)) else { return .semEspaco }

        let conteudo = UNMutableNotificationContent()
        conteudo.title = corte
        conteudo.body = ""
        conteudo.sound = .default
        // ADR 04e: o que o AUTOR marcou atravessa o Foco. O que o app inventou
        // de cobrar (fila, revisão, série) fica no nível normal e espera —
        // é a mesma linha das férias, aplicada ao silêncio do sistema.
        conteudo.interruptionLevel = .timeSensitive
        conteudo.userInfo = ["compromisso": e.id.uuidString]
        let centro = UNUserNotificationCenter.current()

        guard !e.repete else {
            // a antecedência pode empurrar o aviso para a véspera: o dia da
            // semana anda junto, senão "1 h antes" de uma segunda 00h30 tocaria
            // na segunda seguinte, 23h30 — seis dias atrasado
            let minutosDoDia = cal.component(.hour, from: quando) * 60 + cal.component(.minute, from: quando)
            let recuo = Aviso.diasDeRecuo(inicio: e.inicio, aviso: quando, cal)
            for weekday in e.repeteEm {
                var c = DateComponents()
                c.weekday = ((weekday - 1 - recuo) % 7 + 7) % 7 + 1
                c.hour = minutosDoDia / 60
                c.minute = minutosDoDia % 60
                try? await centro.add(UNNotificationRequest(
                    identifier: idDoCompromisso(e.id, weekday: weekday),
                    content: conteudo,
                    trigger: UNCalendarNotificationTrigger(dateMatching: c, repeats: true)))
            }
            return .agendado(quando)
        }
        // uma vez só: o que já passou não avisa
        guard quando > agora else { return .passou }
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: quando)
        try? await centro.add(UNNotificationRequest(
            identifier: idDoCompromisso(e.id), content: conteudo,
            trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)))
        return .agendado(quando)
    }

    static func cancelarCompromisso(id: UUID) {
        let ids = [idDoCompromisso(id)] + (1...7).map { idDoCompromisso(id, weekday: $0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Série da expressiva (notificação sem conteúdo → página)

    static func agendarSerie(serie: UUID, dia: Int, em quando: Date) {
        // ADR 04e: a série de quatro dias não MORRE nas férias — ela espera o
        // primeiro dia que cobra. O método é de quatro sessões, não de quatro
        // datas (e uma sessão de escrita expressiva na praia não é o método).
        let data = Ferias.primeiroDiaQueCobra(aPartirDe: quando)
        guard (2...4).contains(dia), data > .now else { return }
        Task {
            guard await Avisos.pedirSePreciso() == .concedido else { return }
            let centro = UNUserNotificationCenter.current()
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Expressiva"
            conteudo.body = ""
            conteudo.userInfo = ["serie": serie.uuidString, "dia": dia]
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour], from: data)
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await centro.add(UNNotificationRequest(
                identifier: "serie-\(serie.uuidString)-\(dia)",
                content: conteudo, trigger: gatilho))
        }
    }

    static func proximoDiaDaSerie(aPartirDe agora: Date = .now) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: agora)
        comps.hour = Ancora.hora(.manha)
        comps.minute = 0
        let hoje = Calendar.current.date(from: comps) ?? agora
        return Calendar.current.date(byAdding: .day, value: 1, to: hoje)
            ?? hoje.addingTimeInterval(86400)
    }

    /// V3: a série de quatro dias morria no primeiro esquecimento — só o
    /// FECHO agendava o dia seguinte, e quem ignorasse a notificação nunca
    /// mais ouvia falar dela. No arranque, toda série viva que perdeu o aviso
    /// reagenda para amanhã. O método Pennebaker é de quatro sessões; uma
    /// série que morre no dia 2 não entrega o método.
    static func rearmarSeries(notas: [Nota], agora: Date = .now) async {
        let vivas = notas.filter {
            $0.gesto == .expressiva && $0.serieUUID != nil
                && $0.diaDaSerie >= 1 && $0.diaDaSerie < 4
        }
        guard !vivas.isEmpty else { return }
        let pendentes = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let jaAgendadas = Set(pendentes.map(\.identifier))
        // por série, o dia mais adiantado é o que conta
        var maior: [UUID: Int] = [:]
        for n in vivas {
            guard let s = n.serieUUID else { continue }
            maior[s] = max(maior[s] ?? 0, n.diaDaSerie)
        }
        for (serie, dia) in maior {
            let proximo = dia + 1
            guard proximo <= 4 else { continue }
            guard !jaAgendadas.contains("serie-\(serie.uuidString)-\(proximo)") else { continue }
            agendarSerie(serie: serie, dia: proximo, em: proximoDiaDaSerie(aPartirDe: agora))
        }
    }

    static func cancelarSerie(serie: UUID) {
        let ids = (2...4).map { "serie-\(serie.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Toque na notificação

    nonisolated static func uuidDaResposta(_ userInfo: [AnyHashable: Any]) -> UUID? {
        (userInfo["uuid"] as? String).flatMap(UUID.init(uuidString:))
    }

    static let abrirRevisao = Notification.Name("traco.abrirRevisao")
    static let abrirFila = Notification.Name("traco.abrirFila")
    static let abrirSerie = Notification.Name("traco.abrirSerie")
    static let abrirGatilho = Notification.Name("traco.abrirGatilho")
    static let abrirSemana = Notification.Name("traco.abrirSemana")
    /// ADR 04a: o aviso do compromisso TOCA e o toque no banner tem de levar a
    /// algum lugar. Ia para lugar nenhum — o `userInfo` não batia com rota
    /// nenhuma e o `didReceive` caía no `return` mudo.
    static let abrirCompromisso = Notification.Name("traco.abrirCompromisso")

    final class Delegate: NSObject, UNUserNotificationCenterDelegate {
        static let compartilhado = Delegate()

        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse) async {
            let info = response.notification.request.content.userInfo
            await MainActor.run {
                if info["fila"] != nil {
                    NotificationCenter.default.post(name: Revisoes.abrirFila, object: nil)
                    return
                }
                if info["semana"] != nil {
                    NotificationCenter.default.post(name: Revisoes.abrirSemana, object: nil)
                    return
                }
                if let raw = info["serie"] as? String, let serie = UUID(uuidString: raw) {
                    let dia = info["dia"] as? Int ?? 2
                    NotificationCenter.default.post(
                        name: Revisoes.abrirSerie, object: serie, userInfo: ["dia": dia])
                    return
                }
                if let raw = info["compromisso"] as? String,
                   let id = UUID(uuidString: raw) {
                    NotificationCenter.default.post(name: Revisoes.abrirCompromisso, object: id)
                    return
                }
                if info["gatilho"] != nil, let uuid = Revisoes.uuidDaResposta(info) {
                    NotificationCenter.default.post(name: Revisoes.abrirGatilho, object: uuid)
                    return
                }
                guard let uuid = Revisoes.uuidDaResposta(info) else { return }
                NotificationCenter.default.post(name: Revisoes.abrirRevisao, object: uuid)
            }
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            [.banner]
        }
    }

    static func cancelar(uuid: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["revisao-\(uuid.uuidString)"])
        var p = proximas()
        p.removeValue(forKey: uuid.uuidString)
        UserDefaults.standard.set(p, forKey: "revisaoProxima")
    }

    // MARK: - Disco

    private static func niveis() -> [String: Int] {
        (UserDefaults.standard.dictionary(forKey: "revisaoNivel") as? [String: Int]) ?? [:]
    }

    private static func gravarNiveis(_ d: [String: Int]) {
        UserDefaults.standard.set(d, forKey: "revisaoNivel")
    }

    private static func contas() -> [String: Int] {
        (UserDefaults.standard.dictionary(forKey: "revisaoConta") as? [String: Int]) ?? [:]
    }

    private static func proximas() -> [String: TimeInterval] {
        (UserDefaults.standard.dictionary(forKey: "revisaoProxima") as? [String: TimeInterval]) ?? [:]
    }

    private static func marcarProxima(_ uuid: UUID, daquiA dias: Int, agora: Date) {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: agora)
        comps.day = (comps.day ?? 0) + dias
        comps.hour = hora
        comps.minute = 0
        let quando = cal.date(from: comps) ?? agora.addingTimeInterval(TimeInterval(dias) * 86400)
        var p = proximas()
        p[uuid.uuidString] = quando.timeIntervalSince1970
        UserDefaults.standard.set(p, forKey: "revisaoProxima")
    }

    private static func pedirPermissao(aoNegar: @escaping @Sendable () -> Void) {
        Task {
            let ok = await Avisos.pedirSePreciso() == .concedido
            guard !ok else { return }
            let d = UserDefaults.standard
            guard !d.bool(forKey: "avisoRevisoesNegadas") else { return }
            d.set(true, forKey: "avisoRevisoesNegadas")
            aoNegar()
        }
    }
}


/// ADR 2026-09-04a — o que aconteceu com o aviso, em tipo, para a tela poder
/// contar. Silêncio de motor foi exatamente o defeito que esta ADR nomeia.
nonisolated enum ResultadoDoAviso: Equatable, Sendable {
    /// Vai tocar nesta hora — a promessa que a ficha mostra.
    case agendado(Date)
    /// O autor desligou o aviso deste compromisso. Silêncio pedido não é falha.
    case semAviso
    /// O iPhone está com os avisos do Traço desligados (ADR 03e: não é beco —
    /// a tela diz, e leva aos Ajustes).
    case semPermissao
    /// ADR 04b: o teto de 64 pendentes do iOS.
    case semEspaco
    /// Compromisso de uma vez só cuja hora já passou.
    case passou

    /// Vai tocar de verdade? A superfície (widget, Ilha, ficha) pergunta isto
    /// antes de prometer: sino desenhado para um alarme que não existe é a
    /// mesma mentira da ADR 04a, só que do outro lado.
    var vaiTocar: Bool {
        if case .agendado = self { return true }
        return false
    }
}

/// ADR 2026-09-04a/04b — o estado dos avisos, honesto, e o orçamento do iOS.
///
/// Vive fora de `Revisoes` porque não é sobre revisão: é sobre a permissão e o
/// teto, que valem para tudo que o app agenda.
enum Avisos {
    enum Estado: Equatable, Sendable { case naoPerguntado, concedido, negado }

    /// O iOS guarda 64 pendentes por app e DESCARTA o resto sem avisar
    /// ninguém. Um app que promete cobrar tem de saber quanto já prometeu.
    nonisolated static let teto = 64

    static func estado() async -> Estado {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .notDetermined: .naoPerguntado
        case .authorized, .provisional, .ephemeral: .concedido
        default: .negado
        }
    }

    /// Pede UMA vez, no instante em que o autor marca alguma coisa — nunca no
    /// arranque (§3), e nunca de novo depois de um "não" (isso é o iOS que
    /// decide, e insistir seria atrito sem saída).
    @discardableResult
    static func pedirSePreciso() async -> Estado {
        let antes = await estado()
        guard antes == .naoPerguntado else { return antes }
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
        return await estado()
    }

    static func pendentes() async -> Int {
        await UNUserNotificationCenter.current().pendingNotificationRequests().count
    }

    /// Quantos avisos ainda cabem, sabendo que os ids em `reusando` vão ser
    /// substituídos (já foram cancelados) e não contam duas vezes.
    static func livres(reusando: Set<String> = []) async -> Int {
        let pendentes = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let ocupados = pendentes.filter { !reusando.contains($0.identifier) }.count
        return max(0, teto - ocupados)
    }

    /// Cabem mais `quantos`?
    static func cabem(_ quantos: Int, reusando: Set<String> = []) async -> Bool {
        await livres(reusando: reusando) >= quantos
    }

    /// A linha do Perfil: quanto do orçamento já está gasto.
    static func emPalavras() async -> String {
        switch await estado() {
        case .naoPerguntado: return "ainda não pedi — marco um compromisso e o iPhone pergunta."
        case .negado: return "desligados no iPhone: nada do Traço vai te cobrar."
        case .concedido:
            let n = await pendentes()
            return n >= teto
                ? "\(n) de \(teto) avisos — o iPhone não guarda mais que isso; apague um para marcar outro."
                : "\(n) de \(teto) avisos ativos."
        }
    }
}
