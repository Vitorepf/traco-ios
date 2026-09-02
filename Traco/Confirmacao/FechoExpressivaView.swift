import SwiftData
import SwiftUI

/// O fecho da escrita expressiva (SPEC §8). Dois métodos validados, cada um com
/// objetivo próprio — não são variações de estilo:
///
/// **Selar** — Pennebaker. O ganho da escrita expressiva vem da construção de
/// sentido, não do desabafo; reler à toa desfaz isso. O texto fica, atrás de
/// atrito real (dupla confirmação + Face ID).
///
/// **Queimar** — Briñol e col., 2013: descartar o pensamento como objeto
/// material reduz o poder que ele tem sobre você. O texto é destruído.
///
/// Antes dos dois, UMA pergunta que é do autor: o que ficou claro. Essa linha
/// vive FORA do fecho — é ela que entra no corpus e se multiplica.
struct FechoExpressivaView: View {
    var sessao: Sessao
    let minutos: Int
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var sentido = ""
    @State private var progressoQueima: CGFloat = 0
    @FocusState private var foco: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Tema.fundo.opacity(0.6))
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(minutos >= 1 ? "\(minutos) minutos escritos." : "Escrita encerrada.")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Tema.tinta)
                            .accessibilityAddTraits(.isHeader)
                        Text(sessao.sentidosDaSerie.isEmpty
                             ? "O que ficou claro? Uma linha, se veio. É a única coisa que sai daqui."
                             : "Quatro dias. Quatro linhas. O que ficou claro neste?")
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if !sessao.sentidosDaSerie.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(sessao.sentidosDaSerie.enumerated()), id: \.offset) { i, linha in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DIA \(i + 1)")
                                        .font(Tema.label)
                                        .tracking(Tema.trackingLabel)
                                        .foregroundStyle(Tema.tintaFraca)
                                    Text(linha)
                                        .font(Tema.corpo)
                                        .foregroundStyle(Tema.tinta)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            Text("DIA \(sessao.sentidosDaSerie.count + 1)")
                                .font(Tema.label)
                                .tracking(Tema.trackingLabel)
                                .foregroundStyle(Tema.tintaFraca)
                        }
                    }

                    // um TextField `.plain` VAZIO e sem prompt é invisível: nada
                    // de moldura, nada de fundo, nada de texto. O autor lia "uma
                    // linha, se veio — é a única coisa que sai daqui" e não via
                    // onde escrevê-la; o fio de baixo lia como divisor de seção,
                    // não como linha de resposta (critique-affordance). O prompt
                    // mostra a FORMA da resposta sem sugerir o conteúdo.
                    TextField("", text: $sentido,
                              prompt: Text("uma linha").foregroundStyle(Tema.tintaFraca),
                              axis: .vertical)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .textFieldStyle(.plain)
                        .tint(Tema.ambar)
                        .lineLimit(1...4)
                        .focused($foco)
                        .frame(minHeight: Tema.alvo)
                        .accessibilityLabel("O que ficou claro")
                        .accessibilityIdentifier("campo-sentido")
                    Rectangle().fill(Tema.linha).frame(height: 0.5)

                    VStack(alignment: .leading, spacing: 18) {
                        fecho(
                            titulo: "Selar",
                            corpo: "O texto fica no aparelho e sai de tudo — busca, export, rede. Abrir de novo pede Face ID.",
                            destaque: true,
                            id: "fecho-selar"
                        ) {
                            sessao.guardarSentidoDoFecho(corte, no: context)
                        }
                        fecho(
                            titulo: "Queimar",
                            corpo: "O texto é destruído agora. Ficam a data, os minutos e a sua linha. Não tem volta.",
                            destaque: false,
                            id: "fecho-queimar"
                        ) {
                            queimar()
                        }
                    }
                }
                .padding(28)
            }
            .scrollDismissesKeyboard(.interactively)
            // a queima é o método, então ela acontece EM CENA: o fogo consome
            // a folha de baixo para cima — frente irregular, brasa, fagulhas
            // (Briñol: o ato é o que age; Queima.swift tem a cena)
            .modifier(QueimaModifier(progresso: progressoQueima))
        }
        .accessibilityIdentifier("fecho-expressiva")
    }

    private var corte: String {
        sentido.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func queimar() {
        foco = false
        let linha = corte
        guard !reduceMotion else {
            _ = sessao.queimar(no: context, sentido: linha)
            return
        }
        Task { @MainActor in
            // o teclado desce ANTES da cena: com ele de pé, o fogo nascia
            // atrás das teclas e a queima acontecia fora do palco
            try? await Task.sleep(for: .milliseconds(320))
            withAnimation(.easeIn(duration: Tema.queimaCena)) { progressoQueima = 1 }
            try? await Task.sleep(for: .seconds(Tema.queimaCena + 0.15))
            if !sessao.queimar(no: context, sentido: linha) {
                withAnimation(.easeOut(duration: 0.2)) { progressoQueima = 0 }
            }
        }
    }

    private func fecho(titulo: String, corpo: String, destaque: Bool,
                       id: String, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(Tema.barra)
                    .foregroundStyle(destaque ? Tema.ambar : Tema.tintaSuave)
                Text(corpo)
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressaoDiscreta())
        .accessibilityIdentifier(id)
        .accessibilityLabel(titulo)
        .accessibilityHint(corpo)
    }
}
