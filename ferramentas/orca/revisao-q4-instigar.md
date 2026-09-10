# G3 independente — Q4 `instigar` e `contrapor`

**Revisor:** independente do autor da volta. **Candidato:** `aec62d4`; medida:
`79ff054` / executável `e9983ddb…`; conta e aparelho do lote:
`B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`.

## Veredito: REPROVADAS, separadamente

`instigar` e `contrapor` **permanecem indisponíveis por qualidade**. Li as 36
saídas completas: 18 por operação, 6 casos × 3 repetições, em `grok-4.3`, sem
erro de transporte. A régua de `QUALIDADE-IA.md` reprova o caso inteiro com
uma só falha; portanto os acertos e a guarda verde não compensam os casos
abaixo.

Não há hora de volta: às 22:21:13Z–22:25:58Z (19:21:13–19:25:58 BRT) a janela
mediu o candidato, mas ela não atingiu a régua. A linha do Perfil continua
`indisponivelPorQualidade`; não há captura de cartão de resposta real a anexar,
pois a condição para aprovar e mostrá-lo na tela não aconteceu.

## Achados que impedem a saída da lista

### [P1] `instigar`: o degrau quatro não passou a cobrar o limite — 3/3

No par `q4-instigar-mesmo-texto-degrau-4`, as três respostas repetem quase as
mesmas perguntas do degrau zero (hora livre, quinze minutos, estar sozinho) e
só acrescentam “o que pode dar errado se ... não bastarem”. Elas não perguntam
onde a premissa de precisar de uma hora deixa de valer nem o que a contradiz,
como exige a fixture. O degrau continua sem uma diferença visível e útil.

### [P1] `instigar`: a guarda comprou mudez sobre palavras que são do autor — 3/3

Em `q4-instigar-o-autor-escreve-metodo`, nenhuma das três respostas pergunta
sobre o **método de estudo** ou o **segundo degrau** que a pessoa escreveu;
falam apenas de leitura, escrita e gramática. Isso descumpre explicitamente o
par de procedência do caso: impedir jargão do app não autoriza apagar o
vocabulário da pessoa.

### [P1] `instigar`: texto magro ganhou um episódio inventado — 2/3

As repetições 2 e 3 de `q4-instigar-texto-magro` perguntam qual foi a
“tentativa anterior que também não deu certo” / quais tentativas anteriores
também falharam. “De novo” não autoriza supor a repetição do mesmo episódio;
o próprio requisito manda a pessoa nomear isso. A repetição 1 é útil, mas não
compensa as duas.

### [P1] `contrapor`: nega a razão CSV já sustentada — 3/3

`q4-contrapor-razao-ja-sustentada` exige reconhecer que CSV atende ao requisito
de abrir em qualquer editor de texto e, se houver ressalva, nomear limite real
de CSV. As três saídas empurram XLSX/JSON ou conversão por ferramenta e não
reconhecem a restrição dada; a primeira chega a priorizar planilhas, a segunda
traz “ferramentas específicas” e a terceira inventa sistemas de conversão.
É a objeção fabricada que o caso proíbe, nas três repetições.

### [P1] `contrapor`: a dívida declarada de invenção chega à tela — 1/3

Em `q4-contrapor-outro-campo-sem-fabricar`, repetição 3, `foraDaLista` diz
“recompor o valor com o salário nos meses seguintes”. A nota não informa
salário ou renda; o requisito proíbe inventar renda. `vazaAlheio` só observa a
lista de formas de evidência (`%`, pesquisa, metanálise etc.), por isso não
barra este cenário novo. A guarda cobre a forma histórica, mas **não basta**
para liberar `contrapor` enquanto uma invenção concreta permanece medida.

## Scorecard das cinco dimensões de qualidade

| dimensão | instigar | contrapor | prova |
|---|---:|---:|---|
| aderência ao pedido | 6 | 6 | degrau 4 sem limite; CSV não respeita editor de texto |
| correção sustentada | 7 | 5 | pressuposição de episódio; “salário” sem fonte |
| utilidade concreta | 7 | 6 | método do autor some; contraponto contradiz requisito já suficiente |
| adequação ao destinatário e divisão de trabalho | 7 | 7 | pergunta não devolve o que a pessoa pediu examinar; alternativa vira prescrição deslocada |
| uso do contexto pertinente | 7 | 5 | “método/degrau” escritos pela pessoa não são usados; requisito CSV e ausência de renda são ignorados |

Qualquer célula abaixo de 9 mantém a operação fora; aqui ambas têm várias.

## Variação e leitura caso a caso

| operação | execuções lidas | variação relevante | casos que reprovam |
|---|---:|---|---|
| `instigar` | 18 (6 × 3) | 3–5 perguntas por saída; o defeito do degrau aparece em 3/3, o do método do autor em 3/3, e a suposição no texto magro em 2/3 | `q4-instigar-mesmo-texto-degrau-4`, `q4-instigar-o-autor-escreve-metodo`, `q4-instigar-texto-magro` |
| `contrapor` | 18 (6 × 3) | `outroCampo` vazio em 2/18 (permitido); a negação da razão CSV aparece em 3/3 e a renda fabricada em 1/3 | `q4-contrapor-razao-ja-sustentada`, `q4-contrapor-outro-campo-sem-fabricar` |

Os demais casos foram lidos, não inferidos por contagem. A variação observada é
justamente a razão de as três repetições não virarem uma média: o defeito de
`salário` só aparece em uma, e já reprova seu caso.

## A causa alegada, confrontada com 08/09

A leitura original sustenta a atribuição como **correlação observada**, não
como prova contrafactual absoluta: os dois casos com `gesto: decisao`
(`qn-instigar-decisao-com-restricao` e `qn-instigar-degrau-avancado`) não
devolveram andaime nas três execuções; cada um dos quatro sem método devolveu
ao menos uma vez vocabulário nosso — espanhol 3/3, premissa 3/3, texto magro
3/3 e capítulo/“forma nota” 1/3. Portanto faz sentido tirar o andaime do texto
citável; o diagnóstico não cai. O que cai é a conclusão maior de que essa
mudança, mais a guarda de forma, já resolve o atendimento.

## Vermelho e verde da guarda, sem confundir com qualidade remota

Montei checkout descartável de `aec62d4` em `/tmp/q4-red-review`, mudei **só**
`Sabia.vazaAlheio` para `false`, e rodei pela trava no `34CC3F94`:

```
ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
  -destination 'platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B' \
  -only-testing:TracoTests/AndaimeNaoVoltaAoAutorTests -parallel-testing-enabled NO
```

O vermelho foi real: `Test run with 7 tests in 1 suite failed ... with 11
issues` e `** TEST FAILED **`. Isto também corrige a alegação de 12 issues do
relato pai: com o candidato exato, a mutação produz 11. Sem a mutação, no
worktree candidato e no mesmo UDID, `Test run with 7 tests in 1 suite passed`
e `** TEST SUCCEEDED **`.

O checkout descartável foi removido. Eu encontrei o `34CC3F94` ligado e o deixei
ligado; não toquei no `B91C8DEF`, não instalei, não lancei a sonda, não usei
voz, VoiceOver ou iPad. As duas execuções locais passaram por
`com-trava.sh`; a corrida remota julgada é a já registrada pelo LOTE.

## Linha do Perfil e próximo dono

- `instigar` fica na lista com motivo novo: **“a medida de 09/09 ainda não
  cobra o limite do degrau nem usa o método que você escreveu; em texto magro
  supõe um episódio.”**
- `contrapor` fica na lista com motivo novo: **“a medida de 09/09 ainda nega
  uma razão já sustentada e inventou renda que você não escreveu.”**

Dono do próximo conserto: quem mantém `Sabia`/a fixture Q4. Deve corrigir o
comportamento e medir de novo, em três saídas por caso, antes de qualquer troca
de `Politica` ou captura de aprovação.

## Limites

O lote prova o binário e a conta ligados, mas não muda o julgamento semântico
acima; nenhuma nova chamada de rede foi feita por esta revisão. A captura do
cartão no aparelho da conta é exigência de aprovação e não existe nesta
reprovação; inventá-la a partir de JSONL seria evidência falsa.

---

## re-G3 — LOTE-3: REPROVADAS, separadamente (10/09)

Li por inteiro as 72 saídas Q4 do LOTE-3: 36 no `grok-4.3`, que é a comparação
pareada com o LOTE-1, e 36 no `grok-4.5`, na sobra da mesma janela. O candidato
é `dcbf7c6`, incorporado no binário `c6cd0ca8…`; a janela ficou sob uma chamada
de `com-trava.sh`, das 00:38:42Z às 00:54:55Z, no `B91C8DEF`, com uma instalação,
quatro fumaças de conta ligada/12 modelos e zero erro de transporte. Esta
revisão não instalou, lançou ou testou aparelho algum.

### O que mudou de lado

- **P1 1 resolvido:** no par do degrau 4, as três respostas de cada modelo
  perguntam quando a regra da hora livre deixa de valer e o que a contrariaria;
  não repetem a cobrança do degrau 0.
- **P1 2 resolvido, e a atribuição anterior cai no órgão:** `vazaAlheio` já
  comparava contra a nota, portanto não derrubava `método`/`degrau` que ela
  contém. A proibição nominal em `sistemaInstigar` era a causa. A nova regra de
  procedência e `dobrada` devolveram as palavras do autor em **3/3** no 4.3 e
  **3/3** no 4.5, inclusive quando a nota usa `metodo` sem acento.
- **P1 3 mudou, mas não fechou:** o texto magro não ganha mais um episódio
  concreto. Em compensação, no 4.3 as três saídas deixam de pedir *quando* e
  devolvem perguntas vagas como “O que era?”/“O que mudou de novo?”; no 4.5,
  duas de três também não pedem quando. A fixture pede que a pessoa nomeie o
  quê, quando e o que seria dar certo. Pergunta genérica é falha de atendimento,
  não um passe por não inventar.

### `contrapor`: falhas materiais novas ou remanescentes

- **P1 4 não fecha em toda a matriz:** no CSV, o 4.3 rep. 2 deixa `contra`
  vazio e só oferece JSON; não reconhece a razão que sustenta CSV nem nomeia
  limite real. No 4.5 rep. 2 há `Falha.semRetorno` apesar de HTTP 200 e
  “conteúdo completo”. Recusar ou não retornar onde há matéria a contrapor
  falha tanto quanto inventar.
- **P1 5 persiste:** no caso do notebook, 4.3 rep. 1 escreve “compromete renda
  futura”; o 4.5 escreve renda nas três repetições. A nota não declara renda.
  Isto viola também a instrução vigente (“Não atribua ... renda ... que ela não
  escreveu”); a lista do parser a deixa passar porque `renda` foi excluída dela.
- Há ainda indisponibilidade e retorno sem nexo: 4.3 rep. 1 de tudo-ou-nada é
  `Falha.semRetorno`; a rep. 2 fala em páginas e total diário, sem correr nem
  premissa correspondente. Não conto as duas regras extras do conferidor como
  defeito por si, mas estas saídas completas já reprovam por mérito.

### Scorecard de qualidade

| dimensão | instigar | contrapor | prova lida |
|---|---:|---:|---|
| aderência ao pedido | 8 | 4 | texto magro não pergunta quando; CSV e retornos vazios não contrapõem o que a nota sustenta |
| correção sustentada | 9 | 3 | episódio concreto não voltou; renda não dada e retorno sem nexo voltaram |
| utilidade concreta | 8 | 4 | perguntas vagas não avançam o texto magro; sem retorno e alternativa deslocada deixam a pessoa sem exame útil |
| adequação e divisão de trabalho | 8 | 5 | instigar ainda pede pouco do contexto magro; contrapor alterna exame útil com recusa/desvio |
| uso do contexto pertinente | 8 | 3 | método/degrau agora voltam 3/3; CSV e ausência de renda seguem desrespeitados |

Uma dimensão abaixo de 9 reprova; portanto **nenhuma operação volta a estar
disponível**. Não há hora de retorno. `instigar` fica em
`indisponivelPorQualidade` com motivo novo: **“no texto curto, a medida ainda
faz perguntas vagas e não pede quando aconteceu.”** `contrapor` fica com motivo
novo: **“a medida ainda inventa renda e às vezes não entrega contraponto onde a
nota dá matéria.”** Não há captura de cartão real: o LOTE-3 mediu a rota de
produção em JSONL, mas não fotografou uma resposta no cartão; como não há
aprovação, não fabriquei essa prova nem rodei nova chamada.

### Evidência e limite

- Lote e janela: `ferramentas/orca/lote-ia-09c.md` §§2–4 e
  `prova/lote09c-janela.log`.
- Saídas completas lidas: `prova/lote09c-q4-grok-4.3.jsonl` e
  `prova/lote09c-q4-grok-4.5.jsonl`.
- A causa atribuída está confirmada no candidato:
  `Sabia.vazaAlheio` dobra e compara texto do autor, enquanto
  `sistemaInstigar` manda a procedência; `fatoQueEleNaoDeu` ainda exclui
  deliberadamente `renda`. Os testes locais verdes e a contagem 3/3 medem esses
  guardas, mas não substituem esta leitura semântica.

## re-G3 — LOTE-5 (Q4-C): a volta REPROVA para mescla; `contrapor` está pronta para voltar, `instigar` não (10/09)

**Candidato:** `bff6d1a67733027869c1794afa8f23000af5d258`, branch `Vitorepf/q4-c`,
não mesclado. **Binário medido:** `264215af…`, da árvore de `d1773e1` (07:42:29
-03 = 10:42:29Z), comitado **antes** da janela (10:55:25Z). **Revisor
independente:** não escrevi os casos, não escrevi o conserto, não toquei no
`B91C8DEF`.

### Veredito, em três linhas

1. **A volta não mescla como está.** Duas dimensões abaixo de 9: **Correção 7** e
   **Contrato 8**. Nenhuma delas se conserta com medida nova — uma pede um
   pedaço de diff de fora, a outra pede uma frase.
2. **`contrapor` PODE VOLTAR pelo mérito.** Li as 36 execuções inteiras: os três
   defeitos do LOTE-3 caíram, o medo de que a guarda comprasse mudez **não se
   realizou e o inverso aconteceu**, e as cinco dimensões de `QUALIDADE-IA.md`
   dão 9 nas 36. O que falta não é qualidade: é **caso cego de quem não o
   escreveu** e a **captura com a hora** — e as duas exigem o aparelho da conta,
   que este despacho me proíbe de tocar. Recomendo a volta assim que existirem.
3. **`instigar` NÃO VOLTA, e a razão é maior do que a que o autor escreveu.** A
   promoção do *quando* comprou, além da diluição que ele mediu, **dois defeitos
   que o relatório não nomeia** — e um deles viola uma linha do contrato que
   continua viva no mesmo prompt.

### O que eu rodei, e a corrida que joguei fora

Build **LIMPO** (`rm -rf build` + `xcodegen generate` + `xcodebuild test`, que
compila app **e** pacote de testes numa passada) e suíte integral, sempre por
`ferramentas/orca/com-trava.sh`, no **`34CC3F94`** (aparelho de trabalho, que
encontrei ligado e deixei ligado). **Não toquei no `B91C8DEF`.**

```
[11:45:15Z] LIMPANDO build/ (build LIMPO, nao incremental)
warnings=1 errors=0
Traco/Notas/NotasView.swift:806:30: warning: '+' was deprecated in iOS 26.0
```

O único aviso é o herdado de `main`, dívida de outra volta. **Contagem sobre
build que compilou tudo**, como manda a lei de 09/09.

**A primeira corrida da suíte saiu CONTAMINADA e eu a descartei.** Ela acusou
seis testes vermelhos — e um deles, `RespostaNotasTests.oModeloDaRotaPassaPelaSonda()`,
**não existe nesta árvore**: `git log -S` o encontra em `319e9a5` (Q3-C), e
`git merge-base --is-ancestor 319e9a5 HEAD` diz que não é meu ancestral. Logo o
pacote que rodou no meu UDID não era o meu. Às 08:49 vi por quê: um
`xcodebuild test -destination id=34CC3F94` (pid 83730) rodando **com
`/tmp/traco-instrumento.lock` inexistente**, enquanto a MAC-2-A esperava na fila
do `com-trava.sh`. Escalei na hora. Refiz com sonda de isolamento antes e depois:

```
[11:52:39Z] xcodebuild alheios no meu UDID ANTES: 0
[11:54:13Z] xcodebuild test saiu 0
-- isolamento: o teste FANTASMA da Q3-C apareceu? 0  (0 = corrida limpa)
-- isolamento: a suite NOVA desta volta rodou? 2  (>0 = e o meu pacote)
✔ Test run with 1025 tests in 164 suites passed after 88.948 seconds.
** TEST SUCCEEDED **
```

**A alegação do autor — 1025 testes em 164 suítes, verdes — está confirmada por
corrida minha.** Fica a lição de instrumento: *"suíte verde" só vale colando a
contagem E provando que um teste exclusivo da própria árvore apareceu no log* —
sem a segunda metade, a minha primeira corrida teria virado seis achados falsos
contra este candidato.

### Os números do autor, recalculados do zero

Não conferi a tabela dele: reescrevi a conta a partir do JSONL cru e comparei.

| o que ele afirma | o que a minha conta deu | bate? |
|---|---|---|
| mesma fixture, SHA `ed9267c1…` | os **quatro** JSONL (base e agora) trazem `ed9267c19b26dc61…` | sim |
| 72 execuções de cada lado | 36 `casoConcluido` por arquivo × 2 = 72 e 72; 18 `instigar` + 18 `contrapor` em cada | sim |
| HTTP 200 em tudo, modelo respondido = modelo pedido | 36/36 `statusHTTP 200` nos quatro; `modeloRespondido` = `grok-4.3`/`grok-4.5` conforme o arquivo | sim |
| `semRetorno` com 200: 2 → 0 | 2 → 0 | sim |
| renda que a nota não declara: 4 → 0 | 4 → 0 | sim |
| conferidor mecânico INALTERADO | `shasum` do `lote-ia-09c-guardas.py` no candidato = `shasum` em `7d5e482`: `f27c0766…` idêntico; `git diff` vazio | sim |
| ancoradas 49/51 → 48/63 (`4.3`) e 59/61 → 63/71 (`4.5`) | **49/51 → 48/63** e **59/61 → 63/71**, ao grafema | sim |

**E a conferência que ele não fez, que era a que podia derrubar tudo:** o
`semRetorno` cair de 2 para 0 podia ser mera troca de rótulo — o mesmo desfecho
deixando de ser erro e virando saída vazia. **Não é.** A saída vazia também
sumiu:

| campos vazios nas 18 execuções de `contrapor` | LOTE-3 | LOTE-5 |
|---|---|---|
| `grok-4.3` | 14 de 54 (`contra` 3, `foraDaLista` 4, `outroCampo` 7) | **9 de 54** (`contra` **0**) |
| `grok-4.5` | 3 de 54 | **0 de 54** |
| execuções com os três campos cheios | 8/18 e 17/18 | **10/18 e 18/18** |
| execuções com os três campos VAZIOS | 1 e 1 (as duas do `semRetorno`) | **0 e 0** |

O medo declarado em 09/09 — pôr `"renda"` na lista compraria a recusa covarde —
**tinha o sinal trocado: a colheita subiu.** E a sonda prova que quem fez o
trabalho foi o prompt, não a guarda: em 72 execuções a guarda apagou **uma** vez
(`foraDaLista · tamanho`), e **nenhuma** por `fato que ele não deu`.

### As duas conferências duras que o despacho pediu

**1. A coluna nova correu na base?** Correu, e com o mesmo código. Não aceitei o
`prova/lote09e-medida.txt` como prova: importei o `conteudo()`/`VAZIAS` do
`lote-ia-09e-q4c.py` comitado e recontei os quatro arquivos — os quatro números
bateram exatamente, inclusive a exclusão do `q4-instigar-texto-magro`, que é
onde o cabeçalho do medidor declara que a coluna **não se lê** (a nota é "Não
deu certo de novo.", sem palavra de conteúdo, e genérica é o desfecho certo).

*Uma ressalva, que não reprova mas tem de ficar escrita:* o medidor foi **editado
depois da janela** (`bff6d1a` mexe em `lote-ia-09e-q4c.py`), e uma das edições —
tirar `"última vez"` da régua do QUANDO — **baixou a nota da BASE**, não a do
candidato. Medi o efeito: com `"última vez"` dentro, a manchete seria **2/6 →
6/6** em vez de **1/6 → 6/6**. A justificativa está certa contra a letra da
fixture ("faça o autor NOMEAR o quando"; *"o que você tentou da última vez?"*
pede O QUÊ) e está declarada no cabeçalho do medidor — mas não na manchete da
ADR nem do relatório, e afinar a régua depois de ver o dado sempre pede que
quem afina diga para que lado a régua andou.

**2. O portão do Perfil morde por mutação?** Morde, nas **três** asserções e pelo
caminho REAL da tela. Troquei o `motivo` do `instigar` por uma frase de 92
caracteres com data e barra — o erro que o autor diz que o portão pegou nele —
e rodei só `TracoTests/PoliticaTests`:

```
✘ PoliticaTests.swift:75: Expectation failed: (m.count → 92) <= 80
✘ PoliticaTests.swift:76: Expectation failed: !((m → "em 10/09 …/lote09e").contains("/") → true)
✘ PoliticaTests.swift:106: Expectation failed: (linha → " — em 10/09 … · 10/09 · conserto: …")
                                               .contains(leitura → "perguntas de gabarito que não falam da sua nota")
✘ Test run with 7 tests in 1 suite failed after 0.036 seconds with 3 issues.
```

A terceira é a que importa: ela passa por `PerfilView.restoDa`, o helper da tela
de verdade, não por uma contagem de grupos. Mutação desfeita no mesmo comando;
`git diff` da árvore vazio.

### P1 — os dois defeitos de `instigar` que o relatório NÃO nomeia

O autor mediu a diluição e a nomeou com honestidade (96% → 76% e 97% → 89%). Ela
é real e eu a reproduzi. Mas ela **subestima** o dano, e a coluna dele (repetição
em que NENHUMA pergunta carrega palavra da nota) é grossa demais para pegar o
que segue.

**P1-A · A cláusula promovida expulsou a cobrança do MÉTODO, que é a razão de o
método existir.** Em `q4-instigar-com-metodo-decisao` a fixture cobra, por
escrito, que *"as perguntas cobram critério, evidência e custo de errar"*. Contei
as três pernas por repetição:

| as TRÊS pernas do método (critério + evidência + custo de errar) | LOTE-3 | LOTE-5 |
|---|---|---|
| `grok-4.3` | **3/3** | **0/3** |
| `grok-4.5` | 3/3 | **3/3** |

No `grok-4.3`, "custo de errar" **desapareceu das três repetições**, e em duas
delas some também o critério e a evidência. A coluna do autor marcou esse caso
como 1/3 (só a r2 ficou sem palavra da nota); a perda verdadeira é 3/3. E o
`sistemaInstigar` proíbe exatamente isto, na linha logo acima da que subiu:
*"O QUE COBRAR … MANDA nas perguntas: pelo menos duas o cumprem ao pé da letra,
e **nenhuma troca a cobrança por outra mais fácil**."* A cláusula promovida
trocou a cobrança por outra mais fácil.

**P1-B · A cláusula promovida faz o modelo SUPOR um episódio que a pessoa não
escreveu.** Três das notas ricas não descrevem episódio nenhum — uma decisão
pendente (a sala), uma crença sobre o mercado (o vídeo curto) e uma intenção
("quero começar a praticar espanhol"). Contei as perguntas que pressupõem um
episódio (`aconteceu`/`ocorreu`) **e** não carregam palavra da nota:

| perguntas que supõem um episódio que ela não escreveu | LOTE-3 | LOTE-5 |
|---|---|---|
| `grok-4.3` | **0** | **8** |
| `grok-4.5` | **0** | **1** |

Exemplos crus do `grok-4.3`: em `mesmo-texto-degrau-4`, `com-metodo-decisao` e
`premissa-incerta`, a repetição 2 abre com *"O que aconteceu? / Quando
aconteceu?"* sobre notas em que **nada aconteceu**. Isto não é diluição: é a
violação literal de uma linha que **continua viva no mesmo prompt**, quatro
linhas abaixo da promovida — *"Não suponha nenhum fato que ela não escreveu, nem
dentro da pergunta: nada de 'a tentativa anterior', 'o episódio de antes'"*. O
requisito novo e o requisito velho se contradizem quando a nota não tem episódio,
e o modelo obedece ao que está mais alto.

**A alavanca que o autor escreveu conserta os dois**, e é a mesma frase:
condicionar o requisito à MATÉRIA da nota. Isso reforça a decisão dele de não
aplicá-la antes de medir — e reforça também que **este pedaço do diff não deve
entrar em `main` como está**, porque quem vier depois herda a régua pior.

### P2 — a ADR fecha a espécie, mas a frase que a fecha não é verdadeira

A ADR 09s escreve: *"a espécie é 'guarda por campo que apaga e segue', e só esses
dois a têm: `parseMapa`, `parseVoltaram` e `parsePerguntaDeRecordar` recusam a
resposta INTEIRA no primeiro item inválido, que é honestamente não deu para
ler"*, e o teste `todosOsParsersDeListaSeguemAMesmaRegra` congela que *"os dois
da Lente eram os únicos fora do passo"*.

A separação de espécie está certa e o conserto está no lugar certo. **A
justificativa não está.** `Sabia.parseMapa` devolve `nil` em três caminhos em que
a resposta foi lida inteira e quem a recusou fomos nós:

- `guard titulos <= 1, !saida.isEmpty else { return nil }` — uma lista **vazia**,
  JSON perfeitamente legível, e uma lista com dois títulos, lida até o fim;
- em `Sabia.vestir`, `refinado.count == pendentes.count` — o modelo rotulou menos
  blocos do que pedimos, e nós jogamos a resposta inteira fora.

E o desfecho chega ao autor como **a frase que esta ADR existe para matar**:
`Sessao.swift:736` escreve *"a sábia não respondeu. o texto ficou como estava."*
sobre um HTTP 200 lido por inteiro. `vestir` **não está cortada** — é
`.grokDepoisBordo` na tabela `Politica`, rota viva hoje, ao contrário de
`instigar` e `contrapor`. `parsePerguntaDeRecordar` também recusa por guarda de
conteúdo (`Prova.vaza`) e não por ilegibilidade, embora ali o dano seja nenhum:
o ritual cai numa frase fixa, não numa acusação de silêncio.

Isto não é medida nova nem volta nova: é **uma frase da ADR a corrigir e uma
dívida a nomear com dono**. Mas enquanto a frase estiver escrita como está, a
próxima volta lê "a classe está fechada" e não olha para `vestir`.

### P3 — a tela do Perfil mudou, é alcançável hoje, e não tem captura

O limite que o autor declara é **verdadeiro e não desconta**: conferi em
`LenteView.swift:305` e `:325` que `Politica.aviso(_:)` responde **antes** da
chamada enquanto as duas operações estiverem cortadas, então
`Sabia.nadaPassouNaGuarda` é literalmente infotografável hoje. E parar a captura
ao ver a Q3-C instalando no mesmo `B91C8DEF` foi **acerto**, não falha.

Mas o limite cobre uma tela, não duas. **A linha do Perfil mudou nesta volta e é
alcançável hoje, sem conta**, e este branch não acrescenta uma única `.png`. O
substituto é forte — `PoliticaTests` passa pelo `PerfilView.restoDa`, exige a
frase nova e proíbe a data velha, e eu provei por mutação que ele morde — e por
isso a dimensão fica em 8, não abaixo. Eu também não a produzi: o `34CC3F94`
teve três voltas na fila o tempo todo, e captura de tela é artefato do G2 de quem
implementa, não do revisor.

### Mérito, operação por operação — as cinco de `QUALIDADE-IA.md`

Li as 72 saídas inteiras, não o hash.

**`contrapor` — 36 execuções, dois modelos**

| dimensão | nota | o que li |
|---|---:|---|
| aderência ao pedido | 9 | 18/18 nas guardas mecânicas nos dois modelos; nenhum algarismo alheio à nota nos três campos das 36; `burrice` aparece uma vez e como CITAÇÃO da tese dele (*"a tese de que recusar trabalho grande é burrice não remove o limite de capacidade"*), que é o oposto de devolver julgamento |
| correção sustentada | 9 | renda que a nota não declara: 4 → **0**; evidência fabricada não voltou; o contra se apoia no que ela escreveu (reserva de três meses, 18 parcelas, rendimento na conta) |
| utilidade concreta | 9 | colheita SUBIU (tabela acima); no caso do CSV, o limite real do formato passou a ser nomeado 2/3 no `4.3` (era 1/3) e **3/3** no `4.5` (era 2/3) — "separador", "vírgula" |
| adequação e divisão de trabalho | 9 | informação, nunca instrução; a decisão fica com ele em 36/36 |
| uso do contexto pertinente | 9 | a premissa sustentada é RECONHECIDA em 3/3 nos dois modelos no caso do CSV, que era o P1-4 do re-G3 anterior |

Ponto mais fraco, para o caso cego atacar: `q4-contrapor-razao-ja-sustentada`
r1 do `grok-4.3` reconhece a premissa e **não nomeia limite nenhum** — devolve a
razão dela um pouco mais formal. Não quebra requisito escrito; é a execução que
menos entrega das 36.

**`instigar` — 36 execuções, dois modelos**

| dimensão | `4.3` | `4.5` | o que li |
|---|---:|---:|---|
| aderência ao pedido | **7** | 9 | as três pernas do método 3/3 → **0/3** no `4.3`; a cláusula promovida trocou a cobrança por outra mais fácil, que o próprio prompt proíbe |
| correção sustentada | **7** | 9 | 8 perguntas supõem um episódio que ela não escreveu (era 0); no `4.5`, 1 |
| utilidade concreta | **8** | 9 | ancoradas 96% → 76%; média da pergunta caiu de 12,8 para 8,8 palavras — mais curtas e mais vazias |
| adequação e divisão de trabalho | **8** | 9 | *"O que aconteceu? / Quando aconteceu? / O que seria dar certo?"* como abertura de uma nota sobre uma decisão pendente |
| uso do contexto pertinente | **7** | 9 | 1 repetição de 15 sem nada da nota no `4.3`, 0 de 15 no `4.5` |

O que ficou **melhor e é para guardar**: no texto magro as três pernas saem 6/6
contra 1/6, e no `4.5` o efeito colateral quase não existe. A janela é uma
comparação de UMA alavanca e **o `grok-4.5` é claramente melhor que o `grok-4.3`
em `instigar`** — insumo pareado, como o autor diz, e agora com duas colunas
minhas confirmando o mesmo sentido (0 contra 8 episódios supostos; 3/3 contra
0/3 nas pernas do método).

### Scorecard das 15 dimensões

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | fecha a lacuna nomeada "a rota cala com HTTP 200"; diff do EVOLUCAO diz o que fechou e o que segue aberto |
| Contrato | **8** | ADR, SPEC, `Politica`, EVOLUCAO e `LETRAS-ADR` coerentes, letra 09s uma vez só (`grep -c "^| 09s"` = 1) — **menos** a frase do P2, que o código contradiz em `parseMapa`/`vestir` |
| Correção | **7** | 1025 testes em 164 suítes verdes em corrida MINHA, isolamento provado; portão do Perfil vermelho por mutação nas três asserções — **mas** P1-A e P1-B, medidos por mim, somados à diluição que o autor mediu |
| Jornada real | **8** | a linha do Perfil mudou, é alcançável e não tem `.png` (P3); a frase da Lente é infotografável e isso NÃO desconta |
| Design | n/a | nenhum token, layout ou movimento tocado; a frase entra num `LinhaDeEstado` que já existia |
| Simplicidade | 9 | três desfechos onde havia dois, sem tela nova nem passo novo para o autor |
| Movimento | n/a | nada anima |
| Componentes | n/a | nenhum componente novo |
| Acessibilidade | n/a | nenhuma superfície nova alcançável; a frase nova ainda não tem tela |
| Performance | n/a | nada em lista, editor ou parser de caminho quente |
| Privacidade e autoria | 9 | conferido no código: `guardasQueApagaram` grava só `chave · guarda`, nunca o texto; `AvaliacaoIA` é `#if DEBUG` do arquivo inteiro, logo nada disso existe em Release |
| Estado honesto | 9 | é o objeto da volta e o relatório o pratica: o defeito comprado está na ADR, no EVOLUCAO e na tela, com número; e parar a captura contaminada foi a decisão certa |
| Complexidade | 9 | +54/−21 linhas de código de produção fora de comentário, metade delas texto de prompt; `parseContraparte` encolheu |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | evidência citada, linha de resultado colada, defeito próprio declarado antes de eu perguntar |

### O que eu recomendo, em três pedaços

1. **Corrigir a frase do P2** — uma frase na ADR 09s e no comentário do teste,
   dizendo que a espécie está fechada mas que a MESMA frase de tela ainda sai de
   `vestir` sobre um 200 lido inteiro — e **nomear a dívida com dono**:
   `parseMapa` + `Sessao.vestirTudo`. É o diff mais curto que existe e não pede
   medida nenhuma.
2. **Segurar o pedaço do `sistemaInstigar`** (quatro linhas que entram, uma que
   sai) e a linha do Perfil do `instigar` que o acompanha. O resto da volta — o
   conserto da guarda (`parseContraparte`, `parsePerguntas`, `LenteView`,
   `AvaliacaoIA` e os testes), o `sistemaContrapor` e o `"renda"` — está medido,
   positivo e sem regressão, e deve entrar. Mesclar a cláusula promovida como
   está entrega à volta seguinte uma régua pior do que a de hoje; e como
   `instigar` segue cortada, segurá-la não tira nada do autor.
3. **Levar `contrapor` ao caso cego.** Pelo mérito ela passa. O que falta é o que
   `QUALIDADE-IA.md` exige de qualquer volta e nenhum revisor sem o aparelho da
   conta pode dar: casos novos de quem não os escreveu, e a captura com a hora.

### A frase a corrigir, escrita aqui para o autor não adivinhar

A correção do P2 é do autor, dentro da letra dele (09s). É esta frase, na ADR
2026-09-09s do `SPEC.md` e repetida no comentário do teste
`todosOsParsersDeListaSeguemAMesmaRegra`:

> "A espécie é **'guarda por campo que apaga e segue'**, e só esses dois a têm:
> `parseMapa`, `parseVoltaram` e `parsePerguntaDeRecordar` recusam a resposta
> INTEIRA no primeiro item inválido, **que é honestamente *não deu para ler***.
> […] e os dois da Lente eram os únicos fora do passo."

O que a torna falsa é a metade em negrito, não a separação de espécie: em
`parseMapa`, `!saida.isEmpty` e `titulos <= 1` disparam sobre uma lista **lida
até o fim**, e em `Sabia.vestir` o `refinado.count == pendentes.count` joga fora
uma resposta inteira porque ela veio curta. O que basta escrever no lugar:

> A espécie "guarda por campo que apaga e segue" só existe nesses dois, e é por
> isso que o conserto ficou neles. **Mas a FRASE errada na tela não acabou com a
> espécie:** `parseMapa` recusa por contrato uma lista lida até o fim (vazia,
> com dois títulos, ou mais curta que os blocos pendentes) e `Sessao.vestirTudo`
> escreve *"a sábia não respondeu. o texto ficou como estava."* sobre um HTTP 200
> inteiro. `vestir` é `.grokDepoisBordo` — rota **viva**, não cortada. Dívida
> nomeada, dono: a volta seguinte de `vestir`.

### A lição que este G3 deixa para a ESTEIRA: a porcentagem escondeu o caso que morreu

A diluição que o autor mediu está certa e é honesta — 96% → 76%. Mas ela é uma
**média sobre 63 perguntas**, e a média sobreviveu ao caso que morreu: em
`q4-instigar-com-metodo-decisao` o `grok-4.3` foi de **3/3 para 0/3** nas três
pernas que a fixture cobra por escrito, e isso aparece na média como "76%".
A régua que pega isso não é a porcentagem: é **contar, por caso e por repetição,
o requisito que a fixture escreveu**, e deixar o caso reprovar sozinho. É o que
`QUALIDADE-IA.md` já manda ("qualquer requisito obrigatório descumprido reprova
o caso, independentemente da média") e o que uma coluna agregada faz esquecer.

### Limites deste G3

- **Não escrevi caso cego** e não podia: caso cego exige corrida, corrida exige o
  `B91C8DEF`, e o despacho me proíbe de tocá-lo. Tudo o que eu chamo de mérito
  saiu das 72 saídas que já existiam, lidas inteiras.
- **Não fotografei nada.** As duas capturas que faltam são as do G2 do autor.
- **As minhas duas colunas novas são proxy**, como as dele: "supõe episódio"
  conta `aconteceu`/`ocorreu` sem palavra da nota, e "as três pernas" conta
  `critério`/`evidência`/`custo de errar` por expressão. Colei as saídas cruas de
  cada achado acima para que a leitura não dependa da minha regex.
- **Não corrigi uma linha de código.** A árvore está como o autor a deixou:
  `git status` limpo depois da mutação.
