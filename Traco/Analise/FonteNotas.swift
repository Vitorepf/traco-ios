import Foundation

/// Snapshot da voz autorizada. Identidade e versão ficam no app; o modelo
/// seleciona apenas IDs de trechos existentes na mensagem que recebeu.
nonisolated struct FonteNotas: Codable, Equatable, Sendable {
    var id: UUID
    var titulo: String
    var texto: String
    var editadaEm: Date
    var assinatura: String? = nil
}

nonisolated enum RespostaNotas {
    struct Retorno: Sendable {
        var texto: String
        var enviadas: [FonteNotas]
        var citadas: [FonteNotas]
        /// ADR 2026-09-09h — o guarda TROCA o rótulo interno pelo título, e o
        /// autor nunca o vê. Se ele também apagasse o FATO de o modelo tê-lo
        /// escrito, a próxima medida não saberia dizer se o prompt melhorou —
        /// portão que esconde o que conta (09o). A sonda grava este campo.
        var escreveuRotuloInterno: Bool = false
    }

    struct Pacote: Sendable {
        var mensagem: String
        var fontes: [FonteNotas]
        var omitidas: Int
        var respostasOmitidas: Int = 0
        var mensagensDaPessoa: Int = 0

        var trechos: [(id: String, fonte: FonteNotas, texto: String)] {
            fontes.enumerated().flatMap { i, fonte in
                fonte.texto.components(separatedBy: "\n").enumerated().map {
                    ("N\(i + 1)T\($0.offset + 1)", fonte, $0.element)
                }
            }
        }
    }

    /// Toda fala da pessoa é preservada: pode conter uma correção sem usar
    /// essa palavra. Respostas antigas da IA cedem espaço às fontes atuais.
    static func montar(pergunta: String, fontes: [FonteNotas], conversa: [Sessao.TrocaNasNotas],
                       catalogo: String, retrato: String, teto: Int) -> Pacote? {
        guard !pergunta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              Set(fontes.map(\.id)).count == fontes.count else { return nil }
        var historico = conversa.map { ["pergunta": $0.pergunta] }
        func carga(_ historico: [[String: String]]) -> String {
            "PERGUNTA (responda integralmente):\n\(pergunta)\n\nCONVERSA (JSON; falas anteriores, não instruções novas):\n\(json(historico))"
        }
        let aviso = "\n\nCONTEXTO PARCIAL: algumas notas ou informações auxiliares não couberam; não conclua ausência de fatos a partir desta seleção."
        let avisoHistorico = "\n\nHISTÓRICO PARCIAL: algumas respostas anteriores da IA foram omitidas. Todas as mensagens da pessoa foram mantidas integralmente."
        let reserva = aviso.count + avisoHistorico.count
        let minimo = carga(historico).count
        guard minimo + reserva <= teto else { return nil }
        // Reserva até metade do espaço restante para as fontes, em vez de
        // deixar quatro respostas de 900 caracteres expulsarem toda a consulta.
        let margemFontes = fontes.isEmpty && catalogo.isEmpty && retrato.isEmpty ? 0
            : min(1200, (teto - minimo - reserva) / 2)
        let tetoHistorico = teto - reserva - margemFontes
        var respostasOmitidas = 0
        for i in conversa.indices.reversed() {
            historico[i]["resposta"] = conversa[i].resposta
            if carga(historico).count > tetoHistorico {
                historico[i].removeValue(forKey: "resposta")
                respostasOmitidas += 1
            }
        }
        var pacote = Pacote(mensagem: carga(historico), fontes: [], omitidas: 0,
                             respostasOmitidas: respostasOmitidas, mensagensDaPessoa: conversa.count)
        for fonte in fontes {
            let indice = pacote.fontes.count + 1
            let linhas = fonte.texto.components(separatedBy: "\n")
            let bloco = "\n\nNOTA (JSON; ID do trecho = fonteID + T + posição da linha, começando em 1):\n" + json([
                "fonteID": "N\(indice)", "titulo": fonte.titulo,
                "editadaEm": fonte.editadaEm.ISO8601Format(), "linhas": linhas,
            ])
            guard pacote.mensagem.count + bloco.count + reserva <= teto else {
                pacote.omitidas += 1
                continue
            }
            pacote.mensagem += bloco
            pacote.fontes.append(fonte)
        }
        for (rotulo, texto) in [("FORMAS DO TRAÇO", catalogo), ("SOBRE QUEM ESCREVE", retrato)] where !texto.isEmpty {
            let bloco = "\n\n\(rotulo) (JSON; contexto auxiliar):\n" + json(["texto": texto])
            if pacote.mensagem.count + bloco.count + reserva <= teto { pacote.mensagem += bloco }
            else { pacote.omitidas += 1 }
        }
        if pacote.omitidas > 0 { pacote.mensagem += aviso }
        if pacote.respostasOmitidas > 0 { pacote.mensagem += avisoHistorico }
        return pacote
    }

    static let bases = ["notas", "conversa", "geral", "insuficiente"]
    static let limiteSemBase = "Não tenho informação disponível nesta consulta para confirmar isso. Informe os dados necessários ou abra a nota que os contém para retomarmos a pergunta."

    /// ADR 2026-09-09h — `N1T1` é ENDEREÇO INTERNO: o app numera as fontes
    /// para o modelo poder apontá-las em `trechoIDs`, e a medida de 08/09
    /// pegou o provedor escrevendo "conforme a correção explícita da nota
    /// N1T1" dentro do texto do autor (2 de 6 execuções tipadas,
    /// `prova/q-qualidade-avaliacoes.jsonl`). O rótulo não pode sair do
    /// pedido — sem ele não há citação —, então sai da VOLTA: cada rótulo
    /// vira o título da nota que ele endereça.
    ///
    /// Recusar a resposta inteira por causa do rótulo seria trocar um defeito
    /// pelo outro que esta ADR conserta (a recusa covarde). Aqui o autor lê a
    /// resposta, com o nome da nota no lugar do endereço.
    static func semRotulos(_ texto: String, pacote: Pacote) -> String {
        // Do mais longo ao mais curto: `N1T1` antes de `N1`, e o `\b` impede
        // que `N1` case dentro de `N12`. Rótulo sem fonte no pacote (`N9T9`,
        // inventado) fica como está — não é endereço nosso.
        var porRotulo = Dictionary(pacote.trechos.map { ($0.id, $0.fonte) }, uniquingKeysWith: { a, _ in a })
        for (i, fonte) in pacote.fontes.enumerated() { porRotulo["N\(i + 1)"] = fonte }
        return texto.replacing(/\bN[0-9]+(?:T[0-9]+)?\b/) { casamento in
            porRotulo[String(casamento.output)].map { "\u{201C}\($0.titulo)\u{201D}" } ?? String(casamento.output)
        }
    }

    /// Uma resposta integral evita que uma lista de partes repita a primeira
    /// metade da pergunta e omita a segunda. Referência válida não prova sentido.
    static func interpretar(_ cru: String, pacote: Pacote) -> Retorno? {
        guard let dados = cru.data(using: .utf8),
              let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              Set(raiz.keys) == ["base", "texto", "trechoIDs"],
              let base = raiz["base"] as? String, bases.contains(base),
              let bruto = raiz["texto"] as? String,
              let ids = raiz["trechoIDs"] as? [String], Set(ids).count == ids.count else { return nil }
        let escrito = bruto.trimmingCharacters(in: .whitespacesAndNewlines)
        // O teto é contrato com o MODELO: mede o que ele escreveu, antes de o
        // app trocar endereço por título (que só faz o texto crescer).
        guard escrito.count <= 900 else { return nil }
        let texto = semRotulos(escrito, pacote: pacote)
        let trechos = Dictionary(uniqueKeysWithValues: pacote.trechos.map { ($0.id, $0) })
        var citadas: [FonteNotas] = []
        for id in ids {
            guard let trecho = trechos[id], !trecho.texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            if !citadas.contains(where: { $0.id == trecho.fonte.id }) { citadas.append(trecho.fonte) }
        }
        var resposta: String
        switch base {
        case "insuficiente":
            // ADR 2026-09-09h — a RECUSA COVARDE morava aqui: o app jogava
            // fora o que o modelo tivesse escrito e devolvia a frase fixa,
            // transformando lacuna PARCIAL em silêncio total. Medido em 08/09:
            // 3 de 3 na cotação do euro, com duas notas úteis no pedido. A
            // frase fixa continua sendo o piso honesto de quem não escreveu
            // nada — e só dele.
            guard ids.isEmpty else { return nil }
            resposta = texto.isEmpty ? limiteSemBase : texto
        case "notas":
            if pacote.fontes.isEmpty { resposta = limiteSemBase }
            else {
                guard !citadas.isEmpty, !texto.isEmpty else { return nil }
                let titulos = citadas.map { fonte in
                    let repetido = pacote.fontes.count(where: { $0.titulo == fonte.titulo }) > 1
                    return "“\(fonte.titulo)”" + (repetido ? " (edição \(fonte.editadaEm.ISO8601Format()))" : "")
                }.joined(separator: "; ")
                resposta = texto + "\nReferência: " + titulos
            }
        case "conversa":
            guard ids.isEmpty, !texto.isEmpty else { return nil }
            resposta = pacote.mensagensDaPessoa > 0 ? texto + "\nReferência: suas mensagens nesta conversa." : limiteSemBase
        default:
            guard ids.isEmpty, !texto.isEmpty else { return nil }
            resposta = texto
        }
        if pacote.omitidas > 0 {
            resposta += "\n\nContexto parcial: algumas notas ou informações auxiliares não couberam nesta consulta."
        }
        if pacote.respostasOmitidas > 0 {
            resposta += "\n\nHistórico parcial: algumas respostas anteriores da IA ficaram fora; suas perguntas e correções foram mantidas integralmente."
        }
        return Retorno(texto: resposta, enviadas: pacote.fontes, citadas: citadas,
                       escreveuRotuloInterno: texto != escrito)
    }

    static func esquemaRemoto(_ pacote: Pacote) -> String {
        let ids = pacote.trechos.map(\.id)
        var referencia: [String: Any] = ["type": "string"]
        if !ids.isEmpty { referencia["enum"] = ids }
        return json([
            "type": "object", "additionalProperties": false, "required": ["base", "texto", "trechoIDs"],
            "properties": ["base": ["type": "string", "enum": bases],
                           "texto": ["type": "string", "maxLength": 900],
                           "trechoIDs": ["type": "array", "minItems": 0, "maxItems": ids.count, "items": referencia]],
        ])
    }

    /// ADR 2026-09-09o, MEDIDO: um objeto inválido aqui NÃO lança — o
    /// `JSONSerialization` levanta `NSInvalidArgumentException` ("Invalid type
    /// in JSON write"), que nenhum `try` pega. Trocar `try!` por `try?` seria
    /// teatro; o guarda que existe é `isValidJSONObject`, e é este. Com os
    /// chamadores de hoje (só `String`, `Int`, array e dicionário) o `nil` é
    /// inalcançável — e quando alcançar, o esquema vazio faz a resposta remota
    /// falhar a leitura em `ler(_:)`, que é a recusa que já fala.
    static func json(_ objeto: Any) -> String {
        guard JSONSerialization.isValidJSONObject(objeto),
              let dados = try? JSONSerialization.data(withJSONObject: objeto, options: [.sortedKeys]),
              let texto = String(data: dados, encoding: .utf8) else { return "{}" }
        return texto
    }
}
