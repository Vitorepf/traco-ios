import CoreSpotlight
import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-05s: em toda rota de escrita o commit precede o anúncio e as
/// projeções; o selo vale em cada projeção; e uma escrita atrasada nunca
/// passa por cima de uma mais nova.
@MainActor
@Suite(.serialized)
struct IntegridadeRotasTests {
    enum Recusa: Error { case disco }

    private func isolado(_ executar: (URL) throws -> Void) throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("rotas-integridade-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let corpus = Corpus.diretorio
        let espelho = PastaEspelho.defaults
        let indice = Indice.url
        let versoes = Versoes.diretorio
        let nome = "rotas-integridade-\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: nome))
        Corpus.diretorio = raiz
        PastaEspelho.defaults = defaults
        Indice.url = raiz.appendingPathComponent("indice.json")
        Indice.apagarTudo()
        Versoes.diretorio = raiz.appendingPathComponent("versoes")
        defer {
            Corpus.diretorio = corpus
            PastaEspelho.defaults = espelho
            Indice.apagarTudo()
            Indice.url = indice
            Versoes.diretorio = versoes
            defaults.removePersistentDomain(forName: nome)
            try? FileManager.default.removeItem(at: raiz)
            limparDestaque()
        }
        try executar(raiz)
    }

    private func limparDestaque() {
        let suite = SuperficieDisco.defaults
        for chave in [DestaqueDoDia.chaveLinha, DestaqueDoDia.chaveDia, DestaqueDoDia.chaveId] {
            suite.removeObject(forKey: chave)
        }
    }

    private func md(_ uuid: UUID) -> URL {
        Corpus.pastaNotas.appendingPathComponent(uuid.uuidString.lowercased() + ".md")
    }

    private func fatia(_ texto: String, trancada: Bool = false, emCurso: Bool = false,
                       gesto: Gesto? = nil, id: UUID = UUID()) -> FatiaCorpus {
        FatiaCorpus(id: id, texto: texto, gesto: gesto, campos: [:],
                    criadaEm: Date(timeIntervalSince1970: 1), editadaEm: Date(timeIntervalSince1970: 1),
                    recordada: 0, sentido: "", minutos: 0, trancada: trancada, queimada: false,
                    expressivaEmCurso: emCurso, dominio: nil, serie: nil, dia: 0)
    }

    // MARK: - 1. commit antes do anúncio, rota por rota

    @Test func salvarRecusadoMantemOTextoEALinhaFicaAteGravar() throws {
        try isolado { _ in
            limparDestaque()
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            s.gesto = .destaque
            s.campos = ["unica": "a única de hoje"]
            s.texto = "o dia"
            s.persistirNoDisco = { _ in throw Recusa.disco }
            #expect(!s.salvar(no: c.mainContext))
            #expect(s.texto == "o dia" && s.campos["unica"] == "a única de hoje")
            #expect(s.toast == "Não consegui guardar agora. O texto continua aqui.")
            #expect(s.toastFixo)
            // o widget não anuncia o que o disco não tem
            #expect(DestaqueDoDia.linhaDeHoje() == nil)
            #expect(try c.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
            s.persistirNoDisco = nil
            #expect(s.salvar(no: c.mainContext))
            #expect(s.toast == nil && !s.toastFixo)
            #expect(DestaqueDoDia.linhaDeHoje() == "a única de hoje")
        }
    }

    @Test func trancarESairRecusadoNaoViraAPaginaNemAnunciaOSelo() throws {
        try isolado { _ in
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            s.gesto = .expressiva
            s.texto = "quinze minutos que não podem sumir"
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.trancarESair(no: c.mainContext, destino: .notas)
            #expect(s.texto == "quinze minutos que não podem sumir")
            #expect(s.confirmacao == nil)
            #expect(!s.mostrarNotas)
            #expect(s.toast == "Não consegui guardar agora. O texto continua aqui.")
            #expect(try c.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
            s.persistirNoDisco = nil
            s.trancarESair(no: c.mainContext, destino: .notas)
            let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
            #expect(nota.trancada && s.texto.isEmpty && s.mostrarNotas)
        }
    }

    /// Achado 1 da revisão da volta 7: o relógio parava ANTES do commit; na
    /// recusa a expressiva ficava sem prazo e a gravação automática seguinte
    /// apagava o `expressivaPrazo` — aberta sem tranca, para sempre.
    @Test func trancarESairRecusadoDeixaORelogioDePeEAGravacaoSeguinteLevaOPrazo() throws {
        try isolado { _ in
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            defer { s.pararTimer() }
            s.gesto = .expressiva
            s.texto = "quinze minutos"
            s.iniciarTimer()
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.trancarESair(no: c.mainContext, destino: .notas)
            #expect(s.timerLigado && s.toastFixo)
            // a gravação automática (cena ao fundo, troca de aba) leva o prazo
            s.persistirNoDisco = nil
            #expect(s.salvar(no: c.mainContext))
            let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
            #expect(nota.expressivaPrazo != nil && !nota.trancada)
            #expect(s.timerLigado && !s.toastFixo)
            // e a varredura do arranque sela sem o autor responder (§8)
            s.trancarExpressivasVencidas(no: c.mainContext, agora: .distantFuture)
            #expect(nota.trancada && nota.expressivaPrazo == nil)
        }
    }

    @Test func abrirFechoRecusadoDeixaORelogioDePeEOFechoAbreNaSegunda() throws {
        try isolado { _ in
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            defer { s.pararTimer() }
            s.gesto = .expressiva
            s.texto = "quinze minutos"
            s.iniciarTimer()
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.abrirFecho(no: c.mainContext)
            #expect(s.timerLigado && s.fechoUUID == nil && s.texto == "quinze minutos")
            s.persistirNoDisco = nil
            #expect(s.salvar(no: c.mainContext))
            let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
            #expect(nota.expressivaPrazo != nil)
            s.abrirFecho(no: c.mainContext)
            #expect(!s.timerLigado && s.fechoUUID == nota.uuid && nota.trancada && nota.expressivaPrazo == nil)
        }
    }

    /// Achado 2: qualquer aviso transitório apagava a linha fixa de recusa
    /// antes de haver gravação. Agora ele passa por cima e a linha volta.
    @Test func avisoTransitorioNaoApagaALinhaDeRecusa() async throws {
        let s = Sessao()
        let recusa = "Não consegui guardar agora. O texto continua aqui."
        s.mostrarToast(recusa, fixo: true)
        s.mostrarToast("3 notas vieram de fora.", duracao: .milliseconds(10))
        #expect(s.toast == "3 notas vieram de fora." && s.toastFixo)
        try await Task.sleep(for: .milliseconds(300))
        #expect(s.toast == recusa && s.toastFixo)
    }

    @Test func versaoSoEntraNoHistoricoDepoisDoCommit() throws {
        try isolado { _ in
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            s.texto = "primeira"
            #expect(s.salvar(no: c.mainContext))
            let uuid = try #require(s.notaUUID)
            s.texto = "segunda"
            s.persistirNoDisco = { _ in throw Recusa.disco }
            #expect(!s.salvar(no: c.mainContext))
            #expect(Versoes.listar(uuid).isEmpty)
            s.persistirNoDisco = nil
            #expect(s.salvar(no: c.mainContext))
            #expect(Versoes.listar(uuid).map(\.texto) == ["primeira"])
            // restaurar: a versão substituída também só depois do commit
            let nota = try #require(Sessao.buscar(uuid: uuid, no: c.mainContext))
            let versao = try #require(Versoes.listar(uuid).first)
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.restaurar(nota, versao: versao, no: c.mainContext)
            #expect(Versoes.listar(uuid).count == 1)
            #expect(s.texto == "segunda")
        }
    }

    @Test func expressivaVencidaSoTiraDoIndiceDepoisDoCommit() throws {
        try isolado { _ in
            guard Indice.disponivel else { return }
            let c = try ModelContainer.traco(emMemoria: true)
            let nota = Nota(texto: "hoje senti medo e o peito ficou pesado o dia inteiro",
                            gesto: .expressiva, expressivaPrazo: Date().addingTimeInterval(-30))
            c.mainContext.insert(nota)
            try c.mainContext.save()
            // simula a entrada indevida: o teste quer ver QUANDO a rota tira
            Indice.atualizar(.init(uuid: nota.uuid, editadaEm: nota.editadaEm, voz: nota.texto, podeEntrar: true))
            #expect(Indice.vetorGuardado(nota.uuid) != nil)
            let s = Sessao()
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.trancarExpressivasVencidas(no: c.mainContext)
            let viva = try #require(Sessao.buscar(uuid: nota.uuid, no: c.mainContext))
            #expect(!viva.trancada && viva.expressivaPrazo != nil)
            #expect(Indice.vetorGuardado(nota.uuid) != nil)
            s.persistirNoDisco = nil
            s.trancarExpressivasVencidas(no: c.mainContext)
            #expect(nota.trancada)
            #expect(Indice.vetorGuardado(nota.uuid) == nil)
        }
    }

    @Test func apagarRecusadoRecuaEDeixaOEspelhoComoEstava() throws {
        try isolado { _ in
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            s.texto = "nota que ia ser apagada"
            #expect(s.salvar(no: c.mainContext))
            let uuid = try #require(s.notaUUID)
            Corpus.backupAutomatico(notas: try c.mainContext.fetch(FetchDescriptor<Nota>()))
            #expect(FileManager.default.fileExists(atPath: md(uuid).path))
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.apagar(uuid: uuid, no: c.mainContext)
            #expect(Sessao.buscar(uuid: uuid, no: c.mainContext) != nil)
            #expect(s.apagadaRecuperavel == nil)
            #expect(FileManager.default.fileExists(atPath: md(uuid).path))
            s.persistirNoDisco = nil
            s.apagar(uuid: uuid, no: c.mainContext)
            #expect(Sessao.buscar(uuid: uuid, no: c.mainContext) == nil)
            #expect(!FileManager.default.fileExists(atPath: md(uuid).path))
            // desfazer devolve à projeção na hora, e recusa não devolve nada
            s.persistirNoDisco = { _ in throw Recusa.disco }
            s.desfazerApagar(no: c.mainContext)
            #expect(Sessao.buscar(uuid: uuid, no: c.mainContext) == nil)
            #expect(!FileManager.default.fileExists(atPath: md(uuid).path))
            s.persistirNoDisco = nil
            s.desfazerApagar(no: c.mainContext)
            #expect(Sessao.buscar(uuid: uuid, no: c.mainContext) != nil)
            #expect(FileManager.default.fileExists(atPath: md(uuid).path))
        }
    }

    @Test func importarCorpusProjetaSoDepoisDoCommit() throws {
        try isolado { _ in
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            let itens = [(texto: "veio de um .md", gestoNome: String?.none, criadaEm: Date())]
            s.persistirNoDisco = { _ in throw Recusa.disco }
            #expect(s.importarCorpus(itens, no: c.mainContext) == 0)
            #expect(s.toast?.contains("importada") != true)
            #expect(try c.mainContext.fetch(FetchDescriptor<Nota>()).isEmpty)
            #expect(!FileManager.default.fileExists(atPath: Corpus.pastaNotas.path))
            s.persistirNoDisco = nil
            #expect(s.importarCorpus(itens, no: c.mainContext) == 1)
            let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
            #expect(FileManager.default.fileExists(atPath: md(nota.uuid).path))
        }
    }

    // MARK: - 2. projeções concorrentes, em ordem forçada

    @Test func aVarreduraDoSeloVenceAEscritaAtrasadaDaConclusao() throws {
        try isolado { raiz in
            let a = UUID(), b = UUID(), nova = UUID()
            let aAberta = fatia("a nota aberta", id: a)
            let bAberta = fatia("a dor que vai ser selada", gesto: .expressiva, id: b)
            let bSelada = fatia("a dor que vai ser selada", trancada: true, gesto: .expressiva, id: b)
            // g1: concluir A tirou a foto com B aberta; g2: selar B varreu tudo;
            // g3: uma nota nova concluída depois. A tarefa de g1 chega por último.
            Corpus.escreverUma(fatia("nota nova", id: nova), agregados: [aAberta, bSelada, fatia("nota nova", id: nova)],
                               em: raiz, geracao: 3)
            Corpus.escrever(fatias: [aAberta, bSelada], em: raiz, geracao: 2)
            Corpus.escreverUma(aAberta, agregados: [aAberta, bAberta], em: raiz, geracao: 1)
            let bMd = try String(contentsOf: md(b), encoding: .utf8)
            #expect(bMd.contains("estado: selada") && !bMd.contains("a dor que vai ser selada"))
            let corpus = try String(contentsOf: raiz.appendingPathComponent("traco-corpus.md"), encoding: .utf8)
            #expect(!corpus.contains("a dor que vai ser selada"))
            #expect(corpus.contains("a nota aberta") && corpus.contains("nota nova"))
            #expect(FileManager.default.fileExists(atPath: md(a).path))
            #expect(FileManager.default.fileExists(atPath: md(nova).path))
        }
    }

    @Test func aEntradaDoMacAtrasadaNaoRessuscitaANotaSelada() throws {
        try isolado { _ in
            guard Indice.disponivel else { return }
            let a = UUID(), b = UUID()
            let aberta = Indice.NotaLida(uuid: a, editadaEm: .now, voz: "quero começar a correr de manhã", podeEntrar: true)
            let bAberta = Indice.NotaLida(uuid: b, editadaEm: .now, voz: "pretendo fazer exercício cedo", podeEntrar: true)
            Indice.sincronizar([aberta, bAberta], geracao: 1)
            #expect(Indice.quantas == 2)
            Indice.remover(b, geracao: 3)                       // o selo, na main
            Indice.sincronizar([aberta, bAberta], geracao: 2)   // a entrada do Mac, atrasada
            #expect(Indice.vetorGuardado(b) == nil)
            Indice.atualizar(bAberta, geracao: 2)               // o salvar atrasado
            #expect(Indice.vetorGuardado(b) == nil)
            #expect(Indice.vetorGuardado(a) != nil)
            Indice.atualizar(bAberta, geracao: 4)               // uma rota mais nova pode
            #expect(Indice.vetorGuardado(b) != nil)
        }
    }

    // MARK: - 3. a matriz do selo

    private func quatroEstados() -> (aberta: Nota, emCurso: Nota, selada: Nota, queimada: Nota) {
        let aberta = Nota(texto: "quero começar a correr de manhã")
        let emCurso = Nota(texto: "correr de manhã dói e eu choro", gesto: .expressiva,
                           expressivaPrazo: Date().addingTimeInterval(600))
        let selada = Nota(texto: "correr de manhã era fuga", gesto: .expressiva, trancada: true)
        let queimada = Nota(texto: "", gesto: .expressiva, queimada: true, sentido: "vi o medo")
        return (aberta, emCurso, selada, queimada)
    }

    @Test func seloNoIndiceEmCadaEstado() {
        let n = quatroEstados()
        #expect(Sessao.paraIndice(n.aberta).podeEntrar)
        #expect(!Sessao.paraIndice(n.emCurso).podeEntrar)
        #expect(!Sessao.paraIndice(n.selada).podeEntrar)
        #expect(!Sessao.paraIndice(n.queimada).podeEntrar)
    }

    @Test func seloNoSpotlightEmCadaEstado() {
        let n = quatroEstados()
        let ids = Holofote.indexar(notas: [n.aberta, n.emCurso, n.selada, n.queimada]).map(\.uniqueIdentifier)
        #expect(ids == [n.aberta.uuid.uuidString])
    }

    @Test func seloNoWidgetEmCadaEstado() throws {
        try isolado { _ in
            limparDestaque()
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            s.gesto = .destaque
            s.campos = ["unica": "a única"]
            #expect(s.salvar(no: c.mainContext))
            #expect(DestaqueDoDia.linhaDeHoje() == "a única")
            #expect(s.salvar(no: c.mainContext, trancar: true))
            #expect(DestaqueDoDia.linhaDeHoje() == nil)
            // expressiva em curso, selada e queimada nunca escrevem a linha
            s.novaPagina()
            s.gesto = .expressiva
            s.texto = "a dor"
            s.campos = ["unica": "vazou"]
            #expect(s.salvar(no: c.mainContext))
            #expect(DestaqueDoDia.linhaDeHoje() == nil)
            #expect(s.queimar(no: c.mainContext, sentido: ""))
            #expect(DestaqueDoDia.linhaDeHoje() == nil)
        }
    }

    @Test func seloNoContextoDaSabiaEmCadaEstado() throws {
        try isolado { _ in
            guard Indice.disponivel else { return }
            let c = try ModelContainer.traco(emMemoria: true)
            let n = quatroEstados()
            for nota in [n.aberta, n.emCurso, n.selada, n.queimada] { c.mainContext.insert(nota) }
            try c.mainContext.save()
            // o pior caso: todas no índice, como se um selo atrasado tivesse falhado
            Indice.sincronizar([n.aberta, n.emCurso, n.selada, n.queimada].map {
                .init(uuid: $0.uuid, editadaEm: $0.editadaEm, voz: $0.texto, podeEntrar: true)
            })
            let (texto, titulos) = Sessao().contextoDasNotas(pergunta: "como treinar ao acordar?", conversa: [], no: c.mainContext)
            #expect(titulos == [n.aberta.tituloNaLista])
            #expect(!texto.contains("choro") && !texto.contains("fuga") && !texto.contains("vi o medo"))
        }
    }

    @Test func seloNoExportCompletoEmCadaEstado() throws {
        let n = quatroEstados()
        let url = try #require(Corpus.exportar(notas: [n.aberta, n.emCurso, n.selada, n.queimada]))
        let corpo = try String(contentsOf: url, encoding: .utf8)
        #expect(corpo.contains("quero começar a correr"))
        #expect(!corpo.contains("choro") && !corpo.contains("fuga"))
        #expect(corpo.contains("estado: selada") && corpo.contains("estado: queimada") && corpo.contains("vi o medo"))
    }

    @Test func seloNoMdDeCadaNotaEmCadaEstado() throws {
        try isolado { raiz in
            let curso = fatia("ainda escrevendo a dor", emCurso: true, gesto: .expressiva)
            let selada = fatia("dor selada", trancada: true, gesto: .expressiva)
            Corpus.escreverUma(curso, agregados: [curso, selada], em: raiz, geracao: 1)
            Corpus.escreverUma(selada, agregados: [curso, selada], em: raiz, geracao: 1)
            #expect(!FileManager.default.fileExists(atPath: md(curso.id).path))
            let texto = try String(contentsOf: md(selada.id), encoding: .utf8)
            #expect(texto.contains("estado: selada") && !texto.contains("dor selada"))
        }
    }

    @Test func selarPeloFechoTiraDoIndiceNaHora() throws {
        try isolado { _ in
            guard Indice.disponivel else { return }
            let c = try ModelContainer.traco(emMemoria: true)
            let s = Sessao()
            s.texto = "quero começar a correr de manhã cedo"
            #expect(s.salvar(no: c.mainContext))
            let uuid = try #require(s.notaUUID)
            Indice.atualizar(Sessao.paraIndice(try #require(Sessao.buscar(uuid: uuid, no: c.mainContext))))
            #expect(Indice.vetorGuardado(uuid) != nil)
            s.gesto = .expressiva
            s.timerLigado = true
            s.abrirFecho(no: c.mainContext)
            #expect(Indice.vetorGuardado(uuid) == nil)
        }
    }

    // MARK: - 4. recuperação no aparelho

    @Test func pastaIndisponivelGuardaSoNoAparelhoEDiz() throws {
        try isolado { raiz in
            let pasta = raiz.appendingPathComponent("espelho", isDirectory: true)
            try FileManager.default.createDirectory(at: pasta, withIntermediateDirectories: true)
            #expect(PastaEspelho.guardar(pasta))
            #expect(PastaEspelho.estado == nil)
            try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: pasta.path)
            defer { try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: pasta.path) }
            var gravou = false
            Corpus.escreverEspelho(fatias: [fatia("nota aberta")])
            PastaEspelho.comAcesso { _ in gravou = true }
            #expect(!gravou)
            #expect(PastaEspelho.nome == "espelho")
            #expect(PastaEspelho.estado?.hasSuffix("indisponível; guardando só no aparelho") == true)
            // o aparelho continuou guardando
            #expect(FileManager.default.fileExists(atPath: raiz.appendingPathComponent("traco-corpus.md").path))
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: pasta.path)
            PastaEspelho.comAcesso { _ in gravou = true }
            #expect(gravou && PastaEspelho.estado == nil)
        }
    }

    @Test func bookmarkInvalidoDizQueAPastaSumiu() throws {
        try isolado { _ in
            PastaEspelho.defaults.set(Data("não é um bookmark".utf8), forKey: PastaEspelho.chave)
            PastaEspelho.defaults.set("Traço no iCloud", forKey: PastaEspelho.chaveNome)
            PastaEspelho.comAcesso { _ in }
            #expect(PastaEspelho.nome == nil)
            #expect(PastaEspelho.estado == "a pasta “Traço no iCloud” não existe mais; guardando só no aparelho")
            // escolher outra pasta limpa a linha; parar também
            let outra = Corpus.diretorio.appendingPathComponent("outra", isDirectory: true)
            try FileManager.default.createDirectory(at: outra, withIntermediateDirectories: true)
            #expect(PastaEspelho.guardar(outra) && PastaEspelho.estado == nil)
            PastaEspelho.limpar()
            #expect(PastaEspelho.estado == nil)
        }
    }
}
