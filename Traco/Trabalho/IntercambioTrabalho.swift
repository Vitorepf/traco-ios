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

// MARK: - O que a tela decide (ADR 2026-09-06x)
//
// A View não guarda regra: pergunta aqui e desenha. Assim conflito, recusa de
// commit e selo da origem têm teste sem renderizar SwiftUI.
extension IntercambioTrabalho {
    /// O que a tela de intercâmbio tinha em mãos quando o selo caiu. Selar a
    /// origem recolhe o material e a tela diz qual era.
    enum Material: Equatable, Sendable {
        case nenhum, seletor, exportacao, revisao

        var recolhimento: String? {
            switch self {
            case .nenhum: nil
            case .seletor: "A origem foi protegida: fechei o seletor de arquivo. Nada foi importado."
            case .exportacao: "A origem foi protegida: recolhi a cópia preparada antes de entregá-la. Nada saiu do Traço."
            case .revisao: "A origem foi protegida: recolhi o arquivo que estava em revisão. Nada foi importado."
            }
        }
    }

    /// Desfecho de uma tentativa de guardar a versão externa. `mudou` é o que a
    /// mutação disse; `guardou`, o que o commit disse. Os dois são distintos:
    /// a versão pode existir na memória e o disco ter recusado.
    enum Desfecho: Equatable, Sendable {
        case guardada, confirmada, semNovidade, aguardandoCommit, recusada, semAcesso

        static func de(mudou: Bool, guardou: Bool, acesso: Bool) -> Desfecho {
            guard acesso else { return .semAcesso }
            if guardou { return mudou ? .guardada : .semNovidade }
            return mudou ? .aguardandoCommit : .recusada
        }

        var linha: String {
            switch self {
            case .guardada: "Nova versão externa guardada. As versões anteriores foram preservadas."
            case .confirmada: "A mesma versão externa foi confirmada na nova tentativa. Nenhuma cópia a mais foi criada."
            case .semNovidade: "Este conteúdo já está guardado; nenhuma versão duplicada foi criada."
            case .aguardandoCommit: "A versão externa está aqui, mas não consegui guardá-la agora. Nada foi perdido; tente guardar de novo."
            case .recusada: "Não foi possível aplicar o arquivo. Confira o salvamento e importe novamente se a versão ou a intenção mudou."
            case .semAcesso: "A origem foi protegida durante a importação. Nada foi importado."
            }
        }

        /// Só a espera do commit oferece nova tentativa: a versão já está aqui e
        /// guardar de novo confirma a MESMA, sem outra importação.
        var ofereceTentarGuardar: Bool { self == .aguardandoCommit }
        /// A revisão fica de pé só quando o arquivo ainda pode servir.
        var mantemRevisao: Bool { self == .recusada }
    }

    /// As duas versões de um conflito, lado a lado. Escolher nunca sobrescreve:
    /// as duas continuam no histórico, e a escolhida entra como versão nova.
    struct Conflito: Equatable, Sendable {
        let tituloAtual: String, textoAtual: String
        let tituloArquivo: String, textoArquivo: String
        let consequencia: String
    }

    /// Só a base antiga é conflito: as duas pontas mudaram desde o export.
    static func conflito(_ p: Preview, em documento: DocumentoTrabalho) -> Conflito? {
        guard p.estado == .baseAntiga else { return nil }
        return Conflito(
            tituloAtual: "No Traço agora · \(ordem(p.versaoVigenteID, em: documento))",
            textoAtual: documento.versaoAtual?.conteudo ?? "",
            tituloArquivo: "No arquivo recebido · saiu da \(ordem(p.baseID, em: documento))",
            textoArquivo: p.texto,
            consequencia: "Nenhuma escolha apaga nada: a \(ordem(p.versaoVigenteID, em: documento)) continua no histórico e o arquivo, se você o guardar, entra como versão nova.")
    }

    static func descricaoDaBase(_ p: Preview, em documento: DocumentoTrabalho) -> String {
        switch p.estado {
        case .baseAtual:
            "Base do arquivo: \(ordem(p.baseID, em: documento)), a versão atual. O conteúdo recebido será uma nova versão."
        case .baseAntiga:
            "O trabalho mudou dos dois lados desde a exportação. Compare e escolha."
        case .semVinculo:
            "Arquivo sem vínculo de origem. Será acrescentado como material externo, ligado à intenção atual."
        case .incompativel:
            "Este arquivo não pode ser aplicado a este trabalho."
        }
    }

    private static func ordem(_ id: UUID?, em documento: DocumentoTrabalho) -> String {
        guard let id, let i = documento.artefatos.firstIndex(where: { $0.id == id }) else { return "nenhuma versão" }
        return "versão \(i + 1)"
    }
}
