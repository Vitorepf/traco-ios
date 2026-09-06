import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-06j — a latência da descoberta. O que se prova aqui é que a
/// leitura sai do que JÁ estava gravado, que os quatro estados são distintos
/// e que nada é inventado quando a data não existe.
@Suite struct LatenciaTests {
    private let cal = Calendar(identifier: .gregorian)
    private func dia(_ d: Int, _ m: Int = 3, _ a: Int = 2026) -> Date {
        cal.date(from: DateComponents(year: a, month: m, day: d, hour: 10))!
    }
    private func hipotese(_ texto: String, data: Date, avaliadaEm: Date? = nil,
                          estado: DocumentoTrabalho.EstadoHipotese = .proposta)
    -> DocumentoTrabalho.Hipotese {
        var h = DocumentoTrabalho.Hipotese(texto: texto, contexto: "", evidencias: [])
        h.data = data
        h.avaliadaEm = avaliadaEm
        h.estado = estado
        return h
    }

    @Test func aHipoteseAvaliadaDaOsDoisCarimbosEADistanciaEmDias() {
        let r = Latencia.registros(
            hipoteses: [hipotese("travo no meio", data: dia(1), avaliadaEm: dia(15), estado: .confirmada)],
            encerrado: false)
        #expect(r.count == 1)
        #expect(r[0].estado == .descoberto)
        #expect(r[0].dias == 14)
        #expect(r[0].fonte == .hipotese)
    }

    /// O registro antigo do ADR 05r: avaliado ANTES do campo existir. Descobriu,
    /// e quando não está gravado — a tela diz isso e não deduz nada.
    @Test func hipoteseAntigaSemAvaliadaEmDescobreSemTempo() {
        let r = Latencia.registros(
            hipoteses: [hipotese("isto era o gargalo", data: dia(1), avaliadaEm: nil, estado: .contestada)],
            encerrado: false)
        #expect(r[0].estado == .descoberto)
        #expect(r[0].descobertoEm == nil)
        #expect(r[0].dias == nil)
        let s = Latencia.serie(r, agora: dia(20))
        #expect(s.semData.count == 1)
        #expect(s.descobertos.isEmpty)
        #expect(s.meses.isEmpty)
        #expect(Latencia.emPalavras(s).contains("1 sem a data da descoberta"))
    }

    @Test func hipoteseAbertaContinuaAbertaEOTrabalhoEncerradoAAbandona() {
        let aberta = hipotese("talvez seja o horário", data: dia(1))
        #expect(Latencia.registros(hipoteses: [aberta], encerrado: false)[0].estado == .afirmado)
        #expect(Latencia.registros(hipoteses: [aberta], encerrado: true)[0].estado == .abandonado)
        // sem data de conferir, hipótese nunca é cobrada
        #expect(Latencia.registros(hipoteses: [aberta], encerrado: false).allSatisfy { $0.estado != .devido })
    }

    // MARK: - Decisão

    private func decisao(_ campos: [String: String], criadaEm: Date, fechada: Bool = false,
                         agora: Date, versoes: [VersaoNota] = []) -> Latencia.Registro {
        Latencia.registro(decisao: UUID(), campos: campos, criadaEm: criadaEm,
                          fechada: fechada, agora: agora, versoes: { _ in versoes })
    }

    @Test func aDecisaoRespondidaDataADescobertaPeloHistoricoDeVersoes() {
        let campos = ["escolha": "trocar de fornecedor", "espero": "queda de 20% até 20/03/2026",
                      "aconteceu": "caiu 8%"]
        let versoes = [
            VersaoNota(data: dia(2), texto: "", campos: ["escolha": "trocar de fornecedor"]),
            VersaoNota(data: dia(18), texto: "", campos: ["escolha": "trocar de fornecedor",
                                                         "espero": "queda de 20% até 20/03/2026",
                                                         "aconteceu": ""]),
        ]
        let r = decisao(campos, criadaEm: dia(1), agora: dia(25), versoes: versoes)
        #expect(r.estado == .descoberto)
        #expect(r.descobertoEm == dia(18))
        #expect(r.dias == 17)
    }

    /// Sem histórico (nota importada, ou o teto de 30 versões passou por cima)
    /// a descoberta existe e a data não. `editadaEm` mentiria a cada retoque.
    @Test func decisaoRespondidaSemHistoricoNaoInventaData() {
        let r = decisao(["escolha": "ir de trem", "aconteceu": "atrasou"],
                        criadaEm: dia(1), agora: dia(25))
        #expect(r.estado == .descoberto)
        #expect(r.descobertoEm == nil)
        #expect(r.dias == nil)
    }

    @Test func aHoraDeConferirSepararAfirmadoDeDevido() {
        // o texto não traz hora de propósito: `Gatilho` lê "9h" antes da data
        // e devolveria a próxima manhã (limite herdado, não corrigido aqui)
        let campos = ["escolha": "ir de trem", "espero": "confiro em 20/03/2026"]
        #expect(decisao(campos, criadaEm: dia(1), agora: dia(10)).estado == .afirmado)
        #expect(decisao(campos, criadaEm: dia(1), agora: dia(22)).estado == .devido)
        // fechar sem responder é abandonar, e abandonar é resultado, não falha
        #expect(decisao(campos, criadaEm: dia(1), fechada: true, agora: dia(22)).estado == .abandonado)
    }

    /// A data do "espero" é lida a partir de QUANDO foi escrita. Lida a partir
    /// de hoje, "em duas semanas" adiaria a cobrança para sempre.
    @Test func aDataDoEsperoAncoraNaEscrita() {
        let r = decisao(["espero": "confiro em 20/03/2026"], criadaEm: dia(1), agora: dia(2))
        #expect(r.devidoEm != nil)
        #expect(cal.isDate(r.devidoEm!, inSameDayAs: dia(20)))
    }

    // MARK: - A série

    @Test func aSerieAgrupaPorMesComMedianaEGuardaOsAbertosAoLado() {
        var rs: [Latencia.Registro] = []
        for (d, ate) in [(1, 3), (2, 12), (5, 25)] {   // março: 2, 10 e 20 dias
            rs += Latencia.registros(hipoteses: [hipotese("h\(d)", data: dia(d),
                                                          avaliadaEm: dia(ate), estado: .confirmada)],
                                     encerrado: false)
        }
        rs += Latencia.registros(hipoteses: [hipotese("abril", data: dia(1, 4),
                                                      avaliadaEm: dia(4, 4), estado: .confirmada)],
                                 encerrado: false)
        rs += Latencia.registros(hipoteses: [hipotese("ainda em pé", data: dia(20, 3))], encerrado: false)
        let s = Latencia.serie(rs, agora: dia(10, 5), cal: cal)
        #expect(s.meses.count == 2)
        #expect(s.meses[0].quantas == 3)
        #expect(s.meses[0].mediana == 10)      // mediana, não média (10,67)
        #expect(s.meses[1].mediana == 3)
        #expect(s.abertos.count == 1)
        #expect(s.abertos[0].diasEmAberto(agora: dia(10, 5)) == 51)
        #expect(s.medianaGeral == 7)           // [2,3,10,20] → (3+10+1)/2
        #expect(Latencia.emPalavras(s, agora: dia(10, 5)).contains("1 em aberto"))
    }

    /// ADR 05s: o selo não abre por causa de uma medida. Fechada conta, e o
    /// que ela dizia não aparece.
    @Test func notaFechadaEntraPelaContagemENaoPeloConteudo() {
        let r = decisao(["escolha": "segredo do autor", "aconteceu": "deu certo"],
                        criadaEm: dia(1), fechada: true, agora: dia(25))
        #expect(r.texto.isEmpty)
        #expect(r.estado == .descoberto)
    }

    @Test func serieVaziaNaoDizNada() {
        let s = Latencia.serie([])
        #expect(s.vazia)
        #expect(Latencia.emPalavras(s).isEmpty)
    }

    @Test func menosDeUmDiaNaoViraUmDia() {
        let inicio = dia(1)
        let r = Latencia.registros(
            hipoteses: [hipotese("rápida", data: inicio,
                                 avaliadaEm: inicio.addingTimeInterval(3 * 3600), estado: .confirmada)],
            encerrado: false)
        #expect(r[0].dias == 0)
        #expect(Latencia.emDias(0) == "menos de um dia")
        #expect(Latencia.emDias(1) == "1 dia")
    }
}
