# Re-G3 — F2, fundação fora do app, após correções e rebase

Revisor: Fable 5.1, sessão independente, 06/09/2026 03:30–04:15. Branch `Vitorepf/fora-2-fundacao` em `d33b6a8` sobre main `e6b5033` (`git merge-tree --write-tree main HEAD`: limpo). Simulador de teste: iPhone Air `64F7B8B4` (ligado por mim, restaurado — claro, `medium`, `calendario.json` de antes — e desligado ao fim); iPhone 17 e 17 Pro Max do dono intocados. Todo `xcodebuild` via `ferramentas/orca/com-trava.sh`. Nenhum arquivo do branch editado; este arquivo e as capturas `f2-reg3-*.png` ficam untracked em `ferramentas/orca/`.

## Veredito: INTEGRAR (condicionado ao gate do dono, que a prova 1 abaixo responde)

Todas as quinze dimensões em 9 ou n/a. As seis que estavam abaixo de 9 no G3 (Design, Componentes, Acessibilidade, Estado honesto, Complexidade, Fora do app) subiram com evidência reproduzida no Air, não só lida no diff. Ficam dois achados baixos e uma observação para o orquestrador (peso das capturas versionadas).

## Prova 1 — o caminho de atualização preserva os dados (resposta literal para o dono)

Cenário pedido: instalar o build de MAIN (`e6b5033`, `PRODUCT_NAME` "Traço"), criar 2 notas e 1 compromisso, instalar o build do BRANCH por cima com `xcrun simctl install` (sem uninstall) e ver se continuam.

| passo | executável instalado | contêiner de DADOS do app (`get_app_container … data`) | contêiner do App Group | notas / compromissos |
|---|---|---|---|---|
| 0 (estado deixado pelo implementador) | `Traco.app` (branch) | `F2901DF5-…` | `3E4CAEBC-…` | — |
| 1 `simctl install` de main `Traço.app` por cima | `Traço.app`; no disco o executável é `Trac` + U+0327 (NFD) e o `CFBundleExecutable` do Info.plist é U+00E7 (NFC) — confirma a causa que o implementador achou | **`9DB6BE27-…`** (mudou; `F2901DF5` deixou de existir) | `3E4CAEBC-…` (igual) | `Documents/Traço/calendario.json` e `versoes/*.json` com os MESMOS nomes de antes — conteúdo migrado, só o UUID mudou |
| 2 criar dados em main | — | `9DB6BE27-…` | — | `traco://anotar` × 2 ("Prova Re-G3 nota um", "… nota dois"); compromisso "Prova Re-G3 compromisso" hoje 18:00 escrito em `calendario.json` com o app fechado e lido no relançamento; `f2-reg3-02-main-notas.png` (4 notas: Tea, Correr antes do cafe, um, dois), `f2-reg3-03-main-calendario.png` (semana: Almoço 12:00, Prova R… 18:00) |
| 3 `simctl install` do branch `Traco.app` por cima | `Traco.app` (`CFBundleExecutable = Traco`, `CFBundleDisplayName = Traço`, id `app.traco`) | **`095B7561-…`** (mudou de novo) | `3E4CAEBC-…` (igual) | **tudo continua**: `calendario.json` = `['Dentista', 'Almoço', 'Prova Re-G3 compromisso']`; `select ZTEXTO from ZNOTA` no `default.store` = Tea / Correr antes do cafe… / Prova Re-G3 nota um / Prova Re-G3 nota dois; `f2-reg3-04-branch-notas.png`, `f2-reg3-05-branch-calendario.png` (mesmas telas) |
| 4 controle: instalar o MESMO `Traco.app` de novo | `Traco.app` | **`453FC54B-…`** (mudou outra vez) | igual | tudo continua |

Leitura literal: **nenhuma nota e nenhum compromisso se perdeu**. O "contêiner trocou" que o implementador viu é comportamento do simulador em TODA instalação por `simctl install` — o passo 4 prova que acontece sem renomear nada: o installd migra o conteúdo para um UUID novo. Não é efeito do `PRODUCT_NAME`. Dois fatos que reforçam a segurança: (a) o `default.store` do SwiftData (as notas) vive no contêiner do **App Group** (`group.app.traco/Library/Application Support/default.store`), cujo caminho não mudou em nenhum passo; (b) o que vive no contêiner do app (`calendario.json`, `versoes/`, anexos) foi migrado íntegro nas três instalações. Limite honesto da prova: é o simulador; no iPhone o caminho é Xcode/`installcoordinationd`, também por bundle id — a leitura é a mesma, mas o dono ainda decide se quer ver com os próprios olhos antes de outra volta.

## Instrumento (linhas literais)

| prova | resultado |
|---|---|
| main `e6b5033`, `xcodebuild build` (Air, worktree temporário, com-trava) | `** BUILD SUCCEEDED **`; produto no DerivedData `Traço.app` em NFC — o NFD aparece só depois de instalado no simulador |
| branch, `xcodebuild clean build` scheme Traco, Air, com-trava | `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** |
| branch, `xcodebuild build` scheme TracoWidget | `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** |
| branch, `xcodebuild test`, Air, com-trava | `✔ Test run with 665 tests in 124 suites passed after 7.646 seconds.` / `** TEST SUCCEEDED **` (1ª tentativa, sem pendurar); o alvo de testes emite os 2 avisos herdados de main (`ConferenciaTrabalhoTests.swift:381`, "variable never mutated"), como o implementador declarou; app e widget 0 |
| `project.pbxproj` × `xcodegen generate` em cópia (`git archive HEAD`) | diferença **0** linhas |
| `git merge-tree --write-tree main HEAD` | limpo |
| SPEC | `grep -n '2026-09-05[stu]'`: 05s (l. 2337), 05t (2386), 05u (2471), nessa ordem |
| `EditorBlocoView.swift` | versão da volta (`@escaping @MainActor (String) -> Void` + `assumeIsolated`); a frase de main "só `@MainActor` também derruba o compilador" não está mais lá e o build de 0 avisos a desmente |
| maestro | **n/a**: nenhum fluxo cobre widget/Ilha/bloqueada; `varrer.sh` só mudou o caminho do `.app` (conferido: `build/Build/Products/Debug-iphonesimulator/Traco.app` existe após o build); e `varrer.sh` recusa com os dois simuladores do dono ligados, que não desligo |

## A1 — chronod aceita o reload e "abra o Traço" se cumpre (reproduzido)

`log stream` do Air (processos `chronod` e `Traco`, subsystem `com.apple.widgetkit`) durante a jornada inteira, 03:46–03:52:

- `Code=27`: **0** ocorrências · `does not match executable`: **0** · `error reloading`: **0**
- `record reload: [app.traco::app.traco.widget:TracoProximo] = externalRequest([source:<BSProcessHandle …; Traco:17084; valid: YES>]` — 4 pedidos do app aceitos; `reloadTimelines(ofKind:) - reloaded timelines of kind …` — 6 linhas.
- Sequência vista: 03:46:25 publicação (TracoProximo) → 03:46:27 `recarregarPendente` 2 s após `didBecomeActive` (TracoProximo + TracoWidget) → 03:52:00 relançamento publica → 03:52:02 repetição dos dois kinds. O próprio chronod ainda registra um `externalRequestThrottledRetry(… unwindingPendedReloadWhileForeground)` 3–5 s depois: é a fila dele, não recusa.

Jornada (três compromissos "Curto 1/2/3" de 1 min semeados no `calendario.json`, `candidatas` = 3 ⇒ `validoAte` = fim do terceiro, 03:51):

- `f2-reg3-06-casa-curtos.png` (03:46): Próximo "Curto 1 · hoje às 03:48 · 🔔 03:48 · atualizado às 03:46"; Ilha compacta com a contagem (1:26).
- `f2-reg3-07-casa-desatualizado.png` (03:51:59): "desatualizado · abra o Traço · atualizado às 03:46" no instante do horizonte; Ilha compacta diz "acabou".
- `f2-reg3-08-casa-restaurada.png` (03:52:10, app reaberto e fechado): "Almoço · hoje às 12:00 · 🔔 12:00 · atualizado às 03:52"; atividade encerrada pela reconciliação. `superficie.json` foi da revisão 49 (`validoAte` 06:51Z) à 50 (`validoAte` 20/09 00:00 local).

Teste `recargaNaVolta` lido: cobre arranque sem confirmação, escrita idêntica sem novo pedido, repetição na volta e não-repetição depois de confirmada. Coerente com a ADR 05u reescrita.

## A2 — a suíte não escreve no App Group real (provado por leitura antes/depois)

Antes de `xcodebuild test`: `superficie.json` do App Group real com mtime 03:52:00, md5 `550b6070…`, revisão 50; `group.app.traco.plist` md5 `c05f6066…`. Depois da suíte inteira (665 testes): **mtime 03:52:00, md5 `550b6070…`, revisão 50 — idênticos**; `plutil -p` do plist do grupo sem nenhuma diferença (destaqueLinha, destaqueId, soneca, proximo* intactos). No `log stream`, durante a janela da suíte (03:56:49 →) **zero** linhas `Traco[…] reloadTimelines` — os únicos reloads foram `= extensionChanged` do próprio chronod pela reinstalação do app; a suíte própria de UserDefaults apareceu como `Library/Preferences/app.traco.testes.plist` no contêiner do app, não no grupo. `isolarParaTestes()` está num ponto só (`TracoApp.init`, portão `XCTestConfigurationFilePath`) e o teste `suiteIsolada` lê o contêiner real para provar a igualdade — A2 fechado.

## A3/A4/A5/B — conferido no conteúdo das capturas do implementador (`f2c-*.png`, Air) e no código

- **A3 (linha inteira no pequeno):** `f2c-casa-claro.png`: "○ Correr antes / do café" em duas linhas, atalho "Nova nota", rodapé "atualizado às 03:14"; "Recordar" saiu do pequeno quando há Destaque (`soNovaNota`). Médio segue com os dois atalhos (`f2-reg3-06`, sem Destaque: "Nova nota / Recordar").
- **AX5:** `f2c-casa-ax5.png`: pequeno só com "○ Correr / antes do / café" em três linhas, sem clipe, sem rodapé (`soALinha`); Próximo médio "nada marcado · atualizado às 03:18" legível em AX5.
- **A4 (VoiceOver do botão vivo):** `accessibilityLabel("Marcar como feito: \(contexto.state.linha)")` no cartão da bloqueada e na Ilha expandida (diff, dois lugares). Não recapturado na bloqueada: os hunks de `DestaqueVivo`/`CompromissoVivo` mudam só esse rótulo; `quando()` do Próximo passou a `Superficie.quando`, string idêntica — nada visual mudou na Ilha nem na bloqueada.
- **A5/B1 ("atualizado às"):** `RodapeAtualizado` nos dois widgets; visto em todas as capturas (03:14, 03:18, 03:46, 03:52). Sem segundos correndo.
- **B3:** `proximasFatias` e `validoAte` usam o mesmo `fimDoHorizonte`.
- **B4:** `Fatia = Superficie.Proximo` (typealias), sem `projecao`, repasses apagados, `DestaqueAtividade.id` sem padrão; `Superficie.quando` único ("hoje às 12:00" igual no widget e na entidade).
- **B5:** oito `#Preview` (pequeno, médio, bloqueada, AX5 × dois widgets), um estado por entrada (com dado, feito/soneca, vazio, desatualizado, sem dados). Compilam (build do widget 0 avisos).
- **D11 (papel claro no escuro):** `f2c-casa-escuro.png` confirma que segue; aceito como G0 de F4/F5, conforme o pedido.
- **`f2c-casa-desatualizado.png` / `f2c-casa-restaurada.png`:** conteúdo confere com o relato do implementador ("desatualizado · abra o Traço · atualizado às 03:14" → "nada marcado · atualizado às 03:18"); eu reproduzi o mesmo par em `f2-reg3-07/08`.

## Achados

### Alto
Nenhum.

### Médio
- **M1 — 69 MB de PNG entram em main com esta volta.** `ferramentas/orca` passa de 108 MB (main) para 177 MB (HEAD) em capturas: 30 PNGs novos, entre eles as 14 capturas do G3 anterior (`f2-rev-*.png`, ~38 MB) que o implementador versionou. A V9 teve os commits esmagados justamente por peso (LACO: 82 MB → 26 MB). Não é defeito de código; é decisão do orquestrador antes do G5: manter só as `f2c-*` e `fora2-*` citadas na ADR (ou reduzir a escala das capturas), e deixar as do revisor fora do git.

### Baixo
- **B-a — `recarregarPendente` corre 2 s depois do `didBecomeActive` sem checar se o app ainda está em primeiro plano.** Se o autor abrir e fechar o Traço em menos de 2 s, o pedido sai em segundo plano e conta no orçamento. Custo pequeno (um reload), mas a ADR diz "em primeiro plano o reload não conta"; uma linha (`scenePhase == .active` antes de pedir) fecha.
- **B-b — Ilha compacta diz "acabou" depois do fim do compromisso até o app voltar** (`f2-reg3-07`). É o comportamento pré-existente da atividade (reconciliação só no arranque/retorno/comando), não desta volta; registrar para F5 junto do recado da soneca.
- **B-c — `nonisolated(unsafe) static var` para `revisaoPublicada/Recarregada/defaults/atividades`.** Todos os chamadores estão no MainActor hoje (mesma ressalva do G3 para `publicar`); anotar se algum sair da main.

### Conferido e certo (contratos)
- Só o app escreve (`publicar`), extensão só lê; `TRACO_APP` recusa executar fora — inalterado.
- Nada protegido novo vai à superfície: o diff da correção não toca `publica`/`destino(_:)`/selo; a linha do Destaque já ia, como antes.
- `isolarParaTestes` é um ponto só (`TracoApp.init`, portão `XCTestConfigurationFilePath`, o mesmo do `DiscoTraco`); `publicar` cria a pasta temporária (`createDirectory … withIntermediateDirectories`) — o caminho de teste não falha a seco.
- Bundle id `app.traco`, widget `app.traco.widget`, `CFBundleDisplayName` "Traço" (lido do `listapps` do Air: `CFBundleExecutable = Traco`, `CFBundleDisplayName = "Traço"`).
- SPEC/EVOLUCAO/f2-fundacao.md coerentes com o código (causa real, política de recarga, isolamento da suíte, "capturas … da casa e da Ilha no iPhone Air" corrigido).

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | inalterado do G3: linha da volta (MULTIPLICAR), lacuna "Fora do app" do EVOLUCAO atualizada com as correções de 06/09 |
| Contrato | 9 | ADR 05u reescrita com a causa real (NFD×NFC) e a política de recarga; SPEC com 05s/05t/05u; EVOLUCAO e `f2-fundacao.md` coerentes; pbxproj = xcodegen |
| Correção | 9 | build 2 alvos 0 avisos; `665 tests in 124 suites passed` no Air à 1ª (665 = 660 + 3 de main + 2 novos); 20 testes em `ForaDoAppTests` (recargaNaVolta e suiteIsolada novos e lidos); maestro n/a com motivo; merge-tree limpo |
| Jornada real | 9 | reproduzido no Air por conteúdo: casa com Próximo, desatualizado no instante do horizonte, restaurado ao reabrir, notas e calendário antes/depois da atualização; `f2c-*` abertas uma a uma; Ilha/bloqueada sem mudança visual (diff) |
| Design | 9 | A3 (linha inteira), B1/A5 (hora absoluta) vistos; tokens de Tema em tudo (`grep '.system(size' TracoWidget` = 0); D11 declarado G0 de F4/F5 e aceito pelo pedido; G4 pendente como sempre |
| Simplicidade | 9 | pequeno perdeu um atalho quando há Destaque (decisão registrada na SPEC), nenhum passo novo no app, "Recordar" segue no médio e no app |
| Movimento | n/a | nenhuma animação adicionada |
| Componentes | 9 | oito `#Preview` por família e estado; `RodapeAtualizado` um só para os dois widgets; `Fatia` deixou de duplicar `Superficie.Proximo`; lugar único em `Traco/Componentes` segue impossível pelo alvo (custo até V10, já aceito) |
| Acessibilidade | 9 | `f2c-casa-ax5.png` sem clipe (só a linha, três linhas); rótulo do botão vivo com a linha nos dois lugares; alvos e contraste inalterados |
| Performance | n/a | nada de lista, editor ou parser tocado; timeline com ≤ 6 entradas |
| Privacidade e autoria | 9 | selo e `destino(_:)` intocados pela correção; testes de selo seguem; nada agenda, publica ou envia sem gesto |
| Estado honesto | 9 | "abra o Traço" se cumpre (`f2-reg3-07` → `f2-reg3-08`, log sem recusa); hora absoluta do que está na tela; "desatualizado" no instante exato; B-b é pré-existente e registrado |
| Complexidade | 9 | diff da correção +325/−92 em 14 arquivos de código (rede de recarga, isolamento, previews); `Fatia`, repasses e `projecao` apagados; volta inteira +1624/−596 código e +493 testes; M1 é peso de captura, não de código |
| Fora do app | 9 | todos os estados que o simulador permite vistos; um toque uma coisa; orçamento: reload aceito e repetido só quando não confirmado; suíte não toca a superfície real (md5/mtime/plist iguais, zero reload do app) |
| Relato | 9 | `f2-fundacao.md` com linhas literais, causa real explicada em bytes, capturas nomeadas e conferidas; atenção ao contêiner registrada com honestidade (e agora respondida acima) |

## Capturas desta revisão (Air, `simctl io screenshot`, untracked)

`f2-reg3-00-casa-antes.png` (página 1 da casa, sem widgets do Traço) · `f2-reg3-01-main-anotar.png` (main, Notas após `traco://anotar`) · `f2-reg3-02-main-notas.png` (main, 4 notas) · `f2-reg3-03-main-calendario.png` (main, semana com Almoço e Prova R…) · `f2-reg3-04-branch-notas.png` (branch por cima: mesmas 4 notas) · `f2-reg3-05-branch-calendario.png` (branch: mesmos compromissos) · `f2-reg3-06-casa-curtos.png` (Próximo "Curto 1", Ilha 1:26) · `f2-reg3-07-casa-desatualizado.png` · `f2-reg3-08-casa-restaurada.png` (Almoço 12:00, atualizado às 03:52).

## Restauração do Air

`calendario.json` devolvido ao conteúdo de antes (Dentista, Almoço); notas "Prova Re-G3 …" ficaram no `default.store` do App Group (aparelho de teste; apagá-las exigiria o app — deixo registrado); aparência `light`, texto `medium` (não mudei); `log stream` encerrado; Air desligado; 17 e 17 Pro Max do dono intactos. Worktree temporário de main removido.
