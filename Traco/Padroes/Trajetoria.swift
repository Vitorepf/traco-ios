import Foundation

/// A trajetória (ADR 2026-09-04q): dois períodos lado a lado, só evidência
/// nas palavras do autor. Sem seta, sem melhor/pior, sem porcentagem: os dois
/// lados ficam ali e quem lê é ele, como na calibragem (ADR 03o).
nonisolated struct Trajetoria: Equatable, Sendable {
    nonisolated struct Linha: Equatable, Sendable, Identifiable {
        var id: UUID
        var texto: String
    }

    nonisolated struct Periodo: Equatable, Sendable {
        var rotulo: String
        var porForma: [String] = []
        var obstaculos: [Linha] = []
        /// "faltaram 3 de 11 pontos, em 4 provas" — contagem, nunca nota.
        var recordar: String = ""
        var calibragem: String = ""
        var palavras: [Linha] = []
        var sentidos: [String] = []
        var notas: Int = 0

        var vazio: Bool {
            porForma.isEmpty && obstaculos.isEmpty && recordar.isEmpty && calibragem.isEmpty
                && palavras.isEmpty && sentidos.isEmpty
        }
    }

    var recente: Periodo
    var anterior: Periodo

    var vazia: Bool { recente.vazio && anterior.vazio }

    nonisolated struct NotaLida: Sendable {
        var uuid: UUID
        var gesto: Gesto?
        var fechada: Bool
        var criadaEm: Date
        var editadaEm: Date
        var campos: [String: String]
        var sentido: String
        /// ADR 08u/09b: a trajetória é da mente do autor. O que o bot escreveu
        /// não entra — nem na calibragem, nem nas palavras dele, nem na linha
        /// de sentido. Sem padrão: o chamador declara ou não compila.
        var vozDoAutor: Bool
    }

    nonisolated static func ler(notas: [NotaLida], sinais: [Sinal], agora: Date = .now,
                                cal: Calendar = .current) -> Trajetoria {
        let trinta = cal.date(byAdding: .day, value: -30, to: agora) ?? agora
        let sessenta = cal.date(byAdding: .day, value: -60, to: agora) ?? agora
        return Trajetoria(
            recente: periodo("ÚLTIMOS 30 DIAS", notas: notas, sinais: sinais, de: trinta, a: agora),
            anterior: periodo("OS 30 ANTERIORES", notas: notas, sinais: sinais, de: sessenta, a: trinta)
        )
    }

    private static func periodo(_ rotulo: String, notas: [NotaLida], sinais: [Sinal],
                                de: Date, a: Date) -> Periodo {
        var p = Periodo(rotulo: rotulo)
        // o selo: expressiva só entra pela linha de sentido, como sempre
        let abertas = notas.filter { !$0.fechada && $0.gesto != .expressiva && $0.vozDoAutor && $0.criadaEm >= de && $0.criadaEm <= a }
        p.notas = abertas.count
        var conta: [String: Int] = [:]
        for n in abertas { conta[n.gesto?.nome ?? "soltas", default: 0] += 1 }
        p.porForma = conta.sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .prefix(6).map { "\($0.value) \($0.key.lowercased())" }

        p.obstaculos = abertas.filter { $0.gesto == .woop }
            .sorted { $0.criadaEm > $1.criadaEm }
            .compactMap { n in
                let o = (n.campos["obstaculo"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return o.isEmpty ? nil : Linha(id: n.uuid, texto: String(o.prefix(90)))
            }
            .prefix(3).map { $0 }

        let provas = sinais.filter { $0.tipo == .naoVoltou && $0.quando >= de && $0.quando <= a }
        if !provas.isEmpty {
            let faltou = provas.reduce(0) { $0 + ($1.faltaram ?? 0) }
            let total = provas.reduce(0) { $0 + ($1.deQuantos ?? 0) }
            if total > 0 {
                p.recordar = "\(faltou) de \(total) pontos não voltaram, em \(provas.count) \(provas.count == 1 ? "prova" : "provas")"
            }
        }

        let lidas = abertas.map {
            Retrato.NotaLida(gesto: $0.gesto, fechada: $0.fechada, expressiva: $0.gesto == .expressiva,
                             criadaEm: $0.criadaEm, campos: $0.campos, vozDoAutor: true)
        }
        let c = Retrato.calibrar(lidas)
        if c.total > 0 {
            p.calibragem = "\(c.total) conferida\(c.total == 1 ? "" : "s") · aquém \(c.aquem) · igual \(c.igual) · além \(c.alem)"
        }

        p.palavras = abertas.filter { $0.gesto == .palavra }
            .sorted { $0.criadaEm > $1.criadaEm }
            .compactMap { n in
                let m = (n.campos["minhas"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return m.isEmpty ? nil : Linha(id: n.uuid, texto: String(m.prefix(60)))
            }
            .prefix(3).map { $0 }

        p.sentidos = notas.filter { $0.vozDoAutor && $0.gesto == .expressiva && $0.fechada && $0.editadaEm >= de && $0.editadaEm <= a }
            .sorted { $0.editadaEm > $1.editadaEm }
            .map { $0.sentido.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(3).map { $0 }
        return p
    }

    /// Em texto, para o intent "Trajetória" e o MCP: o mesmo que o cartão diz.
    nonisolated static func texto(_ t: Trajetoria) -> String {
        func bloco(_ p: Periodo) -> String {
            var l: [String] = [p.rotulo + " (\(p.notas) \(p.notas == 1 ? "nota" : "notas"))"]
            if !p.porForma.isEmpty { l.append("formas: " + p.porForma.joined(separator: " · ")) }
            if !p.obstaculos.isEmpty { l.append("obstáculos: " + p.obstaculos.map { "“\($0.texto)”" }.joined(separator: "; ")) }
            if !p.recordar.isEmpty { l.append("recordar: " + p.recordar) }
            if !p.calibragem.isEmpty { l.append("decisões: " + p.calibragem) }
            if !p.palavras.isEmpty { l.append("palavras: " + p.palavras.map(\.texto).joined(separator: "; ")) }
            if !p.sentidos.isEmpty { l.append("o que ficou claro: " + p.sentidos.map { "“\($0)”" }.joined(separator: "; ")) }
            return l.joined(separator: "\n")
        }
        return bloco(t.recente) + "\n\n" + bloco(t.anterior)
    }
}
