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
