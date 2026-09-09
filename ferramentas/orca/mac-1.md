# MAC-1 — o Traço no Mac: ler tudo e escrever com origem

Branch `Vitorepf/volta-mac-1`. ADR **2026-09-08u** em `SPEC.md`. Simulador
**A1DF082C-FC87-4DF9-9F56-F2DA1C084DED** (iPhone 17 Pro, teste 4), ligado por
mim no começo e desligado no fim; nenhum outro aparelho foi tocado. Toda sessão
de build, teste e `orca emulator` passou por `ferramentas/orca/com-trava.sh` —
esperei a trava da volta Q por ~15 min numa delas.

**Linha do ciclo (G0).** Ciclo: multiplicar a mente. Intenção: no Mac a pessoa
pergunta ao bot o que já pensou, o que se repete, onde se contradiz e o que tem
hoje — e despeja pensamento que vira nota pelas perguntas do método. Obstáculo:
o MCP não tinha agenda nem decisões prontas, e `traco_escrever` não sabia dizer
quem escreveu. Casos pagos: **1, 2 (só a leitura), 3, 8, 9 e 11**.

## O que entrou

| # | o quê | onde |
|---|---|---|
| 1 | `traco_agenda(dias)` — compromissos, decisões vencidas, Recordar devido | `ferramentas/traco-mcp/servidor.py` |
| 2 | `traco_decisoes(dias)` — esperava × aconteceu × sem resposta | idem |
| 3 | `traco_escrever` com `origem`, `motivo`, `fontes`, e a recusa que diz o que falta | idem |
| 4 | `agenda.md` exportado pelo app, ao lado dos três de hoje | `Corpus.agenda`, `Corpus.escreverAgregados` |
| 5 | a etiqueta de origem na lista e na página aberta; fora do Retrato e da Trajetória | `Nota`, `Corpus`, `Entrada`, `Sessao`, `Retrato`, `Trajetoria`, `NotasView`, `PaginaView` |
| 6 | instruções coláveis dos seis casos | `ferramentas/grokbot/casos/` |

**Três correções que a volta pagou de passagem.** (a) `traco_semana` lia os
campos da forma do CABEÇALHO e eles vivem no CORPO, depois do marcador
`<!-- traco-campos:json-v1 -->` (ADR 05h): a revisão da semana devolvia decisões
e destaques vazios **desde sempre**, e a fixture do autoteste sustentava o
engano pondo `unica:` no cabeçalho, onde nenhuma nota real o tem. (b) A
primeira tentativa criou `TracoSchemaV5` com a mesma lista de classes da V4; o
CoreData derruba o arranque com "Duplicate version checksums detected" — dois
testes de migração pegaram isto antes de qualquer aparelho, e `origemRaw` ficou
como atributo com padrão dentro da V4. (c) Na lista, com gesto + origem +
subtítulo + chip de domínio na mesma linha, a cápsula da origem era a que cedia
e quebrava em duas ("FEITO / PELO BOT"); `fixedSize(horizontal:)` faz o
subtítulo ceder, que é quem já trunca por desenho. **Vista na captura, não no
código** (`mac1-lista-import.png` antes, `mac1-lista.png` depois).

## A tela: fase 5 antes de tocar

A tela da nota já existe, então a auditoria veio primeiro. O que achei: a página
não tem faixa de metadados (a `topbar` é "Notas … Concluir", e a linha da data
só existe na página vazia); a linha da lista já usa `Pilula(forma: .etiqueta)`
para o gesto; `LinhaDeEstado` é para estado transitório da sábia, não para selo
permanente de nota.

**Decisão: nenhum componente novo, nenhuma cor nova.** A etiqueta é a MESMA
`Pilula(.etiqueta)` do gesto — `Tema.chip` de fundo, `Tema.tintaSuave`, caixa
alta com `Tema.trackingLabel`. Aparece em dois lugares, e os dois importam:

- **na linha da lista**, ao lado do gesto: o autor sabe **antes de abrir**;
- **na página aberta, acima do texto**: a página é o lugar em que se confunde o
  texto do bot com a própria voz, e o rótulo tem de chegar **antes da leitura**.

Texto: **"feito pelo bot"** (a formulação do contrato) e **"pesquisa do bot"**.
As duas dizem a mesma coisa em uma linha: isto não é voz do autor.

## Prova

**Autoteste do servidor** (`python3 servidor.py --autoteste`), com os casos
novos e as três recusas — incluindo a asserção de que a recusa **não escreve
arquivo nenhum**:

```
autoteste ok
```

**Suíte integral**, `com-trava.sh` + `-parallel-testing-enabled NO` no meu
simulador:

```
✔ Test run with 953 tests in 153 suites passed after 74.278 seconds.
** TEST SUCCEEDED **
grep -c warning: → 0
```

Cinco testes novos em `TracoTests/IntegridadeCorpusTests.swift`:
`origemDoCabecalhoAtravessaOImport` (as quatro grafias, inclusive a inválida,
que vira `autor`), `origemSobreviveAoRoundtripPelaPasta`,
`notaQueNaoEDoAutorFicaForaDoRetrato` (**nem como contagem**: duas WOOP, uma do
bot, dizem "1 WOOP"), `agendaSaiNaPastaComOQueVenceESemOQueOSeloFecha`,
`expressivaESeladaContinuamForaDaPastaDepoisDaOrigem`.

**A rota inteira, no aparelho.** O servidor MCP rodou contra a pasta que o app
acabara de escrever (`Documents/` do contêiner do simulador):

- `traco_escrever(origem: "grokbot")` **sem motivo** → recusa, nada gravado:
  *"Recusado: escrita com origem “grokbot” exige `motivo` — uma linha dizendo
  por que o bot está escrevendo isto…"*
- com motivo → `Guardado em entrada/20260909-001202-os-tres-temas-que-se-repetem.md`
- o arquivo entrou no app e a nota **apareceu no iPhone com a etiqueta**:
  `mac1-nota-aberta.png` (a etiqueta acima do texto, e o motivo no rodapé da
  própria nota) e `mac1-lista.png` (as duas notas do bot etiquetadas, a do autor
  sem etiqueta). Em AX5 a etiqueta continua inteira e acima do texto:
  `mac1-ax5.png`.
- o app **exportou** a nota do bot com a linha no cabeçalho:
  `notas/7c7fdda6-….md` traz `origem: grokbot`; a do autor não traz linha nenhuma.
- `traco_notas` leu de volta `"origem": "grokbot"` e `"origem": "autor"`.

**`agenda.md` escrito pelo app real**, com as três seções povoadas (compromisso
semeado no `calendario.json`, decisão sem `aconteceu`, Recordar vencido no
`revisaoProxima` do plist):

```
## Compromissos
- 2026-09-09 09:00 · reunião com o contador

## Decisões a conferir
- 2026-08-01 · cbf2c776-… · abrir a segunda clínica em Pinheiros · espero: dois pacientes a mais por semana

## Recordar devido
- 2026-09-07 · 25234acd-… · WOOP · quero correr todo dia de manhã
```

e `traco_agenda(dias: 7)` devolveu exatamente essas três seções, com o
compromisso de daqui a 40 dias fora da janela e o de ontem fora dos
compromissos (autoteste); `traco_decisoes` devolveu a decisão em
`sem_resposta`, com `esperava` preenchido e `aconteceu` vazio.

## Limites, declarados

- **A prova de que a nota do bot não está no Retrato é por TESTE, não por
  captura.** A ScrollView do Perfil **não rolou** com o gesto do helper: nem
  `orca emulator gesture` com dois pontos, nem com cinco (a árvore de AX
  mostrou o retrato parado em `y=2.070` antes e depois), e `orca emulator exec`
  responde `unknown option '-d'` para `swipe`, `scroll` e `drag`. Parei nas três
  tentativas, como a lei manda. O algoritmo está provado por
  `notaQueNaoEDoAutorFicaForaDoRetrato`, que verifica a ausência do texto **e** a
  contagem que não muda.
- **VoiceOver falado não foi exercitado** — proibido por ordem do dono. A
  etiqueta tem `accessibilityIdentifier("origem-nota")` e
  `accessibilityLabel("Esta nota não é sua voz: feito pelo bot")`; a ordem de
  leitura está provada por árvore de AX e por captura.
- **As ações dos Trabalhos não entram no `agenda.md`.** São da MAC-2, que é dona
  de `Traco/Trabalho/*` e de `trabalhos/<id>.md`. O arquivo **diz isso** no
  cabeçalho em vez de fingir completude, e o parser do MCP é por seção — a MAC-2
  acrescenta uma seção sem mexer no formato.
- **As instruções dos casos não foram exercitadas por um cliente MCP externo.**
  Exercitei as ferramentas por stdio contra a pasta viva do aparelho (acima); o
  brief da trilha pede que **o revisor** rode cada caso uma vez com o MCP ligado
  num cliente e leia o retorno inteiro. Fica para ele.
- **Pergunta aberta para o revisor, que não resolvi por não alargar escopo:** a
  inferência de domínio rodou sobre a nota do bot e pôs "TRABALHO" nela
  (`mac1-lista.png`). O domínio é organização, não voz, e a lei fala de Retrato,
  tela e voz — mas classificar texto do bot como se fosse pensamento do autor
  merece um "sim" ou "não" explícito.

## Scorecard (meu; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Corretude | 9 | 953/0, autoteste verde, rota provada no aparelho; a migração V5 foi pega por teste, não por sorte |
| Guardas do selo | 10 | teste explícito de que expressiva/selada continuam fora dos quatro arquivos soltos DEPOIS deste diff; a agenda usa `vivas` e pula `soMetadado` |
| Contrato de origem | 9 | recusa com motivo, recusa de pesquisa sem fontes, origem inválida vira `autor` no import; fora do Retrato e da Trajetória, nem como contagem |
| Tela | 9 | fase 5 antes de tocar, componente e tokens existentes, dois lugares certos, AX5 conferido, um aperto de layout achado na captura e corrigido |
| Evidência | 8 | capturas, agenda do aparelho, MCP contra a pasta viva; **menos 2 porque o Retrato na tela não foi fotografado** (rolagem não respondeu) |
| Escopo | 10 | nada de `Traco/Trabalho/*`; o que é da MAC-2 está declarado, não improvisado |
| Honestidade | 10 | três correções de passagem contadas, três limites e uma pergunta aberta escritos aqui |

## Arquivos

`ferramentas/traco-mcp/servidor.py`, `ferramentas/grokbot/CASOS.md`,
`ferramentas/grokbot/casos/{README,01,02,03,08,09,11}.md`,
`Traco/Modelo/{Nota,Migracao,Retrato}.swift`,
`Traco/Notas/{Corpus,Entrada,PastaEspelho,NotasView}.swift`,
`Traco/Pagina/PaginaView.swift`, `Traco/Perfil/PerfilView.swift`,
`Traco/Padroes/{Trajetoria,PadroesView}.swift`,
`Traco/App/{Sessao,Intents/Intencoes}.swift`,
`TracoTests/{IntegridadeCorpusTests,IntegridadeRotasTests,ColheitaEixosTests}.swift`,
`SPEC.md`, `EVOLUCAO.md`, `ferramentas/orca/mac1-*.png`.
