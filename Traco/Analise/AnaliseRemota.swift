import Foundation

/// Motor padrão (ADR 2026-08-31e): Grok pela API oficial da xAI, com a MESMA lista
/// fechada do motor local. Silêncio em erro: qualquer falha (rede, formato, timeout)
/// devolve nil e o chamador cai na heurística local — nunca inventa, nunca trava.
/// O selo vale para a rede: expressiva/trancada jamais chega aqui (guarda na Sessao).
enum AnaliseRemota {
    static let modelo = "grok-4-fast-non-reasoning" // pago pelo pool da assinatura (ADR 31k)

    /// Contrato FECHADO (§19.4): a IA escolhe um rótulo de lista fixa. Ela nunca
    /// devolve texto — as palavras da tela são todas do app. O que não é
    /// verificável não é perguntado.
    static let sistema = """
    Você é a Análise de um bloco de notas. Você NUNCA escreve texto.
    Você apenas CLASSIFICA. Responda APENAS um JSON válido, sem markdown:
    {"gesto": "woop"|"seEntao"|"spec"|"notaPermanente"|"destaque"|"destilar"|"palavra"|"expressiva"|null, \
    "aviso": "afirmacaoVazia"|"textoPronto"|"ouvinte"|"semObstaculo"|"doisGestos"|null}

    gesto: woop = desejo/meta pessoal ("quero…", "gostaria de…", "preciso começar…") ·
    seEntao = hábito que emperra num gatilho ·
    spec = algo a construir (software/projeto) · notaPermanente = ideia/insight curto ·
    destaque = lista de tarefas do dia · destilar = texto que pede corte até uma frase ·
    palavra = o autor quer poder usar uma palavra · expressiva = desabafo emocional longo · null = nada disso.

    aviso (quando houver aviso, gesto=null). Aviso é RARO e grave — na dúvida, null:
    - afirmacaoVazia = o autor afirma qualidade sobre si ("eu sou rico/vencedor")
    - textoPronto = pede que VOCÊ produza texto por ele ("escreva isto por mim",
      "resuma", "melhore", "traduza"). Um desejo do autor sobre a vida dele
      ("gostaria de começar a ler") NUNCA é textoPronto — é woop.
    - ouvinte = pede escuta, consolo ou companhia
    - semObstaculo = plano/meta sem nomear o obstáculo interno
    - doisGestos = há um segundo método na mesma nota

    Qualquer outra chave, texto livre ou explicação = resposta inválida.
    Na dúvida, os dois null (silêncio).
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
        guard let chave = await ContaGrok.token() else { return nil }
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
        let v = moderar(parseVeredito(msg), texto: texto, gestoAtual: gestoAtual)
        memoGrava(texto, v)
        return v
    }

    /// Aviso é recusa na cara do autor: o erro mais caro que a análise pode
    /// cometer ("Gostaria de começar a ler" tomou um textoPronto no iPhone do
    /// dono, 01/set). O remoto vale pelo ROTEAMENTO de gestos; recusa remota
    /// só passa quando a heurística local, que define os casos do §5, chega
    /// ao MESMO aviso — senão silêncio, que é resposta válida.
    static func moderar(_ v: AnaliseLocal.Veredito?, texto: String,
                        gestoAtual: Gesto?) -> AnaliseLocal.Veredito? {
        guard case .aviso = v else { return v }
        let local = AnaliseLocal.classificar(texto: texto, gestoAtual: gestoAtual, campos: [:])
        return local == v ? v : .silencio
    }

    /// O cartão promete "uma frase curta" (§2): o modelo não fura o teto.
    nonisolated static func umaFrase(_ s: String, teto: Int = 200) -> String {
        let limpa = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard limpa.count > teto else { return limpa }
        return String(limpa.prefix(teto)).trimmingCharacters(in: .whitespaces) + "…"
    }

    /// Parsing estrito: a IA devolve RÓTULO; as palavras são do app. Rótulo
    /// desconhecido, texto livre ou chave extra → silêncio (nunca inventa).
    nonisolated static func parseVeredito(_ cru: String) -> AnaliseLocal.Veredito? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}") else { return nil }
        guard let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any]
        else { return nil }
        if let rotulo = j["aviso"] as? String, !rotulo.isEmpty {
            guard let frase = AnaliseLocal.avisos[rotulo] else { return .silencio }
            return .aviso(frase)
        }
        guard let nomeGesto = j["gesto"] as? String else { return .silencio }
        if nomeGesto == "expressiva" { return .expressiva }
        let mapa: [String: Gesto] = ["woop": .woop, "seEntao": .seEntao, "spec": .spec,
                                     "notaPermanente": .notaPermanente, "destaque": .destaque,
                                     "destilar": .destilar, "palavra": .palavra]
        guard let gesto = mapa[nomeGesto] else { return .silencio }
        // a pergunta é do TEMPLATE, sempre: o algoritmo já sabe o próximo campo
        return .gesto(gesto, pergunta: AnaliseLocal.pergunta(gesto))
    }
}
