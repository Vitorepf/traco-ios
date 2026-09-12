import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-12a — a tesoura lê a NOTA. Os textos são os cegos de
/// `prova/q4c-contrapor-cego-casos.json`. O join velho não volta.
struct GuardaDeContraporTests {
    private let alternativas =
        "Vou virar o banco de dados de uma vez no sábado à noite. Fazer em etapas eu já descartei: o esquema muda inteiro e as duas versões não rodam juntas. Adiar também não dá, o contrato vence neste mês. Não sei quanto tempo a virada leva e não tenho ambiente de teste com os dados reais."
    private let razoes =
        "Vou cancelar a assinatura da academia. Não é o preço, que eu acho justo, nem a distância, que é de cinco minutos a pé, nem o horário, que é livre. É que eu simplesmente não vou. Não anotei quantos dias fui neste mês e não quero trocar por outra academia nem treinar em casa."

    @Test func notaFechaEtapasAdiarEAmbienteDeTeste() {
        let f = GuardaDeContrapor.saidasFechadas(alternativas)
        #expect(f.contains(where: { $0.contains("etapa") }))
        #expect(f.contains(where: { $0.contains("adiar") }))
        #expect(f.contains(where: { $0.contains("ambiente") }))
    }

    @Test func substitutoDaSaidaFechadaCaiEOpcaoQueCabeFica() {
        #expect(GuardaDeContrapor.oferece("Fazer a virada em etapas no fim de semana.",
                                          fechadas: GuardaDeContrapor.saidasFechadas(alternativas)))
        #expect(GuardaDeContrapor.oferece("Adiar para o mês que vem.",
                                          fechadas: GuardaDeContrapor.saidasFechadas(alternativas)))
        #expect(GuardaDeContrapor.oferece("Ensaiar com os dados reais num ambiente de teste.",
                                          fechadas: GuardaDeContrapor.saidasFechadas(alternativas)))
        #expect(!GuardaDeContrapor.oferece("Virar num sábado mais cedo no mesmo mês.",
                                           fechadas: GuardaDeContrapor.saidasFechadas(alternativas)))
    }

    @Test func academiaFechaTrocaECasaENaoMataPausaDaMatricula() {
        let f = GuardaDeContrapor.saidasFechadas(razoes)
        #expect(f.contains(where: { $0.contains("academia") }))
        #expect(f.contains(where: { $0.contains("casa") }))
        #expect(GuardaDeContrapor.oferece("Trocar por outra academia mais perto.", fechadas: f))
        #expect(GuardaDeContrapor.oferece("Treinar em casa três vezes por semana.", fechadas: f))
        #expect(!GuardaDeContrapor.oferece(
            "Pausar ou congelar a matrícula por um período, em vez de cancelar de vez.",
            fechadas: f),
                "é o erro do join: ela TEM a matrícula")
        #expect(!GuardaDeContrapor.oferece("Anotar os dias que ela vai neste mês.", fechadas: f))
    }

    @Test func parseDerrubaOSubstitutoENaoOContra() throws {
        let cru = #"""
        {"contra":"A virada sem duração conhecida concentra o risco na única noite do contrato.","foraDaLista":"Fazer a virada em etapas no sábado seguinte.","outroCampo":""}
        """#
        let r = try #require(Sabia.parseContraparte(cru, texto: alternativas))
        #expect(r.foraDaLista.isEmpty)
        #expect(!r.contra.isEmpty)
    }

    @Test func parsePreservaAPausaQueOJoinMatava() throws {
        let cru = #"""
        {"fechadas":["não quero trocar por outra academia","não quero treinar em casa"],"contra":"Cancelar encerra o pagamento e não toca no simplesmente não vou.","foraDaLista":"pausar ou congelar a matrícula por um período, em vez de cancelar de vez","dependeDe":"a academia permitir pausa da matrícula sem trocar de unidade","outroCampo":""}
        """#
        let r = try #require(Sabia.parseContraparte(cru, texto: razoes))
        #expect(!r.foraDaLista.isEmpty)
        #expect(!r.contra.isEmpty)
    }
}
