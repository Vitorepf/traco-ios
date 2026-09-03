import ActivityKit
import WidgetKit
import SwiftUI

struct EntradaTraco: TimelineEntry {
    let date: Date
    let destaque: String?
}

struct ProvedorTraco: TimelineProvider {
    func placeholder(in context: Context) -> EntradaTraco {
        EntradaTraco(date: .now, destaque: DestaqueDoDia.linhaDeHoje())
    }
    func getSnapshot(in context: Context, completion: @escaping (EntradaTraco) -> Void) {
        completion(EntradaTraco(date: .now, destaque: DestaqueDoDia.linhaDeHoje()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaTraco>) -> Void) {
        let entrada = EntradaTraco(date: .now, destaque: DestaqueDoDia.linhaDeHoje())
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
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DESTAQUE")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                        Text(linha)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(2)
                    }
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
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("DESTAQUE")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(Tema.tintaSuave)
                // velha (passou da meia-noite): a linha de ontem não fica na tela
                Text(contexto.isStale ? "Traço" : contexto.state.linha)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Tema.tinta)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .padding(16)
            .activityBackgroundTint(Tema.fundo)
            .activitySystemActionForegroundColor(Tema.tinta)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    Text(contexto.state.linha)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(2)
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

@main
struct TracoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TracoWidget()
        DestaqueVivo()
    }
}
