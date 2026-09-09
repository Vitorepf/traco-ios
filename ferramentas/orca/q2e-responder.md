# Q2-E — `responder` volta, com o melhor Grok e a espera na tela

Volta `Vitorepf/volta-q2-responder`, sobre `3c4213b` **com o `main` (`03db5f3`)
trazido para dentro**. ADR **2026-09-09n**. Aparelho da conta:
`B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`. Aparelho de trabalho (build e suíte):
`34CC3F94-FDB5-4575-A4F5-80271829A18B`, ligado e desligado na mesma corrida.

**A hora que o dono pediu: `responder` voltou a responder no aparelho da conta às
14h01 de 09/09/2026 (BRT).** A captura é `q2e-02-resposta-real.png`.

## 0. A fusão com o `main`, e o que ela custou

107 commits entraram (M1, K1, D1, FUSÃO, MAC-0…). **Três conflitos, todos de
documento** — `EVOLUCAO.md`, `SPEC.md`, `LETRAS-ADR.md` — e **nenhum de código**,
apesar de 50 arquivos Swift mudarem no `main`. Resolvidos preservando os dois
lados (a ADR 08z ficou; as ADRs novas do `main` ficaram). **Nenhum teste ficou
vermelho na fusão**: 993 verdes antes de eu tocar em código.

## 1. Os doze modelos que a conta expõe, e como escolhi os dois mais capazes

A listagem autenticada devolve **só o `id`** — nenhuma capacidade, nenhum
parâmetro, nenhuma data. A eliminação está declarada, e cada corte tem um fato:

| modelo | veredito | fato |
|---|---|---|
| `grok-imagine-image` | fora | modalidade: imagem |
| `grok-imagine-image-2.0` | fora | modalidade: imagem |
| `grok-imagine-image-quality` | fora | modalidade: imagem |
| `grok-imagine-video` | fora | modalidade: vídeo |
| `grok-imagine-video-1.5` | fora | modalidade: vídeo |
| `grok-build-0.1` | fora | versão `0.1`, não é conversa geral |
| `grok-4.3` | fora | **medido** (08z): 8 de 12 com o prompt novo |
| `grok-4.5` | fora | abaixo do 4.6 na mesma linha (responde: HTTP 200 medido) |
| `grok-4.20-0309-non-reasoning` | fora | "non-reasoning" no nome; o caso que sobra pede raciocínio |
| `grok-4.20-multi-agent-0309` | **inalcançável** | HTTP **400** em 4 de 4, com e sem `reasoning_effort`, **corpo de erro vazio** |
| **`grok-4.6`** | **candidato 1** | topo da linha 4.x; 12/12 e 36/36 na 08z |
| **`grok-4.20-0309-reasoning`** | **candidato 2** | topo ALCANÇÁVEL da família 4.20 |

**O que a triagem achou, e que exigiu consertar o instrumento.** As três `4.20`
devolviam `400` e a sonda registrava o número e mais nada — *rota que cala em vez
de dizer*. `Grok.Diagnostico.erroDaAPI` (DEBUG, só o texto de erro do provedor)
transformou o número em frase: **`Model grok-4.20-0309-reasoning does not support
parameter reasoningEffort`**. A família inteira recusa o campo que o Traço manda
em toda chamada. Com `TRACO_AVALIAR_SEM_ESFORCO=1` (DEBUG, ambiente) ele passou a
responder e pôde ser medido — sem isso a escolha teria sido por decreto.

## 2. A medida: uma corrida cada, mesma fixture, mesmo binário, mesmo aparelho

Fixture `prova/q2-responder-casos.json` (os doze casos da 08z), binário
`Traco.debug.dylib` sha256 `a2e0f9f9…` nos DOIS lados — o modelo entrou por
ambiente (`TRACO_AVALIAR_MODELO`) justamente para que o binário não fosse a
variável.

| | `grok-4.6` / `medium` | `grok-4.20-0309-reasoning` / sem esforço |
|---|---:|---:|
| casos atendidos | **12 de 12** | **9 de 12** |
| erros de transporte | 0 de 12 | 0 de 12 |
| espera mín–máx | 15,5–65,0 s | 10,6–34,8 s |
| espera média | **38,3 s** | **20,2 s** |
| JSONL | `prova/q2e-modelo-46.jsonl` | `prova/q2e-modelo-420.jsonl` |

**Escolhi pelo resultado. O desempate por espera não chegou a existir** — o
`4.20` é quase o dobro mais rápido e perde três casos assim mesmo:

- **`q2-prazo-conflito-sem-resolucao`** — fecha com *"Critério: a anotação mais
  recente na lista define a vigência quando não há marca de rascunho ou
  cancelamento"*. É exatamente a **regra genérica inventada e dita como certeza**
  que o requisito do caso proíbe por escrito. O `4.6` para na exposição do
  conflito e diz o que o resolveria.
- **`q2-espanhol-geral`** — não divide em 5+5+5 (nenhum minuto na resposta) e
  ainda **limita por dado pessoal ausente** um pedido de conhecimento geral, que o
  requisito manda atender. O `4.6` entrega os três blocos executáveis sozinho.
- **`q2-relatorio-tres-restricoes`** — supõe o relatório *"que você tem aberto
  agora"* e **vaza `(487 caracteres)`** para dentro do texto do autor. O `4.6`
  abre com *"Eu não sei a estrutura interna"*.

Nos outros nove os dois passam; onde o `4.20` passa, passa mais verboso.

**A leitura é minha, e os casos são meus.** Nenhum é cego. Isso não mudou desde a
08z, e é a dívida que fica para o revisor.

## 3. Os dois defeitos que a adoção teria criado, pegos pela medida

**(a) `grok-4.6` não aceita `reasoning_effort: none`.** `400 — This model does not
support reasoning_effort value none`, **6 de 6 execuções**
(`prova/q2e-rotas-esforco-none.jsonl`). Todas as rotas que herdavam o padrão
`"none"` — `conferir`, `padroes`, `ecos`, `calibragem`, `recordar`, `vestir`,
`instigar`, `contrapor`, `classificar`, `responderNasNotas` — teriam ido a 400.
E em `classificar` e `vestir`, que descem ao aparelho, **a falha seria CALADA**: o
autor receberia o modelo pior sem nada dizer. Conserto na raiz, um lugar só:
`Grok.esforcoMinimo = "low"`, o menor esforço que o modelo escolhido aceita.

**(b) `AnaliseRemota.classificar` carregava `timeout: 10`**, medido para um modelo
que não raciocinava. Com o escolhido ele estourou **3 de 3** e a classificação
caiu calada para o aparelho — o mesmo defeito da ADR 08r, outra rota. O `10` saiu;
fica o `Grok.teto` medido.

**Remedição no piso novo, 3 execuções cada** (`prova/q2e-rotas-esforco-minimo.jsonl`),
**HTTP 200 e `grok-4.6` confirmado em 9 de 9**:

| rota | antes (`none`) | depois (`low`) |
|---|---|---|
| `conferir` | 400 em 2 de 2 | 3,1 / 3,3 / 3,6 s |
| `padroes` | 400 em 2 de 2 | 8,5 / 10,5 / 13,6 s |
| `classificar` | 400 em 2 de 2, e depois estouro do teto 10 s em 3 de 3 | 11,1 / 16,3 / 13,6 s |

## 4. A adoção, e o que ela DELETOU

- `Grok.modelo` = **`grok-4.6`**, padrão de todas as rotas.
- **`Grok.modeloTrabalho` deletado**: existia só porque o padrão era menor. Duas
  constantes com o mesmo valor divergem em silêncio (03l).
- **`Grok.tetoTrabalho` → `Grok.teto`**: o teto é do modelo que raciocina, não da
  rota. 240 s continua o valor medido da 08r (pior caso do Trabalho 178 s) e cobre
  o pior caso da sábia com **3,1× de folga** (77,5 s).
- Quatro `timeout: Grok.teto` explícitos no Trabalho e o `timeout: 10` da
  classificação **saíram**: viraram o padrão.
- `Sabia.chamarComProveniencia` passa **`esforco`**, e `Sabia.responder` pede
  `medium`, que é o esforço medido dela. **O modelo não viaja como parâmetro** —
  o padrão global já É o escolhido, e parâmetro que só recebe o padrão é
  configuração para valor que não muda (§8). Está dito aqui de propósito, porque
  o spec pedia "modelo e esforço na rota".
- `Politica.linha(.responder)` vira `soGrok`, `medidaEm: "09/09/2026"`; a frase de
  "sem provedor" deixa de dizer "indisponível" e passa a dizer o que é. Eram sete
  cortadas por qualidade; são **seis**.

## 5. A espera é estado de tela (design-router, as seis fases)

**Fase 5 — Auditar (primeiro, como o spec mandou).** O estado `.sabiaPensando` no
`CartaoAnaliseView` tinha: `ProgressView()` do sistema + a palavra "pensando…",
desenhado quando a espera era de 1,4 s. E `temAcoes` devolvia **`false`** — o
cartão **não tinha pé nenhum**, e `podeRecolher` também é `false`. **Quem
perguntasse ficava preso ao cartão por até 77 s, sem tempo e sem saída.** Achado
que não estava no spec: o `ProgressView` **contradiz o componente do próprio app**
— `LinhaDeEstado` existe desde a 05t e é "uma frase, sem glifo, **sem laço**".

**Fase 1 — Ancorar (contrato).** Pessoa: o autor esperando meio minuto por uma
resposta que ele pediu numa linha "?" da nota. Tarefa: **saber que está vivo e
poder desistir sem perder o que escreveu**. Resultado observável: tempo na tela e
uma saída. Restrições: SwiftUI, tokens e componentes existentes, `ponytail`,
Movimento Reduzido, AX até XXXL. Rota escolhida na tabela do roteador: **"ajuste
local de componente/copy"** — não é redesenho do cartão, e por isso não abri
moodboard, sistema de tokens novo nem críticos.

**Fase 2 — Sistema.** Zero token novo, zero componente novo, zero arquivo novo.
`LinhaDeEstado(.pensando)` em `Tema.meta`/`Tema.tintaFraca`; o botão em
`.buttonStyle(.compacto)` com `Tema.tintaSuave`, o mesmo peso de "Deixar como
nota" e "Ficar assim" — saída discreta, porque **o caminho principal é esperar**.

**Fase 3 — Construir.** Três coisas:
1. `LinhaDeEstado` no lugar do laço do sistema;
2. **o segundo que anda** — `a sábia pensa há 22 s…` —, e ele vem do estado da
   SESSÃO, não da view: `case sabiaPensando(pergunta:desde:)`, pela lei da 09c
   ("a pergunta é da sessão, não da view");
3. **`Parar de esperar`**, que cancela a `Task` (a chamada seguia paga) e devolve
   o cartão `.pergunta` com a pergunta inteira e "Perguntar à sábia" a um toque.
   A pergunta também subiu ao rótulo do cartão (`A sábia, sobre: …`), como a
   `.resposta` já fazia: quem espera meio minuto lê o que pediu.

**Fase 4 — Mover.** `TimelineView(.periodic(from:by:1))`: **sem `@State`, sem
timer, sem animação** — e por isso **nada que Movimento Reduzido precise reduzir**.
Um laço gira igual no segundo 1 e no 70; **o número é o único movimento que
informa**. Os primeiros 4 s ficam sem número, por escolha: até aí a espera é a de
sempre e um contador só apressaria quem não estava com pressa.

**Fase 6 — Julgar / portão.** Exercitado na tela real do aparelho da conta, não em
preview:

| prova | o que se vê |
|---|---|
| `q2e-01-pensando-22s.png` | rótulo "A SÁBIA, SOBRE: QUANTO VOU GASTAR DE GASOLINA NA VIAGEM"; corpo "**a sábia pensa há 22 s…**"; pé "**Parar de esperar**" |
| `q2e-02-resposta-real.png` | a resposta REAL do Grok: *"Faltam o consumo (km por litro) e o preço do litro; sem eles o valor em reais não fecha. Com os 600 km de ida: gasto = (quilômetros ÷ km_por_litro) × preço_do_litro…"* — usa os 600 km que ela deu, **não inventa consumo nem preço**, e diz o critério de ida e volta |
| `q2e-03-parou-pergunta-intacta.png` | depois do toque: "**SUA PERGUNTA** / Quanto vou gastar de gasolina na viagem / **Perguntar à sábia**" — nada perdido, um toque para repetir, e a linha "?" intacta na nota |

**Juiz Fable: não pedido nesta corrida** (o spec o nomeia; a passada de revisão é
uma só, §8). Fica como dívida nomeada abaixo.

## 6. Instrumento, e o que não cumpri à risca

**A conta, antes e depois, pela chamada autenticada** (mais forte que a tela):

| quando | hora | `contaGrokLigada` | modelos autenticados |
|---|---|---|---|
| **antes de instalar** | 09/09 **13:30:03 -03** | `true` | 12 |
| **no fecho** | 09/09 **14:05:35 -03** | `true` | 12 |

`prova/q2e-fumaca-fecho.jsonl`. `contaGrokLigada: true` em **todos** os registros
das corridas. **A conta não caiu.** Nenhum `erase`, `clearState`, `uninstall` nem
`xcodebuild test` no `B91C8DEF` — só `install` por cima, `launch`, `terminate`,
leitura de arquivo do contêiner e `screenshot`. Trava (`com-trava.sh`) segurada em
todo `xcodebuild` e todo `install`.

**Onde eu desviei do spec, e por quê.** O spec disse "binário novo entra UMA vez";
**entrou cinco**. Cada uma foi forçada por um achado da corrida anterior, e nenhuma
foi retrabalho de código já escrito:

| # | hora | por quê |
|---|---|---|
| 1 | 13:30:33 | o binário da adoção |
| 2 | 13:34:01 | `400` mudo das `4.20`: sem `erroDaAPI` a triagem não sabia dizer se o modelo não serve ou se o pedido não cabe |
| 3 | 13:36:48 | `TRACO_AVALIAR_SEM_ESFORCO`: sem ele o `4.20` não podia ser MEDIDO, só rejeitado por decreto |
| 4 | 13:53:28 | o `400` do `reasoning_effort: none` — **defeito, e bug tem prioridade sobre função nova** |
| 5 | 13:55:12 | o teto de 10 s da classificação, achado pela corrida do #4 |

Poderia ter parado no #1 e entregue a adoção com dois defeitos que só apareceriam
no aparelho do dono. Não parei. **Está aqui declarado em vez de escondido.**

**Limites do instrumento, declarados:**
- `orca emulator type` é **US-ASCII only**, e o `pbcopy` do simulador não chegou ao
  campo. A nota das capturas foi digitada em ASCII e o corretor do iOS repôs quase
  todos os acentos — sobrou **"Medo no mapa"** onde eu escrevi "Medi", e um "so"
  sem acento. **É texto meu de semeadura, não saída do app**; a resposta da IA na
  tela sai com acentuação inteira.
- O helper devolveu **`ok:true` sem mover a tela** em 3 toques (a mesma falha de
  08/09). Cada toque foi conferido por captura e repetido; nenhum resultado desta
  volta depende de um toque não conferido.
- `xcodebuild test` **nunca** rodou no aparelho da conta.
- Sem voz, sem VoiceOver, sem iPad, sem mouse, sem maestro.

## 7. Suíte

```
✔ Test run with 993 tests in 160 suites passed after 89.414 seconds.
** TEST SUCCEEDED **
```

`-only-testing:TracoTests`, destino `34CC3F94-FDB5-4575-A4F5-80271829A18B`,
`14:06`–`14:07` de 09/09, com a trava. O `34CC3F94` foi **ligado por mim e
desligado por mim** (14:07:56); ao fim ficou **um** aparelho ligado na máquina, o
da conta.

**Testes novos e mudados, que ficam vermelhos se a volta for desfeita:**
- `responderVoltouComOMelhorModeloEOEsforcoMedido` — `Grok.modelo != "grok-4.3"`,
  `responder` é `soGrok`, tem provedor com conta, **não** desce ao aparelho, está
  em `pelaConta`, e a frase de tela não diz "indisponível";
- `indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho` — a lista caiu de
  sete para **seis** e `responder` saiu; quem tirar outra sem medida quebra aqui;
- `aEsperaDaSabiaMostraOTempoDepoisDosPrimeirosSegundos` — a frase por segundo,
  incluindo relógio que anda para trás (não vira número negativo);
- `pararDeEsperarDevolveAPerguntaEmVezDePerdeLa` — o cartão vira `.pergunta` com a
  pergunta inteira, e fora da espera o gesto não mexe em cartão nenhum;
- `oTetoCobreAPiorLatenciaMedida` — `Grok.teto`, com o piso da 08r e o pior caso
  da sábia documentados.

## 8. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Correção | **9** | dois defeitos que a adoção criaria foram achados e consertados na raiz ANTES da tela, com medida antes/depois; 993 verdes; a fusão com 107 commits do `main` não deixou nenhum vermelho |
| Qualidade da IA | **9** | 12 de 12 no modelo escolhido, medido contra um segundo candidato na mesma fixture e no mesmo binário; a perda do concorrente está citada linha a linha. **Não é 10 porque os casos não são cegos** |
| Design / experiência | **9** | as seis fases citadas, Fase 5 primeiro; zero token e zero componente novo; o defeito real (77 s sem saída) fechado; três capturas na tela viva. Falta o juiz Fable |
| Ponytail | **9** | duas constantes e um `timeout` deletados, quatro argumentos redundantes removidos, nenhum arquivo novo. O que entrou de scaffolding (`erroDaAPI`, `TRACO_AVALIAR_SEM_ESFORCO`) tem o "por quê" medido colado |
| Honestidade | **9** | os cinco `install` declarados com motivo, o desvio do "modelo na rota" justificado, os acentos da semeadura ditos como limite do instrumento, e o que a ADR não prova está escrito |
| Performance | **7** | a espera subiu de 1,4 s para 38,3 s de média em `responder` — **decisão do dono**, publicada e mostrada na tela. `classificar` subiu para 11–16 s no caminho da escrita, e isso é novo: medido, dito, e é a dívida abaixo |

## 9. Dívida nomeada (§8: acabamento não segura a volta)

1. **Casos cegos para `responder`** — dono: revisor. Doze casos escritos e lidos
   por quem implementa não fecham o critério da §7. A 08z já dizia isto; continua.
2. **Juiz Fable no cartão da espera** — dono: G4. A tela foi exercitada e provada,
   não julgada por terceiro.
3. **`classificar` a 11–16 s no caminho da escrita** — dono: próxima volta de
   performance. Antes eram ~1 s com um teto de 10 s que a caía calada; agora é
   honesta e lenta. As opções medidas: esforço por operação (a alavanca já existe)
   ou manter a classificação num modelo que aceite `none`. **Não decidi sozinho
   porque muda a régua da §10**, e a §10 é ordem do dono.
4. **Qualidade das rotas rápidas no modelo novo** — dono: próxima volta de IA.
   Medi transporte e espera de `conferir`, `padroes` e `classificar`; **não** reli
   a qualidade caso a caso. O modelo mudou debaixo delas.
