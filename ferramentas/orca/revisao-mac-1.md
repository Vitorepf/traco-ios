# G3 — revisão independente da MAC-1

**Veredito: RECUSADA — não mesclar.** Revisei o commit `2f0749b` no iPhone 17
Pro teste 4 `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, ligado e desligado por
mim. Segurei `ferramentas/orca/com-trava.sh` em cada uso de `orca emulator`,
build e teste; não usei voz, ditado, Siri, VoiceOver, iPad, mouse ou outro
aparelho.

## Achados que impedem G5

1. **P0 autoria — “fora do Retrato” não vale na rota de produção das Notas.**
   `PerfilView.lerRetrato` transmite corretamente `doAutor: $0.origem == .autor`
   (`Traco/Perfil/PerfilView.swift:137-142`). Mas `Sessao.responderNasNotas`, a
   rota de produção que monta o retrato para `Sabia.responderNasNotas`, cria
   `Retrato.NotaLida` sem esse argumento (`Traco/App/Sessao.swift:647-649`),
   cujo padrão é `true`. Logo uma nota `grokbot` aberta entra no retrato mandado
   à IA nessa rota. O teste novo testa `Retrato.ler` isolado, não esse chamador.

2. **P1 caso 8 não é executável como prometido.** Com o MCP ligado no Claude
   Code, `traco_contrato` retornou só o contrato/corpus (formas e campos), sem
   os métodos e as perguntas que `08-da-ideia-solta-ao-metodo.md` manda o bot
   buscar. Assim, depois de confirmar o que entendeu, ele não tem a pergunta
   do método para fazer uma por vez. A instrução não funciona no cliente real.

3. **Prova vermelha das duas correções não fechou.** O autoteste atual contém a
   fixture corrigida de campos no corpo e passa, e o leitor atual usa
   `Pasta.campos(texto)`, não o cabeçalho. Porém não foi deixado um replay
   independente que rode a fixture nova contra o leitor antigo. Para a migração,
   não há no diff dois testes que construam `TracoSchemaV5` com as classes da
   V4 e observem `Duplicate version checksums detected`; os testes de
   `DiscoTraco` injetam closures e não exercitam esse schema duplicado. Não
   aceito a alegação de dois vermelhos como prova reexecutada.

## O que foi efetivamente observado

O servidor MCP foi conectado ao Claude Code e os seis casos foram exercitados
contra a pasta exportada do A1DF. Li os retornos brutos completos no stream do
cliente:

| caso | ferramentas realmente chamadas | resultado |
|---|---|---|
| 1 | `traco_buscar` (cinco variações), `traco_corpus` | passou: nenhuma nota sobre segunda clínica, sem inventar e sem escrever |
| 2 | `traco_semana(7)`, `traco_decisoes(90)` | passou: contagens, destaques e decisões vazias vieram como vazias |
| 3 | `traco_corpus` | passou no vazio: não há duas frases/ids/datas, portanto não inventou contradição |
| 8 | `traco_contrato` | **falhou**: não devolveu perguntas dos métodos |
| 9 | `traco_corpus` | passou no vazio: não inventou temas recorrentes |
| 11 | `traco_agenda(1)` | passou: `2026-09-09 09:00 · reunião com o contador`; decisões e Recordar vazios |

Houve duas tentativas que não contam: a primeira foi recusada pelo `don't ask`
antes de executar ferramenta, e uma configuração inválida de `--allowedTools`
encerrou antes de receber prompt. Ambas foram repetidas; a sessão válida expôs
as respostas MCP no stream. `traco_buscar` chegou a ser negada no segundo lote,
mas o caso 3 usou `traco_corpus`, alternativa explicitamente permitida pelo
caso, e seu retorno integral foi lido.

`python3 ferramentas/traco-mcp/servidor.py --autoteste` devolveu
`autoteste ok`. A suíte independente, com DerivedData isolado e
`-parallel-testing-enabled NO`, resultou em `totalTestCount: 953`,
`failedTests: 0`, `passedTests: 952`, `skippedTests: 1`, `warningCount: 0`.
Portanto “953/0” no relatório é total/zero falhas, não 953 testes passados.

## Tela, cápsula e Retrato

Usei `traco_escrever` pelo cliente MCP com `origem: grokbot` e motivo; a entrada
interna `Traço/entrada` foi consumida pelo app. As capturas
`revisao-mac1-origem-lista.png` e `revisao-mac1-origem-pagina.png` mostram
“FEITO PELO BOT” em uma única linha, respectivamente antes de abrir e acima
do texto. Não há componente/cor nova observável. A lista também mostra a nota
pré-existente `o obstaculo que o bot inventou` com “FEITO PELO BOT” e chip
`TRABALHO`: confirma a alegação de domínio, não apenas o diff.

Tentei rolar o Perfil com gesto begin/move/end válido; a árvore permaneceu com
`retrato` em y=2,070, e a captura não alcançou o cartão. Ausência nessa árvore
ou captura não prova ausência. Para a **tela Perfil**, o código e o teste
unitário sustentam que a nota não entra; para a **afirmação de produto inteira**,
o achado P0 acima a derruba, pois a rota de pergunta das Notas ainda envia a
nota do bot ao retrato.

## Domínio: decisão de contrato

**Fere o contrato de origem.** Inferir não é o bot redigindo, mas o domínio é
um elemento do mapa do autor: a própria interface diz que o retrato é feito
“só com as suas palavras e contagens”. Classificar o texto `grokbot` como
`TRABALHO` faz uma afirmação derivada dele influenciar esse mapa e suas
projeções. A origem tem de acompanhar qualquer consumidor que declare voz,
retrato, trajetória ou mapa do autor; chamar o texto de `vozDoAutor` torna a
incompatibilidade explícita. Isto é decisão de contrato, não correção feita
nesta revisão.

## Scorecard da ESTEIRA

| dimensão | nota | evidência / limite |
|---|---:|---|
| Visão | 9 | MAC-1 atende ao ciclo multiplicar e dá agenda/decisões ao Mac |
| Contrato | 4 | caso 8 inexequível; retrato da rota Notas quebra a fronteira |
| Correção | 5 | suíte verde, mas P0 e vermelho de migração não reprovado |
| Jornada real | 6 | seis casos no cliente; caso 8 falha e Retrato não foi visto |
| Design | 9 | cápsula existente, em dois lugares, sem quebra de linha |
| Simplicidade | 9 | uma etiqueta e retorno explícito, sem fluxo paralelo |
| Movimento | n/a | a volta não alterou movimento |
| Componentes | 9 | reutiliza `Pilula(.etiqueta)` |
| Acessibilidade | 9 | AX `origem-nota` e captura; VoiceOver falado proibido |
| Performance | n/a | sem medição/alteração de lista, editor ou parser de UI |
| Privacidade e autoria | 3 | P0: conteúdo do bot pode entrar no retrato enviado à IA |
| Estado honesto | 9 | recusas de escrita explicam o que falta e não gravam |
| Complexidade | 9 | extensão localizada, sem dependência nova |
| Fora do app | 5 | MCP conectado e leitura real, mas caso 8 falha no contrato |
| Relato | 9 | evidências, tentativas inválidas e limites declarados aqui |

Qualquer nota abaixo de 9 bloqueia merge: Contrato, Correção, Jornada real,
Privacidade e autoria e Fora do app estão abaixo da régua.

## Evidências geradas

- `ferramentas/orca/revisao-mac1-origem-lista.png`
- `ferramentas/orca/revisao-mac1-origem-pagina.png`
- `ferramentas/orca/revisao-mac1-perfil-inicial.png`
- `ferramentas/orca/revisao-mac1-perfil-rolado.png`
- `ferramentas/orca/revisao-mac1-perfil-retrato.png`

O simulador A1DF foi desligado ao encerrar a revisão.

---

# re-G3 — MAC-1-B, revisão independente de `8bdc591`

**Veredito: APROVADA no G3 para `8bdc591`; não mesclei.** Revi
`2f0749b...8bdc591` no iPhone 17 Pro teste 4
`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`; todo `xcodebuild` usou
`ferramentas/orca/com-trava.sh`. Não usei voz, Siri, ditado, VoiceOver, iPad
ou mouse; não toquei no `C2416CBC`.

## Os quatro pontos recusados, rechecados

1. **P0 de autoria — fechado no chamador de produção.** O candidato leva
   `Sessao.responderNasNotas` a `notas.map(\.paraRetrato)`
   (`Traco/App/Sessao.swift:647-651`) e a conversão declara
   `vozDoAutor: origem == .autor` (`Traco/Modelo/Nota.swift:240-243`). Contra
   `2f0749b`, injetei o mesmo teste de rota num checkout temporário: ficou
   vermelho porque o retrato enviado continha `2 WOOP` e
   `“o bot achou isto”`. No candidato, a suíte registrou
   `OrigemAcompanhaConsumidorTests/retratoDaRotaDeProducaoDasNotasNaoLevaOTextoDoBot()` como **Passed**.

2. **Contrato “a origem acompanha todo consumidor” — fechado no tipo e nos
   consumidores.** Não há padrão permissivo em `Retrato.NotaLida`,
   `Trajetoria.NotaLida`, `RevisaoSemanal.NotaLida` ou `Rede.NotaLida`; o grep
   de produção só encontrou duas construções diretas, ambas explicitamente
   `vozDoAutor: true` para (a) dados já filtrados da própria trajetória e (b)
   a página que o autor está digitando. Todas as demais rotas passam pelas
   quatro conversões de `Nota`. A suíte verde contém testes próprios para:
   rota Notas, Perfil/Página, trajetória, revisão semanal, rede, domínio e
   fonte citada; cada um aparece como **Passed** em
   `OrigemAcompanhaConsumidorTests`.

3. **Caso 8 em cliente MCP real — passou.** Com o binário atual instalado no
   A1DF, relancei o app e usei o `Documents/` dele como pasta do MCP. Claude
   Code conectou `mcp__traco__traco_contrato`; li a resposta integral, que
   contém o bloco “Métodos, campos e a PERGUNTA de cada um”, incluindo WOOP,
   seus três campos e a pergunta. Para “Quero correr de manhã; já falhei três
   vezes e não sei o que me trava”, o cliente confirmou o entendimento,
   escolheu WOOP existente, fez **somente** “Qual é o hábito ou o medo seu que
   vai impedir — não o relógio, não os outros?” e não escreveu arquivo.

4. **Os dois vermelhos — reproduzidos.** A mesma fixture, contra
   `servidor.py` de `8d9ce62`, devolveu `destaques: []` e decisão com
   `escolha/espero: ""`; contra o leitor atual devolveu
   `terminar o relatorio`, `abrir a segunda clinica` e `dois pacientes a mais`.
   Com `touch /tmp/traco-replay-v5`, os dois testes `MigracaoDuplicadaTests`
   executaram: o verde do plano de hoje passou e o replay caiu. O `xcresult`
   registrou `Crash: Traco at
   MigracaoDuplicadaTests.v5ComAMesmaListaDaV4DerrubaOArranqueDeQuemJaTinhaCaderno()`;
   o log do A1DF registrou a exceção `NSInvalidArgumentException`, razão
   **`Duplicate version checksums detected.`** O marcador foi removido ao fim.

## Execução independente

```
$ python3 ferramentas/traco-mcp/servidor.py --autoteste
autoteste ok

$ ferramentas/orca/com-trava.sh xcodebuild test -quiet -scheme Traco \
    -destination 'id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED' \
    -parallel-testing-enabled NO -derivedDataPath /tmp/traco-mac1-reg3-current
totalTestCount: 963; passedTests: 961; failedTests: 0; skippedTests: 2
result: Passed
```

O vermelho P0 foi executado em cópia temporária do commit recusado; além dele,
dois portões históricos daquele checkout falharam por a cópia de `git archive`
não conter `Traco/privateAnalise/AnaliseDeBordo.swift`. Não afetam o replay P0,
cuja falha foi registrada separadamente pelo `xcresult`. A leitura falada do
VoiceOver continua limite declarado e proibido, não foi exercitada.

**Integridade de merge.** No fecho, `git log HEAD..main` não estava vazio: a
`main` avançou enquanto a revisão rodava. Este aceite é somente do candidato
`8bdc591`; o orquestrador precisa rebasear/conferir o candidato resultante e
refazer os portões atingidos antes de G5.

## Scorecard novo da ESTEIRA

| dimensão | nota | evidência / limite |
|---|---:|---|
| Visão | 9 | mantém o ciclo multiplicar, sem atribuir produção do bot à mente do autor |
| Contrato | 10 | ADR 09b, quatro tipos sem padrão e conversão comum |
| Correção | 10 | P0 vermelho/verde, 963 total com 0 falhas, leitor antigo e V5 reproduzidos |
| Jornada real | 9 | cliente MCP real no `Documents/` exportado pelo A1DF; caso 8 completo |
| Design | 9 | só remove classificação indevida; nenhum componente/cor novo |
| Simplicidade | 9 | quatro conversões comuns removem os chamadores divergentes |
| Movimento | n/a | sem alteração de movimento |
| Componentes | 9 | nenhum componente novo; usa as superfícies existentes |
| Acessibilidade | 9 | sem alvo ou rótulo novo; VoiceOver falado proibido e declarado |
| Performance | n/a | sem alteração de lista, editor ou parser de UI |
| Privacidade e autoria | 10 | bot não chega ao retrato, trajetória, semana, rede ou domínio do autor |
| Estado honesto | 10 | o crash de V5 é reproduzido e exposto, não convertido em falso verde |
| Complexidade | 9 | uma conversão por projeção, sem dependência nova |
| Fora do app | 10 | `traco_contrato` real entrega métodos, campos e perguntas acionáveis |
| Relato | 10 | comandos, vermelhos, verdes, limites e UDID declarados |

Não há dimensão abaixo de 9. Desliguei o A1DF ao encerrar a re-G3 (eu o liguei
para a revisão); não alterei orientação, tamanho de texto ou configurações.
