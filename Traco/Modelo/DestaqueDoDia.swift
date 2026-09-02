import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// A linha do Destaque de hoje — a única coisa que a tela bloqueada mostra.
/// Nunca expressiva, nunca trancada: só a frase que o autor escreveu.
enum DestaqueDoDia: Sendable {
    nonisolated static let suite = "group.app.traco"
    nonisolated static let chaveLinha = "destaqueLinha"
    nonisolated static let chaveDia = "destaqueDia"

    nonisolated static func gravar(_ linha: String, em data: Date = .now) {
        let corte = linha.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !corte.isEmpty else { return }
        let d = UserDefaults(suiteName: suite) ?? .standard
        d.set(corte, forKey: chaveLinha)
        d.set(diaISO(data), forKey: chaveDia)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "TracoWidget")
        #endif
    }

    nonisolated static func linhaDeHoje(agora: Date = .now) -> String? {
        let d = UserDefaults(suiteName: suite) ?? .standard
        guard d.string(forKey: chaveDia) == diaISO(agora) else { return nil }
        let linha = d.string(forKey: chaveLinha)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return linha.isEmpty ? nil : linha
    }

    nonisolated static func diaISO(_ data: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: data)
    }
}
