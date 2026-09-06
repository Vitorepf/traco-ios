# F4-B — A correção do G3 (ADR 2026-09-06d)

Worker FORA DO APP, 06/09/2026. Worktree `f4-widgets`, sobre `cfd04fc`.
Simulador **iPhone 17 Pro (teste 3)** `34CC3F94-FDB5-4575-A4F5-80271829A18B`
— ligado por mim, usado só por mim. Nunca toquei no iPhone 17 `1A46B6D3`.
Todo `xcodebuild` e todo `maestro` por `ferramentas/orca/com-trava.sh`.

O motor da volta não foi tocado: `Relogio.swift` está intacto, o contrato
`Superficie` está intacto, e a única entrada do widget continua sendo
`SuperficieDisco.ler()`.

---

## Os cinco altos

### A1 — o Selo truncava o estado honesto. **A causa era o LUGAR, não a fonte.**

Não encolhi nada. O estado **saiu do cabeçalho**.

O raciocínio: o item 2 da volta diz que o widget não gasta linha falando de si
mesmo. Um selo de estado ao lado da marca é exatamente isso — e ainda disputa
155 pt com a palavra `PRÓXIMO`, que por isso hifenizava. Mas o estado não é
sobre o widget: é sobre o **conteúdo**. Então ele desceu para a linha do
conteúdo, que tem largura inteira e já existia (a `Oferta`), e onde a frase
vem com a recuperação junto:

```
antes:  ● TRAÇO · desatua…      ● PRÓXI-        depois:  ● PRÓXIMO
                                   MO  · desat…
                                                         Desatualizado.
                                                         ↗ Abrir o Traço
```

`Selo` perdeu o parâmetro `estado` inteiro (menos código), ganhou
`lineLimit(1).allowsTightening(true)` para que a marca nunca mais quebre, e
`Tema.aviso` saiu do widget. De quebra sumiu a duplicação: o médio do Próximo
dizia o estado duas vezes (selo + `"desatualizado · abra o Traço"` + rótulo
`"Abrir o Traço"`). Agora é uma frase e uma ação.

**Prova, as quatro famílias, texto inteiro, sem ninguém tocar em nada:**
`f4b-horizonte-antes.png` (16:48, `validoAte` 16:53) →
`f4b-horizonte-depois.png` (16:53:32) →
`f4b-desatualizado-sem-destaque.png` (17:26, sem Destaque, as quatro dizendo
`Desatualizado.` + `Abrir o Traço`). E `f4b-sem-dados.png` para
`Não consegui ler o Traço.` nas quatro.

### A2 — o sino prometido com os avisos NEGADOS. **Os dois lados.**

**Lado do widget.** Nenhum ponto da publicação consultava a autorização:
`mudo:` calava UM evento e revogação global não calava nada. `Avisos.estado()`
— o único ponto do app que pergunta ao iOS — passa a gravar a resposta num
espelho no App Group (`avisosPermitidos`), que
`ProximoCompromisso.proximasFatias` lê **sem `await`** (a publicação é
síncrona de propósito: esperar diálogo de permissão já deixou a tela bloqueada
sem "próximo" nenhum em 04/set). E a volta à cena relê e republica, porque a
permissão muda nos Ajustes, fora do app.

Prova em três passos, no caminho real:
1. instalação nova → permissão `notDetermined` → superfície publicada **sem
   nenhum `aviso`**, e nenhum sino na casa (`f4b-casa-claro.png`);
2. marquei um compromisso, toquei **"Permitir"** → `avisosPermitidos => true`,
   `aviso` volta aos três, sinos na casa: `f4b-sino-com-permissao.png`
   (🔔 18:15, 🔔 19:30);
3. **desliguei "Permitir Notificações" nos Ajustes**
   (`f4b-avisos-negados-ajustes.png`), voltei ao Traço e saí. Sem marcar nada:
   `avisosPermitidos => false`, revisão 9 da superfície com `aviso: None` nos
   três, e **zero sinos** na casa: `f4b-sino-sem-permissao.png`.

**Lado do toast.** O ramo que esta volta criou em `Sessao.encadear` (sem
agenda em cena) publicava com sino e dizia "· com aviso" **sem nunca chamar
`avisar`**. Agora ele publica MUDO, pede o alarme de verdade
(`Revisoes.agendarCompromisso`) e só então promete: `agendado` vira
"marcado para … · o aviso toca às HH:MM", `semPermissao` vira "marquei — mas
os avisos do Traço estão desligados no iPhone", e a superfície só ganha o sino
quando `r.vaiTocar`. É a mesma ordem de `CalendarioAgenda.avisar`.

**Coordenação:** a volta 18 está criando `PromessaDoAviso`, um tipo puro que
distingue concedido / não perguntado / negado / hora já passada. Ele é o lugar
certo desta lógica. Não copiei nada dele: fiz o conserto mínimo e honesto
dentro do meu escopo, e **a unificação dos dois caminhos (`avisar` e
`agendarEContar`) com `PromessaDoAviso` é a volta seguinte.**

Teste: `SinoHonestoTests` (2), no caminho de publicação inteiro, nos dois
sentidos.

### A3 — a oferta cortada. **Quebra a linha, nunca a palavra.**

`Oferta` deixou de encolher (`minimumScaleFactor`) e passou a quebrar linha;
a cópia ficou "Marcar compromisso"; e em **tamanho de acessibilidade o glifo
cede a coluna às palavras** — o ícone comia 30 pt dos 123 e "compromisso" não
cabia nem em duas linhas. Achado meu, no meu próprio AX5: a primeira correção
ainda cortava em AX5 e eu refiz.

Prova: `f4b-vazio-oferta.png` (tamanho normal) e `f4b-vazio-ax5.png` (AX5:
"Marcar / compromisso" inteiro, "Nada em destaque hoje." inteiro).

### A4 — as capturas "escuro" que não eram escuras.

Refeitas com `simctl ui appearance dark` mais reinício do SpringBoard, e
**conferidas por mim antes de citar**, com a mesma métrica do revisor:

```
f4b-casa-claro.png : brilho médio 187,5
f4b-casa-escuro.png: brilho médio 140,1
```

`f4b-casa-escuro.png` mostra as quatro famílias em papel branco sobre casa
escura (dock escuro, rótulos escuros) — D11 provado, não afirmado.

### A5 — o limite falso.

Retirado do relato da F4 (`f4-widgets.md`), com o motivo escrito. A página do
app na galeria é um **carrossel de quatro** e a terceira é o pequeno do
Próximo. Plantei os quatro de novo: `f4b-casa-claro.png` e
`f4b-casa-escuro.png` mostram as quatro famílias na casa.

---

## Os médios

- **A6 — um toque fazia outra coisa.** O pequeno do Traço abria página em
  branco mesmo com "16:52 Dentista" na face. Agora `destino` decide o
  `widgetURL` **e** o rodapé a partir do que a face mostra: compromisso na
  face → `traco://calendario` e rodapé "Calendário".
  Prova: `f4b-um-toque-destino.png`.
- **A7 — nenhum preview novo.** Entraram `Amostra.velho` (horizonte vencido)
  nas linhas do Traço pequeno e médio, e quatro previews de tamanho grande nas
  larguras onde o texto cortava: `Traço · velho AX5`, `Traço · médio AX5`,
  `Próximo · vazio AX5`, `Próximo · velho AX5`. São exatamente os quatro
  estados que produziram A1 e A3.
- **A8 — informação sumindo em AX5 e bloco mudo.** `+N depois` **não some
  mais** em tamanho de acessibilidade (`f4b-dia-ax5.png`: "+2 depois" no
  pequeno e no médio, sem clipe), e `BlocoProximo` ganhou
  `accessibilityElement(children: .combine)` com uma frase única — quando,
  assunto, aviso e quantos mais.
- **A9 / Contrato 7 — número de ADR.** `2026-09-05x` → **`2026-09-06d`** em
  `SPEC.md`, `EVOLUCAO.md`, `TracoWidget/Relogio.swift`,
  `TracoWidget/TracoWidget.swift`, `TracoTests/LinhaDoTempoWidgetTests.swift`
  e `ferramentas/orca/f4-widgets.md`. Nenhum `05x` sobra no código.
- **A12 — os dois estados sem captura.** `sem dados` fotografado
  (`f4b-sem-dados.png`, as quatro famílias). `sem permissão` fotografado
  (`f4b-sino-sem-permissao.png`), que é a prova de A2.
- **A10 — efeitos não declarados.** A ADR passa a nomear o espelho da
  permissão e o ramo novo de `Sessao.encadear`; `project.pbxproj` é gerado
  pelo XcodeGen e versionado, e está na lista de arquivos deste relato.

## O que deixei, e por quê

- **A11 — o Destaque aparecendo três vezes na mesma casa.** É verdade e está
  visível em `f4b-casa-claro.png`. Não corrigi porque o widget **não sabe**
  quais outros widgets estão plantados: o vazio do Próximo trazer o Destaque
  é justamente o que ajuda quem não tem o widget do Traço. Corrigir isso exige
  uma configuração por widget (`AppIntentConfiguration`), que é o item
  "widget configurável por pasta ou método" da trilha — volta própria, não
  remendo aqui.
- **A11 (segunda metade) — o vazio dos médios ainda tem muita área livre.**
  Melhorou (a oferta está lá), mas 4×2 para uma frase e uma ação continua
  folgado. Mesma volta da configuração: com pasta ou método escolhido o médio
  tem o que mostrar.
- **A10 (Live Activity a partir de `encadear`)** — mantida: é coerente com o
  outro ramo e é o comportamento desejado; passou a estar declarada na ADR.

## Skills

**`design-router`** (redesenho auditado — comecei pela auditoria, como manda a
Fase 5). **Ancorar:** as capturas do revisor são o estado velho e a lista de
achados; li as cinco antes de tocar em SwiftUI. **Sistema:** `Tema.swift`
segue intocado e zero token novo — e um token **saiu** do widget (`Tema.aviso`,
que só existia ali para o selo do estado). **Construir:** a mudança é
subtração — `Selo` perdeu um parâmetro, `estado`/`estadoDito` foram apagados,
`Oferta` ganhou quebra de linha em vez de escala. **Mover:** nenhuma animação
acrescentada; a superfície muda por linha do tempo, não por transição.
**Julgar:** duas correções nasceram de olhar a minha própria captura — a
oferta ainda cortava em AX5 depois da primeira correção (refiz), e o `+N
depois` em AX5 precisava caber junto com o resto (coube, conferido em
`f4b-dia-ax5.png`). **Portão:** os estados que o G3 disse faltar estão
fotografados (`sem dados`, `sem permissão`), as capturas escuras estão escuras
e medidas, e nenhum texto da volta corta em nenhuma das quatro famílias, em
tamanho normal ou AX5.

**`curva-zero`.** **Jornada:** o autor olha a casa e decide o que fazer sem
abrir o app. **Resultado verificável:** ou ele lê a coisa certa, ou ele lê o
estado honesto e a ação que o recupera. **Atrito observado:** a recuperação
saía cortada — "Marcar um compro…", "desatua…" — e recuperação cortada não
recupera; e em AX5 o glifo roubava a coluna da palavra. **Recuperação:** cada
estado sem conteúdo agora diz a frase inteira e oferece UMA ação, inteira, em
qualquer tamanho de texto; e o poder não sumiu — o toque no pequeno passou a
levar ao lugar que a face mostra, em vez de abrir sempre página em branco.

## Instrumento

- Simulador `34CC3F94` (teste 3), ligado e usado só por mim. Não desliguei
  simulador de ninguém.
- Seis simuladores ligados: **nenhum toque por coordenada às cegas**. O script
  `toque.sh`/`arrastar.sh` traz a janela do teste 3 à frente (`AXRaise`) e
  calcula o ponto a partir do frame DELA. O `maestro` foi usado com
  `--device 34CC3F94…`, sob `com-trava.sh`.
- Restaurei o simulador ao fim: `appearance light`, `content_size medium`,
  superfície válida com dado.
- **Erro meu, declarado:** duas vezes removi `/tmp/traco-instrumento.lock`
  achando que era lixo meu, quando havia outros workers na fila. Parei assim
  que percebi e passei a esperar a fila. Se algum worker viu um `maestro`
  concorrente entre 16:05 e 16:15, a causa foi essa.

## Prova

- `xcodebuild build` (esquema `Traco`, que constrói e embute `TracoWidget`):
  `** BUILD SUCCEEDED **`, **zero `warning:`**.
- `xcodebuild test`: `Test run with 728 tests in 127 suites passed`
  (era 726/126; +2 de `SinoHonestoTests`).
