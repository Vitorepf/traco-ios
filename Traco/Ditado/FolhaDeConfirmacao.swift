import SwiftUI

/// ADR 2026-09-06c — o idioma de confirmação do Traço, escrito uma vez.
///
/// Material de verdade + tinta rebaixada, um título, um corpo e no máximo duas
/// ações. `ConfirmacaoView` e `DitadoProprioView` desenhavam essa mesma casca
/// e os mesmos quatro auxiliares byte a byte (G3, M6): agora é um só.
///
/// **Mora aqui, e não em `Traco/Componentes/`, de propósito.** Aquela é a casa
/// certa, mas a volta 12 está lá dentro; a mudança de casa é da volta seguinte.
struct FolhaDeConfirmacao<Chave: Equatable, Conteudo: View>: View {
    /// Muda quando o conteúdo troca de assunto e a folha deve renascer com a
    /// escala. Quem quer troca SECA (o ditado) não passa nada.
    let refazerEm: Chave
    let aoEscapar: () -> Void
    @ViewBuilder let conteudo: Conteudo

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var materializado = false

    var body: some View {
        ZStack {
            // material de verdade, não tinta chapada: o fundo recua com profundidade
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Tema.fundo.opacity(0.55).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) { conteudo }
                    .padding(28)
                    .frame(maxWidth: 360, alignment: .leading)
            }
            // L5 do G3: com texto AX5 a folha rola, e o que rolava passava por
            // baixo da Ilha Dinâmica e do relógio sem nada entre os dois. A
            // linha some antes de chegar lá; em repouso o esmaecido cai dentro
            // do respiro de 28 pt e não se vê.
            .mask(LinearGradient(stops: [.init(color: .clear, location: 0),
                                         .init(color: .black, location: 0.03)],
                                 startPoint: .top, endPoint: .bottom))
            .scaleEffect(materializado || reduceMotion ? 1 : 1.04)
            .blur(radius: materializado || reduceMotion ? 0 : 6)
            .opacity(materializado || reduceMotion ? 1 : 0)
        }
        // escala e blur: sob reduzido o estado já nasce pronto (acima), nada anima
        .onAppear { materializar() }
        // `Seca` nunca muda de valor, então a folha do ditado não refaz nada:
        // a troca de estado dela é seca de propósito (ADR 06c).
        .onChange(of: refazerEm) { _, _ in
            guard !reduceMotion else { return }
            materializado = false
            materializar()
        }
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) { aoEscapar() }
    }

    private func materializar() {
        withAnimation(Tema.movimento(.escala, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
            materializado = true
        }
    }
}

/// A ausência de chave: dois `Seca` são sempre iguais, logo nada refaz a folha.
struct Seca: Equatable {}

extension FolhaDeConfirmacao where Chave == Seca {
    init(aoEscapar: @escaping () -> Void, @ViewBuilder conteudo: () -> Conteudo) {
        self.init(refazerEm: Seca(), aoEscapar: aoEscapar, conteudo: conteudo)
    }
}

/// As peças de dentro da folha. Estavam duplicadas nas duas telas; aqui a
/// tipografia, a cor e o alvo de 44 pt são uma decisão só.
enum Folha {
    @ViewBuilder
    static func titulo(_ t: String, id: String? = nil) -> some View {
        let base = Text(t)
            .font(Tema.confirmacaoTitulo)
            .foregroundStyle(Tema.tinta)
            .accessibilityAddTraits(.isHeader)
        if let id { base.accessibilityIdentifier(id) } else { base }
    }

    static func texto(_ t: String) -> some View {
        Text(t).font(Tema.confirmacaoCorpo).foregroundStyle(Tema.tintaSuave)
    }

    /// A linha miúda que diz o que ficou guardado — nunca a ação.
    static func meta(_ t: String) -> some View {
        Text(t).font(Tema.meta).foregroundStyle(Tema.tintaFraca)
    }

    static func botao(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.barra)
            .foregroundStyle(Tema.ambarTinta)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }

    static func botaoMudo(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.chrome)
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }

    static func botaoDestrutivo(_ t: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(t, action: acao)
            .font(Tema.chrome)
            .foregroundStyle(Tema.aviso)
            .frame(minHeight: Tema.alvo)
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier(id)
    }
}
