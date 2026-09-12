# Qualidade efetiva da IA — trabalho em curso

Pedido de 07/09/2026: elevar a qualidade da IA em todo o Traço, com mínimo
9/10, algoritmos verificáveis onde a regra é fechada e loop independente de
qualidade. O objetivo integral permanece aberto; um incremento não o conclui.

## Resultado e critério

Quem usa o Traço recebe ajuda pertinente ao objetivo, correta no escopo,
utilizável e fiel às restrições, com autoria e proteção preservadas. Regras
determinísticas também são falíveis. A nota 9/10 é um limiar de avaliação por
caso e dimensão, nunca garantia matemática sobre qualquer pedido futuro.

Rubrica: aderência ao pedido, correção sustentada, utilidade concreta,
adequação ao destinatário e divisão de trabalho, uso do contexto pertinente.
9 = cumpre integralmente os requisitos obrigatórios, sem erro material;
restam apenas refinamentos que não impedem o uso. 10 = nenhum defeito
encontrado naquela avaliação. Qualquer requisito obrigatório descumprido
reprova o caso, independentemente da média. Não usar nota dada pelo próprio
gerador como aprovação. Segurança/autoria/persistência são invariantes,
não dimensões que se compensam por média.

## Escopo e provas obrigatórias

| ID | Operação/requisito | Prova exigida | Estado |
|---|---|---|---|
| Q1 | Produzir/revisar Trabalho delegado | Pedido real de espanhol das provas 4–5, variantes e tarefas distintas; ler saída completa, cumprir todas as restrições, revisão encontra erros reais sem inventar | medido com Grok em 08/09 (ADR 08q): produzir 5 de 6; revisar 3 de 6 por teto de 90 s, não por conteúdo. Teto vigente 300 s (08r/09n). Em 12/09 a rota nomeia timeout/cancelar/limite/recusa (`Grok.FalhaHonesta`) em vez de «revisão incompleta». Citação inventada já cai a inconclusivo. Ainda sem aprovação semântica final nem jornada no aparelho (Q8) |
| Q2 | Preparar prática e conferir tentativa; combinar prática e entrega | Casos da prova 6 e novos contextos, exercício executável, exemplo pertinente, critérios observáveis, feedback correto sem substituir tentativa | medido com Grok em 08/09: conferirTentativa 6 de 6; prepararPratica 1 de 6 por teto de 90 s. Depois do teto 300 s a 08r mediu entrega 4 de 6 — 3 recusas foram do nosso contrato, nomeadas (08p). Em 12/09 timeout não vira «exercício inválido» (`Erro.provedorCalou`). Sem aprovação semântica final nem jornada no aparelho (Q8) |
| Q3 | Perguntar, instigar, contrapor e recuperar contexto | Respostas nas Notas/Página com fontes disponíveis, perguntas e informações pertinentes, sem inventar fatos ou ações; perguntas sem resposta sustentada têm tratamento útil | medido com Grok em 08/09: responder 3 de 6 (fabricação de fato), instigar 1 de 6 (jargão do prompt), contrapor 1 de 6 (fato inventado) — as três cortadas na 08q. responderNasNotas voltou em 10/09 (`soGrok`, grok-4.5). Em 12/09 abrir a forma consulta `Politica.aviso(.instigar)` antes de chamar (`PortaoDaRotaQueCalaTests.aFormaAbertaNaoDisparaInstigarCortado`); a Lente continua a superfície. Sem remedição pareada de instigar/contrapor/responder |
| Q4 | Classificar, vestir e inferir domínio | Casos positivos e negativos do catálogo, escrita pessoal e ambiguidade; forma não altera palavras; regras sem chamadas desnecessárias | medido em 08/09: classificar 5 de 6 (regex local), dominio 4 de 6 no aparelho com instabilidade, vestir 5 de 6 no motor LOCAL — Grok em vestir não exercitado. Em 12/09: sem classificador novo; domínio continua `.soBordo`; vestir automático não altera as palavras (`AutoVestirTests.pausaVesteDireto`); silêncio automático é invisível (`PortaoDaRotaQueCalaTests`). Portão `Q4CadernoUnicoTests`: domínio não vai à rede; plantar infere da nota, não da página; sem objeto Território nem wizard de taxonomia. Sem painel novo. Jornada no aparelho = Q8 |
| Q5 | Recordar, ecos, calibragem e Padrões | Recuperação sem resposta vazada, comparação correta de significado, relações sustentadas e hipóteses atribuídas; não confundir contagem com aprendizagem | medido com Grok em 08/09: padroes 6 de 6 e conferir 6 de 6; ecos 3 de 6, calibragem 2 de 6, recordar 1 de 6 — as três cortadas na 08q. Em 12/09 a régua (`Prova.vaza` Lisboa/15) e a porta (`paresDaCalibragem` aceita um par) estão no candidato; as rotas seguem cortadas. `Sessao.contextoDoCaderno` consulta `Politica.provedor(.ecos)` antes de montar candidatas (`PortaoDaRotaQueCalaTests.oContextoDoCadernoNaoDisparaEcosCortado`). Fumaça neste candidato no simulador coordenado `1A46B6D3` (12/09 19:01Z, `/tmp/traco-remedir-sim-11a`, `prova/12-sim-fumaca-11a.jsonl`): `contaGrokLigada:false`, `portaCalibragemAceitaUmPar:true`, `reguaLisboaNaoVaza:true` em toda linha, `chamadasGrok:[]`. O script abortou na conta (exit 4) depois de nomear a 11a no binário; sem remedição. O caderno do simulador ficou. Fumaça no aparelho do dono (12/09 17:29Z, binário Debug já instalado, sem install): `contaGrokLigada:true`, 12 modelos, carimbos de pedido iguais ao candidato (`d42d61ea…` / `90fd80e7…`). Identidade da 11a no mesmo binário (17:36Z, `TRACO_AVALIAR_LIBERAR=recordar,calibragem`): `qn-calibragem-par-unico` chegou com 1 item e calou em 0,3 ms, `chamadasGrok:[]` — porta velha (`pares.count >= 2`). Lisboa foi ao modelo e devolveu «Qual é a sede do governo português?» (não distingue a régua). Sem remedição pareada, sem reabrir rota, sem JSONL inventado. A sonda passa a carimbar `portaCalibragemAceitaUmPar` e `reguaLisboaNaoVaza` em cada linha. O script de remediar alcança o iPhone (`VIA=devicectl`) sem install e aborta sem esses carimbos; esvazia antes de copiar (o `copy to` salta arquivo do mesmo tamanho) e confere o sha da fixture. Ainda não rodou no candidato atual. Fixture em `prova/12-recordar-calibragem-casos.json`; provas do aparelho em `prova/12-aparelho-fumaca.jsonl` e `prova/12-aparelho-identidade-regua-porta.jsonl`. `SO=1` no iPhone do dono (12/09 19:09Z, `prova/12-aparelho-fumaca-so.jsonl`): conta ligada, 12 modelos, carimbos da 11a ausentes (`porta`/`regua` None), exit 5 — sem matriz, sem reabrir. O Debug instalado continua o de 17:36Z. |
| Q6 | Contexto e continuidade | Contexto pertinente chega ao executor, pedido/correções não são cortados, selo revalidado após await; resultado anterior influencia ajuste sem perder origem | guardas de produto verificadas em 12/09 (`Q6ContextoContinuidadeTests`): correção da pessoa não corta; resposta da IA cede; resultado anterior viaja no ajuste sem virar voz do autor; selo no await descarta o retorno e a folha recusa resposta se a fonte mudou. Jornada no aparelho = Q8 |
| Q7 | Provedor e estados reais | Operações exercitadas pelo caminho de produção; modelo/versão/condições identificados sem segredos; timeout, cancelamento, limite e recusa preservam dados e não simulam qualidade | portão local em 12/09: `Grok.FalhaHonesta` nomeia timeout/cancelar/limite/recusa; `textoCompleto` continua nil (não simula qualidade); frases dizem que o escrito fica. Superfícies: Sessao, Notas, Lente e Trabalho (revisar / preparar / produzir / conferirTentativa). Jornada no aparelho = Q8 |
| Q8 | Integração e regressões | Build, testes relevantes e jornada no simulador explicitamente escolhido, com conteúdo completo e estados reais; revisão independente do candidato | C9 Markdown tocada no simulador coordenado em 12/09 (`JornadaC9UITests`, `/tmp/traco-c9-ui5.log`). Jornada no aparelho do dono continua não verificada |

Avaliar base e candidato com condições comparáveis; registrar entradas,
saídas completas, modelo, duração, hashes e critérios. Casos conhecidos e
casos novos do revisor são separados, sem chamar de teste cego o que não foi.
Falhas não desaparecem do denominador. Recusar tudo não é excelência: medir
também a capacidade de atender pedidos legítimos e o custo de uso/espera.

Revisão independente do contrato (07/09): incorporadas as cinco lacunas do
revisor. Antes de medir o candidato, fixar casos por operação × executor e
fallback, três inferências novas por caso generativo (sem reaproveitar memo),
com saídas completas. Cada caso legítimo obrigatório precisa entregar resultado
utilizável >=9 em cada dimensão em todas as três execuções; indisponibilidade,
recusa e timeout falham atendimento, mesmo quando passam recuperação. Uma
amostra finita não prova o requisito literal "sempre" para entradas futuras.
Casos novos revelados na revisão passam a regressões após usados na correção;
a aprovação final exige outra leitura independente e casos novos pertinentes.

O app deve detectar violações verificáveis antes de tratar a geração como
entrega, tentar reparo delimitado quando possível e preservar pedido, versões
e uma explicação acionável quando não conseguir. Reparo esgotado não conta
como atendimento. Julgar artefatos bons e ruins, erros omitidos e inventados.
Combinar exige entrega delegada E prática do trecho escolhido. Recordar inclui
paráfrase, contradição e resposta parcial. Contexto inclui ausência, material
irrelevante/antigo/conflitante, instruções hostis dentro do material, revogação
durante await e retomada. Perguntas sobre fatos atuais precisam de fontes
atuais ou limite explícito; não declarar fatos inventados como resposta.

## Fontes e placement

Bootstrap emulado a partir de AGENTS.md, VISAO-PRODUTO.md, SPEC §§17–19,
EVOLUCAO.md, provas 4–6 e código vigente. Este repo não contém `artisan` nem
o documento de governança apontado pela projeção; não se instala infraestrutura
de outro produto para esta tarefa. Donos: Traco/Analise para cliente/montagem;
Traco/Trabalho para produção, revisão e prática; Traco/App/Sessao para contexto;
TracoTests e provas para avaliação. Reusar esses pontos antes de criar camadas.

Branch inicial: codex/qualidade-ia, base fdc3aa3. Outras worktrees não fazem
parte do candidato. Preservar modelos/dados, contratos locais de escrita
pessoal, selo, versões e cancelamento. Sem compra, publicação ou envio de
mensagens externas; chamadas existentes necessárias à avaliação dentro do
escopo autorizado, sem copiar credenciais entre ambientes.

## Próximos passos

1. Auditar este contrato independentemente e inventariar provedores/rotas.
2. Reproduzir falhas e estabelecer uma avaliação reutilizável ligada ao app.
3. Corrigir causas compartilhadas: contexto, contrato de saída, verificação
   determinística pertinente, provedor e geração/revisão conforme evidência.
4. Executar casos reais, rever independentemente, corrigir e integrar.

## Evidência da sessão

Ainda sem aprovação de qualidade. A compilação e o autoteste MCP da análise
anterior são históricos. Evidências desta corrida:

- Base `qualidade-ia-base-20260907.jsonl`: Apple Intelligence, sem conta Grok,
  três inferências por caso; espanhol reprovado 3/3, classificação aprovada
  somente no caso de decisão escolhido, notas com fatos corretos mas sem fonte
  em 3/3. Leitura independente em `qualidade-ia-avaliacao-base.md`.
- Corrida E0DC84FE em `qualidade-ia-contexto-vestir-20260907.jsonl`: o ajuste
  de prompt não corrigiu fontes 3/3; vestir teve seis recusas e três mapas
  sem melhoria útil. Não contar preservação sem atendimento como excelência.
  A representação das fontes e a dependência desnecessária de modelo em vestir
  estão sendo corrigidas após essa evidência.
- Teste selecionado de 14:06 UTC: 133 passes e duas expectativas antigas de
  mensagem, atualizadas para a descrição explícita das durações individuais.
- Teste selecionado de 14:16 UTC: 137 passes, nenhum erro/skip; inclui fluxo
  Combinar (duas partes, falha parcial e cancelamento entre chamadas), disco,
  feedback por IDs, 700 linhas compactas e guarda de pedido direto.
  Bundle `test_sim_2026-09-07T14-16-12-595Z_pid22167_b2004cbb.xcresult`, no
  diretório de resultados do XcodeBuildMCP. Mudanças posteriores requerem
  testes novamente. Nenhum desses testes usa inferência como prova semântica.

Pendências materiais observadas: produção aceita texto não vazio mesmo com
conteúdo inadequado; feedback ainda pode confirmar critério não observável;
fontes e dependências da conversa precisam de revalidação; Q5 precisa de
avaliação viva com paráfrase/contradição/parcial. A conta Grok continua ausente
no simulador explicitamente escolhido; a solicitação de login ao usuário está
pendente, sem impedir correções e avaliações locais.

## Evidência da corrida de 08/09 (volta Q, ADR 2026-09-08q)

Primeira medida COM a conta Grok ligada, no único aparelho autorizado
(`C2416CBC`). 16 operações × 6 casos × 3 execuções, três lançamentos distintos,
sem memo. Candidato **`acdfcb4`** — o commit que carrega a quarta regra, a
sobrecarga morta apagada e as quinze provas. (`325c819`, que esta seção dizia
antes, só acrescenta `ferramentas/orca/LACO.md` e não implementa nada da 08q;
corrigido em 08/09 pela volta Q-B, achado do G3.) A corrida usou **dois**
binários, e o JSONL diz qual é qual: a matriz de 16 × 6 × 3 rodou na árvore de
`325c819` (bundle `504d29d7…`, dylib `2152892a…`), e a remedição com fontes
tipadas rodou na árvore que virou `acdfcb4` — ver a tabela na ADR 08q. Fixture
`prova/q-qualidade-casos.json` (`29654d46…`); saídas inteiras em
`prova/q-qualidade-avaliacoes.jsonl`; leitura em `ferramentas/orca/q-qualidade.md`.

- Atenderam 6 de 6 casos nas três execuções: `conferir`, `padroes`,
  `conferirTentativa`.
- Cortadas por qualidade na 08q, em dois grupos: sem substituto medido —
  `ecos` (3/6), `calibragem` (2/6), `recordar` (1/6), `instigar` (1/6),
  `contrapor` (1/6); com conserto nomeado — `responder` (3/6, fabricação) e
  `responderNasNotas` (4/6 na remedição com fontes tipadas: recusa por inteiro
  quando falta o fato atual, e deixa escapar rótulos internos).
- 20 falhas de transporte (28 % das 72 chamadas a `grok-4.6`), TODAS nas rotas
  de Trabalho, com teto de 90 s; 0 falhas em 177 chamadas `grok-4.3`.
  `prepararPratica` cai a 1 de 6 casos por isso, não por conteúdo. Indisponibilidade falha atendimento e não sai do denominador.
  **20 é o número certo; onde se leu 12 (ADR 08q e EVOLUCAO) estava errado** —
  a própria tabela somava 11 + 6 + 3. Recontado linha a linha no JSONL em
  08/09 pela Q-B, que também mediu o conserto (ADR 2026-09-08r).
- **Medida invalidada, e o defeito é nosso:** três casos de
  `responderNasNotas` usaram `Sabia.responderNasNotas(pergunta:contexto:)`,
  que não tinha chamador de produção e fabricava uma fonte de título
  "Contexto fornecido". A "atribuição genérica do provedor" era um título do
  próprio app. A sobrecarga foi apagada; a sonda exige `fontes`. As bases de
  07/09 e de `prova/cinco-itens-*` usam a mesma conveniência nesses casos e
  medem a mesma rota morta — registro, sem reescrita de prova alheia.
- Os 59 casos novos foram escritos e lidos pelo implementador: **não são teste
  cego nem held-out**. A aprovação final exige casos novos de um revisor que
  não os tenha visto.
