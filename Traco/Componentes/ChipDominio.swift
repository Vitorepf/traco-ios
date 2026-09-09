import SwiftUI

/// O chip do domínio, único (ADR 05d, 05f). Palavra em tinta suave com seta na
/// lista das Notas (D1); cápsula tingida com ícone e seta na ficha do calendário. Com
/// `aoEscolher` abre o menu: os sete, "Sem domínio" e, se travado, "Devolver
/// ao app". Nada apaga num toque. Sem `aoEscolher`, só mostra.
struct ChipDominio: View {
    let atual: Dominio?
    /// Tinta do domínio, ícone e seta (a ficha); sem ela, etiqueta cinza (as Notas).
    var tingido = false
    var travado = false
    var aoEscolher: ((Dominio?) -> Void)?
    var aoDevolver: (() -> Void)?

    init(atual: Dominio?, tingido: Bool = false, travado: Bool = false,
         aoEscolher: ((Dominio?) -> Void)? = nil, aoDevolver: (() -> Void)? = nil) {
        self.atual = atual
        self.tingido = tingido
        self.travado = travado
        self.aoEscolher = aoEscolher
        self.aoDevolver = aoDevolver
    }

    var body: some View {
        if let aoEscolher {
            Menu {
                ForEach(Dominio.allCases) { d in
                    Toggle(isOn: Binding(get: { d == atual }, set: { _ in aoEscolher(d) })) {
                        Label(d.nome, systemImage: CalendarioTema.icone(de: d))
                    }
                }
                Divider()
                Button { aoEscolher(nil) } label: { Label("Sem domínio", systemImage: "circle.dashed") }
                if travado, let aoDevolver {
                    Button("Devolver ao app") { aoDevolver() }
                }
            } label: {
                // o rótulo É a cápsula: o iOS realça o retângulo do rótulo ao
                // abrir o menu (visto pelo dono, 05/set). O alvo de 44 fica no Menu.
                chip
            }
            .menuStyle(.button)
            .buttonStyle(.discreto)
            .alvo()
            .accessibilityLabel(atual.map { "Domínio: \($0.nome)" } ?? "Sem domínio")
            .accessibilityHint("Abre o menu para trocar ou tirar o domínio")
        } else {
            chip
                .accessibilityLabel(atual.map { "Domínio: \($0.nome)" } ?? "Sem domínio")
        }
    }

    @ViewBuilder private var chip: some View {
        if tingido {
            HStack(spacing: 6) {
                Image(systemName: CalendarioTema.icone(de: atual))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CalendarioTema.tinta(de: atual))
                Text(atual?.nome ?? "Domínio")
                    .font(CalendarioTema.dia)
                if aoEscolher != nil {
                    SetaDeMenu().foregroundStyle(Tema.tintaSuave)
                }
            }
            .foregroundStyle(Tema.tinta)
            .padding(.horizontal, 12)
            .frame(height: CalendarioTema.controle)
            .background(CalendarioTema.fundo(de: atual), in: Capsule())
        } else {
            // D1 (DIRETRIZ §9): nas Notas o domínio é uma PALAVRA em tinta
            // suave, com a seta pequena de quem abre um menu — não uma
            // etiqueta em caixa alta numa cápsula. É o mesmo desenho de
            // "Todas ⌄" e "Mais recentes ⌄" sob o título.
            HStack(spacing: 3) {
                Text(atual?.nome ?? "Domínio")
                if aoEscolher != nil { SetaDeMenu() }
            }
            .font(Tema.meta)
            .foregroundStyle(Tema.tintaSuave)
            .fixedSize()
        }
    }
}

#Preview("normal") {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            ChipDominio(atual: .estudo, aoEscolher: { _ in })
            ChipDominio(atual: nil, aoEscolher: { _ in })
            ChipDominio(atual: .saude, travado: true, aoEscolher: { _ in }, aoDevolver: {})
        }
        HStack {
            ChipDominio(atual: .trabalho, tingido: true, aoEscolher: { _ in })
            ChipDominio(atual: nil, tingido: true, aoEscolher: { _ in })
        }
        ChipDominio(atual: .casa, tingido: true)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("AX5") {
    HStack {
        ChipDominio(atual: .estudo, aoEscolher: { _ in })
        ChipDominio(atual: .trabalho, tingido: true, aoEscolher: { _ in })
    }
    .padding()
    .background(Tema.fundo)
    .environment(\.dynamicTypeSize, .accessibility5)
}
