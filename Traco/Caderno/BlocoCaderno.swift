import Foundation

struct TarefaCaderno: Equatable, Sendable {
    var feito: Bool
    var texto: String
}

enum FormaCaderno: Equatable, Sendable {
    case titulo, lista, tarefa, citacao, tabela
    case codigo(String)
}

enum BlocoCaderno: Equatable, Sendable {
    case paragrafo(String)
    case titulo(Int, String)
    case itens([String], ordenada: Bool)
    case tarefas([TarefaCaderno])
    case citacao([String])
    case tabela(cabeca: [String], corpo: [[String]])
    case codigo(lingua: String, fonte: String)
    case imagem(id: String, alt: String)
    case audio(id: String, nome: String)
    case video(id: String, nome: String)
    case arquivo(id: String, nome: String)
    case divisoria
    case recipiente(slug: String, linhas: [String])
}

struct FatiaCaderno: Identifiable, Equatable, Sendable {
    let id: String
    let bloco: BlocoCaderno
    let fonte: String
    var aberto: Bool
}

enum Caderno: Sendable {
    // ponytail: memo de último valor — o body do SwiftUI avalia `fatias` 2+ vezes por
    // tecla sobre o MESMO texto; isto corta o reparse redundante. Teto conhecido:
    // ainda é O(n) por mudança real; parser incremental por bloco fica na FILA (P1.2).
    nonisolated(unsafe) private static let memoLock = NSLock()
    nonisolated(unsafe) private static var memo: (fonte: String, fatias: [FatiaCaderno])?

    nonisolated static func fatias(_ fonte: String) -> [FatiaCaderno] {
        memoLock.lock()
        if let m = memo, m.fonte == fonte {
            memoLock.unlock()
            return m.fatias
        }
        memoLock.unlock()
        let f = fatiasSemMemo(fonte)
        memoLock.lock()
        memo = (fonte, f)
        memoLock.unlock()
        return f
    }

    nonisolated static func fatiasSemMemo(_ fonte: String) -> [FatiaCaderno] {
        if fonte.isEmpty {
            return [FatiaCaderno(id: "paragrafo:0", bloco: .paragrafo(""), fonte: "", aberto: true)]
        }

        let linhas = fonte.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        // trim pré-computado: cada linha era trimada 2–4× em passadas diferentes
        let trims = linhas.map { $0.trimmingCharacters(in: .whitespaces) }
        var saida: [FatiaCaderno] = []
        var i = 0

        func pega(_ inicio: Int, _ fim: Int) -> String {
            linhas[inicio..<fim].joined(separator: "\n")
        }

        func depoisDeVazias(_ de: Int) -> Int {
            var k = de
            while k < linhas.count, trims[k].isEmpty {
                k += 1
            }
            return k
        }

        // contador por papel: O(1) por bloco (o filter aqui era O(n²) no documento
        // inteiro — 254ms a 10k palavras). Ids idênticos aos de antes.
        var irmaos: [String: Int] = [:]
        func emite(_ bloco: BlocoCaderno, fonte: String, aberto: Bool) {
            let papel = chave(bloco)
            let irmao = irmaos[papel, default: 0]
            irmaos[papel] = irmao + 1
            saida.append(FatiaCaderno(id: "\(papel):\(irmao)", bloco: bloco, fonte: fonte, aberto: aberto))
        }

        while i < linhas.count {
            let inicio = i
            let trim = trims[i]

            if trim.isEmpty {
                i += 1
                continue
            }

            if trim.hasPrefix("```") {
                let lingua = String(trim.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var corpo: [String] = []
                var j = i + 1
                var fechou = false
                while j < linhas.count {
                    if trims[j].hasPrefix("```") {
                        fechou = true
                        j += 1
                        break
                    }
                    corpo.append(linhas[j])
                    j += 1
                }
                let fim = depoisDeVazias(j)
                emite(
                    .codigo(lingua: lingua.isEmpty ? "texto" : lingua, fonte: corpo.joined(separator: "\n")),
                    fonte: pega(inicio, fim),
                    aberto: !fechou
                )
                i = fim
                continue
            }

            if let anexo = anexo(trim) {
                let fim = depoisDeVazias(i + 1)
                emite(anexo, fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if trim.hasPrefix(":::") {
                let slug = String(trim.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                if slug.isEmpty {
                    i += 1
                    continue
                }
                var corpo: [String] = []
                var j = i + 1
                var fechou = false
                while j < linhas.count {
                    if trims[j] == ":::" {
                        fechou = true
                        j += 1
                        break
                    }
                    corpo.append(linhas[j])
                    j += 1
                }
                let fim = depoisDeVazias(j)
                emite(.recipiente(slug: slug, linhas: corpo), fonte: pega(inicio, fim), aberto: !fechou)
                i = fim
                continue
            }

            if trim == "---" || trim == "***" {
                let fim = depoisDeVazias(i + 1)
                emite(.divisoria, fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if let (nivel, texto) = titulo(trim) {
                let fim = depoisDeVazias(i + 1)
                emite(.titulo(nivel, texto), fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if comecaTabela(linhas, i: i) {
                var cabeca: [String] = []
                var corpo: [[String]] = []
                if let primeira = celulas(trim) ?? (trim.hasPrefix("|") ? [""] : nil) {
                    if eSeparador(primeira) {
                        cabeca = Array(repeating: "", count: max(primeira.count, 1))
                        i += 1
                    } else {
                        cabeca = primeira
                        i += 1
                        if i < linhas.count, let sep = celulas(trims[i]), eSeparador(sep) {
                            i += 1
                        }
                    }
                    while i < linhas.count, let row = celulas(trims[i]), !eSeparador(row) {
                        corpo.append(row)
                        i += 1
                    }
                }
                let fim = depoisDeVazias(i)
                emite(.tabela(cabeca: cabeca, corpo: corpo), fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if trim.hasPrefix(">") {
                var bloco: [String] = []
                while i < linhas.count {
                    let t = trims[i]
                    guard t.hasPrefix(">") else { break }
                    bloco.append(String(t.drop(while: { $0 == ">" || $0 == " " })))
                    i += 1
                }
                let fim = depoisDeVazias(i)
                emite(.citacao(bloco), fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if tarefa(trim) != nil {
                var itens: [TarefaCaderno] = []
                while i < linhas.count, let item = tarefa(trims[i]) {
                    itens.append(item)
                    i += 1
                }
                let fim = depoisDeVazias(i)
                emite(.tarefas(itens), fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if lista(trim) != nil {
                var itens: [String] = []
                var ordenada = false
                while i < linhas.count, let detectado = lista(trims[i]) {
                    // o trim detecta o marcador; o CONTEÚDO sai da linha crua —
                    // senão o espaço que o autor acabou de digitar morre a cada tecla
                    let crua = String(linhas[i].drop(while: { $0 == " " }))
                    itens.append(lista(crua)?.texto ?? detectado.texto)
                    ordenada = detectado.ordenada
                    i += 1
                }
                let fim = depoisDeVazias(i)
                emite(.itens(itens, ordenada: ordenada), fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            while i < linhas.count {
                let t = trims[i]
                if t.isEmpty { break }
                if t.hasPrefix("```") || t.hasPrefix(":::") || t == "---" || t == "***" || titulo(t) != nil
                    || lista(t) != nil || tarefa(t) != nil || t.hasPrefix(">")
                    || anexo(t) != nil || comecaTabela(linhas, i: i) {
                    break
                }
                i += 1
            }
            let fim = i
            let aberto = i >= linhas.count
            emite(.paragrafo(pega(inicio, fim)), fonte: pega(inicio, fim), aberto: aberto)
        }

        if saida.isEmpty {
            return [FatiaCaderno(id: "paragrafo:0", bloco: .paragrafo(""), fonte: "", aberto: true)]
        }
        if let last = saida.last, !last.aberto {
            emite(.paragrafo(""), fonte: "", aberto: true)
        }
        return saida
    }

    nonisolated static func chave(_ bloco: BlocoCaderno) -> String {
        switch bloco {
        case .paragrafo: "paragrafo"
        case .titulo(let n, _): "titulo-\(n)"
        case .itens(_, let ordenada): ordenada ? "numerada" : "lista"
        case .tarefas: "tarefa"
        case .citacao: "citacao"
        case .tabela: "tabela"
        case .codigo(let lingua, _): "codigo-\(lingua)"
        case .imagem: "imagem"
        case .audio: "audio"
        case .video: "video"
        case .arquivo: "arquivo"
        case .divisoria: "divisoria"
        case .recipiente(let slug, _): "papel-\(slug)"
        }
    }

    nonisolated static func serializar(_ bloco: BlocoCaderno) -> String {
        switch bloco {
        case .paragrafo(let t):
            return t
        case .titulo(let n, let t):
            return String(repeating: "#", count: min(max(n, 1), 3)) + " " + t
        case .itens(let xs, let ordenada):
            return xs.enumerated().map { i, x in
                ordenada ? "\(i + 1). \(x)" : "- \(x)"
            }.joined(separator: "\n")
        case .tarefas(let xs):
            return xs.map { "- [\($0.feito ? "x" : " ")] \($0.texto)" }.joined(separator: "\n")
        case .citacao(let xs):
            return xs.map { "> \($0)" }.joined(separator: "\n")
        case .tabela(let cabeca, let corpo):
            let cols = max(cabeca.count, 1)
            func linha(_ c: [String]) -> String {
                let cells = (0..<cols).map { $0 < c.count ? c[$0] : "" }
                return "| " + cells.joined(separator: " | ") + " |"
            }
            let sep = "| " + Array(repeating: "---", count: cols).joined(separator: " | ") + " |"
            return ([linha(cabeca), sep] + corpo.map(linha)).joined(separator: "\n")
        case .codigo(let lingua, let fonte):
            return "```\(lingua)\n\(fonte)\n```"
        case .imagem(let id, let alt):
            return "![\(alt)](traco://img/\(id))"
        case .audio(let id, let nome):
            return "[audio:\(nome)](traco://audio/\(id))"
        case .video(let id, let nome):
            return "[video:\(nome)](traco://video/\(id))"
        case .arquivo(let id, let nome):
            return "[arquivo:\(nome)](traco://file/\(id))"
        case .divisoria:
            return "---"
        case .recipiente(let slug, let linhas):
            return ":::\(slug)\n\(linhas.joined(separator: "\n"))\n:::"
        }
    }

    nonisolated static func textoVisivel(_ bloco: BlocoCaderno) -> String {
        switch bloco {
        case .paragrafo(let t), .titulo(_, let t):
            return t
        case .itens(let xs, _), .citacao(let xs):
            return xs.joined(separator: "\n")
        case .tarefas(let xs):
            return xs.map(\.texto).joined(separator: "\n")
        case .codigo(_, let fonte):
            return fonte
        case .tabela(let cabeca, let corpo):
            return (cabeca + corpo.flatMap { $0 }).joined(separator: "\n")
        case .imagem(_, let alt):
            return alt
        case .audio(_, let nome), .video(_, let nome), .arquivo(_, let nome):
            return nome
        case .divisoria:
            return ""
        case .recipiente(_, let linhas):
            return linhas.joined(separator: "\n")
        }
    }

    nonisolated static func comTexto(_ bloco: BlocoCaderno, _ texto: String) -> BlocoCaderno {
        switch bloco {
        case .titulo(let n, _):
            return .titulo(n, texto)
        case .itens(_, let ordenada):
            let xs = texto.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            let linhas = xs.isEmpty ? [""] : xs
            if linhas.count == 1, let t = caixa(linhas[0]) {
                return .tarefas([t])
            }
            return .itens(linhas, ordenada: ordenada)
        case .tarefas(let xs):
            let linhas = texto.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            let base = linhas.isEmpty ? [""] : linhas
            let novo = base.enumerated().map { i, t in
                if let nascida = caixa(t) { return nascida }
                return TarefaCaderno(feito: i < xs.count ? xs[i].feito : false, texto: t)
            }
            return .tarefas(novo)
        case .citacao:
            let xs = texto.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            return .citacao(xs.isEmpty ? [""] : xs)
        case .codigo(let lingua, _):
            return .codigo(lingua: lingua, fonte: texto)
        case .paragrafo:
            return .paragrafo(texto)
        case .recipiente(let slug, _):
            let xs = texto.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            return .recipiente(slug: slug, linhas: xs.isEmpty ? [""] : xs)
        case .tabela(let cabeca, let corpo):
            var next = cabeca.isEmpty ? [""] : cabeca
            let primeira = texto.split(separator: "\n", omittingEmptySubsequences: false)
                .first.map(String.init) ?? texto
            next[0] = primeira
            return .tabela(cabeca: next, corpo: corpo)
        default:
            return bloco
        }
    }

    /// Materializa o gesto da régua / do menu. Campos nascem vazios; a prosa
    /// só entra se o autor já a tinha escrito. A IA não passa daqui.
    nonisolated static func bloco(de papel: PapelForma, texto: String) -> BlocoCaderno {
        let linhas = texto.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        switch papel.gesto {
        case .titulo(let n):
            return .titulo(n, texto.trimmingCharacters(in: .newlines))
        case .lista(let ordenada):
            return .itens(linhas.isEmpty ? [""] : linhas, ordenada: ordenada)
        case .tarefa:
            let xs = (linhas.isEmpty ? [""] : linhas).map { TarefaCaderno(feito: false, texto: $0) }
            return .tarefas(xs)
        case .citacao:
            return .citacao(linhas.isEmpty ? [""] : linhas)
        case .codigo(let lingua):
            return .codigo(lingua: lingua ?? "texto", fonte: "")
        case .tabela:
            return .tabela(cabeca: ["", ""], corpo: [["", ""]])
        case .divisoria:
            return .divisoria
        case .recipiente:
            if linhas.isEmpty {
                return .recipiente(slug: papel.slug, linhas: papel.cromo == .duplo ? ["", ""] : [""])
            }
            return .recipiente(slug: papel.slug, linhas: linhas)
        }
    }

    nonisolated static func forma(_ forma: FormaCaderno, texto: String) -> BlocoCaderno {
        let linhas = texto.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        switch forma {
        case .titulo:
            return .titulo(1, texto.trimmingCharacters(in: .newlines))
        case .lista:
            return .itens(linhas.isEmpty ? [""] : linhas, ordenada: false)
        case .tarefa:
            let xs = (linhas.isEmpty ? [""] : linhas).map { TarefaCaderno(feito: false, texto: $0) }
            return .tarefas(xs)
        case .citacao:
            return .citacao(linhas.isEmpty ? [""] : linhas)
        case .codigo(let lingua):
            return .codigo(lingua: lingua, fonte: "")
        case .tabela:
            return .tabela(cabeca: ["", ""], corpo: [["", ""]])
        }
    }

    nonisolated static func partirUltimo(_ texto: String) -> (antes: String, ultimo: String) {
        if let faixa = texto.range(of: "\n\n", options: .backwards) {
            return (String(texto[..<faixa.lowerBound]), String(texto[faixa.upperBound...]))
        }
        return ("", texto)
    }

    nonisolated static func juntar(_ antes: String, _ bloco: BlocoCaderno) -> String {
        let marca = serializar(bloco)
        if antes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return marca
        }
        return antes.hasSuffix("\n") ? antes + "\n" + marca : antes + "\n\n" + marca
    }

    nonisolated static func aplicar(_ fatias: [FatiaCaderno], id: String, bloco: BlocoCaderno) -> String {
        aplicar(fatias, id: id, novo: serializar(bloco))
    }

    nonisolated static func aplicar(_ fatias: [FatiaCaderno], id: String, novo: String) -> String {
        var partes = fatias.map { $0.id == id ? novo : $0.fonte }
        while partes.last?.isEmpty == true {
            partes.removeLast()
        }
        return partes.joined(separator: "\n")
    }

    nonisolated static func prosa(de markdown: String) -> String {
        fatias(markdown).compactMap { fatia -> String? in
            switch fatia.bloco {
            case .paragrafo(let t), .titulo(_, let t):
                return t
            case .itens(let xs, _), .citacao(let xs):
                return xs.joined(separator: "\n")
            case .tarefas(let xs):
                return xs.map(\.texto).joined(separator: "\n")
            case .tabela(let cabeca, let corpo):
                return (cabeca + corpo.flatMap { $0 }).joined(separator: " ")
            case .recipiente(_, let xs):
                return xs.joined(separator: "\n")
            case .codigo, .imagem, .audio, .video, .arquivo, .divisoria:
                return nil
            }
        }
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }

    nonisolated static func visivel(_ fonte: String) -> String {
        fatias(fonte).map { textoVisivel($0.bloco) }.joined(separator: "\n")
    }

    /// Só prosa e lista: o ÚNICO terreno onde a edição crua nunca expõe
    /// mobiliário markdown (o autor jamais vê ```/traco:///:::/>).
    nonisolated static func soProsaELista(_ fonte: String) -> Bool {
        fatias(fonte).allSatisfy {
            switch $0.bloco {
            case .paragrafo, .itens: return true
            default: return false
            }
        }
    }

    nonisolated static func temMarca(_ s: String) -> Bool {
        s.contains("```") || s.contains(":::") || s.contains("|---") || s.contains("- [ ]") || s.contains("traco://")
    }

    /// Uma página, um campo: prosa nua ou um título. Vários blocos → nil (a notas de figuras).
    nonisolated static func paginaUna(_ fonte: String) -> FatiaCaderno? {
        let xs = fatias(fonte)
        let nucleo = xs.filter { fatia in
            if case .paragrafo(let t) = fatia.bloco, fatia.aberto,
               t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
            return true
        }
        let u = nucleo.count <= 1 ? (nucleo.first ?? xs.first) : nil
        guard let u else { return nil }
        switch u.bloco {
        case .paragrafo, .titulo: return u
        // lista de qualquer tamanho continua una: a digitação nunca troca de campo
        case .itens: return u
        case .tarefas(let xs): return xs.count <= 1 ? u : nil
        case .citacao(let xs): return xs.count <= 1 ? u : nil
        case .tabela(let cabeca, let corpo):
            let cells = cabeca + corpo.flatMap { $0 }
            let vivas = cells.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            return (cabeca.count <= 1 && corpo.isEmpty) || vivas.count <= 1 ? u : nil
        default: return nil
        }
    }

    /// Ao sair da prosa nua, a fatia que nasceu — não o parágrafo vazio à cauda.
    nonisolated static func fatiaQueNasceu(de antigo: String, para novo: String) -> String? {
        let antes = fatias(antigo)
        let depois = fatias(novo)
        func soParagrafos(_ xs: [FatiaCaderno]) -> Bool {
            xs.allSatisfy { if case .paragrafo = $0.bloco { true } else { false } }
        }
        guard soParagrafos(antes), !soParagrafos(depois) else { return nil }
        return depois.last(where: { fatia in
            if case .paragrafo(let t) = fatia.bloco, fatia.aberto,
               t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
            return true
        })?.id
    }

    nonisolated private static func titulo(_ linha: String) -> (Int, String)? {
        guard linha.hasPrefix("#") else { return nil }
        var n = 0
        for ch in linha {
            if ch == "#" { n += 1 } else { break }
            if n == 3 { break }
        }
        guard n > 0, linha.count >= n else { return nil }
        if linha.count == n { return (n, "") }
        let idx = linha.index(linha.startIndex, offsetBy: n)
        if linha[idx] == " " {
            return (n, String(linha[linha.index(after: idx)...]))
        }
        guard linha[idx].isLetter || linha[idx].isNumber else { return nil }
        return (n, String(linha[idx...]))
    }

    nonisolated private static func lista(_ linha: String) -> (texto: String, ordenada: Bool)? {
        if tarefa(linha) != nil { return nil }
        if linha.hasPrefix("- ") || linha.hasPrefix("* ") {
            return (String(linha.dropFirst(2)), false)
        }
        // digitação ao vivo: "-" e "1." sozinhos JÁ são itens (vazios) —
        // o gutter assume o marcador e o autor nunca vê número duplicado
        if linha == "-" || linha == "*" { return ("", false) }
        if let ponto = linha.firstIndex(of: "."),
           !linha[..<ponto].isEmpty,
           linha[..<ponto].allSatisfy(\.isNumber) {
            if linha[ponto...].hasPrefix(". ") {
                return (String(linha[linha.index(ponto, offsetBy: 2)...]), true)
            }
            if linha.index(after: ponto) == linha.endIndex {
                return ("", true) // "3." exato
            }
        }
        return nil
    }

    /// O Enter que todo bloco de notas honra (digitação livre na página):
    /// - Enter no fim de "1. abc" → a linha nova nasce "2. "
    /// - Enter no fim de "- abc" / "* abc" → "- " / "* "
    /// - Enter no fim de "- [ ] x" → "- [ ] "
    /// - Enter num item VAZIO ("1. ", "- ", "3.") → o marcador morre: sai da lista
    /// Age só quando a mudança é exatamente UM \n inserido; senão devolve `novo` intacto.
    nonisolated static func continuar(velho: String, novo: String) -> String {
        guard novo.count == velho.count + 1 else { return novo }
        let vs = Array(velho), ns = Array(novo)
        var i = 0
        while i < vs.count, vs[i] == ns[i] { i += 1 }
        guard i < ns.count, ns[i] == "\n" else { return novo }
        // o resto precisa coincidir (inserção pura de um \n)
        guard Array(ns[(i + 1)...]) == Array(vs[i...]) else { return novo }
        let antes = String(ns[..<i])
        let inicioLinha = antes.lastIndex(of: "\n").map { antes.index(after: $0) } ?? antes.startIndex
        let linha = String(antes[inicioLinha...])
        let resto = String(ns[(i + 1)...])

        func montar(prefixo: String) -> String {
            antes + "\n" + prefixo + resto
        }
        func sairDaLista() -> String {
            String(antes[..<inicioLinha]) + "\n" + resto
        }

        // tarefa
        for marca in ["- [ ] ", "- [x] ", "- [X] ", "- [ ]", "- [x]", "- [X]"] where linha.hasPrefix(marca) {
            let conteudo = linha.dropFirst(marca.count).trimmingCharacters(in: .whitespaces)
            return conteudo.isEmpty ? sairDaLista() : montar(prefixo: "- [ ] ")
        }
        // lista simples
        for marca in ["- ", "* "] where linha.hasPrefix(marca) {
            let conteudo = linha.dropFirst(2).trimmingCharacters(in: .whitespaces)
            return conteudo.isEmpty ? sairDaLista() : montar(prefixo: marca)
        }
        if linha == "-" || linha == "*" { return sairDaLista() }
        // numerada
        if let ponto = linha.firstIndex(of: "."),
           !linha[..<ponto].isEmpty,
           linha[..<ponto].allSatisfy(\.isNumber),
           let n = Int(linha[..<ponto]) {
            let depois = linha[linha.index(after: ponto)...]
            if depois.isEmpty || depois == " " { return sairDaLista() }
            if depois.hasPrefix(" ") { return montar(prefixo: "\(n + 1). ") }
        }
        return novo
    }

    nonisolated private static func tarefa(_ linha: String) -> TarefaCaderno? {
        let marcas: [(String, Bool)] = [
            ("- [x] ", true), ("- [X] ", true), ("- [ ] ", false),
            ("* [x] ", true), ("* [X] ", true), ("* [ ] ", false),
            ("- [x]", true), ("- [X]", true), ("- [ ]", false),
        ]
        for (prefixo, feito) in marcas where linha.hasPrefix(prefixo) {
            var texto = String(linha.dropFirst(prefixo.count))
            if texto.hasPrefix(" ") { texto = String(texto.dropFirst()) }
            return TarefaCaderno(feito: feito, texto: texto)
        }
        if linha.hasPrefix("- [") || linha.hasPrefix("* [") {
            return caixa(String(linha.dropFirst(2)))
        }
        return nil
    }

    /// `[`, `[]`, `[ ]`, `[x]` — o autor chegou à caixa, não à prosa.
    nonisolated private static func caixa(_ s: String) -> TarefaCaderno? {
        var feito = false
        var r = s
        if r.hasPrefix("]") {
            r = String(r.dropFirst())
            if r.hasPrefix(" ") { r = String(r.dropFirst()) }
            return TarefaCaderno(feito: false, texto: r)
        }
        guard r.hasPrefix("[") else { return nil }
        r = String(r.dropFirst())
        if r.hasPrefix("x") || r.hasPrefix("X") {
            feito = true
            r = String(r.dropFirst())
        } else if r.hasPrefix(" ") {
            r = String(r.dropFirst())
        }
        if r.isEmpty {
            return TarefaCaderno(feito: feito, texto: "")
        }
        guard r.hasPrefix("]") else { return nil }
        r = String(r.dropFirst())
        if r.hasPrefix(" ") { r = String(r.dropFirst()) }
        return TarefaCaderno(feito: feito, texto: r)
    }

    nonisolated private static func comecaTabela(_ linhas: [String], i: Int) -> Bool {
        guard i < linhas.count else { return false }
        return linhas[i].trimmingCharacters(in: .whitespaces).hasPrefix("|")
    }

    nonisolated private static func celulas(_ linha: String) -> [String]? {
        guard linha.hasPrefix("|") else { return nil }
        var partes = linha.split(separator: "|", omittingEmptySubsequences: false).map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        if partes.first == "" { partes.removeFirst() }
        if partes.last == "" { partes.removeLast() }
        return partes.isEmpty ? nil : partes
    }

    nonisolated private static func eSeparador(_ cells: [String]) -> Bool {
        !cells.isEmpty && cells.allSatisfy { c in
            let x = c.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespaces)
            return !x.isEmpty && x.allSatisfy { $0 == "-" }
        }
    }

    nonisolated private static func anexo(_ linha: String) -> BlocoCaderno? {
        // pré-filtro O(1): sem "traco://" não há anexo — e nenhuma regex roda
        guard linha.contains("traco://") else { return nil }
        if let m = captura(linha, #"^!\[(.*?)\]\(traco://img/([0-9A-Fa-f-]+)\)$"#) {
            return .imagem(id: m[1], alt: m[0])
        }
        if let m = captura(linha, #"^\[audio:(.*?)\]\(traco://audio/([0-9A-Fa-f-]+)\)$"#) {
            return .audio(id: m[1], nome: m[0])
        }
        if let m = captura(linha, #"^\[video:(.*?)\]\(traco://video/([0-9A-Fa-f-]+)\)$"#) {
            return .video(id: m[1], nome: m[0])
        }
        if let m = captura(linha, #"^\[arquivo:(.*?)\]\(traco://file/([0-9A-Fa-f-]+)\)$"#) {
            return .arquivo(id: m[1], nome: m[0])
        }
        return nil
    }

    // regex compiladas UMA vez (antes: uma compilação por linha por padrão — o
    // custo dominante do parse em nota longa)
    nonisolated(unsafe) private static var regexCache: [String: NSRegularExpression] = [:]
    nonisolated(unsafe) private static let regexLock = NSLock()

    nonisolated private static func captura(_ texto: String, _ padrao: String) -> [String]? {
        regexLock.lock()
        let regex: NSRegularExpression
        if let r = regexCache[padrao] {
            regex = r
        } else if let r = try? NSRegularExpression(pattern: padrao) {
            regexCache[padrao] = r
            regex = r
        } else {
            regexLock.unlock()
            return nil
        }
        regexLock.unlock()
        let faixa = NSRange(texto.startIndex..., in: texto)
        guard let m = regex.firstMatch(in: texto, range: faixa), m.numberOfRanges >= 3 else { return nil }
        func g(_ i: Int) -> String {
            Range(m.range(at: i), in: texto).map { String(texto[$0]) } ?? ""
        }
        return [g(1), g(2)]
    }
}
