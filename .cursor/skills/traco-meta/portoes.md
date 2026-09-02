# Portões

Cada portão: método + condição de passagem + evidência. Sem evidência = fail.

## F — Ferro (sempre)

| # | Método | Passa se | Evidência |
|---|---|---|---|
| F1 | Grep + leitura do diff | Nenhuma prosa de modelo / complete / resumo / elogio entra em `Nota.texto` | paths |
| F2 | Grep | `api.x.ai` só em `AnaliseRemota`/`PadroesRemoto`, via `ContaGrok.token()`; zero chave `xai-`; nada de `Nota.fechada` na rede | `rg 'api.x.ai' Traco` = 2 arquivos; `rg 'xai-'` vazio |
| F3 | Leitura | Análise na pausa (§17) e no botão; classifica `Caderno.prosa` / voz do autor | call site |
| F4 | Lista fechada | IA só: rotear, avisar, uma pergunta, Recordar, Padrões, calar | diff |

## C — Caderno / Markdown-arquivo (se tocou na página)

| # | Método | Passa se | Evidência |
|---|---|---|---|
| C1 | Teste + ecrã | `textoVisivel` e a página não contêm `#` isolado de título, ` ``` `, `:::`, `\|---`, `- [ ]`, `traco://` | `CadernoTests` + screenshot |
| C2 | Toque no portal | Editar mantém a figura (cartão, colunas, gutter). Não vira campo nu nem fonte | Maestro ou simctl + png |
| C3 | Régua | Toque aplica **palavra** → forma. Autor não digita marca | screenshot da régua + bloco |
| C4 | Parser | Cerca aberta de recipiente continua recipiente, não parágrafo-fonte | teste |
| C5 | Round-trip | `serializar` → `fatias` → `textoVisivel` = o que o autor escreveu | teste |

## V — Visual (se tocou UI)

| # | Método | Passa se | Evidência |
|---|---|---|---|
| V1 | Ecrã | Um âmbar vivo. Cursor **ou** Porteiro **ou** Concluída — não um festival | png |
| V2 | Contraste | Texto em `tinta` / `tintaSuave` / `tintaFraca` (#8E8E8A). Sem #5C5C5A | hex no diff |
| V3 | Portal | Código anuncia-se (língua + gutter + sintaxe ≠ âmbar). Ficheiro tem figura por tipo | png |
| V4 | Vazio | Página sem forma = cursor, sem placeholder, sem chip | png |
| V5 | Alvo | Controlos ≥44pt. Régua scrollável, palavras não ícones-sopa | hierarquia / png |

## R — Runtime (se tocou código)

| # | Método | Passa se | Evidência |
|---|---|---|---|
| R1 | `xcodebuild test` | Suite verde | log `TEST SUCCEEDED` |
| R2 | Instalar no Simulator iPhone 17 | App abre <1s na página vazia | `simctl launch` + png |
| R3 | Fluxo da fatia | Maestro ou toque manual do gesto ponta a ponta | yaml + png |
| R4 | Regressão | Porteiro WOOP/trava/silêncio e caderno código/título ainda passam se a fatia os pode partir | testes existentes |

Comandos (repo `/Users/vitorepf/develop/traco-ios`):

```bash
xcodegen generate
xcodebuild -scheme Traco \
  -destination 'platform=iOS Simulator,id=1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF' \
  -derivedDataPath build test
xcrun simctl install 1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF \
  build/Build/Products/Debug-iphonesimulator/Traço.app
```

UDID pode mudar. Confirma com `xcrun simctl list devices booted`.

Evidência visual em `/tmp/traco-verify/`. Não deixes png de Maestro na raiz do repo.

## P — Produto (sempre, leitura)

| # | Método | Passa se |
|---|---|---|
| P1 | SPEC §2 §12 | Sem chat, streak, resumo, nuvem, ouvinte, busca semântica |
| P2 | SPEC §3 | Sem placeholder na página vazia |
| P3 | SISTEMA caderno | Régua = vocabulário; cromo por família, sem arco-íris |
| P4 | Tese | A fatia multiplica gesto/visão/memória — não atalho |

## Como reportar no fim da fatia

```
FATIA: …
F1 pass … 
C2 pass /tmp/traco-verify/….png
R1 pass (N testes)
P4 pass — <uma frase honesta>
AINDA P0: …
```
