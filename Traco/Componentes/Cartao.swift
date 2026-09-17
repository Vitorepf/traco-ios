import SwiftUI

/// O cartão (SISTEMA-CLARO §1.5): raio contínuo e cor por estilo, sombra só
/// no que flutua. Vinte e nove `RoundedRectangle` em doze arquivos citavam
/// raio e cor à mão; aqui cada estilo cita o token uma vez.
struct Cartao: ViewModifier {
    enum Estilo {
        /// Sobre o papel, sem sombra: o cartão da sábia, o campo de busca.
        case papel
        /// Um degrau abaixo do papel (névoa): os campos da ficha.
        case campo
        /// O que flutua: com `sombraFlutuante`.
        case flutuante
        /// Tinta do domínio, raio 18: evento, nota com domínio.
        case tingido(Dominio?)
    }

    var estilo: Estilo
    /// Recuo interno de 14; `[]` quando o recuo já é do conteúdo.
    var recuo: Edge.Set = .all

    func body(content: Content) -> some View {
        if case .campo = estilo {
            // Laço de simplicidade (14/09) e Hermes §1: o campo deixa de ser
            // uma caixa cinza e vira o que a busca das Notas já é — texto no
            // papel com um fio de 0,5 pt embaixo. Vale para os quatro lugares
            // que o usam (ficha, Trabalho, intercâmbio, agendamento) de uma vez.
            content
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) { Rectangle().fill(Tema.linha).frame(height: 0.5) }
        } else {
            caixa(content)
        }
    }

    private func caixa(_ content: Content) -> some View {
        content
            .padding(recuo, 14)
            .background {
                forma
                    .fill(fundo)
                    .sombra(sombra)
                    // SISTEMA-CLARO §1.5: duas sombras, nenhuma dura. A segunda
                    // é a de CONTATO — sem ela o cartão paira sem tocar o papel.
                    .shadow(color: contato, radius: 2, y: 1)
            }
            // "um retângulo mais claro SEM borda lê como buraco, não como objeto
            // acima do plano" (comentário do próprio Tema, law-of-figure-ground):
            // o branco sobre o papel leva SEMPRE o fio de 0,5. Foi este fio que a
            // migração da volta 12 apagou, sem declarar, do aviso da página e dos
            // três portais do caderno (G3 da V12, M2).
            .overlay { if fio { forma.stroke(Tema.linha, lineWidth: 0.5) } }
    }

    private var forma: RoundedRectangle {
        RoundedRectangle(cornerRadius: raio, style: .continuous)
    }

    /// O que é branco sobre o papel precisa de aresta; a névoa e a tinta do
    /// domínio já se separam pela cor.
    private var fio: Bool {
        switch estilo {
        case .papel, .flutuante: true
        case .campo, .tingido: false
        }
    }

    private var contato: Color {
        if case .flutuante = estilo { return Tema.sombraContato }
        return .clear
    }

    private var fundo: Color {
        switch estilo {
        case .papel, .flutuante: Tema.superficie
        case .campo: Tema.superficieBaixa
        case .tingido(let d): CalendarioTema.fundo(de: d)
        }
    }

    private var raio: CGFloat {
        switch estilo {
        case .papel, .flutuante: Tema.raio
        case .campo: Tema.Raio.campo
        case .tingido: Tema.Raio.cartao
        }
    }

    private var sombra: Tema.Sombra {
        if case .flutuante = estilo { return .flutuante }
        return Tema.Sombra(cor: .clear, raio: 0, y: 0)
    }
}

extension View {
    func cartao(_ estilo: Cartao.Estilo, recuo: Edge.Set = .all) -> some View {
        modifier(Cartao(estilo: estilo, recuo: recuo))
    }
}

#Preview("os quatro") {
    VStack(spacing: 16) {
        Text("A Sábia, sobre a nota").frame(maxWidth: .infinity, alignment: .leading).cartao(.papel)
        Text("Quando").frame(maxWidth: .infinity, alignment: .leading).cartao(.campo)
        Text("A barra que flutua").frame(maxWidth: .infinity, alignment: .leading).cartao(.flutuante)
        Text("Dentista").foregroundStyle(CalendarioTema.tinta(de: .saude))
            .frame(maxWidth: .infinity, alignment: .leading).cartao(.tingido(.saude))
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("vazio") {
    Color.clear.frame(height: 80).cartao(.campo)
        .padding()
        .background(Tema.fundo)
}

#Preview("AX5") {
    Text("Quando").cartao(.campo)
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
