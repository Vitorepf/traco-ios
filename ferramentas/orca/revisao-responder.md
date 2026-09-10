# G3 RESPONDER — veredito

**APROVADO para mesclar os SETE consertos de rota; `responder` FICA cortada, e o
placar do implementador está CONFIRMADO por leitura independente.** Uma ressalva
que não bloqueia (o sétimo conserto não tem guarda que o acuse) e uma correção de
prosa a fazer no relatório dele. Revisor: Opus 5, worktree `responder`, candidato
`9e45605`, 10/09/2026.

## 1. O placar — eu li as 240 saídas, uma a uma

Contei do zero, do JSONL, com os requisitos da fixture na mão: **base 14 e 15 de
20; candidatos 12 e 12.** Bate com o relatado, caso a caso.

Onde discordei, discordei **contra a base**, nunca a favor dela — `revisor-responsavel`
r1 (*"quem combinou a reunião"* é reunião inventada), `revisor-correcao` r2 (*"verifique
se está validado antes de reservar"* é a confirmação extra que o caso proíbe) e
`10b-relatorio-sem-indice` r3 (*"copie o trecho"* num arquivo que não deixa copiar).
As três caem em casos que **a base já reprovava**, então o número não muda. **A
conclusão é robusta à minha régua: se eu apertar, a base cai; os candidatos não sobem.**

Provas que conferi eu mesmo, e não pela palavra dele:

| o que | como conferi | resultado |
|---|---|---|
| o braço BASE é o texto que está no app | sha256 de `Sabia.sistemaResponder` recortado do fonte | `d42d61ea…`, 2.235 ch — **idêntico** ao `pedidoResponderSHA256` das 120 linhas de base |
| os três braços são três textos | `pedidoResponderSHA256` por registro | base `d42d61ea`, c1 `20a0b7af`, c2 `72840c9a` — um por braço, sem mistura |
| mesmo binário nas duas janelas | `prova/10b*/janela.log` | 1 install por janela, hash ANTES/DEPOIS/FIM igual; base e candidato **depois** do mesmo install |
| a fixture não foi reescrita | diff estrutural contra `prova/q2f-casos.json` | os **18 casos da Q2-F são byte a byte idênticos**; só entram 2 controles novos |
| a conta não caiu | 6 fumaças + os 240 registros | `contaGrokLigada: true` em **240 de 240**; HTTP 200 em 240; `grok-4.3` em 240 |
| a leitura mais dura que a da Q2-F fecha | 18 casos comuns | base = **13 de 18** contra os 15 de 18 da Q2-F; a diferença são exatamente as **duas** linhas que ele declarou |
| o caso do revisor (já revelado) | li as 12 execuções | reprova nos **quatro** braços; a metade que falta é sempre a continuação |

**Caso cego novo:** escrito e **guardado**, não revelado e não gasto —
`~/orca/prova-restrita/responder/g3-cegos-revisor.json`, modo 600, sha256
`330e43fd1b6288092d5cdc74b6d5d4f93ee9d3ec0f2235891d9b3148ed4fc99c`. Três casos que
a fixture das 20 **não** cobre: instrução hostil colada dentro do material,
contexto que sustenta a resposta inteira (para pegar carência FABRICADA), e forma
pedida na própria pergunta. **Não foram rodados**: os dois aparelhos de conta
estavam com o `instigar` e com o vídeo por ordem desta volta, e nenhum outro
aparelho tem a conta. Limite do instrumento, declarado — não desconta nota.

## 2. As cinco dimensões, com a prova

Sobre as 240 saídas + as 6 da pergunta real. Nota por dimensão, no melhor braço.

| dimensão | nota | a prova |
|---|---:|---|
| aderência ao pedido | **7** | `revisor-orcamento` cai de 3/3 (base) a 0/3 (c1): faz a conta, nomeia os quatro dados que faltam e acaba em *"não é possível aprovar hoje"*, sem um passo. `q2-espanhol-geral` c1 r1 devolve a divisão pedida como escolha do autor |
| correção sustentada | **8** | é a mais alta, e é o que o contrato da 08z comprou: **não achei um único número fabricado nas 240 saídas** — os três casos de gasolina, o do orçamento e o do evento só calculam sobre o que ela deu. O que resta é fabricação de ESTRUTURA — *"vá ao sumário"*, *"Leia só resumos executivos, conclusões e tabelas"* (base `q2-relatorio` r3), *"Abra o PDF"* num arquivo que ela disse ser imagem digitalizada (c2 `10b-relatorio-sem-indice` r2) |
| utilidade concreta | **5** | a Face B, medida: `revisor-venda-nao-observada` c1/c2 param em *"a venda não está concluída"* em 2 de 3; e `revisor-responsavel` entrega uma continuação **sem inventar** em apenas **2 das 12** execuções somadas dos quatro braços (as outras duas que continuam inventam a reunião ou quem a combinou) |
| destinatário e divisão de trabalho | **7** | `q2-biblioteca-sem-horario`: o candidato afirma *"pelo nome e endereço … **que você tem**"* a quem não deu nenhum dos dois — 3/3 → 1/3, e **condicionar a cláusula não resolveu** (2 de 3 ainda afirmam) |
| uso do contexto pertinente | **6** | a pergunta REAL do aparelho: em 2 de 3 do c1 a vizinha do autor entra na proposta da padaria **como se fosse plano do cliente**. E `q2-dado-alem-do-recorte` prova o teto do produto: os 12 km/l e os R$ 6,00 ficam **depois** dos 5.000 e **nenhuma das 12 execuções** os cita |

**Nenhuma dimensão chega a 9 em nenhum braço, e nenhum braço chega a 20 de 20.**
`responder` fica em `indisponivelPorQualidade`, e **tirar o `conserto` da linha do
Perfil é a decisão certa**: ele nomeava exatamente o que estas duas tentativas
mediram e não fecharam. A tela deixou de prometer o que já falhou.

## 3. Os sete consertos, um a um

Provados por MUTAÇÃO no teste 4 (`A1DF082C`), cada um com as irmãs que não acusam.

| # | conserto | mutação que apliquei | vermelho | veredito |
|---:|---|---|---|---|
| 1 | identidade da requisição | `guard self.perguntaAtual == id` → `guard case .sabiaPensando?` | `retornoAtrasadoDeAnaoPublicaNaPerguntaDeB` (2 issues) | **PASSA** |
| 2 | página lida antes do `await` | leitura movida para dentro da `Task` | `oContextoEODaNotaQuePerguntou` (2) | **PASSA** |
| 3 | revalidação da fonte antes de publicar | `guard Self.dependenciasValidas(…)` → `guard true` | `fonteSeladaDuranteAEsperaNaoPublicaAResposta` (2) | **PASSA** |
| 4 | divulgação só do que coube | corte por bloco removido de `contextoDaPergunta` | `aDivulgacaoNomeiaSoAsVizinhasQueCouberam` + `vizinhaQueNaoCabeFicaDeForaInteiraComORotulo` (6) | **PASSA** |
| 5 | falha fica junto da pergunta | `.pergunta(q)` → `cartao = nil` | `aFalhaDeixaAPerguntaNoCartaoComRecuperacao` (1) | **PASSA** |
| 6 | corte silencioso aos 900 fora do parser | corte restaurado em `limparResposta` | `aRespostaLongaChegaInteiraComARessalvaDoFim` (3) | **PASSA** |
| 7 | retorno BRUTO no portão | `diagnostico.bruto = msg` apagada | **NENHUM** — `1038 tests … passed` | **passa em FATO, sem guarda** |

**Em cada uma das seis mutações, um único teste (ou o par do conserto 4) acusou e
as outras 12 ficaram verdes** — as irmãs existem e não acusam por acaso. Rodei
`-only-testing:TracoTests/RespostaNaPaginaTests` (13 testes) por mutação, e a
suíte INTEIRA na sétima.

Três julgamentos que fui conferir no código, e não na prosa dele:

- **#3 não tem furo de filtro.** O que VIAJA passa por `!fechada && gesto != .expressiva && prosa não vazia`; o que é REVALIDADO passa por `fonteParaPergunta` (`!fechada`, não expressiva, `temVoz`). Conferi que `fechada == trancada || queimada` e que prosa não vazia implica `temVoz`: **não há vizinha que viaje e escape da revalidação**. E `fonteParaPergunta`/`dependenciasValidas` já existiam (4 usos em `aabc52d`) — é reúso, não maquinaria nova.
- **#6 tem superfície.** `CartaoAnaliseView` renderiza `Text(texto)` sem `lineLimit`, dentro do `ScrollView` do cartão: a resposta inteira chega ao autor. E `limparResposta` tem **um** chamador de produção, que alimenta só o cartão — nada persiste nem entra em widget. Conferi na Q2-F que o corte era real: **4 das 54 execuções do `grok-4.5` terminavam em `…` no meio da frase** (`prova/q2f-modelo-45.jsonl`, 900 e 901 caracteres).
- **#4 tem superfície.** `notasNaPergunta` (agora só o que coube) é o que `divulgacaoDaPergunta` escreve na linha *"foram junto: …"*. Ressalva pequena: `notasNaPergunta` e `notasLidasNaPergunta` são escritos **antes** do segundo guarda, então uma tentativa vencida pode deixar os números dela na tela pela fração de segundo até a seguinte reescrevê-los. Transitório, nunca nomeia nota que não viajou.

## 4. A raiz: confirmada, e ela era pior do que ele disse

> *o corpo de `perguntarASabia` era INALCANÇÁVEL pela suíte.*

**Confirmado, e o número é ZERO.** Não é "parava na primeira linha": `git grep
perguntarASabia aabc52d -- TracoTests TracoUITests` devolve **um comentário numa
tabela** e nenhuma chamada. Nem unitário nem de interface tocava a função. Depois:
os 13 testes novos entram no corpo por **seis caminhos distintos** — expressiva,
aviso da Política, resposta publicada, resposta nula, fonte revogada e retorno
com identidade vencida — e a suíte executa **47 das 49 linhas** de `perguntarASabia` (cobertura com
`-only-testing:TracoTests/RespostaNaPaginaTests`, `xccov`). Antes: **0 de 49**.

**O que MAIS está inalcançável — a pergunta que fica de pé.** A medida responde
sozinha: as **duas** únicas linhas zeradas são `cartao = .semConta` e o `return nil`
dela (`Sessao.swift:592-593`) — o ramo `disponivel: false`, que é **justamente o
único que um autor sem conta Grok alcança hoje**. Nenhum dos 13 testes o toma. É
uma linha de teste, e é a mesma lei que esta volta acabou de pagar para aprender.
Fora desta rota, o mesmo cheiro está em toda função que só se alcança com a conta
ligada: procure `Sabia.disponivel`, `ContaGrok.ligada` e `Motores.desligados` lidos
DENTRO do corpo em vez de chegarem por parâmetro — foi essa leitura, e não um
teste, que achou os quatro defeitos de rota desta volta.

## 5. Achados — nenhum bloqueia a mescla dos sete

1. **O sétimo conserto não tem guarda.** Nenhum teste da suíte toca
   `Grok.Diagnostico.bruto`: apaguei a linha `diagnostico.bruto = msg` e rodei a
   suíte INTEIRA — `✔ Test run with 1038 tests in 164 suites passed after 145.585 seconds.`, **verde**. O fato está provado por
   **180 de 180 chamadas com `bruto` preenchido** nos JSONL, e o portão é mesmo
   único (`URLSession` só aparece em `Grok.swift` e no `ContaGrok`, que não infere).
   Mas um vigia que ninguém pode derrubar não está provado: se a linha sumir, só a
   próxima corrida descobre.
2. **A costura morreu e o botão dela ficou — e cala.**
   `ferramentas/orca/lote-ia-09d-janela.sh:49` ainda exporta
   `SIMCTL_CHILD_TRACO_AVALIAR_PEDIDO`, e **nenhum Swift lê essa variável** (o
   seletor foi apagado no fecho). Quem rodar o 6º argumento de `rodar` acha que
   mediu o pedido anterior e mede o atual, **em silêncio** — é a "rota que cala"
   da DIRETRIZ §8, agora dentro do instrumento de medida. `pedidoResponderSHA256`
   denuncia, mas só para quem olhar. **Apague a linha 49 ou devolva o seletor.**
3. **Os dois textos reprovados foram apagados.** Sobram o sha256 e três cláusulas
   citadas. O produto desta volta é *"a próxima tentativa não repete estas duas"* —
   e a próxima tentativa não pode ler nenhuma das duas. **Guarde os dois textos em
   `prova/10b/` (são pedido nosso, não nota do autor).**
4. **Uma comparação sem base.** O relatório diz que a pergunta real é *"o único
   lugar onde o candidato 2 é claramente melhor que a base"* — mas a base **nunca
   foi rodada** na pergunta real (a coluna é `—` na própria tabela dele). O 2 de 3
   fica; a comparação, não. Corrija a frase.
5. **A régua da redação não valeu para a prosa.** O JSONL real foi redigido com
   rigor (só sha e tamanho do contexto), e aí o relatório cita no corpo os títulos
   de duas notas reais do aparelho. Baixo risco, mas é a regra dele mesmo.

## 6. Instrumento (meu)

- Build **LIMPO** (`clean build`, 324 ações `SwiftCompile`), **0 erros**,
  **2 linhas de warning**, ambas o herdado `NotasView.swift:814`. Nenhum novo.
- Suíte no **teste 4** (`A1DF082C`), nunca em aparelho de conta:
  `✔ Test run with 1038 tests in 164 suites passed after 146.189 seconds.`
- **Árvore própria, auditada por NOME**: os 13 testes de `RespostaNaPaginaTests`
  aparecem um a um como `passed` no log (`retornoAtrasadoDeAnaoPublicaNaPerguntaDeB`,
  `aDivulgacaoNomeiaSoAsVizinhasQueCouberam`, `fonteSeladaDuranteAEsperaNaoPublicaAResposta`,
  `aRespostaLongaChegaInteiraComARessalvaDoFim`, e os outros nove).
- **Não medi comportamento em aparelho**, então não houve `cmp` de binário meu: a
  minha prova de mérito é leitura de saída e mutação de suíte.
- Captura conferida no CONTEÚDO, não na existência: `10b-perfil-responder-fica-na-lista-large.png`
  mostra `responder` no grupo *"O que ela ainda não faz, nem com a sua conta ligada"*
  — quatro linhas — com a frase nova e **sem** conserto. `instigar` e `contrapor`
  seguem no grupo com conserto. E a linha é afirmada pelo caminho da tela
  (`PerfilView.reprovadas` → `linhaDa`) em `PoliticaTests`, então o portão morde
  sem a foto.
- Sem voz, sem VoiceOver, sem iPad, sem tamanho de letra de acessibilidade.
  Nenhum simulador criado, apagado ou desligado por mim.
