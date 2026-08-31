import SwiftData
import SwiftUI

struct ConfirmacaoView: View {
    let estado: ConfirmacaoEstado
    let sessao: Sessao
    let context: ModelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var materializado = false

    var body: some View {
        ZStack {
            // material de verdade, não tinta chapada: o fundo recua com profundidade
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .ignoresSafeArea()
            Tema.fundo
                .opacity(0.55)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch estado {
                    case .sairTranca(let destino):
                        titulo("Sair agora tranca.")
                        texto("A escrita expressiva fecha a porta de qualquer jeito — dentro ou fora do tempo. Você escolhe qual: selar ou queimar.")
                        botao("Continuar escrevendo", id: "confirmacao-continuar") { sessao.confirmacao = nil }
                        botaoMudo("Fechar a escrita", id: "confirmacao-trancar") {
                            Task {
                                try? await Task.sleep(for: .milliseconds(220))
                                // §8: sair não tranca sozinho — abre a escolha
                                sessao.abrirFecho(no: context)
                            }
                        }
                    case .trancada(let destino):
                        titulo("Trancada.")
                        texto("A escrita expressiva não se relê. A porta fechou — e é isso que faz o método funcionar.")
                        botao(rotuloDestino(destino), id: "confirmacao-seguir") {
                            fecharTrancada(destino)
                        }
                    case .naoSeRele(let uuid):
                        titulo("Não se relê.")
                        texto("Reler o desabafo reacende o que a escrita encerrou.")
                        botao("Deixar fechada", id: "confirmacao-deixar") { sessao.confirmacao = nil }
                        botaoMudo("Abrir mesmo assim", id: "confirmacao-abrir") { sessao.confirmacao = .insistirReabrir(uuid) }
                    case .insistirReabrir(let uuid):
                        titulo("Ela foi escrita para ficar fechada.")
                        botao("Deixar fechada", id: "confirmacao-deixar") { sessao.confirmacao = nil }
                        botaoMudo(Biometria.disponivel ? "Abrir com Face ID" : "Abrir assim mesmo",
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
                        titulo("Apagar esta nota?")
                        texto("O traço some do aparelho — e a revisão marcada some com ele.")
                        botao("Manter", id: "confirmacao-manter") { sessao.confirmacao = nil }
                        botaoDestrutivo("Apagar", id: "confirmacao-apagar") { sessao.apagar(uuid: uuid, no: context) }
                    case .apagarTrancada(let uuid):
                        titulo("Apagar a trancada?")
                        texto("Ela foi escrita para ficar fechada. Apagar apaga para sempre — sem reler.")
                        botao("Manter", id: "confirmacao-manter") { sessao.confirmacao = nil }
                        botaoDestrutivo("Apagar para sempre", id: "confirmacao-apagar-trancada") { sessao.apagar(uuid: uuid, no: context) }
                    }
                }
                .padding(28)
                .frame(maxWidth: 360, alignment: .leading)
            }
            .scaleEffect(materializado || reduceMotion ? 1 : 1.04)
            .blur(radius: materializado || reduceMotion ? 0 : 6)
            .opacity(materializado || reduceMotion ? 1 : 0)
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.18) : .easeOut(duration: Tema.confirmacaoEntra)) {
                materializado = true
            }
        }
        .onChange(of: estado) { _, _ in
            if reduceMotion { return }
            materializado = false
            withAnimation(.easeOut(duration: Tema.confirmacaoEntra)) { materializado = true }
        }
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { escapar() }
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

    private func titulo(_ t: String) -> some View {
        Text(t)
            .font(Tema.confirmacaoTitulo)
            .foregroundStyle(Tema.tinta)
            .accessibilityAddTraits(.isHeader)
    }

    private func texto(_ t: String) -> some View {
        Text(t)
            .font(Tema.confirmacaoCorpo)
            .foregroundStyle(Tema.tintaSuave)
    }

    private func botao(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.barra)
            .foregroundStyle(Tema.ambar)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }

    private func botaoMudo(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.chrome)
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }

    private func botaoDestrutivo(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.chrome)
            .foregroundStyle(Tema.aviso)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }
}
