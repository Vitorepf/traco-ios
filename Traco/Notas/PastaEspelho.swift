import Foundation

/// A pasta do autor onde o segundo cérebro também é gravado (ADR 2026-09-02n):
/// iCloud Drive, ou qualquer provedor do app Arquivos. Escolhida pelo seletor
/// do sistema, guardada como bookmark com escopo de segurança. O Traço só
/// escreve nela; nunca lê de volta, nunca sincroniza.
nonisolated enum PastaEspelho {
    static let chave = "pasta-espelho-bookmark"
    static let chaveNome = "pasta-espelho-nome"
    /// ADR 05s: a linha honesta do Perfil quando a cópia não chegou à pasta.
    /// Nil = a última gravação chegou (ou nunca houve pasta).
    static let chaveEstado = "pasta-espelho-estado"
    nonisolated(unsafe) static var defaults: UserDefaults = .standard

    static var estado: String? { defaults.string(forKey: chaveEstado) }

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
        defaults.removeObject(forKey: chaveEstado)
        return true
    }

    static var nome: String? {
        guard defaults.data(forKey: chave) != nil else { return nil }
        return defaults.string(forKey: chaveNome)
    }

    /// Este aparelho, para o manifesto do espelho: dois iPhones na mesma
    /// pasta não apagam as notas um do outro.
    static var aparelho: String {
        if let id = defaults.string(forKey: "aparelho-id") { return id }
        let novo = String(UUID().uuidString.prefix(8)).lowercased()
        defaults.set(novo, forKey: "aparelho-id")
        return novo
    }

    /// Parar de espelhar TIRA a cópia: apagar no app apaga de verdade, e uma
    /// pasta que ninguém mais atualiza mentiria. Só o que este aparelho escreveu.
    ///
    /// A ESCOLHA só sai quando a varredura de fato correu. Com o iCloud fora
    /// ou o volume ausente, `comAcesso` não roda `corpo` — e apagar o bookmark
    /// ali deixava o caderno inteiro na nuvem sem chave para voltar a limpá-lo,
    /// com o Perfil dizendo "Espelhar numa pasta" (auditoria 17/09). Nesse caso
    /// a pasta continua registrada e `chaveEstado` diz por quê.
    static func limpar() {
        guard comAcesso({ raiz in
            let fm = FileManager.default
            let manifesto = raiz.appendingPathComponent(".espelho-\(aparelho).json")
            let meus: Set<String> = (try? Data(contentsOf: manifesto))
                .flatMap { try? JSONDecoder().decode(Set<String>.self, from: $0) } ?? []
            let notas = raiz.appendingPathComponent("notas", isDirectory: true)
            for nome in meus { try? fm.removeItem(at: notas.appendingPathComponent(nome)) }
            try? fm.removeItem(at: manifesto)
            // `calendario.json` está nesta lista porque `Corpus.escrever`
            // também o grava na raiz do espelho (decisão A4: "os compromissos
            // vão junto"). Sem ele, «Parar de espelhar» deixava a agenda do
            // autor — título, data e o campo livre de cada compromisso — na
            // pasta do iCloud, e a raiz nunca ficava vazia, então a pasta
            // `Traço/` também ficava à vista (auditoria 17/09).
            for solto in ["LEIA-ME.md", "INDICE.md", "traco-corpus.md", "agenda.md", "calendario.json"] {
                try? fm.removeItem(at: raiz.appendingPathComponent(solto))
            }
            if let resto = try? fm.contentsOfDirectory(atPath: notas.path), resto.isEmpty { try? fm.removeItem(at: notas) }
            if let resto = try? fm.contentsOfDirectory(atPath: raiz.path), resto.isEmpty { try? fm.removeItem(at: raiz) }
        }) else { return }
        defaults.removeObject(forKey: chave)
        defaults.removeObject(forKey: chaveNome)
        defaults.removeObject(forKey: chaveEstado)
    }

    /// Resolve o bookmark e abre o acesso só durante `corpo`. Bookmark morto
    /// (pasta apagada, provedor removido) some sozinho: melhor nenhum espelho
    /// que um espelho que finge gravar — e o Perfil diz que sumiu (ADR 05s).
    /// Pasta que resolve mas não recebe escrita (iCloud fora, volume ausente)
    /// não roda `corpo`: a cópia fica só no aparelho, e a linha diz isso.
    /// Devolve se `corpo` correu: quem limpa precisa saber se alcançou a pasta.
    @discardableResult
    static func comAcesso(_ corpo: (URL) -> Void) -> Bool {
        guard let dados = defaults.data(forKey: chave) else { return false }
        let nome = defaults.string(forKey: chaveNome) ?? "escolhida"
        var velho = false
        guard let url = try? URL(resolvingBookmarkData: dados, options: [], relativeTo: nil, bookmarkDataIsStale: &velho) else {
            // Não há URL acessível para limpar arquivos. Retira apenas a
            // escolha inválida: limpar() tentaria resolver o mesmo bookmark.
            defaults.removeObject(forKey: chave)
            defaults.removeObject(forKey: chaveNome)
            defaults.set("a pasta “\(nome)” não existe mais; guardando só no aparelho", forKey: chaveEstado)
            return false
        }
        if velho, let novo = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
            defaults.set(novo, forKey: chave)
        }
        let acesso = url.startAccessingSecurityScopedResource()
        defer { if acesso { url.stopAccessingSecurityScopedResource() } }
        guard (try? url.checkResourceIsReachable()) == true, FileManager.default.isWritableFile(atPath: url.path) else {
            let nuvem = url.path.contains("Mobile Documents") || url.path.contains("CloudDocs")
            defaults.set(nuvem ? "iCloud indisponível; guardando só no aparelho"
                               : "a pasta “\(nome)” está indisponível; guardando só no aparelho", forKey: chaveEstado)
            return false
        }
        defaults.removeObject(forKey: chaveEstado)
        let raiz = url.appendingPathComponent("Traço", isDirectory: true)
        corpo(raiz)
        return true
    }
}
