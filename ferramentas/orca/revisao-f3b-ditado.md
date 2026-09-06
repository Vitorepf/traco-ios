# G3 — revisão da volta F3b (ditado próprio: o áudio antes da letra)

Revisor independente (Claude Opus 5), 06/09/2026. Worktree `f3b-ditado`, HEAD `fa0cf53`.
Simulador de teste: **iPhone Air 64F7B8B4** (já estava ligado quando cheguei — não desliguei).
Todo `xcodebuild` e todo `maestro` correram por `ferramentas/orca/com-trava.sh`.
Nada foi editado no código nem commitado. Capturas desta revisão: `f3b-rev-*.png`.

## Veredito

**CORRIGIR ANTES.** A promessa central da volta — *o áudio é depositado antes de
qualquer letra, e falha de transcrição preserva o áudio* — **se sustenta e está
provada na tela** (`f3b-rev-02`). O instrumento de ensaio **não existe em
Release**, provado no binário. O que derruba a volta são três achados altos e um
conjunto de dimensões que não chegam a 9: uma tela que **mente** quando o disco
recusa, um par de notas **duplicadas com o mesmo áudio** reproduzível em dois
toques, e a **colisão do número da ADR com a F4**.

---

## 1. A ORDEM — o áudio está no disco antes da primeira letra?

**Sim, em todos os caminhos de dentro do app.** Leitura do código e prova em
execução.

- `DitadoProprio.comecar()` abre o `AVAudioRecorder` **no destino final do
  anexo** (`AnexoDisco.url(id, nome:)`, `DitadoProprio.swift:76,117`) — o m4a
  nasce onde a nota vai procurá-lo, não é copiado no fim.
- `concluir()` (`:147-165`) faz, nesta ordem: `fechar()` (o `stop()` que
  finaliza o arquivo) → `gravarNota(corpo SEM transcrição)` → só então
  `pedirALetra()`. Não há `await` entre o guard e a mudança de estado, então não
  há reentrância.
- O único escritor de transcrição é `pedirALetra()` (`:183-198`), que sempre
  corre depois do depósito. `tentarDeNovo()` só age com a nota já no disco.
- Teste `depositoAntesDaLetra` conta a ordem num diário: `passos[0]` = depósito
  sem letra, `passos[1]` = "PEDIU A LETRA", `passos[2]` = reescrita.

### Matar o app no meio da TRANSCRIÇÃO — o que sobra (prova)

`traco://ditar?ensaio=transcrito` → "Pronto" → `simctl terminate` durante os 6 s
da transcrição → relançar.

- Sobra a nota **"Ditado de 6 de setembro, 14h44. O áudio ficou guardado, sem
  transcrição."** (`f3b-rev-01-morto-gravando-sem-nota.png` mostra a lista logo
  antes; `f3b-rev-02-morto-na-transcricao.png` mostra a nota aberta).
- Dentro dela, o portal ÁUDIO com `ditado 6 set. 14h44.m4a`, 70 KB, tocável.
- `afinfo` no arquivo: `estimated duration: 2.065125 sec`, m4a válido.

**A promessa da volta se cumpre aqui.**

### Matar o app no meio da GRAVAÇÃO — o que sobra (prova)

`traco://ditar` → 4 s gravando (`f3b-rev-00-gravando-antes-da-morte.png`) →
`simctl terminate` → relançar → Notas.

- **Nenhuma nota** é criada. A lista depois do relance (`f3b-rev-01`, tirada às
  14h40) tem como mais recente o ditado das **13h53**, do implementador.
- Fica no cofre um `D77FD80B….m4a` de 76 154 bytes que **não abre**:
  `afinfo` → `Fail: AudioFileOpenURL failed`. Sem o `stop()`, o m4a não recebe o
  átomo `moov` e não é áudio, é lixo.
- Como nota nenhuma o referencia, `AnexoDisco.varrerOrfaos` o apaga depois da
  carência de 24 h (`AnexoDisco.swift:59-73`). Para o autor, **não sobra nada**.

Isto **não é achado alto** — é o limite honesto de um gravador em primeiro plano,
e o `willResignActive` de `RaizView.swift:187` cobre o caso comum (sair do app
deposita). Mas a ADR e o EVOLUCAO dizem hoje *"falha, silêncio ou **app morto**
deixam a nota com o áudio tocável dentro dela"*, o que só é verdade **depois do
depósito**. **A frase do contrato precisa dessa ressalva** (achado médio, ver
M4). Ainda no cofre do simulador de teste há 25 m4a; vários outros também não
abrem — resíduo das corridas do implementador, mesma causa.

## 2. A FALHA PRESERVA — e o instrumento de ensaio em Release

**A falha é real e preserva.** No simulador não há modelo de fala no aparelho, e
a transcrição falha de verdade; a nota fica com o áudio e a linha honesta
(`f3b-03-falha.png`, `f3b-07-nota-falha.png`, e a minha `f3b-rev-06`).

**O instrumento de ensaio NÃO existe em Release. Provado:**

1. A declaração está dentro de `#if DEBUG` (`Intencoes.swift:311-317`), e os dois
   únicos usos também (`Intencoes.swift:351-357` na `daURL`, `RaizView.swift:222-234`).
   Como a **própria variável** é Debug-only, qualquer uso não guardado **não
   compilaria** em Release.
2. `xcodebuild build -configuration Release` → `** BUILD SUCCEEDED **`,
   **0 avisos**.
3. Busca no binário Release (`Release-iphonesimulator/Traco.app/Traco`):
   `ensaioDoDitado` = **0 ocorrências**; a frase do ensaio
   `comprar pão e ligar…` = **0 ocorrências**.
4. Controle positivo: as duas cadeias **existem** no `Traco.debug.dylib` do build
   Debug. O método de busca funciona; a ausência em Release é real.

Ressalva menor (L3): o motivo específico e acionável que o código sabe dar
(`"o português para ditado offline não está instalado. Ajustes › Geral › Teclado
› Ditado."`, `DitadoProprio.swift:216`) **nunca aparece**: o simulador entra pelo
ramo genérico `"a transcrição falhou no aparelho."`. A ADR descreve a recusa
específica como o comportamento do simulador; a tela mostra a genérica.

## 3. PRIVACIDADE — o áudio é do autor

**Contrato intacto.** Sem achado alto.

- `pedido.requiresOnDeviceRecognition = true` está **no código**
  (`DitadoProprio.swift:225`), e antes dele o guard que **RECUSA** em vez de cair
  no remoto: `guard reconhecedor.supportsOnDeviceRecognition` (`:214`).
- **Nada de entitlement novo, nada de `UIBackgroundModes: audio`** — o diff de
  `project.yml` e dos plists é **vazio**. O app não pode gravar em segundo plano.
- **O áudio não sai do app.** `Caderno.prosa` descarta blocos `.audio`
  (`BlocoCaderno.swift:594`), e é `prosa` que alimenta `vozDoAutor`
  (`VozDoAutor.swift:17`) — que é o que vai para Spotlight (`Holofote.swift:19`),
  para o índice (`Sessao.swift:1022-1030`) e para a busca. Nem o nome do arquivo
  nem o `traco://audio/<id>` viajam. O widget/App Group não recebe nada do ditado.
- **Nada de blob no SwiftData**: o m4a mora só no cofre `Anexos` do contêiner.
- **Permissões separadas, e a tela diz.** Microfone negado: "Sem microfone." + o
  motivo + "Escrever em vez disso" (`f3b-08`, `f3b-09` — conferidas, conteúdo
  real). Fala negada não impede gravar (`:218-223`).

Dois pontos baixos, não bloqueantes:

- **L1** — `traco://ditar` é esquema público: qualquer app ou página pode abrir o
  Traço **gravando**. A gravação é totalmente visível (tela cheia + indicador
  laranja do iOS), então não há captação silenciosa; ainda assim é superfície
  nova exposta.
- **L2** — `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription` continua
  `"Ditar o compromisso."` (`project.yml:79`). É o texto que o autor lê ao
  autorizar o reconhecimento **desta** função. Contexto errado.

## 4. +1012 LINHAS — o que justifica e o que podia não existir

Repartição real: **+609 Swift de produção**, +171 testes, +158 documento,
+50 maestro, +24 pbxproj gerado.

**Justificado, e eu não cortaria:**

- O gravador, a sessão de áudio, o medidor de nível e o relógio (~60 linhas): o
  nível é a única prova de que o microfone ouve, e a ADR argumenta bem por ele.
- As três injeções (`abrirMicrofone`/`fecharMicrofone`/`transcritor`, ~10 linhas):
  são o que permite **9 testes sem microfone nenhum**. Pagam-se.
- O canal próprio `Rota.ditadoPendente`/`ditar()`/`consumirDitado()` (~14 linhas):
  a razão está certa — o ditado não é `Destino`, e a Página não pode levantar o
  teclado por trás.
- O instrumento `#if DEBUG` (~15 linhas): gated, pequeno, e sem ele o estado
  "transcrito" não se fotografa. Fica.

**Podia não existir (~55 linhas):**

- **A duplicata da `ConfirmacaoView`.** `DitadoProprioView` copia a casca inteira
  (`ZStack` + `.ultraThinMaterial` + `Tema.fundo.opacity(0.55)` + `ScrollView` +
  `VStack(spacing: 16)` + `.padding(28)` + `.frame(maxWidth: 360)`) **e** quatro
  auxiliares (`titulo`, `texto`, `botao`, `botaoMudo`) — `botao`, `botaoMudo` e
  `texto` são **byte a byte** iguais aos de `ConfirmacaoView.swift:125-154`. Isto
  é o idioma de confirmação do app; devia ser **um** componente em
  `Traco/Componentes`, usado pelas duas telas.
- **A defesa do teclado escrita duas vezes**: `DitadoProprioView.onAppear:45` e
  `RaizView.keyboardWillShow:199`. A da raiz é a durável; a da view é redundante.

Veredito da dimensão: o volume é defensável para o que a volta entrega, mas
~55 linhas são duplicata nomeável. **Complexidade 8, Componentes 6.**

## 5. ESTADOS DO G2, AX5 E AS DUAS CORREÇÕES DE PASSAGEM

**Conteúdo das capturas conferido, uma a uma** — todas são telas reais do app,
nenhuma é maquete:

| captura | o que eu vi |
|---|---|
| `f3b-01-gravando` | "Gravando.", 0:04, ponto de nível, Pronto, Descartar |
| `f3b-02-transcrevendo-sobreposto` | o defeito de fade, legítimo (ver abaixo) |
| `f3b-03-falha` | "O áudio ficou." + motivo genérico + Tentar de novo |
| `f3b-04-transcrito` | "Guardado nas Notas." + a letra + "Confira quando puder" |
| `f3b-05-notas-lista` | as notas do ditado na lista real |
| `f3b-06-nota-transcrita` | portal ÁUDIO 135 KB + linha de origem |
| `f3b-07-nota-falha` | portal ÁUDIO **87 KB** + linha honesta |
| `f3b-08-sem-microfone` | "Sem microfone." + "Nada foi gravado" + as duas saídas |
| `f3b-09-escrever-em-vez-disso` | a página em branco com o teclado (05w intacta) |
| `f3b-10-ax5-gravando` | AX5 limpo, tudo visível |
| `f3b-11-ax5-falha` | **cortado** no rodapé; as ações ficam fora da tela |
| `f3b-entrada-*-quadros` | quadros reais da entrada, normal × reduzida |
| `f3b-movimento.mp4` | 9,45 s, 53 KB, lado a lado, dentro do orçamento |

**AX5:** conferi eu mesmo, com `simctl ui content_size
accessibility-extra-extra-extra-large`, e **restaurei para `large` ao fim**
(verificado). As ações **são alcançáveis rolando** — "Tentar de novo" e "Pronto"
aparecem (`f3b-rev-03-ax5-falha-rolado.png`), então não há perda de função. Mas
(a) o relato diz "AX5 sem clipe" e a captura que ele anexa mostra exatamente o
contrário, e (b) ao rolar, o texto passa **por baixo da Ilha Dinâmica e do
relógio**, sem faixa nem inserção — ilegível (visível na minha captura).

**Correção 1 (teclado):** provada. Os quadros de `f3b-entrada-normal-quadros.png`
mostram o teclado descendo enquanto a superfície entra.

**Correção 2 (segundo toque substitui um ditado já terminado):** **sem captura e
sem teste.** É lógica em `RaizView.abrirDitado:214`. Não consigo confirmá-la por
evidência anexada — e, como se vê no achado A2, é justamente nessa vizinhança que
mora um defeito.

**Fade sobreposto:** o defeito é real e a captura é boa evidência — mas ela mostra
**"Áudio guardado." sobre "O áudio ficou."**, não o par "Gravando." / "Áudio
guardado." que a ADR e o comentário de `DitadoProprioView.swift:36-38` nomeiam.

## 6. `Traco/App/Sessao.swift` × a volta F4 — colide?

**No código, não.** `git merge-tree Vitorepf/f3b-ditado Vitorepf/f4-widgets`:
`Auto-merging Traco/App/Sessao.swift` **sem conflito**. A F4 mexe em `agendar`
(~linha 735), a F3b acrescenta `gravarDitado` (~linha 1285). Regiões distantes.

**Nos contratos, sim, e é grave (A3).** As duas voltas declararam a **mesma**
ADR: `## ADR 2026-09-05x — O áudio antes da letra` (F3b) e
`## ADR 2026-09-05x — Os widgets da casa prestam (volta F4)` (F4). O merge-tree
dá `CONFLICT (content)` em **SPEC.md** e **EVOLUCAO.md** (as duas editam a mesma
célula "Fora do app"), e o código da F4 já cita `"ADR 05x"` em comentário para
uma decisão diferente (`Sessao.swift:738` no branch dela). Renumerar é decisão do
orquestrador, mas **tem de acontecer antes do merge**, e o texto dos comentários
de uma das duas voltas vai ter de mudar junto.

---

## Achados por severidade

### ALTO

**A1 — A tela mente quando o disco recusa o depósito.**
`DitadoProprio.swift:155-158` reutiliza `.semMicrofone("não consegui guardar o
áudio.")` para a falha de gravação da NOTA. A view (`DitadoProprioView.swift:90-97`)
desenha então o título **"Sem microfone."** e a linha **"Nada foi gravado — não há
áudio guardado desta vez."** — as duas falsas: o microfone funcionou e o m4a
**está** no disco. A ação principal oferecida é "Abrir os Ajustes", que não
conserta nada. O teste `discoRecusa` (`DitadoProprioTests.swift:108`) **fixa** esse
estado como esperado. Fere `AGENTS.md` ("Não esconder falha para limpar a tela";
"produzido, agendado, realizado e resultado observado são estados distintos") e a
própria ADR ("três estados, três nomes"). Captura da cópia exata:
`f3b-08-sem-microfone.png`.

**A2 — Duas notas, um áudio: a nota do depósito fica mentindo para sempre. REPRODUZIDO NA TELA.**
Passos, dois toques além do comum: começar um ditado, tocar "Pronto", tocar
**"Fechar"** enquanto transcreve, e disparar o controle outra vez antes de a
primeira transcrição voltar. `Sessao.notaDoDitado` é uma única variável chaveada
por `criadaEm` (`Sessao.swift:1288-1298`): quando o segundo ditado deposita,
`notaDoDitado` passa a apontar para ELE, e a transcrição do primeiro, ao chegar,
não encontra "a mesma nota" e **cria uma segunda**. Resultado provado:

- `f3b-rev-06-duas-notas-um-audio.png` — duas notas às 14h51: uma diz
  *"O áudio ficou guardado, sem transcrição."*, e logo acima aparece a nota com a
  letra;
- `f3b-rev-07-nota-duplicada.png` — a nota duplicada aberta, com o **mesmo**
  `ditado 6 set. 14h51.m4a` (101 KB) dentro.

O autor fica com duas entradas para uma fala, uma delas afirmando por escrito que
não há transcrição — quando há, na nota ao lado. Nenhum teste cobre isto.

**A3 — Colisão de número de ADR com a F4** (ver §6). Bloqueia o merge dos dois
branches; a decisão é do orquestrador.

### MÉDIO

**M1 — Sem háptico nas duas trocas que mais importam.** A ADR justifica a troca
seca dizendo que "quem marca a mudança é o háptico e o anúncio". Só há
`Toque.selecao()` ao começar e `Toque.leve()` no depósito
(`DitadoProprio.swift:86,161`). As transições **transcrevendo→transcrito** e
**transcrevendo→semLetra** — exatamente aquelas em que o autor está esperando um
resultado — não têm háptico nenhum. Só o anúncio de VoiceOver.

**M2 — O controle continua se chamando "Anotar", com ícone de escrever.**
`TracoWidget.swift:657`: `Label("Anotar", systemImage: "text.append")`,
inalterado. Depois desta volta a porta abre o **microfone gravando** — confirmei
tocando o controle real na Central de Controle (`f3b-rev-04-controle-central.png`
→ `f3b-rev-05-controle-abre-gravando.png`). A `IntentDescription` foi atualizada;
o rótulo e o ícone que o autor vê, não. `TracoWidget/` estava declarado fora do
escopo — é uma escolha, não uma resolução.

**M3 — "Confira quando puder" sem caminho para conferir.** A tela do transcrito
(`f3b-04`) pede a conferência e oferece só "Pronto". Para corrigir a letra o
autor tem de fechar, ir às Notas e caçar a nota. Falta a ação "Abrir a nota".

**M4 — O contrato promete mais do que o caminho cumpre.** A ADR e a linha do
EVOLUCAO dizem "falha, silêncio ou **app morto** deixam a nota com o áudio
tocável dentro dela". Provado: morto **durante a gravação** não deixa nota
nenhuma e deixa um m4a que não abre (§1). A frase precisa da ressalva "depois do
depósito".

**M5 — A superfície do ditado engole os links profundos.** Com a superfície na
tela, `traco://notas` não navega (observado: a raiz troca a aba por baixo, o
overlay continua cobrindo). Menor, mas é estado preso.

**M6 — Duplicata de componente** (ver §4): a casca e quatro auxiliares da
`ConfirmacaoView` copiados. Nada foi para `Traco/Componentes`. Um `#Preview` só,
para cinco estados.

### BAIXO

- **L1** — `traco://ditar` é público; qualquer app/página abre o Traço gravando
  (visível, nunca silencioso).
- **L2** — `NSSpeechRecognitionUsageDescription` ainda diz "Ditar o compromisso".
- **L3** — O motivo específico ("o português para ditado offline não está
  instalado…") nunca aparece; o simulador sempre cai no genérico.
- **L4** — Relato: `f3b-07` é anunciado com "99 KB"; a captura diz **87 KB**.
- **L5** — AX5: ao rolar, o texto passa por baixo da Ilha Dinâmica sem faixa.
- **L6** — Cada ditado dispara 2–3 projeções completas (backup do corpus +
  reconstrução inteira do domínio Spotlight + índice) em vez de uma. É o padrão
  já existente da casa (`Sessao.swift:1671,1760`), não regressão — só o custo
  conhecido, agora pago duas vezes por fala.
- **L7** — `ferramentas/orca/ESTEIRA.md` **não tem** a seção "Skills obrigatórias
  por portão" citada na ordem do dono de 06/09. O G0 menciona o `design-router`,
  nada mais. O documento está atrás da ordem.

---

## Scorecard — 15 dimensões

| dimensão | nota | evidência e motivo |
|---|---|---|
| Visão | **10** | MULTIPLICAR, fecha a lacuna nomeada "ditado próprio com áudio preservado (F3b)" que o EVOLUCAO listava na coluna do que falta; a linha nova traz lacunas novas e honestas. Diff do EVOLUCAO. |
| Contrato | **8** | ADR curta e coerente com o código; SPEC e EVOLUCAO atualizados. Mas A3 (número 05x colidido com a F4, `CONFLICT` em SPEC.md e EVOLUCAO.md), M4 (a promessa "app morto" excede o provado) e a atribuição errada do par de títulos na captura do fade. |
| Correção | **8** | Suíte **724 testes em 126 suítes, verde**, rodada por mim no 64F7B8B4; `DitadoProprioTests` passa; build dos dois alvos **sem aviso** (os 4 avisos do log são pré-existentes, em `TracoTests/ConferenciaTrabalhoTests.swift`, arquivo que o diff não toca, fora dos dois alvos); Release **0 avisos**. Desconto: a "correção 2" que o relato declara (segundo toque substituindo um ditado terminado) é comportamento novo **sem teste**, e é justamente aí que mora A2, defeito reproduzível na tela; e `discoRecusa` fixa como esperado o estado errado de A1. |
| Jornada real | **9** | Conferi o **conteúdo** das 12 capturas + vídeo, uma a uma: todas são telas reais. Acrescentei os dois caminhos de morte do app e a porta real. Nenhuma captura de arquivo vazio ou maquete. |
| Design | **8** | As seis fases estão citadas **e** se sustentam contra a tela: Sistema confere (zero token novo; os literais 16/28/360 são os mesmos da `ConfirmacaoView`, não invenção), Mover confere (troca seca com o defeito anterior fotografado; entrada respeita Reduzir Movimento). Desconto: a segunda correção de "Julgar" não tem captura nem teste, e L5. |
| Simplicidade | **8** | `curva-zero` citada com as quatro peças exigidas — jornada (um toque → falar → a frase entra), resultado verificável (nota com áudio tocável), atrito observado (a F3 dependia da letra dar certo), recuperação ("Tentar de novo", "Escrever em vez disso") — e as quatro se confirmam na tela. Desconto: M3 (pede conferir e não deixa), M5, e a lista de Notas enche de linhas de máquina idênticas sem título que as distinga (`f3b-rev-06`: cinco linhas quase iguais). |
| Movimento | **8** | Troca seca justificada e provada pelo antes (`f3b-02-…-sobreposto`); entrada com escala+desfoque no normal e só opacidade sob Reduzir Movimento (`f3b-entrada-*`, vídeo 9,45 s / 53 KB); ponto de nível quieto sob movimento reduzido. Desconto: **M1** — o háptico que a ADR aponta como substituto da animação não existe nas duas trocas de resultado. |
| Componentes | **6** | **M6.** Casca + `titulo`/`texto`/`botao`/`botaoMudo` copiados da `ConfirmacaoView` (`:125-154`), três deles idênticos byte a byte; nada extraído para `Traco/Componentes`; um `#Preview` para cinco estados. É exatamente o "sem duplicata" da esteira. |
| Acessibilidade | **8** | Rótulos, `isHeader`, `isModal`, ação de escape, anúncio por estado, `Tema.alvo` (44 pt) em todos os botões, ponto em `@ScaledMetric`. AX5 gravando limpo; AX5 falha **alcançável rolando** (verifiquei: `f3b-rev-03`) — logo, sem perda de função. Desconto: o relato afirma "AX5 sem clipe" e a captura que ele anexa mostra o corte, e L5. Tamanho de texto restaurado para `large`. |
| Performance | **9** | Nenhuma lista, editor ou parser tocado; medidor a 10 Hz é barato; sem hitch observado nas telas dirigidas. L6 é o custo já existente da casa, não regressão. |
| Privacidade e autoria | **9** | `requiresOnDeviceRecognition = true` no código + guard que **recusa** em vez de cair no remoto; zero entitlement novo e zero `UIBackgroundModes` (diff de plists vazio); o áudio nunca entra em `vozDoAutor` (blocos `.audio` caem em `prosa`), logo não vai a Spotlight, índice, busca, widget nem prompt; nada de blob no SwiftData; permissões separadas e a recusa dita na tela. **Ensaio ausente do binário Release, com controle positivo no `Traco.debug.dylib`.** Desconto: L1, L2. |
| Estado honesto | **6** | **A1** (a tela diz "Sem microfone./Nada foi gravado" quando o microfone funcionou e o áudio está no disco) e **A2** (nota que afirma "sem transcrição" com a transcrição na nota ao lado, mesmo áudio — provado em `f3b-rev-06`/`07`). Do lado bom: gravado × transcrito × conferido têm três títulos diferentes, silêncio não vira sucesso, e a falha aparece inteira. |
| Complexidade | **8** | +609 Swift de produção defensáveis para gravador + tela de cinco estados + rota + escritor de nota; ~55 linhas são duplicata nomeável (M6 + a defesa do teclado escrita duas vezes). Nada especulativo; as injeções e o instrumento Debug se pagam. `shortstat`: 29 arquivos, +1012/−10. |
| Fora do app | **8** | A porta funciona de verdade: toquei o controle **na Central de Controle** e o app subiu **gravando** (`f3b-rev-04` → `f3b-rev-05`) — prova que a própria volta não tinha. Desconto: **M2**, o controle continua "Anotar" com ícone `text.append`; a placa promete página, a porta abre microfone. Bloqueada/StandBy seguem nos limites já declarados pela F3. |
| Relato | **9** | Seis linhas equivalentes, legível sem terminal, índice completo das capturas e — o melhor — uma seção "O que NÃO foi possível provar" honesta. Desconto: L4 e a afirmação "AX5 sem clipe" contra a própria captura. |

**Dimensões abaixo de 9 (10 de 15): Contrato (8), Correção (8), Design (8),
Simplicidade (8), Movimento (8), Componentes (6), Acessibilidade (8), Estado
honesto (6), Complexidade (8), Fora do app (8).**
**Em 9 ou mais: Visão (10), Jornada real (9), Performance (9), Privacidade e
autoria (9), Relato (9).**

## O caminho mais curto para 9

1. **A1** — um estado próprio para "o disco recusou" (título e linha verdadeiros;
   e apagar o m4a órfão ou dizer que ele ficou), e corrigir o teste que fixa o
   estado errado. ~15 linhas.
2. **A2** — `notaDoDitado` por ditado, não por sessão: o `DitadoProprio` já
   carrega o próprio `id`; a closure de depósito pode segurar a sua nota. Teste
   com dois ditados sobrepostos. ~15 linhas.
3. **A3** — renumerar uma das duas ADRs 05x (decisão do orquestrador) e alinhar
   os comentários.
4. **M1** háptico nas duas trocas de resultado; **M2** rótulo e ícone do
   controle; **M3** "Abrir a nota"; **M4** a ressalva na frase da ADR e do
   EVOLUCAO; **M6** um componente em `Traco/Componentes` usado pelas duas telas.

## Como rodei

```
xcodegen generate                      # sem drift: o pbxproj commitado bate com project.yml
com-trava.sh xcodebuild test  -destination id=64F7B8B4…   → 724 tests / 126 suites, PASSOU
com-trava.sh xcodebuild build -configuration Release       → BUILD SUCCEEDED, 0 avisos
com-trava.sh maestro --udid 64F7B8B4… test <fluxos de revisão>
xcrun simctl io 64F7B8B4… screenshot   # toda prova de tela é simctl, nunca captura do maestro
```

`maestro/varrer.sh` **não pôde ser usado**: ele recusa rodar com mais de um
simulador ligado, e há sete na máquina. Dirigi por `maestro --udid` sob a trava,
como manda o aviso do dia. O simulador do dono (**iPhone 17 1A46B6D3**) não foi
tocado. O iPhone Air já estava ligado antes de mim; deixei ligado.

---

# Re-G3 — a correção (topo `487a009`)

Mesmo revisor, 06/09/2026, worktree `f3b-ditado`, HEAD **`487a009`**. Simulador:
iPhone Air **64F7B8B4** (já estava ligado quando cheguei; **desligado por mim ao
fim**, conforme a ordem desta rodada). O do dono (**1A46B6D3**) aparece
desligado e **não foi religado nem tocado**. Nada foi editado nem commitado.
Capturas desta rodada: `f3b-reg3-*.png`.

## Veredito

**APROVADO.** Os três altos estão fechados, e eu refiz na tela a corrida que
tinha achado. As duas dimensões que estavam em 6 subiram. Nenhuma regressão
encontrada. **As 15 dimensões ficam em 9 ou mais.** Fica um único pendente de
merge, sem decisão de conteúdo: SPEC.md e EVOLUCAO.md conflitam textualmente
com a F4 (duas ADRs diferentes no mesmo ponto) — guardar as duas, em ordem.

## Aviso de instrumento — leia antes das notas

A máquina está com **sete simuladores ligados** e vários workers rodando maestro
ao mesmo tempo. Achei o mecanismo, e ele **não é do worker**:

- `~/.maestro/tests/2026-09-06_16*/maestro.log` mostra cinco workers escolhendo
  cinco aparelhos diferentes entre 16h37 e 16h39, **todos "using port 7001"**.
- Às 16h48 e às 16h54 o meu maestro registrou `Selected device 64F7B8B4…` e
  ainda assim **falhou** dizendo que "Gravando." não estava visível — enquanto
  `xcrun simctl io 64F7B8B4 screenshot`, tirado no mesmo minuto, mostra
  **"Gravando." na tela** (`f3b-reg3-04-instrumento-maestro-cego.png`). Numa das
  falhas o maestro me devolveu a captura de uma folha de Trabalho com o texto
  "o foco veio para ca", que ninguém deste worktree digitou.
- Ou seja: **`maestro --udid` não isola.** O driver residente de outro
  simulador segura a porta 7001, e o maestro lê a hierarquia do vizinho. O
  `com-trava.sh` serializa comandos, mas **não mata driver deixado para trás**.
- Três comandos meus morreram com `exit 144` sem saída, sempre dentro de uma
  invocação de maestro.

**Consequência metodológica:** nesta rodada eu **não** dei nota com base em
nenhuma evidência do maestro. Toda prova abaixo é `xcrun simctl io … screenshot`
do MEU UDID, arquivo em disco lido por `afinfo`, ou o corpus `.md` do contêiner
do meu simulador. Onde o instrumento me impediu de refazer algo, eu digo — e não
desconto por isso. **Nenhuma nota abaixo caiu por causa da máquina.**

## Os três altos

### A1 — a tela mentia na recusa do disco → **FECHADO**

Cheguei ao estado no meu aparelho por `traco://ditar?ensaio=disco-recusa` e
concluí a gravação **sem maestro**, mandando o app para segundo plano (o que
também reexercita o depósito por `willResignActive`).

`f3b-reg3-02-disco-recusa.png` mostra, na build da árvore atual:

- **"O áudio ficou no aparelho."**
- "Gravei, mas a nota não entrou: o disco recusou."
- "Sem uma nota que o cite, o áudio é apagado em um dia."
- **Tentar de novo** · **Descartar a gravação**

Sumiram "Sem microfone.", "Nada foi gravado" e o "Abrir os Ajustes" que não
consertava nada. E a frase é **verificável**: no mesmo instante, no cofre de
anexos, `32A85405….m4a`, 2 479 882 B, `afinfo` → `estimated duration: 312.31
sec`. Arquivo válido, tocável — o áudio existe, como a tela diz.

O teste virou de lado, como pedido: `discoRecusa` agora exige
`#expect(d.estado == .semDeposito("o disco recusou."))` **e**
`#expect(d.estado != .semMicrofone(...))`. Passa (`✔` no log). `discoVolta` é
novo e prova que a recuperação é o MESMO depósito, com a letra só depois dele.
`descartar()` no estado novo apaga o m4a (`notaCriada == false`), e sair pelo
gesto de escape deixa o arquivo — que é exatamente o que a tela avisa.

### A2 — duas notas para uma fala → **FECHADO, refeito por mim**

Refiz a minha corrida: estado limpo, ditado com `?ensaio=transcrito`, **Pronto**,
**Fechar durante a transcrição**, controle outra vez, **Pronto**. Os mesmos dois
toques.

- Tela: `f3b-reg3-01-corrida-duas-notas.png` — **duas** linhas em Notas, uma por
  fala. Antes eram três.
- E a prova que não depende de pixel: o corpus `.md` do contêiner do meu
  simulador tem **uma nota por ditado**, cada uma com o SEU áudio
  (`39AC843E…` e `44978D86…`, arquivos diferentes) e a sua linha final.
  **Nenhuma** nota dizendo "O áudio ficou guardado, sem transcrição." sobrou.
- No código a causa foi mesmo removida: `Sessao.notaDoDitado` não existe mais;
  `gravarDitado` recebe e devolve a `Nota`, e `armarDitado` fecha um `var minha`
  por ditado que as duas closures dividem. Não há mais chaveamento por `criadaEm`.
- `doisDitadosSobrepostos` roda o segundo ditado inteiro **dentro** da
  transcrição do primeiro e exige `notas.count == 2` — passa.

### A3 — número da ADR → **FECHADO, conferido por mim**

`## ADR 2026-09-06c` no SPEC. Conferi o número contra **todos** os branches
vivos: `06c` não aparece em nenhum outro. `git merge-tree` com a F4, rodado por
mim:

```
Auto-merging Traco/App/Sessao.swift
Auto-merging TracoWidget/TracoWidget.swift
Auto-merging project.yml
Auto-merging Traco.xcodeproj/project.pbxproj
CONFLICT (content): SPEC.md
CONFLICT (content): EVOLUCAO.md
```

Bate com o que ele afirmou. O que sobra é textual (duas ADRs diferentes logo
depois da 05w; a mesma célula "Fora do app" ganhando duas linhas) e resolve-se
guardando as duas. **De passagem, para o orquestrador:** `volta-11-markdown` e
`volta-18-trabalho` declaram **as duas** `ADR 2026-09-06x`. Essa colisão
continua aberta e não é desta volta.

## As duas dimensões que estavam em 6

### Componentes 6 → **9**

`FolhaDeConfirmacao<Chave, Conteudo>` + `enum Folha` carregam a casca (material,
`Tema.fundo` 0,55, `ScrollView`, `VStack(spacing: 16)`, `padding(28)`,
`maxWidth 360`, entrada com escala/desfoque, `isModal`, ação de escape) e as seis
peças. Li o diff da `ConfirmacaoView` linha a linha: é **movimentação fiel** —
nenhum texto, id, ação ou ramo mudou; só saíram os quatro auxiliares
duplicados. `ConfirmacaoView` 119→51, `DitadoProprioView` 98→62, arquivo novo
118 → a duplicata que eu nomeei sumiu.

A tela vizinha não quebrou: `f3bb-06` mostra "Sair agora tranca." inteira na
casca nova, a máquina de estados da confirmação tem cobertura em teste (8
referências, suítes `FechoExpressivaTests`/`QuartoFechoTests` verdes na minha
rodada) e o diff não toca comportamento. **Não pude reexecutar
`maestro/expressiva-trancar.yaml` eu mesmo** pela interferência descrita acima;
digo isso em vez de fingir que rodei.

O `Seca` preserva a troca seca do ditado (`refazerEm` nunca muda → o `onChange`
não dispara), e a `ConfirmacaoView` continua renascendo por assunto. Detalhe
bem resolvido.

**Dois residuais, nomeados, que não bloqueiam:**

- **R1** — o arquivo mora em `Traco/Ditado/`, não em `Traco/Componentes/`. O
  motivo escrito ("a volta 12 está lá dentro") **não se sustenta**: a volta 12
  edita `Botao.swift` e `Cartao.swift`; um arquivo NOVO em `Traco/Componentes/`
  não conflitaria com nada. É mudança de casa da volta seguinte — mas por
  arrumação, não por impedimento.
- **R2** — segue um `#Preview` para seis estados. A justificativa dele ("a regra
  do dono diz que preview não conta") **lê a regra errada**: `RUMO.md:38` diz que
  *captura só no preview do Xcode não conta como prova* — não que preview não
  deva existir; e o critério da própria V10 (`RUMO.md:69`) pede "preview por
  estado". O argumento técnico dele é bom (`estado` é `private(set)`, e abrir o
  tipo só para o Xcode desenhar seria máquina), então isto vai junto com R1 para
  a volta que mudar a casa — mas com a regra citada certa.

### Estado honesto 6 → **9**

Os dois pontos que derrubaram a nota estão fechados e provados acima (A1 e A2).
O terceiro — o app morto **durante** a gravação — ele escolheu corrigir o
contrato. **Julgo a escolha correta, e não é baixar a barra**, por três razões
verificáveis:

1. O texto novo **nomeia o mecanismo**, não o esconde: só o `stop()` fecha o
   átomo final do m4a, e sem ele o arquivo não é áudio. Isso é exatamente o que
   eu medi no G3 (`afinfo` → `AudioFileOpenURL failed`). O contrato passou a
   descrever o que a máquina faz.
2. **Distingue os dois casos** em SPEC e em EVOLUCAO: "depois do depósito"
   preserva; "durante a gravação" não vira nota. A promessa larga que eu tinha
   apontado sumiu das duas fontes.
3. **Diz o preço da alternativa** (gravação em segmentos) e por que não a paga,
   com o caminho real já coberto pelo `willResignActive` — que eu reexercitei
   nesta rodada sem querer, ao concluir dois ditados mandando o app para o
   fundo.

Contrato que descreve o limite é melhor que código que finge não ter limite.

## Regressões — procurei, não achei

- **Suíte:** `727 testes em 126 suítes, PASSOU`, rodada por mim no 64F7B8B4. Os
  quatro testes novos/mudados aparecem verdes por nome no log.
- **Avisos:** os mesmos **dois** de sempre, pré-existentes, em
  `TracoTests/ConferenciaTrabalhoTests.swift` (arquivo que o diff não toca).
  Nenhum aviso novo veio da extração da casca. **Release: 0 avisos.**
- **Ensaio fora do Release, com o ramo novo:** `ensaioDoDitado` 0, `disco-recusa`
  0, a frase do ensaio 0 no binário Release; 2, 1 e 1 no `Traco.debug.dylib`.
  Controle positivo funcionando, ausência real.
- **`xcodegen generate`** não move o pbxproj commitado.
- **Origem/autoria não se perdeu no caminho novo.** `f3bb-03` (a nota aberta por
  "Abrir a nota") não mostra a linha de origem, e isso me preocupou. Fui ao dado:
  os três `.md` do corpus no meu simulador terminam todos com
  `Ditado de 6 de setembro, 16h54, transcrito no aparelho. Confira.` — a linha
  **está na nota**. `Sessao.abrir` faz `texto = nota.texto`, verbatim. Era a
  captura, não o dado. Cheguei ao estado transcrito com "Abrir a nota" na tela
  pelo meu próprio caminho: `f3b-reg3-03-transcrito-abrir-nota.png`.
- **`.mask` nova na casca:** aplicada ao `ScrollView` das DUAS telas. Em repouso
  o esmaecido cai dentro do respiro de 28 pt e não se lê (confirmado em
  `f3bb-06` e nas minhas capturas). Fica a observação de que máscara afeta hit
  testing em SwiftUI: a faixa de 3 % no topo é área de respiro nas duas telas
  hoje, mas quem puser ação ali no futuro vai encontrá-la surda.

## Scorecard revisto

| dimensão | G3 | Re-G3 | o que mudou |
|---|---|---|---|
| Visão | 10 | **10** | inalterada |
| Contrato | 8 | **9** | A3 fechado (06c único, merge-tree conferido por mim); M4 corrigido com o mecanismo escrito. Resta a atribuição errada do par de títulos na captura do fade — ver R3. |
| Correção | 8 | **9** | 727/126 verde na minha máquina; `discoRecusa` passou a **proteger a verdade**; `doisDitadosSobrepostos` reproduz a corrida; o caminho do "segundo toque" agora tem a minha prova de tela. |
| Jornada real | 9 | **9** | oito capturas novas, conteúdo conferido; `f3bb-01` está **desatualizada** (copy de iteração anterior) — reposta pela minha `f3b-reg3-02`. Ver R4. |
| Design | 8 | **9** | L5 resolvido e provado; a "correção 2" de Julgar agora tem evidência de tela (a minha corrida). |
| Simplicidade | 8 | **9** | M3 entregue e visto por mim; M5 deixado com motivo honesto (é roteamento da raiz, não do ditado). Segue aberta a observação da lista de Notas com linhas de máquina iguais — é a fila de transcrição que já está em "Fora (F3b+)". |
| Movimento | 8 | **9** | M1 fechado nas quatro trocas de resultado (`Toque.fechou()` no transcrito, `Toque.aviso()` em toda falha); troca seca preservada pelo `Seca`. |
| Componentes | **6** | **9** | duplicata apagada, uma casca para duas telas, vizinha intacta. R1 e R2 seguem, nomeados. |
| Acessibilidade | 8 | **9** | L5 fechado com máscara no topo e provado em AX5 (`f3bb-05`, copy atual, as duas ações alcançáveis, nada sob a Ilha); a linha falsa "AX5 sem clipe" corrigida no relato. |
| Performance | 9 | **9** | inalterada; nada novo em lista, editor ou parser. |
| Privacidade e autoria | 9 | **9** | contrato intacto; ensaio (com o ramo novo) ausente do Release com controle positivo; L2 corrigido — a permissão de fala agora fala do ditado e diz que o áudio não sai. Origem preservada, verificada no corpus. |
| Estado honesto | **6** | **9** | A1 e A2 fechados e provados na tela e no dado; o contrato do app morto passou a dizer a verdade. |
| Complexidade | 8 | **9** | −55 linhas de duplicata; a defesa do teclado escrita duas vezes virou `Teclado.recolher()` (que já existia); líquido +92 numa rodada que acrescentou um estado, uma costura de teste, três testes, háptico e uma ação. |
| Fora do app | 8 | **9** | M2 fechado: "Ditar" com `mic.fill`, `kind` preservado — decisão certa, trocá-lo apagaria o controle que o autor já instalou. |
| Relato | 9 | **9** | o relato da correção é honesto e lista o que não fez e por quê. Ver R4. |

**Todas em 9 ou mais.** Nenhuma dimensão bloqueia.

## Residuais (nenhum bloqueia o merge)

- **R1** — `FolhaDeConfirmacao` mora em `Traco/Ditado/`; a casa é
  `Traco/Componentes/`, e o motivo escrito não se sustenta para arquivo novo.
- **R2** — um `#Preview` para seis estados; a regra citada (`RUMO.md:38`) fala de
  prova, não de existir preview, e a V10 pede preview por estado.
- **R3** — a ADR ainda diz que o fade sobrepunha "Gravando." e "Áudio guardado."
  citando `f3b-02-transcrevendo-sobreposto.png`; a captura mostra "Áudio
  guardado." sobre "O áudio ficou.". Erro de citação, não de contrato.
- **R4** — `f3bb-01-disco-recusa.png` traz copy de iteração anterior ("não
  consegui criar a nota: o disco recusou a nota"), diferente da build final. A
  atual é `f3b-reg3-02-disco-recusa.png`; vale trocar no índice da ADR.
- **R5** — a máscara do topo da folha afeta hit testing: hoje a faixa é respiro
  nas duas telas, mas ação colocada ali no futuro fica surda.
- Seguem abertos, com motivo aceito: **M5** (o ditado engole `traco://notas`),
  **L1**, **L3**, **L6**, **L7**.

## Para o G5

Único pendente: o conflito textual com a F4 em SPEC.md e EVOLUCAO.md — guardar
as duas ADRs (06c e 05x), em ordem, e as duas linhas na célula "Fora do app".
Não há decisão de conteúdo pendente. Código e `project.yml` fazem auto-merge.

## Como rodei

```
xcodegen generate                                          # sem drift
com-trava.sh xcodebuild test  -destination id=64F7B8B4…     → 727 testes / 126 suítes, PASSOU
com-trava.sh xcodebuild build -configuration Release        → BUILD SUCCEEDED, 0 avisos
git merge-tree --write-tree f3b-ditado f4-widgets           → só SPEC/EVOLUCAO conflitam
xcrun simctl io 64F7B8B4… screenshot                        # TODA prova de tela
xcrun simctl openurl / launch                               # navegação, por causa do maestro cego
afinfo <cofre>/*.m4a                                        # o áudio que a tela diz existir
cat <contêiner>/Documents/notas/*.md                        # uma nota por ditado, com a origem
```

Tamanho de texto do meu simulador: `large`, não mexi nesta rodada. **Simulador
iPhone Air desligado ao terminar**, como a ordem pediu; nenhum outro tocado.

**Nota de fecho sobre a máquina:** ao desligar o meu iPhone Air, contei os
ligados. O **iPhone 17 Pro Max (6033B043)**, que estava ligado no começo desta
rodada, **também sumiu da lista sem que eu o tocasse** — mesmo padrão do
simulador da F3b e do aparelho do dono. Confirma o aviso: há algo externo
desligando simuladores nesta máquina. Nenhuma nota deste relatório depende de
evidência perdida por isso.
