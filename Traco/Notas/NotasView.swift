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
    /// U3 — a folha na lista: quanto cada nota já foi puxada para o lado (por uuid).
    /// Arrastar a nota é arrastar uma folha: ela desliza rígida, ergue a sombra e,
    /// passada a soleira, se solta para o Recordar. Eixos ortogonais ao scroll
    /// vertical (só engata no horizontal), então nunca rouba a rolagem.
    /// ponytail: estado no PAI reavalia a lista a cada quadro do arrasto (filtrar+
    /// agrupar). Ok para o arquivo típico; se travar em corpus grande, extrair
    /// uma LinhaNota com @State local (só a linha puxada re-renderiza).
    @State private var puxada: [UUID: CGFloat] = [:]
    private let folhaLargura: CGFloat = 108   // quanto a folha revela ao ser puxada
    private let folhaSoleira: CGFloat = 72    // passar disto e soltar = Recordar

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

    /// SPEC §20: navegar é da barra inferior. Aqui fica só o título da tela e a
    /// ÚNICA ação que pertence a esta tela — começar uma página nova.
    private var topbar: some View {
        TituloTela("Notas")
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
                    withAnimation(.easeOut(duration: 0.25)) { filtro = nil }
                } label: {
                    Text("Todas")
                        .font(Tema.meta.weight(.medium))
                        .foregroundStyle(filtro == nil ? Tema.ambar : Tema.tintaSuave)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(minHeight: 34)
                        .background(Capsule().fill(filtro == nil ? Tema.ambarSuave : Tema.superficie))
                        .overlay {
                            Capsule().strokeBorder(
                                filtro == nil ? Tema.ambar.opacity(0.5) : Tema.linha,
                                lineWidth: 0.5
                            )
                        }
                }
                .frame(minHeight: Tema.alvo)
                .contentShape(Rectangle())
                .buttonStyle(PressaoDiscreta())
                .accessibilityIdentifier("filtro-todas")
                .accessibilityAddTraits(filtro == nil ? [.isSelected] : [])
                ForEach(FiltroNotas.allCases) { item in
                    Button {
                        Toque.selecao()
                        withAnimation(.easeOut(duration: 0.25)) {
                            filtro = filtro == item ? nil : item
                        }
                    } label: {
                        Text(item.rawValue)
                            .font(Tema.meta.weight(.medium))
                            .foregroundStyle(filtro == item ? Tema.ambar : Tema.tintaSuave)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minHeight: 34)
                            .background(
                                Capsule().fill(filtro == item ? Tema.ambarSuave : Tema.superficie)
                            )
                            // o estado ligado precisa ser inequívoco, não só um
                            // cinza um pouco mais claro (critique-affordance)
                            .overlay {
                                Capsule().strokeBorder(
                                    filtro == item ? Tema.ambar.opacity(0.5) : Tema.linha,
                                    lineWidth: 0.5
                                )
                            }
                    }
                    // alvo de toque 44 sem inflar o visual
                    .frame(minHeight: Tema.alvo)
                    .contentShape(Rectangle())
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityAddTraits(filtro == item ? [.isSelected] : [])
                    .accessibilityIdentifier("filtro-\(item.slug)")
                    .accessibilityLabel(item.rawValue)
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
                    if busca.isEmpty, filtro == nil {
                        Button("escrever na página") {
                            sessao.novaPagina()
                            sessao.mostrarNotas = false
                        }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambar)
                        .frame(minHeight: Tema.alvo)
                        .buttonStyle(PressaoDiscreta())
                    } else {
                        Button("ver todas as notas") {
                            busca = ""
                            filtro = nil
                        }
                        .font(Tema.chrome.weight(.semibold))
                        .foregroundStyle(Tema.ambar)
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
                        if !busca.isEmpty || filtro != nil {
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

    /// A nota como FOLHA na lista: desliza rígida sob o dedo, ergue a sombra de
    /// contato (descola da pilha) e, passada a soleira, se solta para o Recordar
    /// — como quem puxa uma folha do bloco. Só a nota que se relê (nem trancada
    /// nem queimada) puxa: as outras ficam firmes. O pan (`PanFolha`) só engata no
    /// horizontal — a rolagem vertical nunca é roubada (eixos ortogonais).
    private func botaoNota(_ nota: Nota) -> some View {
        let recordavel = !nota.trancada && !nota.queimada
        let dx = puxada[nota.uuid] ?? 0
        let progresso = min(1, Double(-dx / folhaSoleira))
        return ZStack(alignment: .trailing) {
            if recordavel {
                // o que a folha revela ao descolar: Recordar. Sem âmbar — o único
                // acento da tela é o filtro ativo (Von Restorff).
                Label("Recordar", systemImage: "arrow.counterclockwise")
                    .font(Tema.meta.weight(.medium))
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.trailing, 20)
                    .opacity(progresso)
                    .accessibilityHidden(true)
            }
            folhaRow(nota, dx: dx, progresso: progresso, recordavel: recordavel)
        }
    }

    /// A linha como folha: o papel materializa sob o conteúdo e desliza com ele.
    /// Só a nota recordável ENGATA o pan; trancada/queimada ficam firmes — o toque
    /// abre, com o atrito próprio de cada uma.
    @ViewBuilder
    private func folhaRow(_ nota: Nota, dx: CGFloat, progresso: Double, recordavel: Bool) -> some View {
        let base = linhaConteudo(nota)
            // a nota VIRA folha ao ser erguida: o papel materializa sob ela e é ELE
            // que projeta a sombra de contato — sobre texto pelado a sombra some no
            // preto e o arrasto lia como swipe de lista, não folha
            .background(folhaErguida(progresso))
            .offset(x: dx)
        if recordavel {
            base.gesture(PanFolha(aoMover: { puxa(nota, $0) }, aoSoltar: { solta(nota, $0) }))
        } else {
            base
        }
    }

    /// A folha que só existe enquanto a linha é ERGUIDA (progresso 0 = pilha
    /// plana: a lista em repouso fica intocada, texto puro sobre o tampo). Mesmo
    /// papel da PaginaView/U2 — gradiente 0x18→0x12, fio de luz no topo → hairline
    /// (o modelo de luz-de-cima da casa) — e a sombra de contato que a descola da
    /// pilha. É o papel opaco que projeta a sombra: descolar exige superfície.
    private func folhaErguida(_ progresso: Double) -> some View {
        // rampa 4x: a folha SNAPA ao tom cheio logo nos primeiros ~18pt do arrasto
        // (não fica um cinza translúcido a meio caminho, que lia como buraco). Sobre
        // preto a profundidade NÃO é sombra (preto não escurece preto) — é a
        // superfície mais clara + o fio de luz + o fosso. Tokens da casa: erguida,
        // a linha sobe ao nível do CARTÃO (superficieAlta 0x1E, a superfície mais
        // clara da casa) — um degrau CLARO acima do tampo 0x0B e das linhas
        // vizinhas. A nota agarrada é o topo do modelo de luz, não um recuo.
        let p = min(1, progresso * 4)
        return RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
            // FILL SÓLIDO no nível do cartão (superficieAlta 0x1E) — o gradiente pra
            // superficie escurecia o meio da linha fina (lia como 0x18, subtil demais
            // pra descolar). Sólido = a superfície inteira um degrau claro; o "luz de
            // cima" fica por conta do fio de luz forte na borda, não do gradiente.
            .fill(Tema.superficieAlta)
            .overlay {
                // fio de luz FORTE no topo → hairline: a borda que "pega" o erguer.
                // 0.40 no topo = a quina de cima acende (a lip de luz de quem ergue
                // a folha); sem essa borda que acende, a superfície lia como recuo.
                RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                    .strokeBorder(LinearGradient(colors: [.white.opacity(0.40), Tema.linha],
                                                 startPoint: .top, endPoint: .bottom),
                                  lineWidth: 1)
            }
            // a folha FLUTUA: um VÃO de tampo (6pt) acima/baixo a descola das
            // vizinhas — é o fosso escuro, não a sombra (preto não escurece preto),
            // que faz a folha ler ERGUIDA da pilha, não uma linha selecionada rente.
            .padding(.vertical, 6)
            .opacity(p)
    }

    /// A folha desliza sob o dedo; borracha depois da largura (resiste, não escapa).
    private func puxa(_ nota: Nota, _ x: CGFloat) {
        puxada[nota.uuid] = x < 0 ? max(-folhaLargura, x) : 0
    }

    /// Solta: passada a soleira, a folha se desprende pro Recordar; senão volta.
    private func solta(_ nota: Nota, _ x: CGFloat) {
        if x < -folhaSoleira {
            Toque.selecao()
            sessao.recordarDaNotas(nota) // a folha se solta: vai recordar
        }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            puxada[nota.uuid] = 0
        }
    }

    private func linhaConteudo(_ nota: Nota) -> some View {
        Button {
            if nota.queimada {
                sessao.abrir(nota) // diz honestamente que não há o que abrir
            } else if nota.trancada {
                sessao.confirmacao = .naoSeRele(nota.uuid)
            } else {
                sessao.abrir(nota)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                if nota.queimada {
                    // §8: a queimada não finge existir. Mostra o que sobrou —
                    // e o que sobrou é justamente o que se multiplica.
                    Label("Expressiva — queimada", systemImage: "flame")
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
                    Label("Expressiva — trancada", systemImage: "lock.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Tema.tintaSuave)
                    Text("não se relê · \(VozDoAutor.relativo(nota.criadaEm))")
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaFraca)
                } else {
                    DestaqueBusca.texto(titulo(nota), termo: busca, base: Tema.tinta)
                        .font(Tema.chrome.weight(.semibold))
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        // tag é CHIP, data é texto: dois tipos de dado, duas
                        // roupas (law-of-similarity — antes liam como uma string)
                        if let g = nota.gesto {
                            Text(g.nome.uppercased())
                                .font(Tema.label)
                                .tracking(Tema.trackingLabel)
                                .foregroundStyle(Tema.tintaSuave)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.06), in: Capsule())
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
            .padding(.vertical, 12)
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


/// Pan HORIZONTAL da folha na lista. O `DragGesture` do SwiftUI vazava o toque do
/// Button (a nota abria ao puxar de leve) e brigava com a rolagem — lição paga em
/// 02/set. Um `UIPanGestureRecognizer` resolve os dois: só COMEÇA quando o gesto é
/// horizontal (o vertical cede à rolagem do ScrollView) e, ao começar, CANCELA o
/// toque do Button (`cancelsTouchesInView`) — a folha puxa sem abrir a nota.
/// iOS 18+ (o alvo é 26).
struct PanFolha: UIGestureRecognizerRepresentable {
    let aoMover: (CGFloat) -> Void   // translation.x corrente
    let aoSoltar: (CGFloat) -> Void  // translation.x final

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordenador { Coordenador() }

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let g = UIPanGestureRecognizer()
        g.delegate = context.coordinator
        g.cancelsTouchesInView = true   // engatou → o toque do Button é cancelado
        return g
    }

    func handleUIGestureRecognizerAction(_ g: UIPanGestureRecognizer, context: Context) {
        // a direção é resolvida AQUI, não num gate de início: puxão vertical é
        // rolagem (x=0, não puxa nem recorda), só o horizontal move a folha.
        let t = g.translation(in: g.view)
        let x = abs(t.x) > abs(t.y) ? t.x : 0
        switch g.state {
        case .changed:                    aoMover(x)
        case .ended, .cancelled, .failed: aoSoltar(x)
        default:                          break
        }
    }

    /// Coexiste com a rolagem (simultâneo): o vertical rola a lista, o horizontal
    /// puxa a folha. SEM gate de direção no início — um `shouldBegin` horizontal
    /// FALHAVA o pan no arrasto lento (translação ambígua no primeiro quadro) e a
    /// nota abria. Aqui o pan sempre engata e cancela o toque do Button; quem
    /// decide a direção é o handler. O `cancelsTouchesInView` garante que puxar
    /// (em qualquer direção) nunca dispare o toque — rolar também não abre a nota.
    final class Coordenador: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ g: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }
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
