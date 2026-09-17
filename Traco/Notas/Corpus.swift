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
    /// ADR 08u: quem escreveu. O que não é do autor sai com a marca.
    var origem: OrigemNota = .autor
    /// ADR 08u: quando o Recordar cobra esta nota — só para o `agenda.md`.
    var recordarEm: Date?

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
            dia: nota.diaDaSerie,
            origem: nota.origem,
            recordarEm: Revisoes.podeAgendar(gesto: nota.gesto, trancada: nota.fechada,
                                             texto: nota.texto, campos: nota.campos)
                ? Revisoes.proximaData(nota.uuid) : nil
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

    /// Os arquivos que o espelho grava SOLTOS na raiz, fora de `notas/`.
    /// A lista vivia escrita à mão em dois lugares — aqui, ao gravar, e na
    /// varredura do «Parar de espelhar» — e quem acrescentava um nome num
    /// deles esquecia o outro: foi assim que o `calendario.json` ficou na
    /// pasta do iCloud depois de o dono parar de espelhar (achado de contrato
    /// da ADR 17p). Agora quem grava e quem apaga leem daqui.
    nonisolated static let arquivoContrato = "LEIA-ME.md"
    nonisolated static let arquivoIndice = "INDICE.md"
    nonisolated static let arquivoCorpus = "traco-corpus.md"
    nonisolated static let arquivoAgenda = "agenda.md"
    nonisolated static let arquivoCalendario = "calendario.json"
    nonisolated static let arquivosSoltos = [arquivoContrato, arquivoIndice, arquivoCorpus,
                                             arquivoAgenda, arquivoCalendario]

    /// O contrato da pasta. ADR 09b: os MÉTODOS entram aqui, com os campos e a
    /// PERGUNTA de cada um — o caso 8 ("da ideia solta ao método") manda o bot
    /// buscar a pergunta no contrato, e ela não estava em lugar nenhum da
    /// pasta: o catálogo vive no bundle do app, que o Mac não abre. Gerado de
    /// `Catalogo.todos`, e não copiado à mão, para não haver duas listas
    /// divergindo — a lista fixa de dez formas que estava aqui já não era o
    /// catálogo de vinte e oito.
    nonisolated static var contrato: String { base + "\n\n" + metodosEmTexto() }

    nonisolated static func metodosEmTexto(_ metodos: [Metodo]? = nil) -> String {
        var linhas = ["""
        Métodos, campos e a PERGUNTA de cada um. `gesto` no cabeçalho é o nome;
        `metodo` é o id, quando difere. Os campos são o que a nota guarda. A
        pergunta é a que se faz a QUEM ESCREVE, uma por vez — quem pergunta não
        responde, e não preenche campo "para ela ver como fica".
        """]
        for m in (metodos ?? Catalogo.todos).sorted(by: { $0.nome < $1.nome }) {
            var bloco = "- \(m.nome)" + (m.id == m.nome ? "" : " (`\(m.id)`)")
            if !m.campos.isEmpty {
                bloco += "\n  campos: " + m.campos.map(\.id).joined(separator: " · ")
            }
            if !m.pergunta.isEmpty { bloco += "\n  pergunta: \(m.pergunta)" }
            linhas.append(bloco)
        }
        return linhas.joined(separator: "\n") + "\n"
    }

    nonisolated private static let base = """
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

    Import ignore `id`. Trancadas e queimadas nunca voltam como nota aberta.
    A expressiva não tem corpo aqui: só sentido e minutos.
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
        // ADR 08u: quem escreveu viaja com a nota. Ausente = o autor, que é o
        // que toda nota da pasta era antes desta ADR.
        if f.origem != .autor { cab.append("origem: \(f.origem.rawValue)") }
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

    /// ADR 2026-09-16f: o `traco-corpus.md` da pasta espelhada é o caderno que
    /// o Claude lê de uma vez — obra (texto de mestre, que pode mandar) não vai
    /// nele; quem a lê é o servidor `traco-obras`, como dado não confiável. O
    /// export e o backup continuam completos.
    nonisolated static func corpoDoEspelho(fatias: [FatiaCorpus]) -> String {
        corpoDoCorpus(fatias: fatias.filter { !$0.origem.eObra })
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

    /// O que um .md traz para dentro. A `origem` diz quem escreveu (ADR 08u):
    /// ausente no cabeçalho = o autor.
    /// `id`, `editadaEm` e `dominioNome` vêm do cabeçalho que o próprio Traço
    /// escreve: sem eles, importar a cópia devolvia notas com identidade nova
    /// (versões, juntas e Trabalhos perdiam o vínculo) e importar duas vezes
    /// duplicava o caderno (auditoria 17/09).
    typealias ItemImportado = (texto: String, gestoNome: String?, criadaEm: Date, origem: OrigemNota,
                               id: UUID?, editadaEm: Date?, dominioNome: String?)

    /// REGRA DO SELO: import JAMAIS cria nota trancada.
    nonisolated static func importar(_ conteudo: String) -> [ItemImportado] {
        importarComEstado(conteudo).itens
    }

    /// ADR 09y: **um arquivo só se apaga quando o app DELIMITOU tudo o que
    /// havia nele.** `consumido` é cobertura de DELIMITAÇÃO, **não de
    /// leitura**: a fração dos caracteres com tinta que caiu DENTRO de um bloco
    /// que foi `append`ado — não a fração que virou nota. A diferença é medida,
    /// não teórica (G3, `ferramentas/orca/revisao-p0-crlf.md`): numa nota
    /// exportada pelo próprio app com 699 caracteres de tinta, 659 viram texto
    /// de nota e `consumido` diz **1,00** — os 40 restantes são a tinta do
    /// CABEÇALHO, creditada sem virar nota nenhuma. E campo que este parser
    /// nunca lê (`dominio` e `recordada`, que o app ESCREVE; `gesto:` fora do
    /// catálogo) SOME na volta pela `entrada/` com a conta dizendo 100%, e o
    /// arquivo é apagado. `podeRetirar` é o único portão que o coletor lê, para
    /// que ninguém o remonte errado do lado de fora. Bloco recusado pelo selo,
    /// cabeçalho que não fecha, corpo vazio, prosa antes do primeiro cabeçalho:
    /// tudo isso deixa a cobertura abaixo de 1, e incerteza não apaga.
    nonisolated static func importarComEstado(_ conteudo: String) -> (
        itens: [ItemImportado], podeRetirar: Bool, consumido: Double
    ) {
        let f = ISO8601DateFormatter()
        let padrao = try! NSRegularExpression(
            pattern: #"(?m)^---\n(?:id: \S+\n)?criada: (\S+)\n(?:editada: \S+\n)?(?:gesto: (.+)\n)?(?:metodo: (\S+)\n)?"#)
        let ns = conteudo as NSString
        let hits = padrao.matches(in: conteudo, range: NSRange(location: 0, length: ns.length))
        // PORTÃO QUE NÃO ENXERGA FALHA FECHADO (ADR 09y). O regex acima só
        // conhece o fim de linha LF; `cabecalhos` conta A MESMA FORMA partindo
        // por `isNewline`, que enxerga CRLF e CR. Contagens diferentes = existe
        // cabeçalho do Traço que este parser NÃO leu — e um cabeçalho não lido
        // pode ser um selo. Então nada entra como do autor e nada se apaga, em
        // vez de o arquivo inteiro virar uma nota aberta do autor.
        // O QUE ESTE PORTÃO NÃO COBRE, e a ADR dizia que cobria: ele só dispara
        // quando as duas contagens DISCORDAM. Quando AS DUAS são cegas ao mesmo
        // cabeçalho malformado (`criada:` sem o espaço, selo escrito à mão sem
        // linha `criada:`), o arquivo cai no `hits.isEmpty` logo abaixo, que é
        // FAIL-OPEN: vira UMA nota aberta do autor com o corpo selado dentro, e
        // é apagado. Já era assim em `main`; dívida P0-SELO-CEGO, medida pelo
        // G3, com recomendação de uma linha em `revisao-p0-crlf.md` §3.
        guard cabecalhos(conteudo) == hits.count else { return ([], false, 0) }
        guard !hits.isEmpty else {
            let limpo = conteudo.trimmingCharacters(in: .whitespacesAndNewlines)
            if limpo.isEmpty || limpo.hasPrefix("# Traço") { return ([], false, 0) }
            return ([(limpo, nil, .now, pareceObra(limpo) ? .obraSuposta : .autor, nil, nil, nil)], true, 1)
        }
        let tinta = comTinta(conteudo)
        var saida: [ItemImportado] = []
        var lidos = 0
        for (i, hit) in hits.enumerated() {
            let inicioBloco = hit.range.location
            let fimBloco = i + 1 < hits.count ? hits[i + 1].range.location : ns.length
            let bloco = ns.substring(with: NSRange(location: inicioBloco, length: fimBloco - inicioBloco))
            // Só o cabeçalho define proteção. Uma frase do corpo (inclusive
            // dentro de campo JSON) pode discutir "estado: selada" livremente.
            let inicioCabecalho = bloco.index(bloco.startIndex, offsetBy: 4)
            guard let fecha = bloco.range(of: "\n---\n", range: inicioCabecalho..<bloco.endIndex) else { continue }
            let cabecalho = bloco[inicioCabecalho..<fecha.lowerBound]
            // ADR 08u: quem escreveu. O regex de cima só casa o prefixo fixo do
            // cabeçalho; a origem sai daqui, onde a ordem das linhas não importa.
            let origem = cabecalho.split(whereSeparator: \.isNewline).lazy
                .compactMap { linha -> OrigemNota? in
                    let l = linha.trimmingCharacters(in: .whitespaces)
                    guard l.hasPrefix("origem: ") else { return nil }
                    // origem que esta versão não conhece não é o autor: quem
                    // declarou origem declarou que não foi ele (ADR 2026-09-16a)
                    return OrigemNota(rawValue: String(l.dropFirst(8)).trimmingCharacters(in: .whitespaces)) ?? .obraSuposta
                }
                .first ?? .autor
            if cabecalho.split(whereSeparator: \.isNewline).contains(where: {
                let linha = $0.trimmingCharacters(in: .whitespaces)
                return linha == "estado: selada" || linha == "estado: queimada"
            }) {
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
            // lidos só do cabeçalho; não mudam a delimitação (ADR 09y)
            func valor(_ chave: String) -> String? {
                cabecalho.split(whereSeparator: \.isNewline).lazy
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .first { $0.hasPrefix(chave + ": ") }
                    .map { String($0.dropFirst(chave.count + 2)).trimmingCharacters(in: .whitespaces) }
            }
            saida.append((corpo, gestoNome, data, origem,
                          valor("id").flatMap(UUID.init(uuidString:)),
                          valor("editada").flatMap(f.date(from:)),
                          valor("dominio")))
            // A conta fecha-se sozinha SÓ PARA `continue`, e por construção:
            // esta linha é a ÚLTIMA do corpo do laço, então todo caminho que
            // pula o bloco deixa a conta curta sem bookkeeping por ramo.
            // NÃO fecha para descarte que CONSOME SEM DELIMITAR, e o G3 mediu
            // dois: truncar o que se guarda (o teto de 140 grafemas da ADR 08h,
            // sem um `continue` novo, importou 140 de 699 caracteres com
            // `consumido = 1,00` e APAGOU o arquivo) e ler um campo a menos
            // (`dominio`/`recordada`). Filtrar `saida` depois do laço é a mesma
            // família. Quem acrescentar um desses acrescenta o teste junto — a
            // cobertura não o pega.
            lidos += comTinta(bloco)
        }
        return (saida, lidos == tinta, tinta == 0 ? 1 : Double(lidos) / Double(tinta))
    }

    /// ADR 2026-09-16a: um `.md` sem cabeçalho do Traço é voz do autor só
    /// quando parece anotação. Seção numerada (`## 12.`), link sozinho numa
    /// linha (o formato do dossiê) ou mais de 20.000 caracteres é dossiê, livro
    /// ou transcrição: entra como obra. O link no meio da frase é do autor.
    /// ponytail: heurística de três sinais; o que escapa dela é texto curto sem
    /// seção nem link solto, e quem quiser outra coisa declara `origem:`.
    nonisolated static func pareceObra(_ texto: String) -> Bool {
        // o tamanho primeiro: num texto de 1,5 MB a regex custava 35 ms
        (texto.utf8.count > 20_000 && texto.count > 20_000)
            || texto.range(of: #"(?m)^#{1,3}[ \t]+\d+\."#, options: .regularExpression) != nil
            || texto.range(of: #"(?m)^[ \t]*https?://\S+[ \t]*$"#, options: .regularExpression) != nil
    }

    /// Bytes com tinta: tudo que não é espaço, tabulação nem quebra de linha. É
    /// a unidade da cobertura — reindentar um arquivo, ou trocar o fim de linha
    /// dele, não muda o que ele "havia". Contar por byte e não por
    /// `CharacterSet.whitespacesAndNewlines` é 40× mais rápido (medido em
    /// corpus de 562 KB: 0,6 ms contra 23,7 ms) e erra para o lado seguro —
    /// espaço exótico que sobre sem ser lido conta como tinta e segura o
    /// arquivo, que é a direção certa.
    nonisolated private static func comTinta(_ s: String) -> Int {
        var n = 0
        for b in s.utf8 where b != 0x20 && b != 0x0A && b != 0x0D && b != 0x09 { n += 1 }
        return n
    }

    /// Quantos cabeçalhos do Traço o arquivo tem, com QUALQUER fim de linha:
    /// uma linha `---`, o `id:` opcional, e a linha `criada:`. `isNewline`
    /// separa CRLF, CR e LF (em Swift `"\r\n"` é UM `Character`, e por isso
    /// quem parte por `"\n"` lê um arquivo do Windows como uma linha só).
    nonisolated private static func cabecalhos(_ s: String) -> Int {
        let linhas = s.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        var n = 0
        for (i, linha) in linhas.enumerated() where linha == "---" {
            var j = i + 1
            if j < linhas.count, linhas[j].hasPrefix("id: ") { j += 1 }
            if j < linhas.count, linhas[j].hasPrefix("criada: ") { n += 1 }
        }
        return n
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

    /// ADR 2026-09-08u: o dia da pessoa, ao lado do corpus. É o único arquivo
    /// da pasta que o companheiro do Mac precisa para o briefing da manhã: os
    /// compromissos que vêm, as decisões cuja hora de conferir já passou e as
    /// notas que o Recordar deve cobrar. Só leitura — o app escreve, ninguém
    /// edita. Nada aqui vem de expressiva, selada ou queimada: `vivas` já é o
    /// que pode sair, e `Volta`/`Revisoes` recusam a expressiva por dentro.
    ///
    /// ponytail: um `.md` com data no começo de cada linha, não JSON — o autor
    /// abre a pasta e lê, e o servidor MCP parte a linha pelo separador.
    nonisolated static func agenda(_ vivas: [FatiaCorpus], eventos: [EventoCalendario],
                                  agora: Date = .now, cal: Calendar = .current) -> String {
        let dia = DateFormatter(); dia.dateFormat = "yyyy-MM-dd"
        let hora = DateFormatter(); hora.dateFormat = "yyyy-MM-dd HH:mm"
        let hoje = cal.startOfDay(for: agora)

        var linhas = ["# Agenda do Traço", "",
                      "Escrita pelo Traço em \(hora.string(from: agora)). Só leitura: o app grava,",
                      "ninguém edita. O que está aqui é o que o autor marcou e o que o app deve",
                      "cobrar dele — nunca conclusão sobre ele. As ações dos Trabalhos ainda não",
                      "chegam a este arquivo.", ""]

        linhas.append("## Compromissos")
        let futuros = eventos.filter { $0.fim >= hoje }.sorted { $0.inicio < $1.inicio }
        for e in futuros {
            let quando = e.diaInteiro ? "\(dia.string(from: e.inicio)) · dia inteiro" : hora.string(from: e.inicio)
            linhas.append("- \(quando) · \(umaLinha(e.titulo))")
        }
        // seção vazia fica vazia: um item de mentira viraria compromisso no MCP

        linhas.append("")
        linhas.append("## Decisões a conferir")
        for f in vivas.filter({ $0.gesto == .decisao && !$0.soMetadado })
            where Volta.campoDevido(gesto: f.gesto, campos: f.campos, criadaEm: f.criadaEm, agora: agora) != nil {
            let oQue = ["escolha", "decidido"].compactMap { f.campos[$0] }.first ?? umaLinha(f.texto)
            linhas.append("- \(dia.string(from: f.criadaEm)) · \(f.id.uuidString.lowercased()) · \(umaLinha(oQue))"
                          + (f.campos["espero"].map { " · espero: \(umaLinha($0))" } ?? ""))
        }

        linhas.append("")
        linhas.append("## Recordar devido")
        for f in vivas.sorted(by: { $0.criadaEm < $1.criadaEm }) {
            guard let quando = f.recordarEm, quando <= agora, !f.soMetadado else { continue }
            linhas.append("- \(dia.string(from: quando)) · \(f.id.uuidString.lowercased()) · "
                          + "\(f.gesto?.nome ?? "página") · \(umaLinha(f.texto))")
        }
        return linhas.joined(separator: "\n") + "\n"
    }

    /// Uma linha só: o separador do arquivo é " · " e a quebra parte o item.
    nonisolated private static func umaLinha(_ s: String, teto: Int = 120) -> String {
        let plano = s.replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: " · ", with: " - ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return plano.count > teto ? String(plano.prefix(teto)) + "…" : plano
    }

    nonisolated private static func escreverAgregados(_ vivas: [FatiaCorpus], em raiz: URL, geracao g: Int) {
        let corpus = raiz.appendingPathComponent(arquivoCorpus)
        guard avanca(corpus, g) else { return }
        escreverSeMudou(corpoDoEspelho(fatias: vivas).data(using: .utf8), em: corpus)
        escreverSeMudou(indice(fatias: vivas).data(using: .utf8),
                        em: raiz.appendingPathComponent(arquivoIndice))
        // ADR 08u: o quarto arquivo solto. Os compromissos vêm do mesmo disco
        // que o `calendario.json` copia — nada de novo a carregar.
        // ponytail: relê o calendario.json a cada gravação de agregado; é um
        // arquivo pequeno e `escreverSeMudou` corta a escrita. Se doer, guarde
        // os eventos junto com a geração.
        let eventos: [EventoCalendario]
        if case .eventos(let e) = CalendarioDisco.carregar() { eventos = e } else { eventos = [] }
        escreverSeMudou(agenda(vivas, eventos: eventos).data(using: .utf8),
                        em: raiz.appendingPathComponent(arquivoAgenda))
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
        do {
            try dados.write(to: alvo, options: .atomic)
            PastaEspelho.defaults.removeObject(forKey: chaveFalhaDaCopia)
            return true
        } catch {
            // disco cheio, pasta sem permissão: a cópia parou de andar, e o
            // Perfil diz desde quando (a escrita do autor no caderno está intacta)
            if PastaEspelho.defaults.object(forKey: chaveFalhaDaCopia) == nil {
                PastaEspelho.defaults.set(Date(), forKey: chaveFalhaDaCopia)
            }
            return false
        }
    }

    nonisolated static let chaveFalhaDaCopia = "espelho-falhou-em"

    /// Desde quando a cópia em .md não consegue gravar. `nil` = gravando.
    static var copiaFalhouEm: Date? {
        PastaEspelho.defaults.object(forKey: chaveFalhaDaCopia) as? Date
    }

    static func escrever(fatias: [FatiaCorpus], em raiz: URL, soOsMeus: Bool = false, geracao g: Int = 0) {
        ordem.lock(); defer { ordem.unlock() }
        let fm = FileManager.default
        let notasDir = raiz.appendingPathComponent("notas", isDirectory: true)
        try? fm.createDirectory(at: notasDir, withIntermediateDirectories: true)
        escreverSeMudou(contrato.data(using: .utf8), em: raiz.appendingPathComponent(arquivoContrato))
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
            try? calendario.write(to: raiz.appendingPathComponent(arquivoCalendario), options: .atomic)
        }
        escreverAgregados(vivas, em: raiz, geracao: g)
    }
}
