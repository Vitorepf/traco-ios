import PencilKit
import SwiftUI

/// Desenhar é uma forma de colocar o que se pensa (dono, 14/09: "o Traço
/// não pode limitar o poder da mente ou da criação; desenhar também é uma
/// forma"). A folha é o papel com a caneta do sistema; "Pronto" pendura o
/// desenho na nota como imagem, pelo mesmo caminho da foto e do arquivo.
struct DesenhoView: View {
    var aoGuardar: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var desenho = PKDrawing()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancelar") { dismiss() }
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tintaSuave)
                    .alvo()
                    .accessibilityIdentifier("desenho-cancelar")
                Spacer()
                Button("Pronto") {
                    let quadro = desenho.bounds.insetBy(dx: -24, dy: -24)
                    if !desenho.strokes.isEmpty,
                       let png = desenho.image(from: quadro, scale: 2).pngData() {
                        aoGuardar(png)
                    }
                    dismiss()
                }
                .font(Tema.chrome.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .alvo()
                .accessibilityIdentifier("desenho-pronto")
            }
            .padding(.horizontal, Tema.margem)
            .padding(.top, 12)
            Tela(desenho: $desenho)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(Tema.fundo)
    }

    /// O papel de desenho do sistema, com a caixa de canetas dele.
    private struct Tela: UIViewRepresentable {
        @Binding var desenho: PKDrawing

        func makeUIView(context: Context) -> PKCanvasView {
            let tela = PKCanvasView()
            tela.drawing = desenho
            tela.backgroundColor = .clear
            tela.isOpaque = false
            tela.drawingPolicy = .anyInput
            tela.delegate = context.coordinator
            tela.tool = PKInkingTool(.pen, color: UIColor(Tema.tinta), width: 3)
            let canetas = PKToolPicker()
            canetas.setVisible(true, forFirstResponder: tela)
            canetas.addObserver(tela)
            context.coordinator.canetas = canetas
            DispatchQueue.main.async { tela.becomeFirstResponder() }
            return tela
        }

        func updateUIView(_ tela: PKCanvasView, context: Context) {}

        func makeCoordinator() -> Coordenador { Coordenador(desenho: $desenho) }

        final class Coordenador: NSObject, PKCanvasViewDelegate {
            var desenho: Binding<PKDrawing>
            var canetas: PKToolPicker?
            init(desenho: Binding<PKDrawing>) { self.desenho = desenho }
            func canvasViewDrawingDidChange(_ tela: PKCanvasView) { desenho.wrappedValue = tela.drawing }
        }
    }
}
