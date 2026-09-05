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
        #expect(Sabia.mensagemDoAparelho(carga: carga, contexto: "DESCARTÁVEL", teto: carga.count) == carga)
        #expect(Sabia.mensagemDoAparelho(carga: carga, teto: carga.count - 1) == nil)
    }

    @Test func orcamentoRecusadoNaoImpedeTentativaMaior() {
        #expect(Sabia.montarConferir(pontos: ["ponto"], memoria: "memória", teto: 1) == nil)
        #expect(Sabia.montarConferir(pontos: ["ponto"], memoria: "memória", teto: 100) != nil)
    }

    @Test func delimitadoresInvertidosNaoDerrubamOParser() {
        #expect(Sabia.parseVoltaram("} {", pontos: 3) == nil)
    }

    @Test func booleanosNaoSaoIndices() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[true,false]}"#, pontos: 3) == nil)
    }

    @Test func chaveExtraRecusaConferenciaInteira() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[0],"nota":"x"}"#, pontos: 3) == nil)
    }

    @Test func fracaoNaoEIndice() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[1.5]}"#, pontos: 3) == nil)
    }

    @Test func stringNaoEIndice() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":["1"]}"#, pontos: 3) == nil)
    }

    @Test func indicesValidos() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[0,2]}"#, pontos: 3) == [0, 2])
    }

    @Test func indiceForaRecusaTudo() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[0,3]}"#, pontos: 3) == nil)
    }

    @Test func listaVaziaEConferenciaValida() {
        #expect(Sabia.parseVoltaram(#"{"voltaram":[]}"#, pontos: 3) == [])
    }
}
