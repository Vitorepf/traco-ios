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

## 7. Ordem do dono, 08/09/2026 22h — controle total do computador, e a nota 9

Palavras dele: "todos os modelos que estão no Orca trabalhando no Traço têm total liberdade de controlar meu computador e evoluir o Traço iOS. O foco número um é levar o Traço iOS para 9/10; ainda está em 7, e demorou o dia inteiro para subir de 6 para 7. Foquem na melhoria da IA, testem a IA, têm total controle do meu computador. Elevem o padrão de design e de experiência: curva-zero, design-router, gate-loop. Elevem ao extremo a qualidade e o poder do Traço iOS."

O que isso muda:
- **Controle do computador liberado para todo worker do Orca** (computer-use do Orca, simulador, apps do Mac, Espelhamento do iPhone quando a prova exigir o aparelho), com uma condição só: avisar no comentário do worktree ao começar e ao terminar, e nunca dois workers no mesmo app ao mesmo tempo. A lei do mouse da ESTEIRA passa a ser esta. **VOZ, VOICEOVER E iPAD CONTINUAM PROIBIDOS**, sem exceção.
- **Foco 1: a IA.** As sete operações marcadas `indisponivelPorQualidade` na medida de 08/09 voltam UMA POR UMA, cada uma com a sua volta, medida de novo com o Grok pela sonda antes e depois, e só sai da lista com nota 9 nas cinco dimensões de QUALIDADE-IA.md. Contexto, prompt, esquema de saída e teto são as quatro alavancas; a régua é a saída inteira lida, nunca o hash.
- **Foco 2: design e experiência ao extremo.** Toda volta visual passa por `design-router` com as seis fases citadas, `curva-zero` medida em toques antes e depois, e `gate-loop` como dono do ciclo. Tela abaixo de 9 no scorecard tem prioridade sobre função nova.
- **A nota é a régua.** Cada fecho de volta diz o que mudou na nota da dimensão que tocou, com a prova. O dia inteiro de 08/09 subiu um ponto; o que sobe o próximo é a IA que serve e a jornada real do dono.

## 8. Ordem do dono, 09/09/2026 9h — o mais rápido possível, zero bugs, otimizar ao máximo

Palavras dele: "deixe o Orca focado em melhorar o Traço iOS da forma mais rápida possível. Eliminar todos os bugs, erros e otimizar ao máximo. Use as skills ponytail se precisar."

O que isso muda:
- **Velocidade sem perder o portão:** o que acelera é fechar, não abrir. Toda volta nasce com o menor escopo que prova o ganho; corrigir um defeito é uma volta curta com teste que reproduz e captura, não uma volta de tela. O revisor devolve em uma passada o que consegue; passada de acabamento vira dívida nomeada no RUMO, não terceira rodada.
- **Caça a defeitos como frente permanente:** uma volta `B` por vez varre uma classe inteira de erro — os seis `try!` de produção, estados inalcançáveis, rota que cala em vez de dizer, ação que não faz nada, texto que promete o que o motor não sustenta — com teste que reproduz antes e fica vermelho sem o conserto. Fonte: a auditoria de 07/09, a dívida da limpeza no RUMO, o `LETRAS-ADR` e o que os revisores acharam e ficou "aberto".
- **Otimizar ao máximo:** `swiftui-performance-audit` e Instruments nas telas de lista, editor e parser; hitch, alocação por tecla e reparse inteiro são defeitos. Cada volta de otimização traz a medida antes e depois, no mesmo aparelho.
- **Ponytail é lei de código:** a solução mais curta que funciona; nada de abstração para um caso, nada de camada "para depois"; deleção conta como entrega; a suíte cobre o ramo que muda e mais nada. O revisor reprova por excesso tanto quanto por falta.
- **A ordem de fila continua a da §7** (IA até a nota 9, design ao extremo), com a caça a defeitos correndo em paralelo como trilha.

## 9. Veredito do dono sobre o design, 09/09 11h22 — "uma porcaria, 4/10, deplorável, muito IA slop"

Ele olhou a tela de Notas do build de hoje (chips de filtro em cápsula, a linha "Trabalhos", a seção "A VOLTA", a lista com etiqueta de método e de domínio à direita, a barra "Buscar ou perguntar", a barra de abas com o Escrever em âmbar) e deu **4 de 10**. A palavra dele é **slop**: tela que qualquer app de notas gerado por IA teria. A barra dele são apps lapidados por anos — Notes, Things, Craft — e a sensação de FOLHA, não de lista de sistema.

O que isso muda:
- **A nota das telas do scorecard cai para o que ele deu.** Notas = 4. As outras telas se presumem no mesmo nível até ele dizer o contrário. Nenhuma "nota 9" do juiz vale contra o veredito dele; o juiz calibra pelo dono.
- **Volta de design D1, Notas, abre como frente prioritária ao lado da IA.** Fase 5 do design-router primeiro (auditar antes de tocar, com esta tela como o "antes"), depois Ancorar com direção própria: o que dá identidade ao Traço é o papel, a letra e o silêncio, não cápsulas, etiquetas e barras. `tastemaker` para o teste contra design genérico ("se trocar o nome, serve a qualquer app?"), `curva-zero` para a jornada de achar e marcar, `design-router` nas seis fases, `gate-loop` no ciclo. Juiz G4 em Fable, e o dono julga o resultado em vídeo.
- **O que ele NÃO quer ver:** cápsula de filtro em fileira, etiqueta em caixa alta à direita de cada linha, seção em rótulo de sistema ("A VOLTA"), barra de busca de sistema, "Trabalhos" como linha de menu. O que ele quer sentir: uma folha, hierarquia por tipografia, o método e o domínio ditos com uma palavra em tinta suave e não em selo, o gesto de escrever como a coisa principal.
- **Cada volta de tela daqui em diante termina com um vídeo de 15 s no aparelho da conta, enviado ao dono**, e só ele fecha a nota.

## 10. Ordem do dono, 09/09 12h — "sempre use o melhor Grok possível"

Decisão sobre a régua da Q2: o dono aceita a espera em troca da resposta que se sustenta. **Toda rota que chama o Grok usa o melhor modelo que a conta expõe**, não o padrão antigo (`grok-4.3`). "Melhor" é medido, não presumido: a conta lista doze modelos (`grok-4.3`, `4.5`, `4.6`, a família `4.20`…); a volta que adota escolhe entre os dois mais capazes pela sonda, no mesmo caso, e registra a medida. O modelo escolhido vira o padrão global de `Grok.modelo`, com esforço medido por operação (o 4.6 em `medium` deu 36 de 36 em `responder`).

O preço, assumido pelo dono: 36 s de média e 77 s de pior caso em vez de 1,4 s. Então a espera vira estado da tela, nunca silêncio: o cartão diz que está pensando, mostra o tempo passando, deixa cancelar, e o tempo limite da chamada sobe para caber o pior caso medido, como a ADR 08r fez no Trabalho. Espera sem estado é defeito de design.

Uma operação sai de `indisponivelPorQualidade` quando passa com o melhor modelo; se nem com ele passar, continua na lista com a medida nova.

## 11. Ordem do dono, 10/09 07h30 — "o foco de hoje é atingir o mais perto da nota 10/10 possível"

A nota de ontem à noite foi **7**. O que a sobe está medido, e a ordem do dia é a ordem de valor:

1. **A IA que responde ao autor** (vale mais de um ponto). `responderNasNotas` primeiro — a corrida da Q3-C JÁ EXISTE no disco (`~/orca/workspaces/traco-ios/q3-c/prova/lote09d-*`, 4.3 e 4.5, 44 linhas cada, 23h27 de 09/09) e ninguém leu: lê-se antes de gastar o aparelho outra vez. Depois `responder` (o conserto é o prompt proibir inventar estrutura de documento; comparação de UMA alavanca, três corridas por candidato), depois instigar e contrapor, ecos, calibragem, Recordar. Cada uma sai da lista com nota 9 nas cinco dimensões e captura no aparelho da conta (`B91C8DEF`).
2. **A jornada real do espanhol**, de ponta a ponta, no iPhone do dono e pelo Mac com o bot — depende do dono ter o app atualizado; a equipe deixa o build pronto e a jornada ensaiada no aparelho da conta.
3. **Design sem slop** — o D1 (Notas) espera a nota do dono. Aprovado, a régua vai a Página, Calendário e Recordar; reprovado, a régua muda antes de tocar em outra tela. Ninguém redesenha outra tela antes do veredito.
4. **Dívidas que derrubam**: os cinco `try!`, F6b (o botão da bloqueada abre o app), MAC-2 pela metade (o bot ainda não escreve no Trabalho), MAC-3 fechada, a causa da voz.

O teto continua **três voltas** e **um aparelho com conta**. O segundo (teste 3, `34CC3F94`, hoje o da suíte) só vira aparelho de conta quando o dono disser "pode" e fizer o login. As leis da ESTEIRA valem inteiras: VOZ, VOICEOVER E iPAD PROIBIDOS; nunca `erase`, `clearState`, `uninstall` ou `xcodebuild test` no `B91C8DEF`.

## 12. Ordem do dono, 10/09 10h35 — "vamos parar de testar e perder tempo com letra máxima, nunca vou usar isso"

**Letra máxima sai do escopo.** Nenhuma volta, portão, captura, teste, vídeo ou dívida em tamanhos de acessibilidade (AX1 a AX5, XXXL). A volta AX5-1 fecha agora sem mesclar nada; o P1 "a barra sai da tela em AX5" sai do RUMO como dívida e vira uma linha de registro. A linha "Dynamic Type" do scorecard passa a valer só até **large** (o padrão do iPhone) — é o que o dono usa e é o que se fotografa. O código que já existe fica como está: ninguém o remove nem o mantém; se um dia quebrar em AX5, não é defeito. Acessibilidade que continua valendo: alvos de 44 pt, contraste, rótulos e ordem na árvore — coisas que o dono também sente. O tempo que isso libera vai para a IA (§11).
