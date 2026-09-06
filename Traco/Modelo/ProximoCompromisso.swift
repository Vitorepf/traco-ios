import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

/// ADR 2026-09-04a — o próximo compromisso, FORA do app.
///
/// A palavra do dono: *"está marcado não adianta nada se eu não sei"*. Um
/// compromisso que só existe dentro do Traço é um compromisso que o autor
/// descobre tarde — porque a tela que ele mais olha não é a do Traço, é a
/// bloqueada. Então o próximo mora no App Group e aparece em três lugares:
/// widget da casa, widget da tela bloqueada e Live Activity na Ilha.
///
/// Só o que ele MESMO marcou e o que o iPhone dele já mostra. Nota, expressiva
/// e trancada não passam por aqui: o selo vale para a tela bloqueada como vale
/// para a rede.
///
/// ADR 05u: o app publica os próximos (até três, quinze dias) em `Superficie`
/// e a soneca vive aqui, com a ocorrência a que pertence. O snapshot é
/// projeção: quem age (a tela bloqueada) devolve a ocorrência e o app relê o
/// disco antes de agendar qualquer coisa.
nonisolated enum ProximoCompromisso: Sendable {
    nonisolated static let suite = "group.app.traco"
    nonisolated static let chaveSoneca = "sonecaOcorrencia"
    nonisolated static let chaveSonecaEm = "sonecaEm"
    /// Quantos próximos a superfície conhece de antemão: o widget vira
    /// sozinho de um para o outro sem acordar o app.
    nonisolated static let candidatas = 3
    nonisolated static let horizonte: TimeInterval = 14 * 86400

    /// O que a tela mostra. `aviso` é o instante em que vai tocar — nil quando
    /// o autor desligou; a superfície diz as duas coisas, nunca finge.
    nonisolated struct Fatia: Equatable, Sendable {
        /// O id do compromisso: a tela bloqueada precisa dele para AGIR
        /// (ADR 04f), não só para mostrar.
        var id: UUID = UUID()
        var titulo: String
        var inicio: Date
        var fim: Date
        var diaInteiro: Bool
        var aviso: Date?
        /// A soneca que o autor pediu da própria tela bloqueada.
        var lembrarEm: Date?
        var doSistema: Bool = false

        var ocorrencia: String { Superficie.ocorrencia(id, inicio) }

        func comLembrete(_ quando: Date) -> Fatia {
            var f = self
            f.lembrarEm = quando
            return f
        }

        var projecao: Superficie.Proximo {
            .init(id: id, titulo: titulo, inicio: inicio, fim: fim, diaInteiro: diaInteiro,
                  aviso: aviso, lembrarEm: lembrarEm, doSistema: doSistema)
        }

        init(id: UUID = UUID(), titulo: String, inicio: Date, fim: Date, diaInteiro: Bool,
             aviso: Date? = nil, lembrarEm: Date? = nil, doSistema: Bool = false) {
            self.id = id
            self.titulo = titulo
            self.inicio = inicio
            self.fim = fim
            self.diaInteiro = diaInteiro
            self.aviso = aviso
            self.lembrarEm = lembrarEm
            self.doSistema = doSistema
        }

        init(_ p: Superficie.Proximo) {
            self.init(id: p.id, titulo: p.titulo, inicio: p.inicio, fim: p.fim, diaInteiro: p.diaInteiro,
                      aviso: p.aviso, lembrarEm: p.lembrarEm, doSistema: p.doSistema)
        }
    }

    nonisolated private static var defaults: UserDefaults { UserDefaults(suiteName: suite) ?? .standard }

    // MARK: - Publicação

    /// Grava a lista de candidatas na superfície. `validoAte`: quando a lista
    /// é a verdade inteira (menos que `candidatas` no horizonte), vale até o
    /// fim do horizonte; senão só até a última acabar — depois disso o widget
    /// não inventa o seguinte, diz "desatualizado".
    @discardableResult
    nonisolated static func publicar(_ fatias: [Fatia], agora: Date = .now) -> Bool {
        let comSoneca = fatias.map { f -> Fatia in
            var f = f
            if f.lembrarEm == nil { f.lembrarEm = sonecaAtiva(ocorrencia: f.ocorrencia, agora: agora) }
            return f
        }
        // horizonte no início do dia: estável dentro do dia, senão cada
        // republicação idêntica viraria escrita nova (e o WidgetKit recusa
        // reload em rajada — visto no Air, 05/09: ChronoCoreErrorDomain 27)
        let validoAte = comSoneca.count < candidatas
            ? Calendar.current.startOfDay(for: agora.addingTimeInterval(horizonte))
            : (comSoneca.last?.fim ?? agora)
        return SuperficieDisco.publicar(agora: agora) {
            $0.proximos = comSoneca.map(\.projecao)
            $0.validoAte = validoAte
        }
    }

    /// Uma só, ou nada (testes e o intent). `nil` esvazia.
    nonisolated static func gravar(_ f: Fatia?, agora: Date = .now) {
        publicar(f.map { [$0] } ?? [], agora: agora)
    }

    /// O que está publicado, se ainda não acabou. Compromisso que terminou não
    /// é "o próximo" — deixar o de ontem na tela bloqueada é mentira barata.
    nonisolated static func lido(agora: Date = .now) -> Fatia? {
        guard case .disponivel(let s) = SuperficieDisco.ler(), let p = s.proximo(agora: agora) else { return nil }
        var f = Fatia(p)
        if let l = f.lembrarEm, l <= agora { f.lembrarEm = nil }
        return f
    }

    /// A linha de uma face só (`accessoryInline`): hora e título, nada mais.
    nonisolated static func naTelaBloqueada(agora: Date = .now) -> String {
        Superficie.linhaDoProximo(lido(agora: agora)?.projecao)
    }

    nonisolated static func horaCurta(_ data: Date) -> String { Superficie.horaCurta(data) }
    nonisolated static func diaEmPalavras(_ data: Date, agora: Date = .now) -> String {
        Superficie.diaEmPalavras(data, agora: agora)
    }

    // MARK: - Soneca (ADR 04f, com identidade e orçamento — ADR 05u)

    nonisolated static func sonecaAtiva(ocorrencia: String, agora: Date = .now) -> Date? {
        let d = defaults
        guard d.string(forKey: chaveSoneca) == ocorrencia else { return nil }
        let em = d.double(forKey: chaveSonecaEm)
        return em > agora.timeIntervalSince1970 ? Date(timeIntervalSince1970: em) : nil
    }

    nonisolated static func registrarSoneca(ocorrencia: String, em quando: Date) {
        let d = defaults
        d.set(ocorrencia, forKey: chaveSoneca)
        d.set(quando.timeIntervalSince1970, forKey: chaveSonecaEm)
    }

    nonisolated static func esquecerSoneca() {
        defaults.removeObject(forKey: chaveSoneca)
        defaults.removeObject(forKey: chaveSonecaEm)
    }

    /// Relê o compromisso ANTES de agir: o disco do calendário é a verdade;
    /// o que veio do iPhone só existe na projeção e vale se ainda é o mesmo.
    /// Fora disso a ocorrência é velha — e cartão velho não altera nada.
    @MainActor
    static func revalidar(ocorrencia: String, agora: Date = .now) -> Fatia? {
        if case .eventos(let eventos) = CalendarioDisco.carregar() {
            let cal = Calendario.gregoriano()
            let ate = cal.date(byAdding: .day, value: 15, to: agora) ?? agora
            if let e = Calendario.ocorrencias(eventos.filter { !$0.eDeixa && $0.origemTrabalho == nil },
                                              de: agora.addingTimeInterval(-86400), a: ate, cal)
                .first(where: { Superficie.ocorrencia($0.id, $0.inicio) == ocorrencia && $0.fim > agora }) {
                return Fatia(id: e.id, titulo: e.titulo, inicio: e.inicio, fim: e.fim, diaInteiro: e.diaInteiro,
                             aviso: lido(agora: agora)?.aviso)
            }
        }
        if let f = lido(agora: agora), f.doSistema, f.ocorrencia == ocorrencia { return f }
        return nil
    }

    /// O intent da tela bloqueada, inteiro: revalida, pede pelo orçamento,
    /// persiste, publica e SÓ ENTÃO conta na atividade. Erro vira recado.
    @MainActor
    static func lembrarDepois(ocorrencia: String, minutos: Int, agora: Date = .now) async {
        guard let f = revalidar(ocorrencia: ocorrencia, agora: agora) else {
            await encerrarAtividade(ocorrencia: ocorrencia)
            return
        }
        let r = await Revisoes.soneca(titulo: f.titulo, compromisso: f.id, ocorrencia: ocorrencia,
                                      minutos: minutos, agora: agora)
        switch r {
        case .agendado(let quando):
            // o `await` deixou a porta aberta: um editor pode ter apagado ou
            // movido o compromisso enquanto o centro pensava. Relê antes de
            // guardar — soneca de ocorrência que não existe mais é ruído
            guard revalidar(ocorrencia: ocorrencia, agora: agora) != nil else {
                Revisoes.cancelarSoneca(ocorrencia: ocorrencia)
                await encerrarAtividade(ocorrencia: ocorrencia)
                return
            }
            registrarSoneca(ocorrencia: ocorrencia, em: quando)
            guard republicar(agora: agora) else {
                // sem superfície não há confirmação: desfaz o que prometeu
                esquecerSoneca()
                Revisoes.cancelarSoneca(ocorrencia: ocorrencia)
                await contar("não consegui guardar o lembrete", de: f)
                return
            }
            await contar(nil, de: f.comLembrete(quando))
        case .semPermissao:
            await contar("avisos desligados no iPhone", de: f)
        case .semEspaco:
            await contar("o iPhone já tem \(Avisos.teto) avisos; este ficou sem", de: f)
        case .falhou:
            await contar("não consegui marcar o lembrete", de: f)
        }
    }

    /// Republica a projeção a partir do que está publicado + soneca guardada.
    nonisolated private static func republicar(agora: Date) -> Bool {
        guard case .disponivel(let s) = SuperficieDisco.ler() else { return false }
        return SuperficieDisco.publicar(agora: agora) {
            $0.proximos = s.proximos.map { p in
                var p = p
                p.lembrarEm = sonecaAtiva(ocorrencia: p.ocorrencia, agora: agora)
                return p
            }
        }
    }

    // MARK: - A Ilha (só quando é hoje e está perto)

    /// Longe demais na Ilha vira ruído permanente; perto é justamente quando
    /// olhar o relógio resolve. Seis horas é a janela de "o resto do meu dia".
    nonisolated static let janelaViva: TimeInterval = 6 * 3600

    /// Uma atividade só, da ocorrência publicada; encerra o resto. Chamada
    /// no arranque, no retorno à cena, em cada publicação e após comando.
    nonisolated static func reconciliar(agora: Date = .now) async {
        await atualizarAtividade(lido(agora: agora), agora: agora)
    }

    nonisolated static func atualizarAtividade(_ f: Fatia?, agora: Date = .now) async {
        #if canImport(ActivityKit)
        guard let f, f.inicio.timeIntervalSince(agora) <= janelaViva, f.fim > agora else {
            await encerrarAtividades()
            return
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let estado = CompromissoAtividade.ContentState(
            titulo: f.titulo, inicio: f.inicio, fim: f.fim, diaInteiro: f.diaInteiro,
            lembrarEm: f.lembrarEm, recado: nil)
        let conteudo = ActivityContent(state: estado, staleDate: f.fim)
        var viva: Activity<CompromissoAtividade>?
        for a in Activity<CompromissoAtividade>.activities {
            if viva == nil, a.attributes.chave == f.ocorrencia, a.activityState == .active {
                viva = a
            } else {
                await a.end(nil, dismissalPolicy: .immediate)
            }
        }
        if let viva {
            var atual = viva.content.state
            atual.recado = nil
            if atual != estado { await viva.update(conteudo) }
            return
        }
        _ = try? Activity.request(attributes: CompromissoAtividade(chave: f.ocorrencia), content: conteudo)
        #endif
    }

    nonisolated static func encerrarAtividades() async {
        #if canImport(ActivityKit)
        for a in Activity<CompromissoAtividade>.activities {
            await a.end(nil, dismissalPolicy: .immediate)
        }
        #endif
    }

    nonisolated static func encerrarAtividade(ocorrencia: String) async {
        #if canImport(ActivityKit)
        for a in Activity<CompromissoAtividade>.activities where a.attributes.chave == ocorrencia {
            await a.end(nil, dismissalPolicy: .immediate)
        }
        #endif
    }

    /// O retorno na tela: ou a hora em que vai cobrar, ou a razão de não ir.
    /// Aguardado, não enfileirado: o intent só devolve depois de a tela mudar.
    nonisolated private static func contar(_ recado: String?, de f: Fatia) async {
        #if canImport(ActivityKit)
        for a in Activity<CompromissoAtividade>.activities where a.attributes.chave == f.ocorrencia {
            var estado = a.content.state
            estado.lembrarEm = f.lembrarEm
            estado.recado = recado
            await a.update(ActivityContent(state: estado, staleDate: f.fim))
        }
        #endif
    }
}
