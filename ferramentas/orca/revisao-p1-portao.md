# G3 — revisão independente da volta P1 (o portão do movimento e as dívidas curtas)

Revisor: Claude Opus 5, sessão própria, 08/09/2026.
Branch `Vitorepf/volta-p1-portao-movimento`, topo `14535b5`, base `main`.
Simulador **iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`**
(estava DESLIGADO quando cheguei — eu o liguei, usei e desliguei ao fim).
Sem maestro: quatro simuladores ligados na máquina. O `B91C8DEF` (teste 2) não
foi tocado.

## VEREDITO: **CORRIGIR ANTES.** Cinco dimensões abaixo de 9.

O portão existe, fecha a porta e eu o provei vermelho com três violações minhas.
Mas ele **conta como dívida exatamente a forma que ele próprio manda escrever**:
as 76 ocorrências congeladas não são movimento fora de `Tema` — são 76 chamadas
que já passam por `Tema`. Isso derruba Contrato e Correção, e faz a ADR e o
EVOLUCAO afirmarem ao dono uma coisa que o código contradiz.

As três dívidas de documento (A-6, M3, o ramo morto) estão **certas**, e cada
número que o implementador citou eu refiz na mão: batem todos.

---

## 1. O portão vale mesmo? — provado por mim, nos quatro sentidos pedidos

### 1.1 A varredura, reproduzida de fora

Reimplementei a varredura em Python (mesma regex, mesma limpeza de comentário e
string, mesma exclusão de `Traco/Tema.swift`) e cheguei ao mesmo lugar:

```
ARQUIVOS VARRIDOS: 125   (126 no total, menos o isento)
ARQUIVOS COM OCORRENCIA: 19
TOTAL OCORRENCIAS: 76
```

Os 19 caminhos e os 19 números batem, um a um, com `faltosos`. A contagem é
honesta. (Nota miúda: o relato e a ADR dizem "varre 126 fontes"; varre 125 e
isenta 1.)

### 1.2 O vermelho, com as MINHAS violações — as três pegas

Plantei três coisas diferentes ao mesmo tempo e rodei só o portão:

```
✘ Test nenhumMovimentoNovoForaDeTema() recorded an issue at PortaoDoMovimentoTests.swift:135:9:
  Expectation failed: (divergencias → ["Traco/Componentes/Botao.swift: 1 hoje, 0 congelado  ← SUBIU",
                                       "Traco/Componentes/ProvaRevisorG3.swift: 2 hoje, 0 congelado  ← SUBIU",
                                       "TracoWidget/TracoWidget.swift: 2 hoje, 0 congelado  ← SUBIU"]).isEmpty → false
** TEST FAILED **
```

| planta | o que prova | resultado |
|---|---|---|
| `TracoWidget.swift` += `private let curvaDoRevisorG3: Animation = .easeInOut(duration: 0.42)` | dívida REAL (curva literal) num arquivo que o relato diz ter zero | **pego** ✔ |
| `Traco/Componentes/ProvaRevisorG3.swift` — arquivo **NOVO**, nem no `pbxproj`, com `withAnimation(.spring(response: 0.4))` | critério (c): o portão enxerga arquivo novo | **pego** ✔ — a varredura é do sistema de arquivos, não da lista de alvos |
| `Traco/Componentes/Botao.swift` += `Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: false)` | a forma **PRESCRITA** pelo próprio portão | **pego também** ✘ — é o achado alto |

As três plantas foram removidas; `git status` limpo, conferido.

### 1.3 ACHADO ALTO — o portão conta como dívida a forma certa

`Tema.movimento(_ classe:, _ normal: Animation, reduzido:)` **exige uma
`Animation` do SwiftUI no ponto de chamada** (`Traco/Tema.swift:193`). A forma
que a ADR manda escrever é, literalmente:

```swift
.animation(Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion), value: x)
```

e a regex casa o `.easeOut(` dela. Medido nas 76 ocorrências congeladas:

| | ocorrências |
|---|---|
| em linha que **já cita `Tema.`** | **69** |
| em linha sem `Tema.` — as três de `Camadas.swift` | 3 |
| as 3 restantes (linhas de continuação de chamada a `Tema`) | 4 |

E as três "sem `Tema.`" são `withAnimation(mola)`, onde
`Camadas.swift:101` define `private var mola: Animation? { Tema.corte(Tema.Mola.camada, reduzido: reduceMotion) }`.

**Nenhuma das 38 chamadas de `withAnimation(` do repositório escreve uma curva
no ponto de uso.** Todas passam `Tema.*`, `CalendarioTema.morph(reduceMotion)`
ou uma variável que é `Tema.*`. E a dívida que a ADR nomeia — curva ou duração
em número cru fora de `Tema` — é **ZERO hoje**:

```
$ grep -rnE 'duration:[[:space:]]*[0-9]|response:[[:space:]]*[0-9]|\.delay\([[:space:]]*[0-9]|dampingFraction:[[:space:]]*[0-9]|stiffness:[[:space:]]*[0-9]' --include='*.swift' Traco TracoWidget | grep -v '^Traco/Tema.swift'
--- fim (vazio) ---
```

Três consequências, todas más:

1. **A mensagem de falha instrui errado.** Quem migrar uma tela amanhã vai ler
   "SUBIU: não escreva a curva no ponto de uso. `Tema.movimento(classe, curva,
   reduzido:)` é quem decide" — numa linha que É `Tema.movimento(classe, curva,
   reduzido:)`. Foi exatamente o que o meu `Botao.swift` recebeu.
2. **O "zero" da lista é inalcançável.** O comentário diz "apague a linha quando
   chegar a zero". Nenhum arquivo que anime por tempo chega a zero sem parar de
   usar `Tema`.
3. **A dívida de 76 não é dívida.** O que o portão de fato entrega é bom e vale:
   *nenhuma animação nova entra sem alguém olhar*. Só que não é o que a ADR, o
   EVOLUCAO e o relato dizem que ele entrega.

**Conserto (uma linha):** ignorar o casamento que estiver dentro de uma chamada a
`Tema.`/`CalendarioTema.`, e recongelar — a lista cai de 76 para perto de zero e
volta a significar o que o nome dela diz.

### 1.4 Critério (b) — descer TAMBÉM fica vermelho. Falha.

`guard hoje != congelado else { continue }` acusa nos dois sentidos. Provei com
uma migração legítima (troquei uma curva do SwiftUI pela mola nomeada
`Tema.Mola.escala` em `PadroesView.swift:155` — compila, é a migração que a ADR
pede):

```
✘ Expectation failed: (divergencias → ["Traco/Padroes/PadroesView.swift: 1 hoje, 2 congelado  ← desceu"]).isEmpty → false
** TEST FAILED **
```

Está escrito no código que é de propósito ("baixe o número aqui no mesmo
commit") e a mensagem diz o que fazer. Mas o critério do G0 era que a volta por
tela **não** ficasse vermelha, e ela fica. Ou muda para `hoje <= congelado`, ou a
ADR assume a trava de duas mãos por escrito.

### 1.5 Falso positivo em comentário e string — tentei enganar, não consegui

Li `semComentarioNemTexto` e ataquei:

- `// não use "withAnimation("` → o `//` é visto antes do `"`, cortado. ✔
- `let s = "//"` → o `//` está dentro de texto, o guarda `!dentroDeTexto` segura. ✔
- `let s = "a\\" ; withAnimation(x)` → a barra dupla faz o teste de escape achar
  que a aspa está escapada, o texto fica "aberto" e engole o resto da linha:
  **erra para o lado de NÃO acusar**. Teto novo, não escrito no código (o teto
  escrito é só o de `"""`). Falso NEGATIVO, não falso positivo — não cria
  vermelho injusto.

Nenhum caminho que eu achasse produz vermelho a partir de prosa. O guarda contra
o falso verde (`fontes.count > 100` + `Tema.swift` existe no caminho isento) está
lá e é o certo.

### 1.6 `Tema.swift` isento — é a isenção certa, e é estreita

É onde a lei mora (`Duracao`, `Mola`, `movimento`, `animacao`, `corte`,
`gaveta`). A isenção é por caminho exato: se alguém partir o `Tema` em outro
arquivo, o arquivo novo fica vermelho na hora — o que é o comportamento certo.
`Traco/Calendario/CalendarioTema.swift`, que é a SEGUNDA casa de movimento
(`morph`, `desdobra`), **não** é isento e passa verde porque delega tudo a
`Tema.*` — isto é, se alguém escrever uma curva crua lá dentro, fica vermelho.
Correto nos dois sentidos.

---

## 2. A porta morta — apagada, não descrita: **é conserto, não perda de alcance**

Refiz a conta na mão, no `Metodos.json`:

```
13 dia          ['\bmeu dia\b|\bplanejar o dia\b|\bo dia de hoje\b|\bprioridades de hoje\b|\bhoje eu (preciso|tenho que|vou)\b']
27 exameDaNoite ['\bexame da noite\b|\bpassei o dia em revista\b', ...]
total metodos: 28
```

`\bolhando o dia de hoje\b` é **subconjunto estrito** de `\bo dia de hoje\b`:
toda nota que casava a primeira casa a segunda, e o `Meu dia` está catorze
posições ANTES no catálogo. A frase nunca chegava ao Exame, em nenhum tamanho —
e o desvio congelado `exameDaNoite|olhando o dia de hoje|dia` já registrava isso
desde a 06e. **Apagar é comportamento-neutro**: o autor que escrever "olhando o
dia de hoje" cai no Meu dia hoje e caía no Meu dia ontem. Não há perda.

Os números da defesa, todos conferidos por mim:

| afirmação | conferido |
|---|---|
| desvios congelados 18 → **17** | contei a lista: 3 (regex larga) + 3 (Coluna) + 11 (Exame) = **17** ✔ |
| o Exame tinha **17** ramos, agora **16** | expandi as alternativas: 2 + 9 + 5 = 16; com o ramo morto, 17 ✔ |
| **11 calados** pela guarda, **5 vivos** | as 11 entradas `exameDaNoite\|…\|silencio` da lista, e 2+3 = 5 vivos ✔ |
| "os 11 ramos do Exame" era rótulo errado | é: 11 é o subconjunto de confissão de 17 ✔ |
| ramos que chegam abaixo do teto: 9/17 → 5/17 | 5 vivos + os 4 `não devia ter (feito\|reagido\|agido\|tratado)` que voltariam com o token na família 5 = 9 ✔ (consistente por construção) |

**Achado BAIXO:** a volta que estava pagando dívida de número deixou dois números
velhos no MESMO comentário que corrigiu, em `TracoTests/CatalogoTests.swift`:

- linha 402 passa a dizer `DEZESSETE`, mas a **linha 426** ainda diz
  `/// Desvio NOVO, fora destes 18, derruba o teste.`
- linha 407: `Os TRÊS primeiros … Nenhum dos três métodos fica sem porta` — com o
  ramo do Exame fora, sobraram **dois** métodos (`steelman`, `divergencia`).

---

## 3. A ficha do `exameDaNoite` — **eu fotografei**. O texto bate; a copy tem três defeitos

O implementador declarou honestamente que não fotografou. Fotografei eu, sem
maestro, por `cliclick` com `AXRaise` na janela do teste 4 e captura por
`simctl io <MEU UDID>`.

**Caminho, quatro passos:** Perfil › MÉTODOS "28 do app" › rolar até "Exame da
noite" › tocar a linha. A ficha É alcançável — não é dívida de superfície.

**Provas** (untracked, em `ferramentas/orca/revisao-p1-provas/`):
- `metodos-lista-exame.png` — a folha Métodos com o Exame da noite recolhido
- `ficha-exame-serve-para-topo.png` — a ficha aberta, FONTE → SERVE PARA
- `ficha-exame-serve-para-inteiro.png` — o SERVE PARA inteiro, até a última linha

**Conteúdo na tela, conferido palavra a palavra contra o `Metodos.json`:**

> **SERVE PARA**
> Serve para o fim de um dia em que o autor fez algo que não quer repetir — e
> você o abre pelo nome, ou escrevendo "passei o dia em revista". O Traço não
> oferece esta forma sobre a sua escrita pessoal: quando o texto é confissão, a
> nota fica sua e não vira exercício (ADR 2026-09-06h). Não serve para julgar os
> outros, nem para ruminar — se o texto vira desabafo, a forma é a Expressiva.

Bate. Nada cortado, nada truncado, a última linha é alcançável por rolagem.
E a promessa velha (a matéria que a guarda recusa) saiu: agora a ficha declara
a recusa e nomeia as duas portas vivas. **Isso está certo e era o ponto da M3.**

Mas o que o autor lê tem três defeitos que só a foto mostra:

1. **`(ADR 2026-09-06h)` está na tela.** Contei os 28 métodos: esta é a **única**
   `aplicabilidade` do catálogo que cita um número de ADR. É contabilidade
   interna vazando para copy de produto.
2. **Três pessoas na mesma frase.** "…em que **o autor** fez algo… e **você** o
   abre pelo nome… a nota fica **sua**". É também a única das 28 que trata o
   leitor por "você". A string anterior era de terceira pessoa, coerente.
3. **Aspas retas onde o app usa tipográficas.** `"passei o dia em revista"` sai
   com `"` reto na tela, enquanto o vizinho na mesma folha ("Se–então") mostra
   `“não faço”`. Visível na captura.

E o tamanho: **385 caracteres**, contra mediana de 93 e segundo lugar de 195. É a
mais longa das 28, por larga margem, num cartão de leitura.

---

## 4. As quatro réguas não mudaram de lado — provado, e as duas novas mordem

```
✔ Test run with 39 tests in 3 suites passed after 1.276 seconds.   (EscritaPessoal + Catalogo + PortaoDoMovimento)
** TEST SUCCEEDED **
```

Contei os arrays na mão: `comGancho` **13** ✔, `legitimas` **6** ✔, `trabalho`
**72** ✔, protegidas `curtas`+`longas`+`doRevisorG3`+`minhas` = **57** (+ as 7
sondas de `curtasPorFamilia` = os 64 do relato) ✔.

**A causa nova da 06i-E, medida por mim, bate exatamente:**

```
protegidas: 57   ABAIXO do teto 120: 46   acima: 11
com o token `não devia ter`: 5 frases — e a ÚNICA curta é
  «Não devia ter feito isso, senti muito.» (38 car., contém `senti` → família 1a)
```

**46 de 57 já eram curtas.** A causa era contaminação, não rabo. A ADR corrigida
está certa.

Não acreditei nas duas réguas novas: adulterei cada uma e as duas ficaram
vermelhas.

**A exclusividade** (contaminei a sonda da família 4 acrescentando `senti`):
```
✘ Expectation failed: (Set(reconhecem) → ["1a", "4"]) == (Set([familia] + alem) → ["4"])
↳ sonda contaminada — declara 4 sozinha, reconhecem 1a,4: «Fui grosso com o meu irmão hoje, senti muito.»
```

**A cópia-vs-bundle** (devolvi o ramo morto só à cópia congelada em `novos`):
```
✘ Expectation failed: congelado.roteamento == doApp.roteamento
↳ a cópia da M3 divergiu do bundle em exameDaNoite
```

As duas fazem o trabalho que a ADR lhes atribui. Esta parte da volta é sólida.

## 5. Suíte integral e build, refeitos por mim

```
✔ Test run with 889 tests in 144 suites passed after 11.903 seconds.
** TEST SUCCEEDED **
```
`grep -c "warning:"` no log inteiro: **0**. No `A1DF082C`, sob `com-trava.sh`,
UDID explícito.

**Achado MÉDIO, não declarado:** o `xcodegen generate` desta volta não
acrescentou só o arquivo do portão ao `project.pbxproj` — acrescentou também
`TracoTests/ContinuidadeTrabalhoTests.swift`, que **existe em `main` desde
`5065929` e nunca esteve no projeto**: dois testes que nunca rodaram. A volta faz
bem em ligá-los (verdes), mas o relato atribui o `+8` do `pbxproj` só ao portão,
e os "889 testes" não são comparáveis com o número de `main` por essa razão.
Sugestão para o RUMO, fora do escopo desta volta: um portão de uma linha que
exija que todo `TracoTests/*.swift` esteja no alvo — arquivo de teste entrou em
`main` sem nunca rodar.

## 6. Contrato — AGENTS.md, SPEC.md, ADR 08a, EVOLUCAO

- **AGENTS.md:** nada violado. Nenhuma rota protegida mexida, autoria e origem
  intactas, nada publica/gasta/envia. As guardas continuam em código, não no JSON.
- **SPEC.md:** a 06i-E foi corrigida nos quatro pontos e as correções são
  verdadeiras (§2 e §4 acima). A ADR 08a é curta e bem escrita — **e afirma o que
  o código contradiz**: "conta por arquivo quantas vezes ele move por conta
  própria" e "as 76 continuam por migrar".
- **EVOLUCAO.md:** a linha nova diz "as telas fora das três migradas ainda
  desenham por conta própria — agora a lista é o `faltosos`". Falso: as 19 telas
  do `faltosos` desenham **por `Tema`**. É a frase que o dono lê para saber onde
  está a dívida, e ela aponta para o lugar errado.
- **Complexidade:** produção com líquido zero, confirmado — o diff de produção
  são 2 linhas trocadas no `Metodos.json`. Mas o §6 do relato diz
  `7 files changed, 211 insertions(+), 49 deletions(-)`; o real é
  `9 files changed, 660 insertions(+), 49 deletions(-)` (falta a ADR do SPEC e o
  próprio relatório). Número velho, do mesmo tipo que a volta veio consertar.

---

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| **Visão** | **8** | entra no ciclo 4 e põe portão onde não havia — mas fecha uma lacuna diferente da que nomeia: a lacuna do EVOLUCAO é "telas que desenham por conta própria", e essas são zero (§1.3) |
| **Contrato** | **7** | ADR 08a e EVOLUCAO afirmam 76 ocorrências "por migrar"; medido: 69/76 em linha que já cita `Tema.`, as outras 7 idem por variável, e 0 curva literal no repositório. Mais dois números velhos deixados em `CatalogoTests` (linhas 407 e 426) pela volta que veio pagar dívida de número |
| **Correção** | **7** | 889/144 verde e 0 aviso, refeitos por mim; portão provado vermelho com três plantas minhas (arquivo novo, widget, forma prescrita). Mas a forma PRESCRITA fica vermelha (§1.3) e a migração legítima também (§1.4, `PadroesView: 1 hoje, 2 congelado ← desceu`) |
| **Jornada real** | **9** | fotografei a ficha do Exame no `A1DF082C`: `ferramentas/orca/revisao-p1-provas/ficha-exame-serve-para-{topo,inteiro}.png`. Alcançável em 4 passos, texto na tela idêntico ao `Metodos.json`, nada cortado. Único estado que existe: a folha não tem vazio/carregando/falha |
| **Design** | n/a | nenhuma view, token ou componente tocado; diff de produção são 2 linhas de JSON |
| **Simplicidade** | **8** | nenhuma tela, passo ou decisão a mais, e a ficha passa a dizer COMO se chega ao Exame — mas a copy que o autor lê traz `(ADR 2026-09-06h)` (única das 28), muda de "o autor" para "você" na mesma frase (única das 28), usa aspas retas onde o app usa tipográficas, e tem 385 caracteres contra mediana de 93 |
| **Movimento** | n/a | o portão CONGELA movimento; não cria, não altera e não remove nenhuma animação — verificado no diff de produção |
| **Componentes** | n/a | nenhum componente tocado |
| **Acessibilidade** | n/a | nenhuma view, rótulo AX ou alvo tocado; a string mudada já é lida pelo mesmo `LinhasDeProveniencia` |
| **Performance** | n/a | nada no caminho quente; a varredura roda em 0,6 s dentro do teste |
| **Privacidade e autoria** | **9** | as quatro réguas verdes e nenhuma mudou de lado (39/3 colado); as duas réguas novas provadas VERMELHAS por adulteração minha; o ramo apagado provado morto na mão (índice 13 × 27, subconjunto estrito) |
| **Estado honesto** | **8** | o relato é raro em dizer o que NÃO fez (não fotografou a ficha, não rodou o fluxo maestro, não migrou as 76) — mas apresenta 76 como dívida quando não é, dá um shortstat velho (7/+211 contra 9/+660) e não declara que o `pbxproj` também ligou `ContinuidadeTrabalhoTests`, escuro em `main` |
| **Complexidade** | **9** | produção em líquido zero confirmada: 2 linhas trocadas num JSON, nenhum arquivo de produção novo, nenhuma dependência |
| **Fora do app** | n/a | `TracoWidget/` não foi tocado; provei que continua com zero e que o portão o defende (planta minha ficou vermelha lá) |
| **Relato** | **8** | seis linhas, linhas de resultado coladas, limites ditos por nome — repete o enquadramento das "76 por migrar" e o shortstat velho |

---

## O que corrigir antes do merge — uma linha cada

1. **Correção/ALTO** — a regex não pode contar o que está DENTRO de uma chamada a
   `Tema.`/`CalendarioTema.`; recongelar depois disso (a lista cai de 76 para
   perto de zero).
2. **Correção/ALTO** — a mensagem de "SUBIU" não pode dizer "não escreva a curva
   no ponto de uso" para uma linha que cita `Tema`.
3. **Correção/MÉDIO** — `guard hoje <= congelado` (só subir é vermelho), ou
   assumir a trava de duas mãos por escrito na ADR.
4. **Contrato/ALTO** — ADR 08a e EVOLUCAO: trocar "as 76 continuam por migrar /
   as telas ainda desenham por conta própria" pelo medido (zero curva literal
   fora de `Tema` hoje; as 76 são chamadas já roteadas por `Tema`).
5. **Contrato/BAIXO** — `CatalogoTests.swift:426` "fora destes 18" → 17; linha 407
   "Nenhum dos três métodos" → dois.
6. **Simplicidade/MÉDIO** — tirar `(ADR 2026-09-06h)` da `aplicabilidade`, ficar
   com UMA pessoa (ou "o autor" ou "você") e usar as aspas tipográficas do app.
7. **Estado honesto/MÉDIO** — declarar no relato que o `pbxproj` também ligou
   `TracoTests/ContinuidadeTrabalhoTests.swift` (escuro em `main`), e corrigir o
   shortstat para `9 files changed, 660 insertions(+), 49 deletions(-)`.

**Para o RUMO, fora desta volta:** um portão que exija que todo
`TracoTests/*.swift` esteja no alvo de teste — um arquivo de teste viveu em
`main` sem nunca rodar, e nada acusou.

---

## Instrumento — o que eu garanti

- Todo `xcodebuild` por `ferramentas/orca/com-trava.sh`, **UDID explícito**,
  nunca `booted`.
- **Sem maestro.** Nenhuma nota se apoia nele. Direção de tela por `cliclick`
  com `AXRaise` da janela do teste 4; prova de tela sempre
  `xcrun simctl io A1DF082C-… screenshot`.
- O **`B91C8DEF` (teste 2)** não foi tocado — nem build, nem instalação, nem
  toque, nem desligamento. Conferi a geometria das janelas antes de clicar: ele
  está em (401,48) e nenhum clique meu chegou perto.
- O `A1DF082C` estava **Shutdown** quando cheguei; eu o liguei, instalei o app do
  MEU `derivedDataPath`, usei e o **desliguei ao fim**, devolvendo o estado.
- **Limite honesto:** durante a sessão outro worker empilhou três janelas do
  Simulator na mesma posição (1206,48). O `AXRaise` segurou — todas as capturas
  vieram do meu UDID e mostram o meu estado —, mas registro que a direção por
  coordenada esteve em risco nesse trecho.
- Nada editado, commitado ou mesclado. As três plantas e as duas adulterações de
  teste foram removidas por `git checkout --`; a única coisa que deixei na árvore
  é este relatório e a pasta `ferramentas/orca/revisao-p1-provas/` (untracked).
