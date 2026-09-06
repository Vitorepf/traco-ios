import AppIntents

/// ADR 2026-09-05w — captar pensamento em um toque.
///
/// O intent de ABERTURA compartilhado: o controle da Central de Controle e
/// da tela bloqueada, o botão de Ação e o atalho chegam por aqui e o app
/// abre na Página em branco com o teclado pronto (`Rota.captura`). É
/// declarado nos dois alvos porque o `ControlWidgetButton` precisa do tipo;
/// só o app executa (`TRACO_APP`), como os intents da tela bloqueada.
///
/// Nada de microfone aqui: a extensão não grava, e o ditado do teclado é do
/// sistema — o app o deixa a um toque, não o dispara (iOS não expõe isso).
/// O ditado próprio (áudio salvo primeiro, transcrito depois) é a superfície
/// seguinte e entra pelo mesmo `ditado: true`.
struct CapturarIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir para anotar"
    static let description = IntentDescription("Abre o Traço numa página em branco, com o teclado pronto para ditar ou escrever.")
    static let openAppWhenRun = true

    /// Decidido pelo alvo em tempo de compilação; o teste passa `false`.
    static let noApp: Bool = {
        #if TRACO_APP
        true
        #else
        false
        #endif
    }()

    @MainActor
    static func executar(noApp: Bool = noApp) throws {
        guard noApp else { try ForaDoAlvo.recusar(); return }
        #if TRACO_APP
        Rota.ir(.captura(ditado: true))
        #endif
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try Self.executar()
        return .result()
    }
}
