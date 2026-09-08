import Foundation
import Testing
@testable import Traco

struct GrokContratoTests {
    @Test(arguments: [Grok.modelo, Grok.modeloTrabalho])
    func esforcoExplicitoNaoMudaOSchemaENaoAceitaValorInvalido(modelo: String) throws {
        let dados = try #require(Grok.corpo(sistema: "", usuario: "", temperatura: 0.3,
                                           esquema: nil, esforco: "medium", modelo: modelo))
        let corpo = try #require(try JSONSerialization.jsonObject(with: dados) as? [String: Any])
        #expect(corpo["model"] as? String == modelo)
        #expect(corpo["reasoning_effort"] as? String == "medium")
        #expect(Grok.corpo(sistema: "", usuario: "", temperatura: 0, esquema: nil, esforco: "inventado") == nil)
    }

    /// ADR 2026-09-08m. Um teto só para as quatro rotas de Trabalho, e ele é
    /// MEDIDO: com 90 s, 20 de 72 chamadas a `grok-4.6` morriam aos 91 s
    /// (`prepararPratica` 11 de 18); com 240 s, as 30 chamadas das 27 execuções
    /// que carregavam essas 20 falhas voltaram inteiras. A pior execução medida
    /// de ponta a ponta é `qn-produzir-combinar-sem-resolver-a-pratica` em
    /// 178,144 s (duas chamadas), e a chamada isolada mais lenta, 141,058 s.
    ///
    /// São duas guardas distintas, e o G3 pediu as duas separadas:
    /// o PISO OBSERVADO (não descer abaixo do que já medimos chegar) e a
    /// DECISÃO (240 s, com a folga que a ADR 08m escolheu). Baixar o teto para
    /// 181 passaria no piso e mataria a decisão — foi assim que a operação
    /// sumiu da tela sem ninguém notar.
    @Test func oTetoDeTrabalhoCobreAPiorLatenciaMedida() {
        #expect(Grok.tetoTrabalho >= 179,
                "piso: 178,144 s é a pior execução que a medida de 08/09 viu chegar inteira")
        #expect(Grok.tetoTrabalho > 90, "90 s foi o teto que cortou 28 % das chamadas a grok-4.6")
        #expect(Grok.tetoTrabalho == 240,
                "decisão da ADR 08m: 240 s. Mudar o valor é mudar a ADR, com medida nova ao lado")
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
