import Foundation

/// Padrões pelo Grok (exp 1 — a alma do dia 200): perguntas novas a cada visita,
/// citando fragmentos LITERAIS do autor. Mesmo contrato do motor local: nunca
/// conclui, nunca diagnostica, nunca elogia. Silêncio em erro → cai no local.
enum PadroesRemoto {
    static let sistema = """
    Você lê notas de um autor e devolve PERGUNTAS que o fazem pensar duas vezes
    no que ele mesmo escreveu. Responda APENAS JSON válido, sem markdown:
    {"perguntas": ["...", "...", "..."]}

    Regras absolutas:
    - No máximo 3 perguntas, cada uma com até 2 frases.
    - Cada pergunta CITA um fragmento literal de uma nota, entre aspas “…”.
    - Perguntas, nunca conclusões. Proibido diagnosticar, aconselhar, elogiar,
      resumir ou interpretar por ele. Quem conclui é o autor.
    - Procure padrões ENTRE notas: o tema que volta, a promessa sem data,
      o obstáculo com outro nome, a tese que a nota seguinte contradiz.
    - Mesmo idioma das notas. Na dúvida, menos perguntas — ou nenhuma: [].
    """

    static func perguntas(vozes: [String]) async -> [String]? {
        guard !vozes.isEmpty, let chave = await ContaGrok.token() else { return nil }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/chat/completions")!)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = 12
        pedido.setValue("application/json", forHTTPHeaderField: "Content-Type")
        pedido.setValue("Bearer \(chave)", forHTTPHeaderField: "Authorization")
        let notas = vozes.enumerated()
            .map { "NOTA \($0.offset + 1):\n\(String($0.element.prefix(800)))" }
            .joined(separator: "\n\n")
        let corpo: [String: Any] = [
            "model": AnaliseRemota.modelo,
            "temperature": 0.4,
            "messages": [
                ["role": "system", "content": sistema],
                ["role": "user", "content": String(notas.prefix(9000))],
            ],
        ]
        pedido.httpBody = try? JSONSerialization.data(withJSONObject: corpo)
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido),
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let escolhas = raiz["choices"] as? [[String: Any]],
              let msg = (escolhas.first?["message"] as? [String: Any])?["content"] as? String
        else { return nil }
        return parsePerguntas(msg, vozes: vozes)
    }

    nonisolated static func parsePerguntas(_ cru: String, vozes: [String] = []) -> [String]? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"),
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let lista = j["perguntas"] as? [String]
        else { return nil }
        return Array(lista
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            // §19.4: texto livre da IA só passa se o ALGORITMO conseguir verificar.
            // Aqui a prova é dura: a citação tem de existir literalmente nas notas.
            .filter { vozes.isEmpty || ehPergunta($0) && citaOAutor($0, em: vozes) }
            .map { AnaliseRemota.umaFrase($0, teto: 280) }
            .prefix(3))
    }

    /// Pergunta é pergunta: sem "?", é conclusão disfarçada — e conclusão é do autor.
    nonisolated static func ehPergunta(_ p: String) -> Bool { p.contains("?") }

    /// Todo fragmento entre aspas tem de aparecer LITERALMENTE em alguma nota.
    /// Sem citação, ou com citação inventada, a pergunta é descartada.
    nonisolated static func citaOAutor(_ pergunta: String, em vozes: [String]) -> Bool {
        let fragmentos = fragmentosCitados(pergunta)
        guard !fragmentos.isEmpty else { return false }
        let corpus = vozes.joined(separator: "\n").lowercased()
        return fragmentos.allSatisfy { corpus.contains($0.lowercased()) }
    }

    nonisolated static func fragmentosCitados(_ p: String) -> [String] {
        var saida: [String] = []
        var dentro = false
        var atual = ""
        for c in p {
            if c == "\u{201C}" || c == "\u{201D}" || c == "\"" {
                if dentro {
                    let t = atual.trimmingCharacters(in: .whitespacesAndNewlines)
                    // fragmento curto demais não é prova de nada
                    if t.count >= 4 { saida.append(t) }
                    atual = ""
                    dentro = false
                } else {
                    dentro = true
                }
            } else if dentro {
                atual.append(c)
            }
        }
        return saida
    }

    // MARK: - Nunca a mesma pergunta duas visitas seguidas (vale para local e remoto)

    private static let chaveVistas = "padroesVistas"

    static func ineditas(_ perguntas: [String]) -> [String] {
        let vistas = Set(UserDefaults.standard.stringArray(forKey: chaveVistas) ?? [])
        let novas = perguntas.filter { !vistas.contains(assinatura($0)) }
        // se TUDO já foi visto, devolve as originais — repetir é melhor que calar para sempre
        return novas.isEmpty ? perguntas : novas
    }

    static func registrarVistas(_ perguntas: [String]) {
        var vistas = UserDefaults.standard.stringArray(forKey: chaveVistas) ?? []
        vistas.append(contentsOf: perguntas.map(assinatura))
        UserDefaults.standard.set(Array(vistas.suffix(30)), forKey: chaveVistas)
    }

    nonisolated static func assinatura(_ pergunta: String) -> String {
        String(pergunta.lowercased().filter { $0.isLetter }.prefix(64))
    }
}
