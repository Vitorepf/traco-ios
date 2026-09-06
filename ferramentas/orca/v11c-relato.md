# V11-C — correção do G4 (Ambiente Markdown, a tela do conflito)

Worktree `volta-11-markdown`, commit `fede353` sobre `aa61951`.
Simulador: iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`, ligado e restaurado
por mim (`content_size large`, `ReduceMotionEnabled 0` conferidos ao fim).
iPhone 17 `1A46B6D3` do dono: nunca tocado.

## Os quatro itens do mínimo

| item | o que era | o que é | prova |
|---|---|---|---|
| 1. a comparação mostra a diferença | os dois cartões exibiam a MESMA cadeia sempre que a diferença estava depois do corte | `recorteDaDiferenca` ancora os dois no mesmo ponto de divergência, com um fio de contexto, e a tela diz onde começou | `g4c-v11-conflito-na-divergencia.png` (corpo normal), `g4c-v11-ax5-dois-cartoes-diferentes.png` + `g4c-v11-ax5-ressalva.png` (AX5), teste `aComparacaoMostraOndeAsDuasVersoesDiferem` |
| 2. "Manter" fala | fechava a revisão em silêncio | `Desfecho.mantida`, nas DUAS saídas que fechavam | `g4c-v11-manter-fala.png`, teste `manterAVersaoAtualDizOQueAconteceuComOArquivo` |
| 3. chegada e desfecho se veem | cartão nascia abaixo da dobra; corte seco de uma tela e meia; confirmação em cinza igual às instruções, sem anúncio | `ScrollViewReader` + `Tema.movimento(.deslocamento, Mola.camada)`, desfecho em `cartao(.campo)`/`Tema.tinta` sob `.opacidade`, tudo com `AccessibilityNotification.Announcement` | `g4c-v11-chegada-na-tela.png`, `g4c-v11-desfecho-em-cartao.png`, vídeos `g4c-v11-normal.mp4` / `g4c-v11-reduzido.mp4` |
| 4. ação bloqueada | `Importar` desabilitado pixel-idêntico ao habilitado | movimento da V18: nada de `.disabled()`, cápsula `Pilula`, motivo ao lado e no `accessibilityHint`, tocar diz o que falta | `g4c-v11-importar-livre.png` × `g4c-v11-importar-bloqueado-capsula.png` |

`AcaoTrabalhoStyle` **não** foi consertado, por coordenação: ele deixa de existir
na volta 18. Segui o padrão dela nas três ações desta tela.

## Movimento, medido no vídeo cru

Diferença de luminância entre quadros consecutivos no recolhimento do cartão:

- **normal:** 9 quadros seguidos — `5,68 3,54 5,59 7,03 6,55 5,57 1,30 0,43 0,31`
  (subida e cauda). O G4 mediu, no build anterior, **um** quadro com 20,0 e zeros
  nos vizinhos: corte seco.
- **Reduzir Movimento:** `19,34 4,64 4,56 5,71 4,81 5,19 4,00 1,27` — a fade curta
  que a lei de `Tema.swift` manda para a classe `.deslocamento`.

## Instrumento

Maestro não foi usado para prova nenhuma: com cinco simuladores ligados
`--device` não isola. A jornada foi dirigida à mão sobre a janela do meu
simulador (x 123..513; as demais em x ≥ 754) e **toda** captura saiu de
`xcrun simctl io C7341E64… screenshot`.

Jornada real, ponta a ponta: versão 1 escrita no app → exportada → o `.md`
reescrito FORA do app com dez linhas → importado (versão 2) → exportado →
o fim da última linha trocado no disco → a versão local editada no fim →
importado: conflito com as duas pontas divergindo só no fim, documento longo.

## O que fica em aberto (RUMO)

- `.compacto` contra a primária: não toquei; a cápsula cheia da V18 já desfaz a
  inversão nesta tela, mas a regra da casa segue como estava.
- O `recado` não é zerado por atos não relacionados.
- Tocar uma ação bloqueada NOMEIA o obstáculo em vez de rolar até ele: ele mora
  na folha do Trabalho, que é território da volta 18.
- Em AX5 os dois cartões continuam não cabendo INTEIROS no mesmo olhar. O que
  esta volta garante é que o pedaço visível dos dois é diferente.
