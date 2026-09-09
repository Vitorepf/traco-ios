# S1-B — os dois testes que passavam para mim e falhavam para o revisor

**Papel:** implementador. **Volta:** S1-B, sobre `47231c9` (candidato reprovado
em G3 por `ferramentas/orca/revisao-s1-pergunta.md`).
**Simulador exclusivo:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`.
**Trava:** todo `xcodebuild`, `xcodebuild test` e toda sessão de `orca emulator`
passou por `ferramentas/orca/com-trava.sh`. Não usei Siri, ditado, síntese de
fala, VoiceOver nem iPad. **Não instalei nada no `C2416CBC`** e não o toquei.
Não mesclei nada.

## 1. O achado: a dependência de estado tinha nome, e não era "notas semeadas"

Reproduzi o vermelho do revisor no primeiro tiro, com o app **desinstalado antes
da corrida**:

```text
xcrun simctl uninstall A1DF082C-FC87-4DF9-9F56-F2DA1C084DED app.traco
ferramentas/orca/com-trava.sh xcodebuild test-without-building -project Traco.xcodeproj \
  -scheme TracoUITests -destination 'platform=iOS Simulator,id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED' \
  -derivedDataPath /tmp/traco-s1b -only-testing:TracoUITests/PerguntaSobreviveUITests \
  -parallel-testing-enabled NO

PerguntaSobreviveUITests.swift:40: error: XCTAssertTrue failed - PRÉ-CONDIÇÃO: o Calendário não abriu — a aba não trocou
PerguntaSobreviveUITests.swift:58: error: XCTAssertEqual failed: ("Optional("o que eu aprendi ontemgggd")") is not equal to ("Optional("o que eu aprendi ontem"))
PerguntaSobreviveUITests.swift:40: error: XCTAssertTrue failed - PRÉ-CONDIÇÃO: o Calendário não abriu — a aba não trocou
	 Executed 2 tests, with 3 failures (0 unexpected) in 39.168 seconds
** TEST EXECUTE FAILED **
```

**A segunda linha é o achado inteiro.** A busca terminou a corrida valendo
`"o que eu aprendi ontem`**`gggd`**`"`. Os quatro toques em `aba-calendario` não
trocaram de aba: **viraram quatro letras**. A barra estava atrás do teclado, e o
teste tocava a coordenada sem olhar o que havia sob ela.

**Onde a hipótese da S1 parou pela metade.** A S1 já tinha nomeado "com o campo
de busca em foco a barra de navegação some" e mandou o teste arrastar a lista
antes de trocar — o gesto `.scrollDismissesKeyboard(.interactively)` do próprio
app. O que ela não viu: **`NotasView.lista` tem dois ramos.**

| ramo | quando | tem `ScrollView`? | o arrasto dispensa o teclado? |
|---|---|---|---|
| cheio | há notas visíveis | sim | **sim** (era ali que o `.scrollDismissesKeyboard` vivia) |
| vazio | a busca/filtro não achou nada | **não**, era um `VStack` | **não — não há o que arrastar** |

E os dois testes digitam `"o que eu aprendi ontem"` na busca, **o que filtra o
arquivo até zero**. Eles caem no ramo vazio, sempre. O teste passava para quem
tinha notas no aparelho que a busca por sentido devolvia, e falhava para quem
abriu o app limpo. **Era o instrumento medindo o lixo do aparelho anterior, não
a tela.** Medida do AX pelo `orca emulator`, no mesmo aparelho, antes e depois de
focar a busca:

```text
== abas ANTES do teclado ==      {"x": 0.3997, "y": 0.9085, "width": 0.2007, "height": 0.0503}
== abas COM o teclado em pé ==   {"x": 0.3997, "y": 1.0572, "width": 0.2007, "height": 0.0503}
```

`y: 1.0572` é o mesmo número do relatório do G3 — fora da tela.

## 2. Não é defeito do teste; é defeito da pessoa (ADR 2026-09-09d)

Filtrar até zero com o teclado em pé **prende quem escreveu**: a barra de abas
fica atrás do teclado, não há lista para arrastar, e as duas saídas visíveis
("x" e "ver todas as notas") **jogam fora exatamente o que se estava
procurando**. O comentário que já estava no código do ramo cheio dizia a mesma
coisa — *"sem isto o teclado da busca prendia a tab bar atrás de si e a única
saída era o 'x'"* — só que **o ramo vazio ficou para trás**, e é onde a pessoa
está mais perdida.

O conserto é uma guarda no lugar comum, não uma por ramo:

- o `.scrollDismissesKeyboard(.interactively)` **subiu** do ramo cheio para o
  `Group` que envolve os dois (uma linha a menos, não a mais);
- o ramo vazio virou um `ScrollView` com `.scrollBounceBehavior(.always)` —
  conteúdo curto não rola sozinho, e sem rolar não há gesto para o teclado
  seguir.

**Nenhum pixel mudou**: o mesmo `VStack` alinhado ao topo, na mesma margem, com
`linhaTrabalhos` e `Vazio` na mesma ordem. Nada de componente novo, token novo
ou animação nova.

## 3. Não afrouxei asserção — troquei o que o teste afirma antes de tocar

O helper `soltarOTeclado` agora **arrasta enquanto `app.keyboards` existir** e
depois **afirma que ele saiu**, com mensagem que diz o que teria acontecido
("todo toque na barra vira letra"). Em seguida `trocarDeAbaEVoltar` afirma que
`aba-calendario` **existe na árvore** e que **é alcançável** (`isHittable`),
antes de tocar. Um teste que toca coordenada sem checar o que está sob ela não
mede a tela — mede a sorte.

**As duas asserções finais estão intactas**, palavra por palavra: `busca-notas`
tem de valer `"o que eu aprendi ontem"`, e `cartao-sabia-notas` tem de existir
depois da volta.

## 4. Dez corridas seguidas, do zero — 10 de 10

Cada corrida: `simctl shutdown` → esperar `Shutdown` → `simctl boot` →
`bootstatus` → `simctl uninstall app.traco` → `xcodebuild test-without-building`
sob a trava. **Aparelho recém-ligado e app recém-instalado em todas as dez.**

```text
=== corrida 1 · 06:20:41 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.493 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 2 · 06:21:26 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.168 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 3 · 06:24:14 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.407 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 4 · 06:24:58 ===   Executed 2 tests, with 0 failures (0 unexpected) in 28.948 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 5 · 06:26:20 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.246 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 6 · 06:27:04 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.047 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 7 · 06:27:50 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.106 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 8 · 06:29:01 ===   Executed 2 tests, with 0 failures (0 unexpected) in 29.008 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 9 · 06:29:47 ===   Executed 2 tests, with 0 failures (0 unexpected) in 28.924 s   ** TEST EXECUTE SUCCEEDED **   exit=0
=== corrida 10 · 06:30:31 ===  Executed 2 tests, with 0 failures (0 unexpected) in 29.802 s   ** TEST EXECUTE SUCCEEDED **   exit=0
```

Nenhuma corrida travou antes de conectar; nenhuma foi repetida ou descartada.

## 5. O vermelho do pai, com o instrumento novo, em árvore descartável

`git archive cce6beb` para `/tmp/traco-pai-s1b`. Trouxe **só o instrumento**: o
arquivo `PerguntaSobreviveUITests.swift` e o bloco `NotasView.lista` (a 09d, que
é o que torna a jornada **alcançável**). O `@State private var conversaNotas =
ConversaNotas()` do pai ficou **intacto** — é ele que o teste tem de reprovar.
`xcodegen generate`, build e corrida no **meu** UDID:

```text
/tmp/traco-pai-s1b/TracoUITests/PerguntaSobreviveUITests.swift:76: error: XCTAssertEqual failed:
  ("Optional("vazio")") is not equal to ("Optional("o que eu aprendi ontem")")
  - o que a pessoa estava escrevendo sumiu ao trocar de aba
/tmp/traco-pai-s1b/TracoUITests/PerguntaSobreviveUITests.swift:96: error: XCTAssertTrue failed
  - o cartão da sábia sumiu ao trocar de aba — a pessoa perdeu o que esperava sem que nada dissesse
	 Executed 2 tests, with 2 failures (0 unexpected) in 32.623 seconds
** TEST FAILED **
```

**Duas falhas, nas duas asserções finais — nenhuma pré-condição falhou.** No pai,
a jornada chegou ao Calendário e voltou; foi o **estado** que sumiu. É a prova de
que o teste visita o lugar do defeito da 09c e não passa por acidente.
`/tmp/traco-pai-s1b` e `/tmp/traco-pai-s1b-dd` foram **removidos** ao fim.

## 6. Prova visual — instrumento trocado, e por quê

Tentei filmar a jornada dirigindo pelo `orca emulator`. **O helper devolveu
`ok:true` e a tela não mudou**: depois de `gesture` com `begin/move/end`, o AX
continuou com as abas em `y: 1.0572`. É o mesmo limite que o revisor encontrou.
**Não usei esse caminho como prova.** Troquei o instrumento: `xcrun simctl io
<UDID> screenshot` em laço enquanto o **XCUITest** dirige (165 quadros), e
escolhi os quadros pela faixa de pixels do pé da tela. O que se vê em cada um:

| quadro | arquivo | o que se vê |
|---|---|---|
| 0100 | `s1b-01-teclado-em-pe-sem-barra-de-abas.png` | Notas, "nada aqui ainda." (ramo **vazio**), cartão *"o que eu aprendi ontem / a sábia não respondeu / Repetir pergunta"*, campo de busca com caret, **teclado inteiro em pé** e **nenhuma barra de abas** |
| 0110 | `s1b-02-arrasto-no-vazio-devolve-a-barra.png` | mesma tela **depois do arrasto no vazio**: teclado fora e a barra de volta — *Escrever · Notas · Calendário · Padrões · Perfil* — com o cartão intacto |
| 0126 | `s1b-03-o-calendario-foi-alcancado.png` | Calendário aberto ("9 de setembro", a semana, a grade de horas), aba **Calendário** acesa; o alerta do sistema de acesso ao Calendário aparece por ser instalação nova |
| 0150 | `s1b-04-o-cartao-continua-ao-voltar.png` | de volta às Notas: **o mesmo cartão, a mesma pergunta e "Repetir pergunta" no lugar** — a jornada da 09c fechada de ponta a ponta |

## 7. Suíte integral

```text
ferramentas/orca/com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco \
  -destination 'platform=iOS Simulator,id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED' \
  -parallel-testing-enabled NO

✔ Test run with 973 tests in 156 suites passed after 73.336 seconds.
** TEST SUCCEEDED **
```

`grep -c "warning:"` na saída, fora do ruído de `hapticpatternlibrary.plist` do
simulador: **0**.

## 8. As seis dimensões que o G3 pôs abaixo de 9

- **Correção (era 4).** 2 testes, 0 falhas, **dez corridas do zero**, mais 973/973
  na suíte integral. Vermelho do pai reproduzido com o mesmo instrumento.
- **Jornada real (era 4).** A jornada completa agora está em quadro: teclado em
  pé sem barra → arrasto → barra de volta → Calendário → Notas com o cartão.
- **Design (era 6).** O Portão passa a se sustentar porque a fase **Mover** e a
  fase **Julgar** foram feitas na tela viva, não no papel: o gesto que devolve a
  tela existe nos dois estados, e o quadro 0110 mostra a barra de volta. Rota do
  `design-router`: **ajuste local**, entrando pela fase 5 (auditar antes de
  tocar) — a tela já existe e nenhum pixel novo entrou.
- **Simplicidade (era 5).** A barra deixa de sumir sem saída, e a contagem da
  09c (2 toques + redigitar → 1 toque em "Repetir pergunta") passa a ser
  verificável, porque a ida ao Calendário agora existe. O diff **tira** uma
  linha de dentro do ramo e a põe uma vez no `Group`.
- **Acessibilidade (era 5).** As abas voltam de `y: 1.0572` para `y: 0.9085` com
  o gesto do próprio app, em qualquer estado da lista. **Limite declarado, não
  desconto:** VoiceOver falado é proibido no Traço por ordem do dono, então a
  prova é árvore de AX + captura do mesmo instante.
- **Estado honesto (era 5).** O caminho que não conseguia preservar agora
  preserva **e** é alcançável. Nada foi escondido: o quadro 0126 mostra até o
  alerta de permissão do Calendário que a instalação nova traz.

## Limites que registro, e não escondo

- **`orca emulator gesture` devolveu `ok:true` sem mover a tela** neste
  aparelho. Nenhuma nota deste relatório se apoia nele; o que ele produziu foi
  descartado e o instrumento trocado (§6).
- **Um aparelho só.** Tudo foi medido no `A1DF082C`, em tamanho de letra padrão
  e retrato. Não medi em AX XXXL nem no 17e.
- **A permissão do Calendário** aparece na primeira corrida depois de instalar;
  não a respondo, e as dez corridas passaram assim.
- **`EVOLUCAO.md` não foi tocado**: a 09d conserta uma armadilha de tela, não
  fecha capacidade da visão.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | prova e limite |
|---|---:|---|
| Visão | 10 | Sem a 09d a jornada da 09c não é alcançável; com ela, a lacuna do RUMO fecha na tela. |
| Contrato | 10 | ADR 2026-09-09d escrita, letra reservada em `LETRAS-ADR.md`, parágrafo "não consertado" da 09c corrigido. |
| Correção | 10 | 10/10 corridas do zero coladas; 973/973; vermelho do pai reproduzido nas asserções finais. |
| Jornada real | 10 | Quatro quadros do filme, descritos um a um (§6). |
| Design | 9 | Ajuste local, zero pixel novo; Portão observado na tela viva. Não medi em AX XXXL. |
| Simplicidade | 10 | Uma linha sai do ramo e vira uma no `Group`; o vazio ganha `ScrollView`. Sem dependência nova. |
| Movimento | n/a | Nenhuma animação nova. |
| Componentes | n/a | Nenhum componente criado ou alterado. |
| Acessibilidade | 9 | Abas voltam de `y: 1.0572` a `y: 0.9085`; VoiceOver falado proibido (limite declarado). |
| Performance | n/a | Nenhuma lista, editor ou parser alterado — o ramo tocado é o do arquivo **vazio**. |
| Privacidade e autoria | 10 | Nada de origem, envio, gasto ou IA foi tocado. |
| Estado honesto | 10 | O caminho preserva e é alcançável; os limites do §"Limites" estão escritos, não contornados. |
| Complexidade | 10 | O diff de produto tem 1 `ScrollView`, 1 `scrollBounceBehavior` e 1 modificador movido. |
| Fora do app | n/a | Nenhuma superfície fora do app. |
| Relato | 10 | Vermelho, dez verdes, vermelho do pai, quadros descritos, limites e instrumento descartado. |
