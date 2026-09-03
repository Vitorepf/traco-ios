import Foundation

/// A sábia (ADR 2026-09-02o): a IA que dá forma, dá informação e dá pergunta,
/// nunca a resposta do autor. Três chamadas, cada uma com verificação dura:
/// `vestir` devolve um mapa de rótulos por bloco; `responder` devolve texto
/// para um CARTÃO (nunca para a nota); `instigar` devolve perguntas.
/// Selo: expressiva e trancada jamais chegam aqui (quem chama garante).
enum Sabia {
    static let modelo = AnaliseRemota.modelo

    /// As formas que o mapa de vestir pode nomear. Lista fechada: rótulo
    /// desconhecido invalida o mapa inteiro.
    nonisolated enum FormaDeBloco: String, CaseIterable, Sendable {
        case titulo, secao, lista, numerada, tarefas, citacao, codigo, tabela, prosa
    }

    nonisolated struct Rotulo: Equatable, Sendable {
        var i: Int
        var forma: FormaDeBloco
    }

    static let sistemaVestir = """
    Você dá FORMA a um texto sem tocar numa palavra. Recebe blocos numerados.
    Responda APENAS um JSON válido: [{"i": <número do bloco>, "forma": "titulo"|"secao"|"lista"|"numerada"|"tarefas"|"citacao"|"codigo"|"tabela"|"prosa"}]
    Um item por bloco, na ordem. titulo = o título do texto inteiro (no máximo um) ·
    secao = cabeçalho de parte · lista = linhas paralelas sem ordem · numerada = passos em ordem ·
    tarefas = coisas a fazer · citacao = fala de outro · codigo = código ou comando · tabela = linhas com colunas
    separadas por | ou tabulação · prosa = tudo o mais. Na dúvida, prosa. Nenhuma outra chave, nenhum texto.
    """

    static let sistemaResponder = """
    Você é uma pessoa sábia ao lado de quem escreve. Ela deixou uma pergunta na própria nota e você responde
    com informação, opções e critérios — em português, direto, sem elogio, sem rodeio, no máximo 900 caracteres.
    Você NÃO escreve a nota por ela: não redija o texto dela, não conclua por ela, não decida por ela.
    Onde houver mais de um caminho, mostre os caminhos e o que decide entre eles.
    """

    static let sistemaInstigar = """
    Você é uma pessoa sábia lendo o rascunho de quem escreve. Devolva APENAS um JSON válido: {"perguntas": ["…", "…"]}
    De 2 a 5 perguntas curtas em português, cada uma terminando em "?", que apontem buracos, dependências,
    termos ambíguos, o que falta decidir, o que pode dar errado. Perguntas, não respostas. Nenhuma sugestão de texto.
    """

    // MARK: chamadas

    static func vestir(blocos: [String], gesto: Gesto?) async -> [Rotulo]? {
        guard gesto != .expressiva, !blocos.isEmpty else { return nil }
        let usuario = blocos.enumerated().map { "[\($0.offset)] \($0.element.prefix(400))" }.joined(separator: "\n\n")
        guard let cru = await chamar(sistema: sistemaVestir, usuario: usuario, temperatura: 0) else { return nil }
        return parseMapa(cru, blocos: blocos.count)
    }

    static func responder(pergunta: String, contexto: String, gesto: Gesto?) async -> String? {
        guard gesto != .expressiva else { return nil }
        let usuario = "Contexto (a nota, só para você entender; não a reescreva):\n\(contexto.prefix(5000))\n\nPergunta: \(pergunta)"
        guard let cru = await chamar(sistema: sistemaResponder, usuario: usuario, temperatura: 0.3) else { return nil }
        return limparResposta(cru)
    }

    static func instigar(texto: String, gesto: Gesto?) async -> [String]? {
        guard gesto != .expressiva else { return nil }
        let usuario = "Forma: \(gesto?.nome ?? "nota")\n\n\(texto.prefix(6000))"
        guard let cru = await chamar(sistema: sistemaInstigar, usuario: usuario, temperatura: 0.4) else { return nil }
        return parsePerguntas(cru)
    }

    private static func chamar(sistema: String, usuario: String, temperatura: Double) async -> String? {
        guard let chave = await ContaGrok.token() else { return nil }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/chat/completions")!)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = 20
        pedido.setValue("application/json", forHTTPHeaderField: "Content-Type")
        pedido.setValue("Bearer \(chave)", forHTTPHeaderField: "Authorization")
        let corpo: [String: Any] = [
            "model": modelo,
            "temperature": temperatura,
            "messages": [
                ["role": "system", "content": sistema],
                ["role": "user", "content": usuario],
            ],
        ]
        pedido.httpBody = try? JSONSerialization.data(withJSONObject: corpo)
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido),
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let escolhas = raiz["choices"] as? [[String: Any]],
              let msg = (escolhas.first?["message"] as? [String: Any])?["content"] as? String
        else { return nil }
        return msg
    }

    // MARK: verificação dura (§19.4: só entra o que o algoritmo sabe checar)

    /// Mapa válido: um rótulo da lista por bloco existente. Índice repetido,
    /// fora do intervalo, forma desconhecida ou mais de um título = nil.
    nonisolated static func parseMapa(_ cru: String, blocos: Int) -> [Rotulo]? {
        guard let ini = cru.firstIndex(of: "["), let fim = cru.lastIndex(of: "]") else { return nil }
        guard let dados = String(cru[ini...fim]).data(using: .utf8),
              let lista = try? JSONSerialization.jsonObject(with: dados) as? [[String: Any]]
        else { return nil }
        var vistos = Set<Int>()
        var saida: [Rotulo] = []
        var titulos = 0
        for item in lista {
            guard let i = item["i"] as? Int, i >= 0, i < blocos, !vistos.contains(i),
                  let f = item["forma"] as? String, let forma = FormaDeBloco(rawValue: f) else { return nil }
            if forma == .titulo { titulos += 1 }
            vistos.insert(i)
            saida.append(Rotulo(i: i, forma: forma))
        }
        guard titulos <= 1, !saida.isEmpty else { return nil }
        return saida.sorted { $0.i < $1.i }
    }

    /// Perguntas válidas: de 1 a 5, cada uma terminando em "?".
    nonisolated static func parsePerguntas(_ cru: String) -> [String]? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}") else { return nil }
        guard let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let lista = j["perguntas"] as? [String]
        else { return nil }
        let limpas = lista
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasSuffix("?") && $0.count > 8 && $0.count <= 240 }
        guard !limpas.isEmpty else { return nil }
        return Array(limpas.prefix(5))
    }

    /// A resposta tem teto e nunca vem em markdown pesado: é para ler no cartão.
    nonisolated static func limparResposta(_ cru: String, teto: Int = 1200) -> String? {
        var s = cru.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: "**", with: "")
        s = s.replacingOccurrences(of: #"(?m)^#+\s*"#, with: "", options: .regularExpression)
        guard !s.isEmpty else { return nil }
        if s.count > teto { s = String(s.prefix(teto)).trimmingCharacters(in: .whitespaces) + "…" }
        return s
    }

    /// A linha "?" da nota: a última linha que começa com "?" e tem pergunta.
    nonisolated static func perguntaNaNota(_ texto: String) -> String? {
        let linhas = texto.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let linha = linhas.last(where: { $0.hasPrefix("?") }) else { return nil }
        let corpo = String(linha.dropFirst()).trimmingCharacters(in: .whitespaces)
        return corpo.count >= 4 ? corpo : nil
    }

    // MARK: aplicar o mapa (algoritmo: as palavras são as do autor)

    /// Os blocos do texto, como o `estruturar` os vê: separados por linha em branco.
    nonisolated static func blocos(_ texto: String) -> [String] {
        let normal = texto.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        var blocos: [String] = []
        var atual: [String] = []
        for l in normal.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
            if l.trimmingCharacters(in: .whitespaces).isEmpty {
                if !atual.isEmpty { blocos.append(atual.joined(separator: "\n")); atual = [] }
            } else {
                atual.append(l)
            }
        }
        if !atual.isEmpty { blocos.append(atual.joined(separator: "\n")) }
        return blocos
    }

    /// Veste cada bloco com a forma do mapa. Bloco já vestido não se toca.
    nonisolated static func aplicar(_ mapa: [Rotulo], a texto: String) -> String {
        let partes = blocos(texto)
        let formas = Dictionary(uniqueKeysWithValues: mapa.map { ($0.i, $0.forma) })
        var saida: [String] = []
        for (i, bloco) in partes.enumerated() {
            let linhas = bloco.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            let primeira = linhas.first ?? ""
            let jaVestido = primeira.hasPrefix("#") || primeira.hasPrefix("- ") || primeira.hasPrefix("* ")
                || primeira.hasPrefix("> ") || primeira.hasPrefix("```") || primeira.hasPrefix("|")
                || primeira.range(of: #"^\d+[.)] "#, options: .regularExpression) != nil
            guard !jaVestido, let forma = formas[i] else { saida.append(bloco); continue }
            switch forma {
            case .titulo: saida.append("# " + linhas.joined(separator: " "))
            case .secao: saida.append("## " + linhas.joined(separator: " "))
            case .lista: saida.append(linhas.map { "- " + $0 }.joined(separator: "\n"))
            case .numerada: saida.append(linhas.enumerated().map { "\($0.offset + 1). " + $0.element }.joined(separator: "\n"))
            case .tarefas: saida.append(linhas.map { "- [ ] " + $0 }.joined(separator: "\n"))
            case .citacao: saida.append(linhas.map { "> " + $0 }.joined(separator: "\n"))
            case .codigo: saida.append("```\n" + bloco + "\n```")
            case .tabela:
                let celulas = linhas.map { $0.split(whereSeparator: { $0 == "|" || $0 == "\t" }).map { $0.trimmingCharacters(in: .whitespaces) } }
                guard let cabeca = celulas.first, cabeca.count >= 2 else { saida.append(bloco); continue }
                var t = ["| " + cabeca.joined(separator: " | ") + " |", "|" + String(repeating: " --- |", count: cabeca.count)]
                for linha in celulas.dropFirst() { t.append("| " + linha.joined(separator: " | ") + " |") }
                saida.append(t.joined(separator: "\n"))
            case .prosa: saida.append(bloco)
            }
        }
        return saida.joined(separator: "\n\n")
    }
}
