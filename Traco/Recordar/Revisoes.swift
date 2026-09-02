import Foundation
import UserNotifications

/// Revisões agendadas (FILA P1.5): o Recordar chega no dia certo, sem o autor
/// precisar lembrar de usá-lo (§17). v1: uma revisão, 3 dias após concluir.
/// ponytail: intervalo fixo; a escada espaçada (3→7→21) entra quando houver
/// registro de revisões feitas.
enum Revisoes {
    /// Escada espaçada: cada revisão cumprida sobe um degrau.
    /// ponytail: nível em UserDefaults (não é schema); migra para o modelo se a
    /// escada crescer além de 3 degraus.
    nonisolated static let escada = [3, 7, 21]
    nonisolated static let intervaloDias = 3 // compat: degrau 0

    nonisolated static func dias(nivel: Int) -> Int {
        escada[max(0, min(nivel, escada.count - 1))]
    }

    static func nivel(_ uuid: UUID) -> Int {
        (UserDefaults.standard.dictionary(forKey: "revisaoNivel") as? [String: Int])?[uuid.uuidString] ?? 0
    }

    /// Tocar a notificação e recordar = revisão cumprida: sobe o degrau.
    static func registrarCumprida(_ uuid: UUID) {
        var d = (UserDefaults.standard.dictionary(forKey: "revisaoNivel") as? [String: Int]) ?? [:]
        d[uuid.uuidString] = min((d[uuid.uuidString] ?? 0) + 1, escada.count - 1)
        UserDefaults.standard.set(d, forKey: "revisaoNivel")
        var c = (UserDefaults.standard.dictionary(forKey: "revisaoConta") as? [String: Int]) ?? [:]
        c[uuid.uuidString] = (c[uuid.uuidString] ?? 0) + 1
        UserDefaults.standard.set(c, forKey: "revisaoConta")
    }

    /// Arquivo do esforço, não streak: "recordada 3×" no cartão da nota.
    static func contagem(_ uuid: UUID) -> Int {
        (UserDefaults.standard.dictionary(forKey: "revisaoConta") as? [String: Int])?[uuid.uuidString] ?? 0
    }

    /// Trancada/expressiva NUNCA agenda — e a notificação nunca carrega conteúdo
    /// da nota (lock screen é rota de exposição).
    nonisolated static func podeAgendar(gesto: Gesto?, fechada: Bool, texto: String) -> Bool {
        !fechada && gesto != .expressiva && !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    nonisolated static func proximaRevisao(aPartirDe data: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: intervaloDias, to: data) ?? data.addingTimeInterval(TimeInterval(intervaloDias) * 86400)
    }

    static func agendar(uuid: UUID, criadaEm: Date, gesto: Gesto?, fechada: Bool, texto: String,
                        aoNegar: @escaping @Sendable () -> Void = {}) {
        guard podeAgendar(gesto: gesto, fechada: fechada, texto: texto) else { return }
        let centro = UNUserNotificationCenter.current()
        centro.requestAuthorization(options: [.alert]) { ok, _ in
            guard ok else {
                // negação não é morte silenciosa: o app diz UMA vez o que se perdeu
                let d = UserDefaults.standard
                if !d.bool(forKey: "avisoRevisoesNegadas") {
                    d.set(true, forKey: "avisoRevisoesNegadas")
                    aoNegar()
                }
                return
            }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Recordar"
            // sem conteúdo da nota: o selo vale também na lock screen
            let degrau = Self.dias(nivel: Self.nivel(uuid))
            conteudo.body = "Uma nota de \(degrau) dias atrás espera você recordar."
            // nota velha reeditada: a base é o agora — trigger no passado nunca dispara
            let quando = Calendar.current.date(byAdding: .day, value: degrau, to: max(criadaEm, .now)) ?? .now
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour], from: quando)
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            conteudo.userInfo = ["uuid": uuid.uuidString]
            let pedido = UNNotificationRequest(identifier: "revisao-\(uuid.uuidString)", content: conteudo, trigger: gatilho)
            centro.add(pedido)
        }
    }

    // MARK: - Toque na notificação → direto ao Recordar da nota (§17: um passo)

    nonisolated static func uuidDaResposta(_ userInfo: [AnyHashable: Any]) -> UUID? {
        (userInfo["uuid"] as? String).flatMap(UUID.init(uuidString:))
    }

    static let abrirRevisao = Notification.Name("traco.abrirRevisao")

    final class Delegate: NSObject, UNUserNotificationCenterDelegate {
        static let compartilhado = Delegate()

        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse) async {
            guard let uuid = Revisoes.uuidDaResposta(response.notification.request.content.userInfo) else { return }
            await MainActor.run {
                NotificationCenter.default.post(name: Revisoes.abrirRevisao, object: uuid)
            }
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            [.banner]
        }
    }

    static func cancelar(uuid: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["revisao-\(uuid.uuidString)"])
    }
}
