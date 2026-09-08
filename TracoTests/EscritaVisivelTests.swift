import SwiftData
import SwiftUI
import Testing
import UIKit
@testable import Traco

/// A invariante da escrita visível (ADR 08f, V12-E), medida na Página REAL:
/// "em cada quadro apresentado enquanto a Página recebe escrita, a linha visual
/// ativa inteira e o retângulo do caret pertencem à área livre do papel; nenhuma
/// outra superfície pode desenhar nessa área."
///
/// Hospedado: monta `PaginaView` com uma `Sessao` isolada numa janela própria,
/// espera o editor focado e o TECLADO DE SOFTWARE, digita mais do que cabe no
/// papel (no fim e no meio) e, a cada inserção, mede na mesma coordenada da
/// janela: E (a linha do caret pelo TextKit 2, mais o caret), P (o recorte do
/// ScrollView do papel e de todo ancestral que recorta, sem o teclado) e O (toda
/// superfície À FRENTE do editor que toque a linha). Nada aqui rola o papel: quem
/// rola é o app (`EscritaVisivel`); se ele não rolar, E sai de P e o teste cai.
/// Em `large` e AX5; com o encaixe vazio, com o cartão e com o aviso.
///
/// Precisa do teclado de software: no simulador, "Connect Hardware Keyboard"
/// desligado para o UDID (`DevicePreferences.<UDID>.ConnectHardwareKeyboard = 0`).
@MainActor
@Suite(.serialized)
struct EscritaVisivelTests {

    struct Medida {
        var estado: String
        var linha: CGRect
        var area: CGRect
        var intrusos: [String]
        /// a geometria por baixo, para o relato: offset e conteúdo do papel, frame do editor
        var geometria = ""
        var cabe: Bool { !linha.isNull && linha.height > 0 && area.contains(linha) && intrusos.isEmpty }
        var descricao: String {
            String(format: "%@: linha %.0f–%.0f pt, papel %.0f–%.0f pt, intrusos %@",
                   estado, linha.minY, linha.maxY, area.minY, area.maxY,
                   intrusos.isEmpty ? "nenhum" : intrusos.joined(separator: " | ")) + geometria
        }
    }

    /// O teclado, ouvido UMA vez por processo: entre um caso e outro ele fica
    /// de pé (soltar o foco entre casos deixava-o preso fora da tela para o
    /// resto da rodada), e o próximo caso já o encontra.
    @MainActor final class OuvidoDoTeclado {
        static let unico = OuvidoDoTeclado()
        /// o teclado NA TELA; `.null` escondido
        var visivel: CGRect = .null
        /// o último frame anunciado fora da tela (só a altura serve)
        var fora: CGRect = .null
        private var observadores: [NSObjectProtocol] = []
        private init() {
            for nome in [UIResponder.keyboardDidShowNotification, UIResponder.keyboardDidChangeFrameNotification, UIResponder.keyboardDidHideNotification] {
                observadores.append(NotificationCenter.default.addObserver(forName: nome, object: nil, queue: .main) { n in
                    let f = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .null
                    MainActor.assumeIsolated { // a fila é a principal
                        let tela = EscritaVisivel.janelaChave()?.bounds.maxY ?? 0
                        let naTela = !f.isNull && f.minY < tela - 1 && nome != UIResponder.keyboardDidHideNotification
                        OuvidoDoTeclado.unico.visivel = naTela ? f : .null
                        if !naTela, !f.isNull { OuvidoDoTeclado.unico.fora = f }
                    }
                })
            }
        }
    }

    /// A Página REAL do app hospedeiro, e o que é preciso devolver ao fim. Uma
    /// Página hospedada à parte foi tentada e descartada: duas Páginas no mesmo
    /// processo davam dois editores focados, e o controlador apresentado não
    /// recebia a área segura do teclado.
    final class Cenario {
        let janela: UIWindow
        let sessao: Sessao
        var teclado: CGRect { OuvidoDoTeclado.unico.visivel }

        init(cena: UIWindowScene, tamanho: UIContentSizeCategory) throws {
            _ = OuvidoDoTeclado.unico
            janela = try #require(cena.windows.first { $0.isKeyWindow })
            var viva: Sessao?
            for _ in 0..<50 where viva == nil { viva = PaginaView.sessaoViva; if viva == nil { EscritaVisivelTests.esperar(0.1) } }
            sessao = try #require(viva, "a Página do app não publicou a sessão viva")
            // a Página nasce como o autor a deixou: aqui nasce solta e à VISTA —
            // a suíte inteira corre no mesmo processo e outra suíte pode ter
            // deixado o app noutra camada (`CalendarioTrabalhoTests` posta
            // `abrirCompromisso` e o app vai para o calendário). O texto é
            // apagado no editor, com o foco que ele já tiver.
            janela.rootViewController?.presentedViewController?.dismiss(animated: false)
            sessao.aba = .escrever
            sessao.confirmacao = nil
            sessao.mostrarRecordar = false
            sessao.cartao = nil
            sessao.toast = nil
            sessao.soltarForma()
            janela.traitOverrides.preferredContentSizeCategory = tamanho
            EscritaVisivelTests.esperar(0.8)
        }

        func desmontar() {
            sessao.cartao = nil
            sessao.toast = nil
            sessao.soltarForma()
            janela.traitOverrides.remove(UITraitPreferredContentSizeCategory.self)
            janela.rootViewController?.additionalSafeAreaInsets = .zero
            EscritaVisivelTests.esperar(0.5)
        }
    }

    private static func esperar(_ segundos: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(segundos))
    }

    /// O editor da Página: o `UITextView` com mais área NA TELA. A camada do
    /// arquivo (§20) vive ao mesmo tempo, fora da tela à esquerda, e tem editor
    /// próprio — o primeiro da árvore era ele (caret na borda, sem régua).
    private static func editorDaPagina(em janela: UIWindow) -> UITextView? {
        var todos: [UITextView] = []
        func colher(_ v: UIView) { if let tv = v as? UITextView { todos.append(tv) }; v.subviews.forEach(colher) }
        colher(janela)
        return todos.max { a, b in
            let ra = a.convert(a.bounds, to: nil).intersection(janela.bounds), rb = b.convert(b.bounds, to: nil).intersection(janela.bounds)
            return (ra.isNull ? 0 : ra.width * ra.height) < (rb.isNull ? 0 : rb.width * rb.height)
        }
    }

    private static func cena() throws -> UIWindowScene {
        try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
    }

    // MARK: - a medida

    /// E: a linha visual inteira em que o caret está, pelo layout do TextKit 2,
    /// unida ao retângulo do caret. Coordenadas da janela.
    static func linhaAtiva(_ tv: UITextView) -> CGRect {
        guard let fim = tv.selectedTextRange?.end else { return .null }
        var linha = tv.caretRect(for: fim)
        if let tlm = tv.textLayoutManager, let tcm = tlm.textContentManager {
            let offset = tv.offset(from: tv.beginningOfDocument, to: fim)
            if let loc = tcm.location(tcm.documentRange.location, offsetBy: offset) {
                tlm.ensureLayout(for: NSTextRange(location: loc))
                if let frag = tlm.textLayoutFragment(for: loc) {
                    let dentro = offset - tcm.offset(from: tcm.documentRange.location, to: frag.rangeInElement.location)
                    let linhas = frag.textLineFragments
                    for (i, lf) in linhas.enumerated()
                    where NSLocationInRange(dentro, lf.characterRange) || (i == linhas.count - 1 && dentro == NSMaxRange(lf.characterRange)) {
                        let r = lf.typographicBounds
                            .offsetBy(dx: frag.layoutFragmentFrame.minX + tv.textContainerInset.left,
                                      dy: frag.layoutFragmentFrame.minY + tv.textContainerInset.top)
                        linha = linha.union(r)
                    }
                }
            }
        }
        return tv.convert(linha, to: nil)
    }

    /// P: o que do papel está mesmo à vista — os bounds do ScrollView menos o
    /// inset, recortados por todo ancestral que recorta, sem o teclado.
    static func areaLivre(_ tv: UITextView, teclado: CGRect) -> CGRect {
        guard let janela = tv.window, let papel = EscritaVisivel.rolagemAcima(de: tv) else { return .null }
        var area = papel.convert(papel.bounds.inset(by: papel.adjustedContentInset), to: nil)
        var v: UIView? = papel
        while let a = v {
            if a.clipsToBounds || a.layer.masksToBounds { area = area.intersection(a.convert(a.bounds, to: nil)) }
            v = a.superview
        }
        if !teclado.isNull, teclado.height > 0 {
            area = area.intersection(CGRect(x: 0, y: 0, width: janela.bounds.width, height: teclado.minY))
        }
        return area
    }

    /// O ∩ E: toda superfície da janela que está À FRENTE do editor (ordem de
    /// irmãos e `zPosition`, do ancestral comum para baixo), visível, e cujo
    /// retângulo visível toca a linha ativa. Pela árvore de CAMADAS, não de
    /// views: o SwiftUI desenha texto, cores e formas em `CALayer` sem `UIView`
    /// — uma camada plantada sobre o papel passava invisível pela árvore de
    /// views. Descendentes e ancestrais do editor não contam (o caret é camada
    /// dele; o ScrollView está por baixo).
    static func intrusos(sobre linha: CGRect, editor tv: UITextView) -> [String] {
        guard let janela = tv.window, !linha.isNull else { return [] }
        let raiz = janela.layer, meuLayer = tv.layer
        var caminho: [ObjectIdentifier: [(CGFloat, Int)]] = [:]
        func indexar(_ l: CALayer, _ acima: [(CGFloat, Int)]) {
            caminho[ObjectIdentifier(l)] = acima
            for (i, s) in (l.sublayers ?? []).enumerated() { indexar(s, acima + [(s.zPosition, i)]) }
        }
        indexar(raiz, [])
        guard let meu = caminho[ObjectIdentifier(meuLayer)] else { return ["editor fora da janela"] }
        func aFrente(_ outro: [(CGFloat, Int)]) -> Bool {
            for (a, b) in zip(outro, meu) where a != b { return a.0 > b.0 || (a.0 == b.0 && a.1 > b.1) }
            return false
        }
        func ancestral(_ a: CALayer, de b: CALayer) -> Bool {
            var x: CALayer? = b
            while let l = x { if l === a { return true }; x = l.superlayer }
            return false
        }
        func visivel(_ l: CALayer) -> Bool {
            var x: CALayer? = l
            while let a = x { if a.isHidden || a.opacity < 0.01 { return false }; x = a.superlayer }
            return true
        }
        func retanguloVisivel(_ l: CALayer) -> CGRect {
            var r = l.convert(l.bounds, to: raiz)
            var x = l.superlayer
            while let a = x { if a.masksToBounds { r = r.intersection(a.convert(a.bounds, to: raiz)) }; x = a.superlayer }
            return r
        }
        var achados: [String] = []
        func percorrer(_ l: CALayer) {
            defer { (l.sublayers ?? []).forEach(percorrer) }
            guard l !== meuLayer, !ancestral(meuLayer, de: l), !ancestral(l, de: meuLayer) else { return }
            // só o que DESENHA: conteúdo próprio, fundo com tinta, forma, texto, degradê
            let desenha = l.contents != nil || (l.backgroundColor?.alpha ?? 0) > 0.01
                || l is CAShapeLayer || l is CATextLayer || l is CAGradientLayer
            guard desenha, visivel(l), let c = caminho[ObjectIdentifier(l)], aFrente(c) else { return }
            let f = retanguloVisivel(l)
            let r = f.intersection(linha)
            guard !r.isNull, r.width > 1, r.height > 1 else { return }
            let dono = (l.delegate as? UIView).map { String(describing: type(of: $0)) } ?? String(describing: type(of: l))
            achados.append(String(format: "%@ %.0f,%.0f %.0f×%.0f", dono, f.minX, f.minY, f.width, f.height))
        }
        percorrer(raiz)
        return achados
    }

    static func medir(_ tv: UITextView, teclado: CGRect, estado: String) -> Medida {
        let linha = linhaAtiva(tv)
        var m = Medida(estado: estado, linha: linha, area: areaLivre(tv, teclado: teclado),
                       intrusos: intrusos(sobre: linha, editor: tv))
        if let sv = EscritaVisivel.rolagemAcima(de: tv) {
            let f = tv.convert(tv.bounds, to: nil)
            m.geometria = String(format: " [papel offset %.0f, conteúdo %.0f, janela %.0f; editor %.0f–%.0f, conteúdo %.0f, rola %@; teclado %.0f]",
                                 sv.contentOffset.y, sv.contentSize.height, sv.bounds.height, f.minY, f.maxY, tv.contentSize.height,
                                 tv.isScrollEnabled ? "sim" : "não", teclado.minY)
        }
        return m
    }

    // MARK: - a travessia

    static let bloco = "Quero correr de manha mas tenho preguica de levantar. Se de manha eu ficar na cama depois do alarme, entao eu ponho os pes no chao e visto o tenis antes de pensar. "

    /// Digita `texto` em pedaços de palavras e mede depois de cada pedaço.
    private static func digitar(_ texto: String, em tv: UITextView, teclado: CGRect, estado: String, amostras: inout [Medida]) {
        var pedaco = ""
        for palavra in texto.split(separator: " ", omittingEmptySubsequences: false) {
            pedaco += palavra + " "
            if pedaco.count < 24 { continue }
            tv.insertText(pedaco); pedaco = ""
            esperar(0.12)
            amostras.append(medir(tv, teclado: teclado, estado: estado))
        }
        if !pedaco.isEmpty { tv.insertText(pedaco); esperar(0.12); amostras.append(medir(tv, teclado: teclado, estado: estado)) }
    }

    @Test(arguments: [UIContentSizeCategory.accessibilityExtraExtraExtraLarge, .large])
    func aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel(tamanho: UIContentSizeCategory) throws {
        let cenario = try Cenario(cena: Self.cena(), tamanho: tamanho)
        defer { cenario.desmontar() }
        let nome = tamanho == .large ? "large" : "AX5"

        var editor: UITextView?
        for _ in 0..<50 where editor == nil {
            editor = Self.editorDaPagina(em: cenario.janela)
            if editor == nil { Self.esperar(0.1) }
        }
        let tv = try #require(editor, "o TextEditor da Página não está na janela do app")
        // O teclado de software sob `xcodebuild test`: o foco pedido no arranque
        // deixa-o FORA da tela (frame em y = altura da tela, `isInHardwareKeyboardMode`
        // = 0), e o hospedeiro do SwiftUI não desvia dele mesmo depois de ele
        // subir. Soltar e pedir de novo pelo UIKit costuma pô-lo de pé; o desvio,
        // que o SwiftUI faz no app vivo, o teste repõe por `additionalSafeAreaInsets`
        // — a mesma coisa, pela porta do UIKit. Se ele não subir de vez, a mesma
        // altura é reservada e a linha do relato diz "EMULADO": o instrumento tem
        // limite, e o limite fica escrito, não escondido.
        var tentativas = 0
        if !tv.isFirstResponder { tv.becomeFirstResponder(); Self.esperar(0.8) }
        while cenario.teclado.height < 200, tentativas < 8 {
            tentativas += 1
            tv.resignFirstResponder(); Self.esperar(tentativas % 2 == 0 ? 1.2 : 0.5); tv.becomeFirstResponder()
            for _ in 0..<20 where cenario.teclado.height < 200 { Self.esperar(0.1) }
        }
        try #require(tv.isFirstResponder)
        let tecladoReal = cenario.teclado.height >= 200
        var teclado = cenario.teclado
        if !tecladoReal {
            let fora = OuvidoDoTeclado.unico.fora.height
            let altura = fora >= 200 ? fora : 318 // o do iPhone 17 Pro Max, medido
            teclado = CGRect(x: 0, y: cenario.janela.bounds.maxY - altura, width: cenario.janela.bounds.width, height: altura)
        }
        let raiz = try #require(cenario.janela.rootViewController)
        if let sv = EscritaVisivel.rolagemAcima(de: tv), sv.convert(sv.bounds, to: nil).maxY > teclado.minY + 1 {
            raiz.additionalSafeAreaInsets.bottom = teclado.height - cenario.janela.safeAreaInsets.bottom
            Self.esperar(0.6)
        }
        let papel = EscritaVisivel.rolagemAcima(de: tv).map { $0.convert($0.bounds, to: nil) } ?? .null
        print("ESCRITA teclado \(nome): \(tecladoReal ? "de software, na tela" : "EMULADO pela área segura") \(Int(teclado.height)) pt (\(tentativas) tentativa(s)), papel \(Int(papel.minY))–\(Int(papel.maxY)) pt, topo do teclado \(Int(teclado.minY)) pt, inset extra \(Int(raiz.additionalSafeAreaInsets.bottom)) pt")
        try #require(papel.maxY <= teclado.minY + 1, "o papel continua por baixo do teclado")
        tv.selectAll(nil); tv.deleteBackward(); Self.esperar(0.3)
        // antes de medir: nada pode estar sobre o papel — se está, é poluição
        // de outra suíte (ou defeito), e o nome fica na linha, não na medida
        let sobreOPapel = Self.intrusos(sobre: papel.insetBy(dx: 20, dy: 20), editor: tv)
        try #require(sobreOPapel.isEmpty, "há superfície sobre o papel antes de escrever: \(sobreOPapel.joined(separator: " | "))")
        if tamanho != .large {
            try #require((tv.font?.pointSize ?? 0) > 30, "AX5 não chegou ao editor (corpo \(tv.font?.pointSize ?? 0) pt)")
        }
        Self.esperar(0.5)

        var amostras: [Medida] = []
        // encaixe vazio: mais texto do que cabe no papel, inserido no fim
        Self.digitar(String(repeating: Self.bloco, count: tamanho == .large ? 4 : 2), em: tv, teclado: teclado,
                     estado: "\(nome), encaixe vazio, fim", amostras: &amostras)
        // o cartão chega enquanto se escreve (a forma vestiu sozinha): o papel encolhe
        cenario.sessao.cartao = .vestida(.woop, pergunta: "O que pode atrapalhar de manhã?")
        Self.esperar(0.6)
        amostras.append(Self.medir(tv, teclado: teclado, estado: "\(nome), cartão chegou, antes de digitar"))
        Self.digitar(Self.bloco, em: tv, teclado: teclado, estado: "\(nome), cartão, fim", amostras: &amostras)
        // inserção no MEIO, com o fim rolado para dentro: o papel tem de subir
        tv.selectedRange = NSRange(location: tv.text.utf16.count / 2, length: 0)
        Self.digitar("no meio da nota, onde o autor tocou, ", em: tv, teclado: teclado,
                     estado: "\(nome), cartão, meio", amostras: &amostras)
        // o aviso no lugar do cartão, e o toast por cima do encaixe
        cenario.sessao.cartao = .aviso("A sábia não respondeu. O seu texto continua aqui.")
        cenario.sessao.toast = "Toque no microfone do teclado para ditar."
        Self.esperar(0.6)
        amostras.append(Self.medir(tv, teclado: teclado, estado: "\(nome), aviso e toast, antes de digitar"))
        tv.selectedRange = NSRange(location: tv.text.utf16.count, length: 0)
        Self.digitar(Self.bloco, em: tv, teclado: teclado, estado: "\(nome), aviso e toast, fim", amostras: &amostras)

        let dentro = amostras.filter(\.cabe).count
        print("ESCRITA \(nome): \(amostras.count) amostras, \(dentro) com a linha do caret na área livre do papel; teclado \(tecladoReal ? "real" : "emulado") \(Int(teclado.height)) pt")
        #expect(amostras.count >= 20, "poucas amostras para valer como prova")
        for m in amostras where !m.cabe {
            Issue.record("a linha do caret saiu da área livre do papel — \(m.descricao)")
        }
    }
}
