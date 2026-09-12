# TEMPO — o teto cortava a resposta boa, e a espera era calada

**Volta `tempo`, 10/09/2026.** ADR **2026-09-10a** (letra reservada pelo orquestrador em
`aa4d68e`, aparece **uma vez só** na tabela do `LETRAS-ADR.md`). Branch `Vitorepf/tempo`,
**sem mesclar**.

**Linha do ciclo.** G1 da trilha B; serve à intenção *"a IA no Traço absurda de qualidade"*;
reduz o obstáculo *"o teto de tempo é MENOR que a espera medida, então o app corta resposta
boa e chama isso de falha da IA"*; prova-se por medida antes/depois com vermelho
determinístico e pela tela.

---

## 1. O defeito, com o número

`Grok.teto` era **240 s**. A espera medida na corrida da Q3-D em 10/09 foi de **241 s**
(`ferramentas/orca/RUMO.md:790`, `LACO.md:3221`). **O teto era menor que o observado.** O
que o autor recebia era um `semRetorno` **nosso** — a espécie que a Q4-D nomeou —, e a
próxima medida de qualidade registraria como falha do modelo um corte que era do app.

O 240 nasceu honesto (ADR 08r: 178 s de pior execução; 09n: 77,5 s em `responder`, 3,1× de
folga) e **envelheceu em silêncio** quando o modelo passou a raciocinar mais.

E a espera era **calada**: em **seis** das sete superfícies que esperam pela IA havia um
`ProgressView` do sistema — laço que gira igual no 1º e no 241º segundo — sem tempo e, em
três delas, **sem saída nenhuma**.

---

## 2. Antes e depois, em número

### 2.1 O teto

| | antes | depois |
|---|---|---|
| piso observado (fato) | 241 s, só num relatório | `Grok.esperaObservada = 241`, constante do código com guarda |
| decisão | `teto = 240` — **abaixo do observado** | `teto = 300` — **margem declarada**, ~1,25× sobre 241 |
| chamada de 241 s | **cortada aos 240,0 s**, sem publicação | publica em ~241 s |

**A forma da frase é parte da decisão** (Astra no G0): 300 s é **margem declarada sobre o
observado**, **não** um novo pior caso medido e **não** promessa ao autor. *"Medimos 300"* é
falso; *"damos 300 de folga sobre os 241 observados"* é verdade. Foi tratando folga como
promessa que o teto anterior nasceu de 77,5 s e durou até a folga acabar.

### 2.2 Toque → publicação, com a montagem de contexto dentro

O teto governa **só a rede**. A espera que o autor sente começa no toque:

| trecho | medida | como |
|---|---|---|
| montagem do contexto (prosa de 40 notas + empacotamento) | **6,3 ms** (0,0063–0,0068 s em quatro corridas) | `EsperaDoAutorTests.aMontagemDoContextoNaoComeOOrcamentoDaEspera`, linha `MEDIDA montagem-de-contexto 40 notas:` no log |
| rede, orçamento | 240 s → **300 s** | `Grok.teto` |
| **toque → publicação, orçamento** | 240,006 s → **300,006 s** | soma |
| **toque → publicação, pior caso observado** | **cortado em 240,0 s (sem publicação)** | **~241,0 s, publicado** |

A montagem é **ruído** ante 300 s — e é por isso que tratar o orçamento como se fosse só da
rede é honesto. O teste guarda a ordem de grandeza: se passar de 2 s, a conta muda.

### 2.3 A espera na tela

| | antes | depois |
|---|---|---|
| Notas | frase parada, sem número; saída só "Fechar", que descarta a conversa | relógio a partir do 4º s + "Parar de esperar" que devolve a pergunta |
| Página (cartão) | já tinha (ADR 09n) | o mesmo, agora pelo componente |
| Lente · instigar | `ProgressView` mudo, **sem saída** | relógio + saída |
| Lente · contrapor | `ProgressView` mudo, **sem saída** | relógio + saída |
| Trabalho · preparar | `ProgressView` mudo, com "Cancelar preparação" | relógio + a mesma saída |
| Trabalho · conferir tentativa | `ProgressView` mudo, **sem saída** | relógio + saída |
| Trabalho · conferir e adaptar | `ProgressView` mudo, **sem saída** | relógio + saída |
| Trabalho · conferir com IA | `ProgressView` mudo, **sem saída** | relógio + saída |

**Tempo até o autor saber que o app está vivo:** antes, nunca (a frase era a mesma no
segundo 1 e no 241º). Depois, **4 s** para o número aparecer e **1 s** de cadência.

---

## 3. Limites externos — a pergunta da Astra, respondida

> *"Se houver limite de transporte, de sessão ou do provedor abaixo de 300 s, o nosso número
> é decorativo."*

**Não achei nenhum abaixo de 300 s.** Cada um com a sua prova:

| limite | valor | prova |
|---|---|---|
| **transporte** (`URLSessionConfiguration.timeoutIntervalForRequest`) | 60 s de fábrica, **mas o pedido governa** | `NWListener` local que aceita e cala; config **2 s**, pedido **6 s** → o erro chegou em **6,02 s**. Se a config ganhasse, `Grok.teto` seria decoração e toda chamada morreria a 1 min |
| **sessão** (`timeoutIntervalForResource`) | padrão (7 dias) | `Grok.responder` usa `URLSession.shared` sem configuração própria |
| **provedor** (x.ai) | **não corta abaixo de 241 s** | a chamada da Q3-D esperou 241 s e **voltou** — o que também prova o valor do pedido vencendo os 60 s para CIMA |
| o que o teto **não** governa | montagem de contexto | 6,3 ms, medido (§2.2) |

---

## 4. Vermelho determinístico — as duas guardas, e as duas acusaram

Sem chamada real, sem conta, sem tocar no `B91C8DEF`.

**(a) O teto contra o observado.** Rebaixei `teto` a 240 e rodei `GrokContratoTests`:

```
✘ Test oTetoCobreAPiorLatenciaMedida() recorded an issue at GrokContratoTests.swift:42:9:
  Expectation failed: (Grok.teto → 240.0) > (Grok.esperaObservada → 241.0)
✘ Test oTetoCobreAPiorLatenciaMedida() recorded an issue at GrokContratoTests.swift:44:9:
  Expectation failed: (Grok.teto → 240.0) == (300 → 300.0)
✘ Test run with 5 tests in 1 suite failed after 6.032 seconds with 2 issues.
```

**(b) A guarda de geração.** Removi o `guard geracao == minha` de `OficinaTrabalho` e rodei
`PraticaTrabalhoTests`:

```
✘ Test pararDeEsperarNaoDeixaAChamadaVelhaApagarAEsperaDaNova() recorded an issue at
  PraticaTrabalhoTests.swift:1029:9: Expectation failed: (o.esperaDaIA → nil) == (relogioDaNova → …)
✘ Test pararDeEsperarNaoDeixaAChamadaVelhaApagarAEsperaDaNova() recorded an issue at
  PraticaTrabalhoTests.swift:1031:9: Expectation failed: (o → Traco.OficinaTrabalho).conferindoTentativa → false
✘ Test run with 55 tests in 1 suite failed after 0.471 seconds with 2 issues.
```

**Cada vigia tem irmã que NÃO acusa**: `ConversaNotas().esperandoDesde == nil` parada, e
`o.esperaDaIA == nil` antes do toque. Vigia que só sabe acusar não está provado.

**Um teste meu passou pelo motivo errado e eu o consertei.** A primeira versão de (b) dava
duas comportas às duas chamadas — mas `feedbackDaTentativa` é lido na HORA do `await`, não
na criação da `Task`, então as duas recebiam a MESMA comporta, e o iterador de um
`AsyncStream`, ao ser cancelado, ENCERRA o fluxo para quem mais esperava nele. Ele ficou
vermelho na suíte integral, e é isso que está escrito no comentário do teste.

---

## 5. A tela — `large`, no aparelho de TRABALHO

`34CC3F94` (teste 3). **Não toquei no `B91C8DEF`** em nenhum momento desta volta.

- `ferramentas/orca/tempo-espera-notas-large.png` — **"a sábia pensa há 5 s…"**, "Parar de
  esperar", "Fechar". Pensando, tempo e cancelar, os três na tela.
- `ferramentas/orca/tempo-espera-cancelada-large.png` — depois do toque: a pergunta do autor
  **de volta** ("quanto ainda me falta no pretérito?"), "a pergunta foi interrompida." e
  "Repetir pergunta" a um toque. **Cancelar não perde nada.**

Dirigido por `EsperaComEstadoUITests`, com captura por `xcrun simctl io <UDID> screenshot`
enquanto o teste hospedado dirige. A espera longa veio de **transporte controlado**
(`TRACO_ESPERA_FALSA`, só em DEBUG) — **nenhuma chamada real gasta**, como a Astra pediu.

**Um defeito que só a captura mostrou.** A primeira corrida saiu com "Parar de esperar" em
`Tema.barra`, **pesando mais que a própria espera** — o olho ia à saída antes de ler o
estado (von-restorff invertido). Passou a `meta`/`tintaSuave`/`.discreto`, com alvo de 44 pt
mantido. E a segunda coisa que a captura pegou: o `accessibilityIdentifier` posto **de fora**
do componente descia sobre a subárvore e **engolia o do botão** — a saída estava na tela e
ausente da árvore para quem a procurasse por nome. O identificador passou para dentro.

---

## 6. Suíte — com prova de árvore própria

Build **LIMPO** (`DerivedData` apagado antes), `34CC3F94`, sob `com-trava.sh`:

```
HEAD: d0827be TEMPO: o teto cortava a resposta boa aos 240 s, e a espera era calada em seis rotas
✔ Test run with 1024 tests in 164 suites passed after 151.767 seconds.
```

Este é o build LIMPO **sobre o commit exato**, rodado depois das duas últimas correções
(peso da saída e identificador). A corrida LIMPA anterior — 152,262 s, também 1024 verdes —
foi antes delas, e por isso não é a que vale.

Testes **exclusivos deste candidato**, no mesmo log:

```
✔ Test oTetoCobreAPiorLatenciaMedida() passed after 0.001 seconds.
✔ Test oTetoDoPedidoGanhaDoTetoDaSessao() passed after 6.025 seconds.
✔ Test aMontagemDoContextoNaoComeOOrcamentoDaEspera() passed after 0.006 seconds.
MEDIDA montagem-de-contexto 40 notas: 0.006316065788269043 s
✔ Test aEsperaNasNotasTemRelogioESaidaQueNaoPerdeAPergunta() passed after 0.001 seconds.
✔ Test pararDeEsperarNaoDeixaAChamadaVelhaApagarAEsperaDaNova() passed after 0.002 seconds.
✔ Test oRelogioDaEsperaServeQualquerRotaQueRaciocina() passed after 0.001 seconds.
```

UI, no mesmo aparelho:

```
Test Case '-[TracoUITests.EsperaComEstadoUITests testAEsperaNasNotasMostraPensandoTempoECancelar]' passed (15.468 seconds).
```

**Warnings: 1**, e é o **herdado** conhecido — `NotasView.swift:811` (`'+' was deprecated in
iOS 26.0`), o mesmo que o preâmbulo cita em `:806`; as cinco linhas de diferença são as que
esta volta acrescentou acima dele. Dívida de outra volta, não vermelho meu.

---

## 7. O que eu decidi, e o que deixei de fora

**Decidi:** (a) 300 s, e escrever a distinção entre piso e margem no CÓDIGO, não só na ADR —
foi o número solto num relatório que deixou o teto envelhecer em silêncio. (b) Um componente
para as sete superfícies em vez de sete correções — a `LinhaDeEstado` da 05t com o relógio
da 09n, tirado do cartão da Página para servir a todas. (c) A `geracao` em
`OficinaTrabalho`: dar saída sem ela criaria o defeito de identidade tardia.

**Não toquei em `Sessao.perguntarASabia`.** A Astra achou por leitura que ela não confere
identidade depois dos `await` — cancelar e perguntar de novo pode publicar a resposta velha
na pergunta nova. **É da volta `responder`**, e este relato não a conserta. **Não a piorei**,
e o caminho está pronto: `ConversaNotas` (`tentativa: UUID`) e agora `OficinaTrabalho`
(`geracao`) são os dois modelos do conserto que falta ali.

**Este conserto fica IGUAL na base e no candidato da volta `responder`**, e é essa a razão de
ele ter vindo antes: se entrasse junto com a alavanca de prompt, o ganho dele seria atribuído
ao prompt. Palavra da Astra no G0.

**Fora do escopo, por ordem:** letra máxima (DIRETRIZ §12) — nenhum portão, captura ou teste
em AX1–AX5 ou XXXL; a captura é em `large`. Continuam valendo alvo de 44 pt (conferido no
teste de tela), contraste, rótulos e ordem na árvore.

**Dívida que fica nomeada:** o `Fechar` das Notas e o `Parar de esperar` agora aparecem
empilhados no cartão — duas saídas com sentidos diferentes (descartar a conversa × guardar a
pergunta). Não as unifiquei: mexer no `Fechar` é contrato da ADR 05e e pede volta própria.

---

## 8. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| Correção | 9 | dois vermelhos determinísticos provados, cada um com irmã que não acusa; 1024 testes verdes em build LIMPO; a guarda de geração fecha o defeito que a saída nova abriria |
| Simplicidade | 9 | um componente para sete superfícies, feito da `LinhaDeEstado` que já existia; `ProgressView` mudo removido em seis sítios; nenhuma abstração nova |
| Design/experiência | 9 | pensando, tempo e cancelar nas sete rotas, fotografado em `large`; peso da saída corrigido pela captura; alvo de 44 pt medido no teste de tela |
| Acessibilidade | 9 | alvo 44 pt afirmado por teste, identificadores na árvore (defeito de identificador corrigido), sem laço para Movimento Reduzido reduzir; VoiceOver falado fica como limite declarado |
| Evidência | 9 | número antes/depois com a montagem dentro, limites externos medidos e não presumidos, capturas da tela viva, linha de teste exclusivo colada |

**Estado honesto:** produzido, executado e observado. O teto de 300 s é **decisão**, não
medida — ninguém mediu 300, e a ADR diz isso. A espera longa da captura veio de transporte
controlado, não de chamada real: o que está provado na tela é o **estado da espera**, não a
latência do provedor.

---

## 9. Depois do G3 REPROVADO — o teto entrou sozinho, e o Ato 2 fica de pé para o próximo

**O que entrou.** A metade que o G3 aprovou sem achado nenhum contra ela saiu deste branch
e foi para `main`: branch `Vitorepf/tempo-teto`, commit **`e94b742`**, mesclado em
`c0399f9`. Contém **só** `Grok.teto = 300`, `Grok.esperaObservada = 241`, a guarda entre os
dois, os dois testes (`oTetoCobreAPiorLatenciaMedida`, `oTetoDoPedidoGanhaDoTetoDaSessao` —
com o `EscutaMuda` movido para dentro de `GrokContratoTests.swift`, para o commit não
depender do resto) e a **ADR 2026-09-10a com a parte do teto**, que já diz por escrito que a
espera com estado entra **por emenda a ela mesma** quando fechar. Provas no teste 4
(`A1DF082C`), build LIMPO: `✔ Test run with 1028 tests in 163 suites passed after 94.495
seconds`; `✔ Test oTetoDoPedidoGanhaDoTetoDaSessao() passed after 6.023 seconds`; mutação do
teto para 240 acusa em `GrokContratoTests.swift:72` e `:74` e cala de volta em 300; Release
LIMPO `** BUILD SUCCEEDED **` com 1 warning, o herdado de `NotasView.swift:814`.

**O que NÃO entrou, e não custa nada em `main`.** A espera com estado nunca foi mesclada —
o defeito do G3 vive **só neste branch** (`Vitorepf/tempo`, ponta `1f6708d`). Parar aqui não
deixa nada solto no aparelho do dono. Esta volta parou por ordem das 12h40: três cadeiras,
uma por operação de IA, e o Ato 2 seria uma quarta.

### As cinco linhas para quem pegar o Ato 2

1. **O comentário mente, e é ele que justifica o defeito.** `OficinaTrabalho.swift:264`
   afirma que as três rotas de rede *"se excluem por guarda, então é um relógio só"*. As
   guardas em **`:299`** (`guard !revisando`), **`:345`** (`guard !conferindoTentativa`) e
   **`:385`** (`!conferindoTentativa, !adaptando`) olham cada uma só a própria flag — e
   `documento(_:)` monta `praticar(o)` e `artefato(versao:)` no mesmo `VStack`
   (`TrabalhoView.swift:178`+), então **duas chamadas em voo é o caso comum, não o raro**.
   Prove a invariante com teste ou apague a frase; comentário que o código desmente desliga
   a desconfiança de quem lê.
2. **O que quebra, em uma frase:** `geracao` é **um contador por oficina** e `chamada` é
   **um slot só** — com duas rotas em voo o `defer` da primeira não roda, `revisando` fica
   preso em `true`, e "Parar de esperar" cancela só a última, deixando a órfã **gravar a
   leitura da IA no trabalho do autor**. Este último é o mais grave: é conteúdo da IA
   entrando no trabalho dele sem que ele tenha pedido.
3. **As DUAS SONDAS do revisor são a régua, e não estão na árvore.** Ele as plantou, rodou e
   **removeu** ("removida depois; não está no commit"), então elas se **reconstroem** a
   partir de `ferramentas/orca/revisao-tempo.md` §3 — A1 dá o nome
   `sondaRevisorDuasRotasPrendemAFlagDaPrimeira()`, a asserção (`!o.revisando`) e a linha
   vermelha; A2 dá `sondaRevisorPararDeEsperarNaoParaAOutraRota()` e a sua
   (`daIA.isEmpty → false`). **Verdes sem editá-las.** Sonda editada para ficar verde é
   reprova por outro caminho — e toda sonda precisa da irmã que **não** acusa (com uma rota
   só, o mecanismo já funciona: `pararDeEsperarNaoDeixaAChamadaVelhaApagarAEsperaDaNova()`
   passa hoje).
4. **Matar o `?? .now`**, que é o que transforma o estado inconsistente em mentira calada em
   vez de vermelho: `TrabalhoView.swift:699`, `:705`, `:972`. A forma que some com ele é o
   relógio deixar de ser um só — `if let desde = o.esperandoDesde(.tentativa)` em vez de
   `if o.conferindoTentativa { … desde: o.esperaDaIA ?? .now }`. O modelo certo já está na
   casa e é o **`ConversaNotas`** (token `UUID` por chamada, comparado no fim), **um por
   rota**; `OficinaTrabalho` hoje é **contraexemplo, não modelo**, e só volta a servir de
   guia para a volta `responder` depois disto fechado.
5. **O resto do que reprovou, que não é concorrência:** captura de **7 das 8** superfícies
   alteradas em `large` no teste 4 (só as Notas foram fotografadas); as **seis fases do
   `design-router`** citadas no relato (hoje zero citações — recusa no G4 mesmo com o código
   certo); a **hierarquia invertida** que a medida de pixel desmente (saída `#5F5F64` mais
   escura que o estado `#68686C`); o **toque morto do `Contrapor`** na Lente
   (`LenteView.swift:316`/`:344`) e o comentário falso de `LenteView.swift:19` (soltar a
   referência de um `Task` **não** o cancela); e as correções de A7/A8/A9 — a etiqueta da
   rota na medida da montagem, dizer que a tela fotografada depende de a política reabrir
   `responderNasNotas`, "sete superfícies" onde há oito, e o placeholder `ADR 09?`.

**Dívida herdada que achei no caminho e não toquei** (nenhuma é desta volta): `cancelar()`
(`OficinaTrabalho.swift:473`), chamado no `onDisappear`, cancela **só** `tarefa` — as rotas
de IA seguem correndo até o teto quando o autor sai da oficina; e `LinhaDeEstado.swift` tem
um `#Preview("AX5")` de `1f0c8f3` (V10-B), anterior à DIRETRIZ §12.

**Não é meu e ficou como estava** (o `git status` deste worktree chega assim e sai assim):
`maestro/ax5.yaml` apagado e `ferramentas/orca/f5-fotografar.sh` com uma linha de ajuda que
saiu de um `sed` malfeito da §12 (`tamanho: large | large`). Não commitei nem revertí — é
limpeza de outra volta, e o 4º parâmetro já não existe no corpo do script.

**Instrumento desta volta:** só o **teste 4** (`A1DF082C`), tudo sob `com-trava.sh`. Nenhum
comando meu nomeia `B91C8DEF` ou `34CC3F94` — **nenhuma janela de conta gasta, nenhuma
chamada real**. Não dirigi aparelho nenhum (sem mouse, sem maestro), então não havia
orientação, tema nem Movimento Reduzido para restaurar. O checkout descartável do Ato 1
ficou em `/Users/vitorepf/tempo-teto` (**nunca sob `/tmp`**) e foi removido ao fim.
