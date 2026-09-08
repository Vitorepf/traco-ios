# Cinco itens — jornada, provedores, qualidade e continuidade

Trabalho iniciado em 08/09/2026. Objetivo integral aberto até a jornada integrada
atual e a qualidade das respostas pertinentes serem demonstradas.

## Escopo e estado

| Item | Mudança/evidência | Estado |
|---|---|---|
| 1. Jornada real de espanhol | Exercício, tentativa, feedback, ação, relato, ajuste e retomada; prova integrada ainda em execução | Aberto |
| 2. Avaliar provedores | 16 operações × 3 execuções com conta Grok; mesmas 48 sem conta. Entradas, requisitos e retornos completos nos JSONL | Base medida; candidato Grok 4.6 em avaliação |
| 3. Corrigir IA da jornada | Contexto ligado à ação/exercício, critérios sobre produção da pessoa, apoio pertinente, esforço de raciocínio nas operações de Trabalho | Candidato, sem aprovação semântica final |
| 4. Continuidade | Histórico mostra tentativas e feedback; atalhos ao ato e retorno; contexto preserva origem e pedido vigente, corte explícito | Testes e retomada visual passaram; revisão final aberta |
| 5. Resultado orienta ajuste | Relato leva ação, estado e versão; prática recebe tentativa, critério e feedback; novo relato cancela resposta obsoleta | Relato preservado e V2 adaptada; qualidade da adaptação ainda insuficiente |

## Ambiente e verificações

- Base de entrada: `23aad0a`, árvore limpa. Durante o trabalho, outro processo
  criou `5065929`, incluindo as primeiras alterações desta sessão. O conteúdo
  foi preservado; não houve commit, reset ou push por esta sessão.
- Projeto XcodeGen isolado: `/tmp/traco-cinco-itens-projeto/Traco.xcodeproj`,
  fontes atuais do repo, build em `/tmp/traco-cinco-itens-build`.
- Simulador teste 2: `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`, conta conectada
  pelo usuário e confirmada no Perfil em 08/09. Nenhuma credencial foi copiada.
- Simulador teste 3: `34CC3F94-FDB5-4575-A4F5-80271829A18B`, sem conta,
  Apple Intelligence disponível. Sem apagar dados nem alterar configurações.
- 84 testes de Trabalho/prática/contexto/qualidade passaram em
  `/tmp/traco-cinco-itens-testes-2.xcresult`.
- Suíte completa: **887 testes, 143 suítes, zero falhas**, em
  `/tmp/traco-cinco-itens-testes-3.xcresult`. Modelos desligados pelos testes;
  isso prova contratos e regressões, não qualidade de geração.
- Depois das alterações de raciocínio/prompts: 68 testes selecionados passaram
  em `/tmp/traco-cinco-itens-testes-4.xcresult`.

## Base viva por operação

Casos sintéticos em `cinco-itens-ia-casos.json`, três inferências sem memo.
As chamadas seguem a política de produção: sem conta, as nove rotas que exigem
Grok ficam indisponíveis; não se contorna a política para produzir saída pior.
A coluna sem conta não afirma que o Apple Intelligence executou rotas bloqueadas.

| Operação | Com conta, base | Sem conta, base |
|---|---|---|
| Produzir | 2/3 atendem; um intervalo perde segundos | 0/3, política exige Grok |
| Preparar prática | 0/3: apoio e critérios incoerentes | 0/3, política exige Grok |
| Conferir tentativa | 3/3 no caso correto; uma observação expõe IDs internos | 0/3, política exige Grok |
| Revisar | Acha tempo/professor em 3/3, mas inventa exigências e tem citações rejeitadas | 0/3, política exige Grok |
| Responder nas notas | Prazo/orçamento corretos 3/3; fonte genérica da API legada, não nota específica | 0/3, sem retorno |
| Responder | Três divisões de tempo; respostas dependem de material não fornecido, utilidade limitada | 0/3 no requisito integral; uma resposta excede quinze minutos, outra desvaloriza qualidade |
| Instigar | 0/3: linguagem interna e perguntas sobre o método | 0/3: duas sem retorno e uma repetitiva/inadequada |
| Contrapor | 0/3: generalizações e analogias factuais sem sustentação | 0/3: repete/reforça a premissa |
| Vestir | 3/3, estrutura local preservada | 3/3, estrutura local preservada |
| Recordar | 1/3; duas sem retorno | 0/3, política exige Grok |
| Conferir o que voltou | 3/3 no caso de paráfrase completa | 0/3, política exige Grok |
| Ecos | 3/3, notas pertinentes; contradição também é relação permitida | 0/3, política exige Grok |
| Calibragem | 2/3 com perguntas pertinentes; uma saída vazia | 0/3, política exige Grok |
| Padrões | Respostas 3/3, mas pressupostos em algumas perguntas; sem aprovação global | 0/3, política exige Grok |
| Classificar | 3/3 na saída final, com arbitragem local | 3/3 na saída final |
| Domínio | 2/3 trabalho, uma casa; esta rota é sempre do aparelho | 3/3 trabalho |

Denominador limitado: um caso por operação não representa toda a distribuição.
A base usa o identificador configurado antigo; não registrava o modelo devolvido
pela API. A nova sonda registra status HTTP, modelo solicitado e respondido,
esforço e desfecho, sem headers, credenciais nem corpo de erro.

## Provas

- `cinco-itens-grok-base.jsonl`: corrida `0F738527-7495-40F1-B3E3-89919B46C91A`.
- `cinco-itens-apple-base.jsonl`: corrida `951B2420-E34F-4E55-8FEC-A29E893E32B7`.
- `cinco-itens-grok-base-revisao.md`: leitura independente das quatro operações
  de Trabalho, sem confundir formato válido com utilidade.
- `cinco-itens-candidato-raciocinio.json`: hash de todo bundle do candidato,
  incluindo a dylib que contém o código Debug.

## Limites e trabalho restante

Reprovações fora da jornada estão medidas e expostas; não se declaram corrigidas
por trocar um prompt de Trabalho. A avaliação atual do candidato e as variantes
independentes precisam ser lidas integralmente. A jornada visual e o retorno → ajuste com provedor real foram executados;
faltam qualidade suficiente na adaptação, revisão final e atualização da matriz.
Tentativas de QA são sintéticas, nunca relato pessoal do usuário nem prova de
que ele aprendeu espanhol.

## Checkpoint da jornada e correções posteriores

- Pela UI com Grok: intenção sintética `QA 08/09 - Praticar espanhol do zero`,
  exercício V1, tentativa `Me llamo Ana. Soy Recife. Soy designer.`, apoio declarado,
  feedback com duas divergências corretas, relato de escrita parcial sem fala.
- Fechar, instalar o candidato e reabrir preservou contexto e ação pendente.
  `cinco-itens-retomada.png` e `cinco-itens-historico.png` foram examinadas.
- A adaptação V2 usa os erros, mas a revisão independente considerou o ajuste
  pedagógico insuficiente. JSON e Markdown das duas versões permanecem íntegros.
- A conferência local V2 contou resumo de duração duas vezes e perdeu restrições
  anteriores no pedido genérico de ajuste. Regras v3 e seleção compartilhada
  corrigem ambos; rechecagem pela UI confirmou três marcas/15 minutos e idiomas
  português/espanhol, sem apagar o parecer anterior (`jornada-conferencia-v3.json`).
- Rodada `85DF38EE-128E-49A4-8F57-49899EF2C136`: 27/27 retornos completos;
  leitura independente aprovou 15/27 no pedido integral. Preparação 3/9,
  produção de rotina 3/3, feedback 9/12, revisão de material adequado 0/3.
  Leia `cinco-itens-variantes-medium-revisao.md`; não omitir as falhas.
- Testes 7 não iniciaram: host encerrou antes da conexão do runner. Testes 8:
  890/891 passaram; uma asserção de frase perdeu o ponto final após edição do
  prompt. A frase foi preservada; testes 9 passaram e suíte 10: **891/143, zero
  falhas**. Testes 11 e 12 cobrem os prompts e conferência posteriores.
- Candidato `high` medido: 12/24 atenderam integralmente na leitura independente
  (`cinco-itens-high-revisao.md`). Preparação curta substitui instruções conflitantes;
  feedback separa completude de correção do que foi escrito; revisão distingue
  atendimento observável no material de certificação global/execução no mundo.
  Não há aprovação antecipada deste candidato.

Documentação oficial consultada: [Grok 4.3](https://docs.x.ai/developers/models/grok-4.3)
e [migração de modelos](https://docs.x.ai/developers/migration/may-15-retirement).
O diagnóstico registra o esforço solicitado; o campo de tokens de raciocínio,
quando fornecido pela API, distingue pedido de evidência de uso. Sem esse campo,
não se infere quantidade de raciocínio só pela duração ou pelo nome do modelo.

## Checkpoint Grok 4.6 e contrato de apoio

- A consulta autenticada de modelos confirmou `grok-4.6` disponível à conta.
  As quatro rotas de Trabalho passam a solicitá-lo; o diagnóstico confirmou
  o modelo respondido e tokens de raciocínio. Demais rotas permanecem em 4.3.
- Sondagem inicial: quatro respostas completas, preservadas em
  `cinco-itens-grok46-sondagem.jsonl`. A preparação de apresentação omitiu
  vocabulário de profissão necessário à opção fictícia oferecida. Feedback
  parcial e revisão do material adequado reconheceram evidências corretamente.
- A preparação de comida dizia “agua (use una)”. A leitura inicial desta sessão
  classificou isso como erro, mas a revisão independente encontrou na RAE que
  a forma é permitida, embora “un agua” seja habitual. Não reprovar por esse
  motivo: [RAE](https://www.rae.es/espanol-al-dia/el-agua-esta-agua-mucha-agua-0).
- O contrato agora permite explicitamente ensinar palavras e traduções,
  preservando a montagem das frases pela pessoa. Não foi criada segunda
  chamada automática: o experimento registrado em `cinco-itens-segunda-leitura.jsonl`
  não demonstrou benefício suficiente.
- Suíte 17: **891 testes / 143 suítes passaram**. Após o ajuste de vocabulário,
  testes de PraticaTrabalho passaram na suíte 18. Isso não aprova a semântica.
- Candidato com apoio explícito instalado no teste 2, sem apagar dados.
  Hash do bundle em `cinco-itens-candidato-grok46-vocabulario.json`.
  Rodada `cinco-itens-grok46-casos.json`: 11 casos × 3 execuções em andamento,
  incluindo preparação, adaptação do histórico real de QA, feedback, revisão
  e produção. Nenhuma aprovação antecipada.

Documentação do modelo: [Grok 4.6](https://docs.x.ai/developers/models/grok-4.6).
