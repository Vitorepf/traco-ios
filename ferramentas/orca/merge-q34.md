# MERGE-Q34 — o que foi medido entra em `main`, e a tela passa a dizer o que a medida leu

**Linha do ciclo.** G5 (fecho) das voltas Q3-B e Q4-B. Serve à intenção *"a IA melhora
por medida"*; reduz o obstáculo *"trabalho medido e revisado preso em branch que diverge
de `main` a cada hora"*; prova-se por `main` verde na suíte integral, com as três linhas
do Perfil dizendo o que o LOTE-3 leu — vistas na tela, não só no teste.

**Aparelhos.** Um só: **`34CC3F94-FDB5-4575-A4F5-80271829A18B`** (iPhone 17 Pro, teste 3),
o de TRABALHO. Encontrei-o **já ligado** às 01:25Z e **deixo como achei** — não o liguei,
não o desligo. **Não toquei no `B91C8DEF`**: nenhum install, nenhuma sonda, nenhuma
chamada de rede a modelo nenhum. Toda ordem de instrumento passou por
`ferramentas/orca/com-trava.sh`, e a **sequência de captura inteira** (instalar → conceder
→ lançar → navegar → mirar → fotografar) coube **numa chamada só**, que é a lei de 09/09.

**Voz, VoiceOver e iPad:** nenhum acionado, em momento nenhum.

## 1. O grafo do que entrou

```
*   21a2dc9 MERGE-Q34: o re-G3 da Q4 entra em main — instigar e contrapor seguem indisponíveis
|\  
| * 91a314c G3 Q4: lê LOTE-3 e mantém instigar e contrapor indisponíveis
* |   9f4e11a MERGE-Q34: o re-G3 da Q3 entra em main — a sobra ausente, lida e registrada
|\ \  
| * | 508cdd9 G3: reprova Q3-B pela sobra ausente
* | |   afe16e9 MERGE-Q34: LOTE-3 entra em main — Q3-B e Q4-B medidos num binário só, 114 execuções numa janela
|\ \ \  
| * | | cd591e1 LOTE-3: os consertos da Q3 e da Q4 medidos num binário só — 114 execuções, uma instalação, e a régua que era mais dura que a fixture
| * | |   b9059fc Merge branch 'Vitorepf/volta-q4-instigar' into Vitorepf/lote-ia-09c
| |\ \ \  
| | | |/  
| | |/|   
| | * | dcbf7c6 Q4-B: a proibição por nome comprou mudez; a por procedência devolve a voz (ADR 09i, emenda)
| | * | 511b7e2 G3 Q4: reprova instigar e contrapor por leitura independente
| * | | 65dd87c Merge branch 'Vitorepf/volta-q3-notas' into Vitorepf/lote-ia-09c
| | |/  
| |/|   
| * | e83dd11 Q3-B: reconhecer o dado não é responder — o prompt mandava parar, e o pedido não dizia que dia é hoje (ADR 2026-09-09h)
| * | a357160 G3: reprova responder nas Notas pela leitura independente
* | | f99d8ab MERGE-Q34: LOTE-1 e LOTE-2 entram em main — 76 e 114 execuções com a prova no repositório
* | | 2f46bd9 LOTE-2: as mesmas fixtures em 4.5 e 4.6 — 114 execuções, uma alavanca só, e as guardas mecânicas não separam os três
* | | 79ff054 LOTE: as três operações medidas num binário só — 76 execuções, 0 erro de transporte, e a conta não caiu
* | |   edb4dad Merge branch 'Vitorepf/volta-q4-instigar' into Vitorepf/lote-ia-09
|\ \ \  
| | |/  
| |/|   
| * | aec62d4 Q4: o andaime é nosso — instigar pergunta sobre o autor, contrapor se sustenta (ADR 2026-09-09i)
|  /  
* / 5e15911 Merge branch 'Vitorepf/volta-q3-notas' into Vitorepf/lote-ia-09
```

Quatro pontas, quatro mesclas `--no-ff`, **nenhuma história reescrita**. Os SHA que os
relatórios citam continuam alcançáveis — conferido um a um:

| SHA | o que é | alcançável de `HEAD` |
|---|---|---|
| `e83dd11` | Q3-B | ✓ |
| `dcbf7c6` | Q4-B | ✓ |
| `508cdd9` | re-G3 da Q3 | ✓ |
| `91a314c` | re-G3 da Q4 | ✓ |
| `2a06314`, `aec62d4` | Q3 e Q4 originais | ✓ |
| `79ff054`, `2f46bd9`, `cd591e1` | LOTE-1, LOTE-2, LOTE-3 | ✓ |

**Ordem escolhida, e por quê.** `lote-ia-09` primeiro, `lote-ia-09c` depois. O 09c descende
de `2a06314` e `aec62d4`, que o `lote-ia-09` também mesclou: entrando o mais VELHO antes, a
segunda mescla acha essas duas bases comuns e resolve o código sozinha. Na ordem inversa a
base comum cairia em `9b99770` e o `Sabia.swift` conflitaria à toa. Os dois re-G3 entram por
último: cada um é **um commit só de `.md`** sobre um pai que já está dentro do 09c.

**O único conflito: `SPEC.md`, três trechos, e todos a MESMA ADR em dois momentos.** O
`HEAD` trazia a 09h/09i como a Q3 e a Q4 as escreveram; o 09c as trazia com as emendas da
Q3-B e da Q4-B. **Li os dois lados** — o 09c é superconjunto estrito: o diff `HEAD → 09c`
em `SPEC.md` remove **uma** linha, o título curto da 09h, que ele substitui pelo longo, e
acrescenta 152. Resolvi pelo 09c e conferi do tamanho da alegação, como manda a
`LETRAS-ADR.md`: `git diff Vitorepf/lote-ia-09c -- SPEC.md` no lado resolvido = **vazio**,
zero marcadores de conflito.

**`Sabia.swift` não conflitou**, e a razão é boa de registrar: `main` **não tocou em código**
desde `9b99770` — andou só em `ferramentas/orca/ESTEIRA.md` e `LACO.md`. A fusão de Q3-B com
Q4-B já estava feita no 09c (`65dd87c`, `b9059fc`) e foi aproveitada, não refeita.

**Letra de ADR.** Rodei o comando que a `LETRAS-ADR.md` prescreve sobre TODAS as refs vivas.
`09r` já é da F6 (`Vitorepf/volta-f6-bloqueada`), e o "Próxima livre: 09s" do arquivo estava
certo — tomei a **09s** e registrei no mesmo ato. De quebra, o comando desmentiu a linha que
dava `09p` à MAC-0-E: `09p` **não aparece em ref nenhuma**, e fica marcada como buraco.

**A prova saiu do worktree.** Os dois relatórios de revisão citavam `../lote-ia-09c/prova/…`
e `../lote-ia-09/prova/…` — caminho que morre com o worktree. Agora citam o caminho dentro do
repositório, e os cinco alvos existem (conferidos com `test -f`). São 26 arquivos
`prova/lote09*` + as duas fixtures `prova/q3-*.json` / `prova/q4-*.json`.

## 2. As três linhas do Perfil — antes e depois

Compostas pelo caminho real da tela (`Politica.linha` → `PerfilView.reprovadas` →
`dataDe`/`restoDa`), e depois **conferidas na tela viva** (§4).

### ANTES — `origin/main` (90911ec)

```
Indisponível mesmo com a conta Grok — a medida de 08/09 reprovou, e não há outro caminho:
  instigar — devolveu o vocabulário interno do app
  contrapor — sustentou o contraponto em fato inventado
  a pergunta do Recordar — entregou a resposta dentro da pergunta
  ecos entre notas — deixou de fora os vínculos mais úteis
  ler o seu juízo — calou quando não havia erro a apontar
Em correção, com conserto nomeado e sem data — a medida reprovou:
  responder nas Notas — recusou por inteiro perguntas que as suas notas ajudavam a responder · 08/09 · conserto: usar o material disponível quando o fato atual falta, como produzir já faz, e manter os rótulos internos fora do texto
  responder à sua pergunta — inventou cenário que o contexto não sustentava · 09/09 · conserto: o prompt já mata a invenção de número; trocar de modelo não resolve (três medidos, nenhum passou) — falta o prompt impedir também a invenção da ESTRUTURA de um documento
```

### DEPOIS — MERGE-Q34

```
Indisponível mesmo com a conta Grok — a medida de 08/09 reprovou, e não há outro caminho:
  a pergunta do Recordar — entregou a resposta dentro da pergunta
  ecos entre notas — deixou de fora os vínculos mais úteis
  ler o seu juízo — calou quando não havia erro a apontar
Em correção, com conserto nomeado e sem data — a medida reprovou:
  responder nas Notas — faz a conta do gasto e para antes de dizer quanto sobra do seu orçamento · 10/09 · conserto: terminar a conta — dizer quanto sobra do teto em toda repetição — e resolver o conflito de listas também no modelo que o app usa; falta medir
  responder à sua pergunta — inventou cenário que o contexto não sustentava · 09/09 · conserto: o prompt já mata a invenção de número; trocar de modelo não resolve (três medidos, nenhum passou) — falta o prompt impedir também a invenção da ESTRUTURA de um documento
  instigar — no texto curto, ainda faz perguntas vagas e não pede quando aconteceu · 10/09 · conserto: no texto curto, a pergunta pede o quê, QUANDO aconteceu e o que seria dar certo; falta medir
  contrapor — inventa renda que você não escreveu e às vezes cala onde a nota dá matéria · 10/09 · conserto: não atribuir renda que você não escreveu, e nunca devolver vazio quando a resposta veio inteira; falta medir
```

**Nenhuma `regra` mudou.** As três seguem `indisponivelPorQualidade`, porque os dois re-G3 de
22h07 e 22h08 as reprovaram. O que mudou foi o MOTIVO, a DATA e o CONSERTO — e o conserto
agora diz **o que falta medir**, não o que já se mediu.

**A leitura que sustenta cada linha** (relatórios `ferramentas/orca/revisao-q3-notas.md` e
`revisao-q4-instigar.md`; saídas em `prova/lote09c-q3-grok-4.3.jsonl`,
`prova/lote09c-q3-grok-4.5.jsonl`, `prova/lote09c-q4-grok-4.3.jsonl`,
`prova/lote09c-q4-grok-4.5.jsonl`):

| operação | o LOTE-3 DERRUBOU | o LOTE-3 ACHOU VIVO |
|---|---|---|
| `responderNasNotas` | a meia-recusa da conversa: **6/6** calculam R$ 3.354 com a cotação que a pessoa deu (era 0/3); o `HOJE` chega em fuso local; nenhum rótulo interno nas 42 saídas | em `q3-gasto-cotacao-na-nota`, **6/6** calculam os R$ 3.354 e **nenhuma** diz os R$ 2.646 nem faz a subtração; o conflito com o limite da sala ainda reprova **2/3 no `grok-4.3`** (3/3 no `4.5`) |
| `instigar` | a proibição por NOME calava o método/degrau que o AUTOR escreveu — voltou **3/3 nos dois modelos**, inclusive com `metodo` sem acento; o degrau 4 parou de repetir as perguntas do degrau 0, **3/3 nos dois** | no texto curto, perguntas vagas que não pedem QUANDO — **3/3 no `4.3`**, **2/3 no `4.5`** |
| `contrapor` | a evidência fabricada não voltou nas 36 execuções | renda que a nota não declara — **1/3 no `4.3`**, **3/3 no `4.5`**; e contraponto que não chega: `Falha.semRetorno` com **HTTP 200 e conteúdo completo** no `4.5` rep. 2 do CSV e no `4.3` rep. 1 do tudo-ou-nada, mais `contra` vazio no `4.3` rep. 2 do CSV |

**Também mudaram as três frases de `semProvedor`** — o que o autor lê **no ponto em que
toca**, não no Perfil. Elas nomeavam o mesmo defeito de 08/09; deixá-las seria a tela contando
duas histórias sobre a mesma medida. Três linhas, mesma evidência, mesmo ato.

**Um corte que declaro.** O motivo do `contrapor` que os revisores escreveram tem 112
grafemas e o teto da linha da tela é 80 (`PoliticaTests`, guarda que já existia). Cortei
para 74 preservando as duas metades — a renda inventada e o silêncio onde a nota dá matéria
— e troquei "não entrega contraponto" por "cala", que é a palavra do autor. Os outros dois
couberam; tirei deles o "a medida", porque as linhas vizinhas da tabela já são
verbo-primeiro ("deixou de fora…", "inventou cenário…").

## 3. O portão que não guardava nada

O teste dos dois grupos contava `conserto == nil` / `!= nil` e **passava idêntico com o texto
velho** — é o defeito da V12-E: verde sem visitar o lugar onde o defeito mora. Agora ele lê a
linha pelo **caminho real da tela** e exige o trecho novo, a data nova e a ausência do
"08/09". E a guarda de data era chaveada na string `"08/09"`, logo teria deixado passar um
`"10/09"` dentro da oração: virou uma barra, que não tem o que fazer numa frase de tela — nem
como caminho de prova, nem como data. Duas asserções viraram uma, mais forte.

**A prova do vermelho**, como manda a ESTEIRA: plantei o motivo e a data de 08/09 de volta em
`responderNasNotas`, deixei o resto de pé, e o portão **falhou nas três asserções**:

```
✘ Test run with 7 tests in 1 suite failed after 0.083 seconds with 3 issues.
** TEST FAILED **
↳ .responderNasNotas: a tela não diz o que o LOTE-3 leu —  — recusou por inteiro perguntas
  que as suas notas ajudavam a responder · 08/09 · conserto: terminar a conta — …
↳ .responderNasNotas: motivo de 08/09 ainda na tela — …
↳ .responderNasNotas: a data não é a do LOTE-3
```

Violação removida em seguida; a mensagem de falha imprime **a linha que o autor veria**, que é
o que se quer ler quando ela quebrar.

## 4. Instrumento

**Suíte integral**, `34CC3F94`, sob `com-trava.sh`, `-parallel-testing-enabled NO`. Rodei
duas vezes: uma na árvore mesclada (01:25:37Z → 01:29:22Z) e a **final sobre o commit que vai
para `main`** (01:58:09Z → 02:00:04Z).

```
✔ Test run with 1019 tests in 163 suites passed after 89.089 seconds.
** TEST SUCCEEDED **

✔ Test run with 1019 tests in 163 suites passed after 108.625 seconds.
** TEST SUCCEEDED **
```

**Sobre `grep -c warning:`, sem arredondar para o meu lado.** A corrida final deu **0**, mas
ela é incremental e não recompilou tudo; a primeira, que compilou mais, deu **1** — e esse um
é de `main`, não meu: `Traco/Notas/NotasView.swift:806:30: warning: '+' was deprecated in
iOS 26.0`. O arquivo está em `origin/main`, **nenhuma das quatro pontas o toca**, e ele não é
da minha área. Fica declarado, não consertado, e o número honesto desta volta é **1 aviso
herdado, 0 introduzidos**. O `xcodebuild build` do candidato (01:45:57Z → 01:48:18Z) saiu com
`** BUILD SUCCEEDED **` e 0 avisos. Nenhum arquivo `.swift` novo, logo `xcodegen generate`
só foi rodado por higiene.

**Capturas** — o que se vê em cada uma:

| arquivo | o que mostra |
|---|---|
| `prova/merge-q34-perfil-antes.png` | Perfil com o binário de `main`: `instigar — devolveu o vocabulário interno do app` e `contrapor — sustentou o contraponto em fato inventado` no grupo **sem conserto**, sob o cabeçalho "a medida de 08/09" |
| `prova/merge-q34-perfil-tres-linhas.png` | Perfil com o candidato: o grupo sem conserto agora tem **três** linhas (Recordar, ecos, ler o seu juízo) e o grupo "Em correção" abre com `responder nas Notas — faz a conta do gasto e para antes de dizer quanto sobra do seu orçamento · 10/09 · conserto: …`, seguido de `responder à sua pergunta · 09/09` e de `instigar · 10/09` |
| `prova/merge-q34-perfil-instigar-contrapor.png` | o mesmo Perfil rolado: `instigar — no texto curto, ainda faz perguntas vagas e não pede quando aconteceu · 10/09` e `contrapor — inventa renda que você não escreveu e às vezes cala onde a nota dá matéria · 10/09`, com os dois consertos inteiros |
| `prova/merge-q34-perfil-xxxl.png` | as mesmas linhas em **Dynamic Type `accessibility-extra-extra-extra-large`**: o texto quebra e o cartão cresce, **sem clipe e sem truncamento** — o fim do conserto do `contrapor` ("…quando a resposta veio inteira; falta medir") aparece inteiro, e a lista continua alcançável por rolagem |

Tamanho de letra em `medium` nas três, conferido na própria captura (achei o aparelho em
XXXL, deixado por outra volta; restaurei para `medium`, que é o que o preâmbulo manda no fim).
Orientação e Movimento Reduzido não foram tocados.

**Dois limites do instrumento, com prova, e nenhum desconta nota:**

1. **O aparelho de trabalho é disputado, e o binário troca sozinho.** Às 22:42 e de novo às
   22:51 (hora do aparelho) o `Traco.debug.dylib` do contêiner virou um binário que **não
   tinha nenhum dos três textos novos** — sem que eu instalasse nada. É o achado de 08/09 da
   F4-F, de novo. Peguei-o por `strings` no dylib do contêiner, não por caça a cache. A
   defesa que funcionou foi **colar install, navegação e foto numa chamada só de
   `com-trava.sh`**: separadas, a janela entre elas basta para outra sessão instalar por cima.
2. **A rolagem do emulador amplifica ~11×.** Um arrasto de 0,25 de tela moveu o conteúdo 2,86
   — passou do alvo direto para o fim da página. Medi o ganho pela árvore de AX a cada passo e
   passei a calcular o arrasto a partir da posição lida: `(y − alvo)/11,4`. Enquadrou em dois
   passos.

## 5. Escopo — o que NÃO fiz, e de quem é

- **`Falha.semRetorno` com HTTP 200 e conteúdo completo** é defeito do NOSSO motor e tem volta
  própria (**Q4-C**). Não consertei; a linha do Perfil só deixou de mentir sobre ele.
- **Jargão de `conserto`/`porque` na tela do autor** — dívida já nomeada no RUMO.
- **Prompt, contexto, esquema ou teto** — Q3-C e Q4-C. Nada disso mudou aqui.
- **Achado novo, para o RUMO, sem dono ainda:** `EVOLUCAO.md` tem a linha *"Qualidade efetiva
  transversal da IA"* **duplicada** (linhas 18 e 20), já em `origin/main` — a 20 é a viva
  (traz a 09q), a 18 parou na 08w. Escrevi só na viva. Não é desta volta apagar a outra, mas
  alguém tem de apagar.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | G0 no topo; `EVOLUCAO.md` registra as três medições em lote e diz que a lacuna do executor **segue aberta** |
| Contrato | 9 | ADR 2026-09-09s em `SPEC.md`, letra lida por comando e reservada em `LETRAS-ADR.md` no mesmo ato; `EVOLUCAO` coerente com o código |
| Correção | 9 | `1019 tests … passed` + `** TEST SUCCEEDED **`; portão novo com a **prova do vermelho** colada |
| Jornada real | 9 | três capturas nomeadas, conteúdo conferido na tela; antes e depois |
| Design | n/a | nenhum token, componente ou layout tocado — só o texto que a tabela entrega |
| Simplicidade | 9 | nenhum passo, tela ou decisão a mais; duas asserções viraram uma |
| Movimento | n/a | nenhuma animação tocada |
| Componentes | n/a | nenhum componente novo |
| Acessibilidade | 9 | as três linhas lidas na **árvore de AX** e conferidas na captura no mesmo instante, em `content_size medium` **e** em `accessibility-extra-extra-extra-large` (`prova/merge-q34-perfil-xxxl.png`): quebram e crescem, sem clipe. VoiceOver falado **não** foi ligado — é limite declarado, por ordem do dono, e não desconta nota |
| Performance | n/a | nada de lista, editor ou parser |
| Privacidade e autoria | 9 | nenhuma rota, selo ou origem tocada; **nenhuma chamada de rede a modelo nenhum** nesta volta |
| Estado honesto | 9 | é o objeto da volta: a tela parou de acusar defeito derrubado, e o `conserto` passou a dizer o que falta MEDIR |
| Complexidade | 9 | o código líquido **encolheu** um pouco no teste; nenhum arquivo `.swift` novo, nenhuma dependência |
| Fora do app | n/a | nenhuma superfície fora do app |
| Relato | 9 | este documento |

**Nenhuma dimensão abaixo de 9.** A que quase ficou foi Acessibilidade: as três linhas
cresceram bastante, e eu ia entregá-la em 8 por não ter visto o texto grande. Fui ver — em
XXXL elas quebram e o cartão cresce, sem clipe —, porque estado que a ESTEIRA pede no G2 não
é acabamento a adiar. Tamanho de letra restaurado para `medium` ao fim, conferido por
captura.
