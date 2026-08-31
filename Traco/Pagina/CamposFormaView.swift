import SwiftUI

/// Os campos da forma, dentro da folha.
///
/// Auditoria 31/ago: havia um CARTÃO dentro da folha — caixa dentro de caixa.
/// O nome da forma vestia a mesma roupa dos cinco rótulos e lia como um sexto
/// campo (law-of-similarity), e o cartão estourava a altura da folha, cortando
/// o último campo. A folha JÁ é a superfície elevada: aqui dentro só existem
/// linhas, sem moldura.
struct CamposFormaView: View {
    let gesto: Gesto
    @Binding var campos: [String: String]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var nascida = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(gesto.campos.enumerated()), id: \.element.id) { indice, campo in
                LinhaCampo(id: campo.id, rotulo: campo.rotulo, texto: valor(campo.id))
                    // a forma chega como quem entra: campo a campo, um respiro
                    // entre eles (ancorado em `nascida`, que muda DEPOIS do
                    // onAppear — dispara garantido)
                    .opacity(nascida || reduceMotion ? 1 : 0)
                    .offset(y: nascida || reduceMotion ? 0 : 6)
                    .animation(.easeOut(duration: 0.35).delay(min(Double(indice), 5) * 0.05), value: nascida)
                if indice < gesto.campos.count - 1 {
                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                }
            }
        }
        .padding(.horizontal, Tema.margem)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.18) : .easeOut(duration: Tema.formaNasce)) {
                nascida = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("forma-\(gesto.rawValue)")
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
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
            TextField("", text: $texto, axis: .vertical)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .lineLimit(1...5)
                .accessibilityLabel(rotulo)
                .accessibilityIdentifier("campo-\(id)")
        }
        .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
        .padding(.vertical, 14)
    }
}
