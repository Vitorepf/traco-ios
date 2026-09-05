import Foundation

/// O sinal (ADR 2026-09-04h): o que o autor fez com o que o app e a IA lhe
/// deram. Diário no disco, algoritmo puro, e é dele — sair da conta não apaga
/// (o sinal é do aparelho, não da rede); "esquecer tudo" apaga.
///
/// É a entrada da segunda volta do ciclo: sem isto a IA não tinha como
/// melhorar com ESTE autor, e o Soltar, único gesto de recusa, morria no ar.
nonisolated struct Sinal: Codable, Sendable, Equatable, Identifiable {
    enum Tipo: String, Codable, Sendable {
        /// desfez uma forma vestida
        case solto
        /// concluiu uma nota com pelo menos um campo respondido
        case ficou
        /// "serviu" / "não serviu" numa pergunta (instigar, forma, prova)
        case pergunta
        /// "serviu" / "não serviu" na resposta da sábia ou no contrapor
        case resposta
        /// a conferência do Recordar: quantos pontos não voltaram
        case naoVoltou
    }

    var id: UUID = UUID()
    var quando: Date = .now
    var tipo: Tipo
    /// A forma envolvida, quando há uma.
    var forma: String?
    /// Verdadeiro = serviu. Só faz sentido em `pergunta` e `resposta`.
    var serviu: Bool?
    /// A pergunta ou o pedaço que a IA deu, literal — para a sábia não repetir
    /// a classe do que não serviu. Nunca texto do autor.
    var texto: String?
    /// `naoVoltou`: quantos pontos faltaram, e de quantos.
    var faltaram: Int?
    var deQuantos: Int?
}

nonisolated enum Sinais {
    static let teto = 500
    private static let tranca = NSLock()

    /// Testes apontam para um temp.
    nonisolated(unsafe) static var url: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Traço/sinais.json")

    static func todos() -> [Sinal] {
        tranca.lock(); defer { tranca.unlock() }
        return ler()
    }

    private static func ler() -> [Sinal] {
        guard let dados = try? Data(contentsOf: url) else { return [] }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return (try? dec.decode([Sinal].self, from: dados)) ?? []
    }

    @discardableResult
    static func registrar(_ sinal: Sinal) -> Bool {
        tranca.lock(); defer { tranca.unlock() }
        var lista = ler()
        lista.append(sinal)
        if lista.count > teto { lista.removeFirst(lista.count - teto) }
        return gravar(lista)
    }

    static func esquecerTudo() {
        tranca.lock(); defer { tranca.unlock() }
        try? FileManager.default.removeItem(at: url)
    }

    private static func gravar(_ lista: [Sinal]) -> Bool {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        guard let dados = try? enc.encode(lista) else { return false }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        return (try? dados.write(to: url, options: .atomic)) != nil
    }

    // MARK: atalhos

    static func solto(_ forma: Gesto) { registrar(Sinal(tipo: .solto, forma: forma.rawValue)) }
    static func ficou(_ forma: Gesto) { registrar(Sinal(tipo: .ficou, forma: forma.rawValue)) }
    static func pergunta(_ texto: String, forma: Gesto?, serviu: Bool) {
        registrar(Sinal(tipo: .pergunta, forma: forma?.rawValue, serviu: serviu, texto: String(texto.prefix(240))))
    }
    static func resposta(_ texto: String, forma: Gesto?, serviu: Bool) {
        registrar(Sinal(tipo: .resposta, forma: forma?.rawValue, serviu: serviu, texto: String(texto.prefix(120))))
    }
    static func naoVoltou(_ forma: Gesto?, faltaram: Int, de: Int) {
        registrar(Sinal(tipo: .naoVoltou, forma: forma?.rawValue, faltaram: faltaram, deQuantos: de))
    }

    /// ADR 04j: os três últimos sinais desta forma foram "solto"? Então ela
    /// passa a ser sugerida em vez de vestida — até o autor abrir uma por
    /// vontade própria (`ficou` zera).
    nonisolated static func sugerirEmVezDeVestir(_ forma: Gesto, sinais: [Sinal]) -> Bool {
        let ultimos = sinais
            .filter { $0.forma == forma.rawValue && ($0.tipo == .solto || $0.tipo == .ficou) }
            .suffix(3)
        return ultimos.count == 3 && ultimos.allSatisfy { $0.tipo == .solto }
    }

    static func sugerirEmVezDeVestir(_ forma: Gesto) -> Bool {
        sugerirEmVezDeVestir(forma, sinais: todos())
    }

    /// Em uma linha, para o Perfil.
    static func emPalavras() -> String {
        let lista = todos()
        guard let primeiro = lista.first else { return "nenhum sinal ainda — eles nascem quando você solta uma forma, conclui uma, ou diz se uma pergunta serviu." }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "d 'de' MMMM"
        let n = lista.count
        return "\(n) \(n == 1 ? "sinal" : "sinais") desde \(f.string(from: primeiro.quando))."
    }
}
