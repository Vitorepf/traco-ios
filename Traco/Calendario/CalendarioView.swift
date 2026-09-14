import SwiftData
import SwiftUI

struct CalendarioView: View {
    @State var agenda: CalendarioAgenda
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Query private var trabalhos: [Trabalho]
    @Query private var origensDosTrabalhos: [Nota]
    @State private var trabalhoAberto: DestinoTrabalhoCalendario?
    private var selosDosTrabalhos: [SeloOrigemTrabalho] { origensDosTrabalhos.map(SeloOrigemTrabalho.init) }
    /// O calendário das intenções: as notas cujo "Se" tem hora entram como
    /// deixas. Só abertas; a expressiva e a fechada nunca.
    @Query(filter: #Predicate<Nota> { $0.gatilhoEm != nil && !$0.trancada && !$0.queimada })
    private var notasComDeixa: [Nota]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var morph
    /// 32pt bold com tracking −0,6, escalando com o texto do sistema.
    @ScaledMetric(relativeTo: .largeTitle) private var tamTitulo: CGFloat = 32
    @State private var confirmarApagarTudo = false
    /// A ficha nasce inteira (ver o `.sheet`): ordem de detente não escolhe.
    @State private var detenteDaFicha: PresentationDetent = .large
    /// Ditar em vez de digitar: o texto reconhecido cai no campo de prosa e o
    /// resto do caminho é o algoritmo local de sempre.
    @State private var ditado = Ditado()
    /// Os calendários que já estão no iPhone: alimentam a recomendação do
    /// campo (sete dias) E a grade (a faixa visível), sempre só leitura.
    @State private var sistema = CalendarioSistema()

    /// O exemplo inventado só aparece quando não há compromisso de verdade.
    private var dicaDoCampo: String {
        // a recomendação longa cortava a meio da palavra ("Independência do
        // Brasil depois de a…"): exemplo que não cabe não é exemplo
        // na linha única do pé o campo tem ~130 pt: o exemplo tem de caber
        if let r = Recomendacao.primeira(de: sistema.proximos, agenda.cal), r.count <= 12 { return r }
        return "Dentista 14h"
    }

    init(agenda: CalendarioAgenda = CalendarioAgenda()) {
        _agenda = State(initialValue: agenda)
    }

    var body: some View {
        // o "agora" anda: a linha, o "Hoje" e o anel do dia seguem o relógio
        TimelineView(.everyMinute) { contexto in
            conteudo(agora: contexto.date)
        }
        .foregroundStyle(CalendarioTema.tinta)
        .preferredColorScheme(.light)
        .sheet(item: $trabalhoAberto) { destino in
            TrabalhoView(trabalho: destino.trabalho, acaoEmFoco: destino.acaoID)
        }
        .sheet(item: $agenda.ficha) { evento in
            CalendarioFichaView(evento: evento, agenda: agenda)
                // A ORDEM NÃO ESCOLHE O DETENTE. O comentário anterior dizia
                // que `.large` primeiro bastava; a captura de 04/set mostrou a
                // ficha abrindo no médio, cortada em "Termina" — com Notas,
                // Apagar e o AVISO inteiro fora da tela. Só a `selection`
                // decide, e a ficha nasce de um toque deliberado: nasce
                // inteira, e desce se o autor quiser.
                .presentationDetents([.large, .medium], selection: $detenteDaFicha)
                .presentationDragIndicator(.visible)
                .presentationBackground(CalendarioTema.fundo)
        }
        .sheet(item: $agenda.fichaDoSistema) { evento in
            CalendarioFichaSistemaView(
                evento: evento,
                calendario: sistema.naFaixa.first { $0.inicio == evento.inicio && $0.titulo == evento.titulo }?.calendario ?? "",
                agenda: agenda)
        }
        .confirmationDialog("Marcar", isPresented: $agenda.menuMais, titleVisibility: .hidden) {
            Button("Novo compromisso") { agenda.novoEmBranco() }
            Button("Colar") { agenda.colar() }

            Button("Cancelar", role: .cancel) {}
        }
        // sem id na raiz: ele cobria os ids de TODOS os filhos (34 elementos
        // viravam "calendario" e nenhum botão era achado por id)
        .onAppear {
            aplicarEscalaDaRota()
            agenda.deixas = deixas(de: notasComDeixa)
            atualizarTrabalhos()
            agenda.aoAbrirTrabalho = { trabalhoID, acaoID in
                guard let trabalho = trabalhos.first(where: { $0.uuid == trabalhoID }),
                      AcessoTrabalho.permitido(trabalho, no: context) else {
                    atualizarTrabalhos()
                    agenda.mostrar("Este trabalho não está disponível para abrir.")
                    return
                }
                trabalhoAberto = .init(trabalho: trabalho, acaoID: acaoID)
            }
            ditado.aoTexto = { [weak agenda] falado in agenda?.prosa = falado }
        }
        // o acesso ao calendário é pedido AQUI, olhando um calendário — nunca
        // no arranque (§3: o app abre na página em branco, sem cerimônia)
        .task {
            await sistema.pedirAcesso()
            recarregarSistema()
        }
        .onChange(of: agenda.escala) { _, _ in recarregarSistema() }
        .onChange(of: trabalhos.map(\.conteudoJSON)) { _, _ in atualizarTrabalhos() }
        .onChange(of: selosDosTrabalhos) { _, _ in atualizarTrabalhos() }
        .onChange(of: scenePhase) { _, _ in atualizarTrabalhos() }
        .onChange(of: agenda.ancora) { _, _ in recarregarSistema() }
        // sair da tela com o microfone aberto seria gravar às escondidas
        .onDisappear { ditado.parar() }
        .onChange(of: ditado.recado) { _, novo in
            if let novo { agenda.mostrar(novo) }
        }
        .onChange(of: notasComDeixa.map { "\($0.uuid)\($0.gatilhoEm?.timeIntervalSince1970 ?? 0)\($0.tituloNaLista)" }) { _, _ in
            agenda.deixas = deixas(de: notasComDeixa)
        }
        .onReceive(NotificationCenter.default.publisher(for: Rota.mudou)) { _ in
            aplicarEscalaDaRota()
        }
    }

    private func conteudo(agora: Date) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(CalendarioTema.papel).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                cabeca(agora: agora)
                Group {
                    if agenda.modo == .lista {
                        CalendarioListaView(agenda: agenda)
                            .transition(.opacity)
                    } else {
                        escalas(agora: agora)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // a rolagem se dissolve sob os dias e acima da cápsula do pé
                .desvanece(pe: 48, reservaPe: Tema.alvo + 16, fundo: CalendarioTema.fundo)
            }

            chrome(agora: agora)
        }
        .overlay(alignment: .top) {
            if let toast = agenda.toast {
                CalendarioToast(texto: toast, ajustes: agenda.toastComAjustes)
                    .padding(.top, 8)
                    .transition(Tema.transicao(.move(edge: .top).combined(with: .opacity), reduzido: reduceMotion))
            }
        }
        .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: agenda.toast)
        .animation(CalendarioTema.morph(reduceMotion), value: agenda.modo)
    }

    /// A3: a grade pede a faixa que está à vista; a recomendação continua com
    /// os sete dias. Duas janelas, uma leitura só por mudança de escala.
    private func recarregarSistema() {
        guard sistema.podeLer else {
            agenda.doSistema = []
            return
        }
        let (de, a) = agenda.faixaParaOSistema
        sistema.carregarFaixa(de: de, a: a)
        agenda.doSistema = sistema.naFaixa.map(\.comoEvento)
    }

    private func deixas(de notas: [Nota]) -> [EventoCalendario] {
        notas.compactMap { Calendario.deixa(uuid: $0.uuid, gesto: $0.gesto, fechada: $0.fechada, gatilhoEm: $0.gatilhoEm,
                                            se: $0.campos["se"] ?? "", tituloNaLista: $0.tituloNaLista, dominio: $0.dominio) }
    }

    private func atualizarTrabalhos() {
        agenda.acoesDosTrabalhos = scenePhase == .active ? CalendarioTrabalho.eventos(trabalhos, no: context) : []
    }

    private func aplicarEscalaDaRota() {
        guard let escala = Rota.escalaCalendario else { return }
        Rota.escalaCalendario = nil
        withAnimation(CalendarioTema.morph(reduceMotion)) {
            agenda.ir(para: escala)
        }
    }

    // MARK: cabeça

    private func cabeca(agora: Date) -> some View {
        // O risco diz QUE não é dia útil; o nome diz QUAL é. Ele mora aqui, e
        // não na escala do dia, porque tocar num dia riscado — em qualquer
        // escala — muda a âncora, e é esta linha que responde ao toque.
        let feriado = Feriados.de(agenda.ancora, agenda.cal)
        return VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center, spacing: 10) {
                Text(agenda.titulo)
                    .font(.system(size: tamTitulo, weight: .bold))
                    .tracking(CalendarioTema.tituloTracking)
                    .foregroundStyle(CalendarioTema.tinta)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentTransition(.numericText())
                    .animation(CalendarioTema.morph(reduceMotion), value: agenda.titulo)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("calendario-titulo")
            }
            if let feriado {
                Text(feriado.facultativo ? "\(feriado.nome) · ponto facultativo" : feriado.nome)
                    .font(CalendarioTema.meta)
                    .foregroundStyle(CalendarioTema.tintaSuave)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("calendario-feriado")
            }
        }
        .padding(.horizontal, CalendarioTema.margem)
        .padding(.top, 8)
        .padding(.bottom, 12)
        // quem anima é a ALTURA do container (§21), não a opacidade da linha
        .animation(CalendarioTema.morph(reduceMotion), value: feriado)
    }


    // MARK: escalas — um objeto em quatro zooms

    @ViewBuilder
    private func escalas(agora: Date) -> some View {
        let foco = focoDaAncora()
        ZStack {
            if agenda.escala == .dia {
                CalendarioDiaView(agenda: agenda, morph: morph, agora: agora)
                    .transition(CalendarioTema.desdobra(reduzido: reduceMotion, aproximando: agenda.aproximando, foco: foco))
            }
            if agenda.escala == .semana {
                CalendarioSemanaView(agenda: agenda, morph: morph, agora: agora)
                    .transition(CalendarioTema.desdobra(reduzido: reduceMotion, aproximando: agenda.aproximando, foco: foco))
            }
            if agenda.escala == .mes {
                CalendarioMesView(agenda: agenda, morph: morph, agora: agora)
                    .transition(CalendarioTema.desdobra(reduzido: reduceMotion, aproximando: agenda.aproximando, foco: foco))
            }
            if agenda.escala == .ano {
                CalendarioAnoView(agenda: agenda, morph: morph, agora: agora)
                    // o ano é um mapa: 504 células não cabem em corpo maior;
                    // o teto tem de vir de FORA para o ScaledMetric de dentro obedecer
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    .transition(CalendarioTema.desdobra(reduzido: reduceMotion, aproximando: agenda.aproximando, foco: foco))
            }
        }
        .animation(CalendarioTema.morph(reduceMotion), value: agenda.escala)
        // grade densa escala até xxLarge e para: acima disso os números
        // estouravam as células (mesma escolha do Calendário do sistema)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }

    /// Onde o dia âncora está na tela da escala atual: o desdobramento nasce dali.
    private func focoDaAncora() -> UnitPoint {
        let cal = agenda.cal
        switch agenda.escala {
        case .dia:
            let i = agenda.semana.firstIndex { Calendario.mesmoDia($0, agenda.ancora, cal) } ?? 3
            return UnitPoint(x: (CGFloat(i) + 0.5) / 7, y: 0.06)
        case .semana:
            let i = agenda.semana.firstIndex { Calendario.mesmoDia($0, agenda.ancora, cal) } ?? 3
            return UnitPoint(x: 0.08, y: 0.1 + (CGFloat(i) + 0.5) / 7 * 0.7)
        case .mes:
            let i = agenda.grelha.firstIndex { Calendario.mesmoDia($0, agenda.ancora, cal) } ?? 21
            return UnitPoint(x: (CGFloat(i % 7) + 0.5) / 7, y: 0.08 + (CGFloat(i / 7) + 0.5) / 6 * 0.8)
        case .ano:
            let m = cal.component(.month, from: agenda.ancora) - 1
            return UnitPoint(x: (CGFloat(m % 3) + 0.5) / 3, y: (CGFloat(m / 3) + 0.5) / 4)
        }
    }

    // MARK: chrome flutuante

    private func chrome(agora: Date) -> some View {
        // Dono, 14/09: UMA linha, não duas — as escalas à esquerda, o campo
        // (escrever ou falar) à direita. "Hoje" só existe quando não se está
        // em hoje; lista/grade mora no "+", que é raro.
        // Dono, 14/09: UMA linha, e com o material da cápsula anterior — o
        // que vai à esquerda (lista/grade, escalas, Hoje) entra na mesma
        // cápsula de vidro do campo, como o "+" entrava.
        campoProsa(agora: agora)
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, -6)
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
    }

    private func interruptor(agora: Date) -> some View {
        HStack(spacing: 6) {
            // lista ou grade: um alternador só, o glifo do que se vai ver. O
            // toque longo guarda o que o "+" oferecia (novo em branco, colar):
            // o poder fica, sem mais um objeto na cápsula.
            Menu {
                Button("Novo compromisso") { agenda.novoEmBranco() }
                Button("Colar") { agenda.colar() }
            } label: {
                Image(systemName: agenda.modo == .lista ? "calendar" : "list.bullet")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CalendarioTema.tinta)
                    .frame(width: 32, height: Tema.alvo)
                    .contentShape(Rectangle())
            } primaryAction: {
                Toque.selecao()
                withAnimation(CalendarioTema.morph(reduceMotion)) {
                    agenda.modo = agenda.modo == .lista ? .grelha : .lista
                }
            }
            .buttonStyle(PressaoClara())
            .accessibilityLabel(agenda.modo == .lista ? "Ver em grade" : "Ver em lista")
            .accessibilityHint("Toque longo: novo compromisso ou colar")
            .accessibilityIdentifier("modo-alternar")
            HStack(spacing: 0) {
                ForEach(EscalaCalendario.allCases, id: \.self) { escala in
                    let ligado = agenda.escala == escala
                    Button {
                        Toque.selecao()
                        withAnimation(CalendarioTema.morph(reduceMotion)) {
                            agenda.ir(para: escala)
                        }
                    } label: {
                        Text(escala.letra)
                            .font(CalendarioTema.escala)
                            .foregroundStyle(ligado ? .white : CalendarioTema.tintaSuave)
                            .frame(width: 32, height: 32)
                            .background {
                                if ligado {
                                    Circle()
                                        .fill(CalendarioTema.chipActivo)
                                        .shadow(color: CalendarioTema.sombraControle, radius: 4, y: 2)
                                        .matchedGeometryEffect(id: "escala-selecionada", in: morph)
                                }
                            }
                            .frame(width: 34, height: Tema.alvo)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressaoClara())
                    .accessibilityIdentifier("escala-\(escala.rawValue)")
                    .accessibilityLabel(escala.nome)
                    .accessibilityAddTraits(ligado ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.horizontal, 3)
            .background(Capsule().fill(CalendarioTema.trilho))
            .animation(CalendarioTema.morph(reduceMotion), value: agenda.escala)

            if !agenda.hojeAVista(agora) {
                Button {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) {
                        agenda.irHoje(agora: agora)
                    }
                } label: {
                    Text("Hoje")
                        .font(CalendarioTema.chrome)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .frame(height: 32)
                        .background(CalendarioTema.chipActivo, in: Capsule())
                        .frame(height: Tema.alvo)
                        .contentShape(Capsule())
                }
                .buttonStyle(PressaoClara())
                .accessibilityIdentifier("calendario-hoje")
                .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
            }
        }
        .fixedSize()
    }

    private func campoProsa(agora: Date) -> some View {
        // com o Hoje à vista a linha aperta: a dica encurta para "marcar" em
        // vez de sair cortada a meio ("Dentista 1…", vídeo de 14/09)
        let emHoje = agenda.hojeAVista(agora)
        return CampoFlutuante(texto: $agenda.prosa, dica: emHoje ? dicaDoCampo : "marcar", ditado: ditado,
                       identificador: "calendario-prosa", identificadorDoBotao: "calendario-marcar",
                       rotuloEnviar: "Marcar o compromisso", rotuloDitar: "Ditar o compromisso",
                       aoEnviar: { agenda.adicionarDaProsa() }) {
            interruptor(agora: agora)
        }
    }
}

private struct DestinoTrabalhoCalendario: Identifiable {
    let trabalho: Trabalho
    let acaoID: UUID
    var id: UUID { acaoID }
}

/// O chip do dia: círculo em `chip`, ativo em carvão; 44 de alvo sempre.
struct CalendarioChipDia: View {
    let dia: Date
    let activo: Bool
    let hoje: Bool
    let cal: Calendar
    var compacto: Bool = false

    var body: some View {
        let lado: CGFloat = compacto ? 36 : 44
        // o dia que não é útil vem cortado: um risco no número, na tinta que
        // ele já tem. Sem cor própria, sem ícone — o corte é o recado inteiro.
        let feriado = Feriados.de(dia, cal)
        VStack(spacing: compacto ? 0 : 1) {
            Text(Calendario.letraDoDia(dia, cal))
                .font(CalendarioTema.letra)
            Text(Calendario.formatar(dia, "d", cal))
                .font(compacto ? CalendarioTema.meta.monospacedDigit() : CalendarioTema.dia)
                .riscoDeFeriado(feriado != nil,
                                largura: compacto ? 13 : 15,
                                cor: activo ? .white : CalendarioTema.tintaSuave)
        }
        .foregroundStyle(activo ? .white : CalendarioTema.tintaSuave)
        .frame(width: lado, height: lado)
        .background(activo ? CalendarioTema.chipActivo : CalendarioTema.chip, in: Circle())
        .overlay {
            if hoje, !activo {
                Circle().strokeBorder(CalendarioTema.tinta, lineWidth: 1.5)
            }
        }
        .frame(width: Tema.alvo, height: Tema.alvo)
        .contentShape(Rectangle())
        // um elemento só: sem isto a letra e o número repetem o rótulo (G3 v8)
        .accessibilityElement(children: .ignore)
        // o risco é invisível ao VoiceOver: quem não vê precisa ouvir o nome
        .accessibilityLabel(
            feriado.map { "\(Calendario.diaPorExtenso(dia, cal)), feriado, \($0.nome)" }
                ?? Calendario.diaPorExtenso(dia, cal)
        )
        .accessibilityAddTraits(activo ? [.isButton, .isSelected] : .isButton)
    }
}

/// A agenda em lista é a lista do app (Hermes §4 e §5, ADR 10k): o dia é o
/// cabeçalho de seção, com a contagem e o recolher; cada compromisso é uma
/// linha de três níveis no papel — sem o cartão branco que cada um tinha.
/// A identidade à esquerda é o DOMÍNIO: forma do ícone e matiz, as duas
/// cores de identidade que a regra do `Tema` deixa entrar.
struct CalendarioListaView: View {
    @Bindable var agenda: CalendarioAgenda
    /// o recolher de um dia vale enquanto a lista está aberta: amanhã é outro dia
    @State private var recolhidos: Set<Date> = []

    var body: some View {
        let grupos = Dictionary(grouping: agenda.eventosDaEscala()) {
            Calendario.inicioDoDia($0.inicio, agenda.cal)
        }
        let dias = grupos.keys.sorted()
        // A lista pousa em hoje (ou no primeiro dia depois de hoje), como o
        // Calendário do iPhone: o passado fica acima, para quem quiser subir.
        let hoje = Calendario.inicioDoDia(agenda.ancora, agenda.cal)
        let alvo = dias.first { $0 >= hoje } ?? dias.last
        ScrollViewReader { proxy in
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if dias.isEmpty {
                    // Hermes §11: o vazio é uma linha normal
                    LinhaDeLista("calendar", "Nada marcado", "escreva no campo: “dentista sexta às 14h30”", fio: false)
                        .padding(.top, 12)
                        .accessibilityIdentifier("calendario-lista-vazia")
                }
                ForEach(dias, id: \.self) { dia in
                    let doDia = grupos[dia] ?? []
                    VStack(alignment: .leading, spacing: 0) {
                        CabecalhoDeSecao(Calendario.diaPorExtenso(dia, agenda.cal), contagem: doDia.count,
                                         recolhida: Binding(
                                            get: { recolhidos.contains(dia) },
                                            set: { if $0 { recolhidos.insert(dia) } else { recolhidos.remove(dia) } }))
                        if !recolhidos.contains(dia) {
                            ForEach(doDia) { evento in
                                Button {
                                    agenda.abrir(evento)
                                } label: {
                                    LinhaDeLista(
                                        titulo: evento.titulo,
                                        subtitulo: Calendario.intervalo(evento, agenda.cal)
                                            + (evento.doSistema ? " · do seu iPhone" : ""),
                                        glifo: {
                                            Image(systemName: CalendarioTema.icone(de: evento))
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(CalendarioTema.tinta(de: evento))
                                                .frame(width: 28, height: 28)
                                                .background(CalendarioTema.fundo(de: evento), in: Circle())
                                                .overlay {
                                                    if CalendarioTema.temContorno(evento) {
                                                        Circle().strokeBorder(CalendarioTema.contorno(de: evento), lineWidth: 1)
                                                    }
                                                }
                                        },
                                        acessorio: { Chevron() })
                                }
                                .buttonStyle(PressaoClara())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, CalendarioTema.margem)
            .padding(.bottom, 160)
        }
        .onAppear { if let alvo { proxy.scrollTo(alvo, anchor: .top) } }
        }
    }
}
