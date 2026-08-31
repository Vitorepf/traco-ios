import AVFoundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CadernoView: View {
    /// A barra de ações da página viaja DENTRO deste mesmo inset: uma barra
    /// deslizando e outra aparecendo por opacidade se atravessavam no ar.
    var rodape: AnyView?
    /// Com o cartão em cena, a régua sai: o rodapé tem UM ocupante por vez.
    var esconderRegua: Bool = false
    @Binding var texto: String
    var foco: FocusState<Bool>.Binding
    var folga: CGFloat
    @Binding var abrirArquivo: Bool
    var aoMudar: () -> Void

    @State private var editando: String?
    @State private var unaCrua = false
    @State private var foto: PhotosPickerItem?
    @State private var video: PhotosPickerItem?
    @State private var menuFoto = false
    @State private var menuVideo = false
    @State private var importaAudio = false
    @State private var importaFicheiro = false
    @State private var menuArquivo = false
    @State private var menuLingua = false
    @State private var gravando = false
    @State private var gravador: AVAudioRecorder?

    private var fatias: [FatiaCaderno] { Caderno.fatias(texto) }

    private var soProsa: Bool {
        fatias.allSatisfy {
            if case .paragrafo = $0.bloco { return true }
            return false
        }
    }

    var body: some View {
        Group {
            // a página nasceu una e o teclado segue de pé: o campo sob o cursor
            // NUNCA morre no meio da digitação — a prosa veste ao soltar o teclado
            if let una = Caderno.paginaUna(texto)
                ?? (unaCrua && foco.wrappedValue && Caderno.soProsaELista(texto)
                    ? FatiaCaderno(id: "una-crua", bloco: .paragrafo(texto), fonte: texto, aberto: true)
                    : nil) {
                editorUna(una)
                    .padding(.horizontal, Tema.margem)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(fatias) { fatia in
                            if deveEditar(fatia) {
                                editor(fatia)
                            } else {
                                portal(fatia)
                            }
                        }
                    }
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 28)
                }
                .scrollDismissesKeyboard(editando == nil ? .interactively : .never)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if gravando {
                    Button("A gravar") { pararGravacao() }
                        .font(Tema.label)
                        .foregroundStyle(Tema.tintaSuave)
                        .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                        .accessibilityIdentifier("a-gravar")
                        .accessibilityLabel("Parar gravação")
                }
                if foco.wrappedValue, !esconderRegua {
                    regua
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Tema.fundo)
                        .overlay(alignment: .top) {
                            Rectangle().fill(Tema.luzBorda).frame(height: 0.5)
                        }
                        .transition(.move(edge: .bottom))
                }
                // a barra de ações da página mora AQUI: um container, uma lei.
                // A altura mínima impede o quadro VAZIO entre um ocupante sair
                // e o outro entrar (k175) — sem voltar à sobreposição.
                rodape
                    .frame(minHeight: rodape == nil ? 0 : 54)
            }
            // uma animação para a superfície inteira: os filhos trocam DENTRO
            // dela — quem anima é a ALTURA do container, não a opacidade de
            // dois irmãos que ocupam as mesmas linhas
            .animation(Tema.gaveta(reduzido: false), value: foco.wrappedValue)
            .animation(Tema.gaveta(reduzido: false), value: esconderRegua)
            .clipped()
        }
        .onAppear {
            unaCrua = Caderno.paginaUna(texto) != nil
        }
        .onChange(of: foco.wrappedValue) { _, f in
            // o vínculo cru se decide quando o teclado SOBE (a nota era una?);
            // ao descer, a condição do branch já solta a forma sozinha
            if f { unaCrua = Caderno.paginaUna(texto) != nil }
        }
        .onDisappear {
            if gravando { pararGravacao() }
        }
        .onChange(of: abrirArquivo) { _, pedido in
            if pedido {
                menuArquivo = true
                abrirArquivo = false
            }
        }
        .photosPicker(isPresented: $menuFoto, selection: $foto, matching: .images)
        .photosPicker(isPresented: $menuVideo, selection: $video, matching: .videos)
        .onChange(of: foto) { _, item in
            Task { await importarFoto(item) }
        }
        .onChange(of: video) { _, item in
            Task { await importarVideo(item) }
        }
        .fileImporter(isPresented: $importaAudio, allowedContentTypes: [.audio], allowsMultipleSelection: false) { resultado in
            importarResultado(resultado)
        }
        .fileImporter(isPresented: $importaFicheiro, allowedContentTypes: [.item], allowsMultipleSelection: false) { resultado in
            importarResultado(resultado)
        }
        .confirmationDialog("Anexar", isPresented: $menuArquivo, titleVisibility: .visible) {
            Button("Foto") { menuFoto = true }
            Button("Vídeo") { menuVideo = true }
            Button("Áudio") { importaAudio = true }
            Button(gravando ? "Parar" : "Gravar") { tocarGravacao() }
            Button("Arquivo") { importaFicheiro = true }
        }
        .confirmationDialog("Língua do código", isPresented: $menuLingua, titleVisibility: .visible) {
            Button("Swift") { transformarCodigo("swift") }
            Button("JSON") { transformarCodigo("json") }
            Button("JavaScript") { transformarCodigo("javascript") }
            Button("TypeScript") { transformarCodigo("typescript") }
            Button("Python") { transformarCodigo("python") }
            Button("Rust") { transformarCodigo("rust") }
            Button("Go") { transformarCodigo("go") }
            Button("HTML") { transformarCodigo("html") }
            Button("CSS") { transformarCodigo("css") }
            Button("SQL") { transformarCodigo("sql") }
            Button("Shell") { transformarCodigo("bash") }
            Button("Texto") { transformarCodigo("texto") }
        }
    }

    private var regua: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(PapelForma.regua) { papel in
                        Button(papel.nome) {
                            Toque.selecao()
                            withAnimation(.easeOut(duration: 0.18)) { transformar(papel) }
                        }
                        .buttonStyle(PressaoDiscreta())
                        .frame(minHeight: Tema.alvo)
                        .accessibilityIdentifier("regua-\(papel.slug)")
                    }
                }
            }
            .mask(
                HStack(spacing: 0) {
                    Rectangle()
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 16)
                }
            )
            .accessibilityIdentifier("regua")
            Button {
                editando = nil
                Teclado.recolher()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .frame(width: Tema.alvo, height: 32)
            }
            .accessibilityLabel("Esconder teclado")
        }
        .font(Tema.label)
        .foregroundStyle(Tema.tintaSuave)
    }

    private func editorUna(_ fatia: FatiaCaderno) -> some View {
        let eLista = if case .itens = fatia.bloco { true } else { false }
        let eTarefa = if case .tarefas = fatia.bloco { true } else { false }
        let eCitacao = if case .citacao = fatia.bloco { true } else { false }
        let eTabela = if case .tabela = fatia.bloco { true } else { false }
        let nivel = if case .titulo(let n, _) = fatia.bloco { n } else { 0 }
        let eSeccao = nivel == 2
        let eSub = nivel == 3
        let eTituloCapa = nivel == 1
        let mostraSinal = eTabela || eSeccao || eSub
        let nomeSinal = eSeccao ? "seção" : eSub ? "subseção" : "tabela"
        return VStack(alignment: .leading, spacing: 0) {
            SinalTipo(nome: nomeSinal)
                .opacity(mostraSinal ? 1 : 0)
                .frame(height: mostraSinal ? 18 : 0)
                .padding(.bottom, mostraSinal ? 8 : 0)
                .accessibilityHidden(!mostraSinal)
            // lista digita CRUA no mesmo campo (o cursor nunca troca de árvore);
            // ao soltar o teclado, veste a forma
            if eLista, !foco.wrappedValue,
               !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ProsaView(bloco: fatia.bloco)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { foco.wrappedValue = true }
            } else {
                linhaEditor(fatia)
            }
        }
        .padding(eCitacao ? 12 : 0)
        .background(eCitacao ? Tema.superficie : .clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityIdentifier(
            eLista ? "portal-lista"
                : eTarefa ? "portal-tarefa"
                : eTabela ? "portal-tabela"
                : eCitacao ? "portal-citacao"
                : eSeccao ? "portal-seccao"
                : eSub ? "portal-subseccao"
                : eTituloCapa ? "portal-titulo"
                : "pagina"
        )
    }

    private func linhaEditor(_ fatia: FatiaCaderno) -> some View {
        let eTarefa = if case .tarefas = fatia.bloco { true } else { false }
        let eCitacao = if case .citacao = fatia.bloco { true } else { false }
        let feito = if case .tarefas(let xs) = fatia.bloco { xs.first?.feito == true } else { false }
        return HStack(alignment: .top, spacing: eTarefa || eCitacao ? 12 : 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(Tema.tintaFraca)
                        .frame(width: 2, height: 28)
                        .opacity(eCitacao ? 1 : 0)
                    Button {
                        guard case .tarefas(let xs) = fatia.bloco else { return }
                        var next = xs.isEmpty ? [TarefaCaderno(feito: false, texto: "")] : xs
                        next[0].feito.toggle()
                        texto = Caderno.aplicar(fatias, id: fatia.id, bloco: .tarefas(next))
                        aoMudar()
                    } label: {
                        Image(systemName: feito ? "checkmark.circle.fill" : "circle")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.body)
                            .foregroundStyle(feito ? Tema.tintaSuave : Tema.tintaFraca)
                            .frame(width: Tema.alvo, height: Tema.alvo)
                    }
                    .buttonStyle(.plain)
                    .opacity(eTarefa ? 1 : 0)
                    .allowsHitTesting(eTarefa)
                    .accessibilityLabel(feito ? "Feita" : "Por fazer")
                    .accessibilityHidden(!eTarefa)
                }
                .frame(width: eTarefa || eCitacao ? (eTarefa ? Tema.alvo : 20) : 0)
                campoUna(fatia)
        }
    }

    private func campoUna(_ fatia: FatiaCaderno) -> some View {
        let nivel = if case .titulo(let n, _) = fatia.bloco { n } else { 0 }
        let eCitacao = if case .citacao = fatia.bloco { true } else { false }
        // lista não projeta: edita o documento cru e o Enter herda o marcador
        let projeta = switch fatia.bloco {
        case .paragrafo, .itens: false
        default: true
        }
        return TextEditor(text: Binding(
            get: {
                if projeta {
                    return Caderno.textoVisivel(fatia.bloco)
                }
                return texto
            },
            set: { novo in
                // clobber de teardown: quando a régua transforma o documento, o
                // campo velho morre na troca de branch e tenta reescrever o texto
                // antigo por cima — um escrito de um campo que já não representa
                // o documento é descartado
                let vivo = Caderno.paginaUna(texto)
                if projeta {
                    guard vivo?.id == fatia.id else { return }
                    texto = Caderno.aplicar(fatias, id: fatia.id, bloco: Caderno.comTexto(fatia.bloco, novo))
                } else {
                    guard vivo != nil || (foco.wrappedValue && Caderno.soProsaELista(texto)) else { return }
                    texto = Caderno.continuar(velho: texto, novo: novo)
                }
                aoMudar()
            }
        ))
        .font(nivel == 1 ? Tema.tituloNota : nivel >= 2 ? Tema.secaoNota : eCitacao ? Tema.corpo.italic() : Tema.corpo)
        .lineSpacing(nivel > 0 ? 4 : folga)
        .tracking(nivel == 1 ? -0.4 : nivel >= 2 ? -0.2 : -0.05)
        .foregroundStyle(Tema.tinta)
        .scrollContentBackground(.hidden)
        .focused(foco)
        .tint(Tema.ambar)
        .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .topLeading)
        .id("pagina-una")
        .accessibilityLabel(
            nivel == 1 ? "Título"
                : nivel == 2 ? "Seção"
                : nivel == 3 ? "Subseção"
                : eCitacao ? "Citação"
                : "Página"
        )
        .accessibilityIdentifier("pagina")
    }

    @ViewBuilder
    private func portal(_ fatia: FatiaCaderno) -> some View {
        switch fatia.bloco {
        case .codigo(let lingua, let fonte) where lingua == "tex" || lingua == "latex":
            PortalFormulaView(fonte: fonte)
                .onTapGesture { editar(fatia) }
        case .codigo(let lingua, let fonte):
            PortalCodigoView(lingua: lingua, fonte: fonte)
                .onTapGesture { editar(fatia) }
        case .imagem, .audio, .video, .arquivo:
            PortalArquivoView(bloco: fatia.bloco)
        case .tarefas:
            ProsaView(bloco: fatia.bloco, aoAlternarTarefa: { i in alternarTarefa(fatia, i) })
                .onTapGesture { editar(fatia) }
        case .divisoria:
            ProsaView(bloco: fatia.bloco)
        case .paragrafo(let t) where t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty:
            Color.clear
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .topLeading)
                .contentShape(Rectangle())
                .onTapGesture { editar(fatia) }
                .accessibilityIdentifier("pagina")
        default:
            ProsaView(bloco: fatia.bloco)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { editar(fatia) }
        }
    }

    private func deveEditar(_ fatia: FatiaCaderno) -> Bool {
        if let editando {
            return fatia.id == editando
        }
        if fatia.aberto, case .paragrafo(let t) = fatia.bloco {
            return !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }

    private func editor(_ fatia: FatiaCaderno) -> some View {
        EditorBlocoView(
            bloco: fatia.bloco,
            folga: folga,
            foco: foco,
            aoMudar: { bloco in
                texto = Caderno.aplicar(fatias, id: fatia.id, bloco: bloco)
                aoMudar()
            },
            aoLingua: { menuLingua = true }
        )
    }

    private func editar(_ fatia: FatiaCaderno) {
        editando = fatia.id
        Task { @MainActor in
            foco.wrappedValue = true
        }
    }

    private func transformarCodigo(_ lingua: String) {
        transformar(PapelForma(slug: "codigo", nome: "Código", gesto: .codigo(lingua: lingua), cromo: .padrao))
    }

    private func transformar(_ papel: PapelForma) {
        if case .codigo(let lingua) = papel.gesto, lingua == nil {
            menuLingua = true
            Toque.leve()
            return
        }
        if soProsa {
            transformarProsa(papel)
        } else {
            transformarFatia(papel)
        }
        Toque.leve()
        Task { @MainActor in
            foco.wrappedValue = true
        }
        aoMudar()
    }

    private func transformarProsa(_ papel: PapelForma) {
        let (antes, ultimo) = Caderno.partirUltimo(texto)
        if insereNovo(papel) {
            let bloco = bloco(de: papel, texto: "")
            let prosa = ultimo.trimmingCharacters(in: .whitespacesAndNewlines)
            if prosa.isEmpty {
                texto = Caderno.juntar(antes, bloco)
            } else {
                texto = Caderno.juntar(Caderno.juntar(antes, .paragrafo(ultimo)), bloco)
            }
            abrirUltimo(de: papel)
        } else {
            texto = Caderno.juntar(antes, bloco(de: papel, texto: ultimo))
            if ultimo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                abrirUltimo(de: papel)
            } else {
                editando = nil
            }
        }
    }

    private func transformarFatia(_ papel: PapelForma) {
        guard let alvo = fatiaAlvo else {
            texto = Caderno.juntar(texto, bloco(de: papel, texto: ""))
            abrirUltimo(de: papel)
            return
        }
        let visivel = Caderno.textoVisivel(alvo.bloco)
        let vazio = visivel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if insereNovo(papel) {
            if vazio, case .paragrafo = alvo.bloco {
                texto = Caderno.aplicar(fatias, id: alvo.id, bloco: bloco(de: papel, texto: ""))
                editando = alvo.id
            } else {
                texto = Caderno.juntar(texto, bloco(de: papel, texto: ""))
                abrirUltimo(de: papel)
            }
        } else {
            texto = Caderno.aplicar(fatias, id: alvo.id, bloco: bloco(de: papel, texto: visivel))
            editando = vazio ? alvo.id : nil
        }
    }

    private func insereNovo(_ papel: PapelForma) -> Bool {
        switch papel.gesto {
        case .codigo, .tabela, .divisoria: true
        default: false
        }
    }

    private func bloco(de papel: PapelForma, texto: String) -> BlocoCaderno {
        let linhas = texto.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        switch papel.gesto {
        case .titulo(let n):
            return .titulo(n, texto.trimmingCharacters(in: .newlines))
        case .lista(let ordenada):
            return .itens(linhas.isEmpty ? [""] : linhas, ordenada: ordenada)
        case .tarefa:
            let xs = (linhas.isEmpty ? [""] : linhas).map { TarefaCaderno(feito: false, texto: $0) }
            return .tarefas(xs)
        case .citacao:
            return .citacao(linhas.isEmpty ? [""] : linhas)
        case .codigo(let lingua):
            return .codigo(lingua: lingua ?? "texto", fonte: "")
        case .tabela:
            return .tabela(cabeca: ["", ""], corpo: [["", ""]])
        case .divisoria:
            return .divisoria
        case .recipiente:
            if linhas.isEmpty {
                return .recipiente(slug: papel.slug, linhas: papel.cromo == .duplo ? ["", ""] : [""])
            }
            return .recipiente(slug: papel.slug, linhas: linhas)
        }
    }

    private var fatiaAlvo: FatiaCaderno? {
        if let editando, let hit = fatias.first(where: { $0.id == editando }) {
            return hit
        }
        return fatias.last { $0.aberto } ?? fatias.last
    }

    private func abrirUltimo(de papel: PapelForma) {
        let f = Caderno.fatias(texto)
        switch papel.gesto {
        case .codigo:
            editando = f.last { if case .codigo = $0.bloco { true } else { false } }?.id
        case .tabela:
            editando = f.last { if case .tabela = $0.bloco { true } else { false } }?.id
        case .divisoria:
            editando = nil
        case .recipiente:
            editando = f.last {
                if case .recipiente(let slug, _) = $0.bloco { slug == papel.slug } else { false }
            }?.id
        default:
            editando = f.last { !$0.aberto }?.id
        }
    }

    private func alternarTarefa(_ fatia: FatiaCaderno, _ indice: Int) {
        guard case .tarefas(let xs) = fatia.bloco else { return }
        var next = xs
        next[indice].feito.toggle()
        texto = Caderno.aplicar(fatias, id: fatia.id, bloco: .tarefas(next))
        aoMudar()
    }

    private func importarFoto(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        gravar(dados: data, nome: "foto.jpg", tipo: .jpeg)
    }

    private func importarVideo(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        gravar(dados: data, nome: "video.mov", tipo: .mpeg4Movie)
    }

    private func importarResultado(_ resultado: Result<[URL], Error>) {
        if case .success(let urls) = resultado, let url = urls.first {
            importarURL(url)
        }
    }

    private func importarURL(_ url: URL) {
        let ok = url.startAccessingSecurityScopedResource()
        defer { if ok { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else { return }
        let tipo = UTType(filenameExtension: url.pathExtension) ?? .data
        gravar(dados: data, nome: url.lastPathComponent, tipo: tipo)
    }

    private func gravar(dados: Data, nome: String, tipo: UTType) {
        let id = UUID()
        guard (try? AnexoDisco.gravar(id: id, dados: dados, nome: nome)) != nil else { return }
        texto += AnexoDisco.marcaMarkdown(id: id, nome: nome, tipo: tipo)
        editando = nil
        Toque.leve()
        aoMudar()
    }

    private func tocarGravacao() {
        if gravando { pararGravacao() } else { iniciarGravacao() }
    }

    private func iniciarGravacao() {
        Task {
            let ok = await AVAudioApplication.requestRecordPermission()
            guard ok else { return }
            do {
                let sessao = AVAudioSession.sharedInstance()
                try sessao.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
                try sessao.setActive(true)
                let dest = FileManager.default.temporaryDirectory
                    .appendingPathComponent("voz-\(UUID().uuidString).m4a")
                let gravadorNovo = try AVAudioRecorder(
                    url: dest,
                    settings: [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44_100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                )
                gravadorNovo.record()
                gravador = gravadorNovo
                gravando = true
            } catch {
                gravando = false
                gravador = nil
            }
        }
    }

    private func pararGravacao() {
        let url = gravador?.url
        gravador?.stop()
        gravador = nil
        gravando = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        guard let url,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              data.count > 200
        else { return }
        gravar(dados: data, nome: "voz.m4a", tipo: .mpeg4Audio)
    }
}
