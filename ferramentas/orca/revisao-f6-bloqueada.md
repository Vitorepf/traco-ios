# G3 — revisão independente da F6 (os widgets da tela bloqueada)

**Veredito: APROVADO, com quatro dívidas nomeadas.** Nenhuma dimensão abaixo de 9,
nenhum achado alto, nenhum defeito de código. O que falta é **evidência de um
estado** e **um `#Preview` de oito linhas** — nada disso muda o que vai mesclar.

**Quem revisa:** revisor independente. Não sou o autor e **não corrigi nada**: medi.
**Candidato:** `Vitorepf/volta-f6-bloqueada`, commit `e979d8c`, um commit sobre
`f9f2292`. **`main` andou 26 commits** desde então (está em `fc31a5c`) e **a mescla
não é limpa** — §7. **Relato do autor:** `ferramentas/orca/f6-bloqueada.md`.

**Aparelho.** `34CC3F94-FDB5-4575-A4F5-80271829A18B` (iPhone 17 Pro, teste 3), o de
trabalho. **Encontrei-o LIGADO — não fui eu que o liguei — e deixei-o ligado**, como
manda o preâmbulo. Achei-o em `content_size=large`, `appearance=light`; devolvi
`large`/`light`. **Não encostei no `B91C8DEF`**: nenhum comando meu o nomeia, e a
conta não foi tocada. **Todo comando de instrumento passou por
`ferramentas/orca/com-trava.sh`** — suíte, build, install, semeadura, toques e capturas
—, cada sequência de captura inteira dentro de **uma** posse, e nenhuma captura fora da
posse em que instalei. Nenhum mouse, nenhuma voz, nenhum VoiceOver, nenhum iPad, nenhum
maestro.

**Evidência que anexo** (abri todas, e digo o que se vê em cada uma no corpo):
`revisao-f6-ax5-o-cartao-escala.png`, `revisao-f6-ax5-as-faces-nao.png`,
`revisao-f6-editor-cego-a-captura.png`, `revisao-f6-permissao-trava-a-receita.png`,
`revisao-f6-dialogo-cobre-a-fileira-ax5.png`.

---

## 1. A suíte, refeita na árvore do candidato

`com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco -destination
"platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B"
-parallel-testing-enabled NO`, 09/09 22:24–22:27:

```
✔ Test run with 1000 tests in 161 suites passed after 89.312 seconds.
** TEST SUCCEEDED **
```

**1000/0 em 161 suítes — confere com o relato.**

**`grep -c 'warning:'` = 1, não 0:**

```
Traco/Notas/NotasView.swift:806:30: warning: '+' was deprecated in iOS 26.0:
Use string interpolation on `Text` instead
```

**É herdado de `main`.** A linha 806 é byte a byte igual nos dois, e a F6 não toca
nenhum arquivo de `Traco/` (`git diff --stat main...HEAD -- Traco/` volta vazio). O
"0 warning" do relato é **artefato de build incremental**: naquela corrida o arquivo
não recompilou, então o aviso não reimprimiu. **Não desconta nota da F6** — o dono é
`main` —, mas o G1 diz "build sem aviso" e a árvore inteira não passa nele hoje.
**Dívida 1, dono: área das Notas.**

---

## 2. O binário fotografado é o do candidato — e como conferi

Duas provas, na mesma posse da trava em que instalei:

- `cmp` do `TracoWidget.debug.dylib` do contêiner contra o produto do build **deste**
  worktree (`DerivedData/Traco-hjuivhktzidheubaaoqtxaxirell`, cujo `info.plist` aponta
  para `…/volta-f6-bloqueada/Traco.xcodeproj`) → **idêntico**.
- `strings -a` do dylib instalado → **2 ocorrências de `escolha a`**. Em `main` a
  palavra "escolha" aparece uma vez no `TracoWidget.swift` e **dentro de um
  comentário**, que não entra no binário. É um discriminador limpo.

E um achado de instrumento que vale para todos: **entre a minha primeira e a minha
segunda posse da trava o binário do widget no `34CC3F94` foi TROCADO por outra
volta** — o `cmp` acusou e eu reinstalei. Confirma a lei da casa pela terceira vez:
captura que não está na mesma posse da trava que a instalação não é evidência do seu
build.

---

## 3. As 14 capturas do autor, uma a uma — o que se vê, não o que a legenda promete

São **14** arquivos `f6-*.png` (o despacho falava em 12). Abri todos.

| arquivo | o que se vê de fato | sustenta a frase que a cita? |
|---|---|---|
| `f6-antes-bloqueada-dia-inline-retangulo-proximo-circulo.png` (18:25) | inline "Qua., 9  terminar o capítulo do m…" **sem glifo**; cartão vivo com o diálogo "Permitir Atividades ao Vivo do app Traço?" por cima; na fileira o widget **Próximo** ("PRÓXIMO / Dentista / hoje às 19:07") e o círculo ○ | **sim** para o inline sem marca. **Não** traz o retângulo do Destaque no estado "dia" — o "antes" dessa face é o `meio`, abaixo |
| `f6-antes-bloqueada-feito-inline-sem-marca.png` (18:36) | inline **idêntico** ao por-fazer, sem marca nenhuma; retângulo "✓ DESTAQUE / ~~terminar o ca…~~" em UMA linha; círculo ✓; diálogo "Deseja continuar permitindo…" por cima | **sim**, e é a prova mais direta do defeito que a volta veio matar |
| `f6-antes-bloqueada-vazio-que-cala.png` (18:36) | inline "Qua., 9  Traço"; retângulo "Traço"; círculo "+" | **sim** |
| `f6-meio-bloqueada-dia-uma-linha.png` (18:56) | inline **já com ○**; retângulo "○ DESTAQUE / terminar o cap…" — **UMA** linha | **sim** — é o "antes" honesto do retângulo |
| `f6-meio-bloqueada-feito-uma-linha.png` (18:56) | inline "Qua., 9  ✓ terminar o capítulo do…" — **o ✓ do feito, visível** | **sim**, e é a única prova do inline feito. Sem esta captura a afirmação 2 do despacho ficaria sem lastro |
| `f6-depois-bloqueada-dia.png` (18:58) | inline "○ terminar o capítulo do…"; retângulo "○ DESTAQUE / terminar o / capítulo do me…" — **DUAS** linhas, 22 caracteres contra 14 | **sim**; o par `meio`×`depois` mede a mudança de verdade |
| `f6-depois-bloqueada-vazio-oferece.png` (18:57) | inline "Qua., 9  escolha a única coisa" — **cabe inteiro, sem reticências**; retângulo "DESTAQUE / escolha a única / coisa de hoje", completo | **sim**, nas duas faces |
| `f6-bloqueada-curto-t0.png` (18:48) | cartão vivo "Curto 1 / 18:49 / <1 minuto"; retângulo "○ DESTAQUE / terminar o ca…" | **sim** — é o t0 do relógio |
| `f6-bloqueada-curto-desatualizado-t0+5min.png` (18:53) | **quadro de transição**: "Traço · desatualizado" em fundido sobre o fantasma "terminar o capítulo do…", e "DESATUALIZADO" sobre "DESTAQUE" | **sim para o que ela é citada** (o widget virou sozinho, app fechado). O estado `velha` **assentado** não está fotografado — o autor declara |
| `f6-bloqueada-dia-ax5-escuro.png` (18:47) | cartão vivo **grande** (AX5); inline e retângulo **no tamanho normal** | **sim** para "não escalam" |
| `f6-bloqueada-dia-ax5-claro.png` (18:47) | **mesmo minuto, mesmo build**; cartão vivo **no tamanho normal**; inline e retângulo **pixel a pixel iguais** ao "escuro" | **não** para o que o nome promete — §4 |
| `f6-toque-no-circulo-abre-o-app.png` (18:26) | app aberto nas **Notas**, teclado, um "M" digitado, folha "Abrir os campos / Deixar como nota" | prova **menos** — §6 |
| `f6-toque-no-retangulo-abre-o-app.png` (18:30) | app aberto nas **Notas**, teclado, campo vazio | prova **menos**, e a legenda erra a tela: o relato diz "(Perfil/Página)", a imagem mostra **Notas** |
| `f6-capsula-do-cartao-vivo-roda-sem-abrir.png` (18:35) | **a tela continua bloqueada** (relógio 18:35, papel de parede), cartão vivo expandido, e no lugar de "Lembrar em 10 min" a recusa **"🔕 avisos desligados no iPhone"** | **sim** — a melhor captura do conjunto; §6 diz o degrau que falta |

Os dois artefatos não-imagem também abertos: `f6-chronod-curto.log` (345 linhas)
tem o `record reload: […] = externalRequest(…, reason: WidgetCenterServer)` às
**18:48:00.802**, como o relato diz — mas a janela do log é de **18 segundos**
(18:48:00 a 18:48:18) e **não cobre** a virada de 18:52–18:53 que a §3 do relato cita;
essa fica sustentada pela captura, não pelo log. E o
`Failed to fetch metadata for DestaqueFeitoIntent` que o relato lista como limite tem
**zero ocorrências** neste log (é de outro log, não anexado). `f6-curto-t0-t1.txt`
casa com a captura (T0 18:48:12, T1 18:53:38).

---

## 4. O par AX5 prova mais do que o autor diz — e não prova o que o nome dele promete

O relato sustenta "não escalam com Dynamic Type" comparando
`f6-bloqueada-dia-ax5-escuro.png` (18:47) com `f6-depois-bloqueada-dia.png` (18:58) —
**duas builds diferentes**. Medi o par que ele usou para outra coisa, e ele é melhor:
`ax5-claro` × `ax5-escuro`, **mesmo minuto, mesmo build**. Diferença média absoluta
por região (Pillow, RGB, imagens 603×1311):

| região | diferença média | leitura |
|---|---|---|
| cartão vivo (y 740–980) | **11,87** | o cartão **escala**: "PRÓXIMO", "Dentista" e a cápsula estão claramente maiores no "escuro" |
| fileira do widget (y 1000–1110) | **0,73** | o retângulo é **o mesmo desenho** nos dois |
| inline (y 140–180) | 6,19 (ruído de fundo; recortei e empilhei os três: **tipo idêntico**) | o inline é o mesmo desenho |

**Duas consequências, e a segunda é um achado:**

1. **A conclusão está certa e a prova é melhor do que o autor pensa.** Esse par é a
   prova limpa: um build, um minuto, só o tamanho de letra muda — o cartão vivo cresce
   e as duas faces de acessório não mexem um pixel. É **limite do sistema**, não da
   implementação: **não desconta nota** (preâmbulo: limite declarado não desconta). A
   ADR 09r devia citar **este** par, não o par entre builds.
2. **Os dois arquivos não diferem em aparência; diferem em tamanho de letra.** Os dois
   cartões estão igualmente escuros. Ou seja: **não há evidência de que uma aparência
   clara tenha sido renderizada alguma vez**. A frase "claro e escuro: idênticos"
   sobrevive só no sentido fraco de que `simctl ui appearance light` não mudou nada na
   bloqueada — que é, aliás, o que o autor diz. O **nome do arquivo** é que promete o
   que ele não tem. **Dívida 2: renomear, ou refazer o par de aparência.**

---

## 5. O que a F6 mudou e a tela nunca mostrou — e o preview que não existe

**5a. `indisponivel` no inline, sem tela e sem preview.** O diff acrescenta
`"Traço · sem dados"` ao `accessoryInline` (`TracoWidget.swift:680`); em `main` esse
caso caía em `"Traço"`. É **comportamento novo**, é o estado de FALHA que o G2 pede
por nome, e não há captura. Nenhum cenário de `f5-semear.sh` o produz (só
`dia|vazio|feito|curto`), o que explica o buraco sem desculpá-lo.

**5b. E o preview que o relato promete não existe.** O relato justifica a ausência de
teste assim: *"a lógica nova é de view … as duas faces têm `#Preview` por estado desde
a 05u"*. **Conferi: é falso para o inline.** `grep -n accessoryInline
TracoWidget/TracoWidget.swift` devolve quatro linhas — o `case` do `switch` (665,
1206) e os `supportedFamilies` (1018, 1343) — **e nenhum `#Preview`**. Há
`#Preview("Traço · bloqueada", as: .accessoryRectangular)` (linha 1697) e ele cobre os
cinco estados, `Amostra.indisponivel` inclusive. A face que a F6 **mais** mexeu (11
linhas, quatro saídas de texto, um `Label` com glifo novo) é justamente a que não tem
preview nenhum — nem em `main`, nem aqui.

Das quatro saídas do inline, **três têm tela**: o `Label` com ○
(`f6-depois-bloqueada-dia.png`), o `Label` com ✓ (`f6-meio-bloqueada-feito…`) e
`"escolha a única coisa"` (`f6-depois-bloqueada-vazio-oferece.png`);
`"Traço · desatualizado"` aparece legível no quadro de fundido de 18:53. **Uma não
tem nada: `"Traço · sem dados"`.**

**O conserto é de oito linhas e não precisa de simulador** — o mesmo bloco do
retângulo, com as `Amostra` que já existem:

```swift
#Preview("Traço · inline", as: .accessoryInline) {
    TracoWidget()
} timeline: {
    Amostra.comDestaque; Amostra.feito; Amostra.velhoComDestaque
    Amostra.vazio; Amostra.indisponivel
}
```

**Dívida 3, e é a única que eu devolveria ao autor se o orquestrador quiser rigor
máximo.** Não segura a mescla, na minha leitura: o branch órfão é um braço de ternário
cujo texto é **idêntico** ao do retângulo duas linhas abaixo (`:724`), que já mesclou
em `main` e **tem** preview. Mas é o único ponto onde a defesa "prova-se na tela" não
se sustenta, porque o mecanismo invocado para substituir o teste não está lá.

**5c. O build final nunca foi visto grande.** As duas capturas AX5 são da build
**anterior** ao `fixedSize(horizontal: false, vertical: true)` — e o `fixedSize` é
justamente o modificador que tira do layout a capacidade de encolher.
`FraseDoAutor(linhas:)` usa `presa(a:)`, que **não** tem `minimumScaleFactor` (lei da
08h: teto de linhas corta, altura encolhe), então o que não couber é **cortado**. §8
diz até onde eu consegui fechar isto sozinho.

---

## 6. As duas capturas do "abre o app": provam menos do que a frase diz

O despacho perguntou direto. Resposta direta: **provam menos.**

`f6-toque-no-circulo-abre-o-app.png` e `f6-toque-no-retangulo-abre-o-app.png` mostram
o app em primeiro plano nas Notas, com hora. **Não há tela bloqueada no quadro, não há
par antes/depois, nada liga o toque à abertura.** Uma delas ainda erra a tela na
legenda. Sozinhas, provam que o app estava aberto às 18:26 e às 18:30.

**A conclusão, porém, se sustenta — pelo resto da evidência, não por elas:**

- `f6-capsula-do-cartao-vivo-roda-sem-abrir.png` traz o **contrafactual na mesma
  tela**: a bloqueada continua bloqueada e o botão do cartão vivo já rodou (a recusa
  "avisos desligados no iPhone" ocupou o lugar dele). Isso é prova de mecanismo.
- O código explica por quê, e conferi: `DestaqueFeitoIntent: LiveActivityIntent`, com
  `openAppWhenRun = false` e o `perform()` inteiro dentro de `#if TRACO_APP`
  (`Traco/App/Intents/Compartilhado/DestaqueFeitoIntent.swift:13-45`) — o corpo roda
  no processo do app, e para isso acontecer a partir de um widget da bloqueada o
  sistema tem de lançar o app.
- `superficie.feito` seguiu `false` e o `chronod` não registra `perform`.

**O degrau que falta:** o botão que rodou no cartão vivo foi o `LembrarDepoisIntent`
(a recusa dos avisos) — **irmão de protocolo**, não o `DestaqueFeitoIntent`. Na mesma
captura o cartão expandido traz a linha "DESTAQUE ○ terminar o capítulo do meio antes
de dormir": tocar **naquele** ○ teria fechado o argumento com o intent idêntico dos
dois lados. Não é erro de conclusão, é um degrau de rigor. **Anotar na F6b**, não
segurar a volta.

**A retirada do círculo foi a decisão certa**, e é o melhor momento da volta: um
`accessoryCircular` que se veste de botão e age como link é pior que nenhum, e o
autor construiu, mediu, provou e **apagou** — com a dívida nomeada, dono e caminho.

---

## 7. Contrato, registro e mescla

- **ADR 2026-09-09r** (`SPEC.md:8363-8407`): curta, honesta, com as cinco medidas e o
  limite declarado. Boa.
- **EVOLUCAO.md**: a linha "Fora do app" ganha a 09r e **nomeia a lacuna F6b**. Fecha
  uma lacuna e abre outra pelo nome — é exatamente o que a dimensão Visão pede.
- **RUMO.md**: F6 marcada no branch, **F6b criada com dono ("fora do app") e caminho
  ("uma consulta ao Astra antes")**. Exemplar.
- **A ADR 04f ficou com a frase desmentida de pé.** `SPEC.md:1281` ainda diz "o círculo
  marca a única coisa de hoje, **na tela bloqueada** e na Ilha, com o mesmo
  `DestaqueFeitoIntent`", e o comentário em `TracoWidget/TracoWidget.swift:686` repete
  "ADR 04f: na tela bloqueada o Destaque também se marca" — **exatamente em cima do
  `BotaoFeito` que não marca**. A 09r corrige o registro em prosa, mas quem ler o
  código às 3h da manhã bate primeiro no comentário antigo. Duas linhas de marcação
  fecham, e a casa tem precedente (o commit `10bfe87` de `main` voltou e marcou como
  errada uma seção da ESTEIRA). **Dívida 4, baixa.**
- **A mescla NÃO é limpa.** `git merge-tree main HEAD` acusa conflito em `SPEC.md`,
  `EVOLUCAO.md` e `ferramentas/orca/LETRAS-ADR.md`. E há conteúdo a resolver, não só
  rodapé: o branch escreve **"Próxima livre: 09q"**, enquanto `main` já reservou 09q
  (B2), 09r (F6) e 09s (Q4-C) e diz **"Próxima livre: 09t"**. Mesclar a versão do
  branch **regride o registro**. Resolver por `main`, mudando só a linha da 09r de
  "reservada, volta viva" para o estado novo. **Trabalho do G5, do orquestrador — não é
  defeito do autor.**

---

## 8. O que eu mesmo rodei no aparelho — inclusive o que não deu certo

### 8a. O script do autor NÃO plantou o estado sem intervenção — duas tentativas, duas paradas

O despacho pediu: rode `f6-plantar-bloqueada.sh` você mesmo e diga se ele planta sem
intervenção. Rodei duas vezes no `34CC3F94`, sob a trava, com o binário do candidato
conferido. **As duas falharam, em pontos diferentes:**

**Tentativa 1 (22:37).** Percorreu o editor todo pelos rótulos — `posterboard-customize-button`
(0,500 0,929), `grouped-widgets-reticle-view` (0,500 0,788), `^Traço$` (0,500 0,899),
`^Traço, Traço$`, `^Traço, Próximo compromisso$`, `^fechar$` — e morreu no passo
seguinte:

```
f6-plantar: a galeria do inline não abriu
```

Isto é **exatamente o passo que o próprio script marca como "o único toque cego
daqui"**: `"$EMU" "$U" tap 0.5 0.093`, a coordenada fixa do reticle do topo. Como o
`tocar 'editing-done'` vem depois, **nada foi salvo** — a corrida terminou com o pôster
como estava e sem widget nenhum. Um script que falha antes de confirmar é honesto (não
deixa meia-edição), mas não é uma receita que se roda e vai embora.

**Tentativa 2 (22:42).** Parou mais cedo:

```
  toquei '^Traço$' em (0.500 0.500)
f6-plantar: esperava 'A única coisa de hoje' e não veio
```

Na tentativa 1 o mesmo `^Traço$` resolveu para **(0,500 0,899)**; na 2, para
**(0,500 0,500)**. A função `achar()` devolve **o primeiro nó da árvore achatada** que
casa com o regex, e `^Traço$` é ambíguo (a linha do app na lista, o cartão na fileira,
o rótulo do pôster). O toque caiu noutro nó e **abriu o app**: a captura do momento
mostra a tela de Notas às 22:43, com uma nota de verdade aberta. Daí a galeria de
widgets nunca vir.

**Diagnóstico, para quem for consertar:** o passo `rolar_ate '^Traço$'; tocar '^Traço$'`
precisa de um rótulo desambiguado (o `id` do nó, ou o par `type`+`label`, como os
passos vizinhos já fazem com `'^Traço, Traço$'`). E o toque cego do inline precisa
achar o reticle na árvore em vez de confiar em 0,093. **Dívida de instrumento, não de
produto.** Parte disto é a lei já registrada na ESTEIRA — *"a galeria de widgets
trava"*, que derrubou três revisões da F4 — e a ESTEIRA diz que isso **é instrumento e
não desconta nota**. Registro assim.

**Consequência honesta:** eu **não consegui** fotografar as faces do build candidato na
bloqueada com as minhas próprias mãos. As capturas que sustentam esta revisão são as do
autor, lidas uma a uma (§3), mais o que segue.

### 8b. O que eu consegui confirmar sozinho

- **O achado que abriu a volta se reproduz.** Toque longo no pôster às 22:45: a árvore
  de AX devolve `Personalizar` e `posterboard-customize-button` **no mesmo instante** em
  que o `xcrun simctl io … screenshot` mostra só o pôster encolhido, **sem os botões**
  (`revisao-f6-editor-cego-a-captura.png`). É a premissa da ADR 09r, confirmada por
  outra mão: **ausência na captura não era ausência na tela**, e a F1 concluiu errado.
  (Registro uma inconsistência do simulador: num quadro meu das 22:36 o "Personalizar"
  e o "+" **apareceram** na captura. O comportamento não é estável; a conclusão do autor
  continua de pé.)
- **Um limite que ele declarou, reproduzido.** O relato diz que "pedidos do sistema
  cobrem a fileira em AX5 até serem respondidos". Bateu: `revisao-f6-dialogo-cobre-a-fileira-ax5.png`
  (22:39) mostra "Permitir Atividades ao Vivo do app Traço?" em corpo AX5 tapando o
  cartão inteiro.
- **A receita não é auto-suficiente a partir de um aparelho limpo.** `f5-instalar.sh`
  faz `uninstall` antes do `install`, e o `uninstall` **derruba a permissão do
  Calendário**. Na volta seguinte o app abre atrás de "O app Traço deseja ter acesso
  total ao Calendário." e **nunca publica** o `superficie.json`
  (`revisao-f6-permissao-trava-a-receita.png`); `f5-semear.sh` então morre com "o app
  NÃO publicou … em 30 s" e a corrida inteira cai. Perdi ~12 minutos nisso. O conserto é
  uma linha: `xcrun simctl privacy <UDID> grant calendar app.traco` antes do primeiro
  lançamento. **Dívida de instrumento; o dono é a F5, não a F6**, mas quem seguir a
  receita da F6 esbarra nela.
- **`f5-semear.sh` falha ao semear o MESMO cenário duas vezes seguidas.** Ele espera o
  `superficie.json` ficar mais novo que uma marca, e `Superficie.publicar` **descarta
  escrita idêntica** (`SuperficieFora.swift:331`) — então o mtime não anda e o script
  diz "não publicou" com o estado correto no disco. Ruído, não defeito.
- **A restauração está feita e conferida por captura.** `content_size` de volta em
  `large` e `appearance` em `light` — como achei —, `xcrun simctl ui` confirma os dois,
  e a captura das 22:44 mostra a casa em corpo normal. Os dois aparelhos seguem
  **ligados**, como estavam quando cheguei.

### 8c. O buraco do AX5, fechado por mecanismo (não por foto)

A §5c dizia que o build final nunca foi visto grande, e eu não consegui fotografá-lo.
Mas a medida da §4 responde melhor do que uma foto responderia: no par de 18:47,
**mesmo build, mesmo minuto**, mudar o corpo do sistema para AX5 moveu o cartão vivo
(11,87 de diferença média) e **não moveu um pixel das duas faces de acessório** (0,73 na
fileira). Se o `dynamicTypeSize` **não chega** à view, então `fixedSize` não pode se
comportar de um jeito em `medium` e de outro em AX5 — não há segunda condição para ele
responder. O risco que sobra é o de aparelho de verdade, que é a mesma lacuna já
declarada (StandBy e bloqueada trancada não renderizam no simulador). **Fica como está:
limite declarado, não desconta.**

---

## 9. Scorecard

Nota por dimensão, com a prova que a sustenta. Limite de instrumento declarado não
desconta; promessa sem prova, sim.

| dimensão | nota | evidência |
|---|---|---|
| **Visão** | **9** | entra no ciclo "multiplicar"; o diff do `EVOLUCAO.md` reescreve a linha "Fora do app" e **nomeia a lacuna nova (F6b)** no mesmo ato. Fechar uma e abrir outra pelo nome é o ciclo funcionando |
| **Contrato** | **9** | ADR 09r curta e coerente com o código (`SPEC.md:8363-8407`); RUMO com F6 e F6b (dono e caminho); LETRAS-ADR registrada. **Menos**: a ADR 04f ficou com a frase desmentida de pé (`SPEC.md:1281`) e o comentário `TracoWidget.swift:686` a repete em cima do botão que não marca — §7, dívida 4 |
| **Correção** | **9** | suíte refeita por mim: `✔ Test run with 1000 tests in 161 suites passed after 89.312 seconds.` + `** TEST SUCCEEDED **`, `-parallel-testing-enabled NO`, no `34CC3F94`. Nenhuma rota maestro tocada. Sem teste novo, e conferi que **é a norma da árvore**: nenhum teste em `TracoTests/` referencia `TracoWidgetView` nem qualquer string dessas faces. **Menos**: 1 warning (herdado de `main`, §1) e o `#Preview` do inline que o relato diz existir e não existe (§5b) |
| **Jornada real** | **9** | dia, feito, vazio e desatualizado vistos **na bloqueada de verdade**, antes e depois, conferidos por mim um a um (§3) — as três primeiras no build que vai mesclar. **Menos**: `indisponivel` (o estado de falha do G2) sem tela e sem preview; o retângulo feito não foi refotografado em duas linhas (declarado pelo autor) |
| **Design** | **9** | as seis fases estão citadas **com o que cada uma decidiu**, não como lista; comecei conferindo pela tela, como manda o meu papel (`revisor.md`: o revisor não carrega a skill, confere a citação contra a tela). Zero token novo — `Tema.label`, `Tema.meta`, `Tema.trackingLabel`, glifos que a casa já usa; `fixedSize(horizontal:vertical:)` já aparece 5× no mesmo arquivo, é idioma da casa, não truque |
| **Simplicidade** | **9** | o inline diz **uma** coisa (a linha); o vazio oferece em quatro palavras e **cabe inteiro** sem reticências (`f6-depois-bloqueada-vazio-oferece.png`). Nada cresceu: nenhum passo, nenhuma tela, nenhuma decisão a mais. `curva-zero` não se aplica (não é jornada, formulário nem primeiro uso) |
| **Movimento** | **n/a** | a casa não anima nada aqui; o fundido de `f6-bloqueada-curto-desatualizado-t0+5min.png` é do sistema. Motivo dito, não é nota de cortesia |
| **Componentes** | **n/a** | nenhum componente foi criado, e nenhum devia: `FraseDoAutor` e `BotaoFeito` já existiam e o parâmetro `linhas:` já estava lá desde antes. O `#Preview` que falta está cobrado em Correção |
| **Acessibilidade** | **9** | **subo a nota que o autor se deu (8).** Os dois pontos pelos quais ele se descontou são **limites declarados, que por regra não descontam**: (a) Dynamic Type — medi e é do sistema, não da implementação (§4: 0,73 de diferença na fileira contra 11,87 no cartão vivo, mesmo build, mesmo minuto); (b) VoiceOver falado é **proibido** no Traço, e o rótulo está no código (`TracoWidget.swift:676`, `accessibilityLabel(d.feito ? "Feito: \(d.emVoz)" : d.emVoz)`), com `emVoz` não-opcional (`SuperficieFora.swift:74`), então não há `Optional(...)` vazando na fala. Alvo: o retângulo inteiro dentro do `BotaoFeito`. Contraste: material do sistema |
| **Performance** | **n/a** | não toca lista, editor nem parser; duas faces de texto estático por entrada |
| **Privacidade e autoria** | **9** | nada novo sai do app; as quatro strings são literais. O `accessibilityLabel` novo expõe `emVoz`, que é a **mesma** linha já publicada e já falada pelo retângulo desde a 05u, com o teto de 140 grafemas da 08h aplicado no publicador — nenhuma superfície nova |
| **Estado honesto** | **10** | é o melhor da volta. O feito passou a ser visível, o vazio oferece, o desatualizado se diz — e **o defeito foi NOMEADO em vez de escondido**: o botão que abre o app virou F6b no RUMO, com dono e caminho, e a face que não prestava (`accessoryCircular`) foi construída, medida e **apagada**. Um círculo que se veste de botão e age como link é pior que nenhum; a volta chegou a essa conclusão com prova e agiu |
| **Complexidade** | **10** | `git diff --shortstat main...HEAD -- TracoWidget/ Traco/` = **1 arquivo, +42 −8**. Nenhum arquivo Swift novo, nenhuma abstração, nenhuma configuração. Dois scripts de instrumento (+122). E uma família inteira de widget **saiu** em vez de entrar |
| **Fora do app** | **9** | `accessoryInline` e `accessoryRectangular` fotografados **na tela bloqueada de verdade pela primeira vez no projeto**; um toque faz uma coisa — exceto o feito, que é a F6b e está dito. Atualização pela linha do tempo provada com o app fechado (`f6-bloqueada-curto-t0.png` 18:48 → `…-desatualizado-t0+5min.png` 18:53). **Menos**: `indisponivel` sem tela. StandBy não renderiza no simulador — limite declarado, não desconta |
| **Relato** | **9** | honesto onde importa: separa medido de inferido, lista o que não refotografou, e não esconde que o círculo foi construído e retirado. **Menos**: três escorregões de fato, todos pequenos e **nenhum a favor do autor** — "0 warning" (build incremental, §1), "(Perfil/Página)" onde a captura mostra Notas (§3) e "as duas faces têm `#Preview` por estado", que é falso para o inline (§5b) |

**Menor nota: 9. Nada abaixo de 9. VEREDITO: APROVADO — pode mesclar.**

### As quatro dívidas, para o RUMO

1. **Aviso herdado de `main`** — `NotasView.swift:806`, `'+' was deprecated in iOS 26.0`.
   Dono: área das Notas. O G1 diz "build sem aviso" e a árvore não passa nele hoje.
2. **`f6-bloqueada-dia-ax5-claro.png` promete o que não tem** — o par difere em tamanho
   de letra, não em aparência. Renomear, ou refazer o par de claro/escuro.
3. **O `#Preview` do `accessoryInline`** — oito linhas, sem simulador, fecha o único
   braço sem prova (`"Traço · sem dados"`) e torna verdadeira a frase do relato. **É a
   única coisa que eu devolveria ao autor se o orquestrador quiser rigor máximo**; na
   minha leitura não segura a mescla, porque o texto do braço órfão é idêntico ao do
   retângulo em `:724`, que já está em `main` e tem preview. Junto: um cenário
   `indisponivel` no `f5-semear.sh` (duas linhas) para o G2 poder fotografá-lo.
4. **ADR 04f com a frase desmentida** — marcar `SPEC.md:1281` e o comentário
   `TracoWidget.swift:686`, como o `10bfe87` já fez com a ESTEIRA. Duas linhas.

E, para o **G5 (orquestrador, não o autor)**: a mescla conflita em `SPEC.md`,
`EVOLUCAO.md` e `LETRAS-ADR.md`. No LETRAS-ADR **resolver por `main`** — o branch diz
"Próxima livre: 09q" e `main` já está em 09t.

### Dívidas de instrumento levantadas nesta revisão (não descontam nota)

- `f6-plantar-bloqueada.sh`: `achar '^Traço$'` é ambíguo e pegou o nó errado; o toque
  cego em (0,5, 0,093) para o reticle do inline não abriu a galeria. Duas paradas em
  duas corridas (§8a).
- `f5-instalar.sh`: o `uninstall` derruba a permissão do Calendário e o app deixa de
  publicar. Uma linha resolve: `xcrun simctl privacy <UDID> grant calendar app.traco`.
- `f5-semear.sh`: semear o mesmo cenário duas vezes seguidas reporta falha, porque
  `publicar` descarta escrita idêntica e o mtime não anda.
