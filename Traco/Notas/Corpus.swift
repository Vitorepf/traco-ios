import Foundation

/// Uma nota pronta para sair — ou para ficar de fora. O selo decide.
nonisolated struct FatiaCorpus: Sendable, Equatable {
    var id: UUID
    var texto: String
    var gesto: Gesto?
    var campos: [String: String]
    var criadaEm: Date
    var editadaEm: Date
    var recordada: Int
    var sentido: String
    var minutos: Int
    var trancada: Bool
    var queimada: Bool
    var expressivaEmCurso: Bool
    var dominio: Dominio?
    var serie: UUID?
    var dia: Int

    var estado: String? {
        if queimada { return "queimada" }
        if trancada { return "selada" }
        return nil
    }

    /// Expressiva com timer (ou ainda aberta) não sai por rota nenhuma.
    var nuncaSai: Bool { expressivaEmCurso }

    /// Selada ou queimada: cabeçalho e sentido; o corpo da dor não viaja.
    var soMetadado: Bool { trancada || queimada }

    @MainActor static func de(_ nota: Nota) -> FatiaCorpus {
        FatiaCorpus(
            id: nota.uuid,
            texto: nota.texto,
            gesto: nota.gesto,
            campos: nota.campos,
            criadaEm: nota.criadaEm,
            editadaEm: nota.editadaEm,
            recordada: Revisoes.contagem(nota.uuid),
            sentido: nota.sentido,
            minutos: nota.minutosEscritos,
            trancada: nota.trancada,
            queimada: nota.queimada,
            expressivaEmCurso: nota.gesto == .expressiva && !nota.fechada,
            dominio: nota.dominio,
            serie: nota.serieUUID,
            dia: nota.diaDaSerie
        )
    }
}

/// Export do corpus (FILA P1.4 + COLHEITA item 1): as notas como Markdown
/// legível por autor e por IA. Sem servidor. Sem conta.
///
/// Sai: voz do autor, campos, sentido, id, datas, vezes recordada.
/// Nunca sai: expressiva em curso, corpo de selada/queimada, mobiliário, `traco://`.
enum Corpus {
    /// Testes apontam para um temp; o app usa Documents.
    static var diretorio: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!

    static var pastaNotas: URL { diretorio.appendingPathComponent("notas", isDirectory: true) }

    nonisolated static let contrato = """
    # Traço — corpus

    Este arquivo é uma exportação das notas do Traço, não o segundo cérebro
    completo. Traço combina mente, IA e ambiente compartilhado para realizar
    intenções e desenvolver capacidades pertinentes.

    Estar nesta exportação não certifica autoria humana. Notas podem conter
    texto colado ou importado; não atribua ao autor uma origem não demonstrada.
    Este snapshot não inclui o histórico dos Trabalhos e seus artefatos.

    Você pode: ler, citar literalmente, cruzar datas e gestos, cobrar uma
    intenção pelos campos `resultado`, `obstaculo`, `plano`, `se`, `entao`.
    Esta rota é contexto de notas, não escrita direta no documento do autor.
    Não complete silenciosamente uma nota nem devolva resumo como se fosse
    voz pessoal. Produção delegada é permitida em artefato separado com origem
    explícita; use o intercâmbio de Trabalho para versões, sem inventar campos.

    Cada nota aberta tem front matter e corpo. Expressivas seladas ou queimadas
    aparecem SÓ como cabeçalho (`estado`, `minutos`, `sentido`) — o texto da
    dor não está aqui e não deve ser pedido. Expressivas em curso não saem.

    Campos do cabeçalho: `id` (cite por ele), `criada`, `editada`, `gesto`,
    `metodo` (o id da forma, quando não é o nome), `dominio`, `recordada`
    (quantas vezes o autor lembrou de memória), `sentido` (a linha que ele
    escreveu no fecho), `estado`, `minutos`, `serie`, `dia`.

    Gestos e o que cada um guarda:
    - WOOP: resultado, obstaculo, plano
    - Se–então: se, entao
    - Especificação: problema, pronto, nao, restricoes, limites
    - Nota permanente: ideia, liga, fonte
    - Destaque: unica (a única coisa daquele dia)
    - Destilar: em200, em100, em50, frase
    - Palavra: minhas, frase, onde
    - Decisão: escolha, opcoes, criterio, decidido, espero, aconteceu
    - Pré-mortem: plano, falhou, sinal, mudo
    - Expressiva: sem corpo; só sentido e minutos

    Import ignore `id`. Trancadas e queimadas nunca voltam como nota aberta.
    """

    // MARK: - Formato

    nonisolated static func arquivoMd(_ f: FatiaCorpus) -> String {
        let iso = ISO8601DateFormatter()
        var cab: [String] = [
            "id: \(f.id.uuidString)",
            "criada: \(iso.string(from: f.criadaEm))",
            "editada: \(iso.string(from: f.editadaEm))",
        ]
        if let gesto = f.gesto {
            cab.append("gesto: \(gesto.nome)")
            // ADR 05o: o id vai junto quando não é o nome. É por ele que a nota
            // reencontra o método — o nome muda, e o método pode sair da pasta.
            if gesto.rawValue != gesto.nome { cab.append("metodo: \(gesto.rawValue)") }
        }
        if let dominio = f.dominio { cab.append("dominio: \(dominio.nome)") }
        cab.append("recordada: \(f.recordada)")
        if f.soMetadado {
            if let estado = f.estado { cab.append("estado: \(estado)") }
            if f.minutos > 0 { cab.append("minutos: \(f.minutos)") }
            let sentido = f.sentido.trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentido.isEmpty { cab.append("sentido: \(sentido)") }
            if let serie = f.serie {
                cab.append("serie: \(serie.uuidString)")
                cab.append("dia: \(f.dia)")
            }
            return "---\n\(cab.joined(separator: "\n"))\n---\n"
        }
        var corpo = f.texto.trimmingCharacters(in: .whitespacesAndNewlines)
        if let gesto = f.gesto, !f.campos.isEmpty {
            // ADR 05h: strings JSON conservam parágrafos, espaços e linhas
            // que parecem outro campo ou front matter. Chaves antigas também
            // sobrevivem quando o catálogo já não as conhece.
            let conhecidas = gesto.campos.map(\.id).filter { f.campos[$0] != nil }
            let outras = f.campos.keys.filter { !conhecidas.contains($0) }.sorted()
            let respostas = (conhecidas + outras).map { id in
                let valor = String(decoding: try! JSONEncoder().encode(f.campos[id]!), as: UTF8.self)
                return "\(id): \(valor)"
            }
            corpo += "\n\n— \(gesto.nome) —\n\(marcadorCampos)\n" + respostas.joined(separator: "\n")
        }
        let sentido = f.sentido.trimmingCharacters(in: .whitespacesAndNewlines)
        if !sentido.isEmpty, f.gesto != .expressiva {
            cab.append("sentido: \(sentido)")
        }
        return "---\n\(cab.joined(separator: "\n"))\n---\n\n\(corpo)\n"
    }

    /// Compatível com os testes antigos de 5-tupla (trancada = selada, sem corpo).
    static func arquivoMd(texto: String, gesto: Gesto?, campos: [String: String],
                          criadaEm: Date) -> String {
        arquivoMd(FatiaCorpus(
            id: UUID(), texto: texto, gesto: gesto, campos: campos,
            criadaEm: criadaEm, editadaEm: criadaEm, recordada: 0, sentido: "",
            minutos: 0, trancada: false, queimada: false, expressivaEmCurso: false,
            dominio: nil, serie: nil, dia: 0
        ))
    }

    nonisolated static func corpoDoCorpus(fatias: [FatiaCorpus]) -> String {
        let saidas = fatias
            .filter { !$0.nuncaSai }
            .sorted { $0.criadaEm < $1.criadaEm }
        let blocos = saidas.map(arquivoMd)
        let indice = indice(fatias: saidas)
        return contrato + "\n\n" + indice + "\n\n" + blocos.joined(separator: "\n")
    }

    static func corpoDoCorpus(notas: [(texto: String, gesto: Gesto?, campos: [String: String],
                                       trancada: Bool, criadaEm: Date)]) -> String {
        corpoDoCorpus(fatias: notas.map {
            FatiaCorpus(
                id: UUID(), texto: $0.texto, gesto: $0.gesto, campos: $0.campos,
                criadaEm: $0.criadaEm, editadaEm: $0.criadaEm, recordada: 0, sentido: "",
                minutos: 0, trancada: $0.trancada, queimada: false,
                expressivaEmCurso: $0.gesto == .expressiva && !$0.trancada,
                dominio: nil, serie: nil, dia: 0
            )
        })
    }

    nonisolated static func indice(fatias: [FatiaCorpus]) -> String {
        let abertas = fatias.filter { !$0.soMetadado }
        let fechadas = fatias.filter(\.soMetadado)
        let sentidos = fatias.filter { !$0.sentido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let primeira = fatias.map(\.criadaEm).min()
        let ultima = fatias.map(\.criadaEm).max()
        let iso = ISO8601DateFormatter()
        var porGesto: [String: Int] = [:]
        for f in abertas {
            let nome = f.gesto?.nome ?? "página"
            porGesto[nome, default: 0] += 1
        }
        let linhasGesto = porGesto.keys.sorted().map { "- \($0): \(porGesto[$0] ?? 0)" }
        return """
        ## Índice
        - notas abertas: \(abertas.count)
        - expressivas fechadas (só sentido): \(fechadas.count)
        - linhas de sentido: \(sentidos.count)
        - primeira: \(primeira.map { iso.string(from: $0) } ?? "—")
        - última: \(ultima.map { iso.string(from: $0) } ?? "—")
        \(linhasGesto.joined(separator: "\n"))
        """
    }

    // MARK: - Import

    nonisolated private static let marcadorCampos = "<!-- traco-campos:json-v1 -->"

    /// ADR 05h: novo bloco sem ambiguidade; id/rótulo achatado continua
    /// legível para arquivos antigos. Bloco novo inválido fica inteiro como
    /// texto, em vez de descartar respostas que não conseguimos reconstruir.
    static func separarCampos(texto: String, gesto: Gesto?) -> (texto: String, campos: [String: String]) {
        guard let gesto else { return (texto, [:]) }
        // ADR 05o: quem delimita o bloco é o MARCADOR, não o rótulo. O
        // "— Nome —" é o nome do método na hora da exportação; se ele mudou, ou
        // saiu da pasta, as respostas do autor não podem sair junto.
        if let marca = texto.range(of: marcadorCampos + "\n", options: .backwards),
           texto[..<marca.lowerBound].hasSuffix("—\n") {
            let rotulo = texto[..<marca.lowerBound].dropLast()
            let inicio = rotulo.lastIndex(of: "\n").map { rotulo.index(after: $0) } ?? texto.startIndex
            let bloco = texto[marca.upperBound...]
            var campos: [String: String] = [:]
            for linha in bloco.split(separator: "\n", omittingEmptySubsequences: false) {
                guard let doisPontos = linha.range(of: ": ") else { return (texto, [:]) }
                let id = String(linha[..<doisPontos.lowerBound])
                let json = Data(linha[doisPontos.upperBound...].utf8)
                guard !id.isEmpty, campos[id] == nil,
                      let valor = try? JSONDecoder().decode(String.self, from: json)
                else { return (texto, [:]) }
                campos[id] = valor
            }
            var corpo = String(texto[..<inicio])
            while corpo.hasSuffix("\n") { corpo.removeLast() }
            return (corpo, campos)
        }
        let cabecalhoLegado = "— \(gesto.nome) —\n"
        let alcanceLegado = texto.range(of: "\n\n" + cabecalhoLegado)
            ?? (texto.hasPrefix(cabecalhoLegado)
                ? texto.startIndex..<texto.index(texto.startIndex, offsetBy: cabecalhoLegado.count) : nil)
        guard let alcance = alcanceLegado else {
            return (texto, [:])
        }
        let corpo = String(texto[..<alcance.lowerBound])
        let bloco = String(texto[alcance.upperBound...])
        var campos: [String: String] = [:]
        for linha in bloco.split(separator: "\n") {
            for campo in gesto.campos {
                if linha.hasPrefix("\(campo.id): ") {
                    campos[campo.id] = String(linha.dropFirst(campo.id.count + 2))
                } else if linha.hasPrefix("\(campo.rotulo): ") {
                    campos[campo.id] = String(linha.dropFirst(campo.rotulo.count + 2))
                }
            }
        }
        return campos.isEmpty ? (texto, [:]) : (corpo, campos)
    }

    /// REGRA DO SELO: import JAMAIS cria nota trancada.
    nonisolated static func importar(_ conteudo: String) -> [(texto: String, gestoNome: String?, criadaEm: Date)] {
        importarComEstado(conteudo).itens
    }

    /// O coletor precisa saber se parte do arquivo foi recusada pelo selo:
    /// importar suas notas abertas não autoriza apagar a fonte inteira.
    nonisolated static func importarComEstado(_ conteudo: String) -> (
        itens: [(texto: String, gestoNome: String?, criadaEm: Date)], contemProtegida: Bool
    ) {
        let f = ISO8601DateFormatter()
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\n(?:id: \S+\n)?criada: (\S+)\n(?:editada: \S+\n)?(?:gesto: (.+)\n)?(?:metodo: (\S+)\n)?"#)
        let ns = conteudo as NSString
        let hits = padrao.matches(in: conteudo, range: NSRange(location: 0, length: ns.length))
        guard !hits.isEmpty else {
            let limpo = conteudo.trimmingCharacters(in: .whitespacesAndNewlines)
            if limpo.isEmpty || limpo.hasPrefix("# Traço") { return ([], false) }
            return ([(limpo, nil, .now)], false)
        }
        var saida: [(String, String?, Date)] = []
        var contemProtegida = false
        for (i, hit) in hits.enumerated() {
            let inicioBloco = hit.range.location
            let fimBloco = i + 1 < hits.count ? hits[i + 1].range.location : ns.length
            let bloco = ns.substring(with: NSRange(location: inicioBloco, length: fimBloco - inicioBloco))
            // Só o cabeçalho define proteção. Uma frase do corpo (inclusive
            // dentro de campo JSON) pode discutir "estado: selada" livremente.
            let inicioCabecalho = bloco.index(bloco.startIndex, offsetBy: 4)
            guard let fecha = bloco.range(of: "\n---\n", range: inicioCabecalho..<bloco.endIndex) else { continue }
            let cabecalho = bloco[inicioCabecalho..<fecha.lowerBound]
            if cabecalho.split(separator: "\n").contains(where: {
                let linha = $0.trimmingCharacters(in: .whitespaces)
                return linha == "estado: selada" || linha == "estado: queimada"
            }) {
                contemProtegida = true
                continue
            }
            let corpo = String(bloco[fecha.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !corpo.isEmpty else { continue }
            let data = f.date(from: ns.substring(with: hit.range(at: 1))) ?? .now
            let nomeDoGesto = hit.range(at: 2).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 2))
                .trimmingCharacters(in: .newlines)
            let idDoMetodo = hit.range(at: 3).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 3))
            // O `metodo:` é a chave estável e vence o nome, que é exibição
            // (ADR 05o). Nome que o catálogo não conhece, sem `metodo:`, NÃO
            // vira id: texto livre de um .md alheio não entra como forma.
            let gestoNome = idDoMetodo
                ?? nomeDoGesto.flatMap { Gesto.doNome($0)?.conhecido == true ? $0 : nil }
            saida.append((corpo, gestoNome, data))
        }
        return (saida, contemProtegida)
    }

    // MARK: - Disco

    static func backupAutomatico(notas: [Nota]) {
        escreverEspelho(fatias: notas.map(FatiaCorpus.de))
    }

    /// ADR 04o: concluir uma nota grava SÓ o `.md` dela e os três agregados,
    /// fora da main thread. A varredura completa (apagar o que não existe
    /// mais) fica para as rotas do selo — selar, queimar, apagar, importar e
    /// o arranque —, que continuam síncronas e inteiras.
    static func backupDeUma(_ nota: Nota, entre todas: [Nota]) {
        let fatia = FatiaCorpus.de(nota)
        let fatias = todas.map(FatiaCorpus.de)
        let raiz = diretorio
        let g = Geracao.proxima()
        Task.detached(priority: .utility) {
            escreverUma(fatia, agregados: fatias, em: raiz, geracao: g)
            PastaEspelho.comAcesso { escreverUma(fatia, agregados: fatias, em: $0, registrar: true, geracao: g) }
        }
    }

    /// ADR 05s: as escritas só andam para a frente. A tarefa fora da main que
    /// chega DEPOIS da varredura do selo (mais nova) não regrava o `.md` nem os
    /// agregados com a nota ainda aberta; e a varredura mais velha não apaga o
    /// `.md` que uma conclusão mais nova acabou de criar.
    // ponytail: uma trava global e um mapa alvo→geração; fila serial por
    // pasta se a espera na main doer um dia.
    nonisolated private static let ordem = NSLock()
    nonisolated(unsafe) private static var gravadas: [String: Int] = [:]

    nonisolated private static func avanca(_ alvo: URL, _ g: Int) -> Bool {
        if let atual = gravadas[alvo.path], atual > g { return false }
        gravadas[alvo.path] = g
        return true
    }

    nonisolated static func escreverUma(_ f: FatiaCorpus, agregados: [FatiaCorpus], em raiz: URL,
                                        registrar: Bool = false, geracao g: Int = 0) {
        ordem.lock(); defer { ordem.unlock() }
        let fm = FileManager.default
        let notasDir = raiz.appendingPathComponent("notas", isDirectory: true)
        try? fm.createDirectory(at: notasDir, withIntermediateDirectories: true)
        let vivas = agregados.filter { !$0.nuncaSai }
        let nome = f.id.uuidString.lowercased() + ".md"
        let alvo = notasDir.appendingPathComponent(nome)
        if avanca(alvo, g) {
            if f.nuncaSai {
                try? fm.removeItem(at: alvo)
            } else {
                escreverSeMudou(arquivoMd(f).data(using: .utf8), em: alvo)
                if registrar {
                    // o manifesto do espelho continua sabendo o que é deste aparelho
                    let manifesto = raiz.appendingPathComponent(".espelho-\(PastaEspelho.aparelho).json")
                    var meus: Set<String> = (try? Data(contentsOf: manifesto))
                        .flatMap { try? JSONDecoder().decode(Set<String>.self, from: $0) } ?? []
                    if meus.insert(nome).inserted {
                        try? JSONEncoder().encode(meus).write(to: manifesto, options: .atomic)
                    }
                }
            }
        }
        escreverAgregados(vivas, em: raiz, geracao: g)
    }

    nonisolated private static func escreverAgregados(_ vivas: [FatiaCorpus], em raiz: URL, geracao g: Int) {
        let corpus = raiz.appendingPathComponent("traco-corpus.md")
        guard avanca(corpus, g) else { return }
        escreverSeMudou(corpoDoCorpus(fatias: vivas).data(using: .utf8), em: corpus)
        escreverSeMudou(indice(fatias: vivas).data(using: .utf8),
                        em: raiz.appendingPathComponent("INDICE.md"))
    }

    static func exportar(notas: [Nota]) -> URL? {
        let corpo = corpoDoCorpus(fatias: notas.map(FatiaCorpus.de))
        guard !corpo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("traco-corpus-\(f.string(from: .now)).md")
        try? corpo.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }

    /// Uma nota, ou o conjunto de um filtro, pela folha do sistema.
    static func urlComoContexto(_ fatias: [FatiaCorpus], nome: String) -> URL? {
        let corpo = corpoDoCorpus(fatias: fatias)
        guard corpo.contains("---") else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(nome)
        try? corpo.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }

    static func escreverEspelho(fatias: [FatiaCorpus]) {
        let g = Geracao.proxima()
        escrever(fatias: fatias, em: diretorio, geracao: g)
        // a pasta do autor (iCloud Drive ou outro provedor), se ele escolheu uma
        PastaEspelho.comAcesso { pasta in escrever(fatias: fatias, em: pasta, soOsMeus: true, geracao: g) }
    }

    /// Escreve a pasta do segundo cérebro em `raiz`: LEIA-ME, notas/*.md,
    /// traco-corpus.md e INDICE.md. Só o que pode sair (`nuncaSai` fica).
    /// `soOsMeus`: na pasta do autor, só se apaga o que ESTE aparelho escreveu
    /// (manifesto ao lado); um .md dele, ou de outro aparelho, fica.
    /// Grava só o que MUDOU. O espelho reescrevia um .md por nota a cada
    /// conclusão — 1.000 notas = 1.000 escritas atômicas (medido: 0,19 ms cada
    /// no SSD, e muito pior na pasta do iCloud, que ainda sobe tudo de novo).
    /// Ler para comparar custa uma fração de escrever, e o conteúdo é
    /// determinístico: se é igual, escrever é desperdício puro.
    ///
    /// ponytail: isto NÃO troca a semântica — o selo continua reescrevendo a
    /// nota que virou metadado, porque aí o conteúdo mudou.
    @discardableResult
    nonisolated static func escreverSeMudou(_ dados: Data?, em alvo: URL) -> Bool {
        guard let dados else { return false }
        if let atual = try? Data(contentsOf: alvo), atual == dados { return false }
        try? dados.write(to: alvo, options: .atomic)
        return true
    }

    static func escrever(fatias: [FatiaCorpus], em raiz: URL, soOsMeus: Bool = false, geracao g: Int = 0) {
        ordem.lock(); defer { ordem.unlock() }
        let fm = FileManager.default
        let notasDir = raiz.appendingPathComponent("notas", isDirectory: true)
        try? fm.createDirectory(at: notasDir, withIntermediateDirectories: true)
        escreverSeMudou(contrato.data(using: .utf8), em: raiz.appendingPathComponent("LEIA-ME.md"))
        let vivas = fatias.filter { !$0.nuncaSai }
        var ids = Set<String>()
        for f in vivas {
            let nome = f.id.uuidString.lowercased() + ".md"
            ids.insert(nome)
            let alvo = notasDir.appendingPathComponent(nome)
            guard avanca(alvo, g) else { continue }
            escreverSeMudou(arquivoMd(f).data(using: .utf8), em: alvo)
        }
        let manifesto = raiz.appendingPathComponent(".espelho-\(PastaEspelho.aparelho).json")
        let meusAntes: Set<String> = soOsMeus
            ? ((try? Data(contentsOf: manifesto)).flatMap { try? JSONDecoder().decode(Set<String>.self, from: $0) } ?? [])
            : []
        if let existentes = try? fm.contentsOfDirectory(atPath: notasDir.path) {
            for nome in existentes where nome.hasSuffix(".md") && !ids.contains(nome) {
                if soOsMeus, !meusAntes.contains(nome) { continue }
                let alvo = notasDir.appendingPathComponent(nome)
                guard avanca(alvo, g) else { continue }
                try? fm.removeItem(at: alvo)
            }
        }
        if soOsMeus {
            try? JSONEncoder().encode(ids).write(to: manifesto, options: .atomic)
        }
        // A4: os compromissos vão junto. Sem isto, a pasta que o autor abre
        // noutro computador — e que o MCP lê — não tinha um único compromisso.
        if let calendario = try? Data(contentsOf: CalendarioDisco.urlPadrao()),
           raiz != diretorio {
            try? calendario.write(to: raiz.appendingPathComponent("calendario.json"), options: .atomic)
        }
        escreverAgregados(vivas, em: raiz, geracao: g)
    }
}
