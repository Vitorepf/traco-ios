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
    @State private var escolherPasta = false
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
                    ajustes.emCartao()
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
        .task { estado = await ContaGrok.estado() }
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
                        .frame(minHeight: Tema.alvo)
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
                .frame(minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())
                .padding(.top, 6)
                .accessibilityIdentifier("sair-conta")
            } else {
                Button(entrando ? "esperando aprovação…" : "Entrar com a conta Grok") {
                    entrar()
                }
                .font(Tema.chrome)
                .foregroundStyle(Tema.ambarTinta)
                .frame(minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())
                .disabled(entrando)
                .padding(.top, 6)
                .accessibilityIdentifier("entrar-conta")
            }

            Text("A análise e a sábia usam a sua assinatura do Grok — sem chave de API, sem cobrança por uso. Com a conta: a linha “?” responde num cartão, “Vestir tudo” refina a forma, e “Instigar” devolve perguntas. Notas trancadas e expressivas jamais vão à rede.")
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
                set: { Ancora.gravar(.noite, hora: $0) }
            ))
        }
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
            Text("O backup automático grava no app Arquivos a cada nota concluída — nada disso depende de nuvem nem de conta. Se escolher uma pasta, a mesma cópia vai para lá; o Traço só escreve, nunca lê de volta.")
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
