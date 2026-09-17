import SwiftUI

/// O visto da tarefa: o traço do check, desenhado de ponta a ponta. Duas
/// pernas numa caixa 1x1 — quem desenha dá o tamanho.
nonisolated struct TracoDoVisto: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX + r.width * 0.06, y: r.minY + r.height * 0.55))
        p.addLine(to: CGPoint(x: r.minX + r.width * 0.38, y: r.minY + r.height * 0.84))
        p.addLine(to: CGPoint(x: r.minX + r.width * 0.94, y: r.minY + r.height * 0.18))
        return p
    }
}

/// O círculo da tarefa, o mesmo nas três telas que o desenham (o portal, a
/// página una e o bloco em edição). Dono, 17/09: «uma bolinha que, ao colocar
/// no carrinho, se transforma numa animação excepcional em verde check».
///
/// A bolinha vazia é um aro fino; ao toque o verde (`Tema.feito`) nasce do
/// centro com mola, o check é DESENHADO (não aparece feito) e uma onda sai do
/// aro e se apaga. Desmarcar é o mesmo caminho de volta, sem onda. Sob Reduzir
/// Movimento nada disso é interpolado: o estado troca no corte (ADR 05y — só
/// opacidade anima), e o check aparece inteiro. Sem `alternar`, o círculo não
/// faz nada nem vibra.
struct VistoDaTarefa: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let feito: Bool
    let alternar: (() -> Void)?
    @State private var pressionado = false
    /// Conta os toques que MARCAM: a onda nasce de um número novo, nunca de a
    /// bolinha aparecer.
    @State private var toques = 0

    /// Marcar e desmarcar são o mesmo caminho, ao contrário: ao MARCAR o verde
    /// nasce primeiro e o traço corre depois; ao DESMARCAR o traço recolhe
    /// primeiro, ainda sobre o verde, e só então o verde sai. Sem isto o visto
    /// branco desenhava-se de volta sobre papel branco, invisível (auditoria 17/09).
    private var molaDoVerde: Animation? {
        Tema.movimento(.escala, feito ? Tema.Mola.toque : Tema.Mola.toque.delay(Tema.Duracao.passo),
                       reduzido: reduceMotion)
    }

    private var curvaDoTraco: Animation? {
        // a curva vai DENTRO da chamada ao Tema: curva solta na view é o que o
        // portão do movimento recusa (e com razão — a lei mora no Tema)
        Tema.movimento(.escala,
                       feito ? .easeOut(duration: Tema.Duracao.media).delay(Tema.Duracao.passo)
                             : .easeOut(duration: Tema.Duracao.media),
                       reduzido: reduceMotion)
    }

    var body: some View {
        if alternar == nil {
            // a linha fantasma (a que nasce quando o autor escrever) mostra o
            // aro, não um botão: 44 pt de alvo que não respondiam ao dedo
            glifo.accessibilityHidden(true)
        } else {
            botao
        }
    }

    private var botao: some View {
        Button {
            guard let alternar else { return }
            // o dedo confirma antes da tinta: feito é um toque com corpo
            feito ? Toque.selecao() : Toque.leve()
            // a onda é do TOQUE que marca, não da chegada do item na tela: com
            // `onAppear` ela saía sozinha de cada item já feito ao abrir a nota
            // (auditoria 17/09)
            if !feito { toques += 1 }
            alternar()
        } label: {
            glifo
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        // o press não espera a mão soltar
        .onLongPressGesture(minimumDuration: 0, pressing: { p in
            guard alternar != nil else { return }
            withAnimation(Tema.movimento(.escala, .easeOut(duration: Tema.Duracao.toque), reduzido: reduceMotion)) {
                pressionado = p
            }
        }, perform: {})
        .accessibilityLabel(feito ? "Feita" : "Por fazer")
        .accessibilityAddTraits(feito ? [.isButton, .isSelected] : .isButton)
    }

    private var glifo: some View {
        ZStack {
            Circle()
                .strokeBorder(Tema.tintaFraca.opacity(0.55), lineWidth: 1.4)
                .opacity(feito ? 0 : 1)
                .animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion),
                           value: feito)
            Circle()
                .fill(Tema.feito)
                .scaleEffect(feito ? 1 : 0.1)
                .opacity(feito ? 1 : 0)
                .animation(molaDoVerde, value: feito)
            TracoDoVisto()
                .trim(from: 0, to: feito ? 1 : 0)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
                .padding(5.5)
                .animation(curvaDoTraco, value: feito)
            if feito, toques > 0, !reduceMotion { onda.id(toques) }
        }
        .frame(width: 22, height: 22)
        .scaleEffect(pressionado ? 0.84 : 1)
        .frame(width: Tema.alvo, height: Tema.alvo)
    }

    /// A onda que sai do aro quando o item entra no carrinho: nasce no tamanho
    /// da bolinha e se apaga crescendo. Vive só enquanto o quadro dura.
    private var onda: some View {
        Onda()
    }

    private struct Onda: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var aberta = false
        var body: some View {
            Circle()
                .stroke(Tema.feito, lineWidth: 1.5)
                .scaleEffect(aberta ? 2 : 1)
                .opacity(aberta ? 0 : 0.5)
                .onAppear {
                    withAnimation(Tema.movimento(.escala, .easeOut(duration: Tema.Duracao.longa), reduzido: reduceMotion)) {
                        aberta = true
                    }
                }
        }
    }
}

/// O item que fica feito: o risco atravessa a palavra da esquerda para a
/// direita e a tinta esmorece atrás dele — o mesmo texto duas vezes, a cópia
/// riscada revelada por uma máscara que cresce. Sob Reduzir Movimento a
/// máscara não é interpolada: o risco aparece inteiro.
struct TextoRiscavel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let texto: AttributedString
    let feito: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // as duas cópias são complementares: o que uma mostra, a outra
            // esconde. Sem isso o risco de baixo vazava pelos vãos das letras.
            Text(texto)
                .foregroundStyle(Tema.tintaFraca)
                .strikethrough(true, color: Tema.tintaFraca)
                .mask { corte(.leading, cheio: feito) }
            Text(texto)
                .foregroundStyle(Tema.tinta)
                .mask { corte(.trailing, cheio: !feito) }
        }
        .animation(Tema.movimento(.escala, .easeOut(duration: Tema.Duracao.media).delay(Tema.Duracao.passo), reduzido: reduceMotion),
                   value: feito)
    }

    /// A parte visível de uma cópia: a máscara cresce de um lado enquanto a da
    /// outra cópia some do outro — a fronteira é o risco correndo na palavra.
    private func corte(_ lado: Alignment, cheio: Bool) -> some View {
        GeometryReader { g in
            Rectangle()
                .frame(width: cheio ? g.size.width : 0)
                .frame(width: g.size.width, height: g.size.height, alignment: lado)
        }
    }
}

struct ProsaView: View {
    let bloco: BlocoCaderno
    var aoAlternarTarefa: ((Int) -> Void)?

    var body: some View {
        switch bloco {
        case .paragrafo(let t):
            Text(atributos(t))
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .titulo(let n, let t):
            Text(t)
                .font(n <= 1 ? Tema.tituloNota : Tema.secaoNota)
                .tracking(n <= 1 ? -0.4 : -0.2)
                .foregroundStyle(Tema.tinta)
                .padding(.top, n == 1 ? 12 : 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(n <= 1 ? "portal-titulo" : n == 2 ? "portal-seccao" : "portal-subseccao")
        case .itens(let xs, let ordenada):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(xs.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        if ordenada {
                            Text("\(i + 1).")
                                .font(Tema.corpo.monospacedDigit())
                                .foregroundStyle(Tema.tintaFraca)
                                .frame(minWidth: 20, alignment: .trailing)
                        } else {
                            // o marcador vive na linha de base do texto: o círculo com
                            // folga fixa caía abaixo do meio da letra (17/09)
                            Text("•")
                                .font(Tema.corpo.weight(.bold))
                                .foregroundStyle(Tema.tintaFraca)
                                .frame(width: 20, alignment: .center)
                        }
                        Text(atributos(item))
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                    }
                }
            }
            .accessibilityIdentifier("portal-lista")
        case .tarefas(let xs):
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(xs.enumerated()), id: \.offset) { i, item in
                    // `firstTextBaseline`: no item que quebra em duas linhas a
                    // bolinha centrada parava ao lado da SEGUNDA (auditoria 17/09)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        VistoDaTarefa(feito: item.feito, alternar: aoAlternarTarefa.map { f in { f(i) } })
                            .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] + 6 }
                        TextoRiscavel(texto: atributos(item.texto), feito: item.feito)
                            .font(Tema.corpo)
                    }
                }
            }
            .accessibilityIdentifier("portal-tarefa")
        case .citacao(let xs):
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Tema.tintaFraca)
                    .frame(width: 2)
                Text(atributos(xs.joined(separator: "\n")))
                    .font(Tema.corpo.italic())
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .accessibilityIdentifier("portal-citacao")
        case .tabela(let cabeca, let corpo):
            tabela(cabeca, corpo)
        case .divisoria:
            Rectangle()
                .fill(Tema.tintaFraca.opacity(0.55))
                .frame(height: 1)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Divisória")
                .accessibilityIdentifier("portal-divisoria")
        case .recipiente(let slug, let linhas):
            RecipienteView(slug: slug, linhas: linhas)
        default:
            EmptyView()
        }
    }

    private func tabela(_ cabeca: [String], _ corpo: [[String]]) -> some View {
        let cols = max(cabeca.count, corpo.map(\.count).max() ?? 0)
        // sem o rótulo «TABELA»: a grade já diz o que é
        return VStack(alignment: .leading, spacing: 8) {
            Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(0..<cols, id: \.self) { c in
                        celula(c < cabeca.count ? cabeca[c] : "", cabeca: true)
                    }
                }
                ForEach(Array(corpo.enumerated()), id: \.offset) { _, row in
                    GridRow {
                        ForEach(0..<cols, id: \.self) { c in
                            celula(c < row.count ? row[c] : "", cabeca: false)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Tema.linha, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tabela")
        .accessibilityIdentifier("portal-tabela")
    }

    private func celula(_ texto: String, cabeca: Bool) -> some View {
        Text(texto)
            .font(cabeca ? Tema.label : Tema.corpo)
            .foregroundStyle(cabeca ? Tema.tintaSuave : Tema.tinta)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cabeca ? Tema.superficieAlta : Tema.superficie)
    }

    private func atributos(_ bruto: String) -> AttributedString { Self.textoInline(bruto) }

    /// O inline do caderno: ligação, código, forte, riscado, itálico, link.
    /// `static` para o teste alcançar — é função pura sobre a linha.
    static func textoInline(_ bruto: String) -> AttributedString {
        var saida = AttributedString()
        var resto = bruto[...]
        while !resto.isEmpty {
            // ADR 2026-09-03b: [[outra nota]] é ligação, e ligação se LÊ —
            // os colchetes são sintaxe e somem na leitura
            if resto.hasPrefix("[["),
               let fim = resto.dropFirst(2).range(of: "]]") {
                let meio = resto[resto.index(resto.startIndex, offsetBy: 2)..<fim.lowerBound]
                var t = AttributedString(String(meio))
                t.foregroundColor = Tema.ambarTinta
                t.underlineStyle = .single
                saida += t
                resto = resto[fim.upperBound...]
                continue
            }
            if resto.hasPrefix("`"),
               let fim = resto.dropFirst().firstIndex(of: "`") {
                let meio = resto[resto.index(after: resto.startIndex)..<fim]
                var t = AttributedString(String(meio))
                t.font = .body.monospaced()
                t.foregroundColor = Tema.synChave
                t.backgroundColor = Tema.superficieAlta
                saida += t
                resto = resto[resto.index(after: fim)...]
                continue
            }
            if resto.hasPrefix("**"),
               let fim = resto.dropFirst(2).range(of: "**") {
                let meio = resto[resto.index(resto.startIndex, offsetBy: 2)..<fim.lowerBound]
                var t = AttributedString(String(meio))
                t.font = .body.weight(.semibold)
                saida += t
                resto = resto[fim.upperBound...]
                continue
            }
            if resto.hasPrefix("~~"),
               let fim = resto.dropFirst(2).range(of: "~~") {
                let meio = resto[resto.index(resto.startIndex, offsetBy: 2)..<fim.lowerBound]
                var t = AttributedString(String(meio))
                t.strikethroughStyle = .single
                t.foregroundColor = Tema.tintaFraca
                saida += t
                resto = resto[fim.upperBound...]
                continue
            }
            if resto.hasPrefix("*"), !resto.hasPrefix("**"),
               let fim = resto.dropFirst().firstIndex(of: "*") {
                let meio = resto[resto.index(after: resto.startIndex)..<fim]
                var t = AttributedString(String(meio))
                t.font = .body.italic()
                saida += t
                resto = resto[resto.index(after: fim)...]
                continue
            }
            if resto.hasPrefix("["),
               let meioFim = resto.firstIndex(of: "]"),
               resto[resto.index(after: meioFim)...].hasPrefix("("),
               let urlFim = resto[resto.index(after: meioFim)...].firstIndex(of: ")") {
                let label = resto[resto.index(after: resto.startIndex)..<meioFim]
                var t = AttributedString(String(label))
                t.underlineStyle = .single
                t.foregroundColor = Tema.tintaSuave
                saida += t
                resto = resto[resto.index(after: urlFim)...]
                continue
            }
            // o MENOR índice, não o primeiro não-nulo: com `??` em cadeia, uma
            // crase adiante ganhava de um asterisco atrás dela e todo o trecho
            // entre os dois saía cru na tela — markdown na cara do autor
            let next = ["`", "*", "~", "["]
                // Um marcador sem fecho é texto literal: consuma ao menos um
                // caractere, inclusive quando o próprio início é um marcador.
                .compactMap { resto.dropFirst().firstIndex(of: Character($0)) }
                .min() ?? resto.endIndex
            saida += AttributedString(String(resto[..<next]))
            resto = resto[next...]
        }
        return saida
    }
}

struct RecipienteView: View {
    let slug: String
    let linhas: [String]
    var edicao: Binding<String>?
    var foco: FocusState<Bool>.Binding?

    private var papel: PapelForma? { PapelForma.porSlug[slug] }
    private var cromo: CromoPapel { papel?.cromo ?? .padrao }
    private var nome: String { papel?.nome ?? slug }
    private var linhasVivas: [String] {
        if let edicao {
            return edicao.wrappedValue.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        }
        return linhas
    }
    private var corpo: String { linhasVivas.joined(separator: "\n") }
    private var aEditar: Bool { edicao != nil }

    var body: some View {
        conteudo
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: aEditar ? .contain : .combine)
            .accessibilityLabel(nome)
            .accessibilityIdentifier("portal-\(slug)")
    }

    @ViewBuilder
    private var conteudo: some View {
        switch cromo {
        case .silencio:
            silencio
        case .verso:
            VStack(alignment: .leading, spacing: 8) {
                SinalTipo(nome: nome)
                prosa(italico: true, tinta: Tema.tintaSuave, folga: 8)
                    .padding(.leading, 22)
            }
            .padding(.vertical, 16)
        case .voz:
            cartao(italico: true, folga: 6, recuo: 12)
        case .chamada:
            cartao(italico: false, folga: 6, recuo: 0, fundo: true)
        case .pergunta, .ideia, .decisao, .risco, .padrao:
            trilho
        case .duplo:
            duplo
        case .cena:
            palco
        case .passos:
            passos
        case .epigrafe:
            epigrafe
        }
    }

    private var epigrafe: some View {
        VStack(alignment: .center, spacing: 8) {
            SinalTipo(nome: nome)
            inscricao
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
    }

    @ViewBuilder
    private var inscricao: some View {
        if let edicao {
            TextField("", text: edicao, axis: .vertical)
                .font(Tema.corpo.italic())
                .lineSpacing(6)
                .foregroundStyle(Tema.tintaSuave)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                .modifier(FocoOpcional(foco: foco))
        } else {
            Text(corpo)
                .font(Tema.corpo.italic())
                .lineSpacing(6)
                .foregroundStyle(Tema.tintaSuave)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .center)
        }
    }

    private var palco: some View {
        VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: nome)
            Rectangle()
                .fill(Tema.tintaFraca.opacity(0.55))
                .frame(height: 1)
            prosa(italico: false, tinta: Tema.tinta, folga: 6)
        }
        .padding(.vertical, 16)
    }

    private var silencio: some View {
        let vivo = linhasVivas.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: nome)
            if aEditar || vivo {
                prosa(italico: true, tinta: Tema.tintaFraca, folga: 6)
            }
        }
        .padding(.vertical, 20)
    }

    private func cartao(italico: Bool, folga: CGFloat, recuo: CGFloat, fundo: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: nome)
            prosa(italico: italico, tinta: italico ? Tema.tintaSuave : Tema.tinta, folga: folga)
                .padding(.leading, recuo)
        }
        .padding(fundo ? 12 : 0)
        .background(fundo ? Tema.superficie : .clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    /// Pergunta, ideia, decisão e risco dividiam o mesmo trilho cinza — a caixa
    /// dizia o nome e nada mais (auditoria da formatação, 17/09). Cada família
    /// ganha o seu sinal e o tom do trilho; o texto segue em tinta, legível.
    private var tomDoTrilho: (cor: Color, simbolo: String?) {
        switch cromo {
        case .pergunta: (Tema.tintaSuave, "questionmark.circle")
        case .ideia: (Tema.ambar, "lightbulb")
        case .decisao: (Tema.tinta, "checkmark.seal")
        case .risco: (Tema.aviso, "exclamationmark.triangle")
        default: (Tema.tintaFraca.opacity(0.55), nil)
        }
    }

    private var trilho: some View {
        let tom = tomDoTrilho
        return HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(tom.cor.opacity(cromo == .padrao ? 1 : 0.85))
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                SinalTipo(nome: nome, simbolo: tom.simbolo, cor: cromo == .padrao ? nil : tom.cor)
                prosa(italico: false, tinta: Tema.tinta, folga: 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var duplo: some View {
        let esquerda = linhasVivas.first ?? ""
        let direita = linhasVivas.dropFirst().joined(separator: "\n")
        return VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: nome)
            HStack(alignment: .top, spacing: 0) {
                coluna(esquerda, lado: .esquerda)
                Rectangle()
                    .fill(Tema.linha)
                    .frame(width: 1)
                coluna(direita, lado: .direita)
            }
            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Tema.linha, lineWidth: 1)
            }
        }
    }

    private enum LadoDuplo { case esquerda, direita }

    @ViewBuilder
    private func coluna(_ texto: String, lado: LadoDuplo) -> some View {
        Group {
            if let edicao {
                TextField("", text: Binding(
                    get: { lado == .esquerda ? (linhasVivas.first ?? "") : linhasVivas.dropFirst().joined(separator: "\n") },
                    set: { novo in
                        var xs = linhasVivas
                        if xs.isEmpty { xs = [""] }
                        switch lado {
                        case .esquerda:
                            xs[0] = novo
                        case .direita:
                            xs = [xs[0]] + novo.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
                        }
                        edicao.wrappedValue = xs.joined(separator: "\n")
                    }
                ), axis: .vertical)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .modifier(FocoOpcional(foco: lado == .esquerda ? foco : nil))
            } else {
                Text(texto)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
            }
        }
        .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
        .padding(10)
        .accessibilityIdentifier(lado == .esquerda ? "duplo-esquerda" : "duplo-direita")
    }

    private var passos: some View {
        VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: nome)
            if aEditar {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .trailing, spacing: 8) {
                        ForEach(Array(linhasVivas.enumerated()), id: \.offset) { i, _ in
                            Text("\(i + 1)")
                                .font(Tema.corpo.monospacedDigit())
                                .foregroundStyle(Tema.tintaFraca)
                                .frame(minWidth: 20, minHeight: 22, alignment: .trailing)
                        }
                    }
                    prosa(italico: false, tinta: Tema.tinta, folga: 4)
                }
            } else {
                ForEach(Array(linhasVivas.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(i + 1)")
                            .font(Tema.corpo.monospacedDigit())
                            .foregroundStyle(Tema.tintaFraca)
                            .frame(minWidth: 20, alignment: .trailing)
                        Text(item)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func prosa(italico: Bool, tinta: Color, folga: CGFloat) -> some View {
        if let edicao {
            TextField("", text: edicao, axis: .vertical)
                .font(italico ? Tema.corpo.italic() : Tema.corpo)
                .lineSpacing(folga)
                .foregroundStyle(tinta)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(FocoOpcional(foco: foco))
        } else {
            Text(corpo)
                .font(italico ? Tema.corpo.italic() : Tema.corpo)
                .lineSpacing(folga)
                .foregroundStyle(tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct FocoOpcional: ViewModifier {
    var foco: FocusState<Bool>.Binding?

    func body(content: Content) -> some View {
        if let foco {
            content.focused(foco)
        } else {
            content
        }
    }
}
