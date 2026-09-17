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
            CabecalhoDeFolha(aoSair: { dismiss() }, prefixo: "sistema") {
                Pilula(calendario.isEmpty ? "Do seu iPhone" : calendario, forma: .controle)
            }

            Text(evento.titulo)
                .font(.system(.largeTitle, weight: .bold))
                .tracking(CalendarioTema.tituloTracking)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("sistema-titulo")

            // ADR 10k: o "QUANDO" ficava DENTRO do cartão, nomeando o que
            // estava nele; agora é cabeçalho, fora, como na ficha do Traço
            VStack(alignment: .leading, spacing: 8) {
                Text("Quando")
                    .rotulo(Tema.tintaSuave)
                    .padding(.leading, 4)
                VStack(alignment: .leading, spacing: 8) {
                    Text(Calendario.diaPorExtenso(evento.inicio, agenda.cal))
                        .font(.callout)
                    Text(Calendario.intervalo(evento, agenda.cal))
                        .font(.callout)
                        .foregroundStyle(CalendarioTema.tintaSuave)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cartao(.campo)
            }

            if !doCaderno.isEmpty {
                DoCadernoView(vizinhas: doCaderno) { uuid in
                    dismiss()
                    agenda.aoAbrirNota?(uuid)
                }
            }

            Text("Este compromisso é do seu calendário, não do Traço. Ele aparece aqui para você ver o dia inteiro de uma vez — o Traço nunca o edita nem o apaga.")
                .font(.footnote)
                .foregroundStyle(CalendarioTema.tintaSuave)

            Pilula("Abrir no Calendário", forma: .larga) {
                // `calshow:` com o instante em segundos desde 2001 abre o dia
                let quando = evento.inicio.timeIntervalSinceReferenceDate
                if let url = URL(string: "calshow:\(Int(quando))") { abrir(url) }
            }
            .accessibilityIdentifier("sistema-abrir-calendario")

            Spacer(minLength: 0)
        }
        .padding(CalendarioTema.margem)
        .padding(.top, 8)
        .foregroundStyle(CalendarioTema.tinta)
        .background(CalendarioTema.fundo.ignoresSafeArea())
        .environment(\.locale, Locale(identifier: "pt_BR"))
        .mundoDoAutor()
        // ADR 04u/04w: folha de uma linha nasce no médio; com DO CADERNO
        // deixa de ser de uma linha e sobe ao grande
        .presentationDetents(doCaderno.isEmpty ? [.medium] : [.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(CalendarioTema.fundo)
        .task { doCaderno = await DoCadernoView.procurar(DoCadernoView.consulta(titulo: evento.titulo, notas: evento.notas), entre: notas) }
    }
}
