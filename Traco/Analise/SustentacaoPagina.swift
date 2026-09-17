import Foundation

/// ADR 2026-09-12a / Q2-F — a Página não inventa documento, horário ou
/// terceiro que o material não deu. A recusa é local, depois do modelo.
/// A rota `responder` continua cortada na Politica até remedição.
nonisolated enum SustentacaoPagina {
    static let recusaDocumento = "Não descrevo um documento que você não trouxe. Diz o que falta e o que você já anotou."

    /// Termos da fabricação medida (08q / 10b): o modelo mandava abrir PDF
    /// ou ir ao sumário quando a nota não tinha documento nenhum.
    static let documentoAlheio = ["pdf", "sumario", "va ao sumario",
                                  "abra o arquivo", "abra o pdf"]

    static func inventouDocumento(_ resposta: String, material: String) -> Bool {
        Sabia.vazaAlheio(resposta, termos: documentoAlheio, texto: material)
    }

    /// E8 (dono, 16/09: a guarda nossa não cala a resposta inteira): sai só a frase
    /// que supõe o documento; a recusa inteira fica para quando nada útil sobra.
    /// Antes, uma frase com "pdf" ou "sumário" trocava a resposta toda pela recusa —
    /// 12 de 144 respostas medidas no Air, inclusive onde o material dava a estrutura.
    static func filtrar(_ resposta: String, pergunta: String, contexto: String) -> String? {
        let material = pergunta + "\n" + contexto
        guard inventouDocumento(resposta, material: material) else { return resposta }
        let linhas = resposta.components(separatedBy: "\n")
        let paragrafos = linhas.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        // E8 volta 4: tirar só a frase deixava item "4." vazio e frase órfã ("Leia só o que
        // cerca esses achados.") — sai o item ou o parágrafo inteiro, e a lista renumera.
        // Resposta de um parágrafo só perde a frase: tirar o parágrafo seria calar tudo.
        var numero = 0
        var saida: [String] = []
        for linha in linhas {
            let limpa = linha.trimmingCharacters(in: .whitespaces)
            if limpa.isEmpty { saida.append(""); continue }
            var texto = linha
            if inventouDocumento(linha, material: material) {
                guard paragrafos.count == 1 else { continue }
                texto = semAsFrases(linha, material: material)
            }
            if let marca = texto.firstMatch(of: /^(\s*)\d+[.)]\s*/) {
                let resto = texto[marca.range.upperBound...].trimmingCharacters(in: .whitespaces)
                guard !resto.isEmpty else { continue }
                numero += 1
                texto = marca.output.1 + "\(numero). " + resto
            } else {
                numero = 0
            }
            saida.append(texto)
        }
        let texto = saida.joined(separator: "\n").replacing(/\n{3,}/, with: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return texto.count >= minimoUtil ? texto : recusaDocumento
    }

    private static func semAsFrases(_ linha: String, material: String) -> String {
        var frases: [String] = [], inicio = linha.startIndex
        for m in linha.matches(of: /[.!?…]\s+/) {
            frases.append(String(linha[inicio..<m.range.upperBound]))
            inicio = m.range.upperBound
        }
        if inicio < linha.endIndex { frases.append(String(linha[inicio...])) }
        return frases.filter { !inventouDocumento($0, material: material) }.joined().trimmingCharacters(in: .whitespaces)
    }

    /// ponytail: tamanho como régua de "sobrou algo útil"; abaixo disto, a recusa.
    static let minimoUtil = 60

    /// E8 volta 3: "você mesmo/mesma" presume o gênero de quem escreve, e o pedido
    /// sozinho não segurou (2 de 72 na volta 2). A guarda troca por "você" e não cala nada.
    static func semGeneroPresumido(_ resposta: String) -> String {
        resposta.replacing(/(?i)\b(você|voce)\s+mesm[oa]\b/) { $0.output.1 + "" }
    }
}
