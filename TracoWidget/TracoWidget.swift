import WidgetKit
import SwiftUI

// U4 — o Traço fora do app: um widget que é só dois atalhos. Um toque = página
// em branco (traco://nova); outro = Recordar (traco://recordar). As rotas já
// existem no app (Rota/onOpenURL); o widget só as chama. Visual da casa: cores e
// tom do Tema, nada de pele nova. Widget não anima (snapshot); Fase 4 pulada.

struct EntradaTraco: TimelineEntry { let date: Date }

struct ProvedorTraco: TimelineProvider {
    func placeholder(in context: Context) -> EntradaTraco { EntradaTraco(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (EntradaTraco) -> Void) {
        completion(EntradaTraco(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaTraco>) -> Void) {
        // atalho, não painel de dados: uma entrada, sem recarga
        completion(Timeline(entries: [EntradaTraco(date: .now)], policy: .never))
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
        .containerBackground(Tema.fundo, for: .widget)
    }
}

struct TracoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TracoWidget", provider: ProvedorTraco()) { entrada in
            TracoWidgetView(entrada: entrada)
        }
        .configurationDisplayName("Traço")
        .description("Uma página em branco ou Recordar, num toque.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct TracoWidgetBundle: WidgetBundle {
    var body: some Widget { TracoWidget() }
}
