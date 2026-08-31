import Foundation

/// Motor padrão (ADR 2026-08-31e): Grok pela API oficial da xAI, com a MESMA lista
/// fechada do motor local. Silêncio em erro: qualquer falha (rede, formato, timeout)
/// devolve nil e o chamador cai na heurística local — nunca inventa, nunca trava.
/// O selo vale para a rede: expressiva/trancada jamais chega aqui (guarda na Sessao).
enum AnaliseRemota {
    static let modelo = "grok-4-fast-non-reasoning" // ajustável; custo por token é do dono

    static let sistema = """
    Você é a Análise de um bloco de notas. Você NUNCA escreve conteúdo pelo autor.
    Responda APENAS um JSON válido, sem markdown:
    {"gesto": "woop"|"seEntao"|"spec"|"notaPermanente"|"destaque"|"expressiva"|null, \
    "aviso": string|null, "pergunta": string|null}

    gesto: woop = desejo/meta pessoal · seEntao = hábito que emperra num gatilho ·
    spec = algo a construir (software/projeto) · notaPermanente = ideia/insight curto ·
    destaque = lista de tarefas do dia · expressiva = desabafo emocional longo · null = nada disso.

    aviso (então gesto=null, pergunta=null), frases curtas em português:
    - afirmação vazia ("eu sou rico/vencedor") → "Afirmação vazia não muda nada — e pesa em quem se estima pouco. Escreva por que um valor seu importa."
    - pedido de texto pronto → "A frase aqui é sua. O Traço não escreve."
    - pedido de ouvinte/consolo → "Quem é a pessoa de verdade que deveria receber isto? O Traço não é ouvinte."
    - plano sem obstáculo interno → "Sem o obstáculo interno, isso é fantasia — e fantasia reduz o esforço. Qual é o seu?"
    - segundo método na mesma nota → "Um gesto por sessão. O segundo método vai para outra página."

    pergunta: no máximo UMA, apontando o próximo campo vazio do gesto. Nunca elogie,
    nunca console, nunca resuma. Na dúvida, tudo null (silêncio).
    """

    // ponytail: memo de último texto — dispensar o cartão e pausar de novo não repaga token
    nonisolated(unsafe) private static var memo: (texto: String, veredito: AnaliseLocal.Veredito?)?
    nonisolated(unsafe) private static let memoLock = NSLock()

    nonisolated private static func memoLido(_ texto: String) -> AnaliseLocal.Veredito?? {
        memoLock.lock(); defer { memoLock.unlock() }
        if let m = memo, m.texto == texto { return .some(m.veredito) }
        return .none
    }

    nonisolated private static func memoGrava(_ texto: String, _ v: AnaliseLocal.Veredito?) {
        memoLock.lock(); defer { memoLock.unlock() }
        memo = (texto, v)
    }

    static func classificar(texto: String, gestoAtual: Gesto?) async -> AnaliseLocal.Veredito? {
        guard let chave = Chave.ler() else { return nil }
        guard gestoAtual != .expressiva else { return nil } // selo: nunca à rede
        if case .some(let hit) = memoLido(texto) { return hit }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/chat/completions")!)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = 10
        pedido.setValue("application/json", forHTTPHeaderField: "Content-Type")
        pedido.setValue("Bearer \(chave)", forHTTPHeaderField: "Authorization")
        let corpo: [String: Any] = [
            "model": modelo,
            "temperature": 0,
            "messages": [
                ["role": "system", "content": sistema],
                ["role": "user", "content": String(texto.prefix(6000))],
            ],
        ]
        pedido.httpBody = try? JSONSerialization.data(withJSONObject: corpo)
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido),
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let escolhas = raiz["choices"] as? [[String: Any]],
              let msg = (escolhas.first?["message"] as? [String: Any])?["content"] as? String
        else { return nil }
        let v = parseVeredito(msg)
        memoGrava(texto, v)
        return v
    }

    /// O cartão promete "uma frase curta" (§2): o modelo não fura o teto.
    nonisolated static func umaFrase(_ s: String, teto: Int = 200) -> String {
        let limpa = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard limpa.count > teto else { return limpa }
        return String(limpa.prefix(teto)).trimmingCharacters(in: .whitespaces) + "…"
    }

    /// Parsing estrito e testável: fora do formato → nil (silêncio é melhor que inventar).
    nonisolated static func parseVeredito(_ cru: String) -> AnaliseLocal.Veredito? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}") else { return nil }
        guard let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any]
        else { return nil }
        if let aviso = j["aviso"] as? String, !aviso.isEmpty {
            return .aviso(umaFrase(aviso))
        }
        guard let nomeGesto = j["gesto"] as? String else { return .silencio }
        if nomeGesto == "expressiva" { return .expressiva }
        let mapa: [String: Gesto] = ["woop": .woop, "seEntao": .seEntao, "spec": .spec,
                                     "notaPermanente": .notaPermanente, "destaque": .destaque]
        guard let gesto = mapa[nomeGesto] else { return .silencio }
        let pergunta = umaFrase((j["pergunta"] as? String) ?? "")
        return .gesto(gesto, pergunta: pergunta)
    }
}
