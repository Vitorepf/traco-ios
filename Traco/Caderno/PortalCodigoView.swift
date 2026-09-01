import SwiftUI
import UIKit

struct PortalCodigoView: View {
    let lingua: String
    let fonte: String
    var edicao: Binding<String>?
    var foco: FocusState<Bool>.Binding?
    var aoLingua: (() -> Void)?

    private var linhas: [String] {
        let cru = edicao?.wrappedValue ?? fonte
        return cru.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }

    private var nomeLingua: String {
        SintaxeLocal.rotulo(lingua)
    }

    private var nomePapel: String {
        switch lingua.lowercased() {
        case "sh", "bash", "zsh", "shell": "terminal"
        case "tex", "latex": "fórmula"
        default: "código"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cabeca
            areaCodigo
            pe
        }
        .background(Tema.codigoFundo)
        .clipShape(RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                .strokeBorder(Tema.linha, lineWidth: 1)
        }
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(
                topLeadingRadius: Tema.raio,
                bottomLeadingRadius: Tema.raio,
                bottomTrailingRadius: 1,
                topTrailingRadius: 1,
                style: .continuous
            )
            .fill(Tema.ambarSuave)
            .frame(width: 3)
        }
        .accessibilityElement(children: edicao == nil ? .combine : .contain)
        .accessibilityLabel("Código \(nomePapel), \(nomeLingua)")
        .accessibilityHint(edicao == nil ? "Toque para escrever o código" : "Escreva o código")
        .accessibilityIdentifier("portal-codigo")
    }

    private var cabeca: some View {
        HStack(spacing: 8) {
            Button {
                aoLingua?()
            } label: {
                Text(nomeLingua.uppercased())
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tinta)
            }
            .buttonStyle(.plain)
            .disabled(aoLingua == nil)
            .accessibilityLabel("Língua, \(nomeLingua)")
            Spacer(minLength: 8)
            Text(nomePapel)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Tema.superficieAlta)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tema.linha).frame(height: 0.5)
        }
    }

    private var areaCodigo: some View {
        HStack(alignment: .top, spacing: 0) {
            gutter
            Rectangle()
                .fill(Tema.linha)
                .frame(width: 0.5)
            if let edicao {
                CampoCodigo(texto: edicao) {
                    foco?.wrappedValue = true
                }
                .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
                .padding(.leading, 10)
                .padding(.trailing, 16)
                .padding(.vertical, 8)
            } else {
                codigoPintado
            }
        }
        .background(alignment: .leading) {
            Tema.codigoGutter.frame(width: 52)
        }
    }

    private var gutter: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(Array(linhas.enumerated()), id: \.offset) { i, _ in
                Text("\(i + 1)")
                    .font(.caption.monospaced())
                    .monospacedDigit()
                    .foregroundStyle(Tema.tintaFraca)
                    .frame(minWidth: 28, minHeight: 22, alignment: .trailing)
                    .padding(.vertical, 1.5)
            }
        }
        .padding(.trailing, 10)
        .padding(.leading, 14)
        .padding(.vertical, 12)
        .frame(width: 52, alignment: .topTrailing)
        .accessibilityHidden(true)
    }

    private var codigoPintado: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(linhas.enumerated()), id: \.offset) { _, linha in
                    Text(pintada(linha))
                        .font(Tema.mono)
                        .textSelection(.enabled)
                        .padding(.vertical, 1.5)
                        .padding(.trailing, 16)
                        .padding(.leading, 10)
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        }
        // ScrollView horizontal abraça a própria altura: sem isto ele estica
        // para todo o espaço oferecido — foi esse o vão da régua e o dos filtros
        .fixedSize(horizontal: false, vertical: true)
    }

    private var pe: some View {
        HStack {
            Text(linhas.count == 1 ? "1 linha" : "\(linhas.count) linhas")
                .font(Tema.label)
                .foregroundStyle(Tema.tintaFraca)
            Spacer()
            Text("</>")
                .font(Tema.label.monospaced())
                .foregroundStyle(Tema.tintaFraca)
                .accessibilityHidden(true)
            Text(nomeLingua)
                .font(Tema.label)
                .foregroundStyle(Tema.tintaSuave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Tema.superficieAlta)
        .overlay(alignment: .top) {
            Rectangle().fill(Tema.linha).frame(height: 0.5)
        }
    }

    private func pintada(_ linha: String) -> AttributedString {
        if linha.isEmpty { return AttributedString(" ") }
        var saida = AttributedString()
        for (token, papel) in SintaxeLocal.pintar(linha, lingua: lingua) {
            var t = AttributedString(token)
            t.foregroundColor = SintaxeLocal.cor(papel)
            saida += t
        }
        return saida
    }
}

private final class VistaCodigo: UITextView {
    override func buildMenu(with builder: any UIMenuBuilder) {
        builder.remove(menu: .autoFill)
        super.buildMenu(with: builder)
    }
}

private struct CampoCodigo: UIViewRepresentable {
    @Binding var texto: String
    var aoFoco: () -> Void

    func makeUIView(context: Context) -> VistaCodigo {
        let v = VistaCodigo()
        v.delegate = context.coordinator
        v.backgroundColor = .clear
        v.textColor = UIColor(Tema.tinta)
        v.tintColor = UIColor(Tema.ambar)
        v.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        v.keyboardType = .asciiCapable
        v.autocorrectionType = .no
        v.spellCheckingType = .no
        v.smartQuotesType = .no
        v.smartDashesType = .no
        v.smartInsertDeleteType = .no
        v.autocapitalizationType = .none
        v.textContentType = UITextContentType(rawValue: "")
        v.inlinePredictionType = .no
        v.writingToolsBehavior = .none
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0
        v.accessibilityLabel = "Código"
        v.accessibilityValue = texto
        v.accessibilityIdentifier = "pagina-codigo"
        DispatchQueue.main.async { v.becomeFirstResponder() }
        return v
    }

    func updateUIView(_ uiView: VistaCodigo, context: Context) {
        if uiView.text != texto {
            uiView.text = texto
        }
    }

    func makeCoordinator() -> Coordenador {
        Coordenador(self)
    }

    final class Coordenador: NSObject, UITextViewDelegate {
        var parent: CampoCodigo
        init(_ parent: CampoCodigo) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            textView.accessibilityValue = textView.text
            parent.texto = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.aoFoco()
        }
    }
}

