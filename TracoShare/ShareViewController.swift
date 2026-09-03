import UIKit
import UniformTypeIdentifiers

/// U1 — a porta de fora: texto compartilhado noutro app vira nota no Traço.
/// A extensão é só o carteiro — sem tela própria, sem prosa, sem toque na
/// nota de ninguém: colhe o texto, abre traco://criar?texto=… e some. A nota
/// nasce NOVA e destrancada do lado do app (regra 2: trancada nunca entra).
final class ShareViewController: UIViewController {
    private var processou = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !processou else { return }
        processou = true
        colher()
    }

    private func colher() {
        let provedores = (extensionContext?.inputItems as? [NSExtensionItem])?
            .compactMap(\.attachments).flatMap { $0 } ?? []
        guard let provedor = provedores.first(where: {
            $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
        }) else {
            encerrar(abrindo: nil)
            return
        }
        Task { [weak self] in
            let texto = await Self.texto(de: provedor)
            self?.encerrar(abrindo: texto)
        }
    }

    /// loadItem entrega numa fila própria; a chamada por handler é SÍNCRONA, então
    /// o provedor (não-Sendable) nunca cruza o ator — só a String (Sendable) volta
    /// pelo continuation. A versão `async` do loadItem mandaria o provedor pro
    /// executor global (data race sob concorrência estrita).
    private static func texto(de provedor: NSItemProvider) async -> String? {
        await withCheckedContinuation { cont in
            provedor.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                cont.resume(returning: (item as? String)
                    ?? (item as? NSAttributedString)?.string
                    ?? (item as? Data).flatMap { String(data: $0, encoding: .utf8) })
            }
        }
    }

    private func encerrar(abrindo texto: String?) {
        if let texto, !texto.isEmpty {
            var partes = URLComponents()
            partes.scheme = "traco"
            partes.host = "criar"
            partes.queryItems = [URLQueryItem(name: "texto", value: texto)]
            if let url = partes.url { abrirNoApp(url) }
        }
        // um respiro antes de fechar: derrubar o processo no meio do open engole o toque
        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            self?.extensionContext?.completeRequest(returningItems: nil)
        }
    }

    /// Extensão não tem UIApplication.shared: sobe a cadeia de responders e
    /// pede `openURL:` a quem souber — o jeito que os apps de nota fazem.
    private func abrirNoApp(_ url: URL) {
        let seletor = sel_registerName("openURL:")
        var alvo: UIResponder? = self
        while let r = alvo {
            if r.responds(to: seletor) {
                _ = r.perform(seletor, with: url)
                return
            }
            alvo = r.next
        }
    }
}
