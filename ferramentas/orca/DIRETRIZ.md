# Diretriz do dono — 06/09/2026

Lida antes do RUMO em toda escolha de volta. Manda sobre a ordem da fila, não sobre os portões: nada aqui autoriza pular a ESTEIRA.

## 1. Qualidade acima de tudo, sempre

Nenhuma volta entra em main abaixo de 9 em toda dimensão. Diante da escolha entre entregar mais rápido e entregar certo, entrega certo. Se a cota estiver acabando, feche menos voltas, nunca voltas piores. Meia funcionalidade provada vale mais que uma inteira sem prova. Quantidade de voltas não é métrica; distância fechada entre visão e prova é.

## 2. O ciclo do orquestrador, em toda volta

Fazer, implementar, corrigir, melhorar, evoluir. Não é uma fila de etapas, é o que você percorre a cada escolha: o que falta fazer, o que dá para implementar agora, o que está errado e precisa correção, o que existe mas está fraco, e o que pode subir de patamar. Volta que só faz uma dessas cinco coisas é uma volta pequena; procure a que faz três.

Antes de escolher, responda em uma linha: que interação do autor com o Traço fica melhor depois desta volta? Se não houver interação, a volta é motor sem superfície e não entra.

## 3. Crescimento exponencial, não linear

Prefira a volta que faz as próximas ficarem mais baratas. Fundação, vocabulário, componente reutilizável e contrato bem posto valem mais que uma tela isolada. Uma volta que resolve uma classe inteira de problema vence três que resolvem um caso cada. Quando duas voltas têm o mesmo valor, escolha a que desbloqueia mais itens do RUMO.

## 4. O ambiente que se modifica sozinho — prioridade alta

É a terceira participante da visão, hoje a lacuna mais aberta do EVOLUCAO ("HTML útil e interativo: possibilidade de produto, não implementada"). Não existe WKWebView nem HTML no app.

O que o dono quer: um artefato que o autor abre, usa, e que se transforma a pedido dele ou por necessidade percebida. Exemplo dele: aprender espanhol. O artefato começa como uma lição, o autor pratica, erra em conjugação, e o próprio artefato se reescreve para atacar aquilo, guardando as versões e a origem de cada mudança.

HTML e não Markdown, pela razão que o dono deu: representação visual e interação. Markdown continua sendo a base de documento e intercâmbio; HTML é a camada de artefato interativo. Um não substitui o outro.

Contratos que essa frente tem de respeitar, e que valem uma consulta ao conselho antes da primeira linha:
- Capacidades delimitadas: o artefato não busca rede, não gasta, não envia, não lê nota protegida. O que ele pode fazer é declarado e visível.
- Toda modificação é uma versão nova com origem: pedido do autor ou necessidade percebida, e qual foi. O autor pode voltar atrás.
- A modificação por necessidade nunca é silenciosa: o artefato diz o que mudou e por quê.
- Praticar dentro do artefato é o segundo ciclo: a tentativa é do autor, a IA não preenche a resposta.
- Estado honesto: exercício gerado, praticado e demonstrado são estados distintos.

Ordem: uma volta de contrato e prova de conceito (um artefato, uma modificação, versões e origem), depois a jornada real de uma matéria de ponta a ponta.

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
