import SwiftUI

/// Rótulo de seção (SISTEMA-CLARO §3): 11 semibold, caixa alta, tracking +1,2.
/// Era o mesmo trio de modificadores copiado em 32 lugares de 14 arquivos
/// (auditoria V9). A cor muda de tela para tela: as Notas usam `tintaFraca`,
/// a ficha do calendário e o Recordar usam `tintaSuave`.
struct Rotulo: ViewModifier {
    var cor: Color = Tema.tintaFraca

    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .font(Tema.label)
            .tracking(Tema.trackingLabel)
            .foregroundStyle(cor)
    }
}

extension View {
    func rotulo(_ cor: Color = Tema.tintaFraca) -> some View { modifier(Rotulo(cor: cor)) }
}

#Preview("normal") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Pelo sentido").rotulo()
        Text("Quando").rotulo(Tema.tintaSuave)
        Text("Aviso").rotulo(Tema.aviso)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("AX5") {
    Text("O que não voltou").rotulo()
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
