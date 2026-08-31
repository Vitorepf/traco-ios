import SwiftData
import SwiftUI

/// Meu perfil (SPEC §18): conta e ajustes num lugar só.
/// Não existe chave de API nem cobrança por token — a análise com Grok anda
/// pela ASSINATURA do autor (ADR 2026-08-31k).
struct PerfilView: View {
    var sessao: Sessao
    @Environment(\.openURL) private var abrir

    @State private var ligada = ContaGrok.ligada
    @State private var estado: String?
    @State private var codigo: ContaGrok.Codigo?
    @State private var entrando = false
    @State private var tarefa: Task<Void, Never>?
    @State private var corpusURL: URL?
    @State private var importarMd = false
    @Environment(\.modelContext) private var context
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]

    var body: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
            TituloTela("Meu perfil")
            ScrollView {
                VStack(alignment: .leading, spacing: Tema.entreSecoes) {
                    conta
                    ajustes
                    dados
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
            }
            }
        }
        .fileImporter(isPresented: $importarMd,
                      allowedContentTypes: [.plainText, .init(filenameExtension: "md") ?? .plainText],
                      allowsMultipleSelection: true) { resultado in
            guard case .success(let urls) = resultado else { return }
            var total = 0
            for url in urls {
                let acesso = url.startAccessingSecurityScopedResource()
                defer { if acesso { url.stopAccessingSecurityScopedResource() } }
                guard let conteudo = try? String(contentsOf: url, encoding: .utf8) else { continue }
                for item in Corpus.importar(conteudo) {
                    // Regra do selo: import JAMAIS cria trancada.
                    let gesto = item.gestoNome.flatMap(Gesto.doNome)
                    // labels do export voltam a ser CAMPOS, nunca voz do autor
                    let (corpo, campos) = Corpus.separarCampos(texto: item.texto, gesto: gesto)
                    let nota = Nota(texto: corpo, gesto: gesto, campos: campos)
                    nota.criadaEm = item.criadaEm
                    context.insert(nota)
                    total += 1
                }
            }
            try? context.save()
            if total > 0 { sessao.mostrarToast("\(total) nota\(total == 1 ? "" : "s") importada\(total == 1 ? "" : "s").") }
        }
        .sheet(isPresented: Binding(get: { corpusURL != nil }, set: { if !$0 { corpusURL = nil } })) {
            if let corpusURL {
                CompartilharArquivo(url: corpusURL)
            }
        }
        .onDisappear { tarefa?.cancel() }
        .task { estado = await ContaGrok.estado() }
    }

    // MARK: - Conta

    private var conta: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
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
        VStack(alignment: .leading, spacing: Tema.entreItens) {
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

    // MARK: - Dados (§20: exportar/importar são AÇÃO, não navegação — moram aqui)

    private var dados: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("DADOS")
            linhaAcao("Exportar o corpus (.md)") {
                corpusURL = Corpus.exportar(notas: notas)
            }
            .accessibilityIdentifier("exportar-corpus")
            .accessibilityHint("Gera um Markdown com as notas abertas. Trancadas nunca saem.")
            Rectangle().fill(Tema.linha).frame(height: 0.5)
            linhaAcao("Importar .md") { importarMd = true }
                .accessibilityIdentifier("importar-md")
                .accessibilityHint("Traz notas de arquivos Markdown. Import nunca cria trancada.")
            Text("O backup automático já grava no Arquivos a cada nota concluída.")
                .font(.footnote)
                .foregroundStyle(Tema.tintaFraca)
        }
    }

    /// Ação parece ação: chevron à direita (critique-affordance). Sem ele, era
    /// texto branco idêntico ao rótulo morto ao lado.
    private func linhaAcao(_ titulo: String, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            HStack {
                Text(titulo)
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tinta)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Tema.tintaFraca)
            }
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressaoDiscreta())
    }

    private func rotulo(_ t: String) -> some View {
        Text(t)
            .font(Tema.label)
            .tracking(Tema.trackingLabel)
            .foregroundStyle(Tema.tintaFraca)
    }
}
