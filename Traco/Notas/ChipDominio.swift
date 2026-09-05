import SwiftUI

/// ADR 05d — o chip do domínio abre o menu: os sete e "Sem domínio"; a
/// escolha trava a nota. Nada destrói num toque. "Devolver ao app" destrava
/// e a IA do aparelho volta a decidir.
struct ChipDominio: View {
    let atual: Dominio?
    var travado: Bool = false
    var aoEscolher: (Dominio?) -> Void
    var aoDevolver: (() -> Void)? = nil

    var body: some View {
        Menu {
            ForEach(Dominio.allCases) { d in
                Button {
                    aoEscolher(d)
                } label: {
                    if d == atual { Label(d.nome, systemImage: "checkmark") } else { Text(d.nome) }
                }
            }
            Divider()
            Button("Sem domínio") { aoEscolher(nil) }
            if travado, let aoDevolver {
                Button("Devolver ao app") { aoDevolver() }
            }
        } label: {
            // o rótulo É a cápsula: o iOS realça o retângulo do rótulo ao abrir
            // o menu, e um frame de 44 pt em volta virava uma caixa cinza
            // (visto pelo dono, 05/set). O alvo de 44 pt fica no Menu.
            Text((atual?.nome ?? "domínio").uppercased())
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaSuave)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Tema.chip, in: Capsule())
        }
        .menuStyle(.button)
        .buttonStyle(PressaoDiscreta())
        .alvo()
        .accessibilityLabel(atual.map { "Domínio: \($0.nome)" } ?? "Sem domínio")
        .accessibilityHint("Abre o menu para trocar ou tirar o domínio")
        .accessibilityIdentifier("chip-dominio")
    }
}
