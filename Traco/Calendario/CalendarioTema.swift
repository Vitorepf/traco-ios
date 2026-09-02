import SwiftUI

/// O mundo claro (SISTEMA-CLARO.md): papel, um acento (o preto), cápsulas,
/// hairline a 8%, sombra só no que flutua. Componente cita token, nunca hex.
enum CalendarioTema {
    // MARK: primitivos → semânticos
    static let fundo = Color(hex: 0xF4F4F2)            // papel
    static let cartao = Color.white                    // só o que flutua
    static let campo = Color(hex: 0xEBEBEA)            // névoa
    static let chip = Color(hex: 0xE8E8E6)
    static let chipActivo = Color(hex: 0x2C2C2E)       // carvão
    static let tinta = Color(hex: 0x1C1C1E)
    /// 5,2:1 sobre o chip e 5,7:1 sobre o papel. O #8E8E93 do clone media 2,96.
    static let tintaSuave = Color(hex: 0x5F5F64)
    /// Ícones e letras grandes: 3,3:1 sobre o papel.
    static let tintaFraca = Color(hex: 0x86868B)
    /// Só para dias fora do mês e desabilitado real.
    static let tintaMorta = Color(hex: 0xC7C7CC)
    static let linha = Color(hex: 0x1C1C1E).opacity(0.08)
    static let luzBorda = Color.white.opacity(0.6)
    /// A assinatura do Traço, uma vez por tela: o "agora". Fill, nunca texto.
    static let agora = Tema.ambar
    static let agoraTinta = Color(hex: 0x7A5A16)
    static let aviso = Color(hex: 0xB5432F)

    /// Sombra com tinta, não preto puro: cinza-quente.
    static let sombraFlutuante = Color(hex: 0x1C1C1E).opacity(0.08)
    static let sombraCampo = Color(hex: 0x1C1C1E).opacity(0.06)

    // MARK: tipo (escala com Dynamic Type; fecha o §22 no calendário)
    static let evento: Font = .callout.weight(.semibold)        // 16
    static let meta: Font = .footnote.weight(.medium)           // 13
    static let hora: Font = .caption.weight(.medium).monospacedDigit() // 12
    static let dia: Font = .subheadline.weight(.semibold).monospacedDigit() // 15
    static let letra: Font = .caption2.weight(.medium)          // 11
    static let chrome: Font = .body.weight(.semibold)           // 17
    static let escala: Font = .callout.weight(.semibold)        // 16
    static let tituloTracking: CGFloat = -0.6

    // MARK: forma e espaço
    static let raio: CGFloat = 18
    static let raioCampo: CGFloat = 14
    static let raioAcao: CGFloat = 10
    static let horaAltura: CGFloat = 64
    static let semanaBarra: CGFloat = 52
    static let controle: CGFloat = 36
    static let margem: CGFloat = 20

    // MARK: domínio: fundo pastel e letra escura da mesma matiz (4,8 a 8,9:1)
    static func fundo(de dominio: Dominio?) -> Color {
        switch dominio {
        case .trabalho: Color(hex: 0xC9D8F5)
        case .saude: Color(hex: 0xC8E6D4)
        case .pessoas: Color(hex: 0xF3D4C4)
        case .casa: Color(hex: 0xD9C8F0)
        case .dinheiro: Color(hex: 0xF2E2B8)
        case .estudo: Color(hex: 0xC9E3E8)
        case .ideias, .none: Color(hex: 0xE4E4E2)
        }
    }

    static func tinta(de dominio: Dominio?) -> Color {
        switch dominio {
        case .trabalho: Color(hex: 0x2F4F8A)
        case .saude: Color(hex: 0x2D6A4F)
        case .pessoas: Color(hex: 0x8A4B2F)
        case .casa: Color(hex: 0x5A3D7A)
        case .dinheiro: Color(hex: 0x6B4E0F)
        case .estudo: Color(hex: 0x245A66)
        case .ideias, .none: Color(hex: 0x3A3A3C)
        }
    }

    static func icone(de dominio: Dominio?) -> String {
        switch dominio {
        case .trabalho: "briefcase.fill"
        case .saude: "heart.fill"
        case .pessoas: "person.2.fill"
        case .casa: "house.fill"
        case .dinheiro: "banknote.fill"
        case .estudo: "book.fill"
        case .ideias: "lightbulb.fill"
        case .none: "circle.fill"
        }
    }

    // MARK: movimento
    /// Mola com massa e sem pressa, para a troca de escala e de dia.
    static func morph(_ reduce: Bool) -> Animation {
        reduce
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.55, dampingFraction: 0.86)
    }

    /// O desdobramento: a escala nova cresce do lugar do dia âncora e a antiga
    /// recua um passo. Sem blur, sem máscara: o objeto que viaja é o chip do
    /// dia, por `matchedGeometryEffect`; isto só dá corpo ao resto.
    static func desdobra(reduzido: Bool, aproximando: Bool, foco: UnitPoint) -> AnyTransition {
        if reduzido { return .opacity }
        return .asymmetric(
            insertion: .modifier(
                active: Desdobra(t: 0, escala: aproximando ? 0.92 : 1.06, foco: foco),
                identity: Desdobra(t: 1, escala: 1, foco: foco)
            ),
            removal: .modifier(
                active: Desdobra(t: 0, escala: aproximando ? 1.06 : 0.92, foco: foco),
                identity: Desdobra(t: 1, escala: 1, foco: foco)
            )
        )
    }
}

struct Desdobra: ViewModifier, Animatable {
    var t: CGFloat
    var escala: CGFloat
    var foco: UnitPoint

    var animatableData: CGFloat {
        get { t }
        set { t = newValue }
    }

    func body(content: Content) -> some View {
        let k = min(1, max(0, t))
        content
            .scaleEffect(escala + (1 - escala) * k, anchor: foco)
            .opacity(Double(k * k))
    }
}

/// Aviso curto do calendário, na voz do app: verdade, sem desculpa.
struct CalendarioToast: View {
    let texto: String

    var body: some View {
        Text(texto)
            .font(CalendarioTema.meta)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(CalendarioTema.chipActivo, in: Capsule())
            .shadow(color: CalendarioTema.sombraFlutuante, radius: 16, y: 6)
            .accessibilityIdentifier("calendario-toast")
    }
}
