import SwiftUI

/// Tela única da chave (SPEC §5): o custo dito com todas as letras.
struct ChaveView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var valor = ""
    @State private var temChave = Chave.existe
    @State private var resultadoTeste: String?
    @State private var testando = false

    var body: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text("Análise com Grok")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                Text("Com uma chave da API da xAI, o Grok vira o motor da análise. Sem chave, o Traço continua 100% local e gratuito.")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                Text("A API cobra por token, na SUA conta do console da xAI (console.x.ai). SuperGrok não serve aqui — são medidores separados. A chave fica no Keychain do aparelho; notas trancadas nunca vão à rede.")
                    .font(.subheadline)
                    .foregroundStyle(Tema.tintaSuave)

                SecureField(
                    "",
                    text: $valor,
                    prompt: Text("xai-…").foregroundStyle(Tema.tintaFraca)
                )
                .font(Tema.corpo.monospaced())
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityLabel("Chave da API da xAI")

                Button(temChave && valor.isEmpty ? "Chave guardada" : "Guardar no Keychain") {
                    Chave.salvar(valor)
                    temChave = Chave.existe
                    valor = ""
                    dismiss()
                }
                .font(Tema.chrome.weight(.semibold))
                .foregroundStyle(valor.isEmpty ? Tema.tintaFraca : Tema.ambar)
                .disabled(valor.trimmingCharacters(in: .whitespaces).isEmpty)
                .frame(minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())

                if temChave {
                    Button(testando ? "testando…" : (resultadoTeste ?? "testar a chave")) {
                        testando = true
                        Task {
                            resultadoTeste = await Chave.testar()
                            testando = false
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                    .disabled(testando)
                    Button("Remover a chave — voltar ao motor local") {
                        Chave.apagar()
                        temChave = false
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                }
                Spacer()
            }
            .padding(28)
        }
        .presentationDetents([.medium])
        .presentationBackground(Tema.fundo)
    }
}
