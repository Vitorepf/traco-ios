import Foundation
import Testing

@testable import Traco

/// ADR 2026-09-03k — a análise no aparelho.
///
/// Estes testes CHAMAM O MODELO DE VERDADE. É de propósito: o contrato virou
/// tipo, e tipo se prova rodando. Se o aparelho não tiver o modelo (simulador
/// sem Apple Intelligence, máquina antiga), eles se calam em vez de mentir.
@Suite struct AnaliseDeBordoTests {
    @available(iOS 26.0, *)
    private var temModelo: Bool { AnaliseDeBordo.disponivel }

    @Test func aListaFechadaCobreTodosOsGestos() throws {
        guard #available(iOS 26.0, *) else { return }
        // ADR 04l/04t: o esquema nasce do CATÁLOGO — um método sem entrada
        // aqui seria um método que o modelo de bordo nunca poderia escolher
        let esquema = try AnaliseDeBordo.esquema()
        let descricao = String(describing: esquema)
        for m in Catalogo.todos { #expect(descricao.contains(m.id), Comment(rawValue: m.id)) }
        #expect(descricao.contains("nenhum"))
        // e as instruções vêm do mesmo arquivo que o prompt remoto
        #expect(AnaliseDeBordo.instrucoesDoCatalogo.contains("argumento ="))
        #expect(AnaliseRemota.sistema.contains("argumento ="))
    }

    /// ADR 06g: a divergência não pode voltar em silêncio. Não basta cada id
    /// aparecer: a CONTA tem de bater, senão alguém troca `Catalogo.todos` por
    /// uma lista fixa que por acaso contém os ids e ninguém percebe.
    @Test func oEsquemaTemUMAOpcaoPorMETODOMaisNenhum() throws {
        guard #available(iOS 26.0, *) else { return }
        let descricao = String(describing: try AnaliseDeBordo.esquema())
        // "nenhum" é a única opção que não é método
        let ids = Catalogo.todos.map(\.id)
        for id in ids { #expect(descricao.contains("\"\(id)\""), Comment(rawValue: id)) }
        #expect(descricao.contains("\"nenhum\""))
        // e as instruções listam TODOS, não só o primeiro que alguém conferiu
        let instrucoes = AnaliseDeBordo.instrucoesDoCatalogo
        for id in ids { #expect(instrucoes.contains("\(id) ="), Comment(rawValue: id)) }
    }

    /// ADR 06g: a lista que a Siri e os Atalhos oferecem é a mesma do catálogo.
    /// Era um `AppEnum` de nove casos — 9 de 21 formas alcançáveis por voz.
    @MainActor @Test func osAtalhosOferecemOCatalogoInteiro() async throws {
        let oferecidas = try await FormaQuery().suggestedEntities()
        #expect(oferecidas.map(\.id) == Catalogo.todos.map(\.id))
        #expect(oferecidas.count == Catalogo.todos.count)
        let woop = try #require(oferecidas.first { $0.id == "woop" })
        #expect(woop.gesto == .woop)
        #expect(woop.nome == Gesto.woop.nome)
        // e um id que saiu da pasta não vira gesto de mentira
        #expect(FormaEntity(id: "metodoQueSumiu", nome: "x").gesto == nil)
    }

    @Test func oEstadoTemSempreUmaFrase() throws {
        guard #available(iOS 26.0, *) else { return }
        #expect(!AnaliseDeBordo.estadoEmPalavras.isEmpty)
    }

    /// O selo: expressiva jamais é reclassificada, nem no aparelho.
    @Test func aExpressivaNaoPassaPorAqui() async throws {
        guard #available(iOS 26.0, *) else { return }
        let v = await AnaliseDeBordo.classificarSemPortao(texto: "hoje foi pesado demais",
                                                          gestoAtual: .expressiva)
        #expect(v == nil)
    }

    @Test func textoVazioNaoChamaOModelo() async throws {
        guard #available(iOS 26.0, *) else { return }
        #expect(await AnaliseDeBordo.classificarSemPortao(texto: "   \n  ", gestoAtual: nil) == nil)
    }

    /// A prova de verdade: o modelo do sistema roteia um WOOP sem rede nenhuma.
    @Test func oModeloDoAparelhoRoteiaUmDesejo() async throws {
        guard #available(iOS 26.0, *), AnaliseDeBordo.disponivel else { return }
        // pela porta sem portão: a suíte desliga os modelos (ADR 03p), e é
        // justamente aqui que queremos o modelo LIGADO
        let v = await AnaliseDeBordo.classificarSemPortao(
            texto: "quero começar a correr de manhã três vezes por semana",
            gestoAtual: nil)
        let veredito = try #require(v)
        if case .gesto(let g, _) = veredito {
            #expect(g == .woop)
        } else {
            // silêncio é resposta válida (§19.4) — o que NÃO pode é aviso
            if case .aviso = veredito { Issue.record("de bordo devolveu aviso para um desejo") }
        }
    }
}

/// ADR 2026-09-03n — cada forma carrega o movimento do próprio método.
@Suite struct MetodoDasFormasTests {
    @Test func todaFormaTemMetodo() {
        for g in Gesto.allCases where g != .expressiva {
            #expect(!g.metodo.isEmpty, "\(g.nome) sem método")
        }
        // menos a expressiva: o selo diz que a sábia não entra ali
        #expect(Gesto.expressiva.metodo.isEmpty)
    }

    /// O método nomeia o movimento que o autor pula sozinho — não é sinônimo
    /// do nome da forma. Estes são os que a literatura diz serem os pulados.
    @Test func oMetodoNomeiaOMovimentoQueSePula() {
        #expect(Gesto.woop.metodo.contains("INTERNO"))
        #expect(Gesto.premortem.metodo.contains("JÁ FALHOU"))
        #expect(Gesto.spec.metodo.contains("EXPLICITAMENTE de fora"))
        #expect(Gesto.seEntao.metodo.contains("SUBSTITUTO"))
        #expect(Gesto.decisao.metodo.contains("CRITÉRIO"))
    }

    /// A instigação não pode virar sugestão de texto: o contrato de saída
    /// continua sendo só perguntas (§2 + ADR o).
    @Test func aInstigacaoSoAceitaPerguntas() {
        #expect(Sabia.parsePerguntas(#"{"perguntas":["Qual é o obstáculo interno?"]}"#)?.count == 1)
        #expect(Sabia.parsePerguntas(#"{"perguntas":["Escreva assim: o obstáculo é o medo."]}"#)?
            .isEmpty != false)
    }
}

/// ADR 2026-09-03o — a leitura da calibragem. É o único lugar do app onde a IA
/// olha para o AUTOR. Um espelho que inventa é pior que nenhum, então a prova
/// literal é a coisa mais testada aqui.
@Suite struct LeituraDaCalibragemTests {
    let pares = [
        "escolha: migrar o banco agora ou depois do lançamento\nesperava: duas semanas de trabalho\naconteceu: levou seis semanas e travou o lançamento",
        "escolha: contratar um sênior ou dois plenos\nesperava: o sênior resolveria o backlog em um mês\naconteceu: o backlog cresceu, faltava contexto e não braço",
    ]

    @Test func aPerguntaComCitacaoLiteralPassa() {
        let r = Sabia.parseCalibragem(
            #"{"perguntas":["Você escreveu “duas semanas de trabalho” — o que fazia esse prazo parecer seguro?"]}"#,
            pares: pares)
        #expect(r?.count == 1)
    }

    @Test func aCitacaoInventadaEDescartada() {
        #expect(Sabia.parseCalibragem(
            #"{"perguntas":["Você escreveu “eu sempre subestimo prazos” — por quê?"]}"#,
            pares: pares)?.isEmpty == true)
    }

    /// Veredito não passa: nem sem "?", nem como elogio, nem como diagnóstico.
    @Test func vereditoNaoPassa() {
        #expect(Sabia.parseCalibragem(
            #"{"perguntas":["Você subestima prazos em “duas semanas de trabalho”."]}"#,
            pares: pares)?.isEmpty == true)
    }

    @Test func semJsonNadaPassa() {
        #expect(Sabia.parseCalibragem("você erra prazos, sempre", pares: pares) == nil)
        #expect(Sabia.parseCalibragem(#"{"perguntas":[]}"#, pares: pares)?.isEmpty == true)
    }

    /// Um par não é padrão: com menos de dois, a leitura seria adivinhação.
    @Test func umParSoNaoEPadrao() async {
        #expect(await Sabia.lerCalibragem(pares: [pares[0]]) == nil)
        #expect(await Sabia.lerCalibragem(pares: []) == nil)
    }

    @Test func oTetoDeTresSegura() {
        let itens = (1...6).map {
            #"{"perguntas":["Sobre “duas semanas de trabalho”, pergunta \#($0)?"]}"#
        }
        _ = itens
        let muitas = #"{"perguntas":["A “duas semanas de trabalho”?","B “seis semanas”?","C “um mês”?","D “dois plenos”?"]}"#
        #expect(Sabia.parseCalibragem(muitas, pares: pares)?.count == 3)
    }
}

/// ADR 2026-09-03p — o portão. Suíte que gasta a assinatura do autor e
/// varredura não-determinística são defeitos de projeto, não detalhes.
@Suite struct PortaoDosModelosTests {
    @Test func naSuiteOsModelosEstaoDesligados() {
        #expect(Motores.desligados)
    }

    /// E desligado significa NADA sai: o cliente único devolve nil antes de
    /// olhar token, rede ou memo.
    @Test func oClienteNaoChamaComOPortaoFechado() async {
        #expect(await Grok.responder(sistema: "s", usuario: "u", temperatura: 0) == nil)
    }

    /// O motor do aparelho também: o portão vale para os dois, senão a
    /// varredura ficava determinística só pela metade.
    @Test func oMotorDoAparelhoRespeitaOPortao() async throws {
        guard #available(iOS 26.0, *) else { return }
        #expect(await AnaliseDeBordo.classificar(texto: "quero correr", gestoAtual: nil) == nil)
    }
}
