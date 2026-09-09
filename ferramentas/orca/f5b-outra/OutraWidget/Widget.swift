import WidgetKit
import SwiftUI
@main struct OutraBundle: WidgetBundle { var body: some Widget { OutraViva() } }
struct OutraViva: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OutraAtividade.self) { _ in
            Text("Outra atividade").padding()
        } dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) { Text("Outra") }
            } compactLeading: { Image(systemName: "timer").foregroundStyle(.blue) }
              compactTrailing: { Text("outra") }
              minimal: { Image(systemName: "timer").foregroundStyle(.blue) }
        }
    }
}
