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
    /// Quando a nota nasceu: a data escrita no "espero" ("até sexta") se lê a
    /// partir dela. Nil na página nova.
    var criadaEm: Date? = nil
    var aoEncadear: ((Metodo.Encadeamento) -> Void)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var nascida = false
    /// O autor tocou "O que aconteceu" antes da hora de conferir.
    @State private var abriuODepois = false
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
                        .marco(.nenhum, topo: true, base: true)
                }
                LinhaCampo(id: campo.id, rotulo: campo.nome, dica: campo.dica, teto: campo.teto, texto: valor(campo.id), foco: $campoFocado,
                           escala: campo.id == "saldo" ? ["Aquém", "Igual", "Além"] : nil)
                    .marco(marco(de: campo), topo: campo.soDepois,
                           base: campo.soDepois ? campo.id != visiveis.last(where: \.soDepois)?.id : true)
                    // a forma chega como quem entra: campo a campo, um respiro
                    // entre eles (ancorado em `nascida`, que muda DEPOIS do
                    // onAppear — dispara garantido)
                    .opacity(nascida || reduceMotion ? 1 : 0)
                    .offset(y: nascida || reduceMotion ? 0 : 6)
                    .animation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.longa).delay(min(Double(indice), 5) * Tema.Duracao.passo), reduzido: reduceMotion), value: nascida)

                // antes da hora: o que aconteceu ainda não tem campo, tem lugar
                if campo.id == ancora?.id, !mostraODepois, let primeiro = gesto.campos.first(where: \.soDepois) {
                    aindaNaoEscrito(primeiro)
                        .marco(.porVir, topo: true, base: false)
                }
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
                        .foregroundStyle(pronto ? Tema.tinta : Tema.tintaFraca)
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

    // MARK: - A linha do antes e do depois (proposta «Nota viva», tela 5)
    //
    // O que se esperava e o que aconteceu já moram lado a lado na forma. Em vez
    // de repetir os dois num bloco novo, um fio fino e dois pontos os ligam:
    // o ponto cheio é o que foi escrito; o anel é o que ainda falta — âmbar
    // quando chegou a hora de conferir, cinza antes dela.

    /// O último campo antes dos de volta: a ponta de cima do fio.
    private var ancora: CampoForma? {
        guard let i = gesto.campos.firstIndex(where: \.soDepois), i > 0 else { return nil }
        return gesto.campos[i - 1]
    }

    private var mostraODepois: Bool {
        conferenciaDevida || abriuODepois || gesto.campos.contains {
            $0.soDepois && !(campos[$0.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func marco(de campo: CampoForma) -> Marco.Estado {
        guard campo.soDepois || campo.id == ancora?.id else { return .nenhum }
        let escrito = !(campos[campo.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if escrito { return .escrito }
        // só o próximo a escrever acende: dois anéis âmbar liam como duas cobranças
        let proximo = gesto.campos.first {
            $0.soDepois && (campos[$0.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return conferenciaDevida && campo.id == proximo?.id ? .devido : .porVir
    }

    /// "Conferir em 10 de setembro": a data que o próprio autor escreveu no
    /// "espero", lida a partir do dia em que a nota nasceu.
    private var conferirEm: Date? {
        guard gesto == .decisao else { return nil }
        return Gatilho.data(em: campos["espero"] ?? "", agora: criadaEm ?? .now)
    }

    private func aindaNaoEscrito(_ campo: CampoForma) -> some View {
        Button {
            Toque.selecao()
            withAnimation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                abriuODepois = true
            }
            Task { @MainActor in campoFocado = campo.id }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(campo.nome)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                Text(conferirEm.map { "Conferir em " + $0.formatted(.dateTime.day().month(.wide)) } ?? "Ainda não escrito")
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaFraca)
                    .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.discreto)
        .accessibilityHint("Abre o campo para escrever agora")
        .accessibilityIdentifier("ainda-nao-escrito")
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
        gesto.campos.filter { !$0.soDepois || mostraODepois }
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
    /// Resposta que é uma de poucas (auditoria 17/09: «aquém, igual ou além»
    /// era digitação livre). Um toque escreve a palavra; o campo continua
    /// aberto para o autor dizer mais.
    var escala: [String]? = nil

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
            if let escala {
                HStack(spacing: 8) {
                    ForEach(escala, id: \.self) { opcao in
                        let marcada = texto.trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased().hasPrefix(opcao.lowercased())
                        Button {
                            Toque.selecao()
                            texto = marcada ? "" : opcao
                        } label: {
                            Text(opcao)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(marcada ? .white : Tema.tinta)
                                .padding(.horizontal, 16)
                                .frame(height: 36)
                                .background(marcada ? Tema.chipAtivo : Tema.chip, in: Capsule())
                                .frame(minHeight: Tema.alvo)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.discreto)
                        .accessibilityAddTraits(marcada ? .isSelected : [])
                        .accessibilityIdentifier("escala-\(id)-\(opcao.lowercased())")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

/// O ponto no fio que liga o que se esperava ao que aconteceu.
private struct Marco: ViewModifier {
    enum Estado { case nenhum, escrito, devido, porVir }
    let estado: Estado
    /// O fio sobe até a linha de cima / desce até a de baixo.
    let topo: Bool
    let base: Bool

    /// Centro do ponto na altura do rótulo (12 de respiro + meia linha de `Tema.meta`).
    private let centro: CGFloat = 21

    func body(content: Content) -> some View {
        if estado == .nenhum && !(topo && base) {
            content
        } else {
            HStack(alignment: .top, spacing: 12) {
                ZStack(alignment: .top) {
                    // o fio passa por baixo do ponto e atravessa o vão entre as linhas
                    VStack(spacing: 0) {
                        Rectangle().fill(topo ? Tema.tintaFraca.opacity(0.3) : .clear).frame(width: 1, height: centro)
                        Rectangle().fill(base ? Tema.tintaFraca.opacity(0.3) : .clear).frame(width: 1)
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, -4)
                    }
                    ponto.padding(.top, centro - 4.5)
                }
                .frame(width: 9)
                .accessibilityHidden(true)
                content
            }
        }
    }

    @ViewBuilder private var ponto: some View {
        switch estado {
        case .escrito: Circle().fill(Tema.tinta).frame(width: 9, height: 9)
        case .devido: Circle().strokeBorder(Tema.ambar, lineWidth: 1.5).background(Circle().fill(Tema.fundo)).frame(width: 9, height: 9)
        case .porVir: Circle().strokeBorder(Tema.tintaFraca.opacity(0.6), lineWidth: 1).background(Circle().fill(Tema.fundo)).frame(width: 9, height: 9)
        case .nenhum: EmptyView()
        }
    }
}

private extension View {
    func marco(_ estado: Marco.Estado, topo: Bool, base: Bool) -> some View {
        modifier(Marco(estado: estado, topo: topo, base: base))
    }
}

/// Algum campo da forma está sendo escrito. Auditoria 16/09 noite: o último
/// campo crescia atrás da barra "Fale com o Traço" e o cursor sumia — com o
/// campo em foco a barra sai, como no Journal, e o papel ganha a altura dela.
struct CampoDaFormaEmFoco: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = value || nextValue() }
}
