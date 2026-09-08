# Volta E1-B — cancelar o que já foi observado

**Contrato (G0 do orquestrador):** a invariante do cancelamento passa a exigir as
duas condições — `pendente` **e** sem resultado observado — no **modelo**; as duas
ordens testadas; na tela o gesto some (ou fica dito por que não cabe).

**Ciclo:** segunda volta (melhorar a mente do sistema) — a ferramenta deixa de
oferecer um gesto que apaga o que a pessoa observou. Lacuna do EVOLUCAO: a linha
"Intenção→artefato delegado→ação→evidência→ajuste", coluna de estado honesto.

## O defeito, e por que ele é de família

`cancelarAcao` verificava **só** `estado == .pendente`. Observar, por decisão da
08m, **não muda o estado** — é outro eixo. Logo o mesmo cartão que dizia
"Resultado que você informou: Funcionou" oferecia "Cancelar esta ação". O G3 não
deduziu: leu na captura `prova/e1/02-resultado-funcionou-large.png`.

É a doença que a V12 nomeou e que derrubou a V17 no G3: **a regra olha uma
dimensão e o mundo tem duas**.

## O conserto (3 guardas, 1 predicado)

| onde | o que passa a valer | arquivo |
|---|---|---|
| predicado | `podeCancelar(_:)` = `pendente` **E** `observacao(de:) == nil` | [Trabalho.swift](../../Traco/Trabalho/Trabalho.swift) |
| ordem 1 | `cancelarAcao` lê o predicado — observou antes, não cancela depois | Trabalho.swift |
| ordem 2 | `registrarRelato` recusa `resultado` em ação `cancelada` — relato **sem** classificação continua entrando | Trabalho.swift |
| rota de fora | `validar()` recusa o par `cancelada` + evidência com resultado (importação, migração, chamador novo) | Trabalho.swift |
| tela | o gesto some e a linha diz por quê; a view **lê** o predicado, não repete a condição | [TrabalhoView.swift](../../Traco/Trabalho/TrabalhoView.swift) |

A garantia é do agregado. Guarda que vive só na tela é contornável por outra rota
— foi exatamente por isso que o G3 da V17 reprovou.

## G1 — instrumento

Declaro que segurei `ferramentas/orca/com-trava.sh` em **todo** build, **todo**
teste e **toda** sessão de `orca emulator`. Simulador só o meu,
`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, sempre por `-destination id=` e
`-parallel-testing-enabled NO`. Não toquei em `C2416CBC` (Grok), `B91C8DEF`,
`34CC3F94`, `6033B043`, `C7341E64` nem `64F7B8B4`.

```
** BUILD SUCCEEDED **
✔ Test run with 941 tests in 150 suites passed after 10.887 seconds.
** TEST SUCCEEDED **
```

Os dois testes de ordem, isolados:

```
✔ Test observadoAntes_naoSeCancelaDepois() passed after 0.001 seconds.
✔ Test canceladaAntes_naoRecebeResultadoDepois() passed after 0.001 seconds.
✔ Test cancelarAcaoTemGestoESoAlcancaOPendente() passed after 0.001 seconds.
✔ Test run with 13 tests in 1 suite passed after 0.017 seconds.
```

Grep de aviso no log do build: nenhuma linha `warning:`.

## G2 — a tela

Capturas `xcrun simctl io A1DF082C… screenshot`, no Trabalho "Fechar o contrato
com a Acme" que a volta E1 deixou plantado no `default.store` do App Group. Antes
de fotografar, conferi por `nm` que o `Traco.debug.dylib` **instalado** contém
`podeCancelar` — a lei de 08/09 sobre outra sessão instalar por cima.

| captura | o que prova |
|---|---|
| `15-cancelar-ausente-com-resultado-large.png` | o **antes/depois exato** da `02`: mesma ação, "Realização ainda não confirmada" + "Resultado que você informou: Não funcionou", **sem** "Cancelar esta ação" e com o motivo escrito |
| `16-cancelar-ausente-ax5.png` | AX5: os dois eixos e a ausência do gesto, sem clipe |
| `17-motivo-do-gesto-ausente-ax5.png` | AX5: a frase inteira quebrando dentro do cartão |
| `18-cancelar-presente-sem-resultado-large.png` | a contraprova, no mesmo documento e no mesmo build: cartão `Cancelado` sem gestos, e duas ações **pendentes e não observadas** que **continuam** oferecendo "Cancelar esta ação" |

A `18` responde a pergunta óbvia do revisor: o gesto não foi apagado, ele passou a
depender do segundo eixo.

## design-router — rota escolhida

Rota "ajuste local de componente/copy": estados afetados, sistema existente,
mudança e verificação local. Sem moodboard, sem token novo, sem componente novo —
a linha usa `Tema.meta`/`Tema.tintaSuave`, os mesmos das linhas vizinhas do cartão.
Mover/Julgar não se aplicam: não há animação nem elemento novo, só um gesto que
deixa de existir num estado e uma frase que explica a ausência.

## Limites, declarados

- **A versão nascida do relato continua sem foto**: é prova da frente Q, precisa da
  conta Grok que só existe no `C2416CBC`, e esse aparelho eu não toquei. O revisor
  do G3 já confirmou a declaração.
- **O helper do `orca emulator` perdeu a árvore de AX** assim que o Traço abriu
  (`ERR_CONNECTION_REFUSED`), como a ESTEIRA prevê. Dirigi por captura `simctl` do
  meu UDID, lendo posição na própria imagem; nenhuma medida desta volta se apoia
  na árvore de AX. Nada de maestro.
- **A rolagem amplifica de forma variável**, como a V12 achou: usei arrastos de
  0,012 a 0,03 com captura a cada passo.
- **O aparelho estava desligado e em AX5 quando o recebi.** Liguei-o, usei `large`
  para as capturas de tamanho normal e **restaurei AX5** ao fim, conferido por
  `xcrun simctl ui … content_size`. Deixei-o ligado (é onde está a evidência) e
  matei o helper do `orca emulator`.
- **Duas ações a mais no Trabalho plantado** ("Ensaiar a apresentacao", "Ensaiar de
  novo com o time"): criei-as de propósito para a contraprova da `18`. Ambas
  pendentes e não observadas; nada foi apagado.

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | fecha o furo que o G3 achou na lacuna da E1 sem abrir escopo |
| Contrato | 9 | ADR 08n, SPEC e EVOLUCAO coerentes com o código; a invariante é do agregado |
| Correção | 9 | 941/150 verdes; dois testes novos, um por ordem, mais a rota de importação |
| Jornada real | 9 | quatro capturas, incluindo a contraprova de que o gesto continua onde deve |
| Design | n/a | nenhum token, componente ou movimento novo; rota "ajuste local de copy" do design-router |
| Simplicidade | 9 | um gesto a menos num estado, uma linha que explica; nenhuma tela ou passo novo |
| Movimento | n/a | nenhuma animação |
| Componentes | n/a | nenhum componente novo |
| Acessibilidade | 9 | AX5 fotografado, frase quebrando dentro do cartão, identificador na linha nova |
| Performance | n/a | nenhuma lista, editor ou parser tocado |
| Privacidade e autoria | 9 | o resultado da pessoa deixa de ser apagável por um gesto do app |
| Estado honesto | 9 | é a dimensão da volta: o app para de oferecer o desfazer do que foi observado, e diz o motivo |
| Complexidade | 9 | +112/−4 em 5 arquivos, um predicado reusado pela view, nenhum arquivo novo |
| Fora do app | n/a | nada fora do app |
| Relato | — | este documento |
