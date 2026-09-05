import Foundation
import SwiftData

@Model
final class Trabalho {
    var uuid: UUID
    var titulo: String
    var atualizadoEm: Date
    var conteudoJSON: Data

    init(documento: DocumentoTrabalho) throws {
        uuid = documento.id
        titulo = documento.intencaoAtual.texto
        atualizadoEm = .now
        conteudoJSON = try JSONEncoder().encode(documento)
    }

    func ler() throws -> DocumentoTrabalho {
        let documento = try JSONDecoder().decode(DocumentoTrabalho.self, from: conteudoJSON)
        guard documento.formato == 1, documento.id == uuid else { throw DocumentoTrabalho.Erro.formato }
        try documento.validar()
        return documento
    }

    func atualizar(_ documento: DocumentoTrabalho) throws {
        try documento.validar()
        guard documento.id == uuid else { throw DocumentoTrabalho.Erro.referencia }
        conteudoJSON = try JSONEncoder().encode(documento)
        titulo = documento.intencaoAtual.texto
        atualizadoEm = .now
    }
}

nonisolated struct DocumentoTrabalho: Codable, Sendable, Equatable, Identifiable {
    enum Erro: Error { case formato, referencia, vazio, pedidoAntigo }
    enum Apoio: String, Codable, CaseIterable { case delegar, praticar, combinar }
    enum Origem: String, Codable { case pessoa, ia, mista, externa }
    enum FormatoArtefato: String, Codable { case markdown, html }
    enum EstadoAcao: String, Codable { case pendente, executada, cancelada }
    enum TipoEvidencia: String, Codable { case relato, arquivo, verificacao }
    enum EstadoHipotese: String, Codable { case proposta, confirmada, contestada }
    enum EstadoPedido: String, Codable { case preparando, interrompido, falhou, cancelado, pronto }
    enum FonteCriterio: String, Codable { case intencao, resultado, instrucao }
    enum SituacaoCriterio: String, Codable { case atendidoNoEscopo, divergencia, inconclusivo, naoAvaliado }
    enum EstadoConferencia: String, Codable { case concluida, indisponivel, falhou }

    struct Intencao: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var texto: String
        var resultado: String
    }
    /// Um critério lido do pedido e o que se achou dele no artefato. O trecho
    /// da fonte é literal: o autor confere a leitura, não confia nela.
    struct Resultado: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var criterio: String
        var trechoFonte: String
        var fonte: FonteCriterio
        var situacao: SituacaoCriterio
        var trechosDoArtefato: [String] = []
        var justificativa: String
    }
    /// ADR 05p: uma passada de conferência sobre UMA versão, presa ao pedido
    /// que a produziu. `nil` no disco antigo significa sem conferência —
    /// nunca "sem divergências".
    struct Conferencia: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var pedidoID: UUID
        var data = Date.now
        var executor: String
        var versaoDoMetodo: Int
        var estado: EstadoConferencia
        var motivo: String?
        var resultados: [Resultado] = []
    }
    struct Artefato: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var conteudo: String
        var formato: FormatoArtefato = .markdown
        var origem: Origem
        var produtor: String
        var intencaoID: UUID
        var anteriorID: UUID?
        var conferencias: [Conferencia]?
    }
    struct Acao: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var texto: String
        var responsavel: Origem = .pessoa
        var artefatoID: UUID?
        var agendadaEm: Date?
        /// ADR 05n: minutos antes do horário em que o aviso toca; `nil` = sem
        /// alerta. Chave ausente no disco (ação de antes) fica `nil`: a ela
        /// foi prometido "sem alerta", e a promessa vale.
        var avisoMinutos: Int?
        var estado: EstadoAcao = .pendente
        var executadaEm: Date?
    }
    struct Evidencia: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var tipo: TipoEvidencia = .relato
        var texto: String
        var atribuidaA: String
        var acaoID: UUID
        var artefatoID: UUID?
        var referencia: String?
    }
    struct Hipotese: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var texto: String
        var contexto: String
        var evidencias: [UUID]
        var estado: EstadoHipotese = .proposta
        var avaliadaPor: String?
    }
    struct Pedido: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var instrucao: String
        var intencaoID: UUID
        var artefatoID: UUID?
        var estado: EstadoPedido = .preparando
    }

    var formato = 1
    var id = UUID()
    var notaOrigemID: UUID?
    var intencoes: [Intencao]
    var apoio: Apoio = .delegar
    var artefatos: [Artefato] = []
    var acoes: [Acao] = []
    var evidencias: [Evidencia] = []
    var hipoteses: [Hipotese] = []
    var pedidos: [Pedido] = []
    var encerrado = false

    init(intencao: String, resultado: String = "", notaOrigemID: UUID? = nil) {
        self.intencoes = [.init(texto: intencao, resultado: resultado)]
        self.notaOrigemID = notaOrigemID
    }
    var intencaoAtual: Intencao { intencoes.last ?? .init(texto: "", resultado: "") }
    var versaoAtual: Artefato? { artefatos.last }
    var pedidoAtivo: Pedido? { pedidos.last(where: { $0.estado == .preparando }) }

    mutating func reverIntencao(_ texto: String, resultado: String) throws {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        guard texto != intencaoAtual.texto || resultado != intencaoAtual.resultado else { return }
        cancelarPedido()
        intencoes.append(.init(texto: texto, resultado: resultado))
    }
    mutating func iniciarPedido(_ instrucao: String) throws -> Pedido {
        guard !instrucao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        cancelarPedido()
        let pedido = Pedido(instrucao: instrucao, intencaoID: intencaoAtual.id, artefatoID: versaoAtual?.id)
        pedidos.append(pedido)
        return pedido
    }
    mutating func cancelarPedido() {
        for i in pedidos.indices where pedidos[i].estado == .preparando { pedidos[i].estado = .cancelado }
    }
    mutating func interromperPedidos() {
        for i in pedidos.indices where pedidos[i].estado == .preparando { pedidos[i].estado = .interrompido }
    }
    mutating func falharPedido(_ id: UUID) {
        guard let i = pedidos.firstIndex(where: { $0.id == id && $0.estado == .preparando }) else { return }
        pedidos[i].estado = .falhou
    }
    mutating func receber(_ texto: String, produtor: String, pedidoID: UUID) throws {
        guard let i = pedidos.firstIndex(where: { $0.id == pedidoID && $0.estado == .preparando }),
              pedidos[i].intencaoID == intencaoAtual.id,
              pedidos[i].artefatoID == versaoAtual?.id else { throw Erro.pedidoAntigo }
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        artefatos.append(.init(conteudo: texto, origem: .ia, produtor: produtor,
                              intencaoID: intencaoAtual.id, anteriorID: pedidos[i].artefatoID))
        pedidos[i].estado = .pronto
    }
    /// Só a versão vigente recebe conferência: um retorno sobre a versão
    /// anterior não pode ser exibido como leitura da que está na tela.
    mutating func registrarConferencia(_ c: Conferencia, em artefatoID: UUID) throws {
        guard let i = artefatos.firstIndex(where: { $0.id == artefatoID }),
              i == artefatos.count - 1 else { throw Erro.pedidoAntigo }
        artefatos[i].conferencias = (artefatos[i].conferencias ?? []) + [c]
    }
    mutating func guardarVersaoHumana(_ texto: String) throws {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        cancelarPedido()
        let anterior = versaoAtual
        let origem: Origem = anterior.map { $0.origem == .pessoa ? .pessoa : .mista } ?? .pessoa
        artefatos.append(.init(conteudo: texto, origem: origem,
                              produtor: origem == .mista ? "Você, a partir de versão anterior" : "Você",
                              intencaoID: intencaoAtual.id, anteriorID: anterior?.id))
    }
    mutating func prepararAcao(_ texto: String) throws {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        acoes.append(.init(texto: texto, artefatoID: versaoAtual?.id))
    }
    mutating func agendar(_ acaoID: UUID, para data: Date?, aviso: Int? = 0) throws {
        guard let i = acoes.firstIndex(where: { $0.id == acaoID }) else { throw Erro.referencia }
        guard data == nil || acoes[i].estado == .pendente else { throw Erro.referencia }
        acoes[i].agendadaEm = data
        // ação sem horário não tem aviso; fora da lista fechada não entra
        acoes[i].avisoMinutos = data == nil ? nil : (Aviso.opcoes.contains(aviso) ? aviso : 0)
    }
    mutating func registrarRelato(_ texto: String, acaoID: UUID) throws {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        guard let i = acoes.firstIndex(where: { $0.id == acaoID }) else { throw Erro.referencia }
        evidencias.append(.init(texto: texto, atribuidaA: "Você", acaoID: acaoID, artefatoID: acoes[i].artefatoID))
    }
    mutating func marcarExecutada(_ acaoID: UUID) throws {
        guard let i = acoes.firstIndex(where: { $0.id == acaoID }) else { throw Erro.referencia }
        acoes[i].estado = .executada
        acoes[i].executadaEm = .now
    }
    mutating func avaliarHipotese(_ id: UUID, estado: EstadoHipotese) throws {
        guard let i = hipoteses.firstIndex(where: { $0.id == id }) else { throw Erro.referencia }
        cancelarPedido()
        hipoteses[i].estado = estado
        hipoteses[i].avaliadaPor = estado == .proposta ? nil : "Você"
    }
    func validar() throws {
        guard formato == 1, !intencoes.isEmpty else { throw Erro.formato }
        let intencaoIDs = Set(intencoes.map(\.id)), artefatoIDs = Set(artefatos.map(\.id))
        let acaoIDs = Set(acoes.map(\.id)), evidenciaIDs = Set(evidencias.map(\.id))
        guard intencaoIDs.count == intencoes.count, artefatoIDs.count == artefatos.count,
              acaoIDs.count == acoes.count, evidenciaIDs.count == evidencias.count,
              Set(pedidos.map(\.id)).count == pedidos.count,
              Set(hipoteses.map(\.id)).count == hipoteses.count else { throw Erro.referencia }
        let pedidoIDs = Set(pedidos.map(\.id))
        for a in artefatos {
            guard intencaoIDs.contains(a.intencaoID),
                  a.anteriorID.map({ artefatoIDs.contains($0) && $0 != a.id }) ?? true else { throw Erro.referencia }
            guard let cs = a.conferencias else { continue }
            guard Set(cs.map(\.id)).count == cs.count,
                  cs.allSatisfy({ pedidoIDs.contains($0.pedidoID) }) else { throw Erro.referencia }
        }
        for a in acoes where !(a.artefatoID.map(artefatoIDs.contains) ?? true) { throw Erro.referencia }
        for a in acoes where a.agendadaEm == nil && a.avisoMinutos != nil { throw Erro.referencia }
        for e in evidencias {
            guard let a = acoes.first(where: { $0.id == e.acaoID }), a.artefatoID == e.artefatoID else { throw Erro.referencia }
        }
        for h in hipoteses where !h.evidencias.allSatisfy(evidenciaIDs.contains) { throw Erro.referencia }
        for p in pedidos {
            guard intencaoIDs.contains(p.intencaoID), p.artefatoID.map(artefatoIDs.contains) ?? true else { throw Erro.referencia }
        }
    }
}
