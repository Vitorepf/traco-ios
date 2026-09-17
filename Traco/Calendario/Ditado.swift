import AVFoundation
import Foundation
import Speech
import SwiftUI

/// Ditar o compromisso em vez de digitar (pedido do dono, 03/set): o botão de
/// enviar, quando o campo está vazio, é o botão de gravar.
///
/// **No aparelho, sempre.** `requiresOnDeviceRecognition` é obrigatório aqui:
/// este fluxo tem contrato de processamento local do áudio. Isso é uma
/// decisão de privacidade, não um diagnóstico de dívida cognitiva.
/// Se o modelo local não estiver disponível para a
/// língua, o ditado RECUSA e diz por quê — nunca cai no reconhecimento remoto
/// em silêncio.
///
/// Transcrever o que a pessoa disse é assistência delegada, não uma resposta
/// inventada em seu lugar. O texto vai para o campo de prosa e daí em diante quem
/// lê é o algoritmo local de sempre.
@Observable
final class Ditado {
    private(set) var gravando = false
    /// Some sozinho; o campo de prosa não é lugar de erro permanente.
    private(set) var recado: String?

    private let motor = AVAudioEngine()
    private var pedido: SFSpeechAudioBufferRecognitionRequest?
    private var canal: LinhaDeAudio?
    private var tarefa: SFSpeechRecognitionTask?
    private var recadoTask: Task<Void, Never>?
    private let reconhecedor = SFSpeechRecognizer(locale: Locale(identifier: "pt_BR"))

    /// O que o autor falar entra aqui, cru, a cada parcial.
    var aoTexto: ((String) -> Void)?

    /// Testes injetam a máquina: `comecar` chama isto em vez de abrir o
    /// microfone, e `parar` continua sendo o mesmo caminho. Produção deixa nil.
    var motorDeTeste: ((Ditado) -> Void)?

    func alternar() {
        if gravando { parar() } else { comecar() }
    }

    // MARK: começar

    private func comecar() {
        if let motorDeTeste {
            gravando = true
            motorDeTeste(self)
            return
        }
        guard let reconhecedor, reconhecedor.isAvailable else {
            mostrar("o ditado não está disponível agora.")
            return
        }
        guard reconhecedor.supportsOnDeviceRecognition else {
            // a recusa é a decisão certa: o áudio do autor não sai do aparelho
            mostrar("o português para ditado offline não está instalado. Ajustes › Geral › Teclado › Ditado.")
            return
        }
        Task { @MainActor in
            guard await autorizado() else {
                mostrar("o ditado precisa de permissão de microfone e de fala.")
                return
            }
            escutar(reconhecedor)
        }
    }

    private func autorizado() async -> Bool {
        guard await PermissaoDeFala.pedir() == .authorized else { return false }
        return await AVAudioApplication.requestRecordPermission()
    }

    private func escutar(_ reconhecedor: SFSpeechRecognizer) {
        let novo = SFSpeechAudioBufferRecognitionRequest()
        novo.shouldReportPartialResults = true
        novo.requiresOnDeviceRecognition = true
        // sem isto o reconhecedor devolve uma tirada só, sem vírgula nem ponto
        // — e o calendário, que separa os compromissos pela pontuação, lia vinte
        // compromissos ditados como UM título gigante (relato do dono, 17/09)
        novo.addsPunctuation = true
        pedido = novo

        do {
            let sessao = AVAudioSession.sharedInstance()
            try sessao.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try sessao.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            mostrar("não consegui abrir o microfone.")
            return
        }

        let entrada = motor.inputNode
        let formato = entrada.outputFormat(forBus: 0)
        // formato inválido (fone tirado no meio) faz o install estourar
        guard formato.sampleRate > 0, formato.channelCount > 0 else {
            mostrar("não consegui abrir o microfone.")
            encerrarAudio()
            return
        }
        let linha = LinhaDeAudio(novo)
        canal = linha
        entrada.removeTap(onBus: 0)
        // `@Sendable` de propósito: tira a isolação do bloco (ver `PermissaoDeFala`).
        // Este corre na thread de tempo real do CoreAudio.
        entrada.installTap(onBus: 0, bufferSize: 1024, format: formato) { @Sendable buffer, _ in
            linha.receber(buffer)
        }
        motor.prepare()
        do {
            try motor.start()
        } catch {
            mostrar("não consegui abrir o microfone.")
            canal = nil
            encerrarAudio()
            return
        }

        gravando = true
        Toque.selecao()
        // o Speech chama isto numa fila própria: o bloco não pode ser isolado
        // (ver `PermissaoDeFala`) e só valores Sendable atravessam para a main
        tarefa = reconhecedor.recognitionTask(with: novo) { @Sendable [weak self] resultado, erro in
            let texto = resultado?.bestTranscription.formattedString
            let terminou = resultado?.isFinal ?? false
            let falhou = erro != nil
            Task { @MainActor in
                guard let self else { return }
                if let texto { self.aoTexto?(texto) }
                if terminou || falhou { self.parar() }
            }
        }
    }

    // MARK: parar

    /// Só para os testes: entrega um parcial como o reconhecedor entregaria.
    func receberParcial(_ texto: String) {
        guard gravando else { return }
        aoTexto?(texto)
    }

    func parar() {
        guard gravando || motor.isRunning else { return }
        gravando = false
        if motorDeTeste != nil { return }
        canal?.fechar()
        tarefa?.cancel()
        tarefa = nil
        pedido = nil
        canal = nil
        encerrarAudio()
        Toque.leve()
    }

    private func encerrarAudio() {
        motor.inputNode.removeTap(onBus: 0)
        if motor.isRunning { motor.stop() }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func mostrar(_ msg: String) {
        recado = msg
        AccessibilityNotification.Announcement(msg).post()
        recadoTask?.cancel()
        recadoTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            if !Task.isCancelled { self?.recado = nil }
        }
    }
}

/// A permissão de fala, pedida FORA do MainActor.
///
/// `SFSpeechRecognizer.requestAuthorization` chama o bloco "numa fila
/// arbitrária" (documentação da Apple). Neste projeto toda closure escrita
/// dentro de um tipo sem anotação nasce isolada no MainActor
/// (`SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor`, em `project.yml`), e entregar
/// uma closure dessas a um framework que a chama noutra fila é uma armadilha:
/// o Swift 6 põe a verificação de executor na ponte (SE-0423) e o processo
/// MORRE — "Incorrect actor executor assumption". Era o app a fechar no
/// primeiro toque no microfone, antes mesmo de o diálogo de permissão aparecer.
///
/// `nonisolated` aqui é o conserto: a closure nasce sem ator, e o Speech pode
/// chamá-la de onde quiser.
enum PermissaoDeFala {
    nonisolated static func pedir() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { pronto in
            SFSpeechRecognizer.requestAuthorization { pronto.resume(returning: $0) }
        }
    }
}

/// A ponte entre a thread do áudio e o pedido do Speech. Existe por duas
/// razões, as duas de quebra:
///
/// 1. o bloco do tap corre na thread de tempo real do CoreAudio, e isolado no
///    MainActor derruba o processo (ver `PermissaoDeFala`). `@Sendable` tira a
///    isolação — mas aí o bloco não pode capturar o pedido, que não é
///    Sendable. Esta caixa é o que ele captura;
/// 2. `append` depois de `endAudio` é exceção do Speech, e havia janela para
///    isso: `parar()` fechava o áudio e só depois tirava o tap, com buffers em
///    voo pelo meio. A trava fecha a janela.
private final class LinhaDeAudio: @unchecked Sendable {
    private let pedido: SFSpeechAudioBufferRecognitionRequest
    private let trava = NSLock()
    private var aberta = true

    init(_ pedido: SFSpeechAudioBufferRecognitionRequest) { self.pedido = pedido }

    func receber(_ buffer: AVAudioPCMBuffer) {
        trava.lock()
        defer { trava.unlock() }
        guard aberta else { return }
        pedido.append(buffer)
    }

    func fechar() {
        trava.lock()
        defer { trava.unlock() }
        guard aberta else { return }
        aberta = false
        pedido.endAudio()
    }
}
