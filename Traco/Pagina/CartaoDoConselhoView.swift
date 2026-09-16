import SwiftUI

/// ADR 2026-09-16h — a LEITURA do conselho, isolada da lógica: recebe a voz
/// pronta (`Conselho.Cartao.Voz`: regra, condição, caso, mestre, título do
/// vídeo, minuto e link, todos linhas literais da obra conferida) e só desenha.
///
/// Dono, 16/09: a primeira leitura estava "uma merda, terrível" — texto cortado
/// pela folha, "Condição:" como rótulo técnico, fio âmbar na lateral, "Fechar"
/// solto. O desenho novo é uma CAPA, como os cartões de reflexão do Journal da
/// Apple (Atlas das Notas): um objeto de cor funda, inteiro, que se lê de uma
/// vez — quem disse, o que disse, quando vale, e onde ouvir.
struct CartaoDoConselhoView: View {
    let voz: Conselho.Cartao.Voz
    let fechar: () -> Void
    /// O que sobra de altura acima do pé: além disso, a regra rola dentro da capa.
    var teto: CGFloat = .infinity
    /// O título da decisão que chamou o conselho — por que ele apareceu.
    var sobre: String? = nil

    private let forma = RoundedRectangle(cornerRadius: 22, style: .continuous)

    var body: some View {
        ViewThatFits(in: .vertical) {
            conteudo
            ScrollView { conteudo }.scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxHeight: teto)
        .background {
            forma.fill(LinearGradient(colors: [Color(hex: 0x2E2D2B), Color(hex: 0x1C1C1E)],
                                      startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay { forma.strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5) }
        .clipShape(forma)
        .shadow(color: Tema.sombraFlutuante, radius: 18, y: 8)
        .accessibilityElement(children: .contain)
    }

    private var conteudo: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                // quem disse: a obra nunca é voz de quem escreve — o nome do
                // mestre abre a capa, na tinta de identidade do Traço
                Text(verbatim: (voz.mestre ?? "Conselho").uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(0.8)
                    .foregroundStyle(Color(hex: 0xD9A542))
                    .lineLimit(1)
                Spacer(minLength: 8)
                Button(action: fechar) {
                    Image(systemName: "xmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.12), in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.discreto)
                .padding(.trailing, -8)
                .accessibilityLabel("Fechar o conselho")
                .accessibilityIdentifier("fechar-conselho")
            }
            .padding(.bottom, -8)

            // `verbatim`: texto de obra não é markdown nem instrução
            Text(verbatim: voz.regra)
                .font(.title3.weight(.semibold))
                .lineSpacing(3)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("conselho-regra")

            if let condicao = voz.condicao {
                Text(verbatim: condicao.prefix(1).uppercased() + condicao.dropFirst())
                    .font(.callout)
                    .lineSpacing(2)
                    .foregroundStyle(Color.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }

            fonte
                .padding(.top, 4)

            if let sobre {
                Text(verbatim: "Sobre a sua decisão: " + sobre)
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.45))
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Onde ouvir: o vídeo no minuto, como um objeto tocável.
    @ViewBuilder private var fonte: some View {
        let titulo = voz.video.map { "“\($0)”" }
        let rotulo = [voz.minuto, titulo].compactMap { $0 }.joined(separator: " · ")
        if !rotulo.isEmpty {
            let pilula = HStack(spacing: 8) {
                Image(systemName: voz.link == nil ? "quote.opening" : "play.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: 0x1C1C1E))
                    .frame(width: 24, height: 24)
                    .background(Color.white, in: Circle())
                    .accessibilityHidden(true)
                // o minuto primeiro e inteiro: é onde ouvir; o título cabe numa linha
                if let minuto = voz.minuto {
                    Text(verbatim: minuto)
                        .font(.footnote.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .fixedSize()
                }
                if let titulo {
                    Text(verbatim: titulo)
                        .font(.footnote)
                        .foregroundStyle(Color.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .padding(.leading, 6)
            .padding(.trailing, 14)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1), in: Capsule())
            if let link = voz.link {
                Link(destination: link) { pilula }
                    .buttonStyle(.discreto)
                    .accessibilityLabel("Ouvir no vídeo: \(rotulo)")
                    .accessibilityHint("Abre o vídeo no minuto")
                    .accessibilityIdentifier("conselho-video")
            } else {
                pilula
            }
        }
    }
}

#Preview("capa do conselho") {
    CartaoDoConselhoView(voz: .init(
        regra: "Poste pelo menos uma coisa boa por semana; o único critério para passar é ter postado algo recente que não seja lixo.",
        condicao: "se seus canais primários são outbound manual, afiliados ou tráfego pago, não tire o olho do que paga as contas",
        caso: nil, mestre: "Alex Hormozi",
        video: "1.2M Followers in 6 Months… My Content Marketing Strategy REVEALED", minuto: "3:52",
        link: URL(string: "https://www.youtube.com/watch?v=abcdefghijk&t=232s")), fechar: {})
    .padding()
    .background(Tema.fundo)
}
