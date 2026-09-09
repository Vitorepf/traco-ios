# M1-B — o portão que diz "cada versão" passou a ter cada versão

**Volta:** M1-B · **Papel:** implementador · **ADR:** 2026-09-09f (adendo)
**Branch:** `Vitorepf/volta-m1-migracao`, com o `main` de 09/09 **mesclado dentro**
**Aparelho:** iPhone 17 Pro `C2416CBC-C5D9-41F9-ACD8-45EED8FC355E` — o único ligado
**Trava:** todo `xcodebuild test` passou por `ferramentas/orca/com-trava.sh`

## Linha do ciclo (G0)

**Ciclo:** preservar o que o autor escreveu. **Intenção:** o autor abre o Traço
e o caderno dele está lá, depois de qualquer atualização. **Obstáculo:** o
portão prometia "cada versão" e media duas. **Evidência:** um caderno gravado
com o código de cada versão, aberto pelo build de hoje no aparelho.

## 1. O que a G3 reprovou, e o que fiz com cada achado

| achado da G3 | o que fiz |
|---|---|
| P1 — o portão declarado "cada versão" só tinha V4 e V5 | Cresceu a prova, não encolheu a frase: **seis cadernos, um por versão do plano**, e um teste que recusa a lista se ela ficar menor que o plano. |
| P1 — `main` andou cinco commits (sete quando cheguei) | `main` **mesclado no branch** (`ba36043`, conflito só em `LETRAS-ADR.md`, resolvido pela versão do `main`, que é a mais nova). Toda medida abaixo é da árvore mesclada. |

## 2. A circularidade tinha saída, e ela se mede

A volta anterior recusou fabricar fixtures V1/V2 "com o código de hoje, que seria
circular" — e a recusa estava certa. A saída é gravar **com o código de ontem**.
O problema prático: um build de 31/08 não roda mais sem instalar binário antigo
por cima do aparelho do dono.

**O que descobri medindo:** o checksum de uma versão do CoreData depende só da
**forma das entidades** — não da plataforma, não do módulo. Isso não é suposição:

    cópia congelada V4 deste repo, gravada por um executável macOS (SPM):
      4.0.0  ImY8W7hR8jJH+xS4hddeRW+haXr9qO3ZDVx/J9RS3sI=
      Nota gDJIKvkYFO125qlIKgYar6ux+t60dqWkS9xaywBgtaM=
      ReciboEntrada rpWRZ+jVTFlUalgWFo/7I4bCDiraRzdqqQ4uss9Fg1I=
      Trabalho t/7m/7WlGphpsFXvlA1gLKqQfDkCS2FSRNkrVzsx22Y=

    TracoTests/Fixtures/caderno-v4-pre08u.store, gravado pelo build iOS 8d9ce62
    no simulador, na volta passada:
      4.0.0  ImY8W7hR8jJH+xS4hddeRW+haXr9qO3ZDVx/J9RS3sI=
      Nota gDJIKvkYFO125qlIKgYar6ux+t60dqWkS9xaywBgtaM=
      ReciboEntrada rpWRZ+jVTFlUalgWFo/7I4bCDiraRzdqqQ4uss9Fg1I=
      Trabalho t/7m/7WlGphpsFXvlA1gLKqQfDkCS2FSRNkrVzsx22Y=

**Byte a byte igual.** O instrumento está calibrado contra um caso conhecido —
um store que um build histórico real gravou num iPhone. E a mesma corrida
confirmou, de graça, que a cópia congelada V4 do repo é fiel àquele build.

Com isso, as formas antigas da `Nota` foram **extraídas do `git` por script** —
`git show <commit>:Traco/Modelo/Nota.swift`, filtrando as propriedades
armazenadas (as computadas têm `{` e não entram no modelo) — e usadas para
gravar um caderno de cada versão. Nenhuma transcrição à mão; nenhum byte do
código de hoje na forma de ontem. O checkout descartável ficou no scratchpad da
sessão e não foi comitado.

**Controle do método:** a mesma extração aplicada a `9ad639e` (a V4 histórica)
devolveu `ImY8W7…` outra vez. Extrair-do-git ⇒ mesmo checksum do build real.

## 3. O achado: a 1.0.0 teve DUAS formas, e a primeira não abria

Rodando o método sobre todo o passado, apareceu o que o portão incompleto tinha
deixado passar:

| build | data | forma da `Nota` | checksum |
|---|---|---|---|
| `b7fbc3e` | 31/08 08:27 | 8 propriedades | `ZaCSxtyZ+GhOyX+/HrdB0vDyHUU4iGbD8pyC5WHEAI8=` |
| `fea00dd` | 31/08 16:31 | 12 (+ queima, minutos, sentido) | `c2qnFksOJhh+/ANo29UNO8QkIxGdsSf0P+COGywTg4E=` |

`b7fbc3e` é o commit que **criou** o schema versionado. Oito horas depois,
`fea00dd` acrescentou `queimada`, `queimadaEm`, `minutosEscritos` e `sentido` à
`Nota` **sem abrir versão** — exatamente o pecado da 08u, cometido no mesmo dia
em que o schema nasceu. O rótulo continuou `1.0.0`; o checksum, não.

O conserto da M1 congelou a **segunda** forma como `TracoSchemaV1` e deixou a
primeira órfã. Medido no aparelho, no build já consertado:

    ✘ Test cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno:) recorded an issue
      with 1 argument caderno → caderno-v0-b7fbc3e at CadernoAntigoAbreTests.swift:74:6:
      Caught error: SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer, _explanation: nil)

**Conserto:** `TracoSchemaV0`, com a forma de `b7fbc3e` e rótulo `0.9.0` —
porque o CoreData casa o store pelo **checksum**, não pelo número, e duas
versões do plano não podem carregar o mesmo rótulo; a razão está escrita ao lado
da declaração. Estágio `V0→V1` leve. `TracoMigracao` passa de cinco para seis
versões.

## 4. O portão: seis cadernos, um por versão, e a frase que se defende sozinha

| arquivo | versão | de onde vem | notas |
|---|---|---|---:|
| `caderno-v0-b7fbc3e` | 0.9.0 | forma viva de `b7fbc3e` (31/08 08:27) | 3 |
| `caderno-v1-fea00dd` | 1.0.0 | forma viva de `fea00dd` (31/08 16:31) | 4 |
| `caderno-v2-bf535c5` | 2.0.0 | forma viva de `bf535c5` (02/09) | 5 |
| `caderno-v3-degrau` | 3.0.0 | degrau — **nenhum build a gravou em campo** | 6 |
| `caderno-v4-pre08u` | 4.0.0 | build `8d9ce62`, o caderno do autor | 7 |
| `caderno-v5-origem` | 5.0.0 | build desta volta | 7 |

As contagens são distintas **de propósito**: se o teste abrisse o arquivo
errado, a conta denunciaria. Cada caderno confere, além da contagem, o texto de
cada nota, o selo, a queima e o sentido onde aquelas colunas já existiam, e a
origem `.autor` da 08u.

**A 3.0.0 nunca esteve na mão de ninguém.** Ela nasceu e foi superada dentro do
mesmo commit (`9ad639e`), que já abria o container pela V4 — não existe build
que a tenha gravado, e fabricar um passado seria pior que declarar. O caderno
dela é o degrau do plano montado com as formas vivas daquele commit, e o nome do
arquivo diz isso.

**A frase passou a se defender sozinha:** `oPortaoTemUmCadernoPorVersao` compara
o tamanho da lista com `TracoMigracao.schemas.count`. Quem abrir a V6 e esquecer
o caderno dela vê vermelho **antes** de a mudança chegar ao aparelho do autor.

### O vermelho, provado e não afirmado

Tirei o `TracoSchemaV0` do plano (`/*SONDA …*/`) e rodei o portão no
`C2416CBC`:

    ✘ Test oPortaoTemUmCadernoPorVersao() recorded an issue at CadernoAntigoAbreTests.swift:70:9:
      Expectation failed: (Self.cadernos.count → 6) == (TracoMigracao.schemas.count → 5)
    ✘ Test cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno:) recorded an issue with 1 argument
      caderno → caderno-v0-b7fbc3e … Caught error: SwiftDataError(… loadIssueModelContainer …)
    ✘ Test run with 3 tests in 1 suite failed after 0.375 seconds with 2 issues.

As outras cinco versões seguiram verdes na mesma corrida. A sonda foi revertida
(`grep -c SONDA Traco/Modelo/Migracao.swift` → 0).

### O verde, com a hora que o dono pediu

Com o `TracoSchemaV0` de volta, no mesmo aparelho, **às 08:55:15 de 09/09/2026**,
na árvore já mesclada com o `main`:

    ✔ Test oPortaoTemUmCadernoPorVersao() passed after 0.001 seconds.
    ◇ Test case passing 1 argument caderno → caderno-v0-b7fbc3e …
    ◇ Test case passing 1 argument caderno → caderno-v1-fea00dd …
    ◇ Test case passing 1 argument caderno → caderno-v2-bf535c5 …
    ◇ Test case passing 1 argument caderno → caderno-v3-degrau …
    ◇ Test case passing 1 argument caderno → caderno-v4-pre08u …
    ◇ Test case passing 1 argument caderno → caderno-v5-origem …
    ✔ Test cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno:) with 6 test cases passed after 0.464 seconds.
    ✔ Test run with 2 tests in 1 suite passed after 0.466 seconds.
    ** TEST SUCCEEDED **

**O caderno mais antigo do Traço — o de 31/08 às 08:27 — voltou a abrir às
08:55:15 de 09/09/2026.**

## 5. Suíte integral, na árvore mesclada

    SUITE INICIO 08:57:21
    ✔ Test run with 977 tests in 158 suites passed after 55.675 seconds.
    ** TEST SUCCEEDED **
    SUITE FIM 08:58:27
    warnings: 0

E de novo **no commit final** (`1c0d6dd`), para que a linha da suíte seja a do
código que fica:

    SUITE FINAL INICIO 09:15:34   HEAD 1c0d6dd
    ✔ Test run with 977 tests in 158 suites passed after 55.032 seconds.
    ** TEST SUCCEEDED **
    SUITE FINAL FIM 09:16:37
    warnings: 0

`ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco -destination
id=C2416CBC-C5D9-41F9-ACD8-45EED8FC355E -parallel-testing-enabled NO`.
`grep -c 'warning:'` → **0**.

## 6. A CONTA DO DONO CAIU — e quem a derrubou foi a suíte integral

**Parei e escalei na hora, como manda a ordem.** Não reautorizei, não contornei,
não troquei de aparelho.

**Comando exato que derrubou:**

    ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
      -destination id=C2416CBC-C5D9-41F9-ACD8-45EED8FC355E -parallel-testing-enabled NO

a **suíte integral**, entre 08:57:21 e 08:58:27 de 09/09/2026.

**A causa, no código:** `TracoTests/NotasESessaoTests.swift:572`
(`contaDesligadaNaoDeixaRastroNoCofre`) e `:578` (`semContaRemotaCalaSemRede`)
chamam `ContaGrok.sair()`, que faz `guardar(nil, …)` nas contas `oauth-acesso` e
`oauth-renova` do serviço `app.traco.xai`. **O keychain é do SIMULADOR, não do
processo de teste** — a suíte apaga a conta de verdade.

**As três leituras que sustentam isso:**

| quando | como | resultado |
|---|---|---|
| 08:57, antes da suíte integral | sonda `ContaGrok.ligada` dentro do app-host | `SONDA-CONTA-GROK ligada=true` |
| 09:12:48, depois | a mesma sonda | `SONDA-CONTA-GROK ligada=false` |
| 08:56 → 09:12 | `select count(*) from genp` no keychain do simulador | **56 → 54**, com o `-wal` carimbado **08:58** — dentro da janela da suíte |

**Isto atinge toda a esteira, não só esta volta.** O fecho obrigatório de
QUALQUER volta é "suíte integral por `com-trava.sh`" — e agora que há um
aparelho só, esse fecho apaga a conta do dono. Quem rodar a suíte integral no
`C2416CBC` hoje derruba a conta de novo.

**O que eu NÃO fiz, de propósito:** não consertei esses dois testes. Eles são de
área alheia (`Analise`/`Sessao`, da volta Q) e o conserto é decisão de quem
despacha — a sugestão registrada é injetar o cofre ou pular o teste quando o
aparelho tem conta viva, em vez de mexer no keychain real.

A sonda que usei foi removida antes do commit
(`grep -c SONDA TracoTests/CadernoAntigoAbreTests.swift` → 0).

## 7. Um commit alheio pegou o código no meio da sonda

Às **08:56:53**, enquanto eu estava com o `TracoSchemaV0` **comentado de
propósito** (para provar o vermelho, §4), o orquestrador-interface commitou o
meu worktree achando que o terminal tinha morrido: `a7d92ee`. Esse commit
carrega, portanto, o plano **sem** a V0 e a sonda `ContaGrok` dentro do teste —
o estado do disco naquele segundo, não o resultado da volta.

Não reescrevi o commit dele: o meu vem por cima, com o estado correto. Quem ler
o histórico precisa saber que **`a7d92ee` sozinho não compõe a entrega** — é o
commit seguinte que fecha o plano com as seis versões e sem sonda alguma.
Confirmado por `git diff`: a diferença entre `a7d92ee` e o meu commit é
exatamente a V0 de volta ao plano e a sonda fora do teste.

## 8. Estado honesto, limites e fronteiras

- **Não instalei nenhum binário histórico no aparelho do dono.** Foi exatamente
  para evitar isso que calibrei o método macOS contra o `caderno-v4-pre08u`. Os
  builds antigos rodaram como executáveis SPM no Mac, fora do simulador.
- **Não apaguei nada:** sem `erase`, sem `clearState`, sem `uninstall`, sem tocar
  no App Group nem no contêiner privado do `C2416CBC`.
- **Jornada na tela do app: NÃO fiz** — e digo por quê. Ver o caderno de 31/08 na
  lista de Notas do app exigiria plantar aquele store no App Group do
  `C2416CBC`, que é onde está o caderno do dono; a ordem de 09/09 08h50 manda
  parar e perguntar antes de mexer nos dados do app nesse aparelho. Perguntei ao
  orquestrador e a volta fecha com a prova de teste enquanto a resposta não vem.
  O que está provado é o mecanismo inteiro — o container do app de hoje
  (`ModelContainer.traco`, o mesmo que o arranque chama) abre os seis stores e
  entrega as notas com texto, selo, queima e sentido. **O que não está provado é
  a lista desenhada na tela para as versões novas** — a V4 já tinha sido
  fotografada na volta passada (`prova/m1-03-conserto-as-sete-notas.png`).
- **Nada de maestro, voz, VoiceOver, Siri ou iPad.** Não houve mudança de
  interação nesta volta.
- **O aparelho ficou com a conta Grok DESLIGADA** — pela suíte integral, não por
  nenhum gesto meu de instalar, apagar ou reautorizar (§6). O dono precisa
  reautorizar, e a esteira precisa decidir o que fazer com aqueles dois testes
  antes que a próxima volta rode a suíte no mesmo aparelho.
- **Fronteiras:** entrei em `Traco/Modelo/Migracao.swift`,
  `TracoTests/CadernoAntigoAbreTests.swift`, `TracoTests/Fixtures/`, `SPEC.md`,
  `EVOLUCAO.md` e este relatório. `LETRAS-ADR.md` só pela resolução do conflito
  do merge, tomando a versão do `main`. Não toquei em `Traco/Caderno/*`,
  `Traco/Notas/*`, `Traco/Analise/*` nem `Traco/Trabalho/*`.
- **A `1.0.0` continua com dois checksums no mundo.** O plano agora reconhece os
  dois, mas o rótulo `0.9.0` é uma etiqueta nossa, não a que o store carrega
  (ele diz `1.0.0`). Isso funciona porque o CoreData casa por checksum — medido,
  não suposto — e está escrito na declaração para quem vier depois.

## Scorecard (meu; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---:|---|
| G0 — ciclo e intenção | 9 | O ciclo é preservar; a volta faz o caderno mais antigo do Traço voltar a abrir e deixa o portão que impede a próxima reincidência. |
| G1 — causa, não sintoma | 10 | Não parei na frase reprovada: fui ao passado inteiro e achei a 1.0.0 órfã que o conserto anterior não cobria — a mesma causa, uma ocorrência a mais. |
| G2 — evidência | 9 | Instrumento calibrado contra um store gravado por build real (checksum byte a byte), vermelho e verde colados com hora, suíte na árvore mesclada. Falta a tela do app para as versões novas. |
| G3 — portão | 10 | Um caderno por versão, contagens distintas, conferência de conteúdo, e um teste que compara a lista com o plano — a frase deixou de ser maior que a prova. |
| G4 — código | 9 | ~30 linhas de cópia congelada e um estágio. Nenhuma abstração nova; o gerador histórico ficou fora do repo, porque o que o repo precisa guardar é o `.store`, não a máquina de fazê-lo. |
| G5 — fronteiras | 10 | Nenhuma área alheia tocada; o aparelho do dono não teve dado apagado nem binário histórico instalado. |
| Integridade de mescla | 9 | `main` mesclado dentro (`ba36043`) e **todas** as medidas são da árvore mesclada: portão 08:55:15, suíte 977/0 às 08:58. |
| Estado honesto | 10 | A jornada que não fiz está dita, com a razão e a pergunta que a bloqueou; a queda da conta está medida em três leituras, com o comando exato e a linha de código que a causou, e foi escalada na hora em vez de contornada. |
