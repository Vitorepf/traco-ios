import Foundation
import Testing
@testable import Traco

/// A RETOMADA — item 4 da fila do dono, ADR 2026-09-08y. O autor volta depois
/// de um dia e continua **sem reconstruir o contexto**.
///
/// A auditoria de 08/09 na tela viva, com estado plantado, mediu na árvore de
/// AX (frames em alturas de tela, a partir do topo da folha) o que a retomada
/// NÃO contava: a versão nova estava a **1,57 tela**, o resultado que o próprio
/// autor informou a **2,45**, e a data desse relato a **3,76**. O documento
/// inteiro tem 4,74 telas. O "Continuar" e o "Último retorno" já estavam no
/// alto — o que faltava era **o que mudou**, junto e datado.
///
/// Estes testes ficam vermelhos se a retomada voltar a apontar para o lugar
/// errado, nos dois sentidos do erro: contar a coisa errada (a janela) e
/// mandar a rolagem para uma âncora que não existe.
@MainActor
struct RetomadaTrabalhoTests {
    /// Um dia de trabalho no dia 7 — versão preparada, apoio decidido, trecho
    /// delimitado, ato realizado, resultado informado e dificuldade registrada
    /// — visto do dia 8. As datas são explícitas: nada aqui depende de `.now`.
    static func trabalhoDoDia7() throws -> (DocumentoTrabalho, Date) {
        let dia5 = Date(timeIntervalSinceReferenceDate: 810_000_000)
        let dia7 = dia5.addingTimeInterval(2 * 86_400)
        var d = DocumentoTrabalho(intencao: "Apresentar minha ideia para a diretoria",
                                  resultado: "Explicar a proposta em cinco minutos")
        // A versão VELHA: do dia 5, antes da visita. Não pode aparecer.
        let pedidoVelho = try d.iniciarPedido("Um roteiro de cinco minutos")
        try d.receber("# Roteiro\n\nAbertura longa.", produtor: "Grok", pedidoID: pedidoVelho.id)
        d.artefatos[0].data = dia5
        d.pedidos[0].data = dia5

        let pedidoNovo = try d.iniciarPedido("Encurtar a abertura")
        try d.receber("# Roteiro\n\nAbertura curta.", produtor: "Grok", pedidoID: pedidoNovo.id)
        d.artefatos[1].data = dia7.addingTimeInterval(3_600)
        d.apoio = .combinar
        d.apoioMarcadoEm = dia7.addingTimeInterval(7_200)
        d.trechoExercitado = "a abertura de trinta segundos"
        d.trechoDelimitadoEm = dia7.addingTimeInterval(7_300)

        try d.prepararAcao("Ler a abertura em voz alta para a Ana")
        let ato = try #require(d.acoes.last)
        try d.marcarExecutada(ato.id)
        d.acoes[d.acoes.count - 1].executadaEm = dia7.addingTimeInterval(10_800)
        try d.registrarRelato("O segundo bloco arrastou.", acaoID: ato.id, resultado: .parcial)
        d.evidencias[d.evidencias.count - 1].data = dia7.addingTimeInterval(12_000)
        _ = try d.proporHipotese("eu explico o problema duas vezes", propostaPor: "Você")
        d.hipoteses[d.hipoteses.count - 1].data = dia7.addingTimeInterval(13_000)
        return (d, dia5.addingTimeInterval(86_400))  // a visita anterior: dia 6
    }

    @Test func oResumoContaOQueHouveDepoisDaVisitaENadaDeAntes() throws {
        let (d, visita) = try Self.trabalhoDoDia7()
        let textos = d.mudancasDesde(visita).map(\.texto)

        // O que o app SABE que aconteceu, porque tem os vínculos:
        #expect(textos.contains("Versão 2 preparada por Grok"))
        #expect(textos.contains("Apoio marcado: Combinar"))
        #expect(textos.contains("Trecho que você vai exercitar: a abertura de trinta segundos"))
        #expect(textos.contains("Você marcou como realizada: Ler a abertura em voz alta para a Ana"))
        #expect(textos.contains("Resultado que você informou: Funcionou em parte"))
        #expect(textos.contains("Dificuldade registrada: eu explico o problema duas vezes"))

        // A versão do dia 5 está ANTES da visita: contá-la seria dizer que uma
        // coisa velha é novidade — o defeito 3 do G0, na direção contrária.
        #expect(!textos.contains { $0.contains("Versão 1") })

        // Mais recente primeiro: quem volta lê a última notícia sem procurar.
        let datas = d.mudancasDesde(visita).map(\.data)
        #expect(datas == datas.sorted(by: >))
    }

    @Test func semNovidadeOResumoCalaEmVezDeFalarDoVelho() throws {
        let (d, _) = try Self.trabalhoDoDia7()
        let depoisDeTudo = try #require(d.evidencias.last).data.addingTimeInterval(86_400)
        #expect(d.mudancasDesde(depoisDeTudo).isEmpty)
    }

    /// ADR 08m: executar e observar são eixos distintos. Marcar realizada e
    /// informar o resultado dão DUAS linhas, com as datas de cada uma; uma
    /// linha só resumiria o outro eixo, que é o que a E1 separou.
    @Test func atoRealizadoEResultadoInformadoSaoDuasLinhas() throws {
        let (d, visita) = try Self.trabalhoDoDia7()
        let mudancas = d.mudancasDesde(visita)
        let realizada = try #require(mudancas.first { $0.texto.hasPrefix("Você marcou como realizada") })
        let resultado = try #require(mudancas.first { $0.texto.hasPrefix("Resultado que você informou") })
        #expect(realizada.data < resultado.data)
        // A linha do relato carrega a evidência de onde saiu: é assim que a
        // folha evita mostrar a mesma notícia duas vezes na mesma tela.
        #expect(resultado.evidenciaID == d.evidencias.last?.id)
        #expect(realizada.evidenciaID == nil)
    }

    /// Decisão sem data no registro antigo não vira data inventada.
    @Test func decisaoSemDataNaoEntraNoResumo() throws {
        var (d, visita) = try Self.trabalhoDoDia7()
        d.apoioMarcadoEm = nil
        d.trechoDelimitadoEm = nil
        let textos = d.mudancasDesde(visita).map(\.texto)
        #expect(!textos.contains { $0.hasPrefix("Apoio marcado") })
        #expect(!textos.contains { $0.hasPrefix("Trecho que você vai exercitar") })
    }

    /// O PORTÃO DA ÂNCORA. A retomada rola por nome (`rolarPara = "x"`), e o
    /// destino é um `.id("x")` noutro ponto do mesmo arquivo — ou a `chave` de
    /// um `campo(…)`, que o helper marca com `.id(chave)`. Renomear uma das
    /// pontas não quebra a compilação: o toque simplesmente não leva a lugar
    /// nenhum, em silêncio. Este teste fica vermelho nesse dia.
    ///
    /// **A conta, medida em 08/09 antes de congelar** (a regex crua contava
    /// menos do que devia: dois destinos moram num ternário e dois são chaves
    /// de campo). Reproduz-se sem compilar nada:
    ///
    /// ```
    /// grep -n 'rolarPara = ' Traco/Trabalho/TrabalhoView.swift
    /// ```
    ///
    /// São **9** destinos literais hoje — `trabalho-atos`, `trabalho-retorno`,
    /// `trabalho-historico`, `trabalho-erro`, `trabalho-preparando`,
    /// `pratica-adaptando`, `pedido`, `tentativa`, `versao` — e mais dois por
    /// variável (`chave`, `falta`), que este portão não alcança e não finge
    /// alcançar. `versao` entrou com a gaveta que devolve o cursor ao artefato.
    @Test func todaRolagemDaFolhaTemDestinoQueExiste() throws {
        let caminho = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Traco/Trabalho/TrabalhoView.swift")
        let fonte = try String(contentsOf: caminho, encoding: .utf8)
        let literal = /"([a-z][a-z-]*)"/
        var alvos: Set<String> = []
        for linha in fonte.split(separator: "\n") where linha.contains("rolarPara = ") {
            alvos.formUnion(linha.matches(of: literal).map { String($0.output.1) })
        }
        var ancoras = Set(fonte.matches(of: /\.id\("([a-z][a-z-]*)"\)/).map { String($0.output.1) })
        // `campo(…)` marca o campo com `.id(chave)`: a chave também é destino.
        ancoras.formUnion(fonte.matches(of: /chave: "([a-z][a-z-]*)"/).map { String($0.output.1) })
        // sem esta linha uma regex quebrada deixaria a varredura vazia e VERDE
        #expect(alvos.count == 9, "a varredura achou \(alvos.count) destinos: \(alvos.sorted())")
        for alvo in alvos.sorted() {
            #expect(ancoras.contains(alvo), "a folha rola para \"\(alvo)\" e ninguém tem esse .id")
        }
        // C9: a oferta rola por variável (`ancoraDaProximaEstacao`), não por
        // literal em `rolarPara =`. Os três destinos têm de existir no arquivo.
        for alvo in ["trabalho-producao", "trabalho-praticar", "trabalho-atos"] {
            #expect(ancoras.contains(alvo), "a oferta rola para \"\(alvo)\" e ninguém tem esse .id")
        }
        #expect(fonte.contains("trabalho-oferta-retomada"))
        #expect(fonte.contains("trabalho-ir-ao-proximo-passo"))
        #expect(fonte.contains("trabalho-ir-a-estacao"))
        #expect(fonte.contains("trabalho-dificuldade-retomada"))
        #expect(fonte.contains("trabalho-ir-a-dificuldade"))
        #expect(fonte.contains("ancoraDaDificuldade"))
        #expect(ancoras.contains(TrabalhoView.ancoraDaDificuldade),
                "a retomada rola para a dificuldade e ninguém tem esse .id")
        #expect(fonte.contains("else if let oferta"),
                "nó plantado e oferta da jornada não podem aparecer juntos")
        #expect(fonte.contains("abrirGavetaDaVersao"),
                "a gaveta da versão precisa devolver o cursor ao campo")
        #expect(fonte.contains("campoEmFoco = \"versao\""),
                "sem devolver o foco, o teclado fica no pedido")
        #expect(fonte.contains("trabalho-campo-versao"),
                "a primeira versão mora na estação, sem botão a revelar")
        #expect(fonte.contains("trabalho-guardar-versao"))
        #expect(!fonte.contains("trabalho-escrever-versao"),
                "o toque de revelar a primeira versão voltou — a estação é o campo")
    }
}
