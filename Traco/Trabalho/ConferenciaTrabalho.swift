import Foundation
import NaturalLanguage

/// ADR 05p: a checagem local do artefato contra o pedido que o produziu.
///
/// Não é um selo. Reconhece DUAS restrições — idioma explícito e distribuição
/// de tempo — e diz o que examinou e o que não examinou. Tudo que a gramática
/// não casa fica `naoAvaliado` e aparece na linha; ausência de alerta nunca
/// significa qualidade. Sem rede, sem modelo gerativo: regras e o
/// `NLLanguageRecognizer` do aparelho.
nonisolated enum ConferenciaTrabalho {
    static let versaoDoMetodo = 1
    static let executor = "aparelho · regras v1"
    /// Prosa curta demais para o reconhecedor decidir (o parecer do consultor).
    static let minimoDeProsa = 40
    /// Acima disso a conferência recusa veredito em vez de ler um pedaço (05m).
    static let tetoDoArtefato = 200_000

    // MARK: - Entrada

    static func conferir(pedido: DocumentoTrabalho.Pedido,
                         intencao: DocumentoTrabalho.Intencao,
                         artefato: String) -> DocumentoTrabalho.Conferencia {
        func registro(_ estado: DocumentoTrabalho.EstadoConferencia,
                      motivo: String? = nil,
                      resultados: [DocumentoTrabalho.Resultado] = []) -> DocumentoTrabalho.Conferencia {
            .init(pedidoID: pedido.id, executor: executor, versaoDoMetodo: versaoDoMetodo,
                  estado: estado, motivo: motivo, resultados: resultados)
        }
        guard artefato.count <= tetoDoArtefato else {
            return registro(.indisponivel,
                motivo: "O artefato tem \(artefato.count) caracteres e não cabe inteiro nesta checagem. Não conferi um pedaço dele.")
        }
        let criterios = criterios(pedido: pedido, intencao: intencao)
        var resultados = criterios.map { avaliar($0, no: artefato) }
        if criterios.isEmpty {
            resultados.append(.init(criterio: "Restrições do pedido",
                trechoFonte: primeiraFrase(pedido.instrucao), fonte: .instrucao, situacao: .naoAvaliado,
                justificativa: "Esta checagem só reconhece idioma explícito e distribuição de tempo. Nada no pedido casou com essas regras: nenhum critério foi examinado."))
        }
        resultados.append(.init(criterio: "Destinatário, conteúdo e adequação",
            trechoFonte: primeiraFrase(pedido.instrucao), fonte: .instrucao, situacao: .naoAvaliado,
            justificativa: "Se o material serve a quem foi pedido, se as traduções estão corretas e se o texto é utilizável, ninguém leu. Isso exige leitura, não regra."))
        return registro(.concluida, resultados: resultados)
    }

    /// A linha que a versão mostra. Nunca diz “verificado” nem “aprovado”.
    static func linha(_ c: DocumentoTrabalho.Conferencia) -> String {
        switch c.estado {
        case .indisponivel: return "Conferência indisponível: \(c.motivo ?? "sem motivo registrado.")"
        case .concluida: break
        }
        let d = c.resultados.count { $0.situacao == .divergencia }
        let i = c.resultados.count { $0.situacao == .inconclusivo }
        let n = c.resultados.count { $0.situacao == .naoAvaliado }
        let naoAvaliados = " · \(n) \(n == 1 ? "critério não avaliado" : "critérios não avaliados")"
        let inconclusivos = i == 0 ? "" : " · \(i) \(i == 1 ? "inconclusivo" : "inconclusivos")"
        if c.resultados.count == n {
            return "Conferência: nenhum critério examinado" + naoAvaliados
        }
        if d == 0 {
            return "Conferência: nenhuma divergência nos critérios examinados" + inconclusivos + naoAvaliados
        }
        return "Conferência: \(d) \(d == 1 ? "possível divergência" : "possíveis divergências")" + inconclusivos + naoAvaliados
    }

    // MARK: - Critérios

    enum Alvo: Equatable {
        case idioma([NLLanguage])
        case tempo(blocos: Int?, cada: Int?, total: Int)
    }
    struct Criterio: Equatable {
        var rotulo: String
        var trecho: String
        var fonte: DocumentoTrabalho.FonteCriterio
        var alvo: Alvo
    }

    /// Instrução vigente prevalece sobre resultado desejado e sobre intenção:
    /// a primeira fonte que casa a regra é a que vale, e o trecho é literal.
    static func criterios(pedido: DocumentoTrabalho.Pedido,
                          intencao: DocumentoTrabalho.Intencao) -> [Criterio] {
        let fontes: [(DocumentoTrabalho.FonteCriterio, String)] = [
            (.instrucao, pedido.instrucao), (.resultado, intencao.resultado), (.intencao, intencao.texto),
        ]
        var achados: [Criterio] = []
        for (fonte, texto) in fontes where !texto.isEmpty {
            guard let c = idioma(em: texto, fonte: fonte) else { continue }
            achados.append(c)
            break
        }
        for (fonte, texto) in fontes where !texto.isEmpty {
            guard let c = tempo(em: texto, fonte: fonte) else { continue }
            achados.append(c)
            break
        }
        return achados
    }

    // Regex não é Sendable: literais ficam em propriedade computada.
    private static var idiomas: [(Regex<Substring>, NLLanguage, String)] { [
        (#/(?i)portugu[êe]s/#, .portuguese, "português"),
        (#/(?i)espanhol|castelhano|spanish/#, .spanish, "espanhol"),
        (#/(?i)ingl[êe]s|english/#, .english, "inglês"),
        (#/(?i)franc[êe]s|french/#, .french, "francês"),
        (#/(?i)alem[ãa]o|german/#, .german, "alemão"),
        (#/(?i)italiano|italian/#, .italian, "italiano"),
    ] }

    private static func idioma(em texto: String, fonte: DocumentoTrabalho.FonteCriterio) -> Criterio? {
        var linguas: [NLLanguage] = [], nomes: [String] = [], frases: [String] = []
        for (padrao, lingua, nome) in idiomas {
            let ranges = texto.ranges(of: padrao)
            guard !ranges.isEmpty else { continue }
            linguas.append(lingua)
            nomes.append(nome)
            for r in ranges {
                let frase = frase(em: texto, contendo: r)
                if !frases.contains(frase) { frases.append(frase) }
            }
        }
        guard !linguas.isEmpty else { return nil }
        let rotulo = linguas.count == 1
            ? "Idioma pedido: \(nomes[0])"
            : "Idiomas pedidos: \(nomes.formatted(.list(type: .and, width: .standard)))"
        return .init(rotulo: rotulo, trecho: frases.joined(separator: " "), fonte: fonte, alvo: .idioma(linguas))
    }

    private static let numeros: [String: Int] = [
        "um": 1, "uma": 1, "dois": 2, "duas": 2, "tres": 3, "três": 3, "quatro": 4, "cinco": 5,
        "seis": 6, "sete": 7, "oito": 8, "nove": 9, "dez": 10, "onze": 11, "doze": 12, "treze": 13,
        "catorze": 14, "quatorze": 14, "quinze": 15, "dezesseis": 16, "dezessete": 17, "dezoito": 18,
        "dezenove": 19, "vinte": 20, "trinta": 30,
    ]
    private static func valor(_ s: Substring) -> Int? { Int(s) ?? numeros[s.lowercased()] }

    /// UM léxico de tempo: o mesmo padrão lê o pedido e lê o artefato. Enquanto
    /// o do artefato só via dígitos, a tela afirmava “nenhuma marca de minutos”
    /// sobre artefato que escrevia “cinco minutos” três vezes. Em texto porque
    /// literal de regex não interpola; `\b` evita achar “um” dentro de “algum”.
    private static let quantia = #"(?:\d+|dezesseis|dezessete|dezenove|dezoito|quatorze|catorze|quinze|treze|trinta|vinte|dois|duas|tr[êe]s|quatro|cinco|seis|sete|oito|nove|dez|onze|doze|uma?)"#
    /// Uma marca de tempo solta: “5 min”, “cinco minutos”, “5'”, “meia hora”.
    private static let marcaDeTempo = #"(?:\b\#(quantia)\s*(?:minutos?|mins?\b|')|\bmeia\s+horas?)"#
    private static let blocosDeTempo = #"\b(\#(quantia))\s+(?:blocos?|partes?|se[çc][õo]es?|rodadas?)\s+de\s+(\#(marcaDeTempo))"#

    /// Padrão literal deste arquivo: só falha se ele estiver errado, e a suíte pega.
    private static func regex(_ padrao: String) -> Regex<AnyRegexOutput> { try! Regex("(?i)" + padrao) }

    private static func minutos(_ marca: Substring) -> Int? {
        if marca.lowercased().contains("hora") { return 30 }
        return valor(marca.first?.isNumber == true ? marca.prefix(while: \.isNumber) : marca.prefix(while: \.isLetter))
    }

    private static func tempo(em texto: String, fonte: DocumentoTrabalho.FonteCriterio) -> Criterio? {
        if let m = texto.firstMatch(of: regex(blocosDeTempo)),
           let n = m.output[1].substring.flatMap(valor),
           let cada = m.output[2].substring.flatMap(minutos), n > 0, cada > 0 {
            return .init(rotulo: "Tempo pedido: \(n) blocos de \(cada) minutos (\(n * cada) no total)",
                         trecho: frase(em: texto, contendo: m.range), fonte: fonte,
                         alvo: .tempo(blocos: n, cada: cada, total: n * cada))
        }
        if let m = texto.firstMatch(of: regex(marcaDeTempo)), let x = minutos(texto[m.range]), x > 0 {
            return .init(rotulo: "Tempo pedido: \(x) minutos", trecho: frase(em: texto, contendo: m.range),
                         fonte: fonte, alvo: .tempo(blocos: nil, cada: nil, total: x))
        }
        return nil
    }

    // MARK: - Avaliação

    private static func avaliar(_ c: Criterio, no artefato: String) -> DocumentoTrabalho.Resultado {
        func resultado(_ s: DocumentoTrabalho.SituacaoCriterio, _ trechos: [String], _ porque: String) -> DocumentoTrabalho.Resultado {
            .init(criterio: c.rotulo, trechoFonte: c.trecho, fonte: c.fonte,
                  situacao: s, trechosDoArtefato: trechos, justificativa: porque)
        }
        switch c.alvo {
        case .idioma(let esperados): return conferirIdioma(esperados, artefato, resultado)
        case .tempo(let blocos, let cada, let total): return conferirTempo(blocos, cada, total, artefato, resultado)
        }
    }

    private static func conferirIdioma(
        _ esperados: [NLLanguage], _ artefato: String,
        _ resultado: (DocumentoTrabalho.SituacaoCriterio, [String], String) -> DocumentoTrabalho.Resultado
    ) -> DocumentoTrabalho.Resultado {
        let linhas = prosa(artefato)
        guard !linhas.isEmpty else {
            return resultado(.inconclusivo, [], "Nenhum trecho do artefato tem \(minimoDeProsa) caracteres de prosa corrida — abaixo disso o reconhecedor do aparelho não decide idioma. Não é o mesmo que dizer que o idioma está certo.")
        }
        var fora: [(String, String)] = [], baixaConfianca = 0
        for linha in linhas {
            // Instância nova por trecho: o reconhecedor não pode ser compartilhado.
            let leitor = NLLanguageRecognizer()
            leitor.processString(linha)
            let hipoteses = leitor.languageHypotheses(withMaximum: 3)
            guard let topo = hipoteses.max(by: { $0.value < $1.value }), topo.value >= 0.55 else {
                baixaConfianca += 1
                continue
            }
            // Um trecho com material de qualquer idioma declarado é legítimo:
            // "frases em espanhol com tradução em português" não é erro.
            if esperados.contains(where: { (hipoteses[$0] ?? 0) >= 0.30 }) { continue }
            fora.append((nome(topo.key), String(linha.prefix(160))))
        }
        let nomes = esperados.map(nome).formatted(.list(type: .and, width: .standard))
        let curtos = baixaConfianca == 0 ? "" : " \(baixaConfianca) trecho(s) ficaram sem leitura confiável."
        guard fora.isEmpty else {
            let quais = Set(fora.map(\.0)).sorted().formatted(.list(type: .and, width: .standard))
            return resultado(.divergencia, fora.prefix(3).map(\.1),
                "\(fora.count) de \(linhas.count) trechos examinados parecem \(quais); o pedido diz \(nomes).\(curtos)")
        }
        guard baixaConfianca < linhas.count else {
            return resultado(.inconclusivo, [], "Nenhum dos \(linhas.count) trechos examinados teve leitura confiável de idioma. Não conferi nada.")
        }
        let ressalva = esperados.count == 1
            ? ""
            : " Não conferi qual frase é original e qual é tradução — isso exige leitura."
        return resultado(.atendidoNoEscopo, [],
            "Os trechos examinados ficam dentro de \(nomes).\(ressalva)\(curtos)")
    }

    private static func conferirTempo(
        _ blocos: Int?, _ cada: Int?, _ total: Int, _ artefato: String,
        _ resultado: (DocumentoTrabalho.SituacaoCriterio, [String], String) -> DocumentoTrabalho.Resultado
    ) -> DocumentoTrabalho.Resultado {
        let marcas = artefato.matches(of: regex(marcaDeTempo)).compactMap { minutos(artefato[$0.range]) }
        guard !marcas.isEmpty else {
            return resultado(.divergencia, [],
                "Não encontrei distribuição: nenhuma marca de minutos no artefato, nem em dígitos nem por extenso. Isso não é o mesmo que dizer que os tempos somam errado — é dizer que não há tempo escrito para conferir.")
        }
        // Um total anunciado no cabeçalho não conta duas vezes.
        var contadas = marcas
        if contadas.count > 1, contadas.reduce(0, +) != total, let i = contadas.firstIndex(of: total) {
            contadas.remove(at: i)
        }
        let soma = contadas.reduce(0, +)
        let lidas = contadas.map { "\($0) min" }.joined(separator: ", ")
        let achadas = "\(contadas.count) \(contadas.count == 1 ? "marca" : "marcas")"
        if let blocos, let cada {
            guard contadas.count == blocos, soma == total else {
                return resultado(.divergencia, [lidas],
                    "O pedido pede \(blocos) blocos de \(cada) minutos (\(total) no total); encontrei \(achadas) somando \(soma).")
            }
            return resultado(.atendidoNoEscopo, [lidas],
                "Encontrei \(achadas) de minutos somando \(soma), como o pedido pede. O tempo escrito não prova a duração da prática.")
        }
        guard soma == total else {
            return resultado(.divergencia, [lidas],
                "O pedido pede \(total) minutos; as marcas do artefato somam \(soma).")
        }
        return resultado(.atendidoNoEscopo, [lidas],
            "As marcas do artefato somam \(soma) minutos, como o pedido pede. O tempo escrito não prova a duração da prática.")
    }

    // MARK: - Texto

    /// Linhas com prosa suficiente. Cabeçalho, tabela, código e item curto
    /// ficam de fora: o reconhecedor erra neles e o erro viraria alarme falso.
    static func prosa(_ texto: String) -> [String] {
        var linhas: [String] = [], emCodigo = false
        for bruta in texto.split(separator: "\n", omittingEmptySubsequences: false) {
            let linha = bruta.trimmingCharacters(in: .whitespaces)
            if linha.hasPrefix("```") { emCodigo.toggle(); continue }
            guard !emCodigo, !linha.hasPrefix("|"), !linha.hasPrefix("#") else { continue }
            var limpa = linha
            while let m = limpa.prefixMatch(of: #/\s*([-*+>]\s+|\d+[.)]\s+)/#) { limpa.removeSubrange(m.range) }
            limpa = limpa.replacing(#/[*_`#]/#, with: "")
                .replacing(#/\[([^\]]*)\]\([^)]*\)/#) { $0.output.1 }
                .trimmingCharacters(in: .whitespaces)
            if limpa.count >= minimoDeProsa { linhas.append(limpa) }
        }
        return linhas
    }

    /// A frase inteira em volta do achado, literal como o autor escreveu.
    private static func frase(em texto: String, contendo r: Range<String.Index>) -> String {
        let fim = Set<Character>([".", "!", "?", ";", "\n"])
        var inicio = r.lowerBound
        while inicio > texto.startIndex {
            let anterior = texto.index(before: inicio)
            if fim.contains(texto[anterior]) { break }
            inicio = anterior
        }
        var termino = r.upperBound
        while termino < texto.endIndex, !fim.contains(texto[termino]) { termino = texto.index(after: termino) }
        return texto[inicio..<termino].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func primeiraFrase(_ texto: String) -> String {
        guard let primeira = texto.split(whereSeparator: { ".!?\n".contains($0) }).first else { return texto }
        return primeira.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func nome(_ lingua: NLLanguage) -> String {
        idiomas.first { $0.1 == lingua }?.2
            ?? Locale(identifier: "pt_BR").localizedString(forLanguageCode: lingua.rawValue)
            ?? lingua.rawValue
    }
}
