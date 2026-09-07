# Revisão G3 — volta 18, o Trabalho (Claude Opus 5, revisor)

Branch `Vitorepf/volta-18-trabalho`, commit `ece2b27`, base `main`.
Simulador **meu**: iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`,
ligado e desligado por esta revisão. Todo `xcodebuild` e `maestro` por
`ferramentas/orca/com-trava.sh`; `maestro --device <meu UDID>` porque havia sete
simuladores ligados (o do dono, `1A46B6D3`, não foi tocado). Toda prova de tela
por `xcrun simctl io <UDID> screenshot`. Texto restaurado a `large` e aparência
`light` ao fim, como estavam.

**Veredito: CORRIGIR ANTES.** Seis dimensões em 8. A folha melhorou de verdade —
o antes e o depois lado a lado não deixa dúvida —, mas cinco achados se sustentam
contra a tela, e três deles são da MESMA classe que a volta declara fechada.

---

## O que confirmei do que o implementador declara

| declarado | confere? | prova minha |
|---|---|---|
| build sem aviso | **sim** | `xcodebuild clean build` do zero no meu UDID: `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** |
| suíte 720/126 verde | **sim** | `✔ Test run with 720 tests in 126 suites passed after 7.579 seconds` → `** TEST SUCCEEDED **` |
| `AcaoTrabalhoStyle` apagado | sim | diff; o estilo não existe mais no repositório |
| oito `DisclosureGroup` viraram cinco, nenhum aninhado | **sim** | contagem: antes 6+1+1 = 8, depois 3+1+1 = 5; `historico` deixou de ter gaveta dentro de gaveta |
| código 1119 → 1247 linhas sem comentário | **sim** | 847+115+157 = 1119; 913+143+191 = 1247 |
| sétimo defeito (AX5 sangrava pelos dois lados) | **sim** | `v18-antes-ax5-trabalho.png` ("Apresentar a" em x=0, "deia" cortado) × `v18-ax5-trabalho.png`; **reproduzi** em AX5 no meu aparelho (`v18-rev-ax5-trilho.png`) |
| trilho empilha em AX5 | **sim** | `v18-rev-ax5-trilho.png`, três cápsulas empilhadas, sem clipe |
| campo vazio foca o campo em vez de apagar a ação | **sim** | `v18-foco-em-vez-de-fantasma.png`, conferido: cursor no campo, teclado subiu |
| `PromessaDoAviso` distingue *não perguntado* | **sim** | na minha tela: "…, se você permitir os avisos quando o iPhone perguntar" (`v18-rev-promessa-hora-passada.png`) |
| xcodegen não desincroniza o `.pbxproj` | sim | `xcodegen generate` → `git status` limpo |
| `trabalho-voltar` sobrevive ao `CabecalhoDeFolha` | sim | `prefixo: "trabalho"` → `"\(prefixo)-voltar"` |
| **intenção → versão preparada cai de 6 toques para 5** | **NÃO** | ver achado 1 |
| shortstat +592/−364 | quase | o real nos três arquivos é **+599/−371** |

As 20 capturas e os 2 vídeos foram conferidos por CONTEÚDO, não por existência
(folha de contato de oito, mais leitura individual de sete). Cada uma mostra o
estado que o nome promete. Os vídeos: 16,5 s / 88 KB (97 quadros distintos) e
14,3 s / 80 KB (28 quadros) sobre a MESMA jornada — dentro do teto, e a diferença
de quadros é consistente com a lei do movimento reduzido.

---

## Achados, por severidade

### 1. ALTO — a curva-zero não caiu; o número está errado na SPEC

A auditoria mediu **6 toques e 2 digitações** para intenção → versão preparada.
Medi o caminho de hoje no meu aparelho, comando a comando
(`maestro --device`, fluxo em anexo):

| passo | toque |
|---|---|
| Notas → Trabalhos (`abrir-trabalhos`) | 1 |
| campo da intenção (`trabalho-nova-intencao`) | 2 |
| "Começar este trabalho" (`trabalho-criar`) | 3 |
| campo do pedido (`trabalho-pedido`) | 4 |
| "Preparar com IA" (`trabalho-gerar`) | 5 |
| + o toque em "Notas" que a auditoria conta | 6 |

**6 toques e 2 digitações. Idêntico.** Não há foco automático no campo do pedido
depois de "Começar" (`criar()` não move o foco) — conferido na tela
(`v18-rev-caminho-uma-tela.png`: sem teclado, sem cursor). O toque que a volta
diz ter economizado — "abrir o disclosure para chegar ao apoio" — **não estava na
conta da auditoria**: os 6 dela já eram o caminho de quem NÃO decide o apoio.

O que de fato melhorou, e é real: a decisão saiu do disclosure e custa 0 toques
(padrão já marcado), o caminho principal cabe numa tela só, e a ação primária não
está mais atrás de "Dificuldade". Mas a frase da ADR — *"Curva-zero: intenção →
versão preparada cai de 6 toques e 2 digitações para 5 e 2"* — é uma medição que
não se reproduz, e está gravada em `SPEC.md` e no relatório.

**Corrigir:** a frase da ADR e do relatório. Não o código.

### 2. ALTO — a folha ainda promete alarme para hora já passada

`PromessaDoAviso` fecha a metade da permissão do defeito 6. Não fecha a outra
metade, e ela aparece na tela deste build:

`v18-rev-promessa-hora-passada.png` — relógio **15:08**, ato às 15:07, aviso "30
min antes" (14:37) e a folha diz:

> "Toca hoje às **14:37** · 30 min antes, se você permitir os avisos quando o
> iPhone perguntar."

**14:37 já passou há 31 minutos.** Não é caso de laboratório: a evidência do
próprio implementador tem a mesma mentira — `v18-agendar.png`, relógio 14:32,
"Toca hoje às 14:30 · na hora".

O motor já sabe a verdade. Depois do commit a mesma folha diz, em âmbar:
*"A hora do aviso já passou — esta ação ficou sem alarme"* (`v18-agendado.png`,
caso `.passou`). Só a promessa PRÉ-commit não tem esse caso:
`PromessaDoAviso.para(minutos:estado:hora:)` não recebe `agora` e
`Aviso.promessa` devolve "hoje às HH:MM" sem olhar o relógio.

É exatamente a segunda metade do defeito 2 da ficha do Calendário, que a revisão
da V9 acrescentou ("a ficha promete 'Toca hoje às 09:00' para uma hora já
passada"). A volta importou o defeito para o Trabalho junto com a correção.

**Corrigir:** um quinto caso (`.jaPassou`) em `PromessaDoAviso`, com `agora:` no
construtor. Fecha os dois lados de uma vez e responde à pergunta do dono (abaixo).

### 3. ALTO — a ação desabilitada deixa de ser controle

`v18-rev-gerar-travado-sem-capsula.png`: com a intenção em edição não guardada,
"Preparar com IA" **perde a cápsula inteira** e vira texto cinza-claro solto,
centrado, indistinguível de uma legenda. Contraste medido de `Tema.tintaMorta`
(`#C7C7CC`) sobre `Tema.fundo` (`#F4F4F2`): **1,53:1**. Não é "apagado", é sumido.

A causa está em `Pilula`: `fundo` devolve `.clear` quando `!ativa`. O
implementador nomeou isto como dívida da V12 ("a ação SECUNDÁRIA desabilitada
some da grade"), mas subestimou: quem some é a **ação primária da tela**, num
estado alcançável em quatro toques.

E é regressão contra o antes: em `v18-antes-trabalho-novo.png` o "Preparar com
IA" desabilitado era uma **cápsula cinza cheia** — parecia botão, só não parecia
desabilitado. Hoje não parece nem botão. O defeito 2 da §6 (`critique-affordance`)
foi fechado num caso e reaberto no vizinho.

A mesma coisa se vê em quatro lugares mais, nas capturas do próprio
implementador: "Guardar o trecho" e "Guardar minha tentativa"
(`v18-movimento-normal.mp4`, quadros 40 e 10), "Registrar meu relato" e "Guardar
esta dificuldade" (`v18-rev-fluxo-passa-do-alvo.png`, `v18-ato-preparado.png`).

**Agravante de consistência:** a regra nova — *campo vazio não desabilita, leva o
foco* — foi aplicada a DOIS botões ("Preparar com IA", "Preparar este ato") e não
aos outros cinco que desabilitam por campo vazio ("Guardar esta dificuldade",
"Guardar minha tentativa", "Guardar o trecho", "Registrar meu relato", "Guardar
minha versão"). A mesma folha ensina duas gramáticas para a mesma situação.

**Corrigir:** aplicar a regra do foco aos cinco restantes (é a saída barata, e não
toca em `Traco/Componentes`), ou dar cápsula à `Pilula` desabilitada na V12.

### 4. ALTO — o trilho de apoio não diz ao VoiceOver qual está escolhido

`maestro hierarchy` no meu aparelho, com "Delegar" marcado na tela:

```
{'accessibilityText': 'Delegar',  'resource-id': 'trabalho-apoio-delegar',  'selected': 'false'}
{'accessibilityText': 'Praticar', 'resource-id': 'trabalho-apoio-praticar', 'selected': 'false'}
{'accessibilityText': 'Combinar', 'resource-id': 'trabalho-apoio-combinar', 'selected': 'false'}
```

Os três saem iguais. A decisão que muda o que "Preparar" faz é comunicada **só
por cor** (`Tema.chipAtivo` × `Tema.chip`). Para quem usa leitor de tela, o
trilho é três botões idênticos e o estado atual é invisível.

É **regressão**: o `Picker(.pickerStyle(.menu))` da V9 anunciava o valor
escolhido de graça. Trocar o controle nativo pelo trilho perdeu isso.

**Corrigir:** uma linha em `TrabalhoView.trilhoDoApoio`:
`.accessibilityAddTraits(o.documento.apoio == a ? [.isSelected] : [])`.
Não precisa tocar em `Traco/Componentes`.

### 5. MÉDIO — o fluxo maestro que guarda este contrato falha no branch

`maestro/trabalho-acao-aviso.yaml` (ADR 05n, a ação do Trabalho que avisa)
**falha duas vezes seguidas** no meu aparelho, sempre no mesmo passo:

```
Element not found: Text matching regex: Escolher um horário
```

Não é a instabilidade de driver que o relatório declara: a captura de falha
(`v18-rev-fluxo-passa-do-alvo.png`) mostra a folha parada em "Dificuldade" e
"Histórico de versões (0)" — os dois `swipe` de posição fixa do fluxo **passam do
alvo** porque a ordem das seções mudou. O meu próprio fluxo, com
`scrollUntilVisible` no lugar dos swipes, chega ao mesmo alvo sem falhar.

A mudança altera navegação e ordem; AGENTS pede a jornada integrada nesse caso, e
o fluxo que a guarda não foi atualizado.

**Corrigir:** trocar os `swipe` fixos por `scrollUntilVisible` no fluxo.

### 6. BAIXO — a lei da folha contradiz a si mesma na forma

A lei escrita é "carvão avança, âmbar salva", e o comentário de `acaoSecundaria`
diz, corretamente: *"texto solto sobre papel não se lê como controle e não tem
estado desabilitado"*. Mas `acaoDeSaida` — o âmbar — é exatamente texto solto
sobre papel (`BotaoPrimario` alinhado à esquerda, sem cápsula): "Retomar esse
pedido", "Pedir ajuste", "Copiar dados de recuperação", "Tentar guardar
novamente". A metade da COR da lei se sustenta na tela; a metade da FORMA não.

### 7. BAIXO — três números e um comentário desatualizados

- ADR/relatório: `+592/−364`; o real nos três arquivos é `+599/−371`.
- Relatório: vídeos "14,7 s" e "12,2 s"; `ffprobe` diz 16,5 s e 14,3 s (dentro do teto).
- `Traco/Componentes/Botao.swift` ainda documenta `AcaoTrabalhoStyle`
  (TrabalhoView) como estilo vivo e "sete estilos no repositório" — esta volta
  apagou um. Arquivo não tocado pela volta; a correção é de uma linha.
- `Vazio` e a busca: a lista vazia mostra o campo "Buscar trabalhos" mesmo com
  zero trabalhos (`v18-lista-vazia.png`). Ruído pequeno, não bloqueia.

---

## As seis fases do `design-router`, conferidas CONTRA A TELA

| fase | citada | se sustenta na tela? |
|---|---|---|
| **Ancorar** | sim | **sim** — as restrições declaradas se verificam no diff: nenhum arquivo de `Traco/Componentes` nem `Tema.swift` foi tocado; só três views, um teste e documentos |
| **Auditar antes de tocar** (redesenho) | sim | **sim** — 12 capturas `v18-antes-*`; conferi duas contra as afirmações da §6 e reproduzi o sétimo defeito e o seu fecho em AX5 no meu aparelho |
| **Sistema** | sim | **parcial** — nenhum token novo (confere); componentes consumidos (confere); a lei de cor se vê na tela (carvão em Começar/Preparar/Marcar/Guardar tentativa, âmbar só em "Abrir os Ajustes" e nas saídas). Mas a lei de FORMA se contradiz: achado 6 |
| **Construir** | sim | **sim** — cada mudança rastreia a um defeito nomeado da §6 |
| **Mover** | sim | **sim** — três animações, todas por `Tema.movimento/animacao/transicao/gaveta` com `reduzido:` do ambiente; os dois vídeos mostram a mesma jornada com 97 × 28 quadros distintos |
| **Julgar e Portão** | sim | **parcial** — as três correções da própria volta são visíveis (rótulo em caixa normal, foco em vez de fantasma, `safeAreaInset` provado pelo AX5 limpo). Mas o portão declarou "desabilitado sempre diz por quê" sem ver que o controle desabilitado deixou de ser controle: achado 3 |

## Os quatro itens da `curva-zero`, conferidos CONTRA A TELA

| item | se sustenta? |
|---|---|
| jornada | **sim** — a ordem declarada é a ordem da tela (`v18-rev-caminho-uma-tela.png`) |
| resultado verificável | **sim** — versão com produtor declarado (`v18-versao.png`, "Apple Intelligence no aparelho"); ato com horário e estado vindo do motor (`v18-agendado.png`) |
| atrito observado | **NÃO** — achado 1: o número não caiu |
| recuperação | **parcial** — o motivo do desabilitado sempre aparece (confere), mas está pendurado num controle que sumiu (achado 3); "Retomar esse pedido" e a cópia de recuperação continuam lá |

---

## Scorecard — 15 dimensões

| dimensão | nota | evidência |
|---|---|---|
| **Visão** | **9** | fecha a lacuna nomeada do EVOLUCAO ("Direção visual e uso simples") na PIOR tela da auditoria (6,0). O antes e o depois (`v18-antes-trabalho-novo.png` × `v18-rev-caminho-uma-tela.png`) mostram outra tela |
| **Contrato** | **8** | ADR 2026-09-06x curta e coerente; SPEC, EVOLUCAO e código alinhados; `xcodegen` não desincroniza. **Mas** a ADR grava uma medição que não se reproduz (achado 1) e três números errados (achado 7) |
| **Correção** | **8** | `clean build` do zero: `BUILD SUCCEEDED`, **0** `warning:`. Suíte **720/126 verde** reproduzida por mim. 5 testes novos, um por estado da promessa, incluindo a leitura pendente. **Mas** `maestro/trabalho-acao-aviso.yaml` falha 2/2 no branch (achado 5) |
| **Jornada real** | **9** | os nove estados do G2 em large e AX5, conteúdo conferido um a um; quatro reproduzidos por mim no meu aparelho. Falha da IA e estado *negado* não capturados, com motivo declarado e correto |
| **Design** | **8** | a família foi alcançada de verdade: cabeçalho de folha, rótulo de seção, campo em névoa, cartão de papel, a MESMA cápsula antes e depois da primeira versão. **Mas** achado 3 (a primária desabilitada some, 1,53:1, sem forma) e achado 6 (a lei de forma contradita) |
| **Simplicidade** | **8** | 8 → 5 `DisclosureGroup` e nenhum aninhado (contado); decisão no caminho a 0 toques; caminho principal numa tela. **Mas** a contagem antes/depois — a evidência que a ESTEIRA nomeia para esta dimensão — não se moveu: 6 → 6 (achado 1). Regra do orquestrador: se não caiu, não sobe |
| **Movimento** | **9** | três animações com propósito (versão que chega, troca do trilho, gaveta), todas pela lei única de `Tema` com `reduzido:` do ambiente; dois vídeos dentro do teto (16,5 s/88 KB, 14,3 s/80 KB), conteúdo conferido quadro a quadro, 97 × 28 quadros distintos na mesma jornada |
| **Componentes** | **8** | `AcaoTrabalhoStyle` apagado; cinco componentes da casa consumidos. **Mas** a `Pilula` desabilitada perde a cápsula na ação primária (achado 3); `Pilula.larga` sem recuo encosta o texto na borda em AX5 (`v18-ax5-preparar.png`); e `secao`/`acaoSecundaria`/`acaoDeSaida`/`divisoria` são cópias locais do que a ficha do calendário já tem — a duplicata mudou de lugar, não acabou |
| **Acessibilidade** | **8** | AX5 limpo nas duas telas, sétimo defeito fechado e reproduzido por mim; alvos pelos componentes; contrastes bons (rótulo de seção 5,77:1, pílula não marcada 5,18:1, marcada 13,94:1). **Mas** achado 4: o trilho não expõe a seleção ao VoiceOver, e é regressão contra o `Picker` da V9 |
| **Performance** | **n/a** | a volta não acrescenta lista, editor nem parser; a folha já era um `VStack` linear dentro de `ScrollView` e continuou. Nenhuma medida feita, nenhuma travada observada em três jornadas dirigidas |
| **Privacidade e autoria** | **9** | toda escrita continua passando por `aplicar`, que revalida `acesso.permitido` + `o.verificarAcesso()` e exige `o.salvo`; ramo de trabalho protegido intacto na lista e na folha (`trabalho-lista-protegido`, `trabalho-protegido`); a cópia de recuperação revalida antes de tocar a área de transferência; o produtor continua ao lado da versão ("Apple Intelligence no aparelho", `v18-conferencia.png`) e o rodapé continua dizendo que a segunda leitura da IA não é revisão independente. Nada novo envia, gasta ou publica |
| **Estado honesto** | **8** | `PromessaDoAviso` é pura, testada nos quatro casos, e o *não perguntado* aparece certo na minha tela. Pós-commit tudo vem do motor, inclusive `.passou`. **Mas** achado 2: a promessa pré-commit ainda anuncia alarme para hora já passada, na minha captura e na do implementador |
| **Complexidade** | **9** | os números conferem (1119 → 1247). Percorri as linhas que entraram: trilho + ramo AX, tri-estado da promessa, linhas de motivo, cabeçalho fixo, extrações que encurtam chamada — cada bloco fecha um defeito nomeado. Único acréscimo fora da lista é "Ver todos os trabalhos" na busca vazia (3 linhas), defensável como recuperação. Apagados conferidos: estilo, 3 disclosures, 2 `NavigationStack`, o `Picker` |
| **Fora do app** | **n/a** | a volta não toca widget, Ilha, tela bloqueada, Controle nem StandBy |
| **Relato** | **9** | legível por quem não abre terminal, seis fases declaradas de forma conferível, limites declarados com honestidade — inclusive o do *negado*, que confirmei ser um limite real do instrumento. Os números errados ficam em Contrato, não aqui |

**Média das que têm nota: 8,5. Seis dimensões abaixo de 9 → não mescla.**

---

## A pergunta do dono: `PromessaDoAviso` serve à ficha do Calendário?

**Serve, e resolve mais do que você pediu — mas não do jeito que está. Falta um
caso.**

O que ele já resolve na ficha (`CalendarioFicha.swift:127-160`):

1. **A metade da permissão** — hoje a ficha imprime `Text("Toca \(promessa).")`
   sempre que `Aviso.promessa` devolve algo, sem olhar a permissão. Com
   `naoPerguntado` ela promete alarme que ninguém autorizou. É o mesmo buraco.
2. **A contradição, que é PIOR na ficha** — com `estadoDosAvisos == .negado` a
   ficha mostra as DUAS frases ao mesmo tempo: "Toca hoje às 09:00." e, logo
   abaixo, "Os avisos do Traço estão desligados — nada vai tocar." O tipo é uma
   `enum` de caso único: estruturalmente impede as duas juntas, que é o que a
   ADR 04a pede ("UMA linha, sempre").
3. **O acoplamento certo** — ele recebe `hora: String` já formatada, então a
   ficha continua dona do `diaInteiro:` e do `Aviso.nome(...)` dela. Não há nada
   de Trabalho dentro do tipo.

O que **não** resolve, e por isso eu não ligaria as duas pontas antes de
consertar: **a hora já passada** (achado 2). Foi o outro defeito que a revisão da
V9 achou na ficha, e o tipo não tem caso para ele — nem recebe `agora`. Se você
ligar as pontas como está, a ficha ganha a metade da permissão e mantém a metade
do relógio, e o Trabalho continua com a mentira que eu capturei hoje.

**Recomendação para a volta que liga as duas pontas:** primeiro acrescente
`case jaPassou` e o parâmetro `agora: Date` a
`PromessaDoAviso.para(minutos:estado:hora:)` — o texto já existe pronto no
caminho pós-commit (`"A hora do aviso já passou — esta ação ficou sem alarme."`).
Depois mova o tipo de `AgendamentoAcaoView.swift` para junto de `Avisos`/`Aviso`
(ele não tem nada de view) e faça a ficha consumi-lo. Uma volta, dois defeitos,
duas telas, e cinco testes que já existem viram sete.

---

## Instrumento

- Simulador meu: `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9` (iPhone 17 Pro, teste 2),
  ligado por mim, desligado por mim. Sete estavam ligados; o do dono
  (`1A46B6D3`) não foi tocado, e nenhum `clearState` saiu do meu.
- `varrer.sh` **não pôde rodar** (recusa com mais de um simulador ligado, e
  havia sete). Rodei os fluxos por `maestro --device <meu UDID>` sob
  `com-trava.sh`, incluindo `maestro/trabalho-acao-aviso.yaml` duas vezes.
- `xcodebuild clean build` e `xcodebuild test` no meu UDID, sob `com-trava.sh`.
- Texto restaurado a `large` (foi a `accessibility-extra-extra-extra-large` e
  voltou); aparência `light` inalterada. Nada editado, nada commitado.
- Capturas minhas: `v18-rev-caminho-uma-tela.png`,
  `v18-rev-promessa-hora-passada.png`, `v18-rev-gerar-travado-sem-capsula.png`,
  `v18-rev-ax5-trilho.png`, `v18-rev-fluxo-passa-do-alvo.png`.

## Para o orquestrador: quem corrige o quê

| achado | dono sugerido | tamanho |
|---|---|---|
| 1 — número da curva-zero na ADR/SPEC/relatório | implementador do Trabalho | texto, minutos |
| 2 — `case jaPassou` em `PromessaDoAviso` | implementador do Trabalho (e abre a volta da ficha) | uma enum, um parâmetro, dois testes |
| 3 — desabilitado que deixa de ser controle | implementador do Trabalho (regra do foco nos cinco restantes) **ou** V12 (cápsula na `Pilula` desabilitada) | cinco `guard`, ou uma linha em `Pilula` |
| 4 — `.isSelected` no trilho | implementador do Trabalho | uma linha |
| 5 — `trabalho-acao-aviso.yaml` passa do alvo | implementador do Trabalho | trocar 4 `swipe` por `scrollUntilVisible` |
| 6 — forma do `acaoDeSaida` | implementador do Trabalho, ou dívida declarada da V12 | decisão de sistema |
| 7 — números e comentário do `Botao.swift` | implementador do Trabalho | texto |

---

# Re-G3 — volta 18-B (mesmo revisor, 06/09, topo `52097b7`)

Simulador **meu**: iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`,
ligado e desligado por esta revisão; o iPhone 17 do dono já estava desligado e
**não foi religado**. Havia mais quatro simuladores de outros ligados o tempo
todo, e eu não desliguei nenhum.

**Método, por causa da lei nova do instrumento.** A contagem de toques e todos
os estados foram medidos **à mão**: janela do meu simulador trazida à frente,
toque por `cliclick`, e `xcrun simctl io <MEU-UDID> screenshot` **depois de cada
toque**. A captura é a prova de que o toque caiu no meu aparelho: se tivesse
caído no vizinho, a minha tela não teria mudado. Nenhuma nota depende de fluxo
maestro.

**E a lei nova se confirmou no meu turno.** Tentei uma leitura de árvore com
`maestro --device <MEU-UDID>` guardada por uma marca: a intenção do meu aparelho
era a frase única "Apresentar a ideia agoraao cliente". O resultado veio
`MARCA DO MEU APARELHO presente: False`, com `trabalho-preparar-acao` numa tela
que o meu aparelho não estava mostrando — o `lsof` confirma um `maestro-d` de
outro simulador segurando `[::1]:7001`. **A leitura veio do vizinho.** Registro
como prova pendente de instrumento o que só o maestro provaria, e não desconto
nota por isso (ordem do orquestrador).

## Os seis achados, um a um

### 1. Curva-zero — **FECHADO, e melhor do que eu pedi**

Eu tinha dito para corrigir o número na ADR. Ele preferiu fazer a jornada cair.
Medi do zero, sem olhar o número dele, pelo MESMO método da auditoria V9:

| # | toque | prova |
|---|---|---|
| 1 | "Notas" na página | `c1.png` — abriu Notas |
| 2 | "Trabalhos" | `c2.png` — lista vazia, **sem teclado, sem foco** |
| 3 | campo da intenção + digitação 1 | `c3b.png` |
| 4 | "Começar este trabalho" | `c4.png` — **a folha abre com o cursor JÁ no campo do pedido** |
| — | digitação 2, **sem nenhum toque** | `c5.png` — o texto entrou no pedido |
| 5 | "Preparar com IA" | `c6.png` — "A IA está preparando…" |
| — | resultado | `c7.png` — **VERSÃO 1, produtor "Apple Intelligence no aparelho"** |

**5 toques e 2 digitações** (eram 6 e 2). Folha de contato:
`v18-reg3-curva-zero-5-toques.png`. O toque que sumiu é justamente o que só
existia para revelar o passo seguinte, e ele sai sem esconder nada: o campo
continua visível, rotulado e editável. `maestro/trabalho-curva-zero.yaml` guarda
a medição (4 `tapOn` dentro da folha, mais a navegação por `openLink`) e falha se
alguém devolver o toque — a estrutura do fluxo confere com a minha contagem à
mão, mesmo que eu não possa rodá-lo com o instrumento de hoje.

### 2. `PromessaDoAviso.jaPassou` — **FECHADO na tela, nos dois sentidos**

`v18-reg3-promessa-nao-mente-mais.png`:

- **17:43**, ato sem horário: a folha propõe **18:15** — `agora + 30 min`
  arredondado nos 5 — e diz "Toca hoje às 18:15 · na hora, se você permitir os
  avisos quando o iPhone perguntar". Hora **à frente**. O `.now` cru acabou.
- Mudei o aviso para **"2 h antes"** (alarme às 16:15, atrás do relógio das
  17:44) e a linha virou, em âmbar:
  **"A hora do aviso já passou — esta ação ficou sem alarme."**

É a mesma frase do motor depois do commit, agora dita antes. A mentira que eu
fotografei às 15:08 ("Toca hoje às 14:37") não se reproduz mais. 10 testes, e os
três que importam são os certos: `horaExataDoAlarmeJaPassou` (a borda `<=`),
`negadoVemAntesDoRelogio` (a ordem) e `semInstanteMantemOsQuatroCasos`.

### 3+4. A lei do bloqueio e o `.isSelected` — **FECHADO no que dá para ver**

Não sobrou um `.disabled()` em `TrabalhoView` nem em `AgendamentoAcaoView`
(conferido no arquivo, não só no diff). Na tela, nos estados em que eu tinha
fotografado fantasmas:

- `v18-reg3-nada-some-com-campo-vazio.png` — com "O que está dificultando isso?"
  e "O que aconteceu?" **vazios**, "Guardar esta dificuldade", "Registrar meu
  relato" e "Descartar rascunhos dos campos" são **cápsulas inteiras e
  legíveis**. Compare com `v18-rev-fluxo-passa-do-alvo.png`, onde as mesmas três
  eram legenda cinza. O 1,53:1 saiu da folha.
- `v18-reg3-toque-leva-ao-campo.png` — toquei "Preparar este ato" com o campo
  vazio: o ato **não** foi preparado e o cursor foi para "Ensaiar a
  apresentação". "Leva ao que falta" é real.

Tracei **todas** as remoções de `.disabled()` contra as escritas: cada uma passa
por `aplicar`, que agora guarda `levouAoObstaculo`, ou pelo guarda explícito.
Conferi também o invariante de que isso depende: `salvo = false` só é atribuído
em `OficinaTrabalho:91` e `:112`, e **as duas linhas seguintes atribuem `erro`**
— logo `!salvo ⟹ erro != nil`, e o alvo `"trabalho-erro"` da rolagem sempre
existe quando o desvio dispara. Não há caminho novo de escrita sem guarda.

O `.isSelected` está no código (`.accessibilityAddTraits(o.documento.apoio == a ?
[.isSelected] : [])`) e compila. **A prova de árvore ficou pendente de
instrumento**, pelo motivo do cabeçalho.

### 5. `trabalho-acao-aviso.yaml` — **corrigido no arquivo, prova pendente**

Os quatro `swipe` de posição fixa viraram `scrollUntilVisible`, que é a correção
certa (foi o que eu usei para chegar ao mesmo alvo quando o fluxo dele falhava).
Rodar o fluxo hoje provaria o vizinho, não este branch: **pendente de
instrumento**, sem desconto.

### 6. Números e comentário — **corrigidos e conferidos**

Recontei tudo: `+742/−396` nos três arquivos de view somando 18 e 18-B (179+438+
125 / 75+249+72) e **1119 → 1296** linhas sem comentário; só a volta 18 é
`+599/−371` e 1119 → 1247. **Batem com a ADR.** O comentário de `Botao.swift`
sobre `AcaoTrabalhoStyle` continua desatualizado — `Traco/Componentes` está fora
do escopo dele, e a recusa é legítima; vira uma linha da volta dos Componentes.

## Dois achados NOVOS

### A. ALTO — a folha enuncia uma regra que não cumpre mais

A ADR 2026-09-06b descreve a lei do bloqueio incluindo *"edição não guardada
recebe o foco (`campoEmEdicao`)"*. Em `trabalho-gerar` isso **não acontece**: o
guarda do toque é `guard !levouAoObstaculo(o), !faltaCampo("pedido")`, e
`edicaoPendente` só entra no cálculo da **mensagem** (`travado`), nunca na ação.
A volta 18 e a V9 bloqueavam esse caso pelo `.disabled(travado)`; a 18-B removeu
o `.disabled` e portou só a metade `!o.salvo` do guarda.

Provado na tela (`v18-reg3-edicao-pendente-nao-bloqueia.png`):

1. Abri "Rever a intenção", mudei o texto e **não guardei**. A folha escreveu,
   embaixo da cápsula carvão: *"Guarde a intenção ou a versão que está editando
   antes de pedir uma nova preparação."*
2. Toquei "Preparar nova versão com IA". **"A IA está preparando…" começou.**
3. Noventa segundos depois havia uma VERSÃO 2, e a própria folha a marcou em
   vermelho: *"Esta versão foi preparada para uma intenção anterior. Confira o
   que ainda serve."*

O resultado não é mentiroso — o app confessa depois. O que mente é a **regra**: a
tela diz "guarde antes de pedir" e não exige nada. O custo é uma corrida de IA de
~90 s gasta exatamente no caso que a regra existia para evitar. Nenhum teste e
nenhum fluxo cobrem este caso: `trabalho-bloqueio.yaml` só cobre o campo vazio e
o trilho.

**Correção: uma linha, e ela já existe três centenas de linhas abaixo.**
`trabalho-revisar` faz certo:
`if let chave = campoEmEdicao(o) { campoEmFoco = chave; rolarPara = chave; return }`.
Basta a mesma no `trabalho-gerar`.

### B. MÉDIO — em AX5, documento **com versão** volta a sangrar pelos dois lados

`v18-reg3-ax5-sangra-com-versao.png`, o mesmo aparelho e o mesmo AX5, lado a lado:

- **Trabalho novo, sem versão:** margens corretas, trilho empilhado, nada
  cortado. É o que a volta 18 provou e o que eu confirmei no re-teste.
- **O mesmo trabalho depois da versão da IA:** todo o documento desloca ~30 pt
  para a esquerda — "voltar" perde o chevron, "Apresentar" vira "presentar",
  "NESTE TRABALHO, PREFIRO" vira "ESTE TRABALHO, REFIRO", as três pílulas do
  trilho ficam cortadas em x=0 e o cartão de papel passa da borda direita.

**Não é regressão da 18-B**, e digo por quê: o diff `ece2b27..52097b7` não toca
`ConteudoTrabalhoView` nem nada que proponha largura, e a lista dos Trabalhos em
AX5 continua impecável (`ax3.png`). A causa está no conteúdo do documento
propondo largura ideal maior que a tela — `ConteudoTrabalhoView` é a única view
do documento que a prova de AX5 da volta 18 nunca exercitou. **A falha é minha
também:** no G3 eu validei o AX5 num trabalho recém-criado, sem versão, e dei o
sétimo defeito por fechado. Ele está fechado para o cabeçalho e aberto para o
conteúdo.

Registro como achado desta revisão, não como culpa da 18-B: é dívida nomeada com
dono a definir (Trabalho ou a volta do renderizador).

## Os três itens que ele declara em aberto — meu julgamento

| item | limite ou dívida? |
|---|---|
| **teclado cobre a ação primária depois do pedido** | **limite, não dívida desta volta.** O atrito é idêntico antes e depois, e a jornada que eu medi não esbarra nele (o teclado físico do simulador reproduz o caso do teclado recolhido). Nomeado para outra volta: certo. |
| **`IntercambioTrabalhoView` com três ações sem cápsula** | **dívida do RUMO, e NÃO é grave** (`v18-reg3-intercambio-texto-solto.png`). Elas nunca tiveram cápsula para perder: são `Button` do sistema em `Tema.tinta` cheio, não `Pilula`, então **não caem para 1,53:1 nem somem** — desabilitadas, esmaecem como qualquer botão de texto do iOS. Ficam dentro de uma gaveta fechada, fora do caminho principal, e são rotas de perito (exportar/importar). O custo visível é outro: elas ficam três linhas abaixo de "Editar esta versão", que **é** cápsula — duas gramáticas para duas ações secundárias na mesma tela. Vale uma linha no RUMO para a volta do Intercâmbio; não bloqueia nada. |
| **comentário de `Botao.swift`** | **recusa legítima.** `Traco/Componentes` está fora do escopo declarado, e mexer lá para consertar um comentário abriria escopo. Uma linha da volta dos Componentes. |

## A pergunta do dono, respondida com evidência: VoiceOver ganhou ou perdeu?

**Ganhou, no todo, com uma perda estreita e nomeável.** Não é gosto; são quatro
fatos:

1. **O que se ganhou é grande e mensurável.** O estado bloqueado saiu de
   `tintaMorta` sobre papel — **1,53:1**, sem cápsula e sem forma de botão — para
   a cápsula carvão com **13,94:1**. Quem mais sofria com aquilo era baixa visão,
   que é um público maior que o de leitor de tela e o que a forma anterior
   punia mais.
2. **O motivo nunca dependeu só da dica.** O `Text` do motivo continua renderizado
   ao lado do botão (eu o li na tela em três estados). Para o VoiceOver ele está a
   **um deslize** do botão, antes e depois. A dica é canal a mais, não o único.
3. **O toque deixou de ser nada e virou rota.** `faltaCampo` põe o campo em
   primeiro respondedor, e o foco do VoiceOver acompanha — provado em
   `v18-reg3-toque-leva-ao-campo.png`. Com `.disabled()` isso era impossível: o
   botão não recebia toque nenhum.
4. **A perda, dita com precisão.** `.disabled(true)` marca `isEnabled = false`, e
   isso é mais que a palavra "indisponível": **Controle Assistivo e Acesso
   Total por Teclado pulam controles desabilitados**. Agora esses usuários pousam
   num controle que aceita ativação e não faz o que o rótulo promete. E a dica é
   canal fraco: só é falada se "Falar dicas" estiver ligada, e só depois de uma
   pausa.

**Recomendação (não bloqueante):** postar
`AccessibilityNotification.Announcement(motivoDoTravamento(o))` no ramo
bloqueado. Aí o motivo é falado independentemente da configuração de dicas, o
controle continua visível, com contraste e alcançável, e a perda do item 4 fecha
sem trazer de volta o 1,53:1.

## A outra pergunta: `PromessaDoAviso` está pronto para a ficha do Calendário?

**Quase — e falta um guarda que eu não tinha visto no G3. Não ligue as pontas
sem ele.**

O que já está pronto, e é mais do que eu disse antes: o tipo resolve a metade da
permissão, resolve a metade do relógio, e por ser `enum` de caso único impede
estruturalmente a contradição que a ficha exibe hoje (`CalendarioFicha.swift:127`
imprime "Toca hoje às 09:00." e `:142` acrescenta "nada vai tocar" **na mesma
tela**). Os insumos todos existem na ficha: `agenda.estadoDosAvisos`,
`Aviso.nome(_:diaInteiro:)`, `Aviso.promessa(...)`, `Aviso.instante(...)`.

**O que falta: compromisso que se repete.** `Aviso.instante(de:)` calcula o
alarme a partir de `evento.inicio` — a **origem da série**. Para "Correr toda
terça 6:30", `inicio` está no passado, então `instante <= agora` e
`PromessaDoAviso` devolveria **`jaPassou`: "esta ação ficou sem alarme"**. É
falso: `Revisoes.agendarCompromisso` arma, para `e.repete`, **um id por dia da
semana** (`idDoCompromisso(e.id, weekday:)`) e o alarme toca toda semana. O tipo
trocaria uma mentira por outra, no sentido contrário.

No Trabalho isso não acontece hoje: o ato monta
`EventoCalendario(titulo:inicio:fim:avisoMinutos:)` sem `repeteEm`, e
`repete` é `!repeteEm.isEmpty` — sempre `false`. **Por isso não é defeito desta
volta**; é o pré-requisito da próxima.

**O que a volta seguinte precisa fazer, na ordem:**

1. `jaPassou` só quando **não** repete: ou um guarda `!evento.repete` dentro de
   `para(...)`, ou o chamador passa `instante: nil` para série. Com teste.
2. Tornar `instante:` **obrigatório**, não `= nil`. Hoje um chamador que esqueça o
   parâmetro perde a correção **em silêncio** — e `semInstanteMantemOsQuatroCasos`
   canoniza esse silêncio em vez de impedi-lo.
3. Mover o tipo de `AgendamentoAcaoView.swift` para junto de `Avisos`/`Aviso`: ele
   não tem nada de view, e a ficha não deveria importar a folha do Trabalho.

Feito isso, uma volta fecha o defeito 2 da ficha e a contradição das duas frases,
e os 10 testes viram uns 14.

## Scorecard revisto

| dimensão | G3 | Re-G3 | por quê |
|---|---|---|---|
| Visão | 9 | **9** | inalterada |
| Contrato | 8 | **8** | os três números errados foram corrigidos e eu reconferi todos (742/396, 1119→1296, 599/371, 1247). **Mas** a ADR descreve a lei do bloqueio incluindo o desvio por `campoEmEdicao`, e o `trabalho-gerar` não o tem (achado A); e "o tipo fica completo para a ficha do Calendário" não é exato enquanto `jaPassou` não guardar série que se repete |
| Correção | 8 | **8** | `clean build` do zero (185 ações de compilação, **0** `warning:`) e **725 testes / 126 suítes verdes**, reproduzidos por mim; os 5 testes novos acertam as bordas. **Mas** o achado A é regressão de comportamento contra a volta 18, sem teste nem fluxo que a cubra |
| Jornada real | 9 | **9** | os estados do G2 revistos por mim no aparelho: lista vazia, lista, trabalho novo, pedido escrito, preparando, versão, bloqueado, ato preparado, agendamento, ato com alarme passado, AX5 com e sem versão |
| Design | 8 | **9** | o fantasma saiu da folha inteira, provado em quatro estados de campo vazio e no estado bloqueado; a cápsula e o contraste voltaram. O âmbar solto de `acaoDeSaida` continua, mas é dívida declarada de sistema e o julgamento dela é do G4 |
| Simplicidade | 8 | **9** | **5 toques e 2 digitações**, medidos à mão com captura por toque; 8→5 gavetas, decisão a 0 toques, caminho numa tela, e uma guarda que falha se o toque voltar |
| Movimento | 9 | **9** | inalterada; a 18-B não mexe em animação |
| Componentes | 8 | **9** | a folha deixou de depender do estado quebrado da `Pilula` (não há mais `.disabled()` nela); o recuo de `Pilula.larga` em AX5 e a `Secao` que falta seguem como dívida nomeada da V12, sem tocar `Traco/Componentes` |
| Acessibilidade | 8 | **8** | `.isSelected` está no código e a prova de árvore ficou **pendente de instrumento** (sem desconto, ordem do orquestrador). O desconto é o achado **B**: em AX5, documento **com versão** sangra pelos dois lados — o sétimo defeito está fechado para o cabeçalho e aberto para o conteúdo, e eu não tinha exercitado esse caso no G3 |
| Performance | n/a | **n/a** | mesmo motivo |
| Privacidade e autoria | 9 | **9** | reconferi por causa da remoção em massa de `.disabled()`: toda escrita continua passando por `aplicar` (acesso + `verificarAcesso` + `levouAoObstaculo`), o ramo de trabalho protegido está intacto, a cópia de recuperação revalida, e o produtor continua ao lado da versão (`c7.png`, "Apple Intelligence no aparelho") |
| Estado honesto | 8 | **8** | `jaPassou` provado nos dois sentidos na tela e o `.now` cru eliminado — era o meu achado 2 e está fechado. **Mas** o achado A é uma tela que enuncia uma regra e não a cumpre, que é a definição desta dimensão |
| Complexidade | 9 | **9** | +177 linhas na 18-B, e elas fecham seis achados nomeados; a única entrada sem defeito de origem é o `.id()` de rolagem, que é o alvo do desvio |
| Fora do app | n/a | **n/a** | mesmo motivo |
| Relato | 9 | **9** | a ADR e o relatório dizem o que perderam, corrigem os números errados da primeira redação e nomeiam as dívidas com dono. O achado A é omissão de código, não de relato honesto |

**Veredito: CORRIGIR ANTES — por UMA linha.** Cinco dos seis achados do G3 estão
fechados e verificados na tela, e três dimensões subiram (Design, Simplicidade,
Componentes). O que segura é o achado A, e ele é a mesma linha que
`trabalho-revisar` já tem. O achado B não segura o merge por si só, mas segura a
Acessibilidade em 8 até alguém decidir o dono.

## Para o orquestrador

| achado | dono | tamanho |
|---|---|---|
| **A** — `campoEmEdicao` no `trabalho-gerar` (+ um caso em `trabalho-bloqueio.yaml`) | implementador do Trabalho | **uma linha** e um assert |
| **B** — AX5 sangra com versão no documento | a definir: Trabalho ou renderizador | investigação de largura em `ConteudoTrabalhoView` |
| ADR: "o tipo fica completo para a ficha" | implementador do Trabalho | uma frase, com o guarda de série |
| `jaPassou` com série que se repete; `instante:` obrigatório; mover o tipo | volta da ficha do Calendário | pré-requisito, não desta volta |
| `AccessibilityNotification.Announcement` no ramo bloqueado | implementador do Trabalho | melhoria, não bloqueia |
| `IntercambioTrabalhoView` sem cápsula; comentário de `Botao.swift` | RUMO (Intercâmbio; Componentes) | dívida leve |

## Instrumento

- `xcodegen generate` → `.pbxproj` sem diferença.
- `xcodebuild clean build` no meu UDID sob `com-trava.sh`: `** BUILD SUCCEEDED **`,
  185 ações de compilação, **0** linhas `warning:`.
- `xcodebuild test`: `✔ Test run with 725 tests in 126 suites passed after
  8.216 seconds.` → `** TEST SUCCEEDED **`.
- Toques à mão (`cliclick` na janela trazida à frente) + `xcrun simctl io
  <UDID> screenshot` a cada toque. Nenhum fluxo maestro rodado para efeito de
  nota; a única tentativa de leitura de árvore devolveu o vizinho e está
  registrada acima como confirmação da lei.
- Texto restaurado a `large` (foi a `accessibility-extra-extra-extra-large` e
  voltou); aparência `light` inalterada. Nada editado no código, nada commitado.
- Capturas minhas: `v18-reg3-curva-zero-5-toques.png`,
  `v18-reg3-promessa-nao-mente-mais.png`,
  `v18-reg3-nada-some-com-campo-vazio.png`, `v18-reg3-toque-leva-ao-campo.png`,
  `v18-reg3-edicao-pendente-nao-bloqueia.png`,
  `v18-reg3-ax5-sangra-com-versao.png`, `v18-reg3-intercambio-texto-solto.png`.

## Re-G3, segunda passada — volta 18-C (topo `120af64`)

Mesmo revisor, mesmo aparelho: iPhone 17 Pro (teste 2) `B91C8DEF`, ligado e
desligado por mim; havia quatro simuladores de outros ligados e não desliguei
nenhum. Mesmo método da passada anterior: toque à mão com a janela do meu
simulador trazida à frente e `xcrun simctl io <MEU-UDID> screenshot` depois de
cada toque. Nenhuma nota depende de maestro.

### O achado A está fechado — e a causa era mais funda do que eu disse

Eu tinha escrito "uma linha, a mesma que `trabalho-revisar` já tem". Estava certo
no sintoma e **curto no diagnóstico**: o problema não era a linha faltando, eram
**duas listas de guardas copiadas** que divergiram quando a 18-B tirou o
`.disabled(travado)` de uma delas. Copiar a linha de volta teria deixado a classe
do defeito viva. A 18-C funde as duas rotas que chamam a IA em
`levouAoQueFalta(_:campoObrigatorio:)` e alinha `motivoDoTravamento` à mesma
ordem — salvamento, preparação em curso, edição pendente, campo vazio. Correção
melhor que a minha.

**Reproduzi o caso dos DOIS obstáculos juntos**, que é onde a 18-B nomeava um e
levava a outro (`v18-reg3b-dois-obstaculos.png`):

1. Intenção editada e **não guardada** (`edicaoPendente`) **e** campo do pedido
   **vazio** (`faltaCampo`) na mesma tela. A folha escreve *"Guarde a intenção ou
   a versão que está editando antes de pedir uma nova preparação."* — nomeia a
   **intenção**, não o campo vazio.
2. Toquei "Preparar com IA": **nenhuma preparação** começou e a folha rolou até a
   intenção.
3. Digitei em seguida, sem tocar em campo nenhum: o texto entrou **na intenção**.
   Nomeou um obstáculo e levou **a ele**.

Na 18-B esses mesmos passos diziam "guarde a intenção" e levavam o cursor ao
**pedido** — a divergência que eu derrubei. Está fechada.

E confirmei que o guarda desce a escada na mesma ordem em que a frase fala
(`v18-reg3b-motivo-e-guarda-na-mesma-ordem.png`): guardei a intenção, o motivo
**desceu um degrau** para *"Escreva acima o que a IA deve preparar."*, e o mesmo
toque passou a pôr o cursor **no pedido**. Frase e guarda no mesmo degrau, nos
dois degraus alcançáveis.

O degrau `!salvo` não é forçável neste instrumento (`salvo = false` só vem de
conflito de escrita ou de falha de gravação, `OficinaTrabalho:91` e `:112`). Mas
ele deixou de depender de teste: **há um guarda só**, e a ordem dele é
literalmente a ordem da frase — não sobrou onde divergir. Isso é mais forte que
uma captura.

`maestro/trabalho-bloqueio.yaml` ganhou o caso com `assertNotVisible` em
`trabalho-preparando` e a prova do foco por digitação; li o fluxo e ele guarda o
degrau da edição pendente com o pedido **preenchido** — o meu teste de tela
cobriu o outro degrau, com o pedido vazio. Rodá-lo hoje fotografaria o vizinho:
**pendente de instrumento, sem desconto**.

### As duas guardas

**`AccessibilityNotification.Announcement` — o mapeamento está certo.** Não é
gosto; é onde há e onde não há outra fala:

- `levouAoObstaculo` (salvamento falho) e `preparacaoEmCurso` **só rolavam a
  tela**. Sem mudança de foco não há nada que o VoiceOver leia sozinho: sem o
  anúncio, silêncio. Precisavam.
- `campoEmEdicao` move o foco para um campo em **outra seção**; ouvir "O que
  quero realizar" não explica por que a preparação não começou. Precisava.
- **`faltaCampo` não anuncia, e está certo.** Ali o destino **é** o obstáculo: o
  campo que recebe o cursor é o campo vazio, e o VoiceOver já lê o rótulo dele ao
  virar primeiro respondedor — o motivo é falado, nas palavras do próprio campo.
  Um `Announcement` por cima disputaria com a fala da mudança de foco e poderia
  cortá-la. Acrescentar ali pioraria.

**Os dois limites declarados são honestos, e eu subscrevo os dois.**

1. *"`Announcement` é canal do VoiceOver; Controle Assistivo sem VoiceOver
   continua sem a fala."* Verdadeiro e dito com precisão — é uma notificação de
   acessibilidade consumida pelo VoiceOver. E a ADR não finge que resolveu: diz
   que a perda "foi reduzida ao caso sem VoiceOver", e nomeia o que resta para
   essa pessoa (o desvio visível: foco e rolagem até o obstáculo). É a leitura
   correta do que eu tinha apontado.
2. *"o anúncio ser de fato FALADO não está provado."* Honesto, e **eu também não
   consegui fechar**: não havia simulador com VoiceOver ligado neste turno e o
   canal do maestro devolve o vizinho. O que está provado é o desvio — nenhuma
   preparação, foco no campo certo —, e a ADR diz exatamente isso, sem inflar.
   Fica como o limite do `negado` da volta 18: vive no código e na intenção, não
   na captura.

Uma observação de baixa severidade, para o G4 e não para aqui: `trabalho-revisar`
passou a compartilhar o guarda, mas **não tem linha de motivo escrita nem
`accessibilityHint`** como `trabalho-gerar` tem. Quem enxerga e toca ali recebe
só o desvio (rolagem e foco). Não é desonestidade — a tela não enuncia regra
nenhuma nesse ponto e o destino carrega o próprio texto —, é acabamento.

### `PromessaDoAviso`: **sim, está pronto para a ficha do Calendário**

Os dois pré-requisitos que eu levantei estão fechados, e conferi os dois no
código e nos testes:

1. **`jaPassou` guardado por `!repete`** — `if let instante, !repete, instante <= agora`.
   Sem ele, "Correr toda terça 6:30" receberia "esta ação ficou sem alarme"
   enquanto `Revisoes.agendarCompromisso` arma um id por dia da semana e o alarme
   toca toda semana. Três testes novos cobrem o corte pelos três lados: série que
   repete não fica sem alarme (e o mesmo instante **sem** série continua
   `jaPassou`), série não atropela o beco de quem desligou os avisos, série sem
   aviso pedido continua sem aviso. 10 → 13 testes.
2. **`instante:` e `repete:` sem valor padrão.** Era o silêncio que eu tinha
   apontado: um chamador que esquecesse `instante:` perdia a correção do relógio
   inteira sem erro de compilação. Agora a ficha não se liga sem decidir os dois,
   e a justificativa está escrita ("`false` é o lado que mente").

O terceiro item da minha lista — mover o tipo de `AgendamentoAcaoView.swift` para
junto de `Avisos`/`Aviso` — ficou declarado como primeiro passo da volta da
ficha. Concordo: é higiene estrutural, não pré-requisito de correção.

**E acrescento um terceiro pré-requisito que só aparece do lado da ficha**, achado
nesta passada: `CalendarioAgenda.estadoDosAvisos` é `Avisos.Estado` **não
opcional, com valor inicial `.concedido`** (`CalendarioAgenda.swift:30`), e só
depois `Avisos.estado()` responde. `PromessaDoAviso` tem o caso `nil` justamente
para "leitura pendente" (`.seDeixarem`, "se você permitir…"), mas a ficha **nunca
consegue expressá-lo**: na janela antes da leitura voltar ela afirmaria "Toca …"
por padrão otimista. A folha do Trabalho acertou a forma — `@State private var
permissao: Avisos.Estado?` começando em `nil`. A volta da ficha precisa tornar
`estadoDosAvisos` opcional (ou nascer em `.naoPerguntado`) antes de consumir o
tipo, senão importa a correção e mantém a janela de promessa não autorizada.

### Instrumento

- `xcodegen generate` → `.pbxproj` sem diferença.
- `xcodebuild clean build` no meu UDID sob `com-trava.sh`: **185 ações de
  compilação, 0 linhas `warning:`**, `** BUILD SUCCEEDED **`.
- `xcodebuild test`: `✔ Test run with 728 tests in 126 suites passed after
  8.118 seconds.` → `** TEST SUCCEEDED **`. 13 testes em `PromessaDoAvisoTests`.
- Números da ADR reconferidos e **corretos**: `+73/−11` nos dois arquivos de view
  (19+54 / 5+6), **1296 → 1313** linhas sem comentário, `+58/−13` nos testes,
  48 linhas de fluxo.
- Texto `large` e aparência `light` inalterados. Nada editado no código, nada
  commitado.
- Capturas minhas: `v18-reg3b-dois-obstaculos.png`,
  `v18-reg3b-motivo-e-guarda-na-mesma-ordem.png`.

### Notas revistas e veredito

| dimensão | 1ª passada | agora | por quê |
|---|---|---|---|
| **Contrato** | 8 | **9** | a ADR corrige por escrito a própria frase que eu tinha derrubado ("a primeira redação dizia 'completo' e a re-G3 mostrou que não era"), a lei do bloqueio que ela enuncia é a que o código executa, e os quatro números que reconferi batem. Os limites não provados estão declarados no lugar certo |
| **Correção** | 8 | **9** | `clean build` do zero com 0 aviso e **728/126 verdes**, reproduzidos por mim; a regressão foi fechada na raiz (um guarda só, não uma linha copiada) e reproduzi o fecho na tela nos dois degraus alcançáveis; o caso entrou no fluxo de regressão |
| **Estado honesto** | 8 | **9** | a folha cumpre a regra que enuncia, provado com os dois obstáculos juntos, que era o caso exato que a 18-B errava; e a frase desce o degrau junto com o guarda |
| Visão · Jornada real · Design · Simplicidade · Movimento · Componentes · Privacidade · Complexidade · Relato | 9 | **9** | inalteradas |
| Acessibilidade | 8 | **9** | o `.isSelected` e o anúncio seguem **pendentes de instrumento**, e por ordem do orquestrador isso não desconta. O que me fazia descontar era o achado **B** (AX5 sangra com versão), e ele saiu do escopo desta volta: é pré-existente, não está no diff, e vai para o RUMO |
| Performance · Fora do app | n/a | **n/a** | mesmos motivos |

**Veredito: APROVADO no G3.** Nenhuma dimensão abaixo de 9. Sobe para o **G4 de
design**, que é onde a tela redesenhada será julgada de verdade.

**O que segue aberto, e não bloqueia:** o achado B (AX5 com versão) no RUMO, com
dono a definir; `trabalho-revisar` sem motivo escrito, para o G4; mover
`PromessaDoAviso` e destravar `estadoDosAvisos` como primeiros passos da volta da
ficha do Calendário; e duas provas pendentes de instrumento (o caso novo do
`trabalho-bloqueio.yaml` e a fala do anúncio) para quando houver um simulador
sozinho e um com VoiceOver.
