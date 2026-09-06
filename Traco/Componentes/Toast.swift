import SwiftUI

/// Aviso curto na voz do app: verdade, sem desculpa. Cápsula carvão com texto
/// branco e, quando o que falhou tem uma volta, a ação em âmbar (ADR 03e ×
/// 04a). Entra pelo `safeAreaInset` de baixo: empurra o conteúdo e NUNCA cobre
/// a barra de ações. Hoje o calendário tem o seu (`CalendarioToast`) e a
/// página e o perfil desenham outro; os três convergem aqui nas voltas por tela.
struct Toast: View {
    let texto: String
    var acao: (titulo: String, fazer: () -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            Text(texto)
                .font(CalendarioTema.meta)
                .foregroundStyle(.white)
            if let acao {
                Button(acao.titulo, action: acao.fazer)
                    .font(CalendarioTema.meta.weight(.semibold))
                    .foregroundStyle(Tema.ambar)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Tema.chipAtivo, in: Capsule())
        .sombra(Tema.Sombra.flutuante)
        .accessibilityElement(children: .combine)
    }
}

extension View {
    /// O toast no pé, acima de qualquer barra, entrando pela lei de movimento.
    func toast(_ texto: String?, acao: (titulo: String, fazer: () -> Void)? = nil,
               reduzido: Bool) -> some View {
        safeAreaInset(edge: .bottom) {
            if let texto {
                Toast(texto: texto, acao: acao)
                    .padding(.bottom, 8)
                    .transition(Tema.transicao(.move(edge: .bottom).combined(with: .opacity), reduzido: reduzido))
            }
        }
        .animation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduzido), value: texto)
    }
}

#Preview("normal") {
    Toast(texto: "Guardei o compromisso.")
        .padding()
        .background(Tema.fundo)
}

#Preview("com ação (falha com volta)") {
    Toast(texto: "Os avisos estão desligados no iPhone.", acao: ("Ajustes", {}))
        .padding()
        .background(Tema.fundo)
}

#Preview("sobre a barra") {
    Color.clear
        .background(Tema.fundo)
        .toast("Não consegui guardar agora. O texto continua aqui.", reduzido: false)
        .safeAreaInset(edge: .bottom) {
            Rectangle().fill(Tema.superficie).frame(height: Tema.barraNav)
        }
}

#Preview("AX5") {
    Toast(texto: "Guardei o compromisso.", acao: ("Ajustes", {}))
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
