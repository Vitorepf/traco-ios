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
            String(format: "%@: linha %.0f–%.0f pt (%.0f de largura), papel %.0f–%.0f pt, intrusos %@",
                   estado, linha.minY, linha.maxY, linha.width, area.minY, area.maxY,
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
            // a etiqueta de origem (ADR 08u/09b) é estado VISUAL da sessão viva,
            // como o cartão e o toast, e entrou depois deste cenário: sem a
            // neutralizar, uma suíte que abrisse nota do bot deixava a cápsula
            // de pé e mudava o papel por baixo desta medida (achado da C1-D).
            sessao.origemDaPagina = .autor
            sessao.soltarForma()
            janela.traitOverrides.preferredContentSizeCategory = tamanho
            EscritaVisivelTests.esperar(0.8)
        }

        func desmontar() {
            sessao.cartao = nil
            sessao.toast = nil
            sessao.origemDaPagina = .autor
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
                // No FIM do documento — onde o autor escreve — nenhum fragmento
                // começa em `loc` e o TextKit 2 devolve nil; sem este recuo de um
                // caractere, E era só a caixa do caret (2 pt de largura), e a
                // metade `P ∩ O = ∅` só reprovava quem cobrisse a coluna do caret.
                let anterior = offset > 0 ? tcm.location(tcm.documentRange.location, offsetBy: offset - 1) : nil
                if let frag = tlm.textLayoutFragment(for: loc) ?? anterior.flatMap({ tlm.textLayoutFragment(for: $0) }) {
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
        // O é lido no quadro APRESENTADO, como E e P: uma camada que entra por
        // fade ou por corte só cobre a linha quando a apresentação já a pintou.
        // A árvore percorrida continua a do MODELO (é ela que dá a ordem de
        // irmãos); a geometria e a opacidade vêm de `presentation()`, e a
        // conversão nunca mistura as duas árvores.
        //
        // Sem `presentation()` a camada AINDA NÃO FOI ENTREGUE ao render: ela
        // não pinta neste quadro, e contá-la pela geometria do modelo (que já
        // é a de destino) acusava um intruso que a tela não mostrava — foi o
        // que aconteceu no primeiro quadro depois de o cartão nascer.
        let raizP = raiz.presentation() ?? raiz
        func caixa(_ l: CALayer) -> CGRect? {
            guard let p = l.presentation() else { return nil }
            return p.convert(p.bounds, to: raizP)
        }
        func visivel(_ l: CALayer) -> Bool {
            var x: CALayer? = l
            while let a = x {
                guard let p = a.presentation() else { return false }
                if p.isHidden || p.opacity < 0.01 { return false }
                x = a.superlayer
            }
            return true
        }
        func retanguloVisivel(_ l: CALayer) -> CGRect {
            guard var r = caixa(l) else { return .null }
            var x = l.superlayer
            while let a = x {
                if a.masksToBounds, let c = caixa(a) { r = r.intersection(c) }
                x = a.superlayer
            }
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

    /// O editor da Página com o TECLADO DE PÉ e o papel inteiro acima dele —
    /// o preparo que todo teste desta suíte faz antes de medir. Devolve o
    /// editor, o retângulo do teclado (real ou reservado) e se ele é real.
    private static func editorPronto(_ cenario: Cenario, nome: String) throws -> (UITextView, CGRect, Bool) {
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
        print("ESCRITA teclado \(nome): \(tecladoReal ? "de software, na tela" : "EMULADO pela área segura") \(Int(teclado.height)) pt (\(tentativas) tentativa(s)), papel \(Int(papel.minY))–\(Int(papel.maxY)) pt, topo do teclado \(Int(teclado.minY)) pt, inset extra \(Int(raiz.additionalSafeAreaInsets.bottom)) pt, TextKit \(tv.textLayoutManager == nil ? "1" : "2")")
        try #require(papel.maxY <= teclado.minY + 1, "o papel continua por baixo do teclado")
        tv.selectAll(nil); tv.deleteBackward(); Self.esperar(0.3)
        // antes de medir: nada pode estar sobre o papel — se está, é poluição
        // de outra suíte (ou defeito), e o nome fica na linha, não na medida
        let sobreOPapel = Self.intrusos(sobre: papel.insetBy(dx: 20, dy: 20), editor: tv)
        try #require(sobreOPapel.isEmpty, "há superfície sobre o papel antes de escrever: \(sobreOPapel.joined(separator: " | "))")
        if nome != "large" {
            try #require((tv.font?.pointSize ?? 0) > 30, "AX5 não chegou ao editor (corpo \(tv.font?.pointSize ?? 0) pt)")
        }
        Self.esperar(0.5)
        return (tv, teclado, tecladoReal)
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

    // MARK: - a gaveta, quadro a quadro

    /// O retângulo `r`, dado em coordenadas de `v`, onde ele está NO QUADRO
    /// APRESENTADO — pelas camadas de apresentação, não pelo modelo. Durante
    /// uma animação o modelo já tem o valor final e só a apresentação diz o que
    /// o olho vê; a 08f fala de "cada quadro APRESENTADO", e sem isto a sonda
    /// mediria o fim da gaveta em todo quadro dela. Só translação, que é o que
    /// a gaveta faz: escala e rotação não entram aqui.
    static func apresentado(_ r: CGRect, de v: UIView) -> CGRect {
        var rect = r
        var atual: UIView? = v
        while let a = atual, a.superview != nil {
            let l = a.layer.presentation() ?? a.layer
            rect = rect.offsetBy(dx: l.frame.minX - l.bounds.minX, dy: l.frame.minY - l.bounds.minY)
            atual = a.superview
        }
        return rect
    }

    /// E apresentado: a linha ativa onde ela está no quadro.
    static func linhaApresentada(_ tv: UITextView) -> CGRect {
        guard let janela = tv.window else { return .null }
        let naJanela = linhaAtiva(tv)
        guard !naJanela.isNull else { return .null }
        return apresentado(janela.convert(naJanela, to: tv), de: tv)
    }

    /// A CAIXA de `v` na janela, no quadro apresentado. Não é `apresentado(v.bounds…)`:
    /// o `bounds` de um ScrollView traz a rolagem do MODELO dentro dele, e
    /// misturá-la com a posição APRESENTADA da caixa punha o erro de um quadro
    /// dentro da própria medida.
    static func caixaApresentada(_ v: UIView) -> CGRect {
        guard let pai = v.superview else { return v.bounds }
        let l = v.layer.presentation() ?? v.layer
        return apresentado(l.frame, de: pai)
    }

    /// P apresentado: a área livre do papel onde ela está no quadro.
    static func areaApresentada(_ tv: UITextView, teclado: CGRect) -> CGRect {
        guard let janela = tv.window, let papel = EscritaVisivel.rolagemAcima(de: tv) else { return .null }
        var area = caixaApresentada(papel).inset(by: papel.adjustedContentInset)
        var v: UIView? = papel
        while let a = v {
            if a.clipsToBounds || a.layer.masksToBounds { area = area.intersection(caixaApresentada(a)) }
            v = a.superview
        }
        if !teclado.isNull, teclado.height > 0 {
            area = area.intersection(CGRect(x: 0, y: 0, width: janela.bounds.width, height: teclado.minY))
        }
        return area
    }

    /// Um quadro entregue pelo `CADisplayLink`, com a invariante INTEIRA medida
    /// NELE. A 08f tem duas metades e as duas são medidas aqui, separadas para
    /// que cada uma reprove com o seu próprio nome: `E ⊆ P` (a linha ativa
    /// dentro do papel) e `P ∩ O = ∅` (nenhuma superfície à frente pintando
    /// sobre ela).
    struct Quadro {
        var instante: CFTimeInterval
        var linha: CGRect
        var area: CGRect
        var intrusos: [String]
        var custo: CFTimeInterval
        var sonda = ""
        /// E ⊆ P
        var noPapel: Bool { !linha.isNull && linha.height > 0 && area.contains(linha) }
        /// P ∩ O = ∅
        var semIntruso: Bool { intrusos.isEmpty }
        var cabe: Bool { noPapel && semIntruso }
        /// quanto da linha ficou fora do papel, em pt (0 quando está dentro)
        var corte: CGFloat {
            guard !noPapel else { return 0 }
            guard !linha.isNull, !area.isNull else { return linha.height }
            return max(0, linha.maxY - area.maxY) + max(0, area.minY - linha.minY)
        }
    }

    /// Filma a invariante quadro a quadro enquanto a gaveta corre.
    @MainActor final class Camera: NSObject {
        let tv: UITextView
        let teclado: CGRect
        var quadros: [Quadro] = []
        init(tv: UITextView, teclado: CGRect) { self.tv = tv; self.teclado = teclado }
        @objc func quadro(_ link: CADisplayLink) {
            let t0 = CACurrentMediaTime()
            let linha = EscritaVisivelTests.linhaApresentada(tv)
            let area = EscritaVisivelTests.areaApresentada(tv, teclado: teclado)
            // a geometria do MODELO ao lado da apresentada: quando um quadro
            // reprova, é ela que diz se o papel encolheu ou se a rolagem ficou
            var sonda = ""
            if let sv = EscritaVisivel.rolagemAcima(de: tv) {
                let am = EscritaVisivelTests.areaLivre(tv, teclado: teclado)
                sonda = String(format: "modelo: papel %.0f–%.0f, offset %.1f", am.minY, am.maxY, sv.contentOffset.y)
            }
            let intrusos = linha.isNull ? [] : EscritaVisivelTests.intrusos(sobre: linha, editor: tv)
            quadros.append(Quadro(instante: link.timestamp, linha: linha, area: area, intrusos: intrusos,
                                  custo: CACurrentMediaTime() - t0, sonda: sonda))
        }
        /// Repouso, a mudança, e o tempo da gaveta — tudo com o link de pé.
        func gravar(_ segundos: TimeInterval, _ mudar: () -> Void) -> [Quadro] {
            quadros = []
            let link = CADisplayLink(target: self, selector: #selector(quadro(_:)))
            link.add(to: .main, forMode: .common)
            EscritaVisivelTests.esperar(0.25)
            mudar()
            EscritaVisivelTests.esperar(segundos)
            link.invalidate()
            return quadros
        }
    }

    /// A conta de uma gaveta: quantos quadros, quantos reprovaram CADA METADE
    /// da 08f, e QUANDO. As duas metades saem separadas — uma sonda que soma
    /// os dois vermelhos num número só deixa de dizer qual regra caiu.
    private static func contar(_ nome: String, _ quadros: [Quadro]) -> (linha: String, fora: Int, cobertos: Int) {
        guard let primeiro = quadros.first, quadros.count > 2 else { return ("GAVETA \(nome): sem quadros", 0, 0) }
        let fora = quadros.filter { !$0.noPapel }
        let cobertos = quadros.filter { !$0.semIntruso }
        let intervalos = zip(quadros.dropFirst(), quadros).map { $0.instante - $1.instante }.sorted()
        let mediana = intervalos[intervalos.count / 2]
        let custo = quadros.map(\.custo).reduce(0, +) / Double(quadros.count)
        var texto = String(format: "GAVETA %@: %d quadros em %.2f s (cadência %.1f ms, sonda %.1f ms/quadro), %d fora do papel (E ⊄ P), %d cobertos (P ∩ O ≠ ∅)",
                           nome, quadros.count, quadros.last!.instante - primeiro.instante,
                           mediana * 1000, custo * 1000, fora.count, cobertos.count)
        if let a = fora.first, let z = fora.last {
            texto += String(format: "; fora de +%.3f s a +%.3f s = %.3f s de linha cortada, pior corte %.0f pt",
                            a.instante - primeiro.instante, z.instante - primeiro.instante,
                            z.instante - a.instante + mediana, fora.map(\.corte).max() ?? 0)
            for q in fora.prefix(30) {
                texto += String(format: "\nGAVETA   fora +%.3f s: linha %.0f–%.0f, papel %.0f–%.0f, corte %.0f pt | %@",
                                q.instante - primeiro.instante, q.linha.minY, q.linha.maxY, q.area.minY, q.area.maxY, q.corte, q.sonda)
            }
        }
        if let a = cobertos.first, let z = cobertos.last {
            texto += String(format: "; coberta de +%.3f s a +%.3f s = %.3f s de linha sob outra superfície",
                            a.instante - primeiro.instante, z.instante - primeiro.instante,
                            z.instante - a.instante + mediana)
            for q in cobertos.prefix(30) {
                texto += String(format: "\nGAVETA   coberta +%.3f s: linha %.0f–%.0f | %@",
                                q.instante - primeiro.instante, q.linha.minY, q.linha.maxY, q.intrusos.joined(separator: " | "))
            }
        }
        return (texto, fora.count, cobertos.count)
    }

    /// A 08f é escrita "em cada quadro apresentado"; o teste acima mede em
    /// PONTOS DISCRETOS, depois de cada inserção, com o papel parado. A gaveta
    /// muda a altura do encaixe ao longo de `Tema.gaveta`, e o resíduo da 09d
    /// mora aí: a linha ativa cortada pela borda do papel que encolheu antes de
    /// o seguidor correr (`ferramentas/orca/c1/c1-04-residuo-gaveta-cartao.png`).
    /// Aqui a medida é POR QUADRO, com o instante de cada um — é o que troca
    /// "~0,11 s numa varredura de 220" por uma conta que se repete.
    @Test(arguments: [UIContentSizeCategory.large]) // só large: letra grande saiu do produto (dono, 14/09)
    func aLinhaFicaNoPapelEmCadaQuadroDaGaveta(tamanho: UIContentSizeCategory) throws {
        let cenario = try Cenario(cena: Self.cena(), tamanho: tamanho)
        defer { cenario.desmontar() }
        let nome = tamanho == .large ? "large" : "AX5"
        let (tv, teclado, tecladoReal) = try Self.editorPronto(cenario, nome: nome)
        // com a linha ativa encostada na borda de baixo do papel: é ela que a
        // gaveta alcança, e é aí que o autor está a escrever
        var antes: [Medida] = []
        // o "agora" no fim não é enfeite: o bloco acaba em espaço, e com ele o
        // caret cai no início de uma linha VAZIA — E virava a caixa do caret, 2
        // pt de largura. Com uma palavra no fim, E é a linha de letras que o
        // autor está a escrever, que é o que a 08f protege.
        Self.digitar(String(repeating: Self.bloco, count: tamanho == .large ? 4 : 2) + "agora", em: tv, teclado: teclado,
                     estado: "\(nome), antes da gaveta", amostras: &antes)
        let ultima = try #require(antes.last)
        try #require(ultima.cabe, "a linha já estava fora do papel antes da gaveta — \(ultima.descricao)")

        let camera = Camera(tv: tv, teclado: teclado)
        // as três gavetas que ENCOLHEM o papel, que são as que podem cortar a
        // linha: o cartão a chegar, o aviso a tomar o lugar dele (o pé sobe de
        // 275 para 327 pt no 17e) e o toast por cima.
        let cenas: [(String, () -> Void)] = [
            ("cartão a chegar", { cenario.sessao.cartao = .vestida(.woop, pergunta: "O que pode atrapalhar de manhã?") }),
            ("aviso no lugar do cartão", { cenario.sessao.cartao = .aviso("A sábia não respondeu. O seu texto continua aqui.") }),
            ("toast por cima do encaixe", { cenario.sessao.toast = "Toque no microfone do teclado para ditar." }),
        ]
        var totalFora = 0, totalCoberto = 0
        for (cena, mudar) in cenas {
            let (linha, fora, cobertos) = Self.contar("\(nome), \(cena)", camera.gravar(1.2, mudar))
            print(linha)
            totalFora += fora
            totalCoberto += cobertos
        }
        print("GAVETA \(nome): teclado \(tecladoReal ? "real" : "emulado") \(Int(teclado.height)) pt, \(totalFora) quadro(s) com a linha ativa fora do papel, \(totalCoberto) quadro(s) com outra superfície sobre ela")
        #expect(totalFora == 0, "a linha ativa saiu do papel durante a gaveta — a 08f vale em cada quadro apresentado")
        #expect(totalCoberto == 0, "outra superfície desenhou sobre a linha ativa durante a gaveta — a 08f também proíbe isso em cada quadro apresentado")

        // O vermelho da SEGUNDA metade, na mesma corrida: zero intruso só vale
        // como prova se a sonda souber ver um. Uma camada adversarial é plantada
        // à frente do editor, sobre a linha ativa, e os quadros TÊM de acusá-la.
        let linhaAgora = Self.linhaApresentada(tv)
        let intruso = CALayer()
        // larga como uma gaveta de verdade, e não só como o caret: a faixa toma
        // a largura da janela na altura da linha ativa
        intruso.frame = CGRect(x: 0, y: linhaAgora.midY - linhaAgora.height / 4,
                               width: cenario.janela.bounds.width, height: max(2, linhaAgora.height / 2))
        intruso.backgroundColor = UIColor.red.withAlphaComponent(0.5).cgColor
        let adversarial = camera.gravar(0.6) { cenario.janela.layer.addSublayer(intruso) }
        intruso.removeFromSuperlayer()
        Self.esperar(0.2)
        let acusados = adversarial.filter { !$0.semIntruso }
        let aindaNoPapel = adversarial.filter { !$0.noPapel }
        print("GAVETA \(nome), sonda adversarial: camada \(Int(intruso.frame.minY))–\(Int(intruso.frame.maxY)) pt sobre a linha \(Int(linhaAgora.minY))–\(Int(linhaAgora.maxY)) (\(Int(linhaAgora.width)) pt de largura); \(adversarial.count) quadros, \(acusados.count) acusados (P ∩ O ≠ ∅), \(aindaNoPapel.count) fora do papel; primeiro achado: \(acusados.first?.intrusos.joined(separator: " | ") ?? "NENHUM")")
        #expect(acusados.count > adversarial.count / 2, "a sonda não viu uma camada plantada sobre a linha ativa — a metade P ∩ O = ∅ estaria dando verde sem portão")
        #expect(aindaNoPapel.isEmpty, "a camada adversarial não devia mexer em E ⊆ P — as duas metades são medidas separadas")
        let depois = camera.gravar(0.3) {}
        let sobrou = depois.filter { !$0.cabe }
        #expect(sobrou.isEmpty, "a camada adversarial não saiu: \(sobrou.first?.intrusos.joined(separator: " | ") ?? "")")
    }

    @Test(arguments: [UIContentSizeCategory.large]) // só large: letra grande saiu do produto (dono, 14/09)
    func aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel(tamanho: UIContentSizeCategory) throws {
        let cenario = try Cenario(cena: Self.cena(), tamanho: tamanho)
        defer { cenario.desmontar() }
        let nome = tamanho == .large ? "large" : "AX5"

        let (tv, teclado, tecladoReal) = try Self.editorPronto(cenario, nome: nome)

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

        // A ETIQUETA DE ORIGEM, que o `main` trouxe na fusão da C1-D (ADR 08u /
        // 09b): a nota feita pelo bot põe uma cápsula ACIMA do editor, e ela
        // come papel no ponto exato em que a 09d mediu o aperto. É estado de
        // PRODUÇÃO — o autor abre a nota do bot e escreve nela — e a invariante
        // 08f nunca o tinha visto, porque a etiqueta não existia quando esta
        // suíte foi escrita. Medido aqui, e não deduzido do layout.
        //
        // A ALTURA do papel NÃO serve de portão, e a medida é que diz por quê:
        // em AX XXXL, com o aviso e o toast de pé, o papel já está no PISO da
        // 09g (`pisoDoPapel / 3`, uma linha de corpo) — 86,3 pt. A cápsula
        // desce a `CadernoView` inteira, mas quem cede os 60 pt é o ENCAIXE,
        // não o papel, que já não pode encolher: 86,3 -> 86,3, empate legítimo.
        // Em `large` a cápsula custa 25 pt, sobra folga, e aí sim a altura conta
        // o movimento inteiro (209 -> 183). O que vale nos DOIS é o TOPO: a
        // cápsula fica ACIMA do editor, logo empurra o papel para BAIXO sempre
        // que desenha. É isso o portão — a etiqueta
        // que não desenhasse deixaria o topo onde estava (ADR 09j).
        let papel = { EscritaVisivel.rolagemAcima(de: tv).map { $0.convert($0.bounds, to: nil) } ?? .null }
        let semEtiqueta = papel()
        cenario.sessao.origemDaPagina = .grokbot
        Self.esperar(0.6)
        let comEtiqueta = papel()
        print("ETIQUETA \(nome): papel \(Int(semEtiqueta.minY))–\(Int(semEtiqueta.maxY)) (\(Int(semEtiqueta.height)) pt) -> \(Int(comEtiqueta.minY))–\(Int(comEtiqueta.maxY)) (\(Int(comEtiqueta.height)) pt); a cápsula desceu o topo \(Int(comEtiqueta.minY - semEtiqueta.minY)) pt e tomou \(Int(semEtiqueta.height - comEtiqueta.height)) pt de altura")
        #expect(comEtiqueta.minY > semEtiqueta.minY,
                "a etiqueta de origem não desceu o topo do papel — ou não desenhou, e então este caso não mede o que promete")
        #expect(comEtiqueta.height <= semEtiqueta.height,
                "o papel CRESCEU com a etiqueta em cena — a cápsula não pode devolver papel")
        amostras.append(Self.medir(tv, teclado: teclado, estado: "\(nome), etiqueta do bot, antes de digitar"))
        tv.selectedRange = NSRange(location: tv.text.utf16.count, length: 0)
        Self.digitar(Self.bloco, em: tv, teclado: teclado, estado: "\(nome), etiqueta do bot, fim", amostras: &amostras)

        let dentro = amostras.filter(\.cabe).count
        print("ESCRITA \(nome): \(amostras.count) amostras, \(dentro) com a linha do caret na área livre do papel; teclado \(tecladoReal ? "real" : "emulado") \(Int(teclado.height)) pt")
        #expect(amostras.count >= 20, "poucas amostras para valer como prova")
        for m in amostras where !m.cabe {
            Issue.record("a linha do caret saiu da área livre do papel — \(m.descricao)")
        }
    }
}

/// As BORDAS do TextKit 2 em `EscritaVisivel.linhaDoCaret` — o que o re-G3 da
/// C1 nomeou como prova faltante: documento vazio, linha vazia depois de `\n`,
/// quebra suave por palavra e fim do documento. O teste hospedado acima exerce
/// wraps e inserção no meio e no fim na Página real, mas não fixa estas quatro,
/// e nos `guard` sem fragmento a função cai de volta para `caretRect`.
///
/// **O que a medida achou, e muda o que dá para cobrar aqui:** num `UITextView`
/// nu — com a entrelinha do papel e até com a fonte de corpo em AX XXXL — o
/// `caretRect` do UIKit JÁ É a caixa da linha visual, ao pt, em todos os
/// offsets (a linha `LINHA` do relato conta quantos diferem: zero). A distância
/// de 45 para 67 pt que a 09d mediu é do editor da PÁGINA, não do TextKit 2 em
/// geral — quem a prova é o teste hospedado, com a Página real. Então estes
/// casos não podem cobrar "a linha é mais alta que o caret": seria uma
/// asserção que passa por acidente do aparelho. Cobram o que protege o
/// seguidor em qualquer editor: nunca nula, sempre contendo o caret, UMA linha
/// visual só, e na altura certa do documento.
@MainActor
@Suite struct LinhaDoCaretTests {

    /// A ENTRELINHA da Página (`CadernoView`: `.lineSpacing(folga)`).
    static let folga: CGFloat = 12

    /// Um `UITextView` de TextKit 2, estreito para a palavra quebrar, com a
    /// entrelinha do papel e a fonte de corpo em AX XXXL — o tamanho em que a
    /// 09d mediu a diferença entre a linha e o caret.
    private static func editor(_ texto: String, largura: CGFloat = 160,
                               tamanho: UIContentSizeCategory = .large) throws -> UITextView {
        let tv = UITextView(frame: CGRect(x: 0, y: 0, width: largura, height: 2000))
        let paragrafo = NSMutableParagraphStyle()
        paragrafo.lineSpacing = folga
        let fonte = UIFont.preferredFont(forTextStyle: .body,
                                         compatibleWith: UITraitCollection(preferredContentSizeCategory: tamanho))
        tv.attributedText = NSAttributedString(string: texto, attributes: [.font: fonte, .paragraphStyle: paragrafo])
        tv.typingAttributes = [.font: fonte, .paragraphStyle: paragrafo]
        tv.layoutIfNeeded()
        _ = try #require(tv.textLayoutManager, "o editor não é TextKit 2 — a medida da linha visual não se aplica")
        return tv
    }

    private static func linha(_ tv: UITextView, em offset: Int) throws -> (linha: CGRect, caret: CGRect) {
        let p = try #require(tv.position(from: tv.beginningOfDocument, offset: offset), "offset \(offset) fora do documento")
        return (EscritaVisivel.linhaDoCaret(tv, em: p), tv.caretRect(for: p))
    }

    /// O que o seguidor não sobrevive: uma linha nula. Ele rolaria para o vazio.
    @Test func documentoVazioDaALinhaDoCaret() throws {
        let tv = try Self.editor("")
        let (linha, caret) = try Self.linha(tv, em: 0)
        #expect(!linha.isNull && linha.height > 0, "documento vazio devolveu linha nula: \(linha)")
        #expect(linha.contains(caret.insetBy(dx: 0, dy: 0.5)), "a linha do documento vazio não contém o caret")
    }

    /// A linha VAZIA depois de `\n` — a que a 08f protege por escrito ("inclusive
    /// vazia"): ela tem de ficar ENTRE as vizinhas, não colada a uma delas.
    @Test func linhaVaziaDepoisDeQuebraDeParagrafo() throws {
        let tv = try Self.editor("um\n\ndois")
        let (primeira, _) = try Self.linha(tv, em: 0)
        let (vazia, caretVazia) = try Self.linha(tv, em: 3) // logo depois do primeiro \n
        let (ultima, _) = try Self.linha(tv, em: 5)         // no "dois"
        #expect(vazia.height > 0, "a linha vazia veio sem altura")
        #expect(vazia.contains(caretVazia.insetBy(dx: 0, dy: 0.5)), "a linha vazia não contém o caret")
        #expect(vazia.minY >= primeira.maxY - 2, "a linha vazia não ficou abaixo da primeira")
        #expect(vazia.maxY <= ultima.minY + 2, "a linha vazia não ficou acima da última")
    }

    /// A quebra SUAVE por palavra: sem `\n` nenhum, a medida tem de ser a linha
    /// da quebra e não o parágrafo — é o parágrafo que não caberia no papel.
    @Test func quebraPorPalavraMedeALinhaVisualENaoOParagrafo() throws {
        let tv = try Self.editor("quero correr de manha mas tenho preguica de levantar da cama")
        let (primeira, _) = try Self.linha(tv, em: 0)
        let (ultima, _) = try Self.linha(tv, em: tv.text.utf16.count)
        #expect(tv.contentSize.height > primeira.height * 2.5,
                "o texto não quebrou em várias linhas — o caso não foi exercido")
        #expect(ultima.minY > primeira.maxY - 2,
                "a última quebra ficou na altura da primeira: mediu o PARÁGRAFO, não a linha visual")
        #expect(ultima.height < tv.contentSize.height / 2,
                "a linha visual veio com a altura do parágrafo inteiro (\(ultima.height) de \(tv.contentSize.height))")
    }

    /// O fim do documento: o offset está em `NSMaxRange` do último fragmento, e
    /// é o `guard` que o `for` da união trata à parte.
    @Test func fimDoDocumentoCaiNaUltimaLinha() throws {
        let tv = try Self.editor("um\ndois\ntres")
        let (linha, caret) = try Self.linha(tv, em: tv.text.utf16.count)
        let (meio, _) = try Self.linha(tv, em: 4)
        #expect(linha.minY > meio.maxY - 2, "o fim do documento não caiu na última linha")
        #expect(linha.contains(caret.insetBy(dx: 0, dy: 0.5)), "a linha do fim não contém o caret")
    }

    /// UMA linha, nunca duas. Na borda de uma quebra o offset é ao mesmo tempo o
    /// fim de um fragmento e o começo do seguinte; se a união apanhasse os dois,
    /// o seguidor pediria ao papel o dobro da altura e a rolagem saltaria.
    /// Varre TODOS os offsets do documento, e de passagem conta em quantos a
    /// linha visual difere do caret neste editor — o número que sustenta o
    /// limite escrito no cabeçalho desta suíte.
    @Test func aBordaDaQuebraNaoDevolveDuasLinhas() throws {
        let tv = try Self.editor("quero correr de manha mas tenho preguica de levantar da cama")
        var alturas: [CGFloat] = []
        var diferentes = 0
        for offset in 0...tv.text.utf16.count {
            let (linha, caret) = try Self.linha(tv, em: offset)
            alturas.append(linha.height)
            if abs(linha.height - caret.height) > 0.5 || abs(linha.minY - caret.minY) > 0.5 { diferentes += 1 }
            #expect(linha.contains(caret.insetBy(dx: 0, dy: 0.5)), "offset \(offset): a linha não contém o caret")
        }
        let umaLinha = try #require(alturas.min())
        print("LINHA: \(alturas.count) offsets varridos, \(diferentes) em que a linha visual difere do caret; menor linha \(Int(umaLinha)) pt, maior \(Int(alturas.max() ?? 0)) pt")
        #expect(alturas.allSatisfy { $0 < umaLinha * 1.8 },
                "algum offset devolveu DUAS linhas unidas (alturas \(alturas.map { Int($0) })): a união pegou dois fragmentos")
    }
}
