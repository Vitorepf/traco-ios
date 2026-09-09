import SwiftUI
import ActivityKit
@main struct OutraApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Outra").task {
                for a in Activity<OutraAtividade>.activities { await a.end(nil, dismissalPolicy: .immediate) }
                _ = try? Activity.request(attributes: OutraAtividade(),
                    content: .init(state: .init(n: 1), staleDate: nil))
            }
        }
    }
}
