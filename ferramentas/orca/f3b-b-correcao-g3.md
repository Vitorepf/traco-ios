# F3b-B — a correção do G3 (ditado próprio)

Trilha **Fora do app**, worktree `f3b-ditado`, sobre `fa0cf53`. Simulador de
teste: **iPhone Air 64F7B8B4**. Todo `xcodebuild` e todo `maestro` por
`ferramentas/orca/com-trava.sh`; toda captura por `xcrun simctl io screenshot`.

## As seis linhas

1. A tela parou de mentir quando o disco recusa: o estado tem nome próprio, diz
   que o áudio existe, o que falhou e o que dá para fazer — e o teste que fixava
   a mentira passou a exigir a verdade.
2. Dois ditados sobrepostos não fazem mais nota órfã + duplicata: cada ditado
   carrega a SUA nota até o fim, e há teste que reproduz a corrida.
3. A ADR virou **2026-09-06c** em toda citação (código, SPEC, EVOLUCAO, maestro).
4. A casca de confirmação é uma só: `FolhaDeConfirmacao` + `Folha`, usada pelo
   ditado e pela `ConfirmacaoView` — 55 linhas de duplicata apagadas.
5. O contrato passou a dizer a verdade sobre o app morto DURANTE a gravação, em
   vez de prometer o que o gravador em primeiro plano não cumpre.
6. O controle da Central de Controle é "Ditar", com microfone — e o toque real
   nele abre o app gravando.

## Os três altos

### A1 — a tela mentia na recusa do disco

`DitadoProprio.Estado` ganhou `.semDeposito(String)`. Ao recusar, a tela agora
diz **"O áudio ficou no aparelho."**, "Gravei, mas a nota não entrou: o disco
recusou.", "Sem uma nota que o cite, o áudio é apagado em um dia." e oferece
**Tentar de novo** (redeposita o MESMO arquivo, sem regravar) e **Descartar a
gravação**. Antes: "Sem microfone." / "Nada foi gravado" / "Abrir os Ajustes",
com o microfone funcionando e o m4a no disco.

- Prova de tela: `f3bb-01-disco-recusa.png`.
- Prova de que o áudio EXISTE no instante dessa tela: o m4a no cofre de anexos,
  `afinfo` → `estimated duration: 107.55 sec`, arquivo válido. A frase da tela
  é verificável.
- O teste `discoRecusa` deixou de fixar `.semMicrofone` e passou a exigir
  `.semDeposito` **e** a negar `.semMicrofone`. `discoVolta` é novo: prova que
  a recuperação é o mesmo depósito e que a letra vem depois dele.

### A2 — dois ditados, um áudio, uma nota órfã

Causa, como o revisor nomeou: `Sessao.notaDoDitado` era uma variável só. Ela
foi **apagada**. `gravarDitado` passou a receber e devolver a nota
(`nota anterior: Nota?` → `Nota?`), e `Sessao.armarDitado(_:no:)` dá a cada
ditado uma caixa própria que as duas closures dele dividem. Nada mais é
chaveado por `criadaEm`.

- Teste `doisDitadosSobrepostos`: o segundo ditado inteiro corre DENTRO da
  transcrição do primeiro; a suíte exige duas notas, cada uma com o seu áudio e
  a sua letra, e **nenhuma** dizendo "O áudio ficou guardado, sem transcrição."
- Prova de tela: `f3bb-04-corrida-duas-notas.png` — os mesmos dois toques do
  revisor (Pronto → Fechar durante a transcrição → controle outra vez) deixam
  **duas** linhas em Notas, uma por fala, não três.

### A3 — número da ADR

`2026-09-05x` → **`2026-09-06c`** em SPEC.md, EVOLUCAO.md, `maestro/`, e em
todos os comentários de `Traco/`. `grep -rn "05x"` em `*.swift` e `*.yaml`:
zero. O 05x fica com a volta 16, já mesclada, e a F4 mantém o dela.

`git merge-tree Vitorepf/f3b-ditado Vitorepf/f4-widgets` depois da correção:
`Traco/App/Sessao.swift`, `TracoWidget/TracoWidget.swift`, `project.yml` e o
pbxproj **auto-merge limpo**. Sobra CONFLICT em SPEC.md e EVOLUCAO.md — mas já
não é a colisão de número: são duas ADRs DIFERENTES (06c e 05x) acrescentadas
logo depois da 05w, e a mesma célula "Fora do app" ganhando duas linhas. Resolve
guardando as duas, em ordem; não há decisão de conteúdo pendente.

## As duas dimensões abaixo de 7

**Componentes (6).** `FolhaDeConfirmacao<Chave, Conteúdo>` carrega a casca
(material, tinta 0,55, `ScrollView`, `VStack(spacing: 16)`, `padding(28)`,
`maxWidth 360`, a entrada com escala/desfoque, `isModal`, ação de escape); o
enum `Folha` carrega `titulo`, `texto`, `meta`, `botao`, `botaoMudo` e
`botaoDestrutivo`. A `ConfirmacaoView` renasce a cada assunto (`refazerEm:
estado`); o ditado passa `Seca`, que nunca muda — a troca dele continua seca,
como a ADR decidiu. `ConfirmacaoView` encolheu 119→51 linhas, `DitadoProprioView`
98→62; o arquivo novo tem 118. **Mora em `Traco/Ditado/` por ordem do dono** —
a casa certa é `Traco/Componentes/`, e a volta 12 está lá dentro; a mudança de
casa fica para ela. Prova de que a extração não mexeu na confirmação:
`f3bb-06-confirmacao-mesma-folha.png` (tela real de "Sair agora tranca.").

**Estado honesto (6).** Além do A1: escolhi **corrigir o contrato**, não o
código, para o app morto DURANTE a gravação. Motivo escrito na ADR: o
`AVAudioRecorder` só fecha o átomo final do m4a no `stop()`, e sem ele o
arquivo não é áudio; cobrir uma morte violenta em primeiro plano exigiria
gravação em segmentos — muito código para um caso que o autor não produz,
enquanto o caminho real (sair do app) já deposita pelo `willResignActive`, e a
varredura de órfãos apaga o arquivo parcial. SPEC e EVOLUCAO agora dizem
"depois do depósito" e nomeiam o limite.

## Os médios e baixos

| item | o que foi feito |
|---|---|
| **M1** háptico | `Toque.fechou()` no transcrito, `Toque.aviso()` em toda falha (inclusive a recusa do disco). |
| **M2** rótulo do controle | `Label("Ditar", systemImage: "mic.fill")`, `displayName("Ditar")`, descrição nova. O `kind` NÃO mudou — é a chave do controle já instalado. Prova: `f3bb-07-controle-microfone.png` (Central de Controle real) → `f3bb-08-controle-abre-gravando.png`. |
| **M3** "Abrir a nota" | Ação nova no estado transcrito; leva à página COM a nota, áudio dentro. `f3bb-02` → `f3bb-03`. |
| **M4** contrato | Ver acima. ADR + EVOLUCAO. |
| **M6** duplicata | Ver acima. A defesa do teclado escrita duas vezes também caiu: sobrou `Teclado.recolher()` em `abrirDitado` + o `keyboardWillShow` durável da raiz. |
| **L2** permissão de fala | `NSSpeechRecognitionUsageDescription` passou a falar do ditado, não do compromisso. |
| **L4** relato | `f3b-07` corrigido para 87 KB. |
| **L5** AX5 sob a Ilha | A folha esmaece o topo do rolamento: a linha some antes de chegar à Ilha e ao relógio. Prova: `f3bb-05-ax5-disco-recusa-rolado.png` — as duas ações alcançáveis rolando, nada ilegível sob a Ilha. Também encurtei a copy do estado novo. |
| **relato AX5** | A linha "AX5 sem clipe" do `f3b-ditado.md` foi corrigida contra a própria captura. |

### O que NÃO fiz, e por quê

- **M5 — o ditado engole `traco://notas`.** Deixei. É estado preso de um
  overlay modal, e resolvê-lo mexe no roteamento da raiz, não no ditado; a
  volta já entrou pedindo para encolher.
- **L1 — `traco://ditar` é esquema público.** Deixei: fechar o esquema é
  decisão de contrato do dono, não conserto de defeito, e a gravação é
  totalmente visível (tela cheia + indicador do iOS).
- **L3 — o motivo específico do modelo offline nunca aparece.** É comportamento
  do simulador (cai no ramo genérico), não do código; o guard específico está
  lá e o revisor confirmou.
- **L6 — 2–3 projeções por ditado.** É o padrão já existente da casa, não
  regressão desta volta.
- **L7 — `ESTEIRA.md` sem a seção "Skills obrigatórias por portão".** Documento
  do dono; não escrevo ordem em nome dele.
- **`#Preview` por estado.** Não criei: `estado` é `private(set)`, e abrir o
  tipo só para o Xcode desenhar seria máquina para uma prova que não vale — a
  regra do dono diz que preview não conta. A prova são as capturas do simctl.

## design-router — as seis fases

- **Ancorar.** Redesenho parcial: comecei pela auditoria do revisor (15
  dimensões com evidência) e pelas capturas `f3b-rev-*`, não por tela nova.
  Pessoa e situação: o autor que falou na rua e quer a frase guardada; o
  resultado observável é uma nota com áudio tocável.
- **Sistema.** Zero token novo. Os literais 16/28/360 saíram de duas cópias e
  viraram uma definição em `FolhaDeConfirmacao`; tipografia e cor continuam
  `Tema.confirmacaoTitulo`, `Tema.confirmacaoCorpo`, `Tema.meta`, `Tema.alvo`.
- **Construir.** O estado novo usa as peças existentes (`Folha.titulo`,
  `texto`, `meta`, `botao`, `botaoMudo`) — nenhum componente inventado.
- **Mover.** A troca continua seca (a ADR argumenta por quê, e o defeito de
  fade está fotografado). O que faltava era o háptico que a ADR nomeava como
  substituto: agora existe. O esmaecido do topo é máscara estática, não
  animação decorativa.
- **Julgar.** Todo estado novo foi ao simulador, em tamanho normal e AX5, e a
  tela do vizinho (`ConfirmacaoView`) foi conferida por captura para provar que
  a extração não a mexeu.
- **Portão.** Dois alvos sem aviso, Release sem aviso, suíte 727/126 verde,
  `maestro/ditado-proprio.yaml` verde ponta a ponta.

## curva-zero — a jornada

- **Jornada:** um toque no controle → falar → "Pronto" → a frase entra nas
  Notas com o áudio dentro.
- **Resultado verificável:** a nota existe com o portal ÁUDIO tocável — e agora
  o autor chega nela em um toque a partir da própria superfície (`f3bb-03`).
- **Atrito observado (pelo revisor, na tela):** (a) quando o disco recusava, a
  tela mandava o autor aos Ajustes do microfone, que não conserta nada e não
  era o problema; (b) a tela pedia conferência sem caminho para conferir; (c)
  dois toques no controle produziam duas entradas para uma fala, uma delas
  afirmando por escrito que não havia transcrição.
- **Recuperação:** "Tentar de novo" nos dois pontos de falha (letra e
  depósito), "Descartar a gravação" quando o autor decide não insistir,
  "Escrever em vez disso" quando não há microfone. Nenhum caminho termina sem
  saída, e nenhum deles apaga trabalho sem o autor pedir.

## Como rodei

```
xcodegen generate
com-trava.sh xcodebuild build -scheme Traco        -destination id=64F7B8B4…  → 0 avisos
com-trava.sh xcodebuild build -scheme TracoWidget  -destination id=64F7B8B4…  → 0 avisos
com-trava.sh xcodebuild build -configuration Release                          → 0 avisos
com-trava.sh xcodebuild test  -scheme Traco        -destination id=64F7B8B4…  → 727 testes / 126 suítes, PASSOU
com-trava.sh maestro --device 64F7B8B4… test maestro/ditado-proprio.yaml      → verde (38 passos)
com-trava.sh maestro --device 64F7B8B4… test maestro/expressiva-trancar.yaml  → verde (a folha extraída)
xcrun simctl io 64F7B8B4… screenshot   # toda captura
xcrun simctl ui 64F7B8B4… content_size accessibility-…-large  → restaurado para `large` ao fim (verificado)
```

O instrumento de ensaio continua fora do Release, com o ramo novo incluído:
`ensaioDoDitado` = 2 no `Traco.debug.dylib` e **0** no binário Release;
`disco-recusa` = 1 no debug e **0** no Release; a frase do ensaio, 1 e **0**.
Controle positivo funcionando, ausência real.

## Índice das capturas

| captura | o que mostra |
|---|---|
| `f3bb-01-disco-recusa.png` | A1: a tela nova, com o m4a de 107 s no disco no mesmo instante |
| `f3bb-02-transcrito-abrir-nota.png` | M3: "Abrir a nota" ao lado de "Pronto" |
| `f3bb-03-nota-aberta-para-conferir.png` | a nota aberta, com a letra e o portal ÁUDIO (91 KB) |
| `f3bb-04-corrida-duas-notas.png` | A2: os dois toques do revisor deixam DUAS notas, não três |
| `f3bb-05-ax5-disco-recusa-rolado.png` | AX5 rolado: as duas ações alcançáveis, nada sob a Ilha |
| `f3bb-06-confirmacao-mesma-folha.png` | a `ConfirmacaoView` na casca extraída, intacta |
| `f3bb-07-controle-microfone.png` | M2: o controle na Central de Controle, com microfone |
| `f3bb-08-controle-abre-gravando.png` | o toque real nele abre o app gravando |

## Contas da volta

`git diff --shortstat` desta correção: 17 arquivos, **+372 / −280** — líquido
+92, num pedido que cobrava encolher. O Swift de produção ficou em +299/−259.
As 55 linhas de duplicata que o revisor nomeou foram apagadas; o que entrou é o
estado novo (A1), a identidade por ditado (A2), o háptico, "Abrir a nota" e os
três testes que provam tudo isso.
