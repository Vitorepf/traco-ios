import SwiftUI

/// A lente sobre a página: o que se repete, o que enfraquece, o que é de
/// outro. Só aponta; a página continua do autor (regra de ferro 1).
struct LenteView: View {
    let texto: String
    @Environment(\.dismiss) private var dismiss

    private var lente: Lente { Lente.ler(Caderno.prosa(de: texto)) }

    var body: some View {
        let l = lente
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lente")
                            .font(.title2.weight(.bold))
                            .tracking(-0.4)
                        Text(resumo(l))
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .monospacedDigit()
                    }
                    Spacer()
                    Button("Pronto") { dismiss() }
                        .font(Tema.barra)
                        .foregroundStyle(Tema.tinta)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(Tema.chip, in: Capsule())
                        .accessibilityIdentifier("lente-pronto")
                }

                if l.vazia {
                    Text("Nada a apontar.")
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                        .accessibilityIdentifier("lente-vazia")
                } else {
                    if !l.muletas.isEmpty {
                        secao("Muletas", "o que se diz para ganhar tempo") {
                            ForEach(l.muletas) { linha($0.termo, $0.vezes) }
                        }
                    }
                    if !l.frasesFeitas.isEmpty {
                        secao("Frases de outro", "quando aparecem, o pensamento parou um instante") {
                            ForEach(l.frasesFeitas, id: \.self) { linha($0, nil) }
                        }
                    }
                    if !l.passivas.isEmpty {
                        secao("Passivas", "quem faz ficou escondido") {
                            ForEach(l.passivas, id: \.self) { linha($0, nil) }
                        }
                    }
                    if !l.adverbios.isEmpty {
                        secao("Advérbios", "o verbo devia bastar") {
                            ForEach(l.adverbios) { linha($0.termo, $0.vezes) }
                        }
                    }
                    if !l.adjetivos.isEmpty {
                        secao("Adjetivos repetidos", "um é escolha; três é hábito") {
                            ForEach(l.adjetivos) { linha($0.termo, $0.vezes) }
                        }
                    }
                }
            }
            .padding(Tema.margem)
            .padding(.top, 8)
        }
        .background(Tema.fundo.ignoresSafeArea())
        .foregroundStyle(Tema.tinta)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
        .accessibilityIdentifier("lente")
    }

    private func resumo(_ l: Lente) -> String {
        let p = l.palavras == 1 ? "1 palavra" : "\(l.palavras) palavras"
        let f = l.frases == 1 ? "1 frase" : "\(l.frases) frases"
        return "\(p) · \(f)"
    }

    private func secao<C: View>(_ titulo: String, _ nota: String, @ViewBuilder _ conteudo: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo.uppercased())
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                Text(nota)
                    .font(.footnote)
                    .foregroundStyle(Tema.tintaFraca)
            }
            .padding(.leading, 4)
            VStack(spacing: 0) {
                conteudo()
            }
            .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func linha(_ termo: String, _ vezes: Int?) -> some View {
        HStack {
            Text(termo)
                .font(.callout)
                .lineLimit(2)
            Spacer()
            if let vezes {
                Text("×\(vezes)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(Tema.tintaSuave)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
        }
    }
}
