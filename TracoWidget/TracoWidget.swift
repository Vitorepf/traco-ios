import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

struct EntradaTraco: TimelineEntry {
    let date: Date
    let destaque: String?
    var feito: Bool = false
}

struct ProvedorTraco: TimelineProvider {
    func placeholder(in context: Context) -> EntradaTraco {
        EntradaTraco(date: .now, destaque: DestaqueDoDia.linhaDeHoje(), feito: DestaqueDoDia.feitoHoje())
    }
    func getSnapshot(in context: Context, completion: @escaping (EntradaTraco) -> Void) {
        completion(EntradaTraco(date: .now, destaque: DestaqueDoDia.linhaDeHoje(), feito: DestaqueDoDia.feitoHoje()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaTraco>) -> Void) {
        let entrada = EntradaTraco(date: .now, destaque: DestaqueDoDia.linhaDeHoje(), feito: DestaqueDoDia.feitoHoje())
        let amanha = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        completion(Timeline(entries: [entrada], policy: .after(amanha)))
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
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(destaque ? Tema.ambarTinta : Tema.tinta)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(rotulo)
    }
}

struct TracoWidgetView: View {
    @Environment(\.widgetFamily) private var familia
    var entrada: EntradaTraco

    var body: some View {
        Group {
            switch familia {
            case .accessoryInline:
                Text(DestaqueDoDia.naTelaBloqueada())
            case .accessoryRectangular:
                if let linha = entrada.destaque {
                    // ADR 04f: na tela bloqueada o Destaque também se marca.
                    // Era só cartaz aqui e botão na casa — a mesma coisa com
                    // duas leis diferentes é o que confunde o dedo.
                    Button(intent: DestaqueFeitoIntent()) {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: entrada.feito ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("DESTAQUE")
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(1.2)
                                    .foregroundStyle(.secondary)
                                Text(linha)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(2)
                                    .strikethrough(entrada.feito)
                            }
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(entrada.feito ? "Feito: \(linha)" : linha)
                    .accessibilityHint("Marca a única coisa de hoje como feita")
                } else {
                    Text(DestaqueDoDia.naTelaBloqueada())
                        .font(.system(size: 14, weight: .medium))
                }
            default:
                casa
            }
        }
        .containerBackground(Tema.fundo, for: .widget)
    }

    private var casa: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TRAÇO")
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(Tema.tintaFraca)
            Spacer(minLength: 12)
            if let linha = entrada.destaque {
                // F2: a única coisa de hoje, e um toque que a fecha sem abrir
                // o app. Não é streak nem contagem — vale só para hoje.
                Button(intent: DestaqueFeitoIntent()) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: entrada.feito ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundStyle(entrada.feito ? Tema.tintaSuave : Tema.tintaFraca)
                        Text(linha)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(entrada.feito ? Tema.tintaFraca : Tema.tinta)
                            .strikethrough(entrada.feito, color: Tema.tintaFraca)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(entrada.feito ? "Feito: \(linha)" : linha)
                .accessibilityHint("Marca a única coisa de hoje como feita")
                Rectangle().fill(Tema.linha).frame(height: 0.5).padding(.vertical, 10)
            }
            if familia == .systemSmall {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TracoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TracoWidget", provider: ProvedorTraco()) { entrada in
            TracoWidgetView(entrada: entrada)
        }
        .configurationDisplayName("Traço")
        .description("O Destaque do dia na tela bloqueada. Na casa: uma página ou Recordar.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

/// O Destaque vivo: uma linha do autor, papel e tinta, enquanto o dia dura.
struct DestaqueVivo: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DestaqueAtividade.self) { contexto in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Tema.ambar)
                        .frame(width: 6, height: 6)
                    Text("DESTAQUE")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                // ADR 04f: a tela bloqueada deixa de ser cartaz. O círculo é o
                // mesmo gesto do widget da casa, e o alvo é a LINHA inteira.
                Button(intent: DestaqueFeitoIntent()) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle")
                            .font(.system(size: 21, weight: .light))
                            .foregroundStyle(Tema.ambar)
                        // velha (passou da meia-noite): a linha de ontem não fica
                        Text(contexto.isStale ? "Traço" : contexto.state.linha)
                            .font(.system(size: 19, weight: .medium))
                            .tracking(-0.3)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Marcar como feito")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .activitySystemActionForegroundColor(Tema.ambar)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        Button(intent: DestaqueFeitoIntent()) {
                            Image(systemName: "circle")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(Tema.ambar)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Marcar como feito")
                        Text(contexto.state.linha)
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(2)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "sparkle")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                Text(contexto.state.linha)
                    .font(.system(size: 12, weight: .medium))
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
    let proximo: ProximoCompromisso.Fatia?
}

struct ProvedorProximo: TimelineProvider {
    private func entrada(_ agora: Date = .now) -> EntradaProximo {
        EntradaProximo(date: agora, proximo: ProximoCompromisso.lido(agora: agora))
    }
    func placeholder(in context: Context) -> EntradaProximo { entrada() }
    func getSnapshot(in context: Context, completion: @escaping (EntradaProximo) -> Void) {
        completion(entrada())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaProximo>) -> Void) {
        let agora = Date()
        let e = entrada(agora)
        // o widget vira sozinho quando o compromisso acaba: sem isto, o de
        // hoje de manhã ficaria na tela bloqueada a tarde inteira
        let virada = e.proximo.map { min($0.fim, $0.inicio.addingTimeInterval(60)) }
            ?? agora.addingTimeInterval(3600)
        completion(Timeline(entries: [e], policy: .after(max(virada, agora.addingTimeInterval(60)))))
    }
}

struct ProximoWidgetView: View {
    @Environment(\.widgetFamily) private var familia
    var entrada: EntradaProximo

    private var quando: String {
        guard let p = entrada.proximo else { return "" }
        let dia = ProximoCompromisso.diaEmPalavras(p.inicio, agora: entrada.date)
        return p.diaInteiro ? dia : "\(dia) às \(ProximoCompromisso.horaCurta(p.inicio))"
    }

    var body: some View {
        Group {
            switch familia {
            case .accessoryInline:
                Text(ProximoCompromisso.naTelaBloqueada(agora: entrada.date))
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("PRÓXIMO")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                    if let p = entrada.proximo {
                        Text(p.titulo)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                        Text(quando)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("nada marcado")
                            .font(.system(size: 14, weight: .medium))
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
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(Tema.tintaFraca)
            Spacer(minLength: 10)
            if let p = entrada.proximo {
                Text(p.titulo)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Tema.tinta)
                    .lineLimit(2)
                Text(quando)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.top, 2)
                // a promessa também aqui: o autor confere o alarme sem abrir
                // o app (ADR 04a — ele tem de VER que vai ser cobrado)
                if let aviso = p.aviso {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 9))
                        Text(ProximoCompromisso.horaCurta(aviso))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.top, 6)
                }
            } else {
                Text("nada marcado")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Tema.tintaSuave)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TracoProximoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TracoProximo", provider: ProvedorProximo()) { entrada in
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

private func horaDoCompromisso(_ data: Date) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "pt_BR")
    f.dateFormat = "HH:mm"
    return f.string(from: data)
}

struct CompromissoVivo: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompromissoAtividade.self) { contexto in
            // O cartão veste a CASA: papel opaco, tinta do app, e o âmbar como
            // assinatura da ação — a mesma pílula da "Nova" (§20). O cinza do
            // sistema com um chip morto não era o Traço; era um placeholder.
            //
            // Hierarquia: o assunto é o COMPROMISSO. O relógio é metadado, não
            // manchete (`critique-visual-hierarchy` — a versão anterior tinha
            // 20pt para a hora e 16 para o que importa).
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Tema.ambar)
                        .frame(width: 6, height: 6)
                    Text("PRÓXIMO")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 8)
                    if !contexto.state.diaInteiro {
                        Group {
                            if contando(contexto.state.inicio) {
                                Text(contexto.state.inicio, style: .timer)
                            } else {
                                Text(contexto.state.inicio, style: .relative)
                            }
                        }
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 92, alignment: .trailing)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(contexto.state.titulo)
                        .font(.system(size: 21, weight: .semibold))
                        .tracking(-0.4)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    if !contexto.state.diaInteiro {
                        Text(horaDoCompromisso(contexto.state.inicio))
                            .font(.system(size: 17, weight: .semibold).monospacedDigit())
                            .foregroundStyle(.primary)
                    }
                }

                // ADR 04f: ver não é agir. Um botão, um significado — e o toque
                // VIRA texto, senão o botão é mudo (ADR 04a do tamanho do dedo).
                if let recado = contexto.state.recado {
                    Label(recado, systemImage: "bell.slash")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Tema.aviso)
                } else if let quando = contexto.state.lembrarEm, quando > .now {
                    Label("lembro às \(horaDoCompromisso(quando))", systemImage: "bell.badge")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Tema.ambar)
                } else {
                    Button(intent: LembrarDepoisIntent()) {
                        // a assinatura do app numa tela que não é do app: o
                        // fill âmbar não sobrevive ao material do sistema (sai
                        // ocre sujo — visto em 04/set), então a cor vive no
                        // TRAÇO e na letra, sobre o vidro que o iOS já desenha
                        Text("Lembrar em 10 min")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Tema.ambar)
                            .padding(.horizontal, 18)
                            // 38pt: o alvo do §15 é 44, e no cartão da tela
                            // bloqueada 38 é o teto do que cabe sem empurrar o
                            // título — a área tocável ganha o resto na moldura
                            .frame(height: 38)
                            .background(.quaternary, in: Capsule())
                            .overlay(Capsule().strokeBorder(Tema.ambar.opacity(0.55), lineWidth: 1))
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Lembrar em 10 minutos")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            // o material é do SISTEMA: forçar papel por baixo dele devolvia um
            // cinza sujo. Aqui o app entra pela tipografia e pelo âmbar.
            .activitySystemActionForegroundColor(Tema.ambar)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Tema.ambar)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !contexto.state.diaInteiro {
                        // aberta há espaço: aqui a contagem cabe inteira
                        Text(contexto.state.inicio, style: .timer)
                            .font(.system(size: 15, weight: .semibold).monospacedDigit())
                            .frame(maxWidth: 76)
                            .multilineTextAlignment(.trailing)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(contexto.state.titulo)
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let recado = contexto.state.recado {
                            Label(recado, systemImage: "bell.slash")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Tema.aviso)
                        } else if let quando = contexto.state.lembrarEm, quando > .now {
                            Label("lembro às \(horaDoCompromisso(quando))", systemImage: "bell.badge")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Tema.ambar)
                        } else {
                            Button(intent: LembrarDepoisIntent()) {
                                // a Ilha veste a mesma roupa do cartão: acento
                                // âmbar no contorno e na letra, material do
                                // sistema por baixo
                                Text("Lembrar em 10 min")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Tema.ambar)
                                    .padding(.horizontal, 14)
                                    .frame(height: 32)
                                    .background(.quaternary, in: Capsule())
                                    .overlay(Capsule().strokeBorder(Tema.ambar.opacity(0.55), lineWidth: 1))
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                if contexto.state.diaInteiro {
                    Text(contexto.state.titulo)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                        .frame(maxWidth: 76)
                } else if contando(contexto.state.inicio) {
                    Text(contexto.state.inicio, style: .timer)
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .frame(maxWidth: 52)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(horaDoCompromisso(contexto.state.inicio))
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
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
