// Harness do P0-CRLF. `Antes` são as linhas 304-358 de Corpus.swift em HEAD
// (366e609) e `Depois` as linhas 309-393 da árvore de trabalho, COPIADAS
// VERBATIM — só um stub para Gesto.doNome. Nenhuma linha de medida foi
// ajustada para o conserto passar.
import Foundation

enum OrigemNota: String { case autor, grokbot, pesquisa }
struct GestoStub { let conhecido: Bool }
enum Gesto { static func doNome(_ n: String) -> GestoStub? { nil } }
typealias ItemImportado = (texto: String, gestoNome: String?, criadaEm: Date, origem: OrigemNota)

enum Antes {
    nonisolated static func importarComEstado(_ conteudo: String) -> (
        itens: [ItemImportado], contemProtegida: Bool
    ) {
        let f = ISO8601DateFormatter()
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\n(?:id: \S+\n)?criada: (\S+)\n(?:editada: \S+\n)?(?:gesto: (.+)\n)?(?:metodo: (\S+)\n)?"#)
        let ns = conteudo as NSString
        let hits = padrao.matches(in: conteudo, range: NSRange(location: 0, length: ns.length))
        guard !hits.isEmpty else {
            let limpo = conteudo.trimmingCharacters(in: .whitespacesAndNewlines)
            if limpo.isEmpty || limpo.hasPrefix("# Traço") { return ([], false) }
            return ([(limpo, nil, .now, .autor)], false)
        }
        var saida: [ItemImportado] = []
        var contemProtegida = false
        for (i, hit) in hits.enumerated() {
            let inicioBloco = hit.range.location
            let fimBloco = i + 1 < hits.count ? hits[i + 1].range.location : ns.length
            let bloco = ns.substring(with: NSRange(location: inicioBloco, length: fimBloco - inicioBloco))
            // Só o cabeçalho define proteção. Uma frase do corpo (inclusive
            // dentro de campo JSON) pode discutir "estado: selada" livremente.
            let inicioCabecalho = bloco.index(bloco.startIndex, offsetBy: 4)
            guard let fecha = bloco.range(of: "\n---\n", range: inicioCabecalho..<bloco.endIndex) else { continue }
            let cabecalho = bloco[inicioCabecalho..<fecha.lowerBound]
            // ADR 08u: quem escreveu. O regex de cima só casa o prefixo fixo do
            // cabeçalho; a origem sai daqui, onde a ordem das linhas não importa.
            let origem = cabecalho.split(separator: "\n").lazy
                .compactMap { linha -> OrigemNota? in
                    let l = linha.trimmingCharacters(in: .whitespaces)
                    guard l.hasPrefix("origem: ") else { return nil }
                    return OrigemNota(rawValue: String(l.dropFirst(8)).trimmingCharacters(in: .whitespaces))
                }
                .first ?? .autor
            if cabecalho.split(separator: "\n").contains(where: {
                let linha = $0.trimmingCharacters(in: .whitespaces)
                return linha == "estado: selada" || linha == "estado: queimada"
            }) {
                contemProtegida = true
                continue
            }
            let corpo = String(bloco[fecha.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !corpo.isEmpty else { continue }
            let data = f.date(from: ns.substring(with: hit.range(at: 1))) ?? .now
            let nomeDoGesto = hit.range(at: 2).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 2))
                .trimmingCharacters(in: .newlines)
            let idDoMetodo = hit.range(at: 3).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 3))
            // O `metodo:` é a chave estável e vence o nome, que é exibição
            // (ADR 05o). Nome que o catálogo não conhece, sem `metodo:`, NÃO
            // vira id: texto livre de um .md alheio não entra como forma.
            let gestoNome = idDoMetodo
                ?? nomeDoGesto.flatMap { Gesto.doNome($0)?.conhecido == true ? $0 : nil }
            saida.append((corpo, gestoNome, data, origem))
        }
        return (saida, contemProtegida)
    }
}

enum Depois {
    /// ADR 09y: **um arquivo só se apaga quando o app leu tudo o que havia
    /// nele.** `consumido` é essa cobertura — a fração dos caracteres com tinta
    /// do arquivo que viraram nota —, e `podeRetirar` é o único portão que o
    /// coletor lê, para que ninguém o remonte errado do lado de fora. Bloco
    /// recusado pelo selo, cabeçalho que não fecha, corpo vazio, prosa antes do
    /// primeiro cabeçalho: tudo isso deixa a cobertura abaixo de 1, e incerteza
    /// não apaga.
    nonisolated static func importarComEstado(_ conteudo: String) -> (
        itens: [ItemImportado], podeRetirar: Bool, consumido: Double
    ) {
        let f = ISO8601DateFormatter()
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\n(?:id: \S+\n)?criada: (\S+)\n(?:editada: \S+\n)?(?:gesto: (.+)\n)?(?:metodo: (\S+)\n)?"#)
        let ns = conteudo as NSString
        let hits = padrao.matches(in: conteudo, range: NSRange(location: 0, length: ns.length))
        // PORTÃO QUE NÃO ENXERGA FALHA FECHADO (ADR 09y). O regex acima só
        // conhece o fim de linha LF; `cabecalhos` conta A MESMA FORMA partindo
        // por `isNewline`, que enxerga CRLF e CR. Contagens diferentes = existe
        // cabeçalho do Traço que este parser NÃO leu — e um cabeçalho não lido
        // pode ser um selo. Então nada entra como do autor e nada se apaga, em
        // vez de o arquivo inteiro virar uma nota aberta do autor.
        guard cabecalhos(conteudo) == hits.count else { return ([], false, 0) }
        guard !hits.isEmpty else {
            let limpo = conteudo.trimmingCharacters(in: .whitespacesAndNewlines)
            if limpo.isEmpty || limpo.hasPrefix("# Traço") { return ([], false, 0) }
            return ([(limpo, nil, .now, .autor)], true, 1)
        }
        let tinta = comTinta(conteudo)
        var saida: [ItemImportado] = []
        var lidos = 0
        for (i, hit) in hits.enumerated() {
            let inicioBloco = hit.range.location
            let fimBloco = i + 1 < hits.count ? hits[i + 1].range.location : ns.length
            let bloco = ns.substring(with: NSRange(location: inicioBloco, length: fimBloco - inicioBloco))
            // Só o cabeçalho define proteção. Uma frase do corpo (inclusive
            // dentro de campo JSON) pode discutir "estado: selada" livremente.
            let inicioCabecalho = bloco.index(bloco.startIndex, offsetBy: 4)
            guard let fecha = bloco.range(of: "\n---\n", range: inicioCabecalho..<bloco.endIndex) else { continue }
            let cabecalho = bloco[inicioCabecalho..<fecha.lowerBound]
            // ADR 08u: quem escreveu. O regex de cima só casa o prefixo fixo do
            // cabeçalho; a origem sai daqui, onde a ordem das linhas não importa.
            let origem = cabecalho.split(whereSeparator: \.isNewline).lazy
                .compactMap { linha -> OrigemNota? in
                    let l = linha.trimmingCharacters(in: .whitespaces)
                    guard l.hasPrefix("origem: ") else { return nil }
                    return OrigemNota(rawValue: String(l.dropFirst(8)).trimmingCharacters(in: .whitespaces))
                }
                .first ?? .autor
            if cabecalho.split(whereSeparator: \.isNewline).contains(where: {
                let linha = $0.trimmingCharacters(in: .whitespaces)
                return linha == "estado: selada" || linha == "estado: queimada"
            }) {
                continue
            }
            let corpo = String(bloco[fecha.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !corpo.isEmpty else { continue }
            let data = f.date(from: ns.substring(with: hit.range(at: 1))) ?? .now
            let nomeDoGesto = hit.range(at: 2).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 2))
                .trimmingCharacters(in: .newlines)
            let idDoMetodo = hit.range(at: 3).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 3))
            // O `metodo:` é a chave estável e vence o nome, que é exibição
            // (ADR 05o). Nome que o catálogo não conhece, sem `metodo:`, NÃO
            // vira id: texto livre de um .md alheio não entra como forma.
            let gestoNome = idDoMetodo
                ?? nomeDoGesto.flatMap { Gesto.doNome($0)?.conhecido == true ? $0 : nil }
            saida.append((corpo, gestoNome, data, origem))
            lidos += comTinta(bloco)
        }
        return (saida, lidos == tinta, tinta == 0 ? 1 : Double(lidos) / Double(tinta))
    }

    /// Bytes com tinta: tudo que não é espaço, tabulação nem quebra de linha. É
    /// a unidade da cobertura — reindentar um arquivo, ou trocar o fim de linha
    /// dele, não muda o que ele "havia". Contar por byte e não por
    /// `CharacterSet.whitespacesAndNewlines` é 40× mais rápido (medido em
    /// corpus de 562 KB: 0,6 ms contra 23,7 ms) e erra para o lado seguro —
    /// espaço exótico que sobre sem ser lido conta como tinta e segura o
    /// arquivo, que é a direção certa.
    nonisolated private static func comTinta(_ s: String) -> Int {
        var n = 0
        for b in s.utf8 where b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09 { n += 1 }
        return n
    }

    /// Quantos cabeçalhos do Traço o arquivo tem, com QUALQUER fim de linha:
    /// uma linha `---`, o `id:` opcional, e a linha `criada:`. `isNewline`
    /// separa CRLF, CR e LF (em Swift `"\r\n"` é UM `Character`, e por isso
    /// quem parte por `"\n"` lê um arquivo do Windows como uma linha só).
    nonisolated private static func cabecalhos(_ s: String) -> Int {
        let linhas = s.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        var n = 0
        for (i, linha) in linhas.enumerated() where linha == "---" {
            var j = i + 1
            if j < linhas.count, linhas[j].hasPrefix("id: ") { j += 1 }
            if j < linhas.count, linhas[j].hasPrefix("criada: ") { n += 1 }
        }
        return n
    }
}

let sa = "---\ncriada: 2026-09-09T10:00:00Z\norigem: modelo\nestado: selada\n---\n\na dor que ninguem le\n"
let aberta = "---\ncriada: 2026-09-09T10:00:00Z\n---\n\ncorpo aberto\n"
func crlf(_ s: String) -> String { s.replacingOccurrences(of: "\n", with: "\r\n") }
let c = sa.replacingOccurrences(of: "estado: selada\n", with: "estado: selada\r\n")
let d = sa.replacingOccurrences(of: "origem: modelo\n", with: "origem: modelo\r\n")
let e = "# minhas notas de hoje\n\numa linha que so existe aqui\n\n" + aberta
let f = sa.replacingOccurrences(of: "origem: modelo\nestado: selada\n", with: "")
       + "\n" + "---\ncriada: 2026-09-09T11:00:00Z\r\nestado: selada\n---\n\noutra dor\n"
let g = "so uma ideia solta, sem cabecalho nenhum\n"
let h = crlf(aberta)

let casos: [(String, String)] = [
  ("A) LF puro, selada    ", sa), ("B) tudo CRLF, selada  ", crlf(sa)),
  ("C) \\r so no estado    ", c), ("D) \\r so na origem    ", d),
  ("E) prosa antes do 1o  ", e), ("F) misto LF + \\r      ", f),
  ("G) .md sem cabecalho  ", g), ("H) nota ABERTA em CRLF", h),
]
print("caso                   | itens | origem | APAGA? | selo vazou? | consumido")
print("-----------------------|-------|--------|--------|-------------|----------")
for (nome, md) in casos {
    let a = Antes.importarComEstado(md)
    let ors = a.itens.map { $0.origem.rawValue }.joined(separator: ",")
    let vazou = a.itens.contains { $0.texto.contains("dor") }
    print("ANTES  \(nome) | \(a.itens.count)     | \(ors.isEmpty ? "-" : ors)  | \(a.contemProtegida ? "nao" : "SIM")    | \(vazou ? "SIM" : "nao")         | -")
    let p = Depois.importarComEstado(md)
    let ors2 = p.itens.map { $0.origem.rawValue }.joined(separator: ",")
    let vazou2 = p.itens.contains { $0.texto.contains("dor") }
    print("DEPOIS \(nome) | \(p.itens.count)     | \(ors2.isEmpty ? "-" : ors2)  | \(p.podeRetirar ? "SIM" : "nao")    | \(vazou2 ? "SIM" : "nao")         | \(String(format: "%.2f", p.consumido))")
    print("")
}
