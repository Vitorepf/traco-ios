# E6b — o tipo de relação entre notas: a corrida de 17/09 não está no repositório

**Papel:** LEITOR. Não rodei nada, não toquei código do app, não mexi em desenho.
**Data:** 17/09/2026, tarde. **Pedido:** achar a saída da corrida do meio-dia no
iPhone Air, comparar com as barras fixadas antes dela, dizer o que passou e o que
falhou.

---

## O veredito, numa linha

**Não dá para fechar o número: a saída dessa corrida não existe em nenhum lugar
que eu consiga ler, e não vou inventá-la.** O que existe é o CÓDIGO da E6b (o
pedido, o parser, a sonda) e o resultado da medição ANTERIOR, a E6. As barras da
E6b continuam todas em aberto — nenhuma passou, nenhuma falhou; ninguém as mediu
num arquivo que sobreviva.

---

## 1. Onde procurei, e o que cada lugar tem

| lugar | estado | tem a saída? |
|---|---|---|
| `main` no GitHub (`59e3a4c`) | último commit **15/09/2026, 13h31** | **não** — a árvore inteira é de dois dias antes da corrida |
| `origin/cursor/cloud-agent-1789216432230-vnger` | última mexida **11/09** | não |
| árvore de trabalho local do clone | limpa, nada por commitar | não |
| pasta local "traco-ios" (contexto do projeto, tirada às 18h28 de 17/09) | **dois dias à frente de `main`** — tem a E6, E6b, E7, E8, E9 no código e no SPEC | **não** — a pasta é PARCIAL (ver §4) e não traz `prova/` nem `ferramentas/` |
| `prova/e6/`, `prova/e6b/` | — | **não existem em lugar nenhum a que eu tenha acesso** |

`main` também não conhece a E6 (que fechou hoje de manhã), nem a E7, E8 ou E9. **O
repositório está dois dias atrás do trabalho.** É essa, e não outra, a razão de o
número não fechar por leitura.

---

## 2. O que existe: o código da E6b, inteiro e legível

Linhas da pasta local de 17/09 (**não** de `main` — lá nada disto existe):

- **O pedido** — `Traco/Analise/Sabia.swift:702`, `sistemaEcos`. Já pede o tipo:
  `{"ecos": [{"i": …, "tipo": "igual|versaoMaisNova|contradiz|relacionada", "trecho": "…", "trechoNota": "…", "maisNova": "nota|candidata"}]}`,
  com a regra de que `maisNova` só existe em `versaoMaisNova` e a de que, na
  dúvida entre `igual`/`versaoMaisNova` e outro tipo, o tipo é `relacionada`.
- **A chamada** — `Sabia.swift:1437`, `ecos(nota:candidatas:gesto:notaEditadaEm:)`.
  O `notaEditadaEm` entra no pedido como «(editada em AAAA-MM-DD)» ao lado da NOTA.
- **O parser** — `Sabia.swift:1673`, `parseEcos`. Na linha **1696** está,
  escrita, a barra do «Juntar»: *sem a mais nova apontada, a versão não pode virar
  «Juntar»* — sem um `maisNova` válido o tipo **cai para `relacionada`**. O tipo e
  o `trechoNota` **cortam, não calam** (`Sabia.swift:1691`): um tipo inválido tira
  o campo, não a sugestão inteira.
- **A data das candidatas** — `Traco/App/Sessao.swift:858`, `linhaDeEco`: título ·
  data de edição · 240 caracteres. É por essa data que a versão mais nova se
  decide.
- **A sonda** — `Traco/Analise/AvaliacaoIA.swift:526`, `case "ecos"`. Já devolve
  `tipo`, `trechoNota` e `maisNova` por eco, e lê `editadaEm` da fixture.

Ou seja: **o instrumento está pronto.** O que não está é o registro do que ele
mediu.

---

## 3. Barra a barra: o que dá para dizer hoje

As sete barras abaixo são as que a sessão do meio-dia relatou ter fixado antes da
corrida. **Não achei a régua escrita em arquivo nenhum** — registro-as como
relatadas, não como documento.

| barra | veredito | com base em quê |
|---|---|---|
| nenhum «Juntar» errado nas 3 repetições | **em aberto** | a guarda existe (`parseEcos:1696`), o resultado não |
| ≥ 8 de 9 propostas de juntar | **em aberto** | não há fixture de 9 casos de juntar em lugar nenhum que eu leia |
| ≥ 8 de 9 propostas de ligar | **em aberto** | idem |
| ≥ 3 de 4 contradições | **em aberto** | `contradiz` está no pedido e no parser; nunca contado |
| a mais nova apontada certo em toda versão | **em aberto, e com uma falha de fiação** (§5) | — |
| nada sugerido nos casos sem ligação | **em aberto na E6b; passou na E6** | E6: *controles sem vínculo em toda resposta escrita* |
| nenhum trecho inventado | **em aberto na E6b; passou na E6** | E6: *zero trecho não literal* |
| resposta em até 7 s | **em aberto, mas o instrumento existe** (§5) | `duracaoSegundos`, em toda linha `casoConcluido` do JSONL |

**A medição anterior (E6), essa sim está fechada** e é a única base numérica real
que temos. Está no `porque` de `Traco/Analise/Politica.swift:93` e na
**ADR 2026-09-17l** do SPEC, e diz:

- linha de base no `grok-4.3`: **8, 7 e 7 de 11** vínculos — o bruto era igual à
  saída, logo o vazio era do MODELO e não da `GuardaDeEcos`;
- o mesmo pedido no `grok-4.5`: **9, 11 e 10**;
- depois do conserto (o pedido nomeia consequência e padrão), duas corridas de
  **19 casos × 3** sobre listas prontas de 13 a 17 candidatas: **vínculo 10 de 11
  nas 6 repetições**, **zero trecho não literal**, controles sem vínculo em toda
  resposta escrita, 4 casos reservados escritos às cegas em 3/3, 3/3, 2/2 e 3/3,
  3/3, 2/3;
- a rota **voltou** — `ecos` está em `soGrok`, não mais cortada por qualidade.

São esses os 19 casos que a corrida de hoje repetia. **O que a E6b acrescenta —
tipo, trecho da nota e qual é a mais nova — é exatamente a parte que não foi
registrada.**

---

## 4. O que eu NÃO consegui ver, e por isso não afirmo

A pasta local do projeto é **parcial**: traz `Traco/Analise`, `App`, `Assets`,
`Caderno`, `Calendario`, `Componentes` e `Confirmacao`, e para aí — em ordem
alfabética. Ficaram de fora `Modelo`, `Notas`, `Padroes`, `Pagina`, `Perfil`,
`Recordar`, `Trabalho`, além de `TracoTests`, `prova/`, `ferramentas/` e
`maestro/`.

Logo: **não sei dizer se alguma tela já usa o `tipo`** para propor «Juntar» ou
«Ligar». A folha «Notas ligadas» vive em `Traco/Notas/RedeView.swift`, que não
está na pasta. Em `main` (15/09) ela lista ecos sem tipo nenhum, mas `main` é
velho demais para valer como resposta.

---

## 5. Uma falha de fiação — e uma correção ao que esta nota dizia antes

**(a) CORREÇÃO: a barra dos 7 segundos TEM instrumento, e eu disse o contrário.**
A primeira redação desta nota afirmou que o tempo não era gravado. Está errado, e
o erro era meu: eu tinha olhado só o `case "ecos"` e não o laço que o chama. A
sonda cronometra **todo caso**, com relógio monotônico —
`let inicio = ContinuousClock.now` (`AvaliacaoIA.swift:273`) antes de `executar`,
e `registro["duracaoSegundos"]` (`:290`) na linha `casoConcluido`. Vale para as
dezesseis operações, `ecos` inclusive, e o mesmo já está em `main`
(`AvaliacaoIA.swift:240` e `:257`).

Para o `ecos` essa duração **é** o tempo de resposta: um caso de `ecos` faz UMA
chamada ao Grok, e `Grok.esquecerMemo()` roda antes de cada repetição
(`AvaliacaoIA.swift:234`), então nenhuma repetição volta pelo memo. O que sobra
por cima da chamada é o parser. O `segundosEcos` do braço da E6c
(`AvaliacaoIA.swift:505`) existe porque **lá** são duas chamadas em sequência
(escolha pelo índice + ecos) e é preciso separá-las; no `ecos` puro não há o que
separar. **Nada a consertar aqui: a barra dos 7 s fecha com o JSONL como ele é.**

**(b) Em produção a data da NOTA não viaja.** Esta fica de pé.
`Sessao.swift:592` chama
`Sabia.ecos(nota:candidatas:gesto:)` **sem** `notaEditadaEm`. As candidatas levam
a data delas (via `linhaDeEco`), mas a nota aberta não leva a sua. O modelo é
mandado decidir qual das duas é a mais nova **com a data de uma só**. Na sonda a
fixture pode trazer `editadaEm` e a coisa funciona; na tela, não. **Uma barra que
passa na medida e não pode passar no app.** Conserto: passar `nota.editadaEm` na
chamada de `Sessao`.

---

## 6. O que falta para fechar o número

Em ordem, e o primeiro item resolve mais que ele mesmo:

1. **Subir o trabalho de 16 e 17/09 para `main`** — a E6, a E6b, a E7, a E8 e a
   E9, com o texto das provas (`prova/e6/LEIA.md`, o JSONL, o LEIA da E6b). O
   `AGENTS.md` da pasta local já fixou a regra certa em 17/09: *capturas e vídeos
   ficam fora do git; a prova que viaja entre worktrees é TEXTO*. Só que o texto
   também não subiu. Enquanto `main` estiver dois dias atrás, toda pergunta sobre
   uma medição vai terminar como esta.
2. **Achar o `avaliacoes-ia.jsonl` da corrida no Documents do Air** e guardá-lo
   como `prova/e6b/`. Ele existe no aparelho se a corrida chegou a rodar: a sonda
   escreve linha a linha, com `fsync` a cada linha, em
   `Documents/avaliacoes-ia.jsonl` (`AvaliacaoIA.swift:177` e `:223`). A linha
   `evento: "inicio"` traz o `sha256` da fixture — é por ele que se prova qual
   régua rodou.
3. **Escrever a régua da E6b em arquivo**, antes da próxima corrida, e não só na
   conversa. As sete barras acima vieram de relato; uma barra que não está em
   disco não é pré-registrada.
4. **Passar `notaEditadaEm` em `Sessao.swift:592`** (item 5b), senão a barra da
   versão mais nova mede uma coisa e o app faz outra. O patch está no §7.
5. **Só então repetir a corrida.** Refazê-la sem 3 e 4 devolve o mesmo buraco.

O tempo de resposta **não** entra nesta lista: a primeira redação desta nota
punha aqui um quarto item para instrumentar o `case "ecos"`, e ele saiu porque
era engano meu (§5a). Menos um conserto a fazer.

---

## 7. O patch do item 4, e por que ele não vem commitado

**Ele não pode entrar em `main`, e a razão não é cautela minha.** Em `main` a E6b
não existe: `Sabia.Eco` tem só `i` e `trecho` (`Sabia.swift:592`), `sistemaEcos`
não pede tipo nenhum, `ecos(...)` não tem o parâmetro `notaEditadaEm`
(`Sabia.swift:1155`), e `linhaDeEco`/`candidatasDeEcos` **não existem** —
`Sessao` monta as candidatas de outro jeito. Escrever "o conserto de uma linha"
em cima de `main` seria reimplementar a E6 e a E6b inteiras às cegas, num galho
que vai colidir de frente com a árvore do dono quando ela subir. **Uma linha na
árvore certa vale mais que cem linhas na errada.**

Na árvore de 17/09 é isto, e só isto:

```diff
--- a/Traco/App/Sessao.swift
+++ b/Traco/App/Sessao.swift
@@ -590,7 +590,9 @@
         let linhas = candidatas.map(Self.linhaDeEco)
         guard let ecos = await Sabia.ecos(nota: Caderno.prosa(de: texto),
-                                          candidatas: linhas, gesto: gesto)
+                                          candidatas: linhas, gesto: gesto,
+                                          notaEditadaEm: podem.first { $0.uuid == notaUUID }?
+                                              .editadaEm)
         else { return saida }
```

Os dois nomes estão em escopo e conferidos: `notaUUID` é propriedade da `Sessao`
(`Sessao.swift:15`) e `podem` é o array de `Nota` filtrado na mesma função
(`:562`), o mesmo que já vai a `candidatasDeEcos` na linha 587. Nenhuma outra
linha muda: `Sabia.ecos` já tem o parâmetro com valor padrão `nil`
(`Sabia.swift:1437`) e já sabe montar o «(editada em …)» (`:1442`).

O teste que acompanha: uma nota aberta com `editadaEm` conhecida, e a asserção de
que o texto do pedido que sai de `Sabia.ecos` contém «(editada em …)» com essa
data. Hoje ele falha; com o patch, passa.

**Não compilei nem rodei nada disto.** Esta máquina é Linux e não tem toolchain
Swift; o Traço é app de iOS 26 com SwiftUI e SwiftData, e o portão da casa
(`ferramentas/portao.sh`) roda num simulador. Quem aplicar tem de passar o portão
antes de commitar — como manda o `AGENTS.md`.

---

## A lição, que é velha nesta casa

*Uma medida que não deixa arquivo não aconteceu.* A sonda grava cada linha e
sincroniza a cada linha justamente para sobreviver a um aparelho que morre no meio
— e ainda assim o resultado se perdeu, porque o arquivo nunca saiu do aparelho
para o repositório. **O portão que falta não é de qualidade de IA; é de prova.**
