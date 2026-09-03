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
    @State private var filtroDominio: Dominio?
    @State private var versoesDe: Nota?
    @State private var contextoURL: URL?

    var body: some View {
        telaNotas
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
    }

    /// SPEC §20: navegar é da barra inferior. Aqui o título e o export do
    /// conjunto visível — a casa de escrever não carrega este chrome.
    private var topbar: some View {
        TituloTela(texto: "Notas") {
            if !filtradas.isEmpty {
                Button("Como contexto") {
                    contextoURL = Corpus.urlComoContexto(
                        filtradas.map(FatiaCorpus.de), nome: "traco-contexto.md")
                }
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .frame(minHeight: Tema.alvo)
                .buttonStyle(PressaoDiscreta())
                .accessibilityHint("Entrega estas notas à sua IA, sem servidor")
            }
        }
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
                    filtroDominio = nil
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
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 8)
        .opacity(filtro == .trancadas ? 0.4 : 1)
        .disabled(filtro == .trancadas)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Todas" é a saída: sem ela, filtrar era um caminho sem volta
                // óbvio (critique-affordance)
                Button {
                    Toque.selecao()
                    withAnimation(.easeOut(duration: 0.25)) {
                        filtro = nil
                        filtroDominio = nil
                    }
                } label: {
                    Text("Todas")
                        .font(Tema.meta.weight(.medium))
                        .foregroundStyle(filtro == nil ? .white : Tema.tintaSuave)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(minHeight: 34)
                        .background(Capsule().fill(filtro == nil ? Tema.chipAtivo : Tema.chip))
                }
                .frame(minHeight: Tema.alvo)
                .contentShape(Rectangle())
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("filtro-todas")
                .accessibilityAddTraits(filtro == nil ? [.isSelected] : [])
                ForEach(FiltroNotas.allCases) { item in
                    chipFiltro(
                        titulo: item.rawValue,
                        ligado: filtro == item,
                        id: "filtro-\(item.slug)"
                    ) {
                        filtro = filtro == item ? nil : item
                    }
                }
                ForEach(Dominio.allCases) { item in
                    chipFiltro(
                        titulo: item.nome,
                        ligado: filtroDominio == item,
                        id: "filtro-dominio-\(item.rawValue)"
                    ) {
                        filtroDominio = filtroDominio == item ? nil : item
                    }
                }
                Color.clear.frame(width: 4)
            }
            .padding(.horizontal, Tema.margem)
        }
        // MESMO defeito da régua do caderno: ScrollView horizontal sem altura
        // engole todo o espaço que o VStack oferece. A fileira de filtros
        // flutuava no meio de um bloco de ~280pt — 110pt de vão até a busca e
        // 128pt até a lista, três ilhas soltas onde devia haver uma coluna
        // (law-of-proximity).
        .frame(height: Tema.alvo)
        .mask(
            HStack(spacing: 0) {
                Rectangle()
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 28)
            }
        )
        .padding(.bottom, 8)
        .accessibilityHint("Um filtro por vez")
        .sheet(isPresented: Binding(get: { contextoURL != nil },
                                    set: { if !$0 { contextoURL = nil } })) {
            if let contextoURL { CompartilharArquivo(url: contextoURL) }
        }
        .sheet(item: $versoesDe) { nota in
            VersoesView(nota: nota, sessao: sessao)
        }
    }

    private func chipFiltro(titulo: String, ligado: Bool, id: String,
                            acao: @escaping () -> Void) -> some View {
        Button {
            Toque.selecao()
            withAnimation(.easeOut(duration: 0.25)) { acao() }
        } label: {
            Text(titulo)
                .font(Tema.meta.weight(.medium))
                .foregroundStyle(ligado ? .white : Tema.tintaSuave)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 34)
                .background(Capsule().fill(ligado ? Tema.chipAtivo : Tema.chip))
        }
        .frame(minHeight: Tema.alvo)
        .contentShape(Rectangle())
        .buttonStyle(PressaoDiscreta())
        .accessibilityAddTraits(ligado ? [.isSelected] : [])
        .accessibilityIdentifier(id)
        .accessibilityLabel(titulo)
    }

    private var lista: some View {
        let visiveis = filtradas
        return Group {
            if visiveis.isEmpty {
                // No eixo do app, onde os resultados nasceriam — não um placar
                // centralizado contra a tela toda (law-of-continuity; mesmo
                // conserto do Recordar em 9eb6124). O glifo decorativo saiu:
                // era o elemento mais chamativo do ecrã carregando zero
                // conteúdo (critique-visual-hierarchy).
                VStack(alignment: .leading, spacing: 12) {
                    Text(vazioTitulo)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                    // a saída tem que ser do BURACO em que o autor caiu: quando
                    // o vazio é da busca, "escrever na página" joga fora o que
                    // ele estava procurando em vez de devolver o arquivo
                    if busca.isEmpty, filtro == nil, filtroDominio == nil {
                        Button("escrever na página") {
                            sessao.novaPagina()
                            sessao.mostrarNotas = false
                        }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                    } else {
                        Button("ver todas as notas") {
                            busca = ""
                            filtro = nil
                            filtroDominio = nil
                        }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambarTinta)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityIdentifier("limpar-busca")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Tema.margem)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if !busca.isEmpty || filtro != nil || filtroDominio != nil {
                            Text(contagem(visiveis.count))
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaFraca)
                                .padding(.top, 12)
                                .accessibilityIdentifier("contagem-busca")
                        }
                        // O arquivo tem tempo: seções por mês, não um pergaminho cego.
                        ForEach(meses(visiveis), id: \.titulo) { secao in
                            Text(secao.titulo)
                                .font(Tema.label)
                                .tracking(Tema.trackingLabel)
                                .foregroundStyle(Tema.tintaFraca)
                                .padding(.top, 20)
                                .padding(.bottom, 6)
                                .accessibilityAddTraits(.isHeader)
                            ForEach(Array(secao.notas.enumerated()), id: \.element.uuid) { i, nota in
                                botaoNota(nota)
                                // sem separador depois do último: a lista fecha
                                if i < secao.notas.count - 1 {
                                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                                }
                            }
                        }

                    }
                    .padding(.horizontal, Tema.margem)
                }
                // o mesmo gesto do caderno (CadernoView:68): arrastar a lista
                // devolve a tela — sem isto o teclado da busca prendia a tab
                // bar atrás de si e a única saída era o "x" (jakobs-law: no
                // Notes, arrastar a lista dispensa o teclado)
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    private struct SecaoMes {
        let titulo: String
        let notas: [Nota]
    }

    private func meses(_ notas: [Nota]) -> [SecaoMes] {
        let cal = Calendar.current
        let anoAtual = cal.component(.year, from: .now)
        var ordem: [String] = []
        var grupos: [String: [Nota]] = [:]
        let f = DateFormatter()
        f.locale = .current
        for nota in notas {
            let ano = cal.component(.year, from: nota.criadaEm)
            f.dateFormat = ano == anoAtual ? "LLLL" : "LLLL yyyy"
            // a seção de hoje se chama HOJE: repetir "agosto" no cabeçalho e
            // "hoje" em cada linha gasta a única informação temporal útil
            let titulo = cal.isDateInToday(nota.criadaEm)
                ? "HOJE"
                : f.string(from: nota.criadaEm).uppercased()
            if grupos[titulo] == nil { ordem.append(titulo) }
            grupos[titulo, default: []].append(nota)
        }
        return ordem.map { SecaoMes(titulo: $0, notas: grupos[$0] ?? []) }
    }

    private var vazioTitulo: String {
        if filtro == .trancadas { return "nenhuma trancada." }
        if !busca.isEmpty { return "nenhuma nota com “\(busca)”." }
        return "nada aqui ainda."
    }

    /// A busca não dizia quantas achou: o autor não sabia se tinha terminado
    /// (zeigarnik-effect).
    private func contagem(_ n: Int) -> String {
        if !busca.isEmpty {
            return n == 1 ? "1 nota com “\(busca)”" : "\(n) notas com “\(busca)”"
        }
        return n == 1 ? "1 nota" : "\(n) notas"
    }

    private func abrirDaLista(_ nota: Nota) {
        if nota.queimada {
            sessao.abrir(nota) // diz honestamente que não há o que abrir
        } else if nota.trancada {
            sessao.confirmacao = .naoSeRele(nota.uuid)
        } else {
            sessao.abrir(nota)
        }
    }

    private func botaoNota(_ nota: Nota) -> some View {
        // Dois botões irmãos — nunca um Button dentro do outro. O chip de
        // domínio promete um toque; aninhado, o toque abria a nota.
        HStack(alignment: .center, spacing: 8) {
            Button { abrirDaLista(nota) } label: {
                VStack(alignment: .leading, spacing: 4) {
                    if nota.queimada {
                        // §8: a queimada não finge existir. Mostra o que sobrou —
                        // e o que sobrou é justamente o que se multiplica.
                        Text("Expressiva — queimada")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Tema.tintaSuave)
                        if !nota.sentido.isEmpty {
                            DestaqueBusca.texto(nota.sentido, termo: busca, base: Tema.tinta)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        Text(nota.minutosEscritos >= 1
                             ? "\(nota.minutosEscritos) min · \(VozDoAutor.relativo(nota.criadaEm))"
                             : VozDoAutor.relativo(nota.criadaEm))
                            .font(.subheadline)
                            .foregroundStyle(Tema.tintaFraca)
                    } else if nota.trancada {
                        Text("Expressiva — trancada")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Tema.tintaSuave)
                        Text("não se relê · \(VozDoAutor.relativo(nota.criadaEm))")
                            .font(.subheadline)
                            .foregroundStyle(Tema.tintaFraca)
                    } else {
                        DestaqueBusca.texto(titulo(nota), termo: busca, base: Tema.tinta)
                            .font(Tema.chrome.weight(.semibold))
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            if let g = nota.gesto {
                                Text(g.nome.uppercased())
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(Tema.tintaSuave)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Tema.chip, in: Capsule())
                            }
                            let sub = subtitulo(nota)
                            if !(sub == "hoje" && busca.isEmpty) {
                                DestaqueBusca.texto(sub, termo: busca, base: Tema.tintaFraca)
                                    .font(Tema.meta)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressaoDiscreta())
            .tint(Tema.tinta)
            .accessibilityLabel(nota.trancada ? "Expressiva trancada" : titulo(nota))
            .accessibilityHint(nota.trancada ? "Reabrir pede confirmação dupla" : "Segure para recordar a memória")
            .accessibilityIdentifier("nota-notas")

            if !nota.fechada, let d = nota.dominio {
                Button {
                    sessao.soltarDominio(nota, no: context)
                } label: {
                    Text(d.nome.uppercased())
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(Tema.tintaSuave)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Tema.chip, in: Capsule())
                }
                .buttonStyle(PressaoDiscreta())
                .accessibilityLabel(d.nome)
                .accessibilityHint("Um toque tira o domínio")
                .accessibilityIdentifier("chip-dominio")
            }
        }
        .padding(.vertical, 12)
        .frame(minHeight: Tema.alvo)
        .contextMenu {
            if !nota.trancada {
                Button("Recordar") { sessao.recordarDaNotas(nota) }
            }
            let fatia = FatiaCorpus.de(nota)
            if !fatia.nuncaSai {
                Button("Como contexto") {
                    contextoURL = Corpus.urlComoContexto([fatia], nome: "traco-contexto.md")
                }
            }
            if !nota.fechada, nota.gesto != .expressiva {
                Button("Versões") { versoesDe = nota }
            }
            // ADR 2026-08-31f: apagar existe, com atrito — trancada exige dupla.
            Button("Apagar", role: .destructive) {
                sessao.confirmacao = nota.trancada ? .apagarTrancada(nota.uuid) : .apagar(nota.uuid)
            }
        }
    }

    private var filtradas: [Nota] {
        NotasFiltro.visiveis(notas, busca: busca, filtro: filtro, dominio: filtroDominio)
    }

    private func titulo(_ nota: Nota) -> String {
        nota.tituloNaLista
    }

    private func subtitulo(_ nota: Nota) -> String {
        if !busca.isEmpty {
            let trecho = VozDoAutor.trecho(em: nota.vozDoAutor, termo: busca)
            // trecho que repete o título gasta uma linha e não informa nada
            let t = titulo(nota)
            if trecho == t || t.hasPrefix(trecho) || trecho.hasPrefix(t) {
                return VozDoAutor.relativo(nota.criadaEm)
            }
            return trecho
        }
        // arquivo do esforço, não streak: quantas vezes esta nota foi recordada
        let recordadas = Revisoes.contagem(nota.uuid)
        let sufixo = recordadas > 0 ? " · recordada \(recordadas)×" : ""
        let respostas = nota.campos.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if respostas.isEmpty {
            return VozDoAutor.relativo(nota.criadaEm) + sufixo
        }
        return VozDoAutor.truncar(respostas.joined(separator: " · "), 56) + sufixo
    }
}


/// Folha de compartilhamento do sistema (o export gera no toque, não no body).
struct CompartilharArquivo: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
