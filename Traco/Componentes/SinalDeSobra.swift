import SwiftUI

/// O sinal de que há mais texto abaixo, num `ScrollView` com teto.
///
/// O corte de um teto não diz nada por si: em 10/09 o cartão da sábia nas
/// Notas terminou a resposta em `"(A nota"` — parêntese aberto, frase pela
/// metade — e o autor leu aquilo como o fim do que a IA tinha a dizer
/// (`ferramentas/orca/q3c-01-cartao-com-a-sobra.png`). O que faltava não era
/// altura, era AVISO.
///
/// O aviso é o **degradê**: a dobra do papel, que diz sem palavra que a linha
/// continua por baixo. Nasceu no `CartaoAnaliseView` (G4 da V8: "o corte seco
/// a meio glifo não dizia nada"). A ADR 09w pôs ao lado dele a palavra
/// "continua", para a suíte enxergar a afordância; o dono a viu em letra
/// grande sobre a resposta e a chamou de deplorável (DIRETRIZ §14). A palavra
/// saiu. O que a suíte enxerga agora é a PRÓPRIA dobra, que virou elemento de
/// acessibilidade com o identificador e o rótulo "continua abaixo" — a árvore
/// de AX a vê, a tela não lê letra nenhuma.
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
                    // `cor.opacity(0)`, não `.clear`: `.clear` é preto
                    // transparente e a interpolação abre uma faixa cinza
                    // sobre o branco do cartão
                    LinearGradient(colors: [cor.opacity(0), cor, cor],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 28)
                        .allowsHitTesting(false)
                        .accessibilityElement()
                        .accessibilityLabel("continua abaixo")
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
