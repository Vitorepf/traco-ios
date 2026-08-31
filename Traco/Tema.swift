import SwiftUI

enum Tema {
    static let fundo = Color(hex: 0x0B0B0D)
    static let superficie = Color(hex: 0x161619)
    static let superficieAlta = Color(hex: 0x1E1E22)
    static let tinta = Color(hex: 0xECECEA)
    static let tintaSuave = Color(hex: 0x9A9A96)
    /// AA de verdade: o antigo #6B6B70 media 3,41–3,71:1 e reprovava em todo
    /// rótulo pequeno (better-accessibility). Este mede 5,26–5,72:1.
    static let tintaFraca = Color(hex: 0x8A8A8F)
    /// Só para DESABILITADO real — nunca para texto que deve ser lido.
    static let tintaMorta = Color(hex: 0x6B6B70)
    static let linha = Color(hex: 0x26262A)
    static let ambar = Color(hex: 0xD9A542)
    static let ambarSuave = Color(hex: 0xD9A542).opacity(0.14)
    /// Media 4,09:1 sobre #1E1E22 e reprovava AA no rótulo em versalete.
    /// Este mede 6,24:1 — um vermelho só, sem versão apagada.
    static let aviso = Color(hex: 0xE8836A)
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
    static let mono: Font = .system(size: 17, design: .monospaced)
    static let tituloNota: Font = .system(size: 28, weight: .semibold)
    static let secaoNota: Font = .system(size: 22, weight: .semibold)

    // MARK: - Escala tipográfica (5 degraus, razão ≥1.25)
    //
    // Auditoria de 31/ago: 19–20pt fazia QUATRO papéis (título de linha, corpo,
    // botão e ação primária) — sem degrau, a hierarquia não lê
    // (critique-visual-hierarchy). Cada papel agora tem um degrau, e só um.
    // Num app de escrita o CORPO pode ser o maior depois do título: o texto do
    // autor é o assunto.
    /// 28 — título de tela. Tracking negativo: tamanho grande junta as letras.
    static let tituloTela: Font = .system(size: 28, weight: .bold)
    static let trackingTitulo: CGFloat = -0.5
    /// 20 — o corpo, e a voz do autor.
    static let corpo: Font = .system(size: 20)
    /// 17 — título de linha, chrome, ações.
    static let chrome: Font = .system(size: 17)
    static let barra: Font = .system(size: 17, weight: .semibold)
    /// 15 — metadado, legenda, apoio.
    static let meta: Font = .system(size: 15)
    /// 11 — rótulo de seção, sempre em caixa alta com tracking positivo.
    static let label: Font = .system(size: 11, weight: .semibold)
    static let trackingLabel: CGFloat = 1.2
    static let confirmacaoTitulo: Font = .system(size: 28, weight: .semibold)
    static let confirmacaoCorpo: Font = .system(size: 20)

    // MARK: - Grade (um gutter, dois raios — nada mais)
    //
    // Auditoria: três margens (14/22/27) e quatro raios competiam; nenhuma borda
    // concordava com outra (critique-composition).
    static let raio: CGFloat = 12
    static let raioCartao: CGFloat = 12
    /// Ritmo vertical: tudo múltiplo de 4. Dentro de seção 12, entre seções 32.
    static let entreItens: CGFloat = 12
    static let entreSecoes: CGFloat = 32
    static let alvo: CGFloat = 44
    /// SPEC §20: altura da barra inferior — o encaixe que mantém TODA tela acima dela.
    static let barraNav: CGFloat = 52
    /// A queima acontece em cena: rara, e por isso pode ter peso (SPEC §8).
    static let queima: Double = 0.55
    static let margem: CGFloat = 20
    static let pressao: CGFloat = 0.94

    // MARK: - Material de superfície elevada
    //
    // Auditoria: sobre preto, um retângulo mais claro SEM borda lê como buraco,
    // não como objeto acima do plano (law-of-figure-ground). O que falta é o
    // fio de luz no topo — a borda onde a luz bate — mais a sombra de contato.
    // É o detalhe que Linear, Craft e Things têm e que ninguém sabe nomear.
    static let luzBorda = Color.white.opacity(0.07)
    static let sombraContato = Color.black.opacity(0.55)

    static let formaNasce: Double = 0.48
    static let cartaoEntra: Double = 0.26
    /// Saída existe: o cartão sumia em ZERO quadros e lia como erro de render.
    /// Mais rápida que a entrada — o autor já decidiu.
    static let cartaoSai: Double = 0.18
    static let confirmacaoEntra: Double = 0.22
    static let push: Double = 0.40

    static func gaveta(reduzido: Bool) -> Animation {
        reduzido
            ? .easeOut(duration: 0.18)
            : .timingCurve(0.32, 0.72, 0, 1, duration: push)
    }

    /// A curva de pressão da casa: press quase instantâneo, release com vida.
    static func pressaoAnim(_ isPressed: Bool) -> Animation {
        isPressed
            ? .easeOut(duration: 0.08)
            : .spring(response: 0.32, dampingFraction: 0.65)
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
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
    }
}
