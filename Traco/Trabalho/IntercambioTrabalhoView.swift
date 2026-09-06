import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct IntercambioTrabalhoView: View {
    let oficina: OficinaTrabalho
    let permiteImportar: Bool
    @Environment(\.modelContext) private var context
    @State private var importar = false
    @State private var exportar = false
    @State private var arquivo: ArquivoMarkdownTrabalho?
    @State private var preview: IntercambioTrabalho.Preview?
    @State private var recado: String?
    @State private var lendo = false
    @State private var operacao = UUID()
    @State private var tentarGuardar = false
    @State private var importacaoPendenteID: UUID?

    private static let limitePrevia = 12000
    /// O começo de cada lado do conflito: as duas têm de caber no mesmo olhar.
    private static let linhasDoConflito = 12

    private var permitido: Bool { AcessoTrabalho.permitido(oficina.trabalho, no: context) }

    /// O que esta tela tem em mãos. O selo da origem recolhe pelo caminho da
    /// Oficina, que é onde toda rota do Trabalho revalida o acesso.
    private var material: IntercambioTrabalho.Material {
        if preview != nil { .revisao } else if arquivo != nil { .exportacao } else if importar { .seletor } else { .nenhum }
    }

    var body: some View {
        DisclosureGroup("Editar com outras ferramentas") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Exporte a versão em Markdown e traga o arquivo editado de volta. O histórico permanece no Traço.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                Button("Exportar versão em Markdown") { prepararExportacao() }
                    .disabled(!oficina.salvo || oficina.documento.versaoAtual == nil || !permitido)
                    .accessibilityIdentifier("trabalho-exportar-md")
                Button("Importar versão de arquivo") { importar = true }
                    .disabled(!permiteImportar || !oficina.salvo || !permitido || lendo)
                    .accessibilityIdentifier("trabalho-importar-md")
                if !permiteImportar {
                    Text("Guarde a intenção ou a versão em edição antes de importar.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }
                if lendo { ProgressView("Lendo arquivo…") }
                if let recado {
                    Text(recado).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("trabalho-intercambio-recado")
                }
                // A versão já está aqui; guardar de novo confirma a MESMA, sem
                // pedir outro arquivo e sem criar uma segunda cópia.
                if tentarGuardar {
                    Button("Tentar guardar de novo") { retentar() }
                        .disabled(!permitido)
                        .accessibilityIdentifier("trabalho-intercambio-tentar-guardar")
                }
                if permitido, let preview { revisao(preview) }
            }.padding(.top, 8)
        }
        .fileImporter(isPresented: $importar,
                      allowedContentTypes: [.plainText, UTType(filenameExtension: "md") ?? .plainText]) { resultado in
            switch resultado {
            case .success(let url): ler(url)
            case .failure(let erro): recado = erro.localizedDescription
            }
        }
        .fileExporter(isPresented: $exportar, document: arquivo,
                      contentType: .plainText, defaultFilename: "traco-versao.md") { resultado in
            switch resultado {
            case .success: recado = "Arquivo exportado. Esta cópia externa não será alterada se você proteger o trabalho depois."
            case .failure(let erro): recado = "Não consegui exportar: \(erro.localizedDescription)"
            }
            arquivo = nil
        }
        .onChange(of: material, initial: true) { _, novo in oficina.intercambioAberto = novo }
        .onDisappear {
            operacao = UUID()
            oficina.intercambioAberto = .nenhum
        }
        .onChange(of: oficina.salvo) { _, salvo in
            if salvo, let id = importacaoPendenteID,
               oficina.documento.artefatos.contains(where: { $0.id == id }) {
                preview = nil
                importacaoPendenteID = nil
                tentarGuardar = false
                recado = IntercambioTrabalho.Desfecho.confirmada.linha
            }
        }
    }

    private func revisao(_ p: IntercambioTrabalho.Preview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Revisar arquivo recebido").font(Tema.secaoNota)
            Text(IntercambioTrabalho.descricaoDaBase(p, em: oficina.documento)).font(Tema.meta)
            if let intencao = p.intencaoDaBaseID, intencao != p.intencaoVigenteID {
                Text("A intenção mudou desde essa base. A nova versão continuará ligada à intenção anterior; as ações e versões atuais serão preservadas.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            if let conflito = IntercambioTrabalho.conflito(p, em: oficina.documento) {
                asDuasVersoes(conflito, p)
            } else {
                Text(p.motivo ?? "Arquivo externo; a autoria não foi verificada.")
                    .font(Tema.meta)
                trecho(p.texto)
                if p.estado != .incompativel {
                    Button("Guardar como nova versão externa") { aplicar(p) }
                        .disabled(!permiteImportar || !oficina.salvo)
                        .accessibilityIdentifier("trabalho-confirmar-importacao")
                }
                Button("Fechar revisão") { preview = nil }
            }
        }
        .padding(12)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
    }

    /// As duas pontas mudaram: o autor lê as duas e escolhe. Nenhuma escolha
    /// sobrescreve — guardar o arquivo é criar versão nova sobre a base dele.
    @ViewBuilder
    private func asDuasVersoes(_ c: IntercambioTrabalho.Conflito,
                               _ p: IntercambioTrabalho.Preview) -> some View {
        Text(c.tituloAtual).rotulo(Tema.tintaSuave)
        Text(verbatim: String(c.textoAtual.prefix(Self.limitePrevia)))
            .font(Tema.corpo).lineLimit(Self.linhasDoConflito)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cartao(.campo)
            .accessibilityIdentifier("trabalho-conflito-atual")
        Text(c.tituloArquivo).rotulo(Tema.tintaSuave)
        Text(verbatim: String(c.textoArquivo.prefix(Self.limitePrevia)))
            .font(Tema.corpo).lineLimit(Self.linhasDoConflito)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cartao(.campo)
            .accessibilityIdentifier("trabalho-conflito-arquivo")
        Text("Mostro o começo de cada uma. \(c.consequencia)")
            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
        Button("Guardar o arquivo como nova versão") { aplicar(p) }
            .disabled(!permiteImportar || !oficina.salvo)
            .accessibilityIdentifier("trabalho-confirmar-importacao")
        Button("Manter só a versão atual") { preview = nil }
            .accessibilityIdentifier("trabalho-conflito-manter")
    }

    private func trecho(_ texto: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: String(texto.prefix(Self.limitePrevia)))
                .font(Tema.corpo).textSelection(.enabled)
            if texto.count > Self.limitePrevia {
                Text("Prévia parcial. A importação preserva o texto completo do arquivo.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
        }
    }

    private func prepararExportacao() {
        guard oficina.verificarAcesso(), oficina.salvo else { return }
        do {
            arquivo = .init(dados: try IntercambioTrabalho.exportar(oficina.documento))
            exportar = true
        } catch { recado = erroDescricao(error) }
    }

    private func ler(_ url: URL) {
        guard oficina.verificarAcesso(), oficina.salvo, permiteImportar else { return }
        let id = UUID()
        operacao = id
        lendo = true
        preview = nil
        Task {
            let resultado = await Task.detached {
                Result { try LeituraMarkdownTrabalho.ler(url, limite: IntercambioTrabalho.limiteBytes) }
            }.value
            guard operacao == id else { return }
            lendo = false
            guard oficina.verificarAcesso(), permiteImportar else { return }
            do {
                preview = try IntercambioTrabalho.preparar(resultado.get(), para: oficina.documento)
                recado = nil
                tentarGuardar = false
            } catch { recado = erroDescricao(error) }
        }
    }

    private func aplicar(_ p: IntercambioTrabalho.Preview) {
        guard oficina.verificarAcesso(), oficina.salvo, permiteImportar else { return }
        var mudou = false
        let guardou = oficina.alterar {
            mudou = try $0.aplicarVersaoExterna(p, confirmarBaseAntiga: p.estado == .baseAntiga)
        }
        let desfecho = IntercambioTrabalho.Desfecho.de(
            mudou: mudou, guardou: guardou, acesso: oficina.acesso.permitido)
        recado = desfecho.linha
        tentarGuardar = desfecho.ofereceTentarGuardar
        // A versão candidata já está na memória da Oficina: o pendente é o
        // commit, não outra importação.
        importacaoPendenteID = desfecho.ofereceTentarGuardar ? oficina.documento.versaoAtual?.id : nil
        if !desfecho.mantemRevisao { preview = nil }
    }

    private func retentar() {
        guard oficina.verificarAcesso() else { return }
        let guardou = oficina.guardar()
        recado = guardou ? IntercambioTrabalho.Desfecho.confirmada.linha
            : IntercambioTrabalho.Desfecho.de(mudou: true, guardou: false,
                                              acesso: oficina.acesso.permitido).linha
        tentarGuardar = !guardou && oficina.acesso.permitido
        if guardou { importacaoPendenteID = nil }
    }

    private func erroDescricao(_ erro: Error) -> String {
        "Não consegui usar este arquivo: \(erro.localizedDescription). Seu trabalho foi preservado."
    }
}
