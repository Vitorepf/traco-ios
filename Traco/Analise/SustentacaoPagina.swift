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
        let linhas = resposta.components(separatedBy: "\n").map { linha -> String? in
            var frases: [String] = [], inicio = linha.startIndex
            for m in linha.matches(of: /[.!?…]\s+/) {
                frases.append(String(linha[inicio..<m.range.upperBound]))
                inicio = m.range.upperBound
            }
            if inicio < linha.endIndex { frases.append(String(linha[inicio...])) }
            let ficam = frases.filter { !inventouDocumento($0, material: material) }
            if linha.trimmingCharacters(in: .whitespaces).isEmpty { return "" }
            let nova = ficam.joined().trimmingCharacters(in: .whitespaces)
            return nova.isEmpty ? nil : nova
        }.compactMap { $0 }
        let texto = linhas.joined(separator: "\n").replacing(/\n{3,}/, with: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return texto.count >= minimoUtil ? texto : recusaDocumento
    }

    /// ponytail: tamanho como régua de "sobrou algo útil"; abaixo disto, a recusa.
    static let minimoUtil = 60
}
