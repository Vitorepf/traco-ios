import Foundation
import Testing

@testable import Traco

/// A recomendação do campo (ADR 2026-09-03c). A lei aqui é uma só: a sugestão
/// tem de sobreviver à ida e volta pelo parser. Se não sobreviver, ela não sai.
@Suite struct RecomendacaoTests {
    let cal = Calendario.gregoriano()

    private func quando(_ ano: Int, _ mes: Int, _ d: Int, _ h: Int = 0, _ m: Int = 0) -> Date {
        cal.date(from: DateComponents(year: ano, month: mes, day: d, hour: h, minute: m))!
    }

    /// Quinta, 3 de setembro de 2026, 10h.
    private var agora: Date { quando(2026, 9, 3, 10) }

    private func compromisso(_ titulo: String, _ inicio: Date, diaInteiro: Bool = false)
        -> CompromissoDoSistema {
        CompromissoDoSistema(titulo: titulo, inicio: inicio, diaInteiro: diaInteiro)
    }

    // MARK: o caso do dono

    /// O ingresso comprado: o Gmail cria o evento, o EventKit lê, e o campo já
    /// mostra a frase que o autor teclaria.
    @Test func oShowDeStandUpViraFrase() throws {
        // 5/9 é dois dias depois de hoje: "depois de amanhã" diz melhor que
        // "sábado" — e o parser lê as duas
        let show = compromisso("Stand-up do Rafinha", quando(2026, 9, 5, 21))
        let frase = try #require(Recomendacao.frase(de: show, agora: agora, cal))
        #expect(frase == "Stand-up do Rafinha depois de amanhã 21h")

        // e a frase, lida de volta, dá exatamente o mesmo compromisso
        let volta = try #require(CalendarioFrase.ler(frase, ancora: agora, agora: agora, cal))
        #expect(Calendario.mesmoDia(volta.inicio, show.inicio, cal))
        #expect(cal.component(.hour, from: volta.inicio) == 21)
        #expect(volta.titulo == "Stand-up do Rafinha")
    }

    // MARK: as palavras do dia

    @Test func hojeAmanhaEDepois() {
        #expect(Recomendacao.palavraDoDia(quando(2026, 9, 3, 15), agora: agora, cal) == "hoje")
        #expect(Recomendacao.palavraDoDia(quando(2026, 9, 4, 15), agora: agora, cal) == "amanhã")
        #expect(Recomendacao.palavraDoDia(quando(2026, 9, 5, 15), agora: agora, cal) == "depois de amanhã")
        // 6/9 é domingo, e já sai como nome do dia
        #expect(Recomendacao.palavraDoDia(quando(2026, 9, 6, 15), agora: agora, cal) == "domingo")
        // e o "-feira" cai: "segunda", não "segunda-feira"
        #expect(Recomendacao.palavraDoDia(quando(2026, 9, 7, 15), agora: agora, cal) == "segunda")
        #expect(Recomendacao.palavraDoDia(quando(2026, 9, 8, 15), agora: agora, cal) == "terça")
    }

    /// O caso que apareceu na tela: o feriado do dia 7, lido do calendário do
    /// sistema, cabendo no campo e voltando inteiro pelo parser.
    @Test func oFeriadoDoSistemaViraFraseCurta() throws {
        let feriado = CompromissoDoSistema(titulo: "Independência do Brasil",
                                           inicio: quando(2026, 9, 7), diaInteiro: true)
        let frase = try #require(Recomendacao.frase(de: feriado, agora: agora, cal))
        #expect(frase == "Independência do Brasil segunda dia inteiro")
        let volta = try #require(CalendarioFrase.ler(frase, ancora: agora, agora: agora, cal))
        #expect(cal.component(.day, from: volta.inicio) == 7)
        #expect(volta.diaInteiro)
        #expect(volta.titulo == "Independência do Brasil")
    }

    /// Fora da janela de sete dias não há sugestão: placeholder apontando para
    /// três meses adiante é ruído, não ajuda.
    @Test func foraDaJanelaNaoSugere() {
        #expect(Recomendacao.palavraDoDia(quando(2026, 12, 25, 10), agora: agora, cal) == nil)
        let natal = compromisso("Natal", quando(2026, 12, 25, 10))
        #expect(Recomendacao.frase(de: natal, agora: agora, cal) == nil)
    }

    @Test func aHoraSaiComEsemMinuto() {
        #expect(Recomendacao.horaEscrita(quando(2026, 9, 4, 21), cal) == "21h")
        #expect(Recomendacao.horaEscrita(quando(2026, 9, 4, 14, 30), cal) == "14h30")
        #expect(Recomendacao.horaEscrita(quando(2026, 9, 4, 9, 5), cal) == "9h05")
    }

    @Test func oDiaInteiroSeDiz() throws {
        let viagem = compromisso("Viagem", quando(2026, 9, 4), diaInteiro: true)
        let frase = try #require(Recomendacao.frase(de: viagem, agora: agora, cal))
        #expect(frase == "Viagem amanhã dia inteiro")
        let volta = try #require(CalendarioFrase.ler(frase, ancora: agora, agora: agora, cal))
        #expect(volta.diaInteiro)
        #expect(volta.titulo == "Viagem")
    }

    // MARK: a recusa — o que faz a sugestão não mentir

    /// Título com dia da semana dentro, num dia que também se diz pelo nome:
    /// "Feira de sábado domingo 9h" faz `comerDia` pegar o PRIMEIRO dia da
    /// frase — o do título — e marcar o dia errado. A sugestão é descartada.
    @Test func tituloComDiaDaSemanaPodeSerRecusado() {
        let armadilha = compromisso("Feira de sábado", quando(2026, 9, 6, 9))
        #expect(Recomendacao.frase(de: armadilha, agora: agora, cal) == nil)
    }

    /// Mas com "hoje"/"amanhã" na frase o título sobrevive: essas palavras são
    /// lidas ANTES dos nomes de dia, então o "sábado" do título fica quieto.
    @Test func comAmanhaOTituloSobreviveAoDiaDaSemana() throws {
        let feira = compromisso("Feira de sábado", quando(2026, 9, 4, 8))
        let frase = try #require(Recomendacao.frase(de: feira, agora: agora, cal))
        #expect(frase == "Feira de sábado amanhã 8h")
    }

    /// Título com hora dentro: mesma recusa.
    @Test func tituloComHoraDentroNaoSugere() {
        let armadilha = compromisso("Corrida 5h da manhã", quando(2026, 9, 4, 18))
        #expect(Recomendacao.frase(de: armadilha, agora: agora, cal) == nil)
    }

    @Test func tituloVazioNaoSugere() {
        #expect(Recomendacao.frase(de: compromisso("", quando(2026, 9, 4, 10)), agora: agora, cal) == nil)
    }

    // MARK: a escolha da lista

    /// A primeira que serve — passado não conta, e o que o parser recusa é
    /// pulado em silêncio em vez de derrubar a sugestão inteira.
    ///
    /// Vale notar o que a ida e volta NÃO recusa: "Jogo 7 x 1 domingo" num
    /// domingo passa, porque o parser come o "domingo" do título e cai no
    /// mesmo dia — o resultado está certo, e é o resultado que a guarda mede,
    /// não qual palavra foi comida.
    @Test func aPrimeiraQueOParserAceita() throws {
        let lista = [
            compromisso("Passado", quando(2026, 9, 2, 10)),          // já foi
            // "sábado" no título + domingo na frase: o parser pega o do título
            // e marca o dia errado, então esta é recusada
            compromisso("Feira de sábado", quando(2026, 9, 6, 9)),
            compromisso("Dentista", quando(2026, 9, 4, 14, 30)),       // esta serve
            compromisso("Cinema", quando(2026, 9, 5, 20)),
        ]
        let frase = try #require(Recomendacao.primeira(de: lista, agora: agora, cal))
        #expect(frase == "Dentista amanhã 14h30")
    }

    @Test func semCompromissoNaoHaSugestao() {
        #expect(Recomendacao.primeira(de: [], agora: agora, cal) == nil)
    }

    /// A janela entregue ao leitor é exatamente [agora, agora + 7 dias].
    /// (Não dá para testar "sem permissão" aqui: o simulador já tem acesso
    /// concedido e tem eventos de verdade — o que, aliás, prova o caminho.)
    @Test func aJanelaEDeSeteDias() async {
        let sistema = CalendarioSistema()
        var pedida: (Date, Date)?
        sistema.lerDoSistema = { de, a in
            pedida = (de, a)
            return []
        }
        await sistema.recarregar(agora: agora, cal)
        let (de, a) = try! #require(pedida)
        #expect(de == agora)
        #expect(cal.dateComponents([.day], from: de, to: a).day == CalendarioSistema.janelaDias)
    }

    /// Com a leitura injetada, a janela de sete dias é respeitada pelo chamador
    /// e a ordem é cronológica.
    @Test func aLeituraInjetadaVemOrdenada() async {
        let sistema = CalendarioSistema()
        sistema.lerDoSistema = { [self] _, _ in
            [compromisso("Depois", quando(2026, 9, 6, 9)),
             compromisso("Antes", quando(2026, 9, 4, 9))]
        }
        await sistema.recarregar(agora: agora, cal)
        #expect(sistema.proximos.map(\.titulo) == ["Antes", "Depois"])
    }
}
