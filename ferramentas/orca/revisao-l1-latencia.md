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
