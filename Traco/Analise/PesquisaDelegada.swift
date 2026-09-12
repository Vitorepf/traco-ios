/// ADR 2026-09-12a — pesquisa delegada (Fase 2) não abre sem a auditoria
/// do selo nas rotas de contexto (busca, Fontes, Retrato). Esta flag é o
/// portão: enquanto for falsa, nenhuma rota planta pesquisa nem chama rede
/// para achar obra.
nonisolated enum PesquisaDelegada {
    static let aberta = false

    /// Só depois do aceite. Sem aceite não há nó. Relato pessoal e pesquisa
    /// não se misturam: a nota nasce com `origem=pesquisa` e fica fora do
    /// Retrato. A flag de produção continua fechada — o parâmetro existe
    /// para a prova local, não para abrir a rede.
    @MainActor
    static func aceitar(_ texto: String, aberta: Bool = Self.aberta) -> Nota? {
        let t = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard aberta, !t.isEmpty else { return nil }
        let n = Nota(texto: t)
        n.origem = .pesquisa
        return n
    }
}
