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
    @State private var importacaoPendenteID: UUID?

    private var permitido: Bool { AcessoTrabalho.permitido(oficina.trabalho, no: context) }

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
                if let recado { Text(recado).font(Tema.meta).foregroundStyle(Tema.tintaSuave) }
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
        .onDisappear { operacao = UUID() }
        .onChange(of: oficina.salvo) { _, salvo in
            if salvo, let id = importacaoPendenteID,
               oficina.documento.artefatos.contains(where: { $0.id == id }) {
                preview = nil
                importacaoPendenteID = nil
                recado = "A versão externa foi guardada na nova tentativa. O histórico foi preservado."
            }
        }
    }

    private func revisao(_ p: IntercambioTrabalho.Preview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Revisar arquivo recebido").font(Tema.secaoNota)
            Text(descreverBase(p)).font(Tema.meta)
            if let intencao = p.intencaoDaBaseID, intencao != p.intencaoVigenteID {
                Text("A intenção mudou desde essa base. A nova versão continuará ligada à intenção anterior; as ações e versões atuais serão preservadas.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            Text(p.motivo ?? "Arquivo externo; a autoria não foi verificada.")
                .font(Tema.meta)
            Text(verbatim: String(p.texto.prefix(12000)))
                .font(Tema.corpo).textSelection(.enabled)
            if p.texto.count > 12000 {
                Text("Prévia parcial. A importação preserva o texto completo do arquivo.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            if p.estado != .incompativel {
                Button(p.estado == .baseAntiga ? "Criar versão a partir dessa base antiga" : "Guardar como nova versão externa") {
                    aplicar(p)
                }
                .disabled(!permiteImportar || !oficina.salvo)
                .accessibilityIdentifier("trabalho-confirmar-importacao")
            }
            Button("Fechar revisão") { preview = nil }
        }
        .padding(12)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
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
            } catch { recado = erroDescricao(error) }
        }
    }

    private func aplicar(_ p: IntercambioTrabalho.Preview) {
        guard oficina.verificarAcesso(), oficina.salvo, permiteImportar else { return }
        var mudou = false
        if oficina.alterar({ mudou = try $0.aplicarVersaoExterna(p, confirmarBaseAntiga: p.estado == .baseAntiga) }) {
            preview = nil
            recado = mudou ? "Nova versão externa guardada. As versões anteriores foram preservadas." : "Este conteúdo já está guardado; nenhuma versão duplicada foi criada."
        } else {
            if mudou { importacaoPendenteID = oficina.documento.versaoAtual?.id }
            recado = "Não foi possível aplicar o arquivo. Confira o salvamento e importe novamente se a versão ou a intenção mudou."
        }
    }

    private func descreverBase(_ p: IntercambioTrabalho.Preview) -> String {
        func numero(_ id: UUID?) -> String {
            guard let id, let i = oficina.documento.artefatos.firstIndex(where: { $0.id == id }) else { return "nenhuma" }
            return String(i + 1)
        }
        switch p.estado {
        case .baseAtual: return "Base do arquivo: versão \(numero(p.baseID)), a versão atual. O conteúdo recebido será uma nova versão."
        case .baseAntiga: return "Base do arquivo: versão \(numero(p.baseID)). Versão atual: \(numero(p.versaoVigenteID)). A nova versão partirá dessa base antiga, sem apagar a atual."
        case .semVinculo: return "Arquivo sem vínculo de origem. Será acrescentado como material externo, ligado à intenção atual."
        case .incompativel: return "Este arquivo não pode ser aplicado a este trabalho."
        }
    }

    private func erroDescricao(_ erro: Error) -> String {
        "Não consegui usar este arquivo: \(erro.localizedDescription). Seu trabalho foi preservado."
    }
}
