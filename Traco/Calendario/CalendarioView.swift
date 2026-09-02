import SwiftData
import SwiftUI

struct CalendarioView: View {
    @State var agenda: CalendarioAgenda
    /// O calendário das intenções: as notas cujo "Se" tem hora entram como
    /// deixas. Só abertas; a expressiva e a fechada nunca.
    @Query(filter: #Predicate<Nota> { $0.gatilhoEm != nil && !$0.trancada && !$0.queimada })
    private var notasComDeixa: [Nota]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var morph
    /// 32pt bold com tracking −0,6, escalando com o texto do sistema.
    @ScaledMetric(relativeTo: .largeTitle) private var tamTitulo: CGFloat = 32
    @State private var confirmarApagarTudo = false

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
        .sheet(item: $agenda.ficha) { evento in
            CalendarioFichaView(evento: evento, agenda: agenda)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(CalendarioTema.fundo)
        }
        .sheet(isPresented: $agenda.ajustes) {
            CalendarioAjustesView(agenda: agenda)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(CalendarioTema.fundo)
        }
        .confirmationDialog("Marcar", isPresented: $agenda.menuMais, titleVisibility: .hidden) {
            Button("Novo compromisso") { agenda.novoEmBranco() }
            Button("Colar") { agenda.colar() }
            Button("Cancelar", role: .cancel) {}
        }
        .accessibilityIdentifier("calendario")
        .onAppear {
            aplicarEscalaDaRota()
            agenda.deixas = deixas(de: notasComDeixa)
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
            CalendarioTema.fundo.ignoresSafeArea()

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
            }

            chrome(agora: agora)
        }
        .overlay(alignment: .top) {
            if let toast = agenda.toast {
                CalendarioToast(texto: toast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.22), value: agenda.toast)
        .animation(CalendarioTema.morph(reduceMotion), value: agenda.modo)
    }

    private func deixas(de notas: [Nota]) -> [EventoCalendario] {
        notas.compactMap { nota in
            guard let quando = nota.gatilhoEm, nota.gesto != .expressiva else { return nil }
            let se = nota.campos["se"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let titulo = se.isEmpty ? nota.tituloNaLista : se
            guard !titulo.isEmpty else { return nil }
            return EventoCalendario(
                id: nota.uuid, titulo: titulo, inicio: quando,
                fim: quando.addingTimeInterval(30 * 60),
                dominio: nota.dominio, origem: nota.uuid
            )
        }
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
            cabecaBotao("ellipsis") { agenda.menuMais = true }
                .accessibilityLabel("Marcar")
                .accessibilityIdentifier("calendario-mais")
            cabecaBotao("gearshape") { agenda.ajustes = true }
                .accessibilityLabel("Ajustes do calendário")
                .accessibilityIdentifier("calendario-ajustes")
        }
        .padding(.horizontal, CalendarioTema.margem)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func cabecaBotao(_ icone: String, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            Image(systemName: icone)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CalendarioTema.tintaSuave)
                .frame(width: CalendarioTema.controle, height: CalendarioTema.controle)
                .background(CalendarioTema.chip, in: Circle())
                .frame(width: Tema.alvo, height: Tema.alvo)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressaoClara())
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
                    .transition(CalendarioTema.desdobra(reduzido: reduceMotion, aproximando: agenda.aproximando, foco: foco))
            }
        }
        .animation(CalendarioTema.morph(reduceMotion), value: agenda.escala)
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
        VStack(spacing: 10) {
            interruptor(agora: agora)
            campoProsa
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private func interruptor(agora: Date) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                modoBotao(.lista, icone: "list.bullet")
                modoBotao(.grelha, icone: "calendar")
            }
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
                            .frame(width: CalendarioTema.controle, height: CalendarioTema.controle)
                            .background {
                                if ligado {
                                    Circle()
                                        .fill(CalendarioTema.chipActivo)
                                        .matchedGeometryEffect(id: "escala-selecionada", in: morph)
                                }
                            }
                            .frame(width: 40, height: Tema.alvo)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressaoClara())
                    .accessibilityIdentifier("escala-\(escala.rawValue)")
                    .accessibilityLabel(escala.nome)
                    .accessibilityAddTraits(ligado ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.horizontal, 2)
            .background(CalendarioTema.campo, in: Capsule())
            .animation(CalendarioTema.morph(reduceMotion), value: agenda.escala)

            // sempre presente: um botão que aparece e some mexe no layout inteiro
            Button {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) {
                        agenda.irHoje(agora: agora)
                    }
                } label: {
                    Text("Hoje")
                        .font(CalendarioTema.chrome)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: CalendarioTema.controle)
                        .background(CalendarioTema.chipActivo, in: Capsule())
                        .frame(height: Tema.alvo)
                        .contentShape(Capsule())
                }
                .buttonStyle(PressaoClara())
                .accessibilityIdentifier("calendario-hoje")
                .opacity(agenda.ancoraEHoje(agora) && agenda.escala == .dia ? 0.55 : 1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Capsule()
                .fill(CalendarioTema.cartao)
                // vidro sobre alumínio, não cartão: o fio de luz no topo
                .overlay(Capsule().strokeBorder(CalendarioTema.luzBorda, lineWidth: 1))
                .shadow(color: CalendarioTema.sombraFlutuante, radius: 16, y: 6)
        }
        .accessibilityIdentifier("calendario-interruptor")
    }

    private func modoBotao(_ modo: ModoCalendario, icone: String) -> some View {
        let ligado = agenda.modo == modo
        return Button {
            Toque.selecao()
            agenda.modo = modo
        } label: {
            Image(systemName: icone)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ligado ? .white : CalendarioTema.tintaSuave)
                .frame(width: CalendarioTema.controle, height: CalendarioTema.controle)
                .background {
                    if ligado {
                        RoundedRectangle(cornerRadius: CalendarioTema.raioAcao, style: .continuous)
                            .fill(CalendarioTema.chipActivo)
                            .matchedGeometryEffect(id: "modo-selecionado", in: morph)
                    }
                }
                .frame(width: 40, height: Tema.alvo)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressaoClara())
        .accessibilityIdentifier("modo-\(modo.rawValue)")
        .accessibilityLabel(modo == .lista ? "Lista" : "Grade")
        .accessibilityAddTraits(ligado ? [.isButton, .isSelected] : .isButton)
    }

    private var campoProsa: some View {
        let temTexto = !agenda.prosa.trimmingCharacters(in: .whitespaces).isEmpty
        return HStack(spacing: 8) {
            Button {
                agenda.menuMais = true
            } label: {
                Image(systemName: "plus")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(CalendarioTema.tinta)
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressaoClara())
            .accessibilityLabel("Marcar")

            TextField(
                "",
                text: $agenda.prosa,
                prompt: Text("Dentista sexta às 14:30")
                    .foregroundStyle(CalendarioTema.tintaFraca)
            )
            .font(.callout)
            .foregroundStyle(CalendarioTema.tinta)
            .textInputAutocapitalization(.sentences)
            .submitLabel(.done)
            .onSubmit { agenda.adicionarDaProsa() }
            .accessibilityIdentifier("calendario-prosa")
            .accessibilityLabel("Marcar em palavras")

            Button {
                agenda.adicionarDaProsa()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(temTexto ? .white : CalendarioTema.tintaMorta)
                    .frame(width: CalendarioTema.controle, height: CalendarioTema.controle)
                    .background(
                        temTexto ? CalendarioTema.chipActivo : CalendarioTema.chip,
                        in: RoundedRectangle(cornerRadius: CalendarioTema.raioAcao, style: .continuous)
                    )
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressaoClara())
            .disabled(!temTexto)
            .animation(.easeOut(duration: 0.15), value: temTexto)
            .accessibilityLabel("Marcar o compromisso")
            .accessibilityIdentifier("calendario-marcar")
        }
        .padding(.leading, 2)
        .padding(.trailing, 4)
        .padding(.vertical, 2)
        .background(CalendarioTema.campo, in: Capsule())
        .shadow(color: CalendarioTema.sombraCampo, radius: 12, y: 4)
    }
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
        VStack(spacing: compacto ? 0 : 1) {
            Text(Calendario.letraDoDia(dia, cal))
                .font(CalendarioTema.letra)
            Text(Calendario.formatar(dia, "d", cal))
                .font(compacto ? CalendarioTema.meta.monospacedDigit() : CalendarioTema.dia)
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
        .accessibilityLabel(Calendario.diaPorExtenso(dia, cal))
        .accessibilityAddTraits(activo ? [.isButton, .isSelected] : .isButton)
    }
}

struct CalendarioListaView: View {
    @Bindable var agenda: CalendarioAgenda

    var body: some View {
        let grupos = Dictionary(grouping: agenda.eventosDaEscala()) {
            Calendario.inicioDoDia($0.inicio, agenda.cal)
        }
        let dias = grupos.keys.sorted()
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if dias.isEmpty {
                    Text("Nada marcado.")
                        .font(CalendarioTema.evento)
                        .foregroundStyle(CalendarioTema.tintaSuave)
                        .padding(.top, 24)
                        .accessibilityIdentifier("calendario-lista-vazia")
                }
                ForEach(dias, id: \.self) { dia in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Calendario.diaPorExtenso(dia, agenda.cal))
                            .font(CalendarioTema.meta)
                            .foregroundStyle(CalendarioTema.tintaSuave)
                            .padding(.leading, 4)
                        ForEach(grupos[dia] ?? []) { evento in
                            Button {
                                agenda.abrir(evento)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: CalendarioTema.icone(de: evento))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(CalendarioTema.tinta(de: evento))
                                        .frame(width: 28, height: 28)
                                        .background(CalendarioTema.fundo(de: evento), in: Circle())
                                    Text(evento.titulo)
                                        .font(CalendarioTema.evento)
                                        .foregroundStyle(CalendarioTema.tinta)
                                        .lineLimit(1)
                                    Spacer(minLength: 8)
                                    Text(Calendario.intervalo(evento, agenda.cal))
                                        .font(CalendarioTema.hora)
                                        .foregroundStyle(CalendarioTema.tintaSuave)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .frame(minHeight: Tema.alvo)
                                .background(CalendarioTema.cartao, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(PressaoClara())
                        }
                    }
                }
            }
            .padding(.horizontal, CalendarioTema.margem)
            .padding(.bottom, 160)
        }
        .accessibilityIdentifier("calendario-lista")
    }
}

struct CalendarioAjustesView: View {
    @Bindable var agenda: CalendarioAgenda
    @Environment(\.dismiss) private var dismiss
    @State private var confirmarApagar = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Calendário")
                    .font(.title2.weight(.bold))
                    .tracking(-0.4)
                Spacer()
                Button("Pronto") { dismiss() }
                    .font(CalendarioTema.chrome)
                    .foregroundStyle(CalendarioTema.tinta)
                    .padding(.horizontal, 14)
                    .frame(height: CalendarioTema.controle)
                    .background(CalendarioTema.chip, in: Capsule())
                    .accessibilityIdentifier("ajustes-pronto")
            }

            Text("Vive no aparelho. Não sincroniza, e nunca escreve numa nota.")
                .font(CalendarioTema.meta)
                .foregroundStyle(CalendarioTema.tintaSuave)

            Toggle(isOn: Binding(
                get: { agenda.segundaPrimeiro },
                set: { agenda.segundaPrimeiro = $0 }
            )) {
                Text("Semana começa na segunda")
                    .font(.callout)
            }
            .tint(CalendarioTema.chipActivo)
            .padding(14)
            .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: CalendarioTema.raioCampo, style: .continuous))
            .accessibilityIdentifier("ajustes-segunda")

            HStack {
                Text(agenda.eventos.count == 1 ? "1 compromisso" : "\(agenda.eventos.count) compromissos")
                    .font(.callout)
                    .foregroundStyle(CalendarioTema.tintaSuave)
                Spacer()
                Button("Apagar tudo", role: .destructive) { confirmarApagar = true }
                    .font(CalendarioTema.meta)
                    .foregroundStyle(CalendarioTema.aviso)
                    .disabled(agenda.eventos.isEmpty)
                    .accessibilityIdentifier("ajustes-apagar-tudo")
            }
            .padding(14)
            .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: CalendarioTema.raioCampo, style: .continuous))

            Spacer()
        }
        .padding(CalendarioTema.margem)
        .padding(.top, 8)
        .foregroundStyle(CalendarioTema.tinta)
        .preferredColorScheme(.light)
        .confirmationDialog("Apagar todos os compromissos?", isPresented: $confirmarApagar, titleVisibility: .visible) {
            Button("Apagar tudo", role: .destructive) {
                agenda.apagarTudo()
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Não volta.")
        }
    }
}
