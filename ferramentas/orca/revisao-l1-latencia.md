# Revisão G3 — volta L1, a latência da descoberta

Revisor independente (Claude Opus 5), 06/09/2026, worktree `volta-l1-latencia`,
commit `bfe3130`. **Não editei nem commitei nada** do trabalho revisado.
Meu simulador: iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980` — eu o
liguei e eu o desliguei. O iPhone 17 do dono (`1A46B6D3`) não foi tocado e não
esteve ligado em nenhum momento desta revisão.

## Veredito

**CORRIGIR ANTES.** Três achados altos, todos reproduzidos na tela por
`xcrun simctl io screenshot` do meu próprio UDID, nenhum deles de estilo.

O motor está certo, a aritmética está certa, o texto está na voz da casa e a
ideia do dono foi lida com fidelidade rara: nenhum campo novo nasceu, a data da
descoberta saiu mesmo do histórico `Versoes` e não de `editadaEm`, "tempo
desconhecido" não inventa nada, e a seção não pede um passo ao autor. O que
falha não é o cálculo: é o **portão que a seção não atravessou**. Uma superfície
nova de leitura foi aberta sobre o conteúdo do Trabalho **sem o gate de acesso
que todas as outras dez superfícies usam**, e o corte da lista pode apagar todos
os fechados e deixar na tela só a fila de dívidas — que é exatamente o modo de
falha que o dono escreveu com as próprias palavras.

---

## Achados por severidade

### ALTO 1 — o selo do Trabalho não vale na latência: hipótese de trabalho protegido aparece no Perfil

`PerfilView.lerLatencia()` (`Traco/Perfil/PerfilView.swift:203-206`):

```swift
for t in trabalhos {
    guard let doc = try? t.ler() else { continue }
    registros += Latencia.registros(hipoteses: doc.hipoteses, encerrado: doc.encerrado)
}
```

Não há `AcessoTrabalho.permitido(t, no: context)`. `AcessoTrabalho` diz de si
mesmo, no cabeçalho, que "**toda superfície** usa o mesmo resultado antes de
expor" — e é verdade em todas menos nesta: `TrabalhosView` (busca e lista),
`CalendarioView`, `CalendarioTrabalho`, `PaginaView`, `Entidades` (Siri/Atalhos),
`IntercambioTrabalhoView`, `OficinaTrabalho` — dez chamadas, todas gateando.
`lerLatencia` é a única leitora de conteúdo de `Trabalho` que não gateia.

Consequência: um Trabalho nascido de uma nota que o autor depois **trancou,
queimou ou marcou como expressiva** desaparece da lista de Trabalhos, do
calendário, da página e dos Atalhos — e continua imprimindo **o texto literal da
hipótese** no Perfil.

**Prova na tela:** `ferramentas/orca/l1-rev-selo-vazado.png`, primeira linha do
bloco de registros:

```
afirmado · em aberto há 88 dias
SEGREDO SELADO: a hipotese do trabalho protegido
```

Semeado no formato do próprio app (`notaOrigemID` no `DocumentoTrabalho`, que é
justamente o campo que `AcessoTrabalho.Vinculo` decodifica; nota de origem com
`ZTRANCADA=1`). O gate, se fosse chamado, devolveria `.restrito(.origemProtegida)`.

Isto contradiz a própria ADR 06j, que declara "a latência não abre rota nova
para o que o selo fechou". Abre. O cuidado foi tomado no caminho da **Nota**
(`Latencia.registro(decisao:)` zera o `texto` quando `fechada`) e esquecido
inteiro no caminho do **Trabalho**.

Dimensão derrubada: **Privacidade e autoria**.

---

### ALTO 2 — o corte de 12 pode apagar todos os fechados e deixar só a fila de dívidas

`PerfilView.registrosDaLatencia`:

```swift
let lista = s.abertos + s.semData + s.descobertos.reversed().prefix(4) + s.abandonados
ForEach(Array(lista.prefix(12))) { ... }
```

Os abertos vêm primeiro e o corte é no fim. Com 12 ou mais abertos, **nenhum
`descoberto` e nenhum `abandonado` sobrevive ao corte**: as doze linhas da tela
viram doze contadores de dias em aberto, do mais velho para o mais novo.

**Prova na tela:** `ferramentas/orca/l1-rev-muitos-abertos.png`, com 17 abertos:

```
afirmado · em aberto há 96 dias
afirmado · em aberto há 95 dias
afirmado · em aberto há 94 dias
...   (doze linhas, todas iguais, nenhuma descoberta, nenhum abandono)
```

Isto não é um caso de laboratório: hipótese só fecha quando o autor a avalia, e
o autor que usa o Trabalho acumula abertas mais rápido do que as fecha — o
aparelho do dono é o candidato mais provável a essa tela. A volta é declarada
como sendo contra o viés de sobrevivência ("os abertos ao lado dos fechados") e
o corte produz o viés espelhado: só os abertos, nenhum fechado.

E é o modo de falha que o dono nomeou com estas palavras: *"Se a tela fizer o
autor se sentir devendo, a volta não passa, por mais correto que o número
esteja."* Doze linhas de "em aberto há 96 dias" fazem exatamente isso.

Atenuante honesto: a linha de resumo e o gráfico por mês continuam corretos e
continuam contando os fechados. O que se perde é a lista, que é o que o olho lê.

O conserto é pequeno e não é meu para fazer: cortar **por estado** (por exemplo
4 abertos + os sem data + 4 descobertos + 2 abandonados), que é o que a própria
ADR diz que a seção faz.

Dimensão derrubada: **Estado honesto**.

---

### ALTO 3 — a autoria da hipótese se perde, sob uma frase que diz "você afirmar"

`Hipotese.propostaPor` existe desde a ADR 05r, e a mesma ADR escreve a regra:
*"registro antigo fica com autoria DESCONHECIDA, não reconstruída"*. A
`TrabalhoView` obedece, sempre, em toda hipótese:

```swift
Text("Proposta por \(h.propostaPor ?? "autoria desconhecida") · ...")   // TrabalhoView.swift:284
```

`Latencia.registros` descarta `propostaPor`. E a frase de abertura da seção diz
"Quanto tempo passa entre **você afirmar** uma coisa e saber se estava certa."

**Prova na tela:** `ferramentas/orca/l1-rev-autoria-perdida.png`:

```
afirmado · em aberto há 86 dias
registro antigo: propostaPor AUSENTE

afirmado · em aberto há 83 dias
hipotese proposta por Grok, nao pelo autor
```

As duas aparecem idênticas às do autor, sem marca nenhuma, e cada uma com um
contador de dias crescendo ao lado. O app diz ao autor que ele afirmou uma coisa
que pode não ser dele, e ainda mede há quanto tempo ele deve por ela.

Hoje nenhuma rota do app grava `propostaPor` diferente de `"Você"` — o risco
vivo é o **registro antigo, anterior à 05r, com `propostaPor` nulo**, e esse
registro existe precisamente no aparelho do dono, que é o aparelho para o qual
esta volta foi feita. A 05r criou "autoria desconhecida" por causa dele.

Dimensão derrubada junto com o ALTO 1: **Privacidade e autoria**.

---

### MÉDIO 4 — a nota selada entra pela MEDIDA, não só pela contagem, e a citação de 05s não confere

A ADR 06j escreve: "**Selo:** nota trancada ou queimada entra pela CONTAGEM e
nunca pelo conteúdo (05s)". Procurei essa regra na 05s: a 05s é a ADR do *commit
antes do anúncio* e não a enuncia. A única regra escrita em SPEC.md sobre selo e
contagem é a do retrato (linha 1400), e ela diz o **contrário**:

> "nada de expressiva, trancada ou queimada entra no retrato, **nem como
> contagem**."

E o retrato é o cartão **imediatamente acima** da latência, na mesma tela.

O comportamento real, medido: uma Decisão trancada continua contribuindo com a
sua latência para a série. Semeei a decisão respondida como `ZTRANCADA=1` e o
resumo passou de "7 descobertas · a do meio levou 9 dias" para "9 descobertas ·
a do meio levou 20 dias", julho de 3 para 5 descobertas — a selada continua nos
27 dias dela (`ferramentas/orca/l1-rev-autoria-e-selo.png`).

Conteúdo **não** vaza por esta rota — `texto` é zerado e a data do "espero"
nunca chega à tela para nota fechada, porque fechada só cai em `abandonado` ou
`descoberto`. Então não é o ALTO 1. Mas: (a) a política é mais frouxa que a do
vizinho na mesma tela, e (b) uma duração medida a partir do conteúdo selado é
mais do que uma contagem. Isto é decisão do dono, não minha — só não pode ficar
apoiada numa citação que não existe.

---

### MÉDIO 5 — a barra é normalizada pelo pior mês, e o pior mês é sempre 100%

`barraDoMes(Double(m.mediana) / Double(maior))`, com `maior = max(mediana)`.
Conferi a proporção por pixel na minha própria captura, e ela é honesta: julho
mede **43,0 %** da pista para 21/49 = 42,9 %. Não há cor, meta, seta, sequência,
nem ação — a busca pelo placar disfarçado não achou placar, e nisso o worker
está certo.

O que a barra tem é outra coisa: **não tem escala**. O mesmo julho de 21 dias
encolhe ou cresce na tela conforme o pior mês da série muda, então duas capturas
tiradas em meses diferentes não são comparáveis entre si, e a série com um mês
ruim recente achata todos os outros. Não derruba dimensão; é observação para o
dono decidir se quer uma pista fixa (por exemplo, o maior de sempre) ou nenhuma
barra.

---

### BAIXO 6 — a regressão dos fluxos do Perfil não estava provada (mas não há regressão)

Doze fluxos maestro tocam o Perfil (`grep -l aba-perfil maestro/`); o relato do
worker prova **um**, o `latencia.yaml`. Rodei cinco:

| fluxo | L1 | main (construída de `git archive main`) |
|---|---|---|
| `perfil.yaml` | passa | — |
| `perfil-sabia.yaml` | falha em `assertVisible "O que o Traço registrou…"` | **falha igual** |
| `degrau-no-perfil.yaml` | falha em `.*WOOP no degrau 1.*` | **falha igual** |
| `sinal-solto.yaml` | falha em `id: soltar-forma` | **falha igual** |
| `cenarios/abas-rapidas.yaml` | falha em `"base"` | **falha igual** |

Construí a main num diretório de raspa e rodei os mesmos quatro fluxos no mesmo
simulador, na mesma sessão: **assinatura de falha idêntica, comando por comando.**
Logo, **zero regressão atribuível à L1** — e main tem quatro fluxos do Perfil
vermelhos nesta máquina hoje. A ESTEIRA (§ "Lei do instrumento") diz que com
mais de um simulador ligado nenhuma nota se apoia em maestro, e havia cinco;
tratei como instrumento, não descontei nota da L1, e o repasse para o
orquestrador é: **alguém precisa rodar a varredura do Perfil numa máquina com um
simulador só**, porque ninguém sabe hoje se esses quatro estão vermelhos por
instrumento ou por dívida de main.

Reproduzi também, no meu UDID e por captura própria, tudo que o worker afirma:
o `latencia.yaml` passa comando a comando, a série 21→4→49 é a que ele descreve,
e o "tempo desconhecido" aparece (`l1-rev-tempo-desconhecido.png`).

---

## As sete perguntas do dono, respondidas

**1. Os quatro estados são distintos e nenhum é falha?** Distintos, sim, e
provados numa captura só (`l1-rev-tempo-desconhecido.png`): *afirmado*,
*devido*, *descoberto*, *abandonado*, cada um com a sua medida própria, e
"abandonado · fechado sem conferir" escrito sem uma vírgula de reprovação. A
frase de abertura diz "Hipótese sem resposta é informação, e abandonar é
resultado" — a palavra do dono, na tela. **Mas a tela pode, sim, fazer o autor
se sentir devendo**, pelo ALTO 2: quando os abertos passam de doze, a lista
inteira vira dívida com contador. É por isso, e só por isso, que este item não
passa.

**2. Não virou placar?** Procurei o placar disfarçado e não achei: sem meta, sem
sequência, sem XP, sem seta, sem verde e vermelho, sem "melhorou/piorou", sem
ação nenhuma no cartão — nem um botão "conferir agora", que teria sido o erro
fácil. A barra é uma tinta só em todos os meses e a proporção confere no pixel.
A palavra "mediana" ficou de fora e a tela diz "o tempo do meio". Aprovado, com
a ressalva 5 (barra sem escala).

**3. "Tempo desconhecido" sem inventar?** Reproduzido: `descoberto · tempo
desconhecido` para a hipótese avaliada antes da 05r, e a decisão respondida sem
histórico também não ganha data. Nenhuma dedução em nenhum dos dois. Aprovado.

**4. Os abertos ao lado dos fechados?** Estão, e vêm primeiro na lista, o que é
a escolha certa contra o viés de sobrevivência. Não é linha escondida: são as
primeiras linhas do bloco. **Mas o corte de 12 inverte o viés** (ALTO 2).

**5. A semeadura é limite ou desculpa? — É limite, com uma pendência que não é.**
Confirmei que o semeador escreve pelos formatos do próprio app, não por um
formato paralelo: `Versoes` grava e lê ISO-8601 nas duas pontas
(`Versoes.swift:27,56`) e o semeador escreve ISO; `notaOrigemID` é o campo real
de `DocumentoTrabalho`; as tabelas e colunas são as do SwiftData do app. A prova
disso é indireta e boa: a decisão respondida só entra na série se o JSON de
versões decodificar, e ela entra — os 27 dias dela estão na mediana de julho.
O simulador não viaja no tempo, e a série de meses do dono só existe no aparelho
dele: nisso o worker tem razão e escreveu o limite em três lugares, sem esconder.

O que **não** é limite: ninguém provou o ciclo *escrever pelo app → ler na
latência*. Nenhuma hipótese foi criada pela tela do Trabalho, avaliada pela tela
e vista aparecer aqui como "descoberto · menos de um dia". Isso não precisa de
viagem no tempo, custa um fluxo maestro, e é o que fecha a circularidade de o
semeador e o leitor terem sido escritos pela mesma mão na mesma tarde.
**Pendente para o portão:** esse ida-e-volta pelo app. **Pendente para o dono,
que só ele pode fazer:** a série real dele, no aparelho dele.

**6. `curva-zero` — o autor ganha sem fazer nada a mais?** Ganha. Zero campo,
zero decisão, zero confirmação, zero passo que possa falhar: abrir o Perfil,
rolar, ler. A frase da tela responde a pergunta literalmente ("não há nada a
preencher aqui"). O vazio é desenhado e diz de onde a série viria em vez de
culpar quem não tem dados — conferido na tela com estado limpo
(`l1-rev-vazio.png`), e na voz idêntica à do cartão vizinho. As quatro citações
que a skill exige (jornada, resultado verificável, atrito observado,
recuperação) estão no relato e todas se sustentam contra a tela.

**7. As seis fases do `design-router`, contra a tela.** Citadas e verificadas uma
a uma, não aceitas pela menção:
- *Ancorar* — o cartão está onde a ADR diz, logo depois de "A SÁBIA E VOCÊ", e a
  vizinhança se vê na captura do vazio: mesma família, mesma voz de contagem.
- *Sistema* — **zero token novo, confirmado no diff**: `Tema.swift` não aparece
  na lista de arquivos alterados, e o código só usa `Tema.chrome`, `miudo`,
  `tinta`, `tintaSuave`, `tintaFraca`, `superficieBaixa`, `entreItens`, mais o
  `rotulo()` e o `emCartao()` que o Perfil já tinha.
- *Construir* — a alegação "cada linha é um `Text` que quebra sozinho, nenhum
  `HStack`" confere no código e na tela: em AX5 tudo reflui e nada é cortado
  (`l1-serie-ax5.png`, `l1-tempo-desconhecido-ax5.png`, ambas reais e distintas).
- *Mover* — nenhuma animação, confirmado no código; sob Reduzir Movimento não há
  o que cortar. Honesto: é ausência declarada, não trabalho não feito.
- *Julgar* — quatro capturas reais, conteúdo conferido por mim (não só o
  arquivo): large e AX5, série e tempo desconhecido, nenhuma duplicada.
- *Portão* — `maestro/latencia.yaml` existe, roda e passa comando a comando no
  meu UDID; a prova de tela é `simctl`, como a lei manda.

Ressalva: o Perfil é a tela que a auditoria V9 pontuou 7,7 com Simplicidade 6, e
esta volta acrescentou um cartão a ela sem passar pela fase de auditar antes de
tocar. Não é redesenho, então a skill não obriga — mas o Perfil ficou mais longo
de novo, e isso é assunto para a próxima volta que o tocar.

---

## Scorecard — 15 dimensões

| dimensão | nota | evidência |
|---|---|---|
| Visão | **10** | Ciclo MELHORAR, lacuna "modelo revisável do autor" nomeada e o diff do EVOLUCAO a atualiza. Mede a capacidade que a conversa de origem identificou, e não uso, sequência nem quantidade — a visão é respeitada onde é mais fácil traí-la. |
| Contrato | **8** | ADR 06j curta, específica e coerente com o código quase inteiro; EVOLUCAO e SPEC batem. **Desconto:** a linha do Selo cita a 05s por uma regra que a 05s não contém, e a única regra escrita em SPEC (linha 1400) diz o oposto (MÉDIO 4); e a ADR afirma que a latência "não abre rota nova para o que o selo fechou" — abre (ALTO 1). |
| Correção | **9** | `xcodebuild test` por mim, sob `com-trava.sh`, no meu UDID: `Test run with 758 tests in 129 suites passed`, `** TEST SUCCEEDED **`, exit 0. `LatenciaTests`: 11 testes, contados um a um no log. Zero aviso novo (os 4 do log são pré-existentes, em `ConferenciaTrabalhoTests`). Sem regressão: os quatro fluxos vermelhos do Perfil falham **idêntico em main**, provado com build de `git archive main`. |
| Jornada real | **9** | Reproduzi na minha tela: série, tempo desconhecido, vazio, AX5. As quatro capturas do worker são reais, distintas e o conteúdo confere com o que ele afirma. **Falta:** o estado de falha (`t.ler()` que lança) e o de muitos-abertos não foram capturados por ele — eu capturei o segundo, e ele é um achado. |
| Design | **9** | Seis fases conferidas contra a tela, uma a uma (item 7 acima). Zero token novo, `Tema.swift` intocado, nada solto. Ressalva do Perfil que cresce, sem desconto. |
| Simplicidade | **9** | `curva-zero` citada com as quatro exigências e todas se sustentam: nenhuma decisão, nenhum campo, nenhum passo novo; o vazio recupera sem culpar. O autor ganha sem fazer nada a mais. |
| Movimento | **n/a** | Não há animação nenhuma na seção, e é escolha declarada, não omissão: leitura estática, nada a interromper, nada a cortar sob Reduzir Movimento. |
| Componentes | **n/a** | Nada foi para `Traco/Componentes` e nada deveria: a barra do mês é quatro linhas dentro da própria view e não tem segundo uso. Extrair um componente para um uso só seria o erro oposto. |
| Acessibilidade | **9** | AX5 conferido nas capturas do worker e reproduzido: tudo reflui, nada é cortado, nada estoura na horizontal. A barra é `accessibilityHidden` (ela não diz nada que a linha de texto já não diga) e cada linha é `accessibilityElement(children: .combine)`. **Não medido:** VoiceOver real ligado — o worker declara isso, não o esconde. |
| Performance | **9** | `Versoes.listar` uma vez por decisão mais um `t.ler()` por trabalho, síncronos na main, ao abrir o Perfil. Custo declarado na ADR com o caminho de saída nomeado. Não medi com Instruments; com dezenas de notas o Perfil abriu sem hitch visível nas minhas cinco navegações. Se a lista de notas do dono for grande, isto merece medida — não é achado, é vigilância. |
| Privacidade e autoria | **4** | **ALTO 1** (`l1-rev-selo-vazado.png`): hipótese de Trabalho com origem selada impressa literalmente no Perfil, sem `AcessoTrabalho`, sozinha entre onze superfícies. **ALTO 3** (`l1-rev-autoria-perdida.png`): `propostaPor` descartada sob uma frase que diz "você afirmar", contra a regra que a própria 05r escreveu. **MÉDIO 4**: selada entra pela medida. |
| Estado honesto | **6** | Os quatro estados são distintos, nenhum é rotulado como falha, "abandonado" é dito com essa palavra e "tempo desconhecido" não inventa — tudo isso está certo e é o melhor da volta. **ALTO 2** (`l1-rev-muitos-abertos.png`) derruba: com doze ou mais abertos a tela vira uma fila de doze dívidas com contador e nenhum fechado sobrevive, que é o modo de falha que o dono nomeou. |
| Complexidade | **10** | +496 linhas em 3 arquivos de código e teste, zero remoção, zero dependência, **zero campo novo no modelo** — e o campo novo era o caminho óbvio. Confirmei por grep a alegação de motor sem superfície: antes desta volta o único leitor de `avaliadaEm` no app era `TrabalhoView.swift:305`. O `pbxproj` recebeu só as quatro entradas dos dois arquivos. |
| Fora do app | **n/a** | A volta não tem superfície fora do app: nem widget, nem Ilha, nem StandBy, nem Atalhos. |
| Relato | **10** | `l1-latencia.md` é legível por quem não abre terminal, separa o que foi provado do que não foi, e a seção "Limites, ditos e não escondidos" antecipa quatro das minhas perguntas antes de eu as fazer — inclusive a da semeadura. Nenhum número do relato divergiu do que eu medi. |

**Abaixo de 9:** Privacidade e autoria (4), Estado honesto (6), Contrato (8).
**Veredito: CORRIGIR ANTES.**

---

## O que consertar, na ordem

1. **`lerLatencia` passa por `AcessoTrabalho.permitido`** antes de ler o
   documento — uma linha, no molde de `TrabalhosView:19`. (ALTO 1)
2. **Cortar a lista por estado**, não no total: o cartão promete "os abertos ao
   lado dos fechados" e precisa cumprir a promessa no pior caso, não só no bom.
   (ALTO 2)
3. **Levar `propostaPor` junto** e imprimi-la como a `TrabalhoView` imprime, com
   "autoria desconhecida" para o registro antigo — ou, se a seção é só do que o
   autor afirmou, filtrar. Qualquer das duas; a atual não é nenhuma. (ALTO 3)
4. **Corrigir a citação do Selo na ADR** e decidir, com o dono, se uma latência
   medida a partir de nota selada é "contagem" — o retrato, no cartão de cima,
   diz que nem contagem entra. (MÉDIO 4)

## Pendências que não são conserto

- **A série real do dono, no aparelho dele.** Só ele pode. O que existe hoje
  prova o motor e a tela, não a série dele.
- **Um ida-e-volta pelo próprio app**: criar uma hipótese pela tela do Trabalho,
  avaliá-la, e vê-la aparecer aqui. Fecha a circularidade semeador/leitor e não
  precisa de viagem no tempo.
- **Varredura do Perfil numa máquina com um simulador só**: quatro fluxos estão
  vermelhos em main e ninguém sabe se é instrumento ou dívida.
- **VoiceOver real**, declarado pelo worker como não medido.

## Instrumento, declarado

Todo `xcodebuild` e todo `maestro` passaram por `ferramentas/orca/com-trava.sh`.
Cinco simuladores estiveram ligados durante a revisão, então — pela lei da
ESTEIRA — **nenhuma nota minha se apoia em asserção do maestro**: usei o maestro
só para navegar, e toda prova de tela é `xcrun simctl io <meu UDID> screenshot`
do conteúdo que eu mesmo semeei no meu contêiner. Liguei o `6033B043` no início
e o desliguei no fim; nenhum outro simulador foi tocado.

## Capturas desta revisão

| arquivo | o que prova |
|---|---|
| `l1-rev-tempo-desconhecido.png` | reprodução independente: série 21→4→49, os quatro estados, "tempo desconhecido" |
| `l1-rev-selo-vazado.png` | **ALTO 1** — hipótese de Trabalho com origem selada no Perfil |
| `l1-rev-muitos-abertos.png` | **ALTO 2** — doze linhas de dívida, nenhum fechado |
| `l1-rev-autoria-perdida.png` | **ALTO 3** — `propostaPor` ausente e "Grok" indistinguíveis do autor |
| `l1-rev-autoria-e-selo.png` | **MÉDIO 4** — decisão trancada continua na mediana (7→9 descobertas) |
| `l1-rev-vazio.png` | `curva-zero`: vazio desenhado, na voz do cartão vizinho |

---

# Re-G3 — 06/09/2026, mesmo revisor, topo `f895d90`

Worktree `volta-l1-latencia` depois do `git merge main` (`feb0e16`) e do commit
L1-B (`f895d90`). Julguei os quatro achados e o que ele encontrou sozinho.
Não editei nem commitei nada. Meu simulador continua o `6033B043`.

## Veredito: **PASSA.** Os quatro achados morreram, e um deles morreu melhor do que eu tinha pedido.

Suíte por mim, sob `com-trava.sh`, no meu UDID: `Test run with **792 tests in
131 suites** passed`, `** TEST SUCCEEDED **`, exit 0, e agora **zero aviso** —
os dois avisos pré-existentes de `ConferenciaTrabalhoTests` que eu tinha
absolvido caíram no merge da main. `LatenciaTests` foi de 11 para 13.

---

## ALTO 1 — o selo: **corrigido, e a correção é mais larga do que o vazamento**

`lerLatencia` agora é `for t in trabalhos where AcessoTrabalho.permitido(t, no: context)`,
e a guarda da decisão subiu para dentro do funil: `Latencia.registro(decisao:)`
devolve `Registro?` e sai com `nil` logo no `guard !fechada`. Isso é melhor do
que a linha que eu teria escrito na tela: a guarda ficou no lugar por onde toda
leitura de decisão passa, não numa chamada que a próxima pessoa pode esquecer.

**Contagem das superfícies, como pedido:** eram **onze fazendo a checagem e uma
não fazendo**. Agora são **doze fazendo e nenhuma não fazendo** — conferi por
grep os três leitores de `trabalho.ler()` do app inteiro (`CalendarioTrabalho`,
`OficinaTrabalho`, `PerfilView`) e os três têm o gate na linha imediatamente
acima da leitura. Não sobrou leitor descoberto.

**Reprodução do vazamento que eu capturei** (`l1-rev-selo-vazado.png`), no MODO B
do semeador, que reconstrói o meu cenário inteiro: `l1-rev2-quatro-estados.png`.
Não me contentei com "não vi na tela" — a ausência tem prova aritmética, e ela é
mais forte que a leitura:

- A hipótese do trabalho de origem selada é semeada em **01/05/2026**, a mais
  velha de todas. A lista de abertos é ordenada do mais velho para o mais novo e
  o corte pega os mais velhos primeiro, então **se ela existisse seria a primeira
  linha, com 128 dias**. A primeira linha da minha captura diz **119 dias**
  ("registro antigo: propostaPor AUSENTE", semeada em 10/05). Ela não está lá.
- O resumo diz **18 em aberto**: 17 hipóteses do trabalho não protegido + 1
  decisão aberta. O trabalho protegido tem uma hipótese aberta e ela não entra.
  Se o selo vazasse, diria 19.
- O resumo diz **4 descobertas**. A decisão trancada e respondida (`NOTA_DECISAO_SELADA`)
  tem os dois carimbos e não é contada. Diria 5 se entrasse. **"Nem como
  contagem" se sustenta, medido, e não só declarado.**

`maestro/latencia.yaml` ganhou `assertNotVisible "SEGREDO SELADO.*"` e passa —
mas isso é reforço, não a minha prova (ver "Instrumento" no fim).

---

## ALTO 2 — o corte por estado: **corrigido, e cobre o caso que eu construí**

`Latencia.paraTela` dá cota por estado: 2 devidos, o resto de 4 em afirmados, 2
sem data, 4 descobertos, 2 abandonados — teto de doze, e cada estado sobrevive
ao corte quando existe.

Refeito com o meu cenário, e pior que ele: eu tinha derrubado a dimensão com 17
abertos; o MODO B tem **18**. Na captura `l1-rev2-quatro-estados.png`, as doze
linhas são **3 afirmados + 1 devido + 2 sem data + 4 descobertos + 2 abandonados**.
Onde antes havia doze contadores de dívida e nenhum fechado, agora os quatro
estados estão na mesma tela, e o teto de doze linhas não subiu. O modo de falha
que o dono nomeou com as próprias palavras não acontece mais.

Uma observação que não é achado: com 5 devidos e 0 afirmados o bloco de abertos
mostra 2 em vez de 4 (a cota dos afirmados é `4 - devidos.count`, e não há
afirmado para preencher). Sub-preenche, nunca estoura, e nenhum estado some.

---

## ALTO 3 — a autoria: **corrigida, e a frase da tela também**

`propostaPor` viaja no `Registro` e `Registro.autoria` é a regra num lugar só:
`nil` para o autor (sem ruído no caso comum), `"proposta por X"` para quem não é
ele, `"autoria desconhecida"` para o registro anterior à 05r — o molde exato da
`TrabalhoView`. Só a hipótese tem proponente; a decisão é escrita do autor e
`autoria` devolve `nil` para ela, o que está certo.

Na tela (`l1-rev2-quatro-estados.png`):

```
afirmado · em aberto há 119 dias · autoria desconhecida
registro antigo: propostaPor AUSENTE

afirmado · em aberto há 118 dias · proposta por Grok
hipotese proposta por Grok, nao pelo autor
```

E ele consertou uma coisa que eu apontei e não cobrei: a frase de abertura era
"Quanto tempo passa entre **você** afirmar uma coisa" e passou a "entre afirmar
uma coisa". A afirmação sobre a autoria saiu da voz do app, em vez de ficar
desmentida linha a linha. Era a raiz do achado, não o sintoma.

---

## CONTRATO — a citação: **corrigida, e no sentido mais duro**

A citação da 05s que não existia saiu. No lugar entrou a regra do retrato,
nomeada como tal e com o texto dela: *"nada de expressiva, trancada ou queimada
entra no retrato, nem como contagem"*. E ele não escolheu a leitura frouxa: em
vez de justificar a política mais permissiva, **adotou a do vizinho de cima** e
tirou a nota selada da latência inteira. A ADR escreve por quê — uma duração
medida a partir do que o selo fechou é mais do que contar. É a resposta que eu
teria dado se o dono tivesse me perguntado, e ele chegou nela sem perguntar.

---

## O achado dele: trancar não era abandonar. **Confirmo, é real, e o conserto está certo.**

Fui atrás no código antigo antes de acreditar. No `bfe3130`:

```swift
if respondeu { estado = .descoberto }
else if fechada { estado = .abandonado }      // <- o único caminho
else if (devidoEm ?? criadaEm) <= agora { estado = .devido }
```

`fechada` é `trancada || queimada`. Para uma **decisão**, `.abandonado` não tinha
nenhuma outra porta: nem prazo vencido, nem tempo, nem gesto. Só o selo. E o
teste antigo dizia isso em voz alta — `"fechar sem responder é abandonar"`.

Então o app dizia ao autor **"abandonado · fechado sem conferir"** a respeito de
uma nota que ele tinha **trancado para proteger**. Dois atos diferentes — um de
privacidade, um de desistência — colapsados na mesma palavra, numa tela cujo
contrato inteiro é que os quatro estados são distintos e nenhum é falha. O achado
é bom e ninguém o tinha visto, eu inclusive: eu revisei essa linha e li a
contagem, não o significado.

**Nenhum registro real muda de estado por baixo do autor**, e conferi caminho por
caminho, não por confiança:

| registro | antes | agora | mudou de estado? |
|---|---|---|---|
| hipótese, trabalho aberto | afirmado | afirmado | não — `registros(hipoteses:)` é idêntico fora do `propostaPor` |
| hipótese, trabalho encerrado | abandonado | abandonado | não |
| decisão não selada, respondida | descoberto | descoberto | não |
| decisão não selada, prazo vencido | devido | devido | não |
| decisão não selada, no prazo | afirmado | afirmado | não |
| decisão **selada** | abandonado | **sai da latência** | sai da tela, não troca de rótulo |

A única classe afetada é a selada, e ela **sai** em vez de virar outra coisa —
que é o conserto do ALTO 1 e do CONTRATO ao mesmo tempo. Sai também da contagem,
medido acima. Não há registro que apareça hoje com um rótulo diferente do de
ontem.

**O que fica dito, e não é objeção:** depois disto, uma Decisão **não tem
nenhuma porta para `abandonado`**. Uma decisão que o autor nunca vai responder
fica `devido` para sempre, com o contador crescendo sem fim, e o único gesto que
a tira da tela é trancá-la — um ato de privacidade usado como "dispensar", que é
a mesma conflação de antes, invertida. Não é regressão (antes o selo só a
rotulava mal em vez de a remover) e não é desta volta: o que falta é um gesto de
"não vou conferir esta" na própria Decisão. Merece uma linha em "Fora" da ADR e
uma ideia no IDEIAS, não um bloqueio aqui.

---

## O ida-e-volta pelo app: **feito, e é a prova que eu tinha pedido**

`maestro/latencia-ida-e-volta.yaml` cria o Trabalho pela tela, escreve a hipótese
pela tela, avalia pela tela e lê no Perfil — tudo depois de `clearState`, sem uma
linha semeada. Rodei e passa comando a comando; a prova que eu assino é a minha
captura por `simctl`, `l1-rev2-ida-e-volta.png`:

```
1 descoberta com as duas datas · a do meio levou menos de um dia
setembro de 2026 · menos de um dia · 1 descoberta

descoberto · levou menos de um dia
o ida e volta pelo proprio app
```

Nenhuma marca de autoria, porque a hipótese é do autor e o caso comum não ganha
ruído. **A circularidade que eu apontei está fechada:** o leitor não conhece só o
que o semeador escreve; ele lê o que o próprio app grava, pelo caminho do app.
O que continua valendo é a distinção que a ADR já fazia — isto prova o CICLO,
não a série de meses, e a série de meses continua semeada e declarada.

---

## A barra sem escala: **é achado, e eu medi**

Ele levantou e não resolveu; o dono pediu a minha leitura. Ela é: **a barra
codifica posição na série, não duração, e nada na tela diz isso.**

`barraDoMes(Double(m.mediana) / Double(maior))`, com `maior = max(1, medianas.max())`.
Consequência aritmética: **o pior mês da série é sempre 100 %**, qualquer que
seja o número. Medi os dois extremos, com um mês só na série:

| série | o que a tela diz | quanto a barra enche |
|---|---|---|
| um mês, mediana **300 dias** (`l1-rev2-barra-sem-escala.png`) | "julho de 2026 · 300 dias · 1 descoberta" | **97,6 %** |
| um mês, mediana **menos de um dia** (`l1-rev2-ida-e-volta.png`) | "setembro de 2026 · menos de um dia · 1 descoberta" | **3,2 %** |

O segundo caso só não enche porque zero é um caso especial (`max(1, 0)`). **Um
mês só com mediana de 1 dia enche a barra igualzinho a um de 300** — 1/1 = 1. E
é exatamente a tela do primeiro mês de qualquer autor, inclusive a do dono
quando ele abrir isto no aparelho dele. Depois: julho encolhe quando setembro
chega, sem julho ter mudado; e dois autores, um cujo pior mês é 3 dias e outro
cujo pior mês é 300, veem o mesmo desenho.

**É honesto ou vira achado?** Não é desonesto no sentido que o dono teme: não é
placar, não há meta, cor, seta nem veredito, e o número em dias está escrito por
extenso ao lado de cada barra — quem lê tem a verdade na mão. Mas a barra é o
elemento mais rápido de ler e carrega significado **relativo** sentada ao lado
de um número **absoluto**: o relance e a leitura discordam. Isso é defeito do
desenho, não mentira do dado.

**Nota: não bloqueia esta volta**, porque nada na tela afirma o que é falso.
**Mas não pode ficar como está sem estar escrito.** Três saídas, da mais barata
para a mais cara: (a) tirar a barra e ficar só com as palavras, que já são
honestas e já estão lá — é a saída ponytail e não perde nada que o autor use;
(b) ancorar a pista num valor fixo (o maior de sempre, ou 90 dias com marca de
transbordo), que dá unidade ao desenho; (c) manter e **declarar em "Fora" da ADR
que a barra é relativa à própria série**, que é o mínimo aceitável. Hoje a ADR
não diz nenhuma das três. **Recomendo (a)**, e é decisão do dono, não minha.

---

## Notas revistas

| dimensão | era | agora | por quê |
|---|---|---|---|
| **Privacidade e autoria** | 4 | **10** | O gate está no `lerLatencia` e a guarda da decisão no funil, não na tela; doze superfícies checando e nenhuma descoberta; a ausência do selado provada por aritmética (18 e não 19 abertos, 4 e não 5 descobertas, a linha de 128 dias ausente) e não por leitura; `propostaPor` viaja com a regra da `TrabalhoView` e a frase da tela parou de afirmar autoria. |
| **Estado honesto** | 6 | **10** | `paraTela` corta por estado; com **18** abertos — mais que os 17 com que eu derrubei — os quatro estados estão na mesma captura, dentro do mesmo teto de doze linhas. E o significado de ABANDONADO ficou mais honesto do que estava antes da minha revisão: trancar deixou de ser lido como desistir. |
| **Contrato** | 8 | **10** | A citação inventada saiu, a regra do retrato entrou nomeada e com o texto, e a política adotada é a mais restritiva das duas — não a mais conveniente. A ADR registra a mudança de significado de ABANDONADO. |
| **Correção** | 9 | **10** | 792/131 verdes por mim no meu UDID, `TEST SUCCEEDED`, exit 0, **zero aviso**; `LatenciaTests` 11 → 13, e os testes novos são dos comportamentos exatos que eu derrubei (`notaSeladaNaoEntraNaLatenciaNemComoContagem`, `aAutoriaDaHipoteseVemJuntoENaoViraDoAutor`, `oCorteDaTelaGuardaOsQuatroEstados`). O ida-e-volta virou fluxo. |
| **Jornada real** | 9 | **10** | O estado que faltava (muitos abertos) virou o MODO B do semeador e é reexecutável por qualquer um; o ida-e-volta cobre o ciclo pela tela, do zero. |
| **Design** | 9 | **9** | Sem mudança de token nem de layout; a linha de autoria entra no `Text` que já existia. A barra sem escala é a única pendência de desenho, declarada acima e não bloqueante. |

Visão 10, Simplicidade 9, Acessibilidade 9, Performance 9, Complexidade 10,
Relato 10, Movimento/Componentes/Fora do app n/a — todas mantidas da G3, e
nenhuma delas foi tocada pelo L1-B.

**Nenhuma dimensão abaixo de 9. Veredito: PASSA para o G4.**

## O que segue em aberto (não bloqueia)

1. **A série real do dono, no aparelho dele.** Só ele pode; nada nesta volta
   substitui isso, e a ADR continua dizendo isso em vez de fingir.
2. **A barra sem escala** — decidir entre (a), (b) e (c) acima. Recomendo (a).
3. **A Decisão sem porta para "abandonado"** — falta um gesto de "não vou
   conferir esta", e hoje o único jeito de tirar uma decisão da tela é trancá-la.
4. **VoiceOver real ligado**, que o worker continua declarando como não medido.
5. **Varredura do Perfil numa máquina com um simulador só** — a pendência que eu
   já tinha aberto na G3 e que não é desta volta.

## Instrumento, declarado

Todo `xcodebuild` e todo `maestro` passaram por `ferramentas/orca/com-trava.sh`.
Quatro simuladores estiveram ligados, então **nenhuma nota minha se apoia em
asserção do maestro** — nem o `assertNotVisible "SEGREDO SELADO.*"`, nem os
asserts do ida-e-volta. Usei o maestro para navegar e para exercitar o ciclo; a
prova de cada afirmação acima é `xcrun simctl io <meu UDID> screenshot`, mais a
aritmética dos contadores e a medida em pixel das barras. Liguei o `6033B043` e o
desliguei no fim; nenhum outro simulador foi tocado, e o iPhone 17 do dono não
esteve ligado em momento nenhum.

## Capturas do Re-G3

| arquivo | o que prova |
|---|---|
| `l1-rev2-quatro-estados.png` | os três achados de uma vez: sem "SEGREDO SELADO", os quatro estados com 18 abertos, "autoria desconhecida" e "proposta por Grok" |
| `l1-rev2-modo-b.png` | o resumo que dá a prova aritmética: 4 descobertas, 18 em aberto, 2 sem data, 2 abandonadas |
| `l1-rev2-ida-e-volta.png` | o ciclo pela tela, do estado limpo: "descoberto · levou menos de um dia / o ida e volta pelo proprio app" |
| `l1-rev2-barra-sem-escala.png` | a barra: um mês só, mediana de 300 dias, 97,6 % da pista |
