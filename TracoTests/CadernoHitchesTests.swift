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
        var quadros: [(instante: CFTimeInterval, duracao: CFTimeInterval)] = []
        @objc func quadro(_ link: CADisplayLink) { quadros.append((link.timestamp, link.duration)) }

        /// Quadros perdidos: intervalo maior que 1,5 × a duração esperada (o
        /// quadro seguinte não chegou a tempo). Tempo de hitch: o atraso somado,
        /// que é o que o Instruments chama de hitch time.
        func resumo(_ fase: String, de inicio: Int) -> String {
            let fatia = Array(quadros[inicio...])
            guard fatia.count > 2 else { return "HITCH \(fase): sem quadros" }
            var perdidos = 0, atraso: CFTimeInterval = 0, maior: CFTimeInterval = 0
            for i in 1..<fatia.count {
                let intervalo = fatia[i].instante - fatia[i - 1].instante
                let esperado = fatia[i].duracao
                maior = max(maior, intervalo)
                if intervalo > esperado * 1.5 { perdidos += 1; atraso += intervalo - esperado }
            }
            let total = fatia.last!.instante - fatia.first!.instante
            return String(format: "HITCH %@: %d quadros em %.1f s, %d perdidos, hitch %.1f ms (%.2f ms/s), maior intervalo %.1f ms",
                          fase, fatia.count, total, perdidos, atraso * 1000, atraso * 1000 / total, maior * 1000)
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
    private func fotografar(_ nome: String) {
        guard let w = janela() else { return }
        let png = UIGraphicsImageRenderer(bounds: w.bounds).image { _ in w.drawHierarchy(in: w.bounds, afterScreenUpdates: true) }.pngData()
        let destino = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(nome)
        try? png?.write(to: destino)
        print("HITCH captura: \(destino.path)")
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
        fotografar("hitch-digitado.png") // onde a linha do autor está, com o teclado de pé

        let sv = try #require(scrollAcima(de: tv), "o ScrollView do Caderno não foi encontrado acima do editor")
        esperar(2.5) // a análise da pausa veste a forma; o encaixe muda de altura aqui
        fotografar("hitch-vestido.png") // o cartão no encaixe, teclado de pé
        print(String(format: "HITCH geometria com cartão: inset inferior %.0f pt", sv.adjustedContentInset.bottom))
        let fundo = max(0, sv.contentSize.height - sv.bounds.height + sv.adjustedContentInset.bottom)
        #expect(fundo > 0, "o papel não rola — a medida de rolagem não mediu nada")
        let inicioRolagem = relogio.quadros.count
        for _ in 0..<3 {
            sv.setContentOffset(CGPoint(x: 0, y: fundo), animated: true); esperar(0.7)
            sv.setContentOffset(.zero, animated: true); esperar(0.7)
        }
        print(relogio.resumo("rolagem (3 idas e voltas, curso \(Int(fundo)) pt)", de: inicioRolagem))
        print(String(format: "HITCH geometria: conteúdo %.0f pt, janela %.0f pt, inset inferior %.0f pt, teclado %@",
                     sv.contentSize.height, sv.bounds.height, sv.adjustedContentInset.bottom, tv.isFirstResponder ? "de pé" : "fechado"))
        #expect(relogio.quadros.count > 60, "o CADisplayLink não contou quadros — nada foi medido")

        // a prova para o olho: o papel rolado até o fim, com o teclado de pé —
        // é aqui que se vê se a última linha do autor fica visível acima do encaixe
        sv.setContentOffset(CGPoint(x: 0, y: fundo), animated: false); esperar(1.0)
        fotografar("hitch-fim.png")
    }
}
