import Foundation
import Observation

/// Uma tentativa pertence à conversa que a iniciou. Cancelar a Task ajuda
/// o serviço; a identidade impede efeitos tardios mesmo se ele ignorar o cancelamento.
@MainActor
@Observable
final class ConversaNotas {
    enum Estado: Equatable {
        case ociosa
        /// A hora em que a espera começou viaja com a pergunta, como no
        /// `CartaoAnalisar.sabiaPensando` da Página: a conversa vive na SESSÃO
        /// (ADR 09c) e a `NotasView` é recriada a cada troca de aba — um
        /// relógio guardado na view mentiria na volta.
        case pensando(String, desde: Date)
        case falhou(String)
        case interrompida(String)
        case recolhida(String)
    }

    struct Resultado {
        var resposta: String?
        /// As notas que foram junto, com identidade: a tela as mostra como
        /// títulos tocáveis, uma vez cada (§14).
        var fontes: [FonteNotas] = []
        var dependencias: [FonteNotas] = []
        var fontesCitadas: [FonteNotas] = []
        var conversaValida: [Sessao.TrocaNasNotas]? = nil
        var fontesMudaram = false
        /// Nome da obra que a guarda recusou. A folha oferece plantar.
        var obraParaPlantar: String? = nil
        /// E7/E6c: o recibo do que ficou fora e por quê, inclusive o corte da escolha (gatilho do índice).
        var fora: [String] = []
    }
    typealias Responder = @MainActor (String, [Sessao.TrocaNasNotas]) async -> Resultado

    /// A pergunta em escrita, na linha "?" da folha.
    var entrada = ""
    /// A busca em escrita, na linha da lista. Vive aqui (e não na view) pelo
    /// mesmo motivo da conversa: a `NotasView` é recriada a cada troca de aba.
    var busca = ""
    /// DIRETRIZ §14 (complemento): buscar e perguntar são duas intenções e não
    /// dividem um campo. Perguntar é o gesto do Traço — a marca "?" — e abre a
    /// folha com a linha "?" em branco; sai-se por Fechar. Com conversa aberta,
    /// a folha já está aberta e a linha "?" no pé dela é a continuação.
    var perguntando = false
    /// Voltar às notas RECOLHE a conversa, não a apaga (auditoria 16/09 noite:
    /// sair perdia a resposta sem caminho de volta); a lista oferece continuar.
    var recolhida = false
    var modoPergunta: Bool { !recolhida && (perguntando || temCartao) }

    /// Volta à lista guardando a conversa (e a espera, se ainda pensa).
    func recolher() {
        perguntando = false
        recolhida = temCartao
    }
    /// As respostas já avaliadas ("anotado."). Vive AQUI, não na view: a
    /// `NotasView` é recriada a cada troca de aba (ADR 09c), e guardada nela a
    /// avaliação voltava a ser oferecida — visto no aparelho da conta em
    /// 10/09, 15h41: "serviu / não serviu" de volta depois de ir ao Perfil.
    var avaliadas: Set<String> = []
    /// Oferta da guarda de obra. Vive aqui: a `NotasView` recria a cada aba.
    var obraParaPlantar: String? = nil
    private(set) var trocas: [Sessao.TrocaNasNotas] = []
    private(set) var estado: Estado = .ociosa
    private(set) var semModelo = false
    private(set) var fontes: [FonteNotas] = []
    @ObservationIgnored private var tarefa: Task<Void, Never>?
    @ObservationIgnored private var tentativa: UUID?

    var pensando: Bool { esperandoDesde != nil }

    /// Desde quando a sábia está pensando, ou nil se não está.
    var esperandoDesde: Date? {
        if case .pensando(_, let desde) = estado { return desde }
        return nil
    }

    var perguntaParaRepetir: String? {
        switch estado {
        case .falhou(let pergunta), .interrompida(let pergunta), .recolhida(let pergunta): pergunta
        default: nil
        }
    }

    var temCartao: Bool { estado != .ociosa || semModelo || !trocas.isEmpty }

    #if DEBUG
    /// Instrumento de evidência, só em Debug, e só sobre o SINAL DE SOBRA: o
    /// simulador de teste não tem conta Grok e o aparelho que tem é o da conta,
    /// onde a suíte não corre. Sem isto a resposta longa não se testa — e uma
    /// afordância que nenhum teste vê volta a sumir na próxima volta. Não
    /// fabrica token e não chama rede: o texto é uma resposta MEDIDA de verdade
    /// (`prova/lote09b-q3-grok-4.6.jsonl`, caso `q3-gasto-cotacao-na-nota`, a
    /// mais longa das 18 corridas de 09-10/09).
    /// Liga com `simctl launch <UDID> app.traco -ensaio-resposta-longa-nas-notas`.
    static let ensaioDaRespostaLonga = ProcessInfo.processInfo.arguments.contains("-ensaio-resposta-longa-nas-notas")

    /// O irmão para a ESPERA (DIRETRIZ §13 item 3): semeia `.pensando` sem
    /// tarefa nenhuma em voo, para a suíte ver pensando, tempo e parar de
    /// esperar sem gastar uma chamada — o aparelho da conta é o recurso mais
    /// caro que temos. Liga com `-ensaio-espera-nas-notas`.
    static let ensaioDaEspera = ProcessInfo.processInfo.arguments.contains("-ensaio-espera-nas-notas")

    /// 568 grafemas. Sem dependências: `Sessao.dependenciasValidas([])` é
    /// verdadeiro, então a revalidação da tela não a recolhe.
    static let respostaMedida = """
    Você anotou hospedagem de 400 euros e transporte de 120 euros (520 euros no total). Com o câmbio do banco de hoje, R$ 6,45 por euro já com IOF, isso dá R$ 3.354 (400×6,45 = R$ 2.580; 120×6,45 = R$ 774). Você reservou R$ 6.000 para a viagem, então esse trecho cabe no orçamento. Em 02/09 o euro estava a R$ 6,10, mas você mesmo anotou que isso muda todo dia; não sei a cotação de mercado neste instante — confirme no banco ou app de câmbio se for pagar agora.
    Referência: “Orçamento da viagem — 02/09/2026”; “Lista de gastos — 05/09/2026”; “Câmbio de hoje — 09/09/2026”
    """
    #endif

    init() {
        #if DEBUG
        if Self.ensaioDaRespostaLonga {
            trocas = [.init(pergunta: "Quanto vou gastar em reais com hospedagem e transporte na viagem?",
                            resposta: Self.respostaMedida)]
            // as fontes vão junto porque a linha delas é parte do cartão e do
            // seu tamanho: sem elas o ensaio media um cartão que não existe.
            // São os quatro títulos do aparelho da conta em 10/09.
            fontes = ["Reservei R$ 6000 para a viagem. Hospedagem 400 euros. Transporte 120 euros. Hoje o banco me cobrou R$ 6,45 por euro.",
                      "Vou de carro a Fortaleza no fim do mês. Medi no mapa: são 600 km só de ida. Não sei o consumo do carro nem o preço do litro.",
                      "Plano da semana",
                      "Proposta para o cliente da padaria"]
                .map { FonteNotas(id: UUID(), titulo: $0, texto: $0, editadaEm: .now) }
        }
        if Self.ensaioDaEspera {
            estado = .pensando("Quanto ainda me falta no pretérito?", desde: .now)
        }
        #endif
    }

    @discardableResult
    func perguntar(disponivel: Bool, responder: @escaping Responder) -> Task<Void, Never>? {
        let pergunta = entrada
        guard !pergunta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !pensando else { return nil }
        guard disponivel else { semModelo = true; return nil }
        entrada = ""
        return iniciar(pergunta, responder: responder)
    }

    /// Repetir atua na pergunta guardada, nunca no texto que a pessoa já
    /// começou a escrever na busca enquanto aguardava a resposta.
    @discardableResult
    func repetir(disponivel: Bool, responder: @escaping Responder) -> Task<Void, Never>? {
        guard let pergunta = perguntaParaRepetir else { return nil }
        guard disponivel else { semModelo = true; return nil }
        return iniciar(pergunta, responder: responder)
    }

    private func iniciar(_ pergunta: String, responder: @escaping Responder) -> Task<Void, Never> {
        invalidarTentativa()
        obraParaPlantar = nil
        let id = UUID()
        tentativa = id
        estado = .pensando(pergunta, desde: .now)
        semModelo = false
        let anteriores = trocas
        let nova = Task { [weak self] in
            let resultado = await responder(pergunta, anteriores)
            guard !Task.isCancelled, let self, self.tentativa == id else { return }
            self.tentativa = nil
            self.tarefa = nil
            if let validas = resultado.conversaValida {
                self.trocas = validas
                self.fontes = []
            }
            // Q6 / ADR 12a: se a fonte mudou ou o selo caiu no await, a
            // resposta que chegou já é derivação recusada — a pergunta fica
            // para repetir. Resposta e `fontesMudaram` juntos não publicam.
            if resultado.fontesMudaram {
                self.fontes = []
                self.obraParaPlantar = nil
                self.estado = .recolhida(pergunta)
            } else if let resposta = resultado.resposta {
                self.trocas.append(.init(pergunta: pergunta, resposta: resposta, dependencias: resultado.dependencias))
                self.fontes = resultado.fontes
                self.obraParaPlantar = resultado.obraParaPlantar
                self.estado = .ociosa
            } else {
                self.obraParaPlantar = nil
                self.estado = .falhou(pergunta)
            }
        }
        tarefa = nova
        return nova
    }

    /// Sair da tela não perde o pedido interrompido nem o rascunho seguinte.
    func interromper() {
        if case .pensando(let pergunta, _) = estado {
            invalidarTentativa()
            estado = .interrompida(pergunta)
        }
    }

    /// O cartão já exibido também é derivação: revogar a fonte recolhe a
    /// resposta, não apenas impede a próxima chamada. A pergunta fica para retry.
    @discardableResult
    func revalidarFontes(_ permitidas: ([FonteNotas]) -> Bool) -> Bool {
        let ultima = trocas.last
        let validas = trocas.filter { permitidas($0.dependencias) }
        guard validas.count != trocas.count else { return false }
        trocas = validas
        avaliadas = []
        obraParaPlantar = nil
        if case .pensando(let pergunta, _) = estado {
            invalidarTentativa()
            fontes = []
            estado = .recolhida(pergunta)
        } else if let ultima, !permitidas(ultima.dependencias) {
            fontes = []
            estado = .recolhida(perguntaParaRepetir ?? ultima.pergunta)
        }
        return true
    }

    /// ADR 05e: Fechar descarta a conversa, mas não a busca em edição.
    func fechar() {
        recolhida = false
        invalidarTentativa()
        estado = .ociosa
        semModelo = false
        trocas = []
        fontes = []
        perguntando = false
        avaliadas = []
        obraParaPlantar = nil
    }

    private func invalidarTentativa() {
        tentativa = nil
        tarefa?.cancel()
        tarefa = nil
    }
}
