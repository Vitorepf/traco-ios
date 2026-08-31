import SwiftUI

struct CamposFormaView: View {
    let gesto: Gesto
    @Binding var campos: [String: String]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var nascida = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(gesto.nome.uppercased())
                .font(Tema.label)
                .tracking(1.3)
                .foregroundStyle(Tema.tintaSuave)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("forma-\(gesto.rawValue)")
            ForEach(gesto.campos) { campo in
                LinhaCampo(id: campo.id, rotulo: campo.rotulo, texto: valor(campo.id))
            }
        }
        .padding(.horizontal, Tema.margem)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Tema.superficie.opacity(0.55), in: RoundedRectangle(cornerRadius: Tema.raio))
        .padding(.horizontal, 10)
        .blur(radius: nascida || reduceMotion ? 0 : 3)
        .opacity(nascida || reduceMotion ? 1 : 0.55)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.18) : .easeOut(duration: Tema.formaNasce)) {
                nascida = true
            }
        }
        .accessibilityHint("Campos vazios da forma. A frase continua sendo sua.")
    }

    private func valor(_ id: String) -> Binding<String> {
        Binding(
            get: { campos[id, default: ""] },
            set: { campos[id] = $0 }
        )
    }
}

private struct LinhaCampo: View {
    let id: String
    let rotulo: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(rotulo.uppercased())
                .font(Tema.label)
                .tracking(1.0)
                .foregroundStyle(Tema.tintaFraca)
            TextField("", text: $texto, axis: .vertical)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .lineLimit(1...6)
                .frame(minHeight: Tema.alvo)
                .accessibilityLabel(rotulo)
                .accessibilityIdentifier("campo-\(id)")
            Rectangle()
                .fill(Tema.linha)
                .frame(height: 0.5)
        }
    }
}
