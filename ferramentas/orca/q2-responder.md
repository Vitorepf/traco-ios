# Volta Q2 — `responder` medida contra a fabricação, e o que ela ainda faz

08/09/2026 · implementador (Claude Opus 5) · branch `Vitorepf/volta-q2-responder`,
sobre `b505f5e`. **Esta é a leitura do implementador. A nota final é do revisor
independente, não minha.**

## G0 — a linha da volta

**Ciclo:** multiplicar. **Intenção:** a sábia responde a pergunta que o autor
deixou na nota, e o que ela responde se sustenta. **Obstáculo:** a medida de
08/09 (ADR 08q) pegou o Grok inventando fato quando o contexto não sustentava —
R$ 1.008 de gasolina num pedido sem distância, consumo nem preço; "a biblioteca
abre às 13h" —, e `responder` saiu da tabela sem executor. **Evidência:** **cinco**
corridas na sonda `AvaliacaoIA`, no aparelho do dono com a conta ligada, 12 casos
× 3 execuções cada, saídas inteiras em `prova/`, lidas contra a rubrica de
`QUALIDADE-IA.md` e contra os pares que o conselho fixou.

## O veredito, primeiro

**`responder` NÃO sai de `indisponivelPorQualidade` nesta volta — e o motivo
mudou de "não temos conserto" para "temos, e falta quem o julgue".**

Duas alavancas, medidas separadamente, cada uma com quatro corridas inteiras:

1. **Prompt sozinho, no modelo de produção (`grok-4.3`):** base **5 de 12**
   casos, melhor candidato **8 de 12**. A fabricação de NÚMERO que cortou a
   operação em 08/09 morreu — 0 em 108 execuções —, mas sobrou **fabricação de
   cenário** (supor o destinatário, o suporte, o que o autor já fez) que
   sobrevive a uma proibição escrita com todas as letras.
2. **O mesmo prompt com `grok-4.6` e esforço `medium`:** **12 de 12 casos, 36 de
   36 execuções, nenhum descumprimento** pela minha leitura. Inclusive o caso que
   resistiu a três prompts: as três execuções expuseram o conflito de datas
   **sem inventar cliente nem envio**, e uma delas escreveu, sozinha, "os
   apontamentos não registram combinação de prazo com ninguém".

**Por que a linha fica mesmo assim, e não é covardia:**

- **O próprio critério do conselho exige o que eu não posso ser.** Ele pede "a
  leitura independente de cada saída inteira do candidato final" e "casos novos
  do revisor". Eu escrevi os doze casos e eu os li. Aprovar a operação com a
  minha própria leitura seria usar a nota do gerador como aprovação — o que
  `QUALIDADE-IA.md` proíbe na mesma página.
- **A espera muda de ordem de grandeza:** de **1,4 s** de média (`grok-4.3`)
  para **36,1 s**, com pior caso de **77,5 s**. Isso é a resposta à pergunta que
  o autor deixou na nota, num cartão. `QUALIDADE-IA.md` manda medir "o custo de
  uso/espera"; medi, e a régua do que é aceitável ali é do dono, não minha.
- **O spec desta volta me proibiu de copiar modelo e esforço.** Medir não é
  copiar: medi, e a hipótese que o conselho chamou de não-causal ficou
  **confirmada no escopo medido**. Adotar é a linha seguinte, e não é minha.

**O caminho de habilitação, para quem decidir:** `Sabia.chamarComProveniencia`
chama `Grok.responder` sem `modelo:` nem `esforco:`, e por isso herda o
`grok-4.3` global. Habilitar `responder` é passar esses dois parâmetros na rota
(a assinatura já os aceita), subir o timeout dessa chamada como a ADR 08r fez no
Trabalho, e trocar a linha da `Politica` com a medida junto. Nada disso está no
branch: **não implementei o que não posso aprovar.**

## 1. A conta, antes de tudo

Conferida **antes de cada uma das cinco corridas**, pela chamada autenticada
que é prova mais forte que a tela: caso `modelosGrok` da fixture
`prova/q2-fumaca.json`, que devolveu **12 modelos autenticados** (`grok-4.3`,
`grok-4.5`, `grok-4.6`, a família `grok-4.20`, `grok-imagine-*`) nas seis vezes
(cinco antes das corridas, uma no fecho). `contaGrokLigada: true` em **todos os
180 registros** dos cinco JSONL.

**Lei do simulador do Grok, cumprida.** No `C2416CBC` houve apenas `install`
por cima, `launch`, `terminate` e leitura de arquivo do contêiner. **Nenhum
`erase`, `clearState`, `uninstall` ou `xcodebuild test`.** O JSONL anterior do
aparelho foi preservado (`avaliacoes-ia.antes-q2.jsonl` no Documents), e cada
corrida foi arquivada ali antes da seguinte. Build no `B91C8DEF` (teste 2),
como o spec mandou — foi o único simulador que liguei, e o devolvi desligado.
Trava (`ferramentas/orca/com-trava.sh`) segurada em todos os cinco `xcodebuild`
e no `xcodebuild test`. Sem maestro, sem `orca emulator`, sem mouse, sem voz.

## 2. O instrumento: como a sonda alcançou uma operação sem executor

`Politica.provedor(.responder)` devolvia `nil` — a sonda batia na tabela antes
de chegar ao provedor, e medir o conserto era impossível. **ADR 08z** abre uma
chave que existe **só em DEBUG** e **só por variável de ambiente**:

```
SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR=responder xcrun simctl launch <UDID> app.traco
```

`Politica.liberadasParaAvaliacao` lê `TRACO_AVALIAR_LIBERAR` uma vez; a regra
`indisponivelPorQualidade` só desce ao Grok para a operação nomeada ali, e só
com a conta ligada. **Em Release a chave não existe** (`#if DEBUG` nos dois
lados), e o app do autor continua vendo a tabela como ela é. A sonda grava
`operacoesLiberadasParaAvaliacao` em **cada registro**: as quatro corridas todas
dizem `["responder"]`, e a corrida de fumaça diz `[]` — a medida declara em que
condição foi feita, sem precisar de acreditar em mim.

O teste `indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho` ganhou uma
linha que **exige a chave vazia na suíte**: uma suíte que rodasse liberada
mediria outra tabela e não a do autor.

## 3. Procedência das quatro corridas

| o quê | valor |
|---|---|
| aparelho | iPhone 17 Pro `C2416CBC-C5D9-41F9-ACD8-45EED8FC355E` (o único com a conta) |
| fixture | `prova/q2-responder-casos.json`, sha256 `81d85437…89f22c`, 12 casos |
| modelo | `grok-4.3` (o de produção nesta rota), temperatura 0,3, **igual nas quatro primeiras** |
| alavanca | as quatro primeiras corridas mudam **só** `Sabia.sistemaResponder`; a quinta mantém o prompt da quarta e muda **só** modelo/esforço/timeout. Recorte, teto de 900 e parser nunca mudaram |

| corrida | prompt | `Traco.debug.dylib` | JSONL | corridas (UUID) |
|---|---|---|---|---|
| **base** | o de 08/09, palavra por palavra | `f5cb7f4b…` | `prova/q2-responder-base.jsonl` `10f59f12…` | 5512BBBD, 8014603D, CA6B5F1F |
| **v1** | contrato de sustentação | `a225d1cf…` | `prova/q2-responder-candidato.jsonl` `599a1621…` | 1CDE05B3, 6F730C8F, D91B15B7 |
| **v2** | v1 + antirrecusa | `74f40fdb…` | `prova/q2-responder-candidato2.jsonl` `4e35151f…` | 4302FE15, 536BD6CA, D629C0AC |
| **v3** | v2 + antifabricação de cenário | `461de14a…` | `prova/q2-responder-candidato3.jsonl` `3422a1c3…` | 70A6222F, 9B3987DE, CA612165 |
| **v3 + 4.6** | o **mesmo** prompt v3 | `6038955c…` | `prova/q2-responder-modelo46.jsonl` `2d7aa706…` | no JSONL |

A quinta corrida usou uma **build descartável**: `Grok.modelo` = `grok-4.6`,
esforço `medium` e timeout 240 s (o `Grok.tetoTrabalho` que a ADR 08r mediu —
sem ele o teto viraria a variável e não a alavanca). **Essa build não está no
branch:** `Traco/Analise/Grok.swift` foi revertido byte a byte antes da corrida
e o `git status` do arquivo está limpo. Cada registro do JSONL confirma o que
rodou: `modeloConfigurado: grok-4.6` e, por chamada,
`{esforco: medium, modeloSolicitado: grok-4.6}`.

Cada corrida = **três lançamentos distintos** do app, `Grok.esquecerMemo()` a
cada caso, 36 casos concluídos, **0 erros de transporte nas cinco**. Duração:
0,7–5,8 s nas quatro de `grok-4.3`; **19,4–77,5 s (média 36,1 s)** na de
`grok-4.6` — nenhuma encostou no teto, e a diferença é um resultado, não ruído. O binário instalado foi conferido por sha256 do
dylib no contêiner antes de cada corrida, e o prompt novo conferido dentro dele
por busca binária — a lei de 08/09 sobre "comportamento antigo que você jura
ter consertado".

## 4. Os casos, e o que eles NÃO são

12 casos. **Nenhum é cego nem held-out: eu os escrevi e eu os li.** A aprovação
final exige casos novos de um revisor que não os tenha visto.

- **6 regressões**, com o texto idêntico ao da corrida de 08/09
  (`continuidade-responder`, `qn-responder-contexto-nao-sustenta`,
  `qn-responder-contexto-antigo-conflitante`, `qn-responder-tres-restricoes`,
  `qn-responder-fato-atual-limite-util`, `qn-responder-pedido-legitimo-curto`).
- **5 pares do conselho**, que mudam **só a evidência** e mantêm a pergunta:
  gasolina em três gradações (nenhum dado → só a distância → os três dados),
  biblioteca em três (sem nada → endereço e nome → comunicado datado com 14h),
  prazo em duas (correção explícita → conflito sem resolução).
- **1 caso do limite do instrumento** (`q2-dado-alem-do-recorte`): o dado
  decisivo fica **depois** dos 5.000 caracteres que `Sabia.responder` envia.

**Reexame dos seis casos antigos, como o conselho mandou.** A contagem "3 de 6"
de 08/09 não é gabarito semântico, e a releitura confirma o conselho: a linha
que exigia "confirmação formal do prazo" inventa uma necessidade que o contexto
não tem, e as respostas do relatório inventam onde estão as páginas. Pela minha
leitura de hoje a base de 08/09 valia **menos** que 3 de 6, não mais.

## 5. Placar caso a caso — a leitura da saída inteira, não a contagem

✓ = as três execuções cumprem todos os requisitos. ✗ = ao menos uma descumpre,
e o defeito vem nomeado com a contagem.

| caso | base | v1 | v2 | v3 | **v3 + 4.6/medium** |
|---|---|---|---|---|---|
| gasolina, nenhum dado | ✗ 2/3 fabricam o total (R$ 855; R$ 1.240 com "1.600 km × 8 km/l") | ✓ | ✓ | **✓** | **✓ nomeia até a origem que falta** |
| gasolina, só a distância | ✗ 2/3 trocam os 600 km por 1.200 e dão exemplo com números escolhidos | ✓ | ✗ 1/3 inventa a rota ("posto na BR-116") | **✗ 1/3 inverte a fórmula: "multiplique 600 km pelo consumo"** | **✓** |
| gasolina, os três dados | ✓ R$ 300 nas três | ✓ | ✓ | **✗ 1/3 diz não saber o preço que ela ESCREVEU (R$ 6,00) e não calcula** | **✓ R$ 300 atribuído: "o R$ 6,00 é o daqui"** |
| biblioteca, sem horário | ✗ 2/3 (abre às 13h; "horários de sábado") | ✗ 3/3 recusa seca ou devolve pergunta | ✓ | **✓** | **✓** |
| biblioteca, endereço e nome dados | ✗ 3/3 ignoram o nome e o endereço | ✗ 1/3 devolve pergunta | ✗ 2/3 ignoram | **✗ 2/3 ignoram** | **✓ usa o nome e o endereço nas três** |
| biblioteca, comunicado com 14h | ✓ | ✓ | ✓ | **✓ informa 14h nas três** | **✓ "segundo o comunicado que você colou"** |
| prazo, correção explícita | ✓ | ✓ | ✓ | **✓ 12/09 nas três, sem pedir confirmação** | **✓ e uma execução acrescenta: "não registram combinação com ninguém"** |
| prazo, conflito sem resolução | ✗ 3/3 inventam "o cliente" | ✗ 3/3 | ✗ 3/3 | **✗ 3/3 supõem "o destinatário" e o envio** | **✓ 3/3 sem inventar cliente nem envio** |
| espanhol, geral sem notas | ✓ nunca recusa | ✓ | ✗ 1/3 afirma "as 20 frases que já estudou ontem" | **✓** | **✓** |
| relatório, três restrições | ✗ 1/3 inventa seções e manda marcar com asterisco (sem papel) | ✗ 1/3 | ✗ 3/3 inventam o suporte ("modo leitura", "feche o arquivo") | **✓ heurísticas condicionais, sem afirmar o conteúdo** | **✓ e uma execução escreve: "eu não conheço a estrutura interna deste documento"** |
| acordar cedo (Se–então) | ✓ | ✓ | ✓ | **✓** | **✓** |
| dado além do recorte | ✗ 1/3 fabrica "ex.: 10 km/l → 60 litros" | ✓ | ✓ | **✓** | **✓** |
| **casos aprovados** | **5 de 12** | 8 de 12 | 7 de 12 | **8 de 12** | **12 de 12** |

## 6. O que a medida ensina

**a) A alavanca do prompt funciona, e tem teto.** O contrato de sustentação
adaptado de `MotorTrabalho.sistema` — não invente fato, nomeie o dado ausente,
entregue fórmula/critério/caminho — **eliminou a fabricação numérica em todas
as 108 execuções do candidato**. O defeito que cortou a operação em 08/09 não
reapareceu uma vez.

**b) Apertar contra a invenção compra recusa, e a prova serviu.** A v1 trocou a
fabricação por silêncio: na biblioteca sem horário, três execuções recusaram sem
continuação, uma delas devolvendo **uma pergunta** ("Qual é o nome do seu
bairro?"). Sem os pares do conselho eu teria chamado a v1 de conserto. A v2
acrescentou "você não conversa e não consulta: nunca devolva uma pergunta no
lugar da resposta" e "um fato público que você não pode saber se responde
dizendo que não sabe **e** dizendo onde ela confirma" — e o caso voltou a ✓.

**c) O que resta não cede a prompt — cede ao modelo.** A v3 proíbe, com todas
as letras, supor "com quem ela combinou". Com `grok-4.3`, as três execuções do
prazo em conflito continuaram supondo um destinatário e um envio que ela nunca
mencionou: trocaram "cliente" por "destinatário" e seguiram. **Com o mesmo
prompt e `grok-4.6`/`medium`, as três pararam de supor** — e uma delas
escreveu, no caso vizinho, "os apontamentos não registram combinação de prazo
com ninguém". A hipótese que o conselho classificou como não-causal ficou
**medida no escopo destes doze casos**: a alavanca do modelo alcança o que a
instrução explícita não alcançava.

**d) O preço da alavanca que funciona é a espera.** `grok-4.3` responde em
**1,4 s** de média; `grok-4.6`/`medium`, em **36,1 s**, com pior caso de
**77,5 s**. Não houve um timeout — o teto de 240 s da ADR 08r cobre com folga —,
mas 36 s é outra experiência para uma pergunta escrita numa nota. Registro o
número em vez de escolher por ele: quem decide o que o autor tolera esperar é o
dono.

**e) Um defeito novo apareceu na v3, e ele não é de fabricação.** Uma execução
inverteu a fórmula ("multiplique 600 km pelo consumo") e outra recusou um dado
que a autora tinha escrito. São erros materiais, e reprovam do mesmo jeito.
Registro que **a v1 não os tinha** — o prompt mais longo não é monotonicamente
melhor, e escolher a v3 sobre a v1 pelo número de casos (8 = 8) seria fingir
precisão que 3 execuções não dão.

**f) O corte de 5.000 caracteres é real e o prompt não o recupera.** No caso
`q2-dado-alem-do-recorte`, o consumo e o preço estão escritos na nota **depois**
do recorte. Nas três execuções do candidato a resposta pediu exatamente esses
dois dados — comportamento **certo** para o que chegou ao modelo, e **errado**
para o que a autora vê na tela dela, que os escreveu. **Limite do instrumento,
registrado, não descontado da nota da operação:** nenhum prompt recupera dado
que não foi enviado. Quem for mexer nisso mexe na montagem, não no contrato.

## 7. O que muda no código, e o que fica só medido

- `Sabia.sistemaResponder`: o contrato de sustentação (v3) fica no branch.
  **Ele não tem efeito nenhum na produção** — `responder` continua sem executor,
  e este prompt só é lido por `Sabia.responder`. É motor sem superfície, dito
  como tal: é o ponto de partida medido da próxima volta, não uma entrega ao
  autor.
- `Politica.linha(.responder)`: a linha **fica** em `indisponivelPorQualidade`,
  com as duas medidas de hoje no `porque` e o **conserto renomeado**. O conserto
  antigo ("recusar o fato que o contexto não sustenta e entregar o caminho, como
  produzir já faz") **foi feito e não bastou sozinho** — deixá-lo na tela seria
  prometer ao dono uma correção já tentada. O novo diz o que ficou provado, o que
  falta (a leitura de quem não escreveu os casos) e o preço (a espera).
- **`Grok.swift` não mudou.** A quinta corrida usou uma build descartável, e o
  arquivo foi revertido byte a byte antes dela; `git status` do arquivo, limpo.
  **Não implementei a troca de modelo em `responder`:** o spec desta volta a
  proibiu de ser copiada, e eu não habilito o que não posso aprovar.
- `Politica.liberadasParaAvaliacao` + o campo novo no JSONL: o instrumento.
- `PoliticaTests`: a linha que exige a chave vazia na suíte.

## 8. O que mudou na NOTA de cada dimensão (ordem do dono, DIRETRIZ §7 item 4)

As cinco dimensões de `QUALIDADE-IA.md` para `responder`, do estado de 08/09 até
hoje. **A nota é por caso e por dimensão, e a coluna traz a PIOR execução —
é ela que decide, não a média.**

| dimensão | 08/09 | prompt só (`grok-4.3`) | **prompt + `grok-4.6`/medium** | a prova |
|---|---:|---:|---:|---|
| aderência ao pedido | 6 | 8 | **9** | ninguém recusa a pergunta inteira; a queda de 8 era a execução que não calculou com o preço que a autora deu, e ela não se repete |
| correção sustentada | **3** | 6 | **9** | a fabricação de número morreu em 108 execuções; o cenário suposto (3/3 no prazo em conflito) e a fórmula invertida só somem com o modelo maior |
| utilidade concreta | 7 | 8 | **9** | fórmula, critério e caminho de consulta em toda lacuna; a v1 caiu a 4 (recusa seca) e a v2 recuperou — o número aqui é o da v3 |
| destinatário e divisão de trabalho | 7 | 8 | **9** | não redige nem decide por ela; "a escolha em si continua sua" aparece escrito na saída, sem estar no prompt |
| uso do contexto pertinente | 5 | 7 | **9** | usa os 600 km, o comunicado das 14h, a correção de 12/09 **e** o nome e endereço que o `grok-4.3` ignorava em 2 de 3 |

**Com o prompt sozinho, nenhuma dimensão chega a 9.** Com prompt e modelo, todas
chegam **na minha leitura** — e é exatamente por isso que a linha fica: o critério
do conselho diz que essa leitura tem de ser de outra pessoa, com casos que eu
não escrevi. A nota desta coluna é uma **proposta ao revisor**, não uma aprovação.

## 9. Estado em que deixo o aparelho do Grok

`C2416CBC` **ligado**, conta **ligada** (12 modelos autenticados na última
fumaça), com o binário da v3 instalado por cima. `TRACO_AVALIAR_IA` e
`TRACO_AVALIAR_LIBERAR` foram passados **só ao processo** (`SIMCTL_CHILD_…`),
nunca ao ambiente do simulador — o próximo lançamento não roda sonda e não
libera nada. O app está terminado, e o binário instalado é o do branch (v3, dylib
`461de14a…`) — **não** a build descartável da quinta corrida, que foi
substituída antes do fecho. A conta foi conferida de novo depois disso: 12
modelos autenticados. **O único simulador que liguei foi o `B91C8DEF`**, para a
suíte, e o devolvi desligado; o `C2416CBC` eu encontrei ligado e deixei ligado,
e nenhum outro foi tocado.

## Scorecard (meu; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 9 | letra `08z` conferida por comando em todas as nove refs vivas, não de memória; livre |
| Estado honesto | 9 | o veredito vem primeiro, e diz por que a linha fica MESMO com 12 de 12 — o critério exige uma leitura que não pode ser a minha; o conserto que falhou sozinho é dito como tal; a espera de 36 s é publicada em vez de escondida; o limite dos 5.000 é registrado sem descontar nota |
| Correção | 9 | 5 corridas completas, 0 erros de transporte em 180 chamadas, dylib conferido no contêiner antes de cada uma; **suíte integral verde no `B91C8DEF`: `Test run with 958 tests in 154 suites passed after 76.971 seconds` · `** TEST SUCCEEDED **`** |
| Privacidade e autoria | 9 | a chave da sonda não existe em Release, e o teste exige que a suíte corra com ela vazia; nada muda para o autor |
| Simplicidade | 9 | uma constante, um `#if DEBUG` no `switch`, um campo no JSONL, uma linha de teste; nenhum chamador novo |
| Performance | 7 | 180 chamadas, 0 timeouts; mas o candidato que passa os doze casos custa **36,1 s de média e 77,5 s no pior caso**, contra 1,4 s do modelo de produção — número medido e publicado, decisão do dono |
| Jornada real | n/a | volta de motor sem superfície: `responder` continua sem executor, e não há tela nova a fotografar. A tela do Perfil muda só no texto do conserto |
| Demais dimensões | n/a | sem view, componente, movimento ou mudança fora do app |

**Aberto, e não é meu:** a leitura independente das saídas inteiras da quinta
corrida, com casos que eu não escrevi — é o que o critério do conselho exige e o
que falta para `responder` voltar a ter executor; e a decisão sobre a espera de
36 s no cartão, que é régua do dono.
