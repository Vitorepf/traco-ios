import SwiftUI

struct CalendarioFichaView: View {
    @State var evento: EventoCalendario
    @Bindable var agenda: CalendarioAgenda
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(CalendarioTema.tinta)
                                .frame(width: 36, height: 36)
                                .background(CalendarioTema.chip, in: Circle())
                        }
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityLabel("Close")

                        Spacer()

                        Menu {
                            ForEach(CategoriaEvento.allCases, id: \.self) { cat in
                                Button {
                                    evento.categoria = cat
                                } label: {
                                    Label(rotulo(cat), systemImage: CalendarioTema.icone(de: cat))
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: CalendarioTema.icone(de: evento.categoria))
                                    .foregroundStyle(CalendarioTema.tinta(de: evento.categoria))
                                Text(rotulo(evento.categoria))
                                    .font(.system(size: 15, weight: .semibold))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(CalendarioTema.tintaSuave)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 36)
                            .background(CalendarioTema.chip, in: Capsule())
                        }

                        Spacer()

                        Button("Done") {
                            agenda.guardar(evento)
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CalendarioTema.tinta)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(CalendarioTema.chip, in: Capsule())
                        .accessibilityIdentifier("ficha-done")
                    }

                    TextField("Title", text: $evento.titulo)
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(CalendarioTema.tinta)
                        .padding(.top, 8)
                        .accessibilityIdentifier("ficha-titulo")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(CalendarioTema.meta)
                            .foregroundStyle(CalendarioTema.tintaSuave)
                        TextField("Add notes…", text: $evento.notas, axis: .vertical)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Timing")
                            .font(CalendarioTema.meta)
                            .foregroundStyle(CalendarioTema.tintaSuave)
                        Toggle("All-day", isOn: $evento.diaInteiro)
                        DatePicker("Date", selection: $evento.inicio, displayedComponents: .date)
                        if !evento.diaInteiro {
                            DatePicker("Starts at", selection: $evento.inicio, displayedComponents: .hourAndMinute)
                            DatePicker("Ends at", selection: $evento.fim, displayedComponents: .hourAndMinute)
                            Text(duracao)
                                .font(CalendarioTema.meta)
                                .foregroundStyle(CalendarioTema.tintaSuave)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }

                    Button("Delete event", role: .destructive) {
                        agenda.apagar(evento.id)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
                .padding(22)
            }
            .background(CalendarioTema.fundo.ignoresSafeArea())
        }
        .preferredColorScheme(.light)
        .onChange(of: evento.inicio) { _, novo in
            if evento.fim <= novo {
                evento.fim = novo.addingTimeInterval(30 * 60)
            }
        }
    }

    private var duracao: String {
        let m = evento.duracaoMinutos
        if m < 60 { return "\(m)min" }
        let h = m / 60
        let resto = m % 60
        return resto == 0 ? "\(h)h" : "\(h)h \(resto)min"
    }

    private func rotulo(_ cat: CategoriaEvento) -> String {
        switch cat {
        case .trabalho: "Work"
        case .corpo: "Body"
        case .social: "Social"
        case .casa: "Home"
        case .outro: "Other"
        }
    }
}
