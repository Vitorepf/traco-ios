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

    /// O teclado está de pé AGORA. O reconhecedor que o fecha só olha o toque
    /// quando isto é verdade: dois reconhecedores só correm juntos se AMBOS os
    /// lados deixarem, e os do SwiftUI não deixam — então, sem teclado, não se
    /// disputa o toque do app à toa.
    /// ponytail: não foi isto que matou a busca das Notas em 17/09 (era o gesto
    /// da borda nos fluxos, que o iOS intercepta); é guarda por princípio, e
    /// barata.
    nonisolated(unsafe) static var abertoAgora = false

    /// Liga as notificações do sistema que dizem quando o teclado sobe e desce.
    /// Idempotente: chamar duas vezes não observa duas.
    static func observarTeclado() {
        guard !observando else { return }
        observando = true
        let centro = NotificationCenter.default
        centro.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            abertoAgora = true
        }
        centro.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            abertoAgora = false
        }
    }

    private static var observando = false

    /// Dono, 17/09: «ao marcar um compromisso o teclado não fecha». O campo do pé
    /// é multilinha e o Enter envia; a ficha do compromisso tem Notas multilinha —
    /// sem enviar, nada fechava o teclado. Um toque fora de um campo de texto, em
    /// qualquer tela, fecha; o toque segue para quem o recebeu.
    static func instalarToqueQueFecha() {
        let janelas = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
        observarTeclado()
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
        // sem teclado de pé não há o que fechar — e disputar o toque com o app
        // matava o campo do pé das Notas (17/09, visto na tela)
        guard Teclado.abertoAgora, !Teclado.paginaEmFoco else { return false }
        // dentro do campo do pé (o «x», o enviar, o texto) o teclado fica
        if Teclado.campoDoPeAtivo,
           Teclado.quadroDoCampoDoPe.insetBy(dx: -8, dy: -8).contains(touch.location(in: nil)) { return false }
        // A cadeia de cima não basta sempre: no SwiftUI o campo pode ser IRMÃO
        // da vista que recebe o toque (uma camada por cima dele), e subir por
        // `superview` não o encontra. Quem manda é o PONTO: se há campo de
        // texto debaixo dele, o toque é do campo. (17/09: guarda por princípio
        // — a busca morta dos fluxos era o gesto da borda, não isto.)
        var vista = touch.view
        while let atual = vista {
            if atual is UITextView || atual is UITextField { return false }
            vista = atual.superview
        }
        let ponto = touch.location(in: nil)
        if let janela = touch.window, Self.temCampoDeTexto(em: ponto, dentro: janela) { return false }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }

    /// Há um campo de texto desenhado sob este ponto? Percorre a árvore da
    /// janela, não a cadeia de ancestrais: o campo do SwiftUI fica sob uma
    /// camada que recebe o toque no lugar dele.
    /// ponytail: varredura por toque; a árvore de uma tela do Traço tem
    /// centenas de vistas, não milhares.
    static func temCampoDeTexto(em ponto: CGPoint, dentro raiz: UIView) -> Bool {
        for vista in raiz.subviews {
            guard !vista.isHidden, vista.alpha > 0.01 else { continue }
            if vista is UITextField || vista is UITextView,
               vista.isUserInteractionEnabled,
               vista.convert(vista.bounds, to: nil).contains(ponto) { return true }
            if temCampoDeTexto(em: ponto, dentro: vista) { return true }
        }
        return false
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
