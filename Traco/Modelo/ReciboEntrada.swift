import Foundation
import SwiftData

/// Identidade da versão importada, gravada junto com suas notas.
/// Não guarda texto nem depende de a nota continuar existindo.
@Model
final class ReciboEntrada {
    @Attribute(.unique) var chave: String
    var recebidaEm: Date

    init(chave: String, recebidaEm: Date = .now) {
        self.chave = chave
        self.recebidaEm = recebidaEm
    }
}
