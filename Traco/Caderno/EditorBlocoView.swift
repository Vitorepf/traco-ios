import SwiftUI

struct EditorBlocoView: View {
    let bloco: BlocoCaderno
    var folga: CGFloat
    var foco: FocusState<Bool>.Binding
    var aoMudar: (BlocoCaderno) -> Void
    var aoLingua: (() -> Void)?

    var body: some View {
        switch bloco {
        case .codigo(let lingua, let fonte) where lingua == "tex" || lingua == "latex":
            PortalFormulaView(
                fonte: fonte,
                edicao: binding { Caderno.comTexto(bloco, $0) },
                foco: foco
            )
        case .codigo(let lingua, let fonte):
            PortalCodigoView(
                lingua: lingua,
                fonte: fonte,
                edicao: binding { Caderno.comTexto(bloco, $0) },
                foco: foco,
                aoLingua: aoLingua
            )
        case .titulo(let n, _):
            VStack(alignment: .leading, spacing: 6) {
                if n > 1 {
                    SinalTipo(nome: n == 2 ? "seção" : "subseção")
                }
                TextField("", text: binding { Caderno.comTexto(bloco, $0) }, axis: .vertical)
                    .font(n <= 1 ? Tema.tituloNota : Tema.secaoNota)
                    .foregroundStyle(Tema.tinta)
                    .textFieldStyle(.plain)
                    .focused(foco)
                    .tint(Tema.ambar)
                    .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                    .accessibilityLabel(n <= 1 ? "Título" : n == 2 ? "Seção" : "Subseção")
                    .accessibilityIdentifier(n <= 1 ? "portal-titulo" : n == 2 ? "portal-seccao" : "portal-subseccao")
            }
        case .itens:
            // lista edita CRUA (marcadores visíveis) num campo só: o cursor nunca
            // troca de árvore e o Enter herda o marcador via Caderno.continuar
            TextEditor(text: Binding(
                get: { Caderno.serializar(bloco) },
                set: { novo in
                    aoMudar(.paragrafo(Caderno.continuar(velho: Caderno.serializar(bloco), novo: novo)))
                }
            ))
            .font(Tema.corpo)
            .lineSpacing(folga)
            .foregroundStyle(Tema.tinta)
            .scrollContentBackground(.hidden)
            .focused(foco)
            .tint(Tema.ambar)
            .padding(.horizontal, -Tema.sangriaEditor)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .accessibilityLabel("Lista")
            .accessibilityIdentifier("portal-lista")
        case .citacao:
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Tema.tintaFraca)
                    .frame(width: 2)
                editorLinhas
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .accessibilityIdentifier("portal-citacao")
        case .tarefas(let xs):
            editorTarefas(xs)
        case .recipiente(let slug, let linhas):
            RecipienteView(
                slug: slug,
                linhas: linhas,
                edicao: binding { Caderno.comTexto(bloco, $0) },
                foco: foco
            )
        case .tabela(let cabeca, let corpo):
            editorTabela(cabeca, corpo)
        case .divisoria:
            ProsaView(bloco: .divisoria)
        default:
            TextEditor(text: binding { Caderno.comTexto(bloco, $0) })
                .font(Tema.corpo)
                .lineSpacing(folga)
                .tracking(-0.05)
                .foregroundStyle(Tema.tinta)
                .scrollContentBackground(.hidden)
                .focused(foco)
                .tint(Tema.ambar)
                // o recuo interno do TextEditor tirava a linha do eixo
                .padding(.horizontal, -Tema.sangriaEditor)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
                .accessibilityLabel("Página")
                .accessibilityIdentifier("pagina")
        }
    }

    private var editorLinhas: some View {
        TextEditor(text: binding { Caderno.comTexto(bloco, $0) })
            .font({
                if case .citacao = bloco { return Tema.corpo.italic() }
                return Tema.corpo
            }())
            .lineSpacing(folga)
            .foregroundStyle(Tema.tinta)
            .scrollContentBackground(.hidden)
            .focused(foco)
            .tint(Tema.ambar)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .accessibilityLabel(rotuloLinhas)
            .accessibilityIdentifier("pagina")
    }

    private var rotuloLinhas: String {
        switch bloco {
        case .itens: "Lista"
        case .tarefas: "Tarefas"
        case .citacao: "Citação"
        case .recipiente(let slug, _): PapelForma.nome(de: slug)
        default: "Página"
        }
    }

    private func editorTarefas(_ xs: [TarefaCaderno]) -> some View {
        let linhas = xs.isEmpty ? [TarefaCaderno(feito: false, texto: "")] : xs
        let extra = !(linhas.last?.texto.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let visiveis = extra ? linhas + [TarefaCaderno(feito: false, texto: "")] : linhas
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(visiveis.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .center, spacing: 8) {
                    Button {
                        var next = linhas
                        if i < next.count {
                            next[i].feito.toggle()
                            aoMudar(.tarefas(next))
                        }
                    } label: {
                        Image(systemName: item.feito ? "checkmark.circle.fill" : "circle")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.body)
                            .foregroundStyle(item.feito ? Tema.tintaSuave : Tema.tintaFraca)
                            .frame(width: Tema.alvo, height: Tema.alvo)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.feito ? "Feita" : "Por fazer")
                    TextField("", text: Binding(
                        get: { item.texto },
                        set: { novo in
                            var next = linhas
                            if i < next.count {
                                next[i].texto = novo
                            } else {
                                next.append(TarefaCaderno(feito: false, texto: novo))
                            }
                            aoMudar(.tarefas(next.isEmpty ? [TarefaCaderno(feito: false, texto: "")] : next))
                        }
                    ), axis: .vertical)
                    .font(Tema.corpo)
                    .foregroundStyle(item.feito ? Tema.tintaFraca : Tema.tinta)
                    .strikethrough(item.feito, color: Tema.tintaFraca)
                    .textFieldStyle(.plain)
                    .focused(foco)
                    .tint(Tema.ambar)
                }
            }
        }
        .accessibilityLabel("Tarefas")
        .accessibilityIdentifier("portal-tarefa")
    }

    private func editorTabela(_ cabeca: [String], _ corpo: [[String]]) -> some View {
        let cols = max(cabeca.count, corpo.map(\.count).max() ?? 0, 1)
        return VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: "tabela")
            Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(0..<cols, id: \.self) { c in
                        campo(c < cabeca.count ? cabeca[c] : "", cabecalho: true) { novo in
                            var next = cabeca
                            while next.count <= c { next.append("") }
                            next[c] = novo
                            aoMudar(.tabela(cabeca: next, corpo: corpo))
                        }
                    }
                }
                ForEach(Array(corpo.enumerated()), id: \.offset) { i, row in
                    GridRow {
                        ForEach(0..<cols, id: \.self) { c in
                            campo(c < row.count ? row[c] : "") { novo in
                                var next = corpo
                                while next.count <= i { next.append(Array(repeating: "", count: cols)) }
                                var linha = next[i]
                                while linha.count <= c { linha.append("") }
                                linha[c] = novo
                                next[i] = linha
                                aoMudar(.tabela(cabeca: cabeca, corpo: next))
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Tema.linha, lineWidth: 1)
            }
            // a tabela cresce por toque — o autor estrutura, nunca monta a forma
            HStack(spacing: 20) {
                Button("+ linha") {
                    Toque.selecao()
                    aoMudar(.tabela(cabeca: cabeca, corpo: corpo + [Array(repeating: "", count: cols)]))
                }
                .accessibilityIdentifier("tabela-mais-linha")
                Button("+ coluna") {
                    Toque.selecao()
                    aoMudar(.tabela(cabeca: cabeca + [""], corpo: corpo.map { $0 + [""] }))
                }
                .accessibilityIdentifier("tabela-mais-coluna")
            }
            .font(Tema.label)
            .foregroundStyle(Tema.tintaSuave)
            .buttonStyle(PressaoDiscreta())
            .frame(minHeight: Tema.alvo)
        }
        .accessibilityIdentifier("portal-tabela")
    }

    private func campo(_ valor: String, cabecalho: Bool = false,
                       ao: @escaping @Sendable (String) -> Void) -> some View {
        TextField("", text: Binding(get: { valor }, set: ao))
            .font(cabecalho ? Tema.corpo.weight(.medium) : Tema.corpo)
            .foregroundStyle(cabecalho ? Tema.tintaSuave : Tema.tinta)
            .padding(8)
            .focused(foco)
            .tint(Tema.ambar)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            .background(cabecalho ? Tema.superficie : .clear)
            // a estrutura precisa ser VISÍVEL: fio entre células, senão crescer não muda nada
            .overlay(alignment: .bottom) { Rectangle().fill(Tema.linha).frame(height: 0.5) }
            .overlay(alignment: .trailing) { Rectangle().fill(Tema.linha).frame(width: 0.5) }
    }

    private func binding(_ mapa: @escaping (String) -> BlocoCaderno) -> Binding<String> {
        Binding(
            get: { Caderno.textoVisivel(bloco) },
            set: { aoMudar(mapa($0)) }
        )
    }
}
