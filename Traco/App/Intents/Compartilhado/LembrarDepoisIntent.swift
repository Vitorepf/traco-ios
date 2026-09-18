import AppIntents

/// ADR 2026-09-04f — a tela bloqueada deixa de ser cartaz.
///
/// O compromisso já aparece lá (ADR 04a). Mas ver não é agir: quando o aviso
/// toca e o autor não pode atender AGORA, a única saída era abrir o app — e
/// abrir o app é justamente o que ninguém faz na fila do banco.
///
/// Um botão, um significado: **cobra de novo daqui a dez minutos.** Vale só
/// **antes** do `inicio` ("me lembra de sair"). Depois que começou, o app
/// recusa e recolhe aviso/soneca — a peça some, não cobra o que já começou.
///
/// ADR 05u: o botão carrega a OCORRÊNCIA (id + início). O app relê o disco
/// antes de agir, pede a soneca pelo orçamento de avisos (04b) e só anuncia
/// a hora depois de o centro aceitar; recusa vira recado, nunca promessa.
struct LembrarDepoisIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Lembrar em 10 min"
    static let description = IntentDescription("Cobra este compromisso de novo daqui a dez minutos.")
    static let openAppWhenRun = false

    nonisolated static let minutos = 10

    @Parameter(title: "Compromisso", default: "")
    var compromisso: String

    init() {}
    init(ocorrencia: String) { compromisso = ocorrencia }

    @MainActor
    func perform() async throws -> some IntentResult {
        #if TRACO_APP
        await ProximoCompromisso.lembrarDepois(ocorrencia: compromisso, minutos: Self.minutos)
        return .result()
        #else
        try ForaDoAlvo.recusar()
        return .result()
        #endif
    }
}
