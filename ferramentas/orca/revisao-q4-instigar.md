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
