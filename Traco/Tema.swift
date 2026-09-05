import SwiftUI

enum Tema {
    // MARK: - O mundo claro (ADR 2026-09-02h; hex e medidas em SISTEMA-CLARO.md)
    //
    // Papel, não tela. Um acento de estado, o preto (carvão). O âmbar é a
    // assinatura de AÇÃO e vive como fill (cursor, Nova, agora); como texto
    // usa `ambarTinta`, porque #D9A542 sobre o papel mede 2,0:1.
    static let fundo = Color(hex: 0xF4F4F2)            // papel
    static let superficie = Color(hex: 0xFFFFFF)       // cartão
    static let superficieAlta = Color(hex: 0xFFFFFF)   // o que flutua (com sombra)
    static let superficieBaixa = Color(hex: 0xEBEBEA)  // névoa: campo, trilho
    static let chip = Color(hex: 0xE8E8E6)
    static let chipAtivo = Color(hex: 0x2C2C2E)        // carvão
    static let tinta = Color(hex: 0x1C1C1E)            // 15,5:1
    /// 5,7:1 sobre o papel, 5,2:1 sobre o chip.
    static let tintaSuave = Color(hex: 0x5F5F64)
    /// Terceiro nível de tinta. Era #86868B (3,3:1 no papel, 2,95:1 no chip) e
    /// carregava TEXTO em 58 lugares — o trecho da busca, a contagem de
    /// resultados, o rótulo da aba inativa a 11pt. A ADR 02h promete ≥4,5:1
    /// para todo texto, e a varredura de 04/set mediu a promessa quebrada.
    /// #68686C mede 5,04:1 no papel, 4,65:1 no campo e 4,52:1 no chip.
    /// Custo assumido: ficou perto do `tintaSuave` — dois cinzas que quase se
    /// encostam. Um deles deve morrer (FILA); ler vem antes de escalonar.
    static let tintaFraca = Color(hex: 0x68686C)
    /// Só para DESABILITADO real — nunca para texto que deve ser lido.
    static let tintaMorta = Color(hex: 0xC7C7CC)
    /// Hairline: ninguém vê a linha, vê a ordem.
    static let linha = Color(hex: 0x1C1C1E, opacity: 0.08)
    static let ambar = Color(hex: 0xD9A542)
    static let ambarSuave = Color(hex: 0xD9A542).opacity(0.22)
    /// O âmbar que se lê: 5,8:1 sobre o papel.
    static let ambarTinta = Color(hex: 0x7A5A16)
    /// 5,3:1 sobre o papel.
    static let aviso = Color(hex: 0xB5432F)
    static let codigoFundo = Color(hex: 0xEBEBEA)
    static let codigoGutter = Color(hex: 0xE4E4E2)
    static let synChave = Color(hex: 0x7A4E10)
    static let synValor = Color(hex: 0x1F6B5A)
    static let synNumero = Color(hex: 0x2F4F8A)
    static let synTipo = Color(hex: 0x5A3D7A)
    static let synFuncao = Color(hex: 0x245A66)
    static let synPontuacao = Color(hex: 0x6E6E73)
    static let synComentario = tintaFraca
    static let synTexto = tinta
    // §22 fechado (02/set): tudo por estilo de texto, escalando com o
    // tamanho do sistema. Os pontos ao lado são os do tamanho padrão.
    static let mono: Font = .system(.body, design: .monospaced)          // 17
    static let tituloNota: Font = .title.weight(.semibold)               // 28
    static let secaoNota: Font = .title2.weight(.semibold)               // 22

    // MARK: - Escala tipográfica (5 degraus, razão ≥1.25)
    //
    // Auditoria de 31/ago: 19–20pt fazia QUATRO papéis (título de linha, corpo,
    // botão e ação primária) — sem degrau, a hierarquia não lê
    // (critique-visual-hierarchy). Cada papel agora tem um degrau, e só um.
    // Num app de escrita o CORPO pode ser o maior depois do título: o texto do
    // autor é o assunto.
    /// 28 — título de tela. Tracking negativo: tamanho grande junta as letras.
    static let tituloTela: Font = .title.weight(.bold)
    static let trackingTitulo: CGFloat = -0.5
    /// 20 — o corpo, e a voz do autor.
    static let corpo: Font = .title3
    /// 17 — título de linha, chrome, ações.
    static let chrome: Font = .body
    static let barra: Font = .body.weight(.semibold)
    /// 15 — metadado, legenda, apoio.
    static let meta: Font = .subheadline
    /// 11 — rótulo de seção, sempre em caixa alta com tracking positivo.
    static let label: Font = .caption2.weight(.semibold)
    static let trackingLabel: CGFloat = 1.2
    static let confirmacaoTitulo: Font = .title.weight(.semibold)
    static let confirmacaoCorpo: Font = .title3

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
    /// A cena inteira do fogo consumindo a folha (pedido do dono, 01/set).
    /// easeIn: a ignição é lenta, o fogo acelera.
    static let queimaCena: Double = 3.0
    static let margem: CGFloat = 20
    /// O TextEditor traz ~5pt de recuo interno: sem compensar, a linha editada
    /// nasce num degrau à direita do portal vizinho (medido: 26pt vs 21pt na
    /// mesma nota — law-of-continuity). O Recordar já usa margem − 5.
    static let sangriaEditor: CGFloat = 5
    static let pressao: CGFloat = 0.94

    // MARK: - Material de superfície elevada
    //
    // Auditoria: sobre preto, um retângulo mais claro SEM borda lê como buraco,
    // não como objeto acima do plano (law-of-figure-ground). O que falta é o
    // fio de luz no topo — a borda onde a luz bate — mais a sombra de contato.
    // É o detalhe que Linear, Craft e Things têm e que ninguém sabe nomear.
    static let luzBorda = Color.white.opacity(0.6)
    /// Sombra com tinta, não preto: cinza-quente, só no que flutua.
    static let sombraContato = Color(hex: 0x1C1C1E, opacity: 0.10)
    static let sombraFlutuante = Color(hex: 0x1C1C1E, opacity: 0.08)

    static let formaNasce: Double = 0.48
    static let cartaoEntra: Double = 0.26
    /// Saída existe: o cartão sumia em ZERO quadros e lia como erro de render.
    /// Mais rápida que a entrada — o autor já decidiu.
    static let cartaoSai: Double = 0.18
    static let confirmacaoEntra: Double = 0.22
    static let push: Double = 0.40

    // MARK: - Movimento reduzido (ADR 2026-09-05t)
    //
    // Uma lei para o app inteiro: com "Reduzir movimento" ligado, nada
    // desliza nem cresce — o que entra, entra por opacidade curta ou em corte
    // seco. Toda animação e transição custom passa por aqui; a view só diz
    // qual seria o movimento normal.
    static let fadeReduzido: Animation = .easeOut(duration: 0.15)

    static func animacao(_ normal: Animation, reduzido: Bool) -> Animation {
        reduzido ? fadeReduzido : normal
    }

    static func transicao(_ normal: AnyTransition, reduzido: Bool) -> AnyTransition {
        reduzido ? .opacity : normal
    }

    static func gaveta(reduzido: Bool) -> Animation {
        animacao(.timingCurve(0.32, 0.72, 0, 1, duration: push), reduzido: reduzido)
    }

    /// A curva de pressão da casa: press quase instantâneo, release com vida.
    static func pressaoAnim(_ isPressed: Bool) -> Animation {
        isPressed
            ? .easeOut(duration: 0.08)
            : .spring(response: 0.32, dampingFraction: 0.65)
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
            // o rótulo inteiro recebe o dedo, não só o glifo
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            // só escala: baixar a opacidade sobre papel lê como piscar
            // press quase instantâneo; o soltar volta com vida (spring leve)
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
    }
}

extension View {
    /// SISTEMA-CLARO: "36 é o desenho, 44 é o alvo". Um `.frame(minHeight: 44)`
    /// por fora do Button só RESERVA espaço — o dedo e o VoiceOver medem o
    /// `contentShape`. A revisão da volta 8 mediu: "Notas" 45×20 com frame de
    /// 44 sem contentShape; "Como contexto" 44×44 com os dois. Este é o alvo
    /// de verdade, e a `folga` dá o alvo a quem vive apertado (chips da régua,
    /// pílulas de 38 na barra, linhas de 24 nas Notas) sem mover um pixel: o
    /// alvo cresce para os lados e devolve o espaço ao layout.
    func alvo(folgaH: CGFloat = 0, folgaV: CGFloat = 0) -> some View {
        padding(.horizontal, folgaH)
            .padding(.vertical, folgaV)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
            .padding(.horizontal, -folgaH)
            .padding(.vertical, -folgaV)
    }
}
