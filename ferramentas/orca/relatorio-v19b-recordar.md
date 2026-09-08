# Relato — volta 19-B, a correção do G3 do Recordar (ADR 2026-09-06k)

Claude Opus 5, front-end e design, 06/09/2026. Worktree `volta-19-recordar` sobre
`dd54864`. Simulador **iPhone 17 Pro (teste 4) `A1DF082C`**, ligado e desligado por
mim; cinco outros simuladores ligados na máquina e o iPhone 17 do dono **não
tocado**. Build e `xcodebuild test` sob `ferramentas/orca/com-trava.sh`.

**Instrumento, e é o que mais interessa a quem retomar:** com seis simuladores
ligados o maestro lê a hierarquia do vizinho (lei do instrumento da ESTEIRA), e o
toque por coordenada cai na janela do vizinho. O que funcionou foi trazer a MINHA
janela para a frente por AppleScript (`AXRaise` na janela cujo nome contém
"teste 4"), ler `position`/`size` dela e calibrar o mapa **uma vez**: com a janela
em `754, 76` e `402 × 950`, o ponto do aparelho vira tela em
`(754 + x_pt, 152 + y_pt)` — os 76 pt de diferença entre a janela e a tela de 874
são a barra de título do Simulador do iOS 26. A calibração se confere sem tocar em
nada: `cliclick m:x,y` e depois `screencapture -C -x -R<janela>`, que fotografa o
cursor **dentro** do quadro do simulador. Acertei o alvo na primeira tentativa e
não precisei de maestro em momento nenhum. Escrever texto é `cliclick t:"..."` com
o campo já focado. Prova de tela é sempre `xcrun simctl io <MEU-UDID> screenshot`,
nunca `booted` — com cinco simuladores ligados `booted` é ambíguo.

Foi **ordem de parada do dono** no meio desta volta. O que está aqui está fechado e
medido; o que ficou por fazer está nomeado no fim, com dono.

---

## As seis fases do `design-router`

### 1. Ancorar

Pessoa e situação: o autor, sozinho, no ritual **mais repetido do app** — abrir uma
nota que ele mesmo escreveu dias atrás e tentar trazê-la de volta de memória antes
de ver o original. Tarefa principal: escrever de memória e comparar. Resultado
observável: a tela do revelar com "DE MEMÓRIA" e a nota lado a lado, e o que não
voltou. Plataforma: iPhone, só iPhone. Restrição herdada e não negociada: a
curva-zero da V9 (1 toque + escrever + 1 toque) **não pode crescer**, e o §12
proíbe placar, nota ou porcentagem — recuperação parcial é o caso normal da
prática, não um fracasso a medir.

A âncora desta volta-B não é o pedido: é a **recusa do G3**. Três achados altos,
seis dimensões abaixo de 9. Reli a recusa inteira antes de abrir um arquivo, e a
primeira coisa que fiz foi conferir na tela e no código onde cada achado morava —
porque dois deles moravam fora do meu escopo, e descobrir isso depois de editar
seria tarde.

### 2. Sistema

Nada de componente novo, nada de token novo, e **nada de Tema**. A volta 19 já
tinha feito a parte difícil do sistema — `Pilula(forma: .larga)` como ação
principal, `CabecalhoDeFolha`, `.rotulo()`, `.buttonStyle(.primario/.discreto)`,
todas as durações em `Tema.Duracao` e `Tema.animacao(..., reduzido:)` em cada
troca —, e o revisor confirmou os três ao vivo. A 19-B não acrescentou uma cor,
uma fonte nem uma duração.

Onde o sistema **falta**, eu medi em vez de remendar: a `Pilula` não tem estado
desabilitado para chamador nenhum. Com `isEnabled == false` ela devolve
`fundo = .clear` e `tinta = Tema.tintaMorta`, e `tintaMorta` #C7C7CC sobre o papel
#F4F4F2 dá **1,53:1**. Isso não é dívida do Recordar; é dívida da volta dos
Componentes. Consertar num chamador só — que é tudo o que o meu escopo permitiria
— pioraria o sistema para melhorar uma tela. Parei e escrevi a causa.

### 3. Construir

Quatro mudanças, todas dentro de `Traco/Recordar/RecordarView.swift` e
`TracoTests/ProvaTests.swift`:

- **O teto virou teto** (M1). O `.frame(maxHeight: geo.size.height / 2)` estava do
  lado de FORA do `ViewThatFits`, e um `maxHeight` finito num contêiner que sabe
  crescer não limita: cobra. A metade desceu para dentro do ramo que rola, que é o
  único que precisa dela. O ramo que cabe voltou a ter altura de conteúdo.
- **A máscara de gradiente saiu** (B1). Ela desmaiava a última linha da pergunta
  também quando já se tinha rolado até o fim — quem chegava ao fim via a última
  linha apagada para sempre. Nenhuma outra `ScrollView` desta base mascara a
  borda, nem a do `ler`, na mesma tela. Menos quatro linhas.
- **A regra da pergunta tardia virou função** (M4/B3):
  `RecordarView.aceitaPergunta(jaTem:memoria:)`, `nonisolated static`, na mesma
  receita do `comparaLadoALado`. Ela vale agora nos DOIS lados do `await` — antes
  de pedir e depois de voltar — e a `.task(id: memoriaVazia)` faz a primeira letra
  **cancelar** a chamada em voo, em vez de pagar por uma resposta que vai ao lixo.
- **O rótulo de VoiceOver voltou** (B2). O pé ganhou um parâmetro `ax:` e
  "próxima" volta a ser lida como "Próxima".

O que eu **não** construí, de propósito: nenhum remendo para o A1 e nenhum fork da
`Pilula` para o A3. Os dois moram em arquivo de outra volta.

### 4. Mover

Não mexi em movimento, e a razão é que o revisor já o julgou **9** com evidência
melhor do que a que eu produziria: dois vídeos próprios a 30 fps, nos dois modos,
sem um único quadro com dois textos legíveis, com a instrução saindo no mesmo
driver da nota e o papel limpo antes de a pergunta amanhecer. Mexer em movimento
que já passou, sem defeito aberto, seria trabalho novo numa volta de correção.

Tomei o cuidado de conferir que as minhas mudanças **não** tocam movimento: a
`.task(id:)` só cancela rede, o `ViewThatFits` não anima, e a máscara que saiu era
estática. As transições `entraFase` e os `Tema.transicao(...)` estão intactos.

### 5. Julgar

É a fase que faltou na volta 19, e é a que o revisor cobrou por nome. Antes e
depois, em `large`, no mesmo roteiro e no mesmo simulador:

| | antes da volta 19 | volta 19 (recusada) | volta 19-B |
|---|---|---|---|
| caret âmbar, altura da tela | 23,6 % | **46,2 %** | **22,0 %** |
| papel morto entre pergunta e campo | nenhum | ~198 pt | nenhum |
| última linha da pergunta que rola | — | desmaiada para sempre | cortada pela borda, como no resto do app |
| pergunta tardia | trocava embaixo do autor | descartada depois de paga | cancelada na primeira letra |
| ação principal desabilitada | 6,32:1 | 1,61:1 | **1,53:1 — não consertado** |

**O que se ganhou:** o vão morto sumiu e ficou *abaixo* do original — o autor
escreve mais perto do topo do que escrevia antes da volta 19. A regra mais
importante da volta ganhou teste. A pergunta tardia deixou de custar dinheiro.

**O que se perdeu, e eu digo:** nada nesta volta-B. Mas o que a volta 19 perdeu e
**continua perdido** é o contraste da ação principal, e é o estado em que a tela
sempre abre. Enquanto ele não cair, o `von-restorff-effect` que esta volta veio
consertar segue invertido: a saída "hoje não" (6,73:1) é quatro vezes mais legível
que o caminho ("Revelar", 1,53:1). Não escondo isso para limpar a tela.

Prova: `ferramentas/orca/v19b-01-escrever-sem-vao-morto.png`, `large`, tirada com
`xcrun simctl io A1DF082C screenshot` sobre o build desta árvore.

### 6. Portão

Build sem aviso e
`✔ Test run with 786 tests in 132 suites passed after 7.506 seconds` /
`** TEST SUCCEEDED **` no A1DF082C (a volta 19 fechou em 782/131; os +4 e a +1
suíte são a regra da pergunta tardia). Estado do simulador devolvido a
`content_size = large`, `appearance = light`, `ReduceMotionEnabled = 0`, e o
simulador desligado por quem o ligou. Maestro **não** rodado — lei do instrumento,
seis simuladores. VoiceOver não ligado: exige humano.

**Eu não passo este portão sozinho, e não peço que passe.** Dois dos três achados
altos do G3 continuam abertos porque moram fora do meu escopo, e estão nomeados
abaixo com dono. O que eu fecho, fecho medido.

---

## Os quatro itens da `curva-zero`

**Jornada.** Da página com nota escrita: 1 toque em "Recordar" → a nota se esconde
sozinha → escrever de memória → 1 toque em "Revelar" → memória e nota lado a lado.
Saídas honestas em 1 toque cada: "hoje não" (volta amanhã, a escada não muda),
"pular" (vai à próxima sem revelar). **Medida por mim de novo na tela hoje, e
idêntica à V9: a correção não cobrou um toque.** Em AX5 abrir custa 2 toques
porque as quatro ações da página viram lista vertical — comportamento da barra da
página, anterior a esta volta.

**Resultado verificável.** O autor vê, na mesma tela, o que ele trouxe de memória e
o que estava escrito, com "DE MEMÓRIA" e "A NOTA" na mesma linha de base, e abaixo
"O QUE NÃO VOLTOU" — só o que faltou, nas palavras dele, sem placar e sem
porcentagem (§12). É o resultado que ele reconhece: a diferença entre o que ele
lembrou e o que ele escreveu, não uma nota sobre ele.

**Atrito observado.** Três, todos na tela viva, nenhum lido de relatório:
1. **O vão morto** (fechado): em `large` o autor passou a escrever no meio da folha,
   com ~198 pt vazios entre a pergunta e o cursor. Atrito NOVO, criado pela volta
   19 — a correção de AX5 tinha sido paga com o corpo comum.
2. **A ação ilegível** (aberto): "Revelar" a 1,53:1 no estado de abertura. O autor
   abre a tela todo dia e o caminho está mais apagado que a saída. Atrito NOVO, e
   o mais caro dos três, porque é o primeiro estado e é diário.
3. **O enunciado trocando embaixo de quem escreve** (fechado): o app mexia no que a
   pessoa estava lendo enquanto ela respondia. Atrito antigo, e o único dos três
   que o código já **jurava** ter resolvido num comentário que mentia.

**Recuperação.** Toda saída desta tela é reversível e barata: "hoje não" devolve a
nota para amanhã sem mexer na escada, "pular" não custa um degrau, "voltar" sai sem
apagar nada, e a memória escrita nunca sobrescreve a nota — `VozDoAutor.juntar`, o
caminho da nota e `Prova.pontos` continuam intocados por esta volta. A pergunta que
a sábia manda tarde é descartada, não aplicada: o autor termina com a pergunta que
leu. E quando a sábia falha, some, ou não tem conta, a pergunta fixa segura o
lugar — a tela nunca fica sem enunciado.

---

## O que fica ABERTO, com dono

1. **A1 — o toast do "hoje não" nasce em cima da barra de ações.** Defeito 15 da
   V9, **vivo**. `Traco/Pagina/PaginaView.swift:303`, `.padding(.bottom, 88)`,
   lá desde `eae9a8f` (31/08), antes da auditoria. Conserto: o toast medir a
   altura real da barra em vez de chutar 88. **Dono: quem está na volta 12, dentro
   de `PaginaView`.** Parei na fronteira em vez de invadir o arquivo, por ordem do
   orquestrador. A frase falsa que dizia este defeito morto **saiu** da ADR
   2026-09-06k e do EVOLUCAO.md nesta volta-B.
2. **A3 — a ação principal desabilitada mede 1,53:1.** Causa medida:
   `Traco/Componentes/Pilula.swift:52` (`if !ativa { return Tema.tintaMorta }`) e
   o fundo `.clear` da linha 57 — vale para **todos** os chamadores, não só o
   Recordar. **Dono: `Traco/Componentes`.** Vai ao RUMO pelo orquestrador.
3. **B4 — o ramo `ScrollView` do `ViewThatFits`** (AX5 com pergunta longa da
   sábia) segue sem foto. Não reprovado; não coberto. Reproduzir exige AX5 mais
   uma pergunta longa da sábia na mesma abertura.
4. **AX5 depois da correção do M1** não foi refotografado — a ordem de parada
   chegou antes. O risco é conhecido e nomeado: mudei quem carrega o teto, e o
   corpo grande é justamente o caso que o teto existe para servir. **Quem retomar
   começa por aqui:** `content_size accessibility-extra-extra-extra-large`, abrir
   o Recordar em `escrever`, e conferir que o campo do autor continua com folga
   (o revisor mediu ~285 pt no `dd54864`) e que a pergunta não hifeniza.
