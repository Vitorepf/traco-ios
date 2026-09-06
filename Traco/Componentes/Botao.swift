import SwiftUI

/// Três estilos de botão para os sete que a auditoria V9 contou. Todos
/// pressionam com `Tema.pressaoAnim` e escala `Tema.pressao`; sob Reduzir
/// Movimento a pressão não anima (é escala: o estado vira).
///
/// - `.discreto`: o rótulo como está; só escala (é a `PressaoDiscreta` de
///   `Tema`, que segue lá porque a página, o caderno e o perfil a usam).
/// - `.primario`: a ação principal em âmbar-tinta, largura inteira, alvo 44;
///   recua para `tintaFraca` quando desabilitado.
/// - `.compacto`: ação secundária em linha, alvo 44, sem cor própria.
///
/// Ainda fora (arquivos de outras voltas): `PressaoClara` (CalendarioTema),
/// `CompactoStyle` e `CartaoBotaoStyle` (CartaoAnaliseView), `BarraBotaoStyle`
/// (PaginaView, desenho do dono) e `AcaoTrabalhoStyle` (TrabalhoView).
struct BotaoPrimario: ButtonStyle {
    var alinhamento: Alignment = .center
    @Environment(\.isEnabled) private var ativo
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(Tema.pressaoAnim(configuration.isPressed, reduzido: reduceMotion), value: configuration.isPressed)
            .font(Tema.barra)
            .foregroundStyle(ativo ? Tema.ambarTinta : Tema.tintaFraca)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: alinhamento)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct BotaoCompacto: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Tema.barra)
            .alvo()
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(Tema.pressaoAnim(configuration.isPressed, reduzido: reduceMotion), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressaoDiscreta {
    static var discreto: PressaoDiscreta { PressaoDiscreta() }
}

extension ButtonStyle where Self == BotaoPrimario {
    static var primario: BotaoPrimario { BotaoPrimario() }
    static func primario(alinhamento: Alignment) -> BotaoPrimario { BotaoPrimario(alinhamento: alinhamento) }
}

extension ButtonStyle where Self == BotaoCompacto {
    static var compacto: BotaoCompacto { BotaoCompacto() }
}

#Preview("normal") {
    VStack(spacing: 8) {
        Button("Revelar") {}.buttonStyle(.primario)
        Button("Abrir os campos") {}.buttonStyle(.primario(alinhamento: .leading))
        HStack { Button("Deixar como nota") {}.buttonStyle(.compacto) }
        Button("cobrar antes") {}
            .font(Tema.meta)
            .foregroundStyle(Tema.tintaSuave)
            .alvo()
            .buttonStyle(.discreto)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("desabilitado") {
    Button("Revelar") {}.buttonStyle(.primario).disabled(true)
        .padding()
        .background(Tema.fundo)
}

#Preview("pressionado") {
    Text("Revelar")
        .font(Tema.barra)
        .foregroundStyle(Tema.ambarTinta)
        .scaleEffect(Tema.pressao)
        .opacity(0.7)
        .padding()
        .background(Tema.fundo)
}

#Preview("AX5") {
    Button("Revelar") {}.buttonStyle(.primario)
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
