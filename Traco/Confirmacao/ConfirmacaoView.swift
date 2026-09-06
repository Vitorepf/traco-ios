import SwiftData
import SwiftUI

struct ConfirmacaoView: View {
    let estado: ConfirmacaoEstado
    let sessao: Sessao
    let context: ModelContext

    var body: some View {
        // ADR 06c: a casca é uma só — `FolhaDeConfirmacao`. Aqui a folha
        // RENASCE a cada assunto (`refazerEm: estado`): a confirmação encadeia
        // perguntas, e a escala marca que a pergunta é outra.
        FolhaDeConfirmacao(refazerEm: estado, aoEscapar: escapar) {
            switch estado {
            case .sairTranca(let destino):
                Folha.titulo("Sair agora tranca.")
                Folha.texto("A escrita expressiva fecha a porta de qualquer jeito — dentro ou fora do tempo. Você escolhe qual: selar ou queimar.")
                Folha.botao("Continuar escrevendo", id: "confirmacao-continuar") { sessao.confirmacao = nil }
                Folha.botaoMudo("Fechar a escrita", id: "confirmacao-trancar") {
                    Task {
                        try? await Task.sleep(for: .milliseconds(220))
                        // §8: sair não tranca sozinho — abre a escolha.
                        // §15: e o DESTINO se preserva — quem tocou em
                        // Notas com o timer de pé ia parar na página.
                        sessao.abrirFecho(no: context, destino: destino)
                    }
                }
            case .trancada(let destino):
                Folha.titulo("Trancada.")
                Folha.texto("A escrita expressiva não se relê. A porta fechou — e é isso que faz o método funcionar.")
                Folha.botao(rotuloDestino(destino), id: "confirmacao-seguir") {
                    fecharTrancada(destino)
                }
            case .naoSeRele(let uuid):
                Folha.titulo("Não se relê.")
                Folha.texto("Reler o desabafo reacende o que a escrita encerrou.")
                Folha.botao("Deixar fechada", id: "confirmacao-deixar") { sessao.confirmacao = nil }
                Folha.botaoMudo("Abrir mesmo assim", id: "confirmacao-abrir") { sessao.confirmacao = .insistirReabrir(uuid) }
            case .insistirReabrir(let uuid):
                Folha.titulo("Ela foi escrita para ficar fechada.")
                Folha.botao("Deixar fechada", id: "confirmacao-deixar") { sessao.confirmacao = nil }
                Folha.botaoMudo(Biometria.disponivel ? "Abrir com Face ID" : "Abrir assim mesmo",
                          id: "confirmacao-insistir") {
                    // SPEC §8: o último degrau do atrito é o seu rosto —
                    // ninguém com o telefone destravado na mão passa daqui
                    Task {
                        guard await Biometria.pedir("Abrir uma escrita selada") else { return }
                        sessao.confirmacao = nil
                        if let nota = Sessao.buscar(uuid: uuid, no: context) {
                            sessao.abrir(nota, mesmoTrancada: true)
                        }
                    }
                }
            case .apagar(let uuid):
                Folha.titulo("Apagar esta nota?")
                Folha.texto("O traço some do aparelho — e a revisão marcada some com ele.")
                Folha.botao("Manter", id: "confirmacao-manter") { sessao.confirmacao = nil }
                Folha.botaoDestrutivo("Apagar", id: "confirmacao-apagar") { sessao.apagar(uuid: uuid, no: context) }
            case .apagarTrancada(let uuid):
                Folha.titulo("Apagar a trancada?")
                Folha.texto("Ela foi escrita para ficar fechada. Apagar apaga para sempre — sem reler.")
                Folha.botao("Manter", id: "confirmacao-manter") { sessao.confirmacao = nil }
                Folha.botaoDestrutivo("Apagar para sempre", id: "confirmacao-apagar-trancada") { sessao.apagar(uuid: uuid, no: context) }
            }
        }
    }

    private func fecharTrancada(_ destino: DestinoConfirmacao) {
        sessao.confirmacao = nil
        switch destino {
        case .pagina: break
        case .notas: sessao.mostrarNotas = true
        case .recordar: sessao.mostrarRecordar = true
        }
    }

    /// Escape = o caminho que não destrói: continuar, ou deixar fechada.
    private func escapar() {
        switch estado {
        case .sairTranca:
            sessao.confirmacao = nil
        case .trancada(let destino):
            fecharTrancada(destino)
        case .naoSeRele, .insistirReabrir, .apagar, .apagarTrancada:
            sessao.confirmacao = nil
        }
    }

    private func rotuloDestino(_ destino: DestinoConfirmacao) -> String {
        switch destino {
        case .pagina: "Voltar à página"
        case .notas: "Ir às notas"
        case .recordar: "Recordar o que ficou"
        }
    }
}
