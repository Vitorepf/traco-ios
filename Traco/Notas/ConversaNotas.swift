import Foundation
import Observation

/// Uma tentativa pertence à conversa que a iniciou. Cancelar a Task ajuda
/// o serviço; a identidade impede efeitos tardios mesmo se ele ignorar o cancelamento.
@MainActor
@Observable
final class ConversaNotas {
    enum Estado: Equatable {
        case ociosa
        case pensando(String)
        case falhou(String)
        case interrompida(String)
        case recolhida(String)
    }

    struct Resultado {
        var resposta: String?
        var titulos: [String]
        var dependencias: [FonteNotas] = []
        var fontesCitadas: [FonteNotas] = []
        var conversaValida: [Sessao.TrocaNasNotas]? = nil
        var fontesMudaram = false
    }
    typealias Responder = @MainActor (String, [Sessao.TrocaNasNotas]) async -> Resultado

    var entrada = ""
    private(set) var trocas: [Sessao.TrocaNasNotas] = []
    private(set) var estado: Estado = .ociosa
    private(set) var semModelo = false
    private(set) var titulos: [String] = []
    @ObservationIgnored private var tarefa: Task<Void, Never>?
    @ObservationIgnored private var tentativa: UUID?

    var pensando: Bool {
        if case .pensando = estado { return true }
        return false
    }

    var perguntaParaRepetir: String? {
        switch estado {
        case .falhou(let pergunta), .interrompida(let pergunta), .recolhida(let pergunta): pergunta
        default: nil
        }
    }

    var temCartao: Bool { estado != .ociosa || semModelo || !trocas.isEmpty }

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
        let id = UUID()
        tentativa = id
        estado = .pensando(pergunta)
        semModelo = false
        let anteriores = trocas
        let nova = Task { [weak self] in
            let resultado = await responder(pergunta, anteriores)
            guard !Task.isCancelled, let self, self.tentativa == id else { return }
            self.tentativa = nil
            self.tarefa = nil
            if let validas = resultado.conversaValida {
                self.trocas = validas
                self.titulos = []
            }
            if let resposta = resultado.resposta {
                self.trocas.append(.init(pergunta: pergunta, resposta: resposta, dependencias: resultado.dependencias))
                self.titulos = resultado.titulos
                self.estado = .ociosa
            } else {
                self.estado = resultado.fontesMudaram ? .recolhida(pergunta) : .falhou(pergunta)
            }
        }
        tarefa = nova
        return nova
    }

    /// Sair da tela não perde o pedido interrompido nem o rascunho seguinte.
    func interromper() {
        if case .pensando(let pergunta) = estado {
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
        if case .pensando(let pergunta) = estado {
            invalidarTentativa()
            titulos = []
            estado = .recolhida(pergunta)
        } else if let ultima, !permitidas(ultima.dependencias) {
            titulos = []
            estado = .recolhida(perguntaParaRepetir ?? ultima.pergunta)
        }
        return true
    }

    /// ADR 05e: Fechar descarta a conversa, mas não a busca em edição.
    func fechar() {
        invalidarTentativa()
        estado = .ociosa
        semModelo = false
        trocas = []
        titulos = []
    }

    private func invalidarTentativa() {
        tentativa = nil
        tarefa?.cancel()
        tarefa = nil
    }
}
