import Testing
@testable import Traco

/// A voz do autor junta os campos na ordem do método, não na do dicionário (volta 65).
struct OrdemDosCamposTests {
    @Test func woopNaOrdemDoMetodo() {
        let campos = ["plano": "deixo na cozinha", "obstaculo": "o celular na cama", "resultado": "acordar sem alarme"]
        let voz = VozDoAutor.juntar(texto: "Quero dormir cedo", campos: campos)
        let linhas = voz.split(separator: "\n").map(String.init)
        #expect(linhas == ["Quero dormir cedo", "acordar sem alarme", "o celular na cama", "deixo na cozinha"])
    }

    @Test func semMetodoOrdenaPelaChave() {
        let r = VozDoAutor.respostasNaOrdemDoMetodo(["zeta": "z", "alfa": "a"])
        #expect(r == ["a", "z"])
    }
}
