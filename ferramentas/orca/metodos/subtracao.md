# Subtração — ficha do candidato

Volta M1 da trilha Métodos · 06/09/2026 · **APROVADO pelo dono (06/09)**,
aguardando a colagem na volta M3 — ver o contrato em `achados-catalogo.md`.

Faculdade: **simplificação** (hoje vazia no catálogo).
Ciclo: **MELHORAR** — a capacidade de tirar é a que falta quando tudo o que se
sabe fazer é somar; ela limita todo depois. Multiplica de tabela: rotina
encolhida devolve tempo agora.

## Fonte

Gabrielle S. Adams, Benjamin A. Converse, Andrew H. Hales e Leidy E. Klotz,
"People systematically overlook subtractive changes", **Nature 592, 258–261**,
8 de abril de 2021. doi:10.1038/s41586-021-03380-y.
Metadados conferidos no Crossref (volume 592, p. 258–261, 2021-04-08) e o
resumo lido no Europe PMC.

Citação literal, do resumo:

> "Here we show that people systematically default to searching for additive
> transformations, and consequently overlook subtractive transformations.
> Across eight experiments, participants were less likely to identify
> advantageous subtractive changes when the task did not (versus did) cue them
> to consider subtraction, when they had only one opportunity (versus several)
> to recognize the shortcomings of an additive search strategy or when they
> were under a higher (versus lower) cognitive load."

E a abertura, que é o que interessa ao Traço:

> "Improving objects, ideas or situations—whether a designer seeks to advance
> technology, a writer seeks to strengthen an argument or a manager seeks to
> encourage desired behaviour—requires a mental search for possible changes."

## O que a fonte afirma, e o que não afirma

**Afirma:** a busca mental por melhorias vai, por padrão, para o que se
acrescenta; a opção de tirar é menos encontrada quando a tarefa não a sugere.
São oito experimentos, e a dica ("considerar remover também é permitido")
muda o resultado — é o achado que faz este método existir: o Traço é a dica.

**Não afirma:** que subtrair seja melhor que somar. Não afirma nada sobre
projetos reais fora do laboratório — as tarefas são uma estrutura de Lego,
padrões numa grade e um texto. Não afirma nada sobre escrever a subtração numa
nota; ninguém mediu isso. Não há eficácia comprovada de nada aqui, e a ficha
não alega nenhuma.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR, dito acima.
2. **Origem verificável** — artigo em Nature, quatro autores, ano, páginas,
   DOI, citação literal do resumo.
3. **Não duplica** — o mais perto no catálogo é a **Especificação**, que tem o
   campo "o que eu NÃO vou fazer". A diferença é de movimento: a Especificação
   diz o que não será ACRESCENTADO a uma coisa que ainda não existe; a
   Subtração diz o que SAI de uma coisa que já existe e já pesa. Também não é
   o **Destilar**, que corta o texto do autor até uma frase e não sai do texto;
   nem a **Inversão**, que imagina como garantir a falha. Aqui não se imagina
   nada: nomeia-se a peça e tira-se.
4. **Honestidade sobre evidência** — o parágrafo acima diz o que os oito
   experimentos mediram (tarefas de laboratório) e o que ninguém mediu (a nota,
   o projeto real).

## O que ele desbanca ou complementa

Não desbanca ninguém. Complementa a Especificação (encadeamento natural: o que
sai vira o não-escopo da próxima rodada) e o Pré-mortem — o encadeamento
proposto manda o corte para o Pré-mortem, porque tirar tem risco e o Traço não
finge que não tem.

## Caso de uso real no Traço

O dono fecha uma volta e o roteiro do fecho tem seis passos, três dos quais
ninguém lê. A vontade é acrescentar um sétimo ("agora com um resumo"). O texto
"preciso simplificar o fecho da volta, virou um monstro" cai na Subtração: ele
escreve o que ia acrescentar, é obrigado a escrever o que sai, e o campo do
"o que se perde" separa a peça do entulho.

## O que a forma pede e o app ainda não faz

Nada. Cinco campos de texto, no esquema da volta 16; funciona no app de hoje.

## JSON pronto para colar

```json
{
  "id": "subtracao",
  "nome": "Subtração",
  "origem": "Adams, Converse, Hales e Klotz, 2021",
  "faculdade": "simplificação",
  "proveniencia": {
    "fonte": "Gabrielle S. Adams, Benjamin A. Converse, Andrew H. Hales e Leidy E. Klotz, \"People systematically overlook subtractive changes\", Nature 592, 258–261 (8 de abril de 2021)",
    "funcao": "evidencia",
    "adaptacao": "O estudo mostra que a busca mental por melhorias vai sozinha para o que se acrescenta. O Traço faz a dica que falta virar campo: o autor escreve primeiro o que ia ACRESCENTAR, e só depois é obrigado a escrever o que SAI e o que se perde tirando.",
    "evidencia": "Oito experimentos relatam que as pessoas acham menos as mudanças subtrativas vantajosas quando a tarefa não sugere a subtração, quando têm uma só chance de perceber a falha da busca aditiva, e sob carga cognitiva maior. Os experimentos são tarefas de laboratório (uma estrutura de Lego, padrões numa grade, um texto). Não há estudo de escrever isto numa nota, nem do efeito sobre um projeto real.",
    "aplicabilidade": "Serve para algo que já existe e cresceu demais — uma rotina, um plano, um texto, uma tela. Não serve para o que ainda não existe: aí é Especificação."
  },
  "filtro": "Subtração",
  "reconhecimento": "isto já cresceu demais e pede corte, não mais uma peça.",
  "movimento": "Subtração (Adams e colegas, 2021). Antes de escolher o que acrescentar, nomear o que SAI. O estudo mostra que a opção de tirar não chega a ser considerada quando ninguém sugere. Cobre o que sai de fato, o que se perde tirando — se nada se perde, não era peça, era entulho — e quem vai sentir falta.",
  "pergunta": "O que SAI — e o que se perde quando sair?",
  "roteamento": [
    "\\bsimplificar\\b|\\benxugar\\b|\\bcortar pela metade\\b|\\bmenos (é|e) mais\\b",
    "\\bo que (eu )?(tiro|corto|removo)\\b|\\bo que (tirar|remover|cortar)\\b|\\btirar (uma|umas|algumas|as) (coisa|coisas|peças?|partes?|etapas?)\\b",
    "\\b(cheio|cheia|lotad[oa]) de (passos|etapas|op[çc][õo]es|regras|coisas|bot[õo]es)\\b|\\bcomplicad[oa] demais\\b|\\bvirou um monstro\\b"
  ],
  "campos": [
    {
      "id": "melhorar",
      "rotulo": "O que eu quero melhorar (já existe)"
    },
    {
      "id": "ia",
      "rotulo": "O que eu ia acrescentar"
    },
    {
      "id": "sai",
      "rotulo": "O que SAI no lugar"
    },
    {
      "id": "perco",
      "rotulo": "O que se perde tirando (se nada se perde, era entulho)"
    },
    {
      "id": "sente",
      "rotulo": "Quem vai sentir falta"
    }
  ],
  "encadeamentos": [
    {
      "rotulo": "Pré-mortem do corte",
      "para": "premortem",
      "mapa": {
        "plano": "sai"
      },
      "exige": [
        "sai"
      ]
    },
    {
      "rotulo": "Conferir o corte em 14 dias",
      "compromisso": {
        "titulo": "conferir o corte: ",
        "campo": "sai",
        "dias": 14
      },
      "exige": [
        "sai"
      ]
    }
  ],
  "definicao": "algo que já existe e cresceu demais, e pede corte antes de mais uma peça (\"simplificar\", \"complicado demais\", \"o que eu tiro\")"
}
```

## Nota de rodada

Proposto sob a barra de QUATRO (correção do dono, 06/09 13:25). Passaria também
na barra de seis: o passo que se pula é o que o próprio estudo mede — a
subtração não é considerada.
