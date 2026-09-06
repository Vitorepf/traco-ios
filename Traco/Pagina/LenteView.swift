import SwiftUI

/// A lente sobre a página: o que se repete, o que enfraquece, o que é de
/// outro. Só aponta; a página continua do autor (regra de ferro 1).
/// Apontar (ADR k): o autor marca um trecho seu com um rótulo fechado.
struct LenteView: View {
    let texto: String
    /// Sem nota no disco (ou expressiva) não se aponta: só se lê.
    var notaUUID: UUID?
    var gesto: Gesto? = nil
    @Environment(\.dismiss) private var dismiss
    /// ADR 04i: o retrato viaja com a instigação e o contrapor.
    var retrato: String = ""
    @State private var perguntasDaSabia: [String] = []
    @State private var instigando = false
    /// ADR 04m: o que o autor não considerou. Nil = nada pedido ou nada honesto.
    @State private var contraparte: Sabia.Contraparte?
    @State private var contrapondo = false
    @State private var avaliouContraparte = false
    @State private var semConta = false
    @State private var apontados: [Apontamento] = []
    @State private var trechoNovo = ""
    @State private var recusado = false
    /// ADR 05x: a proveniência da forma, recolhida por padrão.
    @State private var deOndeVem = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var prosa: String { Caderno.prosa(de: texto) }
    /// O `NLTagger` e cinco regex sobre a nota inteira: pesado demais para o
    /// `body`, que é justamente o instante em que a folha sobe.
    @State private var lente = Lente.vazio

    var body: some View {
        let l = lente
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // o cabeçalho da casa: título nos tokens, Pronto como texto — a
                // cápsula cinza pesava mais que o título (von-restorff invertido)
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lente")
                            .font(Tema.tituloTela)
                            .tracking(Tema.trackingTitulo)
                            .foregroundStyle(Tema.tinta)
                            .accessibilityAddTraits(.isHeader)
                        // "nada a apontar" vive aqui, na linha de metadados: um
                        // parágrafo solto para dizer pouco era ruído
                        Text(resumo(l) + (l.vazia ? " · nada a apontar" : ""))
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .monospacedDigit()
                            .accessibilityIdentifier(l.vazia ? "lente-vazia" : "lente-resumo")
                    }
                    Spacer(minLength: 8)
                    Button("Pronto") { dismiss() }
                        .font(Tema.barra)
                        .foregroundStyle(Tema.tinta)
                        .alvo()
                        .buttonStyle(PressaoDiscreta())
                        .accessibilityIdentifier("lente-pronto")
                }

                // ADR 05x: a forma desta nota e de onde ela vem. Informação,
                // nunca selo: fonte, função, o que o Traço adaptou, evidência.
                if let gesto {
                    secao(gesto.nome, "a forma desta nota") {
                        if let estado = gesto.estadoDoMetodo {
                            Text(estado)
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaSuave)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .accessibilityIdentifier("metodo-ausente")
                        } else {
                            Button {
                                withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                                    deOndeVem.toggle()
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Text("De onde vem")
                                        .font(Tema.barra)
                                        .foregroundStyle(Tema.tinta)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Tema.tintaFraca)
                                        .rotationEffect(.degrees(deOndeVem ? 180 : 0))
                                        .accessibilityHidden(true)
                                }
                                .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                                .padding(.horizontal, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityIdentifier("de-onde-vem")
                            .accessibilityHint(deOndeVem ? "Recolhe" : "Fonte, função, o que o Traço adaptou e a evidência")
                            .accessibilityValue(deOndeVem ? "aberto" : "recolhido")
                            if deOndeVem {
                                LinhasDeProveniencia(gesto.metodoDef)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
                            }
                        }
                    }
                }

                if !apontados.isEmpty {
                    secao("Apontados por você", "um toque tira a marca") {
                        ForEach(apontados) { a in
                            Button {
                                if let notaUUID, Apontar.desmarcar(notaUUID, id: a.id) {
                                    apontados = Apontar.listar(notaUUID)
                                    Toque.leve()
                                }
                            } label: {
                                linha(a.trecho, nil, rotulo: a.rotulo.nome)
                            }
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityHint("Tira a marca")
                        }
                    }
                }

                if !l.vazia {
                    if !l.muletas.isEmpty {
                        secao("Muletas", "o que se diz para ganhar tempo") {
                            ForEach(l.muletas) { achado($0.termo, $0.vezes, sugerido: .muleta) }
                        }
                    }
                    if !l.frasesFeitas.isEmpty {
                        secao("Frases de outro", "quando aparecem, o pensamento parou um instante") {
                            ForEach(l.frasesFeitas, id: \.self) { achado($0, nil, sugerido: .fraseFeita) }
                        }
                    }
                    if !l.passivas.isEmpty {
                        secao("Passivas", "quem faz ficou escondido") {
                            ForEach(l.passivas, id: \.self) { achado($0, nil, sugerido: .passiva) }
                        }
                    }
                    if !l.adverbios.isEmpty {
                        secao("Advérbios", "o verbo devia bastar") {
                            ForEach(l.adverbios) { achado($0.termo, $0.vezes, sugerido: .vago) }
                        }
                    }
                    if !l.adjetivos.isEmpty {
                        secao("Adjetivos repetidos", "um é escolha; três é hábito") {
                            ForEach(l.adjetivos) { achado($0.termo, $0.vezes, sugerido: .vago) }
                        }
                    }
                }

                // ADR o: instigar — a sábia devolve perguntas, nunca respostas
                if notaUUID != nil, gesto != .expressiva {
                    secao("Instigar", "perguntas sobre o que falta — nunca respostas") {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(perguntasDaSabia, id: \.self) { q in
                                linha(q, nil, rotulo: nil)
                            }
                            if semConta {
                                Text("a sábia " + Sabia.porOndeEmPalavras + ".")
                                    .font(Tema.meta)
                                    .foregroundStyle(Tema.aviso)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                            }
                            Button {
                                instigar()
                            } label: {
                                HStack(spacing: 8) {
                                    if instigando { ProgressView().tint(Tema.tintaSuave) }
                                    Text(perguntasDaSabia.isEmpty ? "Instigar" : "Mais perguntas")
                                        .font(Tema.barra)
                                }
                                .foregroundStyle(Tema.ambarTinta)
                                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                                .padding(.horizontal, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressaoDiscreta())
                            .disabled(instigando)
                            .accessibilityIdentifier("instigar")
                        }
                    }
                }

                // ADR 04m: contrapor — a posição contrária, a opção fora da
                // lista, o exemplo de outro campo. Informação, nunca instrução.
                if notaUUID != nil, gesto != .expressiva {
                    secao("Contrapor", "o outro lado, a opção que faltou, o exemplo de outro campo") {
                        VStack(alignment: .leading, spacing: 0) {
                            if let c = contraparte {
                                if !c.contra.isEmpty { paragrafo("O OUTRO LADO", c.contra) }
                                if !c.foraDaLista.isEmpty { paragrafo("FORA DA LISTA", c.foraDaLista) }
                                if !c.outroCampo.isEmpty { paragrafo("EM OUTRO CAMPO", c.outroCampo) }
                                HStack(spacing: 14) {
                                    Button("Copiar") {
                                        UIPasteboard.general.string = [c.contra, c.foraDaLista, c.outroCampo].filter { !$0.isEmpty }.joined(separator: "\n\n")
                                        Toque.leve()
                                    }
                                    .font(Tema.barra)
                                    .foregroundStyle(Tema.ambarTinta)
                                    if !avaliouContraparte {
                                        Button("serviu") { Sinais.resposta(c.contra, forma: gesto, serviu: true); avaliouContraparte = true; Toque.leve() }
                                            .accessibilityIdentifier("serviu")
                                        Button("não serviu") { Sinais.resposta(c.contra, forma: gesto, serviu: false); avaliouContraparte = true; Toque.leve() }
                                            .accessibilityIdentifier("nao-serviu")
                                    }
                                }
                                .font(Tema.label)
                                .foregroundStyle(Tema.tintaFraca)
                                .buttonStyle(PressaoDiscreta())
                                .alvo()
                                .padding(.horizontal, 14)
                            }
                            if semConta {
                                Text("a sábia " + Sabia.porOndeEmPalavras + ".")
                                    .font(Tema.meta)
                                    .foregroundStyle(Tema.aviso)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                            }
                            Button {
                                contrapor()
                            } label: {
                                HStack(spacing: 8) {
                                    if contrapondo { ProgressView().tint(Tema.tintaSuave) }
                                    Text(contraparte == nil ? "Contrapor" : "Outro ângulo")
                                        .font(Tema.barra)
                                }
                                .foregroundStyle(Tema.ambarTinta)
                                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                                .padding(.horizontal, 14)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressaoDiscreta())
                            .disabled(contrapondo)
                            .accessibilityIdentifier("contrapor")
                            .accessibilityHint("Vai à sábia; a resposta fica aqui, nunca na nota")
                        }
                    }
                }

                if notaUUID != nil {
                    secao("Apontar um trecho", "cole ou escreva um pedaço do seu texto e diga o que ele é") {
                        VStack(spacing: 0) {
                            TextField("um trecho do texto", text: $trechoNovo, axis: .vertical)
                                .font(.callout)
                                .lineLimit(1...3)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .accessibilityIdentifier("apontar-trecho")
                            Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
                            HStack(spacing: 8) {
                                ForEach(RotuloApontar.allCases, id: \.self) { r in
                                    Button(r.nome) { marcar(trechoNovo, r) }
                                        .font(Tema.meta.weight(.medium))
                                        .foregroundStyle(trechoNovo.isEmpty ? Tema.tintaMorta : Tema.tintaSuave)
                                        .padding(.horizontal, 10)
                                        .frame(height: 30)
                                        .background(Tema.chip, in: Capsule())
                                        .disabled(trechoNovo.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            if recusado {
                                Text("esse trecho não está no seu texto.")
                                    .font(Tema.meta)
                                    .foregroundStyle(Tema.aviso)
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 10)
                            }
                        }
                    }
                }
            }
            .padding(Tema.margem)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Tema.fundo.ignoresSafeArea())
        .foregroundStyle(Tema.tinta)
        // ADR 04a, de novo: `[.medium, .large]` nascia no médio com as
        // perguntas cortadas pela borda (report do dono, 04/set). A Lente é
        // leitura; abre inteira.
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
        .onAppear { if let notaUUID { apontados = Apontar.listar(notaUUID) } }
        .task { lente = Lente.ler(prosa) }
    }

    private func instigar() {
        guard Sabia.disponivel else { semConta = true; return }
        semConta = false
        instigando = true
        let t = prosa
        let g = gesto
        let r0 = retrato
        // ADR 04j: o degrau da instigação sobe com a prática nesta forma
        let degrau = g.map { Degraus.instigar($0, sinais: Sinais.todos()) } ?? 0
        Task {
            let r = await Sabia.instigar(texto: t, gesto: g, degrau: degrau, retrato: r0)
            instigando = false
            if let r { perguntasDaSabia = r; Toque.suave() } else { Toque.aviso() }
        }
    }

    private func contrapor() {
        guard Sabia.disponivel else { semConta = true; return }
        semConta = false
        contrapondo = true
        avaliouContraparte = false
        let t = prosa
        let g = gesto
        let r0 = retrato
        Task {
            let r = await Sabia.contrapor(texto: t, gesto: g, retrato: r0)
            contrapondo = false
            if let r { contraparte = r; Toque.suave() } else { Toque.aviso() }
        }
    }

    private func paragrafo(_ rotulo: String, _ texto: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rotulo)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
            Text(texto)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .accessibilityIdentifier("contraparte")
    }

    private func marcar(_ trecho: String, _ rotulo: RotuloApontar) {
        guard let notaUUID else { return }
        if Apontar.marcar(notaUUID, trecho: trecho, rotulo: rotulo, noTexto: prosa) {
            apontados = Apontar.listar(notaUUID)
            trechoNovo = ""
            recusado = false
            Toque.suave()
        } else {
            recusado = true
            Toque.aviso()
        }
    }

    private func resumo(_ l: Lente) -> String {
        let p = l.palavras == 1 ? "1 palavra" : "\(l.palavras) palavras"
        let f = l.frases == 1 ? "1 frase" : "\(l.frases) frases"
        return "\(p) · \(f)"
    }

    private func secao<C: View>(_ titulo: String, _ nota: String, @ViewBuilder _ conteudo: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo.uppercased())
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                Text(nota)
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
            }
            .padding(.leading, 4)
            VStack(spacing: 0) {
                conteudo()
            }
            .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    /// Um achado da lente. Com nota no disco, o toque abre os rótulos para
    /// apontar: é o autor quem decide o que aquilo é.
    @ViewBuilder
    private func achado(_ termo: String, _ vezes: Int?, sugerido: RotuloApontar) -> some View {
        if notaUUID != nil {
            Menu {
                ForEach(RotuloApontar.allCases, id: \.self) { r in
                    Button(r.nome) { marcar(termo, r) }
                }
            } label: {
                linha(termo, vezes, rotulo: nil)
            }
            .accessibilityHint("Apontar este trecho com um rótulo")
        } else {
            linha(termo, vezes, rotulo: nil)
        }
    }

    private func linha(_ termo: String, _ vezes: Int?, rotulo: String?) -> some View {
        HStack(spacing: 10) {
            Text(termo)
                .font(.callout)
                .foregroundStyle(Tema.tinta)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
            if let rotulo {
                Text(rotulo.uppercased())
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Tema.chip, in: Capsule())
            }
            if let vezes {
                Text("×\(vezes)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(Tema.tintaSuave)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .alvo()
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
        }
    }
}
