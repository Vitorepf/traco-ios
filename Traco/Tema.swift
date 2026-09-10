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
    /// A cor da sábia (REFERENCIA-HERMES §6 e §10): IDENTIDADE, nunca enfeite —
    /// só a marca e o nome dela na conversa. 5,8:1 sobre o papel. Quem pergunta
    /// é o âmbar (`ambarTinta`): o mesmo do caret e do "?", o acento do app,
    /// como o azul do `USER` no Hermes.
    static let sabia = Color(hex: 0x1F6B5A)
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
    /// 12 — só FORA do app (ADR 05u): a faixa compacta da Ilha e o rodapé do
    /// widget não têm 15pt. Escala com o sistema como os outros degraus.
    static let miudo: Font = .caption
    /// 13 — o botão da Live Activity (cápsula de 38pt).
    static let acaoViva: Font = .footnote.weight(.semibold)

    // MARK: - Grade (um gutter, dois raios — nada mais)
    //
    // Auditoria: três margens (14/22/27) e quatro raios competiam; nenhuma borda
    // concordava com outra (critique-composition).
    static let raio: CGFloat = 12
    static let raioCartao: CGFloat = 12
    /// SISTEMA-CLARO §4, o mundo claro: controle 10, campo 14, cartão 18.
    /// `raio` (12) segue sendo o do caderno e das superfícies elevadas;
    /// juntar os dois vocabulários é trabalho de volta por tela, não desta.
    enum Raio {
        static let controle: CGFloat = 10
        static let campo: CGFloat = 14
        static let cartao: CGFloat = 18
    }
    /// Ritmo vertical: tudo múltiplo de 4. Dentro de seção 12, entre seções 32.
    static let entreItens: CGFloat = 12
    static let entreSecoes: CGFloat = 32
    static let alvo: CGFloat = 44
    /// SPEC §20: altura da barra inferior — o encaixe que mantém TODA tela acima dela.
    static let barraNav: CGFloat = 52
    static let margem: CGFloat = 20
    /// O TextEditor traz ~5pt de recuo interno: sem compensar, a linha editada
    /// nasce num degrau à direita do portal vizinho (medido: 26pt vs 21pt na
    /// mesma nota — law-of-continuity). O Recordar já usa margem − 5.
    static let sangriaEditor: CGFloat = 5
    static let pressao: CGFloat = 0.94
    /// A pressão do calendário: controles pequenos em trilho afundam menos.
    static let pressaoLeve: CGFloat = 0.96

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
    /// Sombra é cor, raio e deslocamento, sempre os três juntos (SISTEMA-CLARO
    /// §1.5: duas sombras, nenhuma dura). Aplica-se com `.sombra(_:)`.
    struct Sombra {
        let cor: Color
        let raio: CGFloat
        let y: CGFloat
        /// barra flutuante, toast, cartão da análise
        static let flutuante = Sombra(cor: sombraFlutuante, raio: 16, y: 6)
        /// o campo de prosa do calendário
        static let campo = Sombra(cor: Color(hex: 0x1C1C1E, opacity: 0.06), raio: 12, y: 4)
    }

    // MARK: - Duração e mola (ADR 2026-09-05v)
    //
    // A auditoria da volta 9 contou dezesseis durações e quatro molas para um
    // vocabulário de quatro verbos: entrar, sair, trocar, pressionar. Ficam
    // três durações e três molas; o que está fora tem nome e motivo.
    enum Duracao {
        /// fade, corte, chrome que acompanha o dedo; e o fade de Reduzir Movimento
        static let curta: Double = 0.15
        /// entra e sai de estado: toast, cartão, vazio, confirmação
        static let media: Double = 0.25
        /// o que tem massa: gaveta, forma que nasce
        static let longa: Double = 0.4
        // Fora do vocabulário, cada um com o seu motivo:
        /// o press: abaixo de curta de propósito, quase instantâneo; o soltar é `Mola.toque`
        static let toque: Double = 0.08
        /// o respiro entre os campos da forma que nasce (é delay, não duração)
        static let passo: Double = 0.05
        /// a página nova amanhece depois do fecho expressivo (dono, 01/set)
        static let fecho: Double = 0.9
        /// a barra do timer da expressiva anda um segundo real por segundo
        static let relogio: Double = 1.0
        /// a cena do fogo consumindo a folha (dono, 01/set); easeIn: a ignição é lenta
        static let queimaCena: Double = 3.0
    }

    enum Mola {
        /// o soltar do botão: volta com vida
        static let toque: Animation = .spring(response: 0.32, dampingFraction: 0.65)
        /// a camada do arquivo: pousa em vez de bater (cauda longa)
        static let camada: Animation = .spring(response: 0.55, dampingFraction: 0.82)
        /// troca de escala e de estado (SISTEMA-CLARO §5): massa e sem pressa
        static let escala: Animation = .spring(response: 0.55, dampingFraction: 0.86)
        /// a barra que recolhe com o teclado: segue a curva do teclado do sistema
        static let teclado: Animation = .interpolatingSpring(stiffness: 420, damping: 34)
    }

    // MARK: - Movimento reduzido (ADR 2026-09-05t, 05v; desambiguada pela 05y)
    //
    // Uma lei para o app inteiro, num lugar só. A view diz qual seria o
    // movimento normal e de que CLASSE ele é; quem decide sob "Reduzir
    // movimento" é `movimento(_:_:reduzido:)`:
    //   deslocamento → CORTA. Sem quadro intermediário nenhum.
    //   escala       → corta: o estado vira sem quadro intermediário
    //   opacidade    → mantém: opacidade não enjoa
    //   laço         → para: o que repete sem fim fica no estado final
    //
    // Ou seja: sob reduzido só a OPACIDADE anima. A 05v dizia "deslocamento →
    // fade curta OU corte", e a implementação escolhia a fade — que é uma
    // DURAÇÃO menor, não um corte: a geometria continuava a ser interpolada,
    // só que em 0,15 s. Quando os filhos do container são texto legível, essa
    // interpolação é um cross-dissolve de duas geometrias — a classe de defeito
    // que voltou cinco vezes na volta 12, a última no toque em "Abrir os
    // campos" (~370 ms COM Reduzir Movimento, contra ~215 ms sem: mais lento
    // com RM do que sem, o contrário do que RM promete). O "ou" era a
    // ambiguidade; a 05y escolhe o corte, para o app inteiro.
    //
    // `laco` não tem consumidor no app desde a volta 12: o ponto pulsante do
    // "lendo…" saiu e a `Duracao.pulso` que o media foi apagada com ele. A
    // classe fica porque é a LEI de quem tentar repetir sem fim outra vez, e
    // `TemaTests.lacoPara` a mantém honesta.
    enum Movimento { case deslocamento, escala, opacidade, laco }

    static func movimento(_ classe: Movimento, _ normal: Animation, reduzido: Bool) -> Animation? {
        guard reduzido else { return normal }
        return classe == .opacidade ? normal : nil
    }

    /// Deslocamento, o caso mais comum — o nome da V8, para quem já chama.
    /// Devolve `nil` sob reduzido, como toda a classe: corte, não fade.
    static func animacao(_ normal: Animation, reduzido: Bool) -> Animation? {
        movimento(.deslocamento, normal, reduzido: reduzido)
    }

    /// Toda transição custom do app carrega opacidade; sob reduzido só ela fica.
    static func transicao(_ normal: AnyTransition, reduzido: Bool) -> AnyTransition {
        reduzido ? .opacity : normal
    }

    /// O mesmo corte, com o nome à vista de quem move com o DEDO (Camadas) ou
    /// com o RELÓGIO (timer): ali um fade sobre a posição cortada pisca, porque
    /// o estado vira um quadro depois. Desde a 05y é a mesma lei de
    /// `.deslocamento` — o nome fica porque diz a intenção no ponto de uso.
    static func corte(_ normal: Animation, reduzido: Bool) -> Animation? {
        movimento(.deslocamento, normal, reduzido: reduzido)
    }

    static func gaveta(reduzido: Bool) -> Animation? {
        animacao(.timingCurve(0.32, 0.72, 0, 1, duration: Duracao.longa), reduzido: reduzido)
    }

    /// A curva de pressão da casa: press quase instantâneo, release com vida.
    /// Pressão é escala: sob reduzido nada anima, o estado vira.
    static func pressaoAnim(_ isPressed: Bool, reduzido: Bool = false) -> Animation? {
        movimento(.escala, isPressed ? .easeOut(duration: Duracao.toque) : Mola.toque, reduzido: reduzido)
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // o rótulo inteiro recebe o dedo, não só o glifo
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            // só escala: baixar a opacidade sobre papel lê como piscar
            // press quase instantâneo; o soltar volta com vida (spring leve)
            .animation(Tema.pressaoAnim(configuration.isPressed, reduzido: reduceMotion), value: configuration.isPressed)
    }
}

extension View {
    func sombra(_ s: Tema.Sombra) -> some View {
        shadow(color: s.cor, radius: s.raio, y: s.y)
    }

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
