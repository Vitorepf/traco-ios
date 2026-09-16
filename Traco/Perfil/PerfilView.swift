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
    /// Sem a barra, o que separa um mês do outro é só o espaço: em AX5 a linha
    /// do mês quebra em três e um vão fixo some dentro da própria entrelinha.
    @ScaledMetric(relativeTo: .subheadline) private var entreMeses: CGFloat = 8
    /// A medida da letra miúda do cartão da conta: 280 pt em `large` são ~45
    /// caracteres, a linha que se lê sem virar o pescoço. Fixa em pontos, em
    /// AX5 ela virava um terço da tela com doze caracteres por linha — e as
    /// listas de quem responde dobravam de altura à toa. Escala com a letra e
    /// o `maxWidth` da tela passa a mandar quando ela cresce.
    @ScaledMetric(relativeTo: .subheadline) private var medidaMiuda: CGFloat = 280

    @State private var ligada = ContaGrok.ligada
    @State private var confirmarSaida = false
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
    /// ADR 06j: as hipóteses do Trabalho entram na latência pela mesma tela.
    @Query private var trabalhos: [Trabalho]
    @State private var serieDaLatencia = Latencia.Serie()
    /// Hermes §5: a densidade se controla no cabeçalho de cada seção. A tabela
    /// de quem responde nasce recolhida: o estado da conta já está nas linhas
    /// de cima, e o cabeçalho a mantém à vista (ADR 10k).
    // Laço de simplicidade (14/09): o que é AJUSTE fica aberto (conta,
    // permissões, férias, ajustes, dados); o que é CONSULTA nasce recolhido —
    // o cabeçalho basta para ser achado, e a página abre em uma tela.
    var recolhidas = Recolhidas("perfil", deInicio: ["quem-responde", "sabia", "latencia", "metodos", "calendario"])

    var body: some View {
        ZStack {
            Tema.fundo.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
            // ADR 10i: a marca de perguntar, a mesma de toda tela do arquivo
            // perguntar mora no campo do pé das Notas (ADR 2026-09-14a); a
            // marca "?" aqui era uma segunda porta para o mesmo lugar
            TituloTela("Perfil")
            ScrollView {
                // Hermes §1 e §4 (ADR 10k): as seções pousam no PAPEL. O
                // cartão em volta de cada uma nomeava o conteúdo com caixa
                // alta dentro de uma caixa; agora o cabeçalho sussurra e
                // agrupa, e as linhas se separam por fio recuado.
                // seções recolhidas se juntam; só a aberta ganha o respiro de seção
                // (auditoria 16/09 noite: cabeçalhos soltos com vãos de ~80 pt)
                VStack(alignment: .leading, spacing: 4) {
                    conta.respiro(recolhidas.aberta("conta"))
                    quemResponde.respiro(recolhidas.aberta("quem-responde"))
                    permissoes.respiro(recolhidas.aberta("permissoes"))
                    calendario.respiro(recolhidas.aberta("calendario"))
                    ajustes.respiro(recolhidas.aberta("ajustes"))
                    sabiaEVoce.respiro(recolhidas.aberta("sabia"))
                    // a latência vem logo depois do retrato: é a mesma família
                    // — o que o autor registrou, em contagem e sem conclusão
                    latencia.respiro(recolhidas.aberta("latencia"))
                    metodos.respiro(recolhidas.aberta("metodos"))
                    // as férias vêm DEPOIS dos ajustes de todo dia: primeiro o
                    // que vale sempre, depois a exceção (serial-position, e o
                    // fluxo do Perfil provou que o contrário empurra a análise
                    // automática para fora da primeira tela)
                    ferias.respiro(recolhidas.aberta("ferias"))
                    dados
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
            }
            .desvanece(topo: 24, pe: 48)
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
            var itens: [Corpus.ItemImportado] = []
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
            lerLatencia()
        }
        .confirmationDialog("Esquecer tudo o que o Traço registrou?",
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
        retratoTexto = Retrato.ler(notas: notas.map(\.paraRetrato), sinais: sinais,
                                  observados: AcessoTrabalho.juizosObservados(de: trabalhos, no: context))
        formasSugeridas = Gesto.allCases.filter { $0 != .expressiva && Sinais.sugerirEmVezDeVestir($0, sinais: sinais) }
        degrausEmPalavras = Degraus.emPalavras(sinais: sinais)
        indiceQuantas = Indice.quantas
    }

    private var sabiaEVoce: some View {
        recolhidas.secao("A sábia e você", id: "sabia") {
            chave("person.text.rectangle", "A sábia conhece você",
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
                // o retrato é CONTEÚDO (é o que viaja), não subtítulo: inteiro
                prosa(retratoTexto.isEmpty ? "ainda não há retrato — ele nasce das suas notas e dos sinais." : retratoTexto,
                      cor: retratoTexto.isEmpty ? Tema.tintaFraca : Tema.tintaSuave)
                    .accessibilityIdentifier("retrato")
                    .accessibilityLabel("O retrato, exatamente como viaja")
            }
            // ADR 06h: o que está embaixo é contagem (12 sinais desde…),
            // e a VISAO manda distinguir observação de conclusão.
            // o título quebra: "contagem, não conclusão" é a frase da 06h e não se corta
            LinhaDeLista("number", "O que o Traço registrou — contagem, não conclusão", sinaisEmPalavras,
                         linhasDoTitulo: nil, fio: degrausEmPalavras.isEmpty && formasSugeridas.isEmpty)
                .accessibilityIdentifier("sinais")
            if !degrausEmPalavras.isEmpty {
                // ADR 04x: o autor vê o que a sábia vai cobrar dele
                prosa("O que a sábia cobra, por forma: " + degrausEmPalavras)
                    .accessibilityIdentifier("degraus")
            }
            if !formasSugeridas.isEmpty {
                prosa("Você soltou três vezes seguidas: " + formasSugeridas.map(\.nome).joined(separator: ", ")
                      + ". Por isso o Traço passou a sugerir em vez de vestir. Abrir uma por vontade própria devolve o vestir.")
                    .accessibilityIdentifier("formas-sugeridas")
            }
            linhaAcao("trash", "Esquecer tudo", "os sinais somem; as notas ficam", destrutiva: true, fio: false) {
                confirmarEsquecer = true
            }
            .accessibilityIdentifier("esquecer-sinais")
        }
    }

    // MARK: - Latência da descoberta (ADR 2026-09-06j)

    /// Nada aqui pede trabalho ao autor: a leitura sai do que ele já escreveu.
    /// ponytail: um `Versoes.listar` por decisão, síncrono — são dezenas de
    /// JSONs pequenos e a tela abre uma vez; se um dia doer, a data da
    /// descoberta vira campo gravado na hora em que "o que aconteceu" enche.
    private func lerLatencia() {
        var registros: [Latencia.Registro] = []
        for t in trabalhos where AcessoTrabalho.permitido(t, no: context) {
            guard let doc = try? t.ler() else { continue }
            registros += Latencia.registros(hipoteses: doc.hipoteses, encerrado: doc.encerrado)
        }
        for n in notas where n.gesto == .decisao {
            // `registro` devolve nil para nota selada: o selo fecha a rota
            if let r = Latencia.registro(decisao: n.uuid, campos: n.campos,
                                         criadaEm: n.criadaEm, fechada: n.fechada) {
                registros.append(r)
            }
        }
        serieDaLatencia = Latencia.serie(registros)
    }

    private var latencia: some View {
        let s = serieDaLatencia
        return recolhidas.secao("Hipóteses em aberto", id: "latencia",
                     // o cabeçalho conta o que o título diz: as em aberto, não as linhas
                     // mostradas ("2" sobre "4 em aberto", auditoria 16/09 noite)
                     contagem: s.abertos.isEmpty ? nil : s.abertos.count) {
            if s.vazia {
                // Hermes §11: o vazio é uma linha normal, não uma cerimônia
                LinhaDeLista("hourglass", "Ainda não há série",
                             "ela nasce quando você propõe uma hipótese num Trabalho ou escreve uma Decisão com data de conferir.")
                    .accessibilityIdentifier("latencia-vazia")
            } else {
                resumo(s)
                if !s.meses.isEmpty { meses(s.meses) }
                registrosDaLatencia(s)
            }
            prosa("Quanto tempo passa entre apostar numa coisa e saber se estava certa. Vem das hipóteses do Trabalho e das decisões com data de conferir; não há nada a preencher aqui.")
                .padding(.top, 8)
        }
    }

    /// A medida é a manchete e vem sozinha; a composição — sem data, em aberto,
    /// abandonadas — desce uma linha e fica mais quieta. Nenhum número sai:
    /// cinco fatos colados por "·" faziam o olho parar no que destoa (o "18"
    /// em aberto) e não na duração (G4 da L1). São duas leituras da MESMA
    /// `emPalavras`, para a copy da série não nascer de novo aqui.
    private func resumo(_ s: Latencia.Serie) -> some View {
        let medida = Latencia.emPalavras(.init(descobertos: s.descobertos))
        let composicao = Latencia.emPalavras(
            .init(abertos: s.abertos, abandonados: s.abandonados, semData: s.semData))
        // a manchete pode ser longa: o título quebra, a composição corta
        return LinhaDeLista("hourglass", medida.isEmpty ? composicao : medida,
                            medida.isEmpty ? nil : composicao, linhasDoTitulo: nil)
            .accessibilityIdentifier("latencia-resumo")
    }

    /// A série: um mês por linha, na ordem do tempo, só em palavras. Não há
    /// barra: normalizada pela série, o pior mês enchia a pista sempre — 300
    /// dias e 1 dia desenhariam igual —, e a única escala honesta seria
    /// absoluta, que em dias não cabe na largura nem informa (ADR 06j, L1-C).
    private func meses(_ lista: [Latencia.Mes]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Teto de doze, e o horizonte dito: a lista de registros já tinha
            // corte e esta não tinha nenhum — no aparelho de quem escreve há
            // anos era o pedaço que crescia sem fim, e é de onde a barra saiu.
            Text("O tempo do meio entre as descobertas de cada mês, nos 12 últimos.")
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaFraca)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: entreMeses) {
                ForEach(lista.suffix(12)) { m in
                    // um valor só não tem "tempo do meio": diz a contagem e a duração
                    Text(m.inicio.formatted(.dateTime.month(.wide).year()) + " · "
                         + (m.quantas == 1
                            ? "1 descoberta · levou " + Latencia.emDias(m.mediana)
                            : Latencia.emDias(m.mediana) + " · \(m.quantas) descobertas"))
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 4)
        // o vão até os registros tem de ser MAIOR que o vão entre os meses,
        // senão em AX5 a primeira linha de registro entra no grupo dos meses
        .padding(.bottom, entreMeses)
        .accessibilityIdentifier("latencia-meses")
    }

    /// Os abertos viajam junto dos fechados: uma série só do que fechou
    /// esconderia justamente o que nunca voltou. O corte é POR ESTADO
    /// (`Latencia.paraTela`) para que os quatro sobrevivam a ele.
    private func registrosDaLatencia(_ s: Latencia.Serie) -> some View {
        let lista = Latencia.paraTela(s)
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(lista) { r in
                // Dois degraus no mesmo sentido: a linha da MEDIDA é o título,
                // a frase da hipótese recua para o subtítulo (G4 da L1). A
                // identidade à esquerda é o ESTADO pela forma — círculo vazio
                // em aberto, relógio devido, visto descoberto, xis abandonado.
                LinhaDeLista(Self.glifo(r.estado),
                             Latencia.rotulo(r.estado) + " · " + medidaDe(r)
                                + (r.autoria.map { " · " + $0 } ?? ""),
                             r.texto.isEmpty ? nil : r.texto,
                             linhasDoTitulo: nil, fio: r.id != lista.last?.id)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("latencia-registros")
    }

    static func glifo(_ estado: Latencia.Estado) -> String {
        switch estado {
        case .afirmado: "circle"
        case .devido: "clock"
        case .descoberto: "checkmark.circle"
        case .abandonado: "xmark.circle"
        }
    }

    private func medidaDe(_ r: Latencia.Registro) -> String {
        switch r.estado {
        case .descoberto:
            // o registro antigo (ADR 05r) diz que não sabe, e não deduz
            guard let d = r.dias else { return "tempo desconhecido" }
            return "levou " + Latencia.emDias(d)
        case .afirmado, .devido:
            let ha = "há " + Latencia.emDias(r.diasEmAberto() ?? 0)
            guard let quando = r.devidoEm else { return ha }
            return ha + " · conferir em " + quando.formatted(date: .abbreviated, time: .omitted)
        case .abandonado:
            return "fechado sem conferir"
        }
    }

    // MARK: - Métodos (ADR 04l)

    private var metodos: some View {
        let doApp = Catalogo.doApp.count
        let doAutor = Catalogo.doAutor.count
        let problemas = Catalogo.problemas
        return recolhidas.secao("Métodos", id: "metodos", contagem: doApp + doAutor) {
            linhaAcao("books.vertical",
                      "\(doApp) do app" + (doAutor > 0 ? " · \(doAutor) seu\(doAutor == 1 ? "" : "s")" : ""),
                      "a lista, e de onde vem cada um", fio: false) {
                mostrarMetodos = true
            }
            .accessibilityIdentifier("metodos")
            if !problemas.isEmpty {
                // `aviso` é ESTADO: o arquivo que falhou
                ForEach(problemas, id: \.self) { p in
                    prosa("não entrou — " + p, cor: Tema.aviso)
                }
            }
            prosa("Cada método é um arquivo em Arquivos › Traço › metodos. Um arquivo novo nessa pasta aparece aqui na próxima vez que o app abrir.")
                .padding(.top, 8)
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
                Button { mostrarMetodos = false } label: { Pilula("Pronto", forma: .acao) }
                    .buttonStyle(.discreto)
            }
            .padding(.horizontal, Tema.margem)
            .padding(.top, 20)
            .padding(.bottom, 12)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Catalogo.todos) { m in
                        let aberta = provenienciaAberta == m.id
                        VStack(alignment: .leading, spacing: 0) {
                            // ADR 05x: a linha inteira abre "de onde vem"; o alvo
                            // de 44 vive no toque, não numa linha a mais (G3, B7).
                            // ADR 10k: o "SEU" em caixa alta e âmbar era etiqueta
                            // pintada; agora quem é do autor se vê pela FORMA do
                            // glifo, e a origem desce ao subtítulo em frase normal.
                            Button {
                                provenienciaAberta = aberta ? nil : m.id
                            } label: {
                                LinhaDeLista(
                                    titulo: m.nome,
                                    subtitulo: ([m.doAutor ? "seu" : "", m.origem] + m.campos.map(\.nome))
                                        .filter { !$0.isEmpty }.joined(separator: " · "),
                                    fio: !aberta,
                                    glifo: { Image(systemName: m.doAutor ? "person.crop.square" : "book.closed") },
                                    acessorio: {
                                        Image(systemName: "chevron.down")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Tema.tintaFraca)
                                            .rotationEffect(.degrees(aberta ? 180 : 0))
                                    })
                            }
                            .buttonStyle(.linha)
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
        // Três linhas: quem é a conta e como ela está; o que fazer com ela; e o
        // motor do aparelho. A letra miúda da política desceu para a seção de
        // baixo, que se recolhe — era ela que fazia deste o cartão mais alto.
        recolhidas.secao("Conta", id: "conta") {
            // nome e estado são UMA coisa: a conta e como ela está
            LinhaDeLista("person.crop.circle", "Grok", estado ?? "verificando…")
                .accessibilityIdentifier("estado-conta")

            if let codigo {
                // o código é o CONTEÚDO desta hora: grande, em tinta, sem caixa
                VStack(alignment: .leading, spacing: 6) {
                    Text("Aprove no navegador com este código:")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                    Text(codigo.userCode)
                        .font(.title.monospaced().weight(.semibold))
                        .foregroundStyle(Tema.tinta)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("codigo-dispositivo")
                }
                .padding(.vertical, 10)
                linhaAcao("safari", "Abrir a página de aprovação", nil) { abrir(codigo.url) }
            }

            // a AÇÃO, separada de quem a conta é — reconhecida pelo chevron,
            // não pelo âmbar (ADR 10k)
            if ligada {
                // sair é destrutivo e pede confirmação (auditoria 16/09 noite:
                // parecia uma linha comum, sem cor nem aviso)
                linhaAcao("rectangle.portrait.and.arrow.right", "Sair da conta",
                          "a IA passa a usar só o aparelho", destrutiva: true) {
                    confirmarSaida = true
                }
                .accessibilityIdentifier("sair-conta")
                .confirmationDialog("Sair da conta Grok?", isPresented: $confirmarSaida, titleVisibility: .visible) {
                    Button("Sair", role: .destructive) {
                        ContaGrok.sair()
                        ligada = false
                        codigo = nil
                        Task { estado = await ContaGrok.estado() }
                    }
                    Button("Ficar", role: .cancel) {}
                } message: {
                    Text("As respostas pelas suas notas e a escolha dos conselhos deixam de funcionar até você entrar de novo.")
                }
            } else {
                linhaAcao("person.badge.key", entrando ? "esperando aprovação…" : "Entrar com a conta Grok",
                          "sem chave de API, sem cobrança por uso") {
                    entrar()
                }
                .disabled(entrando)
                .accessibilityIdentifier("entrar-conta")
            }

            if #available(iOS 26.0, *) {
                LinhaDeLista("iphone", "No aparelho", AnaliseDeBordo.estadoEmPalavras, fio: false)
                    .accessibilityIdentifier("estado-de-bordo")
            }
        }
    }

    /// ADR 07b: a tabela de quem responde, na única tela que fala de provedor.
    /// Função que o autor não vê não foi entregue: o CABEÇALHO fica sempre à
    /// vista logo abaixo da conta, e um toque abre a letra miúda inteira.
    private var quemResponde: some View {
        recolhidas.secao("Quem responde", id: "quem-responde") {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                // "Hoje: pela sua conta" repetia a Conta logo acima (auditoria 16/09 noite)
                Text("A IA usa a sua assinatura do Grok, sem custo por uso; sem a conta, usa o modelo do próprio iPhone. Notas trancadas e expressivas nunca saem do aparelho.")
                VStack(alignment: .leading, spacing: Tema.entreItens) {
                    Text(Self.oQueAIAFaz)
                    Text(Self.oQueAContaAcrescenta)
                    Text(Self.notasAindaSemTela)
                        .accessibilityIdentifier("perfil-notas-sem-tela")
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("quem-responde")
                // A terceira linha: o que ela ainda não faz. Sem ela, a operação
                // cortada sumia das duas listas de cima e o autor via menos coisa
                // sem explicação — resultado pior calado.
                indisponiveisPorQualidade
            }
            .font(Tema.meta)
            .foregroundStyle(Tema.tintaFraca)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: medidaMiuda, alignment: .leading)
            .padding(.top, 4)
        }
    }

    // MARK: - O que a IA faz, e o que ela ainda não faz (volta Q)

    /// ADR 2026-09-09z — as quatro frases do cartão CONTA, fora da `body` para
    /// o teste poder LÊ-LAS. Antes eram literais no meio da view, e o portão
    /// só sabia contar linhas: passava idêntico com o texto velho.
    ///
    /// A língua é a do autor (DIRETRIZ §13): sem data, sem "medida", sem
    /// "reprovou" e sem o nosso plano de obra. O cartão diz o que a IA FAZ por
    /// ele, e a lista do que ela não faz vem depois — não antes.
    static var oQueAIAFaz: String {
        "A IA faz por você, no aparelho e sem conta: "
            + Politica.peloAparelho.map(Politica.nome).joined(separator: ", ") + "."
    }

    static var oQueAContaAcrescenta: String {
        "Com a sua conta Grok, ela faz também: "
            + Politica.pelaConta.filter { $0 != .responderNasNotas }.map(Politica.nome).joined(separator: ", ")
            + ". Nessas, o modelo do aparelho não dá conta sozinho."
    }

    /// DIRETRIZ §14: uma operação não "volta ao autor" pelo motor — volta pela
    /// tela, e a tela da resposta nas Notas foi vista pelo dono antes de
    /// prestar. Até ele aprovar a superfície, o Perfil NÃO promete: a linha
    /// sai de "faz também" e diz, na língua dele, o que está acontecendo. A
    /// operação continua respondendo (a tabela não mudou); o que muda é o que
    /// o cartão afirma. Quem a devolve a `oQueAContaAcrescenta` é a volta que
    /// levar a tela aprovada.
    static let notasAindaSemTela =
        "Responder ao que você pergunta nas Notas: ela já responde com a sua conta, mas a tela em que a resposta chega ainda está sendo acertada."

    static let aberturaSemConserto = "O que ela ainda não faz, nem com a sua conta ligada:"
    static let aberturaEmCorrecao = "Também não faz ainda, e já sabemos o que falta:"
    static let nadaCortado = "Não há nada que ela deixe de fazer."

    // MARK: - Indisponível por qualidade (volta Q)

    /// Uma operação cortada por qualidade, como a tabela a entrega: motivo e
    /// conserto são DADO da medição e moram em `Politica`; aqui só se formata
    /// (ADR 08q). A data fica lá e não sobe à tela (ADR 09z).
    struct Reprovada {
        let op: Politica.Operacao
        let motivo: String
        /// nil = sem conserto conhecido; com frase = já se sabe o que falta
        let conserto: String?
    }

    /// A terceira lista, lida da mesma tabela que as duas de cima. Uma porta
    /// só: o que sumir de `pelaConta` e `peloAparelho` tem de aparecer aqui.
    static var reprovadas: [Reprovada] {
        Politica.indisponiveis.map { op in
            let l = Politica.linha(op)
            return Reprovada(op: op, motivo: l.motivo, conserto: l.conserto)
        }
    }

    /// Dois estados, dois grupos: reprovada sem substituto, e reprovada com
    /// conserto nomeado. Não se misturam num balaio — o dono precisa ver qual é
    /// qual. Indisponível não é erro nem promessa de volta: sem prazo aqui.
    /// A lista muda de tamanho com a medida; vazia é o estado que se quer, e
    /// a tela diz isso em vez de sumir com a linha.
    private var indisponiveisPorQualidade: some View {
        // auditoria 16/09 noite: a lista de motivos ("inventa uma situação que
        // você não escreveu…") era a nossa lista de defeitos na tela dele. Os
        // nomes bastam; o porquê mora na tabela `Politica` e no ADR.
        let nomes = Self.reprovadas.map { Politica.nome($0.op) }
        return Text(nomes.isEmpty ? Self.nadaCortado
                    : Self.aberturaSemConserto + " " + nomes.joined(separator: ", ") + ".")
            .font(Tema.meta)
            .foregroundStyle(Tema.tintaFraca)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: medidaMiuda, alignment: .leading)
            .accessibilityIdentifier("indisponiveis-por-qualidade")
    }

    /// A linha inteira: o nome da operação em tinta suave, o resto na tinta do
    /// corpo. `AttributedString` em vez de `Text + Text` (`+` está obsoleto no
    /// iOS 26) e em vez de interpolação, que passaria o motivo do autor por
    /// Markdown — o motivo é prosa da tabela `Politica`, não marcação.
    static func linhaDa(_ r: Reprovada) -> AttributedString {
        var nome = AttributedString(Politica.nome(r.op))
        nome.foregroundColor = Tema.tintaSuave
        return nome + AttributedString(restoDa(r))
    }

    /// O que vem depois do nome: " — motivo", e o conserto quando existe.
    /// ADR 09z: a DATA da medida saiu da tela. `medidaEm` continua na tabela,
    /// que é o registro — o autor é que não lê a nossa agenda de medições.
    static func restoDa(_ r: Reprovada) -> String {
        " — " + r.motivo + (r.conserto.map { " · " + $0 } ?? "")
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
        recolhidas.secao("Permissões", id: "permissoes") {
            if sistema.estado == .notDetermined {
                // o pedido ao iOS é um toque do autor, com o porquê à vista
                linhaAcao("calendar", "Calendários do aparelho", sistema.estadoEmPalavras) {
                    Task { await sistema.pedirAcesso() }
                }
                .accessibilityIdentifier("estado-calendario")
            } else {
                LinhaDeLista("calendar", "Calendários do aparelho", sistema.estadoEmPalavras)
                    .accessibilityIdentifier("estado-calendario")
            }
            LinhaDeLista("bell", "Avisos",
                         avisosLigados
                            ? "ligados — o Traço lembra na hora"
                            : "desligados — nenhum lembrete chega",
                         fio: sistema.negado || !avisosLigados)
                .accessibilityIdentifier("estado-avisos")
            if sistema.negado || !avisosLigados {
                linhaAcao("gear", "Abrir os Ajustes do Traço", "só o iOS muda uma permissão negada",
                          fio: false) {
                    if let url = URL(string: UIApplication.openSettingsURLString) { abrir(url) }
                }
                .accessibilityIdentifier("abrir-ajustes")
                .accessibilityHint("O iOS só deixa mudar uma permissão negada por lá")
            }
            // ADR 04b: o iPhone guarda 64 pendentes e descarta o resto em
            // SILÊNCIO. Um app que promete cobrar tem de mostrar quanto já
            // prometeu — senão o teto vira a mesma mentira da ADR 04a.
            if !orcamentoDosAvisos.isEmpty {
                prosa(orcamentoDosAvisos, cor: Tema.tintaSuave)
                    .accessibilityIdentifier("orcamento-avisos")
            }
            // a linha "Calendários do aparelho" já diz o estado; o parágrafo
            // de quatro linhas que explicava o mesmo saiu (laço de 14/09)
        }
        .task {
            await sistema.atualizar()
            avisosLigados = await Revisoes.autorizadaParaAvisar()
            orcamentoDosAvisos = await Avisos.emPalavras()
        }
    }

    /// O calendário do Traço — o do aparelho é a seção de cima, e a diferença
    /// entre os dois é a linha que explica: este vive aqui e não sincroniza.
    private var calendario: some View {
        // a contagem de compromissos mora no cabeçalho, como o "45" do Hermes
        recolhidas.secao("Calendário", id: "calendario", contagem: agenda.eventos.count) {
            chave("calendar.day.timeline.left", "Semana começa na segunda",
                  "só no calendário do Traço, que fica neste iPhone",
                  id: "ajustes-segunda",
                  ligado: Binding(
                    get: { agenda.segundaPrimeiro },
                    set: { agenda.segundaPrimeiro = $0 }
                  ))
            linhaAcao("trash", "Apagar todos os compromissos",
                      agenda.eventos.count == 1 ? "1 compromisso" : "\(agenda.eventos.count) compromissos",
                      destrutiva: true, fio: false) {
                confirmarApagarCalendario = true
            }
            .disabled(agenda.eventos.isEmpty)
            .accessibilityIdentifier("ajustes-apagar-tudo")
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
        recolhidas.secao("Férias", id: "ferias") {
            chave("beach.umbrella", "Modo férias",
                  "o Recordar e a revisão esperam; compromissos avisam",
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
                ) {
                    LinhaDeLista("calendar", "Até")
                }
                // a data marcada é ESTADO: carvão, não âmbar (ADR 10k)
                .tint(Tema.chipAtivo)
                .accessibilityIdentifier("ferias-ate")

                linhaAcao("infinity", "Sem data", "desligo eu mesmo") {
                    feriasAte = nil
                    Ferias.ate = nil
                    reagendarCobranças()
                }
                .accessibilityIdentifier("ferias-sem-data")
            }

            chave("flag", "E nos feriados",
                  "desligado, o Traço cobra no feriado também",
                  id: "ajuste-ferias-feriados",
                  ligado: Binding(
                    get: { feriasNosFeriados },
                    set: { novo in
                        feriasNosFeriados = novo
                        Ferias.incluiFeriados = novo
                        reagendarCobranças()
                    }),
                  fio: false)

            // desligado, os dois interruptores já dizem tudo; a linha só existe
            // quando há algo calado e até quando (laço de 14/09)
            if Ferias.vigente() {
                prosa(estadoDasFerias, cor: Tema.tintaSuave)
                    .accessibilityIdentifier("estado-ferias")
            }
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
        recolhidas.secao("Ajustes", id: "ajustes") {
            // "Análise automática" não é ajuste: a IA age sozinha na pausa da
            // escrita, sempre (goal de 14/09: "a IA não podia decidir isso?").
            // O estado continua a existir para o instrumento (`-autoAnalise`).
            hora("arrow.counterclockwise", "Recordar", "a fila do dia", valor: Binding(
                get: { Revisoes.hora },
                set: { Revisoes.hora = $0 }
            ))
            hora("sunrise", "Manhã", "para “de manhã” numa nota", valor: Binding(
                get: { Ancora.hora(.manha) },
                set: { Ancora.gravar(.manha, hora: $0) }
            ))
            hora("sun.max", "Tarde", "para “à tarde” numa nota", valor: Binding(
                get: { Ancora.hora(.tarde) },
                set: { Ancora.gravar(.tarde, hora: $0) }
            ))
            hora("moon", "Noite", "para “à noite”, e a revisão", fio: false, valor: Binding(
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
    ///
    /// ADR 10k: ligado é ESTADO, e estado é carvão — o âmbar do interruptor
    /// era a mesma cor do cursor dizendo outra coisa.
    private func chave(_ simbolo: String, _ titulo: String, _ explicacao: String, id: String,
                       ligado: Binding<Bool>, fio: Bool = true) -> some View {
        Toggle(isOn: ligado) {
            LinhaDeLista(simbolo, titulo, explicacao, fio: fio)
                .onTapGesture { ligado.wrappedValue.toggle() }
        }
        .tint(Tema.chipAtivo)
        .accessibilityIdentifier(id)
    }

    /// A hora se escolhe num menu, na própria linha: o `Stepper` do sistema
    /// era uma caixa cinza com − e + fora da família, e 23 toques para ir de
    /// 21h a 8h (laço de 14/09).
    private func hora(_ simbolo: String, _ titulo: String, _ explicacao: String, fio: Bool = true,
                      valor: Binding<Int>) -> some View {
        Menu {
            ForEach(0..<24, id: \.self) { h in
                Button { valor.wrappedValue = h } label: {
                    if h == valor.wrappedValue { Label("\(h)h", systemImage: "checkmark") } else { Text("\(h)h") }
                }
            }
        } label: {
            LinhaDeLista(titulo: titulo, subtitulo: explicacao, fio: fio,
                         glifo: { Image(systemName: simbolo) },
                         acessorio: {
                             HStack(spacing: 4) {
                                 Text("\(valor.wrappedValue)h").foregroundStyle(Tema.tintaSuave)
                                 Image(systemName: "chevron.up.chevron.down")
                                     .font(.caption2.weight(.semibold))
                                     .foregroundStyle(Tema.tintaFraca)
                             }
                             .font(Tema.chrome)
                         })
        }
        .buttonStyle(.linha)
        .accessibilityLabel(titulo)
        .accessibilityValue("\(valor.wrappedValue) horas")
    }

    // MARK: - Dados (§20: exportar/importar são AÇÃO, não navegação — moram aqui)

    private var dados: some View {
        recolhidas.secao("Dados", id: "dados") {
            linhaAcao("square.and.arrow.up", "Exportar todas as notas", "um arquivo de texto; as trancadas ficam de fora") {
                corpusURL = Corpus.exportar(notas: notas)
            }
            .accessibilityIdentifier("exportar-corpus")
            .accessibilityHint("Gera um Markdown com as notas abertas. Trancadas nunca saem.")
            linhaAcao("square.and.arrow.down", "Importar notas", "de arquivos de texto; nenhuma chega trancada") {
                importarMd = true
            }
            .accessibilityIdentifier("importar-md")
            .accessibilityHint("Traz notas de arquivos Markdown. Import nunca cria trancada.")
            chave("calendar.badge.clock", "Revisão da semana no domingo",
                  "um aviso sem conteúdo, na hora da noite, abrindo os Padrões",
                  id: "revisao-semanal",
                  ligado: Binding(
                    get: { Revisoes.revisaoSemanalLigada },
                    set: { ligada in
                        UserDefaults.standard.set(ligada, forKey: Revisoes.chaveRevisaoSemanal)
                        Revisoes.agendarRevisaoSemanal()
                    }))
            // ADR 2026-09-02n: a pasta pode viver no iCloud Drive do autor
            // porque é a nuvem DELE — escolhida no seletor do sistema, sem
            // conta do Traço, sem entitlement. Qualquer provedor serve.
            if let nome = PastaEspelho.nome {
                linhaAcao("folder", "Espelhando em “\(nome)”", PastaEspelho.estado ?? "toque para trocar a pasta") {
                    escolherPasta = true
                }
                .accessibilityIdentifier("espelho-pasta")
                .accessibilityHint("Toque para trocar a pasta")
                linhaAcao("folder.badge.minus", "Parar de espelhar", nil) {
                    PastaEspelho.limpar()
                    Toque.leve()
                }
                .accessibilityIdentifier("espelho-parar")
            } else {
                linhaAcao("folder.badge.plus", "Espelhar numa pasta", PastaEspelho.estado ?? "iCloud Drive ou outra nuvem sua") {
                    escolherPasta = true
                }
                .accessibilityIdentifier("espelho-pasta")
                .accessibilityHint("Escolhe uma pasta sua; o Traço grava lá uma cópia da pasta do segundo cérebro a cada nota concluída")
            }
            // ADR 04p: a entrada do Mac — o subtítulo é o ESTADO (a última
            // que entrou); o que ela é desce para a letra miúda da seção
            LinhaDeLista("tray.and.arrow.down", "Entrada do Mac", Entrada.ultimaEmPalavras)
                .accessibilityIdentifier("entrada")
            // ADR 04n: o índice de sentido
            LinhaDeLista("text.magnifyingglass", "Busca pelo sentido",
                         Indice.disponivel
                            ? "\(indiceQuantas) \(indiceQuantas == 1 ? "nota" : "notas") indexadas"
                            : "este aparelho não tem o modelo de frases em português",
                         fio: Indice.disponivel)
                .accessibilityIdentifier("indice-sentido")
            if Indice.disponivel {
                linhaAcao("arrow.clockwise", "Refazer a busca pelo sentido", nil, fio: false) {
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
            // o que as linhas fazem (backup, pasta, entrada/, índice) está no
            // subtítulo de cada uma; os três parágrafos de manual saíram (14/09)
        }
    }

    // MARK: - As peças da tela (ADR 10k)


    /// Ação parece ação: chevron à direita (critique-affordance), e o título
    /// em TINTA — é a forma que diz "toque", não o âmbar (ADR 10k).
    private func linhaAcao(_ simbolo: String, _ titulo: String, _ subtitulo: String?,
                           destrutiva: Bool = false, fio: Bool = true,
                           acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            LinhaDeLista(tocavel: simbolo, titulo, subtitulo, fio: fio, destrutiva: destrutiva)
        }
        .buttonStyle(.linha)
    }

    /// A letra miúda de uma seção: inteira, porque é a única cópia do que ela
    /// diz — o subtítulo das linhas é que corta.
    private func prosa(_ texto: String, cor: Color = Tema.tintaFraca) -> some View {
        Text(texto)
            .font(Tema.meta)
            .foregroundStyle(cor)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }
}

private extension View {
    /// Aberta, a seção leva o respiro inteiro abaixo; recolhida, só o cabeçalho.
    func respiro(_ aberta: Bool) -> some View {
        padding(.bottom, aberta ? Tema.entreSecoes - 4 : 0)
    }
}
