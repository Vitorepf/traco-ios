# G4 da volta L2 — latência da descoberta. Julgar do design.

**PASSA — Design 9, Simplicidade 8 (teto honesto desta tela, lacuna medida e nomeada abaixo), Movimento 9, Componentes 9. A compactação dos registros fica RECUSADA.**

Juiz de design (Fable 5.1), sessão própria. Topo julgado: `a4b13a0`, worktree
`volta-l2-latencia-g4`. Meu simulador: iPhone 17 Pro `C2416CBC-C5D9-41F9-ACD8-45EED8FC355E`
(402 × 874 pt), o único em que instalei e o único que toquei. Não editei código,
não commitei nada: só este relatório, as capturas `g4-l2-*.png` e três árvores
`g4-l2-ax-*.json` em `ferramentas/orca/`.

Skills carregadas antes de olhar a tela: `design-router` — fases **Mover**,
**Julgar** e **Portão**, as três do meu papel. Rota: auditoria — inspecionar e
relatar, não editar.

**O aparelho, como o encontrei e como o deixo.** Perfil em **"sem conta — recursos
locais disponíveis; exercício e revisão por IA precisam do Grok."** — está na
árvore de acessibilidade de todo estado que li (`g4-l2-ax-a-large.json`,
`g4-l2-ax-b-large.json`, `g4-l2-ax-b-ax5.json`, elemento `estado-conta`). Não
abri o Safari, não limpei aba, não desliguei o aparelho, não toquei em login.
Letra `large` e aparência `light` antes; `large` e `light` depois (eco do
`simctl ui` às 13:40).

---

## O binário é o do commit

Build meu, sob `com-trava.sh`, `-destination id=C2416CBC…`, DerivedData próprio
no scratch (dylib de 13:20). `simctl uninstall` antes do `install`. Conferido por
string no dylib instalado: "Sai das hip" = 1, "nos 12 " = 1, "1 descoberta · levou"
= 1, "Sai do que j" = 0. O Swift de `a4b13a0` é o de `9bea1b8` (diff zero), e as
minhas medidas batem com as da L2-B ao ponto:

| estado | `large` (o do aparelho) | AX5 | L2-B disse |
|---|---|---|---|
| MODO A | **886 pt** (1,30 telas de 682) | não medi | 886 / 5.541 |
| MODO B | **1.025 pt** (1,50 telas) | **6.115 pt** (8,97 telas) | 1.025 / 6.115 |

Medida pela árvore, do rótulo "LATÊNCIA DA DESCOBERTA" ao rótulo "MÉTODOS", como
a L2-B. O número da L2-B está certo; a foto agora também.

**Antes e depois, por arquivo.** O "antes" é o binário da L1 mesclada
(`8e3a1a5`, capturas `l2-antes-*.png` da própria L2, cuja copy "Sai do que já
está escrito…" é a de `main:PerfilView.swift:227`, conferido por `git show`). O
"depois" é meu:

| par | antes | depois (meu, `a4b13a0`) | o que muda |
|---|---|---|---|
| MODO A, `large` | `l2-antes-cartao.png` / `l2-antes-registros.png` | `g4-l2-a-large-secao.png` / `g4-l2-a-large-fim.png` | a medida sobe de 12 para 15 pt e passa a ser a linha mais escura do registro; a manchete vira duas linhas |
| MODO B, `large` | `l2-antes-modo-b.png` / `-registros.png` | `g4-l2-b-large-secao.png` / `g4-l2-b-large-fim.png` | "18 em aberto" desce para a segunda linha; "agosto de 2026 · 1 descoberta · levou 5 dias" |
| MODO B, AX5 (o cruzamento que faltava) | não havia | `g4-l2-b-ax5-cabecalho.png`, `-resumo.png`, `-meses.png`, `-registros.png`, `-fim.png` | ver Julgar |
| aparência escura do sistema | não havia | `g4-l2-a-large-sistema-escuro.png`, `g4-l2-b-ax5-registros-sistema-escuro.png` | ver Julgar: o app não tem modo escuro |
| vinte meses / teto de doze | `l2-antes-teto-12-meses.png` | `l2-depois-teto-12-meses.png` (L2-B) | **não reproduzi**: o script de vinte meses é do scratch da L2-B; cito a captura dela, cujo binário ela conferiu por string, e confiro o teto no código (`suffix(12)`) e a copy na minha tela |

---

## A decisão que me pediram: a compactação dos registros

**Recuso. Concordo com a inclinação do orquestrador, e o motivo é mais forte do
que "3%".** Olhei os dois pares lado a lado como o autor olharia
(`l2-depois-modo-a-fim.png` × `l2-alternativa-inline-large-fim.png`;
`l2-depois-modo-a-ax5-registros.png` × `l2-alternativa-inline-ax5-registros.png`):

1. **Em `large` ela destrói a coluna que faz a lista ser varrível.** Na forma em
   duas linhas, a margem esquerda é uma coluna só de medidas: "devido · em aberto
   há 19 dias", "afirmado · em aberto há 6 dias", "descoberto · levou 2 dias"…
   O olho desce a margem e lê a série. No fluxo só, a margem esquerda vira uma
   mistura de medidas e de **restos de hipótese** ("alta expõe o que eu pulo",
   "professor", "rende mais", "minutos por dia para avançar") — metade das
   linhas que começam na margem não são medida nenhuma. É exatamente a
   varredura que a seção existe para dar, trocada por 36 pt.
2. **A linha de dois corpos quebra no meio da hipótese** ("conferir em 5 de /
   set. de 2026 — publicar o vídeo…"): o travessão e a troca de tamanho caem em
   posições arbitrárias, e a hipótese perde o início próprio. Isso é acabamento
   pior comprando fluxo pior, e o portão recusa acabamento que compensa fluxo.
3. **Em AX5 o ganho é de sobra de linha, não de forma.** Cada registro embrulha
   em quatro a seis linhas nas duas formas; os 180 pt são as linhas em que a
   medida terminava curta. E a altura mora onde a L2-B mediu: parágrafo de
   abertura **833 pt** (1,2 telas sozinho) e vinte registros de 171 a 449 pt cada
   (`g4-l2-ax-b-ax5.json`). Compactar o arranjo dos detalhes é mexer no lugar
   errado.

Se um dia alguém quiser mesmo recuperar altura em AX5, a alavanca honesta está
no parágrafo (37 palavras explicando antes de mostrar, em todo estado, para
sempre) e no número de registros — decisões da volta do Perfil, não desta.

## A pergunta que decide o portão: 8 é o teto honesto de Simplicidade?

**É — mas não pelo motivo que a pergunta traz, e isso importa para o RUMO.**

A extração dos nove cartões inline do `PerfilView` (983 linhas hoje) **não muda
um pixel**: é dívida de Complexidade e de Componentes, não de Simplicidade. Fazer
a extração amanhã deixaria o autor com a mesma tela de hoje, e a nota de
Simplicidade teria de ser a mesma. Se a extração for o topo da fila do Perfil,
que seja pelo que ela é — a pior tela do produto em linhas — e não como caminho
para o 9 desta seção.

O que trava a Simplicidade em 8 é o que o autor vê: um cartão de leitura de 1,3
a 1,5 telas em `large` (886 / 1.025 pt de um Perfil com ~4.400 pt de conteúdo,
cerca de um quinto da tela inteira) e de 8 a 9 telas em AX5, dentro do Perfil que
já era o mais longo. Em AX5 o parágrafo sozinho é 1,2 telas, a manchete mais a
composição são 544 pt, e vinte registros são 5.700 pt. Nenhum degrau tipográfico,
nenhum arranjo de detalhes e nenhuma extração de arquivo mexe nisso. O que mexe é
uma decisão sobre **o que o Perfil mostra por padrão** — por exemplo, a seção
mostrar manchete e meses e guardar os registros atrás de uma dobra, ou o parágrafo
encolher para a frase que nomeia a capacidade e mandar o "de onde sai / o que
fazer" para o estado vazio, onde ele é necessário. As duas são decisões da volta
do Perfil: a primeira cria um alvo numa seção que a L1 decidiu manter sem toque,
a segunda mexe na copy que o G4 da L1 elogiou como a que cumpre o contrato. Não
cabe decidir nenhuma das duas no portão de uma volta de correção.

**Caminho para 9 nesta volta: não há.** O único gesto que valeria nesta volta —
tirar do parágrafo a frase "Sai das hipóteses do Trabalho e das decisões com
data de conferir — nada a preencher aqui" e deixá-la só no vazio — recupera mais
do que a compactação (~330 pt em AX5, sem tocar em registro) e ainda deixa o
cartão em 8+ telas. Vale fazer na volta do Perfil; não compra o 9 sozinho.

**Então: mescla com 8, a lacuna nomeada assim** — *o cartão da latência é um
quinto do Perfil em `large` e nove telas em AX5; a altura mora no parágrafo e na
contagem de registros, e só uma decisão sobre o que o Perfil mostra por padrão a
muda.* Prefiro este 8 provado ao 9 que a compactação compraria piorando o tamanho
em que o dono lê.

---

## 1. JULGAR — como o autor olharia

### A pergunta central continua respondida? Sim.

Procurei o placar disfarçado nas minhas capturas, estado por estado:

| o que procurei | MODO A `large` | MODO B `large` e AX5 |
|---|---|---|
| número solto no topo | não: a manchete é uma frase em `Tema.chrome` ("7 descobertas com as duas datas · a do meio levou 9 dias") | não ("4 descobertas … a do meio levou 13 dias") |
| ordem que pareça ranking | meses em ordem do tempo, registros por estado e depois por data | idem |
| meta / sequência / % / streak | nenhuma palavra dessas na árvore inteira | nenhuma |
| cor de bom e ruim | os quatro estados no mesmo `tintaSuave`, a hipótese em `tintaFraca` | idem, em AX5 também |
| alvo / ação | nada tocável na seção (árvore: só `text`) | idem |

**O "18" saiu da manchete** e é isso que o G4 da L1 pediu
(`g4-l2-b-large-secao.png`): "4 descobertas com as duas datas · a do meio levou
13 dias" em cima, e "2 sem a data da descoberta · 18 em aberto · 2 abandonadas"
embaixo, um degrau menor e um cinza mais quieto. Nenhum número saiu. Em AX5
(`g4-l2-b-ax5-resumo.png`) a segunda linha vira quatro linhas e o "18" ainda pega
o olho por ser o maior número da tela — mas pega como composição, não como
manchete; aceito.

### As quatro correções, na tela

1. **Teto de doze com o horizonte na copy** — "O tempo do meio entre as
   descobertas de cada mês, nos 12 últimos." está na tela (`g4-l2-a-large-secao.png`)
   e o `suffix(12)` no código. Doze de vinte impressos: cito
   `l2-depois-teto-12-meses.png` da L2-B, não reproduzi.
   *Um reparo de copy, não de portão:* `s.meses` só contém meses **com**
   descoberta (`Latencia.swift:181`), então os "12 últimos" são os doze últimos
   meses com descobertas, que no aparelho do dono podem recuar mais de doze meses
   de calendário. A frase deixa o leitor entender "últimos 12 meses". Os nomes
   dos meses em cada linha desarmam a leitura errada, então não é estado
   desonesto — mas a copy intermediária ("nos últimos 12 meses com descobertas")
   era mais exata e foi encurtada. Três palavras, para a FILA.
2. **`Tema.miudo` fora do app** — `grep -rn "Tema.miudo" Traco/` devolve nada. A
   medida está em `Tema.meta` + `tintaSuave` e a hipótese em `.footnote` +
   `tintaFraca`, e agora **há hierarquia em `large`** (`g4-l2-a-large-fim.png`):
   a linha da medida é maior e mais escura, a hipótese recua. Era o defeito (b)
   da L1 e está resolvido. Em AX5 o par continua separado
   (`g4-l2-b-ax5-registros.png`).
3. **Frase-resumo em duas linhas sem perder número** — conferido nos dois modos;
   as duas leituras vêm da mesma `emPalavras`.
4. **`quantas == 1`** — "agosto de 2026 · 1 descoberta · levou 5 dias" e
   "setembro de 2026 · 1 descoberta · levou 2 dias" no MODO B
   (`g4-l2-b-large-secao.png`). Nada é chamado de "tempo do meio" com um valor só.

### O que ficou por medir no G4 anterior

- **Modo escuro: não se aplica, por decisão do produto.** `RaizView.swift:142`
  força `.preferredColorScheme(.light)` (e o Calendário repete). Com o aparelho
  em `dark`, a seção sai idêntica e clara (`g4-l2-a-large-sistema-escuro.png`,
  `g4-l2-b-ax5-registros-sistema-escuro.png`). A pergunta da L1 sobre os dois
  cinzas no escuro fica sem objeto. Se o Traço um dia ganhar modo escuro, é volta
  própria e os cinzas entram nela.
- **MODO B × AX5 — o pior caso real, agora visto.** 6.115 pt, 8,97 telas
  (`g4-l2-ax-b-ax5.json`). Nada trunca, nada clipa, nada transborda na
  horizontal (o transbordo do RUMO **não** reproduziu nesta sessão, em nenhuma
  das cinco capturas AX5). O rótulo "LATÊNCIA DA DESCOBERTA" quebra em duas linhas
  em AX5 (`g4-l2-b-ax5-cabecalho.png`), como o de qualquer cartão do Perfil. A
  medida e a hipótese continuam em dois degraus legíveis. O custo é o que a nota
  de Simplicidade já cobra: nove telas de rolagem.
- **VoiceOver: não ouvi, e digo por quê.** Ligar o VoiceOver no simulador pede
  `defaults write` no domínio de acessibilidade **mais desligar e ligar o
  aparelho**, e este aparelho não pode ser desligado (guarda a evidência do
  incidente). O Accessibility Inspector do Mac é mouse, proibido. O que a árvore
  prova — e é o que o VoiceOver lê: cada registro é **um** elemento com a medida
  primeiro e a hipótese depois, separadas por vírgula ("afirmado · em aberto há
  121 dias · autoria desconhecida, registro antigo: propostaPor AUSENTE"); cada
  mês é um elemento; rótulo, parágrafo, manchete, composição e legenda são
  elementos separados na ordem visual; nada é focável como ação. A ordem é a
  certa. **O que fica sem prova:** como o VoiceOver em pt-BR pronuncia o
  separador "·" (U+00B7) — pode ler "ponto do meio" seis vezes por registro ou
  ignorá-lo, e só o ouvido diz. Vai para a fila como pergunta, não como achado.
- **Alvo de 44 pt:** não se aplica — não há um alvo na seção. n/a com motivo.

### Tokens

Tudo que carrega cor e tipo vem de `Tema`: `chrome`, `meta`, `tinta`,
`tintaSuave`, `tintaFraca`, `entreItens`, e o vão dos meses é `@ScaledMetric`
relativo a `.subheadline` (`PerfilView.swift:17`). A ADR é a **08h**, em
`SPEC.md:5391` e em `EVOLUCAO.md:14`; `main` tem `08a`, `08b` e `08e`, e a
reserva de `08h` para a L2 está escrita em `main:LACO.md:116` — sem colisão.
Um número solto novo: `spacing: 4` no `resumo` (o arquivo já tinha 21 literais de
`spacing` antes da volta; `Tema` não tem degrau abaixo de `entreItens = 12`). É
lacuna do `Tema`, não desta volta; fica na FILA com os cinzas.

## 2. MOVER

**Nada se move, e está dito.** O diff em Swift desta volta não tem
`withAnimation`, `.animation`, `.transition` nem curva. Apliquei ao diff as duas
regexes do portão do movimento de `main` (`TracoTests/PortaoDoMovimentoTests.swift`,
ADR 08e — o teste ainda não existe neste branch, que nasceu antes): zero
ocorrências de curva literal, zero de número cru. Quando a L2 for mesclada, o
portão vai rodar sobre este código e vai continuar verde com `faltosos` vazio.
Nada a respeitar em Reduzir Movimento porque nada se move.

## 3. Portão

| dimensão | nota | evidência |
|---|---|---|
| **Design** | **9** | Os dois defeitos de token da L1 saíram (`grep` vazio; hierarquia visível em `large` em `g4-l2-a-large-fim.png`); manchete com um assunto só; quatro estados num cinza; nenhum placar, nenhum alvo, nenhum encoding. Reparo de copy no horizonte ("12 últimos" = com descobertas) anotado, não desconta. |
| **Simplicidade** | **8** | Medida minha, mesmo binário: 886 / 1.025 pt em `large` (1,3–1,5 telas, ~um quinto do Perfil), 6.115 pt em AX5 (9 telas). Teto honesto desta tela; o que o muda é decisão do Perfil (ver acima), não extração de arquivo nem compactação de registro. |
| **Movimento** | **9** | Ausência deliberada, dita; portão de `main` aplicado ao diff: zero. |
| **Componentes** | **9** | Reusa `.emCartao()`, `rotulo(...)`; `resumo` é helper privado no padrão herdado; nenhum componente ou dependência nova; `linhaDe` da alternativa não entrou. |

### Veredito

**PASSA.** Mesclar com Simplicidade 8 e a lacuna nomeada: *o cartão é um quinto
do Perfil em `large` e nove telas em AX5 porque a altura mora no parágrafo e na
contagem de registros; só uma decisão sobre o que o Perfil mostra por padrão a
muda.* A compactação fica recusada com as capturas lado a lado como prova.

### Para o RUMO e a FILA

- **Topo da fila do Perfil, com o nome certo:** a extração dos nove cartões do
  `PerfilView` é dívida de Complexidade (983 linhas), e a altura da latência é
  dívida de Simplicidade — duas dívidas, dois remédios; a segunda pede decidir o
  que o Perfil mostra por padrão (dobra nos registros, ou parágrafo reduzido à
  frase que nomeia a capacidade).
- **Copy do horizonte:** "nos 12 últimos" são os doze últimos meses *com
  descobertas* — três palavras a mais e a frase fica exata.
- **VoiceOver e o "·":** ouvir num aparelho que possa reiniciar.
- **`Tema` sem degrau fino de espaçamento** (`spacing: 2/4/10` inline no Perfil).
- **Modo escuro** não existe no produto (`preferredColorScheme(.light)`); quando
  existir, os dois cinzas da FILA entram por ele.
- Continuam do G4 da L1: Decisão sem porta para `abandonado`; `lerLatencia()`
  síncrona no MainActor.

### Três linhas para o LACO

- A L2 fez as quatro correções e elas estão na tela do binário do commit: a
  medida saiu do menor corpo do produto e ganhou hierarquia em `large`, o "18"
  deixou de ser manchete, a lista de meses tem teto dito, e um mês de uma
  descoberta não chama de "tempo do meio" o único valor que tem.
- A compactação dos registros foi recusada pelo juiz: em `large` ela troca uma
  coluna varrível de medidas por linhas que começam com resto de hipótese, e em
  AX5 recupera sobra de linha, não forma — a altura mora no parágrafo e na
  contagem, não no arranjo.
- Simplicidade 8 é o teto honesto desta tela e não tem a ver com extrair o
  `PerfilView`: extrair não muda um pixel; o que muda é decidir o que o Perfil
  mostra por padrão, e isso é volta do Perfil.

---

## Instrumento, declarado

- **Trava:** o `xcodebuild` e **toda** sessão do `orca emulator` (attach + ax,
  attach + tap, attach + gesture) passaram por `ferramentas/orca/com-trava.sh`,
  em sessões curtas (`ax.sh`, `tap.sh`, `swipe.sh` no scratch). Esperei a trava
  atrás de três rodadas de `CadernoHitchesTests` de outro worker no `6033B043`;
  não a tomei de ninguém. **Um deslize meu:** um `orca emulator exec --command
  help` pendurou e segurou a trava por ~1 min (13:22) até eu matá-lo; ninguém
  ficou parado atrás dele que eu tenha visto.
- **Capturas** por `xcrun simctl io C2416CBC… screenshot`, nunca `booted`. Zero
  maestro. Zero mouse do Mac. Semeadura por `semear-latencia.py` do repositório
  (modos A e B, intacto).
- **Instalação limpa pede duas permissões** (notificações e Calendário); neguei
  as duas — nenhuma toca a seção.
- **Rolagem, o que funciona:** um gesto de três pontos, mesmo com o dedo parado
  antes de soltar, vira arremesso e vai ao fim da página (~7× o arrasto). Com
  **24 pontos intermediários em 800 ms** e 600 ms parado antes de soltar, o
  ganho é estável em ~2,1 pt rolados por pt arrastado; o `ir.py` do scratch mira
  um rótulo pela árvore e corrige em dois ou três passos. Vale registrar na
  ESTEIRA.
- **A4 reproduzido, com hora:** o app morreu às **13:37** (última árvore boa
  13:36:37, captura seguinte já era a tela inicial), no meio de uma rolagem em
  AX5, com quatro simuladores ligados. Sem `.ips` em `DiagnosticReports`, nada
  no `system.log` do aparelho. Relancei, voltei ao Perfil pela árvore e a medida
  do MODO B em AX5 deu os mesmos 6.115 pt antes de qualquer captura. Nenhuma
  foto deste relatório saiu de um app que não estava na frente: toda captura foi
  precedida de leitura da árvore com o rótulo alvo nela.
- Helper encerrado com o fim das sessões; o aparelho continua ligado, como
  pedido.

## Capturas e árvores deste G4 (build meu, 13:31–13:40 de 08/09)

| arquivo | o que prova |
|---|---|
| `g4-l2-a-large-secao.png` | MODO A, `large`: parágrafo "Sai das hipóteses…", manchete em duas linhas, "nos 12 últimos.", três meses, registros em dois degraus |
| `g4-l2-a-large-fim.png` | MODO A, `large`: os nove registros — a coluna de medidas na margem, a hipótese recuada; a fronteira com "Métodos" |
| `g4-l2-a-large-sistema-escuro.png` | aparelho em `dark`, a seção idêntica e clara: o app força `light` |
| `g4-l2-b-large-secao.png` | MODO B, `large`: "18 em aberto" na segunda linha; "1 descoberta · levou 5 dias"; "proposta por Grok" e "autoria desconhecida" |
| `g4-l2-b-large-fim.png` | MODO B, `large`: os doze registros e o corte por estado (descobertos e abandonados sobrevivem aos 18 abertos) |
| `g4-l2-b-ax5-cabecalho.png` | MODO B, AX5: rótulo em duas linhas e o parágrafo de 833 pt começando |
| `g4-l2-b-ax5-resumo.png` | MODO B, AX5: manchete e composição; o "18" como composição, não manchete |
| `g4-l2-b-ax5-meses.png` | MODO B, AX5: legenda com o horizonte e "agosto de 2026 · 1 descoberta · levou 5 dias" |
| `g4-l2-b-ax5-registros.png` | MODO B, AX5: dois degraus legíveis, sem transbordo |
| `g4-l2-b-ax5-registros-sistema-escuro.png` | idem com o aparelho em `dark` |
| `g4-l2-b-ax5-fim.png` | MODO B, AX5: os dois abandonados e o fim do cartão, inteiro |
| `g4-l2-ax-a-large.json`, `g4-l2-ax-b-large.json`, `g4-l2-ax-b-ax5.json` | as árvores de onde saíram 886, 1.025 e 6.115 pt, com `estado-conta` = "sem conta" |
