# Trilha Métodos — volta M4, terceira rodada

06/09/2026 · worktree `metodos-m1`, mesmo branch · pesquisador de métodos.

`Traco/Modelo/Metodos.json` continua **fechado** até a M3. Barra de quatro,
forma livre.

## 1. Onde eu ataquei, e por quê

Somando M1 e M2, o catálogo cobre 22 faculdades. Descartadas as que a tarefa
proíbe revisitar (produtividade, atenção, memória, valores — esta última já
fechada pelo Exame da noite), sobrou perguntar de outro jeito: **o que um
construtor faz o dia inteiro e o catálogo não instrumenta?**

Três buracos, e nenhum deles é "faculdade com um método só" — são faculdades com
nenhum:

| buraco | o que o catálogo tinha | candidato |
|---|---|---|
| o fato que vai CONTRA, no instante em que aparece | Argumento e Atualização pedem a objeção *imaginada*; nada captura a que chega sem convite | A nota do fato contrário |
| **número** | 21 métodos de palavras; o único número é o 0–100 da Atualização, que é grau de crença, não grandeza do mundo | Ordem de grandeza |
| **parar** | três métodos para começar bem (Especificação, Pré-mortem, Decisão), nenhum para parar | Começaria hoje? |

O segundo é o achado mais desconfortável da rodada: **um catálogo inteiro sobre
pensar, sem um único método que produza um número sobre o mundo.**

## 2. Os candidatos

| candidato | faculdade | ciclo | estado |
|---|---|---|---|
| [A nota do fato contrário](fatoContrario.md) | honestidade (vazia) | melhorar | proposto |
| [Ordem de grandeza](ordemDeGrandeza.md) | quantidade (vazia) | multiplicar + melhorar | proposto |
| [Começaria hoje?](comecariaHoje.md) | desapego (vazia) | multiplicar | proposto |
| [Critérios de parada](rejeitado-criteriosDeParada.md) | (desapego) | — | **REJEITADO — barra 3** |
| [Afirmações positivas](rejeitado-afirmacoesPositivas.md) | (sentir) | — | **REJEITADO — barra 4** |

Fontes desta rodada, todas lidas no texto integral: a autobiografia de Darwin
(Gutenberg), o relatório de Fermi sobre Trinity, e o fac-símile da primeira
edição de Jevons (1871) na digitalização da Universidade de Toronto. Para o
resumo de Wood, Perunovic e Lee (2009), Europe PMC. Onde eu **não** li — o
Arkes e Blumer de 1985, atrás de paywall — está escrito na ficha, no lugar em
que um leitor apressado tropeçaria nele.

### As duas rejeições, e por que valem

**Critérios de parada** cai na barra 3: o Pré-mortem já tem o campo `sinal` com
dois encadeamentos em cima dele (virar Se–então, conferir em 14 dias), e o
"Começaria hoje?" desta rodada cobre o outro lado do tempo. Entre os dois, o
movimento está servido antes e depois de começar.

**Afirmações positivas** é a primeira rejeição desta trilha na **barra 4**, e é a
mais interessante que apareceu até aqui. O movimento é próprio: ninguém no
catálogo o faz. Ele cai porque **a identidade do método é uma alegação de
eficácia** que a melhor evidência disponível contradiz — Wood, Perunovic e Lee
(2009) relatam que repetir a afirmação piora o estado de quem tem autoestima
baixa, justamente quem a procuraria. Escrever a proveniência honesta esvazia o
método.

E há a coincidência que fecha o argumento: **o app já tem uma defesa contra isso
em código.** `AnaliseLocal.avisoWood` devolve "Afirmação sem prova não gruda" —
o nome da constante aponta para o mesmo estudo. Aceitar o candidato seria colar
no catálogo um método que o próprio motor interrompe.

## 3. Encadeamentos entre os novos — [`encadeamentos.md`](encadeamentos.md)

Até a M2, cada candidato encadeava só com os 21 antigos. Esta rodada liga os
novos entre si: **sete ligações**, das quais cinco já estão no JSON e duas
esperam a leva do destino.

Antes de escrever qualquer uma, li o código — e achei a regra que faltava:

> `Sessao.encadear` sai em silêncio quando o destino não está no catálogo, mas a
> UI desenha o botão do mesmo jeito. **Encadeamento sem destino = botão que
> acende e não faz nada.**

Daí a regra desta trilha: **um encadeamento só entra na mesma leva do destino,
ou depois.** Conferido por teste em três cenários de colagem: zero botões
mortos.

A ligação mais importante do mapa é **A pergunta de Hamming → Subtração**:
escolher o problema importante sem tirar nada da mesa é fantasia, e sem esse
botão a Pergunta de Hamming produz uma lista bonita e nenhuma mudança. As outras
seis, com o motivo de cada uma e a lista do que eu deliberadamente NÃO liguei,
estão no arquivo.

## 4. O que a forma livre está pedindo do app — seção 7 de [`achados-catalogo.md`](achados-catalogo.md)

Seis pedidos, juntados num lugar só, com custo estimado de fora e o que o autor
ganha em cada um. Em ordem de recomendação:

1. **Campo repetível** — pedido por QUATRO métodos, um deles (a Divergência) já
   no catálogo. Custo baixo, nada de tela nova, e a Divergência ganharia o
   movimento que hoje ela só descreve: contar até dez e cobrar quem parou na
   terceira.
2. **Botão de encadeamento sem destino** — o defeito achado nesta rodada.
   Conserto de minutos.
3. **Compromisso recorrente** — dois métodos de ritmo (Hamming toda semana,
   Sêneca toda noite), com um caminho pobre e honesto se o calendário não souber
   recorrência.
4. **A Classe de referência lendo o corpus** — o maior ganho e o maior custo, e
   o único que muda a natureza do app: de onde a nota é escrita para onde a nota
   é consultada. Com um corte barato descrito na seção (só notas da mesma forma
   com campo de volta preenchido, por data, sem ranking e sem resumo).
5. **Captura direta para uma forma** — pequeno, e casa com o que a trilha Fora do
   app já entregou.
6. **Campo emparelhado (duas colunas)** — o único em que eu recomendaria
   esperar: faça o repetível primeiro e reavalie.

Nenhum é bloqueio para a M3.

## 5. O que procurei e não achei

- **Negociação (BATNA)**, terceira rodada seguida em que ele não entra: continua
  sem cópia legítima acessível de *Getting to Yes*. Se o dono tiver o livro,
  fecho a ficha em uma rodada. Não vou baixar a régua para ele.
- **Percepção**, de novo: tentei a escada de inferência (Argyris) como
  instrumento de separar o dado observável do sentido acrescentado. O movimento
  é real e não duplica ninguém, mas **não achei fonte primária legível** — está
  em *Overcoming Organizational Defenses* (1990) e no Fieldbook de Senge (1994),
  os dois inacessíveis, e o artigo de 1991 da HBR que eu tenho inteiro não
  descreve a escada. Fica como o melhor candidato pendente de fonte, junto com o
  BATNA.
- **Ritmo e corpo**: nada com origem e movimento que mereçam.

Faculdades ainda vazias, e agora o motivo é o mesmo para as duas mais
promissoras: **negociação e percepção estão vazias por falta de acesso à fonte,
não por falta de método.** As outras (atenção, memória) continuam vazias porque
nada bom existe.

## 6. Prova

Script descartável, não commitado (`scratchpad/testar_regex_m4.py`). Três
cenários, na ordem em que as colagens devem acontecer: **A** = 21 + os 4
aprovados (o que a M3 cola), **B** = A + os 3 da M2, **C** = B + os 3 da M4.

```

========================================================================
1. FALSO POSITIVO — as regex dos 3 da M4 contra as frases de todos os outros
========================================================================
Falso positivo = o candidato novo ROUBA o roteamento de uma frase alheia.


  falsos positivos: 0   fronteiras: 0

========================================================================
2. COLISÃO DE ORDEM — regex já existentes casando nas frases da M4
========================================================================
  colisões: 0

========================================================================
3. CENÁRIO A — 21 + os 4 aprovados (o que a M3 cola)
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 34 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
4. CENÁRIO B — A + os 3 da M2
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 40 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
5. CENÁRIO C — B + os 3 da M4
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 52 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
6. ENCADEAMENTOS — nenhum botão morto em nenhum cenário
========================================================================
O app (Sessao.encadear) IGNORA em silêncio um encadeamento cujo destino não
está no catálogo, mas a UI (CamposFormaView) desenha o botão do mesmo jeito.
Logo: um encadeamento só pode entrar junto com o destino, ou depois dele.

  botões mortos: 0

========================================================================
7. ENCADEAMENTOS — o mapa entre os métodos NOVOS (o que esta rodada acrescentou)
========================================================================
  classeDeReferencia   -> cincoPorques         «Por que os parecidos terminaram assim»  mapa={'aconteceu': 'parecidos'}
  cincoPorques         -> subtracao            «Tirar a peça (Subtração)»  mapa={'melhorar': 'aconteceu', 'sai': 'controlo'}
  perguntaHamming      -> subtracao            «O que sai para caber o ataque»  mapa={'melhorar': 'trabalhando', 'ia': 'ataque'}
  vistoNaoVisto        -> subtracao            «Tirar isto (Subtração)»  mapa={'melhorar': 'ato'}
  exameDaNoite         -> colunaEsquerda       «Abrir a conversa (Coluna da esquerda)»  mapa={'comQuem': 'naoRepito'}
  ordemDeGrandeza      -> classeDeReferencia   «Tem casos parecidos? Classe de referência»  mapa={'estimo': 'quantidade'}
  comecariaHoje        -> subtracao            «Se parar, o que sai»  mapa={'melhorar': 'oQue', 'sai': 'oQue'}

========================================================================
8. ESQUEMA (volta 16), mapas e regex que compilam
========================================================================
  erros de esquema: 0 | regex que não compilam: 0

========================================================================
VEREDITO M4
========================================================================
  falsos positivos dos 3 candidatos: 0
  botões mortos (encadeamento sem destino): 0
  erros herdados do catálogo, sem candidato nenhum: 5
  erros de esquema: 0 | regex que não compilam: 0
  total no cenário C: 31 métodos
```

Resumo: **0 falso positivo**, **0 colisão de ordem**, **0 botão morto** nos três
cenários, **0 erro de esquema**, **0 regex que não compila**. Os 5 erros que
aparecem em todos os cenários são os desvios herdados do catálogo, medidos na
M1 e documentados na seção 5 de `achados-catalogo.md` — a diferença com e sem
os dez candidatos continua sendo **zero**.

Como sempre: a suíte do app não rodou, porque esta volta não abre simulador nem
`xcodebuild`. O G1 é da M3.

## 7. Estado da trilha, em três rodadas

Dez candidatos propostos (4 aprovados, 6 esperando gosto), cinco rejeitados com
o motivo escrito, oito faculdades vazias fechadas se o dono aceitar tudo, um
contrato de colagem, um mapa de encadeamentos e seis pedidos de app documentados.
Nenhuma linha do catálogo tocada.
