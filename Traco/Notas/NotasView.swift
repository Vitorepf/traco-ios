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
            }
            .padding(.horizontal, Tema.margem)
        }
        .mask(
            HStack(spacing: 0) {
                Rectangle()
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 16)
            }
        )
        .padding(.bottom, 8)
        .accessibilityHint("Um filtro por vez")
    }

    private var lista: some View {
        let visiveis = filtradas
        return Group {
            if visiveis.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: busca.isEmpty && filtro == nil ? "square.and.pencil" : "magnifyingglass")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Tema.tintaFraca)
                        .accessibilityHidden(true)
                    Text(vazioTitulo)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                    Button("escrever na página") {
                        sessao.novaPagina()
                        sessao.mostrarNotas = false
                    }
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(Tema.ambar)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                }
                .frame(maxWidth: .infinity)
                .padding(Tema.margem)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

    private func botaoNota(_ nota: Nota) -> some View {
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
            return VozDoAutor.trecho(em: nota.vozDoAutor, termo: busca)
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
