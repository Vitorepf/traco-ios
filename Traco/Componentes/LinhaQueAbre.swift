import SwiftUI

/// A linha que abre um menu (seta dupla). Título à esquerda, valor em
/// `tintaSuave` à direita, alvo 44. A variante que abre um bloco abaixo (seta
/// que gira, altura animada pelo pai, §21) entra na V12 com as Versões, que é
/// quem a chama; sem chamador ela não fica aqui.
struct LinhaQueAbre<Icone: View>: View {
    let titulo: String
    var valor: String?
    @ViewBuilder var icone: () -> Icone

    init(_ titulo: String, valor: String? = nil,
         @ViewBuilder icone: @escaping () -> Icone) {
        self.titulo = titulo
        self.valor = valor
        self.icone = icone
    }

    var body: some View {
        HStack(spacing: 8) {
            icone()
            Text(titulo)
            Spacer()
            if let valor {
                Text(valor).foregroundStyle(Tema.tintaSuave)
            }
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Tema.tintaSuave)
        }
        .alvo()
    }
}

extension LinhaQueAbre where Icone == EmptyView {
    init(_ titulo: String, valor: String? = nil) {
        self.init(titulo, valor: valor) { EmptyView() }
    }
}

#Preview("menu") {
    VStack(spacing: 0) {
        LinhaQueAbre("Avisar", valor: "30 min antes") {
            Image(systemName: "bell.fill").font(.footnote)
        }
        Rectangle().fill(Tema.linha).frame(height: 1)
        LinhaQueAbre("Domínio", valor: "Saúde")
    }
    .font(.callout)
    .padding(.horizontal, 14)
    .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
    .padding()
    .background(Tema.fundo)
}

#Preview("AX5") {
    LinhaQueAbre("Avisar", valor: "30 min antes")
        .font(.callout)
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
