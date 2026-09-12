# G3 TEMPO — REPROVADO: a espera ganhou estado, e a oficina ganhou um estado que não sai

**Candidato:** `Vitorepf/tempo`, ponta **`02dd5b4`** (dois commits sobre `d0827be`).
**Veredito: REPROVADO.** Três dimensões abaixo de 9, duas delas por **defeito confirmado
com vermelho determinístico** que eu plantei e rodei. **Não corrigi nada.**

O que o autor afirma sobre o TETO é verdade e eu reproduzi tudo: a separação
fato × decisão, a guarda que fica vermelha, o limite externo de transporte, a suíte, o
warning único. O que não se sustenta é a peça que ele chamou de *"armadilha fechada de
passagem"*: **a `geracao` de `OficinaTrabalho` fechou um buraco e abriu dois maiores**,
porque ela é UMA por oficina e as três rotas que a usam **não se excluem** — ao contrário
do que o comentário dela afirma.

---

## 1. Instrumento desta revisão

- **teste 4** (`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`), tudo sob `com-trava.sh`.
  **Não toquei em `B91C8DEF` nem em `34CC3F94`** (os dois de conta): nenhum comando meu
  os nomeia. Nenhuma chamada real, nenhuma janela de conta gasta.
- `xcodegen generate` antes de tudo: **o `project.pbxproj` comitado não mudou** — o autor
  o gerou coerente com o `project.yml`.
- Build **LIMPO** (`rm -rf build` antes) e um build **Release** completo, que ninguém
  tinha feito nesta volta.
- Capturas próprias: laço de `xcrun simctl io A1DF082C… screenshot` a 1 Hz **enquanto** o
  `EsperaComEstadoUITests` dirigia (22 quadros).
- Nada de maestro (três simuladores ligados; a lei da casa proíbe usá-lo como evidência).

---

## 2. O que eu confirmei do que o autor afirma

### 2.1 A guarda do teto, pelos dois lados

Rebaixei `Grok.teto` a 240 e rodei `GrokContratoTests` — a guarda **acusa**, com as duas
linhas que ele prometeu:

```
✘ Test oTetoCobreAPiorLatenciaMedida() recorded an issue at GrokContratoTests.swift:42:9:
  Expectation failed: (Grok.teto → 240.0) > (Grok.esperaObservada → 241.0)
✘ Test oTetoCobreAPiorLatenciaMedida() recorded an issue at GrokContratoTests.swift:44:9:
  Expectation failed: (Grok.teto → 240.0) == (300 → 300.0)
✘ Test run with 5 tests in 1 suite failed after 6.052 seconds with 2 issues.
```

**A irmã que NÃO acusa existe e eu a vi:** com o teto de volta a 300, na corrida integral,
`✔ Test oTetoCobreAPiorLatenciaMedida() passed after 0.001 seconds.` Vigia provado nos dois
sentidos.

### 2.2 O limite externo que decide — medido de novo, por mim

`✔ Test oTetoDoPedidoGanhaDoTetoDaSessao() passed after 6.017 seconds.`

Config de 2 s, pedido de 6 s, erro aos ~6 s: **o valor do PEDIDO governa**, e os 60 s de
fábrica da `URLSessionConfiguration` não tornam o `Grok.teto` decorativo. Somado à
observação de campo (241 s servidos pela x.ai numa chamada com `URLSession.shared`), o
"nenhum limite externo abaixo de 300 s" está provado nas duas direções. **Esta era a
pergunta que mais podia derrubar a volta, e ela se sustenta.**

### 2.3 A forma da frase na ADR

A ADR 2026-09-10a diz, com todas as letras: *"~1,25× de folga sobre os 241 s observados.
[…] isto não é um novo pior caso medido — ninguém mediu 300 — e não é promessa ao autor.
'Medimos 300' seria falso"*. **É exatamente a forma que o G0 exigiu**, e o mesmo texto
está no comentário de `Grok.teto`, que é onde o próximo vai ler. Sem ressalva.

A letra: `10a` **não** está no `LETRAS-ADR.md` do candidato, e está certo assim — o
orquestrador a reservou em `main` (`aa4d68e`), onde `grep -c` devolve **uma** linha de
tabela (`| 10a | TEMPO · … | reservada, volta viva |`).

### 2.4 Suíte, warnings e Release

Build LIMPO no teste 4, com **duas sondas minhas** dentro da árvore:

```
✘ Test run with 1026 tests in 164 suites failed after 95.489 seconds with 2 issues.
```

**1026 − 2 sondas = 1024**, que é a contagem do autor, e as 2 falhas são as minhas. **Isto
é a prova de que rodei a MINHA árvore**, não um relatório alheio.

Warnings do build limpo: **1**, e é o herdado —
`Traco/Notas/NotasView.swift:811:30: warning: '+' was deprecated in iOS 26.0`. Nenhum novo.

`Test Case '-[TracoUITests.EsperaComEstadoUITests testAEsperaNasNotasMostraPensandoTempoECancelar]' passed (18.219 seconds).`
— verde na minha árvore. **Note que o UI test NÃO está no scheme `Traco`**: ele vive no
scheme `TracoUITests` (`project.yml:163`) e **não entra nos 1024**. Isso é herdado, não do
candidato, mas quem ler "1024 verdes" precisa saber que a prova de tela roda à parte.

**Release compila** (`** BUILD SUCCEEDED **`, mesmo 1 warning) — os `#if DEBUG` novos não
quebram o binário do dono. E a porta de trás não vai junto:

```
strings Release/Traco.app/Traco        | grep -c TRACO_ESPERA_FALSA  → 0
strings Debug/Traco.app/Traco.debug.dylib | grep -c TRACO_ESPERA_FALSA → 1
```

**Vigia que enxerga:** acusa no Debug, cala no Release.

### 2.5 A tela — eu vi, não li a legenda

As duas capturas do candidato são fiéis, e eu as **reproduzi** no meu aparelho:

- meu quadro `t20`: **"a sábia pensa há 4 s…"** + **"Parar de esperar"**;
- meu quadro `t22`, depois do toque: **"quanto ainda me falta no pretérito?"**,
  *"a pergunta foi interrompida."*, **"Repetir pergunta"** em âmbar.

**Pensando, tempo e cancelar estão na tela, e cancelar não perde a pergunta.** Isto é real
e é o ganho principal da volta.

---

## 3. Achados — o que reprova

### A1 · ALTO · `revisando` fica preso em `true` para sempre — a espera vira eterna

`OficinaTrabalho.swift:264` afirma: *"em QUALQUER das três rotas de rede desta oficina —
elas se excluem por guarda, então é um relógio só"*. **Elas não se excluem.**

| rota | guarda | o que ela NÃO olha |
|---|---|---|
| `revisarComIA` (`:299`) | `guard !revisando` | `conferindoTentativa`, `adaptando` |
| `conferirTentativa` (`:345`) | `guard !conferindoTentativa` | `revisando` |
| `adaptar` (`:385`) | `!conferindoTentativa, !adaptando` | `revisando` |

E as duas superfícies estão **na mesma rolagem**: `documento(_:)` monta `praticar(o)` e
`artefato(versao:)` no mesmo `VStack` (`TrabalhoView.swift:178`+), então "Conferir com IA"
e "Conferir minha tentativa" são dois toques do mesmo scroll, no modo combinado
("O que você quer produzir e praticar?").

Com as duas em voo, a `geracao` — que é **uma só por oficina** — invalida o `defer` da
primeira: `defer { if geracao == minha { revisando = false } … }` nunca roda, e
**`revisando` nunca mais volta a `false`**. Antes desta volta o `defer` era incondicional e
sempre limpava. **É regressão introduzida pelo conserto.**

Sonda plantada e rodada por mim (removida depois; não está no commit):

```
✘ Test sondaRevisorDuasRotasPrendemAFlagDaPrimeira() recorded an issue at
  PraticaTrabalhoTests.swift:1166:9:
  Expectation failed: !((o → Traco.OficinaTrabalho).revisando → true → true)
```

**A consequência é exatamente o defeito que a volta veio matar.** Com `revisando == true` e
`esperaDaIA == nil`, os três sítios que escrevem `desde: o.esperaDaIA ?? .now`
(`TrabalhoView.swift:699`, `:705`, `:972`) reavaliam `.now` a cada redesenho: o relógio
**nunca chega aos 4 s**, o número nunca aparece, e a tela volta a ser um **laço mudo com
outra roupa** — desta vez sem nem girar, e sem nunca sair. O `?? .now` é o que transforma
um estado inconsistente numa mentira silenciosa em vez de um vermelho.

**A irmã que não acusa:** com UMA rota só, o mecanismo funciona — o próprio
`pararDeEsperarNaoDeixaAChamadaVelhaApagarAEsperaDaNova()` do autor passa, e passou na
minha corrida.

### A2 · ALTO · "Parar de esperar" não para a outra rota, e a IA grava mesmo assim

`chamada` (`:267`) é **um slot só** para as três rotas: cada `abrir` sobrescreve o anterior.
`pararDeEsperarAIA()` (`:284`) apaga as três flags e cancela **apenas a última**. A
chamada que ficou órfã sobrevive ao toque, passa pelo seu `!Task.isCancelled` (ela nunca
foi cancelada) e **escreve no documento do autor**:

```
✘ Test sondaRevisorPararDeEsperarNaoParaAOutraRota() recorded an issue at
  PraticaTrabalhoTests.swift:1196:9: Expectation failed:
  (daIA → [Conferencia(… executor: "Fake · revisão assistida" …)]).isEmpty → false
```

O autor tocou "Parar de esperar", a tela voltou ao botão, e a leitura da IA **apareceu no
trabalho dele assim mesmo**. Uma saída que não sai é pior que nenhuma: ela promete controle
e não entrega. Isto é dívida de **Estado honesto**, não só de correção.

**Forma do conserto (não é minha alçada implementar):** o modelo certo já está no próprio
candidato — `ConversaNotas` usa **um token por chamada** (`tentativa: UUID`, comparado no
fim). `OficinaTrabalho` usa um **contador global à oficina**, e é daí que vêm A1 e A2. Para
a volta `responder`, **o guia é `ConversaNotas`, não `OficinaTrabalho`** — e o relato do
autor oferece os dois como modelo. Um deles é o que quebrou.

### A3 · MÉDIO · Jornada real: oito superfícies mudaram, **uma** foi fotografada

O diff toca oito sítios (`grep -c "Espera(frase:"`: Notas 1, Página 1, Lente 2, Trabalho 4).
As capturas entregues são **duas, ambas da mesma tela** (Notas). Cartão da Página, Lente ·
instigar, Lente · contrapor e as **quatro** rotas do Trabalho não foram vistas em tela
nenhuma — e é justamente no Trabalho que A1 e A2 moram. O G2 da ESTEIRA pede captura de
**cada tela alterada**; 1 de 8 não sustenta a dimensão.

### A4 · MÉDIO · Toque morto na Lente

`instigar()` e `contrapor()` ganharam `guard instigando == nil, contrapondo == nil else
{ return }` (`LenteView.swift:316` e `:344`), mas **só o botão da rota em voo some** —
o outro continua na tela, com a mesma aparência de ativo. Durante "a sábia procura o que
falta", tocar **"Contrapor"** não faz nada e não diz nada. Antes do diff o toque abria uma
segunda chamada; agora ele morre em silêncio. A folha oferece uma ação que não acontece.

E o comentário de `LenteView.swift:19` — *"A folha é modal: fechá-la também solta o `Task`
com a view"* — **é falso**: soltar a referência de um `Task` não o cancela (só `.task {}`
cancela com o ciclo de vida). Fechar a folha deixa a chamada correndo até o teto. Não é
regressão (já era assim), mas o comentário ensina o errado a quem vier depois.

### A5 · MÉDIO · A hierarquia que o relato diz ter corrigido continua invertida

O relato (§5) conta que a saída pesava mais que a espera e que passou a `meta`/`tintaSuave`.
Medi os pixels da captura do próprio candidato:

| elemento | token | RGB medido | contraste vs `#FCFCFC` |
|---|---|---|---|
| "a sábia pensa há 5 s…" (o ESTADO) | `Tema.tintaFraca` `#68686C` | (104,104,108) | 5,4:1 |
| "Parar de esperar" (a SAÍDA) | `Tema.tintaSuave` `#5F5F64` | (95,95,100) | 6,2:1 |
| "Fechar" | `#5F5F64` | (95,95,100) | 6,2:1 |

Mesma fonte (`Tema.meta`), e **a saída continua sendo a tinta mais escura do cartão**, junto
com "Fechar". O que a correção resolveu foi o **tamanho** (`barra` semibold → `subheadline`);
o **peso de cor** ainda puxa o olho para a saída antes do estado — o `von-restorff`
invertido que o relato declara fechado. Vê-se a olho nu no meu quadro `t20`. Contraste
passa AA nos dois casos; o defeito é de hierarquia, não de legibilidade.

### A6 · MÉDIO · Volta visual sem as seis fases do `design-router`

`grep -c "design-router" ferramentas/orca/tempo-e-espera.md` → **0**. A volta cria um
componente, muda layout em oito superfícies, troca tokens de tipografia e cor e reescreve
copy ("A IA está preparando…" → "a IA prepara"). A ESTEIRA é literal: *"Volta visual sem as
fases do `design-router` citadas no relato é recusada no G4, mesmo que o código esteja
certo."* O relato usa o vocabulário (`von-restorff`) sem passar pelo portão.

### A7 · BAIXO · A medida da montagem não visitou a rota que o texto nomeia

`EsperaDoAutorTests` mede `Caderno.prosa` + `RespostaNotas.montar`, que é a montagem da rota
**das Notas** (`Sabia.responderNasNotas`, `Sabia.swift:148`) — e para essa rota a medida é
válida. Mas o comentário do teste e a §2.2 do relato atribuem os 6,3 ms a
**`Sessao.perguntarASabia`**, que **não chama `RespostaNotas.montar`**: ela usa
`contextoDoCaderno` (`Sessao.swift:~600`) — um `fetch` de TODAS as notas, `Indice.vizinhas`
duas vezes, e um `await Sabia.ecos(...)`, que é **outra operação de IA** (hoje inerte porque
`ecos` está `indisponivelPorQualidade`, mas viva no contrato). O orçamento "toque →
publicação = 300,006 s" só vale para a rota das Notas; na rota da Página a montagem embute
uma segunda chamada com o seu próprio teto. É o padrão que a ESTEIRA nomeia — a medida certa
com a etiqueta da rota errada.

### A8 · BAIXO · A tela fotografada não é alcançável na produção de hoje, e o relato não diz

`TRACO_ESPERA_FALSA` não desliga só a rede: `Politica.provedor` devolve `.grok`
**incondicionalmente** (`Politica.swift:159`), por cima de `soBordo` e de
`indisponivelPorQualidade`; `Politica.aviso` chama `provedor`, então o aviso some. Hoje
`responderNasNotas` está **indisponível por qualidade**, e perguntar nas Notas devolve a
frase da política, não a espera. A captura prova o **componente**, não um estado que o app
alcança agora — e o relato só declara "a espera longa veio de transporte controlado".

**Privacidade: sem vazamento.** Conferi por leitura que `Grok.responder` retorna **antes** de
montar o pedido (`Grok.swift:232`), e por `strings` que o símbolo não existe em Release.
Nada sai do aparelho. O que fica é uma porta que desliga a política inteira num binário
DEBUG — e é o binário DEBUG que se instala nos aparelhos de conta.

### A9 · BAIXO · Contagem e placeholder

- **"sete superfícies"** aparece na ADR, no relato e no comentário de `LinhaDeEstado.swift:57`,
  e a lista da própria ADR tem **oito** (1 Página + 1 Notas + 2 Lente + 4 Trabalho);
  `grep -c "Espera(frase:"` confirma **8** sítios de produção. O certo é "seis das oito
  tinham `ProgressView`; sete das oito eram caladas".
- `GrokContratoTests.swift:45` diz **"decisão da ADR 09?"** — placeholder não substituído. A
  letra é `2026-09-10a`.
- `Grok.esperaObservada = 241` é rastreável até `RUMO.md:790` (linha conferida, texto bate),
  mas **não há dado bruto** no repositório: nenhum `prova/*.jsonl` registra latência > 200 s.
  O fato ainda repousa em prosa — melhor que antes, porque agora tem guarda, mas vale dizer.

---

## 4. As duas dívidas que o autor declarou — meu julgamento

1. **`Sessao.perguntarASabia` sem conferir identidade depois dos `await`.** Confirmo por
   leitura: ela guarda `perguntaTask` e checa `case .sabiaPensando? = self.cartao`, que é
   estado, não identidade — cancelar e perguntar de novo pode publicar a resposta velha na
   pergunta nova. **É da volta `responder`, e ele de fato não a piorou.** Aceito como dívida.
2. **Duas saídas empilhadas no cartão das Notas** (*Fechar* × *Parar de esperar*).
   **Pode esperar** — mexer no *Fechar* é contrato da ADR 05e e pede volta própria. Mas
   registro o que a captura mostra: as duas têm **a mesma tinta e o mesmo tamanho**
   (`#5F5F64`, `Tema.meta`) e sentidos opostos (descartar a conversa × guardar a pergunta).
   Quando a volta abrir, é a hierarquia entre elas que resolve, não o rótulo.

---

## 5. Scorecard — 15 dimensões

| dimensão | nota | evidência |
|---|---|---|
| Visão | **9** | linha do ciclo no relato; `EVOLUCAO.md` nomeia a lacuna que reabriu ("a lacuna de DISPONIBILIDADE que a 08r fechou tinha REABERTO, e fechou de novo com a distinção escrita") |
| Contrato | **7** | ADR na forma exigida (margem × piso, "ninguém mediu 300"), SPEC e EVOLUCAO coerentes; **mas** `OficinaTrabalho.swift:264` afirma no código uma exclusão por guarda que as linhas `:299/:345/:385` desmentem — e é essa afirmação que justifica o relógio único (A1). Mais "sete superfícies" para oito e `ADR 09?` em `GrokContratoTests.swift:45` (A9) |
| Correção | **6** | 1024 verdes reproduzidos e guarda do teto provada por mutação nos dois sentidos; **mas duas sondas minhas ficaram vermelhas** em defeito introduzido por este diff (A1, A2), com irmã que não acusa em ambas |
| Jornada real | **6** | 1 de 8 superfícies alteradas tem captura (A3); as duas entregues eu conferi e reproduzi no meu aparelho |
| Design | **7** | componente coeso, saída discreta, alvo 44 pt medido; **mas** zero citações do `design-router` (A6) e a hierarquia declarada corrigida continua invertida por pixel (A5) |
| Simplicidade | **9** | um componente para oito superfícies feito do que já existia; seis `ProgressView` mudos removidos; nenhuma abstração nova; `curva-zero` não era exigível (não é onboarding/formulário/primeiro uso) |
| Movimento | **9** | `TimelineView` de 1 Hz, sem animação e sem timer: Movimento Reduzido não tem o que reduzir; meus 22 quadros mostram o número andando (4 s → 5 s) |
| Componentes | **9** | `Espera` num lugar só (`Traco/Componentes/LinhaDeEstado.swift`), `#Preview` com três estados, nome em pt, sem duplicata; o identificador voltou para dentro, como o relato conta |
| Acessibilidade | **9** | alvo ≥ 44 pt afirmado no UI test e verde na minha corrida; contraste medido por mim, 5,4:1 e 6,2:1 (AA); identificadores na árvore. VoiceOver falado fica **declarado como limite** e não desconta. Dívida menor: `"parar-de-esperar"` é identificador fixo e pode duplicar se duas esperas coexistirem — que é justamente o cenário de A1 |
| Performance | **9** | a mudança não toca lista, editor nem parser; o custo é uma invalidação de uma linha por segundo. **Sem Instruments — limite declarado**, não nota descontada |
| Privacidade e autoria | **9** | `TRACO_ESPERA_FALSA`: 0 ocorrências no bundle Release, 1 no dylib de Debug; `Grok.responder` retorna antes de montar o pedido, então nada sai. Ressalva nomeada em A8: a porta desliga a política inteira no binário DEBUG |
| Estado honesto | **6** | o ganho é real (pensando + tempo + cancelar, e cancelar devolve a pergunta); **mas** "Parar de esperar" não para a outra rota e a IA grava assim mesmo (A2), o `?? .now` mascara o estado inconsistente em espera eterna sem número (A1), e há toque morto na Lente (A4) |
| Complexidade | **9** | +286/−94 em produção, 10 arquivos, **nenhum arquivo de produção novo**; simplificação líquida real (seis `ProgressView` e dois `Bool` de estado paralelo saíram) |
| Fora do app | **n/a** | a volta não toca widget, Ilha, tela bloqueada nem StandBy |
| Relato | **7** | claro, datado, honesto sobre o que é decisão e o que é medida; **mas** afirma corrigida uma hierarquia que a captura desmente (A5), atribui a medida da montagem a uma rota que não a usa (A7), conta sete onde há oito (A9), e não diz que a tela fotografada não é alcançável hoje (A8) |

**Abaixo de 9: Correção (6), Jornada real (6), Estado honesto (6), Contrato (7), Design (7),
Relato (7). Nada mescla.**

---

## 6. O que precisa acontecer antes do re-G3

1. **A1 e A2 primeiro** — são defeitos que este diff criou, e bug tem prioridade. A forma
   está no próprio candidato: token por chamada, como em `ConversaNotas`, e o cancelamento
   alcançando a chamada certa. Enquanto isso não fechar, **`OficinaTrabalho` não serve de
   modelo para a volta `responder`** — `ConversaNotas` serve.
2. **Matar o `?? .now`** dos três sítios: se a flag está de pé sem relógio, isso é vermelho,
   não `.now`.
3. **A3** — capturas do Trabalho (as quatro rotas) e da Lente (as duas), em `large`.
4. **A4, A5, A6, A9** — o toque morto, a hierarquia entre estado e saída, as seis fases do
   `design-router` no relato, e as correções de contagem/placeholder.
5. **A7 e A8** — corrigir a etiqueta da rota na medida da montagem e dizer no relato que a
   tela fotografada depende de a política reabrir `responderNasNotas`.

**O teto está certo e a ADR está bem escrita.** Se a volta precisar entrar em partes, a
parte do teto (`Grok.teto`, `Grok.esperaObservada`, `GrokContratoTests`,
`oTetoDoPedidoGanhaDoTetoDaSessao`) não tem achado nenhum contra ela — o que reprova é a
espera com estado no Trabalho.

---

## 7. Estado honesto desta revisão

**Executado e observado:** build limpo, build Release, suíte integral com sondas minhas,
mutação do teto, UI test, 22 capturas próprias, medição de pixel, `strings` nos dois
binários. **Lido, não executado:** `Sessao.perguntarASabia` e o caminho de `ecos` — julguei
por leitura, e digo que foi por leitura. **Não fiz:** Instruments; captura da Lente e do
Trabalho (é entrega do autor, não do revisor); nenhuma chamada real de IA; nenhum toque nos
dois aparelhos de conta. **Não corrigi nada** — as duas sondas foram removidas e o
`git status` do candidato voltou ao que estava.
