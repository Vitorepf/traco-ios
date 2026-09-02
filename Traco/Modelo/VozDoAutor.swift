import Foundation

enum VozDoAutor: Sendable {
    // ponytail: cache por (uuid, editadaEm). A busca do arquivo pede a voz de
    // TODAS as notas a cada tecla; sem isto era o parser inteiro × N notas ×
    // tecla. Guarda só a string da voz (não as fatias); teto 4096 e esvazia.
    // `Nota` (PersistentModel) é nonisolated: o cache vive sob lock, como o memo do parser.
    nonisolated private static let lock = NSLock()
    nonisolated(unsafe) private static var cache: [UUID: (editadaEm: Date, voz: String)] = [:]

    nonisolated static func voz(uuid: UUID, editadaEm: Date, texto: String, campos: [String: String]) -> String {
        lock.lock()
        if let c = cache[uuid], c.editadaEm == editadaEm {
            lock.unlock()
            return c.voz
        }
        lock.unlock()
        let v = juntar(texto: texto, campos: campos)
        lock.lock()
        if cache.count >= 4096 { cache.removeAll(keepingCapacity: true) }
        cache[uuid] = (editadaEm, v)
        lock.unlock()
        return v
    }

    nonisolated static func juntar(texto: String, campos: [String: String]) -> String {
        let respostas = campos.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let prosa = Caderno.prosa(de: texto)
        return ([prosa] + respostas)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    nonisolated static func titulo(_ texto: String) -> String {
        let prosa = Caderno.prosa(de: texto)
        let base = prosa.isEmpty ? Caderno.visivel(texto) : prosa
        return base.split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? ""
    }

    nonisolated static func truncar(_ texto: String, _ n: Int) -> String {
        guard texto.count > n else { return texto }
        let corte = texto.prefix(n)
        if let lastSpace = corte.lastIndex(of: " ") {
            return String(corte[..<lastSpace]) + "…"
        }
        return String(corte) + "…"
    }

    nonisolated static func relativo(_ data: Date, agora: Date = .now) -> String {
        let dias = Calendar.current.dateComponents([.day], from: data, to: agora).day ?? 0
        if dias <= 0 { return "hoje" }
        if dias == 1 { return "ontem" }
        return "há \(dias) dias"
    }

    nonisolated static func trecho(em voz: String, termo: String, limite: Int = 56) -> String {
        let linhas = voz.split(separator: "\n").map(String.init)
        let linha = linhas.first { $0.localizedCaseInsensitiveContains(termo) } ?? VozDoAutor.titulo(voz)
        return truncar(linha, limite)
    }
}