import Foundation
import Testing
@testable import Traco

/// DIRETRIZ §14 — a superfície da resposta é UMA, e o que o dono viu às 13h58
/// de 10/09 não pode voltar. Cada teste aqui guarda um dos itens do veredito.
struct SuperficieDaRespostaTests {
    private func fonte(_ texto: String, titulo: String? = nil) -> FonteNotas {
        FonteNotas(id: UUID(), titulo: titulo ?? texto, texto: texto, editadaEm: .now)
    }

    /// "Foram junto: a MESMA nota três vezes". A raiz: o aparelho da conta
    /// tinha três notas com o texto idêntico, e a montagem mandava as três. A
    /// primeira (mais próxima) fica; as iguais pelo texto saem. Títulos iguais
    /// com textos diferentes são notas diferentes e ficam as duas.
    @Test func aMesmaNotaTresVezesViraUma() {
        let a = fonte("Vou virar o banco de dados de uma vez no sábado à noite.")
        let b = fonte("Vou virar o banco de dados de uma vez no sábado à noite.")
        let c = fonte("Vou virar o banco de dados de uma vez no sábado à noite.")
        let d = fonte("Plano da semana", titulo: "Plano")
        let e = fonte("Plano da semana — versão 2", titulo: "Plano")
        let unicas = Sessao.semRepetida([a, b, c, d, e])
        #expect(unicas.map(\.id) == [a.id, d.id, e.id])
        // a sonda que acusa precisa da irmã que não acusa
        #expect(Sessao.semRepetida([d, e]).count == 2)
        #expect(Sessao.semRepetida([]).isEmpty)
    }

    /// A espera diz o tempo do quarto segundo em diante, e a frase é a mesma
    /// nas quatro rotas — minúscula, sem "sobre:", sem caixa alta.
    @Test func aEsperaFalaOTempo() {
        let t0 = Date(timeIntervalSince1970: 1_000)
        let frase = Espera.aSabiaPensa
        #expect(frase == "a sábia pensa")
        #expect(Espera.linha(frase, desde: t0, agora: t0) == "a sábia pensa…")
        #expect(Espera.linha(frase, desde: t0, agora: t0.addingTimeInterval(3)) == "a sábia pensa…")
        #expect(Espera.linha(frase, desde: t0, agora: t0.addingTimeInterval(4)) == "a sábia pensa há 4 s…")
        #expect(Espera.linha(frase, desde: t0, agora: t0.addingTimeInterval(241)) == "a sábia pensa há 241 s…")
        // a Página delega à mesma linha: não há dois relógios
        #expect(CartaoAnaliseView.fraseDaEspera(desde: t0, agora: t0.addingTimeInterval(47)) == "a sábia pensa há 47 s…")
    }

    /// A linha fechada das fontes: quantas, na língua do autor.
    @Test func aLinhaDasFontesContaNaLinguaDoAutor() {
        #expect(CartaoDeResposta<Never>.resumo(1) == "leu 1 nota sua")
        #expect(CartaoDeResposta<Never>.resumo(4) == "leu 4 notas suas")
    }

    /// O jargão que o dono leu na tela não pode voltar a nenhuma das três
    /// superfícies nem ao componente: "A SÁBIA, SOBRE", "Foram junto:" e a
    /// palavra "continua" como texto na dobra. Sonda por texto de fonte,
    /// com a irmã que acusa embutida (o próprio literal desta linha).
    @Test func oJargaoDaTelaDeplorávelNaoVolta() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let arquivos = ["Traco/Notas/NotasView.swift", "Traco/Pagina/CartaoAnaliseView.swift",
                        "Traco/Pagina/LenteView.swift", "Traco/Componentes/CartaoDeResposta.swift",
                        "Traco/Componentes/SinalDeSobra.swift"]
        let proibidos = ["A sábia, sobre", "Foram junto", "Text(\"continua\")", "ProgressView()"]
        for caminho in arquivos {
            let codigo = PortaoDoMovimentoTests.codigoVisivel(
                try String(contentsOf: raiz.appendingPathComponent(caminho), encoding: .utf8), apagandoTema: false)
            for p in proibidos {
                #expect(!codigo.contains(p), "\(caminho) ainda escreve '\(p)' na tela")
            }
        }
        #expect(PortaoDoMovimentoTests.codigoVisivel("Text(\"A sábia, sobre: x\")", apagandoTema: false).contains("A sábia, sobre") == false,
                "a sonda apaga literais: o que ela conta é CÓDIGO que constrói o texto")
        #expect(PortaoDoMovimentoTests.codigoVisivel("let k = \"A SÁBIA, SOBRE: \\(q)\"", apagandoTema: false).isEmpty == false)
    }
}
