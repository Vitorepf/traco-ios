# Volta 18-B — a correção do G3 do Trabalho

Branch `Vitorepf/volta-18-trabalho`, sobre `ece2b27`. Recusa em
`ferramentas/orca/revisao-v18-trabalho.md` (seis achados). Simulador meu:
iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`, ligado por mim.
Todo `xcodebuild` e `maestro` por `ferramentas/orca/com-trava.sh`; `maestro
--device` porque havia sete simuladores ligados (o do dono, `1A46B6D3`, não foi
tocado). Toda prova de tela por `xcrun simctl io <UDID> screenshot`.

## Item por item

### 1 — a curva-zero. Escolhi (a): fazer a jornada cair, e medi depois.

A revisão mediu 6 toques e 2 digitações, idênticos à auditoria, e estava certa:
o toque que a volta 18 dizia ter economizado nunca esteve na conta.

O toque que saiu agora é o **toque no campo do pedido**, e ele era exatamente o
que o dono descreveu: um toque que só existia para revelar o passo seguinte.
Quem acabou de escrever a intenção e tocar "Começar este trabalho" vem dizer o
que quer preparado — a folha recém-criada abre com o cursor lá
(`TrabalhosView` marca qual trabalho nasceu agora; reabrir um trabalho da lista
NÃO leva teclado nenhum).

| passo | toque |
|---|---|
| Notas → Trabalhos (`abrir-trabalhos`) | 1 (+ o toque em "Notas" que a auditoria conta) |
| campo da intenção (`trabalho-nova-intencao`) | 2 |
| "Começar este trabalho" (`trabalho-criar`) | 3 |
| ~~campo do pedido~~ | **sai** |
| "Preparar com IA" (`trabalho-gerar`) | 4 |

**5 toques e 2 digitações.** A medição é um fluxo, não uma afirmação:
`maestro/trabalho-curva-zero.yaml` tem os toques numerados e o `inputText` do
pedido entra SEM toque no campo — se o foco não vier, o texto não entra em
campo nenhum e o `assertVisible` derruba a medição. Passou:

```
$ ferramentas/orca/com-trava.sh maestro --device B91C8DEF-… test maestro/trabalho-curva-zero.yaml
Running on iPhone 17 Pro (teste 2) - iOS 26.5 - B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9
 > Flow trabalho-curva-zero
Launch app "app.traco" with clear state... COMPLETED
exit=0
```

Captura: `v18b-curva-zero-abre-no-pedido.png` — o texto no campo, sem toque
nele, e a ordem de leitura inteira (intenção → apoio → preparar) ainda visível
ACIMA do teclado. A folha não perdeu a decisão de apoio ao ganhar o foco.

**Atrito que continua, e não escondo:** o teclado cobre a ação primária depois
que a pessoa escreve o pedido — antes e depois desta volta, do mesmo jeito. A
rolagem que o descobre é a mesma nas duas versões e não é toque em controle,
então não entra na contagem da auditoria; mas é atrito real e fica nomeado para
a volta que quiser matá-lo (uma barra de teclado é a saída óbvia, e é superfície
nova que não cabia aqui).

### 2 — `PromessaDoAviso.jaPassou`

Quinto caso, e `para(...)` ganhou `instante:` (quando o alarme tocaria, de
`Aviso.instante`) e `agora:`. O caso não carrega valor associado porque a frase
não usa a hora — quem decide é o `agora:`. A ordem é a do motor
(`Avisos.agendar`): permissão negada primeiro (beco com saída nos Ajustes),
depois o relógio, que cala qualquer promessa, só então a promessa.

Achei um segundo defeito no caminho e corrigi junto: um ato sem horário nascia
em `.now` cru, cujo alarme "na hora" JÁ estava atrás do relógio quando o dedo
chegava no botão — a folha abriria sempre dizendo "já passou". A proposta passou
a ser meia hora à frente, arredondada nos 5 minutos.

- `v18b-promessa-hora-passada.png`: relógio 17:13, ato 17:45, "2 h antes" →
  âmbar, "A hora do aviso já passou — esta ação ficou sem alarme."
- `v18b-promessa-toca.png`: mesmo ato, "na hora" → "Toca hoje às 17:45 · na
  hora, se você permitir os avisos quando o iPhone perguntar."
- 10 testes em `PromessaDoAvisoTests` (eram 5): hora passada nos três estados
  que prometem, o corte exato (`instante <= agora`, o mesmo `guard quando >
  agora` do motor), negado antes do relógio, sem aviso ignora o relógio, e sem
  `instante:` os quatro casos antigos continuam iguais.

O tipo fica completo para a volta que liga a ficha do Calendário.

### 3 e 4 — a ação bloqueada, numa lei só

Os dois achados são o mesmo defeito visto de dois lados, e resolvi na raiz em
vez de remendar sete chamadas: **nenhuma ação desta folha some**. Não há mais um
`.disabled()` em `TrabalhoView` nem em `AgendamentoAcaoView`. A ação bloqueada
continua a mesma cápsula, com o mesmo alvo e o mesmo contraste; o motivo
continua escrito na linha de baixo e agora também no `accessibilityHint`; e
tocar leva ao que falta:

- campo vazio → foco no campo (`faltaCampo`), nas sete ações;
- edição não guardada → foco no campo em edição (`campoEmEdicao`);
- salvamento falho → a saída no alto da folha (`levouAoObstaculo`, dentro de
  `aplicar`, por onde TODAS as escritas passam — um guard, não quinze);
- preparação da IA em curso → o próprio progresso (`preparacaoEmCurso`).

Provas: `v18b-gerar-edicao-pendente.png` é o MESMO estado de
`v18-rev-gerar-travado-sem-capsula.png` (intenção em edição não guardada) — era
texto cinza a 1,53:1, hoje é cápsula carvão inteira com o motivo ao lado.
`v18b-gerar-vazio-continua-capsula.png` para o campo vazio.
`maestro/trabalho-bloqueio.yaml` assere que a cápsula está lá, que a linha do
motivo está lá, e que o toque levou o foco (o texto seguinte entra no campo sem
nenhum toque nele).

**O que se perde, e digo:** o VoiceOver não anuncia mais "indisponível" nessas
ações — anuncia o motivo pelo hint, e o toque faz algo útil em vez de nada.
`Traco/Componentes` não foi tocado (fora do escopo): a cápsula do desabilitado
continua dívida da V12, e ainda vale para `IntercambioTrabalhoView`, que ficou
fora do escopo desta volta e desabilita três ações.

### 5 — o trilho diz ao VoiceOver qual está escolhido

`.accessibilityAddTraits(o.documento.apoio == a ? [.isSelected] : [])`.
Guardado no fluxo, que assere `selected: true` na escolhida e `false` nas outras
duas, antes e depois de trocar a escolha (`maestro/trabalho-bloqueio.yaml`,
`v18b-*`).

### 6 — `maestro/trabalho-acao-aviso.yaml`

Os quatro `swipe` de posição fixa viraram `scrollUntilVisible`, como a revisão
pediu. Além disso o fluxo precisou de três ajustes que a própria 18-B causou ou
revelou:

- a folha agora nasce com o teclado no pedido, então o fluxo recolhe o teclado
  antes de procurar o campo do ato;
- depois de "Preparar este ato" o campo continua com o foco, e sem recolher o
  teclado o toque seguinte caía numa tecla (reproduzido: um "T" entrou no campo);
- a asserção pré-commit passou a ser a verdade nova: com o ato meia hora à
  frente e "2 h antes", o alarme está atrás do relógio e a folha diz "A hora do
  aviso já passou". A promessa POSITIVA continua coberta no mesmo fluxo,
  trocando para "na hora";
- o alerta de permissão do iOS, na única vez em que aparece, recolhe a gaveta e
  rola a folha ao topo (defeito conhecido e declarado na ADR): o fluxo reabre a
  gaveta quando isso acontece, em vez de fingir que não acontece.

```
$ ferramentas/orca/com-trava.sh maestro --device B91C8DEF-… test maestro/trabalho-acao-aviso.yaml
Running on iPhone 17 Pro (teste 2) - iOS 26.5 - B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9
 > Flow trabalho-acao-aviso
Launch app "app.traco" with clear state... COMPLETED
exit=0
```

### 7 (da revisão) — os números

- ADR e relatório: `+592/−364` → o real da volta 18 nos três arquivos de view é
  **+599/−371**; com a 18-B, **+742/−396** (código sem comentário 1119 → 1296).
- Vídeos: "14,7 s" e "12,2 s" → `ffprobe` diz **16,503 s** e **14,294 s**.
- A frase da curva-zero na SPEC e no relatório da volta 18 foi corrigida para o
  que se reproduz, com a 18-B declarando o número novo.
- `Traco/Componentes/Botao.swift` ainda documenta `AcaoTrabalhoStyle` como
  estilo vivo: **não corrigi**, porque `Traco/Componentes` está fora do escopo
  que me foi dado. Fica anotado para quem abrir a volta dos Componentes.

## As seis fases do `design-router`

| fase | o que fiz nesta volta |
|---|---|
| **Ancorar** | li AGENTS, VISAO-PRODUTO, a ADR 2026-09-06b na SPEC e a revisão inteira antes de tocar em SwiftUI; escopo: as views de `Traco/Trabalho` exceto `Intercambio*`, testes, maestro, SPEC/EVOLUCAO. Nada de Componentes, Tema, Modelo, Análise |
| **Auditar antes de tocar** (é correção de redesenho) | reproduzi no meu aparelho os dois estados que a revisão fotografou: a ação primária sem cápsula com edição pendente, e a promessa de alarme para hora já passada. Só depois editei |
| **Sistema** | nenhum token novo, nenhum componente novo, nenhum arquivo de `Traco/Componentes` tocado; a ação bloqueada usa a MESMA `Pilula` da ação ativa, e é isso que devolve a cápsula |
| **Construir** | cada mudança rastreia a um achado numerado da revisão; o guard do salvamento falho entrou em `aplicar`, que é por onde tudo passa, em vez de em quinze chamadas |
| **Mover** | não acrescentei nem removi animação: as três leis de movimento da volta 18 continuam como estavam. O foco automático não anima nada além do que o teclado do sistema já faz |
| **Julgar e Portão** | julguei contra as capturas do aparelho, não contra o código: as quatro capturas `v18b-*` são o depois dos dois estados recusados mais os dois da promessa. Suíte 725/126, build 0 `warning:`, três fluxos verdes |

## Os quatro itens da `curva-zero`

- **Jornada.** Notas → Trabalhos → intenção → começar → (cursor já no pedido) →
  pedido → preparar → versão. A ordem da tela é a ordem do caminho.
- **Resultado verificável.** A versão chega no documento com produtor declarado;
  o fluxo da medição só termina quando `trabalho-artefato` aparece — o botão não
  é o fim da jornada, a versão é.
- **Atrito observado.** 6 → **5 toques**, 2 digitações, medido pelo mesmo método
  da revisão e guardado por fluxo. Atrito que fica: o teclado cobre a ação
  primária depois de escrever o pedido (igual antes e depois).
- **Recuperação.** Toda ação bloqueada leva ao que a destrava, e diz o motivo ao
  lado e no hint. Preparação interrompida continua com "Retomar esse pedido";
  rascunhos voltam ao reabrir; o aviso desligado leva aos Ajustes; a promessa
  não anuncia mais alarme que não vai tocar.

## Instrumento

- Build: `xcodebuild build` no meu UDID, `** BUILD SUCCEEDED **`, 0 `warning:`.
- Suíte: `✔ Test run with 725 tests in 126 suites passed after 10.478 seconds.`
  → `** TEST SUCCEEDED **`. (Também apaguei dois `warning:` pré-existentes de
  `ConferenciaTrabalhoTests`: um `var` que nunca muta.)
- Três fluxos maestro no meu UDID sob `com-trava.sh`, todos `exit=0`:
  `trabalho-curva-zero.yaml`, `trabalho-bloqueio.yaml`, `trabalho-acao-aviso.yaml`.
- Capturas minhas, por `simctl`: `v18b-curva-zero-abre-no-pedido.png`,
  `v18b-gerar-vazio-continua-capsula.png`, `v18b-gerar-edicao-pendente.png`,
  `v18b-promessa-hora-passada.png`, `v18b-promessa-toca.png`.
- Nenhum simulador que eu não liguei foi desligado; nenhum `clearState` saiu do
  meu; o iPhone 17 do dono não foi tocado.
- Nota de instrumento, para quem rodar depois: reinstalar o app reseta a
  permissão de notificações, e o alerta do iOS fica MODAL sobre a tela das
  Notas — os três fluxos falharam em bloco por causa dele (`abrir-trabalhos`
  visível, `trabalho-nova-intencao` não). Responder ao alerta uma vez destrava
  os três. Não é regressão de identificador.

## O que NÃO provei

1. **AX5.** Não refiz as capturas de tamanho de acessibilidade: nenhuma das
   mudanças toca layout (o trilho, o cabeçalho e o `safeAreaInset` são os
   mesmos), e o texto novo é linha de motivo que já existia.
2. **VoiceOver com pessoa.** O `selected` está provado na árvore
   (`maestro`), não com leitor de tela ligado num aparelho real.
3. **O estado *negado* da promessa** continua vivendo no teste, não na captura,
   pelo mesmo motivo da volta 18 (o simulador não deixa revogar).
4. **`IntercambioTrabalhoView`** continua com três ações que desabilitam e
   perdem a cápsula: fora do escopo que me foi dado.
