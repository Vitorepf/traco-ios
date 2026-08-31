import SwiftUI

/// Duas camadas (SPEC §20 rev.2):
///
///     [ Notas · Padrões · Perfil ]  desliza por cima de  [ ESCREVER ]
///
/// Escrever não é aba: é a casa, e fica PARADA no fundo. O arquivo entra pela
/// esquerda e sai para a esquerda. Um só elemento se move — layout determinístico:
/// as duas camadas são irmãs de tela cheia num ZStack, então nenhuma pode ser
/// proposta com largura menor que a tela.
///
/// ponytail: já tentei trilho de duas páginas (HStack deslocado) e ZStack com
/// offset nos DOIS filhos. Ambos realimentavam o layout e entregavam o arquivo
/// com ~72% da largura, deixando a escrita aparecer numa faixa à direita. Este é
/// o menor arranjo que não tem esse laço.
struct Camadas<Arquivo: View, Escrita: View>: View {
    @Binding var arquivoAberto: Bool
    var gestoAtivo: Bool
    var reduceMotion: Bool
    @ViewBuilder var arquivo: () -> Arquivo
    @ViewBuilder var escrita: () -> Escrita

    /// UMA fonte de verdade para a posição. Antes havia duas (`arrasto` +
    /// `arquivoAberto`), e soltar mudava as duas no mesmo instante: o valor
    /// final era CRAVADO em vez de perseguido, e o último quadro saltava 69px
    /// depois de um passo de 35 (g229→g230). Mola não acelera na chegada.
    @State private var pos: CGFloat = -10_000
    @State private var arrastando = false
    /// O gesto já animou `pos`: o `onChange` externo não pode re-cravar o alvo
    /// em pleno voo (dois alvos no mesmo movimento = re-aceleração na chegada).
    @State private var animandoPeloGesto = false
    @State private var largura: CGFloat = 0

    private let borda: CGFloat = 28

    var body: some View {
        ZStack {
            escrita()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // profundidade de verdade: a folha do sistema escurece o fundo
                // em 48%; a nossa escurecia 0,7% e lia como substituição
                .overlay(Color.black.opacity(0.45 * fracao).ignoresSafeArea())
                .allowsHitTesting(!arquivoAberto)
                .accessibilityHidden(arquivoAberto)

            arquivo()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: .black.opacity(0.6), radius: 18, x: 6)
                .offset(x: pos)
                .allowsHitTesting(arquivoAberto)
                .accessibilityHidden(!arquivoAberto)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            // medir POR FORA: um GeometryReader que também dimensiona os filhos
            // realimenta o layout
            GeometryReader { g in
                Color.clear
                    .onAppear {
                        largura = g.size.width
                        pos = arquivoAberto ? 0 : -g.size.width
                    }
                    .onChange(of: g.size.width) { _, nova in
                        largura = nova
                        if !arrastando { pos = arquivoAberto ? 0 : -nova }
                    }
            }
        }
        .contentShape(Rectangle())
        .gesture(gestoAtivo && largura > 0 ? trilho(largura) : nil)
        // mudança vinda de FORA do gesto (tocar numa aba, voltar por código)
        .onChange(of: arquivoAberto) { _, aberto in
            guard !arrastando, !animandoPeloGesto, largura > 0 else { return }
            withAnimation(mola(reduzido: reduceMotion)) { pos = aberto ? 0 : -largura }
        }
    }

    /// A folha do sistema pousa com passo de 0,96px; a nossa pousava com 76px.
    /// `response` maior + `dampingFraction` um pouco menor = cauda longa, que é
    /// o que faz o movimento POUSAR em vez de bater.
    /// 0 = escrevendo · 1 = arquivo à mostra. Derivado do MESMO valor animado,
    /// dentro do body — nunca por `onChange`, que não roda por quadro.
    private var fracao: CGFloat {
        guard largura > 0 else { return arquivoAberto ? 1 : 0 }
        return max(0, min(1, 1 + pos / largura))
    }

    private func mola(reduzido: Bool) -> Animation {
        reduzido ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.82)
    }

    private func trilho(_ w: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { v in
                let base: CGFloat = arquivoAberto ? 0 : -w
                if arquivoAberto {
                    // do arquivo: para a ESQUERDA, a partir da borda direita —
                    // o scroll horizontal dos chips continua sendo deles
                    guard v.startLocation.x > w - borda else { return }
                    if !arrastando { Teclado.recolher() } // o teclado sai ANTES
                    arrastando = true
                    pos = max(-w, min(0, base + min(0, v.translation.width)))
                } else {
                    // da escrita: borda esquerda, longe da seleção de texto
                    guard v.startLocation.x < borda else { return }
                    // o teclado desce ANTES do deslize: descendo JUNTO, ele muda
                    // o encaixe da camada e o conteúdo chega em dois pedaços
                    if !arrastando { Teclado.recolher() }
                    arrastando = true
                    pos = max(-w, min(0, base + max(0, v.translation.width)))
                }
            }
            .onEnded { v in
                guard arrastando else { return }
                arrastando = false
                // o destino sai da PROJEÇÃO do movimento, não da posição solta:
                // um peteleco curto e rápido vira a página (apple-design §6)
                let projetado = v.translation.width + v.predictedEndTranslation.width * 0.35
                let virar = abs(projetado) > w * 0.3
                let alvo = arquivoAberto ? !virar : virar
                let mudou = alvo != arquivoAberto
                // a posição é PERSEGUIDA pela mola; nada é cravado. O flag
                // impede que o `onChange` dispare uma SEGUNDA animação sobre a
                // mesma posição — era isso que re-acelerava na chegada.
                animandoPeloGesto = true
                withAnimation(mola(reduzido: reduceMotion)) { pos = alvo ? 0 : -w }
                if mudou { Toque.selecao() }
                Task { @MainActor in
                    // o estado vira no quadro SEGUINTE: mudá-lo junto com a
                    // animação dispara salvar + troca de árvore no mesmo
                    // instante, e isso matava a mola (a volta saía em 1 quadro)
                    try? await Task.sleep(for: .milliseconds(16))
                    if mudou { arquivoAberto = alvo }
                    try? await Task.sleep(for: .milliseconds(700))
                    animandoPeloGesto = false
                }
            }
    }
}

/// A aba do arquivo, na borda esquerda da escrita.
///
/// Auditoria de UX: o arquivo inteiro (Notas · Padrões · Perfil) dependia de o
/// autor LEMBRAR que existe uma borda arrastável, marcada por um traço cinza de
/// 3pt sobre preto. Num app cuja lei é "atrito é bug, não posso ter de lembrar
/// de nada" (§17), isso não era escolha estética — era o bug definido pela
/// própria lei. Agora é âmbar, visível, e **tocável**: o gesto continua para
/// quem já sabe, o toque existe para quem não sabe.
struct AbaArquivo: View {
    var aoTocar: () -> Void

    var body: some View {
        Button(action: aoTocar) {
            Capsule()
                .fill(Tema.ambar.opacity(0.55))
                .frame(width: 4, height: 64)
                .padding(.leading, 3)
                .padding(.vertical, 20)
                .padding(.trailing, 16)   // alvo largo sem chrome largo
                .contentShape(Rectangle())
        }
        .buttonStyle(PressaoDiscreta())
        .frame(maxHeight: .infinity, alignment: .center)
        .accessibilityIdentifier("aba-arquivo")
        .accessibilityLabel("Abrir as notas")
        .accessibilityHint("Também abre arrastando da borda esquerda")
    }
}
