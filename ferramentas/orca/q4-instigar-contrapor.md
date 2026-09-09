# Q4 — `instigar` e `contrapor`: o andaime é nosso

**ADR:** 2026-09-09i (SPEC.md) · **Branch:** `Vitorepf/volta-q4-instigar`, sem mesclar
**Ciclo:** melhorar a mente · **Intenção:** a sábia provoca o autor a pensar melhor —
perguntando sobre o que ELE escreveu, e contrapondo com o que se sustenta.

## ⚠️ Esta passada NÃO correu no aparelho — ela PREPARA a corrida em lote

Nada foi medido contra a rede. Não instalei nada no `B91C8DEF` (aparelho da conta),
não chamei o Grok, não rodei a sonda. **A fixture está pronta:**

```
prova/q4-instigar-contrapor-casos.json   — 12 casos (6 instigar, 6 contrapor), 3 repetições = 36 execuções
```

## O defeito, e por que são um só

A medida de 08/09 com a conta ligada reprovou as duas com **1 de 6** cada:

- `instigar` devolveu **o nosso vocabulário de andaime** em vez de perguntar sobre o texto;
- `contrapor` sustentou o contraponto em **fato inventado**, sempre no `outroCampo`.

São a mesma coisa: **o modelo enche o espaço com material que não veio do autor.**

## A causa do `instigar`, achada e não suposta

O pedido montava, num texto só, o rascunho DELE e o nosso andaime — `Forma: nota`,
`O MÉTODO desta forma…` e `DEGRAU 0 — primeira vez nesta forma. Cobre o MOVIMENTO
básico do método: o passo que se pula.` O que está ao lado do rascunho é **citável**:

| o autor escreveu | voltou (`prova/q-qualidade-avaliacoes.jsonl`, 08/09) |
|---|---|
| "praticar espanhol… quinze minutos" | "Qual é o **movimento básico que se pula** ao esperar ter uma hora livre?" |
| "Não deu certo de novo." | "Qual é o **movimento básico** que foi pulado?" |
| "…parei no primeiro parágrafo" | "**A forma 'nota'** já foi usada em capítulos anteriores?" |
| (o rascunho do espanhol) | "Como a nota '**DEGRAU 0**' se relaciona com **o método** que você menciona?" |

**O que aponta o dedo:** os dois casos **com método** (`decisao`) NÃO vazaram — deram
critério, evidência e custo de errar falando do aluguel e do limite de R$ 1.000.
Vazaram os quatro **sem método**, onde a instrução de degrau era o único texto de
esteio e, sendo meta, virou assunto. **O defeito é nosso, não do provedor.**

## O conserto

**`instigar` — o andaime sai do texto citável (3 movimentos, todos deleção ou mudança de lugar):**

1. Método (03n) e degrau (04j) passam para a mensagem de **SISTEMA**; o pedido leva o
   rascunho e o retrato — só o que veio do autor.
2. O rótulo `Forma: <nome>` **saiu inteiro**: o método já se apresenta pelo nome, e
   sozinho ele só dava uma palavra para citar.
3. `Degraus.instrucaoDeInstigar` reescrita **sem nome citável** — o degrau continua
   mudando o que se cobra (passo básico → relação → evidência → custo → limite) e
   deixou de ser assunto.

**`contrapor` — contrato de sustentação, irmão do que a Q2 provou em `sistemaResponder`:**
proibido número, porcentagem, preço, data, estudo, pesquisa, metanálise, fonte ou
declaração de terceiro que ela não deu; o caso de outro campo **admite `""` por
escrito** (era exigido em toda chamada, e essa exigência é que fabricava a precisão).
O defeito oposto entrou junto: calar nos três só quando a nota não deixa nada a
examinar.

**A guarda que se prova sem o aparelho — relativa ao autor:**

```swift
Sabia.vazaAlheio(frase, termos:, texto:)   // cai se a frase tem o termo e o texto do autor não
```

`parsePerguntas(_:texto:)` derruba a pergunta com `degrau`, `método`, `sábia`,
`rascunho`, `movimento básico` ou `passo que se pula` **que o autor não escreveu**;
`parseContraparte(_:texto:)` derruba o campo com `%`, `metanálise`, `segundo
estudo/pesquisa` ou `dados mostram` nas mesmas condições. A relatividade é o ponto:
**quem escreveu "método" na própria nota ouve uma pergunta sobre o método dele.**

## Prova (colada)

**Vermelho ANTES** — guarda desligada (`return false`), material = as saídas reais de 08/09:

```
✘ Expectation failed: (Sabia.parsePerguntas(json, texto: rascunho) → ["Qual é o movimento básico que se pula ao esperar ter uma hora livre?", "O que exatamente significa praticar espanhol em quinze minutos?"]) == ["O que exatamente significa praticar espanhol em quinze minutos?"]
✘ Expectation failed: (Sabia.parseContraparte(cru, texto: "Vou aceitar a proposta.") → Contraparte(contra: "A comissão de 12% cobre o custo de hoje, …", foraDaLista: "", outroCampo: "")) == nil
✘ Test run with 7 tests in 1 suite failed after 0.023 seconds with 12 issues.
```

**Verde DEPOIS** — suíte integral, `34CC3F94` (teste 3):

```
✔ Test run with 1007 tests in 162 suites passed after 89.239 seconds.
** TEST SUCCEEDED **
```

Build: `** BUILD SUCCEEDED **` (`xcodebuild -scheme Traco -destination 'generic/platform=iOS Simulator' build`).
Aviso restante na árvore: `NotasView.swift:806 '+' was deprecated` — **não é meu** (área da D1).

## Instrumento

- **Trava:** todo `xcodebuild` passou por `ferramentas/orca/com-trava.sh`. Declarado.
- **`34CC3F94` (teste 3):** build e suíte. **Encontrei-o LIGADO por outra volta**
  (`simctl boot` respondeu `Unable to boot device in current state: Booted`) e
  **deixei como achei** — não desliguei o que não liguei.
- **`B91C8DEF` (conta):** **não toquei**. Nenhum install, nenhum launch, nenhuma
  chamada de rede, `ContaGrok` intacta.
- **Primeira corrida:** `The test runner hung before establishing connection` — outra
  volta (PID 91131) rodava `xcodebuild test` no MESMO UDID. Repetida depois da trava,
  conectou e deu a linha acima. As duas saídas estão neste relato.
- Sem mouse, sem maestro, sem voz, sem VoiceOver, sem iPad.

## O que muda se o vencedor da Q2-F for outro modelo

**Nada no código.** O conserto é redação de pedido e guarda de parser — não passa
modelo nem esforço, e nenhuma das duas rotas pede `esforco`, então herda o
`Grok.esforcoMinimo` seja ele qual for. O que muda é a **taxa**: a separação
sistema/usuário depende de o modelo tratar instrução como instrução, e um modelo
que confunde os dois papéis vaza mais e a guarda derruba mais perguntas — o sintoma
seria `instigar` devolvendo `nil` com frequência, não vazamento na tela. Se isso
aparecer na corrida, o caso `q4-instigar-texto-magro` é o que acusa.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 8 | entra no ciclo "melhorar a mente" e ataca duas linhas cortadas, mas **não fecha lacuna do EVOLUCAO**: conserto escrito ≠ conserto medido. Por isso não toquei o EVOLUCAO. |
| Contrato | 9 | ADR 2026-09-09i em SPEC.md, coerente com `Politica` (as duas linhas passam a "em correção, com conserto nomeado") |
| Correção | 9 | vermelho antes com 12 issues, verde depois 1007/162/0; a guarda é o que separa os dois |
| Jornada real | n/a | esta passada não corre no aparelho por ordem do dispatch; a captura da resposta real é do fecho da corrida |
| Design | n/a | motor puro, nenhuma view tocada (implementador.md: "motor puro dispensa design-router") |
| Simplicidade | 9 | nenhum passo, tela ou decisão novo para o autor; o `conserto` na tela do Perfil está em linguagem de pessoa |
| Movimento | n/a | sem animação |
| Componentes | n/a | sem componente de UI |
| Acessibilidade | n/a | sem superfície nova |
| Performance | 9 | duas comparações de `String.contains` por frase, em cima de uma chamada de rede de dezenas de segundos |
| Privacidade e autoria | 9 | menos material nosso sai e nada novo entra; o texto do autor só é LIDO pela guarda, nunca gravado nem enviado |
| Estado honesto | 9 | as linhas ficam `indisponivelPorQualidade` porque a medida não existe; o `conserto` diz "falta medir"; guarda que derruba tudo devolve `nil` e a página cai nas perguntas do método |
| Complexidade | 9 | **+71 linhas líquidas em `Traco/`, e ~13 são lógica** — o resto é prompt e doc; um arquivo novo só (a fixture); nenhuma dependência |
| Fora do app | n/a | sem superfície fora do app |
| Relato | 9 | este arquivo, com as duas saídas do instrumento e a fixture nomeada |

## Dívida nomeada e limites

1. **`Sabia.montarInstigar`/`montarContrapor`** (caminho do aparelho) continuam com o
   andaime na carga. A `Politica` não deixa estas duas descerem ao aparelho; o dia em
   que deixar, a separação tem de ir junto. Não mexi: churn de teste em caminho morto.
2. **A guarda de `contrapor` cobre a FORMA da evidência medida**, não toda invenção:
   "produzem ganhos equivalentes em VO2 máx", sem número e sem fonte, passa pela
   guarda e depende do contrato. Deliberado — guarda que julga verdade cala o
   contraponto honesto, que é o defeito oposto.
3. **Achado colateral, não meu para consertar:** o `conserto` de `responder` na tabela
   diz "**o prompt** já mata a invenção de número", e esse texto vai **inteiro para a
   tela do autor** (`PerfilView.restoDa`). "Prompt" é jargão nosso na tela dele. Uma
   linha, dona: quem tocar a Q2-F.
4. **Casos escritos e lidos por quem implementa.** A leitura de casos cegos é do revisor.

## Para o orquestrador juntar as três fixtures

`prova/q4-instigar-contrapor-casos.json` roda como está: `AvaliacaoIA` aceita as
operações `instigar` e `contrapor`, e ambas precisam de
`TRACO_AVALIAR_LIBERAR=instigar,contrapor` (ADR 08z) para alcançar o provedor —
sem isso a sonda bate em `nil` antes da rede.

## Para a Q3 (`N1T1`), avisado no comentário do worktree `main`

O defeito é irmão e resolvi assim, para as duas voltas não divergirem:
(1) o que é NOSSO vai na mensagem de sistema, o pedido leva só o que veio do autor;
(2) guarda de saída **relativa ao autor**, `Sabia.vazaAlheio`. Se a Q3 for filtrar
`N1T1`/`N2T1` no texto, **chame `vazaAlheio` com os IDs dos trechos** em vez de
escrever outra guarda.
