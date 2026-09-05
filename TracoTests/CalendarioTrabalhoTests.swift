import Foundation
import SwiftData
import Testing
@testable import Traco

@MainActor
struct CalendarioTrabalhoTests {
    private let instante = Date(timeIntervalSince1970: 1_800_000_000)
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!) }

    private func exemplo() throws -> (ModelContainer, Nota, Trabalho, UUID) {
        let container = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "Intenção de origem")
        container.mainContext.insert(nota)
        var d = DocumentoTrabalho(intencao: nota.texto, notaOrigemID: nota.uuid)
        try d.guardarVersaoHumana("Material que não deve sair no calendário")
        try d.prepararAcao("Ensaiar a abertura")
        let id = try #require(d.acoes.first?.id)
        try d.agendar(id, para: instante)
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        return (container, nota, trabalho, id)
    }

    @Test func agendaMostraPontoEAbreAcaoNoTrabalhoSemFicha() throws {
        let (container, _, trabalho, acaoID) = try exemplo()
        let agenda = CalendarioAgenda(agora: instante, cal: cal, eventos: [])
        agenda.acoesDosTrabalhos = CalendarioTrabalho.eventos([trabalho], no: container.mainContext)
        let e = try #require(agenda.eventos(no: instante).first)
        #expect(e.id == acaoID && e.origemTrabalho == trabalho.uuid)
        #expect(e.inicio == instante && e.fim == instante && e.duracaoMinutos == 0)
        #expect(e.notas.isEmpty && e.origem == nil && e.avisoMinutos == 0) // ADR 05n: o padrão 'na hora' projeta
        #expect(Calendario.intervalo(e, cal) == Calendario.horaCurta(instante, cal))
        var destino: (UUID, UUID)?
        agenda.aoAbrirTrabalho = { destino = ($0, $1) }
        agenda.abrir(e)
        #expect(destino?.0 == trabalho.uuid && destino?.1 == acaoID)
        #expect(agenda.ficha == nil && agenda.fichaDoSistema == nil)
        #expect(agenda.eventos.isEmpty)
    }

    @Test func reagendarReprojetaMesmaIdentidadeERemoverPreservaAcao() throws {
        let (container, _, trabalho, id) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let antes = oficina.documento
        let nova = instante.addingTimeInterval(86_400)
        #expect(oficina.alterar { try $0.agendar(id, para: nova) })
        for _ in 0..<3 {
            let eventos = CalendarioTrabalho.eventos([trabalho], no: container.mainContext)
            #expect(eventos.count == 1 && eventos.first?.id == id && eventos.first?.inicio == nova)
        }
        #expect(oficina.alterar { try $0.agendar(id, para: nil) })
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).isEmpty)
        var esperado = antes
        try esperado.agendar(id, para: nil)
        #expect(oficina.documento == esperado)
    }

    @Test func falhaDeCommitMantemHorarioConfirmadoENaoProjetaRascunho() throws {
        enum Falha: Error { case disco }
        let (container, _, trabalho, id) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let nova = instante.addingTimeInterval(86_400)
        oficina.persistir = { _ in throw Falha.disco }
        #expect(!oficina.alterar { try $0.agendar(id, para: nova) })
        #expect(oficina.documento.acoes.first?.agendadaEm == nova)
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).first?.inicio == instante)
        oficina.persistir = { try $0.save() }
        #expect(oficina.guardar())
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).first?.inicio == nova)
    }

    @Test func protecaoDaOrigemRemoveTodaProjecaoERestauracaoNaoDuplica() throws {
        for tipo in ["selada", "queimada", "expressiva", "apagada"] {
            let (container, nota, trabalho, id) = try exemplo()
            let antes = trabalho.conteudoJSON
            switch tipo {
            case "selada": nota.trancada = true
            case "queimada": nota.queimada = true
            case "expressiva": nota.gesto = .expressiva
            default: container.mainContext.delete(nota)
            }
            try container.mainContext.save()
            #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).isEmpty)
            #expect(trabalho.conteudoJSON == antes)
            if tipo != "apagada" {
                nota.trancada = false
                nota.queimada = false
                nota.gesto = nil
                try container.mainContext.save()
                let volta = CalendarioTrabalho.eventos([trabalho], no: container.mainContext)
                #expect(volta.count == 1 && volta.first?.id == id)
            }
        }
    }

    @Test func agregadoIlegivelNaoCriaEventoNemEReescrito() throws {
        let (container, _, trabalho, _) = try exemplo()
        trabalho.conteudoJSON = Data("corrompido".utf8)
        let antes = trabalho.conteudoJSON
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).isEmpty)
        #expect(trabalho.conteudoJSON == antes)
    }

    @Test func encerrarTrabalhoNaoCancelaPendenciaEFusoNaoAlteraInstante() throws {
        let (container, _, trabalho, id) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        #expect(oficina.alterar { $0.encerrado = true })
        let antes = trabalho.conteudoJSON
        let e = try #require(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).first)
        let outroFuso = Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: -10_800)!)
        #expect(Calendario.intervalo(e, cal) != Calendario.intervalo(e, outroFuso))
        #expect(e.inicio == instante && e.id == id)
        #expect(trabalho.conteudoJSON == antes)
        #expect(oficina.documento.acoes[0].estado == .pendente)
    }

    @Test func trabalhoIndependenteNaoDependeDeNotaExistente() throws {
        let container = try ModelContainer.traco(emMemoria: true)
        var documento = DocumentoTrabalho(intencao: "Criado diretamente")
        try documento.prepararAcao("Fazer a primeira tentativa")
        try documento.agendar(documento.acoes[0].id, para: instante)
        let trabalho = try Trabalho(documento: documento)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).count == 1)
    }

    @Test func derivadaNaoViraCompromissoNoEncodeDiscoOuPublicacao() throws {
        let (container, _, trabalho, _) = try exemplo()
        let e = try #require(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).first)
        #expect(!e.editavel)
        #expect(throws: EncodingError.self) { try JSONEncoder().encode(e) }
        let pasta = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: pasta) }
        let url = pasta.appendingPathComponent("calendario.json")
        let proprio = EventoCalendario(titulo: "Compromisso próprio", inicio: instante.addingTimeInterval(60),
            fim: instante.addingTimeInterval(120))
        try CalendarioDisco.gravar([e, proprio], em: url)
        guard case .eventos(let lidos) = CalendarioDisco.carregar(de: url) else {
            Issue.record("Calendário próprio deveria ser legível")
            return
        }
        #expect(lidos.map(\.id) == [proprio.id])
        let agenda = CalendarioAgenda(agora: instante, cal: cal, disco: url, eventos: [])
        agenda.guardar(e)
        #expect(agenda.eventos.isEmpty)
        let fatia = ProximoCompromisso.proximaFatia([e, proprio], cal: cal, manha: 8,
            agora: instante.addingTimeInterval(-60))
        #expect(fatia?.id == proprio.id)
        #expect(ProximoCompromisso.proximaFatia([e], cal: cal, manha: 8,
            agora: instante.addingTimeInterval(-60)) == nil)
    }

    @Test func execucaoSaiDaAgendaMasNaoCriaResultadoEDataPodeSerRemovida() throws {
        let (container, _, trabalho, id) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        #expect(oficina.alterar { try $0.marcarExecutada(id) })
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).isEmpty)
        #expect(oficina.documento.evidencias.isEmpty && oficina.documento.hipoteses.isEmpty)
        let executada = oficina.documento.acoes[0]
        #expect(!oficina.alterar { try $0.agendar(id, para: instante.addingTimeInterval(60)) })
        #expect(oficina.documento.acoes[0] == executada)
        #expect(oficina.alterar { try $0.agendar(id, para: nil) })
        #expect(oficina.documento.acoes[0].estado == .executada)
        #expect(oficina.documento.acoes[0].executadaEm == executada.executadaEm)
        #expect(oficina.documento.acoes[0].artefatoID == executada.artefatoID)
    }

    @Test func dataPassadaERelatoNaoExecutamEAcaoCanceladaNaoReagenda() throws {
        let (container, _, trabalho, id) = try exemplo()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let passada = Date(timeIntervalSince1970: 0)
        #expect(oficina.alterar {
            try $0.agendar(id, para: passada)
            try $0.registrarRelato("Foi difícil começar", acaoID: id)
        })
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).first?.inicio == passada)
        #expect(oficina.documento.acoes[0].estado == .pendente)
        #expect(oficina.documento.acoes[0].executadaEm == nil)
        #expect(oficina.alterar { $0.acoes[0].estado = .cancelada })
        #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).isEmpty)
        #expect(!oficina.alterar { try $0.agendar(id, para: instante) })
        #expect(oficina.alterar { try $0.agendar(id, para: nil) })
        #expect(oficina.documento.evidencias.count == 1)
    }
}

/// ADR 2026-09-05n — a ação do Trabalho avisa. O horário e o aviso moram na
/// ação; o motor arma UMA notificação depois do commit e cala em toda saída.
/// Limite: o centro de notificações do simulador não é exercitado aqui
/// (a permissão é diálogo do iOS); o que se prova é o id, o instante, o disco
/// e a reconciliação da Oficina com o motor injetado.
@MainActor
struct AvisoDaAcaoTests {
    private let instante = Date(timeIntervalSince1970: 1_800_000_000)

    private func aberto() throws -> (ModelContainer, Trabalho, OficinaTrabalho, UUID, Registro) {
        let container = try ModelContainer.traco(emMemoria: true)
        var d = DocumentoTrabalho(intencao: "Apresentar a ideia")
        try d.prepararAcao("Ensaiar a abertura")
        let id = try #require(d.acoes.first?.id)
        let trabalho = try Trabalho(documento: d)
        container.mainContext.insert(trabalho)
        try container.mainContext.save()
        let oficina = try OficinaTrabalho(trabalho: trabalho, context: container.mainContext)
        let registro = Registro()
        oficina.armarAviso = { acao, _ in registro.armadas.append(acao); return registro.resposta }
        oficina.desarmarAviso = { registro.desarmadas.append($0) }
        return (container, trabalho, oficina, id, registro)
    }

    final class Registro {
        var armadas: [DocumentoTrabalho.Acao] = []
        var desarmadas: [UUID] = []
        var resposta: ResultadoDoAviso = .agendado(Date(timeIntervalSince1970: 1_799_998_200))
    }

    private func esperar(_ o: OficinaTrabalho, _ id: UUID) async {
        for _ in 0..<20 where o.avisos[id] == nil { await Task.yield() }
    }

    @Test func chaveAusenteDecodificaComoSemAlertaEV4Continua() throws {
        var d = DocumentoTrabalho(intencao: "Antiga")
        try d.prepararAcao("Ação de antes")
        try d.agendar(d.acoes[0].id, para: instante, aviso: 30)
        var json = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(d)) as? [String: Any])
        var acoes = try #require(json["acoes"] as? [[String: Any]])
        acoes[0].removeValue(forKey: "avisoMinutos")
        json["acoes"] = acoes
        let lido = try JSONDecoder().decode(DocumentoTrabalho.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(lido.acoes[0].avisoMinutos == nil)
        #expect(lido.acoes[0].agendadaEm == d.acoes[0].agendadaEm)
        try lido.validar()
        #expect(Revisoes.instanteDaAcao(lido.acoes[0]) == nil) // sem alerta, como prometido
    }

    @Test func agendarGravaAvisoDaListaFechadaESemHorarioNaoHaAviso() throws {
        var d = DocumentoTrabalho(intencao: "Nova")
        try d.prepararAcao("Ligar para o cliente")
        let id = d.acoes[0].id
        try d.agendar(id, para: instante, aviso: 30)
        #expect(d.acoes[0].avisoMinutos == 30)
        #expect(Revisoes.instanteDaAcao(d.acoes[0]) == instante.addingTimeInterval(-1800))
        try d.agendar(id, para: instante)
        #expect(d.acoes[0].avisoMinutos == 0) // padrão "na hora"
        try d.agendar(id, para: instante, aviso: 7) // fora da lista: volta ao padrão
        #expect(d.acoes[0].avisoMinutos == 0)
        try d.agendar(id, para: instante, aviso: nil)
        #expect(d.acoes[0].avisoMinutos == nil && Revisoes.instanteDaAcao(d.acoes[0]) == nil)
        try d.agendar(id, para: nil, aviso: 30)
        #expect(d.acoes[0].avisoMinutos == nil)
        let volta = try JSONDecoder().decode(DocumentoTrabalho.self, from: JSONEncoder().encode(d))
        #expect(volta == d)
        #expect(Revisoes.idDaAcao(id) == "acao-\(id.uuidString)")
        #expect(Revisoes.idDaAcao(id) != Revisoes.idDoCompromisso(id)) // namespace próprio
    }

    @Test func agendarArmaDepoisDoCommitEAFolhaRecebeOEstado() async throws {
        let (_, _, o, id, r) = try aberto()
        #expect(o.alterar { try $0.agendar(id, para: instante, aviso: 30) })
        await esperar(o, id)
        #expect(r.armadas.map(\.id) == [id] && r.armadas.first?.avisoMinutos == 30)
        #expect(o.avisos[id] == .agendado(Date(timeIntervalSince1970: 1_799_998_200)))
    }

    @Test func executarCancelarRetirarZeramECalam() async throws {
        for saida in ["executar", "cancelar", "retirar"] {
            let (container, trabalho, o, id, r) = try aberto()
            #expect(o.alterar { try $0.agendar(id, para: instante, aviso: 15) })
            await esperar(o, id)
            switch saida {
            case "executar": #expect(o.alterar { try $0.marcarExecutada(id) })
            case "cancelar": #expect(o.alterar { $0.acoes[0].estado = .cancelada })
            default: #expect(o.alterar { try $0.agendar(id, para: nil) })
            }
            #expect(r.desarmadas == [id], "saída: \(saida)")
            #expect(o.avisos[id] == nil, "saída: \(saida)")
            #expect(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).isEmpty)
            if saida == "retirar" { #expect(o.documento.acoes[0].avisoMinutos == nil) }
        }
    }

    @Test func mudarHorarioReagendaEFalhaDeCommitNaoArma() async throws {
        enum Falha: Error { case disco }
        let (_, _, o, id, r) = try aberto()
        #expect(o.alterar { try $0.agendar(id, para: instante, aviso: 0) })
        await esperar(o, id)
        o.persistir = { _ in throw Falha.disco }
        #expect(!o.alterar { try $0.agendar(id, para: instante.addingTimeInterval(3600), aviso: 60) })
        #expect(r.armadas.count == 1) // o disco recusou: nada muda no iPhone
        o.persistir = { try $0.save() }
        #expect(o.guardar())
        for _ in 0..<20 where r.armadas.count < 2 { await Task.yield() }
        #expect(r.armadas.count == 2 && r.armadas.last?.avisoMinutos == 60)
        #expect(r.desarmadas.isEmpty) // reagendar é do motor (cancela e arma no mesmo id)
    }

    @Test func projecaoLevaOAvisoEContinuaSoLeitura() throws {
        let (container, trabalho, o, id, _) = try aberto()
        #expect(o.alterar { try $0.agendar(id, para: instante, aviso: 30) })
        let e = try #require(CalendarioTrabalho.eventos([trabalho], no: container.mainContext).first)
        #expect(e.avisoMinutos == 30 && e.id == id && !e.editavel)
        #expect(throws: EncodingError.self) { try JSONEncoder().encode(e) }
    }

    @Test func semPermissaoESemEspacoChegamAFolhaSemMudarODocumento() async throws {
        for resposta in [ResultadoDoAviso.semPermissao, .semEspaco, .passou] {
            let (_, trabalho, o, id, r) = try aberto()
            r.resposta = resposta
            #expect(o.alterar { try $0.agendar(id, para: instante, aviso: 5) })
            await esperar(o, id)
            #expect(o.avisos[id] == resposta)
            #expect(try trabalho.ler().acoes[0].avisoMinutos == 5) // a escolha fica; o estado é honesto
        }
    }

    @Test func aoAbrirAFolhaLeOEstadoRealDoAvisoENaoOQuePediu() async throws {
        let (_, _, o, id, _) = try aberto()
        #expect(o.alterar { try $0.agendar(id, para: instante, aviso: 30) })
        await esperar(o, id)
        let toca = instante.addingTimeInterval(-1800)
        let antes = instante.addingTimeInterval(-7200)
        // nada no centro e o iPhone negando: a folha NÃO promete "Toca"
        o.lerPendentes = { [] }
        o.lerPermissao = { .negado }
        await o.lerAvisos(agora: antes)
        #expect(o.avisos[id] == .semPermissao && o.permissaoNegada)
        // no centro e permitido: a promessa é verdade
        o.lerPendentes = { [id] }
        o.lerPermissao = { .concedido }
        await o.lerAvisos(agora: antes)
        #expect(o.avisos[id] == .agendado(toca) && !o.permissaoNegada)
        // permitido, fora do centro, hora vencida
        o.lerPendentes = { [] }
        await o.lerAvisos(agora: instante)
        #expect(o.avisos[id] == .passou)
        // permitido, fora do centro, hora futura: não está armado, e a folha diz
        await o.lerAvisos(agora: antes)
        #expect(o.avisos[id] == .semAviso)
        // ação sem aviso não ganha linha de estado nenhuma
        #expect(o.alterar { try $0.agendar(id, para: instante, aviso: nil) })
        await o.lerAvisos(agora: antes)
        #expect(o.avisos.isEmpty)
    }

    @Test func selarQueimarOuApagarAOrigemCalaOAvisoDaAcaoNoAto() throws {
        let anterior = Revisoes.calarTrabalho
        defer { Revisoes.calarTrabalho = anterior }
        for rota in ["selar", "queimar", "apagar"] {
            let container = try ModelContainer.traco(emMemoria: true)
            let ctx = container.mainContext
            let nota = Nota(texto: "Frase privada identificável")
            ctx.insert(nota)
            var d = DocumentoTrabalho(intencao: nota.texto, notaOrigemID: nota.uuid)
            try d.prepararAcao("Ligar para o cliente")
            try d.agendar(d.acoes[0].id, para: instante, aviso: 30)
            let trabalho = try Trabalho(documento: d)
            ctx.insert(trabalho)
            // um Trabalho de outra origem não pode ser calado junto
            let outro = try Trabalho(documento: DocumentoTrabalho(intencao: "Outro", notaOrigemID: UUID()))
            ctx.insert(outro)
            try ctx.save()
            #expect(AcessoTrabalho.derivados(daNota: nota.uuid, no: ctx) == [trabalho.uuid])

            var calados: [UUID] = []
            Revisoes.calarTrabalho = { calados.append($0) }
            let s = Sessao()
            s.abrir(nota)
            switch rota {
            case "selar": #expect(s.salvar(no: ctx, trancar: true))
            case "queimar": s.gesto = .expressiva; #expect(s.queimar(no: ctx, sentido: "corte"))
            default: s.apagar(uuid: nota.uuid, no: ctx)
            }
            #expect(calados == [trabalho.uuid], "rota: \(rota)")
            #expect(!AcessoTrabalho.permitido(trabalho, no: ctx), "rota: \(rota)")
        }
    }

    @Test func toqueNaNotificacaoExpiraENaoAbreOTrabalhoHorasDepois() {
        let trabalho = UUID(), acao = UUID()
        Revisoes.acaoDaNotificacao = (trabalho, acao)
        #expect(Revisoes.acaoDaNotificacao?.acao == acao)
        Revisoes.acaoTocada = (trabalho, acao, Date.now.addingTimeInterval(-Revisoes.validadeDoToque - 1))
        #expect(Revisoes.acaoDaNotificacao == nil)
    }

    @Test func toqueNaNotificacaoUsaARotaDaProjecao() {
        let agenda = CalendarioAgenda(agora: instante, eventos: [])
        let trabalho = UUID(), acao = UUID()
        var destino: (UUID, UUID)?
        Revisoes.acaoDaNotificacao = (trabalho, acao)
        agenda.aoAbrirTrabalho = { destino = ($0, $1) } // a agenda ganha quem abre: consome
        #expect(destino?.0 == trabalho && destino?.1 == acao)
        #expect(Revisoes.acaoDaNotificacao == nil)
        destino = nil
        Revisoes.acaoDaNotificacao = (trabalho, acao)
        NotificationCenter.default.post(name: Revisoes.abrirCompromisso, object: nil) // já no calendário
        #expect(destino?.1 == acao)
    }
}
