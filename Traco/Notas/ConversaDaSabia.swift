import SwiftUI
import UIKit

// A conversa com a sábia nas Notas (dono, 16/09: "horrível… design totalmente
// quebrado, muita coisa faltando de experiência de conversas com IA").
//
// O desenho segue o que as conversas mais lapidadas concordam (Atlas das
// Notas, 16/09 — Claude, Pi, Granola, Notion AI, Perplexity): quem pergunta
// fala num balão à direita; a sábia responde sem balão e sem rótulo, em
// parágrafos com respiro; a espera é uma linha só, logo abaixo da pergunta;
// as fontes moram coladas à resposta; as ações são ícones sem rótulo.

/// A pergunta de quem escreve: balão à direita, um tom acima do papel.
struct BalaoDaPergunta: View {
    let texto: String

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 56)
            Text(texto)
                .font(.body)
                .foregroundStyle(Tema.tinta)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay { RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5) }
                .accessibilityIdentifier("pergunta-sabia-notas")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Você perguntou")
        .accessibilityIdentifier("autor-voce")
    }
}

/// O que a sábia diz: sem balão, na largura toda, um parágrafo por bloco. O
/// negrito e os links do modelo viram tipografia; o resto fica literal.
struct RespostaDaSabia: View {
    let texto: String
    var mostrarReferencia = true

    /// A linha "Referência:" que `RespostaNotas` acrescenta ao fim sai do corpo
    /// e vira nota de rodapé: ela diz de onde veio, não é o que a sábia diz.
    /// Só a linha: o que vem depois dela num bloco próprio ("Contexto parcial:
    /// …", `RespostaNotas`) é aviso para ler, e volta ao corpo.
    static func separar(_ bruto: String) -> (corpo: String, referencia: String?) {
        let texto = bruto.replacingOccurrences(of: "\r\n", with: "\n")
        guard let r = texto.range(of: "\nReferência: ", options: .backwards) else { return (texto, nil) }
        let depois = texto[r.upperBound...]
        let fim = depois.range(of: "\n\n")?.lowerBound ?? depois.endIndex
        let resto = String(depois[fim...]).trimmingCharacters(in: .whitespacesAndNewlines)
        let corpo = String(texto[..<r.lowerBound]) + (resto.isEmpty ? "" : "\n\n" + resto)
        return (corpo, String(depois[..<fim]).trimmingCharacters(in: .whitespacesAndNewlines))
    }

    static func paragrafos(_ texto: String) -> [AttributedString] {
        texto.replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { bloco in
                // só negrito e link viram tipografia; o resto fica literal — "2*3*4"
                // ou um `\(` do modelo não podem sumir na tela
                guard bloco.contains("**") || bloco.contains("](") else { return AttributedString(bloco) }
                return (try? AttributedString(markdown: bloco, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
                    ?? AttributedString(bloco)
            }
    }

    var body: some View {
        let partes = Self.separar(texto)
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(Self.paragrafos(partes.corpo).enumerated()), id: \.offset) { _, paragrafo in
                Text(paragrafo)
                    .font(.body)
                    .lineSpacing(5)
                    .foregroundStyle(Tema.tinta)
                    .tint(Tema.ambarTinta)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if mostrarReferencia, let referencia = partes.referencia, !referencia.isEmpty {
                ReferenciasDaResposta(referencia: referencia)
            }
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("resposta-sabia-notas")
    }
}

/// A espera numa linha, logo abaixo da pergunta: o que a sábia está fazendo,
/// com um brilho que atravessa as letras. O tempo só aparece quando demora.
struct PensandoDaSabia: View {
    let desde: Date
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static func frase(_ segundos: TimeInterval) -> String {
        segundos < 4 ? "Lendo suas notas" : segundos < 20 ? "Pensando" : "Ainda pensando"
    }

    var body: some View {
        // ponytail: 20 quadros por segundo só enquanto espera; com Reduzir
        // Movimento o brilho sai e a linha anda de segundo em segundo
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 20)) { ctx in
            let s = max(0, ctx.date.timeIntervalSince(desde))
            let frase = Self.frase(s) + "…"
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(frase)
                    .font(.body)
                    .foregroundStyle(Tema.tintaFraca)
                    .overlay {
                        if !reduceMotion {
                            GeometryReader { g in
                                let fase = s.truncatingRemainder(dividingBy: 1.6) / 1.6
                                LinearGradient(colors: [.clear, Tema.tinta.opacity(0.85), .clear],
                                               startPoint: .leading, endPoint: .trailing)
                                    .frame(width: g.size.width * 0.45)
                                    .offset(x: (g.size.width * 1.45) * fase - g.size.width * 0.45)
                            }
                            .mask(Text(frase).font(.body))
                            .allowsHitTesting(false)
                        }
                    }
                if s >= 15 {
                    Text(CapsulaDeEspera.tempo(desde: desde, agora: ctx.date))
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(Tema.tintaFraca)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(Espera.linha(Espera.aSabiaPensa, desde: desde, agora: ctx.date))
            .accessibilityIdentifier("sabia-notas-pensando")
        }
    }
}

/// As notas de onde a resposta veio: uma ficha fechada ("leu 3 notas suas")
/// que abre os títulos em cartões tocáveis.
struct FontesDaResposta: View {
    struct Fonte: Identifiable { var id: UUID; var titulo: String; var obra: Bool }
    let resumo: String
    let fontes: [Fonte]
    let abrir: (UUID) -> Void
    @State private var aberto = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                Toque.selecao()
                withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.curta), reduzido: reduceMotion)) { aberto.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.footnote.weight(.semibold))
                        .accessibilityHidden(true)
                    Text(resumo)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                        .rotationEffect(.degrees(aberto ? 180 : 0))
                        .accessibilityHidden(true)
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Tema.tintaSuave)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(Tema.superficieBaixa, in: Capsule())
                .contentShape(Capsule())
                .alvo()
            }
            .buttonStyle(.discreto)
            .accessibilityHint(aberto ? "Recolhe as fontes" : "Mostra de onde veio a resposta")
            .accessibilityIdentifier("fontes-sabia-notas")
            if aberto {
                VStack(spacing: 8) {
                    ForEach(fontes) { fonte in
                        Button { abrir(fonte.id) } label: {
                            HStack(spacing: 10) {
                                Image(systemName: fonte.obra ? "books.vertical" : "note.text")
                                    .font(.subheadline)
                                    .foregroundStyle(Tema.tintaFraca)
                                    .frame(width: 20)
                                // o ícone já diz que é obra: o sufixo " · obra" do título sai
                                Text(fonte.titulo.replacingOccurrences(of: " · obra", with: ""))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Tema.tinta)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Tema.tintaMorta)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay { RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Tema.linha, lineWidth: 0.5) }
                            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(PressaoClara())
                        .accessibilityHint("Abre a nota")
                        .accessibilityIdentifier("fonte-sabia-notas")
                    }
                }
                .transition(Tema.transicao(.opacity.combined(with: .move(edge: .top)), reduzido: reduceMotion))
            }
        }
    }
}

/// As ações sob a resposta: ícones de contorno, sem rótulo. «Serviu» e «não
/// serviu» continuam sendo o mesmo sinal de sempre (e nunca pesam regra).
struct AcoesDaResposta: View {
    let texto: String
    let retorno: ((Bool) -> Void)?
    /// Já avaliada nesta sessão (`ConversaNotas.avaliadas`): a marca vem daqui,
    /// e não de estado da view, para sobreviver à troca de aba.
    var avaliada = false
    @State private var copiado = false
    @State private var escolha: Bool?

    var body: some View {
        HStack(spacing: 2) {
            icone(copiado ? "checkmark" : "doc.on.doc", "Copiar a resposta", id: "copiar-sabia-notas") {
                UIPasteboard.general.string = RespostaDaSabia.separar(texto).corpo
                Toque.leve()
                copiado = true
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.6))
                    copiado = false
                }
            }
            if let retorno, escolha == nil, !avaliada {
                icone("hand.thumbsup", "Serviu", id: "serviu") { escolha = true; retorno(true) }
                icone("hand.thumbsdown", "Não serviu", id: "nao-serviu") { escolha = false; retorno(false) }
            } else if escolha != nil || avaliada {
                // Text com o glifo: a árvore de AX o lê como texto ("anotado")
                Text(Image(systemName: escolha == false ? "hand.thumbsdown.fill" : "checkmark"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(width: 36, height: 36)
                    .accessibilityLabel("anotado")
                    .accessibilityIdentifier("retorno-anotado")
            }
        }
        .padding(.leading, -8)
    }

    private func icone(_ nome: String, _ rotulo: String, id: String, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            Image(systemName: nome)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Tema.tintaFraca)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
                .alvo()
        }
        .buttonStyle(.discreto)
        .accessibilityLabel(rotulo)
        .accessibilityIdentifier(id)
    }
}

/// Quando a sábia não respondeu: a frase na tinta suave e a saída ao lado,
/// numa cápsula de vidro — sem faixa, sem vermelho.
struct FalhaDaSabia: View {
    let frase: String
    let rotulo: String
    let acao: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(frase.prefix(1).uppercased() + frase.dropFirst())
                .font(.body)
                .foregroundStyle(Tema.tintaSuave)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("sabia-notas-falhou")
            Button(rotulo, action: acao)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .padding(.horizontal, 16)
                .frame(height: 38)
                .glassEffect(.regular.interactive(), in: .capsule)
                .alvo()
                .buttonStyle(.discreto)
                .accessibilityIdentifier("repetir-sabia-notas")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A folha nova: o que se pode fazer aqui, sem menu e sem exemplo inventado.
struct AberturaDaConversa: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pergunte às suas notas")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Tema.tinta)
            Text("A sábia lê o que você escreveu e mostra de quais notas tirou a resposta.")
                .font(.body)
                .foregroundStyle(Tema.tintaSuave)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// O rodapé "Referência:" lido como objetos (auditoria 16/09 noite: três URLs
/// cruas do YouTube num parágrafo de 9 linhas). Cada regra de mestre vira uma
/// cápsula tocável — ▶ minuto · “vídeo” —; nota do autor fica como título curto.
struct ReferenciasDaResposta: View {
    let referencia: String

    struct Item: Equatable {
        var mestre: String?
        var video: String?
        var minuto: String?
        var link: URL?
        var texto: String
    }

    /// "Mestre, “Vídeo”, minuto 7:20 — https://…" (`Obra.referencia`), separados por "; ".
    static func itens(_ referencia: String) -> [Item] {
        referencia.components(separatedBy: "; ").compactMap { bruto in
            let item = bruto.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !item.isEmpty else { return nil }
            let padrao = #"^(?:(.+?), )?“(.+?)”(?:, minuto (\S+))?(?: — (https://\S+))?$"#
            guard let r = try? NSRegularExpression(pattern: padrao),
                  let m = r.firstMatch(in: item, range: NSRange(item.startIndex..., in: item)) else {
                return Item(texto: item)
            }
            func grupo(_ i: Int) -> String? {
                Range(m.range(at: i), in: item).map { String(item[$0]) }
            }
            let link = grupo(4).flatMap(Obra.link)
            return Item(mestre: grupo(1), video: grupo(2), minuto: grupo(3), link: link, texto: item)
        }
    }

    var body: some View {
        let itens = Self.itens(referencia)
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(itens.enumerated()), id: \.offset) { _, item in
                if item.minuto != nil || item.link != nil {
                    capsula(item)
                } else {
                    Text(verbatim: "De " + item.texto)
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaFraca)
                        .lineLimit(2)
                }
            }
        }
    }

    @ViewBuilder private func capsula(_ item: Item) -> some View {
        let corpo = HStack(spacing: 8) {
            Image(systemName: item.link == nil ? "quote.opening" : "play.fill")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Tema.chipAtivo, in: Circle())
                .accessibilityHidden(true)
            if let minuto = item.minuto {
                Text(verbatim: minuto)
                    .font(.footnote.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Tema.tinta)
                    .fixedSize()
            }
            Text(verbatim: [item.mestre, item.video.map { "“\($0)”" }].compactMap { $0 }.joined(separator: " · "))
                .font(.footnote)
                .foregroundStyle(Tema.tintaSuave)
                .lineLimit(1)
        }
        .padding(.leading, 5)
        .padding(.trailing, 12)
        .padding(.vertical, 5)
        .background(Tema.superficieBaixa, in: Capsule())
        if let link = item.link {
            Link(destination: link) { corpo }
                .buttonStyle(.discreto)
                .accessibilityLabel("Ouvir \(item.mestre ?? "o vídeo") no minuto \(item.minuto ?? "")")
                .accessibilityIdentifier("referencia-video")
        } else {
            corpo
        }
    }
}

/// A obra citada lida como obra (auditoria 16/09 noite: abria no editor, crua e
/// editável, e ao voltar a resposta era recolhida como se a fonte tivesse
/// mudado). As regras citadas vêm como capas; nada aqui se edita.
struct LeituraDaObra: View {
    let titulo: String
    let texto: String
    /// Os links das regras que a resposta citou; vazio mostra todas.
    let citadas: [String]
    @Environment(\.dismiss) private var dismiss

    private var vozes: [Conselho.Cartao.Voz] {
        let secoes = Obra.secoes(texto)
        let escolhidas = citadas.isEmpty ? secoes : secoes.filter { citadas.contains($0.chave) }
        return (escolhidas.isEmpty ? secoes : escolhidas).compactMap { Conselho.voz($0.texto) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(vozes.enumerated()), id: \.offset) { _, voz in
                        CartaoDoConselhoView(voz: voz, fechar: nil)
                    }
                }
                .padding(.horizontal, Tema.margem)
                .padding(.vertical, 12)
            }
            .background(Tema.fundo)
            .navigationTitle(titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .accessibilityIdentifier("fechar-obra")
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}
