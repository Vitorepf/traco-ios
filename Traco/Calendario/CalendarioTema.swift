import SwiftUI
import UIKit

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
    /// O mesmo passo do `Tema.tintaFraca` (ADR 02h × varredura 04/set): 5,04:1
    /// no papel. As horas da grade e os dias de outro mês são TEXTO.
    static let tintaFraca = Color(hex: 0x68686C)
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
    /// A semana da âncora no ano e no mês: azul de papel, o "onde estou" do clone.
    static let semanaAncora = Color(hex: 0xD6E2F8)
    /// A luz do papel: o centro um fio mais claro que a borda, como folha sob luz.
    static var papel: some ShapeStyle {
        RadialGradient(colors: [Color(hex: 0xF7F7F5), fundo], center: UnitPoint(x: 0.5, y: 0.35), startRadius: 0, endRadius: 700)
    }
    /// Trilho afundado: o que recebe o dedo está um degrau abaixo do papel.
    static var trilho: some ShapeStyle {
        campo.shadow(.inner(color: Color(hex: 0x1C1C1E).opacity(0.10), radius: 3, y: 1))
            .shadow(.inner(color: .white.opacity(0.9), radius: 1, y: -1))
    }
    /// O controle selecionado é o único objeto que se levanta do trilho.
    static let sombraControle = Color(hex: 0x1C1C1E).opacity(0.28)

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

    /// A deixa de uma nota é papel com contorno, não tinta chapada: vem de
    /// fora do calendário e a nota é a dona. O do iPhone (A3) é papel também,
    /// e mais apagado ainda: não é nosso, não se edita, e não pode competir
    /// com o que o autor marcou aqui.
    static func fundo(de evento: EventoCalendario) -> Color {
        if evento.doSistema { return cartao }
        return evento.eDeixa ? cartao : fundo(de: evento.dominio)
    }

    static func tinta(de evento: EventoCalendario) -> Color {
        if evento.doSistema { return tintaSuave }
        return evento.eDeixa ? tinta : tinta(de: evento.dominio)
    }

    static func icone(de evento: EventoCalendario) -> String {
        if evento.doSistema { return "circle.dotted" }
        return evento.eDeixa ? "arrow.turn.down.right" : icone(de: evento.dominio)
    }

    /// Quem leva contorno em vez de fundo cheio: o que não nasceu aqui.
    static func temContorno(_ evento: EventoCalendario) -> Bool {
        evento.eDeixa || evento.doSistema
    }

    static let contornoSistema = Color(hex: 0x1C1C1E).opacity(0.18)

    static func contorno(de evento: EventoCalendario) -> Color {
        evento.doSistema ? contornoSistema : contornoDeixa
    }

    static let contornoDeixa = Color(hex: 0x1C1C1E).opacity(0.35)

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
                active: Desdobra(t: 0, escala: aproximando ? 0.92 : 1.06, foco: foco, saida: false),
                identity: Desdobra(t: 1, escala: 1, foco: foco, saida: false)
            ),
            removal: .modifier(
                active: Desdobra(t: 0, escala: aproximando ? 1.06 : 0.92, foco: foco, saida: true),
                identity: Desdobra(t: 1, escala: 1, foco: foco, saida: true)
            )
        )
    }
}

struct Desdobra: ViewModifier, Animatable {
    var t: CGFloat
    var escala: CGFloat
    var foco: UnitPoint
    var saida: Bool

    var animatableData: CGFloat {
        get { t }
        set { t = newValue }
    }

    func body(content: Content) -> some View {
        let k = min(1, max(0, t))
        // quem sai some cedo (k⁴); quem entra amanhece (k²): nunca duas
        // escalas meio opacas ao mesmo tempo
        let opacidade = saida ? k * k * k * k : k * k
        content
            .scaleEffect(escala + (1 - escala) * k, anchor: foco)
            .opacity(Double(opacidade))
    }
}

/// Pressão no mundo claro: só escala. Baixar a opacidade (o estilo da casa
/// no escuro) sobre papel lê como piscar.
struct PressaoClara: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
    }
}

/// Texto que desvanece na borda direita em vez de cortar no meio da letra.
struct Desvanece: ViewModifier {
    var largura: CGFloat = 14

    func body(content: Content) -> some View {
        content.mask {
            HStack(spacing: 0) {
                Rectangle()
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: largura)
            }
        }
    }
}

extension View {
    func desvanece(_ largura: CGFloat = 14) -> some View { modifier(Desvanece(largura: largura)) }
}

/// Aviso curto do calendário, na voz do app: verdade, sem desculpa.
struct CalendarioToast: View {
    let texto: String
    /// ADR 03e × 04a: aviso sem saída é beco. Quando o que falhou tem uma
    /// volta — e a única que o iOS dá é os Ajustes — ela vem no próprio toast.
    var ajustes = false

    var body: some View {
        HStack(spacing: 14) {
            Text(texto)
                .font(CalendarioTema.meta)
                .foregroundStyle(.white)
            if ajustes {
                Button("Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(CalendarioTema.meta.weight(.semibold))
                .foregroundStyle(Tema.ambar)
                .accessibilityIdentifier("toast-ajustes")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(CalendarioTema.chipActivo, in: Capsule())
        .shadow(color: CalendarioTema.sombraFlutuante, radius: 16, y: 6)
        .accessibilityIdentifier("calendario-toast")
    }
}

/// Arrastar para andar no tempo. É um `UIPanGestureRecognizer` de verdade,
/// não um `DragGesture`: o do SwiftUI perdia para os botões e para o
/// ScrollView; este só começa quando o dedo já mostrou o eixo, e convive
/// com o scroll vertical do dia.
struct Arrasto: UIGestureRecognizerRepresentable {
    enum Eixo { case horizontal, ambos }
    var eixo: Eixo = .horizontal
    /// passo +1 = seguinte, −1 = anterior
    var aoTerminar: (Int) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let g = UIPanGestureRecognizer()
        g.delegate = context.coordinator
        g.maximumNumberOfTouches = 1
        return g
    }

    func handleUIGestureRecognizerAction(_ g: UIPanGestureRecognizer, context: Context) {
        guard g.state == .ended, let vista = g.view else { return }
        let t = g.translation(in: vista)
        let v = g.velocity(in: vista)
        let horizontal = abs(t.x) >= abs(t.y)
        let d = horizontal ? t.x : t.y
        let vel = horizontal ? v.x : v.y
        guard abs(d) > 44 || abs(vel) > 600 else { return }
        if eixo == .horizontal, !horizontal { return }
        aoTerminar(d < 0 ? 1 : -1)
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordenador {
        Coordenador(eixo: eixo)
    }

    final class Coordenador: NSObject, UIGestureRecognizerDelegate {
        let eixo: Eixo
        init(eixo: Eixo) { self.eixo = eixo }

        func gestureRecognizerShouldBegin(_ g: UIGestureRecognizer) -> Bool {
            guard let p = g as? UIPanGestureRecognizer, let vista = p.view else { return false }
            let v = p.velocity(in: vista)
            switch eixo {
            case .horizontal: return abs(v.x) > abs(v.y) * 1.5
            case .ambos: return true
            }
        }

        func gestureRecognizer(_ g: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith outro: UIGestureRecognizer) -> Bool {
            // o scroll vertical do dia continua dele; o nosso só vale no eixo X
            true
        }
    }
}
