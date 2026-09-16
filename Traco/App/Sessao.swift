import Foundation
import CryptoKit
import SwiftData
import SwiftUI

@Observable
final class Sessao {
    var texto: String = ""
    var gesto: Gesto?
    var campos: [String: String] = [:]
    var notaUUID: UUID?
    /// ADR 08u: quem escreveu a nota que está aberta. Página nova é sempre do
    /// autor; a etiqueta da página lê daqui.
    var origemDaPagina: OrigemNota = .autor
    var perguntaPadroes: String?
    var cartao: CartaoAnalisar?
    var toast: String?
    /// O campo que a "volta" nas Notas veio cobrar: a página abre com o cursor
    /// nele, em vez de no título com o campo abaixo da dobra (auditoria 15/09, 3).
    var campoPedido: String?
    /// A nota acabou de ser aberta da lista: a página não rouba o foco para o
    /// título — ler não é escrever; o cursor entra no toque (auditoria 15/09, 11).
    var acabouDeAbrir = false
    var timerLigado = false
    var segundosRestantes = 15 * 60
    /// SPEC §20: um destino por vez. `mostrarNotas`/`mostrarPadroes` continuam
    /// existindo como ponte para a lógica antiga (foco, rota, notificação).
    var aba: Aba = {
        #if DEBUG
        // Instrumento de evidência do ensaio do cartão da sábia: a prova é do
        // CARTÃO, e chegar até ele pela Página fazia o teste depender de uma
        // tela que não é a dele — em AX5 a topbar da Página fica em y=-371 e
        // não volta com rolagem, e o teste ficava vermelho por um defeito de
        // outra área. Só com o mesmo argumento que semeia a resposta.
        if ConversaNotas.ensaioDaRespostaLonga || ConversaNotas.ensaioDaEspera { return .notas }
        #endif
        return .escrever
    }()
    /// A última tela de arquivo visitada: voltar ao arquivo devolve onde parou.
    var abaArquivo: Aba = .notas
    var mostrarRecordar = false

    var mostrarNotas: Bool {
        get { aba == .notas }
        set { aba = newValue ? .notas : .escrever }
    }

    var mostrarPadroes: Bool {
        get { aba == .padroes }
        set { aba = newValue ? .padroes : .escrever }
    }
    var confirmacao: ConfirmacaoEstado?
    var recordarTexto = ""
    var recordarCampos: [String: String] = [:]
    var timerEsgotou = false
    /// SPEC §8: o fecho da expressiva (selar ou queimar) é escolha do autor.
    /// A análise remota leva tempo de rede: sem sinal, a tela fica muda e o
    /// app parece travado (doherty-threshold).
    var analisando = false
    var fechoExpressiva: Int?
    /// A linha de sentido viaja até o salvar — nunca entra no texto selado.
    var sentidoPendente: String?
    var fechoUUID: UUID?
    /// Domínio da página em voo. `dominioTravado` = o autor tocou o chip.
    var dominio: Dominio?
    var dominioTravado = false
    /// Série da expressiva a anexar no próximo salvar.
    var seriePendente: UUID?
    var diaPendente = 0
    /// Sentidos dos dias anteriores — o 4.º fecho os mostra juntos.
    var sentidosDaSerie: [String] = []
    var recordarGesto: Gesto?
    var recordarUUID: UUID?
    var filaUUIDs: [UUID] = []
    /// Só a notificação do dia liga a fila. Recordar solto nunca mostra "próxima".
    var filaAtiva = false
    /// Testes: injeta recusa do disco. Produção deixa nil e grava o contexto.
    var persistirNoDisco: ((ModelContext) throws -> Void)?

    private var toastTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var timerPrazo: Date?

    var paginaVazia: Bool {
        texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// A voz pode viver só nos campos (Se, Destilar, WOOP). Página vazia ≠ sem nota.
    /// Código também é voz: uma nota só com um bloco de código é nota (o corpus
    /// e a IA continuam lendo só a prosa; isto decide se GRAVA).
    var temVoz: Bool {
        !paginaVazia
            || !VozDoAutor.juntar(texto: texto, campos: campos, sentido: sentidoPendente ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Recordar esconde um alvo. O alvo pode ser só o Então, só a frase.
    var podeRecordar: Bool {
        RitualRecordar.de(gesto).temAlvo(texto: texto, campos: campos)
    }

    /// SPEC §4/§6: a forma vive abaixo do texto. Expressiva não tem campos.
    var temCamposDaForma: Bool {
        guard let g = gesto, g != .expressiva else { return false }
        return !g.campos.isEmpty
    }

    /// Um âmbar por vista: Concluir cede enquanto a análise lê ou o cartão fala.
    var concluirEAmbar: Bool {
        gesto != nil && gesto != .expressiva && cartao == nil && !analisando
    }

    var minutosExpressiva: Int {
        max(0, (15 * 60 - segundosRestantes) / 60)
    }

    private var analiseTask: Task<Void, Never>?
    /// A pergunta em voo. Existe para PARAR: sem ela, "parar de esperar" só
    /// esconderia o cartão e a chamada seguiria paga até o teto (ADR 09n).
    private var perguntaTask: Task<Void, Never>?
    /// A identidade da pergunta em voo (ADR 2026-09-10b). `nil` = não há
    /// nenhuma esperando publicação.
    @ObservationIgnored private var perguntaAtual: UUID?

    /// Injeção SOMENTE da operação de IA (mesmo desenho de
    /// `responderContextoNotas`): a seleção do contexto, a identidade da
    /// requisição e a revalidação de acesso continuam as mesmas no app e nas
    /// provas de retorno atrasado. Sem esta costura, o retorno tardio só se
    /// provaria no aparelho da conta — e o defeito é de concorrência, que
    /// aparelho nenhum reproduz sob encomenda.
    @ObservationIgnored
    var responderNaPagina: (String, String, Gesto?, String) async -> String? = {
        await Sabia.responder(pergunta: $0, contexto: $1, gesto: $2, retrato: $3)
    }


    /// Algum campo da forma tem resposta do autor. Campos recém-criados são
    /// todos vazios: vestir não conta como preencher.
    var camposComResposta: Bool {
        campos.values.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    /// A hora de conferir a decisão já chegou (o "espero" trazia data e ela
    /// passou): só então o campo da volta aparece.
    var conferenciaDevida: Bool { conferenciaDevida(agora: .now) }

    /// Com `agora` explícito: o relógio é parâmetro, não ambiente. A versão que
    /// lia `.now` por dentro tornava o teste dependente da hora da máquina —
    /// ele passava o dia inteiro e reprovava no minuto das 9h.
    func conferenciaDevida(agora: Date) -> Bool {
        // ADR 04v: a regra é uma só, e vive fora — a lista cobra pela mesma
        Volta.devida(gesto: gesto, campos: campos, criadaEm: criadaEmDaPagina, agora: agora)
    }

    /// Quando a nota aberta nasceu — o campo da volta do Dia e da Atualização
    /// olha para isto. Nil na página nova.
    var criadaEmDaPagina: Date?
    /// O calendário, para os encadeamentos que marcam compromisso (ADR 04k).
    /// A raiz liga; nos testes fica nil e o disco recebe direto.
    weak var agenda: CalendarioAgenda?

    /// A pergunta que a sábia fez sobre ESTE texto ao abrir a forma (ADR 03h).
    /// nil = ficou a do template.
    var perguntaDaSabia: String?
    /// Os títulos das notas ligadas que foram junto da última pergunta — o
    /// cartão mostra, porque quem manda texto à rede tem de saber o quê.
    var notasNaPergunta: [String] = []

    /// A linha "?" da nota (ADR o): a pergunta do autor à sábia.
    var perguntaNaNota: String? {
        gesto == .expressiva ? nil : Sabia.perguntaNaNota(texto)
    }

    func analisar(automatica: Bool = false) {
        if timerLigado {
            if !automatica { mostrarToast("a análise cala durante a escrita.") }
            return
        }
        guard !paginaVazia else { return }
        // ADR o: a linha "?" já tem cartão no ar — não o atropela
        if let q = perguntaNaNota {
            if case .resposta(let p, _)? = cartao, p == q { return }
            if case .sabiaPensando? = cartao { return }
        }
        var transacao = Transaction()
        transacao.disablesAnimations = true
        withTransaction(transacao) { cartao = nil }

        let textoAtual = texto
        let gestoAtual = gesto
        let camposAtuais = campos
        analiseTask?.cancel()
        analisando = true
        analiseTask = Task { [weak self] in
            defer { Task { @MainActor in self?.analisando = false } }
            // ADR 2026-08-31e: Grok é o padrão — mas só a VOZ do autor viaja
            // (Caderno.prosa tira mobiliário/anexos), nunca com forma aberta
            // (a lógica pós-forma é local) e nunca expressiva (selo).
            // ADR 2026-09-03k — a escada de três degraus. Grok primeiro quando há
            // conta (é o maior); o modelo DO APARELHO quando não há conta ou
            // quando a rede falhou; as quinze regex por último.
            //
            // O degrau do meio é o que muda a natureza do app: até aqui, sem
            // conta ou sem sinal, o cérebro caía direto para as regex. Agora o
            // Traço pensa no avião, no metrô e sem assinatura — de graça, e sem
            // nada sair do iPhone.
            var remoto: AnaliseLocal.Veredito?
            if gestoAtual == nil {
                remoto = await AnaliseRemota.classificar(texto: Caderno.prosa(de: textoAtual), gestoAtual: gestoAtual)
                if remoto == nil, #available(iOS 26.0, *) {
                    remoto = await AnaliseDeBordo.classificar(
                        texto: Caderno.prosa(de: textoAtual), gestoAtual: gestoAtual)
                }
            }
            guard let self, !Task.isCancelled else { return }
            guard self.texto == textoAtual else { return } // o texto mudou em voo: silêncio
            // §17.2: o autor soltou enquanto o veredito viajava — a nota fica quieta
            if automatica, self.autoSuprimidaNaNota { return }
            // ADR 2026-09-04c: o modelo roteia FORMA; o aviso é do algoritmo,
            // sempre. O degrau do aparelho devolve `.silencio` (não nil) quando
            // não é forma nenhuma — e com `remoto ?? local` isso ENGOLIA as
            // quinze regex: os cinco avisos do §5 ficavam inalcançáveis num
            // iPhone com Apple Intelligence e sem conta, e o aceite do §13
            // ("eu sou um vencedor" → aviso Wood) falhava justamente na
            // configuração padrão. Silêncio do modelo não é veredito.
            let local = AnaliseLocal.classificar(texto: textoAtual, gestoAtual: gestoAtual, campos: camposAtuais)
            // ADR 06h (volta A-B): a guarda da escrita pessoal devolvia
            // `.silencio`, e silêncio tem precedência ZERO aqui — com conta Grok
            // ou Apple Intelligence a proteção era NULA, no caso exato que ela
            // existe para impedir. Quem reconhece a escrita pessoal é o
            // algoritmo, e o algoritmo cala o modelo.
            let veredito = Self.escolher(
                remoto: remoto, local: local,
                pessoal: AnaliseLocal.escritaPessoal(texto: textoAtual, campos: camposAtuais))
            self.aplicar(veredito, automatica: automatica)
        }
    }

    /// ADR 2026-09-04c/04r/06h — quem decide entre o degrau de cima e a regex,
    /// em QUATRO linhas, nesta ordem: aviso local vence sempre; escrita pessoal
    /// reconhecida pelo algoritmo cala o modelo; silêncio do modelo devolve a
    /// palavra ao algoritmo; forma do modelo manda. É a §19.4: o algoritmo
    /// garante, a IA sugere — e o que o algoritmo garante inclui a fronteira da
    /// escrita pessoal, que não é sugestão nenhuma.
    nonisolated static func escolher(remoto: AnaliseLocal.Veredito?,
                                     local: AnaliseLocal.Veredito,
                                     pessoal: Bool = false) -> AnaliseLocal.Veredito {
        // ADR 04r: aviso local vence gesto remoto — o aviso é do algoritmo, sempre
        if case .aviso = local { return local }
        // ADR 06h: desabafo protegido pelo algoritmo não pode ser vestido pelo
        // modelo. O modelo recebe `instrucoesDoCatalogo` e foi ensinado a
        // classificar exatamente estas frases; aqui ele não tem voz.
        if pessoal { return local }
        switch remoto {
        case .none, .some(.silencio): return local
        case .some(let v): return v
        }
    }

    private func aplicar(_ veredito: AnaliseLocal.Veredito, automatica: Bool) {
        switch veredito {
        case .silencio:
            // ADR o: a pergunta do autor entra AQUI, no silêncio — não antes da
            // classificação. Com precedência absoluta, uma linha "?" no meio de
            // uma especificação bloqueava a forma para sempre: o autor não tinha
            // como perguntar e ainda receber o gesto. Agora a forma vem primeiro
            // e o "?" ocupa o rodapé quando não há gesto a vestir (e depois da
            // forma aberta, quando a análise é silêncio de qualquer jeito).
            if let q = perguntaNaNota {
                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { cartao = .pergunta(q) }
                return
            }
            // §17: no modo automático o silêncio é invisível — toast a cada pausa seria ruído
            if !automatica {
                Toque.leve()
                let d = UserDefaults.standard
                if d.bool(forKey: "silencioExplicado") {
                    mostrarToast("silêncio.")
                } else {
                    d.set(true, forKey: "silencioExplicado")
                    // só na primeira vez: o contrato de que silêncio é resposta
                    mostrarToast("silêncio. (sem gesto a vestir, a análise não inventa)")
                }
            }
        case .aviso(let frase):
            Toque.aviso()
            cartao = .aviso(frase)
        case .gesto(let g, let pergunta):
            Toque.leve()
            if !dominioTravado {
                dominio = Dominio.inferir(voz: VozDoAutor.juntar(texto: texto, campos: campos, semCitacao: true))
            }
            if automatica, !Sinais.sugerirEmVezDeVestir(g) {
                // §17.3: gatilho explícito = confiança alta → a forma já vem vestida,
                // com Soltar de um toque. As palavras do autor ficam intactas.
                // ADR 04j: se o autor soltou esta forma três vezes seguidas,
                // ela passa a ser SUGERIDA (o ramo de baixo) até ele abrir uma.
                usarForma(g, explicita: false)
                cartao = .vestida(g, pergunta: pergunta)
                Toque.suave() // o app percebeu você — vibra macio, não estala
                // VoiceOver: a página mudou sozinha — quem não vê precisa saber
                AccessibilityNotification.Announcement("Forma \(g.nome) aberta. Soltar a forma disponível.").post()
            } else {
                cartao = .forma(g, pergunta: pergunta)
            }
        case .expressiva:
            // O timer é compromisso (tranca no fim): NUNCA começa sozinho.
            Toque.leve()
            cartao = .expressiva
            if automatica {
                AccessibilityNotification.Announcement("Sugestão de escrita expressiva aberta.").post()
            }
        }
    }

    /// §17: um toque desfaz o vestir automático — e a nota fica quieta até novo texto.
    /// Soltar NUNCA destrói resposta: o que o autor escreveu nos campos volta ao texto
    /// (a voz fica; só o mobiliário sai).
    func soltarForma() {
        // um veredito em voo (Grok ou bordo, lentos) não pode vestir por cima
        // do Soltar: visto na varredura viva de 04/set — o autor soltou e a
        // forma voltou sozinha um segundo depois
        analiseTask?.cancel()
        autoTask?.cancel()
        if let g = gesto {
            Sinais.solto(g) // ADR 04h: o Soltar deixa de morrer no ar
            let respostas = g.campos.compactMap { campo -> String? in
                let r = campos[campo.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return r.isEmpty ? nil : r
            }
            if !respostas.isEmpty {
                texto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
                    + "\n" + respostas.joined(separator: "\n")
            }
        }
        gesto = nil
        campos = [:]
        cartao = nil
        autoSuprimidaNaNota = true // opt-out POR NOTA (§17.2)
        Toque.leve()
    }
    var autoSuprimidaNaNota = false
    var revisaoPendente: UUID?

    /// Exp 12: abrir a notificação não é revisão — REVELAR é.
    func cumprirRevisaoPendente(no context: ModelContext) {
        guard let uuid = revisaoPendente else { return }
        revisaoPendente = nil
        Revisoes.registrarCumprida(uuid)
        if let nota = Self.buscar(uuid: uuid, no: context) {
            Revisoes.agendar(uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto,
                             trancada: nota.fechada, texto: nota.texto, campos: nota.campos)
        }
    }

    func cobrarAntesPendente() {
        guard let uuid = recordarUUID ?? revisaoPendente else { return }
        Revisoes.cobrarAntes(uuid)
        Toque.leve()
        mostrarToast("volta em 3 dias.")
    }

    /// R1: "hoje não". Empurra para amanhã sem mexer na escada e fecha.
    func adiarPendente() {
        guard let uuid = recordarUUID ?? revisaoPendente else { return }
        Revisoes.adiar(uuid)
        revisaoPendente = nil
        Toque.leve()
        mostrarToast("volta amanhã.")
        mostrarRecordar = false
    }

    /// R2: pular sem revelar. Antes, o botão "próxima" só existia DEPOIS de
    /// revelar — e revelar sobe o degrau. Não havia como passar uma nota da
    /// fila sem mentir para a própria escada.
    func pularDaFila(no context: ModelContext) {
        revisaoPendente = nil // não cumpriu: a escada não anda
        proximaDaFila(no: context)
    }

    var temProximaFila: Bool {
        guard filaAtiva else { return false }
        guard let atual = recordarUUID, let i = filaUUIDs.firstIndex(of: atual) else {
            return false
        }
        return i + 1 < filaUUIDs.count
    }

    func abrirFilaDoDia(no context: ModelContext) {
        let notas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        let fila = Revisoes.filaDoDia(notas: notas)
        filaUUIDs = fila.map(\.uuid)
        filaAtiva = !fila.isEmpty
        guard let primeira = fila.first else {
            mostrarToast("nada a recordar hoje.")
            return
        }
        recordarDaNotas(primeira)
    }

    func proximaDaFila(no context: ModelContext) {
        guard let atual = recordarUUID,
              let i = filaUUIDs.firstIndex(of: atual),
              i + 1 < filaUUIDs.count,
              let nota = Self.buscar(uuid: filaUUIDs[i + 1], no: context)
        else {
            mostrarRecordar = false
            return
        }
        recordarDaNotas(nota)
    }

    // MARK: - §17: análise automática na pausa (o autor nunca precisa lembrar do botão)

    var autoAnalise = UserDefaults.standard.object(forKey: "autoAnalise") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoAnalise, forKey: "autoAnalise") }
    }
    private var autoTask: Task<Void, Never>?

    func agendarAutoAnalise(depois segundos: Double = 1.6) {
        autoTask?.cancel()
        analiseTask?.cancel() // veredito em voo não pode vestir texto que mudou
        // o dedo na régua segura o vestir; se o autor DIGITOU nesse meio tempo,
        // a pausa dele fica guardada e é reposta quando o dedo sai
        if tocandoRegua { pediuAnaliseNaRegua = true }
        guard autoAnalise, !autoSuprimidaNaNota, !tocandoRegua, !timerLigado, !paginaVazia, gesto != .expressiva, cartao == nil else { return }
        autoTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(segundos))
            guard let self, !Task.isCancelled else { return }
            self.analisar(automatica: true)
        }
    }

    /// §17 × dedo a caminho da régua: enquanto o dedo TOCA a régua (toque em
    /// voo), o vestir automático fica preso — a forma não veste no meio do
    /// alcance e o chip que o dedo mira não salta (a régua some quando o cartão
    /// entra). Solta com um respiro DEPOIS do toque, porque a ordem entre o fim
    /// do gesto e a ação do chip no soltar é indefinida.
    private(set) var tocandoRegua = false
    /// O autor digitou enquanto o dedo estava na régua: a pausa dele não se perde.
    private var pediuAnaliseNaRegua = false
    func tocarRegua(_ tocando: Bool) {
        if tocando {
            tocandoRegua = true
            pediuAnaliseNaRegua = false
            autoTask?.cancel() // um veredito em voo não pode vestir sob o dedo
        } else {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(250))
                tocandoRegua = false
                // só quem DIGITOU durante o respiro recupera a pausa perdida.
                // Reagendar sempre fazia o cartão entrar e a régua sumir com o
                // dedo ainda a caminho do chip (cenário U3, dedo em voo).
                if pediuAnaliseNaRegua {
                    pediuAnaliseNaRegua = false
                    agendarAutoAnalise()
                }
            }
        }
    }

    func alternarAutoAnalise() {
        autoAnalise.toggle()
        autoTask?.cancel()
        mostrarToast(autoAnalise ? "análise automática ligada." : "análise automática desligada.")
    }

    /// "Vestir a nota" (FILA P1): um toque estrutura a nota INTEIRA (título,
    /// listas, seções) a partir do que o autor já escreveu. A IA não escreve —
    /// `Caderno.estruturar` só veste a forma em volta das palavras dele. Um
    /// cartão em voo é cancelado para não cobrir a nota recém-vestida.
    // MARK: ADR o — a sábia

    /// As notas que ESTA página liga com `[[…]]`, para irem junto da pergunta.
    ///
    /// Uma pessoa sábia ao lado de quem escreve leu o que a pessoa já escreveu
    /// — a sábia lia só a página aberta. O que viaja não é o caderno inteiro:
    /// é o que o AUTOR ligou de próprio punho, e ligar é ato explícito dele.
    ///
    /// O selo manda: `Rede.podeLigar` já corta expressiva (em curso ou
    /// fechada), trancada e queimada. Mesmo filtro da Rede, mesma regra de
    /// casamento — nenhuma lógica nova que pudesse divergir do selo.
    func notasLigadas(no context: ModelContext, teto: Int = 3) -> [(uuid: UUID, titulo: String, prosa: String)] {
        guard !Rede.mencoes(texto).isEmpty else { return [] }
        let todas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        let lidas = todas.map(\.paraRede)
        // a página aberta ainda não é nota: entra como uma, para reusar o
        // casamento de `ligacoes` em vez de reescrevê-lo aqui
        let euUUID = notaUUID ?? UUID()
        // título vazio de propósito: `ligacoes` pula chave vazia ao indexar
        // alvos, então a página é só ORIGEM — nunca vira destino de si mesma
        // nem rouba o casamento de uma nota de verdade.
        // a página aberta é o autor digitando agora — o bot não digita aqui
        let eu = Rede.NotaLida(uuid: euUUID, titulo: "", texto: texto, campos: campos,
                               gesto: gesto, fechada: false, expressivaEmCurso: false,
                               vozDoAutor: true)
        let ligacoes = Rede.daqui(euUUID, Rede.ligacoes(lidas.filter { $0.uuid != euUUID } + [eu]))
        var saida: [(uuid: UUID, titulo: String, prosa: String)] = []
        for l in ligacoes.prefix(teto) {
            guard let n = todas.first(where: { $0.uuid == l.para }) else { continue }
            let prosa = Caderno.prosa(de: n.texto).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !prosa.isEmpty else { continue }
            // ADR 2026-09-10g: a nota que o autor CITOU vai INTEIRA. O corte
            // era aqui, aos 1.200, e ele acontecia ANTES de o orçamento ser
            // consultado: quem escrevia `[[Relatório]]` mandava um começo de
            // documento sem que nada dissesse que era um começo — e o modelo
            // completava o resto. Quem decide o que cabe é
            // `Sabia.contextoDaPergunta`, que sabe o orçamento inteiro e
            // DECLARA o que sacrificou. Duas tesouras cortando o mesmo texto,
            // e só uma sabendo dizer que cortou, era a cúmplice do defeito.
            saida.append((n.uuid, n.tituloNaLista, prosa))
        }
        return saida
    }

    /// O caderno que vai junto da pergunta (ADR 2026-09-03m): o que o autor
    /// LIGOU, mais o que ele não ligou e fala da mesma coisa.
    ///
    /// A ligação explícita é o que ele sabe que se conecta. O eco é o que ele
    /// esqueceu que escreveu — e é justamente aí que mora o valor de ter um
    /// segundo cérebro em vez de uma página. Sem isto a sábia respondia lendo
    /// só a página aberta e a nota que ele lembrou de citar.
    ///
    /// O selo corta antes, nos dois caminhos: `Rede.podeLigar` nas ligadas,
    /// `fechada`/expressiva nas candidatas a eco.
    /// Quantas notas do caderno foram LIDAS pela rede na última pergunta —
    /// não as que voltaram. O cartão dizia só as que voltaram (3), enquanto o
    /// índice de até 40 viajava: quem manda texto à rede tem de ver o quanto.
    var notasLidasNaPergunta = 0

    /// O que a rede viu, em uma linha: quantas notas foram lidas em índice
    /// (título + 240 caracteres) e quais foram inteiras.
    var divulgacaoDaPergunta: String {
        var partes: [String] = []
        if notasLidasNaPergunta > 0 {
            partes.append(notasLidasNaPergunta == 1
                ? "leu o começo de 1 nota sua"
                : "leu o começo de \(notasLidasNaPergunta) notas suas")
        }
        if !notasNaPergunta.isEmpty {
            partes.append("foram junto: " + notasNaPergunta.joined(separator: " · "))
        }
        return partes.joined(separator: " · ")
    }

    func contextoDoCaderno(no context: ModelContext, pergunta: String = "") async -> [(uuid: UUID, titulo: String, prosa: String)] {
        var saida = notasLigadas(no: context)
        var jaTem = Set(saida.map(\.titulo))
        let todas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        let podem = todas.filter {
            $0.uuid != notaUUID && !$0.fechada && $0.gesto != .expressiva
                && !Caderno.prosa(de: $0.texto).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        // ADR 04n: as seis mais próximas da PERGUNTA vão inteiras (600 chars)
        if !pergunta.isEmpty {
            let excluir = Set(saida.compactMap { t in podem.first { $0.tituloNaLista == t.titulo }?.uuid })
            for v in Indice.vizinhas(de: pergunta, teto: 6, exceto: excluir.union([notaUUID].compactMap { $0 })) {
                guard let n = podem.first(where: { $0.uuid == v.uuid }), !jaTem.contains(n.tituloNaLista) else { continue }
                let prosa = Caderno.prosa(de: n.texto).trimmingCharacters(in: .whitespacesAndNewlines)
                saida.append((n.uuid, n.tituloNaLista, String(prosa.prefix(600))))
                jaTem.insert(n.tituloNaLista)
            }
        }
        // A rota `ecos` está cortada (08q). Sem este portão o contexto da
        // Página ainda montava 40 candidatas e chamava `Sabia.ecos` — `chamar`
        // devolvia nil sem rede, mas o caminho ficava minado: se `responder`
        // voltasse e `ecos` não, a pergunta dispararia a rota morta e a
        // divulgação diria que leu o começo de notas que ninguém viu.
        guard Politica.provedor(.ecos) != nil else {
            notasLidasNaPergunta = 0
            return saida
        }
        // ADR 04n: as candidatas a eco são as 40 mais PRÓXIMAS desta nota, não
        // as 40 primeiras de um fetch sem ordem — e só quando há índice
        let proximas = Indice.vizinhas(de: Caderno.prosa(de: texto), teto: 40, minimo: 0.15,
                                       exceto: Set([notaUUID].compactMap { $0 }))
        let ordem = Dictionary(uniqueKeysWithValues: proximas.enumerated().map { ($0.element.uuid, $0.offset) })
        let candidatas = podem
            .filter { !jaTem.contains($0.tituloNaLista) }
            .filter { ordem.isEmpty || ordem[$0.uuid] != nil }
            .sorted { (ordem[$0.uuid] ?? .max) < (ordem[$1.uuid] ?? .max) }
            .prefix(40).map { $0 }
        notasLidasNaPergunta = candidatas.count
        guard !candidatas.isEmpty else { return saida }
        let linhas = candidatas.map {
            "\($0.tituloNaLista) :: \(Caderno.prosa(de: $0.texto).prefix(240))"
        }
        guard let ecos = await Sabia.ecos(nota: Caderno.prosa(de: texto),
                                          candidatas: linhas, gesto: gesto)
        else { return saida }
        for eco in ecos where eco.i < candidatas.count {
            let n = candidatas[eco.i]
            let prosa = Caderno.prosa(de: n.texto).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !prosa.isEmpty else { continue }
            saida.append((n.uuid, n.tituloNaLista, String(prosa.prefix(1200))))
        }
        return saida
    }

    /// Responde a linha "?" num cartão. Sem conta, diz que precisa dela.
    ///
    /// ADR 2026-09-10b: `disponivel` e `aviso` chegam por parâmetro, com o
    /// padrão da produção — mesmo desenho de `ConversaNotas.perguntar(disponivel:)`.
    /// Sem isto o corpo desta função era INALCANÇÁVEL pela suíte: no simulador
    /// de teste não há conta Grok e `Motores.desligados` derruba o aparelho, de
    /// modo que toda chamada parava na primeira linha. Foi por isso que o
    /// retorno tardio e a divulgação torta atravessaram sete voltas sem teste.
    @discardableResult
    func perguntarASabia(no context: ModelContext,
                         disponivel: Bool = Sabia.disponivel,
                         aviso: String? = Politica.aviso(.responder)) -> Task<Void, Never>? {
        guard let q = perguntaNaNota, gesto != .expressiva else { return nil }
        guard disponivel else {
            cartao = .semConta
            return nil
        }
        // ADR 2026-09-09q: `responder` está indisponível por qualidade desde a
        // 08q. Com a conta ligada a rota girava o laço, batia em `nil` dentro
        // de `Sabia.chamar` e o toast dizia "tente de novo" — convite a repetir
        // o que nunca vai dar certo. A frase honesta já existia em `Politica`
        // e nenhuma tela a mostrava. A pergunta volta ao cartão, como no
        // cancelamento da 09n: o que ele escreveu não se perde.
        if let aviso {
            cartao = .pergunta(q)
            mostrarToast(aviso, duracao: .seconds(8))
            return nil
        }
        // a resposta tem até 900 caracteres e o teclado cobria metade dela
        // (visto na primeira chamada real, 03/set). Quem pergunta vai LER.
        Teclado.recolher()
        cartao = .sabiaPensando(pergunta: q, desde: .now)
        let g = gesto
        let retrato = retratoAtual()
        // ADR 2026-09-10b: a PÁGINA se lê agora, junto da pergunta. Lê-la
        // depois do await é ler a nota que o autor abriu enquanto esperava —
        // com o teto do modelo em minutos, isso deixou de ser hipótese.
        let pagina = Caderno.prosa(de: texto)
        // Uma tentativa pertence à pergunta que a iniciou (mesmo padrão de
        // `ConversaNotas.tentativa`): cancelar ajuda o serviço, a identidade
        // impede o efeito tardio mesmo se ele ignorar o cancelamento. O guarda
        // antigo exigia só ALGUM `.sabiaPensando`, e "algum" inclui a pergunta
        // seguinte — o cartão podia responder à pergunta que já não é a atual.
        let id = UUID()
        perguntaAtual = id
        perguntaTask?.cancel()
        let nova = Task { [weak self] in
            guard let self else { return }
            let doCaderno = await self.contextoDoCaderno(no: context, pergunta: q)
            guard self.perguntaAtual == id else { return }
            // As fontes com assinatura, para revalidar ANTES de publicar: selar,
            // apagar ou editar uma vizinha durante a espera revoga o que ela
            // emprestou. Mesma guarda do `responderNasNotas` (`dependenciasValidas`).
            let fontes = self.fontesDoContexto(doCaderno, no: context)
            let (contexto, viajaram) = Sabia.contextoDaPergunta(
                pagina: pagina, vizinhas: doCaderno.map { (titulo: $0.titulo, prosa: $0.prosa) })
            // o cartão diz o que viajou: quem manda texto à rede tem de saber
            // qual — e só o que COUBE viajou (ADR 10b).
            self.notasNaPergunta = viajaram
            let r = await self.responderNaPagina(q, contexto, g, retrato)
            guard self.perguntaAtual == id else { return }
            self.perguntaAtual = nil
            self.perguntaTask = nil
            guard Self.dependenciasValidas(fontes, no: context) else {
                self.notasNaPergunta = []
                self.cartao = .pergunta(q)
                self.mostrarToast("uma nota que ia junto mudou. a sua pergunta continua aqui.", duracao: .seconds(8))
                return
            }
            if let r {
                self.cartao = .resposta(pergunta: q, texto: r)
                Toque.suave()
            } else {
                // ADR 2026-09-10b: a falha FICA junto da pergunta. Era
                // `cartao = nil` mais um toast que passa — depois de minutos de
                // espera, o autor voltava à página sem cartão nenhum e sem
                // caminho de volta. `.pergunta(q)` é o mesmo cartão do
                // cancelamento (09n): "Perguntar à sábia" a um toque.
                self.notasNaPergunta = []
                self.cartao = .pergunta(q)
                self.mostrarToast(Grok.avisoDaFalha(), duracao: .seconds(8))
            }
        }
        perguntaTask = nova
        return nova
    }

    /// As fontes que sustentam o contexto da linha "?" — com assinatura, para
    /// `dependenciasValidas` decidir se ainda valem quando a resposta chega.
    func fontesDoContexto(_ vizinhas: [(uuid: UUID, titulo: String, prosa: String)],
                          no context: ModelContext) -> [FonteNotas] {
        guard !vizinhas.isEmpty, let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return [] }
        let porID = Dictionary(uniqueKeysWithValues: notas.map { ($0.uuid, $0) })
        return vizinhas.compactMap { porID[$0.uuid].flatMap(Self.fonteParaPergunta) }
    }

    /// ADR 2026-09-09n: quem espera pode parar de esperar. O que a pessoa
    /// escreveu não se perde — a pergunta volta ao cartão `.pergunta`, com
    /// "Perguntar à sábia" a um toque, e a linha "?" nunca saiu da nota.
    func pararDeEsperarASabia() {
        guard case .sabiaPensando(let q, _)? = cartao else { return }
        perguntaAtual = nil
        perguntaTask?.cancel()
        perguntaTask = nil
        cartao = .pergunta(q)
    }

    // MARK: ADR 05e — perguntar nas Notas

    /// ADR 09c: a conversa é da SESSÃO, não da view. `RaizView` recria a
    /// `NotasView` a cada troca de aba do arquivo (o `switch` de `abaArquivo`),
    /// e com o `@State` morria a conversa inteira — a pergunta que a pessoa
    /// estava esperando sumia sem que nada dissesse. `interromper()` já dizia
    /// "sair da tela não perde o pedido interrompido"; era o `@State` que
    /// desmentia. Aqui em cima o objeto vive enquanto a sessão viver, e todo
    /// estado dela vem junto: a pergunta guardada, as trocas já respondidas, o
    /// aviso de "sem conta" e a busca que a pessoa estava escrevendo.
    let conversaNotas = ConversaNotas()

    nonisolated struct TrocaNasNotas: Equatable, Sendable {
        var pergunta: String
        var resposta: String
        var dependencias: [FonteNotas] = []
    }

    /// ADR 09b: a nota do bot continua citável — ela está no caderno e o autor
    /// pode perguntar sobre ela —, mas a origem viaja no TÍTULO: a citação na
    /// tela e a fonte no prompt dizem "feito pelo bot" em vez de devolverem o
    /// texto do bot como se fosse a voz de quem escreveu.
    static func fonteParaPergunta(_ nota: Nota) -> FonteNotas? {
        guard !nota.fechada, nota.gesto != .expressiva, nota.temVoz else { return nil }
        // a obra viaja crua: `prosa` tiraria os `## ` que separam as regras
        let obra = nota.origem.eObra
        let prosa = (obra ? nota.texto : nota.textoDeQualquerOrigem).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prosa.isEmpty else { return nil }
        let titulo = nota.tituloNaLista + (nota.origem.etiqueta.map { " · \($0)" } ?? "")
        // A voz junta campos; sua ordem não é identidade. Assinatura usa a
        // representação guardada para detectar edição mesmo sem mudar a data.
        let dados = try! JSONEncoder().encode([nota.texto, nota.camposJSON, nota.sentido,
                                               nota.gestoRaw ?? "", nota.tituloNaLista])
        let assinatura = SHA256.hash(data: dados).map { String(format: "%02x", $0) }.joined()
        return FonteNotas(id: nota.uuid, titulo: titulo, texto: prosa,
                          editadaEm: nota.editadaEm, assinatura: assinatura, obra: obra,
                          obraConferida: nota.origem == .obra)
    }

    static func dependenciasValidas(_ fontes: [FonteNotas], no context: ModelContext) -> Bool {
        guard !fontes.isEmpty else { return true }
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return false }
        let porID = Dictionary(uniqueKeysWithValues: notas.map { ($0.uuid, $0) })
        return fontes.allSatisfy { fonte in
            guard let nota = porID[fonte.id], let atual = fonteParaPergunta(nota),
                  let assinatura = fonte.assinatura else { return false }
            return assinatura == atual.assinatura && fonte.editadaEm == atual.editadaEm
        }
    }

    /// O histórico derivado de uma nota revogada ou editada não volta ao
    /// modelo. Perguntas e correções das trocas restantes seguem inteiras.
    static func conversaValida(_ conversa: [TrocaNasNotas], no context: ModelContext) -> [TrocaNasNotas] {
        conversa.filter { dependenciasValidas($0.dependencias, no: context) }
    }

    func contextoDasNotas(pergunta: String, no context: ModelContext, teto: Int = 8) -> [FonteNotas] {
        let vizinhas = Indice.vizinhas(de: pergunta, teto: teto, minimo: 0.15)
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return [] }
        let porID = Dictionary(uniqueKeysWithValues: notas.map { ($0.uuid, $0) })
        // ADR 2026-09-16c: a obra não disputa as vagas das notas por palavra
        // (um dossiê tem todas as palavras); entra depois, pelas suas seções
        var fontes = vizinhas.compactMap { v in porID[v.uuid].flatMap { $0.origem.eObra ? nil : Self.fonteParaPergunta($0) } }
        // 15/09, com a conta ligada: "o que eu decidi sobre o plano de celular?"
        // foi ao Grok SEM a nota "Decidir se troco de plano de celular" — só o
        // índice de sentido escolhia as fontes, e sem ele (ou com ele a perder a
        // nota) a sábia respondia "não há registro". As notas que têm as
        // PALAVRAS da pergunta (a mesma régua da busca) entram depois das
        // vizinhas, até o teto.
        if fontes.count < teto {
            let ja = Set(vizinhas.map(\.uuid))
            let porPalavra = notas
                .filter { !$0.origem.eObra && !ja.contains($0.uuid) && NotasFiltro.casa($0.textoDeQualquerOrigem, busca: pergunta) }
                .sorted { $0.editadaEm > $1.editadaEm }
                .prefix(teto - fontes.count)
                .compactMap(Self.fonteParaPergunta)
            fontes += porPalavra
        }
        // a obra entra se a pergunta toca DE FATO uma seção (dois radicais dela,
        // sem contar a ponte de sinônimos); a suposta sem seções, pela palavra
        let obras = notas.filter { $0.origem.eObra }.compactMap(Self.fonteParaPergunta).filter { fonte in
            Obra.secoesEmCache(fonte.texto).isEmpty
                ? NotasFiltro.casa(fonte.texto, busca: pergunta)
                : Obra.ranquear(pergunta: pergunta, texto: fonte.texto).contains(where: Obra.admite)
        }
        return Self.semRepetida(fontes + obras)
    }

    /// DIRETRIZ §14: o dono viu a MESMA nota três vezes em "Foram junto:". A
    /// raiz não era a tela — o aparelho da conta tinha três notas com o texto
    /// idêntico (`ZNOTA` do teste 3, 10/09), e três notas iguais são três
    /// vizinhas iguais no índice, com a mesma proximidade. Mandar as três ao
    /// modelo é ruído no pedido e ruído na tela; quem duplica é a montagem, e é
    /// ela que deixa de duplicar. Fica a primeira (a mais próxima), pelo TEXTO:
    /// duas notas com o mesmo texto são a mesma fonte para a pergunta.
    static func semRepetida(_ fontes: [FonteNotas]) -> [FonteNotas] {
        var vistos = Set<String>()
        return fontes.filter { vistos.insert($0.texto).inserted }
    }

    /// Injeção somente da operação de IA; seleção e revalidação de acesso
    /// permanecem as mesmas no app e nas provas de retorno atrasado.
    var responderContextoNotas: (String, [FonteNotas], [TrocaNasNotas], String, String, ([FonteNotas]) -> Bool) async -> RespostaNotas.Retorno? = {
        await Sabia.responderNasNotas(pergunta: $0, fontes: $1, conversa: $2, catalogo: $3, retrato: $4, validarAcesso: $5)
    }

    func responderNasNotas(_ pergunta: String, conversa: [TrocaNasNotas],
                           no context: ModelContext) async -> ConversaNotas.Resultado {
        let validas = Self.conversaValida(conversa, no: context)
        let fontes = contextoDasNotas(pergunta: pergunta, no: context)
        // Retrato também deriva das notas: monte do estado autorizado atual e
        // guarde suas dependências, inclusive quando não são fontes citadas.
        let notas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        let fontesDoRetrato = notas.compactMap(Self.fonteParaPergunta)
        let trabalhos = (try? context.fetch(FetchDescriptor<Trabalho>())) ?? []
        let observados = AcessoTrabalho.juizosObservados(de: trabalhos, no: context)
        let retrato = Retrato.ligado
            ? Retrato.ler(notas: notas.map(\.paraRetrato), sinais: Sinais.todos(),
                          observados: observados) : ""
        let catalogo = Catalogo.todos.filter { $0.id != Gesto.expressiva.rawValue }
            .map { "\($0.nome): \($0.definicao)" }.joined(separator: "\n")
        let retorno = await responderContextoNotas(pergunta, fontes, validas, catalogo, retrato) { enviadas in
            Self.dependenciasValidas(validas.flatMap(\.dependencias) + enviadas
                + (retrato.isEmpty ? [] : fontesDoRetrato), no: context)
        }
        var dependencias = validas.flatMap(\.dependencias) + (retorno?.enviadas ?? [])
        if !retrato.isEmpty { dependencias += fontesDoRetrato }
        var vistos = Set<UUID>()
        dependencias = dependencias.filter { vistos.insert($0.id).inserted }
        let aindaValidas = Self.conversaValida(validas, no: context)
        let fontesValidas = Self.dependenciasValidas(dependencias, no: context)
        guard !Task.isCancelled, let retorno, fontesValidas else {
            return .init(resposta: nil, conversaValida: aindaValidas, fontesMudaram: !fontesValidas)
        }
        let avisoHistorico = validas.count == conversa.count ? ""
            : "\n\nParte da conversa anterior ficou fora desta consulta porque suas fontes mudaram ou deixaram de estar acessíveis."
        return .init(resposta: retorno.texto + avisoHistorico, fontes: retorno.enviadas,
                     dependencias: dependencias, fontesCitadas: retorno.citadas,
                     conversaValida: aindaValidas,
                     obraParaPlantar: retorno.obraParaPlantar)
    }

    /// Fase 0: aceite da guarda de obra. A nota é o nome que ela pediu —
    /// origem dela, sem tese inventada. Sem aceite não há cânone.
    @discardableResult
    func plantarObra(_ nome: String, no context: ModelContext) -> Nota? {
        guard let texto = GuardaDeObra.textoPlantado(nome) else { return nil }
        let nota = Nota(texto: texto)
        nota.dominio = Dominio.inferir(voz: nota.vozDoAutor)
        context.insert(nota)
        guard persistir(context) else {
            mostrarToast("não consegui plantar — a obra não entrou.")
            return nil
        }
        // A próxima pergunta lê o índice e o holofote: sem projeção a obra
        // plantada existe no disco e some da consulta. Persistência falhou
        // não chega aqui — o selo das outras notas segue em `paraIndice`.
        Indice.atualizar(Self.paraIndice(nota), geracao: Geracao.proxima())
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) { projetarTudo(todas) }
        mostrarToast("obra plantada.")
        Toque.leve()
        return nota
    }

    /// Veste o texto inteiro: motor local agora; a sábia, se ligada, refina
    /// com um mapa de rótulos. Nenhuma palavra muda. Um toque desfaz.
    func vestirTudo() {
        guard !paginaVazia, gesto != .expressiva else { return }
        autoTask?.cancel()
        let antes = texto
        let local = Caderno.estruturar(texto)
        if local != texto {
            texto = local
            cartao = .vestido(antes: antes)
            Toque.fechou()
        }
        guard Sabia.disponivel else {
            if local == antes { mostrarToast("nada a vestir aqui.") }
            return
        }
        let base = texto
        let g = gesto
        // ADR 2026-09-09q: quando o motor local não mexeu em nada, o autor está
        // esperando a sábia — e ela falhava calada. Sem conta ele já ouvia
        // "nada a vestir aqui."; COM conta, um toque em Vestir tudo podia não
        // produzir nada e nem uma palavra.
        let nadaLocal = local == antes
        Task { [weak self] in
            let mapa = await Sabia.vestir(blocos: Sabia.blocos(antes), gesto: g)
            guard let self, self.texto == base else { return } // o autor mexeu: silêncio
            guard let mapa else {
                if nadaLocal { self.mostrarToast(Grok.avisoDaFalha()) }
                return
            }
            // Emenda à ADR 2026-09-09s: mapa VAZIO é a sábia tendo respondido e
            // o nosso contrato tendo recusado o que veio. Dizer "não respondeu"
            // sobre um 200 inteiro era o defeito; dizer "nada a vestir aqui."
            // seria a outra metade da mentira — havia o que vestir.
            guard !mapa.isEmpty else {
                if nadaLocal { self.mostrarToast(Sabia.nadaVestiu) }
                return
            }
            let refinado = Sabia.aplicar(mapa, a: antes)
            guard refinado != base, refinado != antes else {
                if nadaLocal { self.mostrarToast("nada a vestir aqui.") }
                return
            }
            self.texto = refinado
            self.cartao = .vestido(antes: antes)
            Toque.suave()
        }
    }

    func desfazerVestir(_ antes: String) {
        texto = antes
        cartao = nil
        Toque.leve()
    }

    /// `explicita` = o autor abriu (cartão, encadeamento, Padrões). A pausa
    /// veste com `false` e NÃO instiga: abundante no ato, calada na pausa
    /// (ADR 04r). O instigar da forma vestida sozinha chega quando ele toca
    /// nela — `instigarSePreciso`.
    func usarForma(_ g: Gesto, explicita: Bool = true) {
        gesto = g
        campos = Dictionary(uniqueKeysWithValues: g.campos.map { ($0.id, "") })
        cartao = nil
        Toque.leve()
        instigou = false
        if explicita { instigarSePreciso() }
    }

    /// Uma instigação por forma aberta. Chamada pelo ato: abrir os campos,
    /// o primeiro caractere num campo, abrir a forma pelo cartão.
    private var instigou = false
    func instigarSePreciso() {
        guard let g = gesto, !instigou else { return }
        instigou = true
        instigarSobreAForma(g)
    }

    /// A pergunta da forma era uma de nove strings fixas: toda spec que o autor
    /// já escreveu ouviu a MESMA frase. A lei do dono é outra — "instiga,
    /// pergunta, e eu construo enquanto aprendo" — e `Sabia.instigar` já existe,
    /// com verificação dura (só entra o que termina em "?").
    ///
    /// Dispara ao ABRIR a forma, não a cada pausa: abrir é ato explícito, uma
    /// vez por nota, e é exatamente onde a pergunta vale. Falhou, veio vazio ou
    /// não há conta: fica a do template. Silêncio é resposta válida (§19.4).
    func instigarSobreAForma(_ g: Gesto) {
        perguntaDaSabia = nil
        guard g != .expressiva, Sabia.disponivel else { return }
        // A Lente já mostra `Politica.aviso(.instigar)`. Abrir a forma é
        // automático — como classificar, o silêncio é a resposta. Sem este
        // portão a conta ligada disparava `Sabia.instigar` na rota cortada e
        // `chamar` devolvia nil; a pergunta do template cobria, e a volta da
        // rota religaria o disparo sozinho.
        guard Politica.aviso(.instigar) == nil else { return }
        let prosa = Caderno.prosa(de: texto)
        guard prosa.count >= 80 else { return } // texto curto não tem buraco a apontar
        let geracao = geracaoDaPagina
        // ADR 04j: o degrau sobe com a prática nesta forma; ADR 04i: a sábia
        // sabe quem escreve
        let sinais = Sinais.todos()
        let degrau = Degraus.instigar(g, sinais: sinais) // ADR 04x: ouve o sinal
        let retrato = retratoAtual(sinais: sinais)
        Task { [weak self] in
            let r = await Sabia.instigar(texto: prosa, gesto: g, degrau: degrau, retrato: retrato)
            guard let self, self.geracaoDaPagina == geracao, self.gesto == g else { return }
            self.perguntaDaSabia = r?.first
        }
    }

    // MARK: ADR 04i — o retrato

    /// As notas do disco, lidas para o retrato. A view injeta (`notasParaRetrato`)
    /// porque a sessão não guarda um contexto; nos testes fica vazio.
    var notasParaRetrato: () -> [Retrato.NotaLida] = { [] }
    /// Juízos de Trabalhos que a view já passou por `AcessoTrabalho`.
    var observadosParaRetrato: () -> [Retrato.JuizoObservado] = { [] }

    /// O bloco SOBRE QUEM ESCREVE — vazio quando desligado, sem conta, ou sem nada.
    func retratoAtual(sinais: [Sinal]? = nil) -> String {
        guard Retrato.ligado, Sabia.disponivel else { return "" }
        return Retrato.ler(notas: notasParaRetrato(), sinais: sinais ?? Sinais.todos(),
                           observados: observadosParaRetrato())
    }

    /// O autor disse se a pergunta da forma serviu (ADR 04h).
    func avaliarPergunta(_ texto: String, serviu: Bool) {
        Sinais.pergunta(texto, forma: gesto, serviu: serviu)
        Toque.leve()
    }

    func avaliarResposta(_ texto: String, serviu: Bool) {
        Sinais.resposta(texto, forma: gesto, serviu: serviu)
        Toque.leve()
    }

    // MARK: ADR 04k — os encadeamentos

    /// Da forma aberta para a próxima, com as palavras do autor copiadas e o
    /// `[[título]]` da origem no destino. A IA não escreve nada aqui.
    func encadear(_ e: Metodo.Encadeamento, no context: ModelContext, agora: Date = .now) {
        guard let g = gesto, g != .expressiva, salvar(no: context) else { return }
        // ADR 16d (revisão): "Pré-mortem do que decidi" grava e sai sem
        // concluir — a Decisão com o ato escrito é consultada aqui também
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) { Self.registrarConselho(nota, no: context) }
        let origemCampos = campos
        let origemTitulo = VozDoAutor.titulo(texto, gesto: g, campos: campos)
        if let c = e.compromisso {
            let frase = (origemCampos[c.campo] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !frase.isEmpty else { return }
            let cal = Calendario.gregoriano()
            let dia = cal.date(byAdding: .day, value: c.dias, to: Calendario.inicioDoDia(agora, cal)) ?? agora
            let inicio = Calendario.hora(Ancora.hora(.manha), 0, no: dia, cal)
            let evento = EventoCalendario(titulo: c.titulo + String(frase.prefix(80)), inicio: inicio,
                                          fim: inicio.addingTimeInterval(1800),
                                          notas: origemTitulo.isEmpty ? "" : "[[\(origemTitulo)]]")
            // ADR 06d: onde o dado que o widget mostra muda, o widget é
            // recarregado. `agenda.guardar` já republica E agenda o alarme;
            // sem agenda em cena (encadeamento a partir da página) o
            // compromisso ia ao disco, o widget desenhava o sino e o toast
            // dizia "com aviso" — sem NINGUÉM ter agendado nada (revisão G3,
            // A2). Aqui a superfície sai MUDA e a promessa só é feita depois
            // que o iOS aceitou.
            let f = DateFormatter()
            f.locale = Locale(identifier: "pt_BR")
            f.dateFormat = "EEEE d, HH:mm"
            let marcado = "marcado para \(f.string(from: inicio))"
            if let agenda {
                agenda.guardar(evento)
                mostrarToast(marcado)
            } else {
                var lista: [EventoCalendario]
                if case .eventos(let atual) = CalendarioDisco.carregar() {
                    lista = atual
                    lista.append(evento)
                } else {
                    lista = [evento]
                }
                try? CalendarioDisco.gravar(lista)
                ProximoCompromisso.publicar(ProximoCompromisso.comAcoesDoTrabalho(lista),
                                            cal: cal, mudo: evento.id)
                mostrarToast(marcado)
                agendarEContar(evento, em: lista, cal: cal, marcado: marcado)
            }
            Toque.suave()
            return
        }
        guard let para = e.para, let destino = Gesto(rawValue: para), destino.conhecido else { return }
        novaPagina()
        usarForma(destino, explicita: true)
        for (campoDestino, campoOrigem) in e.mapa {
            let v = (origemCampos[campoOrigem] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !v.isEmpty, destino.campos.contains(where: { $0.id == campoDestino }) { campos[campoDestino] = v }
        }
        if !origemTitulo.isEmpty {
            let liga = "[[\(origemTitulo)]]"
            if destino.campos.contains(where: { $0.id == "liga" }) {
                campos["liga"] = liga
            } else {
                texto = liga
            }
        }
        irPara(.escrever, no: context)
        mostrarToast("\(destino.nome) aberta com as suas palavras" + (origemTitulo.isEmpty ? "" : " · ligada a “\(VozDoAutor.truncar(origemTitulo, 28))”"))
        Toque.suave()
    }

    /// As linhas da nota que trazem dia E hora viram compromissos, uma vez
    /// cada (mesmo título e mesma hora não entram duas vezes). Toast com o
    /// que entrou; a ficha não abre — a pessoa está a concluir, não a marcar.
    func marcarCompromissosDaNota(agora: Date = .now) {
        marcarCompromissos(em: texto, agora: agora, prefixoDoToast: "guardada · ")
    }

    /// O que traz dia E hora vira compromisso sozinho — da nota ao concluir e
    /// de qualquer frase dita no campo das Notas (dono, 14/09: o campo fala
    /// com a IA, então recebe qualquer coisa: buscar, perguntar, pedir). Uma
    /// frase com vários ("dentista amanhã 14h e correr terça 6h") marca todos
    /// quando TODAS as partes têm dia e hora. Devolve quantos marcou.
    @discardableResult
    func marcarCompromissos(em prosa: String, agora: Date = .now, prefixoDoToast: String = "") -> Int {
        let cal = Calendario.gregoriano()
        let (m, t, n) = (Ancora.hora(.manha), Ancora.hora(.tarde), Ancora.hora(.noite))
        func datado(_ s: Substring) -> EventoCalendario? {
            CalendarioFrase.lerDatado(String(s), agora: agora, cal, manha: m, tarde: t, noite: n)
        }
        var novos = prosa.split(whereSeparator: \.isNewline).compactMap(datado)
        if novos.isEmpty {
            let partes = prosa.replacingOccurrences(of: "\\s+e\\s+", with: "\n", options: .regularExpression)
                .split(whereSeparator: { $0 == "\n" || $0 == ";" || $0 == "," })
            let lidos = partes.compactMap(datado)
            if partes.count > 1, lidos.count == partes.count { novos = lidos }
        }
        guard !novos.isEmpty else { return 0 }
        var lista: [EventoCalendario] = []
        if let agenda { lista = agenda.eventos } else if case .eventos(let atual) = CalendarioDisco.carregar() { lista = atual }
        let existentes = Set(lista.map { $0.titulo.lowercased() + "@" + String(Int($0.inicio.timeIntervalSince1970)) })
        let ineditos = novos.filter { !existentes.contains($0.titulo.lowercased() + "@" + String(Int($0.inicio.timeIntervalSince1970))) }
        guard !ineditos.isEmpty else { return 0 }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE d, HH:mm"
        if let agenda {
            for e in ineditos { agenda.guardar(e) }
        } else {
            lista.append(contentsOf: ineditos)
            try? CalendarioDisco.gravar(lista)
            ProximoCompromisso.publicar(ProximoCompromisso.comAcoesDoTrabalho(lista), cal: cal, mudo: nil)
            for e in ineditos { agendarEContar(e, em: lista, cal: cal, marcado: "\(e.titulo) marcado para \(f.string(from: e.inicio))") }
        }
        if ineditos.count == 1, let e = ineditos.first {
            mostrarToast("\(prefixoDoToast)\(e.titulo) marcado para \(f.string(from: e.inicio))")
        } else {
            mostrarToast("\(prefixoDoToast)\(ineditos.count) compromissos marcados")
        }
        Toque.suave()
        return ineditos.count
    }

    /// ADR 06d (revisão G3, A2): pede o alarme de verdade e conta o que
    /// aconteceu. A superfície só ganha o sino quando o iOS aceitou; a frase
    /// que fica na tela é a que o sistema respondeu, nunca "com aviso" por
    /// otimismo. Mesma ordem de `CalendarioAgenda.avisar` — a unificação dos
    /// dois num tipo só (`PromessaDoAviso`) é a volta seguinte.
    private func agendarEContar(_ e: EventoCalendario, em lista: [EventoCalendario],
                                cal: Calendar, marcado: String) {
        Task { [weak self] in
            let r = await Revisoes.agendarCompromisso(e, cal: cal)
            ProximoCompromisso.publicar(ProximoCompromisso.comAcoesDoTrabalho(lista),
                                        cal: cal, mudo: r.vaiTocar ? nil : e.id)
            guard let self else { return }
            switch r {
            case .agendado(let quando):
                mostrarToast("\(marcado) · o aviso toca às \(Superficie.horaCurta(quando))")
            case .semPermissao:
                mostrarToast("\(marcado) — mas os avisos do Traço estão desligados no iPhone.")
            case .semEspaco:
                mostrarToast("\(marcado). o iPhone já tem \(Avisos.teto) avisos; este ficou sem.")
            case .passou:
                mostrarToast("\(marcado). a hora do aviso já passou, então não vai tocar.")
            case .semAviso:
                break // o "marcado para …" já em cena é a verdade inteira
            }
        }
    }

    /// Os encadeamentos da forma aberta que já podem acender (ADR 04k).
    var encadeamentosProntos: [Metodo.Encadeamento] {
        guard let g = gesto, g != .expressiva else { return [] }
        return g.encadeamentos.filter { e in
            e.exige.allSatisfy { !(campos[$0] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
    }

    /// ADR p × q: um plano sem a própria falha nomeada abre um pré-mortem.
    /// Nota NOVA (o plano continua intacto), com o plano copiado das palavras
    /// do autor para o primeiro campo. A IA não escreve nada aqui.
    func abrirPremortem(de plano: Nota, no context: ModelContext) {
        guard salvar(no: context) else { return }
        let frase = [plano.campos["problema"], plano.campos["resultado"], plano.texto]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? plano.tituloNaLista
        novaPagina()
        usarForma(.premortem)
        campos["plano"] = Caderno.prosa(de: frase).linhaUnica(teto: 200)
        irPara(.escrever, no: context)
        Toque.suave()
    }

    func comecarExpressiva(no context: ModelContext) {
        gesto = .expressiva
        cartao = nil
        iniciarTimer()
        salvar(no: context)
    }

    func abrirDiaDaSerie(_ serie: UUID, dia: Int, no context: ModelContext) {
        let todas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        if let existente = todas.first(where: {
            $0.serieUUID == serie && $0.diaDaSerie == dia && !$0.fechada
        }) {
            abrir(existente)
            return
        }
        novaPagina()
        seriePendente = serie
        diaPendente = dia
        comecarExpressiva(no: context)
    }

    func iniciarTimer(agora: Date = .now, duracao: TimeInterval = 15 * 60) {
        timerLigado = true
        timerEsgotou = false
        timerPrazo = agora.addingTimeInterval(duracao)
        segundosRestantes = max(0, Int(duracao.rounded(.down)))
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                self.alinharTimerAoRelogio()
                if self.timerEsgotou { return }
            }
        }
    }

    /// Relógio de parede — sobreviver a lock screen e `scenePhase` suspenso.
    func alinharTimerAoRelogio(agora: Date = .now) {
        guard timerLigado, let prazo = timerPrazo else { return }
        let resto = max(0, Int(prazo.timeIntervalSince(agora).rounded(.down)))
        segundosRestantes = resto
        if resto <= 0 {
            timerEsgotou = true
            timerTask?.cancel()
        }
    }

    func retomarExpressiva(prazo: Date?, agora: Date = .now) {
        guard let prazo else {
            iniciarTimer(agora: agora)
            return
        }
        let resto = prazo.timeIntervalSince(agora)
        if resto <= 0 {
            timerLigado = true
            timerPrazo = prazo
            segundosRestantes = 0
            timerEsgotou = true
        } else {
            iniciarTimer(agora: agora, duracao: resto)
        }
    }

    func pararTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerLigado = false
        timerPrazo = nil
    }

    /// Fim do relógio de 15 min — mesma porta que “Trancar e sair”.
    func esgotarTimer(no context: ModelContext) {
        guard timerLigado || timerEsgotou else { return }
        timerEsgotou = false
        // §8: o tempo acabou — sela (garantia) e oferece a escolha do fecho
        abrirFecho(no: context)
    }

    /// §8: fecha SELADO primeiro — o selo é garantia e não pode depender de o
    /// autor responder (matar o app no meio deixaria a nota aberta). Só então
    /// oferece a escolha: manter selada ou queimar.
    /// `destino`: para onde o autor ia quando o timer o interrompeu (§15 — o
    /// destino se preserva depois da tranca). `.pagina` = ficar onde está.
    func abrirFecho(no context: ModelContext, destino: DestinoConfirmacao = .pagina) {
        let minutos = minutosExpressiva
        confirmacao = nil
        // o selo tem de estar no disco ANTES de a página virar: com o disco
        // recusando, quinze minutos de escrita sumiam e o toast dizia o contrário.
        // O relógio só para depois do commit: parado antes, a recusa deixava a
        // expressiva sem prazo e a gravação seguinte apagava o `expressivaPrazo`.
        guard salvar(no: context, trancar: true) else { return }
        pararTimer()
        let alvo = notaUUID
        sentidoPendente = nil
        novaPagina()
        Toque.fechou()
        fechoUUID = alvo
        fechoExpressiva = minutos
        fechoDestino = destino
        if let uuid = alvo, let nota = Self.buscar(uuid: uuid, no: context) {
            sentidosDaSerie = Self.sentidosAnteriores(nota, no: context)
        }
    }

    /// Para onde ir quando o fecho terminar. `novaPagina` não pode zerar isto:
    /// ela roda DENTRO do `abrirFecho`, antes de o autor escolher a porta.
    var fechoDestino: DestinoConfirmacao = .pagina

    /// O fecho acabou (selou ou queimou): agora o trânsito que o timer barrou
    /// pode acontecer. Sem isto, tocar em Notas com o timer de pé terminava na
    /// página — a §15 promete o destino preservado.
    private func seguirDestinoDoFecho(no context: ModelContext) {
        let destino = fechoDestino
        fechoDestino = .pagina
        switch destino {
        case .pagina: break
        case .notas: irPara(.notas, no: context)
        // trancada não se recorda: o destino Recordar vira página
        case .recordar: break
        }
    }

    static func sentidosAnteriores(_ nota: Nota, no context: ModelContext) -> [String] {
        guard let serie = nota.serieUUID else { return [] }
        let todas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        return todas
            .filter { $0.serieUUID == serie && $0.uuid != nota.uuid && !$0.sentido.isEmpty }
            .sorted { $0.diaDaSerie < $1.diaDaSerie }
            .map(\.sentido)
    }

    func continuarSerie(na nota: Nota) {
        let temVoz = !nota.sentido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !nota.texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard temVoz else { return }
        if nota.serieUUID == nil {
            nota.serieUUID = UUID()
            nota.diaDaSerie = 1
        }
        guard let serie = nota.serieUUID, nota.diaDaSerie < 4 else { return }
        Revisoes.agendarSerie(
            serie: serie,
            dia: nota.diaDaSerie + 1,
            em: Revisoes.proximoDiaDaSerie())
    }

    /// Devolve se o disco aceitou. Quem vai apagar a página DEPOIS de gravar
    /// tem de olhar isto: gravar recusada + página nova = texto perdido.
    @discardableResult
    func salvar(no context: ModelContext, trancar: Bool = false) -> Bool {
        let serieEmVoo = gesto == .expressiva && seriePendente != nil
        guard temVoz || trancar || serieEmVoo else {
            // Página vazia não é nota — o disco fica. A tela bloqueada não:
            // o autor apagou a única de hoje, e a linha some no mesmo instante.
            if let notaUUID { DestaqueDoDia.apagar(id: notaUUID) }
            return true
        }
        let prazo = (timerLigado && !trancar) ? timerPrazo : nil
        let nota: Nota
        // ADR 05s: nada sai da Sessão antes do commit — versão, widget e índice
        // esperam o disco dizer sim. A anterior fica guardada aqui e vai ao
        // disco só depois (ADR m); a expressiva nunca: o que queima não pode
        // sobreviver aqui.
        var versaoAnterior: (texto: String, campos: [String: String], gesto: Gesto?, fechada: Bool)?
        if let notaUUID, let existente = Self.buscar(uuid: notaUUID, no: context) {
            if existente.texto != texto || existente.campos != campos {
                versaoAnterior = (existente.texto, existente.campos, existente.gesto, existente.fechada)
            }
            existente.texto = texto
            existente.gesto = gesto
            existente.campos = campos
            existente.expressivaPrazo = prazo
            if trancar { existente.trancada = true }
            if let sentidoPendente { existente.sentido = sentidoPendente }
            existente.minutosEscritos = max(existente.minutosEscritos, minutosExpressiva)
            existente.editadaEm = .now
            nota = existente
        } else {
            nota = Nota(texto: texto, gesto: gesto, campos: campos, trancada: trancar,
                        expressivaPrazo: prazo,
                        minutosEscritos: minutosExpressiva,
                        sentido: sentidoPendente ?? "")
            context.insert(nota)
            self.notaUUID = nota.uuid
        }
        aplicarDominio(na: nota)
        aplicarSerie(na: nota)
        aplicarGatilho(na: nota)
        if criadaEmDaPagina == nil { criadaEmDaPagina = nota.criadaEm }
        guard persistir(context) else {
            // A escrita do autor nunca se perde em silêncio: o texto segue na página
            // e a linha fica até uma gravação dizer sim. (Tranca de expressiva
            // continua garantida pelo expressivaPrazo persistido na próxima
            // gravação/arranque.)
            mostrarToast("Não consegui guardar agora. O texto continua aqui.", fixo: true)
            return false
        }
        if let fixa = linhaFixa {
            linhaFixa = nil
            if toast == fixa { toast = nil }
        }
        if let v = versaoAnterior {
            Versoes.registrar(nota.uuid, texto: v.texto, campos: v.campos, gesto: v.gesto, fechada: v.fechada)
        }
        aplicarDestaque(na: nota)
        // ADR 04n: o índice de sentido acompanha a nota — fora da main thread,
        // porque `salvar` roda em toda troca de cena e o índice regrava o
        // arquivo inteiro (ponytail: JSON de N×200 floats; formato binário por
        // nota se um dia doer a mil notas). O selo, esse, tira na hora:
        // `remover` é síncrono nas rotas de selar, queimar e apagar.
        if trancar || nota.fechada {
            // o selo vale para o disco: nada do texto selado fica em Arquivos
            Versoes.apagar(nota.uuid)
            Apontar.apagar(nota.uuid)
            Indice.remover(nota.uuid, geracao: Geracao.proxima())
            calarAcoesDerivadas(de: nota.uuid, no: context)
        } else {
            let lida = Self.paraIndice(nota)
            let g = Geracao.proxima()
            Task.detached(priority: .utility) { Indice.atualizar(lida, geracao: g) }
            classificarDominioNoAparelho(da: nota, no: context) // ADR 05d
        }
        return true
    }

    nonisolated static func paraIndice(_ n: Nota) -> Indice.NotaLida {
        // ADR 04y: os marcadores de PDF viajam com a voz; o índice os expande
        // no texto do anexo, fora da main thread
        let ns = n.texto as NSString
        let marcadores = Indice.marcadorPDF.matches(in: n.texto, range: NSRange(location: 0, length: ns.length))
            .map { ns.substring(with: $0.range) }
        return Indice.NotaLida(uuid: n.uuid, editadaEm: n.editadaEm,
                               voz: ([n.textoDeQualquerOrigem] + marcadores).joined(separator: "\n"),
                               // ADR 16c: obra não entra no índice de sentido — um vetor
                               // dos 3.000 primeiros caracteres de um livro não é o livro
                               podeEntrar: !n.fechada && n.gesto != .expressiva && n.temVoz && !n.origem.eObra)
    }

    /// No arranque: o índice inteiro contra o disco (entra o que pode, sai o
    /// que não pode mais).
    func sincronizarIndice(no context: ModelContext) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        let lidas = notas.map(Self.paraIndice)
        let g = Geracao.proxima()
        Task.detached(priority: .utility) { Indice.sincronizar(lidas, geracao: g) }
    }

    private func aplicarDominio(na nota: Nota) {
        if gesto == .expressiva {
            nota.dominio = nil
            nota.dominioTravado = false
            return
        }
        nota.dominioTravado = dominioTravado
        if dominioTravado {
            nota.dominio = dominio
        } else {
            let voz = VozDoAutor.juntar(texto: texto, campos: campos, sentido: sentidoPendente ?? "", semCitacao: true)
            dominio = Dominio.inferir(voz: voz)
            nota.dominio = dominio
        }
    }

    private func aplicarSerie(na nota: Nota) {
        guard gesto == .expressiva, let serie = seriePendente else { return }
        nota.serieUUID = serie
        nota.diaDaSerie = diaPendente
    }

    private func aplicarGatilho(na nota: Nota) {
        // Decisão (ADR p): "o que espero, e quando eu confiro" agenda a
        // conferência — o diário de decisão só vale se a data cobra
        let fonte: String = switch gesto {
        case .seEntao, .woop: campos["se"] ?? campos["plano"] ?? ""
        case .decisao: campos["espero"] ?? ""
        default: ""
        }
        guard let quando = Gatilho.data(em: fonte) else {
            nota.gatilhoEm = nil
            Revisoes.cancelarGatilho(uuid: nota.uuid)
            return
        }
        let titulo = VozDoAutor.titulo(texto, gesto: gesto, campos: campos)
        guard !titulo.isEmpty else {
            nota.gatilhoEm = nil
            Revisoes.cancelarGatilho(uuid: nota.uuid)
            return
        }
        nota.gatilhoEm = quando
        Revisoes.cancelarGatilho(uuid: nota.uuid)
        Revisoes.agendarGatilho(uuid: nota.uuid, titulo: titulo, em: quando)
    }

    /// ADR 05n/05j: selar, queimar ou apagar a origem cala NO ATO o aviso da
    /// ação derivada. O título do aviso é texto do Trabalho, e o Trabalho fica
    /// restrito no mesmo instante — deixar tocar seria o selo tocando sozinho.
    private func calarAcoesDerivadas(de nota: UUID, no context: ModelContext) {
        for t in AcessoTrabalho.derivados(daNota: nota, no: context) {
            Revisoes.cancelarAcoes(doTrabalho: t)
        }
    }

    /// A nota do disco — id, datas e sentido reais. Nunca um cabeçalho inventado.
    func fatiaComoContexto(no context: ModelContext) -> FatiaCorpus? {
        salvar(no: context)
        guard let id = notaUUID, let nota = Self.buscar(uuid: id, no: context) else { return nil }
        let fatia = FatiaCorpus.de(nota)
        return fatia.nuncaSai ? nil : fatia
    }

    /// `unica` vazio depois de vestir a forma não é ausência — o campo existe
    /// como "". A prosa do corpo é a única de hoje até o autor preencher o sítio.
    private func linhaDoDestaque(texto: String, campos: [String: String]) -> String {
        let unica = campos["unica"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return unica.isEmpty ? VozDoAutor.titulo(texto) : unica
    }

    private func aplicarDestaque(na nota: Nota) {
        if gesto == .destaque, !nota.fechada {
            DestaqueDoDia.gravar(linhaDoDestaque(texto: texto, campos: campos), id: nota.uuid)
            return
        }
        // ADR 04k: a única do Dia é o Destaque do dia — mesma lei, mesma tela
        if let g = gesto, g != .destaque, !nota.fechada, g.campos.contains(where: { $0.id == "unica" }) {
            let unica = campos["unica"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !unica.isEmpty {
                DestaqueDoDia.gravar(unica, id: nota.uuid)
                return
            }
        }
        DestaqueDoDia.apagar(id: nota.uuid)
    }

    func desfazerDominio() {
        dominio = nil
        dominioTravado = true
        Toque.leve()
    }

    /// Devolve a inferência à nota. Roda o léxico na hora, para o autor ver o
    /// resultado sem precisar reabrir e salvar.
    @discardableResult
    func devolverDominio(_ nota: Nota, no context: ModelContext) -> Bool {
        nota.devolverDominio()
        nota.dominio = Dominio.inferir(voz: nota.vozDoAutor)
        guard persistir(context) else {
            mostrarToast("não consegui devolver o domínio.")
            return false
        }
        if notaUUID == nota.uuid {
            dominio = nota.dominio
            dominioTravado = false
        }
        Toque.leve()
        return true
    }

    /// ADR 2026-09-02c: um toque no chip tira o rótulo e trava. Se o disco
    /// recusa, o rótulo continua — o gesto não mente.
    @discardableResult
    func soltarDominio(_ nota: Nota, no context: ModelContext) -> Bool {
        escolherDominio(nil, na: nota, no: context)
    }

    /// ADR 05d: o autor escolhe no menu (um dos sete, ou nenhum) e a nota
    /// trava — a IA não volta a mexer até "Devolver ao app".
    @discardableResult
    func escolherDominio(_ d: Dominio?, na nota: Nota, no context: ModelContext) -> Bool {
        nota.dominio = d
        nota.dominioTravado = true
        guard persistir(context) else {
            mostrarToast("não consegui guardar o domínio — o rótulo continua.")
            return false
        }
        if notaUUID == nota.uuid {
            dominio = d
            dominioTravado = true
        }
        Toque.leve()
        return true
    }

    /// Na página: a escolha vale na hora e vai ao disco no próximo salvar.
    func escolherDominioNaPagina(_ d: Dominio?) {
        dominio = d
        dominioTravado = true
        Toque.leve()
    }

    /// ADR 05d: a IA do aparelho corrige o léxico, fora da main thread, só
    /// quando a voz mudou desde a última vez e o autor não travou.
    private var vozClassificada = ""
    private func classificarDominioNoAparelho(da nota: Nota, no context: ModelContext) {
        guard !nota.dominioTravado, nota.gesto != .expressiva, !nota.fechada else { return }
        let voz = nota.vozDoAutor
        guard voz != vozClassificada, voz.count >= 12 else { return }
        vozClassificada = voz
        let uuid = nota.uuid
        Task { [weak self] in
            guard let r = await AnaliseDeBordo.dominio(texto: voz), let self else { return }
            guard let viva = Self.buscar(uuid: uuid, no: context), !viva.dominioTravado,
                  viva.vozDoAutor == voz, viva.dominio != r else { return }
            viva.dominio = r
            _ = self.persistir(context)
            if self.notaUUID == uuid, !self.dominioTravado { self.dominio = r }
        }
    }

    /// Expressiva vencida sobrevive à morte do processo: a notas não pode vazar o texto.
    func trancarExpressivasVencidas(no context: ModelContext, agora: Date = .now) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        var seladas: [UUID] = []
        var recem: Nota?
        for nota in notas {
            guard nota.gesto == .expressiva, !nota.fechada, let prazo = nota.expressivaPrazo, prazo <= agora else { continue }
            nota.trancada = true
            nota.expressivaPrazo = nil
            recem = nota
            seladas.append(nota.uuid)
        }
        if !seladas.isEmpty {
            guard persistir(context) else {
                mostrarToast("não consegui trancar — a nota continua aberta.")
                return
            }
            // ADR 05s: o selo só chega ao disco depois do commit
            for uuid in seladas {
                Versoes.apagar(uuid)
                Apontar.apagar(uuid)
                Indice.remover(uuid, geracao: Geracao.proxima())
            }
            // a recém-selada sai do Spotlight e vira só metadado no espelho
            Corpus.backupAutomatico(notas: notas)
            Holofote.indexar(notas: notas)
            if let recem, recem.sentido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               fechoExpressiva == nil {
                fechoUUID = recem.uuid
                fechoExpressiva = recem.minutosEscritos
                sentidosDaSerie = Self.sentidosAnteriores(recem, no: context)
            }
        }
    }

    /// ADR 04p: o que o Mac deixou em `entrada/` vira nota; `metodos/` entra
    /// no catálogo. Chamado no arranque e ao voltar à cena.
    func recolherEntrada(no context: ModelContext) {
        var total = 0
        var falhou = false
        func recolher(_ raiz: URL) {
            guard !falhou else { return }
            if Entrada.recolherMetodos(raizes: [raiz]) > 0 { Catalogo.recarregar() }
            let arquivos = Entrada.arquivos(raizes: [raiz])
            guard !arquivos.isEmpty else { return }
            do {
                let recibos = try context.fetch(FetchDescriptor<ReciboEntrada>())
                var conhecidas = Set(recibos.map(\.chave))
                var novas = 0
                for arquivo in arquivos where !conhecidas.contains(arquivo.chave) {
                    for item in arquivo.itens {
                        let gesto = item.gestoNome.flatMap(Gesto.doNome)
                        let partes = Corpus.separarCampos(texto: item.texto, gesto: gesto)
                        let nota = Nota(texto: partes.texto, gesto: gesto, campos: partes.campos)
                        nota.criadaEm = item.criadaEm
                        nota.origem = item.origem
                        context.insert(nota)
                        novas += 1
                    }
                    context.insert(ReciboEntrada(chave: arquivo.chave))
                    conhecidas.insert(arquivo.chave)
                }
                if novas > 0, !persistir(context) {
                    falhou = true
                    mostrarToast("não consegui importar — os arquivos continuam na entrada.")
                    return
                }
                // O recibo sobrevive à remoção da nota: replay não ressuscita conteúdo.
                for arquivo in arquivos { Entrada.confirmar(arquivo) }
                total += novas
            } catch {
                falhou = true
                mostrarToast("não consegui ler as importações — os arquivos continuam na entrada.")
            }
        }
        recolher(Entrada.raizDoApp)
        // Ler e confirmar enquanto o acesso security-scoped continua aberto.
        PastaEspelho.comAcesso { recolher($0) }
        guard total > 0 else { return }
        UserDefaults.standard.set(Date.now, forKey: Entrada.chaveUltima)
        if !falhou { mostrarToast(total == 1 ? "1 nota veio de fora." : "\(total) notas vieram de fora.") }
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
            projetarTudo(todas)
        }
    }

    /// A nota do ditado em curso. Chaveada pela hora em que a gravação
    /// começou: um ditado novo nunca reescreve a nota do anterior.
    /// ADR 06c: a nota do ditado. A PRIMEIRA chamada de um ditado CRIA — e é o
    /// DEPÓSITO, feito antes de existir uma letra; as seguintes reescrevem a
    /// MESMA nota quando a transcrição chega ou falha. `nil` = o disco recusou.
    ///
    /// **A nota volta para quem a pediu.** Ela era uma variável da Sessão, e
    /// dois ditados sobrepostos dividiam a mesma: quando o segundo depositava,
    /// a transcrição do primeiro não achava mais "a sua" nota e criava uma
    /// SEGUNDA (G3, A2). Agora cada ditado carrega a sua identidade até o fim.
    ///
    /// O áudio não entra aqui: ele mora no cofre de anexos e é referido pelo
    /// marcador dentro do texto — nunca um blob no SwiftData.
    func gravarDitado(texto: String, criadaEm: Date, nota anterior: Nota?, no context: ModelContext) -> Nota? {
        let nota: Nota
        let ehNova: Bool
        if let anterior, !anterior.isDeleted {
            nota = anterior
            nota.texto = texto
            nota.editadaEm = .now
            ehNova = false
        } else {
            nota = Nota(texto: texto, criadaEm: criadaEm, editadaEm: criadaEm)
            context.insert(nota)
            ehNova = true
        }
        guard persistir(context) else {
            if ehNova { context.delete(nota) }
            return nil
        }
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) { projetarTudo(todas) }
        return nota
    }

    /// ADR 06c: liga um ditado ao disco. Fica aqui, e não na raiz, porque é o
    /// que o teste da corrida de dois ditados precisa exercitar — a caixa
    /// `minha` é a identidade DESTE ditado, e as duas closures a dividem.
    func armarDitado(_ ditado: DitadoProprio, no context: ModelContext) {
        let quando = ditado.comecouEm
        var minha: Nota?
        ditado.gravarNota = { [weak self] texto in
            guard let self, let n = gravarDitado(texto: texto, criadaEm: quando, nota: minha, no: context) else { return false }
            minha = n
            return true
        }
        ditado.abrirANota = { [weak self] in
            guard let self, let n = minha, salvar(no: context) else { return }
            abrir(n)
            irPara(.escrever, no: context)
        }
    }

    /// ADR 05s: a varredura inteira das três projeções, sempre DEPOIS do
    /// commit — importar, entrada do Mac e as rotas do selo passam por aqui.
    private func projetarTudo(_ todas: [Nota]) {
        Corpus.backupAutomatico(notas: todas)
        Holofote.indexar(notas: todas)
        let lidas = todas.map(Self.paraIndice)
        let g = Geracao.proxima()
        Task.detached(priority: .utility) { Indice.sincronizar(lidas, geracao: g) }
    }

    /// V3: no arranque, série viva que perdeu o aviso volta a ter um.
    func rearmarSeries(no context: ModelContext) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        Task { await Revisoes.rearmarSeries(notas: notas) }
    }

    /// P0 6: no arranque, anexos sem marcador em NOTA NENHUMA (trancadas incluídas —
    /// o texto delas segue referenciando os arquivos) saem do disco.
    func varrerAnexosOrfaos(no context: ModelContext) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        var textos = notas.map(\.texto)
        textos.append(texto) // a página aberta também referencia
        AnexoDisco.varrerOrfaos(textos: textos)
    }

    /// Sobe a cada página nova: o `onChange` da view não vê uuid→nil quando
    /// gravar e zerar acontecem no mesmo ciclo.
    var geracaoDaPagina = 0

    func novaPagina() {
        campoPedido = nil
        // a página nova é para escrever: o cursor volta (a flag da nota aberta
        // da lista, se ficou armada, não vale aqui)
        acabouDeAbrir = false
        geracaoDaPagina += 1
        pararTimer()
        criadaEmDaPagina = nil
        instigou = false
        texto = ""
        gesto = nil
        campos = [:]
        notaUUID = nil
        origemDaPagina = .autor
        perguntaPadroes = nil
        perguntaDaSabia = nil
        notasNaPergunta = []
        notasLidasNaPergunta = 0
        cartao = nil
        confirmacao = nil
        recordarTexto = ""
        recordarCampos = [:]
        autoSuprimidaNaNota = false
        dominio = nil
        dominioTravado = false
        seriePendente = nil
        diaPendente = 0
        sentidosDaSerie = []
        recordarGesto = nil
        recordarUUID = nil
        filaUUIDs = []
        filaAtiva = false
    }

    /// Restaurar uma versão guarda a atual primeiro: nada se perde.
    func restaurar(_ nota: Nota, versao: VersaoNota, no context: ModelContext) {
        guard !nota.fechada, nota.gesto != .expressiva else { return }
        // a página aberta pode ter edição em voo: grava (vira versão) antes de trocar
        if notaUUID == nota.uuid { guard salvar(no: context) else { return } }
        let anterior = (texto: nota.texto, campos: nota.campos, gesto: nota.gesto, fechada: nota.fechada)
        nota.texto = versao.texto
        nota.campos = versao.campos
        nota.editadaEm = .now
        if notaUUID == nota.uuid {
            texto = versao.texto
            campos = versao.campos
        }
        guard persistir(context) else {
            mostrarToast("não consegui restaurar — a nota ficou como estava.")
            return
        }
        // ADR 05s: a versão que restaurar substitui só vira histórico depois do commit
        Versoes.registrar(nota.uuid, texto: anterior.texto, campos: anterior.campos,
                          gesto: anterior.gesto, fechada: anterior.fechada)
        Toque.suave()
    }

    func abrir(_ nota: Nota, mesmoTrancada: Bool = false, campo: String? = nil) {
        campoPedido = nil
        // queimada não abre: não existe texto. Dizer isso é honestidade, não erro.
        if nota.queimada {
            mostrarToast("essa você queimou. ficou a data e o que você entendeu.")
            return
        }
        if nota.trancada, !mesmoTrancada {
            confirmacao = .naoSeRele(nota.uuid)
            return
        }
        pararTimer()
        texto = nota.texto
        gesto = nota.gesto
        campos = nota.campos
        notaUUID = nota.uuid
        origemDaPagina = nota.origem
        criadaEmDaPagina = nota.criadaEm
        instigou = false
        dominio = nota.dominio
        dominioTravado = nota.dominioTravado
        perguntaPadroes = nil
        perguntaDaSabia = nil
        notasNaPergunta = []
        cartao = nil
        mostrarNotas = false
        mostrarPadroes = false
        if nota.gesto == .expressiva, !nota.trancada {
            retomarExpressiva(prazo: nota.expressivaPrazo)
        }
        campoPedido = campo
        acabouDeAbrir = true
    }

    func concluir(no context: ModelContext) {
        if timerLigado {
            // §8: Concluída depois de 10 min já mereceu a porta — mas quem
            // escolhe QUAL porta (selar ou queimar) é sempre o autor
            if minutosExpressiva >= 10 {
                abrirFecho(no: context)
            } else {
                confirmacao = .sairTranca(destino: .pagina)
            }
            return
        }
        guard temVoz else { return }
        // A régua de formatos saiu da página (dono, 14/09): título, seção e
        // lista nascem do próprio texto ao concluir, pelo motor local que o
        // "Todas" já usava. Nenhuma palavra muda — só a forma do que é curto
        // e paralelo. A expressiva fica intocada (selo).
        let original = texto
        if gesto != .expressiva {
            let local = Caderno.estruturar(texto)
            if local != texto { texto = local }
        }
        // gravação recusada devolve as palavras como estavam (integridade)
        guard salvar(no: context) else { texto = original; return }
        // Goal de 14/09: "agenda o que tem hora". A linha da nota que traz dia
        // e hora vira compromisso sozinha; a nota fica como está.
        if gesto != .expressiva { marcarCompromissosDaNota() }
        // Só uma gravação confirmada pode contar como conclusão.
        if let g = gesto, g != .expressiva, camposComResposta { Sinais.ficou(g) }
        // peak-end-rule: o fim do percurso não devolvia NADA — nem confirmação,
        // nem onde a nota foi parar. Uma linha, e ela some sozinha.
        // "especificação guardada" dizia o nome do método; a pessoa só quer
        // saber ONDE a nota foi parar (auditoria 15/09, alto 1)
        mostrarToast("guardada em Notas")
        // FILA P1.5: a nota concluída marca a própria revisão — o Recordar chega
        // no dia certo sem o autor lembrar (§17).
        // Exp 9: o corpus vive também no app Arquivos — backup sem nuvem, sem conta.
        // ADR 04o: concluir grava SÓ a nota que mudou (e os agregados), fora da
        // main thread; a varredura completa fica para as rotas do selo.
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
            if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
                Corpus.backupDeUma(nota, entre: todas)
            } else {
                Corpus.backupAutomatico(notas: todas)
            }
            // Exp 3: Spotlight indexa só as abertas (o selo vale para o sistema)
            Holofote.indexar(notas: todas)
        }
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
            // ADR 16d: o conselho em sombra — registra, não mostra
            Self.registrarConselho(nota, no: context)
            Revisoes.agendar(uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto, trancada: nota.fechada, texto: nota.texto, campos: nota.campos) { [weak self] in
                Task { @MainActor in
                    self?.mostrarToast("revisões precisam de permissão — Ajustes › Traço › Notificações.")
                }
            }
        }
        novaPagina()
        Toque.leve()
    }

    /// ADR 2026-09-16d: Decisão ou Pré-mortem concluídos com o ato escrito
    /// procuram nas obras CONFERIDAS a regra e a outra voz e registram em
    /// sombra (`Sinal.exposto`), uma vez por nota. Nada aparece ao autor.
    static func registrarConselho(_ nota: Nota, no context: ModelContext) {
        guard nota.origem == .autor, !nota.fechada,
              let consulta = Conselho.consulta(gesto: nota.gesto, campos: nota.campos) else { return }
        let sinais = Sinais.todos()
        if let exposto = sinais.last(where: { $0.tipo == .exposto && $0.nota == nota.uuid }) {
            // ADR 16e: a volta — "aconteceu" e "saldo" escritos dão à regra
            // exposta o saldo, uma vez; o «serviu» não passa por aqui
            let aconteceu = (nota.campos["aconteceu"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            // o saldo corrigido substitui (`pesos` lê o último da nota); o mesmo não se repete
            guard !aconteceu.isEmpty, let saldo = Conselho.saldo(nota.campos["saldo"] ?? ""),
                  sinais.last(where: { $0.tipo == .resultado && $0.nota == nota.uuid })?.saldo != saldo.rawValue
            else { return }
            Sinais.registrar(Sinal(tipo: .resultado, forma: nota.gestoRaw, nota: nota.uuid,
                                   regra: exposto.regra, saldo: saldo.rawValue))
            return
        }
        // a volta já escrita antes da exposição: a regra escolhida agora não
        // estava lá quando ele decidiu — não se expõe depois do fato (revisão E4)
        guard (nota.campos["aconteceu"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let obras = ((try? context.fetch(FetchDescriptor<Nota>())) ?? []).filter { $0.origem == .obra && !$0.fechada }
        guard let achado = Conselho.escolher(consulta: consulta, obras: obras.map(\.texto),
                                             pesos: Conselho.pesos(sinais)) else { return }
        Sinais.registrar(Sinal(tipo: .exposto, forma: nota.gestoRaw, texto: achado.regra.secao.texto,
                               nota: nota.uuid, regra: achado.regra.secao.chave,
                               contraria: achado.outra?.secao.texto, porque: achado.regra.termos))
    }

    /// Trocar de aba NUNCA perde texto: salva antes de sair (§20).
    /// Com o timer da expressiva rodando, a saída pede confirmação — o selo vale.
    func irPara(_ nova: Aba, no context: ModelContext) {
        guard nova != aba else { return }
        if timerLigado, nova != .escrever {
            confirmacao = .sairTranca(destino: .notas)
            return
        }
        guard salvar(no: context) else { return }
        Teclado.recolher()
        if nova != .escrever { abaArquivo = nova }
        aba = nova
    }

    func irNotas(no context: ModelContext) {
        if timerLigado {
            confirmacao = .sairTranca(destino: .notas)
            return
        }
        guard salvar(no: context) else { return }
        Teclado.recolher()
        mostrarNotas = true
    }

    func irRecordar(no context: ModelContext) {
        guard podeRecordar else {
            if temVoz || !paginaVazia { mostrarToast("ainda não há o que recordar.") }
            return
        }
        // A cópia só acontece quando o Recordar vai mesmo abrir: durante o timer,
        // nada é capturado — a expressiva não pode vazar por esta rota.
        if timerLigado {
            confirmacao = .sairTranca(destino: .recordar)
            return
        }
        guard salvar(no: context) else { return }
        filaAtiva = false
        filaUUIDs = []
        recordarTexto = texto
        recordarCampos = campos
        recordarGesto = gesto
        recordarUUID = notaUUID
        mostrarRecordar = true
    }

    func recordarDaNotas(_ nota: Nota) {
        guard !nota.fechada,
              RitualRecordar.de(nota.gesto).temAlvo(texto: nota.texto, campos: nota.campos)
        else { return }
        if !filaAtiva { filaUUIDs = [] }
        recordarTexto = nota.texto
        recordarCampos = nota.campos
        recordarGesto = nota.gesto
        recordarUUID = nota.uuid
        revisaoPendente = nota.uuid
        mostrarRecordar = true
    }

    /// Rota "Recordar" do widget (U4): recorda a nota em voo, se houver; senão a
    /// mais recente que ainda se relê. Sem nada a recordar, abre as notas — o
    /// toque do widget nunca cai no vazio.
    func recordarMaisRecente(no context: ModelContext) {
        if RitualRecordar.de(gesto).temAlvo(texto: texto, campos: campos) {
            irRecordar(no: context)
            return
        }
        var desc = FetchDescriptor<Nota>(sortBy: [SortDescriptor(\.editadaEm, order: .reverse)])
        desc.fetchLimit = 8
        if let nota = (try? context.fetch(desc))?.first(where: {
            !$0.fechada && RitualRecordar.de($0.gesto).temAlvo(texto: $0.texto, campos: $0.campos)
        }) {
            recordarDaNotas(nota)
        } else {
            mostrarNotas = true
        }
    }

    /// SPEC §8: QUEIMAR. Não é esconder — é destruir. O texto é sobrescrito antes
    /// de sumir (não basta marcar), e o backup no Arquivos é regravado na hora,
    /// senão a promessa seria mentira. Sobram data, minutos e a linha de sentido.
    /// Se o disco recusa, a queima não aconteceu: o texto e o fecho ficam.
    @discardableResult
    func queimar(no context: ModelContext, sentido linha: String) -> Bool {
        let minutos = minutosExpressiva
        let corte = linha.trimmingCharacters(in: .whitespacesAndNewlines)
        let nota: Nota
        if let alvo = fechoUUID ?? notaUUID, let existente = Self.buscar(uuid: alvo, no: context) {
            nota = existente
        } else {
            nota = Nota(gesto: .expressiva)
            context.insert(nota)
        }
        // a cinza não guarda o texto: sobrescreve, depois esvazia
        nota.texto = String(repeating: " ", count: max(nota.texto.count, 1))
        nota.texto = ""
        nota.campos = [:]
        nota.gesto = .expressiva
        nota.trancada = false
        nota.queimada = true
        nota.queimadaEm = .now
        nota.minutosEscritos = minutos
        nota.sentido = corte
        nota.expressivaPrazo = nil
        nota.editadaEm = .now
        continuarSerie(na: nota)
        guard persistir(context) else {
            mostrarToast("não consegui queimar — o texto continua.")
            return false
        }
        pararTimer()
        // nada de janela de desfazer: queimar não tem volta, e isso é o método
        apagadaRecuperavel = nil
        Versoes.apagar(nota.uuid)
        Apontar.apagar(nota.uuid)
        Indice.remover(nota.uuid, geracao: Geracao.proxima())
        Revisoes.cancelar(uuid: nota.uuid)
        calarAcoesDerivadas(de: nota.uuid, no: context)
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
            Corpus.backupAutomatico(notas: todas)
            Holofote.indexar(notas: todas)
        }
        novaPagina()
        Toque.fechou()
        confirmacao = nil
        fechoExpressiva = nil
        sentidoPendente = nil
        fechoUUID = nil
        seguirDestinoDoFecho(no: context)
        return true
    }

    /// O "Selar" do fecho: a nota já está selada; aqui só grava a linha de
    /// sentido, que vive FORA do selo e entra no corpus.
    @discardableResult
    func guardarSentidoDoFecho(_ linha: String, no context: ModelContext) -> Bool {
        if let alvo = fechoUUID, let nota = Self.buscar(uuid: alvo, no: context) {
            nota.sentido = linha.trimmingCharacters(in: .whitespacesAndNewlines)
            nota.editadaEm = .now
            continuarSerie(na: nota)
            guard persistir(context) else {
                mostrarToast("não consegui gravar o sentido — o fecho continua.")
                return false
            }
            if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
                Corpus.backupAutomatico(notas: todas)
            }
        }
        fechoExpressiva = nil
        fechoUUID = nil
        sentidoPendente = nil
        sentidosDaSerie = []
        seriePendente = nil
        diaPendente = 0
        seguirDestinoDoFecho(no: context)
        Toque.suave()
        return true
    }

    /// Grava ou recua. Sem `try?`: o gesto que promete disco não mente.
    @discardableResult
    private func persistir(_ context: ModelContext) -> Bool {
        do {
            if let persistirNoDisco {
                try persistirNoDisco(context)
            } else {
                try context.save()
            }
            return true
        } catch {
            context.rollback()
            return false
        }
    }

    /// SPEC ADR 2026-09-02a: import é gesto. Se o disco recusa, as notas não
    /// entraram — o aviso não mente que entraram.
    @discardableResult
    func importarCorpus(
        _ itens: [Corpus.ItemImportado],
        no context: ModelContext, anunciar: Bool = true
    ) -> Int {
        guard !itens.isEmpty else { return 0 }
        for item in itens {
            let gesto = item.gestoNome.flatMap(Gesto.doNome)
            let (corpo, campos) = Corpus.separarCampos(texto: item.texto, gesto: gesto)
            let nota = Nota(texto: corpo, gesto: gesto, campos: campos)
            nota.criadaEm = item.criadaEm
            nota.origem = item.origem
            context.insert(nota)
        }
        guard persistir(context) else {
            mostrarToast("não consegui importar — as notas não entraram.")
            return 0
        }
        let n = itens.count
        if anunciar { mostrarToast("\(n) nota\(n == 1 ? "" : "s") importada\(n == 1 ? "" : "s").") }
        // ADR 04o/05s: importar é rota inteira — as notas que entraram chegam
        // ao espelho, ao Spotlight e ao índice agora, não no próximo arranque.
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) { projetarTudo(todas) }
        return n
    }

    func trancarESair(no context: ModelContext, destino: DestinoConfirmacao) {
        // ADR 05s: com o disco recusando, a página não vira — o texto fica, a
        // linha diz e o relógio continua; o destino espera.
        guard salvar(no: context, trancar: true) else { return }
        pararTimer()
        sentidoPendente = nil
        fechoExpressiva = nil
        novaPagina()
        Toque.fechou()
        // Nota trancada não se recorda: o destino Recordar vira página.
        let destinoFinal: DestinoConfirmacao = destino == .recordar ? .pagina : destino
        if destinoFinal == .notas { mostrarNotas = true }
        confirmacao = .trancada(destino: destinoFinal)
    }

    /// ADR 2026-08-31f: apagar apaga de verdade — nota, revisão marcada e,
    /// na próxima varredura, os anexos que só ela referenciava.
    /// Dia 200: a confirmação vira piloto automático — por isso existe a janela
    /// de desfazer (a cópia vive até a próxima ação ou 6s).
    var apagadaRecuperavel: NotaRecuperavel?
    private var desfazerTask: Task<Void, Never>?

    func apagar(uuid: UUID, no context: ModelContext) {
        guard let nota = Self.buscar(uuid: uuid, no: context) else { return }
        apagadaRecuperavel = nota.retrato()
        let serie = nota.serieUUID
        context.delete(nota)
        // ADR 05s: avisos e projeções só depois do commit; recusa recua o contexto
        guard persistir(context) else {
            apagadaRecuperavel = nil
            mostrarToast("não consegui apagar — a nota continua.")
            return
        }
        Revisoes.cancelar(uuid: uuid)
        Revisoes.cancelarGatilho(uuid: uuid)
        if let serie { Revisoes.cancelarSerie(serie: serie) }
        DestaqueDoDia.apagar(id: uuid)
        calarAcoesDerivadas(de: uuid, no: context)
        Versoes.apagar(uuid)
        Apontar.apagar(uuid)
        Indice.remover(uuid, geracao: Geracao.proxima())
        // regra de ferro 2: apagar tira a nota do espelho em Arquivos e do Spotlight AGORA
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
            Corpus.backupAutomatico(notas: todas)
            Holofote.indexar(notas: todas)
        }
        if notaUUID == uuid { novaPagina() }
        varrerAnexosOrfaos(no: context)
        confirmacao = nil
        Toque.fechou()
        desfazerTask?.cancel()
        desfazerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            if !Task.isCancelled { self?.apagadaRecuperavel = nil }
        }
    }

    func desfazerApagar(no context: ModelContext) {
        guard let a = apagadaRecuperavel else { return }
        let nota = Nota.de(a)
        context.insert(nota)
        guard persistir(context) else {
            mostrarToast("não consegui devolver a nota.")
            return
        }
        if nota.gesto == .destaque, !nota.fechada {
            DestaqueDoDia.gravar(
                linhaDoDestaque(texto: nota.texto, campos: nota.campos), id: nota.uuid)
        }
        if let quando = nota.gatilhoEm {
            let titulo = VozDoAutor.titulo(nota.texto, gesto: nota.gesto, campos: nota.campos)
            if !titulo.isEmpty {
                Revisoes.agendarGatilho(uuid: nota.uuid, titulo: titulo, em: quando)
            }
        }
        Revisoes.agendar(
            uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto,
            trancada: nota.fechada, texto: nota.texto, campos: nota.campos)
        if let serie = nota.serieUUID, nota.gesto == .expressiva,
           nota.diaDaSerie > 0, nota.diaDaSerie < 4 {
            Revisoes.agendarSerie(serie: serie, dia: nota.diaDaSerie + 1, em: Revisoes.proximoDiaDaSerie())
        }
        apagadaRecuperavel = nil
        desfazerTask?.cancel()
        // ADR 05s: a nota devolvida volta ao espelho, ao Spotlight e ao índice agora
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) { projetarTudo(todas) }
        Toque.leve()
    }

    static func buscar(uuid: UUID, no context: ModelContext) -> Nota? {
        let d = FetchDescriptor<Nota>(predicate: #Predicate { $0.uuid == uuid })
        return try? context.fetch(d).first
    }

    /// ADR 05s: a linha de gravação recusada é `fixo` — fica na página até
    /// uma gravação dizer sim, em vez de sumir em 2,5 s e deixar silêncio.
    /// Um aviso transitório passa por cima e, ao sumir, devolve a linha.
    private var linhaFixa: String?
    var toastFixo: Bool { linhaFixa != nil }

    func mostrarToast(_ msg: String, fixo: Bool = false, duracao: Duration = .seconds(2.5)) {
        toast = msg
        if fixo { linhaFixa = msg }
        AccessibilityNotification.Announcement(msg).post()
        toastTask?.cancel()
        guard !fixo else { return }
        toastTask = Task {
            try? await Task.sleep(for: duracao)
            if !Task.isCancelled { toast = linhaFixa }
        }
    }
}

enum CartaoAnalisar: Equatable {
    case aviso(String)
    case forma(Gesto, pergunta: String)
    case vestida(Gesto, pergunta: String)
    case expressiva
    /// ADR o: a linha "?" da nota, à espera de o autor pedir a resposta
    case pergunta(String)
    /// a resposta da sábia — no cartão, nunca na nota
    case resposta(pergunta: String, texto: String)
    /// A sábia pensando (rede). ADR 2026-09-09n: a espera passou de 1,4 s para
    /// 36 s de média, e por isso ela carrega a PERGUNTA e a HORA em que começou
    /// — o cartão mostra as duas, e cancelar devolve a pergunta em vez de
    /// perdê-la. Estado da espera é da sessão, não da view (ADR 09c).
    case sabiaPensando(pergunta: String, desde: Date)
    /// vestiu tudo; um toque desfaz
    case vestido(antes: String)
    /// pediu a sábia sem conta ligada
    case semConta
}

enum DestinoConfirmacao {
    case pagina, notas, recordar
}

enum ConfirmacaoEstado: Equatable {
    case sairTranca(destino: DestinoConfirmacao)
    case trancada(destino: DestinoConfirmacao)
    case naoSeRele(UUID)
    case insistirReabrir(UUID)
    case apagar(UUID)
    case apagarTrancada(UUID)
}
