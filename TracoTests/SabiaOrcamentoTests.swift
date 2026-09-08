import Testing

@testable import Traco

@Suite struct SabiaOrcamentoTests {
    @Test func perguntaInteiraComContextoLongo() throws {
        let pergunta = "Qual critério decide entre as opções?"
        let mensagem = try #require(Sabia.montarResponder(pergunta: pergunta,
            contexto: String(repeating: "c", count: 6000), retrato: "RETRATO"))
        #expect(mensagem.count <= 3500)
        #expect(mensagem.contains(pergunta))
        #expect(mensagem.contains("Responda só à pergunta"))
        #expect(!mensagem.contains("RETRATO"))
    }

    @Test func perguntaQueNaoCabeRecusa() {
        #expect(Sabia.montarResponder(pergunta: String(repeating: "?", count: 3501), contexto: "") == nil)
    }

    @Test func conferenciaLongaNaoJulgaSemMemoria() {
        let pontos = (0..<9).map { "ponto \($0) " + String(repeating: "p", count: 400) }
        let mensagem = Sabia.montarConferir(pontos: pontos, memoria: String(repeating: "m", count: 4000))
        // A política desta volta preserva toda a evidência: recusa o orçamento insuficiente.
        #expect(mensagem == nil)
    }

    @Test func conferenciaCurtaPreservaTodosOsIndicesEMemoria() throws {
        let pontos = (0..<9).map { "ponto \($0)" }
        let mensagem = try #require(Sabia.montarConferir(pontos: pontos, memoria: "Eu recordo isto."))
        for i in pontos.indices { #expect(mensagem.contains("[\(i)] \(pontos[i])")) }
        #expect(mensagem.hasSuffix("DE MEMÓRIA:\nEu recordo isto."))
        #expect(mensagem.count <= 3500)
    }

    /// A guarda vale nos dois caminhos: sem evidência inteira, nenhum veredito.
    @Test func conferirCalaComEvidenciaCortada() async {
        #expect(await Sabia.conferir(pontos: ["ponto"],
            memoria: String(repeating: "m", count: 4001), gesto: .decisao) == nil)
        #expect(await Sabia.conferir(pontos: [String(repeating: "p", count: 401)],
            memoria: "recordo isto", gesto: .decisao) == nil)
        // No limite, o que cabe continua montando.
        #expect(Sabia.montarConferir(pontos: [String(repeating: "p", count: 400)],
            memoria: String(repeating: "m", count: 4000), teto: 5000) != nil)
    }

    @Test func conferenciaRecusaMemoriaVazia() {
        #expect(Sabia.montarConferir(pontos: ["ponto"], memoria: " \n ") == nil)
    }

    @Test func conferenciaRecusaPontosVazios() {
        #expect(Sabia.montarConferir(pontos: [], memoria: "memória") == nil)
    }

    @Test func cargaInteiraNoLimiteSacrificaContexto() {
        let carga = "DEGRAU: 2\n\nNOTA:\nAté o último caractere 🧠"
        let secao = Sabia.Secao(rotulo: "PISTA:", corpo: "DESCARTÁVEL")
        #expect(Sabia.mensagemDoAparelho(carga: carga, secoes: [secao], teto: carga.count) == carga)
        #expect(Sabia.mensagemDoAparelho(carga: carga, teto: carga.count - 1) == nil)
    }

    /// ADR 05o: rótulo sem conteúdo é ruído que o aparelho paga.
    @Test func rotuloNaoViajaSemConteudo() throws {
        let carga = "NOTA:\numa nota"
        #expect(Sabia.mensagemDoAparelho(carga: carga, secoes: [Sabia.Secao(rotulo: "PISTA:", corpo: " \n ")]) == carga)
        // nem pela metade: a seção que não cabe sai inteira, com o rótulo
        let apertado = try #require(Sabia.mensagemDoAparelho(
            carga: carga, secoes: [Sabia.Secao(rotulo: "PISTA:", corpo: "cabe mal")], teto: carga.count + 8))
        #expect(!apertado.contains("PISTA:"))
    }

    @Test func instigarNaoMandaCabecalhoDeMetodoVazio() throws {
        let semMetodo = try #require(Sabia.montarInstigar(texto: "rascunho", gesto: nil, degrau: 1, retrato: "RETRATO"))
        #expect(!semMetodo.contains("O MÉTODO"))
        #expect(semMetodo.contains("DEGRAU 1"))
        #expect(semMetodo.contains("O RASCUNHO:\nrascunho"))
        #expect(semMetodo.contains("RETRATO"))
        let comMetodo = try #require(Sabia.montarInstigar(texto: "rascunho", gesto: .woop))
        #expect(comMetodo.contains("O MÉTODO desta forma, que as perguntas devem cobrar:\n\(Gesto.woop.metodo)"))
        // o rascunho é carga: não cabe, não vai — e o método some antes do teto
        #expect(Sabia.montarInstigar(texto: String(repeating: "r", count: 3501), gesto: .woop) == nil)
        let apertado = try #require(Sabia.montarInstigar(texto: String(repeating: "r", count: 3300),
                                                         gesto: .woop, retrato: "RETRATO"))
        #expect(!apertado.contains("O MÉTODO") && !apertado.contains("RETRATO"))
        #expect(apertado.count <= 3500)
    }

    @Test func contraporNaoMandaCabecalhoDeMetodoVazio() throws {
        let semMetodo = try #require(Sabia.montarContrapor(texto: "a nota", gesto: nil))
        #expect(!semMetodo.contains("O MÉTODO"))
        #expect(semMetodo.contains("A NOTA:\na nota"))
        let comMetodo = try #require(Sabia.montarContrapor(texto: "a nota", gesto: .decisao, retrato: "RETRATO"))
        #expect(comMetodo.contains("O MÉTODO desta forma:\n\(Gesto.decisao.metodo)"))
        #expect(comMetodo.contains("SOBRE QUEM ESCREVE"))
    }

    @Test func provaNaoMandaCabecalhoDePistaVazia() throws {
        let semPista = try #require(Sabia.montarRecordar(alvo: "o miolo da nota", pista: "  ", degrau: 2))
        #expect(!semPista.contains("PISTA"))
        #expect(semPista.hasPrefix("DEGRAU: 2\n\nNOTA:\no miolo da nota"))
        let comPista = try #require(Sabia.montarRecordar(alvo: "o miolo da nota", pista: "primeira linha",
                                                         retrato: "RETRATO"))
        #expect(comPista.contains("PISTA JÁ VISÍVEL (não repita):\nprimeira linha"))
        // o alvo é carga: alvo que não cabe cala, em vez de virar pergunta sobre meia nota
        #expect(Sabia.montarRecordar(alvo: String(repeating: "a", count: 3500), pista: "") == nil)
    }

    /// ADR 05o: ecos sobre uma candidata só não é rede — é gasto sem escolha.
    @Test func ecosPedeCandidatasInteirasOuCala() throws {
        let candidatas = ["a primeira outra nota", "a segunda outra nota", "a terceira outra nota"]
        let mensagem = try #require(Sabia.montarEcos(nota: "a nota alvo", candidatas: candidatas))
        for i in candidatas.indices { #expect(mensagem.contains("[\(i)] \(candidatas[i])")) }
        // nota longa: o que sobra não dá duas candidatas inteiras → silêncio, não chamada vazia
        #expect(Sabia.montarEcos(nota: String(repeating: "n", count: 3450), candidatas: candidatas) == nil)
        #expect(Sabia.montarEcos(nota: "a nota alvo", candidatas: ["só uma"]) == nil)
        // e o corte é por candidata inteira, nunca pela metade
        let duas = try #require(Sabia.montarEcos(nota: "a nota alvo",
                                                 candidatas: candidatas + [String(repeating: "c", count: 4000)]))
        #expect(duas.contains("[2] \(candidatas[2])") && !duas.contains("[3]"))
    }

    /// A fronteira da IA (ADR o) é carga: a proibição de reescrever a nota
    /// viaja junto com a nota, no aparelho como no remoto.
    @Test func responderLocalMantemANotaSobRotulo() throws {
        let mensagem = try #require(Sabia.montarResponder(pergunta: "e daqui?", contexto: "a nota do autor",
                                                          rotulo: Sabia.rotuloContextoDaNota))
        #expect(mensagem.contains("não a reescreva"))
        #expect(mensagem.contains("\(Sabia.rotuloContextoDaNota)\na nota do autor"))
    }

    @Test func orcamentoRecusadoNaoImpedeTentativaMaior() {
        #expect(Sabia.montarConferir(pontos: ["ponto"], memoria: "memória", teto: 1) == nil)
        #expect(Sabia.montarConferir(pontos: ["ponto"], memoria: "memória", teto: 100) != nil)
    }

    @Test func delimitadoresInvertidosNaoDerrubamOParser() {
        #expect(Sabia.parseVoltaram("} {", pontos: 3) == nil)
    }

    @Test func booleanosNaoSaoJulgamentos() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":true}"#, pontos: 1) == nil)
    }

    @Test func chaveExtraRecusaConferenciaInteira() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":"equivalente","nota":"x"}"#, pontos: 1) == nil)
    }

    @Test func fracaoNaoEJulgamento() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":1.5}"#, pontos: 1) == nil)
    }

    @Test func numeroEmStringNaoEJulgamento() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":"1"}"#, pontos: 1) == nil)
    }

    @Test func julgamentosValidosViramIndices() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":"equivalente","ponto_1":"parcial","ponto_2":"equivalente"}"#, pontos: 3) == [0, 2])
    }

    @Test func indiceForaRecusaTudo() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":"equivalente","ponto_3":"ausente"}"#, pontos: 2) == nil)
    }

    @Test func nenhumEquivalenteEConferenciaValida() {
        #expect(Sabia.parseVoltaram(#"{"ponto_0":"contradicao","ponto_1":"ausente","ponto_2":"incerto"}"#, pontos: 3) == [])
    }
}
