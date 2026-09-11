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

/// ADR 2026-09-10i — a marca de perguntar: um "?" em âmbar-tinta na linha do
/// título, o MESMO em toda tela do arquivo. É o sinal que o Traço já tem para
/// pergunta — a linha "?" da página — posto onde não há página para escrever.
/// O toque abre a folha da conversa nas Notas com a linha "?" em branco e o
/// teclado de pé. Não é campo: só existe enquanto se pergunta.
struct MarcaDePergunta: View {
    var acao: () -> Void

    var body: some View {
        Button(action: acao) {
            // ADR 10k: tinta. Perguntar é ação, e ação se reconhece pela
            // forma e pelo lugar — o âmbar é do traço do autor e do agora
            Text("?")
                .font(Tema.corpo.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .frame(width: Tema.alvo, height: Tema.alvo)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressaoDiscreta())
        .accessibilityLabel("Perguntar às suas notas")
        .accessibilityHint("Abre a folha da pergunta; a resposta vem das suas notas")
        .accessibilityIdentifier("perguntar-modo")
    }
}
