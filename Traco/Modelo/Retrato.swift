import Foundation

/// O retrato da mente (ADR 2026-09-04i): o eixo do ciclo. O bloco SOBRE QUEM
/// ESCREVE que viaja com a instigação, a resposta, o contrapor e a prova —
/// montado por algoritmo, só com as palavras do autor e com contagens.
///
/// Não conclui, não diagnostica, não pontua. É a evidência que o papel
/// guarda, posta na frente da IA para ela perguntar melhor. E o Perfil mostra
/// exatamente o que viaja: quem manda texto à rede tem de ver o quê.
nonisolated enum Retrato {
    static let teto = 1500
    static let chaveLigado = "retratoLigado"

    /// Uma nota, sem SwiftData.
    nonisolated struct NotaLida: Sendable {
        var gesto: Gesto?
        var fechada: Bool
        var expressiva: Bool
        var criadaEm: Date
        var campos: [String: String]
    }

    static var ligado: Bool {
        get { UserDefaults.standard.object(forKey: chaveLigado) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: chaveLigado) }
    }

    /// O retrato como texto. Vazio quando não há nada: retrato vazio não viaja.
    nonisolated static func ler(notas: [NotaLida], sinais: [Sinal], agora: Date = .now,
                                cal: Calendar = .current) -> String {
        // o selo corta antes: expressiva, selada e queimada não entram, nem como contagem
        let abertas = notas.filter { !$0.fechada && !$0.expressiva }
        let trintaAtras = cal.date(byAdding: .day, value: -30, to: agora) ?? agora
        var blocos: [String] = []

        var porForma: [String: Int] = [:]
        for n in abertas where n.criadaEm >= trintaAtras {
            porForma[n.gesto?.nome ?? "sem forma", default: 0] += 1
        }
        if !porForma.isEmpty {
            let linha = porForma.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
                .prefix(8).map { "\($0.value) \($0.key)" }.joined(separator: " · ")
            blocos.append("Formas nos últimos 30 dias: \(linha).")
        }

        let obstaculos = ultimos(abertas, gesto: .woop, campo: "obstaculo", quantos: 5)
        if !obstaculos.isEmpty {
            blocos.append("Obstáculos internos que já nomeou: " + obstaculos.map { "“\($0)”" }.joined(separator: "; ") + ".")
        }

        let naoVoltou = sinais.filter { $0.tipo == .naoVoltou }.suffix(5)
        if !naoVoltou.isEmpty {
            let faltou = naoVoltou.reduce(0) { $0 + ($1.faltaram ?? 0) }
            let de = naoVoltou.reduce(0) { $0 + ($1.deQuantos ?? 0) }
            if de > 0 {
                blocos.append("Nas últimas \(naoVoltou.count) provas do Recordar, \(faltou) de \(de) pontos não voltaram.")
            }
        }

        let calibragem = calibrar(abertas)
        if calibragem.total >= 2 {
            blocos.append("Decisões conferidas: \(calibragem.total). O que aconteceu ficou aquém do esperado em \(calibragem.aquem), igual em \(calibragem.igual), além em \(calibragem.alem).")
        }

        let palavras = ultimos(abertas, gesto: .palavra, campo: "minhas", quantos: 5, prefixo: 60)
        if !palavras.isEmpty {
            blocos.append("Palavras que conquistou, nas palavras dele: " + palavras.map { "“\($0)”" }.joined(separator: "; ") + ".")
        }

        let naoServiram = sinais.filter { $0.tipo == .pergunta && $0.serviu == false }
            .compactMap(\.texto).suffix(3)
        if !naoServiram.isEmpty {
            blocos.append("Perguntas que ele marcou como “não serviu” (não repita a classe): " + naoServiram.map { "“\($0)”" }.joined(separator: "; ") + ".")
        }

        let serviram = sinais.filter { $0.tipo == .pergunta && $0.serviu == true }
            .compactMap(\.texto).suffix(2)
        if !serviram.isEmpty {
            blocos.append("Perguntas que serviram: " + serviram.map { "“\($0)”" }.joined(separator: "; ") + ".")
        }

        guard !blocos.isEmpty else { return "" }
        var texto = blocos.joined(separator: "\n")
        if texto.count > teto { texto = String(texto.prefix(teto)).trimmingCharacters(in: .whitespaces) + "…" }
        return texto
    }

    /// Os últimos `quantos` valores literais de um campo, mais recentes primeiro.
    private static func ultimos(_ notas: [NotaLida], gesto: Gesto, campo: String, quantos: Int,
                                prefixo: Int = 120) -> [String] {
        notas.filter { $0.gesto == gesto }
            .sorted { $0.criadaEm > $1.criadaEm }
            .compactMap { n -> String? in
                let v = (n.campos[campo] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return v.isEmpty ? nil : String(v.prefix(prefixo))
            }
            .prefix(quantos).map { $0 }
    }

    /// A calibragem por contagem: aquém, igual, além. O juízo é do AUTOR, no
    /// campo "saldo" da volta (ADR 04t); só quando ele não o preencheu é que
    /// se lê por palavras de sinal no "aconteceu" — e aí é grosseiro de
    /// propósito, e dito como contagem.
    nonisolated static func calibrar(_ notas: [NotaLida]) -> (total: Int, aquem: Int, igual: Int, alem: Int) {
        var aquem = 0, igual = 0, alem = 0
        for n in notas where n.gesto == .decisao {
            let esperava = (n.campos["espero"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let aconteceuCru = (n.campos["aconteceu"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !esperava.isEmpty, !aconteceuCru.isEmpty else { continue }
            let saldo = (n.campos["saldo"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let aconteceu = saldo.isEmpty ? aconteceuCru.lowercased() : saldo
            if aconteceu.contains(regex: #"\b(não|nao|menos|pior|atras|atrás|faltou|demorou|nada|aquém|aquem)\b"#) {
                aquem += 1
            } else if aconteceu.contains(regex: #"\b(mais|melhor|antes|além|alem|superou|acima)\b"#) {
                alem += 1
            } else {
                igual += 1
            }
        }
        return (aquem + igual + alem, aquem, igual, alem)
    }
}
