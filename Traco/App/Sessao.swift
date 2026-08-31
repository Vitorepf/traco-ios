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
    var mostrarNotas = false
    var mostrarRecordar = false
    var mostrarPadroes = false
    var confirmacao: ConfirmacaoEstado?
    var recordarTexto = ""
    var recordarCampos: [String: String] = [:]
    var timerEsgotou = false

    private var toastTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var timerPrazo: Date?

    var paginaVazia: Bool {
        texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var minutosExpressiva: Int {
        max(0, (15 * 60 - segundosRestantes) / 60)
    }

    func analisar(automatica: Bool = false) {
        if timerLigado {
            if !automatica { mostrarToast("a análise cala durante a escrita.") }
            return
        }
        guard !paginaVazia else { return }
        var transacao = Transaction()
        transacao.disablesAnimations = true
        withTransaction(transacao) { cartao = nil }

        switch AnaliseLocal.classificar(texto: texto, gestoAtual: gesto, campos: campos) {
        case .silencio:
            // §17: no modo automático o silêncio é invisível — toast a cada pausa seria ruído
            if !automatica {
                Toque.leve()
                mostrarToast("silêncio.")
            }
        case .aviso(let frase):
            Toque.aviso()
            cartao = .aviso(frase)
        case .gesto(let g, let pergunta):
            Toque.leve()
            cartao = .forma(g, pergunta: pergunta)
        case .expressiva:
            Toque.leve()
            cartao = .expressiva
        }
    }

    // MARK: - §17: análise automática na pausa (o autor nunca precisa lembrar do botão)

    var autoAnalise = UserDefaults.standard.object(forKey: "autoAnalise") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoAnalise, forKey: "autoAnalise") }
    }
    private var autoTask: Task<Void, Never>?

    func agendarAutoAnalise(depois segundos: Double = 1.6) {
        autoTask?.cancel()
        guard autoAnalise, !timerLigado, !paginaVazia, gesto != .expressiva, cartao == nil else { return }
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
        trancarESair(no: context, destino: .pagina)
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
            nota.editadaEm = .now
        } else {
            let nota = Nota(texto: texto, gesto: gesto, campos: campos, trancada: trancar, expressivaPrazo: prazo)
            context.insert(nota)
            self.notaUUID = nota.uuid
        }
        try? context.save()
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
    }

    func abrir(_ nota: Nota, mesmoTrancada: Bool = false) {
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
            if minutosExpressiva >= 10 {
                trancarESair(no: context, destino: .pagina)
            } else {
                confirmacao = .sairTranca(destino: .pagina)
            }
            return
        }
        salvar(no: context)
        // FILA P1.5: a nota concluída marca a própria revisão — o Recordar chega
        // no dia certo sem o autor lembrar (§17).
        if let notaUUID, let nota = Self.buscar(uuid: notaUUID, no: context) {
            Revisoes.agendar(uuid: nota.uuid, criadaEm: nota.criadaEm, gesto: nota.gesto, trancada: nota.trancada, texto: nota.texto)
        }
        novaPagina()
        Toque.leve()
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
        guard !nota.trancada else { return }
        recordarTexto = nota.texto
        recordarCampos = nota.campos
        mostrarRecordar = true
    }

    func trancarESair(no context: ModelContext, destino: DestinoConfirmacao) {
        pararTimer()
        salvar(no: context, trancar: true)
        novaPagina()
        Toque.fechou()
        // Nota trancada não se recorda: o destino Recordar vira página.
        let destinoFinal: DestinoConfirmacao = destino == .recordar ? .pagina : destino
        if destinoFinal == .notas { mostrarNotas = true }
        confirmacao = .trancada(destino: destinoFinal)
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
}
