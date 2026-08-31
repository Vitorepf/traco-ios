import SwiftUI

enum DestaqueBusca {
    /// Concatena `Text`s. `AttributedString` dentro de `Button` perde o âmbar
    /// para o `foregroundStyle` do ambiente.
    static func texto(_ texto: String, termo: String, base: Color) -> Text {
        let chave = termo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !chave.isEmpty else {
            return Text(texto).foregroundStyle(base)
        }
        var cursor = texto.startIndex
        var saida = Text("")
        var achou = false
        while cursor < texto.endIndex,
              let faixa = texto.range(of: chave, options: [.caseInsensitive, .diacriticInsensitive], range: cursor..<texto.endIndex) {
            if faixa.lowerBound > cursor {
                saida = saida + Text(String(texto[cursor..<faixa.lowerBound])).foregroundStyle(base)
            }
            saida = saida + Text(String(texto[faixa])).foregroundStyle(Tema.ambar)
            cursor = faixa.upperBound
            achou = true
        }
        if cursor < texto.endIndex {
            saida = saida + Text(String(texto[cursor...])).foregroundStyle(base)
        }
        return achou ? saida : Text(texto).foregroundStyle(base)
    }
}
