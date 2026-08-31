import SwiftData
import UIKit
import SwiftUI

struct NotasView: View {
    @Bindable var sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]
    @State private var busca = ""
    @State private var filtro: FiltroNotas?
    @State private var corpusURL: URL?
    @State private var mostrarChave = false
    @State private var importarMd = false

    var body: some View {
        Empilha(aberto: $sessao.mostrarPadroes, reduceMotion: reduceMotion) {
            telaNotas
        } frente: {
            PadroesView(sessao: sessao)
        }
    }

    private var telaNotas: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                topbar
                campoBusca
                chips
                lista
            }
        }
        .sheet(isPresented: $mostrarChave) { ChaveView() }
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
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var topbar: some View {
        HStack {
            Button {
                sessao.mostrarPadroes = false
                sessao.mostrarNotas = false
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.backward")
                        .font(.subheadline.weight(.semibold))
                    Text("página")
                }
            }
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
            .accessibilityIdentifier("voltar-pagina")
            .accessibilityLabel("Voltar à página")
            Spacer()
            Button("padrões") {
                Teclado.recolher()
                sessao.mostrarPadroes = true
            }
            .font(.subheadline)
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
            .accessibilityIdentifier("abrir-padroes")
            .accessibilityLabel("Padrões")
            .accessibilityHint("Perguntas sobre padrões das suas notas")
            Button {
                sessao.salvar(no: context)
                sessao.novaPagina()
                sessao.mostrarPadroes = false
                sessao.mostrarNotas = false
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Tema.ambar)
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Nova página")
        }
        .font(Tema.chrome)
        .buttonStyle(PressaoDiscreta())
        .padding(.horizontal, Tema.margem)
        .frame(minHeight: Tema.alvo)
    }

    private var campoBusca: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Tema.tintaFraca)
                .accessibilityHidden(true)
            TextField(
                "",
                text: $busca,
                prompt: Text("Buscar nas notas").foregroundStyle(Tema.tintaFraca)
            )
                .foregroundStyle(Tema.tinta)
                .tint(Tema.ambar)
                .font(Tema.corpo)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("busca-notas")
                .accessibilityLabel("Buscar nas notas")
                .accessibilityValue(busca.isEmpty ? "vazio" : busca)
                .accessibilityHint(filtro == .trancadas ? "Indisponível no filtro de trancadas" : "Procura a voz do autor")
            if !busca.isEmpty {
                Button {
                    busca = ""
                    filtro = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Tema.tintaFraca)
                        .frame(width: Tema.alvo, height: Tema.alvo)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressaoDiscreta())
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                .accessibilityIdentifier("limpar-busca")
                .accessibilityLabel("Limpar busca")
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: Tema.alvo)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 8)
        .opacity(filtro == .trancadas ? 0.4 : 1)
        .disabled(filtro == .trancadas)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FiltroNotas.allCases) { item in
                    Button {
                        Toque.selecao()
                        withAnimation(.easeOut(duration: 0.25)) {
                            filtro = filtro == item ? nil : item
                        }
                    } label: {
                        Text(item.rawValue)
                            .font(Tema.label)
                            .foregroundStyle(filtro == item ? Tema.ambar : Tema.tintaSuave)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(minHeight: 32)
                            .background(
                                Capsule().fill(filtro == item ? Tema.ambarSuave : Tema.superficie)
                            )
                    }
                    // alvo de toque 44 sem inflar o visual
                    .frame(minHeight: Tema.alvo)
                    .contentShape(Rectangle())
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityAddTraits(filtro == item ? [.isSelected] : [])
                    .accessibilityIdentifier("filtro-\(item.slug)")
                    .accessibilityLabel(item.rawValue)
                }
            }
            .padding(.horizontal, Tema.margem)
        }
        .mask(
            HStack(spacing: 0) {
                Rectangle()
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 16)
            }
        )
        .padding(.bottom, 8)
        .accessibilityHint("Um filtro por vez")
    }

    private var lista: some View {
        let visiveis = filtradas
        return Group {
            if visiveis.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Tema.tintaFraca)
                        .accessibilityHidden(true)
                    Text(vazioTitulo)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                    Button("escrever na página") {
                        sessao.novaPagina()
                        sessao.mostrarNotas = false
                    }
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.ambar)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                    if busca.isEmpty, filtro == nil {
                        Button {
                            mostrarChave = true
                        } label: {
                            Text(Chave.existe ? "análise com Grok: chave guardada" : "análise com Grok: configurar chave")
                                .font(.subheadline)
                                .foregroundStyle(Tema.tintaFraca)
                                .frame(minHeight: Tema.alvo)
                        }
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityIdentifier("configurar-chave")
                        .accessibilityHint("Chave da API da xAI no Keychain. Sem chave, o app é 100% local.")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(Tema.margem)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(visiveis, id: \.uuid) { nota in
                            botaoNota(nota)
                            Rectangle().fill(Tema.linha).frame(height: 0.5)
                        }
                        // Export mora no fim do arquivo: ação de arquivamento, não de uso diário.
                        // A geração acontece NO TOQUE (nada de I/O no body).
                        if busca.isEmpty, filtro == nil, notas.contains(where: { !$0.trancada }) {
                            Button {
                                corpusURL = Corpus.exportar(notas: notas)
                            } label: {
                                Text("exportar o corpus (.md)")
                                    .font(.subheadline)
                                    .foregroundStyle(Tema.tintaFraca)
                                    .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .padding(.top, 12)
                            .accessibilityIdentifier("exportar-corpus")
                            .accessibilityHint("Gera um arquivo Markdown com as notas abertas. Trancadas nunca saem.")
                        }
                        if busca.isEmpty, filtro == nil {
                            Button {
                                mostrarChave = true
                            } label: {
                                Text(Chave.existe ? "análise com Grok: chave guardada" : "análise com Grok: configurar chave")
                                    .font(.subheadline)
                                    .foregroundStyle(Tema.tintaFraca)
                                    .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityIdentifier("configurar-chave")
                            .accessibilityHint("Chave da API da xAI no Keychain. Sem chave, o app é 100% local.")
                        }
                        if busca.isEmpty, filtro == nil {
                            Button {
                                importarMd = true
                            } label: {
                                Text("importar .md")
                                    .font(.subheadline)
                                    .foregroundStyle(Tema.tintaFraca)
                                    .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityIdentifier("importar-md")
                            .accessibilityHint("Traz notas de arquivos Markdown. Tudo entra aberto — import nunca cria trancada.")
                        }
                    }
                    .padding(.horizontal, Tema.margem)
                }
            }
        }
    }

    private var vazioTitulo: String {
        if filtro == .trancadas { return "nenhuma trancada." }
        if !busca.isEmpty { return "nada com “\(busca)”" }
        return "nada aqui."
    }

    private func botaoNota(_ nota: Nota) -> some View {
        Button {
            if nota.trancada {
                sessao.confirmacao = .naoSeRele(nota.uuid)
            } else {
                sessao.abrir(nota)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                if nota.trancada {
                    Label("Expressiva — trancada", systemImage: "lock.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Tema.tintaSuave)
                    Text("não se relê · \(VozDoAutor.relativo(nota.criadaEm))")
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaFraca)
                } else {
                    DestaqueBusca.texto(titulo(nota), termo: busca, base: Tema.tinta)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        if let g = nota.gesto {
                            Text(g.nome)
                                .foregroundStyle(Tema.tintaSuave)
                        }
                        DestaqueBusca.texto(subtitulo(nota), termo: busca, base: Tema.tintaSuave)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressaoDiscreta())
        .tint(Tema.tinta)
        .contextMenu {
            if !nota.trancada {
                Button("Recordar") { sessao.recordarDaNotas(nota) }
            }
            // ADR 2026-08-31f: apagar existe, com atrito — trancada exige dupla.
            Button("Apagar", role: .destructive) {
                sessao.confirmacao = nota.trancada ? .apagarTrancada(nota.uuid) : .apagar(nota.uuid)
            }
        }
        .accessibilityLabel(nota.trancada ? "Expressiva trancada" : titulo(nota))
        .accessibilityHint(nota.trancada ? "Reabrir pede confirmação dupla" : "Segure para recordar a memória")
        .accessibilityIdentifier("nota-notas")
    }

    private var filtradas: [Nota] {
        NotasFiltro.visiveis(notas, busca: busca, filtro: filtro)
    }

    private func titulo(_ nota: Nota) -> String {
        VozDoAutor.titulo(nota.texto)
    }

    private func subtitulo(_ nota: Nota) -> String {
        if !busca.isEmpty {
            return VozDoAutor.trecho(em: nota.vozDoAutor, termo: busca)
        }
        let respostas = nota.campos.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if respostas.isEmpty {
            return VozDoAutor.relativo(nota.criadaEm)
        }
        return VozDoAutor.truncar(respostas.joined(separator: " · "), 56)
    }
}


/// Folha de compartilhamento do sistema (o export gera no toque, não no body).
private struct CompartilharArquivo: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
