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
    // ponytail: memo por texto. O parse é puro (só depende de `fonte`), então
    // guardar é sempre seguro.
    //
    // Era memo de UM valor, e isso é perfeito no editor — todas as chamadas de
    // um `body` usam a mesma nota — e o pior caso possível na LISTA de notas,
    // onde cada nota tem texto diferente e cada chamada invalidava a anterior.
    // A lista pede `vozDoAutor`, `tituloNaLista` e o trecho da busca: três
    // parses por nota, por avaliação de body, e nenhum acerto. Digitar na busca
    // reparseava o arquivo inteiro a cada caractere, na main thread.
    //
    // Teto conhecido: FIFO de 128 entradas. Digitar 128 teclas seguidas expulsa
    // as notas da lista, que voltam ao cache na próxima visita — barato. Parser
    // incremental por bloco continua na FILA (P1.2).
    nonisolated static let memoTeto = 128
    nonisolated private static let memoLock = NSLock()
    nonisolated(unsafe) private static var memo: [String: [FatiaCaderno]] = [:]
    nonisolated(unsafe) private static var memoOrdem: [String] = []

    nonisolated static func fatias(_ fonte: String) -> [FatiaCaderno] {
        memoLock.lock()
        if let hit = memo[fonte] {
            memoLock.unlock()
            return hit
        }
        memoLock.unlock()
        let f = fatiasSemMemo(fonte)
        memoLock.lock()
        if memo[fonte] == nil {
            memo[fonte] = f
            memoOrdem.append(fonte)
            if memoOrdem.count > memoTeto {
                memo.removeValue(forKey: memoOrdem.removeFirst())
            }
        }
        memoLock.unlock()
        return f
    }

    nonisolated static func fatiasSemMemo(_ fonte: String) -> [FatiaCaderno] {
        if fonte.isEmpty {
            return [FatiaCaderno(id: "paragrafo:0", bloco: .paragrafo(""), fonte: "", aberto: true)]
        }

        // CRLF entra por import de .md feito fora do iPhone. Sem normalizar, o
        // \r sobrevive até a TELA e até a análise — caractere de controle
        // invisível grudado no fim de cada linha da nota.
        let normal = fonte.contains("\r")
            ? fonte.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
            : fonte
        let linhas = normal.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
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
                    // uma cerca não come a outra: sem isto, um ``` sem fecho
                    // engolia o resto da nota e o mobiliário do que veio depois
                    // (":::", "|---") virava CONTEÚDO VISÍVEL
                    if trims[j].hasPrefix(":::") { break }
                    corpo.append(linhas[j])
                    j += 1
                }
                let fim = depoisDeVazias(j)
                let bloco = BlocoCaderno.codigo(lingua: lingua.isEmpty ? "texto" : lingua,
                                                fonte: corpo.joined(separator: "\n"))
                // cerca SEM FECHO só chega aqui por import de .md corrompido, e
                // o recorte cru dela não se descreve: remontar o documento
                // deslocava os blocos vizinhos. Guardamos a forma canônica —
                // tocar a nota conserta o arquivo quebrado.
                emite(bloco, fonte: fechou ? pega(inicio, fim) : serializar(bloco), aberto: !fechou)
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
                    // idem: um recipiente sem fecho não engole o irmão seguinte
                    if trims[j].hasPrefix(":::") || trims[j].hasPrefix("```") { break }
                    corpo.append(linhas[j])
                    j += 1
                }
                let fim = depoisDeVazias(j)
                // corpo vazio vira UMA linha vazia: é o mesmo que `bloco(de:)`
                // cria para um recipiente novo, e sem isso ":::verso" sem fecho
                // (vem de import de .md quebrado) ganhava uma linha em branco a
                // cada ida e volta pela serialização
                let bloco = BlocoCaderno.recipiente(slug: slug, linhas: corpo.isEmpty ? [""] : corpo)
                emite(bloco, fonte: fechou ? pega(inicio, fim) : serializar(bloco), aberto: !fechou)
                i = fim
                continue
            }

            if trim == "---" || trim == "***" {
                let fim = depoisDeVazias(i + 1)
                emite(.divisoria, fonte: pega(inicio, fim), aberto: false)
                i = fim
                continue
            }

            if let (nivel, _) = titulo(trim) {
                let fim = depoisDeVazias(i + 1)
                // o trim detecta o "#"; o CONTEÚDO sai da linha crua — senão o
                // espaço que o autor acabou de digitar morre a cada tecla no
                // campo projetado (mesmo conserto da lista, logo abaixo)
                let crua = String(linhas[inicio].drop(while: { $0 == " " }))
                let texto = titulo(crua)?.1 ?? trim
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
                    guard trims[i].hasPrefix(">") else { break }
                    // conteúdo da linha crua: o espaço à cauda sobrevive à tecla
                    let crua = String(linhas[i].drop(while: { $0 == " " }))
                    bloco.append(String(crua.drop(while: { $0 == ">" || $0 == " " })))
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
                    // conteúdo da linha crua: o espaço à cauda sobrevive à tecla
                    let crua = String(linhas[i].drop(while: { $0 == " " }))
                    itens.append(tarefa(crua) ?? item)
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

    /// "Vestir a nota" (FILA P1): estrutura o texto CRU do autor em formas
    /// visuais — título, seções, listas — sem inventar UMA palavra. Só insere o
    /// mobiliário em volta do que ele já escreveu, lendo a ESTRUTURA (linhas
    /// curtas paralelas = lista; linha curta sozinha = título, depois seção). A
    /// IA não passa daqui: é heurística de forma, nunca de conteúdo. Idempotente
    /// (bloco que já tem forma fica intocado) e reversível (editar volta ao cru).
    /// Recortes da fonte para vestir, sem normalizar nem reconstruir código.
    /// Uma cerca aberta protege até o fim; só a mesma marca, com comprimento
    /// suficiente e sem texto depois, a fecha. Não interpreta a linguagem.
    nonisolated static func intervalosParaVestir(_ texto: String) -> [Range<String.Index>] {
        var intervalos: [Range<String.Index>] = []
        var inicio: String.Index?
        var fim = texto.startIndex
        var cerca: (marca: Character, tamanho: Int)?
        func fecharBloco() {
            if let inicio { intervalos.append(inicio..<fim) }
            inicio = nil
        }
        texto.enumerateSubstrings(in: texto.startIndex..<texto.endIndex, options: .byLines) { linha, faixa, _, _ in
            let limpa = (linha ?? "").trimmingCharacters(in: .whitespaces)
            if let aberta = cerca {
                fim = faixa.upperBound
                let marcas = limpa.prefix { $0 == aberta.marca }
                if marcas.count >= aberta.tamanho,
                   limpa.dropFirst(marcas.count).trimmingCharacters(in: .whitespaces).isEmpty {
                    cerca = nil
                    fecharBloco()
                }
            } else if let marca = limpa.first, marca == "`" || marca == "~",
                      limpa.prefix(while: { $0 == marca }).count >= 3 {
                fecharBloco()
                inicio = faixa.lowerBound
                fim = faixa.upperBound
                cerca = (marca, limpa.prefix { $0 == marca }.count)
            } else if limpa.isEmpty {
                fecharBloco()
            } else {
                if inicio == nil { inicio = faixa.lowerBound }
                fim = faixa.upperBound
            }
        }
        if cerca != nil { fim = texto.endIndex }
        fecharBloco()
        return intervalos
    }

    nonisolated static func estruturar(_ texto: String) -> String {
        var temTitulo = false
        // a última linha do bloco de cima: abaixo de «Comprar» o item pode ter mais palavras
        var anterior = ""
        var mudancas: [(Range<String.Index>, String)] = []
        for (indice, intervalo) in intervalosParaVestir(texto).enumerated() {
            let bloco = texto[intervalo].split(whereSeparator: \.isNewline).map(String.init)
            defer { anterior = bloco.last ?? "" }
            // bloco que já carrega forma/marca é escolha do autor — não se toca.
            // A exceção é a linha de ITENS vestida de cabeçalho: «## Leite ,
            // farinha , ovo , macarrão , queijo» (dono, 17/09, no iPhone) ficava
            // SEÇÃO para sempre, porque a forma nunca revisita o que já tem
            // marca. Cabeçalho com três ou mais itens separados por vírgula
            // nunca foi escolha de ninguém — vira lista, com a marca da cabeça
            // de cima.
            if bloco.contains(where: jaVestida) {
                if bloco.count == 1, let itens = itensDoCabecalho(bloco[0], abaixoDe: anterior) {
                    let marca = marcaDoItem(cabeca: anterior)
                    mudancas.append((intervalo, itens.map { marca + $0 }.joined(separator: "\n")))
                    continue
                }
                if bloco.count == 1, bloco[0].trimmingCharacters(in: .whitespaces).hasPrefix("#") {
                    temTitulo = true
                }
                continue
            }
            // a linha longa de compras também é lista: sem isto o bloco não
            // passava do portão da linha curta e a nota ficava crua
            if bloco.count >= 2,
               bloco.allSatisfy({ curtaSemPonto($0) || itensDaEnumeracao($0, abaixoDe: anterior) != nil }) {
                // linhas curtas paralelas = lista: cada uma vira item, com a
                // cabeça que `cabecaEItens` reconhece (título ou seção)
                let partida = cabecaEItens(bloco, abreANota: indice == 0 && !temTitulo, abaixoDe: anterior)
                let topo = partida.cabeca.map { [(temTitulo ? "## " : "# ") + $0] } ?? []
                if partida.cabeca != nil { temTitulo = true }
                let marca = marcaDoItem(cabeca: partida.cabeca ?? anterior)
                mudancas.append((intervalo, (topo + partida.itens.map { marca + $0 }).joined(separator: "\n")))
                continue
            }
            // «Comprar: leite, pão, café»: a cabeça fica, os itens nascem
            if bloco.count == 1, let partida = cabecaEItensNaLinha(bloco[0]) {
                let topo = (temTitulo ? "## " : "# ") + partida.cabeca
                temTitulo = true
                let marca = marcaDoItem(cabeca: partida.cabeca)
                mudancas.append((intervalo, ([topo] + partida.itens.map { marca + $0 }).joined(separator: "\n")))
                continue
            }
            if bloco.count == 1, curtaSemPonto(bloco[0]) || itensDaEnumeracao(bloco[0], abaixoDe: anterior) != nil {
                // uma linha de itens («Leite , farinha , ovo») é lista, um item
                // por linha — nunca título nem seção (dono, 17/09: a linha das
                // compras virou SEÇÃO)
                if let itens = itensDaEnumeracao(bloco[0], abaixoDe: anterior) {
                    let marca = marcaDoItem(cabeca: anterior)
                    mudancas.append((intervalo, itens.map { marca + $0 }.joined(separator: "\n")))
                    continue
                }
                // linha curta sozinha = título (a primeira) ou seção (as demais)
                let t = bloco[0].trimmingCharacters(in: .whitespaces)
                mudancas.append((intervalo, temTitulo ? "## " + t : "# " + t))
                temTitulo = true
                continue
            }
        }
        var saida = texto
        for (intervalo, vestido) in mudancas.reversed() { saida.replaceSubrange(intervalo, with: vestido) }
        // dar forma também enxuga o vão que cresceu antes desta volta
        return enxugarVaos(saida)
    }

    /// Uma linha de itens («Leite , farinha , ovo»): dois ou mais separadores —
    /// vírgula ou ponto e vírgula, com ou sem espaço em volta — e nenhum item
    /// vazio. Devolve os itens na ordem, sem os separadores e com as palavras
    /// como o autor as escreveu. Vírgula entre dois algarismos é decimal
    /// («1,5 kg») e não separa. Um lugar só: a regra local (`estruturar`), a
    /// forma da IA (`Sabia.aplicar`) e o Destaque (`AnaliseLocal.listaSemDia`).
    ///
    /// Revisão, 17/09: contar vírgulas partia frases e apagava as vírgulas do
    /// autor («Hoje, cedo, fui ao mercado» virava três itens). Não é lista a
    /// linha longa, a que termina como frase, a fala («disse: sim, não»), a que
    /// tem separador dentro de parênteses ou aspas, nem a que tem item de mais
    /// de duas palavras — quatro logo abaixo de uma cabeça de lista
    /// (`cabecaDeLista`), onde «pasta de dente, sabão em pó» é compra.
    /// ponytail: conta palavras, não lê gramática; «Hoje, amanhã, depois» ainda é lista.
    nonisolated static func itensDaEnumeracao(_ linha: String, abaixoDe anterior: String = "") -> [String]? {
        let t = linha.trimmingCharacters(in: .whitespaces)
        // «Comprar: leite, pão, café» numa linha só: a cabeça está aqui dentro
        // (auditoria 17/09 — a linha inteira virava TÍTULO, sem bolinha nenhuma)
        if let dois = t.firstIndex(of: ":"), cabecaDeLista(String(t[..<dois])) {
            let resto = String(t[t.index(after: dois)...])
            return itensDaEnumeracao(resto, abaixoDe: String(t[..<dois]))
        }
        // debaixo de uma cabeça de compras a linha pode ser longa: o teto de 60
        // é o da linha curta de título, e uma compra de sete itens passa dele
        let teto = cabecaDeLista(anterior) ? 200 : 60
        guard t.count <= teto, !t.contains(":"), let ultimo = t.last, !".!?…".contains(ultimo) else { return nil }
        let cs = Array(t)
        var itens = [""]
        var fundo = 0
        var aspas = false
        for (k, c) in cs.enumerated() {
            if "([{«“".contains(c) { fundo += 1 } else if ")]}»”".contains(c) { fundo -= 1 } else if c == "\"" { aspas.toggle() }
            let decimal = c == "," && k > 0 && k + 1 < cs.count && cs[k - 1].isNumber && cs[k + 1].isNumber
            guard c == "," || c == ";", !decimal else { itens[itens.count - 1].append(c); continue }
            // «Comprar (leite, pão), ovo»: a vírgula de dentro não separa a linha
            guard fundo == 0, !aspas else { return nil }
            itens.append("")
        }
        let tetoDePalavras = cabecaDeLista(anterior) ? 4 : 2
        let limpos = itens.map { $0.trimmingCharacters(in: .whitespaces) }
        guard limpos.count >= 3,
              limpos.allSatisfy({ !$0.isEmpty && $0.split(whereSeparator: \.isWhitespace).count <= tetoDePalavras })
        else { return nil }
        return limpos
    }

    /// A cabeça de COMPRA, sem o genérico «Lista de…»: «Comprar», «Compras do
    /// mês», «Mercado», «Feira», «Supermercado». Serve para a decisão
    /// DESTRUTIVA — soltar o método vestido numa nota antiga —, onde «Lista de
    /// coisas para decidir» não pode contar: é lista, mas é matéria de método
    /// (auditoria de produção, 17/09). Para a MARCA do item continua valendo a
    /// `cabecaDeLista`, mais larga: bolinha numa lista qualquer é boa.
    nonisolated static func cabecaDeCompras(_ linha: String) -> Bool {
        linha.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespaces)
            .contains(regex: #"^(#+\s*)?(comprar|compras|mercado|supermercado|feira)(\s+(de|do|da|dos|das|no|na|nos|nas|em|pra|para|pro)\b.*)?\s*:?$"#)
    }

    /// A cabeça de uma lista de compras ou de itens: «Comprar», «Compras:»,
    /// «Compras do mês», «Comprar no mercado», «Mercado», «Lista de…», com ou
    /// sem `#`. «Comprar café» é um afazer, não cabeça. Um lugar só: a
    /// enumeração (`itensDaEnumeracao`) e o Destaque (`AnaliseLocal.listaSemDia`).
    nonisolated static func cabecaDeLista(_ linha: String) -> Bool {
        linha.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespaces)
            .contains(regex: #"^(#+\s*)?(comprar|compras|mercado|supermercado|feira|lista)(\s+(de|do|da|dos|das|no|na|nos|nas|em|pra|para|pro)\b.*)?\s*:?$"#)
    }

    /// O conserto da nota que uma volta anterior vestiu errado: a linha de
    /// itens que ficou de cabeçalho volta a ser lista e o vão que cresceu
    /// enxuga. Só isso — dar forma ao que o autor deixou em prosa é trabalho do
    /// «Concluir», e a varredura do arranque não decide por ele.
    /// O mesmo texto com todo visto em branco: serve para comparar duas versões
    /// e saber se a ÚNICA diferença foi marcar itens (marcar não é uma versão
    /// nova do texto — «Alterações» enchia de linhas iguais, uma por bolinha
    /// tocada no mercado).
    nonisolated static func semVistos(_ texto: String) -> String {
        texto.replacingOccurrences(of: "- [x] ", with: "- [ ] ")
            .replacingOccurrences(of: "- [X] ", with: "- [ ] ")
            .replacingOccurrences(of: "* [x] ", with: "* [ ] ")
            .replacingOccurrences(of: "* [X] ", with: "* [ ] ")
    }

    /// O que o campo do título una grava quando o Enter desce para o corpo:
    /// título, e o resto só se houver resto. Era aqui que a nota engordava —
    /// o campo punha `"\n\n"` e `aplicar` punha outro, duas linhas em branco
    /// por Enter (dono, 17/09: 43 linhas em branco na nota «Comprar»).
    nonisolated static func tituloComResto(_ bloco: BlocoCaderno, resto: String) -> String {
        let limpo = resto.trimmingCharacters(in: .whitespacesAndNewlines)
        return serializar(bloco) + (limpo.isEmpty ? "" : "\n\n" + resto)
    }

    nonisolated static func consertarVestidoErrado(_ texto: String) -> String {
        var anterior = ""
        var mudancas: [(Range<String.Index>, String)] = []
        for intervalo in intervalosParaVestir(texto) {
            let bloco = texto[intervalo].split(whereSeparator: \.isNewline).map(String.init)
            defer { anterior = bloco.last ?? "" }
            guard bloco.count == 1, let itens = itensDoCabecalho(bloco[0], abaixoDe: anterior) else { continue }
            let marca = marcaDoItem(cabeca: anterior)
            mudancas.append((intervalo, itens.map { marca + $0 }.joined(separator: "\n")))
        }
        var saida = texto
        for (intervalo, novo) in mudancas.reversed() { saida.replaceSubrange(intervalo, with: novo) }
        return enxugarVaos(saida)
    }

    /// Os itens escondidos num cabeçalho: «## Leite , farinha , ovo» é uma
    /// linha de itens que alguém marcou de seção (a forma da IA, 17/09; o
    /// modelo tem licença de dizer «secao» e disse). `nil` quando o cabeçalho
    /// é cabeçalho de verdade. Um lugar só: a regra local (`estruturar`) e a
    /// recusa do mapa da IA (`Sabia.vestir`).
    nonisolated static func itensDoCabecalho(_ linha: String, abaixoDe anterior: String = "") -> [String]? {
        let t = linha.trimmingCharacters(in: .whitespaces)
        guard t.hasPrefix("#") else { return nil }
        let corpo = t.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
        guard !corpo.isEmpty else { return nil }
        return itensDaEnumeracao(corpo, abaixoDe: anterior)
    }

    /// A nota que é só cabeça e itens: título, seção, lista, tarefa e linha em
    /// branco, nada mais. É o que sobrevive ao vestir — depois de a forma
    /// partir «leite, pão, café» em três itens, não há mais vírgula para
    /// reconhecer, e a nota de compras voltava a ganhar «A única coisa de hoje»
    /// (auditoria 17/09).
    nonisolated static func soCabecaEItens(_ texto: String) -> Bool {
        let blocos = fatias(texto).map(\.bloco)
        var temItens = false
        for bloco in blocos {
            switch bloco {
            case .itens, .tarefas: temItens = true
            case .titulo: continue
            case .paragrafo(let t) where t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty: continue
            default: return false
            }
        }
        return temItens
    }

    /// A marca com que um item nasce. Debaixo de «Comprar», «Compras»,
    /// «Mercado», «Lista de…» (`cabecaDeLista`), o item é para RISCAR: nasce
    /// tarefa, com a bolinha que vira visto verde ao toque — dono, 17/09: «uma
    /// bolinha que, ao colocar no carrinho, eu aperto e ela vira um check
    /// verde, e o item é riscado». Fora dessas cabeças, item de lista.
    /// Um lugar só: a regra local (`estruturar`) e a forma da IA (`Sabia.aplicar`).
    nonisolated static func marcaDoItem(cabeca: String?) -> String {
        cabecaDeLista(cabeca ?? "") ? "- [ ] " : "- "
    }

    /// A cabeça e os itens de UMA linha: «Comprar: leite, pão, café» devolve
    /// («Comprar», [leite, pão, café]). `nil` quando não há cabeça na linha.
    nonisolated static func cabecaEItensNaLinha(_ linha: String) -> (cabeca: String, itens: [String])? {
        let t = linha.trimmingCharacters(in: .whitespaces)
        guard let dois = t.firstIndex(of: ":") else { return nil }
        let cabeca = String(t[..<dois]).trimmingCharacters(in: .whitespaces)
        guard cabecaDeLista(cabeca), let itens = itensDaEnumeracao(String(t[t.index(after: dois)...]), abaixoDe: cabeca)
        else { return nil }
        return (cabeca, itens)
    }

    /// Cabeça e itens de um bloco de linhas sem marca — a mesma leitura na
    /// regra local (`estruturar`) e na forma de itens da IA (`Sabia.aplicar`).
    /// A primeira linha é cabeça quando a de baixo é uma lista numa linha
    /// («Comprar / Leite , farinha , ovo» com um Enter só, dono, 17/09) ou
    /// quando o bloco abre a nota com três ou mais linhas curtas («Plano de
    /// sábado / comprar pão / ligar…», dono, 14/09). Cada lista numa linha vira
    /// os seus itens; as outras linhas são um item cada.
    nonisolated static func cabecaEItens(_ linhas: [String], abreANota: Bool,
                                         abaixoDe anterior: String) -> (cabeca: String?, itens: [String]) {
        let l = linhas.map { $0.trimmingCharacters(in: .whitespaces) }
        func itens(_ k: Int, _ cabeca: String) -> [String]? { itensDaEnumeracao(l[k], abaixoDe: cabeca) }
        let temCabeca = l.count >= 2 && itens(0, anterior) == nil
            && (itens(1, l[0]) != nil || abreANota && l.count >= 3 && l.allSatisfy(curtaSemPonto))
        // com cabeça, ela vale para TODAS as linhas: a segunda linha de compras
        // («pasta de dente, sabão em pó») não partia porque olhava a linha de
        // cima em vez da cabeça (auditoria 17/09)
        let cabeca = temCabeca ? l[0] : anterior
        return (temCabeca ? l[0] : nil,
                l.indices.dropFirst(temCabeca ? 1 : 0).flatMap { itens($0, cabeca) ?? [l[$0]] })
    }

    /// Linha curta e sem pontuação de fim de frase: candidata a título ou item.
    nonisolated private static func curtaSemPonto(_ linha: String) -> Bool {
        let t = linha.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty, t.count <= 60, let ultimo = t.last else { return false }
        return ultimo != "." && ultimo != "!" && ultimo != "?"
    }

    /// A linha já traz forma (mobiliário, marcador de lista/título/tarefa,
    /// tabela, numerada): vestir de novo dobraria a marca ou mentiria a voz.
    nonisolated private static func jaVestida(_ linha: String) -> Bool {
        let t = linha.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return false }
        if temMarca(t) { return true }
        for p in ["#", "- ", "* ", "> ", "|", "```", "~~~", ":::", "- [", "* ["] where t.hasPrefix(p) {
            return true
        }
        if t == "-" || t == "*" { return true }
        // numerada: "3." ou "3. algo"
        if let ponto = t.firstIndex(of: "."), ponto != t.startIndex,
           t[..<ponto].allSatisfy(\.isNumber) {
            return true
        }
        return false
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

    /// Vão de mais de uma linha em branco não existe no caderno: o que separa
    /// dois blocos é UMA linha em branco. A nota «Comprar» do dono chegou a 43
    /// linhas em branco entre o título e a lista (17/09, no iPhone): cada Enter
    /// no título una somava duas — o `"\n\n"` do campo mais o `"\n\n"` com que
    /// `aplicar` junta as partes. Dentro de código cercado ou de um recipiente
    /// (`:::`) a linha vazia é conteúdo do autor e fica — o fuzz do caderno
    /// pegou o verso com linhas em branco no meio.
    nonisolated static func enxugarVaos(_ texto: String) -> String {
        guard texto.contains("\n\n\n") else { return texto }
        var saida: [String] = []
        var vazias = 0
        var dentroDeCodigo = false
        for linha in texto.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
            let t = linha.trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("```") || t.hasPrefix("~~~") || t == ":::" || t.hasPrefix(":::") {
                dentroDeCodigo.toggle()
                vazias = 0
                saida.append(linha)
                continue
            }
            if dentroDeCodigo {
                vazias = 0
                saida.append(linha)
                continue
            }
            if t.isEmpty {
                vazias += 1
                if vazias > 1 { continue }
            } else {
                vazias = 0
            }
            saida.append(linha)
        }
        return saida.joined(separator: "\n")
    }

    nonisolated static func aplicar(_ fatias: [FatiaCaderno], id: String, novo: String) -> String {
        // O `fonte` de uma fatia inclui as linhas em branco que vêm DEPOIS dela
        // (`depoisDeVazias`), e o `joined` abaixo põe o separador outra vez: sem
        // tirar o rabo em branco, cada gravação somava uma linha em branco — a
        // nota «Comprar» do dono chegou a 43 (17/09). O que está DENTRO do bloco
        // não se toca (o verso com linha em branco no meio é do autor).
        var partes = fatias.map { $0.id == id ? novo : $0.fonte }
            .map { parte in String(parte.reversed().drop(while: { $0.isNewline }).reversed()) }
        while partes.last?.isEmpty == true {
            partes.removeLast()
        }
        // "\n\n", não "\n": a linha em branco é o que SEPARA dois parágrafos —
        // e `enxugarVaos` garante que ela seja UMA, senão o vão cresce a cada
        // gravação (dono, 17/09: 43 linhas em branco na nota «Comprar»).
        // Com um \n só, trocar uma fatia por ELA MESMA fundia os parágrafos do
        // autor num só — bastava tocar um chip ou editar um bloco para a nota
        // perder a divisão que ele escreveu. Entre blocos a linha em branco é
        // sempre segura; o que ela não pode é faltar.
        return partes.joined(separator: "\n\n")
    }

    nonisolated static func prosa(de markdown: String, semCitacao: Bool = false) -> String {
        fatias(markdown).compactMap { fatia -> String? in
            switch fatia.bloco {
            case .paragrafo(let t), .titulo(_, let t):
                return t
            case .citacao(let xs):
                return semCitacao ? nil : xs.joined(separator: "\n")
            case .itens(let xs, _):
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
        .map { semReferenciaInterna($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }

    /// A defesa mora na FRONTEIRA, não na sorte de o parser reconhecer cada
    /// forma de anexo. `prosa` é o que viaja para a rede: uma referência interna
    /// que escapou do parser (import de .md com o link quebrado, por exemplo)
    /// sairia daqui como se fosse a voz do autor.
    nonisolated static func semReferenciaInterna(_ s: String) -> String {
        guard s.contains("traco://") else { return s }
        return s
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.contains("traco://") ? "" : String($0) }
            .joined(separator: "\n")
    }

    nonisolated static func visivel(_ fonte: String) -> String {
        fatias(fonte).map { semReferenciaInterna(textoVisivel($0.bloco)) }.joined(separator: "\n")
    }

    /// Só prosa e lista: o ÚNICO terreno onde a edição crua nunca expõe
    /// mobiliário markdown (o autor jamais vê ```/traco:///:::/>).
    nonisolated static func soProsaELista(_ fonte: String) -> Bool {
        // O portão e a definição de "marca" precisam CONCORDAR. Uma linha ":::"
        // solta, ou um "traco://" que escapou do parser, vira parágrafo comum —
        // o portão abria e o autor via mobiliário na cara. A lei é: se há marca
        // em qualquer lugar do texto, a edição crua não abre.
        if temMarca(fonte) { return false }
        return fatias(fonte).allSatisfy {
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
        case .paragrafo: return u
        // título de UMA linha é una (o "#" digitado à mão precisa de campo
        // vivo; o parser preserva o espaço à cauda). Qualquer \n na fonte é o
        // autor descendo para o corpo: multi-bloco, com a cauda aberta — sem
        // isso a nota só-título era armadilha (todo toque editava o título).
        case .titulo: return fonte.contains("\n") ? nil : u
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
        // O Enter já pôs o marcador e o autor digitou o seu por cima: "- - "
        // vira "- " (dono, 17/09: «- - pao» na lista). Vale para o espaço que
        // fecha o marcador repetido, logo no começo da linha.
        if i < ns.count, ns[i] == " ", Array(ns[(i + 1)...]) == Array(vs[i...]) {
            let antesDoEspaco = String(ns[..<i])
            let inicio = antesDoEspaco.lastIndex(of: "\n").map { antesDoEspaco.index(after: $0) } ?? antesDoEspaco.startIndex
            let linha = String(antesDoEspaco[inicio...]) + " "
            for (dobrado, simples) in [("- - ", "- "), ("* * ", "* "), ("- [ ] - ", "- [ ] "), ("- [ ] - [ ] ", "- [ ] ")]
            where linha == dobrado {
                return String(antesDoEspaco[..<inicio]) + simples + String(ns[(i + 1)...])
            }
            if let m = linha.firstMatch(of: /^(\d+)\. (\d+)\. $/), m.1 == m.2 {
                return String(antesDoEspaco[..<inicio]) + "\(m.1). " + String(ns[(i + 1)...])
            }
        }
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
    nonisolated private static let regexLock = NSLock()

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
