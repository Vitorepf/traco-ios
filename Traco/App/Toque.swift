import UIKit

enum Teclado {
    static func recolher() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// O papel da página tem o foco: aí tocar fora do texto é mover o cursor, e o
    /// teclado fica. Em qualquer outro lugar um toque fora de um campo o fecha.
    static var paginaEmFoco = false
    /// O campo do pé (`CampoFlutuante`) tem o foco agora, e onde ele está na tela:
    /// o «x» e o enviar dele não fecham o teclado.
    static var campoDoPeAtivo = false
    static var quadroDoCampoDoPe: CGRect = .zero

    /// Dono, 17/09: «ao marcar um compromisso o teclado não fecha». O campo do pé
    /// é multilinha e o Enter envia; a ficha do compromisso tem Notas multilinha —
    /// sem enviar, nada fechava o teclado. Um toque fora de um campo de texto, em
    /// qualquer tela, fecha; o toque segue para quem o recebeu.
    static func instalarToqueQueFecha() {
        let janelas = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
        for janela in janelas where !(janela.gestureRecognizers ?? []).contains(where: { $0 is ToqueQueFechaOTeclado }) {
            janela.addGestureRecognizer(ToqueQueFechaOTeclado())
        }
    }
}

final class ToqueQueFechaOTeclado: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    init() {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fechar))
        cancelsTouchesInView = false
        delegate = self
    }

    @objc private func fechar() { Teclado.recolher() }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard !Teclado.paginaEmFoco else { return false }
        // dentro do campo do pé (o «x», o enviar, o texto) o teclado fica
        if Teclado.campoDoPeAtivo,
           Teclado.quadroDoCampoDoPe.insetBy(dx: -8, dy: -8).contains(touch.location(in: nil)) { return false }
        var vista = touch.view
        while let atual = vista {
            if atual is UITextView || atual is UITextField { return false }
            vista = atual.superview
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
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
