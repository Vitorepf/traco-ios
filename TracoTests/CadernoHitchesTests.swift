import Testing
import UIKit
@testable import Traco

/// Medida de hitch em digitação e rolagem no `CadernoView` VIVO (ESTEIRA:
/// "Instruments quando toca editor"). O Instruments não mede isto no
/// simulador — "Hitches is not supported on this platform", "The SwiftUI
/// instrument is not supported on the Simulator" (V12-C, 08/09) —, então a
/// medida é a mesma que o instrumento faria, só que por dentro do processo:
/// um `CADisplayLink` conta os quadros que chegaram atrasados enquanto o
/// teste digita no `TextEditor` de verdade e rola o `ScrollView` de verdade.
///
/// É MEDIDA, não portão: o número vai para o relato (linhas `HITCH`), e o
/// teste só falha se a tela não estiver lá para medir. Um teto aqui seria
/// flaky com cinco simuladores disputando a máquina.
///
/// Roda SÓ quando pedido, porque dirige o app vivo (digita na Página real) e
/// isso muda o estado do processo que a suíte inteira compartilha — na V12-C
/// derrubou `IndiceTests` ao deixar a nota digitada no índice em memória:
///
///     TEST_RUNNER_TRACO_MEDIR_HITCH=1 xcodebuild test … -only-testing:TracoTests/CadernoHitchesTests
@Suite(.serialized, .enabled(if: ProcessInfo.processInfo.environment["TRACO_MEDIR_HITCH"] == "1"))
struct CadernoHitchesTests {

    /// Quem escuta o `CADisplayLink`: um instante por quadro entregue.
    final class Relogio: NSObject {
        var quadros: [(instante: CFTimeInterval, duracao: CFTimeInterval, inset: CGFloat, offset: CGFloat)] = []
        /// Sonda lida a CADA quadro: o inset inferior do papel (a altura do
        /// encaixe — muda quando o aviso/cartão entra) e o offset da rolagem.
        /// É o que separa "o aviso caiu no deslize" de "o deslize engasgou".
        var sonda: (() -> (CGFloat, CGFloat))?
        @objc func quadro(_ link: CADisplayLink) {
            let (inset, offset) = sonda?() ?? (0, 0)
            quadros.append((link.timestamp, link.duration, inset, offset))
        }

        /// Quadros perdidos: intervalo maior que 1,5 × a duração esperada (o
        /// quadro seguinte não chegou a tempo). Tempo de hitch: o atraso somado,
        /// que é o que o Instruments chama de hitch time.
        func resumo(_ fase: String, de inicio: Int) -> String {
            let fatia = Array(quadros[inicio...])
            guard fatia.count > 2 else { return "HITCH \(fase): sem quadros" }
            var perdidos = 0, atraso: CFTimeInterval = 0, maior: CFTimeInterval = 0
            var longos: [String] = []
            for i in 1..<fatia.count {
                let intervalo = fatia[i].instante - fatia[i - 1].instante
                let esperado = fatia[i].duracao
                maior = max(maior, intervalo)
                if intervalo > esperado * 1.5 {
                    perdidos += 1; atraso += intervalo - esperado
                    // cada quadro longo com o que mudou NELE: se o inset saltou, o
                    // encaixe trocou de altura nesse quadro (aviso/cartão a entrar)
                    longos.append(String(format: "HITCH   quadro longo: +%.2f s, %.1f ms, inset %.0f→%.0f pt, offset %.0f→%.0f pt",
                                         fatia[i].instante - fatia.first!.instante, intervalo * 1000,
                                         fatia[i - 1].inset, fatia[i].inset, fatia[i - 1].offset, fatia[i].offset))
                }
            }
            let total = fatia.last!.instante - fatia.first!.instante
            let linha = String(format: "HITCH %@: %d quadros em %.1f s, %d perdidos, hitch %.1f ms (%.2f ms/s), maior intervalo %.1f ms",
                               fase, fatia.count, total, perdidos, atraso * 1000, atraso * 1000 / total, maior * 1000)
            return ([linha] + longos).joined(separator: "\n")
        }
    }

    private func janela() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }

    private func procurar<V: UIView>(_ tipo: V.Type, em raiz: UIView) -> V? {
        if let v = raiz as? V { return v }
        for sub in raiz.subviews { if let v = procurar(tipo, em: sub) { return v } }
        return nil
    }

    private func scrollAcima(de v: UIView) -> UIScrollView? {
        var atual = v.superview
        while let a = atual { if let s = a as? UIScrollView { return s }; atual = a.superview }
        return nil
    }

    private func esperar(_ segundos: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(segundos))
    }

    /// A prova para o olho: a janela do app como está, gravada no tmp do contêiner.
    /// CUSTA ~140 ms na main thread (desenhar a janela + codificar 1,3 MB de PNG)
    /// e por isso nunca é chamada dentro de uma janela medida: a V12-D achou que
    /// o "quadro longo da rolagem" (V12-C) era ESTA chamada a cair a +0,15 s da
    /// fase seguinte. Cronometrada para o número ficar na linha.
    private func fotografar(_ nome: String) {
        guard let w = janela() else { return }
        let t0 = CACurrentMediaTime()
        let png = UIGraphicsImageRenderer(bounds: w.bounds).image { _ in w.drawHierarchy(in: w.bounds, afterScreenUpdates: true) }.pngData()
        let destino = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(nome)
        try? png?.write(to: destino)
        print(String(format: "HITCH captura: %@ (%.1f ms na main thread)", destino.path, (CACurrentMediaTime() - t0) * 1000))
        esperar(0.5) // o custo da captura assenta fora de qualquer fase medida
    }

    @Test func digitacaoERolagemNoCaderno() throws {
        var editor: UITextView?
        for _ in 0..<50 {
            if let w = janela(), let tv = procurar(UITextView.self, em: w) { editor = tv; break }
            esperar(0.1)
        }
        let tv = try #require(editor, "o TextEditor da Página não apareceu na janela")
        let relogio = Relogio()
        let link = CADisplayLink(target: relogio, selector: #selector(Relogio.quadro(_:)))
        link.add(to: .main, forMode: .common)
        defer { link.invalidate() }

        tv.becomeFirstResponder()
        esperar(1.0) // teclado de pé antes de medir
        // a Página começa VAZIA nos dois builds — o app reabre a última página, e
        // texto herdado mudaria a carga (e o curso da rolagem) entre as rodadas
        tv.selectAll(nil); tv.deleteBackward(); esperar(0.5)

        let bloco = "Quero correr de manha mas tenho preguica de levantar. Se de manha eu ficar na cama depois do alarme, entao eu ponho os pes no chao e visto o tenis antes de pensar. "
        let inicioDigitacao = relogio.quadros.count
        for _ in 0..<8 { // 1232 caracteres: mais do que cabe numa tela, para a rolagem ter curso
            for ch in bloco { tv.insertText(String(ch)); esperar(0.02) }
        }
        print(relogio.resumo("digitação (1232 caracteres no TextEditor)", de: inicioDigitacao))

        let sv = try #require(scrollAcima(de: tv), "o ScrollView do Caderno não foi encontrado acima do editor")
        relogio.sonda = { (sv.adjustedContentInset.bottom, sv.contentOffset.y) }
        let insetDigitado = sv.adjustedContentInset.bottom
        // A ESPERA é fase medida (V12-D): é onde a análise da pausa (1,6 s depois
        // da última tecla) faria o encaixe mudar, e a sonda mostra se mudou.
        let inicioEspera = relogio.quadros.count
        esperar(3.0)
        let insetsDaEspera = relogio.quadros[inicioEspera...].map(\.inset)
        print(relogio.resumo("espera da análise (3,0 s depois da última tecla)", de: inicioEspera))
        print(String(format: "HITCH aviso: inset %.0f pt ao fim da digitação, mín %.0f / máx %.0f pt durante a espera, %.0f pt ao fim (%@)",
                     insetDigitado, insetsDaEspera.min() ?? 0, insetsDaEspera.max() ?? 0, sv.adjustedContentInset.bottom,
                     (insetsDaEspera.max() ?? 0) == insetDigitado ? "o encaixe NÃO mudou: nem 'lendo…' nem cartão entraram" : "o encaixe mudou durante a espera"))
        fotografar("hitch-digitado.png") // a linha do autor com o teclado de pé, o encaixe como está
        print(String(format: "HITCH geometria antes de rolar: inset inferior %.0f pt, TextKit %@", sv.adjustedContentInset.bottom,
                     tv.textLayoutManager == nil ? "1" : "2"))
        let fundo = max(0, sv.contentSize.height - sv.bounds.height + sv.adjustedContentInset.bottom)
        #expect(fundo > 0, "o papel não rola — a medida de rolagem não mediu nada")
        // V12-D: a PRIMEIRA descida é fase própria — é nela que a V12-C via o
        // quadro longo (a +0,13–0,19 s, inset parado em 192→192 pt, chamada de
        // rolar < 1 ms), e ele era a captura logo acima a assentar. Separada, se
        // um dia voltar, a linha diz em que fase.
        let inicioRevelacao = relogio.quadros.count
        sv.setContentOffset(CGPoint(x: 0, y: fundo), animated: true); esperar(0.7)
        print(relogio.resumo("primeira descida (revela o texto abaixo da dobra, curso \(Int(fundo)) pt)", de: inicioRevelacao))
        let inicioRolagem = relogio.quadros.count
        for _ in 0..<3 {
            sv.setContentOffset(.zero, animated: true); esperar(0.7)
            sv.setContentOffset(CGPoint(x: 0, y: fundo), animated: true); esperar(0.7)
        }
        print(relogio.resumo("rolagem em regime (3 idas e voltas, curso \(Int(fundo)) pt)", de: inicioRolagem))
        print(String(format: "HITCH geometria: conteúdo %.0f pt, janela %.0f pt, inset inferior %.0f pt, teclado %@",
                     sv.contentSize.height, sv.bounds.height, sv.adjustedContentInset.bottom, tv.isFirstResponder ? "de pé" : "fechado"))
        #expect(relogio.quadros.count > 60, "o CADisplayLink não contou quadros — nada foi medido")

        // a prova para o olho: o papel rolado até o fim, com o teclado de pé —
        // é aqui que se vê se a última linha do autor fica visível acima do encaixe
        sv.setContentOffset(CGPoint(x: 0, y: fundo), animated: false); esperar(1.0)
        fotografar("hitch-fim.png")
    }
}
