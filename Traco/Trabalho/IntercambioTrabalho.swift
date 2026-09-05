import CryptoKit
import Foundation

/// Protocolo de arquivo, sem acesso a disco, execução ou atribuição de autoria.
/// As superfícies verificam AcessoTrabalho antes de fornecer o documento.
nonisolated enum IntercambioTrabalho {
    static let limiteBytes = 2_097_152
    private static let marcador = "<!-- traco-trabalho"
    private static let abertura = "<!-- traco-trabalho:v1 "
    private static let fecho = " -->"

    enum Estado: Equatable, Sendable { case baseAtual, baseAntiga, semVinculo, incompativel }
    enum Erro: Error, LocalizedError {
        case tamanho, utf8, semVersaoMarkdown, vazio, vinculo, previewDesatualizado, confirmarBaseAntiga

        var errorDescription: String? {
            switch self {
            case .tamanho: "O arquivo ultrapassa o limite de 2 MiB. Nenhum conteúdo foi cortado."
            case .utf8: "O arquivo não contém texto UTF-8 válido."
            case .semVersaoMarkdown: "Escolha uma versão Markdown disponível para exportar."
            case .vazio: "O arquivo não contém uma versão para importar."
            case .vinculo: "O vínculo do arquivo não corresponde a uma base válida deste trabalho."
            case .previewDesatualizado: "O trabalho mudou depois da prévia. Confira uma nova prévia antes de importar."
            case .confirmarBaseAntiga: "O arquivo parte de uma versão ou intenção anterior. Confirme essa base antes de importar."
            }
        }
    }

    struct Preview: Identifiable, Equatable, Sendable {
        let id = UUID()
        let estado: Estado
        let texto: String
        let motivo: String?
        let baseID: UUID?
        let intencaoDaBaseID: UUID?
        let trabalhoID: UUID
        let versaoVigenteID: UUID?
        let intencaoVigenteID: UUID
        fileprivate let arquivo: Data
    }

    private struct Envelope: Codable {
        let protocolo: Int
        let trabalhoID: UUID
        let artefatoID: UUID
        let intencaoID: UUID
        let hashBase: String
    }

    static func exportar(_ documento: DocumentoTrabalho, versaoID: UUID? = nil) throws -> Data {
        try documento.validar()
        guard let versao = versaoID.flatMap({ id in documento.artefatos.first { $0.id == id } })
                ?? (versaoID == nil ? documento.versaoAtual : nil),
              versao.formato == .markdown else { throw Erro.semVersaoMarkdown }
        let envelope = Envelope(protocolo: 1, trabalhoID: documento.id,
            artefatoID: versao.id, intencaoID: versao.intencaoID, hashBase: hash(versao.conteudo))
        let json = try JSONEncoder().encode(envelope)
        let dados = Data((abertura + json.base64EncodedString() + fecho + "\n" + versao.conteudo).utf8)
        guard dados.count <= limiteBytes else { throw Erro.tamanho }
        return dados
    }

    static func preparar(_ dados: Data, para documento: DocumentoTrabalho) throws -> Preview {
        guard dados.count <= limiteBytes else { throw Erro.tamanho }
        // Foundation pode consumir BOM ao detectar encoding. O protocolo trata
        // esses bytes como corpo quando não há envelope e precisa preservá-los.
        guard let integral = String(validating: dados, as: UTF8.self) else { throw Erro.utf8 }
        try documento.validar()
        func previa(_ estado: Estado, texto: String, base: UUID? = nil,
                    intencao: UUID? = nil, motivo: String? = nil) -> Preview {
            Preview(estado: estado, texto: texto, motivo: motivo, baseID: base,
                intencaoDaBaseID: intencao, trabalhoID: documento.id,
                versaoVigenteID: documento.versaoAtual?.id,
                intencaoVigenteID: documento.intencaoAtual.id, arquivo: dados)
        }
        // BOM é aceito antes do envelope. Sem envelope, pertence ao texto.
        let semBOM = dados.starts(with: [0xEF, 0xBB, 0xBF]) ? Data(dados.dropFirst(3)) : dados
        guard semBOM.starts(with: Data(marcador.utf8)) else {
            return previa(.semVinculo, texto: integral)
        }
        // A separação é em bytes para preservar CRLF e todo whitespace do corpo.
        guard let quebra = semBOM.firstIndex(of: 0x0A) else {
            return previa(.incompativel, texto: integral, motivo: "O envelope não tem uma linha completa.")
        }
        var linha = Data(semBOM[..<quebra])
        if linha.last == 0x0D { linha.removeLast() }
        let corpo = String(decoding: semBOM[semBOM.index(after: quebra)...], as: UTF8.self)
        guard let cabecalho = String(data: linha, encoding: .utf8),
              cabecalho.hasPrefix(abertura), cabecalho.hasSuffix(fecho),
              let json = Data(base64Encoded: String(cabecalho.dropFirst(abertura.count).dropLast(fecho.count))),
              let envelope = try? JSONDecoder().decode(Envelope.self, from: json),
              envelope.protocolo == 1 else {
            return previa(.incompativel, texto: corpo, motivo: "O envelope é inválido ou usa um protocolo desconhecido.")
        }
        guard envelope.trabalhoID == documento.id,
              let base = documento.artefatos.first(where: { $0.id == envelope.artefatoID }),
              base.formato == .markdown, base.intencaoID == envelope.intencaoID,
              hash(base.conteudo) == envelope.hashBase else {
            return previa(.incompativel, texto: corpo, motivo: "Trabalho, base ou hash original não correspondem ao registro local.")
        }
        let atual = base.id == documento.versaoAtual?.id && base.intencaoID == documento.intencaoAtual.id
        return previa(atual ? .baseAtual : .baseAntiga, texto: corpo,
            base: base.id, intencao: base.intencaoID)
    }

    private static func hash(_ texto: String) -> String {
        SHA256.hash(data: Data(texto.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

extension DocumentoTrabalho {
    /// Confirma uma prévia já lida. A Oficina ainda precisa confirmar seu commit.
    @discardableResult
    mutating func aplicarVersaoExterna(_ preview: IntercambioTrabalho.Preview,
                                       confirmarBaseAntiga: Bool = false) throws -> Bool {
        guard preview.trabalhoID == id, preview.versaoVigenteID == versaoAtual?.id,
              preview.intencaoVigenteID == intencaoAtual.id else {
            throw IntercambioTrabalho.Erro.previewDesatualizado
        }
        let conferida = try IntercambioTrabalho.preparar(preview.arquivo, para: self)
        guard conferida.estado != .incompativel else { throw IntercambioTrabalho.Erro.vinculo }
        guard conferida.estado != .baseAntiga || confirmarBaseAntiga else {
            throw IntercambioTrabalho.Erro.confirmarBaseAntiga
        }
        let texto = conferida.texto
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw IntercambioTrabalho.Erro.vazio
        }
        let intencaoID = conferida.intencaoDaBaseID ?? intencaoAtual.id
        // Um retorno sem alteração ou repetido não fabrica outra versão.
        if versaoAtual.map({ $0.conteudo.utf8.elementsEqual(texto.utf8) }) == true
            || artefatos.contains(where: { $0.id == conferida.baseID && $0.conteudo.utf8.elementsEqual(texto.utf8) })
            || artefatos.contains(where: {
                $0.origem == .externa && $0.anteriorID == conferida.baseID
                    && $0.intencaoID == intencaoID && $0.conteudo.utf8.elementsEqual(texto.utf8)
            }) { return false }
        cancelarPedido()
        artefatos.append(.init(conteudo: texto, origem: .externa,
            produtor: "Arquivo importado · autoria não verificada", intencaoID: intencaoID,
            anteriorID: conferida.baseID))
        return true
    }
}
