import SwiftUI

/// O calendário é um mundo claro — o clone do vídeo, não a página preta.
enum CalendarioTema {
    static let fundo = Color(hex: 0xF4F4F2)
    static let cartao = Color.white
    static let tinta = Color(hex: 0x1C1C1E)
    static let tintaSuave = Color(hex: 0x8E8E93)
    static let tintaFraca = Color(hex: 0xC7C7CC)
    static let chip = Color(hex: 0xE8E8E6)
    static let chipActivo = Color(hex: 0x2C2C2E)
    static let linha = Color(hex: 0x1C1C1E).opacity(0.08)
    static let agora = Color(hex: 0xAEAEB2)
    static let agoraLinha = Color(hex: 0x5B7CFF)
    static let campo = Color(hex: 0xEBEBEA)

    static let trabalho = Color(hex: 0xC9D8F5)
    static let trabalhoTinta = Color(hex: 0x2F4F8A)
    static let corpo = Color(hex: 0xC8E6D4)
    static let corpoTinta = Color(hex: 0x2D6A4F)
    static let social = Color(hex: 0xF3D4C4)
    static let socialTinta = Color(hex: 0x8A4B2F)
    static let casa = Color(hex: 0xD9C8F0)
    static let casaTinta = Color(hex: 0x5A3D7A)
    static let outro = Color(hex: 0xE4E4E2)
    static let outroTinta = Color(hex: 0x3A3A3C)

    static let titulo: Font = .system(size: 32, weight: .bold)
    static let evento: Font = .system(size: 16, weight: .semibold)
    static let meta: Font = .system(size: 13, weight: .medium)
    static let hora: Font = .system(size: 12, weight: .medium)
    static let dia: Font = .system(size: 15, weight: .semibold)
    static let letra: Font = .system(size: 11, weight: .medium)

    static let raio: CGFloat = 18
    static let raioPequeno: CGFloat = 12
    static let horaAltura: CGFloat = 72
    static let semanaBarra: CGFloat = 52

    static func fundo(de categoria: CategoriaEvento) -> Color {
        switch categoria {
        case .trabalho: trabalho
        case .corpo: corpo
        case .social: social
        case .casa: casa
        case .outro: outro
        }
    }

    static func tinta(de categoria: CategoriaEvento) -> Color {
        switch categoria {
        case .trabalho: trabalhoTinta
        case .corpo: corpoTinta
        case .social: socialTinta
        case .casa: casaTinta
        case .outro: outroTinta
        }
    }

    static func icone(de categoria: CategoriaEvento) -> String {
        switch categoria {
        case .trabalho: "briefcase.fill"
        case .corpo: "figure.run"
        case .social: "fork.knife"
        case .casa: "basket.fill"
        case .outro: "square.grid.2x2.fill"
        }
    }

    static func morph(_ reduce: Bool) -> Animation {
        reduce
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.55, dampingFraction: 0.86)
    }

    /// O vídeo desdobra a escala na diagonal, com desfoque — não um cross-fade.
    static func transicao(reduzido: Bool) -> AnyTransition {
        reduzido
            ? .opacity
            : .asymmetric(
                insertion: .modifier(
                    active: CalendarioClipDiagonal(progresso: 0, saida: false),
                    identity: CalendarioClipDiagonal(progresso: 1, saida: false)
                ),
                removal: .modifier(
                    active: CalendarioClipDiagonal(progresso: 0, saida: true),
                    identity: CalendarioClipDiagonal(progresso: 1, saida: true)
                )
            )
    }
}

/// Clip diagonal animável: entra do canto de cima; sai pelo oposto, borrada.
struct CalendarioClipDiagonal: ViewModifier, Animatable {
    var progresso: CGFloat
    var saida: Bool

    var animatableData: CGFloat {
        get { progresso }
        set { progresso = newValue }
    }

    func body(content: Content) -> some View {
        let t = min(1, max(0, progresso))
        let blur = (1 - t) * (saida ? 14 : 8)
        let escala = saida ? (0.90 + 0.10 * t) : (0.94 + 0.06 * t)
        content
            .scaleEffect(escala, anchor: saida ? UnitPoint(x: 0.92, y: 0.88) : UnitPoint(x: 0.08, y: 0.12))
            .blur(radius: blur)
            .opacity(0.2 + 0.8 * t)
            .mask {
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: t),
                                    .init(color: .clear, location: min(1, t + 0.18)),
                                ],
                                startPoint: saida ? UnitPoint(x: 1, y: 1) : UnitPoint(x: 0, y: 0),
                                endPoint: saida ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 1, y: 1)
                            )
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
    }
}
