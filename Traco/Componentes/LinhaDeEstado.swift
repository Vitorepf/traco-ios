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

#Preview("espera com relógio e saída") {
    VStack(alignment: .leading, spacing: 12) {
        Espera(frase: "a sábia pensa", desde: .now)
        Espera(frase: "a sábia pensa", desde: .now.addingTimeInterval(-47), cancelar: {})
        Espera(frase: "a IA confere a sua tentativa", desde: .now.addingTimeInterval(-241), cancelar: {})
    }
    .padding()
    .background(Tema.fundo)
}
