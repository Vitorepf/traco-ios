import Foundation
import Network
import Testing
@testable import Traco

/// Um servidor que ACEITA a conexão e nunca responde. É o transporte
/// controlado que a Astra pediu no G0: *"não gaste chamada real só para
/// esperar — o aparelho da conta é o recurso mais caro que temos."*
/// Sem ele, provar o comportamento do teto custaria uma janela do `B91C8DEF`.
final class EscutaMuda: @unchecked Sendable {
    private let escuta: NWListener
    let endereco: URL

    init() throws {
        escuta = try NWListener(using: .tcp, on: .any)
        // Aceitar e calar: o pedido fica ocioso, que é exatamente o caso que o
        // `timeoutInterval` conta.
        escuta.newConnectionHandler = { $0.start(queue: .global()) }
        let pronta = DispatchSemaphore(value: 0)
        escuta.stateUpdateHandler = { if case .ready = $0 { pronta.signal() } }
        escuta.start(queue: .global())
        guard pronta.wait(timeout: .now() + 5) == .success,
              let porta = escuta.port?.rawValue,
              let url = URL(string: "http://127.0.0.1:\(porta)/v1/chat/completions") else {
            escuta.cancel()
            throw Erro.naoSubiu
        }
        endereco = url
    }

    enum Erro: Error { case naoSubiu }
    func fechar() { escuta.cancel() }
}

struct GrokContratoTests {
    @Test(arguments: [Grok.modelo])
    func esforcoExplicitoNaoMudaOSchemaENaoAceitaValorInvalido(modelo: String) throws {
        let dados = try #require(Grok.corpo(sistema: "", usuario: "", temperatura: 0.3,
                                           esquema: nil, esforco: "medium", modelo: modelo))
        let corpo = try #require(try JSONSerialization.jsonObject(with: dados) as? [String: Any])
        #expect(corpo["model"] as? String == modelo)
        #expect(corpo["reasoning_effort"] as? String == "medium")
        #expect(Grok.corpo(sistema: "", usuario: "", temperatura: 0, esquema: nil, esforco: "inventado") == nil)
    }

    /// ADR 2026-09-08r. Um teto só para as quatro rotas de Trabalho, e ele é
    /// MEDIDO: com 90 s, 20 de 72 chamadas a `grok-4.6` morriam aos 91 s
    /// (`prepararPratica` 11 de 18); com 240 s, as 30 chamadas das 27 execuções
    /// que carregavam essas 20 falhas voltaram inteiras. A pior execução medida
    /// de ponta a ponta é `qn-produzir-combinar-sem-resolver-a-pratica` em
    /// 178,144 s (duas chamadas), e a chamada isolada mais lenta, 141,058 s.
    ///
    /// São duas guardas distintas, e o G3 pediu as duas separadas:
    /// o PISO OBSERVADO (não descer abaixo do que já medimos chegar) e a
    /// DECISÃO (240 s, com a folga que a ADR 08r escolheu). Baixar o teto para
    /// 181 passaria no piso e mataria a decisão — foi assim que a operação
    /// sumiu da tela sem ninguém notar.
    /// ADR 09n alargou o mesmo teto à sábia: pior caso medido em `responder`
    /// com o modelo escolhido, 77,5 s em 36 execuções — cabe com 3,1× de folga.
    ///
    /// **10/09: o piso passou por cima do teto.** A corrida da Q3-D esperou
    /// **241 s** (`ferramentas/orca/RUMO.md:790`), e o teto era 240: ele cortou
    /// uma resposta que estava a caminho e devolveu ao autor um `semRetorno`
    /// NOSSO. Esta é a guarda que ficou vermelha naquele dia e que teria
    /// impedido o defeito se existisse antes — por isso a espera observada é
    /// uma constante do código (`Grok.esperaObservada`), e não um número
    /// enterrado num relatório que ninguém releu.
    @Test func oTetoCobreAPiorLatenciaMedida() {
        #expect(Grok.teto >= 179,
                "piso: 178,144 s é a pior execução que a medida de 08/09 viu chegar inteira")
        #expect(Grok.teto > 90, "90 s foi o teto que cortou 28 % das chamadas a grok-4.6")
        #expect(Grok.teto > Grok.esperaObservada,
                "teto menor que a espera JÁ OBSERVADA corta resposta boa: 240 < 241 na Q3-D")
        #expect(Grok.teto == 300,
                "decisão da ADR 2026-09-10a: 300 s de margem declarada sobre os 241 s observados. Mudar o valor é mudar a ADR, com medida nova ao lado")
    }

    /// Astra no G0: *"conferir os limites externos — se houver limite de
    /// transporte, de sessão ou do provedor abaixo do nosso, o nosso número é
    /// decorativo."* Este é o limite de TRANSPORTE, e ele é real: a
    /// `URLSessionConfiguration` traz `timeoutIntervalForRequest = 60` de
    /// fábrica. Se ela ganhasse do pedido, `Grok.teto` seria decoração e toda
    /// chamada morreria a 1 minuto.
    ///
    /// A prova é por transporte controlado — um `listener` local que ACEITA e
    /// nunca responde —, com a config em 2 s e o pedido em 6 s. Se o valor do
    /// PEDIDO governa, o erro chega perto dos 6 s; se a config governasse,
    /// chegaria aos 2 s. Sem rede, sem conta, sem chamada real, ~6 s de suíte.
    ///
    /// O outro lado (pedido MAIOR que os 60 s de fábrica) já está provado em
    /// campo: a chamada da Q3-D esperou 241 s e voltou — o que também diz que
    /// o provedor não corta abaixo disso.
    @Test func oTetoDoPedidoGanhaDoTetoDaSessao() async throws {
        let mudo = try EscutaMuda()
        defer { mudo.fechar() }
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 60
        let sessao = URLSession(configuration: config)
        var pedido = URLRequest(url: mudo.endereco)
        pedido.timeoutInterval = 6
        let inicio = Date()
        await #expect(throws: (any Error).self) { try await sessao.data(for: pedido) }
        let gasto = Date().timeIntervalSince(inicio)
        #expect(gasto > 3,
                "morreu em \(gasto) s: a config de 2 s ganhou do pedido, e Grok.teto é decorativo")
        #expect(gasto < 12, "morreu em \(gasto) s — nem o valor do pedido explica")
    }

    @Test func respostaCortadaOuRecusadaNaoViraEntregaCompleta() throws {
        func resposta(_ fim: String, texto: String = "Conteúdo completo", recusa: String? = nil) throws -> Data {
            var mensagem = ["content": texto]
            if let recusa { mensagem["refusal"] = recusa }
            return try JSONSerialization.data(withJSONObject: [
                "choices": [["finish_reason": fim, "message": mensagem]],
            ])
        }
        #expect(try Grok.textoCompleto(resposta("stop")) == "Conteúdo completo")
        for fim in ["length", "content_filter", "tool_calls", "desconhecido"] {
            #expect(try Grok.textoCompleto(resposta(fim)) == nil)
        }
        #expect(try Grok.textoCompleto(resposta("stop", texto: " \n")) == nil)
        #expect(try Grok.textoCompleto(resposta("stop", recusa: "Não posso atender")) == nil)
        #expect(Grok.textoCompleto(Data("{}".utf8)) == nil)
        #expect(try Grok.falhaDoCorpo(resposta("length")) == .limite)
        #expect(try Grok.falhaDoCorpo(resposta("stop", recusa: "Não posso atender")) == .recusa)
        #expect(try Grok.falhaDoCorpo(resposta("content_filter")) == .recusa)
        #expect(Grok.falhaDoCorpo(Data("{}".utf8)) == .transporte)
        #expect(try Grok.falhaDoCorpo(resposta("stop")) == nil)
        #expect(Grok.falhaDoErro(CancellationError()) == .cancelada)
        #expect(Grok.falhaDoErro(URLError(.timedOut)) == .timeout)
        #expect(Grok.falhaDoErro(URLError(.cancelled)) == .cancelada)
        for f in [Grok.FalhaHonesta.timeout, .cancelada, .limite, .recusa] {
            let frase = Grok.frase(f)
            #expect(frase.contains("continua aqui") || frase.contains("Não mostro um pedaço"))
            #expect(!frase.contains("pronto"))
        }
        _ = Grok.retirarFalha()
        Grok.registrarFalha(.timeout)
        #expect(Grok.falhaPendente() == .timeout)
        #expect(Grok.avisoDaFalha().contains("estourou"))
        #expect(Grok.avisoDaFalha().contains("continua aqui"))
        #expect(Grok.falhaPendente() == .timeout, "avisoDaFalha não consome")
        #expect(Grok.retirarFalha() == .timeout)
        #expect(Grok.falhaPendente() == nil)
    }

    /// **A guarda do sétimo conserto da 10b.** O G3 apagou `diagnostico.bruto = msg`
    /// e a suíte INTEIRA ficou verde — 1038 de 1038. Não por descuido de quem
    /// escreveu os testes: o corpo de `Grok.responder` é INALCANÇÁVEL daqui.
    /// `Motores.desligados` é `true` em todo processo de teste, e é ele que
    /// impede a suíte de gastar a assinatura do autor (é função, não defeito).
    /// Havia prova de CORRIDA — 180 de 180 chamadas com `bruto` no JSONL — e
    /// nenhuma prova de ÁRVORE: amanhã a linha some e nada fica vermelho.
    ///
    /// Então guarda-se a FORMA do portão, na janela entre o conteúdo aceito e a
    /// memoização: ali o desfecho completo e o bruto são escritos JUNTOS, ou o
    /// que a sonda mede deixa de ser o modelo e passa a ser o que sobrou do
    /// nosso parser. Fora dessa janela o campo não prova nada — declarado e
    /// nunca escrito é exatamente o defeito.
    ///
    /// **E o vigia prova que enxerga na própria execução:** a mesma regra, sobre
    /// a mesma fonte com a linha removida, tem de REPROVAR. Sem isso um portão
    /// que não achou nada passaria calado, que é o defeito que ele guarda.
    @Test func oPortaoPreservaORetornoBrutoQuandoOConteudoVemCompleto() throws {
        let grok = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Traco/Analise/Grok.swift")
        let fonte = try String(contentsOf: grok, encoding: .utf8)

        // a única saída com conteúdo: do `textoCompleto` aceito até a memoização
        func janela(_ texto: String) throws -> Substring {
            let inicio = try #require(texto.range(of: "let msg = textoCompleto(dados)"),
                                      "o portão mudou de forma: este teste deixou de olhar código")
            let fim = try #require(texto.range(of: "memoGrava(chave, msg)"),
                                   "o portão mudou de forma: este teste deixou de olhar código")
            return texto[inicio.upperBound..<fim.lowerBound]
        }

        let saida = try janela(fonte)
        #expect(saida.contains(#"diagnostico.desfecho = "conteúdo completo""#))
        #expect(saida.contains("diagnostico.bruto = msg"),
                "a saída de conteúdo completo parou de preservar o retorno BRUTO do provedor")

        let mutante = fonte.replacingOccurrences(of: "\n        diagnostico.bruto = msg", with: "")
        #expect(mutante.count < fonte.count, "a mutação não tirou nada: a linha mudou de forma")
        let saidaMutante = try janela(mutante)
        #expect(!saidaMutante.contains("diagnostico.bruto = msg"))
    }

    @Test func schemaVaiNoProtocoloESchemaInvalidoNaoDegradaParaTextoLivre() throws {
        let esquema = #"{"type":"object","properties":{"texto":{"type":"string"}},"required":["texto"],"additionalProperties":false}"#
        let dados = try #require(Grok.corpo(sistema: "Contrato", usuario: "Pedido", temperatura: 0, esquema: esquema))
        let corpo = try #require(try JSONSerialization.jsonObject(with: dados) as? [String: Any])
        let formato = try #require(corpo["response_format"] as? [String: Any])
        #expect(formato["type"] as? String == "json_schema")
        let json = try #require(formato["json_schema"] as? [String: Any])
        #expect(json["strict"] as? Bool == true)
        let schema = try #require(json["schema"] as? [String: Any])
        #expect(schema["required"] as? [String] == ["texto"])
        #expect(Grok.corpo(sistema: "", usuario: "", temperatura: 0, esquema: "quebrado") == nil)
        #expect(Grok.corpo(sistema: "", usuario: "", temperatura: 0, esquema: "[]") == nil)
        let livre = try #require(Grok.corpo(sistema: "", usuario: "", temperatura: 0, esquema: nil))
        let texto = try #require(try JSONSerialization.jsonObject(with: livre) as? [String: Any])
        #expect(texto["response_format"] == nil)
    }
}
