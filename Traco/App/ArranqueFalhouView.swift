import SwiftUI

/// O arranque que não abriu (ADR 2026-09-08s, item 8 da fila do dono: "falhas
/// previsíveis permitem recuperação e preservam o conteúdo").
///
/// A tela responde às três perguntas de quem abre o app e não vê o caderno, na
/// ordem em que elas doem: **o que houve**, **onde está o que eu escrevi** e
/// **o que eu posso fazer agora**. Sem jargão de banco, sem culpar quem abriu,
/// e sem prometer um conserto que não existe — o Traço não tem como reparar um
/// arquivo que não conseguiu ler, e dizer que tem seria a mentira que autoriza
/// apagar depois.
///
/// A linha do meio é medida, não prometida: conta os `.md` que estão no espelho
/// AGORA. Se não houver nenhum, ela diz isso — a cópia pode nunca ter sido
/// escrita, e inventar um backup é pior que não ter um.
struct ArranqueFalhouView: View {
    let erro: String
    /// Devolve `true` quando o disco abriu na segunda tentativa.
    let tentarDeNovo: () -> Bool

    @State private var recusouDeNovo = false

    private var copiasNoEspelho: Int {
        (try? FileManager.default.contentsOfDirectory(atPath: Corpus.pastaNotas.path))?
            .filter { $0.hasSuffix(".md") }.count ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tema.entreItens) {
                Text("O Traço não abriu o seu caderno.")
                    .font(Tema.tituloTela)
                    .tracking(Tema.trackingTitulo)
                    .foregroundStyle(Tema.tinta)
                    .accessibilityAddTraits(.isHeader)

                Text("O arquivo onde as suas notas ficam neste aparelho não respondeu. Nada foi apagado: o Traço parou aqui em vez de abrir um caderno vazio por cima do seu.")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)

                Text(ondeEsta)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .accessibilityIdentifier("arranque-onde-esta")

                Button("Tentar abrir de novo") {
                    recusouDeNovo = !tentarDeNovo()
                }
                .buttonStyle(.primario(alinhamento: .leading))
                .accessibilityIdentifier("arranque-tentar")

                if recusouDeNovo {
                    Text("Tentei de novo e o caderno continuou fechado. Se o aparelho estiver sem espaço, liberar espaço e abrir o Traço outra vez é o que costuma resolver.")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.aviso)
                        .accessibilityIdentifier("arranque-recusou-de-novo")
                }

                Text(erro)
                    .font(Tema.miudo)
                    .foregroundStyle(Tema.tintaFraca)
                    .padding(.top, Tema.entreItens)
                    .accessibilityLabel("Detalhe técnico: \(erro)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Tema.margem)
            .padding(.vertical, Tema.entreSecoes)
        }
        .background(Tema.fundo.ignoresSafeArea())
        // um mundo só (ADR 2026-09-02h): a falha não estreia o modo escuro
        .preferredColorScheme(.light)
        .accessibilityIdentifier("disco-falhou")
    }

    private var ondeEsta: String {
        let n = copiasNoEspelho
        guard n > 0 else {
            return "Não encontrei cópia em Markdown no app Arquivos. O arquivo original continua neste aparelho, intacto — o Traço não o toca enquanto não conseguir lê-lo."
        }
        return n == 1
            ? "1 nota está em Markdown no app Arquivos, na pasta Traço. O arquivo original continua neste aparelho, intacto."
            : "\(n) notas estão em Markdown no app Arquivos, na pasta Traço. O arquivo original continua neste aparelho, intacto."
    }
}

#Preview("com espelho") {
    ArranqueFalhouView(erro: "SwiftDataError: could not open store") { false }
}

#Preview("recusou de novo, AX5") {
    ArranqueFalhouView(erro: "SwiftDataError: could not open store") { false }
        .environment(\.dynamicTypeSize, .accessibility5)
}
