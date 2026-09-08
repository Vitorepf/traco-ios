# G4 — juízo de design da V17: PASSA

Juiz de design (Fable 5.1), 08/09/2026, 16h40. Candidato `4bbc6c1` (V17 + V17-B) contra a base `7499e80`.
Simulador **iPhone 17 Pro (teste 4) `A1DF082C`**, ligado por mim e desligado ao fim. Nenhum toque no
`C2416CBC`, no `B91C8DEF`, no `6033B043` nem no `64F7B8B4`. Nenhum mouse. Toda sessão de `orca emulator`
por `com-trava.sh`; toda medida por árvore de AX conferida contra `simctl io A1DF082C` no mesmo instante.
Não corrigi nem comitei nada: as 11 capturas `g4-v17-*.png` ficam soltas em `ferramentas/orca/` para o
orquestrador decidir. `revisao-v17-artefato.md` aparece modificado na árvore — não fui eu; é do revisor.

O que pesou no veredito, em uma linha cada:

- **O coração passa.** "Nesta versão" diz o que mudou (frase do modelo), de onde veio (linha do app com a
  data da tentativa) e o que NÃO afirma ("Reescrever o exercício não é dizer que você aprendeu"). É uma
  seção, no alto do exercício, antes da tarefa. Não vira relatório: três parágrafos, sem histórico.
- **A contestação é alcançável por quem não leu o código.** Exercitei ao vivo: expandir "Feedback: 1
  critério a rever" → escrever o motivo → "Não foi isso que eu errei". Três toques, e a leitura fica
  inteira no registro com a frase em âmbar dizendo que não orienta mais os ajustes.
- **Três cápsulas, via do pedido escrito inteira, curva-zero de 3 toques até o ato do laço.**
- **A recusa honesta reproduzida** no meu aparelho: o parágrafo em `Tema.aviso` no lugar do exercício
  que não mudou, com o exercício vigente e o campo da tentativa preservados.
- **Portão limpo:** zero curva, duração ou cor literal nas linhas acrescentadas; nenhuma tela nova; ADR 08j.
- **AX5 sem clipe** nas duas seções novas e nas três cápsulas; a ordem de foco vai da tentativa causal ao
  campo da próxima tentativa.

Achados que ficam (nenhum bloqueia; P3, um conserto de uma linha cada):

1. `TrabalhoView.swift:454` e `:537` — "A tentativa que gerou esta versão" e "Nesta versão" usam
   `.rotulo(Tema.tintaSuave)` **sem `.accessibilityAddTraits(.isHeader)`**, ao contrário de `secao(_:)`
   (`:1119`). O rotor de cabeçalhos do VoiceOver pula as duas seções novas. Os rótulos internos do cartão
   ("O que fazer", "Exemplo resolvido…") já vinham sem o traço, então "Nesta versão" segue a convenção do
   cartão; mas "A tentativa que gerou esta versão" é irmã de `secao("Praticar")` e devia ser cabeçalho.
   **Conserto:** `.accessibilityAddTraits(.isHeader)` nas duas linhas.
2. `TrabalhoView.swift:735` — o `.accessibilityIdentifier("pratica-feedback")` no `DisclosureGroup`
   **sombreia** os ids dos filhos: na árvore, o campo da contestação, "Não foi isso que eu errei" e a linha
   "Você contestou…" aparecem todos como `pratica-feedback`; `pratica-contestar-leitura` e
   `pratica-leitura-contestada` não existem para o maestro. Não afeta a pessoa; afeta o instrumento e o
   fluxo que um dia guardar esta rota. **Conserto:** mover o id do grupo para o rótulo do disclosure.
3. `PraticaTrabalho.origemDoAjuste` — "A pedido seu." seguido do texto do autor **sem aspas**
   (`g4-v17-a-pedido-seu.png`: "A pedido seu. Quero um exercício mais curto…"). A linha da contestação já
   cita entre “ ”; a do pedido devia fazer o mesmo, para o "eu" da frase ser reconhecido como o do autor.
   **Conserto:** `"A pedido seu. “\(aj.motivo)”"` (ou equivalente no `anuncio`).
4. `TrabalhoView.swift:534` — `VStack(spacing: 6)` literal em `nestaVersao`. Segue a convenção de
   `campo(_:)` (`:1139`), e o `Tema` não tem token entre 0 e `entreItens` (12); portanto não é dívida nova
   desta volta, mas é o quinto `spacing: 6` do arquivo. Fica registrado, não conta contra.

## Os dois limites declarados — aceito os dois

- **O bloqueio da edição durante `adaptando` não se fotografa sem conta.** Aceito. Li o código: o guarda
  em `preparacaoEmCurso` (`TrabalhoView.swift:1309-1314`) anuncia por VoiceOver e rola ao progresso, como
  as outras rotas travadas; e o invariante mora em `guardarVersaoHumana(_:base:)`, não na tela. O teste
  `editarDuranteAAdaptacaoNaoTrocaODocumentoDebaixoDaPessoa` cobre o entrelaçamento. Não desconto.
- **A jornada com provedor real é da frente Q.** Aceito. O que fica por ver com IA de verdade, e que eu
  combinaria na corrida da Q:
  1. a `mudanca` que o modelo escreve **cumpre** o exercício (a frase não pode ser cabeçalho convincente
     sobre exercício repetido — contrato ponto 2); ler os dois enunciados lado a lado;
  2. o `ProgressView` "conferindo e, se a leitura sustentar, adaptando…" com duração real, e o bloqueio de
     "Editar esta versão" durante esse tempo (a captura que esta volta não pôde tirar);
  3. a chegada da N+1 pela animação de `artefatos.count` com o anúncio no alto — a pessoa vê o documento
     trocar e sabe por quê;
  4. leitura sem divergência → "A leitura não apontou divergência…" (só vi o ramo "não concluída");
  5. contestar **e depois** "Conferir e adaptar" numa tentativa nova: o núcleo do ajuste seguinte não repete
     a interpretação contestada (o teste prova; a tela real ainda não);
  6. o caso `ajusteIndisponivel` por orçamento real, não plantado.

## Instrumento — o que foi limite, e o que não foi

- **Documento plantado, não gerado.** Usei os JSONs que o implementador deixou em `/tmp` (saídos da API
  real por teste descartável): `v17-b-depois.json` (N+1 por necessidade percebida), `v17-d-indisponivel.json`.
  Para "A pedido seu." editei o `ajuste` do primeiro para `pedidoDoAutor` com o motivo escrito e a
  `mudanca` trocada; o enunciado continuou o da conjugação — por isso em `g4-v17-a-pedido-seu.png` a
  frase "reduzi para uma frase só" não bate com o exercício abaixo. É o meu plantio, não o app; a captura
  do implementador (`v17b-b-a-pedido-seu.png`) tem o documento coerente e confere com a minha na forma.
- **Contestação e tentativa nova foram ao vivo**, não plantadas: digitei o motivo, toquei o botão, a
  frase em âmbar apareceu; digitei a tentativa, guardei, as três cápsulas apareceram; toquei "Conferir e
  adaptar" sem conta e a folha disse "A leitura não foi concluída, então não reescrevi o exercício".
- **Tamanho de letra:** o aparelho estava em **AX5 quando cheguei**. Baixei para `medium` para as
  capturas normais, subi para AX5 para as de acessibilidade e **devolvi para AX5** ao fim, conferido por
  `simctl ui`. Modo escuro é n/a: `RaizView.swift:142` força `.light`.
- **`orca emulator attach` é por worktree** e o revisor divide este worktree comigo: o helper caiu seis
  vezes no meio de sessões, e cada `attach` manda o app para a casa. O dirigidor (`d.py`/`jornada.py`
  no scratchpad) passou a reatar, relançar e reconferir o estado antes de cada toque. Um defeito meu
  (toque só no ramo "fora da tela") custou três passes de AX5 — está corrigido e as capturas são do
  passe bom (16:27–16:28).
- **Trava disputada:** o `xcodebuild test` da frente Q segurou `com-trava` por 7 min (15:37–15:44) e a
  V12-E dispara `tap` por trava a cada segundo; passei a segurar a trava por sessão curta em vez de por
  comando.
- **Ganho do arrasto** medido nesta folha: 12 a 30 vezes; laço realimentado pela árvore convergiu em 2 a 5
  passos.

## Mover

Nenhuma animação nova no diff — conferido linha a linha (`portao.py` no scratchpad, as duas regex de
`PortaoDoMovimentoTests` de `main` mais uma de cor/tipo soltos, aplicadas só às linhas `+`): **zero
ocorrência**. O que se move continua sendo o da volta 18: a chegada da versão por `artefatos.count` e a
gaveta da contestação por `Tema.gaveta`. O `ProgressView` do ato novo tem texto próprio
("conferindo e, se a leitura sustentar, adaptando…") — certo, porque promete duas coisas. Sem vídeo a
julgar; sem conta não há transição de N para N+1 na tela. Fica para a corrida da Q (item 3 acima).

## Julgar

### 1. O autor entende o que aconteceu com o exercício dele?

`g4-v17-nesta-versao.png` (medium) e `g4-v17-nesta-versao-ax5.png`. A seção tem exatamente três
frases de três donos: a do modelo ("O primeiro bloco agora treina a conjugação de vivir antes das
frases… Os três blocos de cinco minutos… continuam os mesmos") diz o que mudou E o que ficou; a do app
("A partir da leitura da sua tentativa de 8 de set. de 2026, 14:30. A leitura da sua tentativa apontou
divergência em 1 critério: Usa o verbo no presente.") diz de onde veio e por quê; a terceira nega a
promessa que a volta proíbe. Não é relatório: não lista versões, não repete o feedback, não tem número.
Está no alto do cartão, entre "Preparado por Grok · exercício adaptado" e "Situação" — quem abre lê a
mudança antes de "O que fazer". A frase do app repete "da sua tentativa" duas vezes seguidas
("…leitura da sua tentativa de 8 de set… A leitura da sua tentativa apontou…") — redundância de copy,
não de sentido; não desconto.

Nada na folha declara aprendizagem: procurei "aprend", "domin", "nível", "pontu" na árvore de AX das
três leituras — só aparecem nas negações ("não é dizer que você aprendeu", "não prova aprendizagem").

### 2. A contestação é alcançável de verdade?

Sim, e é a seção nova que a salva. Na árvore de AX com o documento aberto, a ordem é:
`pratica-mudanca` → `pratica-motivo-do-ajuste` → enunciado → exemplo → **"A TENTATIVA QUE GEROU ESTA
VERSÃO"** → a tentativa (em leitura) → "Feedback: 1 critério a rever · 1 atendido no escopo lido" (botão
com seta) → **"Minha tentativa"** (campo vazio). Sem a seção, a tentativa da N não estaria em lugar nenhum
da folha (a lista "Tentativas" filtra pela N+1 — conferi: depois de guardar uma tentativa nova, a lista
mostra só a de 16:02).

A rota, medida por toques (`g4-v17-rota-contestar.png`, `g4-v17-leitura-contestada.png`):

| passo | toque | o que a pessoa vê |
|---|---|---|
| 1 | "Feedback: 1 critério a rever ›" | os dois critérios, o trecho citado, "Lido por Grok…", o campo "Por que esta leitura está errada? (para contestá-la)" e a cápsula "Não foi isso que eu errei" |
| 2 | o campo | teclado |
| 3 | "Não foi isso que eu errei" | a leitura continua inteira; abaixo, em âmbar: "Você contestou esta leitura em 8 de set. de 2026, 16:00 — “Não errei por conjugação: eu não sabia a palavra vivo.” Ela continua no registro e não orienta mais os ajustes." |

Três toques mais o motivo. Quem não leu o código acha porque a única coisa tocável no cartão da tentativa
causal é a linha "Feedback… ›", e a cápsula tem o nome do gesto ("Não foi isso que eu errei"), não do
mecanismo. O motivo ser obrigatório (a cápsula fica com hint "Escreva o motivo primeiro") é a coisa certa:
contestar sem dizer o quê seria apagar a leitura por outro nome. A leitura **não some** depois — conferido
na captura: os dois critérios e o "Lido por Grok" seguem acima da frase em âmbar.

### 3. As três cápsulas

`g4-v17-tres-capsulas.png` (ao vivo, tentativa guardada às 16:02): "Conferir minha tentativa" · "Conferir
e adaptar o exercício" · "Nova tentativa". A enlatada saiu. Os três atos são distintos (ler; ler e, se
sustentar, reescrever; recomeçar) e o do laço tem o nome mais longo — certo, porque é o que promete mais.

Curva-zero, medida do documento aberto até o ato do laço:

| jornada | antes da V17 | V17-B |
|---|---|---|
| tentativa → exercício reescrito pelo que a leitura achou | Guardar (1) → Conferir (2) → esperar → "Adaptar o próximo exercício" (3) → esperar; pedido enlatado que a pessoa não escreveu | campo (1) → Guardar (2) → "Conferir e adaptar" (3) → uma espera; causa escrita pelo app com a leitura |
| pedido explícito do autor | a mesma cápsula enlatada, sem o texto dele | "O que você quer praticar?" (campo, no topo da seção) → "Preparar exercício com IA": 2 toques + o texto DELE como causa (`g4-v17-a-pedido-seu.png`) |
| ler por que o exercício mudou | não existia | 0 toques: está no alto do exercício |
| contestar a leitura que causou a versão | inalcançável depois do ajuste (tentativa sumia) | 3 toques |

O poder avançado continua encontrável: "Conferir minha tentativa" (uma operação só) fica em primeiro, e o
pedido escrito continua no campo que sempre existiu. A via do `pedidoDoAutor` é inteira — confirmado no
código (`causaDoPedidoEscrito` nas duas rotas do campo) e na captura.

### 4. A recusa honesta

`g4-v17-ajuste-indisponivel.png`, reproduzida no meu aparelho com `v17-d-indisponivel.json`: o parágrafo
em `Tema.aviso` ("O ajuste ficou indisponível: a sua tentativa, a leitura dela e as restrições ainda
aplicáveis não cabem inteiras na janela do provedor. Não mandei um pedaço delas. O exercício atual e a sua
tentativa continuam guardados.") fica entre o exercício vigente (critérios ainda visíveis acima) e o campo
"Minha tentativa" (vazio, abaixo). É o lugar certo: onde o exercício que não mudou está. E o outro ramo
honesto, que a volta não fotografou, eu vi ao vivo (`g4-v17-leitura-nao-concluida.png`): tocando
"Conferir e adaptar" sem conta, a folha diz "A leitura não foi concluída, então não reescrevi o
exercício. Sua tentativa continua guardada." logo abaixo das cápsulas, e o feedback vira "Feedback
indisponível: …precisam da conta Grok". Nada some, nada finge.

### 5. Acessibilidade

- **AX5** (`g4-v17-nesta-versao-ax5.png`, `g4-v17-tentativa-da-causa-ax5.png`,
  `g4-v17-tres-capsulas-ax5.png`): as três quebram por linha dentro da largura, sem clipe horizontal e sem
  sangrar do cartão; a cápsula "Conferir minha tentativa" vira um blob de três linhas — é o `Pilula
  .filtro` fazendo o que faz em toda a casa.
- **Ordem de foco** (árvore de AX): tentativa causal → apoio usado → feedback (disclosure) → campo "Minha
  tentativa" → "Que apoio você usou?" → "Guardar minha tentativa". Vai da causa à próxima tentativa, como
  o brief pede.
- **Rótulos:** todos os controles novos têm nome do ato ("Conferir e adaptar o exercício", "Não foi isso
  que eu errei"); o campo da contestação tem rótulo de propósito ("…para contestá-la"); a cápsula travada
  tem hint. O bloqueio da edição anuncia por VoiceOver antes de rolar.
- **Falta** o traço de cabeçalho nas duas seções novas (achado 1) e os ids sombreados (achado 2).

## Portão

| item | resultado |
|---|---|
| tokens de `Tema`, nada solto | nas linhas `+` de `TrabalhoView`: `Tema.meta` ×6, `Tema.tintaSuave` ×5, `Tema.aviso` ×2; nenhuma `Color(`, `.font(.` ou `.padding(n)` literal; um `spacing: 6` (achado 4, convenção do arquivo) |
| movimento vindo de `Tema` | zero curva/duração literal nas linhas acrescentadas dos quatro arquivos de Trabalho (mesmas regex do `PortaoDoMovimentoTests` de `main`); `Tema.gaveta` e a animação de `artefatos.count` são as da volta 18 |
| nenhuma tela nova | confirmado: 4 arquivos de `Traco/Trabalho/`, nenhum arquivo de UI novo, nenhum `NavigationLink`/`sheet` novo |
| ADR desta volta | `08j` (e `08k` da V17-B), em `SPEC.md:5694` e `:5776`; ambas com o limite de instrumento escrito |
| `Tema.swift` / `Traco/Componentes` | não tocados |
| capturas dos relatos conferidas no conteúdo | as sete da V17 e as três da V17-B batem com o que eu vi no meu aparelho, forma e texto |

## Pares antes/depois, por arquivo

| arquivo | antes (`7499e80`) | depois (`4bbc6c1`) | na tela |
|---|---|---|---|
| `Traco/Trabalho/TrabalhoView.swift` | a lista "Tentativas" filtrada pela versão vigente; "Adaptar o próximo exercício" como quarta cápsula com pedido enlatado; `exercicio(_:produtor:)` sem anúncio; feedback sem contestação; "Editar esta versão" abria durante a adaptação | `nestaVersao` no alto do exercício; `tentativaQueGerou` entre o exercício e o campo; `contestacao` dentro do feedback; `causaDoPedidoEscrito` nas duas rotas do campo; guarda `preparacaoEmCurso` conta `adaptando`; `guardarVersao(base:)` | `g4-v17-nesta-versao.png`, `g4-v17-tentativa-da-causa.png`, `g4-v17-rota-contestar.png`, `g4-v17-leitura-contestada.png`, `g4-v17-tres-capsulas.png`, `g4-v17-a-pedido-seu.png` |
| `Traco/Trabalho/PraticaTrabalho.swift` | preparação sem `mudanca`; histórico no trecho descartável; sem texto de recusa do ajuste | `nucleoDoAjuste` na cabeça do contexto; `mudanca` no esquema (`additionalProperties:false`) com o mesmo teto e prova de vazamento; `ajusteIndisponivel`, `leituraSemDivergencia`, `leituraNaoConcluida`, `origemDoAjuste`, `anuncio`; `-ensaio-oferta-da-pratica` só em Debug | `g4-v17-ajuste-indisponivel.png`, `g4-v17-leitura-nao-concluida.png` |
| `Traco/Trabalho/Trabalho.swift` | `pedidoDe` inferia a causa | `Pedido.ajuste?`, `Artefato.pedidoID?`, `validarAjuste` (leitura concluída, critério divergente, `conferenciaID` único), `contestarLeitura`, `guardarVersaoHumana(_:base:)` | invisível por si; sustenta as capturas acima |
| `Traco/Trabalho/OficinaTrabalho.swift` | `conferirTentativa` só | `conferirEAdaptar`: lê, guarda a leitura, e só reescreve se sustentar; `adaptando`, `leituraSemAjuste` | `g4-v17-tres-capsulas.png`, `g4-v17-leitura-nao-concluida.png` |
| `TracoTests/AjusteDoExercicioTests.swift` | — | 18 testes (15 + 3) | — (não rodei a suíte: é o G3 quem roda; o revisor a rodou no `B91C8DEF`) |

## Capturas desta revisão (todas `xcrun simctl io A1DF082C-… screenshot`)

| arquivo | estado | tamanho |
|---|---|---|
| `g4-v17-nesta-versao.png` | o anúncio no alto do exercício | medium |
| `g4-v17-tentativa-da-causa.png` | a seção nova, tentativa em leitura, feedback fechado, campo da próxima em branco (teclado aberto pelo meu arrasto, não pelo app) | medium |
| `g4-v17-rota-contestar.png` | feedback expandido: critérios, trecho, campo e "Não foi isso que eu errei" | medium |
| `g4-v17-leitura-contestada.png` | ao vivo: a leitura inteira + a frase em âmbar com o motivo que eu digitei | medium |
| `g4-v17-tres-capsulas.png` | ao vivo: tentativa nova guardada às 16:02 com as três cápsulas | medium |
| `g4-v17-leitura-nao-concluida.png` | ao vivo: "Conferir e adaptar" sem conta → recusa dita, tentativa preservada | medium |
| `g4-v17-ajuste-indisponivel.png` | plantado (`v17-d`): a causa não coube | medium |
| `g4-v17-a-pedido-seu.png` | plantado (JSON editado por mim): "A pedido seu." + o texto do autor | medium |
| `g4-v17-nesta-versao-ax5.png` | o anúncio sem clipe | AX5 |
| `g4-v17-tentativa-da-causa-ax5.png` | o rótulo da seção em três linhas, sem clipe | AX5 |
| `g4-v17-tres-capsulas-ax5.png` | as três cápsulas quebrando dentro da largura | AX5 |

## Scorecard do juiz (dimensões de design; as demais são do G3)

| dimensão | nota | evidência |
|---|---|---|
| Design | 9 | uma seção, três frases de três donos, no lugar onde a leitura começa; lei de cor da folha respeitada (o ato novo em tinta, a recusa e a contestação em âmbar) |
| Simplicidade | 9 | 4 → 3 cápsulas depois de garantir a via; 3 toques até o ato do laço; 0 toques para ler o porquê; 3 para contestar |
| Movimento | n/a | nada novo; portão em zero nas linhas acrescentadas |
| Componentes | 9 | reuso puro (`Pilula .filtro`, `campo`, `.cartao`, `.rotulo`); um `spacing: 6` de convenção |
| Acessibilidade | 8 | AX5 sem clipe, ordem de foco certa, rótulos de ato; falta `isHeader` nas duas seções novas e os ids do disclosure sombreiam os filhos |
| Estado honesto | 9 | quatro ramos ditos na tela, cada um com o seu texto, e nenhum apaga tentativa ou exercício |
