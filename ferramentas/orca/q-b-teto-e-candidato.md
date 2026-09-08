# Volta Q-B — o candidato que a ADR não identificava, e o teto que fazia a operação sumir

08/09/2026 · implementador (Claude Opus 5) · branch `Vitorepf/volta-q-qualidade`.
As três correções que o G3 (`ferramentas/orca/revisao-q-qualidade.md`) exigiu
antes do G5. **Esta é a minha leitura; a nota final é do revisor independente.**

## G0 — a linha da volta

**Ciclo:** melhorar. **Intenção:** o que a tela oferece, o autor recebe.
**Obstáculo:** a ADR 08k identificava o candidato errado, contava 12 falhas onde
o próprio JSONL somava 20, e mantinha três rotas de Trabalho na vitrine sabendo
que uma delas chegava em 1 de 6 casos. **Evidência:** recontagem linha a linha
do JSONL de 08/09; leitura do `git show` dos dois commits; e uma remedição nova
no aparelho do dono, com a conta ligada, dos nove casos que carregavam todas as
20 falhas de transporte.

---

## 1. O candidato: `acdfcb4`, não `325c819`

O G3 tem razão, e o `git show` fecha em uma linha:

- `325c819` — **um arquivo**, `ferramentas/orca/LACO.md`, 10 linhas. Não
  implementa nada da 08k.
- `acdfcb4` — **os 15 arquivos da Q**: `Politica.swift` (+76), `Sabia.swift`
  (−8), `AvaliacaoIA.swift`, `PoliticaTests.swift`, SPEC, QUALIDADE-IA,
  EVOLUCAO, o relatório e as seis provas.

**O candidato desta decisão é `acdfcb4`.** Conferido hoje no próprio aparelho do
dono, no binário que o revisor instalou por cima a partir de uma worktree
destacada em `acdfcb4`:

```
$ nm -a .../Traco.app/Traco.debug.dylib | grep responderNasNotas | head -1
_$s5Traco5SabiaO17responderNasNotas8pergunta6fontes8conversa8catalogo7retrato…
$ strings -a .../Traco.debug.dylib | grep -c indisponivelPorQualidade   # 2
$ strings -a .../Traco.debug.dylib | grep -c medidaEm                   # 2
$ strings -a .../Traco.debug.dylib | grep -c conserto                   # 2
```

Só a assinatura `fontes:` existe; a de `contexto:` não. É o binário da decisão.

### E um fato que o hash único escondia: a corrida foi de DOIS binários

Achado desta volta, lendo o JSONL por entrada de caso. Não corrijo só o hash —
digo o que a redação antiga não deixava ver.

| corridas | o que rodou | árvore | como se sabe |
|---|---|---|---|
| `05D574C2`, `D91E98DE`, `F4D24F76` | a matriz 16 × 6 × 3 | a de `325c819` | os 3 casos de `responderNasNotas` com `contexto` **concluíram com saída**; só a sonda anterior aceitava `contexto` |
| `1FB24380`, `60B40CFE`, `B7A619E5` | a remedição com fontes tipadas | a que virou `acdfcb4` | os casos `…-tipada-q` exigem `fontes`, e só a sonda de `acdfcb4` faz isso |

Os hashes `504d29d7…` / `2152892a…` atestam o binário da **matriz**, não o da
remedição — e nenhum dos dois é o binário que hoje serve a decisão. A troca no
meio da volta **não contamina a matriz**: o que `acdfcb4` mudou em execução foi
a sonda (passou a exigir `fontes`) e a tabela `Politica`, e a tabela é
consequência da medida, não entrada dela — nas quatro rotas de Trabalho
`desceAoAparelho` já era falso na 07b, antes e depois.

## 2. 20 contra 12: **12 está errado**, e por quê

Recontado com `jq` sobre as 610 linhas, agrupando `chamadasGrok` por modelo e
desfecho:

```
 186 grok-4.3   conteúdo completo
  52 grok-4.6   conteúdo completo
  20 grok-4.6   sem resposta de transporte
```

**20** é o número certo. Três razões, e a primeira basta:

1. A própria tabela da ADR somava 11 (`prepararPratica`) + 6 (`revisar`) +
   3 (`produzir`) = **20**. O "12" contradizia o parágrafo em que estava.
2. A contagem direta no JSONL dá 20 de 72 chamadas a `grok-4.6` — 28 %.
3. Não achei nenhuma leitura em que 12 fizesse sentido: nem por caso (9 casos
   distintos), nem por corrida (6 + 6 + 8), nem por operação (3).

**Um terceiro número, reconciliado antes de virar a próxima contradição:**
`grok-4.3` teve 0 falhas em **177** chamadas na matriz e 0 em **186** contando
as 9 da remedição. Os dois estão certos, com denominadores diferentes, e agora
os dois estão escritos.

**Onde foi corrigido:** `SPEC.md` (ADR 08k), `ferramentas/orca/q-qualidade.md`,
`QUALIDADE-IA.md` e `EVOLUCAO.md` — que também dizia "sete rotas cortadas" e
listava seis, faltando `responderNasNotas`.

## 3. O teto: a decisão, e a prova

**Escolhi o teto maior.** Em uma linha: *retentativa e corte caem pelo próprio
dado; o teto é o único lever que não invalida a qualidade já medida — e a
remedição no aparelho do dono devolveu 0 falhas de transporte em 30 chamadas,
contra 20 em 72.*

### Por que não as outras duas

- **Retentativa.** A falha não é intermitente: **cinco dos nove casos**
  estouraram os 91 s nas **três** execuções. Repetir um pedido determinístico é
  fazer o autor esperar 180 s pelo mesmo nada.
- **Indisponível por qualidade.** Cortaria junto `conferirTentativa`
  (`grok-4.6`, esforço `high`, **0 falhas em 18**, 6 de 6 casos) e `produzir`,
  cuja única reprovação foi este teto. É a régua errada para um defeito de
  espera — e o defeito de espera tinha conserto.
- **Teto.** Mesmo modelo, mesmo `reasoning_effort`, mesmo prompt: muda só a
  paciência, e por isso não obriga a remedir as dezesseis. (Baixar o raciocínio,
  que a 08k listava como terceira saída, obrigaria.)

### O código

Quatro `timeout: 90` literais viraram **um** `Grok.tetoTrabalho = 240`
(`Traco/Analise/Grok.swift`), lido por `OficinaTrabalho` (×3) e
`RevisaoTrabalho` (×1). Um lugar só, pela razão da ADR 03l: quatro cópias
divergem em silêncio — e foi assim que um teto apagou uma operação da tela sem
ninguém decidir isso.

### A medida nova (ADR 2026-09-08m)

Aparelho `C2416CBC`, install **por cima**, conta conferida antes, em cada
registro e depois. Nove casos — exatamente os que carregavam as 20 falhas — × 3
execuções = 27, e 30 chamadas a `grok-4.6` (os três `Combinar` chamam duas
vezes).

| rota | antes, 90 s | depois, 240 s | pior latência |
|---|---|---|---|
| prepararPratica | 11 de 18 falhas | **0 de 15** | 141,1 s |
| revisar | 6 de 18 | **0 de 9** | 133,7 s |
| produzir | 3 de 18 | **0 de 3** | 178,1 s (caso de 2 chamadas) |
| conferirTentativa | 0 de 18 | não remedido | 45,7 s em 08/09 |
| **total `grok-4.6`** | **20 de 72 (28 %)** | **0 de 30** | — |

Os que estouravam nas três execuções voltaram inteiros:
`ler-rascunho-q2-conhecido-preparar-espanhol-solo` 133/91/100 s,
`qn-preparar-outro-dominio-planilha` 113/107/102 s,
`qn-produzir-combinar-sem-resolver-a-pratica` 160/178/130 s.
**O teto era o defeito.**

Provas: `prova/qb-teto-casos.json` (`1055b023…`), `prova/qb-fumaca.json`
(`8f85e19c…`), `prova/qb-teto-avaliacoes.jsonl` (`fa51544a…`, 64 linhas, com as
três corridas: fumaça de abertura `2934F6EC` 20h08Z, remedição `B54FF0BE`,
fumaça de fecho `007BB0B8` 20h59Z).

### O achado que vai contra nós, e ele não é de teto

Com o transporte inteiro, **3 das 15 execuções de `prepararPratica` continuam
sem entregar nada**. Nessas três a chamada voltou **HTTP 200, conteúdo
completo, `grok-4.6` confirmado, 3.777 a 6.865 tokens de raciocínio**: quem
recusou foi o **nosso** contrato (`PraticaTrabalho.parsePreparacao`/`validar`).
Defeito de conteúdo, medido, que o teto não conserta.

Por entrega e por caso, `prepararPratica` sai de **1 de 6** para **4 de 6**; as
outras três rotas entregaram em todas as execuções medidas.

**Não movi isso para a tabela `Politica`, e digo por quê.** Ausência
sistemática — metade das vezes, determinística por caso — é indisponibilidade e
mora na tabela. Recusa ocasional do próprio contrato já tem superfície própria
**e por pedido**: `Trabalho.EstadoPedido.praticaIndisponivel`, que a
`TrabalhoView` mostra em `pratica-preparacao-indisponivel` com a saída "Retomar
esse pedido". A tabela não sabe dizer "às vezes"; apagaria a operação inteira
por um defeito que a tela já conta pedido a pedido. Fica aberto e nomeado no
RUMO: **por que `validar` recusa 1 em 5 preparações completas, e se o defeito é
do provedor ou do nosso esquema.**

## 4. `responderNasNotas` continua cortada

Não reativei. O caso tipado do revisor — que eu não vi ao escrever a fixture —
recusou por inteiro nas três execuções, com teto de R$ 5.000, US$ 300 + US$ 120
previstos e cotação datada. **0 de 3.** A linha da tabela não muda e o motivo
continua sendo o da recusa por inteiro. A frase do revisor fica na ADR porque é
a lição: **conserto nomeado não é conserto feito.**

## 5. Portões e provas

**G1 — instrumento.** Tudo via `ferramentas/orca/com-trava.sh`, no simulador de
teste `34CC3F94` (nunca no `C2416CBC`), com `-parallel-testing-enabled NO`.

- `** BUILD SUCCEEDED **` (build para `id=C2416CBC…`, o que instalei).
- `✔ Test run with 915 tests in 149 suites passed after 9.993 seconds.`
  seguido de `** TEST SUCCEEDED **`.
- **Um** aviso de compilação em toda a suíte:
  `Traco/Perfil/PerfilView.swift:637:18: warning: '+' was deprecated in iOS
  26.0` — é da frente do Perfil, não desta volta, e não a toquei.
- Teste novo: `GrokContratoTests.oTetoDeTrabalhoCobreAPiorLatenciaMedida`.
  Falha se alguém devolver o teto para baixo da pior latência já medida — que é
  exatamente como a operação sumiu da tela sem ninguém notar. Não é tautologia:
  guarda o número contra o `90` de volta.

**G2 — jornada.** Volta de motor: nenhuma view mudou, e não invento captura de
tela que não mudou. A prova de jornada desta volta é a corrida no aparelho do
dono, pelas funções de produção (`MotorTrabalho.produzir`,
`MotorTrabalho.prepararPratica`, `RevisaoTrabalho.revisar`), com a conta ligada
— não um teste com `Motores.desligados`. A superfície do resíduo
(`pratica-preparacao-indisponivel`) é a que já existia e continua no lugar.

**Trava do instrumento:** segurei `com-trava.sh` no build, na suíte e na única
sessão de `orca emulator` (attach, dois `ax`, `button home`, `kill`). Nenhum
maestro. Nenhum toque no mouse nem no teclado do Mac. Capturas por
`xcrun simctl io <UDID>`, sempre com o UDID explícito.

**Lei do simulador do Grok, cumprida.** No `C2416CBC` só houve `boot` (ele
estava desligado quando peguei), `install` por cima, `launch`, `terminate`,
`spawn launchctl setenv` e `io screenshot`. **Nenhum `erase`, `clearState`,
`uninstall` ou `xcodebuild test`.** Safari não tocado. Conta conferida por
chamada autenticada antes de instalar, em cada um dos 27 registros, e depois de
tudo: `contaGrokLigada: true`, 12 modelos.

**Estado em que deixo o aparelho.** Achei o `C2416CBC` **desligado** (foi assim
que o revisor o deixou) e o liguei — `boot` não está entre os proibidos, e a
conta sobreviveu a ele, como já tinha sobrevivido ao desligamento de 16h30 da
volta Q. **Deixo-o LIGADO de propósito**, e não desligado como o achei: quem
faz o G3 desta volta precisa dele, e desligar é o gesto que menos quero repetir
perto desta conta. `TRACO_AVALIAR_IA` está **desdefinido** (conferido:
`launchctl getenv` devolve vazio), então o app não roda sonda no próximo
lançamento. O app instalado é o desta branch, com `tetoTrabalho = 240`.
Orientação, letra e aparência não foram tocadas.

## 6. O que esta volta NÃO prova

- **240 s não é um teto provado seguro para sempre.** É o teto sob o qual nada
  encostou em 30 chamadas. A cauda é longa e a amostra por ponto é uma.
- **Menos independência que a matriz original.** As 27 execuções saíram de UM
  lançamento com três repetições e `esquecerMemo()` entre elas, não de três
  lançamentos. Está declarado; não é o mesmo grau de independência.
- **Só os nove casos que falhavam foram remedidos.** Os 52 que já chegavam
  abaixo de 90 s não foram repetidos, porque subir um teto não transforma
  sucesso em falha. O denominador novo é honesto, não é uma matriz nova.
- **Mediu entrega, não qualidade.** "4 de 6" para `prepararPratica` quer dizer
  que quatro casos entregaram nas três execuções — não que o conteúdo dos
  quatro atende a rubrica de `QUALIDADE-IA.md`.
- **Não abri a jornada do espanhol de ponta a ponta.** É volta própria, e o
  orquestrador a separou desta.
- **Não é teste cego.** Os nove casos são os da fixture da Q, escritos pelo
  implementador anterior — que sou eu, nesta mesma frente.

## 7. Scorecard, preenchido por mim (a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | fecha a lacuna de disponibilidade que a 08k nomeou e adiou; EVOLUCAO atualizado |
| Contrato | 9 | candidato `acdfcb4` provado por `git show` e por símbolo no dylib instalado; 20 contra 12 reconciliado nos quatro lugares, com o terceiro número (177/186) escrito antes de virar contradição |
| Correção | 9 | 915 testes, zero falhas, linha colada; teste novo que falha se o teto voltar a 90 |
| Jornada real | 8 | 27 execuções pelas funções de produção no aparelho do dono com a conta ligada; mas é sonda, não a jornada do Trabalho aberta na tela — e eu digo isso em vez de vender captura |
| Design | n/a | volta de motor; nenhuma view tocada |
| Simplicidade | 9 | quatro literais viraram um valor nomeado; nenhum passo novo para o autor |
| Movimento | n/a | sem animação |
| Componentes | n/a | nenhum componente |
| Acessibilidade | n/a | sem view |
| Performance | 9 | é o assunto da volta: 28 % de indisponibilidade medida virou 0 de 30, com a distribuição de latência publicada |
| Privacidade e autoria | 9 | só casos sintéticos, os mesmos da Q; nenhum token, header ou corpo de erro no JSONL |
| Estado honesto | 9 | o achado contra nós está no título de uma seção: o transporte foi consertado e 3 de 15 continuam sem entregar, por recusa do NOSSO contrato — e não movi para a tabela o que a tela já conta por pedido |
| Complexidade | 9 | +1 constante, −4 literais, +1 teste; nenhuma dependência |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | este arquivo, com as saídas inteiras em `prova/qb-teto-avaliacoes.jsonl` |
