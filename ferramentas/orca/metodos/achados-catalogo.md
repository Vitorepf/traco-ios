# Contrato da volta M3 (colagem) e achados do catálogo

Trilha Métodos · escrito na M2, atualizado com a decisão do dono de 06/09.

**Quem executa a M3 lê este arquivo inteiro antes de abrir
`Traco/Modelo/Metodos.json`.** O que está aqui foi medido, não deduzido, e um
dos itens protege a escrita pessoal do dono: errar nele não quebra teste nenhum
— aparece no dia em que um desabafo cai numa forma que faz perguntas.

## Estado, para não haver dúvida

| o que | estado |
|---|---|
| Subtração, Coluna da esquerda, Classe de referência, Cinco porquês (M1) | **APROVADOS pelo dono, 06/09.** Entram na M3 |
| Cinco porquês, especificamente | aprovado **condicionado** ao fecho da citação de Ohno. **Condição cumprida na M2** (citação trocada por fonte lida na íntegra). Entra |
| Conserto da regex do Se–então | **aprovado pelo dono para a M3** (item 3 abaixo) |
| Pergunta de Hamming, O que se vê e o que não se vê, Exame da noite (M2) | propostos, **gosto ainda não decidido. NÃO colar na M3** |
| Matriz de Eisenhower, Cerca de Chesterton, Considerar o oposto | rejeitados. Não entram |

## Como o roteador funciona (a regra que torna a ordem um contrato)

`Traco/Analise/AnaliseLocal.swift`, `detectarGesto`: o catálogo é percorrido
**na ordem do arquivo** e vence o **primeiro** método cuja regex casa no texto
em minúsculas. A Expressiva só é considerada acima de 120 caracteres. O Destaque
não tem regex — é reconhecido pela forma (três ou mais linhas curtas), em
código.

**Ordem no arquivo é comportamento.** Não é estilo, não é organização.

---

# 1. CONTRATO: onde colar

Os quatro objetos aprovados entram **no FIM do array**, depois de `atualizacao`,
nesta ordem:

```
… , atualizacao,
    subtracao,
    colunaEsquerda,
    classeDeReferencia,
    cincoPorques ]
```

Cada objeto está pronto para colar, no bloco ```json da sua ficha:

- `ferramentas/orca/metodos/subtracao.md`
- `ferramentas/orca/metodos/colunaEsquerda.md`
- `ferramentas/orca/metodos/classeDeReferencia.md`
- `ferramentas/orca/metodos/cincoPorques.md`

Copie o bloco inteiro, sem reescrever. As regex têm `\b` e acentos que já foram
testados; retocar à mão é a maneira mais fácil de estragar a prova.

## 2. CONTRATO: por que no fim, e o que NUNCA fazer

**Nenhum destes quatro pode ser colado antes da Expressiva.** Está medido, na
M1 e reconferido na M2:

| ordem testada | resultado |
|---|---|
| os quatro **no fim** | 0 falso positivo, 0 regressão |
| os quatro **antes da Especificação** | dois erros novos, e um é grave |

O erro grave: a **Coluna da esquerda passa a roubar o desabafo da Expressiva**.
Esta frase de teste deixa de ser Expressiva e vira formulário:

> "na reunião com o chefe eu senti uma raiva enorme, doeu ficar ali, fiquei
> calado o tempo todo e chorei depois no corredor, foi pesado demais para mim"

A Coluna da esquerda casa nela por duas regex (`\bfiquei calad[oa]\b` e
`\bna reuni[ãa]o com\b`), e só não a rouba porque a Expressiva vem antes. A
proteção da escrita pessoal, aqui, **é a ordem do arquivo** — não há guarda em
código que salve se a ordem mudar.

**Regra permanente, para esta volta e para as próximas:** nenhum método cuja
regex mencione conversa, silêncio, arrependimento ou sentimento entra antes da
Expressiva. Isso vale para a Coluna da esquerda (M1) e valerá para o Exame da
noite (M2), se o dono o aprovar.

Se algum dia for necessário mexer na ordem, a prova a rodar antes é a do bloco
de falso positivo do script da rodada, e o critério de aprovação é único:
**nenhuma frase longa com palavras de sentimento pode sair da Expressiva.**

## 3. CONTRATO: o conserto da regex do Se–então (aprovado pelo dono)

Hoje, no `Metodos.json`:

```json
"roteamento": ["sempre que|toda vez|não consigo parar"]
```

Sem `\b`, **"sempre que" casa dentro de "sempre quebra"** — e também de "sempre
queria", "sempre quero", "sempre quebrou". Foi assim que a frase "sempre quebra
no mesmo ponto, qual é a causa", que é dos Cinco porquês, foi parar no Se–então.

Trocar por:

```json
"roteamento": ["\\bsempre que\\b|\\btoda vez\\b|\\bnão consigo parar\\b"]
```

Conferido nesta rodada, com o catálogo inteiro montado (21 + os quatro
aprovados + os três da M2), antes e depois da troca:

```
seEntao          -> seEntao          «sempre que abro o telefone na cama eu perco uma hora»
seEntao          -> cincoPorques     «sempre quebra no mesmo ponto, qual é a causa»
seEntao          -> colunaEsquerda   «sempre queria ter dito o que pensei»
```

O Se–então continua pegando tudo o que é dele ("sempre que…", "toda vez…", "não
consigo parar…") e devolve o que nunca foi. Em todo o corpus de frases das duas
rodadas, a correção **não muda mais nenhum roteamento**. Compila — que é o que o
teste `todaRegexDoCatalogoCompila` cobra.

## 4. O que a M3 tem de provar antes de mesclar

1. **Suíte integral verde** no simulador de teste, via `com-trava.sh`. Nada
   disto foi rodado nas voltas M1 e M2: elas não abrem simulador nem
   `xcodebuild`, por ordem da tarefa. **O portão G1 é da M3.**
2. `todaRegexDoCatalogoCompila` passando com as regex novas e com a do Se–então
   corrigida.
3. As frases de teste das fichas roteando para o método certo, no app e não só
   no script — em especial a frase de desabafo do item 2, que tem de continuar
   caindo na Expressiva.
4. Os quatro métodos aparecendo no Perfil com a proveniência (é o que a volta 16
   entregou: fonte, função, adaptação, evidência, aplicabilidade).

## 5. Achado aberto: cinco desvios que já existem hoje

Medidos contra os 21 do branch da volta 16, **sem nenhum candidato no
catálogo**. Não são causados por esta trilha, e a diferença com e sem os
candidatos das duas rodadas é **zero**.

| a frase do autor | vai para | deveria ir para | por quê |
|---|---|---|---|
| "resumir a ideia em 100 caracteres e depois numa frase" | Nota permanente | Destilar | `ideia` casa antes, e a Nota permanente vem antes no arquivo |
| "quero fazer um pré-mortem do lançamento de novembro" | WOOP | Pré-mortem | `(?m)^quero` |
| "quero entender de verdade como funciona a compressão" | WOOP | Feynman | `(?m)^quero` |
| "quero desmontar isso até os primeiros princípios" | WOOP | Primeiros princípios | `(?m)^quero` |
| "quero treinar o pedaço da fala que sempre falha" | WOOP | Prática deliberada | `(?m)^quero` |

Quatro dos cinco são o mesmo: **`(?m)^quero` do WOOP engole qualquer frase que
comece com "quero"**, e o dono começa muita frase com "quero".

**Isto NÃO está aprovado e a M3 não deve mexer nisso de passagem.** Muda
comportamento de um método que o dono usa, e a escolha é dele. As duas saídas,
com o risco de cada uma:

1. **Estreitar o WOOP** — `(?m)^quero (parar|começar|voltar a|conseguir)\b` e
   afins, deixando "quero entender", "quero treinar" e "quero fazer um
   pré-mortem" caírem em quem é dono deles. Risco: um desejo escrito de forma
   inesperada deixa de abrir o WOOP. **É a recomendação**, porque não mexe na
   ordem e o efeito é local.
2. **Mover o WOOP para depois** dos métodos com regex específica. Risco: mexe na
   ordem, que é comportamento — e a regra do item 2 passa a ter de ser
   reconferida inteira.

## 6. O que as provas das rodadas cobrem e o que não cobrem

**Cobrem** (script Python que imita a regra do app, nas duas rodadas): falso
positivo, colisão de ordem, linha de base sem candidatos, esquema da volta 16
(chaves, `funcao` da proveniência, campos, encadeamentos apontando para método e
campo existentes, `recordar`, `compromisso`, id não repetido) e compilação das
regex.

**Não cobrem:** o app rodando. Nenhuma volta desta trilha abriu simulador,
build ou suíte. Isso é da M3.
