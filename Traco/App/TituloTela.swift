import SwiftUI

/// Um único cabeçalho para todas as telas do arquivo.
///
/// Auditoria 31/ago: "Notas" nascia em x=22/y=70 e "Meu perfil" em x=28/y=94 —
/// trocar de aba movia o título 6pt para o lado e 24pt para baixo, quebrando a
/// vertical que o olho tinha acabado de estabelecer (law-of-continuity).
/// Agora a linha é a mesma em toda tela, e a ação da tela (se houver) senta na
/// mesma baseline.
struct TituloTela<Acao: View>: View {
    let texto: String
    @ViewBuilder var acao: () -> Acao

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(texto)
                .font(Tema.tituloTela)
                .tracking(Tema.trackingTitulo)
                .foregroundStyle(Tema.tinta)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            acao()
        }
        .padding(.horizontal, Tema.margem)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

extension TituloTela where Acao == EmptyView {
    init(_ texto: String) {
        self.init(texto: texto) { EmptyView() }
    }
}
