import Foundation

/// O retrato da mente (ADR 2026-09-04i): o eixo do ciclo. O bloco SOBRE QUEM
/// ESCREVE que viaja com a instigação, a resposta, o contrapor e a prova —
/// montado por algoritmo, só com as palavras do autor e com contagens.
///
/// Não conclui, não diagnostica, não pontua. É a evidência que o papel
/// guarda, posta na frente da IA para ela perguntar melhor. O Perfil mostra o
/// retrato inteiro; a rota das Notas leva dele só os blocos do assunto (E7).
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
        /// ADR 08u/09b: só a voz do autor entra no retrato. O que o bot
        /// escreveu não é evidência sobre quem escreve — nem como contagem.
        /// SEM PADRÃO de propósito: o chamador que esquecer não compila. O
        /// defeito de 08u nasceu de um `= true` que a rota das Notas herdou.
        var vozDoAutor: Bool
    }

    /// Juízo no mundo, já cortado pelo tipo existente (`ResultadoObservado`).
    /// Sem enum novo: o rótulo e o relato são as palavras dela.
    nonisolated struct JuizoObservado: Sendable {
        var rotulo: String
        var relato: String
    }

    static var ligado: Bool {
        get { UserDefaults.standard.object(forKey: chaveLigado) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: chaveLigado) }
    }

    /// O retrato como texto. Vazio quando não há nada: retrato vazio não viaja.
    /// `observados` são relatos do Trabalho que o chamador já autorizou —
    /// o Retrato não busca disco nem fura selo.
    nonisolated static func ler(notas: [NotaLida], sinais: [Sinal], agora: Date = .now,
                                cal: Calendar = .current,
                                observados: [JuizoObservado] = []) -> String {
        lerComRecibo(notas: notas, sinais: sinais, agora: agora, cal: cal, observados: observados).texto
    }

    /// E7 (ADR 2026-09-16l): cada linha diz o que é — contagem, citação com a
    /// data em que foi escrita, ou leitura por palavras — em forma neutra; o
    /// teto tira BLOCOS inteiros, na ordem, e `cortados` diz quais caíram
    /// (antes: `prefix(1500) + "…"` no meio de uma citação, sem recibo).
    nonisolated static func lerComRecibo(notas: [NotaLida], sinais: [Sinal], agora: Date = .now,
                                         cal: Calendar = .current,
                                         observados: [JuizoObservado] = []) -> (texto: String, cortados: [String]) {
        // o selo corta antes: expressiva, selada e queimada não entram, nem como contagem
        let abertas = notas.filter { !$0.fechada && !$0.expressiva && $0.vozDoAutor }
        let trintaAtras = cal.date(byAdding: .day, value: -30, to: agora) ?? agora
        var blocos: [(nome: String, texto: String)] = []
        func citacoes(_ itens: [(valor: String, quando: Date)]) -> String {
            itens.map { "“\($0.valor)” (\(dia($0.quando, cal)))" }.joined(separator: "; ")
        }

        var porForma: [String: Int] = [:]
        for n in abertas where n.criadaEm >= trintaAtras {
            porForma[n.gesto?.nome ?? "sem forma", default: 0] += 1
        }
        if !porForma.isEmpty {
            let linha = porForma.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
                .prefix(8).map { "\($0.value) \($0.key)" }.joined(separator: " · ")
            blocos.append(("formas", "Formas nos últimos 30 dias (contagem): \(linha)."))
        }

        let obstaculos = ultimos(abertas, gesto: .woop, campo: "obstaculo", quantos: 5)
        if !obstaculos.isEmpty {
            blocos.append(("obstáculos", "Obstáculos internos já nomeados (citações, com a data da nota): " + citacoes(obstaculos) + "."))
        }

        let proximas = ultimos(abertas, gesto: .woop, campo: "plano", quantos: 5)
        if !proximas.isEmpty {
            blocos.append(("próximas", "Próximas que já escreveu (citações): " + citacoes(proximas) + "."))
        }

        let destiladas = ultimos(abertas, gesto: .destilar, campo: "frase", quantos: 5)
        if !destiladas.isEmpty {
            blocos.append(("destiladas", "Juízos que já cortou numa frase (citações): " + citacoes(destiladas) + "."))
        }

        let noMundo = observados.prefix(5).compactMap { j -> String? in
            let relato = j.relato.split(whereSeparator: \.isNewline).joined(separator: " ").trimmingCharacters(in: .whitespaces)
            let rotulo = j.rotulo.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !relato.isEmpty, !rotulo.isEmpty else { return nil }
            return "“\(relato)” (\(rotulo))"
        }
        if !noMundo.isEmpty {
            blocos.append(("resultados", "Resultados informados no Trabalho (citações): " + noMundo.joined(separator: "; ") + "."))
        }

        let naoVoltou = sinais.filter { $0.tipo == .naoVoltou }.suffix(5)
        if !naoVoltou.isEmpty {
            let faltou = naoVoltou.reduce(0) { $0 + ($1.faltaram ?? 0) }
            let de = naoVoltou.reduce(0) { $0 + ($1.deQuantos ?? 0) }
            if de > 0 {
                blocos.append(("recordar", "Nas últimas \(naoVoltou.count) provas do Recordar (contagem), \(faltou) de \(de) pontos não voltaram."))
            }
        }

        let calibragem = calibrar(abertas)
        if calibragem.total >= 2 {
            let porPalavras = lidasPorPalavras(abertas)
            let leitura = porPalavras == 0 ? ""
                : "; em \(porPalavras) o saldo não foi escrito e a conta veio de uma leitura por palavras do que aconteceu"
            blocos.append(("calibragem", "Decisões conferidas (contagem): \(calibragem.total). O que aconteceu ficou aquém do esperado em \(calibragem.aquem), igual em \(calibragem.igual), além em \(calibragem.alem)\(leitura)."))
        }

        let palavras = ultimos(abertas, gesto: .palavra, campo: "minhas", quantos: 5, prefixo: 60)
        if !palavras.isEmpty {
            blocos.append(("palavras", "Palavras conquistadas, nas palavras de quem escreve (citações): " + citacoes(palavras) + "."))
        }

        // Perguntas da IA podem repetir conteúdo privado de qualquer nota
        // usada na geração. Sinais antigos não registram essas dependências:
        // não atribua a origem por palpite nem reenvie o texto após um selo.
        // O histórico local permanece; citações só poderão voltar ao retrato
        // quando a geração registrar todas as fontes e seu acesso for revalidado.

        var texto = ""
        var cortados: [String] = []
        for bloco in blocos {
            let novo = texto.isEmpty ? bloco.texto : texto + "\n" + bloco.texto
            if novo.count <= teto { texto = novo } else { cortados.append(bloco.nome) }
        }
        return (texto, cortados)
    }

    nonisolated static func dia(_ data: Date, _ cal: Calendar) -> String {
        let c = cal.dateComponents([.day, .month], from: data)
        return String(format: "%02d/%02d", c.day ?? 0, c.month ?? 0)
    }

    /// E7: só os blocos cujas CITAÇÕES dividem assunto com a pergunta — rótulo,
    /// contagem e texto do molde ("escrito", "aconteceu", nome de forma) não são
    /// assunto. Nenhum divide: vão os blocos que cabem, na ordem, até `tetoSemAssunto`.
    nonisolated static func pertinente(_ texto: String, pergunta: String) -> String {
        let daPergunta = Set(Obra.palavras(pergunta).map(\.radical))
        let blocos = texto.components(separatedBy: "\n").filter { !$0.isEmpty }
        let comAssunto = blocos.filter { bloco in
            let citado = bloco.matches(of: /“([^”]*)”/).map { String($0.output.1) }.joined(separator: " ")
            return !Set(Obra.palavras(citado).map(\.radical)).isDisjoint(with: daPergunta)
        }
        if !comAssunto.isEmpty { return comAssunto.joined(separator: "\n") }
        var menor = ""
        for bloco in blocos {
            let novo = menor.isEmpty ? bloco : menor + "\n" + bloco
            if novo.count <= tetoSemAssunto { menor = novo }
        }
        return menor
    }

    static let tetoSemAssunto = 500

    /// Quantas decisões conferidas não têm saldo escrito: essas são contadas por palavras.
    nonisolated static func lidasPorPalavras(_ notas: [NotaLida]) -> Int {
        notas.filter { n in
            n.gesto == .decisao
                && !(n.campos["espero"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !(n.campos["aconteceu"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && (n.campos["saldo"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
    }

    /// Os últimos `quantos` valores literais de um campo, mais recentes primeiro.
    private static func ultimos(_ notas: [NotaLida], gesto: Gesto, campo: String, quantos: Int,
                                prefixo: Int = 120) -> [(valor: String, quando: Date)] {
        notas.filter { $0.gesto == gesto }
            .sorted { $0.criadaEm > $1.criadaEm }
            .compactMap { n -> (valor: String, quando: Date)? in
                let v = (n.campos[campo] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return v.isEmpty ? nil : (String(v.split(whereSeparator: \.isNewline).joined(separator: " ").prefix(prefixo)), n.criadaEm)
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
