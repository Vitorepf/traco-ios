# M1 — o caderno gravado antes da 08u tem de abrir

**Volta:** M1 · **Papel:** implementador · **ADR:** 2026-09-09f
**Branch:** `Vitorepf/volta-m1-migracao` (não mesclada)
**Aparelho:** iPhone 17 `1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF` — meu, e só ele.
**Trava:** todo `xcodebuild`, todo `xcodebuild test` e a única sessão de
`orca emulator` passaram por `ferramentas/orca/com-trava.sh`.

## Linha do ciclo (G0)

**Ciclo:** preservar o que o autor escreveu — antes de multiplicar ou melhorar.
**Intenção:** o autor abre o Traço e o caderno dele está lá, depois de qualquer
atualização. **Obstáculo:** um caderno gravado antes da 08u não abria mais.
**Evidência:** o mesmo store, pré-08u, medido no aparelho em dois builds.

## 1. O vermelho, reproduzido antes de qualquer conserto

**O store é real, não simulado.** Montei um checkout descartável do build
`8d9ce62` (o commit imediatamente anterior à 08u; a `Nota` dele tem exatamente
as mesmas propriedades gravadas de `e72dd85`, que a R1-C mediu abrindo), levei
só o instrumento — um teste que grava sete notas — e rodei no meu UDID. O que
saiu é um `default.store` do SwiftData daquela versão:

    NSStoreModelVersionIdentifiers  = ["4.0.0"]
    NSStoreModelVersionChecksumKey  = "ImY8W7hR8jJH+xS4hddeRW+haXr9qO3ZDVx/J9RS3sI="
    ZNOTA: 7 linhas, e a coluna ZORIGEMRAW NÃO EXISTE

Aberto pelo `main` de hoje (`05ef887`), no aparelho, com o store plantado no App
Group (`Containers/Shared/AppGroup/…/Library/Application Support/default.store`
— é ali que a `ModelConfiguration` padrão põe o caderno, porque o app declara
`group.app.traco`):

    CoreData: error: NSCocoaErrorDomain (134504)
    CoreData: error: 	NSLocalizedDescription : Cannot use staged migration with an unknown model version.
    SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer, _explanation: nil)

**Captura `prova/m1-01-main-recusa-caderno-pre08u.png`** — o que se vê: a tela
da A1 em fundo claro, título **"O Traço não abriu o seu caderno."**, o parágrafo
"Nada foi apagado: o Traço parou aqui em vez de abrir um caderno vazio por cima
do seu", a linha "Não encontrei cópia em Markdown no app Arquivos", o botão
**"Tentar abrir de novo"** e, em cinza no rodapé, a string
`SwiftDataError(… loadIssueModelContainer …)`. Relógio 07:59.

O mesmo vermelho, medido pelo teste em vez da tela:

    ✘ Test cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno:) recorded an issue with 1 argument
      caderno → caderno-v4-pre08u at CadernoAntigoAbreTests.swift:37:6:
      Caught error: SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer, _explanation: nil)
    ✘ Test run with 2 tests in 1 suite failed after 0.071 seconds with 2 issues.

## 2. A hipótese do comentário: confirmada no raciocínio, invertida na conclusão

`Migracao.swift:69-75` dizia que um `VersionedSchema` novo com a mesma lista de
classes teria o mesmo checksum "porque os schemas aqui apontam para a classe
viva, não para uma cópia congelada". **Essa frase está certa — e é exatamente a
razão pela qual o caderno do autor não abre.** Um schema que aponta para a
classe viva não é uma versão: é um apelido para "o código de hoje". O checksum
dele anda junto com o código; o store guarda o checksum do dia em que foi
gravado; quando a 08u pôs `origemRaw` na `Nota`, a V4 passou a valer
`2AijN0DBwZAONF26xkHDYvpSS8mF0j+UmiC853rhPUA=` e o caderno de `ImY8W7…` deixou
de casar com qualquer versão do plano.

O que o comentário concluiu — "não abra versão nova" — era o oposto do conserto.
**Não é o `origemRaw` com padrão que está errado; é acrescentá-lo sem abrir
versão.** O erro não foi medido contra store real porque nenhum teste abria um.

## 3. O conserto: congelar as cópias, abrir a V5 de verdade

`Traco/Modelo/Migracao.swift`:

| versão | classes | de onde vem |
|---|---|---|
| V1 | `TracoSchemaV1.Nota` | já era congelada |
| V2 | `TracoSchemaV2.Nota` | **congelada agora** — a forma de 02/09 até a 08u |
| V3 | V2.Nota + `TracoSchemaV3.ReciboEntrada` | **congelada agora** |
| V4 | V2.Nota + V3.ReciboEntrada + `TracoSchemaV4.Trabalho` | **congelada agora** — é a versão do caderno do autor |
| V5 | `Nota`, `ReciboEntrada`, `Trabalho` **vivas** | nova; `origemRaw` mora aqui |

V2, V3 e V4 reusam a mesma `Nota` congelada porque **entre elas a `Nota` não
mudou** — conferido no `git` em `bf535c5` (V2), `9ad639e` (V3+V4) e `8d9ce62`
(pré-08u): lista de propriedades gravadas idêntica. O que distingue os três
checksums é a LISTA de classes. Estágio novo: V4→V5 leve.
`ModelContainer.traco` abre pela V5.

**Custo, dito de frente:** três classes duplicadas, ~60 linhas, que ninguém
instancia e que nunca mais se tocam. É o preço por versão de poder abrir o que o
autor já escreveu.

**Caminho mais barato, considerado e recusado:** tirar o `migrationPlan` e
deixar o CoreData inferir a migração leve. Abriria o caderno de hoje com um diff
menor — e desistiria de poder renomear ou apagar um campo amanhã sem perda, além
de desfazer o "schema versionado desde o dia 1". Recusado.

## 4. A prova: o caderno antigo abre, com as notas contadas

Mesmo aparelho, mesmo store (`cmp` limpo contra o fixture **depois** da recusa
do `main`: a rede da A1 não tocou em nada), build desta volta instalado por
`simctl install` no UDID explícito.

- Arranque: **zero** ocorrências de `134504`/`loadIssue` no log do `simctl launch`.
- **`prova/m1-02-conserto-arranca.png`** — o que se vê: nenhuma tela de recusa;
  o app abre na Página de hoje ("Notas", "Quarta-feira, 9 de setembro"), régua de
  formas e teclado. Relógio 08:01.
- **`prova/m1-03-conserto-as-sete-notas.png`** — o que se vê, e é a prova: a
  lista **Notas** com **sete linhas** do caderno pré-08u —
  `caderno antigo 7`, `caderno antigo 6`, **`Expressiva — queimada`** com a linha
  de sentido `linha 5` e `5 min · hoje`, `caderno antigo 4`,
  **`Expressiva — trancada`** com `não se relê · hoje`, `caderno antigo 2`,
  `caderno antigo 1`. **O selo e a queima atravessaram a migração**, e o
  `sentido` que o autor escreveu está lá. Relógio 08:02.
- Contagem antes e depois, no SQLite do mesmo arquivo: **7 → 7**, e a coluna
  `ZORIGEMRAW` passou a existir (a migração leve correu de verdade).

## 5. O portão que faltava

`TracoTests/CadernoAntigoAbreTests.swift` abre um **store REAL de cada versão**,
congelado em `TracoTests/Fixtures/`, copiado para um temporário (o bundle é
somente-leitura e a migração escreve), e conta as notas:

- `caderno-v4-pre08u.store` — gravado pelo build `8d9ce62`, anterior à 08u.
- `caderno-v5-origem.store` — gravado pelo build desta volta.

Os testes de `DiscoTraco` injetam closures e **nunca abriram um store antigo de
verdade**; foi por isso que a 08u passou verde e derrubou o arranque no aparelho
do autor. Os dois testes de migração que existiam (`migracaoV2…`,
`migracaoV3…`) gravavam na V2/V3 com a **classe viva** — o mesmo modelo dos dois
lados, migração encenada. Passaram a gravar com as cópias congeladas, e agora
medem o que o nome deles promete.

**O portão fica vermelho de verdade — provado, não afirmado.** Acrescentei
`var sondaDoPortao: String = ""` à `Nota` viva, sem abrir V6:

    ✘ Test cadernoGravadoPorBuildAntigoAbreComAsNotas(caderno:) recorded an issue with 1 argument
      caderno → caderno-v5-origem at CadernoAntigoAbreTests.swift:38:6:
      Caught error: SwiftDataError(… loadIssueModelContainer …)
    ✔ Test oTextoDoAutorAtravessa() passed after 0.016 seconds.
    ✘ Test run with 2 tests in 1 suite failed after 0.236 seconds with 1 issue.

O `caderno-v4-pre08u` seguiu **verde** nessa corrida (a V4 é congelada e migra
para frente); quem pega o defeito é o caderno da versão corrente. A sonda foi
revertida (`grep -c sondaDoPortao Traco/Modelo/Nota.swift` → 0).

**A regra que fica:** toda mudança em `Nota`, `ReciboEntrada` ou `Trabalho` —
atributo com padrão inclusive — congela a cópia na versão corrente, abre a
seguinte, acrescenta o estágio, e **grava um caderno congelado novo antes de a
mudança entrar**. Depois é tarde: o build que gravava aquela versão não existe
mais. `GerarCadernoCongelado` faz o `.store`; a receita está no comentário do
próprio teste.

## 6. Suíte

    ✔ Test run with 977 tests in 158 suites passed after 53.923 seconds.

`ferramentas/orca/com-trava.sh xcodebuild test … -destination id=1A46B6D3… -parallel-testing-enabled NO`.
Zero `warning:` no log. (O `main` tinha 974; os três a mais são o portão e o
gerador.)

## 7. Estado honesto, limites e fronteiras

- **Não desfiz a 08u nem a 09b.** `origemRaw`, `origem` e `vozDoAutor` ficam
  como estão; só a migração mudou. As notas antigas chegam como `.autor`,
  conferido no teste.
- **Não toquei no `C2416CBC`.** Nada de instalar, apagar ou rodar teste nele.
- **Não entrei em `Traco/Caderno/*`, `Traco/Notas/*` nem
  `Traco/App/Sessao.swift`** — as áreas da C1-D e da S1-B. A causa não estava
  lá.
- **Entrei em `TracoTests/IntegridadeEntradaTests.swift` e
  `TracoTests/TrabalhoTests.swift`**, que não estavam cercados: são os dois
  testes de migração, e eles quebraram *porque* o conserto tornou a V2/V3
  congeladas. Corrigi a ficção, não o resultado.
- **Nada de maestro, voz, VoiceOver, Siri ou iPad.** A navegação até a lista de
  Notas foi **um** toque por `orca emulator tap` (0.103, 0.101, o botão
  `notas-da-pagina` lido na árvore de AX), sob a trava; a prova de tela é
  captura `simctl` do meu UDID.
- **Árvores descartáveis, removidas:** `/tmp/traco-pre08u` (build `8d9ce62` +
  um teste gerador de fixture) e `/tmp/traco-main` (build `05ef887`, sem nada
  acrescentado). Levei só o instrumento para o pai; nada além dele.
- **Limite do instrumento:** o `caderno-v4-pre08u` tem sete notas escritas pelo
  gerador, não o caderno do dono. Ele prova a FORMA (versão 4.0.0, checksum
  pré-08u) e a travessia; não prova volume nem conteúdo do aparelho dele. Um
  caderno de verdade, exportado do iPhone do dono, seria evidência mais forte e
  não estava ao alcance desta volta.
- **Versões 1.0.0 e 2.0.0:** congeladas agora, mas **sem fixture** — não tenho
  um store real dessas versões e não vou fabricar um com o código de hoje, que
  seria circular. O portão cobre a 4.0.0 e a 5.0.0.
- **Aparelho restaurado:** não rotacionei, não mexi em tamanho de letra, e
  desliguei só o meu UDID com `simctl shutdown`.

## Scorecard (meu; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---:|---|
| G0 — ciclo e intenção | 9 | O ciclo é preservar; a volta abre o caderno do autor e deixa o portão que impede a reincidência. |
| G1 — causa, não sintoma | 10 | A causa medida (`134504`) contradiz a hipótese barata (`origemRaw`) e acerta o mecanismo: schema apontando para a classe viva. Todas as versões corrigidas, não só a que doía. |
| G2 — evidência | 9 | Store real pré-08u, dois builds no mesmo aparelho, três capturas descritas, contagem 7→7 no SQLite, vermelho e verde colados. Falta o caderno do próprio dono. |
| G3 — portão | 9 | Portão provado vermelho com sonda e revertido; cobre 4.0.0 e 5.0.0, não 1.0.0/2.0.0. |
| G4 — código | 9 | ~60 linhas de cópia congelada, custo declarado, alternativa barata considerada e recusada por escrito. Nada de abstração nova. |
| G5 — fronteiras | 10 | Nenhuma área alheia tocada; os dois testes fora do cerco eram os de migração e a razão está dita. |
