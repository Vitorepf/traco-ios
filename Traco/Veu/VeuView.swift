import SwiftData
import SwiftUI

struct VeuView: View {
    let estado: VeuEstado
    let sessao: Sessao
    let context: ModelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var materializado = false

    var body: some View {
        ZStack {
            Tema.fundo
                .opacity(0.92)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch estado {
                    case .sairTranca(let destino):
                        titulo("Sair agora tranca.")
                        texto("A escrita expressiva fecha a porta de qualquer jeito — dentro ou fora do tempo.")
                        botao("Continuar escrevendo", id: "veu-continuar") { sessao.veu = nil }
                        botaoMudo("Trancar e sair", id: "veu-trancar") {
                            Task {
                                try? await Task.sleep(for: .milliseconds(220))
                                sessao.trancarESair(no: context, destino: destino)
                            }
                        }
                    case .trancada(let destino):
                        titulo("Trancada.")
                        texto("A escrita expressiva não se relê. A porta fechou — e é isso que faz o método funcionar.")
                        botao(rotuloDestino(destino), id: "veu-seguir") {
                            fecharTrancada(destino)
                        }
                    case .naoSeRele(let uuid):
                        titulo("Não se relê.")
                        texto("Reler o desabafo reacende o que a escrita encerrou.")
                        botao("Deixar fechada", id: "veu-deixar") { sessao.veu = nil }
                        botaoMudo("Abrir mesmo assim", id: "veu-abrir") { sessao.veu = .insistirReabrir(uuid) }
                    case .insistirReabrir(let uuid):
                        titulo("Ela foi escrita para ficar fechada.")
                        botao("Deixar fechada", id: "veu-deixar") { sessao.veu = nil }
                        botaoMudo("Abrir assim mesmo", id: "veu-insistir") {
                            sessao.veu = nil
                            if let nota = Sessao.buscar(uuid: uuid, no: context) {
                                sessao.abrir(nota, mesmoTrancada: true)
                            }
                        }
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
            withAnimation(reduceMotion ? .easeOut(duration: 0.18) : .easeOut(duration: Tema.veuEntra)) {
                materializado = true
            }
        }
        .onChange(of: estado) { _, _ in
            if reduceMotion { return }
            materializado = false
            withAnimation(.easeOut(duration: Tema.veuEntra)) { materializado = true }
        }
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { escapar() }
    }

    private func fecharTrancada(_ destino: DestinoVeu) {
        sessao.veu = nil
        switch destino {
        case .pagina: break
        case .pilha: sessao.mostrarPilha = true
        case .puxar: sessao.mostrarPuxar = true
        }
    }

    /// Escape = o caminho que não destrói: continuar, ou deixar fechada.
    private func escapar() {
        switch estado {
        case .sairTranca:
            sessao.veu = nil
        case .trancada(let destino):
            fecharTrancada(destino)
        case .naoSeRele, .insistirReabrir:
            sessao.veu = nil
        }
    }

    private func rotuloDestino(_ destino: DestinoVeu) -> String {
        switch destino {
        case .pagina: "Voltar à página"
        case .pilha: "Ir à pilha"
        case .puxar: "Puxar o que ficou"
        }
    }

    private func titulo(_ t: String) -> some View {
        Text(t)
            .font(Tema.veuTitulo)
            .foregroundStyle(Tema.tinta)
            .accessibilityAddTraits(.isHeader)
    }

    private func texto(_ t: String) -> some View {
        Text(t)
            .font(Tema.veuCorpo)
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
}
