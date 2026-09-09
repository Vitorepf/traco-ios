# G3 — revisão independente da M1 (migração do caderno)

**VEREDITO: CORRIGIR ANTES DE MESCLAR.** O reparo de `e8c7b7e` reproduziu o vermelho real e abriu, sem perder as sete notas, os cadernos V2, V3 e V4 que montei; mas o portão permanente declarado como “cada versão” só contém V4 e V5, e `main` já avançou cinco commits. Estado honesto está em 10, porém Correção, Contrato, Testes de regressão e Integridade de mescla ficam abaixo de 9: esta árvore não é aprovável ainda.

## Escopo e instrumento

- Candidato revisto: `e8c7b7e` (ADR 2026-09-09f), sem alterações de produto por este revisor.
- Simulador exclusivo: iPhone 17 `1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF`; usei UDID explícito e a trava `ferramentas/orca/com-trava.sh` em cada build/teste e sessão do helper. Não toquei no `C2416CBC` e não usei voz, Siri, ditado, VoiceOver ou iPad.
- Cada captura abaixo foi aberta e conferida. O helper `orca emulator` aceitou o toque em `notas-da-pagina` (`ok: true`), mas não mudou a tela; por isso não o usei para alegar uma lista visual. A prova de conteúdo é a contagem SQLite do store real e os asserts de texto executados no teste; a captura mostra apenas que o app chegou à Página, sem a recusa.

## O que foi observado

### Vermelho independente, com store real pré-08u

Montei `/tmp/traco-g3-m1-parent-33878872` em `8d9ce62`, gerei o store V4 nele e o montei no App Group real do meu aparelho. O binário pai quebrado (`05ef887`) recusou abrir: [captura](/tmp/traco-g3-m1-broken-v4-real-recusa-33878872.png) mostra literalmente **“O Traço não abriu o seu caderno”**, com a promessa de preservar o original; [log](/tmp/traco-g3-m1-broken-v4-real-log-33878872.txt) contém `NSCocoaErrorDomain 134504` e `Cannot use staged migration with an unknown model version`.

Isso descarta o falso verde de store no contêiner privado: minha primeira montagem naquele lugar abriu uma Página vazia e foi descartada como instrumento inválido, porque o app lê o App Group. O store correto tinha sete `ZNOTA` antes do lançamento.

### Verde, conteúdo e versões históricas

Instalei o candidato no mesmo `1A46…`, sem trocar o App Group V4. A [captura do V4](/tmp/traco-g3-m1-candidate-v4-arranca-33878872.png) mostra a Página sem a recusa, o [log](/tmp/traco-g3-m1-candidate-v4-log-33878872.txt) não tem erro de migração, e a consulta ao store real continuou em **7 `ZNOTA`** (7 antes, 7 depois). As mesmas montagens reais que gerei com o build histórico abriram no candidato e conservaram **2 notas V2**, **3 notas V3** e **7 notas V4**: [V2](/tmp/traco-g3-m1-candidate-v2-arranca-33878872.png), [V3](/tmp/traco-g3-m1-candidate-v3-arranca-33878872.png), [V4](/tmp/traco-g3-m1-candidate-v4-arranca-33878872.png).

V1 não foi montada: não há fixture V1 nem build histórico V1 anexado pelo candidato. Portanto V1 continua declarada, não observada.

### Histórico e contratos preservados

Comparei os fontes de `bf535c5`, `9ad639e` e `8d9ce62`: a lista persistida de `Nota` é idêntica nos três (inclui, entre outros, `uuid`, `texto`, `camposJSON`, `trancada`, datas, `queimada`, `minutosEscritos`, `sentido`, domínio, gatilho, série e dia); V3 acrescenta `ReciboEntrada` e V4 acrescenta `Trabalho`. As cópias aninhadas V2/V3/V4 do candidato correspondem a essa história; V5 é a única que aponta às classes vivas e V4→V5 é leve.

O diff da M1 não altera `Nota.swift`, `ReciboEntrada.swift` ou `Trabalho.swift`: a origem da 08u e `vozDoAutor` da 09b permanecem. O teste completo também exerceu `oTextoDoAutorAtravessa`, incluindo os sete textos, nota selada, queimada, `sentido` e a origem `.autor` para o caderno pré-08u.

## Achados que impedem a mescla

### P1 — o portão prometido não abre cada versão

`TracoTests/CadernoAntigoAbreTests.swift` documenta que “cada arquivo” é um caderno de versão real, mas `cadernos` contém somente `caderno-v4-pre08u` e `caderno-v5-origem`. Não há fixtures nem argumentos V1, V2 ou V3. Meu teste manual prova V2/V3 **neste candidato**, mas não deixa uma proteção versionada no repositório; V1 nem foi observado.

O teste existente pega a mudança proibida: em checkout temporário, acrescentei `sondaG3SemV6` à `Nota` viva sem abrir V6. `xcodebuild test -only-testing:TracoTests/CadernoAntigoAbreTests` falhou como deveria, com `SwiftDataError.loadIssueModelContainer` / 134504 para a fixture V5, enquanto V4 e o teste de texto passaram. Isso valida o mecanismo, não a cobertura que a ADR promete.

Correção mínima: comitar stores genuinamente gravados pelos builds V1, V2 e V3 (com origem/commit documentados), adicioná-los a `cadernos`, e exigir em cada um contagem e conteúdo representativo. Reexecutar a quebra da classe viva e a suíte após isso.

### P1 — o candidato não está na ponta de `main`

No fechamento da revisão, `HEAD..main` contém cinco commits: `69b45a2`, `0ac65f9`, `bb619bf`, `64d1d3c` e `c23a4c5`. Não declarei esta bateria como certificação do merge futuro: rebase/integração e a repetição dos portões são obrigatórios antes de nova aprovação.

## Scorecard G3

| Dimensão | Nota | Evidência / limite |
|---|---:|---|
| Visão | 10 | Restabelece a abertura do caderno instalado, sem caminho silencioso. |
| Contrato | 8 | Schemas congelados corretos, mas a promessa de portão “cada versão” não está cumprida. |
| Correção | 8 | Vermelho e verde reais, V2/V3/V4 observadas; V1 e o portão integral faltam. |
| Estado honesto | 10 | O vermelho expõe a recusa e preserva o original; o verde mantém sete notas. |
| Jornada real | 9 | App realmente lançou no store V4 e o conteúdo persistido ficou 7; limite do toque do helper está declarado. |
| Preservação / autoria | 10 | 08u e 09b não foram desfeitas; texto e origem do autor atravessaram o teste. |
| Testes de regressão | 8 | 977 verdes e quebra do portão, porém faltam V1/V2/V3 como fixtures permanentes. |
| Build | 10 | `** TEST SUCCEEDED **`; `977 tests in 158 suites passed after 55.426 seconds`; zero `warning:` no log. |
| Acessibilidade | N/A | Não houve mudança de interação; não usei VoiceOver por ordem do dono. |
| Performance / movimento / fora do app | N/A | Migração de modelo, sem superfície ou animação alterada. |
| Integridade de mescla | 7 | `main` avançou cinco commits; a evidência é do candidato isolado, não do merge. |
| Relato e evidência | 10 | Artefatos abertos, comandos e limites explicitados acima. |

## Fechamento operacional

Restaurei o App Group e o contêiner privado do `1A46…` a partir dos backups anteriores: ambos voltaram a 7 `ZNOTA`; guardei os arquivos gerados da corrida em `/tmp/traco-g3-m1-pos-review-33878872` e removi os três checkouts descartáveis. Nenhum branch foi mesclado e nenhum arquivo de produto foi corrigido.
