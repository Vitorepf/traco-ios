import Foundation
import Testing
@testable import Traco

/// Report do dono (17/09): "ao segurar a nota eu não estou vendo mais o campo
/// de versões… uma nota de compra deveria ter versões". A regra que ele quer é
/// a que o disco já seguia — versão é de toda nota, menos a expressiva —, e
/// agora a tela lê essa mesma regra em vez de repeti-la.
struct VersoesEmTodaNotaTests {
    private func pastaTemp() -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("v-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }

    @Test func todaNotaTemVersoesMenosAExpressiva() {
        // prosa solta, sem método
        #expect(Versoes.valemPara(gesto: nil, fechada: false))
        // a nota de compra do report: uma decisão com os campos preenchidos
        #expect(Versoes.valemPara(gesto: .decisao, fechada: false))
        // método do catálogo e método do autor
        #expect(Versoes.valemPara(gesto: .woop, fechada: false))
        #expect(Versoes.valemPara(gesto: Gesto(rawValue: "cornell"), fechada: false))
        // as únicas de fora, as três caras da expressiva
        #expect(!Versoes.valemPara(gesto: .expressiva, fechada: false))
        #expect(!Versoes.valemPara(gesto: .expressiva, fechada: true))
        #expect(!Versoes.valemPara(gesto: nil, fechada: true))
    }

    /// A regra de mostrar é a MESMA de gravar: o que `valemPara` diz sim,
    /// `registrar` guarda; o que diz não, recusa.
    @Test func mostrarEGravarSeguemAMesmaRegra() {
        Versoes.diretorio = pastaTemp()
        let casos: [(Gesto?, Bool)] = [(nil, false), (.decisao, false), (.woop, false),
                                       (.expressiva, false), (.expressiva, true), (nil, true)]
        for (gesto, fechada) in casos {
            let id = UUID()
            let guardou = Versoes.registrar(id, texto: "comprar a cadeira", campos: ["espero": "sexta"],
                                            gesto: gesto, fechada: fechada)
            #expect(guardou == Versoes.valemPara(gesto: gesto, fechada: fechada))
            #expect(Versoes.listar(id).isEmpty == !guardou)
        }
    }

    /// A nota de compra que a lista cobra (decisão sem data de "espero") é a
    /// mesma nota da linha do mês: a linha da volta não pode ser uma nota com
    /// menos poder do que ela.
    @Test func aNotaDaVoltaEUmaNotaComoAsOutras() {
        let nota = Nota(texto: "Decidi comprar a cadeira usada",
                        gesto: .decisao, campos: ["decidido": "a usada"])
        #expect(Volta.campoDevido(gesto: nota.gesto, campos: nota.campos,
                                  criadaEm: nota.criadaEm, fechado: nota.fechada) != nil)
        #expect(Versoes.valemPara(gesto: nota.gesto, fechada: nota.fechada))
    }
}
