import SwiftData
import SwiftUI
import UIKit

/// O trabalho permanece um documento: versões, ato e retorno, sem um wizard.
struct TrabalhoView: View {
    let trabalho: Trabalho
    var acaoEmFoco: UUID? = nil
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.abrirCalendarioDoTrabalho) private var abrirCalendario
    @Environment(\.scenePhase) private var scenePhase
    @Query private var notas: [Nota]
    @State private var oficina: OficinaTrabalho?
    @State private var erroDeLeitura: String?
    @State private var rascunhos: [String: String] = [:]
    @State private var limparAposCommit: [String] = []
    @State private var editandoVersao = false
    @State private var confirmarDescarte = false
    @State private var recuperacao: String?
    @State private var confirmarApagarCopia = false
    @State private var copiaCopiada = false
    @State private var exibicaoSuspensa = false
    @FocusState private var campoEmFoco: String?
    @State private var rolarPara: String?

    private var chaveRascunho: String { "trabalho.rascunhos.\(trabalho.uuid.uuidString)" }
    private var selos: [SeloOrigemTrabalho] { notas.map(SeloOrigemTrabalho.init) }
    private var acesso: AcessoTrabalho.Estado { AcessoTrabalho.estado(trabalho, no: context) }

    var body: some View {
        NavigationStack {
            ScrollViewReader { rolagem in
            ScrollView {
                VStack(alignment: .leading, spacing: Tema.entreSecoes) {
                    if scenePhase != .active {
                        Text("Trabalho").font(Tema.secaoNota)
                    } else if !acesso.permitido {
                        Text("Trabalho protegido").font(Tema.secaoNota)
                        Text(acesso.mensagem).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("trabalho-protegido")
                    } else if let oficina {
                        documento(oficina).buttonStyle(AcaoTrabalhoStyle())
                    } else if let erroDeLeitura {
                        Text(erroDeLeitura).foregroundStyle(Tema.aviso)
                        Button("Tentar abrir novamente") { abrir() }
                    } else {
                        ProgressView("Abrindo trabalho…")
                    }
                }
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .padding(Tema.margem)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Tema.fundo)
            .task(id: oficina != nil) {
                if oficina != nil, acesso.permitido, let acaoEmFoco {
                    await Task.yield()
                    rolagem.scrollTo(acaoEmFoco, anchor: .top)
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
                    withAnimation { rolagem.scrollTo(alvo, anchor: .top) }
                    rolarPara = nil
                }
            }
            }
            .navigationTitle("Trabalho")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Voltar") { voltar() }
                        .accessibilityIdentifier("trabalho-voltar")
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

    @ViewBuilder private func documento(_ o: OficinaTrabalho) -> some View {
        if let erro = o.erro {
            VStack(alignment: .leading, spacing: 8) {
                Text(erro).foregroundStyle(Tema.aviso)
                    .accessibilityIdentifier("trabalho-erro")
                if !o.salvo {
                    Button("Tentar guardar novamente") { guardar(o) }
                        .accessibilityIdentifier("trabalho-tentar-guardar")
                    Button("Preservar cópia e reabrir a versão atual") { preservarEReabrir(o) }
                }
            }
        }
        intencao(o)
        praticar(o)
        producao(o)
        if let versao = o.documento.versaoAtual { artefato(versao, oficina: o) }
        IntercambioTrabalhoView(oficina: o, permiteImportar: !edicaoPendente(o))
        atos(o)
        retorno(o)
        historico(o)
        Text(o.salvo ? "Versões e atos guardados neste aparelho." : "Alterações ainda não guardadas.")
            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            .accessibilityIdentifier("trabalho-salvamento")
        if !rascunhos.isEmpty {
            Text("Os campos em edição, incluindo seu pedido, ficam como rascunhos neste aparelho e voltam ao reabrir este trabalho. Eles só entram no documento quando você os guarda.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            Button("Descartar rascunhos dos campos") { confirmarDescarte = true }
                .disabled(!o.salvo || o.documento.pedidoAtivo != nil)
        }
        if let recuperacao {
            VStack(alignment: .leading, spacing: 8) {
                Text("Uma cópia das alterações anteriores foi preservada neste aparelho, separada da versão atual.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                Button("Copiar dados de recuperação") {
                    guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                    UIPasteboard.general.string = recuperacao
                    copiaCopiada = true
                }
                if copiaCopiada { Text("Cópia na área de transferência.").font(Tema.meta) }
                Button("Apagar cópia de recuperação") { confirmarApagarCopia = true }
            }
        }
    }

    private func intencao(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(o.documento.intencaoAtual.texto).font(Tema.tituloTela)
                .accessibilityAddTraits(.isHeader)
            if !o.documento.intencaoAtual.resultado.isEmpty {
                Text(o.documento.intencaoAtual.resultado).foregroundStyle(Tema.tintaSuave)
            }
            DisclosureGroup("Intenção, resultado e apoio") {
                VStack(alignment: .leading, spacing: 12) {
                    campo("O que quero realizar", chave: "intencao", padrao: o.documento.intencaoAtual.texto, exemplo: "Apresentar minha ideia")
                    campo("Como reconhecerei o resultado", chave: "resultado", padrao: o.documento.intencaoAtual.resultado, exemplo: "Explicar em um minuto")
                    Button("Guardar intenção") {
                        let texto = rascunhos["intencao"] ?? o.documento.intencaoAtual.texto
                        let resultado = rascunhos["resultado"] ?? o.documento.intencaoAtual.resultado
                        aplicar(o, limpar: ["intencao", "resultado"]) { try $0.reverIntencao(texto, resultado: resultado) }
                    }
                    .disabled(!o.salvo)
                    Picker("Neste trabalho, prefiro", selection: Binding(
                        get: { o.documento.apoio },
                        set: { apoio in aplicar(o) { $0.cancelarPedido(); $0.apoio = apoio } }
                    )) {
                        Text("Delegar a produção").tag(DocumentoTrabalho.Apoio.delegar)
                        Text("Praticar com apoio").tag(DocumentoTrabalho.Apoio.praticar)
                        Text("Combinar os dois").tag(DocumentoTrabalho.Apoio.combinar)
                    }
                    .pickerStyle(.menu)
                    .disabled(!o.salvo)
                    Text("Você pode mudar o apoio conforme o que quer fazer. Delegar não exige aprender a executar tudo.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }.padding(.top, 8)
            }
        }
    }

    // MARK: - ADR 05r: praticar

    /// A seção da prática, numa leitura de cima para baixo: objetivo →
    /// material → tentativa → feedback → dificuldade. Aparece com apoio
    /// "praticar"; em "combinar" só depois que a pessoa delimita o trecho que
    /// ela mesma vai exercitar — sem delimitação, combinar é entrega delegada.
    /// A tentativa existe SEM exercício e SEM conta: a prática é da pessoa.
    @ViewBuilder private func praticar(_ o: OficinaTrabalho) -> some View {
        if o.documento.apoio != .delegar {
            VStack(alignment: .leading, spacing: 16) {
                titulo("Praticar")
                Text("O que você quer conseguir fazer: \(o.documento.intencaoAtual.texto)")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("pratica-objetivo")
                if o.documento.apoio == .combinar { delimitacao(o) }
                if o.documento.praticaPedida {
                    let versao = o.documento.versaoAtual
                    let pratica = versao?.pratica
                    if let versao, let pratica {
                        exercicio(pratica, produtor: versao.produtor)
                    } else if let linha = PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) {
                        // Uma linha só: a última recusa, nunca uma pilha.
                        Text(linha).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("pratica-sem-provedor")
                    } else if o.documento.praticaIndisponivel {
                        Text(PraticaTrabalho.preparacaoIndisponivel).font(Tema.meta).foregroundStyle(Tema.aviso)
                            .accessibilityIdentifier("pratica-preparacao-indisponivel")
                    } else {
                        Text("Nenhum exercício preparado ainda. Escreva abaixo o que você quer praticar e toque em preparar: a IA prepara enunciado, exemplo e critérios; a tentativa é sua.")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("pratica-sem-exercicio")
                    }
                    tentativas(artefatoID: pratica == nil ? nil : versao?.id, pratica: pratica, oficina: o)
                }
                dificuldade(o)
            }
        }
    }

    private func delimitacao(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            campo("O trecho que eu mesmo vou exercitar", chave: "trecho",
                  padrao: o.documento.trechoExercitado ?? "", exemplo: "As frases em espanhol")
                .accessibilityIdentifier("pratica-trecho")
            Button("Guardar o trecho") {
                let texto = rascunhos["trecho"] ?? ""
                aplicar(o, limpar: ["trecho"]) { $0.trechoExercitado = texto }
            }
            .disabled(!o.salvo || vazio("trecho"))
            if !o.documento.praticaPedida {
                Text("Sem esse trecho, combinar entrega o trabalho inteiro: nada aqui vira exercício.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
        }
    }

    /// O gargalo, corrigível. A pergunta aceita contexto, recursos, acesso ou
    /// divisão do trabalho — não só habilidade. Só a pessoa confirma ou
    /// contesta, e confirmar é concordar neste contexto, não ser avaliada.
    private func dificuldade(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            campo("O que está dificultando isso?", chave: "dificuldade",
                  exemplo: "Pode ser contexto, recursos, acesso ou divisão do trabalho")
                .accessibilityIdentifier("pratica-dificuldade")
            Button("Guardar esta dificuldade") {
                let texto = rascunhos["dificuldade"] ?? ""
                aplicar(o, limpar: ["dificuldade"]) { try $0.proporHipotese(texto, propostaPor: "Você") }
            }
            .disabled(!o.salvo || vazio("dificuldade"))
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
                    Button("Faz sentido neste contexto") { avaliar(h, .confirmada, chave: chave, oficina: o) }
                        .accessibilityIdentifier("pratica-confirmar-hipotese")
                    Button("Não é essa a dificuldade") { avaliar(h, .contestada, chave: chave, oficina: o) }
                        .accessibilityIdentifier("pratica-contestar-hipotese")
                    Text("Concordar aqui é concordar neste contexto. Não é o app avaliando você, nem prova de que você aprendeu.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }.disabled(!o.salvo)
            }
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

    private func exercicio(_ p: DocumentoTrabalho.Pratica, produtor: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercício: \(p.capacidade)").font(Tema.barra)
            Text("Preparado por \(produtor)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            // O modelo às vezes repete a capacidade na situação: não mostrar duas vezes.
            if p.situacao != p.capacidade {
                Text("Situação: \(p.situacao)").font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            Text("O que fazer").font(Tema.barra)
            Text(p.enunciado).textSelection(.enabled)
                .accessibilityIdentifier("pratica-enunciado")
            Text("Exemplo resolvido, de outro caso — não é a sua resposta").font(Tema.barra)
            Text(p.exemplo).textSelection(.enabled)
                .accessibilityIdentifier("pratica-exemplo")
            Text("Como conferir o seu desempenho").font(Tema.barra)
            ForEach(p.criterios) { c in Text("• \(c.texto)").font(Tema.meta) }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
    }

    /// O campo começa VAZIO e a IA nunca o preenche. Guardar acrescenta uma
    /// tentativa ligada à anterior; a primeira nunca é sobrescrita, e guardar
    /// não marca ação executada nem capacidade adquirida. Sem exercício
    /// (`artefatoID` nil) a tentativa é prática por conta própria, sem feedback.
    private func tentativas(artefatoID: UUID?, pratica p: DocumentoTrabalho.Pratica?,
                            oficina o: OficinaTrabalho) -> some View {
        let guardadas = o.documento.tentativas(doArtefato: artefatoID)
        return VStack(alignment: .leading, spacing: 16) {
            campo("Minha tentativa", chave: "tentativa", exemplo: "Escreva aqui a sua resposta")
                // A tentativa é o texto da pessoa, no idioma que ela pratica: o
                // corretor do sistema reescrevendo-a é o que a ADR proíbe à IA.
                .autocorrectionDisabled()
                .accessibilityIdentifier("pratica-tentativa")
            campo("Que apoio você usou?", chave: "apoio-usado", exemplo: "Ex.: olhei o exemplo")
                .accessibilityIdentifier("pratica-apoio-usado")
            Button(guardadas.isEmpty ? "Guardar minha tentativa" : "Guardar esta nova tentativa") {
                let texto = rascunhos["tentativa"] ?? "", apoio = rascunhos["apoio-usado"] ?? ""
                guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                if o.guardarTentativa(texto, apoioUtilizado: apoio, artefatoID: artefatoID,
                                     anteriorID: guardadas.last?.id) {
                    limpar(["tentativa", "apoio-usado"])
                }
            }
            .disabled(!o.salvo || vazio("tentativa") || vazio("apoio-usado"))
            .accessibilityIdentifier("pratica-guardar-tentativa")
            Text("Guardar preserva a sua resposta como sua. Não marca a ação como realizada nem declara capacidade adquirida.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            if !guardadas.isEmpty {
                Text("Tentativas (\(guardadas.count))").font(Tema.barra)
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
                ForEach(e.tentativa?.conferencias ?? []) { c in feedback(c, pratica: p) }
            }
            if ultima { botaoDoFeedback(e, comExercicio: p != nil, oficina: o) }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) { Rectangle().fill(Tema.linha).frame(height: 1) }
    }

    /// Decisão (b), como em 05q: "Conferir minha tentativa" só com conta Grok.
    /// Sem conta ou sem exercício a linha de recusa já está no material acima;
    /// aqui não se repete. "Nova tentativa" é da pessoa e fica sempre.
    @ViewBuilder private func botaoDoFeedback(_ e: DocumentoTrabalho.Evidencia, comExercicio: Bool,
                                              oficina o: OficinaTrabalho) -> some View {
        if !comExercicio || PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) != nil {
            botaoNovaTentativa
        } else if o.conferindoTentativa {
            ProgressView("A IA está conferindo sua tentativa…").font(Tema.meta)
                .accessibilityIdentifier("pratica-conferindo")
        } else {
            Button("Conferir minha tentativa") {
                guard acesso.permitido, o.verificarAcesso(), o.salvo else { revalidar(); return }
                o.conferirTentativa(e.id)
            }
            .disabled(!o.salvo)
            .accessibilityIdentifier("pratica-conferir-tentativa")
            botaoNovaTentativa
        }
    }

    private var botaoNovaTentativa: some View {
        Button("Nova tentativa") {
            definir("tentativa", "")
            definir("apoio-usado", "")
            campoEmFoco = "tentativa"
            rolarPara = "tentativa"
        }
        .accessibilityIdentifier("pratica-nova-tentativa")
    }

    private func feedback(_ c: DocumentoTrabalho.ConferenciaTentativa, pratica p: DocumentoTrabalho.Pratica) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 12) {
                if let motivo = c.motivo {
                    Text(motivo).font(Tema.meta).foregroundStyle(Tema.aviso)
                }
                ForEach(c.resultados) { r in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.criterios.first { $0.id == r.criterioID }?.texto ?? "Critério removido")
                            .font(Tema.barra)
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
            }.padding(.top, 8)
        } label: {
            Text(PraticaTrabalho.linha(c))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(Tema.meta)
        .accessibilityIdentifier("pratica-feedback")
    }

    /// Em prática sem conta Grok (decisão b) a seção some: não há botão de IA
    /// a oferecer, e a linha que diz por quê já está em Praticar.
    @ViewBuilder private func producao(_ o: OficinaTrabalho) -> some View {
        if !o.documento.praticaPedida || PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) == nil {
            producaoComIA(o)
        }
    }

    private func producaoComIA(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titulo(o.documento.praticaPedida ? "Preparar um exercício" : "Preparar uma versão")
            campo(o.documento.praticaPedida ? "O que você quer praticar?" : "O que você quer que a IA prepare ou ajuste?",
                  chave: "pedido", exemplo: o.documento.praticaPedida ? "Quero praticar me apresentar em espanhol" : "Prepare uma apresentação curta")
                .accessibilityIdentifier("trabalho-pedido")
            if edicaoPendente(o) {
                Text("Guarde a intenção ou a versão que está editando antes de pedir uma nova preparação.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            if o.documento.pedidoAtivo != nil {
                ProgressView("A IA está preparando…")
                    .accessibilityIdentifier("trabalho-preparando")
                Button("Cancelar preparação") { o.cancelar() }
            } else {
                Button(o.documento.praticaPedida ? "Preparar exercício com IA" : o.documento.versaoAtual == nil ? "Preparar com IA" : "Preparar nova versão com IA") {
                    o.gerar(rascunhos["pedido"] ?? "")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!o.salvo || vazio("pedido") || edicaoPendente(o))
                .accessibilityIdentifier("trabalho-gerar")
                if let pedido = o.documento.pedidos.last,
                   pedido.estado == .interrompido || pedido.estado == .falhou || pedido.estado == .cancelado {
                    Text("A preparação anterior foi \(pedido.estado == .interrompido ? "interrompida" : pedido.estado == .falhou ? "malsucedida" : "cancelada"). O pedido continua disponível.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    Button("Retomar esse pedido") { definir("pedido", pedido.instrucao) }
                } else if let pedido = o.documento.pedidos.last, pedido.estado == .praticaIndisponivel {
                    // O porquê já está na seção Praticar; aqui só a saída.
                    Button("Retomar esse pedido") { definir("pedido", pedido.instrucao) }
                }
            }
            if o.documento.versaoAtual == nil {
                DisclosureGroup("Escrever minha própria versão") {
                    VStack(alignment: .leading, spacing: 12) {
                        campo("Sua versão", chave: "versao")
                        Button("Guardar minha versão") { guardarVersao(o) }
                            .disabled(!o.salvo || vazio("versao"))
                    }.padding(.top, 8)
                }
            }
        }
    }

    private func artefato(_ a: DocumentoTrabalho.Artefato, oficina o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titulo("Versão \(numero(a.id, em: o.documento))")
            Text(a.produtor).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            conferencia(a, oficina: o)
            if a.intencaoID != o.documento.intencaoAtual.id {
                Text("Esta versão foi preparada para uma intenção anterior. Confira o que ainda serve.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            if a.pratica != nil {
                Text("O exercício está na seção Praticar, acima.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            } else {
                ConteudoTrabalhoView(fonte: a.conteudo)
                    .id(a.id)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("trabalho-artefato")
            }
            if editandoVersao || !vazio("versao") {
                campo("Editar a versão", chave: "versao", padrao: a.conteudo)
                    .accessibilityIdentifier("trabalho-editar-versao")
                Button("Guardar como nova versão") { guardarVersao(o) }
                    .disabled(!o.salvo || vazio("versao"))
            } else {
                Button("Editar esta versão") { definir("versao", a.conteudo); editandoVersao = true }
            }
        }
        .padding(16)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
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
                    Button("Conferir") { conferir(a, pedido: pedido.id, oficina: o) }
                        .accessibilityIdentifier("trabalho-conferir-primeira")
                    botaoDaIA(a, pedido: pedido.id, oficina: o)
                }
            }
            .accessibilityIdentifier("trabalho-sem-conferencia")
        }
        ForEach(registros) { c in
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 12) {
                    if let motivo = c.motivo {
                        Text(motivo).font(Tema.meta).foregroundStyle(Tema.aviso)
                    }
                    let comTrecho = primeiraPorFonte(c.resultados)
                    ForEach(c.resultados) { r in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.criterio).font(Tema.barra)
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
                    Text(rodape(c)).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    if let ajuste = ConferenciaTrabalho.pedidoDeAjuste(c) {
                        Button("Pedir ajuste") {
                            guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                            definir("pedido", ajuste)
                            campoEmFoco = "pedido"
                            rolarPara = "pedido"
                        }
                        .accessibilityIdentifier("trabalho-pedir-ajuste")
                    }
                    if !daIA(c) {
                        Button("Conferir de novo") { conferir(a, pedido: c.pedidoID, oficina: o) }
                            .disabled(!o.salvo)
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
            Button("Conferir com IA") {
                guard acesso.permitido, o.verificarAcesso(), o.salvo else { revalidar(); return }
                o.revisarComIA(a.id, pedidoID: pedido)
            }
            .disabled(!o.salvo)
            .accessibilityIdentifier("trabalho-conferir-ia")
        }
    }

    private func conferir(_ a: DocumentoTrabalho.Artefato, pedido: UUID, oficina o: OficinaTrabalho) {
        guard acesso.permitido, o.verificarAcesso(), o.salvo else { revalidar(); return }
        o.conferir(a.id, pedidoID: pedido)
    }

    private func daIA(_ c: DocumentoTrabalho.Conferencia) -> Bool {
        c.executor.hasSuffix(RevisaoTrabalho.sufixoDoExecutor) || c.executor == RevisaoTrabalho.naoExecutada
    }

    private func rodape(_ c: DocumentoTrabalho.Conferencia) -> String {
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

    private func atos(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            titulo("Próximo ato")
            campo("O que você vai fazer com este trabalho?", chave: "acao", exemplo: "Ensaiar a apresentação")
                .accessibilityIdentifier("trabalho-acao")
            Button("Preparar este ato") {
                let texto = rascunhos["acao"] ?? ""
                aplicar(o, limpar: ["acao"]) { try $0.prepararAcao(texto) }
            }
            .disabled(!o.salvo || vazio("acao"))
            .accessibilityIdentifier("trabalho-preparar-acao")
            Text("Preparar não marca como realizado. Você pode escolher um horário para cada ação.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            ForEach(o.documento.acoes) { acao in
                VStack(alignment: .leading, spacing: 12) {
                    Text(acao.texto).font(Tema.barra)
                    Text(acao.estado == .executada ? "Você marcou como realizada" : acao.estado == .cancelada ? "Cancelado" : "Realização ainda não confirmada")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    if let id = acao.artefatoID {
                        Text("Material: versão \(numero(id, em: o.documento))")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    }
                    AgendamentoAcaoView(acao: acao, podeGuardar: o.salvo, aviso: o.avisos[acao.id],
                                        permissaoNegada: o.permissaoNegada, guardar: { data, aviso in
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
                            Button("Realizei esta ação") { aplicar(o) { try $0.marcarExecutada(acao.id) } }
                                .disabled(!o.salvo)
                                .accessibilityIdentifier("trabalho-marcar-realizada")
                        }
                        let chave = "relato-\(acao.id.uuidString)"
                        campo("O que aconteceu?", chave: chave, exemplo: "O que funcionou ou faltou")
                        Button("Registrar meu relato") {
                            let texto = rascunhos[chave] ?? ""
                            aplicar(o, limpar: [chave]) { try $0.registrarRelato(texto, acaoID: acao.id) }
                        }
                        .disabled(!o.salvo || vazio(chave))
                        .accessibilityIdentifier("trabalho-registrar-relato")
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) { Rectangle().fill(Tema.linha).frame(height: 1) }
                .id(acao.id)
            }
        }
    }

    /// Só relatos: a tentativa já está em Praticar, e a dificuldade (hipótese,
    /// com autoria) também — o bloco antigo, que criava hipótese sem autor e
    /// apontava todas as evidências como pertinentes, saiu (volta 6, P2-B).
    @ViewBuilder private func retorno(_ o: OficinaTrabalho) -> some View {
        let relatos = o.documento.evidencias.filter { $0.tentativa == nil }
        if !relatos.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                titulo("O que aconteceu")
                ForEach(relatos) { e in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Relato de \(e.atribuidaA) · \(e.data.formatted(date: .abbreviated, time: .shortened))")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        Text(e.texto).textSelection(.enabled)
                    }
                }
                if !o.documento.praticaPedida || PraticaTrabalho.oferta(contaLigada: ContaGrok.ligada) == nil {
                    Button("Revisar com estes relatos") {
                        definir("pedido", "Revise a versão à luz dos relatos registrados e do resultado desejado. Diferencie o que foi observado do que ainda é incerto e proponha um ajuste concreto.")
                        o.gerar(rascunhos["pedido"] ?? "")
                    }
                    .disabled(!o.salvo || o.documento.pedidoAtivo != nil || edicaoPendente(o))
                    .accessibilityIdentifier("trabalho-revisar")
                }
            }
        }
    }

    private func historico(_ o: OficinaTrabalho) -> some View {
        DisclosureGroup("Histórico de versões (\(o.documento.artefatos.count))") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(o.documento.artefatos.reversed()) { a in
                    DisclosureGroup("Versão \(numero(a.id, em: o.documento)) · \(a.produtor)") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(a.conferencias ?? []) { c in
                                Text(daIA(c) ? RevisaoTrabalho.linha(c) : ConferenciaTrabalho.linha(c))
                                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            }
                            ConteudoTrabalhoView(fonte: a.conteudo)
                                .id(a.id)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.padding(.top, 8)
                    }
                }
            }.padding(.top, 8)
        }
    }

    private func titulo(_ texto: String) -> some View {
        Text(texto).font(Tema.secaoNota).accessibilityAddTraits(.isHeader)
    }

    private func campo(_ titulo: String, chave: String, padrao: String = "", exemplo: String = "Escreva aqui") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            TextField(exemplo, text: Binding(get: { rascunhos[chave] ?? padrao },
                                           set: { definir(chave, $0) }), axis: .vertical)
                .lineLimit(2...12)
                .id(chave)
                .focused($campoEmFoco, equals: chave)
                .padding(12)
                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
                .accessibilityLabel(titulo)
        }
    }

    private func vazio(_ chave: String) -> Bool {
        (rascunhos[chave] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func edicaoPendente(_ o: OficinaTrabalho) -> Bool {
        (rascunhos["intencao"].map { $0 != o.documento.intencaoAtual.texto } ?? false)
        || (rascunhos["resultado"].map { $0 != o.documento.intencaoAtual.resultado } ?? false)
        || !vazio("versao")
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
        guard o.salvo else { return }
        if o.alterar(mudanca) { limpar(chaves) }
        else if !o.salvo { limparAposCommit = chaves }
    }

    private func guardarVersao(_ o: OficinaTrabalho) {
        let texto = rascunhos["versao"] ?? ""
        aplicar(o, limpar: ["versao"]) { try $0.guardarVersaoHumana(texto) }
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

private struct AcaoTrabalhoStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Tema.chrome)
            .foregroundStyle(Tema.ambarTinta)
            .frame(minHeight: Tema.alvo, alignment: .leading)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
