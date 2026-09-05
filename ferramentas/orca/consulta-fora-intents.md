# Consulta Fora do app — intents compartilhados entre app, widget e controles

Estado: PERGUNTA PRONTA, consulta ao Astra NÃO executada nesta volta (F1). O Astra é recurso do orquestrador (ESTEIRA, "Conselho de arquitetura"); o worker da trilha deixa aqui a pergunta com o contexto lido, para o orquestrador disparar e colar a recomendação abaixo.

## Pergunta do worker da trilha (Fable 5.1, F1, 05/09/2026)

Base: main `d4d98da`. Hoje há 12 `AppIntent` (10 em `Traco/App/Intencoes.swift`, 2 `LiveActivityIntent` em `TracoWidget/` compilados também no alvo do app por `project.yml`), 2 widgets estáticos + 2 Live Activities em `TracoWidget/TracoWidget.swift`, rotas `traco://` em `Rota.daURL`, Spotlight em `Holofote.swift` sem handler de toque, e dados fora do app por `UserDefaults(suiteName: "group.app.traco")` (`DestaqueDoDia`, `ProximoCompromisso`). O alvo do widget compila 4 arquivos do app por cópia de fonte (`Tema.swift`, `DestaqueDoDia`, `DestaqueAtividade`, `ProximoCompromisso`). Os intents que leem notas abrem o `ModelContainer` por conta própria (`notasDoDisco`, `Intencoes.swift:128`).

A trilha quer (F2, brief `papeis/fora-do-app.md`): um catálogo único de intents usado por widgets, controles da Central de Controle (`ControlWidget`), Siri, Atalhos, Spotlight (`AppEntity` + `IndexedEntity`), URL e extensão de compartilhar, sem duplicar lógica; entidades nota/compromisso/trabalho como `AppEntity`; snapshot barato no App Group; tokens visuais vindos de `Tema.swift`.

Decisão com mais de um caminho válido:
1. **Onde mora o catálogo.** (a) Um framework/target `TracoNucleo` (SwiftPM local ou framework embutido) com modelos SwiftData, `Tema`, os `AppIntent`s e as `AppEntity`s, ligado ao app, ao widget e à futura extensão de compartilhar; (b) manter cópia de fontes por `project.yml` (como hoje) e só disciplinar; (c) intents só no app + `ControlWidget`/widgets falando com o app por App Group e `WidgetCenter`. Qual escolher para Swift 6.2 com `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor` e SwiftData num processo de extensão (limite de memória do widget ~30 MB, container SwiftData aberto por dois processos)?
2. **Fonte de verdade fora do app.** Continuar com `UserDefaults` do App Group como snapshot (barato, mas cada fatia nova vira mais chaves soltas) ou um arquivo JSON versionado no container do grupo (`Fatia` codificada, escrita atômica, lida por widget, controle e intent)? Como isso conversa com `SwiftData` no grupo (mover o store para o App Group é migração com risco de perda)?
3. **`AppEntity` e selo.** Notas seladas/queimadas/expressivas nunca saem; `EntityQuery` de nota deve devolver só abertas, mas Spotlight já indexa por `Holofote`. Uma `IndexedEntity` substitui o `CSSearchableIndex` manual ou convive? Onde fica a única regra do selo para intents, Spotlight, widget e share?
4. **Controles e botão de Ação.** `ControlWidget` roda no processo do widget; um controle "Anotar" que abre o app em ditado precisa de `OpenIntent`/`openAppWhenRun`; um "Recordar" idem. Vale um único `AppIntent` parametrizado por destino (`AbrirTracoIntent(destino:)`) substituindo `Rota.daURL` + `Rota.pendente`, com a URL virando só um adaptador?

O que o implementador de F2 deve provar: build do TracoWidget sem aviso, testes de cada intent sem app aberto, widget e controle lendo o mesmo snapshot, selo coberto por teste nas quatro saídas.

## Recomendação do Astra

(pendente — colar aqui a resposta, com alternativas descartadas, riscos e o que provar)
