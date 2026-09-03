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
            if !dominioTravado {
                dominio = Dominio.inferir(voz: VozDoAutor.juntar(texto: texto, campos: campos))
            }
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
                             trancada: nota.fechada, texto: nota.texto, campos: nota.campos)
        }
    }

    func cobrarAntesPendente() {
        guard let uuid = recordarUUID ?? revisaoPendente else { return }
        Revisoes.cobrarAntes(uuid)
        Toque.leve()
        mostrarToast("volta em 3 dias.")
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
    func abrirFecho(no context: ModelContext) {
        let minutos = minutosExpressiva
        confirmacao = nil
        pararTimer()
        // o selo tem de estar no disco ANTES de a página virar: com o disco
        // recusando, quinze minutos de escrita sumiam e o toast dizia o contrário
        guard salvar(no: context, trancar: true) else { return }
        let alvo = notaUUID
        sentidoPendente = nil
        novaPagina()
        Toque.fechou()
        fechoUUID = alvo
        fechoExpressiva = minutos
        if let uuid = alvo, let nota = Self.buscar(uuid: uuid, no: context) {
            sentidosDaSerie = Self.sentidosAnteriores(nota, no: context)
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
        if let notaUUID, let existente = Self.buscar(uuid: notaUUID, no: context) {
            // a versão anterior fica guardada ANTES de sobrescrever (ADR m);
            // a expressiva nunca: o que queima não pode sobreviver aqui
            if existente.texto != texto || existente.campos != campos {
                Versoes.registrar(existente.uuid, texto: existente.texto, campos: existente.campos,
                                  gesto: existente.gesto, fechada: existente.fechada)
            }
            existente.texto = texto
            existente.gesto = gesto
            existente.campos = campos
            existente.expressivaPrazo = prazo
            if trancar {
                existente.trancada = true
                // o selo vale para o disco: nada do texto selado fica em Arquivos
                Versoes.apagar(existente.uuid)
                Apontar.apagar(existente.uuid)
            }
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
        aplicarDestaque(na: nota)
        guard persistir(context) else {
            // A escrita do autor nunca se perde em silêncio: o texto segue na página
            // e o aviso diz isso. (Tranca de expressiva continua garantida pelo
            // expressivaPrazo persistido na próxima gravação/arranque.)
            mostrarToast("não consegui gravar — o texto continua na página.")
            return false
        }
        return true
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
            let voz = VozDoAutor.juntar(texto: texto, campos: campos, sentido: sentidoPendente ?? "")
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
        let fonte = (gesto == .seEntao || gesto == .woop)
            ? (campos["se"] ?? campos["plano"] ?? "")
            : ""
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
        DestaqueDoDia.apagar(id: nota.uuid)
    }

    func desfazerDominio() {
        dominio = nil
        dominioTravado = true
        Toque.leve()
    }

    /// ADR 2026-09-02c: um toque no chip tira o rótulo e trava. Se o disco
    /// recusa, o rótulo continua — o gesto não mente.
    @discardableResult
    func soltarDominio(_ nota: Nota, no context: ModelContext) -> Bool {
        nota.soltarDominio()
        guard persistir(context) else {
            mostrarToast("não consegui soltar o domínio — o rótulo continua.")
            return false
        }
        Toque.leve()
        return true
    }

    /// Expressiva vencida sobrevive à morte do processo: a notas não pode vazar o texto.
    func trancarExpressivasVencidas(no context: ModelContext, agora: Date = .now) {
        guard let notas = try? context.fetch(FetchDescriptor<Nota>()) else { return }
        var mudou = false
        var recem: Nota?
        for nota in notas {
            guard nota.gesto == .expressiva, !nota.fechada, let prazo = nota.expressivaPrazo, prazo <= agora else { continue }
            nota.trancada = true
            nota.expressivaPrazo = nil
            Versoes.apagar(nota.uuid)
            Apontar.apagar(nota.uuid)
            recem = nota
            mudou = true
        }
        if mudou {
            guard persistir(context) else {
                mostrarToast("não consegui trancar — a nota continua aberta.")
                return
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
            if let todas = try? context.fetch(FetchDescriptor<Nota>()) {
                Corpus.backupAutomatico(notas: todas)
            }
        }
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
        geracaoDaPagina += 1
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
        Versoes.registrar(nota.uuid, texto: nota.texto, campos: nota.campos,
                          gesto: nota.gesto, fechada: nota.fechada)
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
        Toque.suave()
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
        dominio = nota.dominio
        dominioTravado = nota.dominioTravado
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
        guard temVoz else { return }
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
            Holofote.indexar(notas: todas)
        }
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
            Revisoes.agendar(uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto, trancada: nota.fechada, texto: nota.texto, campos: nota.campos) { [weak self] in
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
        filaAtiva = false
        filaUUIDs = []
        recordarTexto = texto
        recordarCampos = campos
        recordarGesto = gesto
        recordarUUID = notaUUID
        salvar(no: context)
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
        continuarSerie(na: nota)
        guard persistir(context) else {
            mostrarToast("não consegui queimar — o texto continua.")
            return false
        }
        // nada de janela de desfazer: queimar não tem volta, e isso é o método
        apagadaRecuperavel = nil
        Versoes.apagar(nota.uuid)
        Apontar.apagar(nota.uuid)
        Revisoes.cancelar(uuid: nota.uuid)
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
        _ itens: [(texto: String, gestoNome: String?, criadaEm: Date)],
        no context: ModelContext
    ) -> Int {
        guard !itens.isEmpty else { return 0 }
        for item in itens {
            let gesto = item.gestoNome.flatMap(Gesto.doNome)
            let (corpo, campos) = Corpus.separarCampos(texto: item.texto, gesto: gesto)
            let nota = Nota(texto: corpo, gesto: gesto, campos: campos)
            nota.criadaEm = item.criadaEm
            context.insert(nota)
        }
        guard persistir(context) else {
            mostrarToast("não consegui importar — as notas não entraram.")
            return 0
        }
        let n = itens.count
        mostrarToast("\(n) nota\(n == 1 ? "" : "s") importada\(n == 1 ? "" : "s").")
        return n
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
    var apagadaRecuperavel: NotaRecuperavel?
    private var desfazerTask: Task<Void, Never>?

    func apagar(uuid: UUID, no context: ModelContext) {
        guard let nota = Self.buscar(uuid: uuid, no: context) else { return }
        apagadaRecuperavel = nota.retrato()
        Revisoes.cancelar(uuid: uuid)
        Revisoes.cancelarGatilho(uuid: uuid)
        if let serie = nota.serieUUID { Revisoes.cancelarSerie(serie: serie) }
        context.delete(nota)
        do {
            try context.save()
        } catch {
            apagadaRecuperavel = nil
            mostrarToast("não consegui apagar — a nota continua.")
            return
        }
        DestaqueDoDia.apagar(id: uuid)
        Versoes.apagar(uuid)
        Apontar.apagar(uuid)
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
        do {
            try context.save()
        } catch {
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
