import SwiftData
import SwiftUI
import UIKit

/// O trabalho permanece um documento: versões, ato e retorno, sem um wizard.
struct TrabalhoView: View {
    let trabalho: Trabalho
    var acaoEmFoco: UUID? = nil
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.abrirCalendarioDoTrabalho) private var abrirCalendario
    @Environment(\.scenePhase) private var scenePhase
    @Query private var notas: [Nota]
    @State private var oficina: OficinaTrabalho?
    @State private var erroDeLeitura: String?
    @State private var rascunhos: [String: String] = [:]
    @State private var limparAposCommit: [String] = []
    @State private var editandoVersao = false
    @State private var confirmarDescarte = false
    @State private var recuperacao: String?
    @State private var confirmarApagarCopia = false
    @State private var copiaCopiada = false
    @State private var exibicaoSuspensa = false

    private var chaveRascunho: String { "trabalho.rascunhos.\(trabalho.uuid.uuidString)" }
    private var selos: [SeloOrigemTrabalho] { notas.map(SeloOrigemTrabalho.init) }
    private var acesso: AcessoTrabalho.Estado { AcessoTrabalho.estado(trabalho, no: context) }

    var body: some View {
        NavigationStack {
            ScrollViewReader { rolagem in
            ScrollView {
                VStack(alignment: .leading, spacing: Tema.entreSecoes) {
                    if scenePhase != .active {
                        Text("Trabalho").font(Tema.secaoNota)
                    } else if !acesso.permitido {
                        Text("Trabalho protegido").font(Tema.secaoNota)
                        Text(acesso.mensagem).foregroundStyle(Tema.tintaSuave)
                            .accessibilityIdentifier("trabalho-protegido")
                    } else if let oficina {
                        documento(oficina).buttonStyle(AcaoTrabalhoStyle())
                    } else if let erroDeLeitura {
                        Text(erroDeLeitura).foregroundStyle(Tema.aviso)
                        Button("Tentar abrir novamente") { abrir() }
                    } else {
                        ProgressView("Abrindo trabalho…")
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
            .task(id: oficina != nil) {
                if oficina != nil, acesso.permitido, let acaoEmFoco {
                    await Task.yield()
                    rolagem.scrollTo(acaoEmFoco, anchor: .top)
                }
            }
            }
            .navigationTitle("Trabalho")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Voltar") { voltar() }
                        .accessibilityIdentifier("trabalho-voltar")
                }
            }
        }
        .tint(Tema.ambarTinta)
        .interactiveDismissDisabled()
        .task { if oficina == nil { abrir() } }
        .onChange(of: selos) { _, _ in revalidar() }
        .onChange(of: trabalho.conteudoJSON) { _, _ in revalidar() }
        .onChange(of: scenePhase) { _, fase in
            revalidar()
        }
        .onDisappear { oficina?.cancelar() }
        .confirmationDialog("Descartar os rascunhos dos campos?", isPresented: $confirmarDescarte) {
            Button("Descartar rascunhos", role: .destructive) { limpar(Array(rascunhos.keys)) }
            Button("Manter", role: .cancel) {}
        } message: {
            Text("As versões, atos e relatos já guardados permanecem. Só os campos ainda em edição serão limpos.")
        }
        .confirmationDialog("Apagar a cópia de recuperação?", isPresented: $confirmarApagarCopia) {
            Button("Apagar cópia", role: .destructive) {
                guard acesso.permitido else { revalidar(); return }
                UserDefaults.standard.removeObject(forKey: chaveRascunho + ".recuperacao")
                recuperacao = nil
            }
            Button("Manter", role: .cancel) {}
        } message: {
            Text("A versão atual do trabalho e os rascunhos dos campos permanecem.")
        }
    }

    @ViewBuilder private func documento(_ o: OficinaTrabalho) -> some View {
        if let erro = o.erro {
            VStack(alignment: .leading, spacing: 8) {
                Text(erro).foregroundStyle(Tema.aviso)
                    .accessibilityIdentifier("trabalho-erro")
                if !o.salvo {
                    Button("Tentar guardar novamente") { guardar(o) }
                        .accessibilityIdentifier("trabalho-tentar-guardar")
                    Button("Preservar cópia e reabrir a versão atual") { preservarEReabrir(o) }
                }
            }
        }
        intencao(o)
        producao(o)
        if let versao = o.documento.versaoAtual { artefato(versao, oficina: o) }
        IntercambioTrabalhoView(oficina: o, permiteImportar: !edicaoPendente(o))
        atos(o)
        retorno(o)
        historico(o)
        Text(o.salvo ? "Versões e atos guardados neste aparelho." : "Alterações ainda não guardadas.")
            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            .accessibilityIdentifier("trabalho-salvamento")
        if !rascunhos.isEmpty {
            Text("Os campos em edição, incluindo seu pedido, ficam como rascunhos neste aparelho e voltam ao reabrir este trabalho. Eles só entram no documento quando você os guarda.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            Button("Descartar rascunhos dos campos") { confirmarDescarte = true }
                .disabled(!o.salvo || o.documento.pedidoAtivo != nil)
        }
        if let recuperacao {
            VStack(alignment: .leading, spacing: 8) {
                Text("Uma cópia das alterações anteriores foi preservada neste aparelho, separada da versão atual.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                Button("Copiar dados de recuperação") {
                    guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
                    UIPasteboard.general.string = recuperacao
                    copiaCopiada = true
                }
                if copiaCopiada { Text("Cópia na área de transferência.").font(Tema.meta) }
                Button("Apagar cópia de recuperação") { confirmarApagarCopia = true }
            }
        }
    }

    private func intencao(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(o.documento.intencaoAtual.texto).font(Tema.tituloTela)
                .accessibilityAddTraits(.isHeader)
            if !o.documento.intencaoAtual.resultado.isEmpty {
                Text(o.documento.intencaoAtual.resultado).foregroundStyle(Tema.tintaSuave)
            }
            DisclosureGroup("Intenção, resultado e apoio") {
                VStack(alignment: .leading, spacing: 12) {
                    campo("O que quero realizar", chave: "intencao", padrao: o.documento.intencaoAtual.texto, exemplo: "Apresentar minha ideia")
                    campo("Como reconhecerei o resultado", chave: "resultado", padrao: o.documento.intencaoAtual.resultado, exemplo: "Explicar em um minuto")
                    Button("Guardar intenção") {
                        let texto = rascunhos["intencao"] ?? o.documento.intencaoAtual.texto
                        let resultado = rascunhos["resultado"] ?? o.documento.intencaoAtual.resultado
                        aplicar(o, limpar: ["intencao", "resultado"]) { try $0.reverIntencao(texto, resultado: resultado) }
                    }
                    .disabled(!o.salvo)
                    Picker("Neste trabalho, prefiro", selection: Binding(
                        get: { o.documento.apoio },
                        set: { apoio in aplicar(o) { $0.cancelarPedido(); $0.apoio = apoio } }
                    )) {
                        Text("Delegar a produção").tag(DocumentoTrabalho.Apoio.delegar)
                        Text("Praticar com apoio").tag(DocumentoTrabalho.Apoio.praticar)
                        Text("Combinar os dois").tag(DocumentoTrabalho.Apoio.combinar)
                    }
                    .pickerStyle(.menu)
                    .disabled(!o.salvo)
                    Text("Você pode mudar o apoio conforme o que quer fazer. Delegar não exige aprender a executar tudo.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                }.padding(.top, 8)
            }
        }
    }

    private func producao(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titulo("Preparar uma versão")
            campo("O que você quer que a IA prepare ou ajuste?", chave: "pedido", exemplo: "Prepare uma apresentação curta")
                .accessibilityIdentifier("trabalho-pedido")
            if edicaoPendente(o) {
                Text("Guarde a intenção ou a versão que está editando antes de pedir uma nova preparação.")
                    .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            }
            if o.documento.pedidoAtivo != nil {
                ProgressView("A IA está preparando…")
                    .accessibilityIdentifier("trabalho-preparando")
                Button("Cancelar preparação") { o.cancelar() }
            } else {
                Button(o.documento.versaoAtual == nil ? "Preparar com IA" : "Preparar nova versão com IA") {
                    o.gerar(rascunhos["pedido"] ?? "")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!o.salvo || vazio("pedido") || edicaoPendente(o))
                .accessibilityIdentifier("trabalho-gerar")
                if let pedido = o.documento.pedidos.last,
                   pedido.estado == .interrompido || pedido.estado == .falhou || pedido.estado == .cancelado {
                    Text("A preparação anterior foi \(pedido.estado == .interrompido ? "interrompida" : pedido.estado == .falhou ? "malsucedida" : "cancelada"). O pedido continua disponível.")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    Button("Retomar esse pedido") { definir("pedido", pedido.instrucao) }
                }
            }
            if o.documento.versaoAtual == nil {
                DisclosureGroup("Escrever minha própria versão") {
                    VStack(alignment: .leading, spacing: 12) {
                        campo("Sua versão", chave: "versao")
                        Button("Guardar minha versão") { guardarVersao(o) }
                            .disabled(!o.salvo || vazio("versao"))
                    }.padding(.top, 8)
                }
            }
        }
    }

    private func artefato(_ a: DocumentoTrabalho.Artefato, oficina o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titulo("Versão \(numero(a.id, em: o.documento))")
            Text(a.produtor).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            if a.intencaoID != o.documento.intencaoAtual.id {
                Text("Esta versão foi preparada para uma intenção anterior. Confira o que ainda serve.")
                    .font(Tema.meta).foregroundStyle(Tema.aviso)
            }
            ConteudoTrabalhoView(fonte: a.conteudo)
                .id(a.id)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("trabalho-artefato")
            if editandoVersao || !vazio("versao") {
                campo("Editar a versão", chave: "versao", padrao: a.conteudo)
                    .accessibilityIdentifier("trabalho-editar-versao")
                Button("Guardar como nova versão") { guardarVersao(o) }
                    .disabled(!o.salvo || vazio("versao"))
            } else {
                Button("Editar esta versão") { definir("versao", a.conteudo); editandoVersao = true }
            }
        }
        .padding(16)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
    }

    private func atos(_ o: OficinaTrabalho) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            titulo("Próximo ato")
            campo("O que você vai fazer com este trabalho?", chave: "acao", exemplo: "Ensaiar a apresentação")
                .accessibilityIdentifier("trabalho-acao")
            Button("Preparar este ato") {
                let texto = rascunhos["acao"] ?? ""
                aplicar(o, limpar: ["acao"]) { try $0.prepararAcao(texto) }
            }
            .disabled(!o.salvo || vazio("acao"))
            .accessibilityIdentifier("trabalho-preparar-acao")
            Text("Preparar não marca como realizado. Você pode escolher um horário para cada ação.")
                .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            ForEach(o.documento.acoes) { acao in
                VStack(alignment: .leading, spacing: 12) {
                    Text(acao.texto).font(Tema.barra)
                    Text(acao.estado == .executada ? "Você marcou como realizada" : acao.estado == .cancelada ? "Cancelado" : "Realização ainda não confirmada")
                        .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    if let id = acao.artefatoID {
                        Text("Material: versão \(numero(id, em: o.documento))")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                    }
                    AgendamentoAcaoView(acao: acao, podeGuardar: o.salvo, guardar: { data in
                        aplicar(o) { try $0.agendar(acao.id, para: data) }
                    }, verNoCalendario: { data in
                        guard o.verificarAcesso(), o.salvo else { revalidar(); return false }
                        o.cancelar()
                        guard guardar(o), abrirCalendario?(data) == true else { return false }
                        dismiss()
                        return true
                    })
                    if acao.estado != .cancelada {
                        if acao.estado == .pendente {
                            Button("Realizei esta ação") { aplicar(o) { try $0.marcarExecutada(acao.id) } }
                                .disabled(!o.salvo)
                                .accessibilityIdentifier("trabalho-marcar-realizada")
                        }
                        let chave = "relato-\(acao.id.uuidString)"
                        campo("O que aconteceu?", chave: chave, exemplo: "O que funcionou ou faltou")
                        Button("Registrar meu relato") {
                            let texto = rascunhos[chave] ?? ""
                            aplicar(o, limpar: [chave]) { try $0.registrarRelato(texto, acaoID: acao.id) }
                        }
                        .disabled(!o.salvo || vazio(chave))
                        .accessibilityIdentifier("trabalho-registrar-relato")
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) { Rectangle().fill(Tema.linha).frame(height: 1) }
                .id(acao.id)
            }
        }
    }

    @ViewBuilder private func retorno(_ o: OficinaTrabalho) -> some View {
        if !o.documento.evidencias.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                titulo("O que aconteceu")
                ForEach(o.documento.evidencias) { e in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Relato de \(e.atribuidaA) · \(e.data.formatted(date: .abbreviated, time: .shortened))")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        Text(e.texto).textSelection(.enabled)
                    }
                }
                Button("Revisar com estes relatos") {
                    definir("pedido", "Revise a versão à luz dos relatos registrados e do resultado desejado. Diferencie o que foi observado do que ainda é incerto e proponha um ajuste concreto.")
                    o.gerar(rascunhos["pedido"] ?? "")
                }
                .disabled(!o.salvo || o.documento.pedidoAtivo != nil || edicaoPendente(o))
                .accessibilityIdentifier("trabalho-revisar")
                DisclosureGroup("Apoio para a próxima tentativa") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Se percebeu uma dificuldade, registre uma hipótese. Pode ser contexto, recursos ou uma capacidade a praticar — não é um diagnóstico.")
                            .font(Tema.meta).foregroundStyle(Tema.tintaSuave)
                        campo("O que pode ajudar na próxima vez?", chave: "hipotese", exemplo: "Ensaiar só a abertura")
                        Button("Guardar hipótese minha") {
                            let texto = rascunhos["hipotese"] ?? ""
                            aplicar(o, limpar: ["hipotese"]) { d in
                                d.hipoteses.append(.init(texto: texto, contexto: d.intencaoAtual.texto,
                                    evidencias: d.evidencias.map(\.id)))
                            }
                        }
                        .disabled(!o.salvo || vazio("hipotese"))
                        ForEach(o.documento.hipoteses) { h in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(h.texto)
                                Text("Hipótese \(h.estado.rawValue)").font(Tema.meta)
                                Button("Faz sentido neste contexto") { aplicar(o) { try $0.avaliarHipotese(h.id, estado: .confirmada) } }
                                Button("Não é essa a dificuldade") { aplicar(o) { try $0.avaliarHipotese(h.id, estado: .contestada) } }
                            }.disabled(!o.salvo)
                        }
                    }.padding(.top, 8)
                }
            }
        }
    }

    private func historico(_ o: OficinaTrabalho) -> some View {
        DisclosureGroup("Histórico de versões (\(o.documento.artefatos.count))") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(o.documento.artefatos.reversed()) { a in
                    DisclosureGroup("Versão \(numero(a.id, em: o.documento)) · \(a.produtor)") {
                        ConteudoTrabalhoView(fonte: a.conteudo)
                            .id(a.id)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                    }
                }
            }.padding(.top, 8)
        }
    }

    private func titulo(_ texto: String) -> some View {
        Text(texto).font(Tema.secaoNota).accessibilityAddTraits(.isHeader)
    }

    private func campo(_ titulo: String, chave: String, padrao: String = "", exemplo: String = "Escreva aqui") -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(Tema.meta).foregroundStyle(Tema.tintaSuave)
            TextField(exemplo, text: Binding(get: { rascunhos[chave] ?? padrao },
                                           set: { definir(chave, $0) }), axis: .vertical)
                .lineLimit(2...12)
                .padding(12)
                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio))
                .accessibilityLabel(titulo)
        }
    }

    private func vazio(_ chave: String) -> Bool {
        (rascunhos[chave] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func edicaoPendente(_ o: OficinaTrabalho) -> Bool {
        (rascunhos["intencao"].map { $0 != o.documento.intencaoAtual.texto } ?? false)
        || (rascunhos["resultado"].map { $0 != o.documento.intencaoAtual.resultado } ?? false)
        || !vazio("versao")
    }

    private func numero(_ id: UUID, em d: DocumentoTrabalho) -> Int {
        (d.artefatos.firstIndex(where: { $0.id == id }) ?? 0) + 1
    }

    private func definir(_ chave: String, _ texto: String) {
        guard acesso.permitido else { revalidar(); return }
        rascunhos[chave] = texto
        UserDefaults.standard.set(rascunhos, forKey: chaveRascunho)
    }

    private func limpar(_ chaves: [String]) {
        guard acesso.permitido else { revalidar(); return }
        for chave in chaves { rascunhos.removeValue(forKey: chave) }
        if chaves.contains("versao") { editandoVersao = false }
        UserDefaults.standard.set(rascunhos, forKey: chaveRascunho)
    }

    private func aplicar(_ o: OficinaTrabalho, limpar chaves: [String] = [],
                         _ mudanca: (inout DocumentoTrabalho) throws -> Void) {
        guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
        guard o.salvo else { return }
        if o.alterar(mudanca) { limpar(chaves) }
        else if !o.salvo { limparAposCommit = chaves }
    }

    private func guardarVersao(_ o: OficinaTrabalho) {
        let texto = rascunhos["versao"] ?? ""
        aplicar(o, limpar: ["versao"]) { try $0.guardarVersaoHumana(texto) }
        if o.salvo { editandoVersao = false }
    }

    @discardableResult private func guardar(_ o: OficinaTrabalho) -> Bool {
        guard acesso.permitido, o.verificarAcesso() else { revalidar(); return false }
        guard o.guardar() else { return false }
        limpar(limparAposCommit)
        limparAposCommit = []
        return true
    }

    private func abrir() {
        guard acesso.permitido else { revalidar(); return }
        do {
            let nova = try OficinaTrabalho(trabalho: trabalho, context: context)
            rascunhos = UserDefaults.standard.dictionary(forKey: chaveRascunho) as? [String: String] ?? [:]
            recuperacao = UserDefaults.standard.string(forKey: chaveRascunho + ".recuperacao")
            oficina = nova
            exibicaoSuspensa = false
            erroDeLeitura = nil
        } catch {
            erroDeLeitura = "Não consegui abrir este trabalho. O registro foi preservado; nenhum documento vazio foi criado."
        }
    }

    private func voltar() {
        guard acesso.permitido else {
            revalidar()
            // Fechar a folha não pode destruir o candidato que o disco recusou.
            // Só preserva bytes já em memória; não modifica o agregado protegido
            // nem disponibiliza a cópia enquanto o acesso estiver revogado.
            if let oficina, !oficina.salvo, !preservarCopiaLocal(oficina) { return }
            dismiss()
            return
        }
        guard let oficina else { dismiss(); return }
        oficina.cancelar()
        guard guardar(oficina) else { return }
        dismiss()
    }

    private func preservarEReabrir(_ o: OficinaTrabalho) {
        guard acesso.permitido, o.verificarAcesso() else { revalidar(); return }
        guard preservarCopiaLocal(o) else { return }
        o.cancelar()
        limparAposCommit = []
        abrir()
    }

    private func preservarCopiaLocal(_ o: OficinaTrabalho) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let dados = try? encoder.encode(o.documento),
              let texto = String(data: dados, encoding: .utf8) else { return false }
        // A cópia nunca substitui o agregado atual. Fica acessível para recuperar
        // alterações recusadas por conflito, até remoção explícita da pessoa.
        let anterior = UserDefaults.standard.string(forKey: chaveRascunho + ".recuperacao")
        let copia = anterior.map { $0 + "\n\n--- Nova cópia de recuperação ---\n\n" + texto } ?? texto
        UserDefaults.standard.set(copia, forKey: chaveRascunho + ".recuperacao")
        return true
    }

    private func revalidar() {
        let oficinaPermitida = oficina?.verificarAcesso() ?? true
        if acesso.permitido && oficinaPermitida {
            guard scenePhase == .active else { return }
            if oficina == nil {
                abrir()
            } else if exibicaoSuspensa {
                // Conserva a mesma Oficina, inclusive documento !salvo e a
                // limpeza pendente. Não recarrega o agregado por cima dela.
                rascunhos = UserDefaults.standard.dictionary(forKey: chaveRascunho) as? [String: String] ?? [:]
                recuperacao = UserDefaults.standard.string(forKey: chaveRascunho + ".recuperacao")
                exibicaoSuspensa = false
            }
            return
        }
        // O body retira toda a superfície antes de renderizar. A Oficina fica
        // retida, sem ações permitidas, para conservar alterações não salvas.
        exibicaoSuspensa = true
        rascunhos = [:]
        recuperacao = nil
        copiaCopiada = false
        erroDeLeitura = nil
        confirmarDescarte = false
        confirmarApagarCopia = false
        Teclado.recolher()
    }
}

/// Só metadados de proteção. A observação não lê título, corpo ou campos.
struct SeloOrigemTrabalho: Equatable {
    let id: UUID
    let trancada: Bool
    let queimada: Bool
    let gesto: String?
    init(_ nota: Nota) {
        id = nota.uuid
        trancada = nota.trancada
        queimada = nota.queimada
        gesto = nota.gestoRaw
    }
}

private struct AcaoTrabalhoStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Tema.chrome)
            .foregroundStyle(Tema.ambarTinta)
            .frame(minHeight: Tema.alvo, alignment: .leading)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
