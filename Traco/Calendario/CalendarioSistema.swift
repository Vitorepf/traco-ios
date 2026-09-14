import EventKit
import Foundation

/// Um compromisso que já vive no iPhone. Não é do Traço: o autor marcou em
/// outro lugar (ou o Gmail marcou por ele, ao comprar um ingresso).
nonisolated struct CompromissoDoSistema: Sendable, Equatable {
    var titulo: String
    var inicio: Date
    var fim: Date
    var diaInteiro: Bool
    /// De qual calendário veio — "Trabalho", "Aniversários", o nome que o autor
    /// vê no app Calendário. Serve para a ficha só-leitura dizer de onde é.
    var calendario: String = ""

    init(titulo: String, inicio: Date, fim: Date? = nil,
         diaInteiro: Bool = false, calendario: String = "") {
        self.titulo = titulo
        self.inicio = inicio
        self.fim = fim ?? inicio.addingTimeInterval(3600)
        self.diaInteiro = diaInteiro
        self.calendario = calendario
    }

    /// Vira um evento que a grade sabe desenhar — marcado como do sistema.
    var comoEvento: EventoCalendario {
        var e = EventoCalendario(titulo: titulo, inicio: inicio, fim: fim, diaInteiro: diaInteiro)
        e.doSistema = true
        return e
    }
}

/// Os calendários que já estão no aparelho (ADR 2026-09-03c): Apple, Google,
/// iCloud, Exchange — o EventKit lê TODOS os que aparecem em Ajustes › Apps ›
/// Calendário › Contas. Uma integração cobre todas; não há OAuth, não há
/// cliente no Google Cloud, não há segunda conta.
///
/// **Só leitura, e só local.** O Traço nunca escreve no calendário do autor,
/// nunca sincroniza e nada disto vai à rede — o EventKit é do sistema, no
/// aparelho. O `calendario.json` continua sendo o dono do que se marca AQUI.
///
/// Por que existe: sem contexto, o campo de prosa só sabia mostrar um exemplo
/// inventado. Com isto, ele mostra o próximo compromisso de verdade.
@Observable
final class CalendarioSistema {
    /// A janela que interessa. Placeholder sugerindo algo de três meses adiante
    /// é ruído; sete dias é o horizonte em que "marcar" ainda é uma decisão.
    nonisolated static let janelaDias = 7

    private(set) var proximos: [CompromissoDoSistema] = []
    /// O que a escala visível mostra (A3). Separado de `proximos` porque a
    /// recomendação quer sete dias e a grade quer o que está na tela.
    private(set) var naFaixa: [CompromissoDoSistema] = []
    private(set) var estado: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)

    /// Testes injetam a leitura; produção deixa nil e fala com o EventKit.
    var lerDoSistema: ((Date, Date) -> [CompromissoDoSistema])?

    private let loja = EKEventStore()

    var podeLer: Bool { estado == .fullAccess }

    /// Negou uma vez? O iOS não deixa perguntar de novo — a volta é os Ajustes.
    /// Quem diz isso é o Perfil; aqui só se sabe que é o caso.
    var negado: Bool { estado == .denied || estado == .restricted }

    /// O estado em uma linha, para o Perfil. Honesto, como o da conta Grok.
    var estadoEmPalavras: String {
        switch estado {
        case .fullAccess: proximos.isEmpty
            ? "lendo — nada nos próximos sete dias"
            : "lendo — \(proximos.count) em sete dias"
        case .writeOnly: "o iOS deu só escrita, e o Traço não escreve. Libere a leitura em Ajustes."
        case .denied: "acesso negado. O campo volta a mostrar um exemplo."
        case .restricted: "acesso restrito neste aparelho."
        default: "ainda não perguntei. Abra o Calendário e eu peço."
        }
    }

    /// Pede o acesso UMA vez, e só quando o autor está olhando um calendário —
    /// é ali que o pedido se explica sozinho (jakobs-law). Nunca no arranque:
    /// o §3 diz que o app abre na página em branco, sem cerimônia.
    func pedirAcesso() async {
        // relê sempre: o autor pode ter mudado nos Ajustes e voltado
        estado = EKEventStore.authorizationStatus(for: .event)
        guard estado == .notDetermined else {
            if podeLer { await recarregar() }
            return
        }
        _ = try? await loja.requestFullAccessToEvents()
        estado = EKEventStore.authorizationStatus(for: .event)
        if podeLer { await recarregar() }
    }

    func recarregar(agora: Date = .now, _ cal: Calendar = Calendario.gregoriano()) async {
        let fim = cal.date(byAdding: .day, value: Self.janelaDias, to: agora) ?? agora
        proximos = ler(de: agora, a: fim)
    }

    /// A3: o que a escala está mostrando. A recomendação continua olhando só
    /// `proximos` (sete dias); a grade pede a faixa dela.
    func carregarFaixa(de inicio: Date, a fim: Date) {
        naFaixa = ler(de: inicio, a: fim)
    }

    private func ler(de inicio: Date, a fim: Date) -> [CompromissoDoSistema] {
        if let lerDoSistema {
            return lerDoSistema(inicio, fim).sorted { $0.inicio < $1.inicio }
        }
        guard podeLer, inicio < fim else { return [] }
        // ponytail: janela de sete dias, leitura síncrona na main. Medido barato
        // nesse tamanho; se um dia a janela crescer, isto sai para um ator.
        let predicado = loja.predicateForEvents(withStart: inicio, end: fim, calendars: nil)
        return loja.events(matching: predicado)
            .compactMap { evento in
                let titulo = (evento.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                guard !titulo.isEmpty, let comeco = evento.startDate else { return nil }
                return CompromissoDoSistema(
                    titulo: titulo, inicio: comeco, fim: evento.endDate,
                    diaInteiro: evento.isAllDay, calendario: evento.calendar?.title ?? "")
            }
            .sorted { $0.inicio < $1.inicio }
    }
}

/// A recomendação do campo de prosa.
///
/// O truque que faz isto barato: a sugestão é escrita na LÍNGUA DO CAMPO — a
/// mesma frase que o autor teclaria. Tocar o campo a preenche e daí em diante
/// quem lê é `CalendarioFrase`, como sempre. Nenhum caminho novo de dados,
/// nenhum parser novo.
///
/// E ela só sai se sobreviver à ida e volta: montamos a frase, mandamos o
/// parser lê-la e conferimos que o dia, a hora e o título voltam iguais. Se
/// o título do evento tiver um dia da semana ou um número solto ("Jogo 7x1
/// sexta"), o parser come a palavra errada — e aí a sugestão é descartada em
/// vez de mentir. Silêncio é resposta válida aqui também.
nonisolated enum Recomendacao {
    static func frase(de c: CompromissoDoSistema, agora: Date,
                      _ cal: Calendar = Calendario.gregoriano()) -> String? {
        guard let quando = palavraDoDia(c.inicio, agora: agora, cal) else { return nil }
        let hora = c.diaInteiro ? "dia inteiro" : horaEscrita(c.inicio, cal)
        let candidata = "\(c.titulo) \(quando) \(hora)"
        return sobreviveAIdaEVolta(candidata, alvo: c, agora: agora, cal) ? candidata : nil
    }

    /// A primeira sugestão da lista que o parser aceita de volta.
    static func primeira(de compromissos: [CompromissoDoSistema], agora: Date = .now,
                         _ cal: Calendar = Calendario.gregoriano()) -> String? {
        compromissos
            .filter { $0.inicio >= agora }
            .lazy
            .compactMap { frase(de: $0, agora: agora, cal) }
            .first
    }

    // MARK: as palavras

    /// Dentro de sete dias, e sempre numa palavra que `comerDia` sabe ler.
    nonisolated static func palavraDoDia(_ data: Date, agora: Date, _ cal: Calendar) -> String? {
        let hoje = Calendario.inicioDoDia(agora, cal)
        let dia = Calendario.inicioDoDia(data, cal)
        guard let passo = cal.dateComponents([.day], from: hoje, to: dia).day,
              (0...CalendarioSistema.janelaDias).contains(passo)
        else { return nil }
        switch passo {
        case 0: return "hoje"
        case 1: return "amanhã"
        case 2: return "depois de amanhã"
        default:
            // "segunda", não "segunda-feira": ninguém escreve o sufixo, e ele
            // custava seis caracteres no campo — a dica truncava antes de
            // dizer QUANDO. O parser lê as duas formas.
            return Calendario.formatar(data, "EEEE", cal)
                .lowercased()
                .replacingOccurrences(of: "-feira", with: "")
        }
    }

    nonisolated static func horaEscrita(_ data: Date, _ cal: Calendar) -> String {
        let h = cal.component(.hour, from: data)
        let m = cal.component(.minute, from: data)
        return m == 0 ? "\(h)h" : String(format: "%dh%02d", h, m)
    }

    // MARK: a prova

    nonisolated static func sobreviveAIdaEVolta(
        _ frase: String, alvo: CompromissoDoSistema, agora: Date, _ cal: Calendar
    ) -> Bool {
        guard let lido = CalendarioFrase.ler(frase, ancora: agora, agora: agora, cal) else {
            return false
        }
        guard Calendario.mesmoDia(lido.inicio, alvo.inicio, cal) else { return false }
        guard lido.diaInteiro == alvo.diaInteiro else { return false }
        if !alvo.diaInteiro {
            guard cal.component(.hour, from: lido.inicio) == cal.component(.hour, from: alvo.inicio),
                  cal.component(.minute, from: lido.inicio) == cal.component(.minute, from: alvo.inicio)
            else { return false }
        }
        // o título tem de voltar inteiro: `limparTitulo` só capitaliza a inicial
        return lido.titulo.caseInsensitiveCompare(alvo.titulo) == .orderedSame
    }
}
