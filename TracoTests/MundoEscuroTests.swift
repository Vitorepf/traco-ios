import Foundation
import SwiftUI
import Testing
import UIKit
@testable import Traco

/// O PORTÃO DOS DOIS MUNDOS (ADR 2026-09-17c).
///
/// A 02h prometeu "todo texto mede ≥4,5:1 sobre o papel e todo ícone ≥3,0:1",
/// e a varredura de 04/set mediu a promessa quebrada em 58 lugares. O mundo
/// escuro nasce com a mesma promessa e com a conta feita ANTES da primeira
/// tela: cada tinta, sobre cada fundo onde ela pode pousar, nos DOIS mundos.
///
/// Este arquivo é irmão do `PilulaContrasteTests`, que mede a cápsula no
/// claro. A diferença é que aqui a cor se resolve dentro de uma
/// `UITraitCollection`: um token do `Tema` já não tem um valor, tem dois, e
/// medir sem dizer qual é medir o que der na telha.
struct MundoEscuroTests {
    // MARK: - Resolver um token num mundo

    /// Os componentes de uma cor JÁ RESOLVIDA para um dos dois mundos.
    /// `performAsCurrent` é o que faz o provedor dinâmico correr: sem isso, a
    /// cor cai no mundo corrente do processo (claro, nos testes) e o escuro
    /// nunca seria medido.
    private func componentes(_ c: Color, _ estilo: UIUserInterfaceStyle) -> (r: Double, g: Double, b: Double, a: Double) {
        var saida = (r: 0.0, g: 0.0, b: 0.0, a: 0.0)
        UITraitCollection(userInterfaceStyle: estilo).performAsCurrent {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
            saida = (Double(r), Double(g), Double(b), Double(a))
        }
        return saida
    }

    private func luminancia(_ c: Color, _ estilo: UIUserInterfaceStyle) -> Double {
        let p = componentes(c, estilo)
        let canal = { (v: Double) in v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * canal(p.r) + 0.7152 * canal(p.g) + 0.0722 * canal(p.b)
    }

    /// WCAG 2.2, 1.4.3 — a mesma conta do `PilulaContrasteTests`, num mundo só.
    private func contraste(_ tinta: Color, _ fundo: Color, _ estilo: UIUserInterfaceStyle) -> Double {
        let la = luminancia(tinta, estilo), lb = luminancia(fundo, estilo)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }

    private func hex(_ c: Color, _ estilo: UIUserInterfaceStyle) -> UInt32 {
        let p = componentes(c, estilo)
        return (UInt32((p.r * 255).rounded()) << 16)
            | (UInt32((p.g * 255).rounded()) << 8)
            | UInt32((p.b * 255).rounded())
    }

    /// Os fundos onde uma tinta pode pousar, em qualquer mundo.
    private static let fundos: [(String, Color)] = [
        ("papel", Tema.fundo),
        ("névoa", Tema.superficieBaixa),
        ("chip", Tema.chip),
        ("superfície", Tema.superficie),
    ]

    /// As tintas que carregam TEXTO. `tintaMorta` fica de fora de propósito:
    /// ela é desabilitado real, e desabilitado não é texto que se deve ler
    /// (a lei está no próprio `Tema` e na ADR da `Pilula`).
    private static let tintas: [(String, Color)] = [
        ("tinta", Tema.tinta),
        ("tintaSuave", Tema.tintaSuave),
        ("tintaFraca", Tema.tintaFraca),
        ("ambarTinta", Tema.ambarTinta),
        ("sábia", Tema.sabia),
    ]

    // MARK: - A promessa, nos dois mundos

    /// O piso de 4,5:1 vale igual nos dois. Um mundo escuro que só "parece"
    /// legível é o defeito de 04/set outra vez, com os sinais trocados.
    @Test func todaTintaSeLeNosDoisMundos() {
        for (mundo, estilo) in [("claro", UIUserInterfaceStyle.light), ("escuro", .dark)] {
            for (nomeTinta, tinta) in Self.tintas {
                for (nomeFundo, fundo) in Self.fundos {
                    let razao = contraste(tinta, fundo, estilo)
                    #expect(razao >= 4.5, "\(mundo): \(nomeTinta) sobre \(nomeFundo) mede \(razao)")
                }
            }
        }
    }

    /// O `aviso` fica FORA do laço acima, e a dívida é do mundo claro: o
    /// #B5432F da 02h mede **4,49:1** sobre o chip — um centésimo abaixo do
    /// piso, medido em 17/09. É pré-existente e não se corrige aqui (o dono
    /// disse em 17/09 que o design está no melhor ponto que já esteve, e mover
    /// o vermelho do feriado é mexer no visual sem pedido). O que este teste
    /// faz é CONGELAR a conta: sobre papel, névoa e superfície o piso vale nos
    /// dois mundos, e o número do chip fica escrito para quem for corrigi-lo.
    @Test func oAvisoSeLeOndeEleMora() {
        for (mundo, estilo) in [("claro", UIUserInterfaceStyle.light), ("escuro", .dark)] {
            for (nome, fundo) in [("papel", Tema.fundo), ("névoa", Tema.superficieBaixa),
                                  ("superfície", Tema.superficie)] {
                #expect(contraste(Tema.aviso, fundo, estilo) >= 4.5,
                        "\(mundo): aviso sobre \(nome)")
            }
        }
        // a dívida congelada: 4,49 no claro, 4,85 no escuro
        #expect(abs(contraste(Tema.aviso, Tema.chip, .light) - 4.49) < 0.05)
        #expect(contraste(Tema.aviso, Tema.chip, .dark) >= 4.5)
    }

    /// `sobreAtivo` é a tinta do acento de estado. Ela mora sobre `chipAtivo`
    /// (a aba acesa, o "Hoje", o dia escolhido, a cápsula cheia) e sobre
    /// `aviso` (o disco de parar o ditado). Era `.white` cravado em dez
    /// lugares; no escuro, branco sobre osso seria branco sobre branco.
    @Test func aTintaDoAcentoSeLeSobreOAcento() {
        for (mundo, estilo) in [("claro", UIUserInterfaceStyle.light), ("escuro", .dark)] {
            #expect(contraste(Tema.sobreAtivo, Tema.chipAtivo, estilo) >= 4.5,
                    "\(mundo): sobreAtivo no chipAtivo")
            #expect(contraste(Tema.sobreAtivo, Tema.aviso, estilo) >= 4.5,
                    "\(mundo): sobreAtivo no aviso")
        }
    }

    /// O acento de estado é o objeto de contraste máximo da tela, nos dois
    /// mundos: carvão sobre papel, osso sobre grafite.
    @Test func oAcentoDeEstadoSaltaDoFundo() {
        for (mundo, estilo) in [("claro", UIUserInterfaceStyle.light), ("escuro", .dark)] {
            #expect(contraste(Tema.chipAtivo, Tema.fundo, estilo) >= 10,
                    "\(mundo): chipAtivo contra o fundo")
        }
    }

    /// A tinta de domínio sobre o fundo de domínio: a lei do cartão tingido
    /// (fundo pastel · letra escura no claro; fundo fundo · letra clara no
    /// escuro), sempre da mesma matiz e sempre legível.
    @Test func oDominioSeLeNosDoisMundos() {
        let dominios: [Dominio?] = Dominio.allCases.map { Optional($0) } + [nil]
        for (mundo, estilo) in [("claro", UIUserInterfaceStyle.light), ("escuro", .dark)] {
            for dominio in dominios {
                let razao = contraste(CalendarioTema.tinta(de: dominio),
                                      CalendarioTema.fundo(de: dominio), estilo)
                #expect(razao >= 4.5,
                        "\(mundo): \(dominio?.rawValue ?? "sem domínio") mede \(razao)")
            }
        }
    }

    /// O realce de código sobre o fundo do portal, nos dois mundos.
    ///
    /// `synPontuacao` fica fora, e a dívida é do claro outra vez: o #6E6E73
    /// mede **4,25:1** sobre o #EBEBEA (medido em 17/09), abaixo do piso da
    /// 02h. É o mesmo cinza que a ADR 04d aposentou do TEXTO e que sobreviveu
    /// aqui; corrigi-lo é mexer no claro sem pedido. No escuro a pontuação
    /// nasce acima do piso, e a conta do claro fica congelada logo abaixo.
    @Test func aSintaxeSeLeNosDoisMundos() {
        let tintas: [(String, Color)] = [
            ("chave", Tema.synChave), ("valor", Tema.synValor), ("número", Tema.synNumero),
            ("tipo", Tema.synTipo), ("função", Tema.synFuncao),
            ("texto", Tema.synTexto), ("comentário", Tema.synComentario),
        ]
        for (mundo, estilo) in [("claro", UIUserInterfaceStyle.light), ("escuro", .dark)] {
            for (nome, tinta) in tintas {
                let razao = contraste(tinta, Tema.codigoFundo, estilo)
                #expect(razao >= 4.5, "\(mundo): sintaxe \(nome) mede \(razao)")
            }
        }
        // a dívida congelada: 4,25 no claro, acima do piso no escuro
        #expect(abs(contraste(Tema.synPontuacao, Tema.codigoFundo, .light) - 4.25) < 0.05)
        #expect(contraste(Tema.synPontuacao, Tema.codigoFundo, .dark) >= 4.5)
    }

    // MARK: - O claro não se mexeu

    /// O dono disse, em 17/09, que o design do app está no melhor ponto que já
    /// esteve. Esta volta acrescenta um mundo; ela não tem licença para mover
    /// um pixel do outro. Os hex são os do `SISTEMA-CLARO.md`, conferidos um a
    /// um: se alguém trocar um par e errar o lado, este teste fica vermelho.
    @Test func oMundoClaroContinuaOMesmo() {
        let congelado: [(String, Color, UInt32)] = [
            ("fundo", Tema.fundo, 0xF4F4F2),
            ("superfície", Tema.superficie, 0xFFFFFF),
            ("superfícieBaixa", Tema.superficieBaixa, 0xEBEBEA),
            ("chip", Tema.chip, 0xE8E8E6),
            ("chipAtivo", Tema.chipAtivo, 0x2C2C2E),
            ("tinta", Tema.tinta, 0x1C1C1E),
            ("tintaSuave", Tema.tintaSuave, 0x5F5F64),
            ("tintaFraca", Tema.tintaFraca, 0x68686C),
            ("tintaMorta", Tema.tintaMorta, 0xC7C7CC),
            ("âmbar", Tema.ambar, 0xD9A542),
            ("ambarTinta", Tema.ambarTinta, 0x7A5A16),
            ("sábia", Tema.sabia, 0x1F6B5A),
            ("aviso", Tema.aviso, 0xB5432F),
            ("sobreAtivo", Tema.sobreAtivo, 0xFFFFFF),
            ("feriado", CalendarioTema.feriado, 0xB5432F),
            ("semanaÂncora", CalendarioTema.semanaAncora, 0xD6E2F8),
        ]
        for (nome, cor, esperado) in congelado {
            let medido = hex(cor, .light)
            #expect(medido == esperado,
                    "\(nome) no claro virou \(String(format: "#%06X", medido)), era \(String(format: "#%06X", esperado))")
        }
    }

    /// O âmbar é a assinatura do Traço e NÃO muda de mundo: é a única cor da
    /// casa que atravessa os dois igual. O que muda é o emprego — no papel ele
    /// mede 2,0:1 como texto e precisa do `ambarTinta`; no grafite ele se lê
    /// sozinho, e `ambarTinta` É o âmbar.
    @Test func oAmbarAtravessaOsDoisMundos() {
        #expect(hex(Tema.ambar, .light) == hex(Tema.ambar, .dark))
        #expect(hex(Tema.ambarTinta, .dark) == hex(Tema.ambar, .dark))
        #expect(contraste(Tema.ambar, Tema.fundo, .dark) >= 4.5)
    }

    // MARK: - Nenhum token esqueceu o escuro

    /// O defeito que este portão existe para pegar: alguém acrescenta um token
    /// com `Color(hex:)` — um valor só — e ele entra no mundo escuro com a cor
    /// do papel. Todo token que carrega COR (e não material nem alfa puro) tem
    /// de mudar entre os dois.
    @Test func todoTokenTemOsDoisLados() {
        let devemMudar: [(String, Color)] = [
            ("fundo", Tema.fundo), ("superfície", Tema.superficie),
            ("superfícieAlta", Tema.superficieAlta), ("superfícieBaixa", Tema.superficieBaixa),
            ("chip", Tema.chip), ("chipAtivo", Tema.chipAtivo), ("sobreAtivo", Tema.sobreAtivo),
            ("tinta", Tema.tinta), ("tintaSuave", Tema.tintaSuave),
            ("tintaFraca", Tema.tintaFraca), ("tintaMorta", Tema.tintaMorta),
            ("ambarTinta", Tema.ambarTinta), ("sábia", Tema.sabia), ("aviso", Tema.aviso),
            ("codigoFundo", Tema.codigoFundo), ("codigoGutter", Tema.codigoGutter),
            ("synChave", Tema.synChave), ("synValor", Tema.synValor),
            ("synNumero", Tema.synNumero), ("synTipo", Tema.synTipo),
            ("synFuncao", Tema.synFuncao), ("synPontuacao", Tema.synPontuacao),
            ("linha", Tema.linha), ("luzBorda", Tema.luzBorda),
            ("feriado", CalendarioTema.feriado), ("semanaÂncora", CalendarioTema.semanaAncora),
            ("contornoSistema", CalendarioTema.contornoSistema),
            ("contornoDeixa", CalendarioTema.contornoDeixa),
        ]
        for (nome, cor) in devemMudar {
            let claro = componentes(cor, .light), escuro = componentes(cor, .dark)
            #expect(claro != escuro, "\(nome) é a MESMA cor nos dois mundos — esqueceu o escuro?")
        }
    }

    /// Os fundos de domínio também têm dois lados, um a um: o laço acima não
    /// os alcança porque eles saem de função, não de constante.
    @Test func todoDominioTemOsDoisLados() {
        for dominio in Dominio.allCases {
            let fundo = CalendarioTema.fundo(de: dominio)
            let tinta = CalendarioTema.tinta(de: dominio)
            #expect(componentes(fundo, .light) != componentes(fundo, .dark), "fundo de \(dominio)")
            #expect(componentes(tinta, .light) != componentes(tinta, .dark), "tinta de \(dominio)")
        }
    }

    // MARK: - A escolha

    /// Três estados, e o padrão é o app de ontem. Um padrão `.sistema` viraria
    /// o Traço no escuro, sem pedido, para quem anda com o iPhone no escuro.
    @Test func aAparenciaPadraoEOAppDeOntem() {
        #expect(Aparencia.claro.esquema == .light)
        #expect(Aparencia.escuro.esquema == .dark)
        #expect(Aparencia.sistema.esquema == nil)
        #expect(Aparencia.naOrdem.count == Aparencia.allCases.count)
        let anterior = UserDefaults.standard.string(forKey: Aparencia.chave)
        UserDefaults.standard.removeObject(forKey: Aparencia.chave)
        #expect(Aparencia.escolhida == .claro)
        if let anterior { UserDefaults.standard.set(anterior, forKey: Aparencia.chave) }
    }

    /// Lixo na chave não vira tela quebrada: cai no padrão.
    @Test func chaveEstragadaCaiNoPadrao() {
        let anterior = UserDefaults.standard.string(forKey: Aparencia.chave)
        UserDefaults.standard.set("penumbra", forKey: Aparencia.chave)
        #expect(Aparencia.escolhida == .claro)
        if let anterior { UserDefaults.standard.set(anterior, forKey: Aparencia.chave) }
        else { UserDefaults.standard.removeObject(forKey: Aparencia.chave) }
    }
}
