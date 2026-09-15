import SwiftUI

/// A forma dos ícones do iPhone: superelipse |x|ⁿ + |y|ⁿ = 1, n = 5. Não é um
/// retângulo de cantos arredondados — o lado já curva antes do canto, e é isso
/// que faz um ícone da Apple parecer "cheio" (dono, 15/09: "o formato está
/// diferente do da Apple").
nonisolated struct Superelipse: Shape {
    var expoente: Double = 5

    func path(in rect: CGRect) -> Path {
        let a = rect.width / 2, b = rect.height / 2
        let cx = rect.midX, cy = rect.midY
        let e = 2 / expoente
        var p = Path()
        let passos = 180
        for i in 0...passos {
            let t = Double(i) / Double(passos) * 2 * .pi
            let c = cos(t), s = sin(t)
            let x = cx + a * CGFloat(copysign(pow(abs(c), e), c))
            let y = cy + b * CGFloat(copysign(pow(abs(s), e), s))
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        p.closeSubpath()
        return p
    }
}
