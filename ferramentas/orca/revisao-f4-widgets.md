# Revisão G3 — F4, os widgets da tela de início (ADR 2026-09-05x)

Revisor: Claude Opus 5, sessão própria, 06/09/2026. Worktree `f4-widgets`,
commit `cfd04fc` sobre main `d1248ce`. **Não editei nem commitei nada.**

Simulador desta revisão: **iPhone 17 Pro (teste 3)**
`34CC3F94-FDB5-4575-A4F5-80271829A18B` — ligado por mim, usado por mim,
desligado por mim ao fim. Todo `xcodebuild` e todo `maestro` por
`ferramentas/orca/com-trava.sh`. Nunca toquei no iPhone 17 `1A46B6D3`.

---

## Veredito

**CORRIGIR ANTES.** Seis dimensões abaixo de 9. O motor da volta está certo e
provado — a linha do tempo agenda releitura de verdade, o orçamento é curto, a
privacidade está intacta —, mas **as três frases que a volta escreveu para a
casa não cabem na casa**: o estado honesto sai como `desatua…`, a marca
`PRÓXIMO` quebra com hífen no meio da palavra, e a única ação do vazio sai como
`Marcar um compro…`. É a dimensão que o dono abriu a volta para consertar, e
ela falha exatamente no lugar em que ele vai olhar.

Além disso, **um limite declarado é falso**: o pequeno do Próximo entra na casa
sem dificuldade nenhuma — eu o plantei em três minutos —, e as três capturas
rotuladas "escuro" não estão em modo escuro.

---

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | **10** | ciclo MULTIPLICAR, lacuna nomeada; `EVOLUCAO.md` diff atualiza a linha "Fora do app" com ADR05x |
| Contrato | **7** | ADR/SPEC/EVOLUCAO coerentes, mas **número de ADR colidido com a F3b** e dois efeitos não declarados (A2, A9) |
| Correção | **8** | build 0 avisos, **726 testes / 126 suítes verdes** (rodei), 11 testes novos da linha do tempo; o ramo novo de `Sessao.encadear` não tem teste |
| Jornada real | **6** | faltam `sem dados` e `sem permissão`; as capturas "escuro" **não são escuras** (A4) |
| Design | **6** | seis fases citadas e visíveis, mas o `Selo` trunca e hifeniza na tela (A1) |
| Simplicidade | **7** | curva-zero citada e o vazio oferece, mas a oferta trunca (A3) e o AX5 esconde "+N depois" (A8) |
| Movimento | **9** | nenhuma animação acrescentada, com razão declarada; `f4-um-toque-feito.mp4` (10,7 s, 57 KB) mostra marcar → desmarcar sem abrir o app — conferi os quadros |
| Componentes | **7** | 5 peças novas, nenhuma com `#Preview` próprio; **8 previews antes, 8 depois** — nenhum estado novo tem preview (A7) |
| Acessibilidade | **8** | AX5 conferido por mim nas quatro famílias, sem clipe; `BlocoProximo` sem rótulo de VoiceOver (A8) |
| Performance | **10** | linha do tempo é aritmética pura sobre ≤3 eventos; **10 entradas** por linha, medidas no chronod; sem lista, editor ou parser tocados |
| Privacidade e autoria | **10** | o widget lê **só** `SuperficieDisco.ler()`; encenei nota expressiva selada e a superfície publicada não tem destaque nenhum |
| Estado honesto | **5** | o "desatualizado" aparece na hora certa **e sozinho**, mas sai truncado (A1); e o sino é prometido com avisos NEGADOS (A2) |
| Complexidade | **9** | +929 / −145 em 29 arquivos; dois arquivos novos justificados; `RodapeAtualizado` apagado |
| Fora do app | **6** | orçamento e privacidade ok, mas **limite declarado é falso** (A5) e um toque não faz uma coisa no pequeno do Traço (A6) |
| Relato | **7** | completo e legível, mas carrega um limite falso e três capturas que não mostram o que dizem |

---

## O que confirmei (o que está certo, e como sei)

### 1. O BUG — a política agenda releitura de verdade. **Fechado.**

Reproduzi sozinho, e com prova mais forte do que a dele. O `chronod` do meu
simulador, nos dois kinds:

```
Task [124] [app.traco::app.traco.widget:TracoProximo]
  Follow-on reload from completion needed: [[timelineExhausted-2026-09-06T17:51:20-03:00-budgeted-1]]
Task [135] ... Scheduling reload with configuration: [timelineExhausted-2026-09-06T17:51:20-03:00-budgeted-1]
Task [135] ... Scheduled with cancellable token: [TaskID: BBC9C4CC]
```

às 14:51:20. **17:51:20 é exatamente `agora + 3 h`** — o teto de
`Relogio.releitura` —, e `budgeted-1` diz que o sistema aceitou contra o
orçamento. As mesmas três linhas existem para `TracoWidget`. Com `.never` não
existia agendamento nenhum. Evidência crua em
`ferramentas/orca/f4-rev-releitura.txt`.

**Ressalva ao relato dele.** A prova do refresh que ele entregou
(`f4-refresh-1/2/3`) mostra o app criando um compromisso e o widget mudando —
mas isso é o `reloadTimelines` do app, que **já funcionava antes da F4**. Não
prova a política. A linha do `chronod` prova; a captura, não. Ele apresentou as
duas no mesmo nível.

**Prova melhor, que eu fiz e ele não:** semeei três compromissos terminando às
15:01/15:02/15:03 (portanto `validoAte` = 15:03), publiquei, e depois **não
toquei em nada**. Às 15:04 os quatro widgets viraram sozinhos para o estado
desatualizado — sem app, sem recarga, só a linha do tempo andando.
`f4-rev-horizonte-antes.png` (14:59) → `f4-rev-horizonte-depois.png` (15:04).

### 2. ORÇAMENTO — curto, medido. **Fechado.**

`entry count: 10` nas quatro famílias, `date range 2026-09-06 17:51 → 2026-09-07
03:00` UTC (14:51 → meia-noite local). O teto aritmético é
`1 (agora) + 3 (fim) + 3 (soneca) + 1 (validoAte) + 1 (meia-noite) + 3 (início)
+ 3 (véspera) = 15`; medido: **10**.

Releituras por dia: a política é `clamp(última entrada, [agora+15min,
agora+3h])`. A última entrada é sempre a meia-noite de amanhã (inserida
incondicionalmente), que só está a menos de 15 min nos 15 minutos antes da
meia-noite. Logo **~8 releituras por dia, mais uma na virada** — nenhuma
rajada, nada perto do reload por minuto que a 05u matou.

### 3. PRIVACIDADE — intacta. **Fechado, com encenação.**

Três provas independentes:

- **Leitura.** `grep` no alvo do widget: `TracoWidget.swift` e `Relogio.swift`
  não contêm `UserDefaults`, `ModelContainer`, `SwiftData`, `Nota`, `Corpus`
  nem `FileManager`. A **única** entrada do widget é `SuperficieDisco.ler()`.
- **Contrato.** `Traco/App/Intents/Compartilhado/SuperficieFora.swift` **não
  está no diff**. Os campos de `Superficie.Destaque` e `Superficie.Proximo`
  são os mesmos da 05u. O vazio que "traz o Destaque" e a densidade de três
  **não abriram campo nenhum** — mostram mais do que já era publicado, nada novo.
- **Porta de entrada.** `Sessao.aplicarDestaque` continua exigindo
  `gesto == .destaque` (ou uma forma com campo `unica`) **e** `!nota.fechada`.
  Conferi o catálogo: só `destaque` e `dia` têm o campo `unica`;
  `expressiva` **não tem**. Nota selada e nota expressiva não têm rota.
- **Encenação.** Rodei `maestro/expressiva-trancar.yaml` (nota expressiva,
  trancada) e selei pelo fecho. A superfície publicada logo depois:

  ```json
  {"proximos": [], "geradoEm": ..., "validoAte": ..., "versao": 1, "revisao": 2}
  ```

  Sem chave `destaque`. Nenhuma palavra da nota. Na casa:
  `f4-rev-vazio-nota-selada.png` — "Nada em destaque hoje."

### 4. Sessao.encadear — não colide e não cascateia. **Fechado.**

- **Colisão com a F3b:** `git merge-tree Vitorepf/f4-widgets Vitorepf/f3b-ditado`
  → `Auto-merging Traco/App/Sessao.swift` **sem conflito**. A F4 mexe na linha
  ~740, a F3b na ~1290. Conflito só em `EVOLUCAO.md` e `SPEC.md` (as duas
  acrescentam ao mesmo fim de arquivo) — trabalho normal de G5.
- **Cascata:** `encadear` é um gesto do autor → um compromisso → uma
  publicação. Não há laço. E `SuperficieDisco.publicar` é idempotente: se
  destaque, proximos e validoAte não mudaram, ele **não regrava e não
  recarrega**. Barato.

### 5. Tema, build, suíte

- `Traco/Tema.swift` **não está no diff** — a declaração dele se sustenta. Os
  18 tokens que o widget usa existem todos.
- `xcodebuild build`: **`** BUILD SUCCEEDED **`, 0 `warning:`**.
- `xcodebuild test` no meu simulador: **`Test run with 726 tests in 126 suites
  passed`** — bate com o "726/126" do SPEC.

---

## Achados, por severidade

### ALTO — A1. O `Selo` trunca o estado honesto em 3 das 4 famílias, e a marca quebra com hífen

`ferramentas/orca/f4-rev-selo-truncado.png`

```
médio do Traço:     ● TRAÇO · desatua…      [Nova nota]  [Recordar]
pequeno do Traço:   ● TRAÇO · desat…
pequeno do Próximo: ● PRÓXI-
                      MO      · desat…
```

O item 2 da volta é "o estado honesto passa ao cabeçalho SÓ quando é verdade".
Quando é verdade, o autor lê **`desatua…`** — reticências no lugar da frase.
E no pequeno do Próximo a palavra `PRÓXIMO` **hifeniza no meio** para caber, o
que é a definição do defeito nº 4 do G0 ("nada ali dizia Traço").

Pior no médio do Traço: **o estado perde a disputa de espaço para dois atalhos**
que renderizam inteiros. É ao contrário — "Nova nota" e "Recordar" estão sempre
no app; a frase honesta só existe ali.

Causa: `TracoWidget.swift:79` `Selo` é um `HStack` em que `Text(rotulo)` não
tem `lineLimit` nem prioridade de layout e `Text("· \(estado)")` tem
`.lineLimit(1)` sem `minimumScaleFactor`. Em 155 pt de largura o SwiftUI
sacrifica os dois.

Como se prova consertado: com `validoAte` no passado, ler `desatualizado`
inteiro nas quatro famílias, com `PRÓXIMO` numa linha só.

### ALTO — A2. O widget promete sino com os avisos NEGADOS, e a rota nova da F4 é a pior delas

`ferramentas/orca/f4-rev-sino-sem-permissao.png`

Toquei **"Não Permitir"** no pedido de notificações às 15:20. Às 15:21, com a
permissão negada, os quatro widgets mostram `🔔 16:00` e `🔔 17:15`. A
superfície publicada confirma no dado: `Dentista aviso=16:00`,
`Revisão com o time aviso=17:15`.

Isto é o D4 da auditoria F1, ainda aberto. Nenhum ponto do caminho de
publicação consulta a autorização: `ProximoCompromisso.proximasFatias` calcula
`aviso` a partir de `avisoMinutos` e `editavel`, e o único mudo é o parâmetro
`mudo:`, que vale para **um** evento — o que acabou de ser gravado. Revogação
global não silencia nada.

A F4 não criou o defeito, mas **multiplicou por seis** as promessas falsas nesta
tela (antes era um sino no médio do Próximo; agora são até três por widget, em
dois widgets).

E há uma rota nova, criada por esta volta, que é pior:

```swift
// Sessao.swift:745 — ramo NOVO da F4
} else if case .eventos(var lista) = CalendarioDisco.carregar() {
    lista.append(evento)
    try? CalendarioDisco.gravar(lista)
    ProximoCompromisso.publicar(lista, cal: cal)   // <- publica com aviso
}
```

`EventoCalendario` nasce com `avisoMinutos = 0`, e o toast logo abaixo diz
**"marcado para … · com aviso"**. Mas este ramo **não chama `avisar(e)`** —
quem chama é `agenda.guardar`, que é o outro ramo. Ou seja: pelo encadeamento a
partir da página, o app diz "com aviso", o widget desenha o sino, e **nenhuma
notificação é agendada**. Antes da F4 a mentira só aparecia na volta seguinte
ao app; agora ela sobe para a casa na hora.

### ALTO — A3. A única ação do vazio sai cortada no pequeno

`ferramentas/orca/f4-rev-oferta-truncada.png`

```
● PRÓXIMO

Nada marcado.
📅 Marcar um compro…
```

O estado existe para oferecer **uma** ação, e a ação é o que trunca.
`Oferta` usa `.lineLimit(1).minimumScaleFactor(0.85)`; a 155 pt, 85% não chega.

### ALTO — A4. As três capturas "escuro" não estão em modo escuro

`f4-depois-inicio-escuro.png`, `f4-antes-inicio-escuro.png`,
`f4-antes-inicio-ax5-escuro.png` são o mesmo cenário claro das capturas
`-claro`, com um minuto de diferença. Papel de parede claro, barra de status
clara, rótulos dos apps claros, dock claro. Brilho médio idêntico à primeira
casa decimal nos três pares:

```
f4-depois-inicio-claro.png: 183.6  |  f4-depois-inicio-escuro.png: 183.6
f4-antes-inicio-claro.png:  185.9  |  f4-antes-inicio-escuro.png:  185.9
f4-antes-inicio-ax5.png:    184.4  |  f4-antes-inicio-ax5-escuro.png: 184.4
```

A decisão de fundo (D11: o widget é papel também no escuro) pode estar certa —
mas ela **não foi mostrada**. Fiz a captura de verdade
(`ferramentas/orca/f4-rev-casa-escuro.png`, `simctl ui appearance dark` mais
reinício do SpringBoard, que é o que faz a casa redesenhar): papel de parede
escuro, dock escuro, e os quatro widgets em papel branco. A decisão se sustenta,
e agora tem prova. Observação para o dono: quatro lajes brancas grandes numa
casa escura pesam bastante — é escolha declarada, não defeito, mas ele vai ver.

### ALTO — A5. O limite declarado do pequeno do Próximo é falso

Ele escreveu: *"Não consegui pôr o pequeno do Próximo na casa: a galeria de
widgets do iOS 26 mostra a página do app com as quatro famílias do primeiro
widget e a busca só casa nome de APP, não de widget."*

Não é assim. A busca casa o nome do app (isso está certo), mas a página do app é
um **carrossel de quatro páginas**, e as quatro são: pequeno do Traço, médio do
Traço, **pequeno do Próximo**, médio do Próximo. Deslizei o carrossel, toquei
"Adicionar Widget" e o pequeno do Próximo entrou na casa. Estão os quatro em
`ferramentas/orca/f4-rev-casa-claro.png`.

Um estado declarado improvável que é provável em três minutos derruba a
dimensão "Fora do app", que existe para exigir captura real. O StandBy e o
accessory na bloqueada, esses eu aceito: são o limite da F1 §7, e conferem.

### MÉDIO — A6. No pequeno do Traço, um toque faz outra coisa

O pequeno do Traço ganhou `.widgetURL("traco://nova")` (antes não tinha destino
nenhum — melhoria real). Mas quando não há Destaque, o miolo dele passa a
mostrar **um compromisso** (`BlocoProximo`), e o toque no widget inteiro abre
uma **página em branco**. O widget mostra "16:10 Dentista" e o toque cria uma
nota. Ver `f4-rev-sino-sem-permissao.png`, widget de baixo à esquerda.

Atenua: o rodapé diz "Nova nota". Não resolve: o conteúdo dominante da face é a
agenda.

### MÉDIO — A7. Cinco peças novas, nenhum preview novo

`Selo`, `AtalhoTraco`, `LinhaProximo`, `BlocoProximo` e `Oferta` entraram sem
`#Preview` próprio. A contagem de `#Preview` no arquivo é **8 antes e 8 depois**:
os mesmos oito da 05u, só com amostra trocada. Nenhum preview cobre um estado
novo — nem o vazio-que-oferece, nem `desatualizado`, nem `sem dados`, nem a
agenda de três, nem Dynamic Type no médio. Foi por isso que A1 e A3 chegaram
até a casa: nenhum preview obriga a olhar o cabeçalho estreito com estado.

Nota de contexto: as peças estão dentro de `TracoWidget.swift` e não em
`Traco/Componentes/` porque o alvo `TracoWidget` só compila `TracoWidget/`,
`Traco/Tema.swift` e `Traco/App/Intents/Compartilhado` — a fronteira justifica.
Mas `Oferta` e o `Vazio` de `Traco/Componentes/Vazio.swift` são o mesmo conceito
em dois lugares; se a F5 mexer num, tem de lembrar do outro.

### MÉDIO — A8. Acessibilidade: informação some no tamanho grande, e o bloco não fala

- `BlocoProximo` (`restantes: tipo.isAccessibilitySize ? 0 : …`) **esconde
  "+N depois" em tamanho de acessibilidade**. Em `f4-rev-casa-ax5.png` o médio
  do Próximo mostra só "15:10 Dentista" e o autor não sabe que há mais dois
  compromissos hoje. Esconder informação para limpar a tela é o que o AGENTS.md
  chama pelo nome.
- `BlocoProximo` é a única das cinco peças **sem `accessibilityElement` e sem
  `accessibilityLabel`** — e é a peça do pequeno, a família mais usada.
  `LinhaProximo` tem os dois; `BlocoProximo` deixa o VoiceOver ler hora,
  título e sino como três elementos soltos.

O resto da acessibilidade está bem: AX5 nas quatro famílias sem clipe (conferi),
`BotaoFeito` com alvo na linha inteira, rótulos e dicas no botão do feito.

### MÉDIO — A9. Número de ADR colidido com a F3b

Os dois ramos abertos reivindicam **`ADR 2026-09-05x`**:

```
f4-widgets:  ## ADR 2026-09-05x — Os widgets da casa prestam (volta F4)
f3b-ditado:  ## ADR 2026-09-05x — O áudio antes da letra
```

E os dois têm comentários de código apontando para "ADR 05x" com sentidos
diferentes (`TracoWidget/Relogio.swift` e `Traco/App/Sessao.swift:1288`). Quem
mesclar segundo tem de renumerar a seção **e** os comentários. Decisão do
orquestrador, não do implementador — mas tem de sair antes do G5.

### BAIXO — A10. Efeitos não declarados

- `Traco.xcodeproj/project.pbxproj` (+10 linhas) está no commit e **não está**
  na lista de arquivos do relato. É gerado pelo XcodeGen, mas é versionado.
- `ProximoCompromisso.publicar(_ eventos:cal:…)` — a chamada nova em
  `Sessao.encadear` — não só publica: ela também enfileira
  `atualizarAtividade(fatias.first)`, que pode **abrir uma Live Activity**
  (`Activity.request`) na tela bloqueada a partir de um caminho que antes não
  abria nenhuma. É coerente com o outro ramo e provavelmente é o que se quer,
  mas não está na ADR.

### BAIXO — A11. O vazio dos médios ainda é um vácuo, e o Destaque aparece três vezes

- `f4-rev-vazio-nota-selada.png`: os dois médios são 4×2 com uma frase curta e
  ~75% de área vazia. É melhor que antes (há oferta), mas o item 3 do G0 era
  exatamente "médio inteiro para 'nada marcado'".
- `f4-depois-inicio-so-destaque.png` (a captura dele): com o Destaque posto e a
  agenda vazia, "Terminar o capítulo do meio" aparece **três vezes** na mesma
  tela — médio do Traço, pequeno do Traço e médio do Próximo. O vazio que
  "traz o Destaque" só ajuda quem **não** tem o widget do Traço; o dono tem.

### BAIXO — A12. Faltam dois estados do G2

Não há captura de `sem dados` (`.indisponivel` — App Group fora do ar) nem de
`sem permissão`. As duas telas existem no código (`"Não consegui ler o Traço."`,
`"sem dados · abra o Traço"`) e nenhuma foi fotografada.

---

## Minhas capturas

| arquivo | o que mostra |
|---|---|
| `f4-rev-casa-claro.png` | as **quatro** famílias na casa, com dado — inclusive o pequeno do Próximo que ele disse não conseguir plantar |
| `f4-rev-casa-escuro.png` | modo escuro de verdade (papel de parede e dock escuros); o widget segue papel — D11 provado |
| `f4-rev-casa-ax5.png` | AX5 nas quatro famílias, sem clipe; e o "+2 depois" que some |
| `f4-rev-horizonte-antes.png` | 14:59, três compromissos, `validoAte` 15:03 |
| `f4-rev-horizonte-depois.png` | 15:04, **sem tocar em nada**: os quatro viraram para desatualizado sozinhos |
| `f4-rev-selo-truncado.png` | `TRAÇO · desatua…` / `TRAÇO · desat…` / `PRÓXI-MO · desat…` |
| `f4-rev-sino-sem-permissao.png` | avisos NEGADOS um minuto antes, e seis sinos prometidos |
| `f4-rev-oferta-truncada.png` | `Marcar um compro…` |
| `f4-rev-vazio-nota-selada.png` | vazio com nota expressiva selada no app: nada protegido na casa |
| `f4-rev-releitura.txt` | o `chronod` agendando a releitura para +3 h nos dois kinds, `budgeted-1` |

---

## Skills, conferidas contra a tela

**`design-router`.** As seis fases estão citadas e a maioria se sustenta:
Ancorar é um redesenho auditado antes de tocar, com capturas do estado velho e
três achados que ele mesmo acrescentou à lista do dono — isso é a fase feita,
não mencionada. Sistema se sustenta por diff (`Tema.swift` intocado, zero token
novo). Construir e Julgar se sustentam (três correções nasceram de olhar a
própria captura). **Portão não se sustenta**: ele fecha o portão dizendo
"capturas por estado" quando faltam dois estados, três capturas não mostram o
que dizem, e o `Selo` — a peça central da fase Sistema — quebra na primeira vez
que o estado aparece. Por isso a nota de Design é 6, não 9.

**`curva-zero`.** Jornada, resultado verificável, atrito observado e recuperação
estão os quatro escritos, e o desenho do vazio é melhor do que era. Mas a
recuperação é a ação, e a ação sai cortada (A3), e o poder que "mudou de lugar"
some de vez no tamanho grande (A8). 7.

---

## Instrumento

- Todo `xcodebuild` e todo `maestro` por `com-trava.sh`.
- Liguei o `iPhone 17 Pro (teste 3)` `34CC3F94`, usei só ele, desliguei ao fim.
  Não desliguei nenhum outro. Não toquei no `iPhone 17` `1A46B6D3`.
- `maestro/varrer.sh` **não pôde rodar**: ele exige exatamente um simulador
  ligado e havia seis. Usei `maestro --device 34CC3F94…` para os gestos e
  `cliclick` com `AXRaise` da minha janela antes de cada toque.
- Restaurei o simulador ao fim: `appearance light`, `content_size medium`.

---
---

# Re-G3 — a correção F4-B (ADR 2026-09-06d), commit `de85760`

Mesmo revisor, sessão nova, 06/09/2026. Simulador **iPhone 17 Pro (teste 3)**
`34CC3F94-FDB5-4575-A4F5-80271829A18B` — ligado, usado e desligado por mim.
Não editei nem commitei nada. O iPhone 17 `1A46B6D3` do dono **não foi ligado**.

Instrumento desta volta, conforme a lei nova da ESTEIRA ("o maestro não isola"):
**todas as provas de estado saíram de `xcrun simctl io … screenshot` e do
conteúdo do App Group**, nunca da hierarquia do `maestro`. Onde o instrumento
me travou, digo qual estado ficou pendente e não desconto nota por isso.

## Veredito

**CORRIGIR ANTES — mas por uma coisa só, e pequena.**

Os cinco altos estão fechados e os médios também; a A2 eu refiz inteira e ela
se sustenta no caminho mais difícil (revogação feita nos Ajustes, fora do app).
O que segura a volta é **uma regressão que a própria correção do A1 criou**: ao
tirar o estado do cabeçalho, o widget do Traço deixou de dizer que está velho
**quando há Destaque** — e aí ele simplesmente apaga a agenda e não fala nada.
Trocou verdade truncada por silêncio. Está na captura DELE.

## Notas revistas

| dimensão | G3 | Re-G3 | por quê |
|---|---|---|---|
| Visão | 10 | **10** | inalterada |
| Contrato | 7 | **9** | A9 feito (05x → 06d), A10 declarado, colisão com a F3b desfeita; sobra `05x` num comentário de `project.yml:87` |
| Correção | 8 | **9** | **728 testes / 127 suítes verdes, rodados por mim**; +2 travando a lei do sino nos dois sentidos |
| Jornada real | 6 | **9** | `sem dados` e `sem permissão` fotografados; escuro real e medido; AX5 dos estados novos |
| Design | 6 | **7** | A1 e A3 resolvidos por subtração, texto inteiro em toda parte — mas **R1** |
| Simplicidade | 7 | **8** | a oferta cabe inteira até em AX5; mas **M1**: em AX5 o médio do Traço vazio fica sem ação nenhuma |
| Movimento | 9 | **9** | intocado |
| Componentes | 7 | **8** | 12 previews (eram 8), os quatro novos são exatamente os estados que cortavam; falta o par que teria pegado R1 |
| Acessibilidade | 8 | **9** | "+N depois" volta em AX5, `BlocoProximo` fala; AX5 conferido por mim, no escuro |
| Performance | 10 | **10** | o espelho é um `bool` de `UserDefaults`, sem `await` |
| Privacidade e autoria | 10 | **10** | o widget continua lendo **só** `SuperficieDisco.ler()`; `SuperficieFora.swift` e `Tema.swift` intocados |
| Estado honesto | 5 | **7** | **A2 fechada por mim ponta a ponta**; mas **R1** |
| Complexidade | 9 | **9** | +273 / −68 em Swift, boa parte subtração |
| Fora do app | 6 | **9** | quatro famílias plantadas e fotografadas em todo estado, A5 corrigido, A6 corrigido, orçamento intacto |
| Relato | 7 | **9** | declara o próprio erro de instrumento e o que deixou; três imprecisões pequenas, nenhuma me enganou |

Abaixo de 9: **Design 7, Estado honesto 7, Simplicidade 8, Componentes 8** —
e três das quatro caem pela mesma R1.

---

## O que refiz, e o que achei

### A1 — fechado, mas abriu R1

O raciocínio dele está certo e é o melhor da correção: a causa não era a fonte,
era o **lugar**. O estado é sobre o conteúdo, não sobre o widget, então desceu
para a linha do conteúdo, onde tem largura inteira. `Selo` perdeu o parâmetro
`estado`, ganhou `lineLimit(1).allowsTightening(true)`, e as quatro famílias
leem `Desatualizado.` e `Não consegui ler o Traço.` **inteiros**, com a ação
uma vez só. Conferi contra a tela em `f4b-desatualizado-sem-destaque.png`
(17:26) e `f4b-sem-dados.png` (17:28): `PRÓXIMO` e `TRAÇO` sem hífen, sem
reticências, nas quatro. Em AX5, `f4b-vazio-ax5.png` (17:14). No escuro e em
AX5, o meu `f4-reg3-escuro.png` e `f4-reg3-escuro-ax5.png`.

### ALTO — R1 (novo). Com Destaque na tela, o widget do Traço fica velho **calado**

`TracoWidget.swift`, `miolo` e `medio`, testam nesta ordem:

```
indisponível → destaque → próximos → velha → vazio
                  ↑ ganha sempre que existe Destaque
```

E `EntradaTraco.proximos` devolve `[]` quando a superfície está velha. Então,
passado o horizonte **com Destaque posto**, o médio do Traço deixa cair a
agenda inteira e **não diz uma palavra**; o pequeno idem. Antes da correção ele
dizia `· desatua…` — truncado, mas dizia.

Está na captura dele, sem eu precisar montar nada:

- `f4b-horizonte-antes.png`: médio do Traço = Destaque + `16:30 Dentista` +
  `16:35 Revisão com o time`.
- `f4b-horizonte-depois.png`: mesmo widget, **só o Destaque**. Os dois
  `PRÓXIMO` dizem `Desatualizado.`; os dois `TRAÇO`, nada.

E reproduzi no meu aparelho: `f4-reg3-velho-com-destaque-cala.png` (18:36,
`validoAte` 18:35) — o pequeno do Traço passado o horizonte, idêntico ao de
antes dele, sem nenhum sinal.

Por que conta: a galeria deste widget promete, com as palavras dele,
"A única coisa de hoje, **o que vem a seguir** e um toque para começar". O que
vem a seguir some sem aviso. E é o defeito que abriu a volta — o dono olhando
para um widget que não conta que parou — voltando com outra roupa. Quem só tem
o widget do Traço não recebe sinal nenhum.

Conserto pequeno: dizer o estado junto do Destaque (uma linha abaixo dele, ou
no rodapé onde hoje mora o atalho), em vez de deixá-lo depender de não haver
Destaque.

### A2 — fechado, e eu refiz o passo mais difícil

O desenho está certo: `Avisos.estado()` é o único ponto que pergunta ao iOS e
agora grava um espelho no App Group (`avisosPermitidos`), que
`proximasFatias` lê **sem `await`** — a publicação continua síncrona, como a
04/set exigiu. `RaizView` relê e republica na volta à cena, porque a permissão
muda nos Ajustes. E o ramo que esta volta criou em `Sessao.encadear` publica
**mudo**, chama `Revisoes.agendarCompromisso` de verdade e só então promete, com
a frase que o sistema respondeu.

Refeito por mim, pelo conteúdo do App Group (`f4-reg3-sino-honesto.txt`):

1. permissão concedida → `avisosPermitidos => true`, superfície revisão 6 com
   `aviso 19:00 / 20:15 / 21:00`;
2. desliguei **"Permitir Notificações" nos Ajustes**
   (`f4-reg3-avisos-desligados-ajustes.png`) — antes de voltar ao app a
   superfície ainda dizia revisão 6 com os três sinos;
3. abri o Traço e saí, **sem marcar nada** → `avisosPermitidos => false`,
   revisão 7, **`aviso: None` nos três**.

Era o defeito 4 da auditoria F1 e o meu A2. Fechado.

**Lacuna de teste, nomeada:** `SinoHonestoTests` trava a lei no caminho de
publicação, nos dois sentidos — mas o ramo que esta volta escreveu
(`Sessao.agendarEContar`) continua sem teste. É o ramo que já errou uma vez.

### A pergunta do orquestrador: a lógica do sino sofre do mal da volta 18?

**Não. E a prova é do aparelho, não da leitura.**

Semeei uma série semanal cuja **cabeça está três domingos atrás**
(`inicio 2026-08-16T21:00`, `repeteEm [1]`, `avisoMinutos 60`) e li o que o app
publicou (`f4-reg3-serie-que-repete.txt`):

```
Padel de domingo  inicio 06/09 21:00 | aviso 06/09 20:00
Padel de domingo  inicio 13/09 21:00 | aviso 13/09 20:00
```

Cada **ocorrência** carrega o próprio aviso. Nenhuma herda 16/08. São três
razões independentes:

1. `ProximoCompromisso.proximasFatias` chama `Calendario.ocorrencias(...)`
   **antes** de `Aviso.instante` — e `ocorrencias` expande a série por
   `e.movido(paraODiaDe: dia, cal)`. `Aviso.instante` nunca vê a cabeça.
2. `Revisoes.agendarCompromisso` **já tem** a guarda que a volta 18 está
   acrescentando: `guard !e.repete else { … return .agendado(quando) }` vem
   **antes** de `guard quando > agora else { return .passou }`. Compromisso que
   repete não alcança o `.passou`.
3. O evento que a F4-B cria em `Sessao.encadear` nasce sem `repeteEm`, então o
   caso nem existe nesse caminho.

O achado da volta 18 é da volta 18. Nada a corrigir aqui — e, quando
`PromessaDoAviso` unificar os dois caminhos, é ela que precisa preservar estas
três propriedades, não o contrário.

### A3 — fechado

`Oferta` deixou de encolher e passou a quebrar linha; em tamanho de
acessibilidade o glifo cede a coluna à palavra. `f4b-vazio-ax5.png`:
`Marcar / compromisso` inteiro em duas linhas, `Nada em destaque hoje.`
inteiro. A segunda correção nasceu dele olhando o próprio AX5 — é a fase
Julgar acontecendo, não sendo citada.

### A4 — fechado, e a medida confere

Medi as capturas dele com o meu método:

```
f4b-casa-claro.png  190,6   |   f4b-casa-escuro.png  144,1
```

Ele declarou 187,5 e 140,1 — a diferença é de reamostragem (ele mediu antes de
reduzir); **a separação é real e é de ~46 pontos**, contra **0,0** dos pares da
F4. E `f4b-casa-escuro.png` mostra papel de parede escuro, dock escuro e os
quatro widgets em papel: D11 provado. O meu par independente dá 166,7 contra
82,3 (`f4-reg3-escuro.png`).

### A5 — fechado

A frase do limite falso saiu de `f4-widgets.md` e os quatro widgets estão
plantados. Confirmei na galeria do meu aparelho que a página do app é um
carrossel de quatro e que o pequeno do Próximo é a terceira.

### A6, A7, A8, A9, A12 — fechados

- **A6.** `destino` decide o `widgetURL` **e** o rodapé pelo que a face mostra.
  `f4b-um-toque-destino.png` (17:23): o pequeno do Traço com `16:52 Dentista`
  na face e **"Calendário"** no rodapé. No meu aparelho, com Destaque posto, o
  mesmo widget diz "Nova nota" — os dois ramos conferidos.
- **A7.** 12 previews (eram 8): `Amostra.velho` nas duas linhas do Traço e
  quatro previews AX5 nas larguras onde o texto cortava.
- **A8.** `+N depois` **não some mais** em AX5 (`f4b-dia-ax5.png`, no pequeno e
  no médio), e `BlocoProximo` ganhou `accessibilityElement(children: .combine)`
  com uma frase única.
- **A9.** `2026-09-05x` → `2026-09-06d` no SPEC, no EVOLUCAO e no código. A
  colisão com a F3b acabou.
- **A12.** `sem dados` (`f4b-sem-dados.png`) e `sem permissão`
  (`f4b-sino-sem-permissao.png`) fotografados.

### MÉDIO — M1 (novo). Em AX5 o médio do Traço vazio não oferece nada

`f4b-vazio-ax5.png`, widget de baixo: `TRAÇO` e `Nada em destaque hoje.` — e
mais nada. O médio esconde os atalhos em tamanho de acessibilidade
(`if !tipo.isAccessibilitySize`) e a `Oferta` desse ramo vai **sem rótulo**, com
o comentário "a ação já está dita ali perto (o médio a tem no cabeçalho)". Em
AX5 não tem: o cabeçalho está vazio. A recuperação da `curva-zero` desaparece
exatamente no tamanho que a correção varreu. Conserto: dar rótulo à `Oferta` do
médio quando `tipo.isAccessibilitySize`.

## A11, que ele deixou: metade honesta, metade não

**A primeira metade é adiamento honesto.** O Destaque aparecendo em dois
widgets é consequência de o widget não saber quais irmãos estão plantados, e o
vazio do Próximo trazer o Destaque é justamente o que serve a quem **não** tem
o widget do Traço. A saída real é configuração por widget
(`AppIntentConfiguration`), que já é item nomeado da trilha. Adiar está certo.
Registro o custo que ele não escreve: na casa **do dono** a duplicação é
garantida, porque ele tem os dois — quem abriu a volta é quem paga o adiamento.

**A segunda metade não é.** "O vazio dos médios ainda tem muita área livre" não
se resolve com widget configurável: calendário vazio continua vazio com pasta
escolhida ou sem. Em `f4b-vazio-oferta.png` (16:54) os dois médios são 4×2 com
uma frase, uma ação e ~70% de área morta — e é literalmente o item 3 do G0 do
dono ("médio inteiro para 'nada marcado'") e o defeito 5 dele ("densidade
errada"). Isso é decisão de layout que cabe hoje, e amarrá-la à volta da
configuração é o defeito voltando pela porta dos fundos. **Não derruba a volta
agora** — a nota de Simplicidade cai por M1, não por isto —, mas tem de estar
no RUMO com nome próprio, não dissolvido em "widget configurável".

## O erro de instrumento dele: efeito nenhum nas provas que consigo checar

Ele declara ter removido `/tmp/traco-instrumento.lock` duas vezes, entre 16:05
e 16:15, sem perceber que havia fila. Julgamento:

- **As capturas que dá para datar estão todas fora da janela.** Li o relógio na
  barra de status de cada uma: 16:54, 17:14, 17:23, 17:26, 17:28. As que não dá
  para datar são as que têm a Live Activity cobrindo o relógio, e o conteúdo
  delas (compromissos às 16:30/16:40) é coerente com a mesma sessão.
- **Os dois números mais expostos eu reproduzi sozinho**, depois, sob a trava:
  `BUILD SUCCEEDED` e `Test run with 728 tests in 127 suites passed`.
- Ele não usou `maestro` para toque — usou `cliclick` com `AXRaise` da janela
  dele —, então o risco de a hierarquia do vizinho contaminar um gesto não se
  aplica ao que ele fez.

**Conclusão:** o dano do lock removido, se houve, foi para os OUTROS workers da
fila, não para as provas desta volta. Declarar o erro no relato é exatamente o
que a ESTEIRA pede; não desconto nota por isso, e recomendo que o orquestrador
verifique quem estava na fila entre 16:05 e 16:15.

## Imprecisões do relato (nenhuma me enganou)

1. "`Tema.aviso` saiu do widget" — saiu do `Selo`, que era o que importava, mas
   o token continua em `TracoWidget.swift:878`, na linha de recusa da Live
   Activity (`bell.slash`), que é da 04f e não desta volta.
2. "Nenhum `05x` sobra no código" — sobra em `project.yml:87`, num comentário
   que a própria F4 escreveu.
3. A prova em três passos da A2 usa, para o passo 1 (nunca perguntado) e para o
   passo 3 (revogado nos Ajustes), duas capturas **indistinguíveis** — mesma
   cena, diferença máxima de 1 nível por canal, e o relógio coberto pela Live
   Activity nas duas. Os dois estados de fato desenham igual (sem sino), então
   não é invenção; mas a foto sozinha não prova a sequência. O que prova é o
   conteúdo do App Group — e é por isso que refiz o passo 3 eu mesmo.

## Instrumento desta revisão

- `xcodebuild` sob `com-trava.sh`. Build limpo do app e do widget; os dois
  únicos `warning:` da suíte estão em `TracoTests/ConferenciaTrabalhoTests.swift:381`,
  arquivo que nem a F4 nem a F4-B tocaram.
- Provas de estado por `xcrun simctl io … screenshot` e pelo conteúdo do
  App Group, como manda a lei nova. Nada de decisivo saiu do `maestro`.
- **Pendente de instrumento, sem desconto de nota:** consegui replantar **uma**
  das quatro famílias no meu aparelho. O carrossel da galeria de widgets parou
  de paginar depois da quinta tentativa (`cliclick` lento e rápido, `maestro`
  por porcentagem), com a SpringBoard travando em quadro parado duas vezes;
  reiniciei a SpringBoard e reiniciei o simulador uma vez cada. Descobri a causa
  de parte disso e registro para quem vier: **a Live Activity do Destaque ocupa
  a Ilha Dinâmica e engole o toque no botão "Editar" da tela de início** —
  apagar o Destaque antes de plantar widget resolve. As três famílias que não
  replantei estão fotografadas nas capturas dele, que conferi por conteúdo e
  por relógio.
- Restaurei ao fim: `appearance light`, `content_size medium`, e desliguei o
  `34CC3F94`. Não desliguei simulador de ninguém.

## Minhas capturas

| arquivo | o que mostra |
|---|---|
| `f4-reg3-velho-com-destaque-cala.png` | 18:36, horizonte vencido às 18:35: o widget do Traço com Destaque **não diz que está velho** (R1) |
| `f4-reg3-avisos-desligados-ajustes.png` | "Permitir Notificações" desligado nos Ajustes |
| `f4-reg3-sino-honesto.txt` | os três passos da A2 pelo App Group: `true` + três sinos → Ajustes off → `false` + `aviso: None` nos três |
| `f4-reg3-serie-que-repete.txt` | série semanal com cabeça de 16/08 publicando aviso 06/09 20:00 e 13/09 20:00 — sem o mal da volta 18 |
| `f4-reg3-escuro.png` | escuro de verdade no meu aparelho (166,7 → 82,3 de brilho médio) |
| `f4-reg3-escuro-ax5.png` | AX5 no escuro: `TRAÇO` inteiro, Destaque em quatro linhas, sem clipe |

## Para o G4

Se o dono mandar seguir, o G4 de design entra com duas perguntas prontas: o
peso de quatro lajes de papel branco numa casa escura (decisão D11 declarada,
mas ele ainda não a viu), e a densidade dos médios vazios (A11, segunda
metade). R1 e M1 têm de estar corrigidos antes.

---

## Re-G3, segunda passada — F4-C (`c79da9e`) já com `git merge main` (`af10375`)

Mesmo revisor, sessão nova, 06/09/2026, ~20h. Simulador **iPhone 17 Pro (teste 3)**
`34CC3F94`, ligado e desligado por mim. Não editei nem commitei código. Não
liguei o iPhone 17 `1A46B6D3` do dono. Prova de tela por `xcrun simctl io
screenshot` e pelo conteúdo do App Group; nada decisivo saiu do maestro (havia
quatro simuladores ligados — lei do instrumento da ESTEIRA).

### Veredito

**CORRIGIR ANTES, e é a última milha.** Tudo pelo que a volta caiu está
fechado: R1 virou lei com teste e eu a refiz na combinação exata; M1 e a metade
da A11 que eu recusei adiar viraram um quadro de ofertas que usa o espaço; e a
suíte **764/131 eu confirmei**. O que sobra é **AX5**: em tamanho de
acessibilidade a frase do Destaque termina em reticências e a palavra
`Desatualizado.` quebra com hífen no meio — `Desatualiza-/do.` —, que é
exatamente o defeito A1 pelo qual recusei da primeira vez, agora só no tamanho
grande. É uma propriedade de `Text` em dois lugares, e o próprio código já tem
a receita três linhas ao lado.

### Notas revistas

| dimensão | Re-G3 (1ª) | agora | por quê |
|---|---|---|---|
| Visão | 10 | **10** | — |
| Contrato | 9 | **10** | `05x` sumiu de `project.yml:87`; e o merge provou que a renumeração era necessária — `ADR 2026-09-05x` chegou de main como "De onde vem cada método" (volta 16) |
| Correção | 9 | **10** | **764 testes / 131 suítes verdes rodados por mim** na árvore mesclada; +4 testes de `EstadoNaFace` |
| Jornada real | 9 | **9** | a combinação que regrediu está fotografada nos dois tamanhos |
| Design | 7 | **9** | R1 fechada, e a correção é melhor que o defeito: a decisão saiu da view e virou lei |
| Simplicidade | 8 | **9** | o médio vazio virou três ações reais no corpo; a recuperação sobrevive em AX5 |
| Movimento | 9 | **9** | intocado |
| Componentes | 8 | **9** | 14 previews; `velhoComDestaque` é a combinação que regrediu, com preview próprio |
| Acessibilidade | 9 | **8** | **N1/N2/N3**: em AX5 a frase do Destaque corta e o estado hifeniza |
| Performance | 10 | **10** | — |
| Privacidade e autoria | 10 | **10** | o widget continua lendo só `SuperficieDisco.ler()`; `SuperficieFora.swift` e `Tema.swift` intocados |
| Estado honesto | 7 | **9** | passada a validade, toda face diz — provei nas duas famílias da casa |
| Complexidade | 9 | **9** | +231 / −14 em Swift |
| Fora do app | 9 | **9** | as duas famílias da casa provadas; as duas de acessório mudam por um ternário e o simulador não as renderiza (F1 §7) |
| Relato | 9 | **8** | declarou o custo de AX5 — mas pela metade, e a outra metade está na captura que ele anexou |

Abaixo de 9: **Acessibilidade 8** e **Relato 8**.

### R1 — fechada, e do jeito certo

A decisão saiu do `if/else` da view e virou `EstadoNaFace` em `Relogio.swift`,
com quatro testes (`EstadoNaFaceTests`), inclusive um que percorre as quatro
combinações e falha com a mensagem "é a R1 de volta". Era a crítica de fundo:
um `if/else` de view não tem suíte, e foi um `if/else` de view que regrediu.

Refiz a combinação exata no meu aparelho, **sem tocar em nada**:

- `f4-reg3b-horizonte-antes.png` — 19:47, `validoAte` 19:52, Destaque posto e
  agenda nos dois widgets do Traço.
- `f4-reg3b-horizonte-depois.png` — **19:53**, sozinho: o pequeno do Traço
  mantém o Destaque e ganha o rodapé `🕐 Desatualizado.`; o médio mantém o
  Destaque, larga a agenda **e diz o rodapé**. Onde antes havia silêncio.

As outras duas famílias do mesmo widget mudam por um ternário
(`DESATUALIZADO` na etiqueta do `accessoryRectangular`, `Traço · desatualizado`
no `accessoryInline`); li as duas e o simulador não renderiza acessório na
bloqueada trancada (F1 §7) — **pendente de instrumento, sem desconto**.

O médio do Próximo ele não replantou porque o carrossel da galeria trava; é o
mesmo instrumento que me travou. E a R1 de fato **não é defeito dessa família**:
`ProximoWidgetView` decide por `estadoDoProximo`, que devolve `.desatualizado`
antes de `.vazio`, então ela sempre disse. Conferi no código e na tela
(`f4-reg3b-horizonte-depois.png`, widget de cima à esquerda).

### M1 e a metade da A11 — fechadas, e o médio agora usa o espaço

`quadroVazio`: sem Destaque e sem agenda, a face inteira vira três ações reais,
uma por linha, com o alvo na linha toda, e os atalhos saem do cabeçalho para
não aparecerem duas vezes. Como moram no **corpo**, sobrevivem ao tamanho de
acessibilidade — que era exatamente onde o vazio ficava mudo.

- `f4-reg3b-vazio-quadro.png` (normal): "Nada em destaque hoje." + Nova nota +
  Marcar compromisso + Recordar.
- `f4-reg3b-vazio-quadro-ax5.png` (**AX5, meu**, 19:59): a frase e **duas ações
  inteiras** no corpo. Antes: uma frase e nada.

Julgamento sobre o defeito 5 do dono ("densidade errada"): **sim, o médio
passou a usar o espaço que tem.** Um 4×2 com uma frase e ~70% de área morta
virou um 4×2 com uma frase e três caminhos. E a resposta que eu recusei na
primeira passada — "isso é a volta do widget configurável" — caiu por terra
sozinha: deu para resolver hoje, sem configuração nenhuma.

### A troca de AX5, que você mandou julgar

**A troca é a certa: o estado tem de ganhar.** Um widget que mostra a frase de
ontem como se fosse a de hoje é a mentira que abriu a volta; perder uma linha
da frase é perda menor que um silêncio. Se fosse escolher, escolheria igual.

**Mas o custo que ele assumiu não precisa ser pago, e é maior do que ele
escreveu.** Três coisas, todas em AX5 e todas na mesma captura que ele anexou
(`f4c-horizonte-depois-ax5.png`, e idênticas às minhas em outro minuto):

- **N1 — a frase não "cede uma linha": ela termina em reticências.**
  `Terminar / o / capítul…` no pequeno do Traço. Reticências no Destaque é o
  item 6 da auditoria dele mesmo ("o widget existe para mostrá-la inteira") e é
  o A1 pelo qual recusei. `linhaDoDestaque` usa `minimumScaleFactor(0.85)`;
  `Velho()`, três linhas ao lado, usa **0,6** justamente para encolher inteiro
  em vez de cortar. A receita está no arquivo e não foi aplicada à frase.
- **N2 — `Desatualiza-/do.`** O estado quebra **com hífen no meio da palavra**
  no pequeno do Próximo (`f4-reg3b-ax5-corte.png`). É a mesma família de
  defeito do `PRÓXI-/MO` que derrubou a F4, agora na própria palavra que diz a
  verdade. Causa: o `Text(estado)` da `Oferta` é o único texto da família **sem
  `allowsTightening` e sem `minimumScaleFactor`** — `AtalhoTraco` tem, `Velho`
  tem, e por isso "Marcar compromisso" quebra em duas linhas inteiras ao lado,
  sem hífen. **Não declarado.**
- **N3 — e parte do corte não é culpa do rodapé.** No pequeno do Próximo, no
  ramo "o vazio traz o Destaque" (que a F4 criou), a frase corta em AX5
  **sem rodapé nenhum na face**: `Terminar / o capít…`
  (`f4-reg3b-ax5-destaque-corta.png`, 19:55, superfície fresca). Mesmo 0,85,
  outro lugar. Ou seja: ele atribuiu ao rodapé um corte que já existia.

Conserto: `minimumScaleFactor(0.6)` e `allowsTightening(true)` nos dois `Text`
(a frase do Destaque e o `estado` da `Oferta`). Com isso a troca deixa de ser
troca — cabem os dois.

### O que confirmei da prova dele

- **`Test run with 764 tests in 131 suites passed`** e `** TEST SUCCEEDED **`,
  na árvore mesclada, no meu simulador, sob `com-trava.sh`. Bate com o
  declarado.
- **Os quatro avisos são de main.** Todos em
  `TracoTests/ConferenciaTrabalhoTests.swift:381` (`d` e `p` que podiam ser
  `let`), arquivo cujo último commit é da volta 5 e que nem a F4 nem a F4-C
  tocaram. Nenhum aviso sai do código da volta.
- **A renumeração era obrigatória, não cosmética.** Depois do merge, `ADR
  2026-09-05x` existe em `SPEC.md:2942` como "De onde vem cada método" (volta
  16). Se a F4 tivesse ficado com `05x`, o SPEC teria dois ADR com o mesmo
  número — o achado A9 do primeiro G3 se pagou aqui.
- Invariantes: `Tema.swift` e `SuperficieFora.swift` **não estão no diff** da
  F4-C; o widget continua sem `UserDefaults`, `SwiftData`, `FileManager` ou
  `Corpus` — só `SuperficieDisco.ler()`.

### Achado menor, para a lista e não para o portão

- **BAIXO.** O `accessoryInline` do widget do **Próximo** continua dizendo só
  `"Traço"` quando o instantâneo está velho, do mesmo jeito que quando não há
  nada marcado — o autor não distingue "nada hoje" de "não sei". O widget do
  Traço acabou de ganhar `"Traço · desatualizado"` para exatamente isso. Uma
  linha, e o `accessoryRectangular` da mesma família já diz certo.

### Instrumento

- `xcodebuild` sob `com-trava.sh`, que agora retoma trava presa e escreve o
  dono — não precisei da retomada, a trava estava livre.
- Quatro simuladores de outros ligados durante toda a sessão: **nenhuma
  evidência de maestro**, conforme a lei nova.
- **Lição de instrumento, para quem vier:** o `cfprefsd` do simulador serve o
  plist do App Group de memória e ignora edição feita por fora — apaguei o
  Destaque do plist e o app continuou publicando a linha por quatro lançamentos
  seguidos. Só **reiniciar o simulador** fez o app ler o disco. E
  `xcrun simctl spawn <D> defaults write group.app.traco …` escreve num domínio
  diferente do que o app sandboxed lê; não serve para semear.
- A galeria de widgets travou de novo no botão "Editar" (mesmo sintoma do
  re-G3 anterior, agora sem Live Activity na Ilha): não replantei nada, e não
  precisei — as duas famílias da casa que a R1 quebrou já estavam plantadas.
- Restaurei ao fim: `content_size medium`, `appearance light`, e desliguei o
  `34CC3F94`. Não desliguei simulador de ninguém.

### Minhas capturas

| arquivo | o que mostra |
|---|---|
| `f4-reg3b-horizonte-antes.png` | 19:47, Destaque + agenda, `validoAte` 19:52 |
| `f4-reg3b-horizonte-depois.png` | **19:53, sozinho**: Destaque mantido e `Desatualizado.` no rodapé do pequeno E do médio — R1 fechada |
| `f4-reg3b-horizonte-depois-ax5.png` | a mesma combinação em AX5 |
| `f4-reg3b-ax5-corte.png` | recorte: `Terminar / o / capítul…` e `Desatualiza-/do.` lado a lado (N1 e N2) |
| `f4-reg3b-ax5-destaque-corta.png` | 19:55, superfície fresca: a frase corta em AX5 **sem rodapé** (N3) |
| `f4-reg3b-vazio-quadro.png` | o médio vazio como quadro de ofertas, três ações |
| `f4-reg3b-vazio-quadro-ax5.png` | 19:59, o mesmo em AX5: duas ações inteiras onde antes não havia nenhuma (M1) |

### Para o G4

Com N1 e N2 corrigidos, esta volta chega ao G4 com o motor provado, o estado
honesto em toda combinação e o vazio resolvido. As duas perguntas de design
continuam de pé para o julgador: o peso de quatro lajes de papel branco numa
casa escura (D11, decisão declarada que o dono ainda não viu), e se três ações
empilhadas são a melhor forma do médio vazio ou só a mais óbvia.

---

## Re-G3, terceira passada — F4-D (`0aca3f3`)

Mesmo revisor, 06/09/2026, ~21h. Simulador **iPhone 17 Pro (teste 3)**
`34CC3F94`, ligado e desligado por mim. Não editei nem commitei código. Não
liguei o iPhone 17 `1A46B6D3` do dono. Quatro simuladores de outros ligados
durante a sessão: **nenhuma evidência de maestro** (lei do instrumento).

### Veredito

**APROVADO no G3.** Nenhuma dimensão abaixo de 9. Os três cortes de AX5 estão
fechados, o custo está declarado inteiro na ADR, e a suíte **767/132 eu
confirmei**. A volta pode ir ao G4.

### Notas revistas

| dimensão | 2ª passada | agora | por quê |
|---|---|---|---|
| Acessibilidade | 8 | **9** | N1, N2 e N3 fechados; nenhuma reticência e nenhum hífen no meio de palavra em nenhuma das quatro famílias, nos dois temas, em AX5 |
| Relato | 8 | **9** | a ADR 06d agora carrega o custo INTEIRO (item 10 e "Custo assumido"), nomeia os três achados e explica o mecanismo — inclusive a parte em que a minha prescrição não bastava |
| Correção | 10 | **10** | **767 testes / 132 suítes verdes rodados por mim**; +3 em `LinhasDoEstadoTests` |
| Contrato | 10 | **10** | — |
| Visão · Jornada real · Design · Simplicidade · Movimento · Componentes · Performance · Privacidade · Estado honesto · Complexidade · Fora do app | 10/9/9/9/9/9/10/10/9/9/9 | **mantidas** | nada nesta passada as toca |

### O mecanismo: a minha prescrição estava certa na direção e curta no meio

Eu prescrevi `minimumScaleFactor(0.6)` e `allowsTightening(true)` nos dois
`Text`, apontando `Velho()` como a receita que já existia no arquivo. Nos dois
lugares onde a frase é do **Destaque** isso bastou — N1 e N3 morreram.

Em `Oferta`, não. E ele mediu, fotografou e explicou:
`f4d-ax5-hifen-persiste.png` é o estado **depois** de aplicar exatamente o que
eu pedi, e ali o pequeno do Traço já mostra `Terminar / o capítulo / do meio`
inteiro (N1 fechado) enquanto o pequeno do Próximo **ainda** mostra
`Desatualiza-/do.`. Com teto de linhas maior que 1, o SwiftUI prefere
**hifenizar a encolher** e nunca chega ao `minimumScaleFactor`.

Confiro a explicação e assumo o erro: `Velho()`, que citei como receita, tem
**três** propriedades — e a operativa era a que eu não transcrevi,
`lineLimit(1)`. Prescrevi duas de três. Numa palavra sem espaço não existe
quebra honesta, e é o teto de linhas, não a escala, que decide se a palavra
parte.

O conserto é a mesma solução estrutural da R1: o teto saiu da view e virou
`LinhasDoEstado` em `Relogio.swift`, com três testes — **palavra sem espaço
recebe uma linha e encolhe inteira; frase com espaço usa o teto e quebra na
linha**. Um `if` de view não tem suíte, e é a terceira vez nesta volta que um
`if` de view é a causa.

**Auditei a lei contra o domínio real**, que é a parte que me cabe: enumerei
todas as strings que a face pode passar a `Oferta(estado:)` e a `ausencia` —
`Desatualizado.`, `Não consegui ler o Traço.`, `Nada em destaque hoje.`,
`Nada marcado.`, `Nada marcado hoje.` Uma sem espaço, quatro com. A regra
cobre as cinco, e o teste dele enumera exatamente essas cinco. A lei é
completa sobre o que a face escreve hoje, e o teste quebra quando alguém
acrescentar um estado sem atualizar a lista — que é o acoplamento certo.

### O que confirmei

- **`Test run with 767 tests in 132 suites passed`**, `** TEST SUCCEEDED **`,
  no meu simulador, sob `com-trava.sh`. Os únicos 4 `warning:` continuam sendo
  `TracoTests/ConferenciaTrabalhoTests.swift:381`, que veio de main.
- **As quatro famílias na casa, em AX5, nos dois temas, com Destaque longo e
  horizonte vencido, sem reticências e sem hífen**: `f4d-ax5-claro.png` e
  `f4d-ax5-escuro.png`. Medi o par: brilho 190,0 contra 144,4 — escuro de
  verdade, não rótulo.
- **O ramo "o vazio traz o Destaque" com superfície fresca**, que era o N3:
  `f4d-ax5-vazio-destaque-claro.png` / `-escuro.png` (189,2 contra 143,6). A
  frase sai inteira, encolhida, onde antes saía `Terminar / o capít…`.
- **O médio do Próximo está plantado** — a família que a galeria não deixava
  paginar aparece nas quatro capturas, em cima, dizendo `Desatualizado.` em
  largura inteira. Ele conseguiu o que travou a mim em três sessões.
- **O custo declarado inteiro.** A ADR 06d passou a dizer, com todas as
  letras, que em AX5 no pequeno com Destaque longo e horizonte vencido a frase
  tem três linhas em vez de quatro e encolhe até 60% — "este é o custo
  inteiro, medido na tela" —, e que as três coisas que eu achei não eram
  troca, eram propriedades que ficaram para trás. Era a razão do Relato 8.

### O BAIXO que ele deixou: a decisão está certa, e por uma razão melhor

O `accessoryInline` do widget do **Próximo** continua dizendo só `"Traço"`
quando o instantâneo é velho, sem distinguir "nada hoje" de "não sei".

A razão dele — família que o simulador não renderiza (F1 §7), e ele não
entrega diff sem prova de tela — é boa e é a disciplina que esta volta inteira
cobrou. **Mas há uma razão mais forte, e é de desenho:** o widget do Traço
acabou de ganhar `"Traço · desatualizado"` nessa mesma família. Se o autor
tiver os dois `accessoryInline` na tela bloqueada, os dois passariam a dizer a
mesma frase, na única família onde existe uma linha e nada mais — é a
duplicação da A11 outra vez, num lugar sem espaço para resolvê-la. O que a
linha do Próximo deve dizer quando o instantâneo é velho **é uma escolha, não
uma transcrição do ternário do irmão**.

Portanto: **adiar está certo**, e quem pegar isto no G4 ou na trilha não deve
copiar o ternário — deve decidir a frase com o dono olhando.

### Observação que nasce do achado dele (BAIXO, para a lista)

A lei nova protege as frases de **estado**, que o app escreve. A frase do
**Destaque** é do autor, é ilimitada, e continua com `lineLimit` maior que 1
(3 no pequeno, 2 no médio) — pelo mecanismo que ele acabou de medir, uma
palavra única mais larga que a face ainda hifenizaria ali. Não vi acontecer e
não é defeito enquanto não se vir: o Destaque é uma frase, e frase quebra no
espaço. Fica anotado porque decorre diretamente do que ele descobriu.

### Instrumento

- `xcodebuild` sob `com-trava.sh` (trava livre; não precisei da retomada nova).
- **A primeira execução da suíte morreu em `The test runner hung before
  establishing connection.`** — build completo, runner sem conectar. É
  instrumento, não código: repeti e deu 767/132. Registro porque a máquina
  passou a noite matando simulador por memória.
- **Não consegui replantar os widgets no meu aparelho nesta rodada.** A folha
  "Adicionar Widget" trava com a linha realçada e a folha nunca abre — mesmo
  sintoma das duas sessões anteriores, agora sem Live Activity na Ilha, e
  reiniciar a SpringBoard só embaralhou o layout. **É instrumento e não
  desconta nota** (ESTEIRA), mas já custou três sessões de revisão: vale uma
  linha na lei do instrumento, ao lado da do maestro. O que confirmei nesta
  passada veio da suíte que rodei, do diff que li linha a linha, da auditoria
  estática da lei contra todas as strings da face, e do conteúdo das capturas
  dele — conferidas por brilho medido e por leitura do que está escrito nelas.
- Restaurei ao fim: `content_size medium`, `appearance light`, e desliguei o
  `34CC3F94`.

### Para o G4

A volta chega ao portão de design com o motor provado (releitura agendada,
orçamento curto), o estado honesto dito em toda combinação e com lei testada,
o sino que só promete o que vai tocar, o vazio que oferece, e nenhum texto
cortado em nenhuma família, tema ou tamanho. As perguntas de design que sobram
são as duas que já anotei: o peso de quatro lajes de papel branco numa casa
escura (D11, decisão declarada que o dono ainda não viu), e se três ações
empilhadas são a melhor forma do médio vazio ou apenas a mais óbvia.
