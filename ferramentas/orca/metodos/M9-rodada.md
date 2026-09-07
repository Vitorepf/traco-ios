# Trilha Métodos — volta M9, sétima rodada de caça

06/09/2026 · worktree `metodos-m1`, mesmo branch.

## 1. O ângulo: perceber — e a M1 estava errada

Você deu a pista e ela estava certa. Na M1 eu escrevi que em percepção "não achei
nada com origem e movimento que mereçam". **O erro não era do mundo, era do meu
método de busca:** eu procurava em literatura de psicologia e de método, e lá de
fato só há treinamento clínico ou escrita criativa sem autor.

O que faltava era procurar **onde as pessoas treinam o olho profissionalmente** —
desenho, pintura, história natural, investigação. Foi a restrição de grau A da M7
que me obrigou a mudar de prateleira. Achei em vinte minutos, e os dois são de
domínio público.

| candidato | grau | faculdade | ciclo | estado |
|---|---|---|---|---|
| [Ver antes de nomear](verAntesDeNomear.md) | **A** | percepção (era vazia) | melhorar | proposto |
| [O que não está lá](oQueNaoEsta.md) | **A** (ficção — ver abaixo) | percepção | multiplicar | proposto |
| [Escada de inferência](rejeitado-escadaDeInferencia.md) | — | (percepção) | — | **REJEITADO — barra 3** |
| [Observação sem avaliação (CNV)](rejeitado-observacaoSemAvaliacao.md) | — | (percepção) | — | **REJEITADO — barra 3** |

### Ver antes de nomear — Ruskin, 1857

*"Sempre supomos que VEMOS o que apenas sabemos."* O registro cru num campo — só
o que uma câmera pegaria —, a conclusão em outro, e mais dois que são do Traço: o
que o mesmo registro também poderia significar, e o que seria preciso olhar para
separar as leituras.

É a lacuna mais cara que a coleção tinha: **os oito métodos de decisão do
catálogo trabalham em cima do que o autor achou que viu.**

### O que não está lá — Doyle, 1892

O cão que não latiu. Primeiro a LISTA do que deveria estar ali se o relato fosse
o que diz ser; só depois o que falta. Sem a lista antes, a ausência não aparece —
e é só isso que separa o método de um conselho.

**A régua não previa ficção, e esta ficha propõe a emenda:** ficção é grau A de
*forma* (obra, autor, ano, lida na íntegra) e o grau mais fraco que existe de
*conteúdo* — um personagem inventado nota uma ausência numa história escrita para
que ele a notasse. A emenda: **ficção obriga uma linha a mais — "é ficção; dá o
critério e o nome, e não estabelece nada"**. Sem ela, "Doyle, 1892" parece
evidência.

A ficha também nomeia o risco de uso: este método vira instrumento de
desconfiança se a lista for feita do que se teme em vez do que a própria história
promete.

### As duas rejeições

**Escada de inferência** estava pendente havia quatro rodadas como "melhor
candidato sem fonte acessível". **Agora está encerrada, e por outro motivo:** o
movimento entrou nesta rodada por uma porta com fonte melhor. A lição é de método
de busca — quando uma fonte não abre, a pergunta seguinte não é "como consigo
esse livro?", é "quem mais, com fonte aberta, cobre este movimento?".

**Observação sem avaliação (CNV)** cai por duplicar duas vezes: a distinção é o
Ver antes de nomear, e o resto da CNV está distribuído entre Coluna da esquerda,
Combinado e Reparação. A ficha registra que **não** é a fraqueza de evidência que
a mata, para ninguém ler aquilo como ataque à CNV.

## 2. O mapa — [`o-que-falta-no-catalogo.md`](o-que-falta-no-catalogo.md)

A entrega principal desta rodada. Três coisas que valem o clique:

**Um problema no jeito de contar, e ele era meu.** O catálogo tem 38 métodos e 31
rótulos de faculdade, 25 deles com um método só. Isso não é cobertura ampla: é
taxonomia gerada pelos métodos. Cada candidato meu chegava com um rótulo novo, e
"faculdade vazia" virou justificativa que se cumpre sozinha. O mapa desfaz a conta
e agrupa os 38 em **nove capacidades reais**.

**O que o mapa mostra:** um terço do catálogo é para decidir (8 métodos, mais três
orbitando) e, até esta rodada, zero para perceber. Três coberturas por acidente —
Destilar e Palavra estão em "aprender" e são de ofício; a Expressiva conta como
conduta e não é método, é a superfície de proteção; Dia e Destaque cobrem o mesmo
movimento.

**Onde você fica na mão:** a maior é **julgar uma coisa feita** — você mantém uma
esteira de quinze dimensões e recusa volta abaixo de nove, e nenhum método
pergunta *isto está bom?*, *quando parar de mexer?*, *isto é "não está bom" ou eu
me cansei?*. O instrumento existe (a ESTEIRA) e vive fora do catálogo, servindo
aos workers e não a você.

## 3. Quantos métodos o catálogo aguenta — e um achado de código

A resposta não é a Hicks, ou não é só ela. **Há três tetos, e o primeiro já
estourou.**

**Teto 1, e é o achado desta rodada:** `AnaliseDeBordo.GestoDeBordo` é uma enum
`@Generable` escrita à mão com **dez métodos**. O modelo de bordo — o que roda sem
conta e sem rede — só sabe devolver esses dez, enquanto o catálogo tem 21 e vai a
38. E em `Sessao.escolher` **o veredito do modelo vence a regex**, então o bordo
pode sobrescrever um roteamento correto do catálogo por um rótulo mais grosso.

O comentário do próprio arquivo diz *"os dois têm de rotear igual, senão ligar a
conta mudaria o comportamento do app"*. **Hoje ligar a conta muda o comportamento
do app, para onze dos vinte e um métodos já colados.** Não é preguiça de quem
escreveu — a geração guiada de bordo precisa de esquema estático —, mas é um teto
de código: enquanto ele existir, **cada método novo é meio método**.

**Teto 2:** colisão de regex. Cinco desvios medidos com 21; esta rodada achou mais
uma fronteira. Estimativa: até uns 45 se administra; acima disso o método novo
custa mais do que vale.

**Teto 3:** as superfícies onde você escolhe — 20 chips de filtro hoje, 37 depois
das levas; o Perfil; a frase do `Degraus.emPalavras`. Aí a Hicks vale inteira, e a
saída não é ter menos métodos: é agrupar pelas nove capacidades.

**O número: cerca de 40 é o teto de trabalho da arquitetura de hoje, e o catálogo
chega a 38 com a leva 2 e esta rodada.** A trilha está no fim da fase de caçar.
Depois da leva 3, minha recomendação é parar de acrescentar por ângulo novo e
passar a **trocar**: método novo entra quando é melhor que um que está lá, e o que
sai vira nota.

## 4. Um defeito meu, achado pelo teste

A regex de `regraQueEuFaco` (leva 2, já empacotada) tinha `fizesse\b`, que **não
casa "fizessem"** — a frase de teste "e se todos fizessem isso" não roteava.
Corrigido para `fizesse(m|mos)?`, reconferido, e o bloco foi regerado no
`leva-2.md` e na ficha. O erro passou pela M7 porque eu li o veredito agregado e
não a lista de falhas; nesta rodada eu li linha por linha.

## 5. Prova

```

========================================================================
1. FALSO POSITIVO — as regex dos 2 da M9 contra as frases de todos os outros
========================================================================
Falso positivo = o candidato novo ROUBA o roteamento de uma frase alheia.

  fronteira       verAntesDeNomear   casa mas PERDE para spec em «o que eu vi foi a tela travada por sei»

  falsos positivos: 0   fronteiras: 1

========================================================================
2. COLISÃO DE ORDEM — regex já existentes casando nas frases da M9
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
  erros: 5 de 41 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
4. CENÁRIO B — A + a leva 2 inteira (8)
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 77 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
5. CENÁRIO C — B + os 2 da M9
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 85 frases  (5 deles são os desvios herdados, medidos na M1)

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

========================================================================
8. ESQUEMA (volta 16), mapas e regex que compilam
========================================================================
  erros de esquema: 0 | regex que não compilam: 0

========================================================================
VEREDITO M9
========================================================================
  falsos positivos dos 2 candidatos da M9: 0
  botões mortos (encadeamento sem destino): 0
  erros herdados do catálogo, sem candidato nenhum: 5
  erros de esquema: 0 | regex que não compilam: 0
  total no cenário C: 38 métodos
```

**0 falso positivo**, **0 colisão de ordem**, **0 botão morto**, **0 erro de
esquema**, **0 regex que não compila**, nos três cenários (leva 1; + leva 2;
+ M9). Uma **fronteira documentada**: com o objeto observado sendo uma tela, a
regex larga da Especificação vence o Ver antes de nomear — mesma classe dos cinco
desvios herdados, mesmo conserto. Os 5 desvios de sempre continuam sendo os
herdados. No cenário C o catálogo teria 38 métodos.

A suíte do app não rodou: esta volta não abre simulador nem `xcodebuild`.
