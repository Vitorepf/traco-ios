import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

// ADR 05u: os widgets LEEM `Superficie` (o snapshot do App Group) e nada mais.
// Nenhuma chave solta, nenhum domínio, nenhum reload por minuto: a linha do
// tempo já traz as transições conhecidas (meia-noite, fim de cada próximo,
// horizonte) e o app recarrega os kinds afetados depois de cada escrita.
// Tipografia pelos degraus de `Tema` (D3): escala com o sistema.

struct EntradaTraco: TimelineEntry {
    let date: Date
    let leitura: SuperficieDisco.Leitura

    var indisponivel: Bool { leitura == .indisponivel }
    var destaque: Superficie.Destaque? {
        guard case .disponivel(let s) = leitura else { return nil }
        return s.destaqueDeHoje(agora: date)
    }
    var geradoEm: Date? {
        guard case .disponivel(let s) = leitura else { return nil }
        return s.geradoEm
    }
}

struct ProvedorTraco: TimelineProvider {
    private func entrada(_ agora: Date = .now) -> EntradaTraco {
        EntradaTraco(date: agora, leitura: SuperficieDisco.ler())
    }
    func placeholder(in context: Context) -> EntradaTraco { entrada() }
    func getSnapshot(in context: Context, completion: @escaping (EntradaTraco) -> Void) {
        completion(entrada())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaTraco>) -> Void) {
        let agora = Date()
        let e = entrada(agora)
        var entradas = [e]
        if e.destaque != nil {
            // o Destaque acaba com o dia: à meia-noite a mesma leitura vira ausência
            let meiaNoite = Calendar.current.startOfDay(
                for: Calendar.current.date(byAdding: .day, value: 1, to: agora) ?? agora)
            entradas.append(EntradaTraco(date: meiaNoite, leitura: e.leitura))
        }
        completion(Timeline(entries: entradas, policy: entradas.count > 1 ? .atEnd : .never))
    }
}

/// Um alvo de toque: a palavra, a área inteira. Sem ícone — o vocabulário é o gesto.
private struct AtalhoTraco: View {
    let rota: String
    let rotulo: String
    let destaque: Bool

    var body: some View {
        Link(destination: URL(string: rota)!) {
            Text(rotulo)
                .font(Tema.meta.weight(.medium))
                .foregroundStyle(destaque ? Tema.ambarTinta : Tema.tinta)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(rotulo)
    }
}

/// A idade do que está na tela, dita (ADR 05u) — em hora absoluta: "há 1 min
/// e 58 seg" mudava a cada segundo numa superfície que o conselho quis calma.
private struct RodapeAtualizado: View {
    let gerado: Date

    var body: some View {
        Text("atualizado às \(Superficie.horaCurta(gerado))")
            .font(Tema.miudo)
            .foregroundStyle(Tema.tintaFraca)
            .lineLimit(1)
    }
}

/// O botão do feito, com identidade (ADR 05u): marca ou desfaz — dois
/// intents, nunca um toggle. O mesmo gesto na casa e na tela bloqueada (04f).
private struct BotaoFeito<Rotulo: View>: View {
    let destaque: Superficie.Destaque
    @ViewBuilder let rotulo: () -> Rotulo

    var body: some View {
        Group {
            if destaque.feito {
                Button(intent: DestaqueDesfazerIntent(nota: destaque.id, dia: destaque.dia)) { rotulo() }
            } else {
                Button(intent: DestaqueFeitoIntent(nota: destaque.id, dia: destaque.dia)) { rotulo() }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(destaque.feito ? "Feito: \(destaque.linha)" : destaque.linha)
        .accessibilityHint(destaque.feito ? "Desfaz o feito" : "Marca a única coisa de hoje como feita")
    }
}

struct TracoWidgetView: View {
    @Environment(\.widgetFamily) private var familia
    @Environment(\.dynamicTypeSize) private var tipo
    var entrada: EntradaTraco

    var body: some View {
        Group {
            switch familia {
            case .accessoryInline:
                Text(entrada.destaque?.linha ?? "Traço")
            case .accessoryRectangular:
                if let d = entrada.destaque {
                    // ADR 04f: na tela bloqueada o Destaque também se marca.
                    BotaoFeito(destaque: d) {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
                                .font(Tema.miudo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("DESTAQUE")
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(.secondary)
                                Text(d.linha)
                                    .font(Tema.meta.weight(.medium))
                                    .lineLimit(2)
                                    .strikethrough(d.feito)
                            }
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                } else {
                    Text(entrada.indisponivel ? "Traço · sem dados" : "Traço")
                        .font(Tema.meta.weight(.medium))
                }
            default:
                casa
            }
        }
        .containerBackground(Tema.fundo, for: .widget)
    }

    private var regua: some View {
        Rectangle().fill(Tema.linha).frame(height: 0.5).padding(.vertical, 10)
    }

    /// No pequeno, a linha do Destaque (ou o "sem dados") ocupa o lugar do
    /// segundo atalho: o widget existe para mostrar a única coisa de hoje
    /// INTEIRA, e "Correr antes…" não a mostrava (A3 do G3). Recordar segue
    /// no médio e no app.
    private var soNovaNota: Bool {
        familia == .systemSmall && (entrada.indisponivel || entrada.destaque != nil)
    }

    /// Em tamanho de acessibilidade o pequeno não cabe linha, atalho e
    /// rodapé: fica só a única coisa de hoje, em até três linhas (visto no
    /// Air em AX5: "Correr a…" e "atualizado às 0…"). O médio segue inteiro.
    private var soALinha: Bool { soNovaNota && tipo.isAccessibilitySize }

    private var casa: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TRAÇO")
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
            Spacer(minLength: 8)
            if entrada.indisponivel {
                // App Group indisponível ou arquivo corrompido: dito, nunca fingido
                Text("sem dados · abra o Traço")
                    .font(Tema.meta.weight(.medium))
                    .foregroundStyle(Tema.tintaFraca)
                    .lineLimit(soALinha ? 3 : 2)
                if !soALinha { regua }
            } else if let d = entrada.destaque {
                // F2: a única coisa de hoje, e um toque que a fecha sem abrir
                // o app. Não é streak nem contagem — vale só para hoje.
                BotaoFeito(destaque: d) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
                            .font(Tema.meta)
                            .foregroundStyle(d.feito ? Tema.tintaSuave : Tema.tintaFraca)
                        Text(d.linha)
                            .font(Tema.meta.weight(.medium))
                            .foregroundStyle(d.feito ? Tema.tintaFraca : Tema.tinta)
                            .strikethrough(d.feito, color: Tema.tintaFraca)
                            .lineLimit(soALinha ? 3 : 2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                if !soALinha { regua }
            }
            if soALinha {
                EmptyView()
            } else if soNovaNota {
                AtalhoTraco(rota: "traco://nova", rotulo: "Nova nota", destaque: true)
            } else if familia == .systemSmall {
                AtalhoTraco(rota: "traco://nova", rotulo: "Nova nota", destaque: true)
                Rectangle().fill(Tema.linha).frame(height: 0.5).padding(.vertical, 12)
                AtalhoTraco(rota: "traco://recordar", rotulo: "Recordar", destaque: false)
            } else {
                HStack(spacing: 16) {
                    AtalhoTraco(rota: "traco://nova", rotulo: "Nova nota", destaque: true)
                    Rectangle().fill(Tema.linha).frame(width: 0.5)
                    AtalhoTraco(rota: "traco://recordar", rotulo: "Recordar", destaque: false)
                }
            }
            Spacer(minLength: 0)
            if let gerado = entrada.geradoEm, !soALinha {
                RodapeAtualizado(gerado: gerado)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TracoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SuperficieDisco.kindDestaque, provider: ProvedorTraco()) { entrada in
            TracoWidgetView(entrada: entrada)
        }
        .configurationDisplayName("Traço")
        .description("O Destaque do dia na tela bloqueada. Na casa: uma página ou Recordar.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

/// O Destaque vivo: uma linha do autor, papel e tinta, enquanto o dia dura.
/// Velha (passou da meia-noite, `isStale`): a linha de ontem não fica e o
/// botão some — quem encerra é o app, ao reconciliar (ADR 05u).
struct DestaqueVivo: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DestaqueAtividade.self) { contexto in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Tema.ambar)
                        .frame(width: 6, height: 6)
                    Text("DESTAQUE")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                if contexto.isStale {
                    Text("Traço")
                        .font(Tema.corpo.weight(.medium))
                        .foregroundStyle(.secondary)
                } else {
                    // ADR 04f: a tela bloqueada deixa de ser cartaz. O círculo é o
                    // mesmo gesto do widget da casa, e o alvo é a LINHA inteira.
                    Button(intent: DestaqueFeitoIntent(nota: contexto.attributes.id, dia: contexto.attributes.dia)) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle")
                                .font(Tema.corpo.weight(.light))
                                .foregroundStyle(Tema.ambar)
                            Text(contexto.state.linha)
                                .font(Tema.corpo.weight(.medium))
                                .tracking(-0.3)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Marcar como feito: \(contexto.state.linha)")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .activitySystemActionForegroundColor(Tema.ambar)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        if !contexto.isStale {
                            Button(intent: DestaqueFeitoIntent(nota: contexto.attributes.id, dia: contexto.attributes.dia)) {
                                Image(systemName: "circle")
                                    .font(Tema.chrome.weight(.light))
                                    .foregroundStyle(Tema.ambar)
                                    .frame(width: Tema.alvo, height: Tema.alvo)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Marcar como feito: \(contexto.state.linha)")
                        }
                        Text(contexto.isStale ? "Traço" : contexto.state.linha)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "sparkle")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                Text(contexto.isStale ? "Traço" : contexto.state.linha)
                    .font(Tema.miudo.weight(.medium))
                    .lineLimit(1)
                    .frame(maxWidth: 96)
            } minimal: {
                Image(systemName: "sparkle")
                    .foregroundStyle(Tema.ambar)
            }
        }
    }
}

// MARK: - ADR 2026-09-04a: o próximo compromisso, fora do app

struct EntradaProximo: TimelineEntry {
    let date: Date
    let leitura: SuperficieDisco.Leitura

    /// Um estado só por entrada, decidido pela DATA da entrada: a mesma
    /// leitura vira "nada marcado" quando o último acaba e "desatualizado"
    /// quando o horizonte passa — sem acordar ninguém.
    var estado: Superficie.EstadoDoProximo {
        guard case .disponivel(let s) = leitura else { return .indisponivel }
        return s.estadoDoProximo(agora: date)
    }

    var geradoEm: Date? {
        guard case .disponivel(let s) = leitura else { return nil }
        return s.geradoEm
    }
}

struct ProvedorProximo: TimelineProvider {
    private func entrada(_ agora: Date = .now) -> EntradaProximo {
        EntradaProximo(date: agora, leitura: SuperficieDisco.ler())
    }
    func placeholder(in context: Context) -> EntradaProximo { entrada() }
    func getSnapshot(in context: Context, completion: @escaping (EntradaProximo) -> Void) {
        completion(entrada())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaProximo>) -> Void) {
        let agora = Date()
        let leitura = SuperficieDisco.ler()
        // as transições REAIS: cada fim (o seguinte entra, ou "nada marcado"),
        // a soneca que passa, e o horizonte (depois dele, "desatualizado").
        // Poucas entradas, nenhuma inventada, e nenhum reload por minuto.
        let entradas = Superficie.transicoes(leitura, agora: agora).map { EntradaProximo(date: $0, leitura: leitura) }
        completion(Timeline(entries: entradas, policy: .never))
    }
}

struct ProximoWidgetView: View {
    @Environment(\.widgetFamily) private var familia
    var entrada: EntradaProximo

    private func quando(_ p: Superficie.Proximo) -> String {
        Superficie.quando(p.inicio, diaInteiro: p.diaInteiro, agora: entrada.date)
    }

    /// O que a superfície diz quando não há compromisso para mostrar.
    private var ausencia: String {
        switch entrada.estado {
        case .indisponivel: "sem dados · abra o Traço"
        case .desatualizado: "desatualizado · abra o Traço"
        default: "nada marcado"
        }
    }

    var body: some View {
        Group {
            switch familia {
            case .accessoryInline:
                if case .proximo(let p) = entrada.estado {
                    Text(Superficie.linhaDoProximo(p))
                } else {
                    Text("Traço")
                }
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("PRÓXIMO")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(.secondary)
                    if case .proximo(let p) = entrada.estado {
                        Text(p.titulo)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(1)
                        Text(quando(p))
                            .font(Tema.miudo)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(ausencia)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                    }
                }
            default:
                casa
            }
        }
        .containerBackground(Tema.fundo, for: .widget)
        .widgetURL(URL(string: "traco://calendario"))
    }

    private var casa: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PRÓXIMO")
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
            Spacer(minLength: 10)
            if case .proximo(let p) = entrada.estado {
                Text(p.titulo)
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                    .lineLimit(2)
                Text(quando(p))
                    .font(Tema.miudo.weight(.medium))
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.top, 2)
                // a promessa também aqui: o autor confere o alarme sem abrir
                // o app (ADR 04a — ele tem de VER que vai ser cobrado)
                if let quando = p.lembrarEm {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.badge")
                            .font(Tema.label)
                        Text("lembro às \(Superficie.horaCurta(quando))")
                            .font(Tema.miudo.weight(.medium))
                    }
                    .foregroundStyle(Tema.ambarTinta)
                    .padding(.top, 6)
                } else if let aviso = p.aviso {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(Tema.label)
                        Text(Superficie.horaCurta(aviso))
                            .font(Tema.miudo.weight(.medium))
                    }
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.top, 6)
                }
            } else {
                Text(ausencia)
                    .font(Tema.meta.weight(.medium))
                    .foregroundStyle(Tema.tintaSuave)
            }
            Spacer(minLength: 0)
            if let gerado = entrada.geradoEm {
                RodapeAtualizado(gerado: gerado)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TracoProximoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SuperficieDisco.kindProximo, provider: ProvedorProximo()) { entrada in
            ProximoWidgetView(entrada: entrada)
        }
        .configurationDisplayName("Próximo compromisso")
        .description("O que vem a seguir, e a que horas o Traço te avisa.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

/// O compromisso vivo: enquanto ele não chega, a Ilha conta. O tempo é
/// desenhado pelo SISTEMA (`Text(style:)`), então anda sem o app acordar —
/// o único jeito honesto de uma contagem regressiva na tela bloqueada.
///
/// A contagem só aparece na ÚLTIMA HORA. Cinco horas em h:mm:ss é teatro: o
/// número muda o tempo todo e não muda nada para quem lê (e ainda estourava a
/// faixa compacta da Ilha, saindo cortado — visto no simulador, 04/set).
/// Longe, a Ilha diz a HORA; perto, ela conta.
private func contando(_ inicio: Date, agora: Date = .now) -> Bool {
    let falta = inicio.timeIntervalSince(agora)
    return falta > 0 && falta <= 3600
}

/// A cápsula da ação, uma só para o cartão e a Ilha: a assinatura do app numa
/// tela que não é do app. O fill âmbar não sobrevive ao material do sistema
/// (sai ocre sujo — visto em 04/set), então a cor vive no TRAÇO e na letra.
private struct CapsulaLembrar: View {
    let ocorrencia: String
    let naIlha: Bool

    var body: some View {
        Button(intent: LembrarDepoisIntent(ocorrencia: ocorrencia)) {
            Text("Lembrar em 10 min")
                .font(naIlha ? Tema.miudo.weight(.semibold) : Tema.acaoViva)
                .foregroundStyle(Tema.ambar)
                .padding(.horizontal, naIlha ? 14 : 18)
                // 38pt: o alvo do §15 é 44, e no cartão da tela bloqueada 38 é
                // o teto do que cabe sem empurrar o título — a área tocável
                // ganha o resto na moldura
                .frame(height: naIlha ? 32 : 38)
                .background(.quaternary, in: Capsule())
                .overlay(Capsule().strokeBorder(Tema.ambar.opacity(0.55), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Lembrar em 10 minutos")
    }
}

/// O retorno do toque (ADR 04f): a hora em que vai cobrar, a razão de não ir,
/// ou o botão. Velho (`isStale`): nada — o compromisso acabou.
private struct LinhaDaAcao: View {
    let estado: CompromissoAtividade.ContentState
    let ocorrencia: String
    let velho: Bool
    let naIlha: Bool

    var body: some View {
        if velho {
            Text("acabou")
                .font(Tema.miudo.weight(.medium))
                .foregroundStyle(.secondary)
        } else if let recado = estado.recado {
            Label(recado, systemImage: "bell.slash")
                .font(Tema.miudo.weight(.medium))
                .foregroundStyle(Tema.aviso)
        } else if let quando = estado.lembrarEm, quando > .now {
            Label("lembro às \(Superficie.horaCurta(quando))", systemImage: "bell.badge")
                .font(Tema.miudo.weight(.medium))
                .foregroundStyle(Tema.ambar)
        } else {
            CapsulaLembrar(ocorrencia: ocorrencia, naIlha: naIlha)
        }
    }
}

struct CompromissoVivo: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompromissoAtividade.self) { contexto in
            // O cartão veste a CASA pela tipografia e pelo âmbar; o material é
            // do sistema (forçar papel por baixo devolvia um cinza sujo).
            //
            // Hierarquia: o assunto é o COMPROMISSO. O relógio é metadado, não
            // manchete (`critique-visual-hierarchy`).
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Tema.ambar)
                        .frame(width: 6, height: 6)
                    Text("PRÓXIMO")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 8)
                    if !contexto.state.diaInteiro, !contexto.isStale {
                        Group {
                            if contando(contexto.state.inicio) {
                                Text(contexto.state.inicio, style: .timer)
                            } else {
                                Text(contexto.state.inicio, style: .relative)
                            }
                        }
                        .font(Tema.miudo.weight(.medium).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 92, alignment: .trailing)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(contexto.state.titulo)
                        .font(Tema.corpo.weight(.semibold))
                        .tracking(-0.4)
                        .foregroundStyle(contexto.isStale ? .secondary : .primary)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    if !contexto.state.diaInteiro {
                        Text(Superficie.horaCurta(contexto.state.inicio))
                            .font(Tema.chrome.weight(.semibold).monospacedDigit())
                            .foregroundStyle(contexto.isStale ? .secondary : .primary)
                    }
                }

                // ADR 04f: ver não é agir. Um botão, um significado — e o toque
                // VIRA texto, senão o botão é mudo (ADR 04a do tamanho do dedo).
                LinhaDaAcao(estado: contexto.state, ocorrencia: contexto.attributes.chave,
                            velho: contexto.isStale, naIlha: false)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .activitySystemActionForegroundColor(Tema.ambar)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Tema.ambar)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !contexto.state.diaInteiro, !contexto.isStale {
                        // aberta há espaço: aqui a contagem cabe inteira
                        Text(contexto.state.inicio, style: .timer)
                            .font(Tema.meta.weight(.semibold).monospacedDigit())
                            .frame(maxWidth: 76)
                            .multilineTextAlignment(.trailing)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(contexto.state.titulo)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        LinhaDaAcao(estado: contexto.state, ocorrencia: contexto.attributes.chave,
                                    velho: contexto.isStale, naIlha: true)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                if contexto.isStale {
                    Text("acabou")
                        .font(Tema.miudo.weight(.medium))
                        .frame(maxWidth: 52)
                } else if contexto.state.diaInteiro {
                    Text(contexto.state.titulo)
                        .font(Tema.miudo.weight(.medium))
                        .lineLimit(1)
                        .frame(maxWidth: 76)
                } else if contando(contexto.state.inicio) {
                    Text(contexto.state.inicio, style: .timer)
                        .font(Tema.miudo.weight(.medium).monospacedDigit())
                        .frame(maxWidth: 52)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(Superficie.horaCurta(contexto.state.inicio))
                        .font(Tema.miudo.weight(.medium).monospacedDigit())
                        .frame(maxWidth: 44)
                }
            } minimal: {
                Image(systemName: "calendar")
                    .foregroundStyle(Tema.ambar)
            }
            .widgetURL(URL(string: "traco://calendario"))
        }
    }
}

@main
struct TracoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TracoWidget()
        TracoProximoWidget()
        DestaqueVivo()
        CompromissoVivo()
    }
}

// MARK: - Previews (B5 do G3): um estado por entrada, uma família por preview.
// A prova segue sendo a captura no simulador; aqui o G4 compara famílias.

private enum Amostra {
    static let agora = Date()
    static func superficie(destaque: Superficie.Destaque? = nil, proximos: [Superficie.Proximo] = [],
                           validoAte: Date = agora.addingTimeInterval(86400)) -> SuperficieDisco.Leitura {
        .disponivel(Superficie(revisao: 7, geradoEm: agora.addingTimeInterval(-1500), validoAte: validoAte,
                               destaque: destaque, proximos: proximos))
    }
    static func destaque(feito: Bool) -> Superficie.Destaque {
        .init(id: UUID(), dia: Superficie.diaISO(agora), linha: "Correr antes do café", feito: feito)
    }
    static func proximo(lembrar: Bool = false) -> Superficie.Proximo {
        .init(titulo: "Dentista", inicio: agora.addingTimeInterval(2700), fim: agora.addingTimeInterval(6300),
              diaInteiro: false, aviso: agora.addingTimeInterval(2700),
              lembrarEm: lembrar ? agora.addingTimeInterval(600) : nil)
    }

    static var comDestaque: EntradaTraco { .init(date: agora, leitura: superficie(destaque: destaque(feito: false))) }
    static var feito: EntradaTraco { .init(date: agora, leitura: superficie(destaque: destaque(feito: true))) }
    static var vazio: EntradaTraco { .init(date: agora, leitura: superficie()) }
    static var indisponivel: EntradaTraco { .init(date: agora, leitura: .indisponivel) }

    static var comProximo: EntradaProximo { .init(date: agora, leitura: superficie(proximos: [proximo()])) }
    static var comSoneca: EntradaProximo { .init(date: agora, leitura: superficie(proximos: [proximo(lembrar: true)])) }
    static var nadaMarcado: EntradaProximo { .init(date: agora, leitura: superficie()) }
    static var desatualizado: EntradaProximo {
        .init(date: agora, leitura: superficie(proximos: [proximo()], validoAte: agora.addingTimeInterval(-60)))
    }
    static var semDados: EntradaProximo { .init(date: agora, leitura: .indisponivel) }
}

#Preview("Traço · pequeno", as: .systemSmall) {
    TracoWidget()
} timeline: {
    Amostra.comDestaque
    Amostra.feito
    Amostra.vazio
    Amostra.indisponivel
}

#Preview("Traço · médio", as: .systemMedium) {
    TracoWidget()
} timeline: {
    Amostra.comDestaque
    Amostra.feito
    Amostra.vazio
    Amostra.indisponivel
}

#Preview("Traço · bloqueada", as: .accessoryRectangular) {
    TracoWidget()
} timeline: {
    Amostra.comDestaque
    Amostra.feito
    Amostra.vazio
    Amostra.indisponivel
}

#Preview("Traço · AX5", traits: .fixedLayout(width: 170, height: 170)) {
    TracoWidgetView(entrada: Amostra.comDestaque)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Próximo · pequeno", as: .systemSmall) {
    TracoProximoWidget()
} timeline: {
    Amostra.comProximo
    Amostra.comSoneca
    Amostra.nadaMarcado
    Amostra.desatualizado
    Amostra.semDados
}

#Preview("Próximo · médio", as: .systemMedium) {
    TracoProximoWidget()
} timeline: {
    Amostra.comProximo
    Amostra.comSoneca
    Amostra.nadaMarcado
    Amostra.desatualizado
    Amostra.semDados
}

#Preview("Próximo · bloqueada", as: .accessoryRectangular) {
    TracoProximoWidget()
} timeline: {
    Amostra.comProximo
    Amostra.nadaMarcado
    Amostra.desatualizado
    Amostra.semDados
}

#Preview("Próximo · AX5", traits: .fixedLayout(width: 170, height: 170)) {
    ProximoWidgetView(entrada: Amostra.comProximo)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}
