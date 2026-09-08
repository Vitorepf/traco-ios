import SwiftData
import SwiftUI
import UIKit

/// O trabalho permanece um documento: versões, ato e retorno, sem um wizard.
///
/// Volta 18 (redesenho): a folha entrou na família do mundo claro — cabeçalho
/// de folha, rótulos de seção, campos em névoa, cartão de papel para a versão.
/// A ordem de leitura passou a ser a do ciclo (VISAO-PRODUTO): intenção →
/// apoio → preparar → versão → ato → o que aconteceu → dificuldade. A
/// dificuldade estava ANTES do caminho principal e empurrava a ação primária
/// para fora da primeira tela; o trabalho é que revela o obstáculo, não o
/// contrário. E a decisão de apoio, que morava num disclosure e nunca era
/// oferecida, virou um trilho de três pílulas no caminho.
///
/// A lei de cor desta folha: **carvão avança, âmbar salva**. A cápsula carvão
/// é a ação que produz alguma coisa na seção (preparar, marcar, guardar a
/// tentativa); o âmbar aparece só como saída de um problema (Ajustes,
/// recuperar, tentar de novo); todo o resto é ação compacta em tinta.
struct TrabalhoView: View {
    let trabalho: Trabalho
    var acaoEmFoco: UUID? = nil
    /// O trabalho acabou de nascer da intenção que a pessoa escreveu na tela
    /// anterior: a folha abre com o cursor no pedido (curva-zero, abaixo).
    var pedidoEmFoco = false
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.abrirCalendarioDoTrabalho) private var abrirCalendario
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var tamanhoTexto
    @Query private var notas: [Nota]
    @State private var oficina: OficinaTrabalho?
    @State private var erroDeLeitura: String?
    @State private var rascunhos: [String: String] = [:]
    @State private var limparAposCommit: [String] = []
    /// A gaveta da versão: escrever a primeira e editar a atual nunca convivem.
    @State private var editandoVersao = false
    @State private var editandoIntencao = false
    @State private var historicoAberto = false
    @State private var confirmarDescarte = false
    @State private var recuperacao: String?
    @State private var confirmarApagarCopia = false
    @State private var copiaCopiada = false
    @State private var exibicaoSuspensa = false
    @FocusState private var campoEmFoco: String?
    @State private var rolarPara: String?

    /// A chave dos rascunhos em `UserDefaults` — `static` para que fechar e
    /// reabrir a folha seja provável em teste com a chave que o app usa, e
    /// não com uma cópia da string.
    static func chaveRascunho(_ trabalho: UUID) -> String { "trabalho.rascunhos.\(trabalho.uuidString)" }
    private var chaveRascunho: String { Self.chaveRascunho(trabalho.uuid) }
    private var selos: [SeloOrigemTrabalho] { notas.map(SeloOrigemTrabalho.init) }
    private var acesso: AcessoTrabalho.Estado { AcessoTrabalho.estado(trabalho, no: context) }

    var body: some View {
        ScrollViewReader { rolagem in
            ScrollView {
                VStack(alignment: .leading, spacing: Tema.entreSecoes) {
                    if scenePhase != .active {
                        Text("Trabalho").font(Tema.tituloTela).tracking(Tema.trackingTitulo)
                    } else if !acesso.permitido {
                        Text("Trabalho protegido").font(Tema.tituloTela).tracking(Tema.trackingTitulo)
                        Text(acesso.mensagem).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("trabalho-protegido")
                        // ADR 06a: o selo recolhe o intercâmbio em curso e a
                        // tela DIZ o que recolheu. Silêncio aqui é o autor sem
                        // saber se o arquivo entrou ou a cópia saiu.
                        if let recolhido = oficina?.intercambioRecolhido.recolhimento {
                            Text(recolhido).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                                .accessibilityIdentifier("trabalho-intercambio-recolhido")
                        }
                    } else if let oficina {
                        documento(oficina)
                            // a versão que a IA acabou de preparar CHEGA: é a
                            // única entrada com massa desta folha
                            .animation(Tema.movimento(.deslocamento, Tema.Mola.camada, reduzido: reduceMotion),
                                       value: oficina.documento.artefatos.count)
                    } else if let erroDeLeitura {
                        Text(erroDeLeitura).font(Tema.meta).foregroundStyle(Tema.aviso)
                        acaoDeSaida("Tentar abrir novamente") { abrir() }
                    } else {
                        ProgressView("Abrindo trabalho…")
                    }
                }
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .padding(.horizontal, Tema.margem)
                .padding(.top, Tema.entreItens)
                .padding(.bottom, Tema.margem)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            // O cabeçalho fica FORA da rolagem: o documento tem três telas e a
            // saída não pode viajar com ele — a folha recusa o arrasto para
            // baixo (`interactiveDismissDisabled`), então "voltar" é a única
            // porta. Por `safeAreaInset`, e não por um VStack irmão: irmão faz
            // a rolagem propor a largura IDEAL do conteúdo, e em AX5 o
            // documento nasce mais largo que a tela e sangra pelos dois lados.
            .safeAreaInset(edge: .top, spacing: 0) {
                CabecalhoDeFolha(saida: .voltar, aoSair: { voltar() }, prefixo: "trabalho")
                    .padding(.horizontal, Tema.margem)
                    .frame(maxWidth: .infinity)
                    .background(Tema.fundo)
            }
            .background(Tema.fundo)
            .task(id: oficina != nil) {
                guard oficina != nil, acesso.permitido else { return }
                if let acaoEmFoco {
                    await Task.yield()
                    rolagem.scrollTo(acaoEmFoco, anchor: .top)
                } else if pedidoEmFoco, vazio("pedido") {
                    // Curva-zero: o toque no campo do pedido só existia para
                    // revelar o passo seguinte. Quem acabou de escrever a
                    // intenção e tocar "Começar este trabalho" vem dizer o que
                    // quer preparado — a folha já abre com o cursor lá, e a
                    // jornada intenção → versão preparada perde um toque.
                    campoEmFoco = "pedido"
                }
            }
            // O texto que o autor não escreveu começa no alto: sem isto o foco
            // rola para o FIM do campo e ele vê um rabo de frase (V5, P3-b).
            .onChange(of: rolarPara) { _, alvo in
                guard let alvo else { return }
                Task {
                    // ponytail: espera o teclado subir; a rolagem do foco vem
                    // depois da nossa. Se o tempo mudar, é aqui que se calibra.
                    try? await Task.sleep(for: .milliseconds(400))
                    withAnimation(Tema.animacao(Tema.Mola.escala, reduzido: reduceMotion)) {
                        rolagem.scrollTo(alvo, anchor: .top)
                    }
                    rolarPara = nil
                }
            }
        }
        .tint(Tema.ambarTinta)
        .interactiveDismissDisabled()
        .task { if oficina == nil { abrir() } }
        .onChange(of: selos) { _, _ in revalidar() }
        .onChange(of: trabalho.conteudoJSON) { _, _ in revalidar() }
        .onChange(of: scenePhase) { _, fase in
            revalidar()
            if fase == .active, let oficina { Task { await oficina.lerAvisos() } }
        }
        .onDisappear { oficina?.cancelar() }
        .confirmationDialog("Descartar os rascunhos dos campos?", isPresented: $confirmarDescarte) {
            Button("Descartar rascunhos", role: .destructive) { limpar(Array(rascunhos.keys)) }
            Button("Manter", role: .cancel) {}
        } message: {
            Text("As versões, atos e relatos já guardados permanecem. Só os campos ainda em edição serão limpos.")
        }
        .confirmationDialog("Apagar a cópia de recuperação?", isPresented: $confirmarApagarCopia) {
            Button("Apagar cópia", role: .destructive) {
                guard acesso.permitido else { revalidar(); return }
                UserDefaults.standard.removeObject(forKey: chaveRascunho + ".recuperacao")
                recuperacao = nil
            }
            Button("Manter", role: .cancel) {}
        } message: {
            Text("A versão atual do trabalho e os rascunhos dos campos permanecem.")
        }
    }

    /// A ordem do ciclo. O que a pessoa veio fazer primeiro, o obstáculo depois.
    @ViewBuilder private func documento(_ o: OficinaTrabalho) -> some View {
        if let erro = o.erro {
            VStack(alignment: .leading, spacing: 8) {
                Text(erro).font(Tema.meta).foregroundStyle(Tema.aviso)
                    .accessibilityIdentifier("trabalho-erro")
                if !o.salvo {
                    acaoDeSaida("Tentar guardar novamente") { guardar(o) }
                        .accessibilityIdentifier("trabalho-tentar-guardar")
                    acaoDeSaida("Preservar cópia e reabrir a versão atual") { preservarEReabrir(o) }
                }
            }
            .cartao(.campo)
            .id("trabalho-erro")
        }
        intencao(o)
        retomada(o)
        apoio(o)
        producao(o)
        praticar(o)
        if let versao = o.documento.versaoAtual { artefato(versao, oficina: o) }
        IntercambioTrabalhoView(oficina: o, permiteImportar: !edicaoPendente(o))
        atos(o)
        retorno(o)
        dificuldade(o)
        historico(o)
        rodape(o)
    }

    // MARK: - Intenção

    @ViewBuilder private func retomada(_ o: OficinaTrabalho) -> some View {
        if let acao = o.documento.acoes.first(where: { $0.estado == .pendente }) {
            acaoSecundaria("Continuar: \(acao.texto)") {
                campoEmFoco = nil
                rolarPara = "trabalho-atos"
            }
            .accessibilityIdentifier("trabalho-continuar-ato")
        }
        if let retorno = o.documento.evidencias.last {
            VStack(alignment: .leading, spacing: 6) {
                Text("Último retorno · \(retorno.atribuidaA)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                Text(retorno.texto).lineLimit(3)
                acaoSecundaria("Ver retorno e histórico") {
                    campoEmFoco = nil
                    if retorno.tentativa != nil { historicoAberto = true }
                    rolarPara = retorno.tentativa == nil ? "trabalho-retorno" : "trabalho-historico"
                }
            }
            .accessibilityIdentifier("trabalho-retomada")
        }
    }

    private func intencao(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            Text(o.documento.intencaoAtual.texto)
                .font(Tema.tituloTela)
                .tracking(Tema.trackingTitulo)
                .accessibilityAddTraits(.isHeader)
            if !o.documento.intencaoAtual.resultado.isEmpty {
                Text(o.documento.intencaoAtual.resultado)
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            if editandoIntencao {
                campo("O que quero realizar", chave: "intencao", padrao: o.documento.intencaoAtual.texto, exemplo: "Apresentar minha ideia")
                campo("Como reconhecerei o resultado", chave: "resultado", padrao: o.documento.intencaoAtual.resultado, exemplo: "Explicar em um minuto")
                Pilula("Guardar intenção", forma: .larga, selecionada: true) {
                    let texto = rascunhos["intencao"] ?? o.documento.intencaoAtual.texto
                    let resultado = rascunhos["resultado"] ?? o.documento.intencaoAtual.resultado
                    aplicar(o, limpar: ["intencao", "resultado"]) { try $0.reverIntencao(texto, resultado: resultado) }
                    gaveta { editandoIntencao = false }
                }
                .accessibilityIdentifier("trabalho-guardar-intencao")
            } else {
                acaoSecundaria("Rever a intenção") { gaveta { editandoIntencao = true } }
                    .accessibilityIdentifier("trabalho-rever-intencao")
            }
        }
    }

    // MARK: - Apoio: a decisão que morava num disclosure

    /// A divisão de trabalho é escolha contextual e reversível (VISAO-PRODUTO),
    /// e é a decisão que muda o que "Preparar" faz. Fica no caminho, com o
    /// padrão já marcado: ninguém precisa decidir para começar.
    private func apoio(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            secao("Neste trabalho, prefiro")
            // Em tamanho de acessibilidade três cápsulas não cabem lado a
            // lado e a linha empurrava a folha inteira para fora da tela pelos
            // dois lados (visto em AX5, na V9 e aqui). Empilhar preserva as
            // três escolhas visíveis, que é o que a decisão precisa.
            trilhoDoApoio(o)
            .animation(Tema.movimento(.escala, Tema.Mola.escala, reduzido: reduceMotion),
                       value: o.documento.apoio)
            // A frase fala da opção SELECIONADA. Estática, ela dizia
            // "Delegar não exige…" com Praticar e com Combinar marcados: a
            // única ajuda da decisão que muda o resto da tela descrevia a
            // escolha que o autor não fez, encostada nela (G4, achado 2).
            Text(explicacaoDoApoio(o.documento.apoio))
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("trabalho-apoio-explicacao")
            if o.documento.apoio == .combinar { delimitacao(o) }
        }
    }

    @ViewBuilder private func trilhoDoApoio(_ o: OficinaTrabalho) -> some View {
        let pilulas = ForEach(DocumentoTrabalho.Apoio.allCases, id: \.self) { a in
            Pilula(nomeDoApoio(a), forma: .filtro, selecionada: o.documento.apoio == a) {
                aplicar(o) { $0.cancelarPedido(); $0.apoio = a }
            }
            // O `Picker` da V9 anunciava o valor escolhido de graça; o trilho
            // dizia a escolha só por cor, e para o VoiceOver as três pílulas
            // saíam idênticas (`selected:false` nas três). A decisão que muda
            // o que "Preparar" faz não pode ser invisível a quem ouve a tela.
            .accessibilityAddTraits(o.documento.apoio == a ? [.isSelected] : [])
            .accessibilityIdentifier("trabalho-apoio-\(a.rawValue)")
        }
        if tamanhoTexto.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) { pilulas }
        } else {
            HStack(spacing: 8) { pilulas }
        }
    }

    private func nomeDoApoio(_ a: DocumentoTrabalho.Apoio) -> String {
        switch a {
        case .delegar: "Delegar"
        case .praticar: "Praticar"
        case .combinar: "Combinar"
        }
    }

    /// O que a escolha marcada muda, na voz do autor, mais a saída que vale
    /// para as três ("você pode mudar quando quiser" — a única parte da frase
    /// antiga que era verdade nas três).
    private func explicacaoDoApoio(_ a: DocumentoTrabalho.Apoio) -> String {
        switch a {
        case .delegar: "Delegar: a IA prepara a versão inteira; você não precisa aprender a executar tudo. Você pode mudar quando quiser."
        case .praticar: "Praticar: você escreve a tentativa; a IA prepara o exercício e o retorno, nunca a resposta. Você pode mudar quando quiser."
        case .combinar: "Combinar: você exercita o trecho que delimitar abaixo; o resto continua com a IA. Você pode mudar quando quiser."
        }
    }

    private func delimitacao(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            campo("O trecho que eu mesmo vou exercitar", chave: "trecho",
                  padrao: o.documento.trechoExercitado ?? "", exemplo: "As frases em espanhol")
                .accessibilityIdentifier("pratica-trecho")
            acaoSecundaria("Guardar o trecho") {
                guard !faltaCampo("trecho") else { return }
                let texto = rascunhos["trecho"] ?? ""
                aplicar(o, limpar: ["trecho"]) { $0.trechoExercitado = texto }
            }
            .accessibilityHint(vazio("trecho") ? "Escreva o trecho primeiro" : "")
            if !o.documento.praticaPedida {
                Text("Sem esse trecho, combinar entrega o trabalho inteiro: nada aqui vira exercício.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Preparar

    /// Em prática sem conta Grok (decisão b) a seção some: não há botão de IA
    /// a oferecer, e a linha que diz por quê já está em Praticar.
    @ViewBuilder private func producao(_ o: OficinaTrabalho) -> some View {
        if !o.documento.praticaPedida || PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) == nil {
            producaoComIA(o)
        }
    }

    private func producaoComIA(_ o: OficinaTrabalho) -> some View {
        let combinando = o.documento.apoio == .combinar && o.documento.praticaPedida
        return VStack(alignment: .leading, spacing: Tema.entreItens) {
            secao(combinando ? "Preparar entrega e exercício" : o.documento.praticaPedida ? "Preparar um exercício" : "Preparar uma versão")
            campo(combinando ? "O que você quer produzir e praticar?" : o.documento.praticaPedida ? "O que você quer praticar?" : "O que você quer que a IA prepare ou ajuste?",
                  chave: "pedido", exemplo: o.documento.praticaPedida ? "Quero praticar me apresentar em espanhol" : "Prepare uma apresentação curta")
                .accessibilityIdentifier("trabalho-pedido")
            if o.documento.pedidoAtivo != nil {
                ProgressView("A IA está preparando…")
                    .font(Tema.meta)
                    .id("trabalho-preparando")
                    .accessibilityIdentifier("trabalho-preparando")
                acaoSecundaria("Cancelar preparação") { o.cancelar() }
            } else {
                // Nada desabilita aqui: a ação principal desabilitada perdia a
                // cápsula inteira e virava legenda a 1,53:1 (revisão da volta
                // 18). Tocar leva ao que falta — o campo vazio, a edição
                // pendente, a saída do erro —, e o motivo continua escrito
                // abaixo (curva-zero §3).
                let travado = !o.salvo || edicaoPendente(o)
                Pilula(combinando ? "Preparar entrega e exercício" : o.documento.praticaPedida ? "Preparar exercício com IA" : o.documento.versaoAtual == nil ? "Preparar com IA" : "Preparar nova versão com IA",
                       forma: .larga, selecionada: true) {
                    guard !levouAoQueFalta(o, campoObrigatorio: "pedido") else { return }
                    let instrucao = rascunhos["pedido"] ?? ""
                    o.gerar(instrucao, ajuste: Self.causaDoPedidoEscrito(o.documento, instrucao))
                }
                    .accessibilityIdentifier("trabalho-gerar")
                    .accessibilityHint(travado || vazio("pedido") ? motivoDoTravamento(o) : "")
                if travado || vazio("pedido") {
                    Text(motivoDoTravamento(o))
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("trabalho-gerar-travado")
                }
                if let pedido = o.documento.pedidos.last,
                   pedido.estado == .interrompido || pedido.estado == .falhou || pedido.estado == .cancelado {
                    Text("A preparação anterior foi \(pedido.estado == .interrompido ? "interrompida" : pedido.estado == .falhou ? "malsucedida" : "cancelada"). O pedido continua disponível.")
                        .font(Tema.meta).foregroundStyle(Tema.aviso)
                    acaoDeSaida("Retomar esse pedido") { definir("pedido", pedido.instrucao) }
                } else if let pedido = o.documento.pedidos.last, pedido.estado == .praticaIndisponivel {
                    // O porquê já está na seção Praticar; aqui só a saída.
                    acaoDeSaida("Retomar esse pedido") { definir("pedido", pedido.instrucao) }
                }
            }
            if o.documento.versaoAtual == nil {
                if editandoVersao {
                    campo("Sua versão", chave: "versao")
                    acaoSecundaria("Guardar minha versão") { guardarVersao(o) }
                        .accessibilityHint(vazio("versao") ? "Escreva a versão primeiro" : "")
                } else {
                    acaoSecundaria("Escrever minha própria versão") { gaveta { editandoVersao = true } }
                }
            }
        }
    }

    /// O motivo é lido na MESMA ordem em que o guarda desvia
    /// (`levouAoQueFalta`). Antes a frase começava pela edição pendente e o
    /// toque ia para o erro de salvamento: com os dois estados juntos, a folha
    /// nomeava um obstáculo e levava a outro.
    private func motivoDoTravamento(_ o: OficinaTrabalho) -> String {
        if !o.salvo { "Guarde as alterações deste trabalho antes de pedir uma preparação." }
        else if edicaoPendente(o) { "Guarde a intenção ou a versão que está editando antes de pedir uma nova preparação." }
        else { "Escreva acima o que a IA deve preparar." }
    }

    // MARK: - ADR 05r: praticar

    /// A prática, na leitura de cima para baixo: pedido → material → tentativa
    /// → feedback. Ela mora DEPOIS de "Preparar" porque é o pedido que a
    /// produz; na V9 o exercício aparecia acima do campo que o pediu.
    /// A tentativa existe SEM exercício e SEM conta: a prática é da pessoa.
    @ViewBuilder private func praticar(_ o: OficinaTrabalho) -> some View {
        if o.documento.apoio != .delegar {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                secao("Praticar")
                if o.documento.praticaPedida {
                    let versao = o.documento.versaoAtual
                    let pratica = versao?.pratica
                    if let versao, let pratica {
                        exercicio(pratica, produtor: versao.produtor, oficina: o)
                    } else if let linha = PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) {
                        // Uma linha só: a última recusa, nunca uma pilha.
                        Text(linha).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("pratica-sem-provedor")
                    } else if o.documento.praticaIndisponivel {
                        Text(PraticaTrabalho.preparacaoIndisponivel).font(Tema.meta).foregroundStyle(Tema.aviso)
                            .accessibilityIdentifier("pratica-preparacao-indisponivel")
                    } else {
                        Text("Nenhum exercício preparado ainda. Escreva acima o que você quer praticar e toque em preparar: a IA prepara enunciado, exemplo e critérios; a tentativa é sua.")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("pratica-sem-exercicio")
                    }
                    tentativaQueGerou(o)
                    // ADR 08j: a causa é núcleo obrigatório; quando ela não
                    // coube, a folha diz isso onde o exercício está — em vez de
                    // o exercício simplesmente não mudar sem explicação.
                    if o.documento.ajusteIndisponivel {
                        Text(PraticaTrabalho.ajusteIndisponivel).font(Tema.meta).foregroundStyle(Tema.aviso)
                            .accessibilityIdentifier("pratica-ajuste-indisponivel")
                    }
                    tentativas(artefatoID: pratica == nil ? nil : versao?.id, pratica: pratica, oficina: o)
                }
            }
        }
    }

    /// ADR 08j: a tentativa que causou a versão vigente pertence à versão
    /// ANTERIOR, e a lista de tentativas é filtrada pela versão atual — sem
    /// isto ela some da tela no instante em que passa a importar, levando
    /// junto a leitura e a rota de contestá-la. Fica aqui, em leitura, com o
    /// feedback e o "Não foi isso que eu errei"; a tentativa nova continua
    /// sendo a da versão de agora, e nasce em branco.
    @ViewBuilder private func tentativaQueGerou(_ o: OficinaTrabalho) -> some View {
        if let versao = o.documento.versaoAtual, let aj = o.documento.ajuste(de: versao),
           let id = aj.evidenciaID, let e = o.documento.evidencias.first(where: { $0.id == id }) {
            Text("A tentativa que gerou esta versão").rotulo(Tema.tintaSuave)
                .accessibilityIdentifier("pratica-tentativa-da-causa")
            tentativa(e, pratica: o.documento.artefatos.first { $0.id == e.artefatoID }?.pratica,
                      ultima: false, oficina: o)
        }
    }

    /// P3-K: quem praticou e depois mudou o apoio para delegar não perde de
    /// vista o que escreveu. Só leitura: escrever outra pede apoio praticar.
    @ViewBuilder private func tentativasGuardadas(_ o: OficinaTrabalho) -> some View {
        let guardadas = o.documento.evidencias.filter { $0.tentativa != nil }
        if !guardadas.isEmpty {
            Text("Tentativas (\(guardadas.count))").font(Tema.chrome.weight(.semibold))
            Text("Escritas quando o apoio era praticar. Para escrever outra, volte o apoio para praticar.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            ForEach(guardadas) { e in
                tentativa(e, pratica: o.documento.artefatos.first { $0.id == e.artefatoID }?.pratica,
                          ultima: false, oficina: o)
            }
        }
    }

    /// O gargalo, corrigível. A pergunta aceita contexto, recursos, acesso ou
    /// divisão do trabalho — não só habilidade. Só a pessoa confirma ou
    /// contesta, e confirmar é concordar neste contexto, não ser avaliada.
    /// Mora no fim: é o trabalho que revela o obstáculo (VISAO-PRODUTO).
    private func dificuldade(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            secao("Dificuldade")
            campo("O que está dificultando isso?", chave: "dificuldade",
                  exemplo: "Pode ser contexto, recursos, acesso ou divisão do trabalho")
                .accessibilityIdentifier("pratica-dificuldade")
            acaoSecundaria("Guardar esta dificuldade") {
                guard !faltaCampo("dificuldade") else { return }
                let texto = rascunhos["dificuldade"] ?? ""
                aplicar(o, limpar: ["dificuldade"]) { try $0.proporHipotese(texto, propostaPor: "Você") }
            }
            .accessibilityHint(vazio("dificuldade") ? "Escreva a dificuldade primeiro" : "")
            .accessibilityIdentifier("pratica-guardar-dificuldade")
            ForEach(o.documento.hipoteses) { h in
                VStack(alignment: .leading, spacing: 6) {
                    Text(h.texto)
                    Text("Proposta por \(h.propostaPor ?? "autoria desconhecida") · \(PraticaTrabalho.estado(h.estado))\(avaliacao(h))")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    if let motivo = h.motivoAvaliacao {
                        Text("Seu motivo: \(motivo)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    }
                    let chave = "motivo-\(h.id.uuidString)"
                    campo("Por quê? (opcional)", chave: chave, exemplo: "O que te faz dizer isso")
                    acaoSecundaria("Faz sentido neste contexto") { avaliar(h, .confirmada, chave: chave, oficina: o) }
                        .accessibilityIdentifier("pratica-confirmar-hipotese")
                    acaoSecundaria("Não é essa a dificuldade") { avaliar(h, .contestada, chave: chave, oficina: o) }
                        .accessibilityIdentifier("pratica-contestar-hipotese")
                }
                .cartao(.campo)
            }
            if !o.documento.hipoteses.isEmpty {
                Text("Concordar aqui é concordar neste contexto. Não é o app avaliando você, nem prova de que você aprendeu.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            if o.documento.apoio == .delegar { tentativasGuardadas(o) }
        }
    }

    private func avaliacao(_ h: DocumentoTrabalho.Hipotese) -> String {
        guard let quando = h.avaliadaEm else { return "" }
        return " · por \(h.avaliadaPor ?? "você") em \(quando.formatted(date: .abbreviated, time: .shortened))"
    }

    private func avaliar(_ h: DocumentoTrabalho.Hipotese, _ estado: DocumentoTrabalho.EstadoHipotese,
                         chave: String, oficina o: OficinaTrabalho) {
        let motivo = rascunhos[chave]
        aplicar(o, limpar: [chave]) { try $0.avaliarHipotese(h.id, estado: estado, motivo: motivo) }
    }

    /// ADR 08j: UMA seção diz o que mudou e por quê, e ela mora no alto do
    /// próprio exercício — quem abre o documento lê a mudança antes da tarefa.
    /// A descrição é do modelo; a origem e o motivo são do app, com os vínculos
    /// que ele conhece. Não repete o histórico e não declara aprendizagem.
    @ViewBuilder private func nestaVersao(_ p: DocumentoTrabalho.Pratica, _ o: OficinaTrabalho) -> some View {
        if let mudanca = p.mudanca, let versao = o.documento.versaoAtual,
           let aj = o.documento.ajuste(de: versao) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nesta versão").rotulo(Tema.tintaSuave)
                Text(mudanca).accessibilityIdentifier("pratica-mudanca")
                Text("\(PraticaTrabalho.origemDoAjuste(aj, tentativaEm: aj.evidenciaID.flatMap { id in o.documento.evidencias.first { $0.id == id }?.data })) \(aj.motivo)")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("pratica-motivo-do-ajuste")
                Text("As versões anteriores e a sua tentativa continuam guardadas. Reescrever o exercício não é dizer que você aprendeu.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func exercicio(_ p: DocumentoTrabalho.Pratica, produtor: String, oficina o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            Text("Exercício: \(p.capacidade)").font(Tema.chrome.weight(.semibold))
            Text("Preparado por \(produtor)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            nestaVersao(p, o)
            // O modelo às vezes repete a capacidade na situação: não mostrar duas vezes.
            if p.situacao != p.capacidade {
                Text("Situação: \(p.situacao)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            Text("O que fazer").rotulo(Tema.tintaSuave)
            Text(p.enunciado).textSelection(.enabled)
                .accessibilityIdentifier("pratica-enunciado")
            Text("Exemplo resolvido, de outro caso — não é a sua resposta").rotulo(Tema.tintaSuave)
            Text(p.exemplo).textSelection(.enabled)
                .accessibilityIdentifier("pratica-exemplo")
            Text("Como conferir o seu desempenho").rotulo(Tema.tintaSuave)
            ForEach(p.criterios) { c in Text("• \(c.texto)").font(Tema.meta) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // Névoa: material da IA em superfície baixa; a entrada da pessoa fica em branco.
        .cartao(.campo)
    }

    /// O campo começa VAZIO e a IA nunca o preenche. Guardar acrescenta uma
    /// tentativa ligada à anterior; a primeira nunca é sobrescrita, e guardar
    /// não marca ação executada nem capacidade adquirida. Sem exercício
    /// (`artefatoID` nil) a tentativa é prática por conta própria, sem feedback.
    private func tentativas(artefatoID: UUID?, pratica p: DocumentoTrabalho.Pratica?,
                            oficina o: OficinaTrabalho) -> some View {
        let guardadas = o.documento.tentativas(doArtefato: artefatoID)
        return VStack(alignment: .leading, spacing: Tema.entreItens) {
            campo("Minha tentativa", chave: "tentativa", exemplo: "Escreva aqui a sua resposta")
                // A tentativa é o texto da pessoa, no idioma que ela pratica: o
                // corretor do sistema reescrevendo-a é o que a ADR proíbe à IA.
                .autocorrectionDisabled()
                .accessibilityIdentifier("pratica-tentativa")
            campo("Que apoio você usou?", chave: "apoio-usado", exemplo: "Ex.: olhei o exemplo")
                .accessibilityIdentifier("pratica-apoio-usado")
            Pilula(guardadas.isEmpty ? "Guardar minha tentativa" : "Guardar esta nova tentativa",
                   forma: .larga, selecionada: true) {
                guard !levouAoObstaculo(o), !faltaCampo("tentativa", "apoio-usado") else { return }
                let texto = rascunhos["tentativa"] ?? "", apoio = rascunhos["apoio-usado"] ?? ""
                guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                if o.guardarTentativa(texto, apoioUtilizado: apoio, artefatoID: artefatoID,
                                     anteriorID: guardadas.last?.id) {
                    limpar(["tentativa", "apoio-usado"])
                }
            }
            .accessibilityHint(vazio("tentativa") || vazio("apoio-usado") ? "Escreva a tentativa e o apoio que usou" : "")
            .accessibilityIdentifier("pratica-guardar-tentativa")
            Text("Guardar preserva a sua resposta como sua. Não marca a ação como realizada nem declara capacidade adquirida.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            if !guardadas.isEmpty {
                Text("Tentativas (\(guardadas.count))").font(Tema.chrome.weight(.semibold))
                ForEach(guardadas) { e in tentativa(e, pratica: p, ultima: e.id == o.documento.tentativaAtual?.id, oficina: o) }
            }
        }
    }

    @ViewBuilder private func tentativa(_ e: DocumentoTrabalho.Evidencia, pratica p: DocumentoTrabalho.Pratica?,
                                        ultima: Bool, oficina o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sua tentativa · \(e.data.formatted(date: .abbreviated, time: .shortened))")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            Text(e.texto).textSelection(.enabled)
                .accessibilityIdentifier("pratica-tentativa-guardada")
            Text("Apoio usado: \(e.tentativa?.apoioUtilizado ?? "não registrado")")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            if let p {
                ForEach(e.tentativa?.conferencias ?? []) { c in
                    feedback(c, pratica: p, evidenciaID: e.id, oficina: o)
                }
            }
            if ultima { botaoDoFeedback(e, comExercicio: p != nil, oficina: o) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cartao(.papel)
    }

    /// Decisão (b), como em 05q: "Conferir minha tentativa" só com conta Grok.
    /// Sem exercício a linha de recusa já está no material acima. Com exercício
    /// e a conta desligada depois, o cartão ocupa o lugar dela: a linha entra
    /// aqui, no lugar do botão (P3-I). "Nova tentativa" é da pessoa e fica sempre.
    @ViewBuilder private func botaoDoFeedback(_ e: DocumentoTrabalho.Evidencia, comExercicio: Bool,
                                              oficina o: OficinaTrabalho) -> some View {
        if !comExercicio {
            botaoNovaTentativa
        } else if let linha = PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) {
            Text(linha).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("pratica-sem-provedor")
            botaoNovaTentativa
        } else if o.conferindoTentativa {
            ProgressView("A IA está conferindo sua tentativa…").font(Tema.meta)
                .accessibilityIdentifier("pratica-conferindo")
        } else if o.adaptando {
            // Duas leituras, dois progressos: quem tocou "conferir e adaptar"
            // espera outra coisa de quem tocou só "conferir".
            ProgressView("A IA está conferindo e, se a leitura sustentar, adaptando o exercício…").font(Tema.meta)
                .id("pratica-adaptando")
                .accessibilityIdentifier("pratica-adaptando")
        } else {
            acaoSecundaria("Conferir minha tentativa") {
                guard !levouAoObstaculo(o), acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                o.conferirTentativa(e.id)
            }
            .accessibilityIdentifier("pratica-conferir-tentativa")
            // ADR 08j: o ato do laço. Ler e, SÓ se a leitura sustentar, gerar a
            // versão seguinte com a causa registrada. É explícito porque
            // "Conferir minha tentativa" já promete uma operação por toque.
            acaoSecundaria("Conferir e adaptar o exercício") {
                guard !levouAoQueFalta(o, campoObrigatorio: nil), acesso.permitido,
                      o.verificarAcesso() else { revalidar(); return }
                o.conferirEAdaptar(e.id)
            }
            .accessibilityIdentifier("pratica-conferir-e-adaptar")
            botaoNovaTentativa
            // A leitura saiu e não sustentou reescrita: dizer isso é o contrato.
            if let semAjuste = o.leituraSemAjuste {
                Text(semAjuste).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("pratica-leitura-sem-ajuste")
            }
        }
    }

    /// ADR 08k: o pedido que a PESSOA escreve para reescrever o exercício
    /// também registra a sua causa — e a causa é o que ela escreveu, não uma
    /// frase enlatada. Antes disso, a única via do `pedidoDoAutor` era a
    /// cápsula "Adaptar o próximo exercício", uma quarta ação empilhada
    /// disputando com "Conferir", "Conferir e adaptar" e "Nova tentativa"
    /// (Simplicidade 7 da revisão): retirá-la sem isto teria apagado a via.
    ///
    /// Nenhuma evidência é apontada: a pessoa escreveu um pedido, não disse a
    /// qual tentativa ele responde, e deduzir isso seria inventar causalidade.
    /// Fora da prática, ou sem exercício vigente, não há ajuste a explicar —
    /// preparar não é ajustar, e a primeira versão não nasce de nenhuma.
    static func causaDoPedidoEscrito(_ d: DocumentoTrabalho, _ instrucao: String) -> DocumentoTrabalho.Ajuste? {
        let limpo = instrucao.trimmingCharacters(in: .whitespacesAndNewlines)
        guard d.praticaPedida, d.versaoAtual?.pratica != nil, !limpo.isEmpty else { return nil }
        return .init(gatilho: .pedidoDoAutor, motivo: String(limpo.prefix(PraticaTrabalho.Limite.motivoDoAjuste)))
    }

    private var botaoNovaTentativa: some View {
        acaoSecundaria("Nova tentativa") {
            definir("tentativa", "")
            definir("apoio-usado", "")
            campoEmFoco = "tentativa"
            rolarPara = "tentativa"
        }
        .accessibilityIdentifier("pratica-nova-tentativa")
    }

    private func feedback(_ c: DocumentoTrabalho.ConferenciaTentativa, pratica p: DocumentoTrabalho.Pratica,
                          evidenciaID: UUID, oficina o: OficinaTrabalho) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                if let motivo = c.motivo {
                    Text(motivo).font(Tema.meta).foregroundStyle(Tema.aviso)
                }
                ForEach(c.resultados) { r in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.criterios.first { $0.id == r.criterioID }?.texto ?? "Critério removido")
                            .font(Tema.chrome.weight(.semibold))
                        Text(situacao(r.situacao)).font(Tema.meta)
                            .foregroundStyle(r.situacao == .divergencia ? Tema.aviso : Tema.tintaSuave)
                        if !r.trechoDaTentativa.isEmpty {
                            Text("Na sua tentativa: “\(r.trechoDaTentativa)”")
                                .font(Tema.meta).foregroundStyle(Tema.tintaSuave).textSelection(.enabled)
                        }
                        Text(r.observacao).font(Tema.meta)
                        // O convite é do APP: a IA não pede nada e não dá a resposta.
                        if r.situacao == .divergencia {
                            Text(PraticaTrabalho.convite).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        }
                    }
                }
                Text("Lido por \(c.executor) em \(c.data.formatted(date: .abbreviated, time: .shortened)). Lê a sua tentativa contra os critérios deste exercício; não avalia você, não corrige o texto e não prova aprendizagem.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                contestacao(c, evidenciaID: evidenciaID, oficina: o)
            }.padding(.top, 8)
        } label: {
            Text(PraticaTrabalho.linha(c))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(Tema.meta)
        .tint(Tema.tintaSuave)
        .accessibilityIdentifier("pratica-feedback")
    }

    /// ADR 08j: a correção do dono sobre a LEITURA. Ele diz o que ela entendeu
    /// errado; a leitura fica no registro — a história não se apaga — e para de
    /// orientar os ajustes seguintes. É a mesma gramática de "Não é essa a
    /// dificuldade" na Hipótese: quem corrige a interpretação é a pessoa.
    @ViewBuilder private func contestacao(_ c: DocumentoTrabalho.ConferenciaTentativa,
                                          evidenciaID: UUID, oficina o: OficinaTrabalho) -> some View {
        if let quando = c.contestadaEm {
            // Sem ponto depois do motivo: o do autor costuma terminar em ponto,
            // e a folha imprimia dois ("…vacino.." na captura da jornada).
            Text("Você contestou esta leitura em \(quando.formatted(date: .abbreviated, time: .shortened)) — “\(c.motivoDaContestacao ?? "sem motivo registrado")” Ela continua no registro e não orienta mais os ajustes.")
                .font(Tema.meta).foregroundStyle(Tema.aviso)
                .accessibilityIdentifier("pratica-leitura-contestada")
        } else {
            let chave = "contestar-\(c.id.uuidString)"
            campo("Por que esta leitura está errada? (para contestá-la)", chave: chave,
                  exemplo: "O que ela entendeu errado da sua tentativa")
            acaoSecundaria("Não foi isso que eu errei") {
                guard !faltaCampo(chave) else { return }
                let motivo = rascunhos[chave] ?? ""
                aplicar(o, limpar: [chave]) { try $0.contestarLeitura(c.id, em: evidenciaID, motivo: motivo) }
            }
            .accessibilityHint(vazio(chave) ? "Escreva o motivo primeiro" : "")
            .accessibilityIdentifier("pratica-contestar-leitura")
        }
    }

    // MARK: - Versão

    private func artefato(_ a: DocumentoTrabalho.Artefato, oficina o: OficinaTrabalho) -> some View {
        let praticaAcima = o.documento.praticaPedida && a.id == o.documento.versaoAtual?.id
        return VStack(alignment: .leading, spacing: Tema.entreItens) {
            HStack(alignment: .firstTextBaseline) {
                secao("Versão \(numero(a.id, em: o.documento))")
                Spacer()
                Text(a.produtor).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            conferencia(a, oficina: o)
            causaDaVersao(a, oficina: o)
            if a.intencaoID != o.documento.intencaoAtual.id {
                Text("Esta versão foi preparada para uma intenção anterior. Confira o que ainda serve.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            if a.pratica != nil && praticaAcima {
                Text("O exercício está na seção Praticar, acima.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            if a.pratica == nil || a.parteDelegada != nil || !praticaAcima {
                ConteudoTrabalhoView(fonte: praticaAcima ? a.parteDelegada ?? a.conteudo : a.conteudo)
                    .id(a.id)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("trabalho-artefato")
            }
            // A mesma regra do bloqueio, e pelo mesmo motivo: o campo só
            // reabre por edição de verdade. Julgado por não-vazio, o cartão
            // imprimia o parágrafo da versão duas vezes para sempre.
            if editandoVersao || Self.alterado(rascunhos, "versao", em: o.documento) {
                campo("Editar a versão", chave: "versao", padrao: a.conteudo)
                    .accessibilityIdentifier("trabalho-editar-versao")
                acaoSecundaria("Guardar como nova versão") { guardarVersao(o, base: a.id) }
                    .accessibilityHint(vazio("versao") ? "Escreva a versão primeiro" : "")
            } else {
                // ADR 08k: enquanto a IA prepara ou adapta, entrar em edição
                // abriria a fresta que o contrato proíbe — a pessoa editaria a
                // versão N e a N+1 chegaria por baixo dela. Tocar leva ao
                // progresso em curso, como em toda ação que compete com ele.
                acaoSecundaria("Editar esta versão") {
                    guard !preparacaoEmCurso(o) else { return }
                    definir("versao", a.conteudo)
                    gaveta { editandoVersao = true }
                }
            }
        }
        .cartao(.papel)
        .transition(Tema.transicao(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity
        ), reduzido: reduceMotion))
    }

    /// ADR 08m: por que esta versão nasceu, quando isso está REGISTRADO. Fora
    /// da prática não há "o que mudou" descrito pelo modelo — a entrega
    /// delegada não tem contrato de saída com essa chave, e resumir a
    /// diferença por conta própria seria o app afirmando o que não observou.
    /// Diz-se o que se sabe: a origem e o motivo guardados no pedido.
    @ViewBuilder private func causaDaVersao(_ a: DocumentoTrabalho.Artefato, oficina o: OficinaTrabalho) -> some View {
        if a.pratica == nil, let aj = o.documento.ajuste(de: a) {
            Text("\(PraticaTrabalho.origemDoAjuste(aj, tentativaEm: aj.evidenciaID.flatMap { id in o.documento.evidencias.first { $0.id == id }?.data })) \(aj.motivo)")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("trabalho-causa-da-versao")
        }
    }

    /// ADR 05p/05q: a checagem local ao lado do produtor e, quando o autor
    /// pede, a revisão assistida — em linhas separadas, porque uma lê regra e
    /// a outra lê sentido. Nenhuma diz "qualidade verificada"; nenhuma bloqueia
    /// ler ou usar. Versão sem conferência DIZ que não foi feita (04a).
    @ViewBuilder private func conferencia(_ a: DocumentoTrabalho.Artefato, oficina o: OficinaTrabalho) -> some View {
        // Só o ÚLTIMO de cada tipo vira linha: conferir de novo não empilha
        // cartão idêntico. O histórico inteiro continua no documento (V5, P3-c).
        let todos = a.conferencias ?? []
        let registros = [todos.last { !daIA($0) }, todos.last { daIA($0) }]
            .compactMap { $0 }.sorted { $0.data < $1.data }
        // "Conferir com IA" mora num lugar só: o último cartão mostrado (P3-d).
        let ondeIA = registros.last?.id
        if registros.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                let pedido = o.documento.pedidoDe(a)
                Text(pedido == nil ? "Conferência: não feita · sem pedido a conferir" : "Conferência: não feita")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                if let pedido {
                    acaoSecundaria("Conferir") { conferir(a, pedido: pedido.id, oficina: o) }
                        .accessibilityIdentifier("trabalho-conferir-primeira")
                    botaoDaIA(a, pedido: pedido.id, oficina: o)
                }
            }
            .accessibilityIdentifier("trabalho-sem-conferencia")
        }
        ForEach(registros) { c in
            DisclosureGroup {
                VStack(alignment: .leading, spacing: Tema.entreItens) {
                    if let motivo = c.motivo {
                        Text(motivo).font(Tema.meta).foregroundStyle(Tema.aviso)
                    }
                    let comTrecho = primeiraPorFonte(c.resultados)
                    ForEach(c.resultados) { r in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.criterio).font(Tema.chrome.weight(.semibold))
                            Text(situacao(r.situacao)).font(Tema.meta)
                                .foregroundStyle(r.situacao == .divergencia ? Tema.aviso : Tema.tintaSuave)
                            if comTrecho.contains(r.id) {
                                Text("No pedido (\(fonte(r.fonte))): “\(r.trechoFonte)”")
                                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave).textSelection(.enabled)
                            }
                            ForEach(Array(r.trechosDoArtefato.enumerated()), id: \.offset) { _, trecho in
                                Text("No artefato: “\(trecho)”")
                                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave).textSelection(.enabled)
                            }
                            Text(r.justificativa).font(Tema.meta)
                        }
                    }
                    Text(rodapeDaConferencia(c)).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    if let ajuste = ConferenciaTrabalho.pedidoDeAjuste(c) {
                        acaoDeSaida("Pedir ajuste") {
                            guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                            definir("pedido", ajuste)
                            campoEmFoco = "pedido"
                            rolarPara = "pedido"
                        }
                        .accessibilityIdentifier("trabalho-pedir-ajuste")
                    }
                    if !daIA(c) {
                        acaoSecundaria("Conferir de novo") { conferir(a, pedido: c.pedidoID, oficina: o) }
                            .accessibilityIdentifier("trabalho-conferir")
                    }
                    if c.id == ondeIA { botaoDaIA(a, pedido: c.pedidoID, oficina: o) }
                }.padding(.top, 8)
            } label: {
                Text(daIA(c) ? RevisaoTrabalho.linha(c) : ConferenciaTrabalho.linha(c))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(Tema.meta)
            .tint(Tema.tintaSuave)
            .accessibilityIdentifier(daIA(c) ? "trabalho-revisao-ia" : "trabalho-conferencia")
        }
    }

    /// Um toque, uma chamada. Enquanto a anterior não volta, o botão sai.
    /// Sem provedor que produza a revisão não há botão: no lugar dele fica a
    /// linha que diz por quê (ADR 05q, volta 5).
    @ViewBuilder private func botaoDaIA(_ a: DocumentoTrabalho.Artefato, pedido: UUID,
                                        oficina o: OficinaTrabalho) -> some View {
        if let aviso = RevisaoTrabalho.oferta() {
            Text(aviso).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("trabalho-revisao-sem-provedor")
        } else if o.revisando {
            ProgressView("A IA está conferindo…")
                .font(Tema.meta)
                .accessibilityIdentifier("trabalho-revisando")
        } else {
            acaoSecundaria("Conferir com IA") {
                guard !levouAoObstaculo(o), acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                o.revisarComIA(a.id, pedidoID: pedido)
            }
            .accessibilityIdentifier("trabalho-conferir-ia")
        }
    }

    private func conferir(_ a: DocumentoTrabalho.Artefato, pedido: UUID, oficina o: OficinaTrabalho) {
        guard !levouAoObstaculo(o), acesso.permitido, o.verificarAcesso() else { revalidar(); return }
        o.conferir(a.id, pedidoID: pedido)
    }

    private func daIA(_ c: DocumentoTrabalho.Conferencia) -> Bool {
        c.executor.hasSuffix(RevisaoTrabalho.sufixoDoExecutor) || c.executor == RevisaoTrabalho.naoExecutada
    }

    private func rodapeDaConferencia(_ c: DocumentoTrabalho.Conferencia) -> String {
        let quando = "\(c.executor) em \(c.data.formatted(date: .abbreviated, time: .shortened))"
        return daIA(c)
            ? "Lido por \(quando). É uma segunda leitura do mesmo tipo de provedor, não uma revisão independente: nada aqui aprova o artefato."
            : "Conferida por \(quando). Esta checagem lê regras, não sentido: nada aqui aprova o artefato."
    }

    /// O mesmo trecho do pedido aparece UMA vez por fonte, não uma por critério.
    private func primeiraPorFonte(_ rs: [DocumentoTrabalho.Resultado]) -> Set<UUID> {
        var vistos = Set<String>(), primeiras = Set<UUID>()
        for r in rs where !r.trechoFonte.isEmpty {
            if vistos.insert(r.fonte.rawValue + "\u{1}" + r.trechoFonte).inserted { primeiras.insert(r.id) }
        }
        return primeiras
    }

    private func fonte(_ f: DocumentoTrabalho.FonteCriterio) -> String {
        switch f {
        case .instrucao: "instrução"
        case .resultado: "resultado desejado"
        case .intencao: "intenção"
        }
    }

    private func situacao(_ s: DocumentoTrabalho.SituacaoCriterio) -> String {
        switch s {
        case .atendidoNoEscopo: "Atendido no escopo examinado"
        case .divergencia: "Possível divergência"
        case .inconclusivo: "Inconclusivo"
        case .naoAvaliado: "Não avaliado"
        }
    }

    // MARK: - Próximo ato

    private func atos(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            secao("Próximo ato")
            campo("O que você vai fazer com este trabalho?", chave: "acao", exemplo: "Ensaiar a apresentação")
                .accessibilityIdentifier("trabalho-acao")
            Pilula("Preparar este ato", forma: .larga, selecionada: true) {
                guard !levouAoObstaculo(o), !faltaCampo("acao") else { return }
                aplicar(o, limpar: ["acao"]) { try $0.prepararAcao(rascunhos["acao"] ?? "") }
            }
            .accessibilityIdentifier("trabalho-preparar-acao")
            .accessibilityHint(vazio("acao") ? "Escreva o ato primeiro" : "")
            Text(vazio("acao")
                 ? "Escreva acima o ato. Preparar não marca como realizado; você pode escolher um horário para cada ação."
                 : "Preparar não marca como realizado. Você pode escolher um horário para cada ação.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            ForEach(o.documento.acoes) { acao in
                VStack(alignment: .leading, spacing: Tema.entreItens) {
                    Text(acao.texto).font(Tema.chrome.weight(.semibold))
                    // ADR 08m: dois eixos, duas linhas. O ATO ("realizei") e o
                    // RESULTADO ("funcionou") nunca se resumem um no outro, e
                    // o terceiro — o horário — está na ficha logo abaixo.
                    Text(acao.estado == .executada ? "Você marcou como realizada" : acao.estado == .cancelada ? "Cancelado" : "Realização ainda não confirmada")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("trabalho-estado-do-ato")
                    Text(o.documento.observacao(de: acao.id)?.resultado.map { "Resultado que você informou: \($0.rotulo)" }
                         ?? "Resultado ainda não informado")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("trabalho-resultado-observado")
                    if let id = acao.artefatoID {
                        Text("Material: versão \(numero(id, em: o.documento))")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    }
                    AgendamentoAcaoView(acao: acao, podeGuardar: o.salvo, aviso: o.avisos[acao.id],
                                        guardar: { data, aviso in
                        aplicar(o) { try $0.agendar(acao.id, para: data, aviso: aviso) }
                    }, verNoCalendario: { data in
                        guard o.verificarAcesso(), o.salvo else { revalidar(); return false }
                        o.cancelar()
                        guard guardar(o), abrirCalendario?(data) == true else { return false }
                        dismiss()
                        return true
                    })
                    if acao.estado != .cancelada {
                        if acao.estado == .pendente {
                            acaoSecundaria("Realizei esta ação") { aplicar(o) { try $0.marcarExecutada(acao.id) } }
                                .accessibilityIdentifier("trabalho-marcar-realizada")
                            // ADR 08m: `cancelada` existia no contrato e não
                            // tinha gesto. Desistir de um ato é uma coisa que
                            // acontece; sem esta saída, a lista só cresce.
                            // ADR 08n: e ela some quando já há resultado
                            // informado — com o motivo dito, porque gesto que
                            // desaparece calado parece defeito.
                            if o.documento.podeCancelar(acao.id) {
                                acaoSecundaria("Cancelar esta ação") { aplicar(o) { try $0.cancelarAcao(acao.id) } }
                                    .accessibilityIdentifier("trabalho-cancelar-acao")
                            } else {
                                Text("Esta ação não se cancela mais: você já informou um resultado, e cancelar apagaria o que aconteceu.")
                                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                                    .accessibilityIdentifier("trabalho-cancelar-indisponivel")
                            }
                        }
                        let chave = "relato-\(acao.id.uuidString)"
                        let chaveResultado = "resultado-\(acao.id.uuidString)"
                        campo("O que aconteceu?", chave: chave, exemplo: "O que funcionou ou faltou")
                        trilhoDoResultado(chaveResultado)
                        Text("Informar o resultado é opcional, e vale para tentativa parcial e para fracasso. Sem ele, o relato fica como não observado — nunca como sucesso.")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        acaoSecundaria("Registrar meu relato") {
                            guard !faltaCampo(chave) else { return }
                            let texto = rascunhos[chave] ?? ""
                            let resultado = DocumentoTrabalho.ResultadoObservado(rawValue: rascunhos[chaveResultado] ?? "")
                            aplicar(o, limpar: [chave, chaveResultado]) {
                                try $0.registrarRelato(texto, acaoID: acao.id, resultado: resultado)
                            }
                        }
                        .accessibilityHint(vazio(chave) ? "Escreva o relato primeiro" : "")
                        .accessibilityIdentifier("trabalho-registrar-relato")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cartao(.papel)
                .id(acao.id)
            }
        }
        .id("trabalho-atos")
    }

    /// ADR 08m: as três formas do resultado, no mesmo trilho do apoio — a
    /// pessoa escolhe uma ou nenhuma, e tocar de novo desmarca. Fracasso e
    /// parcial ficam ao lado de "funcionou", com o mesmo peso: a lista que só
    /// oferece sucesso obriga a mentir ou a calar.
    @ViewBuilder private func trilhoDoResultado(_ chave: String) -> some View {
        let escolhido = DocumentoTrabalho.ResultadoObservado(rawValue: rascunhos[chave] ?? "")
        let pilulas = ForEach(DocumentoTrabalho.ResultadoObservado.allCases, id: \.self) { r in
            Pilula(r.rotulo, forma: .filtro, selecionada: escolhido == r) {
                if escolhido == r { limpar([chave]) } else { definir(chave, r.rawValue) }
            }
            .accessibilityAddTraits(escolhido == r ? [.isSelected] : [])
            .accessibilityIdentifier("trabalho-resultado-\(r.rawValue)")
        }
        // A mesma razão do trilho do apoio: em tamanho de acessibilidade três
        // cápsulas não cabem lado a lado e empurram a folha para fora da tela.
        if tamanhoTexto.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) { pilulas }
        } else {
            HStack(spacing: 8) { pilulas }
        }
    }

    /// ADR 08m: a orientação seguinte NASCE do resultado informado. Três
    /// resultados, três pedidos diferentes — sem isto, "revisar com estes
    /// relatos" mandava a mesma frase quando funcionou e quando fracassou, e
    /// o autor não tinha por que contar que deu errado.
    /// ADR 08o: o resultado é de UMA ação, e a orientação diz qual. Sem o
    /// nome, um Trabalho com três ações e três resultados manda "propor
    /// caminho diferente" enquanto a ação principal funcionou.
    static func orientacaoDoRelato(_ r: DocumentoTrabalho.ResultadoObservado?,
                                   acao: String? = nil) -> String {
        let sujeito = acao.map { "a ação “\($0)”" } ?? "a ação"
        return switch r {
        case .funcionou:
            "A pessoa informou que \(sujeito) FUNCIONOU. Preserve o que ela relatou ter funcionado e não o reescreva; a revisão avança a partir daí, tratando o que ainda está em aberto. Não declare que ela aprendeu."
        case .parcial:
            "A pessoa informou que \(sujeito) funcionou EM PARTE. Preserve o que ela relatou ter funcionado e trabalhe apenas o que ela relatou ter faltado. Não refaça o que já serviu."
        case .naoFuncionou:
            "A pessoa informou que \(sujeito) NÃO FUNCIONOU. Proponha um caminho diferente, não uma variação do mesmo; diga o que está mudando. Não trate o relato dela como erro dela."
        case nil:
            "Revise a versão à luz dos relatos registrados e do resultado desejado. Diferencie o que foi observado do que ainda é incerto e proponha um ajuste concreto."
        }
    }

    /// ADR 08o: o texto da ação em que a pessoa informou o último resultado.
    /// `nil` = nada observado, ou ação que já não está na lista.
    static func acaoObservada(_ d: DocumentoTrabalho) -> String? {
        guard let e = d.ultimaObservacao else { return nil }
        return d.acoes.first { $0.id == e.acaoID }?.texto
    }

    /// A causa do pedido nascido de um relato, como DADO: aponta a evidência
    /// em que a pessoa informou o resultado. `nil` = nenhum resultado
    /// informado — e aí não há causa a registrar, só um pedido comum.
    static func causaDoRelato(_ d: DocumentoTrabalho) -> DocumentoTrabalho.Ajuste? {
        guard let e = d.ultimaObservacao, let r = e.resultado else { return nil }
        let motivo = "Você informou o resultado desta ação: \(r.rotulo). Seu relato: \(e.texto)"
        return .init(gatilho: .resultadoInformado,
                     motivo: String(motivo.prefix(PraticaTrabalho.Limite.motivoDoAjuste)),
                     evidenciaID: e.id)
    }

    /// Só relatos: a tentativa já está em Praticar, e a dificuldade (hipótese,
    /// com autoria) também — o bloco antigo, que criava hipótese sem autor e
    /// apontava todas as evidências como pertinentes, saiu (volta 6, P2-B).
    @ViewBuilder private func retorno(_ o: OficinaTrabalho) -> some View {
        let relatos = o.documento.evidencias.filter { $0.tentativa == nil }
        if !relatos.isEmpty {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                secao("O que aconteceu")
                ForEach(relatos) { e in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Relato de \(e.atribuidaA) · \(e.data.formatted(date: .abbreviated, time: .shortened))")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        // ADR 08m: o resultado informado fica ao lado do relato
                        // que o informou. Relato antigo diz "não observado" —
                        // ninguém lhe atribui sucesso por releitura.
                        Text(e.resultado.map { "Resultado informado: \($0.rotulo)" } ?? "Resultado não observado")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("trabalho-relato-resultado")
                        Text(e.texto).textSelection(.enabled)
                        if let acao = o.documento.acoes.first(where: { $0.id == e.acaoID }) {
                            Text("Ação: \(acao.texto)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        }
                        if let id = e.artefatoID {
                            Text("Material: versão \(numero(id, em: o.documento))")
                                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cartao(.papel)
                }
                if !o.documento.praticaPedida || PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) == nil {
                    // ADR 08m: a orientação seguinte muda pelo resultado, e a
                    // causa vai junto como dado — o documento passa a dizer
                    // que esta versão nasceu do que a pessoa observou.
                    let causa = Self.causaDoRelato(o.documento)
                    let observada = Self.acaoObservada(o.documento)
                    let ondeInformou = observada.map { ", na ação “\($0)”" } ?? ""
                    // ADR 08o: a premissa vem ANTES do botão — quem lê por
                    // VoiceOver ouve de que resultado a revisão parte antes de
                    // ter o gesto na mão, não depois.
                    if let r = o.documento.ultimaObservacao?.resultado {
                        Text("A revisão vai partir do último resultado que você informou\(ondeInformou): \(r.rotulo).")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("trabalho-revisao-parte-do-resultado")
                    }
                    acaoSecundaria(o.documento.praticaPedida ? "Adaptar exercício aos relatos" : "Revisar com estes relatos") {
                        guard !levouAoQueFalta(o, campoObrigatorio: nil) else { return }
                        definir("pedido", Self.orientacaoDoRelato(o.documento.ultimaObservacao?.resultado, acao: observada))
                        let instrucao = rascunhos["pedido"] ?? ""
                        o.gerar(instrucao, ajuste: causa ?? Self.causaDoPedidoEscrito(o.documento, instrucao))
                    }
                    .accessibilityIdentifier("trabalho-revisar")
                }
            }
            .id("trabalho-retorno")
        }
    }

    /// Uma gaveta só, e sem gaveta dentro de gaveta: cada versão é um cartão.
    private func historico(_ o: OficinaTrabalho) -> some View {
        DisclosureGroup("Histórico de versões (\(o.documento.artefatos.count))", isExpanded: $historicoAberto) {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                let livres = o.documento.tentativas(doArtefato: nil)
                if !livres.isEmpty {
                    Text("Tentativas sem material preparado").font(Tema.chrome.weight(.semibold))
                    ForEach(livres) { e in tentativa(e, pratica: nil, ultima: false, oficina: o) }
                }
                ForEach(o.documento.artefatos.reversed()) { a in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Versão \(numero(a.id, em: o.documento)) · \(a.produtor)")
                            .font(Tema.chrome.weight(.semibold))
                        ForEach(a.conferencias ?? []) { c in
                            Text(daIA(c) ? RevisaoTrabalho.linha(c) : ConferenciaTrabalho.linha(c))
                                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        }
                        ConteudoTrabalhoView(fonte: a.conteudo)
                            .id(a.id)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(o.documento.tentativas(doArtefato: a.id)) { e in
                            tentativa(e, pratica: a.pratica, ultima: false, oficina: o)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cartao(.papel)
                }
            }.padding(.top, 8)
        }
        .font(Tema.chrome)
        .tint(Tema.tintaSuave)
        .id("trabalho-historico")
    }

    /// O rodapé de estado: salvamento, rascunhos e a cópia de recuperação.
    @ViewBuilder private func rodape(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(o.salvo ? "Versões e atos guardados neste aparelho." : "Alterações ainda não guardadas.")
                .font(Tema.meta).foregroundStyle(o.salvo ? Tema.tintaSuave : Tema.aviso)
                .accessibilityIdentifier("trabalho-salvamento")
            if rascunhos.keys.contains(where: { Self.alterado(rascunhos, $0, em: o.documento) }) {
                Text("Os campos em edição voltam ao reabrir este trabalho; só entram no documento quando você os guarda.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                acaoSecundaria("Descartar rascunhos dos campos") {
                    guard !levouAoObstaculo(o), !preparacaoEmCurso(o) else { return }
                    confirmarDescarte = true
                }
            }
            if let recuperacao {
                Text("Uma cópia das alterações anteriores foi preservada neste aparelho, separada da versão atual.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                acaoDeSaida("Copiar dados de recuperação") {
                    guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                    UIPasteboard.general.string = recuperacao
                    copiaCopiada = true
                }
                if copiaCopiada {
                    Text("Cópia na área de transferência.").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }
                acaoSecundaria("Apagar cópia de recuperação") { confirmarApagarCopia = true }
            }
        }
    }

    // MARK: - Vocabulário da folha

    /// Rótulo de seção (SISTEMA-CLARO §3), o mesmo da ficha do calendário.
    private func secao(_ texto: String) -> some View {
        Text(texto).rotulo(Tema.tintaSuave).accessibilityAddTraits(.isHeader)
    }

    /// Ação secundária: cápsula de chip, o vocabulário de forma da casa
    /// ("tudo é cápsula", SISTEMA-CLARO §1.3). Texto solto sobre papel não se
    /// lê como controle (critique-affordance) e não tem estado desabilitado;
    /// a cápsula tem os dois, mais o alvo de 44 que a `Pilula` já embrulha.
    /// Sem âmbar: duas saídas em âmbar empatam em peso e o olho não sabe qual
    /// é o caminho (von-restorff-effect).
    private func acaoSecundaria(_ titulo: String, _ fazer: @escaping () -> Void) -> some View {
        Pilula(titulo, forma: .filtro, acao: fazer)
    }

    /// A saída de um problema: o único emprego do âmbar nesta folha.
    private func acaoDeSaida(_ titulo: String, _ fazer: @escaping () -> Void) -> some View {
        Button(titulo, action: fazer)
            .buttonStyle(.primario(alinhamento: .leading))
    }

    private func campo(_ titulo: String, chave: String, padrao: String = "", exemplo: String = "Escreva aqui") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Rótulo de campo em caixa normal: a caixa alta é da SEÇÃO, e
            // duas caixas altas empilhadas gritam sem hierarquia.
            Text(titulo).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            // O `set` só grava o que MUDA. Um `TextField` que sai da tela
            // devolve o texto ao binding, e como o salvamento acabou de
            // `limpar` o rascunho, o que ele devolvia era o `padrao` — em
            // "Sua versão", a string vazia. Um rascunho vazio gravado depois
            // de guardar a versão é diferente da versão: a folha voltava a
            // afirmar uma edição pendente que ninguém fez. Escrever nada não
            // é editar, e agora não vira rascunho (a mesma origem enchia
            // "pedido" de "" e ligava o "Descartar rascunhos" do rodapé).
            TextField(exemplo, text: Binding(get: { rascunhos[chave] ?? padrao },
                                           set: { novo in
                                               guard novo != (rascunhos[chave] ?? padrao) else { return }
                                               definir(chave, novo)
                                           }), axis: .vertical)
                .font(Tema.corpo)
                .lineLimit(2...12)
                .id(chave)
                .focused($campoEmFoco, equals: chave)
                .cartao(.campo)
                .accessibilityLabel(titulo)
        }
    }

    /// A gaveta que abre no lugar (§21: altura animada, um driver só).
    private func gaveta(_ mudar: @escaping () -> Void) {
        withAnimation(Tema.gaveta(reduzido: reduceMotion), mudar)
    }

    private func vazio(_ chave: String) -> Bool {
        (rascunhos[chave] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func edicaoPendente(_ o: OficinaTrabalho) -> Bool { campoEmEdicao(o) != nil }

    /// Qual campo está em edição não guardada — o destino do toque bloqueado.
    private func campoEmEdicao(_ o: OficinaTrabalho) -> String? {
        Self.campoEmEdicao(rascunhos, em: o.documento)
    }

    // MARK: - A regra do rascunho

    /// O que o documento já guarda para um campo que **nasce preenchido**.
    /// `nil` é o campo livre (pedido, ato, relato, dificuldade): ali qualquer
    /// texto é edição, porque não há nada de onde diferir.
    static func guardado(_ chave: String, em d: DocumentoTrabalho) -> String? {
        switch chave {
        case "intencao": d.intencaoAtual.texto
        case "resultado": d.intencaoAtual.resultado
        case "versao": d.versaoAtual?.conteudo ?? ""
        default: nil
        }
    }

    /// **Edição pendente é rascunho DIFERENTE do guardado, não rascunho que
    /// existe.** É a regra inteira desta folha, e ela é `static` porque foi
    /// aqui que a folha passou a mentir sobre si mesma (G4 da volta 18).
    ///
    /// "versao" era julgada por não-vazio. E o rascunho de "versao" não é
    /// escrito só por quem digita: o `TextField` devolve o texto ao binding
    /// quando SAI da tela, depois do `limpar` que o salvamento acabou de
    /// fazer — então **guardar a própria versão gravava, como rascunho, o
    /// texto idêntico ao que tinha acabado de virar versão**. A partir dali a
    /// folha afirmava para sempre uma edição que ninguém fez: imprimia a
    /// versão duas vezes (o cartão reabria o campo "Editar a versão"),
    /// travava "Preparar nova versão com IA" e a importação com um obstáculo
    /// inexistente, e o rodapé oferecia descartar um rascunho que não havia.
    /// `UserDefaults` guarda o rascunho, então sobrevivia a fechar a folha,
    /// reabrir, descartar e reiniciar o aparelho.
    ///
    /// Julgar por diferença apaga a classe: um rascunho igual ao guardado é
    /// invisível para a pessoa, e agora é invisível para a folha também — e
    /// o estado já preso nos aparelhos se desfaz sozinho na primeira leitura.
    static func alterado(_ rascunhos: [String: String], _ chave: String, em d: DocumentoTrabalho) -> Bool {
        // Rascunho em branco não é edição em lugar nenhum: nenhum destes
        // campos pode ser guardado vazio (`reverIntencao` e
        // `guardarVersaoHumana` recusam), então um vazio nunca é trabalho à
        // espera de commit — e travar a folha por ele seria de novo nomear um
        // obstáculo que a pessoa não tem como resolver guardando. É também o
        // que desfaz o estado já preso nos aparelhos: medido no simulador
        // depois de guardar a própria versão, o `plist` do app tinha
        // `"versao" => ""`, escrito pelo `TextField` ao sair da tela.
        guard let rascunho = rascunhos[chave],
              !rascunho.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let guardado = guardado(chave, em: d) else { return true }
        return rascunho != guardado
    }

    /// O primeiro campo do documento em edição não guardada, na ordem em que
    /// a folha os lê. Os campos livres não entram: eles não bloqueiam nada,
    /// o guarda deles é `faltaCampo`.
    static func campoEmEdicao(_ rascunhos: [String: String], em d: DocumentoTrabalho) -> String? {
        ["intencao", "resultado", "versao"].first { alterado(rascunhos, $0, em: d) }
    }

    // MARK: - Bloqueio: nenhuma ação desta folha some

    /// A lei do bloqueio desta folha: **nada desaparece**. `.disabled()` sobre
    /// `Pilula` devolve fundo `.clear` com `tintaMorta` — 1,53:1 sobre o papel,
    /// sem cápsula e sem forma de botão —, e foi assim que a ação PRIMÁRIA da
    /// tela virou legenda cinza (revisão da volta 18). No lugar disso a ação
    /// continua inteira, com o alvo de 44 e o contraste que tinha, e **tocar
    /// leva ao que falta**: o campo vazio recebe o foco, a edição pendente
    /// recebe o foco, o salvamento falho leva à saída no alto da folha, a
    /// preparação em curso leva ao próprio progresso. O motivo continua
    /// escrito ao lado — era o que a ADR pedia ao desabilitado — e agora
    /// também no `accessibilityHint`, para quem ouve a tela.
    ///
    /// - Returns: `true` quando levou a pessoa ao obstáculo; a ação não corre.
    private func levouAoObstaculo(_ o: OficinaTrabalho) -> Bool {
        guard !o.salvo else { return false }
        rolarPara = "trabalho-erro"
        anunciar(o.erro ?? "As alterações deste trabalho ainda não foram guardadas.")
        return true
    }

    /// O guarda ÚNICO das duas rotas que chamam a IA: `trabalho-gerar` e
    /// `trabalho-revisar`. Eram duas listas de guardas copiadas e **elas
    /// divergiram**: ao tirar o `.disabled(travado)` de `trabalho-gerar`, a
    /// volta 18-B portou só a metade `!o.salvo`, e a folha passou a escrever
    /// "Guarde a intenção ou a versão que está editando antes de pedir uma
    /// nova preparação" e a disparar a IA assim mesmo — uma corrida de ~90 s
    /// gasta no caso exato que a regra existia para evitar (re-G3, achado A).
    /// Agora é uma função só: não há mais onde divergir. A ordem é a mesma que
    /// `motivoDoTravamento` fala — salvamento, preparação em curso, edição
    /// pendente, campo vazio —, porque a folha não pode nomear um obstáculo e
    /// levar a outro.
    ///
    /// - Returns: `true` quando levou a pessoa ao que falta; a IA não corre.
    private func levouAoQueFalta(_ o: OficinaTrabalho, campoObrigatorio: String?) -> Bool {
        if levouAoObstaculo(o) || preparacaoEmCurso(o) { return true }
        if let chave = campoEmEdicao(o) {
            // Aqui o motivo é dito antes do foco: o campo que recebe o cursor
            // fica em OUTRA seção da folha, e ouvir só "O que quero realizar"
            // não explica por que a preparação não começou.
            anunciar(motivoDoTravamento(o))
            campoEmFoco = chave
            rolarPara = chave
            return true
        }
        if let campoObrigatorio { return faltaCampo(campoObrigatorio) }
        return false
    }

    /// O motivo dito em voz, não só escrito. Tirar o `.disabled()` devolveu
    /// cápsula, contraste (1,53:1 → 13,94:1) e alcance ao botão, mas custou o
    /// `isEnabled = false` que fazia o Controle Assistivo e o Acesso Total por
    /// Teclado **pularem** o controle: quem varre agora pousa num botão que
    /// aceita ativação e não conclui. O anúncio diz por que parou ali sem
    /// depender de "Falar dicas" estar ligada nem da pausa que ela exige.
    ///
    /// Limite honesto: `Announcement` é canal do VoiceOver. Quem usa Controle
    /// Assistivo **sem** VoiceOver continua sem a fala; para essa pessoa o que
    /// resta é o desvio visível — o foco e a rolagem até o obstáculo.
    private func anunciar(_ motivo: String) {
        guard !motivo.isEmpty else { return }
        AccessibilityNotification.Announcement(motivo).post()
    }

    /// Campo vazio não apaga a ação: leva o foco ao primeiro campo que falta.
    private func faltaCampo(_ chaves: String...) -> Bool {
        guard let falta = chaves.first(where: vazio) else { return false }
        campoEmFoco = falta
        rolarPara = falta
        return true
    }

    /// Enquanto a IA prepara, o que competiria com ela leva ao progresso dela.
    /// ADR 08k: adaptar também conta. Entre a leitura da tentativa e a versão
    /// seguinte não existe `pedidoAtivo` — era por essa fresta que a edição
    /// começava e o documento trocava debaixo dela.
    private func preparacaoEmCurso(_ o: OficinaTrabalho) -> Bool {
        if o.adaptando {
            rolarPara = "pratica-adaptando"
            anunciar("A IA está conferindo e adaptando o exercício. Espere a versão chegar.")
            return true
        }
        guard o.documento.pedidoAtivo != nil else { return false }
        rolarPara = "trabalho-preparando"
        anunciar("A IA já está preparando. Espere ou cancele a preparação em curso.")
        return true
    }

    private func numero(_ id: UUID, em d: DocumentoTrabalho) -> Int {
        (d.artefatos.firstIndex(where: { $0.id == id }) ?? 0) + 1
    }

    private func definir(_ chave: String, _ texto: String) {
        guard acesso.permitido else { revalidar(); return }
        rascunhos[chave] = texto
        UserDefaults.standard.set(rascunhos, forKey: chaveRascunho)
    }

    private func limpar(_ chaves: [String]) {
        guard acesso.permitido else { revalidar(); return }
        for chave in chaves { rascunhos.removeValue(forKey: chave) }
        if chaves.contains("versao") { editandoVersao = false }
        UserDefaults.standard.set(rascunhos, forKey: chaveRascunho)
    }

    private func aplicar(_ o: OficinaTrabalho, limpar chaves: [String] = [],
                         _ mudanca: (inout DocumentoTrabalho) throws -> Void) {
        guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
        guard !levouAoObstaculo(o) else { return }
        if o.alterar(mudanca) { limpar(chaves) }
        else if !o.salvo { limparAposCommit = chaves }
    }

    /// ADR 08k: `base` é a versão que estava na tela quando a edição começou.
    /// O documento recusa guardar por cima de outra — bloquear a entrada em
    /// edição é guarda de tela, e guarda de tela não é invariante.
    private func guardarVersao(_ o: OficinaTrabalho, base: UUID? = nil) {
        guard !faltaCampo("versao") else { return }
        let texto = rascunhos["versao"] ?? ""
        aplicar(o, limpar: ["versao"]) { try $0.guardarVersaoHumana(texto, base: base) }
        if o.salvo { editandoVersao = false }
    }

    @discardableResult private func guardar(_ o: OficinaTrabalho) -> Bool {
        guard acesso.permitido, o.verificarAcesso() else { revalidar(); return false }
        guard o.guardar() else { return false }
        limpar(limparAposCommit)
        limparAposCommit = []
        return true
    }

    private func abrir() {
        guard acesso.permitido else { revalidar(); return }
        do {
            let nova = try OficinaTrabalho(trabalho: trabalho, context: context)
            rascunhos = UserDefaults.standard.dictionary(forKey: chaveRascunho) as? [String: String] ?? [:]
            recuperacao = UserDefaults.standard.string(forKey: chaveRascunho + ".recuperacao")
            oficina = nova
            exibicaoSuspensa = false
            erroDeLeitura = nil
            // ADR 05n: a folha aberta conta o estado real do aviso, não o que se pediu
            Task { await nova.lerAvisos() }
        } catch {
            erroDeLeitura = "Não consegui abrir este trabalho. O registro foi preservado; nenhum documento vazio foi criado."
        }
    }

    private func voltar() {
        guard acesso.permitido else {
            revalidar()
            // Fechar a folha não pode destruir o candidato que o disco recusou.
            // Só preserva bytes já em memória; não modifica o agregado protegido
            // nem disponibiliza a cópia enquanto o acesso estiver revogado.
            if let oficina, !oficina.salvo, !preservarCopiaLocal(oficina) { return }
            dismiss()
            return
        }
        guard let oficina else { dismiss(); return }
        oficina.cancelar()
        guard guardar(oficina) else { return }
        dismiss()
    }

    private func preservarEReabrir(_ o: OficinaTrabalho) {
        guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
        guard preservarCopiaLocal(o) else { return }
        o.cancelar()
        limparAposCommit = []
        abrir()
    }

    private func preservarCopiaLocal(_ o: OficinaTrabalho) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let dados = try? encoder.encode(o.documento),
              let texto = String(data: dados, encoding: .utf8) else { return false }
        // A cópia nunca substitui o agregado atual. Fica acessível para recuperar
        // alterações recusadas por conflito, até remoção explícita da pessoa.
        let anterior = UserDefaults.standard.string(forKey: chaveRascunho + ".recuperacao")
        let copia = anterior.map { $0 + "\n\n--- Nova cópia de recuperação ---\n\n" + texto } ?? texto
        UserDefaults.standard.set(copia, forKey: chaveRascunho + ".recuperacao")
        return true
    }

    private func revalidar() {
        let oficinaPermitida = oficina?.verificarAcesso() ?? true
        if acesso.permitido && oficinaPermitida {
            guard scenePhase == .active else { return }
            if oficina == nil {
                abrir()
            } else if exibicaoSuspensa {
                // Conserva a mesma Oficina, inclusive documento !salvo e a
                // limpeza pendente. Não recarrega o agregado por cima dela.
                rascunhos = UserDefaults.standard.dictionary(forKey: chaveRascunho) as? [String: String] ?? [:]
                recuperacao = UserDefaults.standard.string(forKey: chaveRascunho + ".recuperacao")
                exibicaoSuspensa = false
            }
            return
        }
        // O body retira toda a superfície antes de renderizar. A Oficina fica
        // retida, sem ações permitidas, para conservar alterações não salvas.
        exibicaoSuspensa = true
        rascunhos = [:]
        recuperacao = nil
        copiaCopiada = false
        erroDeLeitura = nil
        confirmarDescarte = false
        confirmarApagarCopia = false
        editandoIntencao = false
        editandoVersao = false
        Teclado.recolher()
    }
}

/// Só metadados de proteção. A observação não lê título, corpo ou campos.
struct SeloOrigemTrabalho: Equatable {
    let id: UUID
    let trancada: Bool
    let queimada: Bool
    let gesto: String?
    init(_ nota: Nota) {
        id = nota.uuid
        trancada = nota.trancada
        queimada = nota.queimada
        gesto = nota.gestoRaw
    }
}
