# Q4-F · CONTRAPOR — três alavancas medidas

**ADR:** 2026-09-10d (era `10c`; a `10c` é do `instigar` e está escrita no `main`).

**O veredito, na primeira linha:** a terceira alavanca — o **ESQUEMA DA SAÍDA** —
**PASSA** os dois casos cegos 3 de 3 no `grok-4.3`, que é o modelo desta rota, e
**sobe** o polo de controle junto (11 → 13 de 18). A guarda que eu escrevi por
cima dela **NÃO PASSA** e foi retirada: 5 disparos, 1 acerto, 4 erros. A rota
não volta, porque a superfície continua pendente no G4 (§14/§15). O LOTE-9 está
no fim deste arquivo; o que vem primeiro é o registro das duas tentativas do
PEDIDO, que continuam descartadas.

---

## As duas tentativas do PEDIDO (LOTE-7 e LOTE-8) — descartadas

**Aparelho:** `34CC3F94-FDB5-4575-A4F5-80271829A18B` (conta, naquelas janelas).
**Suíte:** `A1DF082C`. **Prova:** `prova/lote09g/`, `prova/lote09h/`, `prova/q4f/`.

## As cinco linhas do regime (a operação NÃO passou o caso cego em duas tentativas)

1. Para o recurso que a nota diz **não ter**, o modelo oferece um **substituto** —
   "ensaio com dado sintético", "cópia mascarada", "recorte representativo": ele lê
   a falta declarada como lacuna a preencher, não como condição.
2. O `grok-4.3` ainda **argumenta a favor dela com o motivo que ela pôs fora da
   conta** (preço, distância, horário) e não toca no que ela não examinou.
3. O `grok-4.3` também propõe, em `foraDaLista`, o que a nota fecha por outras
   palavras — "replicação paralela" quando as duas versões não rodam juntas.
4. O `grok-4.5` acerta o cego das razões fechadas 3 de 3 e erra o das alternativas
   negadas 1 de 3, sempre pela mesma porta do item 1.
5. **Nenhum dos dois passa os DOIS cegos em 3 de 3** — e a escolha por operação
   (09v) não salva: o melhor de cada um falha no cego do outro.

## O que a volta entrega, medido

- **A alavanca (uma):** no `sistemaContrapor`, *o que ela já descartou, recusou ou
  disse não ter é DADO; nada disso volta como proposta sua, nem no `foraDaLista`,
  nem como etapa antes; e quanto mais saídas ela fecha, mais o contraponto se
  aperta no que SOBRA.* Condicionada à matéria — sem promover lista, sem exigir
  número de campos, sem autocertificação.
- **O portão antes do prompt:** `Grok.Diagnostico.bruto` (DEBUG). Sem ele,
  "os três vazios são do modelo" era inferência. O conferidor acusa três vazios
  que chegam sem o bruto — e acusou, relendo o LOTE-6.
- **Os três vazios sobre HTTP 200 foram a ZERO** e lá ficaram em 96 execuções.
  Conferido: nenhuma guarda nossa apagou (`guardasQueApagaram` vazio), então a
  rota **herdou** o conserto da 09s; o defeito era do modelo, e a alavanca o
  derrubou.
- **A tela:** a linha perdeu "e às vezes não devolve nada" — 1 em 24 no LOTE-6,
  0 em 48 e 0 em 48 depois. Diz o que ele encontra: *"ela ainda oferece a saída
  que você já tinha descartado"*.

## A tabela

| | cego `alternativas-negadas` | cego `razoes-fechadas` | três vazios | campos vazios |
|---|---|---|---|---|
| LOTE-6 `4.3` | 2/3 | ~1/3 | **1** | 12/72 |
| LOTE-6 `4.5` | **0/3** | 3/3 | 0 | 0/72 |
| LOTE-7 t1 `4.3` | 2/3 | 0–1/3 | **0** | 14/72 |
| LOTE-7 t1 `4.5` | 1/3 | 3/3 | 0 | 0/72 |
| LOTE-8 t2 `4.3` | 1/3 | 1/3 | **0** | **10/72** |
| LOTE-8 t2 `4.5` | **2/3** | **3/3** | 0 | 0/72 |

Ler por **intervalo, não por seta**: são 3 repetições por célula, e o LOTE-5 já
devolveu número diferente na remedida com o mesmo prompt e o mesmo parser.

## Instrumento — o que foi conferido, com a hora

- Fixture **byte a byte** a do LOTE-6: SHA `da012e21bcde220c5f745f9bd7e5d7bcf7b2f845095bbe7ef889c844f2afb029`.
- **LOTE-7** 15:54:27Z–16:05:29Z · **LOTE-8** 16:14Z–16:26Z · captura 16:50–16:52:20Z.
- `ContaGrok.ligada` **true** nas quatro fumaças de cada janela e às **16:45:01Z**
  depois da instalação da captura.
- `cmp` do `Traco.debug.dylib` contra o produto de build: **igual**, no install e
  no fim de cada janela. (O `Traco` de 59 k é só o lançador; o prompt vive no dylib.)
- **Três instalações na volta**, uma por janela de medida mais a da captura —
  declarada, porque fotografar frase que o código já não tem seria mentira na prova.
- Nenhum `xcodebuild test` no aparelho de conta. Suíte só no `A1DF082C`.
- Letra em **`large`** antes e depois; tema `light`; contraste `disabled`.

## Suíte

`✔ Test run with 1039 tests in 164 suites passed after 146.933 seconds.`
Árvore própria, os dois testes exclusivos deste candidato:
`✔ Test oContratoDeContraporFechaASaidaQueElaMesmaDescartou() passed after 0.001 seconds.`
`✔ Test tresVaziosDoModeloNaoSaoTresVaziosDaGuarda() passed after 0.001 seconds.`
Build **incremental** (não limpo) — a contagem de warning desta volta não vale;
o warning herdado de `NotasView.swift:814` continua lá.

## A vigia prova que enxerga

`lote-ia-09g-contrapor.py` foi rodado **primeiro no LOTE-6**, onde os defeitos são
conhecidos: acusou o ensaio do `4.5` 3 de 3, os três vazios do `4.3` e a ausência
do retorno bruto. E na primeira redação ele **sobre-acusava** — contava "sem teste
com dados reais" no `contra` como se fosse a proposta do ensaio, quando o revisor
lera o oposto. Restringi a coluna ao `foraDaLista`, que é o campo que PROPÕE por
contrato, com guarda de negação; o resto vai para o revisor **sem veredito**.
Ele ainda **sub-acusa** (não pega "convênio", "caminhadas", "replicação
paralela") — por isso a leitura de mérito acima é minha, lida saída a saída, e a
nota final é do revisor.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão de `QUALIDADE-IA.md` | nota | prova |
|---|---:|---|
| fidelidade ao que o autor escreveu | 7 | 0 fatos fabricados em 96 execuções; mas o substituto do item 1 introduz recurso que a nota nega |
| utilidade do que volta | 8 | `4.5` morde o não-examinado 3/3 no cego das razões fechadas; `4.3` argumenta pelo que ela excluiu |
| honestidade do silêncio | 9 | três vazios 1 → 0 → 0; `nil` ≠ vazio herdado e conferido; retorno bruto agora preservado |
| estado na tela | 9 | linha na língua do autor, sem data e sem jargão, fotografada em `large` às 16:52:20Z |
| medida que se pode repetir | 8 | mesma fixture byte a byte, uma janela e um install por tentativa, `cmp` dos dois lados; mas 3 repetições por célula é amostra fina |

**Nota que eu não me dou:** a final. O G3 lê a saída inteira e os dois cegos.

---

# LOTE-9 (ADR 2026-09-10d) — a terceira alavanca: o ESQUEMA DA SAÍDA

## **PASSA — a FORMA. NÃO PASSA — a guarda que eu pus por cima dela.**

O `grok-4.3`, que é o modelo desta rota (`Grok.modelo`, padrão global), com o
esquema e **sem** o join, passa **os DOIS casos cegos, 3 de 3** — o primeiro
braço a conseguir isso em quatro lotes. Com o join que eu escrevi, cai para
3/3 e 2/3. **Quem reprovava a operação éramos nós.**

A rota **não volta**: a superfície continua pendente no G4 (§14/§15), e
`Politica.linha(.contrapor)` segue `indisponivelPorQualidade`. O que esta volta
entrega é o mérito medido e a alavanca escrita.

**Aparelho:** `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9` (conta, teste 2). **Suíte:** `A1DF082C`.
**Prova:** `prova/lote09i/`. **Janela:** 19:45:17Z–20:11:02Z, **uma** instalação.

## As cinco linhas

1. **A alavanca é a ORDEM, e ela é propriedade do gerador, não súplica.** O
   esquema obriga `fechadas` a sair ANTES de qualquer proposta existir, e o
   modelo escreve da esquerda para a direita: quando a proposta nasce, a lista
   do que a nota fecha já está escrita e não há como voltar. O `corpoContrapor`
   é **byte a byte** o mesmo nos dois braços; a suíte guarda isso.
2. **No modelo da rota, funcionou nos dois polos ao mesmo tempo** — que é
   exatamente o que a volta do `instigar` não conseguiu hoje. Cego das
   alternativas negadas: **1/3 → 3/3**. Cego das razões fechadas: 3/3 → 3/3.
   Polo de controle: **11 → 13 de 18**, conta absoluta **55 → 63 de 72**. A taxa
   e a conta subiram juntas; nada foi comprado encolhendo o que volta.
3. **O join que eu pus por cima reprovou, e o mecanismo é a lei do despacho a
   falhar onde ela avisou.** 5 disparos nos dois braços do esquema: **1 acerto,
   4 erros**, e os quatro são a mesma espécie — a proposta usava **de outro
   jeito um recurso que ela JÁ TEM**. O modelo declara o FATO (`dependeDe`), o
   nosso código toma a DECISÃO (casar contra `fechadas`), e **a decisão não tem
   como distinguir "ela não tem X" de "ela tem X e a proposta usa X de outro
   jeito"**. "Pausar a matrícula" depende da matrícula que ela tem. O join lê a
   palavra e não lê a RELAÇÃO — e ler a relação é juízo, que só o modelo faria,
   o que devolveria a autocertificação que o desenho existia para evitar.
4. **Há uma segunda porta, e ela não é do join.** No `grok-4.5`, o substituto
   passou inteiro porque **o próprio modelo deixou "ambiente de teste com os
   dados reais" FORA da lista que ele mesmo escreveu**. Separar o FATO da
   DECISÃO não impede o modelo de **encolher o fato**: não mentindo sobre o
   juízo, mas omitindo o dado sobre o qual o juízo seria feito. O esquema não
   fecha essa porta, e eu não afirmo que a fecha.
5. **O `grok-4.5` piora com o esquema, nos dois cegos** (2/3 → 1/3 e 3/3 → 2/3,
   contando a saída do modelo). Não é o modelo desta rota, e a escolha por
   operação (09v) não muda nada aqui — mas está medido, e quem trocar o padrão
   global precisa saber.

## A tabela — os DOIS polos, na mesma janela e no MESMO binário

Cada célula: 3 repetições. **A conta é absoluta**, porque uma taxa que sobe
porque o modelo propõe MENOS é o retrato errado. Os cegos são leitura de mérito
minha, saída a saída; as colunas de controle e de conta são do `lote-ia-09g-contrapor.py`.

| braço · modelo | cego `alternativas-negadas` | cego `razoes-fechadas` | **CONTROLE**: `foraDaLista` na nota que não fecha nada | média de caracteres | campos com texto | join: disparos (acertos) |
|---|---|---|---|---|---|---|
| antigo `4.3` | 1/3 | 3/3 | 11 de 18 | 43 | 55/72 | — |
| esquema `4.3` **com** o join | **3/3** | 2/3 | 12 de 18 | 33 | 61/72 | 2 (**0**) |
| **esquema `4.3` SEM o join** | **3/3** | **3/3** | **13 de 18** | 38 | **63/72** | — |
| antigo `4.5` | 2/3 | 3/3 | 18 de 18 | 139 | 70/72 | — |
| esquema `4.5` **com** o join | 1/3 | 1/3 | 17 de 18 | 73 | 69/72 | 3 (**1**) |
| esquema `4.5` SEM o join | 1/3 | 2/3 | 18 de 18 | 78 | 72/72 | — |

**A recontagem sem o join não custou uma segunda instalação**: o `bruto` guarda
o que o modelo escreveu ANTES da guarda, então "o mesmo binário sem o join" se
conta desta mesma prova. Está no `lote-ia-09g-contrapor.py`, coluna **G**, para
qualquer um repetir.

Ler por **intervalo, não por seta**. A prova está na própria tabela: o braço
ANTIGO do `4.3` deu 11 de 18 no controle aqui e **16 de 18 no LOTE-8**, com o
MESMO prompt, a MESMA fixture e o MESMO parser. Por isso a linha de base foi
**remedida nesta janela** em vez de copiada de ontem.

## Os quatro erros do join, colados

| caso | `fechadas` (o modelo) | `dependeDe` (o modelo) | o que o join APAGOU | veredito |
|---|---|---|---|---|
| `4.5` alt-negadas r2 | …, "ambiente de teste com os dados reais" | "espelho ou cópia isolada dos dados reais" | "…depois de um **ensaio de tempo numa cópia isolada**…" | **ACERTO** |
| `4.5` razões-fechadas r1 | "não quero trocar por outra academia", … | "a academia permitir **pausa** da matrícula" | "pausar ou congelar a matrícula por um período" | ERRO |
| `4.3` razões-fechadas r3 | "trocar por outra academia", … | "A **academia** oferecer pausa temporária" | "Pausar temporariamente a assinatura" | ERRO |
| `4.3` premissa-do-futuro r1 | "escrever **código** à mão" | "ferramentas automatizadas de geração de **código**" | "aprender programação para supervisionar e integrar soluções geradas" | ERRO |
| `4.5` premissa-do-futuro r1 | "escrever **código** à mão" | "sistemas que geram **código** e exigem validação humana" | "aprender a especificar problemas e auditar código gerado" | ERRO |

Em negrito, a palavra que casou. Nos quatro erros ela nomeia algo que a autora
**tem**; no acerto, algo que ela **não tem**. Nenhum limiar separa os dois —
é a mesma palavra, e o que muda é a relação.

## A dívida, nomeada

`Sabia.dependeDoQueElaFechou` fica no código **sem chamador**, e há um teste ao
lado que prova, com os dois casos medidos, por que ela erra. Apagar a função
apagaria a prova, e a volta seguinte recomeçaria pela mesma ideia.

**O desenho que falta:** um campo que diga se o recurso vem **DE FORA** do que
ela já tem — e que seja FATO, não juízo, ou volta ao mesmo lugar.

## Instrumento — o que foi conferido, com a hora

- **Os dois braços no MESMO dylib**, o antigo escolhido por ambiente
  (`TRACO_AVALIAR_CONTRAPOR_ANTIGO=1`). As voltas anteriores compararam
  binários diferentes em janelas diferentes; esta não tem essa dúvida.
- **`bracoContrapor` e `pedidoContraporSHA256` em TODA linha** do JSONL — não só
  na do caso, porque cabeçalho se perde quando alguém corta o arquivo.
  `antigo-sem-esquema` = `e4b665fb…` (2.620 bytes); `esquema-da-saida` =
  `00fb4deb…` (2.973 bytes). Delta: 353 bytes, todos na declaração da FORMA.
- **`ContaGrok.ligada` `true` nas QUATRO fumaças**: 19:45:20Z (antes de tudo),
  19:45:28Z (depois do install), 19:56:04Z (meio), 20:11:02Z (fim). Não caiu.
- Fixture **byte a byte** a do LOTE-6: SHA `da012e21bcde220c5f745f9bd7e5d7bcf7b2f845095bbe7ef889c844f2afb029`.
- **UMA instalação**, por cima, sem `uninstall`/`erase`/`clearState`.
  Não pedi a segunda: a recontagem saiu da prova que eu já tinha.
- **`cmp` do `Traco.debug.dylib`** contra o produto de build: igual às 19:45:25Z e às 20:11:02Z.
- **Zero só vale se havia o que ver:** `bruto` presente nas 96 linhas, coluna C
  = 0 nos quatro braços. Nenhum `NÃO VERIFICÁVEL`.
- Nenhum `xcodebuild test` no aparelho de conta. Letra em **`large`** do início
  ao fim (`UICTContentSizeCategoryL`, conferido pelo `simctl`).

## O TEXTO que o autor lê — corrigido, porque estava velho

O `motivo` dizia *"oferece a saída que você já tinha descartado"*, e esse
defeito o LOTE-8 já tinha derrubado. Deixá-lo ali mente para o autor tanto
quanto prometer volta que não houve. Agora a tela diz o defeito de HOJE — o que
sobrou depois desta volta, que é a segunda porta da linha 4:

> Contrapor pela IA está indisponível: ela ainda **oferece um substituto para o
> que você disse que não tem**. O Steelman e a Inversão continuam no catálogo,
> escritos por você.
> *falta ela aceitar essa falta como ela é, em vez de arranjar um jeito de contornar*

Sem data, sem "medida", sem jargão nosso.

## O que ficou de fora, e por quê

- **A superfície.** Ordem do dono (§14/§15): nenhuma operação volta ao Perfil
  sem a tela nova aprovada no G4. Nenhuma captura de cartão nesta volta — seria
  fotografar a tela que ele acabou de reprovar.
- **O `grok-4.5` como padrão.** Medido e pior aqui; não é decisão desta volta.
- **A segunda porta (o modelo encolhendo `fechadas`).** Nomeada na linha 4,
  não consertada. É a alavanca da volta seguinte, e ela não é o pedido.
## A alavanca desta volta: o ESQUEMA DA SAÍDA (não o pedido)

O `contrapor` já gastou as duas tentativas do PEDIDO (LOTE-7 e LOTE-8), e a
segunda está medida e descartada acima. Esta volta não escreve uma terceira
redação: o `corpoContrapor` — o contrato inteiro, da proibição de fabricar até
"o que ela pôs fora da conta fica fora" — é **byte a byte o mesmo nos dois
braços**, e a suíte guarda isso (`osDoisBracosDoContraporPedemAMesmaCoisa…`).
O que muda é a FORMA que a resposta tem de ter, e essa **a API aplica**:

```
{"fechadas": ["…"], "contra": "…", "foraDaLista": "…", "dependeDe": "…", "outroCampo": "…"}
```

**Duas chaves a mais, e as duas são FATO — nenhuma é juízo.** `fechadas` é o que
a nota diz não ter, já ter descartado ou posto fora da conta. `dependeDe` é o
recurso de que a `foraDaLista` já escrita precisa para existir. Quem **DECIDE**
se a proposta morre é `Sabia.dependeDoQueElaFechou`, no nosso código. Em nenhum
ponto o modelo diz "isto é permitido" — se dissesse, **autocertificaria**, que é
o que a volta anterior evitou de propósito.

**A ordem é a alavanca, e ela é uma propriedade do gerador, não uma súplica.**
`fechadas` sai PRIMEIRO no esquema, e o modelo escreve da esquerda para a
direita: quando a proposta nasce, a lista do que a nota fecha já está escrita e
não há como voltar. Por isso o esquema vai à mão no Swift, e não por
`JSONSerialization`: dicionário não tem ordem, e `.sortedKeys` daria
`contra, dependeDe, fechadas, …`, perdendo a alavanca sem erro nenhum.

**E a decisão não é o atalho cego.** Casar o TEXTO DA NOTA — "a nota contém 'não
tenho'" — erraria exatamente onde importa: `revisor-contrapor-alternativas-negadas`
fecha o faseamento com *"as duas versões não rodam juntas"*, e o item 3 deste
relatório já dizia que o `4.3` propõe o que *"a nota fecha por outras palavras"*.
A guarda casa `dependeDe` contra `fechadas` — duas falas do MODELO, no mesmo
fôlego e no mesmo vocabulário —, nunca contra a nota. **E na nota que não fecha
nada, `fechadas` é `[]` e a guarda devolve `false` sem olhar**: o polo de
controle está protegido por construção, o que não me dispensa de medi-lo.

## Suíte

`✔ Test run with 1058 tests in 165 suites passed after 152.659 seconds.`

Os três testes desta volta, na árvore própria:

- `osDoisBracosDoContraporPedemAMesmaCoisaEDiferemSoNaForma` — prova que o CORPO
  das instruções é byte a byte igual nos dois braços (não é uma terceira
  redação do pedido), e que a ORDEM das chaves do esquema é a da geração.
- `oEsquemaEhLidoEOJoinNaoDecideMais` — guarda a decisão MEDIDA: as duas chaves
  novas são lidas e nenhuma apaga nada; o caso que o join matava chega ao autor.
- `oJoinPorPalavraNaoSeparaOQueElaNaoTemDoQueElaUsaDeOutroJeito` — a prova da
  dívida, com o acerto e o erro medidos lado a lado. É a irmã que acusa ao lado
  da que não acusa: se o segundo deixar de acusar, o desenho mudou e a dívida
  pode ser revista.
