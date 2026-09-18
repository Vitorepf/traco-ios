import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

// ADR 05u: os widgets LEEM `Superficie` (o snapshot do App Group) e nada mais.
// Nenhuma chave solta, nenhum domínio, nenhum reload por minuto: a linha do
// tempo já traz as transições conhecidas (meia-noite, início de cada próximo,
// horizonte) e o app recarrega os kinds afetados depois de cada escrita.
// Tipografia pelos degraus de `Tema` (D3): escala com o sistema.

/// A ponte entre o instantâneo e o `Relogio` (que é só aritmética de datas).
extension Relogio {
    static func inicios(_ leitura: SuperficieDisco.Leitura, agora: Date) -> [Date] {
        guard case .disponivel(let s) = leitura else { return [] }
        return s.proximos.filter { $0.inicio > agora }.map(\.inicio)
    }
}

struct EntradaTraco: TimelineEntry {
    let date: Date
    let leitura: SuperficieDisco.Leitura
    var relevance: TimelineEntryRelevance?

    var indisponivel: Bool { leitura == .indisponivel }
    var destaque: Superficie.Destaque? {
        guard case .disponivel(let s) = leitura else { return nil }
        return s.destaqueDeHoje(agora: date)
    }
    /// F4: o widget do Destaque também mostra o que vem — quando não há a
    /// única coisa de hoje, ele traz algo do app em vez de morrer vazio.
    var proximos: [Superficie.Proximo] {
        guard case .disponivel(let s) = leitura, !s.desatualizada(agora: date) else { return [] }
        return s.proximos.filter { $0.inicio > date }
    }
    /// Quantos compromissos do horizonte NÃO couberam no instantâneo (achado
    /// A do G4). `nil` = instantâneo anterior a esta conta: não sabe, e a face
    /// que não sabe não publica número.
    var alem: Int? {
        guard case .disponivel(let s) = leitura, !s.desatualizada(agora: date) else { return 0 }
        return s.alem()
    }
    /// Estado honesto (F2), dito só quando é verdade: passou o horizonte, a
    /// lista deixou de ser a verdade inteira.
    var velha: Bool {
        guard case .disponivel(let s) = leitura else { return false }
        return s.desatualizada(agora: date)
    }
}

struct ProvedorTraco: TimelineProvider {
    private func entrada(_ agora: Date, _ leitura: SuperficieDisco.Leitura) -> EntradaTraco {
        var e = EntradaTraco(date: agora, leitura: leitura)
        // Relevância declarada (ADR 06d): a Pilha Inteligente sobe o widget
        // quando há uma coisa por fazer, e o esquece quando ela foi feita.
        let peso: Float = if e.indisponivel { 0 }
            else if let d = e.destaque { d.feito ? 5 : 60 }
            else if e.proximos.isEmpty { 0 } else { 20 }
        e.relevance = TimelineEntryRelevance(score: peso)
        return e
    }
    func placeholder(in context: Context) -> EntradaTraco { entrada(.now, SuperficieDisco.ler()) }
    func getSnapshot(in context: Context, completion: @escaping (EntradaTraco) -> Void) {
        completion(entrada(.now, SuperficieDisco.ler()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaTraco>) -> Void) {
        let agora = Date()
        let leitura = SuperficieDisco.ler()
        let entradas = Relogio.datas(base: Superficie.transicoes(leitura, agora: agora),
                                     inicios: Relogio.inicios(leitura, agora: agora),
                                     agora: agora).map { entrada($0, leitura) }
        completion(Timeline(entries: entradas.isEmpty ? [entrada(agora, leitura)] : entradas,
                            policy: .after(Relogio.voltar(agora: agora, ultima: entradas.last?.date))))
    }
}

// MARK: - O vocabulário da casa (ADR 06d)
//
// O G0 da F4: "nenhuma cor, nenhum ícone, nenhuma hierarquia que diga Traço".
// O que o app já tem e a casa não usava: o PONTO ÂMBAR — a marca que a tela
// bloqueada carrega desde a 05u (`DestaqueVivo`, `CompromissoVivo`). Trazê-lo
// para o widget é o que faz as quatro superfícies pertencerem ao mesmo app,
// sem inventar cor nem token: `Tema.ambar`, `Tema.label`, nada mais.

/// O cabeçalho: a marca, e só ela.
///
/// A F2 gastava uma linha inteira dizendo "atualizado às HH:MM" mesmo com o
/// dado fresco; a F4 trocou isso por um selo de estado no mesmo cabeçalho — e
/// em 155 pt de largura o selo saía `TRAÇO · desatua…`, com `PRÓXIMO`
/// hifenizado no meio da marca (revisão G3, A1). A causa não é a fonte: é o
/// LUGAR. O estado é sobre o CONTEÚDO, não sobre o widget, e a faixa do topo
/// não é do conteúdo — o dono já disse que o widget não gasta linha falando de
/// si mesmo. Então o estado desceu para a linha do conteúdo (`Oferta`), onde
/// tem largura inteira e é dito por extenso; aqui ficou a marca, que nunca
/// mais disputa espaço com nada.
private struct Selo: View {
    let rotulo: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Tema.ambar)
                .frame(width: 5, height: 5)
            Text(rotulo)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
                .lineLimit(1)
                .allowsTightening(true)
                // varredura da C: "PRÓXIMO" é uma palavra só, e foi ela que
                // saiu `PRÓXI-/MO` na F4. Uma linha e encolhe inteira.
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Um atalho compacto: glifo âmbar e palavra. Antes eram duas linhas de texto
/// de largura inteira com um filete entre elas — "parece menu de sistema, não
/// widget" (G0 da F4). Aqui ocupam uma linha só, e sobra espaço para conteúdo.
private struct AtalhoTraco: View {
    let rota: String
    let rotulo: String
    let glifo: String
    var primario: Bool = false
    /// F5: a ação PRINCIPAL do quadro vazio veste a cápsula âmbar da tela
    /// bloqueada — a mesma que o autor já toca ali (`CapsulaLembrar`). É o que
    /// tira o quadro da forma de lista e lhe dá uma ação de primeira classe.
    var capsula: Bool = false
    /// A alternativa do quadro: sem glifo e sem moldura, para que a diferença
    /// entre as duas ofertas seja de FORMA, não só de cor.
    var semGlifo: Bool = false

    var body: some View {
        Link(destination: URL(string: rota)!) {
            // Achado G do G4: as ofertas empilhadas tinham passo de ~32 pt e
            // área tocável de ~16 — três destinos diferentes num polegar só.
            // O mínimo da esteira é `Tema.alvo`, e ele vale onde o toque
            // EXISTE: no pequeno o atalho é desenho (`corpo`), e quem leva o
            // toque é o widget inteiro.
            vestido.frame(minHeight: Tema.alvo)
        }
        .accessibilityLabel(rotulo)
    }

    @ViewBuilder private var vestido: some View {
        if capsula {
            corpo.capsulaViva()
        } else {
            corpo
        }
    }

    /// No pequeno o sistema só honra um destino (`widgetURL`): ali o atalho é
    /// desenho, não `Link` — quem leva o toque é o widget inteiro.
    var corpo: some View {
        HStack(spacing: 5) {
            if !semGlifo {
                Image(systemName: glifo)
                    .font(Tema.miudo.weight(.semibold))
            }
            // A3, de novo: encolher a 85% não salva "Marcar compromisso" em
            // tamanho de acessibilidade — e oferta cortada não é oferta. A
            // linha quebra; a palavra, nunca.
            Text(rotulo)
                .font(Tema.miudo.weight(.semibold))
                .lineLimit(2)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(primario ? Tema.ambarTinta : Tema.tintaSuave)
        .contentShape(Rectangle())
    }
}

/// Uma linha de compromisso: hora à esquerda, assunto no meio, sino à direita.
/// É a unidade que faltava — o médio gastava a área inteira numa frase.
private struct LinhaProximo: View {
    let proximo: Superficie.Proximo
    let agora: Date
    var primeiro: Bool = false

    private var hoje: Bool { Calendar.current.isDate(proximo.inicio, inSameDayAs: agora) }
    private var iminente: Bool {
        primeiro && proximo.inicio > agora && proximo.inicio.timeIntervalSince(agora) <= Relogio.vespera
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(proximo.diaInteiro ? "dia" : Superficie.horaCurta(proximo.inicio))
                    .font((primeiro ? Tema.meta : Tema.miudo).weight(.semibold).monospacedDigit())
                    .foregroundStyle(iminente ? Tema.ambarTinta : (primeiro ? Tema.tinta : Tema.tintaSuave))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if !hoje {
                    Text(Superficie.diaEmPalavras(proximo.inicio, agora: agora))
                        .font(Tema.label)
                        .foregroundStyle(Tema.tintaFraca)
                        .lineLimit(1)
                }
            }
            .frame(width: 46, alignment: .leading)
            Text(proximo.titulo)
                .font((primeiro ? Tema.meta : Tema.miudo).weight(primeiro ? .semibold : .medium))
                .foregroundStyle(primeiro ? Tema.tinta : Tema.tintaSuave)
                .lineLimit(1)
                // varredura da C: a agenda passou a sair em AX5 (achado D) e
                // é aqui que o assunto viraria reticências.
                .allowsTightening(true)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
            sino
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(Superficie.quando(proximo.inicio, diaInteiro: proximo.diaInteiro, agora: agora)), \(proximo.titulo)")
    }

    /// A promessa do alarme, também aqui (ADR 04a: ele tem de VER que vai ser
    /// cobrado). A soneca pedida na tela bloqueada ganha o âmbar.
    @ViewBuilder private var sino: some View {
        if let quando = proximo.lembrarEm, quando > agora {
            Label(Superficie.horaCurta(quando), systemImage: "bell.badge")
                .font(Tema.label.monospacedDigit())
                .foregroundStyle(Tema.ambarTinta)
                .labelStyle(.titleAndIcon)
        } else if let aviso = proximo.aviso, aviso > agora {
            Label(Superficie.horaCurta(aviso), systemImage: "bell.fill")
                .font(Tema.label.monospacedDigit())
                .foregroundStyle(Tema.tintaFraca)
                .labelStyle(.titleAndIcon)
        }
    }
}

/// O compromisso em BLOCO: a hora como manchete, o assunto embaixo. É o que
/// cabe em 155pt de largura — a linha de agenda (hora | assunto | sino) só
/// serve onde há largura inteira.
private struct BlocoProximo: View {
    let proximo: Superficie.Proximo
    let agora: Date
    var restantes: Restantes = .nenhum
    var grande: Bool = false

    private var iminente: Bool { proximo.inicio.timeIntervalSince(agora) <= Relogio.vespera }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !proximo.diaInteiro {
                Text(Superficie.horaCurta(proximo.inicio))
                    .font((grande ? Tema.tituloTela : Tema.corpo).weight(.semibold).monospacedDigit())
                    .tracking(Tema.trackingTitulo)
                    .foregroundStyle(iminente ? Tema.ambarTinta : Tema.tinta)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    // H, corolário: entre uma entrada e a seguinte a hora
                    // TROCA, não corta. É o movimento do sistema, não enfeite.
                    .contentTransition(.numericText())
            }
            Text(proximo.titulo)
                .font(Tema.meta.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .lineLimit(2)
                // Achado C do G4: 0,85 não chega em 155 pt e o pequeno saía
                // "Café com o Pe…" — o NOME do compromisso, que é a
                // informação. É a terceira vez desta família na volta
                // (PRÓXI-MO, Desatualiza-do, agora o nome): a face inteira
                // está no mesmo degrau dos irmãos, e a varredura fechou a
                // classe.
                .allowsTightening(true)
                .minimumScaleFactor(0.6)
                .padding(.top, proximo.diaInteiro ? 0 : 1)
            if !Calendar.current.isDate(proximo.inicio, inSameDayAs: agora) {
                Text(Superficie.diaEmPalavras(proximo.inicio, agora: agora))
                    .font(Tema.miudo.weight(.medium))
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.top, 2)
            }
            // a promessa também aqui: o autor confere o alarme sem abrir o app
            // (ADR 04a — ele tem de VER que vai ser cobrado)
            if let quando = proximo.lembrarEm, quando > agora {
                Label("lembro às \(Superficie.horaCurta(quando))", systemImage: "bell.badge")
                    .font(Tema.miudo.weight(.medium))
                    .foregroundStyle(Tema.ambarTinta)
                    .padding(.top, 6)
            } else if let aviso = proximo.aviso, aviso > agora {
                Label(Superficie.horaCurta(aviso), systemImage: "bell.fill")
                    .font(Tema.miudo.weight(.medium))
                    .foregroundStyle(Tema.tintaFraca)
                    .padding(.top, 6)
            }
            if let frase = restantes.frase {
                Text(frase)
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaFraca)
                    .padding(.top, 6)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rotuloDeVoz)
    }

    /// A8: é a peça do PEQUENO, a família mais usada, e era a única das cinco
    /// sem rótulo — o VoiceOver lia hora, título e sino como três elementos
    /// soltos. Uma frase, na ordem em que o autor lê.
    private var rotuloDeVoz: String {
        var partes = [Superficie.quando(proximo.inicio, diaInteiro: proximo.diaInteiro, agora: agora),
                      proximo.titulo]
        if let quando = proximo.lembrarEm, quando > agora {
            partes.append("lembro às \(Superficie.horaCurta(quando))")
        } else if let aviso = proximo.aviso, aviso > agora {
            partes.append("aviso às \(Superficie.horaCurta(aviso))")
        }
        if let voz = restantes.emVoz { partes.append(voz) }
        return partes.joined(separator: ", ")
    }
}

/// Vazio não é widget morto (`curva-zero`): a superfície diz o estado numa
/// linha e OFERECE a próxima ação, com o alvo do widget inteiro por trás.
private struct Oferta: View {
    @Environment(\.dynamicTypeSize) private var tipo
    let estado: String
    /// `nil` quando a ação já está dita ali perto (o médio a tem no cabeçalho):
    /// oferecer "Nova nota" duas vezes na mesma face é ruído, não convite.
    var rotulo: String? = nil
    var glifo: String = "square.and.pencil"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // As duas propriedades que faltavam aqui e existem em `Velho()`
            // três telas ao lado: sem elas a palavra do estado partia ao meio.
            Text(estado)
                .font(Tema.meta.weight(.medium))
                .foregroundStyle(Tema.tintaSuave)
                .lineLimit(LinhasDoEstado.de(estado))
                .allowsTightening(true)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
            if let rotulo {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    // No tamanho de acessibilidade o glifo come 30 pt da
                    // coluna de 123 e "compromisso" deixa de caber — aí o
                    // desenho cede à palavra, nunca o contrário.
                    if !tipo.isAccessibilitySize {
                        Image(systemName: glifo).font(Tema.miudo.weight(.semibold))
                    }
                    // A oferta É a recuperação (`curva-zero`). Saía
                    // "Marcar um compro…" no pequeno (revisão G3, A3):
                    // 85% de escala não chega em 155 pt, e oferta cortada
                    // no meio não é oferta. Quebra a LINHA, nunca a palavra.
                    Text(rotulo)
                        .font(Tema.miudo.weight(.semibold))
                        .lineLimit(3)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(Tema.ambarTinta)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rotulo.map { "\(estado). \($0)" } ?? estado)
    }
}

/// O estado honesto quando há conteúdo em cima dele (R1 da revisão Re-G3).
///
/// A frase é a mesma da `Oferta` (`Desatualizado.`), no mesmo vocabulário; o
/// que muda é o degrau. Havendo Destaque posto, o miolo é do Destaque — e o
/// estado, que é do INSTANTÂNEO inteiro e não do ramo que sobrou, desce para
/// o rodapé. Nunca some: `EstadoNaFace` decide, e a lei tem teste.
private struct Velho: View {
    @Environment(\.dynamicTypeSize) private var tipo

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            // Como na `Oferta` (A3): no tamanho de acessibilidade o glifo
            // cede a coluna à palavra — a frase inteira vale mais que o desenho.
            if !tipo.isAccessibilitySize {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(Tema.label)
            }
            Text("Desatualizado.")
                .font(Tema.miudo.weight(.semibold))
                .lineLimit(1)
                .allowsTightening(true)
                // 155 pt em AX5 não cabem 14 letras: aqui a palavra ENCOLHE
                // inteira, nunca vira reticências nem hífen no meio (A1).
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
        }
        .foregroundStyle(Tema.tintaFraca)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Desatualizado. Abra o Traço para atualizar.")
    }
}

/// A linha do Destaque, com ou sem o risco do feito.
///
/// Achado F do G4: `linhaDoDestaque` declarava `.strikethrough(...)` e a tela
/// não tinha traço nenhum — o código prometia e a superfície não cumpria. O
/// culpado é a convivência do modificador com `minimumScaleFactor` na mesma
/// `Text`; como atributo de run (o caminho que a prosa do app já usa) o risco
/// aparece, e está fotografado.
///
/// Só que `Text(AttributedString)` cobra o preço inverso: ele ignora
/// `minimumScaleFactor` e `allowsTightening`, e a linha que ANTES encolhia
/// passou a terminar em reticências — o defeito que abriu esta volta, de
/// volta pela porta dos fundos (visto na tela, 06/09, no estado velho).
///
/// Então cada estado leva o caminho que serve a ele: a linha POR FAZER, que é
/// a que o autor lê o dia inteiro, continua sendo texto simples e encolhe
/// inteira; a linha FEITA, que já não é leitura e sim recibo, vira atributo e
/// ganha o traço. Nenhum dos dois defeitos sobra.
nonisolated func textoDoDestaque(_ linha: String, feito: Bool) -> Text {
    guard feito else { return Text(linha) }
    var t = AttributedString(linha)
    t.strikethroughStyle = .single
    return Text(t)
}

/// A frase do autor: trecho fiel e legível, com omissão reconhecível (ADR 08i).
///
/// A F4-F tirou o teto de linhas e deixou a frase ENCOLHER até 35% para sair
/// inteira. O G4 mediu o preço: em AX5 a frase saía no mesmo corpo de ~11 pt
/// de quem não ligou acessibilidade — tudo à volta crescia 1,4× e a única
/// coisa que era do autor, não —, e com a primeira linha de uma nota (247
/// caracteres) o pequeno desenhava onze linhas a ~7 pt e AINDA terminava em
/// reticências. Frase inteira em corpo minúsculo é pior que a cortada: a
/// cortada anuncia que há mais; a minúscula anuncia que há tudo.
///
/// Então a frase **mantém o corpo do papel** que a face escolheu (`fonte`,
/// que escala com o tamanho de texto da pessoa) e reduz a QUANTIDADE: quem
/// decide quantas linhas cabem é o layout (`ViewThatFits` prova `maximo`
/// linhas, depois `maximo - 1`… até uma), e o que não coube termina em "…" —
/// o corte da FACE, somado ao do publicador (`Superficie.Destaque.teto`), que
/// já vem na própria linha. Nenhum dos dois apaga a informação de que há mais.
///
/// `linhas` fixo é para a face que monta os candidatos por fora (o pequeno,
/// que tem o rótulo "Nova nota" a sacrificar antes de uma linha da frase —
/// `Sacrificio`).
private struct FraseDoAutor: View {
    let destaque: Superficie.Destaque
    let fonte: Font
    /// Até quantas linhas a face deixa a frase crescer; a face com outra
    /// coisa embaixo (o médio, com agenda) passa `LinhasDoDestaque`.
    var maximo: Int = Sacrificio.maximo
    /// Um número = exatamente este teto de linhas, sem provar outros.
    var linhas: Int? = nil
    /// Na tela bloqueada quem tinge é o sistema (o material apaga tinta nossa):
    /// lá a frase usa `.primary`/`.secondary`, como as outras faces de acessório.
    var acessorio: Bool = false

    var body: some View {
        if let linhas {
            presa(a: linhas)
        } else {
            ViewThatFits(in: .vertical) {
                ForEach(Sacrificio.candidatos(maximo: maximo, rotulo: false), id: \.self) { c in
                    presa(a: c.linhas)
                }
            }
        }
    }

    /// A frase presa a `n` linhas, no corpo cheio: sem `minimumScaleFactor`,
    /// de propósito — o que não cabe em n linhas termina em "…".
    private func presa(a n: Int) -> some View {
        textoDoDestaque(destaque.linha, feito: destaque.feito)
            .font(fonte)
            .foregroundStyle(acessorio
                             ? (destaque.feito ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary))
                             : AnyShapeStyle(destaque.feito ? Tema.tintaFraca : Tema.tinta))
            .allowsTightening(true)
            .lineLimit(n)
            .multilineTextAlignment(.leading)
    }
}

/// O botão do feito, com identidade (ADR 05u): marca ou desfaz — dois
/// intents, nunca um toggle. O mesmo gesto na casa e na tela bloqueada (04f).
private struct BotaoFeito<Rotulo: View>: View {
    let destaque: Superficie.Destaque
    @ViewBuilder let rotulo: () -> Rotulo

    var body: some View {
        Group {
            // Achado H do G4: sem `invalidatableContent` o dono tocava o
            // círculo e a face ficava EXATAMENTE igual até a recarga chegar —
            // o gesto de assinatura do Traço fora do app, sem eco. É o único
            // movimento com função nesta superfície, e é do sistema.
            if destaque.feito {
                Button(intent: DestaqueDesfazerIntent(nota: destaque.id, dia: destaque.dia)) {
                    rotulo().invalidatableContent()
                }
            } else {
                Button(intent: DestaqueFeitoIntent(nota: destaque.id, dia: destaque.dia)) {
                    rotulo().invalidatableContent()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(destaque.feito ? "Feito: \(destaque.emVoz)" : destaque.emVoz)
        .accessibilityHint(destaque.feito ? "Desfaz o feito" : "Marca a única coisa de hoje como feita")
    }
}


/// A agenda do médio: o MÁXIMO que cabe, e a conta do que não coube.
///
/// Achados B e D do G4. Com Destaque posto o médio mostrava `prefix(2)`, não
/// dizia "+N" nenhum e deixava uma faixa vazia no pé; em tamanho de
/// acessibilidade a agenda inteira era escondida por um `if` e sobrava 55% de
/// cartão morto — o defeito nº 5 do dono ("densidade errada") reconstituído
/// para quem mais precisa de ajuda.
///
/// Quem decide quantas linhas cabem é o LAYOUT, não um `if` escrito à mão:
/// `ViewThatFits` prova três, duas, uma — e cada candidata leva junto a conta
/// do que ela própria deixou de fora, então o número nunca descreve outra
/// lista. Não coube nem uma linha (AX5): a face ainda diz quantos vêm, porque
/// esconder informação para limpar a tela é o que o AGENTS.md proíbe.
private struct AgendaQueCabe: View {
    let proximos: [Superficie.Proximo]
    let agora: Date
    /// Quantos ficaram fora do instantâneo; `nil` = não sabe (achado A).
    let alem: Int?
    /// No widget do Próximo o filete separa as linhas entre si; no do Traço
    /// ele já separa a agenda do Destaque, e repeti-lo vira grade.
    var entreLinhas: Bool = false

    var body: some View {
        ViewThatFits(in: .vertical) {
            lista(3)
            lista(2)
            lista(1)
            soAConta
        }
    }

    private func lista(_ quantos: Int) -> some View {
        VStack(alignment: .leading, spacing: entreLinhas ? 6 : 0) {
            ForEach(Array(proximos.prefix(quantos).enumerated()), id: \.element.ocorrencia) { i, p in
                if entreLinhas, i > 0 { Rectangle().fill(Tema.linha).frame(height: 0.5) }
                LinhaProximo(proximo: p, agora: agora, primeiro: i == 0)
                    // F5: o respiro vai ENTRE as linhas, não depois da última.
                    // Os 5 pt do pé não separavam nada e custavam, no médio do
                    // Traço, quase a metade de uma linha de agenda — que é
                    // justamente a coisa que faltava caber ali.
                    .padding(.bottom, entreLinhas || i == quantos - 1 ? 0 : 5)
            }
            conta(mostrando: quantos)
        }
    }

    @ViewBuilder private func conta(mostrando: Int) -> some View {
        if let frase = Restantes.de(naFace: mostrando, publicados: proximos.count, alem: alem).frase {
            Text(frase)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaFraca)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .accessibilityLabel(Restantes.de(naFace: mostrando, publicados: proximos.count,
                                                 alem: alem).emVoz ?? "")
        }
    }

    /// Nem uma linha coube: a informação irredutível é QUANTOS vêm.
    private var soAConta: some View {
        let total = proximos.count + (alem ?? 0)
        return Text(alem == nil ? "e mais compromissos"
                    : (total == 1 ? "1 compromisso por vir" : "\(total) compromissos por vir"))
            .font(Tema.miudo.weight(.medium))
            .foregroundStyle(Tema.tintaSuave)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.6)
    }
}

/// O médio VAZIO como quadro de ofertas (A11 da re-G3; achado E do G4).
///
/// Quatro por dois para uma frase é o defeito nº 5 do dono voltando pela porta
/// dos fundos. O widget do Traço já tinha o quadro; o do Próximo, não — e
/// calendário vazio é o estado mais comum de todos num app de escrita. Um
/// quadro só, os dois widgets, cada um com a sua ordem de valor.
///
/// As ofertas moram no CORPO, não no cabeçalho: assim continuam existindo em
/// tamanho de acessibilidade, onde o cabeçalho se cala e o vazio ficava mudo
/// (`curva-zero`: a recuperação não desaparece no tamanho que mais precisa
/// dela). Quantas cabem é do layout — com alvo de 44 pt (achado G) duas já
/// tomam o cartão em AX5, e a terceira continua no cabeçalho e no app.
/// **F5, achado I da revisão da F4: "o quadro lê como lista de Ajustes".**
///
/// E lia. A causa não era a cor nem a fonte: era a FORMA. Duas linhas de
/// largura inteira, do mesmo peso, com glifo à esquerda e o mesmo passo
/// vertical, empilhadas e esticadas para dividir o cartão em fatias iguais —
/// isso É uma lista de sistema, seja qual for a tinta. E uma lista não tem
/// ação principal: as duas ofertas pediam a mesma coisa ao mesmo tempo.
///
/// Aqui o quadro deixa de ser lista e vira **frase de estado + uma ação, com
/// uma alternativa ao lado**: a primeira em cápsula âmbar — a mesma cápsula
/// que o autor já toca na tela bloqueada (`CapsulaLembrar`), que é a
/// assinatura da casa fora do app —, a segunda em texto discreto, sem glifo,
/// no fim da mesma linha. Uma linha de ações, não uma pilha de linhas iguais;
/// hierarquia por forma e peso, não por ordem (`von-restorff`).
///
/// Em tamanho de acessibilidade a linha não cabe: aí fica só a cápsula, que é
/// a ação de maior valor da face. A alternativa continua no app.
private struct QuadroVazio: View {
    let estado: String
    /// Em ordem de valor; a primeira é a primária.
    let ofertas: [(rota: String, rotulo: String, glifo: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(estado)
                .font(Tema.meta.weight(.medium))
                .foregroundStyle(Tema.tintaSuave)
                .lineLimit(LinhasDoEstado.de(estado, teto: 2))
                .allowsTightening(true)
                .minimumScaleFactor(Encolhe.rotulo)
                .fixedSize(horizontal: false, vertical: true)
            // Quem decide se a alternativa cabe é o LAYOUT, não um `if` de
            // tamanho de tipo escrito à mão: em AX5 a linha inteira não passa,
            // e `ViewThatFits` cai na cápsula sozinha sem inventar regra.
            ViewThatFits(in: .horizontal) {
                linha(comAlternativa: true)
                linha(comAlternativa: false)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func linha(comAlternativa: Bool) -> some View {
        HStack(spacing: 14) {
            if let o = ofertas.first {
                AtalhoTraco(rota: o.rota, rotulo: o.rotulo, glifo: o.glifo,
                            primario: true, capsula: true)
            }
            if comAlternativa, ofertas.count > 1 {
                AtalhoTraco(rota: ofertas[1].rota, rotulo: ofertas[1].rotulo,
                            glifo: ofertas[1].glifo, semGlifo: true)
            }
            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct TracoWidgetView: View {
    @Environment(\.widgetFamily) private var familia
    @Environment(\.dynamicTypeSize) private var tipo
    var entrada: EntradaTraco

    var body: some View {
        Group {
            switch familia {
            case .accessoryInline:
                // R1: uma linha só — e quando o instantâneo é velho, o que
                // ela tem a dizer é isso. Mostrar a linha de ontem como se
                // fosse a de hoje é a mentira que a volta veio matar.
                // F6 (ADR 09r), medido na bloqueada de verdade: a linha FEITA
                // saía igual à por fazer — o glifo do retângulo entra aqui
                // também; e o vazio dizia só "Traço", que não oferece nada.
                if let d = entrada.destaque, !entrada.velha {
                    Label { Text(d.linha) } icon: {
                        Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
                    }
                    .accessibilityLabel(d.feito ? "Feito: \(d.emVoz)" : d.emVoz)
                } else {
                    // Medido: ao lado da data cabem ~21 caracteres; com "Traço · "
                    // na frente a oferta saía "escolha a única c…".
                    Text(entrada.indisponivel ? "Traço · sem dados"
                         : entrada.velha ? "Traço · desatualizado"
                         : "escolha a única coisa")
                }
            case .accessoryRectangular:
                if let d = entrada.destaque {
                    // ADR 04f: na tela bloqueada o Destaque também se marca.
                    BotaoFeito(destaque: d) {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
                                .font(Tema.miudo)
                            VStack(alignment: .leading, spacing: 2) {
                                // R1: na bloqueada não sobra linha para um
                                // rodapé — então o estado ocupa a etiqueta,
                                // que é o único lugar que já era de estado.
                                // varredura da C: "DESATUALIZADO" é a mesma
                                // palavra única que saía `Desatualiza-do` na
                                // casa — na bloqueada ela também encolhe
                                // inteira em vez de cortar.
                                Text(entrada.velha ? "DESATUALIZADO" : "DESTAQUE")
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.6)
                                // F5: a mesma lei na tela bloqueada — teto de
                                // linhas corta, altura encolhe. F6, medido na
                                // bloqueada de verdade: o `ViewThatFits` escolhia
                                // UMA linha ("terminar o ca…") com metade do
                                // cartão vazia embaixo — o retângulo tem lugar
                                // para exatamente duas, e é isso que se pede.
                                FraseDoAutor(destaque: d, fonte: Tema.meta.weight(.medium),
                                             linhas: 2, acessorio: true)
                                    // Medido: o rótulo do `Button` do widget propunha
                                    // a altura de UMA linha à frase; sem isto, "…" em
                                    // 14 caracteres com metade do cartão vazia.
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .contentShape(Rectangle())
                    }
                } else if entrada.indisponivel || entrada.velha {
                    Text(entrada.indisponivel ? "Traço · sem dados" : "Traço · desatualizado")
                        .font(Tema.meta.weight(.medium))
                        .lineLimit(2)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.6)
                } else {
                    // F6: vazio que oferece (regra da F4), na forma do próprio
                    // Destaque — etiqueta e frase —, não um "Traço" solto.
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DESTAQUE")
                            .font(Tema.label)
                            .tracking(Tema.trackingLabel)
                            .foregroundStyle(.secondary)
                        Text("escolha a única coisa de hoje")
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.6)
                    }
                }
            default:
                casa
            }
        }
        .containerBackground(Tema.fundo, for: .widget)
    }

    /// Quantas linhas a única coisa de hoje pode ocupar no médio.
    private var linhasDoDestaque: Int {
        LinhasDoDestaque.noMedio(comAgenda: !entrada.proximos.isEmpty)

    }
    /// O miolo já traz a ação: repeti-la no rodapé mostrava "Nova nota" duas
    /// vezes no mesmo widget (visto no simulador, 06/09).
    private var ofertando: Bool {
        entrada.indisponivel || (entrada.destaque == nil && entrada.proximos.isEmpty)
    }
    /// R1: onde o estado honesto sai nesta face. Havendo Destaque (ou agenda),
    /// há conteúdo — e o estado vira rodapé em vez de desaparecer.
    private var estadoNaFace: EstadoNaFace {
        .de(velha: entrada.velha,
            temConteudo: !entrada.indisponivel && entrada.destaque != nil)
    }
    /// Sem Destaque, sem agenda e com o instantâneo fresco não há conteúdo
    /// nenhum: aí a face inteira vira oferta (A11, segunda metade).
    private var vazioTotal: Bool {
        !entrada.indisponivel && !entrada.velha
            && entrada.destaque == nil && entrada.proximos.isEmpty
    }

    /// A única coisa de hoje, e um toque que a fecha sem abrir o app (F2).
    /// Agora ela é o ASSUNTO do widget: 17pt, não 15, e o círculo âmbar.
    ///
    /// `linhas` fixo é do pequeno, que monta os candidatos por fora
    /// (`Sacrificio`); o médio deixa a frase provar até `LinhasDoDestaque`
    /// linhas, porque a agenda disputa o pé do cartão.
    @ViewBuilder private func linhaDoDestaque(_ d: Superficie.Destaque, linhas: Int? = nil) -> some View {
        let circulo = Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
            .font(Tema.chrome.weight(.light))
            .foregroundStyle(d.feito ? Tema.tintaFraca : Tema.ambar)
        let frase = FraseDoAutor(destaque: d, fonte: Tema.chrome.weight(.semibold),
                                 maximo: familia == .systemMedium ? linhasDoDestaque : Sacrificio.maximo,
                                 linhas: linhas)
        BotaoFeito(destaque: d) {
            Group {
                // ADR 08i: no pequeno em tamanho de acessibilidade a coluna
                // ao lado do círculo tem ~90 pt, e a 24 pt uma palavra de
                // oito letras não cabe — o SwiftUI partia "termi-/nar" em
                // sílaba. O círculo sobe uma linha e a frase fica com os 123
                // pt inteiros: menos hífen, o mesmo tanto de texto.
                if familia == .systemSmall, tipo.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 4) {
                        circulo
                        frase
                    }
                } else {
                    HStack(alignment: .top, spacing: 8) {
                        circulo
                        frase
                        Spacer(minLength: 0)
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }


    /// O pequeno com Destaque, na ordem de sacrifício da ADR 08i: o rótulo
    /// "Nova nota" — que aqui é desenho, não toque — cede antes de a frase
    /// perder uma linha; a frase cede quantidade, nunca corpo. Cada candidato
    /// é "n linhas, com ou sem o rótulo", e o layout fica com o primeiro que
    /// cabe. No estado velho o rodapé toma o lugar do rótulo (`pequeno`).
    private func destaqueQueCabe(_ d: Superficie.Destaque) -> some View {
        ViewThatFits(in: .vertical) {
            ForEach(Sacrificio.candidatos(rotulo: estadoNaFace != .rodape), id: \.self) { c in
                VStack(alignment: .leading, spacing: 4) {
                    linhaDoDestaque(d, linhas: c.linhas)
                    if c.rotulo {
                        AtalhoTraco(rota: destino.rota, rotulo: destino.rotulo,
                                    glifo: destino.glifo, primario: true).corpo
                    }
                }
            }
        }
    }

    /// O miolo do pequeno, por ordem de valor: a única coisa de hoje; sem
    /// ela, o que vem a seguir (é o mesmo instantâneo — nada de dado novo);
    /// sem nada, a oferta. Nunca um vazio de um terço de widget.
    @ViewBuilder private var miolo: some View {
        if entrada.indisponivel {
            Oferta(estado: "Não consegui ler o Traço.", rotulo: "Abrir o Traço",
                   glifo: "arrow.up.forward.app")
        } else if let d = entrada.destaque {
            linhaDoDestaque(d)
        } else if let p = entrada.proximos.first {
            // sem a única coisa de hoje, o pequeno traz o que vem — em bloco,
            // porque a LINHA de agenda (hora | assunto | sino) não cabe em 155pt
            BlocoProximo(proximo: p, agora: entrada.date,
                         restantes: .de(naFace: 1, publicados: entrada.proximos.count,
                                        alem: entrada.alem))
        } else if estadoNaFace == .miolo {
            // A1: o estado honesto por extenso, na linha do conteúdo. Passado o
            // horizonte o instantâneo é velho — e sobre um instantâneo velho o
            // widget NÃO afirma "nada em destaque hoje": ele não sabe.
            Oferta(estado: "Desatualizado.", rotulo: "Abrir o Traço",
                   glifo: "arrow.up.forward.app")
        } else {
            Oferta(estado: "Nada em destaque hoje.", rotulo: "Nova nota")
        }
    }

    /// Para onde o toque leva — e o que o rodapé promete. É o que a FACE
    /// mostra, não uma constante: quando o pequeno cai no compromisso
    /// (sem Destaque de hoje), ele exibia "16:10 Dentista" e o toque abria
    /// uma página em branco (revisão G3, A6). Um destino, uma promessa.
    private var destino: (rota: String, rotulo: String, glifo: String) {
        // Achado J do G4: com o instantâneo velho a face dizia "Abrir o Traço
        // para atualizar" e o toque abria uma PÁGINA EM BRANCO. Abrir o app é
        // o que republica; então o destino passa a ser o app, não uma nota
        // nova que ninguém pediu.
        // ADR 08i: com a frase do autor na face — e ela pode ser um trecho —
        // a promessa do toque é a CONTINUAÇÃO dela, não uma nota nova. A rota
        // é a de entidade da 05u; a tela revalida selo e acesso.
        if let d = entrada.destaque {
            return ("traco://nota/\(d.id.uuidString)", "Abrir a nota", "arrow.up.forward.app")
        }
        if entrada.velha || entrada.indisponivel {
            return ("traco://notas", "Abrir o Traço", "arrow.up.forward.app")
        }
        return entrada.destaque == nil && !entrada.proximos.isEmpty
            ? ("traco://calendario", "Calendário", "calendar")
            : ("traco://nova", "Nova nota", "square.and.pencil")
    }

    /// PEQUENO: o widget inteiro é um alvo só (`widgetURL`), então o atalho
    /// aqui é desenho — e só o primário. "Recordar" saiu da casa na F4-F (o
    /// médio perdeu o cabeçalho de atalhos) e a ADR 08i diz isso em voz alta:
    /// continua no app, na Siri e em `traco://recordar`.
    private var pequeno: some View {
        VStack(alignment: .leading, spacing: 0) {
            // F5: em tamanho de acessibilidade a marca CEDE. Ela custa quase um
            // quarto do cartão de 123 pt — e a casa já escreve "Traço" logo
            // embaixo do widget, na etiqueta do sistema. Gastar a altura do
            // autor para repetir o nome do app é a mesma falta que a F4 tirou
            // do cabeçalho ("o widget não gasta linha falando de si mesmo"),
            // um degrau acima. Onde a frase aperta, quem sai é a marca.
            if !tipo.isAccessibilitySize { Selo(rotulo: "TRAÇO") }
            // Espaçador flexível DISPUTA altura com o texto: entre dois
            // `Spacer` o miolo recebia um terço do cartão, e com o rodapé do
            // estado embaixo a linha do Destaque deixava de encolher e passava
            // a terminar em reticências (visto na tela, 06/09, no estado
            // velho — é a família da C outra vez, agora causada pelo LAYOUT e
            // não pela propriedade). Quem separa é padding; quem empurra para
            // o alto é o frame.
            Group {
                // ADR 08i: com Destaque, os candidatos (frase + rótulo) são
                // provados juntos, para que o rótulo ceda antes da frase.
                if let d = entrada.destaque { destaqueQueCabe(d) } else { miolo }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // O conteúdo tem prioridade de altura sobre o rodapé do estado:
            // sem isto o VStack reparte a altura em fatias iguais. O rodapé
            // não some — o VStack garante a lower priority o mínimo dela.
            .layoutPriority(1)
            if estadoNaFace == .rodape {
                // R1: o Destaque fica, e o rodapé conta que ele é velho —
                // o atalho cede a linha, porque a promessa da face vem antes
                // de mais um caminho para dentro do app.
                Velho()
            } else if entrada.destaque == nil, !ofertando {
                AtalhoTraco(rota: destino.rota, rotulo: destino.rotulo,
                            glifo: destino.glifo, primario: true).corpo
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: destino.rota))
    }

    /// MÉDIO: em faixas de largura inteira, não em duas colunas — a coluna
    /// estreita cortava "Dentista" em "De…" (visto no simulador, 06/09).
    /// Em cima o dia do autor (marca, atalhos, a única coisa); embaixo o que
    /// vem. O médio tinha lugar para três compromissos e usava tudo numa
    /// frase (G0 da F4, item 5).
    private var medio: some View {
        VStack(alignment: .leading, spacing: 0) {
            // F5: o cabeçalho do médio é a MARCA, e só ela.
            //
            // Os dois atalhos que moravam aqui custavam 44 pt de altura (o alvo
            // do achado G) num cartão de ~141 — e a conta é dura: com eles, a
            // `AgendaQueCabe` não achava altura nem para UMA linha e caía em
            // "3 compromissos por vir", com o dia do autor reduzido a um
            // número (visto na tela, 08/09). Três linhas de agenda e uma frase
            // de duas linhas não cabem juntas num 4×2 — isso é aritmética, não
            // escolha. O que É escolha é quem paga: a agenda, que só existe
            // AQUI, ou dois caminhos para dentro do app, que existem no ícone,
            // no controle Ditar, na Siri e no toque do pequeno.
            // Pagam os atalhos (`curva-zero`: o poder muda de lugar, não some).
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Selo(rotulo: "TRAÇO")
            }
            Group {
                if entrada.indisponivel {
                    Oferta(estado: "Não consegui ler o Traço.", rotulo: "Abrir o Traço",
                           glifo: "arrow.up.forward.app")
                } else if let d = entrada.destaque {
                    linhaDoDestaque(d)
                } else if estadoNaFace == .miolo {
                    Oferta(estado: "Desatualizado.", rotulo: "Abrir o Traço",
                           glifo: "arrow.up.forward.app")
                } else if vazioTotal {
                    quadroVazio
                }
            }
            .padding(.top, 8)
            .layoutPriority(1)
            if !entrada.proximos.isEmpty {
                // Sem `!tipo.isAccessibilitySize`: em AX5 a agenda não some,
                // encolhe para o que cabe e DIZ o resto (achados B e D). E os
                // espaçamentos aqui são fixos de propósito — `Spacer` flexível
                // disputa altura com o `ViewThatFits` e o faz escolher menos
                // do que caberia.
                // F5: 14 pt de respiro em volta do filete valiam mais como
                // linha de agenda. O filete separa; separar não custa isso.
                Rectangle().fill(Tema.linha).frame(height: 0.5)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
                AgendaQueCabe(proximos: entrada.proximos, agora: entrada.date, alem: entrada.alem)
                    // sem o frame o `ViewThatFits` recebe do VStack uma
                    // proposta de migalha e escolhe a menor candidata com o
                    // cartão vazio embaixo (visto na tela, 06/09)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            // Passada a validade a agenda está vazia por lei (`proximos`
            // devolve [] quando o instantâneo é velho), então o rodapé continua
            // sendo empurrado para o pé do cartão sem brigar com nada.
            if entrada.proximos.isEmpty, !vazioTotal { Spacer(minLength: 0) }
            if estadoNaFace == .rodape {
                // R1: com Destaque posto, o médio largava a agenda inteira e
                // não dizia nada. Agora diz — no rodapé, embaixo do conteúdo
                // que ele está pondo em dúvida, como no pequeno.
                Velho()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// O médio vazio do Traço: o quadro compartilhado, na ordem de valor
    /// desta face — escrever primeiro (`QuadroVazio` guarda o porquê).
    private var quadroVazio: some View {
        // ADR 08i: a terceira oferta ("Recordar") nunca era desenhada — o
        // quadro mostra duas. Oferta que não aparece não é oferta; saiu.
        QuadroVazio(estado: "Nada em destaque hoje.",
                    ofertas: [("traco://nova", "Nova nota", "square.and.pencil"),
                              ("traco://calendario", "Marcar compromisso", "calendar.badge.plus")])
    }

    private var casa: some View {
        Group {
            if familia == .systemMedium { medio } else { pequeno }
        }
    }
}

struct TracoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SuperficieDisco.kindDestaque, provider: ProvedorTraco()) { entrada in
            TracoWidgetView(entrada: entrada)
        }
        .configurationDisplayName("Traço")
        .description("A única coisa de hoje, o que vem a seguir e um toque para começar.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

/// O Destaque vivo: uma linha do autor, papel e tinta, enquanto o dia dura.
/// Velha (passou da meia-noite, `isStale`): a linha de ontem não fica e o
/// botão some — quem encerra é o app, ao reconciliar (ADR 05u).
struct DestaqueVivo: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DestaqueAtividade.self) { contexto in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Tema.ambar)
                        .frame(width: 6, height: 6)
                    Text("DESTAQUE")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                if contexto.isStale {
                    Text("Traço")
                        .font(Tema.corpo.weight(.medium))
                        .foregroundStyle(.secondary)
                } else {
                    // ADR 04f: a tela bloqueada deixa de ser cartaz. O círculo é o
                    // mesmo gesto do widget da casa, e o alvo é a LINHA inteira.
                    Button(intent: DestaqueFeitoIntent(nota: contexto.attributes.id, dia: contexto.attributes.dia)) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle")
                                .font(Tema.corpo.weight(.light))
                                .foregroundStyle(Tema.ambar)
                            Text(contexto.state.linha)
                                .font(Tema.corpo.weight(.medium))
                                .tracking(-0.3)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Marcar como feito: \(Superficie.Destaque.emVoz(contexto.state.linha, inteira: contexto.state.inteira))")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .activitySystemActionForegroundColor(Tema.ambar)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        if !contexto.isStale {
                            Button(intent: DestaqueFeitoIntent(nota: contexto.attributes.id, dia: contexto.attributes.dia)) {
                                Image(systemName: "circle")
                                    .font(Tema.chrome.weight(.light))
                                    .foregroundStyle(Tema.ambar)
                                    .frame(width: Tema.alvo, height: Tema.alvo)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Marcar como feito: \(Superficie.Destaque.emVoz(contexto.state.linha, inteira: contexto.state.inteira))")
                        }
                        Text(contexto.isStale ? "Traço" : contexto.state.linha)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "sparkle")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                Text(contexto.isStale ? "Traço" : contexto.state.linha)
                    .font(Tema.miudo.weight(.medium))
                    .lineLimit(1)
                    .frame(maxWidth: 96)
            } minimal: {
                Image(systemName: "sparkle")
                    .foregroundStyle(Tema.ambar)
            }
        }
    }
}

// MARK: - ADR 2026-09-04a: o próximo compromisso, fora do app

struct EntradaProximo: TimelineEntry {
    let date: Date
    let leitura: SuperficieDisco.Leitura
    var relevance: TimelineEntryRelevance?

    /// Um estado só por entrada, decidido pela DATA da entrada: a mesma
    /// leitura vira "nada marcado" quando o último acaba e "desatualizado"
    /// quando o horizonte passa — sem acordar ninguém.
    var estado: Superficie.EstadoDoProximo {
        guard case .disponivel(let s) = leitura else { return .indisponivel }
        return s.estadoDoProximo(agora: date)
    }

    /// A agenda que ainda vale, para o médio: até três, na ordem.
    var proximos: [Superficie.Proximo] {
        guard case .disponivel(let s) = leitura, !s.desatualizada(agora: date) else { return [] }
        return s.proximos.filter { $0.inicio > date }.map { p in
            var p = p
            if let l = p.lembrarEm, l <= date { p.lembrarEm = nil }
            return p
        }
    }

    /// Quantos ficaram de fora do instantâneo (achado A do G4).
    var alem: Int? {
        guard case .disponivel(let s) = leitura, !s.desatualizada(agora: date) else { return 0 }
        return s.alem()
    }

    /// F4: quando não há compromisso, o widget traz o que o app tem —
    /// a única coisa de hoje — em vez de um vazio de quatro por dois.
    var destaque: Superficie.Destaque? {
        guard case .disponivel(let s) = leitura else { return nil }
        return s.destaqueDeHoje(agora: date)
    }
}

struct ProvedorProximo: TimelineProvider {
    private func entrada(_ agora: Date, _ leitura: SuperficieDisco.Leitura) -> EntradaProximo {
        var e = EntradaProximo(date: agora, leitura: leitura)
        // Relevância declarada (ADR 06d): quanto mais perto o compromisso,
        // mais alto o widget sobe na Pilha Inteligente.
        let peso: Float
        if case .proximo(let p) = e.estado {
            let falta = p.inicio.timeIntervalSince(agora)
            peso = falta <= Relogio.vespera ? 90 : (falta <= 6 * 3600 ? 50 : 20)
        } else if e.destaque != nil {
            peso = 15
        } else {
            peso = 0
        }
        e.relevance = TimelineEntryRelevance(score: peso)
        return e
    }
    func placeholder(in context: Context) -> EntradaProximo { entrada(.now, SuperficieDisco.ler()) }
    func getSnapshot(in context: Context, completion: @escaping (EntradaProximo) -> Void) {
        completion(entrada(.now, SuperficieDisco.ler()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaProximo>) -> Void) {
        let agora = Date()
        let leitura = SuperficieDisco.ler()
        // As transições reais do dia (fim de cada próximo, véspera, soneca,
        // meia-noite, horizonte) — e uma POLÍTICA de volta. `.never`, que
        // estava aqui, deixou os dois widgets nove horas parados no iPhone do
        // dono (06/09, 13:04): sem o app abrir, nada nunca mais era relido.
        let entradas = Relogio.datas(base: Superficie.transicoes(leitura, agora: agora),
                                     inicios: Relogio.inicios(leitura, agora: agora),
                                     agora: agora).map { entrada($0, leitura) }
        completion(Timeline(entries: entradas.isEmpty ? [entrada(agora, leitura)] : entradas,
                            policy: .after(Relogio.voltar(agora: agora, ultima: entradas.last?.date))))
    }
}

struct ProximoWidgetView: View {
    @Environment(\.widgetFamily) private var familia
    @Environment(\.dynamicTypeSize) private var tipo
    var entrada: EntradaProximo

    private func quando(_ p: Superficie.Proximo) -> String {
        Superficie.quando(p.inicio, diaInteiro: p.diaInteiro, agora: entrada.date)
    }

    /// O que a superfície diz quando não há compromisso para mostrar — e é
    /// AQUI que o estado honesto vive (A1). Antes ele aparecia duas vezes: um
    /// selo truncado no cabeçalho (`desatua…`) e a frase logo abaixo, que
    /// ainda repetia a ação do rótulo ("· abra o Traço" mais "Abrir o Traço").
    /// Um lugar, uma frase inteira, a ação uma vez só.
    private var ausencia: String {
        switch entrada.estado {
        case .indisponivel: "Não consegui ler o Traço."
        case .desatualizado: "Desatualizado."
        default: "Nada marcado."
        }
    }

    var body: some View {
        Group {
            switch familia {
            case .accessoryInline:
                if case .proximo(let p) = entrada.estado {
                    Text(Superficie.linhaDoProximo(p))
                } else {
                    Text("Traço")
                }
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 2) {
                    // varredura da C: era a face com mais divergência — o
                    // rótulo sem teto de linha nenhum (é o PRÓXI-/MO original,
                    // vivo na tela bloqueada), o assunto sem escala e a
                    // ausência em 0,9, que não chega em AX5.
                    if case .proximo = entrada.estado {
                        Text("PRÓXIMO")
                            .font(Tema.label)
                            .tracking(Tema.trackingLabel)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.6)
                    }
                    if case .proximo(let p) = entrada.estado {
                        Text(p.titulo)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(1)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.6)
                        Text(quando(p))
                            .font(Tema.miudo)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    } else {
                        Text(ausencia)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(LinhasDoEstado.de(ausencia, teto: 2))
                            .allowsTightening(true)
                            .minimumScaleFactor(0.6)
                    }
                }
            default:
                casa
            }
        }
        .containerBackground(Tema.fundo, for: .widget)
        .widgetURL(URL(string: "traco://calendario"))
    }

    private var casa: some View {
        VStack(alignment: .leading, spacing: 0) {
            Selo(rotulo: "PRÓXIMO")
            Group {
                if case .proximo(let p) = entrada.estado {
                    // um compromisso só não vira "lista de um": o bloco preenche o
                    // médio; a agenda entra quando há de fato uma agenda.
                    if familia == .systemMedium, entrada.proximos.count > 1 {
                        agenda
                    } else {
                        aquele(p)
                    }
                } else {
                    vazio
                }
            }
            // O que empurra o conteúdo para o alto é o FRAME, não um `Spacer`:
            // espaçador flexível disputa altura com o `ViewThatFits` da agenda
            // e o faz escolher menos linhas do que caberiam.
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// PEQUENO (e o médio de um só): o compromisso em bloco, com a hora como
    /// manchete — é o que se lê de relance. E, quando há mais no dia, o autor
    /// sabe que há mais.
    private func aquele(_ p: Superficie.Proximo) -> some View {
        // A8: `+N depois` NÃO some em tamanho de acessibilidade. Esconder
        // informação para limpar a tela é exatamente o que o AGENTS.md
        // proíbe — o autor tem de saber que há mais dois compromissos hoje.
        BlocoProximo(proximo: p, agora: entrada.date,
                     restantes: .de(naFace: 1, publicados: entrada.proximos.count,
                                    alem: entrada.alem),
                     grande: true)
    }

    /// MÉDIO: a agenda. Os compromissos com hora, assunto e alarme — o espaço
    /// que a F2 gastava numa frase (G0 da F4, item 5) — e, desde o G4, a conta
    /// do que não coube: mostrava três de cinco sem dizer que havia mais.
    private var agenda: some View {
        AgendaQueCabe(proximos: entrada.proximos, agora: entrada.date,
                      alem: entrada.alem, entreLinhas: true)
    }

    /// Vazio é oportunidade (`curva-zero`): sem compromisso, o widget traz a
    /// única coisa de hoje — que já está no mesmo instantâneo — e só quando
    /// não há nem isso é que ele oferece a ação.
    @ViewBuilder private var vazio: some View {
        if case .vazio = entrada.estado, let d = entrada.destaque {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nada marcado hoje.")
                    .font(Tema.miudo.weight(.medium))
                    .foregroundStyle(Tema.tintaFraca)
                BotaoFeito(destaque: d) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
                            .font(Tema.chrome.weight(.light))
                            .foregroundStyle(d.feito ? Tema.tintaFraca : Tema.ambar)
                        // F5: a MESMA frase do autor, a mesma lei. Aqui ela
                        // cortava tanto no pequeno quanto no médio (re-G3 N3);
                        // o teto de linhas era o culpado dos dois lados, e a
                        // correção mora num lugar só (`FraseDoAutor`).
                        FraseDoAutor(destaque: d, fonte: Tema.chrome.weight(.semibold))
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
            }
        } else if case .vazio = entrada.estado, familia == .systemMedium {
            // Achado E: só o widget do Traço tinha ganhado o quadro. Aqui a
            // ordem de valor é outra — quem olha o Próximo vazio quer MARCAR.
            QuadroVazio(estado: ausencia,
                        ofertas: [("traco://calendario", "Marcar compromisso", "calendar.badge.plus"),
                                  ("traco://nova", "Nova nota", "square.and.pencil")])
        } else if case .vazio = entrada.estado {
            Oferta(estado: ausencia, rotulo: "Marcar compromisso", glifo: "calendar.badge.plus")
        } else {
            Oferta(estado: ausencia, rotulo: "Abrir o Traço", glifo: "arrow.up.forward.app")
        }
    }
}

struct TracoProximoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: SuperficieDisco.kindProximo, provider: ProvedorProximo()) { entrada in
            ProximoWidgetView(entrada: entrada)
        }
        .configurationDisplayName("Próximo compromisso")
        .description("A agenda do dia: hora, assunto e a que horas o Traço te avisa.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

/// O compromisso vivo: enquanto ele não chega, a Ilha conta. O tempo é
/// desenhado pelo SISTEMA (`Text(style:)`), então anda sem o app acordar —
/// o único jeito honesto de uma contagem regressiva na tela bloqueada.
///
/// A contagem só aparece na ÚLTIMA HORA. Cinco horas em h:mm:ss é teatro: o
/// número muda o tempo todo e não muda nada para quem lê (e ainda estourava a
/// faixa compacta da Ilha, saindo cortado — visto no simulador, 04/set).
/// Longe, a Ilha diz a HORA; perto, ela conta.
private func contando(_ inicio: Date, agora: Date = .now) -> Bool {
    let falta = inicio.timeIntervalSince(agora)
    return falta > 0 && falta <= 3600
}

/// A cápsula da ação, uma só para o cartão e a Ilha: a assinatura do app numa
/// tela que não é do app. O fill âmbar não sobrevive ao material do sistema
/// (sai ocre sujo — visto em 04/set), então a cor vive no TRAÇO e na letra.
/// A cápsula da casa fora do app — UMA medida (dívida do G4 da F4-F: a do
/// quadro vazio dizia ser "a mesma da tela bloqueada" e tinha 16/9 contra
/// 18/38). 38 pt: o alvo do §15 é 44, e no cartão da tela bloqueada 38 é o
/// teto do que cabe sem empurrar o título — a área tocável ganha o resto por
/// fora. A tinta é de quem veste: `Tema.ambar` sobre o material da bloqueada,
/// `Tema.ambarTinta` sobre o papel da casa (contraste, não gosto).
private struct CapsulaViva: ViewModifier {
    var compacta = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, compacta ? 14 : 18)
            .frame(minHeight: compacta ? 32 : 38)
            .background(.quaternary, in: Capsule())
            .overlay(Capsule().strokeBorder(Tema.ambar.opacity(0.55), lineWidth: 1))
            .contentShape(Capsule())
    }
}

private extension View {
    func capsulaViva(compacta: Bool = false) -> some View { modifier(CapsulaViva(compacta: compacta)) }
}

private struct CapsulaLembrar: View {
    let ocorrencia: String
    let naIlha: Bool

    var body: some View {
        Button(intent: LembrarDepoisIntent(ocorrencia: ocorrencia)) {
            Text("Lembrar em 10 min")
                .font(naIlha ? Tema.miudo.weight(.semibold) : Tema.acaoViva)
                .foregroundStyle(Tema.ambar)
                .capsulaViva(compacta: naIlha)
        }

        .buttonStyle(.plain)
        .accessibilityLabel("Lembrar em 10 minutos")
    }
}

/// O retorno do toque (ADR 04f): a hora em que vai cobrar, a razão de não ir,
/// ou o botão. Velho (`isStale`): nada — o compromisso acabou.
private struct LinhaDaAcao: View {
    let estado: CompromissoAtividade.ContentState
    let ocorrencia: String
    let velho: Bool
    let naIlha: Bool

    var body: some View {
        if velho {
            if let rotulo = Superficie.rotuloDepoisDoInicio {
                Text(rotulo)
                    .font(Tema.miudo.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        } else if let recado = estado.recado {
            Label(recado, systemImage: "bell.slash")
                .font(Tema.miudo.weight(.medium))
                .foregroundStyle(Tema.aviso)
        } else if let quando = estado.lembrarEm, quando > .now {
            Label("lembro às \(Superficie.horaCurta(quando))", systemImage: "bell.badge")
                .font(Tema.miudo.weight(.medium))
                .foregroundStyle(Tema.ambar)
        } else {
            CapsulaLembrar(ocorrencia: ocorrencia, naIlha: naIlha)
        }
    }
}

struct CompromissoVivo: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompromissoAtividade.self) { contexto in
            // O cartão veste a CASA pela tipografia e pelo âmbar; o material é
            // do sistema (forçar papel por baixo devolvia um cinza sujo).
            //
            // Hierarquia: o assunto é o COMPROMISSO. O relógio é metadado, não
            // manchete (`critique-visual-hierarchy`).
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Tema.ambar)
                        .frame(width: 6, height: 6)
                    if !contexto.isStale {
                        Text("PRÓXIMO")
                            .font(Tema.label)
                            .tracking(Tema.trackingLabel)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    if !contexto.state.diaInteiro, !contexto.isStale {
                        Group {
                            if contando(contexto.state.inicio) {
                                Text(contexto.state.inicio, style: .timer)
                            } else {
                                Text(contexto.state.inicio, style: .relative)
                            }
                        }
                        .font(Tema.miudo.weight(.medium).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        // F5b-C: o teto de 92 pt cortava o relógio relativo em
                        // AX5 ("39 minut…", visto na tela bloqueada). O `Text`
                        // de data (`.timer` e `.relative`) é GULOSO: toma toda a
                        // largura que a linha oferece e encosta os dígitos à
                        // esquerda dela — sem teto e sem alinhar, o relógio
                        // grudava em "PRÓXIMO" (visto). Sem teto o texto nunca
                        // corta; alinhado à direita ele volta ao canto.
                        .multilineTextAlignment(.trailing)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(contexto.state.titulo)
                        .font(Tema.corpo.weight(.semibold))
                        .tracking(-0.4)
                        .foregroundStyle(contexto.isStale ? .secondary : .primary)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    if !contexto.state.diaInteiro {
                        Text(Superficie.horaCurta(contexto.state.inicio))
                            .font(Tema.chrome.weight(.semibold).monospacedDigit())
                            .foregroundStyle(contexto.isStale ? .secondary : .primary)
                    }
                }

                // ADR 04f: ver não é agir. Um botão, um significado — e o toque
                // VIRA texto, senão o botão é mudo (ADR 04a do tamanho do dedo).
                LinhaDaAcao(estado: contexto.state, ocorrencia: contexto.attributes.chave,
                            velho: contexto.isStale, naIlha: false)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .activitySystemActionForegroundColor(Tema.ambar)
        } dynamicIsland: { contexto in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Tema.ambar)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !contexto.state.diaInteiro, !contexto.isStale {
                        // aberta há espaço: aqui a contagem cabe inteira. F5b: o
                        // teto de 76 pt cortava o último dígito ("36:1|5", visto
                        // na tela) — o `.timer` reserva a largura do maior valor
                        // que pode mostrar (h:mm:ss, a seis horas do início) e a
                        // caixa transbordava dos dois lados. Sem teto: a região
                        // mede o que a contagem precisa. Alinhar à direita corta
                        // de novo ("29:4|8", visto): os dígitos ficam à esquerda
                        // da caixa reservada, e a folga fica à direita.
                        Text(contexto.state.inicio, style: .timer)
                            .font(Tema.meta.weight(.semibold).monospacedDigit())
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(contexto.state.titulo)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        LinhaDaAcao(estado: contexto.state, ocorrencia: contexto.attributes.chave,
                                    velho: contexto.isStale, naIlha: true)
                    }
                    // F5b: com 4 pt a curva do canto da Ilha comia o "a" de
                    // "acabou", a linha mais baixa da região (visto na tela)
                    .padding(.horizontal, 10)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                if contexto.isStale {
                    if let rotulo = Superficie.rotuloDepoisDoInicio {
                        Text(rotulo)
                            .font(Tema.miudo.weight(.medium))
                            .frame(maxWidth: 52)
                    }
                } else if contexto.state.diaInteiro {
                    Text(contexto.state.titulo)
                        .font(Tema.miudo.weight(.medium))
                        .lineLimit(1)
                        .frame(maxWidth: 76)
                } else if contando(contexto.state.inicio) {
                    Text(contexto.state.inicio, style: .timer)
                        .font(Tema.miudo.weight(.medium).monospacedDigit())
                        .frame(maxWidth: 52)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(Superficie.horaCurta(contexto.state.inicio))
                        .font(Tema.miudo.weight(.medium).monospacedDigit())
                        .frame(maxWidth: 44)
                }
            } minimal: {
                Image(systemName: "calendar")
                    .foregroundStyle(Tema.ambar)
            }
            .widgetURL(URL(string: "traco://calendario"))
        }
    }
}

/// ADR 05w + 06c: o controle da Central de Controle, da tela bloqueada e do
/// botão de Ação. Um toque faz uma coisa: abre o Traço JÁ GRAVANDO — o áudio
/// é guardado primeiro e transcrito depois. Não lê a superfície, não conta,
/// não mostra conteúdo — só o rótulo. O sistema desenha o botão; o âmbar é o
/// do Tema.
///
/// M2 do G3: a placa dizia "Anotar" com ícone de escrever depois de a porta
/// passar a abrir o microfone. O `kind` NÃO muda — é a chave do controle que
/// o autor já instalou; trocá-la apagaria o controle da Central dele.
struct AnotarControle: ControlWidget {
    static let kind = "app.traco.controle.anotar"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: CapturarIntent()) {
                Label("Ditar", systemImage: "mic.fill")
            }
            .tint(Tema.ambar)
        }
        .displayName("Ditar")
        .description("Abre o Traço gravando: fale, e o áudio é guardado antes de qualquer letra.")
    }
}

@main
struct TracoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TracoWidget()
        TracoProximoWidget()
        DestaqueVivo()
        CompromissoVivo()
        AnotarControle()
    }
}

// MARK: - Previews (B5 do G3): um estado por entrada, uma família por preview.
// A prova segue sendo a captura no simulador; aqui o G4 compara famílias.

private enum Amostra {
    static let agora = Date()
    static func superficie(destaque: Superficie.Destaque? = nil, proximos: [Superficie.Proximo] = [],
                           validoAte: Date = agora.addingTimeInterval(86400)) -> SuperficieDisco.Leitura {
        .disponivel(Superficie(revisao: 7, geradoEm: agora.addingTimeInterval(-1500), validoAte: validoAte,
                               destaque: destaque, proximos: proximos))
    }
    static func destaque(feito: Bool) -> Superficie.Destaque {
        .init(id: UUID(), dia: Superficie.diaISO(agora), linha: "Correr antes do café", feito: feito)
    }
    /// F4-I: as três integridades da ADR 08i, com frases do tamanho das do
    /// re-G4 (uma de duas orações, ~100; um parágrafo, ~210). O trecho sai do
    /// MESMO `trecho()` do publicador — o preview não inventa o corte.
    static let longa = "Terminar o capítulo do meio antes de dormir e mandar a versão nova para a Ana revisar na segunda-feira"
    static let paragrafo = "Acordei pensando que o capítulo do meio precisa de uma promessa que fique de pé sozinha para manter quem lê até o fim, e se não der tempo pelo menos anotar o que a Ana disse sobre o ritmo naquela cena do jantar"
    static func destaque(_ linha: String, inteira: Bool?, feito: Bool = false) -> Superficie.Destaque {
        .init(id: UUID(), dia: Superficie.diaISO(agora), linha: linha, feito: feito, inteira: inteira)
    }
    static var inteira: Superficie.Destaque { destaque(longa, inteira: true) }
    static var trecho: Superficie.Destaque {
        let t = Superficie.Destaque.trecho(paragrafo)
        return destaque(t.linha, inteira: t.inteira)
    }
    static var desconhecida: Superficie.Destaque { destaque("Correr antes do café", inteira: nil) }
    static func proximo(lembrar: Bool = false) -> Superficie.Proximo {
        .init(titulo: "Dentista", inicio: agora.addingTimeInterval(2700), fim: agora.addingTimeInterval(6300),
              diaInteiro: false, aviso: agora.addingTimeInterval(2100),
              lembrarEm: lembrar ? agora.addingTimeInterval(600) : nil)
    }
    /// A agenda cheia: o médio tem lugar para três (F4, item 5).
    static var tres: [Superficie.Proximo] {
        [proximo(),
         .init(titulo: "Revisão com o time", inicio: agora.addingTimeInterval(3 * 3600),
               fim: agora.addingTimeInterval(4 * 3600), diaInteiro: false),
         .init(titulo: "Jantar com a Ana", inicio: agora.addingTimeInterval(7 * 3600),
               fim: agora.addingTimeInterval(9 * 3600), diaInteiro: false)]
    }

    static var comDestaque: EntradaTraco { .init(date: agora, leitura: superficie(destaque: destaque(feito: false))) }
    static var feito: EntradaTraco { .init(date: agora, leitura: superficie(destaque: destaque(feito: true))) }
    static var vazio: EntradaTraco { .init(date: agora, leitura: superficie()) }
    static var indisponivel: EntradaTraco { .init(date: agora, leitura: .indisponivel) }

    /// F4: a única coisa de hoje E o que vem — o mesmo instantâneo.
    static var oDia: EntradaTraco {
        .init(date: agora, leitura: superficie(destaque: destaque(feito: false), proximos: tres))
    }
    /// F4: sem Destaque, o widget traz o que vem em vez de morrer vazio.
    static var semDestaqueComAgenda: EntradaTraco { .init(date: agora, leitura: superficie(proximos: tres)) }
    /// A7: o estado que a F4 introduziu e nenhum preview olhava — foi por isso
    /// que `TRAÇO · desatua…` chegou até a casa do dono (revisão G3, A1/A7).
    static var velho: EntradaTraco {
        .init(date: agora, leitura: superficie(proximos: tres, validoAte: agora.addingTimeInterval(-60)))
    }
    /// R1: o estado que faltava — velho COM Destaque posto. É a casa do dono
    /// (ele tem os dois widgets e põe Destaque todo dia), e era a única
    /// combinação que nenhum preview olhava: por isso o widget do Traço pôde
    /// ficar mudo por uma volta inteira.
    static var velhoComDestaque: EntradaTraco {
        .init(date: agora, leitura: superficie(destaque: destaque(feito: false), proximos: tres,
                                               validoAte: agora.addingTimeInterval(-60)))
    }

    static var comProximo: EntradaProximo { .init(date: agora, leitura: superficie(proximos: [proximo()])) }
    static var agendaCheia: EntradaProximo { .init(date: agora, leitura: superficie(proximos: tres)) }
    /// F4: agenda vazia mostra a única coisa de hoje (curva-zero).
    static var vazioComDestaque: EntradaProximo {
        .init(date: agora, leitura: superficie(destaque: destaque(feito: false)))
    }
    static var comSoneca: EntradaProximo { .init(date: agora, leitura: superficie(proximos: [proximo(lembrar: true)])) }
    static var nadaMarcado: EntradaProximo { .init(date: agora, leitura: superficie()) }
    static var desatualizado: EntradaProximo {
        .init(date: agora, leitura: superficie(proximos: [proximo()], validoAte: agora.addingTimeInterval(-60)))
    }
    static var semDados: EntradaProximo { .init(date: agora, leitura: .indisponivel) }
}

#Preview("Traço · pequeno", as: .systemSmall) {
    TracoWidget()
} timeline: {
    Amostra.oDia
    Amostra.feito
    Amostra.semDestaqueComAgenda
    Amostra.vazio
    Amostra.velho
    Amostra.velhoComDestaque
    Amostra.indisponivel
}

#Preview("Traço · médio", as: .systemMedium) {
    TracoWidget()
} timeline: {
    Amostra.oDia
    Amostra.feito
    Amostra.semDestaqueComAgenda
    Amostra.vazio
    Amostra.velho
    Amostra.velhoComDestaque
    Amostra.indisponivel
}

#Preview("Traço · bloqueada", as: .accessoryRectangular) {
    TracoWidget()
} timeline: {
    Amostra.comDestaque
    Amostra.feito
    Amostra.velhoComDestaque
    Amostra.vazio
    Amostra.indisponivel
}

#Preview("Traço · AX5", traits: .fixedLayout(width: 170, height: 170)) {
    TracoWidgetView(entrada: Amostra.oDia)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

/// A7: os dois estados que truncaram na casa, no tamanho grande e na largura
/// estreita — o par que teria pegado A1 e A3 antes do dono.
#Preview("Traço · velho AX5", traits: .fixedLayout(width: 170, height: 170)) {
    TracoWidgetView(entrada: Amostra.velho)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Traço · médio AX5", traits: .fixedLayout(width: 364, height: 170)) {
    TracoWidgetView(entrada: Amostra.semDestaqueComAgenda)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

/// R1: a combinação que regrediu — Destaque posto e horizonte vencido — nas
/// duas larguras da casa e no tamanho grande. Um preview por defeito conhecido.
#Preview("Traço · velho com Destaque AX5", traits: .fixedLayout(width: 170, height: 170)) {
    TracoWidgetView(entrada: Amostra.velhoComDestaque)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

/// A11/M1: o médio vazio virou quadro de ofertas — e em AX5 ele continua
/// tendo ação, que era exatamente o que sumia.
#Preview("Traço · médio vazio AX5", traits: .fixedLayout(width: 364, height: 170)) {
    TracoWidgetView(entrada: Amostra.vazio)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Próximo · pequeno", as: .systemSmall) {
    TracoProximoWidget()
} timeline: {
    Amostra.agendaCheia
    Amostra.comProximo
    Amostra.comSoneca
    Amostra.vazioComDestaque
    Amostra.nadaMarcado
    Amostra.desatualizado
    Amostra.semDados
}

#Preview("Próximo · médio", as: .systemMedium) {
    TracoProximoWidget()
} timeline: {
    Amostra.agendaCheia
    Amostra.comProximo
    Amostra.comSoneca
    Amostra.vazioComDestaque
    Amostra.nadaMarcado
    Amostra.desatualizado
    Amostra.semDados
}

#Preview("Próximo · bloqueada", as: .accessoryRectangular) {
    TracoProximoWidget()
} timeline: {
    Amostra.comProximo
    Amostra.nadaMarcado
    Amostra.desatualizado
    Amostra.semDados
}

#Preview("Próximo · AX5", traits: .fixedLayout(width: 170, height: 170)) {
    ProximoWidgetView(entrada: Amostra.agendaCheia)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

/// A7: a oferta que saía "Marcar um compro…" e o estado que saía "desatua…",
/// nos dois lugares onde eles cortavam.
#Preview("Próximo · vazio AX5", traits: .fixedLayout(width: 170, height: 170)) {
    ProximoWidgetView(entrada: Amostra.nadaMarcado)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Próximo · velho AX5", traits: .fixedLayout(width: 170, height: 170)) {
    ProximoWidgetView(entrada: Amostra.desatualizado)
        .padding(16)
        .environment(\.dynamicTypeSize, .accessibility5)
}

// MARK: - Previews dos componentes (F4-I): `FraseDoAutor` e `CapsulaViva`, um estado por face.
// Os dois têm lei com suíte e vivem num lugar só; faltava a vista. A prova segue
// sendo a captura no simulador — aqui se compara integridade, corte e categoria.

/// A coluna que a face dá à frase: 123 pt ao lado do círculo no pequeno; 138
/// com o círculo em cima (AX); o cartão do pequeno tem 138 de altura útil.
private struct Palco<Conteudo: View>: View {
    var largura: CGFloat = 123
    var altura: CGFloat = 138
    var papel = true
    @ViewBuilder let conteudo: () -> Conteudo

    var body: some View {
        conteudo()
            .frame(width: largura, height: altura, alignment: .topLeading)
            .padding(16)
            .background(papel ? Tema.fundo : Color.black)
    }
}

/// Inteira, trecho do publicador (termina no "…" dele) e integridade
/// desconhecida (instantâneo anterior à conta) — os três estados do ponto 2.
#Preview("FraseDoAutor · inteira, trecho, desconhecida", traits: .fixedLayout(width: 170, height: 460)) {
    VStack(alignment: .leading, spacing: 24) {
        FraseDoAutor(destaque: Amostra.destaque(feito: false), fonte: Tema.chrome.weight(.semibold))
        FraseDoAutor(destaque: Amostra.trecho, fonte: Tema.chrome.weight(.semibold))
        FraseDoAutor(destaque: Amostra.desconhecida, fonte: Tema.chrome.weight(.semibold))
    }
    .frame(width: 123, alignment: .topLeading)
    .padding(16)
    .background(Tema.fundo)
}

/// A projeção é inteira e a FACE corta: ~100 caracteres em 123 × 138 — cinco
/// linhas no corpo cheio e "…" no que sobrou, sem encolher (ponto 4).
#Preview("FraseDoAutor · a face corta em corpo cheio", traits: .fixedLayout(width: 170, height: 170)) {
    Palco { FraseDoAutor(destaque: Amostra.inteira, fonte: Tema.chrome.weight(.semibold)) }
}

/// Com "Desatualizado." embaixo: o rodapé nunca cede, a frase cede quantidade.
#Preview("FraseDoAutor · com Desatualizado.", traits: .fixedLayout(width: 170, height: 170)) {
    Palco {
        VStack(alignment: .leading, spacing: 4) {
            FraseDoAutor(destaque: Amostra.trecho, fonte: Tema.chrome.weight(.semibold))
            Velho().layoutPriority(-1)
        }
    }
}

/// AX5: o corpo cresce com a categoria (~23 pt) e a frase cede linhas, não
/// tamanho — o fato 1 do G4, na vista.
#Preview("FraseDoAutor · AX5", traits: .fixedLayout(width: 170, height: 170)) {
    Palco(largura: 138) { FraseDoAutor(destaque: Amostra.inteira, fonte: Tema.chrome.weight(.semibold)) }
        .environment(\.dynamicTypeSize, .accessibility5)
}

/// Tela bloqueada (`acessorio`): quem tinge é o sistema — `.primary` e, feito,
/// `.secondary` — sobre o material escuro, em `Tema.meta`.
#Preview("FraseDoAutor · bloqueada", traits: .fixedLayout(width: 190, height: 150)) {
    VStack(alignment: .leading, spacing: 12) {
        FraseDoAutor(destaque: Amostra.trecho, fonte: Tema.meta.weight(.medium), maximo: 2, acessorio: true)
        FraseDoAutor(destaque: Amostra.destaque(feito: true), fonte: Tema.meta.weight(.medium), maximo: 2, acessorio: true)
    }
    .frame(width: 158, alignment: .topLeading)
    .padding(16)
    .background(Color.black)
    .environment(\.colorScheme, .dark)
}

/// Uma cápsula só (18/38; 14/32 na Ilha), a tinta de quem veste: `ambarTinta`
/// sobre o papel da casa, `ambar` sobre o material da bloqueada e da Ilha.
#Preview("CapsulaViva · casa, bloqueada, Ilha", traits: .fixedLayout(width: 260, height: 220)) {
    VStack(alignment: .leading, spacing: 12) {
        Text("Nova nota").font(Tema.acaoViva).foregroundStyle(Tema.ambarTinta).capsulaViva()
            .padding(12).background(Tema.fundo)
        Text("Lembrar em 10 min").font(Tema.acaoViva).foregroundStyle(Tema.ambar).capsulaViva()
            .padding(12).background(Color.black)
        Text("Lembrar em 10 min").font(Tema.miudo.weight(.semibold)).foregroundStyle(Tema.ambar).capsulaViva(compacta: true)
            .padding(12).background(Color.black)
    }
    .environment(\.colorScheme, .dark)
}

/// AX5: a cápsula cresce com a letra e mantém o traço e a tinta.
#Preview("CapsulaViva · AX5", traits: .fixedLayout(width: 300, height: 180)) {
    VStack(alignment: .leading, spacing: 12) {
        Text("Nova nota").font(Tema.acaoViva).foregroundStyle(Tema.ambarTinta).capsulaViva()
            .padding(12).background(Tema.fundo)
        Text("Lembrar em 10 min").font(Tema.miudo.weight(.semibold)).foregroundStyle(Tema.ambar).capsulaViva(compacta: true)
            .padding(12).background(Color.black)
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}
