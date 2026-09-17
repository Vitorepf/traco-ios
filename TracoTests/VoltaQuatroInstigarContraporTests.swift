import Foundation
import Testing
@testable import Traco

/// E8 volta 4 (líder, 17/09). Instigar: o degrau cobra em verbos, e nenhum sintagma nominal
/// dele volta como molde da pergunta; o critério que a nota já deu não é perguntado; a nota
/// que não diz quando faz pedir o quando. Contrapor: as guardas de número e de tamanho nunca
/// esvaziam o `contra`.
@Suite struct VoltaQuatroInstigarContraporTests {
    /// Os sintagmas nominais de cada degrau, escritos à mão. Precisam continuar na instrução
    /// (a lista não envelhece calada) e não podem voltar nas perguntas da última corrida.
    static let sintagmas: [Int: [String]] = [
        0: [],
        1: ["duas coisas escritas"],
        2: [],
        3: ["essa avaliação"],
        4: ["aquilo de que tudo ali depende"],
    ]

    static let prova = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("prova/e8-instigar-contrapor")

    /// (degrau, pergunta) do BRUTO do instigar numa corrida guardada.
    static func perguntas(_ arquivo: String) throws -> [(Int, String)] {
        let lote = try JSONSerialization.jsonObject(with: Data(contentsOf: prova.appendingPathComponent("lote.json"))) as? [String: Any]
        var degrau: [String: Int] = [:]
        for c in lote?["casos"] as? [[String: Any]] ?? [] {
            degrau[c["id"] as? String ?? ""] = ((c["entrada"] as? [String: Any])?["degrau"] as? Int) ?? 0
        }
        var saida: [(Int, String)] = []
        for linha in try String(contentsOf: prova.appendingPathComponent(arquivo), encoding: .utf8).split(separator: "\n") {
            guard let d = try JSONSerialization.jsonObject(with: Data(linha.utf8)) as? [String: Any],
                  d["evento"] as? String == "casoConcluido", d["operacao"] as? String == "instigar",
                  let bruto = ((d["chamadasGrok"] as? [[String: Any]])?.first?["bruto"] as? String),
                  let ini = bruto.firstIndex(of: "{"), let fim = bruto.lastIndex(of: "}"),
                  let j = try JSONSerialization.jsonObject(with: Data(bruto[ini...fim].utf8)) as? [String: Any]
            else { continue }
            for p in j["perguntas"] as? [String] ?? [] { saida.append((degrau[d["id"] as? String ?? ""] ?? 0, p)) }
        }
        return saida
    }

    @Test func oDegrauCobraEmVerbosENenhumSintagmaVoltaComoMolde() throws {
        for d in 0...4 {
            let instrucao = Degraus.instrucaoDeInstigar(d)
            #expect(instrucao.hasPrefix("Pergunte"), "degrau \(d) começa por nome, não por verbo: \(instrucao)")
            for s in Self.sintagmas[d] ?? [] { #expect(instrucao.contains(s), "degrau \(d): a lista envelheceu — \(s)") }
            for palavra in ["passo", "movimento", "primeiro"] {
                #expect(!Sabia.dobrada(instrucao).contains(palavra), "degrau \(d): \(palavra)")
            }
        }
        // a irmã que acusa: a redação da volta 3 voltou no bruto da volta 3
        let v3 = try Self.perguntas("grok45-volta3.jsonl")
        #expect(v3.contains { $0.0 == 0 && Sabia.dobrada($0.1).contains("primeiro passo") })
        // a última corrida guardada não traz nenhum sintagma do degrau que a pediu
        let ultima = try FileManager.default.contentsOfDirectory(atPath: Self.prova.path)
            .filter { $0.hasPrefix("grok45-volta") && $0.hasSuffix(".jsonl") }
            .max { Int($0.filter(\.isNumber)) ?? 0 < Int($1.filter(\.isNumber)) ?? 0 }
        for (d, p) in try Self.perguntas(try #require(ultima)) {
            for s in Self.sintagmas[d] ?? [] {
                #expect(!Sabia.dobrada(p).contains(Sabia.dobrada(s)), "degrau \(d) voltou como molde: \(p)")
            }
        }
    }

    @Test func oPedidoNaoPerguntaOCriterioDadoEPedeOQuando() {
        #expect(Sabia.sistemaInstigar.contains("Não pergunte pela razão ou pelo critério que a nota já deu"))
        #expect(Sabia.sistemaInstigar.contains("Se a nota não diz quando e não diz que não sabe, uma das perguntas pede QUANDO"))
    }

    /// Medido no bruto v2+v3: tira 6 perguntas, 5 reprovadas por "critério já dado" e 1 aprovada.
    @Test func aGuardaTiraOCriterioQueANotaJaDeu() {
        let comRazao = "Escolhi manter o preço e perder dois clientes pequenos, porque quero proteger a margem e liberar tempo para os grandes."
        let reprovadas = ["Que critério separa proteger a margem de ceder no preço com esses clientes?",
                          "Qual critério separa proteger a margem de ceder no preço nesses casos?"]
        let fica = "O que mostraria que perder os dois pequenos custou mais do que protegeu?"
        #expect(GuardaDeInstigar.filtrar(reprovadas + [fica], texto: comRazao) == [fica])
        // sem razão na nota, perguntar o critério é a pergunta certa (sala × casa: 9 aprovadas)
        let semRazao = "Preciso decidir entre alugar uma sala por R$ 900 por mês ou atender de casa."
        let criterio = "Qual critério concreto separa alugar a sala de atender de casa?"
        #expect(GuardaDeInstigar.filtrar([criterio], texto: semRazao) == [criterio])
    }

    /// Os dois `contra` que as nossas guardas esvaziaram na volta 3 (bruto da `8F8A01A8`).
    @Test func asGuardasDeNumeroEDeTamanhoNuncaEsvaziamOContra() throws {
        let geladeira = "Vou comprar a geladeira à vista por R$ 3.600 em vez de parcelar em 10 vezes de R$ 399, porque à vista sai R$ 390 mais barato. Para pagar, tiro R$ 3.600 dos R$ 5.000 que guardo para emergência e reponho guardando R$ 400 por mês."
        let contraNumero = "A economia de 390 fixa a compra à vista, mas tirar 3600 dos 5000 de emergência deixa a reserva fina até a reposição mensal de 400 terminar; um imprevisto nesse intervalo encontra bem menos folga do que a nota trata como aceitável."
        // "3600" é o "R$ 3.600" da nota: o mesmo número
        #expect(!Sabia.numeroAlheio(contraNumero, texto: geladeira))
        let r1 = try #require(Sabia.parseContraparte(try Self.json(contra: contraNumero), texto: geladeira))
        #expect(r1.contra.hasPrefix("A economia de 390"))
        // número que a nota não deu numa frase só: a frase fica, porque o contra não fica vazio
        let r2 = try #require(Sabia.parseContraparte(try Self.json(contra: "A reserva cai para 1.200 e o imprevisto encontra menos folga."), texto: geladeira))
        #expect(!r2.contra.isEmpty)
        let mudanca = "Vou fazer a mudança por conta própria no último sábado do mês, com uma van alugada por um dia. Não tenho quem me ajude a carregar e o prédio novo não tem elevador: são três andares de escada."
        let longo = "Com van por um dia e três andares de escada, o que sobra aberto é o volume e o ritmo do carregamento: se o que precisa subir não cabe em idas que o corpo e o tempo do aluguel aguentem, a escolha de ir mesmo assim concentra o risco no esforço e no atraso dentro do próprio sábado, sem reabrir frete, ajuda ou adiamento, que a nota já fechou."
        #expect(longo.count > 320)
        let r3 = try #require(Sabia.parseContraparte(try Self.json(contra: longo), texto: mudanca))
        #expect(!r3.contra.isEmpty && r3.contra.count <= 281)
        // a guarda de FATO continua apagando: renda que a nota não deu não volta nem assim
        let r4 = try #require(Sabia.parseContraparte(try Self.json(contra: "O gasto compromete a renda do mês."), texto: mudanca))
        #expect(r4.contra.isEmpty)
    }

    @Test func aConferenciaNumeraAsFrasesComoAGuardaCorta() {
        #expect(Sabia.frasesDoCampo("Primeira frase. Segunda? Terceira") == ["Primeira frase. ", "Segunda? ", "Terceira"])
        #expect(Sabia.sistemaConferirContraponto.contains("Na dúvida, não liste"))
    }

    static func json(contra: String) throws -> String {
        String(decoding: try JSONSerialization.data(withJSONObject: ["fechadas": [String](), "contra": contra, "foraDaLista": "",
                                                                  "dependeDe": "", "outroCampo": ""]), as: UTF8.self)
    }
}
