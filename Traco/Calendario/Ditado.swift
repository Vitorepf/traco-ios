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
        let fala = await withCheckedContinuation { pronto in
            SFSpeechRecognizer.requestAuthorization { pronto.resume(returning: $0) }
        }
        guard fala == .authorized else { return false }
        return await AVAudioApplication.requestRecordPermission()
    }

    private func escutar(_ reconhecedor: SFSpeechRecognizer) {
        let novo = SFSpeechAudioBufferRecognitionRequest()
        novo.shouldReportPartialResults = true
        novo.requiresOnDeviceRecognition = true
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
        entrada.removeTap(onBus: 0)
        entrada.installTap(onBus: 0, bufferSize: 1024, format: formato) { [weak novo] buffer, _ in
            novo?.append(buffer)
        }
        motor.prepare()
        do {
            try motor.start()
        } catch {
            mostrar("não consegui abrir o microfone.")
            encerrarAudio()
            return
        }

        gravando = true
        Toque.selecao()
        tarefa = reconhecedor.recognitionTask(with: novo) { [weak self] resultado, erro in
            Task { @MainActor in
                guard let self else { return }
                if let resultado {
                    self.aoTexto?(resultado.bestTranscription.formattedString)
                    if resultado.isFinal { self.parar() }
                }
                if erro != nil { self.parar() }
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
        pedido?.endAudio()
        tarefa?.cancel()
        tarefa = nil
        pedido = nil
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
