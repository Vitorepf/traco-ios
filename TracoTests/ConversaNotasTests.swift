import Foundation
import Testing
@testable import Traco

@MainActor
struct ConversaNotasTests {
    /// Não coopera com cancelamento: o teste decide quando cada retorno chega.
    private final class ServicoControlado {
        struct Pedido {
            var pergunta: String
            var anteriores: [Sessao.TrocaNasNotas]
            var retorno: CheckedContinuation<ConversaNotas.Resultado, Never>?
        }

        private(set) var pedidos: [Pedido] = []
        private var aguardando: [(Int, CheckedContinuation<Void, Never>)] = []

        func responder(_ pergunta: String, _ anteriores: [Sessao.TrocaNasNotas]) async -> ConversaNotas.Resultado {
            await withCheckedContinuation { retorno in
                pedidos.append(Pedido(pergunta: pergunta, anteriores: anteriores, retorno: retorno))
                for i in aguardando.indices.reversed() where pedidos.count >= aguardando[i].0 {
                    aguardando.remove(at: i).1.resume()
                }
            }
        }

        func aguardarPedidos(_ quantidade: Int) async {
            if pedidos.count >= quantidade { return }
            await withCheckedContinuation { aguardando.append((quantidade, $0)) }
        }

        func devolver(_ indice: Int, resposta: String?, titulos: [String] = []) {
            let retorno = pedidos[indice].retorno
            pedidos[indice].retorno = nil
            let fontes = titulos.map { FonteNotas(id: UUID(), titulo: $0, texto: $0, editadaEm: .now) }
            retorno?.resume(returning: .init(resposta: resposta, fontes: fontes))
        }
    }

    @Test func fecharImpedeSucessoOuFalhaTardiaDeReabrirCartao() async throws {
        for resposta in [String?.some("resposta antiga"), nil] {
            let conversa = ConversaNotas()
            let servico = ServicoControlado()
            conversa.entrada = "pergunta original"
            let tarefa = try #require(conversa.perguntar(disponivel: true, responder: servico.responder))
            await servico.aguardarPedidos(1)
            conversa.entrada = "busca nova ainda em edição"
            conversa.fechar()
            servico.devolver(0, resposta: resposta, titulos: ["nota antiga"])
            await tarefa.value

            #expect(!conversa.temCartao)
            #expect(conversa.trocas.isEmpty)
            #expect(conversa.fontes.isEmpty)
            #expect(conversa.entrada == "busca nova ainda em edição")
        }
    }

    @Test func retornoAntigoNaoConcluiNovoPedidoNemSubstituiNovaResposta() async throws {
        for antigaPrimeiro in [true, false] {
            let conversa = ConversaNotas()
            let servico = ServicoControlado()
            conversa.entrada = "primeira"
            let antiga = try #require(conversa.perguntar(disponivel: true, responder: servico.responder))
            await servico.aguardarPedidos(1)
            conversa.fechar()
            conversa.entrada = "segunda"
            let nova = try #require(conversa.perguntar(disponivel: true, responder: servico.responder))
            await servico.aguardarPedidos(2)

            if antigaPrimeiro {
                servico.devolver(0, resposta: "antiga", titulos: ["fonte antiga"])
                await antiga.value
                #expect(conversa.pensando)
                #expect(conversa.trocas.isEmpty)
                servico.devolver(1, resposta: "atual", titulos: ["fonte atual"])
                await nova.value
            } else {
                servico.devolver(1, resposta: "atual", titulos: ["fonte atual"])
                await nova.value
                servico.devolver(0, resposta: nil)
                await antiga.value
            }

            #expect(conversa.trocas == [.init(pergunta: "segunda", resposta: "atual")])
            #expect(conversa.fontes.map(\.titulo) == ["fonte atual"])
            #expect(conversa.estado == .ociosa)
            #expect(conversa.perguntaParaRepetir == nil)
        }
    }

    @Test func repetirMantemPerguntaFalhaETextoNovoDigitado() async throws {
        let conversa = ConversaNotas()
        let servico = ServicoControlado()
        let pergunta = "  Qual opção serve?\nConsidere meu orçamento.  "
        conversa.entrada = pergunta
        let primeira = try #require(conversa.perguntar(disponivel: true, responder: servico.responder))
        await servico.aguardarPedidos(1)
        conversa.entrada = "outra busca"
        servico.devolver(0, resposta: nil)
        await primeira.value
        #expect(conversa.perguntaParaRepetir == pergunta)
        #expect(conversa.entrada == "outra busca")

        let repetida = try #require(conversa.repetir(disponivel: true, responder: servico.responder))
        await servico.aguardarPedidos(2)
        #expect(servico.pedidos[1].pergunta == pergunta)
        #expect(servico.pedidos[1].anteriores.isEmpty)
        #expect(conversa.entrada == "outra busca")
        servico.devolver(1, resposta: "resposta conferível")
        await repetida.value
        #expect(conversa.entrada == "outra busca")
        #expect(conversa.trocas == [.init(pergunta: pergunta, resposta: "resposta conferível")])
    }

    @Test func interromperPreservaPedidoParaRetomarSemAceitarRespostaAntiga() async throws {
        let conversa = ConversaNotas()
        let servico = ServicoControlado()
        conversa.entrada = "pedido em voo"
        let antiga = try #require(conversa.perguntar(disponivel: true, responder: servico.responder))
        await servico.aguardarPedidos(1)
        conversa.interromper()
        servico.devolver(0, resposta: "chegou depois de sair")
        await antiga.value
        #expect(conversa.estado == .interrompida("pedido em voo"))
        #expect(conversa.perguntaParaRepetir == "pedido em voo")
        #expect(conversa.trocas.isEmpty)

        let retomada = try #require(conversa.repetir(disponivel: true, responder: servico.responder))
        await servico.aguardarPedidos(2)
        servico.devolver(1, resposta: "retomada")
        await retomada.value
        #expect(conversa.trocas == [.init(pergunta: "pedido em voo", resposta: "retomada")])
    }

    @Test func semModeloNaoEnviaNemApagaBusca() {
        let conversa = ConversaNotas()
        conversa.entrada = "o que busco"
        var chamou = false
        let tarefa = conversa.perguntar(disponivel: false) { _, _ in
            chamou = true
            return .init(resposta: nil)
        }
        #expect(tarefa == nil)
        #expect(!chamou)
        #expect(conversa.semModelo)
        #expect(conversa.entrada == "o que busco")
    }

    @Test func dependenciaViajaComTrocaEHistoricoRevogadoSaiMesmoNaFalha() async throws {
        let conversa = ConversaNotas()
        let fonte = FonteNotas(id: UUID(), titulo: "Proposta", texto: "Prazo 12/09.", editadaEm: .now)
        conversa.entrada = "prazo?"
        let primeira = try #require(conversa.perguntar(disponivel: true) { _, _ in
            .init(resposta: "12/09", fontes: [fonte], dependencias: [fonte])
        })
        await primeira.value
        #expect(conversa.trocas.last?.dependencias == [fonte])
        conversa.entrada = "confirme"
        let segunda = try #require(conversa.perguntar(disponivel: true) { _, anteriores in
            #expect(anteriores.last?.dependencias == [fonte])
            return .init(resposta: nil, conversaValida: [])
        })
        await segunda.value
        #expect(conversa.trocas.isEmpty)
        #expect(conversa.fontes.isEmpty)
        #expect(conversa.estado == .falhou("confirme"))
    }

    @Test func envioDuplicadoNaoIniciaOutraChamadaNemApagaRascunho() async throws {
        let conversa = ConversaNotas()
        let servico = ServicoControlado()
        conversa.entrada = "uma pergunta"
        let tarefa = try #require(conversa.perguntar(disponivel: true, responder: servico.responder))
        await servico.aguardarPedidos(1)
        conversa.entrada = "rascunho seguinte"
        #expect(conversa.perguntar(disponivel: true, responder: servico.responder) == nil)
        #expect(conversa.entrada == "rascunho seguinte")
        servico.devolver(0, resposta: "uma resposta")
        await tarefa.value
        #expect(servico.pedidos.count == 1)
    }
}
