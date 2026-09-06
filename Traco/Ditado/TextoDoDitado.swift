import Foundation

/// ADR 2026-09-05x — o que a nota do ditado diz, em cada um dos três estados.
///
/// Nenhum campo novo no modelo: o áudio entra pelo marcador de anexo que o
/// Caderno já lê e TOCA (`[audio:nome](traco://audio/<id>)`, ADR 04t). Quem
/// abre a nota ouve o que falou — o áudio é localizável a partir dela porque
/// está DENTRO dela, e o arquivo mora no cofre de anexos, nunca no SwiftData.
///
/// A linha de origem é sempre a última e sempre verdadeira no instante em que
/// existe: o depósito nasce dizendo "sem transcrição", que é exatamente o que
/// uma morte do app deixa para trás.
nonisolated enum TextoDoDitado {
    /// O nome que o autor lê no portal do anexo. A extensão é o que o
    /// `AnexoDisco` usa para achar o arquivo: sem `.m4a` o áudio some.
    static func nomeDoArquivo(_ quando: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "d MMM HH'h'mm"
        return "ditado \(f.string(from: quando)).m4a"
    }

    static func marcador(id: UUID, quando: Date) -> String {
        "[audio:\(nomeDoArquivo(quando))](traco://audio/\(id.uuidString))"
    }

    static func quandoEmPalavras(_ quando: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "d 'de' MMMM, HH'h'mm"
        return f.string(from: quando)
    }

    /// O corpo da nota. `transcricao` e `motivo` são exclusivos; nenhum dos
    /// dois é o depósito cru (o áudio guardado, ainda sem letra).
    static func corpo(id: UUID, quando: Date, transcricao: String? = nil, motivo: String? = nil) -> String {
        let audio = marcador(id: id, quando: quando)
        let hora = quandoEmPalavras(quando)
        if let transcricao, !transcricao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let limpa = transcricao.trimmingCharacters(in: .whitespacesAndNewlines)
            return "\(limpa)\n\n\(audio)\n\nDitado de \(hora), transcrito no aparelho. Confira."
        }
        if let motivo {
            return "\(audio)\n\nDitado de \(hora). Não consegui transcrever: \(motivo) O áudio ficou."
        }
        return "\(audio)\n\nDitado de \(hora). O áudio ficou guardado, sem transcrição."
    }
}
