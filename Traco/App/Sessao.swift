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
                             trancada: nota.fechada, texto: nota.texto)
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
        guard autoAnalise, !autoSuprimidaNaNota, !timerLigado, !paginaVazia, gesto != .expressiva, cartao == nil else { return }
        autoTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(segundos))
            guard let self, !Task.isCancelled else { return }
            self.analisar(automatica: true)
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
        guard !paginaVazia else { return }
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
        trancarESair(no: context, destino: .pagina)
        confirmacao = nil
        fechoUUID = Self.ultimaTrancada(no: context)?.uuid
        fechoExpressiva = minutos
    }

    /// A recém-selada: a queima do fecho age sobre ela, mesmo depois do novaPagina.
    private static func ultimaTrancada(no context: ModelContext) -> Nota? {
        let todas = (try? context.fetch(FetchDescriptor<Nota>())) ?? []
        return todas
            .filter { $0.trancada && !$0.queimada }
            .max { $0.editadaEm < $1.editadaEm }
    }

    func salvar(no context: ModelContext, trancar: Bool = false) {
        let limpo = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !limpo.isEmpty || trancar else { return }
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
        mostrarToast(nomeGesto.map { "\($0) guardada · também no Arquivos" } ?? "guardada · também no Arquivos")
        // FILA P1.5: a nota concluída marca a própria revisão — o Recordar chega
        // no dia certo sem o autor lembrar (§17).
        // Exp 9: o corpus vive também no app Arquivos — backup sem nuvem, sem conta
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
            Corpus.backupAutomatico(notas: todas)
            // Exp 3: Spotlight indexa só as abertas (o selo vale para o sistema)
            Holofote.indexar(notas: todas.map { ($0.uuid, $0.vozDoAutor, $0.fechada) })
        }
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
            Revisoes.agendar(uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto, trancada: nota.fechada, texto: nota.texto) { [weak self] in
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
        recordarTexto = texto
        recordarCampos = campos
        salvar(no: context)
        mostrarRecordar = true
    }

    func recordarDaNotas(_ nota: Nota) {
        guard !nota.fechada else { return }
        recordarTexto = nota.texto
        recordarCampos = nota.campos
        mostrarRecordar = true
    }

    /// SPEC §8: QUEIMAR. Não é esconder — é destruir. O texto é sobrescrito antes
    /// de sumir (não basta marcar), e o backup no Arquivos é regravado na hora,
    /// senão a promessa seria mentira. Sobram data, minutos e a linha de sentido.
    func queimar(no context: ModelContext, sentido linha: String) {
        pararTimer()
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
        try? context.save()
        // nada de janela de desfazer: queimar não tem volta, e isso é o método
        apagadaRecuperavel = nil
        Revisoes.cancelar(uuid: nota.uuid)
        if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
            Corpus.backupAutomatico(notas: todas)
            Holofote.indexar(notas: todas.map { ($0.uuid, $0.vozDoAutor, $0.fechada) })
        }
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
        }
        fechoExpressiva = nil
        fechoUUID = nil
        sentidoPendente = nil
        Toque.suave()
    }

    func trancarESair(no context: ModelContext, destino: DestinoConfirmacao) {
        pararTimer()
        salvar(no: context, trancar: true)
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
    var apagadaRecuperavel: (texto: String, gesto: Gesto?, campos: [String: String], criadaEm: Date)?
    private var desfazerTask: Task<Void, Never>?

    func apagar(uuid: UUID, no context: ModelContext) {
        guard let nota = Self.buscar(uuid: uuid, no: context) else { return }
        apagadaRecuperavel = (nota.texto, nota.gesto, nota.campos, nota.criadaEm)
        Revisoes.cancelar(uuid: uuid)
        context.delete(nota)
        do {
            try context.save()
        } catch {
            apagadaRecuperavel = nil
            mostrarToast("não consegui apagar — a nota continua.")
            return
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
        let nota = Nota(texto: a.texto, gesto: a.gesto, campos: a.campos)
        nota.criadaEm = a.criadaEm
        context.insert(nota)
        try? context.save()
        apagadaRecuperavel = nil
        desfazerTask?.cancel()
        Toque.leve()
    }

    static func buscar(uuid: UUID, no context: ModelContext) -> Nota? {
        let d = FetchDescriptor<Nota>(predicate: #Predicate { $0.uuid == uuid })
        return try? context.fetch(d).first
    }

    func mostrarToast(_ msg: String) {
        toast = msg
        AccessibilityNotification.Announcement(msg).post()
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            if !Task.isCancelled { toast = nil }
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
