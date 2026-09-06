# G3 — volta A-5 (léxico da escrita pessoal, ADR 2026-09-06i)

Revisor: Claude Opus 5, sessão independente, 06/09/2026 19:25–19:50.
Branch `Vitorepf/volta-a5-lexico` em `2ad9719`, sobre main `a039100`.
Simulador de teste: **iPhone 17 Pro (teste 4) `A1DF082C`** — já estava ligado
quando cheguei (não fui eu que liguei), instalei e rodei nele, e o deixei como
achei. iPhone 17 `1A46B6D3` do dono: **intocado**. Todo `xcodebuild test` por
`ferramentas/orca/com-trava.sh`. **Nada editado, nada commitado** — este arquivo
e `a5-rev-woop-medo.png` ficam untracked em `ferramentas/orca/`.

---

## Veredito

**CORRIGIR ANTES** — por uma dimensão só, e é a dimensão que esta volta existe
para servir: **Privacidade e autoria (7)** e **Correção (7)**.

A volta conserta o que prometeu consertar: a nota comum de trabalho volta a
achar a forma, e eu vi o caso do WOOP com medo funcionando na tela. Mas o
estreitamento **não foi de graça** — ele foi pago na direção cara, e o preço não
foi medido. A régua das 57 protegidas não cobre a região onde o pagamento
acontece, e por isso passou verde.

**Onde o ponto de equilíbrio ficou: longe demais para o lado do trabalho.**
Não porque desabafo nu escapa (isso é barato: cai no silêncio de sempre), mas
porque **desabafo com gancho de roteamento** escapa — e esse é exatamente o
caso em que escapar custa quatro campos.

---

## 1. Instrumento

| prova | resultado |
|---|---|
| `com-trava.sh xcodebuild test -scheme Traco -destination id=A1DF082C -derivedDataPath /tmp/dd-a5-rev` | `✔ Test run with 751 tests in 128 suites passed after 7.077 seconds.` / `** TEST SUCCEEDED **` |
| avisos de compilação | **2, ambos pré-existentes e fora do escopo**: `TracoTests/ConferenciaTrabalhoTests.swift:381` (`variable 'd'` / `variable 'p'` never mutated). Nenhum aviso em `AnaliseLocal.swift`, `PaginaView.swift`, `PerfilView.swift` ou `EscritaPessoalTests.swift`. |
| `error:` no log | 18 ocorrências, **todas ruído do simulador** (`CHHapticPattern … hapticpatternlibrary.plist`), nenhuma de compilação. |
| maestro | **não usei**, e não me apoio em nenhuma evidência dele: cinco simuladores ligados na máquina (`teste 2`, `teste 3`, `17e`, `iPhone 17 Pro` do dono, `teste 4`). Lei do instrumento da ESTEIRA respeitada. |
| toque por coordenada | feito **depois de erguer a janela do `teste 4`** por `AXRaise` e conferindo cada passo com `xcrun simctl io <meu UDID> screenshot`. A janela do dono fica em x 1272–1674; a minha em 754–1156, sem sobreposição. |

Método das medições abaixo: replica exata da guarda em Swift/Foundation que
**lê os literais de regex direto do `AnaliseLocal.swift`** (nada transcrito à
mão) e o laço do `detectarGesto` contra o `Metodos.json` real, nas duas versões
(A-5 e `main`). Scripts em
`/tmp/claude-501/.../scratchpad/{guarda.swift,rota.swift,rota-main.swift}`.
Confirmei a fidelidade da replica contra as 57 frases protegidas do teste: as 57
dão `silencio` na replica, igual ao que a suíte afirma.

---

## 2. Achados

### ALTO-1 — o estreitamento perdeu o desabafo COM GANCHO, e é aí que doi

Inventei 20 desabafos novos que usam só vocabulário 1b (`medo`, `cansad`,
`sozinh`, `ansios`, `exaust`, `vazi`, `pesa`) **em frases que também carregam um
gancho de roteamento** ("Quero…", "Sempre que…", "Toda vez que…", "Percebi
que…", "Hoje eu preciso…", "Meu objetivo é…", "Não entendi…"). Esse recorte não
existe em nenhuma das 57.

**Em `main`: 19 dos 20 iam para o silêncio. Em A-5: 18 dos 20 são VESTIDOS.**

| a nota | main | A-5 |
|---|---|---|
| "Quero sumir uns dias, ando muito cansado ultimamente." | silêncio | **woop** |
| "Não consigo parar de pensar que estou sozinha demais." | silêncio | **seEntão** |
| "Percebi que estou sozinha faz meses e ninguém notou." | silêncio | **notaPermanente** |
| "Hoje eu preciso aguentar o dia, mas estou cansado demais pra isso." | silêncio | **dia** |
| "Não entendi por que ando tão vazio ultimamente." | silêncio | **feynman** |
| "Toda vez que ela não responde eu fico com um medo besta de ter feito algo errado." | silêncio | **seEntão** |
| "Preciso começar a dormir, ando ansioso desde que ela foi embora." | silêncio | **woop** |
| "Sempre que meu pai liga eu fico exausto por dois dias." | silêncio | **seEntão** |
| "Percebi que ando vazio faz tempo, e ninguém em casa notou nada." | silêncio | **notaPermanente** |
| "Faz três semanas que eu acordo cansado, olho pro app que eu preciso construir e não consigo encostar nele, e isso me deixa pior a cada dia que passa." (148 car.) | silêncio | **spec** |

(+8 outras no mesmo padrão; as duas que continuam protegidas são "Meu dia foi um
vazio só…" e "Quero parar de me sentir tão sozinho… é quando pesa mais", ambas
salvas pelo ramo `\b(o|um|esse|…) vazio\b`.)

**Por que isto é o achado e não uma curiosidade.** A ADR escolhe explicitamente
o lado: *"silêncio numa nota de trabalho custa um toque; vestir um desabafo
carimba quatro campos de exercício sobre o que o autor acabou de sentir."*
Concordo com a assimetria — fui eu que a estabeleci. Mas ela foi aplicada só
como justificativa e não como medida: **a volta reduziu o silêncio indevido em 5
casos dos meus 20 de trabalho, e aumentou o vestir indevido em 18 dos meus 20 de
desabafo.** Nessa moeda o saldo é negativo.

**A causa mecânica é nomeável.** `lexicoDoSentimentoNoAutor` exige que o
complemento seja pronome, pontuação, `e `, ou uma de dez caudas fixas. Em
português a cauda mais comum de um desabafo não está na lista:

- **intensificador posposto**: "cansado **demais**", "sozinha **demais**"
- **advérbio de tempo**: "cansado **ultimamente**", "ansioso **o dia inteiro**",
  "vazio **faz tempo**"
- **verbos de estado que ficaram de fora**: `fico com medo` (`fico` está na
  primeira alternativa mas não na do `medo`), `dá medo`, `bate um medo`,
  `morrendo de medo`, `acordo cansado` (só `acordei` entrou)
- **`ansiedade`** não casa `ansios`; **`cansaço`** não casa `cansad`.

Não é preciso abrir a guarda de volta: bastam a cauda de intensificador/tempo,
`fico|dá|bate` no ramo do `medo`, e os substantivos `ansiedade`/`cansaço`. O
critério "sentimento como assunto" continua de pé — o que falta é a lista de
caudas ser representativa do idioma, não da amostra.

**O que isto diz da régua nova:** ela é boa e mediu o que se propôs, mas o
critério da 1b só é exercitado por **7 das 57** frases protegidas
(5 por `1b+autor`, 1 por densidade, 1 por omissão; as outras 50 são salvas por
1a/2/3/4/5). O ramo mais novo do código é o menos coberto pela régua mais velha.

### ALTO-2 — `vazi[oa]` conta a própria flexão como "duas palavras diferentes"

`duasDeDuplaVida` guarda o **texto casado** num `Set<Substring>`. Todos os
radicais da 1b são radicais de verdade (`cansad`, `ansios`, `exaust`, `sozinh`,
`pesa`, `medo`) e por isso duas flexões colapsam num item só — **menos
`vazi[oa]`**, que captura a vogal final. Consequência, medida:

```
FALHA  «A lista vazia e o estado vazio da tela.»       → [1b+densidade] pessoal
FALHA  «A lista vazia e o estado vazio do app.»        → [1b+densidade] pessoal
ok     «A tela cansada e a lista cansada do app.»      → trabalho
ok     «O usuário ansioso e a fila ansiosa do app.»    → trabalho
```

Uma frase com `vazio` **e** `vazia` — que é o vocabulário exato da tela de
estado vazio que a própria ADR usa como exemplo canônico — dispara a densidade
sozinha. O código contradiz o comentário que ele carrega ("duas palavras
DIFERENTES") e a ADR. Conserto de um caractere: `vazi` em vez de `vazi[oa]` em
`lexicoDeDuplaVida` (o `vazi[oa]` do `lexicoDoSentimentoNoAutor` pode ficar).

### MÉDIO-3 — a densidade cala 15 das minhas 20 notas de trabalho (mas NÃO é regressão)

Escrevi 20 notas comuns de trabalho novas. Em A-5, **15 continuam caladas** — 13
delas pela regra de densidade (duas palavras de dupla vida numa nota de sistema é
comum: "estado vazio" + "fila vazia", "time exausto" + "fila vazia", "o medo é o
servidor cair" + "equipe cansada") e 2 pelo `1b+autor` ("Tenho medo de que o
deploy quebre a produção", "Estou cansado, mas terminei o relatório").

**Sou obrigado a dizer o outro lado, e é favorável ao implementador:** rodei as
mesmas 20 contra `main` e **as 20 eram caladas lá também**. A volta resgata 5 e
não cala nenhuma nota nova. Isto é **dívida residual, não regressão** — e é a
mesma dívida que a ADR já declara no "Fora". Fica registrado para a próxima
volta, não para esta.

Das 15 ainda caladas, 8 chegariam a uma forma real se a guarda não existisse
(`spec` ×5, `premortem`, `decisao`, `leitura`).

### MÉDIO-4 — a ADR invoca a lei do instrumento para uma captura que o instrumento permite

O Portão da ADR diz: *"a captura das duas fica pendente de instrumento — com
seis simuladores ligados o maestro não isola, e a lei da ESTEIRA proíbe apoiar
nota nessa condição."* A leitura está meio certa e meio errada: a lei da ESTEIRA
proíbe apoiar nota em **evidência do maestro**, e no mesmo parágrafo **nomeia o
substituto**: *"Prova de tela é `xcrun simctl io booted screenshot`"*, que é
por-UDID e não sofre do problema. Peguei o instrumento e capturei.

**Meu julgamento sobre a pergunta que veio junto ("captura é necessária ou é
ritual?"):**

- Para o **léxico**, é **ritual**. Uma decisão de roteamento provada por 110
  frases em teste não fica mais verdadeira numa foto; a foto mostra um caso e o
  teste mostra 110. Concordo com não fotografar a régua.
- Para o **M-2**, **não é ritual**: `confirmationDialog` é texto que o dono lê
  na tela, num diálogo destrutivo. É a única superfície visível da volta.
- E há uma captura que valia mais que as duas, que ninguém pediu e que é a que o
  dono ia querer ver: **o caso do WOOP com medo funcionando**. Fiz.

**Captura minha, conferida (não só existente):**
`ferramentas/orca/a5-rev-woop-medo.png` — nota "Quero correr de manha, mas o
medo de me machucar me trava." digitada no editor, `Analisar`, e o cartão que
aparece:

> **WOOP** — "Qual é o hábito ou o medo seu que vai impedir — não o relógio, não
> os outros?" · **Abrir a forma WOOP**

O caso constrangedor da ADR está consertado **na tela**, não só no teste.

**O que eu não consegui capturar, e digo por quê:** o diálogo do M-2. Cheguei ao
Perfil (`teste 4`, janela erguida, capturas conferindo cada passo) e o rolamento
por `cliclick` não pegou em duas tentativas com temporizações diferentes. Parei
em vez de insistir. Portanto o M-2 continua **verdadeiro por leitura e não por
foto** — e a leitura eu fiz: `PerfilView.swift:108` diz "Esquecer tudo o que o
Traço registrou?" e `:161` diz "O que o Traço registrou", a mesma palavra, com
o corpo "Os sinais somem do aparelho. As notas ficam.". Não desconta nota (o
instrumento é o mesmo para mim e para ele), mas fica dito.

### BAIXO-5 — escopo do `PaginaView.swift` conferido, sem colisão com a volta 12

Confirmado item por item:

- O diff da A-5 em `PaginaView.swift` é **exatamente uma linha**
  (`accessibilityHint` do botão da Lente, 1 inserção / 1 remoção). Sem layout,
  sem `Tema`, sem estado.
- A string nova bate com a tela: `LenteView.swift:133` diz "Palavras de apoio"
  (com o rodapé "contadas por palavra inteira") e `:138` diz "Frases de outro".
  A dica voltou a nomear o que a tela mostra. **Confirmado contra a fonte da
  tela, não contra a menção.**
- **Volta 12** (`Vitorepf/volta-12-pagina`, 105+/78−) não toca esta linha: os
  seus hunks em `PaginaView.swift` são `@@ -17`, `-28`, `-53`, `-283`, `-370`,
  `-390`, `-490`, `-564`, `-577`, `-720`; a A-5 mexe em `-485`, **adjacente e
  fora**. `git merge-tree --write-tree Vitorepf/volta-12-pagina HEAD`: conflito
  só em `SPEC.md` e `EVOLUCAO.md` (apêndice de ADR, normal entre voltas
  paralelas), **nenhum em `PaginaView.swift`**.

---

## 3. Scorecard

| dimensão | nota | evidência |
|---|---|---|
| **Visão** | **9** | Fecha lacuna nomeada e medida (regressão da 06h que estava em main); diff do EVOLUCAO coerente; volta "multiplicar" declarada. |
| **Contrato** | **8** | ADR 06i é longa, honesta e declara o "Fora" (inclusive `\bpesa`/"pesado", `exaust` não medido em nota real, e as 47 serem do autor). Desconto: o código contradiz a própria ADR em `vazi[oa]` (ALTO-2), e o Portão invoca a lei do instrumento para uma captura que o instrumento permite (MÉDIO-4). |
| **Correção** | **7** | 751/0 em 128 suítes, build sem aviso novo, três testes novos + régua inversa de 47 com 2 por porta cobrada contra `Catalogo.doApp`. **Mas** 18 de 20 desabafos novos que main protegia passam a ser vestidos (ALTO-1), e a régua nova não cobre esse recorte. Abaixo de 9. |
| **Jornada real** | **8** | Nenhuma captura do implementador. Capturei o caso central eu mesmo e o conteúdo confere (`a5-rev-woop-medo.png`). O diálogo do M-2, única superfície visível da volta, segue sem foto — minha também não saiu. |
| **Design** | **9** | As seis fases do `design-router` citadas na ADR e **conferidas contra a tela**: "Sistema" alega reusar `LenteView:133/138` e `PerfilView:161` — os três existem e dizem exatamente o que a ADR afirma. Duas strings, zero layout, zero token. Ancorar/Construir/Mover/Julgar/Portão coerentes com o tamanho da mudança. |
| **Simplicidade** | **8** | `curva-zero` não foi carregada e a volta **mexe no que o autor encontra depois de escrever** — o caminho comum melhorou (5 notas de trabalho a mais chegam à forma), mas o "atrito observado" e a "recuperação" não foram nomeados: quando a guarda cala, o que o autor vê é nada, e o custo de "um toque" é afirmado sem ser mostrado. Não derrubo abaixo de 8 porque não é volta de jornada, folha ou formulário. |
| **Movimento** | **n/a** | Copy e regex não animam. |
| **Componentes** | **n/a** | Nenhum componente criado ou alterado. |
| **Acessibilidade** | **9** | M-3 é ganho real de VoiceOver: a dica passa a usar as palavras das seções da tela. Nenhum contraste, alvo ou Dynamic Type tocado. |
| **Performance** | **9** | `duasDeDuplaVida` é um laço linear sobre casamentos de uma regex curta, num caminho já regex-pesado e disparado por gesto (`Analisar`), não por tecla. Sem medida de Instruments porque não toca lista, editor nem parser. |
| **Privacidade e autoria** | **7** | Esta é a dimensão da volta e é onde ela sangra: a guarda **é** a fronteira da escrita pessoal, e ela ficou mais estreita do lado caro. 18/20 (ALTO-1). O resto está intacto: a guarda continua fora do `Metodos.json` editável, `Sessao.escolher` continua calando o modelo com precedência sobre o veredito remoto, nada foi movido para arquivo do autor. Abaixo de 9. |
| **Estado honesto** | **9** | A ADR não alega o que não mediu; o "Fora" nomeia três limites reais. Nenhum estado de tela alterado. |
| **Complexidade** | **9** | +50 linhas líquidas em `AnaliseLocal.swift`, +115 em teste, zero arquivo e zero dependência novos. Uma função privada de 9 linhas para a densidade. Proporcional à lacuna. |
| **Fora do app** | **n/a** | Nenhuma superfície fora do app tocada. |
| **Relato** | **9** | Mensagem de commit e ADR legíveis por quem não abre terminal, com o número que importa ("15 das 47 → 0") e o caso em português claro. |

**Duas dimensões abaixo de 9 → CORRIGIR ANTES.**

---

## 4. O que corrigir, na ordem

1. **ALTO-1** — alargar `lexicoDoSentimentoNoAutor` na cauda, não no radical:
   intensificador posposto (`demais`, `pra caramba`), advérbio de tempo
   (`ultimamente`, `hoje`, `faz tempo`, `o dia inteiro`, `de novo` já está),
   `fico|dá|bate|acordo` no ramo do `medo`, e `ansiedade`/`cansaço` como
   substantivos. **E acrescentar à régua protegida um bloco novo: desabafo COM
   gancho de roteamento** — é o recorte que faltava nas 57 e é onde o preço é
   pago. Sugiro no mínimo 10, uma por gancho (`^quero`, `sempre que`,
   `toda vez`, `percebi`, `hoje eu preciso`, `meu objetivo`, `não entendi`,
   `preciso começar`, `preciso parar`, `\bapp\b|construir`).
2. **ALTO-2** — `vazi[oa]` → `vazi` em `lexicoDeDuplaVida`, com um caso na régua
   inversa ("A lista vazia e o estado vazio da tela.").
3. **MÉDIO-4** — capturar o diálogo do Perfil (`simctl io <UDID> screenshot`,
   janela erguida) e trocar o parágrafo do Portão da ADR: a lei da ESTEIRA
   proíbe apoiar nota em maestro, e no mesmo parágrafo aponta o substituto.
4. **MÉDIO-3** — registrar a densidade em nota de sistema como dívida no "Fora"
   da 06i (não é regressão; é o que sobrou).

Nada disto muda a decisão de arquitetura da 06i. O critério "sentimento como
assunto" é o critério certo, é explicável em duas frases e vai ser mantido daqui
a meses sem mistério — o que ele ainda não tem é a lista de caudas do idioma
real, e uma régua que cubra o lado caro.

---
---

# RE-G3 — volta A-5-B (`650a908`), mesmo revisor

Claude Opus 5, sessão independente, 06/09/2026 20:10–20:40. Branch em `650a908`,
main em `3ab0216`. **iPhone 17 Pro (teste 4) `A1DF082C` ligado por mim** (estava
desligado quando cheguei) **e desligado ao fim**. `xcodebuild test` pelo
`com-trava.sh` **de main** (o deste worktree ainda é o velho, sem retomada de
trava órfã — ver BAIXO-4). Nada editado no código, nada commitado.

## Veredito: CORRIGIR ANTES — mas é lista mínima, três linhas

Os dois ALTOs foram atacados de verdade. **ALTO-2 está fechado, sem ressalva.**
**ALTO-1 está 10 de 10 nos casos que citei por extenso** — conferi um por um,
não aceitei a afirmação. O bloco `comGancho` é a peça certa e é a lição da
rodada: ele cobra as duas metades (a nota cala **e** o gancho da porta declarada
casa mesmo), que é o que faz uma régua medir alguma coisa.

O que segura o portão é curto e tem conserto testado: **a cauda nova reintroduz
duas notas de trabalho caladas**, uma delas o exemplo canônico da própria ADR.

## Instrumento

| prova | resultado |
|---|---|
| `com-trava.sh xcodebuild test -scheme Traco -destination id=A1DF082C -derivedDataPath /tmp/dd-a5b-rev` | `✔ Test run with 752 tests in 128 suites passed after 8.868 seconds.` / `** TEST SUCCEEDED **` |
| avisos | os mesmos **2 pré-existentes** de `ConferenciaTrabalhoTests.swift:381`. Nenhum novo. |
| réplica | desta vez **copiei o núcleo verbatim** do `AnaliseLocal.swift` (linhas 113–215) para um binário Swift, em vez de extrair literais — o `lexicoDoSentimentoNoAutor` virou concatenação e o compilador do Swift é quem avalia. Fidelidade máxima. |
| as três réguas na minha réplica | **115 frases (67 protegidas+gancho + 48 de trabalho): 0 problemas.** Reproduzo o que a suíte afirma, no catálogo real. |
| maestro | não usei. Sete simuladores ligados. |

## O que confirmei

**ALTO-2 — fechado.** `vazi[oa]` → `vazi`. Medido:

```
ok  «A lista vazia e o estado vazio da tela.»   → spec  (era silêncio)
ok  «A lista vazia e o estado vazio do app.»    → spec
ok  «O módulo esvazia a fila e fica vazio no fim do dia.» → spec
```

E ganhou entrada na régua inversa. Um caractere, resolvido, com prova. Nada a
acrescentar.

**ALTO-1 — 10 de 10 nos casos nomeados.** Rodei os meus 20 da terceira passada
contra `650a908`: **12 protegidos** (eram 2), e **os 10 que eu havia citado por
extenso estão todos calados**, incluindo os que ele não pôs no `comGancho`
("Não consigo parar de pensar que estou sozinha demais.", "Percebi que ando
vazio faz tempo…"). A afirmação dele é verdadeira e eu a verifiquei sozinho.

Dos 8 que sobram, **4 eu concedo**: "Meu objetivo é parar de acordar exausto
todo santo dia", "Preciso parar de me comparar…", "Meu objetivo é aguentar essa
semana…", "Sempre que fico ansioso eu não saio do quarto…" são frases que WOOP e
Se–então levam **com razão** — objetivo mais obstáculo é literalmente a forma. Eu
as tinha contado como perda e estava sendo generoso comigo mesmo. Os outros 4
são perda real e estão abaixo.

**M-2 — captura conferida no conteúdo, não na existência.** Abri
`ferramentas/orca/a5b-m2-esquecer-dialogo.png`: o diálogo diz **"Esquecer tudo o
que o Traço registrou?"** sobre **"Os sinais somem do aparelho. As notas
ficam."**, e no mesmo enquadramento, logo acima, o rótulo **"O que o Traço
registrou — contagem, não conclusão"**. A foto prova as duas pontas do argumento
numa imagem só, que é mais do que eu pedi. E o parágrafo do Portão da ADR foi
corrigido com a distinção certa: a lei tira o maestro, não a captura.

## A recusa do `dá medo` — o julgamento pedido

**Ele está certo no fato e errado no enquadramento. Eu não mantenho o meu item
como escrito.**

Medi as três formas, com o pré-mortem da régua inversa dele dentro do corpus:

| forma | pré-mortem "o que me dá medo é ninguém avisar" | desabafo "me dá um medo que trava tudo" (+ gancho) |
|---|---|---|
| hoje (sem `dá medo`) | ✅ chega a `premortem` | ❌ vestido de `seEntao` |
| **`d[áa] medo` largo** (o que eu pedi) | ❌ **calado** — perde a forma | ✅ calado |
| **discriminante** (abaixo) | ✅ chega a `premortem` | ✅ calado |

**Então a recusa foi correta:** o `dá medo` largo custa uma forma real numa nota
de trabalho, e ele mediu isso antes de recusar. Recusar item de revisor com
motivo medido é exatamente o comportamento certo, e digo isso sem ressalva.

**Mas não é arbitragem, e é aí que eu discordo.** A ADR escreve o motivo da
recusa e, na mesma frase, nomeia o discriminador sem implementá-lo: *"'me dá
medo' com sujeito nomeado ('o que me dá medo é ninguém avisar') é obstáculo
dentro de uma intenção — a mesma linha PREDICAR/NOMEAR que a ADR já traça."*
Está certo, e essa linha é escrevível:

- **NOMEAR** — o medo é sujeito de uma oração copulativa: "**o que** me dá medo
  **é** X". Nunca leva artigo indefinido, nunca abre frase, nunca vem com `de` +
  infinitivo.
- **PREDICAR** — "me dá **um** medo", "dá medo **de** encarar", "**Dá medo.**"
  em início de frase.

```
d[áa] (um |uma )medo | d[áa] medo de | (^|[.!?]\s*)d[áa] medo
```

Medido nos dois sentidos: **11 de 11** — as 3 formulações de trabalho com
"dá medo" continuam roteando (incluindo o pré-mortem da régua inversa, o
contrato e "o que dá medo de verdade nesse plano"), e as 5 de desabafo passam a
ser caladas. E contra **as 115 frases das três réguas existentes: 0 mudanças,
0 custo.** O padrão é grátis.

**Sobre a assimetria, que é o que você perguntou.** Ela não decide este caso, e
o meu próprio G3 explica por quê: eu mostrei que **um desabafo que escapa só
custa quatro campos se ele também tiver gancho de roteamento.** "Dá medo de
encarar amanhã." cai no silêncio com ou sem guarda — custo zero. O que pesa não
é "desabafo vs trabalho", é **se a nota tem porta**. À primeira vista a
assimetria empurra para incluir `dá medo`; a medida mostra que a primeira vista
erra nas duas pontas — incluir largo custa uma forma (medido), excluir custa
quatro campos em 4 frases minhas (medido).

A conclusão é metodológica e vale além deste caso: **a assimetria é critério de
desempate de último recurso, não argumento de primeira instância.** Ela só entra
depois de provado que nenhuma regra separa os dois lados. Usá-la antes dessa
prova transforma um problema de léxico, que tem conserto de uma linha, em perda
permanente de política. Aqui a prova não foi feita — e quando eu a fiz, a
contradição não existia.

**Portanto: não é o primeiro caso de arbitragem da ADR. A ADR ainda não tem
nenhum,** e é melhor assim.

## Achados novos (quarta passada, 36 frases inéditas)

### ALTO-3 — a cauda derruba o teste do objeto, e o exemplo é o da própria ADR

A cauda é conferida **imediatamente depois do adjetivo**, então um intensificador
posposto curto-circuita o teste que o critério inteiro usa para separar trabalho
de desabafo:

```
não casa  «estou cansado desse módulo cheio de casos especiais.»          ← a ADR: TRABALHO ✔
CASA      «estou cansado demais desse módulo para reescrever a função.»   ← agora PESSOAL ✘
```

A segunda é a primeira com uma palavra a mais, e passa de `spec` a silêncio. É a
frase que a ADR usa como exemplo canônico do lado trabalho, em
`lexicoDoSentimentoNoAutor` e em `aPalavraDeDuplaVidaSozinhaNaoDecide`. Mesma
classe do ALTO-2: **o código contradiz a ADR que o descreve.** Regressão nova da
06i-B (em `main` e na A-5 essa nota roteava).

### ALTO-4 — falta `\b` antes da lista de verbos, e o gerúndio entrou pela porta

`(estou|tô|estava|ando|…)` não tem borda de palavra à esquerda, então `ando `
casa **dentro de qualquer gerúndio**. Até a 06i-B o caminho era inalcançável
porque "cansado demais" não tinha cauda; agora é alcançável:

```
CASA «ando cansado demais»   ←  terminei de escrever o parser trabalhando cansado demais, vou revisar o módulo amanhã.
CASA «ando ansioso demais»   ←  fiquei pensando ansioso demais no resultado do deploy.
```

Ambas são notas de trabalho que perdem a porta (`spec`). É o mesmo defeito que a
06i consertou no `senti` — borda de palavra — repetido no vizinho.

### O conserto dos dois, testado por mim

Três edições, nenhuma reabre o radical:

1. `\b` na frente da lista de verbos;
2. o intensificador vira **transparente** em vez de terminador —
   `…(sozinh[oa]|cansad[oa]|vazi[oa]|exaust[oa]|ansios[oa])\b\s*(demais|pra caramba|ultimamente)?\s*` + cauda, e saem `demais|pra caramba|ultimamente` da lista de terminadores;
3. entra `pra isso` na lista de terminadores (é complemento pronominal, e é o que
   `p("Estou cansado demais pra isso.")` precisa).

Medido com o núcleo modificado:

| corpus | hoje | com o conserto |
|---|---|---|
| 115 frases das três réguas | 0 problemas | **0 problemas** |
| as 4 notas de trabalho caladas pela cauda | 4 caladas | **0 caladas** |
| meus 20 com gancho (3ª passada) | 8 vestidos | 8 vestidos (inalterado) |
| meus 36 da 4ª passada | 14 problemas | 14 (inalterado) |

Estritamente melhor: recupera as quatro e não custa nada em lugar nenhum.

### MÉDIO-5 — `bate` entrou no ramo do medo e não no dos substantivos

`bate|bateu` foi acrescentado a `medo`, mas o ramo de `ansiedade|cansaço` tem só
`(estou|tô|ando|vivo|fiquei|fico)`. Consequência:

```
vestido de seEntao  «Toda vez que eu abro o computador bate um cansaço que não é do corpo.»
vestido de seEntao  «Percebi que bate uma ansiedade toda vez que ele chega em casa.»
```

Assimetria da própria correção. Acrescentar `bate|bateu|dá|deu` ao ramo dos dois
substantivos fecha as duas (`dá` aqui não tem o problema do `medo`: não existe
"o que me dá cansaço é X" como forma de trabalho).

### MÉDIO-6 — o ramo do `pesa` ficou sem cauda

`\b(isso|isto|tudo|a vida|o dia|cada dia|essa semana) pesa\b` exige sujeito
listado. "Hoje eu preciso fingir que está tudo bem, mas **por dentro pesa**"
vira `dia`. `por dentro` já está na cauda do adjetivo; falta reusá-la aqui.

### BAIXO-7 — os dois ganchos que ele mesmo escreveu foram ajustados ao conserto

Oito dos dez do `comGancho` são meus, literais. Nos dois que ele escreveu
(`^preciso parar`, `meu objetivo`) a frase foi trocada por uma que a cauda nova
alcança ("ando cansado demais pra isso", "estou exausto demais pra isso"), e as
minhas para esses mesmos ganchos continuam vestidas. **Não conto como defeito** —
as minhas, olhando de novo, são WOOP legítimo (ver ALTO-1 acima). Fica só o
registro do padrão, porque é o jeito mais fácil de uma régua parar de medir:
escrever a frase depois de conhecer a regex.

### BAIXO-8 — o `com-trava.sh` deste worktree é o velho

`650a908` ainda traz a versão sem retomada de trava órfã; a de main (`3ab0216`)
retoma por dono morto e por 30 min. Usei a de main. Some no merge, mas quem rodar
o instrumento neste worktree antes do merge pega a fila velha.

## Scorecard revisto

| dimensão | G3 | re-G3 | por quê mudou |
|---|---|---|---|
| Visão | 9 | **9** | inalterada. |
| Contrato | 8 | **8** | as duas razões antigas caíram (`vazi[oa]` consertado; Portão corrigido, com a distinção certa e o revisor creditado). **Entra outra da mesma classe:** o exemplo canônico da ADR ("estou cansado desse módulo") muda de lado com uma palavra a mais (ALTO-3). |
| Correção | 7 | **8** | 752/752 verificado por mim; ALTO-2 fechado com entrada na régua; `comGancho` é teste de verdade (cobra a cala **e** o gancho). Não chega a 9 por **duas regressões novas** de trabalho, ALTO-3 e ALTO-4, com conserto de três linhas testado. |
| Jornada real | 8 | **9** | M-2 capturado e **conferido no conteúdo**, com o rótulo e o diálogo no mesmo enquadramento. A dica da Página é só VoiceOver e está declarada como tal, corretamente. |
| Design | 9 | **9** | as seis fases seguem citadas e conferidas contra a fonte da tela. |
| Simplicidade | 8 | **9** | revejo a minha nota anterior: não é volta de jornada, folha nem formulário, e cobrar `curva-zero` aqui era esticar a regra. A extração de `caudaDoSentimento` para constante própria é simplificação real. |
| Movimento / Componentes / Fora do app | n/a | **n/a** | nada tocado. |
| Acessibilidade | 9 | **9** | inalterada. |
| Performance | 9 | **9** | a cauda alonga uma regex já curta num caminho disparado por gesto. |
| Privacidade e autoria | 7 | **8** | melhora grande e medida: 2/20 → 12/20 no corpus que reprovou, 10/10 nos casos nomeados. Não chega a 9 porque desabafo inequívoco ainda é vestido em quatro campos por três buracos com conserto conhecido: `dá medo` + gancho, `bate um cansaço`, `por dentro pesa`. |
| Estado honesto | 9 | **9** | a ADR declara a dívida da densidade e manda para o RUMO, que é o lugar certo. |
| Complexidade | 9 | **9** | +41 linhas em `AnaliseLocal`, uma constante nova, zero arquivo e zero dependência. |
| Relato | 9 | **9** | a ADR credita o revisor, mostra o número dos dois lados e escreve o motivo da recusa. É o que um relato tem de fazer. |

**Três dimensões em 8 → CORRIGIR ANTES.** As três descem pela mesma raiz: a
forma da cauda (ALTO-3, ALTO-4, MÉDIO-5, MÉDIO-6) e o buraco do `dá medo`. Não
são três problemas independentes.

## Lista mínima

1. **`\b`** na frente da lista de verbos de `lexicoDoSentimentoNoAutor`.
2. **Intensificador transparente**, não terminador: `(demais|pra caramba|ultimamente)?` entre o adjetivo e a cauda, e `pra isso` na cauda. (1 e 2 medidos: 0 mudanças nas 115, 4 notas de trabalho recuperadas.)
3. **`d[áa] (um |uma )medo|d[áa] medo de|(^|[.!?]\s*)d[áa] medo`** no ramo do medo, e o parágrafo da recusa vira o parágrafo do discriminador — a linha PREDICAR/NOMEAR que a ADR já traça, agora escrita. (Medido: 11/11, e 0 custo nas 115.)
4. **Opcional, mesma ida:** `bate|bateu|dá|deu` no ramo de `ansiedade|cansaço` (MÉDIO-5) e a cauda reusada no ramo do `pesa` (MÉDIO-6); e uma frase por buraco na régua `comGancho`.

Nada disto reabre radical nenhum, e nada disto muda a ADR na sua decisão — só na
frase sobre a arbitragem, que passa a não precisar existir.
