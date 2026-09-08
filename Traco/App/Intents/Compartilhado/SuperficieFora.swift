import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif
#if canImport(WidgetKit)
import WidgetKit
#endif

/// ADR 2026-09-05u — a superfície pública do Traço fora do app.
///
/// UM documento no App Group, escrito atomicamente só pelo app, lido pelos
/// widgets. Substitui as chaves soltas de `DestaqueDoDia` e
/// `ProximoCompromisso` no `UserDefaults`. É projeção descartável: o estado
/// que autoriza (feito, soneca, o compromisso em si) vive no app; aqui só
/// entra o texto que o selo deixa sair.
///
/// `validoAte` é o horizonte dos próximos: até quando a lista é a verdade
/// inteira. Depois disso o widget diz "desatualizado", nunca inventa o
/// compromisso seguinte.
nonisolated struct Superficie: Codable, Equatable, Sendable {
    static let versaoAtual = 1
    /// Quantos próximos o documento carrega. Mora aqui, e não no app: o
    /// widget precisa do número para saber se a lista dele está cortada, e o
    /// alvo do widget não compila `ProximoCompromisso`.
    static let candidatas = 3

    var versao = versaoAtual
    var revisao = 0
    var geradoEm: Date
    var validoAte: Date
    var destaque: Destaque?
    var proximos: [Proximo] = []
    /// Quantos compromissos do horizonte NÃO couberam em `proximos` (G4 da
    /// F4, achado A). Sem isto a face contava "+2 depois" sobre uma lista que
    /// ela mesma sabia cortada: um número fechado, e falso, num dia de cinco.
    ///
    /// Opcional de propósito: instantâneo gravado antes desta conta decodifica
    /// com `nil`, que quer dizer **não sei** — e a face que não sabe não
    /// publica número (`Restantes.algunsMais`).
    var alemDaLista: Int?

    nonisolated struct Destaque: Codable, Equatable, Sendable {
        /// O teto público da linha, em grafemas (`Character`), marcador
        /// incluído (ADR 08h). É o limite do PUBLICADOR: `VozDoAutor.titulo`
        /// entrega a primeira linha de uma nota sem teto, e um parágrafo de
        /// 247 caracteres chegava inteiro à face. Nenhum número garante que o
        /// texto caiba — a face ainda corta o que sobrar; este só reduz o que
        /// viaja e DECLARA a omissão.
        static let teto = 140

        var id: UUID
        /// `yyyy-MM-dd`: a marca de feito e a atividade valem só neste dia.
        var dia: String
        var linha: String
        var feito: Bool
        /// `true`: `linha` é o texto do autor inteiro. `false`: é um trecho
        /// cortado em `teto` e termina no marcador. `nil`: instantâneo
        /// anterior a esta conta — integralidade DESCONHECIDA, e a face não
        /// afirma nem uma coisa nem outra. A pontuação literal do autor não é
        /// metadado: uma frase que já termina em "…" não prova corte.
        var inteira: Bool? = nil

        nonisolated enum Integridade: Equatable, Sendable { case inteira, trecho, desconhecida }
        var integridade: Integridade {
            switch inteira {
            case .some(true): .inteira
            case .some(false): .trecho
            case .none: .desconhecida
            }
        }

        /// O que o VoiceOver diz. Ler a projeção não autoriza anunciar texto
        /// completo; um trecho é anunciado como trecho.
        var emVoz: String { Superficie.Destaque.emVoz(linha, inteira: inteira) }

        nonisolated static func emVoz(_ linha: String, inteira: Bool?) -> String {
            inteira == false ? "Trecho: \(linha) Continua no Traço." : linha
        }

        /// O corte honesto do publicador: um prefixo fiel de `texto`, em
        /// grafemas, com o marcador dentro do orçamento. Prefere terminar em
        /// fronteira de palavra; palavra maior que o orçamento (ou escrita sem
        /// espaços) corta por grafema — sempre sinalizado. Nunca resume,
        /// nunca escolhe outra oração, nunca toca no original guardado.
        nonisolated static func trecho(_ texto: String, teto: Int = teto) -> (linha: String, inteira: Bool) {
            guard texto.count > teto else { return (texto, true) }
            let orcamento = texto.prefix(max(1, teto - 1))
            var corte = Substring(orcamento)
            // ponytail: fronteira de palavra só se guarda metade do orçamento;
            // senão a palavra é maior que o espaço e o corte é por grafema
            if let espaco = orcamento.lastIndex(where: \.isWhitespace),
               orcamento.distance(from: orcamento.startIndex, to: espaco) >= orcamento.count / 2 {
                corte = orcamento[..<espaco]
            }
            let base = corte.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: ",;:")))
            return ((base.isEmpty ? String(orcamento) : base) + "…", false)
        }
    }


    nonisolated struct Proximo: Codable, Equatable, Sendable {
        var id: UUID
        var titulo: String
        var inicio: Date
        var fim: Date
        var diaInteiro: Bool
        /// Quando o aviso toca; `nil` = desligado ou recusado (ADR 04a/04b).
        var aviso: Date?
        /// A soneca pedida na tela bloqueada (ADR 04f), já confirmada.
        var lembrarEm: Date?
        /// Veio do calendário do iPhone: não está no disco do Traço.
        var doSistema: Bool

        /// A identidade que a tela bloqueada devolve ao app: série repetida
        /// tem o mesmo `id` em cada dia — a ocorrência é `id` + início.
        var ocorrencia: String { Superficie.ocorrencia(id, inicio) }

        init(id: UUID = UUID(), titulo: String, inicio: Date, fim: Date, diaInteiro: Bool,
             aviso: Date? = nil, lembrarEm: Date? = nil, doSistema: Bool = false) {
            self.id = id
            self.titulo = titulo
            self.inicio = inicio
            self.fim = fim
            self.diaInteiro = diaInteiro
            self.aviso = aviso
            self.lembrarEm = lembrarEm
            self.doSistema = doSistema
        }

        func comLembrete(_ quando: Date) -> Proximo {
            var p = self
            p.lembrarEm = quando
            return p
        }
    }

    nonisolated static func ocorrencia(_ id: UUID, _ inicio: Date) -> String {
        "\(id.uuidString)@\(Int(inicio.timeIntervalSince1970))"
    }

    var desatualizada: Bool { desatualizada(agora: .now) }
    /// `>=`: a entrada da linha do tempo cai EXATAMENTE em `validoAte`.
    func desatualizada(agora: Date) -> Bool { agora >= validoAte }

    /// O Destaque, se ainda é o de hoje.
    func destaqueDeHoje(agora: Date = .now) -> Destaque? {
        guard let destaque, destaque.dia == Self.diaISO(agora) else { return nil }
        return destaque
    }

    /// Quantos ficaram de fora da lista publicada. `nil` só quando o
    /// instantâneo é anterior a esta conta E a lista está cheia: lista curta
    /// é, por construção (`publicar`), a verdade inteira do horizonte.
    func alem() -> Int? {
        alemDaLista ?? (proximos.count < Self.candidatas ? 0 : nil)
    }

    /// O primeiro que ainda não acabou. O que terminou não é "o próximo".
    func proximo(agora: Date = .now) -> Proximo? {
        proximos.first { $0.fim > agora }
    }

    /// O que o widget do próximo mostra num instante. Um estado só, e o
    /// "desatualizado" vem ANTES do vazio: depois do horizonte a lista não é
    /// mais a verdade inteira.
    nonisolated enum EstadoDoProximo: Equatable, Sendable {
        case indisponivel, desatualizado, vazio
        case proximo(Proximo)
    }

    func estadoDoProximo(agora: Date = .now) -> EstadoDoProximo {
        if desatualizada(agora: agora) { return .desatualizado }
        guard var p = proximo(agora: agora) else { return .vazio }
        if let l = p.lembrarEm, l <= agora { p.lembrarEm = nil }
        return .proximo(p)
    }

    /// As datas da linha do tempo do widget: agora, o fim de cada próximo (o
    /// seguinte entra, ou "nada marcado"), a soneca que passa e o horizonte.
    /// Poucas, reais, nenhuma inventada — e nenhum reload por minuto.
    nonisolated static func transicoes(_ leitura: SuperficieDisco.Leitura, agora: Date) -> [Date] {
        var datas: Set<Date> = [agora]
        if case .disponivel(let s) = leitura {
            for p in s.proximos where p.fim > agora && p.fim <= s.validoAte {
                datas.insert(p.fim)
                if let l = p.lembrarEm, l > agora { datas.insert(l) }
            }
            if s.validoAte > agora { datas.insert(s.validoAte) }
        }
        return datas.sorted()
    }

    // MARK: - Texto compartilhado (widget e app dizem a mesma coisa)

    nonisolated static func diaISO(_ data: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: data)
    }

    nonisolated static func horaCurta(_ data: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "HH:mm"
        return f.string(from: data)
    }

    /// "hoje", "amanhã" ou o dia da semana — o autor pensa assim, não em datas.
    nonisolated static func diaEmPalavras(_ data: Date, agora: Date = .now) -> String {
        let cal = Calendar(identifier: .gregorian)
        if cal.isDate(data, inSameDayAs: agora) { return "hoje" }
        let amanha = cal.date(byAdding: .day, value: 1, to: agora) ?? agora
        if cal.isDate(data, inSameDayAs: amanha) { return "amanhã" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE, d 'de' MMM"
        return f.string(from: data)
    }

    /// "hoje às 21:45" / "amanhã" — o widget e a entidade dizem o mesmo.
    nonisolated static func quando(_ inicio: Date, diaInteiro: Bool, agora: Date = .now) -> String {
        let dia = diaEmPalavras(inicio, agora: agora)
        return diaInteiro ? dia : "\(dia) às \(horaCurta(inicio))"
    }

    /// A linha de uma face só (`accessoryInline`): hora e título, nada mais.
    nonisolated static func linhaDoProximo(_ p: Proximo?) -> String {
        guard let p else { return "Traço" }
        return p.diaInteiro ? p.titulo : "\(horaCurta(p.inicio)) · \(p.titulo)"
    }
}

/// O disco da superfície: onde o documento mora e como se publica.
///
/// Falha, corrupção ou App Group indisponível viram `.indisponivel` — nunca
/// `.standard`, nunca um widget que finge que está tudo bem.
nonisolated enum SuperficieDisco {
    static let grupo = "group.app.traco"
    static let kindDestaque = "TracoWidget"
    static let kindProximo = "TracoProximo"

    /// Trocável nos testes: pasta temporária, ou `nil` para simular App Group
    /// indisponível.
    nonisolated(unsafe) static var url: URL? = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: grupo)?
        .appendingPathComponent("superficie.json")

    /// Só os kinds cuja seção mudou recarregam; os testes contam.
    nonisolated(unsafe) static var recarregar: @Sendable (Set<String>) -> Void = { kinds in
        #if canImport(WidgetKit)
        for kind in kinds.sorted() { WidgetCenter.shared.reloadTimelines(ofKind: kind) }
        #endif
    }

    /// O ESTADO que autoriza a projeção (linha, dona, feito, soneca) — no
    /// App Group, trocável por uma suíte própria nos testes.
    nonisolated(unsafe) static var defaults: UserDefaults = UserDefaults(suiteName: grupo) ?? .standard

    /// Se o app pode pedir Live Activities; os testes dizem que não.
    nonisolated(unsafe) static var atividades: @Sendable () -> Bool = {
        #if canImport(ActivityKit)
        ActivityAuthorizationInfo().areActivitiesEnabled
        #else
        false
        #endif
    }

    /// `reloadTimelines` não devolve erro. No Air todo pedido era recusado
    /// (ChronoCoreErrorDomain 27) e a causa era o nome do produto (ver
    /// `project.yml`: "Traço" em NFD no disco × NFC no Info.plist). Corrigido
    /// lá; isto é a rede: o par guarda a revisão publicada e a última cuja
    /// recarga foi pedida de novo, e `recarregarPendente` (volta à cena)
    /// repete o pedido. No arranque nada está confirmado: o processo anterior
    /// pode ter morrido com o pedido recusado.
    nonisolated(unsafe) static var revisaoPublicada = 0
    nonisolated(unsafe) static var revisaoRecarregada = -1

    /// Repete o reload dos dois kinds se há publicação sem recarga confirmada
    /// (em primeiro plano o reload não conta no orçamento). Devolve se pediu.
    @discardableResult
    nonisolated static func recarregarPendente() -> Bool {
        guard revisaoRecarregada < revisaoPublicada else { return false }
        recarregar([kindDestaque, kindProximo])
        revisaoRecarregada = revisaoPublicada
        return true
    }

    /// A suíte roda DENTRO do app do simulador: sem isto cada teste escrevia
    /// na superfície real, queimava o orçamento do WidgetKit e deixava
    /// atividade órfã na tela bloqueada. Um ponto só, no arranque em teste.
    nonisolated static func isolarParaTestes() {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("superficie-testes")
        url = raiz.appendingPathComponent("superficie.json")
        recarregar = { _ in }
        defaults = UserDefaults(suiteName: "app.traco.testes") ?? .standard
        atividades = { false }
    }

    nonisolated enum Leitura: Equatable, Sendable {
        case disponivel(Superficie)
        case indisponivel
    }

    nonisolated static func ler() -> Leitura {
        guard let url, let dados = try? Data(contentsOf: url) else { return .indisponivel }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .secondsSince1970
        guard let s = try? dec.decode(Superficie.self, from: dados), s.versao == Superficie.versaoAtual else {
            return .indisponivel
        }
        return .disponivel(s)
    }

    /// Lê o atual, aplica a mudança e grava atomicamente. Devolve `false`
    /// quando o disco recusa: quem chamou NÃO confirma nada na tela.
    ///
    /// Idêntico não regrava (autosaves seguidos) — a não ser que o horizonte
    /// tenha mudado; e nada aqui atrasa: revogação é a mesma chamada.
    @discardableResult
    nonisolated static func publicar(agora: Date = .now, _ mudar: (inout Superficie) -> Void) -> Bool {
        guard let url else { return false }
        let antes: Superficie? = if case .disponivel(let s) = ler() { s } else { nil }
        var nova = antes ?? Superficie(geradoEm: agora, validoAte: agora)
        mudar(&nova)
        // `alemDaLista` entra na comparação: o sexto compromisso do dia não
        // muda os três publicados, muda quantos faltam — e sem isto a escrita
        // era descartada como "idêntica" e a face seguia contando errado.
        if let antes, antes.destaque == nova.destaque, antes.proximos == nova.proximos,
           antes.validoAte == nova.validoAte, antes.alemDaLista == nova.alemDaLista {
            return true
        }
        nova.versao = Superficie.versaoAtual
        nova.revisao = (antes?.revisao ?? 0) + 1
        nova.geradoEm = agora
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .secondsSince1970
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try enc.encode(nova).write(to: url, options: .atomic)
        } catch {
            return false
        }
        // Os dois kinds, sempre. O mapa "kind afetado" é da F2, quando cada
        // face lia METADE do documento; desde a F4 o widget do Traço mostra a
        // agenda e o do Próximo mostra o Destaque — as duas faces leem o
        // documento INTEIRO. Recarregar só quem "mudou" deixava a agenda de
        // ontem embaixo do Destaque de hoje, que é a mentira que esta volta
        // veio matar. Não custa orçamento extra: quem economiza é a guarda do
        // idêntico, logo acima, e ela continua onde estava.
        revisaoPublicada = nova.revisao
        recarregar([kindDestaque, kindProximo])
        return true
    }
}
