import SwiftUI

struct CalendarioFichaView: View {
    @State var evento: EventoCalendario
    @Bindable var agenda: CalendarioAgenda
    @Environment(\.dismiss) private var dismiss
    @FocusState private var tituloEmFoco: Bool

    private var jaExiste: Bool { agenda.eventos.contains { $0.id == evento.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CalendarioTema.tinta)
                            .frame(width: CalendarioTema.controle, height: CalendarioTema.controle)
                            .background(CalendarioTema.chip, in: Circle())
                            .frame(width: Tema.alvo, height: Tema.alvo)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressaoClara())
                    .accessibilityLabel("Fechar")
                    .accessibilityIdentifier("ficha-fechar")

                    Spacer()

                    Menu {
                        ForEach(Dominio.allCases) { dom in
                            Button {
                                evento.dominio = dom
                            } label: {
                                Label(dom.nome, systemImage: CalendarioTema.icone(de: dom))
                            }
                        }
                        Button {
                            evento.dominio = nil
                        } label: {
                            Label("Sem domínio", systemImage: "circle.dashed")
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: CalendarioTema.icone(de: evento.dominio))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CalendarioTema.tinta(de: evento.dominio))
                            Text(evento.dominio?.nome ?? "Domínio")
                                .font(CalendarioTema.dia)
                            Image(systemName: "chevron.down")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(CalendarioTema.tintaSuave)
                        }
                        .foregroundStyle(CalendarioTema.tinta)
                        .padding(.horizontal, 12)
                        .frame(height: CalendarioTema.controle)
                        .background(CalendarioTema.fundo(de: evento.dominio), in: Capsule())
                        .frame(height: Tema.alvo)
                    }
                    .accessibilityIdentifier("ficha-dominio")

                    Spacer()

                    Button("Pronto") {
                        agenda.guardar(evento)
                        dismiss()
                    }
                    .font(CalendarioTema.chrome)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: CalendarioTema.controle)
                    .background(CalendarioTema.chipActivo, in: Capsule())
                    .frame(height: Tema.alvo)
                    .accessibilityIdentifier("ficha-pronto")
                }

                TextField("Título", text: $evento.titulo, axis: .vertical)
                    .font(.system(.largeTitle, weight: .bold))
                    .tracking(CalendarioTema.tituloTracking)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .foregroundStyle(CalendarioTema.tinta)
                    .focused($tituloEmFoco)
                    .padding(.top, 4)
                    .accessibilityIdentifier("ficha-titulo")

                secao("Quando") {
                    VStack(spacing: 0) {
                        Toggle("Dia inteiro", isOn: Binding(
                            get: { evento.diaInteiro },
                            set: { todo in
                                evento.diaInteiro = todo
                                if todo {
                                    evento.inicio = Calendario.inicioDoDia(evento.inicio, agenda.cal)
                                    evento.fim = Calendario.hora(24, 0, no: evento.inicio, agenda.cal)
                                } else {
                                    evento = evento.comInicio(Calendario.hora(9, 0, no: evento.inicio, agenda.cal))
                                    evento.fim = evento.inicio.addingTimeInterval(3600)
                                }
                            }
                        ))
                        .tint(CalendarioTema.chipActivo)
                        .padding(.vertical, 10)
                        divisoria
                        DatePicker("Data", selection: Binding(
                            get: { evento.inicio },
                            set: { evento = evento.movido(paraODiaDe: $0, agenda.cal) }
                        ), displayedComponents: .date)
                        .padding(.vertical, 6)
                        if !evento.diaInteiro {
                            divisoria
                            DatePicker("Começa", selection: Binding(
                                get: { evento.inicio },
                                set: { evento = evento.comInicio($0) }
                            ), displayedComponents: .hourAndMinute)
                            .padding(.vertical, 6)
                            divisoria
                            DatePicker("Termina", selection: Binding(
                                get: { evento.fim },
                                set: { evento = evento.comFim($0) }
                            ), displayedComponents: .hourAndMinute)
                            .padding(.vertical, 6)
                            divisoria
                            HStack {
                                Text("Duração")
                                Spacer()
                                Text(duracao)
                                    .monospacedDigit()
                                    .foregroundStyle(CalendarioTema.tintaSuave)
                                    .contentTransition(.numericText())
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    .font(.callout)
                    .tint(CalendarioTema.tinta)
                    .padding(.horizontal, 14)
                    .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: CalendarioTema.raioCampo, style: .continuous))
                }

                secao("Notas") {
                    TextField("Algo a lembrar", text: $evento.notas, axis: .vertical)
                        .font(.callout)
                        .lineLimit(2...6)
                        .padding(14)
                        .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: CalendarioTema.raioCampo, style: .continuous))
                        .accessibilityIdentifier("ficha-notas")
                }

                if jaExiste {
                    Button {
                        agenda.apagar(evento.id)
                        dismiss()
                    } label: {
                        Text("Apagar compromisso")
                            .font(CalendarioTema.chrome)
                            .foregroundStyle(CalendarioTema.aviso)
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                    }
                    .buttonStyle(PressaoClara())
                    .accessibilityIdentifier("ficha-apagar")
                }
            }
            .padding(CalendarioTema.margem)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(CalendarioTema.fundo.ignoresSafeArea())
        .foregroundStyle(CalendarioTema.tinta)
        .environment(\.locale, Locale(identifier: "pt_BR"))
        .preferredColorScheme(.light)
        .onAppear {
            if evento.titulo.isEmpty { tituloEmFoco = true }
        }
    }

    private var divisoria: some View {
        Rectangle().fill(CalendarioTema.linha).frame(height: 1)
    }

    private func secao<Conteudo: View>(_ titulo: String, @ViewBuilder _ conteudo: () -> Conteudo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(CalendarioTema.tintaSuave)
                .padding(.leading, 4)
            conteudo()
        }
    }

    private var duracao: String {
        let m = evento.duracaoMinutos
        if m < 60 { return "\(m) min" }
        let h = m / 60
        let resto = m % 60
        return resto == 0 ? "\(h) h" : "\(h) h \(resto) min"
    }
}
