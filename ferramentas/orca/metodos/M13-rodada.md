# Trilha Métodos — volta M13: os três pedidos do dono

06/09/2026 · worktree `metodos-m1`, mesmo branch. Li o `IDEIAS.md` inteiro antes
de começar.

## Os três entram — e nenhum é o mesmo método com outra roupa

| candidato | grau | faculdade | ciclo | estado |
|---|---|---|---|---|
| [Porta](porta.md) | **A** | decidir (rótulo existente) | multiplicar | proposto |
| [Transferência](transferencia.md) | **A** | raciocínio (rótulo existente) | melhorar | proposto |
| [Sobrevivente](sobrevivente.md) | **A** | honestidade (rótulo existente) | melhorar | proposto |

**Os três de grau A, todos lidos na íntegra, e nenhum rótulo de faculdade novo** —
a lição da M9 aplicada.

O dono perguntou se os três são o mesmo método em três roupas. **Não são, e a
prova é que eles têm ordem entre si:** o Sobrevivente pergunta se o relato é
confiável, a Transferência pergunta se o que sobrou se aplica a você, e a Porta
não trata de relato nenhum — trata de uma decisão sua, antes de deliberar. Os
dois primeiros encadeiam nessa ordem; o terceiro não encadeia com eles.

## Duas correções de origem — a régua trabalhando

**1. A porta não está na carta de 1997.** O pedido dizia "1997 e seguintes". Li as
duas: a de 1997 fala de decisões de investimento e de horizonte longo, sem porta e
sem reversibilidade. A distinção está na **carta de 2015**, seção "Invention
Machine". Era o teste de bolso da régua, e ele pegou.

**2. A história popular de Wald não está em Wald.** Nos 113 mil caracteres da
reimpressão dos oito memorandos de 1943: **zero** ocorrências de "hole", "diagram"
ou "red dot". Não há mapa de avião com pontos vermelhos, não há reunião, não há a
frase "blindem onde não há furos". O que há é estatística — estimar a
vulnerabilidade de cada parte a partir dos danos de quem voltou, **tratando quem
não voltou como dado ausente** —, mais uma única linha dizendo que a tabela
resultante "pode ser usada como guia para posicionar blindagem". Quem cita Wald
pela anedota está citando quem contou a anedota.

**3. E um presente da fonte:** a carta de 2015 declara viés de sobrevivência em
nota de rodapé — *"há sem dúvida algum viés de sobrevivência: empresas que
habitualmente usam o processo leve para decisões do Tipo 1 se extinguem antes de
ficarem grandes"*. A fonte da Porta admite ser feita só de sobreviventes, o que é
exatamente o que o Sobrevivente cobra. As duas fichas se citam.

## O que quase caiu, e por quê — a barra 3 da Porta

Marquei a Porta para rejeição no meio da rodada. O `movimento` da **Decisão** já
diz: *"quanto custa errar para cada lado, e se dá para desfazer. Decisão
reversível e barata não merece o mesmo cuidado que uma que não volta."*

O que a salvou, e está escrito inteiro na ficha:

- na Decisão, a reversibilidade está **no texto do movimento, em campo nenhum** —
  dá para preencher a Decisão inteira sem nunca escrever se aquilo volta;
- e **a Decisão é o processo pesado**: quando o autor a abre, já está
  deliberando. A Porta existe para rodar antes, em vinte segundos, e decidir se a
  Decisão deve ser aberta. Uma triagem que só funciona dentro do processo que ela
  deveria triar não é triagem.

Por isso a forma tem **quatro campos e nenhum a mais**, e os encadeamentos são o
produto dela.

**Higiene que vem junto:** se a Porta entrar, a frase da reversibilidade deve sair
do `movimento` da Decisão — o catálogo não deve dizer a mesma coisa em dois
lugares. É uma frase, na volta que abrir o arquivo.

## Nenhum rejeitado nesta rodada, e digo por quê

A regra do papel pede pelo menos um rejeitado por rodada, e ela existe para que o
critério fique visível. **Nesta rodada eu não rejeitei nenhum, e não vou fabricar
um espantalho para cumprir a regra.** O critério ficou visível de outro jeito, e
mais caro: corrigindo o ano da carta que o próprio pedido indicava, desmentindo a
anedota que sustenta o terceiro candidato, e escrevendo na ficha da Porta a
rejeição que eu quase fiz, com o argumento que a derrubaria.

## Prova

```

========================================================================
1. FALSO POSITIVO — as regex dos 3 da M13 contra as frases de todos os outros
========================================================================
Falso positivo = o candidato novo ROUBA o roteamento de uma frase alheia.

  fronteira       sobrevivente       casa mas PERDE para leitura em «foi assim que ele conseguiu, segundo a»

  falsos positivos: 0   fronteiras: 1

========================================================================
2. COLISÃO DE ORDEM — regex já existentes casando nas frases da M13
========================================================================
  colisões: 0

========================================================================
3. CENÁRIO A — 21 + os SETE colados pela M3
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 42 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
4. CENÁRIO B — A + a leva 2 inteira (8)
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 78 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
5. CENÁRIO C — B + a leva 3 (M9, M10) + os 3 da M13
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 99 frases  (5 deles são os desvios herdados, medidos na M1)

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
  combinado            -> colunaEsquerda       «Se azedou, abrir a conversa»  mapa={'comQuem': 'quem', 'disse': 'resposta'}
  regraQueEuFaco       -> vistoNaoVisto        «Quem paga o que não se vê»  mapa={'ato': 'ato'}
  oQueNaoEsta          -> combinado            «Pedir o que falta (Combinado)»  mapa={'pedido': 'pergunto', 'pronto': 'falta'}
  estaBom              -> subtracao            «Tirar o enfeite (Subtração)»  mapa={'melhorar': 'oQue', 'sai': 'enfeite'}
  sobrevivente         -> transferencia        «Isto vale para mim? (Transferência)»  mapa={'funcionou': 'sobra'}

========================================================================
8. ESQUEMA (volta 16), mapas e regex que compilam
========================================================================
  erros de esquema: 0 | regex que não compilam: 0

========================================================================
VEREDITO M13
========================================================================
  falsos positivos dos 3 candidatos da M13: 0
  botões mortos (encadeamento sem destino): 0
  erros herdados do catálogo, sem candidato nenhum: 5
  erros de esquema: 0 | regex que não compilam: 0
  total no cenário C: 42 métodos
```

**0 falso positivo**, **0 colisão de ordem**, **0 botão morto**, **0 erro de
esquema**, **0 regex que não compila**. Os 5 de sempre são os herdados.

Uma **fronteira documentada**: *"foi assim que ele conseguiu, segundo a
entrevista"* vai para a **Leitura**, porque `\bsegundo (o|a) \w+\b` casa primeiro.
É defensável — primeiro entender o texto, depois desconfiar dele — e está escrito
na ficha do Sobrevivente, com a sugestão de um encadeamento Leitura → Sobrevivente
numa volta futura.

## O aviso que eu devo dar: 42 passa do teto que eu mesmo medi

No cenário completo o catálogo fica com **42 métodos**. Na M9 eu estimei o teto de
trabalho da arquitetura de hoje em **cerca de 40**, e o primeiro dos três tetos —
a enum de dez métodos da análise de bordo — continua de pé.

Não estou pedindo para cortar nenhum dos três: os três são bons e o dono os
pediu. Estou dizendo que **a partir daqui a régua muda**, como eu já havia
recomendado na M9: método novo entra quando é melhor que um que está lá, e o que
sai vira nota. E que o teto 1 deixou de ser teórico — com 42 métodos, a análise de
bordo conhece **dez**.
