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
| Q1 | Produzir/revisar Trabalho delegado | Pedido real de espanhol das provas 4–5, variantes e tarefas distintas; ler saída completa, cumprir todas as restrições, revisão encontra erros reais sem inventar | não verificado no candidato |
| Q2 | Preparar prática e conferir tentativa; combinar prática e entrega | Casos da prova 6 e novos contextos, exercício executável, exemplo pertinente, critérios observáveis, feedback correto sem substituir tentativa | não verificado |
| Q3 | Perguntar, instigar, contrapor e recuperar contexto | Respostas nas Notas/Página com fontes disponíveis, perguntas e informações pertinentes, sem inventar fatos ou ações; perguntas sem resposta sustentada têm tratamento útil | não verificado |
| Q4 | Classificar, vestir e inferir domínio | Casos positivos e negativos do catálogo, escrita pessoal e ambiguidade; forma não altera palavras; regras sem chamadas desnecessárias | não verificado |
| Q5 | Recordar, ecos, calibragem e Padrões | Recuperação sem resposta vazada, comparação correta de significado, relações sustentadas e hipóteses atribuídas; não confundir contagem com aprendizagem | não verificado |
| Q6 | Contexto e continuidade | Contexto pertinente chega ao executor, pedido/correções não são cortados, selo revalidado após await; resultado anterior influencia ajuste sem perder origem | não verificado |
| Q7 | Provedor e estados reais | Operações exercitadas pelo caminho de produção; modelo/versão/condições identificados sem segredos; timeout, cancelamento, limite e recusa preservam dados e não simulam qualidade | não verificado |
| Q8 | Integração e regressões | Build, testes relevantes e jornada no simulador explicitamente escolhido, com conteúdo completo e estados reais; revisão independente do candidato | não verificado |

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
