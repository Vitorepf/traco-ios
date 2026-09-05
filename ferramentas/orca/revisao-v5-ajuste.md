# Revisão V5 — "Conferir com IA" e "Pedir ajuste" (ADR 2026-09-05q)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026. Só leitura; nada
editado nem commitado (este arquivo, `v5-*.png` e `v5-caso-real.json` ficam
fora do commit). Worktree `volta-5-ajuste`, branch `Vitorepf/volta-5-ajuste` @
6fc833d sobre 4c3d398; main em 333db61.

## Veredito

**CORRIGIR ANTES — lista mínima de DOIS itens (P2-a, P2-b), ambos de poucas
linhas.** Nenhum P1: uma chamada por toque, nunca automática, acesso
revalidado nos quatro pontos, parser estrito, teto sem corte, proveniência
efetiva, produtor intacto, "nunca aprovado", export/import sem conferência —
tudo cumprido no código, provado por teste e, desta vez, PELA TELA no iPhone
17 do dono com Apple Intelligence.

Fatos duros: suíte integral **618/0** no 6033B043 (a 1ª corrida caiu em "test
runner hung", instrumento; a 2ª passou); build genérico e build do dono **sem
warnings**; regressão `trabalho-acao-aviso.yaml` **FALHAS: nenhuma**; jornada
real pela tela: versão gerada em 20 s, "Pedir ajuste" preencheu o campo e levou
o foco, **"Conferir com IA" RODOU no aparelho** (montagem 2.997 ≤ 3.500) e
voltou em 13 s; merge-tree contra main **sem conflito**.

**Pergunta central: recomendo (b), com a condição sendo o PROVEDOR, não o
tamanho** — o botão só aparece com conta Grok; sem ela, uma linha diz por quê.
Evidência na §2.

## 1. Contratos — leitura do diff (`git diff 4c3d398..HEAD`, 11 arquivos, +892/−27)

| Contrato pedido | Cumpre? | Evidência literal |
|---|---|---|
| Uma chamada por toque; nunca automática | Sim | `revisarComIA`: `guard !revisando, verificarAcesso()` e `revisando = true` antes da `Task` (OficinaTrabalho.swift:219-228); `gerar` só chama `conferir(versao.id, …)` (:183); nenhuma referência a `revisao`/`revisarComIA` fora do botão; teste `gerarNaoDisparaRevisaoDaIA` (`revisoes == 0`) |
| Acesso revalidado antes de enviar, depois do await, no commit, antes de mostrar | Sim | `guard verificarAcesso()` na entrada (:219) e no início da Task (:229); `guard verificarAcesso(), !Task.isCancelled, documento.versaoAtual?.id == artefatoID` após o await (:233-234); `alterar` revalida de novo (:65); a view só monta `documento(oficina)` se `acesso.permitido` (TrabalhoView.swift:35-41). O teste `acessoNegadoNaoChamaAIANemGravaRevisao` prova só a revogação ANTES do toque (P3-f) |
| Parser estrito | Sim | `Set(j.keys) == ["criterios"]`, `lista.count <= 12`, `Set(item.keys) == chavesDoCriterio`, enums por `rawValue`, `trechosDoArtefato as? [String]`; qualquer falha → `nil` → `indisponivel` "não veio no formato exigido" (RevisaoTrabalho.swift:94-120, 168-171). Citação não literal → `inconclusivo` "Citação não encontrada" e a citação inventada é apagada (:107-113). Provado na tela (§2, caso real desta revisão) |
| Teto 05m sem corte | Sim | `guard mensagem.count <= teto` → `indisponivel` "Limite do aparelho … Não mandei um pedaço deles." (:158-161); `janelaPadrao` = 18.000 com Grok, 3.500 sem (:22-24); teste `acimaDaJanela…` prova `chamadas == 0` |
| Proveniência efetiva; produtor original intacto | Sim | `Sabia.chamarComProveniencia` devolve `(texto, "Grok")` ou `(texto, "Apple Intelligence no aparelho")` — a mesma string que `produzir` usa como produtor (OficinaTrabalho.swift:355); executor = `"\(provedor) · revisão assistida"` (:166); `registrarConferencia` só faz append (Trabalho.swift:189-193). No disco do caso real: `produtor = "Apple Intelligence no aparelho"`, 2º registro `executor = "Apple Intelligence no aparelho · revisão assistida"` (`v5-caso-real.json`) |
| Favorável nunca "aprovado" | Sim, mas ver P2-a | "Revisão da IA: a IA não apontou divergências nos critérios examinados"; rodapé "não uma revisão independente: nada aqui aprova o artefato" (`v5-revisao-ia-rodape.png`). Nenhum "aprovad"/"verificad" |
| "Pedir ajuste" só preenche e foca | Sim | `definir("pedido", ajuste); campoEmFoco = "pedido"` (TrabalhoView.swift:290-291); `definir` só grava `rascunhos` + UserDefaults (:522-526); nenhum `gerar` no caminho. Na tela: campo preenchido e teclado aberto (`v5-pedir-ajuste.png`, `v5-pedir-ajuste-campo.png`); nenhuma versão nova apareceu |
| Export/import sem conferência | Sim | `grep conferencia Traco/Trabalho/IntercambioTrabalho*.swift` vazio; inalterado desde a V4 |
| 02o: nada da IA entra no artefato por conta própria | Sim, com ressalva P3-e | A revisão só grava `Conferencia`; o artefato não muda. O texto que entra no CAMPO do pedido vem da conferência e vira `Pedido.instrucao` sem marca de origem quando o autor toca "Preparar" — decisão explícita da ADR, o autor edita antes |
| `Sabia.chamar` preserva comportamento | Sim | vira `chamarComProveniencia(...)?.texto`; ordem Grok → recusa de orçamento → aparelho igual; memo só no Grok |
| `xcodegen generate` idempotente | Sim | rodado; `git status` limpo depois (o pbxproj commitado já traz RevisaoTrabalho.swift) |

## 2. Caso real (prova/5.md) e a pergunta central

**Leitura do implementador em prova/5.md: correta.** Conferi as duas amostras
gravadas contra o contrato: aspas não escapadas em todos os itens → `JSONSerialization`
falha → `indisponivel` (certo); amostra 2 sem `justificativa` → chave faltando →
`nil` (certo); nenhuma justificativa menciona traduções ausentes nem os 9 minutos —
"não apontou" está certo. 3.977 > 3.500 → nada enviado (confirmado no `guard`).
O documento declara que a execução foi por sonda fora da tela — honesto.

**Caso real NOVO, pela TELA, nesta revisão (17:11–17:24, iPhone 17 do dono,
Apple Intelligence, sem conta Grok, `TRACO_SEM_MODELO` vazio).** Mesmo pedido
de prova/4.md (intenção + instrução; sem "resultado desejado", porque a criação
do Trabalho só pede a intenção):

| Passo | O que aconteceu | Evidência |
|---|---|---|
| Preparar com IA | Versão 1 em ~20 s, 2.030 caracteres, DESTA VEZ com tradução em todas as 15 frases e 3 blocos; SEM nenhuma marca de tempo | `v5-versao-gerada.png`, `v5-caso-real.json` |
| Conferência local | "1 possível divergência · 1 critério não avaliado": tempo divergente com motivo VERDADEIRO ("nenhuma marca de minutos no artefato, nem em dígitos nem por extenso") — a correção P2-a da V4 está de pé | `v5-conferencia-expandida.png`, `v5-conferencia-botoes.png` |
| Pedir ajuste | Campo do pedido recebeu "Ajustar a versão anterior:\n- Tempo pedido: 3 blocos de 5 minutos (15 no total). O pedido diz: “…”. Não encontrei distribuição…" e o foco foi para o campo (teclado abriu). Nada gerou. | `v5-pedir-ajuste-campo.png` |
| Conferir com IA | Montagem 2.997 ≤ 3.500 → a chamada FOI feita; "A IA está conferindo…" por 13 s; voltou JSON VÁLIDO com 3 critérios | `v5-conferindo.png`, `v5-conferir-ia-estado.png` |
| O que a IA devolveu | `criterio` = "atendidoNoEscopo", "divergencia", "naoAvaliado" (os nomes do enum, como em prova/5); `trechoFonte` não literal do pedido nas três; `trechosDoArtefato` = o parágrafo de abertura, três vezes. O parser derrubou as três para `inconclusivo` com "Citação não encontrada" | `v5-revisao-ia-expandida.png`, `v5-caso-real.json` |
| A linha na tela | **"Revisão da IA: a IA não apontou divergências nos critérios examinados · 3 inconclusivos"** — com ZERO critérios confirmados | `v5-conferir-ia-estado.png` |

Leitura humana: a versão desta vez tinha as traduções, então a divergência
real era só o tempo (nenhuma marca). A IA não apontou o tempo, não apontou
nada: repetiu o mesmo parágrafo três vezes com os nomes do enum como
"critérios". A regra local viu mais que a segunda passada. Em DOIS casos reais
no aparelho (prova/5 forçado; este pela tela), a revisão assistida não
acrescentou uma informação sequer — num deu `indisponivel`, no outro deu três
`inconclusivo` com uma linha que soa favorável.

**Pergunta central — (a) ficar, (b) só aparecer quando cabe, (c) sair.**

Recomendo **(b) com a condição no PROVEDOR**: "Conferir com IA" só aparece com
`ContaGrok.ligada`; sem ela, o lugar do botão mostra uma linha curta ("Revisão
da IA: precisa de conta Grok. O modelo do aparelho não devolveu revisão válida
em nenhum caso real"). A rota no aparelho continua no código (provada por
teste), só não é oferecida como decisão.

Por que não (b) por tamanho, como a pergunta sugeria: o caso desta revisão
COUBE (2.997 ≤ 3.500) e mesmo assim não produziu nada — o portão de tamanho
deixaria o botão aparecer exatamente no caso em que ele engana mais.

Evidência:
1. **Eixo 4 (cada volta mantém ou reduz decisões e carga).** Com (a), a V5 põe
   no cartão uma decisão nova que, no aparelho de referência sem Grok, termina
   em `indisponivel` (prova/5: 3.977 > 3.500) ou em "3 inconclusivos" (este
   caso). Decisão sem poder, duas vezes provada.
2. **04a: a promessa ANTES do fato.** (a) é honesto depois do toque; (b) é
   honesto antes. A informação continua na tela; só o toque inútil some.
3. **Não é (c)**: com Grok a rota é real (`janelaPadrao` = 18.000; executor
   "Grok · revisão assistida" provado por teste) e o parser/limite estão
   provados sobre saída adversa REAL nas duas rodadas. Retirar apagaria uma
   capacidade que existe para quem tem o provedor. Ressalva: a revisão pelo
   Grok NÃO foi executada em caso real (sem conta em nenhum simulador) — se o
   orquestrador exigir prova antes de qualquer botão, (c) é a alternativa
   conservadora e a rota volta com a prova.
4. **Custo de (b):** uma condição em `botaoDaIA` + uma linha de texto + um
   teste. `ContaGrok.ligada` pode mudar em tempo de execução; recalcular ao
   voltar à cena, como já se faz com `verificarAcesso`.

Independente da escolha, **P2-a é obrigatório**: a linha não pode soar
favorável quando nenhum critério foi confirmado.

## 3. Design (julgar/portão)

Capturas simctl (iPhone 17 do dono, 1A46B6D3): `v5-versao-gerada.png`,
`v5-conferencia-expandida.png`, `v5-conferencia-botoes.png`,
`v5-pedir-ajuste.png`, `v5-pedir-ajuste-campo.png`, `v5-conferindo.png`,
`v5-conferir-ia-estado.png`, `v5-revisao-ia-expandida.png`,
`v5-revisao-ia-rodape.png`, `v5-nao-feita.png`, `v5-regressao-acao-aviso.png`.

- **Label à esquerda:** a linha "Conferência: 1 possível divergência · 1
  critério não avaliado" quebra em duas linhas ALINHADA À ESQUERDA, chevron à
  direita (`v5-versao-gerada.png`). P3-c da V4 resolvido.
- **Trecho do pedido uma vez por fonte:** só o 1º critério mostra "No pedido
  (instrução): “…”"; os outros dois não repetem (`v5-conferencia-botoes.png`).
  P3-j da V4 resolvido. "instrução" com acento (P3-d da V4 resolvido).
- **Botões de texto no disclosure:** "Pedir ajuste", "Conferir de novo",
  "Conferir com IA" empilhados no `AcaoTrabalhoStyle`, sem cartaz. Lê como
  ações da conferência. Correto.
- **"Conferência: não feita":** versão escrita à mão mostra a linha em
  `tintaSuave` e NENHUM botão (não há pedido) — honesto e sem decisão morta
  (`v5-nao-feita.png`). A ADR escreve "não feita · Conferir"; a tela mostra a
  linha e os botões só quando há pedido. Coerente.
- **Foco do "Pedir ajuste" (P3-b):** o foco vai ao campo e o teclado abre, mas
  a rolagem deixa visível só o FIM do texto inserido (cursor depois de "para
  conferir."); o cabeçalho "Ajustar a versão anterior:" fica atrás da barra de
  navegação (`v5-pedir-ajuste.png`). O autor vê um rabo de texto que não
  escreveu. Precisa rolar para cima para ler o que entrou
  (`v5-pedir-ajuste-campo.png`).
- **Densidade depois das duas voltas — virou painel na expansão.** Colapsado,
  o cartão está bem: produtor, uma linha por registro, artefato. Expandido, a
  local dá 3 critérios + rodapé + 3 botões e a revisão da IA dá mais 3
  critérios (o MESMO parágrafo citado 3×) + rodapé + botão, e a segunda
  disclosure nasce ABAIXO dos botões da primeira, ENTRE "Conferir com IA" e o
  artefato (`v5-conferir-ia-estado.png`). "Conferir com IA" aparece DUAS vezes
  (dentro da local e dentro da IA — `v5-revisao-ia-rodape.png`). A carga é
  maior que na V4; a hierarquia colapsada é melhor. Ver P3-a, P3-d.
- **Em andamento só quando expandido:** "A IA está conferindo…" vive dentro
  do disclosure (`v5-conferindo.png`); com ele colapsado nada na tela diz que
  há uma chamada em curso (P3-h).
- Fora do diff, pré-existente: `\[Seu Nome]` com barra literal no
  `ConteudoTrabalhoView` e as listas "1." repetidas (Markdown do modelo).

## 4. Prova executada por este revisor

Tudo via `ferramentas/orca/com-trava.sh`. Simulador de teste 6033B043 ligado
por mim e desligado ao fim; o 1A46B6D3 do dono ficou como estava (booted).

| Passo | Resultado literal |
|---|---|
| `xcodebuild test` no 6033B043, `-derivedDataPath build` | 1ª: "The test runner hung before establishing connection" (EXIT 65, simulador recém-ligado). 2ª: **"✔ Test run with 618 tests in 121 suites passed after 6.611 seconds"**, `Suite ConferenciaTrabalhoTests passed`; 40 `@Test` no arquivo |
| `xcodebuild build` `generic/platform=iOS Simulator` | BUILD SUCCEEDED, 0 warnings |
| `xcodebuild build` `id=1A46B6D3` | BUILD SUCCEEDED, 0 warnings |
| `./maestro/varrer.sh maestro/trabalho-acao-aviso.yaml` (só o 1A46B6D3 booted) | `FALHAS: nenhuma`, EXIT 0; `TRACO_SEM_MODELO` desarmado ao fim (`v5-regressao-acao-aviso.png`: horário guardado, "Avisar 30 min antes", "A hora do aviso já passou" honesto) |
| Jornada real, modelo LIGADO | §2. Registro no disco lido do `default.store` do App Group: 1 pedido `pronto`, 1 artefato `Apple Intelligence no aparelho`, 2 conferências com o MESMO `pedidoID` (`v5-caso-real.json`) |

Aviso: o fluxo de regressão tem `clearState: true` e apagou o estado do app
no simulador do dono, inclusive os dois Trabalhos desta jornada; o dump JSON
foi tirado ANTES.

Instrumento (para a memória): `scrollUntilVisible` com `centerElement: true`
deixa o alvo atrás da barra de navegação da folha e o `tapOn` seguinte cai em
"Voltar" (aconteceu 3×). O que funcionou: rolar com `swipe` a partir do cartão
(nunca a partir do TextField, que vira seleção) e tocar só com o alvo entre
25% e 85% da tela. O primeiro "Preparar com IA" após dois swipes ficou em
y=14 e o toque não disparou.

## 5. Merge

`git merge-tree --write-tree main HEAD` → árvore 162ac37, saída 0, **sem
conflito**. main avançou só com `ferramentas/orca/consulta-v6-pratica.md`.
`xcodegen generate` não altera o pbxproj commitado.

## 6. Achados por severidade

### P1
Nenhum.

### P2
- **a) A linha da revisão soa favorável com ZERO critérios confirmados.**
  `ConferenciaTrabalho.linha` só cai em "nenhum critério examinado" quando
  `resultados.count == n` (naoAvaliado); `inconclusivo` não conta como não
  examinado, então 3 inconclusivos viram "a IA não apontou divergências nos
  critérios examinados · 3 inconclusivos" (ConferenciaTrabalho.swift:59-70).
  Evidência: `v5-conferir-ia-estado.png` + `v5-caso-real.json` (as três
  situações = `inconclusivo`, `trechoFonte` vazio). É o "selo enganoso" que a
  consulta V4 nomeou e que a ADR proíbe ("recusa não vira ausência de
  problema"). Correção mínima: quando `d == 0 && i + n == count`, a linha diz
  "\(titulo): nenhum critério confirmado · N inconclusivos · M não avaliados";
  um teste com três inconclusivos.
- **b) `pedidoDe` casa um pedido que NÃO produziu a versão.** Material
  importado sem envelope entra com `anteriorID = nil`
  (IntercambioTrabalho.swift:71,140) e base antiga entra com `anteriorID =
  base`; `pedidoDe` procura `pedido.artefatoID == a.anteriorID` (Trabalho.swift:152)
  e acha o 1º pedido (artefatoID nil) ou o pedido que produziu a versão
  SEGUINTE à base. A tela então oferece "Conferir" / "Conferir com IA" e grava
  uma conferência presa a um `pedidoID` que não gerou aquele texto — contra o
  05p ("presa ao pedidoID que a produziu"). Correção mínima: exigir
  `a.origem == .ia` em `pedidoDe` (só `receber` cria versão com pedido); um
  teste com versão importada.

### P3
- **a) Nomes do enum na tela como título de critério** ("atendidoNoEscopo",
  "divergencia", "naoAvaliado" — `v5-revisao-ia-expandida.png`). O parser
  aceita qualquer String não vazia em `criterio`; nos DOIS casos reais o modelo
  do aparelho pôs o valor do enum. Barato: recusar `criterio` igual a um
  `rawValue` de `SituacaoCriterio`/`FonteCriterio` (→ `indisponivel`, "formato
  exigido"), ou nomear o limite na ADR.
- **b) Foco do "Pedir ajuste" mostra o fim do texto**, não o início (§3).
  Rolar para o topo do campo (`rolagem.scrollTo("pedido", anchor: .top)` — o
  `ScrollViewReader` já existe) resolve.
- **c) Todo registro vira uma linha no cartão** (`ForEach(registros)`,
  TrabalhoView.swift:263) — a V4 mostrava só `.last`. Três "Conferir de novo"
  = três linhas idênticas; cada toque sem provedor persiste um `indisponivel`
  a mais. Mostrar o último de cada executor (local e IA) e deixar o resto no
  histórico.
- **d) "Conferir com IA" duplicado**: `botaoDaIA` está dentro da local E
  dentro da IA (:302), e a `ProgressView` também nasce nas duas. Um só lugar.
- **e) O texto do "Pedir ajuste" vira `Pedido.instrucao` sem marca de origem**
  (`definir("pedido", …)` → `gerar`). Com divergência vinda da IA, a
  justificativa da IA entra no pedido como se fosse do autor e volta ao modelo
  como "PEDIDO VIGENTE DA PESSOA". A ADR decidiu assim e o autor edita antes;
  fica registrado que a origem não é preservada no pedido (AGENTS: "texto
  gerado não vira voz pessoal por estar no mesmo arquivo").
- **f) Sem teste de revogação DURANTE o await** da revisão (a consulta pediu
  "revogação durante espera"); o código cobre (:233), a prova não.
- **g) `Task.isCancelled` nunca é verdadeiro**: a Task de `revisarComIA` não
  vai para `tarefa`, então `verificarAcesso()` negado não a cancela; o guard
  pós-await segura, mas a chamada em curso vai até o fim.
- **h) Chamada em curso invisível com o disclosure colapsado** (§3).
- **i) Mensagem "a IA citou um trecho que não aparece…" quando `trechoFonte`
  vem VAZIO** — a IA não citou nada; a frase atribui uma citação que não houve.
- **j) prova/5.md e a ADR dizem "jornada pela tela: fora"** — esta revisão fez
  a jornada e ela contradiz em parte a leitura de que "pela rota do app a
  revisão nem roda": roda quando o artefato é curto, e devolve inconclusivos.
  O caso desta revisão (dump + capturas) merece entrar em prova/5.md como
  segundo caso real, e a linha de EVOLUCAO deve dizer "roda no aparelho com
  artefato curto e não produz revisão utilizável".
- **k) `janelaPadrao` com Grok ligada mas falhando**: a mensagem de 18.000
  desce ao aparelho, `mensagemDoAparelho` recusa > 3.500 → "Nenhum provedor
  respondeu" — honesto, mas o motivo não diz que foi limite. Só registrar.
- Instrumento: `{id: "trabalho-conferir-ia"}` não foi exercitado por id (toque
  por texto); mesma classe do P3-i da V4.

### O que está certo e provado (para não ser refeito)
Uma chamada por toque e nunca em `gerar`; acesso revalidado antes, depois do
await, no `alterar` e na view; parser derruba JSON/chave/enum inválidos e
citações inventadas (provado sobre saída REAL do aparelho, pela tela);
`indisponivel` com motivo, nunca silêncio; teto 05m sem corte e sem chamada;
proveniência efetiva gravada e produtor intacto (disco); "Pedir ajuste" só
preenche e foca; "não feita" sem botão morto para versão à mão; export/import
inalterados; label à esquerda e trecho único por fonte; 618/0; regressão da
folha OK; merge sem conflito.
