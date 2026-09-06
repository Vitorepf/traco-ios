import AppIntents

/// O widget deixa de ser cartaz e vira botão (F2 do §12): marcar a única
/// coisa de hoje como feita sem abrir o app. Não vira streak, não conta.
///
/// ADR 04f: `LiveActivityIntent` roda no processo do APP, também dentro da
/// Live Activity; por isso o tipo é declarado nos dois alvos e só o app
/// executa (`TRACO_APP`). No widget a declaração serve ao `Button(intent:)`.
///
/// ADR 05u: o botão diz DE QUEM é (`nota` + `dia`). O app relê o Destaque de
/// hoje e só marca se ainda for este; feito é feito (nunca alterna), e o
/// desfazer é outro botão, `DestaqueDesfazerIntent`.
struct DestaqueFeitoIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Feito"
    static let description = IntentDescription("Marca a única coisa de hoje como feita.")
    static let openAppWhenRun = false

    @Parameter(title: "Nota", default: "")
    var nota: String
    @Parameter(title: "Dia", default: "")
    var dia: String

    init() {}
    init(nota: UUID, dia: String) {
        self.nota = nota.uuidString
        self.dia = dia
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        #if TRACO_APP
        guard let id = UUID(uuidString: nota) else { return .result() }
        // persistido e publicado ANTES de o cartão sair; recusa não confirma
        guard DestaqueDoDia.marcarFeito(id: id, dia: dia) else {
            await DestaqueDoDia.reconciliar()
            return .result()
        }
        await DestaqueDoDia.encerrarAtividades()
        return .result()
        #else
        try ForaDoAlvo.recusar()
        return .result()
        #endif
    }
}

/// O desfazer explícito do feito. Volta o cartão vivo (D15 da auditoria F1).
struct DestaqueDesfazerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Desfazer feito"
    static let description = IntentDescription("Volta a única coisa de hoje para não feita.")
    static let openAppWhenRun = false

    @Parameter(title: "Nota", default: "")
    var nota: String
    @Parameter(title: "Dia", default: "")
    var dia: String

    init() {}
    init(nota: UUID, dia: String) {
        self.nota = nota.uuidString
        self.dia = dia
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        #if TRACO_APP
        guard let id = UUID(uuidString: nota), DestaqueDoDia.desfazerFeito(id: id, dia: dia) else {
            await DestaqueDoDia.reconciliar()
            return .result()
        }
        await DestaqueDoDia.reconciliar()
        return .result()
        #else
        try ForaDoAlvo.recusar()
        return .result()
        #endif
    }
}

/// A extensão só declara; executar aqui seria escrever domínio fora do app.
nonisolated struct ForaDoAlvo: Error {
    static func recusar() throws { throw ForaDoAlvo() }
}
