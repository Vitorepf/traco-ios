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

    static func filtrar(_ resposta: String, pergunta: String, contexto: String) -> String? {
        let material = pergunta + "\n" + contexto
        if inventouDocumento(resposta, material: material) { return recusaDocumento }
        return resposta
    }
}
