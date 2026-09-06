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

/// A promessa do aviso, antes de guardar. Pura, porque é a frase que a volta 9
/// pegou mentindo: "Toca hoje às 20:22 · na hora" com os avisos do iPhone
/// desligados. Um `Bool permissaoNegada` juntava dois estados diferentes —
/// *negado* e *ainda não perguntado* — e só o primeiro calava a promessa.
/// Aqui os três estados de `Avisos.Estado` (mais o "ainda lendo") são
/// distintos, e nenhum deles afirma que o iPhone vai tocar sem saber que vai.
enum PromessaDoAviso: Equatable {
    /// Não pediu aviso: o ato só aparece no calendário do Traço.
    case semAviso
    /// A permissão está concedida: a promessa vale.
    case toca(String)
    /// Vai tocar SE o iPhone deixar — ele ainda nem perguntou, ou a leitura
    /// não voltou. A hora é dita; o alarme, não.
    case seDeixarem(String)
    /// Os avisos do Traço estão desligados: não é promessa, é beco com saída.
    case desligados

    static func para(minutos: Int?, estado: Avisos.Estado?, hora: String) -> PromessaDoAviso {
        guard minutos != nil else { return .semAviso }
        switch estado {
        case .negado: return .desligados
        case .concedido: return .toca(hora)
        case .naoPerguntado, nil: return .seDeixarem(hora)
        }
    }

    var texto: String {
        switch self {
        case .semAviso: "Sem aviso: só aparece no calendário do Traço."
        case .toca(let quando): "Toca \(quando)."
        case .seDeixarem(let quando): "Toca \(quando), se você permitir os avisos quando o iPhone perguntar."
        case .desligados: "O iPhone está com os avisos do Traço desligados — nada vai tocar."
        }
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
    var guardar: (Date?, Int?) -> Void
    var verNoCalendario: (Date) -> Bool
    @State private var data = Date.now
    @State private var avisoMinutos: Int? = 0
    @State private var falhouAoAbrir = false
    /// A permissão de hoje, lida aqui: a promessa é desta tela, e uma fonte só
    /// evita a janela em que a frase promete antes de a leitura voltar.
    @State private var permissao: Avisos.Estado?
    @Environment(\.scenePhase) private var scenePhase
    private let cal = Calendario.gregoriano()

    var body: some View {
        DisclosureGroup(!podeGuardar ? "Horário com alteração pendente" : acao.agendadaEm == nil ? "Escolher um horário" : "Horário no calendário") {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                if !podeGuardar {
                    Text("A alteração ainda não foi guardada. O calendário mantém o último horário confirmado.")
                        .font(Tema.meta).foregroundStyle(Tema.aviso)
                }
                if let atual = acao.agendadaEm {
                    Text(atual.formatted(date: .abbreviated, time: .shortened))
                        .font(Tema.meta).monospacedDigit()
                }
                if acao.estado == .pendente { quando }
                if acao.agendadaEm != nil {
                    Pilula("Retirar o horário", forma: .filtro) { guardar(nil, nil) }
                        .disabled(!podeGuardar)
                        .accessibilityIdentifier("trabalho-retirar-horario")
                }
                if podeGuardar, acao.estado == .pendente, let atual = acao.agendadaEm {
                    Pilula("Ver no calendário", forma: .filtro) { falhouAoAbrir = !verNoCalendario(atual) }
                        .accessibilityIdentifier("trabalho-ver-calendario")
                    if falhouAoAbrir {
                        Text("Não foi possível abrir o calendário agora. O horário foi preservado; volte à página para verificar a prática em andamento ou o salvamento.")
                            .font(Tema.meta).foregroundStyle(Tema.aviso)
                    }
                }
            }.padding(.top, 8)
        }
        .font(Tema.chrome)
        .tint(Tema.tintaSuave)
        .onAppear {
            data = acao.agendadaEm ?? .now
            // ação antiga com horário e sem a chave fica "não avisa", como foi
            // prometido a ela; ação nova nasce "na hora"
            avisoMinutos = acao.agendadaEm == nil ? 0 : acao.avisoMinutos
        }
        .task { permissao = await Avisos.estado() }
        .onChange(of: scenePhase) { _, fase in
            // voltar dos Ajustes com o interruptor virado não pode deixar a
            // frase velha na tela
            if fase == .active { Task { permissao = await Avisos.estado() } }
        }
        .onChange(of: acao.agendadaEm) { _, valor in if let valor { data = valor } }
        .onChange(of: acao.avisoMinutos) { _, valor in if acao.agendadaEm != nil { avisoMinutos = valor } }
    }

    /// "Quando" na forma da ficha do calendário (SISTEMA-CLARO §2.3): campo em
    /// névoa, linhas separadas por hairline, o alvo de 44 em cada linha.
    private var quando: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            VStack(spacing: 0) {
                DatePicker("Dia e hora", selection: $data)
                    .datePickerStyle(.compact)
                    .padding(.vertical, 6)
                    .accessibilityIdentifier("trabalho-dia-hora")
                divisoria
                seletorDeAviso
                divisoria
                linhaDoAviso
            }
            .font(.callout)
            .tint(Tema.tinta)
            .cartao(.campo, recuo: .horizontal)
            Pilula(acao.agendadaEm == nil ? "Marcar no calendário" : "Guardar novo horário",
                   forma: .larga, selecionada: true) { guardar(data, avisoMinutos) }
                .disabled(!podeGuardar)
                .accessibilityIdentifier("trabalho-agendar")
            Text("Marcar um horário não confirma a realização.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
        }
    }

    private var divisoria: some View {
        Rectangle().fill(Tema.linha).frame(height: 1)
    }

    /// Lista fechada do compromisso, na linha que abre da casa (ADR 05f).
    private var seletorDeAviso: some View {
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
            LinhaQueAbre("Avisar", valor: Aviso.nome(avisoMinutos)) {
                Image(systemName: avisoMinutos == nil ? "bell.slash" : "bell.fill")
                    .font(.footnote)
                    .foregroundStyle(avisoMinutos == nil ? Tema.tintaSuave : Tema.tinta)
            }
        }
        .accessibilityLabel("Avisar: \(Aviso.nome(avisoMinutos))")
        .accessibilityIdentifier("trabalho-aviso")
    }

    /// UMA linha, sempre (ADR 04a). Enquanto a escolha na tela não foi
    /// guardada, o que Guardar vai fazer; depois, o que o motor e o centro de
    /// notificações dizem. Nunca as duas frases juntas.
    @ViewBuilder private var linhaDoAviso: some View {
        if let aviso, !alterado { estadoDoAviso(aviso) } else { promessa }
    }

    /// A escolha na tela ainda não é a do disco.
    private var alterado: Bool {
        data != acao.agendadaEm || avisoMinutos != acao.avisoMinutos
    }

    /// A promessa em unidade do mundo do autor, antes de guardar.
    @ViewBuilder private var promessa: some View {
        let p = PromessaDoAviso.para(minutos: avisoMinutos, estado: permissao, hora: horaDaPromessa)
        if p == .desligados {
            desligados(p.texto, "trabalho-aviso-promessa")
        } else {
            linha(p.texto, "trabalho-aviso-promessa")
        }
    }

    private var horaDaPromessa: String {
        guard let m = avisoMinutos else { return "" }
        let evento = EventoCalendario(titulo: acao.texto, inicio: data, fim: data, avisoMinutos: m)
        guard let quando = Aviso.promessa(de: evento, cal, manha: Ancora.hora(.manha)) else { return "" }
        return "\(quando) · \(Aviso.nome(m).lowercased())"
    }

    /// Depois do commit: o motor disse o que aconteceu, e a tela repete.
    @ViewBuilder private func estadoDoAviso(_ aviso: ResultadoDoAviso) -> some View {
        switch aviso {
        case .agendado(let quando):
            let evento = EventoCalendario(titulo: acao.texto, inicio: quando, fim: quando, avisoMinutos: 0)
            linha("Aviso marcado para \(Aviso.promessa(de: evento, cal, manha: Ancora.hora(.manha)) ?? quando.formatted(date: .abbreviated, time: .shortened)).", "trabalho-aviso-estado")
        case .semPermissao:
            desligados(PromessaDoAviso.desligados.texto, "trabalho-aviso-estado")
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

    /// ADR 03e: não é beco — a tela diz o que houve e leva aos Ajustes. O
    /// âmbar é a saída de um problema, o único emprego dele nesta folha.
    private func desligados(_ texto: String, _ id: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            linha(texto, id, Tema.aviso)
            Button("Abrir os Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            .font(Tema.chrome.weight(.semibold))
            .foregroundStyle(Tema.ambarTinta)
            .buttonStyle(.compacto)
            .accessibilityIdentifier("trabalho-aviso-ajustes")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private func linha(_ texto: String, _ id: String, _ cor: Color = Tema.tintaSuave) -> some View {
        Text(texto).font(Tema.meta).foregroundStyle(cor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .accessibilityIdentifier(id)
    }
}
