import AVFoundation
import UIKit
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CadernoView: View {
    /// A barra de ações da página viaja DENTRO deste mesmo inset: uma barra
    /// deslizando e outra aparecendo por opacidade se atravessavam no ar.
    var rodape: AnyView?
    /// Campos da forma — abaixo do texto, não numa folha que some ao reabrir.
    var abaixo: AnyView? = nil
    /// Com o cartão em cena, a régua sai: o rodapé tem UM ocupante por vez.
    var esconderRegua: Bool = false
    @Binding var texto: String
    var foco: FocusState<Bool>.Binding
    var folga: CGFloat
    @Binding var abrirArquivo: Bool
    /// §17 × dedo em voo: o toque na régua avisa a sessão para SEGURAR o vestir
    /// automático — a forma não veste no meio do alcance e o chip não salta.
    var aoTocarRegua: ((Bool) -> Void)? = nil
    var aoMudar: () -> Void

    @State private var editando: String?
    // Enter no título/parágrafo troca o campo focado: se o FocusState cair na
    // troca, esta flag devolve o foco ao editor que nasce (medido em 01/set:
    // sem ela o teclado descia no meio da descida para o corpo)
    @State private var descendoDoTitulo = false
    @State private var unaCrua = false
    @State private var foto: PhotosPickerItem?
    @State private var video: PhotosPickerItem?
    @State private var menuFoto = false
    @State private var menuVideo = false
    @State private var importaAudio = false
    @State private var importaFicheiro = false
    @State private var menuArquivo = false
    @State private var menuLingua = false
    @State private var menuFormas = false
    @State private var formaDoMenu: PapelForma?
    @State private var gravando = false
    @State private var gravador: AVAudioRecorder?

    private var fatias: [FatiaCaderno] { Caderno.fatias(texto) }

    private var soProsa: Bool {
        fatias.allSatisfy {
            if case .paragrafo = $0.bloco { return true }
            return false
        }
    }

    @ViewBuilder
    private var paginaCaderno: some View {
        if let una = Caderno.paginaUna(texto)
            ?? (unaCrua && foco.wrappedValue && Caderno.soProsaELista(texto)
                ? FatiaCaderno(id: "una-crua", bloco: .paragrafo(texto), fonte: texto, aberto: true)
                : nil) {
            paginaUna(una)
        } else {
            paginaFatias
        }
    }

    @ViewBuilder
    private func paginaUna(_ una: FatiaCaderno) -> some View {
        if abaixo != nil {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    editorUna(una)
                        .padding(.horizontal, Tema.margem)
                        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                    abaixo
                }
                .padding(.bottom, 28)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            editorUna(una)
                .padding(.horizontal, Tema.margem)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var paginaFatias: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(fatias) { fatia in
                    fatiaNaPagina(fatia)
                        .padding(.horizontal, Tema.margem)
                }
                abaixo
            }
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(editando == nil ? .interactively : .never)
    }

    @ViewBuilder
    private func fatiaNaPagina(_ fatia: FatiaCaderno) -> some View {
        if deveEditar(fatia) {
            editor(fatia)
        } else {
            portal(fatia)
        }
    }

    var body: some View {
        paginaCaderno
        // o encaixe ancora no FIM desta view: sem preencher a altura, a régua
        // ficava pendurada no meio da tela, com um vão até a barra de ações
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: foco.wrappedValue) { _, agora in
            if !agora, descendoDoTitulo {
                descendoDoTitulo = false
                foco.wrappedValue = true
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
                        .padding(.horizontal, Tema.margem)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Tema.fundo)
                        .overlay(alignment: .top) {
                            Rectangle().fill(Tema.linha).frame(height: 0.5)
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
        // A régua segue o FOCO e mais nada. Duas tentativas de amarrá-la ao
        // teclado falharam: seguir a PRESENÇA do teclado apagava a régua inteira
        // com teclado físico (iPad, Magic Keyboard); soltar o foco no
        // keyboardWillHide matava o editor recém-aberto, porque trocar de campo
        // posta willHide antes de o novo campo assumir. O vão que o dono viu era
        // do ScrollView sem altura — já corrigido lá embaixo, na própria régua.
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
        .sheet(isPresented: $menuFormas, onDismiss: {
            guard let papel = formaDoMenu else { return }
            formaDoMenu = nil
            withAnimation(.easeOut(duration: 0.18)) { transformar(papel) }
            // escolher na folha também NÃO expulsa quem escreve. O foco que
            // `transformar` repõe é apagado logo depois pela folha ao sair de
            // cena, então ele é reposto de novo quando ela já saiu — senão o
            // autor volta para a página sem teclado e sem régua.
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(350))
                foco.wrappedValue = true
            }
        }) {
            MenuFormasView { papel in
                formaDoMenu = papel
            }
        }
    }

    private var regua: some View {
        // ScrollView horizontal SEM altura engole todo o espaço oferecido: era
        // ela que abria o vão entre a régua e a barra de ações
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
                    // o último chip precisa SAIR de baixo da máscara de fade,
                    // senão fica cortado para sempre e é inalcançável
                    Color.clear.frame(width: 24)
                }
            }
            .mask(
                HStack(spacing: 0) {
                    Rectangle()
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 24)
                }
            )
            .accessibilityIdentifier("regua")

            // "Todas" é uma PORTA, não uma forma — e estava encostada nos chips
            // com 8pt de folga, logo depois de "Citação" cortada pela máscara. O
            // dedo que mirava a forma abria a folha. Fio vertical + folga fazem
            // dela um grupo à parte (law-of-common-region + fitts-law).
            Rectangle()
                .fill(Tema.linha)
                .frame(width: 0.5, height: 20)
                .padding(.leading, 12)
            Button("Todas") {
                Toque.selecao()
                menuFormas = true
            }
            .buttonStyle(PressaoDiscreta())
            .frame(minHeight: Tema.alvo)
            .padding(.leading, 12)
            .accessibilityIdentifier("regua-todas")
            Button {
                descendoDoTitulo = false
                editando = nil
                Teclado.recolher()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .padding(.leading, 8)
            }
            .accessibilityLabel("Esconder teclado")
        }
        // 11pt é pequeno para um instrumento — mas medi: a 15pt cabem 5 das 12
        // formas e a máscara de fade cai num VÃO entre chips, sem sinalizar
        // nada; a 11pt cabem 6 e o fade pega glifo. Enquanto a régua for uma
        // fileira única de 12 rótulos, alcance vence legibilidade. A troca certa
        // é de ESTRUTURA, não de corpo de letra — e é decisão do dono.
        .font(Tema.label)
        .foregroundStyle(Tema.tintaSuave)
        // 44, não 36: o .clipped() do encaixe corta o que passa da moldura, e
        // com 36 o alvo de toque dos chips ficava ABAIXO do mínimo da Apple —
        // o dedo errava a forma perto da borda (fitts-law)
        .frame(height: Tema.alvo)
        // toque em voo à régua SEGURA o vestir automático (o chip não salta sob
        // o dedo). minimumDistance 0 pega o instante do encostar; simultâneo,
        // não rouba o tap dos chips nem o rolar horizontal da fileira.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in aoTocarRegua?(true) }
                .onEnded { _ in aoTocarRegua?(false) }
        )
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
                    // Enter no título una desce para o corpo: a cabeça fica
                    // título, o cursor nasce no parágrafo da cauda (mesma
                    // receita do multi: editando + flag de rearme do foco)
                    if case .titulo(let n, _) = fatia.bloco, let corte = novo.firstIndex(of: "\n") {
                        let cabeca = String(novo[..<corte])
                        let resto = String(novo[novo.index(after: corte)...])
                        texto = Caderno.aplicar(
                            fatias, id: fatia.id,
                            novo: Caderno.serializar(.titulo(n, cabeca)) + "\n\n" + resto
                        )
                        editando = Caderno.fatias(texto).first {
                            if case .paragrafo = $0.bloco { true } else { false }
                        }?.id
                        descendoDoTitulo = true
                        aoMudar()
                        return
                    }
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
        // o recuo interno do TextEditor punha a prosa num degrau à direita do
        // rótulo da data (26pt vs 24pt medidos) — mesmo conserto do Recordar
        .padding(.horizontal, -Tema.sangriaEditor)
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
                // Enter no título ou no parágrafo desce para um bloco NOVO
                // (Notes): o \n parte o texto no corte, o resto nasce parágrafo
                // e o cursor vai atrás por adoção — o editor seguinte nasce no
                // MESMO ciclo, vinculado ao mesmo foco, e o teclado nunca desce
                // decide pela FATIA editada, não pelo bloco que chega: o editor
                // de lista envia .paragrafo(cru multilinha) pelo caminho do
                // continuar, e parti-lo no primeiro \n mutilava a lista
                let eTituloOuParagrafo = switch fatia.bloco {
                case .titulo, .paragrafo: true
                default: false
                }
                let quebra: (novo: String, corte: String.Index)? = if eTituloOuParagrafo {
                    switch bloco {
                    case .titulo(_, let t): t.firstIndex(of: "\n").map { (t, $0) }
                    case .paragrafo(let t): t.firstIndex(of: "\n").map { (t, $0) }
                    default: nil
                    }
                } else {
                    nil
                }
                if let (t, corte) = quebra {
                    let cabeca = String(t[..<corte])
                    let resto = String(t[t.index(after: corte)...])
                    let cabecote: BlocoCaderno = if case .titulo(let n, _) = bloco {
                        .titulo(n, cabeca)
                    } else {
                        .paragrafo(cabeca)
                    }
                    let posicao = fatias.firstIndex { $0.id == fatia.id }
                    texto = Caderno.aplicar(
                        fatias, id: fatia.id,
                        novo: Caderno.serializar(cabecote) + "\n\n" + resto
                    )
                    if let p = posicao {
                        editando = Caderno.fatias(texto).dropFirst(p + 1).first {
                            if case .paragrafo = $0.bloco { true } else { false }
                        }?.id ?? editando
                    }
                    descendoDoTitulo = true
                    aoMudar()
                    return
                }
                // saída da lista (double-Enter): o continuar removeu o
                // marcador e deixou "\n" à cauda — o cursor desce para o
                // parágrafo seguinte, como no título
                if case .itens = fatia.bloco, case .paragrafo(let t) = bloco, t.hasSuffix("\n") {
                    let posicao = fatias.firstIndex { $0.id == fatia.id }
                    texto = Caderno.aplicar(fatias, id: fatia.id, novo: t)
                    if let p = posicao {
                        editando = Caderno.fatias(texto).dropFirst(p + 1).first {
                            if case .paragrafo = $0.bloco { true } else { false }
                        }?.id ?? editando
                    }
                    descendoDoTitulo = true
                    aoMudar()
                    return
                }
                // a primeira tecla no corpo confirma a adoção do foco: a
                // flag da descida já cumpriu o papel e não pode sobrar armada
                // (sobrando, o rearme brigaria com a próxima dispensa do teclado)
                descendoDoTitulo = false
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
            // vestir a forma NÃO expulsa quem escreve. Com texto na linha, o
            // editor fechava (editando = nil), o teclado descia junto e a régua
            // ia com ele: o autor tocava VERSO e perdia a escrita. A prosa veste
            // ao SOLTAR o teclado, não ao formatar.
            abrirUltimo(de: papel)
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
            // o id carrega o papel ("paragrafo:0" -> "recipiente:0"), então o
            // bloco vestido é reencontrado pela POSIÇÃO, não pelo id antigo
            let posicao = fatias.firstIndex { $0.id == alvo.id }
            texto = Caderno.aplicar(fatias, id: alvo.id, bloco: bloco(de: papel, texto: visivel))
            let novas = Caderno.fatias(texto)
            editando = vazio
                ? alvo.id
                : posicao.flatMap { novas.indices.contains($0) ? novas[$0].id : nil } ?? novas.last?.id
        }
    }

    private func insereNovo(_ papel: PapelForma) -> Bool {
        switch papel.gesto {
        case .codigo, .tabela, .divisoria: true
        default: false
        }
    }

    private func bloco(de papel: PapelForma, texto: String) -> BlocoCaderno {
        Caderno.bloco(de: papel, texto: texto)
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
