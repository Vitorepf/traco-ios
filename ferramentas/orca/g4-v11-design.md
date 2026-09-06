# G4 — julgamento de design da volta 11 (Ambiente Markdown: a tela do conflito)

Worktree `volta-11-markdown`, topo `aa61951`. Papel: julgar, não implementar.
Nenhuma linha de código foi alterada, nada foi commitado.

Fases do `design-router` percorridas: **Mover**, **Julgar**, **Portão**. As fases
de Ancorar/Sistema/Construir estavam feitas e provadas pelo G3 e pelo re-G3; não
as refiz.

Ciclo servido: a tela existe para o segundo ciclo — o autor sai do Traço, usa a
ferramenta que quiser, e volta sem perder o que fez. Ela só serve a esse ciclo se
a volta for uma **decisão informada**; se for um chute, o intercâmbio vira um
gerador de versões que ninguém escolheu.

---

## O que eu mesmo rodei

| | |
|---|---|
| Simulador | iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`, iOS 26.5, único meu, ligado e desligado por mim |
| Build | `com-trava.sh xcodebuild … -destination id=C7341E64…` → **BUILD SUCCEEDED**, instalado no aparelho |
| Jornada | conflito REAL de ponta a ponta, quatro vezes: intenção → versão 1 → exportar `.md` → editar o `.md` FORA do app (shell) → versão 2 no Traço → importar → decidir |
| Vídeo | `g4-v11-normal.mp4` (53 s) e `g4-v11-reduzido.mp4` (34 s) |
| Ajustes | Reduzir Movimento ligado e desligado; Dynamic Type em AX5 e de volta a `large`. **Restaurados e conferidos ao fim** (`content_size: large`, `increase_contrast: disabled`, `ReduceMotionEnabled: 0`) |
| Nunca tocado | iPhone 17 `1A46B6D3…` (do dono) — ficou `Shutdown` o tempo todo |

Texto do fixture: as duas pontas partilham um prefixo longo e divergem no fim.
É o caso REAL do ida-e-volta (o autor edita o fim do arquivo), e é o caso que
esta tela tem de resolver. O texto saiu com um remendo do autocorretor
("…em ponto" virou "…em Confirmem ate quinta"); isso não afeta nenhum achado,
porque todos dependem do **prefixo comum**, não da prosa.

### A máquina, antes do código

**Maestro está falando com o simulador errado, e eu provei por pixels.**
`maestro --device C7341E64…` imprime "Running on iPhone 17e", mas o log do driver
XCTest reporta `DeviceInfo(widthPixels=1206, heightPixels=2622)` — e o meu
iPhone 17e mede **1170×2532** (`xcrun simctl io C7341E64… screenshot` → 1170×2532;
captura de falha do maestro → 1206×2622, que é um iPhone 17 Pro, dos quatro que
outros trabalhadores mantêm ligados). Por isso a asserção `abrir-trabalhos`
falhava três vezes seguidas com a MINHA tela viva e correta: o maestro estava
lendo a hierarquia de outro aparelho. É a colisão que o próprio `README.md` já
antecipa quando diz que o `varrer.sh` "recusa rodar com mais de um simulador
ligado, porque com dois o instalador e o driver escolhem aparelhos diferentes e
o veredito sai falso". Com seis ligados, `--device` não salva.

**Consequência para este G4:** dirigi o aparelho à mão (`cliclick` sobre a janela
do meu simulador, que não se sobrepõe a nenhuma outra — x 123…513 contra x ≥ 754
das demais) e conferi **todo** passo com `xcrun simctl io <MEU UDID> screenshot`,
que é endereçado por aparelho e não admite confusão. Toda captura deste relatório
saiu desse caminho.

**Isto não é achado de código e não conta contra a volta.** Conta contra a
máquina, e vale como aviso: enquanto houver mais de um simulador ligado, um
`FALHOU` do maestro aqui não prova nada sobre o app.

---

## 1. MOVER — nota **7**

### O que a tela tem

Nada. `IntercambioTrabalhoView.swift` não contém uma única ocorrência de
`Tema.movimento`, `Tema.animacao`, `withAnimation` ou `.animation`. Conferi por
`grep` em `Traco/Trabalho/`: o único acerto na pasta inteira é
`TrabalhoView.swift:80`, uma rolagem de foco que não pertence a esta tela.
Os vídeos nos dois modos são indistinguíveis, porque não há movimento para
reduzir. O revisor chamou isso de "honesto — não há animação nova nem removida".
Concordo com o fato e discordo da conclusão.

**Movimento aqui não é enfeite disponível: é a única coisa que pode dizer que a
tela mudou.** E a tela muda duas vezes, as duas de forma invisível.

### Chegada: o conflito nasce fora da tela

`g4-v11-chegada-abaixo-da-dobra.png` — o quadro exato em que o arquivo volta do
seletor. O autor tocou "Importar", escolheu um arquivo em outro processo, voltou.
O que ele vê: **exatamente a tela de antes**. O cartão "Revisar arquivo recebido"
nasceu abaixo da dobra e nada — nem rolagem, nem opacidade, nem um sinal no
painel — diz que ele existe. A tela que o autor deixou e a tela para a qual ele
volta são o mesmo pixel acima da dobra.

A casa já resolveu isto, no MESMO arquivo pai: `TrabalhoView.swift:73-84` tem
`rolarPara` + `withAnimation { rolagem.scrollTo(alvo, anchor: .top) }`, escrito
para "o texto que o autor não escreveu começa no alto: sem isto o foco rola para
o FIM do campo e ele vê um rabo de frase". O arquivo importado É texto que o
autor não escreveu. O mecanismo está a onze linhas de distância e não é chamado.

### Desfecho: uma tela e meia some em um quadro

`g4-v11-conflito-duas-saidas.png` → `g4-v11-desfecho-guardada.png`. Ao tocar
"Guardar o arquivo como nova versão", o cartão inteiro (dois cartões de texto,
a consequência e as duas saídas — cerca de uma tela e meia) desaparece de uma vez,
tudo abaixo salta para cima, e a confirmação aparece uns 700 px ACIMA de onde o
dedo estava.

Medi o corte no vídeo cru, quadro a quadro (diferença de luminância entre quadros
consecutivos, amostrados a 30 fps sobre os últimos 13 s do clipe reduzido):

```
… 363:0.0  364:0.0  365:0.0  366:20.0  367:0.0  368:0.0  369:0.0 …
```

Um único quadro com 20 % da tela trocada, zero nos vizinhos. **Corte seco.**
(Ressalva honesta: `simctl recordVideo` é VFR e a cadência real do trecho é
~6 fps, então o quadro a mais de uma animação muito curta poderia se perder. Mas
o código não tem animação nenhuma, e é ele que fecha a conta — a medição só
confirma.)

### Reduzir Movimento

Respeitado por vacuidade: não há o que reduzir, e nada fica animando. Os dois
vídeos provam isso, e é o resultado correto para o estado atual. O que o eixo
ainda não foi exercido é a outra metade: quando o movimento entrar (itens 3 do
mínimo), ele tem de entrar por `Tema.movimento(.opacidade, …)` e
`Tema.movimento(.deslocamento, …)`, que é a lei escrita em `Tema.swift:170-190`.

### Por que 7 e não 9

Não é "faltou polimento". É que os dois instantes em que a tela tem algo a dizer
— chegou uma decisão / a decisão surtiu efeito — são silenciosos, e a casa já tem
as duas ferramentas prontas e usadas em outras telas para exatamente isso
(`CalendarioView.swift:143`, `PaginaView.swift:310-311`, e o `rolarPara` do
próprio `TrabalhoView`). Uma tela de decisão que não mostra a decisão chegando
nem o efeito acontecendo não está com movimento "honesto": está com o eixo
vazio no lugar em que ele é obrigatório.

---

## 2. JULGAR — nota **7**

### `critique-information-density` — a comparação mostra a parte que não interessa

`g4-v11-conflito-duas-versoes.png` (tamanho normal) e
`g4-v11-conflito-reduzido.png` (a segunda importação, mais próxima do uso real).

A tela mostra o **começo** dos dois textos. Edição de ida-e-volta acontece quase
sempre **longe do começo**: o autor exporta, mexe num trecho, devolve. Resultado,
na captura do segundo conflito: os dois cartões abrem com as MESMAS quatro linhas
e meia, palavra por palavra, e a divergência ("Confirmem ate quarta, porque
preciso fechar a lista com o buffet na quinta de manhã" contra "Confirmem ate
terça, o buffet fecha a lista na quarta cedo") está no fim de cada bloco.

Acima da dobra, o autor vê o primeiro cartão inteiro e o começo do segundo —
e o que ele vê é idêntico. Nada na tela marca onde os textos se separam, nem
quanto do que ele está lendo é comum. "Compare e escolha" é a instrução, e a
tela devolve dois blocos de prosa e nenhuma ajuda.

Isto **não é um limite de AX5**. As doze linhas do tamanho normal têm o mesmo
defeito assim que o documento passa de doze linhas — e o protocolo aceita 2 MiB.
AX5 só torna o problema reproduzível com três frases.

### O caminho comum (`curva-zero`)

O caminho comum está claro e é a melhor coisa da tela: as duas saídas nomeadas
pelo **desfecho**, não pela posição — "Guardar o arquivo como nova versão" e
"Manter só a versão atual" —, a primeira em cima. E `descricaoDaBase` acerta o
tom em cada estado: quando não há o que decidir, a tela diz "Não há nada para
decidir: nenhuma versão será criada" e **não oferece botão**. Isso é curva-zero
de verdade: a volta 11-B tirou uma decisão da jornada em vez de somar uma.

### `critique-visual-hierarchy` — o peso está invertido em dois lugares

Medi pelos tokens da casa (`Tema.swift:9-33`), contra o branco do cartão:

| elemento | token | contraste | tamanho |
|---|---|---|---|
| **"Manter só a versão atual"** (a saída que não faz nada) | `.compacto`, `Tema.tinta` `#1C1C1E` | **17,0 : 1** | `Tema.barra` = body **semibold** |
| texto dos dois cartões | `Tema.tinta` sobre névoa | 14,3 : 1 | `Tema.corpo` = title3 |
| **"Guardar o arquivo como nova versão"** (o caminho) | `AcaoTrabalhoStyle`, `Tema.ambarTinta` `#7A5A16` | **6,36 : 1** | `Tema.chrome` = body regular |
| **"Nenhuma escolha apaga nada…"** (a frase que tira o medo) | `Tema.meta` + `tintaSuave` | **6,35 : 1** | subheadline |

Duas inversões, as duas visíveis em `g4-v11-conflito-duas-saidas.png`:

1. **A secundária tem 2,67× o contraste da primária, e é semibold contra regular.**
   O olho cai em "Manter só a versão atual". A volta consertou o empate em âmbar
   que o G3 pegou — e o conserto correto (obedecer `Botao.swift:11-14`) produziu
   uma inversão nova, porque no fim quem manda no olho é contraste, não matiz.
   O revisor viu isto e parqueou. **Concordo em parquear** — é o padrão da casa
   e mexer no `.compacto` atinge outras telas —, mas registro com número, porque
   nesta tela as duas saídas são desfechos opostos sob medo de perda, e é a única
   tela do app em que essa inversão custa caro.

2. **A frase que autoriza o autor a decidir é o texto mais fraco do cartão, e vem
   depois dos dois blocos.** "Nenhuma escolha apaga nada: a versão N continua no
   histórico e o arquivo, se você o guardar, entra como versão nova." É a
   informação que responde à única pergunta que importa ("posso perder alguma
   coisa?"), e está no mesmo peso ótico do botão principal, no fim, colada por
   ponto-final a um aviso de outra natureza ("Mostro o começo de cada uma.").
   Duas funções distintas — ressalva de truncagem e garantia de não-perda — numa
   frase cinza só.

### `critique-affordance` — três problemas, um deles grave

**(a) Uma das duas saídas nomeadas é muda.** `g4-v11-desfecho-manter-mudo.png`:
toquei "Manter só a versão atual" e a tela **não disse nada**. O cartão some, o
painel volta ao repouso, e não há uma linha sequer. O autor não fica sabendo que
o arquivo não foi importado, nem que ele continua no aparelho e pode ser
importado depois. Na View isso é literal: `Button("Manter só a versão atual")
{ preview = nil }` (`IntercambioTrabalhoView.swift:150`) — sem `recado`.

A outra saída fala ("Nova versão externa guardada. As versões anteriores foram
preservadas."). Ou seja: a saída que o autor com medo de perder mais provavelmente
escolhe é justamente a que não confirma nada. E o produto já sabe qual é a frase
que falta — está escrita no `.precisaReabrir`: "O arquivo continua no seu
aparelho e pode ser importado depois."

**(b) O `Importar` desabilitado parece habilitado.** Provei com um par antes/depois
no mesmo ponto de rolagem: `g4-v11-importar-livre.png` (habilitado) e
`g4-v11-importar-bloqueado.png` (desabilitado, com uma edição de versão pendente).
São o mesmo âmbar, o mesmo peso, o mesmo tamanho — indistinguíveis. O único sinal
é uma frase cinza embaixo, no mesmo estilo das outras duas frases cinzas do painel.

A causa está identificada e é única: `AcaoTrabalhoStyle`
(`TrabalhoView.swift:955-964`) nunca lê `@Environment(\.isEnabled)`. O estilo
irmão da casa lê: `BotaoPrimario` faz
`foregroundStyle(ativo ? Tema.ambarTinta : Tema.tintaFraca)` (`Botao.swift:26-28`).
A regra existe; o estilo local do Trabalho não a segue — e por isso vale para
TODAS as ações do Trabalho, incluindo a entrada do fluxo que esta volta entregou.
Um `@Environment` num estilo fecha a porta em todas.

**(c) O desfecho não se parece com um desfecho.** Em
`g4-v11-desfecho-guardada.png` há três frases cinzas `Tema.meta`+`tintaSuave` na
mesma tela: "Exporte a versão em Markdown e traga o arquivo editado de volta"
(instrução fixa), "Nova versão externa guardada. As versões anteriores foram
preservadas." (o resultado do ato mais consequente do app) e "Preparar não marca
como realizado…" (outra instrução fixa). Tipograficamente idênticas. Nada marca a
do meio como evento, e nada a anuncia: não há
`AccessibilityNotification.Announcement` nesta tela, enquanto o Calendário
(`CalendarioAgenda.swift:371-373`), as Notas (`NotasView.swift:77-89`) e a Página
(`PaginaView.swift:188`) anunciam os seus. Para VoiceOver, o botão sob o foco
some e a confirmação pode nunca ser falada.

**(d) menor:** o `recado` fica velho. Vi "Arquivo exportado. Esta cópia externa
não será alterada…" sobreviver a uma gravação de versão nova
(`g4-v11-painel.png` e o quadro seguinte da jornada): a linha continua descrevendo
um ato que já passou, no painel que já andou.

### O que a tela acerta, e acerta bem

Registro porque pesa na nota e o gate não é só lista de defeitos:

- **Os dois rótulos.** "NO TRAÇO AGORA · VERSÃO 4" e "NO ARQUIVO RECEBIDO · SAIU
  DA VERSÃO 1" nomeiam procedência **e** linhagem em duas linhas de `caption2`.
  É a informação certa no lugar certo, e é o que segura a tela mesmo quando os
  textos não ajudam.
- **A consequência vem ANTES da escolha**, escrita, não implícita.
- **A lei se cumpre na prática, e eu vi.** Guardei duas vezes o arquivo: o
  histórico foi de (2) para (3) para (4), a versão local seguiu no histórico, e o
  cartão da nova versão diz "Arquivo importado · autoria não verificada". Nada
  foi sobrescrito em nenhum caminho que percorri.
- **Onde não há o que decidir, não há botão.** É a melhor decisão da volta 11-B.

---

## 3. O PONTO DO AX5 — eu **discordo** do revisor

A pergunta era se eu concordo que os dois cartões não caberem inteiros em AX5
não derruba Acessibilidade. **Não concordo, e o motivo não é o que o revisor
julgou.**

### O que a tela faz em AX5

`g4-v11-ax5-cartao-1.png` e `g4-v11-ax5-cartao-2.png`, tiradas em sequência na
mesma rolagem:

```
NO TRAÇO AGORA · VERSÃO 4
┌──────────────────────────────┐
│ Convite: sábado as 19h na    │
│ casa do Rui. Co…             │
└──────────────────────────────┘
NO ARQUIVO RECEBIDO · SAIU DA VERSÃO 1
┌──────────────────────────────┐
│ Convite: sábado as 19h na    │
│ casa do Rui. Co…             │
└──────────────────────────────┘
```

Com `lineLimit(4)` neste corpo, as quatro linhas cabem exatamente o prefixo que
os dois textos têm em comum. **Os dois cartões exibem a mesma cadeia de
caracteres, caractere por caractere, incluindo o ponto de corte.** A tela mostra
o mesmo texto duas vezes sob a frase "O trabalho mudou dos dois lados desde a
exportação. Compare e escolha."

### Por que o argumento do revisor não sustenta a nota

Ele deu cinco razões. Duas continuam de pé, três não.

| razão dele | meu julgamento |
|---|---|
| "Nada some nem corta em silêncio — a truncagem é dita: *Mostro o começo de cada uma*" | **Verdadeira sobre o fato errado.** A tela avisa que cortou. Ela não avisa o que importa: que a parte visível das duas é **igual**, e portanto que o autor não tem nada com que decidir. Um aviso de truncagem não é um aviso de indistinguibilidade. |
| "O mecanismo responde ao ambiente: `isAccessibilitySize ? 4 : 12`" | **Verdadeira e insuficiente.** Trocar doze por quatro escolhe *quantas* linhas mostrar. O defeito é *quais*: o começo é a parte que a edição de ida-e-volta menos muda. Ajustar a quantidade não podia consertar isto, e não consertou. |
| "A decisão é recuperável: nada é sobrescrito" | **Verdadeira, e é por isso que isto não é catastrófico.** Comparar mal custa uma versão a mais no histórico, não custa texto. É o que separa "corrigir antes" de "reprovar". |
| "As duas saídas são nomeadas pelo desfecho, não pela posição (Tesler)" | **Verdadeira sobre os botões, irrelevante para o achado.** Os botões estão certos. O que falta não é lembrar qual cartão estava em cima — é ter visto alguma diferença entre eles. Tesler diz que alguém absorve a complexidade irredutível; aqui ela não foi absorvida por ninguém, foi descartada. |
| "Em AX5, dois textos de várias linhas simultâneos são fisicamente impossíveis; exigir isso é exigir que a tela não exista nesse tamanho" | **Verdadeira, e é argumento CONTRA o desenho atual, não a favor.** Se não cabe mostrar os dois inteiros, a saída é mostrar **a diferença** — não mostrar duas vezes o mesmo começo. |

### E a saída que ele registrou para uma volta futura não resolve

"Um lado por vez, com troca nomeada, só em corpo de acessibilidade": trocar entre
dois painéis que **começam iguais** continua não mostrando nada. O problema não é
quantos painéis cabem na tela; é qual pedaço do texto a tela escolhe mostrar.

### O que eu aceitaria, e é mais barato

Quando o prefixo comum for maior que a janela visível, **não mostrar o começo dos
dois**. Mostrar o começo da versão atual e, do arquivo, o ponto em que ele passa
a divergir — ou, no mínimo, uma linha dizendo "as duas começam igual; a diferença
está a partir de …". É cálculo de string ao lado de `conflito(_:em:)`, testável
sem renderizar SwiftUI (como já são `conflito`, `jaGuardado` e `Desfecho`), sem
componente novo, sem estado novo, sem controle novo — e conserta o mesmo defeito
nas doze linhas do tamanho normal, para documentos longos, de graça.

### Onde isto entra na nota

**Não entra só em Acessibilidade.** É defeito de Design que AX5 expõe: em corpo
normal ele aparece assim que o documento passa de doze linhas. Por isso não
proponho baixar uma nota de "Acessibilidade" — proponho que a tela não passe em
**Design** enquanto a comparação puder devolver dois blocos idênticos.

Um último ponto que só AX5 mostrou: `g4-v11-ax5-duas-saidas.png` — as duas saídas
ficam **encostadas**, sem folga visível entre a última linha de "Guardar o arquivo
como nova versão" e a primeira de "Manter só a versão atual", e a inversão de
contraste fica gritante nesse tamanho. Os alvos têm 44 pt (a altura está certa);
falta **separação** entre dois desfechos opostos. Não é bloqueador — nada é
sobrescrito nos dois caminhos —, mas entra na dívida.

---

## 4. PORTÃO

| eixo | nota | por quê |
|---|---|---|
| **Design** | **7** | A comparação — a função da tela — devolve dois blocos idênticos no caso comum do ida-e-volta (provado em AX5, presente em corpo normal a partir de 12 linhas). Uma das duas saídas nomeadas é muda. O desfecho é tipograficamente igual às instruções fixas e não é anunciado. O `Importar` desabilitado parece habilitado. Contra isso: rótulos de procedência e linhagem excelentes, consequência escrita antes da escolha, e "não há nada para decidir" sem botão. |
| **Simplicidade** | **9** | A volta **tirou** decisão da jornada (`jaGuardado` como regra única apaga a classe "escolha sem efeito"), não criou tela, não criou token, não criou componente, e a regra ficou fora da View. Resíduos pequenos: o texto da versão atual aparece duas vezes na mesma rolagem, e o `recado` fica velho depois de atos não relacionados. |
| **Movimento** | **7** | Zero movimento próprio — e a tela tem exatamente duas coisas para dizer com movimento, as duas caladas: o conflito nasce abaixo da dobra sem sinal, e uma tela e meia some num quadro com a confirmação reaparecendo longe do dedo. As duas ferramentas existem na casa e uma delas está no arquivo pai, a onze linhas. Reduzir Movimento respeitado por vacuidade. |
| **Componentes** | **8** | `cartao(.campo)`, `rotulo()`, `.compacto`, `Tema.corpo/meta` — todos reusados, nenhum inventado; `Botao.swift:11-14` agora obedecido. Desconto: a ação principal herda `AcaoTrabalhoStyle`, um dos sete estilos por tela que o próprio `Botao.swift` já lista como dívida, e é justamente o que não implementa a regra de desabilitado que `BotaoPrimario` implementa. |

### Veredito: **CORRIGIR ANTES**

Três eixos abaixo de 9. A lei do produto se cumpre — eu guardei duas vezes e nada
foi sobrescrito — mas a tela ainda não faz o trabalho que a lei existe para
proteger: decidir com informação.

### Lista mínima (quatro itens)

1. **A comparação tem de mostrar onde os textos diferem.**
   Quando o prefixo comum ocupar a janela visível, não mostrar o começo dos dois.
   Começo da versão atual + o ponto de divergência do arquivo, ou uma linha
   nomeando que as duas começam igual e onde mudam. Cálculo de string junto de
   `conflito(_:em:)`, testável sem SwiftUI, sem componente novo. Vale para os dois
   tamanhos de corpo — não é conserto de AX5.
   *Prova de que está feito:* em AX5, com dois textos de prefixo comum, os dois
   cartões deixam de exibir a mesma cadeia.

2. **"Manter só a versão atual" tem de dizer o que aconteceu.**
   Uma linha, no mesmo lugar do outro desfecho: o arquivo não foi importado, ele
   continua no aparelho e pode ser importado depois. A frase já existe no
   `.precisaReabrir`. Um caso de `Desfecho`, sem mecanismo novo.

3. **A chegada e o desfecho têm de ser vistos.**
   (a) O cartão de revisão nascendo → trazer para a tela pelo `rolarPara` que já
   está em `TrabalhoView.swift:73-84`. (b) A entrada e o recolhimento do cartão
   sob `Tema.movimento(.deslocamento, …)`, e a linha de desfecho sob
   `Tema.movimento(.opacidade, …)`, com `reduceMotion` lido do ambiente — a lei de
   `Tema.swift:170-190`. (c) A linha de desfecho anunciada por
   `AccessibilityNotification.Announcement`, como o Calendário, as Notas e a
   Página já fazem, e distinta das instruções fixas do painel.

4. **O `Importar` desabilitado tem de parecer desabilitado.**
   `AcaoTrabalhoStyle` (`TrabalhoView.swift:955-964`) lê `@Environment(\.isEnabled)`
   e recua para `Tema.tintaFraca`, exatamente como `BotaoPrimario`
   (`Botao.swift:26-28`). Um estilo, todas as ações do Trabalho.

**O que NÃO está na lista mínima, de propósito:** a inversão de contraste entre as
duas saídas. É o padrão da casa, mexer nele atinge outras telas, e o contrato
(primária primeiro, nomeada pelo desfecho) está cumprido. Vai para o RUMO.

### Dívida nomeada para o RUMO

- **`.compacto` pesa mais que o âmbar: 17,0 : 1 contra 6,36 : 1, semibold contra
  regular — 2,67× de contraste na secundária.** Obedecer `Botao.swift:11-14`
  consertou o empate e criou uma inversão. Ou a primária ganha tratamento próprio
  em tela de decisão, ou o `.compacto` recua para `tintaSuave`. É volta própria,
  porque atravessa telas.
- **`AcaoTrabalhoStyle` dobrado nos três estilos da casa.** O próprio
  `Botao.swift:16-19` já lista os sete estilos por tela como dívida. Recolher
  este fecha o buraco do desabilitado em todas as ações do Trabalho de uma vez.
- **Em AX5 as duas saídas ficam encostadas.** Alvo de 44 pt está certo; falta
  folga entre dois desfechos opostos.
- **Trazer versão antiga de volta pela importação não tem rota** — `jaGuardado`
  responde "já está aqui". O revisor já nomeou; confirmo que é lacuna de produto,
  não regressão, e que ficou visível justamente porque a tela ficou honesta.
- **O `recado` não é zerado por atos não relacionados** — vi "Arquivo exportado…"
  sobreviver a uma gravação de versão.
- **Maestro não é confiável nesta máquina com vários simuladores ligados.**
  `--device` não impede o driver XCTest de atender outro aparelho (provado por
  dimensão de pixel). Ou o instrumento serializa os simuladores como serializa o
  build, ou todo veredito de fluxo aqui é suspeito.

### Três linhas para o LACO

```
G4 V11 CORRIGIR ANTES: Design 7, Simplicidade 9, Movimento 7, Componentes 8.
A lei se cumpre (guardei 2x, nada sobrescrito), mas a comparação devolve dois
blocos idênticos no ida-e-volta, "Manter" é mudo, chegada e desfecho não têm
sinal, e o Importar desabilitado parece vivo. Mínimo de 4 itens, dívida do
`.compacto` e do `AcaoTrabalhoStyle` nomeada. Maestro atendendo o simulador
errado com 6 ligados — provado por pixel, não conta contra a volta.
```

---

## Índice das evidências (todas minhas, deste worktree)

| arquivo | o que prova |
|---|---|
| `g4-v11-normal.mp4` (53 s) | importar → conflito → decisão → recolhimento, movimento normal |
| `g4-v11-reduzido.mp4` (34 s) | o mesmo com Reduzir Movimento: indistinguível |
| `g4-v11-painel.png` | painel em repouso, duas ações âmbar |
| `g4-v11-chegada-abaixo-da-dobra.png` | o quadro da volta do seletor: nada mudou acima da dobra |
| `g4-v11-conflito-duas-versoes.png` | os dois cartões, rótulos e consequência, corpo normal |
| `g4-v11-conflito-reduzido.png` | o segundo conflito: prefixo comum de 4,5 linhas idênticas |
| `g4-v11-conflito-duas-saidas.png` | a inversão de peso entre as duas saídas |
| `g4-v11-desfecho-guardada.png` | a confirmação como terceira frase cinza igual às instruções |
| `g4-v11-desfecho-manter-mudo.png` | "Manter só a versão atual": a tela não diz nada |
| `g4-v11-ax5-cartao-1.png` / `-2.png` | AX5: os dois cartões com a MESMA cadeia visível |
| `g4-v11-ax5-duas-saidas.png` | AX5: as duas saídas encostadas, inversão gritante |
| `g4-v11-importar-livre.png` / `-bloqueado.png` | par no mesmo ponto de rolagem: desabilitado idêntico a habilitado |
