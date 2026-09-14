import Testing
@testable import Traco

/// O rótulo do catálogo separa nome e dica pelos parênteses (volta 37).
struct CampoFormaNomeTests {
    @Test func nomeEDica() {
        let c = CampoForma(id: "r", rotulo: "Resultado (o melhor desfecho)")
        #expect(c.nome == "Resultado")
        #expect(c.dica == "o melhor desfecho")
    }

    @Test func semParentesesNaoTemDica() {
        let c = CampoForma(id: "p", rotulo: "Se [obstáculo], então eu")
        #expect(c.nome == "Se [obstáculo], então eu")
        #expect(c.dica == nil)
    }

    @Test func parentesesNoMeioNaoSaoDica() {
        let c = CampoForma(id: "x", rotulo: "Quanto (0–100) hoje")
        #expect(c.nome == "Quanto")
        #expect(c.dica == nil)
    }
}
