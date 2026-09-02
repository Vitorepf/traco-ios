import SwiftUI
import UIKit

/// Look Up do iOS: a definição do sistema, não a nossa. A palavra é do autor.
struct DicionarioNativo: UIViewControllerRepresentable {
    let termo: String

    func makeUIViewController(context: Context) -> UIReferenceLibraryViewController {
        UIReferenceLibraryViewController(term: termo)
    }

    func updateUIViewController(_ vc: UIReferenceLibraryViewController, context: Context) {}

    static func temDefinicao(_ termo: String) -> Bool {
        UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: termo)
    }
}
