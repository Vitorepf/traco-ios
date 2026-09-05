import Foundation
import CoreFoundation
import FoundationModels

/// A sábia (ADR 2026-09-02o): a IA que dá forma, dá informação e dá pergunta,
/// nunca a resposta do autor. Três chamadas, cada uma com verificação dura:
/// `vestir` devolve um mapa de rótulos por bloco; `responder` devolve texto
/// para um CARTÃO (nunca para a nota); `instigar` devolve perguntas.
/// Selo: expressiva e trancada jamais chegam aqui (quem chama garante).
enum Sabia {
    static let modelo = AnaliseRemota.modelo

    /// As formas que o mapa de vestir pode nomear. Lista fechada: rótulo
    /// desconhecido invalida o mapa inteiro.
    nonisolated enum FormaDeBloco: String, CaseIterable, Sendable {
        case titulo, secao, lista, numerada, tarefas, citacao, codigo, tabela, prosa
    }

    nonisolated struct Rotulo: Equatable, Sendable {
        var i: Int
        var forma: FormaDeBloco
    }

    static let sistemaVestir = """
    Você dá FORMA a um texto sem tocar numa palavra. Recebe blocos numerados.
    Responda APENAS um JSON válido: [{"i": <número do bloco>, "forma": "titulo"|"secao"|"lista"|"numerada"|"tarefas"|"citacao"|"codigo"|"tabela"|"prosa"}]
    Um item por bloco, na ordem. titulo = o título do texto inteiro (no máximo um) ·
    secao = cabeçalho de parte · lista = linhas paralelas sem ordem · numerada = passos em ordem ·
    tarefas = coisas a fazer · citacao = fala de outro · codigo = código ou comando · tabela = linhas com colunas
    separadas por | ou tabulação · prosa = tudo o mais. Na dúvida, prosa. Nenhuma outra chave, nenhum texto.
    """

    /// ADR 04r: UM teto, 900, no prompt e no parser.
    nonisolated static let tetoResposta = 900

    static let sistemaResponder = """
    Você é uma pessoa sábia ao lado de quem escreve. Ela deixou uma pergunta na própria nota e você responde
    com informação, opções e critérios — em português, direto, sem elogio, sem rodeio, no máximo 900 caracteres.
    Você NÃO escreve a nota por ela: não redija o texto dela, não conclua por ela, não decida por ela.
    Onde houver mais de um caminho, mostre os caminhos e o que decide entre eles.
    Se houver um bloco SOBRE QUEM ESCREVE, use-o para responder a ESTA pessoa — nunca o comente, nunca o elogie.
    """

    /// ADR 05e — a pergunta feita nas Notas, sobre o segundo cérebro inteiro
    /// e sobre os métodos: informação, opções, critérios, e qual forma serve.
    static let sistemaResponderNasNotas = """
    Você é uma pessoa sábia ao lado de quem escreve num segundo cérebro chamado Traço. Ela pergunta pela barra das
    notas, fora de qualquer nota, e você responde com informação, opções e critérios — em português, direto, sem
    elogio, sem rodeio, no máximo 900 caracteres. Você NÃO escreve nota nenhuma por ela: não redija texto dela, não
    conclua por ela, não decida por ela. Quando a pergunta é "que método/forma usar", diga qual das FORMAS DO TRAÇO
    serve e por quê, pelo nome. Quando as NOTAS DELA respondem, aponte-as pelo título. Se houver um bloco SOBRE QUEM
    ESCREVE, use-o para responder a ESTA pessoa — nunca o comente. Se houver CONVERSA ATÉ AQUI, continue-a.
    """

    static func responderNasNotas(pergunta: String, contexto: String, retrato: String = "") async -> String? {
        // No aparelho, sacrifica retrato antes do contexto; pergunta e instrução ficam.
        let usuario = "Pergunta: \(pergunta)\n\nResponda só à pergunta, em prosa corrida, sem repetir nem citar os blocos abaixo.\n\n"
            + contexto + blocoDoRetrato(retrato)
        guard let cru = await chamar(sistema: sistemaResponderNasNotas, usuario: usuario, temperatura: 0.3,
                                     mensagemLocal: { montarResponder(pergunta: pergunta, contexto: contexto, retrato: retrato) })
        else { return nil }
        return limparResposta(cru, teto: tetoResposta)
    }

    /// ADR 04m — contrapor: o que o autor não considerou. Informação, nunca
    /// instrução; a resposta, a opção escolhida e a analogia que fica são dele.
    static let sistemaContrapor = """
    Você lê a nota de quem escreve e devolve o que ela NÃO considerou. Responda APENAS um JSON válido, sem markdown:
    {"contra": "…", "foraDaLista": "…", "outroCampo": "…"}
    contra = a posição contrária à dela, no melhor que alguém competente a defenderia ·
    foraDaLista = uma opção que não está entre as que ela listou ·
    outroCampo = um exemplo concreto de outro campo (outra ciência, ofício, época) que resolveu problema com a mesma estrutura.
    Cada valor em português, até 280 caracteres, INFORMAÇÃO e nunca instrução: proibido "você deve", "faça", "escreva", "tente".
    Nada de elogio, nada de conclusão por ela. Se um dos três não tiver conteúdo honesto, deixe "" — silêncio é resposta válida.
    Se houver um bloco SOBRE QUEM ESCREVE, use-o para escolher o exemplo que ela ainda não viu.
    """

    nonisolated struct Contraparte: Sendable, Equatable {
        var contra: String
        var foraDaLista: String
        var outroCampo: String
        var vazia: Bool { contra.isEmpty && foraDaLista.isEmpty && outroCampo.isEmpty }
    }

    static let sistemaInstigar = """
    Você é uma pessoa sábia lendo o rascunho de quem escreve. Devolva APENAS um JSON válido: {"perguntas": ["…", "…"]}
    De 2 a 5 perguntas curtas em português, cada uma terminando em "?", que apontem buracos, dependências,
    termos ambíguos, o que falta decidir, o que pode dar errado. Perguntas, não respostas. Nenhuma sugestão de texto.
    """

    /// ADR 03i — a prova do Recordar. UMA pergunta que obriga a puxar a nota da
    /// memória, e que não pode entregar nada: `Prova.vaza` recusa a que citar.
    static let sistemaRecordar = """
    Você faz UMA pergunta a quem tenta lembrar da própria nota, sem ver a nota.
    Responda APENAS um JSON válido, sem markdown: {"pergunta": "…"}

    Regras absolutas:
    - Uma só pergunta, em português, no máximo 120 caracteres, terminando em "?".
    - A pergunta APONTA para o miolo da nota e NUNCA o revela: proibido usar as
      palavras da nota, proibido citar, proibido dar a resposta ou parte dela.
    - Pergunte o que a pessoa precisa RECONSTRUIR, não o que ela precisa
      reconhecer. Nada de "você lembra que…", nada de sim/não.
    - Nenhuma outra chave, nenhum texto, nenhuma explicação.
    - Na dúvida, {"pergunta": ""} — silêncio é resposta válida.

    O DEGRAU diz o quanto cobrar. É a mesma nota voltando pela enésima vez:
    0 — primeira volta. Peça UM pedaço concreto: o quê, onde, qual.
    1 — peça a relação entre duas coisas da nota.
    2 — peça o porquê: o mecanismo, a razão que sustenta.
    3 — peça a consequência: o que se segue disto, o que muda.
    4 ou mais — peça o limite: onde isto deixa de valer, o que a contradiz.
    Nunca repita a cobrança do degrau anterior.
    """

    /// A conferência. Contrato mais fechado do app: a resposta é uma lista de
    /// NÚMEROS. Nenhuma palavra do modelo chega à tela do autor — o que ele lê
    /// são os pontos que ele mesmo escreveu.
    static let sistemaConferir = """
    Você confere uma recuperação de memória. Recebe PONTOS numerados (o que a
    nota dizia) e o que a pessoa escreveu DE MEMÓRIA.
    Responda APENAS um JSON válido, sem markdown: {"voltaram": [0, 2]}

    Um ponto VOLTOU quando a memória diz a mesma coisa, ainda que com outras
    palavras. Palavra igual sem o sentido não conta; sentido igual com outras
    palavras conta. Na dúvida, o ponto NÃO voltou.
    Nenhuma outra chave, nenhum texto, nenhum comentário, nenhum elogio.
    """

    /// ADR 03j — o eco: outra nota do autor que fala da MESMA coisa sem citar
    /// esta. A rede do caderno só existia onde ele digitou `[[…]]` à mão.
    static let sistemaEcos = """
    Você lê a NOTA de quem escreve e uma lista numerada de OUTRAS notas da mesma
    pessoa. Diga quais falam da MESMA coisa que a nota, sem que uma cite a outra.
    Responda APENAS um JSON válido, sem markdown:
    {"ecos": [{"i": <número da nota>, "trecho": "…"}]}

    Regras absolutas:
    - No máximo 3. Na dúvida, menos — ou nenhum: {"ecos": []}.
    - "trecho" é um pedaço LITERAL da nota número i, copiado sem mudar uma
      letra, entre 8 e 120 caracteres. É a prova de que você a leu.
    - Mesma COISA, não mesma palavra: o tema que volta, a mesma decisão com
      outro nome, a tese que uma contradiz na outra. Coincidência de
      vocabulário não é eco.
    - Nenhuma outra chave, nenhum texto, nenhuma explicação, nenhum resumo.
    """

    nonisolated struct Eco: Sendable, Equatable {
        var i: Int
        var trecho: String
    }

    // MARK: chamadas

    static func vestir(blocos: [String], gesto: Gesto?) async -> [Rotulo]? {
        guard gesto != .expressiva, !blocos.isEmpty else { return nil }
        let usuario = blocos.enumerated().map { "[\($0.offset)] \($0.element.prefix(400))" }.joined(separator: "\n\n")
        guard let cru = await chamar(sistema: sistemaVestir, usuario: usuario, temperatura: 0,
                                     memoPor: "vestir\u{1}\(usuario.hashValue)") else { return nil }
        return parseMapa(cru, blocos: blocos.count)
    }

    /// ADR 04i: o bloco SOBRE QUEM ESCREVE, quando há retrato.
    nonisolated static func blocoDoRetrato(_ retrato: String) -> String {
        let r = retrato.trimmingCharacters(in: .whitespacesAndNewlines)
        return r.isEmpty ? "" : "\n\nSOBRE QUEM ESCREVE (evidência do caderno dela, nas palavras dela):\n\(r)"
    }

    /// ADR 05m: carga e cabeçalhos são indivisíveis; só o contexto perde a cauda.
    /// Se a carga não cabe, silêncio. O transporte nunca decide o que é descartável.
    nonisolated static func mensagemDoAparelho(carga: String, contexto: String = "",
                                              teto: Int = tetoNoAparelho) -> String? {
        guard !carga.isEmpty, carga.count <= teto else { return nil }
        return carga + contexto.prefix(teto - carga.count)
    }

    nonisolated static func montarResponder(pergunta: String, contexto: String, retrato: String = "",
                                            teto: Int = tetoNoAparelho) -> String? {
        let carga = "Pergunta: \(pergunta)\n\nResponda só à pergunta, em prosa corrida, sem repetir nem citar os blocos abaixo.\n\n"
        // Sacrifica retrato primeiro, depois contexto; nunca pergunta/instrução.
        return mensagemDoAparelho(carga: carga, contexto: contexto + blocoDoRetrato(retrato), teto: teto)
    }

    nonisolated static func montarConferir(pontos: [String], memoria: String,
                                           teto: Int = tetoNoAparelho) -> String? {
        let escrito = memoria.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pontos.isEmpty, !escrito.isEmpty else { return nil }
        let lista = pontos.enumerated().map { "[\($0.offset)] \($0.element)" }.joined(separator: "\n")
        // Não sacrifica evidência: pontos e memória inteiros, ou silêncio sem memo.
        return mensagemDoAparelho(carga: "PONTOS:\n\(lista)\n\nDE MEMÓRIA:\n\(escrito)", teto: teto)
    }

    static func responder(pergunta: String, contexto: String, gesto: Gesto?, retrato: String = "") async -> String? {
        guard gesto != .expressiva else { return nil }
        let usuario = "Contexto (a nota, só para você entender; não a reescreva):\n\(contexto.prefix(5000))"
            + blocoDoRetrato(retrato) + "\n\nPergunta: \(pergunta)"
        guard let cru = await chamar(sistema: sistemaResponder, usuario: usuario, temperatura: 0.3,
                                     mensagemLocal: { montarResponder(pergunta: pergunta, contexto: contexto, retrato: retrato) })
        else { return nil }
        return limparResposta(cru, teto: tetoResposta)
    }

    static func instigar(texto: String, gesto: Gesto?, degrau: Int = 0, retrato: String = "") async -> [String]? {
        guard gesto != .expressiva else { return nil }
        // ADR 03n: o MÉTODO vai junto. Sem ele a sábia sabia o nome da forma e
        // improvisava; com ele, ela cobra o movimento que o método existe para
        // cobrar — o obstáculo interno, a falha já acontecida, o não-escopo.
        var usuario = "Forma: \(gesto?.nome ?? "nota")"
        let metodo = gesto?.metodo ?? ""
        if !metodo.isEmpty { usuario += "\n\nO MÉTODO desta forma, que as perguntas devem cobrar:\n\(metodo)" }
        // ADR 04j: o degrau sobe com a prática nesta forma
        usuario += "\n\n" + Degraus.instrucaoDeInstigar(degrau)
        usuario += blocoDoRetrato(retrato)
        usuario += "\n\nO RASCUNHO:\n\(texto.prefix(6000))"
        guard let cru = await chamar(sistema: sistemaInstigar, usuario: usuario, temperatura: 0.4,
                                     mensagemLocal: {
            // Sacrifica retrato antes do método; forma, degrau e rascunho ficam inteiros.
            mensagemDoAparelho(carga: "Forma: \(gesto?.nome ?? "nota")\n\n"
                + Degraus.instrucaoDeInstigar(degrau) + "\n\nO RASCUNHO:\n\(texto)",
                contexto: "\n\nO MÉTODO desta forma, que as perguntas devem cobrar:\n\(metodo)" + blocoDoRetrato(retrato))
        }) else { return nil }
        return parsePerguntas(cru)
    }

    /// ADR 04m — o que o autor não considerou. Só a pedido; nunca memoiza,
    /// porque pedir de novo é pedir outro ângulo.
    static func contrapor(texto: String, gesto: Gesto?, retrato: String = "") async -> Contraparte? {
        guard gesto != .expressiva else { return nil }
        var usuario = "Forma: \(gesto?.nome ?? "nota")"
        let metodo = gesto?.metodo ?? ""
        if !metodo.isEmpty { usuario += "\n\nO MÉTODO desta forma:\n\(metodo)" }
        usuario += blocoDoRetrato(retrato)
        usuario += "\n\nA NOTA:\n\(texto.prefix(6000))"
        guard let cru = await chamar(sistema: sistemaContrapor, usuario: usuario, temperatura: 0.5,
                                     mensagemLocal: {
            // Sacrifica retrato antes do método; forma e nota ficam inteiras.
            mensagemDoAparelho(carga: "Forma: \(gesto?.nome ?? "nota")\n\nA NOTA:\n\(texto)",
                contexto: "\n\nO MÉTODO desta forma:\n\(metodo)" + blocoDoRetrato(retrato))
        }) else { return nil }
        return parseContraparte(cru)
    }

    /// Três chaves, texto até 280, e nunca instrução. O que começa por
    /// imperativo é descartado — informação é o que a ADR o permite.
    nonisolated static func parseContraparte(_ cru: String) -> Contraparte? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"),
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any]
        else { return nil }
        guard Set(j.keys).isSubset(of: ["contra", "foraDaLista", "outroCampo"]) else { return nil }
        func limpo(_ chave: String) -> String {
            let t = ((j[chave] as? String) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard t.count >= 12, t.count <= 320 else { return "" }
            let baixo = t.lowercased()
            if baixo.contains(regex: #"^(você deve|voce deve|faça|faca|escreva|tente|comece|pare de|precisa|deve )"#) { return "" }
            return AnaliseRemota.umaFrase(t, teto: 280)
        }
        let c = Contraparte(contra: limpo("contra"), foraDaLista: limpo("foraDaLista"), outroCampo: limpo("outroCampo"))
        return c.vazia ? nil : c
    }

    /// A pergunta da prova. Devolve nil (e o ritual fica com a frase fixa) se
    /// não houver conta, se a resposta não for pergunta, ou se ela VAZAR.
    static func perguntaDeRecordar(alvo: String, pista: String, gesto: Gesto?,
                                   degrau: Int = 0, retrato: String = "") async -> String? {
        guard gesto != .expressiva else { return nil }
        let alvoLimpo = alvo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard alvoLimpo.count >= 24 else { return nil } // alvo minúsculo: a frase fixa basta
        var usuario = "DEGRAU: \(max(0, degrau))" + blocoDoRetrato(retrato) + "\n\nNOTA:\n\(alvoLimpo.prefix(4000))"
        let p = pista.trimmingCharacters(in: .whitespacesAndNewlines)
        if !p.isEmpty { usuario += "\n\nPISTA JÁ VISÍVEL (não repita):\n\(p.prefix(600))" }
        // memo por (alvo, degrau): dentro do mesmo degrau a pergunta não deve
        // mudar, e sem isto abrir o Recordar dez vezes eram dez chamadas pagas
        // por uma nota que não mudou. Sobe o degrau, muda a chave, vem outra.
        guard let cru = await chamar(sistema: sistemaRecordar, usuario: usuario, temperatura: 0.5,
                                     memoPor: "prova\u{1}\(max(0, degrau))\u{1}\(alvoLimpo.hashValue)",
                                     mensagemLocal: {
            // Sacrifica retrato antes da pista; degrau e alvo ficam inteiros.
            mensagemDoAparelho(carga: "DEGRAU: \(max(0, degrau))\n\nNOTA:\n\(alvoLimpo)",
                contexto: "\n\nPISTA JÁ VISÍVEL (não repita):\n\(p.prefix(600))" + blocoDoRetrato(retrato))
        })
        else { return nil }
        return parsePerguntaDeRecordar(cru, alvo: alvoLimpo)
    }

    /// Quais pontos voltaram. Só números, e só os que existem.
    static func conferir(pontos: [String], memoria: String, gesto: Gesto?) async -> Set<Int>? {
        guard gesto != .expressiva, !pontos.isEmpty else { return nil }
        let escrito = memoria.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !escrito.isEmpty else { return nil }
        // ADR 05m: veredito sobre evidência cortada não é veredito. Se a memória ou um
        // ponto não cabe inteiro nos limites da montagem, cala — em qualquer caminho.
        guard escrito.count <= 4000, pontos.allSatisfy({ $0.count <= 400 }) else { return nil }
        let lista = pontos.enumerated()
            .map { "[\($0.offset)] \($0.element.prefix(400))" }
            .joined(separator: "\n")
        let usuario = "PONTOS:\n\(lista)\n\nDE MEMÓRIA:\n\(escrito.prefix(4000))"
        guard let cru = await chamar(sistema: sistemaConferir, usuario: usuario, temperatura: 0,
                                     memoPor: "conferir\u{1}\(usuario.hashValue)",
                                     mensagemLocal: { montarConferir(pontos: pontos, memoria: escrito) })
        else { return nil }
        return parseVoltaram(cru, pontos: pontos.count)
    }

    /// Os ecos desta nota entre as candidatas. `candidatas` é o texto EXATO que
    /// viaja: a prova literal é conferida contra ele, não contra a nota inteira.
    static func ecos(nota: String, candidatas: [String], gesto: Gesto?) async -> [Eco]? {
        guard gesto != .expressiva, !candidatas.isEmpty else { return nil }
        let corpo = candidatas.enumerated()
            .map { "[\($0.offset)] \($0.element)" }
            .joined(separator: "\n\n")
        let usuario = "NOTA:\n\(nota.prefix(3000))\n\nOUTRAS NOTAS:\n\(corpo.prefix(9000))"
        guard let cru = await chamar(sistema: sistemaEcos, usuario: usuario, temperatura: 0.2,
                                     memoPor: "ecos\u{1}\(usuario.hashValue)",
                                     mensagemLocal: {
            // Sacrifica candidatas; a nota-alvo e os cabeçalhos ficam inteiros.
            mensagemDoAparelho(carga: "NOTA:\n\(nota)\n\nOUTRAS NOTAS:\n", contexto: corpo)
        })
        else { return nil }
        return parseEcos(cru, candidatas: candidatas)
    }

    /// A sábia existe neste aparelho? Com conta, pelo Grok; sem conta, pelo
    /// modelo do sistema (ADR 04t). Sem nenhum dos dois, as sete superfícies
    /// dizem isso em vez de calar.
    static var disponivel: Bool {
        ContaGrok.ligada || noAparelho
    }

    /// O degrau do aparelho está de pé: modelo presente e o portão aberto.
    static var noAparelho: Bool {
        if #available(iOS 26.0, *) { return AnaliseDeBordo.disponivel && !Motores.desligados }
        return false
    }

    /// Para o cartão e o Perfil: por onde a sábia responde hoje.
    static var porOndeEmPalavras: String {
        if ContaGrok.ligada { return "pela sua conta Grok" }
        if noAparelho { return "pelo modelo do aparelho, sem rede" }
        return "precisa da sua conta Grok (em Perfil) ou da Apple Intelligence ligada"
    }

    /// Toda chamada da sábia passa pelo cliente único (ADR 03l). `memoPor` só
    /// quando repetir a pergunta DEVE dar a mesma resposta.
    ///
    /// ADR 04t — a escada da ADR 03k, aplicada à sábia: Grok primeiro quando há
    /// conta; o modelo do APARELHO quando não há, ou quando a rede falhou. Os
    /// parsers são os mesmos e continuam duros: JSON fora do formato é
    /// silêncio, venha de onde vier. A janela do aparelho é menor, então o
    /// chamador escolhe o contexto descartável; carga grande demais é silêncio.
    /// Vestir, calibragem e Padrões não cortam mais aqui: sem montagem própria,
    /// só seguem no aparelho se a mensagem inteira couber.
    static func chamar(sistema: String, usuario: String, temperatura: Double,
                       memoPor chave: String? = nil, mensagemLocal: (() -> String?)? = nil) async -> String? {
        if let r = await Grok.responder(sistema: sistema, usuario: usuario,
                                        temperatura: temperatura, memoPor: chave) {
            return r
        }
        // A recusa de orçamento não é resposta e nunca passa pelo memo do Grok.
        let pedido: String?
        if let mensagemLocal { pedido = mensagemLocal() }
        else { pedido = mensagemDoAparelho(carga: usuario) }
        guard let pedido else { return nil }
        return await noAparelho(sistema: sistema, usuario: pedido, temperatura: temperatura)
    }

    nonisolated static let tetoNoAparelho = 3500

    static func noAparelho(sistema: String, usuario: String, temperatura: Double) async -> String? {
        guard noAparelho, !usuario.isEmpty, usuario.count <= tetoNoAparelho else { return nil }
        if #available(iOS 26.0, *) {
            let sessao = LanguageModelSession(instructions: sistema)
            let opcoes = GenerationOptions(temperature: temperatura)
            guard let r = try? await sessao.respond(to: usuario, options: opcoes) else { return nil }
            return r.content
        }
        return nil
    }

    /// ADR 03o — a leitura da calibragem. O único lugar do app onde a IA olha
    /// para o AUTOR e não para um texto: o que ele esperava, o que aconteceu, e
    /// em que TIPO de situação a expectativa dele quebra.
    ///
    /// É a metade que faltava do ciclo. O app já multiplicava o trabalho da
    /// mente; isto devolve à mente uma coisa que ela não consegue ver sozinha,
    /// porque a memória reescreve a expectativa depois de saber o fim.
    ///
    /// E continua sendo PERGUNTA: quem conclui sobre o próprio juízo é ele.
    static let sistemaCalibrar = """
    Você lê pares do diário de decisão de uma pessoa: o que ela ESPERAVA que
    acontecesse, escrito ANTES, e o que ACONTECEU, escrito depois.
    Responda APENAS um JSON válido, sem markdown: {"perguntas": ["…"]}

    Regras absolutas:
    - No máximo 3 perguntas, cada uma com até 2 frases, terminando em "?".
    - Cada pergunta CITA um fragmento literal dos pares, entre aspas “…”.
    - Procure o PADRÃO entre os pares, não o caso isolado: o tipo de situação
      em que a expectativa erra sempre para o mesmo lado, o otimismo que volta,
      o prazo que sempre estica, a variável que ela nunca inclui.
    - PERGUNTAS, nunca vereditos. Proibido dar nota, medir acerto, elogiar,
      diagnosticar ou aconselhar. Quem conclui sobre o próprio juízo é ela.
    - Na dúvida, menos perguntas — ou nenhuma: {"perguntas": []}.
    """

    /// Lê a calibragem. `pares` é o texto EXATO que viaja, e contra o qual a
    /// citação literal é conferida.
    static func lerCalibragem(pares: [String]) async -> [String]? {
        // um par não é padrão: com menos de dois, a leitura seria adivinhação
        guard pares.count >= 2 else { return nil }
        let corpo = pares.enumerated()
            .map { "DECISÃO \($0.offset + 1):\n\($0.element)" }
            .joined(separator: "\n\n")
        guard let cru = await chamar(sistema: sistemaCalibrar, usuario: String(corpo.prefix(9000)),
                                     temperatura: 0.3,
                                     memoPor: "calibrar\u{1}\(corpo.hashValue)")
        else { return nil }
        return parseCalibragem(cru, pares: pares)
    }

    /// Mesma prova dura do `PadroesRemoto`: sem citação literal verificável, a
    /// pergunta é descartada. Aqui ela pesa ainda mais — é o juízo do autor
    /// sendo espelhado, e um espelho que inventa é pior que nenhum.
    nonisolated static func parseCalibragem(_ cru: String, pares: [String]) -> [String]? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"),
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let lista = j["perguntas"] as? [String]
        else { return nil }
        return Array(lista
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { PadroesRemoto.ehPergunta($0) && PadroesRemoto.citaOAutor($0, em: pares) }
            .map { AnaliseRemota.umaFrase($0, teto: 280) }
            .prefix(3))
    }

    // MARK: verificação dura (§19.4: só entra o que o algoritmo sabe checar)

    /// Mapa válido: um rótulo da lista por bloco existente. Índice repetido,
    /// fora do intervalo, forma desconhecida ou mais de um título = nil.
    nonisolated static func parseMapa(_ cru: String, blocos: Int) -> [Rotulo]? {
        guard let ini = cru.firstIndex(of: "["), let fim = cru.lastIndex(of: "]") else { return nil }
        guard let dados = String(cru[ini...fim]).data(using: .utf8),
              let lista = try? JSONSerialization.jsonObject(with: dados) as? [[String: Any]]
        else { return nil }
        var vistos = Set<Int>()
        var saida: [Rotulo] = []
        var titulos = 0
        for item in lista {
            guard let i = item["i"] as? Int, i >= 0, i < blocos, !vistos.contains(i),
                  let f = item["forma"] as? String, let forma = FormaDeBloco(rawValue: f) else { return nil }
            if forma == .titulo { titulos += 1 }
            vistos.insert(i)
            saida.append(Rotulo(i: i, forma: forma))
        }
        guard titulos <= 1, !saida.isEmpty else { return nil }
        return saida.sorted { $0.i < $1.i }
    }

    /// A pergunta da prova só passa se for pergunta, couber na tela e NÃO
    /// vazar. Recusa é silêncio: o ritual segue com a frase fixa de sempre.
    nonisolated static func parsePerguntaDeRecordar(_ cru: String, alvo: String) -> String? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"),
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let bruta = j["pergunta"] as? String
        else { return nil }
        let p = bruta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard p.hasSuffix("?"), p.count >= 10, p.count <= 160 else { return nil }
        guard !Prova.vaza(p, alvo: alvo) else { return nil }
        return p
    }

    /// Índices válidos e nada mais: fora do intervalo ou não-inteiro derruba a
    /// conferência INTEIRA, como o mapa de vestir. Meia conferência mentiria
    /// sobre o que não voltou.
    nonisolated static func parseVoltaram(_ cru: String, pontos: Int) -> Set<Int>? {
        guard pontos > 0,
              let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"), ini <= fim,
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              Set(j.keys) == ["voltaram"],
              let lista = j["voltaram"] as? [Any]
        else { return nil }
        var saida = Set<Int>()
        for item in lista {
            guard let numero = item as? NSNumber,
                  CFGetTypeID(numero as CFTypeRef) != CFBooleanGetTypeID(),
                  let i = item as? Int, i >= 0, i < pontos else { return nil }
            saida.insert(i)
        }
        return saida
    }

    /// Eco válido: índice que existe, e um trecho que aparece LITERALMENTE na
    /// candidata que ele diz ter lido. Mesma prova do `PadroesRemoto`: sem
    /// citação verificável, o eco é descartado — nunca mostrado com ressalva.
    nonisolated static func parseEcos(_ cru: String, candidatas: [String]) -> [Eco]? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}"),
              let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let lista = j["ecos"] as? [[String: Any]]
        else { return nil }
        var saida: [Eco] = []
        var vistos = Set<Int>()
        for item in lista {
            guard let i = item["i"] as? Int, i >= 0, i < candidatas.count, !vistos.contains(i),
                  let bruto = item["trecho"] as? String
            else { continue }
            let t = bruto.trimmingCharacters(in: .whitespacesAndNewlines)
            guard t.count >= 8, t.count <= 120,
                  candidatas[i].lowercased().contains(t.lowercased())
            else { continue }
            vistos.insert(i)
            saida.append(Eco(i: i, trecho: t))
            if saida.count == 3 { break }
        }
        return saida
    }

    /// Perguntas válidas: de 1 a 5, cada uma terminando em "?".
    nonisolated static func parsePerguntas(_ cru: String) -> [String]? {
        guard let ini = cru.firstIndex(of: "{"), let fim = cru.lastIndex(of: "}") else { return nil }
        guard let dados = String(cru[ini...fim]).data(using: .utf8),
              let j = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let lista = j["perguntas"] as? [String]
        else { return nil }
        let limpas = lista
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasSuffix("?") && $0.count > 8 && $0.count <= 240 }
        guard !limpas.isEmpty else { return nil }
        return Array(limpas.prefix(5))
    }

    /// A resposta tem teto e nunca vem em markdown pesado: é para ler no cartão.
    nonisolated static func limparResposta(_ cru: String, teto: Int = tetoResposta) -> String? {
        var s = cru.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: "**", with: "")
        s = s.replacingOccurrences(of: #"(?m)^#+\s*"#, with: "", options: .regularExpression)
        guard !s.isEmpty else { return nil }
        if s.count > teto { s = String(s.prefix(teto)).trimmingCharacters(in: .whitespaces) + "…" }
        return s
    }

    /// A linha "?" da nota: a última linha que começa com "?" e tem pergunta.
    nonisolated static func perguntaNaNota(_ texto: String) -> String? {
        let linhas = texto.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let linha = linhas.last(where: { $0.hasPrefix("?") }) else { return nil }
        let corpo = String(linha.dropFirst()).trimmingCharacters(in: .whitespaces)
        return corpo.count >= 4 ? corpo : nil
    }

    // MARK: aplicar o mapa (algoritmo: as palavras são as do autor)

    /// Os blocos do texto, como o `estruturar` os vê: separados por linha em branco.
    nonisolated static func blocos(_ texto: String) -> [String] {
        let normal = texto.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        var blocos: [String] = []
        var atual: [String] = []
        for l in normal.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
            if l.trimmingCharacters(in: .whitespaces).isEmpty {
                if !atual.isEmpty { blocos.append(atual.joined(separator: "\n")); atual = [] }
            } else {
                atual.append(l)
            }
        }
        if !atual.isEmpty { blocos.append(atual.joined(separator: "\n")) }
        return blocos
    }

    /// Veste cada bloco com a forma do mapa. Bloco já vestido não se toca.
    nonisolated static func aplicar(_ mapa: [Rotulo], a texto: String) -> String {
        let partes = blocos(texto)
        let formas = Dictionary(uniqueKeysWithValues: mapa.map { ($0.i, $0.forma) })
        var saida: [String] = []
        for (i, bloco) in partes.enumerated() {
            let linhas = bloco.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            let primeira = linhas.first ?? ""
            let jaVestido = primeira.hasPrefix("#") || primeira.hasPrefix("- ") || primeira.hasPrefix("* ")
                || primeira.hasPrefix("> ") || primeira.hasPrefix("```") || primeira.hasPrefix("|")
                || primeira.range(of: #"^\d+[.)] "#, options: .regularExpression) != nil
            guard !jaVestido, let forma = formas[i] else { saida.append(bloco); continue }
            switch forma {
            case .titulo: saida.append("# " + linhas.joined(separator: " "))
            case .secao: saida.append("## " + linhas.joined(separator: " "))
            case .lista: saida.append(linhas.map { "- " + $0 }.joined(separator: "\n"))
            case .numerada: saida.append(linhas.enumerated().map { "\($0.offset + 1). " + $0.element }.joined(separator: "\n"))
            case .tarefas: saida.append(linhas.map { "- [ ] " + $0 }.joined(separator: "\n"))
            case .citacao: saida.append(linhas.map { "> " + $0 }.joined(separator: "\n"))
            case .codigo: saida.append("```\n" + bloco + "\n```")
            case .tabela:
                let celulas = linhas.map { $0.split(whereSeparator: { $0 == "|" || $0 == "\t" }).map { $0.trimmingCharacters(in: .whitespaces) } }
                guard let cabeca = celulas.first, cabeca.count >= 2 else { saida.append(bloco); continue }
                var t = ["| " + cabeca.joined(separator: " | ") + " |", "|" + String(repeating: " --- |", count: cabeca.count)]
                for linha in celulas.dropFirst() { t.append("| " + linha.joined(separator: " | ") + " |") }
                saida.append(t.joined(separator: "\n"))
            case .prosa: saida.append(bloco)
            }
        }
        return saida.joined(separator: "\n\n")
    }
}
