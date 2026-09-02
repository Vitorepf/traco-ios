import ActivityKit
import Foundation

/// A Live Activity do Destaque (COLHEITA: Forest, Wallet, Clear, Taio, Stoic):
/// a única coisa de hoje, na tela bloqueada e na Ilha, enquanto o dia dura.
/// Uma linha do autor; nunca expressiva, nunca trancada.
nonisolated struct DestaqueAtividade: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var linha: String
    }

    var dia: String
}
