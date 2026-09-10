# P0-CRLF-B — as quatro correções de TEXTO, e a invariante ganha o nome certo

**Candidato:** branch `Vitorepf/p0-crlf`, worktree `/Users/vitorepf/orca/workspaces/traco-ios/p0-crlf`.
**Base:** `21939ae` (o conserto, aprovado pelo G3) + `9452c5d` (o relato do G3) + merge de
`origin/main` (`8f42e19`).
**Linha do ciclo.** Fecha o G1 do P0 depois do G3; serve à intenção *"o trabalho do autor não
some"*; reduz o obstáculo *"o conserto está certo e a alegação está grande demais"*; prova-se
por o revisor aprovar a mescla, que ele já disse que faz com as quatro feitas.

**Zero linha de lógica.** O diff em `.swift` é **100% comentário**, provado por comando abaixo.

---

## 1. O que o G3 derrubou, e o que eu escrevi no lugar

A alegação forte do meu relatório — *"qualquer `continue`, inclusive um que alguém acrescente
amanhã, deixa a conta curta sozinho"* — **vale só para `continue`**. Os dois contraexemplos do
revisor não são hipotéticos e eu não os disputo:

| contraexemplo | medida do G3 | o que a conta diz |
|---|---|---|
| teto de **140 grafemas** da ADR 08h, no estilo da casa, **sem `continue` novo** | importa **140 de 699** caracteres com tinta | `consumido = 1,00` e **apaga** |
| `dominio` e `recordada`, que o app **escreve** e o importador **nunca lê** | somem na volta pela `entrada/` | `consumido = 1,00` e **apaga** |
| a tinta do **cabeçalho**, creditada sem virar nota | **659 de 699** viram texto de nota | `consumido = 1,00` |

**Logo o nome estava errado, e o nome era a parte cara.** Não é cobertura de **leitura**: é
cobertura de **DELIMITAÇÃO** — prova que todo byte caiu dentro de um bloco que foi `append`ado,
não que virou nota. O próximo lê `consumido` e confia; nome errado se paga com juros.

## 2. As quatro correções, uma a uma

**1) `Traco/Notas/Corpus.swift` — o comentário de `importarComEstado`.** Trocado *"a fração dos
caracteres com tinta do arquivo que viraram nota"* por **a fração que caiu DENTRO de um bloco
`append`ado**, com os números: 699 de tinta, 659 viram nota, `consumido` diz 1,00 — os 40 de
diferença são a tinta do cabeçalho. Diz também que campo que o parser não lê (`dominio`,
`recordada`, `gesto:` fora do catálogo) **some com a conta dizendo 100%**.

**2) `Corpus.swift` — o limite da alegação, escrito onde o próximo vai escrever o descarte.**
O aviso ficou **colado em `lidos += comTinta(bloco)`**, não no topo do arquivo: é essa a linha
que alguém lê antes de acrescentar um `saida.append((String(corpo.prefix(140)), …))`. Diz o que
é verdade — fecha para `continue`, e por construção, porque é a última instrução do laço — e o
que **não** é: truncar o que se guarda, filtrar `saida` depois do laço, ou ler um campo a menos
**não** encurtam a conta, com o número dos dois contraexemplos.

**3) `Corpus.swift` e ADR §3 — o portão só vale quando as contagens DISCORDAM.** A frase
*"cabeçalho não lido pode ser um selo: nada entra como do autor e nada se apaga"* descreve uma
garantia que só existe no eixo do fim de linha. Quando **as duas** contagens são cegas ao mesmo
cabeçalho malformado, o arquivo cai no ramo `hits.isEmpty`, que é **fail-open**. Está escrito no
comentário do portão e na ADR, com a dívida **P0-SELO-CEGO** nomeada e a **recomendação medida**
do revisor (uma cláusula `||`: um arquivo que **abre** com a cerca `---` afirma ter estrutura que
este parser não entendeu — fecha os dois casos de selo invisível sem regressão nos dois que
**têm** de continuar apagando).

**4) `ferramentas/orca/LETRAS-ADR.md` — já estava feito, e eu conferi em vez de reescrever.**
O merge de `origin/main` trouxe o arquivo inteiro com a linha da `09y` escrita e a série 09
encerrada na `09z`. Conferido por comando, não de memória:

```
$ grep -c '^| 09y' ferramentas/orca/LETRAS-ADR.md   →  1
$ grep -c '09y'    ferramentas/orca/LETRAS-ADR.md   →  1     (uma vez só no arquivo todo)
$ grep -n 'Próxima livre' ferramentas/orca/LETRAS-ADR.md
  89:**Próxima livre: 10a.**
  92:"Próxima livre: 09s" que estava escrito aqui batia com o comando; no mesmo
```

A linha 92 é **citação dentro do relato histórico da colisão da `09s`**, não uma segunda
declaração viva. Declaração viva há **uma**, e diz `10a`, porque a série 09 acabou na `09z`.
**Sem letra nova nesta volta: é a 09y corrigida.**

**Onde mais a alegação estava escrita, e também foi corrigida** (a ordem era *"onde estiver
escrito"*, e o veredito do G3 nomeia os três: a ADR, o comentário e o EVOLUCAO):
`SPEC.md` (ADR 2026-09-09y, item 1, item 3, dívidas e um parágrafo novo dizendo o que o G3
derrubou), `EVOLUCAO.md` (a célula do P0-CRLF) e `ferramentas/orca/p0-crlf-import.md` (o meu
relatório da volta anterior, com a correção marcada **no lugar da frase errada**, não escondida
no fim).

**O que eu NÃO toquei, de propósito:** `ferramentas/orca/p0-crlf/harness.swift:72-73` guarda a
mesma frase antiga. É **artefato datado de medida**, cópia do que foi medido naquele dia — log
não se reescreve para ficar bonito. Fica dito aqui.

## 3. A dívida que fica nomeada, e NÃO foi consertada aqui

**A recusa é MUDA.** Arquivo não consumido não gera frase nenhuma: `Entrada.arquivos` descarta
sem itens (`Entrada.swift:56`), a lista vazia sai no `guard !arquivos.isEmpty`
(`Sessao.swift:1394`), e com `total == 0` nem o toast final corre (`Sessao.swift:1428`). O autor
larga um `.md` na pasta, abre o app e **não acontece nada**. E esta volta **aumenta a frequência**
desse caminho: o que antes importava errado agora é recusado em silêncio. É a troca certa (dado
acima de aviso) e é um custo novo — mesma família da *espera calada* da DIRETRIZ §13.
**Dono na próxima volta de `entrada/`.**

As três dívidas ficaram escritas na ADR com nome e número — **P0-SELO-CEGO**, **P1-RECUSA-MUDA**,
**P2-CAMPO-QUE-SOME**. **Não escrevi no `RUMO.md`**: a ordem foi *"faça exatamente as quatro, não
mais"*, e o `RUMO` é do orquestrador (foi assim que a linha da `09y` chegou). As três estão
prontas para copiar.

## 4. Instrumento — o que eu rodei, e o que eu não rodei

**Nenhum aparelho de conta foi tocado.** `B91C8DEF` e `34CC3F94` não foram lançados, instalados,
fotografados nem desligados. Nenhum `xcodebuild`, nenhum `simctl`, nenhum MCP de build. Esta
volta é texto e não pediu aparelho — nem o de suíte (`A1DF082C`).

**O que eu provei, e como:**

1. **O diff em Swift é comentário e nada mais** — toda linha `+`/`-` de `Corpus.swift` começa
   com `//` ou `///`:
   ```
   $ git diff -- Traco/Notas/Corpus.swift | grep -E '^[+-]' | grep -v '^[+-][+-]' \
       | grep -vE '^[+-][[:space:]]*(///|//)'
   (vazio)
   ```
2. **O arquivo continua sendo Swift válido:** `xcrun swiftc -parse Traco/Notas/Corpus.swift` → `rc=0`.
3. **O comportamento não mudou, medido pelo harness do REVISOR, não pelo meu.**
   `ferramentas/orca/revisao-p0-crlf/montar.sh` extrai o corpo de `importarComEstado` por `awk`
   **do código vivo** e o compila com `swiftc -O`. Rodei **antes** e **depois** das minhas
   edições: saída **idêntica byte a byte** nos dois, e **idêntica** às 15 primeiras linhas de
   `medida-do-revisor.txt`. Como o `awk` começa em `nonisolated static func importarComEstado`,
   os comentários que eu mexi **dentro** do laço entraram na compilação — não é um teste que
   passou por não olhar.
   ```
   $ diff baseline.txt depois.txt        → IDÊNTICO ao baseline (14 casos)
   $ head -15 medida-do-revisor.txt | diff - <(head -15 depois.txt)  → IDÊNTICO
   ```
   Duas linhas dessa tabela são a **prova de que o vigia enxerga** — ele acusa:
   ```
   N3 gesto desconhecido     | SIM         | SIM          |      1.00 |     1 | SUMIU e o arquivo APAGA
   N4 export com dominio     | SIM         | SIM          |      1.00 |     1 | SUMIU e o arquivo APAGA
   ```
   São os dois casos que eu acabei de escrever no comentário e na ADR, reproduzidos **por mim**,
   nesta árvore. O número 140/699/659 do teto de 140 grafemas é do bloco `AMANHA` de
   `medida-do-revisor.txt`: o revisor rodou esse caso à parte e **não** o comitou em
   `casos-do-revisor.swift`, então eu o cito como medida dele, com caminho, e não como minha.
4. **O merge não trouxe Swift do app:** `git diff --stat 21939ae..HEAD -- '*.swift'` só acusa
   `ferramentas/orca/revisao-p0-crlf/casos-do-revisor.swift` (+69), que **não é fonte de nenhum
   target** — `project.yml` tem `Traco`, `TracoTests`, `TracoUITests` e `TracoWidget`, nunca
   `ferramentas/`. Sem arquivo novo em target, **`xcodegen generate` não é preciso**.

**A suíte NÃO foi rodada nesta volta, e eu não a alego.** O G3 rodou-a no candidato
(`1021 testes em 163 suítes`, build LIMPO, 1 warning herdado em `NotasView.swift:806`,
901 nomes auditados e 0 de fora). O meu delta sobre aquele verde é comentário em um `.swift` e
Markdown, com o merge sem tocar em fonte de target — provado nos itens 1, 2 e 4. Rodar a suíte
para um diff de comentário custaria o aparelho de suíte a outra volta de IA, que é onde o dono
mandou o foco ir. **É custo declarado, não medida escondida.**

## 5. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | **9** | a lacuna do EVOLUCAO continua fechada pelo conserto do G3; esta volta protege quem **lê** o conserto depois |
| Contrato | **9** | as três frases que prometiam mais do que o código faz foram trocadas pelo que ele faz, com o número dos dois contraexemplos; a `09y` está no `LETRAS-ADR` uma vez só, conferida por `grep -c` |
| Correção | **9** | zero linha de lógica (provado por `grep` no diff); `swiftc -parse` rc=0; harness do revisor recompilado e **idêntico** antes/depois e idêntico à medida dele |
| Jornada real | **8** | herdada do candidato: o disco foi provado com `cmp` dos dois lados, mas a captura da volta anterior é a folha vazia, não a lista de notas. Esta volta é texto e não move essa nota |
| Privacidade e autoria | **9** | as três rotas que convertiam `origem: modelo` em voz do autor continuam fechadas; nenhuma aberta aqui — o diff não toca lógica |
| Simplicidade | **9** | quatro correções, quatro arquivos, nenhuma linha executável |
| Complexidade | **9** | +101/−21 em 4 arquivos, tudo comentário e Markdown; nenhum arquivo novo além do relato, nenhuma dependência |
| Performance | **n/a** | nada executável mudou |
| Estado honesto | **9** | a alegação derrubada está **citada e corrigida no lugar onde estava**, inclusive no meu relatório anterior; a suíte não rodada está dita com o custo; o harness datado está dito como não tocado; o 140/699 está atribuído ao revisor porque o caso não está comitado |
| Relato | **9** | todo comando colado com a saída; as duas linhas do vigia que ACUSA coladas |
| Design / Movimento / Componentes / Acessibilidade / Fora do app | **n/a** | nenhuma view, token ou cópia de tela tocada |

**Limites do instrumento, declarados (não descontam nota):** suíte não rodada nesta volta (item
4.5); o caso `AMANHA` do revisor não está comitado, então o 140/699 é medida dele citada por
caminho, não reproduzida por mim; `VoiceOver` falado e tamanho de letra de acessibilidade são
proibidos (§12 e a ordem da voz) e não entram em prova nenhuma.

**Arquivos:** `Traco/Notas/Corpus.swift` (só comentário), `SPEC.md` (ADR 2026-09-09y),
`EVOLUCAO.md`, `ferramentas/orca/p0-crlf-import.md`, `ferramentas/orca/p0-crlf-b.md` (este).
Sem mesclar; SHA no `worker_done`.
