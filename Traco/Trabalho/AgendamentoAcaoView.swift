import SwiftUI

private struct AbrirCalendarioTrabalhoKey: EnvironmentKey {
    static let defaultValue: (@MainActor (Date) -> Bool)? = nil
}

extension EnvironmentValues {
    var abrirCalendarioDoTrabalho: (@MainActor (Date) -> Bool)? {
        get { self[AbrirCalendarioTrabalhoKey.self] }
        set { self[AbrirCalendarioTrabalhoKey.self] = newValue }
    }
}

struct AgendamentoAcaoView: View {
    let acao: DocumentoTrabalho.Acao
    let podeGuardar: Bool
    var guardar: (Date?) -> Void
    var verNoCalendario: (Date) -> Bool
    @State private var data = Date.now
    @State private var falhouAoAbrir = false

    var body: some View {
        DisclosureGroup(!podeGuardar ? "Horário com alteração pendente" : acao.agendadaEm == nil ? "Escolher um horário" : "Horário no calendário") {
            VStack(alignment: .leading, spacing: 12) {
                if !podeGuardar {
                    Text("A alteração ainda não foi guardada. O calendário mantém o último horário confirmado.")
                        .font(Tema.meta).foregroundStyle(Tema.aviso)
                }
                if let atual = acao.agendadaEm {
                    Text(atual.formatted(date: .abbreviated, time: .shortened))
                        .font(Tema.meta)
                }
                if acao.estado == .pendente {
                    DatePicker("Dia e hora", selection: $data)
                        .datePickerStyle(.compact)
                        .accessibilityIdentifier("trabalho-dia-hora")
                    Button(acao.agendadaEm == nil ? "Marcar no calendário" : "Guardar novo horário") {
                        guardar(data)
                    }
                    .disabled(!podeGuardar)
                    .accessibilityIdentifier("trabalho-agendar")
                    Text("Aparece no calendário do Traço, sem alerta. Marcar um horário não confirma a realização.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }
                if acao.agendadaEm != nil {
                    Button("Retirar o horário") { guardar(nil) }
                        .disabled(!podeGuardar)
                        .accessibilityIdentifier("trabalho-retirar-horario")
                }
                if podeGuardar, acao.estado == .pendente, let atual = acao.agendadaEm {
                    Button("Ver no calendário") { falhouAoAbrir = !verNoCalendario(atual) }
                        .accessibilityIdentifier("trabalho-ver-calendario")
                    if falhouAoAbrir {
                        Text("Não foi possível abrir o calendário agora. O horário foi preservado; volte à página para verificar a prática em andamento ou o salvamento.")
                            .font(Tema.meta).foregroundStyle(Tema.aviso)
                    }
                }
            }.padding(.top, 8)
        }
        .onAppear { data = acao.agendadaEm ?? .now }
        .onChange(of: acao.agendadaEm) { _, valor in if let valor { data = valor } }
    }
}
