import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct IntercambioTrabalhoView: View {
    let oficina: OficinaTrabalho
    let permiteImportar: Bool
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var corpo
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var importar = false
    @State private var exportar = false
    @State private var arquivo: ArquivoMarkdownTrabalho?
    @State private var preview: IntercambioTrabalho.Preview?
    @State private var recado: String?
    @State private var lendo = false
    @State private var operacao = UUID()
    @State private var tentarGuardar = false
    @State private var importacaoPendenteID: UUID?

    /// A âncora do cartão de revisão. O arquivo volta do seletor e o cartão
    /// nasce ABAIXO DA DOBRA: sem trazer a tela até ele, a tela que o autor
    /// deixou e a tela para a qual ele volta são o mesmo pixel.
    private static let ancoraDaRevisao = "trabalho-intercambio-revisao"

    /// O começo de cada lado do conflito: as duas têm de caber no mesmo olhar.
    /// Em corpo de acessibilidade cada linha ocupa muito mais altura e um
    /// cartão sozinho toma a tela — então o começo encurta para que a
    /// comparação, que é a razão do desenho, sobreviva ao tamanho grande.
    private var linhasDoConflito: Int { corpo.isAccessibilitySize ? 4 : 12 }

    /// Quanto do trecho comum cabe antes da divergência. Em AX5 as quatro
    /// linhas levam pouco mais de dez caracteres cada: com o contexto do corpo
    /// normal, ele sozinho preenche a janela e os dois cartões voltam a exibir
    /// a mesma cadeia — o defeito que o recorte existe para matar.
    private var contextoDoConflito: Int { corpo.isAccessibilitySize ? 12 : IntercambioTrabalho.contextoDaDiferenca }

    private var permitido: Bool { AcessoTrabalho.permitido(oficina.trabalho, no: context) }

    /// O que esta tela tem em mãos. O selo da origem recolhe pelo caminho da
    /// Oficina, que é onde toda rota do Trabalho revalida o acesso.
    private var material: IntercambioTrabalho.Material {
        // `lendo` também é material em mãos: o arquivo já foi escolhido e está
        // sendo lido. Sem isto o selo caindo nessa janela não registra nada.
        if preview != nil || lendo { .revisao } else if arquivo != nil { .exportacao } else if importar { .seletor } else { .nenhum }
    }

    var body: some View {
        DisclosureGroup("Editar com outras ferramentas") {
            // O proxy é do ScrollView da folha do Trabalho: o ScrollViewReader
            // não cria rolagem, só dá acesso à que já envolve esta tela.
            ScrollViewReader { rolagem in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Exporte a versão em Markdown e traga o arquivo editado de volta. O histórico permanece no Traço.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    acao("Exportar versão em Markdown", id: "trabalho-exportar-md",
                         impedimento: impedimentoDeExportar) { prepararExportacao() }
                    acao("Importar versão de arquivo", id: "trabalho-importar-md",
                         impedimento: impedimentoDeImportar) { importar = true }
                    if lendo { ProgressView("Lendo arquivo…") }
                    if let recado { desfecho(recado) }
                    // A versão já está aqui; guardar de novo confirma a MESMA, sem
                    // pedir outro arquivo e sem criar uma segunda cópia.
                    if tentarGuardar {
                        acao("Tentar guardar de novo", id: "trabalho-intercambio-tentar-guardar",
                             impedimento: permitido ? nil : IntercambioTrabalho.Desfecho.semAcesso.linha) { retentar() }
                    }
                    if permitido, let preview {
                        revisao(preview)
                            .id(Self.ancoraDaRevisao)
                            .transition(Tema.transicao(.move(edge: .top).combined(with: .opacity),
                                                       reduzido: reduceMotion))
                    }
                }
                .padding(.top, 8)
                .onChange(of: preview?.id) { _, novo in
                    guard novo != nil else { return }
                    trazerARevisaoParaATela(rolagem)
                }
            }
        }
        .fileImporter(isPresented: $importar,
                      allowedContentTypes: [.plainText, UTType(filenameExtension: "md") ?? .plainText]) { resultado in
            switch resultado {
            case .success(let url): ler(url)
            case .failure(let erro): anunciar(erro.localizedDescription)
            }
        }
        .fileExporter(isPresented: $exportar, document: arquivo,
                      contentType: .plainText, defaultFilename: "traco-versao.md") { resultado in
            switch resultado {
            case .success: anunciar("Arquivo exportado. Esta cópia externa não será alterada se você proteger o trabalho depois.")
            case .failure(let erro): anunciar("Não consegui exportar: \(erro.localizedDescription)")
            }
            arquivo = nil
        }
        .onChange(of: material, initial: true) { _, novo in oficina.intercambioAberto = novo }
        .onDisappear {
            operacao = UUID()
            oficina.intercambioAberto = .nenhum
        }
        .onChange(of: oficina.salvo) { _, salvo in
            if salvo, let id = importacaoPendenteID,
               oficina.documento.artefatos.contains(where: { $0.id == id }) {
                fecharRevisao()
                importacaoPendenteID = nil
                tentarGuardar = false
                anunciar(IntercambioTrabalho.Desfecho.confirmada.linha)
            }
        }
    }

    // MARK: - Bloqueio: nenhuma ação desta tela some (padrão da volta 18)

    /// A ação bloqueada continua cápsula, com o alvo de 44 e o contraste que
    /// tinha. `.disabled()` aqui não recuava nada — `AcaoTrabalhoStyle` nunca
    /// leu `isEnabled` —, e o estilo deixa de existir na volta 18, que resolveu
    /// a mesma doença na raiz: no lugar do desabilitado, o motivo fica ao lado
    /// e no `accessibilityHint`, e tocar diz o que falta em vez de não fazer
    /// nada. O obstáculo destas três mora na folha do Trabalho, acima desta
    /// tela: aqui ele é dito ao lado, MOSTRADO na linha de desfecho ao
    /// toque e anunciado — não engolido.
    private func acao(_ titulo: String, id: String, impedimento: String?,
                      principal: Bool = false, _ fazer: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Pilula(titulo, forma: principal ? .larga : .filtro, selecionada: principal) {
                // O motivo já está escrito ao lado, colado na cápsula. Tocar
                // tem de RESPONDER, não só anunciar: `Announcement` é canal do
                // VoiceOver, e quem varre a tela com Controle Assistivo sem
                // VoiceOver pousaria num controle que aceita ativação e não
                // muda um pixel. `anunciar` põe o impedimento na linha de
                // desfecho e fala — as duas pessoas recebem a resposta.
                if let impedimento { anunciar(impedimento) }
                else { fazer() }
            }
            .accessibilityIdentifier(id)
            .accessibilityHint(impedimento ?? "")
            if let impedimento {
                Text(impedimento).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("\(id)-travado")
            }
        }
    }

    private var impedimentoDeExportar: String? {
        if !permitido { IntercambioTrabalho.Desfecho.semAcesso.linha }
        else if oficina.documento.versaoAtual == nil { "Guarde uma versão em Markdown antes de exportar." }
        else if !oficina.salvo { "Guarde as alterações deste trabalho antes de exportar." }
        else { nil }
    }

    private var impedimentoDeImportar: String? {
        if !permitido { IntercambioTrabalho.Desfecho.semAcesso.linha }
        else if lendo { "Estou lendo o arquivo anterior. Espere esta leitura terminar." }
        else if !permiteImportar || !oficina.salvo { "Guarde a intenção ou a versão em edição antes de importar." }
        else { nil }
    }

    // MARK: - O que a tela diz quando algo acontece

    /// A linha de desfecho não é instrução fixa: é o resultado do ato mais
    /// consequente desta tela. Ganha o degrau de superfície e a tinta cheia
    /// para não se confundir com as duas frases cinzas do painel, e é falada,
    /// porque para quem ouve o botão sob o foco some e a confirmação pode nunca
    /// ser dita.
    private func desfecho(_ texto: String) -> some View {
        Text(texto)
            .font(Tema.meta).foregroundStyle(Tema.tinta)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cartao(.campo)
            .accessibilityIdentifier("trabalho-intercambio-recado")
            .transition(.opacity)
    }

    private func anunciar(_ linha: String) {
        withAnimation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media),
                                     reduzido: reduceMotion)) {
            recado = linha
        }
        AccessibilityNotification.Announcement(linha).post()
    }

    private func trazerARevisaoParaATela(_ rolagem: ScrollViewProxy) {
        Task {
            await Task.yield()
            withAnimation(Tema.movimento(.deslocamento, Tema.Mola.camada, reduzido: reduceMotion)) {
                rolagem.scrollTo(Self.ancoraDaRevisao, anchor: .top)
            }
            AccessibilityNotification.Announcement("Arquivo recebido. A revisão está abaixo.").post()
        }
    }

    /// Sair da revisão é escolha com desfecho: some o cartão E se diz o que
    /// aconteceu com o arquivo. Os dois botões que fecham passam por aqui.
    private func manter() {
        fecharRevisao()
        anunciar(IntercambioTrabalho.Desfecho.mantida.linha)
    }

    private func fecharRevisao() {
        withAnimation(Tema.movimento(.deslocamento, Tema.Mola.camada, reduzido: reduceMotion)) {
            preview = nil
        }
    }

    private func revisao(_ p: IntercambioTrabalho.Preview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Revisar arquivo recebido").font(Tema.secaoNota)
            Text(IntercambioTrabalho.descricaoDaBase(p, em: oficina.documento)).font(Tema.meta)
            if let intencao = p.intencaoDaBaseID, intencao != p.intencaoVigenteID {
                Text("A intenção mudou desde essa base. A nova versão continuará ligada à intenção anterior; as ações e versões atuais serão preservadas.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            if let conflito = IntercambioTrabalho.conflito(p, em: oficina.documento,
                                                          contexto: contextoDoConflito) {
                asDuasVersoes(conflito, p)
            } else {
                Text(p.motivo ?? "Arquivo externo; a autoria não foi verificada.")
                    .font(Tema.meta)
                trecho(p.texto)
                // Sem conteúdo novo não há decisão: a mutação recusaria e a
                // tela teria pedido uma escolha sem efeito.
                if p.estado != .incompativel, !IntercambioTrabalho.jaGuardado(p, em: oficina.documento) {
                    acao("Guardar como nova versão externa", id: "trabalho-confirmar-importacao",
                         impedimento: impedimentoDeGuardar, principal: true) { aplicar(p) }
                }
                Button("Fechar revisão") { manter() }
                    .buttonStyle(.compacto)
                    .accessibilityIdentifier("trabalho-intercambio-fechar")
            }
        }
        .padding(12)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
    }

    private var impedimentoDeGuardar: String? {
        if !permiteImportar || !oficina.salvo { "Guarde a intenção ou a versão em edição antes de importar." }
        else { nil }
    }

    /// As duas pontas mudaram: o autor lê as duas e escolhe. Nenhuma escolha
    /// sobrescreve — guardar o arquivo é criar versão nova sobre a base dele.
    @ViewBuilder
    private func asDuasVersoes(_ c: IntercambioTrabalho.Conflito,
                               _ p: IntercambioTrabalho.Preview) -> some View {
        Text(c.tituloAtual).rotulo(Tema.tintaSuave)
        Text(verbatim: c.textoAtual)
            .font(Tema.corpo).lineLimit(linhasDoConflito).textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cartao(.campo)
            .accessibilityIdentifier("trabalho-conflito-atual")
        Text(c.tituloArquivo).rotulo(Tema.tintaSuave)
        Text(verbatim: c.textoArquivo)
            .font(Tema.corpo).lineLimit(linhasDoConflito).textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cartao(.campo)
            .accessibilityIdentifier("trabalho-conflito-arquivo")
        // Duas informações de naturezas diferentes, duas linhas: onde a prévia
        // começou, e a garantia de que nada se perde — que é a resposta à única
        // pergunta que importa aqui.
        Text(c.ressalva)
            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            .accessibilityIdentifier("trabalho-conflito-ressalva")
        Text(c.consequencia).font(Tema.meta).foregroundStyle(Tema.tinta)
        acao("Guardar o arquivo como nova versão", id: "trabalho-confirmar-importacao",
             impedimento: impedimentoDeGuardar, principal: true) { aplicar(p) }
        // Botao.swift: a secundária NÃO é âmbar — duas saídas âmbar empatam em
        // peso e o olho não sabe qual é o caminho.
        Button("Manter só a versão atual") { manter() }
            .buttonStyle(.compacto)
            .accessibilityIdentifier("trabalho-conflito-manter")
    }

    private func trecho(_ texto: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: String(texto.prefix(IntercambioTrabalho.limitePrevia)))
                .font(Tema.corpo).textSelection(.enabled)
            if texto.count > IntercambioTrabalho.limitePrevia {
                Text("Prévia parcial. A importação preserva o texto completo do arquivo.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
        }
    }

    private func prepararExportacao() {
        guard oficina.verificarAcesso(), oficina.salvo else { return }
        do {
            arquivo = .init(dados: try IntercambioTrabalho.exportar(oficina.documento))
            exportar = true
        } catch { anunciar(erroDescricao(error)) }
    }

    private func ler(_ url: URL) {
        guard oficina.verificarAcesso(), oficina.salvo, permiteImportar else { return }
        let id = UUID()
        operacao = id
        lendo = true
        preview = nil
        Task {
            let resultado = await Task.detached {
                Result { try LeituraMarkdownTrabalho.ler(url, limite: IntercambioTrabalho.limiteBytes) }
            }.value
            guard operacao == id else { return }
            lendo = false
            guard oficina.verificarAcesso(), permiteImportar else { return }
            do {
                let lido = try IntercambioTrabalho.preparar(resultado.get(), para: oficina.documento)
                withAnimation(Tema.movimento(.deslocamento, Tema.Mola.camada, reduzido: reduceMotion)) {
                    preview = lido
                    recado = nil
                }
                tentarGuardar = false
            } catch { anunciar(erroDescricao(error)) }
        }
    }

    private func aplicar(_ p: IntercambioTrabalho.Preview) {
        guard oficina.verificarAcesso(), oficina.salvo, permiteImportar else { return }
        var mudou = false
        let guardou = oficina.alterar {
            mudou = try $0.aplicarVersaoExterna(p, confirmarBaseAntiga: p.estado == .baseAntiga)
        }
        let desfecho = IntercambioTrabalho.Desfecho.de(
            mudou: mudou, guardou: guardou, acesso: oficina.acesso.permitido,
            recusa: oficina.recusaDoCommit)
        tentarGuardar = desfecho.ofereceTentarGuardar
        // A versão candidata já está na memória da Oficina: o pendente é o
        // commit, não outra importação.
        importacaoPendenteID = desfecho.ofereceTentarGuardar ? oficina.documento.versaoAtual?.id : nil
        if !desfecho.mantemRevisao { fecharRevisao() }
        anunciar(desfecho.linha)
    }

    private func retentar() {
        guard oficina.verificarAcesso() else { return }
        let guardou = oficina.guardar()
        let desfecho: IntercambioTrabalho.Desfecho = guardou ? .confirmada
            : .de(mudou: true, guardou: false, acesso: oficina.acesso.permitido,
                  recusa: oficina.recusaDoCommit)
        // Só o disco merece outra tentativa. Base divergente recusaria de novo:
        // o botão sai e a linha diz o que fazer.
        tentarGuardar = desfecho.ofereceTentarGuardar
        if guardou { importacaoPendenteID = nil }
        anunciar(desfecho.linha)
    }

    private func erroDescricao(_ erro: Error) -> String {
        "Não consegui usar este arquivo: \(erro.localizedDescription). Seu trabalho foi preservado."
    }
}
