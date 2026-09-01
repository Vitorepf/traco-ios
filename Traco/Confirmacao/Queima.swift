import SwiftUI

/// A queima em cena (SPEC §8; pedido do dono, 01/set: "tem que ter toda uma
/// animação de queimando a folha e aquilo sendo destruído pelo fogo").
///
/// Três camadas, todas determinísticas (fases fixas — nada de random por
/// quadro, o flow pode reproduzir):
/// 1. A MÁSCARA: revela o que ainda não queimou; a frente é uma linha
///    irregular (soma de senos) que sobe consumindo a folha.
/// 2. A BRASA: a mesma linha, traçada em âmbar→laranja com blur — o vinco
///    incandescente onde o papel está virando cinza.
/// 3. AS FAGULHAS: partículas nascem na frente e sobem à deriva, apagando.
///
/// Reduced motion: quem chama pula a cena inteira (só opacity, como antes).
nonisolated enum Queima {
    static func suave(_ a: CGFloat, _ b: CGFloat, _ x: CGFloat) -> CGFloat {
        let t = min(1, max(0, (x - a) / max(b - a, 0.0001)))
        return t * t * (3 - 2 * t)
    }

    /// O ritual tem atos (dono, 01/set: "o fim de um ciclo e o começo de uma
    /// nova era"): o fogo PEGA antes de a folha ceder, ruge no meio, e colapsa
    /// em cinzas no fim. Estes envelopes dirigem tudo a partir de um progresso.
    /// Intensidade do fogo: 0 na ignição, 1 na fúria, morre nas cinzas.
    static func fogo(_ p: CGFloat) -> CGFloat {
        suave(0.02, 0.20, p) * (1 - suave(0.86, 0.99, p))
    }

    /// O mundo escurece em volta da folha: só o fogo ilumina.
    static func escuridao(_ p: CGFloat) -> CGFloat {
        suave(0.0, 0.14, p)
    }

    /// A frente só começa a subir DEPOIS de o fogo pegar — e acelera.
    static func frenteRemapada(_ p: CGFloat) -> CGFloat {
        let t = min(1, max(0, (p - 0.14) / 0.82))
        return t * t * (3 - 2 * t)
    }

    /// A altura da frente para um progresso 0…1 (0 = folha intacta).
    /// A folga acima/abaixo garante que a borda irregular não corta antes
    /// da hora nem deixa resto no fim.
    static func alturaDaFrente(_ progresso: CGFloat, em rect: CGRect) -> CGFloat {
        let folga: CGFloat = 44
        return rect.maxY + folga - frenteRemapada(progresso) * (rect.height + folga * 2)
    }

    /// A borda irregular do papel queimando: soma de senos com fases fixas.
    static func recorte(_ x: CGFloat, base: CGFloat, largura: CGFloat) -> CGFloat {
        let t = x / max(largura, 1)
        let a = sin(t * 19.0 + 1.7) * 9
        let b = sin(t * 41.0 + 0.4) * 5
        let c = sin(t * 7.0 + 3.9) * 14
        return base + a + b + c
    }

    /// O caminho da frente, da esquerda para a direita.
    static func linhaDaFrente(_ rect: CGRect, frente: CGFloat) -> Path {
        var p = Path()
        let passo: CGFloat = 6
        p.move(to: CGPoint(x: rect.minX, y: recorte(0, base: frente, largura: rect.width)))
        var x = rect.minX + passo
        while x <= rect.maxX {
            p.addLine(to: CGPoint(x: x, y: recorte(x, base: frente, largura: rect.width)))
            x += passo
        }
        p.addLine(to: CGPoint(x: rect.maxX, y: recorte(rect.maxX, base: frente, largura: rect.width)))
        return p
    }
}

/// Aplica a cena inteira com o progresso INTERPOLADO por quadro: um overlay
/// comum receberia o valor final na hora e a brasa saltaria para o topo
/// enquanto a máscara ainda anima.
struct QueimaModifier: ViewModifier, Animatable {
    var progresso: CGFloat
    var animatableData: CGFloat {
        get { progresso }
        set { progresso = newValue }
    }

    func body(content: Content) -> some View {
        content
            .mask(FrenteDeQueima(progresso: progresso))
            .overlay(BrasaDaQueima(progresso: progresso))
    }
}

/// Máscara: o que fica é o papel ACIMA da frente (o fogo sobe).
struct FrenteDeQueima: Shape {
    var progresso: CGFloat
    var animatableData: CGFloat {
        get { progresso }
        set { progresso = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let frente = Queima.alturaDaFrente(progresso, em: rect)
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY - 60))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY - 60))
        p.addLine(to: CGPoint(x: rect.maxX, y: Queima.recorte(rect.maxX, base: frente, largura: rect.width)))
        let passo: CGFloat = 6
        var x = rect.maxX - passo
        while x >= rect.minX {
            p.addLine(to: CGPoint(x: x, y: Queima.recorte(x, base: frente, largura: rect.width)))
            x -= passo
        }
        p.addLine(to: CGPoint(x: rect.minX, y: Queima.recorte(0, base: frente, largura: rect.width)))
        p.closeSubpath()
        return p
    }
}

/// O fogo dramático: o mundo escurece, a chama pega embaixo, ruge consumindo
/// a folha com línguas altas e uma tempestade de fagulhas, e colapsa em
/// cinzas. `progresso` anima por fora; o TimelineView tremula e move.
struct BrasaDaQueima: View {
    var progresso: CGFloat

    var body: some View {
        TimelineView(.animation) { contexto in
            Canvas { ctx, tamanho in
                guard progresso > 0.001, progresso < 0.999 else { return }
                let rect = CGRect(origin: .zero, size: tamanho)
                let frente = Queima.alturaDaFrente(progresso, em: rect)
                let t = contexto.date.timeIntervalSinceReferenceDate
                let fogo = Queima.fogo(progresso)
                let escuro = Queima.escuridao(progresso)

                func yFrente(_ x: CGFloat) -> CGFloat {
                    Queima.recorte(x, base: frente, largura: rect.width)
                }

                // 0. O MUNDO ESCURECE: o ritual apaga o resto — só o fogo
                // ilumina (o batimento vem da própria luz das chamas)
                let respira = 1 + 0.06 * sin(t * 9) * Double(fogo)
                ctx.fill(Path(rect), with: .color(.black.opacity(0.55 * escuro * respira)))

                // 1. A LUZ DO FOGO lambe a folha inteira acima da frente
                var luz = ctx
                luz.addFilter(.blur(radius: 30))
                let alcance = 180 + 80 * fogo
                let faixaLuz = CGRect(x: rect.minX, y: frente - alcance, width: rect.width, height: alcance + 20)
                luz.fill(Path(faixaLuz), with: .linearGradient(
                    Gradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.06).opacity(0),
                                      Color(red: 1.0, green: 0.42, blue: 0.06).opacity(0.45 * fogo * respira)]),
                    startPoint: CGPoint(x: 0, y: faixaLuz.minY),
                    endPoint: CGPoint(x: 0, y: faixaLuz.maxY)))

                // 2. CARBONIZAÇÃO: o papel escurece e enruga antes de ceder
                var carvao = ctx
                carvao.addFilter(.blur(radius: 9))
                carvao.stroke(Queima.linhaDaFrente(rect, frente: frente - 16),
                              with: .color(.black.opacity(0.85)),
                              style: StrokeStyle(lineWidth: 34, lineCap: .round))

                // 3. AS CHAMAS: vinte línguas altas, cada uma viva por conta
                // própria — altura, inclinação e brilho tremulando rápido
                for j in 0..<20 {
                    let fj = Double(j)
                    let x = rect.minX + (CGFloat(j) + 0.5) * rect.width / 20
                    let base = yFrente(x) + 4
                    let vivo = 0.45 + 0.55 * (0.5 + 0.5 * sin(t * (9.0 + fj.truncatingRemainder(dividingBy: 4)) + fj * 2.1))
                    let altura = (30 + 85 * CGFloat(vivo)) * fogo * (0.75 + 0.25 * sin(fj * 1.3))
                    guard altura > 4 else { continue }
                    let larg = (10 + 6 * sin(fj * 2.7)) * (0.7 + 0.3 * fogo)
                    let lean = CGFloat(sin(t * 3.4 + fj * 0.9)) * 9

                    func lingua(_ escala: CGFloat) -> Path {
                        var p = Path()
                        let h = altura * escala
                        let w = larg * escala
                        p.move(to: CGPoint(x: x - w, y: base))
                        p.addQuadCurve(to: CGPoint(x: x + lean, y: base - h),
                                       control: CGPoint(x: x - w * 0.95, y: base - h * 0.5))
                        p.addQuadCurve(to: CGPoint(x: x + w, y: base),
                                       control: CGPoint(x: x + w * 0.95 + lean, y: base - h * 0.5))
                        p.closeSubpath()
                        return p
                    }

                    var chama = ctx
                    chama.addFilter(.blur(radius: 4))
                    chama.fill(lingua(1), with: .linearGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.50, blue: 0.08).opacity(0.95 * vivo),
                                          Color(red: 0.9, green: 0.18, blue: 0.03).opacity(0)]),
                        startPoint: CGPoint(x: x, y: base),
                        endPoint: CGPoint(x: x, y: base - altura)))
                    var meio = ctx
                    meio.addFilter(.blur(radius: 2))
                    meio.fill(lingua(0.62), with: .linearGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.78, blue: 0.25).opacity(0.95 * vivo),
                                          Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0)],),
                        startPoint: CGPoint(x: x, y: base),
                        endPoint: CGPoint(x: x, y: base - altura * 0.72)))
                    var nucleo = ctx
                    nucleo.addFilter(.blur(radius: 0.8))
                    nucleo.fill(lingua(0.3), with: .linearGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.97, blue: 0.82).opacity(0.95 * vivo),
                                          Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0)],),
                        startPoint: CGPoint(x: x, y: base),
                        endPoint: CGPoint(x: x, y: base - altura * 0.45)))
                }

                // 4. A BRASA: o vinco incandescente onde o papel acaba
                let tremor = 0.75 + 0.25 * sin(t * 19)
                var halo = ctx
                halo.addFilter(.blur(radius: 6))
                halo.stroke(Queima.linhaDaFrente(rect, frente: frente),
                            with: .color(Color(red: 1.0, green: 0.42, blue: 0.06).opacity(0.95 * tremor)),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round))
                ctx.stroke(Queima.linhaDaFrente(rect, frente: frente + 1),
                           with: .color(Color(red: 1.0, green: 0.88, blue: 0.55).opacity(0.95 * tremor)),
                           style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

                // 5. TEMPESTADE DE FAGULHAS: sobem rápido, morrem no ar
                for i in 0..<60 {
                    let fase = Double(i) * 0.617
                    let ciclo = 0.55 + (Double(i).truncatingRemainder(dividingBy: 5)) * 0.17
                    let vida = (t / ciclo + fase).truncatingRemainder(dividingBy: 1)
                    let x = CGFloat((fase * 997).truncatingRemainder(dividingBy: 1)) * rect.width
                    let sobe = CGFloat(vida) * (80 + CGFloat(i % 5) * 40)
                    let deriva = sin(vida * 8 + fase) * 12
                    let y = yFrente(x) - sobe
                    guard y > rect.minY else { continue }
                    let apaga = (1 - vida) * (1 - vida) * Double(fogo)
                    guard apaga > 0.02 else { continue }
                    let cor = Color(red: 1.0, green: 0.55 + 0.35 * apaga, blue: 0.12).opacity(0.95 * apaga)
                    let raio: CGFloat = 1.1 + CGFloat(i % 3) * 0.6
                    ctx.fill(Path(ellipseIn: CGRect(x: x + deriva - raio, y: y - raio,
                                                    width: raio * 2, height: raio * 2)),
                             with: .color(cor))
                }

                // 6. FUMAÇA: véus subindo devagar, mais densos na fúria
                var fumo = ctx
                fumo.addFilter(.blur(radius: 12))
                for i in 0..<8 {
                    let fase = Double(i) * 1.37
                    let vida = (t / 2.2 + fase).truncatingRemainder(dividingBy: 1)
                    let x = CGFloat((fase * 379).truncatingRemainder(dividingBy: 1)) * rect.width
                    let y = yFrente(x) - 60 - CGFloat(vida) * 160
                    guard y > rect.minY else { continue }
                    let r = 12 + CGFloat(vida) * 26
                    fumo.fill(Path(ellipseIn: CGRect(x: x + sin(vida * 5 + fase) * 18 - r,
                                                     y: y - r, width: r * 2, height: r * 2)),
                              with: .color(Color(white: 0.5).opacity(0.20 * (1 - vida) * Double(fogo))))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
