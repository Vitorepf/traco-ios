import Foundation
import CryptoKit

/// A entrada do Mac (ADR 2026-09-04p): a subpasta `entrada/` da pasta do
/// segundo cérebro. A leitura conserva a fonte; somente o commit confirmado
/// permite retirar a mesma versão do arquivo (ADR 05h).
///
/// É a ÚNICA subpasta que o app lê da pasta espelhada. Tudo o mais continua
/// "só escrita". E import jamais tranca: o que entra, entra aberto.
///
/// O mesmo caminho lê `metodos/` (ADR 04l) e copia para a pasta do app, que é
/// de onde o catálogo lê.
nonisolated enum Entrada {
    static let subpasta = "entrada"
    static let chaveUltima = "entradaUltima"

    nonisolated struct Item: Sendable {
        var texto: String
        var gestoNome: String?
        var criadaEm: Date
    }

    nonisolated struct Arquivo: Sendable {
        let url: URL
        let dados: Data
        let chave: String
        let itens: [Item]
        let podeRetirar: Bool
    }

    /// Inspeção sem efeitos: ler não equivale a importar.
    static func recolher(raizes: [URL]) -> [Item] {
        arquivos(raizes: raizes).flatMap(\.itens)
    }

    static func arquivos(raizes: [URL]) -> [Arquivo] {
        let fm = FileManager.default
        var saida: [Arquivo] = []
        var vistas = Set<String>()
        for raiz in raizes {
            let pasta = raiz.appendingPathComponent(subpasta, isDirectory: true)
            guard let nomes = try? fm.contentsOfDirectory(atPath: pasta.path) else { continue }
            for nome in nomes.sorted() where nome.hasSuffix(".md") || nome.hasSuffix(".txt") {
                let url = pasta.appendingPathComponent(nome).standardizedFileURL
                // Uma entrada não ganha autoridade sobre o destino de um link.
                guard let atributos = try? fm.attributesOfItem(atPath: url.path),
                      atributos[.type] as? FileAttributeType == .typeRegular else { continue }
                guard let dados = try? Data(contentsOf: url),
                      let conteudo = String(data: dados, encoding: .utf8) else { continue }
                let resultado = Corpus.importarComEstado(conteudo)
                let itens = resultado.itens.map { Item(texto: $0.texto, gestoNome: $0.gestoNome, criadaEm: $0.criadaEm) }
                guard !itens.isEmpty else { continue }
                var identidade = Data(url.path.utf8)
                identidade.append(0)
                identidade.append(dados)
                let chave = SHA256.hash(data: identidade).map { String(format: "%02x", $0) }.joined()
                guard vistas.insert(chave).inserted else { continue }
                saida.append(Arquivo(url: url, dados: dados, chave: chave, itens: itens, podeRetirar: !resultado.contemProtegida))
            }
        }
        return saida
    }

    /// Chamar apenas depois de persistir notas e recibo na mesma transação.
    /// Se outro editor já mudou o arquivo, ele será uma nova entrada.
    @discardableResult
    static func confirmar(_ arquivo: Arquivo) -> Bool {
        guard arquivo.podeRetirar else { return false }
        var removido = false
        var erro: NSError?
        NSFileCoordinator().coordinate(writingItemAt: arquivo.url, options: .forDeleting, error: &erro) { url in
            guard let atuais = try? Data(contentsOf: url), atuais == arquivo.dados else { return }
            do {
                try FileManager.default.removeItem(at: url)
                removido = true
            } catch { /* O recibo evita duplicar na próxima coleta. */ }
        }
        return removido
    }

    /// ADR 05a: deposita uma frase em `entrada/` da raiz dada, com a hora —
    /// o intent e a rota `traco://anotar` entram por aqui, como o Mac.
    @discardableResult
    static func depositar(_ texto: String, raiz: URL, agora: Date = .now) -> Bool {
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty else { return false }
        let pasta = raiz.appendingPathComponent(subpasta, isDirectory: true)
        try? FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
        let quando = ISO8601DateFormatter().string(from: agora)
        let conteudo = "---\ncriada: \(quando)\n---\n\n\(limpo)\n"
        let url = pasta.appendingPathComponent("anotar-\(UUID().uuidString).md")
        return (try? conteudo.write(to: url, atomically: true, encoding: .utf8)) != nil
    }

    /// A raiz do app: `Documents/Traço`.
    @MainActor static var raizDoApp: URL {
        Corpus.diretorio.appendingPathComponent("Traço", isDirectory: true)
    }

    /// Copia `metodos/*.json` da pasta do autor para a pasta do app.
    /// Devolve quantos arquivos mudaram.
    @discardableResult
    static func recolherMetodos(raizes: [URL], destino: URL = Catalogo.pastaDoAutor) -> Int {
        let fm = FileManager.default
        var mudou = 0
        for raiz in raizes {
            let pasta = raiz.appendingPathComponent("metodos", isDirectory: true)
            guard pasta != destino, let nomes = try? fm.contentsOfDirectory(atPath: pasta.path) else { continue }
            for nome in nomes where nome.hasSuffix(".json") {
                guard let dados = try? Data(contentsOf: pasta.appendingPathComponent(nome)) else { continue }
                let alvo = destino.appendingPathComponent(nome)
                if let atual = try? Data(contentsOf: alvo), atual == dados { continue }
                try? fm.createDirectory(at: destino, withIntermediateDirectories: true)
                if (try? dados.write(to: alvo, options: .atomic)) != nil { mudou += 1 }
            }
        }
        return mudou
    }

    /// A última vez que algo entrou, para o Perfil.
    static var ultimaEmPalavras: String {
        guard let d = UserDefaults.standard.object(forKey: chaveUltima) as? Date else {
            return "nada entrou por aqui ainda."
        }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "d 'de' MMMM, HH:mm"
        return "última entrada: \(f.string(from: d))."
    }
}
