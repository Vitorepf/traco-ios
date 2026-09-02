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

/// Um alvo de toque do widget: ícone + rótulo, área inteira tocável, abre a rota.
private struct AtalhoTraco: View {
    let rota: String
    let simbolo: String
    let rotulo: String
    let destaque: Bool

    var body: some View {
        Link(destination: URL(string: rota)!) {
            HStack(spacing: 10) {
                Image(systemName: simbolo)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(destaque ? Tema.ambar : Tema.tintaSuave)
                    .frame(width: 22)
                Text(rotulo)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Tema.tinta)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
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
                Text(entrada.destaque ?? "Traço")
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    Text("DESTAQUE")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                    Text(entrada.destaque ?? "—")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(2)
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
                AtalhoTraco(rota: "traco://nova", simbolo: "square.and.pencil",
                            rotulo: "Nova nota", destaque: true)
                Rectangle().fill(Tema.linha).frame(height: 0.5).padding(.vertical, 12)
                AtalhoTraco(rota: "traco://recordar", simbolo: "arrow.counterclockwise",
                            rotulo: "Recordar", destaque: false)
            } else {
                HStack(spacing: 16) {
                    AtalhoTraco(rota: "traco://nova", simbolo: "square.and.pencil",
                                rotulo: "Nova nota", destaque: true)
                    Rectangle().fill(Tema.linha).frame(width: 0.5)
                    AtalhoTraco(rota: "traco://recordar", simbolo: "arrow.counterclockwise",
                                rotulo: "Recordar", destaque: false)
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

@main
struct TracoWidgetBundle: WidgetBundle {
    var body: some Widget { TracoWidget() }
}
