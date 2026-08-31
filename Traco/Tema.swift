import SwiftUI

enum Tema {
    static let fundo = Color(hex: 0x0B0B0D)
    static let superficie = Color(hex: 0x161619)
    static let superficieAlta = Color(hex: 0x1E1E22)
    static let tinta = Color(hex: 0xECECEA)
    static let tintaSuave = Color(hex: 0x9A9A96)
    static let tintaFraca = Color(hex: 0x6B6B70)
    static let linha = Color(hex: 0x26262A)
    static let ambar = Color(hex: 0xD9A542)
    static let ambarSuave = Color(hex: 0xD9A542).opacity(0.14)
    static let aviso = Color(hex: 0xC4614D)
    static let codigoFundo = Color(hex: 0x12141A)
    static let codigoGutter = Color(hex: 0x0E1016)
    static let synChave = Color(hex: 0xC9A56A)
    static let synValor = Color(hex: 0x7EB8A8)
    static let synNumero = Color(hex: 0x8AA4C8)
    static let synTipo = Color(hex: 0x9B8FBF)
    static let synFuncao = Color(hex: 0x8EB4D4)
    static let synPontuacao = Color(hex: 0x6E6E6A)
    static let synComentario = tintaFraca
    static let synTexto = tinta
    static let mono: Font = .body.monospaced()
    static let tituloNota: Font = .title2.weight(.semibold)
    static let secaoNota: Font = .title3.weight(.semibold)

    static let corpo: Font = .body
    static let chrome: Font = .subheadline
    static let tituloTela: Font = .headline
    static let meta: Font = .footnote
    static let barra: Font = .subheadline.weight(.semibold)
    static let label: Font = .caption.weight(.semibold)
    static let trackingLabel: CGFloat = 1.2
    static let confirmacaoTitulo: Font = .title.weight(.semibold)
    static let confirmacaoCorpo: Font = .body

    static let raio: CGFloat = 12
    static let raioCartao: CGFloat = 14
    static let alvo: CGFloat = 44
    static let margem: CGFloat = 22
    static let pressao: CGFloat = 0.94

    static let formaNasce: Double = 0.48
    static let cartaoEntra: Double = 0.26
    static let cartaoSai: Double = 0.16
    static let confirmacaoEntra: Double = 0.22
    static let push: Double = 0.40

    static func gaveta(reduzido: Bool) -> Animation {
        reduzido
            ? .easeOut(duration: 0.18)
            : .timingCurve(0.32, 0.72, 0, 1, duration: push)
    }

    static func cartao(reduzido: Bool, aEntrar: Bool) -> Animation {
        if reduzido { return .easeOut(duration: 0.18) }
        return .easeOut(duration: aEntrar ? cartaoEntra : cartaoSai)
    }
}

extension Color {
    nonisolated init(hex: UInt32, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct PressaoDiscreta: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            // press quase instantâneo; o soltar volta com vida (spring leve)
            .animation(configuration.isPressed
                ? .easeOut(duration: 0.08)
                : .spring(response: 0.32, dampingFraction: 0.65),
                value: configuration.isPressed)
    }
}
