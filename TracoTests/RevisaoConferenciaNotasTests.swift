import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor @Suite(.serialized)
struct RevisaoConferenciaNotasTests {
    @Test func obraOmitidaNaoCalaParteApoiadaPorOutraNota() async throws {
        let obra = FonteNotas(id: UUID(), titulo: "Duna", texto: "Duna\n" + String(repeating: "material longo ", count: 2000), editadaEm: .now)
        let escolha = FonteNotas(id: UUID(), titulo: "Minha escolha", texto: "Tenho 80 reais reservados. Ainda não anotei o preço.", editadaEm: .now)
        let pergunta = "Resuma o livro Duna sobre liderança e diga o que falta na minha anotação para decidir a compra."
        let cru = #"{"base":"notas","texto":"Esta consulta não trouxe o trecho da obra sobre liderança. Sua anotação reserva 80 reais; falta consultar o preço para comparar ao valor reservado.","trechoIDs":["N1T1"]}"#
        var gerou = false, conferiu = false
        let r = try #require(await Sabia.responderNasNotas(pergunta: pergunta, fontes: [obra, escolha],
            gerarRemoto: { pacote in
                gerou = true
                #expect(pacote.omitidas == 1 && pacote.fontes == [escolha])
                return cru
            }, conferirRemoto: { pacote, candidata in
                conferiu = true
                #expect(pacote.fontes == [escolha] && candidata == cru)
                #expect(!pacote.mensagem.contains("material longo"))
                return cru
            }))
        #expect(gerou && conferiu)
        #expect(r.citadas == [escolha] && r.enviadas == [escolha])
        #expect(r.texto.contains("80 reais") && !r.texto.contains("não está no caderno"))
    }

    @Test func referenciaFinalVemDaConferenciaENaoDaCandidata() async throws {
        let compra = FonteNotas(id: UUID(), titulo: "Duna", texto: "Quero comprar Duna", editadaEm: .now)
        let trecho = FonteNotas(id: UUID(), titulo: "Meu trecho", texto: "Uma conclusão exige razão independente, não sua repetição.", editadaEm: .now)
        let ruim = #"{"base":"notas","texto":"O livro recomenda obedecer a líderes.","trechoIDs":["N1T1"]}"#
        let boa = #"{"base":"notas","texto":"Seu argumento repete a conclusão. Qual evidência independente mostra o benefício do serviço?","trechoIDs":["N2T1"]}"#
        var chamadas = 0
        let r = try #require(await Sabia.responderNasNotas(
            pergunta: "Segundo meu trecho, como melhoro um argumento circular?", fontes: [compra, trecho],
            gerarRemoto: { pacote in
                #expect(pacote.fontes == [compra, trecho]); chamadas += 1; return ruim
            }, conferirRemoto: { pacote, candidata in
                #expect(candidata == ruim)
                #expect(pacote.fontes == [compra, trecho])
                #expect(pacote.trechos.last?.id == "N2T1")
                chamadas += 1; return boa
            }))
        #expect(chamadas == 2)
        #expect(r.citadas.map(\.id) == [trecho.id])
        #expect(r.enviadas == [compra, trecho])
        #expect(!r.texto.contains("líderes"))
        #expect(r.texto.contains("Referência: “Meu trecho”"))
        #expect(r.candidato == ruim && r.conferencia == boa)
    }

    @Test func conferenciaInvalidaNaoPublicaNemIniciaFallback() async {
        let f = FonteNotas(id: UUID(), titulo: "Minha compra", texto: "Reservei 80 reais, sem preço anotado.", editadaEm: .now)
        var locais = 0, conferencias = 0
        let r = await Sabia.responderNasNotas(pergunta: "O que falta para comparar a compra ao orçamento?", fontes: [f],
            gerarRemoto: { _ in #"{"base":"notas","texto":"Falta consultar o preço e comparar a 80 reais.","trechoIDs":["N1T1"]}"# },
            gerarLocal: { _ in locais += 1; return nil },
            conferirRemoto: { _, _ in conferencias += 1; return "JSON inválido" },
            conferirLocal: { _, _ in locais += 1; return nil })
        #expect(r == nil)
        #expect(conferencias == 1 && locais == 0)
    }

    @Test func edicaoSemMudarDataESeloDuranteConferenciaDescartam() async throws {
        for selar in [false, true] {
            let c = try ModelContainer.traco(emMemoria: true)
            let n = Nota(texto: "Reservei 80 reais, falta o preço.")
            c.mainContext.insert(n); try c.mainContext.save()
            let f = try #require(Sessao.fonteParaPergunta(n))
            let data = n.editadaEm
            var conferiu = false
            let cru = #"{"base":"notas","texto":"Falta consultar o preço e comparar a 80 reais.","trechoIDs":["N1T1"]}"#
            let r = await Sabia.responderNasNotas(pergunta: "O que falta para decidir a compra?", fontes: [f],
                validarAcesso: { Sessao.dependenciasValidas($0, no: c.mainContext) },
                gerarRemoto: { _ in cru }, conferirRemoto: { _, _ in
                    conferiu = true
                    if selar { n.trancada = true }
                    else { n.texto = "Reservei 20 reais."; n.editadaEm = data }
                    return cru
                })
            #expect(conferiu)
            #expect(r == nil)
            #expect(!Sessao.dependenciasValidas([f], no: c.mainContext))
        }
    }
}
