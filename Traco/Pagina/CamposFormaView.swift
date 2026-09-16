import SwiftUI

/// Os campos da forma — abaixo do texto na página, ou na folha se o cartão abrir.
///
/// Auditoria 31/ago: havia um CARTÃO dentro da folha — caixa dentro de caixa.
/// O nome da forma vestia a mesma roupa dos cinco rótulos e lia como um sexto
/// campo (law-of-similarity), e o cartão estourava a altura da folha, cortando
/// o último campo. A folha JÁ é a superfície elevada: aqui dentro só existem
/// linhas, sem moldura.
struct CamposFormaView: View {
    let gesto: Gesto
    @Binding var campos: [String: String]
    /// Quando a conferência é devida (a hora do "espero" já passou). Nil = não.
    var conferenciaDevida: Bool = false
    /// ADR 04k: para onde esta forma leva. Nil = a folha não encadeia (Recordar).
    /// O campo que recebe o cursor ao nascer (a "volta" das Notas cobra um campo).
    var campoInicial: String? = nil
    var aoEncadear: ((Metodo.Encadeamento) -> Void)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var nascida = false
    @FocusState private var campoFocado: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // SPEC §20: a casa não tem chrome. Palavra é escrever o sentido
            // (minhas / frase / onde). Look Up é o do iOS no texto seleccionado.
            ForEach(Array(visiveis.enumerated()), id: \.element.id) { indice, campo in
                // a volta chega direto no campo que cobra (15/09); o contexto vem
                // junto, colado nele: o que você esperava (auditoria 16/09 noite —
                // abria rolada, sem título nem aviso)
                if conferenciaDevida, campo.soDepois, campo.id == visiveis.first(where: \.soDepois)?.id {
                    contextoDaVolta
                }
                LinhaCampo(id: campo.id, rotulo: campo.nome, dica: campo.dica, teto: campo.teto, texto: valor(campo.id), foco: $campoFocado)
                    // a forma chega como quem entra: campo a campo, um respiro
                    // entre eles (ancorado em `nascida`, que muda DEPOIS do
                    // onAppear — dispara garantido)
                    .opacity(nascida || reduceMotion ? 1 : 0)
                    .offset(y: nascida || reduceMotion ? 0 : 6)
                    .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.longa).delay(min(Double(indice), 5) * Tema.Duracao.passo), reduzido: reduceMotion), value: nascida)

            }
            depoisDisto
        }
        .padding(.horizontal, Tema.margem)
        .onAppear {
            withAnimation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.longa), reduzido: reduceMotion)) {
                nascida = true
            }
            // o foco pede a árvore montada: um tique depois do onAppear
            if let campoInicial { Task { @MainActor in campoFocado = campoInicial } }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("forma-\(gesto.rawValue)")
        // a Página esconde o pé enquanto um campo da forma é escrito
        .preference(key: CampoDaFormaEmFoco.self, value: campoFocado != nil)
    }

    /// ADR 04k — a linha DEPOIS DISTO: um botão por encadeamento, aceso quando
    /// os campos de origem têm resposta. O toque copia as palavras do autor
    /// para a próxima forma e liga as duas. A IA não escreve nada aqui.
    private func pronto(_ e: Metodo.Encadeamento) -> Bool {
        e.exige.allSatisfy { !(campos[$0] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    @ViewBuilder private var depoisDisto: some View {
        // Laço de 14/09: a porta só aparece quando o que ela exige já foi
        // respondido — uma oferta apagada, com os campos vazios, era um
        // objeto a mais dizendo "ainda não"
        let prontos = gesto.encadeamentos.filter(pronto)
        if let aoEncadear, !prontos.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Depois disto")
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.top, 8)
                ForEach(prontos) { e in
                    let pronto = true
                    Button {
                        aoEncadear(e)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: e.compromisso == nil ? "arrow.turn.down.right" : "calendar.badge.plus")
                                .font(.footnote.weight(.semibold))
                            Text(e.rotulo)
                                .font(Tema.barra)
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(pronto ? Tema.ambarTinta : Tema.tintaFraca)
                        .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.discreto)
                    .disabled(!pronto)
                    .accessibilityIdentifier("encadear-\(e.para ?? "compromisso")")
                    .accessibilityHint(pronto
                        ? "Abre a próxima forma com as suas palavras copiadas e liga as duas notas"
                        : "Responda \(e.exige.joined(separator: ", ")) primeiro")
                }
            }
            .padding(.vertical, 8)
        }
    }

    /// O campo da volta só entra quando é devido, ou quando já foi respondido.
    @ViewBuilder private var contextoDaVolta: some View {
        let esperava = (campos["espero"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        VStack(alignment: .leading, spacing: 4) {
            Label("Hora de conferir", systemImage: "clock.arrow.circlepath")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Tema.ambarTinta)
            // o "espero" está logo acima, na mesma forma: repeti-lo era eco
            let _ = esperava
        }
        .padding(.top, 18)
        .padding(.bottom, 2)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("contexto-da-volta")
    }

    private var visiveis: [CampoForma] {
        gesto.campos.filter { campo in
            guard campo.soDepois else { return true }
            let resposta = campos[campo.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return conferenciaDevida || !resposta.isEmpty
        }
    }

    private func valor(_ id: String) -> Binding<String> {
        Binding(
            get: { campos[id, default: ""] },
            set: { campos[id] = $0 }
        )
    }
}

private struct LinhaCampo: View {
    let id: String
    let rotulo: String
    var dica: String? = nil
    var teto: Int? = nil
    @Binding var texto: String
    var foco: FocusState<String?>.Binding

    private var preenchido: Bool {
        !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var estourou: Bool {
        guard let teto else { return false }
        return texto.count > teto
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                // nome de campo é conteúdo, vai em frase (ADR 10k); a caixa
                // alta gritava três vezes por forma (auditoria 13/09, defeito 17)
                Text(rotulo)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                if let teto {
                    Spacer(minLength: 8)
                    Text("\(texto.count)/\(teto)")
                        .font(Tema.label)
                        .monospacedDigit()
                        .foregroundStyle(estourou ? Tema.aviso : Tema.tintaFraca)
                        .accessibilityLabel(estourou
                            ? "\(texto.count) de \(teto), passou"
                            : "\(texto.count) de \(teto)")
                }
            }
            // Laço de simplicidade (14/09): o campo é texto no papel com um
            // fio embaixo — o mesmo idioma da busca das Notas e do `.campo`
            // do sistema. A caixa branca era a última caixa da página. O fio
            // diz que recebe texto; o âmbar do caret diz onde.
            // a dica do catálogo mora dentro do campo e some ao escrever
            TextField("", text: $texto, prompt: dica.map { Text($0).foregroundStyle(Tema.tintaFraca) }, axis: .vertical)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .textFieldStyle(.plain)
                .tint(Tema.ambar)
                .lineLimit(1...5)
                .focused(foco, equals: id)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .topLeading)
                .overlay(alignment: .bottom) {
                    // âmbar só onde o cursor está (auditoria 16/09 noite: campos
                    // respondidos em âmbar liam como "em foco")
                    Rectangle().fill(foco.wrappedValue == id ? Tema.ambar : Tema.linha)
                        .frame(height: foco.wrappedValue == id ? 1 : 0.5)
                    let _ = preenchido
                }
                .accessibilityLabel(rotulo)
                .accessibilityIdentifier("campo-\(id)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

/// Algum campo da forma está sendo escrito. Auditoria 16/09 noite: o último
/// campo crescia atrás da barra "Fale com o Traço" e o cursor sumia — com o
/// campo em foco a barra sai, como no Journal, e o papel ganha a altura dela.
struct CampoDaFormaEmFoco: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = value || nextValue() }
}
