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
        #expect(e.notas.isEmpty && e.origem == nil && e.avisoMinutos == nil)
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
