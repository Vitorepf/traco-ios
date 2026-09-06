# V16-C — correção do G4: o Perfil abre com a lei da casa

Implementador: Claude Opus 5 (front-end e design SwiftUI), 06/09/2026.
Branch `Vitorepf/volta-16-metodos`, topo `122277f` sobre `ab5c052`.
Instrumento: iPhone 17 Pro Max de teste `6033B043-F436-41F9-B4F8-2D9E67761980`
— ligado por mim, build do branch instalado, Dynamic Type `large`, Reduzir
Movimento ligado e depois removido, aparelho desligado ao fim. Nenhum outro
simulador tocado. Build e maestro por `ferramentas/orca/com-trava.sh`.

## O item que bloqueava, e a escolha

O G4 dava duas saídas: **animar** ou **manter o corte e mudar a ADR**.
Escolhi **animar**. A informação é a mesma nas duas telas, o gesto é o mesmo,
o deslocamento no Perfil é maior (414 pt no meio de 21 linhas) — não há motivo
honesto para o Perfil se comportar diferente da Lente, e a exceção que a ADR
teria de nomear não existiria: seria só a ausência de uma linha de código.

**Uma ressalva medida, e ela mudou o código.** A correção literal do G4
(`withAnimation` no toque) não funciona aqui: eu a escrevi, compilei, instalei
e medi — **1 quadro**, exatamente como antes. `withAnimation` disparado na tela
que apresenta não atravessa a fronteira de apresentação do `.sheet`; o estado
atravessa (o bloco aparece), a transação não. Controle do instrumento antes de
concluir: a mesma gravação capturou 88 quadros da apresentação da própria folha
e 553 de uma rolagem, então o gravador não era o culpado.

A lei entra então por `.animation(Tema.animacao(.easeOut(duration:
Tema.Duracao.media), reduzido: reduceMotion), value: provenienciaAberta)` na
folha, com `Tema.transicao(.opacity, reduzido: reduceMotion)` no bloco e
`@Environment(\.accessibilityReduceMotion)` na view. Mesmos tokens, mesma
duração, mesma lei única da ADR 05v — muda só onde a transação mora. A ADR 05x
registra isso em uma frase, para quem passar por aqui depois não repetir a
tentativa.

## O que a tela faz agora (medido, 30 fps)

`ferramentas/orca/g4-v16-perfil.mp4` — 5,3 s, 296 KB, `-crf 30`, um vídeo, dois
trechos:

| trecho | gesto | quadros | duração | a lei |
|---|---|---|---|---|
| 0–2,6 s (normal) | abrir | q9–q15 | ~250 ms | `Duracao.media` 0,25 s, `easeOut` |
| 0–2,6 s (normal) | fechar | q61–q68 | **267 ms** | idem |
| 2,6–5,3 s (Reduzir Movimento) | abrir | q90–q94 | **167 ms** | `Tema.fadeReduzido` 0,15 s |
| 2,6–5,3 s (Reduzir Movimento) | fechar | q148–q152 | **167 ms** | idem |

São os mesmos números que o G4 mediu na Lente (267 ms / 167 ms). A seta gira
junto, porque a rotação está dentro do mesmo `value:`.

`ferramentas/orca/g4-v16-perfil-quadros-depois.png` — 24 quadros a 30 fps numa
folha só (1000 px, 239 KB): linhas 1–2 são a abertura normal (quadros 7–18),
linhas 3–4 a mesma abertura sob Reduzir Movimento (88–99). Dá para ver o
cruzamento de opacidade nas duas e a diferença de fôlego entre elas.

## O recomendado do juiz, feito

- **Uma seta só para um significado só.** A Lente passa de
  `.footnote`/`Tema.tintaFraca` para `.caption2`/`Tema.tintaSuave` — o desenho
  que o Perfil e a `LinhaQueAbre` (ADR 05v) já usam. Prova:
  `g4-v16-c-lente-seta.png` (recolhida) e `g4-v16-c-lente-aberta.png`.
- **Valor padrão morto.** `var identificador = "proveniencia"` virou
  `let identificador: String`; o `init` já o definia sempre.

## As seis fases do `design-router`

| fase | o que eu vi ou fiz |
|---|---|
| **Ancorar** | Contrato dado: a recusa do G4 (`g4-v16-design.md`, CORRIGIR ANTES, Movimento 8) e a ADR 05x. Rota escolhida: "ajuste local de componente" + "motion específico" — não reabri o produto, não fiz moodboard, não toquei na jornada. Li a tela como ela está antes de editar. |
| **Sistema** | Nenhum token novo. `Tema.animacao`, `Tema.transicao`, `Tema.Duracao.media`, `Tema.fadeReduzido`, `Tema.tintaSuave`, `.caption2` — todos já existiam; `Traco/Tema.swift` não foi tocado. Zero hex, zero `.system(size:)` novo. |
| **Construir** | Três arquivos e a ADR: `PerfilView` (a lei), `LenteView` (a seta), `LinhasDeProveniencia` (o padrão morto), `SPEC.md`. `** BUILD SUCCEEDED **`, 0 `warning:`. Suíte da área verde. |
| **Mover** (a que manda aqui) | Medi quadro a quadro antes e depois, e a primeira correção falhou na medição — foi a medição que encontrou a fronteira do `.sheet`, não a leitura do código. O resultado bate com a Lente nos dois modos. Sob Reduzir Movimento sobra a opacidade, que é o que a lei manda para `.opacidade`. |
| **Julgar** | Interrompível: os toques do vídeo completam sem empilhar. "Um aberto por vez" continua: trocar de método faz um fechar e outro abrir na mesma curva. O que ficou de fora e continua dívida do RUMO: a linha que abre ainda não é componente (P1, dona V12) e a quebra da origem em AX5 (P2) — nenhum dos dois entra no escopo desta correção. |
| **Portão** | Este relatório, o vídeo, os quadros e as duas capturas da Lente. Devolvo ao coordenador para o re-G4; não abri outro gate-loop. |

## Limites honestos

- Não capturei AX5 nem o método ausente de novo: o diff não os toca (o G4 já os
  aprovou em `ab5c052`).
- O vídeo é um arquivo com dois trechos gravados em sequência (normal, depois
  Reduzir Movimento ligado por `defaults write` + `notifyutil`), cortados e
  concatenados sem alterar o conteúdo nem a velocidade. As gravações brutas
  ficaram no scratchpad da sessão.
- Reduzir Movimento foi removido e o Dynamic Type devolvido a `large` antes de
  desligar o aparelho.
