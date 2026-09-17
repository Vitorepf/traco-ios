import SwiftUI
import UIKit

enum Tema {
    // MARK: - Os dois mundos (ADR 02h e 17c; hex em SISTEMA-CLARO.md e SISTEMA-ESCURO.md)
    //
    // Papel, não tela. A hierarquia vem de tipo, peso, tinta e espaço.
    //
    // A REGRA DA COR (Hermes §10, ADR 2026-09-10k). Cor só diz uma de duas
    // coisas, e nada mais:
    //
    //   IDENTIDADE — o que uma coisa É, reconhecido antes de ler.
    //     · o domínio de um compromisso: fundo pastel + tinta da mesma matiz
    //       (`CalendarioTema.fundo(de:)`/`tinta(de:)`);
    //     · o próprio Traço: o âmbar. Ele marca onde o traço do autor acontece
    //       — o cursor, o círculo de Escrever — e só ali. Fill, nunca texto.
    //
    //   ESTADO — o que está acontecendo agora.
    //     · carvão (`chipAtivo`): o ativo, o ligado, o escolhido — a cápsula
    //       da aba, o interruptor ligado, o dia selecionado, a data marcada;
    //     · âmbar: o AGORA do calendário (a linha e a hora que correm);
    //     · `aviso`: o que falhou ou o que destrói;
    //     · o azul de papel do calendário: a semana onde se está.
    //
    //   NADA MAIS. Rótulo, ação secundária, ícone de linha, glifo de ajuste e
    //   fundo de linha são TINTA. Ação se reconhece pela FORMA — o chevron, o
    //   peso, a linha que se toca —, nunca por pintar o texto de âmbar. Glifo
    //   distingue pela forma antes da cor (Hermes §4). Quem precisar de uma
    //   cor nova tem de dizer, aqui, se ela é identidade ou estado; se não for
    //   nenhuma das duas, é enfeite, e enfeite não entra.
    //
    // `ambarTinta` existe porque #D9A542 sobre o papel mede 2,0:1 — é o âmbar
    // que se lê onde a IDENTIDADE precisa de texto (a hora do agora). Não é
    // licença para pintar botão.
    // OS DOIS MUNDOS (ADR 2026-09-17c; hex e medidas em SISTEMA-ESCURO.md).
    // A 02h dizia "um mundo só, nunca dois", e o que ela proibia era o app
    // virar claro numa aba e escuro noutra — não o autor ESCOLHER onde mora.
    // A escolha é dele, uma vez, no Perfil (`Aparencia`), e vale para o app
    // inteiro: a lei de um mundo só por vez continua de pé.
    //
    // O claro é PAPEL: cinza quente e fosco, e o que flutua é mais claro que
    // ele. O escuro é GRAFITE: quase-preto frio, e o que flutua é mais claro
    // que ele também — porque a direção de "um degrau para fora do plano" é
    // sempre em direção à LUZ, e no papel a luz é o branco, no grafite é o
    // que sobra dela. É a única lei do claro que inverte; todas as outras
    // (um acento, tudo é cápsula, hairline em vez de linha, sombra só no que
    // flutua, tipo secundário cinza e não pequeno) ficam iguais.
    //
    // O acento de ESTADO troca de lado e continua sendo um só: no papel é o
    // carvão sobre branco, no grafite é o osso sobre preto — o mesmo objeto
    // de contraste máximo, a mesma tinta invertida (`sobreAtivo`). O âmbar
    // não muda de emprego em mundo nenhum: continua IDENTIDADE, fill, uma vez
    // por tela. A única diferença é que no grafite ele se lê sozinho (8,6:1),
    // e por isso `ambarTinta` — que existe porque #D9A542 mede 2,0:1 no papel
    // — é o próprio âmbar no escuro, sem a muleta.
    static let fundo = Color(claro: 0xF4F4F2, escuro: 0x0F0F12)            // papel · grafite
    static let superficie = Color(claro: 0xFFFFFF, escuro: 0x1C1C22)       // cartão
    static let superficieAlta = Color(claro: 0xFFFFFF, escuro: 0x1C1C22)   // o que flutua (com sombra)
    static let superficieBaixa = Color(claro: 0xEBEBEA, escuro: 0x17171C)  // névoa · bruma: campo, trilho
    static let chip = Color(claro: 0xE8E8E6, escuro: 0x212127)
    static let chipAtivo = Color(claro: 0x2C2C2E, escuro: 0xE6E6EA)        // carvão · osso
    /// A tinta que pousa SOBRE `chipAtivo` (e sobre `aviso`): o inverso do
    /// acento, nunca `.white` cravado. No papel o ativo é escuro e a tinta é
    /// branca (13,9:1); no grafite o ativo é claro e a tinta é quase-preta
    /// (15,0:1). Era `.white` em dez lugares — a aba acesa, o "Hoje", o dia
    /// escolhido, a cápsula cheia, o enviar do campo, o toast — e no escuro
    /// cada um deles seria branco sobre osso: invisível.
    static let sobreAtivo = Color(claro: 0xFFFFFF, escuro: 0x121216)
    static let tinta = Color(claro: 0x1C1C1E, escuro: 0xE9E9EC)            // 15,5:1 · 15,8:1
    /// 5,7:1 sobre o papel, 5,2:1 sobre o chip. No grafite, 7,2:1 e 6,0:1 —
    /// e ali os dois cinzas finalmente têm um degrau entre si (SISTEMA-ESCURO §3).
    static let tintaSuave = Color(claro: 0x5F5F64, escuro: 0x9E9EA6)
    /// Terceiro nível de tinta. Era #86868B (3,3:1 no papel, 2,95:1 no chip) e
    /// carregava TEXTO em 58 lugares — o trecho da busca, a contagem de
    /// resultados, o rótulo da aba inativa a 11pt. A ADR 02h promete ≥4,5:1
    /// para todo texto, e a varredura de 04/set mediu a promessa quebrada.
    /// #68686C mede 5,04:1 no papel, 4,65:1 no campo e 4,52:1 no chip.
    /// Custo assumido: ficou perto do `tintaSuave` — dois cinzas que quase se
    /// encostam. Um deles deve morrer (FILA); ler vem antes de escalonar.
    /// O #8E8E98 do grafite foi calibrado pelo MESMO pior fundo, o chip: 4,94:1
    /// ali, 5,9:1 no fundo, 5,6:1 na bruma.
    static let tintaFraca = Color(claro: 0x68686C, escuro: 0x8E8E98)
    /// Só para DESABILITADO real — nunca para texto que deve ser lido: 1,53:1
    /// no papel, 1,70:1 no grafite. Quem diz "desligado" é o fundo que sai.
    static let tintaMorta = Color(claro: 0xC7C7CC, escuro: 0x3A3A42)
    /// Hairline: ninguém vê a linha, vê a ordem.
    static let linha = Color(claro: 0x1C1C1E, escuro: 0xFFFFFF, opacity: 0.08, opacidadeEscura: 0.10)
    /// A ÚNICA cor da casa que atravessa os dois mundos igual: a assinatura
    /// não muda de tom porque o papel virou grafite. O par está escrito assim,
    /// e não como `Color(hex:)`, para dizer que o escuro foi pensado e não
    /// esquecido — e para o portão (`MundoEscuroTests`) medir os dois lados.
    static let ambar = Color(claro: 0xD9A542, escuro: 0xD9A542)
    static let ambarSuave = Color(hex: 0xD9A542).opacity(0.22)
    /// O âmbar que se lê: 5,8:1 sobre o papel.
    static let ambarTinta = Color(claro: 0x7A5A16, escuro: 0xD9A542)
    /// A cor da sábia (REFERENCIA-HERMES §6 e §10): IDENTIDADE, nunca enfeite —
    /// só a marca e o nome dela na conversa. 5,8:1 sobre o papel. Quem pergunta
    /// é o âmbar (`ambarTinta`): o mesmo do caret e do "?", o acento do app,
    /// como o azul do `USER` no Hermes.
    static let sabia = Color(claro: 0x1F6B5A, escuro: 0x46AE93)
    /// 5,3:1 sobre o papel, 5,8:1 sobre o grafite. Dívida conhecida: sobre o
    /// CHIP mede 4,49:1 no claro, um centésimo abaixo do piso da 02h — medida e
    /// congelada em `MundoEscuroTests`, não corrigida aqui.
    static let aviso = Color(claro: 0xB5432F, escuro: 0xE06A54)
    static let codigoFundo = Color(claro: 0xEBEBEA, escuro: 0x17171C)
    static let codigoGutter = Color(claro: 0xE4E4E2, escuro: 0x1C1C20)
    static let synChave = Color(claro: 0x7A4E10, escuro: 0xC0954E)
    static let synValor = Color(claro: 0x1F6B5A, escuro: 0x4FAE90)
    static let synNumero = Color(claro: 0x2F4F8A, escuro: 0x7E9CCE)
    static let synTipo = Color(claro: 0x5A3D7A, escuro: 0xA88CD0)
    static let synFuncao = Color(claro: 0x245A66, escuro: 0x6EA8B6)
    static let synPontuacao = Color(claro: 0x6E6E73, escuro: 0x8A8A92)
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
    /// 11 — o cabeçalho de seção, e SÓ ele (Hermes §5): versalete espaçado,
    /// cinza fraco, pequeno. Caixa alta agrupa; nunca nomeia conteúdo — o
    /// nome de um parágrafo, de uma coluna ou de uma etiqueta vai em frase
    /// normal. Mora em `CabecalhoDeSecao`, que carrega a contagem e o recolher.
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
    static let luzBorda = Color(claro: 0xFFFFFF, escuro: 0xFFFFFF, opacity: 0.6, opacidadeEscura: 0.12)
    /// Sombra com tinta, não preto: cinza-quente, só no que flutua.
    static let sombraContato = Color(claro: 0x1C1C1E, escuro: 0x000000, opacity: 0.10, opacidadeEscura: 0.50)
    static let sombraFlutuante = Color(claro: 0x1C1C1E, escuro: 0x000000, opacity: 0.08, opacidadeEscura: 0.45)
    /// O véu da folha que afunda na pilha (`Camadas`). No papel 28 % de preto
    /// já é profundidade; no grafite 28 % sobre #0F0F12 não move quase nada —
    /// a página de baixo tem de escurecer o dobro para ainda AFUNDAR.
    static let veu = Color(claro: 0x000000, escuro: 0x000000, opacity: 0.28, opacidadeEscura: 0.55)
    /// A sombra da folha do arquivo enquanto ela anda: cinza-quente no papel,
    /// preto fundo no grafite. Aplica-se com `.opacity(0)` para desligar.
    static let sombraCamada = Color(claro: 0x1C1C1E, escuro: 0x000000, opacity: 0.22, opacidadeEscura: 0.55)
    /// Sombra é cor, raio e deslocamento, sempre os três juntos (SISTEMA-CLARO
    /// §1.5: duas sombras, nenhuma dura). Aplica-se com `.sombra(_:)`.
    struct Sombra {
        let cor: Color
        let raio: CGFloat
        let y: CGFloat
        /// barra flutuante, toast, cartão da análise
        static let flutuante = Sombra(cor: sombraFlutuante, raio: 16, y: 6)
        /// o campo de prosa do calendário
        static let campo = Sombra(cor: Color(claro: 0x1C1C1E, escuro: 0x000000, opacity: 0.06, opacidadeEscura: 0.40), raio: 12, y: 4)
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

    /// UM token, DOIS mundos (ADR 2026-09-17c). A cor se resolve na hora de
    /// desenhar, pela aparência da janela — e é por isso que nenhuma das ~220
    /// telas do app precisou de um `if escuro`. Quem escolhe a aparência é
    /// `Aparencia`, na raiz; daqui para baixo só existe token.
    ///
    /// O par mora AQUI, na mesma linha, de propósito: um hex claro que muda
    /// sem o escuro ao lado é como a paleta se parte em duas ao longo do
    /// tempo. Componente continua sem citar hex nenhum (a regra do roteador).
    nonisolated init(claro: UInt32, escuro: UInt32, opacity: Double = 1, opacidadeEscura: Double? = nil) {
        let opacidadeNoEscuro = opacidadeEscura ?? opacity
        // só UInt32 e Double atravessam a fronteira: nada de SwiftUI dentro do
        // provedor, que o UIKit pode chamar fora do ator principal
        self.init(uiColor: UIColor { tracos in
            let escuroAgora = tracos.userInterfaceStyle == .dark
            let hex = escuroAgora ? escuro : claro
            return UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
                           green: CGFloat((hex >> 8) & 0xFF) / 255,
                           blue: CGFloat(hex & 0xFF) / 255,
                           alpha: CGFloat(escuroAgora ? opacidadeNoEscuro : opacity))
        })
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

/// Pressão numa LINHA de lista: a linha não encolhe (uma frase inteira a
/// afundar 6 % lê como botão de app, não como folha); ela se acende por
/// baixo, como a linha do Notes e do Mail, e apaga ao soltar. A luz sai um
/// pouco da coluna do texto para os lados, para não parecer um selo justo.
struct PressaoDeLinha: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: Tema.Raio.controle, style: .continuous)
                    .fill(Tema.linha)
                    .padding(.horizontal, -8)
                    .opacity(configuration.isPressed ? 1 : 0)
            }
            .animation(Tema.movimento(.opacidade, configuration.isPressed ? .easeOut(duration: Tema.Duracao.toque) : .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion), value: configuration.isPressed)
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
