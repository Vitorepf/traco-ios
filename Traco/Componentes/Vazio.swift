import SwiftUI

/// O vazio desenhado (SISTEMA-CLARO §7.6): uma frase em `corpo`, no eixo em
/// que o conteúdo nasceria, e a saída do buraco em que o autor caiu — nunca
/// um glifo centralizado nem uma desculpa. Cinco frases e três layouts viram
/// este.
struct Vazio: View {
    struct Acao {
        let titulo: String
        var id: String?
        let fazer: () -> Void

        init(_ titulo: String, id: String? = nil, fazer: @escaping () -> Void) {
            self.titulo = titulo
            self.id = id
            self.fazer = fazer
        }
    }

    let frase: String
    var acao: Acao?

    var body: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            Text(frase)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tintaSuave)
            if let acao {
                Button(acao.titulo, action: acao.fazer)
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.ambarTinta)
                    .alvo()
                    .buttonStyle(.discreto)
                    .accessibilityIdentifier(acao.id ?? "")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Tema.margem)
        .padding(.top, 12)
    }
}

#Preview("com saída") {
    Vazio(frase: "nada aqui ainda.", acao: .init("escrever na página") {})
        .background(Tema.fundo)
}

#Preview("só a frase") {
    Vazio(frase: "nenhuma trancada.")
        .background(Tema.fundo)
}

#Preview("AX5") {
    Vazio(frase: "nenhuma nota com “casa”.", acao: .init("ver todas as notas") {})
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
