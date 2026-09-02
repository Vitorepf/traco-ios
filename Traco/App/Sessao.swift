import Foundation
import SwiftData
import SwiftUI

@Observable
final class Sessao {
    var texto: String = ""
    var gesto: Gesto?
    var campos: [String: String] = [:]
    var notaUUID: UUID?
    var perguntaPadroes: String?
    var cartao: CartaoAnalisar?
    var toast: String?
    /// UMA ação no toast, quando há volta (apagar com desfazer).
    var toastAcao: (rotulo: String, acao: () -> Void)?
    var timerLigado = false
    var segundosRestantes = 15 * 60
    /// SPEC §20: um destino por vez. `mostrarNotas`/`mostrarPadroes` continuam
    /// existindo como ponte para a lógica antiga (foco, rota, notificação).
    var aba: Aba = .escrever
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

    private var toastTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var timerPrazo: Date?

    var paginaVazia: Bool {
        texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var minutosExpressiva: Int {
        max(0, (15 * 60 - segundosRestantes) / 60)
    }

    private var analiseTask: Task<Void, Never>?

    func analisar(automatica: Bool = false) {
        if automatica, autoSuprimidaNaNota { return } // §17.2: o autor soltou — a nota fica quieta
        if timerLigado {
            if !automatica { mostrarToast("a análise cala durante a escrita.") }
            return
        }
        guard !paginaVazia else { return }
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
            var remoto: AnaliseLocal.Veredito?
            if gestoAtual == nil {
                remoto = await AnaliseRemota.classificar(texto: Caderno.prosa(de: textoAtual), gestoAtual: gestoAtual)
            }
            guard let self, !Task.isCancelled else { return }
            guard self.texto == textoAtual else { return } // o texto mudou em voo: silêncio
            let veredito = remoto ?? AnaliseLocal.classificar(texto: textoAtual, gestoAtual: gestoAtual, campos: camposAtuais)
            self.aplicar(veredito, automatica: automatica)
        }
    }

    private func aplicar(_ veredito: AnaliseLocal.Veredito, automatica: Bool) {
        switch veredito {
        case .silencio:
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
            if automatica {
                // §17.3: gatilho explícito = confiança alta → a forma já vem vestida,
                // com Soltar de um toque. As palavras do autor ficam intactas.
                usarForma(g)
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
        if let g = gesto {
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
        autoTask?.cancel() // uma análise armada na última tecla revestiria a nota 1,6s depois
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
                             fechada: nota.fechada, texto: nota.texto)
        }
    }

    // MARK: - Gravar na pausa (radiografia P1: só se gravava ao sair de cena)

    private var gravacaoTask: Task<Void, Never>?

    /// A pausa grava a página. Antes, `salvar` só corria ao sair de cena,
    /// trocar de camada ou concluir: um crash em primeiro plano custava a nota
    /// inteira. `salvar` reusa o notaUUID, então isto não duplica.
    /// 1,0s, não os 1,6s da análise: §21 proíbe gravar no SwiftData no mesmo
    /// instante em que a forma anima — a gravação vem 600ms ANTES do vestir.
    func agendarGravacao(no context: ModelContext, depois segundos: Double = 1.0) {
        gravacaoTask?.cancel()
        gravacaoTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(segundos))
            guard let self, !Task.isCancelled else { return }
            self.salvar(no: context)
        }
    }

    // MARK: - §17: análise automática na pausa (o autor nunca precisa lembrar do botão)

    var autoAnalise = UserDefaults.standard.object(forKey: "autoAnalise") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoAnalise, forKey: "autoAnalise") }
    }
    private var autoTask: Task<Void, Never>?

    func agendarAutoAnalise(depois segundos: Double = 1.6) {
        autoTask?.cancel()
        analiseTask?.cancel() // veredito em voo não pode vestir texto que mudou
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
    func tocarRegua(_ tocando: Bool) {
        if tocando {
            tocandoRegua = true
            autoTask?.cancel() // um veredito em voo não pode vestir sob o dedo
        } else {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(250))
                tocandoRegua = false
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
    func vestirNota() {
        guard !paginaVazia, gesto != .expressiva else { return } // §8.8: ninguém mexe no desabafo
        autoTask?.cancel()
        let vestido = Caderno.estruturar(texto)
        guard vestido != texto else {
            Toque.leve()
            mostrarToast("nada a vestir aqui.")
            return
        }
        texto = vestido
        Toque.fechou()
    }

    func usarForma(_ g: Gesto) {
        gesto = g
        campos = Dictionary(uniqueKeysWithValues: g.campos.map { ($0.id, "") })
        cartao = nil
        Toque.leve()
    }

    func comecarExpressiva(no context: ModelContext) {
        gesto = .expressiva
        cartao = nil
        iniciarTimer()
        salvar(no: context)
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
    func abrirFecho(no context: ModelContext) {
        let minutos = minutosExpressiva
        confirmacao = nil
        // o fecho age sobre ESTA nota, pelo id — não sobre "a última trancada"
        // achada por varredura, que podia ser outra se a gravação falhasse
        fechoUUID = trancarESair(no: context, destino: .pagina)
        confirmacao = nil
        fechoExpressiva = minutos
    }

    func salvar(no context: ModelContext, trancar: Bool = false) {
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        if limpo.isEmpty, !trancar {
            // O autor apagou tudo. Com a gravação na pausa a nota já está no
            // banco — e ficaria lá com o texto velho para sempre. Como no
            // Notes: nota esvaziada some. Nunca uma fechada, nunca uma com
            // resposta de campo (isso é conteúdo).
            if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context),
               !nota.fechada, nota.campos.values.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                Revisoes.cancelar(uuid: notaUUID)
                context.delete(nota)
                try? context.save()
                self.notaUUID = nil
            }
            return
        }
        let prazo = (timerLigado && !trancar) ? timerPrazo : nil
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
            nota.texto = texto
            nota.gesto = gesto
            nota.campos = campos
            nota.expressivaPrazo = prazo
            if trancar { nota.trancada = true }
            if let sentidoPendente { nota.sentido = sentidoPendente }
            nota.minutosEscritos = max(nota.minutosEscritos, minutosExpressiva)
            nota.editadaEm = .now
        } else {
            let nota = Nota(texto: texto, gesto: gesto, campos: campos, trancada: trancar,
                            expressivaPrazo: prazo,
                            minutosEscritos: minutosExpressiva,
                            sentido: sentidoPendente ?? "")
            context.insert(nota)
            self.notaUUID = nota.uuid
        }
        do {
            try context.save()
        } catch {
            // A escrita do autor nunca se perde em silêncio: o texto segue na página
            // e o aviso diz isso. (Tranca de expressiva continua garantida pelo
            // expressivaPrazo persistido na próxima gravação/arranque.)
            mostrarToast("não consegui gravar — o texto continua na página.")
        }
    }

    /// A ÚNICA porta para o disco: tudo que muda o banco (concluir, selar,
    /// queimar, apagar, importar, a linha de sentido) passa por aqui. Antes, só
    /// concluir e queimar regravavam — uma nota apagada continuava legível no
    /// app Arquivos e na busca do iOS até o próximo Concluir de outra nota.
    /// ponytail: fetch de tudo + corpus inteiro + reindex, no MainActor, por
    /// evento (não por tecla — `salvar` da pausa não passa aqui). Teto: ~2 mil
    /// notas começa a hesitar; aí `Corpus.gravar` recebe uma String e vai para
    /// uma Task.detached, e o índice reindexa só a nota tocada.
    func refletirNoDisco(no context: ModelContext) {
        // Em emergência o banco da RAM não é o corpus: nem backup nem índice
        // podem ser reescritos a partir dele.
        guard !Arranque.bancoEmMemoria else { return }
        guard let todas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        Corpus.backupAutomatico(notas: todas)
        // Spotlight indexa só as abertas (o selo vale para o sistema)
        Holofote.indexar(notas: todas.map { ($0.uuid, $0.vozDoAutor, $0.fechada) })
    }

    /// Expressiva vencida sobrevive à morte do processo: a notas não pode vazar o texto.
    func trancarExpressivasVencidas(no context: ModelContext, agora: Date = .now) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        var mudou = false
        for nota in notas {
            guard nota.gesto == .expressiva, !nota.trancada, let prazo = nota.expressivaPrazo, prazo <= agora else { continue }
            nota.trancada = true
            nota.expressivaPrazo = nil
            mudou = true
        }
        if mudou { try? context.save() }
    }

    /// P0 6: no arranque, anexos sem marcador em NOTA NENHUMA (trancadas incluídas —
    /// o texto delas segue referenciando os arquivos) saem do disco.
    func varrerAnexosOrfaos(no context: ModelContext) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        var textos = notas.map(\.texto)
        textos.append(texto) // a página aberta também referencia
        AnexoDisco.varrerOrfaos(textos: textos)
    }

    func novaPagina() {
        pararTimer()
        gravacaoTask?.cancel() // a gravação armada era da página que acabou
        texto = ""
        gesto = nil
        campos = [:]
        notaUUID = nil
        perguntaPadroes = nil
        cartao = nil
        confirmacao = nil
        recordarTexto = ""
        recordarCampos = [:]
        autoSuprimidaNaNota = false
    }

    func abrir(_ nota: Nota, mesmoTrancada: Bool = false) {
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
        gravacaoTask?.cancel()
        autoSuprimidaNaNota = false // §17.2: o opt-out é POR NOTA — esta é outra
        texto = nota.texto
        gesto = nota.gesto
        campos = nota.campos
        notaUUID = nota.uuid
        perguntaPadroes = nil
        cartao = nil
        mostrarNotas = false
        mostrarPadroes = false
        if nota.gesto == .expressiva, !nota.trancada {
            retomarExpressiva(prazo: nota.expressivaPrazo)
        }
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
        let nomeGesto = gesto?.nome.lowercased()
        salvar(no: context)
        // peak-end-rule: o fim do percurso não devolvia NADA — nem confirmação,
        // nem onde a nota foi parar. Uma linha, e ela some sozinha.
        if Arranque.bancoEmMemoria {
            mostrarToast("não ficou: as notas não abriram.")
        } else {
            mostrarToast(nomeGesto.map { "\($0) guardada · também no Arquivos" } ?? "guardada · também no Arquivos")
        }
        // Exp 9: o corpus vive também no app Arquivos — backup sem nuvem, sem conta
        refletirNoDisco(no: context)
        // FILA P1.5: a nota concluída marca a própria revisão — o Recordar chega
        // no dia certo sem o autor lembrar (§17).
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
            Revisoes.agendar(uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto, fechada: nota.fechada, texto: nota.texto) { [weak self] in
                Task { @MainActor in
                    self?.mostrarToast("revisões precisam de permissão — Ajustes › Traço › Notificações.")
                }
            }
        }
        novaPagina()
        Toque.leve()
    }

    /// Trocar de aba NUNCA perde texto: salva antes de sair (§20).
    /// Com o timer da expressiva rodando, a saída pede confirmação — o selo vale.
    func irPara(_ nova: Aba, no context: ModelContext) {
        guard nova != aba else { return }
        if timerLigado, nova != .escrever {
            confirmacao = .sairTranca(destino: .notas)
            return
        }
        salvar(no: context)
        Teclado.recolher()
        if nova != .escrever { abaArquivo = nova }
        aba = nova
    }

    /// "Nova nota" por QUALQUER porta (barra do arquivo, widget, traco://,
    /// Atalhos): com o timer da expressiva rodando, a saída pede confirmação —
    /// o selo vale também aqui. Antes, a rota do widget parava o timer em
    /// silêncio e deixava o desabafo destrancado no banco.
    func novaNota(no context: ModelContext) {
        if timerLigado {
            confirmacao = .sairTranca(destino: .pagina)
            return
        }
        salvar(no: context)
        novaPagina()
        aba = .escrever
    }

    func irNotas(no context: ModelContext) {
        if timerLigado {
            confirmacao = .sairTranca(destino: .notas)
            return
        }
        salvar(no: context)
        Teclado.recolher()
        mostrarNotas = true
    }

    func irRecordar(no context: ModelContext) {
        guard !paginaVazia else { return }
        // A cópia só acontece quando o Recordar vai mesmo abrir: durante o timer,
        // nada é capturado — a expressiva não pode vazar por esta rota.
        if timerLigado {
            confirmacao = .sairTranca(destino: .recordar)
            return
        }
        guard gesto != .expressiva else { return } // selada reaberta não se recorda
        recordarTexto = texto
        recordarCampos = campos
        salvar(no: context)
        mostrarRecordar = true
    }

    func recordarDaNotas(_ nota: Nota) {
        // fechada: só a linha de sentido se recorda (SPEC §8.5) — nunca o texto
        let texto = nota.fechada ? nota.sentido : nota.texto
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        recordarTexto = texto
        recordarCampos = nota.fechada ? [:] : nota.campos
        mostrarRecordar = true
    }

    /// Rota "Recordar" do widget (U4): recorda a nota em voo, se houver; senão a
    /// mais recente que ainda se relê. Sem nada a recordar, abre as notas — o
    /// toque do widget nunca cai no vazio.
    func recordarMaisRecente(no context: ModelContext) {
        // a página em voo, se se recorda (uma expressiva — selada reaberta ou
        // em curso — não se recorda: cai na lista, nunca no vazio)
        if !paginaVazia, gesto != .expressiva { irRecordar(no: context); return }
        var desc = FetchDescriptor<Nota>(sortBy: [SortDescriptor(\.editadaEm, order: .reverse)])
        desc.fetchLimit = 8
        if let nota = (try? context.fetch(desc))?.first(where: { !$0.fechada }) {
            recordarDaNotas(nota)
        } else {
            mostrarNotas = true
        }
    }

    /// SPEC §8: QUEIMAR. Não é esconder — é destruir. O texto é sobrescrito antes
    /// de sumir (não basta marcar), e o backup no Arquivos é regravado na hora,
    /// senão a promessa seria mentira. Sobram data, minutos e a linha de sentido.
    func queimar(no context: ModelContext, sentido linha: String) {
        pararTimer()
        let minutos = minutosExpressiva
        let corte = linha.trimmingCharacters(in: .whitespacesAndNewlines)
        // sem alvo, nada se inventa: uma nota vazia "queimada" diria que
        // queimou o que continua selado no banco — a mentira que §8.6 proíbe
        guard let alvo = fechoUUID ?? notaUUID, let nota = Self.buscar(uuid: alvo, no: context) else {
            mostrarToast("não há o que queimar.")
            fechoExpressiva = nil
            sentidoPendente = nil
            fechoUUID = nil
            return
        }
        // A cinza não guarda o texto. A promessa é de PRODUTO (nenhuma rota do
        // app lê o que foi queimado), não de disco: o SQLite pode guardar
        // páginas velhas no WAL, e "sobrescrever antes de esvaziar" em memória
        // não muda isso — só o que chega ao banco é a string vazia.
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
        try? context.save()
        // nada de janela de desfazer: queimar não tem volta, e isso é o método
        apagadaRecuperavel = nil
        Revisoes.cancelar(uuid: nota.uuid)
        refletirNoDisco(no: context)
        novaPagina()
        Toque.fechou()
        confirmacao = nil
        fechoExpressiva = nil
        sentidoPendente = nil
        fechoUUID = nil
    }

    /// O "Selar" do fecho: a nota já está selada; aqui só grava a linha de
    /// sentido, que vive FORA do selo e entra no corpus.
    func guardarSentidoDoFecho(_ linha: String, no context: ModelContext) {
        if let alvo = fechoUUID, let nota = Self.buscar(uuid: alvo, no: context) {
            nota.sentido = linha.trimmingCharacters(in: .whitespacesAndNewlines)
            nota.editadaEm = .now
            try? context.save()
            refletirNoDisco(no: context) // a linha de sentido entra no corpus (§8.5)
        }
        fechoExpressiva = nil
        fechoUUID = nil
        sentidoPendente = nil
        Toque.suave()
    }

    /// Devolve o id da nota selada — antes de `novaPagina` o limpar.
    @discardableResult
    func trancarESair(no context: ModelContext, destino: DestinoConfirmacao) -> UUID? {
        pararTimer()
        salvar(no: context, trancar: true)
        let selada = notaUUID
        refletirNoDisco(no: context)
        sentidoPendente = nil
        fechoExpressiva = nil
        novaPagina()
        Toque.fechou()
        // Nota trancada não se recorda: o destino Recordar vira página.
        let destinoFinal: DestinoConfirmacao = destino == .recordar ? .pagina : destino
        if destinoFinal == .notas { mostrarNotas = true }
        confirmacao = .trancada(destino: destinoFinal)
        return selada
    }

    /// ADR 2026-08-31f: apagar apaga de verdade — nota, revisão marcada e,
    /// passada a janela, os anexos que só ela referenciava.
    /// Dia 200: a confirmação vira piloto automático — por isso existe a janela
    /// de desfazer: 6s com "Desfazer" no toast (radiografia 02/set: a janela
    /// existia sem botão nenhum). A cópia é uma Nota INTEIRA fora do banco:
    /// desfazer devolve trancada, queimada, minutos e a linha de sentido —
    /// e os anexos, porque a varredura só corre quando a janela fecha.
    var apagadaRecuperavel: Nota?
    private var desfazerTask: Task<Void, Never>?

    func apagar(uuid: UUID, no context: ModelContext) {
        guard let nota = Self.buscar(uuid: uuid, no: context) else { return }
        let copia = Nota(
            texto: nota.texto, gesto: nota.gesto, campos: nota.campos, trancada: nota.trancada,
            criadaEm: nota.criadaEm, editadaEm: nota.editadaEm, expressivaPrazo: nota.expressivaPrazo,
            queimada: nota.queimada, queimadaEm: nota.queimadaEm,
            minutosEscritos: nota.minutosEscritos, sentido: nota.sentido
        )
        Revisoes.cancelar(uuid: uuid)
        context.delete(nota)
        do {
            try context.save()
        } catch {
            mostrarToast("não consegui apagar — a nota continua.")
            return
        }
        apagadaRecuperavel = copia
        if notaUUID == uuid { novaPagina() }
        refletirNoDisco(no: context)
        confirmacao = nil
        Toque.fechou()
        mostrarToast("apagada.", acao: ("Desfazer", { [weak self] in self?.desfazerApagar(no: context) }), duracao: 6)
        desfazerTask?.cancel()
        desfazerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard let self, !Task.isCancelled else { return }
            self.apagadaRecuperavel = nil
            self.varrerAnexosOrfaos(no: context) // só agora: desfazer devolvia a nota sem as fotos
        }
    }

    func desfazerApagar(no context: ModelContext) {
        guard let nota = apagadaRecuperavel else { return }
        context.insert(nota)
        try? context.save()
        refletirNoDisco(no: context)
        apagadaRecuperavel = nil
        desfazerTask?.cancel()
        toastTask?.cancel()
        toast = nil
        toastAcao = nil
        Toque.leve()
    }

    static func buscar(uuid: UUID, no context: ModelContext) -> Nota? {
        let d = FetchDescriptor<Nota>(predicate: #Predicate { $0.uuid == uuid })
        return try? context.fetch(d).first
    }

    func mostrarToast(_ msg: String, acao: (rotulo: String, acao: () -> Void)? = nil, duracao: Double = 2.5) {
        toast = msg
        toastAcao = acao
        AccessibilityNotification.Announcement(msg).post()
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(for: .seconds(duracao))
            if !Task.isCancelled { toast = nil; toastAcao = nil }
        }
    }
}

enum CartaoAnalisar: Equatable {
    case aviso(String)
    case forma(Gesto, pergunta: String)
    case vestida(Gesto, pergunta: String)
    case expressiva
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
