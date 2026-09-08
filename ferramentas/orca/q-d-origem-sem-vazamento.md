# Q-D — a letra da ADR, o quadrigrama que não vaza, e a causalidade caso a caso

Implementador, worktree `volta-q-qualidade`, 08/09/2026. ADR **2026-09-08p** em `SPEC.md`
(era `08n`; ver §1). Responde aos três achados do **re-G3 (segundo)**.

## 1. A letra da ADR — CORRIGIDO, e não para a letra que o pedido dizia

O re-G3 achou a colisão e o orquestrador mandou renomear para `08o`. **`08o` também está
ocupada**: `main` e a volta V13 já têm `## ADR 2026-09-08o — A orientação diz de QUAL ação
está falando (volta E1-C)`. A letra livre é **`p`**, e é a que ficou.

Letras `2026-09-08*` ocupadas hoje, lidas branch a branch (`git show <branch>:SPEC.md`):

| branch | letras |
|---|---|
| `main` | a b e f g h i j k m n o |
| `Vitorepf/volta-a1-arranque` | a b e f g h i j k **n** |
| `Vitorepf/volta-v13-notas` | a b e f g h i j k m n **o** |
| `Vitorepf/volta-q-qualidade` (esta) | a b e g h i k l m **n → p** |

Referências corrigidas: `SPEC.md`, `EVOLUCAO.md`, `ferramentas/orca/q-c-recusa-auditavel.md`,
e os comentários de código em `PraticaTrabalho.swift`, `Prova.swift`, `OficinaTrabalho.swift`
e `AvaliacaoIA.swift`. O documento do revisor (`revisao-q-qualidade.md`) fica como ele o
escreveu — é o registro do achado, não uma referência a corrigir.

**Emendar a `08q` (então `08k`) em vez de abrir letra nova foi considerado, e recusado.** A `08q` decide a
QUARTA REGRA da tabela `Politica` a partir da medição do provedor; a `08p` decide outra coisa,
no nosso código: a recusa do parser vira `Result<_, Recusa>`, a régua passa a ter uma cópia só
e a sonda ganha `recusasDaPreparacao`. Enterrar isso dentro de uma ADR de política de provedor
esconderia a decisão de quem for procurá-la. Se o orquestrador discordar, o desfazer é barato:
é um corta-e-cola e uma renumeração.

**O que esta volta NÃO consertou, e o orquestrador precisa saber antes de mesclar:** as ADRs
`08k` e `08m` **desta branch também colidem com `main`** — lá `08k` é "A garantia sai da tela"
(V17-B) e `08m` é "O resultado da ação volta ao trabalho" (E1). Só a `08l` (Perfil) e a `08p`
estão livres. Não renumerei as duas porque não foram pedidas e porque são decisões de
despachos anteriores; a colisão está aqui declarada, não escondida.

> **RESOLVIDO na Q-E (08/09), a pedido do orquestrador:** `08k` desta branch virou **`08q`** e
> `08m` virou **`08r`**; `08l` e `08p` ficaram. Daqui para a frente este relatório fala de
> `08q` onde falava da ADR de política desta branch. As duas ocorrências acima que citam
> V17-B e E1 continuam dizendo `08k` e `08m` **porque são as letras de `main`**, não as nossas.
> Ver `ferramentas/orca/q-e-letras-e-fecho.md`.

## 2. O quadrigrama que vazava — CONSERTADO: posição e contagem, nunca o trecho

**O furo.** `Recusa.criterioVazaOExemplo(indice:trecho:)` conservava o quadrigrama
normalizado e `redigida` o emitia literalmente entre aspas; `MotorTrabalho` o punha em
`recusasDaPreparacao` e `AvaliacaoIA` o gravava no JSONL. Normalizar tira acento e
pontuação — **não tira o conteúdo**. Um exemplo com dado pessoal, texto selado ou
credencial em quatro palavras seria publicado pela sonda.

**A forma escolhida: posição + contagem de origem, decididas no momento da medida.**
A recusa passa a registrar

```
vazamento · o critério 3 repete 4 palavras seguidas do exemplo
            (a partir da palavra 12 de 84) · 3 dessas 4 palavras o autor já tinha
            escrito no pedido
```

- **posição** — qual critério, a partir de qual palavra do exemplo, de quantas;
- **origem** — QUANTAS das palavras do trecho o AUTOR já tinha escrito neste pedido
  (`instrucao` + `intencao` + `resultado`, exatamente os três campos que a sonda já grava
  em `entrada`, logo conferíveis por quem lê o JSONL);
- **nada do texto.** O trecho existe dentro de `provar` e morre lá.

**A defesa, em uma linha:** a contagem de origem responde a pergunta que a ADR faz — *de
quem é este vocabulário* — e o hash não responde; hash continua sendo oráculo de
confirmação para quem já tenha um palpite do texto, e o palpite perigoso é justamente o
dado pessoal em quatro palavras.

**Onde a escolha é fraca, dito antes que o revisor pergunte.** A conta é por PALAVRA, não
por sequência: exigir as quatro seguidas dentro do pedido seria quase sempre falso — o
autor escreve "separando o que foi concluído, a dependência e o próximo passo", não a
frase do exemplo — e não distinguiria nada. Em troca, palavra funcional ("a", "de") infla
a conta. Por isso a régua de leitura é **estrita**: só o valor CHEIO (todas as palavras do
trecho já escritas pelo autor) sustenta sozinho "isto é vocabulário do pedido"; qualquer
valor menor é indício, e está escrito como indício.

`pedidoDoAutor` **não entra na régua**: nada passa nem cai por causa dele. Quando não é
passado (todo chamador de teste que não o passa), a recusa diz `origem não conferida` —
não supõe zero.

**O teste de privacidade fechou o furo que o re-G3 nomeou.** Ele procurava só
`¿dónde está la estación?` quando a saída seria `donde esta la estacion`. Agora
`cadaRecusaDaPreparacaoDizQualGuardaFoiSemVazarOConteudo` normaliza a linha redigida e
varre **palavra a palavra do exemplo** (todas com 5+ letras: `pedir`, `informacao`,
`perdone`, `donde`, `estacion`, `licenca`, `estacao`) em cada uma das doze recusas. Teste
novo `aRecusaPorVazamentoContaAOrigemDoQuadrigramaSemOTrecho` cobre os três estados da
origem — nenhuma, todas, não conferida — e prova que a origem não muda o veredicto.

**O trecho que já está commitado não foi apagado.** `“a dependencia ainda aberta”` está na
`08p`, no `q-c-recusa-auditavel.md` e em `prova/qc-recusa-avaliacoes.jsonl`. Ele veio de
`revisor-sintetico-resumo-projeto-2x5`, **caso sintético autorizado** — a régua da volta
permite JSONL completo dessas entradas. Apagar a história para parecer limpo seria pior
que declará-la: o que muda é o MECANISMO, que não produz mais trecho nenhum.

## 3. A causalidade nas outras quatro — REMEDIDA, porque as quatro não eram recuperáveis

As quatro primeiras recusas da `2DFC05C3` gravaram só categoria e índice. O bruto foi
descartado (corretamente) e as corridas passaram: **não há como retro-expor evidência
nelas**. Em vez de inferir, remedi com o instrumento novo.

**Corrida `1B7E0E63`**, `C2416CBC`, os mesmos dois casos, 6 repetições. Conta conferida por
listagem **autenticada** de 12 modelos na abertura (`qd-fumaca-abertura`) e no fecho
(`qd-fumaca-fecho`), e `contaGrokLigada: true` em todos os registros.
**12 execuções de `prepararPratica`, 12 HTTP 200 completos de `grok-4.6`, 4 recusas nossas.**

Linhas redigidas, coladas do JSONL:

```
limite · enunciado tem 1582 caracteres e o teto é 1500
vazamento · o critério 3 repete 4 palavras seguidas do exemplo (a partir da palavra 19 de 95) · 4 dessas 4 palavras o autor já tinha escrito no pedido
vazamento · o critério 5 repete 4 palavras seguidas do exemplo (a partir da palavra 80 de 85) · 4 dessas 4 palavras o autor já tinha escrito no pedido
vazamento · o critério 4 repete 4 palavras seguidas do exemplo (a partir da palavra 73 de 78) · 4 dessas 4 palavras o autor já tinha escrito no pedido
```

### Veredito caso a caso

| ocorrência | guarda | evidência de origem | de quem é o defeito |
|---|---|---|---|
| `2DFC05C3` · revisor-sintetico · exec 2 | vazamento | **nenhuma** (binário antigo) | **indeterminado** |
| `2DFC05C3` · q2-apresentacao · exec 1 | vazamento | **nenhuma** | **indeterminado** |
| `2DFC05C3` · q2-apresentacao · exec 2 | vazamento | **nenhuma** | **indeterminado** |
| `2DFC05C3` · q2-apresentacao · exec 3 | vazamento | **nenhuma** | **indeterminado** |
| `0065BE4A` · revisor-sintetico · exec 4 | vazamento | trecho `“a dependencia ainda aberta”`, vocabulário da instrução | **nosso** |
| `1B7E0E63` · revisor-sintetico · exec 3 | **limite** | enunciado 1582 > teto 1500 | **do provedor** (estourou um teto nosso, declarado) |
| `1B7E0E63` · revisor-sintetico · exec 4 | vazamento | 4 de 4 palavras já no pedido | **nosso** |
| `1B7E0E63` · q2-apresentacao · exec 4 | vazamento | 4 de 4 palavras já no pedido | **nosso** |
| `1B7E0E63` · q2-apresentacao · exec 5 | vazamento | 4 de 4 palavras já no pedido | **nosso** |

**Em 4 de 4 ocorrências com evidência exposta, o defeito é NOSSO.** As quatro sem evidência
ficam **indeterminadas** e não foram contadas a favor — a conclusão da `08p` deixa de ser
"as cinco" e passa a ser "as quatro que puderam ser examinadas".

### Dois fatos que vão contra a redação anterior, e ficam escritos

1. **"As onze outras guardas não dispararam uma vez" caiu.** Disparou a de limite:
   `enunciado tem 1582 caracteres e o teto é 1500`. É guarda de TAMANHO, não a régua
   importada do Recordar, e não muda o diagnóstico do vazamento — mas muda o texto da ADR,
   que agora diz **dominante, não exclusiva**. Somando as duas remedições: **30 execuções,
   9 recusas (30 %), 8 por vazamento e 1 por limite.**
2. **A contagem de origem tem teto de confiança.** O pedido do autor tem 93 palavras
   distintas num caso e 70 no outro; palavra funcional entra na conta, e quatro palavras
   funcionais dariam 4 de 4 sem dizer nada. O que sustenta a leitura é o valor CHEIO em
   três de três — indício forte, não teorema. Está na ADR com essas palavras.

## 4. Instrumento e lei do simulador do Grok

- Build e suíte no **`34CC3F94-FDB5-4575-A4F5-80271829A18B`**, sempre por
  `ferramentas/orca/com-trava.sh`, `-parallel-testing-enabled NO`. **Segurei a trava.**
- No `C2416CBC` houve apenas `install` **por cima**, `launch`, `terminate` e leitura do
  contêiner. **Nenhum `erase`, `clearState`, `uninstall` ou `xcodebuild test`.** Safari
  intocado. Não desliguei simulador nenhum, não rotacionei, não mexi em tamanho de letra.
- Nenhuma sessão de `orca emulator`, nenhum maestro, nenhum toque no mouse ou teclado do
  Mac. A prova desta volta é JSONL da sonda, não captura.
- **Uma corrida foi abortada de propósito.** A `D74F5411` (19h24) rodou com a primeira
  versão da medida de origem — um booleano de sequência contígua, que teria dito "não estão
  no pedido" em quase todo caso e teria arredondado a conclusão CONTRA nós por artefato de
  instrumento. Terminei o app, troquei a medida por contagem de palavra, reinstalei e
  remedi. A corrida abortada está no JSONL, com 1 execução e nenhuma recusa; não é escondida.

## 5. O que esta volta NÃO fez

Não alarguei o parser — a régua nos dois sentidos continua no RUMO, por escrever.
(Registro: quando a Q-D fechou, `ferramentas/orca/RUMO.md` ainda **não tinha** essa linha; o
orquestrador a escreveu em `main` na seção “A RÉGUA DO VAZAMENTO, nos dois sentidos”, e a
`08p` passou a apontar para ela — ver `q-e-letras-e-fecho.md`.) Não reabri o corte das sete, não reativei
`responderNasNotas`, não toquei em `Traco/Perfil/**`, `Traco/App/**`, `Traco/Modelo/**` nem
`Traco/Notas/**`. Não trouxe `main`. Não renumerei `08k` e `08m`, que também colidem — está
declarado em §1 (**e a Q-E renumerou depois: `08q` e `08r`**). Não fotografei a tela do
`praticaIndisponivel`: a recusa foi medida pela
sonda, e essa lacuna da `08p` continua aberta.

## 6. Prova

- `prova/qd-origem-casos.json` — sha256 `6e38dfbe634403389f3b1998f92690f38eaba72c618dbee2e8532593814ae4fc`
- `prova/qd-origem-avaliacoes.jsonl` — sha256 `fd60c7c8ffc3ea0f3d0ddeca844312b612a8eeeee57dfa5d486abf6a7ff453a6`, 36 linhas, as duas corridas inteiras
- Suíte no `34CC3F94`, `-parallel-testing-enabled NO`:
  `✔ Test run with 917 tests in 149 suites passed after 9.164 seconds.` · `** TEST SUCCEEDED **`
  (916 antes; o teste novo é `aRecusaPorVazamentoContaAOrigemDoQuadrigramaSemOTrecho`)
- Build no `34CC3F94` e no `C2416CBC`: sem erro; o único warning é
  `PerfilView.swift:637`, WIP da volta A1, não desta.

## 7. Estado em que deixo o aparelho do Grok

`C2416CBC` **ligado**, conta **ligada** (12 modelos autenticados no fecho da corrida
`1B7E0E63`), com o binário desta branch instalado por cima. `TRACO_AVALIAR_IA` foi passado
só ao processo (`SIMCTL_CHILD_…`), **não** ao ambiente do simulador: `launchctl getenv` no
aparelho não devolve nada, e o próximo lançamento não roda sonda. O app está terminado.

## Scorecard (meu; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 9 | letra `08p` livre em todas as branches vivas, com a tabela de letras conferida uma a uma; as colisões que NÃO consertei estão nomeadas |
| Privacidade e autoria | 9 | o trecho morre dentro de `provar`; a recusa carrega posição e contagem, e o teste varre a forma normalizada palavra a palavra |
| Estado honesto | 9 | quatro recusas ficam **indeterminadas** em vez de contadas a favor; a corrida abortada e o teto de confiança da contagem estão escritos; duas afirmações da redação anterior foram desmentidas por medida nova |
| Correção | 9 | 917 testes verdes; o teste novo cobre os três estados da origem e prova que ela não altera a régua |
| Simplicidade | 9 | um parâmetro opcional, uma tupla de retorno e um enum com dois campos a mais; nenhum chamador novo, nenhum passo novo para o autor |
| Performance | 9 | 12 de 12 chamadas completas sob o teto de 240 s; nenhuma encostou |
| Jornada real | 7 | medida pelo caminho de produção no aparelho do dono, mas a tela do `praticaIndisponivel` continua sem foto |
| Demais dimensões | n/a | volta de motor: sem mudança de view, componente, movimento ou fora do app |
