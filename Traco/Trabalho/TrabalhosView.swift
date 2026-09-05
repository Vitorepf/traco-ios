import SwiftData
import SwiftUI

struct TrabalhosView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Query private var notas: [Nota]
    @Query(sort: \Trabalho.atualizadoEm, order: .reverse) private var trabalhos: [Trabalho]
    @State private var aberto: Trabalho?
    @State private var busca = ""
    @AppStorage("trabalho.nova-intencao") private var intencao = ""
    @State private var erro: String?

    private var encontrados: [Trabalho] {
        let q = busca.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return trabalhos }
        return trabalhos.filter {
            AcessoTrabalho.permitido($0, no: context) && $0.titulo.localizedStandardContains(q)
        }
    }

    private var selos: [SeloOrigemTrabalho] { notas.map(SeloOrigemTrabalho.init) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    if scenePhase == .active {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("O que você quer realizar?").font(Tema.secaoNota)
                        TextField("Comece com uma intenção", text: $intencao, axis: .vertical)
                            .lineLimit(2...8)
                            .padding(12)
                            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
                            .accessibilityIdentifier("trabalho-nova-intencao")
                        Button("Começar este trabalho") { criar() }
                            .buttonStyle(.borderedProminent)
                            .disabled(intencao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .accessibilityIdentifier("trabalho-criar")
                        if !intencao.isEmpty {
                            Text("Sua intenção fica como rascunho neste aparelho até começar o trabalho.")
                                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            Button("Limpar intenção") { intencao = "" }
                        }
                        if let erro { Text(erro).foregroundStyle(Tema.aviso) }
                    }
                    TextField("Buscar trabalhos", text: $busca)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("trabalhos-busca")
                    if encontrados.isEmpty {
                        Text(busca.isEmpty ? "Seus trabalhos ficam aqui para continuar de onde parou." : "Nenhum trabalho com esse título.")
                            .foregroundStyle(Tema.tintaSuave)
                    }
                    ForEach(encontrados) { trabalho in
                        let acesso = AcessoTrabalho.estado(trabalho, no: context)
                        if acesso.permitido {
                        Button {
                            guard AcessoTrabalho.permitido(trabalho, no: context) else { return }
                            aberto = trabalho
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(trabalho.titulo).font(Tema.barra)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(trabalho.atualizadoEm, format: .dateTime.day().month().year())
                                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            }
                            .padding(.vertical, 12)
                            .frame(minHeight: Tema.alvo)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("trabalho-na-lista")
                        .accessibilityHint("Abre intenção, versões e próximos atos")
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Trabalho protegido").font(Tema.barra)
                                Text(acesso.mensagem).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                            }
                            .accessibilityIdentifier("trabalho-lista-protegido")
                        }
                    }
                    }
                }
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .padding(Tema.margem)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Tema.fundo)
            .navigationTitle("Trabalhos")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Voltar") { dismiss() }
                }
            }
        }
        .tint(Tema.ambarTinta)
        .onChange(of: selos) { _, _ in
            // O sheet revalida o mesmo selo e remove seu conteúdo sem destruir
            // armazenamento. Mantê-lo aberto mostra por que o acesso mudou.
            erro = nil
        }
        .sheet(item: $aberto) { trabalho in TrabalhoView(trabalho: trabalho) }
    }

    private func criar() {
        do {
            let trabalho = try Trabalho(documento: .init(intencao: intencao))
            context.insert(trabalho)
            try context.save()
            intencao = ""
            erro = nil
            aberto = trabalho
        } catch {
            context.rollback()
            erro = "Não consegui guardar o trabalho. Sua intenção continua aqui; tente novamente."
        }
    }
}
