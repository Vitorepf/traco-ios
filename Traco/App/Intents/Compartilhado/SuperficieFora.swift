import Foundation
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

    var versao = versaoAtual
    var revisao = 0
    var geradoEm: Date
    var validoAte: Date
    var destaque: Destaque?
    var proximos: [Proximo] = []

    nonisolated struct Destaque: Codable, Equatable, Sendable {
        var id: UUID
        /// `yyyy-MM-dd`: a marca de feito e a atividade valem só neste dia.
        var dia: String
        var linha: String
        var feito: Bool
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
        if let antes, antes.destaque == nova.destaque, antes.proximos == nova.proximos,
           antes.validoAte == nova.validoAte {
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
        var kinds = Set<String>()
        if antes?.destaque != nova.destaque { kinds.insert(kindDestaque) }
        if antes?.proximos != nova.proximos || antes?.validoAte != nova.validoAte { kinds.insert(kindProximo) }
        if antes == nil { kinds = [kindDestaque, kindProximo] }
        recarregar(kinds)
        return true
    }
}
