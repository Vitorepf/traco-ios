// Reprodução da dívida P0-IRMÃOS-CRLF (RUMO, 10/09). Roda com: swift crlf-irmaos.swift
//
// Só o `split(separator: "\n")` é cego a CRLF: ele resolve para
// `split(separator: Character)` e em texto CRLF o Character é "\r\n".
// `components(separatedBy:)` NÃO é cego — a busca do Foundation é escalar.
//
// Quem consertar os quatro sítios do RUMO tem de fazer esta saída mudar.
import Foundation

/// Cópia fiel de `Sabia.perguntaNaNota` (Sabia.swift:1037) em 10/09.
func perguntaNaNota(_ texto: String) -> String? {
    let linhas = texto.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
    guard let linha = linhas.last(where: { $0.hasPrefix("?") }) else { return nil }
    let corpo = String(linha.dropFirst()).trimmingCharacters(in: .whitespaces)
    return corpo.count >= 4 ? corpo : nil
}

print("— perguntaNaNota, os dois polos —")
print("LF, ? no meio     ->", perguntaNaNota("texto\n? como defino isso\nmais") ?? "nil")
print("CRLF, ? no meio   ->", perguntaNaNota("texto\r\n? como defino isso\r\nmais") ?? "nil",
      "   <- o botão do cartão SOME")
let comecaComPergunta = "? como defino isso\r\nresto da nota do autor\r\nmais uma linha"
print("CRLF, ? no topo   ->", (perguntaNaNota(comecaComPergunta) ?? "nil").debugDescription,
      "\n                     <- a NOTA INTEIRA viaja como a pergunta")

print("\n— quem é cego, e quem não é —")
let n = "primeira\r\n\r\nterceira\r\nquarta"   // quatro linhas, uma em branco
print("components(\"\\n\")                    :", n.components(separatedBy: "\n").count, "  (não é cego)")
print("split(separator: \"\\n\")              :", n.split(separator: "\n").count, "  <- CEGO")
print("split(whereSeparator: .isNewline)   :", n.split(whereSeparator: \.isNewline).count,
      "  (some a linha em branco)")
print("split(omittingEmpty: false, ...)    :",
      n.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).count,
      "  <- o certo onde o NÚMERO da linha importa")
