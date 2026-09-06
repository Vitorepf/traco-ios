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
}
