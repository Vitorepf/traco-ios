import Foundation

// Réplica fiel de AnaliseLocal.detectarGesto + classificar (prefixos)
struct M: Decodable { let id: String; var roteamento: [String]? }

extension String {
    func has(_ p: String) -> Bool { range(of: p, options: .regularExpression) != nil }
}

let jsonPath = CommandLine.arguments[1]
let metodos = try! JSONDecoder().decode([M].self, from: Data(contentsOf: URL(fileURLWithPath: jsonPath)))

func ePlanoSemObstaculo(_ lower: String) -> Bool {
    let temPlano = lower.has(#"meu plano|vou (conseguir|ser|ficar|ter sucesso)|amanhã (eu )?vou|já me vejo|só (pensar|vibrar) positivo|vai dar certo"#)
    let temObstaculo = lower.has(#"obstáculo|medo|preguiça|hábito|sempre que|mas eu|quando eu|adiar|procrastin|ansiedade|cansaço"#)
    let temWOOP = lower.has(#"(?m)^quero|^preciso começar|^preciso parar|meu objetivo"#)
    return temPlano && !temObstaculo && !temWOOP
}

func detectar(_ x: String, _ lower: String, estrito: Bool) -> String? {
    for m in metodos {
        let r = m.roteamento ?? []
        if r.isEmpty { continue }
        if m.id == "expressiva", x.count <= 120 { continue }
        if r.contains(where: { lower.has($0) }) { return m.id }
    }
    if estrito { return nil }
    let linhas = x.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    if linhas.count >= 3 && linhas.allSatisfy({ $0.count < 60 }) { return "destaque" }
    return nil
}

func classificar(_ texto: String) -> String {
    let bruto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
    if bruto.isEmpty { return "silencio" }
    let lower = bruto.lowercased()
    if lower.has(#"escrev[ae] (por|pra|para) mim|melhore|reescreva|resuma"#) { return "aviso:frasePronta" }
    if lower.has(#"eu sou (rico|um vencedor|incrível|o melhor|imparável)"#) { return "aviso:wood" }
    if lower.has(#"me escuta|me console|desabafar com você|preciso falar com alguém"#) { return "aviso:ouvinte" }
    if let g = detectar(bruto, lower, estrito: false) { return g }
    if ePlanoSemObstaculo(lower) { return "aviso:oettingen" }
    return "silencio"
}

// lê frases da stdin, uma por linha (use \n literal para quebra)
while let linha = readLine(strippingNewline: true) {
    if linha.isEmpty { continue }
    let texto = linha.replacingOccurrences(of: "\\n", with: "\n")
    print("\(classificar(texto))\t[\(texto.count)]\t\(linha.prefix(90))")
}
