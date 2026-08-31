import Foundation
import LocalAuthentication

/// Face ID para abrir uma expressiva SELADA (SPEC §8).
/// O atrito aqui é o método, não segurança teatral: quem selou pediu para não
/// reler à toa, e ninguém com o telefone destravado na mão passa por isto.
enum Biometria {
    /// Falso quando o aparelho não tem biometria — aí o atrito volta a ser só a
    /// dupla confirmação. Nunca trava o autor para fora do que é dele.
    nonisolated static var disponivel: Bool {
        var erro: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &erro)
    }

    static func pedir(_ razao: String = "Abrir uma escrita selada") async -> Bool {
        let ctx = LAContext()
        var erro: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &erro) else {
            return true // sem biometria no aparelho: a dupla confirmação já bastou
        }
        return (try? await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                              localizedReason: razao)) ?? false
    }
}
