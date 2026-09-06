# G4 — volta 16: métodos com proveniência (ADR 2026-09-05x)

Julgado por: segundo Claude (sessão própria; começou em Fable 5.1, terminou em Opus 5 depois de a cota do Fable estourar no meio do portão), papel *julgar* do `design-router`, fases Mover, Julgar e Portão.
Data: 06/09/2026, 05:00–13:00. Branch `Vitorepf/volta-16-metodos`, topo `ab5c052` sobre main `0d0d007`.
Instrumento: iPhone 17 Pro Max de teste `6033B043-F436-41F9-B4F8-2D9E67761980` — ligado por mim, build do branch instalado, usado, Dynamic Type e Reduzir Movimento restaurados, desligado ao fim. Build por `ferramentas/orca/com-trava.sh`: `** BUILD SUCCEEDED **`, 0 `warning:`. Nenhum outro simulador tocado. Sem edição, sem commit.

## Veredito: CORRIGIR ANTES

> **Superado.** A V16-C corrigiu o item e o re-G4 no fim deste arquivo dá **PASSA** sobre `122277f`, com Movimento 9. O que segue é o julgamento de `ab5c052`, conservado como registro.

Um item bloqueia, e é de movimento. **A mesma "de onde vem" abre com a lei da casa na Lente (0,25 s medidos; 0,15 s sob Reduzir Movimento) e não se move no Perfil (corte de um quadro), na tela onde o deslocamento é maior** — e a ADR 05x descreve uma "seta que gira" que a tela não gira. Fora isso a volta é boa: a proveniência é informação e não selo, os tokens são os do `Tema`, o componente é um só para as duas telas, e a correção do G3 (a lista compacta) devolveu ao Perfil a altura que a primeira versão tinha tomado — medi 7 pt de crescimento em doze métodos contra o main, não os ~920 pt que o G3 temia.

## Notas

| dimensão | nota | passa? |
|---|---|---|
| Design | 9 | sim |
| Simplicidade | 9 | sim |
| Movimento | **8** | **não** |
| Componentes | 9 | sim |

## Evidência nova deste portão

Vídeo `g4-v16.mp4` (17,7 s, três trechos, `simctl recordVideo` no meu aparelho):

| trecho | o que mostra |
|---|---|
| 0–6 s | Lente, Dynamic Type `large`: "De onde vem" abre, fecha e abre |
| 6–12 s | Perfil › Métodos: WOOP abre, Se–então abre (WOOP fecha), Se–então fecha |
| 12–17,7 s | Lente com **Reduzir Movimento** ligado: os mesmos três toques |

Capturas (todas minhas, `simctl`, aparelho de teste, `large` salvo onde diz AX5):
`g4-v16-antes-lente.png` e `g4-v16-antes-perfil-metodos.png` (main `0d0d007`, compiladas por mim num worktree temporário e já removido) · `g4-v16-lente-recolhida.png` · `g4-v16-lente-expandida.png` · `g4-v16-perfil-lista.png` · `g4-v16-perfil-woop-aberta.png` · `g4-v16-metodo-ausente.png` (reproduzido por mim: plantei `cornell.json` na pasta do autor, escrevi a nota, apaguei o arquivo, reabri) · `g4-v16-rm-lente-recolhida.png` · AX5: `g4-v16-lente-ax5-1..4.png` (a proveniência inteira, rolada) e `g4-v16-perfil-ax5-woop-aberta.png`. Quadros do Perfil a 30 fps em `g4-v16-perfil-quadros.png`.

## 1. MOVER — a lei do movimento contra o cronômetro

Medi quadro a quadro (vídeo a 30 fps, diferença média entre quadros consecutivos; um "corte" é uma mudança que acontece entre dois quadros vizinhos e nada no meio).

| gesto | quadros | duração | o que a lei pede |
|---|---|---|---|
| Lente, abrir/fechar (3×) | 8 | **267 ms** | `Duracao.media` 0,25 s, `easeOut` — bate |
| Lente sob Reduzir Movimento (3×) | 5 | **167 ms** | `Tema.fadeReduzido` 0,15 s — bate |
| Perfil, abrir/trocar/fechar (3×) | **1** | **33 ms** | nada: corte seco |

A Lente está certa e está certa pelo caminho certo: `Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)` no toque e `Tema.transicao(.opacity, reduzido:)` no bloco (`LenteView.swift:78,105`), isto é, passa pela lei única da ADR 05v em vez de repetir número. Interrompível: os três toques do vídeo completam sem empilhar. Sob Reduzir Movimento sobra a opacidade, que é o que a lei manda para `.opacidade`.

O Perfil não anima nada (`PerfilView.swift:237`: `provenienciaAberta = aberta ? nil : m.id`, sem `withAnimation`; a view nem tem `@Environment(\.accessibilityReduceMotion)`). Consequências que vi na tela:

1. **A seta não gira.** O `rotationEffect(.degrees(aberta ? 180 : 0))` troca de estado entre dois quadros. A ADR 05x escreve "seta que gira": o contrato e a tela discordam.
2. **Um bloco de 414 pt (medido) aparece de um quadro para o outro no meio de uma lista de 21 linhas**, e tudo abaixo salta sem explicação (quadros 176→177 do trecho do Perfil; folha de contato `g4-v16-perfil-quadros.png`). Com "um aberto por vez", trocar de método faz dois saltos simultâneos: um fecha, outro abre.
3. **Mesma informação, mesmo gesto, duas telas, dois comportamentos** — e o corte ficou justamente onde o movimento explicaria mais.

O vocabulário da casa tem o verbo certo e já está escrito na tela ao lado. `Tema.corte(_:reduzido:)` existe, mas a ADR 05v o reserva para "o que o dedo arrasta e o que o relógio move"; abrir um bloco não é nem um nem outro. Por isso **8, e não 9**.

Correção (uma linha e um `@Environment`): envolver a atribuição em `withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion))` e dar ao bloco a mesma `Tema.transicao(.opacity, reduzido:)` da Lente. Se o implementador defender o corte, então é a ADR que muda: tira "seta que gira" e nomeia a exceção com motivo. Revalidar com vídeo novo do Perfil, normal e com Reduzir Movimento.

## 2. JULGAR

### Informação, não selo — passa

Abri a proveniência nas duas telas e procurei o que costuma virar carimbo: cor de aprovação, medalha, ícone, nota, "verificado". Não há nada disso.

- **Tipografia sem hierarquia de valor.** Rótulo em `.rotulo()` (11 semibold, caixa alta, tracking +1,2, `tintaFraca`) e valor em `Tema.meta` sobre `Tema.tinta`. As cinco linhas têm exatamente o mesmo peso: FONTE não é mais importante que EVIDÊNCIA, e SERVE PARA não é um rodapé (`g4-v16-lente-expandida.png`).
- **Sem cor.** O bloco inteiro é acromático. O único âmbar da Lente continua nos botões Instigar e Contrapor, que são ação — o "um acento por tela" do §11 sobrevive. Vale registrar o Δ da correção: a primeira versão da volta (`v16-perfil-metodos.png`) tinha **21 links âmbar "de onde vem"** empilhados no Perfil; o âmbar repetido 21 vezes deixava de ser assinatura e virava ruído. A correção trocou os 21 por uma seta cinza. Foi a melhor decisão da volta.
- **A classificação não vira grau.** "FUNÇÃO: estudo com evidência delimitada" poderia ser lido como um selo de qualidade acima de "prática". Não é, por dois motivos que vi na tela: as três palavras usam a mesma tinta e o mesmo corpo de qualquer outro valor, e a linha EVIDÊNCIA vem logo abaixo delimitando ("em geral modestos e dependentes de a meta ser viável. Não há estudo do uso dentro do Traço"). Quem lê recebe o limite junto com a etiqueta.
- **A adaptação está declarada.** "O QUE O TRAÇO ADAPTOU" diz que o Traço cobra três campos e recusa o obstáculo externo. Um app que quisesse parecer científico esconderia isso.

### Densidade — passa

| estado | o que a tela pede | evidência |
|---|---|---|
| Lente recolhida (padrão) | uma linha a mais: rótulo WOOP + "a forma desta nota" + a cápsula "De onde vem" | `g4-v16-lente-recolhida.png` |
| Lente expandida | ~600 pt de texto cinza; Instigar e Contrapor descem, Apontar sai da primeira tela | `g4-v16-lente-expandida.png` |
| Perfil, lista | 12 métodos na primeira tela, um a um legíveis | `g4-v16-perfil-lista.png` |
| Perfil, uma aberta | a linha do método vira cabeçalho de um bloco de cinco linhas | `g4-v16-perfil-woop-aberta.png` |

Comparei com o main compilado por mim. Na Lente, o bloco novo empurra o bloco de ações **107 pt** para baixo (`g4-v16-antes-lente.png` × `g4-v16-lente-recolhida.png`); em `large` as três ações continuam na primeira tela. Expandido, o custo é grande, mas é o autor que pede, um toque desfaz, e o padrão é recolhido: `critique-information-density` cobra a tela que chega pesada, não a que engorda a pedido.

No Perfil a medida é a resposta ao B7 do G3. Alinhei as duas capturas por densidade de tinta por linha: **+0 px nas primeiras linhas, +21 px (7 pt) na altura de doze métodos**. A lista praticamente não cresceu, porque a correção fez a **linha ser o alvo** em vez de somar uma linha "de onde vem" por método. O medo de ~920 pt não se realizou.

### Hick — passa, com uma ressalva

A lista de 21 não pede decisão nova: nada se perde por não tocar, o conteúdo primário da linha (nome, origem, campos) continua o mesmo, e a marca nova é uma seta pequena repetida 21 vezes — 21 marcas idênticas somam pouco ruído. `hicks-law` mede escolhas simultâneas com consequência; aqui a consequência é reversível e local, e o Perfil abre **um por vez**, o que impede a tela virar um acordeão de 21 blocos abertos.

A ressalva é de *affordance*, não de Hick: na Lente o controle é uma cápsula em `superficieBaixa` com o rótulo "De onde vem" — lê-se como controle. No Perfil o mesmo controle é a linha inteira sem fundo, e o único convite é a seta no fim do título. É a convenção do iOS (`jakobs-law`) e funciona, mas as duas telas convidam com força diferente para o mesmo gesto. Não bloqueia; entra na dívida.

### Estado honesto — passa

Reproduzi o método ausente eu mesmo (`g4-v16-metodo-ausente.png`): "o método "cornell" saiu da sua pasta; os campos continuam na nota." em `Tema.tintaSuave`, dentro da mesma cápsula onde estaria o controle, com o cabeçalho CORNELL / "a forma desta nota" preservado, e Instigar, Contrapor e Apontar intactos abaixo. Sem vermelho, sem ícone, sem alerta: é estado, não erro, como a ADR 04a exige — e é exatamente o reparo que o G3 pediu no B8 (era `Tema.aviso`). Sem cartaz: a frase ocupa duas linhas e some do caminho de quem só quer trabalhar a nota. Diz de quem é a lacuna sem culpar o autor ("saiu da sua pasta", "o arquivo do método não tem o campo"), o que é o tom certo para um arquivo que é dele.

Um detalhe para quem passar por ali depois: a cápsula do estado tem o mesmo desenho da cápsula do controle "De onde vem". Nada convida ao toque (não há seta), mas são dois papéis numa forma só.

### AX5 — passa, sem clipe, com uma quebra feia herdada

- Lente: rolei a proveniência inteira em `accessibility-extra-extra-extra-large` (`g4-v16-lente-ax5-1..4.png`). Tudo quebra linha, nada é cortado, nada trunca, os cinco rótulos e os cinco valores aparecem por inteiro.
- Perfil: `g4-v16-perfil-ax5-woop-aberta.png` — o bloco abre e lê-se; sem clipe.
- **Mas** a linha do método fica ruim em AX5: a origem hifeniza no meio da palavra e ocupa três linhas ("Gabriele Oettin-gen") à direita do nome, e o cabeçalho da folha encosta "Métodos" em "Pronto". O cabeçalho é herdado (o diff não o toca); a coluna da origem piorou nesta volta, porque a seta nova disputa a mesma largura. Não é clipe e não bloqueia; é dívida nomeada.

### O componente é o vocabulário certo — sim

`Traco/Componentes/LinhasDeProveniencia.swift`: um arquivo, nome em português, **três `#Preview`** (catálogo, do autor sem o campo, AX5), zero hex e zero tamanho solto (usa `Tema.meta`, `Tema.tinta`, `Tema.tintaSuave` e o `.rotulo()` da V10), `accessibilityIdentifier` parametrizado para as duas telas, e o par rótulo+valor que é o vocabulário do SISTEMA-CLARO (§3: "rótulo de seção 11 semibold caixa alta"; §2.3 fala em rótulo + campo). Cobre os quatro estados que existem: catálogo, do autor com campo, do autor sem campo, função inválida. **É o que o G3 pediu no B4** — as duas cópias de `proveniencia(_:)` viraram uma. Fica em 9 e não em 10 por duas migalhas: `var identificador = "proveniencia"` tem um valor padrão morto (o `init` sempre o define), e os rótulos "FONTE"/"SERVE PARA" moram no modelo (`Metodo.Proveniencia.linhas`), que é o padrão da casa mas continua sendo cópia de tela dentro de `Traco/Modelo`.

O que **não** virou componente é a linha que abre. A Lente e o Perfil escreveram cada uma a sua, e as duas setas divergem: `.footnote` em `tintaFraca` na Lente, `.caption2` em `tintaSuave` no Perfil — mesma glifo, mesmo significado, dois desenhos, na mesma volta. A ADR 05v já tinha nomeado a dona (`LinhaQueAbre`, "a variante que abre um bloco abaixo entra na V12"), então a dívida é da V12; a divergência é desta volta. Não bloqueia — o componente que a volta prometeu, ela entregou — mas vai para o RUMO com os dois chamadores novos.

## 3. As seis fases do `design-router`, julgadas contra a tela

Ordem nova do dono (ESTEIRA, "Skills obrigatórias por portão"). A V16 começou antes dela, então julgo as fases eu mesmo e registro a ausência de citação como dívida, sem barrar.

| fase | veredito | contra o quê |
|---|---|---|
| Ancorar | cumprida | a volta ancora no que a VISAO cobra (distinguir prática, lente e estudo com evidência delimitada) e na ADR 05o (método que sumiu). Contrato em ADR 05x, com "Custo assumido" e "Fora" honestos. |
| Sistema | cumprida | conferida na tela e no diff: nenhum hex, nenhum `.system(size:)` novo no que a volta escreveu; tudo cita `Tema` e `.rotulo()`. Um acento por tela preservado. |
| Construir | cumprida | componente em `Traco/Componentes` com previews e estados; dois chamadores; identificadores estáveis; AX5 sem clipe nas cinco capturas. |
| **Mover** | **falha parcial** | a Lente obedece à lei (0,25 / 0,15 medidos); o Perfil não se move e a ADR diz que a seta gira. É o item que bloqueia. |
| Julgar | fora do relato | não existe `relatorio-v16-*.md`. O julgamento aconteceu, mas no G3 e depois dele: os 21 links âmbar e a cor de aviso do método ausente foram achados pelo revisor, não pelo autor da volta. |
| Portão | este documento | — |

**Dívida:** nenhum artefato da V16 (ADR 05x, revisão do G3, EVOLUCAO) cita as seis fases pelo nome. Da próxima volta visual em diante isso barra; aqui fica registrado.

## 4. Portão

| dimensão | nota | evidência |
|---|---|---|
| **Design** | **9** | proveniência é informação e não selo: rótulo+valor no mesmo peso, zero cor, classificação delimitada pela linha seguinte (`g4-v16-lente-expandida.png`, `g4-v16-perfil-woop-aberta.png`); tokens do `Tema` em tudo que a volta escreveu; o âmbar continua só na ação; a correção trocou 21 links âmbar por uma seta cinza. Não é 10: duas setas com dois desenhos para o mesmo significado, e a linha do Perfil quebra feio a origem em AX5. |
| **Simplicidade** | **9** | caminho comum intacto (recolhido por padrão); telas +0, decisões +0, passos: 1 toque na Lente, 3 no Perfil; um aberto por vez; a lista do Perfil cresceu **7 pt em doze métodos** contra o main (medido, `g4-v16-antes-perfil-metodos.png` × `g4-v16-perfil-lista.png`), contra os ~920 pt que a primeira versão custava. Não é 10 porque o Perfil, como tela, continua com a nota base 6 da auditoria V9 — esta volta não a toca. |
| **Movimento** | **8** | Lente 267 ms / 167 ms sob Reduzir Movimento, pela lei única (`g4-v16.mp4`, 0–6 s e 12–17,7 s). Perfil: 33 ms, um quadro, sem animação e sem `reduceMotion` na view, com 414 pt saltando no meio de 21 linhas e a "seta que gira" da ADR que não gira (6–12 s). |
| **Componentes** | **9** | `LinhasDeProveniencia` num lugar só, nome em pt, 3 previews, 4 estados, tokens, dois chamadores — fecha o B4 do G3. Não é 10: valor padrão morto no `identificador`, rótulos de tela no modelo, e a linha que abre escrita à mão duas vezes com setas divergentes (dona nomeada: V12). |

**Lista mínima para passar (só isto):**

1. `PerfilView.swift:237` — a abertura da proveniência tem de obedecer à lei da casa: `withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion))` no toque, `Tema.transicao(.opacity, reduzido:)` no bloco, `@Environment(\.accessibilityReduceMotion)` na view. Alternativa legítima: manter o corte e **mudar a ADR 05x**, tirando "seta que gira" e nomeando a exceção com motivo. Prova: vídeo do Perfil normal e com Reduzir Movimento, quadro a quadro.

**Recomendado, não bloqueia:** uma seta só para um significado só (mesmo corpo e mesma tinta na Lente e no Perfil; `caption2` + `tintaSuave` é o que a `LinhaQueAbre` já usa) e apagar o valor padrão morto de `identificador`.

## 5. Dívida nomeada para o RUMO

**Perfil** (nota base 7,7 na auditoria V9: Design 7, Simplicidade 6 — esta volta não a muda)
- **P1.** A linha que abre não tem componente nem movimento. Dona: V12 (`LinhaQueAbre`, variante "abre um bloco abaixo"). Chegam agora dois chamadores novos, com setas divergentes.
- **P2.** Em AX5 a linha do método quebra a origem no meio da palavra e o cabeçalho encosta "Métodos" em "Pronto". Pede um arranjo que empilhe nome/origem em corpos de acessibilidade.
- **P3.** O que dá 6 em Simplicidade continua de pé: o cartão CONTA gasta a primeira tela, quatro telas de rolagem, 12 seções, e o que se toca fica no meio. A folha Métodos melhorou; a tela Perfil, não.

**Lente**
- **L1.** Com a proveniência aberta, Apontar sai da primeira tela; em corpos de acessibilidade a Lente já exigia rolagem. A tela ainda não tem uma volta própria no RUMO.
- **L2.** A bibliografia dos 21 métodos vive só em `Metodos.json` (B9 do G3). Nenhum documento do repositório sustenta as fontes que a tela mostra.

**Processo**
- **D1.** A V16 não tem relatório do implementador e nenhum artefato dela cita as seis fases do `design-router`. Registrado, não barrado (a regra é posterior à volta).

## 6. Três linhas para o LACO

- V16 dá origem, adaptação, evidência e limite aos 21 métodos, na Lente da nota e na lista do Perfil, com um componente só (`LinhasDeProveniencia`, 3 previews) e sem um selo sequer: rótulo e valor no mesmo peso, zero cor, e a evidência que se delimita a si mesma ("não há estudo do uso dentro do Traço").
- A correção do G3 é o que salvou a volta: 21 links âmbar viraram uma seta cinza e a linha do método virou o alvo, o que fez a lista do Perfil crescer **7 pt em doze métodos** contra o main em vez dos ~920 pt temidos; o método que saiu da pasta agora é dito em tinta neutra, estado e não erro, reproduzido neste portão.
- Fica um item, e é de movimento: a mesma "de onde vem" abre em 0,25 s na Lente (0,15 s sob Reduzir Movimento, medidos em vídeo) e em 0 s no Perfil, onde 414 pt saltam no meio de 21 linhas e a "seta que gira" da ADR não gira — uma linha de `withAnimation` separa a V16 do merge.

---

# Re-G4 — 06/09/2026, sobre `122277f` (V16-C)

Mesmo juiz, mesma sessão, mesmo aparelho (`6033B043`, ligado por mim, build do topo do branch instalado, Dynamic Type `large` e Reduzir Movimento restaurados, aparelho desligado ao fim; nenhum outro simulador tocado). Build por `com-trava.sh`: `** BUILD SUCCEEDED **`, 0 `warning:`. Julguei **só** o que barrei e o que a correção mexeu. Design 9, Simplicidade 9 e Componentes 9 continuam valendo — o diff da V16-C toca três arquivos e não encosta em nada que sustentava essas três notas.

## Veredito: PASSA

| dimensão | nota antes | nota agora |
|---|---|---|
| Movimento | 8 | **9** |
| Design · Simplicidade · Componentes | 9 · 9 · 9 | inalteradas |

## O que eu medi, no meu vídeo, não no dele

`g4-v16-reg4-perfil.mp4` (7,9 s: 0–4 s normal, 4–7,9 s com Reduzir Movimento), gravado por mim com `simctl recordVideo` e medido quadro a quadro em resolução cheia (diferença média absoluta entre quadros vizinhos, limiar 0,15; "distintos" = nenhum quadro repetido dentro da curva).

| gesto | quadros | duração | quadros distintos |
|---|---|---|---|
| Perfil, abrir (normal) | 123–129 | **233 ms** | 7 de 7 |
| Perfil, fechar (normal) | 191–198 | **267 ms** | 8 de 8 |
| Perfil, abrir (Reduzir Movimento) | 322–327 | **200 ms** | 6 de 6 |
| Perfil, fechar (Reduzir Movimento) | 387–390 | **133 ms** | 4 de 4 |
| Lente, abrir (normal) | 109–115 | **233 ms** | 7 de 7 |
| Lente, fechar (normal) | 173–180 | **267 ms** | 8 de 8 |
| **controle: uma rolagem, na mesma gravação** | 244–318 | 2 500 ms | **75 de 75** |

No G4 anterior o mesmo gesto no Perfil dava **1 quadro, 33 ms**. Agora dá 7 e 8, exatamente os números que eu tinha medido na Lente — e a Lente, remedida hoje sob a mesma carga de máquina, dá os mesmos 7 e 8. **As duas telas passaram a se mover igual.** Sob Reduzir Movimento a curva encurta para 4–6 quadros: os 133–200 ms cercam os 167 ms de `Tema.fadeReduzido` com o erro de ±1 quadro de quem conta bordas, e o que importa está provado — sob movimento reduzido a curva é materialmente mais curta e sobra a opacidade, que é o que a lei manda para `.opacidade`.

O controle é meu, não dele: a mesma gravação que mostra a expansão em 7 quadros mostra uma rolagem com 75 quadros distintos em 2,5 s. O gravador captura quadros intermediários nesta máquina, agora, com seis simuladores ligados. Logo, 1 quadro antes era o app, e 7 agora também.

## A seta gira — visto, não deduzido

`g4-v16-reg4-perfil-quadros.png` (quadros 122–130, 30 fps, um antes da curva e um depois): quadro 122 fechado com a seta para baixo; 123 com a seta a ~45° e o bloco entrando em opacidade baixa; 124, 125 e 126 com a seta em ângulos intermediários e o texto ganhando corpo; 127–130 com a seta para cima e o bloco cheio. Sob Reduzir Movimento (`g4-v16-reg4-rm-quadros.png`, quadros 321–328) a mesma rotação acontece em menos quadros. A "seta que gira" da ADR 05x agora gira; era exatamente o que eu tinha cobrado.

## O achado dele sobre o `.sheet` — confirmado no que importa, com um limite meu

Ele diz que `withAnimation` disparado na tela que apresenta não atravessa a fronteira do `.sheet` (mediu 1 quadro com a correção literal que eu pedi) e que por isso a lei entrou por `.animation(_:value:)` na folha, com os mesmos tokens.

- **O que eu confirmo:** o resultado na tela é o que a ADR promete, medido por mim nos dois modos, com controle próprio do instrumento. O critério do portão era esse.
- **O que eu confirmo por leitura:** `PerfilView.swift:285` aplica `Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)` com `value: provenienciaAberta`, e o bloco leva `Tema.transicao(.opacity, reduzido:)`. Mesmos tokens, mesma duração, mesma lei única da ADR 05v — muda o lugar da transação, não a lei. O comportamento que ele descreve é o esperado de uma folha, que o SwiftUI hospeda numa apresentação própria: o estado atravessa, a transação não.
- **O meu limite, dito:** não reproduzi a variante que falhou. Reproduzi-la exigiria editar código, e o portão me proíbe. Aceito a medição dele porque a conclusão é verificável pelo outro lado — a técnica que ficou produz, no meu aparelho e na minha medição, os 233/267 ms e os 200/133 ms acima.
- **Está no lugar certo:** a ADR 05x registra a diferença de técnica em uma frase, para quem passar por aqui não repetir a tentativa. É contrato, não desabafo de código.

## Os dois recomendados

- **Uma seta só.** Medi a glifo na Lente recolhida, em pontos do aparelho: **12,3 × 6,8 pt** antes (`g4-v16-lente-recolhida.png`, `.footnote`/`tintaFraca`) contra **9,7 × 5,7 pt** agora (`g4-v16-reg4-lente-seta.png`), e a tinta escureceu (cinza médio da glifo 128,6 → 114,2), que é a passagem de `tintaFraca` para `tintaSuave`. É o desenho que o Perfil e a `LinhaQueAbre` já usavam. Feito.
- **Valor padrão morto.** `var identificador = "proveniencia"` virou `let identificador: String`. Feito, e o build não reclamou.

## Por que 9 e não 10 em Movimento

A lei vale nas duas telas com os mesmos tokens e os mesmos números, é interrompível, respeita movimento reduzido e a exceção de técnica está declarada na ADR. O que falta para 10 não é defeito, é dívida: o app passa a ter **dois mecanismos para uma lei só** — `withAnimation` no toque na Lente, `.animation(_:value:)` na folha no Perfil. Quem escrever a próxima linha que abre terá de saber em qual dos dois casos está. É precisamente o que o componente compartilhado resolveria, e ele já tem dona.

## Dívida para o RUMO (atualizada)

- **P1 (fica, com um agravante nomeado).** A linha que abre continua sem componente; agora, além de dois desenhos que viraram um, há **dois mecanismos de animação** para o mesmo gesto. Dona: V12 (`LinhaQueAbre`, variante "abre um bloco abaixo"). Quem a construir deve embutir a lei de modo que o chamador não escolha entre `withAnimation` e `.animation(_:value:)`.
- **P2, P3, L1, L2, D1:** inalteradas. A V16-C não as toca e não devia tocar.
- **Migalha de registro:** `relatorio-v16-c.md` diz topo `425e112`; o topo real do branch é `122277f`. Corrigir no fecho para o LACO não herdar um sha que não existe.

## Três linhas para o LACO

- O Perfil passou a abrir a proveniência com a lei da casa: 233 ms para abrir e 267 ms para fechar, os mesmos números da Lente remedida no mesmo aparelho e na mesma hora, contra o corte de 1 quadro que barrou a volta — e a seta gira, com ângulos intermediários vistos quadro a quadro.
- Sob Reduzir Movimento a curva encurta para 133–200 ms e sobra a opacidade, como a lei manda; uma rolagem de 75 quadros distintos na mesma gravação prova que o gravador não estava escondendo movimento nenhum.
- O implementador achou, medindo e não lendo, que `withAnimation` não atravessa a fronteira do `.sheet`, entrou pela `.animation(_:value:)` com os mesmos tokens e escreveu isso na ADR 05x; o custo é o app ficar com dois mecanismos para uma lei só, dívida que a `LinhaQueAbre` da V12 fecha. **Movimento 9, volta PASSA.**
