import AppIntents

/// ADR 2026-09-05w — captar pensamento em um toque.
///
/// O intent de ABERTURA compartilhado: o controle da Central de Controle e
/// da tela bloqueada, o botão de Ação e o atalho chegam por aqui e o app
/// abre já gravando (`Rota.ditar`, ADR 06c). É
/// declarado nos dois alvos porque o `ControlWidgetButton` precisa do tipo;
/// só o app executa (`TRACO_APP`), como os intents da tela bloqueada.
///
/// Nada de microfone aqui: a extensão não grava. ADR 06c: o que o app abre
/// agora é o DITADO PRÓPRIO — grava o áudio e o deposita antes de qualquer
/// letra. `Rota.ditar()` e não `Rota.ir(.captura(ditado:))`: a `.captura`
/// levanta o teclado, e teclado por trás da gravação é ruído. A página em
/// branco com o teclado pronto (ADR 05w) continua sendo a saída do estado
/// "sem microfone" — a superfície a oferece por `Escrever em vez disso`.
struct CapturarIntent: AppIntent {
    static let title: LocalizedStringResource = "Abrir para anotar"
    static let description = IntentDescription("Abre o Traço já gravando: o áudio é guardado primeiro e transcrito depois.")
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
        Rota.ditar()
        #endif
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try Self.executar()
        return .result()
    }
}
