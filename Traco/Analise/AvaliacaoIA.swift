#if DEBUG
import CryptoKit
import Foundation
import SwiftData

/// Sonda explícita, com entradas sintéticas: não consulta nem grava o corpus.
/// Lançar com TRACO_AVALIAR_IA=<fixture.json> no Documents do app. O JSONL
/// registra o retorno real das APIs, não uma nota nem o texto bruto descartado
/// pelos parsers. Isso mede os motores; a jornada e o selo exigem prova própria.
@MainActor
enum AvaliacaoIA {
    private static var iniciou = false
    private static let operacoes = ["produzir", "prepararPratica", "conferirTentativa", "revisar",
        "responderNasNotas", "responder", "instigar", "contrapor", "vestir", "recordar",
        "conferir", "ecos", "calibragem", "padroes", "classificar", "dominio", "modelosGrok", "escolherRegra"]

    /// QUAL pedido rodou cada caso, pelo dado e não pelo nome do arquivo. A
    /// 10b precisou reconstruir isto procurando os 2.327 bytes do prompt DENTRO
    /// do dylib instalado; a 10c mede DOIS braços de `instigar` no MESMO
    /// binário, e sem o carimbo os dois JSONL seriam indistinguíveis.
    ///
    /// **Está aqui, e não na cauda do dicionário do registro, porque lá as duas
    /// chaves caíam na mesma linha que fecha o literal** — e uma mescla de
    /// afogadilho derrubava uma delas EM SILÊNCIO, deixando a corrida seguinte
    /// com cara de medida. Um carimbo que some sem barulho é pior que um
    /// carimbo que nunca existiu. `AvaliacaoIACarimboTests` fica vermelho se
    /// qualquer uma sumir, e a rota nova entra aqui em vez de na cauda.
    static var carimbosDoPedido: [String: String] {
        ["pedidoResponderSHA256": sha256(Sabia.sistemaResponder),
         "pedidoInstigarSHA256": sha256(Sabia.pedidoDeInstigar),
         "pedidoResponderNasNotasSHA256": sha256(Sabia.sistemaResponderNasNotas),
         "pedidoConferenciaNotasSHA256": sha256(Sabia.sistemaConferirNasNotas)]
    }

    /// Identidade da régua 11a e da porta de um par, sem gastar o provedor.
    /// Em 12/09 o aparelho do dono carimbou os pedidos vigentes e mesmo assim
    /// `qn-calibragem-par-unico` calou em 0,3 ms com a rota liberada — a porta
    /// velha (`pares.count >= 2`) ainda estava no binário instalado. Sem estas
    /// chaves, carimbo de prompt casa com candidato novo e mede código velho.
    static var carimbosDaRegua: [String: String] {
        [
            "portaCalibragemAceitaUmPar": Sabia.paresDaCalibragem(["um"]) ? "true" : "false",
            "reguaLisboaNaoVaza": Prova.vaza(
                "Qual é a capital de Portugal?",
                alvo: "A capital de Portugal é Lisboa.") ? "false" : "true",
        ]
    }

    static func sha256(_ t: String) -> String {
        SHA256.hash(data: Data(t.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private struct Lote: Codable {
        var repeticoes: Int?
        var casos: [Caso]
    }

    private struct Caso: Codable {
        var id: String
        var operacao: String
        var repeticoes: Int?
        var entrada: Entrada
        var requisitos: [String]?
    }

    private struct Entrada: Codable {
        var documento: DocumentoTrabalho?
        var texto: String?
        var pergunta: String?
        var contexto: String?
        /// ADR 2026-09-10g: a sonda passava `contexto` já PRONTO, e com isso a
        /// montagem — que é a alavanca desta volta — ficava fora da medida.
        /// Com `pagina` e `vizinhas` a sonda entra pela mesma porta da
        /// produção: `Sabia.contextoDaPergunta` monta, e o que viaja é o que
        /// o autor veria viajar. `contexto` continua valendo para as fixtures
        /// antigas (`prova/10b-casos.json` roda sem uma palavra mudada).
        var pagina: String?
        var vizinhas: [Vizinha]?
        var fontes: [FonteNotas]?
        var retrato: String?
        var gesto: String?
        var degrau: Int?
        var itens: [String]?
        var pista: String?
        var campos: [String: String]?
        var intencao: String?
        var resultado: String?
        var instrucao: String?
        var apoio: DocumentoTrabalho.Apoio?
        var trechoExercitado: String?
        var artefato: String?
        var pratica: DocumentoTrabalho.Pratica?
        var tentativa: String?
        var apoioUtilizado: String?
        var conversa: [Troca]?
        /// ADR 2026-09-16k: um caderno de notas do autor; a sonda monta um
        /// caderno em memória com elas e as obras de `itens` e passa pela
        /// SELEÇÃO da sessão (contexto, candidatas, escolha pelo sentido).
        var caderno: [NotaDoCaso]?
    }

    private struct NotaDoCaso: Codable {
        var texto: String
        var gesto: String?
        var campos: [String: String]?
    }

    /// ADR 2026-09-09h — a produção passa a conversa anterior
    /// (`Sessao.responderNasNotas`) e a sonda não passava: a base `conversa` e
    /// a mistura "fato na fala dela + gasto na nota" nunca foram medidas. Só
    /// as duas falas; `dependencias` é estado do caderno, que a sonda não tem.
    private struct Vizinha: Codable {
        var titulo: String
        var prosa: String
    }

    private struct Troca: Codable {
        var pergunta: String
        var resposta: String
    }

    private enum Falha: Error {
        case arquivoInvalido, loteInvalido, operacaoDesconhecida(String)
        case entradaAusente(String), semRetorno
    }

    /// O braço do CONTEXTO (ADR 2026-09-10g). Os dois moram no MESMO binário
    /// e o ambiente escolhe qual roda: `TRACO_AVALIAR_CONTEXTO=antigo` devolve
    /// a montagem da 10b, qualquer outro valor (ou nenhum) roda a desta volta.
    /// Sem isto, "antes" e "depois" seriam dois dylibs — e a medida somaria a
    /// compilação à alavanca.
    static let bracoDoContexto = ProcessInfo.processInfo.environment["TRACO_AVALIAR_CONTEXTO"] ?? "novo"

    /// As obras da biblioteca postas no Documents ao lado da fixture (16g/16i),
    /// pelo import do app; nome com caminho é recusado.
    private static func obrasDoDocuments(_ itens: [String]) throws -> [String] {
        let documentos = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                     appropriateFor: nil, create: false)
        return try itens.map { nome -> String in
            guard nome == URL(fileURLWithPath: nome).lastPathComponent else { throw Falha.arquivoInvalido }
            let bruto = try String(contentsOf: documentos.appendingPathComponent(nome), encoding: .utf8)
            return try exigir(Corpus.importar(bruto).first?.texto, "obra \(nome)")
        }
    }

    /// A montagem do braço escolhido, ou `nil` quando a fixture não traz
    /// `pagina` — aí o caso é dos antigos e usa o `contexto` já pronto.
    private static func montagem(_ e: Entrada) -> (contexto: String, viajaram: [String])? {
        guard let pagina = e.pagina else { return nil }
        let vz = (e.vizinhas ?? []).map { (titulo: $0.titulo, prosa: $0.prosa) }
        return bracoDoContexto == "antigo"
            ? Sabia.contextoDaPerguntaComoEraNa10b(pagina: pagina, vizinhas: vz)
            : Sabia.contextoDaPergunta(pagina: pagina, vizinhas: vz)
    }

    static func executarSeSolicitado() async {
        guard !iniciou, let nome = ProcessInfo.processInfo.environment["TRACO_AVALIAR_IA"] else { return }
        iniciou = true
        let corrida = UUID().uuidString
        do {
            guard !Motores.desligados else { throw Falha.loteInvalido }
            guard !nome.isEmpty, nome == URL(fileURLWithPath: nome).lastPathComponent,
                  nome.hasSuffix(".json") else { throw Falha.arquivoInvalido }
            let documentos = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                         appropriateFor: nil, create: false)
            let origem = documentos.appendingPathComponent(nome)
            let destino = documentos.appendingPathComponent("avaliacoes-ia.jsonl")
            for url in [origem, destino] where FileManager.default.fileExists(atPath: url.path) {
                guard try url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink != true
                else { throw Falha.arquivoInvalido }
            }
            guard origem.resolvingSymlinksInPath().deletingLastPathComponent() == documentos.resolvingSymlinksInPath(),
                  destino.resolvingSymlinksInPath().deletingLastPathComponent() == documentos.resolvingSymlinksInPath()
            else { throw Falha.arquivoInvalido }
            let dados = try Data(contentsOf: origem)
            let lote = try JSONDecoder().decode(Lote.self, from: dados)
            guard !lote.casos.isEmpty, Set(lote.casos.map(\.id)).count == lote.casos.count,
                  lote.casos.allSatisfy({ !$0.id.isEmpty && operacoes.contains($0.operacao)
                    && ($0.repeticoes ?? lote.repeticoes ?? 1) > 0 })
            else { throw Falha.loteInvalido }
            if !FileManager.default.fileExists(atPath: destino.path) {
                guard FileManager.default.createFile(atPath: destino.path, contents: nil) else {
                    throw Falha.arquivoInvalido
                }
            }
            let arquivo = try FileHandle(forWritingTo: destino)
            defer { try? arquivo.close() }
            try arquivo.seekToEnd()
            // ADR 2026-09-10d — os dois braços do `contrapor` vivem no MESMO
            // dylib, então o SHA do binário não distingue qual rodou. O que
            // distingue é o PEDIDO, e ele vai em TODA linha (não só no caso):
            // a dúvida "o binário era outro" morre linha a linha, e não por
            // um cabeçalho que se perde quando alguém corta o arquivo.
            let sistemaContraporQueRodou = Sabia.contraporSemEsquema
                ? Sabia.sistemaContrapor : Sabia.sistemaContraporComEsquema
            let assinaturaDoContrapor: [String: Any] = [
                "bracoContrapor": Sabia.contraporSemEsquema ? "antigo-sem-esquema" : "esquema-da-saida",
                "pedidoContraporSHA256": SHA256.hash(data: Data(sistemaContraporQueRodou.utf8))
                    .map { String(format: "%02x", $0) }.joined(),
            ]
            func gravar(_ campos: [String: Any]) throws {
                var linha = campos
                linha["corrida"] = corrida
                linha["data"] = Date.now.ISO8601Format()
                linha.merge(assinaturaDoContrapor) { atual, _ in atual }
                // Pedido, régua e porta em TODA linha — inclusive `inicio`.
                // A fumaça de 12/09 no aparelho casou o pedido e mediu a porta
                // velha; carimbo só no caso deixava o cabeçalho mentir.
                for (chave, sha) in carimbosDoPedido { linha[chave] = sha }
                for (chave, v) in carimbosDaRegua { linha[chave] = v }
                let json = try JSONSerialization.data(withJSONObject: linha, options: [.sortedKeys, .fragmentsAllowed])
                try arquivo.write(contentsOf: json + Data([0x0A]))
                try arquivo.synchronize()
            }
            try gravar(["evento": "inicio", "fixture": nome,
                        "fixtureSHA256": SHA256.hash(data: dados).map { String(format: "%02x", $0) }.joined(),
                        "operacoesDisponiveis": operacoes, "lote": try objeto(lote),
                        "sistema": ProcessInfo.processInfo.operatingSystemVersionString])
            for caso in lote.casos {
                for repeticao in 1...(caso.repeticoes ?? lote.repeticoes ?? 1) {
                    try Task.checkCancellation()
                    Grok.esquecerMemo()
                    _ = Grok.retirarDiagnosticos()
                    _ = MotorTrabalho.retirarRecusasDaPreparacao()
                    _ = Sabia.retirarGuardasQueApagaram()
                    PadroesRemoto.esquecerMemo()
                    var registro: [String: Any] = ["id": caso.id, "operacao": caso.operacao,
                        "repeticao": repeticao, "entrada": try objeto(caso.entrada),
                        // ADR 2026-09-09v: o nome diz o que o campo é. Desde que
                        // uma rota pode ter modelo próprio, o padrão global NÃO
                        // é mais "o modelo que rodou este caso" — quem quer isso
                        // lê `chamadasGrok[].modeloSolicitado`, que é por chamada.
                        "modeloPadraoGlobal": Grok.modelo,
                        "contaGrokLigada": ContaGrok.ligada,
                        "modeloDoAparelhoDisponivel": AnaliseDeBordo.disponivel,
                        "motoresDesligados": Motores.desligados,
                        // ADR 08z: a corrida diz em que condição foi feita. Uma
                        // operação indisponível por qualidade só alcança o
                        // provedor se estiver listada aqui.
                        "operacoesLiberadasParaAvaliacao": Politica.liberadasParaAvaliacao.sorted(),
                        // ADR 2026-09-10g: QUAL montagem rodou este caso. Vai
                        // em TODA linha, inclusive nas dos casos que não usam
                        // montagem — uma linha sem braço é uma linha que não
                        // sabe dizer de que corrida é.
                        "contextoBraco": bracoDoContexto]
                    if let m = montagem(caso.entrada) {
                        // O texto INTEIRO que viajou, e o seu sha: a leitura do
                        // G3 é sobre o que o modelo recebeu, não sobre o que a
                        // fixture prometeu. Sem isto o braço seria uma palavra
                        // no cabeçalho, sem prova de que mudou alguma coisa.
                        registro["contextoMontado"] = m.contexto
                        registro["contextoSHA256"] = SHA256.hash(data: Data(m.contexto.utf8))
                            .map { String(format: "%02x", $0) }.joined()
                        registro["contextoChars"] = m.contexto.count
                        registro["contextoViajaram"] = m.viajaram
                    }
                    // ADR 2026-09-10b, generalizado em `main`: QUAL pedido rodou
                    // este caso, por operação. A Q2-F teve de reconstruir isso
                    // procurando o prompt DENTRO do dylib instalado; uma linha
                    // aqui e a corrida diz de si mesma qual texto mandou.
                    registro["evento"] = "casoIniciado"
                    try gravar(registro)
                    let inicio = ContinuousClock.now
                    do {
                        registro["saida"] = try await executar(caso)
                    } catch {
                        registro["erro"] = String(reflecting: error)
                    }
                    registro["chamadasGrok"] = try objeto(Grok.retirarDiagnosticos())
                    // ADR 08p: quando o provedor entrega e o nosso contrato
                    // recusa, a linha redigida diz qual guarda foi.
                    let recusas = MotorTrabalho.retirarRecusasDaPreparacao()
                    if !recusas.isEmpty { registro["recusasDaPreparacao"] = recusas }
                    // ADR 2026-09-09s: o LOTE-3 só sabia dizer "vazio". Quem
                    // apagou a frase — e qual chave — é o que decide se a
                    // guarda está certa ou estreita na volta seguinte.
                    let guardas = Sabia.retirarGuardasQueApagaram()
                    if !guardas.isEmpty { registro["guardasQueApagaram"] = guardas }
                    let duracao = inicio.duration(to: .now).components
                    registro["duracaoSegundos"] = Double(duracao.seconds) + Double(duracao.attoseconds) / 1e18
                    registro["evento"] = "casoConcluido"
                    try gravar(registro)
                }
            }
            try gravar(["evento": "fim"])
            // A fixture é nossa, não do caderno. Some depois da corrida para
            // não ficar no Files. O JSONL fica — quem mediu é que o recolhe.
            try? FileManager.default.removeItem(at: origem)
        } catch {
            // Uma falha de IO não vira corrida concluída; preserve o prefixo
            // JSONL já sincronizado e exponha o motivo no console do processo.
            print("AvaliacaoIA \(corrida) interrompida: \(String(reflecting: error))")
        }
    }

    private static func objeto<T: Encodable>(_ valor: T) throws -> Any {
        try JSONSerialization.jsonObject(with: JSONEncoder().encode(valor), options: [.fragmentsAllowed])
    }

    private static func exigir<T>(_ valor: T?, _ campo: String = "retorno da API") throws -> T {
        guard let valor else {
            if campo == "retorno da API" { throw Falha.semRetorno }
            throw Falha.entradaAusente(campo)
        }
        return valor
    }

    private static func executar(_ caso: Caso) async throws -> Any {
        let e = caso.entrada
        let texto = e.texto ?? ""
        let itens = e.itens ?? []
        let gesto = e.gesto.flatMap { Gesto(rawValue: $0) }
        switch caso.operacao {
        case "modelosGrok":
            return ["modelosDisponiveis": try exigir(await Grok.modelosDisponiveis())]
        case "produzir", "prepararPratica", "revisar":
            var documento: DocumentoTrabalho
            if let anterior = e.documento {
                try anterior.validar()
                documento = anterior
            } else {
                documento = DocumentoTrabalho(intencao: try exigir(e.intencao, "intencao"), resultado: e.resultado ?? "")
                documento.apoio = caso.operacao == "prepararPratica" ? .praticar : .delegar
            }
            if let apoio = e.apoio { documento.apoio = apoio }
            if let trecho = e.trechoExercitado { documento.trechoExercitado = trecho }
            if let anterior = e.artefato { try documento.guardarVersaoHumana(anterior) }
            let pedido = try documento.iniciarPedido(exigir(e.instrucao, "instrucao"))
            if caso.operacao == "produzir" {
                let r = try await MotorTrabalho.produzir(documento, pedido)
                var saida: [String: Any] = ["texto": r.texto, "produtor": r.produtor]
                if let pratica = r.pratica { saida["pratica"] = try objeto(pratica) }
                if let parteDelegada = r.parteDelegada { saida["parteDelegada"] = parteDelegada }
                return saida
            }
            if caso.operacao == "prepararPratica" {
                let r = try exigir(await MotorTrabalho.prepararPratica(documento, pedido))
                return ["pratica": try objeto(r.pratica), "produtor": r.produtor]
            }
            let artefato = try exigir(e.artefato, "artefato")
            let anteriores = documento.instrucoesAnteriores(ao: pedido)
            let local = ConferenciaTrabalho.conferir(pedido: pedido, intencao: documento.intencaoAtual, artefato: artefato, instrucoesAnteriores: anteriores)
            return try objeto(await RevisaoTrabalho.revisar(pedido: pedido, intencao: documento.intencaoAtual,
                                                           artefato: artefato, criterios: local.resultados, instrucoesAnteriores: anteriores))
        case "conferirTentativa":
            return try objeto(await MotorTrabalho.conferirTentativa(pratica: exigir(e.pratica, "pratica"),
                tentativa: exigir(e.tentativa, "tentativa"), apoioUtilizado: exigir(e.apoioUtilizado, "apoioUtilizado")))
        case "responderNasNotas":
            // ADR 08q: `fontes` é OBRIGATÓRIO. A conveniência que aceitava
            // `contexto` embrulhava a prosa inteira numa fonte sintética
            // chamada "Contexto fornecido" — um título do próprio app, que a
            // medida de 08/09 leu como atribuição genérica do provedor. A
            // sonda só exercita a rota que a produção usa (Sessao.responderNasNotas).
            // ADR 2026-09-16i: `itens` são obras CONFERIDAS no Documents (a
            // biblioteca), e passam pela mesma candidatura da Sessao
            let pergunta = try exigir(e.pergunta, "pergunta")
            var obras = try obrasDoDocuments(itens).map { texto in
                FonteNotas(id: UUID(), titulo: (texto.split(separator: "\n").first.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "# ")) } ?? "obra") + " · obra",
                           texto: texto, editadaEm: .now, obraConferida: true)
            }.filter { Sessao.obraCandidata($0, pergunta: pergunta) }
            var fontesDoCaso = try exigir(e.fontes, "fontes")
            var idsDoCaderno: [UUID] = []
            var candidatas = 0
            var obrasNoCaderno = 0
            var retratoCompleto = e.retrato ?? ""
            var retratoCortados: [String] = []
            if let caderno = e.caderno {
                let recipiente = try ModelContainer.traco(emMemoria: true)
                let ctx = recipiente.mainContext
                for n in caderno {
                    let nota = Nota(texto: n.texto, gesto: n.gesto.flatMap(Gesto.init(rawValue:)), campos: n.campos ?? [:])
                    ctx.insert(nota)
                    idsDoCaderno.append(nota.uuid)
                }
                for texto in try obrasDoDocuments(itens) {
                    let obra = Nota(texto: texto)
                    obra.origem = .obra
                    ctx.insert(obra)
                }
                try ctx.save()
                if e.retrato == nil {
                    (retratoCompleto, retratoCortados) = Retrato.lerComRecibo(notas: (try ctx.fetch(FetchDescriptor<Nota>())).map(\.paraRetrato), sinais: [])
                }
                let base = Sessao().contextoDasNotas(pergunta: pergunta, no: ctx)
                obrasNoCaderno = base.filter(\.obra).count
                let doAutor = Sessao.candidatasDoAutor(pergunta: pergunta, no: ctx)
                candidatas = doAutor.count
                fontesDoCaso += await Sessao.comNotasPeloSentido(pergunta: pergunta, fontes: base, candidatas: doAutor,
                                                                 perguntar: Sessao.escolherNotasPelaConta)
                obras = []  // as do caderno já vieram pela seleção da sessão
            }
            // E7: o catálogo e o retrato como a sessão manda (pela pergunta); o tamanho
            // do pacote antes (catálogo e retrato inteiros) e depois, sobre as MESMAS fontes
            let catalogo = Sessao.catalogoParaPergunta(pergunta)
            let retrato = Retrato.pertinente(retratoCompleto, pergunta: pergunta)
            let antes = RespostaNotas.montar(pergunta: pergunta, fontes: fontesDoCaso + obras, conversa: [],
                                             catalogo: Sessao.catalogoCompleto, retrato: retratoCompleto, teto: 16_000)
            let depois = RespostaNotas.montar(pergunta: pergunta, fontes: fontesDoCaso + obras, conversa: [],
                                              catalogo: catalogo, retrato: retrato, teto: 16_000)
            let r = try exigir(await Sabia.responderNasNotas(pergunta: pergunta,
                fontes: fontesDoCaso + obras,
                conversa: (e.conversa ?? []).map { .init(pergunta: $0.pergunta, resposta: $0.resposta) },
                catalogo: catalogo, retrato: retrato))
            var saida: [String: Any] = [
                "pacoteChars": r.tamanhoDoPacote, "foraDoPacote": r.fora,
                "pacoteCharsInteiros": antes?.mensagem.count ?? -1, "pacoteCharsPelaPergunta": depois?.mensagem.count ?? -1,
                "catalogoFoi": !catalogo.isEmpty, "retratoChars": retrato.count, "retratoCompletoChars": retratoCompleto.count, "retratoCortados": retratoCortados,
                "texto": r.texto, "fontesEnviadas": try objeto(r.enviadas), "fontesCitadas": try objeto(r.citadas),
                // ADR 09h: o autor não vê o rótulo interno; a MEDIDA vê.
                "escreveuRotuloInterno": r.escreveuRotuloInterno,
                "conferida": r.conferida,
                "reparadaNaConferencia": r.reparadaNaConferencia,
            ]
            if let candidato = r.candidato { saida["candidato"] = candidato }
            if let conferencia = r.conferencia { saida["conferencia"] = conferencia }
            if let base = r.base { saida["base"] = base }
            if let obra = r.obraParaPlantar { saida["obraParaPlantar"] = obra }
            if let via = r.viaObra { saida["viaObra"] = via }
            saida["obrasCandidatas"] = e.caderno == nil ? obras.count : obrasNoCaderno
            if e.caderno != nil {
                // os índices (base 0) das notas do caderno que foram ao pedido
                saida["notasEnviadas"] = r.enviadas.compactMap { f in idsDoCaderno.firstIndex(of: f.id) }
                saida["candidatasDoAutor"] = candidatas
            }
            // as chaves (vídeo com minuto) das seções de obra que viajaram
            saida["secoesEnviadas"] = r.enviadas.filter(\.obra).flatMap { Obra.secoes($0.texto).map(\.chave) }
            return saida
        case "responder":
            // ADR 2026-09-10b: o que sai daqui é a saída TRATADA. O retorno
            // BRUTO do provedor viaja em `chamadasGrok[].bruto` — sem ele a
            // medida lia o que sobrou do nosso `limparResposta` e chamava
            // isso de "o modelo". A evidência liga os dois na mesma linha.
            return try exigir(await Sabia.responder(pergunta: exigir(e.pergunta, "pergunta"),
                contexto: montagem(e)?.contexto ?? e.contexto ?? "",
                gesto: gesto, retrato: e.retrato ?? ""))
        case "instigar":
            // ADR 2026-09-10c: o que sai daqui é a saída TRATADA — `parsePerguntas`
            // já derrubou a pergunta curta, a longa e a que vazou o nosso andaime,
            // e some sem deixar rastro. O retorno BRUTO viaja em
            // `chamadasGrok[].bruto`: sem ele a medida conta o que sobrou da nossa
            // guarda e chama isso de "o modelo".
            return try exigir(await Sabia.instigar(texto: texto, gesto: gesto, degrau: e.degrau ?? 0, retrato: e.retrato ?? ""))
        case "contrapor":
            let r = try exigir(await Sabia.contrapor(texto: texto, gesto: gesto, retrato: e.retrato ?? ""))
            return ["contra": r.contra, "foraDaLista": r.foraDaLista, "outroCampo": r.outroCampo]
        case "vestir":
            let blocos = e.itens ?? Sabia.blocos(texto)
            let r = try exigir(await Sabia.vestir(blocos: blocos, gesto: gesto))
            return ["mapa": r.map { ["i": $0.i, "forma": $0.forma.rawValue] as [String: Any] },
                    "textoAplicado": Sabia.aplicar(r, a: e.itens == nil ? texto : blocos.joined(separator: "\n\n"))]
        case "recordar":
            return try exigir(await Sabia.perguntaDeRecordar(alvo: texto, pista: e.pista ?? "", gesto: gesto,
                degrau: e.degrau ?? 0, retrato: e.retrato ?? ""))
        case "conferir":
            return try exigir(await Sabia.conferir(pontos: itens, memoria: texto, gesto: gesto)).sorted()
        case "ecos":
            return try exigir(await Sabia.ecos(nota: texto, candidatas: itens, gesto: gesto))
                .map { ["i": $0.i, "trecho": $0.trecho] as [String: Any] }
        case "calibragem":
            return try exigir(await Sabia.lerCalibragem(pares: itens))
        case "padroes":
            return try exigir(await PadroesRemoto.perguntas(vozes: itens))
        case "classificar":
            var remoto: AnaliseLocal.Veredito?
            if gesto == nil {
                remoto = await AnaliseRemota.classificar(texto: Caderno.prosa(de: texto), gestoAtual: gesto)
                if remoto == nil {
                    remoto = await AnaliseDeBordo.classificar(texto: Caderno.prosa(de: texto), gestoAtual: gesto)
                }
            }
            let campos = e.campos ?? [:]
            let local = AnaliseLocal.classificar(texto: texto, gestoAtual: gesto, campos: campos)
            let escolhido = Sessao.escolher(remoto: remoto, local: local,
                pessoal: AnaliseLocal.escritaPessoal(texto: texto, campos: campos))
            return ["escolhido": veredito(escolhido), "local": veredito(local),
                    "modelo": remoto.map { veredito($0) as Any } ?? NSNull()]
        case "escolherRegra":
            // ADR 2026-09-16g: `texto` é a consulta que a Decisão monta; `itens`
            // são os arquivos da biblioteca postos no Documents ao lado da
            // fixture. Sai a regra escolhida e por qual via — `palavras` numa
            // linha é o modelo que não respondeu, não acerto dele.
            let obras = try obrasDoDocuments(itens)
            // E7: com `campos` na fixture, a situação vai rotulada como na Sessao
            let situacao = e.campos.flatMap { Conselho.situacao(gesto: gesto, campos: $0) }
            let achado = await Conselho.escolherPeloSentido(consulta: texto, situacao: situacao, obras: obras, pesos: [:]) { s, u, esquema in
                await Sabia.chamar(.escolherRegra, sistema: s, usuario: u, temperatura: 0, esquema: esquema)
            }
            guard let achado else {
                return ["via": "modelo", "regra": NSNull(),
                        "candidatas": Obra.ranquear(pergunta: texto, textos: obras).prefix(Conselho.candidatas).map(\.secao.chave)]
            }
            let ranking = Obra.ranquear(pergunta: texto, textos: obras)
            return ["via": achado.via.rawValue, "regra": achado.regra.secao.chave,
                    // as que o modelo viu: a prova de que uma seção hostil estava entre elas (16j)
                    "candidatas": ranking.prefix(Conselho.candidatas).map(\.secao.chave),
                    "titulo": achado.regra.secao.titulo,
                    "posicaoNoBM25": (ranking.firstIndex { $0.secao.chave == achado.regra.secao.chave } ?? -2) + 1]
        case "dominio":
            let dominio = try exigir(await AnaliseDeBordo.dominio(texto: texto))
            return ["dominio": dominio.map { $0.rawValue as Any } ?? NSNull()]
        default:
            throw Falha.operacaoDesconhecida(caso.operacao)
        }
    }

    private static func veredito(_ valor: AnaliseLocal.Veredito) -> [String: String] {
        switch valor {
        case .silencio: ["tipo": "silencio"]
        case .expressiva: ["tipo": "expressiva"]
        case .aviso(let texto): ["tipo": "aviso", "texto": texto]
        case .gesto(let gesto, let pergunta): ["tipo": "gesto", "gesto": gesto.rawValue, "pergunta": pergunta]
        }
    }
}
#endif
