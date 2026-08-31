import SwiftUI

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
                            Circle()
                                .fill(Tema.tintaFraca)
                                .frame(width: 5, height: 5)
                                .padding(.top, 8)
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
                    HStack(alignment: .center, spacing: 8) {
                        Button {
                            aoAlternarTarefa?(i)
                        } label: {
                            Image(systemName: item.feito ? "checkmark.circle.fill" : "circle")
                                .font(.body)
                                .foregroundStyle(item.feito ? Tema.tintaSuave : Tema.tintaFraca)
                                .frame(width: Tema.alvo, height: Tema.alvo)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.feito ? "Feita" : "Por fazer")
                        Text(atributos(item.texto))
                            .font(Tema.corpo)
                            .foregroundStyle(item.feito ? Tema.tintaFraca : Tema.tinta)
                            .strikethrough(item.feito, color: Tema.tintaFraca)
                    }
                }
            }
            .accessibilityIdentifier("portal-tarefa")
        case .citacao(let xs):
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 1)
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
        return VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: "tabela")
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

    private func atributos(_ bruto: String) -> AttributedString {
        var saida = AttributedString()
        var resto = bruto[...]
        while !resto.isEmpty {
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
            if resto.hasPrefix("*"),
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
            let next = resto.firstIndex(of: "`")
                ?? resto.firstIndex(of: "*")
                ?? resto.firstIndex(of: "~")
                ?? resto.firstIndex(of: "[")
                ?? resto.endIndex
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

    private var trilho: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Tema.tintaFraca.opacity(0.55))
                .frame(width: 2)
            VStack(alignment: .leading, spacing: 8) {
                SinalTipo(nome: nome)
                prosa(italico: false, tinta: Tema.tinta, folga: 4)
            }
        }
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
