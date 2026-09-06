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
