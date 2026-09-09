# G3 — revisão independente da S1: a pergunta interrompida

**Veredito: CORRIGIR ANTES — não aprovo nem há autorização de merge.** O candidato `47231c9` põe corretamente a instância de `ConversaNotas` na `Sessao`, mas a prova de jornada que o acompanha falha no próprio candidato: os dois testes novos terminaram com **3 falhas**. A nota abaixo de 9 em Correção, Jornada real, Design, Simplicidade, Acessibilidade e Estado honesto bloqueia a volta pela ESTEIRA G3.

**Revisor:** independente · **candidato:** `47231c9` · **ADR:** 2026-09-09c · **simulador exclusivo:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`. Todos os `xcodebuild` e usos de `orca emulator` passaram por `ferramentas/orca/com-trava.sh`; não usei Siri, ditado, síntese, VoiceOver ou iPad, e não instalei nem toquei no `C2416CBC`.

## Achado

### [P1] `Traco/Notas/NotasView.swift:334` — a prova nova não consegue trocar de aba no candidato

No caminho que passa pelo binding modificado de `$conversaNotas.entrada` para `Bindable(conversaNotas).entrada`, o campo continua em foco depois de perguntar no cenário reproduzido. A captura do candidato mostra o cartão, a pergunta e o caret no campo, mas **sem a barra de abas**: `ferramentas/orca/g3-s1-depois-02-pre-calendario.png`.

No AX desse mesmo estado (`/tmp/g3-s1-depois-ax-teclado-solto.json`), `aba-calendario` e as demais abas têm `y: 1.0572`, isto é, estão fora da tela. O gesto exigido pelo próprio teste devolveu `ok: true`, mas não moveu a tela nem restaurou a barra; a captura `simctl` é a prova de que o estado não mudou. Portanto não usei a ausência/presença de AX sozinha para concluir a tela.

O comando executado contra o binário instalado, cujo SHA-256 confere com o produto de `/tmp/traco-s1-g3-uitests`, foi:

```text
ferramentas/orca/com-trava.sh xcodebuild test -project Traco.xcodeproj \
  -scheme TracoUITests -destination 'platform=iOS Simulator,id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED' \
  -derivedDataPath /tmp/traco-s1-g3-uitests \
  -only-testing:TracoUITests/PerguntaSobreviveUITests -parallel-testing-enabled NO

...PerguntaSobreviveUITests.swift:40: error: XCTAssertTrue failed -
PRÉ-CONDIÇÃO: o Calendário não abriu — a aba não trocou
Computed hit point {-1, -1} after scrolling to visible
Executed 2 tests, with 3 failures (0 unexpected) in 40.990 seconds
** TEST FAILED **
```

Impacto: a pessoa fica no cartão e não alcança a troca para o Calendário no caminho que a S1 diz ter consertado; os dois verdes alegados não são reproduzíveis neste candidato. A correção precisa tornar a troca possível no estado recém-perguntado e deixar os dois testes verdes no mesmo UDID, incluindo a pré-condição que confirma o Calendário de fato na tela. Não corrigi código.

## Defeito anterior: vermelho reproduzido de forma independente

Construí e instalei o pai `cce6beb` apenas no A1DF082C, então percorri Notas → pergunta → Calendário → Notas. Antes da troca, captura e AX mostram o cartão, `pergunta-pendente-notas`, `sabia-falhou-notas` e `repetir-pergunta-notas` (`ferramentas/orca/g3-s1-antes-04-cartao.png` e `/tmp/g3-s1-antes-ax-cartao.json`); após voltar, a captura `ferramentas/orca/g3-s1-antes-06-sumiu.png` e o AX do mesmo instante mostram só `busca-notas` com valor `vazio`. O defeito estava vivo — não é uma correção de problema já caído — e a captura, não a ausência de AX, fundamenta a ausência visual.

## Leitura de arquitetura e honestidade

O diff move uma única instância para `Sessao.conversaNotas` (`Traco/App/Sessao.swift:596`) e a `NotasView` a consome por uma propriedade computada (`Traco/Notas/NotasView.swift:15`): é a camada correta e inclui, estruturalmente, entrada, estado pendente/falha/interrompida/recolhida, trocas, títulos e `semModelo`. As irmãs locais da view — filtro, domínio, ordem, lote, folhas e valores derivados — continuam locais; a S1 as declara fora do escopo, e elas não constituem uma pergunta esperada que some silenciosamente.

Isso não basta para aprovar a honestidade entregue: a tela atual preserva o cartão, mas bloqueia justamente a ida que permitiria demonstrar a preservação na volta. O caminho que não conseguir preservar teria de explicitar a perda; aqui ele não a explica nem permite completar a jornada. Não encontrei mudança de origem, privacidade, envio, gasto ou IA fora do estado de apresentação.

## Diretriz §7 e curva-zero

O relato da S1 cita as seis fases do `design-router` — Ancorar, Sistema, Construir, Mover, Julgar e Portão — e mede a curva-zero como 2 toques mais redigitação → 1 toque, sem gesto novo. A fase **Portão** não se sustenta: o teste e a captura acima mostram que, no estado real recém-perguntado, não há toque alcançável para Calendário. A medida de curva-zero só pode valer após a jornada completa ser observada; neste candidato ela é não comprovada, não uma tela de rolagem aceita como métrica.

## Scorecard G3

| dimensão | nota | prova e limite |
|---|---:|---|
| Visão | 10 | Fecha a lacuna do RUMO: não perder o que se esperava. |
| Contrato | 9 | ADR 2026-09-09c, RUMO e LETRAS-ADR estão coerentes com o local da instância. |
| Correção | **4** | XCUITest novo no candidato: 2 testes, 3 falhas; não há verde atual. |
| Jornada real | **4** | Vermelho do pai foi reproduzido; a jornada verde do candidato não chegou ao Calendário. |
| Design | **6** | As seis fases foram citadas, mas o Portão visual/interativo falhou. |
| Simplicidade | **5** | A barra some depois de perguntar; a contagem 2 → 1 não é verificável. |
| Movimento | n/a | Nenhuma animação foi introduzida. |
| Componentes | n/a | Nenhum componente foi criado ou alterado. |
| Acessibilidade | **5** | AX do candidato põe as abas em `y: 1.0572`; VoiceOver falado não foi acionado por proibição. |
| Performance | n/a | Nenhuma lista, editor ou parser foi alterado. |
| Privacidade e autoria | 10 | Leitura do diff: nenhuma rota protegida, origem ou envio foi tocado. |
| Estado honesto | **5** | O pai perdia o pedido em silêncio; o candidato não demonstrou a volta e não expõe a indisponibilidade desse caminho. |
| Complexidade | 9 | Um objeto compartilhado é a guarda comum; sem dependência nova. |
| Fora do app | n/a | Nenhuma superfície fora do app foi tocada. |
| Relato | 10 | Este relatório registra vermelho, binário, captura/AX, falha e limites. |

**Fecho:** a solução de propriedade do estado é a menor no lugar certo, mas a entrega ainda não tem prova verde reproduzível e falha na navegação que ela precisa demonstrar. A próxima volta deve corrigir esse P1, repetir a jornada no A1DF082C com captura e AX do mesmo instante, e só então reavaliar as seis dimensões abaixo de 9.
