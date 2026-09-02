import Foundation

/// A pasta do autor onde o segundo cérebro também é gravado (ADR 2026-09-02n):
/// iCloud Drive, ou qualquer provedor do app Arquivos. Escolhida pelo seletor
/// do sistema, guardada como bookmark com escopo de segurança. O Traço só
/// escreve nela; nunca lê de volta, nunca sincroniza.
nonisolated enum PastaEspelho {
    static let chave = "pasta-espelho-bookmark"
    static let chaveNome = "pasta-espelho-nome"
    nonisolated(unsafe) static var defaults: UserDefaults = .standard

    /// Guarda o bookmark. A URL do seletor vem com escopo: abre-se para criar o bookmark.
    @discardableResult
    static func guardar(_ url: URL) -> Bool {
        let acesso = url.startAccessingSecurityScopedResource()
        defer { if acesso { url.stopAccessingSecurityScopedResource() } }
        guard let dados = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) else {
            return false
        }
        defaults.set(dados, forKey: chave)
        defaults.set(url.lastPathComponent, forKey: chaveNome)
        return true
    }

    static var nome: String? {
        guard defaults.data(forKey: chave) != nil else { return nil }
        return defaults.string(forKey: chaveNome)
    }

    static func limpar() {
        defaults.removeObject(forKey: chave)
        defaults.removeObject(forKey: chaveNome)
    }

    /// Resolve o bookmark e abre o acesso só durante `corpo`. Bookmark morto
    /// (pasta apagada, provedor removido) some sozinho: melhor nenhum espelho
    /// que um espelho que finge gravar.
    static func comAcesso(_ corpo: (URL) -> Void) {
        guard let dados = defaults.data(forKey: chave) else { return }
        var velho = false
        guard let url = try? URL(resolvingBookmarkData: dados, options: [], relativeTo: nil, bookmarkDataIsStale: &velho) else {
            limpar()
            return
        }
        if velho, let novo = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
            defaults.set(novo, forKey: chave)
        }
        let acesso = url.startAccessingSecurityScopedResource()
        defer { if acesso { url.stopAccessingSecurityScopedResource() } }
        let raiz = url.appendingPathComponent("Traço", isDirectory: true)
        corpo(raiz)
    }
}
