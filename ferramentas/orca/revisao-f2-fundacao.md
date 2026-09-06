# Revisão G3 — F2, fundação fora do app (ADR 2026-09-05u)

Revisor: Fable 5.1, sessão independente, 05/09/2026 21:05–21:40. Branch `Vitorepf/fora-2-fundacao` em `4abe09c` sobre main `e51550e`; main hoje em `7c8a2e4`. Simulador de teste: iPhone Air `64F7B8B4` (ligado, usado, aparência e tamanho de texto restaurados para `light`/`medium`, `TRACO_SEM_MODELO` desfeito, desligado ao fim). Nenhum arquivo do repositório editado; capturas `f2-rev-*.png` ficam untracked em `ferramentas/orca/`.

## Veredito: CORRIGIR ANTES

Seis dimensões abaixo de 9 (Design 7, Componentes 8, Acessibilidade 8, Estado honesto 7, Complexidade 8, Fora do app 7). A fundação está certa e provada — contratos, selo, identidade dos intents, snapshot atômico, suíte 660/0 nos dois alvos sem aviso — mas a jornada real no Air achou um defeito de produto que o implementador viu só de relance (o "ChronoCoreErrorDomain 27") e tratou como caso de instrumento: **um `reloadTimelines` recusado nunca é repetido**, e o widget que diz "abra o Traço" continua dizendo isso depois de o Traço ser aberto. A lista mínima está no fim; nada exige redesenho.

## Instrumento

| prova | resultado |
|---|---|
| `xcodebuild clean build` (Traco + TracoWidget), Air, via com-trava | `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** |
| `xcodebuild test`, Air, 1ª tentativa | "The test runner hung before establishing connection", 0 testes (instrumento; o mesmo que o implementador viu duas vezes) |
| `xcodebuild test`, Air, 2ª tentativa após shutdown/boot | `✔ Test run with 660 tests in 123 suites passed after 7.629 seconds.` / `** TEST SUCCEEDED **`; suíte "Fora do app — fundação" passou (18) |
| `project.pbxproj` × `xcodegen generate` em cópia temporária | diferença 0 linhas (o pbxproj commitado é o gerado) |
| maestro | **n/a**: nenhum fluxo cobre widget, Ilha ou bloqueada; a única rota tocada (`Rota.daURL`, `traco://anotar`) tem teste unitário em `CicloDaMenteTests:210`; e `varrer.sh` recusa com dois simuladores alheios ligados (17 e 17 Pro Max do dono), que não desligo |
| `git merge-tree --write-tree main HEAD` | **conflito em `SPEC.md` e `Traco/Caderno/EditorBlocoView.swift`**; `Tema.swift`, `PaginaView.swift`, `Revisoes.swift`, `EVOLUCAO.md`, `project.pbxproj` mesclam sozinhos |

## Achados por severidade

### Alto

**A1 — Reload recusado não é repetido; "abra o Traço" não se cumpre.** `SuperficieDisco.publicar` grava e pede `reloadTimelines` dos kinds mudados; se o WidgetKit recusa, o app não sabe (a API não devolve erro, só loga) e a próxima publicação idêntica **não regrava nem pede reload de novo** (`publicar` retorna `true` cedo quando destaque/proximos/validoAte não mudaram). Visto três vezes no Air, no log do processo `Traço`:

```
21:30:21.975 reloadTimelines(ofKind:) - error reloading timelines of kind 'TracoProximo': ChronoCoreErrorDomain Code=27
21:33:37.219 reloadTimelines(ofKind:) - error reloading timelines of kind 'TracoWidget':  ChronoCoreErrorDomain Code=27
21:37:56.327 reloadTimelines(ofKind:) - error reloading timelines of kind 'TracoProximo': ChronoCoreErrorDomain Code=27
```

Consequências vistas na tela: (a) às 21:30 o widget do Próximo mostrava "vigiar o sinal: ninguém abre o e-mail — sábado, 19 de set." (dado de teste, ver A2) enquanto `superficie.json` já dizia Dentista, revisão 36; (b) às 21:33 o Destaque recém-vestido estava na revisão 37 e o widget da casa seguia sem Destaque; (c) `f2-rev-casa-restaurada.png`: o app acabou de ser aberto (a Ilha mostra o Dentista em 6:56), a superfície está na revisão 41 com `validoAte` 19/09, e o widget continua "desatualizado · abra o Traço · atualizado há 2 h e 2 min". O rodapé é honesto sobre a idade, mas a instrução não funciona. A Apple diz que reloads com o app em primeiro plano não contam no orçamento diário ("Cases in which WidgetKit doesn't count reloads against your widget's budget include when: The widget's containing app is in the foreground"), e mesmo assim as três recusas aconteceram com o app em primeiro plano — é limite de rajada, não de dia; por isso o pedido precisa ser repetido, não evitado. Correção mínima: no `didBecomeActive` pedir reload dos dois kinds sempre (uma vez por retorno, independentemente de a escrita ter mudado algo), e/ou repetir o pedido com atraso curto quando uma publicação ocorreu nos últimos segundos. Teste: publicação idêntica após retorno à cena pede reload (hoje `snapshotVersionado` prova o contrário de propósito — o teste precisa distinguir "autosave idêntico" de "retorno à cena").

### Médio

**A2 — A suíte escreve na superfície REAL do simulador e queima o orçamento.** F2 criou `SuperficieDisco.url`/`recarregar` trocáveis, mas só `ForaDoAppTests` os usa. `ColheitaEixosTests`, `AvisoDoCompromissoTests` e `CicloDaMenteTests` (18 chamadas a `DestaqueDoDia.gravar/apagar`, `ProximoCompromisso.publicar/gravar`, `agenda.publicarProximo`) rodam no host de teste = o app do Air, com o `group.app.traco` de verdade: a revisão do documento pulou de 4 para 36 durante a suíte, o `WidgetCenter` real recebeu dezenas de reloads, `Activity.request` real criou atividades órfãs (`chronod`: "DestaqueAtividade:FA465F0C… reload: failed during preparation, Activity had no descriptor") e o widget da casa exibiu um compromisso de teste. É pré-existente em espírito (antes eram chaves soltas), mas F2 tornou o custo visível e deu a ferramenta: um `@Suite` trait ou um ponto único no arranque dos testes redirecionando `SuperficieDisco.url` para pasta temporária, `recarregar` para no-op e as chaves de `DestaqueDoDia`/soneca para uma suíte de UserDefaults de teste. Sem isso, toda captura depois de `xcodebuild test` no mesmo aparelho é suspeita.

**A3 — O Destaque não cabe no widget pequeno.** `f2-rev-casa-destaque.png`: "Correr antes do cafe" (20 caracteres) vira "Correr antes…" no `systemSmall`; `lineLimit(2)` não vale porque `Spacer(minLength: 12)` + duas réguas + dois atalhos não deixam altura. O widget cujo propósito é mostrar a única coisa de hoje não a mostra. Mesmo defeito no estado indisponível: "sem dados · abra…" (`f2-rev-casa-sem-dados.png`). Opções de uma linha: no pequeno, esconder o atalho "Recordar" quando há Destaque, ou trocar `Spacer(minLength: 12)` por `minLength: 4` e `Tema.meta` por `Tema.miudo` na linha.

**A4 — VoiceOver do botão vivo não diz o que marca.** No cartão da bloqueada e na Ilha expandida, `DestaqueFeitoIntent` tem `accessibilityLabel("Marcar como feito")`; o `BotaoFeito` da casa diz a linha. Quem não vê ouve "Marcar como feito" sem saber o quê. Correção: `"Marcar como feito: \(contexto.state.linha)"` nos dois lugares.

**A5 — O widget do Destaque não tem idade nem estado velho.** Só o Próximo tem "atualizado há…"; o `TracoWidget` mostra a linha (ou nada) sem dizer quando foi gerada. Com A1, um Destaque de ontem publicado à meia-noite e reload recusado fica sem marca de velho (a entrada `.atEnd` da meia-noite cobre a virada do dia só se o timeline foi carregado depois do Destaque existir). Correção mínima: o mesmo rodapé, ou ao menos `destaqueDeHoje` já cobre o dia — documentar o custo na ADR se ficar.

### Baixo

- **B1 — Rodapé em segundos.** "atualizado há 1 min e 58 seg" muda a cada segundo; honesto, mas ruído numa superfície que o conselho quis calma. Alternativa sem entrada por minuto: "atualizado às 21:30" (absoluto, `Text(gerado, style: .time)`), uma linha.
- **B2 — Recado esconde a nova tentativa.** Depois de "avisos desligados no iPhone" a cápsula some até a próxima republicação (retorno à cena); quem liga os avisos no Ajustes e volta à bloqueada não tem onde tocar. Aceitável em F2 (ADR assume que o recado é volátil, F5), registrar.
- **B3 — Candidatas fora do horizonte.** `proximasFatias` colhe até `agora + 14 d` e `validoAte` é `startOfDay(agora + 14 d)`: um compromisso no 14º dia entra na lista mas cai depois do horizonte; a linha do tempo o ignora (`p.fim <= s.validoAte`) e o widget diz "desatualizado" enquanto ainda existe candidato. Alinhar os dois (`ate = validoAte`).
- **B4 — `Fatia` duplica `Superficie.Proximo`** (mesmos oito campos, dois `init` de conversão e `projecao`); `ProximoCompromisso.horaCurta/diaEmPalavras` e `DestaqueDoDia.diaISO` são só repasses. `DestaqueAtividade.id = UUID()` como padrão é armadilha (uma atividade sem dona nunca casa em `reconciliar`); melhor sem padrão.
- **B5 — Zero `#Preview` no widget** (antes também zero). Os quatro componentes privados (`BotaoFeito`, `CapsulaLembrar`, `LinhaDaAcao`, `AtalhoTraco`) não têm como viver em `Traco/Componentes` (o alvo do widget só compila `Tema.swift` e `Compartilhado/`) — custo justo até a V10 — mas a ESTEIRA pede preview e o G4 precisa dele para comparar famílias sem aparelho.
- **B6 — D11 segue**: papel claro no escuro (`f2-rev-casa-escuro.png`), G0 de F4/F5 como declarado.
- **B7 — `AbrirNota/Trabalho/CompromissoIntent` devolvem `dialog: ""`** quando abrem; Siri fala vazio. Cosmético.

### Conferido e certo (contratos do item 1 do pedido)

- App único escritor: só `SuperficieDisco.publicar` grava; chamado por `DestaqueDoDia` (Sessao: `aplicarDestaque` em cada `salvar`, `apagar` no trancar/apagar/página vazia), `ProximoCompromisso` (agenda em cada mudança e no retorno à cena, `MarcarCompromissoIntent`, `lembrarDepois`). A extensão só lê (`ler()`), e `perform()` fora de `TRACO_APP` lança `ForaDoAlvo`. Todos os chamadores estão no MainActor (leitura-modificação-escrita sem tranca é segura hoje; anotar se algum dia sair da main).
- Atômico (`.atomic`), versionado (`versao`, `revisao`), idêntico não regrava (`snapshotVersionado`, `apagadoNaoVolta`), reload só dos kinds mudados (`reloadPorKind`), truncado/versão errada/App Group nulo → `.indisponivel` e a tela diz "sem dados · abra o Traço" (visto). Horizonte no início do dia, `>=` no instante exato (`snapshotExpirado`).
- `DestaqueFeitoIntent(nota:dia:)`: `eDeHoje` revalida dona+dia+linha; feito é `true` e repetir não inverte; `DestaqueDesfazerIntent` explícito; superfície recusada desfaz (`persistenciaRecusada`); `encerrarAtividades` aguardado antes de devolver. Visto no Air: casa feito → revisão 38, desfeito → 39, bloqueada feito → 40 e o cartão vivo saiu.
- `LembrarDepoisIntent(ocorrencia:)`: `revalidar` no disco (ou `doSistema` na projeção), `Revisoes.soneca` pelo centro (permissão, `livres`, `add` que lança), revalida de novo após o `await` (`corridaComEditor`), `registrarSoneca` + `republicar` antes de `contar`; recusa vira recado sem hora. Visto no Air: "avisos desligados no iPhone", `lembrarEm` ausente na revisão 40.
- Reconciliação no arranque (`TracoApp`), retorno (`RaizView`) e após comando; `isStale` neutraliza cartão, Ilha compacta e expandida (lido no widget). Entidades aplicam o selo na query (`publica`: `!fechada && gesto != .expressiva && temVoz`; `fechada = trancada || queimada`) e `destino(_:)` revalida no `perform` (`seloNasEntidades`, `protecaoDepoisDaQuery`). `AnotarIntent` distingue `.vazio/.falhou/.anotado` (`anotarHonesto`). Botões em `accessoryRectangular` são suportados no iPhone (doc da Apple, "Adding interactivity…").
- Lista do conselho × 18 testes: persistência recusada ✔, repetição ✔, item velho ✔, soneca negada/lotada/falha ✔, snapshot truncado/expirado ✔, corrida commit×editor ✔ (calendário), proteção depois da consulta ✔, durante await ✔ (só calendário; nota não tem await no `perform`), recibo sem duplicação: fora de F2, coberto por `IntegridadeEntradaTests` pré-existente. Falta: o caso de A1 (reload recusado/retorno à cena).

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | linha da volta em `f2-fundacao.md` (MULTIPLICAR; mesmo comando, mesmo estado em qualquer entrada); nova linha "Fora do app" no EVOLUCAO fecha a lacuna nomeada pela auditoria F1 |
| Contrato | 9 | ADR 05u em SPEC, EVOLUCAO e código coerentes (lido item a item acima); pbxproj = xcodegen; ressalva: a ADR diz "o app recarrega os kinds afetados" e A1 mostra que é pedido sem repetição — registrar a política ao corrigir A1; rebase obrigatório (SPEC e EditorBlocoView) |
| Correção | 9 | build 2 alvos 0 avisos; `660 tests in 123 suites passed` no Air (2ª tentativa; 1ª pendurou sem executar); 18 testes cobrem a lista do conselho; maestro n/a com motivo; higiene A2 recomendada |
| Jornada real | 9 | reproduzido no Air por conteúdo: casa claro/escuro/AX5, Destaque com botão (feito, desfeito), Ilha compacta (compromisso e Destaque) e expandida, bloqueada com dois cartões, feito na bloqueada, "Lembrar em 10 min" recusado honesto, "sem dados", "desatualizado", e o estado após reabrir o app (A1); capturas `fora2-*` do implementador abertas e conferidas; Ilha mínima/StandBy/accessory n/a (simulador não expõe) |
| Design | 7 | A3 (linha do Destaque cortada no pequeno), B1 (segundos no rodapé), A5 (Destaque sem idade), B6 (D11); tokens de Tema em tudo (`grep '.system(size' TracoWidget` = 0); G4 pendente |
| Simplicidade | 9 | um toque faz uma coisa e confirma no lugar; feito e desfazer no mesmo ponto; nenhum passo novo no app; B2 é custo assumido |
| Movimento | n/a | nenhuma animação adicionada; transições da Ilha e do cartão são do sistema |
| Componentes | 8 | quatro componentes privados no arquivo do widget sem `#Preview` (B5); `Fatia` ≡ `Superficie.Proximo` (B4); lugar único é impossível pelo alvo, custo justo até V10 |
| Acessibilidade | 8 | AX5 sem clipe (`f2-rev-casa-ax5.png`); rótulos nos botões; A4 (botão vivo sem a linha); cápsula 38 pt declarada; A3 corta conteúdo também em AX |
| Performance | n/a | nenhuma lista, editor ou parser tocado; timeline com ≤ 6 entradas; `notasDoDisco()` faz fetch completo por consulta de entidade (só Atalhos) |
| Privacidade e autoria | 9 | selo na query e no perform (testes); snapshot só leva linha de nota não fechada e títulos do calendário do autor/sistema; trancar/apagar apaga do App Group; nada agenda sem permissão do centro |
| Estado honesto | 7 | A1: "abra o Traço" não se cumpre após reload recusado (`f2-rev-casa-restaurada.png` + log Code=27 ×3); A5; o resto é exemplar: recusa da soneca dita, sem dados dito, desatualizado dito |
| Complexidade | 8 | +2027/−602: testes +435, pbxproj/yml +67/−34, docs/capturas +101, compartilhado +372, intents +301, app +476/−278, widget +275/−290 (Intencoes é rename, 41/75 reais); fundação justificada; excesso pequeno e concreto em B4 |
| Fora do app | 7 | superfície entregue e provada em todos os estados que o simulador permite; um toque uma coisa ✔; nada protegido ✔; orçamento: A1 (sem recuperação da recusa) e A2 (suíte queima o orçamento do aparelho de teste); A3 |
| Relato | 9 | `f2-fundacao.md` com linhas de resultado, capturas nomeadas, D1 explicado literalmente, defeitos achados na jornada e corrigidos; SPEC diz "capturas no iPhone 17e" mas as da casa são do Air (ajustar uma palavra) |

## Lista mínima para chegar a 9 (por dimensão)

1. **Estado honesto / Fora do app (A1):** pedir reload dos dois kinds no `didBecomeActive` sem depender de a escrita ter mudado (é grátis em primeiro plano segundo a Apple) e/ou repetir o pedido com atraso curto após uma publicação; teste que prova o pedido no retorno à cena com documento idêntico. Registrar a política na ADR 05u.
2. **Fora do app / Correção (A2):** um ponto único nos testes que redireciona `SuperficieDisco.url`, `recarregar` e as chaves do App Group para isolamento em toda a suíte, não só em `ForaDoAppTests`.
3. **Design (A3, B1):** o pequeno mostra a linha inteira (esconder "Recordar" quando há Destaque, ou apertar espaçamento e degrau); rodapé absoluto "atualizado às HH:MM" em vez de segundos correndo. A5 pode ficar registrado na ADR como custo se o G4 aceitar.
4. **Acessibilidade (A4):** rótulo do botão vivo com a linha, nos dois lugares.
5. **Componentes (B5):** `#Preview(as: .systemSmall/.systemMedium/.accessoryRectangular)` para os dois widgets com uma `EntradaTraco`/`EntradaProximo` de amostra por estado.
6. **Complexidade (B4):** `Fatia` vira `Superficie.Proximo` (typealias + extensão para `comLembrete`), sem `id = UUID()` padrão em `DestaqueAtividade`; apagar os repasses `horaCurta/diaEmPalavras/diaISO` ou deixá-los explícitos como compat. B3 junto se couber.

## Merge (rebase sobre main 7c8a2e4)

- `SPEC.md`: as duas ADRs (05t de main, 05u desta volta) foram anexadas no mesmo ponto; manter as duas, 05t antes de 05u.
- `Traco/Caderno/EditorBlocoView.swift`: main (V8) manteve a assinatura antiga e acrescentou ao comentário "(05/09: só `@MainActor`, sem `@Sendable`, também derruba o compilador)"; esta volta usa `@escaping @MainActor (String) -> Void` com `MainActor.assumeIsolated` no `set` e **compila limpa aqui** (build dos dois alvos, 0 avisos, suíte 660/0). Ficar com a versão desta volta e apagar a frase de main que ela desmente.
- `Tema.swift`, `PaginaView.swift`, `Revisoes.swift`, `EVOLUCAO.md`, `project.pbxproj`: mesclam sozinhos; regenerar o pbxproj com `xcodegen` depois do rebase e repetir build + suíte.

## Capturas desta revisão (Air, simctl, untracked em `ferramentas/orca/`)

`f2-rev-casa-claro.png` (Dentista hoje às 21:45, sino, Ilha compacta 12:56) · `f2-rev-casa-escuro.png` (D11) · `f2-rev-casa-ax5.png` · `f2-rev-ilha-expandida.png` (Dentista, cápsula, 12:43) · `f2-rev-app-destaque.png` (cartão "Abrir a forma Destaque" pelo motor local) · `f2-rev-casa-destaque.png` (círculo + "Correr antes…", A3) · `f2-rev-casa-destaque-feito.png` (revisão 38) · `f2-rev-casa-destaque-desfeito.png` (revisão 39, Ilha compacta do Destaque) · `f2-rev-bloqueada.png` (cartão do Destaque na pilha) · `f2-rev-bloqueada-feito.png` (Destaque encerrado, sobra o Próximo com cápsula) · `f2-rev-bloqueada-lembrar.png` ("avisos desligados no iPhone") · `f2-rev-casa-sem-dados.png` · `f2-rev-casa-desatualizado.png` · `f2-rev-casa-restaurada.png` (A1).

Capturas do implementador (`fora2-*.png`, 11) abertas uma a uma: conteúdo confere com o relato (bloqueada com cápsula e com recado no 17e; casa vazio/claro/escuro/AX5, sem dados, desatualizado, Ilha compacta 55:14 e expandida no Air; alerta do D1 nos Atalhos).
