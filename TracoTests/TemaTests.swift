import Foundation
import SwiftUI
import Testing
@testable import Traco

/// ADR 2026-09-05t, 05v e 05y: com "Reduzir movimento", quem decide é `Tema`,
/// num lugar só, por classe de movimento. A gaveta do Caderno e o morph do
/// Calendário têm nome próprio, mas seguem a MESMA lei — e a lei é o corte.
struct TemaTests {
    /// A desambiguação da 05y: `.deslocamento` sob reduzido CORTA. Antes
    /// devolvia `fadeReduzido` (0,15 s), que é uma duração menor e não um
    /// corte: a geometria seguia interpolada e dois textos legíveis podiam
    /// ocupar as mesmas linhas — mais lento COM Reduzir Movimento do que sem.
    @Test func movimentoReduzidoCorta() {
        let mola = Tema.Mola.camada
        #expect(Tema.animacao(mola, reduzido: true) == nil)
        #expect(Tema.animacao(mola, reduzido: false) == mola)
    }

    /// Sob reduzido só a opacidade sobrevive; todo o resto devolve nil.
    @Test func soAOpacidadeAnimaSobReduzido() {
        let normal = Animation.easeOut(duration: Tema.Duracao.media)
        for classe: Tema.Movimento in [.deslocamento, .escala, .laco] {
            #expect(Tema.movimento(classe, normal, reduzido: true) == nil)
        }
        #expect(Tema.movimento(.opacidade, normal, reduzido: true) == normal)
    }

    @Test func gavetaECalendarioSeguemAMesmaLei() {
        #expect(Tema.gaveta(reduzido: true) == nil)
        #expect(Tema.gaveta(reduzido: false) != nil)
        #expect(CalendarioTema.morph(true) == nil)
        #expect(CalendarioTema.morph(false) == Tema.Mola.escala)
    }

    /// G4 da volta 8: o que se arrasta com o dedo corta seco em reduzido —
    /// nil, nenhum fade, nenhum quadro em que o painel some sob o dedo.
    @Test func oQueSeArrastaCortaSecoEmReduzido() {
        let mola = Tema.Mola.camada
        #expect(Tema.corte(mola, reduzido: true) == nil)
        #expect(Tema.corte(mola, reduzido: false) == mola)
    }

    // MARK: - A lei por classe (05v)

    @Test func deslocamentoCorta() {
        #expect(Tema.movimento(.deslocamento, Tema.Mola.teclado, reduzido: true) == nil)
        #expect(Tema.movimento(.deslocamento, Tema.Mola.teclado, reduzido: false) == Tema.Mola.teclado)
    }

    @Test func escalaNaoAnima() {
        let entra = Animation.easeOut(duration: Tema.Duracao.media)
        #expect(Tema.movimento(.escala, entra, reduzido: true) == nil)
        #expect(Tema.movimento(.escala, entra, reduzido: false) == entra)
        // pressão é escala: o press e o soltar param
        #expect(Tema.pressaoAnim(true, reduzido: true) == nil)
        #expect(Tema.pressaoAnim(false, reduzido: true) == nil)
        #expect(Tema.pressaoAnim(false, reduzido: false) == Tema.Mola.toque)
    }

    @Test func opacidadeSeMantem() {
        let fade = Animation.easeOut(duration: Tema.Duracao.fecho)
        #expect(Tema.movimento(.opacidade, fade, reduzido: true) == fade)
    }

    @Test func lacoPara() {
        let pulso = Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)
        #expect(Tema.movimento(.laco, pulso, reduzido: true) == nil)
        #expect(Tema.movimento(.laco, pulso, reduzido: false) == pulso)
    }

    // MARK: - Nenhum literal solto (05v)

    /// Os arquivos da V10-A não têm mais duração nem mola em número: tudo cita
    /// `Tema.Duracao` e `Tema.Mola`. O único lugar com número é o próprio Tema.
    @Test func nenhumLiteralDeDuracaoOuMolaNosArquivosDaV10A() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let arquivos = [
            "Traco/Calendario/CalendarioTema.swift",
            "Traco/Calendario/CalendarioView.swift",
            "Traco/Calendario/CalendarioEscalas.swift",
            "Traco/Pagina/PaginaView.swift",
            "Traco/Pagina/CamposFormaView.swift",
            "Traco/Pagina/CartaoAnaliseView.swift",
            "Traco/Caderno/CadernoView.swift",
            "Traco/Caderno/EditorBlocoView.swift",
            "Traco/App/Camadas.swift",
            "Traco/App/BarraNavegacao.swift",
            "Traco/App/RaizView.swift",
            "Traco/Padroes/PadroesView.swift",
            "Traco/Notas/RedeView.swift",
            "Traco/Confirmacao/ConfirmacaoView.swift",
            "Traco/Confirmacao/FechoExpressivaView.swift",
            "Traco/Confirmacao/Queima.swift",
        ]
        let solto = try Regex(#"duration:\s*[0-9.]+|\.spring\(response:|dampingFraction:\s*[0-9]|interpolatingSpring\("#)
        var achados: [String] = []
        for caminho in arquivos {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            for (n, linha) in texto.split(separator: "\n", omittingEmptySubsequences: false).enumerated()
            where linha.contains(solto) && !linha.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                achados.append("\(caminho):\(n + 1): \(linha.trimmingCharacters(in: .whitespaces))")
            }
        }
        #expect(achados.isEmpty, "literais soltos:\n\(achados.joined(separator: "\n"))")
    }

    // MARK: - Página e Caderno até 9 (V12)

    /// A Página e o Caderno não desenham por conta própria o que Componentes
    /// já tem: rótulo de seção (`.rotulo`), estilo de botão (`.discreto`,
    /// `.primario`, `.compacto`) e a lei de movimento por classe (nenhuma
    /// mola emprestada sob `.deslocamento`); e nenhum estilo de Componentes
    /// pressiona por opacidade (ADR 02h).
    @Test func paginaECadernoCitamComponentesENaoPressionamPorOpacidade() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let arquivos = [
            "Traco/Pagina/PaginaView.swift",
            "Traco/Pagina/CamposFormaView.swift",
            "Traco/Pagina/CartaoAnaliseView.swift",
            "Traco/Caderno/CadernoView.swift",
            "Traco/Caderno/EditorBlocoView.swift",
            "Traco/Caderno/PortalArquivoView.swift",
            "Traco/Caderno/PortalCodigoView.swift",
            "Traco/Componentes/Botao.swift",
        ]
        let solto = try Regex(#"tracking\(Tema\.trackingLabel\)|buttonStyle\(PressaoDiscreta\(\)\)|movimento\(\.deslocamento, Tema\.Mola|^\s*\.opacity\(configuration\.isPressed"#)
        var achados: [String] = []
        for caminho in arquivos {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            for (n, linha) in texto.split(separator: "\n", omittingEmptySubsequences: false).enumerated()
            where linha.contains(solto) && !linha.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                achados.append("\(caminho):\(n + 1): \(linha.trimmingCharacters(in: .whitespaces))")
            }
        }
        #expect(achados.isEmpty, "desenho por conta própria:\n\(achados.joined(separator: "\n"))")
    }

    // MARK: - Os dois comportamentos da 05y que não tinham teste (G3 da V12, M1)

    /// Re-G3 da volta 7: soltar a camada pede o alvo, mas o binding pode
    /// RECUSAR (o timer da expressiva de pé abre confirmação e `Sessao.irPara`
    /// recusa de forma síncrona). Quando recusa, a posição volta ao estado real
    /// — senão a camada fica à mostra e não recebe toque. Quando aceita, nada é
    /// re-cravado: a mola já parou no lugar, e um segundo alvo re-acelera.
    @Test func camadaDevolveAPosicaoQuandoOBindingRecusa() {
        let w: CGFloat = 393
        // pediu abrir e o binding recusou: volta para fora da tela
        #expect(Trilho.posicaoAposRecusa(alvoPedido: true, arquivoAberto: false, largura: w) == -w)
        // pediu fechar e o binding recusou: volta para o arquivo à mostra
        #expect(Trilho.posicaoAposRecusa(alvoPedido: false, arquivoAberto: true, largura: w) == 0)
        // aceitou nos dois sentidos: nada a corrigir
        #expect(Trilho.posicaoAposRecusa(alvoPedido: true, arquivoAberto: true, largura: w) == nil)
        #expect(Trilho.posicaoAposRecusa(alvoPedido: false, arquivoAberto: false, largura: w) == nil)
    }

    /// Custo assumido da 05y: a régua cede ao cartão SÓ em tamanho de
    /// acessibilidade. Em `large` ela fica, com cartão ou sem — o G3 mediu isso
    /// na tela e a suíte passa a segurar.
    @Test func reguaSoCedeAoCartaoEmTamanhoAX() {
        let cartao = CartaoAnalisar.forma(.woop, pergunta: "?")
        #expect(PaginaView.esconderRegua(cartao: cartao, tamanho: .accessibility1))
        #expect(PaginaView.esconderRegua(cartao: cartao, tamanho: .accessibility5))
        // tamanhos não-AX: a régua fica, cartão ou não
        for tamanho in [DynamicTypeSize.xSmall, .large, .xxxLarge] {
            #expect(!PaginaView.esconderRegua(cartao: cartao, tamanho: tamanho))
        }
        // sem cartão nada esconde, nem em AX5
        #expect(!PaginaView.esconderRegua(cartao: nil, tamanho: .accessibility5))
    }

    // MARK: - O piso do papel (05y, correção do G4)

    /// A regra do dono: com o teclado de pé, o texto que o autor escreve fica
    /// à vista. O G4 mediu 413 pt de encaixe para 33 pt de papel — o teto do
    /// cartão era absoluto (440/380) e quem pagava era a única parte elástica.
    /// Agora o encaixe leva o que SOBRA depois do pé e do piso.
    @Test func oPapelTemPiso() throws {
        // `large`, teclado de pé: 446 pt disponíveis, pé de 90, piso de 92
        #expect(CadernoView.tetoDoEncaixe(altura: 446, pe: 90, piso: 92) == 264)
        // o papel fica com o piso inteiro: 446 − 90 − 264 = 92
        // apertado (AX5): três linhas de corpo não cabem, o piso cede até
        // metade do que sobra — mas nunca abaixo de UMA linha (piso / 3)
        let apertado = CadernoView.tetoDoEncaixe(altura: 446, pe: 300, piso: 280)
        let umaLinha: CGFloat = 280 / 3
        #expect(apertado == 146 - umaLinha) // papel 93,3 (uma linha), não 73

        // O 17e em AX XXXL, MEDIDO (ADR 09d, sonda em `tetoDoEncaixe`):
        // 413,67 pt disponíveis, pé de 274,67, piso de 259,33 — a metade dava
        // 69,5 pt de papel para uma linha de corpo de 67, e a linha não cabia
        // em quadro nenhum, com ou sem rolagem. Agora o papel leva uma linha
        // inteira (86,4) e ainda sobra encaixe.
        let altura17: CGFloat = 413.6667
        let pe17: CGFloat = 274.6667
        let piso17: CGFloat = 259.3333
        let e17 = try #require(CadernoView.tetoDoEncaixe(altura: altura17, pe: pe17, piso: piso17))
        let papel17: CGFloat = altura17 - pe17 - e17
        #expect(papel17 > 67) // uma linha de corpo em AX XXXL
        #expect(e17 > 0)      // e ainda sobra encaixe: o cartão não some

        // com o aviso o pé sobe a 326,67 e sobram 87: aí o papel toma tudo —
        // a letra do autor à vista vale mais que a saída do cartão (09d)
        let peAviso: CGFloat = 326.6667
        let eAviso = try #require(CadernoView.tetoDoEncaixe(altura: altura17, pe: peAviso, piso: piso17))
        #expect(eAviso < 1) // o encaixe cede inteiro: sobram 87 pt para a linha
        // sem medida ainda, ou pé maior que a tela: nada de teto, nada achatado
        #expect(CadernoView.tetoDoEncaixe(altura: 0, pe: 0, piso: 92) == nil)
        #expect(CadernoView.tetoDoEncaixe(altura: 400, pe: 400, piso: 92) == nil)
    }

    /// O que a 09d mudou ONDE HAVIA FOLGA SOBRANDO — a pergunta do re-G3 da C1,
    /// que a prova do 17e não respondia: a invariante da 08f fora provada no Pro
    /// Max, e a regra nova faz a folga ceder antes da letra. A regra velha (05y)
    /// era `min(piso, sobra / 2)`; a nova só acrescenta o CHÃO de uma linha.
    /// Onde meia sobra já dava uma linha — que é todo aparelho com tela grande, o
    /// Pro Max inclusive —, as duas dão o MESMO número, e onde não dava, a nova
    /// dá estritamente MAIS papel. Varrido, não amostrado, e sem aparelho: é
    /// aritmética, e vale para os que ainda não existem.
    @Test func ondeHaviaFolgaSobrandoA09dNaoMudaNada() {
        var apertadas = 0, comFolga = 0
        for altura in stride(from: CGFloat(300), through: 900, by: 25) {
            for pe in stride(from: CGFloat(40), through: 400, by: 15) {
                for piso in [CGFloat(92), 160, 200, 259.3333, 280] {
                    let sobra = altura - pe
                    guard sobra > 0, let teto = CadernoView.tetoDoEncaixe(altura: altura, pe: pe, piso: piso) else { continue }
                    let velho = min(piso, sobra / 2) // a regra da 05y
                    let novo = sobra - teto
                    if sobra / 2 >= piso / 3 {
                        #expect(abs(novo - velho) < 0.001,
                                "com folga sobrando (sobra \(sobra), piso \(piso)) a regra mudou: \(velho) -> \(novo)")
                        comFolga += 1
                    } else {
                        #expect(novo > velho,
                                "apertado (sobra \(sobra), piso \(piso)): a regra tinha de dar MAIS papel, deu \(novo) contra \(velho)")
                        apertadas += 1
                    }
                }
            }
        }
        print("PISO: \(comFolga) combinações com folga sobrando (a 09d dá o mesmo que a 05y), \(apertadas) apertadas (a 09d dá mais papel)")
        #expect(comFolga > 0 && apertadas > 0, "a varredura não cobriu os dois lados")
    }

    /// O cartão recolhe-se enquanto o autor escreve, mas o AVISO não — esconder
    /// falha para limpar a tela é o que o contrato proíbe (AGENTS, Fronteiras)
    /// — e a resposta da sábia também não, porque o autor a pediu.
    @Test func oAvisoEARespostaNaoRecolhem() {
        #expect(!CartaoAnaliseView.podeRecolher(.aviso("não consegui guardar")))
        #expect(!CartaoAnaliseView.podeRecolher(.semConta))
        #expect(!CartaoAnaliseView.podeRecolher(.sabiaPensando(pergunta: "q", desde: .now)))
        // a resposta da sábia o autor PEDIU: chega aberta
        #expect(!CartaoAnaliseView.podeRecolher(.resposta(pergunta: "q", texto: "texto longo")))
        #expect(CartaoAnaliseView.podeRecolher(.vestida(.woop, pergunta: "?")))
        #expect(CartaoAnaliseView.podeRecolher(.forma(.woop, pergunta: "?")))
    }

    /// ADR 09n: a espera passou de 1,4 s para 36 s de média (77,5 s no pior
    /// caso medido). O `ProgressView` do sistema girava igual no segundo 1 e
    /// no 70; o que separa "pensando" de "travou" é o número que ANDA.
    /// Os primeiros segundos ficam sem número: até aí é a espera de sempre.
    @Test func aEsperaDaSabiaMostraOTempoDepoisDosPrimeirosSegundos() {
        let inicio = Date(timeIntervalSince1970: 0)
        func frase(_ s: TimeInterval) -> String {
            CartaoAnaliseView.fraseDaEspera(desde: inicio, agora: inicio.addingTimeInterval(s))
        }
        #expect(frase(0) == "a Sábia pensa…")
        #expect(frase(3.9) == "a Sábia pensa…")
        #expect(frase(4) == "a Sábia pensa há 4 s…")
        #expect(frase(36) == "a Sábia pensa há 36 s…")
        #expect(frase(77.5) == "a Sábia pensa há 77 s…")
        // relógio que anda para trás não vira número negativo na tela
        #expect(frase(-5) == "a Sábia pensa…")
    }

    /// ADR 09n: parar de esperar não pode custar o que a pessoa escreveu.
    /// A pergunta volta ao cartão `.pergunta`, que já tem "Perguntar à sábia"
    /// no pé — um toque, e sem redigitar nada. A linha "?" da nota nunca sai.
    @MainActor
    @Test func pararDeEsperarDevolveAPerguntaEmVezDePerdeLa() {
        let s = Sessao()
        s.cartao = .sabiaPensando(pergunta: "por onde começo?", desde: .now)
        s.pararDeEsperarASabia()
        #expect(s.cartao == .pergunta("por onde começo?"))
        // fora da espera, o gesto não mexe em cartão nenhum
        s.cartao = .resposta(pergunta: "q", texto: "t")
        s.pararDeEsperarASabia()
        #expect(s.cartao == .resposta(pergunta: "q", texto: "t"))
    }

    // MARK: - A regra da cor e a caixa alta (ADR 10k, Hermes §5 e §10)

    /// As telas da varredura do sistema não pintam de âmbar nem escrevem em
    /// caixa alta por conta própria. O âmbar é o traço do autor e o agora
    /// (`CalendarioTema.agora`); a caixa alta é do `CabecalhoDeSecao` e do
    /// `.rotulo()` que ele usa. Na árvore de `cfbb19c` este regex achava 37
    /// linhas nestes arquivos; hoje acha zero. Quem precisar de outra cor muda
    /// a regra escrita no `Tema` primeiro — e diz se é identidade ou estado.
    @Test func telasDoSistemaSeguemARegraDaCorEDaCaixaAlta() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let arquivos = [
            "Traco/Perfil/PerfilView.swift",
            "Traco/Padroes/PadroesView.swift",
            "Traco/Pagina/LenteView.swift",
            "Traco/App/TituloTela.swift",
            "Traco/Calendario/CalendarioView.swift",
            "Traco/Calendario/CalendarioFicha.swift",
            "Traco/Calendario/CalendarioFichaSistema.swift",
            "Traco/Calendario/CalendarioEscalas.swift",
            "Traco/Calendario/DoCadernoView.swift",
        ]
        let proibido = try Regex(#"Tema\.ambar|\.uppercased\(\)|textCase\(\.uppercase\)|Tema\.label\b|trackingLabel"#)
        // a sonda que acusa tem irmã que não acusa: pega o defeito velho e
        // deixa passar o agora do calendário e o rótulo de seção sancionado
        #expect("    .foregroundStyle(Tema.ambarTinta)".contains(proibido))
        #expect(#"Text(g.nome.uppercased())"#.contains(proibido))
        #expect(#"    .font(Tema.label)"#.contains(proibido))
        #expect(!"    .fill(CalendarioTema.agora)".contains(proibido))
        #expect(!#"    Text("Quando").rotulo(Tema.tintaSuave)"#.contains(proibido))
        var achados: [String] = []
        for caminho in arquivos {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            #expect(texto.contains("View"), "\(caminho) não parece uma tela")
            for (n, linha) in texto.split(separator: "\n", omittingEmptySubsequences: false).enumerated()
            where linha.contains(proibido) && !linha.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                achados.append("\(caminho):\(n + 1): \(linha.trimmingCharacters(in: .whitespaces))")
            }
        }
        #expect(achados.isEmpty, "cor ou caixa alta fora da regra:\n\(achados.joined(separator: "\n"))")
    }

    /// Dono, 17/09: a tarefa feita é visto VERDE, legível no papel, e as três
    /// telas que desenham a tarefa usam o mesmo círculo (`VistoDaTarefa`).
    @Test func aTarefaFeitaEVistoVerdeNasTresTelas() throws {
        func componentes(_ c: Color) -> (Double, Double, Double) {
            var (r, g, b, a) = (CGFloat.zero, CGFloat.zero, CGFloat.zero, CGFloat.zero)
            UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
            return (Double(r), Double(g), Double(b))
        }
        func luz(_ c: Color) -> Double {
            let (r, g, b) = componentes(c)
            let lin = { (x: Double) in x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4) }
            return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
        }
        let (r, g, b) = componentes(Tema.feito)
        #expect(g > r && g > b, "o visto é verde")
        #expect((luz(Tema.fundo) + 0.05) / (luz(Tema.feito) + 0.05) >= 4.5, "legível sobre o papel")
        #expect(componentes(Tema.feito) != componentes(Tema.sabia), "estado não empresta a identidade da Sábia")

        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let prosa = try String(contentsOf: raiz.appending(path: "Traco/Caderno/ProsaView.swift"), encoding: .utf8)
        #expect(prosa.contains("feito ? Tema.feito : Tema.tintaFraca"))
        #expect(prosa.contains("Toque.leve()") && prosa.contains("Tema.movimento(.opacidade"))
        for caminho in ["Traco/Caderno/ProsaView.swift", "Traco/Caderno/CadernoView.swift", "Traco/Caderno/EditorBlocoView.swift"] {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            #expect(texto.contains("VistoDaTarefa(feito:"), "\(caminho) desenha a tarefa por conta própria")
            #expect(!texto.contains("feito ? Tema.tintaSuave"), "\(caminho) ainda pinta o visto de cinza")
        }
    }
}
