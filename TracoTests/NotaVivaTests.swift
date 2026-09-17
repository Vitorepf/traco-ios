import Foundation
import Testing
@testable import Traco

/// A nota viva (proposta de 16/09): juntar e separar não tocam nas notas, só
/// em quem anda com quem; o «Desfazer» devolve o mapa de antes; a diferença
/// entre versões é das palavras do autor.
@Suite(.serialized) struct NotaVivaTests {
    /// Troca o arquivo por um temporário e devolve o original no fim.
    private func comArquivoTemporario(_ corpo: () -> Void) {
        let original = Juntas.url
        Juntas.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("juntas-\(UUID().uuidString).json")
        Juntas.esquecerCache()
        defer {
            Juntas.url = original
            Juntas.esquecerCache()
        }
        corpo()
    }

    @Test func juntarSepararEDesfazer() { comArquivoTemporario {
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
    } }

    @Test func doisGruposViramUm() { comArquivoTemporario {
        let a = UUID(), b = UUID(), c = UUID(), d = UUID()
        Juntas.juntar(a, com: b)
        Juntas.juntar(c, com: d)
        Juntas.juntar(a, com: c)
        #expect(Set(Juntas.membros(de: d)) == [a, b, c, d])
    } }

    @Test func separarUmaDeTresDeixaAsOutrasJuntas() { comArquivoTemporario {
        let a = UUID(), b = UUID(), c = UUID()
        Juntas.juntar(a, com: b)
        Juntas.juntar(a, com: c)
        #expect(Juntas.separar(c))
        #expect(Juntas.grupo(de: c) == nil)
        #expect(Set(Juntas.membros(de: a)) == [a, b])
    } }

    /// Revisão de 16/09: nota selada DEPOIS de juntada não conta, não é
    /// representante e não esconde as abertas.
    @Test func notaSeladaDepoisDeJuntadaNaoEscondeNemConta() {
        let g = UUID(), aberta = UUID(), selada = UUID(), outra = UUID(), solta = UUID()
        let mapa = [aberta: g, selada: g, outra: g]
        let hoje = Date()
        let fichas: [Juntas.Ficha] = [
            .init(uuid: selada, criadaEm: hoje, podeJuntar: false),           // a mais nova, trancada
            .init(uuid: aberta, criadaEm: hoje.addingTimeInterval(-60), podeJuntar: true),
            .init(uuid: solta, criadaEm: hoje.addingTimeInterval(-90), podeJuntar: true),
            .init(uuid: outra, criadaEm: hoje.addingTimeInterval(-120), podeJuntar: true),
        ]
        let contagens = Juntas.contagens(mapa, fichas)
        #expect(contagens[aberta] == 2 && contagens[outra] == 2)
        #expect(contagens[selada] == nil && contagens[solta] == nil)
        let lista = Juntas.recolher(fichas, mapa: mapa, contagens: contagens)
        // a selada aparece sozinha, a aberta representa o grupo, a outra fica atrás dela
        #expect(lista == [selada, aberta, solta])

        // a irmã que acusa: com as duas abertas seladas, o grupo acaba e ninguém some
        let tudoSelado = fichas.map { Juntas.Ficha(uuid: $0.uuid, criadaEm: $0.criadaEm, podeJuntar: $0.uuid == solta || $0.uuid == aberta) }
        let c2 = Juntas.contagens(mapa, tudoSelado)
        #expect(c2.isEmpty)
        #expect(Juntas.recolher(tudoSelado, mapa: mapa, contagens: c2) == fichas.map(\.uuid))
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
        // só um marcador inteiro sai: a palavra que começa com x fica inteira
        let x = Juntas.diferenca(de: "", para: "- xícara\n[x] xarope\nxampu")
        #expect(x.entrou == ["xícara", "xarope", "xampu"])
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
