import UIKit

enum Teclado {
    static func recolher() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

enum Toque {
    static func leve() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func aviso() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func fechou() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
