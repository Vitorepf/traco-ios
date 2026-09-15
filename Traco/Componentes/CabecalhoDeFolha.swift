import SwiftUI

/// O cabeçalho de uma folha (ADR 04u, 05f): sair à esquerda (✕ em círculo ou
/// "voltar"), o título no meio se houver, concluir ("Pronto") à direita. Sem
/// concluir, um vão da mesma largura da saída mantém o título centrado.
/// Eram cinco desenhos em cinco arquivos (auditoria V9).
struct CabecalhoDeFolha<Titulo: View>: View {
    enum Saida { case fechar, voltar }

    var saida: Saida = .fechar
    var aoSair: () -> Void
    var concluir: (() -> Void)?
    /// Prefixo dos identificadores de acessibilidade: "<prefixo>-fechar", "-pronto".
    var prefixo: String?
    @ViewBuilder var titulo: () -> Titulo

    init(saida: Saida = .fechar, aoSair: @escaping () -> Void,
         concluir: (() -> Void)? = nil, prefixo: String? = nil,
         @ViewBuilder titulo: @escaping () -> Titulo) {
        self.saida = saida
        self.aoSair = aoSair
        self.concluir = concluir
        self.prefixo = prefixo
        self.titulo = titulo
    }

    private var larguraDaSaida: CGFloat { saida == .fechar ? Tema.alvo : 64 }

    var body: some View {
        HStack {
            sair
            Spacer()
            titulo()
            Spacer()
            if let concluir {
                Button(action: concluir) { Pilula("Pronto", forma: .acao) }
                    .frame(height: Tema.alvo)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier(prefixo.map { "\($0)-pronto" } ?? "")
            } else {
                Color.clear.frame(width: larguraDaSaida, height: Tema.alvo)
            }
        }
    }

    @ViewBuilder private var sair: some View {
        switch saida {
        case .fechar:
            Button(action: aoSair) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Tema.tinta)
                    .frame(width: CalendarioTema.controle, height: CalendarioTema.controle)
                    .background(Tema.chip, in: Circle())
                    .frame(width: Tema.alvo, height: Tema.alvo)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.discreto)
            .accessibilityLabel("Fechar")
            .accessibilityIdentifier(prefixo.map { "\($0)-fechar" } ?? "")
        case .voltar:
            // o mesmo desenho do "‹ Notas" da página: chevron tipográfico e
            // a caixa das outras saídas (Pronto, Fechar) — "voltar" em
            // minúscula era a nona palavra para sair (auditoria 15/09, 9)
            Button(action: aoSair) {
                Text("‹ Voltar").font(Tema.chrome).lineLimit(1).fixedSize()
            }
            .foregroundStyle(Tema.tinta)
            .alvo()
            .buttonStyle(.discreto)
            .accessibilityLabel("Voltar")
            .accessibilityIdentifier(prefixo.map { "\($0)-voltar" } ?? "")
        }
    }
}

extension CabecalhoDeFolha where Titulo == EmptyView {
    init(saida: Saida = .fechar, aoSair: @escaping () -> Void,
         concluir: (() -> Void)? = nil, prefixo: String? = nil) {
        self.init(saida: saida, aoSair: aoSair, concluir: concluir, prefixo: prefixo) { EmptyView() }
    }
}

#Preview("fechar e pronto") {
    CabecalhoDeFolha(aoSair: {}, concluir: {})
        .padding()
        .background(Tema.fundo)
}

#Preview("fechar com título") {
    CabecalhoDeFolha(aoSair: {}) { Pilula("Do seu iPhone", forma: .controle) }
        .padding()
        .background(Tema.fundo)
}

#Preview("voltar com rótulo") {
    CabecalhoDeFolha(saida: .voltar, aoSair: {}) { Text("Recordar").rotulo() }
        .padding()
        .background(Tema.fundo)
}

#Preview("AX5") {
    CabecalhoDeFolha(aoSair: {}, concluir: {})
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
