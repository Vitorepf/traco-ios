import SwiftUI

/// A linha que diz o que a sábia está fazendo — ou que não está. Uma frase em
/// `meta`, sem glifo, sem laço (ADR 05t): pensando e lendo em `tintaFraca`,
/// falha e falta de conta em `tintaSuave`, porque essas se leem com atenção.
/// O anúncio ao VoiceOver é da tela, que sabe QUANDO o estado mudou.
struct LinhaDeEstado: View {
    enum Estado { case pensando, lendo, falhou, semConta }

    let texto: String
    let estado: Estado

    init(_ texto: String, _ estado: Estado) {
        self.texto = texto
        self.estado = estado
    }

    var body: some View {
        Text(texto)
            .font(Tema.meta)
            .foregroundStyle(estado == .pensando || estado == .lendo ? Tema.tintaFraca : Tema.tintaSuave)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("pensando e lendo") {
    VStack(alignment: .leading, spacing: 8) {
        LinhaDeEstado("a sábia pensa…", .pensando)
        LinhaDeEstado("lendo…", .lendo)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("falhou e sem conta") {
    VStack(alignment: .leading, spacing: 8) {
        LinhaDeEstado("a sábia não respondeu.", .falhou)
        LinhaDeEstado("a sábia não está neste aparelho. Sem ela, a busca continua.", .semConta)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("AX5") {
    LinhaDeEstado("a sábia não respondeu.", .falhou)
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}

/// A espera que fala: **pensando, tempo e cancelar**, num lugar só (DIRETRIZ
/// §13 item 3 — *"espera calada é defeito de IA, não de design"*; §14 viu
/// nas Notas um "a sábia pensa…" parado com um "Fechar" e mais nada).
///
/// Não é componente novo: é a `LinhaDeEstado` acima com o relógio que a ADR
/// 09n desenhou no cartão da Página, tirado de lá para servir a toda rota que
/// raciocina. O movimento honesto é o SEGUNDO que anda: prova que o app está
/// vivo E diz quanto já se esperou. `TimelineView` acorda a linha uma vez por
/// segundo sem `@State`, sem timer e sem animação — Movimento Reduzido não
/// tem o que reduzir aqui. Desenho da volta TEMPO (`Vitorepf/tempo`), trazido
/// sem mudança de forma.
struct Espera: View {
    /// A frase da espera nas rotas da sábia. Minúscula, no presente: é uma
    /// linha de estado, não um título — e é uma só para as quatro (§14).
    static let aSabiaPensa = "a sábia pensa"

    /// A frase no presente, minúscula, sem reticências: "a sábia pensa".
    /// O tempo e as reticências são desta view.
    let frase: String
    let desde: Date
    /// O identificador vai na LINHA, aqui dentro. Posto de fora, ele desce
    /// sobre a subárvore inteira e engole o do botão.
    var identificador: String?
    /// Nil só onde a saída já existe fora.
    var cancelar: (() -> Void)?
    var rotuloDoCancelar = "Parar de esperar"

    /// Os primeiros segundos não levam número: até aí a espera é a de sempre e
    /// um contador só apressaria quem não estava com pressa. Do quarto segundo
    /// em diante o número aparece e anda — é o que separa "está pensando" de
    /// "travou". Fora do `body` para ter teste.
    static func linha(_ frase: String, desde: Date, agora: Date) -> String {
        let s = max(0, Int(agora.timeIntervalSince(desde)))
        return s < 4 ? "\(frase)…" : "\(frase) há \(s) s…"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimelineView(.periodic(from: desde, by: 1)) { agora in
                LinhaDeEstado(Self.linha(frase, desde: desde, agora: agora.date), .pensando)
            }
            .accessibilityIdentifier(identificador ?? "espera-pensando")
            if let cancelar {
                // A saída é discreta de propósito — o caminho principal é
                // ESPERAR, porque a resposta está a caminho (ADR 09n). Em
                // `meta`, como a linha a que pertence: em `barra` ela pesava
                // mais que a própria espera (von-restorff invertido). Alvo de
                // 44 pt continua, que é o que o dono sente (§12).
                Button(rotuloDoCancelar) { cancelar() }
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .alvo()
                    .buttonStyle(.discreto)
                    .accessibilityIdentifier("parar-de-esperar")
            }
        }
    }
}

/// Quem fala na conversa (REFERENCIA-HERMES §6). A forma distingue antes da
/// cor (§4): ponto para quem pergunta, retângulo para a sábia. Cor é
/// identidade (§10) e mais nada.
enum Autor {
    case voce, sabia

    var nome: String { self == .voce ? "VOCÊ" : "SÁBIA" }
    var cor: Color { self == .voce ? Tema.ambarTinta : Tema.sabia }
}

struct MarcaDeAutor: View {
    let autor: Autor

    var body: some View {
        Group {
            if autor == .voce {
                Circle().frame(width: 7, height: 7)
            } else {
                RoundedRectangle(cornerRadius: 3, style: .continuous).frame(width: 13, height: 9)
            }
        }
        .foregroundStyle(autor.cor)
        .frame(width: 13)
        .accessibilityHidden(true)
    }
}

/// A linha de autor: a marca e o NOME em versalete espaçado, na cor de quem
/// é. Não é caixa alta de rótulo de conteúdo (§5): nomeia QUEM, como o
/// cabeçalho de seção agrupa — é a única caixa alta da conversa.
struct LinhaDeAutor: View {
    let autor: Autor

    init(_ autor: Autor) { self.autor = autor }

    var body: some View {
        HStack(spacing: 8) {
            MarcaDeAutor(autor: autor)
            Text(autor.nome)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(autor.cor)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(autor == .voce ? "Você" : "A sábia")
        .accessibilityAddTraits(.isHeader)
    }
}

/// A espera como CÁPSULA COM TEMPO (REFERENCIA-HERMES §8): estreita, colada
/// acima do campo — a marca da sábia cintila, o que ela faz, e o tempo
/// decorrido à direita. Não toma a tela e não tem botão: parar é o botão do
/// campo, que muda com o estado (§9). O cintilar anda no mesmo segundo do
/// relógio; com Movimento Reduzido a marca fica acesa e só o número anda.
struct CapsulaDeEspera: View {
    let frase: String
    let desde: Date
    var identificador = "espera-pensando"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// "0:07", "4:01" — o relógio do Hermes. Fora do `body` para ter teste.
    static func tempo(desde: Date, agora: Date) -> String {
        let s = max(0, Int(agora.timeIntervalSince(desde)))
        return "\(s / 60):" + (s % 60 < 10 ? "0" : "") + "\(s % 60)"
    }

    var body: some View {
        TimelineView(.periodic(from: desde, by: 1)) { ctx in
            let s = max(0, Int(ctx.date.timeIntervalSince(desde)))
            HStack(spacing: 8) {
                MarcaDeAutor(autor: .sabia)
                    .opacity(reduceMotion || s.isMultiple(of: 2) ? 1 : 0.35)
                    .animation(reduceMotion ? nil : .easeInOut(duration: Tema.Duracao.relogio), value: s)
                Text(frase + "…")
                    .foregroundStyle(Tema.tintaSuave)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(Self.tempo(desde: desde, agora: ctx.date))
                    .monospacedDigit()
                    .foregroundStyle(Tema.tintaFraca)
            }
            .font(Tema.meta)
            .padding(.horizontal, 12)
            .frame(minHeight: 34)
            .background(Tema.superficieBaixa, in: Capsule())
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(Espera.linha(frase, desde: desde, agora: ctx.date))
            .accessibilityIdentifier(identificador)
        }
    }
}

#Preview("cápsula com tempo") {
    VStack(spacing: 12) {
        CapsulaDeEspera(frase: Espera.aSabiaPensa, desde: .now)
        CapsulaDeEspera(frase: Espera.aSabiaPensa, desde: .now.addingTimeInterval(-241))
        LinhaDeAutor(.voce)
        LinhaDeAutor(.sabia)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("espera com relógio e saída") {
    VStack(alignment: .leading, spacing: 12) {
        Espera(frase: "a sábia pensa", desde: .now)
        Espera(frase: "a sábia pensa", desde: .now.addingTimeInterval(-47), cancelar: {})
        Espera(frase: "a IA confere a sua tentativa", desde: .now.addingTimeInterval(-241), cancelar: {})
    }
    .padding()
    .background(Tema.fundo)
}
