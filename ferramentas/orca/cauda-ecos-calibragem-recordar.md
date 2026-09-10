# A CAUDA — `ecos`, `calibragem`, `recordar`

10/09/2026 · worktree `q3-c`, sobre `main` em `6943b3e` · ADR **2026-09-10h**

| operação | veredito |
|---|---|
| **`ecos`** | **FICA — razão CONFIRMADA, e precisa de janela.** A contagem de 08/09 fecha; a CAUSA é **NÃO VERIFICÁVEL** sem o bruto. |
| **`calibragem`** | **FICA — e a razão é OUTRA na metade.** 1 dos 6 casos nunca chegou ao provedor. Só 1 dos 6 é qualidade de IA. |
| **`recordar`** | **FICA — e a razão é OUTRA. A tela nomeava o defeito OPOSTO.** Corrigida em dois sítios. |

Nenhuma volta ao Perfil. A §13 continua com seis indisponíveis — mas agora as
três dizem a verdade, e duas delas apontam para **nós**, não para a IA.

Tudo abaixo saiu de **leitura**, sobre a corrida de 08/09 já no repositório.
Nenhuma janela de aparelho de conta foi aberta, nenhum `B91C8DEF`/`34CC3F94`
tocado. O único aparelho usado foi o de suíte (`A1DF082C`, teste 4).

---

## 1. `ecos` — a razão vale; a suspeita da tesoura não se pode resolver hoje

**A releitura confirma a contagem de 08/09: 3 de 6 reprovam.**

| caso | o que a fixture exige | o que voltou (3 rep.) | |
|---|---|---|---|
| `q5-ecos-sentido-e-contradicao` | exatamente 0 e 2 | 0+2 / **só 0** / 0+2 | ✗ 1 de 3 |
| `q5-ecos-coincidencia-lexical` | **`[]` é o correto** | `[]` 3 de 3 | ✓ |
| `qn-ecos-sem-relacao-legitima` | **vazio é o correto** | `[]` 3 de 3 | ✓ |
| `qn-ecos-relacao-por-consequencia` | ao menos 0 e 2 | `[]` 3 de 3 | ✗ |
| `qn-ecos-duas-relacoes-e-distratores` | exatamente 0 e 2 | 0+2 3 de 3 | ✓ |
| `qn-ecos-nota-curta` | ao menos 0 e 2 | `[]` 3 de 3 | ✗ |

O caso citado na `Politica` — «18 inscritos contra a sala que comporta 15» — é o
`relacao-por-consequencia`, e volta vazio nas três. **A frase da tela está certa.**

**Sobre a suspeita da tesoura: NÃO VERIFICÁVEL, e isto é o veredito, não uma
evasiva.** `prova/q-qualidade-avaliacoes.jsonl` é de 08/09 e o `Grok.Diagnostico.bruto`
nasceu na 10b: **zero ocorrências de `bruto`/`retornoBruto` no arquivo inteiro.**
Sem o retorno do modelo, `{"ecos": []}` vindo do modelo e uma lista **derrubada**
por nós são o mesmo registro. *Zero só vale se havia o que ver — e não havia.*

A tesoura **existe** e é silenciosa: `Sabia.parseEcos` exige que o `trecho` seja
substring literal da candidata (`candidatas[i].lowercased().contains(...)`), e o
que não casa cai num `continue` **sem rastro**; se cair tudo, sai `[]` — não `nil`.
Acento perdido basta, e a linha do `instigar` já registra o Grok a escrever
«metodo» sem acento.

**O indício disponível vai CONTRA a tesoura**, e é honesto dizê-lo: nas
repetições em que houve vínculo, os 6 trechos vieram literais e passaram. Um
modelo que copia certo quando acha não falharia a literalidade só nos dois casos
vazios, nas três repetições, com consistência perfeita. Isso é assinatura de
decisão semântica. **Mas indício não é fato — foi exatamente isso que o `bruto`
veio corrigir.**

**Peço janela** (não abri): remedir `ecos`, 6 casos × 3, **com o bruto** e nos
**dois modelos** — é o desenho que fez o `responderNasNotas` voltar com o 4.5.
Ela responde duas perguntas de uma vez: se o vazio é nosso, e se um modelo mais
novo já o resolve. **Não abro sem a sua palavra.**

---

## 2. `calibragem` — a conta que separa as duas metades

A razão dizia: *«o Grok cala quando não há erro a apontar **e a rota nem chega ao
provedor com um par só**»*. A segunda metade está certa, e **não é qualidade de IA.**

**Morreu na NOSSA porta: 1 de 6.** `qn-calibragem-par-unico` tem
`chamadasGrok: []` — **zero chamadas HTTP**, nas 3 repetições. A causa está no
código, deliberada e comentada: `Sabia.lerCalibragem` abre com
`guard pares.count >= 2` — *«um par não é padrão: com menos de dois, a leitura
seria adivinhação»*. **O autor com um par só nunca teve IA nenhuma**, e nenhum
conserto de pedido muda isso.

**Chegaram ao modelo: 5 de 6** — todas `conteúdo completo`, HTTP 200, nas 15
execuções.

**Qualidade de IA de verdade: 1 de 6.** `qn-calibragem-previsao-acertada` volta
`[]` 3 de 3 onde o requisito **exige** pergunta — calou sobre o que sustentou os
acertos. `q5-calibragem-sem-atraso` também volta `[]` 3 de 3, mas ali o requisito
**aceita** vazio: **passa**. Os requisitos objetivos (≤280 caracteres, ≤2 frases,
termina em `?`) passam em **todas** as perguntas devolvidas.

**Quem conserta:** quem decidir o **contrato do par único** — o código diz «dois
ou nada» e o caso da fixture (autorado nesta corrida, e mais novo) exige resposta
com um. Não é defeito de ninguém até essa decisão; é uma discordância. **Não a
tomei por você.**

**Dívida que fica nomeada:** a frase da tela — «não diz nada quando você não
errou» — descreve corretamente a metade de IA, e por isso **não a mudei**. Mas se
a `calibragem` voltar sem decidir o par único, **o autor com um par só continua
sem IA e nada na tela lho diz.**

---

## 3. `recordar` — a tela nomeava o defeito oposto ao que mais reprova

A tela dizia: *«ela ainda entrega a resposta junto com a pergunta»*. Os dados
dizem sobretudo o **contrário**: em **5 das 18 execuções não veio pergunta
nenhuma**, porque a **nossa** guarda derrubou a que estava certa.

| caso | o que voltou |
|---|---|
| `qn-recordar-alvo-longo` | `nil` **3 de 3** |
| `q5-recordar-capital-lisboa` | `nil`, `nil`, **«Qual é o nome da capital portuguesa?»** |

A repetição que passou é a que escreveu «capital **portuguesa**» em vez de
«capital **de Portugal**». **Reproduzi a régua fora do app** (`Prova.vazamento`:
4-gramas contíguos, normalizados sem acento nem pontuação):

```
alvo «A capital de Portugal é Lisboa.»
  «Qual é a capital de Portugal?»                → DERRUBADA por «a capital de portugal»
  «Qual é o nome da capital portuguesa?»         → passa
alvo «A sala 7 comporta no máximo 15 pessoas.»
  «Por que o limite de ocupação é exatamente 15?» → PASSA
```

**A pergunta perfeita — que não revela Lisboa — é derrubada. A que entrega o `15`
passa.** A régua erra nos dois sentidos, pela mesma causa: **quatro palavras
seguidas não medem «revela a resposta»**. Num alvo longo há mais 4-gramas, logo
mais falsos positivos — é por isso que `alvo-longo` falha 3 de 3.

O vazamento **também** existe, e esse é do modelo: `qn-recordar-degrau-avancado`
entrega o `15` em 2 de 3. **Mas a guarda não o pega**, e era o único defeito que
a tela nomeava.

**A frase mentia em DOIS sítios** — e o segundo é o pior, porque o autor o lê **no
momento em que toca e nada acontece**. Corrigi os dois:

- `Politica.linha(.recordar).motivo` (lista do Perfil)
- `Politica.semProvedor(.recordar)` (aviso da rota)

> «A pergunta do Recordar pela IA está indisponível: **muitas vezes ela ainda não
> devolve pergunta nenhuma e, quando devolve, já entrega a resposta.** O ritual
> segue com a pergunta fixa.»

Sem data, sem «medida», sem jargão nosso; passa o portão da língua (`09z`). Os
dois defeitos, na ordem em que reprovam.

**Quem conserta:** é **nosso**, e vem primeiro — a régua tem de olhar o **alvo da
recuperação**, não o enunciado inteiro. **Não o implementei**: `Prova.vaza`
guarda também `PraticaTrabalho` (ADR 08p), mexer nela sem medida troca um falso
positivo por um falso negativo, e falso negativo aqui **vaza a resposta ao
autor**. Por isso a tela **não promete volta** (`conserto: nil`).

---

## 4. O defeito confirmado, e fechado

`Politica.swift` citava **`prova/q-qualidade.md` cinco vezes**, e esse arquivo
não existe — nem hoje, nem no histórico. O real é `ferramentas/orca/q-qualidade.md`.
Alguém já tinha tropeçado: `consulta-q2-responder.md:66` — *«`prova/q-qualidade.md`
está ausente; usei `ferramentas/orca/q-qualidade.md`»* — e ninguém corrigiu a fonte.

**As cinco corrigidas.** Varri os 15 caminhos citados pela tabela: **era o único órfão.**

**`TracoTests/PortaoDaProvaQueAbreTests.swift`** fica vermelho se alguém citar
caminho de prova que não abre. Com as duas guardas que a casa aprendeu:

- **sonda de lista vazia** (`unicos.count >= 12`) — uma regex quebrada deixaria a
  varredura vazia e **verde**;
- **a irmã que NÃO acusa** — um segundo teste confirma que o caminho falso é
  colhido pela regex **e** não existe; sem ele, um `fileExists` sempre-verdadeiro
  passaria para sempre.

---

## O que ficou de fora, e por quê

1. **A causa do vazio do `ecos`.** Precisa do bruto. **Peço a janela; não a abri.**
2. **O conserto da régua do `Prova.vaza`.** Nomeado, não escrito: sem medida,
   trocaria falso positivo por vazamento real. Precisa de janela própria.
3. **O contrato do par único da `calibragem`.** É decisão sua, não minha.
4. **Pertinência dos 3 casos da `calibragem` que devolveram perguntas.** Os
   requisitos objetivos passam todos; «sem diagnóstico, sem nota» é julgamento e
   **não o reauditei** — por isso não disputo o «no máximo 3 de 6» da linha velha.
5. **`Traco/Analise/Sabia.swift` não foi tocado** — duas voltas medem com ele.
   Li-o; `parseEcos` e `lerCalibragem` estão **citados**, não alterados.

## Nota de processo, contra mim

A reserva da letra `10h` foi empurrada com `git add -A`, e levou junto as cinco
citações corrigidas e o portão novo — conteúdo correto e completo, mas sob uma
mensagem que só fala da letra, e antes de a suíte correr. Não reescrevi `main`
(história reescrita invalida referência alheia). Fica dito aqui em vez de
descoberto depois.
