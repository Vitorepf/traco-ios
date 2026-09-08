# Consulta de arquitetura — G0 da V17

08/09/2026 · Conselho Astra · primeira consulta da volta · parecer, não decisão nem implementação.

## A pergunta, como recebida

A DIRETRIZ §4 diz que **o laço que falta é de OBSERVAÇÃO e VERSÃO, não de renderização**: o Trabalho já tem versões com origem, a tentativa do autor como evidência separada, pedido de ajuste e ida e volta pelo arquivo; o Caderno já renderiza blocos próprios (campos, tarefas, áudio, recipientes `:::slug`) com Tema, VoiceOver, Dynamic Type e movimento reduzido.

**Onde, no modelo que já existe, mora a volta "observação da tentativa → versão N+1 com o motivo escrito no próprio documento" — e qual é a MENOR adição de contrato que a fecha?**

Responda isso em três partes, e prefiro parecer curto e decidido a inventário:
1. **O lugar.** O exercício é um tipo novo de bloco do Caderno, um artefato de Trabalho, ou os dois ligados? Diga onde a versão N+1 nasce e quem a guarda, citando os tipos e as ADRs que já existem. **O risco que eu quero que você ataque de frente: o artefato virar um segundo Trabalho paralelo**, duplicando versões, origem, corpus e índice.
2. **O contrato mínimo.** Que campos ou estados **novos** são inevitáveis, e quais são tentação a recusar? Lembre que "produzido, praticado e demonstrado são estados distintos" e que "reescrito não é aprendido".
3. **A fronteira da IA, aplicada aqui.** A prática dentro do artefato é o segundo ciclo: **a tentativa é do autor, a IA não preenche a resposta**. Diga onde exatamente a IA entra (forma, informação e pergunta) e onde ela **não pode** entrar, no nível do contrato e não do prompt — e como a modificação "por necessidade percebida" se anuncia no documento sem virar ruído.

## 1. O lugar

**Recomendo os dois ligados, com um único dono: Trabalho. Concordo com a DIRETRIZ §4.** O exercício é `DocumentoTrabalho.Artefato.pratica`; o bloco do Caderno é sua representação e porta de interação. A resposta continua em `Evidencia.tentativa`, vinculada por `artefatoID` e `acaoID`, e sua leitura em `Tentativa.conferencias` (ADR 05r). Nenhum desses registros pertence ao bloco.

A N+1 nasce pela rota existente `OficinaTrabalho.gerar` → `MotorTrabalho.produzir` → `DocumentoTrabalho.receber`, que acrescenta `Artefato` com `anteriorID`, `intencaoID`, origem e produtor. `OficinaTrabalho.guardar` confirma o agregado no `Trabalho.conteudoJSON` (05i, 05s). A tentativa da N e a ação que a recebeu permanecem ligadas à N; não se mudam seus vínculos para parecer que responderam à N+1.

**A premissa já avançou desde a 05r:** a ADR 08a permite preparar lendo tentativas anteriores; `contextoDeRetorno` e `PraticaTrabalho.montarPreparacao` já fazem isso. As ADRs 08c/08d exigem preservar restrições e mudar concretamente a atividade. Portanto, falta tornar a causa do ajuste um dado vinculante, legível e recuperável; não falta um segundo motor de contexto.

Para este único exercício, `BlocoCaderno.recipiente(slug:linhas:)` já comporta a representação: não é necessário outro agregado, banco ou sequer outro caso de enum. `Artefato.pratica` governa a preparação validada; o Markdown é sua serialização legível, como já ocorre em `PraticaTrabalho.emMarkdown`. O bloco usa a identidade do artefato, não o índice posicional de `FatiaCaderno`. Reusa o intercâmbio do Trabalho, sem arquivo de estado próprio, Nota duplicada ou corpus/índice autônomos. Isso não afirma cobertura atual: `Corpus.swift` declara que seu snapshot exclui Trabalhos e artefatos; uma projeção futura deve ler o mesmo agregado, sob o mesmo acesso.

Há trabalho de superfície real: hoje `ConteudoTrabalhoView` mostra recipientes como texto literal, e `TrabalhoView` apresenta a prática separadamente. Integrar o exercício ao documento elimina essa separação e a necessidade de reconstruir o pedido depois do feedback. **Nenhuma tela nova.** Acessibilidade do Caderno é base reutilizável, não prova automática desta ligação (05t, 05y, 06b §18-D).

## 2. O contrato mínimo

**Uma causa de ajuste no pedido e um vínculo explícito da versão ao pedido.** Proponho apenas:

- `Pedido.ajuste?`: gatilho fechado (`pedidoDoAutor` ou `necessidadePercebida`), motivo e referências à evidência e, quando usada, à conferência e aos critérios que sustentam o ajuste. A instrução do autor já tem lugar em `Pedido.instrucao`; a base e a intenção já estão em `Pedido.artefatoID/intencaoID`. Necessidade percebida exige evidência pertinente e leitura identificada; pedido do autor pode existir sem tentativa ou feedback.
- `Artefato.pedidoID?`: ligação direta à causa persistida. Hoje `pedidoDe` a infere por base e intenção; essa inferência não deve ser a autoridade para explicar uma transformação. Ausência nos registros antigos significa vínculo não registrado, sem reconstruir causalidade histórica.

O resultado da adaptação deve trazer **o que mudou**, além da preparação válida. O app compõe no próprio `Artefato.conteudo` uma seção curta com essa descrição, o motivo e sua atribuição, antes do mesmo commit que guarda N+1. O texto descritivo não precisa de outra entidade persistida: já vive na versão Markdown. O código fornece os vínculos e a atribuição; o modelo não inventa IDs nem decide qual pedido o produziu. Motivo e mudança não podem ser apenas um cabeçalho convincente sobre exercício repetido.

A evidência causal completa, seus critérios, a correção vigente e as restrições ainda aplicáveis são **núcleo obrigatório** da adaptação. Hoje o histórico pode ser omitido por orçamento; a causa selecionada não pode ficar nesse trecho descartável. Se não couber, o ajuste fica indisponível. Mudança de tentativa, feedback, intenção, apoio, base ou proteção invalida o retorno; não se aplica uma leitura antiga contra a correção nova.

Não acrescentaria um `EstadoExercicio` persistido: **produzido** vem da versão guardada; **tentativa registrada** vem da evidência do autor; **desempenho demonstrado no critério** exige leitura sustentada, com apoio, contexto e avaliador visíveis. Feedback favorável da IA permanece avaliação assistida, não certificação; pronúncia sem evidência de áudio é não avaliada. N+1 nasce produzida, sem herdar desempenho da N. Não há `aprendido`, pontuação global, contador de domínio ou promoção automática de hipótese. Os estados de `Pedido` já cobrem preparação, falha e interrupção.

Preservam-se as leis de 05l/06a: append, commit antes do anúncio, retry da mesma versão sem gerar outra, conflito com escolha e conteúdo preservado. O motivo acompanha o `.md`; ao voltar editado, continua conteúdo de autoria externa não verificada. Marcadores importados não autenticam observações, não criam tentativas `.pessoa` e não habilitam ações; sem preparação local validada, o bloco é leitura inerte. Voltar à N é leitura a um toque; retomá-la como material vigente deve preservar a N+1 no histórico.

## 3. A fronteira da IA

**A IA escreve o próximo instrumento de prática; só o autor escreve a tentativa.** Forma: redistribuir o exercício para isolar conjugação. Informação: explicar a regra e oferecer exemplo resolvido de outro caso. Pergunta: pedir novas frases que exijam a escolha que falhou. Na conferência, apenas resultados por critérios existentes, trechos literais e observação atribuída; hipótese sobre a dificuldade continua corrigível pelo autor.

A barreira é de tipos e de escrita: a saída de adaptação aceita preparação e descrição da mudança, sem campo de resposta ou comando para alterar `Evidencia`. A mutação só acrescenta artefato; `guardarTentativa` permanece uma operação do autor. Em `combinar`, vale o limite existente de `trechoExercitado`; a parte delegada também não pode conter a solução desse trecho. Campo de tentativa começa vazio, sem sugestão incorporada e sem autocorreção que altere conjugação. Validação estrutural impede escrita na evidência, mas **não prova ausência de solução disfarçada no enunciado**: esse limite exige leitura semântica, como a própria 05r reconhece. Falha não pode cair em geração delegada.

Para necessidade percebida, delimitaria o ato visível como **“Conferir e adaptar o exercício”**: a pessoa solicita a leitura; a observação pertinente decide a mudança, sem obrigá-la a redigir outro pedido. Isso precisa ser contrato explícito desse ato, pois “Conferir minha tentativa” hoje promete uma operação própria e uma chamada por toque (05r). Uma conferência sustentada pode originar um ajuste; inconclusivo, ausência de resposta e reabertura do documento não disparam reescrita. A mesma conferência não gera versões repetidas; outra adaptação exige nova evidência ou pedido. Sem loop em segundo plano nem troca do documento enquanto a pessoa está digitando.

Após o commit, uma única seção no documento anuncia, por exemplo: **“Nesta versão — a partir da leitura da IA sobre sua tentativa anterior, concentrei o segundo bloco na concordância entre sujeito e verbo; os três blocos de cinco minutos foram mantidos.”** A frase é ilustrativa e só vale se o material a cumprir. “Ver tentativa”, “Versão anterior” e “Corrigir o motivo” dão acesso aos registros e à correção usando as rotas existentes. A leitura contestada deixa de orientar novos ajustes; a história fica. O anúncio não repete todo o histórico nem declara que a pessoa aprendeu.

O bloco declara suas capacidades locais e não recebe rede, arquivos arbitrários, notas protegidas, envio ou gasto. A IA continua serviço do Trabalho, pelas rotas e permissões existentes; um recipiente Markdown não concede nenhuma delas (05j).

**O que precisa ser provado:** no espanhol concreto, uma tentativa com erro gera atividade diferente e pertinente, preserva as restrições e deixa a próxima resposta em branco; uma correção do dono remove a interpretação equivocada do ajuste seguinte; fechar e reabrir conserva N, tentativa, causa e N+1, inclusive após falha de gravação, retry, conflito ou revogação. Ler as respostas completas com a sonda da frente Q e conferir o documento em uso, incluindo teclado e acessibilidade. Isso sustenta o item 6; o item 1 só se resolve quando o dono efetivamente usa e continua a situação real, não quando a demonstração técnica passa.

Base consultada: visão dos dois ciclos; DIRETRIZ §4; RUMO, fila de 08/09; SPEC, ADRs citadas; EVOLUCAO, “Artefato que se transforma”; tipos e consumidores locais em `211ce0e`. Consulta documental e de código, sem build, teste ou medição de provedor. Governança/placement emulados pelas fontes locais: esta árvore não contém `artisan` nem o documento de governança Atlas. Nenhuma afirmação de qualidade atual foi derivada dos passes históricos.
