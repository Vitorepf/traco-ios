# Q-E — as duas letras que ainda colidiam, e o fecho da volta Q

Implementador, worktree `volta-q-qualidade`, 08/09/2026. Nenhuma ADR nova: esta passada
**corrige letras** e **fecha promessa**. Simulador `34CC3F94` (ligado por mim, desligado ao
fim). O `C2416CBC` (Grok) **não foi tocado**: nenhum build, nenhum install, nenhum teste.

## 1. As letras — CORRIGIDO

`08k` e `08m` desta branch colidiam com `main`, onde já são de voltas **mescladas**:

| letra desta branch | ADR desta branch | quem já tinha a letra em `main` |
|---|---|---|
| `08k` → **`08q`** | Quem responde, medido COM a conta: a quarta regra da tabela (volta Q) | `08k` = "A garantia sai da tela e vira invariante do documento" (V17-B) |
| `08m` → **`08r`** | O teto das rotas de Trabalho é medido, não suposto (volta Q-B) | `08m` = "O resultado da ação volta ao trabalho" (E1) |
| `08l` — fica | A terceira linha do Perfil (volta Q, Perfil) | ninguém |
| `08p` — fica | Por que o NOSSO parser recusou (voltas Q-C e Q-D) | ninguém |

**Conferência letra a letra, ref a ref**, depois de `git fetch` (`main` em `22961f2`, que é a
própria linha do RUMO citada abaixo):

| ref | letras `2026-09-08*` ocupadas |
|---|---|
| `main` / `origin/main` | a b c e f g h i j k m n o |
| `Vitorepf/volta-a1-arranque` | a b c e f g h i j k n |
| `Vitorepf/volta-v13-notas` | a b c e f g h i j k m n o |
| `wip/cinco-itens-grok46-16h39` | a b e g h i |
| **esta branch, depois da correção** | a b e g h i **l p q r** |

`08l`, `08p`, `08q` e `08r` não aparecem em nenhuma outra ref — conferidas uma a uma, não pela
união. A primeira letra livre é `08d`, e ela foi **recusada de propósito**: é buraco anterior
ao `08e`, e usá-la poria a volta Q antes de voltas que rodaram de manhã. `q` e `r` vêm depois
da maior letra em uso (`p`), que é desta branch.

**O que a renumeração NÃO conserta:** as mensagens de commit já escritas (`acdfcb4`, `46ae478`)
continuam dizendo `08k` e `08m`. Não reescrevi história. Cada uma das duas ADRs ganhou uma
linha em `SPEC.md` dizendo a letra de origem e por que mudou, para quem chegar pelo `git log`.

**Referências corrigidas** (50 linhas, 13 arquivos): `SPEC.md`, `EVOLUCAO.md`,
`QUALIDADE-IA.md`, `Traco/Analise/Politica.swift`, `Traco/Analise/Grok.swift`,
`Traco/Analise/AvaliacaoIA.swift`, `Traco/Perfil/PerfilView.swift`,
`TracoTests/PoliticaTests.swift`, `TracoTests/GrokContratoTests.swift`, e os relatórios
`q-qualidade.md`, `q-b-teto-e-candidato.md`, `q-perfil.md`, `revisao-q-qualidade.md`.

**Duas ocorrências ficaram como estavam, de propósito:** em
`ferramentas/orca/q-d-origem-sem-vazamento.md` §1, as citações "lá `08k` é 'A garantia sai da
tela' (V17-B)" e "`08m` é 'O resultado da ação volta ao trabalho' (E1)" falam das letras **de
`main`**, não das nossas. O relatório ganhou uma nota dizendo que a colisão foi resolvida aqui.

**O que sei, e o que eu tinha dito a mais** (corrigido na Q-F, a pedido do re-G3): esta
alegação estava grande demais. O commit `1a4cacf` **não** é só a renumeração — ele tem 16
arquivos e 223/56 linhas, e traz de propósito, na mesma passada: a referência da ADR `08p` ao
`ferramentas/orca/RUMO.md`, a nota de origem da letra nas ADRs `08q` e `08r`, o conserto do
aviso de compilador em `PerfilView.linhaDa` (`AttributedString`), o teste novo em
`PerfilQualidadeTests`, as atualizações do relatório da Q-D e este relatório novo.

O que é equivalente caractere por caractere é o **artefato de renumeração**, e ele é uma lista
explícita: **49 linhas, 55 ocorrências**, enumeradas uma a uma (arquivo:linha, de → para) em
`ferramentas/orca/q-f-escopo-e-guarda.md` §1. Desfazer exatamente essas 55 ocorrências devolve
o lado velho caractere por caractere naquelas 49 linhas; o que sobra são as outras mudanças
acima, nomeadas. Outras 12 linhas contêm `08q`/`08r` e **não** são renumeração pura: nasceram
ou mudaram nesta passada por outro motivo, e também estão listadas lá.

## 2. A `08p` aponta para o RUMO, e não promete o que esta volta não fez — FEITO

O orquestrador escreveu em `main` (`22961f2`) a seção **"A RÉGUA DO VAZAMENTO, nos dois
sentidos — volta própria, e ela vem antes de mexer no parser"**. A `08p` agora a cita pelo
nome, e diz na mesma frase o que **não** fez:

> Esta volta **não** escreveu a régua e **não** mexeu no parser: o que ela entrega é a medida
> e a pergunta, não o conserto.

Não trouxe `main` — a seção não existe no RUMO **desta** branch, e o merge é do orquestrador.

## 3. O aviso do build era NOSSO, não da volta A1 — CORRIGIDO

A Q-D declarou que o único aviso do build (`PerfilView.swift:637`, `'+' was deprecated in
iOS 26.0`) era "WIP da volta A1, não desta". **Está errado, e o `git blame` desmente:** a linha
nasceu em `42c0c20`, o commit do Perfil **desta branch** (ADR `08l`).

Conserto: `Text(nome).foregroundStyle(…) + Text(resto)` virou `PerfilView.linhaDa`, que devolve
uma `AttributedString`. **Por que `AttributedString` e não interpolação**, que é o que a
mensagem de obsolescência sugere: interpolar faria o texto passar por `LocalizedStringKey`, e
o `motivo` é **prosa do autor vinda da tabela `Politica`** — um `*` ou um `_` no motivo viraria
marcação. `AttributedString` é verbatim. Teste novo
(`a linha compõe nome tingido mais resto sem cor, e o texto não muda`) fixa as três coisas que
não podem mudar: o texto é o mesmo de antes, **um** run leva `Tema.tintaSuave`, e é o run do
nome.

**O que NÃO fiz:** não fotografei o cartão CONTA. A mudança é de composição de texto, provada
por teste sobre a `AttributedString`, não por captura. A lacuna de foto da terceira linha
continua aberta, como a `08l` já dizia.

## 4. O que preservei de propósito

Duas decisões das passadas anteriores, que o orquestrador registrou como aceitas e que **não**
foram desfeitas aqui:

- **ADR própria em vez de emenda à `08q`** — a `08p` decide sobre o NOSSO parser, não sobre a
  política do provedor; enterrá-la na ADR de política esconderia a decisão.
- **Posição e origem em vez de hash** — hash continua sendo oráculo de confirmação para quem já
  tem um palpite do texto, e não responde à pergunta da ADR.

E a disciplina que a redação mantém, palavra por palavra: as **quatro** recusas da corrida
`2DFC05C3` continuam **INDETERMINADAS**, não contadas a favor; e a correção contra a própria
redação anterior — a recusa por **limite** (1582 contra 1500) derruba "as onze outras guardas
não dispararam" — continua escrita na `08p`.

## 5. O que esta passada NÃO fez

Não trouxe `main`. Não toquei em `Traco/Notas/**`, `Traco/App/**` nem `Traco/Modelo/**`. Não
mexi no parser, não reabri o corte das sete rotas, não mudou nada na tabela `Politica`. Não
liguei nem usei o `C2416CBC`. Não reordenei as ADRs dentro do `SPEC.md` — a ordem do arquivo
já não era a das letras antes desta passada, e mexer nisso é diff grande sem leitor pedindo.

## 6. Prova

- Conferência de letras: `git grep -ohE '2026-09-08[a-z]'` em cada ref, depois de `git fetch`
  (`main` = `22961f2`), lida uma a uma — a tabela do §1.
- Build limpo no `34CC3F94`, `xcodebuild clean build-for-testing`:
  **0 avisos** (`grep -c "warning:"` = `0`) · `** TEST BUILD SUCCEEDED **`
- Suíte integral no `34CC3F94`, `-parallel-testing-enabled NO`:
  `✔ Test run with 918 tests in 149 suites passed after 9.151 seconds.` · `** TEST SUCCEEDED **`
  (917 antes; o teste novo é `a linha compõe nome tingido mais resto sem cor, e o texto não muda`)

## 7. Estado em que deixo os aparelhos

- `34CC3F94` — **ligado por mim, desligado por mim** ao fim desta passada.
- `C2416CBC` (Grok) — **intocado**: nenhum `erase`, `clearState`, `uninstall`, `install`,
  `xcodebuild` nem `test`. Continua ligado, como estava.
- Nenhuma voz, nenhuma Siri, nenhum VoiceOver, nenhum iPad em nenhum momento.

## Scorecard (meu; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 9 | `08q`, `08r`, `08l` e `08p` conferidas uma a uma em cinco refs depois de `fetch`; as duas ADRs dizem a letra de origem; a equivalência vale para a LISTA de 55 ocorrências (Q-F §1), não para o commit, que traz também o RUMO, as notas de origem, o aviso e o teste — a alegação larga foi corrigida na Q-F |
| Estado honesto | 9 | desmenti a atribuição errada da Q-D (o aviso era nosso, `git blame` em `42c0c20`); declarei que as mensagens de commit antigas continuam com as letras velhas; declarei que a foto do cartão não foi feita |
| Correção | 9 | 918 testes verdes, build limpo com **0** avisos; o teste novo fixa texto, número de runs tingidos e qual run |
| Privacidade e autoria | 9 | a troca de `+` por `AttributedString` foi escolhida **para não** passar prosa do autor por Markdown; nenhum dado novo sai para lugar nenhum |
| Simplicidade | 9 | uma função de 4 linhas substitui uma expressão; o resto da passada é renomeação e texto |
| Jornada real | 6 | nada de novo na jornada; a terceira linha do Perfil segue sem captura, e isso está dito em vez de contornado |
| Demais dimensões | n/a | passada de documento e de um aviso de compilador: sem componente, movimento, fora do app nem mudança de dados |
