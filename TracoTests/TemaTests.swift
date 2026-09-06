import Foundation
import SwiftUI
import Testing
@testable import Traco

/// ADR 2026-09-05t e 05v: com "Reduzir movimento", quem decide é `Tema`, num
/// lugar só, por classe de movimento. A gaveta do Caderno e o morph do
/// Calendário têm nome próprio, mas devolvem o MESMO fade.
struct TemaTests {
    @Test func movimentoReduzidoViraFadeCurto() {
        let mola = Tema.Mola.camada
        #expect(Tema.animacao(mola, reduzido: true) == Tema.fadeReduzido)
        #expect(Tema.animacao(mola, reduzido: false) == mola)
        #expect(Tema.fadeReduzido == .easeOut(duration: Tema.Duracao.curta))
    }

    @Test func gavetaECalendarioSeguemAMesmaLei() {
        #expect(Tema.gaveta(reduzido: true) == Tema.fadeReduzido)
        #expect(Tema.gaveta(reduzido: false) != Tema.fadeReduzido)
        #expect(CalendarioTema.morph(true) == Tema.fadeReduzido)
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

    @Test func deslocamentoViraFadeCurta() {
        #expect(Tema.movimento(.deslocamento, Tema.Mola.teclado, reduzido: true) == Tema.fadeReduzido)
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
        let pulso = Animation.easeInOut(duration: Tema.Duracao.pulso).repeatForever(autoreverses: true)
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
}
