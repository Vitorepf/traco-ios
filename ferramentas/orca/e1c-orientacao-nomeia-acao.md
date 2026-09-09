# E1-C — a orientação diz de QUAL ação está falando, e o G5

Implementador (Claude Opus 5), 08/09/2026, 18h40–19h10. Branch `Vitorepf/volta-e1-estados`,
worktree próprio. Simulador **iPhone Air `64F7B8B4`** — o que o juiz devolveu, em `large`.
Nenhum toque no `C2416CBC` (Grok), no `34CC3F94` (Q-C), no `6033B043` (A1) nem no `A1DF082C`.
Nenhum mouse, nenhum maestro. Toda sessão de `orca emulator` (attach, tap, gesture, kill) e todo
`xcodebuild` passaram por `ferramentas/orca/com-trava.sh`; **segurei a trava** em cada uma.
Não editei o relatório do juiz (`g4-e1-design.md`) nem o do revisor (`revisao-e1-estados.md`).
Não mesclei nada em `main`.

## O que a volta consertou

**P2 do G4 — a orientação seguia o último relato do Trabalho inteiro e não dizia de qual ação.**
Com três ações e três resultados, a instrução mandava *"proponha um caminho diferente"* num
Trabalho cuja ação principal a pessoa disse que **funcionou**. A promessa da 08m — *"o resultado
informado muda a próxima orientação"* — só se sustenta se dá para saber **qual** resultado e **de
qual** ação.

Conserto, em um lugar só: `TrabalhoView.acaoObservada(_:)` resolve o texto da ação do último
resultado, e os **dois textos** passam a nomeá-la.

| onde | antes | depois |
|---|---|---|
| linha da tela (`TrabalhoView.swift:1149`) | "A revisão vai partir do resultado que você informou: Não funcionou." | "A revisão vai partir do último resultado que você informou, **na ação “Ensaiar a apresentacao”**: Não funcionou." |
| pedido à IA (`orientacaoDoRelato`) | "A pessoa informou que NÃO FUNCIONOU. Proponha um caminho diferente…" | "A pessoa informou que **a ação “Ensaiar a apresentacao”** NÃO FUNCIONOU. Proponha um caminho diferente…" |

Os três textos por resultado **não mudaram de conteúdo** — só ganharam sujeito. O contexto da IA
já levava o resultado por ação (`OficinaTrabalho.swift:502`); faltava o **pedido vigente**
concordar com ele, e é o pedido que prevalece.

**P3 do G4 — ordem de foco.** A linha "A revisão vai partir…" era renderizada **abaixo** do botão
"Revisar com estes relatos": o VoiceOver lia relato → botão → e só então de que resultado a
revisão parte. Passa a vir **antes** do botão. Sem componente novo, sem mudar tinta nem fonte.

ADR **2026-09-08o** no `SPEC.md`, depois da 08n. A `08m` continua sendo a ADR da E1.

## A prova, na tela viva

Estado plantado no App Group do `64F7B8B4`: o Trabalho do juiz ("Fechar o contrato com a Acme"),
três ações e **cinco relatos** — proposta *Funcionou* e depois *em parte*, orçamento *em parte*,
ensaio *Não funcionou* duas vezes. É o cenário do `g4-e1-09`, com o último resultado numa ação
**diferente** da principal.

| captura | o que mostra |
|---|---|
| `e1c-01-linha-nomeia-a-acao-antes-do-botao-large.png` | os três relatos com três ações distintas, a linha nomeando **“Ensaiar a apresentacao”** e o botão **abaixo** dela (P2 + P3 na mesma captura) |
| `e1c-02-pedido-nomeia-a-acao-large.png` | o campo do pedido com *"A pessoa informou que a ação “Ensaiar a apresentacao” NÃO FUNCIONOU…"*, e a falha do provedor dita com honestidade logo abaixo |
| `e1c-03-pedido-nomeia-a-acao-ax5.png` | o mesmo pedido em AX5: quebra sem clipe, o campo cresce |
| `e1c-04-linha-nomeia-a-acao-ax5.png` | a linha inteira em AX5, sem clipe, com o botão depois dela |
| `e1c-05-large-restaurado-linha-e-botao.png` | tamanho de letra **restaurado a `large`**, conferido por captura, com a linha e o botão na ordem certa |

**Contraprova no próprio documento.** Os três pedidos gravados no Trabalho, na ordem, dizem:

```
falhou | A pessoa informou que NÃO FUNCIONOU. Proponha um caminho diferente…          (juiz, antes)
falhou | A pessoa informou que funcionou EM PARTE. Preserve o que ela relatou…        (juiz, antes)
falhou | A pessoa informou que a ação “Ensaiar a apresentacao” NÃO FUNCIONOU…         (esta volta)
```

Antes e depois no **mesmo documento**, gerados pela **mesma tela**, sem editar JSON de pedido.
O `estado: falhou` é o limite declarado: sem conta Grok neste aparelho, a versão não nasce — a
tela diz a falha ("A preparação anterior foi malsucedida. O pedido continua disponível.") em vez
de escondê-la.

## O G5

**1. `main` trazida.** `git merge main` — **sem conflito nenhum**, nem em `SPEC.md`: a V12 escreveu
a `08f` no lugar cronológico dela (`SPEC.md:5583`) e as minhas `08m`/`08n` ficaram onde estavam.
Ordem das ADRs conferida: `…08f · 08g · 08h · 08i · 08j · 08k · 08m · 08n · 08o`.
`git log HEAD..main` = **0**.

`main` andou outra vez enquanto eu fechava (`d27c85e`, só `ferramentas/orca/RUMO.md`, 7 linhas de
markdown). Trouxe-a também — segundo merge sem conflito — e **reexecutei a prova na árvore final
`157e857`**, para que nenhuma linha colada aqui seja de uma árvore que já não existe.

**2. Árvore mesclada provada no `64F7B8B4`**, com `-destination id=`, `derivedDataPath` próprio e
`-parallel-testing-enabled NO`:

```
** BUILD SUCCEEDED **          (zero linhas de warning: no build)
✔ Test run with 947 tests in 153 suites passed after 74.487 seconds.   (3a5cb1c + a mudança)
** TEST SUCCEEDED **
✔ Suite PortaoDoMovimentoTests passed after 1.013 seconds.
✔ Test run with 2 tests in 1 suite passed after 1.013 seconds.

✔ Test run with 947 tests in 153 suites passed after 54.351 seconds.   (árvore final 157e857)
** TEST SUCCEEDED **
✔ Test run with 2 tests in 1 suite passed after 0.999 seconds.         (portão do movimento)
** TEST EXECUTE SUCCEEDED **
```

941 → **947**: 5 vieram da V12 e **1 é meu** (`aOrientacaoNomeiaAAcaoDoUltimoResultado`, que planta
duas ações com resultados opostos e exige que a orientação nomeie a do **último** e **não** a que
funcionou). Nenhum vermelho vindo de `main`.

O dylib instalado é o desta volta, não o de `main`: `nm` no `Traco.debug.dylib` do contêiner acha
`acaoObservada` (6 símbolos).

**3. Evidência solta comitada.** As 16 `g4-e1-*.png` do juiz e as 5 `e1c-*.png` desta volta,
reduzidas com `sips -Z 1000`:

| lote | antes | depois | maior arquivo |
|---|---|---|---|
| 16 × `g4-e1-*.png` | 4 576 KB | 2 372 KB | 167 KB |
| 5 × `e1c-*.png` | 1 493 KB | 840 KB | **187 KB** |

Teto de 400 KB por arquivo: **cumprido com folga**. Os relatórios `.md` do juiz e do revisor
entram **sem edição**.

## Design-router, as seis fases (proporcional ao tamanho da mudança)

O roteador classifica isto como **"ajuste local de componente/copy"** — a menor rota, que ele
próprio diz não exigir moodboard, tokens novos nem sete críticos. `gate-loop` é do orquestrador;
não abri outro.

- **Ancorar** — pessoa: quem informou resultados em mais de uma ação e vai pedir a revisão. Tarefa:
  saber de que resultado a revisão parte. Resultado observável: a ação nomeada na tela e no pedido.
- **Sistema** — nada criado: `Tema.meta` e `Tema.tintaSuave`, os mesmos das linhas vizinhas.
  Zero cor, fonte ou duração literal nas linhas novas.
- **Construir** — dois textos ganham sujeito; um `Text` sobe para antes do botão; um lugar só
  (`acaoObservada`) resolve a ação, em vez de repetir a busca em dois sítios.
- **Mover** — nada. Nenhum `withAnimation`, `.animation` ou `.transition` no diff; `reduceMotion`
  não tem o que respeitar. `PortaoDoMovimentoTests` verde.
- **Julgar** — pares antes/depois na tabela acima e nos três pedidos gravados no documento; AX5
  conferido nas duas frases novas.
- **Portão** — build limpo, 947/153 verde, portão do movimento verde, ADR 08o, tamanho de letra
  restaurado e conferido por captura.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | fecha o P2 que fazia a promessa central da 08m funcionar por acaso; linha do EVOLUCAO atualizada |
| Contrato | 9 | ADR 08o curta, `SPEC.md` em ordem cronológica após o merge, `EVOLUCAO.md` coerente |
| Correção | 9 | teste novo que falha se a orientação nomear a ação errada; 947/153 verde; portão do movimento verde |
| Jornada real | 9 | 5 capturas do `64F7B8B4`, `large` e AX5, com os três pedidos gravados como contraprova no mesmo documento |
| Design | 9 | seis fases acima; só tokens de `Tema`; nenhuma tela, componente ou cor nova |
| Simplicidade | 9 | zero toque a mais; a mesma linha passa a dizer mais, e a premissa vem antes do gesto |
| Movimento | n/a | nenhuma animação no diff (`withAnimation`/`.animation`/`.transition`: 0) |
| Componentes | n/a | nenhum componente novo nem alterado |
| Acessibilidade | 9 | P3 consertado (premissa antes do botão); AX5 sem clipe nas duas frases (`e1c-03`, `e1c-04`); **não validei com VoiceOver humano** |
| Performance | n/a | duas interpolações de string num bloco que já existia |
| Privacidade e autoria | 9 | "resultado que **você** informou" continua atribuindo a observação à pessoa; nada publica nem envia |
| Estado honesto | 9 | a falha do provedor continua dita na tela (`e1c-02`), e o pedido fica guardado |
| Complexidade | 9 | +1 função de 4 linhas, dois textos com sujeito, um `Text` movido de lugar |
| Fora do app | n/a | não toca widget, Ilha nem StandBy |
| Relato | — | do revisor |

## O que fica em aberto, e é honesto dizer

1. **`causaDoRelato` continua dizendo "desta ação" sem nomeá-la.** É o mesmo buraco, no motivo
   gravado no cartão da versão. **Não consertei de propósito:** ali o motivo já carrega o relato
   inteiro contra o teto `Limite.motivoDoAjuste`, e enfiar o texto da ação empurraria o relato
   para fora. Precisa de decisão sobre o orçamento, não de uma linha.
2. **O cartão da ação continua mostrando só o último resultado dela** (P3 nº 3 do juiz). O
   histórico inteiro fica em "O que aconteceu"; nada se perde.
3. **Os quatro itens com IA real** que o juiz listou continuam da frente Q — não os tentei.
4. **VoiceOver humano** não foi exercitado; a ordem de foco está provada pela ordem de render.

## Limites do instrumento, e um achado novo

**`orca emulator gesture` exige `type` em cada ponto** — `begin`, `move`, `end`. Sem ele a chamada
devolve `ok:false` com `"gesture point 0 type must be begin, move, or end"` e **não faz nada**;
quem engolir o stderr vê a tela parada e conclui que a rolagem não funciona no aparelho. Perdi
três tentativas assim. Forma que funciona:

```
orca emulator gesture '[{"type":"begin","x":0.92,"y":0.60},
                        {"type":"move","x":0.92,"y":0.585},
                        {"type":"end","x":0.92,"y":0.57}]' --device <UDID> --json
```

A amplificação que a V12 e a E1 registraram continua: um arrasto de 0,03 de tela anda uma tela
inteira em `large` e mais em AX5. Candidato a entrar na ESTEIRA — não a editei porque é arquivo
partilhado e há voltas em paralelo.

**Sem árvore de AX:** o helper não a entrega com o Traço aberto (já registrado pelo revisor da
E1-B e pelo juiz). Toda posição desta passada veio da captura `simctl io 64F7B8B4` do instante
anterior, e cada toque foi conferido pela captura seguinte. **Nenhuma medida de geometria** neste
relato — só leitura de conteúdo.

**Uma reinstalação apagou a permissão de calendário** e o diálogo do sistema voltou; concedi por
`simctl privacy grant calendar` e, como o diálogo insistiu, por toque. Não é defeito da volta.

**Um toque em "Revisar" mandou o app para a tela inicial** sem relatório de crash em
`CrashReporter`, e nenhum pedido foi gravado; a repetição na tentativa seguinte funcionou e gravou.
Não consegui reproduzir e não o vendo como achado — registro como o que é: um evento único, não
explicado.
