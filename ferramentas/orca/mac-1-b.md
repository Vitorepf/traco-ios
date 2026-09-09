# MAC-1-B — a origem acompanha todo consumidor, e o caso 8 funciona

Volta de correção da **MAC-1**, recusada no G3 (`ferramentas/orca/revisao-mac-1.md`,
commit `fc125b1`). Branch `Vitorepf/volta-mac-1`, sobre `2f0749b`. **Não mesclada.**
Simulador **A1DF082C** (iPhone 17 Pro, teste 4), ligado e desligado por mim.
Segurei `ferramentas/orca/com-trava.sh` em todo build, teste e uso de
`orca emulator`. Sem voz, ditado, Siri, VoiceOver, iPad ou mouse. Não encostei
em `C2416CBC` (conta Grok do dono) nem em nenhum outro aparelho.

## 1. P0 — a rota de produção mandava a nota do bot para a IA

`Sessao.responderNasNotas`, a rota que monta o retrato quando o autor pergunta
nas Notas, construía `Retrato.NotaLida` **sem** `doAutor`, e o padrão era `true`.
O teste da 08u exercitava `Retrato.ler` isolado — não o chamador.

**Pago no tipo, não na disciplina.** O campo passou a `vozDoAutor` e **perdeu o
padrão**. As seis conversões `Nota → NotaLida` espalhadas por views e intents
viraram uma só (`Nota.paraRetrato/paraTrajetoria/paraSemana/paraRede`), e quem
escrever o sétimo chamador não compila sem declarar de quem é a voz.

## 2. A decisão de contrato do dono (09/09) — quatro consumidores, não um

> Nenhum consumidor que declare voz, retrato, trajetória ou mapa do autor lê
> texto que não seja dele — nem para inferir domínio, nem para contar.

Cada um destes diz na própria documentação que fala da mente do autor, e cada um
lia texto que não era dela:

| consumidor | o que passava antes | teste do chamador |
|---|---|---|
| **Retrato** (rota das Notas) | o obstáculo que o bot escreveu ia à IA | `retratoDaRotaDeProducaoDasNotasNaoLevaOTextoDoBot` |
| **Retrato** (Perfil / página) | já correto em `2f0749b`; agora numa conversão só | `oRetratoDoPerfilEDaPaginaUsaAMesmaConversaoComOrigem` |
| **Trajetória** | a LINHA DE SENTIDO não era filtrada | `aTrajetoriaNaoMedeAMenteComTextoQueNaoEDela` |
| **Revisão da semana** | contava a nota do bot por forma e mostrava o destaque dele | `aSemanaNaoContaNemDestacaAQuiloQueOBotEscreveu` |
| **Rede** | `[[menção]]` escrita pelo bot virava ligação do autor | `aRedeNaoLigaDoQueOBotEscreveuMasDeixaOAutorLigarAEle` |
| **Domínio** | o léxico chamava o texto `grokbot` de TRABALHO | `oDominioNaoENemInferidoNemClassificadoDoTextoDoBot` |
| **Fonte citada** | a nota do bot voltava sem dizer quem escreveu | `aNotaDoBotCitadaChegaComAOrigemNoTitulo` |
| **Contrato da pasta** | sem os métodos e sem as perguntas (caso 8) | `oContratoDaPastaTrazOsCamposEAPerguntaDeCadaMetodo` |

**A raiz.** `Nota.vozDoAutor` prometia "só a voz do autor" e devolvia o texto do
bot. Agora devolve **vazio** quando a nota não é dele; a busca — que TEM de achar
a nota do bot, porque ela está na pasta — pede `Nota.textoDeQualquerOrigem`, cujo
nome diz o que está pedindo. Com isso o léxico, o classificador de bordo e as
perguntas dos Padrões pararam de ler o texto do bot **sem um `if` novo em cada
lugar**. A nota do bot continua **destino** de uma ligação (ligar a ela é ato do
autor) e continua **citável** — com a etiqueta no título da fonte.

`Nota.dominio` devolve `nil` quando a origem não é o autor, salvo se o AUTOR
escolheu no menu (`dominioTravado`): o rótulo gravado antes desta ADR cala **sem
migração**. Foi o chip `TRABALHO` que o G3 viu na tela.

### O vermelho de cada um, reexecutável

Reverti os seis pontos para o comportamento de `2f0749b` (`vozDoAutor: true` nas
conversões, `Nota.vozDoAutor` permissivo, `Retrato.ler` na rota das Notas com o
padrão, sem o corte de sentido na Trajetória, sem o corte no topo da semana, sem
o `where origem.vozDoAutor` na Rede, contrato sem os métodos) e rodei a suíte
nova. **Os oito falharam:**

```
✘ retratoDaRotaDeProducaoDasNotasNaoLevaOTextoDoBot() failed with 2 issues.
✘ aNotaDoBotCitadaChegaComAOrigemNoTitulo() failed with 1 issue.
✘ oRetratoDoPerfilEDaPaginaUsaAMesmaConversaoComOrigem() failed with 3 issues.
✘ aTrajetoriaNaoMedeAMenteComTextoQueNaoEDela() failed with 2 issues.
✘ aSemanaNaoContaNemDestacaAQuiloQueOBotEscreveu() failed with 2 issues.
✘ aRedeNaoLigaDoQueOBotEscreveuMasDeixaOAutorLigarAEle() failed with 1 issue.
✘ oDominioNaoENemInferidoNemClassificadoDoTextoDoBot() failed with 2 issues.
✘ oContratoDaPastaTrazOsCamposEAPerguntaDeCadaMetodo() failed with 30 issues.
✘ Test run with 8 tests in 1 suite failed after 0.058 seconds with 43 issues.
```

Restaurado, na mesma máquina e no mesmo aparelho:

```
✔ Test run with 8 tests in 1 suite passed after 0.037 seconds.
```

## 3. P1 — o caso 8 no cliente MCP de verdade

`traco_contrato` devolvia o contrato sem os métodos: o catálogo vive no bundle do
app (que o Mac não abre) e `metodos/` na pasta só tem os do autor. **O defeito
era do dado, não da instrução.** `Corpus.contrato` passou a ser **gerado** de
`Catalogo.todos` — e de quebra apagou a lista fixa de dez formas, que já não era
o catálogo de vinte e oito.

Pasta escrita pelo próprio `Corpus.escrever` do app, servidor apontado para ela,
cliente real (`claude -p --mcp-config`, ferramentas restritas a leitura). Retorno
BRUTO de `traco_contrato`, no stream do cliente:

```
Métodos, campos e a PERGUNTA de cada um. `gesto` no cabeçalho é o nome;
`metodo` é o id, quando difere. Os campos são o que a nota guarda. A
pergunta é a que se faz a QUEM ESCREVE, uma por vez — quem pergunta não
responde, e não preenche campo "para ela ver como fica".
- A pergunta de Hamming (`perguntaHamming`)
  campos: campo · importantes · ataque · trabalhando · porque · mudo
  pergunta: Se você acredita que a ação está lá, por que você marcha para cá?
```

E o caso 8 corrido inteiro, com o despejo sem forma
(`ferramentas/orca/mac1b-caso8-cliente-mcp.txt`):

```
Entendi assim: é um desejo recorrente que já falhou três vezes e ainda não tem
obstáculo identificado — não é falta de tempo até prova em contrário, é um WOOP
por fazer. Acertei?

Se sim, o método é WOOP (`woop`) — campos: resultado · obstaculo · plano.
Primeira (e única) pergunta dele, para você responder:

> Qual é o hábito ou o medo seu que vai impedir — não o relógio, não os outros?

Não respondo por você, e não escrevi nada na pasta.

LINHA DO CONTRATO:   pergunta: Qual é o hábito ou o medo seu que vai impedir —
não o relógio, não os outros?
```

O arquivo do caso passou a dizer o nome do bloco e a proibir método fora dele.

## 4. P2 — os dois vermelhos que faltavam

**`traco_semana`.** O autoteste passou a rodar a fixture nova **contra o leitor
antigo** (`semana_pelo_cabecalho`, que lê `escolha`/`espero`/`unica` do
cabeçalho) e a exigir que ele venha vazio, ao lado do verde do leitor de hoje na
mesma fixture. Roda a cada `--autoteste`:

```
$ python3 ferramentas/traco-mcp/servidor.py --autoteste
autoteste ok
```

**A V5.** `TracoSchemaV5Duplicado` e `TracoMigracaoComV5` estão no diff. **A sonda
corrigiu a ADR 08u:** com um caderno NOVO, o plano com a V5 duplicada **abre sem
reclamar** (quatro construções sondadas, todas ABRIU) — o checksum só é conferido
quando um estágio de fato RODA. Por isso o replay sobe um caderno da V3:

```
$ touch /tmp/traco-replay-v5
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'id=A1DF082C-...' -only-testing:TracoTests/MigracaoDuplicadaTests
◇ Test v5ComAMesmaListaDaV4DerrubaOArranqueDeQuemJaTinhaCaderno() started.
*** Terminating app due to uncaught exception 'NSInvalidArgumentException',
    reason: 'Duplicate version checksums detected.'
Restarting after unexpected exit, crash, or test timeout
$ rm /tmp/traco-replay-v5
```

É `NSException`, não `Error` de Swift — **nenhum `do/catch` a pega**, e é por isso
que ela derrubava o arranque em vez de virar recusa tratada. O guarda permanente
é o verde ao lado (`oPlanoDeHojeSobeUmCadernoDaV3EGuardaAOrigem`): um caderno da
V3 sobe pelo plano de hoje e a `origem` atravessa; quem acrescentar uma V5 com a
lista de classes da V4 **mata a suíte inteira**.

## 5. A tela

Mesma pasta, mesmo aparelho, antes e depois do diff:

- `mac1b-dominio-antes.png` — as notas do bot com os chips `TRABALHO` e `ESTUDO`
  que o léxico gravou (o achado de domínio do G3).
- `mac1b-dominio-depois.png` — os chips somem; `FEITO PELO BOT` fica.
- `mac1b-padroes-sem-o-bot.png` — com **duas** notas `Destaque` da semana no
  caderno (uma do autor, uma do bot), ESTA SEMANA diz **"1 destaque · 1 woop"** e
  "Os destaques: entreguei o relatório hoje"; a TRAJETÓRIA diz "2 notas" com
  cinco notas abertas e mostra só o obstáculo do autor.

## 6. Suíte integral

```
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED' \
    -parallel-testing-enabled NO
✔ Test run with 963 tests in 155 suites passed after 54.559 seconds.
$ grep -c warning: <log>
0
```

Resumo do bundle: `totalTestCount 963, passedTests 961, failedTests 0,
skippedTests 2` — os dois pulados são o replay da V5 (sem o arquivo marcador) e o
que já era pulado antes desta volta.

## 7. Limites declarados

- **O cartão do Retrato no Perfil continua fora de alcance.** O gesto do helper
  não rola aquela tela: a árvore permanece com "O retrato, exatamente como viaja"
  em y=2,07 depois de 24 gestos, e a captura confirma a tela parada no topo — o
  mesmo limite que o G3 registrou. A rota do Perfil já passava a origem em
  `2f0749b` e está coberta por teste; a prova viva desta volta veio dos Padrões,
  que é a tela cujo comportamento MUDOU.
- **A etiqueta no título da fonte citada** é provada por teste na função de
  produção (`Sessao.fonteParaPergunta`). Vê-la na tela exige uma resposta de
  provedor, e o único simulador com a conta do dono está fora de alcance.
- **VoiceOver falado** não foi exercitado: proibido no Traço.
- A ADR 08u afirmava dois testes de migração que **não existiam no diff**. Ao
  escrevê-los, o defeito ficou mais preciso do que ela dizia; corrigi o parágrafo
  da 08u apontando para a 09b em vez de reescrever a história.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão | nota | evidência / limite |
|---|---:|---|
| Visão | 9 | paga o ciclo: o companheiro do Mac serve à mente sem se passar por ela |
| Contrato | 9 | quatro consumidores fechados NO TIPO, sem padrão permissivo; caso 8 corrido em cliente real |
| Correção | 9 | 8 testes do chamador, cada um visto vermelho; os dois replays de P2 reexecutáveis; 963/0 |
| Jornada real | 9 | caso 8 num cliente MCP com retorno bruto colado; Padrões e lista no A1DF, antes e depois |
| Design | 9 | nenhum componente ou cor nova; o que mudou na tela foi um chip que **some** |
| Simplicidade | 9 | seis `map` duplicados viraram um; a lista fixa de dez formas saiu do contrato |
| Movimento | n/a | a volta não alterou movimento |
| Componentes | 9 | `Pilula(.etiqueta)` já existente; nada novo |
| Acessibilidade | 9 | árvore de AX e captura; VoiceOver falado declarado como limite |
| Performance | n/a | sem medição ou alteração de lista, editor ou parser de UI |
| Privacidade e autoria | 9 | P0 fechado na rota de produção, com teste do chamador; domínio inferido cala, inclusive o já gravado |
| Estado honesto | 9 | a sonda contradisse a ADR 08u e está escrita como contradição, não como acerto |
| Complexidade | 9 | uma extensão em `Nota.swift`, sem arquivo novo de produção e sem dependência |
| Fora do app | 9 | contrato gerado do catálogo; caso 8 verde no cliente; autoteste com o replay do leitor antigo |
| Relato | 9 | vermelhos e verdes colados, limites do instrumento declarados |
