import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct PrivacidadeTrabalhoTests {
    private func exemplo(comOrigem: Bool = true) throws -> (ModelContainer, Nota, Trabalho) {
        let container = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "Frase privada identificável")
        container.mainContext.insert(nota)
        var documento = DocumentoTrabalho(intencao: nota.texto, notaOrigemID: comOrigem ? nota.uuid : nil)
        try documento.guardarVersaoHumana("Artefato preservado com origem")
        let trabalho = try Trabalho(documento: documento)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        return (container, nota, trabalho)
    }

    private func aberturaRestrita(_ trabalho: Trabalho, no context: ModelContext) -> Bool {
        do {
            _ = try OficinaTrabalho(trabalho: trabalho, context: context)
            return false
        } catch OficinaTrabalho.ErroAbertura.acessoRestrito {
            return true
        } catch { return false }
    }

    @Test func origemAbertaPermiteEProtecaoRestringeSemApagarDados() throws {
        for tipo in ["selada", "queimada", "expressiva"] {
            let (container, nota, trabalho) = try exemplo()
            let antes = trabalho.conteudoJSON
            #expect(AcessoTrabalho.permitido(trabalho, no: container.mainContext))
            switch tipo {
            case "selada": nota.trancada = true
            case "queimada": nota.queimada = true
            default: nota.gesto = .expressiva
            }
            try container.mainContext.save()
            #expect(AcessoTrabalho.estado(trabalho, no: container.mainContext) == .restrito(.origemProtegida))
            #expect(aberturaRestrita(trabalho, no: container.mainContext))
            #expect(trabalho.conteudoJSON == antes)
            #expect(try trabalho.ler().notaOrigemID == nota.uuid)
        }
    }

    @Test func origemApagadaRestringeMasTrabalhoIndependenteContinua() throws {
        for temOrigem in [true, false] {
            let (container, nota, trabalho) = try exemplo(comOrigem: temOrigem)
            let antes = trabalho.conteudoJSON
            container.mainContext.delete(nota)
            try container.mainContext.save()
            let estado = AcessoTrabalho.estado(trabalho, no: container.mainContext)
            #expect(estado == (temOrigem ? .restrito(.origemAusente) : .permitido))
            #expect(trabalho.conteudoJSON == antes)
        }
    }

    @Test func metadadoIlegivelRestringeSemSubstituirDocumento() throws {
        let (container, _, trabalho) = try exemplo()
        let invalido = Data("documento não decodificável".utf8)
        trabalho.conteudoJSON = invalido
        #expect(AcessoTrabalho.estado(trabalho, no: container.mainContext) == .restrito(.indisponivel))
        #expect(aberturaRestrita(trabalho, no: container.mainContext))
        #expect(trabalho.conteudoJSON == invalido)
    }

    @Test func protecaoEVerificadaAntesDeDecodificarCorpoDoTrabalho() throws {
        let (container, nota, trabalho) = try exemplo()
        nota.trancada = true
        trabalho.conteudoJSON = try JSONSerialization.data(withJSONObject: [
            "formato": 1, "id": trabalho.uuid.uuidString,
            "notaOrigemID": nota.uuid.uuidString, "intencoes": "corpo inválido",
        ])
        try container.mainContext.save()
        #expect(AcessoTrabalho.estado(trabalho, no: container.mainContext) == .restrito(.origemProtegida))
        #expect(aberturaRestrita(trabalho, no: container.mainContext))
    }

    @Test func oficinaAbertaRevalidaAntesDeAlterarGuardarOuGerar() throws {
        let (container, nota, trabalho) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let antes = trabalho.conteudoJSON
        var chamou = false
        oficina.produzir = { _, _ in
            chamou = true
            return .init(texto: "Não pode aparecer", produtor: "Fixture")
        }
        oficina.estaDisponivel = { true }
        nota.trancada = true
        try container.mainContext.save()
        #expect(!oficina.verificarAcesso())
        #expect(!oficina.alterar { try $0.reverIntencao("Outro texto", resultado: "") })
        #expect(!oficina.guardar())
        #expect(oficina.gerar("Rever conteúdo") == nil)
        #expect(!chamou && trabalho.conteudoJSON == antes)
        #expect(oficina.acesso == .restrito(.origemProtegida))
    }

    @Test func revogarAntesDeIniciarTaskImpedeChamadaAoProvider() async throws {
        let (container, nota, trabalho) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        var chamou = false
        oficina.estaDisponivel = { true }
        oficina.produzir = { _, _ in
            chamou = true
            return .init(texto: "Não pode aparecer", produtor: "Fixture")
        }
        let tarefa = try #require(oficina.gerar("Preparar versão"))
        // Nenhum await: a origem muda antes de a Task ganhar o MainActor.
        nota.trancada = true
        try container.mainContext.save()
        await tarefa.value
        #expect(!chamou)
        #expect(oficina.acesso == .restrito(.origemProtegida))
        #expect(try trabalho.ler().artefatos.count == 1)
    }

    private final class ProdutorSuspenso {
        var retorno: CheckedContinuation<ProducaoTrabalho, Never>?
        var inicio: CheckedContinuation<Void, Never>?

        func produzir(_ documento: DocumentoTrabalho, _ pedido: DocumentoTrabalho.Pedido) async throws -> ProducaoTrabalho {
            await withCheckedContinuation { continuacao in
                retorno = continuacao
                inicio?.resume()
                inicio = nil
            }
        }

        func aguardarInicio() async {
            if retorno != nil { return }
            await withCheckedContinuation { inicio = $0 }
        }

        func responder() {
            retorno?.resume(returning: .init(texto: "Resposta tardia não autorizada", produtor: "Fixture controlada"))
            retorno = nil
        }
    }

    @Test func origemRevogadaDuranteProviderDescartaRespostaEPreservaHistorico() async throws {
        let (container, nota, trabalho) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let produtor = ProdutorSuspenso()
        oficina.estaDisponivel = { true }
        oficina.produzir = produtor.produzir
        let tarefa = try #require(oficina.gerar("Rever proposta"))
        await produtor.aguardarInicio()
        let antes = trabalho.conteudoJSON
        container.mainContext.delete(nota)
        try container.mainContext.save()
        // O provider ignora cancelamento; o guard de retorno ainda tem de valer.
        produtor.responder()
        await tarefa.value
        #expect(oficina.acesso == .restrito(.origemAusente))
        #expect(trabalho.conteudoJSON == antes)
        #expect(try trabalho.ler().artefatos.count == 1)
        #expect(aberturaRestrita(trabalho, no: container.mainContext))
    }

    @Test func restaurarElegibilidadeNaoPerdeHistoriaNemSoltaOrigem() throws {
        let (container, nota, trabalho) = try exemplo()
        let antes = trabalho.conteudoJSON
        nota.trancada = true
        try container.mainContext.save()
        #expect(!AcessoTrabalho.permitido(trabalho, no: container.mainContext))
        // Representa reabertura autorizada pela rota de selo, não a implementa.
        nota.trancada = false
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        #expect(oficina.verificarAcesso())
        #expect(trabalho.conteudoJSON == antes)
        #expect(!oficina.alterar { $0.notaOrigemID = nil })
        #expect(try trabalho.ler().notaOrigemID == nota.uuid)
    }

    @Test func liberarOrigemRestauraErroDeSaveSemPerderAlteracoesPendentes() throws {
        enum Falha: Error { case simulada }
        for falharSave in [false, true] {
            let (container, nota, trabalho) = try exemplo()
            let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
            let antes = trabalho.conteudoJSON
            if falharSave {
                oficina.persistir = { _ in throw Falha.simulada }
                #expect(!oficina.alterar { try $0.reverIntencao("Intenção ainda não guardada", resultado: "") })
                #expect(!oficina.salvo)
            }
            let erroAnterior = oficina.erro
            let documentoAnterior = oficina.documento
            nota.trancada = true
            try container.mainContext.save()
            #expect(!oficina.verificarAcesso())
            #expect(oficina.erro == oficina.acesso.mensagem)
            // Revalidações repetidas não substituem o erro original pelo aviso.
            #expect(!oficina.verificarAcesso())
            #expect(!oficina.guardar())
            nota.trancada = false
            try container.mainContext.save()
            #expect(oficina.verificarAcesso())
            #expect(oficina.erro == erroAnterior)
            #expect(oficina.salvo == !falharSave)
            #expect(oficina.documento.intencaoAtual == documentoAnterior.intencaoAtual)
            #expect(trabalho.conteudoJSON == antes)
            #expect(oficina.verificarAcesso())
            #expect(oficina.erro == erroAnterior)
            if falharSave {
                oficina.persistir = { try $0.save() }
                #expect(oficina.guardar())
                #expect(oficina.salvo && oficina.erro == nil)
                #expect(try trabalho.ler().intencaoAtual.texto == "Intenção ainda não guardada")
            }
        }
    }
}
