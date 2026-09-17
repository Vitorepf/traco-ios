import Foundation
import SwiftUI

enum PapelSintaxe: Sendable {
    case texto, chave, valor, numero, comentario, tipo, funcao, pontuacao
}

enum SintaxeLocal: Sendable {
    nonisolated static func pintar(_ fonte: String, lingua: String) -> [(String, PapelSintaxe)] {
        let linhas = fonte.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var saida: [(String, PapelSintaxe)] = []
        for (i, linha) in linhas.enumerated() {
            if i > 0 { saida.append(("\n", .texto)) }
            saida.append(contentsOf: pintarLinha(linha, lingua: lingua.lowercased()))
        }
        return saida.isEmpty ? [("", .texto)] : saida
    }

    nonisolated static func cor(_ papel: PapelSintaxe) -> Color {
        switch papel {
        // os mesmos hex do Tema (nonisolated: o Tema é MainActor)
        case .texto: Color(claro: 0x1C1C1E, escuro: 0xE9E9EC)
        case .chave: Color(claro: 0x7A4E10, escuro: 0xC0954E)
        case .valor: Color(claro: 0x1F6B5A, escuro: 0x4FAE90)
        case .numero: Color(claro: 0x2F4F8A, escuro: 0x7E9CCE)
        case .comentario: Color(claro: 0x86868B, escuro: 0x8A8A92)
        case .tipo: Color(claro: 0x5A3D7A, escuro: 0xA88CD0)
        case .funcao: Color(claro: 0x245A66, escuro: 0x6EA8B6)
        case .pontuacao: Color(claro: 0x6E6E73, escuro: 0x8A8A92)
        }
    }

    nonisolated static func rotulo(_ lingua: String) -> String {
        switch lingua.lowercased() {
        case "js", "javascript": "JavaScript"
        case "ts", "typescript": "TypeScript"
        case "py", "python": "Python"
        case "rb", "ruby": "Ruby"
        case "sh", "bash", "zsh", "shell": "Shell"
        case "yml": "YAML"
        case "c++", "cpp": "C++"
        case "cs", "csharp": "C#"
        case "kt", "kotlin": "Kotlin"
        case "md", "markdown": "Markdown"
        case "texto", "text", "plain": "Texto"
        default: lingua.isEmpty ? "Texto" : lingua
        }
    }

    nonisolated private static func pintarLinha(_ linha: String, lingua: String) -> [(String, PapelSintaxe)] {
        let t = linha.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("//") || t.hasPrefix("///") || t.hasPrefix("<!--") || t.hasPrefix("-- ") || t.hasPrefix("/*") {
            return [(linha, .comentario)]
        }
        if comentarioPorHash(lingua), t.hasPrefix("#"), !t.hasPrefix("#include"), !t.hasPrefix("#if") {
            return [(linha, .comentario)]
        }
        if lingua == "json" { return json(linha) }
        return generica(linha, lingua: lingua)
    }

    nonisolated private static func comentarioPorHash(_ lingua: String) -> Bool {
        ["python", "py", "bash", "sh", "zsh", "shell", "yaml", "yml", "ruby", "rb", "toml"].contains(lingua)
    }

    nonisolated private static func json(_ linha: String) -> [(String, PapelSintaxe)] {
        var out: [(String, PapelSintaxe)] = []
        var i = linha.startIndex
        while i < linha.endIndex {
            if linha[i] == "\"" {
                let (token, next) = string(linha, de: i)
                let resto = linha[next...].trimmingCharacters(in: .whitespaces)
                out.append((token, resto.hasPrefix(":") ? .chave : .valor))
                i = next
                continue
            }
            if linha[i].isNumber || (linha[i] == "-" && proximoNumero(linha, i)) {
                let (token, next) = numero(linha, de: i)
                out.append((token, .numero))
                i = next
                continue
            }
            out.append((String(linha[i]), pontuacao(linha[i]) ? .pontuacao : .texto))
            i = linha.index(after: i)
        }
        return out
    }

    nonisolated private static func generica(_ linha: String, lingua: String) -> [(String, PapelSintaxe)] {
        let palavras = chaves(lingua)
        let tipos = tipos(lingua)
        let segueFuncao: Set<String> = ["func", "def", "fn", "function", "fun"]
        var out: [(String, PapelSintaxe)] = []
        var i = linha.startIndex
        var anterior: String = ""

        while i < linha.endIndex {
            if linha[i] == "\"" || linha[i] == "'" {
                let (token, next) = string(linha, de: i)
                out.append((token, .valor))
                anterior = ""
                i = next
                continue
            }
            if linha[i].isNumber {
                let (token, next) = numero(linha, de: i)
                out.append((token, .numero))
                anterior = token
                i = next
                continue
            }
            if linha[i].isLetter || linha[i] == "_" {
                var j = i
                while j < linha.endIndex, linha[j].isLetter || linha[j].isNumber || linha[j] == "_" {
                    j = linha.index(after: j)
                }
                let w = String(linha[i..<j])
                let papel: PapelSintaxe
                if palavras.contains(w) {
                    papel = .chave
                } else if tipos.contains(w) {
                    papel = .tipo
                } else if segueFuncao.contains(anterior) {
                    papel = .funcao
                } else if w.first?.isUppercase == true, lingua == "swift" || lingua == "kotlin" {
                    papel = .tipo
                } else {
                    papel = .texto
                }
                out.append((w, papel))
                anterior = w
                i = j
                continue
            }
            out.append((String(linha[i]), pontuacao(linha[i]) ? .pontuacao : .texto))
            if !linha[i].isWhitespace { anterior = "" }
            i = linha.index(after: i)
        }
        return out
    }

    nonisolated private static func string(_ linha: String, de i: String.Index) -> (String, String.Index) {
        let q = linha[i]
        var j = linha.index(after: i)
        var escape = false
        while j < linha.endIndex {
            if escape {
                escape = false
                j = linha.index(after: j)
                continue
            }
            if linha[j] == "\\" { escape = true; j = linha.index(after: j); continue }
            if linha[j] == q {
                j = linha.index(after: j)
                break
            }
            j = linha.index(after: j)
        }
        return (String(linha[i..<j]), j)
    }

    nonisolated private static func numero(_ linha: String, de i: String.Index) -> (String, String.Index) {
        var j = i
        if linha[j] == "-" { j = linha.index(after: j) }
        while j < linha.endIndex, linha[j].isNumber || linha[j] == "." || linha[j] == "_" {
            j = linha.index(after: j)
        }
        return (String(linha[i..<j]), j)
    }

    nonisolated private static func proximoNumero(_ linha: String, _ i: String.Index) -> Bool {
        let n = linha.index(after: i)
        return n < linha.endIndex && linha[n].isNumber
    }

    nonisolated private static func pontuacao(_ ch: Character) -> Bool {
        "{}[]().,;:".contains(ch)
    }

    nonisolated private static func chaves(_ lingua: String) -> Set<String> {
        switch lingua {
        case "swift":
            ["func", "let", "var", "if", "else", "guard", "return", "struct", "enum", "class",
             "import", "private", "public", "static", "switch", "case", "for", "while", "in",
             "true", "false", "nil", "self", "some", "any", "async", "await", "try", "throws",
             "protocol", "extension", "where", "init", "override", "final", "mutating"]
        case "js", "javascript", "ts", "typescript":
            ["function", "const", "let", "var", "if", "else", "return", "class", "import",
             "export", "from", "async", "await", "true", "false", "null", "undefined", "new",
             "typeof", "of", "in", "switch", "case", "break", "for", "while"]
        case "python", "py":
            ["def", "class", "if", "else", "elif", "return", "import", "from", "as", "for",
             "in", "while", "True", "False", "None", "with", "try", "except", "async", "await",
             "yield", "lambda", "pass", "not", "and", "or"]
        case "rust":
            ["fn", "let", "mut", "if", "else", "return", "struct", "enum", "impl", "pub",
             "use", "true", "false", "match", "async", "await", "mod", "crate", "self"]
        case "go":
            ["func", "var", "const", "if", "else", "return", "struct", "type", "import",
             "package", "for", "range", "true", "false", "nil", "defer", "go", "chan"]
        case "kotlin", "kt":
            ["fun", "val", "var", "if", "else", "return", "class", "object", "when",
             "true", "false", "null", "suspend", "override"]
        case "java":
            ["class", "void", "public", "private", "static", "return", "if", "else", "new",
             "true", "false", "null", "import", "package", "final"]
        case "sql":
            ["SELECT", "FROM", "WHERE", "AND", "OR", "INSERT", "INTO", "UPDATE", "SET",
             "DELETE", "JOIN", "ON", "AS", "NULL", "CREATE", "TABLE", "select", "from",
             "where", "join"]
        case "html", "xml":
            ["div", "span", "html", "head", "body", "script", "style", "class", "id", "href",
             "src", "type", "const"]
        case "css":
            ["color", "background", "display", "flex", "grid", "margin", "padding", "border",
             "font", "width", "height", "position", "important"]
        default:
            ["func", "function", "def", "class", "return", "if", "else", "const", "let", "var",
             "true", "false", "null", "import"]
        }
    }

    nonisolated private static func tipos(_ lingua: String) -> Set<String> {
        switch lingua {
        case "swift":
            ["String", "Int", "Double", "Bool", "Array", "Dictionary", "Optional", "Any",
             "Void", "Error", "Data", "URL", "Date", "CGFloat", "View", "Color"]
        case "ts", "typescript":
            ["string", "number", "boolean", "void", "any", "never", "unknown"]
        case "python", "py":
            ["str", "int", "float", "bool", "list", "dict", "None"]
        case "go":
            ["string", "int", "int64", "bool", "error", "byte"]
        case "rust":
            ["String", "str", "i32", "i64", "u32", "bool", "Vec", "Option", "Result"]
        default:
            []
        }
    }
}
