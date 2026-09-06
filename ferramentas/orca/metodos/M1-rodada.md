# Trilha Métodos — volta M1, primeira rodada

06/09/2026 · worktree `metodos-m1` · pesquisador de métodos.

> **DECISÃO DO DONO (06/09):** os quatro candidatos desta rodada estão
> **APROVADOS**. Os Cinco porquês entram **condicionados** ao fecho da citação
> de Ohno — condição **cumprida na volta M2**, com a citação trocada por uma
> fonte lida na íntegra (ver [`cincoPorques.md`](cincoPorques.md) e
> [`M2-rodada.md`](M2-rodada.md)). A colagem é a **volta M3**, que só abre
> depois de a volta 16 mesclar, e cujo contrato está em
> [`achados-catalogo.md`](achados-catalogo.md).

**Nada foi colado no catálogo.** A volta 16 está com o `Traco/Modelo/Metodos.json`
aberto e mescla em main antes desta trilha; editar agora era conflito garantido.
A entrega desta rodada é a proposta pronta e defendida, no esquema NOVO (com
`proveniencia`), lida de `git show Vitorepf/volta-16-metodos:Traco/Modelo/Metodos.json`.
A colagem é a volta seguinte da trilha.

Barra aplicada: a de **quatro** (correção do dono, 06/09 13:25), com a forma
livre.

## O que saiu

| candidato | faculdade | ciclo | estado |
|---|---|---|---|
| [Subtração](subtracao.md) | simplificação (vazia) | melhorar | **aprovado**, aguarda a M3 |
| [Coluna da esquerda](colunaEsquerda.md) | relação (vazia) | melhorar | **aprovado**, aguarda a M3 |
| [Classe de referência](classeDeReferencia.md) | previsão (vazia) | multiplicar + melhorar | **aprovado**, aguarda a M3 |
| [Cinco porquês](cincoPorques.md) | causa (vazia) | multiplicar + melhorar | **aprovado**, condição da citação cumprida na M2 |
| [Matriz de Eisenhower](rejeitado-matrizEisenhower.md) | (foco) | — | **REJEITADO — barra 3, duplica o Destaque e o Dia** |

As quatro faculdades propostas estão vazias hoje. Nenhuma delas foi escolhida
por estar vazia: o buraco só decidiu a ordem de procurar.

## O que a forma livre trouxe

A correção das 13:25 mudou duas propostas de verdade, e isso está escrito nas
fichas:

- **Coluna da esquerda** quer duas colunas EMPARELHADAS, linha a linha. Vai
  achatada em dois campos longos, que roda hoje. Volta de laço: campo `par`.
- **Cinco porquês** quer uma cadeia de profundidade VARIÁVEL, que para quando a
  causa é controlável. Vai como cinco caixas numeradas, que roda hoje. Volta de
  laço: campo `repete` — que serviria também à Divergência (dez opções) e à
  Classe de referência (os casos parecidos). Três métodos pedindo a mesma coisa
  é sinal: **é a próxima volta de app desta trilha.**
- **Classe de referência** pede, no limite, que o Traço leia o corpus e ofereça
  os casos parecidos que o autor já escreveu. É a volta mais interessante que
  esta rodada achou, e não é bloqueante.

Nenhuma proposta toca a Expressiva, a nota selada ou as rotas protegidas. A
Coluna da esquerda passa perto da Expressiva e a ficha dela prova, com teste,
que a Expressiva continua vencendo o texto longo de desabafo — e por isso o
método **tem de ficar no fim do catálogo**, nunca antes dela.

## Achados para a volta de colagem

> **Estes achados foram consolidados em [`achados-catalogo.md`](achados-catalogo.md)**
> na volta M2, com a regra do roteador escrita por extenso e a correção sugerida
> para o WOOP. A volta de colagem lê aquele arquivo ANTES de abrir o `Metodos.json`.

1. **Ordem: colar os quatro no FIM do catálogo.** Testei a alternativa (os
   quatro antes da Especificação) e ela é PIOR: a Coluna da esquerda passa a
   roubar o desabafo da Expressiva e a Subtração rouba uma frase de construção
   da Especificação. Está no bloco 4 da saída.
2. **Defeito antigo, achado pela prova:** a regex do Se–então é
   `sempre que|toda vez|não consigo parar`, sem `\b`. "sempre que" casa dentro
   de "sempre **que**bra", "sempre **que**ria", "sempre **que**ro". Sugestão:
   `\bsempre que\b`. Não é desta rodada corrigir (arquivo fechado), mas é
   barato e a trilha achou.
3. **Outros cinco desvios que já existem hoje**, sem relação com os candidatos
   (bloco 7 da saída): `(?m)^quero` do WOOP captura qualquer frase que comece
   com "quero" — leva para o WOOP o que era Pré-mortem, Feynman, Primeiros
   princípios e Prática deliberada; e "ideia" da Nota permanente captura uma
   frase de Destilar. A diferença com e sem os candidatos é **zero**.

## O que procurei e não achei

- **Atenção**: Pomodoro e afins. Cronômetro não é instrumento de pensamento, e
  o Traço já tem os quinze minutos da Expressiva. Nada digno.
- **Memória**: repetição espaçada (Ebbinghaus e a literatura de espaçamento).
  Tem evidência de sobra, mas não é método de nota: **é o Recordar**, que já é
  mecanismo do app. Método seria duplicar infraestrutura.
- **Valores e ética**: a *premeditatio malorum* estoica (Sêneca) tem origem
  verificável, mas o movimento é o do Pré-mortem — cai na barra 3.
- **Negociação**: a melhor alternativa fora do acordo (Fisher e Ury,
  *Getting to Yes*, 1981). Origem verificável, movimento próprio (nomear e
  MELHORAR a alternativa antes de sentar à mesa), não duplica ninguém.
  **Não deu tempo de trabalhar nesta rodada; fica como primeiro candidato da
  M2.**
- **Percepção e corpo**: nada com origem e movimento que mereçam.

Faculdades que continuam vazias de propósito, porque nada bom apareceu:
atenção, memória, valores, percepção. Isso é resultado, não falta.

## Prova das regex

Script descartável, não commitado, em
`scratchpad/testar_regex.py` (roda as regex dos 21 do branch da volta 16 mais
as dos 4 candidatos, na mesma ordem e com a mesma regra do app:
`AnaliseLocal.detectarGesto` devolve o PRIMEIRO método cuja regex casa no texto
em minúsculas; a Expressiva só entra acima de 120 caracteres).

```

========================================================================
1. FALSO POSITIVO — as regex dos 4 NOVOS contra as frases dos 21 antigos
========================================================================
Regra: nenhuma regex nova pode casar numa frase que é de outro método.

  fronteira       subtracao            casa mas PERDE para spec em «vou construir uma função para simplificar o »
                  regex: \bsimplificar\b|\benxugar\b|\bcortar pela metade\b|\bmenos (é|e) mais\b
  fronteira       colunaEsquerda       casa mas PERDE para expressiva em «na reunião com o chefe eu senti uma raiva en»
                  regex: \bn[ãa]o (disse|falei|consegui dizer)\b|\bengoli\b|\bfiquei calad[oa]\b|\bdeixei passar\b
  fronteira       colunaEsquerda       casa mas PERDE para expressiva em «na reunião com o chefe eu senti uma raiva en»
                  regex: \b(essa|aquela) conversa (com|foi)\b|\ba conversa com (o|a|ele|ela)\b|\bna reuni[ãa]o com\b

  falsos positivos (o método novo rouba a frase de outro): 0
  fronteiras (casa, mas o método certo vence por vir antes): 3

========================================================================
2. FALSO POSITIVO AO CONTRÁRIO — as 21 regex antigas contra as frases novas
========================================================================
Não é defeito das minhas regex; é ORDEM do catálogo. Quem casa primeiro vence.

  COLISÃO  seEntao              casa antes em «sempre quebra no mesmo ponto, qual é a causa» (queria cincoPorques)
           regex antiga: sempre que|toda vez|não consigo parar
  colisões de ordem: 1

========================================================================
3. ROTEAMENTO REAL — catálogo na ordem (21 + 4 no fim), como o app faz
========================================================================
  ok  woop                 esperado woop                 «quero voltar a correr de manhã três vezes por semana»
  ok  woop                 esperado woop                 «preciso começar a estudar alemão antes do fim do ano»
  ok  seEntao              esperado seEntao              «sempre que abro o telefone na cama eu perco uma hora»
  ok  seEntao              esperado seEntao              «toda vez que sento para escrever eu abro o navegador»
  ok  spec                 esperado spec                 «vou construir um módulo de exportação para o corpus»
  ok  spec                 esperado spec                 «a tela de perfil precisa mostrar a proveniência do m»
  ok  notaPermanente       esperado notaPermanente       «percebi que a origem do método importa mais do que o»
  ok  notaPermanente       esperado notaPermanente       «entendi que a nota só gruda quando eu escrevo com as»
  ok  destilar             esperado destilar             «preciso destilar este texto até sobrar uma frase»
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois numa fras»
  ok  palavra              esperado palavra              «não conhecia a palavra propedêutica, o que quer dize»
  ok  palavra              esperado palavra              «significa alguma coisa parecida com prolegômeno»
  ok  decisao              esperado decisao              «preciso decidir entre ficar no emprego e abrir a emp»
  ok  decisao              esperado decisao              «essa decisão é entre mudar de cidade ou renovar o co»
  ok  premortem            esperado premortem            «imagina que falhou: o aplicativo saiu e ninguém abri»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de novembro»
  ok  argumento            esperado argumento            «defendo que o catálogo precisa de origem verificável»
  ok  argumento            esperado argumento            «a tese é que a nota selada protege a escrita pessoal»
  ok  leitura              esperado leitura              «li que a memória de recuperação vale mais que a rele»
  ok  leitura              esperado leitura              «terminei de ler o livro do Ahrens sobre notas»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a compressão»
  ok  feynman              esperado feynman              «não entendi como funciona o roteamento de bordo, vou»
  ok  dia                  esperado dia                  «meu dia hoje tem três reuniões e o relatório»
  ok  dia                  esperado dia                  «hoje eu preciso fechar a volta e responder o dono»
  ok  analogia             esperado analogia             «isto já foi resolvido em outro campo, na aviação ele»
  ok  analogia             esperado analogia             «é como se o catálogo fosse uma caixa de ferramentas,»
  ok  inversao             esperado inversao             «como garantir que falhe: eu deixaria o método sem or»
  ok  inversao             esperado inversao             «vou pensar ao contrário, qual o pior jeito de escrev»
  ok  steelman             esperado steelman             «quem discorda diria que o catálogo já tem métodos de»
  ok  steelman             esperado steelman             «vou escrever a posição contrária no melhor antes de »
  ok  divergencia          esperado divergencia          «preciso de dez opções antes de escolher o nome»
  ok  divergencia          esperado divergencia          «vou fazer um brainstorm de todas as possibilidades d»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípios»
  ok  primeirosPrincipios  esperado primeirosPrincipios  «quais são as suposições que eu herdei sobre notas»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falha»
  ok  spec                 esperado spec                 «vou construir uma função para simplificar o cadastro»
  ok  expressiva           esperado expressiva           «na reunião com o chefe eu senti uma raiva enorme, do»
  ok  praticaDeliberada    esperado praticaDeliberada    «prática deliberada de leitura em voz alta, quinze mi»
  ok  atualizacao          esperado atualizacao          «qual a probabilidade de a volta 16 mesclar hoje»
  ok  atualizacao          esperado atualizacao          «quanto eu acredito que o roteamento local basta sem »
  ok  expressiva           esperado expressiva           «hoje foi pesado demais, senti uma raiva que não pass»
  ok  None                 esperado None                 «responder o dono
fechar a volta
rever o catálogo»
  ok  subtracao            esperado subtracao            «preciso simplificar o fecho da volta, virou um monst»
  ok  subtracao            esperado subtracao            «o roteiro está complicado demais, o que eu tiro dele»
  ok  subtracao            esperado subtracao            «cheio de etapas que ninguém usa, quero enxugar»
  ok  subtracao            esperado subtracao            «vou cortar pela metade a lista de perguntas»
  ok  subtracao            esperado subtracao            «menos é mais aqui: tirar algumas partes antes de acr»
  ok  colunaEsquerda       esperado colunaEsquerda       «não disse o que pensei na conversa de ontem»
  ok  colunaEsquerda       esperado colunaEsquerda       «fiquei calado e devia ter falado sobre o prazo»
  ok  colunaEsquerda       esperado colunaEsquerda       «engoli a resposta e saí da sala»
  ok  colunaEsquerda       esperado colunaEsquerda       «aquela conversa com o cliente foi mal, deixei passar»
  ok  colunaEsquerda       esperado colunaEsquerda       «o que eu queria ter dito era que aquilo não cabia no»
  ok  classeDeReferencia   esperado classeDeReferencia   «quanto tempo vai levar para eu terminar isso»
  ok  classeDeReferencia   esperado classeDeReferencia   «minha estimativa é de duas semanas»
  ok  classeDeReferencia   esperado classeDeReferencia   «acho que termino em três dias, mas nunca acerto»
  ok  classeDeReferencia   esperado classeDeReferencia   «em quanto tempo eu entrego essa parte»
  ok  classeDeReferencia   esperado classeDeReferencia   «fica pronto em uma semana, é o meu chute de prazo»
  ok  cincoPorques         esperado cincoPorques         «deu errado de novo, a mesma coisa da semana passada»
  ok  cincoPorques         esperado cincoPorques         «por que isso aconteceu, quero a causa raiz»
  ok  cincoPorques         esperado cincoPorques         «falhou de novo na hora de fechar»
  XX  seEntao              esperado cincoPorques         «sempre quebra no mesmo ponto, qual é a causa»
  ok  cincoPorques         esperado cincoPorques         «vou fazer os cinco porquês disso aqui»
  ok  cincoPorques         esperado cincoPorques         «o build quebrou de novo, qual foi a causa»

========================================================================
4. ROTEAMENTO com os 4 novos ANTES da Especificação (ordem proposta)
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois numa fras»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de novembro»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a compressão»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípios»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falha»
  XX  subtracao            esperado spec                 «vou construir uma função para simplificar o cadastro»
  XX  colunaEsquerda       esperado expressiva           «na reunião com o chefe eu senti uma raiva enorme, do»
  XX  seEntao              esperado cincoPorques         «sempre quebra no mesmo ponto, qual é a causa»
  erros nesta ordem: 8 de 63 frases

========================================================================
5. As regex compilam (o que TracoTests.todaRegexDoCatalogoCompila cobra)
========================================================================
  regex que não compilam: 0

========================================================================
6. JSON dos candidatos — esquema da volta 16
========================================================================
  erros de esquema: 0

========================================================================
7. LINHA DE BASE — os 21 sozinhos, sem os candidatos
========================================================================
Separa o que já errava antes desta rodada do que os candidatos causaram.

  herdado  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  herdado  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  herdado  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  herdado  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  herdado  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros já existentes no catálogo, sem os candidatos: 5
  os mesmos com os candidatos no catálogo: 5  (diferença: 0)

========================================================================
VEREDITO
========================================================================
  falsos positivos das regex novas: 0
  erros de roteamento (ordem atual, novos no fim): 6
  erros de roteamento (ordem proposta, novos antes da Especificação): 8
  erros de esquema: 0   regex que não compilam: 0
```

Resumo da prova: **0 falso positivo** (nenhuma frase dos 21 é roubada por um
candidato), **0 regressão** (os mesmos 5 desvios antes e depois), **0 erro de
esquema** contra o `Metodos.json` da volta 16 (chaves, `funcao` da proveniência,
campos, encadeamentos que apontam para método e campo existentes, `recordar`,
`compromisso`, id não repetido), **0 regex que não compila** — que é o que o
teste `todaRegexDoCatalogoCompila` cobra na suíte.

O que a prova NÃO cobre: a suíte de verdade do app não rodou, porque esta volta
não abre simulador nem `xcodebuild` (ordem da tarefa) e porque não editei o
`Metodos.json`. O portão G1 fica para a volta de colagem, com os quatro objetos
dentro do arquivo.
