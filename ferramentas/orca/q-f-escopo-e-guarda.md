# Q-F — a prova do escopo, e a guarda do vazamento provada pela FORMA

Implementador, worktree `volta-q-qualidade`, 08/09/2026. Nenhuma ADR nova: esta passada
**conserta duas afirmações** do re-G3 (terceiro) e **troca uma prova lexical por uma
estrutural**. Simulador `34CC3F94` (ligado por mim, desligado por mim ao fim). O `C2416CBC`
(Grok) **não foi tocado**: nenhum build, nenhum install, nenhum teste, nenhuma corrida nova de
IA. As quatro recusas expostas e as quatro indeterminadas ficam exatamente como estavam.

## 1. A alegação de equivalência era grande demais — CORRIGIDO pelo caminho (a)

**O que `1a4cacf` dizia:** "desfazer a troca no lado novo do diff devolve o lado velho
caractere por caractere — nada mais entrou junto". **Isso é falso para o commit.** O re-G3
repetiu a substituição literal sobre a árvore inteira e sobraram hunks; conferi e confirmo,
com o mesmo método:

```sh
# lado velho = pai; lado novo = commit, com a troca desfeita globalmente
for f in $(git show --name-only --format= 1a4cacf); do
  git show "1a4cacf^:$f" > velho/$f
  git show "1a4cacf:$f" | sed 's/08q/08k/g; s/08r/08m/g' > novo/$f
done
diff -ru velho novo | grep -c '^@@'   # → 8   (com -U0: 11)
```

`git show --stat 1a4cacf` = **16 arquivos, 223 inserções, 56 remoções**. Não 50 linhas.

**Escolhi o caminho (a): restringir a alegação e a prova ao artefato de renumeração.** Não
separei em dois commits porque `1a4cacf` já é citado pelo SHA no veredito do revisor e em
`revisao-q-qualidade.md`; reescrever história invalidaria essas referências, e o defeito é da
frase, não dos arquivos.

### A frase certa, e ela diz o que MAIS entra no mesmo commit

> O commit `1a4cacf` traz a renumeração `08k → 08q` / `08m → 08r` — **49 linhas, 55
> ocorrências, listadas uma a uma abaixo** — **e, na mesma passada e de propósito**: a
> referência da ADR `08p` à seção do `ferramentas/orca/RUMO.md`; a nota de origem da letra
> dentro das ADRs `08q` e `08r` no `SPEC.md`; o conserto do aviso de compilador
> (`Text + Text` → `PerfilView.linhaDa`, `AttributedString`) e o teste novo em
> `TracoTests/PerfilQualidadeTests.swift`; a nota "RESOLVIDO na Q-E" e duas atualizações de
> texto no relatório `q-d-origem-sem-vazamento.md`; e o relatório novo
> `q-e-letras-e-fecho.md`. **A equivalência caractere por caractere vale para a lista de 55
> ocorrências, não para o commit.**

Essa é a redação que passou a valer em `q-e-letras-e-fecho.md` §1 e na linha "Contrato" do
scorecard de lá. Nenhuma frase em nenhum relatório desta volta continua dizendo que o commit
inteiro só renomeia. **O que não dá para consertar:** a mensagem de commit de `1a4cacf` já
está escrita e não reescrevo história — esta seção é a errata, e ela vive no repositório.

### As 49 linhas de renumeração pura (arquivo:linha do lado novo de `1a4cacf`, de → para)

Desfazer exatamente estas 55 ocorrências devolve o lado velho **caractere por caractere**
nestas 49 linhas — provado pela reversão global acima, que não deixa nenhuma delas no `diff`
residual.


**EVOLUCAO.md**
- `EVOLUCAO.md:18` — `08k` → `08q` (x2), `08m` → `08r` (x2)

**QUALIDADE-IA.md**
- `QUALIDADE-IA.md:27` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:29` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:31` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:115` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:121` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:125` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:131` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:139` — `08k` → `08q` (x1)
- `QUALIDADE-IA.md:141` — `08m` → `08r` (x1)

**SPEC.md**
- `SPEC.md:5744` — `08k` → `08q` (x1)
- `SPEC.md:5769` — `08k` → `08q` (x1)
- `SPEC.md:5789` — `08m` → `08r` (x2)
- `SPEC.md:5797` — `08m` → `08r` (x1)
- `SPEC.md:5864` — `08m` → `08r` (x1)
- `SPEC.md:5866` — `08m` → `08r` (x1)
- `SPEC.md:5868` — `08m` → `08r` (x1)
- `SPEC.md:5872` — `08k` → `08q` (x2)
- `SPEC.md:5878` — `08k` → `08q` (x1)
- `SPEC.md:5902` — `08k` → `08q` (x1)
- `SPEC.md:5906` — `08k` → `08q` (x2)
- `SPEC.md:5910` — `08k` → `08q` (x1)

**Traco/Analise/AvaliacaoIA.swift**
- `Traco/Analise/AvaliacaoIA.swift:195` — `08k` → `08q` (x1)

**Traco/Analise/Grok.swift**
- `Traco/Analise/Grok.swift:51` — `08m` → `08r` (x1)

**Traco/Analise/Politica.swift**
- `Traco/Analise/Politica.swift:9` — `08k` → `08q` (x1)
- `Traco/Analise/Politica.swift:162` — `08k` → `08q` (x1)

**Traco/Perfil/PerfilView.swift**
- `Traco/Perfil/PerfilView.swift:580` — `08k` → `08q` (x1)

**TracoTests/GrokContratoTests.swift**
- `TracoTests/GrokContratoTests.swift:16` — `08m` → `08r` (x1)
- `TracoTests/GrokContratoTests.swift:25` — `08m` → `08r` (x1)
- `TracoTests/GrokContratoTests.swift:33` — `08m` → `08r` (x1)

**TracoTests/PoliticaTests.swift**
- `TracoTests/PoliticaTests.swift:44` — `08k` → `08q` (x1)

**ferramentas/orca/q-b-teto-e-candidato.md**
- `ferramentas/orca/q-b-teto-e-candidato.md:10` — `08k` → `08q` (x1)
- `ferramentas/orca/q-b-teto-e-candidato.md:24` — `08k` → `08q` (x1)
- `ferramentas/orca/q-b-teto-e-candidato.md:84` — `08k` → `08q` (x1)
- `ferramentas/orca/q-b-teto-e-candidato.md:106` — `08k` → `08q` (x1)
- `ferramentas/orca/q-b-teto-e-candidato.md:116` — `08m` → `08r` (x1)
- `ferramentas/orca/q-b-teto-e-candidato.md:238` — `08k` → `08q` (x1)

**ferramentas/orca/q-perfil.md**
- `ferramentas/orca/q-perfil.md:7` — `08k` → `08q` (x1)
- `ferramentas/orca/q-perfil.md:77` — `08k` → `08q` (x1)
- `ferramentas/orca/q-perfil.md:78` — `08k` → `08q` (x1)
- `ferramentas/orca/q-perfil.md:122` — `08k` → `08q` (x1)

**Total: 49 linhas, 55 ocorrências** (`EVOLUCAO.md:18`, `SPEC.md:5789`, `SPEC.md:5872`,
`SPEC.md:5906` trocam duas ocorrências na mesma linha).

### As outras 12 linhas com `08q`/`08r` NÃO são renumeração pura

Elas nasceram ou mudaram nesta passada por outro motivo, e por isso ficam fora da alegação de
equivalência. Estão listadas para que a conta feche: 61 linhas do commit contêm as letras
novas, 49 são renumeração pura, 12 são estas.


**SPEC.md** (mista)
- `SPEC.md:5862` — `08m` → `08r` (x1)

**ferramentas/orca/q-d-origem-sem-vazamento.md** (mista)
- `ferramentas/orca/q-d-origem-sem-vazamento.md:26` — `08k` → `08q` (x2)
- `ferramentas/orca/q-d-origem-sem-vazamento.md:39` — `08k` → `08q` (x1)
- `ferramentas/orca/q-d-origem-sem-vazamento.md:40` — `08m` → `08r` (x1)
- `ferramentas/orca/q-d-origem-sem-vazamento.md:41` — `08k` → `08q` (x1)
- `ferramentas/orca/q-d-origem-sem-vazamento.md:172` — `08k` → `08q` (x1), `08m` → `08r` (x1)

**ferramentas/orca/q-e-letras-e-fecho.md** (mista)
- `ferramentas/orca/q-e-letras-e-fecho.md:13` — `08k` → `08q` (x1)
- `ferramentas/orca/q-e-letras-e-fecho.md:14` — `08m` → `08r` (x1)
- `ferramentas/orca/q-e-letras-e-fecho.md:29` — `08k` → `08q` (x1), `08m` → `08r` (x1)
- `ferramentas/orca/q-e-letras-e-fecho.md:50` — `08k` → `08q` (x1), `08m` → `08r` (x1)
- `ferramentas/orca/q-e-letras-e-fecho.md:88` — `08k` → `08q` (x1)
- `ferramentas/orca/q-e-letras-e-fecho.md:126` — `08k` → `08q` (x1), `08m` → `08r` (x1)

## 2. A prova de privacidade passa a ser ESTRUTURAL — CORRIGIDO

**O que estava errado:** `cadaRecusaDaPreparacaoDizQualGuardaFoiSemVazarOConteudo` compara
`Prova.normal(linha)` contra as palavras normalizadas do exemplo, mas filtra `$0.count >= 5`.
Palavras de 1 a 4 letras ficavam sem asserção, e o relatório dizia "palavra a palavra" — mais
do que o teste fazia. E o filtro **não é um descuido**: por `contains`, palavra funcional do
exemplo ("la", "en", "de") casaria com a prosa da própria recusa ("a partir da palavra 1 de
7") e acusaria vazamento onde não há. O comentário do teste agora diz isso, e aponta para a
prova geral.

**O que protege o autor de verdade é a FORMA da recusa**, não uma lista de palavras:
`Recusa` não tem campo nenhum que carregue o trecho. Ela serializa categoria, nome de campo do
contrato, índice, posição, tamanho e contagem de origem — e o trecho morre dentro de `provar`,
na linha `let termos = casado.trecho.split(...)`, de onde só sai `termos.count`.

**O teste novo** (`TracoTests/PraticaTrabalhoTests.swift`,
`nenhumCampoDaRecusaCarregaPalavraDoExercicio`) prova isso assim:

1. **Um exercício em que CADA palavra é um marcador inventado** — `q`, `zk`, `vún`, `nubz`,
   `plu`, `wix`, `mub`, `tyz`, `krebli`, `gorrênita`, `qanaptu`, `ferzol`. **Oito têm de 1 a 4
   letras**, e três levam acento de propósito, para que a normalização também seja exercida.
   Nenhum deles existe na prosa das recusas: por isso a conferência pode ser por **igualdade
   de token normalizado**, e não por `contains`. O exercício marcado é válido
   (`#expect(PraticaTrabalho.validar(comMarcador()) != nil)`), então cada recusa abaixo vem de
   uma alteração deliberada, não de o texto ser estranho.
2. **Um caso de cada uma das 12 guardas da enum**, com o número conferido:
   `#expect(cobertos.count == 12)`. Caso novo sem varredura derruba essa conta.
3. **A varredura é da serialização INTEIRA**, não da linha: `recusa.redigida` **mais**
   `String(reflecting: recusa)`, que carrega todos os valores associados. Se alguém
   acrescentar um campo com o texto, o marcador aparece no dump.

**Prova de que o teste morde** (mutação, feita e desfeita nesta passada): trocando em
`provar` o `nome` do campo pelo `valor` — `.campoAcimaDoTeto(valor, tamanho:...)` em vez de
`.campoAcimaDoTeto(nome, tamanho:...)`, um único token — o teste falha e diz qual palavra e
qual caso:

```
✘ recorded an issue at PraticaTrabalhoTests.swift:521:13: Expectation failed:
  (palavras → ["recusa", "400", "gorrenita", "tem", "campoacimadoteto", ...])
  .isDisjoint(with: doExercicio → ["nubz", "krebli", "qanaptu", "vun", "zk", "q", ...])
↳ ["gorrenita"] em .campoAcimaDoTeto("gorrênita gorrênita ...", tamanho: 400, teto: 200)
```

A mutação foi revertida antes do build de fecho (`git diff` de `Traco/` vazio).

**Fronteira declarada, e ela não foi fechada:** `chavesForaDoContrato` ecoa o **nome** da chave
a mais que veio na resposta do provedor, cortado em 32 caracteres. Nome de chave é forma do
contrato, não o exercício da pessoa — mas é o **único** texto da resposta que chega à linha
gravada, e por isso está afirmado no próprio teste
(`#expect(chaveEstranha.redigida.contains("gorrênita"))`) em vez de ficar por omissão. Fechar
isso seria mexer no parser, que não é desta volta.

**O que o teste NÃO cobre, dito com todas as letras:** ele varre a serialização da `Recusa`.
Não prova nada sobre o que a `entrada` da sonda grava (que é o pedido do autor, por decisão da
`08p`), nem sobre o corpo bruto da resposta, que continua descartado.

## 3. O que esta passada NÃO fez

- **Não mexi no parser nem na régua do vazamento.** `Prova.vaza`, `Prova.vazamento` e
  `PraticaTrabalho.provar` estão byte a byte como estavam em `1a4cacf`. A `08p` continua
  dizendo que a régua é volta própria, e continua verdade.
- **Não toquei no `C2416CBC`.** Nenhuma corrida nova de IA. As quatro recusas expostas e as
  quatro indeterminadas ficam como estão.
- **A foto do cartão CONTA continua lacuna declarada.** Não a fechei e não fingi que fechei.
- Não reescrevi história: `1a4cacf` continua com o SHA que o revisor cita.
- Nenhuma ADR nova no `SPEC.md`: esta passada não decide nada, corrige duas afirmações e
  troca uma prova. `EVOLUCAO.md` não muda porque nenhuma lacuna fechou.

## 4. Arquivos tocados

| arquivo | o quê |
|---|---|
| `TracoTests/PraticaTrabalhoTests.swift` | teste novo `nenhumCampoDaRecusaCarregaPalavraDoExercicio` (+ o auxiliar `provaRecusada`); comentário do teste antigo passa a dizer por que o corte em 5 letras existe e para onde ir para a prova geral |
| `SPEC.md` | ADR `08p`: uma frase dizendo que a garantia é estrutural, o que o teste varre e qual fronteira fica aberta. **Nenhuma ADR nova, nenhuma letra nova** |
| `ferramentas/orca/q-e-letras-e-fecho.md` | §1 e o scorecard: a alegação de equivalência passa a valer para a lista de 55 ocorrências, e a frase diz o que mais entra no commit |
| `ferramentas/orca/q-d-origem-sem-vazamento.md` | §"O teste de privacidade" e o scorecard: "palavra a palavra" vira "palavras de 5+ letras", com o porquê e o ponteiro para a prova estrutural |
| `ferramentas/orca/q-f-escopo-e-guarda.md` | este relatório |

`Traco/**` **não mudou**: `git diff 1a4cacf --stat -- Traco/` é vazio.

## 5. Prova de fecho

Simulador `34CC3F94-FDB5-4575-A4F5-80271829A18B` (iPhone 17 Pro "teste 3"), ligado por mim,
desligado por mim ao fim. Tudo por `ferramentas/orca/com-trava.sh` — segurei a trava em cada
build e em cada corrida de teste.

- **Build limpo**, `xcodebuild -destination id=34CC3F94… clean build-for-testing`:
  `** TEST BUILD SUCCEEDED **` · `grep -c "warning:"` = **0**
- **Suíte integral**, `-parallel-testing-enabled NO test-without-building`:
  `✔ Test run with 919 tests in 149 suites passed after 9.133 seconds.` ·
  `** TEST EXECUTE SUCCEEDED **` · `grep -c "warning:"` = **0**
  (eram 918 em `1a4cacf`; o teste novo é `nenhumCampoDaRecusaCarregaPalavraDoExercicio`)

Nenhuma captura de tela nesta passada: ela não muda nenhuma superfície. Nenhum maestro.

## 6. Estado em que deixo os aparelhos

- `34CC3F94` — **ligado por mim, desligado por mim** ao fim desta passada. Não rotacionei, não
  mexi em tamanho de letra.
- `C2416CBC` (Grok) — **intocado**: nenhum `erase`, `clearState`, `uninstall`, `install`,
  `xcodebuild` nem `test`, e nenhuma corrida de IA. Continua ligado, como estava.
- Os outros dois simuladores de outras voltas — não toquei, não desliguei.
- Nenhuma voz, nenhuma Siri, nenhum VoiceOver, nenhum iPad em nenhum momento. Não toquei no
  mouse nem no teclado do Mac.

## Scorecard (meu; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 9 | a alegação de equivalência agora tem o mesmo tamanho da prova: 49 linhas e 55 ocorrências listadas uma a uma, e a frase nomeia as outras cinco mudanças que entram no mesmo commit |
| Estado honesto | 9 | a errata está no repositório, não só no relatório; digo que a mensagem de `1a4cacf` continua errada e por que não reescrevo história; declaro a fronteira de `chavesForaDoContrato` e o que o teste não cobre |
| Privacidade e autoria | 9 | a prova deixou de ser lexical: varre a serialização inteira de um caso de cada uma das doze guardas, e a mutação de um token mostrou o teste caindo |
| Correção | 9 | 919 testes em 149 suítes verdes, build com 0 avisos; a conta de casos cobertos (12) cai se alguém acrescentar guarda sem varrer |
| Simplicidade | 9 | nenhum código de produção mudou; o teste é um `isDisjoint` sobre um dump, sem armação nem dependência nova |
| Jornada real | 6 | nada de novo na jornada; a foto do cartão CONTA segue lacuna declarada, e não a fingi fechada |
| Visão | 9 | a volta passa a dizer sobre a própria IA exatamente o que consegue provar — que é o ponto de o autor confiar no que o Traço diz |
| Demais dimensões | n/a | passada de teste e de texto: sem design, movimento, componente, acessibilidade nem fora do app |
