import Foundation

/// A rede das notas (ADR 2026-09-03b): o valor de um caderno não está nas
/// notas, está nas ligações entre elas (Luhmann). Hoje o campo "Liga a" é
/// texto morto e uma nota que cita outra não sabe disso.
///
/// Algoritmo puro, offline: a ligação nasce do que o AUTOR escreveu — o campo
/// "Liga a" e as menções `[[assim]]` no texto. A IA não sugere ligação nenhuma;
/// ligar é ato de pensamento, e pensar é dele.
nonisolated enum Rede {
    /// Uma nota, sem SwiftData.
    nonisolated struct NotaLida: Sendable, Equatable {
        var uuid: UUID
        var titulo: String
        var texto: String
        var campos: [String: String]
        var gesto: Gesto?
        var fechada: Bool
        var expressivaEmCurso: Bool
        /// ADR 09b: ligar é ato de pensamento do AUTOR. A nota que o bot deixou
        /// na pasta pode ser DESTINO — ligar a ela é ato dele —, mas nunca
        /// ORIGEM: uma menção que ele não escreveu não é ligação dele.
        /// Sem padrão: o chamador declara ou não compila.
        var vozDoAutor: Bool

        /// Selo: a expressiva (em curso ou fechada) e a trancada não entram na
        /// rede — nem como origem, nem como destino.
        var podeLigar: Bool { !fechada && !expressivaEmCurso && gesto != .expressiva }
    }

    nonisolated struct Ligacao: Sendable, Equatable, Identifiable {
        var de: UUID
        var para: UUID
        var termo: String
        var id: String { "\(de)->\(para)|\(termo)" }
    }

    /// As menções `[[assim]]` de um texto, na ordem em que aparecem.
    nonisolated static func mencoes(_ texto: String) -> [String] {
        guard texto.contains("[["), let re = try? NSRegularExpression(pattern: #"\[\[([^\[\]\n]{1,120})\]\]"#) else { return [] }
        let range = NSRange(texto.startIndex..., in: texto)
        var saida: [String] = []
        for m in re.matches(in: texto, range: range) {
            guard let r = Range(m.range(at: 1), in: texto) else { continue }
            let t = String(texto[r]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty, !saida.contains(where: { $0.caseInsensitiveCompare(t) == .orderedSame }) { saida.append(t) }
        }
        return saida
    }

    /// Tudo o que uma nota aponta: as menções do texto mais o campo "Liga a"
    /// (uma por linha).
    nonisolated static func alvos(_ n: NotaLida) -> [String] {
        var termos = mencoes(n.texto)
        let liga = (n.campos["liga"] ?? "")
        for linha in liga.split(whereSeparator: \.isNewline) {
            let t = linha.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            guard t.count >= 3 else { continue }
            if !termos.contains(where: { $0.caseInsensitiveCompare(t) == .orderedSame }) { termos.append(t) }
        }
        return termos
    }

    /// Normaliza para casar título com menção: minúsculas, sem acento, sem
    /// pontuação de borda. "Nota Permanente!" casa com "nota permanente".
    nonisolated static func chave(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted.subtracting(.whitespaces))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// As ligações do caderno. Um termo casa com uma nota quando é igual ao
    /// título dela, ou quando o título começa por ele (o autor escreve o
    /// começo, não o título inteiro). Empate: a nota de título mais curto.
    nonisolated static func ligacoes(_ notas: [NotaLida]) -> [Ligacao] {
        let elegiveis = notas.filter(\.podeLigar)
        guard elegiveis.count > 1 else { return [] }
        var porChave: [String: [NotaLida]] = [:]
        for n in elegiveis {
            let k = chave(n.titulo)
            guard !k.isEmpty else { continue }
            porChave[k, default: []].append(n)
        }
        let ordenadas = elegiveis
            .filter { !chave($0.titulo).isEmpty }
            .sorted { $0.titulo.count < $1.titulo.count }

        var saida: [Ligacao] = []
        for origem in elegiveis where origem.vozDoAutor {
            for termo in alvos(origem) {
                let k = chave(termo)
                guard !k.isEmpty else { continue }
                let alvo = porChave[k]?.first(where: { $0.uuid != origem.uuid })
                    ?? ordenadas.first { $0.uuid != origem.uuid && chave($0.titulo).hasPrefix(k) && k.count >= 4 }
                guard let alvo else { continue }
                let l = Ligacao(de: origem.uuid, para: alvo.uuid, termo: termo)
                if !saida.contains(l) { saida.append(l) }
            }
        }
        return saida
    }

    // MARK: escrever a ligação (Q2)

    /// O que o autor está ligando AGORA: o último `[[` sem `]]` depois dele.
    /// nil = não está escrevendo ligação nenhuma.
    ///
    /// Não precisa da posição do cursor — quem digita `[[` digita para a
    /// frente. É a aproximação barata que acerta o caso real.
    nonisolated static func ligacaoEmVoo(_ texto: String) -> String? {
        guard let abre = texto.range(of: "[[", options: .backwards) else { return nil }
        let depois = texto[abre.upperBound...]
        guard !depois.contains("]]"), !depois.contains("\n") else { return nil }
        return String(depois)
    }

    /// Os títulos que casam com o que já foi digitado, os mais curtos primeiro
    /// (o título curto é o que o autor provavelmente quer).
    nonisolated static func sugestoes(para trecho: String, entre titulos: [String],
                                      teto: Int = 5) -> [String] {
        let k = chave(trecho)
        let candidatos = titulos
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !chave($0).isEmpty }
        guard !k.isEmpty else {
            return Array(Set(candidatos)).sorted { $0.count < $1.count }.prefix(teto).map { $0 }
        }
        let casam = candidatos.filter { chave($0).contains(k) }
        // começa com o que foi digitado vem antes de conter no meio
        return Array(Set(casam))
            .sorted {
                let a = chave($0).hasPrefix(k), b = chave($1).hasPrefix(k)
                return a == b ? $0.count < $1.count : a
            }
            .prefix(teto)
            .map { $0 }
    }

    /// Fecha a ligação com o título escolhido. Troca do último `[[` até o fim.
    nonisolated static func completar(_ texto: String, com titulo: String) -> String {
        guard let abre = texto.range(of: "[[", options: .backwards) else { return texto }
        return String(texto[..<abre.lowerBound]) + "[[" + titulo + "]]"
    }

    /// Quem esta nota cita.
    nonisolated static func daqui(_ uuid: UUID, _ ligacoes: [Ligacao]) -> [Ligacao] {
        ligacoes.filter { $0.de == uuid }
    }

    /// Quem cita esta nota — o que o autor não vê sem a rede.
    nonisolated static func paraCa(_ uuid: UUID, _ ligacoes: [Ligacao]) -> [Ligacao] {
        ligacoes.filter { $0.para == uuid }
    }

    /// Notas que ninguém cita e que não citam ninguém: ilhas. Não é defeito —
    /// é o que ainda não achou lugar no seu pensamento.
    nonisolated static func ilhas(_ notas: [NotaLida], _ ligacoes: [Ligacao]) -> [UUID] {
        let ligadas = Set(ligacoes.flatMap { [$0.de, $0.para] })
        return notas.filter(\.podeLigar).map(\.uuid).filter { !ligadas.contains($0) }
    }
}
