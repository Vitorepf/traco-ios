import UIKit

/// A invariante da escrita visível (ADR 08f, V12-E): em cada quadro em que a
/// Página recebe escrita, a linha ativa inteira e o caret pertencem à área
/// livre do papel. A ÁREA quem concede é o contêiner (`CadernoView.body`: o
/// papel e o encaixe são irmãos de uma pilha, sem pixel em comum). Isto faz a
/// outra metade: o papel ROLA DE VERDADE até o caret ficar dentro dela. O
/// `TextEditor` da página cresce dentro do `ScrollView` e não rola sozinho, e o
/// `ScrollView` de fora não segue caret (medido na V12-D); sem isto o autor
/// escrevia às cegas a partir da linha em que o texto passa da altura do papel
/// (G4 final da V12, A2: 0 pixels de caret em 11 amostras).
enum EscritaVisivel {
    /// Chamado pelo Caderno quando o texto, o foco ou a altura do papel mudam.
    /// Só enquanto a Página recebe escrita: com o teclado recolhido o autor
    /// pode estar a reler qualquer parte, e o caret não manda. `folga` é o
    /// espaço entre linhas, para a linha inteira — não só o caret — caber.
    static func seguirCaret(folga: CGFloat) {
        // aqui o layout do SwiftUI ainda não assentou (a linha nova ainda não
        // cresceu o conteúdo do ScrollView); na volta seguinte do runloop sim.
        // Pelo RunLoop, não pela fila principal do GCD: um runloop aninhado (o
        // `RunLoop.main.run(until:)` de um teste hospedado) não esvazia a fila,
        // e o seguidor só correria depois de o teste acabar.
        RunLoop.main.perform { MainActor.assumeIsolated {
            guard let janela = janelaChave(), let editor = editorFocado(em: janela),
                  let papel = rolagemAcima(de: editor),
                  let fim = editor.selectedTextRange?.end else { return }
            janela.layoutIfNeeded()
            // `bounds` de um UIScrollView é o que está à vista, em coordenadas do
            // conteúdo; o ScrollView do SwiftUI ignora `scrollRectToVisible`, e
            // o offset é posto à mão, o mínimo que traz a linha para dentro
            let vista = papel.bounds.inset(by: papel.adjustedContentInset)
            let crua = papel.convert(linhaDoCaret(editor, em: fim), from: editor)
            // A folga é o que se pede DEPOIS da linha, e é ela que cede quando
            // o papel é curto: no 17e em AX XXXL o papel tem 87 pt para uma
            // linha de 66 e uma folga de 25, e pedir a folga inteira empurrava
            // 5 pt de letra para debaixo do encaixe. Quem tem de caber é a
            // LINHA; a folga leva o que sobrar, metade de cada lado (ADR 08w).
            let podeFolga = max(0, (vista.height - crua.height) / 2)
            let linha = crua.insetBy(dx: 0, dy: -min(folga, podeFolga))
            var y = papel.contentOffset.y
            if linha.maxY > vista.maxY { y += linha.maxY - vista.maxY }
            else if linha.minY < vista.minY { y -= vista.minY - linha.minY }
            let teto = max(-papel.adjustedContentInset.top,
                           papel.contentSize.height - papel.bounds.height + papel.adjustedContentInset.bottom)
            y = min(max(y, -papel.adjustedContentInset.top), teto)
            if abs(y - papel.contentOffset.y) > 0.5 {
                papel.setContentOffset(CGPoint(x: papel.contentOffset.x, y: y), animated: false)
            }
        } }
    }

    /// A linha VISUAL em que o caret está: o retângulo do caret unido ao
    /// fragmento de linha do TextKit 2. É ela que a invariante 08f manda caber
    /// no papel, e ela é mais alta que o caret — a entrelinha fica por cima.
    /// No iPhone 17e em AX XXXL são 67 pt de linha para 45 de caret, e seguir
    /// só o caret deixava 22 pt de letra acima da borda do papel, no meio da
    /// nota, onde a rolagem tinha para onde ir (ADR 08w).
    /// Medido aqui de novo, e não lido do teste: o instrumento mede sozinho,
    /// senão a prova passa a citar o código que devia julgar.
    static func linhaDoCaret(_ tv: UITextView, em fim: UITextPosition) -> CGRect {
        var linha = tv.caretRect(for: fim)
        guard let tlm = tv.textLayoutManager, let tcm = tlm.textContentManager else { return linha }
        let offset = tv.offset(from: tv.beginningOfDocument, to: fim)
        guard let loc = tcm.location(tcm.documentRange.location, offsetBy: offset) else { return linha }
        tlm.ensureLayout(for: NSTextRange(location: loc))
        guard let frag = tlm.textLayoutFragment(for: loc) else { return linha }
        let dentro = offset - tcm.offset(from: tcm.documentRange.location, to: frag.rangeInElement.location)
        let linhas = frag.textLineFragments
        for (i, lf) in linhas.enumerated()
        where NSLocationInRange(dentro, lf.characterRange) || (i == linhas.count - 1 && dentro == NSMaxRange(lf.characterRange)) {
            linha = linha.union(lf.typographicBounds
                .offsetBy(dx: frag.layoutFragmentFrame.minX + tv.textContainerInset.left,
                          dy: frag.layoutFragmentFrame.minY + tv.textContainerInset.top))
        }
        return linha
    }

    static func janelaChave() -> UIWindow? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows).first { $0.isKeyWindow }
    }

    static func editorFocado(em raiz: UIView) -> UITextView? {
        if let tv = raiz as? UITextView, tv.isFirstResponder { return tv }
        for sub in raiz.subviews { if let tv = editorFocado(em: sub) { return tv } }
        return nil
    }

    /// O `UITextView` é ele mesmo um `UIScrollView`: o papel é o de cima.
    static func rolagemAcima(de v: UIView) -> UIScrollView? {
        var atual = v.superview
        while let a = atual { if let s = a as? UIScrollView { return s }; atual = a.superview }
        return nil
    }
}
