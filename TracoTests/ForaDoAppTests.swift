import AppIntents
import Foundation
import SwiftData
import Testing
import UserNotifications
@testable import Traco

/// ADR 2026-09-05u — a fundação fora do app: um snapshot versionado no App
/// Group escrito só pelo app, dois LiveActivityIntent com identidade e
/// confirmação real, entidades mínimas com selo. Tudo sem UI.
@MainActor
@Suite("Fora do app — fundação", .serialized)
struct ForaDoAppTests {
    /// Cada teste num App Group de mentira (pasta temporária), com os
    /// reloads contados e o estado do Destaque/soneca limpo antes e depois.
    private func isolado(_ corpo: (URL, Contador) async throws -> Void) async throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("fora-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let urlAntes = SuperficieDisco.url
        let recarregarAntes = SuperficieDisco.recarregar
        let centroAntes = Revisoes.centro
        let revisoesAntes = (SuperficieDisco.revisaoPublicada, SuperficieDisco.revisaoRecarregada)
        let contador = Contador()
        SuperficieDisco.url = raiz.appendingPathComponent("superficie.json")
        SuperficieDisco.recarregar = { contador.registrar($0) }
        limpar()
        defer {
            limpar()
            SuperficieDisco.url = urlAntes
            SuperficieDisco.recarregar = recarregarAntes
            Revisoes.centro = centroAntes
            (SuperficieDisco.revisaoPublicada, SuperficieDisco.revisaoRecarregada) = revisoesAntes
            try? FileManager.default.removeItem(at: raiz)
        }
        try await corpo(raiz, contador)
    }

    private func limpar() {
        let d = SuperficieDisco.defaults
        for c in [DestaqueDoDia.chaveLinha, DestaqueDoDia.chaveDia, DestaqueDoDia.chaveId,
                  DestaqueDoDia.chaveFeito, DestaqueDoDia.chaveFeitoId,
                  ProximoCompromisso.chaveSoneca, ProximoCompromisso.chaveSonecaEm] {
            d.removeObject(forKey: c)
        }
    }

    nonisolated final class Contador: @unchecked Sendable {
        private let tranca = NSLock()
        private(set) var chamadas: [Set<String>] = []
        func registrar(_ kinds: Set<String>) { tranca.lock(); chamadas.append(kinds); tranca.unlock() }
        var todos: [String] { chamadas.flatMap { $0.sorted() } }
        func zerar() { tranca.lock(); chamadas = []; tranca.unlock() }
    }

    private var hoje: String { Superficie.diaISO(.now) }
    private var ontem: String { Superficie.diaISO(Date().addingTimeInterval(-86400)) }

    private func lida() -> Superficie? {
        if case .disponivel(let s) = SuperficieDisco.ler() { return s }
        return nil
    }

    // MARK: - Snapshot

    @Test("grava atômico, com revisão, e autosave idêntico não regrava")
    func snapshotVersionado() async throws {
        try await isolado { _, contador in
            let id = UUID()
            DestaqueDoDia.gravar("correr antes do café", id: id)
            let s = try #require(lida())
            #expect(s.versao == Superficie.versaoAtual)
            #expect(s.revisao == 1)
            #expect(s.destaque == .init(id: id, dia: hoje, linha: "correr antes do café", feito: false))
            DestaqueDoDia.gravar("correr antes do café", id: id)
            #expect(lida()?.revisao == 1)
            DestaqueDoDia.gravar("outra", id: id)
            #expect(lida()?.revisao == 2)
            #expect(contador.chamadas.count == 2)
        }
    }

    /// F4-E: o mapa "kind afetado" era da F2, quando cada face lia METADE do
    /// documento. Desde a F4 o widget do Traço mostra a agenda e o do Próximo
    /// mostra o Destaque — as duas leem o documento inteiro, e recarregar só
    /// "quem mudou" deixava a agenda de ontem embaixo do Destaque de hoje.
    @Test("escrita real acorda as DUAS faces — as duas leem o documento inteiro")
    func reloadDasDuasFaces() async throws {
        try await isolado { _, contador in
            let ambas: [Set<String>] = [[SuperficieDisco.kindDestaque, SuperficieDisco.kindProximo]]
            DestaqueDoDia.gravar("a única", id: UUID())
            contador.zerar()
            DestaqueDoDia.gravar("a única, editada", id: DestaqueDoDia.idDeHoje()!)
            #expect(contador.chamadas == ambas)
            contador.zerar()
            ProximoCompromisso.gravar(.init(titulo: "Dentista", inicio: Date().addingTimeInterval(3600),
                                            fim: Date().addingTimeInterval(7200), diaInteiro: false))
            #expect(contador.chamadas == ambas)
            contador.zerar()
            ProximoCompromisso.gravar(nil)
            #expect(contador.chamadas == ambas)
            // e o que NÃO mudou continua não acordando ninguém: quem economiza
            // orçamento é a guarda do idêntico, e ela ficou onde estava
            contador.zerar()
            ProximoCompromisso.gravar(nil)
            #expect(contador.chamadas.isEmpty)
        }
    }

    /// O achado A do G4, de ponta a ponta: cinco compromissos no dia, três no
    /// documento e a conta dos dois que ficaram de fora. Sem ela a face fechava
    /// "+2 depois" num dia de cinco.
    @Test("cinco no dia: o documento carrega três E diz que faltam dois")
    func cincoDeCinco() async throws {
        try await isolado { _, contador in
            let agora = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
            let cinco = (0..<5).map { i in
                ProximoCompromisso.Fatia(titulo: "c\(i)", inicio: agora.addingTimeInterval(Double(i + 1) * 3600),
                                         fim: agora.addingTimeInterval(Double(i + 1) * 3600 + 1800),
                                         diaInteiro: false)
            }
            ProximoCompromisso.publicar(cinco, agora: agora)
            let s = try #require(lida())
            #expect(s.proximos.count == Superficie.candidatas)
            #expect(s.alemDaLista == 2)
            #expect(s.alem() == 2)
            // a face que mostra UM diz que vêm QUATRO — não dois
            #expect(Restantes.de(naFace: 1, publicados: s.proximos.count, alem: s.alem()).frase == "+4 depois")

            // o sexto compromisso não muda os três publicados, muda quantos
            // faltam — e a escrita NÃO pode ser descartada como "idêntica"
            contador.zerar()
            let seis = cinco + [ProximoCompromisso.Fatia(titulo: "c5", inicio: agora.addingTimeInterval(21600),
                                                         fim: agora.addingTimeInterval(23400), diaInteiro: false)]
            ProximoCompromisso.publicar(seis, agora: agora)
            #expect(lida()?.alemDaLista == 3)
            #expect(!contador.chamadas.isEmpty, "a face seguiria contando errado até a próxima escrita")
        }
    }

    @Test("App Group indisponível: nada confirma, e o widget lê 'indisponível'")
    func appGroupIndisponivel() async throws {
        try await isolado { _, _ in
            let id = UUID()
            DestaqueDoDia.gravar("a única", id: id)
            SuperficieDisco.url = nil
            #expect(SuperficieDisco.ler() == .indisponivel)
            #expect(!DestaqueDoDia.marcarFeito(id: id, dia: hoje))
            #expect(!DestaqueDoDia.feitoHoje())
            #expect(!ProximoCompromisso.publicar([]))
        }
    }

    @Test("snapshot truncado ou de outra versão é indisponível, nunca meia verdade")
    func snapshotTruncado() async throws {
        try await isolado { _, _ in
            DestaqueDoDia.gravar("a única", id: UUID())
            let url = try #require(SuperficieDisco.url)
            let inteiro = try Data(contentsOf: url)
            try inteiro.prefix(inteiro.count / 2).write(to: url)
            #expect(SuperficieDisco.ler() == .indisponivel)
            var texto = try #require(String(data: inteiro, encoding: .utf8))
            texto = texto.replacingOccurrences(of: "\"versao\":1", with: "\"versao\":99")
            try Data(texto.utf8).write(to: url)
            #expect(SuperficieDisco.ler() == .indisponivel)
        }
    }

    @Test("horizonte vencido é 'desatualizado'; lista vazia dentro do horizonte é 'nada marcado'")
    func snapshotExpirado() async throws {
        let agora = Date()
        let p = Superficie.Proximo(id: UUID(), titulo: "Dentista", inicio: agora.addingTimeInterval(3600),
                                   fim: agora.addingTimeInterval(7200), diaInteiro: false,
                                   aviso: nil, lembrarEm: nil, doSistema: false)
        let vencida = Superficie(geradoEm: agora.addingTimeInterval(-86400), validoAte: agora.addingTimeInterval(-60), proximos: [p])
        #expect(vencida.estadoDoProximo(agora: agora) == .desatualizado)
        let valida = Superficie(geradoEm: agora, validoAte: agora.addingTimeInterval(86400), proximos: [p])
        #expect(valida.estadoDoProximo(agora: agora) == .proximo(p))
        // depois do fim, e ainda no horizonte: nada marcado — não inventa o seguinte
        #expect(valida.estadoDoProximo(agora: agora.addingTimeInterval(7300)) == .vazio)
        // no instante exato do horizonte (a entrada da linha do tempo) já é velho
        #expect(valida.estadoDoProximo(agora: agora.addingTimeInterval(86400)) == .desatualizado)
        let vazia = Superficie(geradoEm: agora, validoAte: agora.addingTimeInterval(86400))
        #expect(vazia.estadoDoProximo(agora: agora) == .vazio)
    }

    @Test("D6: widget readicionado nunca mostra compromisso apagado")
    func apagadoNaoVolta() async throws {
        try await isolado { _, _ in
            let agora = Date()
            ProximoCompromisso.gravar(.init(titulo: "Dentista", inicio: agora.addingTimeInterval(3600),
                                            fim: agora.addingTimeInterval(7200), diaInteiro: false))
            #expect(ProximoCompromisso.lido(agora: agora)?.titulo == "Dentista")
            ProximoCompromisso.gravar(nil)
            let s = try #require(lida())
            #expect(s.proximos.isEmpty)
            #expect(s.estadoDoProximo(agora: agora) == .vazio)
            #expect(s.validoAte > agora.addingTimeInterval(13 * 86400))
            // e republicar o mesmo estado minutos depois não regrava (o widget
            // não é acordado à toa)
            ProximoCompromisso.gravar(nil, agora: agora.addingTimeInterval(300))
            #expect(lida()?.revisao == s.revisao)
            #expect(ProximoCompromisso.lido(agora: agora) == nil)
        }
    }

    @Test("linha do tempo curta: agora, cada fim, a soneca e o horizonte — nada por minuto")
    func linhaDoTempoCurta() async throws {
        try await isolado { _, _ in
            // segundos inteiros: o documento guarda datas em segundos
            let agora = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
            let tres = (0..<3).map { i in
                ProximoCompromisso.Fatia(titulo: "c\(i)", inicio: agora.addingTimeInterval(Double(i + 1) * 3600),
                                         fim: agora.addingTimeInterval(Double(i + 1) * 3600 + 1800), diaInteiro: false)
            }
            ProximoCompromisso.publicar(tres, agora: agora)
            let s = try #require(lida())
            // três candidatas = o horizonte é o fim da última: não sabemos o que vem depois
            #expect(s.validoAte == tres[2].fim)
            let datas = Superficie.transicoes(.disponivel(s), agora: agora)
            #expect(datas == [agora, tres[0].fim, tres[1].fim, tres[2].fim])
            ProximoCompromisso.publicar([tres[0]], agora: agora)
            let uma = try #require(lida())
            #expect(Superficie.transicoes(.disponivel(uma), agora: agora) == [agora, tres[0].fim, uma.validoAte])
            #expect(Superficie.transicoes(.indisponivel, agora: agora) == [agora])
        }
    }

    @Test("A1: reload recusado não some — a volta à cena repete o que não foi confirmado")
    func recargaNaVolta() async throws {
        try await isolado { _, contador in
            // arranque: nada confirmado (o processo anterior pode ter morrido
            // com o pedido recusado) — a primeira volta à cena pede os dois
            SuperficieDisco.revisaoPublicada = 0
            SuperficieDisco.revisaoRecarregada = -1
            #expect(SuperficieDisco.recarregarPendente())
            #expect(contador.chamadas == [[SuperficieDisco.kindDestaque, SuperficieDisco.kindProximo]])
            #expect(!SuperficieDisco.recarregarPendente())
            contador.zerar()
            // a escrita pede (e o WidgetKit pode recusar sem dizer); o autosave
            // idêntico não pede de novo — e é a volta à cena que repete
            let id = UUID()
            DestaqueDoDia.gravar("a única", id: id)
            DestaqueDoDia.gravar("a única", id: id)
            #expect(contador.chamadas.count == 1)
            #expect(SuperficieDisco.revisaoPublicada == 1)
            contador.zerar()
            #expect(SuperficieDisco.recarregarPendente())
            #expect(contador.chamadas == [[SuperficieDisco.kindDestaque, SuperficieDisco.kindProximo]])
            // confirmada: a próxima volta sem publicação nova não acorda ninguém
            #expect(!SuperficieDisco.recarregarPendente())
            #expect(contador.chamadas.count == 1)
        }
    }

    @Test("A2: a suíte não escreve no App Group real (arquivo, chaves, reload)")
    func suiteIsolada() throws {
        let real = try #require(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SuperficieDisco.grupo))
        let arquivo = real.appendingPathComponent("superficie.json")
        let grupo = try #require(UserDefaults(suiteName: SuperficieDisco.grupo))
        let arquivoAntes = try? Data(contentsOf: arquivo)
        let chavesAntes = [DestaqueDoDia.chaveLinha, DestaqueDoDia.chaveId, ProximoCompromisso.chaveSoneca]
            .map { grupo.string(forKey: $0) }
        // o ponto único do arranque (`TracoApp`) já desviou tudo
        #expect(SuperficieDisco.url?.path.hasPrefix(real.path) == false)
        #expect(!SuperficieDisco.atividades())
        let id = UUID()
        DestaqueDoDia.gravar("de teste", id: id)
        ProximoCompromisso.gravar(.init(titulo: "de teste", inicio: Date().addingTimeInterval(3600),
                                        fim: Date().addingTimeInterval(7200), diaInteiro: false))
        ProximoCompromisso.registrarSoneca(ocorrencia: "x", em: Date().addingTimeInterval(600))
        #expect(DestaqueDoDia.linhaDeHoje() == "de teste")
        #expect((try? Data(contentsOf: arquivo)) == arquivoAntes)
        #expect([DestaqueDoDia.chaveLinha, DestaqueDoDia.chaveId, ProximoCompromisso.chaveSoneca]
            .map { grupo.string(forKey: $0) } == chavesAntes)
        DestaqueDoDia.apagar(id: id)
        ProximoCompromisso.gravar(nil)
        ProximoCompromisso.esquecerSoneca()
    }

    // MARK: - Feito, com identidade

    @Test("feito repetido não inverte; desfazer é explícito")
    func feitoNaoAlterna() async throws {
        try await isolado { _, _ in
            let id = UUID()
            DestaqueDoDia.gravar("a única", id: id)
            #expect(DestaqueDoDia.marcarFeito(id: id, dia: hoje))
            #expect(DestaqueDoDia.marcarFeito(id: id, dia: hoje))
            #expect(DestaqueDoDia.feitoHoje())
            #expect(lida()?.destaque?.feito == true)
            #expect(DestaqueDoDia.desfazerFeito(id: id, dia: hoje))
            #expect(!DestaqueDoDia.feitoHoje())
            #expect(lida()?.destaque?.feito == false)
            #expect(!DestaqueDoDia.desfazerFeito(id: id, dia: hoje))
        }
    }

    @Test("cartão velho (outra nota, outro dia) não altera o Destaque de hoje")
    func cartaoVelho() async throws {
        try await isolado { _, _ in
            let atual = UUID()
            DestaqueDoDia.gravar("a de hoje", id: atual)
            #expect(!DestaqueDoDia.marcarFeito(id: UUID(), dia: hoje))
            #expect(!DestaqueDoDia.marcarFeito(id: atual, dia: ontem))
            #expect(!DestaqueDoDia.feitoHoje())
            #expect(lida()?.destaque?.feito == false)
            // pelo intent, com identidade errada: nada muda e nada quebra
            _ = try await DestaqueFeitoIntent(nota: UUID(), dia: hoje).perform()
            #expect(!DestaqueDoDia.feitoHoje())
            _ = try await DestaqueFeitoIntent(nota: atual, dia: hoje).perform()
            #expect(DestaqueDoDia.feitoHoje())
            _ = try await DestaqueDesfazerIntent(nota: atual, dia: hoje).perform()
            #expect(!DestaqueDoDia.feitoHoje())
        }
    }

    @Test("superfície recusada: o feito volta atrás e não confirma")
    func persistenciaRecusada() async throws {
        try await isolado { raiz, _ in
            let id = UUID()
            DestaqueDoDia.gravar("a única", id: id)
            // uma pasta no lugar do arquivo: a escrita atômica falha
            SuperficieDisco.url = raiz
            #expect(!DestaqueDoDia.marcarFeito(id: id, dia: hoje))
            #expect(!DestaqueDoDia.feitoHoje())
            SuperficieDisco.url = raiz.appendingPathComponent("superficie.json")
            #expect(lida()?.destaque?.feito == false)
        }
    }

    // MARK: - Soneca, pelo orçamento

    private struct Centro {
        static func fake(estado: Avisos.Estado = .concedido, livres: Int = 10,
                         adicionar: @escaping @Sendable (UNNotificationRequest) async throws -> Void = { _ in })
            -> Revisoes.CentroDeAvisos {
            .init(estado: { estado }, livres: { _ in livres }, adicionar: adicionar)
        }
    }

    struct Falha: Error {}

    /// Um compromisso no disco do calendário (o de verdade do processo de
    /// teste, guardado e devolvido) e publicado na superfície.
    private func comCompromisso(_ corpo: (ProximoCompromisso.Fatia, [EventoCalendario]) async throws -> Void) async throws {
        let url = CalendarioDisco.urlPadrao()
        let antes = try? Data(contentsOf: url)
        defer {
            if let antes { try? antes.write(to: url) } else { try? FileManager.default.removeItem(at: url) }
        }
        let agora = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
        let e = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(3600),
                                 fim: agora.addingTimeInterval(7200))
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try CalendarioDisco.gravar([e])
        let fatia = ProximoCompromisso.Fatia(id: e.id, titulo: e.titulo, inicio: e.inicio, fim: e.fim, diaInteiro: false)
        ProximoCompromisso.gravar(fatia, agora: agora)
        try await corpo(fatia, [e])
    }

    @Test("soneca negada, lotada ou falhada não anuncia hora nenhuma")
    func sonecaRecusada() async throws {
        try await isolado { _, _ in
            try await comCompromisso { f, _ in
                for centro in [Centro.fake(estado: .negado), Centro.fake(livres: 0),
                               Centro.fake(adicionar: { _ in throw Falha() })] {
                    Revisoes.centro = centro
                    await ProximoCompromisso.lembrarDepois(ocorrencia: f.ocorrencia, minutos: 10)
                    #expect(ProximoCompromisso.sonecaAtiva(ocorrencia: f.ocorrencia) == nil)
                    #expect(ProximoCompromisso.lido()?.lembrarEm == nil)
                }
                // e pelo intent, com o centro real e só a permissão injetada
                // (`naoPerguntado`): recusa, sem hora — em qualquer simulador
                Revisoes.centro = .init(estado: { .naoPerguntado }, livres: Revisoes.CentroDeAvisos.real.livres,
                                        adicionar: Revisoes.CentroDeAvisos.real.adicionar)
                _ = try await LembrarDepoisIntent(ocorrencia: f.ocorrencia).perform()
                #expect(ProximoCompromisso.lido()?.lembrarEm == nil)
            }
        }
    }

    @Test("soneca aceita: guardada, publicada, e repetir substitui em vez de duplicar")
    func sonecaAceita() async throws {
        try await isolado { _, _ in
            try await comCompromisso { f, _ in
                let pedidos = Contador()
                Revisoes.centro = Centro.fake(adicionar: { r in pedidos.registrar([r.identifier]) })
                await ProximoCompromisso.lembrarDepois(ocorrencia: f.ocorrencia, minutos: 10)
                let quando = try #require(ProximoCompromisso.sonecaAtiva(ocorrencia: f.ocorrencia))
                #expect(abs(quando.timeIntervalSinceNow - 600) < 5)
                #expect(ProximoCompromisso.lido()?.lembrarEm == quando)
                await ProximoCompromisso.lembrarDepois(ocorrencia: f.ocorrencia, minutos: 10)
                #expect(pedidos.todos == [Revisoes.idDaSoneca(f.ocorrencia), Revisoes.idDaSoneca(f.ocorrencia)])
                #expect(lida()?.proximos.count == 1)
            }
        }
    }

    @Test("ocorrência velha não agenda: o centro nem é chamado")
    func ocorrenciaVelha() async throws {
        try await isolado { _, _ in
            try await comCompromisso { f, _ in
                let pedidos = Contador()
                Revisoes.centro = Centro.fake(adicionar: { r in pedidos.registrar([r.identifier]) })
                let velha = Superficie.ocorrencia(f.id, f.inicio.addingTimeInterval(-86400))
                await ProximoCompromisso.lembrarDepois(ocorrencia: velha, minutos: 10)
                await ProximoCompromisso.lembrarDepois(ocorrencia: Superficie.ocorrencia(UUID(), f.inicio), minutos: 10)
                #expect(pedidos.chamadas.isEmpty)
                #expect(ProximoCompromisso.lido()?.lembrarEm == nil)
            }
        }
    }

    @Test("corrida: o editor apaga o compromisso durante o await — a soneca não fica")
    func corridaComEditor() async throws {
        try await isolado { _, _ in
            try await comCompromisso { f, _ in
                Revisoes.centro = Centro.fake(adicionar: { _ in
                    // outro editor, no meio do caminho
                    try CalendarioDisco.gravar([])
                })
                await ProximoCompromisso.lembrarDepois(ocorrencia: f.ocorrencia, minutos: 10)
                #expect(ProximoCompromisso.sonecaAtiva(ocorrencia: f.ocorrencia) == nil)
                #expect(ProximoCompromisso.lido()?.lembrarEm == nil)
            }
        }
    }

    // MARK: - Entidades, com selo

    private func comDisco(_ corpo: (ModelContext) async throws -> Void) async throws {
        let antes = DiscoTraco.compartilhado
        let c = try ModelContainer.traco(emMemoria: true)
        DiscoTraco.compartilhado = c
        defer { DiscoTraco.compartilhado = antes }
        let ctx = ModelContext(c)
        try await corpo(ctx)
    }

    @Test("o selo entra antes de qualquer representação")
    func seloNasEntidades() async throws {
        try await comDisco { ctx in
            let aberta = Nota(texto: "a aberta")
            let selada = Nota(texto: "a selada", trancada: true)
            let queimada = Nota(texto: "a queimada", queimada: true)
            let expressiva = Nota(texto: "a dor", gesto: .expressiva)
            for n in [aberta, selada, queimada, expressiva] { ctx.insert(n) }
            let daAberta = try Trabalho(documento: DocumentoTrabalho(intencao: "do aberto", notaOrigemID: aberta.uuid))
            let daSelada = try Trabalho(documento: DocumentoTrabalho(intencao: "do selado", notaOrigemID: selada.uuid))
            let semOrigem = try Trabalho(documento: DocumentoTrabalho(intencao: "solto"))
            for t in [daAberta, daSelada, semOrigem] { ctx.insert(t) }
            try ctx.save()

            #expect(NotaEntity.publicas().map(\.id) == [aberta.uuid])
            #expect(try await NotaQuery().entities(matching: "sel").isEmpty)
            #expect(try await NotaQuery().entities(for: [selada.uuid, queimada.uuid]).isEmpty)
            #expect(Set(TrabalhoEntity.permitidos().map(\.id)) == [daAberta.uuid, semOrigem.uuid])
            #expect(try await TrabalhoQuery().entities(for: [daSelada.uuid]).isEmpty)
        }
    }

    @Test("compromisso: só o que o autor marcou — deixa e projeção do Trabalho ficam com os donos")
    func compromissoSoDoAutor() async throws {
        let url = CalendarioDisco.urlPadrao()
        let antes = try? Data(contentsOf: url)
        defer {
            if let antes { try? antes.write(to: url) } else { try? FileManager.default.removeItem(at: url) }
        }
        let agora = Date()
        let meu = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(3600), fim: agora.addingTimeInterval(7200))
        let deixa = EventoCalendario(titulo: "correr", inicio: agora.addingTimeInterval(1800), fim: agora.addingTimeInterval(3000), origem: UUID())
        let doTrabalho = EventoCalendario(titulo: "ação", inicio: agora.addingTimeInterval(1800), fim: agora.addingTimeInterval(3000), origemTrabalho: UUID())
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try CalendarioDisco.gravar([meu, deixa, doTrabalho])
        let vistos = CompromissoEntity.proximos(agora: agora)
        #expect(vistos.map(\.compromisso) == [meu.id])
        #expect(vistos.first?.id == Superficie.ocorrencia(meu.id, meu.inicio))
    }

    @Test("proteção depois da consulta: o intent revalida e não abre")
    func protecaoDepoisDaQuery() async throws {
        try await comDisco { ctx in
            Rota.pendente = nil
            let nota = Nota(texto: "a aberta")
            ctx.insert(nota)
            try ctx.save()
            let entidade = try #require(NotaEntity.publicas().first)
            // a rota é decidida aqui (o host de teste tem a PaginaView viva e
            // consumiria `Rota.pendente` no mesmo instante)
            #expect(AbrirNotaIntent.destino(entidade) == .nota(nota.uuid))
            // selada DEPOIS de o sistema ter a entidade na mão
            nota.trancada = true
            try ctx.save()
            #expect(AbrirNotaIntent.destino(entidade) == nil)
            let abrir = AbrirNotaIntent()
            abrir.nota = entidade
            _ = try await abrir.perform()
            #expect(Rota.pendente == nil)
        }
    }


    // MARK: - Captação em um toque (ADR 05w)

    @Test("arranque frio: a rota fica guardada sem ninguém ouvindo e é consumida UMA vez")
    func rotaPendenteUmaVez() async throws {
        Rota.pendente = nil
        // ninguém ouve: é o intent correndo antes da cena (a suíte roda dentro
        // do app vivo, então o anúncio real seria consumido na hora pela Página)
        let anunciarAntes = Rota.anunciar
        Rota.anunciar = {}
        defer { Rota.anunciar = anunciarAntes }
        Rota.ir(.captura(ditado: true))
        #expect(Rota.pendente == .captura(ditado: true))
        #expect(Rota.consumir() == .captura(ditado: true))
        #expect(Rota.consumir() == nil)
        #expect(Rota.pendente == nil)
        // a última vence: duas aberturas seguidas não enfileiram
        Rota.ir(.notas)
        Rota.ir(.captura(ditado: false))
        #expect(Rota.consumir() == .captura(ditado: false))
        #expect(Rota.consumir() == nil)
    }

    @Test("o intent de abertura só executa no app; na extensão recusa e não deixa rota")
    func capturarSoNoApp() async throws {
        Rota.pendente = nil
        let anunciarAntes = Rota.anunciar
        Rota.anunciar = {}
        defer { Rota.anunciar = anunciarAntes }
        Rota.ditadoPendente = false
        #expect(throws: ForaDoAlvo.self) { try CapturarIntent.executar(noApp: false) }
        #expect(Rota.pendente == nil)
        #expect(!Rota.ditadoPendente)
        #expect(CapturarIntent.noApp)
        _ = try await CapturarIntent().perform()
        // ADR 06c: o controle abre GRAVANDO, não com o teclado pronto — e o
        // ditado corre por canal próprio, que a Página (só `Destino`) ignora
        #expect(Rota.consumir() == nil)
        #expect(Rota.consumirDitado())
        #expect(!Rota.consumirDitado())
        #expect(CapturarIntent.openAppWhenRun)
    }

    // MARK: - Captação

    @Test("anotar distingue vazio de falha de gravação; 'anotado' é depósito confirmado")
    func anotarHonesto() async throws {
        let antes = Corpus.diretorio
        defer { Corpus.diretorio = antes }
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("anotar-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: raiz) }
        Corpus.diretorio = raiz

        #expect(AnotarIntent.anotar("   ") == .vazio)
        let pasta = Entrada.raizDoApp.appendingPathComponent(Entrada.subpasta)
        #expect(!FileManager.default.fileExists(atPath: pasta.path))

        // um ARQUIVO no lugar da pasta do app: nada consegue ser escrito
        try Data("x".utf8).write(to: raiz.appendingPathComponent("Traço"))
        #expect(AnotarIntent.anotar("ligar para o dentista") == .falhou)
        let falha = AnotarIntent()
        falha.texto = "ligar para o dentista"
        // o perform() na falha não deposita nada: "anotado" nunca sai daqui
        _ = try await falha.perform()
        #expect(Entrada.recolher(raizes: [Entrada.raizDoApp]).isEmpty)
        try FileManager.default.removeItem(at: raiz.appendingPathComponent("Traço"))

        #expect(AnotarIntent.anotar("ligar para o dentista") == .anotado)
        #expect(AnotarIntent.Resposta.vazio.fala != AnotarIntent.Resposta.falhou.fala)
        let ok = AnotarIntent()
        ok.texto = "e o pão"
        _ = try await ok.perform()
        let itens = Entrada.recolher(raizes: [Entrada.raizDoApp])
        #expect(itens.map(\.texto).sorted() == ["e o pão", "ligar para o dentista"])
    }
}
