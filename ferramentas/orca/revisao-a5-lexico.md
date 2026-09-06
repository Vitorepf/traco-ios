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
