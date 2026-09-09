# Q2-F — a comparação pareada, e o que ela decidiu: nada muda

Volta `Vitorepf/volta-q2-responder`, sobre o `main` com a reversão dentro
(`0d357e7`). ADR **2026-09-09q**. Aparelho da conta:
`B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`. **Nenhum aparelho de trabalho foi ligado
para a medida**; o `34CC3F94` só entrou para a suíte, no fim, e saiu na mesma
corrida.

**O veredito, em uma linha: a troca NÃO se sustenta.** `responder` **fica** em
`indisponivelPorQualidade` e `Grok.modelo` **fica** `grok-4.3`. **Não há captura
de cartão** nesta volta, porque não houve resposta nova a mostrar — o fecho de
tela é para quando o mérito passa, e ele não passou. **A linha do Perfil mudou e
está na §4.1**, com o texto exato que o autor lê.

**As horas.** Fumaça de abertura **15h54 (BRT)** de 09/09/2026, conta ligada e 12
modelos autenticados. Última corrida encerrada **16h55**. Fumaça de fecho
**16h57**, conta ligada e os mesmos 12 modelos. **Zero instalações.**

## 1. Os dois P1 do G3, e o que cada um virou aqui

| P1 | o que caiu | o que esta volta fez |
|---|---|---|
| a comparação mudou DUAS alavancas | `TRACO_AVALIAR_SEM_ESFORCO=1` só no lado 4.20: corpo HTTP diferente | **uma alavanca**: `TRACO_AVALIAR_MODELO` é a ÚNICA variável entre os braços; `reasoning_effort: medium` vai em **todos**, e a prova disso está na §2 |
| a triagem excluiu por NOME e POSIÇÃO | `4.5` "abaixo do 4.6", `non-reasoning` pelo nome, `build-0.1` pela versão | **os doze foram à API**, com a mesma requisição, e cada corte é uma **frase que o provedor escreveu** |

## 2. A triagem: os doze, um por um, pelo que a API respondeu

Uma corrida por modelo, **a mesma fixture** (a listagem autenticada + o caso
`q2-gasolina-sem-dado`), **o mesmo binário**, **o mesmo aparelho**, `temperatura
0.3`, `reasoning_effort: medium`. Só `TRACO_AVALIAR_MODELO` mudou.
`prova/q2f-triagem-doze-modelos.jsonl`, 15h54–15h56.

| modelo | HTTP | o que a API respondeu | veredito |
|---|---:|---|---|
| `grok-imagine-image` | 400 | `Model not found: grok-imagine-image` | fora |
| `grok-imagine-image-2.0` | 400 | `Model not found: grok-imagine-image-2.0` | fora |
| `grok-imagine-image-quality` | 400 | `Model not found: grok-imagine-image-quality` | fora |
| `grok-imagine-video` | 400 | `Model not found: grok-imagine-video` | fora |
| `grok-imagine-video-1.5` | 400 | `Model not found: grok-imagine-video-1.5` | fora |
| `grok-build-0.1` | 400 | `Model grok-build-0.1 does not support parameter reasoningEffort.` | fora |
| `grok-4.20-0309-non-reasoning` | 400 | `Model grok-4.20-0309-non-reasoning does not support parameter reasoningEffort.` | fora |
| `grok-4.20-0309-reasoning` | 400 | `Model grok-4.20-0309-reasoning does not support parameter reasoningEffort.` | fora |
| `grok-4.20-multi-agent-0309` | 400 | sem corpo de erro | fora |
| **`grok-4.3`** | **200** | respondeu, 789 fichas de raciocínio, 8,4 s | **candidato** |
| **`grok-4.5`** | **200** | respondeu, 536 fichas de raciocínio, 15,1 s | **candidato** |
| **`grok-4.6`** | **200** | respondeu, 2.065 fichas de raciocínio, 43,7 s | **candidato** |

**A régua, dita antes de aplicar:** entra na disputa do padrão global quem
**serve a requisição que o Traço manda em produção** — `model`, `temperature`,
`messages` e `reasoning_effort`. Não é opinião sobre capacidade; é o contrato que
o app cumpre em toda chamada.

**Nada saiu por nome, posição ou versão, e nada saiu por hipótese.** As cinco
`imagine` não são "modalidade errada" por dedução: elas **não existem** em
`chat/completions`, e o provedor diz `Model not found`. O `grok-build-0.1` não
saiu pelo `0.1`: ele **recusa o campo**, com a mesma frase da família 4.20 — o
que derruba a suposição da 09n de que a recusa fosse um traço da linha `4.20`.

**Os três 400 do `reasoningEffort` provam o que o G3 disse faltar.** O revisor
apontou que `esforco: medium` no JSONL é o argumento Swift, não prova do corpo
HTTP. O provedor recusar **o parâmetro pelo nome** só é possível se o campo
**foi enviado**. É a comprovação em banda de que os três braços da §3 mandaram
`reasoning_effort` — e o mesmo valor.

**Uma triagem honesta deixou TRÊS candidatos, não dois** — e os três correram.
O `grok-4.5`, que a 09n cortou por posição, é o que aparece melhor por uma das
duas leituras da §3.

## 3. A medida: uma alavanca, 18 casos, 3 corridas, 54 execuções por modelo

**O que ficou fixo em todos os nove lançamentos:** a fixture
(`prova/q2f-casos.json`, sha256 `135d6a71…`, os 12 casos da 08z **mais os 6 casos
cegos do revisor**, sem reescrita); o binário (o mesmo `Traco.debug.dylib` já
instalado, sha256 `6ddf3a8d…`, **nenhum install nesta volta**); o aparelho
(`B91C8DEF`); a temperatura (`0.3`, fixa em `Sabia.responder`); o esforço
(`medium`, fixo em `Sabia.responder:392`); o teto (`Grok.teto = 240 s`); o prompt
(`sistemaResponder`, os mesmos 2.235 caracteres do `HEAD` — conferido byte a byte
dentro do dylib instalado, §5).

**O que variou:** `TRACO_AVALIAR_MODELO`. Só isso.

| modelo | execuções | HTTP 200 | conta ligada | cortadas no teto de 900 | espera mín–máx | média |
|---|---:|---:|---:|---:|---:|---:|
| `grok-4.3` | 54 | 54 | em 54 de 54 | 0 | 3,9–21,0 s | **9,4 s** |
| `grok-4.5` | 54 | 54 | em 54 de 54 | **4** | 4,7–29,9 s | **13,1 s** |
| `grok-4.6` | 54 | 54 | em 54 de 54 | 0 | 13,6–73,4 s | **39,9 s** |

`prova/q2f-modelo-43.jsonl`, `-45.jsonl`, `-46.jsonl`. Li as 162 saídas inteiras.

### 3.1 Os descumprimentos, com a frase que decide cada um

| caso | `grok-4.3` | `grok-4.5` | `grok-4.6` |
|---|---|---|---|
| `q2-prazo-conflito-sem-resolucao` | **falha 3/3** | passa 3/3 | **falha 1/3** |
| `q2-espanhol-geral` | passa 3/3 | passa 3/3 | **falha 1/3** |
| `q2-relatorio-tres-restricoes` | **falha 2/3** | **falha 3/3** | passa 3/3 |
| `revisor-responsavel-nao-definido` | **falha 3/3** | passa 3/3 | passa 3/3 |
| os outros 14 | passam 3/3 | passam 3/3 | passam 3/3 |

**`grok-4.3`, `q2-prazo-conflito-sem-resolucao`** — o requisito manda expor o
conflito **e dizer o que o resolveria, sem inventar destinatário**. Corrida 1
para na exposição: *"O prazo combinado não está definido em uma única data."* —
sem critério. Corridas 2 e 3 dão o critério **inventando o terceiro**:
*"Consulte as mensagens, e-mails ou registro de conversa com o destinatário"*;
*"Consulte o e-mail, mensagem ou registro da conversa em que a data foi
acordada."* O contexto não tem destinatário, canal nem conversa.

**`grok-4.3`, `revisor-responsavel-nao-definido`** (caso CEGO) — o requisito pede
"uma forma concreta de resolver o ponto sem recusar integralmente". Corrida 1:
para em *"Marina só disse que poderia revisar os slides em 08/09."* Corrida 2:
*"Sem essa anotação, a definição não consta no que você tem."* — nenhuma
continuação. Corrida 3 dá uma, **inventando o que o caso nega**: *"consulte o
registro da reunião ou a pessoa que definiu a apresentação"* — não há reunião
anotada, e "a pessoa que definiu" é exatamente o que não existe.

**`grok-4.3`, `q2-relatorio-tres-restricoes`** — o requisito proíbe por escrito
afirmar que o relatório é PDF e onde estão sumário e conclusões. Corrida 1:
*"Abra o PDF no celular… Leia primeiro o sumário executivo ou introdução… pule
para as últimas 5 páginas"*. Corrida 3: *"abra o PDF, role até o sumário… role as
últimas 10 páginas primeiro — relatórios costumam concentrar decisões ali"* — e
essa última é ainda a **regra genérica dita como certeza**.

**`grok-4.5`, `q2-relatorio-tres-restricoes`** — o mesmo requisito, **nas três
corridas**. Corrida 1: *"Abra o PDF e vá direto a sumário/índice… Leia só sumário
executivo + bloco de recomendações/conclusões"*. Corrida 2: *"confira só a
evidência mínima citada no resumo (tabela, gráfico ou trecho)"* — o requisito
proíbe **nominalmente** afirmar tabelas. Corrida 3: *"Use a busca do PDF/app"*.

**`grok-4.6`, corrida 1, `q2-prazo-conflito-sem-resolucao`** — expõe o conflito e
**não diz o que o resolveria**: *"O prazo combinado não está determinado nessas
anotações."* e nada mais. Nas corridas 2 e 3 ele diz (*"Falta a indicação de qual
das duas é a data da combinação, ou qualquer marca/texto na lista que esclareça
alteração ou confirmação"*).

**`grok-4.6`, corrida 1, `q2-espanhol-geral`** — abre com *"Falta o material
concreto (áudio, texto ou lista)."* e fecha com *"O trecho vem da fonte de
espanhol para iniciantes que você tiver hoje"*: **limita por dado pessoal ausente
um pedido de conhecimento geral**, que o requisito manda atender, e não nomeia os
minutos. Nas corridas 2 e 3 entrega `Bloco 1 (5 min)` / `2 (5 min)` / `3 (5 min)`
e condiciona em vez de limitar.

### 3.2 As duas leituras do placar — e elas discordam

| leitura | `grok-4.3` | `grok-4.5` | `grok-4.6` |
|---|---:|---:|---:|
| **por caso** (uma execução reprova o caso) | 15 de 18 | **17 de 18** | 16 de 18 |
| **por execução** (54 cada) | 46 de 54 | 51 de 54 | **52 de 54** |
| **os 6 casos cegos do revisor** | **reprova** (1 caso, 3/3) | passa | passa |

**Este é o resultado, e ele é o motivo de nada mudar.** As duas réguas honestas
**não elegem o mesmo vencedor** entre `4.5` e `4.6`: por caso ganha o `4.5`, por
execução ganha o `4.6`, e a distância entre eles é de **um único descumprimento**
em 54. Coroar um "melhor Grok global" com essa margem seria repetir, com método
melhor, o erro que o G3 apontou: decidir mais do que a medida decide.

**E nenhum dos três chega a 18 de 18.** A régua do portão é "um descumprimento
reprova"; ela não tem vencedor aqui, tem três reprovados.

### 3.3 O que a comparação pareada mostrou e a de duas alavancas escondia

1. **O `grok-4.6` não é 12 de 12.** A 09n mediu **uma corrida** e leu 12/12. Com
   três, ele perde dois casos — e os dois **na mesma corrida**. Uma corrida por
   modelo não distingue o modelo do sorteio.
2. **O `grok-4.5`, cortado por posição, é o melhor por uma das leituras.** O
   corte "abaixo do 4.6 na mesma linha" custava exatamente isto.
3. **O `grok-4.3` — o padrão que está em produção agora — reprova um caso cego,
   3 de 3.** Não é uma nota da Q2-F: é a razão de `responder` continuar cortada.
4. **O custo da espera é 4,2×, não 1,5×.** `4.6` a 39,9 s de média contra 9,4 s
   do `4.3` e 13,1 s do `4.5`, com **73,4 s** de pior caso.
5. **Achado de produto, do `grok-4.5`: 4 respostas em 54 estouraram o teto de 900
   caracteres** e chegariam ao autor **cortadas no meio da frase** com "…"
   (`Sabia.limparResposta`, `Sabia.swift:789`). Nos outros dois modelos, zero.
   Não é hipótese: as quatro estão no JSONL terminando em "…".

## 4. O que NÃO mudou, e por quê

**Nenhum comportamento mudou.** O diff de produção são **duas strings** da
`Politica` — o `porque`, que sustenta a regra, e o `conserto`, que a tela mostra
—, porque as duas afirmavam ao autor uma pendência que esta volta resolveu:

- `Grok.modelo` continua `grok-4.3`. A comparação pareada **existe agora** e não
  elegeu substituto.
- `responder` continua `indisponivelPorQualidade`, com `medidaEm 09/09/2026`. O
  `porque` ganhou o resultado novo.
- O piso `esforcoMinimo = "low"`, o teto único `Grok.teto`, o `erroDaAPI` e o
  contrato de sustentação **ficam**, como o G3 já havia separado. O `erroDaAPI`
  pagou-se de novo: **a triagem inteira desta volta é ele falando**.
- `responderEsperaAComparacaoPareadaAntesDeVoltar` (`PoliticaTests.swift`) segue
  verde, com o comentário atualizado e **três asserções novas**: quem quiser
  tirar `responder` da lista agora precisa bater um placar que **três modelos não
  bateram**.

### 4.1 A linha do Perfil, que é o que o autor lê

O `porque` (evidência, vai para a ADR) e o `conserto` (o que a TELA mostra) da
linha `responder` na `Politica` diziam *"falta a comparação pareada que escolhe o
modelo"*. **A comparação existe agora**, e deixar essa frase na tela do autor
seria afirmar como pendente o que já foi feito. O conserto nomeado passa a ser o
que a medida realmente achou:

> **responder à sua pergunta — inventou cenário que o contexto não sustentava ·
> 09/09 · conserto: o prompt já mata a invenção de número; trocar de modelo não
> resolve (três medidos, nenhum passou) — falta o prompt impedir também a
> invenção da ESTRUTURA de um documento**

**Essa linha é montada no teste pelo caminho da própria tela** —
`PerfilView.reprovadas` lê a tabela, `dataDe` decide que a data desce à linha (o
grupo "em correção" tem duas datas), `linhaDa` escreve —, e o teste afirma o
prefixo inteiro e o trecho "três medidos, nenhum passou". **Não é captura**:
fotografá-la exigiria instalar por cima no aparelho da conta, e esta volta
escolheu não instalar. Isso está declarado como limite: a linha é **executada**,
não **vista**.

**Nenhuma abstração, nenhum arquivo novo de código, nenhuma configuração
nova.** O experimento coube nas alavancas que a 09n já havia deixado
(`TRACO_AVALIAR_MODELO`, `TRACO_AVALIAR_LIBERAR`, `erroDaAPI`) — e a
`TRACO_AVALIAR_SEM_ESFORCO`, que a 09n criou, **não foi usada uma vez sequer**:
usá-la é justamente o que quebrou o pareamento.

## 5. Instrumento: zero instalações, e como isso foi possível

**A lei nova do dia é "não perder a conta", não "contar instalações".** A volta
anterior instalou cinco vezes. Esta instalou **zero** — e a medida é mais forte,
não mais fraca, porque **os nove lançamentos comparados são o mesmo byte**.

O binário já no aparelho (`Traco.debug.dylib`, sha256
`6ddf3a8dcee2199e70ba04752728f9078a4a3bc9ab47807ec5934abbf6bbce72`, instalado
às 13h55 pela Q2-E) serve à Q2-F **por fato conferido, não por confiança**:

- o `sistemaResponder` do `HEAD` — os 2.235 caracteres exatos, extraídos do fonte
  e procurados como sequência de bytes dentro do dylib — **está lá, uma vez**;
- `TRACO_AVALIAR_MODELO`, `TRACO_AVALIAR_LIBERAR`, `TRACO_AVALIAR_IA` e
  `erroDaAPI` estão presentes;
- `Sabia.responder` fixa `esforco: "medium"`, e o `Diagnostico` de cada uma das
  162 execuções registrou `medium`;
- a diferença entre esse binário e o `HEAD` — o **padrão** de `Grok.modelo` e a
  linha de `Politica` — **não alcança a medida**: os três braços declaram o
  modelo por ambiente, e `responder` chega ao provedor pelos dois caminhos
  (`soGrok` com conta, ou `indisponivelPorQualidade` + `TRACO_AVALIAR_LIBERAR`).

**A conta, antes e depois, pela chamada autenticada:**

| quando | hora (BRT) | `contaGrokLigada` | modelos autenticados |
|---|---|---|---|
| abertura | 09/09 **15:54:14** | `true` | 12 |
| fecho | 09/09 **16:57:08** | `true` | 12 |

E `contaGrokLigada: true` em **todos** os 162 registros de caso. `prova/q2f-fumaca-fecho.jsonl`.

**Limites do instrumento, declarados:**
- **A primeira fumaça de fecho (16:56:52) voltou `Falha.semRetorno` em 21 s com
  `contaGrokLigada: true` e `chamadasGrok: []`.** Não foi queda de conta: foi a
  listagem que não voltou — a corrida seguinte, 16 s depois, trouxe os 12 modelos.
  Está no JSONL do fecho, as duas, na ordem.
- **A leitura dos 18 casos é minha, e 6 deles são do revisor** — cegos para quem
  implementou a 08z e a 09n, **não** para quem escreve este relatório: eu os li
  antes de rodar. A leitura independente continua sendo do G3.
- **Três corridas por modelo não medem estabilidade**, medem que ela existe: o
  `4.6` variou entre 16/18 e 18/18 entre corridas idênticas.
- Sem voz, sem VoiceOver, sem iPad, sem Siri, sem mouse, sem maestro, sem
  `orca emulator`. Nenhum `erase`, `clearState`, `uninstall`, `install` ou
  `xcodebuild test` no `B91C8DEF`. Orientação, tamanho de letra e Movimento
  Reduzido **não foram tocados**.

## 6. Suíte

```
✔ Test run with 999 tests in 161 suites passed after 88.505 seconds.
** TEST SUCCEEDED **
```

`-only-testing:TracoTests`, destino `34CC3F94-FDB5-4575-A4F5-80271829A18B`,
**17h04–17h05** de 09/09, sob `ferramentas/orca/com-trava.sh`. **Foram DUAS
corridas de suíte**: a primeira às 17h01 (999 verdes, 89,161 s) antes de a
asserção da linha do Perfil existir, e esta, depois dela. **Liguei e desliguei o
`34CC3F94` nas duas**; ao fim ficou **um** aparelho ligado na máquina, o da conta.

## 7. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Correção | **9** | uma alavanca por corrida, provado em banda pelos 400 do `reasoningEffort`; 54 HTTP 200 por modelo; 999 verdes |
| Qualidade da IA | **9** | os doze triados por frase da API, três candidatos medidos em 162 execuções com os casos cegos dentro, e a conclusão **contraria** a volta anterior em vez de confirmá-la. Não é 10 porque a leitura ainda é minha |
| Design / experiência | **n/a** | nada de tela mudou. A espera na tela é da 09n e continua em `main`, aprovada pelo G3 |
| Ponytail | **9** | zero linha de produção, zero arquivo de código, zero configuração nova, **zero instalação**; a `TRACO_AVALIAR_SEM_ESFORCO` da volta anterior não foi usada |
| Honestidade | **9** | o resultado desmente a 09n e está dito assim; as duas leituras discordantes estão publicadas em vez de escolhida a conveniente; o `semRetorno` da primeira fumaça de fecho está no relatório e no JSONL |
| Performance | **n/a** | nada mudou de custo. A medida de espera dos três está na §3 |

## 8. Dívida nomeada (§8: acabamento não segura a volta)

1. **O `q2-relatorio-tres-restricoes` derruba dois dos três modelos** — dono:
   próxima volta de IA. O `sistemaResponder` proíbe "afirmar o que há dentro de
   um documento que ela não descreveu", e `4.3` e `4.5` afirmam PDF, sumário e
   tabelas assim mesmo. **Pode ser alavanca de PROMPT, não de modelo** — e essa é
   uma alavanca só, testável na mesma bancada desta volta.
2. **`revisor-responsavel-nao-definido` no `4.3`** — dono: mesma volta. É o caso
   cego que o padrão global de produção reprova 3 de 3, e ele mede "recusa
   covarde": expor o vazio sem dar continuação.
3. **Quatro respostas do `4.5` cortadas no teto de 900** — dono: próxima volta de
   tela. Hoje o autor recebe a frase partida com "…". O teto é do cartão, não do
   modelo; a decisão (subir o teto, pedir mais curto no prompt, ou cortar na
   frase) não é minha.
4. **Estabilidade** — dono: quem retomar a escolha do modelo. Três corridas
   mostraram que uma não basta. Antes de qualquer nova adoção, o número de
   corridas precisa ser escolhido pela variância medida aqui, não pelo orçamento.
