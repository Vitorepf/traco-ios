# Consulta V6 — o segundo ciclo dentro do Trabalho: praticar de verdade

Consultor: GPT-6-Astra (Codex), 05/09/2026, só leitura sobre main 4c3d398. Pergunta do orquestrador: contrato mínimo para `Apoio.praticar` ser real (preparação, tentativa autoral, feedback sem resposta), demonstração honesta de capacidade, gargalo corrigível, e a primeira fatia de uma volta.

Recomendação: prática textual dentro do Trabalho, com preparação, tentativa e feedback separados; sem motor adaptativo novo.
Base lida: /Users/vitorepf/develop/traco-ios, main 4c3d398, limpo; o worktree volta-6-consulta está em 2ca50c5 e não contém os arquivos pedidos.
Consulta somente de leitura: visão inteira, EVOLUCAO, ADRs solicitadas, modelos, fluxo de Trabalho, conferência, Recordar e prova/4.md; nenhum build/teste executado.

1. Contrato mínimo
• A pessoa nomeia o que quer conseguir fazer, em qual situação e qual dificuldade quer trabalhar; pode mudar o apoio sem penalidade.
• A IA prepara enunciado executável, exemplo resolvido DIFERENTE da tentativa e critérios compreensíveis de conferência; material e critérios são propostas atribuídas à IA.
• Critério descreve o desempenho esperado sem conter a resposta-alvo; exemplo, tradução e explicação continuam permitidos como apoio explícito.
• A pessoa começa em campo vazio, escreve ou dita a tentativa e a guarda; registrar tentativa não marca ação executada nem capacidade adquirida.
• Tentativa guarda origem pessoa, autoria atribuída, contexto e apoio efetivamente utilizado; desconhecido não vira “sem ajuda”; conteúdo conhecido como copiado/externo mantém sua origem.
• O modelo nunca completa esse campo; revisão é nova tentativa ligada à anterior, preservando a primeira e o apoio usado em cada uma.
• NÃO usar guardarVersaoHumana para isso: após artefato da IA ela cria origem mista e troca versaoAtual; a resposta do exercício pertence à evidência da ação.
• A conferência 05p continua presa ao material/pedido e às suas limitações: idioma e tempo não conferem espanhol correto, compreensão ou pronúncia.
• “Conferir minha tentativa” é operação própria: lê enunciado, critérios, apoio e tentativa INTEIROS; responde por critério com situação e trecho literal da tentativa.
• Primeira fatia: retorno estruturado restrito a IDs, situações fechadas e intervalos/trechos validados; a UI acrescenta “Reveja este critério e tente novamente”.
• Sem campo livre para solução, reescrita ou elogio no feedback; cobertura incompleta fica não avaliada/inconclusiva, nunca acerto implícito.
• Reusar o padrão de validação do Recordar, não seu julgamento de recuperação; Prova.vaza pega cópia literal, não garante ausência de resposta por paráfrase.
• Feedback informa quem avaliou, quando, método e limites; permite discordar, tentar de novo ou pedir mais apoio explicitamente.

2. Demonstração e hipótese honestas
• Evento pertinente = tentativa preservada em tarefa vinculada ao objetivo + situação + critérios anteriores + apoio utilizado + conferência atribuída.
• Enviar resposta produz tentativa; há evidência de demonstração apenas para os critérios sustentados pela resposta, dentro desse contexto e com esse apoio.
• “Falei em voz alta” é relato; texto digitado/ditado sustenta análise textual, não avaliação acústica ou prova de fala espontânea.
• Uma demonstração não prova desenvolvimento: melhora exige comparação pertinente; transferência exige outra tarefa/contexto e nova evidência, sem promoção automática.
• Hipotese.evidencias aponta somente para as evidências pertinentes, não todas as do Trabalho como faz hoje a UI.
• Pessoa ou IA podem propor, com autoria/fonte explícitas; só a pessoa confirma/contesta nesta fatia, com motivo e evidências selecionadas quando a alegação for sobre capacidade.
• “Confirmada por você” conserva o significado atual de concordância contextual; não se transforma em certificação do app ou avaliação independente.
• Contestação não apaga tentativa nem feedback, invalida pedidos dependentes e acompanha o próximo contexto; ausência de resposta ou delegação não é incapacidade.
• Retrato/Trajetória deverão projetar registros datados: tarefa, apoio, trecho, avaliação atribuída e hipótese contestável, com ligação à fonte; sem escore, seta ou rótulo global.
• Retrato precisa respeitar o interruptor e manter rótulo+conteúdo completos no teto; Trajetória mantém períodos, sem declarar progresso por contagem.
• Não alimentar Degraus/Sinais com “demonstrou”: hoje calibram estímulo por uso/satisfação; inclusive “domina esta forma” não deve ser reutilizado como evidência.

3. Gargalo corrigível
• Os dois caminhos são válidos; nesta volta, começar pela pessoa, reaproveitando Hipotese e expondo-a também antes do primeiro relato.
• Pergunta mínima: “O que está dificultando isso?”; permitir contexto, recursos, acesso ou divisão do trabalho, não só habilidade.
• Inferência futura deve dizer “estas tentativas divergiram neste critério; pode ser X”, citar tentativas distintas e perguntar se a leitura faz sentido.
• Reexecutar conferência sobre a mesma resposta não cria padrão; divergências do ARTEFATO DA IA indicam problema da ajuda, não déficit da pessoa.
• Nenhuma sugestão muda objetivo, valores, dificuldade ou apoio por baixo; aceitar, corrigir e dispensar devem ser gestos claros.

4. Fatia de um dia e fronteiras
• Escopo: um exercício textual por preparação, tentativas sucessivas, feedback restrito e ajuste manual do apoio no mesmo Trabalho.
• Trabalho.swift: Artefato.pratica? com capacidade/situação, hipoteseID?, enunciado, exemplo e critérios identificados; usar a ação existente ligada ao material.
• Evidencia.tentativa? acrescenta origem, apoioUtilizado, anteriorID? e conferencias?; texto/data/ação/material já existem; guardar resposta como dado do autor, sem chamá-la apenas de relato na UI.
• Conferência da tentativa guarda identidade, data/executor/método e resultados por critério; não reaproveitar Artefato.conferencias, cujo alvo é outro.
• Hipotese recebe propostaPor?, avaliadaEm? e motivoAvaliacao?; registros antigos sem autor/data permanecem desconhecidos, nunca reconstruídos como fatos.
• Apenas propriedades Codable opcionais no JSON existente: ausência = sem prática/avaliação, formato 1 e SwiftData V4 preservados; validar IDs e vínculos no agregado.
• PraticaTrabalho.swift, único arquivo novo de produção: DTOs/parser e montagem/validação pura do contrato; evitar extrair campos de Markdown por heurística.
• OficinaTrabalho.swift/MotorTrabalho: ramificação de preparação estruturada ao praticar; feedback separado, injetável, preso à tentativa/material/critérios e acesso.
• Reusar infraestrutura de provedor, persistência e cancelamento; não reutilizar prompt de produção delegada para corrigir tentativa; falha mantém o material bruto e diz que a prática estruturada não ficou disponível.
• TrabalhoView: seção “Praticar” com objetivo/dificuldade corrigível, material, campo vazio “Minha tentativa”, apoio usado, Guardar, Conferir e Nova tentativa; histórico preservado.
• Em combinar, tornar explícito o trecho que a pessoa exercita; se faltar essa delimitação, não classificar a entrega inteira como prática.
• Deixar integração global de Retrato/Trajetória e detecção automática para outra volta: exigem Perfil, Sessao, Padrões e Intents consistentes; a evidência permanece examinável no Trabalho.
• Atualizar SPEC/EVOLUCAO com esse limite; testes em suites existentes de Trabalho/Contexto/Privacidade e uma suite pequena do contrato de prática.

5. Riscos e o que provar
• Dívida cognitiva: não entregar a solução na tentativa/feedback; exemplos reconhecíveis como apoio, não prova de autonomia; sem bloqueio moral ao delegar.
• Selo/expressivas: revalidar antes da leitura/envio, depois do await e em toda projeção; origem removida ou protegida restringe também tentativa, feedback e rascunhos.
• Gamificação: nenhuma streak, medalha, contagem de acertos como capacidade, subida automática de degrau ou promessa de aprendizagem.
• Custo: preparação a pedido e conferência a pedido, sem loop de autocorreção ou inferência em cada tecla; teto inteiro, fallback explícito e nova chamada somente por gesto.
• Testes: JSON antigo sem novos campos; referência inválida; origens IA/pessoa/mista/externa preservadas; retry de save sem duplicação e sem apagar rascunho; reabertura recupera tentativa.
• Testes: callback atrasado após nova tentativa/material/apoio/contestação e revogação; payload parcial, JSON inválido, ID/trecho inventado ou texto livre não produz veredito.
• Testes: reavaliar não cria outra demonstração; uso/serviu/ação executada não confirma hipótese; confirmar concordância não declara aprendizagem; feedback não sobrescreve resposta.
• Caso real pela tela, com provedor identificado: três blocos de cinco minutos, sozinho, iniciante, sem instrutor/câmera; exemplos em espanhol com tradução portuguesa e tarefas distintas.
• A pessoa escreve/fala suas frases, guarda o que de fato produziu, recebe indicação de critério/trecho sem solução e faz outra tentativa com apoio registrado; reabrir e inspecionar dados.
• Ler toda a saída contra o pedido: traduções reais, espanhol utilizável e distribuição de 15 minutos; 05p já deixou passar traduções ausentes e não pode ser a única prova.
• Encerrar com “prática textual e feedback contextual demonstrados”; aprendizagem duradoura, pronúncia e transferência seguem pendentes até evidência própria.
