import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-06d — a linha do tempo dos widgets da casa.
///
/// O defeito que abriu a volta F4 não estava em nenhuma suíte: `policy:
/// .never` nas duas linhas do tempo. Sem o app abrir, o WidgetKit nunca mais
/// pedia nada e o widget congelava — nove horas parados no iPhone do dono
/// (06/09, 13:04, "atualizado às 04:14"). Aqui a lei fica escrita: a política
/// SEMPRE devolve uma volta, dentro de um teto e acima de um piso, e as
/// entradas desenham o dia sem acordar o app.
@Suite("Linha do tempo do widget (F4)")
struct LinhaDoTempoWidgetTests {
    private let agora = Date(timeIntervalSince1970: 1_788_700_000)  // 06/09/2026, meio do dia

    private func proximo(_ titulo: String, daqui minutos: Double, dura: Double = 60,
                         lembrar: Date? = nil) -> Superficie.Proximo {
        let i = agora.addingTimeInterval(minutos * 60)
        return .init(titulo: titulo, inicio: i, fim: i.addingTimeInterval(dura * 60),
                     diaInteiro: false, aviso: nil, lembrarEm: lembrar)
    }

    private func superficie(_ proximos: [Superficie.Proximo],
                            validoAte: Date? = nil) -> SuperficieDisco.Leitura {
        .disponivel(Superficie(geradoEm: agora,
                               validoAte: validoAte ?? agora.addingTimeInterval(14 * 86400),
                               destaque: nil, proximos: proximos))
    }

    /// O que os dois provedores montam: as transições que a superfície conhece
    /// mais os começos que ainda não passaram.
    private func datas(_ leitura: SuperficieDisco.Leitura, cal: Calendar = .current) -> [Date] {
        guard case .disponivel(let s) = leitura else {
            return Relogio.datas(base: Superficie.transicoes(leitura, agora: agora),
                                 inicios: [], agora: agora, cal: cal)
        }
        return Relogio.datas(base: Superficie.transicoes(leitura, agora: agora),
                             inicios: s.proximos.filter { $0.inicio > agora }.map(\.inicio),
                             agora: agora, cal: cal)
    }

    // MARK: - A política: nunca `.never`

    @Test("a volta existe sempre, mesmo sem nenhuma transição")
    func voltaSempre() {
        let semNada = Relogio.voltar(agora: agora, ultima: nil)
        #expect(semNada > agora)
        #expect(semNada <= agora.addingTimeInterval(Relogio.releitura))
    }

    @Test("a volta nunca passa do teto de releitura, por longe que seja a última entrada")
    func voltaTemTeto() {
        let daquiADuasSemanas = agora.addingTimeInterval(14 * 86400)
        #expect(Relogio.voltar(agora: agora, ultima: daquiADuasSemanas)
                == agora.addingTimeInterval(Relogio.releitura))
    }

    @Test("a volta nunca cai abaixo do piso: transição colada não vira rajada")
    func voltaTemPiso() {
        let jaJa = agora.addingTimeInterval(30)
        #expect(Relogio.voltar(agora: agora, ultima: jaJa) == agora.addingTimeInterval(Relogio.minimo))
        #expect(Relogio.voltar(agora: agora, ultima: agora.addingTimeInterval(-3600))
                == agora.addingTimeInterval(Relogio.minimo))
    }

    @Test("entre o piso e o teto, a volta é a última entrada — releitura na hora em que muda")
    func voltaSegueAUltimaEntrada() {
        let daquiAUmaHora = agora.addingTimeInterval(3600)
        #expect(Relogio.voltar(agora: agora, ultima: daquiAUmaHora) == daquiAUmaHora)
    }

    @Test("o orçamento: no máximo umas poucas releituras por dia")
    func orcamentoRespeitado() {
        #expect(86400 / Relogio.releitura <= 12)
        #expect(Relogio.minimo >= 600)
    }

    // MARK: - As entradas: o dia desenhado de uma vez

    @Test("a véspera e o início de cada compromisso entram na linha")
    func vesperaInicioEFim() {
        let p = proximo("Dentista", daqui: 180)
        let datas = datas(superficie([p]))
        #expect(datas.contains(p.inicio.addingTimeInterval(-Relogio.vespera)))
        #expect(datas.contains(p.inicio))
        #expect(!datas.contains(p.fim))
    }

    @Test("a meia-noite entra sempre: o Destaque de hoje deixa de ser o de hoje")
    func meiaNoiteEntra() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        let meiaNoite = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: agora)!)
        #expect(datas(superficie([]), cal: cal).contains(meiaNoite))
        // e também quando não há nada que ler: a linha nunca fica vazia
        #expect(datas(.indisponivel, cal: cal).contains(meiaNoite))
    }

    @Test("nenhuma entrada no passado, nenhuma repetida, tudo em ordem")
    func ordenadasESemPassado() {
        let datas = datas(superficie([proximo("Já passou", daqui: -120), proximo("Dentista", daqui: 45),
                                      proximo("Jantar", daqui: 45)]))  // mesma hora: uma data só
        #expect(datas == datas.sorted())
        #expect(Set(datas).count == datas.count)
        #expect(datas.allSatisfy { $0 >= agora })
    }

    @Test("a véspera que já passou não vira entrada")
    func vesperaPassadaNaoEntra() {
        // começa em 20 min: a véspera (uma hora antes) já ficou para trás
        let p = proximo("Daqui a pouco", daqui: 20)
        let datas = datas(superficie([p]))
        #expect(!datas.contains(p.inicio.addingTimeInterval(-Relogio.vespera)))
        #expect(datas.contains(p.inicio))
    }

    @Test("a linha é curta: um dia cheio cabe em poucas entradas")
    func linhaCurta() {
        let datas = datas(superficie([proximo("Dentista", daqui: 45), proximo("Revisão", daqui: 180),
                                      proximo("Jantar", daqui: 420)]))
        // agora + (véspera, início) × 3 + meia-noite + horizonte
        #expect(datas.count <= 12)
        #expect(datas.first == agora)
    }

    @Test("a soneca da tela bloqueada continua sendo uma transição")
    func sonecaEntra() {
        let soneca = agora.addingTimeInterval(600)
        let p = proximo("Dentista", daqui: 45, lembrar: soneca)
        #expect(datas(superficie([p])).contains(soneca))
    }
}

/// ADR 2026-09-06d, revisão G3 — A2: o sino é uma promessa, não um enfeite.
///
/// O revisor negou os avisos às 15:20 e às 15:21 os quatro widgets da casa
/// mostravam `🔔 16:00` e `🔔 17:15`. Nenhum ponto do caminho de publicação
/// perguntava pela autorização: `mudo:` silenciava UM evento (o que acabara de
/// ser gravado) e a revogação global não silenciava nada. Aqui a lei fica
/// escrita: sem permissão no último olhar, a superfície sai sem sino nenhum.
@Suite("O sino só sai quando há alarme (F4-B)")
struct SinoHonestoTests {
    private var cal: Calendar { Calendario.gregoriano(fuso: TimeZone(identifier: "America/Sao_Paulo")!) }

    private func comEspelho(_ permitido: Bool, _ corpo: () -> Void) {
        let antes = SuperficieDisco.defaults.bool(forKey: Avisos.chaveEspelho)
        SuperficieDisco.defaults.set(permitido, forKey: Avisos.chaveEspelho)
        corpo()
        SuperficieDisco.defaults.set(antes, forKey: Avisos.chaveEspelho)
    }

    @Test("avisos negados no iPhone: nenhum sino na superfície")
    func negadoNaoPromete() {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 6, hour: 15, minute: 21))!
        let dentista = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(2340),
                                        fim: agora.addingTimeInterval(5940))
        let revisao = EventoCalendario(titulo: "Revisão com o time", inicio: agora.addingTimeInterval(6540),
                                       fim: agora.addingTimeInterval(10140))

        comEspelho(false) {
            let fatias = ProximoCompromisso.proximasFatias([dentista, revisao], cal: cal, manha: 8, agora: agora)
            #expect(fatias.count == 2)
            #expect(fatias.allSatisfy { $0.aviso == nil })
        }

        // e com permissão o sino volta — a correção não apagou a promessa,
        // só passou a exigir que ela seja verdade
        comEspelho(true) {
            let fatias = ProximoCompromisso.proximasFatias([dentista, revisao], cal: cal, manha: 8, agora: agora)
            #expect(fatias.allSatisfy { $0.aviso != nil })
        }
    }

    @Test("permissão negada vence o caminho de publicação inteiro")
    func negadoAtravessaAPublicacao() {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 6, hour: 15, minute: 21))!
        let e = EventoCalendario(titulo: "Dentista", inicio: agora.addingTimeInterval(2340),
                                 fim: agora.addingTimeInterval(5940))
        comEspelho(false) {
            ProximoCompromisso.publicar([e], cal: cal, manha: 8, agora: agora)
            #expect(ProximoCompromisso.lido(agora: agora)?.aviso == nil)
        }
        comEspelho(true) {
            ProximoCompromisso.publicar([e], cal: cal, manha: 8, agora: agora)
            #expect(ProximoCompromisso.lido(agora: agora)?.aviso != nil)
        }
        ProximoCompromisso.gravar(nil)
    }
}

/// ADR 2026-09-06d, revisão Re-G3 — R1: o estado honesto não depende do ramo.
///
/// A correção do A1 desceu "Desatualizado." do cabeçalho (onde saía `desatua…`)
/// para a linha do conteúdo — e ali, na view, ele virou o ÚLTIMO `else if` de
/// uma cadeia que começa no Destaque. Com Destaque posto e o horizonte vencido,
/// o widget do Traço largava a agenda inteira e ficava CALADO: verdade truncada
/// trocada por silêncio, no defeito que abriu a volta.
///
/// A lei, agora fora do SwiftUI e com teste: **passada a validade, toda face
/// diz**. Só o LUGAR muda — com conteúdo em cima, o estado vira rodapé; sem
/// conteúdo, ele é o miolo e carrega a ação. Um `if/else` de view não tem
/// suíte, e foi um `if/else` de view que regrediu.
@Suite("O estado honesto sai em qualquer combinação (F4-C)")
struct EstadoNaFaceTests {
    @Test("instantâneo fresco não inventa estado, com ou sem conteúdo")
    func frescoCala() {
        #expect(EstadoNaFace.de(velha: false, temConteudo: true) == .nenhum)
        #expect(EstadoNaFace.de(velha: false, temConteudo: false) == .nenhum)
    }

    @Test("velho SEM conteúdo: o estado é o próprio miolo, com a recuperação")
    func velhoSemConteudoViraMiolo() {
        #expect(EstadoNaFace.de(velha: true, temConteudo: false) == .miolo)
    }

    @Test("velho COM Destaque posto: o estado desce ao rodapé — nunca some (R1)")
    func velhoComConteudoViraRodape() {
        #expect(EstadoNaFace.de(velha: true, temConteudo: true) == .rodape)
    }

    @Test("a lei, nas quatro combinações: velho é sempre dito")
    func velhoSempreDiz() {
        for conteudo in [true, false] {
            #expect(EstadoNaFace.de(velha: true, temConteudo: conteudo).diz,
                    "com conteúdo=\(conteudo) o widget ficou mudo — é a R1 de volta")
            #expect(!EstadoNaFace.de(velha: false, temConteudo: conteudo).diz)
        }
    }
}

/// A palavra do estado nunca se parte ao meio. `Desatualiza-/do.` é a mesma
/// família do `PRÓXI-/MO` que derrubou a F4 — e, como aquele, só aparecia na
/// tela. Um teto de linhas decidido na view não tem suíte; este tem.
@Suite("A palavra do estado não quebra com hífen (F4-D)")
struct LinhasDoEstadoTests {
    @Test("palavra só: uma linha — sem onde quebrar, ela encolhe inteira")
    func palavraSoCabeEmUmaLinha() {
        #expect(LinhasDoEstado.de("Desatualizado.") == 1)
    }

    @Test("com espaço: o teto inteiro — quebrar linha vale mais que encolher")
    func fraseUsaOTeto() {
        #expect(LinhasDoEstado.de("Não consegui ler o Traço.") == 3)
        #expect(LinhasDoEstado.de("Nada em destaque hoje.") == 3)
        #expect(LinhasDoEstado.de("Nada marcado.") == 3)
    }

    @Test("os quatro estados que a face escreve hoje, um por um")
    func osEstadosDaFace() {
        let umaPalavra = ["Desatualizado."]
        let comEspaco = ["Não consegui ler o Traço.", "Nada em destaque hoje.",
                         "Nada marcado.", "Nada marcado hoje."]
        for e in umaPalavra {
            #expect(LinhasDoEstado.de(e) == 1, "\(e) pode hifenizar — é o N2 de volta")
        }
        for e in comEspaco { #expect(LinhasDoEstado.de(e) == 3) }
    }
}

/// O achado A do G4, que é da dimensão *Fora do app*: num dia de CINCO
/// compromissos a superfície carrega três e o pequeno imprimia **"+2 depois"**
/// — uma contagem exata, derivada de uma lista que a face sabia cortada. O
/// dono lia "+2" e acreditava que o dia dele tinha três.
///
/// A correção é das duas metades ao mesmo tempo, como o juiz exigiu: o
/// instantâneo passou a carregar quantos ficaram de fora, e a face só publica
/// número quando ele existe. Aqui está a lei; a prova de ponta a ponta (cinco
/// eventos → documento com três e `alemDaLista == 2`) está em `ForaDoAppTests`.
@Suite("A face não fecha número sobre lista cortada (F4-E)")
struct RestantesTests {
    @Test("dia inteiro na face: nada a dizer, e nenhuma linha gasta dizendo")
    func nadaSobrando() {
        #expect(Restantes.de(naFace: 3, publicados: 3, alem: 0) == .nenhum)
        #expect(Restantes.de(naFace: 1, publicados: 1, alem: 0) == .nenhum)
        #expect(Restantes.de(naFace: 3, publicados: 3, alem: 0).frase == nil)
    }

    @Test("cinco no dia, um na face: quatro depois — não dois")
    func oNumeroDoDiaInteiro() {
        // o instantâneo carrega três dos cinco; a face mostra um
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: 2) == .exato(4))
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: 2).frase == "+4 depois")
        // e o médio, mostrando os três: os dois que ficaram fora do documento
        #expect(Restantes.de(naFace: 3, publicados: 3, alem: 2).frase == "+2 depois")
        // era este o número falso: contar só a lista de dentro
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: 2) != .exato(2))
    }

    @Test("instantâneo que não sabe não inventa: 'mais depois', sem número")
    func semSaberNaoPublicaNumero() {
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: nil) == .algunsMais)
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: nil).frase == "mais depois")
        #expect(Restantes.de(naFace: 3, publicados: 3, alem: nil).frase == "mais depois")
    }

    @Test("a voz diz a mesma coisa que a tela")
    func aVozAcompanha() {
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: 2).emVoz == "mais 4 depois")
        #expect(Restantes.de(naFace: 1, publicados: 3, alem: nil).emVoz == "e mais depois")
        #expect(Restantes.de(naFace: 2, publicados: 2, alem: 0).emVoz == nil)
    }

    @Test("lista curta é a verdade inteira: o documento sabe sem carregar conta")
    func listaCurtaSabeSozinha() {
        let curta = Superficie(geradoEm: .now, validoAte: .now.addingTimeInterval(3600),
                               proximos: fatias(2))
        #expect(curta.alem() == 0)
        let cheia = Superficie(geradoEm: .now, validoAte: .now.addingTimeInterval(3600),
                               proximos: fatias(Superficie.candidatas))
        // cheia e sem a conta = instantâneo velho: não sabe, e a face não chuta
        #expect(cheia.alem() == nil)
        var contada = cheia
        contada.alemDaLista = 2
        #expect(contada.alem() == 2)
    }

    private func fatias(_ n: Int) -> [Superficie.Proximo] {
        (0..<n).map { i in
            Superficie.Proximo(titulo: "c\(i)", inicio: .now.addingTimeInterval(Double(i + 1) * 3600),
                               fim: .now.addingTimeInterval(Double(i + 1) * 3600 + 600), diaInteiro: false)
        }
    }
}

/// ADR 08i — até quantas linhas a frase pode crescer no médio.
@Suite("F5: quantas linhas o Destaque pode ocupar no médio")
struct LinhasDoDestaqueTests {
    @Test("com agenda embaixo, duas — a agenda só existe ali e fica com o pé do cartão")
    func agendaFicaComOPe() {
        #expect(LinhasDoDestaque.noMedio(comAgenda: true) == 2)
    }

    @Test("sem agenda o layout decide: o teto de duas linhas com o rodapé deixava três linhas vazias")
    func semAgendaOLayoutDecide() {
        #expect(LinhasDoDestaque.noMedio(comAgenda: false) == Sacrificio.maximo)
        #expect(Sacrificio.maximo > 2)
    }
}

/// ADR 08i — só o RÓTULO encolhe; a frase do autor mantém o corpo e cede
/// quantidade. O piso de 0,35 da F4-F comia o aumento que a pessoa pediu.
@Suite("F5: o piso do encolhimento")
struct EncolheTests {
    @Test("o rótulo encolhe até 0,6 — legível, e reescrevível se não couber")
    func pisoDoRotulo() {
        #expect(Encolhe.rotulo >= 0.6)
        #expect(Encolhe.rotulo <= 1)
    }
}

/// ADR 08i — a ordem de sacrifício do pequeno com Destaque, como dado com suíte.
@Suite("ADR 08i: a ordem de sacrifício")
struct SacrificioTests {
    @Test("o rótulo cede antes de uma linha da frase: para cada n, com rótulo vem antes de sem")
    func rotuloCedePrimeiro() {
        let c = Sacrificio.candidatos(maximo: 3, rotulo: true)
        #expect(c == [.init(linhas: 3, rotulo: true), .init(linhas: 3, rotulo: false),
                      .init(linhas: 2, rotulo: true), .init(linhas: 2, rotulo: false),
                      .init(linhas: 1, rotulo: true), .init(linhas: 1, rotulo: false)])
    }

    @Test("a frase nunca fica sem candidato: o último é uma linha, sem rótulo")
    func ultimoCandidato() {
        for maximo in [0, 1, 5, Sacrificio.maximo] {
            #expect(Sacrificio.candidatos(maximo: maximo, rotulo: true).last == .init(linhas: 1, rotulo: false))
            #expect(Sacrificio.candidatos(maximo: maximo, rotulo: false).last == .init(linhas: 1, rotulo: false))
        }
    }

    @Test("no estado velho o rodapé toma o lugar do rótulo: nenhum candidato o tem")
    func semRotuloNoVelho() {
        #expect(Sacrificio.candidatos(rotulo: false).allSatisfy { !$0.rotulo })
        #expect(Sacrificio.candidatos(rotulo: false).map(\.linhas) == Array((1...Sacrificio.maximo).reversed()))
    }

    /// O critério medível da ADR 08i (F4-I): "corte é evitável quando cabe uma
    /// linha inteira do corpo do papel no espaço livre ao lado do marcador".
    /// A suíte não mede altura — a captura mede. O que ela garante é a
    /// PREMISSA que faz o `ViewThatFits` cumprir o critério: os candidatos
    /// descem de um em um, sem lacuna, e o primeiro que cabe é o MAIOR que
    /// cabe — se n + 1 não coube, o que sobra ao lado do "…" é menos de uma
    /// linha. Uma lista com buraco (8, 6, 4…) reabriria o corte evitável.
    @Test("o critério medível: os candidatos descem de um em um, sem lacuna")
    func semLacunaEntreCandidatos() {
        for rotulo in [true, false] {
            let linhas = Sacrificio.candidatos(rotulo: rotulo).map(\.linhas)
            #expect(linhas.first == Sacrificio.maximo)
            #expect(linhas.last == 1)
            for (maior, menor) in zip(linhas, linhas.dropFirst()) {
                #expect(maior - menor == 0 || maior - menor == 1)
            }
        }
    }
}

