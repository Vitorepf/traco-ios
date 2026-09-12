import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-12a — a tesoura é local. Os textos são os casos cegos
/// de `prova/instigar-cego-casos.json`. O pedido vigente não muda:
/// filtrar o que a nota fechou não pode calar a nota magra.
struct GuardaDeInstigarTests {
    private let fatosNegados =
        "Desisti. Não consigo dizer quando começou, não foi por causa de nada específico, e eu nem sei o que seria dar certo aqui."
    private let magro = "Não deu certo de novo."
    private let jaResponde =
        "Ontem de manhã mandei a proposta com o preço errado: 4.800 onde era 8.400. O cliente respondeu em vinte minutos aceitando. Dar certo, para mim, seria ele aceitar o preço certo sem eu parecer amador. Liguei pedindo desculpa e ele não respondeu mais."
    private let espanhol =
        "Quero começar a praticar espanhol, mas sempre espero ter uma hora livre. Hoje tenho quinze minutos e estou sozinho."

    private func lidas(_ perguntas: [String], texto: String) -> [String]? {
        let json = jsonDe(perguntas)
        return Sabia.parsePerguntas(json, texto: texto)
            .map { GuardaDeInstigar.filtrar($0, texto: texto) }
    }

    private func jsonDe(_ perguntas: [String]) -> String {
        let corpo = perguntas.map { "\"\($0)\"" }.joined(separator: ",")
        return "{\"perguntas\":[\(corpo)]}"
    }

    @Test func fatosNegadosFechaQuandoDarCertoECausaEDeixaOQue() {
        let f = GuardaDeInstigar.fechadas(fatosNegados)
        #expect(f.contains(.quando))
        #expect(f.contains(.darCerto))
        #expect(f.contains(.causa))
        #expect(!f.contains(.que))
    }

    @Test func fatosNegadosDerrubaOGabaritoEGuardaOQue() throws {
        // `parsePerguntas` só entrega 5. As duas que ficam abertas vão
        // nesta lista; o gabarito fechado não pode ocupá-las sozinho.
        let saida = try #require(lidas([
            "Quando começou?",
            "O que seria dar certo?",
            "Qual foi a causa?",
            "Do que você desistiu?",
            "O que faria essa frase deixar de ser verdade?",
        ], texto: fatosNegados))
        #expect(!saida.contains(where: { GuardaDeInstigar.cobra($0, .quando) }))
        #expect(!saida.contains(where: { GuardaDeInstigar.cobra($0, .darCerto) }))
        #expect(!saida.contains(where: { GuardaDeInstigar.cobra($0, .causa) }))
        #expect(saida.contains(where: { $0.contains("desist") }))
        #expect(saida.contains(where: { $0.contains("frase") }))
        #expect(saida.count >= 2)

        let tesoura = GuardaDeInstigar.filtrar([
            "Quando aconteceu?",
            "Que dia foi?",
            "O que seria dar certo?",
            "Qual foi a causa?",
            "Do que você desistiu?",
            "O que faria essa frase deixar de ser verdade?",
        ], texto: fatosNegados)
        #expect(tesoura.count >= 2)
        #expect(tesoura.allSatisfy { !GuardaDeInstigar.cobra($0, .quando) })
    }

    /// O controle que a 2ª redação do pedido quebrou: nota magra sem
    /// fecho. As três pernas entram. Uma tesoura que as cale é o
    /// defeito simétrico do fatos-negados.
    @Test func textoMagroNaoCalaAsTresPernas() throws {
        #expect(GuardaDeInstigar.fechadas(magro).isEmpty)
        let saida = try #require(lidas([
            "O que aconteceu?",
            "Quando aconteceu?",
            "O que seria dar certo?",
        ], texto: magro))
        #expect(saida.count == 3)
        #expect(saida.contains(where: { GuardaDeInstigar.cobra($0, .que) }))
        #expect(saida.contains(where: { GuardaDeInstigar.cobra($0, .quando) }))
        #expect(saida.contains(where: { GuardaDeInstigar.cobra($0, .darCerto) }))
    }

    @Test func notaQueJaRespondeCalaOGabaritoEDeixaMateria() throws {
        let f = GuardaDeInstigar.fechadas(jaResponde)
        #expect(f.contains(.quando))
        #expect(f.contains(.darCerto))
        #expect(f.contains(.que))
        let saida = try #require(lidas([
            "O que aconteceu?",
            "Quando aconteceu?",
            "O que seria dar certo?",
            "O que o aceite dele vale sobre o preço errado?",
            "O que você vai mandar agora?",
        ], texto: jaResponde))
        #expect(!saida.contains(where: { GuardaDeInstigar.cobra($0, .quando) }))
        #expect(!saida.contains(where: { GuardaDeInstigar.cobra($0, .darCerto) }))
        #expect(!saida.contains(where: { $0.contains("O que aconteceu") }))
        #expect(saida.contains(where: { $0.contains("aceite") }))
        #expect(saida.contains(where: { $0.contains("mandar") }))
        #expect(saida.count >= 2)
    }

    @Test func fatoSupostoCaiEPalavraDelaPassa() throws {
        let noFatos = try #require(lidas([
            "Do que você desistiu?",
            "Que projeto você largou?",
            "O que faria essa frase deixar de ser verdade?",
        ], texto: fatosNegados))
        #expect(!noFatos.contains(where: { $0.contains("projeto") }))
        #expect(noFatos.contains(where: { $0.contains("desist") }))
        #expect(noFatos.count >= 2)

        let dela = try #require(lidas([
            "O que o cliente respondeu depois dos vinte minutos?",
            "O que o aceite dele vale sobre o preço errado?",
        ], texto: jaResponde))
        #expect(dela.count == 2)
    }

    /// «Hoje tenho quinze minutos» é disponibilidade, não o quando do
    /// acontecido. Fechar a perna aqui calaria pergunta útil.
    @Test func hojeNaoFechaQuandoDoAcontecido() throws {
        #expect(!GuardaDeInstigar.fechadas(espanhol).contains(.quando))
        let saida = try #require(lidas([
            "Quando você consegue praticar esses quinze minutos?",
            "O que exatamente significa praticar espanhol em quinze minutos?",
        ], texto: espanhol))
        #expect(saida.count == 2)
    }

    @Test func andaimeContinuaCaindoAntesDaTesoura() {
        let json = #"{"perguntas":["Qual é o movimento básico que se pula?","Do que você desistiu?"]}"#
        let soParse = Sabia.parsePerguntas(json, texto: fatosNegados)
        #expect(soParse == ["Do que você desistiu?"])
        #expect(Sabia.perguntasInstigadas(json, texto: fatosNegados)
                == ["Do que você desistiu?"])
    }
}
