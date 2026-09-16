import Foundation

/// A volta que cobra (ADR 2026-09-04v): quando o campo `soDepois` de uma
/// forma passa a valer. Uma regra só, para a página e para a lista.
nonisolated enum Volta {
    /// A hora de conferir chegou. Decisão espera a data do "espero" (sem
    /// data, fica com o autor); Dia é à noite ou no dia seguinte; qualquer
    /// outro campo de volta vale uma semana depois de escrever.
    nonisolated static func devida(gesto: Gesto?, campos: [String: String], criadaEm: Date?,
                                   agora: Date = .now, cal: Calendar = .current) -> Bool {
        guard let gesto else { return false }
        switch gesto {
        case .decisao:
            guard let quando = Gatilho.data(em: campos["espero"] ?? "", agora: agora) else { return true }
            return quando <= agora
        case .dia:
            if cal.component(.hour, from: agora) >= 18 { return true }
            if let c = criadaEm { return !cal.isDate(c, inSameDayAs: agora) }
            return false
        default:
            guard gesto.campos.contains(where: \.soDepois), let c = criadaEm else { return false }
            return agora.timeIntervalSince(c) >= 7 * 86_400
        }
    }

    /// O primeiro campo de volta devido e ainda vazio — o que a lista cobra.
    /// nil = nada a cobrar.
    nonisolated static func campoDevido(gesto: Gesto?, campos: [String: String], criadaEm: Date?,
                                        fechado: Bool = false, agora: Date = .now) -> CampoForma? {
        guard !fechado, gesto != .expressiva,
              devida(gesto: gesto, campos: campos, criadaEm: criadaEm, agora: agora) else { return nil }
        return gesto?.campos.first {
            $0.soDepois && (campos[$0.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    /// ADR 05b: a linha da página em branco. Vazia sem volta devida.
    nonisolated static func emPalavras(quantas: Int) -> String {
        switch quantas {
        case ..<1: ""
        // o mesmo nome das Notas ("Hora de conferir"), sem o jargão "volta"
        case 1: "1 para conferir"
        default: "\(quantas) para conferir"
        }
    }

    /// O rótulo virado em cobrança: "O que roubou o dia (à noite)" →
    /// "O que roubou o dia?".
    nonisolated static func cobranca(_ campo: CampoForma) -> String {
        var r = campo.rotulo
        if let i = r.firstIndex(of: "(") { r = String(r[..<i]) }
        r = r.trimmingCharacters(in: .whitespaces)
        return r.hasSuffix("?") ? r : r + "?"
    }
}
