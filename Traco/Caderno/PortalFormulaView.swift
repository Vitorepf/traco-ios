import SwiftUI

struct PortalFormulaView: View {
    let fonte: String
    var edicao: Binding<String>?
    var foco: FocusState<Bool>.Binding?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: "fórmula")
            campo
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                .strokeBorder(Tema.linha, lineWidth: 1)
        }
        .accessibilityElement(children: edicao == nil ? .combine : .contain)
        .accessibilityLabel("Fórmula")
        .accessibilityIdentifier("portal-formula")
    }

    @ViewBuilder
    private var campo: some View {
        if let edicao {
            TextField("", text: edicao, axis: .vertical)
                .font(Tema.corpo.italic())
                .foregroundStyle(Tema.tinta)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                .modifier(FocoFormula(foco: foco))
                .accessibilityLabel("Fórmula")
                .accessibilityIdentifier("pagina-formula")
        } else {
            Text(fonte)
                .font(Tema.corpo.italic())
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
        }
    }
}

private struct FocoFormula: ViewModifier {
    var foco: FocusState<Bool>.Binding?

    func body(content: Content) -> some View {
        if let foco {
            content.focused(foco)
        } else {
            content
        }
    }
}
