# A leva 3, conferida contra o `main` de hoje

17/09/2026 · conferência de [`leva-3-e-fusao.md`](leva-3-e-fusao.md), escrito em
06/09 e nunca colado. Onze dias de `main` passaram por cima dele.

**Nada de app mudou nesta volta.** Isto é leitura, com a sonda junto:
[`conferir-leva-3.py`](conferir-leva-3.py) — roda em segundos, sem build e sem
simulador, e é a mesma prova que o pacote diz ter rodado em 06/09.

> **Contra qual `main`.** Esta conferência rodou contra `59e3a4c` (15/09), que é
> o topo do repositório no GitHub. Se houver trabalho ainda não empurrado na
> máquina do dono — e em 17/09 havia —, os números de linha daqui já andaram de
> novo. É o motivo de a prova ser um script e não uma tabela: rode
> `python3 ferramentas/orca/metodos/conferir-leva-3.py` no seu `main` e a tabela
> se refaz.

> **O que a sonda é e não é.** Ela imita `AnaliseLocal.detectarGesto` (ordem do
> array, primeira regex que casa vence, Expressiva só acima de 120 caracteres) e
> **lê os léxicos da guarda direto do Swift**, em vez de copiá-los, para não
> envelhecer sozinha. O `re` do Python não é o `NSRegularExpression`; os padrões
> do catálogo usam só alternância, grupo, classe, opcional e `\b`, que se
> comportam igual nos dois. **A prova que vale continua sendo `swift test`.** A
> sonda diz onde olhar.

---

## O veredito em uma linha

**O pacote continua válido e ainda é a próxima coisa a fazer.** O JSON está
íntegro, a guarda não afrouxa, a herança da Inversão faz o que promete. O que
envelheceu foi a **lista do que quebra**: onde o pacote diz "dois testes", hoje
são **sete lugares de teste e três fora de teste**, um deles uma frase que o autor
lê na tela.

## O que passou (e passou limpo)

| prova | resultado |
|---|---|
| Os 14 objetos parseiam, e nenhum id colide com os 28 | **ok** — catálogo final de 41 |
| Nenhum encadeamento aponta para id inexistente, nos 41 | **ok** — zero |
| Todo `mapa`/`exige`/`compromisso` aponta para campo que existe na origem | **ok** — zero defeitos |
| Todos os 14 declaram `proveniencia` com `funcao` válida | **ok** — 10 `lente`, 4 `pratica` |
| **A guarda de escrita pessoal**: o desabafo longo do §1 do pacote vai para a Expressiva com os 41 no lugar | **ok** — e é o teste que manda parar a colagem se falhar |
| A herança da Inversão (§1.3): as cinco frases órfãs acham o Pré-mortem | **ok** — inclusive "como garantir que isso falhe", que hoje não acha ninguém |
| Regressão sobre as 121 frases literais dos testes | **ok** — mudam 3, e as três são a fusão funcionando |

## O que não passa mais: o alcance é 13/14

**A frase de alcance da `reparacao` morreu.** A frase que o próprio pacote usa
para provar que o método é alcançável —

> "magoei ela ontem e preciso reparar"

— casa a primeira regex da `reparacao` e mesmo assim **roteia para lugar nenhum**:
`lexicoDoSentimento` tem `mago[aeiou]`, a guarda acende antes do roteador, e
abaixo de 120 caracteres a guarda manda para o silêncio, não para a Expressiva
(`AnaliseLocal.swift:135`, `:236-248`).

**O método não está morto; a sonda dele está.** Dos onze gatilhos da `reparacao`,
dez continuam chegando — conferidos um a um:

| frase | rota |
|---|---|
| "preciso pedir desculpa pelo atraso" | `reparacao` |
| "como eu reparo isso com ela" | `reparacao` |
| "prejudiquei o time com aquela escolha" | `reparacao` |
| "deixei ela na mão na semana passada" | `reparacao` |
| "quebrei a confiança dele" | `reparacao` |
| "magoei ela ontem e preciso reparar" | **ninguém** |

Em 132 gatilhos dos catorze, a guarda engole exatamente **dois**:

| método | gatilho | léxico que acende |
|---|---|---|
| `reparacao` | `magoei` | `lexicoDoSentimento` (`mago[aeiou]`) |
| `porta` | `se eu me arrepender` | `lexicoDoSentimento` (`arrepend`) |

A `porta` não sente: sobram oito gatilhos, e o de alcance dela ("isso não tem
volta") chega.

**É pequeno, e ainda assim é o achado que importa** — porque é exatamente a lição
que o pacote cita de si mesmo: *"Este é o teste que a M9 quase deixou passar um
método com regex quebrada. Alcance não é detalhe."* Uma sonda que não sonda dá
verde falso, e o 14/14 de 06/09 foi um deles.

**O conserto é de duas linhas de texto, não de código:**

1. **Trocar a frase de alcance** da `reparacao` no pacote por uma que chegue —
   "como eu reparo isso com ela" serve, e é conferida acima.
2. **Decidir o gatilho `magoei`.** Ele nunca vai disparar, então ou sai do
   `roteamento` (uma palavra a menos, e o método fica honesto sobre o que
   alcança), ou fica como intenção declarada e a ficha diz que a guarda o cobre.
   Eu tiraria: gatilho que não dispara é a mesma dívida escondida que a régua da
   proveniência recusa.

**O que não é conserto: mexer na guarda.** Ela mora em código de propósito, e a
regra do próprio pacote vale aqui — se o teste da escrita pessoal falhar,
conserta-se a ordem, nunca a guarda.

---

## O que quebra hoje, com linha — a lista que o pacote não tem mais

O pacote diz, em §1.5: *"Nada mais em `Traco/` cita `inversao`: conferido em
`main`, só estas duas linhas de teste e o próprio JSON."* **Isso não é mais
verdade.** Hoje, em `main`:

### Em teste — sete lugares, não dois

| arquivo:linha | o que quebra | conserto |
|---|---|---|
| `CatalogoTests.swift:8-10` | `oBundleTemOsVinteEOitoMetodos`, `#expect(ids.count == 28)` | vira 41, e o nome do teste vira o número novo |
| `CatalogoTests.swift:13` | a lista literal inclui `"inversao"` | sai da lista |
| **`CatalogoTests.swift:18-19`** | `Array(ids.suffix(7)) == [os sete da M3]` — **os catorze entram no fim, então o sufixo deixa de ser os sete** | o sufixo passa a ser os catorze, ou a asserção muda de forma |
| `CatalogoTests.swift:167` | `Catalogo.metodo("inversao")?.encadeamentos.first?.para == "premortem"` → `nil` | outro par vivo, p.ex. `porta` → `decisao` |
| **`CatalogoTests.swift:288`** | `id("como garantir que falhe: …") == "inversao"` | vira `"premortem"` — a sonda confirma que é para lá que vai |
| **`EscritaPessoalTests.swift:102`** | desabafo com gancho cuja **porta declarada** é `"inversao"`; o teste exige `Catalogo.metodo(porta) != nil` | a porta declarada vira `"premortem"` (a frase continua indo para a Expressiva, que é o ponto do teste) |
| **`EscritaPessoalTests.swift:226-227`** | duas frases com destino esperado `"inversao"` | viram `"premortem"` |

Os cinco em negrito **não estão no pacote.** Três deles nasceram na colagem da
leva 1 (os testes dos sete da M3), que é a base que o pacote pressupõe.

### Fora de teste — três lugares, e um deles o autor lê

| arquivo:linha | o que é | por que importa |
|---|---|---|
| **`Traco/Analise/Politica.swift:207`** | a frase que o app mostra quando o Contrapor está indisponível: *"O Steelman **e a Inversão** continuam no catálogo, escritos por você."* | com a fusão, **o app afirma ao autor que um método está no catálogo quando não está.** É exatamente o defeito que o §1.6a do pacote manda não publicar. Conserto: tirar "e a Inversão", ou trocar pelo Pré-mortem |
| **`maestro/ilhas-encadeadas.yaml`** | o fluxo inteiro é a cadeia Inversão → Pré-mortem: digita "como garantir que falhe o lançamento do curso", espera `forma-inversao`, preenche `campo-quero` e `campo-falhe`, toca "Virar Pré-mortem" | **não é uma linha, é um fluxo.** Com a fusão o texto abre o Pré-mortem direto e não há mais o que encadear. O fluxo é reescrito para outra ilha, ou sai |
| `Traco/Pagina/LenteView.swift:138` | um comentário citando a Inversão como exemplo | cosmético; corrigir junto ou deixar |

### O que continua valendo, conferido linha a linha

O §1.6 do pacote — *a nota que já usa a forma Inversão conserva os campos, e o
catálogo diz que o método saiu* — **continua inteiro.** Só os números de linha
andaram:

| o pacote diz | hoje é |
|---|---|
| `Gesto.swift:9-19` (o `Gesto` é `String`) | igual |
| `Gesto.swift:56` → `Metodo.swift:143` (`desconhecido`) | `Metodo.swift:199` |
| `Gesto.swift:66-69` (`estadoDoMetodo`), frase em `:68` | frase em `Gesto.swift:69` |
| `LenteView.swift:67` (`metodo-ausente`) | `LenteView.swift:83` |
| `CatalogoTests.swift:224` (a frase exata) | `CatalogoTests.swift:228` |
| `Corpus.swift:222-224` (ADR 05o na exportação) | `Corpus.swift:249-251` |
| `RecordarView.swift:17` (o `recordar` que a fusão custa) | `RecordarView.swift:18` |

E as duas arestas do §1.6 continuam abertas do mesmo jeito: a frase que diz "saiu
da **sua pasta**" quando quem tirou foi o app, e o nome que vira o id cru. A
primeira é uma linha em `Gesto.swift:69` mais a string de `CatalogoTests.swift:228`.
**Se a volta não quiser tocar em Swift, a fusão não deve acontecer nela** — é a
regra do próprio pacote, e agora ela tem uma segunda razão: `Politica.swift:207`
também é Swift, também é frase de tela, e também mente depois da fusão.

---

## O que eu mudaria no pacote antes de colar

1. **Substituir o §1.5 pela tabela acima** — sete lugares de teste, não dois.
2. **Acrescentar um §1.7**: `Politica.swift:207` e `maestro/ilhas-encadeadas.yaml`.
   Nenhum dos dois é opcional: um é frase falsa para o autor, o outro é um fluxo
   de aceite que passa a testar algo que não existe.
3. **Trocar a frase de alcance da `reparacao`** e decidir o gatilho `magoei`.
   Feito isso a sonda volta a 14/14.
4. **Deixar o resto como está.** Os cinco passos, a ordem entre eles e o argumento
   da herança continuam corretos, e a ordem importa pelo motivo que o pacote dá.

Nada disto muda a conclusão da [leitura de journaling](journaling-no-catalogo.md):
a leva 3 vem antes de método novo. Só ficou sabido quanto ela custa de verdade.
