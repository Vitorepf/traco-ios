import SwiftData
import SwiftUI
import UIKit

/// Meu perfil (SPEC §18): conta e ajustes num lugar só.
/// Não existe chave de API nem cobrança por token — a análise com Grok anda
/// pela ASSINATURA do autor (ADR 2026-08-31k).
struct PerfilView: View {
    var sessao: Sessao
    /// O calendário do Traço é ajuste, e ajuste mora aqui (§20). A engrenagem
    /// e o "⋯" ocupavam a cabeça do calendário permanentemente para coisas que
    /// se mexem uma vez na vida — e o "⋯" ainda era duplicata do "+" do campo.
    var agenda: CalendarioAgenda
    @Environment(\.openURL) private var abrir

    @State private var ligada = ContaGrok.ligada
    @State private var estado: String?
    @State private var codigo: ContaGrok.Codigo?
    @State private var entrando = false
    @State private var tarefa: Task<Void, Never>?
    @State private var corpusURL: URL?
    @State private var importarMd = false
    @State private var escolherPasta = false
    @State private var sistema = CalendarioSistema()
    @State private var avisosLigados = false
    /// ADR 04b: quanto do teto de 64 do iOS já está gasto.
    @State private var orcamentoDosAvisos = ""
    /// ADR 04e: o modo férias, em estado local para a tela responder no toque.
    @State private var feriasLigado = Ferias.ligado
    @State private var feriasAte: Date? = Ferias.ate
    @State private var feriasNosFeriados = Ferias.incluiFeriados
    @State private var estadoDasFerias = Ferias.emPalavras()
    @State private var confirmarApagarCalendario = false
    /// ADR 04h/04i: o que o Traço aprendeu, e o retrato exatamente como viaja.
    @State private var retratoLigado = Retrato.ligado
    @State private var retratoTexto = ""
    @State private var sinaisEmPalavras = Sinais.emPalavras()
    @State private var formasSugeridas: [Gesto] = []
    @State private var degrausEmPalavras = ""
    @State private var confirmarEsquecer = false
    /// ADR 04n: o índice de sentido, em número.
    @State private var indiceQuantas = Indice.quantas
    @State private var mostrarMetodos = false
    /// ADR 05x: o método cuja proveniência está aberta na lista. Um por vez.
    @State private var provenienciaAberta: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var context
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]

    var body: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
            TituloTela("Perfil")
            ScrollView {
                VStack(alignment: .leading, spacing: Tema.entreSecoes) {
                    conta.emCartao()
                    permissoes.emCartao()
                    calendario.emCartao()
                    ajustes.emCartao()
                    sabiaEVoce.emCartao()
                    metodos.emCartao()
                    // as férias vêm DEPOIS dos ajustes de todo dia: primeiro o
                    // que vale sempre, depois a exceção (serial-position, e o
                    // fluxo do Perfil provou que o contrário empurra a análise
                    // automática para fora da primeira tela)
                    ferias.emCartao()
                    dados.emCartao()
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
            }
            }
        }
        .fileImporter(isPresented: $escolherPasta, allowedContentTypes: [.folder]) { resultado in
            guard case .success(let url) = resultado else { return }
            if PastaEspelho.guardar(url) {
                Corpus.escreverEspelho(fatias: notas.map(FatiaCorpus.de))
                Toque.suave()
            } else {
                sessao.mostrarToast("não consegui guardar essa pasta.")
            }
        }
        .fileImporter(isPresented: $importarMd,
                      allowedContentTypes: [.plainText, .init(filenameExtension: "md") ?? .plainText],
                      allowsMultipleSelection: true) { resultado in
            guard case .success(let urls) = resultado else { return }
            var itens: [(texto: String, gestoNome: String?, criadaEm: Date)] = []
            for url in urls {
                let acesso = url.startAccessingSecurityScopedResource()
                defer { if acesso { url.stopAccessingSecurityScopedResource() } }
                guard let conteudo = try? String(contentsOf: url, encoding: .utf8) else { continue }
                itens.append(contentsOf: Corpus.importar(conteudo))
            }
            _ = sessao.importarCorpus(itens, no: context)
        }
        .sheet(isPresented: Binding(get: { corpusURL != nil }, set: { if !$0 { corpusURL = nil } })) {
            if let corpusURL {
                CompartilharArquivo(url: corpusURL)
            }
        }
        .onDisappear { tarefa?.cancel() }
        .task {
            estado = await ContaGrok.estado()
            lerRetrato()
        }
        .confirmationDialog("Esquecer tudo o que o Traço aprendeu de você?",
                            isPresented: $confirmarEsquecer, titleVisibility: .visible) {
            Button("Esquecer", role: .destructive) {
                Sinais.esquecerTudo()
                lerRetrato()
                Toque.fechou()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Os sinais somem do aparelho. As notas ficam.")
        }
        .sheet(isPresented: $mostrarMetodos) { listaDeMetodos }
    }

    // MARK: - A sábia e você (ADR 04h, 04i, 04j)

    private func lerRetrato() {
        let sinais = Sinais.todos()
        sinaisEmPalavras = Sinais.emPalavras()
        let lidas = notas.map {
            Retrato.NotaLida(gesto: $0.gesto, fechada: $0.fechada, expressiva: $0.gesto == .expressiva,
                             criadaEm: $0.criadaEm, campos: $0.campos)
        }
        retratoTexto = Retrato.ler(notas: lidas, sinais: sinais)
        formasSugeridas = Gesto.allCases.filter { $0 != .expressiva && Sinais.sugerirEmVezDeVestir($0, sinais: sinais) }
        degrausEmPalavras = Degraus.emPalavras(sinais: sinais)
        indiceQuantas = Indice.quantas
    }

    private var sabiaEVoce: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("A SÁBIA E VOCÊ")
            chave("A sábia conhece você",
                  "Um retrato feito só com as suas palavras e contagens viaja junto de cada pergunta: as formas que usa, os obstáculos que nomeou, o que não voltou no Recordar. Nunca conclui, nunca pontua.",
                  id: "ajuste-retrato",
                  ligado: Binding(
                    get: { retratoLigado },
                    set: { novo in
                        retratoLigado = novo
                        Retrato.ligado = novo
                        Toque.leve()
                    }))
            if retratoLigado {
                Text(retratoTexto.isEmpty ? "ainda não há retrato — ele nasce das suas notas e dos sinais." : retratoTexto)
                    .font(.footnote)
                    .foregroundStyle(retratoTexto.isEmpty ? Tema.tintaFraca : Tema.tintaSuave)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("retrato")
                    .accessibilityLabel("O retrato, exatamente como viaja")
            }
            VStack(alignment: .leading, spacing: 4) {
                // ADR 06h: o que está embaixo é contagem (12 sinais desde…),
                // e a VISAO manda distinguir observação de conclusão.
                Text("O que o Traço registrou — contagem, não conclusão")
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tinta)
                Text(sinaisEmPalavras)
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
                    .accessibilityIdentifier("sinais")
                if !degrausEmPalavras.isEmpty {
                    // ADR 04x: o autor vê o que a sábia vai cobrar dele
                    Text("O que a sábia cobra, por forma: " + degrausEmPalavras)
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaSuave)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("degraus")
                }
                if !formasSugeridas.isEmpty {
                    Text("Você soltou três vezes seguidas: " + formasSugeridas.map(\.nome).joined(separator: ", ")
                         + ". Por isso o Traço passou a sugerir em vez de vestir. Abrir uma por vontade própria devolve o vestir.")
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaSuave)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("formas-sugeridas")
                }
            }
            .padding(.top, 4)
            linhaAcao("Esquecer tudo") { confirmarEsquecer = true }
                .accessibilityIdentifier("esquecer-sinais")
        }
    }

    // MARK: - Métodos (ADR 04l)

    private var metodos: some View {
        let doApp = Catalogo.doApp.count
        let doAutor = Catalogo.doAutor.count
        let problemas = Catalogo.problemas
        return VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("MÉTODOS")
            linhaAcao("\(doApp) do app" + (doAutor > 0 ? " · \(doAutor) seu\(doAutor == 1 ? "" : "s")" : "")) {
                mostrarMetodos = true
            }
            .accessibilityIdentifier("metodos")
            if !problemas.isEmpty {
                ForEach(problemas, id: \.self) { p in
                    Text("não entrou — " + p)
                        .font(.footnote)
                        .foregroundStyle(Tema.aviso)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("Cada método é um arquivo. Os seus vivem em Arquivos › Traço › metodos, ou em metodos/ na pasta espelhada: um JSON com id, nome, campos e o movimento que a sábia cobra. O app lê ao abrir.")
                .font(.footnote)
                .foregroundStyle(Tema.tintaFraca)
        }
    }

    private var listaDeMetodos: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Métodos")
                    .font(Tema.tituloTela)
                    .tracking(Tema.trackingTitulo)
                    .foregroundStyle(Tema.tinta)
                Spacer()
                Button("Pronto") { mostrarMetodos = false }
                    .font(Tema.barra)
                    .foregroundStyle(Tema.tinta)
            }
            .padding(.horizontal, Tema.margem)
            .padding(.top, 20)
            .padding(.bottom, 12)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Catalogo.todos) { m in
                        let aberta = provenienciaAberta == m.id
                        VStack(alignment: .leading, spacing: 3) {
                            // ADR 05x: a linha inteira abre "de onde vem"; o alvo
                            // de 44 vive no toque, não numa linha a mais (G3, B7).
                            Button {
                                provenienciaAberta = aberta ? nil : m.id
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text(m.nome)
                                            .font(Tema.corpo.weight(.semibold))
                                            .foregroundStyle(Tema.tinta)
                                            .layoutPriority(1)
                                        if m.doAutor {
                                            Text("SEU")
                                                .font(.system(size: 9, weight: .semibold))
                                                .tracking(0.8)
                                                .foregroundStyle(Tema.ambarTinta)
                                        }
                                        Spacer(minLength: 0)
                                        Text(m.origem)
                                            .font(Tema.label)
                                            .foregroundStyle(Tema.tintaFraca)
                                        Image(systemName: "chevron.down")
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(Tema.tintaSuave)
                                            .rotationEffect(.degrees(aberta ? 180 : 0))
                                            .accessibilityHidden(true)
                                    }
                                    Text(m.campos.map(\.rotulo).joined(separator: " · "))
                                        .font(.footnote)
                                        .foregroundStyle(Tema.tintaSuave)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .alvo()
                            }
                            .buttonStyle(.discreto)
                            .accessibilityIdentifier("de-onde-vem-\(m.id)")
                            .accessibilityHint(aberta ? "Recolhe" : "De onde vem: fonte, função, o que o Traço adaptou e a evidência")
                            .accessibilityValue(aberta ? "aberto" : "recolhido")
                            if aberta {
                                LinhasDeProveniencia(m, identificador: "proveniencia-\(m.id)")
                                    .padding(.top, 8)
                                    .padding(.bottom, 6)
                                    .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
                            }
                        }
                    }
                }
                // A lei da casa (ADR 05v), como na Lente. Aqui a animação mora na
                // folha e não no toque: `withAnimation` do PerfilView não atravessa
                // a fronteira da apresentação do `.sheet` — medido, 1 quadro.
                .animation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: provenienciaAberta)
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.superficie)
    }

    // MARK: - Conta

    private var conta: some View {
        // spacing 0 e folgas por GRUPO: com um vão igual entre os cinco irmãos,
        // o nome, o estado, a ação e a nota de rodapé pareciam quatro coisas
        // soltas — e o cartão ficava alto e oco ao lado dos vizinhos. São três
        // grupos: quem é a conta, o que fazer, e a letra miúda
        // (law-of-proximity).
        VStack(alignment: .leading, spacing: 0) {
            rotulo("CONTA")
            // nome e estado são UMA coisa: a conta e como ela está
            Text("Grok")
                .font(Tema.chrome.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .padding(.top, Tema.entreItens)
            Text(estado ?? "verificando…")
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .padding(.top, 2)
                .accessibilityIdentifier("estado-conta")

            if let codigo {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aprove no navegador com este código:")
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaSuave)
                    Text(codigo.userCode)
                        .font(.title.monospaced().weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("codigo-dispositivo")
                    Button("Abrir a página de aprovação") { abrir(codigo.url) }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .alvo()
                        .buttonStyle(PressaoDiscreta())
                }
                .padding(14)
                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
                .padding(.top, Tema.entreItens)
            }

            // a AÇÃO, separada de quem a conta é
            if ligada {
                Button("Sair da conta — voltar ao motor local") {
                    ContaGrok.sair()
                    ligada = false
                    codigo = nil
                    Task { estado = await ContaGrok.estado() }
                }
                // peso de AÇÃO: idêntico ao parágrafo explicativo, a única
                // ação do cartão lia como prosa (visto na captura do dono no
                // iPhone real, 01/set — critique-affordance). Discreta segue
                // sendo (sair é raro); tocável precisa parecer.
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Tema.tintaSuave)
                .alvo()
                .buttonStyle(PressaoDiscreta())
                .padding(.top, 6)
                .accessibilityIdentifier("sair-conta")
            } else {
                Button(entrando ? "esperando aprovação…" : "Entrar com a conta Grok") {
                    entrar()
                }
                .font(Tema.chrome)
                .foregroundStyle(Tema.ambarTinta)
                .alvo()
                .buttonStyle(PressaoDiscreta())
                .disabled(entrando)
                .padding(.top, 6)
                .accessibilityIdentifier("entrar-conta")
            }

            if #available(iOS 26.0, *) {
                Rectangle().fill(Tema.linha).frame(height: 0.5)
                VStack(alignment: .leading, spacing: 2) {
                    Text("No aparelho")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                    Text(AnaliseDeBordo.estadoEmPalavras)
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaFraca)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("estado-de-bordo")
            }
            Text("A análise e a sábia usam a sua assinatura do Grok — sem chave de API, sem cobrança por uso. Sem a conta, a sábia responde pelo modelo do aparelho (Apple Intelligence), sem rede, com uma janela menor. Hoje: " + Sabia.porOndeEmPalavras + ". Notas trancadas e expressivas jamais vão à rede.")
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaFraca)
                .frame(maxWidth: 280, alignment: .leading)
                .padding(.top, Tema.entreItens)
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

    /// ADR 2026-09-03c/d: o calendário do sistema e as notificações têm de ter
    /// ESTADO e VOLTA aqui. Sem isto, quem tocou "Não Permitir" uma vez ficava
    /// num beco: o app parava de sugerir e nunca dizia por quê.
    private var permissoes: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("PERMISSÕES")
            VStack(alignment: .leading, spacing: 4) {
                Text("Calendários do aparelho")
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                Text(sistema.estadoEmPalavras)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("estado-calendario")
            }
            Text("Apple, Google, iCloud — o Traço lê todos os que estão em Ajustes › Apps › Calendário › Contas, e nunca escreve em nenhum. Serve para o campo do calendário já sugerir o seu próximo compromisso.")
                .font(.footnote)
                .foregroundStyle(Tema.tintaFraca)
            if sistema.negado || !avisosLigados {
                Button("Abrir os Ajustes do Traço") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { abrir(url) }
                }
                .font(Tema.chrome.weight(.semibold))
                .foregroundStyle(Tema.ambarTinta)
                .alvo()
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("abrir-ajustes")
                .accessibilityHint("O iOS só deixa mudar uma permissão negada por lá")
            }
            Rectangle().fill(Tema.linha).frame(height: 0.5)
            VStack(alignment: .leading, spacing: 4) {
                Text("Avisos")
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                Text(avisosLigados
                     ? "ligados — o Recordar, a revisão de domingo e os seus compromissos cobram na hora."
                     : "desligados. Sem eles, nada te cobra: nem o Recordar, nem os compromissos.")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("estado-avisos")
                // ADR 04b: o iPhone guarda 64 pendentes e descarta o resto em
                // SILÊNCIO. Um app que promete cobrar tem de mostrar quanto já
                // prometeu — senão o teto vira a mesma mentira da ADR 04a.
                if !orcamentoDosAvisos.isEmpty {
                    Text(orcamentoDosAvisos)
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("orcamento-avisos")
                }
            }
        }
        .task {
            await sistema.pedirAcesso()
            avisosLigados = await Revisoes.autorizadaParaAvisar()
            orcamentoDosAvisos = await Avisos.emPalavras()
        }
    }

    /// O calendário do Traço — o do aparelho é a seção de cima, e a diferença
    /// entre os dois é a linha que explica: este vive aqui e não sincroniza.
    private var calendario: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("CALENDÁRIO")
            Toggle(isOn: Binding(
                get: { agenda.segundaPrimeiro },
                set: { agenda.segundaPrimeiro = $0 }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Semana começa na segunda")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                    Text("O calendário do Traço vive no aparelho. Não sincroniza, e nunca escreve numa nota.")
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaFraca)
                }
            }
            .tint(Tema.ambar)
            .accessibilityIdentifier("ajustes-segunda")
            Rectangle().fill(Tema.linha).frame(height: 0.5)
            HStack {
                Text(agenda.eventos.count == 1 ? "1 compromisso" : "\(agenda.eventos.count) compromissos")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                Spacer()
                Button("Apagar tudo", role: .destructive) { confirmarApagarCalendario = true }
                    .font(Tema.meta)
                    .foregroundStyle(Tema.aviso)
                    .disabled(agenda.eventos.isEmpty)
                    .accessibilityIdentifier("ajustes-apagar-tudo")
            }
            .alvo()
        }
        .confirmationDialog("Apagar todos os compromissos?",
                            isPresented: $confirmarApagarCalendario, titleVisibility: .visible) {
            Button("Apagar tudo", role: .destructive) { agenda.apagarTudo() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Não volta.")
        }
    }

    /// ADR 2026-09-04e — o modo férias. O Traço cala o que ELE inventou de
    /// cobrar; o que o autor marcou continua tocando.
    private var ferias: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("FÉRIAS")
            chave("Modo férias",
                  "O Traço para de cobrar memória: a fila do Recordar, a revisão de domingo e a série da expressiva esperam. Os seus compromissos continuam avisando — férias não desmarca dentista.",
                  id: "ajuste-ferias",
                  ligado: Binding(
                    get: { feriasLigado },
                    set: { novo in
                        feriasLigado = novo
                        Ferias.ligado = novo
                        // ligar sem data mostrava "Até 11/09" (só o fallback do
                        // seletor) enquanto o estado dizia "sem data": a tela
                        // exibia um valor que não valia. Ligar assume UMA
                        // semana, que é o que se pede quando se viaja; "sem
                        // data" continua sendo escolha explícita logo abaixo.
                        if !novo {
                            feriasAte = nil
                        } else if feriasAte == nil {
                            feriasAte = Calendar.current.date(byAdding: .day, value: 7, to: .now)
                        }
                        Ferias.ate = feriasAte
                        reagendarCobranças()
                    }))

            if feriasLigado {
                DatePicker(
                    "Até",
                    selection: Binding(
                        get: { feriasAte ?? Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now },
                        set: { nova in
                            feriasAte = nova
                            Ferias.ate = nova
                            reagendarCobranças()
                        }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .font(Tema.corpo)
                .tint(Tema.ambarTinta)
                .accessibilityIdentifier("ferias-ate")

                Button("Sem data — desligo eu mesmo") {
                    feriasAte = nil
                    Ferias.ate = nil
                    reagendarCobranças()
                }
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .frame(minHeight: Tema.alvo, alignment: .leading)
                .contentShape(Rectangle())
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("ferias-sem-data")
            }

            chave("E nos feriados",
                  "Desligado, o Traço cobra no feriado também — dia em casa é bom dia para recordar.",
                  id: "ajuste-ferias-feriados",
                  ligado: Binding(
                    get: { feriasNosFeriados },
                    set: { novo in
                        feriasNosFeriados = novo
                        Ferias.incluiFeriados = novo
                        reagendarCobranças()
                    }))

            Text(estadoDasFerias)
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .accessibilityIdentifier("estado-ferias")
        }
    }

    /// Toda mudança do modo reescreve o que está agendado: sem isto, a fila
    /// repetente continuaria tocando na praia (ADR 04a — o estado tem de ser
    /// verdade, não intenção).
    private func reagendarCobranças() {
        estadoDasFerias = Ferias.emPalavras()
        Revisoes.agendarFilaDiaria()
        Revisoes.agendarRevisaoSemanal()
        Toque.leve()
    }

    private var ajustes: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("AJUSTES")
            chave("Análise automática",
                  "A análise chega sozinha na pausa da escrita. Você nunca precisa lembrar do botão.",
                  id: "ajuste-auto-analise",
                  ligado: Binding(
                    get: { sessao.autoAnalise },
                    set: { novo in
                        if novo != sessao.autoAnalise { sessao.alternarAutoAnalise() }
                    }))
            hora("Recordar às", valor: Binding(
                get: { Revisoes.hora },
                set: { Revisoes.hora = $0 }
            ))
            hora("manhã", valor: Binding(
                get: { Ancora.hora(.manha) },
                set: { Ancora.gravar(.manha, hora: $0) }
            ))
            hora("tarde", valor: Binding(
                get: { Ancora.hora(.tarde) },
                set: { Ancora.gravar(.tarde, hora: $0) }
            ))
            hora("noite", valor: Binding(
                get: { Ancora.hora(.noite) },
                set: {
                    Ancora.gravar(.noite, hora: $0)
                    // a revisão de domingo é agendada na hora da NOITE: sem
                    // reagendar, o aviso ficava na hora antiga até o próximo
                    // arranque do app
                    Revisoes.agendarRevisaoSemanal()
                }
            ))
        }
    }

    /// Um ajuste de liga/desliga. A LINHA inteira alterna, não só o
    /// interruptor de 51×31pt no canto (`fitts-law`): o rótulo e a explicação
    /// leem como parte do controle, e o dedo do autor acerta um alvo de 350pt.
    /// O gesto vive no RÓTULO — o interruptor continua consumindo o toque dele,
    /// então nada alterna duas vezes.
    private func chave(_ titulo: String, _ explicacao: String, id: String,
                       ligado: Binding<Bool>) -> some View {
        Toggle(isOn: ligado) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                Text(explicacao)
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { ligado.wrappedValue.toggle() }
        }
        .tint(Tema.ambar)
        .accessibilityIdentifier(id)
    }

    private func hora(_ titulo: String, valor: Binding<Int>) -> some View {
        Stepper(value: valor, in: 0...23) {
            Text("\(titulo) \(valor.wrappedValue)h")
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
        }
        .tint(Tema.tintaSuave)
        .accessibilityLabel(titulo)
        .accessibilityValue("\(valor.wrappedValue) horas")
    }

    // MARK: - Dados (§20: exportar/importar são AÇÃO, não navegação — moram aqui)

    private var dados: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            rotulo("DADOS")
            linhaAcao("Exportar todas as notas (.md)") {
                corpusURL = Corpus.exportar(notas: notas)
            }
            .accessibilityIdentifier("exportar-corpus")
            .accessibilityHint("Gera um Markdown com as notas abertas. Trancadas nunca saem.")
            Rectangle().fill(Tema.linha).frame(height: 0.5)
            linhaAcao("Importar notas (.md)") { importarMd = true }
                .accessibilityIdentifier("importar-md")
                .accessibilityHint("Traz notas de arquivos Markdown. Import nunca cria trancada.")
            Rectangle().fill(Tema.linha).frame(height: 0.5)
            Toggle(isOn: Binding(
                get: { Revisoes.revisaoSemanalLigada },
                set: { ligada in
                    UserDefaults.standard.set(ligada, forKey: Revisoes.chaveRevisaoSemanal)
                    Revisoes.agendarRevisaoSemanal()
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Revisão da semana no domingo")
                        .font(Tema.chrome)
                        .foregroundStyle(Tema.tinta)
                    Text("um aviso sem conteúdo, na hora da noite, abrindo os Padrões")
                        .font(.footnote)
                        .foregroundStyle(Tema.tintaFraca)
                }
            }
            .tint(Tema.ambar)
            .accessibilityIdentifier("revisao-semanal")
            Rectangle().fill(Tema.linha).frame(height: 0.5)
            // ADR 2026-09-02n: a pasta pode viver no iCloud Drive do autor
            // porque é a nuvem DELE — escolhida no seletor do sistema, sem
            // conta do Traço, sem entitlement. Qualquer provedor serve.
            if let nome = PastaEspelho.nome {
                linhaAcao("Espelhando em “\(nome)”") { escolherPasta = true }
                    .accessibilityIdentifier("espelho-pasta")
                    .accessibilityHint("Toque para trocar a pasta")
                linhaAcao("Parar de espelhar") {
                    PastaEspelho.limpar()
                    Toque.leve()
                }
                .accessibilityIdentifier("espelho-parar")
            } else {
                linhaAcao("Espelhar numa pasta (iCloud Drive…)") { escolherPasta = true }
                    .accessibilityIdentifier("espelho-pasta")
                    .accessibilityHint("Escolhe uma pasta sua; o Traço grava lá uma cópia da pasta do segundo cérebro a cada nota concluída")
            }
            // ADR 05s: a cópia que não chegou à pasta não fica muda (ADR 03e)
            if let estadoDoEspelho = PastaEspelho.estado {
                Text(estadoDoEspelho)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("estado-espelho")
            }
            Text("O backup automático grava no app Arquivos a cada nota concluída — nada disso depende de nuvem nem de conta. Se escolher uma pasta, a mesma cópia vai para lá; o Traço só escreve, nunca lê de volta — exceto a subpasta entrada/.")
                .font(.footnote)
                .foregroundStyle(Tema.tintaFraca)
            // ADR 04p: a entrada do Mac
            VStack(alignment: .leading, spacing: 2) {
                Text("Entrada")
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tinta)
                Text("O que o Mac deixa em Traço/entrada (um .md por nota, pelo companheiro MCP ou por qualquer editor) vira nota aberta ao abrir o app. " + Entrada.ultimaEmPalavras)
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("entrada")
            }
            .padding(.top, 4)
            // ADR 04n: o índice de sentido
            VStack(alignment: .leading, spacing: 2) {
                Text("Índice de sentido")
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tinta)
                Text(Indice.disponivel
                     ? "\(indiceQuantas) \(indiceQuantas == 1 ? "nota" : "notas") no índice. Feito no aparelho: a busca acha pelo sentido, os ecos vêm das mais próximas, e a sábia lê o que se parece com a sua pergunta. Trancadas nunca entram."
                     : "este aparelho não tem o modelo de frases em português — a busca pelo sentido e os ecos por proximidade ficam desligados.")
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("indice-sentido")
            }
            .padding(.top, 4)
            if Indice.disponivel {
                linhaAcao("Refazer o índice de sentido") {
                    Indice.apagarTudo()
                    sessao.sincronizarIndice(no: context)
                    Toque.leve()
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        indiceQuantas = Indice.quantas
                    }
                }
                .accessibilityIdentifier("refazer-indice")
            }
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
                    .padding(.trailing, 2)
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

private extension View {
    /// Seção com região própria: sobre preto, espaçamento sozinho não agrupa.
    func emCartao() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .superficieElevada()
    }
}
