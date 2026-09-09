import Foundation

/// A revisão da semana (ADR q): o que a mente deixou no papel nos últimos
/// sete dias e o que ela marcou para os próximos. Algoritmo puro, sem rede:
/// conta, agrupa e cobra — nunca comenta nem elogia.
nonisolated struct RevisaoSemanal: Equatable, Sendable {
    nonisolated struct Linha: Equatable, Sendable, Identifiable {
        var id: UUID
        var texto: String
        var quando: Date?
    }

    /// Notas abertas escritas nos últimos sete dias, por forma.
    var porForma: [(forma: Gesto?, quantas: Int)]
    /// Decisões com data de conferir ainda por vir.
    var decisoesAConferir: [Linha]
    /// Desejos (WOOP) com obstáculo nomeado: o que está em jogo.
    var desejos: [Linha]
    /// Deixas e compromissos dos próximos sete dias.
    var proximos: [Linha]
    /// Destaques dos últimos sete dias, na ordem em que foram escolhidos.
    var destaques: [Linha]
    /// Expressivas fechadas na semana: só a contagem e as linhas de sentido.
    var sentidos: [String]
    /// Planos sem a própria falha nomeada: especificação sem "o que pode dar
    /// errado", desejo sem obstáculo. É onde o pré-mortem entra.
    var semRisco: [Linha] = []
    /// Decisões já conferidas: o que o autor esperava, e o que aconteceu.
    /// Lado a lado, sem nota nem placar — a memória reescreve a expectativa
    /// depois de saber o fim (hindsight), e só o papel guarda a versão de antes.
    var calibragem: [Calibragem] = []

    nonisolated struct Calibragem: Equatable, Sendable, Identifiable {
        var id: UUID
        var escolha: String
        var esperava: String
        var aconteceu: String
    }

    var vazia: Bool {
        porForma.isEmpty && decisoesAConferir.isEmpty && desejos.isEmpty
            && proximos.isEmpty && destaques.isEmpty && sentidos.isEmpty && semRisco.isEmpty
            && calibragem.isEmpty
    }

    static func == (a: RevisaoSemanal, b: RevisaoSemanal) -> Bool {
        a.porForma.map { "\($0.forma?.rawValue ?? "-"):\($0.quantas)" } == b.porForma.map { "\($0.forma?.rawValue ?? "-"):\($0.quantas)" }
            && a.decisoesAConferir == b.decisoesAConferir && a.desejos == b.desejos
            && a.proximos == b.proximos && a.destaques == b.destaques && a.sentidos == b.sentidos
            && a.semRisco == b.semRisco && a.calibragem == b.calibragem
    }

    /// Uma nota, sem SwiftData: o que a revisão precisa saber dela.
    nonisolated struct NotaLida: Sendable {
        var uuid: UUID
        var gesto: Gesto?
        var fechada: Bool
        var criadaEm: Date
        var gatilhoEm: Date?
        var titulo: String
        var campos: [String: String]
        var sentido: String
        var queimadaOuSeladaEm: Date?
        /// ADR 09b: a revisão é do que a MENTE do autor deixou no papel. O que
        /// o bot escreveu não é semana dele — nem como contagem. Sem padrão:
        /// o chamador declara ou não compila.
        var vozDoAutor: Bool
    }

    nonisolated static func ler(notas: [NotaLida], eventos: [EventoCalendario], agora: Date = .now,
                                cal: Calendar = .current) -> RevisaoSemanal {
        let seteAtras = cal.date(byAdding: .day, value: -7, to: agora) ?? agora
        let seteAFrente = cal.date(byAdding: .day, value: 7, to: agora) ?? agora
        // ADR 09b: um corte só, no topo — cada bloco abaixo parte de `notas`, e
        // um filtro por bloco seria seis lugares para esquecer o sétimo.
        let notas = notas.filter(\.vozDoAutor)

        // a expressiva em curso não é nota da semana: nem conta, nem sai (selo)
        let daSemana = notas.filter { !$0.fechada && $0.gesto != .expressiva && $0.criadaEm >= seteAtras && $0.criadaEm <= agora }
        var contagem: [String: (Gesto?, Int)] = [:]
        for n in daSemana {
            let chave = n.gesto?.rawValue ?? "-"
            contagem[chave] = (n.gesto, (contagem[chave]?.1 ?? 0) + 1)
        }
        let porForma = contagem.values
            .sorted { $0.1 == $1.1 ? ($0.0?.rawValue ?? "~") < ($1.0?.rawValue ?? "~") : $0.1 > $1.1 }
            .map { (forma: $0.0, quantas: $0.1) }

        let decisoes = notas
            .filter { $0.gesto == .decisao && !$0.fechada }
            .filter { ($0.gatilhoEm ?? .distantPast) >= agora }
            .sorted { ($0.gatilhoEm ?? .distantFuture) < ($1.gatilhoEm ?? .distantFuture) }
            .map { Linha(id: $0.uuid, texto: $0.campos["escolha"]?.trimmingCharacters(in: .whitespacesAndNewlines).nonVazio ?? $0.titulo, quando: $0.gatilhoEm) }

        let desejos = notas
            .filter { $0.gesto == .woop && !$0.fechada && $0.criadaEm >= seteAtras }
            .compactMap { n -> Linha? in
                let obst = n.campos["obstaculo"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !obst.isEmpty else { return nil }
                return Linha(id: n.uuid, texto: "\(n.titulo) · obstáculo: \(obst)", quando: nil)
            }

        let deixas = notas
            .filter { !$0.fechada && $0.gesto != .expressiva }
            .compactMap { n -> Linha? in
                guard let q = n.gatilhoEm, q >= agora, q <= seteAFrente else { return nil }
                let chave = n.gesto == .decisao ? "escolha" : "se"
                let se = n.campos[chave]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return Linha(id: n.uuid, texto: se.isEmpty ? n.titulo : se, quando: q)
            }
        let compromissos = eventos
            .filter { $0.inicio >= agora && $0.inicio <= seteAFrente && !$0.eDeixa }
            .map { Linha(id: $0.id, texto: $0.titulo, quando: $0.inicio) }
        let proximos = (deixas + compromissos).sorted { ($0.quando ?? .distantFuture) < ($1.quando ?? .distantFuture) }

        let destaques = daSemana
            .filter { $0.gesto == .destaque }
            .sorted { $0.criadaEm < $1.criadaEm }
            .compactMap { n -> Linha? in
                let u = n.campos["unica"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return u.isEmpty ? nil : Linha(id: n.uuid, texto: u, quando: n.criadaEm)
            }

        let sentidos = notas
            .filter { $0.gesto == .expressiva && $0.fechada }
            .filter { ($0.queimadaOuSeladaEm ?? $0.criadaEm) >= seteAtras }
            .map { $0.sentido.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let semRisco = daSemana.compactMap { n -> Linha? in
            let vazio: (String) -> Bool = { (n.campos[$0] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            switch n.gesto {
            case .spec where vazio("limites"): return Linha(id: n.uuid, texto: n.titulo + " · sem “o que pode dar errado”", quando: nil)
            case .woop where vazio("obstaculo"): return Linha(id: n.uuid, texto: n.titulo + " · sem obstáculo nomeado", quando: nil)
            default: return nil
            }
        }

        let calibragem = notas
            .filter { $0.gesto == .decisao && !$0.fechada }
            // "Esta semana" é esta semana: sem janela, uma decisão conferida em
            // junho ficava no cartão para sempre
            .filter { ($0.queimadaOuSeladaEm ?? $0.criadaEm) >= seteAtras }
            .compactMap { n -> Calibragem? in
                let esperava = (n.campos["espero"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let aconteceu = (n.campos["aconteceu"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                guard !esperava.isEmpty, !aconteceu.isEmpty else { return nil }
                let escolha = (n.campos["escolha"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return Calibragem(id: n.uuid, escolha: escolha.isEmpty ? n.titulo : escolha,
                                  esperava: esperava, aconteceu: aconteceu)
            }

        return RevisaoSemanal(porForma: porForma, decisoesAConferir: decisoes, desejos: desejos,
                              proximos: proximos, destaques: destaques, sentidos: sentidos, semRisco: semRisco,
                              calibragem: calibragem)
    }
}

extension RevisaoSemanal {
    /// A revisão em texto, para os Atalhos e a Siri: o mesmo que o cartão diz.
    nonisolated static func texto(_ r: RevisaoSemanal) -> String {
        var linhas: [String] = []
        if !r.porForma.isEmpty {
            linhas.append(r.porForma.map { "\($0.quantas) \($0.forma?.rawValue ?? "sem forma")" }.joined(separator: " · "))
        }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEE d, HH:mm"
        func bloco(_ t: String, _ xs: [Linha]) {
            guard !xs.isEmpty else { return }
            linhas.append(t + ":")
            for x in xs { linhas.append("— " + (x.quando.map { f.string(from: $0).replacingOccurrences(of: ".", with: "") + " " } ?? "") + x.texto) }
        }
        bloco("Destaques", r.destaques)
        bloco("Decisões a conferir", r.decisoesAConferir)
        bloco("Em jogo", r.desejos)
        bloco("Planos sem a falha nomeada", r.semRisco)
        if !r.calibragem.isEmpty {
            linhas.append("Decisões conferidas:")
            for c in r.calibragem {
                linhas.append("— " + c.escolha)
                linhas.append("   esperava: " + c.esperava)
                linhas.append("   aconteceu: " + c.aconteceu)
            }
        }
        bloco("Próximos sete dias", r.proximos)
        if !r.sentidos.isEmpty {
            linhas.append("O que ficou claro:")
            linhas += r.sentidos.map { "— " + $0 }
        }
        return linhas.joined(separator: "\n")
    }
}

nonisolated private extension String {
    var nonVazio: String? { isEmpty ? nil : self }
}
