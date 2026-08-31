import Foundation
import Security

/// Chave da API xAI no Keychain (SPEC §5 / ADR 2026-08-31e).
/// Nunca em UserDefaults, nunca em texto plano, nunca em log.
enum Chave {
    private static let servico = "app.traco.xai"
    private static let conta = "api-key"

    static func salvar(_ valor: String) {
        apagar()
        let limpo = valor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty, let dados = limpo.data(using: .utf8) else { return }
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servico,
            kSecAttrAccount as String: conta,
            kSecValueData as String: dados,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemAdd(q as CFDictionary, nil)
    }

    static func ler() -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servico,
            kSecAttrAccount as String: conta,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var ref: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &ref) == errSecSuccess,
              let dados = ref as? Data,
              let s = String(data: dados, encoding: .utf8), !s.isEmpty
        else { return nil }
        return s
    }

    static func apagar() {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servico,
            kSecAttrAccount as String: conta,
        ]
        SecItemDelete(q as CFDictionary)
    }

    static var existe: Bool { ler() != nil }
}


extension Chave {
    /// Exp 7: quem paga por token merece saber se a chave vive.
    /// GET /v1/models é barato e não gasta crédito de geração.
    static func testar() async -> String {
        guard let chave = ler() else { return "sem chave guardada." }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/models")!)
        pedido.timeoutInterval = 8
        pedido.setValue("Bearer \(chave)", forHTTPHeaderField: "Authorization")
        guard let (_, resposta) = try? await URLSession.shared.data(for: pedido),
              let http = resposta as? HTTPURLResponse
        else { return "sem rede — o motor local segue de guarda." }
        switch http.statusCode {
        case 200: return "chave viva — o Grok é o motor."
        case 401, 403: return "chave inválida ou revogada — o app está no motor local."
        case 429: return "sem crédito ou limite atingido — motor local de guarda."
        default: return "resposta \(http.statusCode) — motor local de guarda."
        }
    }
}
