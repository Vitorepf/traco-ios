import Foundation
import Security

/// Conta Grok pela ASSINATURA (ADR 2026-08-31k). Não existe chave de API neste
/// app e nada é cobrado por token: o login é OAuth 2.0 device-code contra
/// `auth.x.ai`, e as chamadas a `api.x.ai` debitam o pool semanal da assinatura
/// do autor. Sem conta ligada, o Traço é 100% local.
///
/// ponytail: cliente PÚBLICO da xAI (o mesmo do Grok CLI oficial). A xAI não
/// publica registro de cliente próprio — sem `registration_endpoint` no
/// metadata de `auth.x.ai`. Se um dia publicar, troca-se só esta constante.
enum ContaGrok {
    static let clienteID = "b1a00492-073a-47ea-816f-4c329264a828"
    static let escopos = "openid profile email offline_access api:access"
    private static let deviceURL = URL(string: "https://auth.x.ai/oauth2/device/code")!
    private static let tokenURL = URL(string: "https://auth.x.ai/oauth2/token")!

    // MARK: - Keychain (o mesmo cofre de sempre: nunca UserDefaults, nunca log)

    private static let servico = "app.traco.xai"
    private static let contaAcesso = "oauth-acesso"
    private static let contaRenova = "oauth-renova"
    private static let chaveExpira = "grokExpiraEm"

    private static func guardar(_ valor: String?, em conta: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servico,
            kSecAttrAccount as String: conta,
        ]
        SecItemDelete(q as CFDictionary)
        guard let valor, !valor.isEmpty, let dados = valor.data(using: .utf8) else { return }
        var novo = q
        novo[kSecValueData as String] = dados
        novo[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(novo as CFDictionary, nil)
    }

    private static func lido(_ conta: String) -> String? {
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

    static var ligada: Bool { lido(contaRenova) != nil || lido(contaAcesso) != nil }

    static func sair() {
        guardar(nil, em: contaAcesso)
        guardar(nil, em: contaRenova)
        UserDefaults.standard.removeObject(forKey: chaveExpira)
        // sair é sair: o que o autor perguntou não fica na memória do app
        Grok.esquecerMemo()
        PadroesRemoto.esquecerMemo()
    }

    // MARK: - Login por código de dispositivo (sem redirect, serve no iPhone)

    struct Codigo: Sendable, Equatable {
        let deviceCode: String
        let userCode: String
        let url: URL
        let intervalo: Int
    }

    /// Passo 1: pede o código. O autor vê `userCode` e aprova em `url`.
    static func pedirCodigo() async -> Codigo? {
        var pedido = URLRequest(url: deviceURL)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = 15
        pedido.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        pedido.httpBody = corpo(["client_id": clienteID, "scope": escopos])
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido),
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let device = j["device_code"] as? String,
              let user = j["user_code"] as? String,
              let uri = (j["verification_uri_complete"] as? String) ?? (j["verification_uri"] as? String),
              let url = URL(string: uri)
        else { return nil }
        return Codigo(
            deviceCode: device,
            userCode: user,
            url: url,
            intervalo: max(2, (j["interval"] as? Int) ?? 5)
        )
    }

    /// Passo 2: espera o autor aprovar no navegador. Devolve true quando entrou.
    static func aguardar(_ codigo: Codigo, ateSegundos teto: Int = 300) async -> Bool {
        let fim = Date().addingTimeInterval(TimeInterval(teto))
        // RFC 8628 §3.5: `slow_down` manda somar CINCO segundos ao intervalo e
        // seguir. Bater no mesmo ritmo depois do pedido de calma é como o
        // servidor recusa o login de vez — e aí o autor fica sem conta sem
        // entender por quê.
        var intervalo = codigo.intervalo
        while Date() < fim {
            try? await Task.sleep(for: .seconds(intervalo))
            if Task.isCancelled { return false }
            let campos = [
                "client_id": clienteID,
                "device_code": codigo.deviceCode,
                "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
            ]
            guard let j = await postToken(campos) else { continue }
            if guardarSessao(j) { return true }
            // authorization_pending / slow_down: segue esperando em silêncio
            if let erro = j["error"] as? String {
                if erro == "slow_down" { intervalo += 5 }
                if erro != "authorization_pending", erro != "slow_down" { return false }
            }
        }
        return false
    }

    // MARK: - Token vivo (renova sozinho; quem chama nunca pensa nisso)

    /// O único jeito de obter Authorization no app. Devolve nil = motor local.
    static func token() async -> String? {
        if let acesso = lido(contaAcesso), !expirado { return acesso }
        return await renovar()
    }

    private static var expirado: Bool {
        let quando = UserDefaults.standard.double(forKey: chaveExpira)
        // sem prazo gravado (a xAI omitiu `expires_in`) NÃO é "vive para
        // sempre": era isso que deixava um access token morto em uso, com a
        // conta quebrada em silêncio até o autor sair e entrar de novo.
        // Sem prazo, tenta renovar — se não houver refresh, cai no local.
        guard quando > 0 else { return true }
        // 60s de folga: token que morre no meio do voo é erro à toa
        return Date().timeIntervalSince1970 > quando - 60
    }

    @discardableResult
    static func renovar() async -> String? {
        guard let renova = lido(contaRenova) else { return nil }
        let campos = [
            "client_id": clienteID,
            "refresh_token": renova,
            "grant_type": "refresh_token",
        ]
        guard let j = await postToken(campos), guardarSessao(j) else { return nil }
        return lido(contaAcesso)
    }

    // MARK: - Encanamento

    private static func postToken(_ campos: [String: String]) async -> [String: Any]? {
        var pedido = URLRequest(url: tokenURL)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = 20
        pedido.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        pedido.httpBody = corpo(campos)
        guard let (dados, _) = try? await URLSession.shared.data(for: pedido) else { return nil }
        return try? JSONSerialization.jsonObject(with: dados) as? [String: Any]
    }

    @discardableResult
    private static func guardarSessao(_ j: [String: Any]) -> Bool {
        guard let acesso = j["access_token"] as? String, !acesso.isEmpty else { return false }
        guardar(acesso, em: contaAcesso)
        if let renova = j["refresh_token"] as? String, !renova.isEmpty {
            guardar(renova, em: contaRenova)
        }
        if let vida = j["expires_in"] as? Int {
            UserDefaults.standard.set(Date().timeIntervalSince1970 + Double(vida), forKey: chaveExpira)
        }
        return true
    }

    nonisolated static func corpo(_ campos: [String: String]) -> Data {
        var permitido = CharacterSet.alphanumerics
        permitido.insert(charactersIn: "-._~")
        return campos
            .map { chave, valor in
                let v = valor.addingPercentEncoding(withAllowedCharacters: permitido) ?? valor
                return "\(chave)=\(v)"
            }
            .joined(separator: "&")
            .data(using: .utf8) ?? Data()
    }
}

extension ContaGrok {
    /// Estado honesto da conta, em uma linha, para o perfil.
    static func estado() async -> String {
        guard ligada else { return "sem conta — tudo funciona aqui no aparelho." }
        guard let token = await token() else {
            return "sessão expirada — entre de novo."
        }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/models")!)
        pedido.timeoutInterval = 10
        pedido.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        guard let (_, resposta) = try? await URLSession.shared.data(for: pedido),
              let http = resposta as? HTTPURLResponse
        else { return "sem rede. o app segue funcionando aqui no aparelho." }
        switch http.statusCode {
        case 200: return "conectada — o Grok é o motor, pago pela sua assinatura."
        case 401: return "sessão expirada — entre de novo."
        case 403: return "a sua assinatura não libera este acesso. o app segue funcionando aqui no aparelho."
        case 429: return "limite semanal do Grok atingido. o app segue funcionando aqui no aparelho."
        default: return "o Grok respondeu \(http.statusCode). o app segue funcionando aqui no aparelho."
        }
    }
}
