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
    var aoEncadear: ((Metodo.Encadeamento) -> Void)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var nascida = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // SPEC §20: a casa não tem chrome. Palavra é escrever o sentido
            // (minhas / frase / onde). Look Up é o do iOS no texto seleccionado.
            ForEach(Array(visiveis.enumerated()), id: \.element.id) { indice, campo in
                LinhaCampo(id: campo.id, rotulo: campo.nome, dica: campo.dica, teto: campo.teto, texto: valor(campo.id))
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
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("forma-\(gesto.rawValue)")
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
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .topLeading)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(preenchido ? Tema.ambar.opacity(0.5) : Tema.linha).frame(height: 0.5)
                }
                .accessibilityLabel(rotulo)
                .accessibilityIdentifier("campo-\(id)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}
