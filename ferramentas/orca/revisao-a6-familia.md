# G3 — revisão da volta A-6 (a confissão curta é confissão)

Branch `Vitorepf/volta-a6-familia`, commit `fb8d2e9`, base `main`. Revisor
independente (Claude Opus 5) — **o mesmo que achou o defeito no re-G3 da M3**.
Simulador **iPhone 17 Pro (teste 2) `B91C8DEF`**, 06/09/2026, 23h.
Nada foi editado nem commitado no código nesta revisão.

**Veredito: CORRIGIR ANTES — lista mínima de QUATRO linhas, todas em `SPEC.md`
e no arquivo de teste. Nenhuma toca `Traco/Analise`.**
O conserto de código está **certo e provado**: a confissão curta fica com o
autor, as quatro réguas não mudaram de lado, e o defeito que eu achei está
fechado nos dois regimes de tamanho. O que segura são afirmações do relato que
não sobrevivem à medida — a mesma classe que eu bloqueei no G3, menor em alcance.

---

## 0. Como eu medi (o binário verbatim, de novo)

Segunda réplica do roteador (`rota2`), compilada com `swiftc`, em que **nada foi
retranscrito**: as linhas 113/122/136/148/153/170–188/195/200/212/218 (léxicos e
teto) e as funções inteiras `eEscritaPessoal` (223–236), `duasDeDuplaVida`
(240–249) e `detectarGesto` (267–287) entram por `sed` **verbatim** do
`AnaliseLocal.swift`; o catálogo vem do `Metodos.json` real e os sete da M3 saem
do próprio arquivo de teste, extraídos por parser, na ordem de nome de arquivo
que `Catalogo.recarregar` usa.

**Validação antes de eu confiar nela:** a réplica reproduz, uma a uma, **as 141
saídas que a suíte verde afirma** — 64 protegidas + 13 com gancho em silêncio ou
Expressiva, 6 legítimas nos seus métodos, 58 de trabalho nas suas portas, com o
catálogo de 28 onde o teste usa 28 e de 21 onde o teste roda fora do
`comOsNovos`. **0 divergência.** Réplica que acerta 141/141 contra a
implementação real mede a implementação real.

---

## 1. As quatro perguntas que me foram feitas

### a) A confissão curta fica nota livre — **SIM**

```
[36 <120] fam 4=true guarda=true porta exameDaNoite=true rota=silencio
          «Não devia ter reagido assim com ele.»
```

É a frase exata da minha captura `m3-reg3-01-confissao-curta-vestida.png`, a que
abriu a volta. E o par dela continua do mesmo lado: `«Fui grosso com o meu irmão
hoje.»` (32) → silêncio. **A assimetria que eu chamei de arbitrária não existe
mais.**

**Controle negativo, que é o que faz a medida valer:** recompilei a réplica com
`não devia ter` de volta na família 5 (só a linha do léxico trocada, nada mais) e
a régua nova fica VERMELHA — e **só ela**:

```
✘ protegida vestida: exameDaNoite ← «Não devia ter reagido assim com ele.» [36]
✘ curta não calada:  exameDaNoite ← «Não devia ter reagido assim com ele.» [36]
réplica: 2 divergência(s)
```

Nenhuma outra das 141 muda. O conserto é do tamanho que ele diz ser.

### b) As frases curtas novas existem e são curtas de verdade — **SIM, e melhor do que o relato promete**

Medi as sete uma a uma: o tamanho, a família declarada contra o léxico real, a
guarda, a porta que a levaria vestida, e o destino.

| sonda | chars | família declarada | bate na família | guarda | porta viva | rota |
|---|---|---|---|---|---|---|
| Hoje eu fiz besteira e chorei escondido no carro. | 49 | 1a | ✅ | ✅ | exameDaNoite ✅ | silêncio |
| Toda vez que abro o chat eu fico ansioso pra caramba. | 53 | 1b | ✅ | ✅ | seEntao ✅ | silêncio |
| Percebi que eu não presto pra ninguém. | 38 | 2 | ✅ | ✅ | notaPermanente ✅ | silêncio |
| Hoje eu preciso trabalhar e não durmo desde terça. | 50 | 3 | ✅ | ✅ | dia ✅ | silêncio |
| Não devia ter reagido assim com ele. | 36 | 4 | ✅ | ✅ | exameDaNoite ✅ | silêncio |
| Fui grosso com o meu irmão hoje. | 32 | 4 | ✅ | ✅ | exameDaNoite ✅ | silêncio |
| Foi pesado e eu fiquei calada. | 30 | 5 | ✅ | ✅ | colunaEsquerda ✅ | silêncio |

Sete de sete **abaixo** do teto (30 a 53 caracteres, o teto é 120), sete de sete
com gancho VIVO na porta declarada — sem a porta a sonda não mediria nada, e ele
próprio escreveu isso no comentário. **E seis das sete são EXCLUSIVAS**: acionam
uma família e só uma, o que é a propriedade que faz a sonda medir a sua família.
A sétima (a 5) aciona 1b+5, e isso está **declarado no teste** como a regra da
06i, não escondido. Este item é o que vale mais na volta, e ele está bem feito.

### c) Nenhuma das 4 réguas mudou de lado — **NENHUMA**

| régua | frases | resultado |
|---|---|---|
| protegidas | 64 (57 + as 7 novas) | 64 em silêncio ou Expressiva |
| com gancho | 13 | 13 em silêncio ou Expressiva |
| legítimas | 6 | 6 no método delas |
| de trabalho | 58 | 58 na porta delas |

**141 de 141, 0 divergência**, na réplica; e na suíte real, no meu UDID, sob
`com-trava.sh`: `✔ Test run with 780 tests in 130 suites passed after 7.092
seconds.` + `** TEST SUCCEEDED **`, **0 `warning:` no log inteiro**. Confere com
o número declarado na ADR (780/130).

### d) A frase da ADR passou a ser verdadeira — **QUASE. Falta uma palavra, e é uma palavra que a volta ACRESCENTOU**

A parte principal é verdadeira e eu a provei do jeito duro — os **17 ramos** do
Exame da noite, um a um, nos **dois** regimes de tamanho (curta, e a mesma frase
com o rabo de 140 pontos que a régua de alcance usa):

| | antes (`main`) | depois (A-6) |
|---|---|---|
| ramos que chegam ao Exame, frase CURTA | 9 de 17 | **5 de 17** |
| ramos que chegam ao Exame, frase LONGA | 5 de 17 | **5 de 17** |
| ramos que MUDAM de lado com o teto | **4** (`não devia ter feito/reagido/agido/tratado`) | **0** |

**Zero ramos mudam de lado.** É a prova exata do que a volta se propôs: a
afirmação de contrato passa a valer dos dois lados do teto. E a conta da ADR
("era 7 de 11") confere para o subconjunto de confissão: os 11 ramos de
confissão fecham 11 de 11 agora, contra 7 de 11 antes.

**O que não é verdade:** a ADR escreve que o Exame "continua alcançável abaixo do
teto pelo primeiro ramo (`exame da noite`, `passei o dia em revista`, **`olhando
o dia de hoje`**)". O terceiro é falso, **em qualquer tamanho**:

```
1  olhando o dia de hoje | curta: dia | longa: dia
```

`Meu dia` tem `\bo dia de hoje\b` no roteamento e vem ANTES do Exame no catálogo:
toda nota com "olhando o dia de hoje" cai no Meu dia e nunca no Exame. O ramo
está morto por sombreamento — defeito herdado da M3, não desta volta —, **mas a
frase que o cita como porta viva foi escrita AQUI**: a versão anterior da ADR
listava só os dois primeiros, e estava certa. A volta que existe para consertar
uma afirmação falsa acrescentou outra, menor.

---

## 2. Achado NOVO — a CAUSA que a ADR conta não sobrevive à medida

**Severidade: MÉDIO.** É o item que mais me importa, porque a casa aprende pela ADR.

A ADR diz, como lição central da volta:

> "O buraco maior era de AMOSTRA, não de léxico… As 57 protegidas até aqui
> carregavam um rabo de ~140 caracteres: quase toda sonda ficava ACIMA do teto, e
> o caso curto de cada família nunca era exercitado."

Medi as 57. **46 delas já estavam ABAIXO do teto.**

| régua | abaixo do teto | acima |
|---|---|---|
| 57 protegidas | **46** | 11 |
| 13 com gancho | 12 | 1 |
| 58 de trabalho | 56 | 2 |
| 6 legítimas | 6 | 0 |

O rabo de 140 pontos é de `todoRamoDeRegexAlcancaOSeuMetodo` (a régua de
ALCANCE, no arquivo de teste da M3) — não das protegidas. A frase da ADR troca
uma régua pela outra.

**A causa verdadeira, medida:** das 57, **17 tocam a família 4, e 11 dessas são
curtas.** Uma delas carrega o token do defeito e é curta:

```
[38] famílias 1a,4 ← TEM `não devia ter`   «Não devia ter feito isso, senti muito.»
```

Ela é curta desde a 06h e nunca acusou nada — porque `senti` a prende na família
1a antes de a família 4 ou 5 opinar. **O buraco era de amostra, sim, mas por
CONTAMINAÇÃO, não por tamanho.** Toda sonda curta com o token trazia junto uma
palavra de outra família.

Isso muda o conserto que a lição pede. A sonda curta por família é boa — e por
sorte do texto seis das sete saíram exclusivas —, mas
`cadaFamiliaTemUmaSondaAbaixoDoTeto` **não cobra exclusividade**: uma sonda futura
pode ser curta, declarar a família errada e passar verde, que é exatamente o que
aconteceu por quatro voltas. Um `#expect` fecha isso, com a família 5 declarada
como a exceção que ela já é. É a mesma forma do achado que eu fiz no re-G3: a
régua promete mais do que confere.

---

## 3. O preço da volta — medido, e a alternativa mais estreita é PIOR

A ADR assume o custo em prosa ("`não devia ter` agora cala também a confissão de
conduta sobre coisa"). Dou o número, contra o catálogo de 28 que existirá depois
da M3:

| nota de trabalho curta com `não devia ter` | antes | depois |
|---|---|---|
| "Não devia ter aceitado esse prazo. Qual a estimativa real de entrega?" | classeDeReferencia | **silêncio** |
| "Não devia ter escolhido esse banco. Do zero: quais pressupostos ninguém checou?" | primeirosPrincipios | **silêncio** |
| "Não devia ter feito o deploy na sexta. Por que isso quebrou de novo?" | cincoPorques | **silêncio** |
| "Não devia ter prometido a data. Meu argumento é que a fila precisa ser síncrona." | argumento | **silêncio** |
| "Não devia ter comprado o servidor próprio: qual o custo de oportunidade disso?" | vistoNaoVisto | **silêncio** |
| "Numa frase: eu não devia ter aceitado o escopo inteiro sem cortar nada." | destilar | **silêncio** |

**6 de 7 perdem a forma** (a sétima já calava). Contra o catálogo de 21 de `main`
hoje, **3 de 7**. É a assimetria da casa — calar custa um toque, vestir carimba
quatro campos — mas é um número, e um número deve estar na ADR.

**E eu testei a saída óbvia, que é pior.** Estreitar o token para os quatro
verbos que o próprio Exame usa (`não devia ter (feito|reagido|agido|tratado)`)
devolveria as notas de trabalho — e abriria **três buracos novos**, todos pela
Coluna da esquerda, que tem `\bdevia ter (dito|falado|respondido)\b`:

```
guarda=false rota=colunaEsquerda  «Não devia ter dito aquilo pra ela.»
guarda=false rota=colunaEsquerda  «Não devia ter falado assim com ele.»
guarda=false rota=colunaEsquerda  «Não devia ter respondido daquele jeito.»
```

**O token largo é a escolha certa, e não descuido.** Registro isto a favor da
volta, com a medida.

---

## 4. Dois defeitos pequenos

**BAIXO-1 — "os 11 ramos do Exame".** Pela mesma expansão que a ADR usa, o Exame
tem **17** ramos; 11 é o subconjunto de confissão. Medido: 12 dos 17 calados
agora nos dois regimes (eram 12 acima e 8 abaixo). O "era 7 de 11" está certo
para os 11 de confissão; o rótulo "dos 11 ramos do Exame" não.

**BAIXO-2 — números velhos no comentário.** `asDuasReguasValemAoMesmoTempo` ainda
diz *"a guarda que protege as 57 não pode calar as 47"*. São 64 e 58 desde esta
volta — e é o comentário que explica por que o teste existe.

**Sem achado:** o `comOsNovos` volta a injetar de verdade nesta árvore (o bundle
tem 21, não 28), então o BAIXO-1 do meu re-G3 não vale aqui; e conferi que as
regex congeladas do `static let novos` continuam **idênticas** às sete do
`Metodos.json` da M3, ramo a ramo — a divergência que eu temia é latente, não
atual.

---

## 5. Scorecard

| dimensão | nota | por quê |
|---|---|---|
| **Visão** | **9** | entra no ciclo "melhorar", fecha o resíduo nomeado da 06h/06i, EVOLUCAO atualizado |
| **Contrato** | **8** | ↑ a frase falsa da 06h/06i foi corrigida e a correção é verdadeira onde importa (0 ramos mudam de lado). ↓ a volta ACRESCENTOU um exemplo falso ("olhando o dia de hoje", morto por sombreamento em qualquer tamanho) e rotula 11 ramos onde são 17 |
| **Correção** | **8** | ↑ 780/130 verde, 0 aviso, réplica 141/141, controle negativo vermelho exatamente na linha certa e em nenhuma outra. ↓ `cadaFamiliaTemUmaSondaAbaixoDoTeto` não confere a exclusividade que a ADR lhe atribui — a propriedade que teria pego este defeito está lá por sorte do texto, não por asserção |
| **Jornada real** | **n/a** | zero código de view, e — importante — **o defeito não é observável nesta árvore**: sem os sete da M3 o Exame não existe no catálogo de 21, então a frase cai no silêncio com ou sem o conserto. A prova de tela é a minha `m3-reg3-01`, e a tela do conserto só existe depois da mescla |
| **Design / Movimento / Componentes / Acessibilidade / Fora do app** | **n/a** | nada tocado |
| **Simplicidade** | **9** | um token de lugar; nenhuma tela, nenhum passo, nenhuma decisão a mais |
| **Performance** | **9** | o token entra numa alternação que já era avaliada; nenhuma regex nova no caminho quente |
| **Privacidade e autoria** | **9** | ↑ o resíduo do meu §B está fechado e provado dos dois lados do teto, com controle negativo; a guarda continua em código e não no JSON editável |
| **Estado honesto** | **8** | ↓ o custo está dito em prosa e sem número (são 6 de 7 no catálogo de 28), e a CAUSA declarada não sobrevive à medida (§2) |
| **Complexidade** | **9** | uma linha de produção; o resto é teste e documento |
| **Relato** | **8** | ↓ mesma raiz do Contrato: o commit e a ADR contam uma causa que eu medi e não confirmei |

**Quatro dimensões em 8: Contrato, Correção, Estado honesto, Relato.** Todas
descem de texto e de uma asserção que falta, não do conserto.

---

## 6. Lista mínima — quatro linhas, e a volta passa

Nenhuma toca `Traco/Analise`. Todas cabem no commit da própria volta.

1. **Corrigir a causa na ADR** (§2): trocar "as 57 carregavam um rabo de ~140" por
   o que se mede — 46 das 57 já eram curtas; o que faltava era sonda curta
   **exclusiva** da família, porque a única curta com `não devia ter` ("Não devia
   ter feito isso, senti muito.") era presa pela família 1a antes de a 4 ou a 5
   opinarem. → fecha Estado honesto e Relato.
2. **Uma asserção de exclusividade** em `cadaFamiliaTemUmaSondaAbaixoDoTeto`:
   nenhuma outra família reconhece a sonda, com a família 5 declarada como a
   exceção que o comentário já explica. É a régua que a ADR promete. → fecha
   Correção.
3. **Tirar "olhando o dia de hoje"** da lista de portas vivas do Exame (§1d), ou
   dizer ao lado que ela é sombreada pelo Meu dia. → fecha Contrato.
4. **Dois números**: o custo medido (6 de 7 no catálogo de 28, 3 de 7 no de 21) na
   linha do "Fora", e "11 dos 17 ramos" no lugar de "os 11 ramos". → fecha
   Contrato e Estado honesto.

---

## 7. A ordem de mescla — **CONCORDO: A-6 antes da M3**, e por uma razão mais forte do que a que foi dada

A razão dada (a A-6 mexe na guarda que a M3 exercita) está certa. A medida dá uma
segunda, que decide sozinha:

**O defeito só existe depois da M3.** Nesta árvore o Exame não está no catálogo,
então a confissão curta cai no silêncio com ou sem o conserto. Se a M3 entrar
primeiro, `main` passa a vestir "Não devia ter reagido assim com ele." de Exame da
noite **durante toda a janela entre as duas mesclas** — o defeito que eu
fotografei entra em main de propósito. Na ordem A-6 → M3 ele nunca existe.

**O que a A-6 sozinha custa em main**, e é honesto dizer: ela silencia 3 de 7
notas curtas de trabalho com `não devia ter` (§3) contra o catálogo de 21, e não
paga nada até a M3 entrar, porque o benefício depende do Exame existir. Não é
motivo para inverter a ordem — é motivo para as duas entrarem **juntas, nesta
sequência**, e não com dias de intervalo.

---

## 8. Instrumento

`xcodebuild test` no **iPhone 17 Pro (teste 2) `B91C8DEF`**, sob
`ferramentas/orca/com-trava.sh`. **Sem maestro** (a lei do instrumento: com mais
de um simulador ligado o `--device` não isola, e esta volta não precisa dele —
não há tela nova). Nenhum toque por coordenada, o iPhone 17 do dono intocado.
Nada editado, nada commitado no código.

Réplica `rota2` e as três variantes de controle (léxico de `main`, token
estreito, catálogo de 21 e de 28) em
`…/scratchpad/{replica.swift,main.swift,corpus.json,antes/,estreito/,custo/,excl/,r2/}`;
o `replica.swift` é gerado por `sed` do fonte e do teste, então se regenera
sozinho em qualquer árvore. Entrego se o orquestrador quiser fixá-la ao lado de
`m3-rev-provas/`.
