import Foundation
import SwiftUI
import Testing

@testable import Traco

/// ADR 2026-09-03i — a prova do Recordar.
/// O que se testa aqui é a RECUSA: a pergunta que vaza a resposta e a
/// conferência que inventa um ponto não podem chegar à tela do autor.
@Suite struct ProvaTests {
    let nota = """
        A atenção é um músculo e cansa como músculo.
        Treinar é repetir com espaçamento crescente.
        O celular na mesa custa atenção mesmo desligado.
        """

    // MARK: os pontos saem do autor

    @Test func osPontosSaoAsFrasesDoAutor() {
        let p = Prova.pontos(nota)
        #expect(p.count == 3)
        #expect(p[0].hasPrefix("A atenção é um músculo"))
        #expect(p[2].contains("celular na mesa"))
    }

    @Test func migalhaNaoEPonto() {
        // "ok" e "sim" não são pontos: cobrar migalha vira caça-palavra
        let p = Prova.pontos("ok\nsim\nEsta linha aqui tem tamanho de ponto de verdade.")
        #expect(p.count == 1)
    }

    /// Alvo de uma linha curta (a Palavra, o Então): o alvo inteiro é o ponto —
    /// senão a prova ficaria sem nada a conferir justo onde é mais simples.
    @Test func alvoCurtoViraUmPontoSo() {
        #expect(Prova.pontos("saudade") == ["saudade"])
    }

    @Test func oTetoSegura() {
        let longo = (1...20).map { "Esta é a frase número \($0) do texto." }.joined(separator: "\n")
        #expect(Prova.pontos(longo, teto: 8).count == 8)
    }

    // MARK: a pergunta não pode entregar a resposta

    @Test func quatroPalavrasSeguidasDoAlvoEVazamento() {
        #expect(Prova.vaza("Por que a atenção é um músculo?", alvo: nota))
        // e o acento e a pontuação não salvam a citação
        #expect(Prova.vaza("E o “treinar é repetir com” espaçamento?", alvo: nota))
    }

    @Test func perguntaQueApontaSemCitarPassa() {
        #expect(!Prova.vaza("O que a nota compara com uma parte do corpo?", alvo: nota))
        #expect(!Prova.vaza("O que estava sobre a mesa e cobrava um preço?", alvo: nota))
    }

    /// Alvo curto: a pergunta não pode conter o alvo, ponto. Três palavras não
    /// formam um 4-grama, e sem esta regra "Qual é a palavra? Saudade" passava.
    @Test func alvoCurtoNaoPodeAparecerNaPergunta() {
        #expect(Prova.vaza("Qual palavra descreve saudade?", alvo: "saudade"))
        #expect(!Prova.vaza("Qual palavra você guardou?", alvo: "saudade"))
        #expect(Prova.vaza("Você faz o quê: sai para caminhar?", alvo: "sai para caminhar"))
    }

    @Test func alvoVazioNaoVazaNada() {
        #expect(!Prova.vaza("Qualquer pergunta?", alvo: ""))
    }

    // MARK: o parser da pergunta

    @Test func aPerguntaPrecisaSerPerguntaEcaber() {
        let alvo = nota
        #expect(Sabia.parsePerguntaDeRecordar(#"{"pergunta":"O que a nota compara com o corpo?"}"#,
                                              alvo: alvo) != nil)
        // sem "?" é conclusão disfarçada
        #expect(Sabia.parsePerguntaDeRecordar(#"{"pergunta":"A nota fala de atenção."}"#, alvo: alvo) == nil)
        // vazia é o silêncio que o próprio contrato pede
        #expect(Sabia.parsePerguntaDeRecordar(#"{"pergunta":""}"#, alvo: alvo) == nil)
        // sem JSON, nada
        #expect(Sabia.parsePerguntaDeRecordar("claro! aqui está: O que era?", alvo: alvo) == nil)
    }

    @Test func aPerguntaQueVazaEeRecusadaPeloParser() {
        #expect(Sabia.parsePerguntaDeRecordar(#"{"pergunta":"Por que a atenção é um músculo?"}"#,
                                              alvo: nota) == nil)
    }

    // MARK: o parser da conferência — só números, e só os que existem

    @Test func aConferenciaAceitaIndicesValidos() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[0,2]}"#, pontos: 3) == [0, 2])
        #expect(Sabia.parseVoltaram(#"{"voltaram":[]}"#, pontos: 3) == [])
    }

    /// Índice inventado derruba a conferência INTEIRA: meia conferência mentiria
    /// sobre o que não voltou, e o autor leria uma falta que não houve.
    @Test func indiceInventadoDerrubaTudo() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[0,9]}"#, pontos: 3) == nil)
        #expect(Sabia.parseVoltaram(#"{"voltaram":[-1]}"#, pontos: 3) == nil)
        #expect(Sabia.parseVoltaram(#"{"voltaram":["um"]}"#, pontos: 3) == nil)
        #expect(Sabia.parseVoltaram(#"{"voltaram":[0],"nota":"muito bem!"}"#, pontos: 0) == nil)
    }

    @Test func textoLivreNoLugarDoJsonNaoPassa() {
        #expect(Sabia.parseVoltaram("você lembrou de quase tudo, parabéns", pontos: 3) == nil)
    }
}

/// ADR 2026-09-03j — o eco. A rede do caderno só existia onde o autor digitou
/// `[[…]]`; agora a sábia aponta candidatos. O que se testa é a PROVA: sem
/// citação literal verificável, o eco não chega à tela.
@Suite struct EcoTests {
    let candidatas = [
        "Atenção é um músculo :: treina com repetição espaçada e cansa como músculo",
        "Celular na mesa :: mesmo desligado ele custa um pedaço do que sobra",
        "Lista do mercado :: arroz, feijão, café",
    ]

    @Test func oEcoComCitacaoLiteralPassa() {
        let r = Sabia.parseEcos(#"{"ecos":[{"i":1,"trecho":"mesmo desligado ele custa"}]}"#,
                                candidatas: candidatas)
        #expect(r?.count == 1)
        #expect(r?.first?.i == 1)
    }

    /// A citação inventada é o modo de falha que importa: sem esta guarda, a
    /// tela mostraria um trecho que o autor nunca escreveu, entre aspas.
    @Test func aCitacaoInventadaEDescartada() {
        #expect(Sabia.parseEcos(#"{"ecos":[{"i":0,"trecho":"a atenção é finita e sagrada"}]}"#,
                                candidatas: candidatas)?.isEmpty == true)
    }

    @Test func indiceForaDoIntervaloNaoEntra() {
        #expect(Sabia.parseEcos(#"{"ecos":[{"i":9,"trecho":"arroz, feijão"}]}"#,
                                candidatas: candidatas)?.isEmpty == true)
        #expect(Sabia.parseEcos(#"{"ecos":[{"i":-1,"trecho":"arroz, feijão"}]}"#,
                                candidatas: candidatas)?.isEmpty == true)
    }

    /// Trecho curto não é prova de leitura: "de" aparece em quase tudo.
    @Test func trechoCurtoDemaisNaoEProva() {
        #expect(Sabia.parseEcos(#"{"ecos":[{"i":0,"trecho":"treina"}]}"#,
                                candidatas: candidatas)?.isEmpty == true)
    }

    @Test func aMesmaNotaNaoEcoaDuasVezes() {
        let r = Sabia.parseEcos("""
            {"ecos":[{"i":0,"trecho":"repetição espaçada"},{"i":0,"trecho":"cansa como músculo"}]}
            """, candidatas: candidatas)
        #expect(r?.count == 1)
    }

    @Test func tetoDeTres() {
        let muitas = (0..<6).map { "Nota \($0) :: um corpo de texto suficientemente longo aqui" }
        let itens = (0..<6).map { #"{"i":\#($0),"trecho":"corpo de texto suficientemente"}"# }
        let r = Sabia.parseEcos("{\"ecos\":[\(itens.joined(separator: ","))]}", candidatas: muitas)
        #expect(r?.count == 3)
    }

    @Test func semJsonNaoHaEco() {
        #expect(Sabia.parseEcos("achei duas notas parecidas!", candidatas: candidatas) == nil)
        #expect(Sabia.parseEcos(#"{"ecos":[]}"#, candidatas: candidatas)?.isEmpty == true)
    }
}

/// O eco de uma nota curta: o título já é a frase, e a citação repetia. A
/// prova só entra na tela quando acrescenta (visto na 1ª chamada real, 03/set).
@Suite struct EcoSemRepeticaoTests {
    @Test func aCitacaoContidaNoTituloEredundante() {
        let titulo = "Foco e um recurso que acaba. Cada interrupcao cobra um pedaco."
        #expect(Prova.normal(titulo).contains(Prova.normal("Foco e um recurso que acaba")))
        // acento e pontuação não salvam a repetição
        #expect(Prova.normal("Atenção é um músculo").contains(Prova.normal("atencao e um musculo")))
    }

    @Test func aCitacaoDeOutraParteAcrescenta() {
        let titulo = "Foco e um recurso que acaba"
        #expect(!Prova.normal(titulo).contains(Prova.normal("cobra um pedaco que nao volta")))
    }
}

/// Volta 19 — a regra de layout do revelar, testada fora da tela.
///
/// A auditoria V9 deu 5 em Acessibilidade ao Recordar. A causa era uma medida
/// em pontos decidindo sozinha se a comparação cabe em duas colunas: em AX5
/// cada coluna ficava com ~150 pt, o SwiftUI hifenizava em vez de encolher e a
/// nota saía cortada no meio de uma letra. A lição da F4 é esta: o teto vira
/// regra nomeada e testada, não um `if` escondido no meio do `body`.
@Suite struct RecordarLadoALadoTests {
    @Test func aFolhaLargaEmCorpoNormalComparaLadoALado() {
        #expect(RecordarView.comparaLadoALado(largura: 393, tamanho: .large))
        #expect(RecordarView.comparaLadoALado(largura: 360, tamanho: .xxxLarge))
    }

    @Test func aFolhaEstreitaEmpilha() {
        #expect(!RecordarView.comparaLadoALado(largura: 359, tamanho: .large))
    }

    @Test func corpoDeAcessibilidadeEmpilhaEmQualquerLargura() {
        // é o defeito que esta volta fecha: duas colunas de ~150 pt em AX5
        // hifenizam "obstá-culo" e cortam a nota
        for tamanho in [DynamicTypeSize.accessibility1, .accessibility3, .accessibility5] {
            #expect(!RecordarView.comparaLadoALado(largura: 440, tamanho: tamanho))
        }
    }
}
