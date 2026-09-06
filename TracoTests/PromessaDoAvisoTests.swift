import Foundation
import Testing
@testable import Traco

/// Volta 18, defeito 6 da auditoria V9: a folha do ato prometia "Toca hoje às
/// 20:22 · na hora" com os avisos do Traço desligados no iPhone. O `Bool`
/// `permissaoNegada` juntava *negado* e *ainda não perguntado* — e só o
/// primeiro calava a promessa. A frase agora sai de `Avisos.Estado`, com os
/// quatro casos distintos (ADR 04a: estado honesto).
struct PromessaDoAvisoTests {
    private let hora = "hoje às 20:22 · na hora"

    @Test func semAvisoNaoPrometeAlarme() {
        for estado: Avisos.Estado? in [.concedido, .negado, .naoPerguntado, nil] {
            #expect(PromessaDoAviso.para(minutos: nil, estado: estado, hora: hora) == .semAviso)
        }
    }

    @Test func negadoNaoPromete() {
        let p = PromessaDoAviso.para(minutos: 0, estado: .negado, hora: hora)
        #expect(p == .desligados)
        #expect(!p.texto.contains("Toca"))
        #expect(p.texto.contains("nada vai tocar"))
    }

    /// O buraco da V9: sem ter perguntado, o app não sabe se vai tocar. A
    /// frase diz a hora e a condição — nunca a hora sozinha.
    @Test func naoPerguntadoPrometeSobCondicao() {
        let p = PromessaDoAviso.para(minutos: 30, estado: .naoPerguntado, hora: hora)
        #expect(p == .seDeixarem(hora))
        #expect(p.texto.contains("se você permitir"))
    }

    /// Enquanto a leitura da permissão não volta, a tela não promete sozinha.
    @Test func leituraPendenteSeguraAPromessa() {
        #expect(PromessaDoAviso.para(minutos: 0, estado: nil, hora: hora) == .seDeixarem(hora))
    }

    @Test func concedidoPrometeSemCondicao() {
        let p = PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora)
        #expect(p == .toca(hora))
        #expect(p.texto == "Toca \(hora).")
        #expect(!p.texto.contains("se você permitir"))
    }

    // MARK: - A outra metade da mentira: o relógio (revisão da volta 18)

    /// A folha prometia "Toca hoje às 14:37" às 15:08. Permissão nenhuma faz o
    /// iPhone tocar para trás: com a hora passada, a frase é a do motor.
    @Test func horaPassadaNaoPromete() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        for estado: Avisos.Estado? in [.concedido, .naoPerguntado, nil] {
            let p = PromessaDoAviso.para(minutos: 30, estado: estado, hora: hora,
                                         instante: agora.addingTimeInterval(-31 * 60), agora: agora)
            #expect(p == .jaPassou)
            #expect(!p.texto.contains("Toca"))
            #expect(p.texto == "A hora do aviso já passou — esta ação ficou sem alarme.")
        }
    }

    /// O instante exato do alarme já não toca: é o mesmo corte do motor
    /// (`guard quando > agora`), e não um a menos.
    @Test func horaExataDoAlarmeJaPassou() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: agora, agora: agora) == .jaPassou)
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: agora.addingTimeInterval(1), agora: agora) == .toca(hora))
    }

    /// Sem permissão o beco vem primeiro: a saída dos Ajustes resolve os dois,
    /// e é a ordem do motor (`semPermissao` antes de `passou`).
    @Test func negadoVemAntesDoRelogio() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: 30, estado: .negado, hora: hora,
                                     instante: agora.addingTimeInterval(-60), agora: agora) == .desligados)
    }

    /// Sem aviso pedido, o relógio não tem o que dizer.
    @Test func semAvisoIgnoraORelogio() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: nil, estado: .concedido, hora: hora,
                                     instante: agora.addingTimeInterval(-60), agora: agora) == .semAviso)
    }

    /// Sem instante — evento que não situa alarme no tempo — a promessa é a de
    /// antes: o caso novo não pode engolir os quatro que já existiam.
    @Test func semInstanteMantemOsQuatroCasos() {
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora) == .toca(hora))
        #expect(PromessaDoAviso.para(minutos: 0, estado: .naoPerguntado, hora: hora) == .seDeixarem(hora))
    }
}
