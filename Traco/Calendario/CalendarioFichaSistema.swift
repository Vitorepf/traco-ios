import SwiftData
import SwiftUI
import UIKit

/// A3: o compromisso que veio do iPhone (Apple, Google, iCloud). O Traço só
/// lê — não há campo editável aqui, e não há apagar. A saída é o app
/// Calendário, que é o dono.
struct CalendarioFichaSistemaView: View {
    let evento: EventoCalendario
    let calendario: String
    @Bindable var agenda: CalendarioAgenda
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var abrir
    @Query private var notas: [Nota]
    @State private var doCaderno: [Nota] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                .accessibilityIdentifier("sistema-fechar")
                Spacer()
                Text(calendario.isEmpty ? "Do seu iPhone" : calendario)
                    .font(CalendarioTema.dia)
                    .foregroundStyle(CalendarioTema.tintaSuave)
                    .padding(.horizontal, 12)
                    .frame(height: CalendarioTema.controle)
                    .background(CalendarioTema.chip, in: Capsule())
                Spacer()
                Color.clear.frame(width: Tema.alvo, height: Tema.alvo)
            }

            Text(evento.titulo)
                .font(.system(.largeTitle, weight: .bold))
                .tracking(CalendarioTema.tituloTracking)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("sistema-titulo")

            VStack(alignment: .leading, spacing: 8) {
                Text("QUANDO")
                    .font(.caption2.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(CalendarioTema.tintaSuave)
                Text(Calendario.diaPorExtenso(evento.inicio, agenda.cal))
                    .font(.callout)
                Text(Calendario.intervalo(evento, agenda.cal))
                    .font(.callout)
                    .foregroundStyle(CalendarioTema.tintaSuave)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(CalendarioTema.campo, in: RoundedRectangle(cornerRadius: CalendarioTema.raioCampo, style: .continuous))

            if !doCaderno.isEmpty {
                DoCadernoView(vizinhas: doCaderno) { uuid in
                    dismiss()
                    agenda.aoAbrirNota?(uuid)
                }
            }

            Text("Este compromisso é do seu calendário, não do Traço. Ele aparece aqui para você ver o dia inteiro de uma vez — o Traço nunca o edita nem o apaga.")
                .font(.footnote)
                .foregroundStyle(CalendarioTema.tintaSuave)

            Button("Abrir no Calendário") {
                // `calshow:` com o instante em segundos desde 2001 abre o dia
                let quando = evento.inicio.timeIntervalSinceReferenceDate
                if let url = URL(string: "calshow:\(Int(quando))") { abrir(url) }
            }
            .font(CalendarioTema.chrome)
            .foregroundStyle(CalendarioTema.tinta)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .background(CalendarioTema.chip, in: Capsule())
            .buttonStyle(PressaoClara())
            .accessibilityIdentifier("sistema-abrir-calendario")

            Spacer(minLength: 0)
        }
        .padding(CalendarioTema.margem)
        .padding(.top, 8)
        .foregroundStyle(CalendarioTema.tinta)
        .background(CalendarioTema.fundo.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: "pt_BR"))
        .preferredColorScheme(.light)
        // ADR 04u/04w: folha de uma linha nasce no médio; com DO CADERNO
        // deixa de ser de uma linha e sobe ao grande
        .presentationDetents(doCaderno.isEmpty ? [.medium] : [.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(CalendarioTema.fundo)
        .task { doCaderno = await DoCadernoView.procurar(DoCadernoView.consulta(titulo: evento.titulo, notas: evento.notas), entre: notas) }
    }
}
