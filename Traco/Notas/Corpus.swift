import Foundation

/// Uma nota pronta para sair — ou para ficar de fora. O selo decide.
struct FatiaCorpus: Sendable, Equatable {
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

    static func de(_ nota: Nota) -> FatiaCorpus {
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

    static let contrato = """
    # Traço — corpus

    Este arquivo é o segundo cérebro do autor. Foi escrito por ele. Nenhuma
    palavra aqui veio de um modelo.

    Você pode: ler, citar literalmente, cruzar datas e gestos, cobrar uma
    intenção pelos campos `resultado`, `obstaculo`, `plano`, `se`, `entao`.
    Você não pode: escrever neste arquivo, completar uma nota, resumir para
    devolver ao autor como se fosse dele, inventar um campo.

    Cada nota aberta tem front matter e corpo. Expressivas seladas ou queimadas
    aparecem SÓ como cabeçalho (`estado`, `minutos`, `sentido`) — o texto da
    dor não está aqui e não deve ser pedido. Expressivas em curso não saem.

    Campos do cabeçalho: `id` (cite por ele), `criada`, `editada`, `gesto`,
    `dominio`, `recordada` (quantas vezes o autor lembrou de memória),
    `sentido` (a linha que ele escreveu no fecho), `estado`, `minutos`,
    `serie`, `dia`.

    Gestos e o que cada um guarda:
    - WOOP: resultado, obstaculo, plano
    - Se–então: se, entao
    - Especificação: problema, pronto, nao, restricoes, limites
    - Nota permanente: ideia, liga, fonte
    - Destaque: unica (a única coisa daquele dia)
    - Destilar: em200, em100, em50, frase
    - Palavra: minhas, frase, onde
    - Expressiva: sem corpo; só sentido e minutos

    Import ignore `id`. Trancadas e queimadas nunca voltam como nota aberta.
    """

    // MARK: - Formato

    static func arquivoMd(_ f: FatiaCorpus) -> String {
        let iso = ISO8601DateFormatter()
        var cab: [String] = [
            "id: \(f.id.uuidString)",
            "criada: \(iso.string(from: f.criadaEm))",
            "editada: \(iso.string(from: f.editadaEm))",
        ]
        if let gesto = f.gesto { cab.append("gesto: \(gesto.nome)") }
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
            let respostas = gesto.campos.compactMap { campo -> String? in
                guard let r = f.campos[campo.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !r.isEmpty else { return nil }
                return "\(campo.id): \(r)"
            }
            if !respostas.isEmpty {
                corpo += "\n\n— \(gesto.nome) —\n" + respostas.joined(separator: "\n")
            }
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

    static func corpoDoCorpus(fatias: [FatiaCorpus]) -> String {
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

    static func indice(fatias: [FatiaCorpus]) -> String {
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

    /// Reconstrói os campos achatados. Aceita `id: resposta` (novo) e
    /// `Rótulo: resposta` (export antigo). Labels nunca viram voz.
    static func separarCampos(texto: String, gesto: Gesto?) -> (texto: String, campos: [String: String]) {
        guard let gesto, let alcance = texto.range(of: "\n\n— \(gesto.nome) —\n") else {
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
        let f = ISO8601DateFormatter()
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\n(?:id: \S+\n)?criada: (\S+)\n(?:editada: \S+\n)?(?:gesto: (.+)\n)?"#)
        let ns = conteudo as NSString
        let hits = padrao.matches(in: conteudo, range: NSRange(location: 0, length: ns.length))
        guard !hits.isEmpty else {
            let limpo = conteudo.trimmingCharacters(in: .whitespacesAndNewlines)
            if limpo.isEmpty || limpo.hasPrefix("# Traço") { return [] }
            return [(limpo, nil, .now)]
        }
        var saida: [(String, String?, Date)] = []
        for (i, hit) in hits.enumerated() {
            let inicioBloco = hit.range.location
            let fimBloco = i + 1 < hits.count ? hits[i + 1].range.location : ns.length
            let bloco = ns.substring(with: NSRange(location: inicioBloco, length: fimBloco - inicioBloco))
            if bloco.contains("estado: selada") || bloco.contains("estado: queimada") {
                continue
            }
            guard let fecha = bloco.range(of: "---\n\n") ?? bloco.range(of: "---\n") else { continue }
            let corpo = String(bloco[fecha.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !corpo.isEmpty else { continue }
            let data = f.date(from: ns.substring(with: hit.range(at: 1))) ?? .now
            let gestoNome = hit.range(at: 2).location == NSNotFound ? nil : ns.substring(with: hit.range(at: 2))
                .trimmingCharacters(in: .newlines)
            saida.append((corpo, gestoNome, data))
        }
        return saida
    }

    // MARK: - Disco

    static func backupAutomatico(notas: [Nota]) {
        escreverEspelho(fatias: notas.map(FatiaCorpus.de))
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
        escrever(fatias: fatias, em: diretorio)
        // a pasta do autor (iCloud Drive ou outro provedor), se ele escolheu uma
        PastaEspelho.comAcesso { pasta in escrever(fatias: fatias, em: pasta) }
    }

    /// Escreve a pasta do segundo cérebro em `raiz`: LEIA-ME, notas/*.md,
    /// traco-corpus.md e INDICE.md. Só o que pode sair (`nuncaSai` fica).
    static func escrever(fatias: [FatiaCorpus], em raiz: URL) {
        let fm = FileManager.default
        let notasDir = raiz.appendingPathComponent("notas", isDirectory: true)
        try? fm.createDirectory(at: notasDir, withIntermediateDirectories: true)
        try? contrato.data(using: .utf8)?.write(
            to: raiz.appendingPathComponent("LEIA-ME.md"), options: .atomic)
        let vivas = fatias.filter { !$0.nuncaSai }
        var ids = Set<String>()
        for f in vivas {
            let nome = f.id.uuidString.lowercased() + ".md"
            ids.insert(nome)
            try? arquivoMd(f).data(using: .utf8)?.write(
                to: notasDir.appendingPathComponent(nome), options: .atomic)
        }
        if let existentes = try? fm.contentsOfDirectory(atPath: notasDir.path) {
            for nome in existentes where nome.hasSuffix(".md") && !ids.contains(nome) {
                try? fm.removeItem(at: notasDir.appendingPathComponent(nome))
            }
        }
        let corpus = corpoDoCorpus(fatias: vivas)
        try? corpus.data(using: .utf8)?.write(
            to: raiz.appendingPathComponent("traco-corpus.md"), options: .atomic)
        try? indice(fatias: vivas).data(using: .utf8)?.write(
            to: raiz.appendingPathComponent("INDICE.md"), options: .atomic)
    }
}
