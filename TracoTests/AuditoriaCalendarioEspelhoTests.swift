import EventKit
import Foundation
import Testing
@testable import Traco

/// AUDITORIA 17/09 — o calendário e o espelho, nos pontos em que a tela
/// afirmava coisa falsa ou o dado do autor ficava para trás.
///
/// Quatro consertos, um teste cada: os compromissos do iPhone que saíam da
/// tela bloqueada ao guardar no Trabalho; a faixa da grade que decidia qual
/// era "o próximo"; o sino desenhado para o alarme que o iOS recusou na rota
/// da Siri; e o «Parar de espelhar» que deixava o `calendario.json` na nuvem.
///
/// Mais três, dos «achados de contrato» que a 17p deixou em dívida: a lista
/// dos arquivos soltos do espelho escrita à mão em dois lugares; o arranque a
/// frio que publicava a face sem os compromissos do iPhone; e qual pílula de
/// dia inteiro a semana mostra quando há duas.
@Suite("Auditoria do calendário e do espelho", .serialized)
struct AuditoriaCalendarioEspelhoTests {
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!) }

    /// 20/09/2026, meio-dia — a referência de todos os casos abaixo.
    private var agora: Date {
        cal.date(from: DateComponents(year: 2026, month: 9, day: 20, hour: 12))!
    }

    /// O disco da Superfície fora do App Group de verdade, como no
    /// `ForaDoAppTests`: publicar de teste não mexe no widget do aparelho.
    private func comSuperficieDeTeste(_ corpo: (Calendar, Date) async throws -> Void) async throws {
        let raiz = FileManager.default.temporaryDirectory
            .appendingPathComponent("sup-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let urlAntes = SuperficieDisco.url
        let espelhoAntes = CalendarioSistema.naSuperficie
        SuperficieDisco.url = raiz.appendingPathComponent("superficie.json")
        defer {
            SuperficieDisco.url = urlAntes
            CalendarioSistema.naSuperficie = espelhoAntes
            try? FileManager.default.removeItem(at: raiz)
        }
        try await corpo(cal, agora)
    }

    private func publicados() -> [Superficie.Proximo] {
        if case .disponivel(let s) = SuperficieDisco.ler() { return s.proximos }
        return []
    }

    // MARK: - O compromisso do iPhone não é de uma rota só

    /// Guardar QUALQUER coisa no Trabalho passa por `publicarMundo`, que monta
    /// a lista do `calendario.json` + ações — e o compromisso do iPhone não
    /// está em nenhuma das duas. A tela bloqueada perdia a reunião de amanhã
    /// que ela mesma estava mostrando um minuto antes. Agora a fonte é uma só,
    /// dentro de `publicar`, e serve às seis rotas.
    @MainActor @Test("o compromisso do iPhone entra em qualquer rota de publicação")
    func oCompromissoDoIPhoneNaoDependeDeQuemPublicou() async throws {
        try await comSuperficieDeTeste { cal, agora in
            let sistema = CalendarioSistema()
            let reuniao = CompromissoDoSistema(titulo: "Reunião com o contador",
                                               inicio: agora.addingTimeInterval(21 * 3600))
            let show = CompromissoDoSistema(titulo: "Show",
                                            inicio: cal.date(from: DateComponents(
                                                year: 2026, month: 12, day: 12, hour: 21))!)
            sistema.lerDoSistema = { de, a in [reuniao, show].filter { $0.inicio >= de && $0.inicio <= a } }
            await sistema.recarregar(agora: agora, cal)
            let academia = EventoCalendario(titulo: "Academia",
                                            inicio: agora.addingTimeInterval(7 * 3600),
                                            fim: agora.addingTimeInterval(8 * 3600))
            // a forma exata de `publicarMundo`, da Sessao e do intent: a lista
            // do disco, sem compromisso do sistema nenhum dentro
            ProximoCompromisso.publicar([academia], cal: cal, agora: agora)
            let fatias = publicados()
            #expect(fatias.map(\.titulo).contains("Academia"))
            let doIPhone = fatias.first { $0.titulo == "Reunião com o contador" }
            #expect(doIPhone != nil, "a reunião de amanhã saiu da face ao publicar por outra rota")
            #expect(doIPhone?.doSistema == true)
            // ADR 03c: o que vem do iPhone é contexto, e quem avisa é o
            // app Calendário — a face nunca promete alarme por ele
            #expect(doIPhone?.aviso == nil)
            #expect(!fatias.map(\.titulo).contains("Show"), "12/12 está fora dos sete dias")
        }
    }

    /// `agenda.doSistema` é a faixa VISÍVEL da grade. Com ela na face, bastava
    /// o dedo parar em dezembro na escala Mês para a tela bloqueada anunciar
    /// o show de 12/12 como "o próximo" — e a reunião de amanhã não estava em
    /// lugar nenhum. A grade continua desenhando a faixa; a face não a vê.
    @MainActor @Test("a faixa da grade não decide qual é o próximo")
    func aFaixaVisivelNaoVaiAFace() async throws {
        try await comSuperficieDeTeste { cal, agora in
            let sistema = CalendarioSistema()
            let reuniao = CompromissoDoSistema(titulo: "Reunião com o contador",
                                               inicio: agora.addingTimeInterval(21 * 3600))
            sistema.lerDoSistema = { _, _ in [reuniao] }
            await sistema.recarregar(agora: agora, cal)
            let disco = FileManager.default.temporaryDirectory
                .appendingPathComponent("cal-\(UUID().uuidString).json")
            let agenda = CalendarioAgenda(agora: agora, cal: cal, disco: disco, eventos: [])
            defer { try? FileManager.default.removeItem(at: disco) }
            // o dedo parou em dezembro: a grade carregou a faixa de lá
            agenda.doSistema = [CompromissoDoSistema(
                titulo: "Show",
                inicio: cal.date(from: DateComponents(year: 2026, month: 12, day: 12, hour: 21))!
            ).comoEvento]
            agenda.publicarProximo(agora: agora)
            let titulos = publicados().map(\.titulo)
            #expect(!titulos.contains("Show"), "a faixa da grade voltou a decidir o próximo")
            #expect(titulos.contains("Reunião com o contador"), "a janela honesta dos sete dias")
        }
    }

    // MARK: - O sino é promessa (ADR 06d, item 6)

    /// A rota da Siri lia o resultado do alarme para a FRASE e publicava a
    /// Superfície sem ele: com o teto de 64 pendentes cheio, a Siri dizia
    /// "ficou sem alarme" e a tela bloqueada desenhava o sino com a hora.
    ///
    /// O `mudo:` é escrito à mão em cada rota, e nada falhava para avisar que
    /// uma tinha ficado de fora — então o portão conta: quem pede o alarme e
    /// publica depois leva o resultado. Irmão dos portões do `try!` e do
    /// movimento, e reusa a varredura deles (`codigoVisivel`) para não contar
    /// o que está escrito em comentário ou em string.
    @MainActor @Test("nenhuma rota publica a Superfície sem o resultado do alarme")
    func quemAgendaPublicaComMudo() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let fontes = PortaoDoMovimentoTests.fontes(raiz)
        // sem esta linha um caminho errado deixaria a varredura vazia e VERDE
        #expect(fontes.count > 100, "a varredura não achou os fontes: \(fontes.count) arquivos")

        var agendam = 0
        var faltosas: [String] = []
        for caminho in fontes {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            let semMudo = Self.publicacoesSemMudo(texto)
            if texto.contains("agendarCompromisso(") { agendam += 1 }
            faltosas += semMudo.map { "\(caminho):\($0)" }
        }
        #expect(agendam >= 3, "ninguém agenda alarme? a varredura parou de enxergar")
        #expect(faltosas.isEmpty, Comment(rawValue: """
            publicação da Superfície depois de pedir o alarme, sem `mudo:`:
            \(faltosas.joined(separator: "\n"))

            O sino é promessa, não enfeite (ADR 06d, item 6): publique com
            `mudo: r.vaiTocar ? nil : e.id`, como `CalendarioAgenda.avisar` e
            `Sessao.agendarEContar`.
            """))
    }

    /// Sonda do portão: duas formas que TÊM de acusar e três que não podem.
    @MainActor @Test("a varredura do sino ainda enxerga")
    func aVarreduraDoSinoAindaEnxerga() {
        let comDefeito = """
            let aviso = await Revisoes.agendarCompromisso(evento, cal: cal)
            ProximoCompromisso.publicar(ProximoCompromisso.comAcoesDoTrabalho(eventos), cal: cal)
            """
        #expect(Self.publicacoesSemMudo(comDefeito).count == 1, "a forma do defeito deixou de ser vista")
        #expect(Self.publicacoesSemMudo("""
            let r = await Revisoes.agendarCompromisso(e, cal: cal)
            publicarProximo()
            """).count == 1, "a rota da agenda deixou de ser vista")

        #expect(Self.publicacoesSemMudo("""
            let aviso = await Revisoes.agendarCompromisso(evento, cal: cal)
            ProximoCompromisso.publicar(ProximoCompromisso.comAcoesDoTrabalho(eventos), cal: cal,
                                        mudo: aviso.vaiTocar ? nil : evento.id)
            """).isEmpty, "a forma certa ficou vermelha")
        // publicar ANTES de pedir o alarme é a ordem de `avisar` (a superfície
        // não espera diálogo de permissão): não conta
        #expect(Self.publicacoesSemMudo("""
            publicarProximo()
            guard e.editavel else { return }
            let r = await Revisoes.agendarCompromisso(e, cal: cal)
            publicarProximo(mudo: r.vaiTocar ? nil : e.id)
            """).isEmpty, "a publicação anterior ao pedido virou vermelha")
        #expect(Self.publicacoesSemMudo("""
            let r = await Revisoes.agendarCompromisso(e, cal: cal)
            // ProximoCompromisso.publicar(lista, cal: cal)
            """).isEmpty, "comentário virou vermelho")
    }

    /// A publicação que conta é a PRIMEIRA depois do pedido do alarme, na
    /// mesma volta. Devolve as linhas em que ela não leva `mudo:`.
    static func publicacoesSemMudo(_ texto: String) -> [Int] {
        let linhas = PortaoDoMovimentoTests.codigoVisivel(texto, apagandoTema: false)
            .split(separator: "\n", omittingEmptySubsequences: false)
        var faltosas: [Int] = []
        for i in linhas.indices where linhas[i].contains("agendarCompromisso(") {
            let janela = i...min(i + 30, linhas.count - 1)
            guard let p = janela.first(where: {
                linhas[$0].contains("ProximoCompromisso.publicar(") || linhas[$0].contains("publicarProximo(")
            }) else { continue }
            // a chamada pode quebrar em linhas: o `mudo:` vem junto do resto
            let chamada = linhas[p...min(p + 2, linhas.count - 1)].joined()
            if !chamada.contains("mudo:") { faltosas.append(p + 1) }
        }
        return faltosas
    }

    // MARK: - Parar de espelhar TIRA a cópia

    private func comEspelhoDeTeste(_ corpo: (URL, URL) throws -> Void) throws {
        let pai = FileManager.default.temporaryDirectory
            .appendingPathComponent("esp-\(UUID().uuidString)", isDirectory: true)
        let raiz = pai.appendingPathComponent("Traço", isDirectory: true)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let antes = PastaEspelho.defaults
        PastaEspelho.defaults = UserDefaults(suiteName: "teste-espelho-\(UUID().uuidString)")!
        defer {
            PastaEspelho.defaults = antes
            try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: pai.path)
            try? FileManager.default.removeItem(at: pai)
        }
        #expect(PastaEspelho.guardar(pai))
        // é o que `Corpus.escrever` grava na raiz do espelho (decisão A4: "os
        // compromissos vão junto") — título, data e o campo livre de cada um
        try Data(#"[{"titulo":"Dentista","inicio":"2026-09-18T14:30:00Z"}]"#.utf8)
            .write(to: raiz.appendingPathComponent("calendario.json"))
        try Data("# Traço\n".utf8).write(to: raiz.appendingPathComponent("LEIA-ME.md"))
        try corpo(pai, raiz)
    }

    /// A lista de arquivos soltos de `limpar()` tinha quatro nomes e o quinto
    /// que o app grava, `calendario.json`, não estava nela: a agenda do autor
    /// ficava na pasta do iCloud, e como a raiz não ficava vazia a pasta
    /// `Traço/` também ficava lá — com o Perfil dizendo que não há cópia.
    @Test("parar de espelhar tira também o calendário do autor")
    func pararDeEspelharTiraOCalendario() throws {
        try comEspelhoDeTeste { _, raiz in
            PastaEspelho.limpar()
            #expect(!FileManager.default.fileExists(atPath: raiz.appendingPathComponent("calendario.json").path),
                    "a agenda do autor ficou na nuvem depois de «Parar de espelhar»")
            #expect(!FileManager.default.fileExists(atPath: raiz.path),
                    "a raiz vazia sai junto, como as duas guardas prometem")
            #expect(PastaEspelho.nome == nil)
        }
    }

    /// Com a pasta indisponível (iCloud fora, volume ausente) `comAcesso` não
    /// roda a varredura — e `limpar()` apagava o bookmark do mesmo jeito: o
    /// caderno inteiro ficava na nuvem e o app já não tinha chave para voltar
    /// a limpá-lo, enquanto o Perfil voltava a oferecer «Espelhar numa pasta».
    @Test("sem ter apagado nada, a pasta continua registrada")
    func aChaveSoSaiQuandoAVarreduraCorre() throws {
        try comEspelhoDeTeste { pai, raiz in
            try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: pai.path)
            PastaEspelho.limpar()
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: pai.path)
            #expect(FileManager.default.fileExists(atPath: raiz.appendingPathComponent("calendario.json").path),
                    "a cópia continua lá — é justamente por isso que a chave não pode sair")
            #expect(PastaEspelho.nome != nil, "sem a chave o app não pode voltar para tirar a cópia")
            #expect(PastaEspelho.estado != nil, "e o Perfil tem de dizer por que não tirou")
        }
    }

    // MARK: - A barra da semana conta o que escondeu

    /// A barra dá UMA pista aos de dia inteiro e o «+n» só olhava os marcados:
    /// «Aniversário da Ana» (do iPhone) + «Viagem a Lisboa» (do autor) no
    /// mesmo dia mostravam uma pílula e nenhum número. Com o calendário do
    /// iPhone lido, dois de dia inteiro no mesmo dia é o caso comum.
    @MainActor @Test("a semana conta os de dia inteiro que escondeu")
    func aSemanaContaOQueEscondeu() {
        #expect(CalendarioSemanaView.escondidos(pistas: [], inteiros: 2) == 1)
        #expect(CalendarioSemanaView.escondidos(pistas: [], inteiros: 3) == 2)
        // um só de dia inteiro cabe; nenhum não esconde nada
        #expect(CalendarioSemanaView.escondidos(pistas: [], inteiros: 1) == 0)
        #expect(CalendarioSemanaView.escondidos(pistas: [0, 1, 2], inteiros: 0) == 0)
        // o quarto marcado já contava, e agora soma com o dia inteiro que sobrou
        #expect(CalendarioSemanaView.escondidos(pistas: [0, 1, 2, 3], inteiros: 0) == 1)
        #expect(CalendarioSemanaView.escondidos(pistas: [0, 1, 2, 3, 4], inteiros: 3) == 4)
    }

    // MARK: - Os arquivos soltos do espelho, numa lista só

    /// A lista dos nomes que o espelho grava na raiz estava escrita à mão em
    /// dois lugares — em `Corpus`, ao gravar, e na varredura de
    /// `PastaEspelho.limpar()` — e quem acrescentava um nome num deles
    /// esquecia o outro: foi assim que o `calendario.json` ficou na pasta do
    /// iCloud depois de «Parar de espelhar». Agora a lista é uma só, e este
    /// teste fica vermelho quando um arquivo solto NOVO aparece na raiz sem
    /// entrar nela — antes de o dono descobrir na nuvem.
    @MainActor @Test("nenhum arquivo solto do espelho fica fora da lista de quem apaga")
    func todoArquivoSoltoEstaNaLista() throws {
        let raiz = FileManager.default.temporaryDirectory
            .appendingPathComponent("soltos-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        let antes = PastaEspelho.defaults
        PastaEspelho.defaults = UserDefaults(suiteName: "teste-soltos-\(UUID().uuidString)")!
        defer {
            PastaEspelho.defaults = antes
            try? FileManager.default.removeItem(at: raiz)
        }
        let nota = FatiaCorpus(id: UUID(), texto: "primeira", gesto: nil, campos: [:],
                               criadaEm: agora, editadaEm: agora, recordada: 0, sentido: "",
                               minutos: 0, trancada: false, queimada: false,
                               expressivaEmCurso: false, dominio: nil, serie: nil, dia: 0)
        Corpus.escrever(fatias: [nota], em: raiz, soOsMeus: true)
        let naRaiz = try FileManager.default.contentsOfDirectory(atPath: raiz.path)
            .filter { $0 != "notas" && !$0.hasPrefix(".espelho-") }
        // sem esta linha uma gravação que não acontecesse deixaria o teste VERDE
        #expect(naRaiz.count >= 4, "o espelho não gravou os agregados: \(naRaiz)")
        let forasteiros = Set(naRaiz).subtracting(Corpus.arquivosSoltos).sorted()
        #expect(forasteiros.isEmpty, Comment(rawValue: """
            arquivo solto que «Parar de espelhar» vai deixar na pasta do dono:
            \(forasteiros.joined(separator: ", "))

            O nome tem de entrar em `Corpus.arquivosSoltos` — é a lista que
            `PastaEspelho.limpar()` varre.
            """))
    }

    // MARK: - O arranque a frio enche o espelho do iPhone

    /// Publicar já junta `CalendarioSistema.naSuperficie` de uma fonte só,
    /// mas no arranque a frio esse espelho estava VAZIO: quem lia o EventKit
    /// era a aba Calendário ou o Perfil, e sem o dono abrir nenhuma das duas
    /// a tela bloqueada mostrava só o que é do Traço.
    ///
    /// E não pede permissão: sem acesso dado, `encherEspelho` devolve falso
    /// na primeira linha, sem falar com a loja — o pedido é um toque do dono,
    /// na tela em que se explica.
    @MainActor @Test("o arranque enche o espelho do iPhone sem pedir permissão")
    func oArranqueEncheOEspelhoDoSistema() async throws {
        try await comSuperficieDeTeste { cal, agora in
            CalendarioSistema.naSuperficie = []
            // honesto com o aparelho: neste simulador o acesso é `notDetermined`
            // e nada é lido; num que já deu acesso, ler é justamente o certo
            let jaTemAcesso = EKEventStore.authorizationStatus(for: .event) == .fullAccess
            let semInjecao = await CalendarioSistema.encherEspelho(agora: agora, cal)
            #expect(semInjecao == jaTemAcesso, "o arranque leu (ou pediu) o que não podia")

            let reuniao = CompromissoDoSistema(titulo: "Reunião com o contador",
                                               inicio: agora.addingTimeInterval(21 * 3600))
            let leu = await CalendarioSistema.encherEspelho(agora: agora, cal, lendo: { de, a in
                [reuniao].filter { $0.inicio >= de && $0.inicio <= a }
            })
            #expect(leu)
            // a face do arranque: a lista do disco, como a RaizView publica
            ProximoCompromisso.publicar([], cal: cal, agora: agora)
            #expect(publicados().contains { $0.titulo == "Reunião com o contador" },
                    "o arranque a frio publicou a face sem os compromissos do iPhone")
        }
    }

    // MARK: - Qual pílula de dia inteiro a semana mostra

    /// A barra dá UMA pista aos de dia inteiro, e qual deles aparecia era
    /// empate arbitrário: `sorted` não é estável, então «Aniversário da Ana»
    /// e «Viagem a Lisboa» no mesmo dia trocavam de lugar entre renders. A
    /// ordem agora é declarada em `Calendario.antesNoDia` — o mais longo
    /// primeiro, e a desempatar pelo título.
    @MainActor @Test("entre dois de dia inteiro, a semana mostra o mais longo")
    func aSemanaMostraOMaisLongoDoDia() throws {
        let dia = Calendario.inicioDoDia(agora, cal)
        let fimDoDia = Calendario.hora(24, 0, no: dia, cal)
        let aniversario = EventoCalendario(titulo: "Aniversário da Ana", inicio: dia,
                                           fim: fimDoDia, diaInteiro: true)
        let viagem = EventoCalendario(titulo: "Viagem a Lisboa", inicio: dia,
                                      fim: try #require(cal.date(byAdding: .day, value: 5, to: dia)),
                                      diaInteiro: true)
        let almoco = EventoCalendario(titulo: "Almoço", inicio: agora,
                                      fim: agora.addingTimeInterval(3600))
        let doDia = Calendario.porDia([aniversario, almoco, viagem], cal)[dia] ?? []
        #expect(doDia.map(\.titulo) == ["Viagem a Lisboa", "Aniversário da Ana", "Almoço"])
        // o que a pílula esconde continua contado (o «+n» da barra)
        #expect(CalendarioSemanaView.escondidos(
            pistas: [], inteiros: doDia.filter(\.diaInteiro).count) == 1)

        // do mesmo tamanho, o título desempata — e a ordem da ENTRADA não conta
        let feriado = EventoCalendario(titulo: "Feriado", inicio: dia,
                                       fim: fimDoDia, diaInteiro: true)
        for entrada in [[aniversario, feriado], [feriado, aniversario]] {
            #expect((Calendario.porDia(entrada, cal)[dia] ?? []).map(\.titulo)
                    == ["Aniversário da Ana", "Feriado"])
        }
    }
}
