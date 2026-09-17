import SwiftData
import SwiftUI

/// As versões de uma nota: o que estava escrito antes de cada gravação.
/// Restaurar guarda a atual como versão antes de trocar: nada se perde.
struct VersoesView: View {
    let nota: Nota
    let sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var versoes: [VersaoNota] = []
    @State private var aberta: VersaoNota?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alterações")
                        .font(.title2.weight(.bold))
                        .tracking(-0.4)
                    Text(versoes.isEmpty ? "Nenhuma ainda." : (versoes.count == 1 ? "1 versão" : "\(versoes.count) versões"))
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                }
                Spacer()
                // ADR 08p: a cápsula do sistema, não uma cópia local (V9, Componentes)
                Pilula("Pronto", forma: .acao) { dismiss() }
                    .accessibilityIdentifier("versoes-pronto")
            }

            if versoes.isEmpty {
                Text("Cada vez que você muda o texto e guarda, a alteração anterior fica aqui.")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaFraca)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(versoes) { v in
                            Button {
                                aberta = v
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(VozDoAutor.titulo(v.texto, gesto: nota.gesto, campos: v.campos).isEmpty
                                             ? "(só campos)" : VozDoAutor.titulo(v.texto, gesto: nota.gesto, campos: v.campos))
                                            .font(.callout.weight(.semibold))
                                            .lineLimit(1)
                                        Text(quando(v.data))
                                            .font(Tema.meta)
                                            .foregroundStyle(Tema.tintaSuave)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Tema.tintaFraca)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .alvo()
                            }
                            .buttonStyle(PressaoDiscreta())
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
                            }
                        }
                    }
                    .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(Tema.margem)
        .padding(.top, 8)
        .foregroundStyle(Tema.tinta)
        .background(Tema.fundo.ignoresSafeArea())
        .presentationDetents([.large]) // ADR 04u: folha de leitura nasce inteira, nunca cortada no médio
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
        .onAppear { versoes = Versoes.listar(nota.uuid) }
        .sheet(item: $aberta) { v in
            VersaoAbertaView(versao: v, nota: nota, sessao: sessao) {
                versoes = Versoes.listar(nota.uuid)
            }
        }
    }

    private func quando(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE, d 'de' MMMM 'às' HH:mm"
        return f.string(from: d).capitalizadoNoInicio
    }
}

private struct VersaoAbertaView: View {
    let versao: VersaoNota
    let nota: Nota
    let sessao: Sessao
    var aoRestaurar: () -> Void
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button("Voltar") { dismiss() }
                    .font(Tema.chrome)
                    .foregroundStyle(Tema.tintaSuave)
                Spacer()
                Pilula("Restaurar", forma: .acao) {
                    sessao.restaurar(nota, versao: versao, no: context)
                    aoRestaurar()
                    dismiss()
                }
                .accessibilityIdentifier("versao-restaurar")
            }
            ScrollView {
                Text(VozDoAutor.juntar(texto: versao.texto, campos: versao.campos))
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(Tema.margem)
        .padding(.top, 8)
        .background(Tema.fundo.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationBackground(Tema.fundo)
    }
}
