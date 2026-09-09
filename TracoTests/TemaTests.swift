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
            "Traco/Caderno/MenuFormasView.swift",
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

        // O 17e em AX XXXL, MEDIDO (ADR 08w, sonda em `tetoDoEncaixe`):
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
        // a letra do autor à vista vale mais que a saída do cartão (08w)
        let peAviso: CGFloat = 326.6667
        let eAviso = try #require(CadernoView.tetoDoEncaixe(altura: altura17, pe: peAviso, piso: piso17))
        #expect(eAviso < 1) // o encaixe cede inteiro: sobram 87 pt para a linha
        // sem medida ainda, ou pé maior que a tela: nada de teto, nada achatado
        #expect(CadernoView.tetoDoEncaixe(altura: 0, pe: 0, piso: 92) == nil)
        #expect(CadernoView.tetoDoEncaixe(altura: 400, pe: 400, piso: 92) == nil)
    }

    /// O cartão recolhe-se enquanto o autor escreve, mas o AVISO não — esconder
    /// falha para limpar a tela é o que o contrato proíbe (AGENTS, Fronteiras)
    /// — e a resposta da sábia também não, porque o autor a pediu.
    @Test func oAvisoEARespostaNaoRecolhem() {
        #expect(!CartaoAnaliseView.podeRecolher(.aviso("não consegui guardar")))
        #expect(!CartaoAnaliseView.podeRecolher(.semConta))
        #expect(!CartaoAnaliseView.podeRecolher(.sabiaPensando))
        // a resposta da sábia o autor PEDIU: chega aberta
        #expect(!CartaoAnaliseView.podeRecolher(.resposta(pergunta: "q", texto: "texto longo")))
        #expect(CartaoAnaliseView.podeRecolher(.vestida(.woop, pergunta: "?")))
        #expect(CartaoAnaliseView.podeRecolher(.forma(.woop, pergunta: "?")))
    }
}
