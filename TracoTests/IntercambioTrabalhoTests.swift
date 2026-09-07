import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct IntercambioTrabalhoTests {
    private func exemplo(_ texto: String = "Versão original") throws -> DocumentoTrabalho {
        var documento = DocumentoTrabalho(intencao: "Preparar uma conversa")
        try documento.guardarVersaoHumana(texto)
        try documento.prepararAcao("Experimentar a abertura")
        try documento.registrarRelato("Ainda não comecei", acaoID: documento.acoes[0].id)
        return documento
    }

    /// Simula a edição externa do corpo, mantendo o envelope entregue.
    private func editar(_ arquivo: Data, corpo: String) throws -> Data {
        let quebra = try #require(arquivo.firstIndex(of: 0x0A))
        return Data(arquivo[...quebra]) + Data(corpo.utf8)
    }

    @Test func corpoEditadoExternamenteVoltaIntegralComAutoriaEVinculosHonestos() throws {
        var documento = try exemplo()
        let antes = documento
        let corpo = "\n  # Plano 👩🏽‍💻\r\n\r\n```html\r\n<script>não executar()</script>\r\n```\n<!-- comentário comum -->\n\t"
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: corpo)
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAtual && preview.texto == corpo)
        #expect(try documento.aplicarVersaoExterna(preview))
        let nova = try #require(documento.versaoAtual)
        #expect(nova.conteudo == corpo && nova.formato == .markdown)
        #expect(nova.conteudo.utf8.elementsEqual(corpo.utf8))
        #expect(nova.origem == .externa && nova.produtor == "Arquivo importado · autoria não verificada")
        #expect(nova.anteriorID == antes.versaoAtual?.id && nova.intencaoID == antes.intencaoAtual.id)
        #expect(documento.artefatos.dropLast() == antes.artefatos[...])
        #expect(documento.acoes == antes.acoes && documento.evidencias == antes.evidencias)
        let reexportada = try IntercambioTrabalho.preparar(IntercambioTrabalho.exportar(documento), para: documento)
        #expect(reexportada.baseID == nova.id && reexportada.estado == .baseAtual)
    }

    @Test func retornoDaBaseAntigaFormaRamoSemSubstituirVersaoIntermediaria() throws {
        var documento = try exemplo()
        let a = try #require(documento.versaoAtual)
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: "Retorno externo de A")
        try documento.guardarVersaoHumana("Versão B local")
        let antes = documento
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAntiga)
        #expect(throws: IntercambioTrabalho.Erro.self) { try documento.aplicarVersaoExterna(preview) }
        #expect(documento == antes)
        #expect(try documento.aplicarVersaoExterna(preview, confirmarBaseAntiga: true))
        #expect(documento.versaoAtual?.anteriorID == a.id)
        #expect(documento.artefatos.dropLast() == antes.artefatos[...])
        #expect(documento.acoes == antes.acoes)
    }

    @Test func intencaoRevistaExigeConfirmacaoEPreservaIntencaoDaBase() throws {
        var documento = try exemplo()
        let original = documento.intencaoAtual.id
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: "Preparado para intenção antiga")
        try documento.reverIntencao("Agora quero outra conversa", resultado: "Outro resultado")
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAntiga && preview.intencaoDaBaseID == original)
        #expect(try documento.aplicarVersaoExterna(preview, confirmarBaseAntiga: true))
        #expect(documento.versaoAtual?.intencaoID == original)
        #expect(documento.intencaoAtual.id != original)
    }

    @Test func mudancaDepoisDaPreviaExigeNovaConfirmacaoMasRelatoPodeSerConservado() throws {
        for mudarIntencao in [true, false] {
            var documento = try exemplo()
            let preview = try IntercambioTrabalho.preparar(Data("Texto externo".utf8), para: documento)
            if mudarIntencao { try documento.reverIntencao("Outra intenção", resultado: "") }
            else { try documento.guardarVersaoHumana("Outra versão") }
            let antes = documento
            #expect(throws: IntercambioTrabalho.Erro.self) { try documento.aplicarVersaoExterna(preview) }
            #expect(documento == antes)
        }
        var documento = try exemplo()
        let preview = try IntercambioTrabalho.preparar(Data("Texto externo".utf8), para: documento)
        try documento.registrarRelato("Chegou enquanto eu conferia", acaoID: documento.acoes[0].id)
        let evidencias = documento.evidencias
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.evidencias == evidencias)
    }

    @Test func semEnvelopeNaoInventaAncestralNemRemoveBOMOuComentario() throws {
        var documento = try exemplo()
        let texto = "\u{FEFF}<!-- comentário comum -->\r\n\n  material externo  \n"
        let preview = try IntercambioTrabalho.preparar(Data(texto.utf8), para: documento)
        #expect(preview.estado == .semVinculo && preview.texto == texto)
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.versaoAtual?.anteriorID == nil)
        #expect(documento.versaoAtual?.intencaoID == documento.intencaoAtual.id)
        try documento.guardarVersaoHumana("Minha edição posterior")
        #expect(documento.versaoAtual?.origem == .mista)
        #expect(documento.versaoAtual?.produtor == "Você, a partir de versão anterior")
        #expect(documento.artefatos[documento.artefatos.count - 2].origem == .externa)
    }

    @Test func BOMAntesDoEnvelopeECRLFPreservamCorpoExato() throws {
        let documento = try exemplo()
        let exportado = try IntercambioTrabalho.exportar(documento)
        let quebra = try #require(exportado.firstIndex(of: 0x0A))
        let corpo = "\r\ntexto editado\r\n\n"
        let arquivo = Data([0xEF, 0xBB, 0xBF]) + Data(exportado[..<quebra]) + Data("\r\n".utf8) + Data(corpo.utf8)
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAtual && preview.texto == corpo)
    }

    @Test func envelopeAdulteradoNuncaCaiEmSemVinculo() throws {
        let documento = try exemplo()
        let exportado = try IntercambioTrabalho.exportar(documento)
        let quebra = try #require(exportado.firstIndex(of: 0x0A))
        let linha = String(decoding: exportado[..<quebra], as: UTF8.self)
        let payload = String(linha.dropFirst("<!-- traco-trabalho:v1 ".count).dropLast(" -->".count))
        let json = try #require(Data(base64Encoded: payload))
        let original = try #require(JSONSerialization.jsonObject(with: json) as? [String: Any])
        for chave in ["trabalhoID", "artefatoID", "intencaoID", "hashBase", "protocolo"] {
            var valores = original
            if chave == "protocolo" { valores[chave] = 99 }
            else if chave == "hashBase" { valores[chave] = "hash adulterado" }
            else { valores[chave] = UUID().uuidString }
            let adulterado = try JSONSerialization.data(withJSONObject: valores).base64EncodedString()
            let arquivo = Data("<!-- traco-trabalho:v1 \(adulterado) -->\ncorpo".utf8)
            var destino = documento
            let preview = try IntercambioTrabalho.preparar(arquivo, para: destino)
            #expect(preview.estado == .incompativel)
            #expect(throws: IntercambioTrabalho.Erro.self) { try destino.aplicarVersaoExterna(preview) }
            #expect(destino == documento)
        }
        for texto in ["<!-- traco-trabalho:v9 e30= -->\ncorpo", "<!-- traco-trabalho:v1 @@@ -->\ncorpo", "<!-- traco-trabalho:v1 sem fecho"] {
            #expect(try IntercambioTrabalho.preparar(Data(texto.utf8), para: documento).estado == .incompativel)
        }
    }

    @Test func repeticaoNaoFabricaHistoricoENaoCancelaPedidoQuandoNadaMudou() throws {
        var documento = try exemplo()
        let semEdicao = try IntercambioTrabalho.preparar(IntercambioTrabalho.exportar(documento), para: documento)
        _ = try documento.iniciarPedido("Preparação em curso")
        let antes = documento
        #expect(try !documento.aplicarVersaoExterna(semEdicao))
        #expect(documento == antes)
        let dados = Data("Versão externa nova".utf8)
        let preview = try IntercambioTrabalho.preparar(dados, para: documento)
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.pedidoAtivo == nil)
        let depois = documento
        #expect(throws: IntercambioTrabalho.Erro.self) { try documento.aplicarVersaoExterna(preview) }
        let repetida = try IntercambioTrabalho.preparar(dados, para: documento)
        #expect(try !documento.aplicarVersaoExterna(repetida))
        #expect(documento == depois)
    }

    @Test func encodingInvalidoETamanhoExcessivoSaoRecusadosSemTruncamento() throws {
        let documento = try exemplo()
        #expect(throws: IntercambioTrabalho.Erro.self) {
            try IntercambioTrabalho.preparar(Data([0xC3, 0x28]), para: documento)
        }
        let noLimite = Data(repeating: 0x61, count: IntercambioTrabalho.limiteBytes)
        #expect(try IntercambioTrabalho.preparar(noLimite, para: documento).texto.utf8.count == noLimite.count)
        #expect(throws: IntercambioTrabalho.Erro.self) {
            try IntercambioTrabalho.preparar(noLimite + Data([0x61]), para: documento)
        }
        var enorme = documento
        try enorme.guardarVersaoHumana(String(decoding: noLimite, as: UTF8.self))
        #expect(throws: IntercambioTrabalho.Erro.self) { try IntercambioTrabalho.exportar(enorme) }
    }

    @Test func fidelidadeDeBytesNaoConfundeUnicodeEquivalenteComReplay() throws {
        var documento = try exemplo("caf\u{E9}")
        let decomposto = "cafe\u{301}"
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: decomposto)
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(try documento.aplicarVersaoExterna(preview))
        #expect(documento.versaoAtual?.conteudo.utf8.elementsEqual(decomposto.utf8) == true)
    }

    @Test func commitRecusadoPreservaCandidatoERetryNaoAdicionaOutraVersao() throws {
        enum Falha: Error { case disco }
        let container = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: exemplo())
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let antes = trabalho.conteudoJSON
        let preview = try IntercambioTrabalho.preparar(Data("Nova versão importada".utf8), para: oficina.documento)
        oficina.persistir = { _ in throw Falha.disco }
        #expect(!oficina.alterar { try $0.aplicarVersaoExterna(preview) })
        let idCandidato = oficina.documento.versaoAtual?.id
        #expect(trabalho.conteudoJSON == antes && oficina.documento.artefatos.count == 2)
        oficina.persistir = { try $0.save() }
        #expect(oficina.guardar())
        let volta = try trabalho.ler()
        #expect(volta.artefatos.count == 2 && volta.versaoAtual?.id == idCandidato)
        #expect(volta.versaoAtual?.origem == .externa)
    }

    // MARK: - Volta 11: conflito, retry e selo com a tela aberta (ADR 06a)

    @Test func conflitoMostraAsDuasVersoesEEscolherNuncaSobrescreve() throws {
        var documento = try exemplo("Versão A, a que saiu no arquivo")
        let a = try #require(documento.versaoAtual)
        let arquivo = try editar(IntercambioTrabalho.exportar(documento), corpo: "Versão A editada fora")
        try documento.guardarVersaoHumana("Versão B, escrita aqui enquanto o arquivo estava fora")
        let antes = documento
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAntiga)

        // As DUAS versões, com a consequência dita antes da escolha.
        let conflito = try #require(IntercambioTrabalho.conflito(preview, em: documento))
        #expect(conflito.textoAtual == "Versão B, escrita aqui enquanto o arquivo estava fora")
        #expect(conflito.textoArquivo == "Versão A editada fora")
        #expect(conflito.tituloAtual.contains("versão 2") && conflito.tituloArquivo.contains("versão 1"))
        #expect(conflito.consequencia.contains("versão 2") && conflito.consequencia.contains("histórico"))
        // Só a base antiga é conflito: o retorno feliz não abre as duas.
        let comBaseAtual = try exemplo()
        let feliz = try IntercambioTrabalho.preparar(
            try editar(IntercambioTrabalho.exportar(comBaseAtual), corpo: "editado"), para: comBaseAtual)
        #expect(IntercambioTrabalho.conflito(feliz, em: comBaseAtual) == nil)

        // "Manter só a versão atual" não toca em nada.
        #expect(documento == antes)
        // "Guardar o arquivo como nova versão" acrescenta, nunca sobrescreve.
        #expect(try documento.aplicarVersaoExterna(preview, confirmarBaseAntiga: true))
        #expect(documento.artefatos.dropLast() == antes.artefatos[...])
        #expect(documento.artefatos.count == 3)
        #expect(documento.versaoAtual?.conteudo == "Versão A editada fora")
        #expect(documento.versaoAtual?.anteriorID == a.id && documento.versaoAtual?.origem == .externa)
        #expect(documento.acoes == antes.acoes && documento.evidencias == antes.evidencias)
    }

    @Test func recusaDeCommitOfereceRetryQueConfirmaAMesmaVersaoSemDuplicar() throws {
        enum Falha: Error { case disco }
        let container = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: exemplo())
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let preview = try IntercambioTrabalho.preparar(Data("Versão vinda de fora".utf8), para: oficina.documento)

        // A tela aplica: a mutação passou, o commit recusou.
        oficina.persistir = { _ in throw Falha.disco }
        var mudou = false
        let guardou = oficina.alterar { mudou = try $0.aplicarVersaoExterna(preview) }
        let recusa = IntercambioTrabalho.Desfecho.de(mudou: mudou, guardou: guardou,
                                                     acesso: oficina.acesso.permitido,
                                                     recusa: oficina.recusaDoCommit)
        #expect(oficina.recusaDoCommit == .disco)
        #expect(recusa == .aguardandoCommit && recusa.ofereceTentarGuardar && !recusa.mantemRevisao)
        #expect(recusa.linha.contains("Nada foi perdido"))
        let candidato = oficina.documento.versaoAtual?.id
        #expect(oficina.documento.artefatos.count == 2 && !oficina.salvo)

        // "Tentar guardar de novo" não reimporta: confirma a MESMA versão.
        oficina.persistir = { try $0.save() }
        #expect(oficina.guardar())
        #expect(!IntercambioTrabalho.Desfecho.confirmada.ofereceTentarGuardar)
        let volta = try trabalho.ler()
        #expect(volta.artefatos.count == 2 && volta.versaoAtual?.id == candidato)
        #expect(volta.versaoAtual?.origem == .externa)

        // Uma segunda passada pela mesma prévia não fabrica outra cópia.
        let repetida = try IntercambioTrabalho.preparar(Data("Versão vinda de fora".utf8), para: oficina.documento)
        var mudouDeNovo = false
        let guardouDeNovo = oficina.alterar { mudouDeNovo = try $0.aplicarVersaoExterna(repetida) }
        #expect(IntercambioTrabalho.Desfecho.de(mudou: mudouDeNovo, guardou: guardouDeNovo,
                                                acesso: oficina.acesso.permitido,
                                                recusa: oficina.recusaDoCommit) == .semNovidade)
        #expect(try trabalho.ler().artefatos.count == 2)
    }

    @Test func selarAOrigemComOSeletorAbertoRecolheOMaterialEDizOQueRecolheu() throws {
        for material in [IntercambioTrabalho.Material.seletor, .exportacao, .revisao] {
            let container = try ModelContainer.traco(emMemoria: true)
            let nota = Nota(texto: "A origem deste trabalho")
            container.mainContext.insert(nota)
            var documento = try exemplo()
            documento.notaOrigemID = nota.uuid
            let trabalho = try Trabalho(documento: documento)
            container.mainContext.insert(trabalho)
            try container.mainContext.save()
            let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)

            // A tela declara o que tem em mãos; nada foi recolhido ainda.
            oficina.intercambioAberto = material
            #expect(oficina.verificarAcesso())
            #expect(oficina.intercambioRecolhido == .nenhum)

            nota.trancada = true
            try container.mainContext.save()
            #expect(!oficina.verificarAcesso())
            #expect(oficina.intercambioAberto == .nenhum)
            #expect(oficina.intercambioRecolhido == material)
            let linha = try #require(oficina.intercambioRecolhido.recolhimento)
            #expect(linha.contains("A origem foi protegida"))
            #expect(linha.contains(material == .exportacao ? "Nada saiu do Traço" : "Nada foi importado"))
            // Nada foi apagado do trabalho por causa do selo.
            #expect(try trabalho.ler().artefatos.count == 1)

            // Liberada a origem, a linha cala: ela fala do que acabou de acontecer.
            nota.trancada = false
            try container.mainContext.save()
            #expect(oficina.verificarAcesso())
            #expect(oficina.intercambioRecolhido == .nenhum)
            #expect(IntercambioTrabalho.Material.nenhum.recolhimento == nil)
        }
    }

    // MARK: - Volta 11-B: o conflito que não existe e a recusa que não se repete

    @Test func arquivoSemNovidadeNaoInventaConflitoNemPedeDecisao() throws {
        // A rota de três toques do G3: exportar, guardar OUTRA intenção e
        // importar o MESMO arquivo. A intenção revista basta para `.baseAntiga`
        // e não move versão nenhuma: não há dois lados a comparar.
        var documento = try exemplo("A única versão")
        let arquivo = try IntercambioTrabalho.exportar(documento)
        try documento.reverIntencao("Preparar uma conversa difícil", resultado: "Ela me ouve")
        let antes = documento
        let preview = try IntercambioTrabalho.preparar(arquivo, para: documento)
        #expect(preview.estado == .baseAntiga && preview.baseID == preview.versaoVigenteID)
        #expect(IntercambioTrabalho.conflito(preview, em: documento) == nil)
        #expect(IntercambioTrabalho.jaGuardado(preview, em: documento))
        let linha = IntercambioTrabalho.descricaoDaBase(preview, em: documento)
        #expect(!linha.contains("mudou dos dois lados"))
        #expect(linha.contains("mesmo conteúdo") && linha.contains("nada para decidir"))
        // E a escolha não teria efeito nenhum: a mutação recusa e nada muda.
        #expect(!(try documento.aplicarVersaoExterna(preview, confirmarBaseAntiga: true)))
        #expect(documento == antes)

        // A versão local andou, mas o arquivo voltou intocado: também não são
        // dois lados — o que ele traz já está no histórico.
        var voltou = try exemplo("Versão A")
        let intocado = try IntercambioTrabalho.exportar(voltou)
        try voltou.guardarVersaoHumana("Versão B, escrita aqui")
        let previaIntocada = try IntercambioTrabalho.preparar(intocado, para: voltou)
        #expect(previaIntocada.estado == .baseAntiga && previaIntocada.baseID != previaIntocada.versaoVigenteID)
        #expect(IntercambioTrabalho.conflito(previaIntocada, em: voltou) == nil)
        #expect(IntercambioTrabalho.descricaoDaBase(previaIntocada, em: voltou).contains("mesmo conteúdo"))

        // O conflito de verdade continua de pé: as duas pontas com texto diferente.
        var real = try exemplo("Versão A")
        let saiu = try editar(IntercambioTrabalho.exportar(real), corpo: "Versão A editada fora")
        try real.guardarVersaoHumana("Versão B, escrita aqui")
        let comConflito = try IntercambioTrabalho.preparar(saiu, para: real)
        #expect(IntercambioTrabalho.conflito(comConflito, em: real) != nil)
        #expect(IntercambioTrabalho.descricaoDaBase(comConflito, em: real).contains("mudou dos dois lados"))
    }

    @Test func recusaPorBaseDivergenteNaoOfereceNovaTentativaQueNaoPodeDarCerto() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        let trabalho = try Trabalho(documento: exemplo())
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let preview = try IntercambioTrabalho.preparar(Data("Versão vinda de fora".utf8), para: oficina.documento)

        // Outra abertura do MESMO trabalho escreve enquanto esta Oficina vive.
        let outraAbertura = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        #expect(outraAbertura.alterar { try $0.prepararAcao("Escrito na outra abertura") })
        var mudou = false
        let guardou = oficina.alterar { mudou = try $0.aplicarVersaoExterna(preview) }
        #expect(mudou && !guardou && oficina.recusaDoCommit == .baseDivergente)
        let desfecho = IntercambioTrabalho.Desfecho.de(mudou: mudou, guardou: guardou,
                                                       acesso: oficina.acesso.permitido,
                                                       recusa: oficina.recusaDoCommit)
        #expect(desfecho == .precisaReabrir && !desfecho.ofereceTentarGuardar)
        #expect(desfecho.linha.contains("abra o trabalho outra vez"))
        // Repetir daqui bateria na MESMA guarda: por isso o botão não aparece.
        #expect(!oficina.guardar() && oficina.recusaDoCommit == .baseDivergente)
        // A outra recusa, a do disco, continua sendo a que oferece nova tentativa.
        let doDisco = IntercambioTrabalho.Desfecho.de(mudou: true, guardou: false,
                                                      acesso: true, recusa: .disco)
        #expect(doDisco == .aguardandoCommit && doDisco.ofereceTentarGuardar)
    }

    /// O achado do G4: a truncagem mostra o COMEÇO e a edição de ida-e-volta
    /// acontece no FIM. Com prefixo comum longo os dois cartões exibiam a mesma
    /// cadeia — em AX5 com três frases, e no corpo normal em documento longo.
    @Test func aComparacaoMostraOndeAsDuasVersoesDiferem() throws {
        // Documento LONGO de verdade: 40 linhas iguais e a diferença na última.
        let comum = (1...40).map { "Linha \($0) do plano, igual nos dois lados." }.joined(separator: "\n")
        var documento = try exemplo(comum + "\nConfirmem até quarta, o buffet fecha na quinta.")
        let arquivoOriginal = try IntercambioTrabalho.exportar(documento)
        let saiu = try editar(arquivoOriginal, corpo: comum + "\nConfirmem até terça, o buffet fecha na quarta.")
        try documento.guardarVersaoHumana(comum + "\nConfirmem até quarta, o buffet fecha na quinta de manhã.")
        let preview = try IntercambioTrabalho.preparar(saiu, para: documento)
        let conflito = try #require(IntercambioTrabalho.conflito(preview, em: documento))

        // A prova do G4: os dois cartões deixam de exibir a mesma cadeia.
        #expect(conflito.textoAtual != conflito.textoArquivo)
        // E o que se vê nas PRIMEIRAS linhas de cada cartão já difere — não é
        // preciso rolar 40 linhas iguais para achar a divergência.
        #expect(conflito.textoAtual.prefix(60) != conflito.textoArquivo.prefix(60))
        #expect(conflito.textoAtual.contains("quinta de manhã"))
        #expect(conflito.textoArquivo.contains("até terça"))
        // Nenhum dos dois recortes carrega as quarenta linhas comuns.
        #expect(!conflito.textoAtual.contains("Linha 1 do plano"))
        // E a tela diz onde começou a mostrar, em vez de "o começo de cada uma".
        #expect(conflito.ressalva.contains("começam iguais") && conflito.ressalva.contains("linha 41"))
        #expect(conflito.consequencia.contains("Nenhuma escolha apaga nada"))

        // A janela de AX5 leva bem menos texto: com o contexto do corpo normal
        // ele sozinho preencheria as quatro linhas e os dois cartões voltariam
        // a exibir a mesma cadeia. Com a janela menor a diferença entra nela.
        let ax5 = try #require(IntercambioTrabalho.conflito(preview, em: documento, contexto: 12))
        #expect(ax5.textoAtual.prefix(20) != ax5.textoArquivo.prefix(20))

        // Quando a diferença está logo no começo, o recorte não se mexe.
        let curto = IntercambioTrabalho.recorteDaDiferenca(atual: "Versão A", arquivo: "Versão B")
        #expect(curto.atual == "Versão A" && curto.arquivo == "Versão B")
        #expect(curto.ressalva == "Mostro o começo de cada uma.")

        // Parágrafo único, sem quebra de linha: a ressalva conta caracteres.
        let prosa = String(repeating: "palavra ", count: 30)
        let umaLinha = IntercambioTrabalho.recorteDaDiferenca(atual: prosa + "quarta", arquivo: prosa + "terça")
        #expect(umaLinha.atual != umaLinha.arquivo)
        #expect(umaLinha.atual.hasSuffix("quarta") && umaLinha.arquivo.hasSuffix("terça"))
        #expect(umaLinha.ressalva.contains("primeiros") && umaLinha.ressalva.contains("caracteres"))
    }

    /// Escolha sem retorno visível deixa o autor sem saber se o app entendeu.
    /// As duas saídas que fecham a revisão dizem o mesmo fato.
    @Test func manterAVersaoAtualDizOQueAconteceuComOArquivo() {
        let linha = IntercambioTrabalho.Desfecho.mantida.linha
        #expect(linha.contains("Nada foi importado"))
        #expect(linha.contains("continua no seu aparelho e pode ser importado depois"))
        // Não oferece nova tentativa nem segura a revisão: a revisão fechou.
        #expect(!IntercambioTrabalho.Desfecho.mantida.ofereceTentarGuardar)
        #expect(!IntercambioTrabalho.Desfecho.mantida.mantemRevisao)
    }
}
