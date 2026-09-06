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
