import Foundation
import UserNotifications

/// Revisões agendadas (FILA P1.5): o Recordar chega no dia certo, sem o autor
/// precisar lembrar de usá-lo (§17). v1: uma revisão, 3 dias após concluir.
/// ponytail: intervalo fixo; a escada espaçada (3→7→21) entra quando houver
/// registro de revisões feitas.
enum Revisoes {
    nonisolated static let intervaloDias = 3

    /// Trancada/expressiva NUNCA agenda — e a notificação nunca carrega conteúdo
    /// da nota (lock screen é rota de exposição).
    nonisolated static func podeAgendar(gesto: Gesto?, trancada: Bool, texto: String) -> Bool {
        !trancada && gesto != .expressiva && !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    nonisolated static func proximaRevisao(aPartirDe data: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: intervaloDias, to: data) ?? data.addingTimeInterval(TimeInterval(intervaloDias) * 86400)
    }

    static func agendar(uuid: UUID, criadaEm: Date, gesto: Gesto?, trancada: Bool, texto: String) {
        guard podeAgendar(gesto: gesto, trancada: trancada, texto: texto) else { return }
        let centro = UNUserNotificationCenter.current()
        centro.requestAuthorization(options: [.alert]) { ok, _ in
            guard ok else { return }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Recordar"
            // sem conteúdo da nota: o selo vale também na lock screen
            conteudo.body = "Uma nota de \(Self.intervaloDias) dias atrás espera você puxar de memória."
            let quando = proximaRevisao(aPartirDe: criadaEm)
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour], from: quando)
            let gatilho = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let pedido = UNNotificationRequest(identifier: "revisao-\(uuid.uuidString)", content: conteudo, trigger: gatilho)
            centro.add(pedido)
        }
    }

    static func cancelar(uuid: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["revisao-\(uuid.uuidString)"])
    }
}
