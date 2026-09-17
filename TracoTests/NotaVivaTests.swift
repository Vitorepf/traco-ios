import Foundation
import Testing
@testable import Traco

/// A nota viva (proposta de 16/09): juntar e separar não tocam nas notas, só
/// em quem anda com quem; o «Desfazer» devolve o mapa de antes; a diferença
/// entre versões é das palavras do autor.
@Suite(.serialized) struct NotaVivaTests {
    private func limpo() {
        Juntas.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("juntas-\(UUID().uuidString).json")
        Juntas.esquecerCache()
    }

    @Test func juntarSepararEDesfazer() {
        limpo()
        let a = UUID(), b = UUID(), c = UUID()
        #expect(Juntas.grupo(de: a) == nil)
        #expect(Juntas.membros(de: a) == [a])

        #expect(Juntas.juntar(a, com: b))
        #expect(Set(Juntas.membros(de: a)) == [a, b])
        let antes = Juntas.mapa()

        // a terceira entra no mesmo grupo, por qualquer das duas
        #expect(Juntas.juntar(c, com: b))
        #expect(Set(Juntas.membros(de: c)) == [a, b, c])

        // o arquivo guarda: quem lê de novo vê o mesmo grupo
        Juntas.esquecerCache()
        #expect(Set(Juntas.membros(de: b)) == [a, b, c])

        #expect(Juntas.restaurar(antes))
        #expect(Set(Juntas.membros(de: a)) == [a, b])
        #expect(Juntas.grupo(de: c) == nil)

        // separar uma de duas desfaz o grupo inteiro: ninguém fica «1 versão»
        #expect(Juntas.separar(a))
        #expect(Juntas.grupo(de: a) == nil)
        #expect(Juntas.grupo(de: b) == nil)
        // a sonda irmã: separar quem não está junto não grava nada
        #expect(!Juntas.separar(c))
        // juntar consigo mesma não existe
        #expect(!Juntas.juntar(a, com: a))
    }

    @Test func doisGruposViramUm() {
        limpo()
        let a = UUID(), b = UUID(), c = UUID(), d = UUID()
        Juntas.juntar(a, com: b)
        Juntas.juntar(c, com: d)
        Juntas.juntar(a, com: c)
        #expect(Set(Juntas.membros(de: d)) == [a, b, c, d])
    }

    @Test func seloOrigemEExpressivaNuncaEntram() {
        #expect(Juntas.podeJuntar(fechada: false, gesto: nil, obra: false))
        #expect(Juntas.podeJuntar(fechada: false, gesto: .decisao, obra: false))
        #expect(!Juntas.podeJuntar(fechada: true, gesto: nil, obra: false))
        #expect(!Juntas.podeJuntar(fechada: false, gesto: .expressiva, obra: false))
        #expect(!Juntas.podeJuntar(fechada: false, gesto: nil, obra: true))
    }

    @Test func aDiferencaEDasPalavrasDoAutor() {
        let d = Juntas.diferenca(de: "Compras\n- Arroz\n- Leite\n- Café", para: "Compras\n- arroz\n- Café\n- Detergente")
        #expect(d.entrou == ["Detergente"])
        #expect(d.saiu == ["Leite"])
        // acento e caixa não são mudança
        let igual = Juntas.diferenca(de: "- Pão", para: "• pao")
        #expect(igual.entrou.isEmpty && igual.saiu.isEmpty)
    }

    @Test func aMaisParecidaVemPrimeiro() {
        let compras = UUID(), treino = UUID(), mercado = UUID()
        let hoje = Date()
        let ordem = Juntas.parecidas(
            com: "Compras do mês", texto: "arroz café leite", gesto: nil,
            candidatas: [
                (treino, "Treino de corrida", "8 km", nil, hoje),
                (mercado, "Mercado", "arroz e café", nil, hoje.addingTimeInterval(-86_400)),
                (compras, "Compras", "arroz leite", nil, hoje.addingTimeInterval(-2 * 86_400)),
            ])
        #expect(ordem.first == compras)
        #expect(ordem.last == treino)
    }
}
