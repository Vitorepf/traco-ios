import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

// ADR 05u: os widgets LEEM `Superficie` (o snapshot do App Group) e nada mais.
// Nenhuma chave solta, nenhum domínio, nenhum reload por minuto: a linha do
// tempo já traz as transições conhecidas (meia-noite, fim de cada próximo,
// horizonte) e o app recarrega os kinds afetados depois de cada escrita.
// Tipografia pelos degraus de `Tema` (D3): escala com o sistema.

/// A ponte entre o instantâneo e o `Relogio` (que é só aritmética de datas).
extension Relogio {
    static func inicios(_ leitura: SuperficieDisco.Leitura, agora: Date) -> [Date] {
        guard case .disponivel(let s) = leitura else { return [] }
        return s.proximos.filter { $0.fim > agora }.map(\.inicio)
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
        return s.proximos.filter { $0.fim > date }
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
    /// No quadro de ofertas o alvo é a linha inteira (Fitts); no cabeçalho,
    /// não — lá ele divide a faixa com a marca e com o irmão.
    var largo: Bool = false

    var body: some View {
        Link(destination: URL(string: rota)!) {
            corpo
        }
        .accessibilityLabel(rotulo)
    }

    /// No pequeno o sistema só honra um destino (`widgetURL`): ali o atalho é
    /// desenho, não `Link` — quem leva o toque é o widget inteiro.
    var corpo: some View {
        HStack(spacing: 5) {
            Image(systemName: glifo)
                .font(Tema.miudo.weight(.semibold))
            // A3, de novo: encolher a 85% não salva "Marcar compromisso" em
            // tamanho de acessibilidade — e oferta cortada não é oferta. A
            // linha quebra; a palavra, nunca.
            Text(rotulo)
                .font(Tema.miudo.weight(.semibold))
                .lineLimit(2)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            if largo { Spacer(minLength: 0) }
        }
        .foregroundStyle(primario ? Tema.ambarTinta : Tema.tintaSuave)
        .frame(maxWidth: largo ? .infinity : nil, alignment: .leading)
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
        primeiro && proximo.inicio.timeIntervalSince(agora) <= Relogio.vespera && proximo.fim > agora
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(proximo.diaInteiro ? "dia" : Superficie.horaCurta(proximo.inicio))
                    .font((primeiro ? Tema.meta : Tema.miudo).weight(.semibold).monospacedDigit())
                    .foregroundStyle(iminente ? Tema.ambarTinta : (primeiro ? Tema.tinta : Tema.tintaSuave))
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
    var restantes: Int = 0
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
                    .minimumScaleFactor(0.7)
            }
            Text(proximo.titulo)
                .font(Tema.meta.weight(.semibold))
                .foregroundStyle(Tema.tinta)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
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
            if restantes > 0 {
                Text("+\(restantes) depois")
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
        if restantes > 0 { partes.append("mais \(restantes) depois") }
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

/// O botão do feito, com identidade (ADR 05u): marca ou desfaz — dois
/// intents, nunca um toggle. O mesmo gesto na casa e na tela bloqueada (04f).
private struct BotaoFeito<Rotulo: View>: View {
    let destaque: Superficie.Destaque
    @ViewBuilder let rotulo: () -> Rotulo

    var body: some View {
        Group {
            if destaque.feito {
                Button(intent: DestaqueDesfazerIntent(nota: destaque.id, dia: destaque.dia)) { rotulo() }
            } else {
                Button(intent: DestaqueFeitoIntent(nota: destaque.id, dia: destaque.dia)) { rotulo() }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(destaque.feito ? "Feito: \(destaque.linha)" : destaque.linha)
        .accessibilityHint(destaque.feito ? "Desfaz o feito" : "Marca a única coisa de hoje como feita")
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
                Text(entrada.velha ? "Traço · desatualizado"
                                   : (entrada.destaque?.linha ?? "Traço"))
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
                                Text(entrada.velha ? "DESATUALIZADO" : "DESTAQUE")
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .allowsTightening(true)
                                Text(d.linha)
                                    .font(Tema.meta.weight(.medium))
                                    .lineLimit(2)
                                    .strikethrough(d.feito)
                            }
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                } else {
                    Text(entrada.indisponivel ? "Traço · sem dados"
                         : (entrada.velha ? "Traço · desatualizado" : "Traço"))
                        .font(Tema.meta.weight(.medium))
                        .lineLimit(2)
                }
            default:
                casa
            }
        }
        .containerBackground(Tema.fundo, for: .widget)
    }

    /// Quantas linhas a única coisa de hoje pode ocupar. Em tamanho de
    /// acessibilidade o pequeno abre mão do atalho: a linha vem primeiro.
    private var linhasDoDestaque: Int {
        let teto = familia == .systemSmall ? (tipo.isAccessibilitySize ? 4 : 3) : 2
        // Passado o horizonte entra o rodapé do estado. No tamanho normal
        // cabem os dois; em tamanho de acessibilidade não, e aí a QUARTA
        // linha da frase cede — saber que está velho vale mais. O custo é
        // só esse: com `minimumScaleFactor(0.6)` a frase encolhe para caber
        // nas três linhas que sobram, e NUNCA termina em reticências.
        return estadoNaFace == .rodape && tipo.isAccessibilitySize ? max(1, teto - 1) : teto
    }
    private var soALinha: Bool { familia == .systemSmall && tipo.isAccessibilitySize }
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
    @ViewBuilder private func linhaDoDestaque(_ d: Superficie.Destaque) -> some View {
        BotaoFeito(destaque: d) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: d.feito ? "checkmark.circle.fill" : "circle")
                    .font(Tema.chrome.weight(.light))
                    .foregroundStyle(d.feito ? Tema.tintaFraca : Tema.ambar)
                Text(d.linha)
                    .font(Tema.chrome.weight(.semibold))
                    .foregroundStyle(d.feito ? Tema.tintaFraca : Tema.tinta)
                    .strikethrough(d.feito, color: Tema.tintaFraca)
                    .lineLimit(linhasDoDestaque)
                    // 0,85 não chega em 155 pt no AX5 e a frase terminava em
                    // reticências (`capítul…`, re-G3 N1) — reticências no
                    // Destaque é o defeito que abriu a volta. Como em
                    // `Velho()`: a frase ENCOLHE inteira, nunca corta.
                    .allowsTightening(true)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
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
            BlocoProximo(proximo: p, agora: entrada.date, restantes: entrada.proximos.count - 1)
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
        entrada.destaque == nil && !entrada.proximos.isEmpty
            ? ("traco://calendario", "Calendário", "calendar")
            : ("traco://nova", "Nova nota", "square.and.pencil")
    }

    /// PEQUENO: o widget inteiro é um alvo só (`widgetURL`), então os atalhos
    /// aqui são desenho — e só um deles, o primário. "Recordar" continua
    /// encontrável no médio e no app (curva-zero: o poder não some, muda de
    /// lugar).
    private var pequeno: some View {
        VStack(alignment: .leading, spacing: 0) {
            Selo(rotulo: "TRAÇO")
            Spacer(minLength: 8)
            miolo
            Spacer(minLength: 4)
            if estadoNaFace == .rodape {
                // R1: o Destaque fica, e o rodapé conta que ele é velho —
                // o atalho cede a linha, porque a promessa da face vem antes
                // de mais um caminho para dentro do app.
                Velho()
            } else if !soALinha, !ofertando {
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
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Selo(rotulo: "TRAÇO")
                // Com a face vazia os atalhos descem para o corpo (A11/M1):
                // repeti-los aqui seria a mesma ação duas vezes.
                if !tipo.isAccessibilitySize, !vazioTotal {
                    AtalhoTraco(rota: "traco://nova", rotulo: "Nova nota",
                                glifo: "square.and.pencil", primario: true)
                    AtalhoTraco(rota: "traco://recordar", rotulo: "Recordar",
                                glifo: "arrow.counterclockwise")
                }
            }
            Spacer(minLength: 8)
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
            if !entrada.proximos.isEmpty, !tipo.isAccessibilitySize {
                Spacer(minLength: 10)
                Rectangle().fill(Tema.linha).frame(height: 0.5)
                    .padding(.bottom, 8)
                ForEach(Array(entrada.proximos.prefix(entrada.destaque == nil ? 3 : 2).enumerated()),
                        id: \.element.ocorrencia) { i, p in
                    LinhaProximo(proximo: p, agora: entrada.date, primeiro: i == 0)
                        .padding(.bottom, 6)
                }
            }
            if !vazioTotal { Spacer(minLength: 0) }
            if estadoNaFace == .rodape {
                // R1: com Destaque posto, o médio largava a agenda inteira e
                // não dizia nada. Agora diz — no rodapé, embaixo do conteúdo
                // que ele está pondo em dúvida, como no pequeno.
                Velho()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// O médio vazio como QUADRO DE OFERTAS (A11, segunda metade; M1).
    ///
    /// Quatro por dois para uma frase e ~70% de área morta é o defeito 5 do
    /// dono — "densidade errada" — voltando pela porta dos fundos, e widget
    /// configurável não resolve: calendário vazio continua vazio com pasta
    /// escolhida ou sem. Sem Destaque e sem agenda não existe conteúdo a
    /// mostrar; o que existe é o que o autor PODE fazer daqui. Então a face
    /// inteira vira isso: três ações reais, uma por linha, alvo na linha toda.
    ///
    /// E elas moram no CORPO, não no cabeçalho — por isso continuam existindo
    /// em tamanho de acessibilidade, onde o cabeçalho se cala e o vazio ficava
    /// mudo (M1). A recuperação da `curva-zero` não desaparece no tamanho que
    /// mais precisa dela.
    private var quadroVazio: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Nada em destaque hoje.")
                .font(Tema.meta.weight(.medium))
                .foregroundStyle(Tema.tintaSuave)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            AtalhoTraco(rota: "traco://nova", rotulo: "Nova nota",
                        glifo: "square.and.pencil", primario: true, largo: true)
            Spacer(minLength: 8)
            AtalhoTraco(rota: "traco://calendario", rotulo: "Marcar compromisso",
                        glifo: "calendar.badge.plus", largo: true)
            // Em AX5 duas ações já tomam a face inteira; a terceira continua
            // no cabeçalho do tamanho normal e no app (curva-zero: o poder
            // muda de lugar, não some).
            if !tipo.isAccessibilitySize {
                Spacer(minLength: 8)
                AtalhoTraco(rota: "traco://recordar", rotulo: "Recordar",
                            glifo: "arrow.counterclockwise", largo: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
                    .accessibilityLabel("Marcar como feito: \(contexto.state.linha)")
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
                            .accessibilityLabel("Marcar como feito: \(contexto.state.linha)")
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
        return s.proximos.filter { $0.fim > date }.map { p in
            var p = p
            if let l = p.lembrarEm, l <= date { p.lembrarEm = nil }
            return p
        }
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
                    Text("PRÓXIMO")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(.secondary)
                    if case .proximo(let p) = entrada.estado {
                        Text(p.titulo)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(1)
                        Text(quando(p))
                            .font(Tema.miudo)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(ausencia)
                            .font(Tema.meta.weight(.medium))
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
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
            Spacer(minLength: 10)
            if case .proximo(let p) = entrada.estado {
                // um compromisso só não vira "lista de um": o bloco preenche o
                // médio; a agenda entra quando há de fato uma agenda.
                if familia == .systemMedium, !tipo.isAccessibilitySize, entrada.proximos.count > 1 {
                    agenda
                } else {
                    aquele(p)
                }
            } else {
                vazio
            }
            Spacer(minLength: 0)
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
                     restantes: entrada.proximos.count - 1, grande: true)
    }

    /// MÉDIO: a agenda. Três compromissos com hora, assunto e alarme —
    /// o espaço que a F2 gastava numa frase (G0 da F4, item 5).
    private var agenda: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(Array(entrada.proximos.prefix(3).enumerated()), id: \.element.ocorrencia) { i, p in
                if i > 0 { Rectangle().fill(Tema.linha).frame(height: 0.5) }
                LinhaProximo(proximo: p, agora: entrada.date, primeiro: i == 0)
            }
        }
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
                        Text(d.linha)
                            .font(Tema.chrome.weight(.semibold))
                            .foregroundStyle(d.feito ? Tema.tintaFraca : Tema.tinta)
                            .strikethrough(d.feito, color: Tema.tintaFraca)
                            .lineLimit(familia == .systemSmall ? 3 : 2)
                            // re-G3 N3: aqui a frase já cortava em AX5 com a
                            // superfície FRESCA — o corte não era do rodapé.
                            .allowsTightening(true)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
            }
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
private struct CapsulaLembrar: View {
    let ocorrencia: String
    let naIlha: Bool

    var body: some View {
        Button(intent: LembrarDepoisIntent(ocorrencia: ocorrencia)) {
            Text("Lembrar em 10 min")
                .font(naIlha ? Tema.miudo.weight(.semibold) : Tema.acaoViva)
                .foregroundStyle(Tema.ambar)
                .padding(.horizontal, naIlha ? 14 : 18)
                // 38pt: o alvo do §15 é 44, e no cartão da tela bloqueada 38 é
                // o teto do que cabe sem empurrar o título — a área tocável
                // ganha o resto na moldura
                .frame(height: naIlha ? 32 : 38)
                .background(.quaternary, in: Capsule())
                .overlay(Capsule().strokeBorder(Tema.ambar.opacity(0.55), lineWidth: 1))
                .contentShape(Capsule())
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
            Text("acabou")
                .font(Tema.miudo.weight(.medium))
                .foregroundStyle(.secondary)
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
                    Text("PRÓXIMO")
                        .font(Tema.label)
                        .tracking(Tema.trackingLabel)
                        .foregroundStyle(.secondary)
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
                        .frame(maxWidth: 92, alignment: .trailing)
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
                        // aberta há espaço: aqui a contagem cabe inteira
                        Text(contexto.state.inicio, style: .timer)
                            .font(Tema.meta.weight(.semibold).monospacedDigit())
                            .frame(maxWidth: 76)
                            .multilineTextAlignment(.trailing)
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
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(Tema.ambar)
            } compactTrailing: {
                if contexto.isStale {
                    Text("acabou")
                        .font(Tema.miudo.weight(.medium))
                        .frame(maxWidth: 52)
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
