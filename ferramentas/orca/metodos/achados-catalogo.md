# Achados do catálogo — o que a volta de colagem tem de respeitar

Trilha Métodos · escrito na volta M2, com o que a M1 mediu · 06/09/2026.

Este arquivo existe para uma coisa: **a volta de colagem (M3) não pode perder o
que as provas de roteamento acharam.** Um dos achados é de proteção da escrita
pessoal, e um erro nele não aparece em teste de compilação — aparece no dia em
que um desabafo do dono cai numa forma que faz perguntas.

Regra do app, para quem ler isto sem o código na frente
(`Traco/Analise/AnaliseLocal.swift`, `detectarGesto`): o catálogo é percorrido
**na ordem**, e vence o **primeiro** método cuja regex casa no texto em
minúsculas. A Expressiva só é considerada acima de 120 caracteres. O Destaque
não tem regex: é reconhecido pela forma (três ou mais linhas curtas), em código.
**Ordem no arquivo é comportamento.**

## 1. ORDEM: os candidatos entram no FIM do catálogo

Medido na M1, com os quatro candidatos daquela rodada:

- Colados **no fim**: 0 falso positivo, 0 regressão.
- Colados **antes da Especificação**: dois erros novos, e um deles é grave —
  a **Coluna da esquerda passa a roubar o desabafo da Expressiva**. A frase de
  teste "na reunião com o chefe eu senti uma raiva enorme, doeu ficar ali,
  fiquei calado o tempo todo e chorei depois no corredor" deixa de ser Expressiva
  e vira formulário.

**Portanto:** método novo entra no fim. Nenhum método cuja regex mencione
conversa, silêncio, arrependimento ou sentimento pode ser colado antes da
Expressiva. Isso vale para a Coluna da esquerda (M1) e para o Exame da noite
(M2), e a mesma prova foi refeita na M2 com resultado igual.

Se algum dia for preciso mexer na ordem, a prova a rodar antes é a do bloco 1 e
4 do script da M1, e o critério é: nenhuma frase longa de sentimento pode sair
da Expressiva.

## 2. DEFEITO: a regex do Se–então casa dentro de outra palavra

Hoje, no `Metodos.json`:

```
"roteamento": ["sempre que|toda vez|não consigo parar"]
```

Sem `\b`, **"sempre que" casa dentro de "sempre quebra"** — e também de "sempre
queria", "sempre quero", "sempre quebrou". Achado quando a frase "sempre quebra
no mesmo ponto, qual é a causa" (que é dos Cinco porquês) foi parar no Se–então.

Correção sugerida, de uma linha:

```
"roteamento": ["\\bsempre que\\b|\\btoda vez\\b|\\bnão consigo parar\\b"]
```

Confere com o teste `todaRegexDoCatalogoCompila` da suíte e não muda nenhum
roteamento legítimo do Se–então nas frases testadas.

## 3. CINCO DESVIOS QUE JÁ EXISTEM HOJE

Medidos na M1 contra os 21 do branch da volta 16, **sem nenhum candidato no
catálogo**. Não são causados por esta trilha; são o estado atual. A diferença
com e sem os candidatos das duas rodadas é **zero**.

| a frase do autor | vai para | deveria ir para | por quê |
|---|---|---|---|
| "resumir a ideia em 100 caracteres e depois numa frase" | Nota permanente | Destilar | `ideia` casa antes, e a Nota permanente vem antes no arquivo |
| "quero fazer um pré-mortem do lançamento de novembro" | WOOP | Pré-mortem | `(?m)^quero` |
| "quero entender de verdade como funciona a compressão" | WOOP | Feynman | `(?m)^quero` |
| "quero desmontar isso até os primeiros princípios" | WOOP | Primeiros princípios | `(?m)^quero` |
| "quero treinar o pedaço da fala que sempre falha" | WOOP | Prática deliberada | `(?m)^quero` |

O padrão é um só: **`(?m)^quero` do WOOP engole qualquer frase que comece com
"quero"**, e o autor começa muita frase com "quero". Quatro dos cinco desvios
são esse.

Duas saídas possíveis, e a escolha é do dono porque muda comportamento:

1. **Estreitar o WOOP**: exigir o que o WOOP realmente é —
   `(?m)^quero (parar|começar|voltar a|conseguir)\b` e afins — deixando "quero
   entender", "quero treinar", "quero fazer um pré-mortem" caírem em quem é dono
   deles. Risco: um desejo escrito de forma inesperada deixa de abrir o WOOP.
2. **Mover o WOOP para depois** dos métodos com regex específica. Risco: mexe na
   ordem, que é comportamento — e a regra do item 1 acima passa a ter de ser
   reconferida.

Nenhuma das duas foi feita nesta trilha: o `Metodos.json` está fechado até a M3,
e isso é decisão de gosto do dono, não de pesquisa. **Recomendação:** a (1),
porque não mexe na ordem e o efeito é local.

## 4. O QUE AS PROVAS NÃO COBREM

O script das rodadas M1 e M2 é Python e imita a regra do app; a suíte de verdade
não rodou porque estas voltas não abrem simulador nem `xcodebuild` e não editam
o `Metodos.json`. O portão G1 é da volta de colagem, com os objetos dentro do
arquivo. O que a prova cobre: falso positivo, colisão de ordem, linha de base,
esquema da volta 16 e compilação das regex.
