import Foundation
import NaturalLanguage
import PDFKit

/// O índice de sentido (ADR 2026-09-04n): um vetor por nota aberta, feito no
/// aparelho pelo `NLEmbedding` de PALAVRAS em português, na média das palavras
/// de conteúdo. Sem rede, sem conta.
///
/// Medido em 04/set: o modelo de FRASES do sistema não separa nada em
/// português ("banco de dados" fica a 0,78 de "quero correr de manhã", o
/// mesmo que "treinar ao acordar"); a média das palavras separa (0,32–0,43
/// para o parecido, 0,0–0,2 para o resto). O que decide é a prova, não o
/// nome da API.
///
/// O selo corta antes: expressiva, selada e queimada nunca entram, e selar
/// tira do índice na hora. O índice não interpreta — aproxima. Quem liga
/// continua sendo o autor (ADR 03b).
nonisolated enum Indice {
    nonisolated struct Entrada: Codable, Sendable {
        var editadaEm: Date
        var vetor: [Float]
    }

    nonisolated struct Vizinha: Sendable, Equatable {
        var uuid: UUID
        var proximidade: Double
    }

    /// Uma nota, sem SwiftData: o que o índice precisa dela.
    nonisolated struct NotaLida: Sendable {
        var uuid: UUID
        var editadaEm: Date
        var voz: String
        var podeEntrar: Bool
    }

    private static let tranca = NSLock()
    private nonisolated(unsafe) static var memoria: [String: Entrada]?
    /// ADR 05s: a última geração que tocou cada nota. Uma escrita fora da main
    /// que chega depois de um selo mais novo não ressuscita a nota.
    private nonisolated(unsafe) static var geracoes: [String: Int] = [:]

    private static func avanca(_ chave: String, _ g: Int) -> Bool {
        if let atual = geracoes[chave], atual > g { return false }
        geracoes[chave] = g
        return true
    }

    /// Testes apontam para um temp.
    nonisolated(unsafe) static var url: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("indice-sentido.json")
    }()

    /// O modelo existe neste aparelho e nesta língua?
    static var disponivel: Bool { NLEmbedding.wordEmbedding(for: .portuguese) != nil }

    /// Palavras que não carregam assunto. Curta de propósito: o que não está
    /// no modelo já cai sozinho.
    nonisolated static let paragens: Set<String> = [
        "a", "o", "as", "os", "um", "uma", "uns", "umas", "de", "da", "do", "das", "dos", "em", "na", "no",
        "nas", "nos", "por", "para", "pra", "com", "sem", "ao", "à", "às", "aos", "e", "ou", "que", "se",
        "não", "nao", "é", "ser", "ter", "há", "eu", "me", "meu", "minha", "meus", "minhas", "isso", "isto",
        "este", "esta", "esse", "essa", "ele", "ela", "eles", "elas", "mais", "menos", "muito", "já", "ainda",
        "como", "quando", "onde", "mas", "todos", "todas", "todo", "toda", "hoje", "ontem", "amanhã",
        "quero", "preciso", "vou", "antes", "depois", "logo", "cedo", "tarde", "então", "assim",
    ]

    static var quantas: Int {
        tranca.lock(); defer { tranca.unlock() }
        return carregar().count
    }

    // MARK: vetores

    /// O vetor de um texto: a média das palavras de conteúdo que o modelo
    /// conhece. Nil sem modelo ou sem palavra nenhuma. Texto longo é cortado:
    /// o assunto está nas primeiras centenas de palavras.
    static func vetor(_ texto: String) -> [Float]? {
        guard let modelo = NLEmbedding.wordEmbedding(for: .portuguese) else { return nil }
        var soma = [Float](repeating: 0, count: modelo.dimension)
        var n = 0
        for pedaco in texto.lowercased().prefix(3000).split(whereSeparator: { !$0.isLetter }) {
            let palavra = String(pedaco)
            guard palavra.count >= 3, !paragens.contains(palavra), let v = modelo.vector(for: palavra) else { continue }
            for i in 0..<v.count { soma[i] += Float(v[i]) }
            n += 1
            if n >= 400 { break }
        }
        guard n > 0 else { return nil }
        return soma.map { $0 / Float(n) }
    }

    /// ADR 04y: o marcador de um PDF anexado vira o texto das três primeiras
    /// páginas dele, lido no aparelho. Só para o vetor — nunca para a nota.
    nonisolated static let marcadorPDF = try! NSRegularExpression(
        pattern: #"\[arquivo:([^\]]*\.pdf)\]\(traco://file/([0-9A-Fa-f-]{36})\)"#, options: .caseInsensitive)

    nonisolated static func expandirAnexos(_ texto: String) -> String {
        let ns = texto as NSString
        var saida = texto
        for m in marcadorPDF.matches(in: texto, range: NSRange(location: 0, length: ns.length)).reversed() {
            let nome = ns.substring(with: m.range(at: 1))
            let id = ns.substring(with: m.range(at: 2))
            let lido = textoDoPDF(AnexoDisco.url(id, nome: nome))
            saida = (saida as NSString).replacingCharacters(in: m.range, with: lido)
        }
        return saida
    }

    nonisolated static func textoDoPDF(_ url: URL, paginas: Int = 3, teto: Int = 3000) -> String {
        guard let doc = PDFDocument(url: url) else { return "" }
        var partes: [String] = []
        for i in 0..<min(paginas, doc.pageCount) {
            if let t = doc.page(at: i)?.string { partes.append(t) }
        }
        return String(partes.joined(separator: "\n").prefix(teto))
    }

    nonisolated static func cosseno(_ a: [Float], _ b: [Float]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var s: Float = 0, na: Float = 0, nb: Float = 0
        for i in 0..<a.count {
            s += a[i] * b[i]
            na += a[i] * a[i]
            nb += b[i] * b[i]
        }
        guard na > 0, nb > 0 else { return 0 }
        return Double(s / (na.squareRoot() * nb.squareRoot()))
    }

    // MARK: manutenção

    /// Refaz o índice inteiro contra as notas dadas: entra o que pode, sai o
    /// que não pode mais (selo) ou não existe mais. Só recalcula a nota cuja
    /// `editadaEm` mudou.
    /// `geracao` (ADR 05s): ordem em que a rota foi chamada na main; a nota
    /// que um selo mais novo já tirou fica de fora mesmo que esta lista,
    /// mais velha, ainda a traga como aberta.
    static func sincronizar(_ notas: [NotaLida], geracao g: Int = 0) {
        guard disponivel else { return }
        tranca.lock(); defer { tranca.unlock() }
        var atual = carregar()
        var novo: [String: Entrada] = [:]
        for n in notas {
            let chave = n.uuid.uuidString
            defer { atual.removeValue(forKey: chave) }
            guard avanca(chave, g) else {
                if let e = atual[chave] { novo[chave] = e }
                continue
            }
            guard n.podeEntrar else { continue }
            if let e = atual[chave], e.editadaEm == n.editadaEm {
                novo[chave] = e
            } else if let v = vetor(expandirAnexos(n.voz)) {
                novo[chave] = Entrada(editadaEm: n.editadaEm, vetor: v)
            }
        }
        for (chave, e) in atual where !avanca(chave, g) { novo[chave] = e }
        gravar(novo)
    }

    /// Uma nota que mudou — sem passar por todas.
    static func atualizar(_ n: NotaLida, geracao g: Int = 0) {
        guard disponivel else { return }
        tranca.lock(); defer { tranca.unlock() }
        var atual = carregar()
        let chave = n.uuid.uuidString
        guard avanca(chave, g) else { return }
        if n.podeEntrar, let v = vetor(expandirAnexos(n.voz)) {
            atual[chave] = Entrada(editadaEm: n.editadaEm, vetor: v)
        } else {
            atual.removeValue(forKey: chave)
        }
        gravar(atual)
    }

    /// O selo, na hora: selar ou apagar tira do índice antes de qualquer busca.
    static func remover(_ uuid: UUID, geracao g: Int = 0) {
        tranca.lock(); defer { tranca.unlock() }
        var atual = carregar()
        guard avanca(uuid.uuidString, g) else { return }
        guard atual.removeValue(forKey: uuid.uuidString) != nil else { return }
        gravar(atual)
    }

    static func apagarTudo() {
        tranca.lock(); defer { tranca.unlock() }
        memoria = [:]
        geracoes = [:]
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: busca

    /// As notas mais próximas de um texto, das mais próximas para trás.
    /// `minimo` é a proximidade abaixo da qual não é vizinhança, é ruído.
    static func vizinhas(de texto: String, teto: Int, minimo: Double = 0.3,
                         exceto: Set<UUID> = []) -> [Vizinha] {
        guard let alvo = vetor(texto) else { return [] }
        return vizinhas(deVetor: alvo, teto: teto, minimo: minimo, exceto: exceto)
    }

    static func vizinhas(deVetor alvo: [Float], teto: Int, minimo: Double = 0.3,
                         exceto: Set<UUID> = []) -> [Vizinha] {
        tranca.lock()
        let tudo = carregar()
        tranca.unlock()
        var saida: [Vizinha] = []
        for (chave, e) in tudo {
            guard let id = UUID(uuidString: chave), !exceto.contains(id) else { continue }
            let p = cosseno(alvo, e.vetor)
            if p >= minimo { saida.append(Vizinha(uuid: id, proximidade: p)) }
        }
        return Array(saida.sorted { $0.proximidade > $1.proximidade }.prefix(teto))
    }

    static func vetorGuardado(_ uuid: UUID) -> [Float]? {
        tranca.lock(); defer { tranca.unlock() }
        return carregar()[uuid.uuidString]?.vetor
    }

    // MARK: disco

    private static func carregar() -> [String: Entrada] {
        if let memoria { return memoria }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        let lido = (try? Data(contentsOf: url)).flatMap { try? dec.decode([String: Entrada].self, from: $0) } ?? [:]
        memoria = lido
        return lido
    }

    private static func gravar(_ dados: [String: Entrada]) {
        memoria = dados
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        guard let bytes = try? enc.encode(dados) else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? bytes.write(to: url, options: .atomic)
    }
}

/// ADR 05s: um relógio lógico para as projeções (corpus, índice, Spotlight).
/// Cada rota que projeta pega um número na main, na ordem em que foi chamada;
/// quem grava fora da main leva o número junto, e uma gravação atrasada nunca
/// passa por cima de uma mais nova.
@MainActor
enum Geracao {
    private static var contador = 0
    static func proxima() -> Int {
        contador += 1
        return contador
    }
}
