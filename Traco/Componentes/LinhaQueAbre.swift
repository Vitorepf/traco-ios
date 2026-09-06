import SwiftUI

/// A linha que abre algo: um menu (seta dupla) ou um bloco abaixo (seta que
/// gira). Título à esquerda, valor em `tintaSuave` à direita, alvo 44. O que
/// abre embaixo anima a ALTURA, não a opacidade (§21) — isso é do pai, com
/// `Tema.animacao`.
struct LinhaQueAbre<Icone: View>: View {
    enum Abre { case menu, abaixo(aberta: Bool) }

    let titulo: String
    var valor: String?
    var abre: Abre = .menu
    @ViewBuilder var icone: () -> Icone

    init(_ titulo: String, valor: String? = nil, abre: Abre = .menu,
         @ViewBuilder icone: @escaping () -> Icone) {
        self.titulo = titulo
        self.valor = valor
        self.abre = abre
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
            seta
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Tema.tintaSuave)
        }
        .alvo()
    }

    @ViewBuilder private var seta: some View {
        switch abre {
        case .menu:
            Image(systemName: "chevron.up.chevron.down")
        case .abaixo(let aberta):
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(aberta ? 90 : 0))
        }
    }
}

extension LinhaQueAbre where Icone == EmptyView {
    init(_ titulo: String, valor: String? = nil, abre: Abre = .menu) {
        self.init(titulo, valor: valor, abre: abre) { EmptyView() }
    }
}

#Preview("menu e fechada") {
    VStack(spacing: 0) {
        LinhaQueAbre("Avisar", valor: "30 min antes") {
            Image(systemName: "bell.fill").font(.footnote)
        }
        Rectangle().fill(Tema.linha).frame(height: 1)
        LinhaQueAbre("Versões", valor: "3", abre: .abaixo(aberta: false))
    }
    .font(.callout)
    .padding(.horizontal, 14)
    .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
    .padding()
    .background(Tema.fundo)
}

#Preview("aberta") {
    LinhaQueAbre("Versões", valor: "3", abre: .abaixo(aberta: true))
        .font(.callout)
        .padding(.horizontal, 14)
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
