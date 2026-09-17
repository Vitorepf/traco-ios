import Foundation
import SwiftData
import Testing

@testable import Traco

/// Auditoria 17/09 — os defeitos que nasciam de `salvar` correr a cada troca
/// de cena (troca de aba, tela bloqueada, app ao fundo) e reaplicar as
/// projeções como se fosse edição, e os do fecho da expressiva num processo
/// em que o relógio nunca correu. Cada teste nomeia o que o autor via na tela.
@MainActor
@Suite("Gravar sem edição", .serialized)
struct GravarSemEdicaoTests {
    private func limparDestaque() {
        let d = SuperficieDisco.defaults
        for c in [DestaqueDoDia.chaveLinha, DestaqueDoDia.chaveDia, DestaqueDoDia.chaveId,
                  DestaqueDoDia.chaveFeito, DestaqueDoDia.chaveFeitoId] {
            d.removeObject(forKey: c)
        }
    }

    /// Abrir o Destaque de outro dia SÓ PARA RELER carimbava a linha dele com
    /// o dia da gravação e roubava «a única coisa de hoje» da tela bloqueada,
    /// do widget e da Ilha.
    @Test func relerUmDestaqueVelhoNaoRoubaAUnicaDeHoje() throws {
        limparDestaque()
        defer { limparDestaque() }
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .destaque
        s.campos = ["unica": "fechar a auditoria"]
        #expect(s.salvar(no: c.mainContext))
        let deHoje = try #require(s.notaUUID)
        #expect(DestaqueDoDia.linhaDeHoje() == "fechar a auditoria")

        let velha = Nota(texto: "", gesto: .destaque, campos: ["unica": "ligar para o contador"])
        c.mainContext.insert(velha)
        try c.mainContext.save()
        s.novaPagina()
        s.abrir(velha)
        #expect(s.salvar(no: c.mainContext)) // a troca de aba / o bloqueio de tela

        #expect(DestaqueDoDia.linhaDeHoje() == "fechar a auditoria")
        #expect(DestaqueDoDia.idDeHoje() == deHoje)
    }

    /// ADR 02e: o aviso do «Se» «não tem recorrência». A notificação abre a
    /// nota; ler e sair reagendava o aviso para a próxima ocorrência, todo dia.
    @Test func gravarSemEdicaoNaoReagendaOAvisoDoSe() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "escrever três linhas"
        s.gesto = .seEntao
        s.campos = ["se": "às 19h", "entao": "escrevo três linhas"]
        #expect(s.salvar(no: c.mainContext))
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.gatilhoEm != nil)

        // o aviso já tocou: a data é a da ocorrência que passou
        let tocado = Date(timeIntervalSince1970: 1_000_000)
        nota.gatilhoEm = tocado
        try c.mainContext.save()
        #expect(s.salvar(no: c.mainContext))
        #expect(nota.gatilhoEm == tocado)
    }

    /// ADR 08u: a tela bloqueada e o aviso do «Se» declaram a mente do autor.
    /// A nota que o bot deixou em `entrada/` fica no caderno e cala nas duas.
    @Test func aVozDoBotNaoFalaPelaTelaBloqueadaNemPeloAviso() throws {
        limparDestaque()
        defer { limparDestaque() }
        let c = try ModelContainer.traco(emMemoria: true)
        let destaque = Nota(texto: "", gesto: .destaque, campos: ["unica": "o bot achou isto"])
        destaque.origem = .grokbot
        let seEntao = Nota(texto: "ligar para o cliente", gesto: .seEntao,
                           campos: ["se": "às 9h", "entao": "ligo para o cliente"])
        seEntao.origem = .grokbot
        c.mainContext.insert(destaque)
        c.mainContext.insert(seEntao)
        try c.mainContext.save()

        let s = Sessao()
        s.abrir(destaque)
        s.campos["unica"] = "o bot achou isto, e o dono corrigiu a vírgula"
        #expect(s.salvar(no: c.mainContext))
        #expect(DestaqueDoDia.linhaDeHoje() == nil)

        s.novaPagina()
        s.abrir(seEntao)
        s.campos["entao"] = "ligo para o cliente hoje"
        #expect(s.salvar(no: c.mainContext))
        #expect(seEntao.gatilhoEm == nil)
    }

    /// `minutosExpressiva` sai de `segundosRestantes`, que é estado de
    /// processo: depois de uma expressiva selada ele valia os minutos daquela
    /// sessão para sempre, e a primeira nota comum aberta só para reler ficava
    /// com minutos escritos e `editadaEm` novo — a resposta da sábia que a
    /// citava era recolhida sem ninguém ter mexido numa letra.
    @Test func osMinutosDaExpressivaNaoEntramNaNotaComum() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "hoje senti medo e o peito ficou pesado o dia inteiro, chorei."
        s.gesto = .expressiva
        let t0 = Date()
        s.iniciarTimer(agora: t0)
        s.alinharTimerAoRelogio(agora: t0.addingTimeInterval(12 * 60))
        #expect(s.minutosExpressiva == 12)
        #expect(s.salvar(no: c.mainContext, trancar: true))
        s.pararTimer()
        s.novaPagina()
        #expect(s.minutosExpressiva == 0)

        let comum = Nota(texto: "decidir se troco de plano de celular")
        let editadaAntes = comum.editadaEm
        c.mainContext.insert(comum)
        try c.mainContext.save()
        s.abrir(comum)
        #expect(s.salvar(no: c.mainContext))
        #expect(comum.minutosEscritos == 0)
        #expect(comum.editadaEm == editadaAntes)
    }

    /// SPEC §8.4: «Sobram data, minutos e a linha de sentido». A varredura do
    /// arranque abre o fecho de uma expressiva que venceu com o app morto; a
    /// folha dizia «12 minutos escritos.» e a queima gravava 0 por cima.
    @Test func queimarGuardaOsMinutosQueAFolhaMostrou() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "hoje senti medo e chorei o dia inteiro",
                        gesto: .expressiva,
                        expressivaPrazo: Date().addingTimeInterval(-30))
        nota.minutosEscritos = 12
        c.mainContext.insert(nota)
        try c.mainContext.save()

        let s = Sessao() // processo novo: `iniciarTimer` nunca correu aqui
        s.trancarExpressivasVencidas(no: c.mainContext)
        #expect(s.fechoExpressiva == 12)
        #expect(s.queimar(no: c.mainContext, sentido: "o que ficou claro"))

        let cinza = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(cinza.queimada)
        #expect(cinza.minutosEscritos == 12)
    }

    /// SPEC §8.9: «o fecho abre a série», sem distinguir Selar de Queimar; e
    /// §8.5 diz que a linha de sentido é pulável. Queimar a primeira sessão
    /// com a linha em branco deixava o dia 1 sem série e sem o aviso do dia 2.
    @Test func queimarComALinhaEmBrancoAbreASerie() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "primeira sessão: escrevi sobre o que doeu, quinze minutos"
        s.gesto = .expressiva
        let t0 = Date()
        s.iniciarTimer(agora: t0)
        s.alinharTimerAoRelogio(agora: t0.addingTimeInterval(15 * 60))
        s.abrirFecho(no: c.mainContext)
        #expect(s.fechoUUID != nil)
        #expect(s.queimar(no: c.mainContext, sentido: ""))

        let cinza = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(cinza.queimada)
        #expect(cinza.serieUUID != nil)
        #expect(cinza.diaDaSerie == 1)
    }

    /// Exp 12: REVELAR é a revisão — e o degrau é da nota que está NA FOLHA.
    /// Fechar o Recordar pelo X deixava a identidade pendente, e a folha
    /// seguinte creditava a nota anterior, que ninguém recordou.
    @Test func revelarCreditaANotaQueEstaNaFolha() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let a = Nota(texto: "trocar de plano de celular", gesto: .seEntao,
                     campos: ["se": "quando chegar a conta", "entao": "comparo os planos"])
        c.mainContext.insert(a)
        try c.mainContext.save()

        let s = Sessao()
        s.recordarDaNotas(a) // pela lista: a identidade pendente é a de A
        #expect(s.revisaoPendente == a.uuid)
        s.mostrarRecordar = false // fechou pelo X, sem revelar

        s.novaPagina()
        s.texto = "falar com a advogada"
        s.gesto = .seEntao
        s.campos = ["se": "amanhã de manhã", "entao": "ligo para o escritório"]
        s.irRecordar(no: c.mainContext) // a outra porta: o Recordar da página
        let b = try #require(s.recordarUUID)
        #expect(b != a.uuid)

        let degrauDeA = Revisoes.nivel(a.uuid)
        s.cumprirRevisaoPendente(no: c.mainContext)
        #expect(Revisoes.nivel(a.uuid) == degrauDeA)
        #expect(Revisoes.contagem(b) == 1)
    }

    /// ADR 04k: a única do método Dia é o Destaque do dia — mesma lei, mesma
    /// tela. `desfazerApagar` guardava uma cópia reduzida da regra (só o
    /// método Destaque) e a nota devolvida não voltava à tela bloqueada.
    @Test func desfazerDevolveODestaqueDoMetodoDia() throws {
        limparDestaque()
        defer { limparDestaque() }
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.gesto = .dia
        s.campos = ["unica": "entregar o relatório"]
        #expect(s.salvar(no: c.mainContext))
        let id = try #require(s.notaUUID)
        #expect(DestaqueDoDia.linhaDeHoje() == "entregar o relatório")

        s.apagar(uuid: id, no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == nil)
        s.desfazerApagar(no: c.mainContext)
        #expect(DestaqueDoDia.linhaDeHoje() == "entregar o relatório")
    }

    /// ADR 11a: a ação do Trabalho está na mesma tesoura do widget e da tela
    /// bloqueada — mas a tesoura só corta quando alguém a manda recalcular.
    /// Apagar a nota de origem calava o aviso e deixava a linha da ação
    /// restrita na projeção do App Group até o app voltar à cena.
    @Test func apagarAOrigemTiraAAcaoDaTelaBloqueada() throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("selo-\(UUID())")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let urlAntes = SuperficieDisco.url
        let revisoesAntes = (SuperficieDisco.revisaoPublicada, SuperficieDisco.revisaoRecarregada)
        let calendario = CalendarioDisco.urlPadrao()
        let calendarioAntes = try? Data(contentsOf: calendario)
        SuperficieDisco.url = raiz.appendingPathComponent("superficie.json")
        try? FileManager.default.removeItem(at: calendario)
        defer {
            SuperficieDisco.url = urlAntes
            (SuperficieDisco.revisaoPublicada, SuperficieDisco.revisaoRecarregada) = revisoesAntes
            if let calendarioAntes { try? calendarioAntes.write(to: calendario) }
            try? FileManager.default.removeItem(at: raiz)
        }

        let c = try ModelContainer.traco(emMemoria: true)
        let origem = Nota(texto: "a separação")
        c.mainContext.insert(origem)
        var d = DocumentoTrabalho(intencao: "a separação", notaOrigemID: origem.uuid)
        try d.prepararAcao("falar com a advogada")
        let acao = try #require(d.acoes.first?.id)
        try d.agendar(acao, para: Date().addingTimeInterval(3600), duracaoMinutos: 20)
        c.mainContext.insert(try Trabalho(documento: d))
        try c.mainContext.save()

        ProximoCompromisso.publicarMundo(no: c.mainContext)
        func publicados() -> [String] {
            guard case .disponivel(let s) = SuperficieDisco.ler() else { return [] }
            return s.proximos.map(\.titulo)
        }
        #expect(publicados().contains("falar com a advogada"))

        Sessao().apagar(uuid: origem.uuid, no: c.mainContext, recuperavel: false)
        #expect(!publicados().contains("falar com a advogada"))
    }
}
