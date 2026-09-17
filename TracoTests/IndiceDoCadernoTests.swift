import Foundation
import SwiftData
import Testing
@testable import Traco

/// E6c, braço C (em medida): a Sábia escolhe as candidatas pelo ÍNDICE do caderno inteiro.
@MainActor @Suite(.serialized)
struct IndiceDoCadernoTests {
    @Test func oIndiceTemUmaLinhaPorNotaDoAutorQueSeLe() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let dia = Date(timeIntervalSince1970: 1_789_000_000)
        let nova = Nota(texto: "Compra da geladeira\nFechei à vista. A reserva ficou menor.", editadaEm: dia)
        let antiga = Nota(texto: "Regra do dinheiro\nNada de parcelar compra grande.", editadaEm: dia.addingTimeInterval(-300 * 86_400))
        let selada = Nota(texto: "Selada\nNão entra.", trancada: true, editadaEm: dia)
        let expressiva = Nota(texto: "Desabafo\nNão entra.", gesto: .expressiva, editadaEm: dia)
        let obra = Nota(texto: "## Regra de mestre\nNão entra.", editadaEm: dia)
        obra.origem = .obra
        let bot = Nota(texto: "Pesquisa\nNão entra.", editadaEm: dia)
        bot.origem = .grokbot
        let alvo = Nota(texto: "A nota aberta\nNão entra no próprio índice.", editadaEm: dia)
        for n in [nova, antiga, selada, expressiva, obra, bot, alvo] { ctx.insert(n) }
        try ctx.save()

        let indice = Sessao.indiceDoCaderno(todas: [antiga, selada, expressiva, obra, bot, alvo, nova], exceto: [alvo.uuid])
        #expect(indice.notas.map(\.uuid) == [nova.uuid, antiga.uuid], "só as do autor que se leem, da mais recente")
        let linhas = indice.texto.components(separatedBy: "\n")
        #expect(linhas.count == 2)
        #expect(linhas[0].hasPrefix("[0] Compra da geladeira · ") && linhas[0].hasSuffix(" · Fechei à vista."))
        #expect(linhas[1].hasPrefix("[1] Regra do dinheiro · "))
        for fora in ["Selada", "Desabafo", "Regra de mestre", "Pesquisa", "A nota aberta"] {
            #expect(!indice.texto.contains(fora), "\(fora) não pode entrar no índice")
        }
        // o teto corta pelas mais antigas, e o índice diz quantas cobriu
        let curto = Sessao.indiceDoCaderno(todas: [antiga, nova], exceto: [], teto: linhas[0].count + 1)
        #expect(curto.notas.map(\.uuid) == [nova.uuid])
    }

    /// O gatilho do braço C fica visível: quantas notas abertas do autor a escolha das Notas (30)
    /// e o ecos (40, sem a própria) deixam de ver — o recibo diz o dia em que o corte começa.
    @Test func oCorteDaSelecaoEntraNoRecibo() {
        let abertas = (0..<45).map { Nota(texto: "Nota \($0)\nTexto.") }
        let selada = Nota(texto: "Selada\nTexto.", trancada: true)
        let expressiva = Nota(texto: "Desabafo\nTexto.", gesto: .expressiva)
        let obra = Nota(texto: "## Regra\nTexto.")
        obra.origem = .obra
        #expect(Sessao.cortesDaSelecao(todas: Array(abertas.prefix(22)) + [selada, expressiva, obra]) == (notas: 0, ecos: 0))
        #expect(Sessao.cortesDaSelecao(todas: Array(abertas.prefix(32))) == (notas: 2, ecos: 0))
        #expect(Sessao.cortesDaSelecao(todas: abertas + [selada, expressiva, obra]) == (notas: 15, ecos: 4))
        #expect(Sessao.reciboDoCorte((notas: 2, ecos: 0)) == ["notas do autor: 2 fora da escolha (limite de 30)"])
        #expect(Sessao.reciboDoCorte((notas: 0, ecos: 0)).isEmpty)
    }

    @Test func aEscolhaPeloIndiceLeSoNumerosValidos() {
        #expect(Sabia.parseEscolhaPeloIndice(#"{"notas":[3,0,3,99,-1,1]}"#, total: 5) == [3, 0, 1])
        #expect(Sabia.parseEscolhaPeloIndice(#"{"notas":[]}"#, total: 5) == [])
        #expect(Sabia.parseEscolhaPeloIndice("não sei", total: 5) == nil)
        let muitas = "{\"notas\":[" + (0..<30).map(String.init).joined(separator: ",") + "]}"
        #expect(Sabia.parseEscolhaPeloIndice(muitas, total: 30)?.count == 15)
        #expect(Sabia.sistemaEscolherPeloIndice.contains("de qualquer época e com outras palavras"))
        #expect(Sabia.sistemaEscolherPeloIndice.contains("Coincidência de vocabulário não é vínculo"))
        #expect(Sabia.esquemaEscolherPeloIndice.contains(#""maxItems":15"#))
    }
}
