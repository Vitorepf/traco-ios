import Foundation

/// ADR 2026-09-12a — o eco só entra com citação verificável. A tesoura
/// antiga exigia substring literal e derrubava o mesmo trecho com acento
/// ou espaço diferente. Normalizar não inventa vínculo: a candidata ainda
/// tem de conter o trecho. A rota permanece cortada até remedição.
nonisolated enum GuardaDeEcos {
    static func normal(_ s: String) -> String {
        Sabia.dobrada(s).replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    static func cita(_ trecho: String, na candidata: String) -> Bool {
        let t = normal(trecho).trimmingCharacters(in: .whitespaces)
        guard t.count >= 8 else { return false }
        return normal(candidata).contains(t)
    }
}
