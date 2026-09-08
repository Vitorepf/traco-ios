import Foundation

/// O portão de TODOS os modelos — rede e aparelho (ADR 2026-09-03p).
///
/// Duas situações precisam do app pensando só com algoritmo, e as duas
/// morderam de verdade em 03/set:
///
/// 1. **A suíte.** As 82 suítes descrevem o motor LOCAL, que é determinístico.
///    Quando o autor ligou a conta no simulador, o token do chaveiro passou a
///    valer para o processo de teste e oito testes sem nenhuma relação com IA
///    começaram a falhar.
/// 2. **A varredura.** 86 fluxos × uma chamada por pausa de análise = a suíte
///    de teste gastando a assinatura do autor e levando o dobro do tempo.
///    Suíte que custa dinheiro é defeito de projeto.
///
/// Um portão, não uma guarda em cada chamador: assim não há como esquecer um.
/// Os dois fluxos que provam a IA de verdade — `pergunta-sabia` e
/// `lente-instigar` — simplesmente não levantam a bandeira.
nonisolated enum Motores {
    static let desligados: Bool = {
        let e = ProcessInfo.processInfo.environment
        let emTeste = e["XCTestConfigurationFilePath"] != nil
            || e["XCTestBundlePath"] != nil
            || NSClassFromString("XCTestCase") != nil
        // `launchApp: arguments:` do maestro NÃO chega ao app no iOS (provado em
        // 03/set: o fluxo com e sem a bandeira falhou idêntico). O canal que
        // funciona é o AMBIENTE do simulador, que o `clearState` não apaga
        // porque não vive no contêiner do app:
        //   xcrun simctl spawn booted launchctl setenv TRACO_SEM_MODELO 1
        return emTeste || e["TRACO_SEM_MODELO"] == "1"
            || UserDefaults.standard.bool(forKey: "motorSoLocal")
    }()
}

/// O único cliente da xAI (ADR 2026-09-03l). Antes eram TRÊS cópias da mesma
/// requisição — `AnaliseRemota`, `Sabia` e `PadroesRemoto` — cada uma com o seu
/// timeout, o seu tratamento de erro e a sua memoização. Ou a falta dela: o
/// `Sabia` não tinha nenhuma, e abrir o Recordar da mesma nota dez vezes eram
/// dez perguntas pagas por uma nota que não mudou.
///
/// Um lugar só significa: uma política de custo, um timeout, um ponto para
/// medir, e nenhuma chance de as três divergirem em silêncio.
///
/// Silêncio em erro continua sendo a lei: qualquer falha devolve nil e o
/// chamador desce a escada (§19.4).
nonisolated enum Grok {
    static let modelo = "grok-4.3"
    static let modeloTrabalho = "grok-4.6"

    /// O teto de tempo das quatro rotas de Trabalho, num lugar só (ADR
    /// 2026-09-08m). Era `90` repetido em quatro chamadas, e a medida de 08/09
    /// mostrou que ele cortava 20 de 72 chamadas a `grok-4.6` — 28 % — sempre
    /// aos 91 s, enquanto `grok-4.3` não perdeu nenhuma das 177. Teto que corta
    /// a operação para o autor não é prudência: é a operação ausente.
    /// O valor é MEDIDO, não escolhido: ver a ADR e `prova/qb-teto-*.jsonl`.
    static let tetoTrabalho: TimeInterval = 240
    private static let endereco = URL(string: "https://api.x.ai/v1/chat/completions")!

    // MARK: - memo

    /// O que já foi perguntado nesta sessão. Pequeno de propósito: serve para
    /// não repagar a MESMA pergunta (dispensar o cartão e pausar de novo, abrir
    /// o Recordar duas vezes), não para virar cache de verdade.
    private nonisolated(unsafe) static var memo: [(chave: String, resposta: String)] = []
    private static let tranca = NSLock()
    private static let tetoMemo = 32

    #if DEBUG
    static func modelosDisponiveis() async -> [String]? {
        guard !Motores.desligados, let token = await ContaGrok.token() else { return nil }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/models")!)
        pedido.timeoutInterval = 20
        pedido.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido),
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let raiz = (try? JSONSerialization.jsonObject(with: dados)) as? [String: Any],
              let modelos = raiz["data"] as? [[String: Any]] else { return nil }
        return modelos.compactMap { $0["id"] as? String }.sorted()
    }

    struct Diagnostico: Codable, Sendable {
        var modeloSolicitado: String
        var modeloRespondido: String?
        var esforco: String
        var statusHTTP: Int?
        var tokensDeRaciocinio: Int?
        var desfecho: String
    }
    private nonisolated(unsafe) static var diagnosticos: [Diagnostico] = []
    static func retirarDiagnosticos() -> [Diagnostico] {
        tranca.lock(); defer { tranca.unlock() }
        defer { diagnosticos.removeAll() }
        return diagnosticos
    }
    private static func registrar(_ d: Diagnostico) {
        tranca.lock(); defer { tranca.unlock() }
        diagnosticos.append(d)
        if diagnosticos.count > 32 { diagnosticos.removeFirst() }
    }
    #endif

    private static func memoLido(_ chave: String) -> String? {
        tranca.lock(); defer { tranca.unlock() }
        return memo.last { $0.chave == chave }?.resposta
    }

    private static func memoGrava(_ chave: String, _ resposta: String) {
        tranca.lock(); defer { tranca.unlock() }
        memo.removeAll { $0.chave == chave }
        memo.append((chave, resposta))
        if memo.count > tetoMemo { memo.removeFirst(memo.count - tetoMemo) }
    }

    /// O autor saiu da conta: o que ele perguntou não fica na memória do app.
    static func esquecerMemo() {
        tranca.lock(); defer { tranca.unlock() }
        memo.removeAll()
    }

    // MARK: - a chamada

    /// Uma pergunta ao Grok. Devolve o texto cru; quem interpreta é o chamador,
    /// que é quem tem o contrato fechado para conferir.
    ///
    /// `memoPor` é a chave de cache. Nil = sempre chama. A regra: contrato
    /// determinístico (temperatura 0) memoiza porque repetir é desperdício
    /// puro; resposta criativa memoiza só quando repetir a pergunta DEVE dar a
    /// mesma coisa (a pergunta da prova num degrau, por exemplo). Onde o autor
    /// pede de novo esperando algo novo — instigar, padrões — não memoiza.
    static func responder(sistema: String, usuario: String, temperatura: Double,
                          timeout: TimeInterval = 20, memoPor chave: String? = nil,
                          esquema: String? = nil, esforco: String = "none",
                          modelo: String = Grok.modelo) async -> String? {
        guard !Motores.desligados, !Task.isCancelled else { return nil }
        // Uma chave do chamador não pode reutilizar uma resposta de outro
        // pedido/schema. A validação continua depois da geração estruturada.
        let chave = chave.map { "\($0)\u{1}\(modelo)\u{1}\(esforco)\u{1}\(sistema)\u{1}\(usuario)\u{1}\(temperatura)\u{1}\(esquema ?? "")" }
        if let chave, let guardada = memoLido(chave) { return guardada }
        guard let token = await ContaGrok.token() else { return nil }
        guard !Task.isCancelled,
              let corpo = corpo(sistema: sistema, usuario: usuario,
                                temperatura: temperatura, esquema: esquema, esforco: esforco, modelo: modelo) else { return nil }
        var pedido = URLRequest(url: endereco)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = timeout
        pedido.setValue("application/json", forHTTPHeaderField: "Content-Type")
        pedido.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        pedido.httpBody = corpo
        #if DEBUG
        var diagnostico = Diagnostico(modeloSolicitado: modelo, esforco: esforco, desfecho: "sem resposta de transporte")
        defer { registrar(diagnostico) }
        #endif
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido) else { return nil }
        #if DEBUG
        diagnostico.statusHTTP = (resposta as? HTTPURLResponse)?.statusCode
        let envelope = (try? JSONSerialization.jsonObject(with: dados)) as? [String: Any]
        diagnostico.modeloRespondido = envelope?["model"] as? String
        let uso = envelope?["usage"] as? [String: Any]
        let detalhes = uso?["completion_tokens_details"] as? [String: Any]
        diagnostico.tokensDeRaciocinio = detalhes?["reasoning_tokens"] as? Int
        diagnostico.desfecho = "HTTP ou conteúdo recusado"
        #endif
        guard
              !Task.isCancelled,
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let msg = textoCompleto(dados) else { return nil }
        #if DEBUG
        diagnostico.desfecho = "conteúdo completo"
        #endif
        if let chave { memoGrava(chave, msg) }
        return msg
    }

    /// O schema vai no protocolo da API, não apenas numa promessa no prompt.
    /// JSON válido ainda precisa das verificações de domínio e de conteúdo.
    static func corpo(sistema: String, usuario: String, temperatura: Double,
                      esquema: String?, esforco: String = "none", modelo: String = Grok.modelo) -> Data? {
        guard ["none", "low", "medium", "high"].contains(esforco) else { return nil }
        var corpo: [String: Any] = [
            "model": modelo,
            "reasoning_effort": esforco,
            "temperature": temperatura,
            "messages": [
                ["role": "system", "content": sistema],
                ["role": "user", "content": usuario],
            ],
        ]
        if let esquema {
            guard let dados = esquema.data(using: .utf8),
                  let schema = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
                  schema["type"] as? String == "object" else { return nil }
            corpo["response_format"] = [
                "type": "json_schema",
                "json_schema": ["name": "resposta_traco", "strict": true, "schema": schema],
            ]
        }
        return try? JSONSerialization.data(withJSONObject: corpo)
    }

    /// HTTP 200 também pode conter resposta cortada por limite ou recusa.
    /// Nenhuma delas vira versão pronta ou entra no cache.
    static func textoCompleto(_ dados: Data) -> String? {
        guard let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let escolhas = raiz["choices"] as? [[String: Any]],
              let escolha = escolhas.first,
              escolha["finish_reason"] as? String == "stop",
              let mensagem = escolha["message"] as? [String: Any],
              (mensagem["refusal"] as? String ?? "").isEmpty,
              let msg = mensagem["content"] as? String,
              !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }
        return msg
    }
}
