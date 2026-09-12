import Foundation

/// O portão de TODOS os modelos — rede e aparelho (ADR 2026-09-03p).
///
/// Duas situações precisam do app pensando só com algoritmo, e as duas
/// morderam de verdade em 03/set:
///
/// 1. **A suíte.** As 82 suítes descrevem o motor LOCAL, que é determinístico.
///    Quando o autor ligou a conta no simulador, o token do chaveiro passou a
///    valer para o processo de teste e oito testes sem nenhuma relação com IA
///    começaram a falhar.
/// 2. **A varredura.** 86 fluxos × uma chamada por pausa de análise = a suíte
///    de teste gastando a assinatura do autor e levando o dobro do tempo.
///    Suíte que custa dinheiro é defeito de projeto.
///
/// Um portão, não uma guarda em cada chamador: assim não há como esquecer um.
/// Os dois fluxos que provam a IA de verdade — `pergunta-sabia` e
/// `lente-instigar` — simplesmente não levantam a bandeira.
nonisolated enum Motores {
    static let desligados: Bool = {
        let e = ProcessInfo.processInfo.environment
        let emTeste = e["XCTestConfigurationFilePath"] != nil
            || e["XCTestBundlePath"] != nil
            || NSClassFromString("XCTestCase") != nil
        // `launchApp: arguments:` do maestro NÃO chega ao app no iOS (provado em
        // 03/set: o fluxo com e sem a bandeira falhou idêntico). O canal que
        // funciona é o AMBIENTE do simulador, que o `clearState` não apaga
        // porque não vive no contêiner do app:
        //   xcrun simctl spawn booted launchctl setenv TRACO_SEM_MODELO 1
        return emTeste || e["TRACO_SEM_MODELO"] == "1"
            || UserDefaults.standard.bool(forKey: "motorSoLocal")
    }()
}

/// O único cliente da xAI (ADR 2026-09-03l). Antes eram TRÊS cópias da mesma
/// requisição — `AnaliseRemota`, `Sabia` e `PadroesRemoto` — cada uma com o seu
/// timeout, o seu tratamento de erro e a sua memoização. Ou a falta dela: o
/// `Sabia` não tinha nenhuma, e abrir o Recordar da mesma nota dez vezes eram
/// dez perguntas pagas por uma nota que não mudou.
///
/// Um lugar só significa: uma política de custo, um timeout, um ponto para
/// medir, e nenhuma chance de as três divergirem em silêncio.
///
/// Silêncio em erro continua sendo a lei: qualquer falha devolve nil e o
/// chamador desce a escada (§19.4).
nonisolated enum Grok {
    /// O padrão de TODAS as rotas, e ele é MEDIDO, não presumido (DIRETRIZ §10,
    /// ordem do dono de 09/09: "sempre use o melhor Grok possível"). A conta
    /// expõe doze modelos; a ADR 2026-09-09n mediu os dois candidatos capazes
    /// na mesma fixture de doze casos e escreveu por que este ganhou.
    ///
    /// Era `grok-4.3`, o padrão de 03/set, e foi ele que a 08q reprovou em
    /// `responder`: o modelo maior é a alavanca que o prompt não alcançou.
    static let modelo = sonda ?? padrao

    /// O modelo de UMA rota, quando a comparação pareada mediu que ela precisa
    /// de outro (ADR 2026-09-09v). O padrão global **não se move**: no LOTE-09d
    /// o `grok-4.5` ganhou de 21/21 contra 12/21 em `responderNasNotas` e, no
    /// LOTE-3, PERDEU em `contrapor` (renda inventada 3 de 3 contra 1 de 3).
    /// Um vencedor por operação, medido, é o que a DIRETRIZ §10 pede; um
    /// vencedor global consertaria uma rota e estragaria outra.
    ///
    /// A sonda vence sempre, e essa precedência é o ponto: cravar o modelo na
    /// rota sem ela cegaria a próxima comparação pareada — `TRACO_AVALIAR_MODELO`
    /// deixaria de alcançar justamente a rota escolhida, e o silêncio pareceria
    /// acordo.
    static func modelo(daRota medido: String) -> String { sonda ?? medido }
    /// SÓ PARA A SONDA (DEBUG, por ambiente). Nem todo modelo da conta aceita
    /// `reasoning_effort`: a família `grok-4.20` devolve `400 — Model … does
    /// not support parameter reasoningEffort` em TODA chamada, medido em
    /// 09/09 (ADR 09n). Sem esta chave não haveria como medir a qualidade
    /// desses modelos na mesma fixture, e a comparação ficaria por decreto.
    /// Em produção o campo vai sempre: é ele que faz o modelo pensar.
    static let semEsforco: Bool = {
#if DEBUG
        return ProcessInfo.processInfo.environment["TRACO_AVALIAR_SEM_ESFORCO"] == "1"
#else
        return false
#endif
    }()

    /// O MENOR esforço que o modelo escolhido aceita, e o padrão de quem não
    /// pede outro. Era `"none"` — e `"none"` **não existe** no `grok-4.6`:
    /// medido em 09/09, toda chamada volta `400 — This model does not support
    /// reasoning_effort value none` (`prova/q2e-rotas-esforco-none.jsonl`).
    /// Trocar o modelo global sem trocar este piso mataria em silêncio TODAS
    /// as rotas rápidas (`conferir`, `padroes`, `ecos`, `calibragem`,
    /// `recordar`, `vestir`, `instigar`, `contrapor`) — e `classificar` e
    /// `vestir`, que descem ao aparelho, cairiam caladas para o modelo pior,
    /// que é exatamente o que a ADR 07b existe para impedir.
    static let esforcoMinimo = "low"

    // REVERTIDO em 09/09 pelo G3 (revisao-q2-responder.md): a comparação
    // que escolheu o `grok-4.6` mudou DUAS alavancas (modelo e
    // `reasoning_effort`) e a triagem dos doze excluiu candidatos por nome e
    // posição, não por fato observado — então ela não decide o padrão global.
    // O padrão volta ao medido de 03/set até a Q2-F refazer a comparação com
    // uma alavanca só e a triagem por fato declarado.
    private static let padrao = "grok-4.3"

    /// SÓ PARA A SONDA, e por ambiente: comparar dois modelos exige o MESMO
    /// binário nos dois lados, senão a diferença medida não é do modelo. A
    /// sonda grava `modeloPadraoGlobal` em cada registro e o modelo de cada
    /// chamada em `chamadasGrok`, então a medida diz de si mesma o que rodou.
    /// Em Release não existe.
    private static let sonda: String? = {
#if DEBUG
        ProcessInfo.processInfo.environment["TRACO_AVALIAR_MODELO"]
#else
        nil
#endif
    }()

    /// O teto de tempo de TODA rota que raciocina, num lugar só (ADR
    /// 2026-09-08r, alargada pela 09n). Era `90` repetido em quatro chamadas
    /// do Trabalho, e a medida de 08/09 mostrou que ele cortava 20 de 72
    /// chamadas a `grok-4.6` — 28 % — sempre aos 91 s. Teto que corta a
    /// operação para o autor não é prudência: é a operação ausente.
    ///
    /// O valor tem duas partes, e confundi-las foi o defeito: um PISO OBSERVADO
    /// e uma MARGEM DECLARADA sobre ele.
    ///
    /// Piso observado: 178 s numa execução do Trabalho (08r), 77,5 s de pior
    /// caso em `responder` (09n, 36 execuções) — e **241 s** na corrida da Q3-D
    /// em 10/09 (`ferramentas/orca/RUMO.md:790`, `LACO.md:3221`). Os 241 s
    /// passaram POR CIMA dos 240: o teto cortou uma resposta que estava a
    /// caminho, e o que chegou ao autor foi um `semRetorno` **nosso**, não do
    /// modelo. Teto menor que a espera observada não é prudência: é a operação
    /// ausente com a culpa no lugar errado.
    ///
    /// Margem declarada: **300 s**, ~1,25× sobre os 241 s observados. Isto NÃO
    /// é um novo pior caso medido — ninguém mediu 300 — e NÃO é promessa ao
    /// autor: é orçamento de engenharia, e quem diz a verdade do tempo ao autor
    /// é a tela. A próxima medida que passar de 300 sobe o número de novo, com
    /// a mesma distinção escrita.
    ///
    /// Um número, não dois: o teto é do MODELO que raciocina, não da rota, e
    /// duas cópias do mesmo teto divergem em silêncio (ADR 03l). O teto governa
    /// só a REDE; a espera que o autor sente inclui a montagem do contexto
    /// antes dela.
    /// Ver `prova/qb-teto-*.jsonl` e `prova/q2-responder-modelo46.jsonl`.
    static let teto: TimeInterval = 300

    /// A maior espera JÁ OBSERVADA numa chamada real, em segundos. Separada do
    /// teto de propósito: uma é fato, a outra é decisão. O teste que as compara
    /// fica vermelho no dia em que a decisão descer abaixo do fato.
    static let esperaObservada: TimeInterval = 241
    private static let endereco = URL(string: "https://api.x.ai/v1/chat/completions")!

    // MARK: - memo

    /// O que já foi perguntado nesta sessão. Pequeno de propósito: serve para
    /// não repagar a MESMA pergunta (dispensar o cartão e pausar de novo, abrir
    /// o Recordar duas vezes), não para virar cache de verdade.
    private nonisolated(unsafe) static var memo: [(chave: String, resposta: String)] = []
    private static let tranca = NSLock()
    private static let tetoMemo = 32

    #if DEBUG
    static func modelosDisponiveis() async -> [String]? {
        guard !Motores.desligados, let token = await ContaGrok.token() else { return nil }
        var pedido = URLRequest(url: URL(string: "https://api.x.ai/v1/models")!)
        pedido.timeoutInterval = 20
        pedido.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        guard let (dados, resposta) = try? await URLSession.shared.data(for: pedido),
              (resposta as? HTTPURLResponse)?.statusCode == 200,
              let raiz = (try? JSONSerialization.jsonObject(with: dados)) as? [String: Any],
              let modelos = raiz["data"] as? [[String: Any]] else { return nil }
        return modelos.compactMap { $0["id"] as? String }.sorted()
    }

    struct Diagnostico: Codable, Sendable {
        var modeloSolicitado: String
        var modeloRespondido: String?
        var esforco: String
        var statusHTTP: Int?
        var tokensDeRaciocinio: Int?
        /// ADR 09n: o que a API DIZ quando recusa. Sem isto um `400` era um
        /// número mudo, e a triagem entre modelos não sabia dizer se o modelo
        /// é que não serve ou se o pedido é que não cabe nele — "rota que cala
        /// em vez de dizer" (DIRETRIZ §8). Só o texto de erro do provedor, e
        /// só em DEBUG: nada do pedido, nada do token.
        var erroDaAPI: String?
        /// ADR 2026-09-10b — o RETORNO BRUTO, antes de qualquer parser nosso.
        /// A sonda gravava `saida` já depois de `Sabia.limparResposta`, então
        /// medir a IA era medir o que sobrou do nosso tratamento: uma resposta
        /// cortada aos 900 chegava ao JSONL indistinguível de uma que coube.
        /// Fica no PORTÃO por onde todas as rotas passam — assim nenhuma das
        /// dezesseis fica sem o bruto, e nenhuma sonda futura precisa lembrar.
        var bruto: String?
        var desfecho: String
    }
    private nonisolated(unsafe) static var diagnosticos: [Diagnostico] = []
    static func retirarDiagnosticos() -> [Diagnostico] {
        tranca.lock(); defer { tranca.unlock() }
        defer { diagnosticos.removeAll() }
        return diagnosticos
    }
    private static func registrar(_ d: Diagnostico) {
        tranca.lock(); defer { tranca.unlock() }
        diagnosticos.append(d)
        if diagnosticos.count > 32 { diagnosticos.removeFirst() }
    }
    #endif

    private static func memoLido(_ chave: String) -> String? {
        tranca.lock(); defer { tranca.unlock() }
        return memo.last { $0.chave == chave }?.resposta
    }

    private static func memoGrava(_ chave: String, _ resposta: String) {
        tranca.lock(); defer { tranca.unlock() }
        memo.removeAll { $0.chave == chave }
        memo.append((chave, resposta))
        if memo.count > tetoMemo { memo.removeFirst(memo.count - tetoMemo) }
    }

    /// O autor saiu da conta: o que ele perguntou não fica na memória do app.
    static func esquecerMemo() {
        tranca.lock(); defer { tranca.unlock() }
        memo.removeAll()
    }

    // MARK: - a chamada

    /// Uma pergunta ao Grok. Devolve o texto cru; quem interpreta é o chamador,
    /// que é quem tem o contrato fechado para conferir.
    ///
    /// `memoPor` é a chave de cache. Nil = sempre chama. A regra: contrato
    /// determinístico (temperatura 0) memoiza porque repetir é desperdício
    /// puro; resposta criativa memoiza só quando repetir a pergunta DEVE dar a
    /// mesma coisa (a pergunta da prova num degrau, por exemplo). Onde o autor
    /// pede de novo esperando algo novo — instigar, padrões — não memoiza.
    static func responder(sistema: String, usuario: String, temperatura: Double,
                          timeout: TimeInterval = Grok.teto, memoPor chave: String? = nil,
                          esquema: String? = nil, esforco: String = Grok.esforcoMinimo,
                          modelo: String = Grok.modelo) async -> String? {
        // Esta chamada ainda não falhou. Sem limpar, um timeout velho
        // vira o motivo de uma recusa nova — inclusive quando o portão
        // de teste devolve nil sem nomear.
        limparFalha()
        guard !Motores.desligados else { return nil }
        if Task.isCancelled {
            registrarFalha(.cancelada)
            return nil
        }
        // Uma chave do chamador não pode reutilizar uma resposta de outro
        // pedido/schema. A validação continua depois da geração estruturada.
        let chave = chave.map { "\($0)\u{1}\(modelo)\u{1}\(esforco)\u{1}\(sistema)\u{1}\(usuario)\u{1}\(temperatura)\u{1}\(esquema ?? "")" }
        if let chave, let guardada = memoLido(chave) { return guardada }
        guard let token = await ContaGrok.token() else {
            registrarFalha(.semConta)
            return nil
        }
        guard !Task.isCancelled else {
            registrarFalha(.cancelada)
            return nil
        }
        guard let corpo = corpo(sistema: sistema, usuario: usuario,
                                temperatura: temperatura, esquema: esquema, esforco: esforco, modelo: modelo) else { return nil }
        var pedido = URLRequest(url: endereco)
        pedido.httpMethod = "POST"
        pedido.timeoutInterval = timeout
        pedido.setValue("application/json", forHTTPHeaderField: "Content-Type")
        pedido.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        pedido.httpBody = corpo
        #if DEBUG
        var diagnostico = Diagnostico(modeloSolicitado: modelo, esforco: esforco, desfecho: "sem resposta de transporte")
        defer { registrar(diagnostico) }
        #endif
        let dados: Data
        let resposta: URLResponse
        do {
            (dados, resposta) = try await URLSession.shared.data(for: pedido)
        } catch {
            let falha = falhaDoErro(error)
            registrarFalha(falha)
            #if DEBUG
            diagnostico.desfecho = falha.rawValue
            #endif
            return nil
        }
        #if DEBUG
        diagnostico.statusHTTP = (resposta as? HTTPURLResponse)?.statusCode
        let envelope = (try? JSONSerialization.jsonObject(with: dados)) as? [String: Any]
        diagnostico.modeloRespondido = envelope?["model"] as? String
        let uso = envelope?["usage"] as? [String: Any]
        let detalhes = uso?["completion_tokens_details"] as? [String: Any]
        diagnostico.tokensDeRaciocinio = detalhes?["reasoning_tokens"] as? Int
        diagnostico.desfecho = "HTTP ou conteúdo recusado"
        if diagnostico.statusHTTP != 200 {
            let erro = envelope?["error"]
            diagnostico.erroDaAPI = String(describing: erro ?? "sem corpo de erro").prefix(400).description
        }
        #endif
        if Task.isCancelled {
            registrarFalha(.cancelada)
            return nil
        }
        guard (resposta as? HTTPURLResponse)?.statusCode == 200,
              let msg = textoCompleto(dados) else {
            let falha = falhaDoCorpo(dados) ?? .transporte
            registrarFalha(falha)
            #if DEBUG
            diagnostico.desfecho = falha.rawValue
            #endif
            return nil
        }
        #if DEBUG
        diagnostico.desfecho = "conteúdo completo"
        diagnostico.bruto = msg
        #endif
        if let chave { memoGrava(chave, msg) }
        limparFalha()
        return msg
    }

    /// O schema vai no protocolo da API, não apenas numa promessa no prompt.
    /// JSON válido ainda precisa das verificações de domínio e de conteúdo.
    static func corpo(sistema: String, usuario: String, temperatura: Double,
                      esquema: String?, esforco: String = Grok.esforcoMinimo, modelo: String = Grok.modelo) -> Data? {
        guard ["none", "low", "medium", "high"].contains(esforco) else { return nil }
        var corpo: [String: Any] = [
            "model": modelo,
            "temperature": temperatura,
            "messages": [
                ["role": "system", "content": sistema],
                ["role": "user", "content": usuario],
            ],
        ]
        if !semEsforco { corpo["reasoning_effort"] = esforco }
        if let esquema {
            guard let dados = esquema.data(using: .utf8),
                  let schema = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
                  schema["type"] as? String == "object" else { return nil }
            corpo["response_format"] = [
                "type": "json_schema",
                "json_schema": ["name": "resposta_traco", "strict": true, "schema": schema],
            ]
        }
        return try? JSONSerialization.data(withJSONObject: corpo)
    }

    /// HTTP 200 também pode conter resposta cortada por limite ou recusa.
    /// Nenhuma delas vira versão pronta ou entra no cache.
    static func textoCompleto(_ dados: Data) -> String? {
        guard let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let escolhas = raiz["choices"] as? [[String: Any]],
              let escolha = escolhas.first,
              escolha["finish_reason"] as? String == "stop",
              let mensagem = escolha["message"] as? [String: Any],
              (mensagem["refusal"] as? String ?? "").isEmpty,
              let msg = mensagem["content"] as? String,
              !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }
        return msg
    }

    /// Q7 — o vazio tem nome. Timeout, cancelar, limite e recusa não viram
    /// resposta pronta nem qualidade simulada. O que a pessoa escreveu fica.
    enum FalhaHonesta: String, Sendable, Equatable {
        case cancelada, timeout, recusa, limite, transporte, semConta
    }

    private nonisolated(unsafe) static var ultimaFalha: FalhaHonesta?

    static func retirarFalha() -> FalhaHonesta? {
        tranca.lock(); defer { tranca.unlock() }
        defer { ultimaFalha = nil }
        return ultimaFalha
    }

    /// Lê sem consumir. `nil` = esta chamada não nomeou a falha.
    static func falhaPendente() -> FalhaHonesta? {
        tranca.lock(); defer { tranca.unlock() }
        return ultimaFalha
    }

    static func registrarFalha(_ f: FalhaHonesta) {
        tranca.lock(); defer { tranca.unlock() }
        ultimaFalha = f
    }

    static func limparFalha() {
        tranca.lock(); defer { tranca.unlock() }
        ultimaFalha = nil
    }

    static func falhaDoErro(_ erro: Error) -> FalhaHonesta {
        if erro is CancellationError { return .cancelada }
        if let u = erro as? URLError {
            if u.code == .timedOut { return .timeout }
            if u.code == .cancelled { return .cancelada }
        }
        return .transporte
    }

    static func falhaDoCorpo(_ dados: Data) -> FalhaHonesta? {
        if textoCompleto(dados) != nil { return nil }
        guard let raiz = try? JSONSerialization.jsonObject(with: dados) as? [String: Any],
              let escolhas = raiz["choices"] as? [[String: Any]],
              let escolha = escolhas.first
        else { return .transporte }
        let mensagem = escolha["message"] as? [String: Any]
        if let recusa = mensagem?["refusal"] as? String, !recusa.isEmpty { return .recusa }
        switch escolha["finish_reason"] as? String {
        case "length": return .limite
        case "content_filter": return .recusa
        default: return .transporte
        }
    }

    static func frase(_ f: FalhaHonesta) -> String {
        switch f {
        case .cancelada: "Você parou. O que escreveu continua aqui."
        case .timeout: "A espera estourou. O que escreveu continua aqui; nada foi inventado no lugar."
        case .recusa: "O provedor recusou. O que escreveu continua aqui; não invento no lugar."
        case .limite: "A resposta veio cortada pelo limite. Não mostro um pedaço como se fosse o todo."
        case .transporte: "A rede não entregou. O que escreveu continua aqui."
        case .semConta: "Falta a conta. O que escreveu continua aqui."
        }
    }

    /// O que a tela diz quando a chamada calou. Lê sem consumir — a
    /// view pode perguntar mais de uma vez no mesmo estado.
    static func avisoDaFalha() -> String {
        tranca.lock(); defer { tranca.unlock() }
        if let f = ultimaFalha { return frase(f) }
        return "a sábia não respondeu. o que você escreveu continua aqui."
    }
}
