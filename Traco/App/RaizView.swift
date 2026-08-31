import SwiftData
import SwiftUI

/// A raiz (SPEC §20 rev.2): a página em branco é a CASA e não tem chrome nenhum.
/// O arquivo (Notas · Padrões · Perfil) é uma camada ao lado, com barra própria.
/// Vai-se e volta-se por gesto — escrever nunca divide a tela com navegação.
struct RaizView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sessao = Sessao()
    @State private var tecladoAberto = false

    private var arquivoAberto: Binding<Bool> {
        Binding(
            get: { sessao.aba != .escrever },
            set: { abrir in sessao.irPara(abrir ? sessao.abaArquivo : .escrever, no: context) }
        )
    }

    var body: some View {
        Camadas(
            arquivoAberto: arquivoAberto,
            // o gesto vive SEMPRE: ele nasce nos 28pt da borda, longe da seleção
            // de texto — matá-lo com o teclado de pé criava atrito depois de
            // concluir uma nota (o teclado volta e a saída sumia)
            gestoAtivo: true,
            reduceMotion: reduceMotion
        ) {
            ZStack(alignment: .bottom) {
                Tema.fundo.ignoresSafeArea()
                Group {
                    switch sessao.abaArquivo {
                    case .padroes: PadroesView(sessao: sessao)
                    case .perfil: PerfilView(sessao: sessao)
                    default: NotasView(sessao: sessao)
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: tecladoAberto ? 0 : Tema.barraNav)
                }
                // sem animação na troca de aba: saída em corte + entrada em fade
                // deixava um quadro inteiramente VAZIO no meio (k423). Troca
                // seca não tem vão — e aba não tem direção espacial mesmo.
                .transaction { t in t.animation = nil }

                // a barra vive DENTRO da camada: fora dela andava 34px enquanto
                // o corpo andava 233px, e não era recortada pela borda
                BarraNavegacao(
                    aba: Binding(
                        get: { sessao.abaArquivo },
                        set: { nova in sessao.irPara(nova, no: context) }
                    ),
                    escondida: tecladoAberto,
                    aoNovaNota: {
                        sessao.salvar(no: context)
                        sessao.novaPagina()
                        sessao.irPara(.escrever, no: context)
                    }
                )
            }
        } escrita: {
            ZStack(alignment: .leading) {
                Tema.fundo.ignoresSafeArea()
                PaginaView(sessao: sessao)
                if !tecladoAberto {
                    AbaArquivo { sessao.irPara(sessao.abaArquivo, no: context) }
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: tecladoAberto)
        }
        .overlay {
            if let confirmacao = sessao.confirmacao {
                ConfirmacaoView(estado: confirmacao, sessao: sessao, context: context)
                    .transition(reduceMotion
                        ? .opacity
                        : .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.03)),
                            removal: .opacity.combined(with: .scale(scale: 1.02))
                        ))
            }
        }
        .animation(sessao.confirmacao != nil
            ? .easeOut(duration: Tema.confirmacaoEntra)
            : .easeIn(duration: 0.15),
            value: sessao.confirmacao != nil)
        .overlay {
            if let minutos = sessao.fechoExpressiva {
                FechoExpressivaView(sessao: sessao, minutos: minutos)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.22), value: sessao.fechoExpressiva)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            tecladoAberto = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            tecladoAberto = false
        }
    }
}
