# Revisão G3 — volta 19, o Recordar (ADR 2026-09-06k)

Claude Opus 5, revisor, sessão própria, 06/09/2026 22h–23h. Worktree
`volta-19-recordar`, topo `dd54864` sobre `4786681`. Não editei nem commitei
código. **Instrumento:** iPhone 17 Pro (teste 4) `A1DF082C`, ligado e desligado
por mim; build, `xcodebuild test` e nada mais sob `ferramentas/orca/com-trava.sh`.
Seis simuladores ligados na máquina: **não usei maestro** (lei do instrumento da
ESTEIRA — com mais de um simulador o driver do vizinho responde), e toque por
coordenada só depois de trazer a MINHA janela para a frente, com cada passo
conferido por `xcrun simctl io <meu-UDID> screenshot`. O iPhone 17 do dono não
foi tocado. Estado devolvido ao fim: `content_size` = large, `appearance` =
light, `ReduceMotionEnabled` = 0.

**Veredito: CORRIGIR ANTES.** Seis dimensões abaixo de 9, três achados altos.
A volta entrega de verdade as três coisas mais difíceis que prometeu — o pé, o
eixo e a coluna única em AX5, todas conferidas por mim na tela viva. O que a
derruba não é o desenho: é um defeito da auditoria declarado morto que está vivo,
o contraste da ação principal no estado em que a tela SEMPRE abre, e a ausência
das seis fases do `design-router` em qualquer texto da volta.

---

## 1. O achado de processo: metade da V9 já tinha caído?

Confiro **3 de 4**. O quarto é falso, e é o achado alto A1.

| defeito V9 | o implementador diz | o que eu achei | veredito |
|---|---|---|---|
| `PrimarioStyle` próprio, "voltar" e RECORDAR à mão (Componentes 6) | caiu na V10-B | `git show 4786681:Traco/Recordar/RecordarView.swift` — nenhum `ButtonStyle` local; `CabecalhoDeFolha(saida:.voltar)` na linha 235, `Text("RECORDAR").rotulo()` na 236, `.buttonStyle(.primario/.discreto)` nas 315/336/394/406 | **CONFIRMADO** |
| cross-fade entre irmãos do §21 e durações 0,3/0,35/0,4 sem token (Movimento 5) | caiu na V8 + V10-B | o pai já tinha `entraFase` assimétrico (`removal: .identity`) e TODAS as durações em `Tema.Duracao`. Extraí `v19-antes-movimento.mp4` a 30 fps: nos quadros 105→119 a nota já está ilegível e a instrução está sozinha; a pergunta só aparece no 122. **Nenhum quadro com dois textos legíveis** (`v19-rev-06-quadros-antes-instrucao-sobrevive.png`) | **CONFIRMADO** |
| "vol-tar" e "RECOR-DAR" hifenizando em AX5 (Acessibilidade 5) | caiu na V8 | `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)` no cabeçalho, linha 241 do pai; e o cabeçalho de `v19-antes-07-ax5-revelar.png` mostra "voltar" e "RECORDAR" inteiros | **CONFIRMADO** |
| o toast do "hoje não" nasce em cima de "Trabalhar nisto" e das quatro ações (Estado honesto 8) | caiu em `PaginaView` (`padding(.bottom, 88)`) | **FALSO — o defeito está vivo.** Ver A1 | **DERRUBADO** |

**Consequência para as próximas voltas por tela (V13 Notas, V15 Calendário):** o
método está certo e vale — a auditoria V9 é de 05/09 e envelheceu; conferir na
tela viva antes de tocar poupou esta volta de reconsertar três coisas. Mas o
método só vale quando a tela viva **reproduz o estado que a auditoria acusou**.
Foi exatamente aí que falhou: a captura que serviu de prova para o toast é de uma
página VAZIA, onde os controles que o toast tapava nem existem. Regra para as
próximas: quando o defeito é "A tapa B", a prova tem de mostrar B na tela.

## 2. Os três defeitos novos que só a tela viva mostrou

Confiro **os três**.

1. **Duas colunas hifenizando em AX5, nota cortada no meio de uma letra.**
   `v19-antes-07-ax5-revelar.png`: "obstá-culo", "MEMÓ-RIA", "per-gunta", "culo"
   fatiado ao meio e "Voltar à página" em âmbar por cima do corte. A causa está
   no pai: `let ladoALado = geo.size.width >= 360`, medida em pontos, cega ao
   corpo do texto. **REAL, e o pior dos três em consequência** — quem usa letra
   grande lia a própria nota picada.
2. **Campo do autor em linha e meia em AX5.** `v19-antes-06-ax5-escrever.png`.
   **REAL** — a pergunta com `fixedSize` tomava a folha e sobrava uma fresta.
3. **A pergunta da sábia trocada embaixo do autor ~4 s depois.** **REAL, e é o
   mais grave dos três**, porque o app mexe no que a pessoa está lendo enquanto
   ela escreve. No pai, `pedirPergunta()` atribuía `perguntaDaSabia` sem nenhuma
   guarda — e o comentário logo acima, no mesmo arquivo, já **afirmava o
   contrário**: "chegou tarde, o autor já está escrevendo com a frase fixa e nada
   muda embaixo dele". O código não fazia o que o comentário jurava.
   *Ressalva de instrumento:* não consegui reproduzir a corrida na tela — neste
   simulador a sábia de bordo responde em ~2,5 s, antes de a primeira letra ser
   possível; em três tentativas com notas inéditas a pergunta chegou antes e não
   mudou nos 15 s seguintes. A guarda nova (`guard memoriaVazia`) é inequívoca na
   leitura; a prova viva do defeito segue sendo o vídeo do implementador.

## 3. Os seis pontos que o orquestrador mandou conferir

**1) A curva-zero não cresceu.** Medida por mim na tela: da página com nota,
1 toque em "Recordar" → escrever → 1 toque em "Revelar" (`d1-escrito` →
`d2-revelar`). "hoje não" fecha em 1 toque. **Idêntica à V9.** ✅
Em AX5 abrir custa 2 toques, porque as quatro ações da página viram lista
vertical — comportamento da barra, anterior a esta volta, não conta contra ela.

**2) Movimento.** Gravei os meus dois vídeos no meu simulador e extraí a 30 fps.
Normal (`mov-normal.mov`, 235 quadros): a instrução e a nota apagam juntas
(quadros 114→127), o papel fica limpo (129→136) e só então "O que estava
escrito?" amanhece (140). Reduzir Movimento ligado (`mov-rm.mov`, 207 quadros):
quadro 74 instrução + nota legíveis; 76 as duas apagando juntas; 78–81 papel
esvaziando; 82 a pergunta sozinha
(`v19-rev-05-quadros-rm-instrucao-sai-com-a-nota.png`).
**Nenhum par legível no mesmo quadro, nos dois modos.** ✅ E o `.opacity(escondendo ? 0 : 1)`
faz o que promete: a instrução não sobrevive à nota.

**3) AX5.** Conferido ao vivo com `content_size = accessibility-extra-extra-extra-large`.
Revelar: **uma coluna**, "DE MEMÓRIA" e "A NOTA" empilhados, zero hifenização
(`e1-ax5-revelar`). Escrever: pergunta inteira em quatro linhas sem hífen e o
campo do autor com ~285 pt de altura útil — muito além de linha e meia
(`v19-rev-04-ax5-escrever-vivo.png`). Cabeçalho "voltar"/"RECORDAR" inteiros.
**Os dois defeitos de AX5 estão fechados.** ✅
Não vi (e não consegui provocar) o ramo que a ADR diz existir: AX5 com pergunta
LONGA da sábia, onde o `ViewThatFits` cai na `ScrollView` com máscara. Fica como
não verificado, não como reprovado.

**4) Estado honesto — o toast.** **REPROVA.** Ver A1.

**5) +218/−88.** Ver M3. É crescimento real e a ADR 05v pede líquido-negativo em
volta por tela. Meu julgamento está lá: parte ganha o lugar, parte não.

**6) Fases e curva-zero contra a tela.** Ver A2 e M5.

---

## 4. Achados por severidade

### ALTO

**A1 — O toast do "hoje não" continua nascendo em cima da barra de ações; a ADR,
o EVOLUCAO e a mensagem do commit afirmam que já tinha caído.**
Reproduzido por mim **duas vezes**, no meu simulador, em `large`, sem teclado de
software: com a nota escrita na página, "Recordar" → "hoje não" devolve o toast
"volta amanhã." **cobrindo inteira a régua e encostando em "Trabalhar nisto"**
(`v19-rev-01-toast-tapa-a-barra.png`). É o defeito 15 da auditoria V9, palavra por
palavra, ainda aberto.
Por que a prova do implementador não pegou: `v19-antes-05-hoje-nao.png` é de uma
página **vazia** — sem "Trabalhar nisto" e sem Analisar · Recordar · Anexar ·
Lente. O estado que a auditoria acusou não estava na tela.
Confirmação por código: `PaginaView.swift:303` tem `.padding(.bottom, 88)` desde
`eae9a8f` (31/08), **antes** da auditoria. Nada mudou ali; nada podia ter caído.
Dono da correção: quem toca `PaginaView` — o toast precisa medir a barra, não
chutar 88. Impacto no scorecard: Estado honesto e Contrato.

**A2 — As seis fases do `design-router` não são citadas em lugar nenhum da volta.**
`grep` por Ancorar / Sistema / Construir / Mover / Julgar / Portão na ADR
06k (SPEC.md), na mensagem do commit e no EVOLUCAO: **zero ocorrências**. Não
existe arquivo de relato desta volta — a V18 tinha `relatorio-v18-trabalho.md`.
A ESTEIRA é literal: "Volta visual sem as fases do `design-router` citadas no
relato é recusada no G4, mesmo que o código esteja certo."
Justiça seja feita ao trabalho: a fase de **auditar antes de tocar** foi cumprida
melhor do que em qualquer volta que eu tenha lido — a tabela do "já tinha caído"
é auditoria de verdade. Falta escrever as seis com esse nome, e a fase **Julgar**
está de fato ausente do texto: nenhuma linha compara antes e depois em `large` e
diz o que se ganhou e o que se perdeu (e perdeu-se algo — M1 e A3).

**A3 — A ação principal, no estado em que a tela SEMPRE abre, caiu de 6,32:1 para
1,61:1 de contraste; a saída secundária ficou 4× mais legível que o caminho.**
Medido em pixel nas capturas do próprio implementador
(`v19-antes-02-escrever.png` × `v19-depois-02-escrever.png`, fundo 244,244,242):

| | antes | depois |
|---|---|---|
| "Revelar" desabilitado | (89,89,94) → **6,32:1** | (194,194,200) → **1,61:1** |
| "hoje não" | (85,85,90) → 6,73:1 | (83,83,88) → **6,73:1** |

Confirmado ao vivo no meu simulador: 1,53:1 medido em `g-full.png`.
O Recordar abre SEMPRE com a memória vazia, então **1,61:1 é o primeiro estado
que o autor vê, todo dia, no ritual mais repetido do app** — e ali a saída
("hoje não") grita mais alto que o caminho ("Revelar"). É a inversão exata do
`von-restorff-effect` que esta volta veio consertar, deslocada da forma para o
contraste. A ADR declara isto ("continua em `tintaMorta`: legível como
bloqueada"); 1,61:1 não sustenta a palavra "legível".
**Causa-raiz, e não é local:** `Pilula.swift` não tem estado desabilitado — com
`isEnabled == false` ela devolve `fundo = .clear` e `tinta = Tema.tintaMorta`,
para **todos** os chamadores. O contorno de 0,5 que a volta acrescentou é um
remendo num chamador só. O conserto pertence ao componente.

### MÉDIO

**M1 — Em `large` a volta abriu ~198 pt de papel morto entre a pergunta e o lugar
de escrever, e a ADR afirma o contrário.**
A ADR diz: "cabe inteira, ela encosta e o campo começa logo abaixo". Medi o caret
âmbar nas duas capturas do implementador: **antes 23,6 % da altura da tela,
depois 46,2 %** — o autor passou a escrever no meio da folha, com um vão vazio
acima. Reproduzido ao vivo (`v19-rev-02-escrever-vao-morto.png`) e visível na
própria `v19-depois-02-escrever.png` e `v19-depois-03-escrito.png`.
Causa: `.frame(maxHeight: geo.size.height / 2, alignment: .top)` é um teto
**flexível** — o `VStack` entrega ao bloco da pergunta o meio vão inteiro mesmo
quando ela ocupa duas linhas. O teto deveria ser só teto. Em AX5, onde a pergunta
realmente enche a metade, o comportamento é o prometido; em `large`, que é o caso
comum, não é.

**M2 — "O QUE NÃO VOLTOU" foi declarado incapturável por um motivo errado.**
A ADR: "exige conta da sábia, que este simulador não tem". Capturei o estado no
meu simulador em quatro minutos, sem conta nenhuma
(`v19-rev-03-revelar-large-nao-voltou.png`): `Sabia.disponivel` é
`ContaGrok.ligada || noAparelho`, e `noAparelho` está de pé aqui — é a mesma
sábia de bordo que gerou as perguntas visíveis nas capturas
`v19-antes-02` e `v19-depois-02` (e o "serviu / não serviu" só existe quando
`perguntaDaSabia != nil`, o que a própria prova do implementador mostra). Ou seja:
**a evidência da volta contradiz o limite declarado na mesma página.** É desculpa,
não limite. Fica também o ganho: a captura serve de prova de que os dois rótulos
partilham linha de base e de que o `.topLeading` funciona.

**M3 — +130 linhas líquidas de código contra a regra da ADR 05v.**
`git diff --shortstat 4786681 HEAD -- '*.swift'` = **+218 / −88**, dois arquivos
(191/−88 em `RecordarView.swift`, +27 em `ProvaTests.swift`). A ADR 05v decidiu
que "cada volta por tela tem de ser líquido-negativa".
Meu julgamento do que entrou, item a item:
- **Ganha o lugar:** `comparaLadoALado(largura:tamanho:)` + os 27 de teste — é a
  lição da F4 cumprida, regra nomeada e provada fora da tela, e o defeito que ela
  fecha era o pior de AX5. `rodape(...)` é troca, não adição: substitui dois pés
  duplicados por um, e a duplicação era metade do defeito de affordance.
  `perguntaDaProva` extraído é obrigatório para o `ViewThatFits` (dois ramos, uma
  fonte).
- **Não ganha, ou ainda não:** `GeometryReader` + `ViewThatFits` + máscara é a
  parte mais cara do diff e é justamente a que produziu M1 — comprou AX5 e
  vendeu `large`. `Saida` (struct `Identifiable` para uma lista de no máximo
  dois botões) é cerimônia para dois `if let`.
- Volume grande de comentário explicativo: é a casa desta base de código, não
  conta como inchaço.
**Recomendação ao orquestrador:** a exceção se justifica pela regra testada e pelo
pé único; não se justifica enquanto o `ViewThatFits` estiver custando 198 pt de
papel morto. Corrigido M1, eu registro a exceção sem ressalva.

**M4 — O comportamento novo mais importante não tem teste.**
`guard memoriaVazia else { return }` em `pedirPergunta()` é a mudança que impede
o app de trocar o enunciado embaixo de quem escreve. A suíte cobre a regra de
layout (3 testes) e não cobre esta. A ESTEIRA pede "comportamento novo coberto
por teste". É testável fora da tela com a mesma receita do `comparaLadoALado`:
uma função `nonisolated static` que decida se a pergunta vinda entra.

**M5 — `curva-zero` citada só pela contagem de toques.**
O Recordar tinha Simplicidade 8 na V9, então a skill era obrigatória por portão.
A ADR traz **jornada** (1+escrever+1) e nada mais: não nomeia resultado
verificável, atrito observado nem recuperação. O atrito estava lá para ser
nomeado (o vão morto de M1 é atrito novo; a ação ilegível de A3 é atrito novo).

### BAIXO

- **B1** — a máscara de gradiente do ramo que rola apaga a última linha **também
  quando já se rolou até o fim**: quem chega ao fim da pergunta vê a última linha
  desmaiada para sempre. O desmaio deveria depender da posição.
- **B2** — "próxima" perdeu o `.accessibilityLabel("Próxima")` que tinha; agora o
  VoiceOver lê o texto minúsculo da `Pilula`. Trivial, mas é perda de rótulo.
- **B3** — a guarda descarta a resposta **depois** da chamada: com conta Grok, a
  pergunta tardia é paga e jogada fora. Não é privacidade nem gasto sem gesto (o
  gesto foi abrir o Recordar), mas é dinheiro no lixo; dá para cancelar a `task`
  na primeira letra.
- **B4** — não vi na tela o ramo `ScrollView` do `ViewThatFits` (AX5 + pergunta
  longa da sábia). Não reprovo o que não vi; registro como não coberto.

---

## 5. Scorecard (mínimo 9 para mesclar)

| dimensão | nota | evidência |
|---|---|---|
| Visão | **9** | entra no ciclo "Direção visual e uso simples", fecha a lacuna nomeada "tela abaixo de 9 no RUMO" (Recordar 6,2, a segunda pior); EVOLUCAO ganha o parágrafo ADR06k coerente com o código |
| Contrato | **6** | ADR + SPEC + EVOLUCAO + commit são coerentes entre si e com o código, MAS os quatro carregam a afirmação falsa do toast (A1) e a ADR carrega um limite falso (M2). Uma falsidade escrita no EVOLUCAO é pior que no relato: é o contrato |
| Correção | **8** | build **limpo, 0 avisos** (`xcodebuild clean build`, verificado por mim) e `✔ Test run with 782 tests in 131 suites passed` / `** TEST SUCCEEDED **` no A1DF082C — os dois números da ADR batem. Menos 1 por M4. Maestro não rodado (lei do instrumento, seis simuladores); li os quatro fluxos que tocam o Recordar e nenhum quebra: `recordar-adiar` sobrevive, `tapOn: Revelar` casa com o texto da `Pilula`, e as duas rotas escrevem antes de revelar |
| Jornada real | **6** | sete estados capturados nos dois corpos, pelo mesmo roteiro, e o conteúdo de cada um confere com o nome — conferi um a um, não só a existência. Mas dois estados fura o portão: o do toast foi fotografado num estado onde o defeito não pode aparecer (A1) e "O QUE NÃO VOLTOU" foi declarado incapturável e eu capturei (M2) |
| Design | **6** | os ganhos são reais e conferidos ao vivo: o pé único com fio, a `Pilula(.larga)` cheia como único objeto escuro (`d1-escrito`), o eixo `.leading`, "DE MEMÓRIA" e "A NOTA" na mesma linha de base (`v19-rev-03`). Contra: A2 (fases não citadas — recusa por si só na ESTEIRA), A3 (von-Restorff invertido no estado de abertura) e M1 (198 pt de papel morto em `large`) |
| Simplicidade | **7** | curva-zero medida por mim e **intacta**: 1 + escrever + 1, adiar em 1. Mas a skill era obrigatória (tela em 8) e foi citada só pela contagem (M5); e o vão de M1 é atrito novo entre a pergunta e a resposta |
| Movimento | **9** | os meus dois vídeos, 30 fps, nos dois modos: nenhum quadro com dois textos legíveis; a instrução sai no mesmo driver da nota; papel limpo antes de a pergunta amanhecer. Durações todas em `Tema.Duracao`, `Tema.animacao(..., reduzido:)` em cada troca. O vídeo do ANTES sob Reduzir Movimento não existe — não é limite que pese: o depois eu gravei e julguei |
| Componentes | **7** | nada de componente novo, e a `Pilula(.larga)` já existia — a promessa foi cumprida. Mas o remendo do contorno de 0,5 esconde que **`Pilula` não tem estado desabilitado para chamador nenhum** (A3): a causa-raiz foi contornada num caller em vez de fechada no componente |
| Acessibilidade | **6** | AX5 fechado nos dois defeitos, conferido ao vivo (uma coluna, zero hífen, campo com ~285 pt, alvos ≥ 44 pt via `.alvo()` e `minHeight: Tema.alvo`); `CalendarioTema.chrome` é `.body`, então a ação principal escala. Derruba A3: 1,61:1 na ação principal do estado de abertura. VoiceOver não ligado — limite legítimo (exige humano) |
| Performance | **8** | digitação e rolagem sem engasgo observável nas cinco passagens que fiz ao vivo. Sem medida: o diff mete o `TextEditor` dentro de um `GeometryReader` com `ViewThatFits` (dois layouts de teste por passada) e a ESTEIRA pede Instruments quando se toca o editor. Não achei defeito; achei falta de prova |
| Privacidade e autoria | **9** | o diff é de camada de view; `VozDoAutor.juntar`, `Prova.pontos` e o caminho da nota intocados; nada publica, gasta ou envia sem gesto — a chamada à sábia continua atrás de abrir o Recordar. A guarda nova só **descarta** resposta, então reduz exposição. Ressalva B3: descarta depois de pagar |
| Estado honesto | **5** | o toast do "hoje não" nasce em cima dos controles, reproduzido duas vezes por mim (A1) — o defeito 15 da V9 está aberto e foi declarado fechado. O resto da dimensão está bem: "volta amanhã." diz o efeito, a ação bloqueada continua visível em vez de sumir, e a pergunta que chega tarde não finge que sempre esteve ali |
| Complexidade | **6** | +218/−88 = **+130 líquidas** contra a regra de líquido-negativo da ADR 05v (M3). Metade ganha o lugar; a metade cara (`GeometryReader`/`ViewThatFits`) ainda não, porque cobra M1 |
| Fora do app | **n/a** | a volta não toca widget, Ilha, tela bloqueada, StandBy nem intents — `git diff --stat` são dois arquivos de código, ambos do Recordar |
| Relato | **6** | a mensagem do commit é excelente e legível por quem não abre terminal — diz o que caiu, o que ficou e o que prova. Mas não existe arquivo de relato (a V18 tinha), as seis fases não aparecem (A2) e o texto afirma como resolvido um defeito que está vivo (A1) |

**Média:** 6,9 sem contar a n/a. **Seis dimensões abaixo de 9.**

## 6. O que eu devolvo ao orquestrador

**Corrigir antes de mesclar, em ordem de custo/valor:**
1. **A1** — o toast (dono: `PaginaView`). Sozinho, é o item que faz a volta mentir
   em quatro documentos. Enquanto não cair, tirar a linha do EVOLUCAO, da ADR e
   do commit que diz que caiu.
2. **A3** — estado desabilitado em `Pilula` (dono: `Traco/Componentes`), não outro
   remendo no Recordar. Fecha Acessibilidade e Componentes de uma vez.
3. **M1** — o teto da pergunta ser teto, não cota. Fecha Design e destrava a
   exceção de Complexidade.
4. **A2 / M5** — as seis fases e os quatro itens da curva-zero num arquivo de
   relato. É escrita, não código.
5. **M4** — um teste para a guarda da pergunta.

**Os limites declarados, julgados:** VoiceOver não ligado é **limite legítimo**
(exige humano, e a V8 cobre a árvore). O vídeo do ANTES sob Reduzir Movimento é
**limite sem peso** — o depois existe, eu gravei o meu, e o julgamento não
dependia do antes. "O QUE NÃO VOLTOU" sem foto é **desculpa** (M2): o motivo dado
é falso e a captura levou quatro minutos.

**O que eu recomendo que NÃO se mexa:** o pé único, a `Pilula(.larga)` como único
objeto escuro, o `.leading` na raiz, o `.topLeading` do `GridItem`, o
`comparaLadoALado` testado e a guarda da pergunta. São seis acertos e o quinto é
o modelo de como esta base de código devia tratar toda regra de layout.

**Capturas desta revisão:** `ferramentas/orca/v19-rev-01-toast-tapa-a-barra.png`,
`v19-rev-02-escrever-vao-morto.png`, `v19-rev-03-revelar-large-nao-voltou.png`,
`v19-rev-04-ax5-escrever-vivo.png`,
`v19-rev-05-quadros-rm-instrucao-sai-com-a-nota.png`,
`v19-rev-06-quadros-antes-instrucao-sobrevive.png`.
