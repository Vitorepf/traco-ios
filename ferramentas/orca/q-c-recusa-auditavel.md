# Q-C — por que o nosso parser recusou, dito por ele mesmo

Implementador, worktree `volta-q-qualidade`, 08/09/2026. ADR **2026-09-08p** em `SPEC.md`.

> **Corrigido pela volta Q-D (08/09, mesmo dia).** Três coisas deste relatório não valem mais:
> a letra da ADR era `08n` e colidia (virou `08p`); a recusa por vazamento **não emite mais o
> quadrigrama**, e sim posição e contagem de origem; e "as onze outras guardas não dispararam
> uma vez" caiu numa corrida nova. Leia `ferramentas/orca/q-d-origem-sem-vazamento.md`.

## O que o re-G3 pediu, e o que saiu

### 1. Motivo redigido da recusa — FEITO

`PraticaTrabalho.Recusa`: doze casos, cada um com uma linha `redigida` que abre pela
categoria (`forma`, `limite`, `repetição`, `exemplo`, `vazamento`), nomeia o campo e dá
uma medida — contagem, tamanho, índice do critério, nome de chave truncado em 32
caracteres. **Nenhum conteúdo bruto, nenhuma credencial.**

As regras não foram duplicadas: `lerPreparacao` e `provar` devolvem `Result<_, Recusa>` e
são a única cópia; `parsePreparacao` e `validar` viram `try? …get()`. Régua e motivo não
podem divergir porque são a mesma linha de código.

No caso do vazamento — e só nele — vai o **quadrigrama normalizado** que casou. Sem ele a
recusa diz "vazou" e não diz o quê, e a régua fica injulgável. São quatro palavras do
EXEMPLO, que por contrato é outro caso e nunca a resposta-alvo. `Prova.vazamento` devolve o
trecho e `Prova.vaza` passa a ser `vazamento(…) != nil`: uma implementação, dois usos.

Em DEBUG, `MotorTrabalho.prepararPratica` guarda a linha e a sonda retira com
`retirarRecusasDaPreparacao()`, no mesmo molde de `Grok.retirarDiagnosticos()`. A chave
`recusasDaPreparacao` só aparece no JSONL quando houve recusa.

### 2. Remedição dos três casos — FEITA, e o defeito é NOSSO

`C2416CBC`, install **por cima**. Nada de `erase`, `clearState`, `uninstall` ou
`xcodebuild test` nele; Safari intocado. Conta conferida por listagem **autenticada** de 12
modelos na abertura (20h55Z), em cada registro (`contaGrokLigada: true`) e no fecho
(`qc-fumaca-fecho`, 21h58Z, os mesmos 12). **A conta ficou ligada.**

Dois lançamentos: `2DFC05C3` (5 repetições dos dois casos) e `0065BE4A` (4, já com o
quadrigrama exposto). **18 execuções de `prepararPratica`, 18 HTTP 200 completos de
`grok-4.6`, 5 recusas nossas.**

| corrida | caso | exec. | motivo redigido |
|---|---|---:|---|
| 2DFC05C3 | revisor-sintetico-resumo-projeto-2x5 | 2 | vazamento · o critério 4 repete quatro palavras seguidas do exemplo |
| 2DFC05C3 | q2-conhecido-preparar-apresentacao-proposta | 1 | vazamento · o critério 5 repete quatro palavras seguidas do exemplo |
| 2DFC05C3 | q2-conhecido-preparar-apresentacao-proposta | 2 | vazamento · o critério 4 repete quatro palavras seguidas do exemplo |
| 2DFC05C3 | q2-conhecido-preparar-apresentacao-proposta | 3 | vazamento · o critério 4 repete quatro palavras seguidas do exemplo |
| 0065BE4A | revisor-sintetico-resumo-projeto-2x5 | 4 | vazamento · o critério 3 repete do exemplo as quatro palavras seguidas **“a dependencia ainda aberta”** |

**Cinco de cinco na mesma guarda.** As outras onze não dispararam uma vez.

**De quem é o defeito: nosso.** O pedido manda escrever três frases "separando o que foi
concluído, **a dependência** e o próximo passo". O critério que verifica isso precisa nomear
a dependência; o exemplo, que por contrato é outro projeto com fatos diferentes, ensina a
mesma estrutura com as mesmas palavras. **“a dependencia ainda aberta”** é vocabulário
estrutural da tarefa — está na instrução do autor antes de estar no exemplo. O modelo
cumpriu o que pedimos.

A raiz é uma importação com o `alvo` errado: em Recordar o `alvo` É a resposta e quatro
palavras dele entregam o jogo; em `provar` o `alvo` é o exemplo, que o nosso próprio prompt
manda ser de outro caso. Herdamos a régua sem a premissa.

**O parser NÃO foi alargado**, por ordem e por convicção: alargar contrato de validação é
volta própria e o revisor tem de ver a régua antes. **No RUMO, nomeado:** `Prova.vaza` em
`PraticaTrabalho.provar` usa o EXEMPLO como alvo e reprova vocabulário estrutural da tarefa
— 5 de 18 preparações completas em 08/09/2026. Decidir o alvo certo, escrever a régua nos
dois sentidos (o que deve passar e o que deve continuar recusado), e só então mexer.

### 3. O teste do teto — CORRIGIDO (a primeira das duas saídas)

`oTetoDeTrabalhoCobreAPiorLatenciaMedida` passava com `181`. Agora são três expectativas com
papéis separados: **piso observado** `>= 179` (a pior execução inteira medida é 178,144 s),
a lápide dos 90 s, e a **decisão** `== 240`, com a mensagem dizendo que mudar o número é
mudar a ADR e trazer medida nova ao lado. O comentário que chamava 141 s de "pior latência"
foi corrigido: 141,058 s é a chamada isolada mais lenta; 178,144 s é a execução de ponta a
ponta com duas chamadas.

## Prova

- `prova/qc-recusa-avaliacoes.jsonl` — as três corridas inteiras (`fcc017f0…` na cópia do 2º lançamento; o arquivo final inclui a fumaça de fecho)
- `prova/qc-recusa-casos.json` `df2fc8bb…` · `prova/qc-recusa2-casos.json` `5a65ccdf…`
- Suíte no `34CC3F94`, `-parallel-testing-enabled NO`:
  `✔ Test run with 916 tests in 149 suites passed after 9.396 seconds.` · `** TEST SUCCEEDED **`
  (915 antes; o teste novo é `cadaRecusaDaPreparacaoDizQualGuardaFoiSemVazarOConteudo`)
- Build no `34CC3F94`: `** BUILD SUCCEEDED **`

## Estado em que deixo o aparelho do Grok

`C2416CBC` ligado, com o binário desta branch instalado por cima e a conta **ligada**
(12 modelos autenticados às 21h58Z). Não rotacionei, não mexi em tamanho de letra, não
toquei no Safari, não desliguei simulador nenhum. Nenhuma sessão de `orca emulator` foi
aberta — a prova é JSONL da sonda, não captura. Não trouxe `main`.

## O que esta volta não fez

Não reabri o corte das sete. Não reativei `responderNasNotas`. Não toquei em
`Traco/Perfil/**`. Não alarguei o parser. Não julguei a qualidade dos treze exercícios que
passaram — medi quem recusou e por quê, não se o que entrou serve. Não abri a jornada na
tela: a recusa foi medida pela sonda, e `pratica-preparacao-indisponivel` nesta ocorrência
real continua sem foto.

## Scorecard (meu; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 9 | onze guardas viram doze motivos redigidos, régua e motivo na mesma cópia; o defeito nomeado com o quadrigrama na mão |
| Correção | 9 | 916 testes verdes; o teste do teto agora reprova `181` e trava `240` |
| Jornada real | 7 | a recusa foi medida no aparelho do dono pelo caminho de produção, mas a tela do `praticaIndisponivel` não foi fotografada nesta ocorrência |
| Performance | 9 | 18 de 18 chamadas completas sob o teto de 240 s; nenhuma encostou |
| Estado honesto | 9 | a recusa deixou de ser `nil`; a ADR diz que o defeito é nosso e que 18 execuções não são a distribuição |
| Privacidade e autoria | 9 | sem bruto, sem credencial; só categoria, campo e medida — o quadrigrama é do exemplo, que por contrato é outro caso |
| Simplicidade | 9 | duas funções novas e um enum; `parsePreparacao`/`validar` viram uma linha cada; nenhum passo novo para o autor |
| Demais dimensões | n/a | volta de motor, sem mudança de view, componente, movimento ou fora do app |
