# R1-C — a fusão da retomada com o `main`, e o vermelho que ela desenterrou

**Papel:** implementador. **Não** reabri o mérito da R1 (aprovada no re-G3, 9 em
toda dimensão aplicável) e **não** acrescentei função. Isto é integração.

**Instrumento.** Um simulador só, o meu: **iPhone 17 Pro (teste 3)
`34CC3F94-FDB5-4575-A4F5-80271829A18B`**. O `C2416CBC` (conta Grok do dono) não
foi tocado: nada instalado, nada apagado, nada lançado nele. Todo `xcodebuild`,
`xcodebuild test` e toda sessão de `orca emulator` passou por
`ferramentas/orca/com-trava.sh` — **segurei a trava em todas**. Nenhum maestro.
Nenhuma voz, nenhuma Siri, nenhum VoiceOver, nenhum iPad. Desliguei o meu
aparelho com `simctl shutdown` do meu UDID e nunca com `orca emulator kill`.

---

## 1. O que fundi, e onde

Worktree `volta-r1-retomada`, sobre `e72dd85`. Em **duas etapas**, porque o
`main` andou durante o trabalho:

| etapa | `main` trazido | conflitos |
|---|---|---|
| 1 | `3916924` (MAC-1, MAC-1-B, V13, A1, C1, Q, S1) | `SPEC.md`, `ferramentas/orca/LETRAS-ADR.md` |
| 2 | `05ef887` (F5b, e o `55af39f` da ESTEIRA) | `SPEC.md` |

**Nenhum conflito de código.** A R1 vive em `Traco/Trabalho/`; o `main` andou em
`Modelo`, `Notas`, `Padroes`, `Pagina`, `App` e `TracoWidget`.
`Traco.xcodeproj/project.pbxproj` fundiu sozinho, e `xcodegen generate` sobre a
árvore mesclada devolveu **diff vazio** — a fusão do projeto é a canônica.

## 2. Cada escolha de semântica, por escrito

1. **Ordem das ADRs no `SPEC.md`.** O arquivo é cronológico por ENTRADA, não por
   letra (a `08t` já vinha antes da `08o`). As ADRs que já estavam em `main`
   (`08u`, `09b`, `08v`) ficam na ordem em que entraram; a `08y` vai por último.
   **Nenhum texto dos dois lados foi cortado** — os dois blocos inteiros estão lá.
2. **`LETRAS-ADR.md`.** Fica a tabela do `main` (mais nova: traz o bloco de
   2026-09-09 e a `09c` da S1) e, dentro dela, a linha `08y` na redação da R1 —
   "no branch da R1", que é o estado verdadeiro desta letra. Estado de letra
   alheia não foi tocado.
3. **`EVOLUCAO.md`.** Fundiu sozinho. A linha "Intenção→artefato" ficou com a
   redação da R1, a única das duas que mexeu nela.
4. **"A origem acompanha todo consumidor" (ADR 09b) não alcança a R1 — decisão
   declarada, não esquecimento.** A regra vale para quem lê NOTA como voz do
   autor. `DocumentoTrabalho.mudancasDesde` sai de `artefatos`, `acoes`,
   `evidencias`, `apoioMarcadoEm`, `trechoDelimitadoEm` e `hipoteses` — tudo do
   documento do Trabalho, nenhuma nota. Os `selos` da folha existiam antes das
   duas voltas e ficaram como estavam. Se um dia a retomada citar nota, a origem
   viaja junto.

## 3. O ACHADO — quatro testes de tela vermelhos, e a causa não é a fusão

**Primeira corrida da árvore mesclada, os quatro falharam no mesmo ponto:**

```
CurvaZeroRetomadaUITests.swift:65: error: … XCTAssertTrue failed - a Página não abriu
… Failed to tap "notas-da-pagina" Button: No matches found …
Test Suite 'CurvaZeroRetomadaUITests' failed at 2026-09-09 06:16:23.378.
```

**Fotografei a tela DURANTE a corrida**, em laço de `simctl io` (o teste não
chega ao ponto onde pausa para a foto). O que se vê no quadro de 06:25 — e é
tudo o que a tela mostra, o app não abre nada além disto — é o **arranque
honesto da A1** (ADR 08s):

> **O Traço não abriu o seu caderno.**
> O arquivo onde as suas notas ficam neste aparelho não respondeu. Nada foi
> apagado: o Traço parou aqui em vez de abrir um caderno vazio por cima do seu.
> 2 notas estão em Markdown no app Arquivos, na pasta Traço. […]
> **Tentar abrir de novo**
> `SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer, _explanation: nil)`

### A causa, medida em três builds sobre o MESMO arquivo

Copiei o `default.store` do App Group e **restaurei a cópia antes de cada
lançamento**, no mesmo aparelho:

| build | de onde saiu | o que a tela mostra | captura |
|---|---|---|---|
| `e72dd85` — R1 antes da fusão | checkout descartável `/tmp/r1c-antes` | **a Página abre**, com teclado e "Quarta-feira, 9 de setembro" | `r1c-antes-tela.png` (06:31) |
| `main` sozinho (`3916924`) | checkout descartável `/tmp/r1c-pai` | "O Traço não abriu o seu caderno" + `loadIssueModelContainer` | `r1c-pai-tela.png` (06:30) |
| árvore mesclada | o meu worktree | idem | `r1c-mesclado-arranque-falhou.png` (06:25) |

Os dois checkouts descartáveis foram criados só para isto, só com o que já está
no repositório, e **foram removidos ao fim** (`/tmp/r1c-pai`, `/tmp/r1c-antes`).

**Por quê.** O `ZNOTA` daquele store **não tem `ZORIGEMRAW`** (conferido por
`PRAGMA table_info`): foi gravado por um build anterior à ADR 08u. A 08u
acrescentou `Nota.origemRaw` como migração leve DENTRO do `TracoSchemaV4`,
justamente para fugir do "Duplicate version checksums" — mas o `TracoSchemaV4`
aponta para a **classe viva**, então o checksum da V4 mudou junto. O caderno
carrega o carimbo da V4 antiga, nenhum estágio do plano casa, e o CoreData
recusa o container inteiro. A A1 faz o certo: para em vez de abrir vazio por
cima — e é ela que torna o defeito **visível** em vez de silencioso.

**O que isso quer dizer, sem enfeite: quem já tem o Traço instalado não abre o
caderno depois desta atualização.** É defeito do `main`, não da R1: a camada de
modelo da árvore mesclada é byte a byte igual à do `main`
(`git diff main -- Traco/Modelo Traco/Notas Traco/App Traco/Padroes Traco/Pagina Traco/Perfil`
sai vazio) e o `e72dd85` abre o mesmo arquivo. **Não consertei**: migração de
esquema com o caderno do dono em jogo é volta própria. Escalado ao orquestrador
e registrado no `EVOLUCAO.md`.

**O que a fusão mudou na regra que o teste guardava.** Nada. O teste guardava
"quem volta ao trabalho lê na primeira tela o que houve", e continua guardando:
com um caderno que a própria árvore mesclada cria, ele passa e devolve **3
toques, 0 arrastos, 7/7**. O que o vermelho revelou é uma regra de OUTRO lado —
a da A1 — encontrando um dado que a MAC-1 deixou sem caminho de migração.

## 4. Segundo achado, menor, e também da fusão

O `main` de 09/09 (`55af39f`, entrou entre as minhas duas etapas) passou a exigir
que **pré-condição de estado more dentro do teste**. Os quatro da R1 não cumprem:
o estado vem de fora (`ferramentas/orca/semear-retomada.py`) e a visita anterior
mora no `Library/Preferences` do contêiner de DADOS do app — que o
`xcodebuild test` **recria quando o binário muda**. Medido nesta volta: na
primeira corrida depois de um binário novo o bloco some e o teste fica vermelho;
replantado o estado e reexecutado, passa. Isolados, os quatro passam.

Não consertei: mudar de onde a visita mora é decisão da ADR 08y (ela escolheu
`UserDefaults` de propósito — "quando o autor abriu a folha é fato deste
aparelho, não do trabalho"), não de uma reconciliação. **Fica declarado como
dívida nomeada da R1.**

## 5. Prova de fecho na árvore mesclada

Tudo em `34CC3F94`, por `com-trava.sh`, com `-parallel-testing-enabled NO`.

**Suíte integral, duas execuções, as duas verdes:**

```
✔ Test run with 979 tests in 157 suites passed after 54.464 seconds.
** TEST SUCCEEDED **
```
```
✔ Test run with 979 tests in 157 suites passed after 53.722 seconds.
** TEST SUCCEEDED **
```

`grep -c "warning:"` no log completo das duas: **0** e **0**. Nenhuma corrida
travou antes de conectar (nenhum `0 de N`).

**Os quatro de tela** (esquema `TracoUITests`, que não entra na suíte integral),
cada um isolado e com o estado replantado antes:

```
testCurvaZeroEmToquesEGestos                            ** TEST SUCCEEDED **
testTetoExcedenteEAVisitaQueRecomecaAoReabrir           ** TEST SUCCEEDED **
testSemVisitaGuardadaAFolhaCala                         ** TEST SUCCEEDED **
testBlocoDaRetomadaEmAX5                                ** TEST SUCCEEDED **
```

A medida da curva-zero, na árvore mesclada (`/tmp/curva-zero/medida.txt`):

```
janela=874pt  toques-ate-a-folha=3
gesto objetivo proximo-passo versao-nova ato-realizado resultado-informado quando-foi-o-retorno dificuldade vistos
0     0.24*    0.36*         0.58*       0.53*         0.66*               0.64*                0.48*       7
gestos-ate-os-sete=0  toques=3  vistos=7/7
```

**A folha, fotografada na árvore mesclada:**
`ferramentas/orca/r1c-mesclado-retomada.png`. O que se vê nela, de cima para
baixo: "voltar"; o título "Apresentar minha ideia para a diretoria"; a intenção
"Explicar a proposta em cinco minutos sem ler o slide"; "Rever a intenção";
"Continuar: Ensaiar os tres blocos com o cronometro"; o bloco **DESDE 7 DE SET.
DE 2026, 10:00** com quatro linhas — "Dificuldade registrada: eu explico o
problema duas vezes e o meio fica longo", "Você marcou como realizada: Ler a
abertura em voz alta para a Ana", "Versão 2 preparada por Grok", "Trecho que você
vai exercitar: a abertura de trinta segundos" — e "e mais 1 desde então"; depois
"Último retorno · Você · 7 de set. de 2026, 19:30", "Resultado que você informou:
Funcionou em parte", o texto do relato, "Ver retorno e histórico" e o trilho
"NESTE TRABALHO, PREFIRO" com Combinar marcado. É o contrato inteiro da ADR 08y,
vivo depois da fusão.

## 6. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---:|---|
| Correção da fusão | 9 | dois conflitos, os dois de documento, os dois com os dois lados preservados; `xcodegen` devolve diff vazio; 979/157 verdes duas vezes, 0 aviso |
| Semântica declarada | 9 | quatro escolhas escritas uma a uma, incluindo a que diz por que a regra da 09b NÃO alcança a R1 |
| Achado | 9 | o vermelho foi tratado como resultado: causa medida em três builds sobre o mesmo arquivo, com captura de cada um, e a conclusão contraria o palpite fácil ("a fusão quebrou") |
| Estado honesto | 9 | o defeito é do `main` e está dito assim; a dívida da pré-condição está dita; o que não consertei está nomeado com o motivo |
| Escopo | 9 | nenhuma função nova, nenhum mérito reaberto, nenhuma linha de produção tocada nesta volta |

**O que esta volta NÃO prova.** Não prova que o caderno do DONO, no aparelho
dele, tem a mesma forma do store que medi — mede um store gravado por um build
anterior à 08u neste simulador, que é a mesma forma, mas o aparelho dele não foi
tocado. Não prova nada sobre o mérito da R1 (já aprovado) nem sobre a F5b, a
MAC-1 ou a A1 além do que os testes delas dizem. E não prova os quatro de tela
sob a lei das dez corridas do `55af39f`: rodei cada um isolado, não dez vezes.
