import Foundation

/// Padrões pelo Grok (exp 1 — a alma do dia 200): perguntas novas a cada visita,
/// citando fragmentos LITERAIS do autor. Mesmo contrato do motor local: nunca
/// conclui, nunca diagnostica, nunca elogia. Silêncio em erro → cai no local.
enum PadroesRemoto {
    static let sistema = """
    Você lê notas de quem escreve e devolve PERGUNTAS que fazem essa pessoa pensar
    duas vezes no que escreveu. Responda APENAS JSON válido, sem markdown:
    {"perguntas": ["...", "...", "..."]}

    Regras absolutas:
    - No máximo 3 perguntas, cada uma com até 2 frases e 280 caracteres, terminando em "?".
    - Cada pergunta CITA um fragmento literal de uma nota, entre aspas “…”.
    - Perguntas, nunca conclusões. Proibido diagnosticar, aconselhar, elogiar,
      resumir ou interpretar por essa pessoa. Quem conclui é quem escreve.
    - Para apontar uma nota, use o título dela entre «», nunca o número: "NOTA 1",
      "NOTA 2" são só o endereço deste pedido e não existem para quem escreve.
    - Procure padrões ENTRE notas: o tema que volta, a promessa sem data,
      o obstáculo com outro nome, a tese que a nota seguinte contradiz.
    - Mesmo idioma das notas. Na dúvida, menos perguntas — ou nenhuma: [].
    """

    // ponytail: memo pelas vozes lidas. Padrões virou DESTINO da barra (§20), e
    // sem isto trocar de aba e voltar mandava as notas do autor à rede outra
    // vez — até 9.000 caracteres por visita, debitando a assinatura dele.
    // O memo cai quando as notas mudam, que é quando há padrão novo para ler.
    // sem tranca: `perguntas` só é chamada da tela, no MainActor — e NSLock em
    // contexto assíncrono é erro no modo Swift 6
    private static var memo: (chave: String, perguntas: [String]?)?

    static func esquecerMemo() { memo = nil }

    /// E7: `vozes` vão ao modelo (rotuladas); as citações se conferem em
    /// `conferirContra` (a voz crua) — rótulo não é palavra do autor.
    static func perguntas(vozes: [String], conferirContra: [String]? = nil, titulos: [String] = []) async -> [String]? {
        guard !vozes.isEmpty, Politica.provedor(.padroes) != nil else { return nil }
        let assinatura = vozes.joined(separator: "\u{1}")
        if let m = memo, m.chave == assinatura { return m.perguntas }
        let saida = await pedir(vozes: vozes, conferirContra: conferirContra ?? vozes, titulos: titulos)
        memo = (assinatura, saida)
        return saida
    }

    /// Auditoria do líder (16/09): o modelo citava "Na NOTA 3 você escreveu…" — o
    /// endereço do pedido chegava à tela. O título vai junto, para citar por ele.
    nonisolated static func montarPedido(vozes: [String], titulos: [String] = []) -> String {
        vozes.enumerated().map { i, voz in
            let titulo = i < titulos.count ? titulos[i].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            return "NOTA \(i + 1)\(titulo.isEmpty ? "" : " — «\(titulo)»"):\n\(String(voz.prefix(800)))"
        }.joined(separator: "\n\n")
    }

    private static func pedir(vozes: [String], conferirContra: [String], titulos: [String]) async -> [String]? {
        let notas = montarPedido(vozes: vozes, titulos: titulos)
        // sem memo aqui: o memo dos Padrões é o desta enum (por vozes lidas), e
        // quem volta à tela QUER perguntas novas — `ineditas` cuida do resto
        // ADR 04t: pela escada da sábia — Grok, depois o modelo do aparelho
        guard let msg = await Sabia.chamar(.padroes, sistema: sistema, usuario: String(notas.prefix(9000)),
                                           temperatura: 0.4)
        else { return nil }
        return parsePerguntas(msg, vozes: conferirContra)
    }

    nonisolated static func parsePerguntas(_ cru: String, vozes: [String] = []) -> [String]? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"),
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let lista = j["perguntas"] as? [String]
        else { return nil }
        return Array(lista
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            // §19.4: texto livre da IA só passa se o ALGORITMO conseguir verificar.
            // Aqui a prova é dura: a citação tem de existir literalmente nas notas.
            .filter { ehPergunta($0) && !citaEndereco($0) && (vozes.isEmpty || citaOAutor($0, em: vozes)) }
            .prefix(3))
    }

    /// Valida o texto que chega à tela. Cortar depois da validação pode apagar
    /// a pergunta ou sua citação; texto fora do teto precisa ser refeito.
    nonisolated static func ehPergunta(_ p: String) -> Bool { p.hasSuffix("?") && p.count <= 280 }

    /// "NOTA 3" é endereço do pedido, não palavra de quem escreve: a pergunta que
    /// ainda o traz não chega à tela, mesmo com o título pedido no sistema.
    nonisolated static func citaEndereco(_ p: String) -> Bool {
        p.range(of: #"\bnota\s+\d+\b"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

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
