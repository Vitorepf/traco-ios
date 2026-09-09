import SwiftUI
import Testing
import UIKit
@testable import Traco

/// A3 da revisão da V19: `Pilula` desabilitada devolvia `tintaMorta` (#C7C7CC)
/// para TODOS os chamadores — **1,53:1** sobre o papel. Texto que não se lê não
/// é estado desabilitado, é texto apagado; a `TrabalhoView` chegou a contornar o
/// componente por causa disto (o comentário está lá, em "Bloqueio").
///
/// Este é o portão: a tinta da cápsula sai de `Pilula.tinta(ativa:cheia:forma:)`
/// e mede-se aqui, sobre TODOS os fundos onde uma cápsula pousa no mundo claro.
struct PilulaContrasteTests {
    /// Os fundos que existem debaixo de uma cápsula (SISTEMA-CLARO §2.3).
    static let fundos: [(String, Color)] = [
        ("papel", Tema.fundo),
        ("chip", Tema.chip),
        ("superfície", Tema.superficie),
        ("névoa", Tema.superficieBaixa),
    ]

    @Test func aCapsulaDesabilitadaSeLeEmTodoFundo() {
        let tinta = Pilula<Text>.tinta(ativa: false, cheia: false, forma: .filtro)
        for (nome, fundo) in Self.fundos {
            let razao = contraste(tinta, fundo)
            #expect(razao >= 4.5, "desabilitada sobre \(nome): \(razao)")
        }
    }

    /// Desabilitada é a MESMA tinta em toda forma: o defeito era global e a
    /// correção também tem de ser — nenhum chamador fica com o cinza morto.
    @Test func nenhumaFormaVoltaAoCinzaMorto() {
        let morta = corDe(Tema.tintaMorta)
        for forma: Pilula<Text>.Forma in [.filtro, .controle, .acao, .larga, .etiqueta] {
            let tinta = corDe(Pilula<Text>.tinta(ativa: false, cheia: false, forma: forma))
            #expect(tinta != morta, "forma \(forma) voltou a tintaMorta")
        }
    }

    /// A conta que a ADR cita: o cinza morto reprova, o cinza fraco passa.
    @Test func aContaColadaNaADRConfere() {
        #expect(contraste(Tema.tintaMorta, Tema.fundo) < 2)
        #expect(abs(contraste(Tema.tintaFraca, Tema.fundo) - 5.04) < 0.05)
    }

    // MARK: - WCAG 2.2, 1.4.3

    private func corDe(_ c: Color) -> [CGFloat] {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r, g, b, a]
    }

    private func luminancia(_ c: Color) -> Double {
        let comp = corDe(c).prefix(3).map { canal -> Double in
            let v = Double(canal)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * comp[0] + 0.7152 * comp[1] + 0.0722 * comp[2]
    }

    private func contraste(_ a: Color, _ b: Color) -> Double {
        let la = luminancia(a), lb = luminancia(b)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }
}
