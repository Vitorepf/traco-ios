import SwiftUI

struct CalendarioView: View {
    @State var agenda: CalendarioAgenda
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var morph

    init(agenda: CalendarioAgenda = CalendarioAgenda()) {
        _agenda = State(initialValue: agenda)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            CalendarioTema.fundo.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                cabeca
                Group {
                    if agenda.modo == .lista {
                        CalendarioListaView(agenda: agenda)
                    } else {
                        escalas
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // A camada do arquivo é full-bleed: sem isto o título sobe ao
            // Dynamic Island e o «2026» do mês some por baixo do pill.
            .padding(.top, 56)

            chrome
        }
        .foregroundStyle(CalendarioTema.tinta)
        .preferredColorScheme(.light)
        .sheet(item: $agenda.ficha) { evento in
            CalendarioFichaView(evento: evento, agenda: agenda)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $agenda.ajustes) {
            CalendarioAjustesView()
        }
        .confirmationDialog("Add", isPresented: $agenda.menuMais, titleVisibility: .hidden) {
            Button("Paste") { agenda.colar() }
            Button("Edit existing events") {
                if let primeiro = agenda.eventos(no: agenda.ancora).first {
                    agenda.ficha = primeiro
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .accessibilityIdentifier("calendario")
        .onAppear { aplicarEscalaDaRota() }
        .onReceive(NotificationCenter.default.publisher(for: Rota.mudou)) { _ in
            aplicarEscalaDaRota()
        }
    }

    private func aplicarEscalaDaRota() {
        guard let escala = Rota.escalaCalendario else { return }
        Rota.escalaCalendario = nil
        withAnimation(CalendarioTema.morph(reduceMotion)) {
            agenda.ir(para: escala)
        }
    }

    private var cabeca: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(agenda.titulo)
                .font(CalendarioTema.titulo)
                .tracking(-0.6)
                .foregroundStyle(CalendarioTema.tinta)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(0)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("calendario-titulo")
            cabecaBotao("ellipsis") { agenda.menuMais = true }
                .accessibilityLabel("More")
                .layoutPriority(1)
            cabecaBotao("gearshape") { agenda.ajustes = true }
                .accessibilityLabel("Settings")
                .layoutPriority(1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private func cabecaBotao(_ icone: String, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            Image(systemName: icone)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(CalendarioTema.tintaSuave)
                .frame(width: 36, height: 36)
                .background(CalendarioTema.chip, in: Circle())
        }
        .buttonStyle(PressaoDiscreta())
        .frame(minWidth: Tema.alvo, minHeight: Tema.alvo)
    }

    @ViewBuilder
    private var escalas: some View {
        ZStack {
            if agenda.escala == .dia {
                CalendarioDiaView(agenda: agenda, morph: morph)
                    .transition(CalendarioTema.transicao(reduzido: reduceMotion))
            }
            if agenda.escala == .semana {
                CalendarioSemanaView(agenda: agenda, morph: morph)
                    .transition(CalendarioTema.transicao(reduzido: reduceMotion))
            }
            if agenda.escala == .mes {
                CalendarioMesView(agenda: agenda, morph: morph)
                    .transition(CalendarioTema.transicao(reduzido: reduceMotion))
            }
            if agenda.escala == .ano {
                CalendarioAnoView(agenda: agenda, morph: morph)
                    .transition(CalendarioTema.transicao(reduzido: reduceMotion))
            }
        }
        .clipped()
        .animation(CalendarioTema.morph(reduceMotion), value: agenda.escala)
    }

    private var chrome: some View {
        VStack(spacing: 10) {
            interruptor
            campoProsa
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private var interruptor: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                modoBotao(.lista, icone: "list.bullet")
                modoBotao(.grelha, icone: "calendar")
            }
            HStack(spacing: 0) {
                ForEach(EscalaCalendario.allCases, id: \.self) { escala in
                    Button {
                        Toque.selecao()
                        withAnimation(CalendarioTema.morph(reduceMotion)) {
                            agenda.ir(para: escala)
                        }
                    } label: {
                        Text(escala.letra)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(agenda.escala == escala ? .white : CalendarioTema.tintaSuave)
                            .frame(width: 36, height: 36)
                            .background {
                                if agenda.escala == escala {
                                    Circle().fill(CalendarioTema.chipActivo)
                                }
                            }
                    }
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityIdentifier("escala-\(escala.rawValue)")
                    .accessibilityLabel(escala.rawValue)
                    .accessibilityAddTraits(agenda.escala == escala ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(4)
            .background(CalendarioTema.campo, in: Capsule())

            if !agenda.ancoraEHoje || agenda.escala == .mes || agenda.escala == .ano {
                Button {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) {
                        agenda.irHoje()
                    }
                } label: {
                    Text("Today")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(CalendarioTema.chipActivo, in: Capsule())
                }
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("calendario-hoje")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CalendarioTema.cartao, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        .accessibilityIdentifier("calendario-interruptor")
    }

    private func modoBotao(_ modo: ModoCalendario, icone: String) -> some View {
        Button {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) {
                agenda.modo = modo
            }
        } label: {
            Image(systemName: icone)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(agenda.modo == modo ? .white : CalendarioTema.tintaSuave)
                .frame(width: 36, height: 36)
                .background {
                    if agenda.modo == modo {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(CalendarioTema.chipActivo)
                    }
                }
        }
        .buttonStyle(PressaoDiscreta())
        .accessibilityIdentifier("modo-\(modo.rawValue)")
        .accessibilityLabel(modo == .lista ? "List" : "Grid")
        .accessibilityAddTraits(agenda.modo == modo ? [.isButton, .isSelected] : .isButton)
    }

    private var campoProsa: some View {
        HStack(spacing: 10) {
            Button {
                agenda.menuMais = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(CalendarioTema.tinta)
                    .frame(width: Tema.alvo, height: Tema.alvo)
            }
            .buttonStyle(PressaoDiscreta())
            .accessibilityLabel("Add")

            TextField(
                "",
                text: $agenda.prosa,
                prompt: Text("Add events in plain English…")
                    .foregroundStyle(CalendarioTema.tintaSuave)
            )
            .font(.system(size: 16))
            .foregroundStyle(CalendarioTema.tinta)
            .textInputAutocapitalization(.sentences)
            .submitLabel(.done)
            .onSubmit { agenda.adicionarDaProsa() }
            .accessibilityIdentifier("calendario-prosa")
            .accessibilityLabel("Add events in plain English")

            Button {
                agenda.adicionarDaProsa()
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CalendarioTema.tinta)
                    .frame(width: 36, height: 36)
                    .background(CalendarioTema.chip, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(PressaoDiscreta())
            .accessibilityLabel("Add the event")
            .accessibilityIdentifier("calendario-microfone")
        }
        .padding(.leading, 6)
        .padding(.trailing, 10)
        .padding(.vertical, 6)
        .background(CalendarioTema.campo, in: Capsule())
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}

struct CalendarioChipDia: View {
    let dia: Date
    let activo: Bool
    let cal: Calendar
    var compacto: Bool = false

    var body: some View {
        VStack(spacing: compacto ? 0 : 1) {
            Text(Calendario.letraDoDia(dia, cal))
                .font(CalendarioTema.letra)
            Text(Calendario.formatar(dia, "d", cal))
                .font(compacto ? CalendarioTema.meta : CalendarioTema.dia)
        }
        .foregroundStyle(activo ? .white : CalendarioTema.tintaSuave)
        .frame(width: compacto ? 36 : 44, height: compacto ? 36 : 44)
        .background(
            activo ? CalendarioTema.chipActivo : CalendarioTema.chip,
            in: Circle()
        )
        .accessibilityLabel(Calendario.formatar(dia, "EEEE d MMMM", cal))
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
            LazyVStack(alignment: .leading, spacing: 18) {
                if dias.isEmpty {
                    Text("No events in this view.")
                        .font(CalendarioTema.evento)
                        .foregroundStyle(CalendarioTema.tintaSuave)
                        .padding(.top, 24)
                }
                ForEach(dias, id: \.self) { dia in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Calendario.formatar(dia, "EEEE d MMMM", agenda.cal))
                            .font(CalendarioTema.meta)
                            .foregroundStyle(CalendarioTema.tintaSuave)
                        ForEach(grupos[dia] ?? []) { evento in
                            Button {
                                agenda.ficha = evento
                            } label: {
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(CalendarioTema.fundo(de: evento.categoria))
                                        .frame(width: 10, height: 10)
                                    Text(evento.titulo)
                                        .font(CalendarioTema.evento)
                                        .foregroundStyle(CalendarioTema.tinta)
                                    Spacer()
                                    Text(hora(evento))
                                        .font(CalendarioTema.hora)
                                        .foregroundStyle(CalendarioTema.tintaSuave)
                                }
                                .padding(14)
                                .background(CalendarioTema.cartao, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(PressaoDiscreta())
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 160)
        }
        .accessibilityIdentifier("calendario-lista")
    }

    private func hora(_ evento: EventoCalendario) -> String {
        if evento.diaInteiro { return "All day" }
        return "\(Calendario.formatar(evento.inicio, "HH:mm", agenda.cal))–\(Calendario.formatar(evento.fim, "HH:mm", agenda.cal))"
    }
}

struct CalendarioAjustesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("This calendar lives on the phone. It does not sync, and it never writes into a note.")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
