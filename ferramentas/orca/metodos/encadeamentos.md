# Encadeamentos entre os métodos propostos

Trilha Métodos · escrito na M4, atualizado na M5 · 06/09/2026.

Um método sozinho é uma folha. O que faz do catálogo uma coleção é um método
levar ao outro com as palavras do autor já dentro. Até a M2, cada candidato
encadeava só com os 21 antigos; esta rodada liga os novos entre si.

## A REGRA, e ela não é opinião

Li o código antes de escrever qualquer encadeamento
(`Traco/App/Sessao.swift`, `encadear`, e `Traco/Pagina/CamposFormaView.swift`):

- `Sessao.encadear` faz `guard let destino = Gesto(rawValue: para),
  destino.conhecido else { return }` — se o método de destino **não está no
  catálogo, a função sai em silêncio**;
- mas a UI desenha um botão para **cada** encadeamento, e só apaga o que ainda
  não tem os campos exigidos (`exige`). O destino não é conferido.

**Logo: um encadeamento cujo destino ainda não foi colado vira um botão que
acende e não faz nada.** Não quebra teste, não dá erro, não avisa ninguém — só
frustra quem toca.

Daí a regra que esta trilha passa a seguir:

> **Um encadeamento só entra na mesma leva do destino, ou depois dele.**

E a sugestão para uma volta de app, pequena: `encadeamentosProntos` (e a lista
da view) deveriam filtrar também por destino conhecido, para que um catálogo do
autor com um método faltando não gere botão morto. Está em
[`achados-catalogo.md`](achados-catalogo.md).

## O que entra em cada leva

| leva | o que é colado | encadeamentos que podem ir junto |
|---|---|---|
| **M3** (aprovada) | os 4 da M1 | os deles para os 21, mais os 2 **entre eles**: Classe de referência → Cinco porquês, e Cinco porquês → Subtração |
| **depois, se o dono aprovar a M2** | os 3 da M2 | os deles para os 21 e para os 4 da M1 (que já estarão lá): Hamming → Subtração, O que não se vê → Subtração, Exame da noite → Coluna da esquerda |
| **depois, se aprovar a M4** | os 3 da M4 | os deles para os 21 e para a M1: Ordem de grandeza → Classe de referência, Começaria hoje? → Subtração |
| **depois, se aprovar a M5** | os 2 da M5 | os deles para os 21 e para a M1: O combinado → Coluna da esquerda; O ponto que decide → Steelman e Atualização |

Cada leva só aponta para trás. **Nenhum encadeamento escrito hoje aponta para
um método que ainda não foi colado** — conferido por teste, em três cenários,
com zero botão morto.

## O mapa inteiro

Todos os encadeamentos dos dez propostos, do jeito que estão no JSON das fichas.
"o que leva" é `campo de origem`→`campo de destino`: são as palavras do autor,
copiadas; a IA não escreve nada aqui.

| de | rodada | para | tipo | o que leva |
|---|---|---|---|---|
| Subtração | M1 | premortem | para os 21 | `sai`→`plano` |
| Subtração | M1 | compromisso em 14 dias | volta | — |
| Coluna da esquerda | M1 | seEntao | para os 21 | `impediu`→`se`, `diria`→`entao` |
| Coluna da esquerda | M1 | steelman | para os 21 | `disse`→`contraria` |
| Classe de referência | M1 | premortem | para os 21 | `estimo`→`plano` |
| Classe de referência | M1 | compromisso em 30 dias | volta | — |
| Classe de referência | M1 | cincoPorques | **entre os novos** | `parecidos`→`aconteceu` |
| Cinco porquês | M1 | seEntao | para os 21 | `controlo`→`se`, `mudo`→`entao` |
| Cinco porquês | M1 | compromisso em 30 dias | volta | — |
| Cinco porquês | M1 | subtracao | **entre os novos** | `aconteceu`→`melhorar`, `controlo`→`sai` |
| A pergunta de Hamming | M2 | spec | para os 21 | `ataque`→`problema` |
| A pergunta de Hamming | M2 | compromisso em 7 dias | volta | — |
| A pergunta de Hamming | M2 | subtracao | **entre os novos** | `trabalhando`→`melhorar`, `ataque`→`ia` |
| O que se vê e o que não se vê | M2 | decisao | para os 21 | `ato`→`escolha`, `naoVejo`→`criterio` |
| O que se vê e o que não se vê | M2 | compromisso em 30 dias | volta | — |
| O que se vê e o que não se vê | M2 | subtracao | **entre os novos** | `ato`→`melhorar` |
| Exame da noite | M2 | seEntao | para os 21 | `naoRepito`→`se`, `regra`→`entao` |
| Exame da noite | M2 | compromisso em 7 dias | volta | — |
| Exame da noite | M2 | colunaEsquerda | **entre os novos** | `naoRepito`→`comQuem` |
| A nota do fato contrário | M4 | atualizacao | para os 21 | `contra`→`acredito`, `fato`→`descer` |
| A nota do fato contrário | M4 | argumento | para os 21 | `contra`→`tese`, `fato`→`objecao` |
| Ordem de grandeza | M4 | classeDeReferencia | **entre os novos** | `quantidade`→`estimo` |
| Ordem de grandeza | M4 | compromisso em 30 dias | volta | — |
| Começaria hoje? | M4 | decisao | para os 21 | `oQue`→`escolha`, `porque`→`criterio` |
| Começaria hoje? | M4 | subtracao | **entre os novos** | `oQue`→`melhorar`, `oQue`→`sai` |
| Começaria hoje? | M4 | compromisso em 30 dias | volta | — |
| O combinado | M5 | compromisso em 7 dias | volta | — |
| O combinado | M5 | colunaEsquerda | **entre os novos** | `quem`→`comQuem`, `resposta`→`disse` |
| O ponto que decide | M5 | steelman | para os 21 | `dele`→`contraria` |
| O ponto que decide | M5 | atualizacao | para os 21 | `minha`→`acredito`, `meuCrux`→`descer` |

## Por que cada ligação entre os novos existe

**Classe de referência → Cinco porquês.** A lista dos casos parecidos raramente
é neutra: quando três dos quatro terminaram atrasados, a pergunta seguinte não é
de estimativa, é de causa. O campo `parecidos` cai inteiro no `aconteceu`.

**Cinco porquês → Subtração.** A causa que o autor controla quase sempre é uma
peça a mais no sistema: uma etapa, uma trava que não existe, um passo manual. O
`controlo` cai no `sai` da Subtração — o método que vem depois já abre sabendo o
que tirar.

**A pergunta de Hamming → Subtração.** É a ligação mais importante do mapa.
Escolher o problema importante sem tirar nada da mesa é fantasia: o `ataque`
entra como "o que eu ia acrescentar" e o `trabalhando` como "o que já existe" —
a Subtração então cobra o que sai para o ataque caber. Sem isso, a Pergunta de
Hamming produz uma lista bonita e nenhuma mudança.

**O que se vê e o que não se vê → Subtração.** Quando o não visto é caro, o
passo seguinte não é decidir de novo: é cortar. O `ato` vira o objeto do corte.

**Exame da noite → Coluna da esquerda.** O ato de que se arrepende à noite é,
quase sempre, uma conversa. O `naoRepito` entra como "a conversa", e a Coluna
abre para o que ficou por dizer. Dois métodos de rodadas diferentes que se
encaixam sem ajuste.

**Ordem de grandeza → Classe de referência.** São o par de uma coisa só: sem
casos parecidos, decomponha em fatores; com casos, use os casos, que são
melhores. Quem começa pelos fatores e descobre que tem história deve trocar de
método, e o botão diz isso.

**Começaria hoje? → Subtração.** Quando a resposta é parar, o que sai é a coisa
inteira, e a Subtração cobra o que se perde tirando — que é o que impede a
parada de virar arrependimento no mês seguinte.

**O combinado → Coluna da esquerda.** É a rota real de um combinado mal feito:
primeiro o prazo estoura, depois a conversa azeda. O `quem` e a `resposta` entram
na Coluna, que abre para o que ficou por dizer. Os dois métodos são de rodadas
diferentes e do mesmo problema, visto antes e depois.

## O que eu NÃO liguei, e por quê

Encadeamento inventado é pior que encadeamento faltando: vira botão que ninguém
toca, e ensina o autor a ignorar a linha "DEPOIS DISTO".

- **Subtração → qualquer um dos novos.** A Subtração termina numa decisão de
  corte; o que vem depois dela é o Pré-mortem, que já está ligado. Não achei
  ligação honesta para a frente.
- **Coluna da esquerda → Cinco porquês.** Tentador ("por que essa conversa
  sempre termina assim?"), mas os Cinco porquês são para sistema que se repete,
  e conversa com uma pessoa não é sistema. A causa acabaria sendo a pessoa — o
  que o próprio método dos Cinco porquês proíbe.
- **A nota do fato contrário → qualquer um dos novos.** Ela alimenta a
  Atualização e o Argumento, que são dos 21. Entre os novos não achei destino
  que não fosse forçado.
- **O ponto que decide → O combinado.** Um desacordo resolvido às vezes vira
  combinado, mas às vezes vira só entendimento — e forçar o botão empurraria o
  autor a fechar acordo onde ele só queria entender. Fica de fora.
- **Qualquer um dos 21 → um dos novos.** Não toquei em método antigo. Se o dono
  quiser (por exemplo, Decisão → Classe de referência antes de escrever o que
  espera), é uma volta de edição do catálogo, com o mesmo cuidado de ordem.

## Segunda passada, para quando as levas seguintes entrarem

Estes encadeamentos **não estão no JSON de ninguém** porque o destino ainda não
existe. Ficam aqui para a volta que colar a leva correspondente:

| de | para | quando pode entrar | o que leva |
|---|---|---|---|
| Coluna da esquerda (M1) | Exame da noite (M2) | quando a M2 entrar | `comQuem`→`naoRepito`: a conversa vira o ato do dia a julgar |
| Classe de referência (M1) | Ordem de grandeza (M4) | quando a M4 entrar | `estimo`→`quantidade`: sem casos parecidos, decompor em fatores |
| Subtração (M1) | Começaria hoje? (M4) | quando a M4 entrar | `melhorar`→`oQue`: quando o corte é grande demais para ser corte |
| O que se vê e o que não se vê (M2) | Começaria hoje? (M4) | quando a M4 entrar | `ato`→`oQue`: o custo invisível de continuar |
| Coluna da esquerda (M1) | O combinado (M5) | quando a M5 entrar | `comQuem`→`quem`: a conversa que azedou porque nada foi combinado |

Cada um deles é uma linha no array `encadeamentos` do método de origem, que já
estará no `Metodos.json`. **Editar método já colado exige o mesmo teste de
sempre** — e, no caso da Coluna da esquerda, exige também não mexer na posição
dela no arquivo (ver a regra de ordem em `achados-catalogo.md`).
