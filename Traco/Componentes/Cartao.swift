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
        content
            .padding(recuo, 14)
            .background(fundo, in: RoundedRectangle(cornerRadius: raio, style: .continuous))
            .sombra(sombra)
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
        Text("A sábia, sobre a nota").frame(maxWidth: .infinity, alignment: .leading).cartao(.papel)
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
