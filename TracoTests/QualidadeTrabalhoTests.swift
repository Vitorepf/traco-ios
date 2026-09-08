import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct QualidadeTrabalhoTests {
    private let exercicio = DocumentoTrabalho.Pratica(
        capacidade: "Apresentar uma proposta", situacao: "Conversa com cliente",
        enunciado: "Escreva a abertura da sua apresentação em duas frases.",
        exemplo: "Para uma biblioteca: Oferecemos empréstimos perto de sua casa.",
        criterios: [.init(texto: "Explicita a proposta."), .init(texto: "Usa duas frases.")])

    @Test func combinarProduzEntregaEPraticaEGuardaAmbasSemMudarAutoria() async throws {
        var d = DocumentoTrabalho(intencao: "Apresentar uma oficina")
        d.apoio = .combinar
        d.trechoExercitado = "A abertura da apresentação"
        let p = try d.iniciarPedido("Prepare o roteiro e me ajude a praticar a abertura.")
        var preparacoes = 0, entregas = 0
        let textoDelegado = "# Roteiro\n[Abertura a ser escrita por você]\nA oficina dura duas horas."
        let r = try await MotorTrabalho.produzir(d, p, contaLigada: true, preparar: { _, _, _ in
            preparacoes += 1
            return (exercicio, "Provedor de exercício controlado")
        }, entregar: { documento, pedido, pratica in
            entregas += 1
            #expect(pratica == exercicio)
            let contexto = MotorTrabalho.pedido(documento, pedido, teto: 18_000, praticaPreservada: pratica)
            #expect(contexto.contains("A abertura da apresentação"))
            #expect(contexto.contains(exercicio.enunciado))
            #expect(contexto.contains("não resolva esse trecho por ela"))
            return .init(texto: textoDelegado, produtor: "Provedor de entrega controlado")
        })
        #expect(preparacoes == 1 && entregas == 1)
        #expect(r.parteDelegada == textoDelegado && r.pratica == exercicio)
        #expect(r.texto.contains(textoDelegado) && r.texto.contains(exercicio.enunciado))
        try d.receber(r.texto, produtor: r.produtor, pedidoID: p.id, pratica: r.pratica, parteDelegada: r.parteDelegada)
        let lido = try JSONDecoder().decode(DocumentoTrabalho.self, from: JSONEncoder().encode(d))
        try lido.validar()
        #expect(lido.versaoAtual?.parteDelegada == textoDelegado)
        #expect(lido.versaoAtual?.pratica == exercicio)
        #expect(lido.versaoAtual?.origem == .ia)
        #expect(lido.pedidos.last?.estado == .pronto && lido.evidencias.isEmpty)
        let arquivo = try IntercambioTrabalho.exportar(d)
        let previa = try IntercambioTrabalho.preparar(arquivo, para: d)
        #expect(previa.texto == r.texto)
        #expect(try !d.aplicarVersaoExterna(previa))
        #expect(d.artefatos.count == 1 && d.versaoAtual?.pratica == exercicio)
        let alterado = arquivo + Data("\nAjuste externo registrado.".utf8)
        #expect(try d.aplicarVersaoExterna(IntercambioTrabalho.preparar(alterado, para: d)))
        #expect(d.artefatos.first?.parteDelegada == textoDelegado)
        #expect(d.artefatos.first?.pratica == exercicio)
        #expect(d.versaoAtual?.origem == .externa)
        #expect(d.versaoAtual?.pratica == nil && d.versaoAtual?.parteDelegada == nil)
    }

    @Test func praticarNaoChamaEntregaECombinarSemTrechoNaoPreparaExercicio() async throws {
        for apoio in [DocumentoTrabalho.Apoio.praticar, .combinar] {
            var d = DocumentoTrabalho(intencao: "Preparar uma apresentação")
            d.apoio = apoio
            let p = try d.iniciarPedido("Ajude na apresentação.")
            var preparacoes = 0, entregas = 0
            let r = try await MotorTrabalho.produzir(d, p, contaLigada: true, preparar: { _, _, _ in
                preparacoes += 1
                return (exercicio, "Exercício controlado")
            }, entregar: { _, _, pratica in
                entregas += 1
                #expect(pratica == nil)
                return .init(texto: "Entrega controlada", produtor: "Provedor controlado")
            })
            #expect(preparacoes == (apoio == .praticar ? 1 : 0))
            #expect(entregas == (apoio == .praticar ? 0 : 1))
            #expect((r.pratica != nil) == (apoio == .praticar))
            #expect(r.parteDelegada == nil)
        }
    }

    @Test func falhaNaParteDelegadaNaoConcluiComApenasExercicio() async throws {
        var d = DocumentoTrabalho(intencao: "Preparar apresentação")
        d.apoio = .combinar
        d.trechoExercitado = "Abertura"
        let c = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: d)
        c.mainContext.insert(trabalho)
        try c.mainContext.save()
        let o = try OficinaTrabalho(trabalho: trabalho, context: c.mainContext)
        o.produzir = { documento, pedido in
            try await MotorTrabalho.produzir(documento, pedido, contaLigada: true, preparar: { _, _, _ in
                (exercicio, "Exercício controlado")
            }, entregar: { _, _, _ in throw MotorTrabalho.Erro.indisponivel })
        }
        let tarefa = try #require(o.gerar("Prepare entrega e exercício."))
        await tarefa.value
        #expect(o.documento.artefatos.isEmpty)
        #expect(o.documento.pedidos.last?.estado == .falhou)
        #expect(try trabalho.ler().pedidos.last?.instrucao == "Prepare entrega e exercício.")
    }

    @Test func mudarTrechoEnquantoIARespondeCancelaPedidoAntigo() async throws {
        var d = DocumentoTrabalho(intencao: "Preparar apresentação")
        d.apoio = .combinar
        d.trechoExercitado = "Abertura"
        let c = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: d)
        c.mainContext.insert(trabalho)
        try c.mainContext.save()
        let o = try OficinaTrabalho(trabalho: trabalho, context: c.mainContext)
        var retorno: CheckedContinuation<(pratica: DocumentoTrabalho.Pratica, produtor: String)?, Never>?
        var entregas = 0
        o.produzir = { documento, pedido in
            try await MotorTrabalho.produzir(documento, pedido, contaLigada: true, preparar: { _, _, _ in
                await withCheckedContinuation { retorno = $0 }
            }, entregar: { _, _, _ in
                entregas += 1
                return .init(texto: "Entrega para a divisão antiga", produtor: "Controlado")
            })
        }
        let tarefa = try #require(o.gerar("Prepare entrega e exercício."))
        while retorno == nil { await Task.yield() }
        #expect(o.alterar { $0.trechoExercitado = "Conclusão" })
        retorno?.resume(returning: (exercicio, "Controlado"))
        await tarefa.value
        #expect(o.documento.artefatos.isEmpty)
        #expect(o.documento.pedidos.last?.estado == .cancelado)
        #expect(entregas == 0)
    }

    @Test func tresBlocosPrecisamTerCincoMinutosCadaNaoApenasSomarQuinze() throws {
        var d = DocumentoTrabalho(intencao: "Ensaiar uma apresentação")
        let p = try d.iniciarPedido("Prepare 3 blocos de 5 minutos.")
        func tempo(_ texto: String) -> DocumentoTrabalho.Resultado? {
            ConferenciaTrabalho.conferir(pedido: p, intencao: d.intencaoAtual, artefato: texto)
                .resultados.first { $0.criterio.hasPrefix("Tempo pedido:") }
        }
        #expect(tempo("Bloco 1: 3 minutos.\nBloco 2: 5 minutos.\nBloco 3: 7 minutos.")?.situacao == .divergencia)
        #expect(tempo("Bloco 1: 5 minutos.\nBloco 2: 5 minutos.\nBloco 3: 5 minutos.")?.situacao == .atendidoNoEscopo)
    }

    @Test func numerosGrandesNaoDerrubamAConferenciaNemSomemDaSoma() throws {
        var d = DocumentoTrabalho(intencao: "Ensaiar")
        let p = try d.iniciarPedido("Prepare \(Int.max) blocos de 5 minutos.")
        #expect(ConferenciaTrabalho.criterios(pedido: p, intencao: d.intencaoAtual).isEmpty)
        var outro = DocumentoTrabalho(intencao: "Ensaiar")
        let pedido = try outro.iniciarPedido("Prepare 3 blocos de 5 minutos.")
        for texto in ["\(Int.max) minutos e 1 minuto.", "999999999999999999999999 minutos. 5 minutos. 5 minutos. 5 minutos."] {
            let r = ConferenciaTrabalho.conferir(pedido: pedido, intencao: outro.intencaoAtual, artefato: texto)
            #expect(r.resultados.first { $0.criterio.hasPrefix("Tempo pedido:") }?.situacao == .inconclusivo)
        }
    }

    @Test func revisaoNaoConfirmaConteudoSemApontarNadaNoArtefato() throws {
        var d = DocumentoTrabalho(intencao: "Preparar uma apresentação")
        let p = try d.iniciarPedido("Inclua dois exemplos.")
        let cru = #"{"criterios":[{"criterio":"Exemplos","trechoFonte":"dois exemplos","fonte":"instrucao","situacao":"atendidoNoEscopo","trechosDoArtefato":[],"justificativa":"Os exemplos atendem."}]}"#
        let r = try #require(RevisaoTrabalho.parse(cru, pedido: p, intencao: d.intencaoAtual, artefato: "Só o título."))
        #expect(r.first?.situacao == .inconclusivo)
    }
}
