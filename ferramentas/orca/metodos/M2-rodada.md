# Trilha Métodos — volta M2, segunda rodada

06/09/2026 · worktree `metodos-m1`, mesmo branch · pesquisador de métodos.

**Nada foi colado no catálogo.** `Traco/Modelo/Metodos.json` continua fechado
até a volta de colagem (M3), depois que a volta 16 mesclar. Barra aplicada: a de
**quatro**, com a forma livre.

## 1. A pendência do Ohno: fechada trocando a citação

A M1 admitiu que a citação dos Cinco porquês era de segunda mão. Fui atrás da
fonte primária nesta rodada e **não consegui o livro**:

- A edição inglesa de 1988 (*Toyota Production System: Beyond Large-Scale
  Production*) está no Internet Archive como `toyotaproduction0000onot`, mas o
  item é de **acesso restrito** (empréstimo, `printdisabled`). Não contorno
  restrição de acesso.
- Os endpoints públicos de busca-dentro-do-livro não responderam daqui.
- Baixei e li o texto integral de *Workplace Management*, do mesmo Ohno, que
  está aberto no Internet Archive, procurando a passagem: **não está lá.**

Solução, que é a que a tarefa autorizava: **troquei a citação por uma que eu li
inteira** — Toyota Motor Corporation, "Ask 'why' five times about every matter",
*Toyota Traditions*, março de 2006. É a própria empresa onde o método nasceu,
publicando o método, atribuindo-o a Ohno e dando a cadeia inteira do robô de
solda. A obra de Ohno continua sendo a origem (autor, título, editora, ano e
ISBN conferidos no registro de catálogo); o que mudou é que a frase que sustenta
o método agora foi lida por alguém do Traço.

Fica em aberto, pequeno: a frase exata no livro, com página (capítulo 1, seção
"Ask 'Why' Five Times About Every Matter"). Se o dono tiver o livro, são cinco
minutos e a ficha melhora. **Não é mais bloqueio, e o candidato não precisa ser
retirado.**

A ficha `cincoPorques.md` foi atualizada: fonte, citações, como a pendência foi
fechada, e a barra 2 reescrita.

## 2. Os candidatos da M2

| candidato | faculdade | ciclo | estado |
|---|---|---|---|
| [A pergunta de Hamming](perguntaHamming.md) | direção (vazia) | melhorar | proposto |
| [O que se vê e o que não se vê](vistoNaoVisto.md) | consequência (vazia) | multiplicar + melhorar | proposto |
| [Exame da noite](exameDaNoite.md) | caráter (vazia) | melhorar | proposto |
| [Cerca de Chesterton](rejeitado-cercaDeChesterton.md) | (prudência) | — | **REJEITADO — barra 3** |
| [Considerar o oposto](rejeitado-considerarOOposto.md) | (calibragem) | — | **REJEITADO — barra 3** |

Todas as citações desta rodada foram lidas por mim no texto integral: a
transcrição da palestra de Hamming (1986), o ensaio de Bastiat na tradução de
Stirling, o *De Ira* III.36 de Sêneca na tradução de Stewart, o capítulo de
Chesterton, e o resumo de Lord, Lepper e Preston no Europe PMC com os metadados
no Crossref. Nenhuma é de segunda mão.

### Sobre as duas rejeições

As duas caem na mesma barra por motivos diferentes, e vale ler as duas fichas:

- A **Cerca de Chesterton** morre porque a **Subtração**, proposta na M1 desta
  mesma trilha, já tem o campo que faz o trabalho dela. A trilha rejeitou um
  candidato por duplicar outro candidato da própria trilha.
- **Considerar o oposto** morre embora seja **o candidato com melhor apoio
  experimental de toda a trilha** — dois experimentos publicados no JPSP, com
  efeito maior do que mandar a pessoa "ser justa". Cai porque o movimento já é
  cobrado em campo no Argumento, na Atualização e no Steelman inteiro.
  **Evidência não compra entrada**; a barra é sobre o que o método faz no
  catálogo.

> Os encadeamentos ENTRE os métodos propostos foram escritos na volta M4:
> ver [`encadeamentos.md`](encadeamentos.md). O que a forma livre pede do app
> está consolidado na seção 7 de [`achados-catalogo.md`](achados-catalogo.md).

## 3. O que a forma livre pediu, de novo

Dois métodos desta rodada pedem a mesma coisa que um da M1 já pedia:

- **Compromisso recorrente.** A Pergunta de Hamming quer a sexta-feira dos
  grandes pensamentos (Hamming reservava 10% do tempo, toda semana); o Exame da
  noite quer a noite, todo dia. O compromisso do app é de uma vez, em N dias.
  Com o campo repetível que a M1 pediu (Cinco porquês, Divergência, Classe de
  referência), são **duas voltas de app que a trilha já justificou sozinha.**
- **Ditado no escuro** (Exame da noite): a prática de Sêneca é falada com a
  lâmpada apagada. A captura por voz da trilha Fora do app já existe; faltaria o
  modo de tela apagada. Anotado, não bloqueante.

## 4. O que procurei e não achei nesta rodada

- **Negociação — a melhor alternativa fora do acordo (BATNA)**, que eu mesmo
  deixei como lead da M2. **Não entrou, e o motivo é o mesmo padrão do Ohno:**
  as cópias de *Getting to Yes* (Fisher e Ury, 1981) que estão abertas no
  Internet Archive são uploads de comunidade de um livro sob direitos, e a
  edição catalogada está em empréstimo restrito. Não vou citar literalmente um
  livro que não li numa cópia legítima, nem sustentar a ficha em resumo de blog.
  **Se o dono tiver o livro, fecho a ficha em uma rodada.** Fica como lead da M3,
  agora com o motivo escrito.
- **Memória**: continua sendo o Recordar, mecanismo do app, não método. Nada
  mudou desde a M1.
- **Atenção e produtividade**: não voltei lá, por ordem da tarefa e porque a
  conclusão da M1 continua valendo.
- **Percepção**: procurei um instrumento de observação com origem verificável e
  movimento próprio (algo como um protocolo de descrição antes de interpretar).
  O que existe ou é de treinamento clínico, ou é escrita criativa sem autor
  identificável. **Nada digno; a faculdade continua vazia.**
- **Valores**: fechada nesta rodada pelo Exame da noite, que estava na minha
  lista de "vazias" da M1.

Faculdades que continuam vazias de propósito: **atenção, memória, percepção,
negociação** (esta por falta de acesso à fonte, não por falta de método).

## 5. Prova das regex

Script descartável, não commitado (`scratchpad/testar_regex_m2.py`). Roda os 21
do branch da volta 16, os 4 propostos na M1 e os 3 da M2, com a mesma regra do
app: primeiro que casa vence, Expressiva só acima de 120 caracteres. Dois
cenários, porque a M1 ainda não mesclou: **A** = 21 + M2; **B** = 21 + M1 + M2,
que é o catálogo provável da M3.

```

========================================================================
1. FALSO POSITIVO — as regex dos 3 da M2 contra as frases dos outros
========================================================================
Falso positivo = o candidato novo ROUBA o roteamento de uma frase alheia.
Fronteira = a regex casa, mas o método certo vence por vir antes.


  falsos positivos: 0
  fronteiras: 0

========================================================================
2. COLISÃO DE ORDEM — regex antigas casando nas frases da M2
========================================================================
  colisões: 0

========================================================================
3. CENÁRIO A — 21 do catálogo + os 3 da M2 no fim
========================================================================
  ok  woop                 esperado woop                 «quero voltar a correr de manhã três vezes por se»
  ok  seEntao              esperado seEntao              «sempre que abro o telefone na cama eu perco uma »
  ok  spec                 esperado spec                 «vou construir um módulo de exportação para o cor»
  ok  notaPermanente       esperado notaPermanente       «percebi que a origem do método importa mais do q»
  ok  destilar             esperado destilar             «preciso destilar este texto até sobrar uma frase»
  ok  palavra              esperado palavra              «não conhecia a palavra propedêutica, o que quer »
  ok  decisao              esperado decisao              «preciso decidir entre ficar no emprego e abrir a»
  ok  premortem            esperado premortem            «imagina que falhou: o aplicativo saiu e ninguém »
  ok  argumento            esperado argumento            «defendo que o catálogo precisa de origem verific»
  ok  leitura              esperado leitura              «terminei de ler o livro do Ahrens sobre notas»
  ok  feynman              esperado feynman              «não entendi como funciona o roteamento de bordo,»
  ok  dia                  esperado dia                  «hoje eu preciso fechar a volta e responder o don»
  ok  dia                  esperado dia                  «meu dia hoje tem três reuniões e o relatório»
  ok  analogia             esperado analogia             «isto já foi resolvido em outro campo, na aviação»
  ok  inversao             esperado inversao             «como garantir que falhe: eu deixaria o método se»
  ok  steelman             esperado steelman             «quem discorda diria que o catálogo já tem método»
  ok  divergencia          esperado divergencia          «preciso de dez opções antes de escolher o nome»
  ok  primeirosPrincipios  esperado primeirosPrincipios  «quais são as suposições que eu herdei sobre nota»
  ok  praticaDeliberada    esperado praticaDeliberada    «prática deliberada de leitura em voz alta, quinz»
  ok  atualizacao          esperado atualizacao          «qual a probabilidade de a volta 16 mesclar hoje»
  ok  expressiva           esperado expressiva           «hoje foi pesado demais, senti uma raiva que não »
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falha»
  ok  decisao              esperado decisao              «essa decisão é entre mudar de cidade ou renovar »
  ok  perguntaHamming      esperado perguntaHamming      «quais são os problemas importantes do meu campo»
  ok  perguntaHamming      esperado perguntaHamming      «no que eu deveria estar trabalhando este ano»
  ok  perguntaHamming      esperado perguntaHamming      «acho que estou trabalhando na coisa errada»
  ok  perguntaHamming      esperado perguntaHamming      «vale a pena trabalhar nisso ou é perda de tempo»
  ok  perguntaHamming      esperado perguntaHamming      «para onde isso me leva daqui a três anos»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «qual é o custo de oportunidade de tocar esta fre»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «o que eu deixo de fazer se eu aceitar isso»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «parece que não custa nada, é só apertar um botão»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «em troca de quê eu estou fazendo isso»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «qual é o preço disso, além do dinheiro»
  ok  exameDaNoite         esperado exameDaNoite         «não devia ter reagido daquele jeito com ele»
  ok  exameDaNoite         esperado exameDaNoite         «perdi a paciência na reunião e me arrependi»
  ok  exameDaNoite         esperado exameDaNoite         «hoje eu tratei mal quem não tinha culpa»
  ok  exameDaNoite         esperado exameDaNoite         «exame da noite: o dia inteiro em revista»
  ok  exameDaNoite         esperado exameDaNoite         «fui injusto com o time hoje de manhã»
  erros: 1 de 38

========================================================================
4. CENÁRIO B — 21 + os 4 da M1 + os 3 da M2 (catálogo provável da M3)
========================================================================
  ok  woop                 esperado woop                 «quero voltar a correr de manhã três vezes por se»
  ok  seEntao              esperado seEntao              «sempre que abro o telefone na cama eu perco uma »
  ok  spec                 esperado spec                 «vou construir um módulo de exportação para o cor»
  ok  notaPermanente       esperado notaPermanente       «percebi que a origem do método importa mais do q»
  ok  destilar             esperado destilar             «preciso destilar este texto até sobrar uma frase»
  ok  palavra              esperado palavra              «não conhecia a palavra propedêutica, o que quer »
  ok  decisao              esperado decisao              «preciso decidir entre ficar no emprego e abrir a»
  ok  premortem            esperado premortem            «imagina que falhou: o aplicativo saiu e ninguém »
  ok  argumento            esperado argumento            «defendo que o catálogo precisa de origem verific»
  ok  leitura              esperado leitura              «terminei de ler o livro do Ahrens sobre notas»
  ok  feynman              esperado feynman              «não entendi como funciona o roteamento de bordo,»
  ok  dia                  esperado dia                  «hoje eu preciso fechar a volta e responder o don»
  ok  dia                  esperado dia                  «meu dia hoje tem três reuniões e o relatório»
  ok  analogia             esperado analogia             «isto já foi resolvido em outro campo, na aviação»
  ok  inversao             esperado inversao             «como garantir que falhe: eu deixaria o método se»
  ok  steelman             esperado steelman             «quem discorda diria que o catálogo já tem método»
  ok  divergencia          esperado divergencia          «preciso de dez opções antes de escolher o nome»
  ok  primeirosPrincipios  esperado primeirosPrincipios  «quais são as suposições que eu herdei sobre nota»
  ok  praticaDeliberada    esperado praticaDeliberada    «prática deliberada de leitura em voz alta, quinz»
  ok  atualizacao          esperado atualizacao          «qual a probabilidade de a volta 16 mesclar hoje»
  ok  expressiva           esperado expressiva           «hoje foi pesado demais, senti uma raiva que não »
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falha»
  ok  decisao              esperado decisao              «essa decisão é entre mudar de cidade ou renovar »
  ok  subtracao            esperado subtracao            «preciso simplificar o fecho da volta, virou um m»
  ok  subtracao            esperado subtracao            «o roteiro está complicado demais, o que eu tiro »
  ok  colunaEsquerda       esperado colunaEsquerda       «não disse o que pensei na conversa de ontem»
  ok  colunaEsquerda       esperado colunaEsquerda       «fiquei calado e devia ter falado sobre o prazo»
  ok  classeDeReferencia   esperado classeDeReferencia   «quanto tempo vai levar para eu terminar isso»
  ok  classeDeReferencia   esperado classeDeReferencia   «acho que termino em três dias, mas nunca acerto»
  ok  cincoPorques         esperado cincoPorques         «deu errado de novo, a mesma coisa da semana pass»
  ok  cincoPorques         esperado cincoPorques         «por que isso aconteceu, quero a causa raiz»
  ok  perguntaHamming      esperado perguntaHamming      «quais são os problemas importantes do meu campo»
  ok  perguntaHamming      esperado perguntaHamming      «no que eu deveria estar trabalhando este ano»
  ok  perguntaHamming      esperado perguntaHamming      «acho que estou trabalhando na coisa errada»
  ok  perguntaHamming      esperado perguntaHamming      «vale a pena trabalhar nisso ou é perda de tempo»
  ok  perguntaHamming      esperado perguntaHamming      «para onde isso me leva daqui a três anos»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «qual é o custo de oportunidade de tocar esta fre»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «o que eu deixo de fazer se eu aceitar isso»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «parece que não custa nada, é só apertar um botão»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «em troca de quê eu estou fazendo isso»
  ok  vistoNaoVisto        esperado vistoNaoVisto        «qual é o preço disso, além do dinheiro»
  ok  exameDaNoite         esperado exameDaNoite         «não devia ter reagido daquele jeito com ele»
  ok  exameDaNoite         esperado exameDaNoite         «perdi a paciência na reunião e me arrependi»
  ok  exameDaNoite         esperado exameDaNoite         «hoje eu tratei mal quem não tinha culpa»
  ok  exameDaNoite         esperado exameDaNoite         «exame da noite: o dia inteiro em revista»
  ok  exameDaNoite         esperado exameDaNoite         «fui injusto com o time hoje de manhã»
  erros: 1 de 46

========================================================================
5. LINHA DE BASE — as mesmas frases antigas sem nenhum candidato
========================================================================
  herdado  woop               esperado praticaDeliberada  «quero treinar o pedaço da fala que sempre fa»
  erros só com os 21: 1 | com a M2: 1 | com M1+M2: 1

========================================================================
6. ESQUEMA (volta 16) e regex que compilam
========================================================================
  erros de esquema: 0 | regex que não compilam: 0

========================================================================
VEREDITO M2
========================================================================
  falsos positivos dos 3 candidatos: 0
  erros herdados do catálogo (sem candidato nenhum): 1
  os mesmos com a M2 no fim: 1   com M1+M2: 1
  erros de esquema: 0 | regex que não compilam: 0
```

Resumo: **0 falso positivo** (nenhum dos três rouba frase alheia, nem dos 21 nem
dos 4 da M1), **0 colisão de ordem** (nenhuma regex antiga rouba as frases dos
três), **0 regressão** (o único erro é o `(?m)^quero` do WOOP, herdado e já
documentado em `achados-catalogo.md`), **0 erro de esquema** contra o
`Metodos.json` da volta 16 e **0 regex que não compila**.

A prova de que a proteção da Expressiva continua de pé está no cenário B: a
frase longa de desabafo continua indo para a Expressiva mesmo com o Exame da
noite e a Coluna da esquerda no catálogo — porque os dois entram no fim. É o
achado do arquivo `achados-catalogo.md`, reconfirmado nesta rodada.

## 6. Decisão do dono sobre a M1 (06/09, depois desta rodada)

Os quatro da M1 foram **aprovados**, com os Cinco porquês **condicionados** ao
fecho da citação de Ohno — **condição cumprida no item 1 desta rodada**. O
conserto da regex do Se–então foi aprovado para a M3. O achado da ordem virou
**contrato da M3**, escrito em [`achados-catalogo.md`](achados-catalogo.md) para
o worker que vai executar a colagem.

Os três candidatos desta rodada (Hamming, Bastiat, Sêneca) continuam propostos:
gosto não decidido, e a M3 **não** os cola.

## 7. Estado da trilha

Sete candidatos propostos em duas rodadas (Subtração, Coluna da esquerda, Classe
de referência, Cinco porquês, Pergunta de Hamming, O que se vê e o que não se
vê, Exame da noite), três rejeitados com o motivo escrito (Matriz de Eisenhower,
Cerca de Chesterton, Considerar o oposto), oito faculdades vazias fechadas se o
dono aceitar todos, e nenhuma linha do catálogo tocada. A M3 é a colagem, e ela
tem de ler `achados-catalogo.md` antes de abrir o arquivo.
