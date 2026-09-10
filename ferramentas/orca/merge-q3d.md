# MERGE-Q3D — `responderNasNotas` chega ao autor, e o Perfil passa a falar a língua dele

**Linha do ciclo.** É o **G5** da Q3-C e da Q3-D. Serve à intenção *"a lista de
indisponíveis do Perfil chega a ZERO"*; reduz o obstáculo *"a primeira operação a voltar
está aprovada e ainda não chegou ao aparelho do dono"*; e prova-se por **`origin/main` com
a operação fora da lista** e pela suíte verde com prova de árvore própria.

**Aparelhos.** Um só: **`34CC3F94-FDB5-4575-A4F5-80271829A18B`** (teste 3, o de TRABALHO).
Encontrei-o **já ligado** e **deixo ligado**. Build, suíte integral, a corrida de mutação e
as capturas correram nele, sempre por `ferramentas/orca/com-trava.sh`.
**`B91C8DEF` (aparelho da CONTA): NÃO TOQUEI** — nenhum boot, nenhum `simctl` de escrita,
nenhum install, nenhuma sonda, nenhuma leitura de conta. A captura do cartão da Q3-C
(`q3c-01-cartao-com-a-sobra.png`) **não foi refeita**, como a ordem pedia.
**Nenhum terceiro aparelho ligado. Nenhum `orca emulator kill`.**
**Voz, VoiceOver e iPad: nenhum acionado, em momento nenhum.**
**Letra máxima (§12): nenhuma captura, nenhum teste, nenhum portão.** Tudo em `large`.

---

## 1. A mescla — o que conflitou

`git merge --no-ff Vitorepf/q3-c` sobre `origin/main` = `b663efd`, **sem reescrever
história**: os SHA que os relatórios e as ADRs citam continuam alcançáveis.

| SHA | o que é | alcançável de `HEAD` |
|---|---|---|
| `e536503` | PROVA-Q3C, a janela do aparelho da conta | ✓ |
| `319e9a5` | Q3-C, o modelo por operação (ADR 09v) | ✓ |
| `e8205e1` | G3-Q3C, aprovado | ✓ |
| `2448c0a` | Q3-D, o sinal de sobra e o quinto parser (ADR 09w) | ✓ |

**Conflitaram dois arquivos, os dois por ADR apensada no mesmo fim — nenhum código:**

- **`SPEC.md`** — `main` tinha apensado a **09r** (F6, widgets da tela bloqueada) e o meu
  ramo a **09v** e a **09w**, no mesmo ponto do fim. Resolvi ficando com **as três**, na
  ordem cronológica de apensação (09r, depois 09v, depois 09w). Nada foi descartado.
- **`ferramentas/orca/LETRAS-ADR.md`** — o meu ramo dizia *"Próxima livre: 09w"* e não
  tinha a linha da 09w; `main` **já tinha reservado a 09w para a própria Q3-D**, mais a
  09x e a 09y. **A reserva de `main` venceu** (é a que outros workers leem) e a próxima
  livre continuou a que `main` dizia. Conferido: cada letra aparece **uma vez só**.

`EVOLUCAO.md` mesclou sozinho.

---

## 2. As frases do Perfil — antes e depois

O dono mandou a captura das 10h46 e disse a palavra: aquilo é **o nosso jargão na tela
dele**. Duas coisas estavam erradas ao mesmo tempo — a língua, e o fato de o cabeçalho
ficar **falso** depois desta mescla, porque `responderNasNotas` voltou.

### 2a. O cabeçalho e as duas linhas de cima

| | antes | depois |
|---|---|---|
| abre | `Pelo aparelho, sem conta: …` | **`A IA faz por você, no aparelho e sem conta: …`** |
| conta | `Só com a conta Grok: … . `**`Medido em 07/09:`**` nessas, o modelo do aparelho não serviu.` | **`Com a sua conta Grok, ela faz também: … . Nessas, o modelo do aparelho não dá conta sozinho.`** |
| corte 1 | `Indisponível mesmo com a conta Grok — `**`a medida de 08/09 reprovou`**`, e não há outro caminho:` | **`O que ela ainda não faz, nem com a sua conta ligada:`** |
| corte 2 | `Em correção, com conserto nomeado e sem data — `**`a medida de 09/09 reprovou`**`:` | **`Também não faz ainda, e já sabemos o que falta:`** |
| vazio | `Nenhuma operação indisponível por qualidade.` | **`Não há nada que ela deixe de fazer.`** |

A segunda linha é a que mudou de VERDADE: `responder nas Notas` está agora dentro do
*"ela faz também"*. É o cartão dizendo o que a IA faz por ele hoje.

### 2b. As seis que continuam cortadas (a linha da lista)

| operação | antes | depois |
|---|---|---|
| ecos | deixou de fora os vínculos mais úteis | **deixa de fora justamente as notas que mais tinham a ver** |
| calibragem | calou quando não havia erro a apontar | **não diz nada quando você não errou** |
| recordar | entregou a resposta dentro da pergunta | **entrega a resposta junto com a pergunta** |
| responder | inventou cenário que o contexto não sustentava | **inventa uma situação que você não escreveu** |
| instigar | no texto curto, ainda faz perguntas vagas e não pede quando aconteceu | **quando você escreveu pouco, pergunta vago e não pergunta quando aconteceu** |
| contrapor | inventa renda que você não escreveu e às vezes cala onde a nota dá matéria | **inventa uma renda que você não escreveu, e às vezes não responde** |

E o que vinha depois de `· conserto:` — que era o nosso plano de obra escrito na tela dele:

| operação | antes | depois |
|---|---|---|
| responder | o prompt já mata a invenção de número; trocar de modelo não resolve (três medidos, nenhum passou) — falta o prompt impedir também a invenção da **ESTRUTURA** de um documento | **falta ela parar de inventar também a estrutura do documento que você pediu** |
| instigar | no texto curto, a pergunta pede o quê, QUANDO aconteceu e o que seria dar certo; **falta medir** | **falta ela perguntar quando aconteceu mesmo quando você escreveu pouco** |
| contrapor | não atribuir renda que você não escreveu, e nunca devolver vazio quando a resposta veio inteira; **falta medir** | **falta ela não inventar renda sua, e nunca voltar em branco quando tem o que dizer** |

O rótulo `conserto:` caiu junto: a frase já começa em *"falta ela…"*, e esse é o rótulo,
na língua dele.

### 2c. A segunda tela — `Politica.semProvedor`

O coordenador mandou incluir, e a razão é do tamanho do defeito: **o Perfil ele lê quando
vai lá olhar; este aviso ele lê NO MOMENTO EM QUE TOCA A OPERAÇÃO E ELA NÃO ACONTECE.**
É o pior lugar possível para "na medida de 08/09". Deixar as seis para depois seria o
Perfil falando a língua dele e a tela do fracasso ainda falando a nossa.

| operação | o que saiu | o que ficou |
|---|---|---|
| responder | `na medida de 08/09 ela inventou fato que o contexto não sustentava` | `ela ainda inventa uma situação que você não escreveu` |
| ecos | `justamente os vínculos mais úteis quando medimos, em 08/09` | `ainda deixa de fora justamente as notas que mais tinham a ver` |
| calibragem | `na medida de 08/09 ela calou quando não havia erro a apontar` | `ela ainda não diz nada quando você não errou` |
| recordar | `na medida de 08/09 ela entregou a resposta dentro da própria pergunta` | `ela ainda entrega a resposta junto com a pergunta` |
| instigar | `na medida de 10/09, num texto curto, ela fez perguntas vagas…` | `quando você escreveu pouco, ela ainda pergunta vago…` |
| contrapor | `na medida de 10/09 ela inventou renda… e, às vezes, calou onde a sua nota dava matéria` | `ela ainda inventa uma renda que você não escreveu e, às vezes, não responde` |

E a que **voltou**, no molde que veio do G0 da Astra:

> antes: `Responder sobre as suas notas precisa da conta Grok (em Perfil); o modelo do aparelho não citou a nota que sustentava a resposta.`
> **depois: `Responder as perguntas que você deixa nas notas precisa da sua conta Grok (em Perfil).`**

Em nenhuma delas houve promessa nova: **operação que não voltou continua dizendo que não
faz** — só que sem o nosso jargão.

### 2d. O que saiu do CÓDIGO, não só do texto

A data deixou de ter caminho até a tela. `PerfilView.dataDe`, `PerfilView.dia` e o
parâmetro `dataNaLinha` **não existem mais**, e `Reprovada` perdeu o campo `medidaEm`.
`Politica.Linha.medidaEm` **fica** — é o registro, e os testes continuam exigindo que
exista. Morreu a tubulação, não o dado: assim ninguém devolve a data à tela por descuido.
Quatro coisas nomeadas a menos (`dataDe`, `dia`, `dataNaLinha`, `Reprovada.medidaEm`).
O diff líquido dos dois arquivos ainda é **+11 linhas**, e a honestidade é dizer de onde
vem o saldo: das cinco frases nomeadas que o portão precisa LER e dos comentários que
dizem por quê. Máquina saiu; texto e razão entraram.

---

## 3. O portão acompanha, e MORDE

As quatro frases do cartão saíram da `body` e viraram texto nomeado (`oQueAIAFaz`,
`oQueAContaAcrescenta`, `aberturaSemConserto`, `aberturaEmCorrecao`, `nadaCortado`)
**para o teste poder lê-las**. Antes eram literais no meio da view e o portão só sabia
contar linhas — passava idêntico com o texto velho, que é o defeito da V12-E de novo.

Três testes novos, e um deles cobre as DUAS telas:

- `PerfilQualidadeTests` · *"o cartão CONTA não leva data, nem 'medida', nem o nosso plano de obra"* — lê as cinco frases nomeadas **mais as seis linhas renderizadas por `linhaDa`** e recusa `\d\d/\d\d` e onze palavras nossas.
- `PerfilQualidadeTests` · *"as seis linhas cortadas dizem o que acontece com ele"* — uma frase esperada por operação, e os três `conserto` obrigados a começar em `falta ela `.
- `PoliticaTests.oAvisoDaRotaFalaALinguaDoAutor` — o mesmo crivo sobre as **dezesseis** frases de `semProvedor`.

**A prova de que ele acusa** (mutação: cabeçalho velho no cartão + frase velha do
`contrapor` no aviso):

```
✘ Test "o cartão CONTA não leva data, nem 'medida', nem o nosso plano de obra" recorded an issue at PerfilQualidadeTests.swift:54:13:
  Expectation failed: (frase.range(of: #"\d\d/\d\d"#, options: .regularExpression) → 53[utf8] ..< 58[utf8]) == nil
✘ ... PerfilQualidadeTests.swift:60:17: Expectation failed: !((baixo → "indisponível mesmo com a conta grok — a medida de 08/09 reprovou, …").contains(jargao → "medida") → true)
✘ ... PerfilQualidadeTests.swift:60:17: Expectation failed: !(… .contains(jargao → "reprov") → true)
✘ Test oAvisoDaRotaFalaALinguaDoAutor() recorded an issue at PoliticaTests.swift:133:13: Expectation failed: (f.range(of: #"\d\d/\d\d"#…) → 52[utf8] ..< 57[utf8]) == nil
✘ Test oAvisoDaRotaFalaALinguaDoAutor() recorded an issue at PoliticaTests.swift:139:17: Expectation failed: !(… .contains(jargao → "medida") → true)
✘ Test run with 14 tests in 2 suites failed after 0.048 seconds with 5 issues.
```

**E a irmã que não acusa**: com as frases novas, essas mesmas 14 passam, dentro da suíte
integral abaixo.

---

## 4. A suíte — build **LIMPO**, no `34CC3F94`, sob a trava

```
$ ferramentas/orca/com-trava.sh sh -c 'xcodebuild clean -scheme Traco -quiet;
    xcodebuild test -scheme Traco -destination "platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B"'

** TEST SUCCEEDED **
✔ Test run with 1025 tests in 163 suites passed after 145.765 seconds.
```

**Build LIMPO** (`clean` antes), **1 warning**, e é o **herdado** que a ordem já nomeia:

```
Traco/Notas/NotasView.swift:814:30: warning: '+' was deprecated in iOS 26.0
```

**Prova de árvore própria** — a contagem é **1025**, MAIOR que a esperada (não é
contaminação), e as linhas exclusivas do meu candidato aparecem no log:

```
✔ Test todoTetoDoCartaoTemSinalDeSobra() passed after 0.004 seconds.          ← exclusivo da Q3-D
✔ Test oAvisoDaRotaFalaALinguaDoAutor() passed after 0.001 seconds.           ← exclusivo desta volta
✔ Test "o cartão CONTA não leva data, nem 'medida', nem o nosso plano de obra" passed after 0.001 seconds.
✔ Test "a primeira linha do cartão é o que a IA faz, e responder nas Notas está lá" passed after 0.001 seconds.
✔ Test "as seis linhas cortadas dizem o que acontece com ele, não o nosso diagnóstico" passed after 0.001 seconds.
✔ Suite PerfilQualidadeTests passed after 0.003 seconds.
✔ Suite PoliticaTests passed after 0.007 seconds.
✔ Suite RespostaNotasTests passed after 0.029 seconds.   ← o quinto parser, da Q3-D
```

### 4b. Um vermelho que apareceu e NÃO é meu — dito, não escondido

A **primeira** corrida da suíte, na mesma árvore e com o mesmo comando, falhou:

```
✘ Test run with 1025 tests in 163 suites failed after 146.227 seconds with 3 issues.
Failing tests: IndiceTests.oIndiceAproximaESeloTira()
  CicloDaMenteTests.swift:328: Expectation failed: (Indice.quantas → 6) == 2
  CicloDaMenteTests.swift:335: Expectation failed: (Indice.quantas → 5) == 1
  CicloDaMenteTests.swift:337: Expectation failed: (Indice.quantas → 4) == 0
```

A **segunda** corrida, sem uma edição entre as duas, passou. Diagnóstico: **`IndiceTests`
é `.serialized` dentro de si, mas não contra `IntegridadeRotasTests`**, que dirige o MESMO
`Indice` estático (`sincronizar`, `remover`, `apagarTudo`) e roda em paralelo. O `→ 6`
quando se esperava `2` é a soma de execuções que se atropelaram, não um defeito de
conteúdo. Nenhum dos dois arquivos foi tocado por esta mescla
(`git diff --stat b663efd HEAD -- TracoTests/` = só `PoliticaTests` e `RespostaNotasTests`).
**Dívida nomeada, sem dono:** ou `Indice` ganha estado por suíte, ou as duas suítes entram
no mesmo grupo serializado. Não é desta volta consertar; é desta volta DIZER.

### 4c. A corrida FINAL, sobre a árvore exata que foi empurrada

Depois de trazer o `main` das 11h40 (só documentos e scripts — **nenhum arquivo Swift
mudou** lá desde `b663efd`), corri a suíte de novo, do zero, para a árvore verde ser a
árvore empurrada e não uma parecida:

```
✔ Test run with 1025 tests in 163 suites passed after 146.067 seconds.
** TEST SUCCEEDED **
   avisos no build LIMPO: 1 (Traco/Notas/NotasView.swift:814:30, herdado)
✔ Test todoTetoDoCartaoTemSinalDeSobra() passed after 0.004 seconds.
✔ Test oAvisoDaRotaFalaALinguaDoAutor() passed after 0.001 seconds.
✔ Test "o cartão CONTA não leva data, nem 'medida', nem o nosso plano de obra" passed after 0.001 seconds.
✔ Test "a primeira linha do cartão é o que a IA faz, e responder nas Notas está lá" passed after 0.001 seconds.
✔ Test "as seis linhas cortadas dizem o que acontece com ele, não o nosso diagnóstico" passed after 0.001 seconds.
```

`IndiceTests` passou nesta corrida também — a terceira de três, e a segunda seguida.

---

## 4d. O push

Antes de empurrar li a lista inteira, `git log --oneline origin/main..HEAD`: **8 commits**,
nenhum órfão de portão. Quatro são meus (a mescla `--no-ff` da volta, a copy do Perfil, a
mescla do `main` novo e a linha da letra); `319e9a5` (Q3-C) tem o G3 `e8205e1` logo acima;
`2448c0a` (Q3-D) entra por ordem explícita deste despacho, que a nomeia como **bloqueio**
desta mescla; e `e536503` é a prova crua da janela do aparelho da conta, que não se toca.

```
To https://github.com/Vitorepf/traco-ios.git
   aa4d68e..1388c09  HEAD -> main
```

`origin/main` = **`1388c09a0fa9aadbe6e637e9298a2cd29e699786`**, às **11h41 de 10/09**.
Conferido DEPOIS do push, lendo `origin/main`:

- `Politica.linha(.responderNasNotas).regra` é **`.soGrok`** — a operação tem executor;
- a lista de cortadas do portão é **seis**: `ecos`, `calibragem`, `recordar`, `instigar`,
  `contrapor`, `responder`;
- a ADR `2026-09-09z` está no `SPEC.md`, **uma vez só**, e a linha `09z` no `LETRAS-ADR.md`
  também;
- o relatório e a captura da tela viva estão lá.

---

## 5. A tela viva

`ferramentas/orca/q3d-07-perfil-na-lingua-do-autor.png` — Perfil no `34CC3F94`, `light`,
**`content_size large`**, build desta árvore. Na tela, sem data e sem "medida":

> A IA faz por você, no aparelho e sem conta: vestir a forma, reconhecer a forma, o domínio da nota.
> Com a sua conta Grok, ela faz também: preparar versões no Trabalho, preparar exercícios, conferir a sua tentativa, revisar uma versão, **responder nas Notas**, conferir o que voltou, perguntas dos Padrões. Nessas, o modelo do aparelho não dá conta sozinho.
> O que ela ainda não faz, nem com a sua conta ligada:
> a pergunta do Recordar — entrega a resposta junto com a pergunta

**Limite do instrumento, declarado:** as capturas do RESTO da lista (as outras cinco
linhas e o grupo *"Também não faz ainda"*) não saíram. `orca emulator ax` devolveu árvore
vazia neste aparelho e a rolagem por gesto amplifica — dois arrastos viraram gesto de
início e levaram à tela de início. A prova do texto restante é o portão da §3, que lê as
seis linhas pelo mesmo caminho da tela. **A fotografia em `large` no aparelho da CONTA é
do fecho do `responder`, não desta volta** (ordem do coordenador).

**Aparelho ao fim:** `34CC3F94` **ligado**, como o achei; `content_size` de volta em
**`medium`**, conferido pela saída de `xcrun simctl ui … content_size`. Orientação nunca
girada; Movimento Reduzido nunca tocado.

---

## 6. Escopo — o que NÃO fiz, e de quem é

- **`semProvedor` das rotas que TÊM executor** (`produzir`, `conferir`, `padroes`,
  `revisar`, `prepararPratica`): não têm data nem "medida" — passam o portão —, mas ainda
  explicam pelo diagnóstico (*"o modelo do aparelho errou a comparação"*). Dívida nomeada
  na ADR 09z, para a volta que tocar cada uma.
- **`IndiceTests` × `IntegridadeRotasTests`**: a corrida acima, §4b. Sem dono.
- **Prompt, contexto, esquema, teto ou escolha de modelo**: nada mudou aqui. É das voltas
  de IA.
- **A lista de indisponíveis não chegou a ZERO**: caiu de **sete para SEIS**. O que tira
  as outras da lista é medida nova, não texto novo.

---

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | evidência |
|---|---|---|
| Correção | 9 | suíte integral verde sobre build LIMPO, 1025/163, com as linhas exclusivas coladas; o único vermelho visto está diagnosticado como corrida entre duas suítes sobre `Indice`, em arquivos que esta mescla não toca, e reproduzido/derrubado em duas corridas seguidas |
| Contrato/estado honesto | 9 | nenhuma promessa nova: as seis cortadas continuam dizendo que não fazem; `medidaEm` fica no registro e sai só da tela; o cabeçalho deixou de ser falso quando `responderNasNotas` voltou |
| Experiência/copy | 9 | as três telas no mesmo molde (segunda pessoa, presente, efeito para o autor); o cartão abre com o que a IA FAZ; captura em `large` da tela viva |
| Portão | 9 | três testes leem o TEXTO INTEIRO pelo caminho da tela; provado por mutação que caem (5 asserções, 2 suítes) e que passam sem ela |
| Ponytail | 9 | quatro nomes de máquina de data apagados e nenhum substituto; nenhuma abstração nova, nenhum arquivo novo; o saldo de +11 linhas é texto de tela e comentário, e as frases nomeadas existem porque o portão precisa lê-las |
