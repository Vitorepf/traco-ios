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
    // ADR 06c: o ditado próprio cobre a página — é a tarefa inteira
    @State private var ditado: DitadoProprio?

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
                // Só para a troca de ABA: `.transaction { animation = nil }`
                // zerava TODA animação herdada pela subárvore, inclusive o
                // deslize da camada do arquivo (Camadas) — a lista aparecia
                // cravada no lugar final enquanto a pílula, irmã de fora, ainda
                // viajava (rajada de capturas de 14/09, volta 46).
                .animation(nil, value: sessao.abaArquivo)
                // o aviso da Sessão ("Ligar para a Ana marcado para…") só
                // vivia na página; nas Notas o pedido marcava e a tela calava.
                // Aqui ele pousa sobre o campo, com o mesmo cartão da página.
                .overlay(alignment: .bottom) {
                    if let toast = sessao.toast, sessao.aba != .escrever {
                        Text(toast)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .cartao(.papel, recuo: [])
                            .padding(.horizontal, Tema.margem)
                            .padding(.bottom, 56)
                            .transition(Tema.transicao(.opacity.combined(with: .offset(y: 6)), reduzido: reduceMotion))
                            .accessibilityIdentifier("toast-arquivo")
                            .allowsHitTesting(false)
                    }
                }
                .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: sessao.toast)

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
                // a alça âmbar da borda saiu: "‹ Notas" e o gesto de borda já
                // são a saída, e o âmbar só marca onde o traço do autor
                // acontece (auditoria 15/09, 10)
                PaginaView(sessao: sessao)
            }
            .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: tecladoAberto)
        }
        .overlay {
            if let confirmacao = sessao.confirmacao {
                ConfirmacaoView(estado: confirmacao, sessao: sessao, context: context)
                    .transition(Tema.transicao(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.03)),
                        removal: .opacity.combined(with: .scale(scale: 1.02))
                    ), reduzido: reduceMotion))
            }
        }
        // sob reduzido a transição já é só opacidade: a duração fica
        .animation(Tema.movimento(.opacidade, sessao.confirmacao != nil
            ? .easeOut(duration: Tema.Duracao.media)
            : .easeIn(duration: Tema.Duracao.curta), reduzido: reduceMotion),
            value: sessao.confirmacao != nil)
        // ADR 06c: acima de tudo o que a Página pode estar mostrando — a
        // gravação não divide a tela com nada, nem com o teclado.
        .overlay {
            if let ditado {
                DitadoProprioView(ditado: ditado) {
                    self.ditado = nil
                } aoEscrever: {
                    self.ditado = nil
                    Rota.ir(.captura(ditado: false))
                }
                .transition(.opacity)
            }
        }
        .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion),
                   value: ditado == nil)
        .overlay {
            if let minutos = sessao.fechoExpressiva {
                FechoExpressivaView(sessao: sessao, minutos: minutos)
                    .transition(.opacity)
            }
        }
        // a ENTRADA do fecho é rápida (o autor decidiu); a SAÍDA é o fim do
        // ritual — da cinza escura, a página nova amanhece devagar (dono,
        // 01/set: "o fim de um ciclo e o começo de uma nova era")
        .animation(Tema.movimento(.opacidade, sessao.fechoExpressiva != nil
            ? .easeOut(duration: Tema.Duracao.media)
            : .easeOut(duration: Tema.Duracao.fecho), reduzido: reduceMotion),
            value: sessao.fechoExpressiva)
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
            // ADR 06d (revisão G3, A2): a permissão dos avisos muda FORA do
            // app, nos Ajustes. Quem volta à cena relê o estado e republica —
            // sem isto o sino prometido ficava desenhado na casa até alguém
            // marcar outra coisa. A publicação acima não espera (diálogo de
            // permissão já travou a superfície uma vez); esta corrige depois.
            Task {
                _ = await Avisos.estado()
                agenda.publicarProximo()
            }
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
        .onAppear {
            sessao.agenda = agenda
            // ADR 06c: no arranque frio o intent corre antes desta cena existir
            if Rota.consumirDitado() { abrirDitado() }
        }
        .onReceive(NotificationCenter.default.publisher(for: Rota.mudou)) { _ in
            if Rota.consumirDitado() { abrirDitado() }
        }
        // gravação interrompida (o autor saiu do app) conclui e DEPOSITA: a
        // frase falada não se perde por a cena ir embora
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if let d = ditado, d.estado == .gravando { Task { await d.concluir() } }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            sessao.salvar(no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            sessao.salvar(no: context)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            tecladoAberto = true
            // ADR 06c: o foco da página continua armado por baixo; enquanto a
            // gravação está na tela, o teclado não sobe por cima dela
            if ditado != nil {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            tecladoAberto = false
        }
    }

    /// A superfície nasce gravando: um toque fora do app faz UMA coisa.
    /// A closure é o depósito — a primeira chamada cria a nota (antes de
    /// qualquer letra), as seguintes reescrevem a mesma.
    private func abrirDitado() {
        // um ditado EM CURSO não é interrompido por outro toque no controle;
        // um já terminado na tela é substituído — senão o segundo toque não
        // faz nada e o autor fica falando para uma tela parada
        if let atual = ditado, atual.estado == .gravando || atual.estado == .transcrevendo { return }
        // a gravação não divide a tela: o teclado que a página tenha deixado
        // de pé sai agora (a defesa durável é o `keyboardWillShow` acima)
        Teclado.recolher()
        let novo = DitadoProprio()
        // A2 do G3: quem liga o ditado ao disco é a Sessão, e a nota que ele
        // deposita é DELE — dois ditados sobrepostos não dividem mais uma só.
        sessao.armarDitado(novo, no: context)
        #if DEBUG
        // evidência do estado "transcrito", que o simulador não produz sozinho
        if Rota.ensaioDoDitado == "transcrito" {
            // a espera é de propósito: no aparelho a transcrição demora, e sem
            // ela o estado "transcrevendo" passa rápido demais para se ver
            novo.transcritor = { _ in
                try? await Task.sleep(for: .seconds(6))
                return .veio("comprar pão e ligar para a Ana amanhã cedo")
            }
        }
        // o disco recusando o depósito: o estado que a tela mentia (G3, A1)
        if Rota.ensaioDoDitado == "disco-recusa" { novo.gravarNota = { _ in false } }
        Rota.ensaioDoDitado = nil
        #endif
        ditado = novo
        Task { await novo.comecar() }
    }
}
