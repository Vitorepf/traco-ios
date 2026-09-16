# Traço — intenção, realização e desenvolvimento

Decisão de produto de 05/09/2026, consolidada a partir da explicação direta do criador. Esta é a tese vigente; descreve a direção do produto, não certifica que todas as capacidades já estão implementadas. A [SPEC](SPEC.md), ADR 2026-09-05g, registra a mudança e preserva o histórico.

## Para que existe

O Traço transforma o que a pessoa pensa e deseja em realizações no mundo, combinando sua mente, a IA e um ambiente compartilhado de trabalho. Ao realizar, também desenvolve as capacidades que limitam o que essa pessoa poderá realizar depois.

A amplitude é intencional: criação, raciocínio, planejamento, estratégia, linguagem, aprendizagem e execução podem participar do mesmo objetivo. Criar uma empresa, uma obra ou uma experiência; compreender um assunto; organizar compromissos; desenvolver uma habilidade são expressões dessa finalidade. Notas, calendário, métodos e segundo cérebro são componentes desse sistema.

O Traço deve encurtar o caminho entre intenção e resultado com clareza, boa divisão de trabalho, métodos pertinentes e verificação. Um artefato pronto, uma ação executada e um resultado no mundo são avanços diferentes. A aplicação deve mostrar qual deles ocorreu. Resultados que dependem de outras pessoas, condições materiais ou tempo não podem ser declarados alcançados apenas porque a IA produziu um plano convincente.

## Cinco tipos de app num caderno só

Decisão de 16/09/2026, com o criador. Não há nome de mercado para o Traço porque ele fica no cruzamento de cinco tipos de app que hoje existem separados. Cada um faz bem uma parte e falha exatamente onde o outro começa:

| Tipo | Exemplos | O que falta nele | O que o Traço toma dele |
|---|---|---|---|
| **Caderno** | Apple Notas, Journal da Apple, Day One | Não sabe nada além do que você escreveu | A página em branco, rápida, sem menu, que veste a forma certa (Decisão, WOOP, Pré-mortem…) |
| **Segundo cérebro** | Obsidian, Notion, Reflect, Mem, Capacities | Lembra, mas não sabe das suas decisões nem do que aconteceu depois | Notas ligadas, busca pelo sentido, perguntar às próprias notas com a fonte, Recordar e Padrões |
| **Biblioteca com IA** | NotebookLM, Readwise, Recall | Guarda os mestres, mas não sabe da sua vida | As obras dos mestres como consulta com fonte (vídeo, minuto), nunca como voz do autor (ADR 16a) |
| **Diário de decisões** | Planilha de decisões | Não traz conselho nem aprende sozinho | A Decisão com data de conferir e o «o que aconteceu» que volta (ADR 05b, 16e) |
| **Tutor com IA** | ChatGPT como estudo | Esquece você e pensa por você | A IA que pergunta, contrapõe e ensina sem escrever como o autor (ADR o, 14a) |

**O segundo cérebro é a base.** É a memória que torna os outros quatro possíveis: sem ela não há mestre certo na hora certa nem resultado para comparar. É também o tipo mais disputado — como segundo cérebro puro, o Traço compete de igual para igual com apps que fazem isso há anos.

**O diferencial fica em cima da base.** A decisão que você escreve encontra, na hora e com a fonte, o que seus mestres disseram, e depois é confrontada com o que de fato aconteceu. Nenhum dos cinco tipos faz isso sozinho, porque nenhum junta a sua escrita, o acervo dos mestres e o resultado. Nome sugerido para a categoria: **um conselho de mestres que vive no seu caderno.**

**Estado em 16/09/2026 (datado, não certificado):**
- *Caderno:* forte — 28 formas reconhecidas sem menu.
- *Segundo cérebro:* responder com as suas notas funciona com a conta Grok, citando de qual nota veio; ligações só manuais (`[[título]]`); «sugerir notas parecidas» (rota `ecos`) está **cortada por qualidade** e volta a ser medida na entrega E6 (`ferramentas/orca/PROMPT-LIDER-CONSELHO.md`); não há mapa de ligações.
- *Biblioteca:* 75 regras conferidas de Hormozi e Lenny; o Grok escolhe a regra certa em 38 de 40 (ADR 16g).
- *Diário de decisões:* a Decisão cobra a conferência na data e o resultado ajusta as regras (ADR 16e).
- *Tutor:* instigar e contrapor seguem cortados por qualidade (ADR 08q).

Uma mudança que fortalece só um tipo isolado, sem ligá-lo aos outros, tende a copiar um concorrente. A que aproxima dois tipos — a nota que encontra o mestre, a decisão que volta com o resultado — é a que só o Traço pode fazer.

## Três participantes

| Participante | Responsabilidade |
|---|---|
| Mente humana | Traz desejos, valores, experiências, contexto e critérios; cria, escolhe e participa conforme o objetivo. Também pode desenvolver capacidades durante o processo. Não precisa chegar com a intenção perfeitamente formulada. |
| IA | Ajuda a compreender a intenção; expande possibilidades; pesquisa, estrutura, compara, produz e executa o que foi delegado; identifica obstáculos e propõe desenvolvimento pertinente. Expõe pressupostos e confronta resultados. |
| Ambiente compartilhado | Torna pensamento e trabalho persistentes, examináveis e transformáveis por ambos: documentos, artefatos, decisões, ações, evidências e relações, com versões e origem preservadas. |

Markdown é a base preferida de documento e intercâmbio. A pessoa deve trabalhar com uma representação legível, sem precisar conhecer sua sintaxe. HTML é uma possibilidade para representações e artefatos interativos, como protótipos e experiências. Converter ou renderizar um formato não implementa sozinho colaboração, execução, histórico ou sincronização. Esses contratos precisam existir também.

O ambiente deve permitir continuar um trabalho por tempo indeterminado, atravessando sessões. Cada objetivo ou tentativa pode ser concluído, pausado ou abandonado. Continuidade não significa manter loops rodando sem trabalho útil nem impedir encerramento.

## Dois ciclos ligados pela experiência

**Multiplicar agora:** esclarecer intenção → ampliar possibilidades → construir algo utilizável → agir → observar o que aconteceu → ajustar. A IA pode fazer trabalho substancial, incluindo produção de artefatos, quando isso atende à divisão de trabalho escolhida.

**Melhorar para multiplicar mais depois:** identificar uma dificuldade relevante → escolher apoio ou prática → aplicar no trabalho → observar capacidade em situação pertinente → recalibrar a ajuda. A dificuldade pode envolver conhecimentos, linguagem, criatividade, julgamento, organização, habilidade técnica ou interpessoal. O sistema deve investigar o gargalo; não pressupor que toda dificuldade exige mais escrita, nem que toda dificuldade é falta de habilidade.

Os ciclos se alimentam: o trabalho revela obstáculos; o desenvolvimento ajuda novas realizações. Recursos, acesso, contexto e divisão de trabalho também podem explicar um obstáculo. A resposta pode ser ensinar, representar melhor, simplificar, delegar ou buscar ajuda especializada.

A interface não precisa expor esse processo como formulário ou sequência obrigatória de telas. Deve começar pelo que a pessoa quer fazer, construir a estrutura conforme ela se torna útil e deixar claras as decisões que realmente precisam dela.

## Delegação e dívida cognitiva

Delegar uma tarefa não constitui dívida cognitiva por definição. Se a pessoa quer criar um produto, delegar programação pode liberar sua atenção para intenção, clientes, estratégia e avaliação. Se ela quer aprender programação, gerar a resposta inteira pode substituir justamente a prática desejada. A mesma ferramenta tem efeitos diferentes conforme o objetivo e a participação.

Neste produto, o risco de dívida cognitiva é perder ou deixar de desenvolver uma capacidade que continua necessária para conduzir o objetivo, julgar decisões relevantes ou exercer a autonomia pretendida. É uma definição operacional a avaliar, não diagnóstico ou alegação científica de causalidade.

A divisão de trabalho deve ser contextual e revisável:

| Propósito atual | Ajuda apropriada | Evidência pertinente |
|---|---|---|
| Produzir uma entrega | IA pode redigir, programar, representar e revisar o que foi delegado | Artefato utilizável, critérios atendidos, verificação proporcional e origem clara |
| Desenvolver uma capacidade | Exemplos, pistas, prática aplicada, contraste e feedback; preservar a atividade que se quer exercitar | Desempenho em tarefa pertinente, contexto e apoio utilizado; nova demonstração quando necessária |
| Decidir e orientar | Tornar alternativas, consequências e incertezas compreensíveis; recomendar quando útil | Critério e escolha coerentes com objetivo e restrições |
| Verificar | Testes, fontes, observação e avaliação especializada conforme a tarefa | Evidência do resultado, com limites explícitos |

Esses propósitos não exigem quatro modos ou uma pergunta antes de cada ação. Não transformar toda realização em prova, exigir domínio do código para avaliar um produto, nem confundir fluência verbal com compreensão. A avaliação pode combinar a participação da pessoa, testes e especialistas; não depende de ela conferir manualmente tudo que delegou.

A nova fronteira de autoria é: **a IA pode produzir trabalho delegado; deve preservar a origem do conteúdo e não substituir silenciosamente o pensamento ou a prática que a pessoa escolheu exercer.** Escrita pessoal, relato íntimo, resposta de exercício, referência e artefato gerado não se tornam equivalentes por estarem no mesmo arquivo. Um gesto explícito de incorporar texto não altera retroativamente sua origem.

A proteção de expressivas, notas seladas e conteúdo privado continua válida. Produzir um rascunho não autoriza automaticamente enviá-lo, publicar, gastar ou assumir compromissos. Uma delegação já concedida deve ser respeitada sem pedir repetidamente a mesma autorização.

## Segundo cérebro como modelo útil e corrigível

A virtualização pretendida é uma representação operacional da pessoa que permita ajudá-la melhor: objetivos, conhecimento expresso, preferências, restrições, decisões, capacidades demonstradas, assistência utilizada e resultados anteriores. Não é uma réplica literal do cérebro nem uma leitura infalível de estados mentais.

O modelo deve distinguir observação, relato e hipótese; manter fonte, contexto e atualidade; permitir correção pela pessoa. “Delegou programação” não implica “não sabe programar”. “Não respondeu” não implica “não entendeu”. Uma dificuldade localizada não autoriza um rótulo global de inteligência ou personalidade.

Rotas de desenvolvimento são hipóteses verificáveis a serviço dos objetivos da pessoa. Exemplo: dificuldade em comparar custo inicial e recorrente pode levar a uma representação mais clara e prática aplicada à decisão presente. O sistema observa se isso ajudou e ajusta. As intervenções precisam ser compreensíveis e corrigíveis, sem condução oculta de valores ou objetivos.

O Retrato atual pode continuar como uma projeção resumida para a IA, mas contagem de uso e avaliação “serviu” não bastam como modelo de capacidade.

## Formas, escrita e referências

A origem declarada pelo criador é uma investigação ampla sobre mente, pensamento, criação e escrita, incluindo tradições espirituais, filosofia e pesquisa científica. Essa origem deve orientar a amplitude da busca; não deve ser apresentada como comprovação de que todas as obras humanas foram examinadas ou de que todas as técnicas têm a mesma evidência.

Escrita é um instrumento central para tornar o pensamento examinável e trabalhável. Métodos como WOOP e Se–então são recursos aplicáveis a situações, não etapas obrigatórias para qualquer realização. Formas visuais devem tornar relações perceptíveis: opções em tabela, dependências em mapa, compromissos no tempo, experiências em protótipos, previsão comparada ao ocorrido.

Uma prática espiritual pode fornecer significado; uma obra filosófica, uma lente; um estudo, evidência delimitada. O catálogo deve distinguir essas funções, a fonte, a adaptação feita pelo Traço e o que se sabe sobre o uso proposto. Beleza, tradição, nome técnico ou citação não certificam eficácia. Afirmar superioridade universal da escrita ou melhora clínica requer evidência específica que esta decisão documental não fornece.

Curva-zero significa reduzir o esforço de operar e compreender a representação. Texto, imagem ou interação devem ser escolhidos pela tarefa. Preservar precisão e acesso ao detalhe; não esconder incerteza em um visual convincente. O esforço de prática só se justifica quando serve à capacidade pretendida.

## Calendário como ponte para a ação

O calendário organiza tempo, compromissos e retomadas. Deve conectar uma intenção ao próximo ato e trazer seu resultado de volta ao trabalho. Um horário passado não significa execução; uma ação feita não demonstra que o objetivo foi alcançado. Adiar muda a janela, sem inventar uma nova realização.

Uma tentativa precisa poder ligar objetivo, responsável, artefato, ação e evidência. Esses são conceitos do domínio, não uma exigência de cinco telas ou de um sistema pesado de gestão. A pessoa não deve administrar os vínculos manualmente quando o contexto permite construí-los e corrigi-los com simplicidade.

## Um caderno, parâmetros escondidos

Um caderno. A pessoa escreve; a IA veste a forma no momento certo e organiza por baixo. Não é um modo, um território nem um painel de categorias.

Os parâmetros (gesto, domínio, origem, liga; e, quando o campo está plantado, função e o par “se encantar → / se travar →”) ficam escondidos. A IA e o Retrato leem. A pessoa não preenche taxonomia. Classificar em silêncio. Pesquisa chega como pesquisa; só vira nó depois do aceite. Obra que não está no caderno não se inventa: diz-se que não está e oferece-se plantar.

A primeira prova desta visão continua sendo uma oferta ou um protótipo ponta a ponta, não “estudar um campo”.

## Distância entre visão e implementação

A auditoria inicial de 05/09/2026 encontrou uma base em notas, métodos, escrita, recordação, calendário, contexto semântico, Markdown e entrada MCP. Encontrou também contratos que ainda restringem produção pela IA globalmente, sinais centrados em uso e ausência, nas rotas examinadas, de um ciclo operacional completo de realização e desenvolvimento.

Esse diagnóstico é datado. [EVOLUCAO.md](EVOLUCAO.md) registra o estado posterior, incluindo Trabalho, ações e intercâmbio, sem esconder lacunas. Esta decisão não torna todas essas capacidades implementadas. Os contratos de `Corpus`, MCP e Sábia precisam evoluir junto com proveniência, persistência e testes; editar apenas o texto que proíbe geração não entrega colaboração confiável. Notas antigas mantêm identidade, conteúdo e proteção; não viram automaticamente objetivos ou evidências de capacidade.

A primeira prova definida para a evolução é uma jornada completa e delimitada: intenção → artefato utilizável → ação no escopo delegado → evidência → ajuste, com uma oportunidade pertinente de desenvolvimento. Pode ser criar e testar uma oferta ou um protótipo. É uma proposta de validação, não restrição da amplitude do produto nem escolha definitiva de mercado.

A evolução deve priorizar: integridade de gravação/restauração e selo; autoria e origem; vínculo entre trabalho e resultado; modelo corrigível do autor; expansão de representação e execução conforme casos reais. Sem reescrita geral ou catálogo maior como substitutos dessa prova.

## Critério de qualidade

Avaliar separadamente: o que a pessoa conseguiu realizar; que capacidade relevante demonstrou ou desenvolveu; esforço, controle e recuperação durante o processo. Quantidade de notas, ações agendadas, respostas geradas ou rodadas de agentes não substitui nenhuma dessas evidências.

O objetivo é maximizar realização e autonomia, desenvolvendo capacidades onde faz diferença. “Sem dívida cognitiva” orienta decisões e verificação; não pode ser apresentado como garantia universal já demonstrada pelo aplicativo.

## Decidir se uma mudança pertence ao Traço

Antes de propor ou implementar, responda no trabalho em curso:

1. Que intenção da pessoa será realizada e qual obstáculo concreto será reduzido?
2. A IA deve produzir, a pessoa precisa praticar uma capacidade pertinente ou é útil combinar ambos?
3. Que artefato, ação ou evidência muda? Como o trabalho continua e como se corrige um erro?
4. Que dado sobre a pessoa é observado, relatado ou apenas hipótese? Qual origem e proteção precisa acompanhar esse dado?
5. Que prova mostraria utilidade, respeitando restrições do pedido e condições externas?

Uma função pode servir principalmente a um dos ciclos; não precisa anexar um exercício a cada entrega. Mas não pode contradizer o outro ciclo, a autonomia ou a origem. Uma melhoria de integridade ou acessibilidade pertence ao produto porque permite realizar com confiança e controle. Catálogo maior, aparência sofisticada e chamadas adicionais de IA não são justificativa suficiente.

Exemplos de decisão: gerar código e um protótipo para a empresa desejada pode pertencer; exigir que a pessoa memorize esse código para liberar a entrega, sem objetivo de aprendizagem, não. Preparar frases e um ensaio para praticar idioma pode pertencer; marcar a fluência como alcançada porque houve três respostas, não. Adicionar um método exige pertinência e proveniência; copiá-lo de uma lista de concorrentes não basta.

Estas perguntas são um critério de desenvolvimento, não telas obrigatórias nem ritual de autorização. Instruções de entrada do repositório: [AGENTS.md](AGENTS.md). A restrição local de uma ferramenta existente não redefine a finalidade global: se faltar uma rota compatível com autoria e proteção, evoluir o contrato e demonstrá-la, em vez de negar a finalidade ou remover guardas indiscriminadamente.
