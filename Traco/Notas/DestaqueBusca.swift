import SwiftUI

enum DestaqueBusca {
    /// O trecho onde a busca bateu, com o termo em âmbar.
    ///
    /// Era `Text + Text`, obsoleto no iOS 26. A nota antiga dizia que
    /// `AttributedString` perdia o âmbar dentro de um `Button` — e perde com
    /// `foregroundStyle`, que é modificador de VIEW e cede ao ambiente. Aqui é
    /// `foregroundColor`, atributo da própria string, que viaja com o texto e
    /// não cede.
    ///
    /// ATENÇÃO (03/set): a distinção é essa, mas NÃO conferi na tela — não
    /// consegui injetar texto no campo de busca pelo simulador. O olho do dono
    /// no aparelho fecha isto: buscar "celular" e ver se o termo sai em âmbar.
    /// Se sair na cor base, o caminho é voltar ao `Text + Text` e conviver com
    /// o aviso de obsolescência até haver substituto que preserve o run.
    static func texto(_ texto: String, termo: String, base: Color) -> Text {
        Text(atribuido(texto, termo: termo, base: base, realce: Tema.ambarTinta))
    }

    /// `realce` entra por parâmetro: `Tema` é MainActor e isto é função pura.
    nonisolated static func atribuido(_ texto: String, termo: String, base: Color,
                                      realce: Color) -> AttributedString {
        var tudo = AttributedString(texto)
        tudo.foregroundColor = base
        let chave = termo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !chave.isEmpty else { return tudo }

        var saida = AttributedString()
        var cursor = texto.startIndex
        while cursor < texto.endIndex,
              let faixa = texto.range(of: chave,
                                      options: [.caseInsensitive, .diacriticInsensitive],
                                      range: cursor..<texto.endIndex) {
            if faixa.lowerBound > cursor {
                var antes = AttributedString(String(texto[cursor..<faixa.lowerBound]))
                antes.foregroundColor = base
                saida += antes
            }
            var achado = AttributedString(String(texto[faixa]))
            achado.foregroundColor = realce
            saida += achado
            cursor = faixa.upperBound
        }
        guard !saida.characters.isEmpty else { return tudo }
        if cursor < texto.endIndex {
            var resto = AttributedString(String(texto[cursor...]))
            resto.foregroundColor = base
            saida += resto
        }
        return saida
    }
}
