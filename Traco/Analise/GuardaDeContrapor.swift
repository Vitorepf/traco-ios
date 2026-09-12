import Foundation

/// ADR 2026-09-12a — contrapor não oferece substituto para a saída
/// que a NOTA fechou. A tesoura lê a nota, não o `fechadas` do modelo:
/// o join `dependeDoQueElaFechou` casava as duas falas dele e matava
/// proposta que usava o que ela JÁ TEM (LOTE-9). Só `foraDaLista`.
/// A rota permanece cortada até remedição pareada.
nonisolated enum GuardaDeContrapor {
    static func saidasFechadas(_ texto: String) -> [String] {
        let t = Sabia.dobrada(texto)
        var out: [String] = []
        out += capturas(t, #"([^.!?]{5,60}?) eu ja descartei"#)
        out += capturas(t, #"\b(\w{5,30}) tambem nao da"#)
        out += capturas(t, #"nao tenho ([^.!?]{8,80})"#)
        for quero in capturas(t, #"nao quero ([^.!?]{8,80})"#) {
            out += quero.components(separatedBy: " nem ").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return out.filter { $0.count >= 5 }
    }

    static func oferece(_ frase: String, fechadas: [String]) -> Bool {
        let proposta = nucleo(frase)
        guard !proposta.isEmpty else { return false }
        return fechadas.contains { !nucleo($0).isDisjoint(with: proposta) }
    }

    static func filtrar(_ c: Sabia.Contraparte, texto: String) -> Sabia.Contraparte {
        let fechadas = saidasFechadas(texto)
        guard !fechadas.isEmpty, !c.foraDaLista.isEmpty else { return c }
        guard oferece(c.foraDaLista, fechadas: fechadas) else { return c }
        _ = Sabia.apagou("foraDaLista", "saida que ela fechou")
        return Sabia.Contraparte(contra: c.contra, foraDaLista: "", outroCampo: c.outroCampo)
    }

    private static func nucleo(_ t: String) -> Set<Substring> {
        Set(Sabia.dobrada(t).split(whereSeparator: { !$0.isLetter }).filter { $0.count >= 5 })
    }

    private static func capturas(_ t: String, _ padrao: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: padrao) else { return [] }
        let ns = t as NSString
        return re.matches(in: t, range: NSRange(location: 0, length: ns.length)).compactMap { m in
            guard m.numberOfRanges > 1 else { return nil }
            let r = m.range(at: 1)
            guard r.location != NSNotFound else { return nil }
            return ns.substring(with: r).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
