# re-G3 (terceiro) C1 — a sonda inteira e o vídeo

**Veredito: APROVADO no mérito do commit `8bd7382`; não mesclável.** A sonda
agora mede as duas metades da 08f em cada quadro, as faz ficar vermelhas de
forma independente, e o MP4 novo foi efetivamente aberto e mostra a Página que
promete. `main` está em `55af39f`, à frente do candidato; a reconciliação é
outra volta do orquestrador.

## Instrumento e limites

Usei o 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`, sempre por UDID explícito,
e toda corrida passou por `ferramentas/orca/com-trava.sh`. Não usei maestro,
`orca emulator`, mouse/computer-use, Siri, ditado, VoiceOver, fala ou iPad.

Para medir o pai `4898703`, criei `/tmp/c1-caret-pai-4898703`, trouxe **somente
`TracoTests/EscritaVisivelTests.swift`** deste candidato e usei DerivedData
separado. O checkout foi removido com `git worktree remove --force` ao fim.

**Aviso de aparelho — início e fim:** às 06:21 de 09/09 o Pro Max
`6033B043-F436-41F9-B4F8-2D9E67761980` não tinha `xcodebuild` ativo e a F5b-C
estava encerrada; repeti nele a sonda sob a mesma trava. A corrida terminou às
06:22 verde, sem tocar no aparelho Grok `C2416CBC`.

## A sonda inteira, e os dois vermelhos

`Quadro` separa `noPapel` (`E ⊆ P`) de `semIntruso` (`P ∩ O = ∅`) em
`TracoTests/EscritaVisivelTests.swift:402-405`; `contar` relata os dois totais
separadamente e as asserções são independentes nas linhas 524-525.

No candidato, no meu 17e:

```
GAVETA AX5: 0 quadro(s) com a linha ativa fora do papel, 0 com outra superfície sobre ela
GAVETA AX5, sonda adversarial: 50 quadros, 35 acusados (P ∩ O ≠ ∅), 0 fora do papel
GAVETA large: 0 quadro(s) com a linha ativa fora do papel, 0 com outra superfície sobre ela
GAVETA large, sonda adversarial: 51 quadros, 35 acusados (P ∩ O ≠ ∅), 0 fora do papel
✔ Test run with 2 tests in 1 suite passed after 54.441 seconds.
** TEST SUCCEEDED **
```

A faixa adversarial faz **só** a metade dos intrusos ficar vermelha: há 35
acusações e zero quadros fora do papel nos dois tamanhos. No pai com esse mesmo
instrumento e esse mesmo 17e, a geometria fez a outra metade ficar vermelha por
si: AX5 deu 6 fora e 2 cobertos, logo 4 quadros vermelhos exclusivos de
`E ⊆ P`; `large` deu 6 e 6. As duas asserções falharam em ambos os tamanhos:

```
GAVETA AX5: 6 quadro(s) com a linha ativa fora do papel, 2 com outra superfície sobre ela
Expectation failed: (totalFora → 6) == 0
Expectation failed: (totalCoberto → 2) == 0
GAVETA large: 6 quadro(s) com a linha ativa fora do papel, 6 com outra superfície sobre ela
✘ Test run with 2 tests in 1 suite failed after 54.629 seconds with 4 issues.
** TEST FAILED **
```

No Pro Max recém-liberado, a repetição do candidato também fechou ambas as
metades e refez o negativo do intruso:

```
GAVETA AX5: 0 fora, 0 coberto; adversarial 36/51 acusados, 0 fora
GAVETA large: 0 fora, 0 coberto; adversarial 35/51 acusados, 0 fora
✔ Test run with 2 tests in 1 suite passed after 55.115 seconds.
** TEST SUCCEEDED **
```

## Vídeo aberto

Abri `ferramentas/orca/c1/c1c-pagina-na-sonda.mp4`: H.264, 390×844, 20 fps,
36,15 s. Inspecionei um mosaico de 36 quadros (um por segundo) e amostras nos
instantes 0, 18 e 34 s: vê-se a Página **Notas**, a digitação, o cartão
“Trabalhar nisto / Mais ações da nota”, a faixa vermelha adversarial sobre
“pensar, agora”, a nota longa, teclado, aviso “A sábia não respondeu” e toast.
Não há Tela Inicial do iPhone; o início é a Página vazia com data.

## Scorecard

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 10 | A invariante protege a escrita ativa inteira. |
| Contrato | 10 | Duas metades por quadro, duas asserções e dois negativos independentes. |
| Correção | 9 | Pai vermelho no mesmo 17e; candidato verde no 17e e Pro Max; reexecutei a suíte focada, não a integral. |
| Jornada real | 9 | Página hospedada, teclado real, cartão, aviso, toast e vídeo conferido. |
| Design | n/a | Nenhuma superfície de produto foi alterada neste commit. |
| Simplicidade | 9 | Instrumento estendido no teste existente; sem dependência. |
| Movimento | n/a | O commit não altera animação de produto; o vídeo é evidência do portão temporal. |
| Componentes | n/a | Nenhum componente alterado. |
| Acessibilidade | 9 | `large` e AX5 no 17e e Pro Max; VoiceOver falado é limite declarado. |
| Performance | n/a | A mudança mede só no target de testes, não altera o caminho de produção. |
| Privacidade e autoria | n/a | Sem alteração de dados, origem, acesso ou envio. |
| Estado honesto | 10 | MP4 falso removido; o novo foi aberto e seu alcance é descrito. |
| Complexidade | 9 | Sem código de produto nem abstração nova. |
| Fora do app | n/a | Sem superfície fora do app. |
| Relato | 10 | Linhas de resultado, vídeo visto, pai descartável removido e limites explícitos. |

Não há dimensão aplicável abaixo de 9 e não há achado P0/P1 no diff de
`8bd7382`. A aprovação é apenas de mérito: `main` avançou, portanto não é
autorização para mesclar sem a reconciliação própria.
