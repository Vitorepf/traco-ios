import SwiftUI
import UIKit

private struct AbrirCalendarioTrabalhoKey: EnvironmentKey {
    static let defaultValue: (@MainActor (Date) -> Bool)? = nil
}

extension EnvironmentValues {
    var abrirCalendarioDoTrabalho: (@MainActor (Date) -> Bool)? {
        get { self[AbrirCalendarioTrabalhoKey.self] }
        set { self[AbrirCalendarioTrabalhoKey.self] = newValue }
    }
}

/// ADR 05n: o horário e o aviso da ação se escolhem na mesma folha. A promessa
/// aparece em hora real ANTES de guardar; o estado de verdade vem DEPOIS do
/// commit, do motor — nunca do que se pediu (ADR 04a, 05k).
struct AgendamentoAcaoView: View {
    let acao: DocumentoTrabalho.Acao
    let podeGuardar: Bool
    /// O que o aviso virou depois de guardar (ou o que o centro tem, quando a
    /// folha reabre); `nil` enquanto não se sabe.
    var aviso: ResultadoDoAviso? = nil
    /// O iPhone está com os avisos do Traço desligados — a promessa cala.
    var permissaoNegada = false
    var guardar: (Date?, Int?) -> Void
    var verNoCalendario: (Date) -> Bool
    @State private var data = Date.now
    @State private var avisoMinutos: Int? = 0
    @State private var falhouAoAbrir = false
    private let cal = Calendario.gregoriano()

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
                    seletorDeAviso
                    linhaDoAviso
                    Button(acao.agendadaEm == nil ? "Marcar no calendário" : "Guardar novo horário") {
                        guardar(data, avisoMinutos)
                    }
                    .disabled(!podeGuardar)
                    .accessibilityIdentifier("trabalho-agendar")
                    Text("Marcar um horário não confirma a realização.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }
                if acao.agendadaEm != nil {
                    Button("Retirar o horário") { guardar(nil, nil) }
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
        .onAppear {
            data = acao.agendadaEm ?? .now
            // ação antiga com horário e sem a chave fica "não avisa", como foi
            // prometido a ela; ação nova nasce "na hora"
            avisoMinutos = acao.agendadaEm == nil ? 0 : acao.avisoMinutos
        }
        .onChange(of: acao.agendadaEm) { _, valor in if let valor { data = valor } }
        .onChange(of: acao.avisoMinutos) { _, valor in if acao.agendadaEm != nil { avisoMinutos = valor } }
    }

    /// Lista fechada do compromisso, na cápsula de menu (ADR 05f): o rótulo é
    /// a cápsula; o alvo de 44 pt vive no `Menu`.
    private var seletorDeAviso: some View {
        HStack {
            // mesmo peso do rótulo irmão "Dia e hora" do DatePicker (lei da similaridade)
            Text("Avisar").font(Tema.chrome).foregroundStyle(Tema.tinta)
            Spacer()
            Menu {
                ForEach(Aviso.opcoes, id: \.self) { minutos in
                    Button {
                        Toque.selecao()
                        avisoMinutos = minutos
                    } label: {
                        Label(Aviso.nome(minutos), systemImage: avisoMinutos == minutos ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: avisoMinutos == nil ? "bell.slash" : "bell.fill")
                        .font(.caption2)
                    Text(Aviso.nome(avisoMinutos))
                        .font(Tema.meta.weight(.medium))
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(avisoMinutos == nil ? Tema.tintaSuave : Tema.tinta)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Tema.chip, in: Capsule())
            }
            .menuStyle(.button)
            .buttonStyle(PressaoDiscreta())
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
            .accessibilityLabel("Avisar: \(Aviso.nome(avisoMinutos))")
            .accessibilityIdentifier("trabalho-aviso")
        }
    }

    /// UMA linha, sempre (ADR 04a). Enquanto a escolha na tela não foi
    /// guardada, a promessa do que Guardar vai fazer; depois, o que o motor e o
    /// centro de notificações dizem. Nunca as duas frases juntas.
    @ViewBuilder private var linhaDoAviso: some View {
        if let aviso, !alterado { estadoDoAviso(aviso) } else { promessa }
    }

    /// A escolha na tela ainda não é a do disco.
    private var alterado: Bool {
        data != acao.agendadaEm || avisoMinutos != acao.avisoMinutos
    }

    /// A promessa em unidade do mundo do autor, antes de guardar. Com os avisos
    /// desligados no iPhone não há promessa a fazer — há um caminho a mostrar.
    @ViewBuilder private var promessa: some View {
        if avisoMinutos == nil {
            linha("Sem aviso: só aparece no calendário do Traço.", "trabalho-aviso-promessa")
        } else if permissaoNegada {
            desligados("trabalho-aviso-promessa")
        } else {
            linha(textoDaPromessa, "trabalho-aviso-promessa")
        }
    }

    private var textoDaPromessa: String {
        guard let m = avisoMinutos else { return "" }
        let evento = EventoCalendario(titulo: acao.texto, inicio: data, fim: data, avisoMinutos: m)
        guard let quando = Aviso.promessa(de: evento, cal, manha: Ancora.hora(.manha)) else { return "" }
        return "Toca \(quando) · \(Aviso.nome(m).lowercased())."
    }

    /// Depois do commit: o motor disse o que aconteceu, e a tela repete.
    @ViewBuilder private func estadoDoAviso(_ aviso: ResultadoDoAviso) -> some View {
        switch aviso {
        case .agendado(let quando):
            let evento = EventoCalendario(titulo: acao.texto, inicio: quando, fim: quando, avisoMinutos: 0)
            linha("Aviso marcado para \(Aviso.promessa(de: evento, cal, manha: Ancora.hora(.manha)) ?? quando.formatted(date: .abbreviated, time: .shortened)).", "trabalho-aviso-estado")
        case .semPermissao:
            desligados("trabalho-aviso-estado")
        case .semEspaco:
            linha("O iPhone guarda \(Avisos.teto) avisos e já estão todos ocupados — esta ação ficou sem alarme.", "trabalho-aviso-estado", Tema.aviso)
        case .passou:
            linha("A hora do aviso já passou — esta ação ficou sem alarme.", "trabalho-aviso-estado", Tema.aviso)
        case .semAviso:
            if avisoMinutos == nil {
                linha("Sem aviso.", "trabalho-aviso-estado")
            } else {
                // origem liberada, reagendamento recusado: nada está armado, e a
                // folha diz o que falta fazer em vez de prometer
                linha("Este aviso não está marcado no iPhone — guarde o horário de novo.", "trabalho-aviso-estado", Tema.aviso)
            }
        }
    }

    /// ADR 03e: não é beco — a tela diz o que houve e leva aos Ajustes.
    private func desligados(_ id: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            linha("O iPhone está com os avisos do Traço desligados — nada vai tocar.", id, Tema.aviso)
            Button("Abrir os Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            .accessibilityIdentifier("trabalho-aviso-ajustes")
        }
    }

    private func linha(_ texto: String, _ id: String, _ cor: Color = Tema.tintaSuave) -> some View {
        Text(texto).font(Tema.meta).foregroundStyle(cor).accessibilityIdentifier(id)
    }
}
