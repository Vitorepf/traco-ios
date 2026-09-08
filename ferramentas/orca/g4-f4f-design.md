> **re-G4 (08/09, 14:05, topo `d1d7301`): PASSA — a seção "re-G4" no fim deste arquivo é o veredito vigente. O julgamento de 12:33 abaixo fica como estava, por registro.**

# G4 da volta F4-F — **NÃO PASSA.** A frase do autor volta a terminar em reticências no pior caso real, e antes disso vira letra de formiga; o médio e o quadro de ofertas passam.

**Papel:** julgar do design (`design-router`: Mover, Julgar, Portão), sessão própria, sem tocar em código.
**Worktree:** `volta-f5-fora-do-app`, topo `0beddcb`. **G3:** treze dimensões em 9, Complexidade corrigida na F4-G.
**Aparelho:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, iOS 26.5, build deste worktree
(`xcodebuild build -scheme Traco -destination id=A1DF082C…` por `com-trava.sh`, 0 `warning:`, instalado às 12:18 de 08/09
por `f5-instalar.sh`, conferido por símbolo `FraseDoAutor LinhasDoDestaque QuadroVazio`).
**Fases cumpridas:** Ancorar (o G4 da F4 e a ADR 08g), Sistema (`Tema.swift`), **Mover**, **Julgar**, **Portão**.
Nenhum toque no mouse do dono: plantio por `f5-plantar.py`, prova de tela por `f5-fotografar.sh` (captura só dada por
boa com OCR), toques por `orca emulator tap --device`. Aparelho restaurado (IconState do `.bak-f5`, claro, `large`,
Reduzir Movimento em 0) e devolvido desligado.

**Os consertos, um por linha, se a volta for reaberta:**
1. A frase do autor ganha um **piso legível em pontos** (nunca abaixo do `Tema.miudo` do tamanho corrente) e, o que não couber, **corta com "…"** — a lei "letra pequena é só letra pequena" vale até um limite, e o limite se testa em `EncolheTests`.
2. A linha nasce **limitada na publicação** (`Superficie`, um teto de caracteres com "…" honesto), porque hoje `VozDoAutor.titulo` publica a primeira linha inteira de uma nota e nenhum piso de escala segura um parágrafo.
3. **O pequeno larga o atalho decorativo "Nova nota" antes de encolher a frase** — é a mesma lei que esta volta aplicou aos atalhos do médio, e no pequeno o atalho nem é toque (o cartão inteiro é o `widgetURL`).

---

## 0. Instrumento — o que serviu e o que não

- **`f5-fotografar.sh` serviu, e provou o próprio valor:** a captura do estado velho esperou **81 s** pelo OCR ler
  "Desatualizado" ×4 — uma espera fixa teria entregue o cartão fresco como prova. As outras oito vieram em 7–9 s.
- `f5-semear.sh` (`dia`, `curto`, `vazio`), `f5-plantar.py` e `f5-instalar.sh` funcionaram à primeira. O cenário
  `curto` é o caminho real para o "Desatualizado.": três compromissos de um minuto e a face vence sozinha em ~4 min.
- **`orca emulator ax` recusou conexão** na casa (`ERR_CONNECTION_REFUSED`), como a memória da esteira já dizia.
  Alvos foram medidos por toque, não por árvore.
- **`orca emulator attach` é por worktree, não por aparelho.** Com o outro revisor no mesmo worktree, o aparelho
  "ativo" trocava de mãos e `tap --device <meu UDID>` falhava com "No active emulator for this worktree". Passei a
  reatar antes de cada toque. **Aviso honesto:** cada `attach` meu pode ter tirado o Air do outro revisor pelo mesmo
  mecanismo. Dois workers num worktree e um só emulador ativo é uma lei de instrumento a registrar.
- O pior caso não estava no acervo. As capturas da volta usam a frase de 43 caracteres; a ADR 08g chama isso de
  "o pior caso real". **Não é:** `VozDoAutor.titulo` publica a primeira linha da prosa sem teto e o campo "única" é
  texto livre. Semeei 103 e 247 caracteres — uma frase de duas orações e um parágrafo curto, os dois comuns num app
  de escrita.

---

## 1. MOVER

**Nota: 9.**

Nenhuma animação foi criada nesta volta e nenhuma existia: varredura em `TracoWidget/` por `animation`,
`withAnimation`, `transaction`, `contentTransition`, `reduceMotion` acha só o `contentTransition(.numericText())`
da hora do `BlocoProximo` e o `invalidatableContent` do feito, os dois da F4-E, nenhum tocado aqui.

**Reduzir Movimento, provado na tela:** liguei `ReduceMotionEnabled` (valor anterior 0, restaurado a 0), recapturei
o mesmo estado vazio e comparei pixel a pixel a área dos quatro cartões:

| par | pixels diferentes | de |
|---|---|---|
| `g4-f4f-vazio-normal.png` × `g4-f4f-vazio-reduzir-movimento.png` | 3 | 1 769 832 |

Nada se mexe sem propósito porque nada se mexe. É virtude por ausência, como na F4; conto como certo.

---

## 2. JULGAR — as três perguntas, na ordem pedida

### 2.1 O piso de 0,35 é honestidade ou letra de formiga? **É letra de formiga — e, no pior caso, ainda corta.**

Três estados, todos no teste 4, todos com este build, todos com o rodapé "Desatualizado." onde a pergunta o pede.

**(a) 43 caracteres, AX5** — o caso do acervo. `f5-antes-ax5-desatualizado.png` (main) × `f5-depois-desatualizado-ax5.png`.
A frase sai inteira e legível; a reticência morreu. Aqui a volta tem razão.

**(b) 103 caracteres, AX5, velho** — `g4-f4f-velho-ax5.png`, e o recorte lado a lado `g4-f4f-pequeno-normal-x-ax5.png`.
No pequeno a frase sai inteira em oito linhas. Medi o passo de linha nos pixels (3×):

| estado | passo de linha | equivale a |
|---|---|---|
| tamanho normal, 103 chars | ~39 px | corpo de ~11 pt |
| **AX5**, 103 chars | ~38 px | corpo de ~11 pt |
| AX5, "Dentista" ao lado (`Tema.meta`) | — | ~1,4× o normal |

Ou seja: **quem ligou o maior tamanho de acessibilidade lê a frase do autor no mesmo corpo de quem não ligou nada** —
o corpo que essa pessoa declarou, nos Ajustes, que não consegue ler. Tudo à volta cresceu; a única coisa que é dela
não. O círculo do feito tem três vezes a altura-x da frase que ele marca. Isso não é "letra pequena é só letra
pequena"; é a superfície fingindo que entregou a frase a quem não a alcança.

**(c) 247 caracteres, a primeira linha de uma nota sem quebra** — `g4-f4f-longa-normal.png` e `g4-f4f-longa-ax5.png`.
- Em tamanho **normal** o pequeno desenha **onze linhas a ~7 pt** e, embaixo, o atalho "Nova nota" a 12 pt — o
  acessório maior que o assunto. O médio faz o mesmo em quatro linhas a ~8 pt.
- Em **AX5** o pequeno termina em **"ainda me incomoda…"**. Reticências. **O defeito que abriu a volta reproduz
  neste build.** O piso de 0,35 não é um piso de honestidade: é o ponto em que o SwiftUI desiste de encolher e volta
  a cortar — só que agora corta uma frase que já estava ilegível.

A resposta à pergunta é dupla e a segunda metade decide: **a frase inteira em corpo minúsculo é pior** que a
cortada, porque a cortada anuncia que há mais e a minúscula anuncia que há tudo; **e o corte continua existindo**
para o texto que o app de fato publica. O defeito mudou de forma para o caso do acervo e não mudou para o caso real.

O que eu esperaria no lugar: um piso em pontos (a frase nunca menor que o rótulo "Desatualizado." ao lado dela), o
corte honesto acima do piso, e o pequeno abrindo mão do "Nova nota" decorativo antes de tocar no corpo da frase —
exatamente a lei que esta volta aplicou ao médio ("quem paga são os atalhos, que existem em todo lugar").

### 2.2 A troca do médio vale? **Vale.**

`f5-antes-inicio-claro.png` (main: cabeçalho com "Nova nota" e "Recordar", agenda em **zero** linhas, "3 compromissos
por vir") × `g4-f4f-dia-normal.png` (este build, 103 chars: marca, frase em três linhas, **duas linhas de agenda** com
hora e assunto, "+1 depois").

Pelos dois ciclos: os dois atalhos eram ação, mas ação que já existe no ícone, no controle Ditar, no toque do widget
pequeno inteiro e na cápsula do quadro vazio; a agenda é informação que **só existe ali** na tela de início, e é a
informação que faz a intenção virar ação sem abrir o app ("o dentista é às 13:04, então escrevo agora"). A face
continua dizendo o que não mostrou: "+1 depois" é um número que a superfície sabe (`alemDaLista`), e em AX5, onde
nenhuma linha cabe, cai em "3 compromissos por vir" (`g4-f4f-dia-ax5.png`) em vez de fingir agenda. Honesto.

Duas observações, não recusa:
- **"Recordar" sumiu da casa sem ninguém dizer.** O cabeçalho perdeu o atalho e a terceira oferta do `QuadroVazio`
  nunca é desenhada (`ofertas[1]` é a última que a linha mostra). O comentário do `pequeno` ainda afirma "Recordar
  continua encontrável no médio". Não continua. Dívida de rumo: o poder mudou de lugar para dentro do app, e o
  relato não conta.
- Em AX5 com a frase de 43 caracteres o médio deixa **um buraco de ~44 pt** entre a frase e o filete
  (`f5-depois-inicio-ax5-claro.png`, cartão do meio): o teto em pontos da frase reserva duas linhas de AX5 e a frase,
  encolhida, usa menos. Com 103 caracteres o buraco some (`g4-f4f-dia-ax5.png`). Não é o defeito nº 5, é respiro
  mal distribuído.

### 2.3 O quadro lê como oferta ou como Ajustes? **Como oferta.** E um toque faz uma coisa só.

`f5-antes-vazio-claro.png` (main: duas linhas iguais, glifo à esquerda, mesmo peso, esticadas em fatias) ×
`g4-f4f-vazio-normal.png` (frase de estado, **uma** cápsula âmbar, alternativa em texto discreto na mesma linha).
A forma resolveu o achado I: há uma ação de primeira classe e a segunda não disputa com ela. Em AX5 fica só a
cápsula (`g4-f4f-vazio-ax5.png`), sem texto cortado.

**Toques, pelo `orca emulator tap`, com o que abriu lido por OCR na captura do app:**

| toque | onde | abriu |
|---|---|---|
| cápsula "Nova nota" (médio do Traço) | centro | Notas, nota nova com Título/Seção/Lista — `g4-f4f-toque-capsula-nova-nota.png` |
| cápsula "Nova nota" | 20 pt abaixo do centro | a mesma nota nova — `g4-f4f-toque-capsula-borda-20pt.png` |
| alternativa "Marcar compromisso" | centro | calendário, 8 de setembro — `g4-f4f-toque-alternativa-marcar.png` |
| alternativa "Marcar compromisso" | 26 pt abaixo do centro | o mesmo calendário — `g4-f4f-toque-alternativa-borda-26pt.png` |
| cápsula "Marcar compromisso" (médio do Próximo) | centro | calendário — `g4-f4f-toque-proximo-capsula-marcar.png` |
| pequeno do Traço, qualquer ponto | centro | nota nova — `g4-f4f-toque-pequeno-inteiro.png` |

O alvo de 44 pt (achado G) está **provado por toque**, inclusive na alternativa sem moldura. A confirmação não é na
própria superfície — é `Link`, o app abre no lugar prometido — e para "Nova nota" isso é o certo: a ação é escrever,
e escrever não cabe num widget.

---

## 3. PORTÃO

**Tokens.** Tudo que é cor e fonte vem de `Tema`; `Tema.miudo` está no lugar que a ADR 05u reservou (fora do app).
Restam, no diff: `.background(.quaternary, in: Capsule())` (material do sistema, não token — `Tema.chip` existe),
`Tema.ambar.opacity(0.55)` (derivado), e os números soltos `16/9` (cápsula), `14/10` (quadro), `6/4/5` (respiros).
A cápsula é apresentada como "a mesma que o autor já toca na tela bloqueada" (`CapsulaLembrar`) — **não é**: lá
`18 pt` horizontal, altura `38`, tinta `Tema.ambar`; aqui `16/9` e `Tema.ambarTinta`. Duas cápsulas com o mesmo nome
e medidas diferentes é um token que falta. Não derruba sozinho; é a dívida de Componentes de sempre.

**Nada protegido exposto.** O widget lê só `Superficie`; a linha do Destaque é o que o autor escreveu no campo
"única" ou a primeira linha da prosa — nunca selo, expressiva ou Recordar. O diff não abre rota nova. Confirmado.

**As duas lacunas.** Ilha mínima: `minimal` desenha a mesma view de `compactLeading`, fotografada; aceito com a
lacuna dita. StandBy: limite do simulador, confirmado pelo G3. **"Fora do app" pode chegar a 9 com a lacuna dita**,
e o que fica por ver no aparelho real é uma coisa só e específica: **o cartão de papel (`Tema.fundo`, ~95% de
luminância) no StandBy noturno**, na mesa de cabeceira, em modo noite — é o pior caso da dívida "papel na parede
escura" que o G4 da F4 registrou, e o simulador não mostra. Ilha mínima com um segundo app vivo (um timer do
Relógio) é a outra foto, menor. **Nesta volta, porém, "Fora do app" não chega a 9 por outro motivo:** a superfície
afirma "a frase inteira, sempre" e no caso real não é inteira nem legível.

| dimensão | nota | por quê, em uma linha |
|---|---|---|
| **Design** | **7** | quadro e médio certos; a frase do autor a ~11 pt em AX5 e a ~7 pt no normal, abaixo de um atalho decorativo de 12 pt; reticências de volta com 247 chars |
| **Simplicidade** | **8** | médio e quadro reduzem passos sem esconder custo; "Recordar" saiu da casa sem ser dito |
| **Movimento** | **9** | nada se mexe; Reduzir Movimento idêntico ao pixel |
| **Componentes** | **8** | `FraseDoAutor` num lugar só, com leis testadas; segue no arquivo do widget sem preview, e a cápsula "a mesma" não é a mesma |
| **Fora do app** | **7** | toques provados, nada protegido, lacunas ditas — mas a promessa central da volta ("não termina em reticências") reproduz falsa neste build |

**Veredito: NÃO PASSA.** Mínimo da esteira é 9; Design e Fora do app ficam em 7.

---

## 4. Três linhas para o LACO

- A volta acertou o médio e o quadro: onde havia zero linhas de agenda há duas e um "+1 depois" verdadeiro, e o
  vazio deixou de parecer Ajustes — uma cápsula, uma alternativa, seis toques provados abrindo exatamente o que
  prometem, com 44 pt de alvo medidos pelo dedo.
- O G4 recusa pela frase: o piso de 0,35 entrega ao leitor de AX5 a frase do autor no mesmo corpo de ~11 pt de quem
  não ligou acessibilidade, e com a primeira linha de uma nota (247 caracteres) o pequeno desenha onze linhas a
  ~7 pt no normal e **volta a terminar em reticências** em AX5 — o "pior caso real" da ADR (43 chars) não é o pior
  caso que o app publica.
- `f5-fotografar.sh` esperou 81 s pelo OCR ler "Desatualizado" ×4 antes de dar a captura por boa — a espera fixa
  teria entregue o cartão fresco como prova; e `orca emulator attach` é por worktree, então dois revisores no mesmo
  worktree roubam o emulador um do outro a cada `attach`.

---

### Capturas (todas minhas, iPhone 17 Pro teste 4, build deste worktree, 08/09 12:20–12:33)

| arquivo | estado |
|---|---|
| `g4-f4f-dia-normal.png` / `g4-f4f-dia-ax5.png` | 103 chars, três compromissos, fresco; normal e AX5 |
| `g4-f4f-velho-normal.png` / `g4-f4f-velho-ax5.png` / `g4-f4f-velho-ax5-escuro.png` | 103 chars com "Desatualizado."; normal, AX5 claro, AX5 escuro |
| `g4-f4f-pequeno-normal-x-ax5.png` | recorte lado a lado do pequeno: normal × AX5, mesma frase |
| `g4-f4f-longa-normal.png` / `g4-f4f-longa-ax5.png` | 247 chars: letra de formiga no normal, **reticências** em AX5 |
| `g4-f4f-vazio-normal.png` / `g4-f4f-vazio-ax5.png` | quadro de ofertas, normal e AX5 |
| `g4-f4f-vazio-reduzir-movimento.png` | o mesmo com Reduzir Movimento ligado |
| `g4-f4f-toque-*.png` | o app aberto por cada toque da tabela em 2.3 |
| `g4-f4f-casa-restaurada.png` | a casa devolvida ao IconState original |

---

# re-G4 da volta F4-F (terceira tentativa, F4-H) — **PASSA.** Os dois fatos que derrubaram a volta caíram na tela: em AX5 a frase do autor cresce com a categoria (passo de linha 20 → 27 pt), e com 247 caracteres nenhuma face desenha letra de formiga nem corte que engana — o publicador declara o trecho, a face corta o que sobra com "…" e o toque abre a nota certa.

**Papel:** julgar do design (`design-router`: Mover, Julgar, Portão), sessão própria, sem tocar em código.
**Worktree:** `volta-f5-fora-do-app`, topo `d1d7301`. **Contrato julgado:** a ADR 08i e a decisão de sete pontos (SPEC.md), lidas com o parecer do conselho (`consulta-f4f-corte-honesto.md`, no checkout `main`) — julguei contra o contrato novo, não contra a 08g.
**Aparelho:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, ligado por mim às 13:44 e devolvido desligado às 14:02, casa restaurada do `IconState.plist.bak-f5` (`reg4-f4f-casa-restaurada.png`), claro, `large`.
**Build:** `xcodebuild build -scheme Traco -destination id=A1DF082C…` por `com-trava.sh` (sucesso, `-quiet` sem saída), instalado por `f5-instalar.sh` e conferido por símbolo `Sacrificio CapsulaViva destaqueQueCabe`.
**Instrumento:** nenhum toque no mouse do dono. Plantio por `f5-plantar.py`; estado por `f5-semear.sh` (com `ID=` da nota real); toda captura de casa por `f5-fotografar.sh` (só dada por boa com o OCR lendo o texto, 7–8 s cada; **uma recusou** de propósito — ver 0); toques, trancar e destrancar por `orca emulator` sob `com-trava.sh`, **reatando antes de cada comando** (o `attach` não sobrevive ao SpringBoard renascer). `orca emulator ax` recusou de novo (`ERR_CONNECTION_REFUSED`).
**Frases:** as MESMAS do G4 de 12:33, recuperadas por OCR das minhas capturas — 103 (`…na segunda-feira`) e 247 (`…naquela cena do jantar`) — e a do acervo (43).

## 0. Instrumento — o que serviu nesta volta

- `f5-fotografar.sh` recusou uma captura (90 s, `'terminar o' ×0`) e tinha razão: o app tinha relançado com a nota do Destaque selada e **tirou o Destaque da superfície** — a casa mostrava o Próximo no lugar. A recusa virou a prova de privacidade da seção 2.3.
- `f5-semear.sh` com `ID=` funciona; para criar a nota real usei `simctl openurl traco://anotar?texto=…` com o app aberto, e o id vem do `Documents/notas/<uuid>.md` que o app exporta. O banco SwiftData mora no **App Group** (`…/AppGroup/…/Library/Application Support/default.store`), não no contêiner do app; `ZUUID` é blob — `hex(ZUUID)`.
- Selar por fora: `update ZNOTA set ZTRANCADA=1` com o app morto. A primeira tentativa abriu o Calendário com pedido de permissão por cima e escondeu o toast; a segunda, com a casa recém-nascida (`f5-fotografar.sh` antes do toque), mostrou o recado.
- Enviei `traco://anotar` duas vezes por engano de shell: duas notas iguais no teste 4. Instrumento meu, não o app.

## 1. MOVER

**Nota: 9.** O diff de `TracoWidget/` entre `0beddcb` e `d1d7301` tem **zero** ocorrências de `animation`, `withAnimation`, `transition`; `ViewThatFits` não anima a escolha do candidato. Nada novo se mexe, e a comparação pixel a pixel do G4 (3 pixels em 1 769 832 com Reduzir Movimento) continua valendo porque a face é a mesma classe de coisa: estática.

## 2. JULGAR — as sete perguntas

### 2.1 Os meus dois fatos, refeitos

**Fato 1 — 103 caracteres em AX5: o corpo cresce.** Medido por projeção de tinta no pequeno (`linhas.py`, 3×):

| estado | passo de linha | altura da banda de minúsculas | corpo |
|---|---|---|---|
| normal, 103 (`reg4-f4f-103-fresca-normal.png`) | 60 px = **20 pt** | 39 px | 17 pt |
| **AX5**, 103 (`reg4-f4f-103-fresca-ax5.png`) | 80–82 px = **27 pt** | 52 px | **~23 pt** (1,33×) |
| G4 de 12:33, AX5, 103 (`g4-f4f-velho-ax5.png`) | 36–39 px = 12–13 pt | 23 px | ~11 pt |

A pessoa que pediu AX5 lê a frase do autor 1,33× maior que quem não pediu (o widget na casa escala ~1,4× no máximo — a "Dentista" ao lado cresce o mesmo tanto). A única coisa que era dela agora cresce com ela. **O fato 1 caiu.**

**Fato 2 — 247 caracteres, com e sem "Desatualizado.":** o publicador escreveu `superficie.json` com **135 grafemas** em fronteira de palavra (`…e se não der tempo pelo menos…`, `inteira: false`), e a face cortou de novo o que não coube, em corpo cheio:

| face | normal claro | normal escuro | AX5 claro | AX5 escuro |
|---|---|---|---|---|
| pequeno fresco | 5 linhas a 17 pt, `para man…` (`reg4-f4f-247-fresca-normal.png`) | — | 3 linhas a ~23 pt, `meio antes…` (`…-fresca-ax5.png`) | — |
| pequeno velho | 4 linhas + **Desatualizado.** (`…-velha-normal.png`) | idem (`…-velha-escuro.png`) | 2 linhas + Desatualizado. (`…-velha-ax5.png`) | idem (`…-velha-ax5-escuro.png`) |
| médio fresco | 2 linhas + agenda de 2 + "+1 depois" | — | 2 linhas + "3 compromissos por vir" | — |
| médio velho | **4 linhas** + Desatualizado., sem buraco | idem | 3 linhas + Desatualizado. | idem |
| tela bloqueada | 2 linhas, `promes…` (`reg4-f4f-bloqueada-247.png`) | | | |
| Ilha compacta | `terminar o ca…` | | `terminar o ca…` | |

Nenhuma letra de formiga (o menor corpo de frase em qualquer face é 17 pt), nenhuma face afirma inteireza, e o mesmo trecho de 135 sai no widget, na bloqueada e na Ilha. **O fato 2 caiu.** O que era onze linhas a ~7 pt virou cinco a 17; o que era "…" sobre texto ilegível virou "…" sobre texto do corpo do papel.

### 2.2 A regra, aplicada como teste, face a face

*"Reticência é honestidade quando indica continuação realmente omitida por um limite público declarado ou pelo espaço restante depois de retirar o dispensável, preservando leitura no tamanho escolhido e acesso ao original; é falha quando encobre corte evitável, texto ilegível ou uma promessa de integralidade."*

| face | omissão real? | dispensável retirado antes? | legível no tamanho escolhido? | acesso ao original? | veredito |
|---|---|---|---|---|---|
| pequeno fresco, 103/247, normal | sim (6ª linha não cabe: sobram ~14 pt sob a 5ª) | sim — "Abrir a nota" some | 17 pt | toque abre a nota | honesta |
| pequeno fresco, AX5 | sim | sim | ~23 pt | idem | honesta |
| pequeno velho, normal | sim | rótulo já cedeu ao rodapé | 17 pt | idem | honesta, com um resto: **~26 pt** livres entre a 4ª linha e o rodapé (a 5ª pediria ~24 + 4 de respiro e não coube por ~2 pt) — resto de divisão inteira, não meio cartão vazio |
| médio velho, normal | sim | (nada a retirar) | 17 pt | idem | honesta — e fechou o corte evitável da F4-F (2 linhas + 3 vazias) |
| médio fresco, AX5 | sim | agenda vira "3 compromissos por vir" | ~23 pt | idem | honesta |
| tela bloqueada | sim (135 → 2 linhas) | — | `Tema.meta` do sistema | atividade abre o app | honesta |
| Ilha compacta | sim (96 pt) | — | `Tema.miudo` | idem | honesta |
| publicador (135 de 247) | sim, e **declarada** (`inteira: false`) | — | — | o estado guarda os 247 | honesta |

**A frase se sustenta como lei?** Sustenta, e é melhor do que a que substituiu: ela transforma "reticência" de sintoma em pergunta de quatro partes que qualquer face responde com uma captura e um número. O ponto onde ela pode abrir porta para corte fácil é o segundo membro — *"espaço restante depois de retirar o dispensável"* — porque "dispensável" é classificação por face, e quem quiser cortar cedo pode classificar pouco. A ADR fecha essa porta para o Destaque (a lista do que está acima da disputa está escrita e tem suíte), mas para a PRÓXIMA face é preciso que "corte evitável" tenha um critério medível, e proponho o que usei nesta tabela: **é evitável quando cabe uma linha inteira do corpo do papel no espaço livre ao lado do marcador.** Com esse critério a regra é teste; sem ele é opinião.

Duas observações de forma, nenhuma derruba:
- O publicador corta em fronteira de palavra; a face corta onde o SwiftUI cortar (`para man…`, `promess…`, `que fi…`). São **duas gramáticas para o mesmo marcador**. Não engana (a omissão é reconhecível), mas a ADR só descreve a primeira. Dívida de Componentes, a registrar.
- Em AX5 no pequeno o rodapé "Desatualizado." cresce **1,2×** (banda de 20 → 24 px) enquanto a frase cresce 1,33× — é o `Encolhe.rotulo` de 0,6 da F4 fazendo 14 letras caberem em 123 pt. Nunca some (lei cumprida), mas é o rótulo de estado crescendo menos que tudo. Fora do diff desta volta; o remédio é o da própria ADR — palavra mais curta.

### 2.3 A promessa agora é verdadeira? **É — e o selo segura.**

- Nota real criada por `traco://anotar` (id `0031251F-4209-407A-AF8B-1496E39A3E16`), Destaque semeado com esse id, casa recém-nascida, `orca emulator tap 0.27 0.20`: o app abriu **"A nota real do re-G4 da F4-F"** com o cursor na página (`reg4-f4f-toque-pequeno-abre-a-nota.png`, OCR).
- Mesma nota **selada por fora** (`ZTRANCADA=1` com o app morto), mesmo toque: página em branco com o recado **"Essa nota não está disponível."** (`reg4-f4f-toque-nota-selada.png`, 1 s e 2 s). Nada da nota apareceu.
- Mais forte que a rota: quando o app relançou com a nota selada, `superficie.json` saiu **sem Destaque** (`destaque: null`) e o pequeno passou a mostrar o Próximo com "Calendário" — a frase de uma nota protegida deixa a superfície na publicação seguinte. Foi o que fez o `f5-fotografar.sh` recusar a captura.
- O `widgetURL` no estado velho continua `traco://nota/<id>` (o rótulo cede ao rodapé, o destino não muda) — coerente com a ADR: abrir o app é o que republica.

### 2.4 A ordem de sacrifício, na tela

| estado | o que a tela mostra | lei |
|---|---|---|
| pequeno fresco, 43 chars, normal (`reg4-f4f-43-fresca-normal.png`) | frase inteira em 4 linhas **e** "Abrir a nota" | o rótulo entra porque não custa linha |
| pequeno fresco, 103/247, normal | 5 linhas, **sem** rótulo | o rótulo cedeu antes da 5ª linha |
| pequeno fresco, 43, AX5 (`…-43-fresca-ax5.png`) | 3 linhas + "…", sem rótulo | idem, em AX |
| pequeno velho, todos | frase + **"Desatualizado."**, sem rótulo | o rodapé nunca cede |
| vazio, normal (`reg4-f4f-vazio-normal.png`) | "Nada em destaque hoje." + **Nova nota** (pequeno); cápsula **Nova nota** + Marcar compromisso (médio) | oferta principal, não cede |
| vazio, AX5 (`…-vazio-ax5.png`) | **Nova nota** no pequeno e na cápsula do médio; a alternativa cedeu | a oferta principal fica, a secundária cede |

Confirmado: o mesmo rótulo tem duas funções e a tela distingue as duas.

### 2.5 VoiceOver anuncia trecho

**Não ouvi no aparelho:** `orca emulator ax` recusa conexão na casa (mesma lei do G3 e do G4). O que confiro: `BotaoFeito` rotula com `destaque.emVoz` (`TracoWidget.swift`), a Live Activity idem nas duas faces, e `emVoz` só prefixa "Trecho: … Continua no Traço." quando `inteira == false` (`TrechoPublicoTests.emVoz`, `documentoAntigoNaoSabe`). Quando a projeção é inteira e só a FACE cortou (103 em AX5, `meio antes…`), o VoiceOver lê a linha de 103 inteira sem prefixo — que é a verdade: quem ouve recebe mais que quem vê, e ninguém ouve "texto completo". Aceito com a lacuna dita: **VoiceOver ouvido é item do aparelho real.**

### 2.6 As lacunas declaradas

StandBy e Ilha mínima seguem sem captura pelo limite do simulador que confirmei no G3. **"Fora do app" pode chegar a 9 com a lacuna dita.** O que fica por ver no aparelho real, exatamente:
1. o cartão de papel (`Tema.fundo`) no **StandBy noturno** — a dívida "papel na parede escura" da L2;
2. a **Ilha mínima** com um segundo app vivo;
3. **VoiceOver ouvido** no pequeno com trecho e com a projeção inteira cortada pela face;
4. a **Ilha compacta com duas atividades em AX5**: num quadro (`reg4-f4f-247-fresca-ax5.png`, 13:47:09, Próximo e Destaque vivos ao mesmo tempo) o trecho saiu `erminar o ca…`, com o "t" cortado à esquerda; em cinco outros quadros saiu inteiro. Um quadro não é achado; é o que olhar primeiro no aparelho.

### 2.7 Os limites que ele mesmo declarou

- *"A suíte não renderiza layout; a ordem é dado com teste e a prova visual é a captura."* **Aceitável** — e é o desenho certo: `Sacrificio.candidatos` tem suíte (`SacrificioTests`), e a tabela 2.4 é a prova visual, com o caso de fronteira (43 com rótulo, 103 sem) fotografado. O que a suíte não pode dizer, a captura disse.
- *"Em AX o SwiftUI pode partir palavra em sílaba acima de ~10 letras a 24 pt em 123 pt."* **Aceitável.** Nas minhas seis capturas de AX5 do pequeno não houve hífen; o único `segunda-/feira` é o hífen do autor no médio normal. É quebra tipográfica declarada, não corte, e a subida do círculo tirou o caso de 90 pt. Se aparecer numa palavra real, a lei "corte é só o '…'" continua verdadeira.

## 3. PORTÃO

**Tokens.** `CapsulaViva` fechou a dívida "a mesma cápsula" (18/38 na casa e na bloqueada, 14/32 na Ilha, tinta de quem veste). Restam como estavam: `.background(.quaternary, in: Capsule())` (material, não token) e `Tema.ambar.opacity(0.55)` (derivado). Números novos: `spacing: 4` do candidato e `maxWidth: 96` da Ilha — respiros, não tokens.

**Nada protegido exposto.** Provado três vezes nesta volta: rota revalida selo (toast), publicador tira o Destaque da nota selada (`destaque: null`), e o estado guarda o texto inteiro enquanto só a projeção corta (135 no arquivo, 247 no plist).

**Pares antes/depois, por arquivo**

| arquivo | antes (0beddcb, G4 de 12:33) | depois (d1d7301, re-G4) |
|---|---|---|
| `SuperficieFora.swift` | `linha` sem teto; nenhum metadado de integridade | `teto = 140` grafemas, `trecho()` em fronteira de palavra, `inteira: Bool?` → `integridade`, `emVoz` |
| `DestaqueDoDia.swift` | `projecao` publica a linha inteira; `reconciliar` monta o `ContentState` à parte | `projecao` corta uma vez; `estadoVivo` nasce dela — widget, bloqueada e Ilha com o mesmo trecho (visto: 135 nos três) |
| `TracoWidget.swift` — `FraseDoAutor` | `minimumScaleFactor(0.35)`, sem teto de linhas: ~11 pt em AX5, ~7 pt com 247 | `ViewThatFits` sobre `lineLimit(n)` no corpo cheio: 17 pt normal, ~23 pt AX5, "…" no que sobra |
| `TracoWidget.swift` — `pequeno` | rótulo "Nova nota" fixo abaixo da frase, mesmo com a frase a 7 pt | `destaqueQueCabe`: rótulo só quando não custa linha (43 sim, 103 não) |
| `TracoWidget.swift` — `destino` | com Destaque, `traco://nova` ("Nova nota") | `traco://nota/<id>` ("Abrir a nota"); provado com nota real e com nota selada |
| `TracoWidget.swift` — quadros | terceira oferta "Recordar" nunca desenhada | duas ofertas; ADR diz onde "Recordar" continua |
| `TracoWidget.swift` — cápsulas | 16/9 na casa × 18/38 na bloqueada | `CapsulaViva` única |
| `Relogio.swift` | `Encolhe.frase = 0.35`; `noMedio(rodape:comAgenda:)` → 2 com rodapé (3 linhas vazias) | `Encolhe` só de rótulo; `Sacrificio` com suíte; `noMedio(comAgenda:)` → o layout decide (4 linhas + rodapé, sem buraco) |
| `Intencoes.swift` | sem rota `nota` | `traco://nota/<uuid>` → `Destino.nota`, a `PaginaView` revalida `fechada`/`expressiva` |
| `Atividades.swift` | `ContentState.linha` | `+ inteira: Bool?` — a Ilha sabe que é trecho |

| dimensão | nota | por quê, em uma linha |
|---|---|---|
| **Design** | **9** | corpo do papel em toda categoria, medido; corte só onde não cabe; buraco do médio fechado; rótulo cede antes da frase |
| **Simplicidade** | **9** | um toque, um destino que agora corresponde ao que a face mostra; "Recordar" dito |
| **Movimento** | **9** | nada se mexe; diff sem animação |
| **Componentes** | **8** | `CapsulaViva` e `Sacrificio` com suíte; segue sem preview e com duas gramáticas de "…" (publicador × face) |
| **Fora do app** | **9 com lacuna dita** | widget, bloqueada e Ilha com um contrato (135 nos três); toque e selo provados; StandBy, Ilha mínima, VoiceOver ouvido e a Ilha com duas atividades em AX5 ficam para o aparelho |

**Veredito: PASSA.** Mínimo da esteira é 9; Componentes fica em 8 pela mesma dívida antiga (sem preview) mais uma nova e pequena (duas gramáticas do marcador), nenhuma das duas de tela.

## 4. Três linhas para o LACO

- A volta consertou o que eu recusei, do jeito que o conselho pediu e não do jeito fácil: o teto virou dado público na projeção (um lugar, três superfícies), a frase deixou de encolher e passou a ceder quantidade, e o toque passou a abrir a nota — provado com nota real e com nota selada.
- A regra do corte honesto serve como lei, com um critério que proponho escrever: corte é evitável quando cabe uma linha inteira do corpo do papel no espaço livre ao lado do "…". Sem número, "evitável" vira opinião na próxima face.
- Instrumento: `f5-fotografar.sh` recusou uma captura e a recusa era a prova (a nota selada tinha saído da superfície); o `attach` do `orca emulator` morre com o SpringBoard — reatar antes de cada comando; o banco do app mora no App Group e `ZUUID` é blob.

### Capturas (todas minhas, iPhone 17 Pro teste 4, build `d1d7301`, 08/09 13:45–14:01)

| arquivo | estado |
|---|---|
| `reg4-f4f-103-fresca-normal.png` / `-ax5.png` | 103 chars, fresco, normal e AX5 — o fato 1 |
| `reg4-f4f-247-fresca-normal.png` / `-ax5.png` | 247 chars, fresco (publicador em 135) |
| `reg4-f4f-247-velha-normal.png` / `-escuro.png` / `-ax5.png` / `-ax5-escuro.png` | 247 chars com "Desatualizado.", quatro combinações — o fato 2 |
| `reg4-f4f-43-fresca-normal.png` / `-ax5.png` | 43 chars da nota real: rótulo "Abrir a nota" entra (normal) e cede (AX5) |
| `reg4-f4f-toque-pequeno-abre-a-nota.png` | o toque no pequeno abre "A nota real do re-G4 da F4-F" |
| `reg4-f4f-toque-nota-selada.png` / `-2s.png` | a mesma nota selada: "Essa nota não está disponível." |
| `reg4-f4f-vazio-normal.png` / `-ax5.png` | quadro de ofertas: "Nova nota" principal, não cede |
| `reg4-f4f-bloqueada-247.png` | tela bloqueada, Live Activity com o trecho de 135 em 2 linhas |
| `reg4-f4f-casa-restaurada.png` | a casa devolvida ao IconState original |
