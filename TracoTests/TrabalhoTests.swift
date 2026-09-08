import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct TrabalhoTests {
    enum Falha: Error { case disco, produtor }

    /// Retornos controlados, inclusive depois de cancelar: não usa rede nem relógio.
    private final class ProdutorControlado {
        struct Chamada {
            var documento: DocumentoTrabalho
            var pedido: DocumentoTrabalho.Pedido
            var retorno: CheckedContinuation<Result<ProducaoTrabalho, Falha>, Never>?
        }
        private(set) var chamadas: [Chamada] = []
        private var esperando: [(Int, CheckedContinuation<Void, Never>)] = []

        func produzir(_ documento: DocumentoTrabalho, _ pedido: DocumentoTrabalho.Pedido) async throws -> ProducaoTrabalho {
            let resultado: Result<ProducaoTrabalho, Falha> = await withCheckedContinuation { retorno in
                chamadas.append(.init(documento: documento, pedido: pedido, retorno: retorno))
                for i in esperando.indices.reversed() where chamadas.count >= esperando[i].0 {
                    esperando.remove(at: i).1.resume()
                }
            }
            return try resultado.get()
        }

        func aguardar(_ quantidade: Int) async {
            if chamadas.count >= quantidade { return }
            await withCheckedContinuation { esperando.append((quantidade, $0)) }
        }

        func devolver(_ indice: Int, texto: String) {
            concluir(indice, com: .success(.init(texto: texto, produtor: "Fake controlado, só para teste")))
        }

        func falhar(_ indice: Int) { concluir(indice, com: .failure(.produtor)) }

        private func concluir(_ indice: Int, com resultado: Result<ProducaoTrabalho, Falha>) {
            let retorno = chamadas[indice].retorno
            chamadas[indice].retorno = nil
            retorno?.resume(returning: resultado)
        }
    }

    private func criarOficina(_ documento: DocumentoTrabalho) throws -> (ModelContainer, OficinaTrabalho) {
        let container = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: documento)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        return (container, try OficinaTrabalho(trabalho: trabalho, context: container.mainContext))
    }

    @Test func evidenciaNovaCancelaProducaoQueAindaNaoALeu() async throws {
        var original = DocumentoTrabalho(intencao: "Comparar uma oferta")
        try original.guardarVersaoHumana("Versão apresentada ao cliente")
        try original.prepararAcao("Apresentar a oferta")
        let acao = try #require(original.acoes.first)
        let (_, oficina) = try criarOficina(original)
        let produtor = ProdutorControlado()
        oficina.produzir = produtor.produzir
        oficina.estaDisponivel = { true }
        let tarefa = try #require(oficina.gerar("Prepare uma revisão"))
        await produtor.aguardar(1)
        #expect(oficina.alterar { try $0.registrarRelato("O cliente pediu mais clareza no prazo", acaoID: acao.id) })
        let evidencias = oficina.documento.evidencias
        produtor.devolver(0, texto: "Versão revista")
        await tarefa.value

        #expect(oficina.documento.evidencias == evidencias)
        #expect(oficina.documento.artefatos.first == original.artefatos.first)
        #expect(oficina.documento.versaoAtual == original.versaoAtual)
        #expect(oficina.documento.pedidos.last?.estado == .cancelado)
        #expect(oficina.documento.evidencias.first?.artefatoID == original.versaoAtual?.id)
        #expect(try oficina.trabalho.ler() == oficina.documento)
    }

    @Test func pedidoCanceladoNaoContaminaNovoPedidoEmNenhumaOrdem() async throws {
        for antigaPrimeiro in [true, false] {
            let (_, oficina) = try criarOficina(DocumentoTrabalho(intencao: "Criar uma oferta"))
            let produtor = ProdutorControlado()
            oficina.produzir = produtor.produzir
            oficina.estaDisponivel = { true }
            let antiga = try #require(oficina.gerar("Primeiro pedido"))
            await produtor.aguardar(1)
            oficina.cancelar()
            let nova = try #require(oficina.gerar("Pedido atual"))
            await produtor.aguardar(2)
            let atualID = try #require(oficina.documento.pedidoAtivo).id
            if antigaPrimeiro {
                produtor.devolver(0, texto: "Entrega antiga")
                await antiga.value
                #expect(oficina.documento.pedidoAtivo?.id == atualID)
                #expect(oficina.documento.artefatos.isEmpty)
                produtor.devolver(1, texto: "Entrega atual")
                await nova.value
            } else {
                produtor.devolver(1, texto: "Entrega atual")
                await nova.value
                produtor.falhar(0)
                await antiga.value
            }
            #expect(oficina.documento.artefatos.map(\.conteudo) == ["Entrega atual"])
            #expect(oficina.documento.pedidos.first?.estado == .cancelado)
            #expect(oficina.documento.pedidos.last?.estado == .pronto)
            #expect(oficina.erro == nil)
        }
    }

    @Test func editarIntencaoOuVersaoDuranteEsperaRecusaEntregaObsoleta() async throws {
        for editarIntencao in [true, false] {
            var original = DocumentoTrabalho(intencao: "Intenção anterior")
            try original.guardarVersaoHumana("Versão anterior")
            let (_, oficina) = try criarOficina(original)
            let produtor = ProdutorControlado()
            oficina.produzir = produtor.produzir
            oficina.estaDisponivel = { true }
            let tarefa = try #require(oficina.gerar("Revisar material"))
            await produtor.aguardar(1)
            if editarIntencao {
                #expect(oficina.alterar { try $0.reverIntencao("Mudou a intenção", resultado: "Outra finalidade") })
            } else {
                #expect(oficina.alterar { try $0.guardarVersaoHumana("Meu texto escrito durante a espera") })
            }
            let revisado = oficina.documento
            produtor.devolver(0, texto: "Texto antigo que não pode substituir a revisão")
            await tarefa.value
            #expect(oficina.documento == revisado)
            #expect(try oficina.trabalho.ler() == revisado)
        }
    }

    @Test func recusaAoIniciarProducaoPermiteRepetirSemPedidoPreso() async throws {
        let (_, oficina) = try criarOficina(DocumentoTrabalho(intencao: "Não perder pedido"))
        let produtor = ProdutorControlado()
        oficina.produzir = produtor.produzir
        oficina.estaDisponivel = { true }
        oficina.persistir = { _ in throw Falha.disco }
        #expect(oficina.gerar("Instrução que precisa sobreviver") == nil)
        #expect(!oficina.salvo)
        #expect(oficina.documento.pedidoAtivo == nil)
        #expect(oficina.documento.pedidos.last?.instrucao == "Instrução que precisa sobreviver")
        #expect(produtor.chamadas.isEmpty)

        oficina.persistir = { try $0.save() }
        let tentativa = try #require(oficina.gerar("Instrução que precisa sobreviver"))
        await produtor.aguardar(1)
        produtor.devolver(0, texto: "Material recuperado")
        await tentativa.value
        #expect(oficina.salvo)
        #expect(oficina.documento.artefatos.map(\.conteudo) == ["Material recuperado"])
    }

    @Test func recusaAoGuardarEntregaMantemMaterialParaSalvarSemGerarDeNovo() async throws {
        let (_, oficina) = try criarOficina(DocumentoTrabalho(intencao: "Conservar entrega"))
        let produtor = ProdutorControlado()
        oficina.produzir = produtor.produzir
        oficina.estaDisponivel = { true }
        let tarefa = try #require(oficina.gerar("Criar a versão delegada"))
        await produtor.aguardar(1)
        oficina.persistir = { _ in throw Falha.disco }
        produtor.devolver(0, texto: "Entrega que o disco recusou")
        await tarefa.value
        #expect(!oficina.salvo)
        #expect(oficina.documento.versaoAtual?.conteudo == "Entrega que o disco recusou")
        #expect(try oficina.trabalho.ler().artefatos.isEmpty)
        oficina.persistir = { try $0.save() }
        #expect(oficina.guardar())
        #expect(try oficina.trabalho.ler() == oficina.documento)
        #expect(produtor.chamadas.count == 1)
    }

    @Test func revisaoPreservaMaterialAvaliadoEAcaoNaoMudaDeVersao() throws {
        var documento = DocumentoTrabalho(intencao: "Testar uma oferta", resultado: "Observar resposta de um cliente")
        try documento.guardarVersaoHumana("Oferta inicial, escrita por mim")
        let primeira = try #require(documento.versaoAtual)
        try documento.prepararAcao("Apresentar a primeira oferta")
        let acao = try #require(documento.acoes.first)
        try documento.agendar(acao.id, para: Date(timeIntervalSince1970: 0))
        #expect(documento.acoes[0].estado == .pendente)
        #expect(documento.acoes[0].executadaEm == nil)
        #expect(documento.evidencias.isEmpty)

        let pedido = try documento.iniciarPedido("Proponha uma segunda redação")
        try documento.receber("Segunda oferta produzida pelo provedor de teste", produtor: "Provedor de teste", pedidoID: pedido.id)
        let segunda = try #require(documento.versaoAtual)
        try documento.registrarRelato("Apresentei a primeira oferta; ainda não recebi retorno", acaoID: acao.id)
        try documento.guardarVersaoHumana("Minha revisão da segunda oferta")
        try documento.validar()

        #expect(documento.artefatos.first == primeira)
        #expect(segunda.anteriorID == primeira.id)
        #expect(segunda.origem == .ia)
        #expect(documento.versaoAtual?.anteriorID == segunda.id)
        #expect(documento.versaoAtual?.origem == .mista)
        #expect(documento.acoes[0].artefatoID == primeira.id)
        #expect(documento.evidencias[0].artefatoID == primeira.id)
        #expect(documento.evidencias[0].acaoID == acao.id)
    }

    @Test func relatoNaoViraVerificacaoIndependenteNemAprendizagem() throws {
        var documento = DocumentoTrabalho(intencao: "Comparar preços")
        try documento.prepararAcao("Comparar duas propostas")
        let acao = try #require(documento.acoes.first)
        try documento.registrarRelato("A comparação pareceu útil, mas ainda tenho dúvidas", acaoID: acao.id)

        let evidencia = try #require(documento.evidencias.first)
        #expect(evidencia.tipo == .relato)
        #expect(evidencia.atribuidaA == "Você")
        // SPEC 05i distingue observação e ato: um relato, por si, não prova
        // execução. A expectativa antiga acompanhava uma inferência indevida.
        #expect(documento.acoes[0].estado == .pendente)
        #expect(documento.acoes[0].executadaEm == nil)
        #expect(documento.hipoteses.isEmpty)
        #expect(!documento.encerrado)
    }

    @Test func relatoDeNaoExecucaoMantemEstadoERelatoPosteriorNaoMudaDataDoAto() throws {
        var documento = DocumentoTrabalho(intencao: "Realizar um ensaio")
        try documento.prepararAcao("Ensaiar a apresentação")
        let acao = try #require(documento.acoes.first).id
        try documento.registrarRelato("Não consegui ensaiar hoje", acaoID: acao)
        #expect(documento.acoes[0].estado == .pendente)
        #expect(documento.acoes[0].executadaEm == nil)
        try documento.marcarExecutada(acao)
        let quandoExecutou = try #require(documento.acoes[0].executadaEm)
        try documento.registrarRelato("Agora fiz o ensaio; ainda não sei se melhorou", acaoID: acao)
        #expect(documento.acoes[0].estado == .executada)
        #expect(documento.acoes[0].executadaEm == quandoExecutou)
        #expect(documento.evidencias.count == 2)
        #expect(documento.hipoteses.isEmpty && !documento.encerrado)
    }

    @Test func trocarApoioOuContestarPremissaInvalidaProducaoEmVoo() async throws {
        for mudarApoio in [true, false] {
            var original = DocumentoTrabalho(intencao: "Preparar proposta")
            let hipotese = DocumentoTrabalho.Hipotese(texto: "Preciso praticar a comparação",
                                                     contexto: "Propostas da semana", evidencias: [])
            original.hipoteses.append(hipotese)
            try original.avaliarHipotese(hipotese.id, estado: .confirmada)
            let (_, oficina) = try criarOficina(original)
            let produtor = ProdutorControlado()
            oficina.produzir = produtor.produzir
            oficina.estaDisponivel = { true }
            let tarefa = try #require(oficina.gerar("Prepare a proposta"))
            await produtor.aguardar(1)
            if mudarApoio {
                #expect(oficina.alterar { $0.apoio = .praticar })
            } else {
                #expect(oficina.alterar { try $0.avaliarHipotese(hipotese.id, estado: .contestada) })
            }
            let corrigido = oficina.documento
            #expect(corrigido.pedidoAtivo == nil)
            produtor.devolver(0, texto: "Produzido sob a divisão de trabalho anterior")
            await tarefa.value
            #expect(oficina.documento == corrigido)
            #expect(oficina.documento.artefatos.isEmpty)
            #expect(try oficina.trabalho.ler() == corrigido)
        }
    }

    @Test func contestacaoNaoSomeParaFingirQuePedidoCabeNoModelo() throws {
        for teto in [3500, 18000] {
            var documento = DocumentoTrabalho(intencao: String(repeating: "intenção detalhada ", count: teto / 18))
            let hipotese = DocumentoTrabalho.Hipotese(texto: "Não atribuir minha decisão à falta de capacidade",
                                                     contexto: "Faltava informação de preço, não conhecimento",
                                                     evidencias: [])
            documento.hipoteses.append(hipotese)
            try documento.avaliarHipotese(hipotese.id, estado: .contestada)
            let pedido = try documento.iniciarPedido("Compare as alternativas")
            let prompt = MotorTrabalho.pedido(documento, pedido, teto: teto)
            #expect(prompt.contains(pedido.instrucao))
            let correcao = try #require(prompt.split(separator: "\n").first(where: { $0.contains(hipotese.texto) }))
            #expect(correcao.contains("contestada") && correcao.contains(hipotese.contexto))
            // O produtor deve recusar o núcleo grande; o construtor não pode
            // caber silenciosamente descartando a correção que muda seu significado.
            #expect(prompt.count > teto)
        }
    }

    @Test func promptDistingueAvaliacoesDeVersoesEAcoesDiferentes() throws {
        var documento = DocumentoTrabalho(intencao: "Revisar uma proposta")
        try documento.guardarVersaoHumana("Proposta A")
        try documento.prepararAcao("Apresentar A")
        let acaoA = try #require(documento.acoes.first).id
        try documento.registrarRelato("A não esclareceu o prazo", acaoID: acaoA)
        documento.evidencias[0].data = Date(timeIntervalSince1970: 1000)
        try documento.guardarVersaoHumana("Proposta B, prazo detalhado")
        try documento.prepararAcao("Apresentar B")
        let acaoB = try #require(documento.acoes.last).id
        try documento.registrarRelato("B esclareceu o prazo", acaoID: acaoB)
        documento.evidencias[1].data = Date(timeIntervalSince1970: 2000)
        let pedido = try documento.iniciarPedido("Proponha a próxima revisão")
        let prompt = MotorTrabalho.pedido(documento, pedido, teto: 10000)
        for evidencia in documento.evidencias {
            let linha = try #require(prompt.split(separator: "\n").first(where: { $0.contains(evidencia.texto) }))
            #expect(linha.contains(evidencia.acaoID.uuidString))
            #expect(linha.contains(try #require(evidencia.artefatoID).uuidString))
            #expect(linha.contains(evidencia.data.ISO8601Format()))
            #expect(linha.contains("relato") && linha.contains(evidencia.atribuidaA))
        }
    }

    @Test func oficinaObsoletaNaoSobrescreveHistoricoDeOutraAbertura() throws {
        let (container, antiga) = try criarOficina(DocumentoTrabalho(intencao: "Intenção compartilhada"))
        let atual = try OficinaTrabalho(trabalho: antiga.trabalho, context: container.mainContext)
        #expect(atual.alterar { try $0.prepararAcao("Ação que outra abertura guardou") })
        let persistido = try atual.trabalho.ler()
        #expect(!antiga.alterar { try $0.reverIntencao("Revisão numa abertura antiga", resultado: "Novo critério") })
        #expect(!antiga.salvo && antiga.erro != nil)
        #expect(antiga.documento.intencaoAtual.texto == "Revisão numa abertura antiga")
        #expect(try atual.trabalho.ler() == persistido)
        #expect(persistido.acoes.count == 1)
    }

    @Test func abrirDuranteProducaoNaoInterrompeExecutorVivo() async throws {
        let (container, oficina) = try criarOficina(DocumentoTrabalho(intencao: "Produção em curso"))
        let produtor = ProdutorControlado()
        oficina.produzir = produtor.produzir
        oficina.estaDisponivel = { true }
        let tarefa = try #require(oficina.gerar("Prepare o material"))
        await produtor.aguardar(1)
        let pedido = try #require(oficina.documento.pedidoAtivo)
        var recusouAbertura = false
        do {
            _ = try OficinaTrabalho(trabalho: oficina.trabalho, context: container.mainContext)
        } catch OficinaTrabalho.ErroAbertura.emExecucao { recusouAbertura = true }
        #expect(recusouAbertura)
        #expect(try oficina.trabalho.ler().pedidoAtivo?.id == pedido.id)
        produtor.devolver(0, texto: "Material concluído pelo executor original")
        await tarefa.value
        let reaberta = try OficinaTrabalho(trabalho: oficina.trabalho, context: container.mainContext)
        #expect(reaberta.documento.pedidos.last?.estado == .pronto)
        #expect(reaberta.documento.versaoAtual?.conteudo == "Material concluído pelo executor original")
    }

    @Test func indisponibilidadeGuardaInstrucaoParaReabrirERepetir() async throws {
        var original = DocumentoTrabalho(intencao: "Continuar com meu material")
        try original.guardarVersaoHumana("Versão humana preservada")
        let (container, oficina) = try criarOficina(original)
        oficina.estaDisponivel = { false }
        let produtor = ProdutorControlado()
        oficina.produzir = produtor.produzir
        let instrucao = "Rever somente a clareza da proposta"
        #expect(oficina.gerar(instrucao) == nil)
        #expect(produtor.chamadas.isEmpty)
        let reaberta = try OficinaTrabalho(trabalho: oficina.trabalho, context: container.mainContext)
        let guardado = try #require(reaberta.documento.pedidos.last)
        #expect(guardado.instrucao == instrucao && guardado.estado == .falhou)
        #expect(reaberta.documento.artefatos == original.artefatos)
        reaberta.estaDisponivel = { true }
        reaberta.produzir = produtor.produzir
        let tarefa = try #require(reaberta.gerar(guardado.instrucao))
        await produtor.aguardar(1)
        #expect(produtor.chamadas[0].pedido.instrucao == instrucao)
        produtor.devolver(0, texto: "Revisão disponível agora")
        await tarefa.value
        #expect(reaberta.documento.artefatos.first == original.artefatos.first)
        #expect(reaberta.documento.versaoAtual?.conteudo == "Revisão disponível agora")
    }

    @Test func contestacaoVaiAoPedidoComContextoSemDeslocarInstrucao() throws {
        var documento = DocumentoTrabalho(intencao: "Escolher fornecedores", resultado: "Comparar custos recorrentes")
        try documento.guardarVersaoHumana(String(repeating: "material extenso ", count: 800))
        try documento.prepararAcao("Conferir duas propostas")
        try documento.registrarRelato("Conferi os custos, mas faltava uma taxa na proposta", acaoID: try #require(documento.acoes.first).id)
        let evidencia = try #require(documento.evidencias.first)
        let hipotese = DocumentoTrabalho.Hipotese(texto: "Preciso de prática em custos recorrentes",
                                                 contexto: "Comparação de fornecedores, taxa ausente",
                                                 evidencias: [evidencia.id])
        documento.hipoteses.append(hipotese)
        try documento.avaliarHipotese(hipotese.id, estado: .contestada)
        let pedido = try documento.iniciarPedido("Prepare uma tabela de comparação")
        let prompt = MotorTrabalho.pedido(documento, pedido, teto: 1800)

        #expect(prompt.count <= 1800)
        #expect(prompt.contains(pedido.instrucao))
        #expect(prompt.contains(documento.intencaoAtual.texto))
        #expect(prompt.contains(documento.intencaoAtual.resultado))
        let linhaDaHipotese = try #require(prompt.split(separator: "\n").first(where: { $0.contains(hipotese.texto) }))
        #expect(linhaDaHipotese.contains("contestada"))
        #expect(linhaDaHipotese.contains("Você"))
        #expect(linhaDaHipotese.contains(hipotese.contexto))
        #expect(documento.hipoteses[0].evidencias == [evidencia.id])
    }

    @Test func recusaDoDiscoPreservaRascunhoEPermiteGuardarDepois() throws {
        let original = DocumentoTrabalho(intencao: "Intenção original", resultado: "Resultado original")
        let (container, trabalho) = try criarOficina(original)
        trabalho.persistir = { _ in throw Falha.disco }

        #expect(!trabalho.alterar { try $0.reverIntencao("Intenção revisada", resultado: "Resultado revisado") })
        #expect(!trabalho.salvo)
        #expect(trabalho.erro != nil)
        #expect(trabalho.documento.intencaoAtual.texto == "Intenção revisada")
        #expect(try trabalho.trabalho.ler() == original)

        trabalho.persistir = { try $0.save() }
        #expect(trabalho.guardar())
        #expect(trabalho.salvo)
        #expect(trabalho.erro == nil)
        let persistido = try #require(container.mainContext.fetch(FetchDescriptor<Trabalho>()).first).ler()
        #expect(persistido == trabalho.documento)
        #expect(persistido.intencoes.first == original.intencoes.first)
    }

    @Test func falhaDoTrabalhoNaoDescartaNotaPendenteNoMesmoContexto() throws {
        let original = DocumentoTrabalho(intencao: "Intenção já salva")
        let (container, oficina) = try criarOficina(original)
        let context = container.mainContext
        context.autosaveEnabled = false
        let nota = Nota(texto: "Nota antes da edição", gesto: .woop,
                        campos: ["obstaculo": "Antes"])
        context.insert(nota)
        try context.save()
        let dataDoTrabalho = oficina.trabalho.atualizadoEm
        nota.texto = "Texto da nota ainda não salvo"
        nota.campos = ["obstaculo": "Primeiro parágrafo\n\nSegundo parágrafo"]
        context.processPendingChanges()
        oficina.persistir = { _ in throw Falha.disco }

        #expect(!oficina.alterar { try $0.reverIntencao("Rascunho de trabalho que o disco recusou", resultado: "Novo resultado") })
        #expect(nota.texto == "Texto da nota ainda não salvo")
        #expect(nota.campos["obstaculo"] == "Primeiro parágrafo\n\nSegundo parágrafo")
        #expect(oficina.documento.intencaoAtual.texto == "Rascunho de trabalho que o disco recusou")
        #expect(!oficina.salvo)
        #expect(try oficina.trabalho.ler() == original)
        #expect(oficina.trabalho.titulo == original.intencaoAtual.texto)
        #expect(oficina.trabalho.atualizadoEm == dataDoTrabalho)

        // Salvar a nota depois não deve gravar por acidente o Trabalho recusado.
        try context.save()
        let leituraNova = ModelContext(container)
        let notaSalva = try #require(leituraNova.fetch(FetchDescriptor<Nota>()).first)
        let trabalhoSalvo = try #require(leituraNova.fetch(FetchDescriptor<Trabalho>()).first)
        #expect(notaSalva.uuid == nota.uuid)
        #expect(notaSalva.texto == "Texto da nota ainda não salvo")
        #expect(notaSalva.campos["obstaculo"] == "Primeiro parágrafo\n\nSegundo parágrafo")
        #expect(try trabalhoSalvo.ler() == original)
    }

    @Test func jsonCorrompidoNaoSeTornaTrabalhoVazioSobrescrito() throws {
        let (container, oficina) = try criarOficina(DocumentoTrabalho(intencao: "Não apagar"))
        let bytes = Data("{conteudo inválido".utf8)
        oficina.trabalho.conteudoJSON = bytes
        try container.mainContext.save()
        var recusou = false
        do {
            _ = try OficinaTrabalho(trabalho: oficina.trabalho, context: container.mainContext)
        } catch { recusou = true }
        #expect(recusou)
        #expect(oficina.trabalho.conteudoJSON == bytes)
        #expect(oficina.trabalho.titulo == "Não apagar")
    }

    @Test func referenciaCorrompidaTambemRecusaAberturaSemSobrescrever() throws {
        var documento = DocumentoTrabalho(intencao: "Trabalho íntegro")
        try documento.prepararAcao("Uma ação")
        let (container, oficina) = try criarOficina(documento)
        documento.acoes[0].artefatoID = UUID()
        let bytes = try JSONEncoder().encode(documento)
        oficina.trabalho.conteudoJSON = bytes
        try container.mainContext.save()
        var recusou = false
        do {
            _ = try OficinaTrabalho(trabalho: oficina.trabalho, context: container.mainContext)
        } catch { recusou = true }
        #expect(recusou)
        #expect(oficina.trabalho.conteudoJSON == bytes)
    }

    @Test func reabrirPedidoSemExecutorPreservaInstrucaoEVersoes() throws {
        var documento = DocumentoTrabalho(intencao: "Continuar amanhã")
        try documento.guardarVersaoHumana("Primeira versão preservada")
        let pedido = try documento.iniciarPedido("Revisar amanhã sem inventar dados")
        let (_, oficina) = try criarOficina(documento)
        #expect(oficina.documento.pedidoAtivo == nil)
        #expect(oficina.documento.pedidos.last?.id == pedido.id)
        #expect(oficina.documento.pedidos.last?.instrucao == pedido.instrucao)
        #expect(oficina.documento.pedidos.last?.estado == .interrompido)
        #expect(oficina.documento.artefatos == documento.artefatos)
        #expect(try oficina.trabalho.ler() == oficina.documento)
    }

    @Test func migracaoV3MantemNotaSeladaReciboEPermiteTrabalhoPersistente() throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("trabalho-migracao-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: raiz) }
        let url = raiz.appendingPathComponent("dados.sqlite")
        let notaID = UUID()
        let data = Date(timeIntervalSince1970: 1234)
        let documento = DocumentoTrabalho(intencao: "Trabalho novo")
        do {
            let v3 = try ModelContainer(for: Schema(versionedSchema: TracoSchemaV3.self),
                                       configurations: ModelConfiguration(url: url))
            let nota = Nota(texto: "Texto pessoal preservado", gesto: .expressiva, campos: [:],
                            trancada: true, criadaEm: data, editadaEm: data, sentido: "Sentido preservado")
            nota.uuid = notaID
            v3.mainContext.insert(nota)
            v3.mainContext.insert(ReciboEntrada(chave: "arquivo-ja-importado", recebidaEm: data))
            try v3.mainContext.save()
        }
        do {
            let v4 = try ModelContainer.traco(url: url)
            let nota = try #require(v4.mainContext.fetch(FetchDescriptor<Nota>()).first)
            #expect(nota.uuid == notaID)
            #expect(nota.texto == "Texto pessoal preservado")
            #expect(nota.trancada && nota.gesto == .expressiva)
            #expect(nota.sentido == "Sentido preservado")
            #expect(nota.criadaEm == data && nota.editadaEm == data)
            let recibo = try #require(v4.mainContext.fetch(FetchDescriptor<ReciboEntrada>()).first)
            #expect(recibo.chave == "arquivo-ja-importado" && recibo.recebidaEm == data)
            v4.mainContext.insert(try Trabalho(documento: documento))
            try v4.mainContext.save()
        }
        let reaberto = try ModelContainer.traco(url: url)
        #expect(try reaberto.mainContext.fetchCount(FetchDescriptor<Nota>()) == 1)
        #expect(try reaberto.mainContext.fetchCount(FetchDescriptor<ReciboEntrada>()) == 1)
        #expect(try #require(reaberto.mainContext.fetch(FetchDescriptor<Trabalho>()).first).ler() == documento)
    }
}
