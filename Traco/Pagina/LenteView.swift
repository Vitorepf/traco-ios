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
    @State private var perguntasDaSabia: [String] = []
    @State private var instigando = false
    @State private var semConta = false
    @State private var apontados: [Apontamento] = []
    @State private var trechoNovo = ""
    @State private var recusado = false

    private var prosa: String { Caderno.prosa(de: texto) }
    private var lente: Lente { Lente.ler(prosa) }

    var body: some View {
        let l = lente
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lente")
                            .font(.title2.weight(.bold))
                            .tracking(-0.4)
                        Text(resumo(l))
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .monospacedDigit()
                    }
                    Spacer()
                    Button("Pronto") { dismiss() }
                        .font(Tema.barra)
                        .foregroundStyle(Tema.tinta)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(Tema.chip, in: Capsule())
                        .accessibilityIdentifier("lente-pronto")
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

                if l.vazia {
                    Text("Nada a apontar.")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("lente-vazia")
                } else {
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
                    secao("Instigar", "a sábia lê e devolve perguntas: buracos, dependências, o que falta decidir") {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(perguntasDaSabia, id: \.self) { q in
                                linha(q, nil, rotulo: nil)
                            }
                            if semConta {
                                Text("precisa da sua conta Grok, em Perfil.")
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
        .onAppear { if let notaUUID { apontados = Apontar.listar(notaUUID) } }
    }

    private func instigar() {
        guard ContaGrok.ligada else { semConta = true; return }
        semConta = false
        instigando = true
        let t = prosa
        let g = gesto
        Task {
            let r = await Sabia.instigar(texto: t, gesto: g)
            instigando = false
            if let r { perguntasDaSabia = r; Toque.suave() } else { Toque.aviso() }
        }
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
        .frame(minHeight: Tema.alvo)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
        }
    }
}
