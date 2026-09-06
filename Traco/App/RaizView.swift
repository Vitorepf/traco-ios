import SwiftData
import SwiftUI

/// A raiz (SPEC §20 rev.2): a página em branco é a CASA e não tem chrome nenhum.
/// O arquivo (Notas · Calendário · Padrões · Perfil) é uma camada ao lado, com barra própria.
/// Vai-se e volta-se por gesto — escrever nunca divide a tela com navegação.
struct RaizView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sessao = Sessao()
    @State private var tecladoAberto = false
    @State private var agenda = CalendarioAgenda()

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
                    case .calendario:
                        CalendarioView(agenda: agenda)
                            .onAppear {
                                agenda.aoAbrirNota = { uuid in
                                    guard let nota = Sessao.buscar(uuid: uuid, no: context) else { return }
                                    guard sessao.salvar(no: context) else { return }
                                    sessao.abrir(nota)
                                    sessao.irPara(.escrever, no: context)
                                }
                            }
                    case .padroes: PadroesView(sessao: sessao)
                    case .perfil: PerfilView(sessao: sessao, agenda: agenda)
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
                        // disco recusou = a página fica; nada de página nova por cima
                        guard sessao.salvar(no: context) else { return }
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
        // a ENTRADA do fecho é rápida (o autor decidiu); a SAÍDA é o fim do
        // ritual — da cinza escura, a página nova amanhece devagar (dono,
        // 01/set: "o fim de um ciclo e o começo de uma nova era")
        .animation(sessao.fechoExpressiva != nil
            ? .easeOut(duration: 0.22)
            : .easeOut(duration: 0.9),
            value: sessao.fechoExpressiva)
        .overlay {
            if let aviso = DiscoTraco.aviso {
                ZStack {
                    Tema.fundo.ignoresSafeArea()
                    Text(aviso)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .padding(Tema.margem)
                        .frame(maxWidth: 680)
                }
                .accessibilityIdentifier("disco-falhou")
            }
        }
        // um mundo só (ADR 2026-09-02h): nunca claro numa aba e escuro noutra
        .preferredColorScheme(.light)
        .environment(\.abrirCalendarioDoTrabalho, { data in
            guard sessao.salvar(no: context) else { return false }
            agenda.ancora = Calendario.inicioDoDia(data, agenda.cal)
            agenda.ir(para: .dia)
            sessao.irPara(.calendario, no: context)
            return sessao.aba == .calendario && sessao.abaArquivo == .calendario
        })
        // A página em voo GRAVA ao sair de cena. Fica na RAIZ e escuta a
        // notificação do UIApplication: o `scenePhase` de uma view aninhada
        // chegou tarde demais para gravar antes da suspensão.
        // ADR l: o Destaque vivo acaba com o dia; ao voltar sem Destaque de hoje, encerra
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // ADR 05u: o que está vivo na tela bloqueada é reconciliado com o
            // estado guardado — Destaque de outro dia ou já feito sai
            FilaDeAtividade.compartilhada.enfileirar { await DestaqueDoDia.reconciliar() }
            DestaqueDoDia.publicar()
            // ADR 04a: o compromisso vive fora do app. O relógio anda enquanto
            // o Traço dorme, então quem republica o próximo é o voltar à cena —
            // sem isto, o widget e a Ilha mostravam o de ontem.
            agenda.publicarProximo()
            // ADR 05u: o reload pedido na escrita pode ter sido recusado em
            // rajada e a API não conta; a volta à cena repete, fora da rajada,
            // o que ainda não foi confirmado ("abra o Traço" tem de se cumprir)
            Task {
                try? await Task.sleep(for: .seconds(2))
                SuperficieDisco.recarregarPendente()
            }
            // volta das férias sem o app ser morto: reagenda o que estava calado
            if Ferias.expirarSePassou() {
                Revisoes.agendarFilaDiaria()
                Revisoes.agendarRevisaoSemanal()
            }
        }
        // ADR 04k: os encadeamentos que marcam compromisso passam pela agenda
        .onAppear { sessao.agenda = agenda }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            sessao.salvar(no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            sessao.salvar(no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            tecladoAberto = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            tecladoAberto = false
        }
    }
}
