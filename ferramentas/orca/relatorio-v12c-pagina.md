# Volta 12-C — o fim da lista do Re-G3

Implementador: Claude Opus 5, 06/09/2026. Worktree `volta-12-pagina`, sobre
`69bec69` (sem worktree novo, sem rebase). Simulador: **iPhone 17 Pro
C2416CBC** — o que o orquestrador me deu; nenhum outro foi tocado nem desligado,
e o iPhone 17 do dono não foi tocado. Todo `xcodebuild` por
`ferramentas/orca/com-trava.sh`. **Maestro não rodou**: a lei nova da ESTEIRA
diz que `--device` não isola com vizinhos ligados, e havia cinco simuladores de
pé. Toda prova é `xcrun simctl io screenshot` e `recordVideo` presos ao meu UDID.

Recusa atacada: seção **Re-G3** de `revisao-v12-pagina.md`, três itens — um de
código (Movimento, o resíduo do A1) e dois de texto (Contrato R1, Relato R2).
Nada além disto foi aberto. Em particular **não** desfiz a aresta do aviso nem o
`Trabalhar nisto` fora do menu em AX, que o revisor aprovou.

---

## `design-router` — as seis fases

**1. Ancorar.** Pedido: fechar três itens, não redesenhar tela. Pessoa: o autor
escrevendo com o teclado de pé, no instante em que a forma veste sozinha
(§17.3). Resultado verificável: em nenhum quadro, nos dois modos de movimento,
um pé aparece desenhado sobre o texto do cartão. Plataforma iPhone, pt-BR.

**2. Sistema.** Nada novo. Nenhum token, nenhum componente, nenhuma cor,
nenhuma duração. A correção tira estrutura; não acrescenta vocabulário.

**3. Auditar antes de tocar** (é correção de redesenho, então começa aqui).
Reproduzi o resíduo no meu simulador com o build de `69bec69` instalado, antes
de mexer numa linha, e nos DOIS modos: `v12c-pe-quadros.png` linhas 1 e 2. É a
mesma coisa que o revisor filmou — "Trabalhar nisto", "Analisar Recordar Anexar
Lente" e "Abrir os campos / Deixar como nota" desenhados por cima de "WOOP",
"isto é um desejo com obstáculo" e "Qual é o hábito…", por ≈15 quadros.

**4. Construir.** Uma mudança, num arquivo. Abaixo.

**5. Mover.** A lei da 05y — quem anima é a ALTURA do encaixe, o CONTEÚDO corta
— passou a valer também aqui: o encaixe cresce e revela o cartão, e nada
dissolve. Sob Reduzir Movimento é corte seco.

**6. Julgar e Portão.** São do revisor. Aqui vai a evidência com a lei ao lado.

## `curva-zero` — a jornada que a correção toca

- **Jornada.** O autor escreve na página com o teclado de pé; passados 1,6 s de
  pausa a análise corre sozinha e a forma veste (§17.3). O cartão nasce acima da
  régua; os campos da forma nascem abaixo do texto.
- **Resultado verificável.** O autor continua escrevendo. **O cursor não se
  perde e o teclado não desce** — que é a lei do dono no §3.
- **Atrito observado.** Antes desta correção, vestir a forma DERRUBAVA o foco:
  o teclado descia sozinho, e para voltar a escrever era preciso tocar de novo
  na página. O cruzamento de quadros que o revisor filmou é o sintoma visível do
  mesmo defeito — o autor via o pé duplicado porque a tela inteira estava sendo
  redesenhada noutra geometria.
- **Recuperação.** Inalterada: "Deixar como nota" desfaz a forma sem tocar no
  texto. Nada foi escondido para limpar a tela; o que mudou foi o foco não cair.

---

## Item 1 — MOVIMENTO: a causa era o RAMO, não a transição

O revisor disse "provavelmente um modificador". Não era. Bissectei por
experimento, como no A1, com um build por hipótese e a mesma tira de quadros:

| experimento | o que fiz | fantasma |
|---|---|---|
| E0 | tirei as DUAS `Tema.gaveta` (a de `sessao.cartao` na Página e a de `foco` no Caderno) | **morre** |
| E1 | tirei só a da Página | continua |
| E2 | tirei só a do Caderno | continua |
| E5 | `.transaction { $0.animation = nil }` no corpo (`paginaCaderno`) | continua |
| E3 | tirei o RAMO de `paginaUna` | **morre**, e o teclado deixa de descer |

E0 prova que a animação é o VEÍCULO; E1/E2 provam que não é uma animação
específica; E5 prova que não é o corpo animando. E3 aponta a causa.

**A causa.** `CadernoView.paginaUna` tinha dois ramos — com e sem `abaixo`.
Vestir a forma cria os campos, `abaixo` vira não-nil, o ramo troca e o SwiftUI
recria o EDITOR. O editor recriado perde o foco; o teclado desce; o encaixe
inteiro muda de geometria no mesmo ciclo em que o cartão entra — e, com qualquer
animação em curso, aparece nas DUAS geometrias ao mesmo tempo. Daí o pé do
cartão e o pé da página sobre o texto do cartão.

A V12-B consertou o SINTOMA vizinho (o `.safeAreaInset` pendurado no ramo, que
trocava a árvore do encaixe) e por isso o primeiro par morreu. O ramo continuou
lá; este é o segundo par.

**A correção.** Um ramo só. A diferença entre os dois casos vira VALOR, não
estrutura:

```swift
private func paginaUna(_ una: FatiaCaderno) -> some View {
    GeometryReader { geo in
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                editorUna(una)
                    .padding(.horizontal, Tema.margem)
                    .frame(maxWidth: .infinity,
                           minHeight: abaixo == nil ? geo.size.height : 160,
                           alignment: .topLeading)
                abaixo
            }
            .padding(.bottom, abaixo == nil ? 0 : 28)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
```

Sem campos o editor ocupa a altura do container — o papel inteiro continua alvo
do cursor, como antes. Com campos ele cede o que não usa e os campos entram por
baixo, como antes. O que mudou é que o editor **é o mesmo** nos dois casos.

## Item 2 — CONTRATO (R1): a linha da 05y no `EVOLUCAO.md`

A matriz tinha três afirmações vencidas. As três foram trocadas pelo que a tela
e o instrumento fazem hoje:

| dizia | diz agora |
|---|---|
| "em AX o pé vira um menu só com **'Trabalhar nisto' dentro**" | "em AX o pé tem 'Trabalhar nisto' como BOTÃO e as outras quatro no menu 'Mais ações da nota'", com o motivo da reversão ao lado (as cinco não cabiam — G3 da V12, M3) |
| "suíte **714/0**" | "suíte **718/0** em 125 suítes" |
| "shortstat **líquido-negativo**" | "+62 linhas líquidas de Swift do app (V12 −55, V12-B +108, V12-C +9), portanto **NÃO** cumpre a regra da 05v — exceção aceita pelo orquestrador", com o motivo declarado |

A linha ganhou também o defeito desta correção e o que foi feito com ele, para
que a matriz não fique atrás da ADR outra vez.

## Item 3 — RELATO (R2): os relatos no desenho de hoje

- `relatorio-v12-pagina.md`, curva-zero: "para **um** menu que abre cinco ações"
  virou "'Trabalhar nisto' como botão e as outras quatro no menu", com a nota de
  que a frase antiga descrevia o desenho REVERTIDO pela V12-B.
- `relatorio-v12-pagina.md`, autoavaliação: a mesma correção na linha de
  Simplicidade; e a linha de Correção passou a dizer que 714/0 é **deste commit**
  e que a volta fechou em 718/0.
- `relatorio-v12b-pagina.md`: retirei o "a frase 'cinco ações a um toque' fica de
  pé porque a tela passou a fazê-la". Não fica: em AX só "Trabalhar nisto" está a
  um toque; as outras quatro seguem a dois. A ADR não repete a frase — era o
  relato que exagerava, e agora diz isso no lugar onde exagerava.

Não apaguei nada: requalifiquei no lugar, com ponteiro, que é a escolha que o
revisor aprovou na B2/B3.

## O que fiz além dos três, e por quê

Uma linha, no mesmo `paginaUna` e na `paginaFatias`: `abaixo?.transition(.identity)`.
Com o ramo consertado, o cruzamento do revisor já estava morto — filmei e conferi
antes de tocar nisto. Mas na tira sob Reduzir Movimento os RÓTULOS DOS CAMPOS
ainda nasciam por fade (o `.opacity` padrão do Optional sob a animação em curso),
e a regra desta volta é que sob Reduzir Movimento nada dissolve. Não é frente
nova: é a lei que a própria 05y escreve — o conteúdo corta — aplicada onde
faltava, na mesma função. Está na tira: linha 4, quadros 28→29, os campos entram
inteiros num quadro só.

## Evidência

**Tira de quadros, o que o revisor pediu.** Sete quadros a 30 fps por linha, do
C2416CBC, mesmo roteiro nos quatro:

| arquivo | linha | build | Reduzir Movimento | o que se vê |
|---|---|---|---|---|
| `v12c-pe-quadros-sem-rm.png` | 1 | `69bec69` | desligado | "Trabalhar nisto", "Analisar Recordar Anexar Lente" e "Abrir os campos / Deixar como nota" DESENHADOS SOBRE "isto é um desejo com obstáculo" e "Qual é o hábito…" |
| `v12c-pe-quadros-sem-rm.png` | 2 | **V12-C** | desligado | cada pé aparece UMA vez, sólido e no lugar; o encaixe cresce e revela o cartão |
| `v12c-pe-quadros-com-rm.png` | 1 | `69bec69` | **ligado** | o mesmo cruzamento |
| `v12c-pe-quadros-com-rm.png` | 2 | **V12-C** | **ligado** | corte seco: os campos entram num quadro, o cartão é revelado, nenhum pé sobre o texto |

Em nenhum quadro das linhas do DEPOIS há dois textos legíveis na mesma linha —
que era a prova pedida, literalmente.

**A página vazia não mudou um pixel.** Comparei a captura crua da página em
branco do build `69bec69` com a do build V12-C, 1206×2622, fora da barra de
status: **2 183 px diferentes de 2 945 052**, todos numa caixa de x 938–1072,
y 1673–1714 — que é a faixa de SUGESTÃO do teclado do iOS ("O" contra "Quero"),
não o app. Fora dela, zero. É a prova de que trocar dois ramos por um não mexeu
no leiaute: o papel inteiro continua alto como era. Captura: `v12c-vazia.png`.

**Suíte.**

```
✔ Test run with 718 tests in 125 suites passed after 6.824 seconds.
```

`com-trava.sh xcodebuild test` no C2416CBC, `** TEST SUCCEEDED **`. Os mesmos
718 do V12-B: a correção não pede teste novo nem quebra nenhum. Build limpo em
`derivedDataPath` próprio: **zero avisos**.

**Complexidade.** Swift do app nesta correção: **+19 −10**, das quais **13 das 19
somadas são comentário**. Código sozinho: **+6 −10 = −4** — o código ENCOLHE,
porque a correção tira um ramo. A volta inteira passa a **+62 líquidas** (V12
−55, V12-B +108, V12-C +9), e a linha do `EVOLUCAO.md` diz isso com o motivo.

## Instrumento, e o que ele me custou

Cinco simuladores ligados. Não usei maestro: pela lei nova da ESTEIRA ele não
isola, e hoje isso não foi teoria — a trava do instrumento ficou presa **50
minutos** por um `com-trava.sh maestro` órfão (PID 58540, PPID 1, das 16:40) cujo
driver `xcodebuild test-without-building` pendurava no simulador A1DF082C. O
`trap 'rmdir'` do com-trava só dispara na saída, e a saída nunca veio. Escalei ao
orquestrador com a cadeia de PIDs em vez de matar processo alheio; ele matou e
consertou a causa no `com-trava.sh` (retomada automática acima de 30 min e dono
escrito dentro da trava, commit `a039100` em main). Não trouxe esse merge para
cá: mexeria nos números de shortstat que acabei de escrever na matriz, no meio
de uma revisão.

Toques por `cliclick` com a janela do MEU simulador trazida à frente por
AppleScript, nunca por coordenada às cegas. Uma armadilha para o próximo: o
simulador guarda MODIFICADOR PRESO — um `cliclick kd:cmd,shift` que não fecha
deixa todo texto seguinte virar atalho, e "…manh" acabou em ⌘⇧H, que manda o app
para a tela inicial. Religar o teclado pelo menu I/O limpa o estado; está no
roteiro que usei.

## Autoavaliação — declaração, não veredito

| dimensão | o que sustento | prova |
|---|---|---|
| Movimento | nenhum pé sobre o texto do cartão, nos dois modos; sob Reduzir Movimento os campos entram por corte seco | as duas tiras, linhas do DEPOIS |
| Correção | 718/0 em 125 suítes; zero avisos; a causa achada por bissecção com cinco builds, não por leitura | linha literal + tabela dos experimentos |
| Contrato | ADR 05y ganhou o parágrafo do resíduo; a matriz do `EVOLUCAO.md` deixou de mentir em três pontos | diff dos dois |
| Relato | as duas frases do desenho revertido requalificadas no lugar, com ponteiro; o "fica de pé" retirado | diff dos dois relatos |
| Simplicidade | o código encolhe 4 linhas; nenhum token, componente ou dependência novo | shortstat |
| Estado honesto | a volta é +62 e está escrito assim, com o motivo, onde antes se dizia "líquido-negativo" | linha da matriz |

**O que NÃO sustento, declarado.** Não rodei maestro nem varredura: com cinco
simuladores de pé ela não vale como portão, e a lei da ESTEIRA diz isso. Não
provei VoiceOver falado — continua exigindo humano em aparelho real. Não medi
desempenho: o `GeometryReader` novo é um por página e não entra em lista nem em
laço, mas medida não houve.
