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

    /// O piano completo (motion 6): seleção para chips/régua, suave para a
    /// análise "perceber" o autor, firme para fechos físicos.
    static func selecao() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func suave() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func firme() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
