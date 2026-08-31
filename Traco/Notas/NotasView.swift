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
        HStack(alignment: .firstTextBaseline) {
            Text("Notas")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button {
                sessao.salvar(no: context)
                sessao.novaPagina()
                sessao.aba = .escrever
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Tema.ambar)
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressaoDiscreta())
            .accessibilityIdentifier("nova-pagina")
            .accessibilityLabel("Nova página")
        }
        .padding(.horizontal, Tema.margem)
        .padding(.top, 4)
        .padding(.bottom, 10)
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
                ForEach(FiltroNotas.allCases) { item in
                    Button {
                        Toque.selecao()
                        withAnimation(.easeOut(duration: 0.25)) {
                            filtro = filtro == item ? nil : item
                        }
                    } label: {
                        Text(item.rawValue)
                            .font(Tema.label)
                            .foregroundStyle(filtro == item ? Tema.ambar : Tema.tintaSuave)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(minHeight: 32)
                            .background(
                                Capsule().fill(filtro == item ? Tema.ambarSuave : Tema.superficie)
                            )
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
                        // O arquivo tem tempo: seções por mês, não um pergaminho cego.
                        ForEach(meses(visiveis), id: \.titulo) { secao in
                            Text(secao.titulo)
                                .font(Tema.label)
                                .tracking(Tema.trackingLabel)
                                .foregroundStyle(Tema.tintaFraca)
                                .padding(.top, 20)
                                .padding(.bottom, 6)
                                .accessibilityAddTraits(.isHeader)
                            ForEach(secao.notas, id: \.uuid) { nota in
                                botaoNota(nota)
                                Rectangle().fill(Tema.linha).frame(height: 0.5)
                            }
                        }
                        if visiveis.count > 6 {
                            Text("\(visiveis.count) notas")
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaFraca)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 16)
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
            let titulo = f.string(from: nota.criadaEm).uppercased()
            if grupos[titulo] == nil { ordem.append(titulo) }
            grupos[titulo, default: []].append(nota)
        }
        return ordem.map { SecaoMes(titulo: $0, notas: grupos[$0] ?? []) }
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
