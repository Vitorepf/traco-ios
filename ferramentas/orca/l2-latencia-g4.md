# VOLTA L2 — o G4 que não passou: as quatro correções da latência da descoberta

Worker de FRONT-END E DESIGN. Meu simulador: iPhone 17 Pro
`C2416CBC-C5D9-41F9-ACD8-45EED8FC355E` (402 × 874 pt), o único que liguei e o
único onde instalei. Nunca toquei em `B91C8DEF` (teste 2) nem em `34CC3F94`
(teste 3). Topo de partida: `8e3a1a5`.

Skills carregadas ANTES da primeira linha de SwiftUI: `design-router` (com
`REDESENHO.md` e `CHECKLIST.md`) e `curva-zero`. As seis fases estão citadas
abaixo, na ordem em que aconteceram.

---

## G0 — a linha da volta

**Ciclo:** melhorar para multiplicar mais depois — o autor vê a capacidade que
limita o que ele vai conseguir realizar: quanto tempo leva para descobrir que
errou.
**Intenção que serve:** ler a série e entender que capacidade está sendo
mostrada, sem sentir que está devendo e sem que a seção coma o Perfil.
**Obstáculo que reduz:** o G4 da L1 (`g4-l1-design.md`) reprovou com Design 8 e
Simplicidade 7, e fechou com quatro correções pequenas e verificáveis.
**Evidência que prova:** as quatro na tela com captura antes/depois no mesmo
estado semeado; o cartão remedido em AX5; modo escuro, MODO B × AX5 e VoiceOver,
que tinham ficado por medir.

---

## As seis fases do `design-router`

### 1. Ancorar (auditar antes de tocar — é redesenho)

A auditoria já estava escrita no `g4-l1-design.md`. **Auditoria é datada, então
confirmei cada item na tela viva antes de mexer**, com o build de `HEAD`
instalado no meu UDID e o estado semeado pelo `semear-latencia.py` do próprio
repositório:

| o que o juiz afirmou | confirmado na tela viva? |
|---|---|
| `Tema.miudo` usado dentro do app só nestas duas linhas | sim — `grep -rn "Tema.miudo" Traco` devolvia exatamente `PerfilView.swift:256` e `:285` |
| o par 12/`tintaFraca` + 13/`tintaSuave` lê como massa só | sim — `l2-antes-modo-b-registros.png`: doze registros, nenhum degrau visível entre a medida e a frase |
| a frase-resumo de cinco fatos faz o olho parar no "18" | sim — `l2-antes-modo-b.png`, quatro linhas de manchete com o "18 em aberto" no meio |
| a lista de meses não tem teto | sim — com vinte meses semeados o app imprime os vinte: `l2-antes-teto-12-meses.png` e `-fim.png` (janeiro/2025 → agosto/2026) |
| `quantas == 1` chama de "tempo do meio" um valor só | sim — `l2-antes-modo-b.png`: "agosto de 2026 · 5 dias · 1 descoberta" |
| o cartão come ~6–7 telas em AX5 | sim, e medi de novo: **5.200 pt no meu aparelho** = 7,63 telas cheias de 682 pt (o juiz mediu no Pro Max, tela maior, e chegou a 6–7 — mesma coisa em telas menores) |

O que **não** confirmei como defeito e por isso não toquei: a paleta silenciosa,
a ordem cronológica, a ausência de alvo e a decisão de tirar a barra. O juiz
está certo: é o acerto da volta e não podia regredir.

### 2. Sistema

Reuso de token, zero token novo. A regra que o cartão passa a ter, e que é a
correção de fundo do achado (b) do juiz:

> **linha que carrega MEDIDA → `Tema.meta` (15) + `tintaSuave`
> prosa de apoio → `.footnote` (13) + `tintaFraca`**

Antes era o contrário em cima da medida: 12 pt (o degrau que a ADR 05u reserva
a FORA do app) com o cinza mais fraco. Depois: o número é o maior e o mais
escuro do par, e a frase da hipótese recua. A manchete continua `Tema.chrome` +
`tinta`; o rótulo continua `Tema.label`. Nenhuma cor de juízo entrou, os quatro
estados seguem no mesmo cinza.

Desvio declarado da letra do juiz: ele pediu `Tema.miudo` → `Tema.meta` nas
**duas** linhas. Na linha 256 (a legenda dos meses, que é prosa, não medida) subir
para 15 deixaria a LEGENDA maior que o DADO. Ela foi para `.footnote`, que é o
degrau que toda a prosa do cartão já usava. O que o juiz pediu de fato —
`Tema.miudo` fora de dentro do app, e a medida fora do menor corpo do produto —
está cumprido, e a varredura prova: `grep -rn "Tema.miudo" Traco` não devolve
nada; o token só vive em `TracoWidget`, como a 05u manda.

### 3. Construir

As quatro correções, mais uma quinta declarada:

1. **Teto de doze meses** — `ForEach(lista.suffix(12))`, e a copy passou a dizer
   o horizonte ("nos 12 últimos"). Prova em `l2-antes-teto-12-meses*.png` (vinte
   meses impressos) contra `l2-depois-teto-12-meses*.png` (setembro/2025 →
   agosto/2026, os oito mais velhos cortados), no MESMO estado semeado
   (script próprio, 20 meses, em `/tmp`; não alterei o `semear-latencia.py`).
2. **`Tema.miudo` → `Tema.meta`** na linha da medida, com o cinza trocado de
   `tintaFraca` para `tintaSuave` — ver a fase Sistema.
3. **A frase-resumo em duas linhas** — a medida sozinha como manchete, a
   composição (sem data · em aberto · abandonadas) uma linha abaixo, mais
   quieta. Nenhum número saiu. **Não dupliquei a copy do modelo na view**: são
   duas leituras da mesma `Latencia.emPalavras`, uma com só `descobertos` e
   outra com só o resto, então `Traco/Modelo/Latencia.swift` não foi tocado (é
   área proibida) e nenhum teste precisou mudar.
4. **`quantas == 1`** — "agosto de 2026 · 1 descoberta · levou 5 dias" no lugar
   de "· 5 dias · 1 descoberta" sob a legenda do tempo do meio.
5. **(declarado, não pedido) copy encurtada** — o parágrafo de abertura perdeu
   12 das 49 palavras e a legenda dos meses 10 das 16, mantendo as três
   promessas que o juiz creditou e a proveniência. É o que paga parte da altura
   que o degrau maior custa.

Fora de escopo, e não fiz: extrair os nove cartões inline do `PerfilView`,
mexer no modelo/`Decisao`/`abandonado`, devolver a barra, criar alvo.

### 4. Mover

**Nenhum movimento, e é deliberado.** A seção é superfície de leitura; mover
números que medem honestidade seria decoração sobre um contrato de sobriedade.
Não escrevi um `withAnimation`, não criei curva nem duração, e não toquei em
`Tema.Duracao`/`Tema.Mola` — o portão do movimento que outra volta está criando
não tem nada desta volta para reprovar. O juiz já aceitou a ausência no G4 da
L1 e ela continua dita aqui.

### 5. Julgar — o que a medida diz

Altura do cartão medida pela **árvore de acessibilidade** (`orca emulator ax`),
que devolve o frame de todo elemento, dentro e fora da tela, normalizado pela
altura do aparelho: do rótulo `LATÊNCIA DA DESCOBERTA` ao rótulo `MÉTODOS`.
O método foi conferido de forma independente contra uma varredura de capturas
com passo medido por OCR, no mesmo estado: **5.198 pt (capturas) contra 5.200 pt
(árvore)**. Tela cheia útil do iPhone 17 Pro = 682 pt.

| estado semeado, AX5 | ANTES | DEPOIS | Δ |
|---|---|---|---|
| MODO A (3 meses, 9 registros) | 5.200 pt · 7,63 telas | 5.541 pt · 8,13 telas | **+341 pt (+6,6%)** |
| MODO B (3 meses, 18 em aberto) | 5.758 pt · 8,44 telas | 6.115 pt · 8,97 telas | **+357 pt (+6,2%)** |
| 20 MESES (série de dois anos) | 6.148 pt · 9,01 telas | 5.340 pt · 7,83 telas | **−808 pt (−13%)** |

**Digo o número novo sem enfeitar: onde a série é curta o cartão ENGORDOU 6,6%.**
A conta está aberta: +345 pt vêm só da linha da medida subindo de 12 para 15 pt
em nove registros — que é exatamente o que o G4 exigiu. Em troca, o parágrafo
encolheu 104 pt e o resumo 15 pt. Onde a série é de verdade, o teto inverte o
sinal e o cartão fica 13% menor — e é ali que o problema do juiz vivia ("no
aparelho do dono, com a série real de dois anos, são 24 linhas").

**Nenhum placar novo** (conferido item a item na tela e no diff): não há número
solto no topo, a ordem dos meses continua cronológica, não aparecem "meta",
"sequência", "%" ou "streak", nada é tocável, e os quatro estados seguem no
mesmo cinza. A segunda linha do resumo é mais clara que a primeira, não de outra
cor.

### 6. Portão — scorecard preenchido por mim (a nota final é do revisor)

| dimensão | nota que eu proponho | evidência |
|---|---|---|
| Visão | 9 | entra no ciclo "melhorar para multiplicar"; fecha a lacuna do G4 da L1, com o diff do EVOLUCAO |
| Contrato | 9 | ADR 2026-09-08b em `SPEC.md`, EVOLUCAO atualizado, código coerente com os dois |
| Correção | 9 | nenhum comportamento novo; suíte integral **887 testes em 143 suítes, verde** |
| Jornada real | 8 | MODO A, MODO B, vazio, 20 meses e AX5 vistos na tela; **faltou a captura do vazio DEPOIS e do MODO B × AX5** — o helper do `orca emulator` é um só na máquina e outra sessão o tomava (limite de instrumento, declarado abaixo) |
| Design | 9 | `Tema.miudo` fora do app (varredura vazia), uma regra de degrau só, paleta intacta, quatro estados no mesmo cinza |
| Simplicidade | 8 | o teto entrou e a lista parou de crescer (−13% na série real), mas em série curta o cartão engordou 6,6%: a troca está medida e declarada, não escondida |
| Movimento | n/a | ausência deliberada numa superfície de leitura; nada se move, nada a respeitar em Reduzir Movimento |
| Componentes | 8 | reusa `.emCartao()`/`rotulo(...)`; um construtor privado novo (`resumo`), no padrão herdado das outras oito seções — a extração dos nove cartões continua dívida do RUMO |
| Acessibilidade | 8 | VoiceOver conferido pela árvore (rótulos, ordem, registro combinado, nada focável) e AX5 medido nos três estados; **desconto porque não OUVI a fala**, e porque achei um transbordo horizontal em AX5 que não é meu mas é real |
| Performance | n/a | nada novo na rolagem; `lerLatencia()` segue como estava (dívida já no RUMO) |
| Privacidade e autoria | 9 | nada mudou nas rotas: o selo continua fechando a decisão trancada e o `AcessoTrabalho` continua sendo o funil; MODO B prova que "SEGREDO SELADO" não vaza |
| Estado honesto | 9 | o teto diz o horizonte em vez de cortar calado; `quantas == 1` para de chamar de "tempo do meio" um valor só |
| Complexidade | 7 | `+52 / −16` no `PerfilView` (líquido +36, dos quais 16 são comentário): **não é líquida-negativa**, e o motivo é a quebra do resumo em dois `Text` com guarda |
| Fora do app | n/a | esta volta não toca superfície de fora |
| Relato | — | este documento |

---

## `curva-zero` — a leitura da seção

- **Jornada:** o autor abre o Perfil, rola até a latência e LÊ. Não há passo,
  não há decisão, não há campo. O resultado verificável é ele saber quanto tempo
  leva para descobrir que errou.
- **Atrito observado (e reduzido):** a manchete de cinco fatos exigia releitura
  para achar a medida no meio do "18 em aberto" — agora a medida é a primeira
  linha e sozinha. O registro exigia esforço para separar a medida do texto da
  hipótese — agora há um degrau de tamanho E de tinta, no mesmo sentido.
- **Recuperação:** continua não havendo caminho da linha "devido · em aberto há
  17 dias" até a nota. **Mantive assim de propósito**: tornar a linha tocável
  transformaria a seção em fila de trabalho, que é a cobrança que o contrato
  proíbe. Fica escrito como decisão, não como esquecimento.
- **Nada novo a aprender:** nenhum campo nasceu, nenhum gesto novo, nenhuma
  palavra de jargão. "tempo do meio" continua sendo a tradução de mediana e
  agora não é usada onde não cabe.

---

## O que ficou por medir e agora se mediu

- **Modo escuro** — `l2-depois-ax5-escuro.png`. O app é claro por decisão
  (`RaizView` fixa `.preferredColorScheme(.light)`, ADR 02h "o mundo claro"), e
  com o aparelho em aparência escura a seção renderiza idêntica: nenhuma cor de
  sistema vaza, nenhum texto perde contraste, os dois cinzas continuam se
  comportando como no claro. Não é achado; é o comportamento contratado.
- **MODO B × AX5** — o pior caso real (18 abertos × corpo grande) foi MEDIDO:
  5.758 → 6.115 pt. A captura não saiu (instrumento, ver abaixo).
- **VoiceOver** — li a árvore de acessibilidade inteira da seção
  (`orca emulator ax`, tamanho padrão, MODO A). A ordem é rótulo → parágrafo →
  medida → composição → legenda dos meses → três meses → registros → MÉTODOS.
  Cada registro é UM elemento combinado ("descoberto · levou 2 dias, estudar
  antes do café rende mais"), e **nenhum elemento da seção é botão, alvo ou
  ajustável**: o leitor não anuncia ação nenhuma, então a seção não vira lista
  de pendências no ouvido. As linhas de mês são elementos separados, um por mês,
  cada uma se bastando ("agosto de 2026 · 1 descoberta · levou 5 dias").
  **Limite honesto: eu li a árvore, não escutei a fala.**
- **Alvo de 44 pt** — n/a com motivo: não há um só alvo na seção.

---

## Achados (não consertados nesta volta)

**A1 — Em AX5, a camada do arquivo do Perfil transborda na horizontal.** O
cartão, o título "Perfil" e a barra de abas saem cortados dos dois lados; o
conteúdo não fica mais largo (a quebra de linha é idêntica), ele fica
DESLOCADO. **Reproduz igual no build de `HEAD`, sem nenhuma mudança minha** —
`l2-achado-ax5-transbordo-head.png` foi tirada com o binário compilado a partir
de `git checkout HEAD -- Traco/Perfil/PerfilView.swift` —, e no mesmo aparelho,
no mesmo tamanho de letra, o app Ajustes NÃO transborda
(`l2-achado-ax5-transbordo-head-large.png` mostra o mesmo Perfil correto em
tamanho padrão). É intermitente: some depois de reiniciar o simulador e volta.
É de `Traco/App/Camadas.swift` / `RaizView`, fora do meu escopo, e é
acessibilidade real. Não consertei (não é de uma linha e não é o que eu estava
tocando), conforme a instrução do orquestrador.

**A2 — Incidente de instrumento com consequência fora da máquina.** Com o
layout deslocado do A1, toques meus de navegação em coordenada fixa caíram sobre
"Entrar com a conta Grok" e abriram o Safari no fluxo device-code da x.ai várias
vezes; o Safari do meu simulador já tinha sessão iniciada e ficou com oito abas,
uma delas na página "Dispositivo Autorizado"
(`l2-incidente-grok-abas-safari.png`, 11h21 de 08/09). **Nenhum token ficou
guardado no Traço**: o Perfil diz "sem conta — recursos locais disponíveis"
(`l2-incidente-grok-perfil-sem-conta.png`, 11h23). Escalei na hora; por ordem do
orquestrador não limpei as abas e não desfiz nada. A revogação do lado da x.ai,
se houver, é do dono. Depois disso parei de dirigir por coordenada de tela: o
resto da volta foi por `orca emulator` (árvore AX + toque normalizado), sem
tocar no mouse do Mac.

**A3 — O helper do `orca emulator` é um só para a máquina (porta 3100).** Com
cinco simuladores ligados e vários workers, `--device` não isola: a árvore AX
voltava a tela do vizinho e os gestos paravam de chegar ao meu aparelho.
Reancorar (`attach`) antes de cada gesto ajuda e não resolve. Foi por isso que
faltaram duas capturas (vazio DEPOIS e MODO B × AX5); as duas têm medida pela
árvore no lugar. É instrumento, e registro como fato, não como nota.

---

## Instrumento, declarado

- Simulador: só o meu, `C2416CBC`, sempre por UDID explícito — em `xcodebuild
  -destination id=`, em `simctl install` e em `simctl io screenshot`. Nunca
  `booted`, nunca `generic`.
- `xcodebuild` e `xcodebuild test` sempre por `ferramentas/orca/com-trava.sh`.
- **Zero maestro.** Nenhuma linha deste relatório se apoia em asserção dele.
- Semeadura pelo `semear-latencia.py` do repositório (modos A e B, sem alterá-lo)
  mais dois estados meus, feitos por script no `/tmp`: o vazio (apagando `ZNOTA`
  e `ZTRABALHO`) e o de vinte meses.
- Tamanho de letra: o aparelho estava em `large` quando peguei; ficou em AX5
  durante a medição e **voltou para `large`**, conferido por captura
  (`l2-restauracao-letra-normal.png`, 12h24) e pelo eco do próprio comando. O
  orquestrador pediu `medium`; restaurei o valor que ENCONTREI, que é `large`, e
  digo isto em vez de silenciar a diferença. Aparência: voltou para `light`.
- Build sem aviso; suíte integral:

```
✔ Test run with 887 tests in 143 suites passed after 8.572 seconds.
** TEST SUCCEEDED **
```

## Capturas

| arquivo | o que prova |
|---|---|
| `l2-antes-cartao.png` / `l2-antes-registros.png` | MODO A, tamanho padrão, ANTES: o cartão inteiro e a lista de registros como massa cinza |
| `l2-antes-modo-b.png` / `l2-depois-modo-b.png` | MODO B, tamanho padrão: a frase-resumo de cinco fatos com o "18" no meio → a medida sozinha na manchete e a composição quieta embaixo; e "agosto de 2026 · 5 dias · 1 descoberta" → "· 1 descoberta · levou 5 dias" |
| `l2-antes-modo-b-registros.png` / `l2-depois-modo-b-registros.png` | os doze registros antes (dois cinzas encostados, medida no menor corpo) e depois (medida maior e mais escura, frase recuada) |
| `l2-antes-teto-12-meses.png` / `-fim.png` | vinte meses semeados, ANTES: janeiro/2025 até agosto/2026, sem corte |
| `l2-depois-teto-12-meses.png` / `-fim.png` | o mesmo estado, DEPOIS: setembro/2025 até agosto/2026, doze linhas |
| `l2-antes-vazio.png` | o estado vazio ANTES (a captura DEPOIS não saiu — ver A3; pela árvore, o cartão vazio mede 241 pt) |
| `l2-depois-ax5-meses.png` | AX5, DEPOIS: a legenda com o horizonte e as linhas de mês no degrau novo |
| `l2-depois-ax5-escuro.png` | o aparelho em aparência escura: a seção idêntica, sem vazamento de cor de sistema |
| `l2-achado-ax5-transbordo-head.png` / `-large.png` | o achado A1 no build de HEAD, e o mesmo Perfil correto em tamanho padrão |
| `l2-incidente-grok-abas-safari.png` / `l2-incidente-grok-perfil-sem-conta.png` | o incidente A2 e a prova de que o app seguiu "sem conta" |
| `l2-restauracao-letra-normal.png` | o tamanho de letra restaurado |

## Três linhas para o LACO

- A medida saiu do menor corpo do produto: `Tema.miudo`, que a ADR 05u reserva a
  fora do app, não é mais usado dentro dele em lugar nenhum, e o cartão passou a
  ter uma regra só de degrau — quem carrega número é maior e mais escuro, quem
  explica recua.
- A lista de meses ganhou teto de doze com o horizonte dito na copy: com a série
  real de dois anos o cartão encolhe 13%; com a série curta ele engorda 6,6%, que
  é o preço, medido e declarado, de pôr o número num degrau legível.
- Ficam dois achados que não são desta volta e não consertei: em AX5 a camada do
  arquivo do Perfil transborda na horizontal (reproduz em HEAD), e o helper que
  dirige o simulador é um só para a máquina inteira, o que custou duas capturas
  e um incidente com o login do Grok, escalado na hora.
