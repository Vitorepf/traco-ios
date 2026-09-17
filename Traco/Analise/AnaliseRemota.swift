import Foundation

/// Motor padrão (ADR 2026-08-31e): Grok pela API oficial da xAI, com a MESMA lista
/// fechada do motor local. Silêncio em erro: qualquer falha (rede, formato, timeout)
/// devolve nil e o chamador cai na heurística local — nunca inventa, nunca trava.
/// O selo vale para a rede: expressiva/trancada jamais chega aqui (guarda na Sessao).
enum AnaliseRemota {
    /// O modelo mora no cliente único (ADR 03l); isto é só o apelido antigo.
    static var modelo: String { Grok.modelo }

    /// Contrato FECHADO (§19.4): a IA escolhe um rótulo de lista fixa. Ela nunca
    /// devolve texto — as palavras da tela são todas do app. O que não é
    /// verificável não é perguntado.
    /// O prompt lista o CATÁLOGO (ADR 04l): um método novo entra no roteamento
    /// remoto sem uma linha de código. O `aviso` saiu do contrato (ADR 04r):
    /// o aviso é do algoritmo, sempre — o modelo só roteia.
    static var sistema: String {
        let linhas = Catalogo.todos
            .filter { $0.id != Gesto.expressiva.rawValue }
            .map { "\($0.id) = \($0.paraRoteador)" }
        let ids = Catalogo.todos.map { "\"\($0.id)\"" }.joined(separator: "|")
        return """
        Você é a Análise de um bloco de notas. Você NUNCA escreve texto.
        Você apenas CLASSIFICA. Responda APENAS um JSON válido, sem markdown:
        {"gesto": \(ids)|null}

        gesto:
        \(linhas.joined(separator: " ·\n"))
        expressiva = desabafo emocional longo · null = nada disso.

        Qualquer outra chave, texto livre ou explicação = resposta inválida.
        Na dúvida, null (silêncio).
        """
    }

    static func classificar(texto: String, gestoAtual: Gesto?) async -> AnaliseLocal.Veredito? {
        guard gestoAtual != .expressiva else { return nil } // selo: nunca à rede
        #if DEBUG
        // ADR 06h (volta A-B): o simulador não tem conta nem Apple Intelligence,
        // então a precedência do modelo era INVERIFICÁVEL na tela — e ela é
        // exatamente onde a guarda da escrita pessoal era nula. Um modelo de
        // mentira, ligado pelo ambiente do simulador, torna o degrau de cima
        // observável:
        //   xcrun simctl spawn <udid> launchctl setenv TRACO_MODELO_FALSO exameDaNoite
        if let id = ProcessInfo.processInfo.environment["TRACO_MODELO_FALSO"],
           let g = Gesto(rawValue: id), g.conhecido {
            return .gesto(g, pergunta: AnaliseLocal.pergunta(g))
        }
        #endif
        // memo pelo texto: dispensar o cartão e pausar de novo não repaga token
        // silêncio aqui é aceito (as regex decidem), então a falha desta chamada
        // de fundo não pode apagar nem trocar o motivo que outra tela espera
        guard let msg = await Grok.$semAviso.withValue(true, operation: { await Grok.responder(sistema: sistema, usuario: String(texto.prefix(6000)),
                                             // ADR 09n: o `timeout: 10` daqui foi medido para um
                                             // modelo que NÃO raciocinava. Com o modelo escolhido
                                             // (DIRETRIZ §10) ele estourava em 2 de 2 execuções e a
                                             // classificação caía CALADA para o modelo do aparelho —
                                             // o "resultado pior calado" que a ADR 07b existe para
                                             // impedir. Fica o `Grok.teto` medido, como nas outras
                                             // rotas: um teto só, e ele limita a falha, não a espera
                                             // (a análise seguinte cancela a anterior).
                                             temperatura: 0,
                                             memoPor: "classificar\u{1}\(texto.hashValue)") })
        else { return nil }
        return parseVeredito(msg)
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
        // ADR 04r: `aviso` não é mais do contrato. Um modelo velho que ainda o
        // mande é ignorado — a recusa vem da regex local ou não vem.
        guard let nomeGesto = j["gesto"] as? String else { return .silencio }
        if nomeGesto == "expressiva" { return .expressiva }
        guard let gesto = Gesto(rawValue: nomeGesto), gesto.conhecido else { return .silencio }
        // a pergunta é do TEMPLATE, sempre: o algoritmo já sabe o próximo campo
        return .gesto(gesto, pergunta: AnaliseLocal.pergunta(gesto))
    }
}
