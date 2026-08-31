import SwiftUI

/// Meu perfil (SPEC §18): conta e ajustes num lugar só.
/// Não existe chave de API nem cobrança por token — a análise com Grok anda
/// pela ASSINATURA do autor (ADR 2026-08-31k).
struct PerfilView: View {
    var sessao: Sessao
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var abrir

    @State private var ligada = ContaGrok.ligada
    @State private var estado: String?
    @State private var codigo: ContaGrok.Codigo?
    @State private var entrando = false
    @State private var tarefa: Task<Void, Never>?

    var body: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Meu perfil")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Tema.tinta)
                        .accessibilityAddTraits(.isHeader)

                    conta
                    ajustes
                    Spacer(minLength: 8)
                }
                .padding(28)
            }
        }
        .presentationDetents([.large])
        .presentationBackground(Tema.fundo)
        .onDisappear { tarefa?.cancel() }
        .task { estado = await ContaGrok.estado() }
    }

    // MARK: - Conta

    private var conta: some View {
        VStack(alignment: .leading, spacing: 12) {
            rotulo("CONTA")
            Text("Grok")
                .font(Tema.corpo.weight(.medium))
                .foregroundStyle(Tema.tinta)
            Text(estado ?? "verificando…")
                .font(.subheadline)
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("estado-conta")

            if let codigo {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aprove no navegador com este código:")
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaSuave)
                    Text(codigo.userCode)
                        .font(.title.monospaced().weight(.semibold))
                        .foregroundStyle(Tema.ambar)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("codigo-dispositivo")
                    Button("Abrir a página de aprovação") { abrir(codigo.url) }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambar)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                }
                .padding(14)
                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
            }

            if ligada {
                Button("Sair da conta — voltar ao motor local") {
                    ContaGrok.sair()
                    ligada = false
                    codigo = nil
                    Task { estado = await ContaGrok.estado() }
                }
                .font(.subheadline)
                .foregroundStyle(Tema.tintaSuave)
                .frame(minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("sair-conta")
            } else {
                Button(entrando ? "esperando aprovação…" : "Entrar com a minha conta Grok") {
                    entrar()
                }
                .font(Tema.chrome.weight(.semibold))
                .foregroundStyle(Tema.ambar)
                .frame(minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())
                .disabled(entrando)
                .accessibilityIdentifier("entrar-conta")
            }

            Text("A análise usa a sua assinatura do Grok. O Traço não tem chave de API e nunca cobra por uso. Sem conta, ele funciona 100% local. Notas trancadas jamais vão à rede.")
                .font(.footnote)
                .foregroundStyle(Tema.tintaFraca)
        }
    }

    private func entrar() {
        entrando = true
        tarefa?.cancel()
        tarefa = Task {
            guard let novo = await ContaGrok.pedirCodigo() else {
                entrando = false
                estado = "não deu para falar com a xAI — tente de novo."
                return
            }
            codigo = novo
            abrir(novo.url)
            let ok = await ContaGrok.aguardar(novo)
            entrando = false
            codigo = nil
            ligada = ContaGrok.ligada
            estado = ok ? await ContaGrok.estado() : "login não concluído."
            if ok { Toque.suave() }
        }
    }

    // MARK: - Ajustes

    private var ajustes: some View {
        VStack(alignment: .leading, spacing: 12) {
            rotulo("AJUSTES")
            Toggle(isOn: Binding(
                get: { sessao.autoAnalise },
                set: { novo in
                    if novo != sessao.autoAnalise { sessao.alternarAutoAnalise() }
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Análise automática")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                    Text("A análise chega sozinha na pausa da escrita. Você nunca precisa lembrar do botão.")
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaFraca)
                }
            }
            .tint(Tema.ambar)
            .accessibilityIdentifier("ajuste-auto-analise")
        }
    }

    private func rotulo(_ t: String) -> some View {
        Text(t)
            .font(Tema.label)
            .tracking(Tema.trackingLabel)
            .foregroundStyle(Tema.tintaFraca)
    }
}
