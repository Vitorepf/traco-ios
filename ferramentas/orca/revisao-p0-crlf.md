# G3 do P0-CRLF — revisão independente

**Candidato:** `21939ae` · branch `Vitorepf/p0-crlf` · ADR 2026-09-09y
**Veredito:** **o CÓDIGO passa; o TEXTO que sai com ele não.** Não mesclar como está —
mesclar depois de uma correção **só de comentário e ADR, zero linha de lógica**.
Duas dimensões em 8, **Contrato** e **Estado honesto**, pela mesma raiz: a ADR, o
comentário de `importarComEstado` e o EVOLUCAO prometem uma invariante **mais forte do que
o código entrega**, e eu medi a diferença.

Revisor: outro fornecedor, não corrigiu nada. Aparelho de trabalho `34CC3F94` (build e
suíte, sob `com-trava.sh`, numa única chamada). **`B91C8DEF` não foi tocado** — não
instalei, não lancei, não fotografei, não desliguei. Nenhum `xcodebuild` por MCP; conferi
que não havia servidor MCP de build vivo (`ps` limpo) antes de começar.

---

## 1. O que eu refiz, e bate

`D` e `E` refeitos por mim, em harness **independente do autor**: os corpos de `Antes` e
`Depois` saem por `awk` do arquivo vivo e do commit pai, **nunca digitados**, para não
haver deriva de transcrição (`ferramentas/orca/revisao-p0-crlf/montar.sh`).

| caso | ANTES apaga | DEPOIS apaga | `consumido` |
|---|---|---|---|
| D) `\r` só na origem | SIM (selo vazou) | **não** | 0,00 |
| E) prosa antes do 1º cabeçalho, sem um `\r` | SIM | **não** | 0,52 |

Idênticos à tabela do autor em `medida-antes-depois.txt`. Rodei mais **12 casos que ele não
escreveu** e **nenhum regrediu**.

**O portão de contagem é carga, não enfeite.** Removi só a linha
`guard cabecalhos(conteudo) == hits.count` do mesmo código: o caso B (tudo CRLF, selada)
volta a **vazar o corpo selado como voz do autor e a apagar o arquivo**, com
`consumido = 1.00`. A cobertura sozinha **não** pega. O portão ganhou o lugar dele.

## 2. A alegação forte, derrubada com número

> "qualquer `continue`, inclusive um que alguém escreva amanhã, deixa a conta curta sozinho"

**Verdadeira para `continue`** — e estruturalmente, porque `lidos += comTinta(bloco)` é a
última instrução do corpo do laço. **Falsa para tudo o mais.** Escrevi o caminho de descarte
novo que o exercício pede, e escrevi-o **no estilo que esta casa já usa** — o teto de 140
grafemas da ADR 08h — sem nenhum `continue` novo:

```
saida.append((String(corpo.prefix(140)), gestoNome, data, origem))
```

```
AMANHA (teto de 140 grafemas, SEM continue novo):
  caracteres no arquivo : 699
  caracteres importados : 140
  consumido             : 1.00
  podeRetirar (APAGA?)  : SIM
```

**140 de 699 caracteres, a conta fecha em 100%, e o arquivo do autor é apagado.** (Escrevi
"140 de 659" na primeira redação e estava errado: **699** é o que o arquivo tem, **140** é o
que entrou, e **659** é o que o caminho de HOJE importa — os 40 de diferença são a tinta do
cabeçalho, creditada sem virar nota, que é exatamente o defeito.)
A invariante é cega a todo descarte que não seja pular o bloco inteiro: truncar, filtrar
`saida` depois do laço, ou ler um campo errado.

**O nome certo da invariante não é "cobertura de leitura".** É **cobertura de
delimitação**: ela prova que todo byte do arquivo caiu dentro de um bloco que foi
`append`ado — não que virou nota. A diferença é medível hoje, sem inventar código futuro:

| caso | `consumido` | apaga? | o que se perde |
|---|---|---|---|
| N3) `gesto: Meu Metodo Pessoal` (nome fora do catálogo) | **1,00** | SIM | o nome do gesto, descartado por `Gesto.doNome` |
| N4) nota **exportada pelo próprio app** com `dominio:` e `recordada:` | **1,00** | SIM | `dominio` e `recordada` — o importador **nunca os lê** (`Corpus.swift:147` escreve, nada lê) |

A tinta do cabeçalho é creditada como lida sem virar nota nenhuma. Então o comentário
`consumido é ... a fração dos caracteres com tinta que **viraram nota**` é falso, e é um
número falso **em tempo de execução**, não só na prosa.

## 3. O que continua vazando (aberto, **não** é regressão desta volta)

O portão só dispara quando os **dois** contadores **discordam**. Quando ambos são cegos ao
mesmo cabeçalho malformado, o arquivo cai no ramo `hits.isEmpty`, que é **fail-open**:
"nenhum cabeçalho do Traço ⇒ isto é prosa livre do autor" ⇒ importa tudo e apaga.

| caso | hoje | o que acontece |
|---|---|---|
| N1) `criada:2026-…` (sem o espaço) num bloco com `estado: selada` | apaga | arquivo inteiro vira **UMA nota aberta `origem: autor`**, com o corpo selado dentro |
| N2) selo escrito à mão, sem linha `criada:` | apaga | idem |
| N6) `estado:selada` (sem o espaço), cabeçalho por tudo o mais válido | apaga | o regex **lê** o cabeçalho, o selo **não** é reconhecido, o corpo entra como do autor, `consumido = 1,00` |

**Os três já apagavam em `main`** — a coluna ANTES é SIM nos três. Esta volta não piorou
nada; ela fechou B, C, D, F e H e deixou esta família aberta. Mas a frase da ADR
*"cabeçalho não lido pode ser um selo: nada entra como do autor e nada se apaga"* descreve
uma garantia que só existe no eixo do fim de linha.

**Recomendação medida** (uma cláusula `||` no ramo `hits.isEmpty`: um arquivo que **abre**
com a cerca `---` afirma ter estrutura que este parser não entendeu):

```
  N1 selo invisivel                      hoje: apaga=SIM  |  com a linha: apaga=nao
  N2 selo a mao                          hoje: apaga=SIM  |  com a linha: apaga=nao
  G  prosa solta (tem de APAGAR)         hoje: apaga=SIM  |  com a linha: apaga=SIM
  exportada ida e volta (tem de APAGAR)  hoje: apaga=SIM  |  com a linha: apaga=SIM
  E  prosa antes do 1o (nao apaga)       hoje: apaga=nao  |  com a linha: apaga=nao
```

Fecha N1 e N2 **sem regressão** nos dois casos que **têm** de continuar apagando. N6 não
fecha por aí — pede leitura estrita das chaves do cabeçalho, e é volta própria.

## 4. As duas coisas declaradas, julgadas

**1) A normalização não foi escrita — falha segura ou buraco? → FALHA SEGURA.**
Medi: nota **aberta** inteira em CRLF devolve 0 itens, `consumido = 0`, `podeRetirar =
false`. O arquivo **fica na `entrada/`, intacto**. Nada se perde, nada se apaga, e nada
entra errado. É a direção certa.

**Não vale trazer `Corpus.fimDeLinhaLF` da `Vitorepf/mac-2-a` nesta volta.** Ela custaria
uma dependência de branch que a §13 parou, e teria de ser re-verificada aqui de qualquer
modo. O que dói no autor não é a falta da normalização — é a **recusa muda** (abaixo). Na
ordem certa, **avisa-se o autor antes de normalizar por ele.** Custo declarado basta;
nomeie a dívida com número no RUMO.

**2) A recusa é MUDA — concorda com o 8? → CONCORDO, e é pior do que ele descreveu.**
Segui a rota inteira: com 0 itens, `Entrada.arquivos` descarta o arquivo (`continue`,
`Entrada.swift:56`); com a lista vazia, `Sessao.recolherEntrada` sai no
`guard !arquivos.isEmpty` (`Sessao.swift:1394`); e com `total == 0` **nem o toast final
corre** (`Sessao.swift:1428`). O autor larga um `.md` na pasta, abre o app e **não acontece
absolutamente nada**: sem nota, sem frase, sem erro. A captura `p0-01` confirma — tela em
repouso, nenhuma palavra sobre os cinco arquivos que ficaram para trás.

E esta volta **aumenta a frequência** desse caminho: o que antes importava errado agora é
recusado em silêncio. É a troca certa (dado acima de aviso), mas é um custo novo, e é a
mesma família da *espera calada* que o dono nomeou na §13.

## 5. Instrumento — a prova de que a suíte é a minha

Build **LIMPO** (`rm -rf build` antes; `xcodegen generate` na mesma chamada) e suíte, tudo
dentro de **uma única** chamada de `com-trava.sh`, no `34CC3F94`:

```
✔ Test run with 1021 tests in 163 suites passed after 146.794 seconds.
◇ Test arquivoSoSaiDaEntradaQuandoOAppLeuTudo() started.
✔ Test arquivoSoSaiDaEntradaQuandoOAppLeuTudo() passed after 0.001 seconds.
◇ Test oQueOAppLeuInteiroContinuaPodendoSairDaEntrada() started.
✔ Test oQueOAppLeuInteiroContinuaPodendoSairDaEntrada() passed after 0.001 seconds.
** TEST SUCCEEDED **
```

Os dois testes exclusivos do candidato **no meu log**. Auditoria de contaminação refeita
por mim: **901 nomes distintos executados, 0 que não existem na minha árvore**
(`nomes-executados-901.txt`). Warnings do build limpo: **exatamente 1**, o herdado em
`NotasView.swift:806:30` — dívida de outra volta, não vermelho deste candidato.

Conferi as provas do autor pelo conteúdo, não pela existência: `jornada.sh` faz `cmp` do
binário **antes e depois** dentro da mesma trava; `jornada.txt` mostra 7 semeados, **6
sobreviventes**, e corpo selado **só** em `entrada/`, nunca em `notas/`. `p0-01` é a tela
viva às 11h01 — mas é a folha de escrever vazia, **não** a lista de notas: a prova de
jornada apoia-se no disco, não no que se vê. É por isso que Jornada real fica em 8, como o
próprio autor pôs.

## 6. Achado de processo — colisão de letra armada

**`ferramentas/orca/LETRAS-ADR.md` ainda diz "Próxima livre: 09y."** A ADR 09y já está
escrita em `SPEC.md:8978`. O próprio caderno de letras manda em negrito: *"reservar é
ESCREVER neste arquivo — dizer 'é sua' por mensagem não reserva nada"*, depois de duas
colisões em uma hora ontem. O autor deixou a linha para o coordenador e escreveu isso no
relato dele; **a linha continua sem ser escrita.** O próximo que ler o arquivo pega 09y e
colide. Custa 30 segundos e é do coordenador.

## 7. Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | **9** | fecha a lacuna nomeada no EVOLUCAO; a interação que melhora é a do autor cujo `.md` sobrevive |
| Contrato | **8** | a ADR promete mais do que o código faz, em três pontos medidos (§2 e §3); e a letra 09y não foi reservada no `LETRAS-ADR.md` (§6) |
| Correção | **9** | 1021/163 verde **reproduzido por mim**, build limpo, 1 warning herdado, 901/0 na auditoria; 14 casos independentes sem uma regressão; portão provado carga ao ser removido |
| Jornada real | **8** | disco provado com `cmp` dos dois lados; a captura é a folha vazia, não a lista — concordo com o 8 do autor |
| Privacidade e autoria | **9** | três rotas que convertiam `origem: modelo` em voz do autor e importavam corpo selado estão fechadas; **nenhuma** aberta por esta volta. As de §3 já apagavam em `main` e viram P0 próprio |
| Simplicidade | **9** | o portão saiu de quem chama; uma decisão a menos do lado de fora |
| Complexidade | **9** | 54 somadas / 11 removidas em 2 arquivos de produção, ~28 delas comentário; nenhum arquivo novo, nenhuma dependência, nenhuma normalização duplicada |
| Performance | **9** | medido **antes** de escolher: 0,6 ms contra 23,1 ms em 562 KB; `cabecalhos` 6,0 ms no mesmo corpus, declarado e não escondido; arquivo de `entrada/` é ruído |
| Estado honesto | **8** | `consumido = 1,00` afirma leitura integral em N3 e N4, onde campos do próprio formato do app somem e o arquivo é apagado; a alegação do "continue de amanhã" cai em 140 de 699 caracteres; mais a recusa muda que o autor nomeou |
| Relato | **9** | harness, medidas, log e capturas citados por caminho, e todos reproduziram |
| Design / Movimento / Componentes / Acessibilidade / Fora do app | **n/a** | motor puro: o diff não toca nenhuma view, token ou cópia de tela — conferido por `--name-only` |

**Nada mescla abaixo de 9 ⇒ este candidato não mescla como está.**

## 8. O que falta, com número — e é texto, não lógica

1. **`Corpus.swift:303-307`** — trocar *"a fração dos caracteres com tinta do arquivo que
   **viraram nota**"* pelo que a conta faz: **a fração que caiu dentro de um bloco
   importado**. Dizer que a tinta do cabeçalho é creditada sem virar nota.
2. **`Corpus.swift:314-320` e ADR §1** — trocar *"qualquer `continue`, inclusive um que
   alguém acrescente amanhã"* por **"qualquer `continue`"**, e dizer que truncar, filtrar
   `saida` ou ler um campo errado **não** encurtam a conta. Sem essa frase, o próximo autor
   confia num guarda que não existe.
3. **ADR §3** — *"nada entra como do autor e nada se apaga"* vale quando as contagens
   **discordam**; quando ambas são cegas ao mesmo cabeçalho, o ramo `hits.isEmpty` continua
   fail-open. Dizer isso, e abrir a dívida com a recomendação medida de §3.
4. **`ferramentas/orca/LETRAS-ADR.md`** — escrever a linha da `09y` e mover "Próxima livre"
   para `09z`, conferindo `grep -c "^| 09y"` = 1.

Feitos os quatro, **Contrato e Estado honesto sobem a 9 e eu aprovo a mescla.** Nenhum
deles pede uma linha de lógica; os três primeiros são comentário e ADR, o quarto é uma
linha de tabela.

## 9. Dívidas para o RUMO, com dono

- **P0-SELO-CEGO** (§3): `hits.isEmpty` é fail-open. N1, N2 e N6 apagam arquivo do autor e
  importam corpo selado como voz dele. Recomendação de uma linha medida para N1/N2; N6 pede
  leitura estrita das chaves. **Já existia em `main`** — não segura esta volta.
- **P1-RECUSA-MUDA** (§4): arquivo não entendido não gera frase nenhuma. Mesma família da
  espera calada da §13.
- **P2-CAMPO-QUE-SOME** (§2): `dominio` e `recordada` são escritos pelo app e nunca lidos
  na volta pela `entrada/`; `gesto:` fora do catálogo é descartado. Some, e o arquivo é
  apagado dizendo 100%.

---

**Provas desta revisão:** `ferramentas/orca/revisao-p0-crlf/` — `montar.sh` (extrai os dois
lados do código vivo, sem digitar), `casos-do-revisor.swift` (os 14 casos),
`medida-do-revisor.txt` (as quatro tabelas), `nomes-executados-901.txt` (a auditoria de
contaminação).

---

# 10. re-G3 do `0f3b4a1` — APROVADO

**Veredito: APROVO a mescla de `0f3b4a1`.** As quatro coisas que eu pedi estão feitas, o
diff em código é **100% comentário** e o meu próprio harness dá a **mesma saída byte a byte**
antes e depois. Não refiz o mérito: ele foi julgado em §1–§9 e nada no candidato o toca.

## 10.1 O diff em Swift é comentário — conferido, não aceito

```
$ git diff 21939ae..0f3b4a1 -- Traco/Notas/Corpus.swift \
    | grep -E '^[+-]' | grep -vE '^(\+\+\+|---$|--- )' \
    | grep -vE '^[+-][[:space:]]*(///|//)'
(vazio — rc=1)
31 linhas somadas, 7 removidas, todas `///` ou `//`
$ swiftc -parse Traco/Notas/Corpus.swift ; echo $?
0
```

E o diff **inteiro** do intervalo (que inclui o merge do `main`, `6aa109f`) toca **dois**
`.swift`: `Traco/Notas/Corpus.swift` e `ferramentas/orca/revisao-p0-crlf/casos-do-revisor.swift`
— o meu harness, que **nenhum target compila**: os `sources` do `project.yml` são `Traco`,
`TracoTests`, `TracoUITests`, `TracoWidget`, e `ferramentas` não aparece. Nenhum outro arquivo
do intervalo está num target (são `.md`, `maestro/condicoes.sh`, `f5-fotografar.sh` e o
`ax5.yaml` apagado). **O binário de produção é bit a bit o que eu já medi.**

## 10.2 O harness do revisor: mesma saída, byte a byte

`montar.sh` extrai o lado "depois" do **arquivo vivo**, então um comentário que caísse na
faixa do `awk` mudaria a extração. Rodei duas vezes com o mesmo `casos-do-revisor.swift`,
trocando só a fonte do lado "depois":

```
$ bash ferramentas/orca/revisao-p0-crlf/montar.sh            > saida-0f3b4a1.txt   # arquivo vivo
$ bash montar-antes.sh                                       > saida-21939ae.txt   # git show 21939ae:
$ diff saida-21939ae.txt saida-0f3b4a1.txt  &&  md5 -q ambos
f79ea6ec09995225184b815a298f0a0f
f79ea6ec09995225184b815a298f0a0f     ← idênticos
```

E a saída de hoje casa **linha a linha** com as 16 primeiras linhas de
`medida-do-revisor.txt` (as 18 restantes são sondas minhas de fora do `montar.sh`):
`diff <(sed -n '/^caso  /,$p' medida-do-revisor.txt) saida-0f3b4a1.txt` só aponta as linhas
17–34, que o `montar.sh` nunca imprimiu. **Se o comportamento tivesse mudado, não era
comentário.** Não mudou.

## 10.3 As quatro, uma a uma

| pedido (§8) | onde | veredito |
|---|---|---|
| 1. invariante = cobertura de **DELIMITAÇÃO** | `Corpus.swift:302-315`, ADR §1 (`SPEC.md:9007`), `EVOLUCAO.md:23`, `p0-crlf-import.md:64` | **feito**, nos quatro, com a mesma palavra |
| 2. promessa encolhe para **só `continue`** | aviso de 10 linhas **imediatamente acima** de `lidos += comTinta(bloco)` (`Corpus.swift:382-388`), mais ADR §1 e o relatório anterior | **feito**, no lugar certo e com os dois números |
| 3. portão só vale quando as contagens **DISCORDAM** | `Corpus.swift:330-335` + ADR §3 (`SPEC.md:9037-9045`), com `P0-SELO-CEGO`, `P1-RECUSA-MUDA` e `P2-CAMPO-QUE-SOME` escritas em `SPEC.md:9067/9075/9081` | **feito**; as três dívidas têm nome, número de linha e recomendação |
| 4. `LETRAS-ADR` | `grep -c '^| 09y'` = **1** (linha 82); uma única "Próxima livre" viva, dizendo `10a` (linha 89; a da 92 é prosa sobre um erro passado) | **feito** — e **conferir em vez de reescrever foi a decisão certa**: o `main` já tinha a linha, e `10a` é melhor que o `09z` que eu pedi |

O aviso do item 2 está no lugar que importa: o laço termina em `lidos += comTinta(bloco)`, e
é essa linha que o próximo autor lê antes de escrever um descarte. Conferi que é de fato a
**última instrução do corpo do laço** — a afirmação do comentário se sustenta por construção,
não por disciplina.

## 10.4 O texto novo descreve o limite como eu o medi? Sim

Fui eu quem achou o limite, então esta é a pergunta que só eu respondo. Li o aviso inteiro e
ele não sobra nem falta:

- *"A conta fecha-se sozinha SÓ PARA `continue`"* — verdadeiro, e **mais fraco** que a
  realidade (um `break` ou um `return` também encurtam a conta), o que é o lado certo do erro.
- *"truncar o que se guarda … importou 140 de 699 caracteres com `consumido = 1,00` e APAGOU
  o arquivo"* — é exatamente o bloco `AMANHA` de `medida-do-revisor.txt:17-21`, com o número
  corrigido.
- *"ler um campo a menos (`dominio`/`recordada`)"* — é N3 e N4 da minha tabela, que hoje
  imprimem `SUMIU e o arquivo APAGA` com `consumido 1.00`. Conferi `Corpus.swift:147/151`:
  o app **escreve** `dominio:` e `recordada:` mesmo.
- *"Filtrar `saida` depois do laço é a mesma família"* — verdadeiro, e eu não tinha escrito
  essa generalização com essas palavras; ela está certa.
- *"Já era assim em `main`"* sobre o `hits.isEmpty` — verdadeiro e verificável na minha
  própria tabela: N1 e N2 marcam `ANTES apaga = SIM`.

Conferi também as três referências de linha da dívida `P1-RECUSA-MUDA`:
`Entrada.swift:55` (`guard !itens.isEmpty else { continue }`), `Sessao.swift:1394`
(`guard !arquivos.isEmpty else { return }`) e `Sessao.swift:1428` (`guard total > 0 else
{ return }`) — a frase *"o autor larga um `.md` na pasta, abre o app e não acontece nada"* é
**verdadeira**. E a ADR diz, por conta própria, que **esta volta aumenta a frequência desse
caminho**. Autocrítica que eu não pedi e que conta.

## 10.5 O número: 140 de **699**, e os três lugares concordam

O autor achou um erro **meu**, que virou lei na ESTEIRA: eu havia escrito *"140 de 659"*.
O certo tem três partes — **699** é o que o arquivo tem, **140** é o que o descarte importa,
**659** é o que o caminho de hoje importa, e os **40** de diferença são a tinta do cabeçalho
creditada sem virar nota, que é o defeito em pessoa. Conferência dos lugares:

| lugar | diz | ok |
|---|---|---|
| `Corpus.swift:307` / `:387` | 699 de tinta, 659 viram nota / 140 de 699 | ✔ |
| ADR 09y (`SPEC.md:9019-9025`) | 140 de 699 · 699 de tinta, 659 viram nota | ✔ |
| `EVOLUCAO.md:23` | 140 de 699 · 659 de 699 | ✔ |
| `p0-crlf-import.md:79/82`, `p0-crlf-b.md:22/24/34` | 140 de 699 · 659 de 699 | ✔ |
| **este relatório, §2** | dizia **659**. **Corrigido por mim nesta seção**, com a correção declarada no lugar do erro | ✔ |
| `ferramentas/orca/ESTEIRA.md:1420` **deste worktree** | ainda diz "140 de 659" | — já **corrigido no `main`** (`8fe1fb0`, *"140 de 699, não de 659"*), que diz 699 e explica as três partes. O worktree está só atrasado e a mescla o cura. **Não é defeito do candidato.** |

## 10.6 A suíte não rodada: ausência **declarada e correta**

Concordo com o autor, e a prova é a de 10.1: o **único** Swift em target que mudou é
comentário (`swiftc -parse` rc=0), e nenhum arquivo de target fora de Swift foi tocado. A
suíte verde de `21939ae` vale sem mudança — e eu já a auditei por **nome**, não por contagem:
os dois testes **exclusivos deste candidato** aparecem em `nomes-executados-901.txt`
(`grep -x` = 1 cada):

```
arquivoSoSaiDaEntradaQuandoOAppLeuTudo                1
oQueOAppLeuInteiroContinuaPodendoSairDaEntrada        1
```

**Não rodar a suíte aqui é a decisão certa**, e gastar um aparelho nela seria desperdício.
Registro como **ausência declarada e correta — não é lacuna, e não desconta nota.**

## 10.7 Scorecard final (revisor independente)

| dimensão | antes (§7) | agora | o que mudou |
|---|---|---|---|
| Contrato | 8 | **9** | a ADR deixou de prometer o que o código não faz: a invariante tem o nome certo, a promessa do "`continue` de amanhã" encolheu com dois contraexemplos numerados, o portão diz onde não vale, e a `09y` está no `LETRAS-ADR` uma vez só |
| Estado honesto | 8 | **9** | a alegação derrubada está **citada e corrigida no lugar onde estava** (inclusive no relatório anterior do autor, com um "CORRIGIDO depois do G3" em vez de reescrita silenciosa); as três dívidas têm nome e linha; a suíte não rodada está declarada com a razão; e ele corrigiu um número **meu** |
| Visão · Correção · Jornada real · Privacidade e autoria · Simplicidade · Complexidade · Performance · Relato | 9 | **9** | inalteradas — o candidato não tocou nenhuma linha de lógica, provado em 10.1 e 10.2 |
| Design / Movimento / Componentes / Acessibilidade / Fora do app | n/a | **n/a** | motor puro; nenhuma view, token ou cópia de tela no diff |

**Nenhuma dimensão abaixo de 9. Aprovo a mescla de `0f3b4a1`.**

Uma nota de caneta, do dono da ESTEIRA e não do autor: a linha 82 do `LETRAS-ADR.md` ainda
intitula a 09y com *"o app **leu** tudo"*. É texto do `main`, o autor foi mandado **conferir**
e conferiu certo; trocar uma palavra ali é uma linha de quem cuida do arquivo.

**Provas desta seção:** `ferramentas/orca/revisao-p0-crlf/montar.sh` (rodado sobre `0f3b4a1`),
`medida-do-revisor.txt:1-16` (casa linha a linha com a corrida de hoje), `nomes-executados-901.txt`.
