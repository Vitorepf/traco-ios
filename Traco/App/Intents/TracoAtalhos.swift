import AppIntents

/// As frases de Siri e os atalhos sugeridos (ADR 05u: o catálogo mora em
/// `Traco/App/Intents/`; nomes de tipos e parâmetros preservados para que
/// atalho salvo no aparelho do autor continue a funcionar).
struct TracoAtalhos: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NovaNotaIntent(),
            phrases: ["Nova nota no \(.applicationName)", "Escrever no \(.applicationName)"],
            shortTitle: "Nova nota",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: AnotarIntent(),
            phrases: ["Anotar no \(.applicationName)", "Anota no \(.applicationName)"],
            shortTitle: "Anotar",
            systemImageName: "text.append"
        )
        AppShortcut(
            intent: AbrirNotasIntent(),
            phrases: ["Minhas notas no \(.applicationName)"],
            shortTitle: "Notas",
            systemImageName: "list.bullet"
        )
        AppShortcut(
            intent: DestaqueDeHojeIntent(),
            phrases: ["Destaque de hoje no \(.applicationName)", "Qual é o meu destaque no \(.applicationName)"],
            shortTitle: "Destaque de hoje",
            systemImageName: "sparkle"
        )
        AppShortcut(
            intent: CompromissosDeHojeIntent(),
            phrases: ["Meu dia no \(.applicationName)", "O que tenho hoje no \(.applicationName)"],
            shortTitle: "Meu dia",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: LinhasDeSentidoIntent(),
            phrases: ["Linhas de sentido do \(.applicationName)"],
            shortTitle: "Linhas de sentido",
            systemImageName: "text.quote"
        )
        AppShortcut(
            intent: EstaSemanaIntent(),
            phrases: ["Minha semana no \(.applicationName)", "Esta semana no \(.applicationName)"],
            shortTitle: "Esta semana",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: TrajetoriaIntent(),
            phrases: ["Minha trajetória no \(.applicationName)"],
            shortTitle: "Trajetória",
            systemImageName: "point.topleft.down.to.point.bottomright.curvepath"
        )
        AppShortcut(
            intent: MarcarCompromissoIntent(),
            phrases: ["Marcar no \(.applicationName)", "Marcar compromisso no \(.applicationName)"],
            shortTitle: "Marcar",
            systemImageName: "calendar.badge.plus"
        )
        AppShortcut(
            intent: CorpusComoContextoIntent(),
            phrases: ["Contexto do \(.applicationName)", "Minhas notas como contexto no \(.applicationName)"],
            shortTitle: "Como contexto",
            systemImageName: "doc.text"
        )
    }
}
