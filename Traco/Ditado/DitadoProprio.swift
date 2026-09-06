import AVFoundation
import Foundation
import Speech

/// ADR 2026-09-06c — o áudio antes da letra.
///
/// A F3 (ADR 05w) trouxe o autor de fora do app até a página em branco com o
/// teclado pronto, mas quem transcrevia era o ditado do teclado do iOS: se a
/// transcrição falhasse, se faltasse rede ou se o app morresse, **não ficava
/// nada**. A ADR 05a pede o contrário — o áudio é depositado primeiro, a letra
/// vem depois, e falha de transcrição PRESERVA o áudio.
///
/// Aqui o microfone e o reconhecedor são duas coisas separadas de propósito:
/// `AVAudioRecorder` escreve o m4a direto no destino final do anexo (o áudio
/// nasce depositado), e só DEPOIS de a nota estar no disco a transcrição
/// começa. Permissão de fala negada não impede gravar: impede só a letra.
///
/// **No aparelho, sempre.** `requiresOnDeviceRecognition` é contrato de
/// privacidade (o mesmo do `Ditado` do calendário): o áudio do autor não sai
/// do aparelho. Sem o modelo local da língua, o ditado RECUSA a letra e diz
/// por quê — nunca cai no reconhecimento remoto em silêncio.
@MainActor
@Observable
final class DitadoProprio {
    /// Gravado, transcrito e conferido são três coisas diferentes — e a tela
    /// as diz por nomes diferentes. `transcrevendo` já significa "o áudio está
    /// no disco": é o estado que uma morte do app deixa para trás, e é verdade.
    enum Estado: Equatable {
        case gravando
        case transcrevendo
        case transcrito(String)
        /// O áudio ficou; a letra não veio. O motivo é curto e honesto.
        case semLetra(String)
        /// Nem gravar deu: sem microfone não há depósito nenhum.
        case semMicrofone(String)
        /// O microfone OUVIU e o m4a está no disco — quem recusou foi a nota.
        /// Tem nome próprio porque a tela dizia "Sem microfone./Nada foi
        /// gravado" com o áudio gravado ao lado (G3, A1): mentira na recusa.
        case semDeposito(String)
    }

    private(set) var estado: Estado = .gravando
    private(set) var segundos = 0
    /// 0…1, o que o microfone está ouvindo agora. Só informação: sem nível, o
    /// autor não tem como saber se falou para um microfone mudo.
    private(set) var nivel: Double = 0
    private(set) var notaCriada = false

    let id = UUID()
    let comecouEm: Date

    /// Grava a nota do ditado: a PRIMEIRA chamada cria, as seguintes reescrevem
    /// a mesma. `false` = o disco recusou — e aí nada se confirma na tela.
    @ObservationIgnored var gravarNota: (String) -> Bool = { _ in false }

    /// Leva o autor à nota que acabou de nascer. `nil` = ninguém ligou o
    /// ditado ao disco (testes), e a tela não oferece o caminho.
    @ObservationIgnored var abrirANota: (() -> Void)?

    // MARK: injeções (testes e ensaio de estado; produção deixa nil)

    /// Devolve o motivo da recusa, ou `nil` se o microfone abriu.
    @ObservationIgnored var abrirMicrofone: ((URL) async -> String?)?
    @ObservationIgnored var fecharMicrofone: (() -> Void)?
    /// O que o reconhecedor devolve: a letra, ou o motivo honesto de ela não
    /// ter vindo. Não é `Result`: falha de transcrição não é erro do programa,
    /// é um estado que a tela mostra com o áudio ao lado.
    enum Letra: Equatable, Sendable {
        case veio(String)
        case naoVeio(String)
    }

    @ObservationIgnored var transcritor: ((URL) async -> Letra)?

    private var gravador: AVAudioRecorder?
    private var relogio: Task<Void, Never>?

    init(comecouEm: Date = .now) {
        self.comecouEm = comecouEm
    }

    /// O arquivo do anexo: o mesmo cofre de toda mídia do Traço, que é o que
    /// faz o áudio ser TOCÁVEL de dentro da nota (`traco://audio/<id>`).
    var urlDoAudio: URL { AnexoDisco.url(id.uuidString, nome: TextoDoDitado.nomeDoArquivo(comecouEm)) }

    // MARK: - começar

    func comecar() async {
        if let motivo = await abrir(urlDoAudio) {
            estado = .semMicrofone(motivo)
            return
        }
        estado = .gravando
        Toque.selecao()
        contarOTempo()
    }

    private func abrir(_ url: URL) async -> String? {
        if let abrirMicrofone { return await abrirMicrofone(url) }
        guard await AVAudioApplication.requestRecordPermission() else {
            return "o Traço precisa do microfone para gravar."
        }
        return abrirGravadorReal()
    }

    /// Abre o microfone de verdade e começa a escrever o m4a NO DESTINO FINAL
    /// do anexo: o áudio nasce depositado, não é copiado para lá no fim.
    private func abrirGravadorReal() -> String? {
        do {
            let sessao = AVAudioSession.sharedInstance()
            try sessao.setCategory(.record, mode: .spokenAudio, options: [.duckOthers])
            try sessao.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            return "não consegui abrir o microfone."
        }
        let ajustes: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]
        do {
            try FileManager.default.createDirectory(at: urlDoAudio.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            let novo = try AVAudioRecorder(url: urlDoAudio, settings: ajustes)
            novo.isMeteringEnabled = true
            guard novo.record() else { return "não consegui abrir o microfone." }
            gravador = novo
            return nil
        } catch {
            return "não consegui abrir o microfone."
        }
    }

    private func contarOTempo() {
        relogio?.cancel()
        relogio = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, case .gravando = estado else { return }
                if let g = gravador {
                    g.updateMeters()
                    // -60 dB (silêncio) … 0 dB (estouro) em 0…1
                    nivel = max(0, min(1, (Double(g.averagePower(forChannel: 0)) + 60) / 60))
                    segundos = Int(g.currentTime)
                } else {
                    segundos = Int(Date.now.timeIntervalSince(comecouEm))
                }
            }
        }
    }

    // MARK: - concluir: o áudio antes da letra

    func concluir() async {
        guard estado == .gravando else { return }
        relogio?.cancel()
        fechar()
        await depositar()
    }

    /// A recuperação do disco recusado: o m4a continua no aparelho, então a
    /// segunda tentativa é o MESMO depósito, não uma gravação nova.
    func depositarDeNovo() async {
        guard case .semDeposito = estado else { return }
        await depositar()
    }

    /// 1. O DEPÓSITO. A nota entra no disco agora, sem uma letra: se o app
    ///    morrer no passo seguinte, o autor acha a frase gravada e a linha
    ///    diz a verdade — nunca finge que transcreveu.
    /// 2. A LETRA, depois. Falha aqui não desfaz nada.
    private func depositar() async {
        guard gravarNota(TextoDoDitado.corpo(id: id, quando: comecouEm)) else {
            estado = .semDeposito("o disco recusou.")
            Toque.aviso()
            return
        }
        notaCriada = true
        estado = .transcrevendo
        Toque.leve()
        await pedirALetra()
    }

    /// Antes do depósito o áudio ainda não é trabalho guardado: descartar aqui
    /// não perde nada do autor. Depois do depósito o botão nem existe.
    func descartar() {
        relogio?.cancel()
        fechar()
        guard !notaCriada else { return }
        try? FileManager.default.removeItem(at: urlDoAudio)
    }

    /// A recuperação do caminho de falha: o áudio está lá, tenta a letra de novo.
    func tentarDeNovo() async {
        guard case .semLetra = estado else { return }
        estado = .transcrevendo
        await pedirALetra()
    }

    private func pedirALetra() async {
        switch await (transcritor ?? Self.transcreverNoAparelho)(urlDoAudio) {
        case .veio(let texto) where !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty:
            // M1 do G3: a troca de estado é seca de propósito, e a ADR diz que
            // quem marca a mudança é o háptico — então ele tem de existir nas
            // DUAS trocas em que o autor está esperando um resultado.
            if gravarNota(TextoDoDitado.corpo(id: id, quando: comecouEm, transcricao: texto)) {
                estado = .transcrito(texto)
                Toque.fechou()
            } else {
                estado = .semLetra("não consegui guardar a transcrição.")
                Toque.aviso()
            }
        case .veio:
            estado = .semLetra("não ouvi palavra nenhuma.")
            Toque.aviso()
        case .naoVeio(let motivo):
            // a nota fica com o áudio e a linha honesta; nada some, nada finge
            _ = gravarNota(TextoDoDitado.corpo(id: id, quando: comecouEm, motivo: motivo))
            estado = .semLetra(motivo)
            Toque.aviso()
        }
    }

    private func fechar() { (fecharMicrofone ?? { [weak self] in self?.fecharGravadorReal() })() }

    private func fecharGravadorReal() {
        gravador?.stop()
        gravador = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - o reconhecedor, no aparelho e só

    private static let transcreverNoAparelho: (URL) async -> Letra = { url in
        guard let reconhecedor = SFSpeechRecognizer(locale: Locale(identifier: "pt_BR")), reconhecedor.isAvailable else {
            return .naoVeio("o reconhecimento de fala não está disponível agora.")
        }
        guard reconhecedor.supportsOnDeviceRecognition else {
            // A recusa é a decisão certa: o áudio do autor não sai do aparelho.
            return .naoVeio("o português para ditado offline não está instalado. Ajustes › Geral › Teclado › Ditado.")
        }
        let permissao = await withCheckedContinuation { pronto in
            SFSpeechRecognizer.requestAuthorization { pronto.resume(returning: $0) }
        }
        guard permissao == .authorized else {
            return .naoVeio("o reconhecimento de fala está desligado nos Ajustes.")
        }
        let pedido = SFSpeechURLRecognitionRequest(url: url)
        pedido.requiresOnDeviceRecognition = true
        pedido.shouldReportPartialResults = false
        return await withCheckedContinuation { pronto in
            nonisolated(unsafe) var respondeu = false
            reconhecedor.recognitionTask(with: pedido) { resultado, erro in
                guard !respondeu else { return }
                if let resultado, resultado.isFinal {
                    respondeu = true
                    pronto.resume(returning: .veio(resultado.bestTranscription.formattedString))
                } else if erro != nil {
                    respondeu = true
                    pronto.resume(returning: .naoVeio("a transcrição falhou no aparelho."))
                }
            }
        }
    }
}
