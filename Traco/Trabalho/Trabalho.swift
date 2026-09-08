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
    /// ADR 05r: `tentativa` é a resposta do autor a um exercício. Nasce aqui e
    /// não no disco antigo — nenhum registro anterior vira tentativa por
    /// releitura. Continua sendo evidência de uma AÇÃO, nunca versão.
    enum TipoEvidencia: String, Codable { case relato, arquivo, verificacao, tentativa }
    enum EstadoHipotese: String, Codable { case proposta, confirmada, contestada }
    /// ADR 05r (volta 6): `praticaIndisponivel` é o pedido de PRÁTICA cuja
    /// preparação não validou. Fica guardado assim — nunca cai na produção
    /// delegada, que entregaria a resposta a quem escolheu praticar.
    /// ADR 08j: `ajusteIndisponivel` é o pedido de AJUSTE cuja causa não coube
    /// na janela do provedor. A evidência causal é núcleo obrigatório: se não
    /// cabe, o ajuste não sai — e a tela diz isso, em vez de mandar um pedaço.
    enum EstadoPedido: String, Codable { case preparando, interrompido, falhou, cancelado, pronto, praticaIndisponivel, ajusteIndisponivel }
    /// ADR 08j: por que esta versão foi pedida. Lista FECHADA — o app não
    /// inventa um terceiro motivo para reescrever o exercício de alguém.
    enum GatilhoDoAjuste: String, Codable { case pedidoDoAutor, necessidadePercebida }
    enum FonteCriterio: String, Codable { case intencao, resultado, instrucao }
    enum SituacaoCriterio: String, Codable, CaseIterable { case atendidoNoEscopo, divergencia, inconclusivo, naoAvaliado }
    enum EstadoConferencia: String, Codable { case concluida, indisponivel }

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
    /// ADR 05r: um critério de desempenho do exercício, com identidade — o
    /// feedback aponta o ID, nunca repete o texto do critério por conta própria.
    struct Criterio: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var texto: String
    }
    /// ADR 05r: a preparação da IA quando a pessoa escolheu PRATICAR. É
    /// material de exercício, não a resposta: o `exemplo` é resolvido e
    /// diferente do que se pede na tentativa. `nil` = esta versão não é
    /// prática — nunca "prática sem critérios".
    struct Pratica: Codable, Sendable, Equatable {
        var capacidade: String
        var situacao: String
        var dificuldade: String?
        var hipoteseID: UUID?
        var enunciado: String
        var exemplo: String
        var criterios: [Criterio]
        /// ADR 08j: o que MUDOU nesta versão, descrito pelo modelo e limitado
        /// pelo mesmo contrato de tipo do resto. `nil` = esta versão não nasceu
        /// de um ajuste; nunca "mudou e não disse".
        var mudanca: String?
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
        /// ADR 08j: o pedido que produziu esta versão, guardado. Antes disso
        /// `pedidoDe` inferia por base e intenção, e inferência não pode ser a
        /// autoridade que explica ao autor por que o exercício dele mudou.
        /// `nil` em registro antigo, em versão escrita à mão e em importada.
        var pedidoID: UUID?
        var conferencias: [Conferencia]?
        var pratica: Pratica?
        /// Em Combinar, a entrega fica legível separadamente do exercício.
        /// `conteudo` mantém ambos para intercâmbio e versões anteriores.
        var parteDelegada: String?
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
    /// ADR 05r: o que a conferência achou de UM critério na tentativa. O
    /// trecho é literal da tentativa (a validação apaga o que não for) e a
    /// observação não traz solução, reescrita nem elogio.
    struct ResultadoDaTentativa: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var criterioID: UUID
        var situacao: SituacaoCriterio
        var trechoDaTentativa: String
        var observacao: String
    }
    /// ADR 05r: uma passada de feedback sobre UMA tentativa. Reavaliar
    /// acrescenta aqui e não cria outra tentativa — nem outra demonstração.
    struct ConferenciaTentativa: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var executor: String
        var versaoDoMetodo: Int
        var estado: EstadoConferencia
        var motivo: String?
        var resultados: [ResultadoDaTentativa] = []
        /// ADR 08j: a pessoa disse que esta leitura interpretou errado. A
        /// leitura FICA — a história não se apaga —, mas para de orientar
        /// ajustes: some do contexto de retorno e não sustenta um ajuste novo.
        var contestadaEm: Date?
        var motivoDaContestacao: String?
        var contestada: Bool { contestadaEm != nil }
    }
    /// ADR 05r: a resposta que a pessoa escreveu. `apoioUtilizado` é dela e é
    /// obrigatório — desconhecido nunca vira "sem ajuda". `anteriorID` liga
    /// uma revisão à tentativa que veio antes, sem apagá-la.
    struct Tentativa: Codable, Sendable, Equatable {
        var origem: Origem = .pessoa
        var apoioUtilizado: String
        var anteriorID: UUID?
        var conferencias: [ConferenciaTentativa]?
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
        var tentativa: Tentativa?
    }
    struct Hipotese: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var texto: String
        var contexto: String
        var evidencias: [UUID]
        var estado: EstadoHipotese = .proposta
        var avaliadaPor: String?
        /// ADR 05r: quem PROPÔS. Registro antigo fica `nil` e a tela diz
        /// "autoria desconhecida"; ninguém reconstrói autor por dedução.
        var propostaPor: String?
        var avaliadaEm: Date?
        var motivoAvaliacao: String?
    }
    func instrucoesAnteriores(ao pedido: DocumentoTrabalho.Pedido) -> [String] {
        pedidos.prefix { $0.id != pedido.id }
            .filter { $0.estado == .pronto && $0.intencaoID == pedido.intencaoID }
            .reversed().map(\.instrucao)
    }

    /// ADR 08j: a CAUSA do ajuste, como dado — não como inferência. Guarda o
    /// gatilho, o motivo escrito pelo app e a referência à evidência (e à
    /// leitura e aos critérios, quando foram eles que a sustentaram).
    /// `necessidadePercebida` exige tentativa E leitura: sem elas, "o app
    /// percebeu" seria o app afirmando o que não observou. `pedidoDoAutor`
    /// existe sem nenhuma das duas — a pessoa pode simplesmente querer outro
    /// exercício.
    struct Ajuste: Codable, Sendable, Equatable {
        var gatilho: GatilhoDoAjuste
        var motivo: String
        var evidenciaID: UUID?
        var conferenciaID: UUID?
        var criterioIDs: [UUID] = []
    }

    struct Pedido: Codable, Sendable, Equatable, Identifiable {
        var id = UUID()
        var data = Date.now
        var instrucao: String
        var intencaoID: UUID
        var artefatoID: UUID?
        var estado: EstadoPedido = .preparando
        /// `nil` = este pedido não é um ajuste, ou é registro antigo. Ausência
        /// significa vínculo NÃO REGISTRADO; ninguém reconstrói causalidade.
        var ajuste: Ajuste?
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
    /// ADR 05r: em `combinar`, o trecho que a PESSOA vai exercitar. Sem esta
    /// delimitação, combinar é entrega delegada — classificar a entrega
    /// inteira como prática seria chamar de exercício o que ela não fez.
    var trechoExercitado: String?

    init(intencao: String, resultado: String = "", notaOrigemID: UUID? = nil) {
        self.intencoes = [.init(texto: intencao, resultado: resultado)]
        self.notaOrigemID = notaOrigemID
    }
    static let acaoDaPraticaLivre = "Praticar por conta própria"
    var intencaoAtual: Intencao { intencoes.last ?? .init(texto: "", resultado: "") }
    var versaoAtual: Artefato? { artefatos.last }
    /// ADR 05r: este pedido prepara PRÁTICA? Em `praticar`, sempre. Em
    /// `combinar`, só com o trecho delimitado. Em `delegar`, nunca.
    var praticaPedida: Bool {
        switch apoio {
        case .praticar: true
        case .combinar: !(trechoExercitado ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .delegar: false
        }
    }
    /// A dificuldade que a pessoa registrou e não contestou — o que entra na
    /// preparação. Contestar retira; ninguém pratica contra a própria correção.
    var dificuldadeVigente: Hipotese? { hipoteses.last { $0.estado != .contestada } }
    /// A última tentativa guardada. As anteriores continuam na lista.
    var tentativaAtual: Evidencia? { evidencias.last { $0.tentativa != nil } }

    /// O mesmo orçamento para entrega e exercício; o núcleo nunca é cortado.
    static func montarContexto(cabeca: String, secoes: [String], final: String, teto: Int) -> String {
        guard !secoes.isEmpty else { return cabeca + final }
        let material = secoes.joined(separator: "\n\n")
        let abertura = "\n\n<material_de_referencia>\n"
        let fecho = "\n</material_de_referencia>"
        let fixo = cabeca.count + abertura.count + fecho.count + final.count
        if fixo + material.count <= teto { return cabeca + abertura + material + fecho + final }
        let aviso = "\n\n[CONTEXTO PARCIAL: parte do histórico foi omitida; não trate ausências como fatos.]"
        let disponivel = max(0, teto - fixo - aviso.count)
        guard disponivel > 0 else { return cabeca + aviso + final }
        // O fechamento também tem espaço reservado: cortar a versão antiga
        // não pode deixar o pedido vigente dentro do bloco de referência.
        return cabeca + abertura + String(material.prefix(disponivel)) + fecho + aviso + final
    }

    /// Contexto derivado do registro, compartilhado por entrega e prática.
    /// Mais recente primeiro: a janela não deve priorizar uma tentativa antiga.
    var contextoDeRetorno: String {
        let atos = Dictionary(uniqueKeysWithValues: acoes.map { ($0.id, $0) })
        let materiais = Dictionary(uniqueKeysWithValues: artefatos.map { ($0.id, $0) })
        return evidencias.reversed().map { e in
            let acao = atos[e.acaoID]
            var linhas = ["[\(e.tipo.rawValue), \(e.atribuidaA), \(e.data.ISO8601Format()), ação \(e.acaoID), versão \(e.artefatoID?.uuidString ?? "sem artefato")] \(e.texto)",
                "Ação: \(acao?.texto ?? "referência ausente") · estado registrado: \(acao?.estado.rawValue ?? "desconhecido") · material: \(e.artefatoID?.uuidString ?? "sem artefato")"]
            if let tentativa = e.tentativa {
                let pratica = e.artefatoID.flatMap { materiais[$0]?.pratica }
                if let pratica { linhas.append("Exercício dessa tentativa: \(pratica.enunciado)") }
                linhas.append("Apoio declarado: \(tentativa.apoioUtilizado)")
                if let feedback = tentativa.conferencias?.last {
                    // ADR 08j: a leitura que a pessoa contestou FICA no registro
                    // e sai do contexto: o que ela disse que está errado não
                    // pode continuar orientando o exercício seguinte.
                    if feedback.contestada {
                        linhas.append("Leitura contestada pela pessoa em \(feedback.data.ISO8601Format()) · motivo: \(feedback.motivoDaContestacao ?? "não informado"). NÃO use esta interpretação para orientar o ajuste.")
                    } else {
                        linhas.append("Feedback atribuído a \(feedback.executor) · \(feedback.estado.rawValue):")
                        linhas += feedback.resultados.map { r in
                            let criterio = pratica?.criterios.first { $0.id == r.criterioID }?.texto ?? "critério indisponível"
                            return "\(criterio) · \(r.situacao.rawValue): \(r.observacao) · trecho: \(r.trechoDaTentativa)"
                        }
                        if let motivo = feedback.motivo { linhas.append(motivo) }
                    }
                }
            }
            return linhas.joined(separator: "\n")
        }.joined(separator: "\n\n")
    }
    /// `nil` lista as tentativas feitas SEM exercício preparado: a prática
    /// não depende da IA para existir.
    func tentativas(doArtefato id: UUID?) -> [Evidencia] {
        evidencias.filter { $0.tentativa != nil && $0.artefatoID == id }
    }
    /// O último pedido de prática ficou sem exercício? Só o último conta: a
    /// tela mostra uma linha de recusa, não uma pilha.
    var praticaIndisponivel: Bool { pedidos.last?.estado == .praticaIndisponivel }
    /// ADR 08j: o último pedido era um ajuste cuja causa não coube? Só o
    /// último conta, como na prática indisponível: uma linha, não uma pilha.
    var ajusteIndisponivel: Bool { pedidos.last?.estado == .ajusteIndisponivel }
    var pedidoAtivo: Pedido? { pedidos.last(where: { $0.estado == .preparando }) }
    /// O pedido que produziu esta versão, quando houve um: a rota para conferir
    /// uma versão que ficou sem conferência (ADR 05q). Versão escrita à mão ou
    /// importada não tem pedido, e conferir contra nada não é conferir — só
    /// `receber` cria versão a partir de um pedido, por isso `origem == .ia`:
    /// sem isso, material importado com `anteriorID` nulo casava o PRIMEIRO
    /// pedido e a conferência ficava presa a um texto que ele não gerou.
    /// ADR 08j: o vínculo guardado manda. A inferência abaixo continua só para
    /// registro antigo, e SÓ para achar a rota de conferência da 05q — a causa
    /// que a tela conta ao autor vem de `ajuste(de:)`, que não infere nada.
    func pedidoDe(_ a: Artefato) -> Pedido? {
        if let id = a.pedidoID { return pedidos.first { $0.id == id } }
        guard a.origem == .ia else { return nil }
        return pedidos.last { $0.estado == .pronto && $0.intencaoID == a.intencaoID && $0.artefatoID == a.anteriorID }
    }
    /// ADR 08j: por que esta versão nasceu, quando isso está REGISTRADO.
    /// `nil` = vínculo não registrado (versão anterior ao contrato, escrita à
    /// mão, importada ou pedida sem ajuste). Nunca uma causa reconstruída.
    func ajuste(de a: Artefato) -> Ajuste? {
        guard let id = a.pedidoID else { return nil }
        return pedidos.first { $0.id == id }?.ajuste
    }
    /// A leitura que sustenta um ajuste, quando ela ainda orienta: contestada
    /// pela pessoa, some daqui — a história fica no documento.
    func leituraDoAjuste(_ aj: Ajuste) -> ConferenciaTentativa? {
        guard let evidenciaID = aj.evidenciaID, let conferenciaID = aj.conferenciaID,
              let c = evidencias.first(where: { $0.id == evidenciaID })?
                  .tentativa?.conferencias?.first(where: { $0.id == conferenciaID }),
              !c.contestada else { return nil }
        return c
    }

    mutating func reverIntencao(_ texto: String, resultado: String) throws {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        guard texto != intencaoAtual.texto || resultado != intencaoAtual.resultado else { return }
        cancelarPedido()
        intencoes.append(.init(texto: texto, resultado: resultado))
    }
    @discardableResult
    mutating func iniciarPedido(_ instrucao: String, ajuste: Ajuste? = nil) throws -> Pedido {
        guard !instrucao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        let pedido = Pedido(instrucao: instrucao, intencaoID: intencaoAtual.id,
                            artefatoID: versaoAtual?.id, ajuste: ajuste)
        // A causa é conferida ANTES de tocar no documento: um ajuste recusado
        // não pode deixar para trás um pedido cancelado que ninguém pediu.
        try validarAjuste(pedido)
        cancelarPedido()
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
    /// ADR 08j: a causa não coube na janela. O pedido fica guardado assim e a
    /// tela diz por quê; nada de mandar um pedaço da evidência causal.
    mutating func marcarAjusteIndisponivel(_ id: UUID) {
        guard let i = pedidos.firstIndex(where: { $0.id == id && $0.estado == .preparando }) else { return }
        pedidos[i].estado = .ajusteIndisponivel
    }
    mutating func marcarPraticaIndisponivel(_ id: UUID) {
        guard let i = pedidos.firstIndex(where: { $0.id == id && $0.estado == .preparando }) else { return }
        pedidos[i].estado = .praticaIndisponivel
    }
    mutating func receber(_ texto: String, produtor: String, pedidoID: UUID,
                          pratica: Pratica? = nil, parteDelegada: String? = nil) throws {
        guard let i = pedidos.firstIndex(where: { $0.id == pedidoID && $0.estado == .preparando }),
              pedidos[i].intencaoID == intencaoAtual.id,
              pedidos[i].artefatoID == versaoAtual?.id else { throw Erro.pedidoAntigo }
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        if let parteDelegada {
            guard pratica != nil, !parteDelegada.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  texto.contains(parteDelegada) else { throw Erro.vazio }
        }
        artefatos.append(.init(conteudo: texto, origem: .ia, produtor: produtor,
                              intencaoID: intencaoAtual.id, anteriorID: pedidos[i].artefatoID,
                              pedidoID: pedidoID, pratica: pratica, parteDelegada: parteDelegada))
        pedidos[i].estado = .pronto
    }

    /// ADR 05r: a resposta do autor entra como EVIDÊNCIA da ação ligada ao
    /// material, nunca como versão — `guardarVersaoHumana` criaria origem
    /// mista e trocaria a versão vigente pela resposta de um exercício.
    /// A primeira tentativa nunca é sobrescrita: cada guardar acrescenta.
    /// Guardar não marca ação executada nem capacidade adquirida.
    /// `artefatoID` nil é tentativa SEM exercício preparado (a IA não o
    /// produziu ou não há conta): a prática da pessoa não depende disso.
    @discardableResult
    mutating func guardarTentativa(_ texto: String, apoioUtilizado: String,
                                   artefatoID: UUID?, anteriorID: UUID? = nil) throws -> Evidencia {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !apoioUtilizado.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        if let artefatoID {
            guard let artefato = artefatos.first(where: { $0.id == artefatoID }),
                  artefato.pratica != nil else { throw Erro.referencia }
        }
        if let anteriorID {
            guard evidencias.contains(where: { $0.id == anteriorID && $0.tentativa != nil }) else { throw Erro.referencia }
        }
        // A tentativa é um ATO sobre este material. Reusa a ação que já existe
        // para ele; só cria uma quando não há nenhuma, e ela nasce pendente.
        // Sem material, só a ação própria da prática serve: um ato que a
        // pessoa preparou ("Ensaiar") não recebe tentativa alheia.
        let textoDaAcao = artefatoID == nil ? Self.acaoDaPraticaLivre : "Fazer o exercício preparado"
        let acaoID: UUID
        if let existente = acoes.first(where: {
            $0.artefatoID == artefatoID && $0.estado != .cancelada && (artefatoID != nil || $0.texto == textoDaAcao)
        }) {
            acaoID = existente.id
        } else {
            let nova = Acao(texto: textoDaAcao, artefatoID: artefatoID)
            acoes.append(nova)
            acaoID = nova.id
        }
        let evidencia = Evidencia(tipo: .tentativa, texto: texto, atribuidaA: "Você",
                                  acaoID: acaoID, artefatoID: artefatoID,
                                  tentativa: .init(apoioUtilizado: apoioUtilizado, anteriorID: anteriorID))
        evidencias.append(evidencia)
        return evidencia
    }

    /// Feedback nunca sobrescreve a resposta: acrescenta uma leitura à
    /// tentativa. Reavaliar a mesma tentativa não cria outra demonstração.
    mutating func registrarConferenciaDaTentativa(_ c: ConferenciaTentativa, em evidenciaID: UUID) throws {
        guard let i = evidencias.firstIndex(where: { $0.id == evidenciaID }),
              var tentativa = evidencias[i].tentativa else { throw Erro.referencia }
        tentativa.conferencias = (tentativa.conferencias ?? []) + [c]
        evidencias[i].tentativa = tentativa
    }

    /// ADR 08j: a correção do dono sobre uma LEITURA. Não apaga a conferência
    /// nem a tentativa: marca que aquela interpretação está contestada, e a
    /// partir daí ela não entra mais no contexto que orienta um ajuste.
    /// Contestar de novo só troca o motivo; nunca cria uma segunda leitura.
    mutating func contestarLeitura(_ conferenciaID: UUID, em evidenciaID: UUID, motivo: String) throws {
        let limpo = motivo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty else { throw Erro.vazio }
        guard let i = evidencias.firstIndex(where: { $0.id == evidenciaID }),
              var tentativa = evidencias[i].tentativa,
              let j = tentativa.conferencias?.firstIndex(where: { $0.id == conferenciaID })
        else { throw Erro.referencia }
        tentativa.conferencias?[j].contestadaEm = .now
        tentativa.conferencias?[j].motivoDaContestacao = limpo
        evidencias[i].tentativa = tentativa
    }

    /// A dificuldade, proposta por quem de fato a propôs. Sem evidências
    /// pertinentes selecionadas, a lista fica vazia — apontar todas as
    /// evidências do Trabalho seria inventar pertinência.
    @discardableResult
    mutating func proporHipotese(_ texto: String, propostaPor: String,
                                 evidencias pertinentes: [UUID] = []) throws -> Hipotese {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        let conhecidas = Set(self.evidencias.map(\.id))
        guard pertinentes.allSatisfy({ conhecidas.contains($0) }) else { throw Erro.referencia }
        let h = Hipotese(texto: texto, contexto: intencaoAtual.texto, evidencias: pertinentes,
                         propostaPor: propostaPor)
        hipoteses.append(h)
        return h
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
    /// Só a pessoa avalia, e "faz sentido neste contexto" é concordância
    /// contextual — nunca certificação do app nem declaração de aprendizagem.
    mutating func avaliarHipotese(_ id: UUID, estado: EstadoHipotese, motivo: String? = nil) throws {
        guard let i = hipoteses.firstIndex(where: { $0.id == id }) else { throw Erro.referencia }
        cancelarPedido()
        hipoteses[i].estado = estado
        hipoteses[i].avaliadaPor = estado == .proposta ? nil : "Você"
        hipoteses[i].avaliadaEm = estado == .proposta ? nil : .now
        let limpo = motivo?.trimmingCharacters(in: .whitespacesAndNewlines)
        hipoteses[i].motivoAvaliacao = estado == .proposta || (limpo ?? "").isEmpty ? nil : limpo
    }
    /// ADR 08j: a causa registrada tem de ser verdadeira no próprio documento.
    /// `necessidadePercebida` exige a tentativa E a leitura que a sustentam —
    /// o app não diz "percebi" sem apontar o que leu. Os critérios citados são
    /// os do exercício daquela tentativa: nenhum critério inventado entra.
    func validarAjuste(_ p: Pedido) throws {
        guard let aj = p.ajuste else { return }
        guard !aj.motivo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Erro.vazio }
        if aj.gatilho == .necessidadePercebida {
            guard aj.evidenciaID != nil, aj.conferenciaID != nil else { throw Erro.referencia }
        }
        guard let evidenciaID = aj.evidenciaID else {
            guard aj.conferenciaID == nil, aj.criterioIDs.isEmpty else { throw Erro.referencia }
            return
        }
        guard let evidencia = evidencias.first(where: { $0.id == evidenciaID }),
              let tentativa = evidencia.tentativa else { throw Erro.referencia }
        if let conferenciaID = aj.conferenciaID {
            guard tentativa.conferencias?.contains(where: { $0.id == conferenciaID }) ?? false else { throw Erro.referencia }
        }
        let criterios = Set(evidencia.artefatoID
            .flatMap { id in artefatos.first { $0.id == id }?.pratica?.criterios.map(\.id) } ?? [])
        guard Set(aj.criterioIDs).isSubset(of: criterios) else { throw Erro.referencia }
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
            // ADR 08j: o vínculo guardado aponta para um pedido que existe e que
            // de fato tinha esta versão como base. Um ponteiro que não fecha
            // explicaria a mudança errada — pior que não explicar.
            if let pedidoID = a.pedidoID {
                guard let p = pedidos.first(where: { $0.id == pedidoID }),
                      p.intencaoID == a.intencaoID, p.artefatoID == a.anteriorID else { throw Erro.referencia }
            }
            if let parteDelegada = a.parteDelegada {
                guard a.pratica != nil, !parteDelegada.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      a.conteudo.contains(parteDelegada) else { throw Erro.referencia }
            }
            if let p = a.pratica {
                let criterioIDs = Set(p.criterios.map(\.id))
                guard !p.criterios.isEmpty, criterioIDs.count == p.criterios.count,
                      p.criterios.allSatisfy({ !$0.texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
                      p.hipoteseID.map({ id in hipoteses.contains { $0.id == id } }) ?? true else { throw Erro.referencia }
            }
            guard let cs = a.conferencias else { continue }
            guard Set(cs.map(\.id)).count == cs.count,
                  cs.allSatisfy({ pedidoIDs.contains($0.pedidoID) }) else { throw Erro.referencia }
        }
        for a in acoes where !(a.artefatoID.map(artefatoIDs.contains) ?? true) { throw Erro.referencia }
        for a in acoes where a.agendadaEm == nil && a.avisoMinutos != nil { throw Erro.referencia }
        for e in evidencias {
            guard let a = acoes.first(where: { $0.id == e.acaoID }), a.artefatoID == e.artefatoID else { throw Erro.referencia }
            guard let t = e.tentativa else { continue }
            guard e.tipo == .tentativa, t.origem == .pessoa,
                  t.anteriorID.map({ id in id != e.id && evidencias.contains { $0.id == id && $0.tentativa != nil } }) ?? true
            else { throw Erro.referencia }
            // Tentativa ligada a material responde a um exercício: o material
            // precisa ter prática (ADR 05r). Sem material é prática por conta
            // própria — e sem critérios não há feedback a carregar.
            guard let artefatoID = e.artefatoID else {
                guard t.conferencias?.isEmpty ?? true else { throw Erro.referencia }
                continue
            }
            guard let pratica = artefatos.first(where: { $0.id == artefatoID })?.pratica else { throw Erro.referencia }
            guard let cs = t.conferencias else { continue }
            let criterioIDs = Set(pratica.criterios.map(\.id))
            guard Set(cs.map(\.id)).count == cs.count,
                  cs.allSatisfy({ c in
                      Set(c.resultados.map(\.id)).count == c.resultados.count
                          && c.resultados.allSatisfy { criterioIDs.contains($0.criterioID) }
                  }) else { throw Erro.referencia }
        }
        for h in hipoteses where !h.evidencias.allSatisfy(evidenciaIDs.contains) { throw Erro.referencia }
        for p in pedidos {
            guard intencaoIDs.contains(p.intencaoID), p.artefatoID.map(artefatoIDs.contains) ?? true else { throw Erro.referencia }
            try validarAjuste(p)
        }
    }
}
