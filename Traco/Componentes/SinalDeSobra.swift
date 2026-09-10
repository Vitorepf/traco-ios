import SwiftUI

/// O sinal de que há mais texto abaixo, num `ScrollView` com teto.
///
/// O corte de um teto não diz nada por si: em 10/09 o cartão da sábia nas
/// Notas terminou a resposta em `"(A nota"` — parêntese aberto, frase pela
/// metade — e o autor leu aquilo como o fim do que a IA tinha a dizer
/// (`ferramentas/orca/q3c-01-cartao-com-a-sobra.png`). Nenhum teto conserta
/// isso: em `accessibility-extra-extra-extra-large` toda resposta transborda,
/// porque o que falta não é altura, é AVISO.
///
/// São duas coisas, e as duas são necessárias:
/// - o **degradê** é a dobra do papel — diz, sem palavra, que a linha
///   continua por baixo. Nasceu no `CartaoAnaliseView` (G4 da V8: "o corte
///   seco a meio glifo não dizia nada") e estava lá copiado à mão;
/// - a **palavra** diz o mesmo a quem o degradê não alcança, e é ela que a
///   suíte consegue enxergar — um degradê não entra na árvore de AX, e uma
///   afordância que nenhum teste vê volta a sumir na próxima volta.
///
/// Some sozinho quando a pessoa chega ao fim: sinal que mente uma vez não é
/// mais lido.
struct SinalDeSobra: ViewModifier {
    var cor: Color
    var identificador: String
    @State private var sobra = false

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Bool.self) { g in
                g.contentOffset.y + g.containerSize.height < g.contentSize.height - 1
            } action: { _, tem in sobra = tem }
            .overlay(alignment: .bottom) {
                if sobra {
                    Text("continua")
                        .rotulo()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        // o degradê precisa de vão para virar dobra; sem ele a
                        // palavra encosta na linha de cima e vira etiqueta
                        .padding(.top, 20)
                        // `cor.opacity(0)`, não `.clear`: `.clear` é preto
                        // transparente e a interpolação abre uma faixa cinza
                        // sobre o branco do cartão
                        .background(LinearGradient(colors: [cor.opacity(0), cor, cor],
                                                   startPoint: .top, endPoint: .bottom))
                        .allowsHitTesting(false)
                        .accessibilityIdentifier(identificador)
                }
            }
    }
}

extension View {
    /// `identificador` é o que a suíte procura para provar que a afordância
    /// existe quando o texto transborda.
    func sinalDeSobra(_ identificador: String, cor: Color = Tema.superficie) -> some View {
        modifier(SinalDeSobra(cor: cor, identificador: identificador))
    }
}

#Preview("cabe — sem sinal") {
    ScrollView { Text("Duas linhas cabem no teto.").font(Tema.corpo) }
        .frame(maxHeight: 220)
        .sinalDeSobra("sobra-preview")
        .padding()
        .background(Tema.superficie)
}

#Preview("transborda — com sinal") {
    ScrollView {
        Text(String(repeating: "A resposta continua muito além do que o teto do cartão mostra. ", count: 12))
            .font(Tema.corpo)
            .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxHeight: 220)
    .sinalDeSobra("sobra-preview")
    .padding()
    .background(Tema.superficie)
}
