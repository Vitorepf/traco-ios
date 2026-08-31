import SwiftData
import SwiftUI

@main
struct TracoApp: App {
    var body: some Scene {
        WindowGroup {
            PaginaView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Nota.self)
    }
}