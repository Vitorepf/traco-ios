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
            #expect(PromessaDoAviso.para(minutos: nil, estado: estado, hora: hora,
                                         instante: nil, repete: false) == .semAviso)
        }
    }

    @Test func negadoNaoPromete() {
        let p = PromessaDoAviso.para(minutos: 0, estado: .negado, hora: hora,
                                     instante: nil, repete: false)
        #expect(p == .desligados)
        #expect(!p.texto.contains("Toca"))
        #expect(p.texto.contains("nada vai tocar"))
    }

    /// O buraco da V9: sem ter perguntado, o app não sabe se vai tocar. A
    /// frase diz a hora e a condição — nunca a hora sozinha.
    @Test func naoPerguntadoPrometeSobCondicao() {
        let p = PromessaDoAviso.para(minutos: 30, estado: .naoPerguntado, hora: hora,
                                     instante: nil, repete: false)
        #expect(p == .seDeixarem(hora))
        #expect(p.texto.contains("se você permitir"))
    }

    /// Enquanto a leitura da permissão não volta, a tela não promete sozinha.
    @Test func leituraPendenteSeguraAPromessa() {
        #expect(PromessaDoAviso.para(minutos: 0, estado: nil, hora: hora,
                                     instante: nil, repete: false) == .seDeixarem(hora))
    }

    @Test func concedidoPrometeSemCondicao() {
        let p = PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: nil, repete: false)
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
                                         instante: agora.addingTimeInterval(-31 * 60), repete: false, agora: agora)
            #expect(p == .jaPassou)
            #expect(!p.texto.contains("Toca"))
            #expect(p.texto == "A hora do aviso já passou — nada vai tocar.")
        }
    }

    /// O instante exato do alarme já não toca: é o mesmo corte do motor
    /// (`guard quando > agora`), e não um a menos.
    @Test func horaExataDoAlarmeJaPassou() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: agora, repete: false, agora: agora) == .jaPassou)
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: agora.addingTimeInterval(1), repete: false, agora: agora) == .toca(hora))
    }

    /// Sem permissão o beco vem primeiro: a saída dos Ajustes resolve os dois,
    /// e é a ordem do motor (`semPermissao` antes de `passou`).
    @Test func negadoVemAntesDoRelogio() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: 30, estado: .negado, hora: hora,
                                     instante: agora.addingTimeInterval(-60), repete: false, agora: agora) == .desligados)
    }

    /// Sem aviso pedido, o relógio não tem o que dizer.
    @Test func semAvisoIgnoraORelogio() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: nil, estado: .concedido, hora: hora,
                                     instante: agora.addingTimeInterval(-60), repete: false, agora: agora) == .semAviso)
    }

    /// Sem instante — evento que não situa alarme no tempo — a promessa é a de
    /// antes: o caso novo não pode engolir os quatro que já existiam. O `nil`
    /// agora é **escrito** no chamador: `instante:` perdeu o valor padrão, e o
    /// silêncio que este teste canonizava virou uma decisão visível (re-G3).
    @Test func semInstanteMantemOsQuatroCasos() {
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: nil, repete: false) == .toca(hora))
        #expect(PromessaDoAviso.para(minutos: 0, estado: .naoPerguntado, hora: hora,
                                     instante: nil, repete: false) == .seDeixarem(hora))
    }

    // MARK: - A mentira ao contrário: o compromisso que se repete (re-G3)

    /// `Aviso.instante` conta a partir do **início da série**, que para
    /// "Correr toda terça 6:30" está no passado — mas `agendarCompromisso`
    /// arma um id por dia da semana e o alarme toca toda semana. Sem o guarda,
    /// a ficha do Calendário diria "ficou sem alarme" do compromisso que mais
    /// toca. O mesmo instante, sem série, continua sendo hora passada.
    @Test func serieQueRepeteNaoFicaSemAlarme() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let origemDaSerie = agora.addingTimeInterval(-7 * 24 * 60 * 60)
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: origemDaSerie, repete: true, agora: agora) == .toca(hora))
        #expect(PromessaDoAviso.para(minutos: 30, estado: .naoPerguntado, hora: hora,
                                     instante: origemDaSerie, repete: true, agora: agora) == .seDeixarem(hora))
        #expect(PromessaDoAviso.para(minutos: 0, estado: .concedido, hora: hora,
                                     instante: origemDaSerie, repete: false, agora: agora) == .jaPassou)
    }

    /// Repetir não devolve promessa a quem desligou os avisos: o beco continua
    /// vindo antes do relógio, e antes da série.
    @Test func serieQueRepeteNaoAtropelaOBeco() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let p = PromessaDoAviso.para(minutos: 30, estado: .negado, hora: hora,
                                     instante: agora.addingTimeInterval(-60), repete: true, agora: agora)
        #expect(p == .desligados)
        #expect(p.texto.contains("nada vai tocar"))
    }

    /// Série sem aviso pedido continua sem aviso: `repete` não inventa alarme.
    @Test func serieSemAvisoContinuaSemAviso() {
        let agora = Date(timeIntervalSinceReferenceDate: 800_000_000)
        #expect(PromessaDoAviso.para(minutos: nil, estado: .concedido, hora: hora,
                                     instante: agora.addingTimeInterval(-60), repete: true,
                                     agora: agora) == .semAviso)
    }
}
