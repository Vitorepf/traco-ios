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

    static func agendarFilaDiaria() {
        let centro = UNUserNotificationCenter.current()
        centro.getNotificationSettings { estado in
            guard estado.authorizationStatus == .authorized
                    || estado.authorizationStatus == .provisional else { return }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Recordar"
            conteudo.body = ""
            conteudo.userInfo = ["fila": true]
            var comps = DateComponents()
            comps.hour = hora
            comps.minute = 0
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let pedido = UNNotificationRequest(
                identifier: "fila-do-dia", content: conteudo, trigger: gatilho)
            centro.removePendingNotificationRequests(withIdentifiers: ["fila-do-dia"])
            centro.add(pedido)
        }
    }

    // MARK: - Aviso do Se (título da nota, sem corpo)

    static func agendarGatilho(uuid: UUID, titulo: String, em data: Date) {
        guard data > .now else { return }
        let centro = UNUserNotificationCenter.current()
        centro.requestAuthorization(options: [.alert]) { ok, _ in
            guard ok else { return }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = titulo
            conteudo.body = ""
            conteudo.userInfo = ["uuid": uuid.uuidString, "gatilho": true]
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: data)
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let pedido = UNNotificationRequest(
                identifier: "gatilho-\(uuid.uuidString)", content: conteudo, trigger: gatilho)
            centro.add(pedido)
        }
    }

    static func cancelarGatilho(uuid: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["gatilho-\(uuid.uuidString)"])
    }

    // MARK: - Série da expressiva (notificação sem conteúdo → página)

    static func agendarSerie(serie: UUID, dia: Int, em data: Date) {
        guard (2...4).contains(dia), data > .now else { return }
        let centro = UNUserNotificationCenter.current()
        centro.requestAuthorization(options: [.alert]) { ok, _ in
            guard ok else { return }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Expressiva"
            conteudo.body = ""
            conteudo.userInfo = ["serie": serie.uuidString, "dia": dia]
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour], from: data)
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let pedido = UNNotificationRequest(
                identifier: "serie-\(serie.uuidString)-\(dia)",
                content: conteudo, trigger: gatilho)
            centro.add(pedido)
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
                if let raw = info["serie"] as? String, let serie = UUID(uuidString: raw) {
                    let dia = info["dia"] as? Int ?? 2
                    NotificationCenter.default.post(
                        name: Revisoes.abrirSerie, object: serie, userInfo: ["dia": dia])
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { ok, _ in
            guard ok else {
                let d = UserDefaults.standard
                if !d.bool(forKey: "avisoRevisoesNegadas") {
                    d.set(true, forKey: "avisoRevisoesNegadas")
                    aoNegar()
                }
                return
            }
        }
    }
}
