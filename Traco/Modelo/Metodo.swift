import Foundation

/// Um método do catálogo (ADR 2026-09-04l): o que antes era um `case` da enum
/// `Gesto` com seis `switch` espalhados. Agora é dado — `Metodos.json` no
/// bundle, mais o que o autor puser em `Documents/Traço/metodos/*.json`.
///
/// Adicionar um método deixou de exigir código: um arquivo com id, nome,
/// campos e o movimento que a sábia cobra. O app lê no arranque e ao voltar
/// à cena; entrada inválida é ignorada e dita no Perfil.
nonisolated struct Metodo: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var nome: String
    /// De quem é o método (Oettingen, Klein, Adler…). Nunca aparece na nota;
    /// aparece no Perfil, para o autor saber o que está usando.
    var origem: String = ""
    /// A faculdade da mente que ele treina (desejo, raciocínio, criação…).
    var faculdade: String = ""
    /// O que o app RECONHECEU no texto — a razão da classificação.
    var reconhecimento: String = ""
    /// A definição para o ROTEADOR (remoto e de bordo): o que o texto é, com
    /// os sinais de superfície ("quero…", "sempre que…"). Vazio = o
    /// reconhecimento serve.
    var definicao: String = ""
    /// O MOVIMENTO do método (ADR 03n): o passo que a pessoa pula sozinha.
    var movimento: String = ""
    /// A pergunta do template: o próximo campo vazio (§19.1).
    var pergunta: String = ""
    /// Regex sobre a voz do autor, em minúsculas. Vazio = só a IA roteia.
    var roteamento: [String] = []
    var campos: [CampoForma] = []
    /// O ritual do Recordar para este método. Nil = a nota inteira.
    var recordar: RecordarSpec?
    /// Para onde esta forma leva (ADR 04k).
    var encadeamentos: [Encadeamento] = []
    /// O chip na busca. Nil = sem chip.
    var filtro: String?
    /// Marcado em tempo de execução: veio da pasta do autor, não do bundle.
    var doAutor: Bool = false

    nonisolated struct RecordarSpec: Codable, Sendable, Equatable {
        /// Os campos que somem e que o autor tem de puxar da memória.
        var alvo: [String]
        /// Os campos que ficam à vista como pista.
        var pista: [String] = []
        var pergunta: String = "O que estava escrito?"
        var instrucao: String = "Leia uma última vez — a nota vai se esconder."
        var rotuloAlvo: String = "A NOTA"
        /// Falso = a pista já é ditado: a tela abre direto em escrever.
        var mostraAntes: Bool = true

        enum CodingKeys: String, CodingKey { case alvo, pista, pergunta, instrucao, rotuloAlvo, mostraAntes }

        init(alvo: [String], pista: [String] = [], pergunta: String = "O que estava escrito?",
             instrucao: String = "Leia uma última vez — a nota vai se esconder.",
             rotuloAlvo: String = "A NOTA", mostraAntes: Bool = true) {
            self.alvo = alvo; self.pista = pista; self.pergunta = pergunta
            self.instrucao = instrucao; self.rotuloAlvo = rotuloAlvo; self.mostraAntes = mostraAntes
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            alvo = try c.decode([String].self, forKey: .alvo)
            pista = try c.decodeIfPresent([String].self, forKey: .pista) ?? []
            pergunta = try c.decodeIfPresent(String.self, forKey: .pergunta) ?? "O que estava escrito?"
            instrucao = try c.decodeIfPresent(String.self, forKey: .instrucao) ?? "Leia uma última vez — a nota vai se esconder."
            rotuloAlvo = try c.decodeIfPresent(String.self, forKey: .rotuloAlvo) ?? "A NOTA"
            mostraAntes = try c.decodeIfPresent(Bool.self, forKey: .mostraAntes) ?? true
        }
    }

    nonisolated struct Encadeamento: Codable, Sendable, Equatable, Identifiable {
        var rotulo: String
        /// O id da forma de destino. Nil quando o destino é um compromisso.
        var para: String?
        /// campo do destino → campo da origem. As palavras são do autor.
        var mapa: [String: String] = [:]
        /// Compromisso no calendário, em `dias` a partir de hoje, com o texto
        /// do campo `campo` no título.
        var compromisso: Compromisso?
        /// O que precisa ter resposta para o botão acender.
        var exige: [String] = []
        var id: String { rotulo }

        enum CodingKeys: String, CodingKey { case rotulo, para, mapa, compromisso, exige }

        init(rotulo: String, para: String? = nil, mapa: [String: String] = [:],
             compromisso: Compromisso? = nil, exige: [String] = []) {
            self.rotulo = rotulo; self.para = para; self.mapa = mapa
            self.compromisso = compromisso; self.exige = exige
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            rotulo = try c.decode(String.self, forKey: .rotulo)
            para = try c.decodeIfPresent(String.self, forKey: .para)
            mapa = try c.decodeIfPresent([String: String].self, forKey: .mapa) ?? [:]
            compromisso = try c.decodeIfPresent(Compromisso.self, forKey: .compromisso)
            exige = try c.decodeIfPresent([String].self, forKey: .exige) ?? []
        }

        nonisolated struct Compromisso: Codable, Sendable, Equatable {
            var titulo: String
            var campo: String
            var dias: Int
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, nome, origem, faculdade, reconhecimento, definicao, movimento, pergunta, roteamento, campos, recordar, encadeamentos, filtro
    }

    init(id: String, nome: String, origem: String = "", faculdade: String = "", reconhecimento: String = "",
         movimento: String = "", pergunta: String = "", roteamento: [String] = [], campos: [CampoForma] = [],
         recordar: RecordarSpec? = nil, encadeamentos: [Encadeamento] = [], filtro: String? = nil) {
        self.id = id; self.nome = nome; self.origem = origem; self.faculdade = faculdade
        self.reconhecimento = reconhecimento; self.movimento = movimento; self.pergunta = pergunta
        self.roteamento = roteamento; self.campos = campos; self.recordar = recordar
        self.encadeamentos = encadeamentos; self.filtro = filtro
    }

    /// Toda chave além de `id`, `nome` e `campos` é opcional no arquivo: um
    /// método do autor não precisa saber o formato inteiro para entrar.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        nome = try c.decode(String.self, forKey: .nome)
        origem = try c.decodeIfPresent(String.self, forKey: .origem) ?? ""
        faculdade = try c.decodeIfPresent(String.self, forKey: .faculdade) ?? ""
        reconhecimento = try c.decodeIfPresent(String.self, forKey: .reconhecimento) ?? ""
        definicao = try c.decodeIfPresent(String.self, forKey: .definicao) ?? ""
        movimento = try c.decodeIfPresent(String.self, forKey: .movimento) ?? ""
        pergunta = try c.decodeIfPresent(String.self, forKey: .pergunta) ?? ""
        roteamento = try c.decodeIfPresent([String].self, forKey: .roteamento) ?? []
        campos = try c.decodeIfPresent([CampoForma].self, forKey: .campos) ?? []
        recordar = try c.decodeIfPresent(RecordarSpec.self, forKey: .recordar)
        encadeamentos = try c.decodeIfPresent([Encadeamento].self, forKey: .encadeamentos) ?? []
        filtro = try c.decodeIfPresent(String.self, forKey: .filtro)
    }

    /// Um método que o catálogo não conhece mais (arquivo apagado, id
    /// antigo): a nota não perde o gesto, e os campos gravados aparecem com o
    /// id no lugar do rótulo. Honestidade, não erro.
    static func desconhecido(_ id: String) -> Metodo {
        Metodo(id: id, nome: id, reconhecimento: "", movimento: "", pergunta: "")
    }

    /// O que o roteador lê: a definição, ou o reconhecimento na falta dela.
    var paraRoteador: String { definicao.isEmpty ? (reconhecimento.isEmpty ? nome : reconhecimento) : definicao }

    var valido: Bool {
        !id.trimmingCharacters(in: .whitespaces).isEmpty
            && !nome.trimmingCharacters(in: .whitespaces).isEmpty
            && Set(campos.map(\.id)).count == campos.count
    }
}

nonisolated struct CampoForma: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let rotulo: String
    var teto: Int? = nil
    /// Campo que só faz sentido na VOLTA (a conferência da decisão, o que
    /// roubou o dia). Some enquanto está vazio e a hora não chegou.
    var soDepois: Bool = false

    init(id: String, rotulo: String, teto: Int? = nil, soDepois: Bool = false) {
        self.id = id
        self.rotulo = rotulo
        self.teto = teto
        self.soDepois = soDepois
    }

    enum CodingKeys: String, CodingKey { case id, rotulo, teto, soDepois }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        rotulo = try c.decode(String.self, forKey: .rotulo)
        teto = try c.decodeIfPresent(Int.self, forKey: .teto)
        soDepois = try c.decodeIfPresent(Bool.self, forKey: .soDepois) ?? false
    }
}

/// O catálogo em memória. Lido do bundle e da pasta do autor; nunca escreve.
nonisolated enum Catalogo {
    private static let tranca = NSLock()
    private nonisolated(unsafe) static var lista: [Metodo] = []
    private nonisolated(unsafe) static var porId: [String: Metodo] = [:]
    private nonisolated(unsafe) static var carregado = false
    /// Arquivos do autor que não entraram, com o motivo — o Perfil diz.
    private nonisolated(unsafe) static var recusados: [String] = []

    /// A pasta do autor. Testes apontam para um temp.
    nonisolated(unsafe) static var pastaDoAutor: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Traço/metodos", isDirectory: true)

    static var todos: [Metodo] {
        garantir()
        tranca.lock(); defer { tranca.unlock() }
        return lista
    }

    static var doAutor: [Metodo] { todos.filter(\.doAutor) }
    static var doApp: [Metodo] { todos.filter { !$0.doAutor } }

    static var problemas: [String] {
        garantir()
        tranca.lock(); defer { tranca.unlock() }
        return recusados
    }

    static func metodo(_ id: String) -> Metodo? {
        garantir()
        tranca.lock(); defer { tranca.unlock() }
        return porId[id]
    }

    private static func garantir() {
        tranca.lock()
        let pronto = carregado
        tranca.unlock()
        if !pronto { recarregar() }
    }

    /// Lê o bundle e a pasta do autor. O bundle é a base; um arquivo do autor
    /// com o id de um método do app é ignorado — o selo e os dez de origem
    /// não são configuráveis.
    static func recarregar() {
        var novos = doBundle()
        var ids = Set(novos.map(\.id))
        var motivos: [String] = []
        let fm = FileManager.default
        if let nomes = try? fm.contentsOfDirectory(atPath: pastaDoAutor.path) {
            for nome in nomes.sorted() where nome.hasSuffix(".json") {
                let url = pastaDoAutor.appendingPathComponent(nome)
                guard let dados = try? Data(contentsOf: url) else { continue }
                do {
                    var m = try JSONDecoder().decode(Metodo.self, from: dados)
                    m.doAutor = true
                    guard m.valido else { motivos.append("\(nome): falta id, nome ou os campos repetem"); continue }
                    guard !ids.contains(m.id) else { motivos.append("\(nome): o id “\(m.id)” já existe"); continue }
                    guard m.id != Gesto.expressiva.rawValue else { motivos.append("\(nome): a expressiva não é configurável"); continue }
                    ids.insert(m.id)
                    novos.append(m)
                } catch {
                    motivos.append("\(nome): JSON inválido")
                }
            }
        }
        tranca.lock()
        lista = novos
        porId = Dictionary(uniqueKeysWithValues: novos.map { ($0.id, $0) })
        recusados = motivos
        carregado = true
        tranca.unlock()
    }

    private static func doBundle() -> [Metodo] {
        guard let url = Bundle.main.url(forResource: "Metodos", withExtension: "json")
                ?? Bundle(for: Marcador.self).url(forResource: "Metodos", withExtension: "json"),
              let dados = try? Data(contentsOf: url),
              let lidos = try? JSONDecoder().decode([Metodo].self, from: dados)
        else { return [] }
        return lidos.filter(\.valido)
    }

    private final class Marcador {}
}
