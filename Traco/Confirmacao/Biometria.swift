import Foundation
import LocalAuthentication

/// Face ID para abrir uma expressiva SELADA (SPEC §8).
/// O atrito aqui é o método, não segurança teatral: quem selou pediu para não
/// reler à toa, e ninguém com o telefone destravado na mão passa por isto.
enum Biometria {
    /// Decide só o rótulo do botão; quem guarda a porta é `pedir`.
    nonisolated static var disponivel: Bool {
        var erro: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &erro)
    }

    /// Rosto, ou o código do aparelho quando o rosto falha, está bloqueado ou
    /// foi desligado para o Traço nos Ajustes — desligar o Face ID não pode
    /// abrir a selada. Só um aparelho SEM código passa direto: aí não há dono
    /// a conferir e a dupla confirmação já foi o atrito.
    static func pedir(_ razao: String = "Abrir uma escrita selada") async -> Bool {
        let ctx = LAContext()
        var erro: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &erro) else {
            return erro?.code == LAError.passcodeNotSet.rawValue
        }
        return (try? await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: razao)) ?? false
    }
}
