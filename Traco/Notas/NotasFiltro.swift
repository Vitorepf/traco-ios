import Foundation

enum NotasFiltro {
    /// Trabalhos é destino do arquivo, não resultado da busca. A porta não
    /// some ao filtrar (ADR 2026-09-11a).
    static func mostraTrabalhos(busca: String, filtro: FiltroNotas?,
                                dominio: Dominio? = nil) -> Bool {
        _ = (busca, filtro, dominio)
        return true
    }

    static func visiveis(_ notas: [Nota], busca: String, filtro: FiltroNotas?,
                         dominio: Dominio? = nil) -> [Nota] {
        notas.filter { nota in
            if filtro == .trancadas { return nota.trancada }
            if nota.trancada { return busca.isEmpty && filtro == nil && dominio == nil }
            // Série em voo grava a página vazia para o kill não a perder.
            // O arquivo é o que o autor escreveu — sem voz, não é nota.
            // ADR 08p: e sem nome também não. Uma página só com o marcador
            // "## " tem texto cru (Nota.temVoz diz sim) mas nada visível: a
            // lista afirmava uma nota onde não havia nada. A raiz é
            // Sessao.paginaVazia/Nota.temVoz lerem o texto cru — fora desta volta.
            if !nota.fechada && (!nota.temVoz || nota.tituloNaLista.isEmpty) { return false }
            if let filtro, let g = filtro.gesto, nota.gesto != g { return false }
            if let dominio, nota.dominio != dominio { return false }
            if !busca.isEmpty { return casa(nota.textoDeQualquerOrigem, busca: busca) }
            return true
        }
    }

    /// "analise" acha "análise": busca sem acento e sem caixa. E uma PERGUNTA
    /// ("o que eu decidi sobre o plano de celular?") acha a nota que tem
    /// metade das palavras com quatro letras ou mais, por prefixo — "decidi"
    /// acha "Decidir". Sem a sábia no aparelho, é o que responde (auditoria
    /// 15/09, alto 2). Uma palavra só continua a exigir a palavra inteira.
    static func casa(_ texto: String, busca: String) -> Bool {
        let opcoes: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        if texto.range(of: busca, options: opcoes, locale: .current) != nil { return true }
        let palavras = Self.palavras(busca)
        guard palavras.count >= 2 else { return false }
        return pontuacao(texto, palavras: palavras) * 2 >= palavras.count
    }

    /// As palavras que contam numa busca: quatro letras ou mais, sem repetição.
    static func palavras(_ busca: String) -> [String] {
        var vistas = Set<String>()
        return busca.split { !$0.isLetter && !$0.isNumber }.map(String.init)
            .filter { $0.count >= 4 && vistas.insert($0.lowercased()).inserted }
    }

    /// Quantas das palavras o texto tem (por prefixo, sem caixa nem acento).
    /// É a régua do MATERIAL de um Trabalho: uma nota que fala do assunto
    /// ("Traço") entra mesmo sem repetir o verbo do pedido.
    static func pontuacao(_ texto: String, palavras: [String]) -> Int {
        let opcoes: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        return palavras.filter { texto.range(of: $0, options: opcoes, locale: .current) != nil }.count
    }
}
