import SwiftData
import SwiftUI

/// A folha dos trabalhos, no mundo claro (SISTEMA-CLARO §2.3): cabeçalho de
/// folha, título de tela, campo em névoa e a ação em cápsula carvão. Era
/// `NavigationStack` com barra do sistema e "Voltar" em cápsula de 30 pt só
/// aqui (auditoria V9, Componentes 4).
struct TrabalhosView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Query private var notas: [Nota]
    @Query(sort: \Trabalho.atualizadoEm, order: .reverse) private var trabalhos: [Trabalho]
    @State private var aberto: Trabalho?
    /// Qual trabalho nasceu agora: só ele abre com o cursor no pedido.
    @State private var criadoAgora: UUID?
    @State private var busca = ""
    @AppStorage("trabalho.nova-intencao") private var intencao = ""
    @State private var erro: String?
    @FocusState private var intencaoEmFoco: Bool

    private var encontrados: [Trabalho] {
        let q = busca.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return trabalhos }
        return trabalhos.filter {
            AcessoTrabalho.permitido($0, no: context) && $0.titulo.localizedStandardContains(q)
        }
    }

    private var selos: [SeloOrigemTrabalho] { notas.map(SeloOrigemTrabalho.init) }
    private var podeCriar: Bool { !intencao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Tema.entreSecoes) {
                if scenePhase == .active {
                    abertura
                    lista
                }
            }
            .font(Tema.corpo)
            .foregroundStyle(Tema.tinta)
            .padding(.horizontal, Tema.margem)
            .padding(.top, Tema.entreItens)
            .padding(.bottom, Tema.margem)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        // A saída fica fora da rolagem: a lista cresce, a porta não viaja com
        // ela. Por `safeAreaInset` (ver TrabalhoView: irmão de VStack estoura
        // a largura em AX5).
        .safeAreaInset(edge: .top, spacing: 0) {
            CabecalhoDeFolha(saida: .voltar, aoSair: { dismiss() }, prefixo: "trabalhos")
                .padding(.horizontal, Tema.margem)
                .frame(maxWidth: .infinity)
                .background(Tema.fundo)
        }
        .background(Tema.fundo)
        .tint(Tema.ambarTinta)
        .onChange(of: selos) { _, _ in
            // O sheet revalida o mesmo selo e remove seu conteúdo sem destruir
            // armazenamento. Mantê-lo aberto mostra por que o acesso mudou.
            erro = nil
        }
        .sheet(item: $aberto) { trabalho in
            TrabalhoView(trabalho: trabalho, pedidoEmFoco: trabalho.uuid == criadoAgora)
        }
    }

    /// A intenção primeiro: o campo e a única ação cheia da tela.
    private var abertura: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            Text("Trabalhos")
                .font(Tema.tituloTela)
                .tracking(Tema.trackingTitulo)
            // A abertura é um convite, não um rótulo de formulário: a caixa
            // alta fica para as seções ("SEUS TRABALHOS"), que são nomes.
            Text("O que você quer realizar?")
                .font(Tema.chrome.weight(.semibold))
            TextField("Comece com uma intenção", text: $intencao, axis: .vertical)
                .lineLimit(2...8)
                .focused($intencaoEmFoco)
                .cartao(.campo)
                .accessibilityIdentifier("trabalho-nova-intencao")
            // A ação principal não vira fantasma por falta de texto: tocar sem
            // intenção leva o foco ao campo que falta (curva-zero §3, "erro
            // localizado e ajuda acionável"). Desabilitar aqui apagava a única
            // ação da tela — o defeito 2 da V9 pelo avesso.
            Pilula("Começar este trabalho", forma: .larga, selecionada: true) {
                guard podeCriar else { intencaoEmFoco = true; return }
                criar()
            }
            .accessibilityIdentifier("trabalho-criar")
            .accessibilityHint(podeCriar ? "" : "Escreva a intenção primeiro")
            if !podeCriar {
                Text("Escreva a intenção acima para começar.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            } else {
                Text("Sua intenção fica como rascunho neste aparelho até começar o trabalho.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                Pilula("Limpar intenção", forma: .filtro) { intencao = "" }
            }
            if let erro {
                Text(erro).font(Tema.meta).foregroundStyle(Tema.aviso)
            }
        }
    }

    @ViewBuilder private var lista: some View {
        VStack(alignment: .leading, spacing: Tema.entreItens) {
            Text("Seus trabalhos").rotulo(Tema.tintaSuave)
            TextField("Buscar trabalhos", text: $busca)
                .cartao(.campo)
                .accessibilityIdentifier("trabalhos-busca")
            if encontrados.isEmpty {
                // ponytail: `Vazio` traz a margem de tela embutida e aqui ela
                // dobraria; a frase e a saída são as mesmas dele.
                Text(busca.isEmpty ? "Seus trabalhos ficam aqui para continuar de onde parou."
                     : "Nenhum trabalho com esse título.")
                    .foregroundStyle(Tema.tintaSuave)
                if !busca.isEmpty {
                    Pilula("Ver todos os trabalhos", forma: .filtro) { busca = "" }
                }
            }
            ForEach(encontrados) { trabalho in
                let acesso = AcessoTrabalho.estado(trabalho, no: context)
                if acesso.permitido {
                    Button {
                        guard AcessoTrabalho.permitido(trabalho, no: context) else { return }
                        // reabrir um trabalho não é começar um: sem teclado
                        criadoAgora = nil
                        aberto = trabalho
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(trabalho.titulo).font(Tema.chrome.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(trabalho.atualizadoEm, format: .dateTime.day().month().year())
                                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                                .monospacedDigit()
                        }
                        .cartao(.papel)
                        .frame(minHeight: Tema.alvo)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.discreto)
                    .accessibilityIdentifier("trabalho-na-lista")
                    .accessibilityHint("Abre intenção, versões e próximos atos")
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Trabalho protegido").font(Tema.chrome.weight(.semibold))
                        Text(acesso.mensagem).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    }
                    .cartao(.papel)
                    .accessibilityIdentifier("trabalho-lista-protegido")
                }
            }
        }
    }

    private func criar() {
        do {
            let trabalho = try Trabalho(documento: .init(intencao: intencao))
            context.insert(trabalho)
            try context.save()
            intencao = ""
            erro = nil
            criadoAgora = trabalho.uuid
            aberto = trabalho
        } catch {
            context.rollback()
            erro = "Não consegui guardar o trabalho. Sua intenção continua aqui; tente novamente."
        }
    }
}
