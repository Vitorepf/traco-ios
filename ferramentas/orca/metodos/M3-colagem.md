# Volta M3 — a colagem, e o que o implementador conferiu por conta própria

ADR 2026-09-06e · 06/09/2026 · worktree `volta-m3-colagem`.

As fichas dos sete e a régua da proveniência são da trilha Métodos e vivem no
branch `Vitorepf/metodos-m1` (`ferramentas/orca/metodos/`). Este arquivo é só o
que ESTA volta fez com elas — para não duplicar, e para não editar ficha que
outra volta ainda está escrevendo.

## O que entrou

Os sete, **no FIM** do `Traco/Modelo/Metodos.json`, nesta ordem:

| # | id | nome | faculdade | rodada |
|---|---|---|---|---|
| 22 | `subtracao` | Subtração | simplificação | M1 |
| 23 | `colunaEsquerda` | Coluna da esquerda | relação | M1 |
| 24 | `classeDeReferencia` | Classe de referência | previsão | M1 |
| 25 | `cincoPorques` | Cinco porquês | causa | M1 |
| 26 | `perguntaHamming` | A pergunta de Hamming | direção | M2 |
| 27 | `vistoNaoVisto` | O que se vê e o que não se vê | consequência | M2 |
| 28 | `exameDaNoite` | Exame da noite | caráter | M2 |

Os blocos `json` das fichas entraram **sem uma letra reescrita**. Conferido: o
arquivo antes e depois é idêntico nos 21 primeiros métodos, exceto a regex do
Se–então (o conserto aprovado), e os ids ficam na mesma posição.

## A verificação de duplicação — feita aqui, contra o catálogo na tela

A trilha já rejeitou seis candidatos por duplicação. Estes três foram conferidos
de novo, porque a tarefa mandou não aceitar a palavra do pesquisador:

**Exame da noite × Dia.** Não duplica. O Dia julga a EXECUÇÃO do dia (a única, as
três seguintes, o que roubou o dia — o ladrão é de fora); o Exame julga os ATOS
DO AUTOR (o que eu fiz e não quero repetir, o que contive, a regra). Faculdades
`foco` e `caráter`. As regex não colidem: o Dia pega `hoje eu (preciso|tenho
que|vou)`, o Exame pega `hoje eu (fiz|reagi|tratei)` — verbos disjuntos.

**Exame da noite × Expressiva.** Não duplica, e o limite é a ORDEM, não a regex.
A Expressiva é desabafo sem forma, sem campo e sem pergunta; o Exame é
julgamento com quatro campos e uma regra concreta no fim. Medido: o desabafo
longo com "me arrependi" dentro continua caindo na Expressiva, porque ela vem
antes e só ela é considerada acima de 120 caracteres. Uma frase CURTA de
julgamento ("perdi a paciência com o time hoje") ia para o Exame, e esta volta
dizia que isso "é o certo".

**Estava errado, e a colagem com main corrigiu.** Essa frase é confissão de
conduta, e a guarda das ADRs 2026-09-06h/06i a cala: ela fica do autor e não
vira exercício nenhum. O Exame da noite continua existindo, mas quem chega nele
é quem convoca o método ("exame da noite", "passei o dia em revista") ou quem
escreve "hoje eu (fiz|reagi|tratei)" fora de contexto de confissão — o segundo
ramo inteiro dele (`não devia ter …`, `me arrependi`, `fui …`) está fechado, 9
de 9 sondas caladas. É o preço da proteção, e está medido em
`todoRamoDeRegexAlcancaOSeuMetodo`.

**O que se vê e o que não se vê × Inversão e Pré-mortem.** Não duplica. A
Inversão e o Pré-mortem imaginam a FALHA de um plano (como garanto que falhe /
um ano depois já falhou). Bastiat nomeia o que DEIXA DE ACONTECER porque um ato
aconteceu — custo, não falha, e sobre algo que está acontecendo, não sobre um
plano. Regex sem interseção.

**A pergunta de Hamming × Decisão e Primeiros princípios.** Não duplica. A
Decisão escolhe entre opções com um critério; Hamming pergunta se o que se faz
está entre os problemas importantes do campo e se há ATAQUE para algum. Os
Primeiros princípios separam o verificado do herdado — outro eixo inteiro.

**Nenhum dos sete foi recusado.** Os três foram conferidos e passam.

## O achado meu: uma regex que nasce inalcançável

`\bolhando o dia de hoje\b`, do Exame da noite, **nunca dispara**: o Dia casa
antes com `\bo dia de hoje\b`, e o Dia está na posição 14 enquanto o Exame está
na 28. Medido:

```
dia    «olhando o dia de hoje, o que eu fiz que não quero repetir»
```

**Não é regressão** — a frase já ia para o Dia antes desta volta, e a alternativa
inalcançável não causa falso positivo nenhum. Deixei a regex como a ficha a
mediu (a regra do contrato é não reescrever bloco medido) e nomeei o caso: é da
mesma família dos cinco desvios pré-existentes — regex larga e cedo comendo
regex específica e tarde — e vai para a volta de roteamento junto deles.

## O que esta volta NÃO fez, de propósito

- **Os cinco desvios pré-existentes.** `(?m)^quero` do WOOP engolindo Pré-mortem,
  Feynman, Primeiros princípios e Prática deliberada; `ideia` da Nota permanente
  engolindo Destilar. Medidos pela trilha, não causados por ela, e mexer no WOOP
  muda um método que o dono usa: é escolha dele. Com o meu, são seis.
- **A correção da UI do botão de encadeamento sem destino.** O dado está
  guardado (nenhum encadeamento colado aponta para id inexistente, com teste que
  trava); a tela — não acender o botão — é outra volta, porque `Sessao.swift`
  está aberto em duas voltas hoje.
- **Os encadeamentos "à espera da leva do destino"** (`encadeamentos.md`, última
  tabela). Ficam fora: os destinos deles são da M4, que não entrou.
  A ligação Coluna da esquerda → Exame da noite poderia entrar (o destino veio
  nesta mesma leva), mas exige editar um bloco já colado — fica para quem colar
  a M4, junto das outras três.
- **A M4** (A nota do fato contrário, Ordem de grandeza, Começaria hoje?) e a M5.

## As três frases de honestidade nos 21 antigos

Da régua da proveniência (`regua-da-proveniencia.md`, trilha Métodos): três
fichas declaravam grau de origem acima do real — obra real citada ao lado de um
procedimento que não está nela. Nenhuma sai do catálogo; o movimento das três é
bom. Antes → depois:

**Decisão** (`proveniencia.fonte`)

- antes: "Diário de decisão, prática divulgada por Daniel Kahneman; derivado de
  Kahneman e Gary Klein, Conditions for Intuitive Expertise (2009)"
- depois: "Diário de decisão: prática atribuída a Daniel Kahneman, sem texto
  dele que a descreva. Kahneman e Gary Klein, Conditions for Intuitive Expertise
  (2009), tratam de quando a intuição de especialista é confiável — é evidência
  vizinha sobre julgamento, não a origem deste método."

**Primeiros princípios** (`proveniencia.adaptacao`)

- antes: "O que acho que sei, o que é verdade de fato, o que construo do zero."
- depois: "Aristóteles não propõe este exercício; o Traço toma dele a noção de
  princípio e monta o resto: o que acho que sei, o que é verdade de fato, o que
  construo do zero."

**Inversão** (`proveniencia.fonte`)

- antes: "Charlie Munger, discursos (1986 em diante), citando Carl Jacobi:
  inverta, sempre inverta"
- depois: "Charlie Munger, discursos (1986 em diante), sem transcrição de
  referência localizada, citando uma frase atribuída a Carl Jacobi: inverta,
  sempre inverta"

O campo `funcao` dos três já estava certo (`pratica`, `lente`, `lente`) e a
linha `evidencia` já dizia que não há estudo — a inflação estava só na `fonte` e
na `adaptacao`. Nada mais foi tocado.

## A prova

| o que | resultado |
|---|---|
| build (`generic/platform=iOS Simulator`) | `** BUILD SUCCEEDED **`, sem aviso |
| `CatalogoTests` | 20 testes, `✔ Test run with 20 tests in 1 suite passed after 0.041 seconds` |
| suíte integral (iPhone 17 Pro Max 6033B043) | `✔ Test run with 723 tests in 125 suites passed after 10.307 seconds` · `** TEST SUCCEEDED **` |
| `maestro/metodos-m3.yaml` | verde: Perfil diz "28 do app", proveniência do Exame da noite abre |
| roteamento, 74 frases, os 7 no fim | 0 desvio |
| roteamento, 74 frases, os 7 antes da Especificação | a Coluna da esquerda rouba o desabafo da Expressiva |
| encadeamentos | 0 botão morto, 28 ids únicos |

Os quatro testes novos em `TracoTests/CatalogoTests.swift`:

- `oSeEntaoNaoCasaDentroDeOutraPalavra` — fixa o conserto do `\b`;
- `osSeteNovosRoteiamParaSiMesmos` — 14 frases dos sete, mais 5 dos 21 que eles
  não podem roubar;
- `oDesabafoLongoContinuaExpressivo` — a proteção da escrita pessoal, e cai se
  alguém mover um dos sete para cima da Expressiva;
- `nenhumEncadeamentoApontaParaMetodoInexistente` — a guarda contra botão morto,
  sobre `Catalogo.todos` (inclui a pasta do autor).

Mais dois ajustados por consequência: `oBundleTemOsVinteEOitoMetodos` (era 21, e
agora fixa também a ordem dos sete no fim) e, em
`TracoTests/ColheitaRestanteTests.swift`, a lista fechada de formas com campo de
volta ganhou `classeDeReferencia` — o campo "Como terminou de fato" é o desfecho
que alimenta a classe da próxima vez, e o `default` de `Volta.devida` já o cobra
sete dias depois, sem código novo.

## Uma observação que não é da colagem, mas é do catálogo

Na tela, **quem roteia primeiro não é a regex**. Com Apple Intelligence ligada e
sem conta Grok, `AnaliseDeBordo` decide antes e o veredito dele vence
(`Sessao.escolher`, ADR 04c). Provado aqui: "perdi a paciência na reunião e me
arrependi" virou Expressiva pelo modelo, e "quais são os problemas importantes
do meu campo" virou Analogia — quando a regex do catálogo daria Exame da noite e
Pergunta de Hamming.

Isso **não é defeito desta volta e não é defeito do modelo**: é a escada de três
degraus por desenho. E há uma boa notícia dentro: o esquema do degrau de bordo
nasce de `Catalogo.todos` em tempo de execução, então os sete já estão na lista
fechada dele e nas instruções, sem código. O que a volta fixa por teste é o
degrau determinístico, que é o piso — e o piso é o que garante a proteção da
Expressiva quando o modelo cala.


## A colagem com main (volta M3-C, 06/09/2026)

- `git merge main` com as voltas V16, F3b, a voz, V11, A5 e V18 dentro;
  conflito só em SPEC.md e EVOLUCAO.md, resolvido mantendo tudo (a ADR 06e
  entrou entre a 06c e a 06f).
- `aEscritaPessoalNaoChegaVestidaDeMetodo`, o vermelho de propósito desta
  volta, **passou** — nenhuma das 22 sobrou, sem uma linha de `Traco/Analise`
  tocada aqui.
- `conhecidos` remedido do zero: **18 desvios**, não 14 nem 4. Os 4 antigos
  seguem vivos e os 14 da guarda são exatamente os que a 06h previu — a A5 e as
  06i-B/C/D não mudaram a conta.
- Duas frases desta volta morreram e **estavam erradas**: `osSeteNovosRoteiamParaSiMesmos` pedia que "perdi a paciência na reunião e me arrependi" e "fui
injusto com o time hoje de manhã" virassem exercício. Trocadas por três que
convocam o Exame sem confessar nada.
- As sete portas ganharam régua: 14 frases de trabalho novas em
  `EscritaPessoalTests.trabalho` (58 → 72), para `todaPortaDeMainTemPeloMenosDuasFrases` cobrir 28 portas em vez de 21.
- Suíte integral **785/0 em 130 suítes**, build do app limpo.
- `maestro/metodos-m3-tom.yaml` reapontado: a entrada era "Perdi a paciencia
  com ela hoje. Me arrependi e chorei.", hoje calada pela guarda. Trocada por
  "Exame da noite: o que do dia de trabalho eu nao repito amanha." Fluxo verde
  (saída 0) no iPhone 17 Pro (teste 2), com controle negativo provando que a
  asserção roda (saída 1 com a frase trocada por uma inexistente); tela em
  `ferramentas/orca/m3c-01-tom-do-cartao-exame.png`.
