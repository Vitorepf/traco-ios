# Diretriz do dono — 06/09/2026

Lida antes do RUMO em toda escolha de volta. Manda sobre a ordem da fila, não sobre os portões: nada aqui autoriza pular a ESTEIRA.

## 1. Qualidade acima de tudo, sempre

Nenhuma volta entra em main abaixo de 9 em toda dimensão. Diante da escolha entre entregar mais rápido e entregar certo, entrega certo. Se a cota estiver acabando, feche menos voltas, nunca voltas piores. Meia funcionalidade provada vale mais que uma inteira sem prova. Quantidade de voltas não é métrica; distância fechada entre visão e prova é.

## 2. O ciclo do orquestrador, em toda volta

Fazer, implementar, corrigir, melhorar, evoluir. Não é uma fila de etapas, é o que você percorre a cada escolha: o que falta fazer, o que dá para implementar agora, o que está errado e precisa correção, o que existe mas está fraco, e o que pode subir de patamar. Volta que só faz uma dessas cinco coisas é uma volta pequena; procure a que faz três.

Antes de escolher, responda em uma linha: que interação do autor com o Traço fica melhor depois desta volta? Se não houver interação, a volta é motor sem superfície e não entra.

## 3. Crescimento exponencial, não linear

Prefira a volta que faz as próximas ficarem mais baratas. Fundação, vocabulário, componente reutilizável e contrato bem posto valem mais que uma tela isolada. Uma volta que resolve uma classe inteira de problema vence três que resolvem um caso cada. Quando duas voltas têm o mesmo valor, escolha a que desbloqueia mais itens do RUMO.

## 4. O ambiente que se modifica sozinho — em Markdown, prioridade alta

**Decisão do dono, 07/09/2026, depois da verificação rigorosa do estado do app: o artefato que se transforma nasce em Markdown, não em HTML.** O que ele quer não mudou: um artefato que o autor abre, usa, e que se transforma a pedido dele ou por necessidade percebida. O exemplo dele continua o mesmo: a lição de espanhol que o autor pratica, erra em conjugação, e que se reescreve para atacar aquilo, guardando as versões e a origem de cada mudança.

Por que Markdown vence para este caso, e é o caso que importa:
- O laço que falta é de OBSERVAÇÃO e VERSÃO, não de renderização. O Trabalho já tem versões com origem, tentativa do autor como evidência separada (ADR 05r), pedido de ajuste e ida e volta pelo arquivo (ADRs 05l e 06a). O que não existe é a volta em que a observação da tentativa gera a versão seguinte e diz por quê.
- O Caderno já renderiza blocos próprios — campos, tarefas, áudio, recipientes `:::slug` — com Tema, VoiceOver, Dynamic Type e movimento reduzido. Um bloco de exercício é mais um tipo nessa lista, e a régua de 9 em toda dimensão alcança o conteúdo. Dentro de um WKWebView nada disso vale.
- Selo, expressiva, corpus, índice, MCP, exportação e a comparação ancorada na divergência já cobrem `.md`. HTML exigiria refazer o contrato de privacidade para um formato que carrega script e link.
- O modelo de bordo produz Markdown com muito mais confiança do que HTML com script. As provas 4, 5 e 6 mostram que ele já falha em JSON estrito; pedir uma página interativa correta a ele é pedir o que não vem, e o dono quer depender menos do Grok (§5).

Onde o HTML continua tendo lugar, e só ali: protótipo de experiência, mock de oferta ou de app que se testa com outra pessoa, simulação, visualização com interação própria — o caso "criar e testar uma oferta ou um protótipo" da visão. Faixa estreita, sandbox sem rede e sem acesso a notas, capacidades declaradas na tela, e só quando um caso real pedir. **Nenhuma volta de HTML abre antes de o artefato em Markdown provar o laço inteiro.** `FormatoArtefato.html` fica como está, sem código.

Contratos que esta frente tem de respeitar, em qualquer formato:
- Capacidades delimitadas: o artefato não busca rede, não gasta, não envia, não lê nota protegida. O que ele pode fazer é declarado e visível.
- Toda modificação é uma versão nova com origem: pedido do autor ou necessidade percebida, e qual foi. O autor pode voltar atrás.
- A modificação por necessidade nunca é silenciosa: o artefato diz, no próprio documento, o que mudou e por quê.
- Praticar dentro do artefato é o segundo ciclo: a tentativa é do autor, a IA não preenche a resposta.
- Estado honesto: exercício gerado, praticado e demonstrado são estados distintos; "reescrito" não é "aprendido".

Ordem: a V17 do RUMO — uma volta de contrato e prova (um artefato com bloco de exercício, uma tentativa do autor, uma modificação nascida da observação com origem e motivo ditos no documento, versão anterior a um toque) —, depois a jornada real de uma matéria de ponta a ponta. A qualidade da geração é pré-requisito medido, não presumido: a frente `codex/qualidade-ia` mede a base e o candidato, e a V17 usa a sonda dela para provar o caso real.

## 5. Aparelho antes da rede, com medida

O app já usa o modelo da Apple (`SystemLanguageModel`, `LanguageModelSession`, `@Generable`) em Sabia, AnaliseDeBordo, OficinaTrabalho e PraticaTrabalho, e o Grok em seis arquivos de Analise. Reduzir a dependência do Grok é objetivo do dono e é bom para privacidade e custo.

Mas a V5 mediu e registrou: para conferência, o modelo de bordo estourou o limite ou devolveu JSON inválido. Então a regra é medir, não torcer. Para cada rota que hoje chama o Grok, uma volta pode: medir os dois lado a lado no mesmo caso real, publicar a comparação, e mover para o aparelho apenas o que passar com a mesma qualidade. Rota que não passar continua no Grok e o motivo fica escrito. Nunca trocar por bordo e piorar calado.

Vale também olhar o que a Apple dá pronto e o app ainda não usa, quando substitui código próprio com qualidade igual ou melhor: tradução, fala, escrita, imagem, busca semântica.

## 6. Decida você. O dono não é passo do fluxo

O dono trabalha de forma assíncrona e não vai responder em tempo real. Orquestrador parado esperando resposta é falha sua, não paciência. Você tem esforço xhigh e o conselho Astra justamente para decidir sozinho o que é difícil.

**O teste é a reversibilidade, não a importância.** Decisão difícil e reversível você toma; decisão fácil e irreversível você não toma.

Decida sozinho, sempre, e registre a decisão com o porquê no LACO em uma linha: arquitetura, contrato, ADR, ordem do RUMO, escopo da volta, direção visual, nome, movimento, componente, o que entra e o que fica de fora, trocar um modelo por outro, recusar ou aceitar um achado da revisão, refazer uma volta, abandonar uma abordagem. Tudo isso vive em git e o dono desfaz quando quiser.

**Quando estiver dividido entre dois caminhos válidos, consulte o Astra e decida com o parecer.** Não devolva a dúvida ao dono. O parecer é insumo; a decisão é sua.

**Só estes param e esperam**, e a lista é fechada:
- risco real aos dados do dono no aparelho dele;
- gastar dinheiro, publicar, enviar mensagem ou qualquer coisa que saia da máquina;
- mudar contrato de privacidade, autoria ou selo;
- apagar trabalho do dono.

Mesmo nesses casos: abra o gate, escreva a pergunta em ferramentas/orca/PERGUNTAS.md com as opções e a sua recomendação, e SIGA com todas as outras voltas. Uma volta esperando nunca para o laço. Se a espera passar de duas horas e a decisão for reversível na prática, tome a sua recomendação como resposta, escreva que foi por tempo, e siga; o dono desfaz se discordar.

Escolha a opção que preserva mais: dados, versões, origem e a possibilidade de voltar atrás. Quando o risco for de perda, prove primeiro em simulador de teste, nunca no aparelho do dono.
