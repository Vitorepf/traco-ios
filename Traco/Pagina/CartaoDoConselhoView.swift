import SwiftUI

/// ADR 2026-09-16h — a LEITURA do conselho, isolada da lógica: recebe a voz
/// pronta (`Conselho.Cartao.Voz`: regra, condição, caso, mestre, título do
/// vídeo, minuto e link, todos linhas literais da obra conferida) e só desenha.
/// Quando aparece, o «uma vez por nota» e o Fechar moram na `Sessao` e no
/// `CartaoAnaliseView`; o redesenho desta leitura é do líder (16/09).
struct CartaoDoConselhoView: View {
    let voz: Conselho.Cartao.Voz

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Conselho").rotulo(Tema.tintaFraca)
            // `verbatim`: texto de obra não é markdown nem instrução
            Text(verbatim: voz.regra)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("conselho-regra")
            if let condicao = voz.condicao {
                Text(verbatim: "Condição: " + condicao)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .fixedSize(horizontal: false, vertical: true)
            }
            let fonte = [voz.mestre, voz.video.map { "“\($0)”" }, voz.minuto].compactMap { $0 }.joined(separator: " · ")
            if let link = voz.link {
                Link(destination: link) {
                    Text(verbatim: fonte).multilineTextAlignment(.leading)
                }
                .font(Tema.meta)
                .foregroundStyle(Tema.ambarTinta)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHint("Abre o vídeo no minuto")
                .accessibilityIdentifier("conselho-video")
            } else if !fonte.isEmpty {
                Text(verbatim: fonte)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
