import Foundation
func comTinta(_ s: String) -> Int {
    s.unicodeScalars.lazy.filter { !CharacterSet.whitespacesAndNewlines.contains($0) }.count
}
func cabecalhos(_ s: String) -> Int {
    let linhas = s.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
    var n = 0
    for (i, linha) in linhas.enumerated() where linha == "---" {
        var j = i + 1
        if j < linhas.count, linhas[j].hasPrefix("id: ") { j += 1 }
        if j < linhas.count, linhas[j].hasPrefix("criada: ") { n += 1 }
    }
    return n
}
// um corpus de 2000 notas, como o export real
var blocos: [String] = []
for i in 0..<2000 {
    blocos.append("---\nid: \(UUID().uuidString)\ncriada: 2026-09-0\(i % 9 + 1)T10:00:00Z\neditada: 2026-09-09T10:00:00Z\nrecordada: 0\n---\n\ntrês temas voltam e o autor escreve umas quatro linhas sobre eles, com vírgulas, acentuação e um parágrafo a mais para o arquivo ter tamanho de verdade.\n")
}
let corpus = blocos.joined(separator: "\n")
print("bytes: \(corpus.utf8.count)")
func tintaEscalarProp(_ s: String) -> Int {
    s.unicodeScalars.lazy.filter { !$0.properties.isWhitespace }.count
}
func tintaCaractere(_ s: String) -> Int { s.lazy.filter { !$0.isWhitespace }.count }
func tintaUTF8(_ s: String) -> Int {
    var n = 0
    for b in s.utf8 where b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09 { n += 1 }
    return n
}
let provas: [(String, (String) -> Int)] = [
    ("comTinta (CharacterSet)", comTinta), ("escalar.properties  ", tintaEscalarProp),
    ("Character.isWhitespace", tintaCaractere), ("byte UTF-8          ", tintaUTF8),
    ("cabecalhos          ", cabecalhos),
]
for (nome, fn) in provas {
    var soma = 0
    let t0 = Date()
    for _ in 0..<10 { soma += fn(corpus) }
    let ms = Date().timeIntervalSince(t0) * 1000 / 10
    print(String(format: "%@: %6.1f ms  (resultado %d)", nome, ms, soma / 10))
}
