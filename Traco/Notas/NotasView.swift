import SwiftData
import SwiftUI

struct NotasView: View {
    @Bindable var sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Nota.criadaEm, order: .reverse) private var notas: [Nota]
    @State private var busca = ""
    @State private var filtro: FiltroNotas?

    var body: some View {
        Empilha(aberto: $sessao.mostrarPadroes, reduceMotion: reduceMotion) {
            telaNotas
        } frente: {
            PadroesView(sessao: sessao)
        }
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

    private var topbar: some View {
        HStack {
            Button("‹ página") {
                sessao.mostrarPadroes = false
                sessao.mostrarNotas = false
            }
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
            .accessibilityIdentifier("voltar-pagina")
            .accessibilityLabel("Voltar à página")
            Spacer()
            Button("padrões") {
                Teclado.recolher()
                sessao.mostrarPadroes = true
            }
            .font(.subheadline)
            .foregroundStyle(Tema.tintaSuave)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
            .accessibilityIdentifier("abrir-padroes")
            .accessibilityLabel("Padrões")
            .accessibilityHint("Perguntas sobre padrões das suas notas")
            Button {
                sessao.salvar(no: context)
                sessao.novaPagina()
                sessao.mostrarPadroes = false
                sessao.mostrarNotas = false
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.medium))
                    .foregroundStyle(busca.isEmpty ? Tema.ambar : Tema.tintaSuave)
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Nova página")
        }
        .font(Tema.chrome)
        .buttonStyle(PressaoDiscreta())
        .padding(.horizontal, 18)
        .frame(minHeight: Tema.alvo)
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
                .accessibilityIdentifier("limpar-busca")
                .accessibilityLabel("Limpar busca")
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: Tema.alvo)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, Tema.margem)
        .padding(.bottom, 8)
        .opacity(filtro == .trancadas ? 0.4 : 1)
        .disabled(filtro == .trancadas)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FiltroNotas.allCases) { item in
                    Button(item.rawValue) {
                        filtro = filtro == item ? nil : item
                    }
                    .font(Tema.label)
                    .foregroundStyle(filtro == item ? Tema.tinta : Tema.tintaSuave)
                    .padding(.horizontal, 14)
                    .frame(minHeight: Tema.alvo)
                    .background(
                        Capsule()
                            .stroke(filtro == item ? Tema.tintaSuave : Tema.linha, lineWidth: 1)
                    )
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityAddTraits(filtro == item ? [.isSelected] : [])
                    .accessibilityIdentifier("filtro-\(item.slug)")
                    .accessibilityLabel(item.rawValue)
                }
            }
            .padding(.horizontal, Tema.margem)
        }
        .padding(.bottom, 8)
        .accessibilityHint("Um filtro por vez")
    }

    private var lista: some View {
        let visiveis = filtradas
        return Group {
            if visiveis.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(vazioTitulo)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                    Button("escrever na página") {
                        sessao.novaPagina()
                        sessao.mostrarNotas = false
                    }
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tinta)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Tema.margem)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(visiveis, id: \.uuid) { nota in
                            botaoNota(nota)
                            Rectangle().fill(Tema.linha).frame(height: 0.5)
                        }
                    }
                    .padding(.horizontal, Tema.margem)
                }
            }
        }
    }

    private var vazioTitulo: String {
        if filtro == .trancadas { return "nenhuma trancada." }
        if !busca.isEmpty { return "nada com “\(busca)”" }
        return "nada aqui."
    }

    private func botaoNota(_ nota: Nota) -> some View {
        Button {
            if nota.trancada {
                sessao.confirmacao = .naoSeRele(nota.uuid)
            } else {
                sessao.abrir(nota)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                if nota.trancada {
                    Label("Expressiva — trancada", systemImage: "lock.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Tema.tintaSuave)
                    Text("não se relê · \(VozDoAutor.relativo(nota.criadaEm))")
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaFraca)
                } else {
                    DestaqueBusca.texto(titulo(nota), termo: busca, base: Tema.tinta)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        if let g = nota.gesto {
                            Text(g.nome)
                                .foregroundStyle(Tema.tintaSuave)
                        }
                        DestaqueBusca.texto(subtitulo(nota), termo: busca, base: Tema.tintaSuave)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .frame(minHeight: Tema.alvo)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressaoDiscreta())
        .tint(Tema.tinta)
        .contextMenu {
            if !nota.trancada {
                Button("Recordar") { sessao.recordarDaNotas(nota) }
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
            return VozDoAutor.trecho(em: nota.vozDoAutor, termo: busca)
        }
        let respostas = nota.campos.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if respostas.isEmpty {
            return VozDoAutor.relativo(nota.criadaEm)
        }
        return VozDoAutor.truncar(respostas.joined(separator: " · "), 56)
    }
}
