# F4-C — a correção do re-G3 (ADR 2026-09-06d)

Worker FORA DO APP, Claude Opus 5, 06/09/2026. Worktree `f4-widgets`, base
`de85760`. Simulador **iPhone 17 Pro (teste 3)** `34CC3F94-FDB5-4575-A4F5-80271829A18B`
— ligado, usado e restaurado por mim. O iPhone 17 `1A46B6D3` do dono **não foi
ligado**. Todo `xcodebuild` por `ferramentas/orca/com-trava.sh`. Nenhuma prova
de tela saiu do `maestro`: todas de `xcrun simctl io … screenshot`.

## O que a volta consertou

### R1 (ALTO) — o estado honesto não depende mais do ramo

A minha correção do A1 estava certa no diagnóstico (o estado é do CONTEÚDO, não
do widget, e por isso desceu do cabeçalho para a linha do conteúdo) e errada na
execução: na view ele virou o **último `else if`** de uma cadeia que começa no
Destaque. Bastava haver Destaque posto para ele nunca ser alcançado — e aí,
passado o horizonte, o widget do Traço largava a agenda inteira e **ficava
calado**. Troquei verdade truncada por silêncio, no defeito que abriu a volta.

O conserto não é um `if` a mais na view; é **tirar a decisão da view**.
`EstadoNaFace` (em `TracoWidget/Relogio.swift`, o arquivo que já compila no alvo
de testes) diz a lei: *passada a validade, toda face diz*. Só o LUGAR muda —
sem conteúdo em cima, o estado é o miolo e carrega a recuperação; com conteúdo,
desce ao **rodapé** (`Velho`), onde o atalho cede a linha: a promessa da face
vem antes de mais um caminho para dentro do app.

Nas duas famílias da tela bloqueada, que não têm rodapé: a etiqueta `DESTAQUE`
vira `DESATUALIZADO`, e a linha do `accessoryInline` passa a dizer
`Traço · desatualizado` em vez de mostrar a frase de ontem como se fosse a de
hoje.

**Prova (capturas minhas, do aparelho, com o build desta volta):**

| arquivo | o que mostra |
|---|---|
| `f4c-horizonte-antes.png` | 19:31 — Destaque posto e agenda viva nos três widgets plantados |
| `f4c-horizonte-depois.png` | 19:35, `validoAte` vencido, **sem eu tocar em nada**: o pequeno do Traço e o médio do Traço mostram o Destaque **e** `Desatualizado.` no rodapé; o pequeno do Próximo diz `Desatualizado. / Abrir o Traço` |
| `f4c-horizonte-depois-ax5.png` | o mesmo estado em AX5: `Desatualizado.` inteiro nas três faces |

### M1 (MÉDIO) e a segunda metade do A11 — o médio vazio virou quadro de ofertas

O revisor recusou adiar a densidade do médio vazio, e ele tem razão: widget
configurável não resolve calendário vazio. Sem Destaque e sem agenda **não há
conteúdo** para mostrar — o que existe é o que o autor PODE fazer daqui. A face
inteira passa a ser isso: três ações reais, uma por linha, com o alvo na linha
toda (`Nova nota`, `Marcar compromisso`, `Recordar`), e o cabeçalho abre mão das
miniaturas, que seriam a mesma ação duas vezes.

Isso fecha o M1 pela raiz: as ações moram no **corpo**, não no cabeçalho, então
continuam existindo em tamanho de acessibilidade — onde o cabeçalho se cala e o
vazio ficava mudo. Em AX5 são duas; "Recordar" continua no tamanho normal e no
app (curva-zero: o poder muda de lugar, não some).

| arquivo | o que mostra |
|---|---|
| `f4c-vazio-oferta.png` | 19:37 — o médio vazio com as três ações ocupando os 4×2, contra a frase solitária de antes |
| `f4c-vazio-oferta-ax5.png` | AX5: o médio vazio com **duas ações** — antes não tinha nenhuma (M1) |

## Custo assumido, declarado

**Em AX5, no PEQUENO, com Destaque longo e horizonte vencido, a frase do
Destaque perde a quarta linha para o rodapé do estado** — `Terminar o
capítul…` em `f4c-horizonte-depois-ax5.png`. É escolha, não descuido: 155 pt não
comportam quatro linhas de AX5 mais a linha do estado, e saber que o que se vê é
velho vale mais que a última linha da frase. O texto inteiro continua no rótulo
de VoiceOver. **No tamanho normal não há corte nenhum** — o `linhasDoDestaque`
só cede em `tipo.isAccessibilitySize`, porque tirar uma linha no tamanho normal
seria trocar o silêncio da R1 por um `capítulo do…`, que é o A1 outra vez.

## O que ficou de fora, e por quê

- **O médio do Próximo não foi replantado.** Três das quatro famílias da casa
  estão plantadas e fotografadas (pequeno do Traço, médio do Traço, pequeno do
  Próximo). A quarta não entrou: a galeria de widgets do iOS 26 é um carrossel
  de quatro páginas e ele **para de paginar** — o mesmo instrumento que travou o
  revisor. A R1 não é defeito do widget do Próximo (ele já dizia
  `Desatualizado.` antes e depois, e está na captura), então a prova do que a
  volta consertou não depende dessa família.
- **`accessoryRectangular` e `accessoryInline` na tela bloqueada** seguem sem
  render no simulador (limite da F1 §7, aceito pelo revisor). A mudança das duas
  está no código e nos previews; a captura é do aparelho do dono.

## Instrumento — dois achados que valem para quem vier

1. **O container do App Group muda de UUID entre instalações.** O `semear.py`
   da F4 tinha o UUID cravado e passou a escrever num container **órfão**: nada
   do que eu semeava chegava ao app, e eu perdi ~20 min achando que o
   `cfprefsd` mentia. O jeito certo é achar o container pelo metadata
   (`MCMMetadataIdentifier == group.app.traco`).
2. **Sem ATIVAR o app Simulator, o clique sintético não registra.** `AXRaise`
   põe a janela na frente mas não dá foco ao processo; com seis simuladores
   abertos, todos os meus primeiros toques caíram no vazio. Um
   `tell application "Simulator" to activate` antes de cada toque resolveu.

## As skills, e onde elas aparecem na tela

**`design-router` — redesenho, então comecei auditando (fase Ancorar).** Li a
recusa inteira, os dois widgets, as quatro famílias e a captura do próprio
revisor (`f4-reg3-velho-com-destaque-cala.png`) ANTES de tocar em SwiftUI, e
percorri as combinações de estado × família até achar a que ninguém olhava:
velho **com** Destaque. **Sistema:** nenhum token novo — `Velho` usa
`Tema.label`, `Tema.miudo` e `Tema.tintaFraca`, e o quadro de ofertas reusa o
`AtalhoTraco` que já existia; `Tema.swift` continua fora do diff. **Construir:**
a decisão saiu da view para `EstadoNaFace`, e o rodapé é a peça mínima que
faltava. **Mover:** nenhuma animação acrescentada — o estado honesto não pisca
nem entra deslizando; a mudança acontece na virada da linha do tempo, que é
movimento do sistema. **Julgar:** a primeira versão desta correção **truncou o
Destaque** no pequeno (`r1-intermediario`, no scratchpad) porque eu tirei uma
linha da frase em todo tamanho; vi na minha própria captura, restringi o corte a
AX5 e refiz o build e a captura — está descrito acima como custo assumido, não
escondido. **Portão:** os dois defeitos têm captura do aparelho, no estado que
elas dizem mostrar, com o build desta volta instalado; o que não tem captura
está nomeado acima com o motivo.

**`curva-zero`.** **Jornada:** o autor olha a casa para saber o que fazer agora;
quando não há nada marcado, a superfície tem de dizer o que ele PODE fazer.
**Resultado verificável:** um toque abre a tela certa — nota nova, calendário ou
Recordar —, e as três ações são `Link` de verdade no médio. **Atrito
observado:** em AX5 o médio vazio não oferecia nada (M1, achado do revisor na
tela dele), e no tamanho normal gastava 4×2 numa frase. **Recuperação:** ela
mudou de lugar (do cabeçalho para o corpo) exatamente para não sumir no tamanho
grande; e no estado velho a recuperação é a própria frase honesta mais o toque
que abre o app.
