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
